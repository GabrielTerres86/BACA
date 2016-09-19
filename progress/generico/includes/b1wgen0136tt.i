/*..............................................................................

   Programa: b1wgen0136tt.i                  
   Autor   : Oscar
   Data    : Maio/2012                      Ultima atualizacao: 11/06/2014

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0136.p

   Alteracoes: 04/11/2013 - Incluido o campo cdpactra na temp-table
                            tt-lancconta (Adriano).
                            
               11/06/2014 - Incluido o campo nrseqava na temp-table
                            tt-lancconta (James).
............................................................................. */

DEF TEMP-TABLE tt-lancconta NO-UNDO
        FIELD cdcooper AS INTE
        FIELD nrctremp AS INTE
        FIELD cdhistor AS INTE
        FIELD dtmvtolt AS DATE
        FIELD cdagenci AS INTE
        FIELD cdbccxlt AS INTE
        FIELD cdoperad AS CHAR
        FIELD nrdolote AS INTE
        FIELD nrdconta AS INTE
        FIELD vllanmto AS DECI
        FIELD cdpactra AS INTE
        FIELD nrseqava AS INTE
                                  
INDEX  tt-lancconta1 cdcooper nrctremp cdhistor dtmvtolt nrdconta.


    
    
    
