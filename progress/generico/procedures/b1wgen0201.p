/*..............................................................................

    Programa  : b1wgen0201.p
    Autor     : Lucas Reinert
    Data      : Novembro/2017                Ultima Atualizacao: 21/03/2019
    
    Dados referentes ao programa:

    Objetivo  : BO ref. Rotina integracao CDC

    Alteracoes: 19/10/2018 - P442 - Inclusao de opcao OUTROS VEICULOS onde ha procura por CAMINHAO (Marcos-Envolti)
                
                21/03/2019 - P437 - Consignado - Inclusao dos parametros par_vlpreempi e par_vlrdoiof 
                             na chamada da rotina valida-dados-gerais - Josiane Stiehler - AMcom
 
..............................................................................*/

/*................................ DEFINICOES ............................... */
{ sistema/generico/includes/b1wgen0188tt.i  }
{ sistema/generico/includes/b1wgen0002tt.i  }
{ sistema/generico/includes/b1wgen0024tt.i  }
{ sistema/generico/includes/b1wgen0038tt.i  }
{ sistema/generico/includes/b1wgen0043tt.i  }
{ sistema/generico/includes/b1wgen0056tt.i  }
{ sistema/generico/includes/b1wgen0069tt.i  }
{ sistema/generico/includes/b1wgen0084tt.i  }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/b1wgen0201tt.i  }
{ sistema/generico/includes/b1wgen9999tt.i  }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_des_reto AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF TEMP-TABLE tt-tipo-rendi                                           NO-UNDO
    FIELD tpdrendi  AS INTE
    FIELD dsdrendi  AS CHAR.

DEF TEMP-TABLE tt-aval-crapbem                                         NO-UNDO
    LIKE tt-crapbem
    USE-INDEX crapbem2 USE-INDEX tt-crapbem AS PRIMARY.

