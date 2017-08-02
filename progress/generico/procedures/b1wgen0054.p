/*.............................................................................

    Programa: b1wgen0054.p
    Autor   : Jose Luis (DB1)
    Data    : Janeiro/2010                   Ultima atualizacao: 19/04/2017

    Objetivo  : Tranformacao BO tela CONTAS - FILIACAO, task 119

    Alteracoes: 22/09/2010 -  Adicionado tratamento para conta 'pai' 
                              ou 'filha' (Gabriel - DB1).
                              
                20/12/2010 -  Adicionado parametros na chamada do procedure
                              Replica_Dados para tratamento do log e  erros
                              da validação na replicação (Gabriel - DB1).
   
				19/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).
   
.............................................................................*/


/*................................ DEFINICOES ...............................*/


{ sistema/generico/includes/b1wgen0054tt.i &TT-LOG=SIM }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                           NO-UNDO.

/*................................ PROCEDURES ...............................*/
PROCEDURE Busca_Dados:

  DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
  DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
  DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_idseqttl AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_flgerlog AS LOGI                             NO-UNDO.

  DEF OUTPUT PARAM par_msgconta AS CHAR                             NO-UNDO.

  DEF OUTPUT PARAM TABLE FOR tt-filiacao.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF BUFFER bcrapass FOR crapass.
  DEF BUFFER bcrapttl FOR crapttl.

  DEF BUFFER crabttl FOR crapttl.
  DEF BUFFER crabass FOR crapass.

  DEF VAR aux_dtaltera AS DATE                              NO-UNDO.
  DEF VAR aux_nrdconta AS INTE                              NO-UNDO.
  DEF VAR h-b1wgen0077 AS HANDLE                            NO-UNDO.

  EMPTY TEMP-TABLE tt-filiacao.
  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
         aux_dstransa = "Busca dados da Filiacao"
         aux_cdcritic = 0
         aux_dscritic = ""
         aux_retorno  = "NOK".

  Filiacao: DO ON ERROR UNDO, RETURN ERROR:
      EMPTY TEMP-TABLE tt-filiacao.
      
      FIND bcrapass WHERE bcrapass.cdcooper = par_cdcooper AND
                          bcrapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

      IF  NOT AVAILABLE bcrapass THEN 
          DO:
              ASSIGN aux_dscritic = "Associado nao encontrado".
              LEAVE Filiacao.
          END.

      FIND bcrapttl WHERE bcrapttl.cdcooper = bcrapass.cdcooper AND
                          bcrapttl.nrdconta = bcrapass.nrdconta AND
                          bcrapttl.idseqttl = par_idseqttl     
                          NO-LOCK NO-ERROR.

      IF  NOT AVAILABLE bcrapttl THEN 
          DO:
              ASSIGN aux_dscritic = "Titular nao encontrado".
              LEAVE Filiacao.
          END.

      CREATE tt-filiacao.
      ASSIGN 
          tt-filiacao.nmpaittl = bcrapttl.nmpaittl
          tt-filiacao.nmmaettl = bcrapttl.nmmaettl NO-ERROR.

      IF  ERROR-STATUS:ERROR THEN
          ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).

      /* Rotina para controle/replicacao entre contas */
      IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
          RUN sistema/generico/procedures/b1wgen0077.p 
              PERSISTENT SET h-b1wgen0077.

      RUN Busca_Conta IN h-b1wgen0077
          ( INPUT par_cdcooper,
            INPUT par_nrdconta,
            INPUT bcrapttl.nrcpfcgc,
            INPUT par_idseqttl,
           OUTPUT aux_nrdconta,
           OUTPUT par_msgconta,
           OUTPUT aux_cdcritic,
           OUTPUT aux_dscritic ).

      IF  VALID-HANDLE(h-b1wgen0077) THEN
          DELETE OBJECT h-b1wgen0077.

      LEAVE Filiacao.
  END.

  IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
      RUN gera_erro (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT 1,
                     INPUT aux_cdcritic,
                     INPUT-OUTPUT aux_dscritic).
  ELSE ASSIGN aux_retorno = "OK".

  IF  par_flgerlog  THEN
      RUN proc_gerar_log (INPUT par_cdcooper,
                          INPUT par_cdoperad,
                          INPUT "",
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

/*****************************************************************************/
/**                 Procedure para validar dados da filiacao                **/
/*****************************************************************************/
PROCEDURE Valida_Dados:

  DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
  DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
  DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_idseqttl AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_flgerlog AS LOGI                             NO-UNDO.
  DEF  INPUT PARAM par_nmmaettl AS CHAR                             NO-UNDO.
  DEF  INPUT PARAM par_nmpaittl AS CHAR                             NO-UNDO.

  DEF OUTPUT PARAM par_nmdcampo AS CHAR                             NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR h-b1wgen9999 AS HANDLE.                         

  EMPTY TEMP-TABLE tt-erro.
  
  ASSIGN
      aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
      aux_dstransa = "Valida dados da Filiacao"
      aux_cdcritic = 0
      aux_dscritic = ""
      aux_retorno  = "NOK".

  Valida: DO ON ERROR UNDO Valida, LEAVE Valida:

      IF   NOT VALID-HANDLE(h-b1wgen9999) THEN
           RUN sistema/generico/procedures/b1wgen9999.p 
           PERSISTENT SET h-b1wgen9999.

      RUN Critica_Nome IN h-b1wgen9999 
          ( INPUT par_nmpaittl,
            OUTPUT aux_cdcritic ).

      IF  aux_cdcritic <> 0 THEN
          DO:
             ASSIGN par_nmdcampo = "nmpaittl".
             LEAVE Valida.
          END.

      RUN Critica_Nome IN h-b1wgen9999 
          ( INPUT par_nmmaettl,
            OUTPUT aux_cdcritic ).

      IF  aux_cdcritic <> 0 THEN 
          DO:
             ASSIGN par_nmdcampo = "nmmaettl".
             LEAVE Valida.
          END.
          
      IF  par_nmmaettl = "" THEN
          DO:
            ASSIGN
                par_nmdcampo = "nmmaettl"
                aux_dscritic = "O nome da mae deve ser informado.".
            LEAVE Valida.
          END.

      IF  CAPS(par_nmmaettl) = CAPS(par_nmpaittl) THEN
          DO: 
              ASSIGN 
                  par_nmdcampo = "nmmaettl"
                  aux_cdcritic = 30.
              LEAVE Valida.
          END.
  END.

  IF   VALID-HANDLE(h-b1wgen9999) THEN
       DELETE PROCEDURE h-b1wgen9999.

  IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
      RUN gera_erro (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT 1,
                     INPUT aux_cdcritic,
                     INPUT-OUTPUT aux_dscritic).
  ELSE 
      ASSIGN aux_retorno = "OK".

  IF  par_flgerlog AND aux_retorno <> "OK" THEN
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

/*****************************************************************************/
/**                 Procedure para gravar dados da filiacao                 **/
/*****************************************************************************/
PROCEDURE Grava_Dados.

  DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
  DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
  DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_idseqttl AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_flgerlog AS LOGI                             NO-UNDO.
  DEF  INPUT PARAM par_nmmaettl AS CHAR                             NO-UNDO.
  DEF  INPUT PARAM par_nmpaittl AS CHAR                             NO-UNDO.
  DEF  INPUT PARAM par_cddopcao AS CHAR                             NO-UNDO.
  DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.

  DEF OUTPUT PARAM par_msgalert AS CHAR                             NO-UNDO.
  DEF OUTPUT PARAM log_tpatlcad AS INTE                             NO-UNDO.
  DEF OUTPUT PARAM log_msgatcad AS CHAR                             NO-UNDO.
  DEF OUTPUT PARAM log_chavealt AS CHAR                             NO-UNDO.

  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_contador AS INTE                                      NO-UNDO.
  DEF VAR h-b1wgen0077 AS HANDLE                                    NO-UNDO.
  DEFINE BUFFER bcrapttl FOR crapttl.

  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
         aux_dstransa = "Grava dados da Filiacao"
         aux_cdcritic = 0
         aux_dscritic = ""
         aux_retorno  = "NOK".

  Grava: DO TRANSACTION 
            ON ERROR  UNDO Grava, LEAVE Grava 
            ON QUIT   UNDO Grava, LEAVE Grava
            ON STOP   UNDO Grava, LEAVE Grava
            ON ENDKEY UNDO Grava, LEAVE Grava:

      ContadorAss: DO aux_contador = 1 TO 10:
          FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF  NOT AVAILABLE crapass THEN
              DO:
                  IF  LOCKED(crapass) THEN
                      DO:
                         IF  aux_contador = 10 THEN
                             DO:
                                aux_dscritic = "Associado sendo alterado" +
                                               " em outra estacao".
                                LEAVE ContadorAss.
                             END.
                         ELSE 
                             DO: 
                                PAUSE 1 NO-MESSAGE.
                                NEXT ContadorAss.
                             END.
                      END.
                  ELSE
                      DO:
                         ASSIGN aux_cdcritic = 72.
                         LEAVE ContadorAss.  
                      END.
              END.
          ELSE 
              LEAVE ContadorAss.
      END.

      IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
          UNDO Grava, LEAVE Grava.

      ContadorTtl: DO aux_contador = 1 TO 10:
          FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = par_nrdconta AND
                                   crapttl.idseqttl = par_idseqttl
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE crapttl THEN
               DO:
                  IF  LOCKED(crapttl) THEN
                      DO:
                         IF  aux_contador = 10 THEN
                             DO:
                                aux_dscritic = "Titular sendo alterado " +
                                               "em outra estacao".
                                LEAVE ContadorTtl.
                             END.
                         ELSE 
                             DO: 
                                PAUSE 1 NO-MESSAGE.
                                NEXT ContadorTtl.
                             END.
                      END.
                  ELSE
                      DO:
                         ASSIGN aux_dscritic = "Titular nao cadastrado.".
                         LEAVE ContadorTtl.  
                      END.
               END.
          ELSE 
              LEAVE ContadorTtl.
      END.

      IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
          UNDO Grava, LEAVE Grava.

      EMPTY TEMP-TABLE tt-filiacao-ant.
      EMPTY TEMP-TABLE tt-filiacao-atl.

      CREATE tt-filiacao-ant.
      BUFFER-COPY crapass TO tt-filiacao-ant.
      BUFFER-COPY crapttl TO tt-filiacao-ant.
      
      IF  par_flgerlog  THEN 
          DO:
              { sistema/generico/includes/b1wgenalog.i }
          END.
      
      CASE par_idseqttl:
         WHEN 1 THEN ASSIGN crapass.dsfiliac = CAPS(par_nmpaittl)
                                               + " E " +
                                               CAPS(par_nmmaettl).
      END CASE.

      ASSIGN crapttl.nmpaittl = CAPS(par_nmpaittl)
             crapttl.nmmaettl = CAPS(par_nmmaettl).

      CREATE tt-filiacao-atl.
      BUFFER-COPY crapass TO tt-filiacao-atl.
      BUFFER-COPY crapttl TO tt-filiacao-atl.

      IF  par_flgerlog  THEN 
          DO:
              { sistema/generico/includes/b1wgenllog.i }
          END.
      
      /* Realiza a replicacao dos dados para as contas relacionadas ao coop. */
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
                   INPUT "FILIACAO",
                   INPUT par_dtmvtolt,
                   INPUT FALSE, /*par_flgerlog*/
                  OUTPUT aux_cdcritic,
                  OUTPUT aux_dscritic,
                  OUTPUT TABLE tt-erro ) NO-ERROR.

             IF  VALID-HANDLE(h-b1wgen0077) THEN
                 DELETE OBJECT h-b1wgen0077.
             
             IF  RETURN-VALUE <> "OK" THEN
                 UNDO Grava, LEAVE Grava.

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
                    OUTPUT par_msgalert ).

                 IF  VALID-HANDLE(h-b1wgen0077) THEN
                     DELETE OBJECT h-b1wgen0077.
                 
             END.

          END.
      
      ASSIGN aux_retorno = "OK".

      LEAVE Grava.
  END.

  IF  VALID-HANDLE(h-b1wgen0077) THEN
      DELETE OBJECT h-b1wgen0077.

  IF  AVAILABLE crapass  THEN
      FIND CURRENT crapass NO-LOCK NO-ERROR.

  IF  AVAILABLE crapttl  THEN
      FIND CURRENT crapttl NO-LOCK NO-ERROR.

  IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
      DO:
         ASSIGN aux_retorno = "NOK".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,
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
            INPUT BUFFER tt-filiacao-ant:HANDLE,
            INPUT BUFFER tt-filiacao-atl:HANDLE ).

  RETURN aux_retorno.

END PROCEDURE. 

/*................................. FUNCTIONS ...............................*/

