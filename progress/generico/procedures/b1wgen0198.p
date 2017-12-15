/*..............................................................................

   Programa: b1wgen0197.p
   Autora  : Rafael Muniz Monteiro - Mout's
   Data    : 11/12/2017                        Ultima atualizacao: 

   Dados referentes ao programa:

   Objetivo  : BO - Rotinas para geraçao de emprestimo linha 100

   Alteracoes: 

 ..............................................................................*/

/*................................ DEFINICOES ................................*/

{ sistema/generico/includes/b1wgen0188tt.i  }
{ sistema/generico/includes/b1wgen0002tt.i  }
{ sistema/generico/includes/b1wgen0024tt.i  }
{ sistema/generico/includes/b1wgen0038tt.i  }
{ sistema/generico/includes/b1wgen0043tt.i  }
{ sistema/generico/includes/b1wgen0056tt.i  }
{ sistema/generico/includes/b1wgen0069tt.i  }
{ sistema/generico/includes/b1wgen0084tt.i  }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/b1wgen9999tt.i  }


{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i } 


DEF TEMP-TABLE tt-tipo-rendi                                           NO-UNDO
    FIELD tpdrendi  AS INTE
    FIELD dsdrendi  AS CHAR.

DEF TEMP-TABLE tt-aval-crapbem                                         NO-UNDO
    LIKE tt-crapbem
    USE-INDEX crapbem2 USE-INDEX tt-crapbem AS PRIMARY.

DEF VAR h-b1wgen0002  AS HANDLE                                        NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_des_reto AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.


/*............................ PROCEDURES EXTERNAS ...........................*/

