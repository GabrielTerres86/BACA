CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS500" (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Coop conectada
                                                ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                                ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                                ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                                ,pr_dscritic OUT VARCHAR2) AS           --> Texto de erro/critica encontrada
    /* ............................................................................

     Programa: PC_CRPS500 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rangel Decker
     Data    : Maio/2018                       Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Quando for chamado
     Objetivo  : Transferencia de contas em prejuizo

     Alteracoes: 
  ..............................................................................*/
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Erro para parar a cadeia
      vr_exc_saida exception;
      -- Erro sem parar a cadeia
      vr_exc_fimprg exception;

      ---------------- Cursores genéricos ----------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Variável genérica de calendário com base no cursor da btch0001
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Variável para retorno de busca na craptab
      vr_dstextab craptab.dstextab%TYPE;

      -- Variáveis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE;--> Número da conta de restart
      vr_dsrestar VARCHAR2(4000);       --> String genérica com informações para restart
      vr_inrestar INTEGER;              --> Indicador de Restart

      -- Valor de arrastro cfme parâmetros
      vr_vlr_arrasto NUMBER;

      vr_cdcritic crapcri.cdcritic%TYPE; --> Codigo da critica
      vr_dscritic VARCHAR2(2000);        --> Descricao da critica

      vr_tab_erro  gene0001.typ_tab_erro ;

    BEGIN
      -- Código do programa
      vr_cdprogra := 'CRPS500';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS500'
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
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
      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Código da critica
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro
      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Se houver indicador de restart, mas não veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;
      END IF;


      prej0003.pc_transfere_prejuizo_cc(pr_cdcooper => pr_cdcooper   --> Coop conectada
                                       ,pr_cdcritic => vr_cdcritic  --> Critica encontrada
                                       ,pr_dscritic  => vr_dscritic
                                       ,pr_tab_erro  => vr_tab_erro ); 


      -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);

      -- Testar saída de erro
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Chamar rotina para eliminação do restart para evitarmos
      -- reprocessamento das aplicações indevidamente
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                 ,pr_cdprogra => vr_cdprogra   --> Código do programa
                                 ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                 ,pr_des_erro => vr_dscritic); --> Saída de erro
      -- Testar saída de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Sair do processo
        RAISE vr_exc_saida;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit final
      COMMIT;

   EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Se foi gerada critica para envio ao log
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
      END IF;
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit pois gravaremos o que foi processo até então
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END pc_crps500;
/
