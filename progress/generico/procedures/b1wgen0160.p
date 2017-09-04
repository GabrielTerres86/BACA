
/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0160.p
    Autor   : Gabriel Capoia (DB1)
    Data    : 16/07/2013                     Ultima atualizacao: 02/08/2016

    Objetivo  : Tranformacao BO tela PESQSR.

    Alteracoes: 01/07/2014 - Adicionado campo tt-pesqsr.cdagetfn na
                             procedure Busca_Opcao_C e na Busca_Opcao_D.
                             (Reinert)
                18/09/2014 - Integracao cooperativas 4 e 15 (Vanessa)

                24/06/2016 - Ajustes referente a homologacao da área de negocio
                             (Adriano - SD 412556).

                07/07/2016 - #442054 Correcao do proc Busca_Opcao_C para
                             pegar os dados do favorecido do cheque (cdbancdep,
                             cdagedep e nrctadep) (Carlos)

                28/11/2016 - Incorporacao Transulcred
                             Correcao do FIND da TCO, estava errado
                             (Guilherme/SUPERO)

				02/08/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							 (Adriano - P339).

............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0160tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR h-b1wgen9998 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.

DEF BUFFER crablcm FOR craplcm.

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                       EFETUA A PESQUISA DE REMESSA                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbaninf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtola AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-pesqsr.
    DEF OUTPUT PARAM TABLE FOR tt-dados-cheque.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdctitg AS INTE                                    NO-UNDO.
    DEF VAR aux_nrctaass AS INTE                                    NO-UNDO.
    DEF VAR aux_dsdctitg AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrchqsdv AS INTE                                    NO-UNDO.
    DEF VAR aux_cdagechq AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrfonemp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrramemp AS INTE                                    NO-UNDO.
    DEF VAR aux_cdturnos AS INTE                                    NO-UNDO.
    DEF VAR aux_dsagenci AS CHAR                                    NO-UNDO.
    DEF VAR aux_regexist AS LOGI INIT FALSE                         NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Pesquisa de Remessa".


    Busca:
    DO  ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-pesqsr.
        EMPTY TEMP-TABLE tt-erro.

        /*Verifica se tem algo digitado*/
        IF par_nrdocmto <= 0 THEN
            DO:
                ASSIGN aux_cdcritic = 008
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        FOR FIRST crapcop FIELDS(cdcooper cdagebcb cdagectl cdageitg)
            WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop  THEN
            DO:
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        IF  par_cddopcao = "C" THEN
            RUN Busca_Opcao_C
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_cdoperad,
                  INPUT par_nmdatela,
                  INPUT par_idorigem,
                  INPUT par_cddopcao,
                  INPUT par_nrdocmto,
                  INPUT par_nrdctabb,
                  INPUT par_cdbaninf,
                  INPUT par_flgerlog,
                 OUTPUT TABLE tt-pesqsr,
                 OUTPUT TABLE tt-dados-cheque,
                 OUTPUT TABLE tt-erro).
        ELSE
        IF  par_cddopcao = "D" THEN

            RUN Busca_Opcao_D
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_cddopcao,
                      INPUT par_nrdocmto,
                      INPUT par_nrdctabb,
                      INPUT par_cdbaninf,
                      INPUT par_nrdconta,
                      INPUT par_cdbccxlt,
                      INPUT par_flgerlog,
                      INPUT par_dtmvtola,
                      INPUT par_dtmvtolt,
                     OUTPUT TABLE tt-pesqsr,
                     OUTPUT TABLE tt-dados-cheque,
                     OUTPUT TABLE tt-erro).

        ELSE
            DO:
                ASSIGN aux_cdcritic = 14
                       aux_dscritic = "".
                LEAVE Busca.
            END.


        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.

            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */


