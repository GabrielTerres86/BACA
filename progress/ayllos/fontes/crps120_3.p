/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps120_3.p              | Incorporado ao pc_crps120         |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - LUCAS LOMBARDI      (SUPERO)

*******************************************************************************/











/* ..........................................................................

   Programa: Fontes/crps120_3.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Maio/95.                        Ultima atualizacao: 11/02/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar folha de pagamento e debito de cotas e emprestimos.

   Alteracoes: 16/11/95 - Alterado para tratar debito do convenio DENTARIO para
                          a CEVAL JARAGUA DO SUL (Edson).

               03/05/96 - Alterado para tratar debito da poupanca programada.

               24/06/96 - Implementado o campo cdempfol (codigo da empresa no
                          sistema de folha das empresas) (Deborah).

               07/08/96 - Alterado para tratar varios convenios de dentistas
                          (Edson).

               18/11/96 - Alterado para excluir o crapfol correspondente ao
                          credito da folha do associado (Edson).

               18/12/96 - Alterado para tratar aviso do debito de seguro de
                          casa (Edson).

               14/01/97 - Alterado para tratar CPMF (Edson).

               06/02/97 - Acertar tratamento da CPMF (Odair)

               21/02/97 - Tratar seguro saude Bradesco e desmembrar a
                          includes/crps120.i para fontes/crps120_3.p para nao
                          estorar 63K (Odair).

               18/03/97 - Dar pesos para data crapavs.dtintegr (Odair)

               25/04/97 - Tratar historico do seguro AUTO (Edson).

               19/05/97 - Alterar o peso do historico 127 para o mesmo peso
                          do historico 160 (Edson).

               04/06/97 - Otimizacao da rotina de leitura do crapavs (Edson).

               25/06/97 - Alterado para fazer includes na leitura do crapavs.
                          (Odair).

               27/08/97 - Alterado para tratar crapavs.flgproce (Deborah).

               06/10/97 - Nao lancar valor zerado (Odair).

               16/02/98 - Alterar data final da CPMF (Odair)

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               09/11/98 - Tratar situacao em prejuizo (Deborah).
                         
               26/02/99 - Tratar associados empresa resima (Odair)

               01/06/1999 - Tratar CPMF (Deborah).

               23/10/2000 - Desmembrar a critica 95 conforme a situacao do 
                            titular (Eduardo).
                            
               27/07/2001 - Tratar historico 341 - Seguro de Vida (Junior).

               11/03/2003 - Tratar a seguinte situacao: primeiro debita em 
                            c/c e depois debita via folha - o sistema fazia em
                            folha sempre o total, desconsiderando o que ja 
                            tinha sido debitado em c/c - passou a considerar).
                            
               27/11/2003 - Tratamento para Cecrisa, para obter numero da conta
                            atraves do numero de cadastro(Mirtes)

               08/04/2004 - Nao cobrava corretamente a prestacao quando
                            pagamento parcial (Margarete)
                            Alterado o formulario para 80col (Deborah). 
                                   
               07/05/2004 - Nao cobrava corretamente o emprestimo na conta
                            corrente quando pagamento parcial (Margarete).

               07/07/2004 - Tratamento Contas Cecrisa (verificar se existem
                            Contas duplicadas e ATIVAS)(Mirtes)
                            Chamado 0800(Tarefa 1006)

               29/06/2005 - Alimentado campo cdcooper das tabelas craprej
                            e craplcm (Diego).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               30/05/2006 - Criar crapfol quando for credito do salario (Julio)
               
               30/08/2006 - Somente criar crapfol se for integracao de credito 
                            de salario mensal (Julio)
                            
               11/12/2006 - Verificar se eh Conta Salario - crapccs (Ze).

               20/12/2007 - Nao remover arquivo para o salvar antes de setar
                            a solicitacao como processada (Julio).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               22/07/2009 - Correcao no tratamento do campo cdempres (Diego).
               
               10/08/2009 - Acerto na critica 775 (Diego).
               
               29/02/2012 - Desprezado registros com valor zerado (Adriano).
               
               28/08/2013 - Incluido a chamada da procedure "atualiza_desconto"
                            "atualiza_emprestimo" para os contratos que 
                            nao ocorreram debito (James).
                            
               24/09/2013 - Retirada condicao para debito de cotas(127) devido
                            a mesma ja estar sendo feita dentro do programa
                            crps120_2 (Diego).
                            
               01/10/2013 - Possibilidade de imprimir o relatório direto da tela 
                            SOL062, na hora da solicitacao (N) (Carlos)
               
               09/10/2013 - Atribuido valor 0 no campo crapcyb.cdagenci (James)
               
               14/11/2013 - Ajuste para nao atualizar as flag de judicial e
                            vip no cyber (James).
                            
               15/01/204 - Inclusao de VALIDDAE craprej, craplcm, crapfol, 
                           craplot e craplcs (Carlos)
                           
               11/02/2014 - Remover a criacao do emprestimo no CYBER (James)
               
               05/11/2015 - Caso algum registro da crapass esteja lockado gera erro (Lombardi)
............................................................................*/

