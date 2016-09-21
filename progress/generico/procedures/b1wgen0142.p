/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0142.p
    Autor   : Gabriel Capoia (DB1)
    Data    : Novembro/2012                     Ultima atualizacao: 02/09/2014

    Objetivo  : Tranformacao BO tela CONINF.

    Alteracoes: 05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
    
                02/09/2014 - Carregar somente cooperativas ativas na procedure
                             pi_carrega_cooperativas (David).
                             
............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0142tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.

/*................................ PROCEDURES ..............................*/
/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA BOLETIM DE CAIXA                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Carrega_Tela:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmcooper AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmtpdcto AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsdircop AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-crapcop.
    DEF OUTPUT PARAM TABLE FOR tt-tpodcto.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapcop.
        EMPTY TEMP-TABLE tt-tpodcto.
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapcop WHERE
                          crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        ASSIGN par_dsdircop = crapcop.dsdircop.

        RUN pi_carrega_cooperativas
            (OUTPUT par_nmcooper,
             OUTPUT TABLE tt-crapcop).

        RUN pi_carrega_tipos_carta
             (OUTPUT par_nmtpdcto,
              OUTPUT TABLE tt-tpodcto).

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

END PROCEDURE. /* Busca_Dados */

PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoopea AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenca AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_indespac AS INTE  FORMAT "9"               NO-UNDO.
    DEF  INPUT PARAM par_cdfornec AS INTE  FORMAT "zzzz9"           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtol1 AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtol2 AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdsaida AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapinf.
    DEF OUTPUT PARAM TABLE FOR tt-crapinf-aux.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR pos_tpdocmto AS INTE                                     NO-UNDO.
    DEF VAR aux_nmtpdcto AS CHAR                                     NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
    
    DEF VAR aux_flgexist AS LOGI                                     NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_nrregist = par_nrregist
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Boletim de Caixa".
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapinf.
        EMPTY TEMP-TABLE tt-tpodcto.
        EMPTY TEMP-TABLE tt-erro.

        IF  par_dtmvtol1 = ? THEN
            DO:
                ASSIGN aux_dscritic = "Data inicial do periodo invalida."
                       aux_cdcritic = 0
                       par_nmdcampo = "dtmvtol1".
                LEAVE Busca.
            END.

        IF  par_dtmvtol2 = ? OR 
            par_dtmvtol2 < par_dtmvtol1 THEN
            DO:
                ASSIGN aux_dscritic = "Data final do periodo invalida."
                       aux_cdcritic = 0
                       par_nmdcampo = "dtmvtol2".
                LEAVE Busca.
            END.

        IF NOT (par_cdagenca <> 0 AND par_cdcooper <> 3 AND
                CAN-FIND(crapage WHERE crapage.cdcooper = par_cdcoopea  AND
                                       crapage.cdagenci = par_cdagenca) OR
                par_cdagenca = 0 OR par_cdcooper = 3) THEN
            DO:
                ASSIGN aux_dscritic = ""
                       aux_cdcritic = 15
                       par_nmdcampo = "cdagenca".
                LEAVE Busca.
            END.

        IF  NOT CAN-DO("0,1,2",STRING(par_indespac)) THEN
            DO:
                ASSIGN aux_dscritic = ""
                       aux_cdcritic = 14
                       par_nmdcampo = "indespac".
                LEAVE Busca.
            END.

        IF  NOT CAN-DO("0,1,2",STRING(par_cdfornec)) THEN
            DO:
                ASSIGN aux_dscritic = ""
                       aux_cdcritic = 14
                       par_nmdcampo = "cdfornec".
                LEAVE Busca.
            END.

        RUN pi_carrega_tipos_carta
             (OUTPUT aux_nmtpdcto,
              OUTPUT TABLE tt-tpodcto).

        /* Carrega na temp-table cooperativa selecionada ou TODAS */
        IF  par_cdcoopea = 0 THEN
            DO:
                FOR EACH crapcop NO-LOCK:
                    CREATE tt-crapcop.
                    BUFFER-COPY crapcop TO tt-crapcop.
                END.
            END.
        ELSE 
            DO:
                FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcoopea NO-LOCK: END.

                IF  AVAIL crapcop THEN
                    DO:
                        CREATE tt-crapcop.
                        BUFFER-COPY crapcop TO tt-crapcop.
                        RELEASE crapcop.
                    END.
            END.

        FOR EACH tt-crapcop:

            FOR EACH crapinf WHERE
                     crapinf.cdcooper  = tt-crapcop.cdcooper AND
                     crapinf.dtmvtolt >= par_dtmvtol1        AND
                     crapinf.dtmvtolt <= par_dtmvtol2        NO-LOCK
                     BY crapinf.cdcooper
                         BY crapinf.dtmvtolt
                             BY crapinf.cdagenci:

                IF  (par_cdagenca <> 0 AND crapinf.cdagenci <> par_cdagenca) OR
                    (par_tpdocmto <> 0 AND crapinf.tpdocmto <> par_tpdocmto) OR
                    (par_indespac <> 0 AND crapinf.indespac <> par_indespac) OR
                    (par_cdfornec <> 0 AND crapinf.cdfornec <> par_cdfornec) THEN
                    NEXT.

                FIND tt-crapinf WHERE
                     tt-crapinf.cdcooper = crapinf.cdcooper AND 
                     tt-crapinf.dtmvtolt = crapinf.dtmvtolt AND
                     tt-crapinf.cdagenci = crapinf.cdagenci AND 
                     tt-crapinf.tpdocmto = crapinf.tpdocmto AND 
                     tt-crapinf.indespac = crapinf.indespac AND 
                     tt-crapinf.cdfornec = crapinf.cdfornec NO-ERROR.

                IF  NOT AVAIL tt-crapinf THEN
                    DO:

                        CREATE tt-crapinf.
                        BUFFER-COPY crapinf TO tt-crapinf
                        ASSIGN tt-crapinf.nmrescop = tt-crapcop.nmrescop
                               pos_tpdocmto        = LOOKUP(STRING(crapinf.tpdocmto),
                                                      aux_nmtpdcto) - 1
                               tt-crapinf.dstpdcto = ENTRY(pos_tpdocmto,aux_nmtpdcto).

                        CASE tt-crapinf.indespac:
                            WHEN 1 THEN ASSIGN tt-crapinf.dsdespac = "Correio".
                            WHEN 2 THEN ASSIGN tt-crapinf.dsdespac = "Balcao".
                        END CASE.

                        CASE tt-crapinf.cdfornec:
                            WHEN 1 THEN ASSIGN tt-crapinf.nmfornec = "Postmix".
                            WHEN 2 THEN ASSIGN tt-crapinf.nmfornec = "Engecopy".
                        END CASE.        
                        
                    END. /* IF  NOT AVAIL tt-crapinf */

                ASSIGN tt-crapinf.qtinform = tt-crapinf.qtinform + 1.

            END. /* FOR EACH crapinf */

        END. /* FOR EACH tt-crapcop */

        IF  par_tpdsaida THEN /* Arquivo */
            DO:
                FOR FIRST crapcop WHERE
                          crapcop.cdcooper = par_cdcooper NO-LOCK: END.

                IF  NOT AVAILABLE crapcop  THEN
                    DO: 
                        ASSIGN aux_cdcritic = 651
                               aux_dscritic = "".
                        LEAVE Busca.
                    END.

                ASSIGN aux_nmendter = "/micros/" + crapcop.dsdircop + "/" + par_dsiduser
                       aux_nmarqimp = aux_nmendter + ".csv".
                
                OUTPUT TO VALUE(aux_nmarqimp).

                PUT UNFORMATTED 
                    "Cooperativa;Data;PA;Tipo Carta;Quantidade;Destino;" +
                    "Fornecedor" SKIP.

                ASSIGN aux_flgexist = FALSE.

                FOR EACH tt-crapinf: 

                    PUT tt-crapinf.cdcooper ";"
                        tt-crapinf.dtmvtolt ";"
                        tt-crapinf.cdagenci ";"
                        tt-crapinf.dstpdcto FORMAT "X(31)"  ";"
                        tt-crapinf.qtinform ";"
                        tt-crapinf.dsdespac ";"
                        tt-crapinf.nmfornec SKIP.

                    ASSIGN aux_flgexist = TRUE.

                END. /* FOR EACH tt-crapinf */

                OUTPUT CLOSE.

                IF  NOT aux_flgexist  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nenhum informativo encontrado."
                               aux_cdcritic = 0.
                        LEAVE Busca.
                    END.

            END. /* IF  par_tpdsaida */
        ELSE
            DO:
                IF  NOT TEMP-TABLE tt-crapinf:HAS-RECORDS THEN
                    DO:
                        ASSIGN aux_dscritic = "Nenhum informativo encontrado."
                               aux_cdcritic = 0.
                        LEAVE Busca.
                    END.


                IF  par_idorigem = 5 AND /* Se ayllos web e não gera arquivo */
                    NOT par_tpdsaida THEN
                    RUN pi_paginacao
                        (INPUT par_nrregist,
                         INPUT par_nriniseq,
                         INPUT TABLE tt-crapinf,
                         OUTPUT par_qtregist,
                         OUTPUT TABLE tt-crapinf-aux).

            END.
            
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
            ELSE
                DO:
                    FIND FIRST tt-erro NO-ERROR.

                    IF  AVAIL tt-erro THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                END.

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

