/*..............................................................................
 
   Programa: b1wgen0196.p
   Autora  : Odirlei Busana - AMcom.
   Data    : 21/03/2017                        Ultima atualizacao: 21/04/2019

   Dados referentes ao programa:

   Objetivo  : BO - Rotinas para geraçao de Cessao de Cartao de credito

   Alteracoes: 12/05/2017 - Passagem de 0 para a nacionalidade. (Jaison/Andrino)

               22/06/2017 - Ajuste para calcular o risco da operacao de acordo
                            com a quantidade de dias em atraso. (Anderson)

               15/12/2017 - Insercao do campo idcobope. PRJ404 (Lombardi)

	           12/10/2017 - Projeto 410 - passar como parametro da calcula_iof o
			                numero do contrato (Jean - Mout´s)

               21/11/2017 - Incluir campo cdcoploj e nrcntloj na chamada da rotina 
                            grava-proposta-completa. PRJ402 - Integracao CDC
                            (Reinert)						                  
							  
               24/01/2018 - Passagem de parametros nulos. (Jaison/James - PRJ298)
               
               12/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)

			   28/06/2018 - Ajustes projeto CDC. PRJ439 - CDC (Odirlei-AMcom)

               27/11/2018 - P410 - Ajuste nrseqdig na chamada pc_insere_iof ORACLE. (Douglas Pagel/AMcom)

               21/12/2018 - P298.2.2 - Apresentar pagamento na carencia (Adriano Nagasava - Supero)

               21/04/2019 - P450 - Cessao de Cartao deve ter Qualificacao 5-Cessao
                            (Guilherme/AMcom)

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
    DEF  INPUT PARAM par_dtvencto_ori AS DATE                       NO-UNDO.
    
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
    DEF VAR aux_vlprecar AS DECI                                    NO-UNDO.
    DEF VAR aux_qtdiacar AS INTE                                    NO-UNDO.
    DEF VAR aux_vlajuepr AS DECI                                    NO-UNDO.
    DEF VAR aux_txdiaria AS DECI                                    NO-UNDO.
    DEF VAR aux_txmensal AS DECI                                    NO-UNDO.
    DEF VAR aux_vlpreemp AS DECI                                    NO-UNDO.
    DEF VAR aux_percetop AS DECI                                    NO-UNDO.
    DEF VAR aux_txcetmes AS DECI                                    NO-UNDO.
    DEF VAR aux_qtdiaatr AS INTE                                    NO-UNDO.
    DEF VAR aux_inrisdia AS CHAR                                    NO-UNDO.


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
           aux_dstransa = "Gravacao cessao de credito".
           
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
  
     /* Calcular o Risco de acordo com a quantidade de dias em atraso */
     ASSIGN aux_qtdiaatr = par_dtmvtolt - par_dtvencto_ori
            aux_inrisdia = IF aux_qtdiaatr < 15 THEN
                              "A"
                           ELSE
                           IF aux_qtdiaatr <= 30 THEN
                              "B"
                           ELSE 
                           IF aux_qtdiaatr <= 60 THEN
                              "C"
                           ELSE
                           IF aux_qtdiaatr <= 90 THEN
                              "D"
                           ELSE
                           IF aux_qtdiaatr <= 120 THEN
                              "E"
                           ELSE
                           IF aux_qtdiaatr <= 150 THEN
                              "F"
                           ELSE
                           IF aux_qtdiaatr <= 180 THEN
                              "G"
                           ELSE
                              "H".
     
     /* Assume o pior risco */
     IF aux_inrisdia > tt-proposta-epr.nivrisco THEN
        ASSIGN tt-proposta-epr.nivrisco = aux_inrisdia.
  
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
                                             INPUT par_vlemprst,
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
                                             INPUT ?, /* par_idcarenc */
                                             INPUT ?, /* par_dtcarenc */
											                       INPUT 0, /* par_idfiniof */
                                             INPUT 5, /* par_idquapro */ /* cessao de cartao */
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
                                             OUTPUT aux_nivrisco,
                                             OUTPUT aux_vlprecar).

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
                                            INPUT par_cdfinemp,
                                            INPUT par_vlemprst,
                                            INPUT 1,
                                            INPUT par_dtmvtolt,
                                            INPUT par_dtdpagto,
                                            INPUT FALSE,      /*par_flggrava*/
                                            INPUT par_dtmvtolt,
                                            INPUT 0, /* idfiniof */
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
                                           INPUT "", /* dscatbem */
                                           INPUT 0,  /* idfiniof */
                                           INPUT "", /* dsctrliq */
                                           INPUT "N",
                                           INPUT ?, /*par_dtcarenc*/
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
                        INPUT par_vlemprst,
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
                        INPUT 5,            /* par_idquapro */ /* cessao de cartao */
                        INPUT par_dtdpagto,
                        INPUT 1,            /* par_qtpromis */
                        INPUT FALSE,        /* par_flgpagto */
                        INPUT "",           /* par_dsctrliq */
                        INPUT 0,            /* par_nrctaava */
                        INPUT 0,            /* par_nrctaav2 */
                        INPUT ?,            /* par_idcarenc */
                        INPUT ?,            /* par_dtcarenc */
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
                        INPUT "Cessao de credito",       /* par_dsobserv CHAR */
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
						INPUT 0,                        /* par_vlrecjg1 */

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
						INPUT 0,                         /* par_vlrecjg2 */

                        INPUT "",                        /* par_dsdbeavt CHAR */
                        INPUT aux_flgerlog,              /* par_flgerlog LOGI */
                        INPUT aux_dsjusren,              /* par_dsjusren CHAR */
                        INPUT par_dtmvtolt,              /* par_dtlibera DATE */
                        INPUT 0, /* idcobope */
                        /* INPUT 0,                         cdcoploj */
                        /* INPUT 0,                         nrcntloj */
                        INPUT 0,						 /* idfiniof */
						INPUT "",                        /* dscatbem */
						INPUT 1,
						INPUT "TP", /* par_dsdopcao */
                        INPUT 0,
                       OUTPUT TABLE tt-erro,
                       OUTPUT TABLE tt-msg-confirma,
                       OUTPUT aux_recidepr,
                       OUTPUT nov_nrctremp,
                       OUTPUT aux_flmudfai).

     IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

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
                            INPUT par_vlemprst,
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
                                                   /* calculo de tarifa sera
                                                     realizado na propria rotina
                                                   INPUT aux_vltarifa,
                                                   INPUT aux_vltaxiof,
                                                   INPUT aux_vltariof, */
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
    /* Variaveis para tarifa */
    DEF VAR aux_cdhistor AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisest AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisgar AS INTE                                    NO-UNDO.
    DEF VAR aux_vlrtarif AS DECI                                    NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE                                    NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE                                    NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhistmp AS INTE                                    NO-UNDO.
    DEF VAR aux_cdfvltmp AS INTE                                    NO-UNDO.
    DEF VAR aux_cdlantar LIKE craplat.cdlantar                      NO-UNDO.
    DEF VAR aux_vltrfesp AS DECI                                    NO-UNDO.
    DEF VAR aux_datatual AS DATE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_vltrfgar AS DECI                                    NO-UNDO.
    DEF VAR aux_vlpreclc AS DECI                                    NO-UNDO.
    DEF VAR aux_vliofpri AS DECI                                    NO-UNDO.
    DEF VAR aux_vliofadi AS DECI                                    NO-UNDO.
    DEF VAR aux_flgimune AS INTE                                    NO-UNDO.

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

        FIND crawepr WHERE crawepr.cdcooper = par_cdcooper AND 
                           crawepr.nrdconta = par_nrdconta AND 
                           crawepr.nrctremp = par_nrctremp 
                           NO-LOCK.
        IF NOT AVAIL crawepr THEN DO:
          
          ASSIGN aux_cdcritic = 535
                 aux_dscritic = "".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          UNDO TRANS_1, RETURN "NOK".
          
        END.

        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND craplcr.cdlcremp = par_cdlcremp NO-LOCK.
        IF NOT AVAIL craplcr THEN DO:
          ASSIGN aux_cdcritic = 363
                 aux_dscritic = "".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          UNDO TRANS_1, RETURN "NOK".
        END.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Efetuar a chamada a rotina Oracle */ 
        RUN STORED-PROCEDURE pc_calcula_tarifa
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper  /* Cooperativa conectada */
                                                ,INPUT par_nrdconta  /* Conta do associado */
                                                ,INPUT par_cdlcremp  /* Codigo da linha de credito do emprestimo. */
                                                ,INPUT par_vlemprst  /* Valor do emprestimo. */
                                                ,INPUT craplcr.cdusolcr  /* Codigo de uso da linha de credito (0-Normal/1-CDC/2-Boletos) */
                                                ,INPUT craplcr.tpctrato  /* Tipo de contrato utilizado por esta linha de credito. */
                                                ,INPUT ""  /* Relaçao de categoria de bens em garantia 
                                                                     Deve iniciar com o primeiro tipo de bem em garantia
                                                                     deve ser separado por |
                                                                     deve terminar com | */
                                                ,INPUT "IOF"         /* Nome do programa chamador */
                                                ,INPUT "N"           /* Envia e-mail S/N, se N interrompe o processo em caso de erro */
                                                ,INPUT crawepr.tpemprst  /* tipo de emprestimo */
                                                ,INPUT crawepr.idfiniof  /* financia iof */
                                                ,OUTPUT 0 /* Valor da tarifa calculada */
                                                ,OUTPUT 0 /* Valor da tarifa especial calculada */
                                                ,OUTPUT 0 /* Valor da tarifa garantia calculada */
                                                ,OUTPUT 0 /* Codigo do historico do lancamento. */
                                                ,OUTPUT 0 /* Codigo da faixa de valor por cooperativa. */
                                                ,OUTPUT 0 /* Codigo do historico de bens em garantia */
                                                ,OUTPUT 0 /* Código da faixa de valor dos bens em garantia */
                                                ,OUTPUT 0 /* Critica encontrada */
                                                ,OUTPUT ""). /* Texto de erro/critica encontrada */
           
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_calcula_tarifa
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_vlrtarif = 0
                aux_vltrfesp = 0
                aux_vltrfgar = 0
                par_vltottar = 0
                aux_vlrtarif = DECI(pc_calcula_tarifa.pr_vlrtarif) WHEN pc_calcula_tarifa.pr_vlrtarif <> ?
                aux_vltrfesp = DECI(pc_calcula_tarifa.pr_vltrfesp) WHEN pc_calcula_tarifa.pr_vltrfesp <> ?
                aux_vltrfgar = DECI(pc_calcula_tarifa.pr_vltrfgar) WHEN pc_calcula_tarifa.pr_vltrfgar <> ?
                aux_dscritic = pc_calcula_tarifa.pr_dscritic WHEN pc_calcula_tarifa.pr_dscritic <> ?.   
                aux_cdhistor = pc_calcula_tarifa.pr_cdhistor.
                aux_cdhisgar = pc_calcula_tarifa.pr_cdhisgar.

        IF aux_dscritic <> ""  THEN
           UNDO TRANS_1, LEAVE TRANS_1.

        IF aux_vlrtarif > 0 THEN DO:
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
                                INPUT aux_vlrtarif,
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

        END. /* IF aux_vlrtarif > 0 */
    
    
        IF aux_vltrfgar > 0 THEN DO:
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
                                INPUT aux_cdhisgar,
                                INPUT aux_cdpesqbb,
                                INPUT 0,     /* par_cdbanchq */
                                INPUT 0,     /* par_cdagechq */
                                INPUT 0,     /* par_nrctachq */
                                INPUT FALSE, /* par_flgaviso */
                                INPUT 0,     /* par_tpdaviso */
                                INPUT aux_vltrfgar,
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

        IF RETURN-VALUE <> "OK" THEN
           UNDO TRANS_1, LEAVE TRANS_1.
        
        END. /* IF aux_vltrfgar > 0 */

        IF VALID-HANDLE(h-b1wgen0153)  THEN
           DELETE PROCEDURE h-b1wgen0153.        
    
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND crapass.nrdconta = par_nrdconta NO-LOCK.
    
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
        /* Efetuar a chamada a rotina Oracle */ 
        RUN STORED-PROCEDURE pc_calcula_iof_epr
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                ,INPUT par_nrdconta
                                                ,INPUT par_nrctremp
                                                ,INPUT par_dtmvtolt
                                                ,INPUT crapass.inpessoa
                                                ,INPUT par_cdlcremp
                                                ,INPUT crawepr.cdfinemp
                                                ,INPUT crawepr.qtpreemp
                                                ,INPUT crawepr.vlpreemp
                                                ,INPUT par_vlemprst
                                                ,INPUT crawepr.dtdpagto
                                                ,INPUT crawepr.dtmvtolt
                                                ,INPUT crawepr.tpemprst
                                                ,INPUT ?
                                                ,INPUT 0
                                                ,INPUT ""
                                                ,INPUT crawepr.idfiniof
                                                ,INPUT ""
                                                ,INPUT "S" /* Gravar valor por parcela no cadastro de parcelas */
                                                ,OUTPUT 0
                                                ,OUTPUT 0
                                                ,OUTPUT 0
                                                ,OUTPUT 0
                                                ,OUTPUT 0
                                                ,OUTPUT "").
       
           
         /* Fechar o procedimento para buscarmos o resultado */ 
         CLOSE STORED-PROC pc_calcula_iof_epr
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

         ASSIGN aux_vlpreclc = 0
                aux_vliofpri = 0
                aux_vliofadi = 0
                aux_flgimune = 0
                par_vltottar = 0
                par_vltariof = 0
                par_vltariof = DECI(pc_calcula_iof_epr.pr_valoriof) WHEN pc_calcula_iof_epr.pr_valoriof <> ?
                aux_vlpreclc = DECI(pc_calcula_iof_epr.pr_vlpreclc) WHEN pc_calcula_iof_epr.pr_vlpreclc <> ?
                aux_vliofpri = DECI(pc_calcula_iof_epr.pr_vliofpri) WHEN pc_calcula_iof_epr.pr_vliofpri <> ?
                aux_vliofadi = DECI(pc_calcula_iof_epr.pr_vliofadi) WHEN pc_calcula_iof_epr.pr_vliofadi <> ?
                aux_dscritic = pc_calcula_iof_epr.pr_dscritic WHEN pc_calcula_iof_epr.pr_dscritic <> ?
                aux_flgimune = pc_calcula_iof_epr.pr_flgimune WHEN pc_calcula_iof_epr.pr_flgimune <> ?.   
                                  
         IF aux_dscritic <> ""  THEN
            UNDO TRANS_1, LEAVE TRANS_1.


        /* Caso for imune, nao podemos cobrar IOF */
        IF par_vltariof > 0 AND aux_flgimune = 0 THEN
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
        
		       /* Projeto 410 - verifica a linha de credito para definir o histórico de emprestimo / financiamento */
			   IF AVAIL craplcr then
			      if craplcr.dsoperac = "FINANCIAMENTO" then
				     ASSIGN aux_cdhistor = 2309.
				  else
				     ASSIGN aux_cdhistor = 2308.
                
				
               CREATE craplcm.
               ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                      craplcm.cdagenci = craplot.cdagenci
                      craplcm.cdbccxlt = craplot.cdbccxlt
                      craplcm.nrdolote = craplot.nrdolote
                      craplcm.nrdconta = par_nrdconta
                      craplcm.nrdctabb = par_nrdconta
                      craplcm.nrdctitg = STRING(par_nrdconta,"99999999")
                      craplcm.nrdocmto = par_nrctremp
                     /* craplcm.cdhistor = 322 */
					  craplcm.cdhistor = aux_cdhistor
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
        
              
              /* Projeto 410 - Gera lancamento de IOF complementar na TBGEN_IOF_LANCAMENTO - Jean (Mout´S) */
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
               RUN STORED-PROCEDURE pc_insere_iof
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* Código da cooperativa referente ao contrato de empréstimos */
                                                   ,INPUT par_nrdconta     /* Número da conta referente ao empréstimo */
                                                   ,INPUT craplot.dtmvtolt /* data de movimento */
                                                   ,INPUT 1                /* tipo de produto - 1 - Emprestimo */
                                                   ,INPUT par_nrctremp     /* Número do contrato de empréstimo */
                                                   ,INPUT ?                /* lancamento automatico */
                                                   ,INPUT craplot.dtmvtolt /* data de movimento LCM*/
                                                   ,INPUT craplot.cdagenci /* codigo da agencia  */
                                                   ,INPUT craplot.cdbccxlt /* Codigo caixa*/
                                                   ,INPUT craplot.nrdolote /* numero do lote */
                                                   ,INPUT craplot.nrseqdig /* sequencia do lote */
                                                   ,INPUT aux_vliofpri /* par_vltariof     iof principal */
                                                   ,INPUT aux_vliofadi                /* iof adicional */
                                                   ,INPUT 0                /* iof complementar */
                                                   ,INPUT aux_flgimune     /* flag IMUNE*/
                                                   ,OUTPUT 0               /* codigo da critica */
                                                   ,OUTPUT "").            /* Critica */
         
               /* Fechar o procedimento para buscarmos o resultado */ 
               CLOSE STORED-PROC pc_insere_iof

               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

               /* Se retornou erro */
               ASSIGN aux_cdcritic = 0
                      aux_cdcritic = INTE(pc_insere_iof.pr_cdcritic) WHEN pc_insere_iof.pr_cdcritic <> ?
                      aux_dscritic = ""
                      aux_dscritic = pc_insere_iof.pr_dscritic WHEN pc_insere_iof.pr_dscritic <> ?.
                
               IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                  DO:
                  
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    UNDO TRANS_1, RETURN "NOK".
                  END.
               
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
