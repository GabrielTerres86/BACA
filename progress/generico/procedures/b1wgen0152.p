/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0152.p
    Autor   : Gabriel Capoia (DB1)
    Data    : 04/02/2013                     Ultima atualizacao: 15/12/2014

    Objetivo  : Tranformacao BO tela CLDPAC.

    Alteracoes: Campo crapcld.cddjusti tratado para receber somente
                justificativas validas, procedure grava_dados recebeu
                novo parametro: par_confirem (Reinert).
    
                13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero). 
                             
                08/04/2014 - Adicionado ASSIGN tt-creditos.cdcooper.
                             (Fabricio)
                             
                10/06/2014 - Incluido rotina verifica_fechamento 
				             (Chamado 143945) - (Andrino-RKAM).
                
                15/12/2014 - Adicionar validate para a crapcld na Grava_Dados.
                             Remover filtro de cdagenci para a crapass na Busca_Dados.
                             (Douglas - Chamado 143945)
............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0152tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }


DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.

FUNCTION LockTabela   RETURNS CHARACTER PRIVATE 
    ( INPUT par_cddrecid AS RECID,
      INPUT par_nmtabela AS CHAR ) FORWARD.

/*................................ PROCEDURES ..............................*/
/* ------------------------------------------------------------------------ */
/*         EFETUA A CONSULTA DA ANALISE DE MOVIMENTACAO X RENDA             */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Fechamento:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = "".

    /* Verifica se ja foi enviado para conferencia */
    FIND crapfld WHERE crapfld.cdcooper = par_cdcooper AND
                       crapfld.dtmvtolt = par_dtmvtolt AND
                       crapfld.cdtipcld = 1 /* DIARIO COOP */
                       NO-LOCK NO-ERROR.

    IF  AVAIL crapfld THEN 
        DO:
            aux_dscritic = "Fechamento para esta data ja realizado".
            aux_returnvl = "NOK".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.
     
END PROCEDURE. /* Verifica_Fechamento */

/* ------------------------------------------------------------------------ */
/*         EFETUA A CONSULTA DA ANALISE DE MOVIMENTACAO X RENDA             */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenca AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtola AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-creditos.
    DEF OUTPUT PARAM TABLE FOR tt-just.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Analise de movimentacao X renda".

    DEF VAR aux_nrdjusti AS INTE                                    NO-UNDO.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-creditos.
        EMPTY TEMP-TABLE tt-just.
        EMPTY TEMP-TABLE tt-erro.

        IF par_dtmvtola <> par_dtmvtoan THEN
           DO:
               ASSIGN aux_cdcritic = 13
                      par_nmdcampo = "dtmvtola".
               LEAVE Busca.
           END.

        IF NOT par_cdagenca > 0 THEN
           DO:
               ASSIGN aux_dscritic = "PA deve ser maior que zero.".
                      par_nmdcampo = "cdagenca".
               LEAVE Busca.
           END.

        IF  par_cddopcao = "J" OR 
            par_idorigem = 5 THEN
            DO:
                ASSIGN aux_nrdjusti = 0.

                FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper AND
                                       craptab.nmsistem = "JDP"        AND
                                       craptab.tptabela = "CONFIG"     AND
                                       craptab.cdempres = 0            AND
                                       craptab.cdacesso = "JUSTDEPOS" NO-LOCK:

                    CREATE tt-just.
                    ASSIGN tt-just.cddjusti = craptab.tpregist
                           tt-just.dsdjusti = craptab.dstextab
                           aux_nrdjusti     = aux_nrdjusti + 1.

                END. /* FOR EACH craptab */

            END. /* IF  par_cddopcao = J */

            FOR EACH crapcld WHERE crapcld.cdcooper = par_cdcooper AND
                                   crapcld.cdagenci = par_cdagenca AND
                                   crapcld.dtmvtolt = par_dtmvtola AND
                                   crapcld.cdtipcld = 1 NO-LOCK:

                FIND crapass WHERE crapass.cdcooper = crapcld.cdcooper AND
                                   crapass.nrdconta = crapcld.nrdconta
                                   NO-LOCK NO-ERROR.

                CREATE tt-creditos.
                ASSIGN tt-creditos.cdcooper = crapcld.cdcooper
                       tt-creditos.nrdconta = crapcld.nrdconta
                       tt-creditos.vlrendim = crapcld.vlrendim
                       tt-creditos.vltotcre = crapcld.vltotcre 
                       tt-creditos.flextjus = crapcld.flextjus
                       tt-creditos.cddjusti = crapcld.cddjusti
                       tt-creditos.dsdjusti = crapcld.dsdjusti
                       tt-creditos.dsobserv = crapcld.dsobserv
                       tt-creditos.cdoperad = crapcld.cdoperad
                       tt-creditos.nrdrowid = ROWID(crapcld).

                IF  AVAIL crapass THEN
                    DO:
                        ASSIGN tt-creditos.nmprimtl = crapass.nmprimtl 
                               tt-creditos.inpessoa = 
                                         IF   crapass.inpessoa = 1 THEN
                                              STRING(crapass.inpessoa) + "-FIS"
                                         ELSE STRING(crapass.inpessoa) + "-JUR".
                    END. /* IF  AVAIL crapass */

            END. /* FOR EACH crapcld */

            IF  NOT TEMP-TABLE tt-creditos:HAS-RECORDS THEN
                DO:
                    ASSIGN aux_dscritic = "Nao existem lancamentos a serem listados.".
                           par_nmdcampo = "nrcpfcgc".
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

