
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0027tt.i }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/b1wgen0043tt.i  }
{ sistema/generico/includes/b1wgen0084tt.i  }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }



DEF VAR aux_dsmesage AS CHAR                           NO-UNDO.
DEF VAR h-b1wgen0084 AS HANDLE                         NO-UNDO. 
DEF VAR aux_dtmvtolt AS CHAR                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_flgalcad AS LOGI                                        NO-UNDO.
DEF VAR aux_dsnivris AS CHAR                                        NO-UNDO.

DEF VAR aux_valortax AS DECI DECIMALS 7 FORMAT  "zzz9.9999999"      NO-UNDO.
DEF VAR aux_valrnovo AS DECI DECIMALS 2                             NO-UNDO.
DEF VAR aux_mesrefer AS INTE                                        NO-UNDO.
DEF VAR aux_anorefer AS INTE                                        NO-UNDO.
DEF VAR aux_dtrefere AS DATE                                        NO-UNDO.
DEF VAR aux_diavecto AS INTE                                        NO-UNDO.

DEF VAR var_qtdiacar AS INTE                                        NO-UNDO.
DEF VAR var_vlajuepr AS DECI                                        NO-UNDO.
DEF VAR var_txdiaria AS DECI DECIMALS 10                            NO-UNDO.
DEF VAR var_txmensal AS DECI                                        NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                        NO-UNDO.
DEF VAR par_loginusr AS CHAR                                        NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                        NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                        NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                        NO-UNDO.
DEF VAR par_numipusr AS CHAR                                        NO-UNDO.


DEF VAR h-b1wgen0043 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0002 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.
DEF VAR hb1wgen0024  AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0134 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen084a AS HANDLE                                      NO-UNDO.

DEF VAR h-b1crapsab  AS HANDLE                                      NO-UNDO.
DEF TEMP-TABLE cratsab NO-UNDO LIKE crapsab.

DEF VAR aux_vlsdeved        AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"    NO-UNDO.
DEF BUFFER crabass   FOR crapass.
DEF BUFFER crablcr   FOR craplcr.
DEF BUFFER crablem   FOR craplem.
DEF BUFFER crabavl   FOR crapavl.
DEF BUFFER crabepr   FOR crapepr.

DEF VAR aux_titelavl AS CHARACTER FORMAT "x(61)"                    NO-UNDO.
DEF VAR aux_qtlintel AS INT     FORMAT "99"                         NO-UNDO.
DEF VAR aux_tpdsaldo AS INT                                         NO-UNDO.
DEF VAR aux_stimeout AS INT                                         NO-UNDO.
DEF VAR aux_inhst093 AS LOGICAL                                     NO-UNDO.
DEF VAR aux_qtprecal LIKE crapepr.qtprecal                          NO-UNDO.
DEF VAR aux_qtctaavl AS INT                                         NO-UNDO.
DEF VAR aux_avljaacu AS LOG                                         NO-UNDO.
DEF VAR aux_aprovavl AS LOG  FORMAT "Sim/Nao"                       NO-UNDO.
DEF VAR aux_cdempres AS INT                                         NO-UNDO.
DEF VAR tab_indpagto AS INT                                         NO-UNDO.
DEF VAR tab_dtcalcul AS DATE                                        NO-UNDO.
DEF VAR tab_dtlimcal AS DATE                                        NO-UNDO.
DEF VAR tab_flgfolha AS LOGICAL                                     NO-UNDO.
DEF VAR aux_inusatab AS LOGICAL                                     NO-UNDO.
DEF VAR tab_diapagto AS INTE                                        NO-UNDO.
DEF VAR tab_cdlcrbol AS INTE                                        NO-UNDO.

DEF  STREAM str_1.

DEF TEMP-TABLE  w-emprestimo                                        NO-UNDO
    FIELD nrdconta LIKE crapepr.nrdconta
    FIELD nrctremp LIKE crapepr.nrctremp
    FIELD dtmvtolt LIKE crapepr.dtmvtolt
    FIELD vlemprst LIKE crapepr.vlemprst
    FIELD qtpreemp LIKE crapepr.qtpreemp
    FIELD vlpreemp LIKE crapepr.vlpreemp
    FIELD vlsdeved LIKE aux_vlsdeved.
    
    
PROCEDURE buscar_historico_e_lote_efet_prop: 
    DEF  INPUT PARAM par_tpemprst AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idfiniof AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dsoperac AS CHAR                            NO-UNDO.
    
    DEF  OUTPUT PARAM par_cdhistor AS INTE                            NO-UNDO.
    DEF  OUTPUT PARAM par_cdhistor_tar AS INTE                            NO-UNDO.
    DEF  OUTPUT PARAM par_nrdolote AS INTE                            NO-UNDO.
    
    ASSIGN par_cdhistor = 0
           par_nrdolote = 0.
           
    
    /* Financia IOF - se financiar IOF, nunca vai ser TR */
    IF par_idfiniof = 1 THEN
      DO:        
        IF par_tpemprst = 1 THEN /* Pre-Fixado */
          DO:
            IF par_dsoperac = "FINANCIAMENTO" THEN
              ASSIGN par_cdhistor = 2305
                     par_cdhistor_tar = 2307
                     par_nrdolote = 600030.
                
            ELSE
              ASSIGN par_cdhistor = 2304
                     par_cdhistor_tar = 2306
                     par_nrdolote = 600005.
          END.
        ELSE
          IF par_tpemprst = 2 THEN /* Pos-Fixado */
            DO:
              IF par_dsoperac = "FINANCIAMENTO" THEN
                ASSIGN par_cdhistor = 2536
                       par_cdhistor_tar = 2307
                       par_nrdolote = 600030.
              ELSE
                ASSIGN par_cdhistor = 2535
                     par_cdhistor_tar = 2306
                       par_nrdolote = 600005.
            END.
      END.
    ELSE
      DO:
        /* Nao financia IOF */
        IF par_tpemprst = 1 THEN /* Pre-Fixado */
          DO:
          IF par_dsoperac = "FINANCIAMENTO" THEN
              ASSIGN par_cdhistor = 2309
                     par_nrdolote = 600030.
          ELSE
              ASSIGN par_cdhistor = 2308
                     par_nrdolote = 600005.
          END.
        ELSE
          IF par_tpemprst = 2 THEN /* Pos-Fixado */
            DO:
              IF par_dsoperac = "FINANCIAMENTO" THEN
                ASSIGN par_cdhistor = 2538
                       par_nrdolote = 600030.
                ELSE
                ASSIGN par_cdhistor = 2537
                       par_nrdolote = 600005.
            END.
        ELSE /* TR */             
          DO:
            ASSIGN par_cdhistor = 2310.
            IF par_dsoperac = "FINANCIAMENTO" THEN
                ASSIGN par_nrdolote = 600013.
            ELSE
                ASSIGN par_nrdolote = 600012.
          END.
      END.
        
    RETURN "OK".

END PROCEDURE.    


