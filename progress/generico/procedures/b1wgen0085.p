/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0085.p
    Autor   : Jose Luis Marchezoni (DB1)
    Data    : Fevereiro/2011                  Ultima atualizacao: 17/12/2013

    Objetivo  : Tranformacao BO tela ANOTA

    Alteracoes: 25/03/2011 - Retirar critica retornada nas opcoes A e E quando
                             o cooperado nao possuir anotacoes (David).
                             
                21/10/2011 - Adicionado a include b1cabrelvar.i para ser usada
                             pela b1cabrel080.i ( Rogerius Militão - DB1 )
                             
                17/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
   
.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/b1wgen0085tt.i &TT-LOG=SIM }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR aux_nrcoluna AS INTE                                        NO-UNDO.

DEF STREAM str_1.

FUNCTION LockTabela   RETURNS CHARACTER PRIVATE () FORWARD.

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA DOS DADOS DO ASSOCIADO                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-infoass.
    DEF OUTPUT PARAM TABLE FOR tt-crapobs.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabobs FOR crapobs.
    DEF BUFFER crabope FOR crapope.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Anotacoes"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-infoass.
        EMPTY TEMP-TABLE tt-crapobs.
        EMPTY TEMP-TABLE tt-erro.   

        /* Validar o digito da conta */
        IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrdconta ) THEN
            DO:
               ASSIGN aux_cdcritic = 8.
               LEAVE Busca.
            END.

        /* Informacoes sobre o cooperado */
        FOR FIRST crabass FIELDS(cdcooper nrdconta nmprimtl)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

        CREATE tt-infoass.
        ASSIGN 
            tt-infoass.cdcooper = crabass.cdcooper
            tt-infoass.nrdconta = crabass.nrdconta
            tt-infoass.nmprimtl = crabass.nmprimtl.

        FOR EACH crabobs WHERE crabobs.cdcooper = par_cdcooper AND
                               crabobs.nrdconta = par_nrdconta AND
                               (IF par_nrseqdig <> 0 THEN 
                                   crabobs.nrseqdig = par_nrseqdig ELSE TRUE)
                               NO-LOCK,
            EACH crabope FIELDS(nmoperad) WHERE 
                               crabope.cdcooper = crabobs.cdcooper AND
                               crabope.cdoperad = crabobs.cdoperad NO-LOCK:

            CREATE tt-crapobs.
            BUFFER-COPY crabobs TO tt-crapobs
                ASSIGN 
                    tt-crapobs.recidobs = RECID(crabobs)
                    tt-crapobs.hrtransc = STRING(crabobs.hrtransa,"HH:MM:SS")
                    tt-crapobs.nmoperad = crabope.nmoperad.
        END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Busca.
    END.

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


    IF  par_flgerlog THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
                            INPUT 1, /** idseqttl **/
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */ 

/* ------------------------------------------------------------------------ */
/*                EFETUA A VALIDACAO DOS DADOS INFORMADOS                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgprior AS LOG                            NO-UNDO.

    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    ASSIGN
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p 
                PERSISTENT SET h-b1wgen9999.

        RUN p-conectagener IN h-b1wgen9999.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        /* Mensagem de confirmacao: 078 - Confirma a operacao? (S/N) */
        ASSIGN 
            aux_returnvl = "OK"
            par_msgretor = DYNAMIC-FUNCTION("BuscaCritica" IN h-b1wgen0060,78).

        RUN p-desconectagener IN h-b1wgen9999.

        LEAVE Valida.
    END.

    IF  VALID-HANDLE(h-b1wgen9999) THEN
        DELETE OBJECT h-b1wgen9999.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

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

    IF  aux_returnvl = "NOK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT NO,
                            INPUT 1, /** idseqttl **/
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Dados */

