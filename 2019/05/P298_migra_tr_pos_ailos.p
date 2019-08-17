  
/*..............................................................................

    Programa  : P298_migra_tr_pos.p
    Autor     : Rafael Faria (Supero)
    Data      : Outubro/2018                Ultima Atualizacao: 03/05/2019
    
    Dados referentes ao programa:

    Objetivo  : BO ref. Rotina de migracao de emprestimos

    Alteracoes: 03/05/2019 - Projeto 298.2.2 - Pos Fixado, adicionar tratamento de carencia e parcela 
 
                25/05/2019 - Projeto 298.2.2 - Pos Fixado, removido tratamento de carencia e parcela para migrar contrato especifico

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
{ sistema/generico/includes/b1wgen9999tt.i  }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

/* programas */
DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0165 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0043 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0084 AS HANDLE                                         NO-UNDO.

/* variaveis */
DEF STREAM str_arquivo.
DEF STREAM str_2.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnivris AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

/* tabelas */
DEF TEMP-TABLE tt-registro-arquivo NO-UNDO               
    FIELD cdcooper  LIKE crawepr.cdcooper
    FIELD nrdconta  LIKE crawepr.nrdconta
    FIELD nmprimtl  LIKE crapass.nmprimtl
    FIELD nrctremp  LIKE crawepr.nrctremp
    FIELD cdfinemp  LIKE crawepr.cdfinemp
    FIELD cdlcremp  LIKE crawepr.cdlcremp
    FIELD flgctrmg  AS LOGICAL INIT FALSE
    FIELD dscritic  LIKE crapcri.dscritic
    FIELD dtdpagto  LIKE crapepr.dtdpagto
    FIELD qtparatu  LIKE crawepr.qtpreemp.
    
DEF TEMP-TABLE tt-tipo-rendi                                           NO-UNDO
    FIELD tpdrendi  AS INTE
    FIELD dsdrendi  AS CHAR.

DEF TEMP-TABLE tt-aval-crapbem                                         NO-UNDO
    LIKE tt-crapbem
    USE-INDEX crapbem2 USE-INDEX tt-crapbem AS PRIMARY.
        
PROCEDURE leitura_arquivo_carga:

    /*entrada
    DEF  INPUT PARAM par_nmdirarq AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    */
    /*saida*/
    DEF OUTPUT PARAM TABLE FOR tt-registro-arquivo.
    
    /*variaveis*/
    DEF VAR aux_setlinha     AS CHAR                                          NO-UNDO.

    /* Vamos ler o arquivo */
    INPUT STREAM str_arquivo FROM VALUE("/micros/cecred/james/migracao.csv") NO-ECHO.

    Busca:
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       IMPORT STREAM str_arquivo UNFORMATTED aux_setlinha.
       
       CREATE tt-registro-arquivo.
       ASSIGN tt-registro-arquivo.cdcooper = INTE(TRIM(ENTRY(1,aux_setlinha,";")))
              tt-registro-arquivo.nrdconta = INTE(REPLACE(REPLACE(TRIM(ENTRY(2,aux_setlinha,";")),'.',''),'-',''))
              tt-registro-arquivo.nmprimtl = TRIM(ENTRY(3,aux_setlinha,";"))
              tt-registro-arquivo.nrctremp = INTE(REPLACE(TRIM(ENTRY(4,aux_setlinha,";")),'.',''))
              tt-registro-arquivo.cdfinemp = INTE(TRIM(ENTRY(5,aux_setlinha,";")))
              tt-registro-arquivo.cdlcremp = INTE(TRIM(ENTRY(6,aux_setlinha,";"))).
              tt-registro-arquivo.qtparatu = INTE(TRIM(ENTRY(7,aux_setlinha,";"))).
       VALIDATE tt-registro-arquivo.
    END.

END PROCEDURE.  /* END leitura_arquivo_carga */

PROCEDURE valida_dados:
    
    /*entrada*/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    /*saida*/
    DEF OUTPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdagenci LIKE crawepr.cdagenci             NO-UNDO.
    DEF OUTPUT PARAM par_cdoperad LIKE crawepr.cdoperad             NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    FOR FIRST crapepr FIELDS(nrctremp) 
                       WHERE crapepr.cdcooper = par_cdcooper AND
                             crapepr.nrdconta = par_nrdconta AND
                             crapepr.nrctremp = par_nrctremp
                             NO-LOCK: END.

    IF NOT AVAIL crapepr THEN
       DO:
           ASSIGN par_dscritic = "Emprestimo nao encontrado, contrato: " + STRING(par_nrctremp).
           RETURN "NOK".
       END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    FOR FIRST crawepr FIELDS(cdagenci cdoperad) 
                       WHERE crawepr.cdcooper = par_cdcooper AND
                             crawepr.nrdconta = par_nrdconta AND
                             crawepr.nrctremp = par_nrctremp
                             NO-LOCK: END.

    IF NOT AVAIL crawepr THEN
       DO:
           ASSIGN par_dscritic = "Emprestimo nao encontrado, proposta: " + STRING(par_nrctremp).
           RETURN "NOK".
       END.

    ASSIGN par_dtmvtolt = crapdat.dtmvtolt
           par_dtmvtopr = crapdat.dtmvtopr
           par_cdagenci = crawepr.cdagenci
           par_cdoperad = crawepr.cdoperad.

    RETURN "OK".

END PROCEDURE. /* END valida_dados */

PROCEDURE altera_parcelas:
    
    /*entrada*/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO. /*total de parcelas*/
    
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrparepr AS INTE                                    NO-UNDO.
    
    ASSIGN aux_nrparepr = par_qtpreemp.

    FOR EACH crappep WHERE crappep.cdcooper = par_cdcooper AND
                           crappep.nrdconta = par_nrdconta AND
                           crappep.nrctremp = par_nrctremp
                           EXCLUSIVE-LOCK
                           BY crappep.nrparepr DESC:

     ASSIGN crappep.nrparepr = aux_nrparepr.
                aux_nrparepr = aux_nrparepr - 1.
    END.  

    RETURN "OK".

END PROCEDURE. /* END altera_parcelas */

