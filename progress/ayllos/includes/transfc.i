/* .............................................................................

   Programa: Includes/transfc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Outubro/91                        Ultima Atualizacao:02/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a consulta de transferencias e duplicacoes (TRANSF).
   
   ALTERACAO : 02/06/2000 - Tirar os prompt-for (Odair)
   
               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

............................................................................. */

ASSIGN tel_nrdconta = 0   tel_nmprimtl = ""
       tel_nrsconta = 0   tel_nrmatric = 0
       tel_tptransa = 0   tel_dstransa = ""
       tel_sttransa = "".

DO WHILE TRUE:

   REPEAT ON ENDKEY UNDO, LEAVE:

          UPDATE tel_nrdconta tel_nrsconta tel_tptransa
                 WITH FRAME f_transf.
          LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        LEAVE.

   glb_nrcalcul = tel_nrdconta.

   RUN fontes/digfun.p.
   IF   NOT glb_stsnrcal THEN
        DO:
            glb_cdcritic = 8.
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_transf NO-PAUSE.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
            NEXT.
         END.

   glb_nrcalcul = tel_nrsconta.
   RUN fontes/digfun.p.
   IF   NOT glb_stsnrcal THEN
        DO:
            glb_cdcritic = 8.
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_transf NO-PAUSE.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
            NEXT.
         END.

   FIND craptrf WHERE craptrf.cdcooper = glb_cdcooper AND 
                      craptrf.nrdconta = tel_nrdconta AND
                      craptrf.tptransa = tel_tptransa AND
                      craptrf.nrsconta = tel_nrsconta
                      USE-INDEX craptrf1 NO-LOCK NO-WAIT NO-ERROR.

   IF   NOT AVAILABLE craptrf THEN
        DO:
            glb_cdcritic = 124.
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_transf NO-PAUSE.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
            NEXT.
         END.

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                      crapass.nrdconta = craptrf.nrdconta
                      NO-LOCK NO-WAIT NO-ERROR.

   IF   AVAILABLE crapass THEN
        ASSIGN tel_nrmatric = crapass.nrmatric
               tel_nmprimtl = crapass.nmprimtl.
   ELSE
        DO:
            glb_cdcritic = 009.
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_transf NO-PAUSE.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
            NEXT.
         END.

   ASSIGN tel_nrsconta = craptrf.nrsconta
          tel_tptransa = craptrf.tptransa
          tel_dstransa = IF craptrf.tptransa = 1
                            THEN " - TRANSFERENCIA"
                            ELSE " - DUPLICACAO"
          tel_sttransa = IF craptrf.insittrs = 1
                            THEN "A FAZER"
                            ELSE IF craptrf.insittrs = 2
                                    THEN "PROCESSADA"
                                    ELSE "NAO PROCESSADA".

   DISPLAY tel_nrdconta tel_nmprimtl tel_nrsconta
           tel_nrmatric tel_tptransa tel_dstransa
           tel_sttransa WITH FRAME f_transf.

   LEAVE.

END.

/* .......................................................................... */
