/*............................................................................

    Programa: sistema/generico/includes/b1wgen0133tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : 26/01/2012                      Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0133.
  
    Alteracoes: 
    
............................................................................*/  
DEF TEMP-TABLE tt-devedor NO-UNDO
    FIELD tpidenti AS INTE
    FIELD nrctremp AS INTE
    FIELD nrctrspc AS CHAR
    FIELD dtvencto AS DATE
    FIELD vldivida AS DECI
    FIELD dtinclus AS DATE
    FIELD dtdbaixa AS DATE
    FIELD tpinsttu AS INTE
    FIELD dsidenti AS CHAR
    FIELD dsinsttu AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD cdagenci AS INTE
    FIELD nmresage AS CHAR
    FIELD nrdconta AS INTE
    FIELD dsoberv1 AS CHAR
    FIELD dsoberv2 AS CHAR
    FIELD operador AS CHAR
    FIELD opebaixa AS CHAR
    FIELD nrctaavl AS INTE
    FIELD nmpriavl AS CHAR
    FIELD nrdrowid AS ROWID.

DEF TEMP-TABLE tt-conta NO-UNDO
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR.

DEF TEMP-TABLE tt-contrato NO-UNDO
    FIELD nrctrspc AS CHAR
    FIELD vldivida AS DECI
    FIELD dtinclus AS DATE
    FIELD dtdbaixa AS DATE
    FIELD nrdrowid AS ROWID.
