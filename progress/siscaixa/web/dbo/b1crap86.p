/*--------------------------------------------------------------------------*/
/*  b1crap86.p - Estornos - Lançamento de cheques (rotina 51 + lanchq)      */ 
/*--------------------------------------------------------------------------*/

/* Alteracoes: 29/07/2011 - Adaptado da rotina 71 (Guilherme).

               21/09/2011 - Alterar banco caixa de 500 p/ 11 
                          - Alterar o Lote de 28000 + nro-caixa para 
                                              30000 + Nro-caixa
                          - Adaptacao para utilizacao de craplcx no lanmto                    
                            (Guilherme).                  
               
               21/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)            
...........................................................................*/
                             
{dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }

DEF  VAR glb_nrcalcul         AS DECIMAL                           NO-UNDO.
DEF  VAR glb_dsdctitg         AS CHAR                              NO-UNDO.
DEF  VAR glb_stsnrcal         AS LOGICAL                           NO-UNDO.

DEFINE VARIABLE i-cod-erro    AS INT                               NO-UNDO.
DEFINE VARIABLE c-desc-erro   AS CHAR                              NO-UNDO.

DEF VAR i-nro-lote            AS INTE                              NO-UNDO.
DEF VAR aux_nrdconta          AS INTE                              NO-UNDO.
DEF VAR i_conta               AS DEC                               NO-UNDO.
DEF VAR aux_nrtrfcta LIKE  craptrf.nrsconta                        NO-UNDO.
DEF VAR l-achou               AS LOG                               NO-UNDO.
DEF VAR l-achou-migrado       AS LOG                               NO-UNDO.
DEF VAR l-achou-horario-corte AS LOG                               NO-UNDO.

DEF VAR h_b1crap00            AS HANDLE                            NO-UNDO.
DEF VAR h_b2crap00            AS HANDLE                            NO-UNDO.

DEF VAR aux_contador          AS INTE                              NO-UNDO.
DEF VAR dt-menor-fpraca       AS DATE                              NO-UNDO.
DEF VAR dt-maior-praca        AS DATE                              NO-UNDO.
DEF VAR dt-menor-praca        AS DATE                              NO-UNDO.
DEF VAR dt-maior-fpraca       AS DATE                              NO-UNDO.
DEF VAR c-docto               AS CHAR                              NO-UNDO.
DEF VAR c-docto-salvo         AS CHAR                              NO-UNDO.
DEF VAR i-docto               AS INTE                              NO-UNDO.

DEF VAR aux_lsconta1          AS CHAR                              NO-UNDO.
DEF VAR aux_lsconta2          AS CHAR                              NO-UNDO.
DEF VAR aux_lsconta3          AS CHAR                              NO-UNDO.
DEF VAR aux_lscontas          AS CHAR                              NO-UNDO.

DEF VAR i_nro-docto           AS INTE                              NO-UNDO.
DEF VAR i_nro-talao           AS INTE                              NO-UNDO.
DEF VAR i_posicao             AS INTE                              NO-UNDO.
DEF VAR i_nro-folhas          AS INTE                              NO-UNDO. 

DEF VAR in99                  AS INTE NO-UNDO.

DEF  VAR aux_ctpsqitg         AS DEC                               NO-UNDO.
DEF  VAR aux_nrdctitg LIKE crapass.nrdctitg                        NO-UNDO.
DEF  VAR aux_nrctaass LIKE crapass.nrdconta                        NO-UNDO.

DEF  VAR flg_exetrunc         AS LOG                               NO-UNDO.

/**   Conta Integracao **/
DEF  BUFFER crabass5 FOR crapass.                             
DEF  VAR aux_nrdigitg         AS CHAR                              NO-UNDO.
DEF  VAR glb_cdcooper         AS INT                               NO-UNDO.
{includes/proc_conta_integracao.i}

DEFINE TEMP-TABLE tt-lancamentos NO-UNDO
    FIELD tpdocmto AS INTE
    FIELD dtmvtolt AS DATE
    FIELD vllanmto AS DECI.