/******************************************************************************/
/**      Procedure para criar contrato de emprestimo de linha 100     **/
/******************************************************************************/
PROCEDURE grava_dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    /*DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.*/
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
        
    DEF OUTPUT PARAM nov_nrctremp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_dtdrisco LIKE crapris.dtdrisco                      NO-UNDO.
    DEF VAR aux_dtoutris LIKE crapprp.dtoutris                      NO-UNDO.
    DEF VAR aux_vltotsfn LIKE crapprp.vltotsfn                      NO-UNDO.
    DEF VAR aux_qtopescr LIKE crapprp.qtopescr                      NO-UNDO.
    DEF VAR aux_qtifoper LIKE crapprp.qtifoper                      NO-UNDO.
    DEF VAR aux_vlopescr LIKE crapprp.vlopescr                      NO-UNDO.
    DEF VAR aux_vlrpreju LIKE crapprp.vlrpreju                      NO-UNDO.
    DEF VAR aux_vlsfnout LIKE crapprp.vlsfnout                      NO-UNDO.
    DEF VAR aux_vlsalari LIKE crapttl.vlsalari                      NO-UNDO.
    DEF VAR aux_vloutras LIKE crapprp.vloutras                      NO-UNDO.
    DEF VAR aux_vlalugue LIKE crapprp.vlalugue                      NO-UNDO.
    DEF VAR aux_vlsalcon LIKE crapprp.vlsalcon                      NO-UNDO.
    DEF VAR aux_nmempcje LIKE crapprp.nmempcje                      NO-UNDO.
    DEF VAR aux_flgdocje LIKE crapprp.flgdocje                      NO-UNDO.
    DEF VAR aux_nrctacje LIKE crapprp.nrctacje                      NO-UNDO.
    DEF VAR aux_nrcpfcje LIKE crapprp.nrcpfcje                      NO-UNDO.
    DEF VAR aux_perfatcl LIKE crapjfn.perfatcl                      NO-UNDO.
    DEF VAR aux_vlmedfat LIKE crapprp.vlmedfat                      NO-UNDO.
    DEF VAR aux_dsjusren LIKE craprpr.dsjusren                      NO-UNDO.
    DEF VAR aux_vltarifa LIKE crapepr.vltarifa                      NO-UNDO.
    DEF VAR aux_vltaxiof LIKE crapepr.vltaxiof                      NO-UNDO.
    DEF VAR aux_vltariof LIKE crapepr.vltariof                      NO-UNDO.
    DEF VAR aux_dsmesage AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlutiliz AS DECI                                    NO-UNDO.
    DEF VAR aux_nomcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdbeavt AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdfinan AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdrendi AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdebens AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdalien AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinterv AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgerlog AS LOG                                     NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_recidepr AS INTE                                    NO-UNDO.
    DEF VAR aux_flmudfai AS CHAR                                    NO-UNDO.
    DEF VAR aux_nivrisco AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtdiacar AS INTE                                    NO-UNDO.
    DEF VAR aux_vlajuepr AS DECI                                    NO-UNDO.
    DEF VAR aux_txdiaria AS DECI                                    NO-UNDO.
    DEF VAR aux_txmensal AS DECI                                    NO-UNDO.
    DEF VAR aux_vlpreemp AS DECI                                    NO-UNDO.
    DEF VAR aux_percetop AS DECI                                    NO-UNDO.
    DEF VAR aux_txcetmes AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsddisp AS DECI                                    NO-UNDO.
    
    DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0084 AS HANDLE                                  NO-UNDO.
    
    

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.

    IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p 
           PERSISTENT SET h-b1wgen0002.

    IF NOT VALID-HANDLE(h-b1wgen0043) THEN
       RUN sistema/generico/procedures/b1wgen0043.p 
           PERSISTENT SET h-b1wgen0043.

    IF NOT VALID-HANDLE(h-b1wgen0084) THEN
       RUN sistema/generico/procedures/b1wgen0084.p 
           PERSISTENT SET h-b1wgen0084.
    

    ASSIGN aux_flgerlog = TRUE
           aux_flgtrans = FALSE
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gravacao de transferencia de conta prejuizo".

    /* Verificacao de contrato de acordo */  
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Verifica se ha contratos de acordo */
    RUN STORED-PROCEDURE pc_verifica_acordo_ativo
      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                          ,INPUT par_nrdconta
                                          ,INPUT par_nrdconta /*par_nrctremp*/
                                          ,INPUT 0 /*3*/
                                          ,0
                                          ,0
                                          ,"").

    CLOSE STORED-PROC pc_verifica_acordo_ativo
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
           aux_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
           aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo).
    
    IF aux_cdcritic > 0 OR (aux_dscritic <> ? AND aux_dscritic <> "") THEN
      DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
      END.        
      
    IF aux_flgativo = 1 THEN
      DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Transferencia para prejuizo nao permitida, emprestimo em acordo. Cooperativa :"+par_cdcooper+
                              " Conta: "+par_nrdconta.

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT 1, /* nrdcaixa  */
                      INPUT 1, /* sequencia */
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).

       RETURN "NOK".
           
     END.
     /* Buscar o valor a ser online da conta transferido*/
     /* Utilizar o tipo de busca A, para carregar do dia anterior
      (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
     RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT crapcop.cdcooper,
                                 INPUT crapris.cdagenci,
                                 INPUT 1, /* nrdcaixa */
                                 INPUT aux_cdoperad, 
                                 INPUT crapris.nrdconta,
                                 INPUT crapdat.dtmvtolt,
                                 INPUT "A", /* Tipo Busca */
                                 OUTPUT 0,
                                 OUTPUT "").

     CLOSE STORED-PROC pc_obtem_saldo_dia_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
     
     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
     ASSIGN aux_cdcritic = 0
            aux_dscritic = ""
            aux_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic 
                               WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
            aux_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                               WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?. 
     
     IF aux_cdcritic <> 0  OR 
        aux_dscritic <> "" THEN
        DO: 
           IF  aux_dscritic = "" THEN
               ASSIGN aux_dscritic =  "Nao foi possivel carregar os saldos dia.".
            
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                             " - " + aux_nmdatela + "' --> '"  +
                             aux_dscritic + " >> log/proc_batch.log").
           RETURN "NOK".
        END.
     
     FIND FIRST wt_saldos NO-LOCK NO-ERROR.
     IF AVAIL wt_saldos THEN
       DO:
        ASSIGN aux_vlsddisp = wt_saldos.vlsddisp * -1.
       END.  
     
     IF aux_vlsddisp = ? THEN
       DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic =  "Nao encontrou saldo online para a conta "+par_nrdconta.
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).               
        RETURN "NOK".     
       END.
     /* FIM - Buscar o valor a ser online da conta transferido**/
     /*Carrega as informacoe necessarias para gerar a linha 100*/      
     RUN obtem-dados-proposta-emprestimo 
         IN h-b1wgen0002(INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT par_cdoperad,
                         INPUT par_nmdatela,
                         INPUT 0,    /* par_inproces */
                         INPUT par_idorigem,
                         INPUT par_nrdconta,
                         INPUT par_idseqttl,
                         INPUT par_dtmvtolt,
                         INPUT 0,    /* par_nrctremp */
                         INPUT "I",  /* par_cddopcao */
                         INPUT 0,
                         INPUT aux_flgerlog,
                         OUTPUT TABLE tt-erro,
                         OUTPUT TABLE tt-dados-coope,
                         OUTPUT TABLE tt-dados-assoc,
                         OUTPUT TABLE tt-tipo-rendi,
                         OUTPUT TABLE tt-itens-topico-rating,
                         OUTPUT TABLE tt-proposta-epr,
                         OUTPUT TABLE tt-crapbem,
                         OUTPUT TABLE tt-bens-alienacao,
                         OUTPUT TABLE tt-rendimento,
                         OUTPUT TABLE tt-faturam,
                         OUTPUT TABLE tt-dados-analise,
                         OUTPUT TABLE tt-interv-anuentes,
                         OUTPUT TABLE tt-hipoteca,
                         OUTPUT TABLE tt-dados-avais,
                         OUTPUT TABLE tt-aval-crapbem,
                         OUTPUT TABLE tt-msg-confirma).

     IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

     /* Dados gerais da cooperativa */
     FIND FIRST tt-dados-coope NO-LOCK NO-ERROR.
     /* Dados na crawepr */
     FIND FIRST tt-proposta-epr NO-LOCK NO-ERROR.
     /* Dados gerais do cooperado */
     FIND FIRST tt-dados-assoc NO-LOCK NO-ERROR.       

     /* Rendimento */
     FIND FIRST tt-rendimento NO-LOCK NO-ERROR.
     IF AVAIL tt-rendimento THEN
        DO:
            ASSIGN aux_vlsalari = tt-rendimento.vlsalari
                   aux_vloutras = tt-rendimento.vloutras
                   aux_vlalugue = tt-rendimento.vlalugue
                   aux_vlsalcon = tt-rendimento.vlsalcon
                   aux_nmempcje = tt-rendimento.nmextemp
                   aux_flgdocje = tt-rendimento.flgdocje
                   aux_nrctacje = tt-rendimento.nrctacje
                   aux_nrcpfcje = tt-rendimento.nrcpfcjg
                   aux_vlmedfat = tt-rendimento.vlmedfat
                   aux_dsjusren = tt-rendimento.dsjusren
                   aux_perfatcl = tt-rendimento.perfatcl.

          /*  IF tt-rendimento.perfatcl = 0 THEN
               ASSIGN aux_perfatcl = 15.
            ELSE
               ASSIGN aux_perfatcl = tt-rendimento.perfatcl.  */
        END.
  
     /* Dados do risco */
     FIND FIRST tt-dados-analise NO-LOCK NO-ERROR.
     IF AVAIL tt-dados-analise THEN
        DO:
            ASSIGN aux_dtdrisco = tt-dados-analise.dtdrisco
                   aux_vltotsfn = tt-dados-analise.vltotsfn
                   aux_dtoutris = tt-dados-analise.dtoutris
                   aux_qtopescr = tt-dados-analise.qtopescr
                   aux_qtifoper = tt-dados-analise.qtifoper
                   aux_vlopescr = tt-dados-analise.vlopescr
                   aux_vlrpreju = tt-dados-analise.vlrpreju
                   aux_vlsfnout = tt-dados-analise.vlsfnout.
        END.
  
     ASSIGN tt-proposta-epr.nivrisco = "H".
  
     RUN valida-dados-gerais IN h-b1wgen0002(INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT par_dtmvtopr,
                                             INPUT "I",  /* par_cddopcao */
                                             INPUT 0,    /* par_inproces */
                                             INPUT tt-dados-assoc.cdagenci,
                                             INPUT 0,    /* par_nrctremp */
                                             INPUT par_cdlcremp,
                                             INPUT 1, /* par_qtpreemp */
                                             INPUT "",   /* par_dsctrliq */
                                             INPUT tt-dados-coope.vlmaxutl,
                                             INPUT tt-dados-coope.vlmaxleg,
                                             INPUT tt-dados-coope.vlcnsscr,
                                             INPUT aux_vlsddisp, /*par_vlemprst,*/
                                             INPUT par_dtdpagto,
                                             INPUT 1,    /* par_inconfir */
                                             INPUT 1,    /* par_tpaltera */
                                             INPUT tt-dados-assoc.cdempres,
                                             INPUT FALSE,/* par_flgpagto */
                                             INPUT ?,    /* par_dtdpagt2 */
                                             INPUT 0,    /* par_ddmesnov */
                                             INPUT par_cdfinemp,
                                             INPUT 0,    /* par_qtdialib */
                                             INPUT tt-dados-assoc.inmatric,
                                             INPUT aux_flgerlog,
                                             INPUT 1,    /* par_tpemprst */
                                             INPUT par_dtmvtolt,
                                             INPUT 30,   /* par_inconfi2 */
                                             INPUT 0,
                                             INPUT "", /* cdmodali */
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-msg-confirma,
                                             OUTPUT TABLE tt-ge-epr,
                                             OUTPUT aux_dsmesage,
                                             OUTPUT tt-proposta-epr.vlpreemp,
                                             OUTPUT tt-proposta-epr.dslcremp,
                                             OUTPUT tt-proposta-epr.dsfinemp,
                                             OUTPUT tt-proposta-epr.tplcremp,
                                             OUTPUT tt-proposta-epr.flgpagto,
                                             OUTPUT tt-proposta-epr.dtdpagto,
                                             OUTPUT aux_vlutiliz,
                                             OUTPUT aux_nivrisco).

     IF RETURN-VALUE <> "OK" THEN
     DO:
        RETURN "NOK".
     END.   
          
     /* Busca os dados da proposta a partir da finalidade */
     RUN carrega_dados_proposta_finalidade IN h-b1wgen0002
                                           (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_idorigem,
                                            INPUT par_dtmvtolt,
                                            INPUT par_nrdconta,
                                            INPUT 1,    /* par_tpemprst */
                                            INPUT par_cdfinemp,
                                            INPUT par_cdlcremp,
                                            INPUT FALSE,
                                            INPUT tt-proposta-epr.dsctrliq,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-dados-proposta-fin).
     
     IF RETURN-VALUE <> "OK" THEN
     DO:
        RETURN "NOK".
     END.
     
     FIND FIRST tt-dados-proposta-fin 
          NO-LOCK NO-ERROR.
     /* Carregar dados */
     IF AVAIL tt-dados-proposta-fin THEN
     DO:
     
         ASSIGN tt-dados-analise.nrgarope = tt-dados-proposta-fin.nrgarope
                tt-dados-analise.nrinfcad = tt-dados-proposta-fin.nrinfcad
                tt-dados-analise.nrliquid = tt-dados-proposta-fin.nrliquid
                tt-dados-analise.nrpatlvr = tt-dados-proposta-fin.nrpatlvr
                tt-dados-analise.nrperger = tt-dados-proposta-fin.nrperger.     
     END.     

     RUN valida-itens-rating IN h-b1wgen0043(INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_dtmvtolt,
                                             INPUT par_nrdconta,
                                             INPUT tt-dados-analise.nrgarope,
                                             INPUT tt-dados-analise.nrinfcad,
                                             INPUT tt-dados-analise.nrliquid,
                                             INPUT tt-dados-analise.nrpatlvr,
                                             INPUT tt-dados-analise.nrperger,
                                             INPUT par_idseqttl,
                                             INPUT par_idorigem,
                                             INPUT par_nmdatela,
                                             INPUT aux_flgerlog,
                                             OUTPUT TABLE tt-erro).
  
     IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

     RUN valida-analise-proposta IN h-b1wgen0002(INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT aux_flgerlog,
                                                 INPUT ?, /* par_dtcnsspc  */
                                                 INPUT tt-dados-analise.nrinfcad,
                                                 INPUT ?, /* par_dtoutspc */
                                                 INPUT aux_dtdrisco,
                                                 INPUT aux_dtoutris,
                                                 INPUT tt-dados-analise.nrgarope,
                                                 INPUT tt-dados-analise.nrliquid,
                                                 INPUT tt-dados-analise.nrpatlvr,
                                                 INPUT tt-dados-analise.nrperger,
                                                 OUTPUT aux_nomcampo,
                                                 OUTPUT TABLE tt-erro).
  
     IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

     RUN monta_registros_proposta IN h-b1wgen0002(INPUT TABLE tt-aval-crapbem,
                                                  INPUT TABLE tt-faturam,
                                                  INPUT TABLE tt-crapbem,
                                                  INPUT TABLE tt-bens-alienacao,
                                                  INPUT TABLE tt-hipoteca,
                                                  INPUT TABLE tt-interv-anuentes,
                                                  INPUT TABLE tt-rendimento,
                                                  OUTPUT aux_dsdbeavt,
                                                  OUTPUT aux_dsdfinan,
                                                  OUTPUT aux_dsdrendi,
                                                  OUTPUT aux_dsdebens,
                                                  OUTPUT aux_dsdalien,
                                                  OUTPUT aux_dsinterv).                                                    

     IF NOT VALID-HANDLE(h-b1wgen0084) THEN
       RUN sistema/generico/procedures/b1wgen0084.p 
           PERSISTENT SET h-b1wgen0084.

     RUN calcula_emprestimo IN h-b1wgen0084(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_idorigem,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT FALSE,      /* par_flgerlog */
                                            INPUT 0,          /* par_nrctremp */
                                            INPUT par_cdlcremp,
                                            INPUT aux_vlsddisp, /*par_vlemprst,*/
                                            INPUT 1,
                                            INPUT par_dtmvtolt,
                                            INPUT par_dtdpagto,
                                            INPUT FALSE,      /*par_flggrava*/
                                            INPUT par_dtmvtolt,
                                            OUTPUT aux_qtdiacar,
                                            OUTPUT aux_vlajuepr,
                                            OUTPUT aux_txdiaria,
                                            OUTPUT aux_txmensal,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-parcelas-epr).

     IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

     FIND FIRST tt-parcelas-epr NO-LOCK NO-ERROR.
     IF AVAIL tt-parcelas-epr THEN
        DO:
        
            ASSIGN aux_vlpreemp = tt-parcelas-epr.vlparepr.
        END.
       


     /* Calcula o custo efetivo total */
     RUN calcula_cet_novo IN h-b1wgen0002 (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_dtmvtolt,
                                           INPUT par_nrdconta,
                                           INPUT tt-dados-assoc.inpessoa,
                                           INPUT 2, /* cdusolcr */
                                           INPUT par_cdlcremp,
                                           INPUT 1, /* tpemprst */
                                           INPUT 0, /* nrctremp */
                                           INPUT par_dtmvtolt,
                                           INPUT aux_vlpreemp, /*par_vlemprst*/
                                           INPUT aux_vlpreemp, /*par_vlparepr*/
                                           INPUT 1,            /*par_nrparepr*/
                                           INPUT par_dtdpagto, /*par_dtvencto*/
                                           INPUT 0, /* cdfinemp */
                                           OUTPUT aux_percetop,
                                           OUTPUT aux_txcetmes,
                                           OUTPUT TABLE tt-erro).

     IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
                                                  
     RUN grava-proposta-completa IN h-b1wgen0002 (
                        INPUT par_cdcooper, /* par_cdcooper INTE */
                        INPUT par_cdagenci, /* par_cdagenci INTE */
                        INPUT par_cdagenci, /* par_cdpactra INTE */
                        INPUT par_nrdcaixa, /* par_nrdcaixa INTE */
                        INPUT par_cdoperad, /* par_cdoperad CHAR */
                        INPUT par_nmdatela, /* par_nmdatela CHAR */
                        INPUT par_idorigem, /* par_idorigem INTE */
                        INPUT par_nrdconta, /* par_nrdconta INTE */
                        INPUT par_idseqttl, /* par_idseqttl INTE */
                        INPUT par_dtmvtolt, /* par_dtmvtolt DATE */
                        INPUT tt-dados-assoc.inpessoa, /* par_inpessoa INTE */
                        INPUT 0,            /* par_nrctremp */
                        INPUT 1,            /* par_tpemprst */
                        INPUT FALSE,        /* par_flgcmtlc */ 
                        INPUT aux_vlutiliz, /* par_vlutiliz DECI */
                        INPUT 0,            /* par_vllimapv */
                        INPUT "I",          /* par_cddopcao CHAR */
                        /*---Dados para a crawepr---*/
                        INPUT aux_vlsddisp, /*par_vlemprst,*/
                        INPUT 0,            /* par_vlpreant */
                        INPUT aux_vlpreemp,
                        INPUT 1,            /* par_qtpreemp */
                        INPUT tt-proposta-epr.nivrisco,
                        INPUT par_cdlcremp,
                        INPUT par_cdfinemp,
                        INPUT 0,            /* par_qtdialib */
                        INPUT FALSE,        /* par_flgimppr */
                        INPUT FALSE,        /* par_flgimpnp */
                        INPUT aux_percetop,
                        INPUT 1,            /* par_idquapro */
                        INPUT par_dtdpagto,
                        INPUT 1,            /* par_qtpromis */
                        INPUT FALSE,        /* par_flgpagto */
                        INPUT "",           /* par_dsctrliq */
                        INPUT 0,            /* par_nrctaava */
                        INPUT 0,            /* par_nrctaav2 */
                        /*-------Rating------ */
                        INPUT tt-dados-analise.nrgarope, /* par_nrgarope INTE */
                        INPUT tt-dados-analise.nrperger, /* par_nrperger INTE */
                        INPUT ?,                         /* par_dtcnsspc DATE */
                        INPUT tt-dados-analise.nrinfcad, /* par_nrinfcad INTE */
                        INPUT aux_dtdrisco,              /* par_dtdrisco DATE */
                        INPUT aux_vltotsfn,              /* par_vltotsfn DECI */
                        INPUT aux_qtopescr,              /* par_qtopescr INTE */
                        INPUT aux_qtifoper,              /* par_qtifoper INTE */
                        INPUT tt-dados-analise.nrliquid, /* par_nrliquid INTE */
                        INPUT aux_vlopescr,              /* par_vlopescr DECI */
                        INPUT aux_vlrpreju,              /* par_vlrpreju DECI */
                        INPUT tt-dados-analise.nrpatlvr, /* par_nrpatlvr INTE */
                        INPUT ?,                         /* par_dtoutspc DATE */
                        INPUT aux_dtoutris,              /* par_dtoutris DATE */
                        INPUT aux_vlsfnout,              /* par_vlsfnout DECI */
                        /* Dados Salario/Faturamento */
                        INPUT aux_vlsalari,              /* par_vlsalari DECI */
                        INPUT aux_vloutras,              /* par_vloutras DECI */
                        INPUT aux_vlalugue,              /* par_vlalugue DECI */ 
                        INPUT aux_vlsalcon,              /* par_vlsalcon DECI */
                        INPUT aux_nmempcje,              /* par_nmempcje CHAR */
                        INPUT aux_flgdocje,              /* par_flgdocje LOGI */
                        INPUT aux_nrctacje,              /* par_nrctacje INTE */
                        INPUT aux_nrcpfcje,              /* par_nrcpfcje DECI */
                        INPUT aux_perfatcl,              /* par_perfatcl DECI */
                        INPUT aux_vlmedfat,              /* par_vlmedfat DECI */
                        INPUT FALSE,                     /* par_inconcje LOGI */
                        INPUT FALSE,                     /* par_flgconsu LOGI */
                        INPUT "Transferencia a prejuizo",/* par_dsobserv CHAR */
                        INPUT aux_dsdfinan,              /* par_dsdfinan CHAR */
                        INPUT aux_dsdrendi,              /* par_dsdrendi CHAR */
                        INPUT aux_dsdebens,              /* par_dsdebens CHAR */
                        /*---------- Alienacao / Hipoteca -------------*/
                        INPUT aux_dsdalien,              /* par_dsdalien CHAR */
                        INPUT aux_dsinterv,              /* par_dsinterv CHAR */
                        INPUT tt-dados-coope.lssemseg,   /* par_lssemseg CHAR */
                        /*------------------ Parametros do Avalista 1 -------  */
                        INPUT "",                        /* par_nmdaval1 CHAR */
                        INPUT 0,                         /* par_nrcpfav1 DECI */
                        INPUT "",                        /* par_tpdocav1 CHAR */
                        INPUT "",                        /* par_dsdocav1 CHAR */
                        INPUT "",                        /* par_nmdcjav1 CHAR */
                        INPUT 0,                         /* par_cpfcjav1 DECI */
                        INPUT "",                        /* par_tdccjav1 CHAR */
                        INPUT "",                        /* par_doccjav1 CHAR */
                        INPUT "",                        /* par_ende1av1 CHAR */
                        INPUT "",                        /* par_ende2av1 CHAR */
                        INPUT "",                        /* par_nrfonav1 CHAR */
                        INPUT "",                        /* par_emailav1 CHAR */
                        INPUT "",                        /* par_nmcidav1 CHAR */
                        INPUT "",                        /* par_cdufava1 CHAR */
                        INPUT 0,                         /* par_nrcepav1 INTE */
                        INPUT 0,                         /* par_cdnacio1 CHAR */
                        INPUT 0,                         /* par_vledvmt1 DECI */
                        INPUT 0,                         /* par_vlrenme1 DECI */
                        INPUT 0,                         /* par_nrender1 INTE */
                        INPUT "",                        /* par_complen1 CHAR */
                        INPUT 0,                         /* par_nrcxaps1 INTE */
                        INPUT 0,                         /* par_inpesso1 INTE */
                        INPUT ?,                         /* par_dtnasct1 DATE */

                        /*------------------ Parametros do Avalista 2 -------  */
                        INPUT "",                        /* par_nmdaval2 CHAR */
                        INPUT 0,                         /* par_nrcpfav2 DECI */
                        INPUT "",                        /* par_tpdocav2 CHAR */
                        INPUT "",                        /* par_dsdocav2 CHAR */
                        INPUT "",                        /* par_nmdcjav2 CHAR */
                        INPUT 0,                         /* par_cpfcjav2 DECI */
                        INPUT "",                        /* par_tdccjav2 CHAR */
                        INPUT "",                        /* par_doccjav2 CHAR */
                        INPUT "",                        /* par_ende1av2 CHAR */
                        INPUT "",                        /* par_ende2av2 CHAR */
                        INPUT "",                        /* par_nrfonav2 CHAR */
                        INPUT "",                        /* par_emailav2 CHAR */
                        INPUT "",                        /* par_nmcidav2 CHAR */
                        INPUT "",                        /* par_cdufava2 CHAR */
                        INPUT 0,                         /* par_nrcepav2 INTE */
                        INPUT 0,                         /* par_cdnacio2 CHAR */
                        INPUT 0,                         /* par_vledvmt2 DECI */
                        INPUT 0,                         /* par_vlrenme2 DECI */
                        INPUT 0,                         /* par_nrender2 INTE */
                        INPUT "",                        /* par_complen2 CHAR */
                        INPUT 0,                         /* par_nrcxaps2 INTE */
                        INPUT 0,                         /* par_inpesso2 INTE */
                        INPUT ?,                         /* par_dtnasct2 DATE */

                        INPUT "",                        /* par_dsdbeavt CHAR */
                        INPUT aux_flgerlog,              /* par_flgerlog LOGI */
                        INPUT aux_dsjusren,              /* par_dsjusren CHAR */
                        INPUT par_dtmvtolt,              /* par_dtlibera DATE */
     
                       OUTPUT TABLE tt-erro,
                       OUTPUT TABLE tt-msg-confirma,
                       OUTPUT aux_recidepr,
                       OUTPUT nov_nrctremp,
                       OUTPUT aux_flmudfai).

     IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
     /*
     RUN grava_dados_lancamento_conta
                           (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_nmdatela,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,
                            INPUT tt-dados-assoc.inpessoa,
                            INPUT par_dtmvtolt,
                            INPUT nov_nrctremp,
                            INPUT par_cdlcremp,
                            INPUT aux_vlsddisp, /*par_vlemprst,*/
                            INPUT par_dtdpagto,
                            INPUT 0,
                            INPUT 0,
                            INPUT 0,
                            INPUT 1, /* par_qtpreemp */
                             INPUT aux_vlpreemp,
                            OUTPUT aux_vltarifa,
                            OUTPUT aux_vltaxiof,
                            OUTPUT aux_vltariof,
                            OUTPUT TABLE tt-erro).

     IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
     */

     
     RUN grava_efetivacao_proposta IN h-b1wgen0084(INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_dtmvtolt,
                                                   INPUT aux_flgerlog,
                                                   INPUT nov_nrctremp,
                                                   INPUT 0,  /*par_insitapr*/
                                                   INPUT "", /*par_dsobscmt*/
                                                   INPUT par_dtdpagto,
                                                   INPUT 0, /*par_cdbccxlt*/
                                                   INPUT 0, /*par_nrdolote*/
                                                   INPUT par_dtmvtopr,
                                                   INPUT 0, /*par_inproces*/
                                                   INPUT aux_vltarifa,
                                                   INPUT aux_vltaxiof,
                                                   INPUT aux_vltariof,
                                                   INPUT 0 , /*par_nrcpfope*/
                                                   OUTPUT aux_dsmesage,
                                                   OUTPUT TABLE tt-ratings,
                                                   OUTPUT TABLE tt-erro).



     IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".
     
    
    IF VALID-HANDLE(h-b1wgen0002) THEN
       DELETE PROCEDURE h-b1wgen0002.

    IF VALID-HANDLE(h-b1wgen0043) THEN
       DELETE PROCEDURE h-b1wgen0043.

    IF VALID-HANDLE(h-b1wgen0084) THEN
       DELETE PROCEDURE h-b1wgen0084.

      
    RETURN "OK".

