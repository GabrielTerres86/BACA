/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0144.p
    Autor   : Gabriel Capoia (DB1)
    Data    : 17/]/2012                     Ultima atualizacao: 14/08/2015

    Objetivo  : Tranformacao BO tela PESQDP.

    Alteracoes: 24/06/2013 - Correção do diretório do arquivo da impressão
                             do relatório. Correção de alinhamento do relatório:
                             alterada a impressão de cdbccxlt por dsbccxlt.
                             (Carlos)
                             
                18/07/2013 - Criada procedure alimenta_capturado (Reinert).
                
                12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                04/06/2014 - Adicionado campo cdagedst na tt-crapchd na 
                             procedure Busca_Dados. (Reinert) 
                             
                27/06/2014 - Adicionada procedure Gera_Relatorio_Devolvidos.
                             (Reinert)
                             
                14/08/2015 - Removidos todos os campos da tela menos os campos
 				    		 Data do Deposito e Valor do cheque. Adicionado novos 
                             campos para filtro, numero de conta e numero de 
                             cheque, conforme solicitado na melhoria 300189 (Kelvin)                            
                                 
............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0144tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR aux_dsbccxlt AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9998 AS HANDLE                                      NO-UNDO.

DEF VAR rel_qtdtotal AS INTE                                        NO-UNDO.
DEF VAR rel_vlrtotal AS DECI                                        NO-UNDO.

FORM "Data"          AT 01
     "PA"            AT 13
     "Conta/DV"      AT 20
     "Tipo"          AT 31
     "Compe"         AT 41
     "Banco"         AT 48
     "Conta Cheque"  AT 57
     "Cheque"        AT 72
     "CMC7"          AT 80
     "Valor"         AT 126
     SKIP(1)
     WITH WIDTH 150 NO-BOX NO-LABELS OVERLAY FRAME f_cab_detalhes_rel.

FORM tt-crapchd.dtmvtolt  AT 01  NO-LABEL     
     tt-crapchd.cdagenci  AT 13  NO-LABEL     
     tt-crapchd.nrdconta  AT 18  NO-LABEL      
     tt-crapchd.dsbccxlt  AT 31  NO-LABEL  FORMAT "x(08)"
     tt-crapchd.cdcmpchq  AT 41  NO-LABEL
     tt-crapchd.cdbanchq  AT 48  NO-LABEL
     tt-crapchd.nrctachq  AT 53  NO-LABEL
     tt-crapchd.nrcheque  AT 71  NO-LABEL     
     tt-crapchd.dsdocmc7  AT 80  NO-LABEL  FORMAT "x(34)"   
     tt-crapchd.vlcheque  AT 117 NO-LABEL  FORMAT "zzz,zzz,zz9.99"   
     WITH WIDTH 132 NO-BOX SIDE-LABELS OVERLAY FRAME f_detalhes_rel.

FORM SKIP(1)
     "TOTAL GERAL  --------> "  AT 01 
     rel_qtdtotal               AT 95  NO-LABEL  FORMAT "zzzzzz,zz9"
     rel_vlrtotal               AT 110 NO-LABEL  format "zzzzzz,zzz,zzz,zz9.99"
     WITH WIDTH 132 NO-BOX SIDE-LABELS OVERLAY FRAME f_total_rel.

FORM tt-crapddi.cdageaco     AT 2
     tt-crapddi.cdagedst     AT 16
     tt-crapddi.nrdconta     AT 23 
     tt-crapddi.cdbanchq     AT 39 
     tt-crapddi.nrcheque     AT 45 
     tt-crapddi.cdalinea     AT 57 
     tt-crapddi.dtdeposi     AT 65
     tt-crapddi.vlcheque     AT 77
     WITH WIDTH 132 NO-BOX NO-LABEL OVERLAY FRAME f_chq_devolvidos.

FORM
    "PA ACL."                AT 01 
    "Age. Destino"           AT 09
    "Conta/DV"               AT 25
    "Banco Chq."             AT 34 
    "Cheque"                 AT 48 
    "Alinea"                 AT 55 
    "Data deposito"          AT 62               
    "Valor"                  AT 93
    SKIP                    
    "-------"                AT 01 
    "-------------"          AT 09 
    "----------"             AT 23 
    "----------"             AT 34 
    "---------"              AT 45 
    "------"                 AT 55 
    "-------------"          AT 62     
    "----------------------" AT 76
    SKIP
    WITH WIDTH 132 NO-BOX NO-LABEL OVERLAY FRAME f_cab_chq_devolvidos.
     
  
