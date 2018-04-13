/* ............................................................................

   Programa: Includes/lanrqei.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Agosto/2000.                    Ultima alteracao: 18/05/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LANRQE.

   Alteracoes: 17/04/2001 - Permitir no max 500 bloquetos (Deborah).

               28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).
               
               26/07/2002 - Acerto para nao rodar o ver-capital para a conta
                            de cheque salario (Deborah).

               15/07/2003 - Substituido o Nro de conta fixo do Banco do Brasil,
                            pela variavel aux_lsconta3, setada no 
                            lanrqe.p (Julio).

               18/11/2003 - Tratamento para permitir requisicao de cheque 
                            continuo do Banco do Brasil (Julio) 

               04/10/2004 - Alteracao na requisicao maxima do numero de 
                            taloes de formulario continuo para 20 (Julio)

               06/07/2005 - Alimentado campo cdcooper das tabelas craptrq e
                            crapreq (Diego).

               03/10/2005 - Incluir Continuo ITG (Ze).
               
               08/11/2005 - Alterar o Limite de Form. Continuo (Ze).

               20/12/2005 - Inclusao das opcoes (2)ChequeTB e (5)Form.Avulso
                            (Julio)

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               10/02/2006 - Nao permitir a requisicao de cheques para tipos de
                            conta 05, 06, 07, 17 e 18 (Evandro).
                            
               14/02/2006 - Alterado para ler folhas ao inves de taloes para o
                            "Formulario Continuo" (Evandro).
                            
               25/01/2007 - Permitir solicitacao de taloes para o BANCOOB
                            (Evandro).
                            
               03/04/2007 - Corrigida a critica para contas BANCOOB (Evandro).
               
               16/04/2007 - Desabilitar tipo de requisicao 3 para Viacredi
                            Tarefa 11121 (David).

               08/05/2007 - Desabilitar tipo de requisicao 3 para todas as
                            cooperativas, exceto CECRED (David).
                                    
               12/06/2007 - Alterado qtdade formulario continuo.Somente  
                            Somente Viacredi(Mirtes)
               
               24/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)
                            
               24/04/2008 - Para tipo de requisicao 5, permitir 500 folhas para
                            pessoa JURIDICA e 20 para FISICA (Evandro).

               09/05/2008 - Para requisicao 3, permitir formularios continuos
                            somente para contas juridicas e do tipo BANCOOB
                            (Gabriel).

               03/07/2008 - Nao permite mais de 400 folhas para o mesmo pedido
                            de formularios continuos, verificar todas as
                            requisicoes pendentes (Evandro).
                
               03/07/2009 - No pedido de formularios continuos, considerar
                            apenas requisicoes com cdcritic = 0 (Fernando).
                            
               28/09/2009 - Nao permitir inclusoes para contas demitidas(tipo4)
                            (Guilherme).
                            
               15/10/2009 - Adaptacoes projeto IF CECRED (Guilherme).

               01/12/2009 - Limitar a 200 chq avulso para PJ (Guilherme).
               
               01/03/2010 - Tratar formulario continuo(req 5) apenas para 
                            IF CECRED (Guilherme).
                            
               30/04/2010 - Bloquear a opcao para emissão de taloes TB.
                            (2-Folhas TB) (Guilherme).

               10/06/2010 - Coope tem que estar operando com ABBC para
                            podes solicitar taloes tipo 3 (Magui).
                            
                            
               20/04/2011 - Bloqueado a solicitacao de "8-Bloquetos BB" 
                            para a Viacredi (Adriano).
                            
               02/05/2011 - Ajuste na alteracao de 03/07/09 estava usando
                            crapreq ao inves de crabreq (Guilherme).
                            
               06/06/2011 - Gravado glb_cdoperad no crapreq.cdoperad
                            (Adriano).             
                            
               06/09/2011 - Incluido a chamada da procedure alerta_fraude
                            (Adriano).
                            
               14/03/2013 - Realizado a chamada da procedure alerta_fraude
                            no inicio do programa e retirado o tratamento
                            de contas BB "aux_lsconta" (Adriano).             
               
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)              
                            
               14/03/2017 - Aumentar para 1500 folhas por requisição no formulario  
                            3, conforme solicitado no chamado 627236. (Kelvin)
                            
               18/05/2017 - Retirar glb_cddopcao do form f_lanrqe (Lucas Ranghetti #646559)
               
               21/03/2018 - Substituida verificacao "cdtipcta = 4,5,6,7,..." pela modalidade igual a "2,3".
                          - Substituida verificacao "cdtipcta < 12" pelo indicador de conta integraçao = 0.
                          - Substituida verificacao "cdtipcta = 8,9,10,11" pela consulta se o produto de 
                            folhas de cheque está liberado para o tipo de conta.
                          - Substituida verificacao "cdtipcta > 11" pelo indicador de conta integraçao = 1. 
                            PRJ366 (Lombardi).
               
............................................................................. */

