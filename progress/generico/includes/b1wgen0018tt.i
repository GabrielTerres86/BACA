/*.............................................................................

   Programa: b1wgen0018tt.i                  
   Autor   : GATI - Peixoto/Eder
   Data    : Setembro/2009                      Ultima atualizacao: 16/02/2015

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utilizadas na BO b1wgen0018.p

   Alteracoes: 29/10/2009 - Inclusao das temp-tables tt-crapcdb e 
                            tt-crapass (GATI - Eder)
                            
               17/11/2009 - Inclusao de temp-tables para processos das telas
                            * DESCTO: tt-fechamento, crawlot e tt-relat-lotes
                            * CUSTOD: tt-relat-custod, crabcst
                            
               05/11/2010 - Inclusao da temp-table tt-alterar para processos
                            da tela DESCTO, opcao "A" (Adriano).
                            
               16/02/2015 - Melhorias Nova Operacao 129,130,131 e 132- Desconto
                              de Cheque/Titulos (Andre Santos - SUPERO) 
                            
               26/06/2017 - Adicionados campos vlcheque e qtcheque nas tabelas 
                            crawlot, tt-relat-lotes e tt-relat-custod. PRJ367. (Lombardi)
                            
.............................................................................*/
DEFINE TEMP-TABLE tt-detalhe-conta NO-UNDO
    FIELD nrdconta AS INTE    FORMAT "zzzz,zzz,9"
    FIELD dsagenci AS CHAR    FORMAT "x(21)"
    FIELD dstipcta AS CHAR    FORMAT "x(21)"
    FIELD dssititg AS CHAR    FORMAT "x(07)" 
    FIELD nrmatric AS INTE    FORMAT "zzz,zz9"
    FIELD dtabtcct AS DATE    FORMAT "99/99/9999"
    FIELD nrdctitg AS CHAR    
    FIELD dtatipct AS DATE    FORMAT "99/99/9999"
    FIELD nmprimtl AS CHAR    FORMAT "x(40)"
    FIELD nmsegntl AS CHAR    FORMAT "x(40)".
       
DEFINE TEMP-TABLE tt-alt-tip-conta NO-UNDO
    FIELD literal1 AS CHAR    INIT "Alteracoes: Em:"
    FIELD literal2 AS CHAR    INIT "De"
    FIELD literal3 AS CHAR    INIT "Para"
    FIELD dtalttct AS DATE    FORMAT "99/99/9999"
    FIELD dstctant AS CHAR    FORMAT "x(20)"
    FIELD dstctatu AS CHAR    FORMAT "x(20)".

DEFINE TEMP-TABLE tt-transfer      NO-UNDO
    FIELD nrdconta AS INTE    FORMAT "zzzz,zzz,9"
    FIELD nmprimtl AS CHAR    FORMAT "x(50)"
    FIELD cdageatu AS INTE    FORMAT "99"
    FIELD dtaltera AS DATE    FORMAT "99/99/9999"
    FIELD cdageori AS INTE    FORMAT "99"
    FIELD cdagedes AS INTE    FORMAT "99". 

DEF TEMP-TABLE tt-crapcdb NO-UNDO LIKE crapcdb
     USE-INDEX crapcdb2
     USE-INDEX crapcdb3
     USE-INDEX crapcdb6
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dtmvtopg LIKE craplau.dtmvtopg
    FIELD dspesqui AS CHAR
    FIELD dssitchq AS CHAR
    FIELD dsobserv AS CHAR
    FIELD nmopedev AS CHAR
    FIELD nrcherel AS INTE
    FIELD situacao AS CHAR
    INDEX ttcrapcdb cdcooper nrdconta dtlibera.

DEF TEMP-TABLE tt-crapass          NO-UNDO LIKE crapass.

DEF TEMP-TABLE tt-alterar          NO-UNDO
    FIELD nrcpfcgc AS DEC  FORMAT "zzzzzzzzzzzzz9"
    FIELD nmcheque AS CHAR FORMAT "x(40)".