DEF VAR   aux_vlalipmf      AS    DECIMAL                      NO-UNDO.
DEF VAR   aux_cfrvipmf      AS    DECIMAL                      NO-UNDO.
DEF VAR   aux_vlsalliq      AS    DECIMAL                      NO-UNDO.
DEF VAR   aux_flgdente      AS    LOGICAL                      NO-UNDO.
DEF VAR   aux_vldebita      AS    DECIMAL                      NO-UNDO.
DEF VAR   aux_vlpgempr      LIKE  crapepr.vlsdeved             NO-UNDO.
DEF VAR   aux_vldebtot      LIKE  crapepr.vlsdeved             NO-UNDO.
DEF VAR   aux_cdempres_2    AS INT                             NO-UNDO.
DEF VAR   aux_flgexist      AS LOGICAL                         NO-UNDO.

/* vars para impressao.i */
DEF    VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF    VAR par_flgrodar AS LOGICAL INIT TRUE                          NO-UNDO.
DEF    VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEF    VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF    VAR par_flgfirst AS LOGICAL INIT TRUE                          NO-UNDO.
DEF    VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF    VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF    VAR par_flgcance AS LOGICAL                                    NO-UNDO.

DEF BUFFER crabass FOR crapass.
DEF BUFFER crabttl FOR crapttl.

{ includes/var_cpmf.i } 
{ includes/var_batch.i }
{ includes/var_crps120.i }

/* Se e periodo de cobranca de CPMF atualiza variaveis */

IF   glb_dtmvtolt > 01/22/1997 AND glb_dtmvtolt < 01/24/1999 THEN
     ASSIGN aux_vlalipmf = glb_vlalipmf
            aux_cfrvipmf = glb_cfrvipmf.
ELSE
     ASSIGN aux_vlalipmf = 0
            aux_cfrvipmf = 1.

{ includes/cpmf.i } 

aux_flfirst2 = TRUE.

/*  Leitura do arquivo com os liquidos de pagamento  */

