/* .............................................................................

   Programa: Includes/convene.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Agosto/2002                     Ultima Atualizacao: 22/09/2014.

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela CONVENIOS.

   Alteracoes: 13/11/2002 - Incluir campos para facilitar repasse (Margarete).
      
               20/09/2005 - Tratamento para segmento do convenio (Julio)
               
               23/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               09/08/2007 - Incluido campo "Pagamento na Internet" (Diego).
              
               11/03/2013 - Incluido campo "Sicredi" (Daniele).
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

               
............................................................................. */

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:
       
       FIND crapcon WHERE crapcon.cdcooper = glb_cdcooper   AND
                          crapcon.cdempcon = tel_cdempcon   AND
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
            MESSAGE glb_dscritic.
            DISPLAY tel_cdempcon WITH FRAME f_emp_convenio.
            NEXT.
        END.

   ASSIGN tel_nmrescon = crapcon.nmrescon
          tel_nmextcon = crapcon.nmextcon
          tel_cdhistor = crapcon.cdhistor
          tel_nrdolote = crapcon.nrdolote
          tel_flginter = crapcon.flginter
          tel_cpfcgrcb = crapcon.cpfcgrcb
          tel_cdbccrcb = crapcon.cdbccrcb
          tel_cdagercb = crapcon.cdagercb
          tel_nrccdrcb = crapcon.nrccdrcb
          tel_cdfinrcb = crapcon.cdfinrcb
          tel_cnpescto = crapcon.dspescto
          tel_flgcnvsi = crapcon.flgcnvsi.

   DISPLAY tel_nmrescon tel_nmextcon tel_cdhistor tel_nrdolote tel_flginter
           tel_cpfcgrcb tel_cdbccrcb tel_cdagercb tel_nrccdrcb tel_cdfinrcb
           tel_flgcnvsi WITH FRAME f_emp_convenio.

   DISPLAY tel_cnpescto WITH FRAME f_consulta_contatos.

   IF  tel_flgcnvsi THEN
       DO:
           PAUSE(0).
           MESSAGE "Convenios Sicredi nao podem ser excluidos.".
           NEXT.
       END.

   ENABLE ALL WITH FRAME f_consulta_contatos.
  
   ASSIGN tel_cnpescto:READ-ONLY IN FRAME f_consulta_contatos = YES. 
   
   WAIT-FOR CHOOSE OF btn_btcnsair.
            
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

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
            ASSIGN tel_cnpescto:SCREEN-VALUE IN FRAME f_consulta_contatos = "".

            CLEAR FRAME f_emp_convenio ALL NO-PAUSE.
            CLEAR FRAME f_consulta_contatos ALL NO-PAUSE.

            NEXT.
        END.

   DELETE crapcon.
 
   RELEASE crapcon.
   
END. /* Fim da transacao */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

ASSIGN tel_cnpescto:SCREEN-VALUE IN FRAME f_consulta_contatos = "".

CLEAR FRAME f_emp_convenio ALL NO-PAUSE.
CLEAR FRAME f_consulta_contatos ALL NO-PAUSE.

HIDE FRAME f_consulta_contatos NO-PAUSE.
  
/* .......................................................................... */
