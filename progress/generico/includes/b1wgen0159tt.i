/*..............................................................................

    Programa: b1wgen0159tt.i
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andre Santos - Supero
    Data    : Julho/2013                        Ultima atualizacao: 13/06/2014

    Dados referentes ao programa:

    Objetivo  : Arquivo com variáveis ultizadas na BO b1wgen0159.p
               
    Alteracoes: 27/08/2013 - Ajustando BO para Ayllos(WEB)
                            (Andre Santos - SUPERO)
                            
                13/06/2014 - Temp-table para totalização por entidade
                             (SD. 167168 - Lunelli)
                            
..............................................................................*/

DEF TEMP-TABLE tt-imunidade NO-UNDO LIKE crapimt
    FIELD dsdentid AS CHAR
    FIELD dssitcad AS CHAR
    FIELD nmoperad AS CHAR.

DEF TEMP-TABLE tt-contas-ass NO-UNDO LIKE crapass.

DEF TEMP-TABLE tt-entidade NO-UNDO
    FIELD cddentid AS INTE
    FIELD dsdentid AS CHAR.

DEF TEMP-TABLE tt-situacao NO-UNDO
    FIELD cdsitcad AS INTE
    FIELD dssitcad AS CHAR.

DEF TEMP-TABLE tt-totalizador-entid NO-UNDO
    FIELD cddentid AS INTE
    FIELD totentid AS INTE.

/*............................................................................*/