END PROCEDURE. /* END grava_dados */


 PROCEDURE grava_dados_lancamento_conta PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoptfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO.
	  DEF  INPUT PARAM par_vlpreemp AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_vltottar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltaxiof AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltariof AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdpesqbb AS CHAR                                    NO-UNDO.
    /* Variaveis para IOF */
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgtaiof AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgimune AS LOGI                                    NO-UNDO.
    /* Variaveis para tarifa */
    DEF VAR aux_cdhistor AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisest AS INTE                                    NO-UNDO.
    DEF VAR aux_vlrtarif AS DECI                                    NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE                                    NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE                                    NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhistmp AS INTE                                    NO-UNDO.
    DEF VAR aux_cdfvltmp AS INTE                                    NO-UNDO.
    DEF VAR aux_cdlantar LIKE craplat.cdlantar                      NO-UNDO.
    DEF VAR aux_vltrfesp AS DECI                                    NO-UNDO.
    DEF VAR aux_datatual AS DATE                                    NO-UNDO.

    DEF VAR h-b1wgen0153 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0159 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0188 AS HANDLE                                  NO-UNDO.    

    ASSIGN aux_flgtrans = FALSE.

    TRANS_1: DO TRANSACTION ON ERROR  UNDO TRANS_1, LEAVE TRANS_1
                            ON ENDKEY UNDO TRANS_1, LEAVE TRANS_1:

        IF NOT VALID-HANDLE(h-b1wgen0153) THEN
           RUN sistema/generico/procedures/b1wgen0153.p 
               PERSISTENT SET h-b1wgen0153.

        RUN carrega_dados_tarifa_emprestimo IN h-b1wgen0153
                                                (INPUT  par_cdcooper,
                                                 INPUT  par_cdlcremp,
                                                 INPUT  "EM", /*par_cdmotivo*/
                                                 INPUT  par_inpessoa,
                                                 INPUT  par_vlemprst,
                                                 INPUT  par_nmdatela,
                                                 OUTPUT aux_cdhistor,
                                                 OUTPUT aux_cdhisest,
                                                 OUTPUT aux_vlrtarif,
                                                 OUTPUT aux_dtdivulg,
                                                 OUTPUT aux_dtvigenc,
                                                 OUTPUT aux_cdfvlcop,
                                                 OUTPUT TABLE tt-erro).

        IF RETURN-VALUE <> "OK"  THEN
           UNDO TRANS_1, LEAVE TRANS_1.

        ASSIGN aux_cdhistmp = aux_cdhistor
               aux_cdfvltmp = aux_cdfvlcop.

        RUN carrega_dados_tarifa_emprestimo IN h-b1wgen0153
                                            (INPUT  par_cdcooper,
                                             INPUT  par_cdlcremp,
                                             INPUT  "ES",
                                             INPUT  par_inpessoa,
                                             INPUT  par_vlemprst,
                                             INPUT  par_nmdatela,
                                             OUTPUT aux_cdhistor,
                                             OUTPUT aux_cdhisest,
                                             OUTPUT aux_vltrfesp,
                                             OUTPUT aux_dtdivulg,
                                             OUTPUT aux_dtvigenc,
                                             OUTPUT aux_cdfvlcop,
                                             OUTPUT TABLE tt-erro).

        IF RETURN-VALUE <> "OK"  THEN
           UNDO TRANS_1, LEAVE TRANS_1.

        IF aux_cdhistor = 0 AND aux_cdfvlcop = 0 THEN
           DO:
               ASSIGN aux_cdhistor = aux_cdhistmp
                      aux_cdfvlcop = aux_cdfvltmp.
           END.

        ASSIGN par_vltottar = aux_vlrtarif + aux_vltrfesp.
        IF par_vltottar > 0 THEN
           DO:
               IF par_idorigem = 3 THEN
                  ASSIGN aux_cdpesqbb = "INTERNET".
               ELSE 
                  IF par_idorigem = 4 THEN
                     ASSIGN aux_cdpesqbb = "CASH".

               RUN lan-tarifa-online 
                   IN h-b1wgen0153 (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdconta,
                                    INPUT 100,  /* par_cdbccxlt */
                                    INPUT 50003,/* par_nrdolote */
                                    INPUT 1,    /* par_tpdolote */
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_dtmvtolt, /* par_dtmvtlcm */
                                    INPUT par_nrdconta,
                                    INPUT STRING(par_nrdconta,"99999999"),
                                    INPUT aux_cdhistor,
                                    INPUT aux_cdpesqbb,
                                    INPUT 0,     /* par_cdbanchq */
                                    INPUT 0,     /* par_cdagechq */
                                    INPUT 0,     /* par_nrctachq */
                                    INPUT FALSE, /* par_flgaviso */
                                    INPUT 0,     /* par_tpdaviso */
                                    INPUT par_vltottar,
                                    INPUT par_nrctremp,
                                    /* Variaveis TAA */
                                    INPUT par_cdcoptfn,
                                    INPUT par_cdagetfn,
                                    INPUT par_nrterfin,
                                    INPUT 0,  /* par_nrsequni */
                                    INPUT 0,  /* par_nrautdoc */
                                    INPUT "", /* par_dsidenti */
                                    INPUT aux_cdfvlcop,
                                    INPUT 0,  /* par_inproces */
                                    OUTPUT aux_cdlantar,
                                    OUTPUT TABLE tt-erro).

               IF RETURN-VALUE <> "OK"  THEN
                  UNDO TRANS_1, LEAVE TRANS_1.

           END. /* IF par_vltottar > 0 */

        IF VALID-HANDLE(h-b1wgen0153)  THEN
           DELETE PROCEDURE h-b1wgen0153.        
    
    
        IF NOT VALID-HANDLE(h-b1wgen0188) THEN
           RUN sistema/generico/procedures/b1wgen0188.p 
               PERSISTENT SET h-b1wgen0188.
    
        /* Calcula o IOF */
        RUN calcula_iof IN h-b1wgen0188
                        (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT par_cdoperad,
                         INPUT par_nmdatela,
                         INPUT par_idorigem,
                         INPUT par_nrdconta,
                         INPUT par_cdlcremp,
                         INPUT par_vlemprst,
                         INPUT par_dtmvtolt,
                         INPUT par_qtpreemp,
                         INPUT par_dtdpagto,
						 INPUT par_vlpreemp,
                         OUTPUT par_vltaxiof,
                         OUTPUT par_vltariof,
                         OUTPUT TABLE tt-erro).

        IF RETURN-VALUE <> "OK" THEN
           UNDO TRANS_1, LEAVE TRANS_1.
        
        IF VALID-HANDLE(h-b1wgen0188)  THEN
           DELETE PROCEDURE h-b1wgen0188.

        /* Caso for imune, nao podemos cobrar IOF */
        IF par_vltariof > 0 THEN
           DO:
               DO WHILE TRUE:
        
                  FIND craplot 
                       WHERE craplot.cdcooper = par_cdcooper AND
                             craplot.dtmvtolt = par_dtmvtolt AND
                             craplot.cdagenci = 1            AND
                             craplot.cdbccxlt = 100          AND
                             craplot.nrdolote = 50002
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          
                  IF NOT AVAILABLE craplot THEN
                     IF LOCKED craplot THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                     ELSE
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                   craplot.cdagenci = 1
                                   craplot.cdbccxlt = 100
                                   craplot.nrdolote = 50002
                                   craplot.tplotmov = 1
                                   craplot.cdcooper = par_cdcooper.
                            VALIDATE craplot.
                        END.
          
                  LEAVE.
        
               END.  /*  Fim do DO WHILE TRUE  */
        
               CREATE craplcm.
               ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                      craplcm.cdagenci = craplot.cdagenci
                      craplcm.cdbccxlt = craplot.cdbccxlt
                      craplcm.nrdolote = craplot.nrdolote
                      craplcm.nrdconta = par_nrdconta
                      craplcm.nrdctabb = par_nrdconta
                      craplcm.nrdctitg = STRING(par_nrdconta,"99999999")
                      craplcm.nrdocmto = par_nrctremp
                      craplcm.cdhistor = 322
                      craplcm.nrseqdig = craplot.nrseqdig + 1
                      craplcm.cdpesqbb = 
                                 STRING(par_vlemprst,"zzz,zzz,zz9.99") + 
                                 STRING(par_vlemprst,"zzz,zzz,zz9.99") +
                                 STRING(0,"zzz,zzz,zz9.99")
                      craplcm.vllanmto = par_vltariof
                      craplcm.cdcooper = par_cdcooper
					            craplcm.cdcoptfn = par_cdcoptfn
			                craplcm.cdagetfn = par_cdagetfn
			                craplcm.nrterfin = par_nrterfin
					            craplcm.cdorigem = par_idorigem
                      craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
                      craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto
                      craplot.qtinfoln = craplot.qtinfoln + 1
                      craplot.qtcompln = craplot.qtcompln + 1
                      craplot.nrseqdig = craplot.nrseqdig + 1.
               VALIDATE craplcm.
        
               /* Atualiza IOF pago e base de calculo no crapcot */
               DO WHILE TRUE:
        
                  FIND crapcot 
                       WHERE crapcot.cdcooper = par_cdcooper AND
                             crapcot.nrdconta = par_nrdconta
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               
                  IF NOT AVAILABLE crapcot THEN
                     IF LOCKED crapcot THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                     ELSE
                        DO:
                            ASSIGN aux_cdcritic = 169
                                   aux_dscritic = "".
        
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            UNDO TRANS_1, RETURN "NOK".
        
                        END.
               
                  LEAVE.
               
               END.  /*  Fim do DO WHILE TRUE  */
        
               ASSIGN crapcot.vliofepr = 
                              crapcot.vliofepr + craplcm.vllanmto
                      crapcot.vlbsiepr = 
                              crapcot.vlbsiepr + par_vlemprst.

           END. /* END IF aux_vltxaiof > 0 THEN */

        ASSIGN aux_flgtrans = TRUE.

    END. /* END TRANS_1 */

    IF NOT aux_flgtrans THEN
       RETURN "NOK".

    RETURN "OK".

END PROCEDURE. /* END grava_dados_lancamento_conta */