/*................................ PROCEDURES ..............................*/
/* ------------------------------------------------------------------------ */
/*                 EFETUA A PESQUISA DE CHEQUES DEPOSITADOS                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtola AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tipocons AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_vlcheque AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrcheque AS DECI FORMAT "zzzzzzzzzz"       NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocmc7 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapchd.
    DEF OUTPUT PARAM TABLE FOR tt-crapchd-aux.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_lsdigctr AS CHAR                                    NO-UNDO.


    MESSAGE "cdcooper: " + STRING(par_cdcooper) + " | " + 
            "cdagenci: " + STRING(par_cdagenci) + " | " + 
            "nrdcaixa: " + STRING(par_nrdcaixa) + " | " + 
            "cdoperad: " + STRING(par_cdoperad) + " | " + 
            "nmdatela: " + STRING(par_nmdatela) + " | " + 
            "idorigem: " + STRING(par_idorigem) + " | " + 
            "dtmvtola: " + STRING(par_dtmvtola) + " | " + 
            "tipocons: " + STRING(par_tipocons) + " | " + 
            "vlcheque: " + STRING(par_vlcheque) + " | " + 
            "nrcheque: " + STRING(par_nrcheque) + " | " + 
            "nrdconta: " + STRING(par_nrdconta) + " | " + 
            "dsdocmc7: " + STRING(par_dsdocmc7) + " | " + 
            "nrregist: " + STRING(par_nrregist) + " | " + 
            "nriniseq: " + STRING(par_nriniseq) + " | " + 
            "flgerlog: " + STRING(par_flgerlog) + " | " + 
            "dtmvtolt: " + STRING(par_dtmvtolt) + " | " + 
            "qtregist: " + STRING(par_qtregist) + " | " + 
            "nmdcampo: " + STRING(par_nmdcampo)
        VIEW-AS ALERT-BOX INFO BUTTONS OK.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_nrregist = par_nrregist
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Pesquisa de Cheques Depositados"
           par_nmdcampo = "".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapchd.
        EMPTY TEMP-TABLE tt-crapchd-aux.
        EMPTY TEMP-TABLE tt-erro.
        
        IF  par_dtmvtola > par_dtmvtolt THEN
            DO: 
                ASSIGN aux_cdcritic = 13
                       par_nmdcampo = "dtmvtola"
                       aux_dscritic = "".
                
                LEAVE Busca.
            END.
        
        IF  par_dtmvtola = ? THEN
            DO: 
                ASSIGN aux_cdcritic = 0
                       par_nmdcampo = "dtmvtola"
                       aux_dscritic = "A Data do deposito deve ser preenchida!".

                LEAVE Busca.
            END.
        
        IF  WEEKDAY(par_dtmvtola) = 1 OR
            WEEKDAY(par_dtmvtola) = 7 OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                   crapfer.dtferiad = par_dtmvtola) THEN
            DO: 
                ASSIGN aux_cdcritic = 13
                       par_nmdcampo = "dtmvtola"
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        IF  par_tipocons THEN DO:

            IF NOT par_vlcheque > 0 THEN
               DO:
                    ASSIGN aux_cdcritic = 269
                           par_nmdcampo = "vlcheque"
                           aux_dscritic = "".
                    LEAVE Busca.
               END.

            FOR FIRST crapcop FIELDS(cdagectl)
                              WHERE crapcop.cdcooper = par_cdcooper
                              NO-LOCK:
            END.

            FOR EACH crapchd WHERE
                     crapchd.cdcooper  = par_cdcooper AND
                     crapchd.dtmvtolt =  par_dtmvtola AND
                     crapchd.vlcheque >= par_vlcheque AND
                     (IF par_nrcheque <> 0 THEN
                      crapchd.nrcheque = par_nrcheque ELSE 
                      crapchd.nrcheque > 0)           AND 
                     (IF par_nrdconta <> 0 THEN
                      crapchd.nrdconta = par_nrdconta ELSE 
                      crapchd.nrdconta > 0) NO-LOCK,
                EACH crapban WHERE
                     crapban.cdbccxlt = crapchd.cdbanchq NO-LOCK
                     BY crapchd.vlcheque
                        BY crapban.nmresbcc
                           BY crapchd.cdagenci
                              BY crapchd.nrdconta
                                 BY crapchd.nrcheque:

                RUN alimenta_capturado(INPUT crapchd.cdbccxlt,
                                       INPUT crapchd.nrdolote).

                CREATE tt-crapchd.
                BUFFER-COPY crapchd TO tt-crapchd
                ASSIGN tt-crapchd.nmresbcc = crapban.nmresbcc
                       tt-crapchd.cdbccxlt = crapban.cdbccxlt
                       tt-crapchd.nmextbcc = crapban.nmextbcc
                       tt-crapchd.dsbccxlt = aux_dsbccxlt
                       tt-crapchd.nrdconta = IF crapchd.nrdconta = 0 THEN
                                                crapchd.nrctadst
                                             ELSE
                                                crapchd.nrdconta.

                IF  tt-crapchd.cdagedst = 0 THEN
                    ASSIGN tt-crapchd.cdagedst = crapcop.cdagectl.
    
            END. /* FIM FOR EACH crapchd */
    
            IF  NOT TEMP-TABLE tt-crapchd:HAS-RECORDS THEN
                DO:
                    ASSIGN aux_cdcritic = 244
                           aux_dscritic = "".
                    LEAVE Busca.
                END.

        END. /* IF  par_tipocons */
        ELSE DO:

            IF  NOT VALID-HANDLE(h-b1wgen9998) THEN
                RUN sistema/generico/procedures/b1wgen9998.p
                    PERSISTENT SET h-b1wgen9998.

            RUN dig_cmc7 IN h-b1wgen9998
                       ( INPUT par_dsdocmc7,
                        OUTPUT par_nmdcampo,
                        OUTPUT aux_lsdigctr).
            IF  VALID-HANDLE(h-b1wgen9998) THEN
                DELETE OBJECT h-b1wgen9998.

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    ASSIGN aux_cdcritic = 666
                           aux_dscritic = "".
                    LEAVE Busca.
                END.

            FIND crapchd WHERE crapchd.cdcooper = par_cdcooper AND
                               crapchd.dtmvtolt = par_dtmvtola AND
                               crapchd.dsdocmc7 = par_dsdocmc7
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapchd THEN
                DO:
                    ASSIGN aux_cdcritic = 244
                           aux_dscritic = "".
                    LEAVE Busca.
                END.

            FIND crapban WHERE 
                 crapban.cdbccxlt = crapchd.cdbanchq
                 NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapban THEN
                DO:
                    ASSIGN aux_cdcritic = 57
                           aux_dscritic = "".
                    LEAVE Busca.
                END.

            RUN alimenta_capturado(INPUT crapchd.cdbccxlt,
                                   INPUT crapchd.nrdolote).

            FIND crapage WHERE 
                 crapage.cdcooper = par_cdcooper     AND 
                 crapage.cdagenci = crapchd.cdagenci
                 NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapage THEN
                DO:
                    ASSIGN aux_cdcritic = 15
                           aux_dscritic = "".
                    LEAVE Busca.
                END.

            FIND crapass WHERE 
                 crapass.cdcooper = par_cdcooper AND 
                 crapass.nrdconta = IF crapchd.nrdconta = 0 THEN
                                       crapchd.nrctadst
                                    ELSE
                                       crapchd.nrdconta
                 NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapass THEN
                DO:
                    ASSIGN aux_cdcritic = 9
                           aux_dscritic = "".
                    LEAVE Busca.
                END.

            CREATE tt-crapchd.
            BUFFER-COPY crapchd TO tt-crapchd
            ASSIGN tt-crapchd.nmextbcc = crapban.nmextbcc
                   tt-crapchd.cdbccxlt = crapban.cdbccxlt
                   tt-crapchd.nmextage = crapage.nmextage
                   tt-crapchd.nmresbcc = crapban.nmresbcc
                   tt-crapchd.nmprimtl = crapass.nmprimtl
                   tt-crapchd.dsbccxlt = aux_dsbccxlt.

        END. /* FIM ELSE */

        IF  par_idorigem = 5 THEN
            RUN pi_paginacao
                (INPUT par_nrregist,
                 INPUT par_nriniseq,
                 INPUT TABLE tt-crapchd,
                 OUTPUT par_qtregist,
                 OUTPUT TABLE tt-crapchd-aux).
        
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

PROCEDURE Gera_Relatorio_Devolvidos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtdevolu AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM par_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM par_nmarqpdf AS CHAR                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Impressão Pesquisa de Cheques Depositados".

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:

        IF  par_dtdevolu = ? OR 
            par_dtdevolu > par_dtmvtolt THEN
            DO:
                ASSIGN aux_cdcritic = 013
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                              par_dsiduser + STRING(TIME)
               par_nmarqimp = aux_nmendter + ".ex"
               par_nmarqpdf = aux_nmendter + ".pdf".               

        OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.
        /* cdempres = 11; cdrelato = 683; Quantidade de colunas =  132 */
        { sistema/generico/includes/cabrel.i "11" "683" "132" }

        VIEW STREAM str_1 FRAME f_cab_chq_devolvidos.

        /* Busca cheques acolhidos que foram devolvidos na coop de destino */ 
        FOR EACH crapddi WHERE crapddi.cdcopaco = par_cdcooper AND
                               crapddi.dtmvtolt = par_dtdevolu NO-LOCK:
            
            FOR FIRST crapchd WHERE crapchd.cdcooper = crapddi.cdcopaco AND
                                    crapchd.cdbanchq = crapddi.cdbanchq AND
                                    crapchd.cdagechq = crapddi.cdagechq AND
                                    crapchd.nrcheque = crapddi.nrcheque AND
                                    crapchd.nrctachq = crapddi.nrctachq 
                                    USE-INDEX crapchd4 NO-LOCK:
            END.

            CREATE tt-crapddi.
            ASSIGN tt-crapddi.cdageaco = crapchd.cdagenci WHEN AVAILABLE crapchd
                   tt-crapddi.cdagedst = crapchd.cdagedst WHEN AVAILABLE crapchd
                   tt-crapddi.nrdconta = crapddi.nrdconta
                   tt-crapddi.cdbanchq = crapddi.cdbanchq
                   tt-crapddi.nrcheque = crapddi.nrcheque
                   tt-crapddi.cdalinea = crapddi.cdalinea
                   tt-crapddi.nrdcaixa = INTEGER(SUBSTR(STRING(crapchd.nrdolote,"999999"),3,3)) WHEN AVAILABLE crapchd
                   tt-crapddi.dtdeposi = crapddi.dtdeposi
                   tt-crapddi.insitprv = crapchd.insitprv WHEN AVAILABLE crapchd
                   tt-crapddi.vlcheque = crapddi.vlcheque.
        END.

        FOR EACH tt-crapddi BY tt-crapddi.cdageaco:

            IF  LINE-COUNTER(str_1) > 80  THEN 
                DO: 
                    PAGE STREAM str_1.
                    DISPLAY STREAM str_1 WITH FRAME f_cab_chq_devolvidos.
                END.
            
            DISPLAY STREAM str_1
                    tt-crapddi.cdageaco
                    tt-crapddi.cdagedst
                    tt-crapddi.nrdconta
                    tt-crapddi.cdbanchq
                    tt-crapddi.nrcheque
                    tt-crapddi.cdalinea
                    tt-crapddi.dtdeposi
                    tt-crapddi.vlcheque WITH FRAME f_chq_devolvidos.

            DOWN WITH FRAME f_chq_devolvidos.

        END.

        OUTPUT STREAM str_1 CLOSE.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:                                
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Imprime.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_nmarqimp,
                     OUTPUT par_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.
        
        LEAVE Imprime.
    
    END. /* Imprime */

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

END PROCEDURE. /* Gera_Relatorio_Devolvidos */

/* ------------------------------------------------------------------------ */
/*                     GERA IMPRESSÃO CHEQUES DEPOSITADOS                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Relatorio:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtfim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdsaida AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF  OUTPUT PARAM aux_nrdcampo AS INTE                          NO-UNDO.
    DEF  OUTPUT PARAM par_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM par_nmarqpdf AS CHAR                          NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarquiv AS CHAR NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Impressão Pesquisa de Cheques Depositados".
    
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.


        IF par_dtmvtini = ? THEN
           DO: 
              ASSIGN aux_cdcritic = 013
                     aux_dscritic = "".
              LEAVE Imprime.
           END.

        IF par_dtmvtfim = ? THEN
           DO: 
              ASSIGN aux_cdcritic = 013
                     aux_dscritic = "".
              LEAVE Imprime.
           END.
        
        IF par_dtmvtini > par_dtmvtolt THEN
           DO: 
              ASSIGN aux_cdcritic = 013
                     aux_dscritic = "".
              LEAVE Imprime.
           END.
                     
        IF par_dtmvtfim < par_dtmvtini OR
           par_dtmvtfim > par_dtmvtolt  THEN
           DO: 
              ASSIGN aux_cdcritic = 013
                      aux_dscritic = "".
              LEAVE Imprime.
           END.

        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                              par_dsiduser + STRING(TIME)
               par_nmarqimp = aux_nmendter + ".ex"
               par_nmarqpdf = aux_nmendter + ".pdf"
            
               aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + par_dsiduser
               aux_nmarquiv = aux_nmarquiv + ".txt".
         
        OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.

        /* Cdempres = 11 , Relatorio 619 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "619" "132" }

        VIEW STREAM str_1 FRAME f_cab_detalhes_rel.

        CASE par_cdbccxlt:
            WHEN "0" THEN DO: /*TODOS*/

                FOR EACH crapchd NO-LOCK WHERE
                         crapchd.cdcooper  = par_cdcooper AND
                         crapchd.dtmvtolt >= par_dtmvtini AND
                         crapchd.dtmvtolt <= par_dtmvtfim AND
                        (crapchd.cdbccxlt  = 11  OR
                         crapchd.cdbccxlt  = 500 OR
                         crapchd.cdbccxlt  = 600 OR
                         crapchd.cdbccxlt  = 700)
                         BY crapchd.dtmvtolt:

                    RUN cria_tabela_temporaria.
                END.

            END.

            WHEN "1" THEN DO: /*CAIXA*/  

                FOR EACH crapchd NO-LOCK WHERE
                         crapchd.cdcooper  = par_cdcooper AND
                         crapchd.dtmvtolt >= par_dtmvtini AND
                         crapchd.dtmvtolt <= par_dtmvtfim AND 
                         crapchd.cdbccxlt = 11            AND
                        (crapchd.nrdolote <= 30000 OR
                         crapchd.nrdolote >= 30999)
                         BY crapchd.dtmvtolt:

                    RUN cria_tabela_temporaria.

                END.

            END.

            WHEN "2" THEN DO: /*CUSTODIA*/

                FOR EACH crapchd NO-LOCK WHERE
                         crapchd.cdcooper  = par_cdcooper AND
                         crapchd.dtmvtolt >= par_dtmvtini AND
                         crapchd.dtmvtolt <= par_dtmvtfim AND 
                         crapchd.cdbccxlt = 600
                         BY crapchd.dtmvtolt:

                    RUN cria_tabela_temporaria.

                END.

            END.

            WHEN "3" THEN DO: /*DESCONTO*/
                
                FOR EACH crapchd NO-LOCK WHERE
                         crapchd.cdcooper  = par_cdcooper AND
                         crapchd.dtmvtolt >= par_dtmvtini AND
                         crapchd.dtmvtolt <= par_dtmvtfim AND 
                         crapchd.cdbccxlt = 700
                         BY crapchd.dtmvtolt:

                    RUN cria_tabela_temporaria.

                END.

            END.

            WHEN "4" THEN DO: /*LANCHQ*/
                
                FOR EACH crapchd NO-LOCK WHERE
                         crapchd.cdcooper  = par_cdcooper AND
                         crapchd.dtmvtolt >= par_dtmvtini AND
                         crapchd.dtmvtolt <= par_dtmvtfim AND 
                         crapchd.cdbccxlt = (IF  crapchd.nrdolote > 30000 AND
                                                 crapchd.nrdolote < 30999 THEN 11
                                             ELSE 500)
                         BY crapchd.dtmvtolt:

                    RUN cria_tabela_temporaria.

                END.

            END.

        END CASE.

        FOR EACH tt-crapchd
            BREAK BY tt-crapchd.dtmvtolt
                      BY tt-crapchd.cdagenci:

            IF  LINE-COUNTER(str_1) > 80  THEN 
                DO: 
                    PAGE STREAM str_1.
                    DISPLAY STREAM str_1 WITH FRAME f_cab_detalhes_rel.
                END.

            DISPLAY STREAM str_1 
                    tt-crapchd.dtmvtolt tt-crapchd.cdagenci tt-crapchd.nrdconta
                    tt-crapchd.dsbccxlt tt-crapchd.cdcmpchq tt-crapchd.cdbanchq
                    tt-crapchd.nrctachq tt-crapchd.nrcheque tt-crapchd.dsdocmc7
                    tt-crapchd.vlcheque WITH FRAME f_detalhes_rel.

            DOWN WITH FRAME f_detalhes_rel.

        END. /* FIM FOR EACH tt-crapchd */

        DISPLAY STREAM str_1 rel_qtdtotal rel_vlrtotal WITH FRAME f_total_rel.

        OUTPUT STREAM str_1 CLOSE.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  par_tpdsaida = "T" THEN
                    DO:
                        UNIX SILENT VALUE("ux2dos " + par_nmarqimp + " > " + aux_nmarquiv).
                    END.
                
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Imprime.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_nmarqimp,
                     OUTPUT par_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.

        LEAVE Imprime.

    END. /* Imprime */
     
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

END PROCEDURE. /* Gera_Relatorio */

/*............................. PROCEDURES INTERNAS .........................*/

PROCEDURE pi_paginacao:

    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-crapchd.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapchd-aux.

    ASSIGN aux_nrregist = par_nrregist.

    Pagina: DO ON ERROR UNDO Pagina, LEAVE Pagina:
        EMPTY TEMP-TABLE tt-crapchd-aux.

        FOR EACH tt-crapchd:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginação */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                    CREATE tt-crapchd-aux.
                    BUFFER-COPY tt-crapchd TO tt-crapchd-aux.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

    END. /* Pagina */

    RETURN "OK".

END PROCEDURE. /*pi_paginacao*/

PROCEDURE cria_tabela_temporaria:

    DEF VAR aux_cdbccxlt AS CHAR                                NO-UNDO.

    CASE crapchd.cdbccxlt:
        WHEN 11 THEN
            DO:
                 IF   crapchd.nrdolote > 30000 AND
                      crapchd.nrdolote < 30999 THEN
                      aux_cdbccxlt = "LANCHQ".
                 ELSE
                      aux_cdbccxlt = "CAIXA".
            END.
            
        WHEN 500 THEN
            aux_cdbccxlt = "LANCHQ".
    
        WHEN 600 THEN
            aux_cdbccxlt = "CUSTODIA".
    
        WHEN 700 THEN
            aux_cdbccxlt = "DESCONTO".
    END CASE.
             
    CREATE tt-crapchd.
    ASSIGN tt-crapchd.dtmvtolt = crapchd.dtmvtolt
           tt-crapchd.cdagenci = crapchd.cdagenci
           tt-crapchd.nrdconta = crapchd.nrdconta     
           tt-crapchd.dsbccxlt = aux_cdbccxlt    
           tt-crapchd.cdcmpchq = crapchd.cdcmpchq
           tt-crapchd.cdbanchq = crapchd.cdbanchq
           tt-crapchd.nrctachq = crapchd.nrctachq
           tt-crapchd.nrcheque = crapchd.nrcheque     
           tt-crapchd.dsdocmc7 = crapchd.dsdocmc7
           tt-crapchd.vlcheque = crapchd.vlcheque.
           
    ASSIGN rel_qtdtotal = rel_qtdtotal + 1
           rel_vlrtotal = rel_vlrtotal + crapchd.vlcheque.
  
END PROCEDURE.

PROCEDURE alimenta_capturado:

DEF  INPUT PARAM par_cdbccxlt AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_nrdolote AS INTE                           NO-UNDO.

    CASE par_cdbccxlt:
        WHEN 11 THEN
            DO:
                IF  par_nrdolote > 30000 AND
                    par_nrdolote < 30999 THEN
                    ASSIGN aux_dsbccxlt = "LANCHQ".
                ELSE ASSIGN aux_dsbccxlt = "CAIXA".
            END.
        WHEN 500 THEN
            ASSIGN aux_dsbccxlt = "LANCHQ".
    
        WHEN 600 THEN
            ASSIGN aux_dsbccxlt = "CUSTODIA".
    
        WHEN 700 THEN
            ASSIGN aux_dsbccxlt = "DESCONTO".
    
        WHEN 100 THEN
            ASSIGN aux_dsbccxlt = "LANDPV".
    
    END CASE.
END PROCEDURE.

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/
