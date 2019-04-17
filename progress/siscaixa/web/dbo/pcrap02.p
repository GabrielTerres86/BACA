/*----------------------------------------------------------------------*/
/*  pcrap02.p -                                                         */
/*  Verificar se o associado possui Capital                             */
/*  par_nrdconta = Conta do associado em questao                        */
/*  par_vllanmto = Se maior que 0, verifica de pode sacar o valor       */
/*  se for 0, apenas testa se o associado possui                        */    
/*  capital suficiente para efetuar a operacao(antigo ver_capital.p).   */
/*                                                                      */
/*  Alteracoes: 16/11/2005 - Alteracao de crapchq e crapcht p/ crapfdc  */
/*                           (SQLWorks - Eder)                          */
/*              17/11/2005 - Adequacao ao padrao, analise de performance*/
/*                           e dos itens convertidos(SQLWorks - Andre)  */
/*              02/03/2006 - Unifiicao dos Bancos - SQLWorks - Fernando.*/
/*              18/06/2014 - Exclusao do uso da tabela crapcar.
                            (Tiago Castro - Tiago RKAM)                 */
/*----------------------------------------------------------------------*/

DEF INPUT  PARAMETER p-cooper       AS CHAR                            NO-UNDO.
DEF INPUT  PARAMETER p-cod-agencia  AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER p-nro-caixa    AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER p-nro-conta    AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER p-valor-lancto AS DECIMAL                         NO-UNDO.
DEF INPUT  PARAMETER p-dtmvtolt     AS DATE                            NO-UNDO.

{dbo/bo-erro1.i}

DEF  VAR glb_nrcalcul               AS DECIMAL                         NO-UNDO.
DEF  VAR glb_dsdctitg               AS CHAR                            NO-UNDO.
DEF  VAR glb_stsnrcal               AS LOGICAL                         NO-UNDO.

DEFINE VARIABLE i-cod-erro          AS INTEGER                         NO-UNDO.
DEFINE VARIABLE c-desc-erro         AS CHARACTER                       NO-UNDO.

DEFINE VARIABLE d-vlcapmin          AS DECIMAL                         NO-UNDO.
DEFINE VARIABLE d-vldsaldo          AS DECIMAL                         NO-UNDO.
DEFINE VARIABLE i-contador          AS INTEGER                         NO-UNDO.

DEF VAR aux_data                    AS DATE                            NO-UNDO.

FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

/*  Le registro de matricula  */

FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
FIND FIRST crapmat WHERE crapmat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

/*  Le tabela de valor minimo do capital  */

FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                   craptab.nmsistem = "CRED"            AND
                   craptab.tptabela = "USUARI"          AND
                   craptab.cdempres = 11                AND
                   craptab.cdacesso = "VLRUNIDCAP"      AND
                   craptab.tpregist = 1                 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     ASSIGN d-vlcapmin = crapmat.vlcapini.
ELSE
     ASSIGN d-vlcapmin = DECIMAL(craptab.dstextab).

IF   d-vlcapmin < crapmat.vlcapini   THEN
     IF  crapcop.cdcooper <> 6   THEN
         ASSIGN d-vlcapmin = crapmat.vlcapini.

FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                   crapass.nrdconta = p-nro-conta       NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapass   THEN 
     DO:
         ASSIGN i-cod-erro  = 9
                c-desc-erro = " ".           
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT i-cod-erro,
                        INPUT c-desc-erro,
                        INPUT YES).
         RETURN "NOK".
     END.

