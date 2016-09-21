
/*..............................................................................

   Programa: b1wgen0004tt.i                  
   Autor   : David
   Data    : Agosto/2007                      Ultima atualizacao: 09/10/2009

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0004.p

   Alteracoes: 21/02/2008 - Retirado tt-output, conflito BO1(Guilherme).

               31/03/2008 - Incluir temp-table tt-acumula (David).
               
               09/10/2009 - Incluir campo cddresga na tt-saldo-rdca (David).
                            
..............................................................................*/

DEF TEMP-TABLE tt-acumula NO-UNDO
    FIELD nraplica LIKE craprda.nraplica
    FIELD tpaplica AS CHAR 
    FIELD vlsdrdca LIKE craprda.vlsdrdca.
    
DEF TEMP-TABLE tt-dados-acumulo NO-UNDO
    FIELD nrdconta LIKE craprda.nrdconta
    FIELD nraplica LIKE craprda.nraplica
    FIELD dsaplica LIKE crapdtc.dsaplica
    FIELD dtmvtolt LIKE craprda.dtmvtolt
    FIELD dtvencto LIKE craprda.dtvencto
    FIELD vlaplica LIKE craprda.vlaplica
    FIELD txaplica LIKE craplap.txaplica
    FIELD txaplmes LIKE craplap.txaplmes                        
    FIELD vlsldrdc LIKE craprda.vlsdrdca         
    FIELD vlstotal LIKE crapcap.vlsddapl.   
    
DEF TEMP-TABLE tt-tipo-aplicacao NO-UNDO
    FIELD tpaplica LIKE crapdtc.tpaplica
    FIELD dsaplica LIKE crapdtc.dsaplica
    FIELD tpaplrdc LIKE crapdtc.tpaplrdc.
    
DEF TEMP-TABLE tt-carencia-aplicacao NO-UNDO
    FIELD cdperapl LIKE crapttx.cdperapl
    FIELD qtdiaini LIKE crapttx.qtdiaini
    FIELD qtdiafim LIKE crapttx.qtdiafim
    FIELD qtdiacar LIKE crapttx.qtdiacar.
    
DEF TEMP-TABLE tt-saldo-rdca NO-UNDO
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD nraplica AS INTE FORMAT "zzz,zz9"
    FIELD dshistor AS CHAR FORMAT "x(25)"
    FIELD nrdocmto AS CHAR FORMAT "x(12)"
    FIELD dtvencto AS DATE FORMAT "99/99/9999"
    FIELD indebcre AS CHAR FORMAT " x "
    FIELD vllanmto AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD sldresga AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD cddresga AS CHAR FORMAT " x ".

DEF TEMP-TABLE tt-extr-rdca NO-UNDO
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD dshistor AS CHAR FORMAT "x(25)"
    FIELD nrdocmto AS INTE FORMAT "zzz,zz9"
    FIELD indebcre AS CHAR FORMAT " x "
    FIELD vllanmto AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlsldapl AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD txaplica AS DECI FORMAT "zz9.999999"
    FIELD dsaplica AS CHAR FORMAT "x(10)".
    
DEF TEMP-TABLE tt-extr-rdc NO-UNDO
    FIELD dtmvtolt LIKE crapdat.dtmvtolt
    FIELD cdagenci LIKE crapage.cdagenci
    FIELD cdbccxlt LIKE craplap.cdbccxlt
    FIELD nrdolote LIKE craplap.nrdolote
    FIELD cdhistor LIKE craphis.cdhistor
    FIELD dshistor LIKE craphis.dshistor
    FIELD nrdocmto LIKE craplap.nrdocmto
    FIELD indebcre LIKE craphis.indebcre
    FIELD vllanmto LIKE craplap.vllanmto
    FIELD vlsdlsap LIKE craplap.vlsdlsap
    FIELD txaplica LIKE craplap.txaplica
    FIELD vlpvlrgt LIKE craplap.vlpvlrgt.
    
DEF TEMP-TABLE tt-resg-aplica NO-UNDO
    FIELD dtresgat LIKE craplrg.dtresgat
    FIELD nrdocmto LIKE craplrg.nrdocmto
    FIELD tpresgat AS CHAR
    FIELD dsresgat AS CHAR
    FIELD nmoperad LIKE crapope.nmoperad
    FIELD hrtransa AS CHAR
    FIELD vllanmto LIKE craplrg.vllanmto.    

/*............................................................................*/

