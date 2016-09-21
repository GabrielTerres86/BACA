/* .............................................................................

   Programa: Includes/taxcdii.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete                       Ultima Atualizacao: 11/12/2013
   Data    : Novembro/2003

   Dados referentes ao programa:                       

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela taxcdi.

   Alteracao : 07/07/2005 - Alimentado campo cdcooper da tabela craptrd (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               01/09/2006 - Usar a maior taxa CDI ou POUP(moeda tipo 8) +
                            22,5 maior percentual de IR (Magui).

               19/07/2007 - Melhorada leitura craptrd, chave nova (Magui).
               
               19/03/2009 - Incluido log (proc_crialog) (Fernando).
               
               11/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
............................................................................. */

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   UPDATE tel_tpvlinfo tel_dtiniper tel_txdatrtr tel_vlmoefix
          WITH FRAME f_taxcdi
   EDITING:
           READKEY.
           IF   FRAME-FIELD = "tel_txdatrtr"   THEN
                IF   LASTKEY =  KEYCODE(".")   THEN
                      APPLY 44.
                ELSE
                      APPLY LASTKEY.
           ELSE 
           IF   FRAME-FIELD = "tel_vlmoefix"   THEN
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
                                         crapfer.dtferiad = aux_dtmvtolt) 
                  THEN
                   .    
      ELSE 
           aux_qtdiaute = aux_qtdiaute + 1.

      aux_dtmvtolt = aux_dtmvtolt + 1.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   (aux_dtfimper - tel_dtiniper) < 28 THEN
        DO:
            glb_cdcritic = 13.
            NEXT-PROMPT tel_dtiniper WITH FRAME f_taxcdi.
            NEXT.
        END.
    
   IF   (aux_dtfimper - tel_dtiniper) > 35 THEN
        DO:
            glb_cdcritic = 13.
            NEXT-PROMPT tel_dtiniper WITH FRAME f_taxcdi.
            NEXT.
        END.

   IF   CAN-FIND(FIRST craptrd WHERE craptrd.cdcooper = glb_cdcooper  AND
                                     craptrd.dtiniper = tel_dtiniper  AND
                                     craptrd.tptaxrda < 6
                                     USE-INDEX craptrd1) THEN
        DO:
            glb_cdcritic = 349.
            CLEAR FRAME f_taxcdi.
            NEXT.
        END.

   DO  aux_qtdtxtab = 1 TO aux_contador:
       
       FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper                 AND
                          craptrd.dtiniper = tel_dtiniper                 AND
                          craptrd.tptaxrda = aux_tptaxcdi[aux_qtdtxtab]   AND
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
          /*** Magui como eles cadastram a oficial e a projetada e a poupanca
               so existe uma preciso do find assim, pensar nisso antes
               de muda ***/
          FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper AND
                             crapmfx.dtmvtolt = tel_dtiniper AND
                             crapmfx.tpmoefix = 16 /* CDI */
                             NO-ERROR.
          IF   NOT AVAILABLE crapmfx   THEN
               DO:
                   CREATE crapmfx.
                   ASSIGN crapmfx.cdcooper = glb_cdcooper 
                          crapmfx.dtmvtolt = tel_dtiniper 
                          crapmfx.tpmoefix = 16.
               END.               
          ASSIGN crapmfx.vlmoefix = tel_txdatrtr.
          VALIDATE crapmfx.

          FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper AND
                             crapmfx.dtmvtolt = tel_dtiniper AND
                             crapmfx.tpmoefix = 8 /* POUPANCA */
                             NO-ERROR.
          
          IF   NOT AVAILABLE crapmfx   THEN
               DO:
                   CREATE crapmfx.
                   ASSIGN crapmfx.cdcooper = glb_cdcooper 
                          crapmfx.dtmvtolt = tel_dtiniper 
                          crapmfx.tpmoefix = 8.
               END.               
          ASSIGN crapmfx.vlmoefix = tel_vlmoefix.
          VALIDATE crapmfx.

          CREATE craptrd.
          ASSIGN craptrd.tptaxrda = aux_tptaxcdi[aux_qtdtxtab]
                 craptrd.dtiniper = tel_dtiniper
                 craptrd.dtfimper = aux_dtfimper
                 craptrd.qtdiaute = aux_qtdiaute
                 craptrd.vlfaixas = aux_vlfaixas[aux_qtdtxtab]
                 craptrd.incarenc = 0
                 craptrd.incalcul = 0
                 craptrd.cdcooper = glb_cdcooper
                 aux_vltxadic     = aux_txadical[aux_qtdtxtab].

          RUN fontes/calctaxa_poupanca.p (INPUT  aux_qtdiaute,
                                          INPUT  tel_vlmoefix,
                                          OUTPUT aux_txmespop,
                                          OUTPUT aux_txdiapop).
                                                          
          IF   tel_tpvlinfo  THEN /* OFICIAL */
               ASSIGN craptrd.txofimes = ROUND(((tel_txdatrtr * aux_vltxadic) 
                                                 / 100),6)  
                      craptrd.txofidia = 
                              ROUND(((EXP(1 + (craptrd.txofimes / 100),
                                              1 / aux_qtdiaute) - 1) * 100),6)
                      craptrd.vltrapli = IF craptrd.txofimes < aux_txmespop
                                         THEN tel_vlmoefix
                                         ELSE tel_txdatrtr
                      craptrd.txofimes = IF craptrd.txofimes < aux_txmespop
                                         THEN aux_txmespop 
                                         ELSE craptrd.txofimes
                      craptrd.txofidia = IF craptrd.txofidia < aux_txdiapop
                                         THEN aux_txdiapop
                                         ELSE craptrd.txofidia.
          ELSE /* PROJETADA */
               ASSIGN aux_txprodia     = ROUND(((tel_txdatrtr * aux_vltxadic)
                                              / 100),6)  
                      craptrd.txprodia = 
                              ROUND(((EXP(1 + (aux_txprodia / 100),
                                              1 / aux_qtdiaute) - 1) * 100),6)
                      craptrd.vltrapli = IF craptrd.txprodia < aux_txdiapop
                                         THEN tel_vlmoefix
                                         ELSE tel_txdatrtr
                      craptrd.txprodia = IF craptrd.txprodia < aux_txdiapop
                                         THEN aux_txdiapop
                                         ELSE craptrd.txprodia.     

          RELEASE craptrd.
      
       END. /* Fim da transacao */
   
   END. /* do aux_qtdtxtab */
   
   RUN proc_crialog (INPUT " incluiu").
   
END. /* DO WILE */ 

CLEAR FRAME f_taxcdi.
HIDE FRAME f_taxcdi.
/* .......................................................................... */

