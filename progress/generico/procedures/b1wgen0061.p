/*.............................................................................

    Programa: b1wgen0061.p
    Autor   : Jose Luis (DB1)
    Data    : Marco/2010                   Ultima atualizacao: 20/04/2017

    Objetivo  : Tranformacao BO tela CONTAS - CLIENTE FINANCEIRO

    Alteracoes: 05/08/2010 - Acerto na dtabtcct para emissao ficha (Guilherme)
    
                18/08/2010 - Ajustar alteração acima na opção alterar (David).
                
                06/06/2011 - Retirado critica das procedures Busca_Dados,
                             Valida_Dados para permitir a exclusao do 
                             cadastramento sem que seja no mesmo dia 
                             (Adriano).
                
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                22/07/2014 - Alterado atribuicao do campo tt-fichacad.cdagedet
                             na procedure Busca_Impressao. (Reinert)
   
                07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)

			    20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).

			   
.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/b1wgen0061tt.i &SESSAO-BO=SIM }
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i}

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.

/*............................. PROCEDURES ..................................*/

PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR /* I/A/E */               NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-dadoscf.
    DEF OUTPUT PARAM TABLE FOR tt-crapsfn.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados do Cliente Financeiro"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-dadoscf.
        EMPTY TEMP-TABLE tt-crapsfn.
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapass FIELDS(cdcooper nrdconta inpessoa nrcpfcgc 
                                 cdagenci nmprimtl)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

        CREATE tt-dadoscf.
        ASSIGN 
            tt-dadoscf.cdcooper = crapass.cdcooper
            tt-dadoscf.nrdconta = crapass.nrdconta
            tt-dadoscf.inpessoa = crapass.inpessoa
            tt-dadoscf.cdagenci = crapass.cdagenci
            tt-dadoscf.nrdrowid = ROWID(crapass).

        FOR FIRST crapcop FIELDS(nmextcop)
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:

            ASSIGN tt-dadoscf.nmextcop = crapcop.nmextcop.
        END.

        FOR FIRST crapttl FIELDS(cdcooper nrdconta idseqttl nmextttl nrcpfcgc)
                          WHERE crapttl.cdcooper = crapass.cdcooper AND
                                crapttl.nrdconta = crapass.nrdconta AND 
                                crapttl.idseqttl = par_idseqttl     NO-LOCK:
        END.

        IF  AVAILABLE crapttl THEN
            ASSIGN
               tt-dadoscf.nmextttl = crapttl.nmextttl
               tt-dadoscf.nrcpfcgc = crapttl.nrcpfcgc.
        ELSE
            ASSIGN                    
               tt-dadoscf.nmextttl = crapass.nmprimtl
               tt-dadoscf.nrcpfcgc = crapass.nrcpfcgc.

        FOR FIRST crapage FIELDS(nmresage)
                          WHERE crapage.cdcooper = crapass.cdcooper AND
                                crapage.cdagenci = crapass.cdagenci NO-LOCK:

            ASSIGN tt-dadoscf.nmresage = crapage.nmresage.
        END.

        /* Garantir a informacao do departamento do operador, sugestao David */
        FOR FIRST crapope FIELDS(cddepart)
                          WHERE crapope.cdcooper = par_cdcooper AND
                                crapope.cdoperad = par_cdoperad NO-LOCK:
            ASSIGN par_cddepart = crapope.cddepart.
        END.

        /* 1 = DADOS, 2 = FICHA CADASTRAL */
        FOR EACH crapsfn WHERE crapsfn.cdcooper = crapass.cdcooper    AND
                               crapsfn.nrcpfcgc = tt-dadoscf.nrcpfcgc AND
                               crapsfn.tpregist = par_tpregist        AND
                               (IF par_nrseqdig <> 0 THEN
                                crapsfn.nrseqdig = par_nrseqdig ELSE TRUE) 
                               NO-LOCK: 

            IF  CAN-DO("A,E",par_cddopcao) AND ROWID(crapsfn) <> par_nrdrowid 
                THEN
                NEXT.

            CREATE tt-crapsfn.
            BUFFER-COPY crapsfn TO tt-crapsfn
                ASSIGN 
                   tt-crapsfn.nrdctasf = crapsfn.nrdconta
                   tt-crapsfn.dtmvtosf = crapsfn.dtmvtolt
                   tt-crapsfn.nrdrowid = ROWID(crapsfn).

            FOR FIRST crapban FIELDS(nmextbcc)
                              WHERE crapban.cdbccxlt = tt-crapsfn.cddbanco 
                              NO-LOCK:
                ASSIGN tt-crapsfn.nmdbanco = crapban.nmextbcc.
            END.

            FOR FIRST crapagb FIELDS(nmageban)
                              WHERE crapagb.cddbanco = tt-crapsfn.cddbanco AND
                                    crapagb.cdageban = tt-crapsfn.cdageban 
                                    NO-LOCK:
                ASSIGN tt-crapsfn.nmageban = crapagb.nmageban.
            END.
            
            /* verificacao se sera possivel concluir as operacoes */
            IF  tt-crapsfn.tpregist = 1 THEN
                DO:
                   CASE par_cddopcao:
                       WHEN "A" THEN DO:
                           IF  tt-crapsfn.dtmvtolt <> par_dtmvtolt        AND
                               par_cddepart  <> 20   AND   /* TI */
                               par_cddepart  <> 8   THEN   /* COORD.ADM/FINANCEIRO */ 
                               DO:
                                  aux_dscritic = "Somente eh permitido alterar"
                                               + " registros gerados hoje!".
                                  UNDO Busca, LEAVE Busca.
                               END.
                       END.
                       
                   END CASE.
                END.
            ELSE
                DO:
                   CASE par_cddopcao:
                       WHEN "E" THEN DO:
                           IF  tt-crapsfn.dtdenvio <> ? THEN
                               DO:
                                  aux_dscritic = "Nao eh possivel excluir, " + 
                                                 "registro ja foi enviado!".
                                  UNDO Busca, LEAVE Busca.
                               END.

                           IF  NOT CAN-FIND(gncpicf NO-LOCK WHERE  
                                   gncpicf.cdcooper = crapsfn.cdcooper AND
                                   gncpicf.nrcpfcgc = crapsfn.nrcpfcgc AND
                                   gncpicf.tpregist = crapsfn.tpregist AND
                                   gncpicf.nrseqdig = crapsfn.nrseqdig) THEN
                               DO:
                                  aux_dscritic = "Nao foi encontrado registro "
                                                 + "generico cliente SFN.".
                                  UNDO Busca, LEAVE Busca.
                               END.
                       END.
                   END CASE.
                END.
        END.

        /* se for alteracao ou exclusao, deve encontrar o registro */
        IF  CAN-DO("A,E",par_cddopcao)             AND 
            NOT TEMP-TABLE tt-crapsfn:HAS-RECORDS THEN
            DO:
               ASSIGN aux_dscritic = "Registro do Cliente Financeiro nao " + 
                                     "foi encontrado".
               LEAVE Busca.
            END.

        LEAVE Busca.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE 
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog AND par_cddopcao = "C" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK"
                                   THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR /* I/A/E */               NO-UNDO.
    DEF  INPUT PARAM par_desopcao AS LOG  /* D/E */                 NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddbanco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageban AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtabtcct AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctasf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dgdconta AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nminsfin AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtosf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdenvio AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados do Cliente Financeiro"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.
        
        IF  par_nrcpfcgc = 0 THEN
            DO:
               ASSIGN aux_cdcritic = 27.
               LEAVE Valida.
            END.

        /* validar a instituicao (banco) */
        IF  NOT CAN-FIND(crapban NO-LOCK WHERE 
                                 crapban.cdbccxlt = par_cddbanco) AND
            par_cddbanco <> 0 THEN
            DO:
               ASSIGN aux_cdcritic = 57.
               LEAVE Valida.
            END.

        /* validar a agencia bancaria */
        IF  NOT CAN-FIND(crapagb NO-LOCK WHERE 
                                 crapagb.cddbanco = par_cddbanco AND
                                 crapagb.cdageban = par_cdageban) AND
            par_cddbanco <> 0 THEN
            DO:
               ASSIGN aux_cdcritic = 15.
               LEAVE Valida.
            END.
        
        /* Garantir a informacao do departamento do operador, sugestao David */
        FOR FIRST crapope FIELDS(cddepart)
                          WHERE crapope.cdcooper = par_cdcooper AND
                                crapope.cdoperad = par_cdoperad NO-LOCK:
            ASSIGN par_cddepart = crapope.cddepart.
        END.
        
        /* D = DADOS SISTEMA FINANCEIRO */
        IF  par_desopcao THEN 
            DO: 
               CASE par_cddopcao:
                   WHEN "E" THEN DO:
                       IF  NOT CAN-FIND(crapsfn NO-LOCK WHERE  
                                        crapsfn.cdcooper = par_cdcooper AND
                                        crapsfn.nrcpfcgc = par_nrcpfcgc AND
                                        crapsfn.tpregist = par_tpregist AND
                                        crapsfn.nrseqdig = par_nrseqdig) THEN
                           DO:
                              aux_dscritic = "Nao foi encontrado registro " +
                                             "do SFN.".
                              LEAVE Valida.

                           END.
                       
                       LEAVE Valida.
                   END.
                   WHEN "A" THEN DO:
                       IF  NOT CAN-FIND(crapsfn NO-LOCK WHERE  
                                        crapsfn.cdcooper = par_cdcooper AND
                                        crapsfn.nrcpfcgc = par_nrcpfcgc AND
                                        crapsfn.tpregist = par_tpregist AND
                                        crapsfn.nrseqdig = par_nrseqdig) THEN
                           DO:
                              aux_dscritic = "Nao foi encontrado registro " +
                                             "do SFN.".
                              LEAVE Valida.
                           END.

                       IF  par_dtmvtosf <> par_dtmvtolt            AND
                           par_cddepart <> 20   AND  /* TI */
                           par_cddepart <> 8   THEN  /* COORD.ADM/FINANCEIRO */
                           DO:
                              aux_dscritic = "Somente eh permitido alterar " + 
                                             "registros gerados hoje!".
                              LEAVE Valida.
                           END.
                   END.
               END CASE.

               /* se houve erro no 'case', retorna da procedure */
               IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                   LEAVE Valida.

               /* validar data de abertura da conta */
               IF  par_dtabtcct = ? THEN
                   DO:
                      aux_dscritic = "Informe a data de abertura da conta".
                      LEAVE Valida.
                   END.

               /* abertura da conta menor que a data do sistema */
               IF  par_dtabtcct > par_dtmvtolt THEN
                   DO:
                      aux_dscritic = "Data da abertura da conta nao pode ser" +
                                     " maior que a data atual.".
                      LEAVE Valida.
                   END.

               /* validar numero da conta */
               IF  par_nrdctasf = 0 THEN
                   DO:
                      aux_dscritic = "Informe o numero da conta corrente " +
                                     "(sem DV)".
                      LEAVE Valida.
                   END.

               /* validar o digito verificador da conta */
               IF  par_dgdconta = "" THEN
                   DO:
                      aux_dscritic = "Informe o Digito Verificador (DV) da " + 
                                     "conta corrente".
                      LEAVE Valida.
                   END.

               /* se nao informou o banco deve validar o nome da instituicao */
               IF  par_nminsfin = "" AND par_cddbanco = 0 THEN
                   DO:
                      aux_dscritic = "Informe o nome da instituicao " + 
                                     "financeira".
                      LEAVE Valida.
                   END.
            END.
        ELSE
            /* E = EMISSAO DA FICHA CADASTRAL */
            DO: 
               CASE par_cddopcao:
                   WHEN "I" THEN DO:
                       IF  NOT CAN-FIND(crapban NO-LOCK WHERE 
                                        crapban.cdbccxlt = par_cddbanco) THEN
                           DO:
                              ASSIGN aux_cdcritic = 57.
                              LEAVE Valida.
                           END.

                       IF  NOT CAN-FIND(crapagb NO-LOCK WHERE  
                                        crapagb.cddbanco = par_cddbanco AND
                                        crapagb.cdageban = par_cdageban) THEN
                           DO:
                              ASSIGN aux_cdcritic = 15.
                              LEAVE Valida.
                           END.
                   END.

                   WHEN "E" THEN DO:
                       IF  NOT CAN-FIND(crapsfn NO-LOCK WHERE  
                                        crapsfn.cdcooper = par_cdcooper AND
                                        crapsfn.nrcpfcgc = par_nrcpfcgc AND
                                        crapsfn.tpregist = par_tpregist AND
                                        crapsfn.nrseqdig = par_nrseqdig) THEN
                           DO:
                              aux_dscritic = "Nao foi encontrado registro " +
                                             "do SFN.".
                              LEAVE Valida.
                           END.

                       IF  par_dtdenvio <> ? THEN
                           DO:
                              aux_dscritic = "Nao eh possivel excluir, " + 
                                             "registro ja foi enviado!".
                              LEAVE Valida.
                           END.

                       IF  NOT CAN-FIND(gncpicf NO-LOCK WHERE  
                                        gncpicf.cdcooper = par_cdcooper AND
                                        gncpicf.nrcpfcgc = par_nrcpfcgc AND
                                        gncpicf.tpregist = par_tpregist AND
                                        gncpicf.nrseqdig = par_nrseqdig) THEN
                           DO:
                              aux_dscritic = "Nao foi encontrado registro " +
                                             "generico cliente SFN.".
                              LEAVE Valida.
                           END.
                   END.
               END CASE.

               /* se houve erro no 'case', retorna da procedure */
               IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                   LEAVE Valida.
            END.

        LEAVE Valida.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE 
        ASSIGN aux_retorno = "OK".
                                                                             
    IF  par_flgerlog AND aux_retorno <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN YES ELSE NO),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR /* I/A */                 NO-UNDO.
    DEF  INPUT PARAM par_desopcao AS LOG  /* D/E */                 NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddbanco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageban AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtabtcct AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctasf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dgdconta AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nminsfin AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrseqdig AS INTE                                    NO-UNDO.
    DEF VAR aux_flgenvio AS LOG                                     NO-UNDO.
    DEF VAR aux_dtdenvio AS DATE                                    NO-UNDO.
    DEF VAR aux_insitcta AS INTE                                    NO-UNDO.
    DEF VAR aux_cdmotdem AS INTE                                    NO-UNDO.
    DEF VAR aux_dtdemiss AS DATE                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    DEF VAR aux_dtabtcct AS DATE                                    NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Grava dados do Cliente Financeiro"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Grava: DO TRANSACTION
       ON ERROR  UNDO Grava, LEAVE Grava
       ON QUIT   UNDO Grava, LEAVE Grava
       ON STOP   UNDO Grava, LEAVE Grava
       ON ENDKEY UNDO Grava, LEAVE Grava:

       EMPTY TEMP-TABLE tt-erro.
       EMPTY TEMP-TABLE tt-crapsfn-log.
       
       CASE par_cddopcao:
           WHEN "I" THEN DO:
               FOR FIRST crapass FIELDS(dtdemiss 
                                        cdmotdem 
                                        inpessoa
                                        dtadmiss)
                                 WHERE 
                                 crapass.cdcooper = par_cdcooper AND
                                 crapass.nrdconta = par_nrdconta 
                                 NO-LOCK:

                   IF  crapass.dtdemiss = ? THEN
                       ASSIGN aux_insitcta = 1.
                   ELSE
                       DO:
                           ASSIGN 
                               aux_dtdemiss = crapass.dtdemiss 
                               aux_insitcta = 2.

                           IF  crapass.cdmotdem = 2 OR  
                               crapass.cdmotdem = 4 OR
                               crapass.cdmotdem = 5 THEN
                               ASSIGN aux_cdmotdem = 2. 
                           ELSE
                               ASSIGN aux_cdmotdem = 1.
                       END.

                   ASSIGN aux_inpessoa = crapass.inpessoa.
               END.

               /* procurar a ultima sequencia para atualizar o 
                  registro SFN e o ICF */
               ASSIGN aux_nrseqdig = 1.

               FOR LAST crapsfn FIELDS(nrseqdig)
                   WHERE crapsfn.cdcooper = par_cdcooper AND
                         crapsfn.nrcpfcgc = par_nrcpfcgc AND
                         crapsfn.tpregist = par_tpregist NO-LOCK
                         BY crapsfn.nrseqdig:

                   ASSIGN aux_nrseqdig = crapsfn.nrseqdig + 1.
               END.

               /* verifica se e preciso setar os controles de envio */
               /* DADOS */
               IF  par_desopcao THEN 
                   ASSIGN 
                       aux_flgenvio = FALSE
                       aux_dtdemiss = ?
                       aux_insitcta = 0
                       aux_dtabtcct = par_dtabtcct.
               ELSE  
                   /* EMISSAO */
                   DO:
                      FOR FIRST crapcop FIELDS(cdagebcb)
                                        WHERE crapcop.cdcooper = par_cdcooper 
                                        NO-LOCK:

                          IF  crapcop.cdagebcb = 0 THEN
                              ASSIGN 
                                 aux_flgenvio = TRUE        
                                 aux_dtdenvio = par_dtmvtolt.
                      END.

                      ASSIGN aux_dtabtcct = crapass.dtadmiss.

                      /* CRIA TABELA GENERICA GNCPICF */
                      RUN Inclui_Icf
                          ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_nmdatela,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,
                            INPUT TRUE, /* log */
                            INPUT par_nrcpfcgc,
                            INPUT par_tpregist,
                            INPUT aux_nrseqdig,
                            INPUT aux_inpessoa,
                            INPUT par_dtmvtolt,
                            INPUT par_cddbanco,
                            INPUT par_cdageban,
                            INPUT aux_dtabtcct,
                            INPUT par_dgdconta,
                            INPUT par_nminsfin,
                            INPUT aux_flgenvio,
                            INPUT aux_insitcta,
                            INPUT aux_cdmotdem,
                           OUTPUT aux_cdcritic,
                           OUTPUT aux_dscritic ).

                      IF  RETURN-VALUE <> "OK" OR 
                          (aux_dscritic <> "" OR aux_cdcritic <> 0) THEN
                          UNDO Grava, LEAVE Grava.

                      ASSIGN par_nrdctasf = par_nrdconta.
                   END.

           END.
           WHEN "A" THEN DO:
               ASSIGN aux_nrseqdig = par_nrseqdig
                      aux_dtabtcct = par_dtabtcct.
           END.
           OTHERWISE 
               aux_dscritic = "O campo 'cddopcao' deve ser <I> ou <A>".
       END CASE.

       IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           UNDO Grava, LEAVE Grava.

       ContadorSfn: DO aux_contador = 1 TO 10:

          FIND crapsfn WHERE crapsfn.cdcooper = par_cdcooper AND
                             crapsfn.nrcpfcgc = par_nrcpfcgc AND
                             crapsfn.tpregist = par_tpregist AND
                             crapsfn.nrseqdig = aux_nrseqdig
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF  NOT AVAILABLE crapsfn THEN
              DO:
                  IF  LOCKED(crapsfn) THEN
                      DO:
                         IF  aux_contador = 10 THEN
                             DO:
                                aux_dscritic = "Informacoes do sistema finan" +
                                               "ceiro nacional sendo alterad" +
                                               "o em outra estacao".
                                LEAVE ContadorSfn.
                             END.
                         ELSE 
                             DO: 
                                PAUSE 1 NO-MESSAGE.
                                NEXT ContadorSfn.
                             END.
                      END.
                  ELSE 
                      DO:
                         IF  par_cddopcao = "I" THEN
                             DO:
                                 CREATE crapsfn.
                                 ASSIGN 
                                     crapsfn.cdcooper = par_cdcooper 
                                     crapsfn.nrcpfcgc = par_nrcpfcgc
                                     crapsfn.tpregist = par_tpregist
                                     crapsfn.nrseqdig = aux_nrseqdig
                                     crapsfn.inpessoa = aux_inpessoa.

                                 ASSIGN aux_flgenvio = YES.
                                 VALIDATE crapsfn.
                                 LEAVE ContadorSfn.
                             END.
                         ELSE
                             DO:
                                aux_dscritic = "Nao foi encontrado registro " +
                                               "do SFN.".
                                LEAVE ContadorSfn.
                             END.
                      END.  
              END.
          ELSE 
              LEAVE ContadorSfn.
       END.

       IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           UNDO Grava, LEAVE Grava.

       /* preparar p/ log */
       IF  par_cddopcao <> "I" THEN
           DO:
              CREATE tt-crapsfn-log.
              BUFFER-COPY crapsfn TO tt-crapsfn-log.
           END.

       ASSIGN 
           crapsfn.dtabtcct = aux_dtabtcct
           crapsfn.cddbanco = par_cddbanco
           crapsfn.cdageban = par_cdageban
           crapsfn.dgdconta = UPPER(par_dgdconta)
           crapsfn.dtmvtolt = par_dtmvtolt
           crapsfn.cdoperad = par_cdoperad
           crapsfn.hrtransa = TIME
           crapsfn.nrdconta = par_nrdctasf
           crapsfn.nminsfin = UPPER(par_nminsfin)
           crapsfn.flgenvio = aux_flgenvio
           crapsfn.dtdenvio = aux_dtdenvio
           crapsfn.dtdemiss = aux_dtdemiss
           crapsfn.insitcta = aux_insitcta
           crapsfn.cdmotdem = aux_cdmotdem NO-ERROR.

       IF  ERROR-STATUS:ERROR THEN
           DO:
              ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
              UNDO Grava, LEAVE Grava.
           END.

       RUN Gera_Log
           ( INPUT par_cdcooper,
             INPUT par_nrdconta,
             INPUT par_idseqttl,
             INPUT par_cdoperad,
             INPUT par_nmdatela,
             INPUT par_cddopcao,
             INPUT par_desopcao,
             INPUT aux_dtabtcct,
             INPUT par_cddbanco,
             INPUT par_cdageban,
             INPUT par_nrdctasf,
             INPUT par_dgdconta,
             INPUT par_nminsfin,
             INPUT TABLE tt-crapsfn-log,
            OUTPUT aux_dscritic ) .

       IF  RETURN-VALUE <> "OK" THEN
           DO:
              ASSIGN aux_dscritic = "A geracao dos logs nao foi concluida " +
                                    "corretamente.".
              UNDO Grava, LEAVE Grava.
           END.

       ASSIGN aux_retorno = "OK".

       LEAVE Grava.
    END.

    RELEASE crapsfn.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_retorno = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
                                                                             
    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Inclui_Icf:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddbanco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageban AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtabtcct AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dgdconta AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nminsfin AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgenvio AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_insitcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmotdem AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Incluir Cliente Financeiro (ICF)"
        par_dscritic = ""
        par_cdcritic = 0
        aux_retorno = "NOK".

    Inclui: DO TRANSACTION
       ON ERROR  UNDO Inclui, LEAVE Inclui
       ON QUIT   UNDO Inclui, LEAVE Inclui
       ON STOP   UNDO Inclui, LEAVE Inclui
       ON ENDKEY UNDO Inclui, LEAVE Inclui:

       EMPTY TEMP-TABLE tt-erro.
       
       ContadorIcf: DO aux_contador = 1 TO 10:

          FIND gncpicf WHERE gncpicf.cdcooper = par_cdcooper AND
                             gncpicf.nrcpfcgc = par_nrcpfcgc AND
                             gncpicf.tpregist = par_tpregist AND
                             gncpicf.nrseqdig = par_nrseqdig
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF  NOT AVAILABLE gncpicf THEN
              DO:
                 IF  LOCKED(gncpicf) THEN
                     DO:
                        IF  aux_contador = 10 THEN
                            DO:
                               ASSIGN par_cdcritic = 341.
                               LEAVE ContadorIcf.
                            END.
                        ELSE
                            DO:
                               PAUSE 1 NO-MESSAGE.
                               NEXT ContadorIcf.
                            END.
                     END.
                 ELSE
                     DO:
                        CREATE gncpicf.
                        ASSIGN
                            gncpicf.cdcooper = par_cdcooper
                            gncpicf.nrcpfcgc = par_nrcpfcgc
                            gncpicf.tpregist = par_tpregist
                            gncpicf.nrseqdig = par_nrseqdig
                            gncpicf.cdagenci = par_cdagenci
                            gncpicf.inpessoa = par_inpessoa
                            gncpicf.dtabtcct = par_dtabtcct
                            gncpicf.cddbanco = par_cddbanco
                            gncpicf.cdageban = par_cdageban
                            gncpicf.dtmvtolt = par_dtmvtolt
                            gncpicf.cdoperad = par_cdoperad
                            gncpicf.hrtransa = TIME
                            gncpicf.nminsfin = CAPS(par_nminsfin)
                            gncpicf.cdcrictl = 0
                            gncpicf.flgenvio = par_flgenvio 
                            gncpicf.nrdconta = par_nrdconta
                            gncpicf.dgdconta = CAPS(par_dgdconta)
                            /*gncpicf.insitcta = par_insitcta*/
                            gncpicf.cdmotdem = par_cdmotdem NO-ERROR.
                        VALIDATE gncpicf.
                        IF  ERROR-STATUS:ERROR THEN
                            DO:
                              par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                              LEAVE ContadorIcf.
                            END.
    
                        LEAVE ContadorIcf.
                     END.
              END.
          ELSE
              LEAVE ContadorIcf.
       END.

       IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
           UNDO Inclui, LEAVE Inclui.

       ASSIGN aux_retorno = "OK".

       LEAVE Inclui.
    END.

    RELEASE gncpicf.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_retorno = "NOK".

    IF  par_flgerlog THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT par_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN YES ELSE NO),
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Exclui_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_desopcao AS LOG  /* D/E */                 NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtosf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdenvio AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

       

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Exclui dados do Cliente Financeiro"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    /* validar antes de excluir */
    RUN Valida_Dados
        ( INPUT par_cdcooper, 
          INPUT par_cdagenci, 
          INPUT par_nrdcaixa, 
          INPUT par_cdoperad, 
          INPUT par_nmdatela, 
          INPUT par_idorigem, 
          INPUT par_nrdconta, 
          INPUT par_idseqttl, 
          INPUT FALSE,        
          INPUT "E",          
          INPUT par_desopcao, 
          INPUT par_nrcpfcgc, 
          INPUT par_tpregist, 
          INPUT par_nrseqdig, 
          INPUT 0,            
          INPUT 0,            
          INPUT ?,            
          INPUT 0,            
          INPUT "",           
          INPUT "",           
          INPUT par_dtmvtosf, 
          INPUT par_dtmvtolt, 
          INPUT "",           
          INPUT par_dtdenvio, 
         OUTPUT TABLE tt-erro ) NO-ERROR.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    ASSIGN
        aux_dstransa = "Exclui dados do Cliente Financeiro"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Exclui: DO TRANSACTION
       ON ERROR  UNDO Exclui, LEAVE Exclui
       ON QUIT   UNDO Exclui, LEAVE Exclui
       ON STOP   UNDO Exclui, LEAVE Exclui
       ON ENDKEY UNDO Exclui, LEAVE Exclui:

       EMPTY TEMP-TABLE tt-erro.

       ContadorSfn: DO aux_contador = 1 TO 10:

          FIND crapsfn WHERE crapsfn.cdcooper = par_cdcooper AND
                             crapsfn.nrcpfcgc = par_nrcpfcgc AND
                             crapsfn.tpregist = par_tpregist AND
                             crapsfn.nrseqdig = par_nrseqdig
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF  NOT AVAILABLE crapsfn THEN
              DO:
                  IF  LOCKED(crapsfn) THEN
                      DO:
                         IF  aux_contador = 10 THEN
                             DO:
                                aux_dscritic = "Informacoes do sistema finan" +
                                               "ceiro nacional sendo alterad" +
                                               "o em outra estacao".
                                LEAVE ContadorSfn.
                             END.
                         ELSE 
                             DO: 
                                PAUSE 1 NO-MESSAGE.
                                NEXT ContadorSfn.
                             END.
                      END.
                  ELSE 
                      DO:
                         aux_dscritic = "Nao foi encontrado registro " +
                                        "do SFN.".
                         LEAVE ContadorSfn.
                      END.
              END.
          ELSE 
              DO:
                  DELETE crapsfn  NO-ERROR.
    
                  IF  ERROR-STATUS:ERROR THEN
                      DO:
                         ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                         LEAVE ContadorSfn.
                      END.

                  LEAVE ContadorSfn.
              END.
       END.

       IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           UNDO Exclui, LEAVE Exclui.

       ContadorCfi: DO aux_contador = 1 TO 10:

          FIND gncpicf WHERE gncpicf.cdcooper = par_cdcooper AND
                             gncpicf.nrcpfcgc = par_nrcpfcgc AND
                             gncpicf.tpregist = par_tpregist AND
                             gncpicf.nrseqdig = par_nrseqdig
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF  NOT AVAILABLE gncpicf THEN
              DO:
                  IF  LOCKED(gncpicf) THEN
                      DO:
                         IF  aux_contador = 10 THEN
                             DO:
                                aux_dscritic = "Informacoes do sistema finan" +
                                               "ceiro nacional sendo alterad" +
                                               "o em outra estacao".
                                LEAVE ContadorCfi.
                             END.
                         ELSE 
                             DO: 
                                PAUSE 1 NO-MESSAGE.
                                NEXT ContadorCfi.
                             END.
                      END.
              END.
          ELSE 
              DO:
                  DELETE gncpicf  NO-ERROR.
    
                  IF  ERROR-STATUS:ERROR THEN
                      DO:
                         ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                         LEAVE ContadorCfi.
                      END.

                  LEAVE ContadorCfi.
              END.
       END.

       IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           UNDO Exclui, LEAVE Exclui.

       RUN Gera_Log
           ( INPUT par_cdcooper,
             INPUT par_nrdconta,
             INPUT par_idseqttl,
             INPUT par_cdoperad,
             INPUT par_nmdatela,
             INPUT "E",
             INPUT par_desopcao,
             INPUT ?,
             INPUT 0,
             INPUT 0,
             INPUT 0,
             INPUT "",
             INPUT "",
             INPUT TABLE tt-crapsfn-log,
            OUTPUT aux_dscritic ) .

       IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           UNDO Exclui, LEAVE Exclui.

       ASSIGN aux_retorno = "OK".

       LEAVE Exclui.
    END.

    
    RELEASE crapsfn.
    RELEASE gncpicf.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_retorno = "NOK".
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.


    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-fichacad.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsmesref AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtpalavr AS INTE                                    NO-UNDO.
    DEF VAR aux_contapal AS INTE                                    NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados do Cliente Financeiro para impressao "
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Imprimir: DO ON ERROR UNDO Imprimir, LEAVE Imprimir:
        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt-fichacad.

        FOR FIRST crapsfn FIELDS(cddbanco cdageban)
                          WHERE crapsfn.cdcooper = par_cdcooper   
                            AND crapsfn.nrcpfcgc = par_nrcpfcgc 
                            AND crapsfn.tpregist = par_tpregist 
                            AND crapsfn.nrseqdig = par_nrseqdig NO-LOCK: 
        END.

        IF  NOT AVAILABLE crapsfn THEN
            DO:
               ASSIGN aux_dscritic = "Nao existem bancos cadastrados para " + 
                                     "impressao.".
               LEAVE Imprimir.
            END.

        ASSIGN aux_dsmesref = "JANEIRO,FEVEREIRO,MARCO,ABRIL," + 
                              "MAIO,JUNHO,JULHO,AGOSTO,"       +
                              "SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO".

        FOR FIRST crapcop FIELDS(nmrescop nmcidade nmextcop cdbcoctl)
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop THEN
            DO:
               ASSIGN aux_dscritic = "Cadastro de coperativa nao encontrado.".
               LEAVE Imprimir.
            END.

        FOR FIRST crapban FIELDS(cdbccxlt nmextbcc)
                          WHERE crapban.cdbccxlt = crapsfn.cddbanco NO-LOCK:
        END.

        IF  NOT AVAILABLE crapban THEN
            DO:
               ASSIGN aux_dscritic = "Nao existem bancos cadastrados para " + 
                                     "impressao.".
               LEAVE Imprimir.
            END.

        FOR FIRST crapagb FIELDS(cdageban nmageban)
                          WHERE crapagb.cddbanco = crapsfn.cddbanco AND
                                crapagb.cdageban = crapsfn.cdageban NO-LOCK:
        END.

        IF  NOT AVAILABLE crapagb THEN
            DO:
               ASSIGN aux_dscritic = "Nao existem agencias bancarias para " + 
                                     "impressao.".
               LEAVE Imprimir.
            END.

        FOR FIRST crapass FIELDS(inpessoa cdsitdct dtdemiss nmprimtl 
                                 nrcpfcgc dtabtcct dtadmiss )
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Imprimir.
            END.

        CREATE tt-fichacad.

        ASSIGN 
            tt-fichacad.cddbanco = STRING(crapban.cdbccxlt,"ZZ,ZZZ")
            tt-fichacad.nmdbanco = crapban.nmextbcc
            tt-fichacad.cdageban = STRING(crapagb.cdageban,"ZZ,ZZZ")
            tt-fichacad.nmageban = crapagb.nmageban
            tt-fichacad.nmrescop = crapcop.nmrescop
            tt-fichacad.nmprimtl = crapass.nmprimtl
            tt-fichacad.dtabtcct = (IF crapass.dtabtcct < crapass.dtadmiss 
                                   THEN crapass.dtabtcct ELSE crapass.dtadmiss)
            tt-fichacad.dstitulo = "FORNECIMENTO DA DATA DE INICIO DO " + 
                                   "RELACIONAMENTO DO CLIENTE"
            tt-fichacad.dssubtit = "RESOLUCAO 3279/BACEN"
            tt-fichacad.dsrodape = "AUTORIZO O ENVIO DAS INFORMACOES AO " + 
                                   "BANCO DESTINATARIO:" 
            tt-fichacad.cdagedet = STRING(crapagb.cdageban,"ZZ,ZZZ")
            tt-fichacad.cdinsdet = crapcop.cdbcoctl
            tt-fichacad.dsdcabec = CAPS(TRIM(crapcop.nmcidade) + ", "  +
                                        STRING(DAY(par_dtmvtolt),"99")
                                        +  " DE " +
                                        STRING(ENTRY(MONTH(par_dtmvtolt),
                                                     aux_dsmesref),"x(9)") 
                                        + " DE " + 
                                        STRING(YEAR(par_dtmvtolt),"9999") + 
                                        ".") NO-ERROR.
        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
               LEAVE Imprimir.
            END.

        /* Encerrada somente por demissao */
        IF  crapass.cdsitdct = 4  THEN
            tt-fichacad.dsdemiss = STRING(crapass.dtdemiss,"99/99/9999").
        ELSE
            tt-fichacad.dsdemiss = "XX/XX/XXXX".

        ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2.
        
        DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):
           IF  aux_contapal <= aux_qtpalavr THEN
               tt-fichacad.nmresbr1 = tt-fichacad.nmresbr1 +   
                                      (IF TRIM(tt-fichacad.nmresbr1) = "" 
                                       THEN "" ELSE " ") + 
                                      ENTRY(aux_contapal,crapcop.nmextcop," ").
           ELSE
               tt-fichacad.nmresbr2 = tt-fichacad.nmresbr2 +
                                      (IF TRIM(tt-fichacad.nmresbr2) = "" 
                                       THEN "" ELSE " ") + 
                                      ENTRY(aux_contapal,crapcop.nmextcop," ").
        END.  /*  Fim DO .. TO  */ 

        CASE crapass.cdsitdct:
            WHEN 1 THEN tt-fichacad.dssitdct = "NORMAL".
            WHEN 2 THEN tt-fichacad.dssitdct = "ENCERRADA PELO ASSOCIADO".
            WHEN 3 THEN tt-fichacad.dssitdct = "ENCERRADA PELA COOP".
            WHEN 4 THEN tt-fichacad.dssitdct = "ENCERRADA PELA DEMISSAO".
            WHEN 5 THEN tt-fichacad.dssitdct = "NAO APROVADA".
            WHEN 6 THEN tt-fichacad.dssitdct = "NORMAL - SEM TALAO".
            WHEN 9 THEN tt-fichacad.dssitdct = "ENCERRADA P/ OUTRO MOTIVO".
            OTHERWISE tt-fichacad.dssitdct = "".
        END CASE.

        CASE crapass.inpessoa:
           WHEN 1 THEN DO:
               ASSIGN 
                   tt-fichacad.dspessoa = "PESSOA FISICA"
                   tt-fichacad.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                                        "99999999999"),
                                                 "xxx.xxx.xxx-xx").

               IF  crapass.cdsitdct = 4 THEN
                   ASSIGN tt-fichacad.dssitdct = "ENCERRADA".
               ELSE
                   ASSIGN tt-fichacad.dssitdct = "ATIVA".

               FOR FIRST crapttl FIELDS(nmextttl)
                                 WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl = par_idseqttl NO-LOCK:
                   ASSIGN tt-fichacad.nmextttl = crapttl.nmextttl.
               END.

			   FOR FIRST crapttl FIELDS(nmextttl nrcpfcgc)
                                 WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl = 2 NO-LOCK:
                   
               END.

               IF  NOT AVAIL crapttl THEN
                   ASSIGN tt-fichacad.nmsegntl = "XXXXXXXXXXXXXX" 
                          tt-fichacad.nrcpfstl = "XXX.XXX.XXX-XX".
               ELSE
                   ASSIGN
                       tt-fichacad.nrcpfstl = STRING(STRING(crapttl.nrcpfcgc,
                                                            "99999999999"),
                                                     "xxx.xxx.xxx-xx")
                       tt-fichacad.nmsegntl = crapttl.nmextttl.

               
           END.

           OTHERWISE DO:
               ASSIGN 
                   tt-fichacad.dspessoa = "PESSOA JURIDICA"
                   tt-fichacad.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                                        "99999999999999"),
                                                 "xx.xxx.xxx/xxxx-xx")
                   tt-fichacad.nmextttl = crapass.nmprimtl.
           END.
        END CASE.

        LEAVE Imprimir.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        
    ELSE 
        ASSIGN aux_retorno = "OK".
                                                                             
    IF  par_flgerlog THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK"
                                   THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Gera_Log:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_desopcao AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dtabtcct AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddbanco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageban AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctasf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dgdconta AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nminsfin AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-crapsfn-log.

    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    /**** Cria os logs de alteracoes dos campos ****/
    DO ON ERROR UNDO, LEAVE:
        CASE par_cddopcao:
            WHEN "I" THEN DO:
                /* DADOS */
                IF  par_desopcao THEN
                    DO:
                       RUN proc_gerar_log 
                           ( INPUT par_cdcooper,  
                             INPUT par_cdoperad,  
                             INPUT aux_dscritic,  
                             INPUT aux_dsorigem,  
                             INPUT "SFN - Inclusao de conta",
                             INPUT YES,           
                             INPUT par_idseqttl,  
                             INPUT par_nmdatela,  
                             INPUT par_nrdconta,  
                            OUTPUT aux_nrdrowid ). 

                       RUN proc_gerar_log_item 
                          ( INPUT aux_nrdrowid,
                            INPUT "Abertura C/C",
                            INPUT "",
                            INPUT TRIM(STRING(par_dtabtcct,"99/99/9999")) ).

                       IF  par_cddbanco <> 0 THEN
                           DO:
                               RUN proc_gerar_log_item 
                                  ( INPUT aux_nrdrowid,
                                    INPUT "Cod. Banco",
                                    INPUT "",
                                    INPUT TRIM(STRING(par_cddbanco)) ).

                               RUN proc_gerar_log_item 
                                  ( INPUT aux_nrdrowid,
                                    INPUT "Agencia Banco",
                                    INPUT "",
                                    INPUT TRIM(STRING(par_cdageban)) ).

                               RUN proc_gerar_log_item 
                                  ( INPUT aux_nrdrowid,
                                    INPUT "Conta C/C",
                                    INPUT "",
                                    INPUT TRIM(STRING(par_nrdctasf)) ).

                               RUN proc_gerar_log_item 
                                  ( INPUT aux_nrdrowid,
                                    INPUT "DV",
                                    INPUT "",
                                    INPUT TRIM(STRING(par_dgdconta)) ).
                           END.
                       ELSE
                           RUN proc_gerar_log_item 
                              ( INPUT aux_nrdrowid,
                                INPUT "Instituicao Financeira",
                                INPUT "",
                                INPUT TRIM(STRING(par_nminsfin)) ).
                    END.
                ELSE
                    /* EMISSAO */
                    DO:
                       RUN proc_gerar_log 
                           ( INPUT par_cdcooper,  
                             INPUT par_cdoperad,  
                             INPUT aux_dscritic,  
                             INPUT aux_dsorigem,  
                             INPUT "SFN - Inclusao de conta - Emissao",
                             INPUT YES,           
                             INPUT par_idseqttl,  
                             INPUT par_nmdatela,  
                             INPUT par_nrdconta,  
                            OUTPUT aux_nrdrowid ). 

                       RUN proc_gerar_log_item 
                          ( INPUT aux_nrdrowid,
                            INPUT "Codigo Banco",
                            INPUT "",
                            INPUT TRIM(STRING(par_cddbanco)) ).

                       RUN proc_gerar_log_item 
                          ( INPUT aux_nrdrowid,
                            INPUT "Codigo Agencia",
                            INPUT "",
                            INPUT TRIM(STRING(par_cdageban)) ).
                    END.
            END.
            WHEN "A" THEN DO:
                FIND FIRST tt-crapsfn-log NO-ERROR.

                IF   NOT AVAILABLE tt-crapsfn-log THEN
                     LEAVE.

                RUN proc_gerar_log 
                    ( INPUT par_cdcooper,  
                      INPUT par_cdoperad,  
                      INPUT aux_dscritic,  
                      INPUT aux_dsorigem,  
                      INPUT "SFN - Alteracao de conta",
                      INPUT YES,           
                      INPUT par_idseqttl,  
                      INPUT par_nmdatela,  
                      INPUT par_nrdconta,  
                     OUTPUT aux_nrdrowid ) .

                IF  (par_dtabtcct <> tt-crapsfn-log.dtabtcct) THEN
                    RUN proc_gerar_log_item 
                       ( INPUT aux_nrdrowid,
                         INPUT "Abertura C/C",
                         INPUT tt-crapsfn-log.dtabtcct,
                         INPUT TRIM(STRING(par_dtabtcct,"99/99/9999"))).

                IF  (par_cddbanco <> tt-crapsfn-log.cddbanco)  THEN
                    RUN proc_gerar_log_item 
                       ( INPUT aux_nrdrowid,
                         INPUT "Cod. Banco",
                         INPUT tt-crapsfn-log.cddbanco,
                         INPUT TRIM(STRING(par_cddbanco))).

                IF  (par_cdageban <> tt-crapsfn-log.cdageban)  THEN
                    RUN proc_gerar_log_item 
                       ( INPUT aux_nrdrowid,
                         INPUT "Agencia Banco",
                         INPUT tt-crapsfn-log.cdageban,
                         INPUT TRIM(STRING(par_cdageban))).

                IF  (par_nrdctasf <> tt-crapsfn-log.nrdconta) THEN
                    RUN proc_gerar_log_item 
                       ( INPUT aux_nrdrowid,
                         INPUT "Conta C/C",
                         INPUT tt-crapsfn-log.nrdconta,
                         INPUT TRIM(STRING(par_nrdctasf))).

                IF  (par_dgdconta <> tt-crapsfn-log.dgdconta) THEN
                    RUN proc_gerar_log_item 
                       ( INPUT aux_nrdrowid,
                         INPUT "DV",
                         INPUT tt-crapsfn-log.dgdconta,
                         INPUT TRIM(STRING(par_dgdconta))).

                IF  (par_nminsfin <> tt-crapsfn-log.nminsfin) THEN
                    RUN proc_gerar_log_item 
                       ( INPUT aux_nrdrowid,
                         INPUT "Instituicao Financeira",
                         INPUT tt-crapsfn-log.nminsfin,
                         INPUT TRIM(STRING(par_nminsfin))).
            END.
            WHEN "E" THEN DO: 
                RUN proc_gerar_log 
                    ( INPUT par_cdcooper,  
                      INPUT par_cdoperad,  
                      INPUT aux_dscritic,  
                      INPUT aux_dsorigem,  
                      INPUT "SFN - Exclusao de conta" +
                            (IF NOT par_desopcao THEN " - Emissao" ELSE ""), 
                      INPUT YES,           
                      INPUT par_idseqttl,  
                      INPUT par_nmdatela,  
                      INPUT par_nrdconta,  
                     OUTPUT aux_nrdrowid ).
            END.

        END CASE.
    END.

    RETURN (IF aux_dscritic = "" THEN "OK" ELSE "NOK").

END PROCEDURE.

/*............................. FUNCTIONS ...................................*/
