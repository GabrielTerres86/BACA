/*.............................................................................
   
   Programa: b1wgen0118.p                  
   Autor(a): Gabriel
   Data    : 29/09/2011                        Ultima atualizacao: 12/06/2018

   Dados referentes ao programa:

   Objetivo  : BO com funcoes da sobre a Transferencia entre Cooperativas.

   Alteracoes: 27/12/2102 - Tratar paginacao na listagem (Gabriel). 
   
               14/03/2013 - Incluir campo de origem (Gabriel). 
   
               12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
               
               27/06/2014 - Adicionado busca por tipo de operacao 5 na busca da
                            crapldt. (Reinert)                            
                            
               04/07/2014 - Incluido historicos para deposito em cheque na 
                            procedure acerto-financeiro. (Reinert)  
                            
               27/10/2014 - Incluído parametro na procedure gera-log (Diego).                          
                                          
               12/06/2018 - P450 - Chamada da rotina para consistir lançamento em conta corrente(LANC0001) 
                            na tabela CRAPLCM  - José Carvalho(AMcom)
                                          
               26/09/2018 - P450 - Correção mensagem de erro no retorno da rotina 0200 - gera lançamento
			                Renato Cordeiro (AMcom)
               
               16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)
............................................................................ */

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/gera_log.i  }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgen0118tt.i }
{ sistema/generico/includes/b1wgen0200tt.i }


DEF VAR aux_cdcritic AS INTE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                         NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                         NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                         NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                        NO-UNDO.

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.


