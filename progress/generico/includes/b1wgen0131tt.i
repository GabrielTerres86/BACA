/*............................................................................

    Programa: sistema/generico/includes/b1wgen0131tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : Dezembro/2011                      Ultima atualizacao: 25/07/2012
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0131.
  
    Alteracoes: 25/07/2012 - Incluido temp-table tt-fluxo-con e novos campos
                na tt-fluxo (Tiago).
    
............................................................................*/ 

DEF TEMP-TABLE tt-previs NO-UNDO
    FIELD vlmoedas AS DECI EXTENT 6
    FIELD vldnotas AS DECI EXTENT 6
    FIELD qtmoedas AS INTE EXTENT 6
    FIELD qtdnotas AS INTE EXTENT 6
    FIELD qtmoepct AS INTE EXTENT 6
    FIELD submoeda AS DECI EXTENT 6
    FIELD subnotas AS DECI EXTENT 6
    FIELD qtremtit AS INTE
    FIELD vlremtit AS DECI
    FIELD vldvlbcb AS DECI
    FIELD qtdvlbcb AS INTE
    FIELD vldepesp AS DECI
    FIELD vldvlnum AS DECI
    FIELD vlremdoc AS DECI
    FIELD qtremdoc AS INTE
    FIELD totmoeda AS DECI
    FIELD totnotas AS DECI
    FIELD nmoperad AS CHAR
    FIELD hrtransa AS CHAR.

DEF TEMP-TABLE tt-fluxo NO-UNDO
    FIELD vlchqnot AS DECI
    FIELD vlchqdia AS DECI
    FIELD vlcobbil AS DECI
    FIELD vlcobmlt AS DECI.

DEF TEMP-TABLE tt-ffin-mvto-sing
    FIELD cdbcoval AS INTE EXTENT 4
    FIELD tpdmovto AS INTE 
    FIELD vlcheque AS DECI EXTENT 4
    FIELD vltotdoc AS DECI EXTENT 4
    FIELD vltotted AS DECI EXTENT 4
    FIELD vltottit AS DECI EXTENT 4
    FIELD vldevolu AS DECI EXTENT 4 
    FIELD vlmvtitg AS DECI EXTENT 4
    FIELD vlttinss AS DECI EXTENT 4
    FIELD vltrdeit AS DECI EXTENT 4
    FIELD vlsatait AS DECI EXTENT 4
    FIELD vlfatbra AS DECI EXTENT 4
    FIELD vlconven AS DECI EXTENT 4
    FIELD vlrepass AS DECI EXTENT 4
    FIELD vlnumera AS DECI EXTENT 4
    FIELD vlrfolha AS DECI EXTENT 4
    FIELD vldivers AS DECI EXTENT 4
    FIELD vlttcrdb AS DECI EXTENT 4
    FIELD vloutros AS DECI EXTENT 4.

DEF TEMP-TABLE tt-ffin-cons-sing
    FIELD cdcooper AS INTE
    FIELD cdagenci AS INTE
    FIELD cdoperad AS CHAR
    FIELD dtmvtolt AS DATE
    FIELD vlentrad AS DECI
    FIELD vlsaidas AS DECI
    FIELD vlresult AS DECI
    FIELD vlsldfin AS DECI
    FIELD vlsldcta AS DECI
    FIELD vlresgat AS DECI
    FIELD vlaplica AS DECI
    FIELD nmrescop AS CHAR
    FIELD nmoperad AS CHAR
    FIELD hrtransa AS CHAR.

DEF TEMP-TABLE tt-ffin-mvto-cent
    FIELD cdbcoval AS INTE EXTENT 3
    FIELD tpdmovto AS INTE
    FIELD vlcheque AS DECI EXTENT 3
    FIELD vltotdoc AS DECI EXTENT 3
    FIELD vltotted AS DECI EXTENT 3
    FIELD vltottit AS DECI EXTENT 3
    FIELD vldevolu AS DECI EXTENT 3 
    FIELD vlmvtitg AS DECI EXTENT 3
    FIELD vlttinss AS DECI EXTENT 3
    FIELD vldivers AS DECI EXTENT 3
    FIELD vlttcrdb AS DECI EXTENT 3.

DEF TEMP-TABLE tt-ffin-cons-cent
    FIELD cdcooper AS INTE 
    FIELD dtmvtolt AS DATE 
    FIELD vlentrad AS DECI EXTENT 3
    FIELD vlsaidas AS DECI EXTENT 3
    FIELD vlresult AS DECI EXTENT 3.

DEF TEMP-TABLE tt-per-datas NO-UNDO 
    FIELD cdagrupa AS INTE FORMAT "9999999999"
    FIELD nrsequen AS INTE FORMAT "9999999999"
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD vlrtotal AS DECI FORMAT "zzz,zzz,zz,zzz,zz9.99"
    INDEX tt-per-datas1 dtmvtolt
    INDEX tt-per-datas2 nrsequen.

DEF TEMP-TABLE tt-auxerros NO-UNDO LIKE craperr.

/* ......................................................................... */


    

