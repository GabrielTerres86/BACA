/*............................................................................
   
   Programa: sistema/generico/procedures/b1wgen0193.p
   Autor   : James Prust Junior
   Data    : Janeiro/2015                       Ultima atualizacao: 05/01/2016
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Procedures referente a tela Contas - Liberar/Bloquear
      
   Alteracoes: 05/01/2016 - Adicionado leitura e gravacao do novo campo na
                            interface, flgcrdpa  (Anderson).
............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.

PROCEDURE busca_dados:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_flgrenli AS LOG                            NO-UNDO.
    DEF OUTPUT PARAM par_flgcrdpa    LIKE crapass.flgcrdpa          NO-UNDO.
    DEF OUTPUT PARAM par_libcrdpa AS LOGICAL                        NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.   

        /* pesquisa o associado */
        FOR crapass FIELDS(cdoplcpa flgcrdpa flgrenli)
                    WHERE crapass.cdcooper = par_cdcooper AND 
                          crapass.nrdconta = par_nrdconta 
                          NO-LOCK: END.

        IF NOT AVAILABLE crapass THEN
           DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
           END.

        /* Liberado para edicao quando:
           ou o associado possui pre-aprv.
           ou o associado nao possui pré-aprv e foi setado manualmente */
        ASSIGN par_flgrenli = crapass.flgrenli
               par_libcrdpa = (crapass.cdoplcpa <> "" AND crapass.cdoplcpa <> ? AND crapass.flgcrdpa = NO) 
                               OR crapass.flgcrdpa = YES
               par_flgcrdpa = crapass.flgcrdpa.

    END. /* END Busca: */

    IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1,           
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
    ELSE 
       ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.
    
END.

PROCEDURE grava_dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgrenli AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_flgcrdpa AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgrenli LIKE crapass.flgrenli                      NO-UNDO.
    DEF VAR aux_flgcrdpa LIKE crapass.flgcrdpa                      NO-UNDO.
    DEF VAR aux_cdoplcpa LIKE crapass.cdoplcpa                      NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR par_cddopcao AS CHAR INITIAL "A"                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Atualizar informacoes Desabilitar Operacoes do associado"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    TRANSACAO:
    DO TRANSACTION ON ERROR  UNDO TRANSACAO, LEAVE TRANSACAO 
                   ON ENDKEY UNDO TRANSACAO, LEAVE TRANSACAO:

       CONTADOR:
       DO aux_contador = 1 TO 10:
       
          FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta 
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
          IF NOT AVAILABLE crapass THEN 
             DO:
                 IF LOCKED crapass THEN 
                    DO:
                        IF  aux_contador = 10  THEN
                            DO:
                                FIND crapass WHERE 
                                 crapass.cdcooper = par_cdcooper AND
                                 crapass.nrdconta = par_nrdconta
                                 NO-LOCK NO-ERROR.
                                
                                RUN critica-lock 
                                   (INPUT RECID(crapass),
                                    INPUT "banco",
                                    INPUT "crapass",
                                    INPUT par_idorigem).
                            END.
                        ELSE
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT CONTADOR.
                            END.
                    END.
                 ELSE 
                    ASSIGN aux_cdcritic = 9.
             END.
          
          LEAVE CONTADOR.

       END. /** Fim do DO .. TO **/
        
       IF aux_dscritic <> ""  THEN
          UNDO TRANSACAO, LEAVE TRANSACAO.

       { sistema/generico/includes/b1wgenalog.i }

        ASSIGN aux_flgcrdpa = crapass.flgcrdpa
               aux_cdoplcpa = crapass.cdoplcpa.

        /* Caso a Flag de Credito Pre Aprovado tenha sido alterada */
        IF crapass.flgcrdpa <> par_flgcrdpa THEN           
           DO:
              /* Se NAO tem Codigo do Operador e foi setado como possui CPA */
              IF crapass.cdoplcpa = '' AND par_flgcrdpa = YES THEN
                 ASSIGN aux_flgcrdpa = NO.
              ELSE
                 DO: 
                    ASSIGN aux_flgcrdpa = par_flgcrdpa
                           aux_cdoplcpa = par_cdoperad.
                 END.
           END.

       ASSIGN aux_flgrenli     = crapass.flgrenli
              crapass.flgrenli = par_flgrenli
              crapass.flgcrdpa = aux_flgcrdpa
              crapass.cdoplcpa = aux_cdoplcpa.

       { sistema/generico/includes/b1wgenllog.i }

    END. /* END TRANSACAO: */

    IF par_flgerlog THEN
       DO:
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
        
           IF aux_flgrenli <> par_flgrenli  THEN
              RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                       INPUT "Renova Limite Credito Automatico",
                                       INPUT STRING(aux_flgrenli),
                                       INPUT STRING(par_flgrenli)).
           IF aux_flgcrdpa <> par_flgcrdpa THEN
              RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                       INPUT "Libera Credito Pre-aprovado",
                                       INPUT STRING(aux_flgcrdpa),
                                       INPUT STRING(par_flgcrdpa)).

       END. /* END IF par_flgerlog THEN */

    IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1,           
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
    ELSE 
       ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END.
/****************************************************************************/
