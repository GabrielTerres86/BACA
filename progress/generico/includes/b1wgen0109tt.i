/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0109tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : Agosto/2011                        Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0109.
  
    Alteracoes: 
    
............................................................................*/

DEF TEMP-TABLE tt-nmrelato
    FIELD nmrelato LIKE craprel.nmrelato
    FIELD contador AS INTE
    FIELD flgrelat AS LOGI
    FIELD flgvepac AS LOGI
    FIELD nmdprogm AS CHAR
    FIELD nrcolfrm AS INTE.
