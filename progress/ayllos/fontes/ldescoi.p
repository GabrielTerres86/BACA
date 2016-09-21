/* .............................................................................

   Programa: Fontes/ldescoi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                         Ultima atualizacao: 13/12/2013
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LDESCO.

   Alteracoes: 04/07/2005 - Alimentado campo cdcooper da tabela crapldc (Diego).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               18/09/2008 - Incluido campo Tipo de Documento (Gabriel).
               
               13/11/2008 - Alterado critica 765 por "Linha de desconto
                            ja existe" (Guilherme).
                            
               13/12/2013 - Inclusao de VALIDATE crapldc (Carlos)
                           
............................................................................. */

{ includes/var_online.i }

{ includes/var_ldesco.i }   /*  Contem as definicoes das variaveis e forms  */

IF   CAN-FIND(crapldc WHERE crapldc.cdcooper = glb_cdcooper    AND
                            crapldc.cddlinha = tel_cddlinha    AND
                            crapldc.tpdescto = IF  tel_tpdescto = "C" THEN 2
                                               ELSE 3)   THEN
     DO:
         MESSAGE "Linha de desconto ja existe.".
         RETURN.
     END.

TRANS_I:

DO TRANSACTION ON ERROR UNDO TRANS_I, RETRY:

   CREATE crapldc.
   ASSIGN crapldc.cddlinha = tel_cddlinha
          crapldc.nrdevias = 1
          crapldc.flgstlcr = TRUE
          crapldc.cdcooper = glb_cdcooper.
   VALIDATE crapldc.

   tel_dsdescto = IF   tel_tpdescto = "C"   THEN
                       " - Cheques"
                  ELSE
                       " - Titulos".
   
   DISPLAY tel_dsdescto WITH FRAME f_ldesco. 

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_dsdlinha tel_nrdevias tel_flgtarif WITH FRAME f_ldesco.

      tel_dsdlinha = CAPS(tel_dsdlinha).
      
      DISPLAY tel_dsdlinha tel_dsdescto WITH FRAME f_ldesco.

      UPDATE tel_txjurmor tel_txmensal WITH FRAME f_ldesco

      EDITING:

          READKEY.

          IF   FRAME-FIELD = "tel_txjurmor"   OR
               FRAME-FIELD = "tel_txmensal"   THEN
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
        UNDO TRANS_I, NEXT.


   ASSIGN tel_txdiaria = ROUND((EXP(1 + (tel_txmensal / 100),1 / 30) - 1) *
                                100,7)

          crapldc.dsdlinha = tel_dsdlinha
          crapldc.txmensal = tel_txmensal
          crapldc.txdiaria = tel_txdiaria
          crapldc.nrdevias = tel_nrdevias
          crapldc.flgtarif = tel_flgtarif
          crapldc.txjurmor = tel_txjurmor
          crapldc.flgsaldo = FALSE
          crapldc.flgstlcr = TRUE
          crapldc.tpdescto = IF   tel_tpdescto = "C"   THEN  2
                             ELSE 3.

   DISPLAY tel_txdiaria tel_dsdlinha tel_nrdevias tel_flgtarif 
           tel_dssitlcr WITH FRAME f_ldesco.

   PAUSE 0.

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
            HIDE FRAME f_finali NO-PAUSE.
            UNDO TRANS_I, NEXT.
        END.

   tel_cddlinha = 0.

END.  /*  Fim da transacao  */

/* .......................................................................... */

