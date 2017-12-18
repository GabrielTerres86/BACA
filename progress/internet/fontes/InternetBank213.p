/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank213.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Quisinski
   Data    : Agosto/2017                       Ultima atualizacao:   /  /    
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Gerar relatório dos titulos que foram agendados atraves do arquivo
   
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }


DEF  INPUT PARAM par_cdcooper  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nrremess  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nmarquiv  AS CHAR                  NO-UNDO.
DEF  INPUT PARAM par_nmbenefi  AS CHAR                  NO-UNDO.
DEF  INPUT PARAM par_dscodbar  AS CHAR                  NO-UNDO.
DEF  INPUT PARAM par_idstatus  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_tpdata    AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_dtiniper  AS DATE                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper  AS DATE                  NO-UNDO.
DEF  INPUT PARAM par_tprelato  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_iddspscp  AS INTE                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr  AS CHAR                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF    VAR       aux_nmrelato  AS CHAR                  NO-UNDO.
DEF    VAR       aux_dssrvarq  AS CHAR                  NO-UNDO.
DEF    VAR       aux_dsdirarq  AS CHAR                  NO-UNDO.
DEF    VAR       aux_dscritic  AS CHAR                  NO-UNDO.

/* Relatorio */
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_relato_arq_pgto_ib
    aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT par_cdcooper  /* Cod Cooperativa */
                  ,INPUT "" /* Nome da tela */
                  ,INPUT 90 /* PA */
                  ,INPUT 900 /* Numero caixa */
                  ,INPUT "996" /* Cod Operador */
                  ,INPUT par_nrdconta /* Conta */
                  ,INPUT par_nrremess /* Numero da Remessa */
                  ,INPUT par_nmarquiv /* Nome do arquivo que esta sendo processado */
                  ,INPUT par_nmbenefi /* Nome do beneficiario */
                  ,INPUT par_dscodbar /* Codigo de barras */ 
                  ,INPUT par_idstatus /* Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidaçao / 4-Com erro */
                  ,INPUT par_tpdata /* Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento) */
                  ,INPUT STRING(par_dtiniper, "99/99/9999") /* Data inicial de pesquisa */ 
                  ,INPUT STRING(par_dtfimper, "99/99/9999") /* Data final   de pesquisa */ 
                  ,INPUT 3 /* Sistema de origem chamador -> INTERNET BANK */
                  ,INPUT par_tprelato /* Tipo do relatorio (1-PDF /2-CSV) */ 
                  ,INPUT par_iddspscp /* Parametro criado para permitir a geracao do relatorio para o IB atual e para o IB novo */                  
                  ,OUTPUT "" /* Nome do arquivo do relatorio com extensao */
                  ,OUTPUT "" /* Nome do servidor para download do arquivo */
                  ,OUTPUT "" /* Nome do diretório para download do arquivo */                  
                  ,OUTPUT 0 /* Código da crítica */ 
                  ,OUTPUT ""). /* Descricao da critica */

CLOSE STORED-PROC pc_relato_arq_pgto_ib
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_nmrelato = ""
           aux_dscritic = ""
           aux_nmrelato = pc_relato_arq_pgto_ib.pr_nmrelato
                          WHEN pc_relato_arq_pgto_ib.pr_nmrelato <> ?
           aux_dssrvarq = pc_relato_arq_pgto_ib.pr_dssrvarq
                          WHEN pc_relato_arq_pgto_ib.pr_dssrvarq <> ?
           aux_dsdirarq = pc_relato_arq_pgto_ib.pr_dsdirarq
                          WHEN pc_relato_arq_pgto_ib.pr_dsdirarq <> ?                          
           aux_dscritic = pc_relato_arq_pgto_ib.pr_dscritic
                          WHEN pc_relato_arq_pgto_ib.pr_dscritic <> ?.


IF aux_dscritic <> "" THEN
DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                          "</dsmsgerr>".
    RETURN "NOK".
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<nmrelato>" + aux_nmrelato + "</nmrelato>" +
                               "<dssrvarq>" + aux_dssrvarq + "</dssrvarq>" +
                               "<dsdirarq>" + aux_dsdirarq + "</dsdirarq>".

RETURN "OK".