/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/posult.i - Versão WebSpeed 2.1
  Autor: B&T/Solusoft
 Função: Posiciona no ultimo registro da tabela. Seta as variaveis ponteiro e 
             statuspos. Utiliza o pre-processor &FIRST-ENABLE-TABLE para encontrar 
             a tabela com a qual deve trabahar.
-------------------------------------------------------------------------------*/

FIND LAST {&FIRST-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
IF NOT AVAILABLE {&FIRST-ENABLED-TABLE} THEN
   ASSIGN ponteiro = "?".
ELSE
   ASSIGN ponteiro = STRING(ROWID({&FIRST-ENABLED-TABLE}))
          statuspos = "".   /* aqui u */
