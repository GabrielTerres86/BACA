CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps127 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

       Programa: pc_crps127                       Antigo: Fontes/crps127.p
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah
       Data    : Julho/95.                        Ultima atualizacao: 24/03/2014

       Dados referentes ao programa:

       Frequencia: Roda Mensalmente no Processo de Limpeza
       Objetivo  : Limpeza das autorizacoes de debito canceladas (crapatr).
                   Atende a Solicitacao 013.
                   Ordem da Solicitacao 065.
                   Exclusividade = 2
                   Ordem do Programa na Solicitacao = 17
                   
       Alteracoes: 10/01/2000 - Padronizar mensagens (Deborah).
       
                   16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
                   
                   24/03/2014 - Conversão PROGRESS >>> ORACLE. (Reinert)
    ............................................................................. */


    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS127';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Cursor para verificar se programa deve executar
      CURSOR cr_craptab IS
        SELECT tab.dstextab
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper  AND
               tab.nmsistem = 'CRED'       AND
               tab.tptabela = 'GENERI'     AND
               tab.cdempres = 00           AND
               tab.cdacesso = 'EXELIMPEZA' AND          
               tab.tpregist = 001;               
      rw_craptab cr_craptab%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      
      vr_dtrefere DATE;
      vr_qtdelatr INTEGER;
      
      --------------------------- SUBROTINAS INTERNAS --------------------------

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
      
      -- Verifica se programa deve executar
      OPEN cr_craptab;
      FETCH cr_craptab
       INTO rw_craptab;
       
      IF cr_craptab%NOTFOUND THEN
         -- Critica: 176 - Falta tabela de execucao de limpeza - registro 001.
         vr_cdcritic := 176;
         -- Busca critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         -- Gera log no proc_batch
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                  || vr_cdprogra || ' --> '
                                                                  || vr_dscritic );
         RAISE vr_exc_saida;                                                                       
      ELSE
         IF rw_craptab.dstextab = '1' THEN
            -- Critica: 177 - Limpeza ja rodou este mes.
            vr_cdcritic := 177;
            -- Busca Critica
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            -- Gera log no proc_batch
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                     || vr_cdprogra || ' --> '
                                                                     || vr_dscritic );
            RAISE vr_exc_saida;
         END IF;
      END IF;
      
			-- Recebe o primeiro dia do mes de dois meses atrás 
      vr_dtrefere := trunc(ADD_MONTHS(rw_crapdat.dtmvtolt, -2), 'mm');
      
      BEGIN
				-- Limpa a tabela de cadastro de autorizações de débito em conta
        DELETE FROM crapatr
              WHERE crapatr.cdcooper = pr_cdcooper    -- Cooperativa
                AND crapatr.dtfimatr < vr_dtrefere;   -- Data do fim da autorização
        -- Recebe a quantidade de registros removidos                
        vr_qtdelatr := sql%rowcount;
      EXCEPTION
				-- Se ocorrer algum erro ao executar a query acima
        WHEN OTHERS THEN
					-- Recebe a descrição do erro
          vr_dscritic := 'Erro ao deletar registro da crapatr. Detalhes: '||sqlerrm;
					-- Levanta crítica
          RAISE vr_exc_saida;
      END;
      
      -- Imprime no log do processo o total das exclusoes
      vr_cdcritic := 661;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                  || vr_cdprogra || ' --> '
                                                                  || vr_dscritic || ' ATR = '
                                                                  || gene0002.fn_mask(vr_qtdelatr, 'z.zzz.zz9'));

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
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
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
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps127;
/

