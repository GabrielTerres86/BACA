/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank192.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andrey
   Data    : Junho/2017                     Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Carregar mensagens para os prepostos aprovarem.
   
   Alteracoes: 
 
..............................................................................*/

    
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF VAR aux_cdcritic AS INT                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                       NO-UNDO.
DEF VAR xml_req      AS CHAR 									   NO-UNDO.

DEF  INPUT PARAM cdcooper LIKE crapopi.cdcooper                    NO-UNDO.
DEF  INPUT PARAM nrdconta LIKE crapopi.nrdconta                    NO-UNDO.
DEF  INPUT PARAM nrcpfpre LIKE crapopi.nrcpfope					   NO-UNDO.
DEF  INPUT PARAM nrcpfope AS CHAR					  			   NO-UNDO.
DEF  INPUT PARAM iddopcao AS INTE					   			   NO-UNDO.

DEF OUTPUT PARAM dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

IF iddopcao = 2 THEN
	DO:
		{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
		 RUN STORED-PROCEDURE pc_retorna_mensagem_preposto aux_handproc = PROC-HANDLE NO-ERROR
								 (INPUT cdcooper,
								  INPUT nrdconta,
								  INPUT nrcpfpre,
								  OUTPUT "").

			CLOSE STORED-PROC pc_retorna_mensagem_preposto aux_statproc = PROC-STATUS
				  WHERE PROC-HANDLE = aux_handproc.
				  
			ASSIGN xml_req = pc_retorna_mensagem_preposto.xml_operador.

		{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

		ASSIGN dsmsgerr = "".
			
		CREATE xml_operacao.
		ASSIGN xml_operacao.dslinxml = xml_req.

		RETURN "OK".
	END.
ELSE
	DO:
		{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
		 RUN STORED-PROCEDURE pc_confirma_operacao_preposto aux_handproc = PROC-HANDLE NO-ERROR
								 (INPUT cdcooper,
								  INPUT nrdconta,
								  INPUT nrcpfpre,
								  INPUT nrcpfope,
								  OUTPUT "").

			CLOSE STORED-PROC pc_confirma_operacao_preposto aux_statproc = PROC-STATUS
				  WHERE PROC-HANDLE = aux_handproc.
				  
			ASSIGN xml_req = pc_confirma_operacao_preposto.xml_operador.

		{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

		ASSIGN dsmsgerr = "".
			
		CREATE xml_operacao.
		ASSIGN xml_operacao.dslinxml = xml_req.

		RETURN "OK".
	END.
/*............................................................................*/
