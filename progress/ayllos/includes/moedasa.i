/* .................................................................................

   Programa: Includes/moedasa.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                           Ultima alteracao: 03/11/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela MOEDAS.

   Alteracoes: 21/05/97 - Alterado para permitir alteracoes no tipo de moeda 3,
                          4 e 5 (Deborah).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               16/11/2011 - Inclusão das chamadas "calculo_poupanca" e 
                            "atualiza_sol026" para calcular de forma automática 
                            a Taxa de Cardeneta de Poupança com base na TR
                            (Handrei - RKAM).
                          - Inclusão da chamada atualiza_tr para calcular a
                            taxa de juros nos emprestimos e cheque especial
                            (Isara - RKAM).
                            
               03/02/2009 - Inclusão da gravação de log quando houver alteração,
                            inlcusao do tratamento p/ taxa selic (19) (Jean Michel).
                            
               26/02/2014 - Inclusao da procedure atualiza_taxa_poupanca (Jean Michel).
               
               27/06/2014 - Ajuste no tratamento de critica (Jean Michel).
               
               02/09/2014 - Cadastrar moedas somente para cooperativas ativas
                            (David).
                            
               03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

               08/12/2016 - P341-Automatização BACENJUD - Realizar a validação 
			                do departamento pelo código do mesmo (Renato Darosci)
.................................................................................... */
DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


