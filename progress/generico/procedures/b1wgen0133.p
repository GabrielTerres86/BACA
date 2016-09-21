/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0133.p
    Autor   : Gabriel Capoia (DB1)
    Data    : 26/01/2012                     Ultima atualizacao: 05/03/2014

    Objetivo  : Tranformacao BO tela CADSPC

    Alteracoes: 15/03/2012 - Listar todos os registros SERASA/SPC (Oscar).
    
                11/04/2013 - Alteração para converter arquivo unix para
                             windows/dos (David Kruger).
                             
                13/11/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                23/01/2014 - Alterado a procedure "verifica_emprestimo"
                             para não ocorrer erro de CPF da conta nao confere
                             com o digitado. (James)
                          
                24/01/2014 - Alterado a procedure "Grava_Dados" para permitir
                             inserir avalista que nao possui conta (James).
                             
                27/01/2014 - Ajuste na procedure "Verifica_Fiador", para buscar
                             o avalista na opcao de Inluir. (James)
                             
                05/03/2014 - Incluso VALIDATE (Daniel).
............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen0133tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgenvlog.i
  &TELA-CONTAS=NAO &TELA-MATRIC=SIM &VAR-GERAL=SIM &SESSAO-BO=SIM }

DEF STREAM str_1.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.

DEF VAR aux_dsinsttu AS CHAR EXTENT 2 INIT ["SPC","SERASA"]          NO-UNDO.
DEF VAR aux_dsidenti AS CHAR EXTENT 4 INIT ["Dev1","","Fia1","Fia2"] NO-UNDO.

&SCOPED-DEFINE CAMPOS tpidenti nrctremp nrctrspc dtvencto vldivida~
                      dtinclus dtdbaixa tpinsttu

/* Pre-Processador para controle de erros 'Progress' */
&SCOPED-DEFINE GET-MSG ERROR-STATUS:GET-MESSAGE(1)

/*................................ PROCEDURES ..............................*/ 
/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA DOS DADOS PARA EXIBIÇÃO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrdev AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-devedor.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmresage AS CHAR                                    NO-UNDO.
    DEF VAR aux_opebaixa AS CHAR                                    NO-UNDO.
    DEF VAR aux_operador AS CHAR                                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_nrregist = par_nrregist.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-devedor.
        EMPTY TEMP-TABLE tt-erro.

        CASE par_cddopcao:

            WHEN "C" THEN DO:

                /* Consulta por CPF */
                IF  par_nrcpfcgc <> 0  THEN
                    DO:
                        IF  NOT CAN-FIND(
                            FIRST crapspc WHERE
                                  crapspc.nrcpfcgc = par_nrcpfcgc AND
                                  crapspc.cdcooper = par_cdcooper) THEN
                            DO:
                                ASSIGN aux_cdcritic = 870
                                       par_nmdcampo = "nrcpfcgc". 
                                LEAVE Busca.
                            END.

                        FIND FIRST crapass WHERE 
                                   crapass.nrcpfcgc = par_nrcpfcgc  AND
                                   crapass.cdcooper = par_cdcooper
                                   NO-LOCK NO-ERROR.
               
                        IF  AVAILABLE crapass THEN
                            ASSIGN aux_nmprimtl = crapass.nmprimtl.
                        ELSE
                            DO:
                                FIND FIRST crapavt WHERE 
                                           crapavt.nrcpfcgc = par_nrcpfcgc AND
                                           crapavt.cdcooper = par_cdcooper
                                           NO-LOCK NO-ERROR.
                                 
                                IF  AVAILABLE crapavt  THEN
                                    ASSIGN aux_nmprimtl = crapavt.nmdavali.
                            END.

                        FOR EACH crapspc FIELD({&CAMPOS})
                           WHERE crapspc.nrcpfcgc = par_nrcpfcgc AND
                                 crapspc.cdcooper = par_cdcooper NO-LOCK,
                           FIRST crapass FIELDS(nmprimtl cdcooper cdagenci)
                           WHERE crapass.cdcooper = crapspc.cdcooper AND
                                 crapass.nrdconta = crapspc.nrdconta
                                 NO-LOCK:

                            FOR FIRST crapage FIELDS(nmresage)
                                WHERE crapage.cdcooper = crapass.cdcooper AND
                                      crapage.cdagenci = crapass.cdagenci
                                      NO-LOCK: END.

                            IF  AVAIL crapage  THEN
                                ASSIGN aux_nmresage = crapage.nmresage.
                            ELSE
                                ASSIGN aux_nmresage = "".

                            RUN cria_devedor( INPUT aux_nmprimtl,
                                              INPUT crapass.cdagenci,
                                              INPUT aux_nmresage,
                                              INPUT par_nrregist,
                                              INPUT par_nriniseq,
                                       INPUT-OUTPUT par_qtregist,
                                       INPUT-OUTPUT TABLE tt-devedor,
                                             BUFFER crapspc) NO-ERROR.

                            IF  ERROR-STATUS:ERROR THEN
                        		DO:
                        		   ASSIGN aux_dscritic = aux_dscritic + 
                                                        {&GET-MSG}.
                        		   LEAVE Busca.
                        		END.

                        END. /* Fim FOR EACH crapspc */

                    END. /* IF  par_nrcpfcgc <> 0 */
                ELSE
                IF  par_nrdconta <> 0  THEN
                    DO:
                        IF  NOT CAN-FIND(
                            FIRST crapspc WHERE
                                  crapspc.nrdconta = par_nrdconta AND
                                  crapspc.cdcooper = par_cdcooper) THEN
                            DO:
                                ASSIGN aux_cdcritic = 577
                                       par_nmdcampo = "nrdconta".  
                                LEAVE Busca.
                            END.

                        FOR EACH crapspc FIELD({&CAMPOS})
                           WHERE crapspc.nrdconta = par_nrdconta AND
                                 crapspc.cdcooper = par_cdcooper NO-LOCK,
                           FIRST crapass FIELDS(nmprimtl cdcooper cdagenci)
                           WHERE crapass.cdcooper = crapspc.cdcooper AND
                                 crapass.nrdconta = crapspc.nrdconta
                                 NO-LOCK:

                            FOR FIRST crapage FIELDS(nmresage)
                                WHERE crapage.cdcooper = crapass.cdcooper AND
                                      crapage.cdagenci = crapass.cdagenci
                                      NO-LOCK: END.

                            IF  AVAIL crapage  THEN
                                ASSIGN aux_nmresage = crapage.nmresage.
                            ELSE
                                ASSIGN aux_nmresage = "".

                            RUN cria_devedor( INPUT crapass.nmprimtl,
                                              INPUT crapass.cdagenci,
                                              INPUT aux_nmresage,
                                              INPUT par_nrregist,
                                              INPUT par_nriniseq,
                                       INPUT-OUTPUT par_qtregist,
                                       INPUT-OUTPUT TABLE tt-devedor,
                                             BUFFER crapspc) NO-ERROR.

                            IF  ERROR-STATUS:ERROR THEN
                        		DO:
                        		   ASSIGN aux_dscritic = aux_dscritic + 
                                                        {&GET-MSG}.
                        		   LEAVE Busca.
                        		END.

                        END. /* Fim FOR EACH crapspc */

                    END. /* IF  par_nrdconta <> 0 */
                ELSE 
                    /* par_nrdconta = 0 AND par_nrcpfcgc = 0 */
                    DO:
                        FOR EACH crapspc FIELD({&CAMPOS})
                           WHERE crapspc.cdcooper = par_cdcooper NO-LOCK,
                           FIRST crapass FIELDS(nmprimtl cdcooper cdagenci)
                           WHERE crapass.cdcooper = crapspc.cdcooper AND
                                 crapass.nrdconta = crapspc.nrdconta
                                 NO-LOCK:

                            FOR FIRST crapage FIELDS(nmresage)
                                WHERE crapage.cdcooper = crapass.cdcooper AND
                                      crapage.cdagenci = crapass.cdagenci
                                      NO-LOCK: END.

                            IF  AVAIL crapage  THEN
                                ASSIGN aux_nmresage = crapage.nmresage.
                            ELSE
                                ASSIGN aux_nmresage = "".

                            RUN cria_devedor( INPUT crapass.nmprimtl,
                                              INPUT crapass.cdagenci,
                                              INPUT aux_nmresage,
                                              INPUT par_nrregist,
                                              INPUT par_nriniseq,
                                       INPUT-OUTPUT par_qtregist,
                                       INPUT-OUTPUT TABLE tt-devedor,
                                             BUFFER crapspc) NO-ERROR.

                            IF  ERROR-STATUS:ERROR THEN
                        		DO:
                        		   ASSIGN aux_dscritic = aux_dscritic + 
                                                        {&GET-MSG}.
                        		   LEAVE Busca.
                        		END.

                        END. /* Fim FOR EACH crapspc */
                    END.
                    
            END. /* par_cddopcao = C */

            WHEN "A" OR WHEN "B" THEN DO:

                FOR FIRST crapspc WHERE 
                          ROWID(crapspc) = par_nrdrowid NO-LOCK: END.

                IF  NOT AVAIL crapspc THEN
                    DO:
                        ASSIGN aux_cdcritic = 870.
                        LEAVE Busca.
                    END.

                FOR FIRST crapope FIELDS(nmoperad)
                    WHERE crapope.cdoperad = crapspc.opebaixa  AND
                          crapope.cdcooper = par_cdcooper NO-LOCK: END.

                IF  AVAIL crapope THEN
                    ASSIGN aux_opebaixa = crapspc.opebaixa + "-" + 
                                          crapope.nmoperad.

                FOR FIRST crapope FIELDS(nmoperad)
                    WHERE crapope.cdoperad = crapspc.cdoperad  AND
                          crapope.cdcooper = par_cdcooper NO-LOCK: END.

                IF  AVAIL crapope THEN
                    ASSIGN aux_operador = crapspc.cdoperad + "-" + 
                                          crapope.nmoperad.

                CREATE tt-devedor.
                ASSIGN tt-devedor.nrctrspc = crapspc.nrctrspc
                       tt-devedor.dtvencto = crapspc.dtvencto
                       tt-devedor.vldivida = crapspc.vldivida
                       tt-devedor.dtinclus = crapspc.dtinclus
                       tt-devedor.tpinsttu = crapspc.tpinsttu
                       tt-devedor.dtdbaixa = crapspc.dtdbaixa
                       tt-devedor.dsoberv1 = crapspc.dsoberva
                       tt-devedor.dsoberv2 = crapspc.dsobsbxa
                       tt-devedor.operador = aux_operador
                       tt-devedor.opebaixa = aux_opebaixa
                       tt-devedor.dsinsttu = aux_dsinsttu[crapspc.tpinsttu]
                       tt-devedor.nrdrowid = ROWID(crapspc).

            END. /* par_cddopcao = A */

        END CASE.

        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR 
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
            
            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------ */
