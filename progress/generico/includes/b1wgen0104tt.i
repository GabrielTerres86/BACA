/*..............................................................................

    Programa: sistema/generico/includes/b1wgen0104tt.i                  
    Autor   : Guilherme/Gabriel
    Data    : Julho/2010                     Ultima atualizacao: 22/02/2012

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0104.p

   Alteracoes: 22/02/2012 - Criados novos campos para evitar registros 
                            duplicados quando tipo doc. for 0. (Lucas)
                            
..............................................................................*/

DEF TEMP-TABLE tt-crapcme NO-UNDO
    FIELD nrdconta LIKE crapcme.nrdconta
    FIELD dsdconta AS CHAR
    FIELD vllanmto LIKE crapcme.vllanmto
    FIELD nrseqaut LIKE crapcme.nrseqaut
    FIELD nrccdrcb LIKE crapcme.nrccdrcb
    FIELD nmpesrcb LIKE crapcme.nmpesrcb
    FIELD inpesrcb AS INTE
    FIELD nridercb LIKE crapcme.nridercb
    FIELD dtnasrcb LIKE crapcme.dtnasrcb
    FIELD desenrcb LIKE crapcme.desenrcb
    FIELD nmcidrcb LIKE crapcme.nmcidrcb
    FIELD nrceprcb LIKE crapcme.nrceprcb
    FIELD cdufdrcb LIKE crapcme.cdufdrcb
    FIELD flinfdst LIKE crapcme.flinfdst
    FIELD recursos LIKE crapcme.recursos
    FIELD dstrecur LIKE crapcme.dstrecur
    FIELD cpfcgrcb AS CHAR
    FIELD dsdopera AS CHAR
    FIELD nmcooptl AS CHAR
    FIELD vlretesp LIKE crapcme.vlretesp
    FIELD vlmincen AS DECI.

DEF TEMP-TABLE bk-cmedep NO-UNDO LIKE tt-crapcme.