/* ------------------------------------------------------------------------ */
/*                    EFETUA A PESQUISA DE REMESSA - OPCAO C                */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Opcao_C:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbaninf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-pesqsr.
    DEF OUTPUT PARAM TABLE FOR tt-dados-cheque.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdctitg AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrctaass AS INTE                                    NO-UNDO.
    DEF VAR aux_dsdctitg AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrchqsdv AS INTE                                    NO-UNDO.
    DEF VAR aux_cdagechq AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrfonemp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrramemp AS INTE                                    NO-UNDO.
    DEF VAR aux_cdturnos AS INTE                                    NO-UNDO.
    DEF VAR aux_dsagenci AS CHAR                                    NO-UNDO.
    DEF VAR aux_regexist AS LOGI INIT FALSE                         NO-UNDO.
    DEF VAR aux_nrseqchq AS INT     INIT 0                          NO-UNDO.
    DEF VAR aux_ctamigra AS LOGICAL INIT FALSE                      NO-UNDO.
	DEF VAR aux_contador AS INT										NO-UNDO.

    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Pesquisa de Remessa".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-pesqsr.
        EMPTY TEMP-TABLE tt-erro.

        /* Validar o numero do documento */
        IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrdocmto ) THEN
            DO:
                ASSIGN aux_cdcritic = 8
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        /* Validar o numero conta base ou cheque */
        IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrdctabb ) THEN
            DO:
                ASSIGN aux_cdcritic = 8
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        IF  NOT VALID-HANDLE(h-b1wgen9998) THEN
            RUN sistema/generico/procedures/b1wgen9998.p
                PERSISTENT SET h-b1wgen9998.

        RUN existe_conta_integracao IN h-b1wgen9998
                                  ( INPUT par_cdcooper,
                                    INPUT par_nrdctabb,
                                   OUTPUT aux_nrdctitg,
                                   OUTPUT aux_nrctaass).

        RUN dig_bbx IN h-b1wgen9998
                  ( INPUT par_cdcooper,
                    INPUT par_cdagenci,
                    INPUT par_nrdcaixa,
                    INPUT par_nrdctabb,
                   OUTPUT aux_dsdctitg,
                   OUTPUT TABLE tt-erro ).

        IF  VALID-HANDLE(h-b1wgen9998)  THEN
            DELETE PROCEDURE h-b1wgen9998.

        IF  RETURN-VALUE <> "OK"  THEN
            LEAVE Busca.

        ASSIGN aux_nrchqsdv = INT(SUBSTR(STRING(par_nrdocmto,"9999999"),1,6)).

        CASE par_cdbaninf:
            WHEN 756 THEN ASSIGN aux_cdagechq = crapcop.cdagebcb.

            WHEN  85 THEN DO:
                ASSIGN aux_cdagechq = crapcop.cdagectl.

                /*VERIFICA SE É CONTA MIGRADA*/
                FIND FIRST craptco
                     WHERE craptco.cdcooper = par_cdcooper
                       AND craptco.nrctaant = par_nrdctabb
					   AND craptco.flgativo = TRUE
                   NO-LOCK NO-ERROR.

                IF  AVAILABLE craptco  THEN DO:
                    IF  craptco.cdcopant = 4   /* CONCREDI    */
                    OR  craptco.cdcopant = 15  /* CREDIMILSUL */
                    OR  craptco.cdcopant = 17  /* TRANSULCRED */ THEN DO:
                        ASSIGN aux_ctamigra = TRUE.

                        /* PESQUISA A AGENCIA DA CONTA MIGRADA*/
                        FIND FIRST crapcop
                             WHERE crapcop.cdcooper = craptco.cdcopant
                           NO-LOCK NO-ERROR.
                    END.
                END.
            END.
            OTHERWISE     ASSIGN aux_cdagechq = crapcop.cdageitg.
        END CASE.

        IF aux_ctamigra  THEN
            DO:
                FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper      AND /*PESQUISA COM AS DUAS AGENCIAS*/
                                   crapfdc.cdbanchq = par_cdbaninf      AND
                                   (crapfdc.cdagechq = aux_cdagechq OR
                                    crapfdc.cdagechq = crapcop.cdagectl) AND
                                    crapfdc.nrctachq = par_nrdctabb      AND
                                    crapfdc.nrcheque = aux_nrchqsdv
                       NO-LOCK NO-ERROR.
        END.
        ELSE
            FOR FIRST crapfdc
                WHERE crapfdc.cdcooper = par_cdcooper AND
                      crapfdc.cdbanchq = par_cdbaninf AND
                      crapfdc.cdagechq = aux_cdagechq AND
                      crapfdc.nrctachq = par_nrdctabb AND
                      crapfdc.nrcheque = aux_nrchqsdv
                      USE-INDEX crapfdc1 NO-LOCK:
        END.

        IF  NOT AVAIL crapfdc THEN
            DO:
                ASSIGN aux_cdcritic = 244
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        ASSIGN aux_nrdconta = crapfdc.nrdconta
               aux_cdagechq = crapfdc.cdagechq .

        FOR FIRST crapass
            WHERE crapass.cdcooper = crapfdc.cdcooper AND
                  crapass.nrdconta = crapfdc.nrdconta NO-LOCK:
        END.

        IF  NOT AVAIL crapass THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".
                LEAVE Busca.
            END.

                ASSIGN aux_nmprimtl = crapass.nmprimtl
                       aux_nrfonemp = "0"
                           aux_nrramemp = 0.

                Telefone:
                DO aux_contador = 1 TO 4:

          FOR FIRST craptfc FIELDS (tptelefo nrtelefo nrdddtfc nrdramal)
              WHERE craptfc.cdcooper = crapfdc.cdcooper
                AND craptfc.nrdconta = crapfdc.nrdconta
                AND craptfc.idseqttl = 1
                AND craptfc.tptelefo = aux_contador NO-LOCK:

              /* 1 - Residencial */
              /* 2 - Celular     */
              /* 3 - Comercial   */
              /* 4 - Contato     */
              CASE craptfc.tptelefo:
                WHEN 1 THEN
                DO:
                    IF craptfc.nrtelefo > 0 THEN
                    DO:
                        ASSIGN aux_nrfonemp = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo)
                               aux_nrramemp = craptfc.nrdramal.

                        LEAVE telefone.
                    END.
                END.

                WHEN 2 THEN
                DO:
                    IF craptfc.nrtelefo > 0 THEN
                    DO:
                        ASSIGN aux_nrfonemp = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo)
                               aux_nrramemp = craptfc.nrdramal.

                        LEAVE telefone.
                    END.
                END.

                WHEN 4 THEN
                DO:
                    IF craptfc.nrtelefo > 0 THEN
                    DO:
                        ASSIGN aux_nrfonemp = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo)
                               aux_nrramemp = craptfc.nrdramal.

                        LEAVE telefone.
                    END.
                END.
            END CASE.

          END.
        END.

        FOR FIRST crapttl
            WHERE crapttl.cdcooper = par_cdcooper     AND
                  crapttl.nrdconta = crapass.nrdconta AND
                  crapttl.idseqttl = 1  NO-LOCK:
        END.

        IF  AVAIL crapttl THEN
            ASSIGN aux_cdturnos = crapttl.cdturnos.
        ELSE
            ASSIGN aux_cdturnos = 0.

        FOR FIRST crapage
            WHERE crapage.cdcooper = par_cdcooper AND
                  crapage.cdagenci = crapass.cdagenci NO-LOCK:
        END.

        IF  NOT AVAIL crapage THEN
            ASSIGN aux_dsagenci =
                     STRING(crapass.cdagenci,"zz9") + " - " + FILL("*",15).
        ELSE
            ASSIGN aux_dsagenci =
                     STRING(crapass.cdagenci,"zz9") + " - " + crapage.nmresage.

        IF  crapfdc.incheque = 8 THEN
            DO:
                ASSIGN aux_cdcritic = 320
                       aux_dscritic = "".
                LEAVE Busca.
            END.
        ELSE
        IF  NOT CAN-DO("0,1,2,5,6,7",STRING(crapfdc.incheque)) THEN
            DO:
                ASSIGN aux_cdcritic = 127
                       aux_dscritic = "".
                LEAVE Busca.
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = IF crapfdc.incheque = 5
                                      THEN 97
                                      ELSE IF crapfdc.incheque = 6
                                           THEN 96
                                           ELSE 257.

                FOR EACH craplcm
                   WHERE craplcm.cdcooper = par_cdcooper     AND
                         craplcm.nrdconta = crapass.nrdconta AND
                         craplcm.nrdocmto = par_nrdocmto     AND
                        (craplcm.cdhistor = 50   OR
                         craplcm.cdhistor = 56   OR
                         craplcm.cdhistor = 59   OR
                         craplcm.cdhistor = 21   OR
                         craplcm.cdhistor = 26   OR
                         craplcm.cdhistor = 313  OR
                         craplcm.cdhistor = 524  OR
                         craplcm.cdhistor = 572  OR
                         craplcm.cdhistor = 340  OR
                         craplcm.cdhistor = 521  OR
                         craplcm.cdhistor = 526  OR
                         craplcm.cdhistor = 621)
                         USE-INDEX craplcm2 NO-LOCK :

                    FIND FIRST crapfdc WHERE
                        crapfdc.cdcooper = par_cdcooper AND
                        crapfdc.nrdconta = crapass.nrdconta AND
                        crapfdc.nrcheque =
                        INTE(SUBSTRING(STRING(craplcm.nrdocmto), 1, (LENGTH(STRING(craplcm.nrdocmto)) - 1)))
                        NO-LOCK NO-WAIT.

                    CREATE tt-pesqsr.
                    ASSIGN tt-pesqsr.dtmvtolt = craplcm.dtmvtolt
                           tt-pesqsr.cdagenci = craplcm.cdagenci
                           tt-pesqsr.cdbccxlt = craplcm.cdbccxlt
                           tt-pesqsr.nrdolote = craplcm.nrdolote
                           tt-pesqsr.vllanmto = craplcm.vllanmto
                           tt-pesqsr.cdpesqbb = craplcm.cdpesqbb
                           tt-pesqsr.nrseqimp = craplcm.nrseqdig
                           tt-pesqsr.vldoipmf = DEC(TRUNC(crapfdc.vlcheque * 0.0038 , 2))
                           tt-pesqsr.cdbanchq = STRING(crapfdc.cdbandep,"zzz9") + "-" +
                                                STRING(crapfdc.cdagedep,"9999")
                           tt-pesqsr.sqlotchq = craplcm.sqlotchq
                           tt-pesqsr.cdcmpchq = craplcm.cdcmpchq
                           tt-pesqsr.nrlotchq = craplcm.nrlotchq
                           tt-pesqsr.nrctachq = crapfdc.nrctadep
                           tt-pesqsr.cdbaninf = par_cdbaninf

                           tt-pesqsr.cdagechq = aux_cdagechq

                           tt-pesqsr.nrdocmto = par_nrdocmto
                           tt-pesqsr.nrdctabb = par_nrdctabb
                           tt-pesqsr.nmprimtl = aux_nmprimtl
                           tt-pesqsr.dsagenci = aux_dsagenci
                           tt-pesqsr.cdturnos = aux_cdturnos
                           tt-pesqsr.nrfonemp = aux_nrfonemp
                           tt-pesqsr.nrramemp = aux_nrramemp
                           tt-pesqsr.nrdconta = aux_nrdconta
                           tt-pesqsr.dsdocmc7 = crapfdc.dsdocmc7
                           tt-pesqsr.cdagetfn = craplcm.cdagetfn
                           aux_regexist       = TRUE.

                    /*** LOCALIZA MOVIMENTO DE DEVOLUCAO CHEQUE ***/
                    FIND FIRST crablcm
                         WHERE crablcm.cdcooper   = craplcm.cdcooper
                           AND crablcm.nrdconta   = craplcm.nrdconta
                           AND crablcm.dtmvtolt  >= craplcm.dtmvtolt

                           AND (crablcm.cdhistor  = 47   OR
                                crablcm.cdhistor  = 191  OR
                                crablcm.cdhistor  = 338  OR
                                crablcm.cdhistor  = 573)
                           AND crablcm.nrdocmto  = craplcm.nrdocmto NO-LOCK NO-ERROR.

                    IF  AVAIL crablcm THEN DO:

                        ASSIGN aux_nrseqchq = aux_nrseqchq + 1.

                        CREATE tt-dados-cheque.
                        ASSIGN tt-dados-cheque.nrseqchq = aux_nrseqchq
                               tt-dados-cheque.dtmvtolt = crablcm.dtmvtolt
                               tt-dados-cheque.cdalinea = crablcm.cdpesqbb
                               tt-dados-cheque.dtmvtori = craplcm.dtmvtolt
                               tt-dados-cheque.cdbanchq = STRING(craplcm.cdbanchq,"zzz9")
                                                          + "-" +
                                                          STRING(craplcm.cdagechq,"9999")
                               tt-dados-cheque.cdagechq = craplcm.cdagechq
                               tt-dados-cheque.cdcmpchq = craplcm.cdcmpchq
                               tt-dados-cheque.nrlotchq = craplcm.nrlotchq
                               tt-dados-cheque.sqlotchq = craplcm.sqlotchq
                               tt-dados-cheque.nrctachq = craplcm.nrctachq.
                    END.

                END. /* FOR EACH craplcm */

                IF  NOT aux_regexist   THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Cheque nao compensado".
                        LEAVE Busca.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "".
                    END.

            END.

        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.

            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Opcao_C */

