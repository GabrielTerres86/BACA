
/*..............................................................................

   Programa: b1wgen0081tt.i                  
   Autor   : Adriano
   Data    : 29/11/2010                      Ultima atualizacao: 29/01/2015

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0081.p

   Alteracoes: 01/08/2011 - Criado dshistoi na tt-extr-rdca.(Gabriel - DB1)
                
               16/08/2011 - Adicionado campo nraplica, dshistor, dtmvtolt e  
                            dtaplica em tt-resg-aplica (Jorge)
                            
               08/09/2011 - Criado tpaplrdc na tt-extr-rdca.(Gabriel - DB1)
               
               01/10/2012 - Adicionado novo parametro dsextrat em tt-extr-rdca.
                            (Jorge).
                            
               01/09/2013 - Adicionado campo dsaplica na tt-dados-aplicacao (Lucas).
               
               10/06/2014 - Ajustes referente ao projeto captacao:
                           - Incluido o campo dtcarenc na temp-table
                             tt-carencia-aplicacao, tt-dados-aplicacao  
                           (Adriano).
                           
               24/07/2014 - Inclusao do campo dstipapl na temp-table
                            tt-tipo-aplicacao (Jean Michel).
               
               31/07/2014 - Inclusao da temp-table tt-carencia-aplicacao-novo,
                            para projeto de captacao (Jean Michel).
                            
               09/10/2014 - Inclusao do campo sitresga na temp-table
                            tt-resg-aplica (Jean Michel).             
                            
               21/11/2014 - Inclusão do campo nraplica na temp-table
                            tt-extr-rdca (Reinert)
                            
               29/01/2015 - Inclusao do campo nmprdcom, flgrecno na
                            tt-dados_aplicacao (Jean Michel).             
               
..............................................................................*/

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
    FIELD tpaplrdc LIKE crapdtc.tpaplrdc
    FIELD dstipapl AS CHAR FORMAT "x(2)".

DEF TEMP-TABLE tt-carencia-aplicacao NO-UNDO
    FIELD cdperapl LIKE crapttx.cdperapl
    FIELD qtdiaini LIKE crapttx.qtdiaini
    FIELD qtdiafim LIKE crapttx.qtdiafim
    FIELD qtdiacar LIKE crapttx.qtdiacar
    FIELD dtcarenc LIKE crapdat.dtmvtolt.

DEF TEMP-TABLE tt-carencia-aplicacao-novo NO-UNDO
    FIELD qtdiacar LIKE crapdtc.tpaplica
    FIELD qtdiaprz LIKE crapdtc.tpaplica.

DEF TEMP-TABLE tt-extr-rdca NO-UNDO
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD dshistor AS CHAR FORMAT "x(25)"
    FIELD nrdocmto AS INTE FORMAT "zzz,zz9"
    FIELD indebcre AS CHAR FORMAT " x "
    FIELD vllanmto AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlsldapl AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD txaplica AS DECI FORMAT "zz9.999999"
    FIELD dsaplica AS CHAR FORMAT "x(10)"
    FIELD cdagenci AS INTE FORMAT "zz9"
    FIELD vlpvlrgt AS CHAR FORMAT "x(16)"
    FIELD cdhistor AS INTE FORMAT "zzz9"
    FIELD tpaplrdc AS INTE FORMAT "9"
    FIELD dsextrat AS CHAR FORMAT "x(21)"
    FIELD nraplica AS INTE FORMAT "zzz,zz9".

DEF TEMP-TABLE tt-resg-aplica NO-UNDO
    FIELD dtresgat LIKE craplrg.dtresgat
    FIELD nrdocmto LIKE craplrg.nrdocmto
    FIELD tpresgat AS CHAR
    FIELD dsresgat AS CHAR
    FIELD nmoperad LIKE crapope.nmoperad
    FIELD hrtransa AS CHAR
    FIELD vllanmto LIKE craplrg.vllanmto
    FIELD nraplica LIKE craplrg.nraplica
    FIELD dshistor AS CHAR FORMAT "x(25)"
    FIELD dtmvtolt LIKE craplrg.dtmvtolt
    FIELD dtaplica LIKE craprda.dtmvtolt
    FIELD sitresga AS CHAR FORMAT "x(02)"
    FIELD idtipapl AS CHAR FORMAT "x(01)".

