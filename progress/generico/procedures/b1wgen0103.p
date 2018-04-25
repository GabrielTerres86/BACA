/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0103.p
    Autor   : Gabriel Capoia dos Santos (DB1)
    Data    : Julho/2011                        Ultima atualizacao: 10/03/2015

    Objetivo  : BO - DESEXT, EXTEMP, EXTPPR, EXTRAT, EXTRDA.

    Alteracoes: 
               04/10/2011 - Adicionado o parametro par_flgerlog na chamada da 
                            procedure extrato_cotas (Rogerius Militão - DB1)

               18/09/2012 - Novos parametros DATA na chamada da procedure
                            obtem-dados-aplicacoes (Guilherme/Supero).
                            
               13/02/2013 - Incluir chamada de procedure valida_restricao_operador
                            em Busca_Extppr, Busca_Extrda (Lucas R.)
                            
               31/07/2013 - Implementada opcao A da tela EXTRAT (Lucas).
               
               19/09/2013 - Incluida opcao AC na procedure Busca_Extrato
                            para impressao de depositos de cheque junto com
                            o extrato e geracao de PDF para web(Tiago).
               
               12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               24/04/2014 - Adicionado param. de paginacao em procedure
                             obtem-dados-emprestimos em BO 0002.(Jorge)  
                             
               03/07/2014 - Ajuste para validar permissoes de operadores
                            (Chamado 163002) (Jonata - RKAM).                                                                                     
                            
               17/10/2014 - Adicionada procedures pc_busca_aplicacoes e 
                            pc_busca_extrato_aplicacao_car. (Reinert)
                            
               10/03/2015 - Inclusao de parametro na procedure
                            pc_busca_extrato_aplicacao_car (Jean Michel).
                                         
			   07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                            departamento passando a considerar o código (Renato Darosci)   
							              
               14/03/2018 - Substituida validacao "cdtipcta = (5, 6, 7, 17, 18)" 
                            pela modalidade do tipo de conta = 2 ou 3. PRJ339 (Lombardi).
							              
.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/b1wgen0103tt.i &TT-LOG=SIM }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM 
                                       &TELA-MATRIC=SIM &TELA-CONTAS=NAO }
{ sistema/generico/includes/var_oracle.i }                                       
                                       
DEF STREAM str_1.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR h-b1wgen9998 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.
DEF VAR aux_cdmodali AS INTE                                        NO-UNDO.
DEF VAR aux_des_erro AS CHAR                                        NO-UNDO.

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                      EFETUA A BUSCA DA TELA DESEXT                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Desext:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

     DEF OUTPUT PARAM TABLE FOR tt-desext.
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF BUFFER crabass FOR crapass.
     
     ASSIGN
         aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
         aux_dstransa = "Busca Destino do Extrato"
         aux_dscritic = ""
         aux_cdcritic = 0
         aux_returnvl = "NOK".
    
     Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
         EMPTY TEMP-TABLE tt-desext.
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
         FOR FIRST crabass FIELDS(cdcooper nrdconta nmprimtl cdsecext tpextcta
                                  tpavsdeb cdagenci)
                           WHERE crabass.cdcooper = par_cdcooper AND
                                 crabass.nrdconta = par_nrdconta NO-LOCK:
         END.

         IF  NOT AVAILABLE crabass THEN
             DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE Busca.
             END.

         IF  NOT CAN-FIND(FIRST crapsld 
                                    WHERE crapsld.cdcooper = par_cdcooper AND
                                          crapsld.nrdconta = par_nrdconta) THEN
             DO:
                 ASSIGN aux_cdcritic = 10.
                 LEAVE Busca.
             END.
         
         CREATE tt-desext.
         ASSIGN 
             tt-desext.cdcooper = crabass.cdcooper
             tt-desext.nrdconta = crabass.nrdconta
             tt-desext.cdagenci = crabass.cdagenci
             tt-desext.nmprimtl = crabass.nmprimtl
             tt-desext.cdsecext = crabass.cdsecext
             tt-desext.tpextcta = crabass.tpextcta
             tt-desext.tpavsdeb = crabass.tpavsdeb.

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

END PROCEDURE. /* Busca_Desext */

/* ------------------------------------------------------------------------- */
/*                  Efetua a Validação dos dados informados                  */
/* ------------------------------------------------------------------------- */
PROCEDURE Valida_Desext:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsecext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpavsdeb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabass FOR crapass.
    
    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida Destino do Extrato"
           aux_cdcritic = 0
           par_nmdcampo = ""
           aux_returnvl = "NOK".
    
    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.
        
        /* Informacoes sobre o cooperado */
        FOR FIRST crabass FIELDS(tpextcta cdtipcta dtdemiss cdsitdct cdagenci inpessoa)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK: END.

         IF  NOT AVAILABLE crabass THEN
             DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE Valida.
             END.
        
        IF  NOT CAN-FIND (FIRST crapdes 
                                  WHERE crapdes.cdcooper = par_cdcooper     AND
                                        crapdes.cdagenci = crabass.cdagenci AND
                                        crapdes.cdsecext = par_cdsecext)
            THEN
            DO:
                ASSIGN aux_cdcritic = 19
                       par_nmdcampo = "cdsecext".
                LEAVE Valida.
            END.


        IF  NOT CAN-DO ("0,1,2",STRING(par_tpextcta)) THEN
            DO:
                ASSIGN aux_cdcritic = 264
                       par_nmdcampo = "tpextcta".
                LEAVE Valida.
            END.

        IF  NOT CAN-DO ("0,1",STRING(par_tpavsdeb)) THEN
            DO:
                ASSIGN aux_cdcritic = 513
                       par_nmdcampo = "tpavsdeb".
                LEAVE Valida.
            END.
        
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_busca_modalidade_tipo
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT crabass.inpessoa, /* Tipo de pessoa */
                                             INPUT crabass.cdtipcta, /* Tipo de conta */
                                            OUTPUT 0,                /* Modalidade */
                                            OUTPUT "",               /* Flag Erro */
                                            OUTPUT "").              /* Descriçao da crítica */
        
        CLOSE STORED-PROC pc_busca_modalidade_tipo
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_cdmodali = 0
               aux_des_erro = ""
               aux_dscritic = ""
               aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                              WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
               aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                              WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
               aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                              WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.
        
        IF aux_des_erro = "NOK"  THEN
            DO:
               par_nmdcampo = "tpextcta".
               LEAVE Valida.
            END.
        
        IF  (CAN-DO("02,03",STRING(aux_cdmodali,"99")) OR
             crabass.dtdemiss <> ?  OR  crabass.cdsitdct <> 1)  THEN
             IF  par_tpextcta > 0 THEN
                 DO:  
                      ASSIGN aux_cdcritic = 572
                      par_nmdcampo = "tpextcta".
                      LEAVE Valida.
                 END.

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

    IF  aux_returnvl = "NOK" AND par_flgerlog THEN
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

END PROCEDURE. /* Valida_Desext */

/* ------------------------------------------------------------------------- */
/*                 REALIZA A GRAVACAO DOS DADOS DA TELA DESEXT               */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Desext:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsecext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpavsdeb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_msgrecad AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_cdsecext AS INTE                                    NO-UNDO.
    DEF VAR aux_tpextcta AS INTE                                    NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava Destino do Extrato"
           aux_cdcritic = 0
           aux_returnvl = "NOK".
    
    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        ContadorAssociado: DO aux_contador = 1 TO 10:

            FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                               crapass.nrdconta = par_nrdconta
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                 
            IF  NOT AVAIL crapass THEN
                DO:
                    IF  LOCKED(crapass)   THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 72.
                                    LEAVE ContadorAssociado.
                                END.
                            ELSE 
                                DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT ContadorAssociado.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 9.
                            LEAVE ContadorAssociado.
                        END.
                END.
            ELSE
                LEAVE ContadorAssociado.

        END. /* ContadorAssociado */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        ContadorSaldos: DO aux_contador = 1 TO 10:

            FIND crapsld WHERE crapsld.cdcooper = par_cdcooper  AND
                               crapsld.nrdconta = par_nrdconta
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                 
            IF  NOT AVAIL crapsld THEN
                DO:
                    IF  LOCKED(crapsld)   THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 72.
                                    LEAVE ContadorSaldos.
                                END.
                            ELSE 
                                DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT ContadorSaldos.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 10.
                            LEAVE ContadorSaldos.
                        END.
                END.
            ELSE
                LEAVE ContadorSaldos.

        END. /* ContadorSaldos */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        { sistema/generico/includes/b1wgenalog.i
            &TELA-MATRIC=SIM &TELA-CONTAS=NAO }

        EMPTY TEMP-TABLE tt-desext-ant.
        EMPTY TEMP-TABLE tt-desext-atl.

        IF  par_flgerlog THEN
            DO:
                CREATE tt-desext-ant.
                BUFFER-COPY crapass TO tt-desext-ant.
            END.

        ASSIGN aux_cdsecext     = crapass.cdsecext
               crapass.cdsecext = par_cdsecext

               aux_tpextcta     = crapass.tpextcta
               crapass.tpextcta = par_tpextcta

               crapass.tpavsdeb = par_tpavsdeb.

        IF  aux_cdsecext <> crapass.cdsecext   THEN
            DO:
                FOR EACH crapavs WHERE crapavs.cdcooper = par_cdcooper AND
                                       crapavs.nrdconta = par_nrdconta
                                       EXCLUSIVE-LOCK ON ERROR UNDO, NEXT:

                    ASSIGN crapavs.cdsecext = crapass.cdsecext.

                END.

                FOR EACH craprda WHERE craprda.cdcooper = par_cdcooper AND
                                       craprda.nrdconta = par_nrdconta
                                       EXCLUSIVE-LOCK ON ERROR UNDO, NEXT:

                    ASSIGN craprda.cdsecext = crapass.cdsecext.

                END.

                /* Altera secao das aplicacoes RDCA  Programadas */

                FOR EACH craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                                       craprpp.nrdconta = par_nrdconta
                                       EXCLUSIVE-LOCK ON ERROR UNDO, NEXT:

                   ASSIGN craprpp.cdsecext = crapass.cdsecext.

                END.  /*  Fim do FOR EACH  */
            END. 

        IF  aux_tpextcta <> crapass.tpextcta THEN
            IF  crapass.tpextcta = 1 THEN
                ASSIGN crapsld.vlsdanes = crapsld.vlsdmesa
                       crapsld.dtsdanes = DATE(MONTH(par_dtmvtolt),01,
                                          YEAR(par_dtmvtolt))
                       crapsld.dtsdanes = crapsld.dtsdanes - 1.

        IF  par_flgerlog THEN
            DO:
                CREATE tt-desext-atl.
                BUFFER-COPY crapass TO tt-desext-atl.
            END.

        { sistema/generico/includes/b1wgenllog.i 
            &TELA-MATRIC=SIM &TELA-CONTAS=NAO }
            
    END. /* Grava */

    RELEASE crapass.
    RELEASE crapsld.

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

    IF  par_flgerlog THEN
        DO:
            RUN proc_gerar_log_tab
                ( INPUT par_cdcooper,
                  INPUT par_cdoperad,
                  INPUT aux_dscritic,
                  INPUT aux_dsorigem,
                  INPUT aux_dstransa,
                  INPUT (IF aux_returnvl = "OK" THEN TRUE ELSE FALSE),
                  INPUT 1, /*idseqttl*/
                  INPUT par_nmdatela, 
                  INPUT par_nrdconta, 
                  INPUT YES, /*log dos itens*/
                  INPUT BUFFER tt-desext-ant:HANDLE,
                  INPUT BUFFER tt-desext-atl:HANDLE ).
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Desext */

