/* .............................................................................

   Programa: Fontes/acha_origem.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Dezembro/2004.                      Ultima atualizacao:   /  /    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para montar descricao com a origem do cheque.

   Alteracoes:

............................................................................. */

{ includes/var_online.i }

DEF INPUT  PARAM par_recid    AS RECID                               NO-UNDO.
DEF OUTPUT PARAM par_dspesqui AS CHAR                                NO-UNDO.

FIND craplcm WHERE RECID(craplcm) = par_recid NO-LOCK NO-ERROR.

IF   craplcm.cdagenci = 1      AND
     craplcm.cdbccxlt = 100    AND
     craplcm.nrdolote = 4500   THEN                             /*  Custodia  */
     DO:
         RUN proc_custodia.
     END.
ELSE
IF   craplcm.cdagenci = 1      AND
     craplcm.cdbccxlt = 100    AND
     craplcm.nrdolote = 4501   THEN                             /*  Desconto  */
     DO:
         RUN proc_desconto.
     END.

/* .......................................................................... */

PROCEDURE proc_custodia:



END PROCEDURE.

PROCEDURE proc_desconto:



END PROCEDURE.

/* .......................................................................... */

