/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank205.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Quisinski
   Data    : Agosto/2017                       Ultima atualizacao:   /  /    
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Gravar as mensagens de crítica da validaçao do arquivo de LOG.
   
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF  INPUT PARAM par_cdcooper AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nrconven AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nrremret AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                  NO-UNDO.
DEF  INPUT PARAM par_nmoperad AS CHAR                  NO-UNDO.
DEF  INPUT PARAM par_cdprogra AS CHAR                  NO-UNDO.
DEF  INPUT PARAM par_nmarquiv AS CHAR                  NO-UNDO.
DEF  INPUT PARAM par_dsmsglog AS CHAR                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                  NO-UNDO.

DEF    VAR       aux_dscritic AS CHAR                  NO-UNDO.

/* Gravar a critica no LOG de processamento do arquivo */
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_gera_log_arq_pgto
    aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT par_cdcooper,  /* Cooperativa */
                   INPUT par_nrdconta,  /* Conta */
                   INPUT par_nrconven,  /* Convenio */
                   INPUT 1, /* Inidicador do tipo de movimento (1-Remessa/ 2-Retorno) */
                   INPUT par_nrremret,  /* Numero da Remessa */
                   INPUT par_cdoperad,  /* Operador logado na conta online */
                   INPUT par_nmoperad,  /* Nome do operador logado na conta online */
                   INPUT par_cdprogra,  /* Programa que chamou a gravacao */
                   INPUT "CRAPHPT",     /* Tabela que foi manipulada para gerar o log */
                   INPUT par_nmarquiv,  /* Nome do arquivo que esta sendo processado*/ 
                   INPUT par_dsmsglog,  /* Descricao do LOG */
                  OUTPUT 0,             /* Código da crítica */
                  OUTPUT "").           /* Descricao da critica */


CLOSE STORED-PROC pc_gera_log_arq_pgto
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_dscritic = ""
       aux_dscritic = pc_gera_log_arq_pgto.pr_dscritic
                      WHEN pc_gera_log_arq_pgto.pr_dscritic <> ?.

IF aux_dscritic <> "" THEN
DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                          "</dsmsgerr>".
    RETURN "NOK".
END.

RETURN "OK".