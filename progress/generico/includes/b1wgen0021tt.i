/*..............................................................................

   Programa: b1wgen0021tt.i                  
   Autor   : Murilo
   Data    : Agosto/2007                       Ultima atualizacao: 09/10/2017

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0021.p

   Alteracoes: 19/11/2007 - Incluir temp-tables e campos (David).

               10/12/2007 - Incluir campos na tt-dados-capital (David).

               22/02/2007 - Incluir temp-table tt-saldo-cotas (David).
               
               04/11/2008 - Incluido campo cdufdcop na tt-autorizacao e
                            e tt-cancelamento(Guilherme).
                            
               21/02/2011 - Adicionado campos na tt-extrato_cotas (Henrique).
               
               01/10/2012 - Inclusao do campo dsextrat na tt-extrato_cotas
                            (Lucas R.).
                            
               03/06/2013 - Incluido na tt-saldo-cotas, tt-dados-capital
                            o campo FIELD vlblqjud LIKE crapblj.vlbloque
                            (Andre Santos - SUPERO)
                            
               29/08/2013 - Adicionado os campos dtinipla e dtfuturo na 
                            temp-table tt-novo-plano.
                            Criadas temp-tables tt-lancamentos e
                            tt-estornos. (Fabricio)
                            
               06/02/2014 - Adicionado campos cdtipcor, dtultcor e vlcorfix
                            na temp-table tt-novo-plano e cdtipcor e
                            vlcorfix na tt-autorizacao.
                            Removido campo flgplano da temp-table tt-novo-plano.
                            (Fabricio)
                            
               27/09/2016 - Ajuste das Rotinade Integralização/Estorno integralizaçao
                            M169 (Ricardo Linhares)                            
                            
               09/10/2017 - Incluir campo dsprotoc na temp-table tt-novo-plano (David)
                            
..............................................................................*/

DEF TEMP-TABLE tt-saldo-cotas NO-UNDO
    FIELD vlsldcap AS DECI
    FIELD vlblqjud LIKE crapblj.vlbloque.
    
DEF TEMP-TABLE tt-extrato_cotas NO-UNDO
    FIELD dtmvtolt AS DATE
    FIELD dshistor AS CHAR
    FIELD nrdocmto AS DECI 
    FIELD nrctrpla AS DECI
    FIELD indebcre AS CHAR
    FIELD vllanmto AS DECI
    FIELD vlsldtot AS DECI
    FIELD cdagenci AS INTE
    FIELD cdbccxlt AS INTE
    FIELD nrdolote AS INTE
    FIELD dsextrat AS CHAR
    FIELD incancel AS LOG
    FIELD lctrowid AS INTE.
        
DEF TEMP-TABLE tt-dados-capital NO-UNDO
    FIELD vldcotas AS DECI
    FIELD vlcmicot AS DECI
    FIELD qtcotmfx AS INTE
    FIELD qtprepag AS INTE
    FIELD vlcaptal AS DECI
    FIELD vlmoefix AS DECI
    FIELD nrctrpla AS INTE
    FIELD vlprepla AS DECI
    FIELD dtinipla AS DATE
    FIELD dspagcap AS CHAR
    FIELD nrdolote AS INTE
    FIELD cdagenci AS INTE
    FIELD cdbccxlt AS INTE
    FIELD vlblqjud LIKE crapblj.vlbloque.
    
DEF TEMP-TABLE tt-novo-plano NO-UNDO
    FIELD despagto AS CHAR
    FIELD vlprepla AS DECI
    FIELD qtpremax AS INTE
    FIELD dtdpagto AS DATE
    FIELD flcancel AS LOGI
    FIELD dtlimini AS DATE
    FIELD dtinipla AS DATE
    FIELD dtfuturo AS DATE
    FIELD cdtipcor AS INTE
    FIELD dtultcor AS DATE
    FIELD dtprocor AS DATE
    FIELD vlcorfix AS DECI
    FIELD dsprotoc LIKE crappro.dsprotoc.
    
DEF TEMP-TABLE tt-subscricao NO-UNDO
    FIELD dtdebito AS CHAR
    FIELD dtrefere AS DATE
    FIELD vllanmto AS DECI
    FIELD vlparcap AS DECI.

DEF TEMP-TABLE tt-cancelamento NO-UNDO
    FIELD nmextcop AS CHAR
    FIELD nrdocnpj AS CHAR
    FIELD nrcancel AS INTE
    FIELD vlcancel AS DECI
    FIELD nmprimtl AS CHAR
    FIELD dsdebito AS CHAR
    FIELD nrctrpla AS INTE
    FIELD dtinipla AS DATE
    FIELD nmcidade AS CHAR
    FIELD cdufdcop AS CHAR
    FIELD nmrescop AS CHAR.

DEF TEMP-TABLE tt-autorizacao NO-UNDO
    FIELD nmextcop AS CHAR
    FIELD nrdocnpj AS CHAR
    FIELD nrctrpla AS INTE
    FIELD vlprepla AS DECI
    FIELD nmprimtl AS CHAR
    FIELD flgpagto AS LOGI
    FIELD diadebit AS CHAR
    FIELD dsdprazo AS CHAR
    FIELD dsprepla AS CHAR EXTENT 2
    FIELD dsmesano AS CHAR
    FIELD nranoini AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufdcop AS CHAR
    FIELD nmrescop AS CHAR EXTENT 2
    FIELD cdtipcor AS INTE
    FIELD vlcorfix AS DECI.

DEF TEMP-TABLE tt-protocolo NO-UNDO
    FIELD cdtippro LIKE crappro.cdtippro
    FIELD dtmvtolt LIKE crappro.dtmvtolt
    FIELD dttransa LIKE crappro.dttransa
    FIELD hrautent LIKE crappro.hrautent
    FIELD vldocmto LIKE crappro.vldocmto
    FIELD nrdocmto LIKE crappro.nrdocmto
    FIELD dsinform LIKE crappro.dsinform
    FIELD dsprotoc LIKE crappro.dsprotoc.
    
DEF TEMP-TABLE tt-horario NO-UNDO
    FIELD hrinipla AS CHAR
    FIELD hrfimpla AS CHAR.

DEF TEMP-TABLE cratpla NO-UNDO LIKE crappla.

DEF TEMP-TABLE tt-lancamentos NO-UNDO
    FIELD nrdocmto AS DECI
    FIELD vllanmto AS DECI
    FIELD lctrowid AS INTE.

DEF TEMP-TABLE tt-estornos NO-UNDO LIKE tt-lancamentos.

/*............................................................................*/
