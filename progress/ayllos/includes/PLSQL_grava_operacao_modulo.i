/* ............................................................................

   Programa: Includes/PLSQL_grava_operacao_modulo.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Maio/2014                        Ultima atualizacao:

   Dados referentes ao programa:
   Objetivo: Gravar no modulo o que esta sendo executado no momento
   
   Alteracoes:
   
............................................................................ */


DO TRANSACTION: /* Inicio da transacao */

RUN STORED-PROCEDURE {&dboraayl}.send-sql-statement
    aux_handpro2 = PROC-HANDLE NO-ERROR
("BEGIN " +
 "DBMS_APPLICATION_INFO.SET_MODULE('" + glb_cdprogra + "','');" +
 "END;").   

CLOSE STORED-PROCEDURE {&dboraayl}.send-sql-statement
      WHERE PROC-HANDLE = aux_handpro2.

END.
