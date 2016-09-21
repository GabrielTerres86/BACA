
/******************************************************************************
*                                                                             *
*   Programa: b1wgen0187.p                                                    *
*   Autor   : Jorge I. Hamaguchi                                              *
*   Data    : Março/2014                    Ultima atualizacao: 00/00/0000    *
*                                                                             *
*   Dados referentes ao programa:                                             *
*                                                                             *
*   Objetivo  : BO Referente a tela DEVDOC "Devolucao de documentos"          *
*                                                                             *
*   Alteracoes:                                                               *
*                                                                             *
******************************************************************************/

{ sistema/generico/includes/b1wgen0187tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

PROCEDURE busca_crapddc:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtoan AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtodc AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_nrregist AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nriniseq AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapddc.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapddc.

    DEF VAR aux_nrregist AS INTE                                       NO-UNDO.
    
    ASSIGN aux_nrregist = par_nrregist.
    
    FOR EACH crapddc WHERE crapddc.cdcooper = par_cdcooper
                       AND crapddc.dtmvtolt = par_dtmvtoan
                       NO-LOCK:
        
        ASSIGN par_qtregist = par_qtregist + 1.

        /* controles da paginação */
        IF  (par_qtregist < par_nriniseq) OR
            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
            NEXT.

        /* controles da paginação */
        IF  (par_qtregist > (par_nriniseq + par_nrregist)) THEN
            NEXT.

        IF  aux_nrregist > 0 THEN
            DO: 
                FIND FIRST crapope
                     WHERE crapope.cdcooper = par_cdcooper 
                       AND crapope.cdoperad = crapddc.cdoperad
                       NO-LOCK NO-ERROR.
                IF NOT AVAIL crapope THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro ao buscar operador.".
            
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.

                CREATE tt-crapddc.
                BUFFER-COPY crapddc TO tt-crapddc.
                ASSIGN tt-crapddc.nmoperad = crapope.nmoperad.
            END.

        ASSIGN aux_nrregist = aux_nrregist - 1.

    END.

    RETURN "OK".

END.

PROCEDURE atualiza_doc:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdocmto AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtodc AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_vldocmto AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_cdbandoc AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagedoc AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrctadoc AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_cdmotdev AS INTE                              NO-UNDO.
                                                                               
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR ant_cdmotdev AS INTE                                       NO-UNDO.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                 NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapcop) THEN
        RETURN "NOK".

    IF NOT CAN-DO("51,52,53,56,57,58,59,62,66,67",STRING(par_cdmotdev)) THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Codigo do motivo invalido.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    FIND crapddc WHERE crapddc.cdcooper = par_cdcooper
                   AND crapddc.nrdocmto = par_nrdocmto
                   AND crapddc.dtmvtolt = par_dtmvtodc
                   AND crapddc.vldocmto = par_vldocmto
                   AND crapddc.cdbandoc = par_cdbandoc
                   AND crapddc.cdagedoc = par_cdagedoc
                   AND crapddc.nrctadoc = par_nrctadoc
                   EXCLUSIVE-LOCK NO-ERROR.
    
    IF NOT AVAIL crapddc THEN
    DO:
        IF NOT CAN-FIND(FIRST crapddc 
                        WHERE crapddc.cdcooper = par_cdcooper
                          AND crapddc.nrdocmto = par_nrdocmto
                          AND crapddc.dtmvtolt = par_dtmvtodc
                          AND crapddc.vldocmto = par_vldocmto
                          AND crapddc.cdbandoc = par_cdbandoc
                          AND crapddc.cdagedoc = par_cdagedoc
                          AND crapddc.nrctadoc = par_nrctadoc) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Documento nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
        ELSE
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Mais de um documento encontrado com esses " +
                                  "parametros.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    END.
    

    ASSIGN  ant_cdmotdev     = crapddc.cdmotdev
            crapddc.cdmotdev = par_cdmotdev.

    IF TRIM(crapddc.dslayout) <> "" THEN
       SUBSTRING(crapddc.dslayout,239,2) = STRING(par_cdmotdev).
    
    UNIX SILENT
         VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
         " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
         "Operador " + par_cdoperad                        +
         " alterou o documento " + STRING(par_nrdocmto)    +
         " de valor R$ " + STRING(par_vldocmto)            +
         " no campo codigo do motivo de " + STRING(ant_cdmotdev) +
         " para  " + STRING(par_cdmotdev)                  +
         " >> /usr/coop/" + TRIM(crapcop.dsdircop)         + 
         "/log/devdoc.log").

    RETURN "OK".
END.

PROCEDURE consulta_doc:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdocmto AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtodc AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_vldocmto AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_cdbandoc AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagedoc AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrctadoc AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_cdmotdev AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapddc.

    DEF VAR aux_cdcritic AS INTE                                      NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapddc.
    
    /* verificar se Nao existe registro desse documento ou se existe mais de um */
    FIND crapddc WHERE crapddc.cdcooper = par_cdcooper
                   AND crapddc.nrdocmto = par_nrdocmto
                   AND crapddc.dtmvtolt = par_dtmvtodc
                   AND crapddc.vldocmto = par_vldocmto
                   AND crapddc.cdbandoc = par_cdbandoc
                   AND crapddc.cdagedoc = par_cdagedoc
                   AND crapddc.nrctadoc = par_nrctadoc
                   AND crapddc.cdmotdev = par_cdmotdev
                   NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapddc THEN
    DO:
        /* verificar se o registro existe*/
        IF NOT CAN-FIND(FIRST crapddc 
                        WHERE crapddc.cdcooper = par_cdcooper
                          AND crapddc.nrdocmto = par_nrdocmto
                          AND crapddc.dtmvtolt = par_dtmvtodc
                          AND crapddc.vldocmto = par_vldocmto
                          AND crapddc.cdbandoc = par_cdbandoc
                          AND crapddc.cdagedoc = par_cdagedoc
                          AND crapddc.nrctadoc = par_nrctadoc
                          AND crapddc.cdmotdev = par_cdmotdev) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Documento nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
        ELSE
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Mais de um documento encontrado com esses " +
                                  "parametros.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    END.
        
    CREATE tt-crapddc.
    BUFFER-COPY crapddc TO tt-crapddc.

    RETURN "OK".

