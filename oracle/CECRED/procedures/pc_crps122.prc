CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps122 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps122 (Fontes/crps122.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Junho/95                     Ultima atualizacao: 22/06/2016

       Dados referentes ao programa:

       Frequencia: Roda Mensalmente no Processo de Limpeza
       Objetivo  : Limpeza dos Avisos de Debito em C/C (crapavs).
                   Atende a Solicitacao 013.
                   Ordem da Solicitacao 065.
                   Exclusividade = 2
                   Ordem do Programa na Solicitacao = 16

       Alteracoes: 30/06/95 - Alterado para eliminar da leitura a selecao de tipo
                              de aviso 1 (limpara todos os tipo de avisos).
                              Nao atualizar tabela de execucao e a solicitacao.
                              (Deborah)

                   10/01/2000 - Padronizar mensagens (Deborah).

                   16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   24/03/2014 - Conversão Progress >> Oracle PLSQL (Tiago Castro - RKAM)

                   22/06/2016 - Correcao para o uso da function fn_busca_dstextab 
                                da TABE0001. (Carlos Rafael Tanholi).
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS122';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      vr_qtavsdel   NUMBER :=0;
      vr_dtrefere   DATE;

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

      CURSOR cr_crapavs IS --cadastro de aviso de debito em conta corrente
        SELECT  COUNT(*)
        FROM    crapavs
        WHERE   crapavs.cdcooper = pr_cdcooper
        AND     crapavs.dtrefere < vr_dtrefere;
      rw_crapavs cr_crapavs%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      vr_total NUMBER;
      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;      
      --------------------------- SUBROTINAS INTERNAS --------------------------

      --------------- VALIDACOES INICIAIS -----------------

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
      --busca cadastro de execucao de limpeza
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 00
                                               ,pr_cdacesso => 'EXELIMPEZA'
                                               ,pr_tpregist => 001);   
        									 
      IF TRIM(vr_dstextab) IS NULL THEN 
        --gera log erro
        vr_cdcritic := 176;
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                || vr_cdprogra || ' --> '
                                || vr_dscritic );
        RAISE vr_exc_saida; --encerra programa
        
      ELSE -- encontrou cadastro de execucao de limpeza
        IF  vr_dstextab = '1' THEN  -- texto da tabela = 1
          --gera log erro
          vr_cdcritic := 177;
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                  || vr_cdprogra || ' --> '
                                  || vr_dscritic );
          RAISE vr_exc_saida; --encerra programa
        END IF;
      END IF;
      
      --calcula data referencia
      --busca o dia da data referencia e subtrai esse valor da data referencia
      vr_dtrefere :=  rw_crapdat.dtmvtolt - lpad(to_char(rw_crapdat.dtmvtolt,'dd'),2,'0');
      --busca o dia calculado vr_dtrefere e subtrai esse valor da data calculada
      vr_dtrefere :=  vr_dtrefere - lpad(to_char(vr_dtrefere,'dd'),2,'0');
      --busca o dia calculado na vr_dtrefere e soma mais 1 dia
      vr_dtrefere :=  vr_dtrefere - lpad(to_char(vr_dtrefere,'dd'),2,'0')+1;

      --Acumula a quantidade  de avisos deletados
      OPEN cr_crapavs;
      FETCH cr_crapavs INTO vr_qtavsdel;
      CLOSE cr_crapavs;
      BEGIN
        DELETE  FROM crapavs --executa limpeza dos avisos encontrados
        WHERE   cdcooper  = pr_cdcooper
        AND     dtrefere  < vr_dtrefere;
      EXCEPTION
        WHEN OTHERS THEN
          -- gera log erro
          vr_dscritic := SQLERRM;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                  || vr_cdprogra || ' --> '
                                  || vr_dscritic );
          RAISE vr_exc_saida; -- encerra programa
      END;
      /*  Imprime no log do processo os totais das exclusoes   */
      vr_cdcritic := 661;
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                              || vr_cdprogra || ' --> '
                              || vr_dscritic || ' AVS = '||to_char(vr_qtavsdel,'fm999,990.990') );


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

  END pc_crps122;