DEF VAR h-b1wgen0001 AS HANDLE                                        NO-UNDO.

INICIO:

DO WHILE TRUE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET tel_nrdctabb WITH FRAME f_lanrqe.
      
      FOR EACH crapreq WHERE crapreq.cdcooper = glb_cdcooper AND
                             crapreq.nrdconta = tel_nrdctabb
                             NO-LOCK BREAK BY crapreq.dtmvtolt DESCENDING:
      
          CASE crapreq.tprequis:
       
               WHEN 1 THEN MESSAGE "Ultimo tipo de requisicao: " +
                                   "NORMAL.".
                          
               WHEN 2 THEN MESSAGE "Ultimo tipo de requesicao: " +
                                   "FOLHAS TB.".
      
               WHEN 3 THEN MESSAGE "Ultimo tipo de requesicao: " +
                                   "FORMULARIOS CONTINUOS.".

               WHEN 5 THEN MESSAGE "Ultimo tipo de requesicao: " +
                                   "FORM.AVULSO.".
                                                    
               WHEN 8 THEN MESSAGE "Ultimo tipo de requesicao: " +
                                   "BLOQUETOS BB.".
                
          END CASE.
           
          LEAVE.
          
      END.
      
      SET tel_tprequis       
          tel_qtreqtal 
          WITH FRAME f_lanrqe.
      
      ASSIGN aux_nrdctabb = tel_nrdctabb
             aux_tprequis = tel_tprequis
             aux_qtreqtal = tel_qtreqtal
             aux_nrseqdig = tel_nrseqdig
             glb_nrcalcul = tel_nrdctabb
             glb_cdcritic = 0.
      
      RUN fontes/digfun.p.

      IF NOT glb_stsnrcal THEN
         DO:
             ASSIGN glb_cdcritic = 008.
             NEXT-PROMPT tel_nrdctabb WITH FRAME f_lanrqe.

         END.
      ELSE 
      DO:
         FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                            crapass.nrdconta = aux_nrdctabb 
                            NO-LOCK NO-ERROR.

         IF NOT AVAILABLE crapass   THEN
            DO:
                ASSIGN glb_cdcritic = 009.
                NEXT-PROMPT tel_nrdctabb WITH FRAME f_lanrqe.
            END.
         ELSE
            DO:
               IF crapass.dtelimin <> ? THEN
                  DO:
                      ASSIGN glb_cdcritic = 410.
                      NEXT-PROMPT tel_nrdctabb
                                  WITH FRAME f_lanrqe.
                  END.
               ELSE
                  DO:
                      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                      
                      RUN STORED-PROCEDURE pc_busca_modalidade_tipo
                      aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                           INPUT crapass.cdtipcta, /* Tipo de conta */
                                                          OUTPUT 0,   /* Modalidade */
                                                          OUTPUT "",  /* Flag erro */
                                                          OUTPUT ""). /* Descriçao da crítica */
                      
                      CLOSE STORED-PROC pc_busca_modalidade_tipo
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                      
                      ASSIGN aux_cdmodali = 0
                             aux_des_erro = ""
                             aux_dscritic = ""
                             aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                            WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
                             aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                                            WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
                             aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                                            WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.
                      
                      IF aux_des_erro = "NOK"  THEN
                           DO:
                              ASSIGN glb_cdcritic = aux_cdcritic
                                     glb_dscritic = aux_dscritic.
                              NEXT-PROMPT tel_nrdctabb
                                          WITH FRAME f_lanrqe.
                           END.                      
                      IF CAN-DO("2,3",STRING(aux_cdmodali)) THEN     
                          DO:
                              ASSIGN glb_cdcritic = 17.
                              NEXT-PROMPT tel_nrdctabb
                                          WITH FRAME f_lanrqe.
                          END.
                      ELSE
                         DO:
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                             
                            RUN STORED-PROCEDURE pc_busca_tipo_conta_itg
                            aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                                 INPUT crapass.cdtipcta, /* Tipo de conta */
                                                                OUTPUT 0,   /* Modalidade */
                                                                OUTPUT "",  /* Flag erro */
                                                                OUTPUT ""). /* Descriçao da crítica */
                            
                            CLOSE STORED-PROC pc_busca_tipo_conta_itg
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                            
                            ASSIGN aux_indctitg = 0
                                   aux_des_erro = ""
                                   aux_dscritic = ""
                                   aux_indctitg = pc_busca_tipo_conta_itg.pr_indconta_itg 
                                                  WHEN pc_busca_tipo_conta_itg.pr_indconta_itg <> ?
                                   aux_des_erro = pc_busca_tipo_conta_itg.pr_des_erro 
                                                  WHEN pc_busca_tipo_conta_itg.pr_des_erro <> ?
                                   aux_dscritic = pc_busca_tipo_conta_itg.pr_dscritic
                                                  WHEN pc_busca_tipo_conta_itg.pr_dscritic <> ?.
                            
                            IF aux_des_erro = "NOK"  THEN
                                 DO:
                                    ASSIGN glb_cdcritic = aux_cdcritic
                                           glb_dscritic = aux_dscritic.
                                    NEXT-PROMPT tel_nrdctabb
                                                WITH FRAME f_lanrqe.
                                 END.  
                            
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                            
                            RUN STORED-PROCEDURE pc_permite_produto_tipo
                            aux_handproc = PROC-HANDLE NO-ERROR (INPUT 38,               /* Codigo do produto */
                                                                 INPUT crapass.cdtipcta, /* Tipo de conta */
                                                                 INPUT crapass.cdcooper, /* Cooperativa */
                                                                 INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                                OUTPUT "",   /* Possui produto */
                                                                OUTPUT 0,   /* Codigo da crítica */
                                                                OUTPUT "").  /* Descriçao da crítica */
                            
                            CLOSE STORED-PROC pc_permite_produto_tipo
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                            
                            ASSIGN aux_possuipr = ""
                                   aux_cdcritic = 0
                                   aux_dscritic = ""
                                   aux_possuipr = pc_permite_produto_tipo.pr_possuipr 
                                                  WHEN pc_permite_produto_tipo.pr_possuipr <> ?
                                   aux_cdcritic = pc_permite_produto_tipo.pr_cdcritic 
                                                  WHEN pc_permite_produto_tipo.pr_cdcritic <> ?
                                   aux_dscritic = pc_permite_produto_tipo.pr_dscritic
                                                  WHEN pc_permite_produto_tipo.pr_dscritic <> ?.
                            
                            IF aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                                 DO:
                                    ASSIGN glb_cdcritic = aux_cdcritic
                                           glb_dscritic = aux_dscritic.
                                    NEXT-PROMPT tel_nrdctabb
                                                WITH FRAME f_lanrqe.
                                 END.
                            
                            IF  tel_tprequis <> 8      AND
                               (crapass.nrdctitg = ""  OR  
                                aux_indctitg = 0       OR
                                crapass.flgctitg <> 2) AND
                                /* BANCOOB e IF CECRED*/
                                aux_possuipr = "N" THEN
                                DO:
                                   IF aux_indctitg = 1 THEN
                                      ASSIGN glb_cdcritic = 860. 
                                   ELSE
                                      ASSIGN glb_cdcritic = 17.
                                        
                                   NEXT-PROMPT tel_tprequis 
                                               WITH FRAME f_lanreq.
                                END.
                            ELSE
                            IF  aux_tprequis = 4       AND
                                crapass.inpessoa <> 3  THEN
                                DO:
                                    ASSIGN glb_cdcritic = 127.
                                    NEXT-PROMPT tel_nrdctabb
                                                    WITH FRAME f_lanrqe.
                                END.
                         END.  
                  END.         

            END.     
         
         IF glb_cdcritic = 0 THEN
            DO:
                IF NOT VALID-HANDLE(h-b1wgen0001) THEN
                   RUN sistema/generico/procedures/b1wgen0001.p
                       PERSISTENT SET h-b1wgen0001.
      
                IF VALID-HANDLE(h-b1wgen0001)   THEN
                   DO:
                       RUN ver_capital IN h-b1wgen0001(
                                                  INPUT  glb_cdcooper,
                                                  INPUT  crapass.nrdconta,
                                                  INPUT  0, /* cod-agencia */
                                                  INPUT  0, /* nro-caixa   */
                                                  INPUT  0, /* vllanmto */
                                                  INPUT  glb_dtmvtolt,
                                                  INPUT  "lanrqei",
                                                  INPUT  1, /* AYLLOS */
                                                  OUTPUT TABLE tt-erro).

                       DELETE PROCEDURE h-b1wgen0001.
                       
                       /* Verifica se houve erro */
                       FIND FIRST tt-erro NO-LOCK NO-ERROR.
                   
                       IF AVAILABLE tt-erro   THEN
                          DO:
                              ASSIGN glb_cdcritic = tt-erro.cdcritic
                                     glb_dscricpl = tt-erro.dscritic.
                          END.

                       

                   END.
                /************************************/
                                           
                IF glb_cdcritic > 0   THEN
                   NEXT-PROMPT tel_nrdctabb WITH FRAME f_lanrqe.

            END.

      END.

      ASSIGN glb_dscritic = "".

      /* Nao solicitar taloes tipo 2 */
      IF  tel_tprequis = 2  THEN
          ASSIGN glb_dscritic = "Tipo de requisicao 2-Folhas TB desabilitada.".  
      ELSE
      IF tel_tprequis = 8 AND glb_cdcooper = 1 THEN
         ASSIGN glb_dscritic = "Tipo de requisicao 8-Bloquetos BB desabilitada.".  
      ELSE 
      IF tel_qtreqtal = 0                          OR
         (tel_tprequis = 2 AND tel_qtreqtal > 20)  OR
         (tel_tprequis     = 5  AND
          tel_qtreqtal     > 20 AND
          crapass.inpessoa = 1)                    OR
         (tel_tprequis     = 5   AND
          tel_qtreqtal     > 200 AND
          crapass.inpessoa = 2)                    OR
         (tel_tprequis = 8 AND tel_qtreqtal > 500) THEN
         ASSIGN glb_cdcritic = 26.
      ELSE
      IF (tel_tprequis = 2 OR tel_tprequis = 5) AND 
         (tel_qtreqtal MODULO 4) > 0            THEN
         glb_cdcritic = 859.
      ELSE
      IF tel_tprequis = 3   THEN
         DO:
             IF crapass.inpessoa <> 2   THEN
                ASSIGN glb_cdcritic = 331.
             ELSE             
                DO:
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    
                    RUN STORED-PROCEDURE pc_permite_produto_tipo
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT 38,               /* Codigo do produto */
                                                         INPUT crapass.cdtipcta, /* Tipo de conta */
                                                         INPUT crapass.cdcooper, /* Cooperativa */
                                                         INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                        OUTPUT "",  /* Possui produto */
                                                        OUTPUT 0,   /* Codigo da crítica */
                                                        OUTPUT ""). /* Descriçao da crítica */
                    
                    CLOSE STORED-PROC pc_permite_produto_tipo
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
                    ASSIGN aux_possuipr = ""
                           aux_cdcritic = 0
                           aux_dscritic = ""
                           aux_possuipr = pc_permite_produto_tipo.pr_possuipr 
                                          WHEN pc_permite_produto_tipo.pr_possuipr <> ?
                           aux_cdcritic = pc_permite_produto_tipo.pr_cdcritic 
                                          WHEN pc_permite_produto_tipo.pr_cdcritic <> ?
                           aux_dscritic = pc_permite_produto_tipo.pr_dscritic
                                          WHEN pc_permite_produto_tipo.pr_dscritic <> ?.
                    
                    IF aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                         DO:
                            ASSIGN glb_cdcritic = aux_cdcritic
                                   glb_dscritic = aux_dscritic.
                         END.
                    
                    IF aux_possuipr = "N" THEN 
                       ASSIGN glb_cdcritic = 17.
                END.
             /*** Magui em 14/06/2010 fora enquanto nao houver emissao
                  de cheques com a nossa IF
             ELSE
             DO:
                IF  aux_flopabbc   THEN
                    DO:
                        IF  crapcop.cdbcoctl = 0  THEN
                            glb_dscritic = "Nao ha cadastro de IF CECRED " +
                                           "na tela CADCOP.".
                        ELSE
                            IF  crapass.cdbcochq <> crapcop.cdbcoctl  THEN
                                glb_dscritic = 
                                    "Banco para emissao de cheques " +
                                    "da conta deve ser IF CECRED " + 
                                    STRING(crapcop.cdbcoctl,"999") + ".".
                     END.
             END.
             *****************/
             IF tel_qtreqtal MODULO 20 > 0   OR 
                tel_qtreqtal < 100           OR
                tel_qtreqtal > 1500           THEN
                ASSIGN glb_cdcritic = 26.
             ELSE
             IF crapass.cdsitcpf <> 1   THEN
                ASSIGN glb_cdcritic = 737.
             ELSE
                DO:
                    /* CCF */
                    FIND LAST crapneg WHERE 
                              crapneg.cdcooper  = glb_cdcooper        AND
                              crapneg.nrdconta  = crapass.nrdconta    AND
                              crapneg.cdhisest  = 1                   AND
                              crapneg.dtfimest  = ?                   AND
                              crapneg.dtiniest <= (glb_dtmvtolt - 10) AND
                             (crapneg.cdobserv  = 12                  OR
                              crapneg.cdobserv  = 13)
                              NO-LOCK NO-ERROR.

                    IF AVAILABLE crapneg   THEN
                       ASSIGN glb_cdcritic = 720.
                    ELSE
                       DO:
                           /* Nao permite mais de 400 folhas para o mesmo
                              pedido, verifica todas as requisicoes
                              pendentes */
                           ASSIGN aux_contador = 0.

                           FOR EACH crabreq WHERE
                               crabreq.cdcooper = crapass.cdcooper    AND
                               crabreq.nrdconta = crapass.nrdconta    AND
                               crabreq.tprequis = 3  /* FORM.CONT */  AND
                               crabreq.insitreq <> 2 /* Nao Atend */  AND
                               crabreq.cdcritic = 0      
                               NO-LOCK:

                               ASSIGN aux_contador = aux_contador +
                                                     crabreq.qtreqtal.
        
                           END.
                           
                           IF aux_contador + tel_qtreqtal > 1500   THEN
                              DO:
                                  MESSAGE "Limite por pedido"
                                          "excedido.".
                                  NEXT.
                              END.

                       END.

                END. 

         END.
      ELSE
         DO:
             IF tel_tprequis = 0  THEN
                ASSIGN glb_cdcritic = 14.
         END.
      
      IF glb_cdcritic > 0   OR
         glb_dscritic <> "" THEN
         DO: 
             IF glb_dscritic = ""  THEN
                RUN fontes/critic.p.

             BELL.
             CLEAR FRAME f_lanrqe.
             
             IF glb_cdcritic = 737   THEN
                CASE crapass.cdsitcpf:
                     
                     WHEN 0 THEN MESSAGE glb_dscritic "s/consulta.".
                     WHEN 2 THEN MESSAGE glb_dscritic "pendente.".
                     WHEN 3 THEN MESSAGE glb_dscritic "cancelado.".
                     WHEN 4 THEN MESSAGE glb_dscritic "irregular.".
                     WHEN 5 THEN MESSAGE glb_dscritic "suspenso.".
                   
                END CASE.
                  
             ELSE
                MESSAGE glb_dscritic.
             
             DISPLAY tel_nrdctabb 
                     tel_tprequis 
                     tel_qtreqtal
                     WITH FRAME f_lanrqe.

             NEXT.

         END.
 
      FIND crapreq WHERE crapreq.cdcooper = glb_cdcooper  AND
                         crapreq.dtmvtolt = glb_dtmvtolt  AND
                         crapreq.tprequis = aux_tprequis  AND
                         crapreq.nrdctabb = tel_nrdctabb  AND
                         crapreq.nrinichq = 0
                         USE-INDEX crapreq2 NO-LOCK NO-ERROR.
                   
      IF AVAILABLE crapreq   THEN
         DO:
             ASSIGN glb_cdcritic = 68.
             NEXT-PROMPT tel_nrdctabb WITH FRAME f_lanrqe.
         END.

      IF glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             CLEAR FRAME f_lanrqe.
             MESSAGE glb_dscritic.
             DISPLAY tel_nrdctabb 
                     tel_tprequis 
                     tel_qtreqtal
                     tel_nrseqdig WITH FRAME f_lanrqe.

             NEXT.

         END.

      
      IF NOT VALID-HANDLE(h-b1wgen0110) THEN
         RUN sistema/generico/procedures/b1wgen0110.p 
             PERSISTENT SET h-b1wgen0110.

      /*Monta a mensagem da operacao para envio no e-mail*/
      ASSIGN aux_dsoperac = "Tentativa de incluir "                      + 
                            "requisicoes especiais na conta "            + 
                            STRING(crapass.nrdconta,"zzzz,zzz,9")        +
                           (IF crapass.inpessoa = 1 THEN
                               STRING((STRING(crapass.nrcpfcgc,
                                       "99999999999")),"xxx.xxx.xxx-xx")
                            ELSE
                               STRING((STRING(crapass.nrcpfcgc,
                                       "99999999999999")),
                                       "xx.xxx.xxx/xxxx-xx")).

      /*Verifica se o associado esta no cadastro restritivo. Se estiver,
        sera enviado um e-mail informando a situacao*/
      RUN alerta_fraude IN h-b1wgen0110
                                 (INPUT glb_cdcooper,
                                  INPUT glb_cdagenci,
                                  INPUT 0, /*nrdcaixa*/
                                  INPUT glb_cdoperad,
                                  INPUT glb_nmdatela,
                                  INPUT glb_dtmvtolt,
                                  INPUT 1, /*ayllos*/
                                  INPUT crapass.nrcpfcgc,
                                  INPUT crapass.nrdconta,
                                  INPUT 1, /*idseqttl*/
                                  INPUT TRUE, /*Bloqueia operacao*/
                                  INPUT 24, /*cdoperac*/
                                  INPUT aux_dsoperac,
                                  OUTPUT TABLE tt-erro).

      IF VALID-HANDLE(h-b1wgen0110) THEN
         DELETE PROCEDURE h-b1wgen0110.

      IF RETURN-VALUE <> "OK"  THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF AVAIL tt-erro  THEN
               DO:
                   MESSAGE tt-erro.dscritic.
                   PAUSE(2) NO-MESSAGE.
                   NEXT.

               END.
            ELSE
               DO:
                   MESSAGE "Nao foi possivel verificar o " + 
                           "cadastro restritivo.".
                   PAUSE(2) NO-MESSAGE.
                   NEXT.

               END.

         END.

      LEAVE.

   END.


   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      RETURN.   /* Volta pedir a opcao para o operador */

   TRANS_1:

   DO TRANSACTION ON ERROR UNDO TRANS_1:
 

       FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper AND
                          craptrq.tprequis = 9            AND
                          craptrq.nrdolote = 99 
                          EXCLUSIVE-LOCK NO-ERROR.
                          
       IF NOT AVAILABLE craptrq   THEN
          DO:
              CREATE craptrq.

              ASSIGN craptrq.tprequis = 9
                     craptrq.nrdolote = 99
                     craptrq.cdcooper = glb_cdcooper.
              VALIDATE craptrq.
          END.
            
      ASSIGN tel_nrseqdig = craptrq.nrseqdig + 1.

      CREATE crapreq.

      ASSIGN crapreq.nrdconta = aux_nrdctabb
             crapreq.cdoperad = glb_cdoperad
             crapreq.nrdctabb = aux_nrdctabb
             crapreq.nrdolote = 99
             crapreq.cdagenci = crapass.cdagenci
             crapreq.cdtipcta = crapass.cdtipcta
             crapreq.nrinichq = 0
             crapreq.insitreq = 1
             crapreq.nrfinchq = 0
             crapreq.qtreqtal = tel_qtreqtal
             crapreq.nrseqdig = tel_nrseqdig
             crapreq.dtmvtolt = glb_dtmvtolt
             crapreq.tprequis = tel_tprequis
             crapreq.cdcooper = glb_cdcooper
             crapreq.tpformul = IF   tel_tprequis = 3 THEN
                                     999
                                ELSE 000
             crapreq.tpforchq = IF   tel_tprequis = 2 THEN
                                     "TB"
                                ELSE
                                IF   tel_tprequis = 5 THEN
                                     "A4"
                                ELSE
                                     crapreq.tpforchq
             craptrq.qtcomprq = craptrq.qtcomprq + 1
             craptrq.qtinforq = craptrq.qtinforq + 1
             
             craptrq.qtcomptl = craptrq.qtcomptl + tel_qtreqtal
             craptrq.qtinfotl = craptrq.qtinfotl + tel_qtreqtal

             craptrq.qtcompen = 0
             craptrq.qtinfoen = 0

             craptrq.nrseqdig = tel_nrseqdig

             tel_qtinforq = craptrq.qtinforq
             tel_qtcomprq = craptrq.qtcomprq
             tel_qtinfotl = craptrq.qtinfotl
             tel_qtcomptl = craptrq.qtcomptl.
                          
   END.    /* Fim da transacao */

   RELEASE craptrq.
   RELEASE crapreq.

   IF aux_flgerros   THEN
      NEXT.
   
   ASSIGN tel_reganter[6] = tel_reganter[5]
          tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]
          tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]
          tel_reganter[1] =
              STRING(tel_nrdctabb,"zzzz,zzz,9") + "        "      +
              STRING(tel_tprequis,"9")          + "            "  +
              STRING(tel_qtreqtal,"zzz9")         + "     "       +
              STRING(tel_nrseqdig,"zz,zz9")
          tel_nrdctabb = 0
          tel_tprequis = 0
          tel_qtreqtal = 0
          tel_nrseqdig = tel_nrseqdig + 1.

   DISPLAY tel_qtinforq 
           tel_qtcomprq
           tel_qtinfotl 
           tel_qtcomptl
           tel_nrdctabb 
           tel_tprequis 
           tel_qtreqtal 
           tel_nrseqdig
           WITH FRAME f_lanrqe.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] 
           tel_reganter[2] 
           tel_reganter[3]
           tel_reganter[4] 
           tel_reganter[5] 
           tel_reganter[6]
           WITH FRAME f_regant.

END.

/* .......................................................................... */

