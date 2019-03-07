/*.............................................................................

    Programa  : sistema/generico/procedures/b1wgen0078.p
    Autor     : David/Gabriel
    Data      : Marco/2011                   Ultima Atualizacao: 26/05/2018
    
    Dados referentes ao programa:

    Objetivo  : BO de rotinas DDA (Debito Direto Autorizado).
                - Tela CONTAS (Rotina DDA).
                - Tela LOGDDA

    Alteracoes:  25/07/2011 - Ajuste para colocar a CX Postal no endereco da 
                              cooperativa.
                              Substituicao do campo nrlivdda para idlivdda 
                              na crapcop. (Gabriel)  

                 01/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                              Cedente por Beneficiário e  Sacado por Pagador 
                              Chamado 229313 (Jean Reddiga - RKAM).    

				25/10/2017 -  Ajustado para especificar adesão de DDA pelo Mobile
							  PRJ356.4 - DDA (Ricardo Linhares)  							    

				         14/03/2018 -  Ajuste para buscar a descricao do tipo de conta do oracle. 
                               PRJ366 (Lombardi)

				26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

                16/02/2019 - Ajuste variável aux_nrrecid para DECI - Paulo Martins - Mouts


.............................................................................*/


/*................................ DEFINICOES ...............................*/


{ sistema/generico/includes/b1wgen0078tt.i }
{ sistema/generico/includes/b1wgen0079tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i  }

DEF STREAM str_1. /* Lista erros DDA */
DEF STREAM str_2. /* Termo de adesao / Exclusao / Titulos */

DEF VAR aux_nmarqlog AS CHAR                                          NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                          NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                          NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                          NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                          NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                         NO-UNDO.
DEF VAR aux_dsmesref AS CHAR                                          NO-UNDO.


/*............................ PROCEDURES EXTERNAS ..........................*/


/*****************************************************************************/
/**      Procedure para consultar lista de erros que ocorreram no JDDDA     **/
/*****************************************************************************/
PROCEDURE lista-erros-dda:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtlog AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nritmini AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nritmfin AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qterrdda AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-logdda.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dslinlog AS CHAR                                    NO-UNDO.
    DEF VAR aux_idseqlog AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-logdda. 
    EMPTY TEMP-TABLE tt-erro. 
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    ASSIGN aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + "/log/" +
                          "JDDDA_LogErros_" + STRING(par_dtmvtlog,"99999999") +
                          ".log"
           par_qterrdda = 0
           aux_idseqlog = 0.

    IF  SEARCH(aux_nmarqlog) = ?  THEN
        RETURN "OK".
        
    INPUT STREAM str_1 FROM VALUE(aux_nmarqlog).

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_1 UNFORMATTED aux_dslinlog.

        ASSIGN par_qterrdda = par_qterrdda + 1.

        IF  par_nritmini > 0             AND 
            par_nritmfin > 0             AND 
           (par_qterrdda < par_nritmini  OR
            par_qterrdda > par_nritmfin) THEN
            NEXT.

        ASSIGN aux_idseqlog = aux_idseqlog + 1.

        CREATE tt-logdda.
        ASSIGN tt-logdda.idseqlog = aux_idseqlog
               tt-logdda.dttransa = DATE(INTE(SUBSTR(aux_dslinlog,
                                                     4,2)),
                                         INTE(SUBSTR(aux_dslinlog,
                                                     1,2)),
                                         INTE(SUBSTR(aux_dslinlog,
                                                     7,4)))
               tt-logdda.hrtransa = SUBSTR(aux_dslinlog,12,8)
               tt-logdda.hrtraint = ((INTE(SUBSTR(tt-logdda.hrtransa,
                                                  1,2)) * 3600) +
                                     (INTE(SUBSTR(tt-logdda.hrtransa,
                                                  4,2)) * 60) +
                                      INTE(SUBSTR(tt-logdda.hrtransa,7,2))) 
               tt-logdda.nrdconta = INTE(REPLACE(SUBSTR(aux_dslinlog,
                                          25,10),".",""))
               tt-logdda.nmprimtl = TRIM(SUBSTR(aux_dslinlog,38,50))
               tt-logdda.dscpfcgc = TRIM(SUBSTR(aux_dslinlog,91,18))
               tt-logdda.nmmetodo = TRIM(SUBSTR(aux_dslinlog,112,40))
               tt-logdda.cdderror = TRIM(SUBSTR(aux_dslinlog,155,30))
               tt-logdda.dsderror = TRIM(SUBSTR(aux_dslinlog,188))
               tt-logdda.dsreserr = IF tt-logdda.cdderror MATCHES "*SOAP-ENV*"  
                                    THEN SUBSTR(tt-logdda.cdderror,1,23)
                                    ELSE SUBSTR(tt-logdda.dsderror,1,23).

    END. /** Fim do DO WHILE TRUE **/

    INPUT STREAM str_1 CLOSE.

    RETURN "OK".

END PROCEDURE.


