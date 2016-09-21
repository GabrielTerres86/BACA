/*-----------------------------------------------------------------------------

    b1crap30.p - OPERAÇÕES PARA AUTORIZAÇÕES DE DÉBITO AUTOMÁTICO
    
    Alteracoes:
                
------------------------------------------------------------------------------*/
{dbo/bo-erro1.i}

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0092tt.i }

DEF VAR i-cod-erro      AS INTEGER.
DEF VAR c-desc-erro     AS CHAR.

DEF VAR h-b1wgen0092 AS HANDLE                                      NO-UNDO.


PROCEDURE retorna-convenios-por-segmto:

    DEF     INPUT  PARAM par_nmrescop     AS CHAR                NO-UNDO.
    DEF     INPUT  PARAM par_cdsegmto     AS INTE                NO-UNDO.
    DEF     OUTPUT PARAM pListAux         AS CHAR                NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.
                                                                
    IF  par_cdsegmto = 99 THEN
        DO:
            FOR EACH crapcon WHERE crapcon.cdcooper = crapcop.cdcooper  AND
                                   crapcon.flgcnvsi = FALSE             AND
                                   crapcon.cdsegmto > 0                 NO-LOCK,
                FIRST gnconve WHERE gnconve.cdhiscxa = crapcon.cdhistor AND
                                    gnconve.flgativo = TRUE             AND
                                    gnconve.nmarqatu <> ""              AND
                                    gnconve.cdhisdeb <> 0 NO-LOCK:
                
                ASSIGN pListAux = pListAux +
                                 (IF pListAux = '' THEN '' ELSE ',') +
                                  STRING(crapcon.nmextcon) + ',' +
                                  STRING(crapcon.cdempcon) + '/' + 
                                  STRING(crapcon.cdsegmto).
            END.
        END.
    ELSE
        DO:
            FOR EACH crapcon WHERE crapcon.cdcooper = crapcop.cdcooper  AND
                                   crapcon.flgcnvsi = FALSE             AND                                  
                                   crapcon.cdsegmto = par_cdsegmto      NO-LOCK,
                FIRST gnconve WHERE gnconve.cdhiscxa = crapcon.cdhistor AND
                                    gnconve.flgativo = TRUE             AND
                                    gnconve.nmarqatu <> ""              AND
                                    gnconve.cdhisdeb <> 0 NO-LOCK:

                ASSIGN pListAux = pListAux +
                                 (IF pListAux = '' THEN '' ELSE ',') +
                                  STRING(crapcon.nmextcon) + ',' +
                                  STRING(crapcon.cdempcon).
            END.
        END.

    IF  pListAux = '' THEN
        ASSIGN pListAux = 'Sem empresas conveniadas nesse segmento,0'.

    RETURN "OK".       

END PROCEDURE.


PROCEDURE busca-convenios-codbarras:

    DEF     INPUT  PARAM par_nmrescop     AS CHAR                NO-UNDO.
    DEF     INPUT  PARAM par_cdempcon     AS INTE                NO-UNDO.
    DEF     INPUT  PARAM par_cdsegmto     AS INTE                NO-UNDO.
    DEF    OUTPUT  PARAM par_flgcvdis     AS LOGI                NO-UNDO.

    ASSIGN par_flgcvdis = FALSE.

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN busca_convenios_codbarras IN h-b1wgen0092 (INPUT crapcop.cdcooper,
                                                   INPUT par_cdempcon,
                                                   INPUT par_cdsegmto,
                                                   OUTPUT TABLE tt-convenios-codbarras).

    DELETE PROCEDURE h-b1wgen0092.

    FIND FIRST tt-convenios-codbarras WHERE tt-convenios-codbarras.cdempcon = par_cdempcon 
                                        AND tt-convenios-codbarras.cdsegmto = par_cdsegmto
                                            NO-LOCK NO-ERROR.
    
    IF  AVAIL tt-convenios-codbarras THEN
        ASSIGN par_flgcvdis = TRUE.

    /* Oferta Pró-Ativa */
    IF  crapcop.flgofatr = FALSE THEN
        ASSIGN par_flgcvdis = FALSE.

    RETURN "OK".