INPUT  STREAM str_2 FROM VALUE(aux_nmarqint) NO-ECHO.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, RETURN:

   glb_cdcritic = 0.

   IF   aux_flgfirst   THEN
        IF   glb_inrestar = 0   THEN
             DO:

                 glb_cdcritic = 219.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   "' --> '" + aux_nmarqint +
                                   " >> log/proc_batch.log").

                 glb_cdcritic = 0.

                 SET STREAM str_2       /*  Registro de controle  */
                     aux_tpregist  aux_dtmvtoin  aux_cdempres
                     aux_tpdebito  aux_vldaurvs.

                                  /*-------- Desativado
                 IF   crapsol.cdempres = 10   AND   aux_cdempres = 1   THEN
                      aux_cdempres = crapsol.cdempres.
                 ELSE
                 IF   crapsol.cdempres = 13   AND   aux_cdempres = 10   THEN
                      aux_cdempres = crapsol.cdempres.
                 ---------------------------*/

                 /* Coloca sempre tipo de debito 1 (moeda corrente) */
                 aux_tpdebito = 1.

                 IF   aux_tpregist <> 1   THEN
                      glb_cdcritic = 181.
                 ELSE
                 IF   aux_dtmvtoin <> aux_dtrefere   THEN
                      glb_cdcritic = 173.
                 ELSE
                 IF   aux_cdempres <> aux_cdempfol   THEN
                      glb_cdcritic = 173.
                 ELSE
                 IF   NOT CAN-DO("1,2",STRING(aux_tpdebito))   THEN
                      glb_cdcritic = 379.
                 
                 IF   glb_cdcritic > 0   THEN
                      DO:
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                            glb_dscritic + " EMPRESA = " +
                                            STRING(aux_cdempsol,"99999") +
                                            " >> log/proc_batch.log").
                          RETURN.      /* Le proxima solicitacao */
                      END.

                 ASSIGN aux_flgfirst = FALSE
                        aux_cdempres = aux_cdempsol.
             END.
        ELSE
             DO:
                 SET STREAM str_2       /*  Registro de controle  */
                     aux_cdempres aux_tpdebito aux_vldaurvs.

                 /*--------- Desativado

                 IF   crapsol.cdempres = 10   AND   aux_cdempres = 1   THEN
                      aux_cdempres = crapsol.cdempres.
                 ELSE
                 IF   crapsol.cdempres = 13   AND   aux_cdempres = 10   THEN
                      aux_cdempres = crapsol.cdempres.
                 ---------------------*/

                 /* Coloca sempre tipo de debito 1 (moeda corrente) */

                 aux_tpdebito = 1.

                 DO WHILE aux_nrseqint <> glb_nrctares:

                    SET STREAM str_2
                        aux_tpregist  aux_nrseqint ant_nrdconta ^ ^.

                 END.

                 IF   aux_tpregist = 9   THEN
                      LEAVE.

                 ASSIGN aux_flgfirst = FALSE
                        aux_cdempres = aux_cdempsol.
             END.

   SET STREAM str_2
       aux_tpregist  aux_nrseqint  aux_nrdconta  aux_vllanmto  aux_cdhistor.

   IF   aux_tpregist = 9 OR
        aux_nrdconta = 99999999 THEN
        LEAVE.

   IF   aux_vllanmto = 0 THEN /*Ignora registro com valor zerado*/
        NEXT.

   /*  Verifica se deve somar o fator salarial  */

   IF   aux_nrdconta = ant_nrdconta    THEN
        aux_flgsomar = TRUE.
   ELSE
        ASSIGN aux_flgsomar = FALSE
               ant_nrdconta = aux_nrdconta
               rel_qttarifa = rel_qttarifa + 1.

   /*--------------Alteracao Numero da Conta - Cecrisa ----*/

    IF  glb_cdcooper = 5 THEN 
        DO:
           IF  aux_cdempres = 1 OR
               aux_cdempres = 2 OR
               aux_cdempres = 3 OR
               aux_cdempres = 5 OR
               aux_cdempres = 6 OR
               aux_cdempres = 7 OR
               aux_cdempres = 8 OR
               aux_cdempres = 15 THEN
               DO:
                  ASSIGN aux_flgexist = FALSE.
                  
                  FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                         crapass.nrcadast = aux_nrdconta,
                      FIRST crapttl WHERE 
                            crapttl.cdcooper = glb_cdcooper      AND
                            crapttl.nrdconta = crapass.nrdconta  AND
                            crapttl.idseqttl = 1                 AND
                            crapttl.cdempres = aux_cdempres  NO-LOCK:
                                         
                      ASSIGN aux_flgexist = TRUE.
                      
                      FOR EACH crabass WHERE
                               crabass.cdcooper  = glb_cdcooper AND
                               crabass.nrcadast  = aux_nrdconta AND
                               crabass.nrdconta <> crapass.nrdconta AND
                               crabass.cdsitdct <> 3,
                          FIRST crabttl WHERE
                                crabttl.cdcooper = glb_cdcooper     AND
                                crabttl.nrdconta = crabass.nrdconta AND
                                crabttl.idseqttl = 1                AND
                                crabttl.cdempres = aux_cdempres  NO-LOCK:
                           
                          ASSIGN glb_cdcritic = 775. /*+ de 1 cont p/ass*/
                          
                          LEAVE.
                          
                      END.
                      
                      IF   glb_cdcritic <> 775  THEN
                           ASSIGN aux_nrdconta = crapass.nrdconta.

                      LEAVE.     
                  END.
                  
                  IF   aux_flgexist = FALSE  THEN
                       ASSIGN  glb_cdcritic  = 9.
                           
               END.
        END.       
   
   ASSIGN aux_flgctsal = FALSE.
   
   /*-------------------------------------------------------*/

   TRANS_1:

   DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

      DO WHILE TRUE:
         
         IF  glb_cdcritic = 0 THEN 
             DO:
                FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                   crapass.nrdconta = aux_nrdconta
                                   USE-INDEX crapass1 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                         
                IF   NOT AVAILABLE crapass   THEN
                     IF   LOCKED crapass  THEN
                          DO:
                            MESSAGE "Este processo já esta sendo executado." VIEW-AS ALERT-BOX INFO BUTTONS OK.
                            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                                glb_cdprogra + "' --> '" +
                                                "Este processo já esta sendo executado." + 
                                                " >> log/proc_batch.log").
                             glb_cdcritic = 99999.
                             MESSAGE "Solicitacao abortada.".
                             RETURN.
                             /* PAUSE 2 NO-MESSAGE.
                             NEXT. */
                          END.
                     ELSE
                          DO:
                              FIND crapccs WHERE 
                                           crapccs.cdcooper = glb_cdcooper AND
                                           crapccs.nrdconta = aux_nrdconta
                                           USE-INDEX crapccs1 NO-LOCK NO-ERROR.
                              
                              IF   AVAILABLE crapccs THEN
                                   DO:
                                       RUN p_trata_crapccs.
                                       ASSIGN aux_flgctsal = TRUE.
                                       LEAVE.
                                   END.
                              ELSE
                                   DO:
                                       glb_nrcalcul = aux_nrdconta.

                                       RUN fontes/digfun.p.
                                       IF   NOT glb_stsnrcal THEN
                                            glb_cdcritic = 8.
                                       ELSE
                                            glb_cdcritic = 9.
                                   END.         
                          END.
                ELSE
                     DO: 
                         RUN trata_cdempres (INPUT crapass.inpessoa,
                                             INPUT crapass.nrdconta).
                         
                         IF   aux_cdempres_2 <> aux_cdempsol   THEN
                              DO:
                                 IF   CAN-DO("00080,00081,00099",
                                             STRING(aux_cdempres_2,"99999"))
                                        AND
                                      (aux_cdempsol = 31 or aux_cdempsol = 90)
                                        THEN
                                      .
                                 ELSE    
                                      glb_cdcritic = 174.
                              END.
                         ELSE

                                                  /*-----
                         IF   crapass.dtdemiss <> ? THEN
                              glb_cdcritic = 075.
                         ELSE
                         -------*/
                         
                         IF   crapass.dtelimin <> ? THEN
                              glb_cdcritic = 410.
                         ELSE
                         IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                              glb_cdcritic = 695.
                         ELSE
                         IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                              DO:
                                  FIND FIRST craptrf WHERE
                                        craptrf.cdcooper = glb_cdcooper     AND
                                        craptrf.nrdconta = crapass.nrdconta AND
                                        craptrf.tptransa = 1                AND
                                        craptrf.insittrs = 2
                                        USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                                  IF   AVAILABLE craptrf THEN
                                       aux_nrdconta = craptrf.nrsconta.
                                  ELSE
                                       glb_cdcritic = 95.
                              END.
                     END.                              
             END.
             LEAVE.
      END.  /*  Fim do DO WHILE TRUE  */

      IF   aux_flgctsal THEN
           NEXT.

      IF   aux_flglotes   THEN
           DO:
               { includes/crps120_l.i }          /*  Leitura dos lotes  */

               aux_flglotes = FALSE.
           END.

      DO WHILE TRUE:

         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = aux_dtintegr   AND
                            craplot.cdagenci = aux_cdagenci   AND
                            craplot.cdbccxlt = aux_cdbccxlt   AND
                            craplot.nrdolote = aux_nrlotfol
                            USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplot   THEN
              IF   LOCKED craplot   THEN
                   DO:
                       PAUSE 2 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                       glb_cdcritic = 60.
                       RUN fontes/critic.p.
                       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                         " - " + glb_cdprogra + "' --> '" +
                                         glb_dscritic + " EMPRESA = " +
                                         STRING(aux_cdempsol,"99999") +
                                         " LOTE = " +
                                         STRING(aux_nrlotfol,"9,999") +
                                         " >> log/proc_batch.log").
                       UNDO TRANS_1, RETURN.
                   END.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      ASSIGN aux_nrdoclot = SUBSTRING(STRING(aux_nrlotfol,"999999"),2,5)
             aux_nrdocmto = INTEGER(aux_nrdoclot + STRING(aux_nrseqint,
                                                              "99999")).

      IF   glb_cdcritic = 0   AND
           aux_cdempres = 4   THEN
           IF   CAN-FIND(craplcm WHERE craplcm.cdcooper = glb_cdcooper     AND
                                       craplcm.nrdconta = aux_nrdconta     AND
                                       craplcm.dtmvtolt = craplot.dtmvtolt AND
                                       craplcm.cdhistor = aux_cdhistor     AND
                                       craplcm.nrdocmto = aux_nrdocmto
                                       USE-INDEX craplcm2)                 THEN
                DO:
                    glb_cdcritic = 285.
                    RUN fontes/critic.p.
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + glb_cdprogra + "' --> '" +
                                      glb_dscritic +
                                      " EMP = " + STRING(aux_cdempres) +
                                      " SEQ = " + STRING(aux_nrseqint) +
                                      " CONTA = " + STRING(aux_nrdconta) +
                                      " >> log/proc_batch.log").
                END.

      IF   glb_cdcritic > 0   THEN 
           DO:
               CREATE craprej.
               ASSIGN craprej.dtmvtolt = craplot.dtmvtolt
                      craprej.cdagenci = craplot.cdagenci
                      craprej.cdbccxlt = craplot.cdbccxlt
                      craprej.nrdolote = craplot.nrdolote
                      craprej.tplotmov = craplot.tplotmov
                      craprej.nrdconta = aux_nrdconta
                      craprej.cdempres = aux_cdempsol
                      craprej.cdhistor = aux_cdhistor
                      craprej.vllanmto = aux_vllanmto
                      craprej.cdcritic = glb_cdcritic
                      craprej.tpintegr = 1
                      craprej.cdcooper = glb_cdcooper

                      craplot.qtinfoln = craplot.qtinfoln + 1
                      craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto

                      glb_cdcritic     = 0.
               VALIDATE craprej.
           END.
      ELSE
           DO: /*  Credito do liquido de pagamento  */
                           
               IF   aux_vllanmto > 0 THEN
                    DO:

                        CREATE craplcm.
                        ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                               craplcm.cdagenci = craplot.cdagenci
                               craplcm.cdbccxlt = craplot.cdbccxlt
                               craplcm.nrdolote = craplot.nrdolote
                               craplcm.nrdconta = aux_nrdconta
                               craplcm.nrdctabb = aux_nrdconta
                               craplcm.nrdctitg = STRING(aux_nrdconta,
                                                         "99999999")
                               craplcm.nrdocmto = aux_nrdocmto
                               craplcm.cdhistor = aux_cdhistor
                               craplcm.vllanmto = aux_vllanmto
                               craplcm.nrseqdig = craplot.nrseqdig + 1
                               craplcm.cdcooper = glb_cdcooper

                               craplot.qtinfoln = craplot.qtinfoln + 1
                               craplot.qtcompln = craplot.qtcompln + 1
                              craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
                              craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
                               craplot.nrseqdig = craplcm.nrseqdig.
                        VALIDATE craplcm.

                    END.
                    
               IF   aux_dtrefere = glb_dtultdma   OR /* Somente criar crapfol*/
                    aux_dtrefere = glb_dtultdia   THEN /* se for folha mensal*/
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       FIND crapfol WHERE crapfol.cdcooper = glb_cdcooper AND
                                          crapfol.cdempres = aux_cdempres AND
                                          crapfol.nrdconta = aux_nrdconta AND
                                          crapfol.dtrefere = aux_dtrefere 
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                  
                       IF   NOT AVAILABLE crapfol   THEN
                            DO:
                               IF   LOCKED(crapfol)   THEN
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                               ELSE 
                                    DO:
                                        CREATE crapfol.
                                        ASSIGN crapfol.cdcooper = glb_cdcooper
                                               crapfol.cdempres = aux_cdempres
                                               crapfol.nrdconta = aux_nrdconta
                                               crapfol.dtrefere = aux_dtrefere
                                               crapfol.vllanmto = aux_vllanmto.
                                        VALIDATE crapfol.
                                        LEAVE.
                                    END.
                            END.
                       ELSE
                            ASSIGN crapfol.vllanmto = aux_vllanmto.
                       
                       LEAVE.
                    END. /* DO WHILE TRUE...... */
                
               ASSIGN tot_vlsalliq = aux_vllanmto
                      aux_flgdente = TRUE
                      tot_vldebemp = 0
                      tot_vldebsau = 0
                      tot_vldebcot = 0
                      tot_vldebden = 0
                      tot_vldebcta = 0
                      tot_vlhstsau = 0.   /* Valor individual do historico */

               /*  Atualiza o fator salarial  */

               IF   aux_flgatual   THEN
                    ASSIGN crapass.dtedvmto = aux_dtrefere
                           crapass.vledvmto =
                              IF NOT aux_flgsomar
                                 THEN ROUND((aux_vllanmto * 1.15) * 0.30,2)
                                 ELSE crapass.vledvmto +
                                      ROUND((aux_vllanmto * 1.15) * 0.30,2).

               IF   aux_cdhistor = 8   THEN
                    DO:

                         /*  Leitura dos avisos de debitos  */

                        { includes/crps120_9.i } 
                            
