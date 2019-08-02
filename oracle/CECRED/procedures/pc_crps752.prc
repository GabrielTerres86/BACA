CREATE OR REPLACE PROCEDURE CECRED.pc_crps752(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
                                             
  /* .............................................................................

     Programa: pc_crps752
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Setembro/2018                       Ultima atualizacao: 25/04/2019

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Solicitação 001
                 Processamento dos prejuizos de conta corrente, como pagamento e liquidação.

     Alteracoes: 25/04/2019 - P450 - Inclusão de chamdaa da "PREJ0006.pc_processa_debt_inc_prj" para processar os débitos 
                              ocorridos no dia e incrementar o saldo do prejuízo (quando aplicável).
                              Reginaldo/AMcom
         
  ............................................................................ */



  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS752';

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);
  vr_tab_erro   GENE0001.typ_tab_erro;

  ------------------------------- CURSORES ---------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdbcoctl
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;


  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  

  ------------------------------- VARIAVEIS -------------------------------
  vr_dserro   VARCHAR2(10000);
  vr_dstexto  VARCHAR2(2000);
  vr_titulo   VARCHAR2(1000);
  vr_destinatario_email VARCHAR2(500);
  vr_idprglog   tbgen_prglog.idprglog%TYPE;
  
  

BEGIN

  --------------- VALIDACOES INICIAIS -----------------

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);
  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop;
  FETCH cr_crapcop
   INTO rw_crapcop;
  -- Se não encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois haverá raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;

  -- Leitura do calendário da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;

  -- Se não encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE btch0001.cr_crapdat;
  END IF;

  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se a variavel de erro é <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
  -- Se as regras de prejuízo de conta corrente estão ativas para a cooperativa
  IF PREJ0003.fn_verifica_flg_ativa_prju(pr_cdcooper) = FALSE THEN
    vr_dscritic := 'Prejuizo de conta corrente não esta ativo para esta cooperativa.';
    RAISE vr_exc_fimprg;  
  END IF;
  
  -- Processa os débitos ocorridos no dia na conta corrente e incrementa o saldo do prejuízo
  PREJ0006.pc_processa_debt_inc_prj(pr_cdcooper => pr_cdcooper);
  
  --> Verificar se é o ultimo dia do mês
  IF to_char(rw_crapdat.dtmvtolt,'MM') <> to_char(rw_crapdat.dtmvtopr,'MM') THEN
  
    -- Calcula e debita da corrente corrente em prejuízo os juros remuneratórios
    PREJ0003.pc_calc_juro_prejuizo_mensal( pr_cdcooper => pr_cdcooper
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
                                              
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;    
    END IF;                                          
  END IF;                                          

  -- Resgata créditos bloqueados em contas em prejuízo não movimentados há mais de X dias
  PREJ0003.pc_resgata_cred_bloq_preju ( pr_cdcooper => pr_cdcooper
                                       , pr_cdcritic => vr_cdcritic
                                       , pr_dscritic => vr_dscritic);

  IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;    
  END IF;
    
  -- Efetua o pagamento automático do prejuízo com os créditos disponíveis para operações na conta corrente
  PREJ0003.pc_pagar_prejuizo_cc_autom( pr_cdcooper => pr_cdcooper
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_tab_erro => vr_tab_erro );

  IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;    
  END IF;
  
  -- Processa liquidação do prejuízo para contas corrente que tiveram todo o saldo de prejuízo pago
  PREJ0003.pc_liquida_prejuizo_cc( pr_cdcooper => pr_cdcooper
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tab_erro => vr_tab_erro );
  
  IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;    
  END IF;

  ----------------- ENCERRAMENTO DO PROGRAMA -------------------

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informações atualizadas
  COMMIT;
      
EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || vr_dscritic );
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit
    COMMIT;
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas das variaveis locais
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
    
    
    -- Abrir chamado - Texto para utilizar na abertura do chamado e no email enviado
    vr_dstexto := to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' ||
                 'Erro na execucao do programa. Critica: ' || nvl(vr_dscritic,' ');

    -- Parte inicial do texto do chamado e do email
    vr_titulo := '<b>Abaixo os erros encontrados na rotina ' || vr_cdprogra || '</b><br><br>';

    -- Buscar e-mails dos destinatarios do produto cyber
    vr_destinatario_email := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CYBER_RESPONSAVEL');

    cecred.pc_log_programa( PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                           ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                           ,pr_tpexecucao    => 1             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
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

    
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
    
    -- Abrir chamado - Texto para utilizar na abertura do chamado e no email enviado
    vr_dstexto := to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' ||
                 'Erro na execucao do programa. Critica: ' || nvl(vr_dscritic,' ');

    -- Parte inicial do texto do chamado e do email
    vr_titulo := '<b>Abaixo os erros encontrados na rotina ' || vr_cdprogra || '</b><br><br>';

    -- Buscar e-mails dos destinatarios do produto cyber
    vr_destinatario_email := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CYBER_RESPONSAVEL');

    cecred.pc_log_programa( PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                           ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                           ,pr_tpexecucao    => 1             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
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

    


END pc_crps752;
/