PROCEDURE efetiva_proposta:

    DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_insitapr AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dsobscmt AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_dtdpagto AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrcpfope AS DECI                              NO-UNDO.

    DEFINE OUTPUT PARAM par_mensagem AS CHAR                          NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-ratings.
    DEFINE OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdempres LIKE crapttl.cdempres                        NO-UNDO.
    DEF VAR aux_txiofepr AS DECI                                      NO-UNDO.
    DEF VAR aux_floperac AS LOGI                                      NO-UNDO.
    DEF VAR aux_cdhistor AS INTE                                      NO-UNDO.
    DEF VAR aux_cdhistor_tar AS INTE                                  NO-UNDO.
    DEF VAR aux_nrdolote AS INTE                                      NO-UNDO.
    DEF VAR aux_vltotctr AS DECI                                      NO-UNDO.
    DEF VAR aux_vltotjur AS DECI                                      NO-UNDO.
    DEF VAR aux_vltotemp AS DECI                                      NO-UNDO.
    DEF VAR aux_contador AS INTE                                      NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                      NO-UNDO.
    DEF VAR aux_dsoperac AS CHAR                                      NO-UNDO.
    DEF VAR aux_flgportb AS LOGI INIT FALSE                           NO-UNDO.
    DEF VAR aux_flcescrd AS LOGI INIT FALSE                           NO-UNDO.
    DEF VAR aux_idcarga  AS INTE                                      NO-UNDO.
    DEF VAR aux_flgativo AS INTE                                      NO-UNDO.
    DEF VAR aux_vltottar AS DECI                                      NO-UNDO.
    DEF VAR aux_vltariof AS DECI                                      NO-UNDO.
    DEF VAR aux_tpfinali AS INTE                                      NO-UNDO.
    DEF VAR aux_flgimune AS INTE                                      NO-UNDO.
    DEF VAR aux_vltotiof AS DECI                                      NO-UNDO.
    DEF VAR aux_qtdiaiof AS INTE									  NO-UNDO.
    DEF VAR aux_vlaqiofc AS DECI                                      NO-UNDO.    
    DEF VAR aux_cdhistar_cad  AS INTE                                 NO-UNDO.
    DEF VAR aux_cdhistar_gar  AS INTE                                 NO-UNDO.    
    DEF VAR aux_vlpreclc AS DECI                                      NO-UNDO.
    DEF VAR aux_vliofpri AS DECI                                      NO-UNDO.    
    DEF VAR aux_vliofadi AS DECI                                      NO-UNDO.    
    DEF VAR aux_nrseqdig AS INTE                                      NO-UNDO.
    DEF VAR aux_nrdolote_cred AS INTE                                 NO-UNDO.   
    DEF VAR aux_cdhistor_cred AS INTE                                 NO-UNDO.

    DEF VAR h-b1wgen0084 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0097 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0134 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0171 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0188 AS HANDLE                                    NO-UNDO.
    DEF VAR aux_dscatbem AS CHAR                                      NO-UNDO.
    DEF VAR aux_dsctrliq AS CHAR                                      NO-UNDO.
    DEF VAR i            AS INTE                                      NO-UNDO.
    DEF VAR aux_vltrfgar AS DECI                                      NO-UNDO.    
    DEF VAR aux_vltarifa AS DECI                                      NO-UNDO.
    DEF VAR aux_vltaxiof AS DECI                                      NO-UNDO.    
    DEF VAR aux_dtrisref AS DATE /* DATA RISCO REFIN */               NO-UNDO.
    DEF VAR aux_qtdiaatr AS INTE                                      NO-UNDO.
    DEF VAR aux_idquapro AS INTE                                      NO-UNDO.

    DEF BUFFER b-crawepr FOR crawepr.

    EMPTY TEMP-TABLE tt-erro.

    IF par_flgerlog   THEN
       ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
              aux_dstransa = "Grava dados de efetivacao da proposta.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF NOT VALID-HANDLE(h-b1wgen0084) THEN
    RUN sistema/generico/procedures/b1wgen0084.p PERSISTENT SET h-b1wgen0084.
    
    RUN valida_dados_efetivacao_proposta
        IN h-b1wgen0084 (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT par_cdoperad,
                         INPUT par_nmdatela,
                         INPUT par_idorigem,
                         INPUT par_nrdconta,
                         INPUT par_idseqttl,
                         INPUT par_dtmvtolt,
                         INPUT par_flgerlog,
                         INPUT par_nrctremp).

    IF VALID-HANDLE(h-b1wgen0084) THEN
    DELETE PROCEDURE h-b1wgen0084.

    IF RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

       ASSIGN aux_vltotemp = crawepr.vlemprst
              aux_vltotctr = crawepr.qtpreemp * crawepr.vlpreemp
              aux_vltotjur = aux_vltotctr - crawepr.vlemprst
              aux_floperac = ( craplcr.dsoperac = "FINANCIAMENTO" )
			        aux_idcarga  = 0.

        DO aux_contador = 1 TO 10:

           FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                              craplcr.cdlcremp = crawepr.cdlcremp
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE craplcr   THEN
              IF LOCKED craplcr   THEN
                 DO:
                     ASSIGN aux_cdcritic = 77.
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
              ELSE
                 DO:
                     ASSIGN aux_cdcritic = 363.
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                   RETURN "NOK".
                 END.

           ASSIGN aux_cdcritic = 0.
           LEAVE.
       END.

     IF aux_cdcritic <> 0 or aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.             

     ASSIGN aux_dsctrliq = ""
            aux_nrdolote_cred = 650004.

             IF   aux_floperac   THEN             /* Financiamento*/
                ASSIGN aux_cdhistor_cred = 2327.
             ELSE                                 /* Emprestimo */
                  ASSIGN aux_cdhistor_cred = 2326.

     IF NOT VALID-HANDLE(h-b1wgen0134) THEN
     RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

     RUN cria_lancamento_lem IN h-b1wgen0134
                             (INPUT par_cdcooper,
                              INPUT par_dtmvtolt,
                              INPUT par_cdagenci,
                              INPUT 100,          /* cdbccxlt */
                              INPUT par_cdoperad,
                              INPUT par_cdagenci,
                              INPUT 4,            /* tplotmov */
                              INPUT aux_nrdolote_cred, /* nrdolote */
                              INPUT par_nrdconta,
                              INPUT aux_cdhistor_cred,
                              INPUT par_nrctremp,
                              INPUT aux_vltotemp, /* Valor total emprestado */
                              INPUT par_dtmvtolt,
                              INPUT craplcr.txdiaria,
                              INPUT 0,
                              INPUT 0,
                              INPUT 0,
                              INPUT TRUE,
                              INPUT TRUE,
                              INPUT 0,
                              INPUT par_idorigem).

        IF VALID-HANDLE(h-b1wgen0134) THEN
        DELETE PROCEDURE h-b1wgen0134.

        IF RETURN-VALUE <> "OK"   THEN
          DO:
              ASSIGN aux_dscritic = "Erro na criacao do lancamento".
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
                   RETURN "NOK".
          END.

       FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK NO-ERROR.

       IF AVAILABLE crapass   THEN
          DO:
              IF crapass.inpessoa = 1   THEN
                 DO:
                     FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                        crapttl.nrdconta = crapass.nrdconta AND
                                        crapttl.idseqttl = 1
                                        NO-LOCK NO-ERROR.

                     IF AVAIL crapttl  THEN
                        ASSIGN aux_cdempres = crapttl.cdempres.

                  END.
              ELSE
                 DO:
                    FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                       crapjur.nrdconta = crapass.nrdconta
                                       NO-LOCK NO-ERROR.

                    IF AVAIL crapjur  THEN
                       ASSIGN aux_cdempres = crapjur.cdempres.

                 END.

                 END.

       /* Acionar rotina que gera a qualificacao da operacao */
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
       
       RUN STORED-PROCEDURE pc_proc_qualif_operacao
           aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,     /* Cooperativa                      */
                             INPUT par_cdagenci,     /* Cod Agencia                      */
                             INPUT par_nrdcaixa,     /* Nr do Caixa                      */
                             INPUT par_cdoperad,     /* Cod Operador                     */ 
                             INPUT par_nmdatela,     /* Programa Chamador                */
                             INPUT par_idorigem,     /* Origem                           */
                             INPUT par_nrdconta,     /* Conta                            */
                             INPUT aux_dsctrliq,     /* Contratos Liquidados             */
                             INPUT par_dtmvtolt,     /* Data do Movimento                */
                             INPUT par_dtmvtopr,     /* Data do Proximo dia de movimento */
                            /* -- OUTPUTS -- */
                            OUTPUT 0,                /* Id Qualif Operacao               */
                            OUTPUT "",               /* Descricao Qualif Operacao        */
                            OUTPUT 0,                /* ERRO - Id da critica             */  
                            OUTPUT "").              /* ERRO - Descricao da critica      */

       CLOSE STORED-PROC pc_proc_qualif_operacao 
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
       
       ASSIGN aux_cdcritic = 0
              aux_dscritic = ""
              aux_idquapro = 1
              aux_cdcritic = pc_proc_qualif_operacao.pr_cdcritic 
                             WHEN pc_proc_qualif_operacao.pr_cdcritic <> ?
              aux_dscritic = pc_proc_qualif_operacao.pr_dscritic 
                             WHEN pc_proc_qualif_operacao.pr_dscritic <> ?
              aux_idquapro = pc_proc_qualif_operacao.pr_idquapro 
                             WHEN pc_proc_qualif_operacao.pr_idquapro <> ?.

       IF  aux_cdcritic <> 0   OR
           aux_dscritic <> ""  THEN
           DO:                                    
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
                   RETURN "NOK".
          END.

       /* Requalifica a operacao na proposta                 */
       /* INICIO                                             */       
       FIND FIRST b-crawepr
          WHERE b-crawepr.cdcooper = par_cdcooper AND
                b-crawepr.nrdconta = par_nrdconta AND
                b-crawepr.nrctremp = par_nrctremp
                EXCLUSIVE-LOCK NO-ERROR.
       
       IF AVAIL b-crawepr THEN
          ASSIGN b-crawepr.idquapro = aux_idquapro.
          
       /* FIM                                                */
       /* Requalifica a operacao na proposta                 */
       
       CREATE crapepr.
       ASSIGN crapepr.dtmvtolt = par_dtmvtolt
              crapepr.cdagenci = par_cdagenci
              /* Gravar operador que efetivou a proposta */
              crapepr.cdopeefe = par_cdoperad
              crapepr.cdbccxlt = 0
              crapepr.nrdolote = 0 /*aux_nrdolote_cred*/
              crapepr.nrdconta = par_nrdconta
              /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
              crapepr.cdopeori = par_cdoperad
              crapepr.cdageori = par_cdagenci
              crapepr.dtinsori = TODAY
              /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
              crapepr.nrctremp = par_nrctremp
              crapepr.cdorigem = par_idorigem

              crapepr.cdfinemp = crawepr.cdfinemp
              crapepr.cdlcremp = crawepr.cdlcremp
              crapepr.vlemprst = crawepr.vlemprst
              crapepr.vlpreemp = crawepr.vlpreemp
              crapepr.qtpreemp = crawepr.qtpreemp
              crapepr.nrctaav1 = crawepr.nrctaav1
              crapepr.nrctaav2 = crawepr.nrctaav2
              crapepr.txjuremp = crawepr.txdiaria
              crapepr.vlsdeved = crawepr.vlemprst
              crapepr.dtultpag = crawepr.dtmvtolt
              crapepr.tpemprst = crawepr.tpemprst
              crapepr.txmensal = crawepr.txmensal
              crapepr.cdempres = aux_cdempres
              crapepr.nrcadast = crapass.nrcadast
              /* PJ 450 - Diego Simas (AMcom)  */
              /* Requalificar a Operacao       */
              crapepr.idquaprc = aux_idquapro
              crapepr.flgpagto = FALSE
              crapepr.dtdpagto = par_dtdpagto
              crapepr.qtmesdec = 0
              crapepr.qtprecal = 0
              crapepr.dtinipag = ?
              crapepr.tpdescto = crawepr.tpdescto
              crapepr.cdcooper = par_cdcooper
              crapepr.qttolatr = crawepr.qttolatr
              crapepr.iddcarga = aux_idcarga
              crapepr.vlsprojt = crawepr.vlemprst.
       VALIDATE crapepr.

       IF NOT VALID-HANDLE(h-b1wgen0043) THEN
       RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

       RUN obtem_emprestimo_risco IN h-b1wgen0043
                                  (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_idorigem,
                                   INPUT par_nmdatela,
                                   INPUT FALSE,
                                   INPUT crawepr.cdfinemp,
                                   INPUT crawepr.cdlcremp,
                                   INPUT crawepr.nrctrliq,
                                   INPUT "", /* par_dsctrliq */
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT aux_dsnivris).

       IF VALID-HANDLE(h-b1wgen0043) THEN
       DELETE PROCEDURE h-b1wgen0043.

       ASSIGN par_mensagem = ''.

       IF crawepr.dsnivris <> aux_dsnivris AND aux_flcescrd = FALSE THEN 
          DO:
             ASSIGN crawepr.dsnivris = aux_dsnivris
					        	crawepr.dsnivori = aux_dsnivris.
          END.

       IF crawepr.nrctaav1 > 0   THEN
          DO:
             FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                crapass.nrdconta = crawepr.nrctaav1
                                NO-LOCK NO-ERROR.

             IF NOT AVAIL crapass THEN
                DO:
                   ASSIGN aux_cdcritic = 9.
                   
                   RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
                   RETURN "NOK".
                END.

             /*Monta a mensagem da operacao para envio no e-mail*/
             ASSIGN aux_dsoperac = "Inclusao/alteracao "                      +
                                   "do Avalista conta "                       +
                                   STRING(crapass.nrdconta,"zzzz,zzz,9")      +
                                   " - CPF/CNPJ "                             +
                                  (IF crapass.inpessoa = 1 THEN
                                      STRING((STRING(crapass.nrcpfcgc,
                                            "99999999999")),"xxx.xxx.xxx-xx")
                                    ELSE
                                       STRING((STRING(crapass.nrcpfcgc,
                                             "99999999999999")),
                                             "xx.xxx.xxx/xxxx-xx" ))          +
                                   " na conta "                               +
                                   STRING(crawepr.nrdconta,"zzzz,zzz,9").

             IF NOT VALID-HANDLE(h-b1wgen0110) THEN
                RUN sistema/generico/procedures/b1wgen0110.p
                    PERSISTENT SET h-b1wgen0110.

             /*Verifica se o primeiro avalista esta no cadastro restritivo. Se
               estiver, sera enviado um e-mail informando a situacao*/
             RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_dtmvtolt,
                                               INPUT par_idorigem,
                                               INPUT crapass.nrcpfcgc,
                                               INPUT crapass.nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT FALSE, /*nao bloq. operacao*/
                                               INPUT 33, /*cdoperac*/
                                               INPUT aux_dsoperac,
                                               OUTPUT TABLE tt-erro).

             IF VALID-HANDLE(h-b1wgen0110) THEN
                DELETE PROCEDURE(h-b1wgen0110).

             IF RETURN-VALUE <> "OK" THEN
                DO:
                   IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                      DO:
                      ASSIGN aux_dscritic = "Nao foi possivel verificar " +
                                            "o cadastro restritivo.".
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                      END.           
                   RETURN "NOK".

                END.

          END.

       IF crawepr.nrctaav2 > 0   THEN
          DO:
             FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                crapass.nrdconta = crawepr.nrctaav2
                                NO-LOCK NO-ERROR.

             IF NOT AVAIL crapass THEN
                DO:
                   ASSIGN aux_cdcritic = 9.
                   RUN gera_erro (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT 1,
                                  INPUT aux_cdcritic,
                                  INPUT-OUTPUT aux_dscritic).
                   RETURN "NOK".
                END.

             /*Monta a mensagem da operacao para envio no e-mail*/
             ASSIGN aux_dsoperac = "Inclusao/alteracao "                      +
                                   "do Avalista conta "                       +
                                   STRING(crapass.nrdconta,"zzzz,zzz,9")      +
                                   " - CPF/CNPJ "                             +
                                  (IF crapass.inpessoa = 1 THEN
                                      STRING((STRING(crapass.nrcpfcgc,
                                            "99999999999")),"xxx.xxx.xxx-xx")
                                    ELSE
                                       STRING((STRING(crapass.nrcpfcgc,
                                             "99999999999999")),
                                             "xx.xxx.xxx/xxxx-xx" ))          +
                                   " na conta "                               +
                                   STRING(crawepr.nrdconta,"zzzz,zzz,9").

             IF NOT VALID-HANDLE(h-b1wgen0110) THEN
                RUN sistema/generico/procedures/b1wgen0110.p
                    PERSISTENT SET h-b1wgen0110.

             /*Verifica se o primeiro avalista esta no cadastro restritivo. Se
               estiver, sera enviado um e-mail informando a situacao*/
             RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_dtmvtolt,
                                               INPUT par_idorigem,
                                               INPUT crapass.nrcpfcgc,
                                               INPUT crapass.nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT FALSE, /*nao bloq. operacao*/
                                               INPUT 33, /*cdoperac*/
                                               INPUT aux_dsoperac,
                                               OUTPUT TABLE tt-erro).

             IF VALID-HANDLE(h-b1wgen0110) THEN
                DELETE PROCEDURE(h-b1wgen0110).

             IF RETURN-VALUE <> "OK" THEN
                DO:
                   IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                      DO:
                      ASSIGN aux_dscritic = "Nao foi possivel verificar " +
                                            "o cadastro restritivo.".
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).                       
                 END.
                   RETURN "NOK".
       END.

       END.


       ASSIGN craplcr.flgsaldo = TRUE.

       IF NOT VALID-HANDLE(h-b1wgen0043) THEN
       RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

       RUN gera_rating IN h-b1wgen0043 (INPUT par_cdcooper,
                                         INPUT 0,   /** Pac   **/
                                         INPUT 0,   /** Caixa **/
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_nrdconta,
                                         INPUT 1,   /** Titular **/
                                         INPUT par_dtmvtolt,
                                         INPUT par_dtmvtopr,
                                         INPUT par_inproces,
                                         INPUT 90, /*Emprestimo/Financiamento*/
                                         INPUT par_nrctremp,
                                         INPUT TRUE, /*Gravar Rating*/
                                         INPUT TRUE, /** Log **/
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-cabrel,
                                        OUTPUT TABLE tt-impressao-coop,
                                        OUTPUT TABLE tt-impressao-rating,
                                        OUTPUT TABLE tt-impressao-risco,
                                        OUTPUT TABLE tt-impressao-risco-tl,
                                        OUTPUT TABLE tt-impressao-assina,
                                        OUTPUT TABLE tt-efetivacao,
                                        OUTPUT TABLE tt-ratings).

       IF VALID-HANDLE(h-b1wgen0043) THEN
       DELETE PROCEDURE h-b1wgen0043.

       IF RETURN-VALUE <> "OK"   THEN
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

