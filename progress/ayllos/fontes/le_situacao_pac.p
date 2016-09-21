/*.............................................................................

   Programa: fontes/le_situacao_pac.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Agosto/2005                           Ultima alteracao:   /  /    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Le cadastro de situacao de pac.

   Alteracoes: 

............................................................................. */

DEF INPUT  PARAM par_insitage AS INT                             NO-UNDO.
DEF OUTPUT PARAM par_dssitage AS CHAR                            NO-UNDO.

IF   par_insitage = 0   THEN
     par_dssitage = "EM OBRAS".
ELSE
IF   par_insitage = 1   THEN
     par_dssitage = "ATIVO".
ELSE
IF   par_insitage = 2   THEN
     par_dssitage = "INATIVO".
ELSE
     par_dssitage = "NAO CAD".
 
/* .......................................................................... */

