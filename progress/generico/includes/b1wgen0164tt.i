
/*............................................................................

    Programa: sistema/generico/includes/b1wgen0164tt.i
    Autor(a): Carlos Henrique
    Data    : Agosto/2014                      Ultima atualizacao: 06/11/13
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0164.
  
    Alteracoes: 06/11/2013 - Incluido campos do endereço para atender a 
                             parte de web (Jéssica DB1).
                             
                 19/03/2015 - Criação da tt-crapavt-aux para paginação 
                              dos resultados (Vanessa).
............................................................................*/ 

    DEF TEMP-TABLE tt-crapavt NO-UNDO LIKE crapavt
        FIELD dsendres1 AS CHAR
        FIELD dsendres2 AS CHAR
        FIELD dsnacion  AS CHAR.

    DEF TEMP-TABLE tt-crapavt-aux NO-UNDO LIKE tt-crapavt.