PROCEDURE integra_proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_nrdconta AS DECI                           NO-UNDO.    
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpemprst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlliqemp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vliofepr AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_percetop AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlpreemp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgimppr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdalien AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    /* Indica se permite reiniciar fluxo de aprovaçao */
    DEF  INPUT PARAM par_inresapr AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdcoploj AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaloj AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsvended AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgdocje AS LOGI                           NO-UNDO.
    
    DEF INPUT-OUTPUT PARAM par_nrctremp AS DECI                     NO-UNDO.
    DEF OUTPUT PARAM par_dsjsonan AS LONGCHAR                       NO-UNDO.
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
    DEF VAR aux_dsmesage AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlutiliz AS DECI                                    NO-UNDO.
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
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_dsbensal AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdregis AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsmensag AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgsenha AS INTE                                    NO-UNDO.
    
    /** ------------------- Variáveis do 1 avalista -------------------- **/    
    DEF VAR aux_nrctaava AS INTE                                    NO-UNDO.
    DEF VAR aux_nmdaval1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfav1 AS DECI                                    NO-UNDO.
    DEF VAR aux_tpdocav1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdocav1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdcjav1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_cpfcjav1 AS DECI                                    NO-UNDO.
    DEF VAR aux_tdccjav1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_doccjav1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_ende1av1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_ende2av1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrfonav1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_emailav1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmcidav1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdufava1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcepav1 AS INTE                                    NO-UNDO.
    DEF VAR aux_cdnacio1 AS INTE                                    NO-UNDO.
    DEF VAR aux_vledvmt1 AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrenme1 AS DECI                                    NO-UNDO.
    DEF VAR aux_nrender1 AS INTE                                    NO-UNDO.
    DEF VAR aux_complen1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcxaps1 AS INTE                                    NO-UNDO.
    DEF VAR aux_inpesso1 AS INTE                                    NO-UNDO.
    DEF VAR aux_dtnasct1 AS DATE                                    NO-UNDO.
    
    /** ------------------- Variáveis do 2 avalista -------------------- **/
    DEF VAR aux_nrctaav2 AS INTE                                    NO-UNDO.
    DEF VAR aux_nmdaval2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfav2 AS DECI                                    NO-UNDO.
    DEF VAR aux_tpdocav2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdocav2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdcjav2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_cpfcjav2 AS DECI                                    NO-UNDO.
    DEF VAR aux_tdccjav2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_doccjav2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_ende1av2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_ende2av2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrfonav2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_emailav2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmcidav2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdufava2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcepav2 AS INTE                                    NO-UNDO.
    DEF VAR aux_cdnacio2 AS INTE                                    NO-UNDO.
    DEF VAR aux_vledvmt2 AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrenme2 AS DECI                                    NO-UNDO.
    DEF VAR aux_nrender2 AS INTE                                    NO-UNDO.
    DEF VAR aux_complen2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcxaps2 AS INTE                                    NO-UNDO.
    DEF VAR aux_inpesso2 AS INTE                                    NO-UNDO.
    DEF VAR aux_dtnasct2 AS DATE                                    NO-UNDO.
    DEF VAR aux_dsjsonan AS LONGCHAR                                NO-UNDO.
    

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.

    IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p 
           PERSISTENT SET h-b1wgen0002.

    ASSIGN aux_nrinfcad = 1 /* Informacao Cadastral */
           aux_flgerlog = TRUE
           aux_flgtrans = FALSE
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Integracao proposta CDC".

    GRAVAINTCDC: DO TRANSACTION ON ERROR  UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC
                                ON ENDKEY UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC:

       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       /* Efetuar a chamada a rotina Oracle */ 
       RUN STORED-PROCEDURE pc_valida_dados_proposta
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_tpemprst,
                                             INPUT par_cdlcremp,
                                             INPUT par_cdfinemp,
                                             INPUT par_dsdalien,
                                             OUTPUT "",
                                             OUTPUT 0,
                                             OUTPUT "").
       
       /* Fechar o procedimento para buscarmos o resultado */ 
       CLOSE STORED-PROC pc_valida_dados_proposta
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

       ASSIGN aux_dsbensal = pc_valida_dados_proposta.pr_dsbensal_out
                                WHEN pc_valida_dados_proposta.pr_dsbensal_out <> ?           
              aux_dscritic = pc_valida_dados_proposta.pr_dscritic
                                WHEN pc_valida_dados_proposta.pr_dscritic <> ?.           

       IF aux_dscritic <> "" THEN
          UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC.
          
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
                           INPUT par_nrctremp,    /* par_nrctremp */
                           INPUT par_cddopcao,  /* par_cddopcao */
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
          UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC.

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
					 
					 /*rating*/
                     aux_nrgarope = tt-dados-analise.nrgarope.
                     aux_nrliquid = tt-dados-analise.nrliquid.
                     aux_nrpatlvr = tt-dados-analise.nrpatlvr.
                     aux_nrperger = tt-dados-analise.nrperger.
                     aux_nrinfcad = tt-dados-analise.nrinfcad.
          END.
          
       FOR EACH tt-dados-avais NO-LOCK BY tt-dados-avais.idavalis:
       
          IF  tt-dados-avais.idavalis = 1 THEN
              DO:
                FOR FIRST crapnac 
                   FIELDS(cdnacion)
                    WHERE CAPS(crapnac.dsnacion) = CAPS(tt-dados-avais.dsnacion)
                  NO-LOCK:
                    ASSIGN aux_cdnacio1 = crapnac.cdnacion.
                END.
                
                IF NOT AVAIL crapnac THEN
                  ASSIGN aux_cdnacio1 = 42. /* Se nao encontrar nacionalidade assumimos como BRASILEIRA */              
                  
                ASSIGN aux_nrctaava = tt-dados-avais.nrctaava
                       aux_nmdaval1 = tt-dados-avais.nmdavali
                       aux_nrcpfav1 = tt-dados-avais.nrcpfcgc
                       aux_tpdocav1 = tt-dados-avais.tpdocava
                       aux_dsdocav1 = tt-dados-avais.nrdocava
                       aux_nmdcjav1 = tt-dados-avais.nmconjug
                       aux_cpfcjav1 = tt-dados-avais.nrcpfcjg
                       aux_tdccjav1 = tt-dados-avais.tpdoccjg
                       aux_doccjav1 = tt-dados-avais.nrdoccjg
                       aux_ende1av1 = tt-dados-avais.dsendre1
                       aux_ende2av1 = tt-dados-avais.dsendre2
                       aux_nrfonav1 = tt-dados-avais.nrfonres
                       aux_emailav1 = tt-dados-avais.dsdemail
                       aux_nmcidav1 = tt-dados-avais.nmcidade
                       aux_cdufava1 = tt-dados-avais.cdufresd
                       aux_nrcepav1 = tt-dados-avais.nrcepend
                       aux_vledvmt1 = tt-dados-avais.vledvmto
                       aux_vlrenme1 = tt-dados-avais.vlrenmes
                       aux_nrender1 = tt-dados-avais.nrendere
                       aux_complen1 = tt-dados-avais.complend
                       aux_nrcxaps1 = tt-dados-avais.nrcxapst
                       aux_inpesso1 = tt-dados-avais.inpessoa
                       aux_dtnasct1 = tt-dados-avais.dtnascto.
              
              END.
          ELSE
              DO:
                FOR FIRST crapnac 
                   FIELDS(cdnacion)
                    WHERE CAPS(crapnac.dsnacion) = CAPS(tt-dados-avais.dsnacion)
                  NO-LOCK:
                    ASSIGN aux_cdnacio2 = crapnac.cdnacion.
                END.
                
                IF NOT AVAIL crapnac THEN
                  ASSIGN aux_cdnacio2 = 42. /* Se nao encontrar nacionalidade assumimos como BRASILEIRA */              
                  
                ASSIGN aux_nrctaav2 = tt-dados-avais.nrctaava
                       aux_nmdaval2 = tt-dados-avais.nmdavali
                       aux_nrcpfav2 = tt-dados-avais.nrcpfcgc
                       aux_tpdocav2 = tt-dados-avais.tpdocava
                       aux_dsdocav2 = tt-dados-avais.nrdocava
                       aux_nmdcjav2 = tt-dados-avais.nmconjug
                       aux_cpfcjav2 = tt-dados-avais.nrcpfcjg
                       aux_tdccjav2 = tt-dados-avais.tpdoccjg
                       aux_doccjav2 = tt-dados-avais.nrdoccjg
                       aux_ende1av2 = tt-dados-avais.dsendre1
                       aux_ende2av2 = tt-dados-avais.dsendre2
                       aux_nrfonav2 = tt-dados-avais.nrfonres
                       aux_emailav2 = tt-dados-avais.dsdemail
                       aux_nmcidav2 = tt-dados-avais.nmcidade
                       aux_cdufava2 = tt-dados-avais.cdufresd
                       aux_nrcepav2 = tt-dados-avais.nrcepend
                       aux_vledvmt2 = tt-dados-avais.vledvmto
                       aux_vlrenme2 = tt-dados-avais.vlrenmes
                       aux_nrender2 = tt-dados-avais.nrendere
                       aux_complen2 = tt-dados-avais.complend
                       aux_nrcxaps2 = tt-dados-avais.nrcxapst
                       aux_inpesso2 = tt-dados-avais.inpessoa
                       aux_dtnasct2 = tt-dados-avais.dtnascto.
              
              END.
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
                                               INPUT par_cddopcao,  /* par_cddopcao */
                                               INPUT 0,    /* par_inproces */
                                               INPUT tt-dados-assoc.cdagenci,
                                               INPUT par_nrctremp,    /* par_nrctremp */
                                               INPUT par_cdlcremp,
                                               INPUT par_qtpreemp,
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
                                               INPUT par_tpemprst,
                                               INPUT par_dtmvtolt,
                                               INPUT 30,   /* par_inconfi2 */
                                               INPUT 0,
                                               INPUT "", /* cdmodali */
                                               INPUT  0, /*par_idcarenc*/
                                               INPUT ?, /*par_dtcarenc*/
                                               INPUT 1, /*par_idfiniof*/
											                         INPUT 1, /*par_idquapro*/
                                               INPUT 0, /*par_vlpreempi*/
                                               INPUT -1, /*par_vlrdoiof*/
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
          UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC.
    
       /* Limpar temp-table de bens alienados, utilizaremos somente os bens enviados pela Ibratan */
       EMPTY TEMP-TABLE tt-bens-alienacao.
       
       /* Bens alienados separados por pipe */
       DO aux_contador = 1 TO NUM-ENTRIES(aux_dsbensal,"|"):
           
          ASSIGN aux_dsdregis = ENTRY(aux_contador,aux_dsbensal,"|").

          IF   aux_dsdregis = ""   THEN
               NEXT.                      
    
          CREATE tt-bens-alienacao.
          ASSIGN tt-bens-alienacao.lsbemfin =
                            "( " + STRING(aux_contador,"z9") + "º Bem )"
                 tt-bens-alienacao.dscatbem = ENTRY(1,aux_dsdregis,";")
                 tt-bens-alienacao.dsbemfin = ENTRY(2,aux_dsdregis,";")
                 tt-bens-alienacao.dscorbem = ENTRY(3,aux_dsdregis,";")
                 tt-bens-alienacao.dschassi = ENTRY(5,aux_dsdregis,";")
                 tt-bens-alienacao.nranobem = INTE(ENTRY(6,aux_dsdregis,";"))
                 tt-bens-alienacao.nrmodbem = INTE(ENTRY(7,aux_dsdregis,";"))
                 tt-bens-alienacao.nrdplaca = ENTRY(8,aux_dsdregis,";")
                 tt-bens-alienacao.nrrenava = DECI(ENTRY(9,aux_dsdregis,";"))
                 tt-bens-alienacao.tpchassi = INTE(ENTRY(10,aux_dsdregis,";"))
                 tt-bens-alienacao.ufdplaca = ENTRY(11,aux_dsdregis,";")
                 tt-bens-alienacao.vlmerbem = DECI(ENTRY(4,aux_dsdregis,";"))
                 tt-bens-alienacao.uflicenc = ENTRY(13,aux_dsdregis,";")
                 tt-bens-alienacao.idseqbem = INTE(ENTRY(15,aux_dsdregis,";"))
                 tt-bens-alienacao.dstipbem = ENTRY(14,aux_dsdregis,";")
                 tt-bens-alienacao.idalibem = aux_contador
                 tt-bens-alienacao.nrcpfbem = DECI(ENTRY(12,aux_dsdregis,";")).

                 
          /* 
          AQUI TEMOS QUE BUSCAR PELO O BEM DE ALIENACAO PARA ALTERAR O CAMPO IDSEQBEM
          COMO O AYLLOS MANTEM NA TABELA OS BENS (CRAPBEM) DO COOPERADO O IDSEQBEM ENVIADO PELA A IBRATAN
          SERA SEMPRE DIFERENTE DO QUE MANTEMOS NO AYLLOS, DESTA FORMA TEMOS QUE CRIAR ESTE PALIATIVO PARA MANIPULAR O CAMPO.
          NO CDC SEMPRE SERA UM UNICO BEM ALIENADO POR PROPOSTA, COM ISSO REALIZAMOS ESSA BUSCA PARA NAO CUSTOMIZAR O SISTEMA
          POR CONTA DESTA FALHA DE INTEGRACAO. (PJ402 E PJ439)
          */
          
          /*se for alteracao pegamos o campo para tratar na base conforme descrito acima*/
          IF  par_cddopcao="A" THEN
            DO:

              FIND FIRST crapbpr WHERE crapbpr.cdcooper = par_cdcooper
                                   AND crapbpr.nrdconta = par_nrdconta
                                   AND crapbpr.nrctrpro = par_nrctremp
                                   AND crapbpr.tpctrpro = 90
                                   AND crapbpr.flgalien = TRUE   NO-LOCK NO-ERROR.
                               
                IF AVAIL crapbpr THEN
                  DO:
                    ASSIGN tt-bens-alienacao.idseqbem = crapbpr.idseqbem.
                  END.
          END. /* fim do IF de alteracao */

          IF CAN-DO("MOTO,AUTOMOVEL,CAMINHAO,OUTROS VEICULOS",TRIM(CAPS(tt-bens-alienacao.dscatbem))) THEN
            DO:
               RUN valida-dados-alienacao IN h-b1wgen0002 (INPUT par_cdcooper,
                                                           INPUT 0,
                                                           INPUT 0,
                                                           INPUT par_cdoperad,
                                                           INPUT par_nmdatela,
                                                           INPUT 1, /* Ayllos*/
                                                           INPUT par_cddopcao,
                                                           INPUT par_nrdconta,
                                                           INPUT par_nrctremp,
                                                           INPUT CAPS(tt-bens-alienacao.dscorbem),
                                                           INPUT CAPS(tt-bens-alienacao.nrdplaca),
                                                           INPUT tt-bens-alienacao.idseqbem,
                                                           INPUT CAPS(tt-bens-alienacao.dscatbem),
                                                           INPUT CAPS(tt-bens-alienacao.dstipbem),
                                                           INPUT CAPS(tt-bens-alienacao.dsbemfin),
                                                           INPUT tt-bens-alienacao.vlmerbem,
                                                           INPUT tt-bens-alienacao.tpchassi,
                                                           INPUT CAPS(tt-bens-alienacao.dschassi),
                                                           INPUT CAPS(tt-bens-alienacao.ufdplaca),
                                                           INPUT CAPS(tt-bens-alienacao.uflicenc),
                                                           INPUT tt-bens-alienacao.nrrenava,
                                                           INPUT tt-bens-alienacao.nranobem,
                                                           INPUT tt-bens-alienacao.nrmodbem,
                                                           INPUT tt-bens-alienacao.nrcpfbem,
                                                           INPUT aux_contador,
                                                           INPUT TRUE,
                                                           INPUT par_vlemprst,
                                                           OUTPUT TABLE tt-erro,
                                                           OUTPUT aux_nmdcampo,
                                                           OUTPUT aux_flgsenha,
                                                           OUTPUT aux_dsmensag).
                                           
               IF RETURN-VALUE <> "OK"   THEN
                   UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC.                                    
            END.
    
       END.
       
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

       RUN grava-proposta-completa IN h-b1wgen0002(INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_dtmvtolt,
                                                   INPUT tt-dados-assoc.inpessoa,
                                                   INPUT par_nrctremp, /* par_nrctremp */
                                                   INPUT 1, /* par_tpemprst */
                                                   INPUT FALSE, /* par_flgcmtlc */
                                                   INPUT aux_vlutiliz,
                                                   INPUT 0, /* par_vllimapv */
                                                   INPUT par_cddopcao,
                                                   /*---Dados para a crawepr---*/
                                                   INPUT par_vlemprst,
                                                   INPUT 0, /* par_vlpreant */
                                                   INPUT par_vlpreemp,
                                                   INPUT par_qtpreemp,
                                                   INPUT tt-proposta-epr.nivrisco,
                                                   INPUT par_cdlcremp,
                                                   INPUT par_cdfinemp,
                                                   INPUT 0, /* par_qtdialib */
                                                   INPUT TRUE, /* par_flgimppr */
                                                   INPUT FALSE, /* par_flgimpnp */
                                                   INPUT par_percetop,
                                                   INPUT 1, /* par_idquapro */
                                                   INPUT par_dtdpagto,
                                                   INPUT 0, /* par_qtpromis */
                                                   INPUT FALSE, /* par_flgpagto */
                                                   INPUT "", /* par_dsctrliq */
                                                   INPUT aux_nrctaava,  /* par_nrctaava */
                                                   INPUT aux_nrctaav2,  /* par_nrctaav2 */
                                                   INPUT 0, /*par_idcarenc*/
                                                   INPUT ?, /*par_dtcarenc*/
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
                                                   INPUT par_flgdocje,
                                                   INPUT aux_nrctacje,
                                                   INPUT aux_nrcpfcje,
                                                   INPUT aux_perfatcl,
                                                   INPUT aux_vlmedfat,
                                                   INPUT FALSE,
                                                   INPUT FALSE,
                                                   INPUT par_dsobserv,
                                                   INPUT aux_dsdfinan,
                                                   INPUT aux_dsdrendi,
                                                   INPUT aux_dsdebens,
                                                   /* Alienacao */
                                                   INPUT aux_dsdalien,
                                                   INPUT aux_dsinterv,
                                                   INPUT tt-dados-coope.lssemseg,
                                                   /* Avalista 1 */
                                                   INPUT aux_nmdaval1,
                                                   INPUT aux_nrcpfav1,
                                                   INPUT aux_tpdocav1,
                                                   INPUT aux_dsdocav1,
                                                   INPUT aux_nmdcjav1,
                                                   INPUT aux_cpfcjav1,
                                                   INPUT aux_tdccjav1,
                                                   INPUT aux_doccjav1,
                                                   INPUT aux_ende1av1,
                                                   INPUT aux_ende2av1,
                                                   INPUT aux_nrfonav1,
                                                   INPUT aux_emailav1,
                                                   INPUT aux_nmcidav1,
                                                   INPUT aux_cdufava1,
                                                   INPUT aux_nrcepav1,
                                                   INPUT aux_cdnacio1,
                                                   INPUT aux_vledvmt1,
                                                   INPUT aux_vlrenme1,
                                                   INPUT aux_nrender1,
                                                   INPUT aux_complen1,
                                                   INPUT aux_nrcxaps1,
                                                   INPUT aux_inpesso1,
                                                   INPUT aux_dtnasct1,
												   INPUT 0, /* par_vlrecjg1 */
                                                   /* Avalista 2 */
                                                   INPUT aux_nmdaval2,
                                                   INPUT aux_nrcpfav2,
                                                   INPUT aux_tpdocav2,
                                                   INPUT aux_dsdocav2,
                                                   INPUT aux_nmdcjav2,
                                                   INPUT aux_cpfcjav2,
                                                   INPUT aux_tdccjav2,
                                                   INPUT aux_doccjav2,
                                                   INPUT aux_ende1av2,
                                                   INPUT aux_ende2av2,
                                                   INPUT aux_nrfonav2,
                                                   INPUT aux_emailav2,
                                                   INPUT aux_nmcidav2,
                                                   INPUT aux_cdufava2,
                                                   INPUT aux_nrcepav2,
                                                   INPUT aux_cdnacio2,
                                                   INPUT aux_vledvmt2,
                                                   INPUT aux_vlrenme2,
                                                   INPUT aux_nrender2,
                                                   INPUT aux_complen2,
                                                   INPUT aux_nrcxaps2,
                                                   INPUT aux_inpesso2,
                                                   INPUT aux_dtnasct2,
												   INPUT 0, /* par_vlrecjg2 */
                                                   INPUT "",
                                                   INPUT aux_flgerlog,
                                                   INPUT aux_dsjusren,
                                                   INPUT par_dtmvtolt,
                                                   INPUT 0,/*par_idcobope*/
												   INPUT 1, /*par_idfiniof*/
                                                   INPUT "", /*par_dscatbem*/
                                                   INPUT par_inresapr, /* par_inresapr */
												   INPUT "TP", /* par_dsdopcao */
                                                   INPUT 0,
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-msg-confirma,
                                                   OUTPUT aux_recidepr,
                                                   OUTPUT par_nrctremp,
                                                   OUTPUT aux_flmudfai).

       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC.
			  
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       /* Gravar Vendedor do emprestimo */ 
       RUN STORED-PROCEDURE pc_manter_empr_cdc_prog
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctremp,
                                             INPUT par_cdcoploj,
                                             INPUT par_nrctaloj,
                                             INPUT par_dsvended,
                                             INPUT par_vlemprst,
                                             OUTPUT "").
       
       /* Fechar o procedimento para buscarmos o resultado */ 
       CLOSE STORED-PROC pc_manter_empr_cdc_prog
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

       ASSIGN aux_dscritic = pc_manter_empr_cdc_prog.pr_dscritic
                                WHEN pc_manter_empr_cdc_prog.pr_dscritic <> ?.           

       IF aux_dscritic <> "" THEN 
         DO:
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic). 
         UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC.           
       END.

       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       /* Montar retorno da proposta em formato JSON */ 
       RUN STORED-PROCEDURE pc_monta_ret_proposta_json
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctremp,
                                             INPUT aux_nrctaava,  /* par_nrctaava */
                                             INPUT aux_nrctaav2,  /* par_nrctaav2 */
											 INPUT par_inresapr,
                                             OUTPUT "",          /* pr_retjson */
                                             OUTPUT 0 ,          /* pr_cdcritic */
                                             OUTPUT "").         /* pr_dscritic */
       
       /* Fechar o procedimento para buscarmos o resultado */ 
       CLOSE STORED-PROC pc_monta_ret_proposta_json
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

       ASSIGN aux_cdcritic = 0
              aux_dscritic = "" 
              aux_dsjsonan = ""
              aux_cdcritic = pc_monta_ret_proposta_json.pr_cdcritic
                                WHEN pc_monta_ret_proposta_json.pr_cdcritic <> ?       
              aux_dscritic = pc_monta_ret_proposta_json.pr_dscritic
                                WHEN pc_monta_ret_proposta_json.pr_dscritic <> ?
              aux_dsjsonan  = pc_monta_ret_proposta_json.pr_retjson
                                WHEN pc_monta_ret_proposta_json.pr_retjson <> ?.           

       IF aux_dscritic <> "" OR 
          aux_cdcritic <> 0 THEN 
         DO:
          RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic). 
         UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC.           
       END.
       
       ASSIGN par_dsjsonan = aux_dsjsonan.
       
       ASSIGN aux_flgtrans = TRUE.

    END. /* END GRAVAINTCDC: DO TRANSACTION */

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

    IF VALID-HANDLE(h-b1wgen0002) THEN
       DELETE PROCEDURE h-b1wgen0002.

    IF NOT aux_flgtrans THEN
       RETURN "NOK".
    
    RETURN "OK".