TRANS_1:
DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:
       
       FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper   AND
                          crapmfx.dtmvtolt = tel_dtmvtolt   AND
                          crapmfx.tpmoefix = tel_tpmoefix
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crapmfx   THEN
            IF   LOCKED crapmfx   THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapmfx),
                    					 INPUT "banco",
                    					 INPUT "crapmfx",
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
                    
                    glb_cdcritic = 77.
                    NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 211.
                     CLEAR FRAME f_moedas.
                     LEAVE.
                 END.
       ELSE
            DO:
                aux_contador = 0.
                LEAVE.
            END.
   END.

   IF   aux_contador <> 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   IF   (tel_tpmoefix = 11 OR tel_tpmoefix = 19 OR tel_tpmoefix = 21) AND
        glb_cdcooper <> 3  THEN
        DO:
            BELL.
            MESSAGE "Moeda alterada somente na Central.".
            NEXT.
        END.

   IF tel_tpmoefix = 11 OR tel_tpmoefix = 19 THEN
        DO:
            IF   MONTH(tel_dtmvtolt) <> MONTH(glb_dtmvtolt) THEN
                 DO:
                     BELL.
                     MESSAGE "Nao e possivel alterar do mes anterior.".
                     NEXT.
                 END.  
        END.
   
   
   IF   tel_tpmoefix = 3   OR 
        tel_tpmoefix = 4   OR 
        tel_tpmoefix = 5   OR
        tel_tpmoefix = 11  OR
        tel_tpmoefix = 19  OR
        tel_tpmoefix = 21  THEN
        .
   ELSE
        IF   tel_dtmvtolt < glb_dtmvtolt THEN
             IF   glb_cddepart <> 20 THEN   /* TI */
                  DO:
                      glb_cdcritic = 212.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      NEXT.
                  END.

   ASSIGN tel_vlmoefix = crapmfx.vlmoefix.

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
        
        /* Escreve mensagem de log com alteração */
              
        IF  crapmfx.vlmoefix <> tel_vlmoefix THEN
            ASSIGN aux_msgdolog = "Valor da moeda " + STRING(tel_tpmoefix) + " para data: " + STRING(tel_dtmvtolt,"99/99/9999") + " foi alterado de: " + STRING(DEC(crapmfx.vlmoefix)) + " para " + STRING(DEC(tel_vlmoefix)).
            
        UNIX SILENT VALUE ("echo "      +   STRING(glb_dtmvtolt,"99/99/9999")     +
                           " - "        +   STRING(TIME,"HH:MM:SS")               +
                           " Operador: " + glb_cdoperad + " --- "                 +
                           aux_msgdolog                                           +
                           " >> /usr/coop/" + TRIM(crapcop.dsdircop)              + "/log/moedas.log").

        IF  crapmfx.tpmoefix <> 11 AND crapmfx.tpmoefix <> 19 AND
            crapmfx.tpmoefix <> 21 THEN 
            ASSIGN crapmfx.vlmoefix = tel_vlmoefix
                   tel_vlmoefix     = 0.
      
        /***** Calcula a Poupança apos fornecer o valor da Taxa da TR ****/
        IF  crapmfx.tpmoefix = 11 THEN 
            DO:
                ASSIGN aux_flgderro = FALSE
                       par_dscritic = ?.
                
                FOR EACH crapcop WHERE crapcop.flgativo = TRUE NO-LOCK:
                    
                    FIND b-crapmfx WHERE b-crapmfx.cdcooper = crapcop.cdcooper AND
                                         b-crapmfx.dtmvtolt = tel_dtmvtolt     AND
                                         b-crapmfx.tpmoefix = crapmfx.tpmoefix 
                                         EXCLUSIVE-LOCK NO-ERROR.

                    IF NOT AVAIL b-crapmfx THEN
                        DO:
                            IF crapmfx.tpmoefix = 11 THEN
                                DO:
                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        MESSAGE "ERRO AO ALTERAR A TR - COOP: "
                                        + STRING(crapcop.nmrescop).
            
                                        PAUSE 10 NO-MESSAGE.
                                        LEAVE.
                                    END.
                                END.
                                  
                            ASSIGN aux_flgderro = TRUE.
                            UNDO TRANS_1, LEAVE.  
                        END.
                    
                    ASSIGN b-crapmfx.vlmoefix = tel_vlmoefix.
                    
                    RUN atualiza_taxa_poupanca(INPUT crapcop.cdcooper,
                                               INPUT tel_dtmvtolt,
                                              OUTPUT par_dscritic).
                    
                    /* Verifica se ocorreu alguma critica */
                    IF RETURN-VALUE <> "OK" THEN
                       DO:  
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE par_dscritic.
                                PAUSE 10 NO-MESSAGE.
                                LEAVE.
                            END.

                            ASSIGN aux_flgderro = TRUE.
                            UNDO TRANS_1, LEAVE.  
                    END.

                END.  /* Fim do FOR EACH */  
                
            END.
        ELSE 
        IF  crapmfx.tpmoefix = 19 OR crapmfx.tpmoefix = 21 THEN
            DO:
                ASSIGN aux_flgderro = FALSE.
                
                FOR EACH crapcop WHERE crapcop.flgativo = TRUE NO-LOCK:
                                
                    FIND b-crapmfx WHERE b-crapmfx.cdcooper = crapcop.cdcooper AND
                                         b-crapmfx.dtmvtolt = tel_dtmvtolt     AND
                                         b-crapmfx.tpmoefix = crapmfx.tpmoefix 
                                         EXCLUSIVE-LOCK NO-ERROR.

                    IF  NOT AVAIL b-crapmfx  THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                IF crapmfx.tpmoefix = 19 THEN
                                    MESSAGE "ERRO AO ALTERAR A SELIC Meta - COOP: "
                                            + STRING(crapcop.nmrescop).
                                ELSE
                                    MESSAGE "ERRO AO ALTERAR O IPCA - COOP: "
                                            + STRING(crapcop.nmrescop).
    
                                PAUSE 10 NO-MESSAGE.
                                LEAVE.
                            END.

                            ASSIGN aux_flgderro = TRUE.
                            UNDO TRANS_1, LEAVE.  
                        END.
                
                    ASSIGN b-crapmfx.vlmoefix = tel_vlmoefix.  

                END.

                IF  crapmfx.tpmoefix = 19 THEN
                    DO:
                        FIND b-crapmfx WHERE b-crapmfx.cdcooper = glb_cdcooper AND
                                             b-crapmfx.dtmvtolt = tel_dtmvtolt AND
                                             b-crapmfx.tpmoefix = 11
                                             NO-LOCK NO-ERROR NO-WAIT.

                        IF  AVAIL b-crapmfx THEN
                            DO:
                                FOR EACH crapcop WHERE crapcop.flgativo = TRUE
                                                       NO-LOCK:
                                    
                                    RUN atualiza_taxa_poupanca(INPUT crapcop.cdcooper,
                                                               INPUT tel_dtmvtolt,
                                                              OUTPUT par_dscritic).
                                    
                                    /* Verifica se ocorreu alguma critica */
                                    IF RETURN-VALUE <> "OK" THEN
                                       DO:
                                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                MESSAGE par_dscritic.
                                                PAUSE 10 NO-MESSAGE.
                                                LEAVE.
                                            END.
                
                                            ASSIGN aux_flgderro = TRUE.
                                            UNDO TRANS_1, LEAVE.  
                                       END.
                
                                END.  /* Fim do FOR EACH */  
                            END.
                    END.
            END.
      
        LEAVE.

   END.

