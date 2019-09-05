/*..............................................................................

    Programa: b1wgen0040tt.i                  
    Autor   : David
    Data    : Maio/2009                       Ultima atualizacao: 30/06/2014

    Dados referentes ao programa:

    Objetivo  : Temp-tables utlizadas na BO b1wgen0040.p - Custodia

    Alteracoes: 16/12/2009 - Incluir temp-table tt-consulta-cheque (David).
    
                02/05/2011 - Incluir temp-table tt-cheques. (André - DB1)
                
                31/08/2012 - Incluir novos campos na tt-chueques. (Tiago)            
                
                30/06/2014 - Incluir campo cdageaco na tt-cheque. (Reinert)
                
                16/09/2014 - Inclusão do campo cdagechq na tt-cheque. (Vanessa)
                
                21/08/2019 - Inclusão do campo nrremret na tt-cheques-custodia. RITM0011937 (Lombardi)
..............................................................................*/


DEF TEMP-TABLE tt-resumo-custodia                                       NO-UNDO
    FIELD dtlibera AS DATE
    FIELD qtcheque AS INTE
    FIELD vlcheque AS DECI.
    
DEF TEMP-TABLE tt-cheques-custodia                                      NO-UNDO
    FIELD dtlibera AS DATE  
    FIELD cdbanchq AS INTE  
    FIELD cdagechq AS INTE
    FIELD nrctachq AS DECI  
    FIELD nrcheque AS INTE  
    FIELD vlcheque AS DECI
    FIELD dtdevolu AS DATE  
    FIELD tpdevolu AS CHAR
    FIELD cdopedev AS CHAR
    FIELD nrremret AS INTE.

DEF TEMP-TABLE tt-consulta-cheque                                       NO-UNDO
    FIELD nrcheque LIKE crapfdc.nrcheque
    FIELD nrdigchq LIKE crapfdc.nrdigchq
    FIELD nrdctabb LIKE crapfdc.nrdctabb
    FIELD vlcheque LIKE crapfdc.vlcheque
    FIELD dtretchq LIKE crapfdc.dtretchq
    FIELD dtliqchq LIKE crapfdc.dtliqchq
    FIELD dssitchq AS CHAR
    FIELD cdbanchq LIKE crapfdc.cdbanchq
    FIELD cdagechq LIKE crapfdc.cdagechq.

DEFINE TEMP-TABLE tt-cheques                                            NO-UNDO
    FIELD cdbanchq LIKE crapfdc.cdbanchq
    FIELD nrcheque AS INTE
    FIELD nrseqems LIKE crapfdc.nrseqems 
    FIELD tpcheque AS CHAR
    FIELD tpforchq LIKE crapfdc.tpforchq 
    FIELD dsobserv AS CHAR     
    FIELD dtemschq LIKE crapfdc.dtemschq 
    FIELD dtretchq LIKE crapfdc.dtretchq
    FIELD dtliqchq LIKE crapfdc.dtliqchq
    FIELD nrdctitg LIKE crapfdc.nrdctitg
    FIELD nrpedido LIKE crapfdc.nrpedido
    FIELD dtsolped LIKE crapped.dtsolped  
    FIELD dtrecped LIKE crapped.dtrecped
    FIELD dsdocmc7 LIKE crapfdc.dsdocmc7
    FIELD dscordem AS CHAR
    FIELD dscorde1 AS CHAR
    FIELD dtmvtolt AS CHAR
    FIELD vlcheque LIKE crapfdc.vlcheque
    FIELD vldacpmf AS DECI
    FIELD cdtpdchq LIKE crapfdc.cdtpdchq
    FIELD cdbandep LIKE crapfdc.cdbandep  
    FIELD cdagedep LIKE crapfdc.cdagedep  
    FIELD nrctadep LIKE crapfdc.nrctadep
    FIELD flgsubtd AS LOGI
    FIELD nrdigchq AS INTE
    FIELD cdbantic LIKE crapfdc.cdbantic
    FIELD cdagetic LIKE crapfdc.cdagetic
    FIELD nrctatic LIKE crapfdc.nrctatic
    FIELD dtlibtic LIKE crapfdc.dtlibtic
    FIELD cdageaco LIKE crapfdc.cdageaco
    FIELD cdagechq LIKE crapfdc.cdagechq.
       
/*............................................................................*/