END PROCEDURE. /*efetiva_proposta*/


PROCEDURE criar_proposta:
    
    /*entrada*/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrmgr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpemprst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idcarenc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcarenc AS DATE                           NO-UNDO.
    /*entradas secundarias e fixas*/
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    
    DEF OUTPUT PARAM par_nrnvcemp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    /*variaveis*/
    DEF VAR aux_flgerlog AS LOG                                     NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
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
    
    DEF VAR aux_dtdrisco LIKE crapris.dtdrisco                      NO-UNDO.
    DEF VAR aux_dtoutris LIKE crapprp.dtoutris                      NO-UNDO.
    DEF VAR aux_vltotsfn LIKE crapprp.vltotsfn                      NO-UNDO.
    DEF VAR aux_qtopescr LIKE crapprp.qtopescr                      NO-UNDO.
    DEF VAR aux_qtifoper LIKE crapprp.qtifoper                      NO-UNDO.
    DEF VAR aux_vlopescr LIKE crapprp.vlopescr                      NO-UNDO.
    DEF VAR aux_vlrpreju LIKE crapprp.vlrpreju                      NO-UNDO.
    DEF VAR aux_vlsfnout LIKE crapprp.vlsfnout                      NO-UNDO.
    
    DEF VAR aux_nrgarope LIKE crapprp.nrgarope                      NO-UNDO.
    DEF VAR aux_nrliquid LIKE crapprp.nrliquid                      NO-UNDO.
    DEF VAR aux_nrpatlvr LIKE crapprp.nrpatlvr                      NO-UNDO.
    DEF VAR aux_nrinfcad LIKE crapprp.nrinfcad                      NO-UNDO.
    DEF VAR aux_nrperger LIKE crapprp.nrperger                      NO-UNDO.
    
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
    DEF VAR aux_vlrecjg1 AS DECI                                    NO-UNDO.
    
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
    DEF VAR aux_vlrecjg2 AS DECI                                    NO-UNDO.
    DEF VAR aux_dsjsonan AS LONGCHAR                                NO-UNDO.
    
    DEF VAR aux_dsmesage AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlutiliz AS DECI                                    NO-UNDO.
    DEF VAR aux_nivrisco AS CHAR                                    NO-UNDO.
    DEF VAR aux_nomcampo AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_dsdbeavt AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdfinan AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdrendi AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdebens AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdalien AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinterv AS CHAR                                    NO-UNDO.
    DEF VAR aux_recidepr AS INTE                                    NO-UNDO.
    DEF VAR aux_flmudfai AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlprecar AS DECI                                    NO-UNDO.
    
    DEF BUFFER crawepr_migrado FOR crawepr.
    DEF BUFFER crapprp_migrado FOR crapprp.

    IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p 
           PERSISTENT SET h-b1wgen0002.
    
    IF NOT VALID-HANDLE(h-b1wgen0043) THEN
       RUN sistema/generico/procedures/b1wgen0043.p 
           PERSISTENT SET h-b1wgen0043.

    ASSIGN aux_nrinfcad = 1 /* Informacao Cadastral */
           aux_flgerlog = TRUE
           aux_flgtrans = FALSE
           aux_dsorigem = "MIGRACAO"
           aux_dstransa = "Migracao de emprestimo".

        /*MESSAGE "Obter dados - obtem-dados-proposta-emprestimo ".*/
        RUN obtem-dados-proposta-emprestimo 
           IN h-b1wgen0002(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT "AUTOCDC", /*par_nmdatela - fixme para ignorar revisao*/
                           INPUT 0,    /* par_inproces */
                           INPUT par_idorigem,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_dtmvtolt,
                           INPUT par_nrctrmgr,    /* par_nrctremp */
                           INPUT "A",  /* par_cddopcao */
                           INPUT par_inconfir, /*par_inconfir*/
                           INPUT par_flgerlog,
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
                        
       FIND FIRST tt-erro NO-LOCK NO-ERROR.
       IF AVAIL tt-erro THEN
          DO:
              RETURN "NOK".
          END.

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
                   ASSIGN aux_nrgarope = tt-dados-analise.nrgarope
                          aux_nrliquid = tt-dados-analise.nrliquid
                          aux_nrpatlvr = tt-dados-analise.nrpatlvr
                          aux_nrperger = tt-dados-analise.nrperger
                          aux_nrinfcad = tt-dados-analise.nrinfcad.
                          
                          
                   IF aux_nrgarope = 0 THEN
                      aux_nrgarope = 1.
                   
                   IF aux_nrliquid = 0 THEN
                      aux_nrliquid = 1.
                      
                   IF aux_nrpatlvr = 0 THEN
                      aux_nrpatlvr = 1.
                      
                   IF aux_nrperger = 0 THEN   
                      aux_nrperger = 1.
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
                       aux_dtnasct1 = tt-dados-avais.dtnascto
                       aux_vlrecjg1 = tt-dados-avais.vlrencjg.
              
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
                       aux_dtnasct2 = tt-dados-avais.dtnascto
                       aux_vlrecjg2 = tt-dados-avais.vlrencjg.
              
              END.
       END. 
       
       /*MESSAGE "Valida dados - valida-dados-gerais".*/
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
                                               INPUT par_qtpreemp, /*par_qtpreemp*/
                                               INPUT "",   /* par_dsctrliq */
                                               INPUT tt-dados-coope.vlmaxutl,
                                               INPUT 9999999999, /*tt-dados-coope.vlmaxleg,*/ /* aumentar valor para migrar sem erro FARIA*/
                                               INPUT tt-dados-coope.vlcnsscr,
                                               INPUT par_vlemprst,
                                               INPUT par_dtdpagto,
                                               INPUT par_inconfir,    /* par_inconfir FARIA*/
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
                                               INPUT par_idcarenc, /*par_idcarenc*/
                                               INPUT par_dtcarenc, /*par_dtcarenc*/
                                               INPUT 0, /*par_idfiniof*/
                                               INPUT 1, /*par_idquapro*/
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
                                               
       
       
       FIND FIRST tt-erro NO-LOCK NO-ERROR.
       IF AVAIL tt-erro THEN
           RETURN "NOK".
       
       /*MESSAGE "Valida rating - valida-itens-rating".*/
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
    
       FIND FIRST tt-erro NO-LOCK NO-ERROR.
       IF AVAIL tt-erro THEN
          RETURN "NOK".

       /*MESSAGE "Valida analise - valida-analise-proposta".*/
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
    
       FIND FIRST tt-erro NO-LOCK NO-ERROR.
       IF AVAIL tt-erro THEN
           RETURN "NOK".
          
       /*MESSAGE "Valida montagem - monta_registros_proposta".*/
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
       
       /*MESSAGE "Grava proposta - grava-proposta-completa".*/
       RUN grava-proposta-completa IN h-b1wgen0002(INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT "MIGRACAO", /*par_nmdatela,*/
                                                   INPUT par_idorigem,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_dtmvtolt,
                                                   INPUT tt-dados-assoc.inpessoa,
                                                   INPUT par_nrctremp, /* par_nrctremp */
                                                   INPUT par_tpemprst, /* par_tpemprst */
                                                   INPUT FALSE, /* par_flgcmtlc */
                                                   INPUT aux_vlutiliz,
                                                   INPUT 0, /* par_vllimapv */
                                                   INPUT par_cddopcao,
                                                   /*---Dados para a crawepr---*/
                                                   INPUT par_vlemprst,
                                                   INPUT 0, /* par_vlpreant */
                                                   INPUT tt-proposta-epr.vlpreemp, /*par_vlpreemp*/
                                                   INPUT par_qtpreemp,
                                                   INPUT tt-proposta-epr.nivrisco,
                                                   INPUT par_cdlcremp,
                                                   INPUT par_cdfinemp,
                                                   INPUT 0, /* par_qtdialib */
                                                   INPUT TRUE, /* par_flgimppr */
                                                   INPUT FALSE, /* par_flgimpnp */
                                                   INPUT 0, /*par_percetop*/
                                                   INPUT 1, /* par_idquapro */
                                                   INPUT par_dtdpagto,
                                                   INPUT 0, /* par_qtpromis */
                                                   INPUT FALSE, /* par_flgpagto */
                                                   INPUT "", /* par_dsctrliq */
                                                   INPUT aux_nrctaava,  /* par_nrctaava */
                                                   INPUT aux_nrctaav2,  /* par_nrctaav2 */
                                                   INPUT par_idcarenc, /*par_idcarenc*/
                                                   INPUT par_dtcarenc, /*par_dtcarenc*/
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
                                                   INPUT aux_flgdocje, /*par_flgdocje*/
                                                   INPUT aux_nrctacje,
                                                   INPUT aux_nrcpfcje,
                                                   INPUT aux_perfatcl,
                                                   INPUT aux_vlmedfat,
                                                   INPUT FALSE,
                                                   INPUT FALSE,
                                                   INPUT tt-proposta-epr.dsobserv, /*par_dsobserv*/
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
                                                   INPUT aux_vlrecjg1, /*par_vlrecjg1*/
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
                                                   INPUT aux_vlrecjg2, /*/*par_vlrecjg2*/*/
                                                   INPUT "", /*par_dsdbeavt*/
                                                   INPUT aux_flgerlog,
                                                   INPUT aux_dsjusren,
                                                   INPUT par_dtmvtolt,
                                                   INPUT 0,/*par_idcobope*/
                                                   INPUT 0, /*par_idfiniof*/
                                                   INPUT "", /*par_dscatbem*/
                                                   INPUT 1, /* par_inresapr */
                                                   INPUT "TP", /*par_dsdopcao*/
                                                   INPUT 0, /*par_ingarapr*/
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-msg-confirma,
                                                   OUTPUT aux_recidepr,
                                                   OUTPUT par_nrnvcemp,
                                                   OUTPUT aux_flmudfai).
       
       FIND FIRST tt-erro NO-LOCK NO-ERROR.
       IF AVAIL tt-erro THEN
           RETURN "NOK".

        DO WHILE TRUE:
    
           FIND  crawepr_migrado WHERE crawepr_migrado.cdcooper = par_cdcooper AND
                                       crawepr_migrado.nrdconta = par_nrdconta AND
                                       crawepr_migrado.nrctremp = par_nrnvcemp
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
           IF NOT AVAILABLE crawepr_migrado THEN
              IF LOCKED crawepr_migrado THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
              ELSE
                 DO:
                    ASSIGN aux_dscritic = "Proposta nao encontrada".
                    LEAVE.
                 END.
    
           LEAVE.
    
        END.  /*  Fim do DO WHILE TRUE  */     

       ASSIGN crawepr_migrado.dsobscmt = tt-proposta-epr.dsobscmt
              crawepr_migrado.percetop = 0.

       /* PRP*/
       DO WHILE TRUE:
    
           FIND  crapprp_migrado WHERE crapprp_migrado.cdcooper = par_cdcooper AND
                                       crapprp_migrado.nrdconta = par_nrdconta AND
                                       crapprp_migrado.nrctrato = par_nrnvcemp
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crapprp_migrado THEN
              IF LOCKED crapprp_migrado THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
              ELSE
                 DO:
                    ASSIGN aux_dscritic = "Proposta nao encontrada".
                    LEAVE.
                 END.
    
           LEAVE.
    
        END.  /*  Fim do DO WHILE TRUE  */   
        
       ASSIGN crapprp_migrado.nrinfcad = aux_nrinfcad. 
       
       IF tt-dados-assoc.inpessoa = 1 THEN
           DO:
               DO WHILE TRUE:
        
                   FIND crapttl WHERE  crapttl.cdcooper = par_cdcooper     AND
                                       crapttl.nrdconta = par_nrdconta     AND
                                       crapttl.idseqttl = par_idseqttl 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                   IF  NOT AVAILABLE crapttl   THEN
                        IF  LOCKED crapttl   THEN
                           DO:
                               ASSIGN aux_dscritic = "Registro de titular em " + 
                                                     "uso. Tente novamente.".
                                      aux_cdcritic = 0.                    
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                           END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 821.
                                LEAVE.
                            END.
        
                   aux_dscritic = "".
                   LEAVE.
        
               END. /* Final do DO .. TO */    

               ASSIGN crapttl.nrinfcad = aux_nrinfcad
                      crapttl.nrpatlvr = aux_nrpatlvr.
           END.
       ELSE
           DO:
               DO WHILE TRUE:
    
                   FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                      crapjur.nrdconta = par_nrdconta 
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                   IF  NOT AVAILABLE crapjur   THEN
                       IF  LOCKED crapjur   THEN
                           DO:
                               ASSIGN aux_dscritic = "Registro de titular em " + 
                                                     "uso. Tente novamente.".
                                      aux_cdcritic = 0.                    
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                           END.
                       ELSE
                           DO:
                               ASSIGN aux_cdcritic = 564.
                               LEAVE.
                           END.
    
                   aux_dscritic = "".
                   LEAVE.
    
               END. /* Final do DO .. TO */    

               ASSIGN crapjur.nrinfcad = aux_nrinfcad
                      crapjur.nrpatlvr = aux_nrpatlvr
                      crapjur.nrperger = aux_nrperger.
           END.
           

    RETURN "OK".

END PROCEDURE. /* END criar_proposta */

PROCEDURE altera-numero-proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrant AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR         aux_contador AS INTE                           NO-UNDO.
    DEF  VAR         aux_dsoperac AS CHAR                           NO-UNDO.
    DEF  VAR         h-b1wgen0110 AS HANDLE                         NO-UNDO.
    DEF  VAR         aux_nrctremp AS INTE                           NO-UNDO.

    DEF  BUFFER      crabavt      FOR crapavt.
    DEF  BUFFER      crabavl      FOR crapavl.
    DEF  BUFFER      crabbpr      FOR crapbpr.
    DEf  BUFFER      crabrpr      FOR craprpr.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar o numero da proposta de credito".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapass THEN
       DO:
          ASSIGN aux_cdcritic = 9.

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

       END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar o numero do contrato da "  +
                          "proposta de emprestimo/financiamento na conta " +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                          " - CPF/CNPJ "                                   +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),"xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 11, /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel verificar o " +
                                      "cadastro restritivo.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.

          RETURN "NOK".

       END.

    DO TRANSACTION WHILE TRUE:
        
        
        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                           craplcr.cdlcremp = par_cdlcremp
                           NO-LOCK NO-ERROR.

        IF   AVAIL craplcr   THEN
             IF   NOT CAN-DO("1,4", STRING(craplcr.tpctrato)) THEN
                  DO:
                      aux_dscritic =
                          "Tipo de linha nao permitida nesta alteracao.".
                      LEAVE.
                  END.
        

        /* Verifica se ja existe contrato com o numero informado */
        FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                           crawepr.nrdconta = par_nrdconta   AND
                           crawepr.nrctremp = par_nrctremp
                           NO-LOCK NO-ERROR.

        IF   AVAIL crawepr   THEN
             DO:
                 aux_dscritic =
                     "Numero da proposta de emprestimo ja existente.".
                 LEAVE.
             END.

        /* Verifica se o contrato atual ja foi efetivado. */
        FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                           crapepr.nrdconta = par_nrdconta AND
                           crapepr.nrctremp = par_nrctrant
                           NO-LOCK NO-ERROR.

        IF   AVAIL crapepr   THEN
             DO:
                aux_dscritic = "Proposta ja efetivada.".
                LEAVE.
             END.


        /* BNDES */
        FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper  AND
                                 crapprp.nrdconta = par_nrdconta  AND
                                 crapprp.nrctrato = par_nrctremp  AND
                                 crapprp.tpctrato = 90
                           NO-LOCK NO-ERROR.

        IF   AVAIL crapprp   THEN
             DO:
                 aux_dscritic =
                     "Numero de proposta BNDES ja existente.".
                 LEAVE.
             END.


        DO aux_contador = 1 TO 10:

            FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                               crawepr.nrdconta = par_nrdconta   AND
                               crawepr.nrctremp = par_nrctrant
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crawepr   THEN
                 IF   LOCKED crawepr   THEN
                      DO:
                          aux_cdcritic = 371.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          aux_cdcritic = 356.
                          LEAVE.
                      END.

            aux_cdcritic = 0.
            LEAVE.

        END. /* Tratamento Lock crawepr */

                /*Se for Portabilidade Credito Tpfinali = 2 
                  nao permite alterar o numero da proposta*/
                FIND crapfin WHERE crapfin.cdcooper = crawepr.cdcooper
                               AND crapfin.cdfinemp = crawepr.cdfinemp
                                           AND crapfin.tpfinali = 2 NO-LOCK NO-ERROR. 

        IF AVAIL(crapfin) THEN
           DO:
               aux_dscritic = "Nao e permitido alterar o numero da proposta de portabilidade".
               LEAVE.
           END.
        
        IF   aux_cdcritic <> 0 OR
             aux_dscritic <> ""  THEN
             UNDO, LEAVE.

        /* Mudar o numero do contrato */
        ASSIGN aux_nrctremp     = crawepr.nrctremp
               crawepr.nrctremp = par_nrctremp.

        VALIDATE crawepr.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT 0
                                              ,INPUT crawepr.idcobope
                                              ,INPUT crawepr.nrctremp
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic 
               WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
             UNDO, LEAVE.     
        
        /* Avalistas terceiros, intervenientes anuentes */
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper        AND
                               crapavt.nrdconta = par_nrdconta        AND
                               CAN-DO("1,9",STRING(crapavt.tpctrato)) AND
                               crapavt.nrctremp = par_nrctrant        NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavt WHERE crabavt.cdcooper = crapavt.cdcooper   AND
                                   crabavt.nrdconta = crapavt.nrdconta   AND
                                   crabavt.tpctrato = crapavt.tpctrato   AND
                                   crabavt.nrctremp = crapavt.nrctremp   AND
                                   crabavt.nrcpfcgc = crapavt.nrcpfcgc
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF    NOT AVAIL crabavt   THEN
                      IF   LOCKED crabavt   THEN
                           DO:
                               aux_cdcritic = 77.
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                           END.
                      ELSE
                           DO:
                               aux_cdcritic = 869.
                               LEAVE.
                           END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0   THEN
                 LEAVE.

            /* Atualizar numero contrato */
            ASSIGN crabavt.nrctremp = par_nrctremp.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        /* Avalistas cooperados */
        FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper   AND
                               crapavl.nrctaavd = par_nrdconta   AND
                               crapavl.nrctravd = par_nrctrant   AND
                               crapavl.tpctrato = 1              NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavl WHERE crabavl.cdcooper = crapavl.cdcooper   AND
                                   crabavl.nrdconta = crapavl.nrdconta   AND
                                   crabavl.nrctravd = crapavl.nrctravd   AND
                                   crabavl.tpctrato = crapavl.tpctrato
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabavl   THEN
                     IF   LOCKED crabavl   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              aux_cdcritic = 869.
                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0   THEN
                 LEAVE.

            /* Mudar o numero do contrato */
            ASSIGN crabavl.nrctravd = par_nrctremp.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        /* Bens das propostas */
        FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper    AND
                               crapbpr.nrdconta = par_nrdconta    AND
                               crapbpr.tpctrpro = 90              AND
                               crapbpr.nrctrpro = par_nrctrant    NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabbpr WHERE crabbpr.cdcooper = crapbpr.cdcooper   AND
                                   crabbpr.nrdconta = crapbpr.nrdconta   AND
                                   crabbpr.tpctrpro = crapbpr.tpctrpro   AND
                                   crabbpr.nrctrpro = crapbpr.nrctrpro   AND
                                   crabbpr.idseqbem = crapbpr.idseqbem
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabbpr   THEN
                     IF   LOCKED crabbpr   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              ASSIGN aux_dscritic = "Descricao dos bens da proposta " +
                                                    "de emprestimo nao encontrada.".
                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.

            ASSIGN crabbpr.nrctrpro = par_nrctremp.

        END. /* Fim bens das propostas */

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        /* Proposta */
        DO aux_contador = 1 TO 10:

            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                               crapprp.nrdconta = par_nrdconta   AND
                               crapprp.tpctrato = 90             AND
                               crapprp.nrctrato = par_nrctrant
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF    NOT AVAIL crapprp   THEN
                  IF   LOCKED crapprp   THEN
                       DO:
                           aux_cdcritic = 371.
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                  ELSE
        
        DO:
                           aux_cdcritic = 510.
                           LEAVE.
                       END.

            aux_cdcritic = 0.
            LEAVE.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        /* Novo numero de contrato */
        ASSIGN crapprp.nrctrato = par_nrctremp.
        RELEASE crapprp.


        /* Rendimentos da proposta */
        FOR EACH craprpr WHERE craprpr.cdcooper = par_cdcooper   AND
                               craprpr.nrdconta = par_nrdconta   AND
                               craprpr.tpctrato = 90             AND
                               craprpr.nrctrato = par_nrctrant   NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabrpr WHERE crabrpr.cdcooper = craprpr.cdcooper   AND
                                   crabrpr.nrdconta = craprpr.nrdconta   AND
                                   crabrpr.tpctrato = craprpr.tpctrato   AND
                                   crabrpr.nrctrato = craprpr.nrctrato   AND
                                   crabrpr.tpdrendi = craprpr.tpdrendi
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabrpr   THEN
                     IF   LOCKED crabrpr   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              ASSIGN aux_dscritic = "Registro de rendimento " +
                                                    "do cooperado nao encontrado.".

                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.

            /* Novo numero de contrato */
            ASSIGN crabrpr.nrctrato = par_nrctremp.

        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        IF   crawepr.tpemprst = 1   THEN
             DO:
                 IF NOT VALID-HANDLE(h-b1wgen0084) THEN
                 RUN sistema/generico/procedures/b1wgen0084.p
                     PERSISTENT SET h-b1wgen0084.

                 RUN altera_numero_proposta_parcelas IN h-b1wgen0084 (
                     INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT par_dtmvtolt,
                     INPUT par_flgerlog,
                     INPUT par_nrctrant,
                     INPUT crawepr.nrctremp,
                     OUTPUT TABLE tt-erro).

                 IF VALID-HANDLE(h-b1wgen0084) THEN 
                 DELETE OBJECT h-b1wgen0084.

                 IF   RETURN-VALUE <> "OK"   THEN
                      DO:
                          FIND FIRST tt-erro NO-ERROR.
                          IF AVAIL tt-erro   THEN
                             aux_dscritic = tt-erro.dscritic.
                          ELSE
                             aux_dscritic = "Ocorreram erros durante a "
                                           + "gravacao das parcelas da "
                                           + "proposta.".

                          EMPTY TEMP-TABLE tt-erro.

                          UNDO, LEAVE.
                      END.
             END.
        ELSE IF crawepr.tpemprst = 2 THEN
             DO:
                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                 /* Efetuar a chamada a rotina Oracle  */
                 RUN STORED-PROCEDURE pc_alt_numero_parcelas_pos
                     aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                          INPUT par_nrdconta,
                                                          INPUT par_nrctrant,
                                                          INPUT crawepr.nrctremp,
                                                         OUTPUT 0,   /* pr_cdcritic */
                                                         OUTPUT ""). /* pr_dscritic */  

                 /* Fechar o procedimento para buscarmos o resultado */ 
                 CLOSE STORED-PROC pc_alt_numero_parcelas_pos
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = ""
                        aux_cdcritic = INT(pc_alt_numero_parcelas_pos.pr_cdcritic) 
                                       WHEN pc_alt_numero_parcelas_pos.pr_cdcritic <> ?
                        aux_dscritic = pc_alt_numero_parcelas_pos.pr_dscritic
                                       WHEN pc_alt_numero_parcelas_pos.pr_dscritic <> ?.

                 IF   aux_cdcritic <> 0    OR
                      aux_dscritic <> ""   THEN
                      UNDO, LEAVE.
             END.

        LEAVE.

    END. /* Fim TRANSACTION , tratamento criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             IF  par_flgerlog  THEN
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

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    IF  par_flgerlog  THEN
        DO:

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

            IF  aux_nrctremp <> par_nrctremp THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "nrctremp",
                                         INPUT aux_nrctremp,
                                         INPUT par_nrctremp).
        END.
     
    RETURN "OK".

END PROCEDURE. /*altera-numero-proposta*/

