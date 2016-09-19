/*..............................................................................

    Programa: b1wgen0183tt.i                  
    Autor   : Tiago
    Data    : Fevereiro/2014                     Ultima atualizacao: 

    Dados referentes ao programa:

    Objetivo  : Temp-tables utlizadas na BO b1wgen0183.p 

    Alteracoes: 
    
..............................................................................*/


DEF TEMP-TABLE tt-craphec   LIKE craphec.

DEF TEMP-TABLE tt-processos                                            NO-UNDO
    FIELD nmproces  AS  CHAR
    FIELD hrageini  AS  CHAR
    FIELD hragefim  AS  CHAR
    FIELD ageinihr  AS  INTE
    FIELD ageinimm  AS  INTE
    FIELD agefimhr  AS  INTE
    FIELD agefimmm  AS  INTE
    FIELD nrseqexe  AS  INTE
    FIELD flgativo  AS  LOGICAL.

DEF TEMP-TABLE tt-coop                                                  NO-UNDO
    FIELD cdcooper  AS  INTE
    FIELD nmrescop  AS  CHAR.
