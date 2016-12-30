/* .............................................................................

   Programa: Includes/pedidob.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/92.                         Ultima atualizacao: 30/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de bloqueio da tela PEDIDO.

   Alteracoes: 03/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               08/12/2000 - Mostrar BANCOOB na tela quando o campo 
                            crapped.nrdctabb for 0 (Eduardo).
                            
               15/07/2003 - Alterar a conta do convenio do BB de fixo para  
                            variavel (Fernando).               

               10/09/2004 - Tratar conta integracao (Margarete).

               06/07/2005 - Alimentado campo cdcooper do buffer crabcch (Diego).

               12/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               07/12/2005 - Ajustes na conversao crapchq/crapfdc (Edson).
                              
               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               17/01/2007 - Contar a quantidade de cheques do pedido (Ze).
               
               07/03/2007 - Incluido o campo crapped.cdbanchq (Evandro).
               
               21/03/2007 - Incluido o campo crapcch.cdbanchq nas buscas;
                          - Substituido o campo crapcch.flgstlcm por
                            crapcch.tpopelcm;
                          - Alimentados os campos cdbanchq, cdagechq e nrctachq
                            da crapcch (Evandro).
               
               18/04/2007 - Somente atualizar registros na crapcch quando nao
                            for BANCOOB (Evandro).
                            
               08/10/2009 - Adaptacoes projeto IF CECRED(Guilherme).

			   30/12/2016 - Ajuste para logar a operacao de bloqueio
							(Adriano - SD 559724).

............................................................................. */