/*  Emprestimos  */         IF crapavs.cdhistor = 108 THEN
                               DO:
                                   ASSIGN 
                                       aux_vlsalliq = TRUNCATE(tab_txrdcpmf *
                                                      tot_vlsalliq,2)
                                       aux_vlpgempr = crapavs.vllanmto -
                                                      crapavs.vldebito
                                       aux_vldebtot = 0.
                                                  
                                   IF aux_vlsalliq > 0 THEN
                                      DO:
                                         RUN fontes/crps120_1.p
                                                (INPUT  crapavs.nrdconta,
                                                 INPUT  crapavs.nrdocmto,
                                                 INPUT  aux_nrlotemp,
                                                 INPUT  tab_inusatab,
                                                 INPUT  aux_vlpgempr,
                                                 INPUT  aux_vlsalliq,
                                                 INPUT  aux_dtintegr,
                                                 INPUT  95,
                                                 OUTPUT crapavs.insitavs,
                                                 OUTPUT aux_vldebtot,
                                                 OUTPUT crapavs.vlestdif,
                                                 OUTPUT crapavs.flgproce).

                                         IF glb_cdcritic > 0 THEN
                                            UNDO TRANS_1, RETURN.

                                         ASSIGN crapavs.vldebito =
                                                    crapavs.vldebito +
                                                    aux_vldebtot
                                                tot_vldebcta[108] =
                                                    tot_vldebcta[108] +
                                                    aux_vldebtot
                                                tot_vlsalliq =
                                                    tot_vlsalliq -
                                                TRUNC((1 + tab_txcpmfcc) *
                                                      aux_vldebtot,2).
                                      END.
                               END.       
                            ELSE          