/****************************************************************************
 Procedure que mostra os dados do sacado eletronico. Rotina de DDA na CONTAS
*****************************************************************************/
PROCEDURE consulta-sacado-eletronico:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-sacado-eletronico.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR h-b1wgen0079 AS HANDLE                                  NO-UNDO.


    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Carregar os dados do pagador eletronico".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-sacado-eletronico.

    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta   
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE.
             END.

        CREATE tt-sacado-eletronico.
               
        IF   crapass.inpessoa = 1   THEN
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                    crapttl.nrdconta = par_nrdconta   AND
                                    crapttl.idseqttl = par_idseqttl
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAIL crapttl   THEN
                      DO:
                          ASSIGN aux_dscritic = "Titular nao cadastrado.".
                          LEAVE.
                      END.

                 ASSIGN tt-sacado-eletronico.nmextttl = crapttl.nmextttl
                        tt-sacado-eletronico.inpessoa = 1
                        tt-sacado-eletronico.dspessoa = "1 - FISICA"
                        tt-sacado-eletronico.nrcpfcgc = crapttl.nrcpfcgc.
                        tt-sacado-eletronico.dscpfcgc =  
                            STRING(STRING(crapttl.nrcpfcgc,
                                   "99999999999"),"xxx.xxx.xxx-xx").
             END.
        ELSE
             DO:
                 ASSIGN tt-sacado-eletronico.nmextttl = crapass.nmprimtl
                        tt-sacado-eletronico.inpessoa = 2
                        tt-sacado-eletronico.dspessoa = "2 - JURIDICA"
                        tt-sacado-eletronico.nrcpfcgc = crapass.nrcpfcgc
                        tt-sacado-eletronico.dscpfcgc = 
                            STRING(STRING(crapass.nrcpfcgc,
                                   "99999999999999"),"xx.xxx.xxx/xxxx-xx").
             END.

        RUN sistema/generico/procedures/b1wgen0079.p 
            PERSISTENT SET h-b1wgen0079.

        RUN requisicao-consulta-situacao IN h-b1wgen0079 
                                         (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          INPUT FALSE,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-consulta-situacao).
        DELETE PROCEDURE h-b1wgen0079.

        IF   RETURN-VALUE <> "OK"   THEN
             LEAVE.
        
        FIND FIRST tt-consulta-situacao NO-LOCK NO-ERROR.

        IF   NOT AVAIL tt-consulta-situacao   THEN
             DO:
                 ASSIGN tt-sacado-eletronico.btnaderi = (crapass.dtdemiss = ?).
                        aux_flgtrans = TRUE.
                 LEAVE.
             END.
                  
        BUFFER-COPY tt-consulta-situacao TO tt-sacado-eletronico.

        RUN situacao-cad-dda (INPUT tt-sacado-eletronico.cdsituac,
                             OUTPUT tt-sacado-eletronico.dssituac).

        /* Botao de Consulta */
        IF   CAN-DO("1,2,4,12,13,15",STRING(tt-sacado-eletronico.cdsituac))  THEN
             ASSIGN tt-sacado-eletronico.btnconsu = TRUE.

        /* Botao de Inclusao */
        IF   CAN-DO("0,3,5,17",STRING(tt-sacado-eletronico.cdsituac))  AND
             crapass.dtdemiss = ?                                      THEN
             ASSIGN tt-sacado-eletronico.btnaderi = TRUE.

        /* Botao de Excluir */
        IF   CAN-DO("6,14,16",STRING(tt-sacado-eletronico.cdsituac))   THEN
             ASSIGN tt-sacado-eletronico.btnexclu = TRUE.

        ASSIGN aux_flgtrans = TRUE.

        LEAVE.

    END.

    IF   NOT aux_flgtrans   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro   THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
             ELSE
                  ASSIGN aux_dscritic = tt-erro.dscritic.

             IF   par_flgerlog   THEN 
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).
             RETURN "NOK".
         END.

    IF   par_flgerlog  THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Incluir o titular da conta como sacado eletronico.
*****************************************************************************/
PROCEDURE aderir-sacado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flmobile AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.                             

    DEF  VAR         aux_contador AS INTE                           NO-UNDO.
    DEF  VAR         aux_flgtrans AS LOGI                           NO-UNDO.
    DEF  VAR         h-b1wgen0079 AS HANDLE                         NO-UNDO.


    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                /* Caso seja efetuada alguma alteracao na descricao deste log,
              devera ser tratado o relatorio de "demonstrativo produtos por
              colaborador" da tela CONGPR. (Fabricio - 04/05/2012) */
                aux_dstransa = "Efetuar a inclusao do titular no DDA.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:
                
        RUN sistema/generico/procedures/b1wgen0079.p 
            PERSISTENT SET h-b1wgen0079.
                                   
        RUN requisicao-incluir-sacado IN h-b1wgen0079 (INPUT par_cdcooper,
                                                       INPUT par_cdagenci,
                                                       INPUT par_nrdcaixa,
                                                       INPUT par_cdoperad,
                                                       INPUT par_nmdatela,
                                                       INPUT par_idorigem,
                                                       INPUT par_nrdconta,
                                                       INPUT par_idseqttl,
                                                       INPUT par_flgerlog,
                                                      OUTPUT TABLE tt-erro).                                                
        DELETE PROCEDURE h-b1wgen0079.        

        IF   RETURN-VALUE <> "OK"   THEN
             LEAVE.         
            
        ASSIGN aux_flgtrans = TRUE.
              
        LEAVE.

    END.

    IF   NOT aux_flgtrans   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro   THEN
                  ASSIGN aux_dscritic = "Erro na inclusao do pagador.".
             ELSE
                  ASSIGN aux_dscritic = tt-erro.dscritic.
          
             IF   par_flgerlog   THEN 
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).
             RETURN "NOK".        
         END.

    IF   par_flgerlog  THEN DO:
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).
      END.

	RUN gravar-log-adesao (INPUT par_cdcooper,
                        INPUT par_nmdatela,
                        INPUT par_cdoperad,
                        INPUT par_nrdconta,
                        INPUT par_idseqttl,
                        INPUT par_flmobile).



    RETURN "OK".

END PROCEDURE.

PROCEDURE gravar-log-adesao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flmobile AS INTE                           NO-UNDO.
    DEF VAR aux_nrrecid   AS DECI                                   NO-UNDO.

    /* Gerar log(CRAPLGM) - Rotina Oracle */
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
      RUN STORED-PROCEDURE pc_gera_log_prog
        aux_handproc = PROC-HANDLE NO-ERROR
        (INPUT par_cdcooper    /* pr_cdcooper */
        ,INPUT par_cdoperad    /* pr_cdoperad */
        ,INPUT ""               /* pr_dscritic */
        ,INPUT "INTERNET"      /* pr_dsorigem */
        ,INPUT "Efetuar a inclusao do titular no DDA."    /* pr_dstransa */
        ,INPUT TODAY    /* pr_dttransa */
        ,INPUT 1        /* Operacao sem sucesso */ /* pr_flgtrans */
        ,INPUT TIME            /* pr_hrtransa */
        ,INPUT par_idseqttl    /* pr_idseqttl */
        ,INPUT "INTERNETBANK"  /* pr_nmdatela */
        ,INPUT par_nrdconta    /* pr_nrdconta */
        ,OUTPUT 0 ). /* pr_nrrecid  */
    
      CLOSE STORED-PROC pc_gera_log_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}
    
    
      ASSIGN aux_nrrecid = pc_gera_log_prog.pr_nrrecid
                              WHEN pc_gera_log_prog.pr_nrrecid <> ?.       
                              
      /* Gerar log item (CRAPLGI) - Rotina Oracle */
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     
      RUN STORED-PROCEDURE pc_gera_log_item_prog
               aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT aux_nrrecid,
                   INPUT "Origem",
                   INPUT "",
                   INPUT IF par_flmobile = 1 THEN "MOBILE" ELSE "INTERNETBANK").

      CLOSE STORED-PROC pc_gera_log_item_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

