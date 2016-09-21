/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0094.p
    Autor   : Gabriel Capoia dos Santos (DB1)
    Data    : Junho/2011                        Ultima atualizacao: 05/09/2014

    Objetivo  : Tranformacao BO tela MANTAL

    Alteracoes:  13/08/2012 - Alteração de texto de cancelamento de cheque 
                              quando for pessoa Juridica - PJ. (Lucas R.).
                              
                26/09/2012 - Inclusao de verificacao de cheque em custodia
                            (Lucas R.).   
                            
                26/11/2012 - Retirado chamadas para inclusão de logs através da
                             BO b1wgenvlog.i (Daniel).  
                             
                27/02/2013 - Inclusao do filtro
                             crapfdc.dtlibtic >= par_dtmvtolt onde
                             aux_cdcritic = 950. (Fabricio)
                             
                01/04/2014 - Adicionado crapfdc.dtlibtic <> ? onde
                             aux_cdcritic = 950. (Fabricio)
                             
                11/06/2014 - Somente emitir a crítica 950 apenas se a 
                             crapfdc.dtlibtic >= data do movimento (SD. 163588 - Lunelli)
                             
                05/09/2014 - Ajustes ref. ao Projeto 198-Viacon (Rafael).
   
.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/b1wgen0094tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM 
                                         &TELA-MANTAL=SIM }
                                         
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.

DEF VAR rel_mmmvtolt AS CHAR    FORMAT "x(17)"  EXTENT 12 
                                    INIT["de  Janeiro  de","de Fevereiro de",
                                         "de   Marco   de","de   Abril   de",
                                         "de   Maio    de","de   Junho   de",
                                         "de   Julho   de","de   Agosto  de",
                                         "de  Setembro de","de  Outubro  de",
                                         "de  Novembro de","de  Dezembro de"]
                                                                    NO-UNDO.

DEF STREAM str_1.

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

FUNCTION VerCcf RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrdconta AS INTEGER,
      INPUT par_nrchqcdv AS INTEGER ) FORWARD.

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
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-infoass.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabtrf FOR craptrf.
        
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Manutencao dos Talonarios"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-infoass.
        EMPTY TEMP-TABLE tt-erro.
        
        IF  NOT CAN-DO ("B,D",par_cddopcao) THEN
            DO:
                ASSIGN aux_cdcritic = 014.
                LEAVE Busca.
            END.

        IF  par_nrdconta <= 0 THEN
            DO:
                ASSIGN aux_cdcritic = 127.
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

        CREATE tt-infoass.
        ASSIGN 
            tt-infoass.cdcooper = crabass.cdcooper
            tt-infoass.nrdconta = crabass.nrdconta
            tt-infoass.nmprimtl = crabass.nmprimtl.

        FOR FIRST crabtrf WHERE crabtrf.cdcooper = crabass.cdcooper AND
                                crabtrf.nrdconta = crabass.nrdconta AND
                                crabtrf.tptransa = 1                AND
                                crabtrf.insittrs = 2 NO-LOCK:
        END.

        IF  AVAILABLE crabtrf THEN
            DO:
                ASSIGN aux_dscritic = "Conta transferida para " +
                                      TRIM(STRING(crabtrf.nrsconta,
                                                  "zzzz,zzz,9")).
                LEAVE Busca.
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

END PROCEDURE. /*Busca_Dados*/
                                                             
