/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/posant.i - Vers�o WebSpeed 2.1
  Autor: B&T/Solusoft
 Fun��o: Posiciona o ponteiro de registro no registro anterior ao informado 
         pela variavel ponteiro. Seta as variaveis ponteiro e statuspos. 
         Utiliza o pre-processor &FIRST-ENABLE-TABLE para encontrar a tabela 
         com a qual deve trabahar.
-------------------------------------------------------------------------------*/

FIND {&FIRST-ENABLED-TABLE} WHERE 
     ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
IF AVAILABLE {&FIRST-ENABLED-TABLE} THEN DO:
   FIND PREV {&FIRST-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
   IF AVAILABLE {&FIRST-ENABLED-TABLE} THEN DO:
      ASSIGN ponteiro = STRING(ROWID({&FIRST-ENABLED-TABLE})).
      FIND PREV {&FIRST-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
      IF AVAILABLE {&FIRST-ENABLED-TABLE} THEN 
         ASSIGN statuspos = "".
      ELSE
         ASSIGN statuspos = "".
      FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
   END.
   ELSE DO:
      RUN RodaJavaScript("alert('Este j� � o primeiro registro.')"). 
      FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
      IF AVAILABLE {&FIRST-ENABLED-TABLE} THEN
         ASSIGN statuspos = "".
      ELSE
         ASSIGN statuspos = "?".
   END.
END.
ELSE 
   RUN PosicionaNoPrimeiro.