DEF TEMP-TABLE tt-fechamento       NO-UNDO
    FIELD dtlibera AS DATE FORMAT "99/99/9999"
    FIELD dschqcop AS CHAR FORMAT "x(20)"
    FIELD qtcheque AS INTE FORMAT "zzz,zz9"
    FIELD vlcheque AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtchqdev AS INTE FORMAT "zzz,zz9-"
    FIELD vlchqdev AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD qtchqdsc AS INTE FORMAT "zzz,zz9-"
    FIELD vlchqdsc AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD qtchqcop AS INTE FORMAT "zzz,zz9"
    FIELD vlchqcop AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtchqban AS INTE FORMAT "zzz,zz9"
    FIELD vlchqban AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtcredit AS INTE FORMAT "zzz,zz9-"
    FIELD vlcredit AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD qtdmenor AS INTE FORMAT "zzz,zz9"
    FIELD qtdmaior AS INTE FORMAT "zzz,zz9"
    FIELD vlrmenor AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD vlrmaior AS DECI FORMAT "zzz,zzz,zz9.99-".

DEF TEMP-TABLE crawlot             NO-UNDO
    FIELD indrelat AS INT
    FIELD dtmvtolt AS DATE    FORMAT "99/99/9999"
    FIELD cdagenci AS INT     FORMAT "zzz9"
    FIELD nrdconta AS INT     FORMAT "zzzz,zzz,9"
    FIELD nrborder AS INT     FORMAT "z,zzz,zz9"
    FIELD nrdolote AS INT     FORMAT "zzz,zz9"
    FIELD qtchqcop AS INT     FORMAT "zz9"
    FIELD qtchqmen AS INT     FORMAT "zz9"
    FIELD qtchqmai AS INT     FORMAT "zz9"
    FIELD qtcheque AS INT     FORMAT "zz9"
    FIELD qtchqtot AS INT     FORMAT "zz9"
    FIELD vlchqcop AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD vlchqmen AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD vlchqmai AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD vlcheque AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD vlchqtot AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD nmoperad AS CHAR    FORMAT "x(10)"
    FIELD dtlibera AS DATE    FORMAT "99/99/9999"
    FIELD cdbccxlt LIKE craplot.cdbccxlt
    FIELD qtcompln AS INT     FORMAT "zz9"           
    FIELD vlcompdb AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    INDEX crawlot1 dtmvtolt cdagenci nrdolote.

DEF TEMP-TABLE tt-relat-lotes      NO-UNDO
    FIELD dsdsaldo AS CHAR
    FIELD qtdlotes AS INT  FORMAT "zz9"
    FIELD qtchqcop AS INT  FORMAT "zzz9"
    FIELD qtchqmen AS INT  FORMAT "zzz9"
    FIELD qtchqmai AS INT  FORMAT "zzz9"
    FIELD qtcheque AS INT  FORMAT "zzz9"
    FIELD qtchqtot AS INT  FORMAT "zzz9"
    FIELD vlchqcop AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD vlchqmen AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD vlchqmai AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD vlcheque AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD vlchqtot AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD vlchmatb AS DECI FORMAT "zzz,zzz,zz9.99".

DEF TEMP-TABLE tt-saldo            NO-UNDO
    FIELD qtchqcop AS INTE FORMAT "zzz,zz9" 
    FIELD qtchqban AS INTE FORMAT "zzz,zz9" 
    FIELD qtchqdev AS INTE FORMAT "zzz,zz9-"
    FIELD qtcheque AS INTE FORMAT "zzz,zz9" 
    FIELD qtcredit AS INTE FORMAT "zzz,zz9-"
    FIELD qtsldant AS INTE FORMAT "zzz,zz9-"
    FIELD qtlibera AS INTE FORMAT "zzz,zz9-"
    FIELD qtchqdsc AS INTE FORMAT "zzz,zz9-"
    FIELD vlchqcop AS DECI FORMAT "zzz,zzz,zz9.99" 
    FIELD vlchqban AS DECI FORMAT "zzz,zzz,zz9.99" 
    FIELD vlchqdev AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD vlcheque AS DECI FORMAT "zzz,zzz,zz9.99" 
    FIELD vlcredit AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD vlsldant AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD vllibera AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD vlchqdsc AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD dschqcop AS CHAR FORMAT "x(20)".

