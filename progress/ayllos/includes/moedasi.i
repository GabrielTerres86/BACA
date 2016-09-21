/* .............................................................................

   Programa: Fontes/moedasi.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                       Ultima Atualizacao: 02/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela MOEDAS.

   Alteracoes: 06/07/2005 - Alimentado campo cdcooper da tabela crapmfx (Diego).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               16/11/2011 - Inclusão das chamadas "calculo_poupanca" e 
                            "atualiza_sol026" para calcular de forma automática 
                            a Taxa de Cardeneta de Poupança com base na TR
                            (Handrei - RKAM).
                          - Inclusão da chamada atualiza_tr para calcular a
                            taxa de juros nos emprestimos e cheque especial
                            (Isara - RKAM).
               
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)              
                
               03/02/2014 - Inlcusão do tratamento da nova taxa Selic(19) e
                            inlcusão de log (Jean Michel).
                            
               27/06/2014 - Ajuste no tratamento de critica (Jean Michel).
               
               16/07/2014 - Incluso Validate (Daniel)
               
               02/09/2014 - Cadastrar moedas somente para cooperativas ativas
                            (David).
                             
............................................................................. */

IF   CAN-FIND(crapmfx WHERE crapmfx.cdcooper = glb_cdcooper    AND
                            crapmfx.dtmvtolt = tel_dtmvtolt    AND
                            crapmfx.tpmoefix = tel_tpmoefix)   THEN
     DO:
         glb_cdcritic = 165.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_moedas.
         NEXT.
     END.

