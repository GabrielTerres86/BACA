/* .............................................................................

   Programa: Includes/anotaa.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Dezembro/2001                       Ultima alteracao: 08/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela ANOTA.

   Alteracoes: 23/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
   
               22/02/2011 - Utilizacao de BO - (Jose Luis, DB1)
               
               08/04/2014 - Ajuste de whole index (Jean Michel).
............................................................................. */

ON RETURN OF anota-b DO: 
    HIDE MESSAGE NO-PAUSE.

    IF  NOT AVAILABLE tt-crapobs THEN
        RETURN NO-APPLY.

    ASSIGN aux_nrseqdig = tt-crapobs.nrseqdig
           tel_dsobserv = tt-crapobs.dsobserv
           tel_flgprior = tt-crapobs.flgprior.

    DO WHILE TRUE ON ERROR UNDO, LEAVE:
        HIDE FRAME f_anotacoes NO-PAUSE.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           DISPLAY tel_flgprior tel_dsobserv WITH FRAME f_observacao.

           ENABLE ALL WITH FRAME f_observacao.

           WAIT-FOR CHOOSE OF btn-salvar IN FRAME f_observacao.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /* F4 OU FIM */
             DO:
                 HIDE MESSAGE NO-PAUSE.

                 RUN Confirma.

                 IF  RETURN-VALUE = "NOK"  THEN
                     DO:
                        HIDE FRAME f_observacao NO-PAUSE.
                        VIEW FRAME f_anotacoes.
                        RETURN NO-APPLY.
                     END.
                 ELSE
                      DO:
                          ASSIGN tel_dsobserv
                                 tel_flgprior.
                          NEXT.
                      END.
             END.

        ASSIGN 
            tel_dsobserv = CAPS(INPUT tel_dsobserv)
            tel_flgprior = INPUT tel_flgprior.

        RUN Valida_Dados.

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        RUN Grava_Dados.

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        HIDE FRAME f_observacao NO-PAUSE.

        ASSIGN
            tt-crapobs.dsobserv = tel_dsobserv 
            tt-crapobs.flgprior = tel_flgprior.

        VIEW FRAME f_anotacoes.

        LEAVE.
    END.

    RETURN NO-APPLY.
END.   

ASSIGN glb_cdcritic = 0
       aux_tipconsu = yes
       aux_nmarqimp = "".

ALTERA:

DO WHILE TRUE:
     
   CLEAR FRAME f_anotacoes ALL NO-PAUSE. 

   ASSIGN btn-incluir:HIDDEN  = TRUE
          btn-visualiz:HIDDEN = TRUE
          btn-imprimir:HIDDEN = TRUE.

   OPEN QUERY anota-q FOR EACH tt-crapobs NO-LOCK
                        WHERE tt-crapobs.cdcooper = glb_cdcooper.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE anota-b btn-sair WITH FRAME f_anotacoes. 
       LEAVE.
   END.

   HIDE FRAME f_observacao NO-PAUSE.

   VIEW FRAME f_anotacoes.
          
   LEAVE.

END.  /*  Fim da transacao  */

/* .......................................................................... */
