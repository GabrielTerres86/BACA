
/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0117tt.i
    Autor   : Adriano
    Data    : Outubro/2011               Ultima Atualizacao: 21/02/2013
     
    Dados referentes ao programa:
   
    Objetivo  : Includes referente a BO b1wgen0117.
                 
    Alteracoes: 21/02/2013 - Ajuste para utilizar a tabela crapcrt e incluido 
                            a temp-table tt-vinculo (Adriano).

.............................................................................*/

DEF TEMP-TABLE tt-crapcrt NO-UNDO 
    FIElD nrcpfcgc AS CHAR
    FIElD nrregres LIKE crapcrt.nrregres   
    FIElD cdsitreg LIKE crapcrt.cdsitreg   
    FIElD nmpessoa LIKE crapcrt.nmpessoa   
    FIElD cdcopsol LIKE crapcrt.cdcopsol   
    FIElD nmpessol LIKE crapcrt.nmpessol   
    FIElD cdbccxlt LIKE crapcrt.cdbccxlt   
    FIElD dtinclus LIKE crapcrt.dtinclus   
    FIElD hrinclus AS CHAR
    FIElD dsjusinc LIKE crapcrt.dsjusinc   
    FIElD cdcopinc LIKE crapcrt.cdcopinc   
    FIELD cdopeinc LIKE crapcrt.cdopeinc
    FIElD cdcopexc LIKE crapcrt.cdcopexc   
    FIElD cdopeexc LIKE crapcrt.cdopeexc   
    FIElD dsjusexc LIKE crapcrt.dsjusexc   
    FIElD dtexclus LIKE crapcrt.dtexclus   
    FIElD hrexclus AS CHAR
    FIElD tporigem LIKE crapcrt.tporigem
    FIELD nmcopsol AS CHAR                             
    FIELD nmcopinc AS CHAR   
    FIELD nmopeinc AS CHAR  
    FIELD nmcopexc AS CHAR 
    FIELD nmopeexc AS CHAR
    FIELD nmextbcc AS CHAR.                                      
    

DEF TEMP-TABLE tt-vinculo NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrctavin LIKE crapass.nrdconta
    FIELD nmctavin LIKE crapass.nmprimtl
    FIELD nrcpfvin AS CHAR
    FIELD tpdovinc AS CHAR.



/*............................................................................*/