/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA DOS DADOS DO ASSOCIADO                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extppr:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM aux_nrctrrpp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-infoass.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabrpp FOR craprpp.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Extrato de Poupanca Programada"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK"
        aux_nrctrrpp = 0.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-infoass.
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

        IF  NOT VALID-HANDLE(h-b1wgen9998) THEN
            RUN sistema/generico/procedures/b1wgen9998.p
                PERSISTENT SET h-b1wgen9998.
       
        RUN valida_restricao_operador IN h-b1wgen9998
                                     (INPUT par_cdoperad,
                                      INPUT par_nrdconta,
                                      INPUT "",
                                      INPUT par_cdcooper,
                                     OUTPUT aux_dscritic).
       
        IF  VALID-HANDLE(h-b1wgen9998) THEN
            DELETE OBJECT h-b1wgen9998.
       
        IF  RETURN-VALUE <> "OK" THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT 0,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".  
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

        FIND crabrpp WHERE crabrpp.cdcooper = par_cdcooper  AND
                           crabrpp.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  AVAIL crabrpp THEN
            ASSIGN aux_nrctrrpp = crabrpp.nrctrrpp.
        ELSE
        IF  (NOT AMBIGUOUS crabrpp) THEN
            DO: 
                ASSIGN aux_cdcritic = 345.
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

END PROCEDURE. /* Busca_Extppr */

/* ------------------------------------------------------------------------ */
/*                        EFETUA A BUSCA DA POUPANCA                        */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Poupanca:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-poupanca.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0006 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_vltotrpp AS DECI DECIMALS 8                         NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Extrato de Poupanca Programada"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-poupanca.
        EMPTY TEMP-TABLE tt-erro.
        
        IF  NOT VALID-HANDLE(h-b1wgen0006)  THEN
            RUN sistema/generico/procedures/b1wgen0006.p
                PERSISTENT SET h-b1wgen0006.
    
        RUN consulta-poupanca IN h-b1wgen0006 
                            ( INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_nrctrrpp,
                              INPUT par_dtmvtolt,
                              INPUT par_dtmvtopr,
                              INPUT par_inproces,
                              INPUT par_cdprogra,
                              INPUT FALSE, /* flgerlog */
                             OUTPUT aux_vltotrpp,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-dados-rpp ).
    
        IF  VALID-HANDLE(h-b1wgen0006)  THEN
            DELETE PROCEDURE h-b1wgen0006.

        FIND FIRST tt-dados-rpp NO-ERROR.

        IF  NOT AVAIL tt-dados-rpp THEN
            DO:
               ASSIGN aux_cdcritic = 426.
               LEAVE Busca.
            END.
        
        CREATE tt-poupanca.
        ASSIGN
            tt-poupanca.cdcooper = par_cdcooper
            tt-poupanca.nrdconta = par_nrdconta
            tt-poupanca.vlrdcapp = tt-dados-rpp.vlsdrdpp
            tt-poupanca.dddebito = tt-dados-rpp.indiadeb
            tt-poupanca.dtvctopp = tt-dados-rpp.dtvctopp
            tt-poupanca.nrctrrpp = tt-dados-rpp.nrctrrpp
            tt-poupanca.dtiniper = tt-dados-rpp.dtsldrpp
            tt-poupanca.dtfimper = par_dtmvtolt.

        ASSIGN aux_returnvl = "OK".

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


    IF  par_flgerlog THEN
        DO:
            RUN proc_gerar_log 
                (INPUT par_cdcooper,
                 INPUT par_cdoperad,
                 INPUT aux_dscritic,
                 INPUT aux_dsorigem,
                 INPUT aux_dstransa,
                 INPUT (IF aux_returnvl = "OK" THEN TRUE ELSE FALSE),
                 INPUT 1, /** idseqttl **/
                 INPUT par_nmdatela, 
                 INPUT par_nrdconta, 
                OUTPUT aux_nrdrowid).

            /* nrctrrpp */
            RUN proc_gerar_log_item 
                ( INPUT aux_nrdrowid,
                  INPUT "nrctrrpp",
                  INPUT par_nrctrrpp,
                  INPUT par_nrctrrpp ).
        END.
               
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Poupanca */ 

/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA LANAÇAMENTOS NA POUPANCA                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Lancamentos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-extr-rpp.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR h-b1wgen0006 AS HANDLE                                  NO-UNDO.
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Extrato de Poupanca Programada"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-extr-rpp.
        EMPTY TEMP-TABLE tt-erro.

        IF  par_dtiniper = ? THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE Busca.
            END.


        IF  par_dtfimper = ? OR par_dtfimper < par_dtiniper THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE Busca.
            END.

        IF  NOT VALID-HANDLE(h-b1wgen0006)  THEN
            RUN sistema/generico/procedures/b1wgen0006.p
                PERSISTENT SET h-b1wgen0006.
        
        RUN consulta-extrato-poupanca IN h-b1wgen0006
                                    ( INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT par_nrctrrpp,
                                      INPUT par_dtiniper,
                                      INPUT par_dtfimper,
                                      INPUT FALSE, /* flgerlog */
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-extr-rpp).
    
        IF  VALID-HANDLE(h-b1wgen0006)  THEN
            DELETE PROCEDURE h-b1wgen0006.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Busca.
        
        IF  NOT TEMP-TABLE tt-extr-rpp:HAS-RECORDS THEN
            DO:
               ASSIGN aux_cdcritic = 81.
               LEAVE Busca.
            END.

        ASSIGN aux_returnvl = "OK".

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
                                   INPUT FALSE,
                                   INPUT 1, /** idseqttl **/
                                   INPUT par_nmdatela, 
                                   INPUT par_nrdconta, 
                                  OUTPUT aux_nrdrowid).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Lancamento */