END.


/******************************************************************************
 Encerrar a adesao ao DDA do cooperado
******************************************************************************/
PROCEDURE encerrar-sacado-dda:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR         aux_contador AS INTE                           NO-UNDO.
    DEF  VAR         aux_flgtrans AS LOGI                           NO-UNDO.
    DEF  VAR         h-b1wgen0079 AS HANDLE                         NO-UNDO.


    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Exclusão do cooperado como pagador eletrônico.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:

        RUN sistema/generico/procedures/b1wgen0079.p 
            PERSISTENT SET h-b1wgen0079.

        RUN requisicao-encerrar-sacado IN h-b1wgen0079
                                          (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT FALSE,
                                          OUTPUT TABLE tt-erro).  
        DELETE PROCEDURE h-b1wgen0079.

        IF   RETURN-VALUE <> "OK"   THEN
             LEAVE.
             
        ASSIGN aux_flgtrans = TRUE.
        LEAVE.

    END.  /* Fim tratamento de criticas */

    IF   NOT aux_flgtrans   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro   THEN
                  ASSIGN aux_dscritic = "Erro na exclusao do pagador.".
             ELSE
                  ASSIGN aux_dscritic = tt-erro.dscritic.
          
             IF   par_flgerlog   THEN 
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).
             RETURN "NOK".
         END.
         
    IF   par_flgerlog  THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Efetuar a impressao do termo de adesao.
