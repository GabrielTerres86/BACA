/* ............................................................................

   Programa: sistema/generico/includes/PLSQL_grava_operacao_AyllosWeb.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2014                        Ultima atualizacao:

   Dados referentes ao programa:
   Objetivo: Gravar dados de execucao da requisicao
   
   Alteracoes:
   
............................................................................ */

DO TRANSACTION: /* Inicio da transacao */

    RUN STORED-PROCEDURE {&dboraayl}.send-sql-statement
        aux_handpro2 = PROC-HANDLE NO-ERROR
       ("BEGIN " +
            "DBMS_SESSION.SET_IDENTIFIER('" + STRING(aux_cdcooper) + " | " +
                                              cNomeBO + "|" +
                                              cProcedure +
                                        (IF AVAIL tt-permis-acesso THEN
                                            " | " +
                                            tt-permis-acesso.cdopecxa + " | " +
                                            tt-permis-acesso.nmdatela + " | " +
                                            tt-permis-acesso.nmrotina + " | " +
                                            tt-permis-acesso.cddopcao
                                         ELSE
                                            "") +    
                                          "');" + "END;").
     
    CLOSE STORED-PROCEDURE {&dboraayl}.send-sql-statement
          WHERE PROC-HANDLE = aux_handpro2.

END.
