/*.............................................................................

    Programa: b1wgen0064.p
    Autor   : Jose Luis (DB1)
    Data    : Marco/2010                   Ultima atualizacao: 05/03/2014

    Objetivo  : Tranformacao BO tela CONTAS - INFORMATIVOS

    Alteracoes: 03/12/2013 - Incluida validacao para permitir a inclusao de 
                             informativos somente se o cooperado possuir a 
                             senha de tele-atendimento/URA. (Reinert)
                             
                05/03/2014 - Incluso VALIDATE (Daniel).
                             
                14/03/2018 - Alterar a validaçao por tipo de conta pela 
                             modalidade. PRJ366 (Lombardi).
.............................................................................*/

/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0064tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i } 
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.

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
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapcra.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcra FOR crapcra.
    DEF BUFFER crabtab FOR craptab.

    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados dos Informativos"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapcra.
        EMPTY TEMP-TABLE tt-erro.   

        FOR EACH crabcra WHERE (crabcra.cdcooper = par_cdcooper AND
                                crabcra.nrdconta = par_nrdconta AND
                                crabcra.idseqttl = par_idseqttl) AND
                               (IF par_nrdrowid <> ? THEN
                                   ROWID(crabcra) = par_nrdrowid 
                                ELSE TRUE) NO-LOCK:

            IF  par_cddopcao <> "C" AND ROWID(crabcra) <> par_nrdrowid THEN
                NEXT.

            CREATE tt-crapcra.
            BUFFER-COPY crabcra TO tt-crapcra
                ASSIGN tt-crapcra.nrdrowid = ROWID(crabcra).

            FOR FIRST crabtab FIELDS(dstextab)
                               WHERE crabtab.cdcooper = 0            AND
                                     crabtab.nmsistem = "CRED"       AND
                                     crabtab.tptabela = "USUARI"     AND
                                     crabtab.cdempres = 11           AND
                                     crabtab.cdacesso = "FORENVINFO" AND
                                     crabtab.tpregist = crabcra.cddfrenv 
                                     NO-LOCK:

                CASE ENTRY(2,crabtab.dstextab,","):
                    WHEN "crapcem" THEN DO:
                        FOR FIRST crapcem FIELDS(dsdemail)
                            WHERE crapcem.cdcooper = crabcra.cdcooper  AND
                                  crapcem.nrdconta = crabcra.nrdconta  AND
                                  crapcem.idseqttl = crabcra.idseqttl  AND
                                  crapcem.cddemail = crabcra.cdseqinc  NO-LOCK:

                            ASSIGN tt-crapcra.dsrecebe = crapcem.dsdemail.
                        END.
                    END.
                    WHEN "craptfc" THEN DO:
                        FOR FIRST craptfc FIELDS(nrtelefo) 
                            WHERE craptfc.cdcooper = crabcra.cdcooper  AND
                                  craptfc.nrdconta = crabcra.nrdconta  AND
                                  craptfc.idseqttl = crabcra.idseqttl  AND
                                  craptfc.cdseqtfc = crabcra.cdseqinc  NO-LOCK:

                            tt-crapcra.dsrecebe = STRING(craptfc.nrtelefo).
                        END.
                    END.
                    WHEN "crapenc" THEN DO:
                        FOR FIRST crapenc FIELDS(dsendere) 
                            WHERE crapenc.cdcooper = crabcra.cdcooper  AND
                                  crapenc.nrdconta = crabcra.nrdconta  AND
                                  crapenc.idseqttl = crabcra.idseqttl  AND
                                  crapenc.cdseqinc = crabcra.cdseqinc  NO-LOCK:

                            ASSIGN tt-crapcra.dsrecebe = crapenc.dsendere.
                        END.
                    END.
                END CASE.
            END.

            FOR FIRST gnrlema FIELDS(nmrelato)
                              WHERE gnrlema.cdprogra = crabcra.cdprogra AND
                                    gnrlema.cdrelato = crabcra.cdrelato 
                                    NO-LOCK:
                ASSIGN tt-crapcra.nmrelato = gnrlema.nmrelato.
            END.

            FOR FIRST crabtab FIELDS(dstextab)
                              WHERE crabtab.cdcooper = 0              AND
                                    crabtab.nmsistem = "CRED"         AND
                                    crabtab.tptabela = "USUARI"       AND
                                    crabtab.cdempres = 11             AND
                                    crabtab.cdacesso = "FORENVINFO"   AND
                                    crabtab.tpregist = crabcra.cddfrenv 
                                    NO-LOCK: 
               ASSIGN tt-crapcra.dsdfrenv = ENTRY(1,crabtab.dstextab,",").
            END.

            FOR FIRST crabtab FIELDS(dstextab)
                              WHERE crabtab.cdcooper = 0              AND
                                    crabtab.nmsistem = "CRED"         AND
                                    crabtab.tptabela = "USUARI"       AND
                                    crabtab.cdempres = 11             AND
                                    crabtab.cdacesso = "PERIODICID"   AND
                                    crabtab.tpregist = crabcra.cdperiod 
                                    NO-LOCK:
                ASSIGN tt-crapcra.dsperiod = crabtab.dstextab.
            END.

        END.

        IF  (par_cddopcao <> "C" AND par_cddopcao <> "I") AND 
            NOT (TEMP-TABLE tt-crapcra:HAS-RECORDS)      THEN
            DO:
               ASSIGN aux_dscritic = "Registro de Informativo nao encontrado.".
               UNDO Busca, LEAVE Busca.
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

