/*..............................................................................

    Programa: sistema/generico/includes/b1wgen0084tt.i                  
    Autor   : Irlan
    Data    : Fevereiro/2010                     Ultima atualizacao: 19/12/2018

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0084.p

   Alteracoes: 01/03/2012 - Passar as temp-table da BO b1wgen0084a para esta
                            includes (Gabriel). 
                            
               06/03/2018 - Adicionado campo idcobope na temp-table tt-efetiv-epr.
                            (PRJ 404)

               19/12/2018 - PJ298.2 - Adicionados campos tpemprst e vlprecar na temp-table tt-efetiv-epr.
                            (Andre Clemer - Supero)
..............................................................................*/

DEF TEMP-TABLE tt-parcelas-epr    NO-UNDO
    FIELD cdcooper AS INTE
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrctremp LIKE crappep.nrctremp
    FIELD nrparepr AS INTE
    FIELD vlparepr AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD dtparepr AS DATE FORMAT "99/99/9999"    
    FIELD indpagto AS INTE FORMAT "9"
    FIELD dtvencto AS DATE FORMAT "99/99/9999".

DEF TEMP-TABLE tt-datas-parcelas  NO-UNDO
    FIELD nrparepr AS INTE
    FIELD dtparepr AS DATE.

DEF TEMP-TABLE tt-efetiv-epr       NO-UNDO
    FIELD cdcooper LIKE crawepr.cdcooper 
    FIELD nrdconta LIKE crawepr.nrdconta 
    FIELD nrctremp LIKE crawepr.nrctremp 
    FIELD insitapr LIKE crawepr.insitapr
    FIELD cdsitapr AS CHAR
    FIELD dssitapr AS CHAR
    FIELD dsobscmt LIKE crawepr.dsobscmt
    FIELD dsaprova AS CHAR
    FIELD flgobcmt AS LOGI 
    FIELD cdfinemp LIKE crawepr.cdfinemp
    FIELD cdlcremp LIKE crawepr.cdlcremp
    FIELD nivrisco LIKE crawepr.dsnivris
    FIELD vlemprst LIKE crawepr.vlemprst
    FIELD vlpreemp LIKE crawepr.vlpreemp
    FIELD qtpreemp LIKE crawepr.qtpreemp
    FIELD flgpagto LIKE crawepr.flgpagto
    FIELD dtdpagto AS DATE
    FIELD nrctaav1 LIKE crawepr.nrctaav1
    FIELD nrctaav2 LIKE crawepr.nrctaav2
    FIELD avalist1 AS CHAR
    FIELD avalist2 AS CHAR
    FIELD altdtpgt AS LOGICAL
    FIELD idfiniof AS INTE
    FIELD idcobope LIKE crawepr.idcobope
    FIELD tpemprst LIKE crawepr.tpemprst
    FIELD vlprecar LIKE crawepr.vlprecar
	FIELD flliquid AS INTE.

DEF TEMP-TABLE tt-msg-aval        NO-UNDO
    FIELD cdavalis AS INTE
    FIELD dsmensag AS CHAR.

DEF TEMP-TABLE tt-empr-aval-1     NO-UNDO
    FIELD nrdconta LIKE crapepr.nrdconta   
    FIELD nrctremp LIKE crapepr.nrctremp
    FIELD dtmvtolt LIKE crapepr.dtmvtolt
    FIELD vlemprst LIKE crapepr.vlemprst
    FIELD qtpreemp LIKE crapepr.qtpreemp
    FIELD vlpreemp LIKE crapepr.vlpreemp
    FIELD vlsdeved LIKE crapepr.vlsdeved.

DEF TEMP-TABLE tt-empr-aval-2     NO-UNDO LIKE tt-empr-aval-1.

DEF TEMP-TABLE tt-lanctos-parcelas NO-UNDO LIKE craplem
    FIELD dshistor LIKE craphis.dshistor
    FIELD flgalcad   AS LOGI.



/*............................................................................*/
