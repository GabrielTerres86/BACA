/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0094tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : Junho/2011                        Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0094.
  
    Alteracoes: 
    
.............................................................................*/

DEF TEMP-TABLE tt-infoass NO-UNDO 
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl.

DEF TEMP-TABLE tt-chequedc NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcheque LIKE crapcst.nrcheque
    FIELD nrborder LIKE crapcdb.nrborder
    FIELD dtlibera LIKE crapcdb.dtlibera
    FIELD cdpesqui AS CHAR  FORMAT "x(50)"
    FIELD tpcheque AS CHAR  FORMAT "x(1)".

DEF TEMP-TABLE tt-criticas NO-UNDO
    FIELD cdbanchq AS INTE  FORMAT "z,zz9"
    FIELD cdagechq AS INTE  FORMAT "z,zz9"
    FIELD nrctachq AS DECI  FORMAT "zzzz,zzz,9"
    FIELD nrcheque AS INTE  FORMAT "zzz,zzz,9"
    FIELD cdcritic AS INTE  FORMAT "z,zz9"
    FIELD dscritic AS CHAR  FORMAT "x(65)".

DEF TEMP-TABLE tt-cheques  NO-UNDO
    FIELD cdbanchq LIKE crapfdc.cdbanchq
    FIELD cdagechq LIKE crapfdc.cdagechq
    FIELD nrctachq AS DECI  FORMAT "zzzz,zzz,9"
    FIELD nrcheque AS INTE  FORMAT "zzz,zzz,9".