DEF TEMP-TABLE tt-lancamentos      NO-UNDO
    FIELD pesquisa AS CHAR    FORMAT "x(25)"
    FIELD dtlibera LIKE crapcdb.dtlibera 
    FIELD cdbanchq LIKE crapcdb.cdbanchq
    FIELD cdagechq LIKE crapcdb.cdagechq 
    FIELD nrctachq LIKE crapcdb.nrctachq 
    FIELD nrcheque LIKE crapcdb.nrcheque 
    FIELD vlcheque LIKE crapcdb.vlcheque.

DEF TEMP-TABLE tt-relat-custod     NO-UNDO
    FIELD indrelat AS INTE
    FIELD dsdsaldo AS CHAR
    FIELD qtdlotes AS INTE  FORMAT "zzz9"
    FIELD qtchqcop AS INTE  FORMAT "zzz9"
    FIELD qtchqmen AS INTE  FORMAT "zzz9"
    FIELD qtchqmai AS INTE  FORMAT "zzz9"
    FIELD qtcheque AS INTE  FORMAT "zzz9"
    FIELD qtchqtot AS INTE  FORMAT "zzz9"
    FIELD vlchqcop AS DECI
    FIELD vlchqmen AS DECI FORMAT "zzzz,zzz,zz9.99"
    FIELD vlchqmai AS DECI FORMAT "zzzz,zzz,zz9.99"
    FIELD vlcheque AS DECI FORMAT "zzzz,zzz,zz9.99"
    FIELD vlchqtot AS DECI FORMAT "zzzz,zzz,zz9.99".

DEF TEMP-TABLE crabcst             NO-UNDO
    FIELD indrelat AS INT
    FIELD cdagenci AS INT  FORMAT "zz9"
    FIELD nrdconta AS INT  FORMAT "zzzz,zzz,9"
    FIELD nrdolote AS INT  FORMAT "zzz,zz9"
    FIELD cdbccxlt AS INT  FORMAT "zz9"
    FIELD dtlibera AS DATE FORMAT "99/99/9999"
    FIELD cdbanchq LIKE crapcst.cdbanchq
    FIELD cdcmpchq LIKE crapcst.cdcmpchq
    FIELD cdagechq LIKE crapcst.cdagechq
    FIELD nrctachq LIKE crapcst.nrctachq
    FIELD nrcheque LIKE crapcst.nrcheque
    FIELD vlcheque LIKE crapcst.vlcheque
    FIELD dsdocmc7 LIKE crapcst.dsdocmc7.

DEF TEMP-TABLE tt-crapcst          NO-UNDO LIKE crapcst
    FIELD tpdevolu AS CHAR FORMAT "X(4)"
    FIELD dspesqui AS CHAR
    FIELD dssitchq AS CHAR
    FIELD dsobserv AS CHAR
    FIELD nmopedev AS CHAR
    FIELD nrcherel AS INTE
    FIELD nmprimtl LIKE crapass.nmprimtl.

DEF TEMP-TABLE tt-crapbdc          NO-UNDO LIKE crapbdc
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dtlibera LIKE crapcdb.dtlibera.

DEF TEMP-TABLE tt-resumo-bordero   NO-UNDO
    FIELD dtmvtolt AS DATE
    FIELD nrborder AS INTE
    FIELD qtcheque AS INTE
    FIELD vlcheque AS DECI.

DEF TEMP-TABLE tt-detalhes-bordero NO-UNDO
    FIELD dtlibera AS DATE
    FIELD cdbanchq AS INTE
    FIELD cdagechq AS INTE
    FIELD nrctachq AS DECI
    FIELD nrcheque AS INTE
    FIELD vlcheque AS DECI
    FIELD dtdevolu AS DATE.

DEF TEMP-TABLE tt-titulo-bordero   NO-UNDO
    FIELD dtmvtolt AS DATE
    FIELD nrborder AS INTE
    FIELD qttitulo AS INTE
    FIELD vltitulo AS DECI
    FIELD vlliquid AS DECI.

DEF TEMP-TABLE tt-detalhes-titulo NO-UNDO
    FIELD dtlibbdt AS DATE
    FIELD cdbandoc AS INTE
    FIELD nrcnvcob AS INTE
    FIELD nrdocmto AS INTE
    FIELD vltitulo AS DECI
    FIELD vlliquid AS DECI
    FIELD dtvencto AS DATE
    FIELD dtresgat AS DATE
    FIELD vlliqres AS DECI
    FIELD tpcobran AS CHAR.

/*..........................................................................*/
