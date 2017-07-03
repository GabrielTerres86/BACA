CREATE OR REPLACE PROCEDURE CECRED.pc_crps718(pr_cdcooper  IN craptab.cdcooper%type,
                                              pr_nrdconta  IN crapcob.nrdconta%TYPE,                                              
                                              pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                              pr_dscritic OUT VARCHAR2) AS

  /******************************************************************************
    Programa: pc_crps718 
    Sistema : Cobranca - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Rafael Cechet
    Data    : abril/2017.                     Ultima atualizacao: 17/04/2017
 
    Dados referentes ao programa:
 
    Frequencia: Diario.
    Objetivo  : Buscar confirmacao de registros e intrucoes
                comandadas dos titulos na CIP.
    
    Observacoes: Horario de execucao: todos os dias, das 6:00h as 21:00h
                                      a cada 2 minutos.
                                      
    Alteracoes: 
  ******************************************************************************/
  -- CONSTANTES
  vr_cdprogra     CONSTANT VARCHAR2(10) := 'crps718';     -- Nome do programa
  vr_dsarqlog     CONSTANT VARCHAR2(12) := 'crps718.log'; -- Nome do arquivo de log

  -- CURSORES 
  -- Buscar as cooperativas para processamento
  -- Quanto a cooperativa do parametro for 3, ira processar todas as coops 
  -- exceto CECRED, quando outra cooperativa for informada, gerar para a propria
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
         , cop.cdbcoctl
         , cop.cdagectl
      FROM crapcop cop
     WHERE cop.cdcooper = 3;  
    
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  -- VARIÁVEIS
  vr_cdcritic           NUMBER;
  vr_dscritic           VARCHAR2(1000);

  vr_flgerlog           BOOLEAN;
  vr_cdcooper           crapcop.cdcooper%TYPE;
  
  -- EXCEPTIONS
  vr_exc_saida          EXCEPTION;               
  
  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    vr_dscritic_aux VARCHAR2(4000);
  BEGIN
  
    --> Apenas gerar log se for processo batch/job ou erro  
    IF nvl(pr_nrdconta,0) = 0 OR pr_dstiplog = 'E' THEN
    
      vr_dscritic_aux := pr_dscritic;
      
      --> Se é erro e possui conta, concatenar o numero da conta no erro
      IF pr_nrdconta <> 0 THEN
        vr_dscritic_aux := vr_dscritic_aux||' - Conta: '||pr_nrdconta;
      END IF;
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_cdprogra    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => vr_dscritic_aux    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  
    END IF;
  END pc_controla_log_batch;
  
  /**********************************************************/
   
BEGIN
  
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_'||UPPER(vr_cdprogra),
                             pr_action => vr_cdprogra);
  
  
 
  -- Percorrer as cooperativas
  FOR rw_crapcop IN cr_crapcop LOOP
  
    /* Busca data do sistema */ 
    OPEN  BTCH0001.cr_crapdat(rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    -- Fechar 
    CLOSE BTCH0001.cr_crapdat;
    
    --> se ainda estiver rodando o processo batch
    -- nao deve rodar o programa
    IF rw_crapdat.inproces <> 1 THEN
      continue;
    END IF;
    
    -- Log de início da execução
    pc_controla_log_batch(pr_cdcooper  => rw_crapcop.cdcooper,
                          pr_dstiplog  => 'I');
    
    --> variavel apenas para controle do log, caso seja abortado o programa
    vr_cdcooper := rw_crapcop.cdcooper;                
    
    --> Buscar retorno operacao Titulos NPC
    DDDA0001.pc_retorno_operacao_tit_NPC(pr_cdcritic => vr_cdcritic  --Codigo de Erro
                                        ,pr_dscritic => vr_dscritic); --Descricao de Erro    
                                        
    -- Verifica se ocorreu erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    COMMIT;                                          
    
    -- Log de fim da execução
    pc_controla_log_batch(pr_cdcooper  => rw_crapcop.cdcooper,
                          pr_dstiplog  => 'F');    
                                                  
  END LOOP; -- Fim loop cooperativas   
  
EXCEPTION
  WHEN vr_exc_saida THEN
      
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    
    -- Log de erro início da execução
    pc_controla_log_batch(pr_cdcooper  => vr_cdcooper,
                          pr_dstiplog  => 'F',
                          pr_dscritic  => pr_dscritic);
    
    
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
      
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    
    -- Log de erro início da execução
    pc_controla_log_batch(pr_cdcooper  => vr_cdcooper,
                          pr_dstiplog  => 'F',
                          pr_dscritic  => pr_dscritic);
    
    -- Efetuar rollback
    ROLLBACK;
END pc_crps718;
/