/* ------------------------------------------------------------------------ */
/*                    EFETUA A PESQUISA DE REMESSA - OPCAO D                */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Opcao_D:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbaninf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtola AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-pesqsr.
    DEF OUTPUT PARAM TABLE FOR tt-dados-cheque.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdctitg AS INTE                                    NO-UNDO.
    DEF VAR aux_nrctaass AS INTE                                    NO-UNDO.
    DEF VAR aux_dsdctitg AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrchqsdv AS INTE                                    NO-UNDO.
    DEF VAR aux_cdagechq AS INTE                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrfonemp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrramemp AS INTE                                    NO-UNDO.
    DEF VAR aux_cdturnos AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdctabb AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdctabb_x AS CHAR                                  NO-UNDO.
    DEF VAR aux_dsagenci AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtlimite AS DATE                                    NO-UNDO.
    DEF VAR aux_regexist AS LOGI                                    NO-UNDO.
    DEF VAR aux_contador AS INT										NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Pesquisa de Remessa"
           aux_dtlimite = IF MONTH(par_dtmvtolt) = 01
                             THEN DATE(12,01,YEAR(par_dtmvtolt) - 1)
                             ELSE DATE(MONTH(par_dtmvtolt) - 1,01,
                                  YEAR(par_dtmvtolt)).

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-pesqsr.
        EMPTY TEMP-TABLE tt-erro.

        /*? par_nrdconta do associado*/
        IF par_nrdconta <= 0 THEN
            DO:
                ASSIGN aux_cdcritic = 008
                       aux_dscritic = "".
                LEAVE Busca.
            END.


        FOR FIRST crapass
            WHERE crapass.cdcooper = par_cdcooper AND
                  crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAIL crapass THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        ASSIGN aux_nrdctabb_x = " "
               aux_nrdctabb   = 0.

        IF  par_cdbccxlt = 756 OR
            par_cdbccxlt = 85  THEN
            ASSIGN aux_nrdctabb = crapass.nrdconta.
        ELSE
            ASSIGN aux_nrdctabb_x = crapass.nrdctitg.

        /* Alimenta cdturnos */
        FOR FIRST crapttl
            WHERE crapttl.cdcooper = par_cdcooper     AND
                  crapttl.nrdconta = crapass.nrdconta AND
                  crapttl.idseqttl = 1 NO-LOCK:
        END.

        IF  AVAIL crapttl THEN
            ASSIGN aux_cdturnos = crapttl.cdturnos.
        ELSE
            ASSIGN aux_cdturnos = 0.

        ASSIGN aux_nmprimtl = crapass.nmprimtl
                       aux_nrfonemp = "0"
                           aux_nrramemp = 0.

                Telefone:
                DO aux_contador = 1 TO 4:

          FOR FIRST craptfc FIELDS (tptelefo nrtelefo nrdddtfc nrdramal)
              WHERE craptfc.cdcooper = par_cdcooper
                AND craptfc.nrdconta = crapass.nrdconta
                AND craptfc.idseqttl = 1
                AND craptfc.tptelefo = aux_contador NO-LOCK:

              /* 1 - Residencial */
              /* 2 - Celular     */
              /* 3 - Comercial   */
              /* 4 - Contato     */
              CASE craptfc.tptelefo:
                WHEN 1 THEN
                DO:
                    IF craptfc.nrtelefo > 0 THEN
                    DO:
                        ASSIGN aux_nrfonemp = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo)
                                                           aux_nrramemp = craptfc.nrdramal.

                        LEAVE telefone.
                    END.
                END.

                WHEN 2 THEN
                DO:
                    IF craptfc.nrtelefo > 0 THEN
                    DO:
                        ASSIGN aux_nrfonemp = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo)
                                                           aux_nrramemp = craptfc.nrdramal.

                        LEAVE telefone.
                    END.
                END.

                WHEN 4 THEN
                DO:
                    IF craptfc.nrtelefo > 0 THEN
                    DO:
                        ASSIGN aux_nrfonemp = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo)
                                                           aux_nrramemp = craptfc.nrdramal.

                        LEAVE telefone.
                    END.
                END.
              END CASE.

          END.
        END.

        FOR FIRST crapage
            WHERE crapage.cdcooper = par_cdcooper     AND
                  crapage.cdagenci = crapass.cdagenci NO-LOCK:
        END.

        IF  NOT AVAIL crapage THEN
            ASSIGN aux_dsagenci = STRING(crapass.cdagenci,"zz9") + " - " + FILL("*",15).
        ELSE
            ASSIGN aux_dsagenci = STRING(crapass.cdagenci,"zz9") + " - " + crapage.nmresage.

        FOR EACH craplcm
           WHERE craplcm.cdcooper = crapass.cdcooper   AND
                 craplcm.nrdconta = crapass.nrdconta   AND
                 craplcm.nrdocmto = par_nrdocmto       AND
                (craplcm.cdbccxlt = 1   OR
                 craplcm.cdbccxlt = 756 OR
                 craplcm.cdbccxlt = 85) NO-LOCK,
            FIRST craphis
            WHERE craphis.cdcooper = par_cdcooper      AND
                  craphis.cdhistor = craplcm.cdhistor  AND
                  craphis.indebcre = "C"               AND
                 (craphis.dshistor MATCHES "*TED*" OR
                  craphis.dshistor MATCHES "*TEC*"  OR
                  craphis.dshistor MATCHES "*DOC*") NO-LOCK:

            IF  craplcm.dtmvtolt < aux_dtlimite OR
                craplcm.dtmvtolt > par_dtmvtolt THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Consulta permitida apenas para lancamentos superiores a " + STRING(aux_dtlimite, '99/99/9999').
                LEAVE Busca.
            END.

            CREATE tt-pesqsr.

            ASSIGN tt-pesqsr.dtmvtolt = craplcm.dtmvtolt
                   tt-pesqsr.cdagenci = craplcm.cdagenci
                   tt-pesqsr.cdbccxlt = craplcm.cdbccxlt
                   tt-pesqsr.nrdolote = craplcm.nrdolote
                   tt-pesqsr.vllanmto = craplcm.vllanmto
                   tt-pesqsr.cdpesqbb = craplcm.cdpesqbb
                   tt-pesqsr.nrseqimp = craplcm.nrseqdig
                   tt-pesqsr.vldoipmf = DEC(TRUNC(craplcm.vllanmto * 0.0038 , 2))
                   tt-pesqsr.cdbanchq = STRING(craplcm.cdbanchq,"zzz9") + "-" +
                                        STRING(craplcm.cdagechq,"9999")
                   tt-pesqsr.sqlotchq = craplcm.sqlotchq
                   tt-pesqsr.cdcmpchq = craplcm.cdcmpchq
                   tt-pesqsr.nrlotchq = craplcm.nrlotchq
                   tt-pesqsr.nrctachq = craplcm.nrctachq
                   tt-pesqsr.nrdocmto = par_nrdocmto
                   tt-pesqsr.nrdctabb = aux_nrdctabb
                   tt-pesqsr.nrdctabx = aux_nrdctabb_x
                   tt-pesqsr.cdbaninf = craplcm.cdbccxlt
                   tt-pesqsr.nmprimtl = aux_nmprimtl
                   tt-pesqsr.dsagenci = aux_dsagenci
                   tt-pesqsr.cdturnos = aux_cdturnos
                   tt-pesqsr.nrfonemp = aux_nrfonemp
                   tt-pesqsr.nrramemp = aux_nrramemp
                   tt-pesqsr.nrdconta = par_nrdconta
                   tt-pesqsr.cdagetfn = 0
                   aux_regexist       = TRUE.

        END. /* FIM FOR EACH craplcm  */

        IF  NOT aux_regexist   THEN
            DO:
                ASSIGN aux_cdcritic = 242
                       aux_dscritic = "".
                LEAVE Busca.
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "".
            END.

        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.

            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Opcao_D */



