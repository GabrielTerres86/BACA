/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0177.p
    Autor   : Gabriel Capoia (DB1)
    Data    : 20/09/2013                     Ultima atualizacao: 15/06/2016

    Objetivo  : Tranformacao BO tela GT0003.

    Alteracoes: 15/06/2016 - Correcao da paginacao para filtro que tras apenas 
                             um registro (Carlos)
         
		        06/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)
............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0177tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.

DEF BUFFER b-gncontr FOR gncontr.

/*................................ IMPRESSAO ..............................*/

DEF VAR aux_tiporel  AS CHAR FORMAT "x(11)"                         NO-UNDO.
DEF VAR aux_nmrescop AS CHAR FORMAT "x(20)"                         NO-UNDO.
DEF VAR aux_cdcooped AS INTE                                        NO-UNDO.
DEF VAR aux_dtinici  AS DATE                                        NO-UNDO.
DEF VAR aux_dtfinal  AS DATE                                        NO-UNDO.
DEF VAR aux_ttqtdoctos  LIKE gncontr.qtdoctos                       NO-UNDO.
DEF VAR aux_ttvldoctos  LIKE gncontr.vldoctos                       NO-UNDO.
DEF VAR aux_ttvltarifa  LIKE gncontr.vltarifa                       NO-UNDO.
DEF VAR aux_ttvlapagar  LIKE gncontr.vlapagar                       NO-UNDO.
DEF VAR aux_ggqtdoctos  LIKE gncontr.qtdoctos                       NO-UNDO.
DEF VAR aux_ggvldoctos  LIKE gncontr.vldoctos                       NO-UNDO.
DEF VAR aux_ggvltarifa  LIKE gncontr.vltarifa                       NO-UNDO.
DEF VAR aux_ggvlapagar  LIKE gncontr.vlapagar                       NO-UNDO.

FORM "SELECAO "     AT  1
     aux_cdcooped   AT 15    LABEL "Cooperativa  "
     aux_dtinici    AT 40    LABEL "Data Inicial " FORMAT "99/99/9999"
     aux_dtfinal    AT 70    LABEL "Data Final "   FORMAT "99/99/9999"
     SKIP(1)
     aux_tiporel    NO-LABEL
     "         Qtd.Doctos       Vl.Doctos          Tarifa     Vl. a Pagar"
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab.

FORM  aux_nmrescop   
      gncontr.qtdoctos  
      gncontr.vldoctos  
      gncontr.vltarifa  
      gncontr.vlapagar  
      WITH NO-BOX  NO-LABELS DOWN FRAME f_movtos WIDTH 132.

FORM  gnconve.nmempres 
      gncontr.qtdoctos  
      gncontr.vldoctos  
      gncontr.vltarifa  
      gncontr.vlapagar  
      WITH NO-BOX  NO-LABELS DOWN FRAME f_movtos_conven WIDTH 132.

/*................................ PROCEDURES ..............................*/

