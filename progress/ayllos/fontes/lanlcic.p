/* .............................................................................

   Programa: fontes/lanlcic.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Setembro/2004.                      Ultima atualizacao: 12/03/2007

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de CONSULTA da tela LANLCI.

   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre

               12/03/2007 - Usar o numero da conta para buscar o associado
                            (Evandro).

.............................................................................*/
{ includes/var_online.i } 
{ includes/var_lanlci.i }

DEF VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"                 NO-UNDO.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   UPDATE tel_nrctainv tel_nrdocmto WITH FRAME f_lanlci.
   
   /* verifica o DV da conta */
   glb_nrcalcul = tel_nrctainv.

   RUN fontes/digfun.p.
   IF   NOT glb_stsnrcal   THEN
        DO:
            glb_cdcritic = 8.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT-PROMPT tel_nrctainv WITH FRAME f_lanlci.
            NEXT.
        END.
        
   /* se o dv esta correto procura o associado */
   glb_nrcalcul = tel_nrctainv - 600000000.
   
   RUN fontes/digfun.p.
   
   FIND crapass WHERE crapass.cdcooper = glb_cdcooper        AND
                      crapass.nrdconta = INT(glb_nrcalcul)
                      NO-LOCK NO-ERROR.
                      
   IF   NOT AVAILABLE crapass               OR
        crapass.nrctainv <> tel_nrctainv   THEN
        DO:
            glb_cdcritic = 9.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT-PROMPT tel_nrctainv WITH FRAME f_lanlci.
            NEXT.
        END.
                      
   ASSIGN aux_nrdconta = crapass.nrdconta.
   
   /* busca lancamento conta investimento */
   FIND craplci WHERE craplci.cdcooper = glb_cdcooper    AND
                      craplci.dtmvtolt = glb_dtmvtolt    AND
                      craplci.cdagenci = tel_cdagenci    AND
                      craplci.cdbccxlt = tel_cdbccxlt    AND
                      craplci.nrdolote = tel_nrdolote    AND
                      craplci.nrdconta = aux_nrdconta    AND
                      craplci.nrdocmto = tel_nrdocmto    NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craplci   THEN
        DO:
            glb_cdcritic = 90.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            RETURN.
        END.
        
   ASSIGN tel_cdhistor = craplci.cdhistor
          tel_vllanmto = craplci.vllanmto
          tel_nrseqdig = craplci.nrseqdig.
          
   DISPLAY  tel_cdhistor  tel_vllanmto  tel_nrseqdig WITH FRAME f_lanlci.
   
   IF   tel_cdhistor = 487   THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
               HIDE MESSAGE NO-PAUSE.
               PAUSE(0).
           
               OPEN QUERY bcrapchd-q 
                    FOR EACH  crapchd WHERE crapchd.cdcooper = glb_cdcooper AND
                                            crapchd.dtmvtolt = tel_dtmvtolt AND
                                            crapchd.cdagenci = tel_cdagenci AND
                                            crapchd.cdbccxlt = tel_cdbccxlt AND
                                            crapchd.nrdolote = tel_nrdolote AND
                                            crapchd.nrdconta = aux_nrdconta AND
                                            crapchd.nrdocmto = tel_nrdocmto
                                            USE-INDEX crapchd3 NO-LOCK.
                                            
               ENABLE bcrapchd-b WITH FRAME f_consulta_compel.

               WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
              
            END.

            CLEAR FRAME f_consulta_compel ALL.
            HIDE FRAME f_consulta_compel NO-PAUSE.

        END.
END.
/*...........................................................................*/
