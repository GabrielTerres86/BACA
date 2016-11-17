/*..............................................................................

   Programa: b1wgen0006tt.i                  
   Autor   : David
   Data    : Agosto/2007                      Ultima atualizacao: 03/10/2012   

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0006.p

   Alteracoes: 25/10/2007 - Incluir variaves rpp (Magui) 

               30/04/2008 - Retornar campo dtvctopp - Vencimento (David).
               
               03/03/2010 - Adaptacao para rotina POUP.PROGRAMADA (David).
               
               03/10/2012 - Adicionado campo dsextrat em tt-extr-rpp (Jorge).
                   
..............................................................................*/


DEF TEMP-TABLE tt-dados-rpp NO-UNDO
    FIELD nrctrrpp AS INTE FORMAT "z,zzz,zz9"
    FIELD cdagenci AS INTE FORMAT "zz9"
    FIELD cdbccxlt AS INTE FORMAT "zz9"
    FIELD nrdolote AS INTE FORMAT "zzz9"
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD dtvctopp AS DATE FORMAT "99/99/9999"
    FIELD dtdebito AS DATE FORMAT "99/99/9999"
    FIELD indiadeb AS INTE FORMAT "99"
    FIELD vlprerpp AS DECI FORMAT "zzz,zz9.99"
    FIELD qtprepag AS INTE FORMAT "zz9"
    FIELD vlprepag AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD vlsdrdpp AS DECI DECIMALS 8 FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlrgtrpp AS DECI DECIMALS 8 FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vljuracu AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD vlrgtacu AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD dtinirpp AS DATE FORMAT "99/99/9999"
    FIELD dtrnirpp AS DATE FORMAT "99/99/9999"
    FIELD dtaltrpp AS DATE FORMAT "99/99/9999"
    FIELD dtcancel AS DATE FORMAT "99/99/9999"
    FIELD dssitrpp AS CHAR FORMAT "x(10)"
    FIELD dsblqrpp AS CHAR FORMAT "x(3)"
    FIELD dsresgat AS CHAR FORMAT "x(3)"
    FIELD dsctainv AS CHAR FORMAT "x(3)"
    FIELD dsmsgsaq AS CHAR FORMAT "x(40)"
    FIELD cdtiparq AS INTE FORMAT "9"
    FIELD dtsldrpp AS DATE
    FIELD nrdrowid AS ROWID.

DEF TEMP-TABLE tt-extr-rpp NO-UNDO
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD dshistor AS CHAR FORMAT "x(25)"
    FIELD nrdocmto AS INTE FORMAT "zzz,zz9"
    FIELD indebcre AS CHAR FORMAT " x "
    FIELD vllanmto AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlsldppr AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD txaplica AS DECI FORMAT "zz9.999999"
    FIELD txaplmes AS DECI FORMAT "zz9.999999"
    FIELD cdagenci AS INTE FORMAT "zz9"
    FIELD cdbccxlt AS INTE FORMAT "zz9"
    FIELD nrdolote AS INTE FORMAT "zzz,zz9"
    FIELD dsextrat AS CHAR FORMAT "x(21)".

DEF TEMP-TABLE tt-resgates-rpp NO-UNDO
    FIELD dtresgat AS DATE
    FIELD nrdocmto AS DECI
    FIELD tpresgat AS CHAR
    FIELD dsresgat AS CHAR
    FIELD nmoperad AS CHAR
    FIELD hrtransa AS CHAR
    FIELD vlresgat AS DECI.

DEF TEMP-TABLE tt-autoriza-rpp NO-UNDO
    FIELD nmextcop AS CHAR
    FIELD nmrescop AS CHAR
    FIELD nmexcop1 AS CHAR
    FIELD nmexcop2 AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufdcop AS CHAR
    FIELD nrdocnpj AS CHAR
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD nrctrrpp AS INTE
    FIELD vlprerpp AS DECI
    FIELD dsprerpp AS CHAR
    FIELD dtvctopp AS DATE
    FIELD ddaniver AS CHAR
    FIELD dsmesano AS CHAR
    FIELD nranoini AS CHAR
    FIELD nrdiargt AS INTE
    FIELD txaplica AS DECI
    FIELD dtmvtolt AS DATE
    FIELD flgsubst AS LOGI.


/*............................................................................*/
