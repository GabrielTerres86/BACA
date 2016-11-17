/* .............................................................................

   Programa: Includes/taxesp2e.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/96                         Ultima atualizacao: 22/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela taxesp para RDCA2.

   Alteracoes: 02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
   
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                            b1wgen9999.p procedure acha-lock, que identifica qual 
                            é o usuario que esta prendendo a transaçao. (Vanessa)

............................................................................. */

aux_indpostp = 1.

tel_vlfaixas = 0.

DISPLAY tel_vlfaixas WITH FRAME f_taxesp.

DO WHILE TRUE :

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

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 5:

       FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper   AND
                          craptrd.dtiniper = tel_dtiniper   AND
                          craptrd.tptaxrda = tel_tptaxesp   AND
                          craptrd.incarenc = 0              AND
                          craptrd.vlfaixas = tel_vlfaixas
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craptrd   THEN
            IF   LOCKED craptrd   THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptrd),
                    					 INPUT "banco",
                    					 INPUT "craptrd",
                    					 OUTPUT par_loginusr,
                    					 OUTPUT par_nmusuari,
                    					 OUTPUT par_dsdevice,
                    					 OUTPUT par_dtconnec,
                    					 OUTPUT par_numipusr).
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_dadosusr = 
                    "077 - Tabela sendo alterada p/ outro terminal.".
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 3 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                    			  " - " + par_nmusuari + ".".
                    
                    HIDE MESSAGE NO-PAUSE.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 5 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    glb_cdcritic = 0.
                    NEXT.
                 END.
           ELSE
                 DO:
                     glb_cdcritic = 347.
                     CLEAR FRAME f_taxesp.
                     LEAVE.
                 END.
       ELSE
            DO:
                aux_contador = 0.
                
                IF   craptrd.incalcul > 0   THEN
                     glb_cdcritic = 424.
                
                ASSIGN tel_dtfimper = craptrd.dtfimper
                       tel_qtdiaute = craptrd.qtdiaute
                       tel_txofimes = craptrd.txofimes
                       tel_txofidia = craptrd.txofidia
                       tel_txprodia = craptrd.txprodia
                       tel_dscalcul = IF   craptrd.incalcul = 0  THEN
                                           "NAO"
                                      ELSE
                                           "SIM".

                DISPLAY tel_dtfimper tel_qtdiaute tel_vlfaixas
                        tel_txofimes tel_txofidia tel_txprodia tel_dscalcul
                        WITH FRAME f_taxesp.

                LEAVE.
            END.
   END.

   IF   (aux_contador <> 0 OR glb_cdcritic <> 0 )  THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      glb_cdcritic = 0.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   DELETE craptrd.

END. /* Fim da transacao */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_taxesp NO-PAUSE.

/* .......................................................................... */