/* ------------------------------------------------------------------------- */
/*                            Verifica Opcao Banco                           */
/* ------------------------------------------------------------------------- */
PROCEDURE Busca_Agencia:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdagechq AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           par_cdagechq = 0.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_cdbanchq <= 0 THEN
            DO:
                ASSIGN aux_cdcritic = 57.
                LEAVE Busca.
            END.
        
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE Busca.
            END.

        IF  par_cdbanchq = 1  THEN
            /* Banco do Brasil - sem DV */
            ASSIGN par_cdagechq = INT(SUBSTRING(STRING(crapcop.cdagedbb),1,
                                  LENGTH(STRING(crapcop.cdagedbb)) - 1)).
        ELSE
        IF  par_cdbanchq = 756  THEN
            ASSIGN par_cdagechq = crapcop.cdagebcb. /* BANCOOB */
        ELSE
        IF  par_cdbanchq = crapcop.cdbcoctl  THEN
            ASSIGN par_cdagechq = crapcop.cdagectl. /* CECRED */
        ELSE
            ASSIGN par_cdagechq = 0.

        LEAVE Busca.
    END. /* Busca */
    
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
  
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Agencia */

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
    DEF  INPUT PARAM par_nrctachq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinichq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrfimchq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nrinichq AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_nrfimchq AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-chequedc.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsdctitg AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.
    DEF VAR aux_nrsequen AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen9998 AS HANDLE                                  NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida Manutencao dos Talonarios"
           aux_cdcritic = 0
           aux_nrinichq = 0
           aux_nrfimchq = 0
           par_nmdcampo = ""
           aux_returnvl = "NOK".
    
    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_cdbanchq <= 0 THEN
            DO:
                ASSIGN aux_cdcritic = 57
                       par_nmdcampo = "cdbanchq".
                LEAVE Valida.
            END.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass   THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       par_nmdcampo = "cdbanchq".
                LEAVE Valida.
            END.

        IF  par_nrctachq <= 0 THEN
            DO:
                ASSIGN aux_cdcritic = 127
                       par_nmdcampo = "nrctachq".
                LEAVE Valida.
            END.

        /* Validar o digito da conta */
        IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrctachq ) THEN
            DO:
               ASSIGN aux_cdcritic = 8
                      par_nmdcampo = "nrctachq".
               LEAVE Valida.
            END.

        IF  NOT VALID-HANDLE(h-b1wgen9998)  THEN
            RUN sistema/generico/procedures/b1wgen9998.p
                PERSISTENT SET h-b1wgen9998.

        RUN dig_bbx IN h-b1wgen9998
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_nrctachq,
             OUTPUT aux_dsdctitg,
             OUTPUT TABLE tt-erro ).

        IF  VALID-HANDLE(h-b1wgen9998)  THEN
            DELETE PROCEDURE h-b1wgen9998.

        IF  RETURN-VALUE <> "OK"  THEN
            DO:
                IF  par_nrctachq <> par_nrdconta THEN
                    DO:
                        /* Projeto 198-Viacon (Rafael) */
                        FIND craptco WHERE 
                             craptco.cdcooper = par_cdcooper AND
                             craptco.nrdconta = par_nrdconta
                             NO-LOCK NO-ERROR.

                        IF (AVAIL craptco AND 
                            craptco.nrctaant <> par_nrctachq) OR 
                            NOT AVAIL craptco THEN DO:
                                ASSIGN par_nmdcampo = "nrctachq".
                                LEAVE Valida.         
                        END.
                    END.
                ELSE 
                    EMPTY TEMP-TABLE tt-erro.
            END.

        /*Se for BB, cheque de conta ITG, tem que ter conta integracao ativa*/
        IF  par_cdbanchq     = 1             AND
            crapass.nrdctitg = aux_dsdctitg  AND
            (crapass.nrdctitg = ""    OR
            crapass.flgctitg <> 2)   THEN
            DO:
                ASSIGN aux_cdcritic = 860.
                       par_nmdcampo = "cdbanchq".
                LEAVE Valida.
            END.

        IF  par_nrinichq = 0  AND
            par_nrfimchq = 0  THEN
            DO:
                ASSIGN aux_cdcritic = 129.
                       par_nmdcampo = "nrinichq".
                LEAVE Valida.
            END.

        IF  par_nrinichq > 0   THEN
            DO:
                /* Validar o digito do cheque */
                IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_nrinichq ) THEN
                    DO:
                       ASSIGN aux_cdcritic = 8
                              par_nmdcampo = "nrinichq".
                       LEAVE Valida.
                    END.

                ASSIGN aux_nrinichq = 
                               INT(SUBSTR(STRING(par_nrinichq,"9999999"),1,6)).

            END.

        IF  par_nrfimchq > 0   THEN
            DO:
                /* Validar o digito do cheque */
                IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_nrfimchq ) THEN
                    DO:
                       ASSIGN aux_cdcritic = 8
                              par_nmdcampo = "nrfimchq".
                       LEAVE Valida.
                    END.

                IF  par_nrinichq > par_nrfimchq   OR
                    par_nrinichq = 0              THEN
                    DO: 
                        ASSIGN aux_cdcritic = 129
                               par_nmdcampo = "nrinichq".
                        LEAVE Valida.
                    END.

                ASSIGN aux_nrfimchq = 
                               INT(SUBSTR(STRING(par_nrfimchq,"9999999"),1,6)).

            END.

        IF  aux_nrfimchq = 0   THEN
            ASSIGN aux_nrfimchq = aux_nrinichq.
        
        EMPTY TEMP-TABLE tt-chequedc.
        EMPTY TEMP-TABLE tt-criticas.
        
        RUN Ver_Custodia_Desconto
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_cdoperad,
              INPUT par_idorigem,
              INPUT par_nmdatela,
              INPUT par_dtmvtolt,
              INPUT par_nrdconta,
              INPUT par_cdbanchq,
              INPUT par_cdagechq,
              INPUT par_nrctachq,
              INPUT aux_nrinichq,
              INPUT aux_nrfimchq,
              INPUT par_cddopcao,
              INPUT FALSE,    /*flgerlog*/
              INPUT-OUTPUT aux_nrdrowid,
              INPUT-OUTPUT aux_nrsequen,
             OUTPUT TABLE tt-chequedc,
             INPUT-OUTPUT TABLE tt-criticas ).
                                        
        ASSIGN aux_returnvl = "OK".

        LEAVE Valida.

    END. /*Valida*/

    IF  VALID-HANDLE(h-b1wgen9998) THEN
        DELETE OBJECT h-b1wgen9998.
   
    IF  aux_dscritic <> "" OR 
        aux_cdcritic <> 0  OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
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
                    IF AVAIL(tt-erro) THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
               END.

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

