/* .............................................................................

   Programa: Includes/taxcdia.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete                       Ultima Atualizacao: 11/12/2013
   Data    : Novembro/2003

   Dados referentes ao programa:                       

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela taxcdi.

   Alteracao : 07/07/2005 - Alimentado campo cdcooper da tabela craptrd (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               01/09/2006 - Usar a maior taxa CDI ou POUP(moeda tipo 8) +
                            22,5 maior percentual de IR (Magui).

               19/07/2007 - Melhora leitura do craptrd, chave nova (Magui).

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

   UPDATE tel_tpvlinfo tel_dtiniper WITH FRAME f_taxcdi.

   /*** Magui com uso da poupanca isso cai fora. No mesmo dia posso ter
        usado a poupanca e o cdi 
   FIND FIRST craptrd WHERE craptrd.cdcooper = glb_cdcooper   AND
                            craptrd.dtiniper = tel_dtiniper   NO-LOCK NO-ERROR.

   ASSIGN tel_txdatrtr = IF AVAILABLE craptrd THEN craptrd.vltrapli
                         ELSE 0.
 
   **************/
   /*** Magui podemos pegar o valor da poupanca e do cdi do crapmfx ***/
   FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper AND
                      crapmfx.dtmvtolt = tel_dtiniper AND
                      crapmfx.tpmoefix = 8 /* POUPANCA */
                      NO-LOCK NO-ERROR.
   ASSIGN tel_vlmoefix = IF AVAILABLE crapmfx THEN crapmfx.vlmoefix
                         ELSE 0.
   
   FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper AND
                      crapmfx.dtmvtolt = tel_dtiniper AND
                      crapmfx.tpmoefix = 16 /* CDI */
                      NO-LOCK NO-ERROR.
   ASSIGN tel_txdatrtr = IF AVAILABLE crapmfx THEN crapmfx.vlmoefix
                         ELSE 0.
   
   UPDATE tel_txdatrtr tel_vlmoefix WITH FRAME f_taxcdi
   
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

   IF   (tel_dtiniper < (glb_dtmvtolt - 60)) THEN
        DO:
            glb_cdcritic = 13.
            NEXT-PROMPT tel_dtiniper WITH FRAME f_taxcdi.
            NEXT.
        END.

   IF   (tel_txdatrtr = 0) THEN
        DO:
            glb_cdcritic = 185.
            NEXT-PROMPT tel_txdatrtr WITH FRAME f_taxcdi.
            NEXT.
        END.
    
   FIND FIRST craptrd WHERE craptrd.cdcooper = glb_cdcooper   AND
                            craptrd.dtiniper = tel_dtiniper   AND
                            craptrd.tptaxrda < 6              AND
                            craptrd.incalcul = 2              NO-LOCK NO-ERROR.
                       
   IF   AVAILABLE craptrd   THEN                     
        DO:
            IF   craptrd.vltrapli <> tel_txdatrtr   THEN
                 DO:
                     glb_cdcritic = 424.
                     NEXT-PROMPT tel_txdatrtr WITH FRAME f_taxcdi.
                     NEXT.
                 END.
        END.
   
   RUN fontes/calcdata.p (INPUT tel_dtiniper,INPUT 1,INPUT "M", INPUT 0,
                                OUTPUT aux_dtfimper).
         
   ASSIGN aux_dtmvtolt = tel_dtiniper
          aux_qtdiaute = 0.

   DO WHILE aux_dtmvtolt < aux_dtfimper:

      IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR
                  CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
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

   IF   NOT CAN-FIND(FIRST craptrd WHERE craptrd.cdcooper = glb_cdcooper AND
                                         craptrd.dtiniper = tel_dtiniper AND
                                         craptrd.tptaxrda < 6)
                                THEN
        DO:
            glb_cdcritic = 347.
            CLEAR FRAME f_taxcdi.
            NEXT.
        END.

   DO  aux_qtdtxtab = 1 TO aux_contador:
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

          FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper               AND
                             craptrd.dtiniper = tel_dtiniper               AND
                             craptrd.tptaxrda = aux_tptaxcdi[aux_qtdtxtab] AND
                             craptrd.incarenc = 0                          AND
                             craptrd.vlfaixas = aux_vlfaixas[aux_qtdtxtab]
                             EXCLUSIVE-LOCK NO-ERROR.
          VALIDATE craptrd.
          IF   NOT AVAILABLE craptrd   THEN
               DO: 
                   CREATE craptrd.
                   ASSIGN craptrd.tptaxrda = aux_tptaxcdi[aux_qtdtxtab]
                          craptrd.dtiniper = tel_dtiniper
                          craptrd.dtfimper = aux_dtfimper
                          craptrd.vlfaixas = aux_vlfaixas[aux_qtdtxtab]
                          craptrd.incarenc = 0
                          craptrd.incalcul = 0
                          craptrd.cdcooper = glb_cdcooper.
               END.           
           
          ASSIGN craptrd.qtdiaute = aux_qtdiaute
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
   
   RUN proc_crialog (INPUT " alterou").
   
END. /* DO WILE */ 

CLEAR FRAME f_taxcdi.

/* .......................................................................... */

