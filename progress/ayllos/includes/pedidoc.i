/* .............................................................................

   Programa: Includes/pedidoc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/92.                         Ultima atualizacao: 08/10/2009

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela PEDIDO.

   Alteracoes: 03/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               28/06/99 - Mostrar pedido roubado (Odair)

               08/12/2000 - Mostrar BANCOOB na tela quando o campo 
                            crapped.nrdctabb for 0 (Eduardo).
               
               15/07/2003 - Alterar a conta do convenio do BB de fixo para   
                            variavel (Fernando).
                            
               16/09/2004 - Tratar conta integracao (Margarete).

               12/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               07/12/2005 - Ajustes na conversao crapchq/crapfdc (Edson).
               
               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               17/01/2007 - Contar a quantidade de cheques do pedido (Ze).
               
               07/03/2007 - Incluido o campo crapped.cdbanchq (Evandro).
               
               09/05/2008 - Somada a quantidade de folhas de cheques utilizando
                            a estrutura crapfdc (Elton).
                            
               08/10/2009 - Adaptacoes projeto IF CECRED (Guilherme).
               
............................................................................. */

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   UPDATE tel_nrpedido WITH FRAME f_pedido.

   ASSIGN aux_regexist = FALSE
          aux_flgretor = FALSE
          aux_contador = 0.

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
   
   IF   tel_nrpedido > 0   THEN
        DO:         
            FOR EACH crapped WHERE crapped.cdcooper = glb_cdcooper   AND
                                   crapped.nrpedido = tel_nrpedido   NO-LOCK:
                                    
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
                
                         FOR EACH crapfdc WHERE 
                                          crapfdc.cdcooper = glb_cdcooper  AND
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
                IF   crapped.cdbanchq = crapcop.cdbcoctl   THEN /* IF CECRED */
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
        END.
   ELSE
        DO:
            FOR EACH crapped WHERE crapped.cdcooper = glb_cdcooper  AND
                                   crapped.dtrecped = ?             NO-LOCK:

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
                     ASSIGN tel_qtfolhas = 0.
                     FOR EACH crapfdc WHERE 
                                      crapfdc.cdcooper = glb_cdcooper  AND
                                      crapfdc.nrpedido = tel_nrpedido
                                      USE-INDEX crapfdc3 NO-LOCK:
                              ASSIGN tel_qtfolhas = tel_qtfolhas + 1.
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
                IF   crapped.cdbanchq = crapcop.cdbcoctl   THEN /* IF CECRED */
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

            tel_nrpedido = 0.

            IF   NOT aux_regexist   THEN
                 DO:
                     glb_cdcritic = 222.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

