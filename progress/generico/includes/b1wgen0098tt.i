/*..............................................................................
    
    Programa: sistema/generico/includes/b1wgen0098tt.i                  
    Autor   : Henrique
    Data    : Maio/2010                     Ultima atualizacao: 27/07/2015

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0098.p

   Alteracoes: 27/07/2015 - Removido os campos vlsaqmax, insaqmax da 
                            temp-table tt-crapcrm. (James)
..............................................................................*/

DEF TEMP-TABLE tt-crapcrm NO-UNDO
        FIELD nrdconta AS DECI
        FIELD nrdctitg AS CHAR
        FIELD dssititg AS CHAR
        FIELD nmprimtl AS CHAR
        FIELD nmtitcrd AS CHAR
        FIELD dtemscar AS DATE
        FIELD dtvalcar AS DATE.