PROCEDURE Busca_Opcao_R.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE FORMAT "99/99/9999"       NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcheque AS DATE FORMAT "99/99/9999"       NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR FORMAT "X(20)"            NO-UNDO.

    DEF OUTPUT PARAM ret_nmarquiv AS CHAR FORMAT "X(30)"            NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR FORMAT "X(30)"            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdocmto AS INTE                                    NO-UNDO.
    DEF VAR aux_cddcompe AS INTE                                    NO-UNDO.
    DEF VAR aux_nmdircop AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdoperad AS CHAR   FORMAT "X(24)"                   NO-UNDO.
    DEF VAR aux_dsregdat AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtregdat AS DATE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /* Busca descricao da Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.

    IF  AVAIL crapcop THEN DO:

        IF  par_idorigem = 5 THEN
            ASSIGN aux_nmdircop = "/usr/coop/" + crapcop.dsdircop +
                                  "/rl/".
        ELSE
            ASSIGN aux_nmdircop = "/micros/" + crapcop.dsdircop + "/".

        ASSIGN ret_nmarquiv = aux_nmdircop + par_nmarqimp
               ret_nmarqpdf = aux_nmdircop + par_nmarqimp + ".ex".

    END.

    OUTPUT STREAM str_1 TO VALUE(ret_nmarquiv).

    /* Cabecalho do Relatorio */
    PUT STREAM str_1
        "PA;"              FORMAT "X(3)"  AT 4
        "CONTA;"           FORMAT "X(6)"  AT 11
        "BCO CHQ;"         FORMAT "X(8)"  AT 17
        "DOCUMENTO;"       FORMAT "X(10)" AT 26
        "COMP;"            FORMAT "X(5)"  AT 36
        "BCO DEP;"         FORMAT "X(8)"  AT 41
        "AGE DEP;"         FORMAT "X(8)"  AT 49
        "CONTA DEP;"       FORMAT "X(10)" AT 61
        "CMC;"             FORMAT "X(10)" AT 71
        "TD;"              FORMAT "X(3)"  AT 113
        "VALOR;"           FORMAT "X(6)"  AT 117
        SKIP.

    ASSIGN aux_contador = 0.

    FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                           craplcm.dtmvtolt = par_dtcheque AND
            CAN-DO("50,59,313,340,524,572",STRING(craplcm.cdhistor))
                           NO-LOCK:

        ASSIGN aux_nrdocmto = INT(SUBSTR(STRING(craplcm.nrdocmto,"9999999"),1,6)).

        FIND FIRST crapfdc WHERE crapfdc.cdcooper = craplcm.cdcooper
                             AND crapfdc.cdbanchq = craplcm.cdbanchq
                             AND crapfdc.cdagechq = craplcm.cdagechq
                             AND crapfdc.nrctachq = craplcm.nrctachq
                             AND crapfdc.nrcheque = aux_nrdocmto
                             NO-LOCK NO-ERROR.

        IF  AVAIL crapfdc THEN DO:

            ASSIGN aux_contador = aux_contador + 1.

            PUT STREAM str_1
                crapfdc.cdagechq FORMAT "z,zz9"          AT 1
                ";"                                      AT 6
                crapfdc.nrctachq FORMAT "zzz,zzz,9"      AT 7
                ";"                                      AT 16
                crapfdc.cdbanchq FORMAT "z,zz9"          AT 17
                ";"                                      AT 24
                craplcm.nrdocmto FORMAT "zz,zzz,zz9"     AT 25
                ";"                                      AT 35
                crapfdc.cdcmpchq FORMAT "zzz9"           AT 36
                ";"                                      AT 40
                crapfdc.cdbandep FORMAT "999"            AT 41
                ";"                                      AT 48
                crapfdc.cdagedep FORMAT "9999"           AT 49
                ";"                                      AT 56
                crapfdc.nrctadep FORMAT "zzz,zzz,zz9,9"  AT 57
                ";"                                      AT 70
                crapfdc.dsdocmc7 FORMAT "x(40)"          AT 71
                ";"                                      AT 111
                crapfdc.cdtpdchq FORMAT "zz9"            AT 112
                ";"                                      AT 115
                crapfdc.vlcheque FORMAT "zzz,zzz,zz9,99" AT 116
                SKIP.

        END.

    END. /*FIM FOR EACH*/

    OUTPUT STREAM str_1 CLOSE.

    IF  aux_contador = 0 THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Nenhum registro encontrado".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.


    IF  par_idorigem = 5 THEN DO: /* Ayllos Web */

        UNIX SILENT VALUE("cp " + ret_nmarquiv + " " + ret_nmarqpdf +
                          " 2> /dev/null").

        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.

        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Handle invalido para BO " +
                                     "b1wgen0024.".

               RUN gera_erro (INPUT par_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1, /*sequencia*/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).

               RETURN "NOK".
            END.

        RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                INPUT 1, /* cdagenci */
                                                INPUT 1, /* nrdcaixa */
                                                INPUT ret_nmarqpdf,
                                                OUTPUT ret_nmarqpdf,
                                                OUTPUT TABLE tt-erro ).


        IF  VALID-HANDLE(h-b1wgen0024)  THEN
            DELETE PROCEDURE h-b1wgen0024.

        IF  RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE.

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ):
/*-----------------------------------------------------------------------------
  Objetivo:  Valida o digita verificador
     Notas:
-----------------------------------------------------------------------------*/

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_vlresult AS LOGICAL     NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p
            PERSISTENT SET h-b1wgen9999.

    ASSIGN
        aux_nrdconta = par_nrdconta
        aux_vlresult = TRUE.

    RUN dig_fun IN h-b1wgen9999
        ( INPUT par_cdcooper,
          INPUT par_cdagenci,
          INPUT par_nrdcaixa,
          INPUT-OUTPUT aux_nrdconta,
          OUTPUT TABLE tt-erro ).

    DELETE OBJECT h-b1wgen9999.

    /* verifica se o digito foi informado corretamente */
    IF  RETURN-VALUE <> "OK" THEN
        ASSIGN aux_vlresult = FALSE.

    FIND FIRST tt-erro NO-ERROR.

    IF  AVAILABLE tt-erro THEN
        ASSIGN aux_vlresult = FALSE.

    EMPTY TEMP-TABLE tt-erro.

    RETURN aux_vlresult.

END FUNCTION.
