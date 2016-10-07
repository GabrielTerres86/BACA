/*............................................................................

    Programa: sistema/generico/includes/b1wgen0131tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : Dezembro/2011                      Ultima atualizacao: 03/10/2016
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0131.
  
    Alteracoes: 25/07/2012 - Incluido temp-table tt-fluxo-con e novos campos
                na tt-fluxo (Tiago).

                03/10/2016 - Remocao das opcoes "F" e "L" para o PRJ313.
                             (Jaison/Marcos SUPERO)

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

DEF TEMP-TABLE tt-per-datas NO-UNDO 
    FIELD cdagrupa AS INTE FORMAT "9999999999"
    FIELD nrsequen AS INTE FORMAT "9999999999"
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD vlrtotal AS DECI FORMAT "zzz,zzz,zz,zzz,zz9.99"
    INDEX tt-per-datas1 dtmvtolt
    INDEX tt-per-datas2 nrsequen.

DEF TEMP-TABLE tt-auxerros NO-UNDO LIKE craperr.

/* ......................................................................... */


    

