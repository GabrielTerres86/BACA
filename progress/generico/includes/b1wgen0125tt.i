/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0125tt.i
    Autor(a): Rogerius Militao (DB1)
    Data    : Novembro/2011                      Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0125.
  
    Alteracoes: 
    
.............................................................................*/ 

/*** Definição de Temp-Table ***/
DEF TEMP-TABLE tt-contas 
         FIELD cdagenci AS INTE FORMAT "zz9"
         FIELD nrdconta AS INTE FORMAT "zzzz,zzz,z"
         FIELD nrcpfcgc AS DECI 
         FIELD nmprimtl AS CHAR FORMAT "x(35)"
         FIELD tpdconta AS CHAR FORMAT "x(15)"
         FIELD idseqttl LIKE crapttl.idseqttl.

DEF TEMP-TABLE tt-modalidade NO-UNDO
    FIELD cdmodali AS CHAR FORMAT "x(02)"
    FIELD dsmodali AS CHAR FORMAT "x(40)"
    FIELD vlvencto LIKE crapvop.vlvencto.

DEF TEMP-TABLE tt-detmodal NO-UNDO
    FIELD cdmodali LIKE crapvop.cdmodali
    FIELD dssubmod AS CHAR FORMAT "x(40)"
    FIELD vlvencto LIKE crapvop.vlvencto.

DEF TEMP-TABLE tt-historico NO-UNDO
    FIELD dtrefere AS CHAR 
    FIELD vlvencto AS DECI FORMAT "->>,>>>,>>9.99"
    FIELD dsdbacen AS CHAR FORMAT "x(43)"
    FIELD dtcomple LIKE crapopf.dtrefere
    INDEX tt-historico1 dtcomple DESC.

DEF TEMP-TABLE tt-fluxo NO-UNDO
    FIELD cdvencto LIKE crapvop.cdvencto
    FIELD dsvencto AS CHAR
    FIELD vlvencto AS DECI
    FIELD elemento AS INT.

DEF TEMP-TABLE tt-venc-fluxo NO-UNDO
    FIELD cdmodali AS CHAR FORMAT "x(02)"
    FIELD dsmodali LIKE gnmodal.dsmodali
    FIELD vlvencto LIKE crapvop.vlvencto.

DEF TEMP-TABLE tt-complemento NO-UNDO
    FIELD dtrefere AS CHAR
    FIELD qtopesfn LIKE crapopf.qtopesfn 
    FIELD qtifssfn LIKE crapopf.qtifssfn
    FIELD vlopesfn AS DECI
    FIELD vlopevnc AS DECI
    FIELD vlopeprj AS DECI
    FIELD vlopcoop AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD dtrefaux AS DATE
    FIELD vlopbase AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD dtrefer2 AS CHAR.
 
