/* .............................................................................
   Programa: Fontes/critica_nome.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete 
   Data    : Novembro/2004                   Ultima Atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : So permitir letras em campos com nomes.

   Parametros
   ==========

   ENTRADA: par_nmdentra: string com o texto a criticar

   SAIDA    glb_cdcritic: codigo do erro encontrado.

   Alteracoes: 
............................................................................. */

DEF INPUT  PARAMETER par_nmdentra AS CHAR  NO-UNDO.

DEF OUTPUT PARAMETER par_cdcritic AS INTE  NO-UNDO.

DEF VAR aux_contador AS INT                NO-UNDO.
DEF var aux_nmabrevi AS CHAR               NO-UNDO.
DEF VAR aux_qtletini AS INTE               NO-UNDO.

ASSIGN aux_nmabrevi = TRIM(par_nmdentra)
       aux_qtletini = LENGTH(aux_nmabrevi)
       par_cdcritic = 0.

DO  aux_contador = 1 TO LENGTH(aux_nmabrevi):

    IF   SUBSTR(aux_nmabrevi,aux_contador,1) <> ""    AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "A"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "B"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "C"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "D"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "E"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "F"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "G"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "H"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "I"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "J"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "K"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "L"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "M"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "N"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "O"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "P"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "Q"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "R"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "S"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "T"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "U"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "V"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "X"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "W"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "Y"   AND
         SUBSTR(aux_nmabrevi,aux_contador,1) <> "Z"   THEN
         DO:
             par_cdcritic = 835.
             LEAVE.
         END.
END.
             
/* .......................................................................... */
