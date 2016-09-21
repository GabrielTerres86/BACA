CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS174" ( pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                          ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                          ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                          ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

       Programa: PC_CRPS174 (Antigo Fontes/crps174.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Novembro/96                        Ultima atualizacao: 25/11/2013

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Atende a solicitacao 018.
                   Atualizar o indicador de pagamento do plano de capital.

       Alteracoes: 28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                 15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                 01/08/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                 25/11/2013 - Ajustes no comentário do campo indpagto (Marcos-Supero)

    ............................................................................. */


    DECLARE

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      ----------------------------- VARIAVEIS ------------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS174';
      -- Tratamento de erros
      vr_exc_erro exception;
      vr_exc_fimprg exception;
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);

    BEGIN

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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1--true
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Buscar descrição da crítica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      BEGIN
        -- Atualizar a situação dos Planos de Pagamento para não pago.
        -- Obs: Somente nas seguintes condições:
        --      a) Tipo de plano 1 (???)
        --      b) Situação do plano igual a 1 (???)
        --      c) Débito em conta
        --      d) Situação paga
        UPDATE crappla
           SET indpagto = 0
         WHERE cdcooper = pr_cdcooper
           AND tpdplano = 1
           AND cdsitpla = 1
           AND flgpagto = 0
           AND indpagto = 1;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar a tabela CRAPPAL. Detalhes '||sqlerrm;
          RAISE vr_exc_erro;
      END;

      -- Processo OK, devemos chamar a fimprg
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

      WHEN vr_exc_erro THEN
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
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        -- Efetuar rollback
        ROLLBACK;
    END;
  END PC_CRPS174;
/

