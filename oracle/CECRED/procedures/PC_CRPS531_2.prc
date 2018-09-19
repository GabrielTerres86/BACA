CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS531_2 (pr_idorigem      IN VARCHAR2              --> Origem do conteúdo (E-Envio / R-Recebimento)
                                                ,pr_tpmensagem    IN VARCHAR2              --> Tipo de mensagem (COA / COD)
                                                ,pr_nrcontrole    IN VARCHAR2              --> Nr.controle de envio/recebimento
                                                ,pr_dhdthr_bc     IN VARCHAR2              --> Data/Hora de postagem pelo BACEN, Somente recebimento 'yyyy-dd-mm hh:mi:ss'
                                                ,pr_cdcritic     OUT CRAPCRI.CDCRITIC%TYPE --> Critica encontrada
                                                ,pr_dscritic     OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
/* ............................................................................

   Programa: PC_CRPS531_2
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Everton Souza
   Data    : Setembro/2018.                     Ultima atualizacao:


   Frequencia : Sempre que for chamado.
   Objetivo   : Integrar mensagens(COA/COD) recebidas do JDSPB.
                Projeto 475 - MELHORIAS SPB CONTINGÊNCIA


   Alteracoes:

   ............................................................................ */
    -- Tratamento de erros
    vr_cdcritic            NUMBER;
    vr_dscritic            VARCHAR2(4000);
    vr_des_erro            VARCHAR2(4000);
    vr_exc_saida           EXCEPTION;

    -- Variaveis de Trabalho
    vr_logprogr            VARCHAR2(1000);
    vr_cdfase              TBSPB_MSG_ENVIADA_FASE.CDFASE%TYPE;
    vr_cdfase1             TBSPB_MSG_ENVIADA_FASE.CDFASE%TYPE;
    vr_nmmensagem          TBSPB_MSG_ENVIADA_FASE.NMMENSAGEM%TYPE;
    vr_nrseq_mensagem      TBSPB_MSG_ENVIADA_FASE.NRSEQ_MENSAGEM%TYPE;
    vr_nrseq_mensagem_fase TBSPB_MSG_ENVIADA_FASE.NRSEQ_MENSAGEM_FASE%TYPE;
    vr_dhdthr_bc           DATE;


   BEGIN -- inicio principal
     --
     vr_logprogr :=  'crps531_'||to_char(SYSDATE,'DDMMRRRR');
     --
     vr_cdfase1 := NULL;
     --
     IF pr_idorigem = 'E' THEN
       vr_nmmensagem := ' - ENVIO';
       --
       IF pr_tpmensagem = 'COA' THEN
         vr_cdfase := 30;
       ELSIF pr_tpmensagem = 'COD' THEN
         vr_cdfase := 35;
       ELSE
         vr_dscritic := 'Envio - Tipo de mensagem diferente de COA/COD - '||pr_tpmensagem||'!';
         RAISE vr_exc_saida;
       END IF;
     ELSIF pr_idorigem = 'R' THEN
       vr_nmmensagem := ' - RECEBIDO';
       --
       IF TRIM(pr_dhdthr_bc) IS NOT NULL THEN
         vr_dhdthr_bc := TO_DATE(SUBSTR(pr_dhdthr_bc,1,10)||' '||SUBSTR(pr_dhdthr_bc,12,8),'yyyy-mm-dd hh24:mi:ss');
       ELSE
         vr_dhdthr_bc := NULL;
       END IF;
       --
       IF pr_tpmensagem = 'COA' THEN
         vr_cdfase  := 105;
       ELSIF pr_tpmensagem = 'COD' THEN
         vr_cdfase  := 110;
       ELSE
         vr_dscritic := 'Recebimento - Tipo de mensagem diferente de COA/COD - '||pr_tpmensagem||'!';
         RAISE vr_exc_saida;
       END IF;
       --
       IF vr_dhdthr_bc IS NOT NULL THEN
         IF pr_tpmensagem = 'COA' THEN
           vr_cdfase1 := 100;
         ELSIF pr_tpmensagem = 'COD' THEN
           vr_cdfase1 := NULL;
         ELSE
           vr_dscritic := 'Recebimento - Tipo de mensagem diferente de COA/COD - '||pr_tpmensagem||'!';
           RAISE vr_exc_saida;
         END IF;
       END IF;
     ELSE
       vr_dscritic := 'Origem da mensagem diferente de E/R - '||pr_idorigem||'!';
       RAISE vr_exc_saida;
     END IF;
     --
     IF  pr_nrcontrole IS NULL
     THEN
       vr_dscritic := 'PC_CRPS531_2 - Numero de controle esta nulo - Origem = '||pr_idorigem||'!';
       RAISE vr_exc_saida;
     END IF;
     vr_nmmensagem := pr_tpmensagem || vr_nmmensagem;
     --
     IF vr_cdfase1 IS NOT NULL THEN
       SSPB0003.pc_grava_trace_spb (pr_cdfase                 => vr_cdfase1
                                   ,pr_idorigem               => pr_idorigem
                                   ,pr_nmmensagem             => 'HORA BACEN'
                                   ,pr_nrcontrole             => pr_nrcontrole
                                   ,pr_nrcontrole_str_pag     => NULL
                                   ,pr_nrcontrole_dev_or      => NULL
                                   ,pr_dhmensagem             => vr_dhdthr_bc
                                   ,pr_insituacao             => 'OK'
                                   ,pc_dhdthr_bc              => vr_dhdthr_bc
                                   ,pr_dsxml_mensagem         => NULL
                                   ,pr_dsxml_completo         => NULL
                                   ,pr_nrseq_mensagem_xml     => NULL
                                   ,pr_nrdconta               => NULL
                                   ,pr_cdcooper               => NULL
                                   ,pr_cdproduto              => 30 -- TED
                                   ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                   ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                   ,pr_dscritic               => vr_dscritic
                                   ,pr_des_erro               => vr_des_erro
                                   );
       IF vr_dscritic IS NOT NULL THEN
         raise vr_exc_saida;
       END IF;
       COMMIT;
     END IF;
     SSPB0003.pc_grava_trace_spb (pr_cdfase                 => vr_cdfase
                                 ,pr_idorigem               => pr_idorigem
                                 ,pr_nmmensagem             => vr_nmmensagem
                                 ,pr_nrcontrole             => pr_nrcontrole
                                 ,pr_nrcontrole_str_pag     => NULL
                                 ,pr_nrcontrole_dev_or      => NULL
                                 ,pr_dhmensagem             => SYSDATE
                                 ,pr_insituacao             => 'OK'
                                 ,pr_dsxml_mensagem         => NULL
                                 ,pr_dsxml_completo         => NULL
                                 ,pr_nrseq_mensagem_xml     => NULL
                                 ,pr_nrdconta               => NULL
                                 ,pr_cdcooper               => NULL
                                 ,pr_cdproduto              => 30 -- TED
                                 ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                 ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                 ,pr_dscritic               => vr_dscritic
                                 ,pr_des_erro               => vr_des_erro
                                 );
     IF vr_dscritic IS NOT NULL THEN
       raise vr_exc_saida;
     END IF;
     --
     COMMIT;

   EXCEPTION
   WHEN vr_exc_saida THEN
      -- Efetuar retorno do erro não tratado
      -- Iniciar LOG de execução
      BTCH0001.pc_gera_log_batch(pr_cdcooper      => 3
                                ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                  ||' - '|| 'crps531' ||' --> '
                                                  ||'Erro execucao - '
                                                  || 'Nr.Controle IF: ' || pr_nrcontrole || ' '
                                                  || 'Mensagem: ' || vr_nmmensagem || ' '
                                                  || 'Na Rotina PC_CRPS531_2 --> '||vr_dscritic
                                ,pr_nmarqlog      => vr_logprogr
                                ,pr_cdprograma    => 'crps531'
                                ,pr_dstiplog      => 'E'
                                ,pr_tpexecucao    => 3
                                ,pr_cdcriticidade => 0
                                ,pr_flgsucesso    => 1
                                ,pr_cdmensagem    => vr_cdcritic);
      -- Efetuar rollback
      ROLLBACK;

   WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral PC_CRPS531_2 - '||sqlerrm;
      -- Iniciar LOG de execução
      BTCH0001.pc_gera_log_batch(pr_cdcooper      => 3
                                ,pr_ind_tipo_log  => 3 -- Erro não tratado
                                ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                  ||' - '|| 'crps531' ||' --> '
                                                  ||'Erro execucao - '
                                                  || 'Nr.Controle IF: ' || pr_nrcontrole || ' '
                                                  || 'Mensagem: ' || vr_nmmensagem || ' '
                                                  || 'Na Rotina PC_CRPS531_2 --> '||vr_dscritic
                                ,pr_nmarqlog      => vr_logprogr
                                ,pr_cdprograma    => 'crps531'
                                ,pr_dstiplog      => 'E'
                                ,pr_tpexecucao    => 3
                                ,pr_cdcriticidade => 0
                                ,pr_flgsucesso    => 1
                                ,pr_cdmensagem    => vr_cdcritic);
      -- Efetuar rollback
      ROLLBACK;

END PC_CRPS531_2;
/
