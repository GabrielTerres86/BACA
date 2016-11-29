/* ..........................................................................

   Programa: sistema/generico/includes/var_log_progrid.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jean Michel
   Data    : Outubro/2016.                      Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada (On-line)
   Objetivo  : Execucao de Store Procedure Oracle para gravar informacoes
			   de log do sistema PROGRID.

   Alteracoes:

............................................................................. */

{ includes/var_progrid.i }
{ sistema/generico/includes/var_oracle.i }

PROCEDURE insere_log_progrid:
  DEF INPUT PARAM par_nmprogra AS CHAR NO-UNDO.
  DEF INPUT PARAM par_nmparame AS CHAR NO-UNDO.

  { sistema/ayllos/includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

  RUN STORED-PROCEDURE pc_informa_acesso_progrid
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_nmprogra
                         ,INPUT par_nmparame).

  CLOSE STORED-PROC pc_informa_acesso_progrid
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

  { sistema/ayllos/includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
END PROCEDURE.