PROCEDURE Busca_Relatorios:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddfrenv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdperiod AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-informativos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.
    DEF VAR aux_cdmodali AS INTE                                    NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen0059 AS HANDLE                                  NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados dos Informativos"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_cdprogra = 217  AND par_cdrelato = 171  THEN
            DO:
               FOR FIRST crapass FIELDS(inpessoa cdtipcta)
                                 WHERE crapass.cdcooper = par_cdcooper AND
                                       crapass.nrdconta = par_nrdconta NO-LOCK:

                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                   RUN STORED-PROCEDURE pc_busca_modalidade_tipo
                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                        INPUT crapass.cdtipcta, /* Tipo de conta */
                                                       OUTPUT 0,                /* Modalidade */
                                                       OUTPUT "",               /* Flag Erro */
                                                       OUTPUT "").              /* Descriçao da crítica */

                   CLOSE STORED-PROC pc_busca_modalidade_tipo
                         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                   ASSIGN aux_cdmodali = 0
                          aux_des_erro = ""
                          aux_dscritic = ""
                          aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                         WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
                          aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                                         WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
                          aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                                         WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.

                   IF aux_des_erro = "NOK"  THEN
                       LEAVE Busca.
                   
                   IF  aux_cdmodali = 2 OR
                       aux_cdmodali = 3 THEN
                       DO:
                          ASSIGN aux_dscritic = "Este tipo de conta nao "    +
                                                "permite o Envio de Extrato" +
                                                " de Conta Corrente.". 
                          LEAVE Busca.
                       END.
               END. /* for first crapass */
            END.

        IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
            RUN sistema/generico/procedures/b1wgen0059.p
                PERSISTENT SET h-b1wgen0059.

        EMPTY TEMP-TABLE tt-informativos.

        RUN busca-crapifc IN h-b1wgen0059
            ( INPUT par_cdcooper, /* cdcooper */ 
              INPUT par_cdrelato, /* cdrelato */
              INPUT par_cdprogra, /* cdprogra */
              INPUT par_cddfrenv, /* cddfrenv */
              INPUT par_cdperiod, /* cdperiod */
              INPUT 99999,        /* nrregist */
              INPUT 0,            /* nriniseq */
             OUTPUT aux_qtregist,
             OUTPUT TABLE tt-informativos ).

        LEAVE Busca.
    END.

    IF  VALID-HANDLE(h-b1wgen0059) THEN
        DELETE OBJECT h-b1wgen0059.

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

