/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank210.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Quisinski
   Data    : Agosto/2017                       Ultima atualizacao:   /  /    
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Consultar as criticas geradas durante a validacao do arquivo 
               de agendamento de pagamento
   
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }


FUNCTION roundUp RETURNS INTEGER ( x as decimal ):
  IF x = TRUNCATE( x, 0 ) THEN
    RETURN INTEGER( x ).
  ELSE
    RETURN INTEGER(TRUNCATE( x, 0 ) + 1 ).
END.


DEF  INPUT PARAM par_cdcooper  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nrconven  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nrremret  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nmarquiv  AS CHAR                  NO-UNDO.
DEF  INPUT PARAM par_dtinilog  AS DATE                  NO-UNDO.
DEF  INPUT PARAM par_dtfimlog  AS DATE                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr  AS CHAR                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF    VAR       aux_dscritic  AS CHAR                  NO-UNDO.
DEF    VAR       aux_dslogxml  AS LONGCHAR              NO-UNDO.
DEF    VAR       aux_iteracoes AS INT                   NO-UNDO.
DEF    VAR       aux_posini    AS INT                   NO-UNDO.
DEF    VAR       aux_contador  AS INT                   NO-UNDO.

/* Gravar a critica no LOG de processamento do arquivo */
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_consulta_log_arq_pgto
    aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT par_cdcooper,  /* Cooperativa */
                   INPUT par_nrdconta,  /* Conta */
                   INPUT par_nrconven,  /* Convenio */
                   INPUT par_nrremret,  /* Numero da Remessa */
                   INPUT "CRAPHPT",     /* Tabela que foi manipulada para gerar o log */
                   INPUT par_nmarquiv,  /* Nome do arquivo que esta sendo processado*/ 
                   INPUT STRING(par_dtinilog, "99/99/9999"), /* Data Inicio do LOG */
                   INPUT STRING(par_dtfimlog, "99/99/9999"), /* Data Fim do LOG */
                  OUTPUT "",  /* LOG do processamento */ 
                  OUTPUT 0,   /* Código da crítica */
                  OUTPUT ""). /* Descricao da critica */


CLOSE STORED-PROC pc_consulta_log_arq_pgto
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_dscritic = ""
       aux_dscritic = pc_consulta_log_arq_pgto.pr_dscritic
                      WHEN pc_consulta_log_arq_pgto.pr_dscritic <> ?.

IF aux_dscritic <> "" THEN
DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                          "</dsmsgerr>".
    RETURN "NOK".
END.

ASSIGN aux_dslogxml = ""
       aux_dslogxml = pc_consulta_log_arq_pgto.pr_xml_log
                      WHEN pc_consulta_log_arq_pgto.pr_xml_log <> ?.

/***** Inicio - Carregamento do XML *****/

ASSIGN aux_iteracoes = roundUp(LENGTH(aux_dslogxml) / 31000)
       aux_posini    = 1.    

DO  aux_contador = 1 TO aux_iteracoes:
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = SUBSTRING(aux_dslogxml, aux_posini, 31000)
           aux_posini            = aux_posini + 31000.
               
END.

/***** FIM - Carregamento do XML *****/

RETURN "OK".