*****************************************************************************/
PROCEDURE imprime-termo-adesao:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdtest1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpftest1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmdtest2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpftest2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
  
    DEF OUTPUT PARAM TABLE FOR tt-erro.     
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF VAR aux_nrcpfcgc AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsendere AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsmvtolt AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmextcop AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_dstipcta AS CHAR                                    NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_dsdecoop AS CHAR                                    NO-UNDO.
    DEF VAR aux_cpftest1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_cpftest2 AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.


    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Efetuar a impressao do termo de adesao.".
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    EMPTY TEMP-TABLE tt-erro.
    

    FORM "CONTRATO/TERMO DE ADESAO AO SISTEMA DE DEBITO DIRETO AUTORIZADO - DDA"
         SKIP(3)
         "COOPERATIVA"
         SKIP(1)
         "Cooperativa filiada a Cooperativa Central de Credito Urbano - AILOS,"
         "prestadora do servico de DDA"
         SKIP(1)
         aux_nmextcop FORMAT "x(100)"
         SKIP(1)
         "CNPJ: " tt-crapcop.nrdocnpj
         SKIP(1)
         "Endereco: " aux_dsendere FORMAT "x(110)"
         SKIP(2)
         WITH NO-LABEL SIDE-LABEL WIDTH 132 FRAME f_coop.

    FORM "PAGADOR ELETRONICO - COOPERADO"
         SKIP(1)
         aux_nmprimtl     LABEL "Nome/Razao Social" FORMAT "x(50)"
         SKIP(1)
         aux_nrcpfcgc     LABEL "CPF/CNPJ"          FORMAT "x(18)"
         SKIP(1)
         crapenc.dsendere LABEL "Endereco" 
         SKIP(1)
         crapenc.nmcidade LABEL "Cidade"
         SKIP(1)
         crapenc.cdufende LABEL "UF"   
         SPACE(5)
         crapenc.nrcepend LABEL "CEP"
         SKIP(1)
         WITH SIDE-LABEL WIDTH 132 FRAME f_sacado.
    
    FORM "Pelo presente instrumento, o PAGADOR ELETRONICO e, se for o caso, os"
         "seus PAGADORES AGREGADOS, acima" 
         SKIP          
         "identificados e qualificados, aderem ao Sistema de Debito Direto"
         "Autorizado - DDA e declaram, em carater irrevogavel" 
         SKIP  
         "e irretratavel, para todos os efeitos legais, o seguinte:"
         SKIP(1)
         "1 - Estao cientes e de pleno acordo com as disposicoes contidas nas"
         "Clausulas e Condicoes Gerais do Contrato para" 
         SKIP
         "    Prestacao de Servico do Sistema de Debito Direto Autorizado - DDA,"
         "registradas no" tt-crapcop.dslocdda 
         SKIP                
         aux_dsdecoop FORMAT "x(130)"
         SKIP
         "    as quais integram este Contrato/Termo de Adesao, para os devidos"
         "fins, formando um documento unico e indivisivel," 
         SKIP      
         "    cujo teor declaram conhecer e entender e com o qual concordam, "
         "passando a assumir todas as prerrogativas"
         SKIP
         "    e obrigacoes que lhes sao atribuidas, na condicao de PAGADOR "
         "ELETRONICO e, PAGADORES AGREGADOS."
         SKIP(1)    
         "2 - Neste ato estao plenamente cientes de que, a partir desta data,"
         "receberao os seus titulos de cobranca registrada,"
         SKIP
         "    exclusivamente de forma eletronica na(s) conta(s) de deposito"
         "elegivel(is) a participacao do DDA, nao mais recebendo-os "
         SKIP
         "    impressos em papel;"
         SKIP(1)
         "3 - Os PAGADORES AGREGADOS declaram ademais, estarem cientes de que,"
         "mediante a assinatura deste Termo,"
         SKIP
         "    autorizarao o PAGADOR ELETRONICO a visualizar e pagar todos os"
         "titulos de cobranca registrada emitidos contra"
         SKIP
         "    si, o qual tera poderes tambem para, a qualquer tempo, solicitar"
         "a exclusao de quaisquer PAGADORES AGREGADOS,"
         SKIP 
         "    independente de sua anuencia e/ou assinatura."
         SKIP(1)
         "E, por estarem assim justas e contratadas, firmam o presente"
         "Contrato/Termo de Adesao em tantas vias quantas forem"
         SKIP
         "necessarias para a entrega de uma via para cada parte, na presenca"
         "das duas testemunhas abaixo identificadas, que,"
         SKIP
         "estando cientes, tambem assinam, para que produza os devidos e"
         "legais efeitos."
         SKIP(1)
         aux_dsmvtolt AT 80 FORMAT "x(50)"
         SKIP(3)
         WITH NO-LABEL WIDTH 132 FRAME f_texto.
    
    FORM "__________________________________________" 
         SKIP
         aux_nmprimtl FORMAT "x(50)"
         SKIP(4)
         "__________________________________________" 
         SKIP
         aux_nmextcop FORMAT "x(100)"
         SKIP(3)
         "TESTEMUNHAS"
         SKIP(4)
         "__________________________________________"
         SKIP
         par_nmdtest1 FORMAT "x(50)"
         SKIP
         aux_cpftest1 FORMAT "x(30)"
         SKIP(4)
         "__________________________________________"
         SKIP
         par_nmdtest2 FORMAT "x(50)"
         SKIP
         aux_cpftest2 FORMAT "x(30)"
         WITH NO-LABELS WIDTH 132 FRAME f_assinaturas.

   
    ASSIGN aux_dsmesref = "JANEIRO,FEVEREIRO,MARCO,ABRIL,MAIO,JUNHO," + 
                          "JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO".  
    
    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO:
                 aux_cdcritic = 9.
                 LEAVE.
             END.
                                                  
        IF   crapass.inpessoa = 1    THEN
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                    crapttl.nrdconta = par_nrdconta   AND
                                    crapttl.idseqttl = par_idseqttl
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAIL crapttl   THEN
                      DO:
                          ASSIGN aux_dscritic = "Titular nao cadastrado.".
                          LEAVE.
                      END.            
             END.
            
        IF   crapass.inpessoa = 1   THEN
             FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper   AND
                                      crapenc.nrdconta = par_nrdconta   AND
                                      crapenc.idseqttl = par_idseqttl   AND
                                      crapenc.tpendass = 10
                                      NO-LOCK NO-ERROR.  
        ELSE
             FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper   AND
                                      crapenc.nrdconta = par_nrdconta   AND
                                      crapenc.idseqttl = par_idseqttl   AND
                                      crapenc.tpendass = 9
                                      NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapenc   THEN
             DO:
                 aux_cdcritic = 247.
                 LEAVE.
             END.
              
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
        RUN STORED-PROCEDURE pc_descricao_tipo_conta
          aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                   INPUT crapass.cdtipcta, /* Tipo de conta */
                                  OUTPUT "",               /* Descriçao do Tipo de conta */
                                  OUTPUT "",               /* Flag Erro */
                                  OUTPUT "").              /* Descriçao da crítica */

        CLOSE STORED-PROC pc_descricao_tipo_conta
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_dstipcta = ""
               aux_des_erro = ""
               aux_dscritic = ""
               aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                               WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
               aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                               WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
               aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                               WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
        
        IF aux_des_erro = "NOK"  THEN
                 LEAVE.

        RUN busca-coop (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                       OUTPUT TABLE tt-erro,
                       OUTPUT TABLE tt-crapcop).

        IF   RETURN-VALUE <> "OK"   THEN
             LEAVE.

        FIND FIRST tt-crapcop NO-LOCK NO-ERROR.

        /* Monta o nome do arquivo */
        ASSIGN par_nmarqimp = "/usr/coop/" + TRIM(tt-crapcop.dsdircop) + 
                              "/rl/" + par_dsiduser.

        /* Deletar arquivos deste terminal */
        UNIX SILENT VALUE("rm " + par_nmarqimp + "* 2>/dev/null").

        ASSIGN par_nmarqimp = par_nmarqimp + STRING(TIME) + ".ex".

        OUTPUT STREAM str_2 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 82.

        ASSIGN aux_nmextcop = tt-crapcop.nmextcop + " - " + tt-crapcop.nmrescop.
         
        RUN busca-end-coop (INPUT TABLE tt-crapcop,
                           OUTPUT aux_dsendere).

        IF   crapass.inpessoa = 1   THEN
             ASSIGN aux_nmprimtl = crapttl.nmextttl
                    aux_nrcpfcgc =  STRING(STRING(crapttl.nrcpfcgc,
                                      "99999999999"),"xxx.xxx.xxx-xx").                                     
        ELSE 
             ASSIGN aux_nmprimtl = crapass.nmprimtl
                    aux_nrcpfcgc =  STRING(STRING(crapass.nrcpfcgc,
                                      "99999999999999"),"xx.xxx.xxx/xxxx-xx").

        ASSIGN aux_dsmvtolt = CAPS(tt-crapcop.dsciddda) + ", " + 
                              STRING(DAY(par_dtmvtolt),"99") + " de " +
                              ENTRY(MONTH(par_dtmvtolt),aux_dsmesref) + " de " +
                              STRING(YEAR(par_dtmvtolt),"9999") + "." 
                        
               aux_cpftest1 = STRING(STRING(par_cpftest1,
                                      "99999999999"),"xxx.xxx.xxx-xx")
            
               aux_cpftest2 = STRING(STRING(par_cpftest2,
                                  "99999999999"),"xxx.xxx.xxx-xx")
            
               aux_dsdecoop = "    de " + tt-crapcop.dsciddda + ", em " + 
                              STRING(tt-crapcop.dtctrdda,"99/99/9999")  +
                              ", sob o n. " + tt-crapcop.nrctrdda       +
                              ", livro " + tt-crapcop.idlivdda + 
                              ", folha "    + 
                              STRING(tt-crapcop.nrfoldda,"zzz,zz9") + ",".   
                              

        DISPLAY STREAM str_2 aux_nmextcop
                             tt-crapcop.nrdocnpj
                             aux_dsendere WITH FRAME f_coop.

        DISPLAY STREAM str_2 aux_nmprimtl        aux_nrcpfcgc
                             crapenc.dsendere    crapenc.nmcidade
                             crapenc.cdufende    crapenc.nrcepend
                             WITH FRAME f_sacado.

        DISPLAY STREAM str_2 tt-crapcop.dslocdda
                             aux_dsdecoop aux_dsmvtolt WITH FRAME f_texto. 

        ASSIGN aux_nmprimtl = CAPS(aux_nmprimtl)
               par_nmdtest1 = CAPS(par_nmdtest1)
               par_nmdtest2 = CAPS(par_nmdtest2).

        DISPLAY STREAM str_2 aux_nmprimtl
                             aux_nmextcop 
                             par_nmdtest1 
                             aux_cpftest1 
                             par_nmdtest2
                             aux_cpftest2 WITH FRAME f_assinaturas.
                                                                     
        OUTPUT STREAM str_2 CLOSE.
         
        IF   par_idorigem = 5   THEN /* Copiar para o Ayllos Web */
             DO:
                 RUN sistema/generico/procedures/b1wgen0024.p
                     PERSISTENT SET h-b1wgen0024.

                 RUN envia-arquivo-web IN h-b1wgen0024
                                       (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_nmarqimp,
                                       OUTPUT par_nmarqpdf,
                                       OUTPUT TABLE tt-erro).           

                 DELETE PROCEDURE h-b1wgen0024.

                 IF   RETURN-VALUE <> "OK"  THEN 
                      LEAVE.
             END.

        ASSIGN aux_flgtrans = TRUE.
        LEAVE.

    END. /* Fim tratamento criticas */

    IF   NOT aux_flgtrans   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro   THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,  /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
             ELSE
                  ASSIGN aux_dscritic = tt-erro.dscritic.
          
             IF   par_flgerlog   THEN 
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).
             RETURN "NOK".
         END.

    IF   par_flgerlog  THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Efetuar a impressao do termo de exclusao.