END PROCEDURE. /*Valida_Dados*/

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
    DEF  INPUT PARAM par_nrctachq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinichq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrfimchq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-criticas.
    DEF OUTPUT PARAM TABLE FOR tt-cheques.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0095 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_cont     AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcalcul AS INTE                                    NO-UNDO.
    DEF VAR aux_idsucess AS ROWID                                   NO-UNDO.
    DEF VAR aux_idcritic AS ROWID                                   NO-UNDO.
    DEF VAR aux_nridsuce AS INTE                                    NO-UNDO.
    DEF VAR aux_nridcrit AS INTE                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabbss FOR crapass.
    DEF BUFFER crabcop FOR crapcop.

    ASSIGN aux_dscritic = ""
           aux_dstransa = "Grava Manutencao dos Talonarios"
           aux_cdcritic = 0
           aux_idsucess = ?
           aux_idcritic = ?
           aux_nridsuce = 0
           aux_nridcrit = 0
           aux_returnvl = "NOK".
    
    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-criticas.
        EMPTY TEMP-TABLE tt-cheques. 
        EMPTY TEMP-TABLE tt-erro.    

        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAIL crabcop THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                UNDO Grava, LEAVE Grava.
            END.
            
        FOR FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK: END.
                   
        IF  NOT AVAIL crapass THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                UNDO Grava, LEAVE Grava.
            END.
        
        Cheques: DO aux_cont = par_nrinichq TO par_nrfimchq:
            
            ASSIGN aux_nrcalcul = aux_cont * 10
                   aux_cdcritic = 0.

            IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                RUN sistema/generico/procedures/b1wgen9999.p 
                    PERSISTENT SET h-b1wgen9999.
            
            RUN dig_fun IN h-b1wgen9999 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT-OUTPUT aux_nrcalcul,
                 OUTPUT TABLE tt-erro ).

            EMPTY TEMP-TABLE tt-erro.
            
            IF  VALID-HANDLE(h-b1wgen9999) THEN
                DELETE OBJECT h-b1wgen9999.

            FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper   AND
                               crapfdc.cdbanchq = par_cdbanchq   AND
                               crapfdc.cdagechq = par_cdagechq   AND
                               crapfdc.nrctachq = par_nrctachq   AND
                               crapfdc.nrcheque = aux_cont
                               USE-INDEX crapfdc1 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAILABLE crapfdc   THEN
                IF  LOCKED crapfdc   THEN
                    DO:
                        RUN Cria_Critica
                            ( INPUT par_cdcooper,
                              INPUT par_cdoperad,
                              INPUT par_idorigem,
                              INPUT par_nmdatela,
                              INPUT par_nrdconta,
                              INPUT "Criticas",
                              INPUT par_cdbanchq,
                              INPUT par_cdagechq,
                              INPUT par_nrctachq,
                              INPUT aux_nrcalcul,
                              INPUT 341, /*cdcritic*/
                              INPUT par_flgerlog,
                              INPUT-OUTPUT aux_idcritic,
                              INPUT-OUTPUT aux_nridcrit,
                              INPUT-OUTPUT TABLE tt-criticas ).
                        
                        NEXT Cheques.
                    END.
                ELSE
                    DO:
                        RUN Cria_Critica
                            ( INPUT par_cdcooper,
                              INPUT par_cdoperad,
                              INPUT par_idorigem,
                              INPUT par_nmdatela,
                              INPUT par_nrdconta,
                              INPUT "Criticas",
                              INPUT par_cdbanchq,
                              INPUT par_cdagechq,
                              INPUT par_nrctachq,
                              INPUT aux_nrcalcul,
                              INPUT 268, /*cdcritic*/
                              INPUT par_flgerlog,
                              INPUT-OUTPUT aux_idcritic,
                              INPUT-OUTPUT aux_nridcrit,
                              INPUT-OUTPUT TABLE tt-criticas ).
                        
                        NEXT Cheques.
                    END.
                
            { sistema/generico/includes/b1wgenalog.i }

            RUN Ver_Custodia_Desconto
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_cdoperad,
                  INPUT par_idorigem,
                  INPUT par_nmdatela,
                  INPUT par_dtmvtolt,
                  INPUT par_nrdconta,
                  INPUT par_cdbanchq,
                  INPUT par_cdagechq,
                  INPUT par_nrctachq,
                  INPUT aux_cont, /*nrinichq*/
                  INPUT aux_cont, /*nrfimchq*/
                  INPUT par_cddopcao,
                  INPUT par_flgerlog,
                  INPUT-OUTPUT aux_idcritic,
                  INPUT-OUTPUT aux_nridcrit,
                 OUTPUT TABLE tt-chequedc,
                 INPUT-OUTPUT TABLE tt-criticas ).
            
            IF  RETURN-VALUE = "NOK" THEN
                NEXT Cheques.

            IF  par_cddopcao = "B" THEN
                DO:
                    ASSIGN log_cddopcao = par_cddopcao
                           log_nrdctabb = par_nrctachq
                           log_nrdocmto = INT(STRING(crapfdc.nrcheque) +
                                              STRING(crapfdc.nrdigchq)).

                    IF    crapfdc.incheque = 0             AND
                        ((crapfdc.cdbantic = 0             AND 
                          crapfdc.cdagetic = 0             AND
                          crapfdc.nrctatic = 0)            OR
                         (crapfdc.dtlibtic < par_dtmvtolt  AND
                          crapfdc.dtlibtic <> ?))          THEN
                        ASSIGN crapfdc.incheque = 8.
                     ELSE
                          DO:
                              IF  (crapfdc.cdbantic <> 0            OR 
                                   crapfdc.cdagetic <> 0            OR
                                   crapfdc.nrctatic <> 0)           THEN
                                  ASSIGN aux_cdcritic = 950.                             
                              ELSE
                              IF  crapfdc.incheque = 1   THEN
                                  ASSIGN aux_cdcritic = 96.
                              ELSE
                              IF  crapfdc.incheque = 2   THEN
                                  ASSIGN aux_cdcritic = 257.
                              ELSE
                              IF  crapfdc.incheque = 5   THEN
                                  ASSIGN aux_cdcritic = 97.
                              ELSE
                              IF  crapfdc.incheque = 8   THEN
                                  ASSIGN aux_cdcritic = 320.
                              ELSE
                                  ASSIGN aux_cdcritic = 999.

                            RUN Cria_Critica
                                ( INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT par_idorigem,
                                  INPUT par_nmdatela,
                                  INPUT par_nrdconta,
                                  INPUT "Criticas",
                                  INPUT par_cdbanchq,
                                  INPUT par_cdagechq,
                                  INPUT par_nrctachq,
                                  INPUT aux_nrcalcul,
                                  INPUT aux_cdcritic,
                                  INPUT par_flgerlog,
                                  INPUT-OUTPUT aux_idcritic,
                                  INPUT-OUTPUT aux_nridcrit,
                                  INPUT-OUTPUT TABLE tt-criticas ).
                            
                            ASSIGN aux_cdcritic = 0.
                            NEXT Cheques. 
                        END.

                    IF  crapfdc.dtretchq = ?   THEN
                        ASSIGN crapfdc.dtretchq = 01/01/0001.

                    ASSIGN crapfdc.dtliqchq = par_dtmvtolt
                           crapfdc.cdoperad = par_cdoperad.

                    CREATE tt-cheques.
                    ASSIGN tt-cheques.cdbanchq = crapfdc.cdbanchq
                           tt-cheques.cdagechq = crapfdc.cdagechq
                           tt-cheques.nrctachq = crapfdc.nrctachq
                           tt-cheques.nrcheque = aux_nrcalcul.

                    IF  par_flgerlog THEN
                        RUN Cria_Log
                            ( INPUT par_cdcooper,
                              INPUT par_cdoperad,
                              INPUT par_idorigem,
                              INPUT par_nmdatela,
                              INPUT par_nrdconta,
                              INPUT "Cancelados",
                              INPUT aux_nrcalcul,
                              INPUT par_cdbanchq,
                              INPUT par_cdagechq,
                              INPUT par_nrctachq,
                              INPUT "", /* dscritic */
                              INPUT-OUTPUT aux_idsucess,
                              INPUT-OUTPUT aux_nridsuce ).


                        /* Se nao for BANCOOB e CECRED 
                        e estiver com a conta itg correta */
                    IF  crapfdc.nrdctitg  = crapass.nrdctitg   AND
                        crapfdc.cdbanchq <> 756                AND
                        crapfdc.cdbanchq <> crabcop.cdbcoctl   THEN
                        DO:

                            IF  NOT VALID-HANDLE(h-b1wgen0095) THEN
                                RUN sistema/generico/procedures/b1wgen0095.p 
                                    PERSISTENT SET h-b1wgen0095.

                            RUN grava-crapcch IN h-b1wgen0095
                                ( INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT par_idorigem,
                                  INPUT par_nrdconta,
                                  INPUT 1,            /*idseqttl*/
                                  INPUT par_flgerlog,
                                  INPUT par_dtmvtolt,
                                  INPUT crapfdc.cdbanchq,
                                  INPUT crapfdc.nrdconta,
                                  INPUT crapfdc.nrdctabb,
                                  INPUT aux_nrcalcul, /*nrinichq*/
                                  INPUT 2,            /*cdhistor*/
                                  INPUT "2",          /*stlcmexc / Exclusão*/
                                  INPUT "1",          /*stlcmcad / Inclusão*/
                                  INPUT par_dtmvtolt, /*dtemscch*/
                                  INPUT par_nrctachq,
                                  INPUT crapfdc.nrdctitg,
                                  INPUT crapfdc.nrseqems,
                                  INPUT crapfdc.cdagechq,
                                 OUTPUT TABLE tt-erro ).

                            IF  VALID-HANDLE(h-b1wgen0095) THEN
                                DELETE OBJECT h-b1wgen0095.

                            IF  RETURN-VALUE <> "OK" THEN
                                UNDO Grava, LEAVE Grava.

                        END.

                END. /*IF par_cddopcao = "B"*/
            ELSE
            IF  par_cddopcao = "D" THEN
                DO:
                    ASSIGN log_cddopcao = par_cddopcao
                           log_nrdctabb = par_nrctachq
                           log_nrdocmto = INT(STRING(crapfdc.nrcheque) +
                                              STRING(crapfdc.nrdigchq)).

                    IF  crapfdc.incheque = 8   THEN
                        ASSIGN crapfdc.incheque = 0.
                    ELSE
                        NEXT Cheques.

                    IF  crapfdc.dtretchq = 01/01/0001   THEN
                        ASSIGN crapfdc.dtretchq = ?.
                          
                    ASSIGN crapfdc.dtliqchq = ?
                           crapfdc.cdoperad = "".

                    IF  par_flgerlog THEN
                        RUN Cria_Log
                            ( INPUT par_cdcooper,
                              INPUT par_cdoperad,
                              INPUT par_idorigem,
                              INPUT par_nmdatela,
                              INPUT par_nrdconta,
                              INPUT "Ativados",
                              INPUT aux_nrcalcul,
                              INPUT par_cdbanchq,
                              INPUT par_cdagechq,
                              INPUT par_nrctachq,
                              INPUT "", /* dscritic */
                              INPUT-OUTPUT aux_idsucess,
                              INPUT-OUTPUT aux_nridsuce ).
                    

                    /* Se nao for BANCOOB e CECRED 
                       e estiver com a conta itg correta */
                    IF  crapfdc.nrdctitg  = crapass.nrdctitg   AND
                        crapfdc.cdbanchq <> 756                AND
                        crapfdc.cdbanchq <> crabcop.cdbcoctl   THEN
                        DO:

                            IF  NOT VALID-HANDLE(h-b1wgen0095) THEN
                                RUN sistema/generico/procedures/b1wgen0095.p 
                                    PERSISTENT SET h-b1wgen0095.

                            RUN grava-crapcch IN h-b1wgen0095
                                ( INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT par_idorigem,
                                  INPUT par_nrdconta,
                                  INPUT 1,            /*idseqttl*/
                                  INPUT par_flgerlog,
                                  INPUT par_dtmvtolt,
                                  INPUT crapfdc.cdbanchq,
                                  INPUT crapfdc.nrdconta,
                                  INPUT crapfdc.nrdctabb,
                                  INPUT aux_nrcalcul, /*nrinichq*/
                                  INPUT 2,            /*cdhistor*/
                                  INPUT "1",          /*stlcmexc / Inclusão*/
                                  INPUT "2",          /*stlcmcad / Exclusão*/
                                  INPUT par_dtmvtolt, /*dtemscch*/
                                  INPUT par_nrctachq,
                                  INPUT crapfdc.nrdctitg,
                                  INPUT crapfdc.nrseqems,
                                  INPUT crapfdc.cdagechq,
                                 OUTPUT TABLE tt-erro ).

                            IF  VALID-HANDLE(h-b1wgen0095) THEN
                                DELETE OBJECT h-b1wgen0095.

                            IF  RETURN-VALUE <> "OK" THEN
                                UNDO Grava, LEAVE Grava.

                        END.
                    
                END. /*IF par_cddopcao = "D"*/

            RELEASE crapfdc.

        END. /* Fim do DO .. TO */

        ASSIGN aux_returnvl = "OK".

        LEAVE Grava.
        
    END. /*Grava*/

    RELEASE crapfdc.

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

