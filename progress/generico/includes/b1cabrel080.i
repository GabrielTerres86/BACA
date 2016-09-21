/* ............................................................................

  Programa: b1cabrel080.i
  Autor   : David
  Data    : Marco/2011                                Ultima Atualizacao: 21/10/2011
  
  Dados referente ao programa:
  
  Objetivo: Incluir o cabecalho em todas as paginas do relatorio desejado.
  
  NOTA    : Lembrar quando se da o OUTPUT TO VALUE de colocar tambem o 
            'PAGE-SIZE 84 PAGED'.
            O programa chamador devera ter OBRIGATORIAMENTE os seguintes campos
            declarados:
            
            par_cdcooper - Para realizar as leituras necessarias.
            par_dtmvtolt - Para incluir a data no cabecalho.
            
            Alem disso, a includes deve ser chamada com 3 parametros.
            1. O 'cdempres'.
            2. O 'Codigo do relatorio'. 
            
            Exemplo: { sistema/generico/includes/cabrel080.i "11" "558" }
                             
 Alteracoes: 
           21/10/2011 - Retirado as definicoes de variaveis
           (Rogerius Militão - DB1)
           20/12/2011 - substituido a descricao "PAG" por "PG" pois estourava
           o limite de 80 colunas e desconfigurava o cabecalho no relatorio e
           retirado onde alimentava a var "rel_nmdestin" pois no fonte antigo
           nao continha a mesma e acabava trazendo dados imcompativeis com
           o relatorio.
           
............................................................................. */

FIND crapcop WHERE crapcop.cdcooper = par_cdcooper   NO-LOCK NO-ERROR.

IF   NOT AVAIL crapcop    THEN
     rel_nmrescop = FILL ("?",11).
ELSE
     rel_nmrescop = crapcop.nmrescop.
     
FIND crapemp WHERE crapemp.cdcooper = par_cdcooper   AND
                   crapemp.cdempres = {1}            NO-LOCK NO-ERROR.
                   
IF   NOT AVAIL crapemp   THEN
     rel_nmempres = FILL("?",11).
ELSE  
     rel_nmempres = SUBSTR(crapemp.nmresemp,1,11).

FIND craprel WHERE craprel.cdcooper = par_cdcooper   AND
                   craprel.cdrelato = {2}            NO-LOCK NO-ERROR.
                       
IF   NOT AVAIL craprel   THEN
     ASSIGN rel_nmrelato = FILL("?",17)
            rel_nrmodulo = 1
            rel_nmdestin = FILL("?",40). 
ELSE
     ASSIGN rel_nmrelato = craprel.nmrelato
            rel_nrmodulo = craprel.nrmodulo.
     /*     No cabecalho antigo nao alimentava "nmdestin"
            rel_nmdestin = craprel.nmdestin. */
            
FORM HEADER
     rel_nmrescop               AT   1 FORMAT "x(11)"
     "-"                        AT  13
     rel_nmrelato               AT  15 FORMAT "x(16)" 
     "REF."                     AT  32
     par_dtmvtolt               AT  36 FORMAT "99/99/9999"
     {2}                        AT  47 FORMAT "999"
     "/"                        AT  50
     "TEL"                      AT  51 
     "-"                        AT  55
     TODAY                      AT  57 FORMAT "99/99/9999"
     STRING(TIME,"HH:MM")       AT  68 FORMAT "x(5)"
     "PG"                       AT  74
     PAGE-NUMBER(str_1)         AT  76 FORMAT "zzz9"
     SKIP(1)
     rel_nmdestin                      FORMAT "x(40)"
     SKIP(1)
     WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_cabrel.

VIEW STREAM str_1 FRAME f_cabrel.
          
/* ......................................................................... */
