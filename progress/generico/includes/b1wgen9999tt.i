/*..............................................................................

   Programa: b1wgen9999tt.i                  
   Autor   : David
   Data    : Marco/2008                  Ultima atualizacao: 23/09/2016

   Dados referentes ao programa:

   Objetivo  : Temp-tables utilizadas na BO b1wgen9999.p

   Alteracoes: 22/07/2008 - Incluir tt-cabrel (Guilherme).

               18/08/2008 - Incluir tt-iof (Guilherme). 
               
               29/07/2010 - Fase II do projeto de melhorias de Op. de 
                            credito (Gabriel).
                            
               13/04/2011 - Inclusão de campo Nro. e Complemento na 
                            tt-dados-avais. CEP integrado. (André - DB1)              
               
               21/08/2013 - Incluir tt-listal (André E / Supero)
               
               06/06/2014 - Incluso campos inpessoa e dtnascto na
                            TEMP-TABLE tt-dados-avais (Daniel/Thiago).  
                            
               23/09/2016 - Correçao nas TEMP-TABLES colocar NO-UNDO, tt-cooper (Oscar).                             
                            
..............................................................................*/

DEF TEMP-TABLE tt-cooper NO-UNDO
    FIELD cdcooper AS INT
    FIELD nmrescop AS CHAR.


DEF TEMP-TABLE tt-dados-avais NO-UNDO
    FIELD nrctaava AS INTE
    FIELD nmdavali AS CHAR
    FIELD nrcpfcgc AS DECI
    FIELD tpdocava AS CHAR
    FIELD nrdocava AS CHAR
    FIELD nmconjug AS CHAR
    FIELD nrcpfcjg AS DECI
    FIELD tpdoccjg AS CHAR
    FIELD nrdoccjg AS CHAR
    FIELD dsendre1 AS CHAR
    FIELD dsendre2 AS CHAR  
    FIELD nrfonres AS CHAR
    FIELD dsdemail AS CHAR 
    FIELD nmcidade AS CHAR 
    FIELD cdufresd AS CHAR
    FIELD nrcepend AS INTE
    FIELD dsnacion AS CHAR
    FIELD vledvmto AS DECI
    FIELD vlrenmes AS DECI
    FIELD idavalis AS INTE
    FIELD complend AS CHAR
    FIELD nrendere AS INTE
    FIELD nrcxapst AS INTE
    FIELD dsendre3 AS CHAR
    FIELD inpessoa AS INTE
    FIELD dtnascto AS DATE
    FIELD cdnacion AS INTE.
    
DEF TEMP-TABLE tt-cabrel NO-UNDO
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nmrelato AS CHAR
    FIELD dtmvtref AS DATE FORMAT "99/99/9999"
    FIELD nmmodulo AS CHAR FORMAT "x(15)"
    FIELD cdrelato AS INTE FORMAT "999"
    FIELD progerad AS CHAR
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD dshoraat AS CHAR
    FIELD nmdestin AS CHAR FORMAT "x(40)".
    
DEF TEMP-TABLE tt-iof NO-UNDO
    FIELD dtiniiof AS DATE
    FIELD dtfimiof AS DATE
    FIELD txccdiof AS DECI.
DEF TEMP-TABLE tt-iof-sn LIKE tt-iof.

DEF TEMP-TABLE tt-listal NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD qtfolhas AS INT
    FIELD qtdflsa4 AS INT.
      
/*............................................................................*/