PROCEDURE Valida_Relatorios:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddfrenv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdperiod AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_cdprogra = 217  AND par_cdrelato = 171  THEN
            DO:
               FOR FIRST crapass FIELDS(cdtipcta)
                                 WHERE crapass.cdcooper = par_cdcooper AND
                                       crapass.nrdconta = par_nrdconta NO-LOCK:

                   IF  crapass.cdtipcta = 5  OR crapass.cdtipcta = 6  OR
                       crapass.cdtipcta = 7  OR crapass.cdtipcta = 17 OR
                       crapass.cdtipcta = 18 THEN
                       DO:
                          ASSIGN aux_dscritic = "Este tipo de conta nao "    +
                                                "permite o Envio de Extrato" +
                                                " de Conta Corrente.". 
                          LEAVE Valida.
                       END.
               END. /* for first crapass */
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
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cdseqinc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddfrenv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdperiod AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdselimp AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgreceb AS LOGICAL                                 NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados dos Informativos"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.   

        Recebe: DO ON ERROR UNDO Recebe, LEAVE Recebe:
            ASSIGN aux_flgreceb = YES.

            IF  CAN-FIND(FIRST crapcem WHERE 
                                       crapcem.cdcooper = par_cdcooper AND
                                       crapcem.nrdconta = par_nrdconta AND
                                       crapcem.idseqttl = par_idseqttl AND
                                       crapcem.cddemail = par_cdseqinc ) THEN
                LEAVE Recebe.

            IF  CAN-FIND(FIRST craptfc WHERE 
                                       craptfc.cdcooper = par_cdcooper AND
                                       craptfc.nrdconta = par_nrdconta AND
                                       craptfc.idseqttl = par_idseqttl AND
                                       craptfc.cdseqtfc = par_cdseqinc )
                THEN 
                LEAVE Recebe.

            IF  CAN-FIND(FIRST crapenc WHERE 
                                       crapenc.cdcooper = par_cdcooper AND
                                       crapenc.nrdconta = par_nrdconta AND
                                       crapenc.idseqttl = par_idseqttl AND
                                       crapenc.cdseqinc = par_cdseqinc ) THEN
                LEAVE Recebe.

            ASSIGN aux_flgreceb = NO.

            LEAVE Recebe.
        END.

        /* Validar o campo 'RECEBIMENTO' */
        IF  NOT aux_flgreceb THEN
            DO:
               ASSIGN aux_dscritic = "O campo 'Recebimento' deve ser " + 
                                     "preenchido.".
               LEAVE Valida.
            END.

        /* Validar o campo 'PERIODO' */
        IF  NOT CAN-FIND(FIRST craptab WHERE 
                                       craptab.cdcooper = 0              AND
                                       craptab.nmsistem = "CRED"         AND
                                       craptab.tptabela = "USUARI"       AND
                                       craptab.cdempres = 11             AND
                                       craptab.cdacesso = "PERIODICID"   AND
                                       craptab.tpregist = par_cdperiod) THEN
            DO:
               ASSIGN aux_dscritic = "Periodo de Recebimento nao encontrado.".
               LEAVE Valida.
            END.

        /* Validar o campo 'INFORMATIVO' */
        IF  NOT CAN-FIND(FIRST gnrlema WHERE 
                                       gnrlema.cdprogra = par_cdprogra AND
                                       gnrlema.cdrelato = par_cdrelato) THEN
            DO:
               ASSIGN aux_dscritic = "O campo 'Informativo' deve ser " + 
                                     "preenchido corretamente.".
               LEAVE Valida.
            END.

        /* Validar o campo 'FORMA ENVIO' */
        IF  NOT CAN-FIND(FIRST craptab WHERE 
                                       craptab.cdcooper = 0            AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "USUARI"     AND
                                       craptab.cdempres = 11           AND
                                       craptab.cdacesso = "FORENVINFO" AND
                                       craptab.tpregist = par_cddfrenv) THEN 
            DO:
               ASSIGN aux_dscritic = "Forma de Envio nao cadastrada.".
               LEAVE Valida.
            END.

        IF  par_cdprogra = 217  AND par_cdrelato = 171  THEN
            DO:
               FOR FIRST crapass FIELDS(cdtipcta)
                                 WHERE crapass.cdcooper = par_cdcooper AND
                                       crapass.nrdconta = par_nrdconta NO-LOCK:

                   IF  crapass.cdtipcta = 5  OR crapass.cdtipcta = 6  OR
                       crapass.cdtipcta = 7  OR crapass.cdtipcta = 17 OR
                       crapass.cdtipcta = 18 THEN
                       DO:
                          ASSIGN aux_dscritic = "Este tipo de conta nao "    +
                                                "permite o Envio de Extrato" +
                                                " de Conta Corrente.". 
                          LEAVE Valida.
                       END.
               END. /* for first crapass */
            END.

        /* verificar se ja existe cadastro */
        IF  CAN-FIND(FIRST crapcra WHERE
                     crapcra.cdcooper = par_cdcooper AND
                     crapcra.nrdconta = par_nrdconta AND
                     crapcra.idseqttl = par_idseqttl AND
                     crapcra.cdrelato = par_cdrelato AND
                     crapcra.cdprogra = par_cdprogra AND
                     crapcra.cddfrenv = par_cddfrenv AND
                     crapcra.cdseqinc = par_cdseqinc AND
                     crapcra.cdselimp = par_cdselimp AND
                     ROWID(crapcra)  <> par_nrdrowid) AND
            (par_cddopcao = "I" OR par_cddopcao = "A") THEN
            DO:
                ASSIGN aux_dscritic = "Ja existe cadastro com os dados " + 
                                      "informados".
                LEAVE Valida.
            END.

        /* Verificar se cooperado possui senha URA cadastrada */
        IF NOT CAN-FIND(FIRST crapsnh WHERE 
                        crapsnh.cdcooper = par_cdcooper 
                    AND crapsnh.nrdconta = par_nrdconta
                    AND crapsnh.tpdsenha = 2)
                    AND par_cddopcao = "I" THEN
           DO:             
             IF par_cdrelato = 171 THEN
                DO:
                   ASSIGN aux_dscritic = "Senha de tele-atendimento/URA nao cadastrada".                
                   LEAVE Valida.
                END.
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
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddfrenv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_sqincant AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseqinc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdselimp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdperiod AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdseqinc AS INTE                                    NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF par_cddopcao = "E" 
                        THEN "Exclui"  ELSE "Grava") + 
                       " dados dos Informativos"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.   

        CASE par_cddopcao:
            WHEN "I" THEN ASSIGN aux_cdseqinc = par_cdseqinc.
            WHEN "A" THEN ASSIGN aux_cdseqinc = par_sqincant.
            WHEN "E" THEN ASSIGN aux_cdseqinc = par_cdseqinc.
        END CASE.

        ContadorCra: DO aux_contador = 1 TO 10:
            FIND crapcra WHERE ROWID(crapcra) = par_nrdrowid
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                 
            IF   NOT AVAILABLE crapcra THEN
                 DO:
                     IF  LOCKED(crapcra) THEN
                         DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                   aux_dscritic = "Informativo sendo alterado" 
                                                  + " em outra estacao." .
                                   LEAVE ContadorCra.
                                END.
                            ELSE 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT ContadorCra.
                                END.
                         END.
                     ELSE
                         DO:
                            IF  par_cddopcao <> "I" THEN
                                DO:
                                   aux_dscritic = "Registro de informativos " +
                                                  "nao foi encontrado.". 
                                   LEAVE ContadorCra.
                                END.

                            CREATE crapcra.
                            ASSIGN
                               crapcra.cdcooper = par_cdcooper
                               crapcra.nrdconta = par_nrdconta
                               crapcra.idseqttl = par_idseqttl
                               crapcra.cdrelato = par_cdrelato
                               crapcra.cdprogra = par_cdprogra
                               crapcra.cddfrenv = par_cddfrenv
                               crapcra.cdseqinc = par_cdseqinc
                               crapcra.cdselimp = par_cdselimp
                               par_nrdrowid     = ROWID(crapcra).
                            VALIDATE crapcra.

                            LEAVE ContadorCra.
                         END.
                 END.
            ELSE LEAVE ContadorCra.
        END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        EMPTY TEMP-TABLE tt-crapcra-ant.
        EMPTY TEMP-TABLE tt-crapcra-atl.

        /* prepara a tabela p/ gravar o log - dados antigos */
        IF  par_cddopcao = "I" THEN
            CREATE tt-crapcra-ant.
        ELSE 
            DO:
                RUN Busca_Dados
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT FALSE,
                      INPUT par_cddopcao,
                      INPUT par_nrdrowid,
                     OUTPUT TABLE tt-crapcra-ant,
                     OUTPUT TABLE tt-erro ).

                IF   RETURN-VALUE <> "OK" THEN
                     UNDO Grava, LEAVE Grava.
            END.

        /* atualizar os dados na tabela */
        IF  par_cddopcao = "E"  THEN
            DO:
               DELETE crapcra.
            END.
        ELSE 
            DO:
               ASSIGN
                   crapcra.cdseqinc = par_cdseqinc 
                   crapcra.cdperiod = par_cdperiod
                   crapcra.cdrelato = par_cdrelato
                   crapcra.cdprogra = par_cdprogra.
            END.

        /* prepara a tabela p/ gravar o log - dados atuais */
        IF  par_cddopcao = "E" THEN
            CREATE tt-crapcra-atl.
        ELSE 
            DO:
                RUN Busca_Dados
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT FALSE,
                      INPUT par_cddopcao,
                      INPUT par_nrdrowid,
                     OUTPUT TABLE tt-crapcra-atl,
                     OUTPUT TABLE tt-erro ).
            END.

        EMPTY TEMP-TABLE tt-erro.

        RUN Grava_Log
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_idorigem,
              INPUT par_nrdconta,
              INPUT par_idseqttl,
              INPUT par_cddopcao,
              INPUT TABLE tt-crapcra-ant,
              INPUT TABLE tt-crapcra-atl,
             OUTPUT aux_cdcritic,
             OUTPUT aux_dscritic ).

        IF  RETURN-VALUE <> "OK" THEN
            UNDO Grava, LEAVE Grava.

        ASSIGN aux_retorno = "OK".

        LEAVE Grava.
    END.

    RELEASE crapcra.

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

    IF  par_flgerlog AND aux_retorno = "NOK" THEN
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

