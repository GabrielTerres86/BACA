/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank74.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Outubro/2011                        Ultima atualizacao: 13/01/2016
   
   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Exclusao transacoes pendentes dos operadores de internet
   
   Alteracoes: 13/01/2016 - Alteracoes para o projeto de Assinatura Conjunta
                            Prj. 131 (Jean Michel).
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdoperad AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nmdatela AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_cdditens AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_nrcpfope AS DECIMAL     NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR               NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dscritic AS CHAR                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                        NO-UNDO.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_exclui_trans_pend
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper, /* Codigo Cooperativa         */
                                            INPUT par_nrdconta, /* Conta do Associado         */
                                            INPUT par_nrdcaixa, /* Numero do caixa            */  
                                            INPUT par_cdagenci, /* Numero da agencia          */
                                            INPUT par_cdoperad, /* Numero do operador         */
                                            INPUT par_dtmvtolt, /* Data da operacao           */
                                            INPUT par_idorigem, /* Codigo Origem              */
                                            INPUT par_nmdatela, /* Nome da tela               */
                                            INPUT par_cdditens, /* Itens                      */
                                            INPUT par_nrcpfope, /* CPF do operador            */
                                            INPUT 1,            /* Flag de log - Default TRUE */
                                           OUTPUT 0,            /* Codigo do erro             */
                                           OUTPUT "").          /* Descricao do erro          */
    
    CLOSE STORED-PROC pc_exclui_trans_pend 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_exclui_trans_pend.pr_cdcritic 
                            WHEN pc_exclui_trans_pend.pr_cdcritic <> ?
           aux_dscritic = pc_exclui_trans_pend.pr_dscritic
                            WHEN pc_exclui_trans_pend.pr_dscritic <> ?. 
    
    IF aux_cdcritic <> 0   OR
       aux_dscritic <> ""  THEN
       DO:
          IF aux_dscritic = "" THEN
             DO:
                FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
                
                IF AVAIL crapcri THEN
                   ASSIGN aux_dscritic = crapcri.dscritic.
                ELSE
                   ASSIGN aux_dscritic =  "Nao foi possivel realizar a operacao.".
             END.
    
          ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
    
          RETURN "NOK".
    
       END.

    ASSIGN aux_dscritic = "Transacoes excluidas com sucesso.".

    xml_dsmsgerr = "<dsmsgsuc>" + aux_dscritic + "</dsmsgsuc>".

    RETURN "OK".
/*............................................................................*/
