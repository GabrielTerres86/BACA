/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank200.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Daniel Zimmermann, Paulo Penteado (GFT)
   Data    : Junho/2018
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Gera token para transacoes.
   
   Alteracoes: 26/06/2018 Criação
 
..............................................................................*/
    
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF  INPUT PARAM par_cdcooper LIKE crapttl.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr  AS CHAR                                 NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dstoken   AS CHAR                                          NO-UNDO.
DEF VAR aux_dscritic  AS CHAR                                          NO-UNDO.
DEF VAR xml_ret       AS CHAR 									       NO-UNDO.

 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
 
 RUN STORED-PROCEDURE pc_cria_autenticacao_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_nrcpfope,
						              OUTPUT "",
                          OUTPUT "").

    CLOSE STORED-PROC pc_cria_autenticacao_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.
		  
{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
ASSIGN aux_dstoken  = ""
       aux_dscritic = ""
       aux_dstoken  = pc_cria_autenticacao_ib.pr_tokenib
                      WHEN pc_cria_autenticacao_ib.pr_tokenib <> ?
       aux_dscritic = pc_cria_autenticacao_ib.pr_dscritic
                      WHEN pc_cria_autenticacao_ib.pr_dscritic <> ?.

IF aux_dscritic <> "" THEN
DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    RETURN "NOK".
END.

/***** Inicio - Carregamento do XML *****/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<dstoken>" + TRIM(aux_dstoken) + "</dstoken>".


/***** FIM - Carregamento do XML *****/

RETURN "OK".