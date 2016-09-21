/* .............................................................................

   Programa: Includes/taxespc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/94

   Dados referentes ao programa:              Ultima Atualizacao: 02/02/2006
   
   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela taxesp.

   Alteracoes: 05/03/96 - Alterado para tratar tipo de taxa rda (Odair).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper   AND
                   craptrd.dtiniper = tel_dtiniper   AND
                   craptrd.tptaxrda = tel_tptaxesp   AND
                   craptrd.incarenc = 0              AND
                   craptrd.vlfaixas = 0
                   USE-INDEX craptrd1                NO-LOCK NO-ERROR.

IF   AVAILABLE craptrd   THEN
     DO:
         ASSIGN  tel_dtfimper = craptrd.dtfimper
                 tel_qtdiaute = craptrd.qtdiaute
                 tel_vlfaixas = 0
                 tel_txofimes = craptrd.txofimes
                 tel_txofidia = craptrd.txofidia
                 tel_txprodia = craptrd.txprodia
                 tel_dscalcul = IF   craptrd.incalcul = 0 THEN "NAO"
                                ELSE
                                     "SIM".

         DISPLAY tel_dtfimper tel_qtdiaute tel_vlfaixas
                 tel_txofimes tel_txofidia tel_txprodia tel_dscalcul
                 WITH FRAME f_taxesp.
     END.
ELSE
     DO:
         glb_cdcritic = 347.
         CLEAR FRAME f_taxesp.
         NEXT.
     END.

/* .......................................................................... */