*****************************************************************************/
PROCEDURE imprime-termo-exclusao:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdtest1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpftest1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmdtest2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpftest2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
  
    DEF OUTPUT PARAM TABLE FOR tt-erro.     
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.  


    DEF VAR aux_nrcpfcgc AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdecoop AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmextcop AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsendere AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsmvtolt AS CHAR                                    NO-UNDO.
    DEF VAR aux_cpftest1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_cpftest2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_dstipcta AS CHAR                                    NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.
                                  

    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Efetuar a impressao do termo de exclusao.".
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    EMPTY TEMP-TABLE tt-erro.


    FORM "CONTRATO/TERMO DE EXCLUSAO DE PAGADOR ELETRONICO E/OU PAGADOR AGREGADO DO"
         SKIP
         SPACE(16)
         "SISTEMA DE DEBITO DIRETO AUTORIZADO - DDA"
         SKIP(3)
         "COOPERATIVA"
         SKIP(1)
         "Cooperativa filiada a Cooperativa Central de Credito Urbano - AILOS,"
         "prestadora do servico de DDA"
         SKIP(1)
         aux_nmextcop FORMAT "x(100)"
         SKIP(1)
         "CNPJ: " tt-crapcop.nrdocnpj
         SKIP(1)
         "Endereco: " aux_dsendere FORMAT "x(110)"
         SKIP(2)
         WITH NO-LABEL SIDE-LABEL WIDTH 132 FRAME f_coop.

    FORM "PAGADOR ELETRONICO - COOPERADO"
         SKIP(1)
         aux_nmprimtl     LABEL "Nome/Razao Social" FORMAT "x(50)"
         SKIP(1)
         aux_nrcpfcgc     LABEL "CPF/CNPJ"          FORMAT "x(18)"
         SKIP(1)
         crapenc.dsendere LABEL "Endereco" 
         SKIP(1)
         crapenc.nmcidade LABEL "Cidade"
         SKIP(1)
         crapenc.cdufende LABEL "UF"   
         SPACE(5)
         crapenc.nrcepend LABEL "CEP"
         SKIP(1)
         WITH SIDE-LABEL WIDTH 132 FRAME f_sacado.

    FORM "Pelo presente instrumento, o PAGADOR ELETRONICO requer a exclusao da(s)"
         "pessoa(s) a seguir indicada(s), do"
         SKIP
         "Sistema de Debito Direto Autorizado - DDA:"
         SKIP(1)
         "     (  ) Exclusao do proprio PAGADOR ELETRONICO;"
         SKIP(1)
         "     (  ) Exclusao do(s) PAGADOR(ES) AGREGADO(S) acima indicado(s)."
         SKIP(1)
         "1 - O PAGADOR ELETRONICO declara estar ciente das consequencias"
         "decorrentes da exclusao solicitada,"
         SKIP
         "    estabelecidas na Clausula 07, XII e XIII das Clausulas e Condicoes"
         "Gerais do Contrato para Prestacao de Servico do"
         SKIP
         "    Sistema de Debito Direto Autorizado - DDA, registrado no" 
         tt-crapcop.dslocdda                                           
         aux_dsdecoop FORMAT "x(130)"   
         SKIP(1)
         "2 - Declara estar ciente ainda que, a sua exclusao do DDA, importara"
         "na exclusao automatica e imediata de seus"
         SKIP
         "    PAGADORES AGREGADOS, aos quais se obriga a informar sobre a presente"
         "solicitacao."
         SKIP(1)
         "3 - O PAGADOR ELETRONICO isenta a COOPERATIVA de qualquer prejuizo"
         "ou responsabilidade, nos termos"
         SKIP
         "    contratuais, decorrentes da presente solicitacao."
         SKIP(1)
         "E, por estarem assim justas e contratadas, firmam o presente"
         "Contrato/Termo de Exclusao em tantas vias quantas forem"
         SKIP
         "necessarias para a entrega de uma via para cada parte, na presenca"
         "das duas testemunhas abaixo identificadas, que,"
         SKIP
         "estando cientes, tambem assinam, para que produza os devidos e"
         "legais efeitos."
         SKIP(1)
         SKIP(1)
         aux_dsmvtolt AT 80 FORMAT "x(50)"
         SKIP(3)
         WITH NO-LABEL WIDTH 132 FRAME f_texto.

    FORM "__________________________________________" 
         SKIP
         aux_nmprimtl FORMAT "x(50)"
         SKIP(4)
         "__________________________________________" 
         SKIP
         aux_nmextcop FORMAT "x(100)"
         SKIP(3)
         "TESTEMUNHAS"
         SKIP(4)
         "__________________________________________"
         SKIP
         par_nmdtest1 FORMAT "x(50)"
         SKIP
         aux_cpftest1 FORMAT "x(30)"
         SKIP(4)
         "__________________________________________"
         SKIP
         par_nmdtest2 FORMAT "x(50)"
         SKIP
         aux_cpftest2 FORMAT "x(30)"
         WITH NO-LABELS WIDTH 132 FRAME f_assinaturas.

    ASSIGN aux_dsmesref = "JANEIRO,FEVEREIRO,MARCO,ABRIL,MAIO,JUNHO," + 
                          "JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO".

    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO:
                 aux_cdcritic = 9.
                 LEAVE.
             END.
                                                  
        IF   crapass.inpessoa = 1    THEN
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                    crapttl.nrdconta = par_nrdconta   AND
                                    crapttl.idseqttl = par_idseqttl
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAIL crapttl   THEN
                      DO:
                          ASSIGN aux_dscritic = "Titular nao cadastrado.".
                          LEAVE.
                      END.            
             END.
            
        IF   crapass.inpessoa = 1   THEN
             FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper   AND
                                      crapenc.nrdconta = par_nrdconta   AND
                                      crapenc.idseqttl = par_idseqttl   AND
                                      crapenc.tpendass = 10
                                      NO-LOCK NO-ERROR.  
        ELSE
             FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper   AND
                                      crapenc.nrdconta = par_nrdconta   AND
                                      crapenc.idseqttl = par_idseqttl   AND
                                      crapenc.tpendass = 9
                                      NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapenc   THEN
             DO:
                 aux_cdcritic = 247.
                 LEAVE.
             END.
              
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
        RUN STORED-PROCEDURE pc_descricao_tipo_conta
          aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                   INPUT crapass.cdtipcta, /* Tipo de conta */
                                  OUTPUT "",               /* Descriçao do Tipo de conta */
                                  OUTPUT "",               /* Flag Erro */
                                  OUTPUT "").              /* Descriçao da crítica */
        
        CLOSE STORED-PROC pc_descricao_tipo_conta
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_dstipcta = ""
               aux_des_erro = ""
               aux_dscritic = ""
               aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                               WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
               aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                               WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
               aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                               WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.

        IF aux_des_erro = "NOK"  THEN
                 LEAVE.

        RUN busca-coop (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                       OUTPUT TABLE tt-erro,
                       OUTPUT TABLE tt-crapcop).

        IF   RETURN-VALUE <> "OK"   THEN
             LEAVE.

        FIND FIRST tt-crapcop NO-LOCK NO-ERROR.

        /* Monta o nome do arquivo */
        ASSIGN par_nmarqimp = "/usr/coop/" + TRIM(tt-crapcop.dsdircop) + 
                              "/rl/" + par_dsiduser.

        /* Deletar arquivos deste terminal */
        UNIX SILENT VALUE("rm " + par_nmarqimp + "* 2>/dev/null").

        ASSIGN par_nmarqimp = par_nmarqimp + STRING(TIME) + ".ex".

        OUTPUT STREAM str_2 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 82.

        ASSIGN aux_nmextcop = tt-crapcop.nmextcop + " - " + tt-crapcop.nmrescop.
         
        RUN busca-end-coop (INPUT TABLE tt-crapcop,
                           OUTPUT aux_dsendere).
        
        IF   crapass.inpessoa = 1   THEN
             ASSIGN aux_nmprimtl = crapttl.nmextttl
                    aux_nrcpfcgc =  STRING(STRING(crapttl.nrcpfcgc,
                                      "99999999999"),"xxx.xxx.xxx-xx").                                     
        ELSE 
             ASSIGN aux_nmprimtl = crapass.nmprimtl
                    aux_nrcpfcgc =  STRING(STRING(crapass.nrcpfcgc,
                                      "99999999999999"),"xx.xxx.xxx/xxxx-xx").

        ASSIGN aux_dsmvtolt = CAPS(tt-crapcop.dsciddda) + ", " + 
                              STRING(DAY(par_dtmvtolt),"99") + " de " +
                              ENTRY(MONTH(par_dtmvtolt),aux_dsmesref) + " de " +
                              STRING(YEAR(par_dtmvtolt),"9999") + "." 
                        
               aux_cpftest1 = STRING(STRING(par_cpftest1,
                                      "99999999999"),"xxx.xxx.xxx-xx")
            
               aux_cpftest2 = STRING(STRING(par_cpftest2,
                                  "99999999999"),"xxx.xxx.xxx-xx")
            
               aux_dsdecoop = "    de " + tt-crapcop.dsciddda + ", em " + 
                              STRING(tt-crapcop.dtctrdda,"99/99/9999")  +
                              ", sob o n. " + tt-crapcop.nrctrdda       +
                              ", livro " + tt-crapcop.idlivdda          +
                              ", folha "    + 
                              STRING(tt-crapcop.nrfoldda,"zzz,zz9") + ",".   
                             
        DISPLAY STREAM str_2 aux_nmextcop
                             tt-crapcop.nrdocnpj
                             aux_dsendere WITH FRAME f_coop.

        DISPLAY STREAM str_2 aux_nmprimtl
                             aux_nrcpfcgc
                             crapenc.dsendere
                             crapenc.nmcidade
                             crapenc.cdufende 
                             crapenc.nrcepend WITH FRAME f_sacado.

        DISPLAY STREAM str_2 tt-crapcop.dslocdda
                             aux_dsdecoop aux_dsmvtolt WITH FRAME f_texto. 

         ASSIGN aux_nmprimtl = CAPS(aux_nmprimtl)
                par_nmdtest1 = CAPS(par_nmdtest1)
                par_nmdtest2 = CAPS(par_nmdtest2).

        DISPLAY STREAM str_2 aux_nmprimtl
                             aux_nmextcop 
                             par_nmdtest1 
                             aux_cpftest1 
                             par_nmdtest2
                             aux_cpftest2 WITH FRAME f_assinaturas.

        OUTPUT STREAM str_2 CLOSE.
         
        IF   par_idorigem = 5   THEN /* Copiar para o Ayllos Web */
             DO:
                 RUN sistema/generico/procedures/b1wgen0024.p
                     PERSISTENT SET h-b1wgen0024.

                 RUN envia-arquivo-web IN h-b1wgen0024
                                       (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_nmarqimp,
                                       OUTPUT par_nmarqpdf,
                                       OUTPUT TABLE tt-erro).           

                 DELETE PROCEDURE h-b1wgen0024.

                 IF   RETURN-VALUE <> "OK"  THEN 
                      LEAVE.
             END.

        ASSIGN aux_flgtrans = TRUE.
        LEAVE.

    END.

    IF   NOT aux_flgtrans   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro   THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,  /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
             ELSE
                  ASSIGN aux_dscritic = tt-erro.dscritic.
          
             IF   par_flgerlog   THEN 
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).
             RETURN "NOK".
         END.

    IF   par_flgerlog  THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).
    RETURN "OK".

