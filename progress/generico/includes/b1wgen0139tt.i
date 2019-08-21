/*..............................................................................

    Programa: b1wgen0139tt.i                  
    Autor   : Tiago
    Data    : Julho/2012                       Ultima atualizacao: 25/06/2013

    Dados referentes ao programa:

    Objetivo  : Temp-tables utlizadas na BO b1wgen0139.p 

    Alteracoes: 25/06/2013 - Adicionados os campos mrgitgcr e mrgitgdb (Reinert)
    
..............................................................................*/


DEF TEMP-TABLE tt-fluxo-fin                                             NO-UNDO
    FIELD mrgsrdoc AS DECIMAL 
    FIELD mrgsrchq AS DECIMAL
    FIELD mrgnrtit AS DECIMAL
    FIELD mrgsrtit AS DECIMAL
    FIELD caldevch AS DECIMAL
    FIELD mrgitgcr AS DECIMAL
    FIELD mrgitgdb AS DECIMAL
    FIELD horabloq AS CHARACTER.
