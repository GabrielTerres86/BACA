/* .............................................................................

   Programa: Includes/conveni.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Agosto/2002                     Ultima Atualizacao: 11/03/2013.

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela CONVENIOS.

   Alteracoes: 13/11/2002 - Incluir campos para facilitar repasse (Margarete).
    
               06/07/2005 - Alimentado campo cdcooper da tabela crapcon (Diego).

               20/09/2005 - Alimentar o campo crapcon.cdsegmto (Julio)
               
               23/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               09/08/2007 - Incluido campo "Pagamento na Internet" (Diego). 
               
               05/09/2007 - Incluida confirmacao para criacao de novo convenio
                            (Elton). 
               
               11/01/2011 - Permite somente aos operadores "126", "979" e "997"
                            alterarem as informacoes de repasse na inclusao do
                            convenio (Elton).         
 
               10/01/2013 - Retirado o operador "997" e incluido o "30097" nas
                            opcoes de repasse.(Mirtes)
                          
               11/03/2013 - Adicionado campo "Sicredi" (Daniele).
                      
............................................................................. */
IF   tel_cdempcon = 0   THEN
     DO:
         ASSIGN glb_cdcritic = 375.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_emp_convenio.
        DISPLAY glb_cddopcao tel_cdempcon WITH FRAME f_emp_convenio.
         NEXT.
     END.

ASSIGN tel_flgcnvsi = FALSE.

FIND crapcon WHERE crapcon.cdcooper = glb_cdcooper AND
                   crapcon.cdempcon = tel_cdempcon AND
                   crapcon.cdsegmto = aux_cdsegmto NO-LOCK NO-ERROR NO-WAIT.

IF   AVAILABLE crapcon   THEN
     DO:
         ASSIGN glb_dscritic = "Empresa ja cadastrada.".
         MESSAGE glb_dscritic.
         CLEAR FRAME f_emp_convenio.

         DISPLAY glb_cddopcao tel_cdempcon tel_flgcnvsi WITH FRAME f_emp_convenio.
         NEXT.
     END.

     
DO TRANSACTION ON ENDKEY UNDO, LEAVE:

  DISPLAY tel_flginter tel_flgcnvsi WITH FRAME f_emp_convenio.
  
  DO WHILE TRUE:

      SET tel_nmrescon tel_cpfcgrcb tel_nmextcon 
          tel_cdhistor tel_nrdolote tel_flginter
          WITH FRAME f_emp_convenio.

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
              UPDATE tel_cdbccrcb tel_cdagercb 
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
      
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
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
      
      CREATE crapcon.

      ASSIGN crapcon.cdempcon = tel_cdempcon
             crapcon.cdcooper = glb_cdcooper
             crapcon.cdsegmto = aux_cdsegmto
             crapcon.nmrescon = CAPS(tel_nmrescon)
             crapcon.nmextcon = CAPS(tel_nmextcon)
             crapcon.cpfcgrcb = tel_cpfcgrcb
             crapcon.cdhistor = tel_cdhistor
             crapcon.nrdolote = tel_nrdolote
             crapcon.flginter = tel_flginter 
             crapcon.cdbccrcb = tel_cdbccrcb
             crapcon.cdagercb = tel_cdagercb
             crapcon.nrccdrcb = tel_nrccdrcb
             crapcon.cdfinrcb = tel_cdfinrcb
             crapcon.flgcnvsi = tel_flgcnvsi
             tel_dspescto     = ""
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

