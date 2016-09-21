/* .............................................................................

   Programa: Includes/convenx.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI - Diego
   Data    : Maio/2011                   Ultima Atualizacao:11/03/2013.

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar replicacao dos dados de um convênio para demais 
               cooperativas do sistema.
               
               
   Alteracoes: 11/03/2013 - Adicionado campo "Sicredi", nao replicar
                            convenios Sicredi (Daniele). 
               
............................................................................. */

DEF BUFFER b_crapcon FOR crapcon.

FIND b_crapcon WHERE 
     b_crapcon.cdcooper = glb_cdcooper  AND
     b_crapcon.cdempcon = tel_cdempcon  AND
     b_crapcon.cdsegmto = aux_cdsegmto
     NO-LOCK NO-ERROR NO-WAIT.

IF NOT AVAIL b_crapcon THEN 
    DO:
        ASSIGN glb_cdcritic = 40.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic.
        CLEAR FRAME f_emp_convenio.
        DISPLAY tel_cdempcon WITH FRAME f_emp_convenio.
        NEXT.
    END.
ELSE 
    DO:
        ASSIGN tel_nmrescon = b_crapcon.nmrescon
               tel_nmextcon = b_crapcon.nmextcon
               tel_cdhistor = b_crapcon.cdhisto
               tel_nrdolote = b_crapcon.nrdolote
               tel_flginter = b_crapcon.flginter
               tel_cpfcgrcb = b_crapcon.cpfcgrcb
               tel_cdbccrcb = b_crapcon.cdbccrcb
               tel_cdagercb = b_crapcon.cdagercb
               tel_nrccdrcb = b_crapcon.nrccdrcb
               tel_cdfinrcb = b_crapcon.cdfinrcb
               tel_cnpescto = b_crapcon.dspescto
               tel_flgcnvsi = b_crapcon.flgcnvsi.
             
        DISPLAY tel_nmrescon tel_nmextcon tel_cdhistor tel_nrdolote 
                tel_flginter tel_cpfcgrcb tel_cdbccrcb tel_cdagercb
                tel_nrccdrcb tel_cdfinrcb tel_flgcnvsi WITH FRAME f_emp_convenio.
        
        DISPLAY tel_cnpescto WITH FRAME f_consulta_contatos.

        IF  b_crapcon.flgcnvsi THEN
            DO:
                PAUSE(0).
                MESSAGE "Nao e possivel replicar convenios SICREDI.".
                NEXT.
            END.
        
        ENABLE ALL WITH FRAME f_consulta_contatos.
        
        ASSIGN tel_cnpescto:READ-ONLY 
               IN FRAME f_consulta_contatos = YES. 
    END.

DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
     ASSIGN aux_confirma = "N"
            glb_cdcritic = 78.
    
     RUN fontes/critic.p.
     BELL.
     MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
     LEAVE.
END.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
     aux_confirma        <> "S"           THEN
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

FOR EACH crapcop NO-LOCK:

    IF   crapcop.cdcooper = glb_cdcooper THEN
         NEXT.

         /*  Replicar Empresa    */
    FIND crapcon WHERE 
         crapcon.cdcooper = crapcop.cdcooper   AND
         crapcon.cdempcon = tel_cdempcon       AND
         crapcon.cdsegmto = aux_cdsegmto       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   NOT AVAIL b_crapcon   THEN
         CREATE crapcon.

    BUFFER-COPY b_crapcon EXCEPT cdcooper TO crapcon
        ASSIGN crapcon.cdcooper = crapcop.cdcooper.
    
END.

RELEASE crapcon.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.
                 
ASSIGN tel_dspescto:SCREEN-VALUE IN FRAME f_contatos = "".
                   
CLEAR FRAME f_emp_convenio ALL NO-PAUSE.
CLEAR FRAME f_contatos ALL NO-PAUSE.
