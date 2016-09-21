/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0148tt.i
    Autor   : Lucas Lunelli
    Data    : Janeiro/2013              Ultima Atualizacao: 06/01/2015
     
    Dados referentes ao programa:
   
    Objetivo  : Includes referente a BO b1wgen0148.
                 
    Alteracoes: 06/01/2015 - Inclusão da temp-table tt-crapcpc (Jean Michel).

.............................................................................*/

DEF TEMP-TABLE tt-aplicacoes NO-UNDO
    FIELD nraplica AS CHAR
    FIELD dtmvtolt LIKE craprda.dtmvtolt
    FIELD sldresga AS CHAR.
                                   
DEF TEMP-TABLE tt-crapcpc NO-UNDO
    FIELD cdprodut LIKE crapcpc.cdprodut
    FIELD nmprodut LIKE crapcpc.nmprodut
    FIELD idtipapl AS CHAR FORMAT "A/N".
