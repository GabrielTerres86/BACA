/*..............................................................................

    Programa: b1wgen0199tt.i
    Autor   : Lucas Reinert
    Data    : Dezembro/2017                   Ultima atualizacao: 

    Objetivo  : Definicao das Temp-Tables para rotinas relacionadas a Integracao CDC

    Alteracoes: 
..............................................................................*/

                  
DEFINE TEMP-TABLE tt-avalista NO-UNDO 
    FIELD idavalis AS INTE    
    FIELD cdcooper LIKE crapavt.cdcooper 
    FIELD nrctaava AS DECI
    FIELD nrdvctav AS INTE
    FIELD nmavalis AS CHAR
    FIELD nrcpfcgc AS DECI
    FIELD tppessoa AS INTE
    FIELD dtnascto AS DATE
    FIELD tpdocava AS CHAR
    FIELD nrdocava AS CHAR
    FIELD nrcepava AS INTE
    FIELD dsendere AS CHAR
    FIELD nrendere AS INTE
    FIELD dscomple AS CHAR
    FIELD nrcxpost AS INTE
    FIELD dsbairro AS CHAR
    FIELD dscidade AS CHAR
    FIELD cdufende AS CHAR
    FIELD dsnacion AS CHAR
    FIELD nrtelefo AS CHAR
    FIELD dsdemail AS CHAR
    FIELD vlrenmes AS DECI
    FIELD vlendmax AS DECI
    FIELD nmconjug AS CHAR
    FIELD nrcpfcon AS DECI
    FIELD tpdoccon AS CHAR
    FIELD nrdoccon AS CHAR.

/*............................................................................*/

