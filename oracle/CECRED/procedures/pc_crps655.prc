CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS655" (pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                                  ,pr_flgresta  IN PLS_INTEGER             --> Flag padrao para utilização de restart
                                                  ,pr_stprogra OUT PLS_INTEGER             --> Saída de termino da execução
                                                  ,pr_infimsol OUT PLS_INTEGER             --> Saída de termino da solicitacao
                                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Critica encontrada
                                                  ,pr_dscritic OUT VARCHAR2) IS

BEGIN
  /* ...........................................................................

  Programa: pc_crps655 (Fonte Antigo Fontes/crps655.p)
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Douglas
  Data    : Outubro/2013                   Ultima atualizacao: 24/10/2013

  Dados referentes ao programa:

  Frequencia: Diario
  Objetivo  : Controlar limpeza das tabelas do Corvu
              Roda na ultima cadeia exclusiva do processo noturno
              Solicitacao: 32 - Ordem de Execucao: 1

  Alterações: 24/10/2013 - Conversao PROGRESS >>> PLSQL (Adriano)

  ............................................................................*/
  DECLARE

    --Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
    SELECT cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;


    --------------------------VARIAVEIS----------------------------------------

    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS655';

    -- Codigo da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- Descrição da critica
    vr_dscritic VARCHAR2(4000);
    -- Tratamento de finalizacao do programa
    vr_exc_fimprg EXCEPTION;
    -- Tratamento de saida do programa
    vr_exc_saida EXCEPTION;
    --Armazena a data para usada no delete
    vr_dtmvtolt DATE;

  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);

    IF vr_cdcritic <> 0 THEN
      -- Buscar descrição da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    -- Verificacao do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    --Apaga todos os registros de saldo devedor
    BEGIN
      DELETE crapsdv
       WHERE crapsdv.cdcooper = pr_cdcooper;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao limpar a base sdv. Detalhes: '||sqlerrm;
          RAISE vr_exc_saida;

    END;

    --Pega a data a ser utilizada como base para deletar os registros de saldo diario
    IF TO_CHAR(rw_crapdat.dtmvtolt,'mm') = TO_CHAR(rw_crapdat.dtmvtopr,'mm') THEN
      vr_dtmvtolt := rw_crapdat.dtmvtolt;
    ELSE
      IF TO_CHAR(rw_crapdat.dtmvtolt,'mm') = TO_CHAR(rw_crapdat.dtmvtoan,'mm') THEN
        vr_dtmvtolt := rw_crapdat.dtmvtoan;
      END IF;

    END IF;

    --Deleta todos os registros de saldo diario com base na vr_dtmvtolt
    IF NOT vr_dtmvtolt IS NULL THEN
      BEGIN
        DELETE crapscd
         WHERE crapscd.cdcooper = pr_cdcooper
           AND crapscd.dtmvtolt = vr_dtmvtolt;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao limpar a base scd. Detalhes: '||sqlerrm;
            RAISE vr_exc_saida;
      END;

    END IF;

    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Efetuar commit
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
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
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

    END;

END PC_CRPS655;
/

