/*............................................................................

   Programa: b1wgen0056.p
   Sistema : Conta-Corrente - Cooperativa de Credito.
   Sigla   : CRED
   Autor   : Jose Luis (DB1)
   Data    : Marco/2010                        Ultima alteracao: 17/08/2015 

   Dados referentes ao programa:
   
   Frequencia: Diario(Ayllos).
   Objetivo  : Tratar Bens do associado. Baseado no fonte fontes/contas_bens.p
   
   Alteracoes: 02/03/10 - Procedure p/ buscar os dados (Jose Luis, DB1)
               
               22/09/2010 -  Adicionado tratamento para conta 'pai' 
                             ou 'filha' (Gabriel - DB1).
                             
              28/10/2010 - Retirar a critica que trata sobre o cadastro
                           dos bens com a mesma descricao (Gabriel).
                           
              20/12/2010 -  Adicionado parametros na chamada do procedure
                            Replica_Dados para tratamento do log e  erros
                            da validação na replicação (Gabriel - DB1).
                            
              13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
              
              28/03/2014 - Inclusao do log para a tela atenda na inclusao de
                           bens (Carlos)
                           
              20/06/2014 - Correção Revisão Cadastral (SD. 168091  - Lucas)
              
              30/07/2014 - Adicionado replace de caracteres que possam dar 
                           erro na monstagem da string do bem.
                           (Jorge/Gielow) - SD 183551
                           
              17/08/2015 - Adicionado replace de apostrofo na descricao do bem.
                           (Jorge/Gielow) - SD 320666             
          
              11/10/2017 - REMOVIDO REPLICACAO DE BENS pois replicaçao será realizada 
                           pelas triggres do cadastro de pessoa unificado.
                           PRJ339 -CRM (Odirlei-AMcom)
          
.............................................................................*/

{ sistema/generico/includes/b1wgen0056tt.i &TT-LOG=SIM }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &SESSAO-BO=SIM }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0077 AS HANDLE                                      NO-UNDO.