/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA DO EXTRATO DA CONTA-CORRENTE               */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extrato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinimov AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimmov AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_dtinimov AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM aux_dtfimmov AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-extrat.
    DEF OUTPUT PARAM TABLE FOR tt-extrato_conta.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabass FOR crapass.

    DEF VAR aux_dtmvtolt AS DATE                                    NO-UNDO.
    DEF VAR aux_dtlimite AS DATE                                    NO-UNDO.
    DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_nrregist AS INTE                                    NO-UNDO.

    DEF VAR aux_dshistor AS CHAR                                    NO-UNDO.
    DEF VAR aux_vllanmto AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlsdtota AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgfirst AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.

    FORM tt-extrato_conta.dtmvtolt COLUMN-LABEL "Data"       FORMAT "99/99/9999"
         aux_dshistor              COLUMN-LABEL "Historico"  FORMAT "x(18)"
         tt-extrato_conta.nrdocmto COLUMN-LABEL "Documento"  FORMAT "x(12)"
         tt-extrato_conta.indebcre COLUMN-LABEL "D/C"        FORMAT "x"
         aux_vllanmto              COLUMN-LABEL "Valor"      FORMAT "x(12)"
         aux_vlsdtota              COLUMN-LABEL "Saldo"      FORMAT "x(14)"
         WITH NO-BOX DOWN WIDTH 132 FRAME f_arquivo_extrat.

    FORM par_nrdconta       AT  1 LABEL "Conta/dv"
         par_dtinimov       AT 46 LABEL "Periodo" 
         "a"               
         par_dtfimmov       AT 68 NO-LABEL
         SKIP
         tt-extrat.nmprimtl AT  1 LABEL "Tit."
         tt-extrat.vllimcre AT 39 LABEL "Limite Credito" FORMAT "zzz,zzz,zz9.99"  
         tt-extrat.cdagenci AT 70 LABEL "PA"
         SKIP(1)
         WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_cabecalho.

    FORM SKIP(1)
         "RELACAO DE CHEQUES RECEBIDOS EM DEPOSITO" AT 1
         SKIP(1)
         "DATA"            AT  1
         "DOCUMENTO"       AT 14
         "BANCO  AGENCIA"  AT 25
         "CONTA"           AT 50
         "CHEQUE"          AT 60
         "VALOR"           AT 76
         SKIP
         "---------- ----------- ------ --------"    AT  1
         "--------------- ---------- --------------" AT 40
         WITH NO-BOX NO-LABEL WIDTH 80 FRAME f_label_chq.

    FORM tt-extrato_cheque.dtmvtolt AT  1 FORMAT "x(10)"
         tt-extrato_cheque.nrdocmto AT 12 FORMAT "zzz,zzz,zz9"
         tt-extrato_cheque.cdbanchq AT 27 FORMAT "999"
         tt-extrato_cheque.cdagechq AT 35 FORMAT "9999"
         tt-extrato_cheque.nrctachq AT 41 FORMAT "zzzz,zzz,zzz,9"
         tt-extrato_cheque.nrcheque AT 57 FORMAT "zzz,zz9"
         "."                        AT 64
         tt-extrato_cheque.nrddigc3 AT 65 FORMAT "9"
         tt-extrato_cheque.vlcheque AT 68 FORMAT "zzzzzz,zz9.99"
         WITH NO-BOX DOWN NO-LABEL WIDTH 80 FRAME f_cheques.

    FORM "--------------"            AT 67
         tt-extrato_cheque.vltotchq AT 68 FORMAT "zzzzzz,zz9.99"
         SKIP(1)
         WITH NO-BOX DOWN NO-LABEL WIDTH 80 FRAME f_deposito.
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Extrato de Depositos a Vista"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-extrat.
        EMPTY TEMP-TABLE tt-extrato.
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

        IF  par_dtinimov = ? THEN
            ASSIGN par_dtinimov = 
                               DATE(MONTH(par_dtmvtolt),01,YEAR(par_dtmvtolt)).

        IF  par_dtfimmov = ? THEN
            ASSIGN par_dtfimmov = par_dtmvtolt.

        IF  par_dtinimov > par_dtfimmov OR 
            par_dtfimmov > par_dtmvtolt THEN 
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE Busca.
            END.

        IF  par_dtinimov <= 03/31/2005 THEN  /* Lancamentos Microfilmados */
            DO:
                ASSIGN aux_cdcritic = 852.
                LEAVE Busca.
            END.

        ASSIGN aux_dtinimov = par_dtinimov
               aux_dtfimmov = par_dtfimmov.

        /* Informacoes sobre o cooperado */
        FOR FIRST crabass FIELDS(cdcooper nrdconta nmprimtl vllimcre cdagenci)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

        CREATE tt-extrat.
        ASSIGN tt-extrat.cdcooper = crabass.cdcooper
               tt-extrat.nrdconta = crabass.nrdconta
               tt-extrat.nmprimtl = crabass.nmprimtl
               tt-extrat.vllimcre = crabass.vllimcre
               tt-extrat.cdagenci = crabass.cdagenci.

        IF  par_nmdatela = "EXTRAT" THEN
            DO:
                RUN ListaFun 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmoperad,
                      INPUT par_cddepart,
                      INPUT par_dtmvtolt,
                      INPUT par_nrdconta,
                      INPUT par_dsiduser,
                     OUTPUT TABLE tt-erro ).
        
                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Busca.
            END.
            
        IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
            RUN sistema/generico/procedures/b1wgen0001.p
                PERSISTENT SET h-b1wgen0001.

        IF  NOT VALID-HANDLE(h-b1wgen0001) THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para b1wgen0001.".
                LEAVE Busca.
            END.

        IF  par_idorigem = 1   OR
            par_cddopcao = "A" OR 
            par_cddopcao = "AC" THEN
            DO:                    
                RUN obtem-saldo IN h-b1wgen0001 
                              ( INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_nrdconta,
                                INPUT par_dtinimov,
                                INPUT par_idorigem,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-saldos).

                
                IF  RETURN-VALUE = "NOK" THEN
                    LEAVE Busca.

                FIND FIRST tt-saldos NO-LOCK NO-ERROR.

                RUN consulta-extrato IN h-b1wgen0001 
                                   ( INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,
                                     INPUT par_nrdconta,
                                     INPUT par_dtinimov,
                                     INPUT par_dtfimmov,
                                     INPUT par_idorigem,
                                     INPUT 1, /* idseqttl */
                                     INPUT "EXTRAT", 
                                     INPUT FALSE,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-extrato_conta).

                IF  RETURN-VALUE = "NOK" THEN
                    LEAVE Busca.

                IF  par_cddopcao = "AC" THEN
                    DO: 
                        /*depositos de cheques*/
                        RUN obtem-cheques-deposito IN h-b1wgen0001
                            (INPUT par_cdcooper, /*cdcooper*/
                             INPUT 0,            /*cdagenci*/
                             INPUT 0,            /*nrdcaixa*/
                             INPUT par_cdoperad, /*cdoperad*/
                             INPUT par_nmdatela, /*nmdatela*/
                             INPUT 1,            /*idorigem*/
                             INPUT par_nrdconta, /*nrdconta*/
                             INPUT 1,            /*idseqttl*/
                             INPUT par_dtinimov, /*dtiniper*/
                             INPUT par_dtfimmov, /*dtfimper*/
                             INPUT FALSE,        /*flgpagin*/  
                             INPUT 0,            /*iniregis*/
                             INPUT 0,            /*qtregpag*/
                             INPUT FALSE,        /** LOG **/
                             OUTPUT aux_qtregist, /*qtregist*/
                             OUTPUT TABLE tt-extrato_cheque).
        
                        IF  RETURN-VALUE = "NOK" THEN
                            LEAVE Busca.
                    END.

                /* Para opcao A do Ayllos WEB */
                IF  par_idorigem = 5 THEN
                    DO:
                        /** Registro de saldo anterior nao deve aparecer como lancamento **/
                        FIND tt-extrato_conta WHERE tt-extrato_conta.nrsequen = 0
                                                    EXCLUSIVE-LOCK NO-ERROR.
                        
                        IF  AVAILABLE tt-extrato_conta  THEN 
                            DELETE tt-extrato_conta.
                    END.

                IF  TEMP-TABLE tt-extrato_conta:HAS-RECORDS THEN 
                    DO:
                        CREATE tt-extrato_conta.
                        ASSIGN tt-extrato_conta.dtmvtolt = par_dtinimov
                               tt-extrato_conta.nrsequen = 0
                               tt-extrato_conta.dshistor = "SALDO ANTERIOR"
                               tt-extrato_conta.vlsdtota =  tt-saldos.vlsddisp +
                                                            tt-saldos.vlsdchsl +
                                                            tt-saldos.vlsdbloq +
                                                            tt-saldos.vlsdblpr +
                                                            tt-saldos.vlsdblfp.

                    END.

            END.
        ELSE
        IF  par_idorigem = 5 AND par_cddopcao <> "A" THEN
            DO:
                RUN extrato-paginado IN h-b1wgen0001 
                                   ( INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,
                                     INPUT par_nmdatela,
                                     INPUT par_idorigem,
                                     INPUT par_nrdconta,
                                     INPUT 1, /* idseqttl */
                                     INPUT par_dtinimov,        
                                     INPUT par_dtfimmov,
                                     INPUT par_nriniseq,
                                     INPUT par_nrregist,
                                     INPUT FALSE,
                                    OUTPUT par_qtregist,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-extrato_conta).

                IF  RETURN-VALUE = "NOK" THEN
                    LEAVE Busca.
            END.

        IF  par_cddopcao = "A" OR 
            par_cddopcao = "AC" THEN
            DO:
                IF  par_nmarquiv = "" THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Nome do arquivo nao informado.".

                        LEAVE Busca.
                    END.

                IF  NOT TEMP-TABLE tt-extrato_conta:HAS-RECORDS THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Nao ha registros para serem exibidos.".

                        LEAVE Busca.
                    END.
                
                FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
                
                IF  NOT AVAIL crapcop THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Cooperativa nao cadastrada.".
                
                        LEAVE Busca.
                    END.
                
                ASSIGN aux_nmarqimp = "/micros/" + crapcop.dsdircop  +  
                                      "/" + par_nmarquiv. 

                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).

                FIND FIRST tt-extrat NO-ERROR.
    
                DISPLAY STREAM str_1 par_nrdconta
                                     par_dtinimov FORMAT "99/99/9999"
                                     par_dtfimmov FORMAT "99/99/9999"
                                     tt-extrat.nmprimtl WHEN AVAILABLE tt-extrat FORMAT "X(30)"
                                     tt-extrat.vllimcre WHEN AVAILABLE tt-extrat
                                     tt-extrat.cdagenci WHEN AVAILABLE tt-extrat
                                     WITH FRAME f_cabecalho.
                
                FOR EACH tt-extrato_conta NO-LOCK BREAK BY tt-extrato_conta.dtmvtolt
                                                        BY tt-extrato_conta.nrsequen:

                    ASSIGN aux_dshistor = IF  tt-extrato_conta.nrsequen = 0  THEN
                                              tt-extrato_conta.dshistor
                                          ELSE
                                              STRING(tt-extrato_conta.cdhistor,"9999") + "-" + 
                                              tt-extrato_conta.dshistor
                           aux_vllanmto = IF  tt-extrato_conta.nrsequen = 0  THEN
                                              "            "
                                          ELSE
                                              STRING(tt-extrato_conta.vllanmto,
                                                     "zzzzz,zz9.99")
                           aux_vlsdtota = IF  tt-extrato_conta.vlsdtota = 0  AND 
                                              tt-extrato_conta.nrsequen > 0  THEN 
                                              "               "
                                          ELSE
                                              STRING(tt-extrato_conta.vlsdtota,
                                                     "zzzzzz,zz9.99-").
                       
                    DISPLAY STREAM str_1 tt-extrato_conta.dtmvtolt
                                         aux_dshistor
                                         tt-extrato_conta.nrdocmto
                                         tt-extrato_conta.indebcre
                                         aux_vllanmto
                                         aux_vlsdtota WITH FRAME f_arquivo_extrat.
                
                    DOWN STREAM str_1 WITH FRAME f_arquivo_extrat.
                
                END.

                /*Impressao dos cheques depositados*/
                IF  par_cddopcao = "AC" THEN
                    DO:
                        ASSIGN aux_flgfirst = TRUE. 
        
                        FOR EACH tt-extrato_cheque /* NO-LOCK*/ :
        
                            IF  aux_flgfirst  THEN
                                DO: 
                                    VIEW STREAM str_1 FRAME f_label_chq.
        
                                    ASSIGN aux_flgfirst = FALSE.
                                END.
        
                            DISPLAY STREAM str_1
                                    tt-extrato_cheque.dtmvtolt
                                    tt-extrato_cheque.nrdocmto     
                                    tt-extrato_cheque.cdbanchq  
                                    tt-extrato_cheque.cdagechq
                                    tt-extrato_cheque.nrctachq  
                                    tt-extrato_cheque.nrcheque
                                    tt-extrato_cheque.nrddigc3  
                                    tt-extrato_cheque.vlcheque
                                    WITH FRAME f_cheques.
        
                            DOWN STREAM str_1 WITH FRAME f_cheques.
        
                            IF  tt-extrato_cheque.vltotchq > 0  THEN
                                DISPLAY STREAM str_1 tt-extrato_cheque.vltotchq 
                                        WITH FRAME f_deposito.
        
                        END. /** Fim do FOR EACH tt-extrato_cheque **/
                    END.

                OUTPUT STREAM str_1 CLOSE.
                
                HIDE MESSAGE NO-PAUSE.

                ASSIGN aux_nmarqimp = TRIM(aux_nmarqimp).
                
                IF  par_idorigem = 5 AND 
                    SUBSTR(aux_nmarqimp,LENGTH(aux_nmarqimp) - 2,3) = "pdf" THEN
                    DO:     
                        /* Gera relatorio em PDF */
                        RUN sistema/generico/procedures/b1wgen0024.p
                            PERSISTENT SET h-b1wgen0024.
        
                        RUN envia-arquivo-web IN h-b1wgen0024
                                                 (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT aux_nmarqimp,
                                                 OUTPUT aux_nmarqpdf,
                                                 OUTPUT TABLE tt-erro).     
        
                        DELETE PROCEDURE h-b1wgen0024. 

                        IF  RETURN-VALUE <> "OK"   THEN
                            DO:
                                RETURN "NOK".
                            END.
                    END.
               ELSE
                    DO:   
                       UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + 
                                         aux_nmarqimp + "_copy").
                                           
                       UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + "_copy" +
                                         ' | tr -d "\032" > ' + aux_nmarqimp +
                                         " 2>/dev/null").
                        
                       UNIX SILENT VALUE("rm " + aux_nmarqimp + "_copy").
                    END.

                EMPTY TEMP-TABLE tt-extrat.
                EMPTY TEMP-TABLE tt-extrato_conta.
                EMPTY TEMP-TABLE tt-extrato_cheque.

            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Busca.

    END. /* Busca */

    IF  VALID-HANDLE(h-b1wgen0001)  THEN
        DELETE PROCEDURE h-b1wgen0001.

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
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                END.

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    IF  par_flgerlog THEN
        DO:
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

            RUN proc_gerar_log_item 
                    ( INPUT aux_nrdrowid,
                      INPUT "dtinimov",
                      INPUT STRING(par_dtinimov,"99/99/9999"),
                      INPUT "" ).

            RUN proc_gerar_log_item 
                    ( INPUT aux_nrdrowid,
                      INPUT "dtfimmov",
                      INPUT STRING(par_dtfimmov,"99/99/9999"),
                      INPUT "" ).
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Extrato */