/*              EFETUA A BUSCA A CONTA DO DEVEDOR OU FIADOR                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Conta:

    DEF  INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                       NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-conta.

    FOR EACH crapass FIELDS(nrdconta nmprimtl)
       WHERE crapass.cdcooper = par_cdcooper AND
             crapass.nrcpfcgc = par_nrcpfcgc NO-LOCK:
        CREATE tt-conta.
        BUFFER-COPY crapass TO tt-conta.
    END.

    RETURN "OK".

END PROCEDURE. /* busca_conta */

/* ------------------------------------------------------------------------ */
/*                  EFETUA A BUSCA DOS DADOS DO DEVEDOR                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Devedor:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-devedor.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapass FIELDS(cdcooper cdagenci nmprimtl)
            WHERE crapass.nrdconta = par_nrdconta AND
                  crapass.nrcpfcgc = par_nrcpfcgc AND
                  crapass.cdcooper = par_cdcooper NO-LOCK: END.

        IF  AVAIL crapass THEN
            DO:
                FOR FIRST crapage FIELDS(nmresage)
                    WHERE crapage.cdcooper = crapass.cdcooper AND
                          crapage.cdagenci = crapass.cdagenci NO-LOCK: END.

                CREATE tt-devedor.
                ASSIGN tt-devedor.nmprimtl = crapass.nmprimtl
                       tt-devedor.cdagenci = crapass.cdagenci
                       tt-devedor.nmresage = crapage.nmresage.
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 867.
                LEAVE Busca.
            END.

        IF  par_cddopcao <> "I" THEN
            IF NOT CAN-FIND(FIRST crapspc WHERE
                                  crapspc.nrcpfcgc = par_nrcpfcgc AND
                                  crapspc.tpidenti = par_tpidenti AND
                                  crapspc.nrdconta = par_nrdconta AND
                                  crapspc.cdcooper = par_cdcooper) THEN
                DO:
                    ASSIGN aux_cdcritic = 870.
                    LEAVE Busca.
                END.

        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK"
                   par_nmdcampo = "nrdconta".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* busca_devedor */

/* ------------------------------------------------------------------------ */
/*                  EFETUA A BUSCA DOS DADOS DO FIADOR                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Fiador:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_flgassoc AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-devedor.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_flgassoc = FALSE.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapass FIELDS(cdcooper cdagenci nmprimtl)
            WHERE crapass.nrdconta = par_nrdconta AND
                  crapass.cdcooper = par_cdcooper NO-LOCK: END.

        IF  AVAIL crapass THEN
            DO:
                FOR FIRST crapage FIELDS(nmresage)
                    WHERE crapage.cdcooper = crapass.cdcooper AND
                          crapage.cdagenci = crapass.cdagenci NO-LOCK: END.

                CREATE tt-devedor.
                ASSIGN tt-devedor.nmprimtl = crapass.nmprimtl
                       tt-devedor.cdagenci = crapass.cdagenci
                       tt-devedor.nmresage = crapage.nmresage.
            END.

        IF  par_cddopcao <> "I" THEN
            IF NOT CAN-FIND(FIRST crapspc WHERE
                                  crapspc.nrcpfcgc = par_nrcpfcgc AND
                                  crapspc.tpidenti = par_tpidenti AND
                                  crapspc.nrdconta = par_nrdconta AND
                                  crapspc.cdcooper = par_cdcooper) THEN
                DO:
                    ASSIGN aux_cdcritic = 870.
                    LEAVE Busca.
                END.

        IF  CAN-FIND(FIRST crapass WHERE
                           crapass.cdcooper = par_cdcooper AND
                           crapass.nrcpfcgc = par_nrcpfcgc) THEN
            ASSIGN aux_flgassoc = TRUE.
        ELSE
            DO:
                FOR FIRST crapavt FIELDS(nmdavali)
                    WHERE crapavt.nrcpfcgc = par_nrcpfcgc AND
                          crapavt.nrdconta = par_nrdconta AND
                          crapavt.cdcooper = par_cdcooper NO-LOCK: END.

                IF AVAIL crapavt THEN
                    DO:
                        IF  NOT AVAIL tt-devedor THEN
                            CREATE tt-devedor.

                        ASSIGN tt-devedor.nmpriavl = crapavt.nmdavali.
                    END.
                ELSE
                    DO:
                        IF  par_cddopcao = "I" THEN
                            DO:
                                ASSIGN aux_cdcritic = 869.
                                LEAVE Busca. 
                            END.
                    END.
            END.

        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK"
                   par_nmdcampo = "nrdconta".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END. /* busca_fiador */

