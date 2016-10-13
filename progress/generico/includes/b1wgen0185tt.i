/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0185tt.i
    Autor   : Jéssica Laverde Gracino (DB1)
    Data    : 24/02/2014                     Ultima atualizacao: 11/10/2016
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0185.
  
    Alteracoes: 20/01/2015 - Ajustes para liberacao (Adriano).

				11/10/2016 - M172 - Ajuste do formato do número de celular devido
							ao acrescimo de mais um digito.
							(Ricardo Linhares)
    
.............................................................................*/

DEF TEMP-TABLE tt-lista NO-UNDO
    FIELD cddopcao AS CHAR FORMAT "x(1)"
    FIELD dscopcao AS CHAR FORMAT "x(76)".

DEF TEMP-TABLE tt-situacao NO-UNDO
    FIELD sqsitcrd AS INT 
    FIELD dssitcrd AS CHAR FORMAT "x(07)"
    FIELD insitcrd LIKE crawcrd.insitcrd
    INDEX id-tt-situacao1 sqsitcrd
    INDEX id-tt-situacao2 insitcrd.

DEF TEMP-TABLE tt-lincred NO-UNDO
    FIELD cdcodigo AS INT
    FIELD dsdescri AS CHAR
    FIELD flgmarca AS LOG.

DEF TEMP-TABLE tt-finalidade NO-UNDO
    FIELD cdcodigo AS INT
    FIELD dsdescri AS CHAR
    FIELD flgmarca AS LOG.

DEF TEMP-TABLE tt-cartoes NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD dtmvtolt LIKE craplcm.dtmvtolt
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD cdagenci LIKE crawcrd.cdagenci
    FIELD nrdconta LIKE crawcrd.nrdconta
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD nrcpftit AS CHAR FORMAT "99999999999"
    FIELD dsadmcrd AS CHAR   
    FIELD dssitcrd AS CHAR   
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD dtpropos LIKE crawcrd.dtpropos
    FIELD dtsolici LIKE crawcrd.dtsolici
    FIELD dtcancel LIKE crawcrd.dtcancel
    FIELD dtentreg LIKE crawcrd.dtentreg
    FIELD vllimcrd AS DECI
    FIELD vllimdeb AS DECI
    FIELD nrreside AS CHAR   FORMAT "(xx)xxxx-xxxx"
    FIELD nrcelula AS CHAR   FORMAT "(xx)xxxxx-xxxx"
    FIELD dddebito LIKE crawcrd.dddebito
    FIELD vlfatdb1 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD vlfatdb2 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD vlfatdb3 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD histo613 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD histo614 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD histo668 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD vlrrendi AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD outroren AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    INDEX tt-cartoes1 
          AS PRIMARY dtmvtolt cdcooper nrdconta
    INDEX tt-cartoes2 cdcooper dtmvtolt nrdconta.

DEF TEMP-TABLE tt-lancamentos NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD dtmvtolt LIKE craplcm.dtmvtolt
    FIELD nrdconta LIKE crawcrd.nrdconta
    FIELD cdhistor LIKE craplcm.cdhistor
    FIELD histo613 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD histo614 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD histo668 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    INDEX tt-cartoes1 
          AS PRIMARY cdcooper dtmvtolt nrdconta
    INDEX tt-cartoes2 cdcooper nrdconta.
    

DEF TEMP-TABLE tt-craplgm1 NO-UNDO
    FIELD nrdconta AS INTE
    FIELD dttransa AS DATE
    INDEX index01 dttransa nrdconta.
    
DEF TEMP-TABLE tt-craplgm2 NO-UNDO
    FIELD nrdconta AS INTE
    FIELD dttransa AS DATE
    INDEX index01 dttransa nrdconta.    

DEF TEMP-TABLE tt-dados NO-UNDO
    FIELD dtrefere AS CHAR
    FIELD qtlibera AS INTE
    FIELD qtacesso AS INTE
    INDEX index01 AS PRIMARY dtrefere.
    
DEF TEMP-TABLE tt-acesso-trimestre NO-UNDO
    FIELD dtrefere AS CHAR
    FIELD nrdconta AS INTE
    INDEX index01 AS PRIMARY dtrefere nrdconta.

