CREATE OR REPLACE PROCEDURE CECRED.pc_crps783(pr_cdcooper IN crapcop.cdcooper%TYPE
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  /*..............................................................................

    Programa: pc_crps783                      
    Sistema : Empréstimos - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Pagel - AMcom
    Data    : Julho/2019                  Ultima Atualizacao :

    Dados referente ao programa:

    Frequencia : Diário (JOB).
    Objetivo   : Gerar arquivo com propostas de emprestimo que excederam o reenvio automático 
                 para o Motor/Esteira .

    Alteracoes : 
  ..............................................................................*/

  ------------------------------- VARIAVEIS -------------------------------

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  
  -- Auxiliares para o processamento 
  -- Código do programa
  vr_cdprogra           CONSTANT crapprg.cdprogra%TYPE := 'CRPS783';
  vr_nomdojob           CONSTANT VARCHAR2(30)          := 'JBEPR_REENVIO_ANALISE_REL';
  vr_flgerlog           BOOLEAN;
  
  ---------------------------------- CURSORES  ----------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper = DECODE(pr_cdcooper,0,cop.cdcooper,pr_cdcooper) -- Se passado zero, traz todas 
       AND cop.flgativo = 1  -- Somente ativas
       AND cop.cdcooper <> 3
       ORDER BY cdcooper;

  ------------------------------- REGISTROS -------------------------------
    rw_crapcop cr_crapcop%ROWTYPE;
  
  ------------------------- PROCEDIMENTOS INTERNOS -----------------------------   
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2,
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        
    END pc_controla_log_batch;
    
  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'I');
    
    FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP
      ESTE0001.pc_email_reenvio_analise(pr_cdcooper => rw_crapcop.cdcooper  
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
      --Verifica retorno de erro                                
      IF vr_dscritic IS NOT NULL OR vr_cdcritic > 0 THEN
        RAISE vr_exc_saida;
      END IF;       
    END LOOP;                              
        
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------                                                     
  
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'F');

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);
    
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
    raise_application_error(-20500,vr_dscritic);
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    vr_dscritic := SQLERRM;                           
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);
    pr_dscritic := vr_dscritic;                      
    -- Efetuar rollback
    ROLLBACK;
    raise_application_error(-20500,vr_dscritic);
    
End pc_crps783;
/
