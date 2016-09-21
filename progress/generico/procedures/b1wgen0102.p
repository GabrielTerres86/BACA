/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0102.p
    Autor   : Gabriel Capoia dos Santos (DB1)
    Data    : Julho/2011                        Ultima atualizacao: 21/01/2015

    Objetivo  : Tranformacao BO tela ALIENA

    Alteracoes:  

        22/11/2013 - GRAVAMES - Gravar campos tpinclus/dtatugrv/cdsitgrv na 
                     procedure Busca_Dados. (Guilherme/SUPERO)
        
        21/01/2015 - Alterado o formato do campo nrctremp para 8 
                     caracters (Kelvin - 233714)

.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/b1wgen0102tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                        NO-UNDO.
DEF VAR aux_flgfirst AS LOGICAL                                     NO-UNDO.

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
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-infoepr.
    DEF OUTPUT PARAM TABLE FOR tt-aliena.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_lssemseg AS CHAR                                    NO-UNDO. 

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabepr FOR crapepr.
    DEF BUFFER crabbpr FOR crapbpr.
    DEF BUFFER crabtab FOR craptab.
        
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Alienacao Fiduciaria"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-infoepr.
        EMPTY TEMP-TABLE tt-aliena.
        EMPTY TEMP-TABLE tt-erro.    

        IF  NOT CAN-DO ("C,A,S",par_cddopcao) THEN
            DO:
                ASSIGN aux_cdcritic = 014.
                LEAVE Busca.
            END.                     

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

        CREATE tt-infoepr.
        ASSIGN tt-infoepr.cdcooper = crabass.cdcooper
               tt-infoepr.nrdconta = crabass.nrdconta
               tt-infoepr.nmprimtl = crabass.nmprimtl
               tt-infoepr.dtmvtolt = ?.

        FOR FIRST crabepr FIELDS(dtmvtolt)
                          WHERE crabepr.cdcooper = par_cdcooper AND
                                crabepr.nrdconta = par_nrdconta AND
                                crabepr.nrctremp = par_nrctremp NO-LOCK:
        END.

        IF  NOT AVAILABLE crabepr THEN
            DO:
                ASSIGN aux_cdcritic = 356.
                LEAVE Busca.
            END.

        IF  AVAIL tt-infoepr THEN
            ASSIGN tt-infoepr.dtmvtolt = crabepr.dtmvtolt.

        /* Buscar lista de categorias dispensadas do seguro */
        FOR FIRST crabtab FIELDS(dstextab)
                          WHERE crabtab.cdcooper = par_cdcooper  AND
                                crabtab.nmsistem = "CRED"        AND
                                crabtab.tptabela = "USUARI"      AND
                                crabtab.cdempres = 11            AND
                                crabtab.cdacesso = "DISPSEGURO"  AND
                                crabtab.tpregist = 001           NO-LOCK: END.
        
        IF  NOT AVAILABLE crabtab THEN
            aux_lssemseg = "".
        ELSE 
            aux_lssemseg = crabtab.dstextab.

        /* Bens alienados */
        FOR EACH crabbpr FIELDS( cdcooper nrdconta tpctrpro nrctrpro idseqbem
                                 dscatbem dsbemfin flgalfid dtvigseg flglbseg
                                 flgrgcar tpinclus dtatugrv cdsitgrv)
                         WHERE crabbpr.cdcooper = par_cdcooper AND
                               crabbpr.nrdconta = par_nrdconta AND
                               crabbpr.tpctrpro = 90           AND
                               crabbpr.nrctrpro = par_nrctremp AND
                               crabbpr.flgalien = TRUE         NO-LOCK:



            CREATE tt-aliena.
            ASSIGN tt-aliena.cdcooper = crabbpr.cdcooper
                   tt-aliena.nrdconta = crabbpr.nrdconta
                   tt-aliena.tpctrpro = crabbpr.tpctrpro
                   tt-aliena.nrctrpro = crabbpr.nrctrpro
                   tt-aliena.idseqbem = crabbpr.idseqbem
                   tt-aliena.dscatbem = crabbpr.dscatbem
                   tt-aliena.dsbemfin = crabbpr.dsbemfin
                   tt-aliena.flgalfid = crabbpr.flgalfid
                   tt-aliena.dtvigseg = crabbpr.dtvigseg
                   tt-aliena.flglbseg = crabbpr.flglbseg
                   tt-aliena.flgrgcar = crabbpr.flgrgcar
                   tt-aliena.tpinclus = crabbpr.tpinclus 
                   tt-aliena.dtatugrv = crabbpr.dtatugrv 
                   tt-aliena.cdsitgrv = crabbpr.cdsitgrv
                   tt-aliena.flgperte = CAN-DO(aux_lssemseg,crabbpr.dscatbem).

        END.

        ASSIGN aux_returnvl = "OK".
        
        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

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
                                    INPUT FALSE,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".       

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------- */
/*                  Efetua a Validação dos dados informados                  */
/* ------------------------------------------------------------------------- */
PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqbem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgalfid AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgperte AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtvigseg AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-mensagens.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_dstransa = "Valida Alienacao Fiduciaria"
           aux_cdcritic = 0
           aux_nrsequen = 0
           aux_returnvl = "NOK".

    DEF BUFFER crabbpr FOR crapbpr.
    
    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-mensagens.
        EMPTY TEMP-TABLE tt-erro.
        
        FOR FIRST crabbpr FIELDS( flgalfid dtvigseg )
                          WHERE crabbpr.cdcooper = par_cdcooper AND
                                crabbpr.nrdconta = par_nrdconta AND
                                crabbpr.tpctrpro = 90           AND
                                crabbpr.nrctrpro = par_nrctremp AND
                                crabbpr.idseqbem = par_idseqbem NO-LOCK: END.

        IF  NOT AVAILABLE crabbpr   THEN
            DO:
                ASSIGN aux_cdcritic = 55.
                LEAVE Valida.
            END.
        
        IF  par_cddopcao = "A" THEN
            DO:
                
                IF  (crabbpr.flgalfid AND NOT par_flgalfid)  THEN
                    DO:
                        RUN cria-registro-msg ( INPUT "Campo ALIENACAO -> "  +
                                                "Confirma a alteracao de OK " +
                                                "para PENDENTE!(S/N):" ).
                    END.
        
                IF  NOT par_flgperte THEN 
                    DO:
                        IF  (crabbpr.dtvigseg <> ? AND par_dtvigseg = ?) THEN
                            DO:
                                RUN cria-registro-msg 
                                                ( INPUT "Campo SEGURO -> " +
                                                "Confirma a baixa do seguro!" +
                                                "(S/N):" ).
                            END.
                         ELSE
                         IF  par_dtvigseg < par_dtmvtolt THEN
                             DO:
                                 RUN cria-registro-msg 
                                     ( INPUT "Campo SEGURO -> " + 
                                             "O SEGURO JA ESTA VENCIDO!!! - " +
                                             "Confirma?(S/N):" ).
                             END.                    
                    END.

            END. /* par_cddopcao = "A" */
        ELSE 
        IF  par_cddopcao = "S" THEN
            DO:
                
                IF  par_flgperte THEN 
                    DO: 
                        ASSIGN aux_dscritic =
                             "744 - Para este bem nao e necessario seguro.".
                        LEAVE Valida.
                    END.
        
                IF  (crabbpr.dtvigseg <> ? AND par_dtvigseg = ?) THEN
                    DO:
                        RUN cria-registro-msg 
                                      ( INPUT "Campo SEGURO -> " + 
                                             "Confirme a baixa do seguro! " +
                                             "(S/N):" ).
                       
                    END.
                ELSE
                IF  par_dtvigseg < par_dtmvtolt   THEN
                    DO:
                        RUN cria-registro-msg 
                                     ( INPUT "Campo SEGURO -> " + 
                                             "O SEGURO JA ESTA VENCIDO!!! " +
                                              "- Confirma? (S/N):" ).
                    END.
                   
            END. /* par_cddopcao = "S" */

    END. /* Valida */

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