PROCEDURE valida_dados_efetivacao_proposta:

    DEFINE INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEFINE INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEFINE INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEFINE INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEFINE INPUT PARAM par_nrctremp AS INTE                            NO-UNDO.

    DEF VAR aux_contador AS INTE    NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGI    NO-UNDO.
    DEF VAR aux_cdempres AS INTE    NO-UNDO.
    DEF VAR aux_dsoperac AS CHAR    NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE  NO-UNDO.
    DEF VAR aux_nrctrliq AS CHAR    NO-UNDO.
    DEF VAR aux_flgativo AS INTEGER NO-UNDO.
    DEF VAR aux_flgcescr AS LOG INIT FALSE                             NO-UNDO.
          /* DEF VAR aux_flimovel AS INTEGER NO-UNDO. 17/02/2017 - Validaçao removida */

    DEF BUFFER crabbpr FOR crapbpr.
    
     ASSIGN aux_cdcritic = 0
            aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad
                       NO-LOCK.

    IF   aux_cdcritic <> 0 OR aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    RUN dig_fun IN h-b1wgen9999 ( INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT-OUTPUT par_nrdconta,
                                  OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen9999.
    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".


    FIND crapass WHERE crapass.nrdconta = par_nrdconta   AND
                       crapass.cdcooper = par_cdcooper   NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapass   THEN
         DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de efetivar proposta de "         +
                          "emprestimo/financiamento na conta "         +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")        +
                          " - CPF/CNPJ "                               +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).

    ASSIGN aux_cdempres = 0.

    IF  crapass.inpessoa = 1 THEN /*  Fisica */
        DO:
            FIND crapttl NO-LOCK WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl = par_idseqttl NO-ERROR.
            IF   AVAIL crapttl THEN
                 ASSIGN aux_cdempres = crapttl.cdempres.
        END.
    ELSE /*  Juridica */
        DO:
            FIND crapjur NO-LOCK WHERE crapjur.cdcooper = par_cdcooper AND
                                       crapjur.nrdconta = par_nrdconta NO-ERROR.
            IF   AVAIL crapjur THEN
                 ASSIGN aux_cdempres = crapjur.cdempres.
        END.

    FIND crapemp NO-LOCK WHERE
         crapemp.cdcooper = crapass.cdcooper AND
         crapemp.cdempres = aux_cdempres NO-ERROR.

    IF   NOT AVAIL crapemp THEN
         DO:
            ASSIGN aux_cdcritic = 40
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.

    IF  CAN-FIND(crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                               crapepr.nrdconta = par_nrdconta   AND
                               crapepr.nrctremp = par_nrctremp
                               USE-INDEX crapepr2)               THEN
        DO:
            ASSIGN aux_cdcritic = 92
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.


    FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper  AND
                           crapepr.nrdconta = par_nrdconta  AND
                           crapepr.nrctremp = par_nrctremp  AND
                           crapepr.dtmvtolt = par_dtmvtolt  NO-LOCK,
       FIRST crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                           crawepr.nrdconta = par_nrdconta  AND
                           crawepr.nrctremp = par_nrctremp  NO-LOCK:

        ASSIGN aux_contador = 1.

        DO  aux_contador = 1 TO 10 :

            IF  crawepr.nrctrliq[aux_contador] > 0 THEN
                DO:

                    IF  crawepr.nrctrliq[1]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[2]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[3]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[4]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[5]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[6]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[7]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[8]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[9]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[10] =
                        crawepr.nrctrliq[aux_contador] THEN

                        DO:
                            ASSIGN aux_cdcritic = 805
                                   aux_dscritic = "".

                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).

                            RETURN "NOK".

                        END.

                END. /* IF */
        END. /* DO */
    END. /* FOR EACH */

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                       crawepr.nrdconta = par_nrdconta   AND
                       crawepr.nrctremp = par_nrctremp   NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crawepr   THEN
         DO:
            ASSIGN aux_cdcritic = 535
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.
    ELSE DO:
        IF crawepr.insitapr <> 1  AND   /* Aprovado */
           crawepr.insitapr <> 3  THEN DO:  /* Aprovado com Restricao */
    
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "A proposta deve estar aprovada.".
         
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
        
              RETURN "NOK".
        END.
     
   FOR FIRST crapfin FIELDS(tpfinali)
        WHERE crapfin.cdcooper = par_cdcooper AND
              crapfin.cdfinemp = crawepr.cdfinemp
              NO-LOCK: END.    
    
    IF AVAIL crapfin AND crapfin.tpfinali = 1 THEN
       ASSIGN aux_flgcescr = TRUE.
          
    /* Validar apenas se nao for cessao de credito */
    IF  NOT aux_flgcescr THEN
        DO:
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
                                              INPUT 33, /*cdoperac*/
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
        END.
     
         /* Verificar se a analise foi finalizada */
        IF crawepr.insitest <> 3 THEN DO:
         ASSIGN aux_cdcritic = 0
                aux_dscritic = " A proposta nao pode ser efetivada, "
                                + " verifique a situacao da proposta".
        
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
        
              RETURN "NOK".
        END.

        /** Verificar "inliquid" do contrato relacionado a ser liquidado **/
        DO  aux_contador = 1 TO 10 :
            IF  crawepr.nrctrliq[aux_contador] > 0 THEN DO:

                IF  CAN-FIND(FIRST crabepr
                             WHERE crabepr.cdcooper = crawepr.cdcooper
                               AND crabepr.nrdconta = crawepr.nrdconta
                               AND crabepr.nrctremp = crawepr.nrctrliq[aux_contador]
                               AND crabepr.inliquid = 1) THEN DO:

                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Atencao: Exclua da proposta os contratos ja liquidados!".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 2,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
            
                    RETURN "NOK".
                END.
            END.
        END.

        /* Verificar se um dos bens da proposta ja se
           encontra alienado em outro contrato */
        FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper
                           AND crapbpr.nrdconta = par_nrdconta
                           AND crapbpr.nrctrpro = par_nrctremp
                           AND crapbpr.flgalien = TRUE
                           AND CAN-DO("AUTOMOVEL,MOTO,CAMINHAO,OUTROS VEICULOS",crapbpr.dscatbem)
                           NO-LOCK:
            FOR EACH crapepr WHERE crapepr.cdcooper = crapbpr.cdcooper
                               AND crapepr.nrdconta = crapbpr.nrdconta
                               AND crapepr.inliquid = 0
                               NO-LOCK:
                FOR FIRST crabbpr WHERE crabbpr.cdcooper = crapepr.cdcooper
                                    AND crabbpr.nrdconta = crapepr.nrdconta
                                    AND crabbpr.nrctrpro = crapepr.nrctremp
                                    AND crabbpr.flgalien = TRUE
                                    AND crabbpr.dschassi = crapbpr.dschassi
                                    AND (crabbpr.cdsitgrv <> 4 AND
                                         crabbpr.cdsitgrv <> 5)
                                    NO-LOCK: END.
                IF AVAIL crabbpr THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Ja existe o mesmo chassi alienado em um contrato liberado!".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 2,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
            
                    RETURN "NOK".
                END.
            END.
        END.

        /* Verificar se um dos bens da proposta ja se
           encontra alienado em outro contrato */
        FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper
                           AND crapbpr.nrdconta = par_nrdconta
                           AND crapbpr.nrctrpro = par_nrctremp
                           AND crapbpr.flgalien = TRUE
                           AND CAN-DO("AUTOMOVEL,MOTO,CAMINHAO,OUTROS VEICULOS",crapbpr.dscatbem)
                           NO-LOCK:
            FOR EACH crapepr WHERE crapepr.cdcooper = crapbpr.cdcooper
                               AND crapepr.nrdconta = crapbpr.nrdconta
                               AND crapepr.inliquid = 0
                               NO-LOCK:
                FOR FIRST crabbpr WHERE crabbpr.cdcooper = crapepr.cdcooper
                                    AND crabbpr.nrdconta = crapepr.nrdconta
                                    AND crabbpr.nrctrpro = crapepr.nrctremp
                                    AND crabbpr.flgalien = TRUE
                                    AND crabbpr.dschassi = crapbpr.dschassi
                                    AND (crabbpr.cdsitgrv <> 4 AND
                                         crabbpr.cdsitgrv <> 5)
                                    NO-LOCK: END.
                IF AVAIL crabbpr THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Ja existe o mesmo chassi alienado em um contrato liberado!".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 2,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
            
                    RETURN "NOK".
    END.
            END.
        END.
    END.

/*
    /* Nao permitir utilizar linha 100, quando possuir acordo de estouro de conta ativo */
    IF   crawepr.cdlcremp = 100  THEN
         DO:
             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

             /* Verifica se ha contratos de acordo */
             RUN STORED-PROCEDURE pc_verifica_acordo_ativo
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                 ,INPUT par_nrdconta
                                                 ,INPUT par_nrdconta
                                                 ,INPUT 1
                                                 ,0
                                                 ,0
                                                 ,"").

             CLOSE STORED-PROC pc_verifica_acordo_ativo
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

             ASSIGN aux_flgativo = 0
                    aux_cdcritic = 0
                    aux_dscritic = ""
                    aux_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
                    aux_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
                    aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo) WHEN pc_verifica_acordo_ativo.pr_flgativo <> ?.
                              
              IF   aux_cdcritic > 0   OR
                   (aux_dscritic <> ? AND aux_dscritic <> "") THEN
                   DO:
                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT 1,
                                      INPUT aux_cdcritic,
                                      INPUT-OUTPUT aux_dscritic).

                       RETURN "NOK".
                   END.
                            
              IF   aux_flgativo = 1  THEN
                   DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Operacao nao permitida, conta corrente esta em acordo.".

                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT 1,
                                      INPUT aux_cdcritic,
                                      INPUT-OUTPUT aux_dscritic).

                       RETURN "NOK".
                   END.
         END.
         */

    /* Condicao para a Finalidade for Cessao de Credito */
    FOR FIRST crapfin FIELDS(tpfinali)
                       WHERE crapfin.cdcooper = crawepr.cdcooper AND 
                             crapfin.cdfinemp = crawepr.cdfinemp
                             NO-LOCK: END.

    IF AVAIL crapfin AND crapfin.tpfinali = 1 THEN
       ASSIGN aux_flgcescr = TRUE.

    /* Vamos validar o capital minimo apenas se nao for cessao de credito  */
    IF NOT aux_flgcescr THEN
       DO:
          RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.

          IF  VALID-HANDLE(h-b1wgen0001)   THEN
              DO:
                  RUN ver_capital IN h-b1wgen0001(INPUT  par_cdcooper,
                                                  INPUT  par_nrdconta,
                                                  INPUT  par_cdagenci,
                                                  INPUT  par_nrdcaixa,
                                                  INPUT  0, /* vllanmto */
                                                  INPUT  par_dtmvtolt,
                                                  INPUT  "lanctri",
                                                  INPUT  1, /* AYLLOS */
                                                  OUTPUT TABLE tt-erro).
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                  IF  AVAILABLE tt-erro   THEN
                      DO.
                        DELETE PROCEDURE h-b1wgen0001.
                        RETURN "NOK".
                      END.
                  ELSE
                     DELETE PROCEDURE h-b1wgen0001.

              END.
       END.
        
        
    FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                       craplcr.cdlcremp = crawepr.cdlcremp NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplcr   THEN
        DO:
           ASSIGN aux_cdcritic = 363
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
        END.

    /* 17/02/2017 - Retirado a validaçao conforme solicitaçao 
    ELSE DO:  /* Se encontrar linha de crédito */
    
        /* Se o tipo do contrato for igual a 3 -> Contratos de imóveis */
        IF craplcr.tpctrato = 3 THEN DO:
            
                        ASSIGN aux_flimovel = 0.

                    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

            /* Verifica se ha contratos de acordo */
            RUN STORED-PROCEDURE pc_valida_imoveis_epr
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                ,INPUT par_nrdconta
                                                ,INPUT crawepr.nrctremp
                                                                                                ,INPUT 3
                                                ,OUTPUT 0
                                                ,OUTPUT 0
                                                ,OUTPUT "").

            CLOSE STORED-PROC pc_valida_imoveis_epr
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = INT(pc_valida_imoveis_epr.pr_cdcritic) WHEN pc_valida_imoveis_epr.pr_cdcritic <> ?
                   aux_dscritic = pc_valida_imoveis_epr.pr_dscritic WHEN pc_valida_imoveis_epr.pr_dscritic <> ?
                                   aux_flimovel = INT(pc_valida_imoveis_epr.pr_flimovel).
        
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
          
            IF aux_flimovel = 1 THEN
            DO:
            
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "A proposta nao pode ser efetivada, dados dos Imoveis nao cadastrados.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
             
            END. /* IF aux_flimovel = 1 THEN */
        END. /* IF craplcr.tpctrato = 3 */
    END. /* IF  NOT AVAIL craplcr */
        FIM - 17/02/2017 - Retirado a validaçao conforme solicitaçao */
    
    IF  par_dtmvtolt > crawepr.dtlibera THEN
        DO:
            ASSIGN  aux_cdcritic = 0
                    aux_dscritic = "Data de movimento nao pode ser maior "
                                 + "que a data de liberacao do emprestimo.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    /* Verificacao de contrato de acordo */  
    DO  aux_contador = 1 TO 10:

      IF  crawepr.nrctrliq[aux_contador] > 0 THEN DO:
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

        /* Verifica se ha contratos de acordo */
        RUN STORED-PROCEDURE pc_verifica_acordo_ativo
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                              ,INPUT par_nrdconta
                                              ,INPUT crawepr.nrctrliq[aux_contador]
                                                                                          ,INPUT 3
                                              ,OUTPUT 0
                                              ,OUTPUT 0
                                              ,OUTPUT "").

        CLOSE STORED-PROC pc_verifica_acordo_ativo
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

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
                   aux_dscritic = "A proposta nao pode ser efetivada, contrato marcado para liquidar esta em acordo.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
             
          END.
     END.   
   END.
   /* Fim verificacao contrato acordo */  
   
    RETURN "OK".

