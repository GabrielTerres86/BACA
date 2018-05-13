/* .............................................................................

   Programa: Fontes/ldescoe.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                          Ultima atualizacao: 04/12/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela LDESCO.

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 

               18/09/2008 - Incluido campo Tipo de Desconto (Gabriel).
               
               04/12/2008 - Verificar se ha limite ativo conforme o tipo da
                            linha de credito (Evandro).
                            
............................................................................. */

{ includes/var_online.i }

{ includes/var_ldesco.i }   /*  Contem as definicoes das variaveis e forms  */

TRANS_E:

DO TRANSACTION ON ERROR UNDO TRANS_E, RETRY:

   DO aux_tentaler = 1 TO 10:

      FIND crapldc WHERE crapldc.cdcooper = glb_cdcooper   AND
                         crapldc.cddlinha = tel_cddlinha   AND
                         crapldc.tpdescto = IF   tel_tpdescto = "C"   THEN 2
                                            ELSE 3
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE crapldc   THEN
           IF   LOCKED crapldc   THEN
                DO:
                    glb_cdcritic = 374.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                glb_cdcritic = 363.
      ELSE
           glb_cdcritic = 0.

      LEAVE.

   END.  /*  Fim do DO .. TO  */

   IF   glb_cdcritic > 0   THEN
        NEXT.

   ASSIGN tel_dsdlinha = crapldc.dsdlinha

          tel_dssitlcr = IF crapldc.flgstlcr THEN "LIBERADA" ELSE "BLOQUEADA"

          tel_txmensal = crapldc.txmensal
          tel_txdiaria = crapldc.txdiaria
          tel_txjurmor = crapldc.txjurmor
          tel_flgtarif = crapldc.flgtarif

          tel_nrdevias = crapldc.nrdevias

          tel_tpdescto = IF   crapldc.tpdescto = 2   THEN
                              "C"
                         ELSE
                              "T"
                
          tel_dsdescto = IF   crapldc.tpdescto = 2   THEN      
                              " - Cheques"
                         ELSE
                         IF   crapldc.tpdescto = 3   THEN
                              " - Titulos"
                         ELSE
                              " - Nao cadastrada" 

          tel_dssitlcr = IF   crapldc.flgsaldo   THEN 
                              tel_dssitlcr + " COM SALDO"
                         ELSE 
                              tel_dssitlcr + " SEM SALDO".

   DISPLAY tel_txjurmor tel_txmensal tel_txdiaria tel_dsdlinha 
           tel_nrdevias tel_flgtarif tel_dssitlcr tel_tpdescto
           tel_dsdescto WITH FRAME f_ldesco.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 378.
      RUN fontes/critic.p.
      glb_cdcritic = 0.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.

      IF   NOT CAN-DO("S,N",aux_confirma)   THEN
           NEXT.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.

   IF   aux_confirma = "S"   THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               aux_confirma = "N".

               glb_cdcritic = 78.
               RUN fontes/critic.p.
               glb_cdcritic = 0.
               BELL.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"   THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     glb_cdcritic = 0.
                     BELL.
                     MESSAGE glb_dscritic.
                     UNDO TRANS_E, NEXT.
                 END.

            /*  Bloqueia a linha para nao ser mais utilizada  */

            crapldc.flgstlcr = FALSE.

            HIDE MESSAGE NO-PAUSE.
            MESSAGE "Aguarde, pesquisando contratos ...".

            FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper   AND
                                     craplim.cddlinha = tel_cddlinha   AND
                                     craplim.tpctrlim = crapldc.tpdescto
                                     NO-LOCK NO-ERROR.

            IF   AVAILABLE craplim   THEN
                 DO:
                     HIDE MESSAGE NO-PAUSE.

                     ASSIGN glb_cdcritic = 377
                            aux_flgclear = FALSE.
                     UNDO TRANS_E, NEXT.
                 END.

            HIDE MESSAGE NO-PAUSE.

            DELETE crapldc.

            UNIX SILENT VALUE("echo " + 
                              STRING(glb_dtmvtolt,"99/99/9999") + " as " +
                              STRING(TIME,"HH:MM:SS") + " - " + 
                              "Excluindo linha de desconto " +
                              STRING(tel_cddlinha,"999") + " - " +
                              tel_dsdlinha + " com taxa mensal de " +
                              STRING(tel_txmensal,"zz9.999999") + " por " +
                              glb_cdoperad + "-" + glb_nmoperad +
                              " >> log/ldesco.log").
 


            tel_cddlinha = 0.

            CLEAR FRAME f_ldesco NO-PAUSE.

            NEXT.
        END.

   HIDE MESSAGE NO-PAUSE.

   CLEAR FRAME f_ldesco NO-PAUSE.

END.  /*  Fim da transacao  */

/* .......................................................................... */

