/*..............................................................................

   Programa: b1wgen0157tt.i
   Autor   : Guilherme/SUPERO
   Data    : Junho/2013                      Ultima atualizacao:  / /

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0157.p

   Alteracoes:
                           
.............................................................................*/

DEF TEMP-TABLE tt-aval-crapbem                                         NO-UNDO
    LIKE tt-crapbem.

DEF TEMP-TABLE tt-associado                                            NO-UNDO
    LIKE crapass.

DEF TEMP-TABLE tt-ctrbndes                                             NO-UNDO
    FIELD cdagenci  AS INT
    FIELD nrdconta  AS INT
    FIELD vlctrbnd  AS DECI
    FIELD nrctrato  AS INT
    FIELD tpctrato  AS INTE
    FIELD dtmvtolt  AS DATE
    FIELD inrisctl  AS CHAR
    FIELD nrnotrat  AS DECI
    FIELD indrisco  AS CHAR
    FIELD nrnotatl  AS DECI
    FIELD dteftrat  AS DATE
    FIELD cdoperad  AS CHAR
    FIELD nmoperad  AS CHAR
    FIELD vlutlrat  AS DECI
    FIELD dsagenci  AS CHAR
    FIELD nmprimtl  AS CHAR.

DEF TEMP-TABLE tt-relat LIKE tt-ctrbndes.

/*............................................................................*/
