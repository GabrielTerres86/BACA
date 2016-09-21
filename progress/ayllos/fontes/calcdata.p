/* .............................................................................
   Programa: Fontes/calcdata.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/97                          Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular datas recebendo como parametro
               data para ser utilizada,
               se e para calcular meses(M) ou Anos (A)
               quantidade a frente.

............................................................................. */

DEF INPUT  PARAMETER aux_dtmvtolt AS DATE      NO-UNDO.
DEF INPUT  PARAMETER aux_qtmesano AS INTE      NO-UNDO.
DEF INPUT  PARAMETER aux_tpmesano AS CHAR      NO-UNDO.
DEF INPUT  PARAMETER aux_diaorigi AS INTE      NO-UNDO.
DEF OUTPUT PARAMETER aux_dtcalcul AS DATE      NO-UNDO.

DEF VAR  aux_contador AS INT                   NO-UNDO.
DEF VAR  aux_dtinicio AS DATE                  NO-UNDO.
DEF VAR  aux_dtfimqtd AS DATE                  NO-UNDO.
DEF VAR  aux_mesrefer AS INT                   NO-UNDO.
DEF VAR  aux_anorefer AS INT                   NO-UNDO.

IF  NOT CAN-DO("M,A",aux_tpmesano)  THEN
    DO:
        BELL.
        MESSAGE "TIPO DE PARAMETRO ERRADO".
        RETURN.
    END.

IF   aux_tpmesano = "M" AND aux_qtmesano > 11 THEN
     DO:
         BELL.
         MESSAGE "QUANTIDADE DE MESES DEVE ESTAR ENTRE 1 E 11".
         RETURN.
     END.

IF   aux_tpmesano = "A" THEN
     IF   DAY(aux_dtmvtolt) = 29  AND  MONTH(aux_dtmvtolt) = 2 THEN
          aux_dtcalcul =  DATE(03,01,YEAR(aux_dtmvtolt) + aux_qtmesano).
     ELSE
          aux_dtcalcul =  DATE(MONTH(aux_dtmvtolt),DAY(aux_dtmvtolt),
                                  YEAR(aux_dtmvtolt) + aux_qtmesano).

IF   aux_tpmesano = "M" THEN
     DO:
         ASSIGN aux_dtinicio = aux_dtmvtolt - DAY(aux_dtmvtolt)
                aux_mesrefer = MONTH(aux_dtmvtolt) + aux_qtmesano
                aux_anorefer = IF  aux_mesrefer > 12
                                   THEN 1
                                   ELSE 0
                aux_mesrefer = IF  aux_mesrefer > 12
                                   THEN aux_mesrefer - 12
                                   ELSE aux_mesrefer
                aux_dtfimqtd = DATE(aux_mesrefer,01,
                                    YEAR(aux_dtmvtolt) + aux_anorefer)
                aux_dtfimqtd = IF  aux_mesrefer = 2 AND
                                   DAY(aux_dtmvtolt) = 31
                                   THEN IF   YEAR(aux_dtfimqtd) MODULO 4 = 0
                                             THEN aux_dtfimqtd - 2
                                             ELSE aux_dtfimqtd - 3
                               ELSE
                               IF  aux_mesrefer = 2 AND DAY(aux_dtmvtolt) = 30
                                   THEN IF  YEAR(aux_dtfimqtd) MODULO 4 = 0
                                            THEN aux_dtfimqtd - 1
                                            ELSE aux_dtfimqtd - 2
                               ELSE
                                   aux_dtfimqtd - 1
                aux_dtcalcul = (aux_dtfimqtd - aux_dtinicio) +
                               aux_dtmvtolt.

     END.



/* .......................................................................... */
