

/* .............................................................................

   Programa: Includes/b1cabrel132_2.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jean Michel
   Data    : Outubro/2013                     Ultima Atualizacao: 00/00/0000 

   Dados referentes ao programa:
   
   Objetivo  : Montar o cabecalho dos relatorios com 132 colunas.

   Alteracoes: 
............................................................................. */

FIND crapcop WHERE crapcop.cdcooper = par_cdcooper   NO-LOCK NO-ERROR.

IF   NOT AVAIL crapcop    THEN
     rel_nmrescop = FILL ("?",11).
ELSE
     rel_nmrescop = crapcop.nmrescop.

FIND crapemp WHERE crapemp.cdcooper = par_cdcooper  AND
                   crapemp.cdempres = {1}   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapemp   THEN
     rel_nmempres = FILL("?",11).
ELSE
     rel_nmempres = SUBSTRING(crapemp.nmresemp,1,11).

IF   {2} > 0 THEN
     DO:
         FIND craprel WHERE craprel.cdcooper = par_cdcooper    AND 
                            craprel.cdrelato = {2} NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craprel   THEN
              ASSIGN rel_nmrelato    = FILL("?",40)
                     rel_nrmodulo    = 5
                     rel_nmdestin = FILL("?",40). 
         ELSE
              ASSIGN rel_nmrelato    = craprel.nmrelato
                     rel_nrmodulo    = craprel.nrmodulo
                     rel_nmdestin    = craprel.nmdestin.
                     

         FORM HEADER
              rel_nmrescop               AT   1 FORMAT "x(11)"
              "-"                        AT  13
              rel_nmrelato               AT  15 FORMAT "x(40)"
              "- REF."                   AT  56
              par_dtmvtolt               AT  62 FORMAT "99/99/9999"
              rel_nmmodulo[rel_nrmodulo] AT  73 FORMAT "x(15)"
              {2}                        AT  89 FORMAT "999"
              "/"                        AT  92
              "TEL"                      AT  93 
              "EM"                       AT  97
              TODAY                      AT 100 FORMAT "99/99/9999"
              "AS"                       AT 111
              STRING(TIME,"HH:MM")       AT 114 FORMAT "x(5)"
              "HR PAG.:"                 AT 120
              PAGE-NUMBER(str_2)         AT 128 FORMAT "zzzz9"
              SKIP(1)
              rel_nmdestin               FORMAT "x(40)"
              SKIP(1)
                             
         WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_cabrel132_2.

         VIEW STREAM str_2 FRAME f_cabrel132_2.

     END.
/* .......................................................................... */
