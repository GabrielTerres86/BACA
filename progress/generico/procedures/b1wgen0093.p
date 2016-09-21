/*.............................................................................

   Programa: b1wgen0093.p
   Autora  : André - DB1
   Data    : 27/05/2011                        Ultima atualizacao: 17/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO - Cadastramento Guias Previdencia

   Alteracoes: 17/10/2011 - Alterado valor total da guia (Gabriel)
     
               30/07/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao invés da crapass (James).
                            
               17/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
               
.............................................................................*/

/*................................ DEFINICOES ...............................*/

{ sistema/generico/includes/b1wgen0093tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1crap82   AS HANDLE                                         NO-UNDO.

/*............................ PROCEDURES EXTERNAS ..........................*/

/* ************************************************************************* */
/**                       Procedure para buscar pagto ou nome               **/
/* ************************************************************************  */
PROCEDURE busca-pagto-nome:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdidenti AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrctadeb AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_nmprimtl AS CHAR                              NO-UNDO.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrctadeb
                       NO-LOCK NO-ERROR.

    IF  AVAIL crapass THEN
        ASSIGN par_nmprimtl = crapass.nmprimtl.

    RETURN "OK".

END PROCEDURE.

/* ************************************************************************* */
/**                       Procedure para buscar associado                   **/
/* ************************************************************************  */
PROCEDURE busca-assoc:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdidenti AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cddpagto AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_flgcontr AS LOGI                              NO-UNDO.

    DEF OUTPUT PARAM par_flgexass AS LOGI                              NO-UNDO.
    DEF OUTPUT PARAM par_msgretor AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-cadgps.

    DEF VAR aux_nrdconta AS INTE NO-UNDO.
    DEF VAR aux_idseqttl AS INTE NO-UNDO.
    DEF VAR aux_nrtelefo AS CHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cadgps.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_flgexass = FALSE.

    Busca: DO WHILE TRUE:

        IF  par_cddopcao <> "I" THEN
            DO:

                FIND crapcgp WHERE crapcgp.cdcooper = par_cdcooper   AND
                                   crapcgp.cdidenti = par_cdidenti   AND
                                   crapcgp.cddpagto = par_cddpagto
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapcgp THEN
                    DO:
                        ASSIGN aux_cdcritic = 855.
                        LEAVE Busca.
                    END.

                CREATE tt-cadgps.
                ASSIGN tt-cadgps.cddpagto = crapcgp.cddpagto
                       tt-cadgps.cdidenti = crapcgp.cdidenti
                       tt-cadgps.tpcontri = crapcgp.tpcontri
                       tt-cadgps.nrdconta = crapcgp.nrdconta
                       tt-cadgps.idseqttl = crapcgp.idseqttl
                       tt-cadgps.nmextttl = crapcgp.nmprimtl
                       tt-cadgps.flgrgatv = crapcgp.flgrgatv
                       tt-cadgps.flgdbaut = crapcgp.flgdbaut
                       aux_nrdconta = crapcgp.nrdconta
                       aux_idseqttl = crapcgp.idseqttl.

            END.

        IF  par_flgcontr  THEN
            ASSIGN aux_nrdconta = par_nrdconta
                   aux_idseqttl = par_idseqttl.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = aux_nrdconta
                           NO-LOCK NO-ERROR.

        IF  AVAILABLE crapass  THEN
            DO:
                ASSIGN par_flgexass = TRUE.

                FIND FIRST craptfc WHERE craptfc.cdcooper = par_cdcooper AND
                                         craptfc.nrdconta = aux_nrdconta AND
                                         craptfc.idseqttl = aux_idseqttl
                                         NO-LOCK NO-ERROR.

                IF AVAIL craptfc THEN 
                   ASSIGN aux_nrtelefo = "(" + STRING(craptfc.nrdddtfc) + ") " +
                                         STRING(craptfc.nrtelefo).
                ELSE
                   ASSIGN aux_nrtelefo = "".

                IF  crapass.inpessoa = 1 THEN
                    DO:
                        FIND crapttl WHERE
                             crapttl.cdcooper = par_cdcooper  AND
                             crapttl.nrdconta = aux_nrdconta  AND
                             crapttl.idseqttl = aux_idseqttl
                             NO-LOCK NO-ERROR.

                        IF  NOT AVAIL crapttl AND
                            (par_idseqttl <> 0 OR par_cddopcao = "A") THEN
                            DO:
                                ASSIGN par_msgretor = "009 - Associado nao " +
                                                      "cadastrado.".
                                LEAVE Busca.
                            END.

                        IF  NOT AVAIL crapttl THEN
                            LEAVE Busca.

                        FIND FIRST crapenc WHERE
                                   crapenc.cdcooper = par_cdcooper       AND
                                   crapenc.nrdconta = crapttl.nrdconta   AND
                                   crapenc.idseqttl = crapttl.idseqttl
                                   NO-LOCK NO-ERROR.

                        IF  NOT AVAIL tt-cadgps THEN
                            CREATE tt-cadgps.
                        ASSIGN
                            tt-cadgps.nmextttl = crapttl.nmextttl
                            tt-cadgps.nrcpfcgc = crapttl.nrcpfcgc
                            tt-cadgps.dsendres = 
                                        SUBSTRING(crapenc.dsendere,1,32) + " " +
                                        TRIM(STRING(crapenc.nrendere,"zzz,zzz" ))
                            tt-cadgps.nmbairro = crapenc.nmbairro
                            tt-cadgps.nmcidade = crapenc.nmcidade
                            tt-cadgps.nrcepend = crapenc.nrcepend
                            tt-cadgps.cdufresd = crapenc.cdufende
                            tt-cadgps.nrfonres = aux_nrtelefo                            
                            tt-cadgps.inpessoa = crapass.inpessoa
                            tt-cadgps.nrendres = crapenc.nrendere
                            tt-cadgps.complend = crapenc.complend
                            tt-cadgps.nrcxapst = crapenc.nrcxapst
                            tt-cadgps.idseqttl = aux_idseqttl
                            tt-cadgps.nrdconta = aux_nrdconta
                            tt-cadgps.cdidenti = par_cdidenti
                            tt-cadgps.cddpagto = par_cddpagto.

                    END.
                ELSE
                    DO:
                        FIND crapenc WHERE
                             crapenc.cdcooper = par_cdcooper      AND
                             crapenc.nrdconta = crapass.nrdconta  AND
                             crapenc.idseqttl = 1                 AND
                             crapenc.cdseqinc = 1
                             NO-LOCK NO-ERROR.

                        IF  NOT AVAIL tt-cadgps THEN
                            CREATE tt-cadgps.
                        ASSIGN
                            tt-cadgps.nmextttl = crapass.nmprimtl
                            tt-cadgps.nrcpfcgc = crapass.nrcpfcgc
                            tt-cadgps.dsendres =
							          SUBSTRING(crapenc.dsendere,1,32) + " " +
							          TRIM(STRING(crapenc.nrendere,"zzz,zzz" ))
                            tt-cadgps.nmbairro = crapenc.nmbairro
                            tt-cadgps.nmcidade = crapenc.nmcidade
                            tt-cadgps.nrcepend = crapenc.nrcepend
                            tt-cadgps.cdufresd = crapenc.cdufende
                            tt-cadgps.nrfonres = aux_nrtelefo
                            tt-cadgps.inpessoa = crapass.inpessoa
                            tt-cadgps.nrendres = crapenc.nrendere
                            tt-cadgps.complend = crapenc.complend
                            tt-cadgps.nrcxapst = crapenc.nrcxapst
                            tt-cadgps.idseqttl = aux_idseqttl
                            tt-cadgps.nrdconta = aux_nrdconta
                            tt-cadgps.cdidenti = par_cdidenti
                            tt-cadgps.cddpagto = par_cddpagto.

                END.
             END.
        ELSE
        IF  AVAILABLE crapcgp   THEN
            DO:
                IF  NOT AVAIL tt-cadgps THEN
                    CREATE tt-cadgps.

                ASSIGN tt-cadgps.nmextttl = crapcgp.nmprimtl
                       tt-cadgps.nrcpfcgc = crapcgp.nrcpfcgc
                       tt-cadgps.dsendres = crapcgp.dsendres
                       tt-cadgps.nmbairro = crapcgp.nmbairro
                       tt-cadgps.nmcidade = crapcgp.nmcidade
                       tt-cadgps.nrcepend = crapcgp.nrcepend
                       tt-cadgps.cdufresd = crapcgp.cdufresd
                       tt-cadgps.nrfonres = crapcgp.nrfonres
                       tt-cadgps.nrendres = crapcgp.nrendres
                       tt-cadgps.complend = crapcgp.complend
                       tt-cadgps.nrcxapst = crapcgp.nrcxapst
                       tt-cadgps.idseqttl = aux_idseqttl
                       tt-cadgps.nrdconta = aux_nrdconta
                       tt-cadgps.cdidenti = par_cdidenti
                       tt-cadgps.cddpagto = par_cddpagto.
            END.

        IF  NOT AVAIL crapass AND par_nrdconta <> 0 AND
            (par_cddopcao = "A" OR par_cddopcao = "I")  THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE Busca.
            END.

        LEAVE.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.

/* ************************************************************************* */
/**                       Procedure para carregar debito                    **/
/* ************************************************************************  */
PROCEDURE busca-deb:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdidenti AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cddpagto AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_msgretor AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-cadgps.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cadgps.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Busca: DO WHILE TRUE:

        FIND crapcgp WHERE crapcgp.cdcooper = par_cdcooper   AND
                           crapcgp.cdidenti = par_cdidenti   AND
                           crapcgp.cddpagto = par_cddpagto   NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcgp THEN
            DO:
                ASSIGN aux_cdcritic = 855.
                LEAVE Busca.
            END.

        CREATE tt-cadgps.
        ASSIGN tt-cadgps.inpessoa = crapcgp.inpessoa
               tt-cadgps.flgdbaut = crapcgp.flgdbaut
               tt-cadgps.nrctadeb = crapcgp.nrctadeb
               tt-cadgps.vlrdinss = crapcgp.vlrdinss
               tt-cadgps.vloutent = crapcgp.vloutent
               tt-cadgps.vlrjuros = crapcgp.vlrjuros
               tt-cadgps.nmctadeb = "".

        IF  tt-cadgps.inpessoa = 1 THEN
            ASSIGN tt-cadgps.dspessoa = "- Fisica".
        ELSE
        IF  tt-cadgps.inpessoa = 2 THEN
            ASSIGN tt-cadgps.dspessoa = "- Juridica".

        FIND crapass WHERE  crapass.cdcooper = par_cdcooper AND
                            crapass.nrdconta = tt-cadgps.nrctadeb
                            NO-LOCK NO-ERROR.

        IF  AVAIL crapass THEN
            ASSIGN tt-cadgps.nmctadeb = crapass.nmprimtl.

        ASSIGN tt-cadgps.vlrtotal = tt-cadgps.vlrdinss + tt-cadgps.vloutent +
                                    tt-cadgps.vlrjuros.

        IF  crapcgp.flgrgatv = FALSE THEN
            ASSIGN par_msgretor = "Ative a guia para cadastrar debito " +
                                  "autorizado.".

        LEAVE.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.


/* ************************************************************************ */
/*                           Gravacao dos dados                             */
/* ************************************************************************ */
PROCEDURE grava-dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.

    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdidenti AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cddpagto AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_vlrdinss AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_flgdbaut AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_nrctadeb AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_vloutent AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_vlrjuros AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_vlrtotal AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_tpcontri AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgrgatv AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dsendres AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdufresd AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrendres AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrfonres AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmextttl AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                       NO-UNDO.
    DEF VAR aux_contador AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    ASSIGN aux_flgtrans = FALSE.

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        ContadorD: DO aux_contador = 1 TO 10:

            FIND crapcgp WHERE crapcgp.cdcooper = par_cdcooper   AND
                               crapcgp.cdidenti = par_cdidenti   AND
                               crapcgp.cddpagto = par_cddpagto
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  par_cddopcao = "D" OR par_cddopcao = "A" THEN
                DO:
                    IF  NOT AVAIL crapcgp THEN
                        IF  LOCKED crapcgp  THEN
                            DO:
                                IF  aux_contador = 10 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 341.
                                        UNDO Grava, LEAVE Grava.
                                    END.
                                ELSE
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorD.
                                    END.
                            END.
                        ELSE
                            DO:
                                IF  par_cddopcao = "D" THEN
                                    ASSIGN aux_cdcritic = 855.
                                ELSE
                                    ASSIGN aux_cdcritic = 77.
                                UNDO Grava, LEAVE Grava.
                            END.
                END.
            ELSE
            IF  par_cddopcao = "I" THEN
                DO:
                    IF  AVAIL crapcgp    OR 
                        LOCKED(crapcgp)  THEN
                        DO:
                            ASSIGN aux_cdcritic = 854.
                            UNDO Grava, LEAVE Grava.
                        END.
                END.

            LEAVE.

        END.

        IF  par_cddopcao = "D" THEN
            DO:
                ASSIGN crapcgp.inpessoa = par_inpessoa
                       crapcgp.vlrdinss = par_vlrdinss
                       crapcgp.flgdbaut = par_flgdbaut
                       crapcgp.nrctadeb = par_nrctadeb
                       crapcgp.vloutent = par_vloutent
                       crapcgp.vlrjuros = par_vlrjuros NO-ERROR.
            END.
        ELSE
        IF  par_cddopcao = "A" THEN
            DO:
                ASSIGN crapcgp.cddpagto = par_cddpagto
                       crapcgp.tpcontri = par_tpcontri
                       crapcgp.nrdconta = par_nrdconta
                       crapcgp.idseqttl = par_idseqttl
                       crapcgp.nmprimtl = CAPS(par_nmextttl)
                       crapcgp.nrcpfcgc = par_nrcpfcgc
                       crapcgp.dsendres = par_dsendres
                       crapcgp.nmbairro = par_nmbairro
                       crapcgp.nmcidade = par_nmcidade
                       crapcgp.nrcepend = par_nrcepend
                       crapcgp.cdufresd = par_cdufresd
                       crapcgp.nrendres = par_nrendres
                       crapcgp.complend = CAPS(par_complend)
                       crapcgp.nrcxapst = par_nrcxapst
                       crapcgp.nrfonres = par_nrfonres
                       crapcgp.flgrgatv = par_flgrgatv NO-ERROR.
            END.
        ELSE
        IF  par_cddopcao = "I" THEN
            DO:
                CREATE crapcgp.
                ASSIGN crapcgp.cdoperad = par_cdoperad
                       crapcgp.hrtransa = TIME
                       crapcgp.cdcooper = par_cdcooper
                       crapcgp.dtmvtolt = par_dtmvtolt
                       crapcgp.cdidenti = par_cdidenti
                       crapcgp.cddpagto = par_cddpagto
                       crapcgp.tpcontri = par_tpcontri
                       crapcgp.nrdconta = par_nrdconta
                       crapcgp.idseqttl = par_idseqttl
                       crapcgp.nmprimtl = CAPS(par_nmextttl)
                       crapcgp.nrcpfcgc = par_nrcpfcgc
                       crapcgp.dsendres = par_dsendres
                       crapcgp.nmbairro = par_nmbairro
                       crapcgp.nmcidade = par_nmcidade
                       crapcgp.nrcepend = par_nrcepend
                       crapcgp.cdufresd = par_cdufresd
                       crapcgp.nrendres = par_nrendres
                       crapcgp.complend = CAPS(par_complend)
                       crapcgp.nrcxapst = par_nrcxapst
                       crapcgp.nrfonres = par_nrfonres
                       crapcgp.flgrgatv = YES
                       crapcgp.inpessoa = 0 NO-ERROR.
                VALIDATE crapcgp.
            END.

        IF  ERROR-STATUS:ERROR THEN
            DO:
                ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                LEAVE Grava.
            END.

        ASSIGN aux_flgtrans = TRUE.

    END.

    RELEASE crapcgp.
    
    IF  (NOT aux_flgtrans) OR (aux_cdcritic <> 0 OR aux_dscritic <> "")  THEN
        DO:
            IF  (aux_cdcritic = 0 AND aux_dscritic = "") THEN
                ASSIGN aux_dscritic = "Erro na transacao. Nao foi possivel" +
                                      "gravar os dados.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    IF  par_flgerlog THEN
        RUN proc-crialog ( INPUT par_cdcooper,
                           INPUT par_cdoperad,
                           INPUT par_cddopcao,
                           INPUT par_dtmvtolt,
                           INPUT par_cdidenti,
                           INPUT par_cddpagto,
                           INPUT par_flgdbaut,
                           INPUT par_inpessoa,
                           INPUT par_nrctadeb,
                           INPUT par_vlrdinss,
                           INPUT par_vloutent,
                           INPUT par_vlrjuros,
                           INPUT par_vlrtotal,
                           INPUT par_tpcontri,
                           INPUT par_idseqttl,
                           INPUT par_flgrgatv,
                           INPUT par_nrdconta ).
    RETURN "OK".

END PROCEDURE.

/* ************************************************************************* */
/**                           Validar autorizacao                           **/
/* ************************************************************************  */
PROCEDURE valida-autori-deb:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctadeb AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdidenti AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_chrvalid AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdcampo = "".

    Valida: DO WHILE TRUE:
        
        IF  par_chrvalid = "DEBITO" THEN
            DO:
                FIND FIRST crapcop WHERE
                           crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                
                IF  crapcop.cdcrdarr = 0 AND par_cddopcao = "D" THEN
                    DO:
                        ASSIGN aux_dscritic = "Debito autorizado somente " +
                                              "para pagamento pelo bancoob."
                               par_nmdcampo = "cddopcao".
                        LEAVE Valida.
                   END.
            END.
        ELSE
        IF  par_chrvalid = "AUTORI" THEN
            DO:

                IF  NOT CAN-DO("1,2",STRING(par_inpessoa)) THEN 
                    DO:
                        ASSIGN aux_dscritic = "Tipo de pessoa invalido."
                               par_nmdcampo = "inpessoa".
                        LEAVE Valida.
                    END.

                FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                   crapass.nrdconta = par_nrctadeb
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               par_nmdcampo = "nrctadeb".
                        LEAVE Valida.
                    END.

                FIND crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                                   crapatr.nrdconta = par_nrctadeb AND
                                   crapatr.cdhistor = 585          AND
                                   crapatr.cdrefere = par_cdidenti AND
                                   crapatr.dtfimatr = ?
                                   NO-LOCK NO-ERROR.

                 IF  NOT AVAIL crapatr THEN
                     DO:
                        ASSIGN aux_dscritic = "Autorizacao nao cadastrada na " +
                                              "tela AUTORI."
                               par_nmdcampo = "nrctadeb".
                        LEAVE Valida.
                     END.
                
            END.
            
        LEAVE Valida.
    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

/* ************************************************************************* */
/**               Validar valores para os codigos de pagamento              **/
/* ************************************************************************  */
PROCEDURE valida-valores:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cddpagto AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_vlrdinss AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_vlrjuros AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_vloutent AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nmrescop AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_vlrtotal AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsobserv AS CHAR                                       NO-UNDO.
    DEF VAR aux_verdbaut AS LOGICAL                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdcampo = "".

    Valida: DO WHILE TRUE:

        ASSIGN par_vlrtotal = par_vlrdinss + par_vlrjuros + par_vloutent.

         /** Valor deve ser zero para estes codigos **/
        IF  CAN-DO("1759,2020,2119,2143,2216,2240,2615,2712,2810,2879," +
                  "2917,2976,3000,3107", STRING (par_cddpagto))        THEN
            DO:
                IF  par_vlrdinss > 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "Valor INSS nao deve ser " +
                                              "informado para este codigo."
                               par_nmdcampo = "vlrdinss".
                        LEAVE Valida.
                    END.
            END.
        ELSE
        /* Valor INSS eh opcional para estes codigos e obrig para os outros */
        IF  NOT CAN-DO("1201,2011,2445,2437",STRING(par_cddpagto))  AND
            par_vlrdinss = 0 THEN
            DO:
                ASSIGN aux_dscritic = "Valor INSS deve ser maior do que zero."
                       par_nmdcampo = "vlrdinss".
                LEAVE Valida.
            END.

        IF  par_vlrtotal  < 10 THEN
            DO:
                ASSIGN aux_dscritic = "Valor total da guia deve ser " +
                                      "maior ou igual a R$ 10,00."
                       par_nmdcampo = "vlrdinss".
                LEAVE Valida.
            END.

        RUN dbo/b1crap82.p PERSISTENT SET h-b1crap82.
        /* Passado parametro agencia 999 p/diferenciar do caixa on-line */
        RUN valida-valor-entidades IN h-b1crap82
            ( INPUT STRING(par_cdcooper),
              INPUT 999,
              INPUT 0,
              INPUT INT(par_cddpagto),
              INPUT par_vloutent,
             OUTPUT aux_dsobserv,
             OUTPUT aux_verdbaut ).

        IF  aux_verdbaut = TRUE THEN
            DO:
                ASSIGN aux_dscritic = aux_dsobserv
                       par_nmdcampo = "vlrdinss".
                LEAVE Valida.
            END.
        /* Passado parametro 888 p/diferenciar do caixa on-line e da MOVGPS */
        RUN valida-atm-juros IN h-b1crap82
            ( INPUT STRING(par_nmrescop),
              INPUT 888,
              INPUT 0,
              INPUT par_cddpagto,
              INPUT 0,
              INPUT 0,
              INPUT par_vlrjuros,
              INPUT 0,
             OUTPUT aux_dsobserv,
             OUTPUT aux_verdbaut ).

        IF  aux_verdbaut = TRUE  THEN
            DO:
                ASSIGN aux_dscritic = aux_dsobserv
                       par_nmdcampo = "vlrdinss".
                LEAVE Valida.
            END.

        DELETE PROCEDURE h-b1crap82.

        LEAVE Valida.
    END.
    
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.



/* ************************************************************************* */
/**              Validacoes no processo de alteracao/inserção               **/
/* ************************************************************************  */
PROCEDURE valida-ins:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdidenti AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cddpagto AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_posvalid AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_inpessoa AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_flgconti AS LOGI                              NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_flgconti = TRUE
           par_nmdcampo = "".

    Valida: DO WHILE TRUE:

        IF  par_posvalid = 1 THEN
            DO:
                IF  par_cdidenti = 0   THEN
                    DO:
                        ASSIGN aux_dscritic = "Numero do identificador nao " +
                                              "pode ser zero.".
                        LEAVE Valida.
                    END.
            END.
        ELSE
        IF  par_posvalid = 2 OR par_posvalid = 3 THEN
            DO:
                FIND crapgps WHERE
                     crapgps.cddpagto = par_cddpagto NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapgps   THEN
                    DO:
                        ASSIGN aux_dscritic = "Codigo de pagamento invalido."
                               par_nmdcampo = (IF par_posvalid = 2 THEN 
                                                  "flgrgatv" ELSE "cddpagto").
                        LEAVE Valida.
                    END.

                IF  NOT crapgps.flgativo   THEN
                    DO:
                        ASSIGN aux_dscritic =
                                    "O codigo de pagamento """                +
                                    STRING(par_cddpagto) + """ nao pode ser " +
                                    "recebido pela cooperativa."
                               par_nmdcampo = (IF par_posvalid = 2 THEN 
                                                  "flgrgatv" ELSE "cddpagto").
                        LEAVE Valida.
                    END.

                IF  par_posvalid = 3 THEN
                    DO:
                        FIND crapcgp WHERE crapcgp.cdcooper = par_cdcooper   AND
                                           crapcgp.cdidenti = par_cdidenti   AND
                                           crapcgp.cddpagto = par_cddpagto
                                           NO-LOCK NO-ERROR.

                        IF  AVAILABLE crapcgp  THEN
                            DO:
                                ASSIGN aux_cdcritic = 854
                                       par_nmdcampo = "cddpagto".
                                LEAVE Valida.
                            END.
                    END.
            END.
        ELSE
        IF  par_posvalid = 4 THEN
            DO:
                FIND crapass WHERE
                     crapass.cdcooper = par_cdcooper  AND
                     crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapass THEN
                    DO:
                        ASSIGN par_flgconti = FALSE.
                        LEAVE Valida.
                    END.

                ASSIGN par_inpessoa = crapass.inpessoa.

                LEAVE Valida.
            END.

        LEAVE Valida.
    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/* ************************************************************************* */
/**                          Valida identificador                           **/
/** Utilizada também no zoom_guias.p                                        **/
/* ************************************************************************  */
PROCEDURE valida-identificador:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdidenti AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cddpagto AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdsomas AS INTE                                       NO-UNDO.
    DEF VAR aux_cdidenti AS CHAR  FORMAT "x(15)"                       NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGI                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdcampo = "".

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RUN sistema/generico/procedures/b1wgen9999.p
            PERSISTENT SET h-b1wgen9999.

    Valida: DO WHILE TRUE:
                    /* CNPJ */
        IF  CAN-DO("2003,2011,2020,2100,2119,2127,2143,2305,2402,2437,2445," +
                   "2500,2550,2607,2615,2631,2640,2909,2917,2950,2976,3000," +
                   "4103,4316,4332,5037,5045,5053,5061,5070,5088,5096,5100," +
                   "5118,5126,5134,6408,6602,6670,6700,6742,7307,7315,8214," +
                   "8303,8346,8362,8400,8443,8605,8907,8940,9105,9202,9601",
                   STRING(par_cddpagto)) THEN
            DO:
                RUN valida-cnpj IN h-b1wgen9999
                    ( INPUT par_cdidenti,
                     OUTPUT aux_stsnrcal ).

                IF  NOT aux_stsnrcal  THEN
                    DO:
                        ASSIGN aux_dscritic = "Identificador-CNPJ invalido " +
                                              "para o codigo de pagamento."
                               par_nmdcampo = "cdidenti".
                        LEAVE Valida.
                    END.
            END.
        ELSE         /* CEI */
        IF  CAN-DO("2208,2216,2240,2321,2429,3107,2704,2712,2658,2682,2801" +
                   ",2810,2852,2879,6432,6629",STRING(par_cddpagto))  THEN
            DO:
                ASSIGN aux_cdidenti = STRING(par_cdidenti).

                IF  LENGTH(aux_cdidenti) < 13  THEN
                    DO:
                        DO WHILE LENGTH(aux_cdidenti) <> 12:
                            ASSIGN aux_cdidenti = FILL("0",1) + aux_cdidenti.
                        END.

                        IF  INT(SUBSTR(aux_cdidenti,1,2))  <  0   OR
                           (INT(SUBSTR(aux_cdidenti,11,1)) <> 6   AND
                            INT(SUBSTR(aux_cdidenti,11,1)) <> 7   AND
                            INT(SUBSTR(aux_cdidenti,11,1)) <> 8   AND
                            INT(SUBSTR(aux_cdidenti,11,1)) <> 9   AND
                            INT(SUBSTR(aux_cdidenti,11,1)) <> 0)  THEN
                            DO:
                                ASSIGN aux_dscritic =
                                             "Identificador-CEI invalido para"
                                             + " o codigo de pagamento."
                                       par_nmdcampo = "cdidenti".
                                 LEAVE Valida.
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_nrdsomas =
                                           INT(SUBSTR(aux_cdidenti,1,1)) * 7 +
                                           INT(SUBSTR(aux_cdidenti,2,1)) * 4 +
                                           INT(SUBSTR(aux_cdidenti,3,1)) * 1 +
                                           INT(SUBSTR(aux_cdidenti,4,1)) * 8 +
                                           INT(SUBSTR(aux_cdidenti,5,1)) * 5 +
                                           INT(SUBSTR(aux_cdidenti,6,1)) * 2 +
                                           INT(SUBSTR(aux_cdidenti,7,1)) * 1 +
                                           INT(SUBSTR(aux_cdidenti,8,1)) * 6 +
                                           INT(SUBSTR(aux_cdidenti,9,1)) * 3 +
                                           INT(SUBSTR(aux_cdidenti,10,1)) * 7 +
                                           INT(SUBSTR(aux_cdidenti,11,1)) * 4.

                                IF  LENGTH(STRING(aux_nrdsomas)) = 3  THEN
                                    ASSIGN aux_nrdsomas =
                                        INT(SUBSTR(STRING(aux_nrdsomas),2,1)) +
                                        INT(SUBSTR(STRING(aux_nrdsomas),3,1)).

                                ELSE
                                    ASSIGN aux_nrdsomas =
                                        INT(SUBSTR(STRING(aux_nrdsomas),1,1)) +
                                        INT(SUBSTR(STRING(aux_nrdsomas),2,1)).

                                IF  LENGTH(STRING(aux_nrdsomas)) = 2   THEN
                                    ASSIGN aux_nrdsomas =
                                        INT(SUBSTR(STRING(aux_nrdsomas),2,1)).

                                IF  aux_nrdsomas <> 0   THEN
                                    ASSIGN aux_nrdsomas = 10 - aux_nrdsomas.

                                IF  aux_nrdsomas <>
                                    INT(SUBSTR(aux_cdidenti,12,1))  THEN
                                    DO:
                                        ASSIGN aux_dscritic =
                                                   "Identificador-CEI digito" +
                                                   " verificador invalido."
                                               par_nmdcampo = "cdidenti".
                                        LEAVE Valida.
                                    END.

                                ASSIGN aux_nrdsomas = 0.

                            END.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_dscritic = "Identificador-CEI invalido " +
                                              "para o codigo de pagamento."
                               par_nmdcampo = "cdidenti".
                        LEAVE Valida.
                    END.
            END.
        ELSE        /* DEBCAD */
        IF  CAN-DO("1201,3204,4006,6440",STRING(par_cddpagto))   THEN
            DO:

                RUN dig_fun IN h-b1wgen9999
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT-OUTPUT par_cdidenti,
                     OUTPUT TABLE tt-erro ).

                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro THEN
                            DO:
                                ASSIGN aux_dscritic =
                                             "Identificador-DEBCAD invalido " +
                                             "para o codigo de pagamento."
                                       par_nmdcampo = "cdidenti".
                                LEAVE Valida.
                            END.
                    END.
            END.
        ELSE        /*NIT/PIS/PASEP*/
        IF  CAN-DO("1007,1104,1120,1147,1163,1180,1406,1457,1473,1490,1503," +
                   "1554,1600,1651,1708,1759,6467",STRING(par_cddpagto))  THEN
            DO:
                ASSIGN aux_cdidenti = STRING(par_cdidenti).

                IF  LENGTH(aux_cdidenti) < 12   THEN
                    DO:
                          /* coloca o/os zero/os que estao faltando */
                        DO WHILE LENGTH(aux_cdidenti) <> 11:
                            ASSIGN aux_cdidenti = FILL("0",1) + aux_cdidenti.
                        END.

                        ASSIGN aux_nrdsomas =
                                           INT(SUBSTR(aux_cdidenti,1,1))  * 3 +
                                           INT(SUBSTR(aux_cdidenti,2,1))  * 2 +
                                           INT(SUBSTR(aux_cdidenti,3,1))  * 9 +
                                           INT(SUBSTR(aux_cdidenti,4,1))  * 8 +
                                           INT(SUBSTR(aux_cdidenti,5,1))  * 7 +
                                           INT(SUBSTR(aux_cdidenti,6,1))  * 6 +
                                           INT(SUBSTR(aux_cdidenti,7,1))  * 5 +
                                           INT(SUBSTR(aux_cdidenti,8,1))  * 4 +
                                           INT(SUBSTR(aux_cdidenti,9,1))  * 3 +
                                           INT(SUBSTR(aux_cdidenti,10,1)) * 2
                               aux_nrdsomas = aux_nrdsomas MODULO 11
                               aux_nrdsomas = 11 - aux_nrdsomas.

                        IF  CAN-DO("10,11",STRING(aux_nrdsomas))  THEN
                            ASSIGN aux_nrdsomas = 0.

                        IF  aux_nrdsomas <> INT(SUBSTR(aux_cdidenti,11,1)) THEN
                            DO:
                                ASSIGN aux_dscritic =
                                               "Identificador-NIT/PIS/PASEP" +
                                               " digito verificador invalido."
                                       par_nmdcampo = "cdidenti".
                                LEAVE Valida.
                            END.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_dscritic =
                                      "Identificador-NIT/PIS/PASEP invalido " +
                                      "para o codigo de pagamento."
                               par_nmdcampo = "cdidenti".
                        LEAVE Valida.
                    END.
            END.
        ELSE        /* N*" do titulo */
        IF  CAN-DO("4200,4308,4324,4995",STRING(par_cddpagto))  THEN
            DO:
                RUN dig_fun IN h-b1wgen9999
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT-OUTPUT par_cdidenti,
                     OUTPUT TABLE tt-erro ).

                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro THEN
                            DO:
                                ASSIGN aux_dscritic =
                                        "Identificador-N. DO TITULO invalido " +
                                        "para o codigo de pagamento."
                                       par_nmdcampo = "cdidenti".
                                LEAVE Valida.
                            END.
                    END.
            END.
        ELSE        /* Referencia */
        IF  CAN-DO("6009,6106,6203,6300,6505,6513,8001,8109,8206,8257,8133," +
                   "8141,8150,8168,8176",STRING(par_cddpagto))   THEN
            DO:
                RUN dig_fun IN h-b1wgen9999
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT-OUTPUT par_cdidenti,
                     OUTPUT TABLE tt-erro ).

                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro THEN
                            DO:
                                ASSIGN aux_dscritic =
                                        "Identificador-REFERENCIA invalido " +
                                        "para o codigo de pagamento."
                                       par_nmdcampo = "cdidenti".
                                LEAVE Valida.
                            END.
                    END.
            END.
        ELSE        /* NB */
        IF  CAN-DO("6459,9008,9016,9113,9210",STRING(par_cddpagto))  THEN
            DO:
                ASSIGN aux_cdidenti = STRING(par_cdidenti).

                IF  LENGTH(aux_cdidenti) < 11 THEN
                    DO:
                        /* coloca o/os zero/os nas posicoes da frente */
                        DO WHILE LENGTH (aux_cdidenti) <> 10:
                            ASSIGN aux_cdidenti =  FILL("0",1) + aux_cdidenti.
                        END.

                        ASSIGN aux_nrdsomas =INT(SUBSTR(aux_cdidenti,1,1)) * 2 +
                                             INT(SUBSTR(aux_cdidenti,2,1)) * 9 +
                                             INT(SUBSTR(aux_cdidenti,3,1)) * 8 +
                                             INT(SUBSTR(aux_cdidenti,4,1)) * 7 +
                                             INT(SUBSTR(aux_cdidenti,5,1)) * 6 +
                                             INT(SUBSTR(aux_cdidenti,6,1)) * 5 +
                                             INT(SUBSTR(aux_cdidenti,7,1)) * 4 +
                                             INT(SUBSTR(aux_cdidenti,8,1)) * 3 +
                                             INT(SUBSTR(aux_cdidenti,9,1)) * 2
                               aux_nrdsomas =  aux_nrdsomas MODULO 11.

                        IF  CAN-DO("0,1",STRING(aux_nrdsomas))  THEN
                            ASSIGN aux_nrdsomas = 0.
                        ELSE
                            ASSIGN aux_nrdsomas  = 11 - aux_nrdsomas.

                        IF  aux_nrdsomas <> (INT(SUBSTR(aux_cdidenti,10,1)))
                            THEN
                            DO:
                                ASSIGN aux_dscritic = "Identificador-NB digito" +
                                                      " verificador invalido."
                                       par_nmdcampo = "cdidenti".
                                LEAVE Valida.
                            END.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_dscritic = "Identificador-NB invalido " +
                                              "para o codigo de pagamento."
                               par_nmdcampo = "cdidenti".
                        LEAVE Valida.
                    END.
            END.
        ELSE        /* CPF */
        IF  CAN-DO("6610,6718,6750,8222,8311,8354,8370,8419,8451,8915,8958," +
                   "9610",STRING(par_cddpagto))  THEN
            DO:
                RUN valida-cpf IN h-b1wgen9999
                    ( INPUT par_cdidenti,
                     OUTPUT aux_stsnrcal ).

                IF  NOT aux_stsnrcal  THEN
                    DO:
                        ASSIGN aux_dscritic = "Identificador-CPF invalido " +
                                              "para o codigo de pagamento."
                               par_nmdcampo = "cdidenti".
                        LEAVE Valida.
                    END.
            END.

        LEAVE Valida.
    END.

    IF  VALID-HANDLE(h-b1wgen9999)  THEN
        DELETE PROCEDURE h-b1wgen9999.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            EMPTY TEMP-TABLE tt-erro.

            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/* ************************************************************************* */
/**                           Validar dados gerais                          **/
/* ************************************************************************  */
PROCEDURE valida-dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.

    DEF  INPUT PARAM par_nrcpfcgc AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dsendres AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdufresd AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_stsnrcal AS LOGI                                       NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI                                       NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Valida: DO WHILE TRUE:

        IF  par_nrcpfcgc > 0   THEN
            DO:

                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                     RUN sistema/generico/procedures/b1wgen9999.p
                         PERSISTENT SET h-b1wgen9999.

                RUN valida-cpf-cnpj IN h-b1wgen9999
                    ( INPUT par_nrcpfcgc,
                     OUTPUT aux_stsnrcal,
                     OUTPUT aux_inpessoa ).

                IF  VALID-HANDLE(h-b1wgen9999)  THEN
                    DELETE PROCEDURE h-b1wgen9999.

                IF  NOT aux_stsnrcal   THEN
                    DO:
                        ASSIGN aux_cdcritic = 27
                               par_nmdcampo = "nrcpfcgc".
                        LEAVE Valida.
                    END.
            END.

        IF  par_nrdconta = 0 AND par_nrcepend <> 0  THEN
            DO:
                IF  NOT CAN-FIND(FIRST crapdne
                                 WHERE crapdne.nrceplog = par_nrcepend)
                    THEN
                    DO:
                        ASSIGN aux_dscritic = "CEP nao cadastrado."
                               par_nmdcampo = "nrcepend".
                        LEAVE Valida.
                    END.

                IF  par_dsendres = ""  THEN
                    DO:
                        ASSIGN aux_dscritic = "Endereco deve ser informado."
                               par_nmdcampo = "nrcepend".
                        LEAVE Valida.
                    END.

                IF  NOT CAN-FIND(FIRST crapdne
                                 WHERE crapdne.nrceplog = par_nrcepend
                                   AND (TRIM(par_dsendres) MATCHES
                                       ("*" + TRIM(crapdne.nmextlog) + "*")
                                    OR TRIM(par_dsendres) MATCHES
                                       ("*" + TRIM(crapdne.nmreslog) + "*"))) THEN
                    DO:
                        ASSIGN aux_dscritic = "Endereco nao pertence ao CEP."
                               par_nmdcampo = "par_nrcepen".
                        LEAVE Valida.
                    END.
                IF  LOOKUP(par_cdufresd,"AC,AL,AP,AM,BA,CE,DF,ES,GO," +
                           "MA,MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN," +
                           "RS,RO,RR,SC,SP,SE,TO") = 0 THEN
                    DO:
                       ASSIGN aux_cdcritic = 33.
                       LEAVE Valida.
                    END.

            END.

       LEAVE.

    END. /* Fim tratamento de criticas */

    IF   aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE proc-crialog:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cdidenti AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cddpagto AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgdbaut AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctadeb AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_vlrdinss AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_vloutent AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_vlrjuros AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_vlrtotal AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_tpcontri AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgrgatv AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.

    DEF VAR aux_cddopcao AS CHAR                                       NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    CASE par_cddopcao:
        WHEN "D" THEN ASSIGN aux_cddopcao = "Debito autorizado".
        WHEN "I" THEN ASSIGN aux_cddopcao = "Inclusao".
        OTHERWISE     ASSIGN aux_cddopcao = "Alteracao".
    END.

    IF   par_cddopcao = "D"   THEN
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " " +
                          STRING(TIME,"HH:MM:SS") + "' --> '"               +
                          " Operador "  + par_cdoperad                      +
                          " solicitou opcao " + par_cddopcao                +
                          " no Identificador "       + STRING(par_cdidenti) +
                          " com Codigo pgto "        + STRING(par_cddpagto) +
                          ". Colocou Debito autorizado como - "             +
                          STRING(par_flgdbaut, "SIM/NAO")                   +
                          " , Tp.natureza guia - " + STRING(par_inpessoa)   +
                          " , Conta/dv para debito - "                      +
                          STRING(par_nrctadeb, "zzzz,zzz,9")                +
                          " , Valor do INSS - "                             +
                          STRING(par_vlrdinss,"zz,zzz,zz9.99")              +
                          " , Valor outras entidades - "                    +
                          STRING(par_vloutent,"zz,zzz,zz9.99")              +
                          " , Valor ATM/Juros/Multa - "                     +
                          STRING(par_vlrjuros,"zz,zzz,zz9.99")              +
                          " , Valor total - "                               +
                          STRING(par_vlrtotal,"zz,zzz,zz9.99")              +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/log/cadgps.log").
    ELSE
    IF  par_cddopcao = "I"   THEN
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " " +
                          STRING(TIME,"HH:MM:SS") + "' --> '"               +
                          " Operador "  + par_cdoperad                      +
                          " solicitou opcao " + par_cddopcao                +
                          " do Identificador "       + STRING(par_cdidenti) +
                          " com Codigo pgto "        + STRING(par_cddpagto) +
                          " - Tipo "                 + STRING(par_tpcontri) +
                          " , Conta/Dv - "                                  +
                          STRING(par_nrdconta, "zzzz,zzz,9")                +
                          " , Seq. Ttl - "     + STRING(par_idseqttl)       +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/log/cadgps.log").
    ELSE
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " " +
                          STRING(TIME,"HH:MM:SS") + "' --> '"               +
                          " Operador "  + par_cdoperad                      +
                          " solicitou opcao " + par_cddopcao                +
                          " no Identificador "       + STRING(par_cdidenti) +
                          " com Codigo pgto "        + STRING(par_cddpagto) +
                          " - Tipo "                 + STRING(par_tpcontri) +
                          " , Conta/Dv - "                                  +
                          STRING(par_nrdconta, "zzzz,zzz,9")                +
                          " , Seq. Ttl - "     + STRING(par_idseqttl)       +
                          " , status Ativo - "                              +
                          STRING(par_flgrgatv, "SIM/NAO")                   +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/log/cadgps.log").
END PROCEDURE.


