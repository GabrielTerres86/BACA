CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps101 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
/* ..........................................................................

   Programa: pc_crps101                       Antigo: Fontes/crps101.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/94.                     Ultima atualizacao: 21/02/2014

   Dados referentes ao programa:

   Frequencia: Roda anualmente em fevereiro  no Processo de Limpeza
   Objetivo  : Limpeza dos registros de estouros.

               Atende a Solicitacao 056.
               Ordem da Solicitacao 066.
               Exclusividade = 2
               Ordem do Programa na Solicitacao = 1

   Alteracao : 14/02/95 - Alterado para mudar a aux_dtlimite para 01/01/ano -1
                          (Odair).

               10/04/96 - Alterado para nao atualizar a solicitacao como proces-
                          sada e nao atualizar a tabela de limpeza.

               07/02/2000 - Padronizar mensagens (Deborah).

               14/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               21/02/2014 - Conversão Progress => Oracle. (Reinert)
............................................................................. */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS101';

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

      -- Cursor para verificar se deve executar o crps
      CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE,
                         pr_nmsistem IN craptab.nmsistem%TYPE,
                         pr_tptabela IN craptab.tptabela%TYPE,
                         pr_cdempres IN craptab.cdempres%TYPE,
                         pr_cdacesso IN craptab.cdacesso%TYPE,
                         pr_tpregist IN craptab.tpregist%TYPE) IS
      SELECT tab.dstextab
        FROM craptab tab
       WHERE tab.cdcooper = pr_cdcooper
         AND tab.nmsistem = pr_nmsistem
         AND tab.tptabela = pr_tptabela
         AND tab.cdempres = pr_cdempres
         AND tab.cdacesso = pr_cdacesso
         AND tab.tpregist = pr_tpregist;
      rw_craptab cr_craptab%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------

      vr_dtlimite DATE;
      vr_qtnegdel INTEGER := 0;

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
      BEGIN

        -- Verifica se programa deve rodar
        OPEN cr_craptab(pr_cdcooper => pr_cdcooper  -- Código da cooperativa
                       ,pr_nmsistem => 'CRED'       -- Nome do Sistema
                       ,pr_tptabela => 'GENERI'     -- Tipo da tabela
                       ,pr_cdempres => 00           -- Código da empresa
                       ,pr_cdacesso => 'EXELIMPNEG' -- Código de acesso
                       ,pr_tpregist => 001);        -- Tipo de registro
        FETCH cr_craptab INTO rw_craptab;

        IF cr_craptab%NOTFOUND THEN
           vr_cdcritic := 420; -- Falta tabela de execucao da limpeza do crapneg
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                       || vr_cdprogra || ' --> '
                                                                       || vr_dscritic );
           RAISE vr_exc_saida;
        ELSE
          IF rw_craptab.dstextab <> '0' THEN
             vr_cdcritic := 177; -- Limpeza ja rodou neste mes
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                         || vr_cdprogra || ' --> '
                                                                         || vr_dscritic );
             RAISE vr_exc_saida;
          END IF;
        END IF;
        -- Monta a data limite (01/01/Ano atual - 1)
        vr_dtlimite := trunc(trunc(sysdate,'yyyy')-1,'yyyy');

        BEGIN
          -- Limpa os registros da crapneg
          DELETE FROM crapneg neg
                WHERE neg.cdcooper = pr_cdcooper
                  AND neg.dtiniest < vr_dtlimite
                  AND -- Condicao 1 [Devolucao Chq. E Contra Ordem]
                      (( neg.cdhisest = 1 AND neg.cdobserv = 21 )
                   OR -- Condicao 2 [Estouro com data de fim do estouro for menor que a data limite]
                      ( neg.cdhisest = 5 AND neg.dtfimest < vr_dtlimite )
                   OR -- Condicao 3 [Alt. Tipo Conta]
                      neg.cdhisest = 2);
          -- Recebe quantidade de registros deletados
          vr_qtnegdel := sql%rowcount;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao deletar registro da crapneg. Detalhes: '||sqlerrm;
            RAISE vr_exc_saida;
        END;

        -- Imprime no log do processo os totais das exclusoes
        vr_cdcritic := 661;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                    || vr_cdprogra || ' --> '
                                                                    || vr_dscritic || ' NEG = '
                                                                    || gene0002.fn_mask(vr_qtnegdel, 'z.zzz.zz9'));

      END;
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

  END pc_crps101;
/

