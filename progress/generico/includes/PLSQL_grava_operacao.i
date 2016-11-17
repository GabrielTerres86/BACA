/* ............................................................................

   Programa: Includes/PLSQL_grava_operacao.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Marco/2014                        Ultima atualizacao: 19/05/2014

   Dados referentes ao programa:
   Objetivo: Gravar operador e nome da tela que esta utilizando na sessao
   
   Alteracoes: 19/05/2014 - Alterar a chamada da session no Oracle. (James)
............................................................................ */
DO TRANSACTION: /* Inicio da transacao */

    RUN STORED-PROCEDURE {&dboraayl}.send-sql-statement
        aux_handpro2 = PROC-HANDLE NO-ERROR
    ("BEGIN " +
     "DBMS_APPLICATION_INFO.SET_MODULE('" + STRING(glb_cdcooper) + 
                                        " | " + glb_cdoperad + 
                                        " | " + glb_nmdatela + "','');" +
     "END;").   
    
    CLOSE STORED-PROCEDURE {&dboraayl}.send-sql-statement
          WHERE PROC-HANDLE = aux_handpro2.

END.
