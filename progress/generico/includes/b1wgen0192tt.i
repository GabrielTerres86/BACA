/*.............................................................................

   Programa: b1wgen0192tt.i                  
   Autor   : Andre Santos - SUPERO
   Data    : Setembro/2014                       Ultima atualizacao: / /

   Dados referentes ao programa:

   Objetivo  : Definicoes e criacao de temp-table referente a BO b1wgen0192.p

   Alteracoes:

.............................................................................*/

DEF TEMP-TABLE tt-arquivos NO-UNDO
    FIELD nrconven   AS INTE
    FIELD dtdadesa   AS DATE
    FIELD cdoperad   AS CHAR
    FIELD flgativo   AS CHAR
    FIELD dsorigem   AS CHAR.
