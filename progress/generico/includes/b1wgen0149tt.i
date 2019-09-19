/*.............................................................................

   Programa: b1wgen0149tt.i                 
   Autor   : David Kruger
   Data    : Janeiro/2013                        Ultima atualizacao: 08/01/2014

   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0149.p - AGENCI

   Alteracoes: 08/01/2014 - Ajustes para homolgação (Adriano).
   
.............................................................................*/


DEF TEMP-TABLE tt-agencia                                          NO-UNDO
    FIELD nrdrowid AS ROWID                                     
    FIELD cdageban LIKE crapagb.cdageban                        
    FIELD dgagenci LIKE crapagb.dgagenci                        
    FIELD nmageban LIKE crapagb.nmageban                        
    FIELD cdsitagb LIKE crapagb.cdsitagb                        
    FIELD cdcompen LIKE crapcaf.cdcompen                        
    FIELD nmcidade LIKE crapcaf.nmcidade                        
    FIELD cdufresd LIKE crapcaf.cdufresd                        
    FIELD cddbanco LIKE crapagb.cddbanco                        
    INDEX tt-agencia1 cddbanco cdageban.                        
                                                                
DEF TEMP-TABLE tt-feriados                                        NO-UNDO
    FIELD nrdrowid AS ROWID                                     
    FIELD dtferiad LIKE crapfsf.dtferiad                        
    FIELD flgbaixa AS INTE
    INDEX tt-feriados1 nrdrowid.                                
                                                                
DEF TEMP-TABLE tt-banco                                           NO-UNDO
    FIELD cddbanco LIKE crapban.cdbccxlt
    FIELD nmextbcc LIKE crapban.nmextbcc.