END PROCEDURE. /*Grava_Dados*/

/* ------------------------------------------------------------------------ */
/*                          GERA IMPRESSÃO DO TERMO                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Imprime_Termo:
         
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-criticas.
    DEF  INPUT PARAM TABLE FOR tt-cheques.

    DEF  OUTPUT PARAM par_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM par_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.
                                                                            
    
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscritix AS CHAR FORMAT "x(40)"                     NO-UNDO.
    DEF VAR aux_flgexist AS LOGI INITIAL FALSE                      NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabcri FOR crapcri.
    DEF BUFFER crabass FOR crapass.
        
    ASSIGN aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Imprime Manutencao dos Talonarios"
           aux_dscritic = ""
           aux_returnvl = "NOK".
        
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crabcop FIELDS(dsdircop) 
                          WHERE crabcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        FOR FIRST crabass WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK: END.
                   
        IF  NOT AVAIL crabass THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.
    
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN 
            aux_nmendter = aux_nmendter + STRING(TIME)
            aux_nmarqimp = aux_nmendter + ".ex"
            aux_nmarqpdf = aux_nmendter + ".pdf".

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        FIND FIRST tt-cheques NO-ERROR.
        
        IF  AVAILABLE tt-cheques   THEN
            DO:
                RUN lista_cheques_baixados
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_dtmvtolt,
                      INPUT par_nmoperad,
                      INPUT crabass.nmprimtl,
                      INPUT crabass.nrdconta,
                      INPUT TABLE tt-cheques,
                     OUTPUT aux_flgexist,
                     OUTPUT TABLE tt-erro).
                
                IF  RETURN-VALUE = "NOK" THEN
                    LEAVE Imprime.
    
            END.
        
        FIND FIRST tt-criticas NO-LOCK NO-ERROR.
    
        IF  AVAILABLE tt-criticas   THEN
            DO:
                PAGE STREAM str_1.
    
                DISPLAY STREAM str_1
                        "\022\024\033\120"     /* Reseta impressora */
                        crabass.nrdconta
                        crabass.nmprimtl
                        SKIP(1)
                        "CRITICAS NA BAIXA DOS CHEQUES:"
                        SKIP(1)
                        WITH NO-BOX SIDE-LABELS FRAME f_cab_critica.
                            
                FOR EACH tt-criticas NO-LOCK:
                
                    FIND crabcri OF tt-criticas NO-LOCK NO-ERROR.
                    
                    IF   NOT AVAILABLE crabcri   THEN
                         aux_dscritix = STRING(tt-criticas.cdcritic).
                    ELSE
                         aux_dscritix = crabcri.dscritic.
                         
                    DISPLAY STREAM str_1
                            tt-criticas.cdbanchq LABEL "BANCO"
                            tt-criticas.cdagechq LABEL "AGENCIA"
                            tt-criticas.nrctachq LABEL "CONTA CHEQUE"
                            tt-criticas.nrcheque LABEL "CHEQUE"
                            aux_dscritix         LABEL "CRITICA"
                            WITH NO-BOX DOWN FRAME f_criticas.
                            
                    DOWN STREAM str_1 WITH FRAME f_criticas.
                    
                END.  /*  Fim do FOR EACH w_criticas  */
    
                DISPLAY STREAM str_1
                        SKIP(1)
                        "**************************************" SKIP
                        "** ESTES CHEQUES NAO FORAM BAIXADOS **" SKIP
                        "**************************************" SKIP
                        WITH NO-BOX FRAME f_fim_criticas.
            
                ASSIGN aux_flgexist = TRUE.
                
            END.
        
        OUTPUT STREAM str_1 CLOSE.
        
        IF  NOT aux_flgexist THEN
            DO:
                ASSIGN aux_cdcritic = 263
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

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
                       + ':/var/www/ayllos/documentos/' + crabcop.dsdircop
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
    
    END. /*Imprime*/
    
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
    
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT 1, /*idseqttl*/
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

