/* .............................................................................

   Programa: Includes/cabrel234_4.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                     Ultima Atualizacao: 11/05/2006

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Montar o cabecalho dos relatorios com 234 colunas.

   Alteracoes: 20/03/1998 - Tratamento para milenio e troca para V8 (Margarete).

               04/01/2002 - Incluir destino (Margarete).

               11/05/2004 - Incluir numero do programa gerador (Margarete).
               
               03/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               11/05/2006 - Substituida variavel rel_nmempres por glb_nmrescop
                            no FORM HEADER (Diego).
               
............................................................................. */

FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper  AND
                   crapemp.cdempres = glb_cdempres  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapemp   THEN
     rel_nmempres = FILL("?",11).
ELSE
     rel_nmempres = SUBSTRING(crapemp.nmresemp,1,11).

IF   glb_cdrelato[4] > 0 THEN
     DO:
         FIND craprel WHERE craprel.cdcooper = glb_cdcooper    AND
                            craprel.cdrelato = glb_cdrelato[4] NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craprel   THEN
              ASSIGN rel_nmrelato[4] = FILL("?",40)
                     rel_nrmodulo    = 5.
         ELSE
              ASSIGN rel_nmrelato[4] = craprel.nmrelato
                     rel_nrmodulo    = craprel.nrmodulo.

         FORM HEADER

              glb_nmrescop               AT   1 FORMAT "x(11)"
              "-"                        AT  13
              rel_nmrelato[4]            AT  15 FORMAT "x(40)"
              "- REF."                   AT 106
              glb_dtmvtolt               AT 113 FORMAT "99/99/9999"
              rel_nmmodulo[rel_nrmodulo] AT 124 FORMAT "x(15)"
              glb_cdrelato[4]            AT 191 FORMAT "999"
              "/"                        AT 194
              glb_progerad               AT 195 FORMAT "x(03)"
              "EM"                       AT 199
              TODAY                      AT 202 FORMAT "99/99/9999"
              "AS"                       AT 213
              STRING(TIME,"HH:MM")       AT 216 FORMAT "x(5)"
              "HR PAG.:"                 AT 222
              PAGE-NUMBER(str_4)         AT 230 FORMAT "zzzz9"
              SKIP(1)
              glb_nmdestin[4]                   FORMAT "x(40)"
              SKIP(1)

         WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 234 FRAME f_cabrel234_4.
     END.
/* .......................................................................... */