/* ------------------------------------------------------------------------- */
/*                 REALIZA A GRAVACAO DOS DADOS DA TELA CLDPAC               */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flextjus AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddjusti AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdjusti AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_confirem AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava Situacao dos Terminais Financeiros"
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_idorigem = par_idorigem.


    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        Contador: DO aux_contador = 1 TO 10:

            FIND crapcld WHERE ROWID(crapcld) = par_nrdrowid
                               EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAIL crapcld THEN
                DO:
                    IF  LOCKED(crapcld) THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    FIND crapcld WHERE ROWID(crapcld) = par_nrdrowid
                                                 NO-LOCK NO-ERROR.

                                    /* encontra o usuario que esta travando */
                                    ASSIGN aux_dscritic = 
                                              LockTabela( INPUT RECID(crapcld),
                                                             INPUT "crapcld").
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
                            ASSIGN aux_dscritic = "Creditos do cooperado " +
                                                  "nao cadastrado!".

                            LEAVE Contador.

                        END.

                END.
            ELSE
                LEAVE Contador.

        END. /* Contador */
        IF (par_cddjusti = 7) THEN
            IF (TRIM(par_dsdjusti) = "") THEN
                aux_dscritic = "Informe uma descricao.".

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        FIND LAST craptab WHERE craptab.cdcooper = par_cdcooper   AND
                                craptab.nmsistem = "JDP"          AND
                                craptab.tptabela = "CONFIG"       AND
                                craptab.cdempres = 0
                                NO-LOCK NO-ERROR.
        IF AVAIL craptab THEN
           IF par_confirem = "S" THEN
               DO:
                   ASSIGN  crapcld.flextjus     = par_flextjus
                           crapcld.cddjusti     = par_cddjusti
                           crapcld.dsdjusti     = par_dsdjusti 
                           crapcld.dsobserv     = par_dsobserv
                           crapcld.cdoperad     = par_cdoperad.
                   
                   VALIDATE crapcld.
               END.
           ELSE
               IF (par_cddjusti > 0 AND par_cddjusti <= craptab.tpregist) THEN
                   DO:
                       ASSIGN crapcld.flextjus     = par_flextjus
                              crapcld.cddjusti     = par_cddjusti
                              crapcld.dsdjusti     = par_dsdjusti 
                              crapcld.dsobserv     = par_dsobserv
                              crapcld.cdoperad     = par_cdoperad.
    
                       VALIDATE crapcld.
                   END.
               ELSE
                  ASSIGN aux_dscritic = "Justificativa nao encontrada!".



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

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/

FUNCTION LockTabela RETURNS CHARACTER PRIVATE 
    ( INPUT par_cddrecid AS RECID,
      INPUT par_nmtabela AS CHAR ):
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
                          "(" + par_nmtabela + ").".

    IF  aux_idorigem = 3  THEN  /** InternetBank **/
        RETURN aux_mslocktb.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN aux_mslocktb.

    RUN acha-lock IN h-b1wgen9999 (INPUT par_cddrecid,
                                   INPUT "banco",
                                   INPUT par_nmtabela,
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
