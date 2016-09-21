/* ............................................................................

   Programa: sistema/generico/includes/PLSQL_grava_operacao_AyllosWeb.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2014                        Ultima atualizacao: 02/08/2016

   Dados referentes ao programa:
   Objetivo: Gravar dados de execucao da requisicao
   
   Alteracoes: 16/05/2014 - Alterar a chamada da session no Oracle. (James)

			   02/08/2016 - Efetuar chamada de procedure no Oracle para evitar
			                que os cursores fiquem abertos. (Rodrigo)
............................................................................ */
DO TRANSACTION: /* Inicio da transacao */

	{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE {&dboraayl}.pc_informa_acesso
        aux_handpro2 = PROC-HANDLE NO-ERROR (STRING(aux_cdcooper) +
                                             (
											  IF AVAIL tt-permis-acesso THEN
                                                 "|" + tt-permis-acesso.cdopecxa + 
												 "|" + tt-permis-acesso.nmdatela + 
												 "|" + tt-permis-acesso.nmrotina + 
												 "|" + tt-permis-acesso.cddopcao
                                              ELSE
                                                 "")
											,cNomeBO + "-" +
                                             cProcedure).

    CLOSE STORED-PROCEDURE {&dboraayl}.pc_informa_acesso
          WHERE PROC-HANDLE = aux_handpro2.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
END.
