/* .............................................................................
   
   Programa: b1wgen0008.p
   Autor   : Junior
   Data    : 31/10/2005                     Ultima atualizacao: 27/12/2007
   
   Dados referentes ao programa:

   Objetivo  : Calcular datas recebendo como parametro
               data para ser utilizada,
               se e para calcular meses(M) ou Anos (A),
               quantidade a frente.
               
               Adaptado do programa fontes/calcdata.p.
   
   Alteracoes: 19/05/2005 - Incluido codigo da cooperativa nas leituras das
                            tabelas (Diego).
                            
               27/12/2007 - Retirada dos FINDs crapcop e crapdat, pois este nao
                            estava sendo necessario (Julio)
   
............................................................................. */

DEF TEMP-TABLE tt-erro LIKE craperr.

DEF VAR aux_sequen   AS INTE NO-UNDO.
DEF VAR i-cod-erro   AS INTE NO-UNDO.
DEF VAR c-dsc-erro   AS CHAR NO-UNDO.

PROCEDURE calcdata:

    DEF INPUT        PARAM p-cdcooper      AS INTE.
    DEF INPUT        PARAM p-cod-agencia   AS INTE.
    DEF INPUT        PARAM p-nro-caixa     AS INTE.                     
    DEF INPUT        PARAM p-cod-operador  AS CHAR. 
    DEF INPUT        PARAM aux_dtmvtolt    AS DATE.
    DEF INPUT        PARAM aux_qtmesano    AS INTE.
    DEF INPUT        PARAM aux_tpmesano    AS CHAR.
    DEF INPUT        PARAM aux_diaorigi    AS INTE.
    
    DEF OUTPUT       PARAM aux_dtcalcul    AS DATE.
    DEF OUTPUT       PARAM TABLE FOR tt-erro.

    DEF VAR  aux_contador AS INT                   NO-UNDO.
    DEF VAR  aux_dtinicio AS DATE                  NO-UNDO.
    DEF VAR  aux_dtfimqtd AS DATE                  NO-UNDO.
    DEF VAR  aux_mesrefer AS INT                   NO-UNDO.
    DEF VAR  aux_anorefer AS INT                   NO-UNDO.

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
                                   IF  aux_mesrefer = 2 AND 
                                       DAY(aux_dtmvtolt) = 30
                                       THEN IF  YEAR(aux_dtfimqtd) MODULO 4 = 0
                                                THEN aux_dtfimqtd - 1
                                                ELSE aux_dtfimqtd - 2
                                   ELSE
                                       aux_dtfimqtd - 1
                    aux_dtcalcul = (aux_dtfimqtd - aux_dtinicio) + aux_dtmvtolt.

         END.

END PROCEDURE.

/* b1wgen0008.p */

/* ......................................................................... */

