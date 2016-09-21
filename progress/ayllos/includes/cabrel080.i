/* .............................................................................

   Programa: Includes/cabrel080.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                     Ultima Atualizacao: 11/05/2006

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Montar o cabecalho dos relatorios com 80 colunas.

   Alteracoes: 20/03/1998 - Tratamento para milenio e troca para V8 (Margarete).
   
               03/01/2002 - Incluir destino (Margarete).

               11/05/2004 - Incluir numero do programa gerador (Margarete).
               
               23/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               11/05/2006 - Substituida variavel rel_nmempres por glb_nmrescop
                            no FORM HEADER (Diego).
............................................................................. */

FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper  AND
                   crapemp.cdempres = glb_cdempres  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapemp   THEN
     rel_nmempres = FILL("?",11).
ELSE
     rel_nmempres = SUBSTRING(crapemp.nmresemp,1,11).

FIND craprel WHERE craprel.cdcooper = glb_cdcooper  AND
                   craprel.cdrelato = glb_cdrelato  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craprel   THEN
     ASSIGN rel_nmrelato = FILL("?",17)
            rel_nrmodulo = 5.
ELSE
     ASSIGN rel_nmrelato = craprel.nmrelato
            rel_nrmodulo = craprel.nrmodulo.

FORM HEADER

     glb_nmrescop               AT   1 FORMAT "x(11)"
     "-"                        AT  13
     rel_nmrelato               AT  15 FORMAT "x(17)"
     "REF"                      AT  33
     glb_dtmvtolt               AT  36 FORMAT "99/99/9999"
     glb_cdrelato               AT  47 FORMAT "999"
     "/"                        AT  50
     glb_progerad               AT  51 FORMAT "999"
     "-"                        AT  55
     TODAY                      AT  57 FORMAT "99/99/9999"
     STRING(TIME,"HH:MM")       AT  68 FORMAT "x(5)"
     "PAG:"                     AT  74
     PAGE-NUMBER                AT  78 FORMAT "zz9"
     SKIP(1)
     glb_nmdestin                      FORMAT "x(40)"
     SKIP(1)

WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_cabrel080.

/* .......................................................................... */

