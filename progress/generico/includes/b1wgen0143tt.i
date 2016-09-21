/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0143tt.i
    Autor(a): Gabriel Capoia (DB1)
    Data    : 07/12/2012                      Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0143.
  
    Alteracoes: 
    
.............................................................................*/ 

DEFINE TEMP-TABLE cratneg NO-UNDO 
    FIELD nrseqdig AS INTE FORMAT "zz,zz9"  
    FIELD dtiniest AS DATE FORMAT "99/99/9999"
    FIELD cdbanchq AS DECI FORMAT "z,zz9"    
    FIELD nrctachq AS DECI FORMAT "zzzz,zzz,9"
    FIELD cdobserv AS INTE FORMAT "zzz9"
    FIELD nrdocmto AS DECI FORMAT "zz,zzz,zz9"
    FIELD vlestour AS DECI FORMAT "zzz,zzz,zzz,zz9"
    FIELD dtfimest AS DATE FORMAT "99/99/9999"
    FIELD nmoperad AS CHAR FORMAT "x(11)"
    FIELD flgselec AS LOGI FORMAT "*/ "
    FIELD flgctitg AS INTE FORMAT "9"
    FIELD idseqttl AS INTE FORMAT "9"
    INDEX cratneg1 AS UNIQUE PRIMARY nrseqdig  DESC.

DEFINE TEMP-TABLE cratttl NO-UNDO 
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD nmextttl LIKE crapttl.nmextttl.        

DEFINE TEMP-TABLE tt-nmarqimp NO-UNDO 
    FIELD nmarqimp AS CHAR.
    

DEFINE TEMP-TABLE tt-crapneg NO-UNDO
    FIELD nrdconta LIKE crapneg.nrdconta
    FIELD cdbanchq LIKE crapneg.cdbanchq
    FIELD cdagechq LIKE crapneg.cdagechq
    FIELD nrdocmto LIKE crapneg.nrdocmto
    FIELD nrctachq LIKE crapneg.nrctachq
    FIELD vlestour LIKE crapneg.vlestour
    FIELD idseqttl LIKE crapneg.idseqttl
    FIELD nrdctabb LIKE crapneg.nrdctabb. 