/* ------------------------------------------------------------------------ */
/*                      EFETUA A BUSCA DA TELA EXTEMP                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extemp:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM aux_nrctremp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-infoass.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabepr FOR crapepr.
        
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Extrato de Emprestimo"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK"
        aux_nrctremp = 0.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-infoass.
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

        FIND crabepr WHERE crabepr.cdcooper = par_cdcooper  AND
                           crabepr.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  AVAIL crabepr THEN
            ASSIGN aux_nrctremp = crabepr.nrctremp.
        ELSE
        IF  (NOT AMBIGUOUS crabepr) THEN
            DO: 
                ASSIGN aux_cdcritic = 355.
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

END PROCEDURE. /* Busca_Extemp */ 

/* ------------------------------------------------------------------------ */
/*                  EFETUA A BUSCA DO EXTRATO DO EMPRESTIMO                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-epr.
    DEF OUTPUT PARAM TABLE FOR tt-extrato_epr.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.

    DEF VAR h-b1wgen0002 AS HANDLE                                  NO-UNDO.
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Extrato de Emprestimo"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-dados-epr.
        EMPTY TEMP-TABLE tt-extrato_epr.
        EMPTY TEMP-TABLE tt-erro.
       
        IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
            RUN sistema/generico/procedures/b1wgen0002.p
                PERSISTENT SET h-b1wgen0002.

      
        RUN obtem-dados-emprestimos IN h-b1wgen0002
                                  ( INPUT par_cdcooper, 
                                    INPUT par_cdagenci, 
                                    INPUT par_nrdcaixa, 
                                    INPUT par_cdoperad, 
                                    INPUT par_nmdatela, 
                                    INPUT par_idorigem, 
                                    INPUT par_nrdconta, 
                                    INPUT par_idseqttl, 
                                    INPUT par_dtmvtolt,
                                    INPUT par_dtmvtopr, 
                                    INPUT ?, /* dtcalcul */
                                    INPUT par_nrctremp,
                                    INPUT par_cdprogra,
                                    INPUT par_inproces,
                                    INPUT FALSE, /* flgerlog */
                                    INPUT TRUE, 
                                    INPUT 0, /** nriniseq **/
                                    INPUT 0, /** nrregist **/
                                   OUTPUT aux_qtregist,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-dados-epr).
        
        IF  RETURN-VALUE <> "OK" THEN
            DO:
                IF  VALID-HANDLE(h-b1wgen0002)  THEN
                    DELETE PROCEDURE h-b1wgen0002.
                LEAVE Busca.
            END.

        RUN obtem-extrato-emprestimo IN h-b1wgen0002
                                   ( INPUT par_cdcooper,     
                                     INPUT par_cdagenci,     
                                     INPUT par_nrdcaixa,     
                                     INPUT par_cdoperad,     
                                     INPUT par_nmdatela,     
                                     INPUT par_idorigem,     
                                     INPUT par_nrdconta,     
                                     INPUT par_idseqttl,     
                                     INPUT par_nrctremp,     
                                     INPUT ?, /* dtiniper */ 
                                     INPUT ?, /* dtfimper */ 
                                     INPUT FALSE,  /* flgerlog */
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-extrato_epr).

        IF  VALID-HANDLE(h-b1wgen0002)  THEN
            DELETE PROCEDURE h-b1wgen0002.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Busca.
            
    END. /* Busca */

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
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog THEN
        DO:
            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN
                DO: 
                    FIND FIRST tt-erro NO-ERROR.
                    IF  AVAIL tt-erro THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                END.
                
            RUN proc_gerar_log 
                (INPUT par_cdcooper,
                 INPUT par_cdoperad,
                 INPUT aux_dscritic,
                 INPUT aux_dsorigem,
                 INPUT aux_dstransa,
                 INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
                 INPUT 1, /** idseqttl **/
                 INPUT par_nmdatela, 
                 INPUT par_nrdconta, 
                OUTPUT aux_nrdrowid).

            /* nrctremp */
            RUN proc_gerar_log_item 
                ( INPUT aux_nrdrowid,
                  INPUT "nrctremp",
                  INPUT par_nrctremp,
                  INPUT par_nrctremp ).


        END.
                
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Emprestimo */ 

