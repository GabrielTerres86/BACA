/*.............................................................................

   Programa: siscaixa/web/tempo_execucao_taa.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Dezembro/2014                    Ultima atualizacao: 19/11/2015

   Dados referentes ao programa:

   Frequencia: Conforme tempo de monitoracao
   Objetivo  : Executar requisicao no servico WebSpeed do TAA para
               monitoracao de performance e disponibilidade
   
   Alteracoes: 19/11/2015 - Ajustado para utilizar a procedure de 
                            obtem-saldo-dia convertida em Oracle
                            (Douglas - Chamado 285228)
.............................................................................*/ 

ETIME(TRUE).

/* Include para usar os comandos para WEB */
{src/web2/wrap-cgi.i}

/* Configura a saída como XML */
OUTPUT-CONTENT-TYPE ("text/html":U).

/* BOs */
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0003tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }

    /* dados do associado nas operacoes */                     
DEFINE VARIABLE aux_cdcooper AS INT      NO-UNDO. /* cooperativa */                                                        
DEFINE VARIABLE aux_nrdconta AS INT      NO-UNDO. /* conta/dv */
DEFINE VARIABLE aux_cdcritic AS INT      NO-UNDO. /* codigo critica */
DEFINE VARIABLE aux_dscritic AS CHAR     NO-UNDO. /* descricao critica */
DEFINE VARIABLE h-b1wgen0003 AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0019 AS HANDLE   NO-UNDO.

ASSIGN aux_cdcooper = 1
       aux_nrdconta = 329.

FIND crapdat WHERE crapdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.

RUN obtem_saldo_limite.

IF  RETURN-VALUE = "NOK"   THEN
    {&out} "2 - NOK - Tempo: " + TRIM(STRING(ETIME,"zz9,999")) + " segundos".
ELSE
    {&out} "0 - OK  - Tempo: " + TRIM(STRING(ETIME,"zz9,999")) + " segundos".

PROCEDURE obtem_saldo_limite:

    /* SALDOS */
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    /* Utilizar o tipo de busca A, para carregar do dia anterior
      (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
    RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT aux_cdcooper,
                                 INPUT 91,              /* PAC      */
                                 INPUT 999,             /* Caixa    */
                                 INPUT "996",           /* Operador */
                                 INPUT aux_nrdconta,
                                 INPUT crapdat.dtmvtocd,
                                 INPUT "A", /* Tipo Busca */
                                 OUTPUT 0,
                                 OUTPUT "").

    CLOSE STORED-PROC pc_obtem_saldo_dia_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic 
                              WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
           aux_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                              WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?. 

    IF aux_cdcritic <> 0  OR 
       aux_dscritic <> "" THEN
       DO: 
           RETURN "NOK".
       END.

    /* LIMITE */
    RUN sistema/generico/procedures/b1wgen0019.p PERSISTENT SET h-b1wgen0019.

    RUN obtem-valor-limite IN h-b1wgen0019 (INPUT aux_cdcooper,
                                            INPUT 91,           /* PAC */
                                            INPUT 999,          /* Caixa */
                                            INPUT "996",        /* Operador */
                                            INPUT "TAA",        /* Tela */
                                            INPUT 4,            /* Origem - TAA */
                                            INPUT aux_nrdconta,
                                            INPUT 1,            /* Titular */
                                            INPUT FALSE,        /* Log */
                                           OUTPUT TABLE tt-limite-credito,
                                           OUTPUT TABLE tt-erro) NO-ERROR.

    DELETE PROCEDURE h-b1wgen0019.

    IF  ERROR-STATUS:NUM-MESSAGES > 0 THEN
        RETURN "NOK".

    /* LANCAMENTOS FUTUROS */
    RUN sistema/generico/procedures/b1wgen0003.p PERSISTENT SET h-b1wgen0003.

    RUN consulta-lancamento IN h-b1wgen0003 (INPUT aux_cdcooper,
                                             INPUT 91,             /* PAC */
                                             INPUT 999,            /* Caixa */
                                             INPUT "996",          /* Operador */
                                             INPUT aux_nrdconta,
                                             INPUT 4,              /* Origem - TAA */
                                             INPUT 1,              /* Titular */
                                             INPUT "TAA",          /* Tela */
                                             INPUT FALSE,          /* Log */
                                            OUTPUT TABLE tt-totais-futuros,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-lancamento_futuro).

    DELETE PROCEDURE h-b1wgen0003.
                     
    IF  ERROR-STATUS:NUM-MESSAGES > 0 THEN
        RETURN "NOK".
                            
    RETURN "OK".

END PROCEDURE.
