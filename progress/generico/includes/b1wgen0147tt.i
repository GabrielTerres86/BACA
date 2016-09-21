/*.............................................................................
    
   Programa: b1wgen0147tt.i                  
   Autor(a): Lucas R.
   Data    : 02/05/2013                         Ultima atualizacao: 09/05/2013

   Dados referentes ao programa:

   Objetivo  : Temp-Tables utilizadas na BO b1wgen0147.p

   Alteracoes: 09/05/2013 - Adicionado temp-table tt-arq-imp. (Fabricio)

.............................................................................*/
 
DEF TEMP-TABLE tt-infoass NO-UNDO 
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc AS CHAR
    FIELD cddopcao AS CHAR.

DEF TEMP-TABLE tt-arq-imp NO-UNDO
    FIELD idsequen AS INTE
    FIELD nmarquiv AS CHAR.
 
DEF TEMP-TABLE tt-saldo-devedor-bndes NO-UNDO LIKE crapebn
    FIELD qtdmesca AS INTE
    FIELD percaren AS CHAR
    FIELD perparce AS CHAR
    FIELD dsdprodu AS CHAR.