/* ------------------------------------------------------------------------ */
/*                      EFETUA A BUSCA DA TELA EXTRDA                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extrda:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM aux_nraplica AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-infoass.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nraplrac AS INTE                                    NO-UNDO.
    DEF VAR aux_nraplrda AS INTE                                    NO-UNDO.
    
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabrda FOR craprda.
    DEF BUFFER crabrac FOR craprac.
        
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Extrato de Aplicacoes"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK"
        aux_nraplica = 0.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-infoass.
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

        IF  NOT VALID-HANDLE(h-b1wgen9998) THEN
            RUN sistema/generico/procedures/b1wgen9998.p
               PERSISTENT SET h-b1wgen9998.

            RUN valida_restricao_operador IN h-b1wgen9998
                                         (INPUT par_cdoperad,
                                          INPUT par_nrdconta,
                                          INPUT "",
                                          INPUT par_cdcooper,
                                         OUTPUT aux_dscritic).

        IF  VALID-HANDLE(h-b1wgen9998) THEN
            DELETE OBJECT h-b1wgen9998.

        IF  RETURN-VALUE <> "OK" THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT 0,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".  
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

        FIND crabrda WHERE crabrda.cdcooper = par_cdcooper  AND
                           crabrda.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  AVAIL crabrda THEN
            ASSIGN aux_nraplrda = crabrda.nraplica.

        FIND crabrac WHERE crabrac.cdcooper = par_cdcooper AND
                           crabrac.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
            
        IF  AVAIL crabrac THEN
            ASSIGN aux_nraplrac = crabrac.nraplica.

        IF  NOT AVAIL crabrda AND NOT AMBIGUOUS crabrda AND
            NOT AVAIL crabrac AND NOT AMBIGUOUS crabrac THEN
            DO:
                ASSIGN aux_cdcritic = 345.
                LEAVE Busca.
            END.

        IF  aux_nraplrda > 0 AND (aux_nraplrac = 0 AND NOT AMBIGUOUS crabrac) THEN
            ASSIGN aux_nraplica = aux_nraplrda.
        ELSE
        IF  aux_nraplrac > 0 AND (aux_nraplrda = 0 AND NOT AMBIGUOUS crabrda) THEN
            ASSIGN aux_nraplica = aux_nraplrac.
        
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

END PROCEDURE. /* Busca_Extrda */

