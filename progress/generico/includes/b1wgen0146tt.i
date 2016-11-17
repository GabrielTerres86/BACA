/*.............................................................................

   Programa: b1wgen0146tt.i                 
   Autor   : David Kruger
   Data    : Janeiro/2013                        Ultima atualizacao: 

   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0146.p - NOTJUS

   Alteracoes: 
   
.............................................................................*/


DEF TEMP-TABLE tt-estouro                               NO-UNDO
    FIELD nrseqdig LIKE crapneg.nrseqdig
    FIELD dtiniest LIKE crapneg.dtiniest
    FIELD qtdiaest LIKE crapneg.qtdiaest
    FIELD dshisest AS CHAR
    FIELD vlestour LIKE crapneg.vlestour
    FIELD dsobserv AS CHAR.