/* -------------------------------------------------------------------------- */
/*                  CONSULTAR PROTOCOLO DE ARRECADACAO NO CAIXA               */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtola AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdconven AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooped AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_totqtdoc AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_totvldoc AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_tottarif AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_totpagar AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-gt0003.
    DEF OUTPUT PARAM TABLE FOR tt-gt0003-aux.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Dados Protocolo de Arrecadacao no Caixa".              

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-gt0003-aux.
        EMPTY TEMP-TABLE tt-gt0003.
        EMPTY TEMP-TABLE tt-erro.

        IF  par_dtmvtola <> ? AND
            par_cdcooped <> 0 AND 
            par_cdconven <> 0 THEN
            DO:

                FOR FIRST gncontr 
                    WHERE gncontr.cdcooper = par_cdcooped AND
                          gncontr.tpdcontr = 1            AND  /* Arrecadacao Caixa */
                          gncontr.cdconven = par_cdconven AND
                          gncontr.dtmvtolt = par_dtmvtola NO-LOCK: END.

                IF  AVAIL gncontr THEN
                    DO:
                        CREATE tt-gt0003.

                        ASSIGN tt-gt0003.nmrescop = " ".

                        FOR FIRST crapcop 
                            WHERE crapcop.cdcooper = par_cdcooped NO-LOCK: END.

                        IF  AVAIL crapcop THEN
                            ASSIGN tt-gt0003.nmrescop = crapcop.nmrescop.

                        ASSIGN tt-gt0003.cdcooper = gncontr.cdcooper
                               tt-gt0003.cdconven = gncontr.cdconven
                               tt-gt0003.dtmvtolt = gncontr.dtmvtolt
                               tt-gt0003.dtcredit = gncontr.dtcredit
                               tt-gt0003.nmarquiv = gncontr.nmarquiv
                               tt-gt0003.qtdoctos = gncontr.qtdoctos
                               tt-gt0003.vldoctos = gncontr.vldoctos
                               tt-gt0003.vltarifa = gncontr.vltarifa
                               tt-gt0003.vlapagar = gncontr.vlapagar    
                               tt-gt0003.nrsequen = gncontr.nrsequen.

                        FOR FIRST gnconve 
                            WHERE gnconve.cdconve  = gncontr.cdconven AND
                                  gnconve.flgativo = TRUE NO-LOCK: END.

                        IF  AVAIL gnconve THEN
                            ASSIGN tt-gt0003.cdcopdom = gnconve.cdcooper
                                   tt-gt0003.nrcnvfbr = gnconve.nrcnvfbr
                                   tt-gt0003.nmempres = gnconve.nmempres.

                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 563 /* Convenio nao Cadastrado */
                               aux_dscritic = ""
                               par_nmdcampo = "cdconven".
                        LEAVE Busca.
                    END.

                IF  par_idorigem = 5 THEN DO:

                    ASSIGN par_totqtdoc = tt-gt0003.qtdoctos
                           par_totvldoc = tt-gt0003.vldoctos
                           par_tottarif = tt-gt0003.vltarifa
                           par_totpagar = tt-gt0003.vlapagar.

                    RUN pi_paginacao ( INPUT par_nrregist,
                                       INPUT par_nriniseq,
                                       INPUT TABLE tt-gt0003,
                                      OUTPUT par_qtregist,
                                      OUTPUT TABLE tt-gt0003-aux).
                    EMPTY TEMP-TABLE tt-gt0003.
                END.                
                
            END. /* par_dtmvtola <> ? AND par_cdcooped <> 0 AND par_cdconven <> 0 */
        ELSE
            DO:
                RUN soma_totais
                    ( INPUT par_cdcooped,
                      INPUT par_dtmvtola,
                      INPUT par_cdconven,
                     OUTPUT par_totqtdoc,
                     OUTPUT par_totvldoc,
                     OUTPUT par_tottarif,
                     OUTPUT par_totpagar).

                IF  par_cdconven <> 0 THEN
                    DO:
                        FOR EACH gncontr 
                           WHERE gncontr.dtmvtolt = par_dtmvtola AND
                                 gncontr.cdconven = par_cdconven AND
                                 gncontr.tpdcontr = 1 NO-LOCK,
                           FIRST gnconve 
                           WHERE gnconve.cdconven = gncontr.cdconven AND
                                 gnconve.flgativo = TRUE NO-LOCK 
                            BY gncontr.cdcooper
                                BY gncontr.cdconven
                                    BY gncontr.dtmvtolt:

                            CREATE tt-gt0003.

                            ASSIGN tt-gt0003.nmrescop = " ".

                            FOR FIRST crapcop 
                                WHERE crapcop.cdcooper = gncontr.cdcooper NO-LOCK: END.
    
                            IF  AVAIL crapcop THEN
                                ASSIGN tt-gt0003.nmrescop = crapcop.nmrescop.

                            ASSIGN tt-gt0003.cdcooper = gncontr.cdcooper
                                   tt-gt0003.cdconven = gnconve.cdconven
                                   tt-gt0003.dtmvtolt = gncontr.dtmvtolt
                                   tt-gt0003.dtcredit = gncontr.dtcredit
                                   tt-gt0003.qtdoctos = gncontr.qtdoctos
                                   tt-gt0003.vldoctos = gncontr.vldoctos
                                   tt-gt0003.vltarifa = gncontr.vltarifa
                                   tt-gt0003.vlapagar = gncontr.vlapagar
                                   tt-gt0003.nmarquiv = gncontr.nmarquiv
                                   tt-gt0003.nrsequen = gncontr.nrsequen
                                   tt-gt0003.cdcopdom = gnconve.cdcooper
                                   tt-gt0003.nrcnvfbr = gnconve.nrcnvfbr
                                   tt-gt0003.nmempres = gnconve.nmempres.
                        END. /* FOR EACH gncontr  */

                    END. /* par_cdconven <> 0 */
                ELSE
                    DO:
                        IF  par_cdcooped <> 0 THEN
                            DO:
                                FOR EACH gncontr WHERE
                                         gncontr.dtmvtolt = par_dtmvtola AND
                                         gncontr.cdcooper = par_cdcooped AND
                                         gncontr.tpdcontr = 1 NO-LOCK , 
                                   FIRST gnconve WHERE
                                         gnconve.cdconven = gncontr.cdconven AND 
                                         gnconve.flgativo = TRUE NO-LOCK
                                    BY gncontr.cdcooper
                                        BY gncontr.cdconven
                                            BY gncontr.dtmvtolt:

                                    CREATE tt-gt0003.

                                    ASSIGN tt-gt0003.nmrescop = " ".

                                    FOR FIRST crapcop 
                                        WHERE crapcop.cdcooper = gncontr.cdcooper NO-LOCK: END.
            
                                    IF  AVAIL crapcop THEN
                                        ASSIGN tt-gt0003.nmrescop = crapcop.nmrescop.

                                    ASSIGN tt-gt0003.cdcooper = gncontr.cdcooper
                                           tt-gt0003.cdconven = gnconve.cdconven
                                           tt-gt0003.dtmvtolt = gncontr.dtmvtolt
                                           tt-gt0003.dtcredit = gncontr.dtcredit
                                           tt-gt0003.qtdoctos = gncontr.qtdoctos
                                           tt-gt0003.vldoctos = gncontr.vldoctos
                                           tt-gt0003.vltarifa = gncontr.vltarifa
                                           tt-gt0003.vlapagar = gncontr.vlapagar
                                           tt-gt0003.nmarquiv = gncontr.nmarquiv
                                           tt-gt0003.nrsequen = gncontr.nrsequen
                                           tt-gt0003.cdcopdom = gnconve.cdcooper
                                           tt-gt0003.nrcnvfbr = gnconve.nrcnvfbr
                                           tt-gt0003.nmempres = gnconve.nmempres.

                                END. /* FOR EACH gncontr  */

                            END. /* par_cdcooped <> 0 */
                        ELSE
                            DO:
                                FOR EACH gncontr WHERE
                                         gncontr.dtmvtolt = par_dtmvtola AND
                                         gncontr.tpdcontr = 1 NO-LOCK , 
                                   FIRST gnconve WHERE
                                         gnconve.cdconven = gncontr.cdconven AND
                                         gnconve.flgativo = TRUE NO-LOCK
                                    BY gncontr.cdcooper
                                        BY gncontr.cdconven
                                            BY gncontr.dtmvtolt:

                                    CREATE tt-gt0003.

                                    ASSIGN tt-gt0003.nmrescop = " ".

                                    FOR FIRST crapcop 
                                        WHERE crapcop.cdcooper = gncontr.cdcooper NO-LOCK: END.
            
                                    IF  AVAIL crapcop THEN
                                        ASSIGN tt-gt0003.nmrescop = crapcop.nmrescop.

                                    ASSIGN tt-gt0003.cdcooper = gncontr.cdcooper
                                           tt-gt0003.cdconven = gnconve.cdconven
                                           tt-gt0003.dtmvtolt = gncontr.dtmvtolt
                                           tt-gt0003.dtcredit = gncontr.dtcredit
                                           tt-gt0003.qtdoctos = gncontr.qtdoctos
                                           tt-gt0003.vldoctos = gncontr.vldoctos
                                           tt-gt0003.vltarifa = gncontr.vltarifa
                                           tt-gt0003.vlapagar = gncontr.vlapagar
                                           tt-gt0003.nmarquiv = gncontr.nmarquiv
                                           tt-gt0003.nrsequen = gncontr.nrsequen
                                           tt-gt0003.cdcopdom = gnconve.cdcooper
                                           tt-gt0003.nrcnvfbr = gnconve.nrcnvfbr
                                           tt-gt0003.nmempres = gnconve.nmempres.

                                END. /* FOR EACH gncontr  */

                            END.
                    END.

                IF  par_idorigem = 5 THEN DO:
                    RUN pi_paginacao ( INPUT par_nrregist,
                                       INPUT par_nriniseq,
                                       INPUT TABLE tt-gt0003,
                                      OUTPUT par_qtregist,
                                      OUTPUT TABLE tt-gt0003-aux).

                    EMPTY TEMP-TABLE tt-gt0003.
                    
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

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */

PROCEDURE pi_paginacao:

    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-gt0003.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-gt0003-aux.

    ASSIGN aux_nrregist = par_nrregist.

    Pagina: DO ON ERROR UNDO Pagina, LEAVE Pagina:
        EMPTY TEMP-TABLE tt-gt0003-aux.

        FOR EACH tt-gt0003:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginação */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                    CREATE tt-gt0003-aux.
                    BUFFER-COPY tt-gt0003 TO tt-gt0003-aux.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

    END. /* Pagina */

    RETURN "OK".

END PROCEDURE. /*pi_paginacao*/

/* ------------------------------------------------------------------------- */
/*                           GERA IMPRESSÃO DAS CARTAS                       */
/* ------------------------------------------------------------------------- */
PROCEDURE Gera_Impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tiporel  AS LOGI                           NO-UNDO.  
    DEF  INPUT PARAM par_cdcooped AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinici  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfinal  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crabcop FOR crapcop.    
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Manutencao do CCF"

           aux_cdcooped = par_cdcooped
           aux_dtinici  = par_dtinici 
           aux_dtfinal  = par_dtfinal.
     
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.
            
        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooped NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Cooperativa nao existe.".
                LEAVE Imprime.
            END.
            

        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.
        
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        IF  par_tiporel = YES THEN
            ASSIGN aux_tiporel = "Convenio   ".
        ELSE
            ASSIGN aux_tiporel = "Cooperativa".
        
        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

        PUT STREAM str_1 CONTROL "\0330\033x0\033\017" NULL.

        { sistema/generico/includes/b1cabrelvar.i }
        { sistema/generico/includes/b1cabrel132.i "11" "347" }
        
        DISPLAY STREAM str_1 aux_tiporel
                             aux_cdcooped
                             aux_dtinici
                             aux_dtfinal WITH FRAME f_cab.

        IF   par_tiporel = NO THEN      /* Por Cooperativa */
             RUN lista_por_cooperativa.
        ELSE      
             RUN lista_por_convenio.
        
        PAGE STREAM str_1.
        
        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

        PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

        OUTPUT  STREAM str_1 CLOSE.
        
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
                      INPUT aux_nmarqimp,
                     OUTPUT aux_nmarqpdf,
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

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Gera_Impressao */