END PROCEDURE.


PROCEDURE obtem-autorizacoes-debito:

    DEF INPUT  PARAM par_nmrescop   AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad   AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta   AS DECI               NO-UNDO.
    DEF INPUT  PARAM par_cdsegmto   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_cdempcon   AS INTE               NO-UNDO.
    DEF OUTPUT PARAM par_flgdbaut   AS LOGI               NO-UNDO.    
                                                          
    EMPTY TEMP-TABLE tt-autori.

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
    
    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN busca-autori IN h-b1wgen0092
        ( INPUT crapcop.cdcooper,
          INPUT 0,            
          INPUT 0,            
          INPUT par_cdoperad, 
          INPUT "CXONLINE", 
          INPUT 2, /* CXONLINE */            
          INPUT par_nrdconta, 
          INPUT 0, 
          INPUT YES,
          INPUT crapdat.dtmvtolt,
          INPUT "C",
          INPUT "0",
          INPUT 0,
          INPUT "N",
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-autori).

    DELETE PROCEDURE h-b1wgen0092.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = tt-erro.dscritic.
            ELSE
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Problemas na BO 92".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.

    ASSIGN par_flgdbaut = FALSE.
            
    FOR EACH tt-autori WHERE tt-autori.cdempcon = par_cdempcon AND
                             tt-autori.cdsegmto = par_cdsegmto NO-LOCK:
        ASSIGN par_flgdbaut = TRUE.
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE valida-campos-debaut:

    DEF INPUT  PARAM par_nmrescop   AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta   AS DECI               NO-UNDO.
    DEF INPUT  PARAM par_cdempcon   AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_cdrefere   AS DECI               NO-UNDO.
    DEF INPUT  PARAM par_inlimite   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_vlrmaxdb   AS DECI               NO-UNDO.
    DEF INPUT  PARAM par_dshisext   AS CHAR               NO-UNDO.    
    DEF INPUT  PARAM par_cddsenha   AS INTE               NO-UNDO.
    DEF OUTPUT PARAM par_foco       AS CHAR               NO-UNDO.

    DEF VAR aux_flgsevld            AS LOGI                 NO-UNDO.

    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    IF  par_cdempcon = "" THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Selecione uma empresa.".
                   par_foco    = "13". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
  
            RETURN "NOK".
        END.

    IF  par_cdrefere = 0 THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Preencha a Identificação do Consumidor.".
                   par_foco    = "15".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
  
            RETURN "NOK".
        END.

    IF  par_inlimite = 1 AND 
        par_vlrmaxdb = 0 THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Insira o valor máximo de débito.".
                   par_foco    = "18". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
  
            RETURN "NOK".
        END.

    ASSIGN aux_flgsevld = FALSE.

    IF  par_cddsenha = 0 THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Preencha a Senha do Cartão Magnético."
                   par_foco    = "20". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
  
            RETURN "NOK".
        END.
    ELSE
        DO:
            FOR EACH crapcrm WHERE crapcrm.cdcooper = crapcop.cdcooper AND
                                   crapcrm.nrdconta = par_nrdconta     NO-LOCK:

                IF  ENCODE(STRING(par_cddsenha)) = crapcrm.dssencar THEN
                    DO:
                        ASSIGN aux_flgsevld = TRUE.
                        LEAVE.
                    END.
            END.

            IF  aux_flgsevld = FALSE THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Senha do Cartão Magnético incorreta."
                           par_foco    = "20". 
        
                    RUN cria-erro (INPUT par_nmrescop,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
          
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE inclui-debito-automatico:

    DEF INPUT  PARAM par_nmrescop   AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad   AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta   AS DECI               NO-UNDO.
    DEF INPUT  PARAM par_cdsegmto   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_cdempcon   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_cdrefere   AS DECI               NO-UNDO.
    DEF INPUT  PARAM par_vlrmaxdb   AS DECI               NO-UNDO.
    DEF INPUT  PARAM par_dshisext   AS CHAR               NO-UNDO.    
    DEF OUTPUT PARAM par_foco       AS CHAR               NO-UNDO.
                                                          
    DEF VAR aux_nmdcampo            AS CHAR               NO-UNDO.
    DEF VAR aux_nmprimtl            AS CHAR               NO-UNDO.
    DEF VAR aux_nmfatret            AS CHAR               NO-UNDO.
                                                          
    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN busca_convenios_codbarras IN h-b1wgen0092 (INPUT crapcop.cdcooper,
                                                   INPUT par_cdempcon, 
                                                   INPUT par_cdsegmto,
                                                   OUTPUT TABLE tt-convenios-codbarras).

    DELETE PROCEDURE h-b1wgen0092.

    FIND FIRST tt-convenios-codbarras WHERE tt-convenios-codbarras.cdempcon = par_cdempcon
                                        AND tt-convenios-codbarras.cdsegmto = par_cdsegmto
                                            NO-LOCK NO-ERROR.
    
    IF  RETURN-VALUE = "NOK" OR NOT AVAIL tt-convenios-codbarras  THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Convenio nao encontrado."
                   par_foco    = "14". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).  
            RETURN "NOK".
        END.
    
    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN valida-dados IN h-b1wgen0092
        ( INPUT crapcop.cdcooper, 
          INPUT 0,            
          INPUT 0, 
          INPUT par_cdoperad, 
          INPUT "CXONLINE", 
          INPUT 2, /** Caixa ON_LINE **/
          INPUT par_nrdconta, 
          INPUT 1, 
          INPUT YES,
          INPUT "I",
          INPUT tt-convenios-codbarras.cdhistor,
          INPUT par_cdrefere,
          INPUT crapdat.dtmvtolt,
          INPUT ?,
          INPUT ?, /*dtlimite*/
          INPUT crapdat.dtmvtolt,
          INPUT ?,
         OUTPUT aux_nmdcampo,
         OUTPUT aux_nmprimtl,
         OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0092.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = tt-erro.dscritic
                       par_foco    = "13".      
            ELSE
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Problemas na BO 92"
                       par_foco    = "13". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN grava-dados IN h-b1wgen0092
        ( INPUT crapcop.cdcooper,                 /*  par_cdcooper   */
          INPUT 0,                                /*  par_cdagenci   */
          INPUT 0,                                /*  par_nrdcaixa   */
          INPUT par_cdoperad,                     /*  par_cdoperad   */
          INPUT "CXONLINE",                       /*  par_nmdatela   */
          INPUT 2,                                /*  par_idorigem   */
          INPUT par_nrdconta,                     /*  par_nrdconta   */
          INPUT 1,                                /*  par_idseqttl   */
          INPUT YES,                              /*  par_flgerlog   */
          INPUT crapdat.dtmvtolt,                 /*  par_dtmvtolt   */
          INPUT "I",                              /*  par_cddopcao   */         
          INPUT tt-convenios-codbarras.cdhistor,  /*  par_cdhistor   */
          INPUT par_cdrefere,                     /*  par_cdrefere   */
          INPUT 0,                                /*  par_cddddtel   */
          INPUT crapdat.dtmvtolt,                 /*  par_dtiniatr   */
          INPUT ?,                                /*  par_dtfimatr   */
          INPUT ?,                                /*  par_dtultdeb   */
          INPUT ?,                                /*  par_dtvencto   */
          INPUT par_dshisext,                     /*  par_nmfatura   */
          INPUT par_vlrmaxdb,                     /*  par_vlrmaxdb   */
          INPUT "N",                              
          INPUT par_cdempcon,                     
          INPUT par_cdsegmto,                     
          INPUT "N",                              
          INPUT "",                     
          INPUT "",                     
          INPUT "",                     
          INPUT "",                     
          INPUT "",                     
         OUTPUT aux_nmfatret,                     
         OUTPUT TABLE tt-erro).    
         
    DELETE PROCEDURE h-b1wgen0092.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = tt-erro.dscritic
                       par_foco    = "13".
            ELSE
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Problemas na BO 92"
                       par_foco    = "13". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.
    ELSE
        DO:
            RUN elimina-erro (INPUT par_nmrescop,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa).
        
            ASSIGN i-cod-erro  = 0 
                   c-desc-erro = "Autorização cadastrada com sucesso.".
        
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.

    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */

