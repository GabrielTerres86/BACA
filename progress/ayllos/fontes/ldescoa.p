/* .............................................................................

   Programa: Fontes/ldescoa.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                        Ultima atualizacao: 17/09/2008 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela LDESCO.

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 

               17/09/2008 - Alterado para usar soh um frame e incluir campo
                            Tipo de Desconto e modificar chave de acesso
                            a tabela crapldc (Gabriel).
............................................................................. */

{ includes/var_online.i }

{ includes/var_ldesco.i }   /*  Contem as definicoes das variaveis e forms  */

TRANS_A:

DO TRANSACTION ON ERROR UNDO TRANS_A, RETRY:

   DO aux_tentaler = 1 TO 10:

      FIND crapldc WHERE crapldc.cdcooper = glb_cdcooper    AND
                         crapldc.cddlinha = tel_cddlinha    AND
                         crapldc.tpdescto = IF tel_tpdescto = "C"  THEN 2
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
                            
          ant_txmensal = tel_txmensal
          
          tel_tpdescto = IF  crapldc.tpdescto  = 2   THEN
                             "C"
                         ELSE
                             "T"
          
          tel_dsdescto = IF   crapldc.tpdescto = 2   THEN
                              " - Cheques"
                         ELSE
                         IF   crapldc.tpdescto = 3   THEN
                              " - Titulos"
                         ELSE
                              " - Nao cadastrada".

   DISPLAY tel_cddlinha tel_txmensal tel_txdiaria tel_txjurmor 
           tel_dsdlinha tel_nrdevias tel_flgtarif tel_dssitlcr
           tel_tpdescto tel_dsdescto WITH FRAME f_ldesco.
           
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_txjurmor tel_txmensal WITH FRAME f_ldesco

      EDITING:

         READKEY.

         IF   FRAME-FIELD = "tel_txmensal"   OR
              FRAME-FIELD = "tel_txdmulta"   THEN
              IF   LASTKEY =  KEYCODE(".")   THEN
                   APPLY 44.
              ELSE
                   APPLY LASTKEY.
         ELSE
              APPLY LASTKEY.

      END.  /*  Fim do EDITING  */

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        UNDO TRANS_A, NEXT.

   tel_txdiaria = ROUND((EXP(1 + (tel_txmensal / 100),1 / 30) - 1) * 100,7).

   DISPLAY tel_txdiaria WITH FRAME f_ldesco.
        
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 381.
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      glb_cdcritic = 0.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            UNDO TRANS_A, NEXT.
        END.

   IF   aux_confirma = "S"   THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               UPDATE tel_dsdlinha tel_nrdevias tel_flgtarif 
                      WITH FRAME f_ldesco.
                
               tel_dsdlinha = CAPS(tel_dsdlinha).

               DISPLAY tel_dsdlinha tel_dsdescto WITH FRAME f_ldesco.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 UNDO TRANS_A, NEXT.
        END.

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
            UNDO TRANS_A, NEXT.
        END.

   ASSIGN crapldc.dsdlinha = tel_dsdlinha
          crapldc.txmensal = tel_txmensal
          crapldc.txdiaria = tel_txdiaria
          crapldc.txjurmor = tel_txjurmor
          crapldc.nrdevias = tel_nrdevias
          crapldc.flgtarif = tel_flgtarif.

   IF   ant_txmensal <> tel_txmensal   THEN    /*  Log de alteracao de taxa  */
        DO:
            UNIX SILENT VALUE("echo " + 
                              STRING(glb_dtmvtolt,"99/99/9999")  + " as "   +
                              STRING(TIME,"HH:MM:SS")    + " - " + 
                              "Linha de desconto "       +
                              STRING(tel_cddlinha,"999") + " - " +
                              "Descricao "               +
                              STRING(tel_dsdlinha)       + " - " +
                              "Taxa alterada de "        +
                              STRING(ant_txmensal,"zz9.999999")  + " para " +
                              STRING(tel_txmensal,"zz9.999999")  + " por "  +
                              glb_cdoperad + "-" + glb_nmoperad  +
                              " >> log/ldesco.log").
        END.

   tel_cddlinha = 0.

   CLEAR FRAME f_ldesco NO-PAUSE.

END.  /*  Fim da transacao  */

/* .......................................................................... */