PROCEDURE soma_totais:

    DEF INPUT  PARAM par_cdcooper    AS  INTE                NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt    AS  DATE                NO-UNDO.
    DEF INPUT  PARAM par_cdconven    AS  INTE                NO-UNDO.

    DEF OUTPUT PARAM par_totqtdoc    AS  DECI                NO-UNDO.
    DEF OUTPUT PARAM par_totvldoc    AS  DECI                NO-UNDO.
    DEF OUTPUT PARAM par_tottarif    AS  DECI                NO-UNDO.
    DEF OUTPUT PARAM par_totpagar    AS  DECI                NO-UNDO.

    ASSIGN par_totqtdoc = 0
           par_totvldoc = 0
           par_tottarif = 0
           par_totpagar = 0.

    IF  par_cdconven <> 0 THEN
        DO:
            FOR EACH b-gncontr NO-LOCK WHERE
                     b-gncontr.dtmvtolt = par_dtmvtolt AND
                     b-gncontr.cdconven = par_cdconven AND
                     b-gncontr.tpdcontr = 1, 
            FIRST gnconve NO-LOCK WHERE
                  gnconve.cdconven = b-gncontr.cdconven AND 
                  gnconve.flgativo = TRUE
               BY b-gncontr.cdcooper
               BY b-gncontr.cdconven
               BY b-gncontr.dtmvtolt:

                ASSIGN par_totqtdoc = par_totqtdoc + b-gncontr.qtdoctos
                       par_totvldoc = par_totvldoc + b-gncontr.vldoctos
                       par_tottarif = par_tottarif + b-gncontr.vltarifa
                       par_totpagar = par_totpagar + b-gncontr.vlapagar.
           
            END. 
        END.
    ELSE
        DO:
            IF  par_cdcooper <> 0 THEN
                DO:
                
                    FOR EACH b-gncontr NO-LOCK WHERE
                             b-gncontr.dtmvtolt = par_dtmvtolt AND
                             b-gncontr.cdcooper = par_cdcooper AND
                             b-gncontr.tpdcontr = 1, 
                    FIRST gnconve NO-LOCK WHERE
                          gnconve.cdconven = b-gncontr.cdconven AND 
                          gnconve.flgativo = TRUE
                       BY b-gncontr.cdcooper
                       BY b-gncontr.cdconven
                       BY b-gncontr.dtmvtolt:
    
                        ASSIGN par_totqtdoc = par_totqtdoc + b-gncontr.qtdoctos
                               par_totvldoc = par_totvldoc + b-gncontr.vldoctos
                               par_tottarif = par_tottarif + b-gncontr.vltarifa
                               par_totpagar = par_totpagar + b-gncontr.vlapagar.
                  
                    END. 
                END.
            ELSE
                DO: 

                    FOR EACH b-gncontr NO-LOCK WHERE
                             b-gncontr.dtmvtolt = par_dtmvtolt AND
                             b-gncontr.tpdcontr = 1, 
                    FIRST gnconve NO-LOCK WHERE
                          gnconve.cdconven = b-gncontr.cdconven AND 
                          gnconve.flgativo = TRUE
                       BY b-gncontr.cdcooper
                       BY b-gncontr.cdconven
                       BY b-gncontr.dtmvtolt:
                         
                        ASSIGN par_totqtdoc = par_totqtdoc + b-gncontr.qtdoctos
                               par_totvldoc = par_totvldoc + b-gncontr.vldoctos
                               par_tottarif = par_tottarif + b-gncontr.vltarifa
                               par_totpagar = par_totpagar + b-gncontr.vlapagar.
    
                    END. 
                    
                END.
        END.
     
    RETURN "OK".
