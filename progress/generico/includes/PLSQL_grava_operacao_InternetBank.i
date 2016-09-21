/* ............................................................................

   Programa: sistema/generico/includes/PLSQL_grava_TAA.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2014                        Ultima atualizacao: 19/05/2014

   Dados referentes ao programa:
   Objetivo: Gravar conta e cartao que esta executando a operacao
   
   Alteracoes: 19/05/2014 - Alterar a chamada da session no Oracle. (James)
............................................................................ */

DO TRANSACTION: /* Inicio da transacao */

    RUN STORED-PROCEDURE {&dboraayl}.send-sql-statement
        aux_handpro2 = PROC-HANDLE NO-ERROR
        ("BEGIN " +
         "DBMS_APPLICATION_INFO.SET_MODULE('" + STRING(aux_cdcooper) + " | " +
                                                STRING(aux_nrdconta) + " | " +
                                                STRING(aux_idseqttl) + " | " +
                                                STRING(aux_operacao) + "','');" +
         "END;").
     
    CLOSE STORED-PROCEDURE {&dboraayl}.send-sql-statement
          WHERE PROC-HANDLE = aux_handpro2.

END.