PROCEDURE valida-autenticacao:
    
    DEF INPUT  PARAM p-cooper            AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia       AS INT NO-UNDO. /* Cod. Agencia     */
    DEF INPUT  PARAM p-nro-caixa         AS INT NO-UNDO. /* Nro Caixa     */
    DEF INPUT  PARAM p-nrautent          AS INT NO-UNDO. /* Autenticacao Nro. */
    DEF OUTPUT PARAM TABLE FOR tt-lancamentos.
      
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    DEF VAR aux_dtlibera AS DATE NO-UNDO.
    
    EMPTY TEMP-TABLE tt-lancamentos.
    
    ASSIGN l-achou-horario-corte = NO
           i-nro-lote = 30000 + p-nro-caixa.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF   p-nrautent = 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Autenticacao deve ser informada.".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */
         RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                                INPUT 0,
                                OUTPUT aux_lscontas).

    ASSIGN l-achou = NO
    /*** Verifica se PAC faz previa dos cheques ***/ 
           flg_exetrunc = FALSE.
    FIND craptab WHERE  craptab.cdcooper = crapcop.cdcooper   AND
                        craptab.nmsistem = "CRED"             AND
                        craptab.tptabela = "GENERI"           AND
                        craptab.cdempres = 0                  AND
                        craptab.cdacesso = "EXETRUNCAGEM"     AND
                        craptab.tpregist = p-cod-agencia    
                        NO-LOCK NO-ERROR.        

    IF  craptab.dstextab = "SIM" THEN
    DO:
       ASSIGN i-cod-erro   = 0
              flg_exetrunc = TRUE.

       FIND craplcx WHERE craplcx.cdcooper = crapcop.cdcooper AND
                          craplcx.dtmvtolt = crapdat.dtmvtolt AND 
                          craplcx.cdagenci = p-cod-agencia    AND 
                          craplcx.nrdcaixa = p-nro-caixa      AND 
                          craplcx.nrautdoc = p-nrautent NO-LOCK NO-ERROR.
       
       IF  NOT AVAILABLE craplcx  THEN
       DO:
           ASSIGN i-cod-erro  = 90
                  c-desc-erro = " ".           
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.

       FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper AND
                              crapchd.dtmvtolt = crapdat.dtmvtolt AND
                              crapchd.cdagenci = p-cod-agencia    AND
                              crapchd.cdbccxlt = 11               AND
                              crapchd.nrdolote = i-nro-lote       AND
                              crapchd.nrdocmto = craplcx.nrdocmto
                              USE-INDEX crapchd3 NO-LOCK:

           IF  crapchd.insitprv > 0 THEN 
           DO:
               ASSIGN i-cod-erro  = 0  
                      c-desc-erro = "Estorno nao pode ser efetuado. " + 
                                    "Cheque ja enviado para previa.".
               RUN cria-erro (INPUT p-cooper,
                              INPUT p-cod-agencia,
                              INPUT p-nro-caixa,
                              INPUT i-cod-erro,
                              INPUT c-desc-erro,
                              INPUT YES).
               RETURN "NOK".
           END.

           CREATE tt-lancamentos.
           ASSIGN tt-lancamentos.tpdocmto = 1
                  tt-lancamentos.dtmvtolt = crapdat.dtmvtolt
                  tt-lancamentos.vllanmto = crapchd.vlcheque
                  l-achou-horario-corte  = YES
                  l-achou = YES.
       END.

    END.
    
    IF   l-achou = NO   THEN 
         DO:
             ASSIGN i-cod-erro  = 90
                    c-desc-erro = " ". 
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper      AND     
                       craplot.dtmvtolt = crapdat.dtmvtolt      AND
                       craplot.cdagenci = p-cod-agencia         AND
                       craplot.cdbccxlt = 11                    AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote           
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplot  THEN  
        DO:
            ASSIGN i-cod-erro  = 60
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  l-achou-horario-corte  = YES   THEN 
        DO:
            /* Verifica horario de Corte */
            FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                               craptab.nmsistem = "CRED"             AND
                               craptab.tptabela = "GENERI"           AND
                               craptab.cdempres = 0                  AND
                               craptab.cdacesso = "HRTRCOMPEL"       AND
                               craptab.tpregist = p-cod-agencia  
                               NO-LOCK NO-ERROR.

            IF   NOT AVAIL craptab   THEN  
                 DO:
                     ASSIGN i-cod-erro  = 676
                            c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".          
                 END.   

            IF   flg_exetrunc = FALSE THEN 
                 IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN 
                      DO:
                          ASSIGN i-cod-erro  = 677
                                 c-desc-erro = " ".           
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                      END.    

            IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN 
                 DO:
                     ASSIGN i-cod-erro  = 676
                            c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END. 
        END.    /* Verifica Horario de Corte */

    RETURN "OK".