/* ------------------------------------------------------------------------ */
/*                    EFETUA A VALIDACAO OS DADOS DO FIADOR                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Fiador:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaavl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-devedor.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrctaavl AS INTE INIT 0                             NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.

        IF  CAN-DO("I,A",par_cddopcao) THEN
            DO: 
                FOR FIRST crapass FIELDS(nrdconta)
                    WHERE crapass.nrcpfcgc = par_nrcpfcgc AND
                          crapass.cdcooper = par_cdcooper NO-LOCK: END.

                IF  AVAIL crapass THEN
                    ASSIGN aux_nrctaavl = crapass.nrdconta.

                IF  par_nrctaavl = 0 AND
                    aux_nrctaavl <> 0 THEN
                    DO:
                        ASSIGN aux_cdcritic = 874.
                        LEAVE Busca.
                    END.
    
                FOR FIRST crapass FIELDS(nrdconta nmprimtl)
                    WHERE crapass.nrdconta = par_nrctaavl AND
                          crapass.nrcpfcgc = par_nrcpfcgc AND
                          crapass.cdcooper = par_cdcooper NO-LOCK: END.
        
                IF  AVAIL crapass THEN
                    DO:
                        CREATE tt-devedor.
                        ASSIGN tt-devedor.nrctaavl = crapass.nrdconta
                               tt-devedor.nmpriavl = crapass.nmprimtl.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 867.
                        LEAVE Busca.
                    END.
            END.
        ELSE
        IF  CAN-DO("B",par_cddopcao) THEN
            DO: 
                FOR FIRST crapass FIELDS(nrdconta nmprimtl)
                    WHERE crapass.nrcpfcgc = par_nrcpfcgc AND
                          crapass.cdcooper = par_cdcooper NO-LOCK: END.

                IF  AVAIL crapass  THEN
                    DO:
                        CREATE tt-devedor.
                        ASSIGN tt-devedor.nrctaavl = crapass.nrdconta
                               tt-devedor.nmpriavl = crapass.nmprimtl.
                    END.
            END.

        IF  par_cddopcao <> "I" THEN
            IF NOT CAN-FIND(FIRST crapspc WHERE
                                  crapspc.nrcpfcgc = par_nrcpfcgc AND
                                  crapspc.tpidenti = par_tpidenti AND
                                  crapspc.nrdconta = par_nrdconta AND
                                  crapspc.cdcooper = par_cdcooper) THEN
                DO:
                    ASSIGN aux_cdcritic = 870.
                    LEAVE Busca.
                END.

        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
                   par_nmdcampo = "nrctaavl". 

            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* verifica_fiador */

