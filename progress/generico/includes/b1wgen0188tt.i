/*..............................................................................

    Programa: sistema/generico/includes/b1wgen0188tt.i                  
    Autor   : James Prust Junior
    Data    : Julho/2014                     Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0188.p

   Alteracoes: 
..............................................................................*/

DEF TEMP-TABLE tt-dados-cpa NO-UNDO
    FIELD cdcooper LIKE crapepr.cdcooper
    FIELD nrdconta LIKE crapepr.nrdconta
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD vldiscrd AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD txmensal AS DECI FORMAT "zzz,zzz,zz9.99-".

DEF TEMP-TABLE tt-parcelas-cpa NO-UNDO
    FIELD cdcooper LIKE crapepr.cdcooper
    FIELD nrdconta LIKE crapepr.nrdconta
    FIELD nrctremp LIKE crapepr.nrctremp
    FIELD nrparepr LIKE crappep.nrparepr
    FIELD vlparepr LIKE crappep.vlparepr
    FIELD dtvencto LIKE crappep.dtvencto
    FIELD flgdispo AS LOG INIT TRUE.
/*............................................................................*/
