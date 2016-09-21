/* .............................................................................

   Programa: Includes/lanreqi.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/92.                     Ultima alteracao: 13/03/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LANREQ.

   Alteracoes: 13/06/94 - Alterado para acessar a tabela de contas de convenio

               30/08/94 - Alterado para nao permitir lancamentos para associa-
                          dos com dtelimin (Deborah).

               14/11/96 - Verificar numeros iniciais e finais de solicitacoes
                          para nao permitir que sejam de associados diferentes
                          (Odair).

               02/04/98 - Tratamento para milenio e troca para V8 (Magui).

               06/10/98 - Tratar campo novo (cdtipcta) no crapreq (Deborah).
               
               02/07/99 - Liberar apenas tpcheque = 1 Normal (Odair)

               22/12/1999 - Alterado para liberar qtd. de taloes solicitados
                            para pessoa juridica e cheque administrativo
                            (Edson).

               28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).

               13/02/2003 - Usar agencia e numero do lote para separar
                            as agencias (Magui).
                            
               17/03/2005 - Verificar se Conta Integracao(Mirtes)

               06/07/2005 - Alimentado campo cdcooper da tabela crapreq (Diego).

               12/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               07/12/2005 - Acertar leitura do crapfdc (Magui).

               23/12/2005 - Nao permitir mais de 2 taloes para contas normais
                            e mais de 4 para contas conjuntas (Julio)

               04/01/2006 - Registrar operador da liberacao (Magui).

               13/01/2006 - Nao permitir acessar o campo qtreqtal quando
                            tprequis = 2 "Cheque TB" 
                            Criticas para conta integracao irregular (Julio)
                            
               19/01/2006 - Consistir se numero de folhas do talao a ser 
                            entregue e multiplo de 4 (Julio)

               24/01/2006 - Incluido campo agelot na leitura do crapreq
                            (Mirtes)

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               10/02/2006 - Nao permitir a requisicao para tipos de conta
                            05, 06, 07, 17 e 18 (Evandro).
                            
               10/04/2006 - Critica de multiplos so para formularios A4.
               
               08/02/2007 - Modificacao do uso dos indices, adequacao ao
                            BANCOOB e uso de BOs (Evandro).
                            
               16/03/2007 - Passagem do nome do sistema por parametro para a 
                            BO (Evandro).
                            
               29/09/2009 - Novo parametro da valida-dados par_cdagechq 
                            Adaptacoes projeto IF CECRED (Guilherme).
                            
               06/09/2011 - Ajuste para Lista Negra (Adriano).
               
               13/03/2013 - Ajuste referente ao projeto Cadastro Restritivo
                            (Adriano).

............................................................................. */


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nrctachq    
             tel_tprequis    
             tel_qtreqtal
             tel_cdbanchq    
             tel_nrinichq    
             tel_nrfinchq 
             WITH FRAME f_lanreq.
             
      /* Instancia a BO para executar as procedures */
      RUN siscaixa/web/dbo/b1crap05.p PERSISTENT SET h-b1crap05.

      IF VALID-HANDLE(h-b1crap05)   THEN
         DO: 
             RUN valida-dados IN h-b1crap05(INPUT glb_nmrescop,
                                            INPUT tel_cdagelot,
                                            INPUT tel_nrdolote,
                                            INPUT tel_nrctachq,
                                            INPUT tel_tprequis,
                                            INPUT tel_qtreqtal,
                                            INPUT tel_cdbanchq,
                                            INPUT tel_cdagechq,
                                            INPUT tel_nrinichq,
                                            INPUT tel_nrfinchq,
                                            INPUT "AYLLOS",
                                            INPUT glb_cdoperad,
                                           OUTPUT par_cdagechq).

             /* Elimina a instancia da BO */
             DELETE PROCEDURE h-b1crap05.

             /* Se ocorreu algum erro */
             IF RETURN-VALUE = "NOK"   THEN
                DO: 
                   FIND FIRST craperr WHERE craperr.cdcooper = glb_cdcooper AND
                                            craperr.cdagenci = tel_cdagelot AND
                                            craperr.nrdcaixa = tel_nrdolote
                                            NO-LOCK NO-ERROR.
                              
                   IF AVAILABLE craperr   THEN
                      DO:
                          MESSAGE craperr.dscritic.
                          NEXT.
                      END.

                END.

         END.

      LEAVE.

   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
      LEAVE.
   
   ASSIGN tel_cdagechq = par_cdagechq.
   
   DISPLAY tel_cdagechq WITH FRAME f_lanreq.
   
   /* Instancia a BO para executar as procedures */
   RUN siscaixa/web/dbo/b1crap05.p PERSISTENT SET h-b1crap05.

   IF VALID-HANDLE(h-b1crap05)   THEN
      DO:
         RUN solicita-entrega-talao IN h-b1crap05(INPUT glb_nmrescop,
                                                  INPUT tel_cdagelot,
                                                  INPUT tel_nrdolote,
                                                  INPUT tel_nrctachq,
                                                  INPUT tel_tprequis,
                                                  INPUT tel_qtreqtal,
                                                  INPUT tel_cdbanchq,
                                                  INPUT tel_cdagechq,
                                                  INPUT tel_nrinichq,
                                                  INPUT tel_nrfinchq,
                                                  INPUT glb_cdoperad,
                                                  INPUT "AYLLOS").

         /* Elimina a instancia da BO */
         DELETE PROCEDURE h-b1crap05.

         /* Se ocorreu algum erro */
         IF RETURN-VALUE = "NOK"   THEN
            DO: 
              FIND FIRST craperr WHERE craperr.cdcooper = glb_cdcooper AND
                                       craperr.cdagenci = tel_cdagelot AND
                                       craperr.nrdcaixa = tel_nrdolote
                                       NO-LOCK NO-ERROR.
                            
              IF AVAILABLE craperr   THEN
                 DO:
                    MESSAGE craperr.dscritic.
                    NEXT.
                 END.

            END.
          
      END.

   /* Atualiza os contadores da tela */
   FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper   AND
                      craptrq.cdagelot = tel_cdagelot   AND
                      craptrq.tprequis = 0              AND
                      craptrq.nrdolote = tel_nrdolote   
                      NO-LOCK NO-ERROR.
                      
   IF AVAILABLE craptrq   THEN
      ASSIGN tel_qtinforq = craptrq.qtinforq
             tel_qtcomprq = craptrq.qtcomprq
             tel_qtinfotl = craptrq.qtinfotl
             tel_qtcomptl = craptrq.qtcomptl
             tel_qtinfoen = craptrq.qtinfoen
             tel_qtcompen = craptrq.qtcompen

             tel_qtdiferq = tel_qtcomprq - tel_qtinforq
             tel_qtdifetl = tel_qtcomptl - tel_qtinfotl
             tel_qtdifeen = tel_qtcompen - tel_qtinfoen.
   
   IF tel_qtdiferq = 0 AND  
      tel_qtdifetl = 0 AND
      tel_qtdifeen = 0 THEN
      DO:
          ASSIGN glb_nmdatela = "LOTREQ".
          HIDE FRAME f_lanreq.
          HIDE FRAME f_regant.
          HIDE FRAME f_lanctos.
          HIDE FRAME f_moldura.
          RETURN.
      END.

   ASSIGN tel_reganter[6] = tel_reganter[5]
          tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]
          tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]
          tel_reganter[1] = STRING(tel_nrctachq,"zzzz,zzz,9") + "     "    +
                            STRING(tel_tprequis,"9")          + "       "  +
                            STRING(tel_qtreqtal,"z9")         + "        " +
                            STRING(tel_cdbanchq,"z,zz9")      + "     "    +
                            STRING(tel_cdagechq,"zzz9")       + "  "       +
                            STRING(tel_nrinichq,"zzz,zzz,9")  + "  "       +
                            STRING(tel_nrfinchq,"zzz,zzz,9")  + " "        +
                            STRING(tel_nrseqdig,"zz,zz9").
                            
   ASSIGN tel_cdbanchq = 0
          tel_cdagechq = 0
          tel_nrctachq = 0
          tel_qtreqtal = 0
          tel_nrinichq = 0
          tel_nrfinchq = 0
          tel_nrseqdig = tel_nrseqdig + 1.

   DISPLAY tel_nrdolote tel_cdagelot tel_qtinforq tel_qtcomprq
           tel_qtdiferq tel_qtinfotl tel_qtcomptl tel_tprequis
           tel_qtdifetl tel_qtinfoen tel_qtcompen
           tel_qtdifeen tel_nrctachq tel_qtreqtal
           tel_nrinichq tel_nrfinchq tel_nrseqdig
           WITH FRAME f_lanreq.
   
   PAUSE(0).
   
   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
           tel_reganter[4] tel_reganter[5] tel_reganter[6]
           WITH FRAME f_regant.
     
END.

/* .......................................................................... */