/* ------------------------------------------------------------------------ */
/*                   EFETUA A BUSCA DOS DADOS DO CONTRATO                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Contratos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrdev AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaavl AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-contrato.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabspc FOR crapspc.

    &SCOPED-DEFINE CAMPOS-SPC nrctrspc vldivida dtinclus dtdbaixa

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-contrato.
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT CAN-DO("1,3,4",STRING(par_tpidenti))  THEN
            DO:
                ASSIGN aux_dscritic = "Identificacao invalida.".
                LEAVE Busca.
            END.
            
        IF  NOT CAN-DO("1,2,3",STRING(par_tpctrdev))  THEN
            DO:
                ASSIGN aux_dscritic = "Tipo de contrato invalido.".
                LEAVE Busca.
            END.

        IF  par_tpctrdev = 1 AND
            par_tpidenti = 1 THEN
            ASSIGN par_nrctremp = par_nrdconta.

        /* Verifica tipo  de Contrato */
        IF  par_tpctrdev = 3 THEN
            DO:
                FOR FIRST crapepr FIELDS(nrctaav1 nrctaav2 qtprecal
                                         inprejuz qtmesdec)
                    WHERE crapepr.nrdconta = par_nrdconta AND
                          crapepr.nrctremp = par_nrctremp AND
                          crapepr.cdcooper = par_cdcooper NO-LOCK: END.

                IF  NOT AVAIL crapepr THEN
                    DO:
                        ASSIGN aux_cdcritic = 484.
                        LEAVE Busca.
                    END.

                IF  par_cddopcao = "I" THEN
                    IF  crapepr.inprejuz = 0 AND
                        crapepr.qtmesdec <= crapepr.qtprecal THEN
                        DO:
                            ASSIGN aux_cdcritic = 866.
                            LEAVE Busca.
                        END.    
                
                IF  par_cddopcao = "B" OR 
                    par_cddopcao = "I" THEN
                    DO:
                        /* validacao somente para fiadores */
                        IF  par_tpidenti <> 1  THEN DO:

                            /* conta de avalista nao esta no ctrato informado */
                            IF  (NOT CAN-FIND(FIRST crapavl WHERE
                                 crapavl.cdcooper = par_cdcooper  AND
                                 crapavl.nrdconta = par_nrctaavl  AND
                                 crapavl.nrctravd = par_nrctremp  AND
                                 crapavl.tpctrato = 1 NO-LOCK))   AND
                                (crapepr.nrctaav1 <> par_nrctaavl AND
                                 crapepr.nrctaav2 <> par_nrctaavl) THEN
                                DO:
                                    ASSIGN aux_dscritic = "Conta de fiador" +
                                                          " nao encontrada " +
                                                          "para contrato: " + 
                                                          STRING(par_nrctremp,
                                                                 "zz,zzz,zz9") 
                                                          + ".".
                                    LEAVE Busca.    

                                END. /* IF  (NOT CAN-FIND */

                        END. /* IF  par_tpidenti <> 1 */

                    END. /*IF  par_cddopcao = "B"*/

            END. /* IF  par_tpctrdev = 3 */
        ELSE
        IF  par_tpctrdev = 2 THEN
            DO:
                IF  NOT CAN-FIND(FIRST craplim WHERE
                                       craplim.nrdconta = par_nrdconta AND
                                       craplim.nrctrlim = par_nrctremp AND
                                       craplim.tpctrlim = par_tpctrdev AND
                                       craplim.cdcooper = par_cdcooper) THEN
                    DO:
                        ASSIGN aux_cdcritic = 484.
                        LEAVE Busca.
                    END.

                IF  par_cddopcao = "B" THEN
                    DO:
                        /* validacao somente para fiadores */
                        IF  par_tpidenti <> 1  THEN DO:

                            /* conta de avalista nao esta no ctrato informado */
                            IF  (NOT CAN-FIND(FIRST crapavl WHERE
                                 crapavl.cdcooper = par_cdcooper  AND
                                 crapavl.nrdconta = par_nrctaavl  AND
                                 crapavl.nrctravd = par_nrctremp  AND
                                 crapavl.tpctrato = 2 NO-LOCK))   AND
                                (craplim.nrctaav1 <> par_nrctaavl AND
                                 craplim.nrctaav2 <> par_nrctaavl) THEN
                                DO:
                                    ASSIGN aux_dscritic = "Conta de fiador" +
                                                          " nao encontrada " +
                                                          "para contrato: " + 
                                                          STRING(par_nrctremp,
                                                                 "zz,zzz,zz9") 
                                                          + ".".
                                    LEAVE Busca.    

                                END. /* IF  (NOT CAN-FIND */

                        END. /* IF  par_tpidenti <> 1 */

                    END. /*IF  par_cddopcao = "B"*/

            END. /* IF  par_tpctrdev = 2 */
        ELSE
        IF  par_tpctrdev = 1 THEN
            DO:
                IF  par_cddopcao = "I" THEN
                    DO:
                        IF  par_tpidenti <> 1 THEN
                            DO:
                                ASSIGN aux_cdcritic = 871.
                                LEAVE Busca.
                            END.
                        IF  par_nrdconta <> par_nrctremp THEN
                            DO:
                                ASSIGN aux_cdcritic = 484.
                                LEAVE Busca.
                            END.
                    END.
                    
            END.

        IF  par_cddopcao = "I" THEN
            DO:
                FOR LAST crapcdv FIELD(dtardeve)
                   WHERE crapcdv.nrdconta = par_nrdconta AND
                         crapcdv.nrctremp = par_nrctremp AND
                         crapcdv.cdorigem = par_tpctrdev AND
                         crapcdv.cdcooper = par_cdcooper NO-LOCK: END.

                IF  par_tpctrdev = 3 AND
                    crapepr.inprejuz = 1 THEN
                    .
                ELSE
                    DO:
                        IF  NOT AVAIL crapcdv THEN
                            DO:
                                ASSIGN aux_cdcritic = 864.
                                LEAVE Busca.
                            END.
                        ELSE  
                        IF  crapcdv.dtardeve = ?  THEN
                            DO:
                                ASSIGN aux_cdcritic = 864.
                                LEAVE Busca.
                            END.
                    END.

                LEAVE Busca.
            END.
            
        FOR EACH crabspc FIELDS({&CAMPOS-SPC})
           WHERE crabspc.nrcpfcgc = par_nrcpfcgc AND  
                 crabspc.tpidenti = par_tpidenti AND
                 crabspc.nrdconta = par_nrdconta AND
                 crabspc.nrctremp = par_nrctremp AND
                 crabspc.cdorigem = par_tpctrdev AND
                 crabspc.cdcooper = par_cdcooper NO-LOCK:

            CREATE tt-contrato.
            BUFFER-COPY crabspc USING {&CAMPOS-SPC} TO tt-contrato
                ASSIGN tt-contrato.nrdrowid = ROWID(crabspc).

        END.

        IF  NOT TEMP-TABLE tt-contrato:HAS-RECORDS THEN
            DO:
                ASSIGN aux_cdcritic = 484.
                LEAVE Busca.
            END.
       
        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  par_tpidenti = 1 AND par_tpctrdev = 1 THEN
                ASSIGN par_nmdcampo = "tpctrdev".
            ELSE
                ASSIGN par_nmdcampo = "nrctremp".

            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Contratos */

/* ------------------------------------------------------------------------ */
/*                 EFETUA A VALIDACAO DOS DADOS DO CONTRATO                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinclus AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vldivida AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpinsttu AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdbaixa AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_dsinsttu AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_operador AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.
        

            IF  par_cddopcao <> "I" THEN
                DO:
                    FOR FIRST crapspc WHERE
                              crapspc.nrcpfcgc = par_nrcpfcgc AND
                              crapspc.tpidenti = par_tpidenti AND
                              crapspc.nrdconta = par_nrdconta AND
                              crapspc.cdcooper = par_cdcooper NO-LOCK: END.
                            
                    IF  NOT AVAIL crapspc THEN
                        DO:
                            ASSIGN aux_cdcritic = 870.
                            LEAVE Valida.
                        END.
                END.
                
        CASE par_cddopcao:

            WHEN "A" OR WHEN "I" THEN DO:
                
                RUN valida_alteracao_inclusao
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_idorigem,
                      INPUT par_cdoperad,
                      INPUT par_cddopcao,
                      INPUT par_nrdconta,
                      INPUT par_nrcpfcgc,
                      INPUT par_tpidenti,
                      INPUT par_dtvencto,
                      INPUT par_dtinclus,
                      INPUT par_vldivida,
                      INPUT par_tpinsttu,
                     OUTPUT par_nmdcampo,
                     OUTPUT aux_dsinsttu,
                     OUTPUT aux_operador,
                     OUTPUT TABLE tt-erro) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN aux_dscritic = aux_dscritic + 
                                            {&GET-MSG}.
                       LEAVE Valida.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Valida.

            END. /* par_cddopcao = "A" */

            WHEN "B" THEN DO:

                IF  par_dtdbaixa <> crapspc.dtdbaixa  THEN  
                    DO:
                        FOR FIRST crapope FIELDS(nmoperad cdoperad)
                            WHERE crapope.cdoperad = par_cdoperad AND
                                  crapope.cdcooper = par_cdcooper NO-LOCK: END.
        
                        IF  AVAIL crapope THEN
                            ASSIGN aux_operador = crapope.cdoperad + "-" + 
                                                  crapope.nmoperad.
        
                    END.

            END.

        END CASE.
        
        LEAVE Valida.
        
    END. /* Valida */
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
            
            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                           
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Dados */

/* ------------------------------------------------------------------------ */
/*                     EFETUA A VALIDACAO DO CONTRATO                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Contrato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrdev AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaavl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_tpctrdev = 3 THEN
            RUN verifica_emprestimo
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_idorigem,
                  INPUT par_cdoperad,
                  INPUT par_nrdconta,
                  INPUT par_nrctremp,
                  INPUT par_nrcpfcgc,
                  INPUT par_tpidenti,
                  INPUT par_nrctaavl,
                 OUTPUT par_nmdcampo,
                 OUTPUT TABLE tt-erro) NO-ERROR.
        ELSE
        IF  par_tpctrdev = 2   THEN
            RUN verifica_limite
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_idorigem,
                  INPUT par_cdoperad,
                  INPUT par_nrdconta,
                  INPUT par_nrctremp,
                  INPUT par_tpctrdev,
                  INPUT par_tpidenti,
                  INPUT par_nrctaavl,
                 OUTPUT par_nmdcampo,
                 OUTPUT TABLE tt-erro) NO-ERROR.
        
        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = aux_dscritic + 
                                    {&GET-MSG}.
               LEAVE Valida.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Valida.
            
        
        LEAVE Valida.
        
    END. /* Valida */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Contrato */

