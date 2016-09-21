/*..............................................................................

   Programa: b1wgen0023tt.i                  
   Autor   : Guilherme
   Data    : Junho/2009                  Ultima atualizacao:   /  /     
   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0023.p - Emprestimos

   Alteracoes: 
                            
..............................................................................*/
    
DEF TEMP-TABLE tt-dados_epr_net NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD dtdpagto LIKE crapepr.dtdpagto
    FIELD vlpreemp LIKE crapepr.vlpreemp
    FIELD qtpreemp LIKE crapepr.qtpreemp.
    
/* ......................................................................... */ 
