/* .............................................................................

   Programa: Includes/cabrel132_4.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                     Ultima Atualizacao: 11/05/2006

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Montar o cabecalho dos relatorios com 132 colunas.

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
              "- REF."                   AT  56
              glb_dtmvtolt               AT  62 FORMAT "99/99/9999"
              rel_nmmodulo[rel_nrmodulo] AT  73 FORMAT "x(15)"
              glb_cdrelato[4]            AT  89 FORMAT "999"
              "/"                        AT  92
              glb_progerad               AT  93 FORMAT "x(03)"
              "EM"                       AT  97
              TODAY                      AT 100 FORMAT "99/99/9999"
              "AS"                       AT 111
              STRING(TIME,"HH:MM")       AT 114 FORMAT "x(5)"
              "HR PAG.:"                 AT 120
              PAGE-NUMBER(str_4)         AT 128 FORMAT "zzzz9"
              SKIP(1)
              glb_nmdestin[4]                   FORMAT "x(40)"
              SKIP(1)

         WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_cabrel132_4.
     END.
/* .......................................................................... */