/*  Planos de capital  */   IF   crapavs.cdhistor = 127   THEN
                                 DO:
                                     IF   tot_vlsalliq >= 0  THEN
                                          DO:
                                              RUN fontes/crps120_2.p
                                                     (INPUT  crapavs.nrdconta,
                                                      INPUT  crapavs.nrdocmto,
                                                      INPUT  aux_nrlotcot,
                                                      INPUT  crapavs.vllanmto,
                                                      INPUT  tot_vlsalliq,
                                                      INPUT  aux_dtintegr,
                                                      INPUT  crapass.dtdemiss,
                                                      INPUT  75,
                                                      OUTPUT crapavs.insitavs,
                                                      OUTPUT crapavs.vldebito,
                                                      OUTPUT crapavs.vlestdif,
                                                      OUTPUT aux_vldoipmf,
                                                      OUTPUT crapavs.flgproce).

                                              IF   glb_cdcritic > 0   THEN
                                                   UNDO TRANS_1, RETURN.

                                              /* Se efetuou o debito */ 
                                              ASSIGN tot_vldebcta[127] =
                                                         tot_vldebcta[127] +
                                                             crapavs.vldebito

                                                     tot_vlsalliq =
                                                         tot_vlsalliq -
                                                             crapavs.vldebito +
                                                             aux_vldoipmf.
                                          END.
                                 END.
                            ELSE