PROCEDURE inclui-registro:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dsrelbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtaltbem AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_persemon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtprebem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlprebem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrdobem AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_msgalert AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_idseqbem AS INTE                                    NO-UNDO.
    DEF VAR aux_msgalert AS CHAR                                    NO-UNDO.
    DEFINE BUFFER bcrapttl FOR crapttl.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    ASSIGN 
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Inclui Bens"
        aux_cdcritic = 0
        aux_dscritic = ""
        aux_retorno  = "NOK".
    
    Inclui: DO TRANSACTION
        ON ERROR  UNDO Inclui, LEAVE Inclui
        ON QUIT   UNDO Inclui, LEAVE Inclui
        ON STOP   UNDO Inclui, LEAVE Inclui
        ON ENDKEY UNDO Inclui, LEAVE Inclui:
       
                /* Pega o ultimo na sequencia do titular */
        FIND LAST crapbem WHERE crapbem.cdcooper = par_cdcooper   AND
                                crapbem.nrdconta = par_nrdconta   AND
                                crapbem.idseqttl = par_idseqttl  
                                NO-LOCK NO-ERROR .

        IF   AVAILABLE crapbem THEN 
             ASSIGN aux_idseqbem = crapbem.idseqbem + 1.
        ELSE ASSIGN aux_idseqbem = 1.

        CREATE crapbem.
        ASSIGN 
            crapbem.cdcooper = par_cdcooper
            crapbem.cdoperad = par_cdoperad
            crapbem.dsrelbem = UPPER(par_dsrelbem)
            crapbem.dtaltbem = par_dtaltbem
            crapbem.dtmvtolt = par_dtmvtolt
            crapbem.idseqttl = par_idseqttl
            crapbem.nrdconta = par_nrdconta
            crapbem.persemon = par_persemon
            crapbem.qtprebem = par_qtprebem
            crapbem.vlprebem = par_vlprebem
            crapbem.vlrdobem = par_vlrdobem
            crapbem.idseqbem = aux_idseqbem.
        VALIDATE crapbem.

        /* Registra a inclusao na tela ALTERA */
        ContadorAlt: DO aux_contador = 1 TO 10:
            FIND crapalt WHERE crapalt.cdcooper = par_cdcooper    AND
                               crapalt.nrdconta = par_nrdconta    AND
                               crapalt.dtaltera = par_dtmvtolt
                               USE-INDEX crapalt1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAILABLE crapalt   THEN
                DO:
                    IF  LOCKED(crapalt) THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    ASSIGN aux_dscritic = "Registro sendo alterado em" +
                                                          " outro terminal (crapalt)".
                                    LEAVE ContadorAlt.
                                END.
                            ELSE
                                DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT ContadorAlt.
                                END.
                        END.
                    ELSE
                        DO:
                            CREATE crapalt.
                            ASSIGN crapalt.nrdconta = par_nrdconta
                                   crapalt.dtaltera = par_dtmvtolt
                                   crapalt.tpaltera = 2
                                   crapalt.dsaltera = " [" + par_nmdatela + 
                                                      "] Inc. bem " + crapbem.dsrelbem +
                                                      " " + STRING(par_idseqttl) + ".ttl, "
                                   crapalt.cdcooper = par_cdcooper
                                   crapalt.cdoperad = par_cdoperad.
                
                            VALIDATE crapalt.
                            LEAVE ContadorAlt.
                        END.
                END.
            ELSE
                DO:
                    ASSIGN crapalt.dsaltera = crapalt.dsaltera + " [" + par_nmdatela + 
                                              "] Inc. bem " + crapbem.dsrelbem + 
                                              " " + STRING(par_idseqttl) + ".ttl, "
                           crapalt.cdoperad = par_cdoperad.
                    RELEASE crapalt.
                    LEAVE ContadorAlt.
                END.
        END.  /*  Fim do DO TO  */


        /* mensagem de alerta */
        IF   crapbem.dsrelbem MATCHES "*CASA*"   THEN
             ASSIGN par_msgalert = "Verifique se o item ENDERECO deve " + 
                                    "ser atualizado.".

        CREATE tt-crapbem-ant.
        ASSIGN
            tt-crapbem-ant.cdcooper = par_cdcooper
            tt-crapbem-ant.nrdconta = par_nrdconta.

        CREATE tt-crapbem-atl.
        BUFFER-COPY crapbem TO tt-crapbem-atl.
        
       /* Realiza a replicacao dos dados p/as contas relacionadas ao coop. */
/*        IF  par_idseqttl = 1 AND par_nmdatela = "CONTAS" THEN 
            DO:
               IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                   RUN sistema/generico/procedures/b1wgen0077.p 
                        PERSISTENT SET h-b1wgen0077.
               
               RUN Replica_Dados IN h-b1wgen0077
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT "BENS",
                     INPUT par_dtmvtolt,
                     INPUT FALSE, /*par_flgerlog*/
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic,
                    OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen0077) THEN
                   DELETE OBJECT h-b1wgen0077.

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO Inclui, LEAVE Inclui.

               FIND FIRST bcrapttl WHERE bcrapttl.cdcooper = par_cdcooper AND
                                         bcrapttl.nrdconta = par_nrdconta AND
                                         bcrapttl.idseqttl = par_idseqttl
                                         NO-ERROR.
    
               IF AVAILABLE bcrapttl THEN DO:
                    
                   IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                       RUN sistema/generico/procedures/b1wgen0077.p
                           PERSISTENT SET h-b1wgen0077.
                   
                   RUN Revisao_Cadastral IN h-b1wgen0077
                     ( INPUT par_cdcooper,
                       INPUT bcrapttl.nrcpfcgc,
                       INPUT par_nrdconta,
                      OUTPUT par_msgrvcad ).

                   IF  VALID-HANDLE(h-b1wgen0077) THEN
                       DELETE OBJECT h-b1wgen0077.
                   
               END.

            END.*/

        ASSIGN aux_retorno = "OK" .

        LEAVE Inclui.
    END.

    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    RELEASE crapbem.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_retorno = "NOK" .

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.

    IF  par_flgerlog THEN
        RUN proc_gerar_log_tab
            ( INPUT par_cdcooper,
              INPUT par_cdoperad,
              INPUT aux_dscritic,
              INPUT aux_dsorigem,
              INPUT aux_dstransa,
              INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
              INPUT par_idseqttl, 
              INPUT par_nmdatela, 
              INPUT par_nrdconta, 
              INPUT YES,
              INPUT BUFFER tt-crapbem-ant:HANDLE,
              INPUT BUFFER tt-crapbem-atl:HANDLE ).
    
    RETURN aux_retorno.
    
