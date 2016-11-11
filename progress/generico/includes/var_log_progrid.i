/* ..........................................................................

   Programa: sistema/generico/includes/var_log_progrid.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jean Michel
   Data    : Outubro/2016.                      Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada (On-line)
   Objetivo  : Execucao de Store Procedure Oracle para gravar informacoes de log do
							 sistema PROGRID.

   Alteracoes:
               
............................................................................. */
{ includes/var_progrid.i }
{ sistema/generico/includes/var_oracle.i }

PROCEDURE insere_log_progrid:
	DEF INPUT PARAM nmprogra AS CHAR NO-UNDO.
  DEF INPUT PARAM nmparame AS CHAR NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_informa_acesso_progrid
		aux_handpro2 = PROC-HANDLE NO-ERROR (nmprogra,nmparame).

CLOSE STORED-PROCEDURE pc_informa_acesso_progrid
			WHERE PROC-HANDLE = aux_handpro2.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

END PROCEDURE.