/*  P. Programada  */       IF  (crapavs.cdhistor = 160   OR
/*  Seguro Casa    */            crapavs.cdhistor = 175   OR
/*  Seguro Auto    */            crapavs.cdhistor = 199   OR
/*  Seguro Vida    */            crapavs.cdhistor = 341)  THEN
                                 ASSIGN crapavs.insitavs = 1
                                        crapavs.vldebito = crapavs.vllanmto
                                        crapavs.vlestdif = 0
                                        crapavs.flgproce = TRUE.
                            ELSE
/*  Demais historicos  */        DO:
                                     aux_vldebita = crapavs.vllanmto - 
                                                    crapavs.vldebito.
                                     IF   tot_vlsalliq >=
                                                TRUNCATE((1 + tab_txcpmfcc)
                                                     * aux_vldebita,2) THEN
                                          ASSIGN crapavs.insitavs = 1
                                                 crapavs.flgproce = TRUE
                                             crapavs.vldebito = crapavs.vllanmto
                                             crapavs.vlestdif = 0
                                             tot_vldebcta[crapavs.cdhistor] =
                                                tot_vldebcta[crapavs.cdhistor] +
                                                aux_vldebita
                                             tot_vlsalliq = tot_vlsalliq -
                                                  TRUNCATE((1 + tab_txcpmfcc) *
                                                    aux_vldebita,2).
                                 END.

                            IF   crapavs.vldebito = 0   AND
                                 crapavs.insitavs = 0   THEN
                                 crapavs.vlestdif = crapavs.vllanmto * -1.

                        END.  /*  Fim do FOR EACH -- Leitura dos avisos  */
                        
                        RUN fontes/crps120_d.p.   /*  Efetua os lancamentos  */

                        IF   glb_cdcritic > 0    THEN
                             UNDO TRANS_1, RETURN.
                    END.
           END.

      /*  Cria registro de restart  */

      DO WHILE TRUE:

         FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND
                            crapres.cdprogra = glb_cdprogra
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE crapres   THEN
              IF   LOCKED crapres   THEN
                   DO:
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                       glb_cdcritic = 151.
                       RUN fontes/critic.p.
                       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                         " - " + glb_cdprogra + "' --> '" +
                                         glb_dscritic +
                                         " >> log/proc_batch.log").
                       UNDO TRANS_1, RETURN.
                   END.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      ASSIGN crapres.nrdconta = aux_nrseqint
             crapres.dsrestar = STRING(rel_qttarifa,"999999") + " " +
                                STRING(aux_indmarca,"9").

   END.  /*  Fim da Transacao  */

