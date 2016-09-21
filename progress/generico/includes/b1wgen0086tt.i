/* ............................................................................
  
   Programa: b1wgen0086tt.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Fevereiro/2011                  Ultima Atualizacao:
   
   Dados referentes ao programa:
   
   Objetivo  : Definir as variaveis/temp-tables da b1wgen0086.p

   Alteracoes:
                                                                             
.............................................................................*/

DEF TEMP-TABLE tt-crapreg NO-UNDO LIKE crapreg 
     FIELD nmoperad LIKE crapope.nmoperad
     FIELD dsoperad AS   CHAR 
     FIELD cddsregi AS   CHAR.

DEF TEMP-TABLE tt-crapope NO-UNDO LIKE crapope.









/* ..........................................................................*/
