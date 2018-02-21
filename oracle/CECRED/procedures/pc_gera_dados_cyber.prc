CREATE OR REPLACE PROCEDURE CECRED.pc_gera_dados_cyber(pr_dscritic OUT VARCHAR2) IS
BEGIN 

/* .............................................................................

  Programa: PC_GERA_DADOS_CYBER
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : 
  Data    : 2017.                                     Ultima atualizacao: 16/01/2018
  Dados referentes ao programa:
    Frequencia: Diaria. Seg-sex, 08h
    Programa Chamador: JBCYB_GERA_DADOS_CYBER

  Alteracoes: 14/11/2017 - Log de trace da exception others e retorno de crítica para
                           o programa chamador (Carlos)

              09/01/2018 - #826598 Tratamento para enviar e-mail e abrir chamado quando 
                           ocorrer erro na execução do programa pc_crps652 (Carlos)

              16/01/2018 - Quando chegar reagendamento não retornar mensagem de erro.
                           A solução definitiva será em novo chamado e a GENE0004 pode retonar
                           alem do codigo da mensagem um indicador de tipo de mensagem para não dar erro.
                           (Envolti - Belli - Chamado 831545)
                           
  .............................................................................. */  

  DECLARE
    
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    vr_cdcooper INTEGER := 3; --CECRED PQ O 652 RODA PRA TODAS COOP A PARTIR DELA 
    vr_dtmvtolt DATE;
    vr_stprogra INTEGER;
    vr_infimsol INTEGER;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_dserro   VARCHAR2(4000);
    vr_tab_erro GENE0001.typ_tab_erro;      
    vr_exc_erro EXCEPTION;
                                      
    vr_cdprogra    VARCHAR2(40) := 'PC_GERA_DADOS_CYBER';
    vr_nomdojob    VARCHAR2(40) := 'JBCYB_GERA_DADOS_CYBER';
    vr_flgerlog    BOOLEAN := FALSE;
    vr_dthoje      DATE := TRUNC(SYSDATE);

    vr_dstexto VARCHAR2(2000);
    vr_titulo VARCHAR2(1000);
    vr_destinatario_email VARCHAR2(500);
    vr_idprglog   tbgen_prglog.idprglog%TYPE;

    --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => vr_cdcooper    --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
    END pc_controla_log_batch;
    
  BEGIN     
    
    -- Log de inicio de execucao
    pc_controla_log_batch(pr_dstiplog => 'I');
    
    -- SD#497991
    -- validação copiada de TARI0001
    -- Verificar se a data atual é uma data util, se retornar uma data diferente
    -- indica que não é um dia util, então deve sair do programa sem executar ou reprogramar
    IF gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
                                  ,pr_dtmvtolt => vr_dthoje) = vr_dthoje THEN -- SD#497991

      gene0004.pc_executa_job( pr_cdcooper => vr_cdcooper   --> Codigo da cooperativa
                              ,pr_fldiautl => 1   --> Flag se deve validar dia util
                              ,pr_flproces => 1   --> Flag se deve validar se esta no processo
                              ,pr_flrepjob => 1   --> Flag para reprogramar o job
                              ,pr_flgerlog => 1   --> indicador se deve gerar log
                              ,pr_nmprogra => 'pc_gera_dados_cyber' --> Nome do programa que esta sendo executado no job
                              ,pr_dscritic => vr_dserro);

      -- se nao retornou critica chama rotina
      IF trim(vr_dserro) IS NULL THEN
        
        OPEN btch0001.cr_crapdat(3);
        FETCH btch0001.cr_crapdat  INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
          
        --Verifica o dia util da cooperativa e caso nao for pula a coop
        vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper  => vr_cdcooper
                                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                                  ,pr_tipo      => 'A');
                                                    
        IF vr_dtmvtolt <> rw_crapdat.dtmvtolt THEN
           vr_cdcritic := 0;
           vr_dscritic := 'Data da cooperativa diferente da data atual.';
           RAISE vr_exc_erro; 
        END IF;                                          
         
        pc_crps652(pr_cdcooper => vr_cdcooper
                  ,pr_nmtelant => ' '
                  ,pr_flgresta => 0
                  ,pr_stprogra => vr_stprogra
                  ,pr_infimsol => vr_infimsol
                  ,pr_cdcritic => vr_cdcritic 
                  ,pr_dscritic => vr_dscritic);
                                         
        IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
           
          -- Abrir chamado - Texto para utilizar na abertura do chamado e no email enviado
          vr_dstexto := to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_nomdojob || ' --> ' ||
                       'Erro na execucao do programa. Critica: ' || nvl(vr_dscritic,' ');

          -- Parte inicial do texto do chamado e do email
          vr_titulo := '<b>Abaixo os erros encontrados no job ' || vr_nomdojob || '</b><br><br>';

          -- Buscar e-mails dos destinatarios do produto cyber
          vr_destinatario_email := gene0001.fn_param_sistema('CRED',vr_cdcooper,'CYBER_RESPONSAVEL');

          cecred.pc_log_programa(
              PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
             ,PR_CDPROGRAMA    => vr_nomdojob   --> Codigo do programa ou do job
             ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
             -- Parametros para Ocorrencia
             ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
             ,pr_cdcriticidade => 2             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
             ,pr_dsmensagem    => vr_dstexto    --> dscritic       
             ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
             ,pr_flabrechamado => 1             --> Abrir chamado (Sim=1/Nao=0)
             ,pr_texto_chamado => vr_titulo
             ,pr_destinatario_email => vr_destinatario_email
             ,pr_flreincidente => 1             --> Erro pode ocorrer em dias diferentes, devendo abrir chamado
             ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)
           
           RAISE vr_exc_erro; 
        END IF;
      
      ELSE
        -- Não retornar o erro - Chamado 831545 - 16/01/2018
        IF vr_dserro NOT LIKE '%Processo noturno nao finalizado para cooperativa%' THEN
        vr_cdcritic := 0;
        vr_dscritic := vr_dserro;
        RAISE vr_exc_erro;  
      END IF;
      END IF;

    END IF; 

    -- Log de fim de execucao
    pc_controla_log_batch(pr_dstiplog => 'F');

  EXCEPTION
    WHEN vr_exc_erro THEN  

      pr_dscritic := vr_dscritic;

      GENE0001.pc_gera_erro(pr_cdcooper => vr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 100
                           ,pr_nrsequen => 1 /** Sequencia **/
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);
                             
      --vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Log de erro de execucao
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => vr_dscritic);

      ROLLBACK;
        
    WHEN OTHERS THEN     
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper, 
                                   pr_compleme => vr_dscritic);

      pr_dscritic := vr_dscritic;
      
      -- Erro
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro na rotina pc_gera_dados_cyber. '||sqlerrm;

      GENE0001.pc_gera_erro(pr_cdcooper => vr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 100
                           ,pr_nrsequen => 1 /** Sequencia **/
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);

      --vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Log de erro de execucao
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => vr_dscritic);
      ROLLBACK;                             
        
  END;          
END pc_gera_dados_cyber;
/