PROCEDURE Grava_Log:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-crapcra-ant.
    DEF  INPUT PARAM TABLE FOR tt-crapcra-atl. 

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    GravaLog: DO TRANSACTION
        ON ERROR  UNDO GravaLog, LEAVE GravaLog
        ON QUIT   UNDO GravaLog, LEAVE GravaLog
        ON STOP   UNDO GravaLog, LEAVE GravaLog
        ON ENDKEY UNDO GravaLog, LEAVE GravaLog:

        FIND FIRST tt-crapcra-ant NO-ERROR.

        FIND FIRST tt-crapcra-atl NO-ERROR.

        CASE par_cddopcao:
            WHEN "I" THEN DO:
                RUN proc_gerar_log 
                    ( INPUT par_cdcooper,  
                      INPUT par_cdoperad,  
                      INPUT aux_dscritic,  
                      INPUT aux_dsorigem,  
                      INPUT "Inclusao de Informativo: " + 
                            STRING(tt-crapcra-atl.cdrelato) + "-" + 
                            tt-crapcra-atl.nmrelato,
                      INPUT YES,           
                      INPUT par_idseqttl,  
                      INPUT par_nmdatela,  
                      INPUT par_nrdconta,  
                     OUTPUT aux_nrdrowid ). 

                RUN proc_gerar_log_item 
                   ( INPUT aux_nrdrowid,
                     INPUT "Periodo",
                     INPUT "",
                     INPUT STRING(tt-crapcra-atl.cdperiod) + "-" + 
                           tt-crapcra-atl.dsperiod ).

                RUN proc_gerar_log_item 
                   ( INPUT aux_nrdrowid,
                     INPUT "Canal",
                     INPUT "",
                     INPUT STRING(tt-crapcra-atl.cddfrenv) + "-" + 
                           tt-crapcra-atl.dsdfrenv ).

                RUN proc_gerar_log_item
                    ( INPUT aux_nrdrowid,
                      INPUT "Endereco",
                      INPUT "",
                      INPUT STRING(tt-crapcra-atl.cdseqinc) + "-" + 
                            tt-crapcra-atl.dsrecebe).
            END.
            WHEN "A" THEN DO:
                IF  tt-crapcra-ant.cdperiod <> tt-crapcra-atl.cdperiod OR
                    tt-crapcra-ant.cdseqinc <> tt-crapcra-atl.cdseqinc THEN
                    DO:
                        RUN proc_gerar_log 
                            ( INPUT par_cdcooper,  
                              INPUT par_cdoperad,  
                              INPUT aux_dscritic,  
                              INPUT aux_dsorigem,  
                              INPUT "Alteracao de Informativo: " + 
                                    STRING(tt-crapcra-atl.cdrelato) + "-" + 
                                    tt-crapcra-atl.nmrelato,
                              INPUT YES,           
                              INPUT par_idseqttl,  
                              INPUT par_nmdatela,  
                              INPUT par_nrdconta,  
                             OUTPUT aux_nrdrowid ). 

                        /* Descricao periodo depois da alteracao */
                        IF  tt-crapcra-ant.cdperiod <> 
                            tt-crapcra-atl.cdperiod THEN
                            RUN proc_gerar_log_item 
                                ( INPUT aux_nrdrowid,
                                  INPUT "Periodo",
                                  INPUT STRING(tt-crapcra-ant.cdperiod) + "-" +
                                        tt-crapcra-ant.dsperiod,
                                  INPUT STRING(tt-crapcra-atl.cdperiod) + "-" +
                                        tt-crapcra-atl.dsperiod ).
                        ELSE
                            RUN proc_gerar_log_item 
                                ( INPUT aux_nrdrowid,
                                  INPUT "Periodo",
                                  INPUT "",
                                  INPUT STRING(tt-crapcra-ant.cdperiod) + "-" +
                                        tt-crapcra-ant.dsperiod ).

                        /* Descricao do canal de distribuicao */
                        RUN proc_gerar_log_item 
                            ( INPUT aux_nrdrowid,
                              INPUT "Canal",
                              INPUT "",
                              INPUT STRING(tt-crapcra-ant.cddfrenv) + "-" + 
                                    tt-crapcra-ant.dsdfrenv ).

                        /* Atualizacao do endereco */
                        IF  tt-crapcra-ant.cdseqinc <> 
                            tt-crapcra-atl.cdseqinc THEN
                            RUN proc_gerar_log_item 
                                ( INPUT aux_nrdrowid,
                                  INPUT "Endereco",
                                  INPUT STRING(tt-crapcra-ant.cdseqinc) + "-" +
                                        tt-crapcra-ant.dsrecebe,
                                  INPUT STRING(tt-crapcra-atl.cdseqinc) + "-" +
                                        tt-crapcra-atl.dsrecebe ).
                        ELSE 
                            RUN proc_gerar_log_item 
                                ( INPUT aux_nrdrowid,
                                  INPUT "Endereco",
                                  INPUT "",
                                  INPUT STRING(tt-crapcra-ant.cdseqinc) + "-" +
                                        tt-crapcra-ant.dsrecebe ).
                    END.
            END.
            WHEN "E" THEN DO:
                RUN proc_gerar_log
                    ( INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT aux_dscritic,
                      INPUT aux_dsorigem,
                      INPUT "Exclusao de informativo: " +
                            STRING(tt-crapcra-ant.cdrelato) + "-" +
                            tt-crapcra-ant.nmrelato,
                      INPUT YES,
                      INPUT par_idseqttl,
                      INPUT par_nmdatela,
                      INPUT par_nrdconta,
                     OUTPUT aux_nrdrowid ).

                RUN proc_gerar_log_item
                   ( INPUT aux_nrdrowid,
                     INPUT "Periodo",
                     INPUT "",
                     INPUT STRING(tt-crapcra-ant.cdperiod) + "-" +
                           tt-crapcra-ant.dsperiod ).

                RUN proc_gerar_log_item
                   ( INPUT aux_nrdrowid,
                     INPUT "Canal",
                     INPUT "",
                     INPUT STRING(tt-crapcra-ant.cddfrenv) + "-" +
                           tt-crapcra-ant.dsdfrenv ).

                RUN proc_gerar_log_item
                    ( INPUT aux_nrdrowid,
                      INPUT "Endereco",
                      INPUT "",
                      INPUT STRING(tt-crapcra-ant.cdseqinc) + "-" +
                            tt-crapcra-ant.dsrecebe ).
            END.
        END CASE.

        LEAVE GravaLog.
    END.

    IF  aux_dscritic = "" AND aux_cdcritic = 0 THEN
        ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.
