/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0122tt.i
    Autor(a): Rogerius Militão (DB1)
    Data    : Outubro/2011                        Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0122.
  
    Alteracoes: 
    
.............................................................................*/ 

DEF TEMP-TABLE tt-tipo                                                 NO-UNDO
    FIELD cdtippro    LIKE crappro.cdtippro
    FIELD dstippro    LIKE crappro.dsinform[1].

DEF TEMP-TABLE tt-cratpro                                              NO-UNDO
    FIELD nmprimtl AS CHAR
    FIELD tppgamto AS CHAR
    FIELD dsdbanco AS CHAR
    FIELD cdtippro LIKE crappro.cdtippro
    FIELD dstippro AS CHAR
    FIELD dtmvtolt LIKE crappro.dtmvtolt
    FIELD dttransa LIKE crappro.dttransa
    FIELD hrautent LIKE crappro.hrautent
    FIELD hrautenx AS CHAR
    FIELD vldocmto LIKE crappro.vldocmto
    FIELD nrdocmto LIKE crappro.nrdocmto
    FIELD nrseqaut LIKE crappro.nrseqaut
    FIELD dsinform LIKE crappro.dsinform
    FIELD cdbarras AS CHAR
    FIELD lndigita AS CHAR
    FIELD terminax AS CHAR
    FIELD dsprotoc LIKE crappro.dsprotoc
    FIELD dscedent LIKE crappro.dscedent
    FIELD flgagend LIKE crappro.flgagend
    FIELD nmprepos LIKE crappro.nmprepos
    FIELD nrcpfpre LIKE crappro.nrcpfpre
    FIELD nmoperad LIKE crapopi.nmoperad
    FIELD nrcpfope LIKE crappro.nrcpfope
    FIELD flgpagto LIKE crappla.flgpagto
    FIELD dsageban AS CHAR
    FIELD nrctafav AS CHAR
    FIELD nmfavore AS CHAR
    FIELD nrcpffav AS CHAR
    FIELD dsfinali AS CHAR
    FIELD dstransf AS CHAR.

/*............................................................................*/
