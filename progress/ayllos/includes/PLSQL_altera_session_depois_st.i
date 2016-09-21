/* ............................................................................

   Programa: Includes/PLSQL_altera_session_depois_st.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rafael Cechet/CECRED
   Data    : Abril/2014                        Ultima atualizacao:

   Dados referentes ao programa:
   Objetivo: Include necessaria depois de executar uma STORED PROCEDURE
             do banco de dados Oracle (st = SEM TRANSACTION).
   
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
