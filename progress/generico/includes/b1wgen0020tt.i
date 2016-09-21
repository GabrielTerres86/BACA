/*..............................................................................

   Programa: b1wgen0020tt.i                  
   Autor   : Murilo
   Data    : Agosto/2007                      Ultima atualizacao: 03/10/2012   

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0020.p

   Alteracoes: 21/08/2008 - Incluir tabela tt-saldo-investimento (David).
    
               09/10/2008 - Incluir campo cdbloque na tt-extrato-inv (David).
               
               03/10/2012 - Incluir campo ds extrat na tt-extrat_inv (Lucas R.).
                            
..............................................................................*/

DEF TEMP-TABLE tt-extrato_inv NO-UNDO
    FIELD dtmvtolt LIKE craplci.dtmvtolt
    FIELD dshistor LIKE craphis.dshistor
    FIELD nrdocmto LIKE craplci.nrdocmto
    FIELD indebcre LIKE craphis.indebcre
    FIELD vllanmto LIKE craplci.vllanmto
    FIELD vlsldtot AS DECI
    FIELD cdbloque AS CHAR
    FIELD dsextrat LIKE craphis.dsextrat.

DEF TEMP-TABLE tt-saldo-investimento NO-UNDO
    FIELD vlsldinv AS DECI.

/*............................................................................*/