/*............................. PROCEDURES INTERNAS .........................*/

PROCEDURE pi_paginacao:

    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-crapinf.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapinf-aux.

    ASSIGN aux_nrregist = par_nrregist.

    Pagina: DO ON ERROR UNDO Pagina, LEAVE Pagina:
        EMPTY TEMP-TABLE tt-crapinf-aux.

        FOR EACH tt-crapinf:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginação */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                    CREATE tt-crapinf-aux.
                    BUFFER-COPY tt-crapinf TO tt-crapinf-aux.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

    END. /* Pagina */

    RETURN "OK".

END PROCEDURE. /*pi_paginacao*/

PROCEDURE pi_carrega_cooperativas:

    DEF OUTPUT PARAM par_nmcooper AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcop.

    Coop: DO ON ERROR UNDO Coop, LEAVE Coop:
        EMPTY TEMP-TABLE tt-crapcop.

        CREATE tt-crapcop.
        ASSIGN tt-crapcop.nmrescop = "TODAS"
               tt-crapcop.cdcooper = 0
               par_nmcooper = "TODAS,0".

        FOR EACH crapcop WHERE crapcop.cdcooper <> 3   AND
                               crapcop.flgativo = TRUE NO-LOCK:

            CREATE tt-crapcop.
            BUFFER-COPY crapcop TO tt-crapcop
            ASSIGN par_nmcooper = par_nmcooper           + "," +
                                  CAPS(crapcop.nmrescop) + "," +
                                  STRING(crapcop.cdcooper).
    
        END. /* FOR EACH crapcop */

        LEAVE Coop.

    END. /* Coop */

    RETURN "OK".