/* ------------------------------------------------------------------------ */
/*                  EFETUA A BUSCA DO EXTRATO DAS APLICACOES                */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Aplicacoes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-saldo-rdca.
    DEF OUTPUT PARAM TABLE FOR tt-extr-rdca.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0081 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_vlsldapl AS DECI                                    NO-UNDO.
    
    /* Variaveis retornadas da procedure pc_busca_aplicacoes_car e
       pc_busca_extrato_aplicacao */
    DEF VAR aux_nraplica   AS INTE                                  NO-UNDO.
    DEF VAR aux_idtippro   AS INTE                                  NO-UNDO.
    DEF VAR aux_cdprodut   AS INTE                                  NO-UNDO.
    DEF VAR aux_nmprodut   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dsnomenc   AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmdindex   AS CHAR                                  NO-UNDO.
    DEF VAR aux_vlaplica   AS DECI                                  NO-UNDO.
    DEF VAR aux_vlsldtot   AS DECI                                  NO-UNDO.
    DEF VAR aux_vlsldrgt   AS DECI                                  NO-UNDO.
    DEF VAR aux_vlrdirrf   AS DECI                                  NO-UNDO.
    DEF VAR aux_percirrf   AS DECI                                  NO-UNDO.
    DEF VAR aux_dtmvtolt   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dtvencto   AS CHAR                                  NO-UNDO.
    DEF VAR aux_qtdiacar   AS INTE                                  NO-UNDO.
    DEF VAR aux_qtdiaapl   AS INTE                                  NO-UNDO.
    DEF VAR aux_txaplica   AS DECI                                  NO-UNDO.
    DEF VAR aux_txlancto   AS DECI                                  NO-UNDO.
    DEF VAR aux_idblqrgt   AS INTE                                  NO-UNDO.
    DEF VAR aux_dsblqrgt   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dsresgat   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dtresgat   AS CHAR                                  NO-UNDO.
    DEF VAR aux_cdoperad   AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmoperad   AS CHAR                                  NO-UNDO.
    DEF VAR aux_idtxfixa   AS INTE                                  NO-UNDO.
    DEF VAR aux_cdagenci   AS INTE                                  NO-UNDO.
    DEF VAR aux_dshistor   AS CHAR                                  NO-UNDO.
    DEF VAR aux_cdhistor   AS INTE                                  NO-UNDO.
    DEF VAR aux_nrdocmto   AS INTE                                  NO-UNDO.
    DEF VAR aux_indebcre   AS CHAR                                  NO-UNDO.
    DEF VAR aux_vllanmto   AS DECI                                  NO-UNDO.

    /* Variáveis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.


    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Extrato de Aplicacoes"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-saldo-rdca.
        EMPTY TEMP-TABLE tt-extr-rdca.
        EMPTY TEMP-TABLE tt-erro.              
                
        FIND craprda WHERE craprda.cdcooper = par_cdcooper AND
                           craprda.nrdconta = par_nrdconta AND
                           craprda.nraplica = par_nraplica NO-LOCK NO-ERROR.

        IF  AVAIL craprda THEN
            DO:

                IF  NOT VALID-HANDLE(h-b1wgen0081)  THEN
                    RUN sistema/generico/procedures/b1wgen0081.p
                        PERSISTENT SET h-b1wgen0081.
                
                RUN obtem-dados-aplicacoes IN h-b1wgen0081
                                          ( INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_idorigem,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_nraplica,
                                            INPUT par_cdprogra,
                                            INPUT FALSE, /*flgerlog*/
                                            INPUT ?,
                                            INPUT ?,
                                           OUTPUT aux_vlsldapl,
                                           OUTPUT TABLE tt-saldo-rdca,
                                           OUTPUT TABLE tt-erro).
                
                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        IF  VALID-HANDLE(h-b1wgen0081)  THEN
                            DELETE PROCEDURE h-b1wgen0081.
                        LEAVE Busca.
                    END.
        
                FIND FIRST tt-saldo-rdca NO-ERROR.
        
                IF  NOT AVAIL tt-saldo-rdca THEN
                    DO:
                        ASSIGN aux_cdcritic = 426.
                        LEAVE Busca.
                    END.
                
                RUN consulta-extrato-rdca IN h-b1wgen0081
                                           ( INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT par_nraplica,
                                             INPUT 0, /* tpaplica */
                                             INPUT aux_vlsldapl,
                                             INPUT ?, /* dtinicio */
                                             INPUT ?, /* datafim  */
                                             INPUT par_cdprogra,
                                             INPUT par_idorigem,
                                             INPUT FALSE, /*flgerlog*/
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-extr-rdca).
        
                IF  VALID-HANDLE(h-b1wgen0081)  THEN
                    DELETE PROCEDURE h-b1wgen0081.
        
                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Busca.                        
            END.          
        ELSE
            DO:

                /********NOVA CONSULTA APLICACOOES*********/
                /** Saldo das aplicacoes **/
                
                /* Inicializando objetos para leitura do XML */ 
                CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
                CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
                CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
                CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
                CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
                
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                
                /* Efetuar a chamada a rotina Oracle */
                RUN STORED-PROCEDURE pc_busca_aplicacoes_car
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* Código da Cooperativa*/
                                                    ,INPUT par_cdoperad     /* Código do Operador*/
                                                    ,INPUT par_nmdatela     /* Nome da Tela*/
                                                    ,INPUT 1                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA*/
                                                    ,INPUT par_nrdconta     /* Número da Conta*/
                                                    ,INPUT par_idseqttl     /* Titular da Conta*/
                                                    ,INPUT par_nraplica     /* Número da Aplicação - Parâmetro Opcional*/
                                                    ,INPUT 0                /* Código do Produto – Parâmetro Opcional */
                                                    ,INPUT par_dtmvtolt     /* Data de Movimento*/
                                                    ,INPUT 5                /* Identificador de Consulta (0 – Ativas / 1 – Resgatadas / 2 – Vencidas / 4 – Encerradas / 5 – Todas / 6 – Disponíveis para resgate) */
                                                    ,INPUT 0                /* Identificador de Log (0 – Não / 1 – Sim) */
                                                    ,OUTPUT ?               /* XML */
                                                    ,OUTPUT 0               /* Código da crítica */
                                                    ,OUTPUT "").            /* Descrição da crítica */
        
                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_busca_aplicacoes_car
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        
                /* Busca possíveis erros */ 
                ASSIGN aux_cdcritic = 0
                      aux_dscritic = ""
                      aux_cdcritic = pc_busca_aplicacoes_car.pr_cdcritic 
                                     WHEN pc_busca_aplicacoes_car.pr_cdcritic <> ?
                      aux_dscritic = pc_busca_aplicacoes_car.pr_dscritic 
                                     WHEN pc_busca_aplicacoes_car.pr_dscritic <> ?.

                /* Buscar o XML na tabela de retorno da procedure Progress */ 
                ASSIGN xml_req = pc_busca_aplicacoes_car.pr_clobxmlc.
        
                IF  xml_req = ? THEN
                    LEAVE Busca.

                /* Efetuar a leitura do XML*/ 
                SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
                PUT-STRING(ponteiro_xml,1) = xml_req. 
                 
                xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                xDoc:GET-DOCUMENT-ELEMENT(xRoot).
                
                DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
                
                    xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
                
                    IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
                     NEXT. 
                
                    IF xRoot2:NUM-CHILDREN > 0 THEN
                       CREATE tt-saldo-rdca.
        
                    DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                    
                        xRoot2:GET-CHILD(xField,aux_cont).
                            
                        IF xField:SUBTYPE <> "ELEMENT" THEN 
                            NEXT. 
                        
                        xField:GET-CHILD(xText,1).                   
        
                        ASSIGN aux_nraplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "nraplica"
                               aux_idtippro = INT (xText:NODE-VALUE) WHEN xField:NAME = "idtippro"
                               aux_cdprodut = INT (xText:NODE-VALUE) WHEN xField:NAME = "cdprodut"
                               aux_nmprodut = xText:NODE-VALUE WHEN xField:NAME = "nmprodut"
                               aux_dsnomenc = xText:NODE-VALUE WHEN xField:NAME = "dsnomenc"
                               aux_nmdindex = xText:NODE-VALUE WHEN xField:NAME = "nmdindex"
                               aux_vlaplica = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlaplica"
                               aux_vlsldtot = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsldtot"
                               aux_vlsldrgt = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsldrgt"
                               aux_vlrdirrf = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlrdirrf"
                               aux_percirrf = DECI(xText:NODE-VALUE) WHEN xField:NAME = "percirrf"
                               aux_dtmvtolt = xText:NODE-VALUE WHEN xField:NAME = "dtmvtolt"
                               aux_dtvencto = xText:NODE-VALUE WHEN xField:NAME = "dtvencto"
                               aux_qtdiacar = INT (xText:NODE-VALUE) WHEN xField:NAME = "qtdiacar"
                               aux_txaplica = DECI(xText:NODE-VALUE) WHEN xField:NAME = "txaplica"
                               aux_idblqrgt = INT (xText:NODE-VALUE) WHEN xField:NAME = "idblqrgt"
                               aux_dsblqrgt = xText:NODE-VALUE WHEN xField:NAME = "dsblqrgt"
                               aux_dsresgat = xText:NODE-VALUE WHEN xField:NAME = "dsresgat"
                               aux_dtresgat = xText:NODE-VALUE WHEN xField:NAME = "dtresgat"
                               aux_cdoperad = xText:NODE-VALUE WHEN xField:NAME = "cdoperad"
                               aux_nmoperad = xText:NODE-VALUE WHEN xField:NAME = "nmoperad"
                               aux_idtxfixa = INT (xText:NODE-VALUE) WHEN xField:NAME = "idtxfixa"
                               aux_qtdiaapl = INT (xText:NODE-VALUE) WHEN xField:NAME = "qtdiauti".

                    END.            
        
                    ASSIGN  tt-saldo-rdca.dsaplica = aux_dsnomenc
                            tt-saldo-rdca.vlsdrdad = aux_vlsldtot
                            tt-saldo-rdca.dtvencto = DATE(aux_dtvencto)
                            tt-saldo-rdca.indebcre = aux_dsblqrgt
                            tt-saldo-rdca.cdoperad = aux_cdoperad
                            tt-saldo-rdca.sldresga = aux_vlsldrgt
                            tt-saldo-rdca.qtdiaapl = aux_qtdiaapl
                            tt-saldo-rdca.qtdiauti = aux_qtdiacar
                            tt-saldo-rdca.txaplmax = STRING(aux_txaplica)
                            tt-saldo-rdca.txaplmin = STRING(aux_txaplica)
                            tt-saldo-rdca.tpaplrdc = aux_idtippro
                            tt-saldo-rdca.tpaplica = 0.

                END.                
        
                SET-SIZE(ponteiro_xml) = 0. 
             
                DELETE OBJECT xDoc. 
                DELETE OBJECT xRoot. 
                DELETE OBJECT xRoot2. 
                DELETE OBJECT xField. 
                DELETE OBJECT xText.                                        

                IF  aux_cdcritic <> 0 OR
                    aux_dscritic <> "" THEN
                    LEAVE Busca.
        
                FIND FIRST tt-saldo-rdca NO-ERROR.
        
                IF  NOT AVAIL tt-saldo-rdca THEN
                    DO:
                        ASSIGN aux_cdcritic = 426.
                        LEAVE Busca.
                    END.
                    
                /* Inicializando objetos para leitura do XML */ 
                CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
                CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
                CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
                CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
                CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
                
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                
                /* Efetuar a chamada a rotina Oracle */
                RUN STORED-PROCEDURE pc_busca_extrato_aplicacao_car
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper /* Código da Cooperativa */
                                                    ,INPUT par_cdoperad /* Código do Operador */
                                                    ,INPUT par_nmdatela /* Nome da Tela */
                                                    ,INPUT 1            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                    ,INPUT par_nrdconta /* Número da Conta */
                                                    ,INPUT par_idseqttl /* Titular da Conta */
                                                    ,INPUT par_dtmvtolt /* Data de Movimento */
                                                    ,INPUT par_nraplica /* Número da Aplicação */
                                                    ,INPUT 1            /* Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim) */
                                                    ,INPUT 0            /* Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim) */
                                                    ,OUTPUT 0           /* Valor de resgate    */
                                                    ,OUTPUT 0           /* Valor de rendimento */
                                                    ,OUTPUT 0           /* Valor do IRRF       */
                                                    ,OUTPUT 0           /* Aliquota de IR      */    
                                                    ,OUTPUT 0           /* Taxa acumulada durante o período total da aplicação */
                                                    ,OUTPUT 0           /* Taxa acumulada durante o mês vigente */
                                                    ,OUTPUT ?           /* XML */
                                                    ,OUTPUT 0           /* Código da crítica */
                                                    ,OUTPUT "").        /* Descrição da crítica */
        
                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_busca_extrato_aplicacao_car
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        
                /* Busca possíveis erros */ 
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = pc_busca_extrato_aplicacao_car.pr_cdcritic 
                                      WHEN pc_busca_extrato_aplicacao_car.pr_cdcritic <> ?
                       aux_dscritic = pc_busca_extrato_aplicacao_car.pr_dscritic 
                                      WHEN pc_busca_extrato_aplicacao_car.pr_dscritic <> ?.


                /* Buscar o XML na tabela de retorno da procedure Progress */ 
                ASSIGN xml_req = pc_busca_extrato_aplicacao_car.pr_clobxmlc.

                IF  xml_req = ? THEN
                    LEAVE Busca.

                /* Efetuar a leitura do XML*/ 
                SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
                PUT-STRING(ponteiro_xml,1) = xml_req. 
                
                xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                xDoc:GET-DOCUMENT-ELEMENT(xRoot).
                
                DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
                
                    xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
                
                    IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
                     NEXT. 
                
                    IF xRoot2:NUM-CHILDREN > 0 THEN
                       CREATE tt-extr-rdca.
        
                    DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                    
                        xRoot2:GET-CHILD(xField,aux_cont).
                            
                        IF xField:SUBTYPE <> "ELEMENT" THEN 
                            NEXT. 
                        
                        xField:GET-CHILD(xText,1).                

                        ASSIGN aux_cdagenci = INTE(xText:NODE-VALUE) WHEN xField:NAME = "cdagenci"                               
                               aux_dtmvtolt = xText:NODE-VALUE WHEN xField:NAME = "dtmvtolt"                               
                               aux_txlancto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "txlancto"
                               aux_cdhistor = INTE(xText:NODE-VALUE) WHEN xField:NAME = "cdhistor"
                               aux_dshistor = xText:NODE-VALUE WHEN xField:NAME = "dshistor"
                               aux_nrdocmto = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrdocmto"
                               aux_indebcre = xText:NODE-VALUE WHEN xField:NAME = "indebcre"
                               aux_vllanmto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vllanmto".

                    END.            

                    ASSIGN  tt-extr-rdca.dtmvtolt = DATE(aux_dtmvtolt)
                            tt-extr-rdca.cdagenci = aux_cdagenci        
                            tt-extr-rdca.dshistor = STRING(aux_cdhistor,'9999') + "-" + aux_dshistor
                            tt-extr-rdca.nrdocmto = aux_nrdocmto
                            tt-extr-rdca.indebcre = aux_indebcre
                            tt-extr-rdca.vllanmto = aux_vllanmto
                            tt-extr-rdca.txaplica = aux_txlancto
                            tt-extr-rdca.vlpvlrgt = "".

                END.                
        
                SET-SIZE(ponteiro_xml) = 0. 
             
                DELETE OBJECT xDoc. 
                DELETE OBJECT xRoot. 
                DELETE OBJECT xRoot2. 
                DELETE OBJECT xField. 
                DELETE OBJECT xText.

                IF  aux_cdcritic <> 0 OR
                    aux_dscritic <> "" THEN
                    LEAVE Busca.                       
          
                /*******FIM CONSULTA APLICACAOES**********/

            END.
    END. /* Busca */

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
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog THEN
        DO:
            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN
                DO: 
                    FIND FIRST tt-erro NO-ERROR.
                    IF  AVAIL tt-erro THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                END.
                
            RUN proc_gerar_log 
                (INPUT par_cdcooper,
                 INPUT par_cdoperad,
                 INPUT aux_dscritic,
                 INPUT aux_dsorigem,
                 INPUT aux_dstransa,
                 INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
                 INPUT 1, /** idseqttl **/
                 INPUT par_nmdatela, 
                 INPUT par_nrdconta, 
                OUTPUT aux_nrdrowid).

            /* nraplica */
            RUN proc_gerar_log_item 
                ( INPUT aux_nrdrowid,
                  INPUT "nraplica",
                  INPUT par_nraplica,
                  INPUT par_nraplica ).


        END.
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Aplicacoes */ 
 
  
/* ------------------------------------------------------------------------ */
/*                   LOGICA DO FONTE /includes/listafun.i                   */
/* ------------------------------------------------------------------------ */
PROCEDURE ListaFun:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabjur FOR crapjur.
    DEF BUFFER crabcop FOR crapcop.

    DEF VAR aux_cdempres AS INTE                                    NO-UNDO.
    DEF VAR aux_terminal AS CHAR FORMAT "x(20)"                     NO-UNDO.
        
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Listafun: DO ON ERROR UNDO Listafun, LEAVE Listafun:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crabcop FIELDS(dsdircop) 
                          WHERE crabcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651.
                LEAVE Listafun.
            END.

        FOR FIRST crabass FIELDS(cdcooper nrdconta nmprimtl inpessoa)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
        END.
      
        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Listafun.
            END.
      
        IF  crabass.inpessoa = 1   THEN 
            DO:
                FOR FIRST crabttl FIELDS(cdempres)
                                  WHERE crabttl.cdcooper = par_cdcooper     AND
                                        crabttl.nrdconta = crabass.nrdconta AND
                                        crabttl.idseqttl = 1 NO-LOCK: END.
        
                IF  AVAIL crabttl  THEN
                    ASSIGN aux_cdempres = crabttl.cdempres.
            END.
        ELSE
            DO:
                FOR FIRST crabjur FIELDS(cdempres)
                                  WHERE crabjur.cdcooper = par_cdcooper     AND
                                        crabjur.nrdconta = crabass.nrdconta
                                        NO-LOCK: END.
        
                IF  AVAIL crabjur  THEN
                    ASSIGN aux_cdempres = crabjur.cdempres.
            END.
      
      
        IF  (CAN-DO("11,50",STRING(aux_cdempres)))  AND 
            (par_nmoperad <> crabass.nmprimtl)      AND
            (par_cddepart <> 20)  /* TI */         THEN
            DO:
             
                UNIX SILENT VALUE("echo " +
                                   STRING(YEAR(par_dtmvtolt),"9999") +
                                   STRING(MONTH(par_dtmvtolt),"99") +
                                   STRING(DAY(par_dtmvtolt),"99") + " " +
                                   STRING(par_cdoperad,"x(10)")  + " " +
                                   STRING(par_nmoperad,"x(15)") + " " + 
                                   STRING(crabass.nrdconta,"99999999") + ' "' +
                                   STRING(crabass.nmprimtl,"x(15)") + '" ' +
                                   STRING(TIME,"HH:MM:SS") + " " +
                                   STRING(par_dsiduser,"x(15)") + " " +
                                   STRING(PROGRAM-NAME(1),"x(30)") +
                                   " >> /usr/coop/" + crabcop.dsdircop + 
                                   "/arq/.acessos.dat").
        END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Listafun.

    END. /* Listafun */

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