END PROCEDURE. /* Procedure de inclusao de registro */


PROCEDURE altera-registro:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dsrelbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtaltbem AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_persemon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtprebem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlprebem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrdobem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_idseqbem AS INTE                           NO-UNDO.
                                                                    
    DEF OUTPUT PARAM par_msgalert AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                             

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_msgalert AS CHAR                                    NO-UNDO.
    DEF BUFFER bcrapttl FOR crapttl.

    ASSIGN 
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Altera Bens"
        aux_cdcritic = 0
        aux_dscritic = ""
        aux_retorno  = "NOK".

    Altera: DO TRANSACTION
        ON ERROR  UNDO Altera, LEAVE Altera
        ON QUIT   UNDO Altera, LEAVE Altera
        ON STOP   UNDO Altera, LEAVE Altera
        ON ENDKEY UNDO Altera, LEAVE Altera:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta   
                           NO-LOCK NO-ERROR.

        Contador: DO aux_contador = 1 TO 10:

            FIND crapbem WHERE ROWID(crapbem) = par_nrdrowid
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapbem   THEN
                DO:
                    IF   LOCKED crapbem  THEN
                         DO:
                             IF  aux_contador = 10 THEN
                                 DO:
                                    ASSIGN aux_cdcritic = 341.
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
                             aux_dscritic = "Registro do bem nao foi " + 
                                            "encontrado.".
                             LEAVE Contador.
                         END.
                END.
            ELSE
                DO:
                   ASSIGN aux_dscritic = "".
                   LEAVE Contador.
                END.

        END. /* Fim do DO ... TO */

        IF   aux_dscritic <> ""   THEN
             LEAVE Altera.

        /* mensagem de alerta */
        IF  crapbem.dsrelbem MATCHES "*CASA*" OR par_dsrelbem MATCHES "*CASA*" 
            THEN ASSIGN par_msgalert = "Verifique se o item ENDERECO deve " + 
                                       "ser atualizado.".

        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenalog.i }
            END.
        
        EMPTY TEMP-TABLE tt-crapbem-ant.
        EMPTY TEMP-TABLE tt-crapbem-atl.

        CREATE tt-crapbem-ant.
        BUFFER-COPY crapbem TO tt-crapbem-ant.

        ASSIGN
            crapbem.dsrelbem = UPPER(par_dsrelbem)
            crapbem.dtaltbem = par_dtaltbem
            crapbem.persemon = par_persemon
            crapbem.qtprebem = par_qtprebem
            crapbem.vlprebem = par_vlprebem
            crapbem.vlrdobem = par_vlrdobem.

        CREATE tt-crapbem-atl.
        BUFFER-COPY crapbem TO tt-crapbem-atl.

        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenllog.i }
            END.

        /* Realiza a replicacao dos dados p/as contas relacionadas ao coop. */
        IF  par_idseqttl = 1 AND par_nmdatela = "CONTAS" THEN 
            DO:
               IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                   RUN sistema/generico/procedures/b1wgen0077.p 
                        PERSISTENT SET h-b1wgen0077.

               RUN Replica_Dados IN h-b1wgen0077
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT "BENS",
                     INPUT par_dtmvtolt,
                     INPUT FALSE, /*par_flgerlog*/
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic,
                    OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen0077) THEN
                   DELETE OBJECT h-b1wgen0077.

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO Altera, LEAVE Altera.

               FIND FIRST bcrapttl WHERE bcrapttl.cdcooper = par_cdcooper AND
                                         bcrapttl.nrdconta = par_nrdconta AND
                                         bcrapttl.idseqttl = par_idseqttl
                                         NO-ERROR.
    
               IF AVAILABLE bcrapttl THEN DO:
                    
                   IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                       RUN sistema/generico/procedures/b1wgen0077.p
                           PERSISTENT SET h-b1wgen0077.
                   
                   RUN Revisao_Cadastral IN h-b1wgen0077
                     ( INPUT par_cdcooper,
                       INPUT bcrapttl.nrcpfcgc,
                       INPUT par_nrdconta,
                      OUTPUT par_msgrvcad ).

                   IF  VALID-HANDLE(h-b1wgen0077) THEN
                       DELETE OBJECT h-b1wgen0077.
                   
               END.

            END.

        ASSIGN aux_retorno = "OK".

        LEAVE Altera.

    END.

    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    RELEASE crapbem NO-ERROR.    
        
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_retorno = "NOK" .

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.

    IF  par_flgerlog THEN
        DO:
           RUN proc_gerar_log_tab
               ( INPUT par_cdcooper,
                 INPUT par_cdoperad,
                 INPUT aux_dscritic,
                 INPUT aux_dsorigem,
                 INPUT aux_dstransa,
                 INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
                 INPUT par_idseqttl, 
                 INPUT par_nmdatela, 
                 INPUT par_nrdconta, 
                 INPUT YES,
                 INPUT BUFFER tt-crapbem-ant:HANDLE,
                 INPUT BUFFER tt-crapbem-atl:HANDLE ).
        END.

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE exclui-registro:

    DEF  INPUT PARAM par_cdcooper AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                         NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                        NO-UNDO.
    DEF  INPUT PARAM par_idseqbem AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                         NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                          NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                         NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                         NO-UNDO.

    DEF OUTPUT PARAM par_msgalert AS CHAR                         NO-UNDO.
    DEF OUTPUT PARAM log_tpatlcad AS INTE                         NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                         NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                         NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad AS CHAR                         NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_contador AS INTE                                  NO-UNDO.
    DEFINE BUFFER bcrapttl FOR crapttl.
    
    ASSIGN 
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Exclui Bens"
        aux_cdcritic = 0
        aux_dscritic = ""
        aux_retorno  = "NOK".

    Exclui: DO TRANSACTION
        ON ERROR  UNDO Exclui, LEAVE Exclui
        ON QUIT   UNDO Exclui, LEAVE Exclui
        ON STOP   UNDO Exclui, LEAVE Exclui
        ON ENDKEY UNDO Exclui, LEAVE Exclui:

        EMPTY TEMP-TABLE tt-erro.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta   
                           NO-LOCK NO-ERROR.

        Contador: DO aux_contador = 1 TO 10:

           FIND crapbem WHERE ROWID(crapbem) = par_nrdrowid 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF  NOT AVAILABLE crapbem   THEN
               DO:
                   IF  LOCKED crapbem  THEN
                       DO:
                           aux_dscritic = "Registro do bem ja esta sendo " + 
                                          "alterado em outro terminal.".
                           PAUSE 1 NO-MESSAGE.
                           NEXT Contador.
                       END.
                   ELSE
                       DO:
                           aux_dscritic = "Registro do bem nao foi " + 
                                          "encontrado.".
                           LEAVE Contador.
                       END.
               END.

           aux_dscritic = "".
           LEAVE Contador.

        END. /* Fim do DO ... TO */

        IF  aux_dscritic <> "" THEN
            UNDO Exclui, LEAVE Exclui.

        CREATE tt-crapbem-ant.
        BUFFER-COPY crapbem TO tt-crapbem-ant.

        CREATE tt-crapbem-atl.
        ASSIGN tt-crapbem-atl.cdcooper = par_cdcooper
               tt-crapbem-atl.nrdconta = par_nrdconta.
        
        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenalog.i }
                { sistema/generico/includes/b1wgenllog.i }
            END.
        
        /* mensagem de alerta */
        IF  crapbem.dsrelbem MATCHES "*CASA*" THEN
            ASSIGN par_msgalert = "Verifique se o item ENDERECO deve " + 
                                  "ser atualizado.".

        IF  aux_dscritic = "" THEN
            DELETE crapbem.     

        /* Realiza a replicacao dos dados p/as contas relacionadas ao coop. */
        /** REMOVIDO REPLICACAO DE BENS pois replixaçao será realizada pelas triggres do cadastro de pessoa 
          unificado
        
        IF  par_idseqttl = 1 AND par_nmdatela = "CONTAS" THEN 
            DO:
               IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                   RUN sistema/generico/procedures/b1wgen0077.p 
                        PERSISTENT SET h-b1wgen0077.

               RUN Replica_Dados IN h-b1wgen0077
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT "BENS",
                     INPUT par_dtmvtolt,
                     INPUT FALSE, /*par_flgerlog*/
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic,
                    OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen0077) THEN
                   DELETE OBJECT h-b1wgen0077.

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO Exclui, LEAVE Exclui.
            END.
            */

            FIND FIRST bcrapttl WHERE bcrapttl.cdcooper = par_cdcooper AND
                                      bcrapttl.nrdconta = par_nrdconta AND
                                      bcrapttl.idseqttl = par_idseqttl
                                      NO-ERROR.
    
            IF AVAILABLE bcrapttl THEN DO:
                 
                IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                    RUN sistema/generico/procedures/b1wgen0077.p
                        PERSISTENT SET h-b1wgen0077.
                
                RUN Revisao_Cadastral IN h-b1wgen0077
                  ( INPUT par_cdcooper,
                    INPUT bcrapttl.nrcpfcgc,
                    INPUT par_nrdconta,
                   OUTPUT par_msgrvcad ).

                IF  VALID-HANDLE(h-b1wgen0077) THEN
                    DELETE OBJECT h-b1wgen0077.
                
            END.

        ASSIGN aux_retorno = "OK".

        LEAVE Exclui.
    END.

    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_retorno = "NOK" .

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.

    IF  par_flgerlog THEN
        RUN proc_gerar_log_tab
            ( INPUT par_cdcooper,
              INPUT par_cdoperad,
              INPUT aux_dscritic,
              INPUT aux_dsorigem,
              INPUT aux_dstransa,
              INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
              INPUT par_idseqttl, 
              INPUT par_nmdatela, 
              INPUT par_nrdconta, 
              INPUT YES,
              INPUT BUFFER tt-crapbem-ant:HANDLE,
              INPUT BUFFER tt-crapbem-atl:HANDLE ).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca-Dados:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_idseqbem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.

    DEF OUTPUT PARAM par_msgconta AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapbem.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_nrcpfcto AS DEC                                     NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR aux_dsrelbem AS CHAR                                    NO-UNDO.

    ASSIGN 
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca os Bens"
        aux_cdcritic = 0
        aux_dscritic = ""
        aux_retorno  = "NOK"
        aux_dsrelbem = "".
            
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt-crapbem.

        FOR EACH crapbem WHERE crapbem.cdcooper = par_cdcooper AND
                               crapbem.nrdconta = par_nrdconta AND
                               crapbem.idseqttl = par_idseqttl AND 
                               (IF par_idseqbem <> 0 
                                THEN crapbem.idseqbem = par_idseqbem ELSE TRUE)
                               NO-LOCK:

            /* se esta buscando para Alterar ou Excluir,o rowid deve existir */
            IF  CAN-DO("A,E",par_cddopcao) AND ROWID(crapbem) <> par_nrdrowid 
                THEN
                NEXT.

            ASSIGN aux_dsrelbem = REPLACE(crapbem.dsrelbem,";",",").
            ASSIGN aux_dsrelbem = REPLACE(aux_dsrelbem,"|","-").
            ASSIGN aux_dsrelbem = REPLACE(aux_dsrelbem,"'","").
             
            CREATE tt-crapbem.
            BUFFER-COPY crapbem TO tt-crapbem.
            ASSIGN tt-crapbem.dsrelbem = aux_dsrelbem
                   tt-crapbem.nrdrowid = ROWID(crapbem)
                   tt-crapbem.vlrdobem = DECIMAL(STRING(crapbem.vlrdobem,
                                                        "999,999,999.99")).
        END.

        /* se for alteracao ou exclusao, deve encontrar o registro */
        IF  CAN-DO("A,E",par_cddopcao) AND 
            NOT TEMP-TABLE tt-crapbem:HAS-RECORDS THEN
            DO:
               ASSIGN aux_dscritic = "Registro do Bem nao foi encontrado".
               LEAVE Busca.
            END.

        /*Alteração: Busco o CPF para usa como parametro na Busca_Conta*/
        FOR FIRST crapttl FIELDS(nrcpfcgc)
            WHERE crapttl.cdcooper = par_cdcooper
              AND crapttl.nrdconta = par_nrdconta
              AND crapttl.idseqttl = par_idseqttl NO-LOCK:
                ASSIGN aux_nrcpfcto = crapttl.nrcpfcgc.
        END.
        
        /*Alteração:  Rotina para controle/replicacao entre contas */
        IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
            RUN sistema/generico/procedures/b1wgen0077.p 
                PERSISTENT SET h-b1wgen0077.

        RUN Busca_Conta IN h-b1wgen0077
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT aux_nrcpfcto,
              INPUT par_idseqttl,
             OUTPUT aux_nrdconta,
             OUTPUT par_msgconta,
             OUTPUT aux_cdcritic,
             OUTPUT aux_dscritic ).
        
        IF  VALID-HANDLE(h-b1wgen0077) THEN
            DELETE OBJECT h-b1wgen0077.

        LEAVE Busca.
    END.
    
    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE 
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog AND par_cddopcao = "C" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK"
                                   THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).
    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Valida-Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsrelbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_persemon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtprebem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlprebem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrdobem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_idseqbem AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    ASSIGN 
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados dos Bens"
        aux_cdcritic = 0
        aux_dscritic = ""
        aux_retorno  = "NOK".
    
    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_cddopcao = "E" THEN
            LEAVE Valida.

        IF  par_dsrelbem = "" THEN
            DO:
               ASSIGN aux_dscritic = "O campo 'Descricao do bem' deve ser " +
                                     "preenchido".
               LEAVE Valida.
            END.

        IF  par_persemon > 100 THEN
            DO:
                ASSIGN aux_dscritic = "Valor errado informado no campo " + 
                                      "'Percentual sem onus'.".
                LEAVE Valida.
            END.

        IF  par_qtprebem <= 0 AND par_persemon <> 100 THEN
            DO:
                ASSIGN aux_dscritic = "O campo 'Parcelas a pagar' deve ser " +
                                      "preenchido".
                LEAVE Valida.
            END.

        IF  par_vlprebem <= 0 AND par_persemon <> 100 THEN
            DO:
                ASSIGN aux_dscritic = "O campo 'Valor da Parcelas' deve ser " +
                                      "preenchido".
                LEAVE Valida.
            END.

        IF  par_vlrdobem = 0 THEN
            DO:
               ASSIGN aux_dscritic = "O campo 'Valor do Bem' deve ser " +
                                     "preenchido".
               LEAVE Valida.
            END.

        LEAVE Valida.
    END.

    IF   aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
        
    ELSE 
         ASSIGN aux_retorno = "OK".

    IF  aux_retorno <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN YES ELSE NO),
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).


    RETURN aux_retorno.

END PROCEDURE.

/*...........................................................................*/