END PROCEDURE.

PROCEDURE lista_por_cooperativa.
     
    ASSIGN aux_ttqtdoctos = 0
           aux_ttvldoctos = 0
           aux_ttvltarifa = 0
           aux_ttvlapagar = 0.
    ASSIGN aux_ttqtdoctos = 0
           aux_ttvldoctos = 0
           aux_ttvltarifa = 0
           aux_ttvlapagar = 0.
    
    FOR EACH  gncontr WHERE
             (gncontr.cdcooper = aux_cdcooped      OR                    
              aux_cdcooped     = 0)                AND
              gncontr.dtmvtolt >= aux_dtinici      AND
              gncontr.dtmvtolt <= aux_dtfinal      AND
              gncontr.tpdcontr = 1                 NO-LOCK,
         EACH crapcop WHERE
              crapcop.cdcooper = gncontr.cdcooper  NO-LOCK
              BREAK BY crapcop.nmrescop
                       BY gncontr.cdconven:

        ASSIGN aux_ttqtdoctos = aux_ttqtdoctos + gncontr.qtdoctos
               aux_ttvldoctos = aux_ttvldoctos + gncontr.vldoctos
               aux_ttvltarifa = aux_ttvltarifa + gncontr.vltarifa
               aux_ttvlapagar = aux_ttvlapagar + gncontr.vlapagar.
        ASSIGN aux_ggqtdoctos = aux_ggqtdoctos + gncontr.qtdoctos
               aux_ggvldoctos = aux_ggvldoctos + gncontr.vldoctos
               aux_ggvltarifa = aux_ggvltarifa + gncontr.vltarifa
               aux_ggvlapagar = aux_ggvlapagar + gncontr.vlapagar.
            
        IF   LAST-OF(crapcop.nmrescop) THEN
             DO:
                
                ASSIGN aux_nmrescop = crapcop.nmrescop.
                DISPLAY STREAM str_1
                       aux_nmrescop
                       aux_ttqtdoctos @ gncontr.qtdoctos
                       aux_ttvldoctos @ gncontr.vldoctos
                       aux_ttvltarifa @ gncontr.vltarifa
                       aux_ttvlapagar @ gncontr.vlapagar
                       WITH FRAME f_movtos.
                DOWN   WITH FRAME f_movtos.
                ASSIGN aux_ttqtdoctos = 0
                       aux_ttvldoctos = 0
                       aux_ttvltarifa = 0
                       aux_ttvlapagar = 0.
             END.
               
        IF   LINE-COUNTER(str_1) > 80  THEN
             DO:
                PAGE STREAM str_1.
                       
                DISPLAY STREAM str_1
                        aux_tiporel
                        aux_cdcooped
                        aux_dtinici
                        aux_dtfinal WITH FRAME f_cab.
            END.
    END.
    DISPLAY STREAM str_1
                   "TOTAL " @ aux_nmrescop
                   aux_ggqtdoctos @ gncontr.qtdoctos
                   aux_ggvldoctos @ gncontr.vldoctos
                   aux_ggvltarifa @ gncontr.vltarifa
                   aux_ggvlapagar @ gncontr.vlapagar
                   WITH FRAME f_movtos.
    DOWN   WITH FRAME f_movtos.


