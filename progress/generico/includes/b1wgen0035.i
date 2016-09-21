/*..............................................................................

    Programa: b1wgen0035.p
    Autor   : Magui/David
    Data    : Setembro/2008                     Ultima Atualizacao:   /  /
           
    Dados referentes ao programa:
                
    Objetivo  : Variaveis para geracao dos arquivos DLO.
                    
    Alteracoes:
                        
..............................................................................*/

DEF TEMP-TABLE w_dlo
    FIELD cddconta LIKE crapdlo.cddconta
    FIELD cdlimite LIKE crapdlo.cdlimite
    FIELD vllanmto LIKE crapdlo.vllanmto
    INDEX w_dlo1 AS PRIMARY UNIQUE cddconta.
  
/*............................................................................*/
