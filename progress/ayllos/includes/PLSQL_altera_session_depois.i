/* ............................................................................

   Programa: Includes/PLSQL_altera_session_depois.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André Santos/Supero
   Data    : Agosto/2012                        Ultima atualizacao:

   Dados referentes ao programa:
   Objetivo: Include necessaria no processo batch hibrido (PLSQL).
   
   Alteracoes:
   
............................................................................ */

RUN STORED-PROCEDURE {&dboraayl}.send-sql-statement
    aux_handpro2 = PROC-HANDLE NO-ERROR
                   ("ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,'").

CLOSE STORED-PROCEDURE {&dboraayl}.send-sql-statement
      WHERE PROC-HANDLE = aux_handpro2.

RUN STORED-PROCEDURE {&dboraayl}.send-sql-statement
    aux_handpro2 = PROC-HANDLE NO-ERROR
                   ("ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY'").

CLOSE STORED-PROCEDURE {&dboraayl}.send-sql-statement
      WHERE PROC-HANDLE = aux_handpro2.

END. /* Fim da transacao */
