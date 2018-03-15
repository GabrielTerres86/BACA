CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS515 (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa conectada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN
    /* ............................................................................

       Programa: PC_CRPS515 (Antigo Fontes/crps515.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Diego
       Data    : Setembro/2008                       Ultima atualizacao: 23/02/2016

       Dados referentes ao programa:

       Frequencia: Semanal
       Objetivo  : Gerar arquivo com saldo devedor dos emprestimos - Risco.

       Alteracoes:

                 09/05/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

                 09/08/2013 - Inclusão de teste na pr_flgresta antes de controlar
                              o restart (Marcos-Supero)

                 25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)
                 
                 25/01/2016 - Incluido tratamento temporario para chamar rotina alternativa com
                              melhorias de performace apenas para cooperativa 16 SD385161 (Odirlei-AMcom)

                 23/02/2016 - Incluido cooperativa 1 - Viacredi para rodar nova versão com ajustes de performace
                              SD385161 (Odirlei-AMcom) 

    ..............................................................................*/

    DECLARE
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros
      vr_exc_erro exception;

      ---------------- Cursores genéricos ----------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrtelura
              ,cop.dsdircop
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.nrctactl
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

    BEGIN
      -- Código do programa
      vr_cdprogra := 'CRPS515';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS515'
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
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
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
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => pr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF pr_cdcritic <> 0 THEN
        -- Buscar descrição da crítica
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;
      -- Não rodar no mensal
      IF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapdat.dtmvtopr,'mm')  THEN
        -- Tratamento e retorno de valores de restart
        btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                  ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                  ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                  ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                  ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                  ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                  ,pr_cdcritic  => pr_cdcritic   --> Código da critica
                                  ,pr_des_erro  => pr_dscritic); --> Saída de erro
        -- Se encontrou erro, gerar exceção
        IF pr_dscritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Se houver indicador de restart, mas não veio conta
        IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
          -- Remover o indicador
          vr_inrestar := 0;
        END IF;
        -- Chamar função que busca o dstextab para retornar o valor de arrasto
        -- no parâmetro de sistema RISCOBACEN
        vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'RISCOBACEN'
                                                 ,pr_tpregist => 000);
        -- Se a variavel voltou vazia
        IF vr_dstextab IS NULL THEN
          -- Buscar descrição da crítica 55
          pr_cdcritic := 55;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 55);
          -- Envio centralizado de log de erro
          RAISE vr_exc_erro;
        END IF;
        -- Por fim, tenta converter o valor de arrasto presente na posição 3 até 9
        vr_vlr_arrasto := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,3,9));
        -- Se o valor estiver null ou deu erro de conversão ou veio vazio
        IF vr_vlr_arrasto IS NULL THEN
          -- Gerar erro
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao converter o valor de arrasto do parâmetro RISCOBACEN('||vr_dstextab||')';
          RAISE vr_exc_erro;
        END IF;

        -- Por fim, chamar a 310i, que é a responsável por todo o processo de criação dos riscos
          pc_crps310_i(pr_cdcooper   => pr_cdcooper    --> Coop conectada
                      ,pr_rw_crapdat => rw_crapdat     --> Rowtype de informações da crapdat
                      ,pr_cdprogra   => vr_cdprogra    --> Codigo programa conectado
                      ,pr_vlarrasto  => vr_vlr_arrasto --> Valor parametrizado para arrasto
                      ,pr_flgresta   => pr_flgresta    --> Flag 0/1 para utilização de restart
                      ,pr_nrctares   => vr_nrctares    --> Conta do ultimo restart
                      ,pr_dsrestar   => vr_dsrestar    --> Descrição genérica de restart
                      ,pr_inrestar   => vr_inrestar    --> Indicador se há ou não restart
                      ,pr_cdcritic   => pr_cdcritic    --> Código de erro encontrado
                      ,pr_dscritic   => pr_dscritic);  --> Descrição de erro encontrado
        
        -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
        GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                  ,pr_action => NULL);

        -- Testar saída de erro
        IF pr_dscritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Chamar rotina para eliminação do restart para evitarmos
        -- reprocessamento das aplicações indevidamente
        btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                   ,pr_cdprogra => vr_cdprogra   --> Código do programa
                                   ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                   ,pr_des_erro => pr_dscritic); --> Saída de erro
        -- Testar saída de erro
        IF pr_dscritic IS NOT NULL THEN
          -- Sair do processo
          pr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;
        -- Processo OK, devemos chamar a fimprg
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit final
        COMMIT;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps515;
/

