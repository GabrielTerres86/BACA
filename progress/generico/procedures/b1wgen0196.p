/*..............................................................................

   Programa: b1wgen0196.p
   Autora  : Odirlei Busana - AMcom.
   Data    : 21/03/2017                        Ultima atualizacao: 21/03/2017

   Dados referentes ao programa:

   Objetivo  : BO - Rotinas para geraçao de Cessao de Cartao de credito

   Alteracoes:

 ..............................................................................*/

/*................................ DEFINICOES ................................*/

{ sistema/generico/includes/b1wgen0002tt.i  }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }  

DEF VAR h-b1wgen0002  AS HANDLE                                        NO-UNDO.


/*............................ PROCEDURES EXTERNAS ...........................*/

/******************************************************************************/
/**      Procedure para criar contrato de emprestimo de cessao de cartao     **/
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
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM nov_nrctremp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrgarope LIKE crapprp.nrgarope                      NO-UNDO.
    DEF VAR aux_nrliquid LIKE crapprp.nrliquid                      NO-UNDO.
    DEF VAR aux_nrpatlvr LIKE crapprp.nrpatlvr                      NO-UNDO.
    DEF VAR aux_nrinfcad LIKE crapprp.nrinfcad                      NO-UNDO.
    DEF VAR aux_nrperger LIKE crapprp.nrperger                      NO-UNDO.
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
    DEF VAR aux_idcarga  AS INTE                                    NO-UNDO.

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

    ASSIGN aux_nrinfcad = 1 /* Informacao Cadastral */
           aux_flgerlog = TRUE
           aux_flgtrans = FALSE
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gravacao pre-aprovado".

    GRAVA: DO TRANSACTION ON ERROR  UNDO GRAVA, LEAVE GRAVA
                          ON ENDKEY UNDO GRAVA, LEAVE GRAVA:
           
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
          UNDO GRAVA, LEAVE GRAVA.

       /* Dados gerais da cooperativa */
       FIND FIRST tt-dados-coope NO-LOCK NO-ERROR.
       /* Dados na crawepr */
       FIND FIRST tt-proposta-epr NO-LOCK NO-ERROR.
       /* Dados gerais do cooperado */
       FIND FIRST tt-dados-assoc NO-LOCK NO-ERROR.
       IF tt-dados-assoc.inpessoa = 1 THEN
          DO:
              ASSIGN aux_nrgarope = 10 /* Garantia */
                     aux_nrliquid = 9  /* Liquidez */
                     aux_nrpatlvr = 4  /* Patr. Pessoal livre  */
                     aux_nrperger = 0. /* Percepcao com relacao empresa */

              FOR crapttl FIELDS(nrinfcad nrpatlvr)
                          WHERE crapttl.cdcooper = par_cdcooper AND
                                crapttl.nrdconta = par_nrdconta AND
                                crapttl.idseqttl = 1
                                NO-LOCK: END.
              IF AVAIL crapttl THEN
                 DO:
                     IF crapttl.nrinfcad > 0 THEN
                        ASSIGN aux_nrinfcad = crapttl.nrinfcad.

                     IF crapttl.nrpatlvr > 0 THEN
                        ASSIGN aux_nrpatlvr = crapttl.nrpatlvr.
                 END.

          END. /* END IF tt-dados-assoc.inpessoa = 1 THEN */
       ELSE
          DO:
              ASSIGN aux_nrgarope = 11 /* Garantia */
                     aux_nrliquid = 11 /* Liquidez */
                     aux_nrpatlvr = 5  /* Patr. Pessoal livre  */
                     aux_nrperger = 1. /* Percepcao com relacao empresa */

              FOR crapjur FIELDS(nrinfcad nrpatlvr nrperger)
                          WHERE crapjur.cdcooper = par_cdcooper AND
                                crapjur.nrdconta = par_nrdconta 
                                NO-LOCK: END.
               
              IF AVAIL crapjur THEN
                 DO:
                     IF crapjur.nrinfcad > 0 THEN
                        ASSIGN aux_nrinfcad = crapjur.nrinfcad.

                     IF crapjur.nrpatlvr > 0 THEN
                        ASSIGN aux_nrpatlvr = crapjur.nrpatlvr.

                     IF crapjur.nrperger > 0 THEN
                        ASSIGN aux_nrperger = crapjur.nrperger.
                            
                 END.
          END.

        /* Busca a carga ativa */
        RUN busca_carga_ativa(INPUT par_cdcooper,
                              INPUT par_nrdconta,
                             OUTPUT aux_idcarga).
        /*  Caso nao possua carga ativa */
        IF  aux_idcarga = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nenhuma carga ativa.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        FOR crapcpa FIELDS(cdlcremp) WHERE crapcpa.cdcooper = par_cdcooper AND
                                           crapcpa.nrdconta = par_nrdconta AND
                                           crapcpa.iddcarga = aux_idcarga
                                           NO-LOCK: END.
        IF NOT AVAIL crapcpa THEN
           DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Associado nao cadastrado no pre-aprovado".

               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
               RETURN "NOK".
           END.
       
       /* Dados de parametrizacao do credito pre-aprovado */
        FOR crappre FIELDS(cdfinemp)
                   WHERE crappre.cdcooper = par_cdcooper            AND
                         crappre.inpessoa = tt-dados-assoc.inpessoa
                         NO-LOCK: END.

       IF NOT AVAIL crappre THEN
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Parametros pre-aprovado nao cadastrado".
           
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
              RETURN "NOK".
          END.

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
                     aux_dsjusren = tt-rendimento.dsjusren.

              IF tt-rendimento.perfatcl = 0 THEN
                 ASSIGN aux_perfatcl = 15.
              ELSE
                 ASSIGN aux_perfatcl = tt-rendimento.perfatcl.
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
                                               INPUT crapcpa.cdlcremp,
                                               INPUT 1, /* par_qtpreemp */
                                               INPUT "",   /* par_dsctrliq */
                                               INPUT tt-dados-coope.vlmaxutl,
                                               INPUT tt-dados-coope.vlmaxleg,
                                               INPUT tt-dados-coope.vlcnsscr,
                                               INPUT par_vlemprst,
                                               INPUT par_dtdpagto,
                                               INPUT 1,    /* par_inconfir */
                                               INPUT 1,    /* par_tpaltera */
                                               INPUT tt-dados-assoc.cdempres,
                                               INPUT FALSE,/* par_flgpagto */
                                               INPUT ?,    /* par_dtdpagt2 */
                                               INPUT 0,    /* par_ddmesnov */
                                               INPUT crappre.cdfinemp,
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
          UNDO GRAVA, LEAVE GRAVA.
    
       RUN valida-itens-rating IN h-b1wgen0043(INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT par_nrdconta,
                                               INPUT aux_nrgarope,
                                               INPUT aux_nrinfcad,
                                               INPUT aux_nrliquid,
                                               INPUT aux_nrpatlvr,
                                               INPUT aux_nrperger,
                                               INPUT par_idseqttl,
                                               INPUT par_idorigem,
                                               INPUT par_nmdatela,
                                               INPUT aux_flgerlog,
                                               OUTPUT TABLE tt-erro).
    
       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVA, LEAVE GRAVA.
    
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
                                                   INPUT aux_nrinfcad,
                                                   INPUT ?, /* par_dtoutspc */
                                                   INPUT aux_dtdrisco,
                                                   INPUT aux_dtoutris,
                                                   INPUT aux_nrgarope,
                                                   INPUT aux_nrliquid,
                                                   INPUT aux_nrpatlvr,
                                                   INPUT aux_nrperger,
                                                   OUTPUT aux_nomcampo,
                                                   OUTPUT TABLE tt-erro).
    
       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVA, LEAVE GRAVA.
    
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
                                              INPUT par_vlemprst,
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
  
       IF VALID-HANDLE(h-b1wgen0084) THEN
         DELETE PROCEDURE h-b1wgen0084.


       /* Calcula o custo efetivo total */
       RUN calcula_cet_novo IN h-b1wgen0002 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_dtmvtolt,
                                             INPUT par_nrdconta,
                                             INPUT crapass.inpessoa,
                                             INPUT 2, /* cdusolcr */
                                             INPUT par_cdlcremp,
                                             INPUT 1, /* tpemprst */
                                             INPUT 0, /* nrctremp */
                                             INPUT par_dtmvtolt,
                                             INPUT aux_vlpreemp, /*par_vlemprst*/
                                             INPUT aux_vlpreemp, /*par_vlparepr*/
                                             INPUT 1,            /*par_nrparepr*/
                                             INPUT par_dtvencto,
                                             INPUT 0, /* cdfinemp */
                                             OUTPUT aux_percetop,
                                             OUTPUT aux_txcetmes,
                                             OUTPUT TABLE tt-erro).

       IF RETURN-VALUE <> "OK" THEN
          RETURN "NOK".
                                                    

       RUN grava-proposta-completa IN h-b1wgen0002(INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
												                           INPUT par_cdagenci, /*par_cdpactra*/
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_dtmvtolt,
                                                   INPUT tt-dados-assoc.inpessoa,
                                                   INPUT 0, /* par_nrctremp */
                                                   INPUT 1, /* par_tpemprst */
                                                   INPUT FALSE, /* par_flgcmtlc */
                                                   INPUT aux_vlutiliz,
                                                   INPUT 0, /* par_vllimapv */
                                                   INPUT "I",
                                                   /*---Dados para a crawepr---*/
                                                   INPUT par_vlemprst,
                                                   INPUT 0, /* par_vlpreant */
                                                   INPUT aux_vlpreemp,
                                                   INPUT 1, /* par_qtpreemp */
                                                   INPUT tt-proposta-epr.nivrisco,
                                                   INPUT crapcpa.cdlcremp,
                                                   INPUT crappre.cdfinemp,
                                                   INPUT 0, /* par_qtdialib */
                                                   INPUT FALSE, /* par_flgimppr */
                                                   INPUT FALSE, /* par_flgimpnp */
                                                   INPUT aux_percetop,
                                                   INPUT 1, /* par_idquapro */
                                                   INPUT par_dtdpagto,
                                                   INPUT 1, /* par_qtpromis */
                                                   INPUT FALSE, /* par_flgpagto */
                                                   INPUT "", /* par_dsctrliq */
                                                   INPUT 0,  /* par_nrctaava */
                                                   INPUT 0,  /* par_nrctaav2 */
                                                   /*-------Rating------ */
                                                   INPUT aux_nrgarope,
                                                   INPUT aux_nrperger,
                                                   INPUT ?, /* par_dtcnsspc */
                                                   INPUT aux_nrinfcad,
                                                   INPUT aux_dtdrisco,
                                                   INPUT aux_vltotsfn,
                                                   INPUT aux_qtopescr,
                                                   INPUT aux_qtifoper,
                                                   INPUT aux_nrliquid,
                                                   INPUT aux_vlopescr,
                                                   INPUT aux_vlrpreju,
                                                   INPUT aux_nrpatlvr,
                                                   INPUT ?, /* par_dtoutspc */
                                                   INPUT aux_dtoutris,
                                                   INPUT aux_vlsfnout,
                                                   /* Dados Salario/Faturamento */
                                                   INPUT aux_vlsalari,
                                                   INPUT aux_vloutras,
                                                   INPUT aux_vlalugue,
                                                   INPUT aux_vlsalcon,
                                                   INPUT aux_nmempcje,
                                                   INPUT aux_flgdocje,
                                                   INPUT aux_nrctacje,
                                                   INPUT aux_nrcpfcje,
                                                   INPUT aux_perfatcl,
                                                   INPUT aux_vlmedfat,
                                                   INPUT FALSE,
                                                   INPUT FALSE,
                                                   /* par_dsobserv */
                                                   INPUT "Credito Pre-Aprovado",
                                                   INPUT aux_dsdfinan,
                                                   INPUT aux_dsdrendi,
                                                   INPUT aux_dsdebens,
                                                   /* Alienacao */
                                                   INPUT aux_dsdalien,
                                                   INPUT aux_dsinterv,
                                                   INPUT tt-dados-coope.lssemseg,
                                                   /* Avalista 1 */
                                                   INPUT "", /* par_nmdaval1 */
                                                   INPUT 0,  /* par_nrcpfav1 */
                                                   INPUT "", /* par_tpdocav1 */
                                                   INPUT "", /* par_dsdocav1 */
                                                   INPUT "", /* par_nmdcjav1 */
                                                   INPUT 0,  /* par_cpfcjav1 */
                                                   INPUT "", /* par_tdccjav1 */
                                                   INPUT "", /* par_doccjav1 */
                                                   INPUT "", /* par_ende1av1 */
                                                   INPUT "", /* par_ende2av1 */
                                                   INPUT "", /* par_nrfonav1 */
                                                   INPUT "", /* par_emailav1 */
                                                   INPUT "", /* par_nmcidav1 */
                                                   INPUT "", /* par_cdufava1 */
                                                   INPUT 0,  /* par_nrcepav1 */
                                                   INPUT "", /* par_dsnacio1 */
                                                   INPUT 0,  /* par_vledvmt1 */
                                                   INPUT 0,  /* par_vlrenme1 */
                                                   INPUT 0,  /* par_nrender1 */
                                                   INPUT "", /* par_complen1 */
                                                   INPUT 0,  /* par_nrcxaps1 */
                                                   INPUT 0,
                                                   INPUT ?,
                                                   /* Avalista 2 */
                                                   INPUT "", /* aux_nmdaval2 */
                                                   INPUT 0,  /* aux_nrcpfav2 */
                                                   INPUT "", /* aux_tpdocav2 */
                                                   INPUT "", /* aux_dsdocav2 */
                                                   INPUT "", /* aux_nmdcjav2 */
                                                   INPUT 0,  /* aux_cpfcjav2 */
                                                   INPUT "", /* aux_tdccjav2 */
                                                   INPUT "", /* aux_doccjav2 */
                                                   INPUT "", /* aux_ende1av2 */
                                                   INPUT "", /* aux_ende2av2 */
                                                   INPUT "", /* aux_nrfonav2 */
                                                   INPUT "", /* aux_emailav2 */
                                                   INPUT "", /* aux_nmcidav2 */
                                                   INPUT "", /* aux_cdufava2 */
                                                   INPUT 0,  /* aux_nrcepav2 */
                                                   INPUT "", /* aux_dsnacio2 */
                                                   INPUT 0,  /* aux_vledvmt2 */
                                                   INPUT 0,  /* aux_vlrenme2 */
                                                   INPUT 0,  /* aux_nrender2 */
                                                   INPUT "", /* aux_complen2 */
                                                   INPUT 0,  /* aux_nrcxaps2 */
                                                   INPUT 0,
                                                   INPUT ?,
                                                   INPUT "",
                                                   INPUT aux_flgerlog,
                                                   INPUT aux_dsjusren,
                                                   INPUT par_dtmvtolt,
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-msg-confirma,
                                                   OUTPUT aux_recidepr,
                                                   OUTPUT nov_nrctremp,
                                                   OUTPUT aux_flmudfai).

       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVA, LEAVE GRAVA.

       RUN grava_dados_conta (INPUT par_cdcooper,
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
                              INPUT crapcpa.cdlcremp,
                              INPUT par_vlemprst,
                              INPUT par_dtdpagto,
                              INPUT 0,
                              INPUT 0,
                              INPUT 0,
                              OUTPUT aux_vltarifa,
                              OUTPUT aux_vltaxiof,
                              OUTPUT aux_vltariof,
                              OUTPUT TABLE tt-erro).

       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVA, LEAVE GRAVA.

       RUN grava_efetivacao_proposta IN h-b1wgen0084(INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_cdoperad,
                                                     INPUT "CMAPRV", /*par_nmdatela*/
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
          UNDO GRAVA, LEAVE GRAVA.

       ASSIGN aux_flgtrans = TRUE.

    END. /* END GRAVA: DO TRANSACTION */

    IF NOT TEMP-TABLE tt-erro:HAS-RECORDS AND
       (aux_cdcritic > 0 OR aux_dscritic <> "") THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
       END.

    FIND FIRST tt-erro EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL tt-erro THEN
       DO:
           /* Gera Log */
           RUN proc_gerar_log (INPUT par_cdcooper,
                               INPUT par_cdoperad,
                               INPUT SUBSTR(tt-erro.dscritic,1,65),
                               INPUT aux_dsorigem,
                               INPUT aux_dstransa,
                               INPUT FALSE,
                               INPUT par_idseqttl,
                               INPUT par_nmdatela,
                               INPUT par_nrdconta,
                              OUTPUT aux_nrdrowid).
           
           ASSIGN tt-erro.cdcritic = 0
                  tt-erro.dscritic = "Nao foi possivel concluir sua "     +
                                     "solicitacao. Dirija-se a um Posto " +
                                     "de Atendimento".

       END. /* END IF AVAIL tt-erro THEN */

    IF VALID-HANDLE(h-b1wgen0002) THEN
       DELETE PROCEDURE h-b1wgen0002.

    IF VALID-HANDLE(h-b1wgen0043) THEN
       DELETE PROCEDURE h-b1wgen0043.

    IF VALID-HANDLE(h-b1wgen0084) THEN
       DELETE PROCEDURE h-b1wgen0084.

    IF NOT aux_flgtrans THEN
       RETURN "NOK".
    
    RETURN "OK".

END PROCEDURE. /* END grava_dados */


 