BLOQUEIO:

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   UPDATE 
   tel_nrpedido WITH FRAME f_pedido.

   ASSIGN aux_regexist = FALSE
          aux_flgretor = FALSE
          aux_contador = 0
          aux_qtlibblq = 0
          aux_contatal = 0.

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   IF   tel_nrpedido = 0   THEN
        DO:
            glb_cdcritic = 221.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.
   
   FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

   FOR EACH crapped WHERE crapped.cdcooper  = glb_cdcooper   AND
                          crapped.nrpedido  = tel_nrpedido   AND
                          crapped.dtrecped <> ?              NO-LOCK:

       ASSIGN aux_regexist = TRUE
              aux_contador = aux_contador + 1.

       IF   aux_contador = 1   THEN
            IF   aux_flgretor   THEN
                 DO:
                     PAUSE MESSAGE
                         "Tecle <Entra> para continuar ou <Fim> para encerrar".
                     CLEAR FRAME f_lanctos ALL NO-PAUSE.
                 END.

       ASSIGN tel_nrpedido = crapped.nrpedido
              tel_nrseqped = crapped.nrseqped
              tel_dtsolped = crapped.dtsolped
              tel_dtlibped = crapped.dtrecped
              tel_nrdctabb = crapped.nrdctabb
              tel_nrinichq = crapped.nrinichq
              tel_nrfinchq = crapped.nrfinchq
              tel_dspedido = "".

       IF   crapped.qtflschq > 0   THEN
            tel_qtfolhas = crapped.qtflschq.
       ELSE
            DO:
                tel_qtfolhas = 0.
                
                FOR EACH crapfdc WHERE crapfdc.cdcooper = glb_cdcooper  AND
                                       crapfdc.nrpedido = tel_nrpedido
                                       USE-INDEX crapfdc3 NO-LOCK:
                    tel_qtfolhas = tel_qtfolhas + 1.                   
                END.
            END.
       
       PAUSE (0).

       DISPLAY tel_nrpedido tel_nrseqped tel_dtsolped
               tel_dtlibped WITH FRAME f_lanctos.
                      
       IF   CAN-DO(aux_lscontas,STRING(crapped.nrdctabb))   THEN
            tel_dspedido = STRING(crapped.nrdctabb,"zzzz,zzz,9") +
                           "    " +
                           STRING(tel_qtfolhas,"z,zzz,zzz") +
                           "  " +
                           STRING(crapped.nrinichq,"zzz,zzz,z") +
                           "  " +
                           STRING(crapped.nrfinchq,"zzz,zzz,z").
       ELSE                
       IF  (crapped.nrdctabb = 418   OR 
            crapped.nrdctabb = 0)    AND
            crapped.dtsolped < 1/1/2005   THEN
            tel_dspedido = "BANCOOB".
       ELSE
       IF   crapped.cdbanchq = 1   THEN /* Banco do Brasil */
            tel_dspedido = "CONTA ITG     " +
                           STRING(tel_qtfolhas,"z,zzz,zzz").
       ELSE
       IF   crapped.cdbanchq = 756   THEN  /* BANCOOB */
            tel_dspedido = "BANCOOB       " +
                           STRING(tel_qtfolhas,"z,zzz,zzz").
       ELSE
       IF   crapped.cdbanchq = crapcop.cdbcoctl   THEN  /* IF CECRED */
            tel_dspedido = "IF CECRED     " +
                           STRING(tel_qtfolhas,"z,zzz,zzz").

       IF   CAN-DO(aux_lspedrou,STRING(tel_nrpedido))   THEN
            DISPLAY " ROUBADO " @ tel_dtlibped WITH FRAME f_lanctos.
                
       DISPLAY tel_dspedido WITH FRAME f_lanctos.

       IF   aux_contador = 11   THEN
            DO:
                ASSIGN aux_contador = 0
                       aux_flgretor = TRUE.
            END.
       ELSE
            DOWN WITH FRAME f_lanctos.

   END.  /*  Fim do FOR EACH -- Leitura dos pedidos de talonarios  */

   IF   NOT aux_regexist   THEN
        DO:
            glb_cdcritic = 221.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S"   THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   ASSIGN glb_cdcritic = 0.
   
   DO WHILE TRUE TRANSACTION:

      FIND FIRST crapped WHERE crapped.cdcooper  = glb_cdcooper   AND
                               crapped.nrpedido  = tel_nrpedido   AND
                               crapped.dtrecped <> ? USE-INDEX crapped1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE crapped   THEN
           IF   LOCKED crapped   THEN
                glb_cdcritic = 236.
           ELSE
                glb_cdcritic = 221.
      ELSE
           IF   crapped.insitped > 1   THEN
                glb_cdcritic = 236.
      
      IF   AVAILABLE crapped   AND   glb_cdcritic = 0   THEN 
           DO: 
               MESSAGE "Aguarde...Verificando talonarios.".

               FOR EACH crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                                      crapfdc.nrpedido = tel_nrpedido   NO-LOCK
                                      BREAK BY crapfdc.nrdctitg
                                               BY crapfdc.nrseqems
                                                  BY crapfdc.nrcheque:

                   IF   FIRST-OF(crapfdc.nrdctitg)   OR
                        FIRST-OF(crapfdc.nrseqems)   THEN
                        aux_nrchqini = INT(STRING(crapfdc.nrcheque) +
                                           STRING(crapfdc.nrdigchq)).

                   IF   crapfdc.dtemschq <> ?   AND
                        crapfdc.dtretchq =  ?   THEN
                        DO:
                          /*FIND crapass OF crapfdc NO-LOCK NO-ERROR.*/
                          
                            FIND crapass WHERE 
                                 crapass.cdcooper = crapfdc.cdcooper    AND
                                 crapass.nrdconta = crapfdc.nrdconta 
                                 NO-LOCK NO-ERROR.       

                            aux_nrdctitg = crapfdc.nrdctitg.
                      
                            IF   aux_nrdctitg = crapass.nrdctitg   THEN 
                                 IF   LAST-OF(crapfdc.nrdctitg)   OR
                                      LAST-OF(crapfdc.nrseqems)   THEN
                                      DO:
                                          aux_nrchqfim = 
                                              INT(STRING(crapfdc.nrcheque) +
                                                  STRING(crapfdc.nrdigchq)).
                                       
                                          FIND FIRST crapcch WHERE 
                                                crapcch.cdcooper =
                                                      glb_cdcooper       AND
                                                crapcch.nrdconta =
                                                      crapfdc.nrdconta   AND
                                                crapcch.nrdctabb =
                                                      crapfdc.nrdctabb   AND
                                                crapcch.nrchqini =
                                                      aux_nrchqini       AND
                                                crapcch.nrchqfim =
                                                      aux_nrchqfim       AND
                                                crapcch.cdhistor = 0     AND
                                               (crapcch.flgctitg = 1     OR
                                                crapcch.flgctitg = 4)    AND
                                                crapcch.cdbanchq =
                                                      crapfdc.cdbanchq
                                                  NO-LOCK NO-ERROR.
                                          
                                          IF   AVAILABLE crapcch   THEN
                                               DO:
                                                   ASSIGN glb_cdcritic = 219.
                                                   LEAVE.
                                               END.
                                      END.
                        END.                
                           
               END.  /*  Fim do FOR EACH  */

               IF   glb_cdcritic = 0   THEN
                    DO:
                        crapped.insitped = 3.
                        LEAVE.
                    END.
           END.

      RUN fontes/critic.p.
      BELL.
      MESSAGE glb_dscritic.
      NEXT BLOQUEIO.

   END.  /*  Fim do DO WHILE TRUE e da transacao  */
  
   OUTPUT STREAM str_1 TO arq/pedido.blq.

   aux_flgerros = FALSE.

   FOR EACH crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                          crapfdc.nrpedido = tel_nrpedido
                          EXCLUSIVE-LOCK TRANSACTION

                          ON ENDKEY UNDO, RETRY ON ERROR UNDO, RETRY
                          BREAK BY crapfdc.nrdctitg
                                   BY crapfdc.nrseqems
                                      BY crapfdc.nrcheque:

       IF   FIRST-OF(crapfdc.nrdctitg)   OR
            FIRST-OF(crapfdc.nrseqems)   THEN
            ASSIGN aux_nrchqini = INT(STRING(crapfdc.nrcheque) +
                                      STRING(crapfdc.nrdigchq))
                   aux_contatal = aux_contatal + 1
                   aux_qtlibblq = aux_qtlibblq + 1.
       
       IF   crapfdc.dtemschq <> ?   AND
            crapfdc.dtretchq =  ?   THEN
            DO:
                ASSIGN crapfdc.dtemschq = ?.
                       aux_ctpsqitg = crapfdc.nrdctabb.
                       
              /*FIND crapass OF crapfdc NO-LOCK NO-ERROR.*/
               
                FIND crapass WHERE crapass.cdcooper = crapfdc.cdcooper AND
                                   crapass.nrdconta = crapfdc.nrdconta
                                   NO-LOCK NO-ERROR.
                
                aux_nrdctitg = crapfdc.nrdctitg.
                      
                IF   aux_nrdctitg = crapass.nrdctitg   THEN 
                     IF   LAST-OF(crapfdc.nrdctitg)   OR
                          LAST-OF(crapfdc.nrseqems)   THEN
                          DO:
                              aux_nrchqfim = INT(STRING(crapfdc.nrcheque) +
                                                 STRING(crapfdc.nrdigchq)).
                        
                              /* Se nao for BANCOOB e IF CECRED*/
                              IF   crapfdc.cdbanchq <> 756             AND
                                   crapfdc.cdbanchq = crapcop.cdbcoctl THEN
                                   RUN proc_bloqueia_cch.
                          END.
            END.
       ELSE
            DO:
                ASSIGN aux_dtemstal = crapfdc.dtemschq
                       aux_dtrettal = crapfdc.dtretchq.

                PUT STREAM str_1
                         crapfdc.nrdconta FORMAT "99999999"    " "
                         crapfdc.nrcheque FORMAT "999999"      " "
                         crapfdc.nrpedido FORMAT "999999"      " "
                         crapfdc.nrdctabb FORMAT "99999999"    " "
                         aux_dtemstal     FORMAT "99/99/9999"  " "
                         aux_dtrettal     FORMAT "99/99/9999"  " " SKIP.

                aux_flgerros = TRUE.
            END.

       IF   aux_contatal > 9   THEN
            DO:
                HIDE MESSAGE NO-PAUSE.
                MESSAGE COLOR NORMAL "Aguarde...Bloqueando talao" aux_qtlibblq
                                     "de" crapped.nrfinchq "...".
                aux_contatal = 0.
            END.

   END.  /*  Fim do FOR EACH e da transacao  --  crapfdc  */

   FOR EACH crapped WHERE crapped.cdcooper = glb_cdcooper AND
                          crapped.nrpedido = tel_nrpedido 
                          EXCLUSIVE-LOCK TRANSACTION:

       ASSIGN crapped.dtrecped = ?
              crapped.insitped = 1.

   END.  /*  Fim do DO WHILE TRUE e da transacao  */

   PUT STREAM str_1
              "99999999 999999 999999 99999999 01/01/0001 01/01/0001" SKIP.

   OUTPUT STREAM str_1 CLOSE.

   HIDE MESSAGE NO-PAUSE.

   IF   aux_flgerros   THEN
        DO:
		    UNIX SILENT VALUE("echo "                                          +
							  STRING(glb_dtmvtolt,"99/99/9999")                +
							  " " + STRING(TIME,"HH:MM:SS") + "' -->'"         +
							  " Operador " + glb_cdoperad                      +
							  " efetuou o bloqueio do pedido "                 + 
							  string(tel_nrpedido,"zzzzz9") + " com problemas. " +                       
							  " >> log/pedido.log").

            glb_cdcritic = 227.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.

            ASSIGN glb_nmtelant = glb_nmdatela
                   glb_nmdatela = "CRIPED".

            HIDE FRAME f_pedido.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_moldura.
            RETURN.
        END.
   ELSE
        DO:
		    UNIX SILENT VALUE("echo "                                          +
							  STRING(glb_dtmvtolt,"99/99/9999")                +
							  " " + STRING(TIME,"HH:MM:SS") + "' -->'"         +
							  " Operador " + glb_cdoperad                      +
							  " efetuou o bloqueio do pedido "                 + 
							  string(tel_nrpedido,"zzzzz9") + " com sucesso. " +                       
							  " >> log/pedido.log").

            CLEAR FRAME f_lanctos ALL NO-PAUSE.

            glb_cdcritic = 228.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