END PROCEDURE. /* END integra_proposta */

PROCEDURE integra_dados_avalista:

    DEF INPUT PARAM par_cdcooper AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                   NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                   NO-UNDO.
    DEF INPUT PARAM par_idorigem AS CHAR                   NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS DECI                   NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS DECI                   NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                   NO-UNDO.
    DEF INPUT PARAM par_dsdopcao AS CHAR                   NO-UNDO.
    /* Indica se permite reiniciar fluxo de aprovaçao */
    DEF  INPUT PARAM par_inresapr AS INT                   NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-avalista.

    DEF OUTPUT PARAM par_dsjsonan AS LONGCHAR              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dtmvtolt AS DATE                           NO-UNDO.
    DEF VAR aux_dsjsonan AS LONGCHAR                       NO-UNDO.

    /** ------------------- Variaveis do 1 avalista ------------------ **/
    DEF VAR aux_nrctaava AS INTE                           NO-UNDO.
    DEF VAR aux_nmdaval1 AS CHAR                           NO-UNDO.
    DEF VAR aux_nrcpfav1 AS DECI                           NO-UNDO.
    DEF VAR aux_tpdocav1 AS CHAR                           NO-UNDO.
    DEF VAR aux_dsdocav1 AS CHAR                           NO-UNDO.
    DEF VAR aux_nmdcjav1 AS CHAR                           NO-UNDO.
    DEF VAR aux_cpfcjav1 AS DECI                           NO-UNDO.
    DEF VAR aux_tdccjav1 AS CHAR                           NO-UNDO.
    DEF VAR aux_doccjav1 AS CHAR                           NO-UNDO.
    DEF VAR aux_ende1av1 AS CHAR                           NO-UNDO.
    DEF VAR aux_ende2av1 AS CHAR                           NO-UNDO.
    DEF VAR aux_nrfonav1 AS CHAR                           NO-UNDO.
    DEF VAR aux_emailav1 AS CHAR                           NO-UNDO.
    DEF VAR aux_nmcidav1 AS CHAR                           NO-UNDO.
    DEF VAR aux_cdufava1 AS CHAR                           NO-UNDO.
    DEF VAR aux_nrcepav1 AS INTE                           NO-UNDO.
    DEF VAR aux_cdnacio1 AS INTE                           NO-UNDO.
    DEF VAR aux_vledvmt1 AS DECI                           NO-UNDO.
    DEF VAR aux_vlrenme1 AS DECI                           NO-UNDO.
    DEF VAR aux_nrender1 AS INTE                           NO-UNDO.
    DEF VAR aux_complen1 AS CHAR                           NO-UNDO.
    DEF VAR aux_nrcxaps1 AS INTE                           NO-UNDO.
    DEF VAR aux_inpesso1 AS INTE                           NO-UNDO.
    DEF VAR aux_dtnasct1 AS DATE                           NO-UNDO.

    /** ------------------- Variaveis do 2 avalista ------------------- **/
    DEF VAR aux_nrctaav2 AS INTE                           NO-UNDO.    
    DEF VAR aux_nmdaval2 AS CHAR                           NO-UNDO.
    DEF VAR aux_nrcpfav2 AS DECI                           NO-UNDO.
    DEF VAR aux_tpdocav2 AS CHAR                           NO-UNDO.
    DEF VAR aux_dsdocav2 AS CHAR                           NO-UNDO.
    DEF VAR aux_nmdcjav2 AS CHAR                           NO-UNDO.
    DEF VAR aux_cpfcjav2 AS DECI                           NO-UNDO.
    DEF VAR aux_tdccjav2 AS CHAR                           NO-UNDO.
    DEF VAR aux_doccjav2 AS CHAR                           NO-UNDO.
    DEF VAR aux_ende1av2 AS CHAR                           NO-UNDO.
    DEF VAR aux_ende2av2 AS CHAR                           NO-UNDO.
    DEF VAR aux_nrfonav2 AS CHAR                           NO-UNDO.
    DEF VAR aux_emailav2 AS CHAR                           NO-UNDO.
    DEF VAR aux_nmcidav2 AS CHAR                           NO-UNDO.
    DEF VAR aux_cdufava2 AS CHAR                           NO-UNDO.
    DEF VAR aux_nrcepav2 AS INTE                           NO-UNDO.
    DEF VAR aux_cdnacio2 AS INTE                           NO-UNDO.
    DEF VAR aux_vledvmt2 AS DECI                           NO-UNDO.
    DEF VAR aux_vlrenme2 AS DECI                           NO-UNDO.
    DEF VAR aux_nrender2 AS INTE                           NO-UNDO.
    DEF VAR aux_complen2 AS CHAR                           NO-UNDO.
    DEF VAR aux_nrcxaps2 AS INTE                           NO-UNDO.
    DEF VAR aux_inpesso2 AS INTE                           NO-UNDO.
    DEF VAR aux_dtnasct2 AS DATE                           NO-UNDO.
    DEF VAR aux_flmudfai AS CHAR                           NO-UNDO.

    DEF VAR aux_flgtrans AS LOGI                           NO-UNDO.
    DEF VAR aux_idpeapro AS INT                            NO-UNDO.
    DEF VAR aux_nrgarope LIKE crapprp.nrgarope             NO-UNDO. /*PRJ438 - BUG*/
    DEF VAR aux_nrliquid LIKE crapprp.nrliquid             NO-UNDO. /*PRJ438 - BUG*/
    ASSIGN aux_flgtrans = FALSE.

    /* Buscar data atual */
    GRAVAINTCDC: DO TRANSACTION ON ERROR  UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC
                                ON ENDKEY UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC:
    
    FOR FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK:
      ASSIGN aux_dtmvtolt = crapdat.dtmvtolt.
    END.

    FOR EACH tt-avalista:
      
      IF tt-avalista.idavalis = 1 THEN
        DO:
          ASSIGN aux_nrctaava = DECI(STRING(tt-avalista.nrctaava) + STRING(tt-avalista.nrdvctav))
                 aux_nmdaval1 = tt-avalista.nmavalis
                 aux_nrcpfav1 = tt-avalista.nrcpfcgc
                 aux_tpdocav1 = tt-avalista.tpdocava
                 aux_dsdocav1 = tt-avalista.nrdocava
                 aux_nmdcjav1 = tt-avalista.nmconjug
                 aux_cpfcjav1 = tt-avalista.nrcpfcon
                 aux_tdccjav1 = tt-avalista.tpdoccon
                 aux_doccjav1 = tt-avalista.nrdoccon
                 aux_ende1av1 = tt-avalista.dsendere
                 aux_ende2av1 = tt-avalista.dsbairro
                 aux_nrfonav1 = tt-avalista.nrtelefo
                 aux_emailav1 = tt-avalista.dsdemail
                 aux_nmcidav1 = tt-avalista.dscidade
                 aux_cdufava1 = tt-avalista.cdufende
                 aux_nrcepav1 = tt-avalista.nrcepava
                 aux_vledvmt1 = tt-avalista.vlendmax
                 aux_vlrenme1 = tt-avalista.vlrenmes
                 aux_nrender1 = tt-avalista.nrendere
                 aux_complen1 = tt-avalista.dscomple
                 aux_nrcxaps1 = tt-avalista.nrcxpost
                 aux_inpesso1 = tt-avalista.tppessoa
                 aux_dtnasct1 = tt-avalista.dtnascto.
                 
          FOR FIRST crapnac 
             FIELDS(cdnacion)
              WHERE CAPS(crapnac.dsnacion) = CAPS(tt-avalista.dsnacion)
            NO-LOCK:
              ASSIGN aux_cdnacio1 = crapnac.cdnacion.
          END.
          
          IF NOT AVAIL crapnac THEN
            ASSIGN aux_cdnacio1 = 42. /* Se nao encontrar nacionalidade assumimos como BRASILEIRA */
        END.
      ELSE
        DO:
          ASSIGN aux_nrctaav2 = DECI(STRING(tt-avalista.nrctaava) + STRING(tt-avalista.nrdvctav))
                 aux_nmdaval2 = tt-avalista.nmavalis
                 aux_nrcpfav2 = tt-avalista.nrcpfcgc
                 aux_tpdocav2 = tt-avalista.tpdocava
                 aux_dsdocav2 = tt-avalista.nrdocava
                 aux_nmdcjav2 = tt-avalista.nmconjug
                 aux_cpfcjav2 = tt-avalista.nrcpfcon
                 aux_tdccjav2 = tt-avalista.tpdoccon
                 aux_doccjav2 = tt-avalista.nrdoccon
                 aux_ende1av2 = tt-avalista.dsendere
                 aux_ende2av2 = tt-avalista.dsbairro
                 aux_nrfonav2 = tt-avalista.nrtelefo
                 aux_emailav2 = tt-avalista.dsdemail
                 aux_nmcidav2 = tt-avalista.dscidade
                 aux_cdufava2 = tt-avalista.cdufende
                 aux_nrcepav2 = tt-avalista.nrcepava
                 aux_vledvmt2 = tt-avalista.vlendmax
                 aux_vlrenme2 = tt-avalista.vlrenmes
                 aux_nrender2 = tt-avalista.nrendere
                 aux_complen2 = tt-avalista.dscomple
                 aux_nrcxaps2 = tt-avalista.nrcxpost
                 aux_inpesso2 = tt-avalista.tppessoa
                 aux_dtnasct2 = tt-avalista.dtnascto.
                 
          FOR FIRST crapnac 
             FIELDS(cdnacion)
              WHERE CAPS(crapnac.dsnacion) = CAPS(tt-avalista.dsnacion)
            NO-LOCK:
              ASSIGN aux_cdnacio2 = crapnac.cdnacion.
          END.
          
          IF NOT AVAIL crapnac THEN
            ASSIGN aux_cdnacio2 = 42. /* Se nao encontrar nacionalidade assumimos como BRASILEIRA */                 
        END.      
    END.
    
    IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p 
           PERSISTENT SET h-b1wgen0002.    
    
    ASSIGN aux_idpeapro = 0. /*Nao perde aprovacao*/
    
    RUN atualiza_dados_avalista_proposta IN h-b1wgen0002
            (INPUT par_cdcooper,
             INPUT par_cdagenci,
             INPUT par_nrdcaixa,
             INPUT par_cdoperad,
             INPUT par_nmdatela,
             INPUT par_idorigem,
             INPUT par_nrdconta,
             INPUT par_idseqttl,
             INPUT aux_dtmvtolt,
             INPUT par_nrctremp,
             INPUT par_flgerlog,
             INPUT par_dsdopcao,
             INPUT aux_nrctaava,
             INPUT aux_nrctaav2,
             INPUT aux_nmdaval1,
             INPUT aux_nrcpfav1,
             INPUT aux_tpdocav1,
             INPUT aux_dsdocav1,
             INPUT aux_nmdcjav1,
             INPUT aux_cpfcjav1,
             INPUT aux_tdccjav1,
             INPUT aux_doccjav1,
             INPUT aux_ende1av1,
             INPUT aux_ende2av1,
             INPUT aux_nrfonav1,
             INPUT aux_emailav1,
             INPUT aux_nmcidav1,
             INPUT aux_cdufava1,
             INPUT aux_nrcepav1,
             INPUT aux_cdnacio1,
             INPUT aux_vledvmt1,
             INPUT aux_vlrenme1,
             INPUT aux_nrender1,
             INPUT aux_complen1,
             INPUT aux_nrcxaps1,
             INPUT aux_inpesso1,
             INPUT aux_dtnasct1,
             INPUT 0,
             INPUT aux_nmdaval2,
             INPUT aux_nrcpfav2,
             INPUT aux_tpdocav2,
             INPUT aux_dsdocav2,
             INPUT aux_nmdcjav2,
             INPUT aux_cpfcjav2,
             INPUT aux_tdccjav2,
             INPUT aux_doccjav2,
             INPUT aux_ende1av2,
             INPUT aux_ende2av2,
             INPUT aux_nrfonav2,
             INPUT aux_emailav2,
             INPUT aux_nmcidav2,
             INPUT aux_cdufava2,
             INPUT aux_nrcepav2,
             INPUT aux_cdnacio2,
             INPUT aux_vledvmt2,
             INPUT aux_vlrenme2,
             INPUT aux_nrender2,
             INPUT aux_complen2,
             INPUT aux_nrcxaps2,
             INPUT aux_inpesso2,
             INPUT aux_dtnasct2,
             INPUT 0,
             INPUT "", /*par_dsdbeavt*/
             INPUT par_inresapr, /* par_inresapr */
             INPUT 0,
             INPUT-OUTPUT aux_idpeapro,
            OUTPUT aux_flmudfai,
            OUTPUT aux_nrgarope, /*PRJ438 - BUG*/
            OUTPUT aux_nrliquid, /*PRJ438 - BUG*/  
            OUTPUT TABLE tt-erro,
            OUTPUT TABLE tt-msg-confirma).

    IF RETURN-VALUE <> "OK"   THEN
      UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC.

     { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

     /* Montar retorno da proposta em formato JSON */ 
     RUN STORED-PROCEDURE pc_monta_ret_proposta_json
      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdconta,
                                           INPUT par_nrctremp,
                                           INPUT aux_nrctaava,  /* par_nrctaava */
                                           INPUT aux_nrctaav2,  /* par_nrctaav2 */
                                           INPUT par_inresapr,  /* par_inresapr*/
                                           OUTPUT "",          /* pr_retjson */
                                           OUTPUT 0 ,          /* pr_cdcritic */
                                           OUTPUT "").         /* pr_dscritic */
     
     /* Fechar o procedimento para buscarmos o resultado */ 
     CLOSE STORED-PROC pc_monta_ret_proposta_json
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

     ASSIGN aux_cdcritic = 0
            aux_dscritic = "" 
            aux_dsjsonan = ""
            aux_cdcritic = pc_monta_ret_proposta_json.pr_cdcritic
                              WHEN pc_monta_ret_proposta_json.pr_cdcritic <> ?       
            aux_dscritic = pc_monta_ret_proposta_json.pr_dscritic
                              WHEN pc_monta_ret_proposta_json.pr_dscritic <> ?
            aux_dsjsonan  = pc_monta_ret_proposta_json.pr_retjson
                              WHEN pc_monta_ret_proposta_json.pr_retjson <> ?.           

     IF aux_dscritic <> "" OR 
        aux_cdcritic <> 0 THEN 
       DO:
        RUN gera_erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1,
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic). 
       UNDO GRAVAINTCDC, LEAVE GRAVAINTCDC.
     END.

     ASSIGN par_dsjsonan = aux_dsjsonan.
     
     ASSIGN aux_flgtrans = TRUE.
    
    END. /* END GRAVAINTCDC: DO TRANSACTION */

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

    IF VALID-HANDLE(h-b1wgen0002) THEN
       DELETE PROCEDURE h-b1wgen0002.

    IF NOT aux_flgtrans THEN
        RETURN "NOK".

    RETURN "OK".
    
END PROCEDURE.  /* END integra_dados_avalista */
/* ......................................................................... */