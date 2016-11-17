/*..............................................................................
    
   Programa: b1wgen0013.p                  
   Autora  : Guilherme / SUPERO
   Data    : 20/02/2013                        Ultima atualizacao: 05/03/2014

   Dados referentes ao programa:

   Objetivo  : BO CONSULTA DE LOGs DE ACESSO A TELAS

   Alteracoes: 05/03/2014 - Incluso VALIDATE (Daniel).
   
               12/08/2015 - Ajustes de performance, utilizacao de FIELDS para 
                            trazer apenas campos utilizados. (Jorge/Julio)

..............................................................................*/
 
{ sistema/generico/includes/b1wgen0013tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
           
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.


/*............................................................................*/



PROCEDURE consulta-cooperativas:
    
    DEF OUTPUT PARAM TABLE FOR tt-cooper.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-cooper.
    EMPTY TEMP-TABLE tt-erro.
    
    FOR EACH crapcop FIELDS(crapcop.cdcooper
                            crapcop.nmrescop) NO-LOCK
        BY crapcop.nmrescop:

        CREATE tt-cooper.
        ASSIGN tt-cooper.cdcooper = crapcop.cdcooper
               tt-cooper.nmrescop = CAPS(crapcop.nmrescop).
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE registra-log-acesso-telas:
    DEF INPUT  PARAM par_cdcooper      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dsdatela      AS CHAR                        NO-UNDO.
    DEF INPUT  PARAM par_idorigem      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_cdoperad      AS CHAR                        NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt      AS DATE                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR          aux_hracesso      AS INT                         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /** Nao cria registro com informacao incompleta **/
    IF  par_cdcooper = 0 THEN  RETURN "OK".

    IF  par_cdcooper = 0
    OR  par_dsdatela = ""
    OR  par_cdoperad = ""
    OR  par_idorigem = 0
    OR  par_dtmvtolt = ? THEN RETURN "OK".

    IF NOT CAN-FIND(LAST craptel
                   WHERE craptel.cdcooper = par_cdcooper
                     AND craptel.nmdatela = TRIM(CAPS(par_dsdatela))
                     NO-LOCK) THEN RETURN "OK".
       
    /** Verificar se registro ja existe */
    ASSIGN aux_hracesso = TIME.

    IF  CAN-FIND(LAST  craplgt NO-LOCK
        WHERE craplgt.cdcooper = par_cdcooper
          AND craplgt.nmdatela = TRIM(CAPS(par_dsdatela))
          AND craplgt.dtmvtolt = par_dtmvtolt
          AND craplgt.idorigem = par_idorigem
          AND craplgt.cdoperad = par_cdoperad
          AND craplgt.hracesso = aux_hracesso) THEN
          /* Se ja existe para o mesmo segundo, nao cria */
          RETURN "OK".

    /** Feito TRANSACTION apenas para contornar a situacao
        do PKGDESEN pois ocorre registros duplicados pois 
        a data do sistema nao se altera                   **/
    DO TRANSACTION ON ERROR UNDO, RETURN "NOK":
        CREATE craplgt.
        ASSIGN craplgt.cdcooper = par_cdcooper
               craplgt.nmdatela = TRIM(CAPS(par_dsdatela))
               craplgt.dtmvtolt = par_dtmvtolt
               craplgt.idorigem = par_idorigem
               craplgt.cdoperad = par_cdoperad
               craplgt.hracesso = aux_hracesso NO-ERROR.
        VALIDATE craplgt.

        IF  ERROR-STATUS:ERROR THEN
            UNDO.
        
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE consulta-nunca-acessados:

    DEF INPUT  PARAM par_cdcooper      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_idorigem      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dtrefini      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_dtreffim      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_nriniseq      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrregist      AS INTE                        NO-UNDO.
    DEF OUTPUT PARAM par_qtdregis      AS INTE                        NO-UNDO.


    DEF OUTPUT PARAM TABLE FOR tt-resultados.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-resultados.

    DEF VAR aux_cdcooper  AS INT                                      NO-UNDO.
    DEF VAR aux_dsorigem  AS CHAR                                     NO-UNDO.
    DEF VAR aux_contador  AS INT                                      NO-UNDO.
    DEF VAR aux_qtdregis  AS INT                                      NO-UNDO.


    IF  par_cdcooper = 99 THEN
        aux_cdcooper = 1.
    ELSE
        aux_cdcooper = par_cdcooper.


    FOR EACH crapcop FIELDS(crapcop.cdcooper
                            crapcop.nmrescop) NO-LOCK
       WHERE crapcop.cdcooper >= aux_cdcooper
         AND crapcop.cdcooper <= par_cdcooper
          BY crapcop.nmrescop:
    
        FOR EACH craptel FIELDS(craptel.cdcooper
                                craptel.nmdatela) NO-LOCK
           WHERE craptel.cdcooper = crapcop.cdcooper
             AND craptel.flgtelbl = TRUE                 
             AND craptel.nmrotina = "" /* APENAS OS PAIS */
           ,EACH crapprg
           WHERE crapprg.cdcooper = craptel.cdcooper
             AND crapprg.nmsistem = "CRED"
             AND crapprg.cdprogra = craptel.nmdatela
              BY craptel.nmdatela:


            IF  par_idorigem = 0 THEN DO:
                /** VERIFICA SE TEM LOG PARA AYLLOS CARACTER (idorigem = 1) */
                RUN cria-valida-log (INPUT craptel.cdcooper,
                                     INPUT craptel.nmdatela,
                                     INPUT 1, /* Ayllos Caracter */
                                     INPUT crapcop.nmrescop,
                                     INPUT 3, /* Tipo "Nunca" */
                                     INPUT par_dtrefini,
                                     INPUT par_dtreffim,
                                     INPUT 0,
                                     INPUT 0).

                /** VERIFICA SE TEM LOG PARA AYLLOS WEB (idorigem = 2) */
                RUN cria-valida-log (INPUT craptel.cdcooper,
                                     INPUT craptel.nmdatela,
                                     INPUT 2, /* Ayllos Web */
                                     INPUT crapcop.nmrescop,
                                     INPUT 3, /* Tipo "Nunca" */
                                     INPUT par_dtrefini,
                                     INPUT par_dtreffim,
                                     INPUT 0,
                                     INPUT 0).
            END.
            ELSE DO:
                RUN cria-valida-log (INPUT craptel.cdcooper,
                                     INPUT craptel.nmdatela,
                                     INPUT par_idorigem,
                                     INPUT crapcop.nmrescop,
                                     INPUT 3, /* Tipo "Nunca" */
                                     INPUT par_dtrefini,
                                     INPUT par_dtreffim,
                                     INPUT 0,
                                     INPUT 0).
            END.
        END. /* FIM FOR EACH craptel */
    END. /* FIM FOR EACH crapcop */


    RUN executa-paginacao (INPUT par_nriniseq,
                           INPUT par_nrregist,
                           INPUT TABLE tt-resulta,
                          OUTPUT par_qtdregis,
                          OUTPUT TABLE tt-resultados).

    RETURN "OK".

END PROCEDURE.


PROCEDURE consulta-nao-acessadas:

    DEF INPUT  PARAM par_cdcooper      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dsdatela      AS CHAR                        NO-UNDO.
    DEF INPUT  PARAM par_idorigem      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dtrefini      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_dtreffim      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_nriniseq      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrregist      AS INTE                        NO-UNDO.
    DEF OUTPUT PARAM par_qtdregis      AS INTE                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-resultados.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-resultados.

    DEF VAR aux_cdcooper  AS INT                                      NO-UNDO.
    DEF VAR aux_dsorigem  AS CHAR                                     NO-UNDO.
    DEF VAR aux_contador  AS INT                                      NO-UNDO.
    DEF VAR aux_qtdregis  AS INT                                      NO-UNDO.


    IF  par_cdcooper = 99 THEN
        aux_cdcooper = 1.
    ELSE
        aux_cdcooper = par_cdcooper.


    FOR EACH crapcop FIELDS(crapcop.cdcooper
                            crapcop.nmrescop) NO-LOCK
       WHERE crapcop.cdcooper >= aux_cdcooper
         AND crapcop.cdcooper <= par_cdcooper
          BY crapcop.nmrescop:
    
        FOR EACH craptel FIELDS(craptel.cdcooper
                                craptel.nmdatela) NO-LOCK
           WHERE craptel.cdcooper = crapcop.cdcooper
             AND craptel.flgtelbl = TRUE                 
             AND craptel.nmrotina = "" /* APENAS OS PAIS */
             AND (craptel.nmdatela = par_dsdatela OR
                      par_dsdatela = "")
           ,EACH crapprg
           WHERE crapprg.cdcooper = craptel.cdcooper
             AND crapprg.nmsistem = "CRED"
             AND crapprg.cdprogra = craptel.nmdatela
              BY craptel.nmdatela:


            IF  par_idorigem = 0 THEN DO:
                /** VERIFICA SE TEM LOG PARA AYLLOS CARACTER (idorigem = 1) */
                RUN cria-valida-log (INPUT craptel.cdcooper,
                                     INPUT craptel.nmdatela,
                                     INPUT 1, /* Ayllos Caracter */
                                     INPUT crapcop.nmrescop,
                                     INPUT 2, /* Tipo "Nao Acessadas" */
                                     INPUT par_dtrefini,
                                     INPUT par_dtreffim,
                                     INPUT 0,
                                     INPUT 0).

                /** VERIFICA SE TEM LOG PARA AYLLOS WEB (idorigem = 2) */
                RUN cria-valida-log (INPUT craptel.cdcooper,
                                     INPUT craptel.nmdatela,
                                     INPUT 2, /* Ayllos Web */
                                     INPUT crapcop.nmrescop,
                                     INPUT 2, /* Tipo "Nao Acessadas" */
                                     INPUT par_dtrefini,
                                     INPUT par_dtreffim,
                                     INPUT 0,
                                     INPUT 0).
            END.
            ELSE DO:
                RUN cria-valida-log (INPUT craptel.cdcooper,
                                     INPUT craptel.nmdatela,
                                     INPUT par_idorigem,
                                     INPUT crapcop.nmrescop,
                                     INPUT 2, /* Tipo "Nao Acessadas" */
                                     INPUT par_dtrefini,
                                     INPUT par_dtreffim,
                                     INPUT 0,
                                     INPUT 0).
            END.
        END. /* FIM FOR EACH craptel */
    END. /* FIM FOR EACH crapcop */


    RUN executa-paginacao (INPUT par_nriniseq,
                           INPUT par_nrregist,
                           INPUT TABLE tt-resulta,
                          OUTPUT par_qtdregis,
                          OUTPUT TABLE tt-resultados).

    RETURN "OK".

END PROCEDURE.



PROCEDURE consulta-acessadas:

    DEF INPUT  PARAM par_cdcooper      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dsdatela      AS CHAR                        NO-UNDO.
    DEF INPUT  PARAM par_idorigem      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dtrefini      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_dtreffim      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_nriniseq      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrregist      AS INTE                        NO-UNDO.

    DEF OUTPUT PARAM par_qtdregis      AS INTE                        NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-resultados.
    DEF OUTPUT PARAM TABLE FOR tt-detalhes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcooper  AS INT                                      NO-UNDO.
    DEF VAR aux_dsorigem  AS CHAR                                     NO-UNDO.
    DEF VAR aux_contador  AS INT                                      NO-UNDO.
    DEF VAR aux_qtdregis  AS INT                                      NO-UNDO.
    DEF VAR aux_qtdusers  AS INT                                      NO-UNDO.
    DEF VAR aux_qtdacess  AS INT                                      NO-UNDO.
    DEF VAR aux_rowid     AS CHAR                                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-resultados.

    IF  par_cdcooper = 99 THEN
        aux_cdcooper = 1.
    ELSE
        aux_cdcooper = par_cdcooper.

    FOR EACH crapcop FIELDS(crapcop.cdcooper
                            crapcop.nmrescop) NO-LOCK
       WHERE crapcop.cdcooper >= aux_cdcooper
         AND crapcop.cdcooper <= par_cdcooper
          BY crapcop.nmrescop:

        FOR EACH  craplgt FIELDS(craplgt.cdcooper
                                 craplgt.nmdatela
                                 craplgt.cdoperad
                                 craplgt.idorigem) NO-LOCK
           WHERE  craplgt.cdcooper =  crapcop.cdcooper
             AND (craplgt.nmdatela =  par_dsdatela OR
                  par_dsdatela     =  "")
             AND  craplgt.dtmvtolt >= par_dtrefini
             AND  craplgt.dtmvtolt <= par_dtreffim
             AND (craplgt.idorigem =  par_idorigem OR
                  par_idorigem =  0)
           BREAK BY craplgt.cdcooper
                 BY craplgt.nmdatela
                 BY craplgt.idorigem
                 BY craplgt.cdoperad
                 BY craplgt.dtmvtolt:

            IF  FIRST-OF(craplgt.cdoperad) THEN DO:
   
                IF  FIRST-OF(craplgt.nmdatela) THEN
                    ASSIGN aux_qtdusers = 1.
                ELSE
                    ASSIGN aux_qtdusers = aux_qtdusers + 1.

            END.


            FIND FIRST tt-resulta EXCLUSIVE-LOCK
                 WHERE tt-resulta.dsdatela = craplgt.nmdatela
                   AND tt-resulta.cdcooper = craplgt.cdcooper
                   AND tt-resulta.idorigem = craplgt.idorigem
              NO-ERROR.
            
            IF  NOT AVAIL tt-resulta THEN DO:

                IF  craplgt.idorigem = 1 THEN
                    ASSIGN aux_dsorigem = "Ayllos Caracter".
                ELSE
                    ASSIGN aux_dsorigem = "Ayllos Web".

                CREATE tt-resulta.
                
                ASSIGN aux_rowid = STRING(ROWID(tt-resulta)).
                ASSIGN tt-resulta.rowid    = aux_rowid
                       tt-resulta.idresult = 1 /* Log Acessadas */
                       tt-resulta.dsdatela = CAPS(craplgt.nmdatela)
                       tt-resulta.cdcooper = craplgt.cdcooper
                       tt-resulta.dscooper = crapcop.nmrescop
                       tt-resulta.idorigem = craplgt.idorigem
                       tt-resulta.dsorigem = aux_dsorigem
                       tt-resulta.qtdusuar = aux_qtdusers
                       tt-resulta.qtdacess = 1.
            END.
            ELSE
                ASSIGN tt-resulta.qtdacess = tt-resulta.qtdacess + 1
                       tt-resulta.qtdusuar = aux_qtdusers
                       aux_rowid           = tt-resulta.rowid.

            IF  LAST-OF(craplgt.idorigem) THEN
                ASSIGN aux_qtdusers = 0
                       aux_rowid    = "".


        END. /* FIM FOR EACH craplgt */

    END. /* FIM FOR EACH crapcop */

    RUN executa-paginacao (INPUT par_nriniseq,
                           INPUT par_nrregist,
                           INPUT TABLE tt-resulta,
                          OUTPUT par_qtdregis,
                          OUTPUT TABLE tt-resultados).

    RETURN "OK".

END PROCEDURE.


PROCEDURE executa-paginacao:
    
    DEF INPUT  PARAM par_nriniseq      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrregist      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM TABLE FOR tt-resulta.
    DEF OUTPUT PARAM par_qtdregis      AS INT                         NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-resultados.

    DEF VAR aux_contador  AS INT                                      NO-UNDO.
    DEF VAR aux_qtdregis  AS INT                                      NO-UNDO.

    FOR EACH tt-resulta NO-LOCK:

        ASSIGN aux_contador = aux_contador + 1.
        ASSIGN par_qtdregis = par_qtdregis + 1.
          
        IF  (aux_contador < par_nriniseq OR
             aux_contador > (par_nriniseq + par_nrregist)) THEN NEXT.

        IF aux_qtdregis = par_nrregist THEN NEXT.

        ASSIGN aux_qtdregis = aux_qtdregis + 1.

        CREATE tt-resultados.
        BUFFER-COPY tt-resulta TO tt-resultados.

    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE exibe-detalhes:

    DEF INPUT  PARAM par_cdcooper      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dsdatela      AS CHAR                        NO-UNDO.
    DEF INPUT  PARAM par_idorigem      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dtrefini      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_dtreffim      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_nriniseq      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrregist      AS INTE                        NO-UNDO.
    
    DEF OUTPUT PARAM par_qtdregis      AS INTE                        NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-detalhe-pesquisa.
    DEF OUTPUT PARAM TABLE FOR tt-detalhes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmoperad      AS CHAR                                 NO-UNDO.
    DEF VAR aux_indachou      AS LOGI INIT FALSE                      NO-UNDO.

    EMPTY TEMP-TABLE tt-detalhe-pesquisa.

    FOR EACH craplgt FIELDS(craplgt.cdcooper
                            craplgt.nmdatela
                            craplgt.idorigem
                            craplgt.cdoperad) NO-LOCK
       WHERE craplgt.cdcooper =  par_cdcooper
         AND craplgt.nmdatela =  par_dsdatela
         AND craplgt.idorigem =  par_idorigem
         AND craplgt.dtmvtolt >= par_dtrefini
         AND craplgt.dtmvtolt <= par_dtreffim
          BY craplgt.cdcooper
          BY craplgt.nmdatela
          BY craplgt.idorigem
          BY craplgt.cdoperad:

        ASSIGN aux_indachou = FALSE.
        FOR FIRST tt-detalhes FIELDS(tt-detalhes.qtdacess) EXCLUSIVE-LOCK
             WHERE tt-detalhes.dsdatela = craplgt.nmdatela
               AND tt-detalhes.cdcooper = craplgt.cdcooper
               AND tt-detalhes.idorigem = craplgt.idorigem
               AND tt-detalhes.cdoperad = craplgt.cdoperad:
            ASSIGN aux_indachou = TRUE
                   tt-detalhes.qtdacess = tt-detalhes.qtdacess + 1.
        END.
            
        IF  NOT aux_indachou THEN DO:
            ASSIGN aux_indachou = FALSE.
            FOR FIRST crapope FIELDS(crapope.nmoperad)
                WHERE crapope.cdcooper = craplgt.cdcooper
                  AND crapope.cdoperad = craplgt.cdoperad
                  NO-LOCK:
                ASSIGN aux_indachou = TRUE
                       aux_nmoperad = crapope.nmoperad.
            END.
            IF  NOT aux_indachou THEN
                aux_nmoperad = "OPERADOR NAO ENCONTRADO".

            IF  craplgt.idorigem = 1 THEN
                ASSIGN aux_dsorigem = "Ayllos Caracter".
            ELSE
                ASSIGN aux_dsorigem = "Ayllos Web".

            FOR FIRST crapcop FIELDS(crapcop.cdcooper
                                     crapcop.nmrescop)
                WHERE crapcop.cdcooper = par_cdcooper
                NO-LOCK:
                CREATE tt-detalhes.
                ASSIGN tt-detalhes.dsdatela = CAPS(craplgt.nmdatela)
                       tt-detalhes.cdcooper = craplgt.cdcooper
                       tt-detalhes.dscooper = crapcop.nmrescop
                       tt-detalhes.cdoperad = craplgt.cdoperad
                       tt-detalhes.nmoperad = aux_nmoperad
                       tt-detalhes.idorigem = craplgt.idorigem
                       tt-detalhes.dsorigem = aux_dsorigem
                       tt-detalhes.qtdacess = 1.
            END.
        END.
    END.
    
    RUN executa-paginacao-detalhe (INPUT par_nriniseq,
                                   INPUT par_nrregist,
                                   INPUT TABLE tt-detalhes,
                                  OUTPUT par_qtdregis,
                                  OUTPUT TABLE tt-detalhe-pesquisa).

    RETURN "OK".
    
END PROCEDURE.


PROCEDURE executa-paginacao-detalhe:
    
    DEF INPUT  PARAM par_nriniseq      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrregist      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM TABLE FOR tt-detalhes.
    DEF OUTPUT PARAM par_qtdregis      AS INT                         NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-detalhe-pesquisa.

    DEF VAR aux_contador  AS INT                                      NO-UNDO.
    DEF VAR aux_qtdregis  AS INT                                      NO-UNDO.

    FOR EACH tt-detalhes NO-LOCK:

        ASSIGN aux_contador = aux_contador + 1.
        ASSIGN par_qtdregis = par_qtdregis + 1.
          
        IF  (aux_contador < par_nriniseq OR
             aux_contador > (par_nriniseq + par_nrregist)) THEN NEXT.

        IF aux_qtdregis = par_nrregist THEN NEXT.

        ASSIGN aux_qtdregis = aux_qtdregis + 1.

        CREATE tt-detalhe-pesquisa.
        BUFFER-COPY tt-detalhes TO tt-detalhe-pesquisa.

    END.

END PROCEDURE.


PROCEDURE cria-valida-log:
    DEF INPUT  PARAM par_cdcooper      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nmdatela      AS CHAR                        NO-UNDO.
    DEF INPUT  PARAM par_idorigem      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nmrescop      AS CHAR                        NO-UNDO.
    DEF INPUT  PARAM par_idpesqui      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dtrefini      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_dtreffim      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_qtdusuar      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_qtdacess      AS INTE                        NO-UNDO.

    DEF VAR aux_indachou               AS LOGI INIT FALSE             NO-UNDO.
    
    /* Nao Acessadas   */
    IF par_idpesqui = 2 THEN
    DO:
        IF CAN-FIND(LAST craplgt
                   WHERE craplgt.cdcooper =  par_cdcooper
                     AND craplgt.nmdatela =  par_nmdatela
                     AND craplgt.idorigem =  par_idorigem
                     AND craplgt.dtmvtolt >= par_dtrefini 
                     AND craplgt.dtmvtolt <= par_dtreffim
                     NO-LOCK) THEN
            ASSIGN aux_indachou = TRUE.
    END.
    ELSE IF par_idpesqui = 3 THEN  /* nunca acessadas */
    DO:
        IF CAN-FIND(LAST craplgt WHERE craplgt.cdcooper = par_cdcooper
                                   AND craplgt.nmdatela = par_nmdatela
                                   AND craplgt.idorigem = par_idorigem
                                   NO-LOCK)  THEN
            ASSIGN aux_indachou = TRUE.
    END.
    
    IF  NOT aux_indachou THEN DO:
        
        IF NOT CAN-FIND(LAST tt-resulta NO-LOCK
                       WHERE tt-resulta.dsdatela = par_nmdatela
                         AND tt-resulta.cdcooper = par_cdcooper
                         AND tt-resulta.idorigem = par_idorigem) THEN
        DO:
            IF  par_idorigem = 1 THEN
                ASSIGN aux_dsorigem = "Ayllos Caracter".
            ELSE
                ASSIGN aux_dsorigem = "Ayllos Web".

            CREATE tt-resulta.
            ASSIGN tt-resulta.idresult = par_idpesqui
                   tt-resulta.dsdatela = CAPS(par_nmdatela)
                   tt-resulta.cdcooper = par_cdcooper
                   tt-resulta.dscooper = par_nmrescop
                   tt-resulta.idorigem = par_idorigem
                   tt-resulta.dsorigem = aux_dsorigem
                   tt-resulta.qtdusuar = par_qtdusuar
                   tt-resulta.qtdacess = par_qtdacess.
        END.
    END.

END PROCEDURE.
