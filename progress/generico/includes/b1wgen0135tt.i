/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0135tt.i                  
    Autor(a): Fabricio
    Data    : Fevereiro/2012                     Ultima atualizacao: 
  
    Dados referentes ao programa:
  
    Objetivo  : Definicao das temp-tables para a tela TRAESP.
                
  
    Alteracoes: 
                             
                 04/12/2017 - Melhoria 458, adicionado coluna cpfcgrcb e table tt-crapcme2 - Antonio R. Junior (mouts)
                 08/05/2019 - Incluso novo parametro nrdconta na tt-crapcme2.
                             RITM0011928 - Jose Dill (Mouts)
                             
.............................................................................*/

DEF TEMP-TABLE tt-transacoes-especie NO-UNDO
    FIELD cdagenci AS CHAR
    FIELD nrdolote AS INTE
    FIELD nrdconta AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD vllanmto AS CHAR
    FIELD nrdocmto AS CHAR
    FIELD dtmvtolt AS DATE
    FIELD tpoperac AS CHAR
    FIELD sisbacen AS LOGI
    FIELD nmrescop AS CHAR
    FIELD cdopecxa AS CHAR
    FIELD nrdcaixa AS INTE
    FIELD nrseqaut AS INTE
    FIELD nrdctabb AS INTE.

DEF TEMP-TABLE tt-crapcme NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD cdagenci LIKE crapcme.cdagenci
    FIELD nrdconta LIKE crapcme.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc AS CHAR
    FIELD nrdocmto LIKE crapcme.nrdocmto
    FIELD tpoperac AS CHAR
    FIELD vllanmto LIKE crapcme.vllanmto
    FIELD dtmvtolt LIKE crapcme.dtmvtolt
    FIELD infrepcf AS CHAR
    FIELD flinfdst LIKE crapcme.flinfdst
    FIELD recursos LIKE crapcme.recursos
    FIELD dstrecur LIKE crapcme.dstrecur
    FIELD nrdrowid AS ROWID
    FIELD dsdjusti LIKE crapcme.dsdjusti
    INDEX cdcooper cdagenci nrdconta.

DEF TEMP-TABLE tt-reg-crapcme NO-UNDO LIKE tt-crapcme.
DEF TEMP-TABLE tt-crapcme2 NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrcpfcgc AS CHAR
    FIELD tpoperac AS CHAR
    FIELD dtmvtolt LIKE crapcme.dtmvtolt
    FIELD nrdconta LIKE crapcme.nrdconta.