END PROCEDURE.



PROCEDURE lista_por_convenio.

    ASSIGN aux_ttqtdoctos = 0
           aux_ttvldoctos = 0
           aux_ttvltarifa = 0
           aux_ttvlapagar = 0.
    ASSIGN aux_ttqtdoctos = 0
           aux_ttvldoctos = 0
           aux_ttvltarifa = 0
           aux_ttvlapagar = 0.

    FOR EACH  gncontr WHERE
             (gncontr.cdcooper = aux_cdcooped      OR                    
              aux_cdcooped     = 0)                AND
              gncontr.dtmvtolt >= aux_dtinici      AND
              gncontr.dtmvtolt <= aux_dtfinal      AND
              gncontr.tpdcontr = 1                 NO-LOCK,
         EACH gnconve WHERE
              gnconve.cdconven = gncontr.cdconven  NO-LOCK
         BREAK BY gnconve.nmempres
               BY gncontr.cdcooper:

        ASSIGN aux_ttqtdoctos = aux_ttqtdoctos + gncontr.qtdoctos
               aux_ttvldoctos = aux_ttvldoctos + gncontr.vldoctos
               aux_ttvltarifa = aux_ttvltarifa + gncontr.vltarifa
               aux_ttvlapagar = aux_ttvlapagar + gncontr.vlapagar.
           
        ASSIGN aux_ggqtdoctos = aux_ggqtdoctos + gncontr.qtdoctos
               aux_ggvldoctos = aux_ggvldoctos + gncontr.vldoctos
               aux_ggvltarifa = aux_ggvltarifa + gncontr.vltarifa
               aux_ggvlapagar = aux_ggvlapagar + gncontr.vlapagar.
 
        IF   LAST-OF(gnconve.nmempres) THEN
             DO:
                DISPLAY STREAM str_1
                       gnconve.nmempres
                       aux_ttqtdoctos @ gncontr.qtdoctos
                       aux_ttvldoctos @ gncontr.vldoctos
                       aux_ttvltarifa @ gncontr.vltarifa
                       aux_ttvlapagar @ gncontr.vlapagar
                       WITH FRAME f_movtos_conven.
                DOWN   WITH FRAME f_movtos_conven.
                ASSIGN aux_ttqtdoctos = 0
                       aux_ttvldoctos = 0
                       aux_ttvltarifa = 0
                       aux_ttvlapagar = 0.
             END.
               
        IF   LINE-COUNTER(str_1) > 80  THEN
             DO:
                PAGE STREAM str_1.
                       
                DISPLAY STREAM str_1
                        aux_tiporel
                        aux_cdcooped
                        aux_dtinici
                        aux_dtfinal WITH FRAME f_cab.
            END.
    END.
   
    DISPLAY STREAM str_1
                   "TOTAL " @ gnconve.nmempres
                   aux_ggqtdoctos @ gncontr.qtdoctos
                   aux_ggvldoctos @ gncontr.vldoctos
                   aux_ggvltarifa @ gncontr.vltarifa
                   aux_ggvlapagar @ gncontr.vlapagar
                   WITH FRAME f_movtos_conven.
    DOWN   WITH FRAME f_movtos_conven.

    
END PROCEDURE.

