/*.............................................................................

    Programa: b1wgen0075tt.i
    Autor   : Odirlei Busana - AMcom
    Data    : Outubro/2017                   Ultima atualizacao: 
    
    Objetivo  : Definicao das Temp-Tables, CADCTA

    Alteracoes: 

.............................................................................*/



/*...........................................................................*/

/*&IF DEFINED(TT-LOG) <> 0 &THEN*/
    DEFINE TEMP-TABLE tt-dados-ant NO-UNDO 
        FIELD cdbcochq AS INTE
        FIELD cdconsul AS INTE
        FIELD cdagedbb AS INTE
        FIELD nrdctitg AS CHAR  
        FIELD nrctacns AS DEC 
        FIELD incadpos AS INTE
        FIELD flgiddep AS LOGICAL
        FIELD flgrestr AS LOGICAL
        FIELD indserma AS LOGICAL
        FIELD inlbacen AS INT
        FIELD nmtalttl AS CHAR
        FIELD qtfoltal AS INTE
        FIELD cdempres AS INTE
        FIELD nrinfcad AS INTE
        FIELD nrpatlvr AS INTE
        FIELD dsinfadi AS CHAR
        FIELD nmctajur AS CHAR.

    DEFINE TEMP-TABLE tt-dados-atl NO-UNDO LIKE tt-dados-ant.
/*&ENDIF*/