PROCEDURE migrar_dados_tr:
    
    DEF VAR aux_cdcooper LIKE crapcop.cdcooper                      NO-UNDO.
    DEF VAR aux_nrdconta LIKE crapass.nrdconta                      NO-UNDO.
    DEF VAR aux_nrctremp LIKE crawepr.nrctremp                      NO-UNDO.
    DEF VAR aux_nrctrmgr LIKE crawepr.nrctremp                      NO-UNDO.
    DEF VAR aux_nrctrnov LIKE crawepr.nrctremp                      NO-UNDO.
    DEF VAR aux_cdfinemp LIKE crawepr.nrctremp                      NO-UNDO.
    DEF VAR aux_cdlcremp LIKE crawepr.cdlcremp                      NO-UNDO.
    DEF VAR aux_dtmvtolt LIKE crapdat.dtmvtolt                      NO-UNDO.
    DEF VAR aux_dtmvtopr LIKE crapdat.dtmvtopr                      NO-UNDO.
    DEF VAR aux_vlsdeved LIKE crawepr.vlemprst                      NO-UNDO.
    DEF VAR aux_vltotpag LIKE crawepr.vlemprst                      NO-UNDO.
    DEF VAR aux_idcarenc AS INTE                                    NO-UNDO.
    DEF VAR aux_dtcarenc AS DATE                                    NO-UNDO.
    DEF VAR aux_dtcarenc_string AS CHAR                             NO-UNDO.
    
    DEF VAR aux_cdagenci LIKE crawepr.cdagenci                      NO-UNDO.
    DEF VAR aux_cdoperad LIKE crawepr.cdoperad                      NO-UNDO.
    
    DEF VAR aux_qtpreapg AS DECIMAL DECIMALS 4                      NO-UNDO.
    DEF VAR aux_dtdpagto AS DATE                                    NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.
    DEF VAR aux_qtparatu AS INTE                                    NO-UNDO.
    DEF VAR aux_dtlibera AS DATE                                    NO-UNDO.
    

    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_mensagem AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtpreemp LIKE crawepr.qtpreemp                      NO-UNDO.
    DEF VAR aux_tpctrato LIKE craplcr.tpctrato                      NO-UNDO.
    DEF  BUFFER crablcr_migracao FOR craplcr.
    DEF  BUFFER crawepr_migrado  FOR crawepr.
    
    IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p 
           PERSISTENT SET h-b1wgen0002.

    /* primeira chamada ler arquivo de carga*/
    RUN leitura_arquivo_carga (/**/
                               /**/
                               OUTPUT TABLE tt-registro-arquivo).

    IF NOT AVAIL tt-registro-arquivo THEN
       DO:
           MESSAGE "Tabela sem registros".
           RETURN "NOK".
       END.

    /*MESSAGE "leu arquivo".*/
    OUTPUT STREAM str_2 TO VALUE("/micros/cecred/james/migracao_log.csv").
    PUT STREAM str_2 UNFORMATTED "Cooperativa;Conta;Contrato Antigo;Contrato Novo;PA Cooperado;Saldo Liquida;Tipo Pessoa;Status" SKIP.

    MIGRACAEMPR: DO TRANSACTION ON ERROR  UNDO MIGRACAEMPR, LEAVE MIGRACAEMPR
                                ON ENDKEY UNDO MIGRACAEMPR, LEAVE MIGRACAEMPR:
    
      /* percorrer tabela*/
      FOR EACH tt-registro-arquivo EXCLUSIVE-LOCK:    
        
        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt-dados-epr.
        
        ASSIGN aux_cdcooper = tt-registro-arquivo.cdcooper
               aux_nrdconta = tt-registro-arquivo.nrdconta
               aux_nrctremp = tt-registro-arquivo.nrctremp
               aux_cdfinemp = tt-registro-arquivo.cdfinemp
               aux_cdlcremp = tt-registro-arquivo.cdlcremp
               aux_qtparatu = tt-registro-arquivo.qtparatu /* quantas prestacoes faltam, sera gerado no arquivo */
               aux_nrctrnov = INTE("80" + STRING(aux_nrctremp))
               aux_dscritic = "".

        FIND crawepr_migrado WHERE crawepr_migrado.cdcooper = aux_cdcooper AND 
                                   crawepr_migrado.nrdconta = aux_nrdconta AND
                                   crawepr_migrado.nrctremp = aux_nrctrnov
                                   NO-LOCK NO-ERROR.
                                   
        IF AVAIL crawepr_migrado THEN  
           DO:
               PUT STREAM str_2 UNFORMATTED aux_cdcooper ";"
                                            aux_nrdconta ";"
                                            aux_nrctrnov ";"
                                            " ;"
                                            " ;"
                                            " ;"
                                            " ;"
                                            "Contrato Ja Migrado"
                                            SKIP.
               NEXT.
           END.

        DO WHILE TRUE:
    
           FIND  crablcr_migracao WHERE crablcr_migracao.cdcooper = aux_cdcooper AND
                                        crablcr_migracao.cdlcremp = aux_cdlcremp
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
           IF NOT AVAILABLE crablcr_migracao THEN
              IF LOCKED crablcr_migracao THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
              ELSE
                 DO:
                    ASSIGN aux_dscritic = "Linha de Credito Nao Cadastrada".
                    LEAVE.
                 END.
    
           LEAVE.
    
        END.  /*  Fim do DO WHILE TRUE  */

        IF aux_dscritic <> "" THEN
           DO:
                PUT STREAM str_2 UNFORMATTED aux_cdcooper ";"
                                             aux_nrdconta ";"
                                             aux_nrctremp ";"
                                             " ;"
                                             " ;"
                                             " ;"
                                             " ;"
                                             "Linha de Credito Nao Cadastrada"
                                             SKIP.
                NEXT.
           END.
        
        ASSIGN crablcr_migracao.flgdisap = TRUE
               aux_tpctrato              = crablcr_migracao.tpctrato.

        /* segunda chamada validar se a proposta pode ser migrada*/
       /* MESSAGE "Numero  conta: "aux_nrdconta.
        MESSAGE "Numero empres: "aux_nrctremp.
        MESSAGE "Novo   numero: "aux_nrctrnov.*/
    
        /*MESSAGE "Valida proposta".*/
        RUN valida_dados(INPUT aux_cdcooper,
                         INPUT aux_nrdconta,
                         INPUT aux_nrctremp,
                         OUTPUT aux_dtmvtolt,
                         OUTPUT aux_dtmvtopr,
                         OUTPUT aux_cdagenci,
                         OUTPUT aux_cdoperad,
                         OUTPUT aux_dscritic).
                           
        /*MESSAGE "Retorno Valida proposta: " aux_dscritic.*/
        IF aux_dscritic <> "" THEN
           DO:
               PUT STREAM str_2 UNFORMATTED aux_cdcooper ";"
                                            aux_nrdconta ";"
                                            aux_nrctremp ";"
                                            " ;"
                                            " ;"
                                            " ;"
                                            " ;"
                                            aux_dscritic
                                            SKIP.
           NEXT.
           END.     

        /*MESSAGE "Dados emprestimo - obtem-dados-emprestimos".*/
        RUN obtem-dados-emprestimos
            IN h-b1wgen0002 (INPUT aux_cdcooper, /*par_cdcooper*/
                             INPUT aux_cdagenci, /*par_cdagenci*/
                             INPUT 0, /*par_cdbccxlt*/
                             INPUT aux_cdoperad, /*par_cdoperad*/
                             INPUT "MIGRACAO", /*"ATENDA", /*par_nmdatela*/ */
                             INPUT 5, /*par_idorigem*/
                             INPUT aux_nrdconta, /*par_nrdconta*/
                             INPUT 1, /*par_idseqttl*/
                             INPUT aux_dtmvtolt, /*par_dtmvtolt*/
                             INPUT aux_dtmvtopr, /*par_dtmvtopr*/
                             INPUT aux_dtmvtolt, /*par_dtcalcul*/
                             INPUT aux_nrctremp, /*par_nrctremp*/
                             INPUT 1, /*par_cdprogra*/
                             INPUT 0, /*par_inproces*/
                             INPUT false, /*par_flgerlog*/
                             INPUT false, /*par_flgcondc*/
                             INPUT 0, /** nriniseq **/
                             INPUT 0, /** nrregist **/
                             OUTPUT aux_qtregist,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-dados-epr).
        
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF AVAIL tt-erro THEN
           DO:
               UNDO MIGRACAEMPR, LEAVE MIGRACAEMPR.
           END.

        FIND FIRST tt-dados-epr NO-LOCK NO-ERROR.
            IF AVAIL tt-dados-epr THEN
                DO:
                    ASSIGN aux_vlsdeved = tt-dados-epr.vlsdeved
                           /*aux_qtparatu = ROUND(tt-dados-epr.qtpreemp - tt-dados-epr.qtprecal,0) - sera gerado no arquivo*/
                           aux_dtdpagto = tt-dados-epr.dtdpagto
                           aux_qtpreapg = ROUND(tt-dados-epr.qtprecal,0).
                           aux_qtpreemp = tt-dados-epr.qtpreemp.
                END.

        ASSIGN aux_idcarenc = 0
               aux_dtcarenc = ?.
        /*se os meses decorridos for igual 0 deve considerar carencia*/
        /*comentado para migrar contrato especifico*/
		   /*IF tt-dados-epr.qtmesdec=0 THEN
          DO:
           ASSIGN aux_idcarenc = 2
                  aux_dtlibera = aux_dtmvtolt.

           ASSIGN aux_dtcarenc = DATE(SUBSTR(STRING(aux_dtdpagto),1,2) + "/" + SUBSTR(STRING(aux_dtlibera),4,2) + "/" + SUBSTR(STRING(aux_dtmvtolt),7,4)).
           ASSIGN aux_dtcarenc = aux_dtcarenc + 30.
           ASSIGN aux_dtcarenc = DATE(SUBSTR(STRING(aux_dtdpagto),1,2) + "/" + SUBSTR(STRING(aux_dtcarenc),4,2) + "/" + SUBSTR(STRING(aux_dtcarenc),7,4)).
		     END.
		   */

        /*
		    MESSAGE "tt-dados-epr.qtmesdec"tt-dados-epr.qtmesdec.
        MESSAGE "aux_dtmvtolt"aux_dtmvtolt.
        MESSAGE "aux_dtcarenc"aux_dtcarenc.
        MESSAGE "aux_dtdpagto"aux_dtdpagto.
        */

           /*
           Regra de criaçao da data de carencia
           PHP
           var idcarenc = normalizaNumero($("#idcarenc", "#frmNovaProp").val());
           var dtlibera = $("#dtlibera", "#frmNovaProp").val();
           var dtdpagto = $("#dtdpagto", "#frmNovaProp").val();
           var dtcarenc = dtdpagto.substr(0, 2) + '/' + dtlibera.substr(3, 2) + '/' + dtmvtolt.substr(6, 4);
           ORACLE           
            IF vr_qtddias > 0 THEN
              vr_dd := SUBSTR(pr_dtcarenc,1,2);
              BEGIN
                IF TO_NUMBER(vr_dd) >= 28 THEN
                  vr_dscritic := 'Data de Pagamento nao pode ser maior ou igual ao dia 28.';
                  RAISE vr_exc_saida;
                END IF;
                vr_dtcarenc := TO_DATE(pr_dtcarenc, 'DD/MM/RRRR');
                vr_dtcarenc := vr_dtcarenc + vr_qtddias;
                vr_mmaaaa   := TO_CHAR(vr_dtcarenc,'MM/RRRR');
                vr_dtcarenc := TO_DATE(vr_dd || '/' || vr_mmaaaa, 'DD/MM/RRRR');
              EXCEPTION
                WHEN vr_exc_saida THEN
                  RAISE vr_exc_saida;
                WHEN OTHERS THEN
                  vr_dscritic := 'Data da carencia é inválida.';
                  RAISE vr_exc_saida;
              END;
            END IF;
           
           */
           
           

        /*MESSAGE "Data movto....: " aux_dtmvtolt.
        MESSAGE "Saldo devedor.: " aux_vlsdeved.
        MESSAGE "Parceltas tota: " tt-dados-epr.qtpreemp.
        MESSAGE "Parcelas pagas: " aux_qtpreapg.
        MESSAGE "Parc. a pagar.: " aux_qtparatu.
        MESSAGE "Data pagamento: " aux_dtdpagto.*/

        /*MESSAGE "Criar proposta".*/
        RUN criar_proposta(INPUT aux_cdcooper, /*par_cdcooper*/
                           INPUT aux_nrdconta, /*par_nrdconta*/
                           INPUT 0, /*par_nrctremp*/
                           INPUT aux_nrctremp, /*par_nrctrmgr*/
                           INPUT aux_cdfinemp, /*par_cdfinemp*/
                           INPUT aux_cdlcremp,  /*par_cdlcremp*/
                           INPUT aux_dtmvtolt, /*par_dtmvtolt*/
                           INPUT aux_vlsdeved, /*par_vlemprst*/
                           INPUT aux_qtparatu, /*par_qtpreemp*/
                           INPUT aux_dtdpagto, /*par_dtdpagto*/
                           INPUT aux_dtmvtopr, /*par_dtmvtopr*/
                           INPUT 2, /*par_tpemprst*/
                           INPUT aux_idcarenc, /*par_idcarenc*/
                           INPUT aux_dtcarenc, /*par_dtcarenc*/
                           /*fixos*/
                           INPUT aux_cdagenci, /*par_cdagenci*/
                           INPUT 0, /*par_nrdcaixa*/
                           INPUT aux_cdoperad, /*par_cdoperad*/
                           INPUT "ATENDA", /*par_nmdatela*/
                           INPUT 0, /*par_inproces*/
                           INPUT 5, /*par_idorigem*/
                           INPUT 1, /*par_idseqttl*/
                           INPUT "I", /*par_cddopcao*/
                           INPUT 0, /*par_inconfir*/
                           INPUT FALSE, /*par_flgerlog*/
                           OUTPUT aux_nrctrmgr, /*par_nrctremp*/
                           OUTPUT TABLE tt-erro).

        /*MESSAGE "Saiu do programa criar proposta: " RETURN-VALUE. */
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF AVAIL tt-erro THEN
             DO:
                 UNDO MIGRACAEMPR, LEAVE MIGRACAEMPR.
             END.
        
        /*MESSAGE "Altera numero da proposta". */
        ASSIGN crablcr_migracao.tpctrato = 1. /*manipular para poder trocar o numero*/
        /*RELEASE craplcr.*/
        RUN altera-numero-proposta (INPUT aux_cdcooper, /*par_cdcooper*/
                                    INPUT aux_cdagenci, /*par_cdagenci*/
                                    INPUT 0, /*par_nrdcaixa*/
                                    INPUT aux_cdoperad, /*par_cdoperad*/
                                    INPUT "ATENDA", /*par_nmdatela*/
                                    INPUT 5, /*par_idorigem*/
                                    INPUT aux_nrdconta, /*par_nrdconta*/
                                    INPUT 1, /*par_idseqttl*/
                                    INPUT aux_dtmvtolt, /*par_dtmvtolt*/
                                    INPUT aux_nrctrmgr, /*par_nrctrant*/
                                    INPUT aux_nrctrnov, /*par_nrctremp*/
                                    INPUT aux_cdlcremp, /*par_cdlcremp*/
                                    INPUT true, /*par_flgerlog*/
                                    OUTPUT TABLE tt-erro).
        /*retorna o valor original*/                            
        ASSIGN crablcr_migracao.tpctrato = aux_tpctrato. 

        FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF AVAIL tt-erro THEN
             DO:
                 UNDO MIGRACAEMPR, LEAVE MIGRACAEMPR.
             END.

        /*MESSAGE "Efetivar proposta - efetiva_proposta".*/
        RUN efetiva_proposta (INPUT aux_cdcooper, /*par_cdcooper */
                              INPUT aux_cdagenci, /*par_cdagenci */
                              INPUT 0, /*par_nrdcaixa */
                              INPUT aux_cdoperad, /*par_cdoperad */
                              INPUT "ATENDA", /*par_nmdatela */
                              INPUT 5, /*par_idorigem */
                              INPUT aux_nrdconta, /*par_nrdconta */
                              INPUT 1, /*par_idseqttl */
                              INPUT aux_dtmvtolt, /*par_dtmvtolt */
                              INPUT false, /*par_flgerlog */
                              INPUT aux_nrctrnov, /*par_nrctremp */
                              INPUT 0, /*par_insitapr */
                              INPUT "", /*par_dsobscmt */
                              INPUT aux_dtdpagto, /*par_dtdpagto */
                              INPUT 1, /*par_cdbccxlt */
                              INPUT 1, /*par_nrdolote */
                              INPUT aux_dtmvtopr, /*par_dtmvtopr */
                              INPUT 0, /*par_inproces */
                              INPUT 0, /*par_nrcpfope */
                              OUTPUT aux_mensagem,
                              OUTPUT TABLE tt-ratings,
                              OUTPUT TABLE tt-erro).

        FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF AVAIL tt-erro THEN
             DO:
                 UNDO MIGRACAEMPR, LEAVE MIGRACAEMPR.
             END.

        /* Somente efetua a reordenacao se nao tiver carencia, pois o emprestimo
           ja esta sendo criado na ordem correta */
        IF tt-dados-epr.qtmesdec <> 0 THEN
          DO:
            /*MESSAGE "altera_parcelas".*/
            RUN altera_parcelas(INPUT aux_cdcooper, /*par_cdcooper*/
                                INPUT aux_nrdconta, /*par_nrdconta*/
                                INPUT aux_nrctrnov, /*par_nrctremp*/
                                INPUT aux_qtpreemp, /*par_qtpreemp*/
                                OUTPUT aux_dscritic).
                               
            /*MESSAGE "Retorno altera parcela: " aux_dscritic.*/
            IF aux_dscritic <> "" THEN
               DO:
                   UNDO MIGRACAEMPR, LEAVE MIGRACAEMPR.
               END.
          END.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        /*liquidacao de contrato TR*/   
        /*MESSAGE "pc_gera_lancamento_epr_tr".*/
        RUN STORED-PROCEDURE pc_gera_lancamento_epr_tr
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper, /* pr_cdcooper */
                                             INPUT aux_nrdconta, /* pr_nrdconta */
                                             INPUT aux_nrctremp, /* pr_nrctremp */
                                             INPUT aux_vlsdeved, /* pr_vllanmto */
                                             INPUT aux_cdoperad, /* pr_cdoperad */
                                             INPUT 5, /* pr_idorigem */
                                             INPUT "MIGRACAO", /* pr_nmtelant */
                                             OUTPUT 0, /* pr_vltotpag */
                                             OUTPUT 0, /* pr_cdcritic */
                                             OUTPUT ""). /* pr_dscritic */
       
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_gera_lancamento_epr_tr
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_vltotpag = pc_gera_lancamento_epr_tr.pr_vltotpag
                         WHEN pc_gera_lancamento_epr_tr.pr_vltotpag <> ?
               aux_cdcritic = pc_gera_lancamento_epr_tr.pr_cdcritic
                         WHEN pc_gera_lancamento_epr_tr.pr_cdcritic <> ?
               aux_dscritic = pc_gera_lancamento_epr_tr.pr_dscritic
                         WHEN pc_gera_lancamento_epr_tr.pr_dscritic <> ?.

        IF aux_dscritic <> "" THEN 
           DO:
               UNDO MIGRACAEMPR, LEAVE MIGRACAEMPR.
           END.  

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        /* Gravar Vendedor do emprestimo */ 
        /*MESSAGE "pc_grava_migra_empr".*/
        RUN STORED-PROCEDURE pc_grava_migra_empr
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper,
                                             INPUT aux_nrdconta,
                                             INPUT aux_nrctremp,
                                             INPUT aux_dtmvtolt, /*par_dtmvtolt*/
                                             INPUT aux_nrctrnov, /*par_nrctrnov*/
                                             OUTPUT "").
       
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_grava_migra_empr
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic = pc_grava_migra_empr.pr_dscritic
                         WHEN pc_grava_migra_empr.pr_dscritic <> ?.           

        IF aux_dscritic <> "" THEN 
           DO:
               UNDO MIGRACAEMPR, LEAVE MIGRACAEMPR.
           END.  
 
        ASSIGN tt-registro-arquivo.flgctrmg = TRUE
               tt-registro-arquivo.dscritic = aux_dscritic.           
        
        ASSIGN crablcr_migracao.flgdisap = FALSE.
        
        FIND crapass WHERE crapass.cdcooper = aux_cdcooper AND
                           crapass.nrdconta = aux_nrdconta
                           NO-LOCK NO-ERROR.
                           
        PUT STREAM str_2 UNFORMATTED aux_cdcooper ";"
                                     aux_nrdconta ";"
                                     aux_nrctremp ";"
                                     aux_nrctrnov ";"
                                     crapass.cdagenci ";"
                                     aux_vlsdeved ";"
                                     crapass.inpessoa ";"
                                     "OK"
                                     SKIP.
        /*Para tester e nao comitar os registros*/
        /*UNDO MIGRACAEMPR, LEAVE MIGRACAEMPR.*/

      END. /* IF tt-registro-arquivo*/

   END. /* END MIGRACAEMPR: DO TRANSACTION */

   
    IF VALID-HANDLE(h-b1wgen0002) THEN
       DELETE PROCEDURE h-b1wgen0002.

    FIND FIRST tt-erro NO-LOCK NO-ERROR.
    IF AVAIL tt-erro THEN
       ASSIGN aux_dscritic = STRING(tt-erro.cdcritic) + " - " + tt-erro.dscritic.

    IF aux_dscritic <> "" THEN
       DO:
          PUT STREAM str_2 UNFORMATTED aux_cdcooper ";"
                                       aux_nrdconta ";"
                                       aux_nrctremp ";"
                                       aux_nrctrnov ";"
                                       " ;"
                                       " ;"
                                       " ;"
                                       aux_dscritic
                                       SKIP.
       END.

END PROCEDURE. /* migrar_dados_tr */

RUN migrar_dados_tr.