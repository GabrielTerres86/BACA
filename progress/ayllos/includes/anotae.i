/* .............................................................................

   Programa: Includes/anotae.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Dezembro/2001                       Ultima alteracao: 08/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela ANOTA.

   Alteracoes: 23/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
   
               23/02/2011 - Utilizacao de BO - (Jose Luis, DB1)
               
               08/04/2014 - Ajuste de whole index (Jean Michel).

............................................................................. */

ON RETURN OF anota-b DO:
    HIDE MESSAGE NO-PAUSE.
      
    IF  NOT AVAILABLE tt-crapobs THEN
        RETURN NO-APPLY.

    ASSIGN 
        aux_nrseqdig = tt-crapobs.nrseqdig
        aux_recidobs = tt-crapobs.recidobs
        tel_dsobserv = tt-crapobs.dsobserv
        tel_flgprior = tt-crapobs.flgprior.

    DO WHILE TRUE ON ERROR UNDO, LEAVE:
                
        RUN Confirma.
        
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE.

        RUN Valida_Dados.
        
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE.
        
        RUN Grava_Dados.
        
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE.

        ASSIGN
            glb_nrcalcul = tel_nrdconta
            aux_nrseqdig = 0.

        DELETE tt-crapobs.

        OPEN QUERY anota-q FOR EACH tt-crapobs NO-LOCK
                          WHERE tt-crapobs.cdcooper = glb_cdcooper.

       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE e da transacao  */
    
    RETURN NO-APPLY.

END.  /*  Fim da transacao  */

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

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