END. /*Imprime_Termo*/

/*............................ PROCEDURES INTERNAS ..........................*/

PROCEDURE Ver_Custodia_Desconto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinichq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrfimchq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF INPUT-OUTPUT PARAM par_nrdrowid AS ROWID                    NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_nrsequen AS INTE                     NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-chequedc.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-criticas.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcalcul AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcheque AS INTE                                    NO-UNDO.
    DEF VAR aux_cdbanchq AS INTE                                    NO-UNDO.
    DEF VAR aux_cdagechq AS INTE                                    NO-UNDO.
    DEF VAR aux_cdpesqui AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmoperad LIKE crapope.nmoperad                      NO-UNDO.
    
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabbss FOR crapass.
    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabcdb FOR crapcdb.
    DEF BUFFER crabfdc FOR crapfdc.
    DEF BUFFER crabcst FOR crapcst.
    DEF BUFFER crabope FOR crapope.

    ASSIGN aux_cdcritic = 0
           aux_returnvl = "NOK".
        
    Verifica: DO ON ERROR UNDO Verifica, LEAVE Verifica:

        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAIL crabcop THEN
            LEAVE Verifica.
        
        FOR FIRST crabass WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK: END.
                   
        IF  NOT AVAIL crabass THEN
            LEAVE Verifica.

        Cheques: DO aux_contador = par_nrinichq TO par_nrfimchq:

            ASSIGN aux_nrcalcul = aux_contador * 10
                   aux_cdcritic = 0.

            IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                RUN sistema/generico/procedures/b1wgen9999.p 
                    PERSISTENT SET h-b1wgen9999.
            
            RUN dig_fun IN h-b1wgen9999 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT-OUTPUT aux_nrcalcul,
                 OUTPUT TABLE tt-erro ).

            EMPTY TEMP-TABLE tt-erro.
            
            DELETE OBJECT h-b1wgen9999.

            FOR FIRST crabfdc WHERE crabfdc.cdcooper = par_cdcooper AND
                                    crabfdc.cdbanchq = par_cdbanchq AND
                                    crabfdc.cdagechq = par_cdagechq AND
                                    crabfdc.nrctachq = par_nrctachq AND
                                    crabfdc.nrcheque = aux_contador NO-LOCK
                                    USE-INDEX crapfdc1: END.

            IF  NOT AVAILABLE crabfdc  THEN
                NEXT.

            IF  crabfdc.nrdconta <> par_nrdconta THEN
                DO:
                    RUN Cria_Critica
                        ( INPUT par_cdcooper,
                          INPUT par_cdoperad,
                          INPUT par_idorigem,
                          INPUT par_nmdatela,
                          INPUT par_nrdconta,
                          INPUT "Criticas",
                          INPUT par_cdbanchq,
                          INPUT par_cdagechq,
                          INPUT par_nrctachq,
                          INPUT aux_nrcalcul,
                          INPUT 127, /*cdcritic*/
                          INPUT par_flgerlog,
                          INPUT-OUTPUT par_nrdrowid,
                          INPUT-OUTPUT par_nrsequen,
                          INPUT-OUTPUT TABLE tt-criticas ).

                    NEXT Cheques.
                END.

            IF  crabfdc.dtemschq = ? THEN
                DO:
                    RUN Cria_Critica
                        ( INPUT par_cdcooper,
                          INPUT par_cdoperad,
                          INPUT par_idorigem,
                          INPUT par_nmdatela,
                          INPUT par_nrdconta,
                          INPUT "Criticas",
                          INPUT par_cdbanchq,
                          INPUT par_cdagechq,
                          INPUT par_nrctachq,
                          INPUT aux_nrcalcul,
                          INPUT 108, /*cdcritic*/
                          INPUT par_flgerlog,
                          INPUT-OUTPUT par_nrdrowid,
                          INPUT-OUTPUT par_nrsequen,
                          INPUT-OUTPUT TABLE tt-criticas ).

                    NEXT Cheques. 
                END.

            IF  par_cddopcao = "D" THEN
                NEXT Cheques.

            IF  VerCcf ( INPUT par_cdcooper,
                         INPUT par_nrdconta,
                         INPUT aux_nrcalcul ) THEN
                DO:
                    RUN Cria_Critica
                        ( INPUT par_cdcooper,
                          INPUT par_cdoperad,
                          INPUT par_idorigem,
                          INPUT par_nmdatela,
                          INPUT par_nrdconta,
                          INPUT "Criticas",
                          INPUT par_cdbanchq,
                          INPUT par_cdagechq,
                          INPUT par_nrctachq,
                          INPUT aux_nrcalcul,
                          INPUT 749, /*cdcritic*/
                          INPUT par_flgerlog,
                          INPUT-OUTPUT par_nrdrowid,
                          INPUT-OUTPUT par_nrsequen,
                          INPUT-OUTPUT TABLE tt-criticas ).
                    NEXT Cheques. 
                END.
                

            ASSIGN aux_nrcheque = INT(SUBSTR(STRING(aux_nrcalcul,"9999999"),1,6))
                   aux_cdbanchq = crabfdc.cdbanchq
                   aux_cdagechq = 
                         IF  par_cdbanchq = 756 THEN
                             crabcop.cdagebcb
                         ELSE
                         IF  aux_cdbanchq = crabcop.cdbcoctl THEN
                             /*crabcop.cdagectl - Projeto 198-Viacon (Rafael) */
                             crabfdc.cdagechq
                         ELSE
                             INT(SUBSTR(STRING(crabcop.cdagedbb,"9999999"),1,6)).
                  
            FOR FIRST crabcdb WHERE crabcdb.cdcooper = par_cdcooper     AND
                                    crabcdb.cdcmpchq = crabfdc.cdcmpchq AND
                                    crabcdb.cdbanchq = aux_cdbanchq     AND
                                    crabcdb.cdagechq = aux_cdagechq     AND
                                    crabcdb.nrctachq = crabfdc.nrdctabb AND
                                    crabcdb.nrcheque = aux_nrcheque     AND
                                    crabcdb.dtdevolu = ?                AND
                                    crabcdb.dtlibera >= par_dtmvtolt NO-LOCK
                                    USE-INDEX crapcdb5: END.

            IF  AVAILABLE crabcdb THEN
                DO:
                    
                    FOR FIRST crabbss WHERE crabbss.cdcooper = par_cdcooper AND
                                            crabbss.nrdconta = crabcdb.nrdconta
                                            NO-LOCK: END.

                    IF  NOT AVAIL crabbss THEN
                        NEXT.

                    FOR FIRST crabope WHERE crabope.cdcooper = par_cdcooper AND
                                            crabope.cdoperad = crabcdb.cdoperad
                                            NO-LOCK: END.

                    /* Projeto 198-Viacon (Rafael) IF  NOT AVAIL crabope THEN
                        NEXT.*/

                    /* Projeto 198-Viacon (Rafael) */
                    IF  NOT AVAIL crabope THEN
                        ASSIGN aux_nmoperad = "NAO_CADASTRADO".
                    ELSE
                        ASSIGN aux_nmoperad = ENTRY(1,crabope.nmoperad," ").

                    ASSIGN aux_cdpesqui = 
                                  STRING(crabcdb.dtmvtolt,"99/99/9999") + "-" +
                                  STRING(crabcdb.cdagenci,"999") + "-" +
                                  STRING(crabcdb.cdbccxlt,"999") + "-" +
                                  STRING(crabcdb.nrdolote,"999999") + "-" +
                                  aux_nmoperad.

                    CREATE tt-chequedc.
                    ASSIGN tt-chequedc.nrdconta = crabbss.nrdconta
                           tt-chequedc.nmprimtl = crabbss.nmprimtl
                           tt-chequedc.nrcheque = crabcdb.nrcheque
                           tt-chequedc.nrborder = crabcdb.nrborder
                           tt-chequedc.dtlibera = crabcdb.dtlibera
                           tt-chequedc.cdpesqui = aux_cdpesqui
                           tt-chequedc.tpcheque = "D" /*Desconto*/
                           aux_cdcritic         = 811.
                    
                END.

            IF  aux_cdcritic = 0 THEN
                DO:
                    FOR FIRST crabcst WHERE 
                                      crabcst.cdcooper = par_cdcooper       AND
                                      crabcst.cdcmpchq = crabfdc.cdcmpchq   AND
                                      crabcst.cdbanchq = aux_cdbanchq       AND
                                      crabcst.cdagechq = aux_cdagechq       AND
                                      crabcst.nrctachq = crabfdc.nrdctabb   AND
                                      crabcst.nrcheque = aux_nrcheque       AND
                                      crabcst.dtdevolu = ? USE-INDEX crapcst5 
                                      NO-LOCK: END.

                    IF  NOT AVAILABLE crabcst   THEN
                        FOR FIRST crabcst WHERE 
                                        crabcst.cdcooper = par_cdcooper     AND
                                        crabcst.cdcmpchq = crabfdc.cdcmpchq AND
                                        crabcst.cdbanchq = aux_cdbanchq     AND
                                        crabcst.cdagechq = 95               AND
                                        crabcst.nrctachq = crabfdc.nrdctabb AND
                                        crabcst.nrcheque = aux_nrcheque     AND
                                        crabcst.dtdevolu = ? USE-INDEX crapcst5
                                        NO-LOCK: END.

                    IF  AVAILABLE crabcst THEN
                        IF  crabcst.dtlibera >= par_dtmvtolt THEN
                            DO:
                                FOR FIRST crabbss WHERE 
                                            crabbss.cdcooper = par_cdcooper AND
                                            crabbss.nrdconta = crabcst.nrdconta
                                            NO-LOCK: END.

                                IF  NOT AVAIL crabbss THEN
                                    NEXT.

                                FOR FIRST crabope WHERE 
                                            crabope.cdcooper = par_cdcooper AND
                                            crabope.cdoperad = crabcst.cdoperad
                                            NO-LOCK: END.

                                /* Projeto 198-Viacon (Rafael) IF  NOT AVAIL crabope THEN
                                    NEXT.*/

                                /* Projeto 198-Viacon (Rafael) */
                                IF  NOT AVAIL crabope THEN
                                    ASSIGN aux_nmoperad = "NAO_CADASTRADO".
                                ELSE
                                    ASSIGN aux_nmoperad = ENTRY(1,crabope.nmoperad," ").

                                ASSIGN aux_cdpesqui =
                                  STRING(crabcst.dtmvtolt,"99/99/9999") + "-" +
                                  STRING(crabcst.cdagenci,"999") + "-" +
                                  STRING(crabcst.cdbccxlt,"999") + "-" +
                                  STRING(crabcst.nrdolote,"999999") + "-" +
                                  aux_nmoperad.

                                CREATE tt-chequedc.
                                ASSIGN tt-chequedc.nrdconta = crabbss.nrdconta
                                       tt-chequedc.nmprimtl = crabbss.nmprimtl
                                       tt-chequedc.nrcheque = crabcst.nrcheque
                                       tt-chequedc.nrborder = 0
                                       tt-chequedc.dtlibera = crabcst.dtlibera
                                       tt-chequedc.cdpesqui = aux_cdpesqui
                                       tt-chequedc.tpcheque = "C" /*Custodia*/
                                       aux_cdcritic         = 757.

                            END.

                END. /* IF  aux_cdcritic = 0 THEN */
            
            IF  aux_cdcritic <> 0 THEN
                RUN Cria_Critica
                    ( INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_idorigem,
                      INPUT par_nmdatela,
                      INPUT par_nrdconta,
                      INPUT "Criticas",
                      INPUT par_cdbanchq,
                      INPUT par_cdagechq,
                      INPUT par_nrctachq,
                      INPUT aux_nrcalcul,
                      INPUT aux_cdcritic,
                      INPUT par_flgerlog,
                      INPUT-OUTPUT par_nrdrowid,
                      INPUT-OUTPUT par_nrsequen,
                      INPUT-OUTPUT TABLE tt-criticas ).
            ELSE
                ASSIGN aux_returnvl = "OK".

            ASSIGN aux_cdcritic = 0.


        END. /* DO aux_contador ... */

        IF  par_cddopcao = "D" THEN
            ASSIGN aux_returnvl = "OK".

    END. /*Verifica*/
    
    RETURN aux_returnvl.
        