END. /* Fim da transacao */

RELEASE crapmfx.
RELEASE b-crapmfx.

IF   crapmfx.tpmoefix = 11 OR crapmfx.tpmoefix = 19 OR crapmfx.tpmoefix = 21 THEN
     DO:
        
         IF   aux_flgderro = FALSE                AND
              KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
              DO:
                  MESSAGE "TAXA ALTERADA COM SUCESSO EM TODAS AS COOP.".
                  PAUSE 10 NO-MESSAGE.
              END.
         ELSE
              DO:
                  MESSAGE "TAXA NAO ALTERADA.".
                  PAUSE 10 NO-MESSAGE.
              END.
     END.


IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_moedas NO-PAUSE.


PROCEDURE atualiza_taxa_poupanca:

    DEFINE INPUT PARAM p_cdcooper AS INTEGER NO-UNDO.
    DEFINE INPUT PARAM p_dtmvtolt AS DATE    NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic AS CHAR NO-UNDO.

    DEF VAR aux_vlpoupan AS DECIMAL DECIMALS 8 NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = p_cdcooper NO-LOCK NO-ERROR NO-WAIT.

    FIND crapmfx WHERE crapmfx.cdcooper = p_cdcooper   AND
                       crapmfx.dtmvtolt = p_dtmvtolt   AND
                       crapmfx.tpmoefix = 11
                       NO-LOCK NO-ERROR NO-WAIT.
                           
    RUN sistema/generico/procedures/b1wgen0128.p 
                            PERSISTENT SET h-b1wgen0128.

    RUN poupanca IN h-b1wgen0128
                (INPUT p_cdcooper,
                 INPUT crapmfx.dtmvtolt,
                 INPUT crapmfx.vlmoefix,
                OUTPUT aux_vlpoupan,
                OUTPUT par_dscritic).
    
    IF   RETURN-VALUE <> "OK" THEN
        DO:
            IF aux_vlpoupan = 0 AND par_dscritic = ? THEN
                DO:
                    MESSAGE "ERRO AO INCLUIR A TR - COOP: "
                        + STRING(crapcop.nmrescop).
                    PAUSE 10 NO-MESSAGE.
                END.
            ELSE
                DO:
                    MESSAGE par_dscritic.
                    PAUSE 10 NO-MESSAGE.
                END.
        END.
    
    RUN atualiza_sol026 IN h-b1wgen0128
                       (INPUT p_cdcooper,
                        INPUT p_dtmvtolt,
                        INPUT aux_vlpoupan).
                                
    IF   RETURN-VALUE <> "OK" THEN
        DO:
            MESSAGE "ERRO AO INCLUIR A TR SOL026 - COOP: "
                    + STRING(crapcop.nmrescop).
            PAUSE 10 NO-MESSAGE.                  
        END.
    
    IF  crapcop.cdcooper <> 3 THEN
       DO:
           RUN atualiza_tr IN h-b1wgen0128
                          (INPUT crapmfx.cdcooper,
                           INPUT crapmfx.dtmvtolt,
                           INPUT crapmfx.vlmoefix).
                               
           IF   RETURN-VALUE <> "OK" THEN
                DO:
                    MESSAGE "ERRO AO INCLUIR A TR TAXMES - COOP: "
                            + STRING(crapcop.nmrescop).
                    PAUSE 10 NO-MESSAGE.
                END.    
       END.

    DELETE PROCEDURE h-b1wgen0128.
    
END PROCEDURE.

/* .......................................................................... */
