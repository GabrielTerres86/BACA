/* .............................................................................

   Programa: Includes/taxesp2c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/96

   Dados referentes ao programa:              Ultima Atualizacao: 02/02/2006
   
   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela taxesp para RDCA2.

   Alteracoes: 02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

............................................................................. */

aux_indpostp = 1.

tel_vlfaixas = 0.

DISPLAY tel_vlfaixas WITH FRAME f_taxesp.
 
DO WHILE TRUE:

   UPDATE tel_vlfaixas WITH FRAME f_taxesp.

   ASSIGN aux_flgfaixa = NO.
   DO  aux_qtdtxtab = 1 TO aux_qtfaixas:
       IF   aux_tptaxrda[aux_qtdtxtab] = INPUT FRAME f_taxesp tel_tptaxesp AND
            aux_vlfaixas[aux_qtdtxtab] = INPUT FRAME f_taxesp tel_vlfaixas THEN
            DO:
                ASSIGN aux_flgfaixa = YES.
                LEAVE.
            END.
   END. 
   IF   NOT aux_flgfaixa   THEN 
        DO:
            ASSIGN glb_cdcritic = 773.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.
 
   LEAVE.

END.

FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper   AND
                   craptrd.dtiniper = tel_dtiniper   AND
                   craptrd.tptaxrda = tel_tptaxesp   AND
                   craptrd.incarenc = 0              AND
                   craptrd.vlfaixas = tel_vlfaixas 
                   USE-INDEX craptrd1                NO-LOCK NO-ERROR.

IF   AVAILABLE craptrd   THEN
     DO:
         ASSIGN  tel_dtfimper = craptrd.dtfimper
                 tel_qtdiaute = craptrd.qtdiaute
                 tel_txofimes = craptrd.txofimes
                 tel_txofidia = craptrd.txofidia
                 tel_txprodia = craptrd.txprodia
                 tel_dscalcul = IF   craptrd.incalcul = 0 THEN "NAO"
                                ELSE
                                     "SIM".

         DISPLAY tel_dtfimper tel_qtdiaute tel_txofimes
                 tel_txofidia tel_txprodia tel_dscalcul WITH FRAME f_taxesp.
     END.
ELSE
     DO:
         glb_cdcritic = 347.
         CLEAR FRAME f_taxesp.
         NEXT.
     END.

/* .......................................................................... */
