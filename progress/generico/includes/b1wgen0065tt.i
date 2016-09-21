/*.............................................................................

    Programa: b1wgen0065tt.i
    Autor   : Jose Luis
    Data    : Abril/2010                   Ultima atualizacao: 00/00/0000

    Objetivo  : Definicao das Temp-Tables para tela de CONTAS - REGISTRO

    Alteracoes:

.............................................................................*/



/*...........................................................................*/

DEFINE TEMP-TABLE tt-registro NO-UNDO
    FIELD vlfatano LIKE crapjur.vlfatano
    FIELD vlcaprea LIKE crapjur.vlcaprea
    FIELD dtregemp LIKE crapjur.dtregemp
    FIELD nrregemp LIKE crapjur.nrregemp
    FIELD orregemp LIKE crapjur.orregemp
    FIELD dtinsnum LIKE crapjur.dtinsnum
    FIELD nrinsmun LIKE crapjur.nrinsmun
    FIELD nrinsest LIKE crapjur.nrinsest
    FIELD flgrefis LIKE crapjur.flgrefis
    FIELD nrcdnire LIKE crapjur.nrcdnire
    FIELD perfatcl LIKE crapjfn.perfatcl.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-registro-ant NO-UNDO LIKE tt-registro.

    DEFINE TEMP-TABLE tt-registro-atl NO-UNDO LIKE tt-registro.

&ENDIF
