/* ............................................................................

  Programa: cabrel.i
  Autor   : Gabriel
  Data    : Fevereiro/2011                      Ultima Atualizacao: 
  
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
            3. A 'Quantidade de colunas' no relatorio.
            
            Exemplo: { sistema/generico/includes/cabrel.i "11" "558" "132" }
                             
  Alteracoes:           
            20/12/2011 - retirado alimentacao da var "rel_nmdestin"
............................................................................. */

DEF VAR rel_nmrescop AS CHAR                                          NO-UNDO.
DEF VAR rel_nmempres AS CHAR  FORMAT "x(15)"                          NO-UNDO.
DEF VAR rel_nmrelato AS CHAR  FORMAT "x(40)"                          NO-UNDO.
DEF VAR rel_nmdestin AS CHAR                                          NO-UNDO.
DEF VAR rel_nrmodulo AS INTE                                          NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 5
                              INIT ["DEP. A VISTA   ","CAPITAL        ",
                                    "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]               NO-UNDO.



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
     ASSIGN rel_nmrelato = FILL("?",40)
            rel_nrmodulo = 5
            rel_nmdestin = FILL("?",40). 
ELSE
     ASSIGN rel_nmrelato = craprel.nmrelato
            rel_nrmodulo = craprel.nrmodulo.
            
FORM HEADER
     rel_nmrescop               AT   1 FORMAT "x(11)"
     "-"                        AT  13
     rel_nmrelato               AT  15 FORMAT "x(40)"
     "- REF."                   AT  56
     par_dtmvtolt               AT  62 FORMAT "99/99/9999"
     rel_nmmodulo[rel_nrmodulo] AT  73 FORMAT "x(15)"
     {2}                        AT  89 FORMAT "999" /* Cod. Relato */
     "/"                        AT  92
     "TEL"                      AT  93 
     "EM"                       AT  97
     TODAY                      AT 100 FORMAT "99/99/9999"
     "AS"                       AT 111
     STRING(TIME,"HH:MM")       AT 114 FORMAT "x(5)"
     "HR PAG.:"                 AT 120
     PAGE-NUMBER(str_1)         AT 128 FORMAT "zzzz9"
     SKIP(1)
     rel_nmdestin               FORMAT "x(40)"
     SKIP(1)
                                                                          
     WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH {3} FRAME f_cabrel.

VIEW STREAM str_1 FRAME f_cabrel.
          
/* ......................................................................... */
                   

