/*..............................................................................

    Programa: b1wgen0047tt.i
    Autor   : David
    Data    : Novembro/2009                   Ultima atualizacao: 00/00/0000   

    Objetivo  : 

    Alteracoes: 
   
..............................................................................*/


DEF TEMP-TABLE tt-dependente NO-UNDO
    FIELD nmdepend LIKE crapdep.nmdepend
    FIELD dtnascto LIKE crapdep.dtnascto
    FIELD cdtipdep LIKE crapdep.tpdepend
    FIELD dstipdep AS CHAR FORMAT "x(15)"
    FIELD nrdrowid AS ROWID.

DEF TEMP-TABLE tt-tipos-dependente NO-UNDO
    FIELD cdtipdep AS INTE
    FIELD dstipdep AS CHAR.


/*............................................................................*/