/* ------------------------------------------------------------------------ */
/*                      EFETUA A GRAVACAO DOS DADO                          */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrdev AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinclus AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrspc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vldivida AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpinsttu AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsoberv1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtdbaixa AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsoberv2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaavl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrctaass AS INTE                                    NO-UNDO.
    DEF VAR par_idseqttl AS INTE INIT 1                             NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava Informacoes do Devedor"
           aux_cdcritic = 0
           aux_returnvl = "NOK".
    
    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.

        /* Verifica alteracoes desta conta na crapalt */
        FOR FIRST crapass WHERE 
                  crapass.nrdconta = par_nrdconta AND
                  crapass.cdcooper = par_cdcooper NO-LOCK: END. 

        CASE par_cddopcao:

            WHEN "A" THEN DO:
                
        /*         { includes/agn_altera.i} */

                RUN seleciona_crapspc(INPUT par_nrdrowid) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN aux_dscritic = aux_dscritic + 
                                            {&GET-MSG}.
                       UNDO Grava, LEAVE Grava.
                    END.
                
                IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                    UNDO Grava, LEAVE Grava.

                { sistema/generico/includes/b1wgenalog.i &TELA-CONTAS=NAO 
                                                        &TELA-MATRIC=SIM }

                IF  par_dtinclus <> crapspc.dtinclus THEN
                    ASSIGN crapspc.cdoperad = par_cdoperad.

                ASSIGN crapspc.nrctrspc = par_nrctrspc
                       crapspc.dtvencto = par_dtvencto
                       crapspc.vldivida = par_vldivida
                       crapspc.dtinclus = par_dtinclus
                       crapspc.tpinsttu = par_tpinsttu
                       crapspc.dsoberva = par_dsoberv1.

                { sistema/generico/includes/b1wgenllog.i &TELA-CONTAS=NAO 
                                                        &TELA-CADSPC=SIM }
                
            END. /* par_cddopcao = "A" */

            WHEN "B" THEN DO:

                RUN seleciona_crapspc(INPUT par_nrdrowid) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN aux_dscritic = aux_dscritic + 
                                            {&GET-MSG}.
                       UNDO Grava, LEAVE Grava.
                    END.
                
                IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                    UNDO Grava, LEAVE Grava.

                { sistema/generico/includes/b1wgenalog.i 
                  &TELA-CONTAS=NAO &TELA-MATRIC=SIM }

                IF  par_dtdbaixa <> crapspc.dtdbaixa THEN
                    ASSIGN crapspc.opebaixa = par_cdoperad.

                ASSIGN crapspc.dtdbaixa = par_dtdbaixa
                       crapspc.dsobsbxa = par_dsoberv2.

                RUN remove_spc_crapass
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,  
                      INPUT par_nrdcaixa,  
                      INPUT par_cdoperad,  
                      INPUT par_idorigem,  
                      INPUT par_nrcpfcgc,  
                      INPUT par_nrdconta,  
                      INPUT par_tpidenti,  
                      INPUT par_nrctaavl,
                      INPUT par_nrdrowid,  
                      INPUT par_dtinclus,  
                     OUTPUT TABLE tt-erro) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN aux_dscritic = aux_dscritic + 
                                            {&GET-MSG}.
                       UNDO Grava, LEAVE Grava.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Grava, LEAVE Grava.

                IF  log_dtdbaixa <> ?   THEN
                    DO:
                        { sistema/generico/includes/b1wgenllog.i
                          &TELA-CONTAS=NAO &TELA-MATRIC=SIM &TELA-CADSPC=SIM }
                    END.
                
            END. /* par_cddopcao = "B" */

            WHEN "I" THEN DO:
                
                IF  par_tpidenti = 1 OR
                    par_tpidenti = 2 THEN
                    ASSIGN aux_nrctaass = par_nrdconta.
                ELSE
                    ASSIGN aux_nrctaass = par_nrctaavl.

                IF aux_nrctaass > 0 THEN
                   DO:
                       RUN seleciona_crapass(INPUT par_cdcooper,
                                             INPUT aux_nrctaass) NO-ERROR.
        
                       IF AVAIL crapass THEN
                          DO:
                              IF  crapass.dtdsdspc = ? THEN
                                  ASSIGN crapass.dtdsdspc = par_dtinclus
                                         crapass.inadimpl = 1.
                          END.
                   END.

                IF  CAN-FIND(FIRST crapspc WHERE
                                   crapspc.cdcooper = par_cdcooper AND
                                   crapspc.nrdconta = par_nrdconta AND
                                   crapspc.nrcpfcgc = par_nrcpfcgc AND
                                   crapspc.nrctremp = par_nrctremp AND
                                   crapspc.dtinclus = par_dtinclus NO-LOCK)
                    THEN
                    DO:
                        ASSIGN aux_dscritic = "Ja existe resgistro de " +
                                              "inclusao para este contrato " +
                                              "nesta data.".
                        UNDO Grava, LEAVE Grava.
                    END.

                CREATE crapspc.
                ASSIGN crapspc.cdcooper = par_cdcooper
                       crapspc.nrcpfcgc = par_nrcpfcgc
                       crapspc.cdorigem = par_tpctrdev
                       crapspc.nrctremp = par_nrctremp
                       crapspc.tpidenti = par_tpidenti
                       crapspc.nrctrspc = par_nrctrspc
                       crapspc.dtvencto = par_dtvencto
                       crapspc.vldivida = par_vldivida
                       crapspc.dtinclus = par_dtinclus
                       crapspc.tpinsttu = par_tpinsttu
                       crapspc.dtdbaixa = ?
                       crapspc.dtmvtolt = par_dtmvtolt
                       crapspc.hrtransa = TIME
                       crapspc.cdoperad = par_cdoperad
                       crapspc.opebaixa = ""
                       crapspc.dsoberva = par_dsoberv1
                       crapspc.dsobsbxa = ""
                       crapspc.nrdconta = par_nrdconta.
                VALIDATE crapspc.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN aux_dscritic = aux_dscritic + 
                                            {&GET-MSG}.
                       UNDO Grava, LEAVE Grava.
                    END.

            END. /* par_cddopcao = "I" */

        END CASE.

        LEAVE Grava.

    END. /* Grava */

    IF  aux_dscritic <> "" OR 
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */

