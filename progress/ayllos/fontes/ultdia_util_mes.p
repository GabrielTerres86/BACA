/* .............................................................................
   Programa: Fontes/ultdia_util_mes.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Marco/2006                      Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular o ultimo dia util do mes solicitado. 

............................................................................. */

{ includes/var_batch.i }
DEF INPUT  PARAMETER aux_dtmvtoan AS DATE      NO-UNDO.
DEF OUTPUT PARAMETER aux_dtcalcul AS DATE      NO-UNDO.

ASSIGN aux_dtcalcul = ((DATE(MONTH(aux_dtmvtoan),28,YEAR(aux_dtmvtoan)) +
                                   4) - DAY(DATE(MONTH(aux_dtmvtoan),28,
                                                  YEAR(aux_dtmvtoan)) + 4)).

DO WHILE TRUE:
   IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtcalcul)))    OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                               crapfer.dtferiad = aux_dtcalcul)   THEN
        DO:
            aux_dtcalcul = aux_dtcalcul - 1.
            NEXT.
        END.
   LEAVE.
END.  /*  Fim do DO WHILE TRUE  */