PROCEDURE proc_bloqueia_cch:

    FIND FIRST crapcch WHERE crapcch.cdcooper = glb_cdcooper         AND
                             crapcch.nrdconta = crapfdc.nrdconta     AND
                             crapcch.nrdctabb = crapfdc.nrdctabb     AND
                             crapcch.nrchqini = aux_nrchqini         AND
                             crapcch.nrchqfim = aux_nrchqfim         AND
                             crapcch.cdhistor = 0                    AND  
                             crapcch.tpopelcm = "1"                  AND
                             crapcch.cdbanchq = crapfdc.cdbanchq
                             EXCLUSIVE-LOCK NO-ERROR.
                              
    IF   AVAILABLE crapcch   THEN
         DO:
             IF   crapcch.flgctitg = 0   THEN
                  DELETE crapcch.
             ELSE
                  DO:
                      FIND FIRST crapcch WHERE 
                                 crapcch.cdcooper = glb_cdcooper         AND
                                 crapcch.nrdconta = crapfdc.nrdconta     AND
                                 crapcch.nrdctabb = crapfdc.nrdctabb     AND
                                 crapcch.nrchqini = aux_nrchqini         AND
                                 crapcch.nrchqfim = aux_nrchqfim         AND
                                 crapcch.cdhistor = 0                    AND  
                                 crapcch.tpopelcm = "2"                  AND
                                 crapcch.cdbanchq = crapfdc.cdbanchq
                                 EXCLUSIVE-LOCK NO-ERROR.
                      
                      IF   AVAILABLE crapcch THEN
                           DO:
                               IF   crapcch.flgctitg = 0   THEN
                                    DELETE crapcch.
                           END.
                      ELSE              
                           DO:
                               CREATE crabcch.      
                               ASSIGN crabcch.dtmvtolt = glb_dtmvtolt
                                      crabcch.nrdconta = crapfdc.nrdconta
                                      crabcch.nrdctabb = crapfdc.nrdctabb
                                      crabcch.nrtalchq = crapfdc.nrseqems
                                      crabcch.cdhistor = 0
                                      crabcch.nrchqini = aux_nrchqini
                                      crabcch.nrchqfim = aux_nrchqfim
                                      crabcch.tpopelcm = "2" /*exc*/ 
                                      crabcch.cdcooper = glb_cdcooper
                                      crabcch.cdbanchq = crapfdc.cdbanchq
                                      crabcch.cdagechq = crapfdc.cdagechq
                                      crabcch.nrctachq = crapfdc.nrctachq.
                               
                               RELEASE crabcch.
                           END.   
                  END.
         END.
         
END PROCEDURE.

/* .......................................................................... */