END PROCEDURE.


/****************************************************************************
 Efetuar a verificacao se o CPF/CNPJ é um PAGADOR eletronico na base JDDDA  
****************************************************************************/
PROCEDURE verifica-sacado:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_flgverif AS LOGI                            NO-UNDO.


    DEF VAR h-b1wgen0079 AS HANDLE                                   NO-UNDO.


    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Verificar se o CPF/CNPJ e um pagador eletronico.".
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    EMPTY TEMP-TABLE tt-erro.

    RUN sistema/generico/procedures/b1wgen0079.p PERSISTENT SET h-b1wgen0079.

    RUN requisicao-verificar IN h-b1wgen0079 (INPUT par_cdcooper,
                                              INPUT par_cdagecxa,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nmdatela,
                                              INPUT par_idorigem,
                                              INPUT par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT par_flgerlog,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT par_flgverif).
    DELETE PROCEDURE h-b1wgen0079.

    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   AVAIL tt-erro   THEN
                  ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE
                  ASSIGN aux_dscritic = "Erro na verificacao do CPF/CNPJ.".

             IF   par_flgerlog   THEN 
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.

/***************************************************************************
 Trazer todos os titulos bloqueados.
***************************************************************************/
PROCEDURE lista-grupo-titulos-sacado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvenini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvenfin AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsittit AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idordena AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qttitulo AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-grupo-titulos-sacado-dda.
    DEF OUTPUT PARAM TABLE FOR tt-grupo-instr-tit-sacado-dda.
    DEF OUTPUT PARAM TABLE FOR tt-grupo-descto-tit-sacado-dda.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_nritmini AS INTE INIT 1                             NO-UNDO.
    DEF VAR aux_nritmfin AS INTE INIT 100                           NO-UNDO.
    DEF VAR h-b1wgen0079 AS HANDLE                                  NO-UNDO.

    
    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Trazer todos os titulos bloqueados.".
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.
    
    DO WHILE TRUE:

        RUN sistema/generico/procedures/b1wgen0079.p 
            PERSISTENT SET h-b1wgen0079.

        RUN lista-titulos-sacado IN h-b1wgen0079
                                     (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT par_dtvenini,
                                      INPUT par_dtvenfin,
                                      INPUT aux_nritmini,
                                      INPUT aux_nritmfin,
                                      INPUT par_cdsittit,
                                      INPUT par_idordena,
                                      INPUT FALSE,
                                      INPUT FALSE,
                                     OUTPUT par_qttitulo,
                                     OUTPUT TABLE tt-titulos-sacado-dda,
                                     OUTPUT TABLE tt-instr-tit-sacado-dda,
                                     OUTPUT TABLE tt-descto-tit-sacado-dda,
                                     OUTPUT TABLE tt-erro).
                                               
        DELETE PROCEDURE h-b1wgen0079.

        IF   RETURN-VALUE <> "OK"   THEN
             UNDO, LEAVE.

        /* Copiar os dados das temp-table retornadas para as do grupo */

        TEMP-TABLE tt-grupo-titulos-sacado-dda:COPY-TEMP-TABLE 
            ( TEMP-TABLE tt-titulos-sacado-dda:HANDLE,TRUE ).

        TEMP-TABLE tt-grupo-instr-tit-sacado-dda:COPY-TEMP-TABLE 
            ( TEMP-TABLE tt-instr-tit-sacado-dda:HANDLE,TRUE ).

        TEMP-TABLE tt-grupo-descto-tit-sacado-dda:COPY-TEMP-TABLE 
            ( TEMP-TABLE tt-descto-tit-sacado-dda:HANDLE,TRUE ).
    
        IF   par_qttitulo > aux_nritmfin   THEN /* Se tem mais titulos */
             DO:
                 ASSIGN aux_nritmini = aux_nritmfin + 1    /*Ini = Fim + 1 */
                        aux_nritmfin = aux_nritmfin + 100. /*Fim = Fim + 100 */             
                 NEXT.
             END.
               
        ASSIGN aux_flgtrans = TRUE.
        LEAVE.
    END.

    IF   NOT aux_flgtrans  THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
             IF   NOT AVAIL tt-erro   THEN
                  ASSIGN aux_dscritic = "Erro na impressao dos titulos.".
             ELSE
                  ASSIGN aux_dscritic = tt-erro.dscritic.
             
             IF   par_flgerlog   THEN 
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
             RETURN "NOK".
         END.

    IF   par_flgerlog  THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Trazer o nome da testemunha se o CPF dele é de cooperado