END PROCEDURE. /*   valida dados efetivacao proposta    */


PROCEDURE grava_efetivacao_proposta:

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
    DEF VAR aux_qtdiaiof AS INTE                                                                          NO-UNDO.
    DEF VAR aux_vlaqiofc AS DECI                                      NO-UNDO.    
    DEF VAR aux_cdhistar_cad  AS INTE                                 NO-UNDO.
    DEF VAR aux_cdhistar_gar  AS INTE                                 NO-UNDO.    
    DEF VAR aux_vlpreclc AS DECI                                      NO-UNDO.
    DEF VAR aux_vliofpri AS DECI                                      NO-UNDO.    
    DEF VAR aux_vliofadi AS DECI                                      NO-UNDO.    
    DEF VAR aux_nrseqdig AS INTE                                      NO-UNDO.
    DEF VAR aux_nrdolote_cred AS INTE                                 NO-UNDO.   
    DEF VAR aux_cdhistor_cred AS INTE                                 NO-UNDO.

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

    FOR FIRST tbepr_portabilidade
       FIELDS (nrdconta)
        WHERE tbepr_portabilidade.cdcooper = par_cdcooper
          AND tbepr_portabilidade.nrdconta = par_nrdconta
          AND tbepr_portabilidade.nrctremp = par_nrctremp
        NO-LOCK:
        ASSIGN aux_flgportb = TRUE.
    END.

    IF  aux_flgportb = FALSE THEN
        DO:
    /** GRAVAMES **/
    RUN sistema/generico/procedures/b1wgen0171.p PERSISTENT SET h-b1wgen0171.

    RUN valida_bens_alienados IN h-b1wgen0171 (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT par_nrctremp,
                                               INPUT "",
                                              OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0171.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

        END.

    RUN valida_dados_efetivacao_proposta (INPUT par_cdcooper,
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

    IF RETURN-VALUE <> "OK"   THEN
       RETURN "NOK".

    FOR FIRST crapfin FIELDS(tpfinali)
        WHERE crapfin.cdcooper = par_cdcooper AND
              crapfin.cdfinemp = crawepr.cdfinemp
              NO-LOCK: END.
              
    IF AVAILABLE crapfin THEN     
       /* cessao de credito */
       IF crapfin.tpfinali = 1 THEN
          ASSIGN aux_flcescrd = TRUE.

    EFETIVACAO:
    DO TRANSACTION ON ERROR UNDO, LEAVE:

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

                     UNDO EFETIVACAO, LEAVE EFETIVACAO.
                 END.

           ASSIGN aux_cdcritic = 0.
           LEAVE.

       END.

    
       FOR FIRST crappre FIELDS(cdfinemp vlmulpli vllimmin) WHERE crappre.cdcooper = par_cdcooper     
                                                              AND crappre.inpessoa = crapass.inpessoa
                                                              AND (crappre.cdfinemp = crawepr.cdfinemp
                                                               OR crawepr.flgpreap = 1) NO-LOCK: END.

       /* Verifica se o emprestimo eh pre-aprovado */
       IF AVAIL crappre THEN
          DO:
              IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                 RUN sistema/generico/procedures/b1wgen0188.p 
                     PERSISTENT SET h-b1wgen0188.
                     
              /* Busca a carga ativa */
              RUN busca_carga_ativa IN h-b1wgen0188(INPUT par_cdcooper,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_idcarga).
        
              IF VALID-HANDLE(h-b1wgen0188) THEN
                 DELETE PROCEDURE(h-b1wgen0188).

              Contador: DO aux_contador = 1 TO 10:

                 FIND crapcpa WHERE crapcpa.cdcooper = par_cdcooper AND
                                    crapcpa.nrdconta = par_nrdconta AND
                                    crapcpa.iddcarga = aux_idcarga
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF NOT AVAILABLE crapcpa THEN
                    IF LOCKED crapcpa THEN
                        DO:
                           ASSIGN aux_cdcritic = 77.
                           PAUSE 2 NO-MESSAGE.
                           NEXT.
                       END.
                    ELSE
                       DO:
                           ASSIGN aux_dscritic = "Associado nao cadastrado " +
                                                 "no pre-aprovado".
                           UNDO EFETIVACAO, LEAVE EFETIVACAO.
                       END.

                 ASSIGN aux_cdcritic = 0.
                 LEAVE Contador.

              END. /* END Contador: DO aux_contador = 1 TO 10: */

              /* Depois de alocado o registro, vamos verificar se possui saldo
                 disponivel */
              IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                 RUN sistema/generico/procedures/b1wgen0188.p
                     PERSISTENT SET h-b1wgen0188.

              /* Valida os dados do credito pre-aprovado */
            /*  RUN valida_dados IN h-b1wgen0188 (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                INPUT par_nrdconta,
                                                INPUT par_idseqttl,
                                                INPUT crawepr.vlemprst,
                                                INPUT DAY(par_dtdpagto),
                                                INPUT par_nrcpfope,
                                                OUTPUT TABLE tt-erro).
              */
              IF VALID-HANDLE(h-b1wgen0188) THEN
                 DELETE PROCEDURE(h-b1wgen0188).

              IF RETURN-VALUE <> "OK" THEN
                 RETURN "NOK".

              /* Atualiza o valor contratado do credito pre-aprovado */
              ASSIGN crapcpa.vlctrpre = crapcpa.vlctrpre + crawepr.vlemprst
                     crapcpa.vllimdis = TRUNC(((crapcpa.vllimdis -
                                                crawepr.vlemprst) /
                                              crappre.vlmulpli),0)
                     crapcpa.vllimdis = crapcpa.vllimdis * crappre.vlmulpli.

              /* Caso o valor minimo ofertado for maior que o saldo disponivel
                 vamos zerar o saldo disponivel */
              IF crappre.vllimmin > crapcpa.vllimdis THEN
                 ASSIGN crapcpa.vllimdis = 0.

          END. /* END IF AVAIL crappre AND par_cdfinemp = crappre.cdfinemp  */


      RUN buscar_historico_e_lote_efet_prop(INPUT crawepr.tpemprst
                                           ,INPUT crawepr.idfiniof
                                           ,INPUT craplcr.dsoperac
                                           ,OUTPUT aux_cdhistor
                                           ,OUTPUT aux_cdhistor_tar
                                           ,OUTPUT aux_nrdolote).
        
      /* Projeto 410 - Novo IOF */
      ASSIGN aux_flgimune = 0
             aux_vltotiof = 0
             aux_qtdiaiof = 1
             aux_dscatbem = "".
      
      FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                         crapjur.nrdconta = par_nrdconta
                         NO-LOCK NO-ERROR.

      
      FOR EACH crapbpr WHERE crapbpr.cdcooper = crawepr.cdcooper  AND
                             crapbpr.nrdconta = crawepr.nrdconta  AND
                             crapbpr.nrctrpro = crawepr.nrctremp  AND
                             crapbpr.tpctrpro = 90 NO-LOCK:
          ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
      END.
       
       ASSIGN aux_dsctrliq = "".
       
       DO i = 1 TO 10:

         IF  crawepr.nrctrliq[i] > 0  THEN
           aux_dsctrliq = aux_dsctrliq +
              (IF  aux_dsctrliq = ""  THEN
                   TRIM(STRING(crawepr.nrctrliq[i],
                               "z,zzz,zz9"))
               ELSE
                   ", " +
                   TRIM(STRING(crawepr.nrctrliq[i],
                               "z,zzz,zz9"))).

       END. /** Fim do DO ... TO **/
                      
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
      RUN STORED-PROCEDURE pc_calcula_iof_epr
      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper       /* Código da cooperativa */
                                          ,INPUT par_nrdconta       /* Número da conta */
                                          ,INPUT crawepr.nrctremp   /* Numero do contrato */
                                          ,INPUT par_dtmvtolt       /* Data do movimento para busca na tabela de IOF */
                                          ,INPUT crapass.inpessoa   /* Tipo de Pessoa */
                                          ,INPUT crawepr.cdlcremp   /* Linha de crédito */
                                          ,INPUT crawepr.cdfinemp   /* Finalidade */
                                          ,INPUT crawepr.qtpreemp   /* Quantidade de parcelas */
                                          ,INPUT crawepr.vlpreemp   /* Valor da parcela do emprestimo */
                                          ,INPUT crawepr.vlemprst   /* Valor do emprestimo */
                                          ,INPUT crawepr.dtdpagto   /* Data de pagamento */
                                          ,INPUT crawepr.dtlibera   /* Data de liberação */
                                          ,INPUT crawepr.tpemprst   /* Tipo de emprestimo */
                                          ,INPUT crawepr.dtcarenc
                                          ,INPUT 0 /* dias de carencia */
                                          ,INPUT aux_dscatbem       /* Bens em garantia */
                                          ,INPUT crawepr.idfiniof   /* Indicador de financiamento de iof e tarifa */
                                          ,INPUT aux_dsctrliq       /* pr_dsctrliq */
                                          ,INPUT "S"                /* Gravar valor do IOF p/parcela nas parcelas */
                                          ,OUTPUT 0                 /* Valor calculado da Parcela */
                                          ,OUTPUT 0                 /* Retorno do valor do IOF */
                                          ,OUTPUT 0                 /* pr_vliofpri Valor calculado do iof principal */
                                          ,OUTPUT 0                 /* pr_vliofadi Valor calculado do iof adicional */
                                          ,OUTPUT 0                 /* pr_flgimune Possui imunidade tributária (1 - Sim / 0 - Nao) */
                                          ,OUTPUT "").              /* Critica */

      /* Fechar o procedimento para buscarmos o resultado */ 
      CLOSE STORED-PROC pc_calcula_iof_epr
      
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
      /* Se retornou erro */
      ASSIGN aux_dscritic = ""
             aux_dscritic = pc_calcula_iof_epr.pr_dscritic WHEN pc_calcula_iof_epr.pr_dscritic <> ?.
             
      IF aux_dscritic <> "" THEN
        UNDO EFETIVACAO, LEAVE EFETIVACAO.
        
      /* Retorno do calculo */
      ASSIGN aux_vlpreclc = 0
             aux_vltotiof = 0
             aux_vliofpri = 0
             aux_vliofadi = 0
             aux_flgimune = 0.
      ASSIGN aux_vlpreclc = pc_calcula_iof_epr.pr_vlpreclc WHEN pc_calcula_iof_epr.pr_vlpreclc <> ?
             aux_vltotiof = pc_calcula_iof_epr.pr_valoriof WHEN pc_calcula_iof_epr.pr_valoriof <> ?
             aux_vliofpri = pc_calcula_iof_epr.pr_vliofpri WHEN pc_calcula_iof_epr.pr_vliofpri <> ?
             aux_vliofadi = pc_calcula_iof_epr.pr_vliofadi WHEN pc_calcula_iof_epr.pr_vliofadi <> ? 
             aux_flgimune = pc_calcula_iof_epr.pr_flgimune WHEN pc_calcula_iof_epr.pr_flgimune <> ?.
      
                 
      /* Buscar a tarifa */
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
      RUN STORED-PROCEDURE pc_calcula_tarifa
      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper       /* Código da cooperativa */
                                          ,INPUT par_nrdconta       /* Número da conta */
                                          ,INPUT crawepr.cdlcremp   /* Linha de crédito */
                                          ,INPUT crawepr.vlemprst   /* Valor do emprestimo */
                                          ,INPUT craplcr.cdusolcr   /* Uso da linha de crédito */
                                          ,INPUT craplcr.tpctrato   /* Tipo de contrato */
                                          ,INPUT aux_dscatbem       /* Bens em garantia */
                                          ,INPUT 'ATENDA'           /* Nome do programa */
                                          ,INPUT 'N'                /* Flag de envio de e-mail */
                                          ,INPUT crawepr.tpemprst   /* Tipo de empréstimo */
                                          ,INPUT crawepr.idfiniof   /* Identificador se financia iof e tarifa */                                          
                                          ,OUTPUT 0                 /* Valor da tarifa */
                                          ,OUTPUT 0                 /* Valor da tarifa especial */
                                          ,OUTPUT 0                 /* Valor da tarifa garantia */
                                          ,OUTPUT 0                 /* Histórico do lançamento */
                                          ,OUTPUT 0                 /* Faixa de valor por cooperativa */
                                          ,OUTPUT 0                        /* Historico Garantia */
                                          ,OUTPUT 0                        /* Faixa de valor garantia */
                                          ,OUTPUT 0                 /* Crítica encontrada */
                                          ,OUTPUT "").              /* Critica */

      /* Fechar o procedimento para buscarmos o resultado */ 
      CLOSE STORED-PROC pc_calcula_tarifa
      
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
      /* Se retornou erro */
      ASSIGN aux_dscritic = ""
             aux_dscritic = pc_calcula_tarifa.pr_dscritic WHEN pc_calcula_tarifa.pr_dscritic <> ?.
      IF aux_dscritic <> "" THEN
        UNDO EFETIVACAO, LEAVE EFETIVACAO.
            
      /* Valor tarifa */
      ASSIGN aux_vltarifa = 0.
      IF pc_calcula_tarifa.pr_vlrtarif <> ? THEN
          ASSIGN aux_vltarifa = aux_vltarifa + ROUND(DECI(pc_calcula_tarifa.pr_vlrtarif),2).
      IF pc_calcula_tarifa.pr_vltrfesp <> ? THEN
          ASSIGN aux_vltarifa = aux_vltarifa + ROUND(DECI(pc_calcula_tarifa.pr_vltrfesp),2).
      IF pc_calcula_tarifa.pr_vltrfgar <> ? THEN
          ASSIGN aux_vltrfgar = ROUND(DECI(pc_calcula_tarifa.pr_vltrfgar),2).
        
     ASSIGN aux_cdhistar_cad = 0
            aux_cdhistar_gar = 0
            aux_cdhistar_cad = pc_calcula_tarifa.pr_cdhistor WHEN pc_calcula_tarifa.pr_cdhistor <> ?
            aux_cdhistar_gar = pc_calcula_tarifa.pr_cdhisgar WHEN pc_calcula_tarifa.pr_cdhisgar <> ?.
     
     
     /* Se for Pos-Fixado */
     IF  crawepr.tpemprst = 2  THEN DO:
             ASSIGN aux_nrdolote_cred = 650004.

             IF   aux_floperac   THEN             /* Financiamento*/
                ASSIGN aux_cdhistor_cred = 2327.
             ELSE                                 /* Emprestimo */
                  ASSIGN aux_cdhistor_cred = 2326.
         END.
     ELSE
         DO:
            FIND crapfin WHERE crapfin.cdcooper = crawepr.cdcooper
                           AND crapfin.cdfinemp = crawepr.cdfinemp NO-LOCK NO-ERROR NO-WAIT.
         
            IF AVAILABLE crapfin THEN
              ASSIGN aux_tpfinali = crapfin.tpfinali.                
         
            IF aux_floperac THEN /* Financiamento*/
              DO:
                IF aux_tpfinali = 3 THEN /* CDC */
                  ASSIGN aux_cdhistor_cred = 2014.
                ELSE
                  ASSIGN aux_cdhistor_cred = 1059.
                  
                ASSIGN  aux_nrdolote_cred = 600030.
              END.
           ELSE /* Emprestimo */
             DO:
              IF aux_tpfinali = 3 THEN /* CDC */
                ASSIGN aux_cdhistor_cred = 2013.
              ELSE
                ASSIGN aux_cdhistor_cred = 1036.
              
              ASSIGN aux_nrdolote_cred = 600005.
             END.
         END.

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

        DELETE PROCEDURE h-b1wgen0134.

        IF RETURN-VALUE <> "OK"   THEN
          DO:
              ASSIGN aux_dscritic = "Erro na criacao do lancamento".

              UNDO EFETIVACAO , LEAVE EFETIVACAO.
          END.

       /* Caso nao cobrou IOF pois é imune, mas possui valor principal ou adicional */
       IF aux_flgimune = 1 AND (aux_vliofpri > 0 OR aux_vliofadi > 0 ) THEN
       DO:
           { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
           /* Efetuar a chamada a rotina Oracle */
           RUN STORED-PROCEDURE pc_insere_iof
           aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper        /* Cooperativa              */ 
                                               ,INPUT par_nrdconta        /* Numero da Conta Corrente */
                                               ,INPUT par_dtmvtolt        /* Data de Movimento        */
                                               ,INPUT 1                   /* Emprestimo       */
                                               ,INPUT par_nrctremp        /* Numero do Bordero        */
                                               ,INPUT ?                   /* ID Lautom                */
                                               ,INPUT ?                   /* Data Movimento LCM       */
                                               ,INPUT ?                   /* Numero da Agencia LCM    */
                                               ,INPUT ?                   /* Numero do Caixa LCM      */
                                               ,INPUT ?                   /* Numero do Lote LCM       */
                                               ,INPUT ?                   /* Sequencia LCM            */
                                               ,INPUT aux_vliofpri        /* Valor Principal IOF      */
                                               ,INPUT aux_vliofadi        /* Valor Adicional IOF      */
                                               ,INPUT 0                   /* Valor Complementar IOF   */
                                               ,INPUT aux_flgimune        /* Possui imunidade tributária (1 - Sim / 0 - Nao)*/
                                               ,OUTPUT 0                  /* Codigo da Critica */
                                               ,OUTPUT "").               /* Descriçao da crítica */
           
           /* Fechar o procedimento para buscarmos o resultado */ 
           CLOSE STORED-PROC pc_insere_iof
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = ""
                  aux_cdcritic = pc_insere_iof.pr_cdcritic
                                 WHEN pc_insere_iof.pr_cdcritic <> ?
                  aux_dscritic = pc_insere_iof.pr_dscritic
                                 WHEN pc_insere_iof.pr_dscritic <> ?.
           /* Se retornou erro */
           IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
           DO:
               /*MESSAGE "(2) Erro ao inserir lancamento de IOF.".*/
               ASSIGN aux_dscritic = "Erro ao inserir lancamento de IOF.".
               UNDO EFETIVACAO , LEAVE EFETIVACAO.
           END.
        
      END.
      
      /* Se Financia IOF, gera lancamento na LEM */             
      IF crawepr.idfiniof = 1 THEN 
      DO:  
          IF aux_vltotiof > 0 THEN
                      DO:
              /* Gera a LEM se for financiado IOF */
              RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

              RUN cria_lancamento_lem_chave IN h-b1wgen0134
                                  (INPUT par_cdcooper,
                                   INPUT par_dtmvtolt,
                                   INPUT par_cdagenci,
                                   INPUT 100,          /* cdbccxlt */
                                   INPUT par_cdoperad,
                                   INPUT par_cdagenci,
                                   INPUT 4,            /* tplotmov */
                                   INPUT aux_nrdolote, /* nrdolote */
                                   INPUT par_nrdconta,
                                   INPUT aux_cdhistor,
                                   INPUT par_nrctremp,
                                   INPUT aux_vltotiof, /* Valor IOF */
                                   INPUT par_dtmvtolt,
                                   INPUT craplcr.txdiaria,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT TRUE,
                                   INPUT TRUE,
                                   INPUT 0,
                                   INPUT par_idorigem,
                                   OUTPUT aux_nrseqdig ).

              DELETE PROCEDURE h-b1wgen0134.

              IF RETURN-VALUE <> "OK"   THEN
              DO:
                  ASSIGN aux_dscritic = "Erro na criacao do lancamento".

                  UNDO EFETIVACAO , LEAVE EFETIVACAO.
              END.
           
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
              /* Efetuar a chamada a rotina Oracle */
              RUN STORED-PROCEDURE pc_insere_iof
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper        /* Cooperativa              */ 
                                                  ,INPUT par_nrdconta        /* Numero da Conta Corrente */
                                                  ,INPUT par_dtmvtolt        /* Data de Movimento        */
                                                  ,INPUT 1                   /* Emprestimo       */
                                                  ,INPUT par_nrctremp        /* Numero do Bordero        */
                                                  ,INPUT ?                   /* ID Lautom                */
                                                  ,INPUT par_dtmvtolt       /* Data Movimento LCM       */
                                                  ,INPUT par_cdagenci       /* Numero da Agencia LCM    */
                                                  ,INPUT 100                /* Numero do Caixa LCM      */
                                                  ,INPUT aux_nrdolote       /* Numero do Lote LCM       */
                                                  ,INPUT aux_nrseqdig        /* Sequencia LCM            */
                                                  ,INPUT aux_vliofpri        /* Valor Principal IOF      */
                                                  ,INPUT aux_vliofadi        /* Valor Adicional IOF      */
                                                  ,INPUT 0                   /* Valor Complementar IOF   */
                                                  ,INPUT aux_flgimune        /* Possui imunidade tributária (1 - Sim / 0 - Nao)*/
                                                  ,OUTPUT 0                  /* Codigo da Critica */
                                                  ,OUTPUT "").               /* Descriçao da crítica */
                                               
               /* Fechar o procedimento para buscarmos o resultado */ 
               CLOSE STORED-PROC pc_insere_iof
                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = ""
                      aux_cdcritic = pc_insere_iof.pr_cdcritic
                                     WHEN pc_insere_iof.pr_cdcritic <> ?
                      aux_dscritic = pc_insere_iof.pr_dscritic
                                     WHEN pc_insere_iof.pr_dscritic <> ?.
               /* Se retornou erro */
               IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
                  DO:
                      /*MESSAGE "(1) Erro ao inserir lancamento de IOF.".*/
                      ASSIGN aux_dscritic = "Erro ao inserir lancamento de IOF.".
                      UNDO EFETIVACAO , LEAVE EFETIVACAO.
               END.

           END.    
           

          /* Gera a tarifa na LEM se for financiado IOF */
          IF aux_vltarifa > 0 THEN
          DO:
              IF aux_cdhistar_cad = 0 THEN DO:         
                  ASSIGN aux_dscritic = "Historico de tarifa nao encontrado".
                  UNDO EFETIVACAO , LEAVE EFETIVACAO.
              END.
                
              RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.
            
              RUN cria_lancamento_lem IN h-b1wgen0134
                                      (INPUT par_cdcooper,
                                       INPUT par_dtmvtolt,
                                       INPUT par_cdagenci,
                                       INPUT 100,          /* cdbccxlt */
                                       INPUT par_cdoperad,
                                       INPUT par_cdagenci,
                                       INPUT 4,            /* tplotmov */
                                       INPUT aux_nrdolote, /* nrdolote */
                                       INPUT par_nrdconta,
                                       INPUT aux_cdhistar_cad,
                                       INPUT par_nrctremp,
                                       INPUT aux_vltarifa, /* Valor TARIFA */
                                       INPUT par_dtmvtolt,
                                       INPUT craplcr.txdiaria,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT TRUE,
                                       INPUT TRUE,
                                       INPUT 0,
                                       INPUT par_idorigem).
         
              DELETE PROCEDURE h-b1wgen0134.
  
              IF RETURN-VALUE <> "OK"   THEN
              DO:
                  ASSIGN aux_dscritic = "Erro na criacao do lancamento".

                  UNDO EFETIVACAO , LEAVE EFETIVACAO.
              END.
          END.
          /* Gerar tarifa de bens */
          IF aux_vltrfgar > 0 THEN
          DO:
              IF aux_cdhistar_gar = 0 THEN DO:
                
                  ASSIGN aux_dscritic = "Historico de tarifa nao encontrado".
                  UNDO EFETIVACAO , LEAVE EFETIVACAO.
              END.

          /* Gera a LEM se for financiado IOF */
          RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

          RUN cria_lancamento_lem IN h-b1wgen0134
                                  (INPUT par_cdcooper,
                                   INPUT par_dtmvtolt,
                                   INPUT par_cdagenci,
                                   INPUT 100,          /* cdbccxlt */
                                   INPUT par_cdoperad,
                                   INPUT par_cdagenci,
                                   INPUT 4,            /* tplotmov */
                                   INPUT aux_nrdolote, /* nrdolote */
                                   INPUT par_nrdconta,
                                   INPUT aux_cdhistar_gar,
                                   INPUT par_nrctremp,
                                   INPUT aux_vltrfgar, /* Valor TARIFA */
                                   INPUT par_dtmvtolt,
                                   INPUT craplcr.txdiaria,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT TRUE,
                                   INPUT TRUE,
                                   INPUT 0,
                                   INPUT par_idorigem).
          
          DELETE PROCEDURE h-b1wgen0134.
          
          IF RETURN-VALUE <> "OK"   THEN
              DO:
                  ASSIGN aux_dscritic = "Erro na criacao do lancamento".
          
                  UNDO EFETIVACAO , LEAVE EFETIVACAO.
              END.
          
          END.
          
      END. /* IF crawepr.idfiniof = 0 THEN */
        
      /* Agrupar valor de tarifas cobradas */
      ASSIGN aux_vltarifa = aux_vltarifa + aux_vltrfgar. 
        
      
      /* Busca a taxa de IOF principal contratada */
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                              
      /* Efetuar a chamada a rotina Oracle  */
      RUN STORED-PROCEDURE pc_busca_taxa_iof_prg
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT par_nrctremp,
                                               INPUT par_dtmvtolt,
                                               INPUT crawepr.cdlcremp,
                                               INPUT crawepr.cdfinemp,
                                               INPUT crawepr.vlemprst,
                                               OUTPUT "",
                                               OUTPUT "",
                                               OUTPUT 0,
                                               OUTPUT 0,
                                               OUTPUT "").

      /* Fechar o procedimento para buscarmos o resultado */ 
      CLOSE STORED-PROC pc_busca_taxa_iof_prg
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
      
      ASSIGN aux_dscritic = ""
             aux_vlaqiofc = 0
             aux_vlaqiofc = DECI(pc_busca_taxa_iof_prg.pr_vltxiofpri) WHEN pc_busca_taxa_iof_prg.pr_vltxiofpri <> ?
             aux_dscritic = pc_busca_taxa_iof_prg.pr_dscritic WHEN pc_busca_taxa_iof_prg.pr_dscritic <> ?.
      IF aux_vlaqiofc = 0 THEN    
         ASSIGN aux_vlaqiofc = DECI(pc_busca_taxa_iof_prg.pr_vltxiofcpl) WHEN pc_busca_taxa_iof_prg.pr_vltxiofcpl <> ?.
             
      IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         UNDO EFETIVACAO , LEAVE EFETIVACAO.
      /* Inicio P438 */
      /* Se for PP e origem Ayllos Web*/
      IF  crawepr.tpemprst = 1 AND crawepr.cdorigem = 5 THEN
          DO:
              /* Caso NAO seja Refinanciamento efetua credito na conta  */
              IF  NOT CAN-FIND(crawepr WHERE crawepr.cdcooper = par_cdcooper
                                         AND crawepr.nrdconta = par_nrdconta
                                         AND crawepr.nrctremp = par_nrctremp
                                         AND (crawepr.nrctrliq[1]  > 0   OR
                                              crawepr.nrctrliq[2]  > 0   OR
                                              crawepr.nrctrliq[3]  > 0   OR
                                              crawepr.nrctrliq[4]  > 0   OR
                                              crawepr.nrctrliq[5]  > 0   OR
                                              crawepr.nrctrliq[6]  > 0   OR
                                              crawepr.nrctrliq[7]  > 0   OR
                                              crawepr.nrctrliq[8]  > 0   OR
                                              crawepr.nrctrliq[9]  > 0   OR
                                              crawepr.nrctrliq[10] > 0)) THEN
                  DO:
                      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
         
                      /* Efetuar a chamada a rotina Oracle  */
                      RUN STORED-PROCEDURE pc_credito_online_pp
                          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                               INPUT par_nrdconta,
                                                               INPUT par_nrctremp,
                                                               INPUT par_nmdatela,
                                                               INPUT crapass.inpessoa,
                                                               INPUT par_cdagenci,
                                                               INPUT par_nrdcaixa,
                                                               INPUT par_cdagenci, /* pr_cdpactra */
                                                               INPUT par_cdoperad,
                                                              OUTPUT 0,   /* pr_vltottar */
                                                              OUTPUT 0,   /* pr_vltariof */
                                                              OUTPUT 0,   /* pr_cdcritic */
                                                              OUTPUT ""). /* pr_dscritic */

                      /* Fechar o procedimento para buscarmos o resultado */ 
                      CLOSE STORED-PROC pc_credito_online_pp
                             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                      
                      ASSIGN aux_vltottar = 0
                             aux_vltariof = 0
                             aux_cdcritic = 0
                             aux_dscritic = ""
                             aux_vltottar = pc_credito_online_pp.pr_vltottar
                                            WHEN pc_credito_online_pp.pr_vltottar <> ?
                             aux_vltariof = pc_credito_online_pp.pr_vltariof
                                            WHEN pc_credito_online_pp.pr_vltariof <> ?
                             aux_cdcritic = INT(pc_credito_online_pp.pr_cdcritic) 
                                            WHEN pc_credito_online_pp.pr_cdcritic <> ?
                             aux_dscritic = pc_credito_online_pp.pr_dscritic
                                            WHEN pc_credito_online_pp.pr_dscritic <> ?
                             aux_vltarifa = aux_vltottar.

                      IF   aux_cdcritic <> 0    OR
                           aux_dscritic <> ""   THEN
                        DO:
                         CREATE tt-erro.
                         ASSIGN tt-erro.cdcritic = aux_cdcritic
                                tt-erro.dscritic = aux_dscritic.
                           UNDO EFETIVACAO , LEAVE EFETIVACAO.
                        END.

                  END. /* NOT CAN-FIND */

          END. /* crawepr.tpemprst = 1 */
      /* Fim P438 */
      /**/
      /* Se for Pos-Fixado */
      IF  crawepr.tpemprst = 2  THEN
          DO:
              /* Caso NAO seja Refinanciamento efetua credito na conta  */
              IF  NOT CAN-FIND(crawepr WHERE crawepr.cdcooper = par_cdcooper
                                         AND crawepr.nrdconta = par_nrdconta
                                         AND crawepr.nrctremp = par_nrctremp
                                         AND (crawepr.nrctrliq[1]  > 0   OR
                                              crawepr.nrctrliq[2]  > 0   OR
                                              crawepr.nrctrliq[3]  > 0   OR
                                              crawepr.nrctrliq[4]  > 0   OR
                                              crawepr.nrctrliq[5]  > 0   OR
                                              crawepr.nrctrliq[6]  > 0   OR
                                              crawepr.nrctrliq[7]  > 0   OR
                                              crawepr.nrctrliq[8]  > 0   OR
                                              crawepr.nrctrliq[9]  > 0   OR
                                              crawepr.nrctrliq[10] > 0)) THEN
                  DO:
                      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                              
                      /* Efetuar a chamada a rotina Oracle  */
                      RUN STORED-PROCEDURE pc_efetua_credito_conta
                          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                               INPUT par_nrdconta,
                                                               INPUT par_nrctremp,
                                                               INPUT par_dtmvtolt,
                                                               INPUT par_nmdatela,
                                                               INPUT crapass.inpessoa,
                                                               INPUT par_cdagenci,
                                                               INPUT par_nrdcaixa,
                                                               INPUT par_cdagenci, /* pr_cdpactra */
                                                               INPUT par_cdoperad,
                                                              OUTPUT 0,   /* pr_vltottar */
                                                              OUTPUT 0,   /* pr_vltariof */
                                                              OUTPUT 0,   /* pr_cdcritic */
                                                              OUTPUT ""). /* pr_dscritic */

                      /* Fechar o procedimento para buscarmos o resultado */ 
                      CLOSE STORED-PROC pc_efetua_credito_conta
                             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                      
                      ASSIGN aux_vltottar = 0
                             aux_vltariof = 0
                             aux_cdcritic = 0
                             aux_dscritic = ""
                             aux_vltottar = pc_efetua_credito_conta.pr_vltottar
                                            WHEN pc_efetua_credito_conta.pr_vltottar <> ?
                             aux_vltariof = pc_efetua_credito_conta.pr_vltariof
                                            WHEN pc_efetua_credito_conta.pr_vltariof <> ?
                             aux_cdcritic = INT(pc_efetua_credito_conta.pr_cdcritic) 
                                            WHEN pc_efetua_credito_conta.pr_cdcritic <> ?
                             aux_dscritic = pc_efetua_credito_conta.pr_dscritic
                                            WHEN pc_efetua_credito_conta.pr_dscritic <> ?
                             aux_vltarifa = aux_vltottar.

                      IF   aux_cdcritic <> 0    OR
                           aux_dscritic <> ""   THEN
                        DO:
                         CREATE tt-erro.
                         ASSIGN tt-erro.cdcritic = aux_cdcritic
                                tt-erro.dscritic = aux_dscritic.
                           UNDO EFETIVACAO , LEAVE EFETIVACAO.
                        END.

                  END. /* NOT CAN-FIND */

          END. /* crawepr.tpemprst = 2 */

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
       /***********************
          CALCULO DATA RISCO REFIN
          Se houve alguma liquidacao de contrato
       ***********************/
       IF (crawepr.nrctrliq[1]  > 0
       OR  crawepr.nrctrliq[2]  > 0
       OR  crawepr.nrctrliq[3]  > 0
       OR  crawepr.nrctrliq[4]  > 0
       OR  crawepr.nrctrliq[5]  > 0
       OR  crawepr.nrctrliq[6]  > 0
       OR  crawepr.nrctrliq[7]  > 0
       OR  crawepr.nrctrliq[8]  > 0
       OR  crawepr.nrctrliq[9]  > 0
       OR  crawepr.nrctrliq[10] > 0
       OR  crawepr.nrliquid     > 0) THEN DO:

       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
           /* Verifica se ha contratos de acordo */
           RUN STORED-PROCEDURE pc_dias_atraso_liquidados
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                 ,INPUT par_nrdconta
                                                 ,INPUT crawepr.nrctremp
                                                 ,OUTPUT 0
                                                 ,OUTPUT "").
    
           CLOSE STORED-PROC pc_dias_atraso_liquidados
                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
           ASSIGN aux_qtdiaatr = 0
                  aux_dscritic = ""
                  aux_dscritic = pc_dias_atraso_liquidados.pr_dscritic WHEN pc_dias_atraso_liquidados.pr_dscritic <> ?
                  aux_qtdiaatr = INT(pc_dias_atraso_liquidados.pr_qtdatref).
            
           IF (aux_dscritic <> ? AND aux_dscritic <> "") THEN
              ASSIGN aux_dtrisref = par_dtmvtolt
                     aux_qtdiaatr = 0.
    
           ASSIGN aux_dtrisref = par_dtmvtolt - aux_qtdiaatr.
       END.
       ELSE 
           ASSIGN aux_dtrisref = ?.
       /***********************/
          
       /* Diego Simas (AMcom) - PJ 450                       */
       /* Início                                             */
       
       /* Verifica se existe algum contrato limite/adp       */
       /* e adiciona a lista de contratos para qualificar    */ 
       IF aux_dsctrliq <> "" THEN
          DO:
            IF crawepr.nrliquid <> 0 THEN
               aux_dsctrliq = aux_dsctrliq + 
                 ", " + TRIM(STRING(crawepr.nrliquid, "z,zzz,zz9")).                           
          END.
       ELSE
          DO:
            IF crawepr.nrliquid <> 0 THEN
               aux_dsctrliq = aux_dsctrliq + 
                 TRIM(STRING(crawepr.nrliquid, "z,zzz,zz9")).               
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
               CREATE tt-erro.
               ASSIGN tt-erro.cdcritic = aux_cdcritic
                      tt-erro.dscritic = aux_dscritic.
               UNDO EFETIVACAO, LEAVE EFETIVACAO.
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
       
       /* Fim                                                */    
       /* Diego Simas (AMcom) - PJ 450                       */

       CREATE crapepr.
       ASSIGN crapepr.dtmvtolt = par_dtmvtolt
              crapepr.cdagenci = par_cdagenci
              /* Gravar operador que efetivou a proposta */
              crapepr.cdopeefe = par_cdoperad
              crapepr.cdbccxlt = 100
              crapepr.nrdolote = aux_nrdolote_cred
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
              crapepr.vliofepr = aux_vltotiof
              crapepr.vliofpri = aux_vliofpri
              crapepr.vliofadc = aux_vliofadi
              crapepr.cdcooper = par_cdcooper
              crapepr.qttolatr = crawepr.qttolatr
              crapepr.vltarifa = aux_vltarifa
              crapepr.vlaqiofc = aux_vlaqiofc
              /*P438 Incluir a tratativa para PP*/
              crapepr.vltariof = aux_vltotiof /* (IF CAN-DO("1,2", STRING(crawepr.tpemprst)) THEN aux_vltariof ELSE aux_vltotiof) */
              crapepr.iddcarga = aux_idcarga
              crapepr.idfiniof = crawepr.idfiniof
              crapepr.dtinicio_atraso_refin = aux_dtrisref.
                                
              if crawepr.idfiniof > 0 then do:
                             assign crapepr.vlsdeved = crawepr.vlemprst + aux_vltotiof + aux_vltarifa.
                                    crapepr.vlemprst = crawepr.vlemprst + aux_vltotiof + aux_vltarifa.
                          end.


       /* Se for Pos-Fixado */
       IF   crawepr.tpemprst = 2   THEN
            DO:
                ASSIGN crapepr.vlsprojt = crawepr.vlemprst.
                IF crawepr.idfiniof > 0  THEN
                   ASSIGN crapepr.vlsprojt = crawepr.vlemprst + aux_vltotiof + aux_vltarifa.
            END.

       IF   crapepr.cdlcremp = 100   THEN
            DO:
                ASSIGN crapepr.dtprejuz = par_dtmvtolt
                       crapepr.inprejuz = 1
                       crapepr.vlsdprej = crapepr.vlsdeved
                       crapepr.vlprejuz = crapepr.vlsdeved
                       crapepr.inliquid = 1
                       crapepr.vlsdeved = 0.

                VALIDATE crapepr.

                FOR EACH crappep FIELDS(inliquid inprejuz)
                                  WHERE crappep.cdcooper = par_cdcooper AND
                                        crappep.nrdconta = par_nrdconta AND
                                        crappep.nrctremp = par_nrctremp AND
                                        crappep.inliquid = 0
                                 EXCLUSIVE-LOCK:
                    ASSIGN crappep.inliquid = 1
                           crappep.inprejuz = 1.
                END.
            END.
       ELSE
         VALIDATE crapepr.

       IF  crawepr.idcobope > 0  THEN
           DO:
              DO i = 1 TO 10:

                 IF  crawepr.nrctrliq[i] > 0  THEN
                     DO:

                        FOR FIRST b-crawepr FIELDS(idcobope)
                                            WHERE b-crawepr.cdcooper = par_cdcooper   AND
                                                  b-crawepr.nrdconta = par_nrdconta   AND
                                                  b-crawepr.nrctremp = crawepr.nrctrliq[i] NO-LOCK:
                           IF  b-crawepr.idcobope > 0  THEN
                               DO:
                                  /* Efetuar o desbloqueio de possiveis coberturas vinculadas ao mesmo */
                                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                  RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
                                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "ATENDA"
                                                                        ,INPUT b-crawepr.idcobope
                                                                        ,INPUT "D"
                                                                        ,INPUT par_cdoperad
                                                                        ,INPUT ""
                                                                        ,INPUT 0
                                                                        ,INPUT "S"
                                                                        ,"").

                                  CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                                  ASSIGN aux_dscritic  = ""
                                         aux_dscritic  = pc_bloq_desbloq_cob_operacao.pr_dscritic 
                                                         WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

                                  IF aux_dscritic <> "" THEN
                                     UNDO EFETIVACAO , LEAVE EFETIVACAO.
                               END.
                        END. /* FOR FIRST b-crawepr */

                     END. /* crawepr.nrctrliq[i] > 0 */

              END. /** Fim do DO ... TO **/
        
              /* Efetuar o bloqueio de possiveis coberturas vinculadas ao mesmo */
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

              RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT "ATENDA"
                                                    ,INPUT crawepr.idcobope
                                                    ,INPUT "B"
                                                    ,INPUT par_cdoperad
                                                    ,INPUT ""
                                                    ,INPUT 0
                                                    ,INPUT "S"
                                                    ,"").

              CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

              ASSIGN aux_dscritic  = ""
                     aux_dscritic  = pc_bloq_desbloq_cob_operacao.pr_dscritic 
                                     WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

              IF aux_dscritic <> "" THEN
                 UNDO EFETIVACAO , LEAVE EFETIVACAO.


           END. /* crawepr.idcobope > 0 */

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

       DELETE PROCEDURE h-b1wgen0043.

       ASSIGN par_mensagem = ''.

       IF crawepr.dsnivris <> aux_dsnivris AND           
          /* nao atualizar o risco no caso de cessao */
          aux_flcescrd = FALSE THEN 
          DO:
               FIND CURRENT crawepr EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               IF AVAIL crawepr THEN DO:
                  ASSIGN par_mensagem = 'O risco da proposta foi de "' +
                                        crawepr.dsnivris +
                                        '" e o do contrato sera de "' +
                                        aux_dsnivris + '".'
                         crawepr.dsnivris = aux_dsnivris
                                                 crawepr.dsnivori = aux_dsnivris.

                                  RUN proc_gerar_log (INPUT par_cdcooper,
                           INPUT par_cdoperad,
                           INPUT "",
                           INPUT aux_dsorigem,
                           INPUT par_mensagem,
                           INPUT TRUE,
                           INPUT par_idseqttl,
                           INPUT par_nmdatela,
                           INPUT par_nrdconta,
                          OUTPUT aux_nrdrowid).

               END.

          END.

       IF crawepr.nrctaav1 > 0   THEN
          DO:
             FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                crapass.nrdconta = crawepr.nrctaav1
                                NO-LOCK NO-ERROR.

             IF NOT AVAIL crapass THEN
                DO:
                   ASSIGN aux_cdcritic = 9.
                   UNDO EFETIVACAO, LEAVE EFETIVACAO.

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
                      ASSIGN aux_dscritic = "Nao foi possivel verificar " +
                                            "o cadastro restritivo.".

                   UNDO EFETIVACAO, LEAVE EFETIVACAO.

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
                   UNDO EFETIVACAO, LEAVE EFETIVACAO.

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
                      ASSIGN aux_dscritic = "Nao foi possivel verificar " +
                                            "o cadastro restritivo.".
                   UNDO EFETIVACAO, LEAVE EFETIVACAO.

                 END.

       END.

       IF aux_cdcritic <> 0   THEN
          UNDO EFETIVACAO , LEAVE EFETIVACAO.

       ASSIGN craplcr.flgsaldo = TRUE.

       RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

       IF NOT VALID-HANDLE(h-b1wgen0043)  THEN
          DO:
              ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0043.".

              UNDO EFETIVACAO, LEAVE EFETIVACAO.
          END.

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

       DELETE PROCEDURE h-b1wgen0043.

       IF RETURN-VALUE <> "OK"   THEN
          EMPTY TEMP-TABLE tt-erro.
         
         /* UNDO EFETIVACAO , LEAVE EFETIVACAO. */

       /* Acionar rotina de Gravacao do Calculo CET gerado */
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       RUN STORED-PROCEDURE pc_calculo_cet_emprestimos
           aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper, /* Cooperativa */
                             INPUT par_dtmvtolt, /* Data Movimento */
                             INPUT par_nrdconta, /* Conta */
                             INPUT par_nmdatela, /* Programa chamador */
                             INPUT crapass.inpessoa, /* Indicativo de pessoa */
                             INPUT craplcr.cdusolcr, /* Codigo de uso da linha de credito */
                             INPUT crawepr.cdlcremp, /* Linha de credio  */
                             INPUT crawepr.tpemprst, /* Tipo da operacao */
                             INPUT crawepr.nrctremp, /* Contrato         */
                             INPUT crawepr.dtlibera, /* Data liberacao   */
                             INPUT crawepr.vlemprst, /* Valor emprestado */
                             INPUT crawepr.txmensal, /* Taxa mensal */
                             INPUT crawepr.vlpreemp, /* valor parcela    */  
                             INPUT crawepr.qtpreemp, /* prestacoes       */
                             INPUT crawepr.dtdpagto, /* data pagamento   */
                             INPUT crawepr.cdfinemp, /* finalidade */
                             INPUT aux_dscatbem, /* Categoria Bem */
                             INPUT crawepr.idfiniof, /* */
                             INPUT aux_dsctrliq, /* Contratos Liquidados */
                             INPUT "S", /* Gravar */
                            OUTPUT 0,
                            OUTPUT 0,
                            OUTPUT 0,
                            OUTPUT "").

       CLOSE STORED-PROC pc_calculo_cet_emprestimos 
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

       ASSIGN aux_cdcritic = 0
              aux_dscritic = ""
              aux_cdcritic = pc_calculo_cet_emprestimos.pr_cdcritic 
                             WHEN pc_calculo_cet_emprestimos.pr_cdcritic <> ?
              aux_dscritic = pc_calculo_cet_emprestimos.pr_dscritic 
                             WHEN pc_calculo_cet_emprestimos.pr_dscritic <> ?.
           
       IF  aux_cdcritic <> 0   OR
           aux_dscritic <> ""  THEN
           DO:                                    
               CREATE tt-erro.
               ASSIGN tt-erro.cdcritic = aux_cdcritic
                      tt-erro.dscritic = aux_dscritic.

               UNDO EFETIVACAO, LEAVE EFETIVACAO.
           END.
         
        /*Validaçao e efetivaçao do seguro prestamista -- PRJ438 - Paulo Martins (Mouts)*/     
        IF crapass.inpessoa = 1 THEN
        DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
          RUN STORED-PROCEDURE pc_efetiva_proposta_sp
                               aux_handproc = PROC-HANDLE NO-ERROR
                        (INPUT par_cdcooper,      /* Cooperativa */
                         INPUT par_nrdconta,      /* Número da conta */
                         INPUT par_nrctremp,      /* Número emrepstimo */
                         INPUT par_cdagenci,      /* Agencia */
                         INPUT par_nrdcaixa,      /* Caixa */
                         INPUT par_cdoperad,      /* Operador   */
                         INPUT par_nmdatela,      /* Tabela   */
                         INPUT par_idorigem,      /* Origem  */
                        OUTPUT 0,
                        OUTPUT "").

          CLOSE STORED-PROC pc_efetiva_proposta_sp 
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
          ASSIGN aux_cdcritic = pc_efetiva_proposta_sp.pr_cdcritic
                                   WHEN pc_efetiva_proposta_sp.pr_cdcritic <> ?
                 aux_dscritic = pc_efetiva_proposta_sp.pr_dscritic
                                   WHEN pc_efetiva_proposta_sp.pr_dscritic <> ?.
          IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
            DO:
              CREATE tt-erro.
              ASSIGN tt-erro.cdcritic = aux_cdcritic
                     tt-erro.dscritic = aux_dscritic.
            UNDO EFETIVACAO, LEAVE EFETIVACAO.
        END.
        END.
       
       ASSIGN aux_flgtrans = TRUE.

    END.  /*  DO TRANSACTION  */

    IF NOT aux_flgtrans   THEN
       DO:
           IF CAN-FIND(FIRST tt-erro)   THEN
              RETURN "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
       END.

    IF  par_flgerlog   THEN
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

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctremp",
                                     INPUT par_nrctremp,
                                     INPUT par_nrctremp).
        END.
    RETURN "OK".

