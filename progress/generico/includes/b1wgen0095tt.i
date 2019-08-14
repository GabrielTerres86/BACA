/*.............................................................................

    Programa: b1wgen0095tt.i                  
    Autor   : André - DB1
    Data    : Junho/2011                       Ultima atualizacao: 23/07/2013

    Dados referentes ao programa:

    Objetivo  : Temp-tables utlizadas na BO b1wgen0095.p

    Alteracoes: 18/06/2013 - Ajuste no inclusao da contra-ordem (Trf. 70652)
                            Ze.
                            
                23/07/2013 - Ajuste para melhorar o desempenho no crapcor (Ze)
                
                09/08/2019 - Adicionado campo dtliqchq na tabela tt-dctror. RITM0023830 (Lombardi)
.............................................................................*/
DEFINE TEMP-TABLE tt-dctror                                             NO-UNDO
    FIELD cdcooper AS INT
    FIELD nmprimtl AS CHAR
    FIELD cdsitdtl AS INTE
    FIELD dssitdtl AS CHAR
    FIELD dtemscor AS DATE
    FIELD cdhistor AS INTE
    FIELD nrinichq AS INTE
    FIELD nrfinchq AS INTE
    FIELD nrctachq AS DECI
    FIELD cdbanchq AS INTE
    FIELD cdagechq AS INTE
    FIELD dtaltera AS DATE
    FIELD nrtalchq AS INTE
    FIELD dshistor AS CHAR
    FIELD nrdconta AS INTE
    FIELD dtvalcor AS DATE
    FIELD flprovis AS LOGI FORMAT "SIM/NAO"
    FIELD dsprovis AS CHAR
    FIELD flgativo AS LOGI
    FIELD dtliqchq AS DATE.

DEFINE TEMP-TABLE tt-contra                                             NO-UNDO
    FIELD cdhistor AS INTE
    FIELD cdbanchq AS INTE
    FIELD cdagechq AS INTE
    FIELD nrctachq AS DECI
    FIELD nrinichq AS INTE
    FIELD nrfinchq AS INTE
    FIELD nrdconta AS INTE
    FIELD flgfecha AS LOGI
    FIELD dtvalcor AS DATE
    FIELD flprovis AS LOGI FORMAT "SIM/NAO"
    FIELD flgativo AS LOGI.

DEFINE TEMP-TABLE tt-cheques                                            NO-UNDO
    FIELD cdbanchq AS INTE
    FIELD cdagechq AS INTE
    FIELD nrctachq AS DECI
    FIELD nrcheque AS INTE
    FIELD nrinichq AS INTE
    FIELD nrfinchq AS INTE
    FIELD nrdconta AS INTE
    FIELD cdhistor AS INTE
    FIELD dscritic AS CHAR
    FIELD dtvalcor AS DATE
    FIELD flprovis AS LOGI FORMAT "SIM/NAO"
    FIELD flgativo AS LOGI.

DEF TEMP-TABLE tt-criticas                                              NO-UNDO
    FIELD cdbanchq AS INTE 
    FIELD cdagechq AS INTE 
    FIELD nrctachq AS DECI 
    FIELD nrcheque AS INTE 
    FIELD dscritic AS CHAR
    .

DEF TEMP-TABLE tt-custdesc                                              NO-UNDO
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR 
    FIELD dtliber1 AS DATE /* p/ custodia */   
    FIELD cdpesqu1 AS CHAR /* p/ custodia */  
    FIELD dtliber2 AS DATE /* p/ desconto */  
    FIELD cdpesqu2 AS CHAR /* p/ desconto */  
    FIELD cdbanchq AS INTE
    FIELD cdagechq AS INTE
    FIELD nrctachq AS DECI
    FIELD nrcheque AS INTE
    FIELD nrinichq AS INTE
    FIELD nrfinchq AS INTE
    FIELD cdhistor AS INTE
    FIELD flgselec AS LOGI INIT FALSE
    FIELD flgcusto AS LOGI INIT FALSE
    FIELD flgdesco AS LOGI INIT FALSE
    FIELD flprovis AS LOGI FORMAT "SIM/NAO".

DEF TEMP-TABLE tt-dctror-ant NO-UNDO
    /* crapfdc */
    FIELD cdcooper LIKE crapfdc.cdcooper
    FIELD nrdconta LIKE crapfdc.nrdconta
    FIELD cdbanchq LIKE crapfdc.cdbanchq
    FIELD cdagechq LIKE crapfdc.cdagechq
    FIELD nrctachq LIKE crapfdc.nrctachq
    FIELD nrcheque LIKE crapfdc.nrcheque
    FIELD incheque LIKE crapfdc.incheque
    /* crapcor */
    FIELD cdhistor LIKE crapcor.cdhistor
    FIELD dtemscor LIKE crapcor.dtemscor
    /* crapass */
    FIELD cdsitdtl LIKE crapass.cdsitdtl

    FIELD dscritic AS CHAR
    .

DEF TEMP-TABLE tt-dctror-atl NO-UNDO LIKE tt-dctror-ant.

DEF BUFFER crabcor FOR crapcor.
/*...........................................................................*/