IF   crapass.inpessoa <> 3   THEN 
     DO:
       
         /*  Le registro de capital  */
    
         FIND crapcot WHERE crapcot.cdcooper = crapcop.cdcooper AND
                            crapcot.nrdconta = p-nro-conta  
                            NO-LOCK NO-ERROR. 
            
         IF   NOT AVAILABLE crapcot   THEN 
              DO:
                  ASSIGN i-cod-erro  = 169
                         c-desc-erro = " ".           
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
              END.
         
         IF   p-valor-lancto = 0   THEN   
              DO:
              /*  Verifica se ha capital suficiente  */
         
                  IF   crapcot.vldcotas < d-vlcapmin   THEN 
                       DO:
                           
                        /*FIND crapadm OF crapcot NO-LOCK NO-ERROR.*/
                          FIND crapadm WHERE 
                               crapadm.cdcooper = crapcop.cdcooper  AND
                               crapadm.nrdconta = crapcot.nrdconta
                               NO-LOCK NO-ERROR.

                           IF   NOT AVAILABLE crapadm   THEN 
                                DO:
                                    IF   crapass.dtdemiss = ?   THEN 
                                         DO:
                            
                                             ASSIGN aux_data = crapdat.dtmvtolt
                                                        - DAY(crapdat.dtmvtolt)
                                                    aux_data = aux_data - 
                                                               DAY(aux_data).
                        
                                             IF   crapass.dtadmiss <= aux_data 
                                                  THEN DO:
                                                      ASSIGN i-cod-erro  = 735
                                                             c-desc-erro = " ".
                                                      RUN cria-erro 
                                                          (INPUT p-cooper,
                                                           INPUT p-cod-agencia,
                                                           INPUT p-nro-caixa,
                                                           INPUT i-cod-erro,
                                                           INPUT c-desc-erro,
                                                           INPUT YES).
                                                      RETURN "NOK".
                                                  END.
                                         END.
                                END.
                       END.
              END.
         ELSE  
              DO: 
                  IF   crapcot.vldcotas <> p-valor-lancto   OR
                       crapass.dtdemiss = ?               THEN 
                       DO:
                           IF  (crapcot.vldcotas - p-valor-lancto) < d-vlcapmin
                               THEN DO:
                                    ASSIGN i-cod-erro  = 630
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
                  RUN ver_saldos. /*Nao permite sacar capital se houver saldos*/
                  IF   RETURN-VALUE = "NOK"   THEN
                       RETURN "NOK".
              END.
     END.
RETURN "OK".
/* .......................................................................... */

