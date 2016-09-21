/*............................................................................

    Programa: sistema/generico/includes/b1wgen0025tt.i
    Autor(a): Oscar
    Data    : Outubro/2012                      Ultima atualizacao: 
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0025.
  
    Alteracoes: 
............................................................................*/ 

DEF TEMP-TABLE cratlot           NO-UNDO     LIKE craplot.
DEF TEMP-TABLE cratlcm           NO-UNDO     LIKE craplcm.

/* para controle do estorno */
DEF TEMP-TABLE tt-craplcm        NO-UNDO     LIKE craplcm.

DEF TEMP-TABLE tt-lancamentos
    FIELD cdtplanc   AS INT
    FIELD cdcooper   AS INT
    FIELD cdcoptfn   AS INT
    FIELD cdagetfn   AS INT
    FIELD nrdconta   AS DECI 
    FIELD dstplanc   AS CHAR
    FIELD tpconsul   AS CHAR
    FIELD qtdecoop   AS INT
    FIELD qtdmovto   AS INT
    FIELD vlrtotal   AS DECI 
    FIELD vlrtarif   AS DECI 
    INDEX ix-lanc cdtplanc cdcooper cdcoptfn cdagetfn nrdconta.
