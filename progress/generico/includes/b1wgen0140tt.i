/*..............................................................................

    Programa: b1wgen0140tt.i                  
    Autor   : Tiago
    Data    : Setembro/2012                      Ultima atualizacao: 07/01/2014

    Dados referentes ao programa:

    Objetivo  : Temp-tables utlizadas na BO b1wgen0140.p e no fonte procap.p 

    Alteracoes: 07/01/2014 - Inserido campo cdageass na tt-craplct (Tiago).
..............................................................................*/

DEF TEMP-TABLE tt-craplct LIKE craplct
    FIELD dsdesblq    AS    CHARACTER
    FIELD dtdsaque    AS    DATE
    FIELD nmprimtl    LIKE  crapass.nmprimtl
    FIELD cdtpdata    AS    INTE
    FIELD totinteg    AS    DECI
    FIELD cdageass    LIKE  craplct.cdagenci.

    