END PROCEDURE. /*Ver_Custodia_Desconto*/

PROCEDURE Cria_Critica:

    DEF  INPUT PARAM  par_cdcooper AS INTE                          NO-UNDO.
    DEF  INPUT PARAM  par_cdoperad AS CHAR                          NO-UNDO.
    DEF  INPUT PARAM  par_idorigem AS INTE                          NO-UNDO.
    DEF  INPUT PARAM  par_nmdatela AS CHAR                          NO-UNDO.
    DEF  INPUT PARAM  par_nrdconta AS INTE                          NO-UNDO.
    DEF  INPUT PARAM  par_auxdescr AS CHAR                          NO-UNDO.
    DEF  INPUT PARAM  par_cdbanchq AS INTE                          NO-UNDO.
    DEF  INPUT PARAM  par_cdagechq AS INTE                          NO-UNDO.
    DEF  INPUT PARAM  par_nrctachq AS INTE                          NO-UNDO.
    DEF  INPUT PARAM  par_nrchqcdv AS INTE                          NO-UNDO.
    DEF  INPUT PARAM  par_cdcritic AS INTE                          NO-UNDO.
    DEF  INPUT PARAM  par_flgerlog AS LOGI                          NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_nrdrowid AS ROWID                   NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_nrsequen AS INTE                    NO-UNDO.
    DEF  INPUT-OUTPUT PARAM TABLE FOR tt-criticas.

    DEF VAR aux_dscritix AS CHAR                                    NO-UNDO.

    DEF BUFFER crabcri FOR crapcri.

    FOR FIRST crabcri WHERE crabcri.cdcritic = par_cdcritic NO-LOCK: END.
                    
    IF  NOT AVAILABLE crabcri THEN
        ASSIGN aux_dscritix = STRING(tt-criticas.cdcritic).
    ELSE
        ASSIGN aux_dscritix = crabcri.dscritic.

    CREATE tt-criticas.
    ASSIGN tt-criticas.cdbanchq = par_cdbanchq
           tt-criticas.cdagechq = par_cdagechq
           tt-criticas.nrctachq = par_nrctachq
           tt-criticas.cdcritic = par_cdcritic
           tt-criticas.nrcheque = par_nrchqcdv
           tt-criticas.dscritic = aux_dscritix.

    IF  par_flgerlog THEN
        RUN Cria_Log
            ( INPUT par_cdcooper,
              INPUT par_cdoperad,
              INPUT par_idorigem,
              INPUT par_nmdatela,
              INPUT par_nrdconta,
              INPUT par_auxdescr,
              INPUT par_nrchqcdv,
              INPUT par_cdbanchq,
              INPUT par_cdagechq,
              INPUT par_nrctachq,
              INPUT aux_dscritix,
              INPUT-OUTPUT par_nrdrowid,
              INPUT-OUTPUT par_nrsequen ).


    RETURN "OK".

