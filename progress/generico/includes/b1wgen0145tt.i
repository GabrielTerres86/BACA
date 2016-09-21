/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0145tt.i
    Autor(a): Gabriel Capoia (DB1)
    Data    : 20/12/2012                      Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0145.
  
    Alteracoes: 
    
.............................................................................*/ 

DEFINE TEMP-TABLE tt-msgconta NO-UNDO
    FIELD msgconta AS CHAR.

DEFINE TEMP-TABLE w_contas NO-UNDO
    FIELD nrdconta  LIKE crapass.nrdconta.

DEFINE TEMP-TABLE tt-contras NO-UNDO
    FIELD nrctremp AS INTE
    FIELD cdpesqui AS CHAR
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD vldivida AS CHAR
    FIELD tpdcontr AS CHAR.

DEF TEMP-TABLE tt-avalistas NO-UNDO
    FIELD nrdconta LIKE crapavt.nrdconta
    FIELD nmdavali LIKE crapavt.nmdavali
    FIELD nrcpfcgc LIKE crapavt.nrcpfcgc
    INDEX nrdconta nrcpfcgc.
