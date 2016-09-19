/* .............................................................................

   Programa: Fontes/ldescobl.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                          Ultima atualizacao: 18/09/2008 
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de bloqueio e liberacao da tela LDESCO.

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 

               18/09/2008 - Alterado os forms da tela e incluido campo tipo
                            de desconto (Gabriel).
............................................................................. */

{ includes/var_online.i }

{ includes/var_ldesco.i }   /*  Contem as definicoes das variaveis e forms  */

TRANS_BL:

DO TRANSACTION ON ERROR UNDO TRANS_BL, RETRY:

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
        
          tel_dssitlcr = IF crapldc.flgsaldo
                            THEN tel_dssitlcr + " COM SALDO"
                            ELSE tel_dssitlcr + " SEM SALDO"
                            
          tel_tpdescto = IF   crapldc.tpdescto  = 2   THEN
                              "C"
                         ELSE
                              "T"
          
          tel_dsdescto = IF crapldc.tpdescto = 2 THEN
                            " - Cheques "
                         ELSE
                         IF crapldc.tpdescto = 3 THEN
                            " - Titulos "
                         ELSE
                            " - Nao Cadastrada".
                            
   DISPLAY tel_txmensal tel_txdiaria tel_txjurmor  tel_dsdlinha 
           tel_flgtarif tel_nrdevias tel_dssitlcr  tel_tpdescto
           tel_dsdescto WITH FRAME f_ldesco.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      glb_cdcritic = 0.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S"   THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            UNDO TRANS_BL, NEXT.
        END.

   IF   glb_cddopcao = "B"   THEN
        crapldc.flgstlcr = FALSE.
   ELSE
        crapldc.flgstlcr = TRUE.

   tel_dssitlcr = IF crapldc.flgstlcr THEN "LIBERADA" ELSE "BLOQUEADA".

   DISPLAY tel_dssitlcr WITH FRAME f_ldesco.

END.  /*  Fim da transacao  */

/* .......................................................................... */