END.   /*  Fim do DO WHILE TRUE  */

INPUT  STREAM str_2 CLOSE.

IF   glb_cdcritic = 0   THEN
     DO:
         RUN fontes/crps120_r.p.

         IF   glb_cdcritic > 0   THEN
              DO:
                  RUN fontes/critic.p.
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" + glb_dscritic +
                                    " >> log/proc_batch.log").
                  RETURN.
              END.

         glb_cdcritic = IF rel_qtdifeln = 0 THEN 190 ELSE 191.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           glb_dscritic + "' --> '" + aux_nmarqint +
                           " >> log/proc_batch.log").

         ASSIGN glb_nrcopias = 2
                glb_nmformul = "80col"
                glb_nmarqimp = aux_nmarquiv[aux_contaarq]
                aux_nmarqimp = glb_nmarqimp.

         /* Imprime na hora da solicitacao da tela SOL062 ou vai 
            para batch noturno */
         IF  glb_inproces = 1  THEN
             RUN gerar_impressao.
         ELSE
             RUN fontes/imprim.p.

         /*  Exclui rejeitados apos a impressao  */

         TRANS_2:

         FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper   AND
                                craprej.dtmvtolt = aux_dtmvtolt   AND
                                craprej.cdagenci = aux_cdagenci   AND
                                craprej.cdbccxlt = aux_cdbccxlt   AND
                                craprej.nrdolote = aux_nrlotfol   AND
                                craprej.cdempres = aux_cdempsol   AND
                                craprej.tpintegr = 1 EXCLUSIVE-LOCK
                                TRANSACTION ON ERROR UNDO TRANS_2, RETURN:

             DELETE craprej. 

         END.   /*  Fim do FOR EACH e da transacao  */

         TRANS_3:

         DO TRANSACTION ON ERROR UNDO TRANS_3, RETURN:

            DO WHILE TRUE:

               FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND
                                  crapres.cdprogra = glb_cdprogra
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   NOT AVAILABLE crapres   THEN
                    IF   LOCKED crapres   THEN
                         DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE
                         DO:
                             glb_cdcritic = 151.
                             RUN fontes/critic.p.
                             UNIX SILENT
                                  VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + "' --> '" +
                                        glb_dscritic +
                                        " >> log/proc_batch.log").
                             UNDO TRANS_3, RETURN.
                         END.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            ASSIGN crapres.nrdconta = 0
                   crapres.dsrestar = ""
                   glb_cdcritic     = 0.

         END.  /*  Fim da transacao  */

     END.  /*  Fim da impressao do relatorio  */