/* ------------------------------------------------------------------------- */
/*                   REALIZA A GRAVACAO DOS DADOS DOS CHEQUES                */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqbem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgalfid AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtvigseg AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flglbseg AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgrgcar AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgperte AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
                                 
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR ant_flgalfid AS LOGI                                    NO-UNDO.
    DEF VAR ant_dtvigseg AS DATE                                    NO-UNDO.
    DEF VAR ant_flglbseg AS LOGI                                    NO-UNDO.
    DEF VAR ant_flgrgcar AS LOGI                                    NO-UNDO.

    DEF BUFFER crabbpr FOR crapbpr.
    
    ASSIGN aux_flgfirst = TRUE
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = ""
           aux_dstransa = "Grava Alienacao Fiduciaria"
           aux_cdcritic = 0
           aux_returnvl = "NOK".
    
    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        ContadorAliena: DO aux_contador = 1 TO 10:

            /* Buffer da crapbpr */
            FIND crabbpr WHERE crabbpr.cdcooper = par_cdcooper  AND
                               crabbpr.nrdconta = par_nrdconta  AND
                               crabbpr.tpctrpro = 90                   AND
                               crabbpr.nrctrpro = par_nrctrpro   AND
                               crabbpr.idseqbem = par_idseqbem 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                 
            IF  NOT AVAIL crabbpr THEN
                DO:
                    IF  LOCKED(crabbpr)   THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    /* encontra o usuario que esta travando */
                                    ASSIGN aux_cdcritic = 341.
                                    LEAVE ContadorAliena.
                                END.
                            ELSE 
                                DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT ContadorAliena.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 55.
                            LEAVE ContadorAliena.
                        END.
                END.
            ELSE
                LEAVE ContadorAliena.

        END. /* ContadorAliena */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        IF  par_cddopcao = "A" THEN
            DO:
                ASSIGN ant_flgalfid     = crabbpr.flgalfid
                       crabbpr.flgalfid = par_flgalfid.
                
                RUN proc_log 
                    ( INPUT par_cdcooper,
                      INPUT par_dtmvtolt,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_nrdconta,
                      INPUT par_nrctrpro,
                      INPUT crabbpr.dsbemfin,
                      INPUT "a alienacao",
                      INPUT "flgalfid",
                      INPUT STRING(ant_flgalfid,"Ok/Pendente"),
                      INPUT STRING(crabbpr.flgalfid,"Ok/Pendente")).
        
                IF  par_flgperte THEN
                    DO:
                        ASSIGN aux_returnvl = "OK".
                        LEAVE Grava.
                    END.
        
                ASSIGN ant_dtvigseg     = crabbpr.dtvigseg
                       crabbpr.dtvigseg = par_dtvigseg

                       ant_flglbseg     = crabbpr.flglbseg
                       crabbpr.flglbseg = par_flglbseg

                       ant_flgrgcar     = crabbpr.flgrgcar
                       crabbpr.flgrgcar = par_flgrgcar

                       crabbpr.flgsegur = IF  (par_dtvigseg = ? OR 
                                              par_dtvigseg < par_dtmvtolt) THEN
                                              FALSE
                                          ELSE 
                                              TRUE.
                
                RUN proc_log 
                    ( INPUT par_cdcooper,
                      INPUT par_dtmvtolt,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_nrdconta,
                      INPUT par_nrctrpro,
                      INPUT crabbpr.dsbemfin,
                      INPUT "o vencimento do seguro",
                      INPUT "dtvigseg",
                      INPUT STRING(ant_dtvigseg),
                      INPUT STRING(crabbpr.dtvigseg)).
        
                RUN proc_log 
                    ( INPUT par_cdcooper,
                      INPUT par_dtmvtolt,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_nrdconta,
                      INPUT par_nrctrpro,
                      INPUT crabbpr.dsbemfin,
                      INPUT "o liberado do seguro",
                      INPUT "flglbseg",
                      INPUT STRING(ant_flglbseg,"Sim/Nao"),
                      INPUT STRING(crabbpr.flglbseg,"Sim/Nao")).
        
                RUN proc_log 
                    ( INPUT par_cdcooper,
                      INPUT par_dtmvtolt,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_nrdconta,
                      INPUT par_nrctrpro,
                      INPUT crabbpr.dsbemfin,
                      INPUT "o registro cartorio",
                      INPUT "flgrgcar",
                      INPUT STRING(ant_flgrgcar,"Sim/Nao"),
                      INPUT STRING(crabbpr.flgrgcar,"Sim/Nao")).


            END. /* par_cddopcao = "A" */
        ELSE
        IF  par_cddopcao = "S" THEN
            DO:
                ASSIGN 
                   ant_dtvigseg     = crabbpr.dtvigseg
                   crabbpr.dtvigseg = par_dtvigseg
                   
                   crabbpr.flgsegur = IF  (par_dtvigseg = ? OR
                                          par_dtvigseg < par_dtmvtolt) THEN
                                          FALSE
                                      ELSE 
                                          TRUE.
                
                    RUN proc_log 
                        ( INPUT par_cdcooper,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_nrdconta,
                          INPUT par_nrctrpro,
                          INPUT crabbpr.dsbemfin,
                          INPUT "o vencimento do seguro",
                          INPUT "dtvigseg",
                          INPUT STRING(ant_dtvigseg),
                          INPUT STRING(crabbpr.dtvigseg)).

            END. /* par_cddopcao = "S" */

        ASSIGN aux_returnvl = "OK".

        LEAVE Grava.
        
    END. /* Grava */

    RELEASE crabbpr.

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

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".


    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados*/