END PROCEDURE. /* ListaFun */

/* ------------------------------------------------------------------------ */
/*                      EFETUA A BUSCA DA TELA EXTAPL                       */
/* ------------------------------------------------------------------------ */

PROCEDURE Busca_Extapl:

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
     DEF OUTPUT PARAM TABLE FOR tt-extapl.
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF BUFFER crabass FOR crapass.
     DEF BUFFER crabrda FOR craprda.
     DEF BUFFER crabdtc FOR crapdtc.
     DEF BUFFER crabrpp FOR craprpp.
         
     ASSIGN
         aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
         aux_dstransa = "Busca Modo Impressao Extratos Aplicacoes"
         aux_dscritic = ""
         aux_cdcritic = 0
         aux_nrsequen = 0
         aux_returnvl = "NOK".
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-infoass.
        EMPTY TEMP-TABLE tt-extapl.
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT CAN-DO("A,C",par_cddopcao) THEN
            DO:
                ASSIGN aux_cdcritic = 14.
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
        ASSIGN tt-infoass.cdcooper = crabass.cdcooper
               tt-infoass.nrdconta = crabass.nrdconta
               tt-infoass.nmprimtl = crabass.nmprimtl.

        Aplicacao: FOR EACH crabrda WHERE crabrda.cdcooper = par_cdcooper AND
                                          crabrda.nrdconta = par_nrdconta AND
                                          crabrda.vlsdrdca <> 0 NO-LOCK:

            CREATE tt-extapl.
            ASSIGN aux_nrsequen       = aux_nrsequen + 1
                   tt-extapl.nrsequen = aux_nrsequen
                   tt-extapl.tpaplica = crabrda.tpaplica
                   tt-extapl.nraplica = crabrda.nraplica
                   tt-extapl.tpemiext = crabrda.tpemiext
                   tt-extapl.dtmvtolt = crabrda.dtmvtolt.

            IF  crabrda.tpaplica = 3 THEN
                ASSIGN tt-extapl.descapli = "RDCA30".
            ELSE
            IF  crabrda.tpaplica = 5 THEN
                ASSIGN tt-extapl.descapli = "RDCA60".
            ELSE
                DO:

                    FOR FIRST crabdtc WHERE crabdtc.cdcooper = par_cdcooper AND
                                            crabdtc.tpaplica = crabrda.tpaplica
                                            NO-LOCK: END.

                    IF  AVAIL crabdtc THEN
                        ASSIGN  tt-extapl.descapli = crabdtc.dsaplica.

                END.

            IF  crabrda.tpemiext = 1 THEN
                ASSIGN tt-extapl.dsemiext = "Individual".
            ELSE
            IF  crabrda.tpemiext = 2 THEN
                ASSIGN tt-extapl.dsemiext = "Todos juntos".
            ELSE
            IF  crabrda.tpemiext = 3 THEN
                ASSIGN tt-extapl.dsemiext = "Nao imprime".

        END. /* Aplicacao */

        Poupanca: FOR EACH crabrpp WHERE crabrpp.cdcooper = par_cdcooper AND
                                         crabrpp.nrdconta = par_nrdconta AND
                                        (crabrpp.cdsitrpp = 1            OR
                                         crabrpp.vlsdrdpp > 0) NO-LOCK:
            CREATE tt-extapl.
            ASSIGN aux_nrsequen       = aux_nrsequen + 1
                   tt-extapl.nrsequen = aux_nrsequen
                   tt-extapl.tpaplica = 6
                   tt-extapl.nraplica = crabrpp.nrctrrpp
                   tt-extapl.tpemiext = crabrpp.tpemiext
                   tt-extapl.descapli = "P.PROG"
                   tt-extapl.dtmvtolt = crabrpp.dtmvtolt.

            IF  crabrpp.tpemiext = 1 THEN
                ASSIGN tt-extapl.dsemiext = "Individual".
            ELSE
            IF  crabrpp.tpemiext = 2 THEN
                ASSIGN tt-extapl.dsemiext = "Todos juntos".
            ELSE
            IF  crabrpp.tpemiext = 3 THEN
                ASSIGN tt-extapl.dsemiext = "Nao imprime".

        END. /* Poupanca */

        IF  NOT TEMP-TABLE tt-extapl:HAS-RECORDS THEN
            DO:
                ASSIGN aux_cdcritic = 11.
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

END PROCEDURE. /* Busca_Extapl */

/* ------------------------------------------------------------------------- */
/*                  Efetua a Validação dos dados informados                  */
/* ------------------------------------------------------------------------- */
PROCEDURE Valida_Extapl:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.                  
    DEF  INPUT PARAM par_tpemiext AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabass FOR crapass.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".
    
    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-infoass.
        EMPTY TEMP-TABLE tt-extapl.
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT CAN-DO("A,C,T",par_cddopcao) THEN
            DO:
                ASSIGN aux_cdcritic = 14.
                LEAVE Valida.
            END.

        /* Validar o digito da conta */
        IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrdconta ) THEN
            DO:
               ASSIGN aux_cdcritic = 8.
               LEAVE Valida.
            END.

        /* Informacoes sobre o cooperado */
        FOR FIRST crabass FIELDS(cdcooper nrdconta nmprimtl)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Valida.
            END.

        IF  NOT CAN-DO("1,2,3",STRING(par_tpemiext)) THEN
            DO:
                ASSIGN aux_dscritic = "Impressao Extrato deve ser " +
                                      "1-Individual, 2-Todos ou 3-Nao imp.".
                LEAVE Valida.
            END.

        IF  par_cddopcao = "A"      AND
            par_tpaplica <> 6        AND 
            par_tpemiext = 2         AND 
            (CAN-FIND(FIRST craprda WHERE 
                         craprda.cdcooper = par_cdcooper AND
                         craprda.nrdconta = par_nrdconta AND
                         craprda.nraplica = par_nraplica))        
            AND
            (CAN-FIND(FIRST crapdtc WHERE 
                         crapdtc.cdcooper = par_cdcooper AND
                         crapdtc.tpaplica = par_tpaplica)) THEN 
            DO:
               
                ASSIGN aux_dscritic =   "As aplicacoes PRE ou POS " +
                                       "nao podem ter tipo de " +
                                       "impressao 2.".
                
                LEAVE Valida.
       
           END.
       

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
        DO:
            ASSIGN  aux_dstransa = "Valida Modo Impressao Extratos Aplicacoes".
    
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
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Extapl */