PROCEDURE p_trata_crapccs:
       
    aux_nrdocmto = INTEGER(STRING(aux_nrseqint,"99999")).
    
    DO WHILE TRUE:

       IF   crapccs.cdsitcta = 2 THEN
            glb_cdcritic = 444.
       ELSE
       IF   crapccs.dtcantrf <> ? THEN
            glb_cdcritic = 890.
          
       LEAVE.
    END.

    TRANS_4:

    DO TRANSACTION ON ERROR UNDO TRANS_4, RETURN:

       IF   aux_flfirst2 THEN
            aux_nrlotccs = 10201.

       DO WHILE TRUE:
         
          FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                             craplot.dtmvtolt = aux_dtintegr   AND
                             craplot.cdagenci = 1              AND
                             craplot.cdbccxlt = 100            AND
                             craplot.nrdolote = aux_nrlotccs
                             USE-INDEX craplot1 NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE craplot  THEN
               DO:
                   IF   NOT LOCKED craplot   THEN
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.cdcooper = glb_cdcooper
                                   craplot.dtmvtolt = aux_dtintegr
                                   craplot.cdagenci = 1
                                   craplot.cdbccxlt = 100
                                   craplot.nrdolote = aux_nrlotccs
                                   craplot.tplotmov = 32
                                   aux_flfirst2     = FALSE.
                            VALIDATE craplot.
                            LEAVE.
                        END.
                   ELSE
                        DO:
                            IF   NOT aux_flfirst2 THEN
                                 DO:
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                 END.
                        END.
               END.         
          ELSE
               IF   aux_flfirst2 THEN
                    aux_nrlotccs = aux_nrlotccs + 1.
               ELSE
                    LEAVE.
       END.
          
       IF   glb_cdcritic > 0   THEN
            DO:
                CREATE craprej.
                ASSIGN craprej.dtmvtolt = aux_dtmvtolt
                       craprej.cdagenci = craplot.cdagenci
                       craprej.cdbccxlt = craplot.cdbccxlt
                       craprej.nrdolote = craplot.nrdolote
                       craprej.tplotmov = craplot.tplotmov
                       craprej.nrdconta = aux_nrdconta
                       craprej.cdempres = aux_cdempres
                       craprej.cdhistor = aux_cdhistor
                       craprej.vllanmto = aux_vllanmto
                       craprej.cdcritic = glb_cdcritic
                       craprej.tpintegr = 1
                       craprej.cdcooper = glb_cdcooper
                      
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto

                       glb_cdcritic     = 0.
                VALIDATE craprej.
            END.
       ELSE
            DO:
                aux_nrdocmt2 = aux_nrdocmto.
                
                DO WHILE TRUE:
                                
                   FIND craplcs WHERE craplcs.cdcooper = glb_cdcooper   AND
                                      craplcs.dtmvtolt = aux_dtintegr   AND
                                      craplcs.nrdconta = aux_nrdconta   AND
                                      craplcs.cdhistor = 560            AND
                                      craplcs.nrdocmto = aux_nrdocmt2
                                      NO-LOCK NO-ERROR NO-WAIT.

                   IF   AVAILABLE craplcs THEN
                        aux_nrdocmt2 = (aux_nrdocmt2 + 1000000).
                   ELSE
                        LEAVE.
          
                END.  /*  Fim do DO WHILE TRUE  */

                aux_nrdocmto = aux_nrdocmt2.
          
                CREATE craplcs.
                ASSIGN craplcs.cdcooper = glb_cdcooper
                       craplcs.cdopecrd = glb_cdoperad
                       craplcs.dtmvtolt = aux_dtintegr
                       craplcs.nrdconta = aux_nrdconta
                       craplcs.nrdocmto = aux_nrdocmto
                       craplcs.vllanmto = aux_vllanmto
                       craplcs.cdhistor = 560
                       craplcs.nrdolote = craplot.nrdolote 
                       craplcs.cdbccxlt = craplot.cdbccxlt
                       craplcs.cdagenci = craplot.cdagenci

                       craplcs.flgenvio = FALSE
                       craplcs.cdopetrf = ""
                       craplcs.dttransf = ?
                       craplcs.hrtransf = 0
                       craplcs.nmarqenv = ""
                          
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
                       craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
                       craplot.nrseqdig = aux_nrseqint.
                VALIDATE craplcs.
            END.
                              
       DO WHILE TRUE:

          FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                             crapres.cdprogra = glb_cdprogra
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE crapres   THEN
               IF   LOCKED crapres   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 151.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic +
                                          " >> log/proc_batch.log").
                        UNDO TRANS_4, RETURN.
                    END.
          LEAVE.

       END.  /*  Fim do DO WHILE TRUE  */

       crapres.nrdconta = aux_nrseqint.

    END.  /*  Fim da Transacao  */

END PROCEDURE.


PROCEDURE trata_cdempres:

  DEF INPUT PARAM par_inpessoa AS INT  NO-UNDO.
  DEF INPUT PARAM par_nrdconta AS INT  NO-UNDO.

  ASSIGN aux_cdempres_2 = 0.
  
  IF   par_inpessoa = 1  THEN
       DO:
           FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper  AND
                              crapttl.nrdconta = par_nrdconta  AND
                              crapttl.idseqttl = 1  NO-LOCK NO-ERROR.
                               
           IF   AVAIL crapttl  THEN
                ASSIGN aux_cdempres_2 = crapttl.cdempres.
       END.
  ELSE
       DO:
           FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                              crapjur.nrdconta = par_nrdconta
                              NO-LOCK NO-ERROR.
                                      
           IF   AVAIL crapjur  THEN
                ASSIGN aux_cdempres_2 = crapjur.cdempres.
       END.

END PROCEDURE.

PROCEDURE gerar_impressao.
    { includes/impressao.i }
END.

/* .......................................................................... */
