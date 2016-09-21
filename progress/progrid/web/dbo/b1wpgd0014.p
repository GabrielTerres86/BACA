/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0014.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Evandro
   Data    : Outubro/2005                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Incremento/Decremento do status da agenda
............................................................................ */
&SCOPED-DEFINE tabela   crapagp

PROCEDURE incrementa-status:
    DEFINE INPUT  PARAMETER aux_nrdrowid AS ROWID                NO-UNDO.
    DEFINE OUTPUT PARAMETER m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.

    /* Busca a tabela e incrementa o status */
    FIND {&tabela} WHERE ROWID({&tabela}) = aux_nrdrowid EXCLUSIVE-LOCK NO-ERROR.

    IF   NOT AVAILABLE {&tabela}   THEN
         DO:
            ASSIGN m-erros = m-erros + "Tabela de Status da Agenda não encontrada".
            RETURN "NOK".
         END.
          
    ASSIGN {&tabela}.idstagen = {&tabela}.idstagen + 1.

    RETURN "OK".

END PROCEDURE.


PROCEDURE decrementa-status:
    DEFINE INPUT  PARAMETER aux_nrdrowid AS ROWID                NO-UNDO.
    DEFINE OUTPUT PARAMETER m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.    

    /* Busca a tabela e incrementa o status */
    FIND {&tabela} WHERE ROWID({&tabela}) = aux_nrdrowid EXCLUSIVE-LOCK NO-ERROR.

    IF   NOT AVAILABLE {&tabela}   THEN
         DO:
            ASSIGN m-erros = m-erros + "Tabela de Status da Agenda não encontrada".
            RETURN "NOK".
         END.
          
    ASSIGN {&tabela}.idstagen = {&tabela}.idstagen - 1.

    RETURN "OK".

END PROCEDURE.
