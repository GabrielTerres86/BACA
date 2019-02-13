/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0154tt.i
    Autor(a): Fabricio
    Data    : Marco/2013                     Ultima atualizacao: 
  
    Dados referentes ao programa:
  
    Objetivo  : Definicao das temp-tables para a tela ICFJUD.
                
  
    Alteracoes: 
                             
.............................................................................*/

DEF TEMP-TABLE tt-consulta-icf NO-UNDO
    FIELD dtinireq AS DATE
    FIELD dtfimreq AS DATE
    FIELD cdbanori AS INTE
    FIELD nrctaori AS DECI
    FIELD cdbanreq AS INTE
    FIELD cdagereq AS INTE
    FIELD nrctareq AS DECI
    FIELD nrcpfcgc AS DECI
    FIELD nmprimtl AS CHAR
    FIELD dacaojud AS CHAR
    FIELD cdcritic AS INTE
    FIELD cdtipcta AS INTE
	FIELD dsdocmc7 AS CHAR
    FIELD dsstatus AS CHAR.

DEF VAR aux_dscpfcgc AS CHAR                                     NO-UNDO.
DEF VAR aux_dsdenome AS CHAR                                     NO-UNDO.
DEF VAR aux_dstipcta AS CHAR                                     NO-UNDO.
DEF VAR aux_dsstatus AS CHAR                                     NO-UNDO.

/* .......................................................................... */