TRANS_1:
DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   IF tel_tpmoefix <> 19 AND tel_tpmoefix <> 21 THEN
    DO:
        CREATE crapmfx.
        ASSIGN crapmfx.dtmvtolt = tel_dtmvtolt
               crapmfx.tpmoefix = tel_tpmoefix
               crapmfx.cdcooper = glb_cdcooper.
        
        VALIDATE crapmfx.
    END.

   DO WHILE TRUE:

      UPDATE tel_vlmoefix WITH FRAME f_moedas

      EDITING:

               READKEY.
               IF   FRAME-FIELD = "tel_vlmoefix"   THEN
                    IF   LASTKEY =  KEYCODE(".")   THEN
                         APPLY 44.
                    ELSE
                         APPLY LASTKEY.
               ELSE
                    APPLY LASTKEY.

      END.

      IF tel_tpmoefix <> 11 AND tel_tpmoefix <> 19 AND tel_tpmoefix <> 21 THEN
        ASSIGN crapmfx.vlmoefix = tel_vlmoefix
               tel_vlmoefix     = 0.
      ELSE
        DO:
            IF tel_tpmoefix = 11 THEN
                DO:
                   ASSIGN aux_flgderro = FALSE.
                
                   FOR EACH crapcop WHERE crapcop.flgativo = TRUE NO-LOCK:
                
                       RUN sistema/generico/procedures/b1wgen0128.p 
                            PERSISTENT SET h-b1wgen0128.
                            
                       RUN poupanca IN h-b1wgen0128
                                         (INPUT crapcop.cdcooper,
                                          INPUT INPUT FRAME f_moedas tel_dtmvtolt,
                                          INPUT INPUT FRAME f_moedas tel_vlmoefix,
                                          OUTPUT aux_vlpoupan,
                                          OUTPUT par_dscritic).
                       
                       IF   RETURN-VALUE <> "OK" THEN
                            DO:
                                IF aux_vlpoupan = 0 AND par_dscritic = ? THEN
                                    DO:
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                            MESSAGE "ERRO AO INCLUIR A TR - COOP: "
                                                + STRING(crapcop.nmrescop).
                                            PAUSE 10 NO-MESSAGE.
                                           
                                            ASSIGN aux_flgderro = TRUE.
                                            LEAVE.
                                        END.   

                                        DELETE PROCEDURE h-b1wgen0128.
                                        UNDO TRANS_1, LEAVE.
                                        
                                    END.
                                ELSE
                                    DO:
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:      
                                            MESSAGE par_dscritic.
                                            PAUSE 10 NO-MESSAGE.
                                            
                                            ASSIGN aux_flgderro = TRUE.
                                            LEAVE.
                                        END.   

                                        DELETE PROCEDURE h-b1wgen0128.
                                        UNDO TRANS_1, LEAVE.
                                    END.
                            END.
                        
                       RUN atualiza_sol026 IN h-b1wgen0128 
                                         (INPUT crapcop.cdcooper,
                                          INPUT INPUT FRAME f_moedas tel_dtmvtolt,
                                          INPUT aux_vlpoupan).
                                                    
                       IF   RETURN-VALUE <> "OK" THEN
                            DO:
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    MESSAGE "ERRO AO INCLUIR A TR SOL026 - COOP: "
                                                + STRING(crapcop.nmrescop).
                                    PAUSE 10 NO-MESSAGE.
                                    
                                    ASSIGN aux_flgderro = TRUE.
                                    LEAVE.
                                END.

                                DELETE PROCEDURE h-b1wgen0128.
                                UNDO TRANS_1, LEAVE.
                            END.
    
                       IF  crapcop.cdcooper <> 3 THEN
                           DO:
                               RUN atualiza_tr IN h-b1wgen0128 
                                          (INPUT crapcop.cdcooper,
                                           INPUT INPUT FRAME f_moedas tel_dtmvtolt,
                                           INPUT INPUT FRAME f_moedas tel_vlmoefix).
                                                   
                               IF   RETURN-VALUE <> "OK" THEN
                                    DO:
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                            MESSAGE 
                                               "ERRO AO INCLUIR A TR TAXMES - COOP: "
                                               + STRING(crapcop.nmrescop).
                                            PAUSE 10 NO-MESSAGE.
                                          
                                            ASSIGN aux_flgderro = TRUE.
                                            LEAVE.
                                        END.

                                        DELETE PROCEDURE h-b1wgen0128.
                                        UNDO TRANS_1, LEAVE.
                                    END.    
                           END.
    
                       DELETE PROCEDURE h-b1wgen0128.
    
                   END.  /* Fim do FOR EACH */  
                END.
            ELSE
                DO:
                    FOR EACH crapcop WHERE crapcop.flgativo = TRUE NO-LOCK:
                        CREATE crapmfx.
                        ASSIGN crapmfx.cdcooper = crapcop.cdcooper
                               crapmfx.dtmvtolt = tel_dtmvtolt
                               crapmfx.tpmoefix = tel_tpmoefix
                               crapmfx.vlmoefix = tel_vlmoefix.
                        VALIDATE crapmfx.
                    END.
                END.    
        END.     
      
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

END. /* Fim da transacao */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR NO-WAIT.

ASSIGN aux_msgdolog = "Incluida moeda do tipo " + STRING(tel_tpmoefix) + " para data: " + STRING(tel_dtmvtolt) + ", com valor de: " + STRING(crapmfx.vlmoefix).
   
UNIX SILENT VALUE ("echo "      +   STRING(glb_dtmvtolt,"99/99/9999")     +
                  " - "        +   STRING(TIME,"HH:MM:SS")               +
                  " Operador: " + glb_cdoperad + " --- "                 +
                  aux_msgdolog                                           +
                  " >> /usr/coop/" + TRIM(crapcop.dsdircop)              + "/log/moedas.log").

RELEASE crapmfx.

IF   crapmfx.tpmoefix = 11 OR crapmfx.tpmoefix = 19 OR crapmfx.tpmoefix = 21 THEN
     DO:
         IF   aux_flgderro = FALSE                AND
              KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
              DO:
                  MESSAGE "TAXA CADASTRADA COM SUCESSO EM TODAS AS COOP.".
                  PAUSE 10 NO-MESSAGE.
              END.
         ELSE
              DO:
                  MESSAGE "TAXA NAO CADASTRADA.".
                  PAUSE 10 NO-MESSAGE.
              END.
     END.


IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
    NEXT.

CLEAR FRAME f_moedas NO-PAUSE.

/* .......................................................................... */
