/*-----------------------------------------------------------------------------

    b1crap30.p - OPERAÇÕES PARA AUTORIZAÇÕES DE DÉBITO AUTOMÁTICO
    
    Alteracoes: 31/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
                
------------------------------------------------------------------------------*/
{dbo/bo-erro1.i}

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0092tt.i }

DEF VAR i-cod-erro      AS INTEGER.
DEF VAR c-desc-erro     AS CHAR.

DEF VAR h-b1wgen0092 AS HANDLE                                      NO-UNDO.
DEF VAR h_b2crap00               AS HANDLE                            NO-UNDO.
DEF VAR h-b1crap02               AS HANDLE                            NO-UNDO.


PROCEDURE retorna-convenios-por-segmto:

    DEF     INPUT  PARAM par_nmrescop     AS CHAR                NO-UNDO.
    DEF     INPUT  PARAM par_cdsegmto     AS INTE                NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-convenios-codbarras.

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.
                                                                
    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN busca_convenios_codbarras IN h-b1wgen0092 (INPUT crapcop.cdcooper,
                                                   INPUT 0,
                                                   INPUT IF par_cdsegmto = 99 THEN 0 ELSE par_cdsegmto,
                                                   OUTPUT TABLE tt-convenios-codbarras).

    DELETE PROCEDURE h-b1wgen0092.

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
    DEF OUTPUT PARAM par_foco       AS CHAR               NO-UNDO.

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
          INPUT STRING(tt-convenios-codbarras.flgcnvsi, "S/N"),
          INPUT tt-convenios-codbarras.cdempcon,
          INPUT tt-convenios-codbarras.cdsegmto,
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

PROCEDURE retorna-conta-cartao:
    
    DEF INPUT        PARAM p-cooper              AS CHAR.
    DEF INPUT        PARAM p-cod-agencia         AS INTEGER.  /* Cod. Agencia    */
    DEF INPUT        PARAM p-nro-caixa           AS INTEGER.  /* Numero Caixa    */
    DEF INPUT        PARAM p-cartao              AS DEC.      /* Nro Cartao */
    DEF OUTPUT       PARAM p-nro-conta           AS DEC.      /* Nro Conta       */
    DEF OUTPUT       PARAM p-nrcartao            AS DECI.
    DEF OUTPUT       PARAM p-idtipcar            AS INTE.
                      
    DEF VAR h-b1wgen0025 AS HANDLE               NO-UNDO.
    DEF VAR aux_dscartao AS CHAR                 NO-UNDO.

    DEF VAR aux_nrcartao AS DEC                  NO-UNDO.
    DEF VAR aux_nrdconta AS INT                  NO-UNDO.
    DEF VAR aux_cdcooper AS INT                  NO-UNDO.
    DEF VAR aux_inpessoa AS INT                  NO-UNDO.
    DEF VAR aux_idsenlet AS LOGICAL              NO-UNDO.
    DEF VAR aux_idseqttl AS INT                  NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                 NO-UNDO.  
    DEF VAR i_conta      AS DEC                   NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
 
    IF   p-cartao = 0   THEN      
          DO:
              ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Numero do cartao deve ser Informado".           
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
          END.
          
     ASSIGN aux_dscartao = "XX" + SUBSTR(STRING(p-cartao),1,16) + "=" + SUBSTR(STRING(p-cartao),17).
          
     RUN sistema/generico/procedures/b1wgen0025.p 
         PERSISTENT SET h-b1wgen0025.
         
     RUN verifica_cartao IN h-b1wgen0025(INPUT crapcop.cdcooper,
                                         INPUT 0,
                                         INPUT aux_dscartao, 
                                         INPUT crapdat.dtmvtolt,
                                        OUTPUT p-nro-conta,
                                        OUTPUT aux_cdcooper,
                                        OUTPUT p-nrcartao,
                                        OUTPUT aux_inpessoa,
                                        OUTPUT aux_idsenlet,
                                        OUTPUT aux_idseqttl,
                                        OUTPUT p-idtipcar,
                                        OUTPUT aux_dscritic).

     DELETE PROCEDURE h-b1wgen0025.
     
     IF   RETURN-VALUE <> "OK"   THEN /* Se retornou erro */
          DO:
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT aux_dscritic,
                             INPUT YES).
              RETURN "NOK".
          END.
    
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    
    ASSIGN i_conta = p-nro-conta.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.

    RUN retornaCtaTransferencia IN h-b1crap02 (INPUT p-cooper,
                                               INPUT p-cod-agencia, 
                                               INPUT p-nro-caixa, 
                                               INPUT p-nro-conta, 
                                              OUTPUT aux_nrdconta).
    IF   RETURN-VALUE = "NOK" THEN 
         DO:
             DELETE PROCEDURE h-b1crap02.
             RETURN "NOK".
         END.
         
    IF   aux_nrdconta <> 0 THEN
         ASSIGN p-nro-conta = aux_nrdconta.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE valida_senha_cartao: 
    
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-nro-conta        AS DEC.     
    DEF INPUT  PARAM p-nrcartao         AS DECI.
    DEF INPUT  PARAM p-opcao            AS CHAR.
    DEF INPUT  PARAM p-senha-cartao     AS CHAR.
    DEF INPUT  PARAM p-idtipcar         AS INTE.
    DEF INPUT  PARAM p-infocry          AS CHAR.
    DEF INPUT  PARAM p-chvcry           AS CHAR.
    
    DEF VAR h-b1wgen0025 AS HANDLE                                NO-UNDO.
    
    DEF VAR aux_cdcritic AS INTE                                  NO-UNDO.    
    DEF VAR aux_dscritic AS CHAR                                  NO-UNDO.
    
    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).
           
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
     
    IF   p-opcao = "C"   THEN
         DO:
            IF  TRIM(p-senha-cartao) = '' THEN
                DO:
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT 0,
                                   INPUT "Insira uma senha.",
                                   INPUT YES).
                     RETURN "NOK".
                END.
				
            RUN sistema/generico/procedures/b1wgen0025.p 
                 PERSISTENT SET h-b1wgen0025.
                 
            RUN valida_senha_tp_cartao IN h-b1wgen0025(INPUT crapcop.cdcooper,
                                                       INPUT p-nro-conta, 
                                                       INPUT p-nrcartao,
                                                       INPUT p-idtipcar,
                                                       INPUT p-senha-cartao,
                                                       INPUT p-infocry,
                                                       INPUT p-chvcry,
                                                      OUTPUT aux_cdcritic,
                                                      OUTPUT aux_dscritic). 

            DELETE PROCEDURE h-b1wgen0025.
           
            IF   RETURN-VALUE <> "OK"   THEN /* Se retornou erro */
                 DO:
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT aux_cdcritic,
                                    INPUT aux_dscritic,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
         END.
         
    RETURN "OK".
    
END PROCEDURE.


/* .......................................................................... */