END PROCEDURE. /*   grava efetivacao proposta */

FOR EACH crapcop FIELDS(cdcooper) WHERE crapcop.flgativo = TRUE NO-LOCK:

  FOR EACH crawepr FIELDS(cdcooper cdagenci dtdpagto cdfinemp cdorigem nrdconta nrctremp dtmvtolt)WHERE crawepr.dtmvtolt > 01/22/2019 
                     AND crawepr.cdfinemp = 68
                     AND crawepr.cdorigem <> 5
                     AND crawepr.cdcooper = crapcop.cdcooper
                     NO-LOCK:
                     
     IF CAN-FIND(FIRST craplcm WHERE craplcm.cdcooper = crawepr.cdcooper
                               AND craplcm.nrdconta = crawepr.nrdconta
                               AND craplcm.nrdocmto = crawepr.nrctremp
                               AND craplcm.dtmvtolt >= crawepr.dtmvtolt) THEN
         DO:
            
             IF NOT CAN-FIND(FIRST crapepr WHERE crapepr.cdcooper = crawepr.cdcooper
                               AND crapepr.nrdconta = crawepr.nrdconta
                               AND crapepr.nrctremp = crawepr.nrctremp
                               AND crapepr.dtmvtolt >= crawepr.dtmvtolt) THEN
                               
               DO:
                   ASSIGN aux_dtmvtolt = string(crawepr.dtmvtolt + 1).
                   
                   
                  /* validar dia util, senao for retorna o proximo - Rotina Oracle */
                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                  RUN STORED-PROCEDURE pc_valida_dia_util
                    aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT crawepr.cdcooper         /* pr_cdcooper */
                                  ,INPUT-OUTPUT date(aux_dtmvtolt)  /* pr_dtmvtolt */
                                  ,INPUT "P"         /* pr_tipo */
                                  ,INPUT 1                    /* pr_feriado - Considerar feriados*/
                                  ,INPUT 0).                  /* pr_excultdia - Nao excluir ultimo dia do ano*/

                  CLOSE STORED-PROC pc_valida_dia_util
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}

                  /* FIM validar dia util - Rotina Oracle */

                 
               GRAVA_EFETIVA: DO TRANSACTION ON ERROR  UNDO GRAVA_EFETIVA, LEAVE GRAVA_EFETIVA
                                       ON ENDKEY UNDO GRAVA_EFETIVA, LEAVE GRAVA_EFETIVA:
                   
                    RUN grava_efetivacao_proposta     (INPUT crawepr.cdcooper,
                                                       INPUT crawepr.cdagenci,
                                                       INPUT 100,
                                                       INPUT "1",
                                                       INPUT "CMAPRV", /*par_nmdatela*/
                                                       INPUT 3,
                                                       INPUT crawepr.nrdconta,
                                                       INPUT 1,
                                                       INPUT crawepr.dtmvtolt,
                                                       INPUT TRUE,
                                                       INPUT crawepr.nrctremp,
                                                       INPUT 0,  /*par_insitapr*/
                                                       INPUT "", /*par_dsobscmt*/
                                                       INPUT crawepr.dtdpagto,
                                                       INPUT 0, /*par_cdbccxlt*/
                                                       INPUT 0, /*par_nrdolote*/
                                                       INPUT date(aux_dtmvtolt),
                                                       INPUT 0, /*par_inproces*/
                                                       /* calculo de tarifa sera
                                                       realizado na propria rotina
                                                       INPUT aux_vltarifa,
                                                       INPUT aux_vltaxiof,
                                                       INPUT aux_vltariof,*/
                                                       INPUT 0,
                                                       OUTPUT aux_dsmesage,
                                                       OUTPUT TABLE tt-ratings,
                                                       OUTPUT TABLE tt-erro). 
                  
                  FOR EACH tt-erro NO-LOCK:
                      MESSAGE STRING(tt-erro.cdcritic) + " - " + tt-erro.dscritic VIEW-AS ALERT-BOX.
                  END.
                  
                  IF RETURN-VALUE <> "OK" THEN
                     UNDO GRAVA_EFETIVA, LEAVE GRAVA_EFETIVA.
                     
                  END.
               
               END.
         END.
         
  END.
END.

    