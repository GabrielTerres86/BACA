/* .............................................................................

   Programa: Includes/convena.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Agosto/2002                     Ultima Atualizacao: 22/09/2014.
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela CONVENIOS.

   Alteracoes: 13/11/2002 - Incluir campos para facilitar repasse (Margarete).
               
               20/09/2005 - Tratamento para o campo crapcon.cdsegmto (Julio)
                
               23/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                
               09/08/2007 - Incluido campo "Pagamento na Internet" (Diego). 
               
               05/09/2007 - Incluido confirmacao para as alteracoes (Elton). 
               
               11/01/2012 - Permite somente aos operadores "126", "979" e "997" 
                            alterarem os campos de repasse da tela (Elton).
               
               10/01/2013 - Retirado o operador "997" e incluido o "30097" nas
                            opcoes de repasse.(Mirtes)
                            
               11/03/2013 - Incluido campo "Sicredi", nao permitir alteracoes 
                            quando houver registro de convenios Sicredi (Daniele). 
                            
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                            
.............................................................................. */

   DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:

       FIND crapcon WHERE crapcon.cdcooper = glb_cdcooper AND
                          crapcon.cdempcon = tel_cdempcon AND
                          crapcon.cdsegmto = aux_cdsegmto
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crapcon   THEN
            IF   LOCKED crapcon   THEN
                 DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapcon),
                        					 INPUT "banco",
                        					 INPUT "crapcon",
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
                     glb_cdcritic = 558.
                     CLEAR FRAME f_emp_convenio.
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
            DISPLAY tel_cdempcon WITH FRAME f_emp_convenio.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   ASSIGN tel_nmrescon = crapcon.nmrescon
          tel_nmextcon = crapcon.nmextcon
          tel_cdhistor = crapcon.cdhistor
          tel_nrdolote = crapcon.nrdolote
          tel_flginter = crapcon.flginter
          tel_flgcnvsi = crapcon.flgcnvsi
          tel_cpfcgrcb = crapcon.cpfcgrcb
          tel_cdbccrcb = crapcon.cdbccrcb
          tel_cdagercb = crapcon.cdagercb
          tel_nrccdrcb = crapcon.nrccdrcb
          tel_cdfinrcb = crapcon.cdfinrcb
          tel_dspescto = crapcon.dspescto.

   DISPLAY tel_nmrescon tel_nmextcon tel_cdhistor tel_nrdolote tel_flginter
           tel_cpfcgrcb tel_cdbccrcb tel_cdagercb tel_nrccdrcb tel_flgcnvsi
           tel_cdfinrcb
           WITH FRAME f_emp_convenio.

   IF  crapcon.flgcnvsi = TRUE THEN
       DO:
           IF  glb_cdcooper = 3 THEN
               DO:
                   UPDATE tel_flgcnvsi WITH FRAME f_emp_convenio.

                   ASSIGN aux_confirma = "N".
                   RUN fontes/confirma.p (INPUT  "",
                                          OUTPUT aux_confirma).
                   
                   IF  aux_confirma <> "S" THEN 	
                       NEXT.

                   ASSIGN crapcon.flgcnvsi = tel_flgcnvsi.

               END.
           ELSE
               MESSAGE "Convenios Sicredi nao podem ser alterados.".

           NEXT.

       END.

    DO WHILE TRUE:

      SET tel_nmrescon tel_cpfcgrcb tel_nmextcon 
          tel_cdhistor tel_nrdolote tel_flginter 
          WITH FRAME f_emp_convenio.

      ASSIGN glb_nrcalcul = tel_cpfcgrcb.
      
      IF   tel_cpfcgrcb <> 0   THEN
           DO:
               ASSIGN glb_nrcalcul = tel_cpfcgrcb.
               RUN fontes/cpfcgc.p.
               IF   NOT glb_stsnrcal THEN
                    DO:
                        glb_cdcritic = 27.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT-PROMPT tel_cpfcgrcb WITH FRAME f_emp_convenio. 
                        NEXT.
                    END.
           END.  

      IF  glb_cdoperad = "126" OR
          glb_cdoperad = "979" OR 
          glb_cdoperad = "30097" THEN
          DO:
              UPDATE   tel_cdbccrcb tel_cdagercb 
                       tel_nrccdrcb tel_cdfinrcb
                       WITH FRAME f_emp_convenio.

              IF   tel_cdbccrcb <> 0   THEN
                   DO:
                       FIND crapban WHERE crapban.cdbccxlt = tel_cdbccrcb 
                                          NO-LOCK NO-ERROR.
                       IF   NOT AVAILABLE crapban   THEN
                            DO:
                                glb_cdcritic = 057.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                NEXT-PROMPT tel_cdbccrcb WITH FRAME f_emp_convenio.
                                NEXT.
                            END.
                   END.
        
              IF   tel_cdagercb <> 0   THEN
                   DO:
                       FIND crapagb WHERE crapagb.cdageban = tel_cdagercb   AND 
                                          crapagb.cddbanco = tel_cdbccrcb 
                                          NO-LOCK NO-ERROR.
                       IF   NOT AVAILABLE crapagb   THEN
                            DO:
                                glb_cdcritic = 015.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                NEXT-PROMPT tel_cdagercb WITH FRAME f_emp_convenio.
                                NEXT.
                            END.
                   END.
                   
              IF   tel_cdfinrcb <> 0   THEN 
                   DO:
                       FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                          craptab.nmsistem = "CRED"       AND
                                          craptab.tptabela = "GENERI"     AND
                                          craptab.cdempres = 00           AND
                                          craptab.cdacesso = "FINTRFDOCS" AND
                                          craptab.tpregist = tel_cdfinrcb
                                          NO-LOCK NO-ERROR.
                       IF   NOT AVAILABLE craptab   THEN
                            DO:
                                glb_cdcritic = 362.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                NEXT-PROMPT tel_cdfinrcb WITH FRAME f_emp_convenio.
                                NEXT.
                            END.
                   END.
          END. 
                                       
      ON  "RETURN" OF tel_dspescto
          APPLY 32.

      DISPLAY tel_dspescto WITH FRAME f_contatos.
       
      ENABLE ALL WITH FRAME f_contatos.
  
      WAIT-FOR CHOOSE OF btn_btaosair.
      
      DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

          ASSIGN aux_confirma = "N"
                 glb_cdcritic = 78.
          RUN fontes/critic.p.
          BELL.
          MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
          LEAVE.
      END.

      IF    KEYFUNCTION(LASTKEY) = "END-ERROR" OR
            aux_confirma <> "S" THEN
            DO:
                glb_cdcritic = 79.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                tel_cnpescto:SCREEN-VALUE IN FRAME f_consulta_contatos = "".

                CLEAR FRAME f_emp_convenio ALL NO-PAUSE.
                CLEAR FRAME f_consulta_contatos ALL NO-PAUSE.
                LEAVE.
            END.
       
      ASSIGN crapcon.nmrescon = CAPS(tel_nmrescon)
             crapcon.nmextcon = CAPS(tel_nmextcon)
             crapcon.cpfcgrcb = tel_cpfcgrcb
             crapcon.cdhistor = tel_cdhistor
             crapcon.nrdolote = tel_nrdolote
             crapcon.flginter = tel_flginter
             crapcon.cdbccrcb = tel_cdbccrcb
             crapcon.cdagercb = tel_cdagercb
             crapcon.nrccdrcb = tel_nrccdrcb
             crapcon.cdfinrcb = tel_cdfinrcb.
             crapcon.dspescto = tel_dspescto:SCREEN-VALUE IN FRAME f_contatos.
      
      LEAVE.

   END.

END. /* Fim da transacao */

RELEASE crapcon.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

ASSIGN tel_dspescto:SCREEN-VALUE IN FRAME f_contatos = "".

CLEAR FRAME f_emp_convenio ALL NO-PAUSE.
CLEAR FRAME f_contatos ALL NO-PAUSE.

/* .......................................................................... */