PROCEDURE Gera_Impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    
    
    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.
 

    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabass FOR crapass.

    DEF VAR aux_cdagefim AS INTE                                    NO-UNDO.
    DEF VAR aux_flgexist AS LOGI                                    NO-UNDO.
    DEF VAR aux_dsidenti AS CHAR FORMAT "x(10)"                     NO-UNDO.
    DEF VAR aux_dsinsttu AS CHAR FORMAT "x(10)"                     NO-UNDO.

    DEF VAR tot_qtdcoope AS INTE  FORMAT "zzz,zz9"                  NO-UNDO.
    DEF VAR tot_vlrcoope LIKE crapspc.vldivida                      NO-UNDO.
    DEF VAR tot_qtdterce AS INTE  FORMAT "zzz,zz9"                  NO-UNDO.
    DEF VAR tot_vlrterce LIKE crapspc.vldivida                      NO-UNDO.
    DEF VAR tot_qtdgeral AS INTE  FORMAT "zzz,zz9"                  NO-UNDO.
    DEF VAR tot_vlrgeral LIKE crapspc.vldivida                      NO-UNDO.

    FORM  crapass.cdagenci LABEL "PA"
          crapspc.nrdconta LABEL "Conta"
          crapass.nmprimtl LABEL "Nome"
          crapspc.nrcpfcgc LABEL "CPF/CGC"
          crapspc.nrctremp LABEL "Contrato" 
          aux_dsidenti     LABEL "Identifi"
          crapspc.nrctrspc LABEL "Contrato SPC"
          SKIP
          crapspc.vldivida LABEL "Valor Divida"   AT 105
          crapspc.dtinclus LABEL "Dt.Inclusao"
          aux_dsinsttu     LABEL "Serasa"
          WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_rel_spc.

    FORM SKIP(2)
         SPACE(99) "QTDE        VALORES" SKIP
         SPACE(85) "COOPERADOS" tot_qtdcoope tot_vlrcoope SKIP
         SPACE(85) " TERCEIROS" tot_qtdterce tot_vlrterce SKIP
         SPACE(85) "     TOTAL" tot_qtdgeral tot_vlrgeral
         WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_totais.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_returnvl = "NOK"
           aux_cdagefim = IF   par_cdagencx = 0 THEN 
                               9999
                          ELSE par_cdagencx
           aux_flgexist = FALSE.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

/*         IF  par_cdagencx = 0  THEN                                    */
/*             DO:                                                       */
/*                 ASSIGN aux_cdcritic = 0                               */
/*                        aux_dscritic = "PAC deve ser maior que zero.". */
/*                 LEAVE Imprime.                                        */
/*             END.                                                      */

        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.
        
        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".txt".

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        /* Cdempres = 11 , Relatorio 408 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "438" "132" }

        FOR EACH crapspc WHERE crapspc.cdcooper = par_cdcooper AND
                               crapspc.dtdbaixa = ? NO-LOCK,
           FIRST crapass WHERE crapass.cdcooper = par_cdcooper     AND
                               crapass.nrdconta = crapspc.nrdconta AND
                               crapass.cdagenci >= par_cdagencx    AND
                               crapass.cdagenci <= aux_cdagefim NO-LOCK
                               BREAK BY crapass.cdagenci
                                       BY crapspc.nrdconta
                                         BY crapspc.nrcpfcgc
                                           BY crapspc.nrctremp
                                             BY crapspc.nrctrspc
                                               BY crapspc.dtmvtolt:

            
            CASE crapspc.tpidenti:
                WHEN 1 THEN ASSIGN aux_dsidenti = "Devedor1".
                WHEN 2 THEN ASSIGN aux_dsidenti = "Devedor2".
                WHEN 3 THEN ASSIGN aux_dsidenti = "Fiador1".
                OTHERWISE   ASSIGN aux_dsidenti = "Fiador2".
            END CASE.
            
            IF  crapspc.tpinsttu = 1 THEN
                ASSIGN aux_dsinsttu = "SPC".
            ELSE
                ASSIGN aux_dsinsttu = "SERASA".

        
            DISPLAY STREAM str_1 
                    crapass.cdagenci crapspc.nrdconta
                    crapass.nmprimtl crapspc.nrcpfcgc
                    crapspc.nrctremp FORMAT "zz,zzz,zz9"
                    aux_dsidenti
                    crapspc.nrctrspc crapspc.vldivida
                    crapspc.dtinclus aux_dsinsttu WITH FRAME f_rel_spc.

            DOWN STREAM str_1 WITH FRAME f_rel_spc.

            IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
                DO:
                    PAGE STREAM str_1.
                    VIEW STREAM str_1 FRAME f_cabrel.
                END.          

            ASSIGN aux_flgexist = TRUE.

            IF  LAST-OF(crapspc.nrctrspc) THEN
                DO:
                    IF CAN-FIND(FIRST crabass WHERE
                               crabass.cdcooper = par_cdcooper AND
                               crabass.nrcpfcgc = crapspc.nrcpfcgc NO-LOCK) THEN
                        ASSIGN tot_qtdcoope = tot_qtdcoope + 1
                               tot_vlrcoope = tot_vlrcoope + crapspc.vldivida.
                    ELSE
                        ASSIGN tot_qtdterce = tot_qtdterce + 1
                               tot_vlrterce = tot_vlrterce + crapspc.vldivida.
                END.
            
        END. /* Fim FOR EACH crapspc */

        IF  aux_flgexist THEN
            DO:
                DISP STREAM str_1
                     tot_qtdcoope tot_vlrcoope
                     tot_qtdterce tot_vlrterce
                    (tot_qtdcoope + tot_qtdterce) @ tot_qtdgeral
                    (tot_vlrcoope + tot_vlrterce) @ tot_vlrgeral
                    WITH FRAME f_totais.

                DOWN WITH FRAME f_totais.    
            END.
        ELSE
            ASSIGN aux_cdcritic = 263.

        OUTPUT STREAM str_1 CLOSE.

        IF  aux_cdcritic <> 0 THEN
            LEAVE Imprime.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO: 
                UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " >> " + 
                                  aux_nmarqpdf + " 2>/dev/null").

                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                      '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                      ':/var/www/ayllos/documentos/' + crabcop.dsdircop +
                      '/temp/" 2>/dev/null').  
    
                 /* Remover arquivos nao mais necessarios */
/*                  UNIX SILENT VALUE ("rm " + par_nmarquiv + "* 2>/dev/null"). */
                 UNIX SILENT VALUE ("rm " + aux_nmarqpdf + "* 2>/dev/null").
                                                         
    
                 /* Nome do PDF para devolver como parametro */
                 aux_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/"). 
                

/*                 IF  NOT VALID-HANDLE(h-b1wgen0024) THEN                    */
/*                     RUN sistema/generico/procedures/b1wgen0024.p           */
/*                         PERSISTENT SET h-b1wgen0024.                       */
/*                                                                            */
/*                 IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN                   */
/*                     DO:                                                    */
/*                         ASSIGN aux_dscritic = "Handle invalido para BO " + */
/*                                               "b1wgen0024.".               */
/*                         LEAVE Imprime.                                     */
/*                     END.                                                   */
/*                                                                            */
/*                 RUN envia-arquivo-web IN h-b1wgen0024                      */
/*                     ( INPUT par_cdcooper,                                  */
/*                       INPUT par_cdagenci,                                  */
/*                       INPUT par_nrdcaixa,                                  */
/*                       INPUT aux_nmarqimp,                                  */
/*                      OUTPUT aux_nmarqpdf,                                  */
/*                      OUTPUT TABLE tt-erro ).                               */
/*                                                                            */
/*                 IF  VALID-HANDLE(h-b1wgen0024)  THEN                       */
/*                     DELETE PROCEDURE h-b1wgen0024.                         */
/*                                                                            */
/*                 IF  RETURN-VALUE <> "OK" THEN                              */
/*                     RETURN "NOK".                                          */
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE 
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Gera_Impressao */

