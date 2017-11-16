/*..............................................................................

    Programa: sistema/generico/includes/b1wgen0078tt.i                  
    Autor   : David
    Data    : Marco/2011                      Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0078.p

   Alteracoes: 
                            
..............................................................................*/


DEF TEMP-TABLE tt-logdda NO-UNDO
    FIELD idseqlog AS INTE
    FIELD dttransa AS DATE
    FIELD hrtransa AS CHAR
    FIELD hrtraint AS INTE
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD dscpfcgc AS CHAR
    FIELD nmmetodo AS CHAR
    FIELD cdderror AS CHAR
    FIELD dsderror AS CHAR
    FIELD dsreserr AS CHAR
    INDEX tt-log-dda1 dttransa hrtransa.

DEF TEMP-TABLE tt-sacado-eletronico NO-UNDO 
    FIELD flgativo AS LOGI FORMAT "SIM/NAO"
    FIELD cdsituac AS INTE
    FIELD dtsituac AS DATE FORMAT "99/99/9999"
    FIELD dtadesao AS DATE FORMAT "99/99/9999"
    FIELD qtadesao AS INTE
    FIELD dtexclus AS DATE FORMAT "99/99/9999"
    FIELD dssituac AS CHAR FORMAT "x(44)"
    FIELD nrcpfcgc AS DECI
    FIELD dscpfcgc AS CHAR FORMAT "x(21)"
    FIELD inpessoa AS INTE
    FIELD dspessoa AS CHAR FORMAT "x(15)"
    FIELD nmextttl AS CHAR FORMAT "x(50)"
    FIELD btnconsu AS LOGI 
    FIELD btnaderi AS LOGI
    FIELD btnexclu AS LOGI
    FIELD flsacpro AS LOGI FORMAT "SIM/NAO". 

DEF TEMP-TABLE tt-crapcop NO-UNDO LIKE crapcop.

DEF TEMP-TABLE tt-testemunha NO-UNDO
    FIELD nrcpfcgc AS DECI
    FIELD nmdteste AS CHAR.

/*............................................................................*/

