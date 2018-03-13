/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/posseg.i - Versão WebSpeed 2.1
  Autor: B&T/Solusoft
 Função: Posiciona o ponteiro de registro no registro seguinte ao informado pela 
         variavel ponteiro. Seta as variaveis ponteiro e statuspos. Utiliza o 
         pre-processor &FIRST-ENABLE-TABLE p/ encontrar a tabela com a qual deve trabahar.
-------------------------------------------------------------------------------*/

FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
IF AVAILABLE {&FIRST-ENABLED-TABLE} THEN DO:
   FIND NEXT {&FIRST-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
   IF AVAILABLE {&FIRST-ENABLED-TABLE} THEN DO:
      ASSIGN ponteiro = STRING(ROWID({&FIRST-ENABLED-TABLE})).
      FIND NEXT {&FIRST-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
      IF AVAILABLE {&FIRST-ENABLED-TABLE} THEN
         ASSIGN statuspos = "".
      ELSE
         ASSIGN statuspos = "".
      FIND {&FIRST-ENABLED-TABLE} WHERE 
           ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
   END.
   ELSE DO:
      RUN RodaJavaScript("alert('Este já é o último registro.')").
      FIND {&FIRST-ENABLED-TABLE} WHERE 
           ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
      IF AVAILABLE {&FIRST-ENABLED-TABLE} THEN
         ASSIGN statuspos = "".
      ELSE
         ASSIGN statuspos = "?".
   END.
END.
ELSE
   RUN PosicionaNoUltimo.
