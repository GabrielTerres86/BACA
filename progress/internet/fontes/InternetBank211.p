/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank211.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Quisinski
   Data    : Agosto/2017                       Ultima atualizacao:   /  /    
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Consultar os titulos que foram agendados atraves do arquivo
   
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
DEF  INPUT PARAM par_nrremess  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nmarquiv  AS CHAR                  NO-UNDO.
DEF  INPUT PARAM par_nmbenefi  AS CHAR                  NO-UNDO.
DEF  INPUT PARAM par_dscodbar  AS CHAR                  NO-UNDO.
DEF  INPUT PARAM par_idstatus  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_tpdata    AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_dtiniper  AS DATE                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper  AS DATE                  NO-UNDO.
DEF  INPUT PARAM par_iniconta  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nrregist  AS INTE                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr  AS CHAR                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF    VAR       aux_dscritic  AS CHAR                  NO-UNDO.
DEF    VAR       aux_dsxml     AS LONGCHAR              NO-UNDO.
DEF    VAR       aux_iteracoes AS INT                   NO-UNDO.
DEF    VAR       aux_posini    AS INT                   NO-UNDO.
DEF    VAR       aux_contador  AS INT                   NO-UNDO.
DEF    VAR       aux_qttotage  AS INT                   NO-UNDO.

/* Regra implementada para atender IB Classico e Novo                                               */
/* IB Classico envia a posicao inicial sempre com valor par, por exemplo 0 na primeira paginacao    */
/* Novo IB por padrao envia sempre com valor impar, por exemplo 1 para primeira paginacao           */
/* Para manter a regra atual verifico se o valor e impar, e nesse caso decremento a posicao inicial */
IF  par_iniconta MOD 2 <> 0 THEN 
    ASSIGN par_iniconta = par_iniconta - 1.

/* Consultar os titulos agendados atraves do arquivo */
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_cons_tit_arq_pgto_car
    aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT par_cdcooper,  /* Cooperativa */
                   INPUT par_nrdconta,  /* Conta */
                   INPUT par_nrremess,  /* Numero da Remessa */
                   INPUT par_nmarquiv,  /* Nome do Arquivo */
                   INPUT par_nmbenefi,  /* Nome do Beneficiario */
                   INPUT par_dscodbar,  /* Codigo de Barras */
                   INPUT par_idstatus,  /* Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidaçao / 4-Com erro) */
                   INPUT par_tpdata,    /* Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento) */
                   INPUT STRING(par_dtiniper, "99/99/9999"), /* Data Inicio do Periodo */
                   INPUT STRING(par_dtfimper, "99/99/9999"), /* Data Fim do Periodo */
                   INPUT par_iniconta, /* Numero de Registros para listar em tela */
                   INPUT par_nrregist, /* Numero de Registros */
                  OUTPUT 0,   /* Quantidade Total de Agendamentos */
                  OUTPUT "",  /* LOG do processamento */ 
                  OUTPUT 0,   /* Código da crítica */
                  OUTPUT ""). /* Descricao da critica */

CLOSE STORED-PROC pc_cons_tit_arq_pgto_car
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_qttotage = 0
       aux_dscritic = ""
       aux_qttotage = pc_cons_tit_arq_pgto_car.pr_qttotage
                      WHEN pc_cons_tit_arq_pgto_car.pr_qttotage <> ?
       aux_dscritic = pc_cons_tit_arq_pgto_car.pr_dscritic
                      WHEN pc_cons_tit_arq_pgto_car.pr_dscritic <> ?.

IF aux_dscritic <> "" THEN
DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                          "</dsmsgerr>".
    RETURN "NOK".
END.

ASSIGN aux_dsxml = ""
       aux_dsxml = pc_cons_tit_arq_pgto_car.pr_xml
                      WHEN pc_cons_tit_arq_pgto_car.pr_xml <> ?.

/***** Inicio - Carregamento do XML *****/

ASSIGN aux_iteracoes = roundUp(LENGTH(aux_dsxml) / 31000)
       aux_posini    = 1.    

DO  aux_contador = 1 TO aux_iteracoes:
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = SUBSTRING(aux_dsxml, aux_posini, 31000)
           aux_posini            = aux_posini + 31000.
END.

/***** FIM - Carregamento do XML *****/

RETURN "OK".