END PROCEDURE. /* pi_carrega_cooperativas */

PROCEDURE pi_carrega_tipos_carta:

    DEF OUTPUT PARAM aux_nmtpdcto AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-tpodcto.

    DEF VAR cont AS INTE NO-UNDO.

    Coop: DO ON ERROR UNDO Coop, LEAVE Coop:
        EMPTY TEMP-TABLE tt-tpodcto.

        ASSIGN aux_nmtpdcto = "TODOS,0,"                       + 
                          "269-Cartas de Inclusao no CCF,1,"   +
                          "166-Senhas Tele Atendimento,2,"     +
                          "273-Chegada de Cartao Magnetico,3," +
                          "136-Emprestimos Concedidos,4,"      +
                          "Convite Progrid,5,"             + 
                          "056-Recibo Deposito Cooperativo,6," + 
                          "171-Extrato de Conta Corrente,7,"   + 
                          "410-Credito de Sobras,8,"           +
                          "359-Emprestimo em Atraso,10,"       +
                          "174-Extrato Aplicacao RDCA,11,"     +
                          "174-Extrato Aplic. P.Programada,12," +
                          "173/193/204-Aviso Debito C/C,13".

        DO cont = 1 TO NUM-ENTRIES(aux_nmtpdcto) BY 2 :

            CREATE tt-tpodcto.
            ASSIGN tt-tpodcto.nmtpdcto = ENTRY(cont,aux_nmtpdcto) 
                   tt-tpodcto.tpdocmto = INT(ENTRY(cont + 1,aux_nmtpdcto)).
        END.

        LEAVE Coop.

    END. /* Busca */

    
    
    RETURN "OK".

END PROCEDURE. /* pi_carrega_cooperativas */

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/