/*............................. PROCEDURES INTERNAS ........................*/

/* ------------------------------------------------------------------------ */
/*          Cria Temp-Table com dados do devedor e trata a paginação        */
/* ------------------------------------------------------------------------ */
PROCEDURE cria_devedor PRIVATE:

    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmresage AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF INPUT-OUTPUT PARAM par_qtregist AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-devedor.

    DEF PARAM BUFFER crabspc FOR crapspc.

    Cria: DO ON ERROR UNDO, LEAVE:
        
        ASSIGN par_qtregist = par_qtregist + 1.

        /* controles da paginação */
        IF  (par_qtregist < par_nriniseq) OR
            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
            LEAVE Cria.
    
        IF  aux_nrregist > 0 THEN
            DO:
    
                CREATE tt-devedor.
                BUFFER-COPY crapspc USING {&CAMPOS} TO tt-devedor
                ASSIGN tt-devedor.dsidenti = aux_dsidenti[tt-devedor.tpidenti]
                       tt-devedor.dsinsttu = aux_dsinsttu[tt-devedor.tpinsttu]
                       tt-devedor.nmprimtl = par_nmprimtl
                       tt-devedor.cdagenci = par_cdagenci
                       tt-devedor.nmresage = par_nmresage.
            END.
    
        ASSIGN aux_nrregist = aux_nrregist - 1.
    
        LEAVE Cria.

    END. /* Cria */

    RETURN "OK".

END PROCEDURE. /* cria_devedor */

PROCEDURE valida_alteracao_inclusao PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinclus AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vldivida AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpinsttu AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_dsinsttu AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_operador AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
                                   
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:

        EMPTY TEMP-TABLE tt-erro.

        IF  par_cddopcao = "A" THEN
            DO:
                FOR FIRST crapspc WHERE
                          crapspc.nrcpfcgc = par_nrcpfcgc AND
                          crapspc.tpidenti = par_tpidenti AND
                          crapspc.nrdconta = par_nrdconta AND
                          crapspc.cdcooper = par_cdcooper NO-LOCK: END.
    
                IF  NOT AVAIL crapspc THEN
                    DO:
                        ASSIGN aux_cdcritic = 870.
                        LEAVE Valida.
                    END.
            END.
        
        IF  par_dtvencto = ? THEN
            DO:
                ASSIGN aux_cdcritic = 375
                       par_nmdcampo = "dtvencto".
                LEAVE Valida.
            END.

        IF  par_vldivida = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 375
                       par_nmdcampo = "vldivida".
                LEAVE Valida.
            END.

        IF  par_dtinclus = ? THEN
            DO:
                ASSIGN aux_cdcritic = 375
                       par_nmdcampo = "dtinclus".
                LEAVE Valida.
            END.

        IF  NOT CAN-DO("1,2",STRING(par_tpinsttu)) THEN
            DO:
                ASSIGN aux_cdcritic = 14
                    par_nmdcampo = "tpinsttu".
                LEAVE Valida.
            END.

        IF  par_tpinsttu = 1 THEN
            ASSIGN aux_dsinsttu = "SPC".
        ELSE
            ASSIGN aux_dsinsttu = "SERASA".
                                   
        IF  par_cddopcao = "A" THEN
            DO:
                IF  par_dtinclus <> crapspc.dtinclus  THEN  
                    DO:
                        FOR FIRST crapope FIELDS(nmoperad cdoperad)
                            WHERE crapope.cdoperad = par_cdoperad AND
                                  crapope.cdcooper = par_cdcooper NO-LOCK: END.
        
                        IF  AVAIL crapope THEN
                            ASSIGN aux_operador = crapope.cdoperad + "-" + 
                                                  crapope.nmoperad.
        
                    END.
            END.

        LEAVE Valida.
        
    END. /* Valida */
                                   
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* valida_alteracao */

PROCEDURE seleciona_crapspc PRIVATE:

    DEF  INPUT PARAM par_nrdrowid AS ROWID                      NO-UNDO.
    
    Contador: DO aux_contador = 1 TO 10:
        
        FIND FIRST crapspc WHERE ROWID(crapspc) = par_nrdrowid
            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapspc THEN
            DO:
                IF  LOCKED(crapspc) THEN
                    DO:
                        IF  aux_contador = 10 THEN
                            DO:
                                ASSIGN aux_cdcritic = 77.
                                LEAVE Contador.
                            END.
                        ELSE 
                            DO:
                               PAUSE 1 NO-MESSAGE.
                               NEXT Contador.
                            END.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 301.
                        LEAVE Contador.
                    END.
            END.
        ELSE
            LEAVE Contador.

    END. /* Contador */

    RETURN.

END PROCEDURE.

PROCEDURE seleciona_crapass PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                      NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                      NO-UNDO.
    
    Contador: DO aux_contador = 1 TO 10:
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta
                           EXCLUSIVE-LOCK NO-ERROR.

        IF  NOT AVAIL crapass THEN
            DO:
                IF  LOCKED(crapass) THEN
                    DO:
                        IF  aux_contador = 10 THEN
                            DO:
                                ASSIGN aux_dscritic = "Registro de associado " +
                                                      "esta em uso em outro " +
                                                      "terminal. Tente " +
                                                      "Novamente.".
                                LEAVE Contador.
                            END.
                        ELSE 
                            DO:
                               PAUSE 1 NO-MESSAGE.
                               NEXT Contador.
                            END.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_dscritic = "Registro de associado " +
                                              "nao existe.".
                        LEAVE Contador.
                    END.
            END.
        ELSE
            LEAVE Contador.

    END. /* Contador */

    RETURN.

END PROCEDURE.