/* ------------------------------------------------------------------------- */
/*                 REALIZA A GRAVACAO DOS DADOS DA TELA EXTAPL               */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Extapl:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_descapli AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpemiext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM aux_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsemiext AS CHAR                                    NO-UNDO.

    ASSIGN aux_nrdrowid = ?
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsemiext = ""
           aux_returnvl = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-infoass.
        EMPTY TEMP-TABLE tt-extapl.
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT CAN-DO("A,T",par_cddopcao) THEN
            DO:
                ASSIGN aux_cdcritic = 14.
                LEAVE Grava.
            END.

        IF  par_tpemiext = 1 THEN
            ASSIGN aux_dsemiext = "Individual".
        ELSE
        IF  par_tpemiext = 2 THEN
            ASSIGN aux_dsemiext = "Todos juntos".
        ELSE
        IF  par_tpemiext = 3 THEN
            ASSIGN aux_dsemiext = "Nao imprime".

        IF  par_cddopcao = "A" THEN
            DO:
                CREATE tt-extapl.
                ASSIGN tt-extapl.nrsequen = 1
                       tt-extapl.descapli = par_descapli 
                       tt-extapl.tpaplica = par_tpaplica
                       tt-extapl.nraplica = par_nraplica.
                       
            END.
        ELSE
        IF  par_cddopcao = "T" THEN
            DO:
                RUN Busca_Extapl ( INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_nrdconta,
                                   INPUT "A", /* cddopcao */
                                   INPUT FALSE,
                                  OUTPUT TABLE tt-infoass,
                                  OUTPUT TABLE tt-extapl,
                                  OUTPUT TABLE tt-erro ).

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Grava.

            END.

        ASSIGN  aux_nrsequen = 0 
                aux_dstransa = "Grava Modo Impressao Extratos Aplicacoes".

        FOR EACH tt-extapl:

            IF  tt-extapl.tpaplica = 6 THEN
                DO:
                    FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                                       craprpp.nrdconta = par_nrdconta AND
                                       craprpp.nrctrrpp = tt-extapl.nraplica
                                       EXCLUSIVE-LOCK NO-ERROR.

                    IF  AVAIL craprpp THEN 
                        DO:
                            RUN proc_log 
                                ( INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT par_nrdconta,
                                  INPUT tt-extapl.descapli,
                                  INPUT tt-extapl.nraplica,
                                  INPUT craprpp.tpemiext,
                                  INPUT par_tpemiext).
    
                            ASSIGN craprpp.tpemiext = par_tpemiext.
                        
                        END.
                END.
            ELSE
                DO:
                    FIND craprda WHERE craprda.cdcooper = par_cdcooper AND
                                       craprda.nrdconta = par_nrdconta AND
                                       craprda.nraplica = tt-extapl.nraplica
                                       EXCLUSIVE-LOCK NO-ERROR.
                          
                    IF  AVAIL craprda THEN 
                        DO:
                            FOR FIRST crapdtc WHERE 
                                            crapdtc.cdcooper = par_cdcooper AND
                                            crapdtc.tpaplica = craprda.tpaplica
                                            NO-LOCK: END.

                            IF  AVAIL crapdtc THEN 
                                DO:
                                    IF  par_tpemiext = 2 THEN
                                        DO:
                                            ASSIGN aux_msgretor =   "As aplicacoes PRE ou POS " +
                                                                    "nao podem ter tipo de " +
                                                                    "impressao 2.".
                                            NEXT.
                                        END.
                                END.

                            RUN proc_log 
                                ( INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT par_nrdconta,
                                  INPUT tt-extapl.descapli,
                                  INPUT tt-extapl.nraplica,
                                  INPUT craprda.tpemiext,
                                  INPUT par_tpemiext).

                             ASSIGN craprda.tpemiext = par_tpemiext.
                 
                        END. /* AVAIL craprda */

                END. /* ELSE */

        END. /* FOR EACH tt-extapl: */

        ASSIGN aux_returnvl = "OK".

        LEAVE Grava.

    END. /* Grava */

    RELEASE craprpp.
    RELEASE craprda.
    
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
                DO:
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

                END.

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".


    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Extapl */

/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA DOS DADOS DO ASSOCIADO                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extcap:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-infoass.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabcot FOR crapcot.
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Extrato Capital"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-infoass.
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

        IF  NOT CAN-FIND (FIRST crabcot WHERE 
                                          crabcot.cdcooper = par_cdcooper AND
                                          crabcot.nrdconta = par_nrdconta) THEN
            DO:
                ASSIGN aux_cdcritic = 169.
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

END PROCEDURE. /* Busca_Extcap */

/* ------------------------------------------------------------------------ */
/*                   EFETUA A BUSCA DO EXTRATO DE CAPITAL                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extrato_Cotas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmovano AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM aux_vlsldant AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM aux_vlsldtot AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-ext_cotas.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabass FOR crapass.
    
    DEF VAR aux_dtmvtolt AS DATE                                    NO-UNDO.
    DEF VAR aux_dtlimite AS DATE                                    NO-UNDO.
    DEF VAR h-b1wgen0021 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_nrregist AS INTE                                    NO-UNDO.
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca Extrato de Capital"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-ext_cotas.
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

        IF  par_dtmovano = 0   THEN
            DO:
                ASSIGN aux_dtmvtolt = DATE(01,01,YEAR(par_dtmvtolt)).
            END.
        ELSE
        IF  par_dtmovano > YEAR(par_dtmvtolt) THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE Busca.
            END.
        ELSE
            ASSIGN aux_dtmvtolt = DATE(01,01,par_dtmovano).


        IF  NOT VALID-HANDLE(h-b1wgen0021) THEN
            RUN sistema/generico/procedures/b1wgen0021.p
                PERSISTENT SET h-b1wgen0021.

        IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0021.".
                LEAVE Busca.
            END.

        RUN extrato_cotas IN h-b1wgen0021 
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela, 
                          INPUT par_idorigem,
                          INPUT par_nrdconta,
                          INPUT 1, /* par_idseqttl  */
                          INPUT par_dtmvtolt,
                          INPUT aux_dtmvtolt,
                          INPUT par_dtmvtolt,
                          INPUT FALSE,
                         OUTPUT aux_vlsldant,
                         OUTPUT TABLE tt-extrato_cotas).
        
        IF  VALID-HANDLE(h-b1wgen0021) THEN
            DELETE PROCEDURE h-b1wgen0021.

        /* Tratamento de paginação somente para web*/
        IF  par_idorigem = 5 THEN
            DO:
                ASSIGN aux_nrregist = par_nrregist.

                FOR EACH tt-extrato_cotas NO-LOCK:

                    ASSIGN par_qtregist = par_qtregist + 1.

                    IF  ( par_qtregist = ( par_nriniseq - 1 )) AND
                        ( par_qtregist > 1 ) THEN
                        ASSIGN aux_vlsldant = tt-extrato_cotas.vlsldtot.

                    /* controles da paginação */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    /* controles da paginação */
                    IF  (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO: 
                            
                            ASSIGN aux_vlsldtot = tt-extrato_cotas.vlsldtot.

                            CREATE tt-ext_cotas.
                            BUFFER-COPY tt-extrato_cotas TO tt-ext_cotas.

                        END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.

                END.


            END.
        ELSE
            DO:
                FOR EACH tt-extrato_cotas:
                    CREATE tt-ext_cotas.
                    BUFFER-COPY tt-extrato_cotas TO tt-ext_cotas.
                END.
            END.

        ASSIGN aux_returnvl = "OK".

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

END PROCEDURE. /* Busca_Extrato */

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ PROCEDURES INTERNAS ................................*/
/* ------------------------------------------------------------------------- */
/*                      Procedure que loga alteracoes                        */
/* ------------------------------------------------------------------------- */
PROCEDURE proc_log:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_descapli AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpemiex1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpemiex2 AS INTE                           NO-UNDO.

    IF  par_tpemiex1 = par_tpemiex2  THEN
        RETURN "OK".
    
    ASSIGN aux_nrsequen = aux_nrsequen + 1.

    IF  aux_nrdrowid = ? THEN 
        DO:

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
    
    /* tpaplica */
    RUN proc_gerar_log_item 
        ( INPUT aux_nrdrowid,
          INPUT "tpaplica" + STRING(aux_nrsequen),
          INPUT STRING(par_descapli),
          INPUT STRING(par_descapli)).

    /* nraplica */                
    RUN proc_gerar_log_item 
        ( INPUT aux_nrdrowid,
          INPUT "nraplica" + STRING(aux_nrsequen),
          INPUT STRING(par_nraplica),
          INPUT STRING(par_nraplica)).

    /* tpemiext */
    RUN proc_gerar_log_item 
       ( INPUT aux_nrdrowid,
         INPUT "tpemiext" + STRING(aux_nrsequen),
         INPUT STRING(par_tpemiex1),
         INPUT STRING(par_tpemiex2)).


    RETURN "OK".

END PROCEDURE. /* proc_log */


/*................................ FUNCTIONS ................................*/

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