/******************************************************************************
 Procedure utilizada na TRFSAL para transferencia de salario 
******************************************************************************/
PROCEDURE tranf-salario-intercooperativa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_rowidlcs AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cdagetrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR         aux_dadosdeb AS CHAR                           NO-UNDO.
    DEF  VAR         aux_flgtrans AS LOGI                           NO-UNDO.

    DEF  VAR         b1crap22     AS HANDLE                         NO-UNDO.

    DEF BUFFER crablcs FOR craplcs.
    DEF BUFFER crabcop FOR crapcop.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    /**********************************************************************  
     ATENCAO - Nao confundir os Dados do Remetente com os do Destinatario.
    **********************************************************************/

    Transf : DO TRANSACTION ON ERROR  UNDO Transf, LEAVE Transf
                            ON ENDKEY UNDO Transf, LEAVE Transf: 

        /* Lancamento de credito salario */
        FIND craplcs WHERE ROWID (craplcs) = par_rowidlcs NO-LOCK NO-ERROR.

        IF   NOT AVAIL craplcs   THEN
             DO:
                 aux_cdcritic = 90.
                 LEAVE Transf.
             END.

        /* Conta transferencia */
        FIND crapccs WHERE crapccs.cdcooper = par_cdcooper     AND
                           crapccs.nrdconta = craplcs.nrdconta NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapccs   THEN
             DO:
                 ASSIGN aux_cdcritic = 127.
                 LEAVE Transf.
             END.

        /* Cooperativa remetente */
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapcop   THEN
             DO:
                 aux_cdcritic = 651.
                 LEAVE Transf.
             END.

        /* Dados do Remetente */
        ASSIGN aux_dadosdeb =
                     STRING(crapcop.cdagectl,"z,zz9")            + "/" +
                     STRING(crapccs.nrdconta,"zz,zzz,zzz,zzz,9") + "/" +
                     STRING(crapccs.nrcpfcgc,"zzzzzzzzzzzzz9").  

        /* Cooperativa Destino */
        FIND crabcop WHERE crabcop.cdagectl = par_cdagetrf NO-LOCK NO-ERROR.

        IF   NOT AVAIL crabcop   THEN
             DO:
                 aux_dscritic = "Cooperativa de destino nao encontrada.".
                 LEAVE.
             END.

        /* Criar o registro de debito do Salario */ 
        CREATE crablcs.
        BUFFER-COPY craplcs EXCEPT cdhistor TO crablcs.
        ASSIGN crablcs.cdhistor = 1018.
        VALIDATE crablcs.

        /* Lote de lancamento de credito destino */
        FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper   AND 
                           craplot.dtmvtolt = par_dtmvtolt       AND
                           craplot.cdagenci = 1                  AND
                           craplot.cdbccxlt = 85                 AND
                           craplot.nrdolote = 10115
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAIL craplot   THEN
             DO:
                 CREATE craplot.
                 ASSIGN craplot.cdcooper = crabcop.cdcooper
                        craplot.dtmvtolt = par_dtmvtolt
                        craplot.cdagenci = 1 
                        craplot.cdbccxlt = 85
                        craplot.nrdolote = 10115
                        craplot.tplotmov = 1.
                 
             END.

        /* Verificar se ja existe Lancamento */
        FIND craplcm WHERE craplcm.cdcooper = crabcop.cdcooper        AND
                           craplcm.dtmvtolt = craplot.dtmvtolt        AND
                           craplcm.cdagenci = craplot.cdagenci        AND
                           craplcm.cdbccxlt = craplot.cdbccxlt        AND
                           craplcm.nrdolote = craplot.nrdolote        AND
                           craplcm.nrdctabb = INTE(crapccs.nrctatrf)  AND   
                           craplcm.nrdocmto = craplcs.nrdocmto        
                           NO-LOCK NO-ERROR.

        IF   AVAIL craplcm   THEN
             DO:
                 aux_cdcritic = 92.
                 LEAVE Transf.
             END.

        /* BLOCO DA INSERÇAO DA CRAPLCM */
        IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
          RUN sistema/generico/procedures/b1wgen0200.p 
        PERSISTENT SET h-b1wgen0200.
        
        /* Criar o registro de credito do Salario */
        RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
          (INPUT craplot.dtmvtolt               /* par_dtmvtolt */
          ,INPUT craplot.cdagenci               /* par_cdagenci */
          ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
          ,INPUT craplot.nrdolote               /* par_nrdolote */
          ,INPUT crapccs.nrctatrf               /* par_nrdconta */
          ,INPUT craplcs.nrdocmto               /* par_nrdocmto */
          ,INPUT 1022                           /* par_cdhistor */
          ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
          ,INPUT craplcs.vllanmto               /* par_vllanmto */
          ,INPUT crapccs.nrctatrf               /* par_nrdctabb */
          ,INPUT aux_dadosdeb /* Remetente */   /* par_cdpesqbb */
          ,INPUT 0                              /* par_vldoipmf */
          ,INPUT 0                              /* par_nrautdoc */
          ,INPUT 0                              /* par_nrsequni */
          ,INPUT 0                              /* par_cdbanchq */
          ,INPUT 0                              /* par_cdcmpchq */
          ,INPUT 0                              /* par_cdagechq */
          ,INPUT 0                              /* par_nrctachq */
          ,INPUT 0                              /* par_nrlotchq */
          ,INPUT 0                              /* par_sqlotchq */
          ,INPUT ""                             /* par_dtrefere */
          ,INPUT TIME                           /* par_hrtransa */
          ,INPUT par_cdoperad                   /* par_cdoperad */
          ,INPUT ""                             /* par_dsidenti */
          ,INPUT craplot.cdcooper               /* par_cdcooper */
          ,INPUT ""                             /* par_nrdctitg */
          ,INPUT ""                             /* par_dscedent */
          ,INPUT par_cdcooper                   /* par_cdcoptfn */
          ,INPUT 0                              /* par_cdagetfn */
          ,INPUT 0                              /* par_nrterfin */
          ,INPUT 0                              /* par_nrparepr */
          ,INPUT 0                              /* par_nrseqava */
          ,INPUT 0                              /* par_nraplica */
          ,INPUT 0                              /* par_cdorigem */
          ,INPUT 0                              /* par_idlautom */
          /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
          ,INPUT 0                              /* Processa lote                                 */
          ,INPUT 0                              /* Tipo de lote a movimentar                     */
          /* CAMPOS DE SAÍDA                                                                     */                                            
          ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
          ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
          ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
          ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */
          
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
           DO:  
             LEAVE Transf.
           END.   
        ELSE 
           DO:
             /* 19/06/2018- TJ - Posicionando no registro da craplcm criado acima */
             FIND FIRST tt-ret-lancto.
             FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
           END.
          
        IF  VALID-HANDLE(h-b1wgen0200) THEN
            DELETE PROCEDURE h-b1wgen0200.

        ASSIGN craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto
               craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
              
               craplot.nrseqdig = craplot.nrseqdig + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.qtinfoln = craplot.qtinfoln + 1.
        VALIDATE craplot.
                            
        RUN sistema/siscaixa/web/dbo/b1crap22.p PERSISTENT SET b1crap22.
            
        /* Criar o crapldt */
        RUN gera-log IN b1crap22 (INPUT crapcop.nmrescop, /* Remetente */
                                  INPUT crapccs.cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT crabcop.nmrescop, /* Destino */
                                  INPUT crapccs.nrdconta, /* conta de */ 
                                  INPUT crapccs.nrctatrf, /* conta para */
                                  INPUT 3,                /* Tec Salario */
                                  INPUT craplcm.vllanmto,
                                  INPUT craplcm.nrdocmto,
                                  INPUT 0).
           
        DELETE PROCEDURE b1crap22.

        ASSIGN aux_flgtrans = TRUE.
        
    END.

    IF   NOT aux_flgtrans  THEN
         DO:
             IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".                      
         END.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Procedure para valores parametrizados na TRFCOP. 
*****************************************************************************/  
PROCEDURE busca-parametro:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_vlaprcoo AS DECI                           NO-UNDO.

    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.


    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
          
        FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "GENERI"       AND
                           craptab.cdempres = 0              AND
                           craptab.cdacesso = "VLRTRFCOOP"   AND
                           craptab.tpregist = 1              NO-LOCK NO-ERROR.

       ASSIGN par_vlaprcoo = DECI (craptab.dstextab) WHEN AVAIL craptab. 

       ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans    THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".  
         END.
         
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Alterar os parametros da TRFCOP.
*****************************************************************************/
PROCEDURE altera-parametro:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlaprcoo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador          AS INTE                           NO-UNDO.
    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    Altera: DO TRANSACTION ON ERROR  UNDO Altera, LEAVE Altera
                           ON ENDKEY UNDO Altera, LEAVE Altera: 

        DO aux_contador = 1 TO 10:
        
           FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                              craptab.nmsistem = "CRED"         AND
                              craptab.tptabela = "GENERI"       AND
                              craptab.cdempres = 0              AND
                              craptab.cdacesso = "VLRTRFCOOP"   AND
                              craptab.tpregist = 1              
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
           
           IF   NOT AVAIL craptab   THEN
                IF   LOCKED craptab   THEN
                     DO:
                         aux_cdcritic = 77.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         CREATE craptab.
                         ASSIGN craptab.cdcooper = par_cdcooper
                                craptab.nmsistem = "CRED"
                                craptab.tptabela = "GENERI"
                                craptab.cdempres = 0
                                craptab.cdacesso = "VLRTRFCOOP"
                                craptab.tpregist = 1.
                         VALIDATE craptab.
                     END.

           ASSIGN aux_cdcritic = 0.
           LEAVE.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO Altera, LEAVE Altera.

        ASSIGN craptab.dstextab = STRING(par_vlaprcoo,"zzz,zzz,zz9.99"). 

        ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans    THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".  
         END.
         
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Buscar as operacoes (Transferencia/Deposito) para a TRFCOP.
*****************************************************************************/
PROCEDURE busca-operacoes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dttransa AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpoperac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdenvio AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdpacrem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO. 
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapldt.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgtrans AS LOGI                                   NO-UNDO.
    DEF  VAR aux_nrregist AS INTE                                   NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nrregist = par_nrregist.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapldt.

    Operacoes: DO ON ERROR UNDO Operacoes, LEAVE Operacoes:

        /* Cooperativa */
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapcop   THEN
             DO:
                 aux_cdcritic = 651.
                 LEAVE Operacoes.
             END.

        IF   par_tpdenvio = 1   THEN /* Recebimento */
             DO:
                 FOR EACH crapldt WHERE crapldt.cdagedst = crapcop.cdagectl   AND
                                   ( IF   par_tpoperac = 1    THEN
                                        crapldt.tpoperac = par_tpoperac OR
                                        crapldt.tpoperac = 5
                                     ELSE
                                        crapldt.tpoperac = par_tpoperac)      AND

                                   ( IF   par_dttransa <> ?   THEN  
                                          crapldt.dttransa = par_dttransa
                                     ELSE 
                                          TRUE) NO-LOCK:

                     IF    par_cdpacrem <> 0   THEN
                           DO:
                               IF   CAN-DO("90,91",STRING(par_cdpacrem))   THEN
                                    IF    crapldt.cdpacrem <> par_cdpacrem   THEN
                                           NEXT.
                                    ELSE  
                                           .
                               ELSE
                               IF   CAN-DO("90,91",STRING(crapldt.cdpacrem))  THEN
                                    NEXT.
                           END.

                     ASSIGN par_qtregist = par_qtregist + 1.

                     /* controles da paginação */
                     IF  par_qtregist < par_nriniseq  OR
                         par_qtregist >= (par_nriniseq + par_nrregist) THEN
                         NEXT.

                     IF   aux_nrregist > 0 THEN
                          RUN busca-nformacoes-operacoes.

                     ASSIGN aux_nrregist = aux_nrregist - 1.

                 END.
             END.
        ELSE
        IF   par_tpdenvio = 2   THEN /* Envio */
             DO:
                 FOR EACH crapldt WHERE crapldt.cdcooper = par_cdcooper       AND   
                                        crapldt.cdagerem = crapcop.cdagectl   AND
                                    ( IF   par_tpoperac = 1    THEN
                                        crapldt.tpoperac = par_tpoperac OR
                                        crapldt.tpoperac = 5
                                     ELSE
                                        crapldt.tpoperac = par_tpoperac)      AND
                            
                                   ( IF   par_dttransa <> ?   THEN  
                                          crapldt.dttransa = par_dttransa
                                     ELSE 
                                          TRUE) NO-LOCK:

                     IF    par_cdpacrem <> 0   THEN
                           DO:
                               IF   CAN-DO("90,91",STRING(par_cdpacrem))   THEN
                                    IF    crapldt.cdpacrem <> par_cdpacrem   THEN
                                           NEXT.
                                    ELSE  
                                           .
                               ELSE
                               IF   CAN-DO("90,91",STRING(crapldt.cdpacrem))  THEN
                                    NEXT.
                           END.

                     ASSIGN par_qtregist = par_qtregist + 1.
                     
                     /* controles da paginação */
                     IF   par_qtregist < par_nriniseq  OR
                          par_qtregist >= (par_nriniseq + par_nrregist) THEN
                          NEXT.

                     IF   aux_nrregist > 0 THEN
                          RUN busca-nformacoes-operacoes.

                     ASSIGN aux_nrregist = aux_nrregist - 1.

                 END.
             END.

        ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans    THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".  
         END.

    RETURN "OK".

END PROCEDURE.

/****************************************************************************
 Cobrar e creditar a tarifa do deposito Intercooperativa. (crps609)
****************************************************************************/  
PROCEDURE deposito-tarifa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagedst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllanmto AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF  VAR         aux_flgtrans AS LOGI                           NO-UNDO.

    DEF  BUFFER crabcop FOR crapcop.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    EMPTY TEMP-TABLE tt-erro.
    

          /************************************************************
              ATECAO - com os CDCOOPER (Destino ou Remetente)
          ************************************************************/
    Deposito: DO TRANSACTION ON ERROR  UNDO Deposito, LEAVE Deposito
                             ON ENDKEY UNDO Deposito, LEAVE Deposito: 

        /* Coperativa Remetente */
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
        IF   NOT AVAIL crapcop    THEN
             DO:
                 aux_cdcritic = 651.
                 UNDO, LEAVE Deposito.
             END.

        /* Cooperativa Destino */
        FIND crabcop WHERE crabcop.cdagectl = par_cdagedst NO-LOCK NO-ERROR.

        IF   NOT AVAIL crabcop    THEN
             DO:
                 aux_cdcritic = 651.
                 UNDO, LEAVE Deposito.
             END.

        /* Lancamento da cooperativa Remetente (Credito) */
        RUN cria-lancamento (INPUT 3,
                             INPUT par_dtmvtolt,
                             INPUT 1,     /* Agencia */
                             INPUT 85,    /* Banco */  
                             INPUT 7104,  /* Lote*/    
                             INPUT 1008,   /* Historico */
                             INPUT par_vllanmto,
                             INPUT crapcop.nrctactl, /* Conta remetente */
                             INPUT crabcop.nrctactl, /* Conta destino   */
                             INPUT par_cdoperad).

        IF    RETURN-VALUE <> "OK"   THEN
              UNDO, LEAVE Deposito.

        /* Lancamento cooperativa Destino (Debito) */
        RUN cria-lancamento (INPUT 3,
                             INPUT par_dtmvtolt,
                             INPUT 1,    /* Agencia */
                             INPUT 85,   /* Banco */
                             INPUT 7104, /* Lote*/
                             INPUT 1007,  /* Historico */
                             INPUT par_vllanmto, /* Valor */
                             INPUT crabcop.nrctactl, /* Conta Destino */
                             INPUT crapcop.nrctactl, /* Conta remetente */
                             INPUT par_cdoperad).

        IF    RETURN-VALUE <> "OK"   THEN
              UNDO, LEAVE Deposito.

        ASSIGN aux_flgtrans = TRUE.

    END.
        
    IF   NOT aux_flgtrans    THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".  
         END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Efetuar o acerto entre as cooperativas sobre depósito, transferência e 
 transferência de TEC salário.
******************************************************************************/
PROCEDURE acerto-financeiro:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpoperac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagedst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllanmto AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR         aux_cdhiscre AS INTE                           NO-UNDO.
    DEF  VAR         aux_cdhisdeb AS INTE                           NO-UNDO.
    DEF  VAR         aux_flgtrans AS LOGI                           NO-UNDO.


    DEF  BUFFER crabcop FOR crapcop.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    EMPTY TEMP-TABLE tt-erro.
    
              /****************************************************** 
                  ATECAO - com os CDCOOPER (Destino ou Remetente) 
              ******************************************************/              
    Acerto: DO TRANSACTION ON ERROR  UNDO Acerto, LEAVE Acerto
                           ON ENDKEY UNDO Acerto, LEAVE Acerto: 

        /* Coperativa Remetente */
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
        IF   NOT AVAIL crapcop    THEN
             DO:
                 aux_cdcritic = 651.
                 UNDO, LEAVE Acerto.
             END.

        /* Cooperativa Destino */
        FIND crabcop WHERE crabcop.cdagectl = par_cdagedst NO-LOCK NO-ERROR.

        IF   NOT AVAIL crabcop    THEN
             DO:
                 aux_cdcritic = 651.
                 UNDO, LEAVE Acerto.
             END.

        IF   par_tpoperac = 1   THEN  /* Deposito */
             ASSIGN aux_cdhiscre = 1006
                    aux_cdhisdeb = 1005.
        ELSE
        IF   par_tpoperac = 2   THEN /* Transferenca */
             ASSIGN aux_cdhiscre = 1013
                    aux_cdhisdeb = 1012.
        ELSE
        IF    par_tpoperac = 3   THEN /* TEC Salario */
              ASSIGN aux_cdhiscre = 1021
                     aux_cdhisdeb = 1020.
        ELSE
        IF    par_tpoperac = 5   THEN /* Deposito em CHEQUE */
              ASSIGN aux_cdhiscre = 1527
                     aux_cdhisdeb = 1525.
        
        /* Lancamento da cooperativa Remetente (Debito) */
        RUN cria-lancamento (INPUT 3,
                             INPUT par_dtmvtolt,
                             INPUT 1,     /* Agencia */
                             INPUT 85,    /* Banco */  
                             INPUT 7104,  /* Lote*/    
                             INPUT aux_cdhisdeb,   /* Historico */
                             INPUT par_vllanmto,
                             INPUT crapcop.nrctactl, /* Conta remetente */
                             INPUT crabcop.nrctactl, /* Conta destino   */
                             INPUT par_cdoperad).

        IF    RETURN-VALUE <> "OK"   THEN
              UNDO, LEAVE Acerto.

        /* Lancamento cooperativa Destino (Credito) */
        RUN cria-lancamento (INPUT 3,
                             INPUT par_dtmvtolt,
                             INPUT 1,    /* Agencia */
                             INPUT 85,   /* Banco */
                             INPUT 7104, /* Lote*/
                             INPUT aux_cdhiscre,  /* Historico */
                             INPUT par_vllanmto, /* Valor */
                             INPUT crabcop.nrctactl, /* Conta Destino */
                             INPUT crapcop.nrctactl, /* Conta remetente */
                             INPUT par_cdoperad).

        IF    RETURN-VALUE <> "OK"   THEN
              UNDO, LEAVE Acerto.

        ASSIGN aux_flgtrans = TRUE.

    END.
        
    IF   NOT aux_flgtrans    THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".  
         END.

    RETURN "OK".

END PROCEDURE.


/**************************** PROCEDURES INTERNAS ****************************/

PROCEDURE cria-lancamento:
                        
    DEF INPUT PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI                        NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                        NO-UNDO.

    DEF VAR aux_contador AS INTE                                NO-UNDO.
    DEF VAR aux_nrdocmto AS INTE                                NO-UNDO.
    DEF VAR aux_indebcre AS CHAR                                NO-UNDO.


    aux_nrdocmto = INT(STRING(par_nrdocmto) + STRING("001")).

    DO aux_contador = 1 TO 10:
    
       FIND craplot WHERE craplot.cdcooper = par_cdcooper    AND
                          craplot.dtmvtolt = par_dtmvtolt    AND
                          craplot.cdagenci = par_cdagenci    AND
                          craplot.cdbccxlt = par_cdbccxlt    AND
                          craplot.nrdolote = par_nrdolote
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAIL craplot   THEN
            IF   LOCKED craplot   THEN
                 DO:
                      aux_cdcritic = 84.  
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                 END.
            ELSE
                 DO:
                     CREATE craplot.
                     ASSIGN craplot.cdcooper = par_cdcooper
                            craplot.dtmvtolt = par_dtmvtolt
                            craplot.cdagenci = par_cdagenci           
                            craplot.cdbccxlt = par_cdbccxlt          
                            craplot.nrdolote = par_nrdolote
                            craplot.tplotmov = 1
                            craplot.cdoperad = par_cdoperad.
                 END.

       ASSIGN aux_cdcritic = 0.
       LEAVE.

    END.

    IF   aux_cdcritic <> 0   THEN
         RETURN "NOK". 

    DO WHILE TRUE:

        FIND craplcm WHERE craplcm.cdcooper = par_cdcooper      AND
                           craplcm.dtmvtolt = craplot.dtmvtolt  AND
                           craplcm.cdagenci = craplot.cdagenci  AND
                           craplcm.cdbccxlt = craplot.cdbccxlt  AND
                           craplcm.nrdolote = craplot.nrdolote  AND
                           craplcm.nrdctabb = par_nrdconta      AND  
                           craplcm.nrdocmto = aux_nrdocmto
                           USE-INDEX craplcm1 NO-LOCK NO-ERROR.
        
        IF   AVAILABLE craplcm THEN
             aux_nrdocmto = (aux_nrdocmto + 1).
        ELSE
             LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    /* BLOCO DA INSERÇAO DA CRAPLCM */
    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
        RUN sistema/generico/procedures/b1wgen0200.p 
        PERSISTENT SET h-b1wgen0200.
    
    IF  DYNAMIC-FUNCTION("PodeDebitar" IN h-b1wgen0200, 
                                       INPUT par_cdcooper, 
                                       INPUT par_nrdconta,
                                       INPUT par_cdhistor) THEN
               DO:
                 RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                 (INPUT craplot.dtmvtolt               /* par_dtmvtolt */
                 ,INPUT craplot.cdagenci               /* par_cdagenci */
                 ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
                 ,INPUT craplot.nrdolote               /* par_nrdolote */
                 ,INPUT par_nrdconta                   /* par_nrdconta */
                 ,INPUT aux_nrdocmto                   /* par_nrdocmto */
                 ,INPUT par_cdhistor                   /* par_cdhistor */
                 ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                 ,INPUT par_vllanmto                   /* par_vllanmto */
                 ,INPUT par_nrdconta                   /* par_nrdctabb */
                 ,INPUT ""                             /* par_cdpesqbb */
                 ,INPUT 0                              /* par_vldoipmf */
                 ,INPUT 0                              /* par_nrautdoc */
                 ,INPUT 0                              /* par_nrsequni */
                 ,INPUT 0                              /* par_cdbanchq */
                 ,INPUT 0                              /* par_cdcmpchq */
                 ,INPUT 0                              /* par_cdagechq */
                 ,INPUT 0                              /* par_nrctachq */
                 ,INPUT 0                              /* par_nrlotchq */
                 ,INPUT 0                              /* par_sqlotchq */
                 ,INPUT craplot.dtmvtolt               /* par_dtrefere */
                 ,INPUT ""                             /* par_hrtransa */
                 ,INPUT ""                             /* par_cdoperad */
                 ,INPUT ""                             /* par_dsidenti */
                 ,INPUT par_cdcooper                   /* par_cdcooper */
                 ,INPUT ""                             /* par_nrdctitg */
                 ,INPUT ""                             /* par_dscedent */
                 ,INPUT 0                              /* par_cdcoptfn */
                 ,INPUT 0                              /* par_cdagetfn */
                 ,INPUT 0                              /* par_nrterfin */
                 ,INPUT 0                              /* par_nrparepr */
                 ,INPUT 0                              /* par_nrseqava */
                 ,INPUT 0                              /* par_nraplica */
                 ,INPUT 0                              /* par_cdorigem */
                 ,INPUT 0                              /* par_idlautom */
                 /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
                 ,INPUT 0                              /* Processa lote                                 */
                 ,INPUT 0                              /* Tipo de lote a movimentar                     */
                 /* CAMPOS DE SAÍDA                                                                     */                                            
                 ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
                 ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
                 ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
                 ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */

                 IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                    DO:  
                       RETURN "NOK".
                    END.
                 ELSE 
                    DO:
                       /* 19/06/2018- TJ - Posicionando no registro da craplcm criado acima */
                       FIND FIRST tt-ret-lancto.
                       FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                    END.
               
               
               IF  VALID-HANDLE(h-b1wgen0200) THEN
                   DELETE PROCEDURE h-b1wgen0200.
      
    ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.nrseqdig = craplcm.nrseqdig.

    FIND FIRST craphis WHERE craphis.cdcooper = par_cdcooper  AND
                             craphis.cdhistor = par_cdhistor  NO-LOCK NO-ERROR.
   
    IF  AVAIL craphis THEN
        aux_indebcre = craphis.indebcre.
                                                      
    IF  aux_indebcre = "C" THEN
        ASSIGN craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
               craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.
    ELSE
        ASSIGN craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
               craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
    
    VALIDATE craplot.
      
    RETURN "OK".
        END.
    ELSE
      RETURN "NOK".

END PROCEDURE.


PROCEDURE busca-nformacoes-operacoes:

    DEF BUFFER crabcop FOR crapcop.


    CREATE tt-crapldt.
    ASSIGN tt-crapldt.dstransa = STRING(crapldt.hrtransa,"HH:MM:SS")
           tt-crapldt.vllanmto = crapldt.vllanmto
           tt-crapldt.cdpacrem = crapldt.cdpacrem.

    /* Cooperativa remetente */
    FIND crabcop WHERE crabcop.cdagectl = crapldt.cdagerem NO-LOCK NO-ERROR.

    IF   AVAIL crabcop   THEN
         DO:
                  /* Conta Remetente */
             IF   crapldt.nrctarem <> 0 THEN
                  FIND crapass WHERE crapass.cdcooper = crabcop.cdcooper   AND
                                     crapass.nrdconta = crapldt.nrctarem 
                                     NO-LOCK NO-ERROR.
            
             IF   AVAIL crapass   THEN
                  ASSIGN tt-crapldt.nrctarem = crapass.nrdconta
                         tt-crapldt.nmprirem = crapass.nmprimtl
                         tt-crapldt.nrcpfrem = crapass.nrcpfcgc
                         tt-crapldt.inpesrem = crapass.inpessoa.

             ASSIGN tt-crapldt.cdagerem = crabcop.cdagectl
                    tt-crapldt.dsagerem = crabcop.nmrescop.
         END.
        
    /* Cooperativa Destino */
    FIND crabcop WHERE crabcop.cdagectl = crapldt.cdagedst NO-LOCK NO-ERROR.

    IF   AVAIL crabcop   THEN
         DO:
             IF   crapldt.nrctadst <> 0  THEN
                  FIND crapass WHERE crapass.cdcooper = crabcop.cdcooper   AND
                                     crapass.nrdconta = crapldt.nrctadst   
                                     NO-LOCK NO-ERROR.
              
             IF   AVAIL crapass   THEN
                  ASSIGN tt-crapldt.nrctadst = crapass.nrdconta
                         tt-crapldt.nmpridst = crapass.nmprimtl
                         tt-crapldt.nrcpfdst = crapass.nrcpfcgc
                         tt-crapldt.inpesdst = crapass.inpessoa.

             ASSIGN tt-crapldt.cdagedst = crabcop.cdagectl
                    tt-crapldt.dsagedst = crabcop.nmrescop.
         END.

    IF   AVAIL crapass THEN
         RELEASE crapass.
            
    IF   tt-crapldt.cdpacrem = 90   THEN
         ASSIGN tt-crapldt.dspacrem = "Internet".
    ELSE
    IF   tt-crapldt.cdpacrem = 91   THEN
         ASSIGN tt-crapldt.dspacrem = "TAA".
    ELSE
         ASSIGN tt-crapldt.dspacrem = "Caixa On-Line".

END PROCEDURE.

/* ......................................................................... */
