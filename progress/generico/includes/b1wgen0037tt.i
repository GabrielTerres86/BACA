/*..............................................................................

    Programa: b1wgen0037tt.i                  
    Autor   : David
    Data    : Janeiro/2009                    Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0037.p

   Alteracoes: 
                            
..............................................................................*/


DEF TEMP-TABLE tt-informativos                                         NO-UNDO
    FIELD cdprogra AS INTE 
    FIELD cdrelato AS INTE 
    FIELD nmrelato AS CHAR 
    FIELD dsrelato AS CHAR
    FIELD cdgrprel AS INTE
    FIELD cdfenvio AS INTE 
    FIELD cdperiod AS INTE 
    FIELD grupoinf AS CHAR 
    FIELD dsrecebe AS CHAR 
    FIELD dsfenvio AS CHAR 
    FIELD dsperiod AS CHAR 
    FIELD endcoope AS CHAR 
    FIELD nrdrowid AS ROWID. 
                                          
DEF TEMP-TABLE tt-historico                                             NO-UNDO
    FIELD dttransa AS DATE
    FIELD dstransa AS CHAR
    FIELD dsperiod AS CHAR
    FIELD dsdcanal AS CHAR
    FIELD dsendere AS CHAR.

DEF TEMP-TABLE tt-destino-envio                                         NO-UNDO
    FIELD cdrelato AS INTE
    FIELD cddfrenv AS INTE
    FIELD cddestin AS INTE
    FIELD dsdestin AS CHAR
    FIELD selected AS CHAR.

DEF TEMP-TABLE tt-periodo-envio                                         NO-UNDO
    FIELD cdrelato AS INTE
    FIELD cddfrenv AS INTE    
    FIELD cdperiod AS INTE
    FIELD dsperiod AS CHAR
    FIELD selected AS CHAR.

DEF TEMP-TABLE tt-canais-envio                                          NO-UNDO
    FIELD cdprogra AS INTE
    FIELD cdrelato AS INTE
    FIELD cddfrenv AS INTE
    FIELD dsdfrenv AS CHAR.
       
DEF TEMP-TABLE tt-grupo-informativo                                     NO-UNDO
    FIELD cdgrprel AS INTE
    FIELD nmgrprel AS CHAR
    FIELD dsgrprel AS CHAR.
    
                                   
/*............................................................................*/
