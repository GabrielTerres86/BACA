/* ............................................................................

   Programa: sistema/generico/includes/PLSQL_grava_operacao_InternetBank.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2014                        Ultima atualizacao: 19/05/2014

   Dados referentes ao programa:
   Objetivo: Gravar conta e cartao que esta executando a operacao
   
   Alteracoes: 19/05/2014 - Alterar a chamada da session no Oracle. (James)

			   02/08/2016 - Efetuar chamada de procedure no Oracle para evitar
			                que os cursores fiquem abertos. (Rodrigo)
............................................................................ */

DO TRANSACTION: /* Inicio da transacao */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE {&dboraayl}.pc_informa_acesso
	aux_handpro2 = PROC-HANDLE NO-ERROR (STRING(aux_cdcooper) + "|" +
                                         STRING(aux_nrdconta) + "|" +
                                         STRING(aux_idseqttl) + "|" +
										 STRING(aux_nrcpfope) + "|" +
										 STRING(aux_nripuser) + "|" +
										 STRING(aux_flmobile)
									   , STRING(aux_operacao)).
	
	CLOSE STORED-PROC {&dboraayl}.pc_informa_acesso
	    WHERE PROC-HANDLE = aux_handpro2.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
END.