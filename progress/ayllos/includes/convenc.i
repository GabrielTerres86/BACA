
/* .............................................................................

   Programa: Includes/convenc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Agosto/2002                     Ultima Atualizacao: 11/03/2013.

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela CONVENIOS.

   Alteracoes: 13/11/2002 - Incluir campos para facilitar repasse (Margarete).
               08/04/2004 - Incluido campos historico/Lote(Mirtes)
               19/09/2005 - Inclusao do campo segmento (Julio)
               23/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               09/08/2007 - Incluido campo "Pagamento na Internet" (Diego).
               11/03/2013 - Incluido campo "Sicredi" (Daniele).
............................................................................ */

IF   tel_cdempcon <> 0   THEN
     DO:
         FIND crapcon WHERE crapcon.cdcooper = glb_cdcooper AND
                            crapcon.cdempcon = tel_cdempcon AND
                            crapcon.cdsegmto = aux_cdsegmto
                            NO-LOCK NO-ERROR NO-WAIT.

         IF   AVAILABLE crapcon   THEN
              DO:

                  ASSIGN tel_nmrescon = crapcon.nmrescon
                         tel_nmextcon = crapcon.nmextcon
                         tel_cdhistor = crapcon.cdhisto
                         tel_nrdolote = crapcon.nrdolote
                         tel_flginter = crapcon.flginter
                         tel_flgcnvsi = crapcon.flgcnvsi
                         tel_cpfcgrcb = crapcon.cpfcgrcb
                         tel_cdbccrcb = crapcon.cdbccrcb
                         tel_cdagercb = crapcon.cdagercb
                         tel_nrccdrcb = crapcon.nrccdrcb
                         tel_cdfinrcb = crapcon.cdfinrcb
                         tel_cnpescto = crapcon.dspescto.
                         
                  DISPLAY tel_nmrescon tel_nmextcon tel_cdhistor tel_nrdolote 
                          tel_flginter tel_flgcnvsi tel_cpfcgrcb tel_cdbccrcb
                          tel_cdagercb tel_nrccdrcb tel_cdfinrcb WITH FRAME f_emp_convenio.

                  DISPLAY tel_cnpescto WITH FRAME f_consulta_contatos.
      
                  ENABLE ALL WITH FRAME f_consulta_contatos.
  
                  ASSIGN tel_cnpescto:READ-ONLY 
                                      IN FRAME f_consulta_contatos = YES. 
   
                  WAIT-FOR CHOOSE OF btn_btcnsair.
                  
              END.
         ELSE
              DO:
                  ASSIGN glb_cdcritic = 40.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  CLEAR FRAME f_emp_convenio.
                  DISPLAY tel_cdempcon WITH FRAME f_emp_convenio.
                  NEXT.
              END.
     END.
ELSE
     DO:
        
         ASSIGN glb_cdcritic = 40.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_emp_convenio.
         DISPLAY tel_cdempcon WITH FRAME f_emp_convenio.
         NEXT.
     END.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.
                 
ASSIGN tel_cnpescto:SCREEN-VALUE IN FRAME f_consulta_contatos = "".
                   
CLEAR FRAME f_emp_convenio ALL NO-PAUSE.
CLEAR FRAME f_consulta_contatos ALL NO-PAUSE.

HIDE FRAME f_consulta_contatos NO-PAUSE.

/* .......................................................................... */
