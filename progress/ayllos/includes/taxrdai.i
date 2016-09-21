/* .............................................................................

   Programa: Includes/taxrdai.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete                       Ultima Atualizacao: 19/07/2007
   Data    : Janeiro/2002

   Dados referentes ao programa:                       

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela taxrda.

   Alteracao : 23/09/2003 - Atualizar campo de T.R usada (Margarete).

               07/07/2005 - Alimentado campo cdcooper da tabela craptrd (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               19/07/2007 - Melhorar leitura craptrd, nova chave (Magui).
............................................................................. */

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   UPDATE tel_tpvlinfo tel_dtiniper tel_txdatrtr WITH FRAME f_taxrda
   EDITING:
           READKEY.
           IF   FRAME-FIELD = "tel_txdatrtr"   THEN
                IF   LASTKEY =  KEYCODE(".")   THEN
                      APPLY 44.
                ELSE
                      APPLY LASTKEY.
           ELSE
                APPLY LASTKEY.

   END.  /*  Fim do EDITING  */

   RUN fontes/calcdata.p (INPUT tel_dtiniper,INPUT 1,INPUT "M", INPUT 0,
                          OUTPUT aux_dtfimper).
         
   ASSIGN aux_dtmvtolt = tel_dtiniper
          aux_qtdiaute = 0.

   DO WHILE aux_dtmvtolt < aux_dtfimper:
      
      IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR
                  CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                                         crapfer.dtferiad = aux_dtmvtolt) THEN
                       .
      ELSE 
           aux_qtdiaute = aux_qtdiaute + 1.

      aux_dtmvtolt = aux_dtmvtolt + 1.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   (aux_dtfimper - tel_dtiniper) < 28 THEN
        DO:
            glb_cdcritic = 13.
            NEXT-PROMPT tel_dtiniper WITH FRAME f_taxrda.
            NEXT.
        END.
    
   IF   (aux_dtfimper - tel_dtiniper) > 35 THEN
        DO:
            glb_cdcritic = 13.
            NEXT-PROMPT tel_dtiniper WITH FRAME f_taxrda.
            NEXT.
        END.

   IF   CAN-FIND(FIRST craptrd WHERE
                       craptrd.cdcooper = glb_cdcooper AND
                       craptrd.dtiniper = tel_dtiniper AND
                       craptrd.tptaxrda < 6 USE-INDEX craptrd1) THEN

        DO:
            glb_cdcritic = 349.
            CLEAR FRAME f_taxrda.
            NEXT.
        END.

   DO  aux_qtdtxtab = 1 TO aux_contador:
       
       FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper                 AND
                          craptrd.dtiniper = tel_dtiniper                 AND
                          craptrd.tptaxrda = aux_tptaxrda[aux_qtdtxtab]   AND
                          craptrd.incarenc = 0                            AND
                          craptrd.vlfaixas = aux_vlfaixas[aux_qtdtxtab]   
                      NO-LOCK NO-ERROR.
    
       IF   AVAILABLE craptrd   THEN
            DO:
                ASSIGN glb_cdcritic = 349.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                NEXT.
            END.

      
       DO TRANSACTION ON ENDKEY UNDO, LEAVE:

          CREATE craptrd.
          ASSIGN craptrd.tptaxrda = aux_tptaxrda[aux_qtdtxtab]
                 craptrd.dtiniper = tel_dtiniper
                 craptrd.dtfimper = aux_dtfimper
                 craptrd.qtdiaute = aux_qtdiaute
                 craptrd.vlfaixas = aux_vlfaixas[aux_qtdtxtab]
                 craptrd.incarenc = 0
                 craptrd.incalcul = 0
                 craptrd.vltrapli = tel_txdatrtr
                 craptrd.cdcooper = glb_cdcooper
                 aux_vltxadic     = aux_txadical[aux_qtdtxtab].
   
          IF   tel_tpvlinfo  THEN /* OFICIAL */
               ASSIGN craptrd.txofimes = ROUND(((tel_txdatrtr + 100) * (1 + 
                                           (aux_vltxadic / 100)) - 100),6)  
                      craptrd.txofidia = 
                              ROUND(((EXP(1 + (craptrd.txofimes / 100),
                                              1 / aux_qtdiaute) - 1) * 100),6).
          ELSE /* PROJETADA */
               ASSIGN aux_txprodia     = ROUND(((tel_txdatrtr + 100) * (1 + 
                                             (aux_vltxadic / 100)) - 100),6)  
                      craptrd.txprodia = 
                              ROUND(((EXP(1 + (aux_txprodia / 100),
                                              1 / aux_qtdiaute) - 1) * 100),6).

 
          RELEASE craptrd.
      
       END. /* Fim da transacao */
   
   END. /* do aux_qtdtxtab */
   
END. /* DO WILE */ 

CLEAR FRAME f_taxrda.
HIDE FRAME f_taxrda.
/* .......................................................................... */