*****************************************************************************/
PROCEDURE traz-nome-testemunha:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-testemunha.


    EMPTY TEMP-TABLE tt-testemunha.

    FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                             crapttl.nrcpfcgc = par_nrcpfcgc   NO-LOCK NO-ERROR.

    CREATE tt-testemunha.
    ASSIGN tt-testemunha.nrcpfcgc = par_nrcpfcgc
           tt-testemunha.nmdteste = crapttl.nmextttl WHEN AVAIL crapttl.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
 Validar os CPF das testemunhas para a impressao do termo de adesao
*****************************************************************************/
PROCEDURE valida-cpf-testemunhas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdtest1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpftest1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmdtest2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpftest2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF  VAR         par_stsnrcal AS LOGI                           NO-UNDO.
    DEF  VAR         h-b1wgen9999 AS HANDLE                         NO-UNDO.

     
    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Validar CPF das testemunhas.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND   
                           crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE.
             END.

        IF   par_nmdtest1 = ""   AND   
             par_cpftest1 <> 0   THEN
             DO:
                 ASSIGN aux_dscritic = "Nome da testemunha 1 nao foi prenchido.".
                 LEAVE.
             END.

        IF   par_nmdtest2 =  ""   AND  
             par_cpftest2 <> 0    THEN
             DO:
                 ASSIGN aux_dscritic = "Nome da testemunha 2 nao foi prenchido.".
                 LEAVE.             
             END.

        IF   par_nmdtest1 <> ""   AND   
             par_cpftest1 =  0    THEN
             DO:
                 ASSIGN aux_dscritic = "CPF da testemunha 1 nao foi prenchido.".
                 LEAVE.
             END.

        IF   par_nmdtest2 <> ""   AND
             par_cpftest2 =  0    THEN
             DO:
                 ASSIGN aux_dscritic = "CPF da testemunha 2 nao foi prenchido.".
                 LEAVE.
             END.

        IF   par_cpftest1 <> 0   THEN
             DO:
                 RUN sistema/generico/procedures/b1wgen9999.p
                     PERSISTENT SET h-b1wgen9999.

                 RUN valida-cpf IN h-b1wgen9999 (INPUT par_cpftest1,
                                                OUTPUT par_stsnrcal).

                 DELETE PROCEDURE h-b1wgen9999.

                 IF   NOT par_stsnrcal   THEN /* CPF com erro */
                      DO:
                          ASSIGN aux_cdcritic = 27.
                          LEAVE.
                      END.

                 IF   par_cpftest1 = crapass.nrcpfcgc   THEN
                      DO:
                          ASSIGN aux_dscritic = 
                           "CPF da testemunha nao pode ser igual ao do cooperado.".
                          LEAVE.
                      END.
             END.

        IF   par_cpftest2 <> 0   THEN
             DO:
                 RUN sistema/generico/procedures/b1wgen9999.p
                     PERSISTENT SET h-b1wgen9999.

                 RUN valida-cpf IN h-b1wgen9999  (INPUT par_cpftest2,
                                                 OUTPUT par_stsnrcal).

                 DELETE PROCEDURE h-b1wgen9999.

                 IF   NOT par_stsnrcal   THEN /* CPF com erro */
                      DO:
                          ASSIGN aux_cdcritic = 27.
                          LEAVE.
                      END.

                 IF   par_cpftest2 = crapass.nrcpfcgc   THEN
                      DO:
                          ASSIGN aux_dscritic = 
                           "CPF da testemunha nao pode ser igual ao do cooperado.".
                          LEAVE.
                      END.
             END.

        IF   par_cpftest1 <> 0   AND
             par_cpftest2 <> 0   AND 
             par_cpftest1 = par_cpftest2  THEN
             DO:
                 ASSIGN aux_dscritic = "CPF das testemunhas nao pode ser igual.".
                 LEAVE.
             END.

        LEAVE.
    END.
    
    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             IF   par_flgerlog   THEN 
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).
             RETURN "NOK".   
         END.
                      
    RETURN "OK".

