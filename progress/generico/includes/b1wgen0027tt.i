/*..............................................................................

   Programa: b1wgen0027tt.i                  
   Autor   : Guilherme
   Data    : Fevereiro/2008                  Ultima atualizacao: 19/06/2015

   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0027.p

   Alteracoes: 04/03/2008 - Incluir rotina de extrato_emitidos_cash (Ze).
   
               04/12/2009 - Mudar tabela do risco da crapass para a capnrc
                            (Gabriel)
               
               18/08/2010 - Incluido os campos qtdiaris e dtdrisco na 
                            Temp-Table tt-ocorren (Elton).
                            
               04/03/2011 - Inclusao dos campos inrisctl e dtrisctl na
                            temp-table tt-ocorren. (Fabricio)
                            
               29/11/2012 - Incluido o campo dsdrisgp na tabel tt-ocorren
                            (Adriano).
                            
               19/06/2015 - Incluido o campo innivris na temp-table tt-ocorren.
                            (James).
                            
               09/01/2019 - P298.2.2 - Luciano (Supero) - Na tela Atenda > Ocorrencias> Prejuízo> 
                            deverá apresentar as informaçoes de prejuízo do contrato Pós-Fixado.
..............................................................................*/

DEF TEMP-TABLE tt-ocorren NO-UNDO
    FIELD qtctrord AS INTE
    FIELD qtdevolu AS INTE
    FIELD dtcnsspc LIKE crapass.dtcnsspc
    FIELD dtdsdsps LIKE crapass.dtdsdspc
    FIELD qtddsdev LIKE crapsld.qtddsdev
    FIELD dtdsdclq LIKE crapsld.dtdsdclq
    FIELD qtddtdev LIKE crapsld.qtddtdev
    FIELD flginadi AS LOGI
    FIELD flglbace AS LOGI
    FIELD flgeprat AS LOGI
    FIELD indrisco LIKE crapnrc.indrisco
    FIELD nivrisco AS CHAR
    FIELD flgpreju AS LOGI
    FIELD flgjucta AS LOGI
    FIELD flgocorr AS LOGI
    FIELD dtdrisco AS DATE
    FIELD qtdiaris AS INTE
    FIELD inrisctl LIKE crapass.inrisctl
    FIELD dtrisctl LIKE crapass.dtrisctl
    FIELD dsdrisgp AS CHAR
    FIELD innivris LIKE crapris.innivris.
    
DEF TEMP-TABLE tt-contra_ordem NO-UNDO
     FIELD cdbanchq LIKE crapcor.cdbanchq
     FIELD cdagechq LIKE crapcor.cdagechq
     FIELD nrctachq LIKE crapcor.nrctachq
     FIELD cdoperad LIKE crapcor.cdoperad
     FIELD nrcheque LIKE crapcor.nrcheque
     FIELD dtemscor LIKE crapcor.dtemscor
     FIELD dtmvtolt LIKE crapcor.dtmvtolt
     FIELD dshistor LIKE craphis.dshistor.    
     
DEFINE TEMP-TABLE tt-emprestimos NO-UNDO
     FIELD cdpesqui AS CHAR
     FIELD nrctremp AS INTE
     FIELD vlemprst AS DECI
     FIELD vlsdeved AS DECI 
     FIELD vlpreapg AS DECI
     FIELD dtultpag AS DATE.
     
DEFINE TEMP-TABLE tt-prejuizos NO-UNDO
     FIELD cdpesqui AS CHAR
     FIELD nrctremp AS INTE
     FIELD dtprejuz AS DATE
     FIELD vlprejuz AS DECI
     FIELD vlsdprej AS DECI
     FIELD nrdiaatr AS INTE
     FIELD nrdiaprj AS INTE
     FIELD nrdiatot AS INTE
     FIELD vljrmprj AS DECI
     FIELD vlttmupr AS DECI
     FIELD vlttjmpr AS DECI
     FIELD vltiofpr AS DECI
     FIELD vlrpagos AS DECI
     FIELD vlrabono AS DECI
     FIELD vlsaldev AS DECI.

DEFINE TEMP-TABLE tt-spc NO-UNDO
       FIELD nrctremp AS INTE
       FIELD dsidenti AS CHAR
       FIELD dtvencto AS DATE
       FIELD dtinclus AS DATE
       FIELD vldivida AS DECI
       FIELD dsorigem AS CHAR
       FIELD nrctrspc AS CHAR
       FIELD dtdbaixa AS DATE.
       
DEFINE TEMP-TABLE tt-estouros NO-UNDO
    FIELD nrseqdig LIKE crapneg.nrseqdig
    FIELD dtiniest LIKE crapneg.dtiniest
    FIELD qtdiaest LIKE crapneg.qtdiaest
    FIELD cdhisest AS CHAR 
    FIELD vlestour LIKE crapneg.vlestour
    FIELD nrdctabb LIKE crapneg.nrdctabb
    FIELD nrdocmto LIKE crapneg.nrdocmto
    FIELD cdobserv AS CHAR
    FIELD dsobserv AS CHAR
    FIELD vllimcre LIKE crapneg.vllimcre
    FIELD dscodant AS CHAR
    FIELD dscodatu AS CHAR.
    
DEFINE TEMP-TABLE tt-extcash NO-UNDO
    FIELD dtrefere AS DATE
    FIELD dtmesano AS CHAR
    FIELD cdagenci AS INT
    FIELD nrnmterm AS CHAR
    FIELD inisenta AS LOGICAL.
    
/*............................................................................*/