/* ------------------------------------------------------------------------ */
/*               REALIZA A GRAVACAO DOS DADOS DAS ANOTACOES                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgprior AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_contador AS INTE                                   NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF  par_cddopcao = "I" THEN 
                            "Inclusao" 
                        ELSE 
                            IF  par_cddopcao = "A" THEN 
                                "Alteracao"
                            ELSE 
                                "Exclusao") + " de Anotacoes"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt-crapobs-ant.
        EMPTY TEMP-TABLE tt-crapobs-atl.

        ContadorObs: DO aux_contador = 1 TO 10:
            FIND crapobs WHERE crapobs.cdcooper = par_cdcooper AND
                               crapobs.nrdconta = par_nrdconta AND
                               crapobs.nrseqdig = par_nrseqdig
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapobs THEN
                DO:
                   IF  LOCKED(crapobs) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 /* encontra o usuario que esta travando */
                                 ASSIGN aux_dscritic = LockTabela().
                                 LEAVE ContadorObs.
                              END.
                          ELSE 
                              DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorObs.
                              END.
                       END.
                   ELSE
                       DO:
                          IF  par_cddopcao = "I" THEN 
                              DO:
                                 ASSIGN par_nrseqdig = 1.

                                 /* Buscar pela ultima sequencia */
                                 FOR FIRST crapobs FIELDS(nrseqdig)
                                     WHERE crapobs.cdcooper = par_cdcooper AND
                                           crapobs.nrdconta = par_nrdconta
                                           NO-LOCK USE-INDEX crapobs1:

                                    ASSIGN par_nrseqdig = crapobs.nrseqdig + 1.
                                 END.

                                 CREATE crapobs.
                                 ASSIGN 
                                     crapobs.cdcooper = par_cdcooper
                                     crapobs.cdoperad = par_cdoperad
                                     crapobs.nrdconta = par_nrdconta
                                     crapobs.nrseqdig = par_nrseqdig
                                     crapobs.hrtransa = TIME
                                     crapobs.dtmvtolt = par_dtmvtolt.
                                 VALIDATE crapobs.

                                 LEAVE ContadorObs.
                              END.
                          ELSE 
                              DO:
                                 ASSIGN aux_dscritic = "Registro da anotacao" +
                                                       " nao foi encontrado.".
                                 LEAVE ContadorObs.
                              END.
                       END.
                END.
            ELSE
                LEAVE ContadorObs.
        END. /* ContadorObs */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        CREATE tt-crapobs-ant.
        CREATE tt-crapobs-atl.

        IF  par_cddopcao <> "I" THEN
            BUFFER-COPY crapobs TO tt-crapobs-ant.
        ELSE
            ASSIGN tt-crapobs-ant.dtmvtolt = ?.

        IF  par_cddopcao = "E" THEN 
            DO:
               DELETE crapobs.
               ASSIGN tt-crapobs-atl.dtmvtolt = ?.
            END.
        ELSE 
            DO:
               ASSIGN
                   crapobs.dsobserv = CAPS(par_dsobserv)
                   crapobs.flgprior = par_flgprior.
               BUFFER-COPY crapobs TO tt-crapobs-atl.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Grava.
    END.

    IF  AVAILABLE crapobs  THEN
        FIND CURRENT crapobs NO-LOCK NO-ERROR.

    RELEASE crapobs.

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

    IF  par_flgerlog THEN
        DO:
           RUN proc_gerar_log_tab
               ( INPUT par_cdcooper,
                 INPUT par_cdoperad,
                 INPUT aux_dscritic,
                 INPUT aux_dsorigem,
                 INPUT aux_dstransa,
                 INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
                 INPUT 1, /** idseqttl **/
                 INPUT par_nmdatela,
                 INPUT par_nrdconta,
                 INPUT YES,
                 INPUT BUFFER tt-crapobs-ant:HANDLE,
                 INPUT BUFFER tt-crapobs-atl:HANDLE ).
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */

/* ------------------------------------------------------------------------ */
/*                       GERA IMPRESSÃO DAS ANOTAÇÕES                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_tipconsu AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF VAR aux_recidobs AS RECID                                   NO-UNDO.
    DEF VAR aux_flgfirst AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsobserv AS CHAR  VIEW-AS EDITOR 
                                       INNER-CHARS 76 INNER-LINES 8
                                       LARGE PFCOLOR 0              NO-UNDO.

    DEF VAR rel_dsoperad AS CHAR  FORMAT "x(40)"                    NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    FORM "EM" crapobs.dtmvtolt "AS"
         crapobs.hrtransa "POR" 
         rel_dsoperad SKIP(1)
         WITH COLUMN aux_nrcoluna NO-BOX NO-LABELS FRAME f_cabecalho.
         
    FORM "** MENSAGEM PRIORITARIA **"
         SKIP(1)
         WITH COLUMN aux_nrcoluna NO-BOX FRAME f_prioridade.
         
    FORM aux_dsobserv
         WITH COLUMN aux_nrcoluna NO-BOX NO-LABELS FRAME f_texto.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Imprime Anotacoes".
    
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapcop FIELDS(dsdircop) 
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop  THEN
            DO:
               ASSIGN 
                   aux_cdcritic = 651
                   aux_dscritic = "".
               LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN 
            aux_nmendter = aux_nmendter + STRING(TIME)
            aux_nmarqimp = aux_nmendter + ".ex"
            aux_nmarqpdf = aux_nmendter + ".pdf".

        IF  NOT par_tipconsu  THEN
            DO:

                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 84 PAGED.

                { sistema/generico/includes/b1cabrelvar.i }
                { sistema/generico/includes/b1cabrel080.i "11" "270" }
        
                /*  Configura a impressora para 1/8"  */
                PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        
                PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
        
                ASSIGN aux_nrcoluna = 5.
                       
            END.
        ELSE
            DO:
                aux_nrcoluna = 1.
                
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp). /* visualiza nao pode
                                                            ter caracteres de 
                                                            controle */

            END.

        ASSIGN aux_cdcritic = 0
               aux_flgfirst = TRUE.

        FOR EACH crapobs WHERE crapobs.cdcooper = par_cdcooper  AND
                               crapobs.nrdconta = par_nrdconta  AND
                              (IF par_nrseqdig = 0 THEN TRUE
                               ELSE crapobs.nrseqdig = par_nrseqdig)
                               NO-LOCK:
            

            IF  aux_flgfirst  THEN
                DO:
                   FOR FIRST crapass FIELDS(nrdconta nmprimtl)
                                     WHERE crapass.cdcooper = par_cdcooper AND
                                           crapass.nrdconta = par_nrdconta  
                                           NO-LOCK:
                       DISPLAY 
                           STREAM str_1
                           crapass.nrdconta LABEL "CONTA/DV"
                           crapass.nmprimtl LABEL "TITULAR"  FORMAT "x(40)"
                           SKIP(1)
                           WITH COLUMN aux_nrcoluna NO-LABELS SIDE-LABELS 
                           NO-BOX FRAME f_titular.
                   END.

                   ASSIGN aux_flgfirst = FALSE.
                END.
            ELSE
                DISPLAY 
                    STREAM str_1
                    SKIP(1)
                    FILL("-",80) FORMAT "x(76)"
                    SKIP(1)
                WITH COLUMN aux_nrcoluna NO-BOX FRAME f_linha.

            FOR FIRST crapope FIELDS(cdoperad nmoperad)
                              WHERE crapope.cdcooper = par_cdcooper     AND
                                    crapope.cdoperad = crapobs.cdoperad 
                                    NO-LOCK:
            END.
            
            IF  NOT AVAILABLE crapope THEN
                ASSIGN rel_dsoperad = TRIM(crapobs.cdoperad) + 
                                      " - NAO ENCONTRADO!".
            ELSE
                ASSIGN rel_dsoperad = TRIM(crapope.cdoperad) + " - " +
                                      TRIM(crapope.nmoperad).
            
            ASSIGN aux_dsobserv = TRIM(crapobs.dsobserv).
            
            DISPLAY 
                STREAM str_1
                crapobs.dtmvtolt  
                STRING(crapobs.hrtransa,"HH:MM:SS") @ crapobs.hrtransa
                rel_dsoperad
                WITH FRAME f_cabecalho.

            IF  crapobs.flgprior   THEN
                VIEW STREAM str_1 FRAME f_prioridade.

            DISPLAY 
                STREAM str_1 
                aux_dsobserv WITH FRAME f_texto.

        END.  /*  Fim do FOR EACH  */

        OUTPUT STREAM str_1 CLOSE.

        IF  par_idorigem = 5 THEN  /** Ayllos Web **/
            DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "".
               
               Imp-Web: DO WHILE TRUE:
                   RUN sistema/generico/procedures/b1wgen0024.p 
                       PERSISTENT SET h-b1wgen0024.
               
                   IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                       DO:
                          ASSIGN aux_dscritic = "Handle invalido para BO " +
                                                "b1wgen0024.".
                          LEAVE Imprime.
                       END.
               
                   RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                           INPUT aux_nmarqpdf).
               
                   IF  SEARCH(aux_nmarqpdf) = ?  THEN
                       DO:
                          ASSIGN aux_dscritic = "Nao foi possivel gerar " + 
                                                "a impressao.".
                          LEAVE Imprime.
                       END.
               
                   UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                      '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra 
                      + ':/var/www/ayllos/documentos/' + crapcop.dsdircop 
                      + '/temp/" 2>/dev/null').
               
                   LEAVE Imp-Web.
               END. /** Fim do DO WHILE TRUE **/
               
               IF  VALID-HANDLE(h-b1wgen0024)  THEN
                   DELETE OBJECT h-b1wgen0024.
               
               IF  par_idorigem = 5  THEN
                   UNIX SILENT VALUE ("rm " + aux_nmendter + "* 2>/dev/null").
        END.
        ELSE
            UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null").

        ASSIGN 
            par_nmarqimp = aux_nmarqimp
            par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
    END.

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
    
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.
END. /* Gera_Impressao */

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/

FUNCTION LockTabela RETURNS CHARACTER PRIVATE ():
/*-----------------------------------------------------------------------------
  Objetivo:  Identifica o usuario que esta locando o registro
     Notas:  
-----------------------------------------------------------------------------*/

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_mslocktb AS CHAR                                    NO-UNDO.

    ASSIGN aux_mslocktb = "Registro sendo alterado em outro terminal " +
                          "(crapobs).".

    IF  aux_idorigem = 3  THEN  /** InternetBank **/
        RETURN aux_mslocktb.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN aux_mslocktb.
        
    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapobs),
                                   INPUT "banco",
                                   INPUT "crapobs",
                                  OUTPUT aux_loginusr,
                                  OUTPUT aux_nmusuari,
                                  OUTPUT aux_dsdevice,
                                  OUTPUT aux_dtconnec, 
                                  OUTPUT aux_numipusr).

    DELETE OBJECT h-b1wgen9999.

    ASSIGN aux_mslocktb = aux_mslocktb + " Operador: " + 
                          aux_loginusr + " - " + aux_nmusuari.

    RETURN aux_mslocktb.   /* Function return value. */

END FUNCTION.

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

    IF  aux_nrdconta <> par_nrdconta THEN
        ASSIGN aux_vlresult = FALSE.

   RETURN aux_vlresult.
        
END FUNCTION.