END PROCEDURE.

PROCEDURE estorna-lancamento:
    
    DEF INPUT  PARAM p-cooper                AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia           AS INT  NO-UNDO. /* Cod. Agencia  */
    DEF INPUT  PARAM p-nro-caixa             AS INT  NO-UNDO. /* Numero Caixa  */
    DEF INPUT  PARAM p-cod-operador          AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-nrautent              AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdoperad            AS CHAR NO-UNDO.
    DEF INPUT  PARAM par_cddsenha            AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-valor                 AS DEC  NO-UNDO.
    DEF OUTPUT PARAM p-docto                 AS DEC  NO-UNDO.

    DEF VAR flg_vhrcorte AS LOGICAL NO-UNDO.   
    DEF BUFFER crablot   FOR craplot.

    DEF VAR h-b1wgen9998 AS HANDLE NO-UNDO.
    DEF VAR h-b1wgen0000 AS HANDLE NO-UNDO.
                                                     
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 30000 + p-nro-caixa.
  
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    ASSIGN i-cod-erro   = 0
           flg_exetrunc = TRUE.

    RUN valida-autenticacao (INPUT  p-cooper,
                             INPUT  p-cod-agencia,
                             INPUT  p-nro-caixa,
                             INPUT  p-nrautent,
                             OUTPUT TABLE tt-lancamentos).

    IF  RETURN-VALUE <> "OK"  THEN
        RETURN "NOK".

    RUN sistema/generico/procedures/b1wgen0000.p 
                  PERSISTENT SET h-b1wgen0000.

    RUN valida-senha-coordenador IN h-b1wgen0000 (INPUT crapcop.cdcooper,
                                                  INPUT p-cod-agencia,            
                                                  INPUT p-nro-caixa,            
                                                  INPUT p-cod-operador, 
                                                  INPUT "b1crap86", 
                                                  INPUT 2, /* cx online */  
                                                  INPUT 0,  /* conta */
                                                  INPUT 0,  /* se ttl */
                                                  INPUT 2, /* coordenador */
                                                  INPUT par_cdoperad,
                                                  INPUT par_cddsenha,
                                                  INPUT FALSE,       
                                                 OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0000.

    IF  RETURN-VALUE <> "OK"  THEN
    DO:
         FIND FIRST tt-erro NO-ERROR.
         IF   AVAIL tt-erro   THEN
         DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = tt-erro.dscritic.

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
         END.
         ELSE
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Erro ao validar senha de coordenador".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
         END.

         RETURN "NOK".
    END.
        
    
    ASSIGN in99 = 0.
    DO  WHILE TRUE:
        ASSIGN in99 = in99 + 1.

        FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper AND
                           craplot.dtmvtolt = crapdat.dtmvtolt AND
                           craplot.cdagenci = p-cod-agencia    AND
                           craplot.cdbccxlt = 11               AND  /* Fixo */
                           craplot.nrdolote = i-nro-lote 
                           NO-ERROR NO-WAIT.

        IF   NOT AVAIL   craplot   THEN  
             DO:
                 IF   LOCKED craplot   THEN 
                      DO:
                          IF   in99 < 100   THEN 
                               DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT.
                               END.
                          ELSE 
                               DO:
                                   ASSIGN i-cod-erro  = 0
                                        c-desc-erro = "Tabela CRAPLOT em uso ".                                     
                                   RUN cria-erro (INPUT p-cooper,
                                                  INPUT p-cod-agencia,
                                                  INPUT p-nro-caixa,
                                                  INPUT i-cod-erro,
                                                  INPUT c-desc-erro,
                                                  INPUT YES).
                                   RETURN "NOK".
                               END.
                      END.
                 ELSE 
                      DO:
                          ASSIGN i-cod-erro  = 60
                                 c-desc-erro = " ".           
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                      END.
             END.
        LEAVE.
    END.  /*  DO WHILE */

    FIND crapaut WHERE crapaut.cdcooper = crapcop.cdcooper AND
                       crapaut.cdagenci = p-cod-agencia    AND
                       crapaut.nrdcaixa = p-nro-caixa      AND
                       crapaut.dtmvtolt = crapdat.dtmvtolt AND
                       crapaut.nrsequen = p-nrautent
                       NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapaut THEN
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Autenticacao nao encontrada.".
  
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    ELSE
         ASSIGN p-docto = crapaut.nrdocmto.

    ASSIGN in99 = 0.
    DO  WHILE TRUE:
        ASSIGN in99 = in99 + 1.

        FIND craplcx WHERE craplcx.cdcooper = crapcop.cdcooper AND
                           craplcx.dtmvtolt = crapdat.dtmvtolt AND 
                           craplcx.cdagenci = p-cod-agencia    AND 
                           craplcx.nrdcaixa = p-nro-caixa      AND 
                           craplcx.nrautdoc = p-nrautent 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAIL   craplcx   THEN  
             DO:
                 IF   LOCKED craplcx   THEN 
                      DO:
                          IF   in99 < 100   THEN 
                               DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT.
                               END.
                          ELSE 
                               DO:
                                   ASSIGN i-cod-erro  = 0
                                        c-desc-erro = "Tabela CRAPLCX em uso ".                                     
                                   RUN cria-erro (INPUT p-cooper,
                                                  INPUT p-cod-agencia,
                                                  INPUT p-nro-caixa,
                                                  INPUT i-cod-erro,
                                                  INPUT c-desc-erro,
                                                  INPUT YES).
                                   RETURN "NOK".
                               END.
                      END.
                 ELSE 
                      DO:
                          ASSIGN i-cod-erro  = 90
                                 c-desc-erro = " ".           
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                      END.
             END.
        LEAVE.
    END.  /*  DO WHILE */
    
    FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper AND
                           crapchd.dtmvtolt = crapdat.dtmvtolt AND
                           crapchd.cdagenci = p-cod-agencia    AND
                           crapchd.cdbccxlt = 11               AND
                           crapchd.nrdolote = i-nro-lote       AND
                           crapchd.nrdocmto = craplcx.nrdocmto
                           USE-INDEX crapchd3 EXCLUSIVE-LOCK:

        RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.

        RUN atualiza-previa-caixa  IN h_b1crap00  (INPUT crapcop.nmrescop,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT p-cod-operador,
                                                   INPUT crapdat.dtmvtolt,
                                                   INPUT 2).  /*Estorno*/
        DELETE PROCEDURE h_b1crap00.
        
        ASSIGN p-valor = p-valor + crapchd.vlcheque.

        DELETE crapchd.

    END. /* for each crapchd */

    DELETE craplcx.
    
    ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
           craplot.qtinfoln  = craplot.qtinfoln - 1
           craplot.vlcompcr  = craplot.vlcompcr - p-valor
           craplot.vlinfocr  = craplot.vlinfocr - p-valor.
                
    IF  craplot.vlcompdb = 0  AND
        craplot.vlinfodb = 0  AND
        craplot.vlcompcr = 0  AND
        craplot.vlinfocr = 0  THEN
        DELETE craplot.
    ELSE
        RELEASE craplot.
                
    RETURN "OK".

END PROCEDURE.
/* b1crap71.p */
