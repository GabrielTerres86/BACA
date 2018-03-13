/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/pospri.i - Versão WebSpeed 2.1
  Autor: B&T/Solusoft
 Função: Posiciona no primeiro registro da tabela. Seta as variaveis ponteiro e 
             statuspos. Utiliza o pre-processor &FIRST-ENABLE-TABLE p/ encontrar
             a tabela com a qual deve trabahar.
-------------------------------------------------------------------------------*/

FIND FIRST {&FIRST-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
IF NOT AVAILABLE {&FIRST-ENABLED-TABLE} THEN
   ASSIGN ponteiro = "?"
          statuspos = "".
ELSE
   ASSIGN ponteiro = STRING(ROWID({&FIRST-ENABLED-TABLE}))
          statuspos = "".  /* aqui p */