PROCEDURE ver_saldos:

    FIND FIRST crapepr WHERE crapepr.cdcooper = crapcop.cdcooper  AND
                             crapepr.nrdconta = p-nro-conta       AND
                             crapepr.inliquid = 0 
                             NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE crapepr   THEN 
         DO:
             ASSIGN i-cod-erro  = 736
                    c-desc-erro = " EMPRESTIMO COM SALDO DEVEDOR.".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
         
    FIND FIRST crappla WHERE crappla.cdcooper = crapcop.cdcooper  AND
                             crappla.nrdconta = p-nro-conta       AND
                             crappla.cdsitpla = 1 
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crappla   THEN 
         DO:
             ASSIGN i-cod-erro  = 736
                    c-desc-erro = " PLANO DE CAPITAL ATIVO.".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    IF   crapass.vllimcre > 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 736
                    c-desc-erro = " LIMITE DE CREDITO EM CONTA-CORRENTE.".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    FIND FIRST crapcrd WHERE crapcrd.cdcooper = crapcop.cdcooper  AND
                             crapcrd.nrdconta = p-nro-conta       AND
                             crapcrd.dtcancel = ?             
                             NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE crapcrd   THEN  
         DO:
             ASSIGN i-cod-erro  = 736
                    c-desc-erro = " CARTAO DE CREDITO ATIVO.".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    FOR EACH craprda WHERE craprda.cdcooper = crapcop.cdcooper  AND
                           craprda.nrdconta = p-nro-conta       AND
                           craprda.insaqtot = 0                 NO-LOCK:
                             
        d-vldsaldo = craprda.vlsdrdca.
        
        FOR EACH craplap WHERE craplap.cdcooper = crapcop.cdcooper   AND
                               craplap.nrdconta = craprda.nrdconta   AND
                               craplap.nraplica = craprda.nraplica   AND
                              (craplap.cdhistor = 118                OR
                               craplap.cdhistor = 178)               
                               USE-INDEX craplap5 NO-LOCK:
                               
            d-vldsaldo = d-vldsaldo - craplap.vllanmto.                   
                               
        END.  /*  Fim do FOR EACH -- Leitura do craplap  */

        IF   d-vldsaldo > 0   THEN  
             DO:
                 FIND FIRST craplrg WHERE 
                            craplrg.cdcooper = crapcop.cdcooper  AND
                            craplrg.dtmvtolt = p-dtmvtolt        AND
                            craplrg.nrdconta = craprda.nrdconta  AND
                            craplrg.nraplica = craprda.nraplica  AND
                            craplrg.dtresgat = p-dtmvtolt        AND
                            craplrg.vllanmto = 0                 AND
                            craplrg.tpaplica = 3                 
                            NO-LOCK NO-ERROR.

                 IF   NOT AVAIL craplrg   THEN 
                      DO:
                          ASSIGN i-cod-erro  = 736                     
                                 c-desc-erro = " SALDO EM APLICACAO RDCA.".
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                      END.
             END.
    
    END.  /*  Fim do FOR EACH -- Leitura do craprda  */
     
    FIND FIRST crapapl WHERE crapapl.cdcooper = crapcop.cdcooper  AND
                             crapapl.nrdconta = p-nro-conta       AND
                             crapapl.inresgat = 0 
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapapl  THEN 
         DO:
             ASSIGN i-cod-erro  = 736
                    c-desc-erro = " SALDO EM APLICACAO RDC.".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    FIND FIRST crapseg WHERE crapseg.cdcooper = crapcop.cdcooper  AND
                             crapseg.nrdconta = p-nro-conta       AND
                             crapseg.dtfimvig > TODAY             AND
                             crapseg.dtcancel = ?           
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapseg   THEN 
         DO:
             ASSIGN i-cod-erro  = 736
                    c-desc-erro = " SEGURO ATIVO.".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    FIND FIRST crapatr WHERE crapatr.cdcooper = crapcop.cdcooper    AND
                             crapatr.nrdconta = p-nro-conta         AND
                             crapatr.dtfimatr = ? 
                             NO-LOCK NO-ERROR.

    IF   AVAILABLE crapatr   THEN 
         DO:
             ASSIGN i-cod-erro  = 736
                    c-desc-erro = " AUTORIZACAO DE DEBITO EM CONTA-CORRENTE.".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    FOR EACH craprpp WHERE craprpp.cdcooper = crapcop.cdcooper  AND
                           craprpp.nrdconta = p-nro-conta       AND
                          (craprpp.vlsdrdpp > 0                 OR
                           craprpp.dtcancel = ?)                NO-LOCK:
        
        ASSIGN d-vldsaldo = craprpp.vlsdrdpp.
        
        FOR EACH craplpp WHERE craplpp.cdcooper = crapcop.cdcooper   AND
                               craplpp.nrdconta = craprpp.nrdconta   AND
                               craplpp.nrctrrpp = craprpp.nrctrrpp   AND
                               craplpp.cdhistor = 158                NO-LOCK:
                               
            ASSIGN d-vldsaldo = d-vldsaldo - craplpp.vllanmto.                   
        END.  /*  Fim do FOR EACH -- Leitura do craplpp  */
         
        IF   d-vldsaldo > 0   THEN 
             DO:
                 ASSIGN i-cod-erro  = 736
                        c-desc-erro = " APLICACAO PROGRAMADA COM SALDO.".
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.

    END.  /*  Fim do FOR EACH -- Leitura do craprpp  */
         
    FOR EACH crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper  AND
                           crapfdc.nrdconta = p-nro-conta       AND
                           crapfdc.dtretchq <> ?                NO-LOCK:
                           
        IF   crapfdc.incheque = 0   THEN  
             DO:
                 IF   crapfdc.tpcheque = 1   THEN   
                      DO:
                          ASSIGN i-cod-erro  = 736
                                 c-desc-erro = " TALAO DE CHEQUES EM USO.".
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                      END.
                 ELSE 
                      DO:
                          ASSIGN i-cod-erro  = 736
                                 c-desc-erro = " TALAO DE CHEQUES TB EM USO.".
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                      END.
             END.
    END.  /*  for each crapfdc */                       

    /*-------------------
    Usado no FOR EACH anterior
    FOR EACH crapfdc WHERE crapfdc.cdcooper  = glb_cdcooper     AND
                           crapfdc.nrdconta  = p-nro-conta      AND
                           crapfdc.dtretchq <> ?                NO-LOCK:
                           
        IF  crapfdc.incheque = 0   THEN  DO:
            ASSIGN i-cod-erro  = 736
                   c-desc-erro = " TALAO DE CHEQUES TB EM USO.".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
                           
    END.  /*  Fim do FOR EACH -- Leitura do crapfdc  */                       
    -------------------*/
    FIND FIRST crapcst WHERE crapcst.cdcooper = crapcop.cdcooper  AND
                             crapcst.nrdconta = p-nro-conta       AND
                             crapcst.dtlibera > p-dtmvtolt        AND
                             crapcst.dtdevolu = ? 
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapcst   THEN  
         DO:
             ASSIGN i-cod-erro  = 736
                    c-desc-erro = " CHEQUES EM CUSTODIA NAO RESGATADOS.".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    FIND FIRST craptit WHERE craptit.cdcooper = crapcop.cdcooper  AND
                             craptit.nrdconta = p-nro-conta       AND
                             craptit.dtdpagto > p-dtmvtolt        AND
                             craptit.dtdevolu = ?             
                             NO-LOCK NO-ERROR.

    IF   AVAIL craptit   THEN 
         DO:
             ASSIGN i-cod-erro  = 736
                    c-desc-erro = " TITULOS PROGRAMADOS NAO RESGATADOS.".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.

/* pcrap02.p */