END.

PROCEDURE salva_docs:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_documtos AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                      NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.
    DEF VAR aux_nrdocmto AS DECI                                      NO-UNDO.
    DEF VAR aux_dtmvtodc AS DATE                                      NO-UNDO.
    DEF VAR aux_vldocmto AS DECI                                      NO-UNDO.
    DEF VAR aux_cdbandoc AS INTE                                      NO-UNDO.
    DEF VAR aux_cdagedoc AS INTE                                      NO-UNDO.
    DEF VAR aux_nrctadoc AS DECI                                      NO-UNDO.
    DEF VAR aux_cdmotdev AS INTE                                      NO-UNDO.
    DEF VAR aux_contador AS INTE                                      NO-UNDO.
    DEF VAR aux_nmcampos AS CHAR                                      NO-UNDO.
    DEF VAR aux_devolver AS INTE                                      NO-UNDO.
    DEF VAR ant_flgdevol AS LOGI                                      NO-UNDO.
    DEF VAR aux_dsdevolu AS CHAR                                      NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapcop THEN
        RETURN "NOK".

    /* Faz um loop dos documentos vindos da pagina web */
    DO aux_contador = 1 TO NUM-ENTRIES(par_documtos,"*"):

        ASSIGN aux_nmcampos = ENTRY(aux_contador,par_documtos,"*")
               aux_nrdocmto = DECI(ENTRY(1,aux_nmcampos,"|"))
               aux_dtmvtodc = DATE(ENTRY(2,aux_nmcampos,"|"))
               aux_vldocmto = DECI(ENTRY(3,aux_nmcampos,"|"))
               aux_cdbandoc = INTE(ENTRY(4,aux_nmcampos,"|"))
               aux_cdagedoc = INTE(ENTRY(5,aux_nmcampos,"|"))
               aux_nrctadoc = DECI(ENTRY(6,aux_nmcampos,"|"))
               aux_cdmotdev = INTE(ENTRY(7,aux_nmcampos,"|"))
               aux_devolver = INTE(ENTRY(8,aux_nmcampos,"|")).

        FIND crapddc WHERE crapddc.cdcooper = par_cdcooper
                       AND crapddc.nrdocmto = aux_nrdocmto
                       AND crapddc.dtmvtolt = aux_dtmvtodc
                       AND crapddc.vldocmto = aux_vldocmto
                       AND crapddc.cdbandoc = aux_cdbandoc
                       AND crapddc.cdagedoc = aux_cdagedoc
                       AND crapddc.nrctadoc = aux_nrctadoc
                       AND crapddc.cdmotdev = aux_cdmotdev
                       EXCLUSIVE-LOCK NO-ERROR.
        
        /* se nao achar ou tiver mais de um registro com os parmetros */
        IF NOT AVAIL crapddc THEN
        DO:
            /* se nao achar nenhum registro */
            IF NOT CAN-FIND(FIRST crapddc 
                            WHERE crapddc.cdcooper = par_cdcooper
                              AND crapddc.nrdocmto = aux_nrdocmto
                              AND crapddc.dtmvtolt = aux_dtmvtodc
                              AND crapddc.vldocmto = aux_vldocmto
                              AND crapddc.cdbandoc = aux_cdbandoc
                              AND crapddc.cdagedoc = aux_cdagedoc
                              AND crapddc.nrctadoc = aux_nrctadoc
                              AND crapddc.cdmotdev = aux_cdmotdev) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Documento nao encontrado.".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
            ELSE /* senao vai existir mais de um registro com os parametros */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Mais de um documento encontrado com " +
                                      "esses parametros.".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
        END.
        
        ASSIGN ant_flgdevol = crapddc.flgdevol.

        /* se chegou aki, encontrou o registro e unico, 
           atualiza  para enviar ou nao enviar*/
        IF aux_devolver = 0 THEN
            ASSIGN crapddc.flgdevol = FALSE.
        ELSE
            ASSIGN crapddc.flgdevol = TRUE.

        /* se alterou a flag de devolucao cria log */
        IF (ant_flgdevol AND aux_devolver = 0)  OR 
           (NOT ant_flgdevol AND aux_devolver = 1) THEN
        DO:
            IF  ant_flgdevol THEN
                ASSIGN aux_dsdevolu = "NAO DEVOLVER".
            ELSE
                ASSIGN aux_dsdevolu = "DEVOLVER".

            UNIX SILENT
                 VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                 " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                 "Operador " + par_cdoperad                        +
                 " alterou o documento " + STRING(aux_nrdocmto)    +
                 " de valor R$ " + STRING(aux_vldocmto)            +
                 " para  " + aux_dsdevolu                          +
                 " >> /usr/coop/" + TRIM(crapcop.dsdircop)         + 
                 "/log/devdoc.log").
        END.
    END.
    
    RETURN "OK".

END.