END PROCEDURE. /*Cria_Critica*/

PROCEDURE Cria_Log:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_auxdescr AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrchqcdv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF  INPUT-OUTPUT PARAM par_nrdrowid AS ROWID                   NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_nrsequen AS INTE                    NO-UNDO.
    
    DEF VAR aux_dsorigem2 AS CHAR                                   NO-UNDO.
    DEF VAR aux_dstransa2 AS CHAR                                   NO-UNDO.
    
    ASSIGN aux_dsorigem2 = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa2 = "Gravacao Manutencao dos Talonarios: " +
                           par_auxdescr
           par_nrsequen  = par_nrsequen + 1.

    
    IF  par_nrdrowid = ? THEN
        RUN proc_gerar_log 
            ( INPUT par_cdcooper,
              INPUT par_cdoperad,
              INPUT "",
              INPUT aux_dsorigem2,
              INPUT aux_dstransa2,
              INPUT TRUE,
              INPUT 1, /*idseqttl*/
              INPUT par_nmdatela,
              INPUT par_nrdconta,
             OUTPUT par_nrdrowid ).

    /* nrcheque */
    RUN proc_gerar_log_item 
        ( INPUT par_nrdrowid,
          INPUT "nrcheque" + STRING(par_nrsequen),
          INPUT par_nrchqcdv,
          INPUT par_nrchqcdv ).

    /* cdbanchq */
    RUN proc_gerar_log_item 
        ( INPUT par_nrdrowid,
          INPUT "cdbanchq" + STRING(par_nrsequen),
          INPUT par_cdbanchq,
          INPUT par_cdbanchq ).

    /* cdagechq */
    RUN proc_gerar_log_item 
        ( INPUT par_nrdrowid,
          INPUT "cdagechq" + STRING(par_nrsequen),
          INPUT par_cdagechq,
          INPUT par_cdagechq ).

    /* nrctachq */
    RUN proc_gerar_log_item 
        ( INPUT par_nrdrowid,
          INPUT "nrctachq" + STRING(par_nrsequen),
          INPUT par_nrctachq,
          INPUT par_nrctachq ).

    IF  par_dscritic <> "" THEN
        DO:
            /* dscritic */
            RUN proc_gerar_log_item 
                ( INPUT par_nrdrowid,
                  INPUT "dscritic" + STRING(par_nrsequen),
                  INPUT par_dscritic,
                  INPUT par_dscritic ).

        END.

    RETURN "OK".

END PROCEDURE. /* Cria_Log */