END PROCEDURE.


/* .......................... PROCEDURES INTERNAS .......................... */

PROCEDURE situacao-cad-dda:

    DEF  INPUT PARAM par_cdsituac AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_dssituac AS CHAR                            NO-UNDO.

    FIND craptab WHERE craptab.cdcooper = 0              AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "SITSACADDA"   AND
                       craptab.tpregist = par_cdsituac   NO-LOCK NO-ERROR.

    ASSIGN par_dssituac =  IF   AVAIL craptab   THEN
                                craptab.dstextab 
                           ELSE 
                                "SITUACAO NAO CADASTRADA".
    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Buscar os dados da cooperativa para impressao do termo
******************************************************************************/
PROCEDURE busca-coop:

    DEF INPUT  PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapcop.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper   NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapcop   THEN
         DO:
             ASSIGN aux_cdcritic = 794
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic, 
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    CREATE tt-crapcop.
    BUFFER-COPY crapcop EXCEPT nrctabcb TO tt-crapcop.

    RETURN "OK".

END PROCEDURE.


PROCEDURE busca-end-coop:

    DEF  INPUT PARAM TABLE FOR tt-crapcop.
    DEF OUTPUT PARAM par_dsendere AS CHAR                        NO-UNDO.


    FIND FIRST tt-crapcop NO-LOCK NO-ERROR.

    IF   NOT AVAIL tt-crapcop   THEN
         DO:
             ASSIGN aux_cdcritic = 794.
             RETURN "NOK".
         END.

    ASSIGN par_dsendere = tt-crapcop.dsendcop.

    IF   tt-crapcop.nrendcop <> 0    THEN /* Numero Endereco */
         par_dsendere = IF   par_dsendere <> ""   THEN 
                             par_dsendere + "," + STRING(tt-crapcop.nrendcop)
                        ELSE 
                             STRING(tt-crapcop.nrendcop).

    IF   tt-crapcop.nrcxapst <> 0   THEN /* Cx. Postal */
         par_dsendere = IF   par_dsendere <> ""   THEN 
                             par_dsendere + ", Cx. Postal " + 
                                       STRING(tt-crapcop.nrcxapst)
                        ELSE 
                             "Cx. Postal " + STRING(tt-crapcop.nrcxapst).
            
    IF   tt-crapcop.dscomple <> ""   THEN /* Complemento */
         par_dsendere = IF   par_dsendere <> ""   THEN 
                             par_dsendere + "," + tt-crapcop.dscomple
                        ELSE 
                             tt-crapcop.dscomple.
                                     
    IF   tt-crapcop.nmbairro <> ""   THEN /* Bairro */
         par_dsendere = IF   par_dsendere <> ""   THEN
                             par_dsendere + ", Bairro " + tt-crapcop.nmbairro
                        ELSE
                             "Bairro " + tt-crapcop.nmbairro.

    IF   tt-crapcop.nmcidade <> ""   THEN /* Cidade */
         par_dsendere = IF   par_dsendere <> ""   THEN
                             par_dsendere  + "," + tt-crapcop.nmcidade
                        ELSE
                             tt-crapcop.nmcidade.

    IF   tt-crapcop.cdufdcop <> ""   THEN /* U.F */
         par_dsendere = IF   par_dsendere <> ""   THEN
                             par_dsendere + "/" + tt-crapcop.cdufdcop
                        ELSE 
                             tt-crapcop.cdufdcop.               

    IF   tt-crapcop.nrcepend <> 0    THEN /* CEP */
         par_dsendere = IF   par_dsendere <> ""   THEN
                             par_dsendere + " - CEP " + 
                             STRING(tt-crapcop.nrcepend,"zz,zzz,zz9")
                        ELSE 
                             "CEP " + 
                                 STRING(tt-crapcop.nrcepend,"zz,zzz,zz9"). 
    RETURN "OK".

END PROCEDURE.

/*...........................................................................*/
