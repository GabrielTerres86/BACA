/* .............................................................................

   Programa: Includes/cabrel080_4.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                     Ultima Atualizacao: 11/05/2006

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Montar o cabecalho dos relatorios com 80 colunas.

   Alteracoes: 20/03/1998 - Tratamento para milenio e troca para V8 (Margarete).

               04/01/2002 - Incluir destino (Margarete).

               11/05/2004 - Incluir nome do programa gerador (Margarete).
               
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               11/05/2006 - Substituida variavel rel_nmresemp por glb_nmrescop
                            no FORM HEADER (Diego).
               
............................................................................. */

FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper  AND
                   crapemp.cdempres = glb_cdempres  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapemp   THEN
     rel_nmresemp = FILL("?",11).
ELSE
     rel_nmresemp = SUBSTRING(crapemp.nmresemp,1,11).

IF   glb_cdrelato[4] > 0   THEN
     DO:
         FIND craprel WHERE craprel.cdcooper = glb_cdcooper     AND
                            craprel.cdrelato = glb_cdrelato[4]  
                            NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craprel   THEN
              ASSIGN rel_nmrelato[4] = FILL("?",17)
                     rel_nrmodulo    = 1.
         ELSE
              ASSIGN rel_nmrelato[4] = craprel.nmrelato
                     rel_nrmodulo    = craprel.nrmodulo.

         FORM HEADER

              glb_nmrescop               AT   1 FORMAT "x(11)"
              "-"                        AT  13
              rel_nmrelato[4]            AT  15 FORMAT "x(16)"
              "REF."                     AT  32
              glb_dtmvtolt               AT  36 FORMAT "99/99/9999"
              glb_cdrelato[4]            AT  47 FORMAT "999"
              "/"                        AT  50
              glb_progerad               AT  51 FORMAT "x(03)"
              "-"                        AT  55
              TODAY                      AT  57 FORMAT "99/99/9999"
              STRING(TIME,"HH:MM")       AT  68 FORMAT "x(5)"
              "PAG:"                     AT  74
              PAGE-NUMBER(str_4)         AT  78 FORMAT "zz9"
              SKIP(1)
              glb_nmdestin[4]                   FORMAT "x(40)"
              SKIP(1)

         WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_cabrel080_4.

     END.

/* .......................................................................... */