PROCEDURE lista_cheques_baixados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR  FORMAT "x(30)"           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR  FORMAT "x(30)"           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE  FORMAT "zzzz,zzz,9"      NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-cheques.

    DEF  OUTPUT PARAM aux_flgexist AS LOGI                          NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    /* montar a data atual por extenso */
    DEF VAR aux_dsmvtolt AS CHAR  FORMAT "x(50)"                    NO-UNDO.
    DEF VAR aux_nmextcop AS CHAR  FORMAT "x(75)"                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER b-crapass1 FOR crapass.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_returnvl = "NOK".
    
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO:
                ASSIGN 
                    aux_cdcritic = 651
                    aux_dscritic = "".
                LEAVE Imprime.
            END.
    
        ASSIGN aux_dsmvtolt = crabcop.nmcidade + ", " 
                             + STRING(DAY(par_dtmvtolt)) + " " +
                            rel_mmmvtolt[MONTH(par_dtmvtolt)] + " " +
                            STRING(YEAR(par_dtmvtolt)) + ".".
        
        ASSIGN aux_nmextcop = TRIM(crabcop.nmextcop) + " - " + 
                              TRIM(crabcop.nmrescop).
        
        
        FIND b-crapass1 WHERE b-crapass1.cdcooper = par_cdcooper AND
                              b-crapass1.nrdconta = par_nrdconta 
                              NO-LOCK NO-ERROR.


        IF b-crapass1.inpessoa = 2 THEN  /*2 = Pessoa Juridica*/
            DO: 
                FORM "\022\024\033\120"     /* Reseta impressora */
                     SKIP
                     aux_dsmvtolt
                     SKIP(4)
                     "A\033\105" 
                     aux_nmextcop
                     SKIP(1)
                     "Nesta\033\106"
                     SKIP(4)
                     "Prezados Senhores:"
                     SKIP(3)
                     "A,\033\105"
                     par_nmprimtl       FORMAT "x(39)"
                     "\033\106,titular da C/C\033\105"
                     par_nrdconta
                     ",\033\106"
                     SKIP
                     "vem atraves desta, solicitar o cancelamento  das  folhas  de "
                     "cheques,"
                     SKIP
                     "conforme relacao abaixo."
                     SKIP
                     "Declara, desde ja, que os mesmos foram inutilizados e assume"
                     " inteira  e"
                     SKIP
                     "total responsabilidade  por  estas  informacoes,  inclusive,"
                     " \033\105declara-se"
                     SKIP
                     "ciente da  possibilidade  de  devolucao\033\106,  no  caso  da"
                     " apresentacao  de"
                     SKIP
                     "qualquer um dos cheques abaixo, no sistema de compensacao."
                     WITH NO-LABELS WIDTH 96 COLUMN 8 FRAME f_termo_pj.

                     DISPLAY STREAM str_1 aux_dsmvtolt              
                                          aux_nmextcop              
                                          par_nmprimtl              
                                          par_nrdconta              
                                          WITH FRAME f_termo_pj. 

            END.
            ELSE  /*Pessoa fisica*/
                DO: 
                    FORM "\022\024\033\120"     /* Reseta impressora */
                     SKIP
                     aux_dsmvtolt
                     SKIP(4)
                     "A\033\105" 
                     aux_nmextcop
                     SKIP(1)
                     "Nesta\033\106"
                     SKIP(4)
                     "Prezados Senhores:"
                     SKIP(3)
                     "Eu,\033\105"
                     par_nmprimtl       FORMAT "x(39)"
                     "\033\106,titular da C/C\033\105"
                     par_nrdconta
                     ",\033\106"
                     SKIP
                     "venho atraves desta, solicitar o cancelamento  das  folhas  de "
                     "cheques,"
                     SKIP
                     "conforme relacao abaixo."
                     SKIP
                     "Declaro, desde ja, que os mesmos foram inutilizados e assumo"
                     " inteira  e"
                     SKIP
                     "total responsabilidade  por  estas  informacoes,  inclusive,"
                     " \033\105declaro-me"
                     SKIP
                     "ciente da  possibilidade  de  devolucao\033\106,  no  caso  da"
                     " apresentacao  de"
                     SKIP
                     "qualquer um dos cheques abaixo, no sistema de compensacao."
                     WITH NO-LABELS WIDTH 96 COLUMN 8 FRAME f_termo_pf.

                     DISPLAY STREAM str_1 aux_dsmvtolt              
                                          aux_nmextcop              
                                          par_nmprimtl              
                                          par_nrdconta              
                                          WITH FRAME f_termo_pf.    

                END.
        
        
        
        
        /* impressao dos cheques cancelados */
    
        PUT STREAM str_1 SKIP(1)
                         "BANCO   AGE.  CTA.CHEQUE    CHEQUE"  AT 08
                         "BANCO   AGE.  CTA.CHEQUE    CHEQUE"  AT 45
                         SKIP(1).
        
        aux_contador = 0.
        
        FOR EACH tt-cheques:
            
            IF   aux_contador = 0   THEN      /* imprime lado esquerdo */
                 DO:
                    PUT STREAM str_1
                               tt-cheques.cdbanchq  AT 08
                               tt-cheques.cdagechq  AT 15
                               tt-cheques.nrctachq  AT 22
                               tt-cheques.nrcheque  AT 33.
    
                    aux_contador = 1.
                 END.
            ELSE                              /* impreme lado direito */
                 DO:
                    PUT STREAM str_1
                               tt-cheques.cdbanchq  AT 45
                               tt-cheques.cdagechq  AT 52
                               tt-cheques.nrctachq  AT 59
                               tt-cheques.nrcheque  AT 70
                               SKIP.
    
                    aux_contador = 0.
                 END.
                 
            IF   LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 7)   THEN
                 DO:
                    PAGE STREAM str_1.
                    PUT STREAM str_1 SKIP(1)
                               "BANCO   AGE.  CTA.CHEQUE    CHEQUE"  AT 08
                               "BANCO   AGE.  CTA.CHEQUE    CHEQUE"  AT 45
                               SKIP(1).
                 END.
        END.
        

        PUT STREAM str_1 SKIP(2)
                         "Sem mais para o momento,"       AT  8
                         SKIP(5)
                         "_____________________________"  AT 10 
                         "_____________________________"  AT 50
                         SKIP
                         par_nmprimtl                     AT 10
                         par_nmoperad                     AT 50
                         SKIP(1).
         
        ASSIGN aux_flgexist = TRUE.

    END. /*Imprime*/


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
    
    RETURN aux_returnvl.
    
END PROCEDURE. /*lista_cheques_baixados*/

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/
                                                                               
FUNCTION VerCcf RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrdconta AS INTEGER,
      INPUT par_nrchqcdv AS INTEGER ):
/*-----------------------------------------------------------------------------
  Objetivo: 
     Notas:  
-----------------------------------------------------------------------------*/

    DEF VAR aux_vlresult AS LOGICAL INIT FALSE NO-UNDO.
   
    FOR EACH crapneg WHERE crapneg.cdcooper = par_cdcooper             AND
                           crapneg.nrdconta = par_nrdconta             AND
                           crapneg.nrdocmto = par_nrchqcdv             AND
                           crapneg.cdhisest = 1                        AND
                           CAN-DO("12,13", STRING(crapneg.cdobserv))   AND
                           crapneg.dtfimest = ?                        NO-LOCK 
                           USE-INDEX crapneg1:
                             
        ASSIGN aux_vlresult = TRUE.
        
    END.  /*  Fim do FOR EACH  */

    RETURN aux_vlresult.
        
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