PROCEDURE remove_spc_crapass PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaavl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dtinclus AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabspc FOR crapspc.

    DEF VAR aux_nrctaass AS INTE                                    NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_nrctaass = 0.

    Grava: DO TRANSACTION 
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.

        /* Caso o Fiador nao seja correntista, limpar apenas crapass do devedor */
        IF  par_tpidenti = 1 OR
            par_tpidenti = 2 OR
            par_nrctaavl = 0 THEN DO:

            /* Verifica se existe algum outro contrato do cooperado no SPC */
            FOR FIRST crabspc WHERE
                      crabspc.cdcooper = par_cdcooper AND
                      crabspc.nrcpfcgc = par_nrcpfcgc AND
                      crabspc.dtdbaixa = ?            AND
                      ROWID(crabspc)  <> par_nrdrowid NO-LOCK: END.
                      
            IF  AVAIL crabspc THEN
                LEAVE Grava.

            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta
                               EXCLUSIVE-LOCK NO-ERROR.

            IF  AVAILABLE crapass  THEN
                DO:
                    /* remove do SPC na crapass */
                    IF  crapspc.dtdbaixa <> ?   THEN
                        ASSIGN crapass.dtdsdspc = ?
                               crapass.inadimpl = 0.
                    ELSE
                        /* Desfaz baixa na crapass */
                        ASSIGN crapass.dtdsdspc = par_dtinclus
                               crapass.inadimpl = 1.

                    FIND CURRENT crapass NO-LOCK.
                END.
        END.
        /* Quando o Fiador é correntistas */
        ELSE DO:

            DO aux_contador = 1 TO 2:

                /* Devedor */
                IF  aux_contador = 1  THEN
                    DO:
                        FOR FIRST crabspc WHERE 
                                  crabspc.cdcooper = par_cdcooper AND
                                  crabspc.nrdconta = par_nrdconta AND
                                  crabspc.dtdbaixa = ?            AND
                                  ROWID(crabspc)  <> par_nrdrowid NO-LOCK: END.

                        IF  AVAIL crabspc THEN
                            NEXT.

                        ASSIGN aux_nrctaass = par_nrdconta.
                    END. /* Fim IF  aux_contador = 1 */

                ELSE /* Fiador */
                    DO:
                        FOR FIRST crabspc WHERE 
                                  crabspc.cdcooper = par_cdcooper AND
                                  crabspc.nrcpfcgc = par_nrcpfcgc AND
                                  crabspc.dtdbaixa = ?            AND
                                  ROWID(crabspc)  <> par_nrdrowid NO-LOCK: END.

                        IF  AVAIL crabspc THEN
                            LEAVE.

                        ASSIGN aux_nrctaass = par_nrctaavl.
                    END.

                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = aux_nrctaass
                                   EXCLUSIVE-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    DO:
                        /* remove do SPC na crapass */
                        IF  crapspc.dtdbaixa <> ? THEN
                            ASSIGN crapass.dtdsdspc = ?
                                   crapass.inadimpl = 0.

                        /* Desfaz baixa na crapass */
                        ELSE
                            ASSIGN crapass.dtdsdspc = par_dtinclus
                                   crapass.inadimpl = 1.

                        FIND CURRENT crapass NO-LOCK.
                    END.

            END. /* Fim DO aux_contador = 1 TO 2: */

        END. /* Fim ELSE */

        LEAVE Grava.

    END. /* Grava */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
            ELSE
                DO:
                    FIND FIRST tt-erro NO-ERROR.

                    IF  AVAIL tt-erro THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                END.
            

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

 END.

PROCEDURE verifica_emprestimo PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaavl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapepr WHERE
                  crapepr.nrdconta = par_nrdconta  AND
                  crapepr.nrctremp = par_nrctremp  AND
                  crapepr.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAIL crapepr THEN
            DO:
                ASSIGN aux_cdcritic = 484.
                LEAVE Valida.
            END.

        IF  crapepr.inprejuz = 0 AND
            crapepr.qtmesdec <= crapepr.qtprecal THEN
            DO:
                ASSIGN aux_cdcritic = 866.
                LEAVE Valida.
            END.

        FOR FIRST crawepr WHERE
                  crawepr.nrdconta = par_nrdconta AND
                  crawepr.nrctremp = par_nrctremp AND
                  crawepr.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAIL crawepr THEN
            DO:
                ASSIGN aux_cdcritic = 484.
                LEAVE Valida.
            END.

        FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                 crapass.nrcpfcgc = par_nrcpfcgc
                                 NO-LOCK NO-ERROR.

        FOR FIRST crapavt WHERE
                  crapavt.nrcpfcgc = par_nrcpfcgc AND
                  crapavt.nrdconta = par_nrdconta AND
                  crapavt.nrctremp = par_nrctremp AND
                  crapavt.cdcooper = par_cdcooper NO-LOCK: 
        END.

        /* Verifica se realmente e o tipo de avalista informado */
        IF  par_tpidenti = 3 THEN
            DO:
                IF  NOT(AVAIL crapass AND 
                       (par_nrctaavl = crapepr.nrctaav1  OR
                        crawepr.nmdaval1 = crapass.nmprimtl)) THEN
                    DO:
                        IF  NOT(AVAIL crapavt   AND
                            crapepr.nrctaav1 = 0 AND
                            crawepr.nmdaval1 = crapavt.nmdavali) THEN
                            DO:
                                ASSIGN aux_cdcritic = 867
                                       par_nmdcampo = "tpidenti".
                                LEAVE Valida.
                            END.
                    END.
            END. /* Fim IF  par_tpidenti = 3 */
        ELSE
        IF  par_tpidenti = 4 THEN
            DO:
                IF  NOT(AVAILABLE crapass AND 
                       (par_nrctaavl = crapepr.nrctaav2 OR
                        crawepr.nmdaval2 = crapass.nmprimtl)) THEN
                    DO:
                        IF  NOT(AVAILABLE crapavt     AND
                                crapepr.nrctaav2 = 0  AND
                                crawepr.nmdaval2 = crapavt.nmdavali)  THEN
                            DO:
                                ASSIGN aux_cdcritic = 867
                                       par_nmdcampo = "tpidenti". 
                                LEAVE Valida.
                            END.    
                    END.
            END. /* Fim IF  par_tpidenti = 4 */

        LEAVE Valida.
        
    END. /* Valida */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* verifica_emprestimo */

PROCEDURE verifica_limite PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrdev AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpidenti AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaavl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        FOR craplim WHERE
            craplim.nrdconta = par_nrdconta AND
            craplim.nrctrlim = par_nrctremp AND
            craplim.tpctrlim = par_tpctrdev AND
            craplim.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAIL craplim THEN
            DO:
                ASSIGN aux_cdcritic = 484.
                LEAVE Valida.
            END.

        /* Verifica se realmente e o tipo de avalista informado */
        IF  par_tpidenti = 3 THEN
            DO:
                IF  NOT(AVAILABLE crapass AND 
                       (par_nrctaavl = craplim.nrctaav1 OR
                        craplim.nmdaval1 = crapass.nmprimtl)) THEN
                    DO:
                        IF  NOT(AVAILABLE crapavt     AND
                                craplim.nrctaav1 = 0  AND
                                craplim.nmdaval1 =
                                crapavt.nmdavali) THEN
                            DO:
                                ASSIGN aux_cdcritic = 867
                                       par_nmdcampo = "tpidenti".
                                LEAVE Valida.
                            END.   
                    END.
            END. /* Fim IF  par_tpidenti = 3 */
        ELSE
        IF  par_tpidenti = 4 THEN
            DO:
                IF  NOT(AVAILABLE crapass AND 
                        (par_nrctaavl = craplim.nrctaav2  OR
                         craplim.nmdaval2 = crapass.nmprimtl)) THEN
                    DO:
                        IF  NOT(AVAILABLE crapavt     AND
                                craplim.nrctaav2 = 0  AND
                                craplim.nmdaval2 = crapavt.nmdavali) THEN
                            DO:
                                ASSIGN aux_cdcritic = 867
                                       par_nmdcampo = "tpidenti".
                                LEAVE Valida.
                            END.    
                    END.
            END. /* Fim IF  par_tpidenti = 4 */

        LEAVE Valida.
        
    END. /* Valida */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* verifica_limite */

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/