/*............................ PROCEDURES INTERNAS ..........................*/

/* ------------------------------------------------------------------------- */
/*          Procedure para criar registro de uma mensagem de alerta          */
/* ------------------------------------------------------------------------- */
PROCEDURE cria-registro-msg:
    
    DEF  INPUT PARAM par_dsmensag AS CHAR                           NO-UNDO.

    CREATE tt-mensagens.
    ASSIGN aux_nrsequen = aux_nrsequen + 1
           tt-mensagens.nrsequen = aux_nrsequen
           tt-mensagens.dsmensag = par_dsmensag.

    RETURN "OK".
           
END PROCEDURE.

/* ------------------------------------------------------------------------- */
/*                      Procedure que loga alteracoes                        */
/* ------------------------------------------------------------------------- */
PROCEDURE proc_log:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsbemfin AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdcampo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vldantes AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vldepois AS CHAR                           NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.
    
    IF  par_vldantes = par_vldepois   THEN
        RETURN "OK".

    FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

    IF  NOT AVAIL crabcop THEN
        RETURN "NOK".

    ASSIGN par_vldantes = "baixa" WHEN par_vldantes = ?
           par_vldepois = "baixa" WHEN par_vldepois = ?.

    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999") + " "     +
                      STRING(TIME,"HH:MM:SS") + "' --> ' Operador "          +
                      par_cdoperad + " - alterou da conta "                  +
                      STRING(par_nrdconta,"zzzz,zzz,9") + ", contrato "      +
                      STRING(par_nrctremp,"zz,zzz,zz9")  + ", bem "           +
                      par_dsbemfin + ", " + par_dsdcampo   +
                      " de " + par_vldantes + " para " + par_vldepois        + 
                      " >> /usr/coop/" + TRIM(crabcop.dsdircop) + 
                      "/log/aliena.log").
    
    IF  ( aux_flgfirst ) THEN 
        DO:
            ASSIGN aux_flgfirst = FALSE.
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT YES,
                                INPUT 1, /** idseqttl **/
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
            
        END.

    RUN proc_gerar_log_item 
        ( INPUT aux_nrdrowid,
          INPUT par_nmdcampo,
          INPUT par_vldantes,
          INPUT par_vldepois ).
                    

    RETURN "OK".

END PROCEDURE. /* proc_log */

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ):
/*-----------------------------------------------------------------------------
  Objetivo:  Valida o digito verificador
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