DEF TEMP-TABLE tt-dados-aplicacao NO-UNDO
    FIELD tpaplrdc LIKE crapdtc.tpaplrdc
    FIELD cdageapl LIKE craprda.cdagenci
    FIELD tpaplica LIKE craprda.tpaplica   
    FIELD nraplica LIKE craprda.nraplica
    FIELD qtdiaapl LIKE craprda.qtdiaapl
    FIELD dtresgat LIKE craprda.dtvencto
    FIELD qtdiacar LIKE crapttx.qtdiacar
    FIELD cdperapl LIKE crapttx.cdperapl
    FIELD flgdebci LIKE craprda.flgdebci
    FIELD vllanmto LIKE craprda.vlaplica
    FIELD txaplica LIKE craplap.txaplica
    FIELD dsaplica LIKE crapdtc.dsaplica
    FIELD dtcarenc LIKE crapdat.dtmvtolt
    FIELD nmprdcom LIKE crapcpc.nmprodut
    FIELD flgrecno AS logi.

DEF TEMP-TABLE tt-agendamento NO-UNDO
    FIELD cdageass LIKE crapaar.cdageass
    FIELD cdagenci LIKE crapaar.cdagenci
    FIELD cdcooper LIKE crapaar.cdcooper
    FIELD cdoperad LIKE crapaar.cdoperad
    FIELD cdsitaar LIKE crapaar.cdsitaar
    FIELD dtcancel LIKE crapaar.dtcancel
    FIELD dtcarenc LIKE crapaar.dtcarenc
    FIELD dtiniaar LIKE crapaar.dtiniaar
    FIELD dtmvtolt LIKE crapaar.dtmvtolt
    FIELD dtvencto LIKE crapaar.dtvencto
    FIELD flgctain LIKE crapaar.flgctain
    FIELD flgresin LIKE crapaar.flgresin
    FIELD flgtipar LIKE crapaar.flgtipar
    FIELD flgtipin LIKE crapaar.flgtipin
    FIELD hrtransa LIKE crapaar.hrtransa
    FIELD idseqttl LIKE crapaar.idseqttl
    FIELD nrctraar LIKE crapaar.nrctraar
    FIELD nrdconta LIKE crapaar.nrdconta
    FIELD nrdocmto LIKE crapaar.nrdocmto 
    FIELD nrmesaar LIKE crapaar.nrmesaar
    FIELD qtdiacar LIKE crapaar.qtdiacar
    FIELD qtmesaar LIKE crapaar.qtmesaar
    FIELD vlparaar LIKE crapaar.vlparaar
    FIELD dtdiaaar LIKE crapaar.dtdiaaar
    FIELD incancel AS INTE
    FIELD dssitaar AS CHAR
    FIELD dstipaar AS CHAR.

DEF TEMP-TABLE tt-agen-det NO-UNDO
    FIELD cdcooper LIKE craplau.cdcooper
    FIELD cdagenci LIKE craplau.cdagenci
    FIELD cdbccxlt LIKE craplau.cdbccxlt
    FIELD cdbccxpg LIKE craplau.cdbccxpg
    FIELD cdhistor LIKE craplau.cdhistor
    FIELD dtdebito LIKE craplau.dtdebito
    FIELD dtmvtolt LIKE craplau.dtmvtolt
    FIELD dtmvtopg LIKE craplau.dtmvtopg
    FIELD insitlau LIKE craplau.insitlau
    FIELD nrdconta LIKE craplau.nrdconta
    FIELD nrdctabb LIKE craplau.nrdctabb
    FIELD nrdolote LIKE craplau.nrdolote
    FIELD nrseqlan LIKE craplau.nrseqlan
    FIELD tpdvalor LIKE craplau.tpdvalor
    FIELD vllanaut LIKE craplau.vllanaut
    FIELD nrdocmto AS   CHAR
    FIELD flgtipar AS   INTE
    FIELD dstipaar AS   CHAR
    FIELD flgtipin AS   INTE
    FIELD dstipinv AS   CHAR
    FIELD qtdiacar LIKE crapaar.qtdiacar
    FIELD dssitlau AS   CHAR
    FIELD vlsolaar AS   DECI
    FIELD dsprotoc LIKE crappro.dsprotoc.

/****************************************************************************/


