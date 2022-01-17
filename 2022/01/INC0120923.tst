PL/SQL Developer Test script 3.0
528
-- Created on 07/01/2022 by F0032641 
declare 
  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------    
    pr_cdcooper crapcop.cdcooper%TYPE := 16;
    pr_nrdconta crawepr.nrdconta%TYPE := 653675;
    pr_stprogra PLS_INTEGER;            --> Saída de termino da execução
    pr_infimsol PLS_INTEGER;            --> Saída de termino da solicitação

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS194';

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
              ,cop.flintcdc
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Cadastro auxiliar dos emprestimos com movimento a mais de 4 meses
      -- que não estejam cadastrados na crapepr
      CURSOR cr_crawepr ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_dtmvtolt IN DATE) IS
        SELECT crawepr.nrdconta --Numero da conta/dv do associado
              ,crawepr.nrctremp --Numero do contrato de emprestimo
              ,crawepr.tpemprst --Tipo do emprestimo (0 - atual, 1 - pre-fixada)
              ,crawepr.idcobope --Cobertura
              ,crawepr.cdfinemp --Finalidade de emprestimo
              ,crawepr.cdoperad --Usuario de criacao da proposta
              ,crawepr.rowid    --id do registro
        FROM  crawepr
        WHERE crawepr.cdcooper = pr_cdcooper
        AND   crawepr.nrdconta = pr_nrdconta
        AND   crawepr.tpemprst = 3
        AND   crawepr.nrctremp IN (386257, 387565);

      -- renegociados nao efetivados somente
      CURSOR cr_renegociacao(pr_cdcooper IN tbepr_renegociacao.cdcooper%TYPE,
                             pr_nrdconta IN tbepr_renegociacao.nrdconta%TYPE,
                             pr_nrctremp IN tbepr_renegociacao.nrctremp%TYPE) IS
        SELECT 1 
          FROM tbepr_renegociacao r
         WHERE r.cdcooper = pr_cdcooper
           AND r.nrdconta = pr_nrdconta
           AND r.nrctremp = pr_nrctremp
           AND r.dtlibera IS NULL;
      rw_renegociacao cr_renegociacao%ROWTYPE;
      
      -- Verificar o tipo de finalidade
      CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE
                       ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
        SELECT fin.tpfinali
          FROM crapfin fin
         WHERE fin.cdcooper = pr_cdcooper
           AND fin.cdfinemp = pr_cdfinemp;
      rw_crapfin cr_crapfin%ROWTYPE;
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      vr_dtlimite     DATE;
      vr_dtlimpla     DATE;
      vr_dtlimepr     DATE;
      vr_qtmeslim     INTEGER := 0;
      vr_qtprocrd     INTEGER;
      vr_qtpropla     INTEGER;
      vr_qtproepr     INTEGER;
      vr_dstextab     craptab.dstextab%TYPE;

      --------------------------- SUBROTINAS INTERNAS --------------------------
begin
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

      -- busca o valor do parametro EXELIMPEZA
      vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'EXELIMPEZA'
                                                ,pr_tpregist => 1);

      -- se nao encontrar o parametro, aborta a execucao
      IF TRIM(vr_dstextab) IS NULL THEN
        -- gera critica 387 - Falta tabela de execucao da limpeza do cadastro.
        vr_cdcritic := 387;
        -- finaliza a execucao
        RAISE vr_exc_saida;
      END IF;

      -- verifica se a limpeza já foi executada em outra oportunidade
      IF vr_dstextab = '1' THEN
        -- gera critica 177 - Limpeza ja rodou este mes.
        vr_cdcritic := 177;
        -- finaliza a execucao
        RAISE vr_exc_saida;
      END IF;

      /*  Monta data limite para efetuar a limpeza  */

      -- primeiro dia do mês anterior (60 dias)
      vr_dtlimite := TRUNC(add_months(rw_crapdat.dtmvtolt,-1),'MONTH');

      --> Buscar parametro que define quantidade de meses para limpeza
      -- Parametro utilizado também no CRPS704
      vr_qtmeslim := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                               pr_cdcooper => pr_cdcooper, 
                                               pr_cdacesso => 'QTD_MES_LIMPEZA_WEPR');

      IF nvl(vr_qtmeslim,0) = 0 THEN
        vr_dscritic := 'Quantidade de meses para limpeza nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        -- primeiro dia de 4 meses atras (120 dias)
        vr_dtlimepr := TRUNC(add_months(rw_crapdat.dtmvtolt,vr_qtmeslim*-1),'MONTH');
      END IF;

      -- primeiro dia de 4 meses atras (120 dias)
      vr_dtlimpla := TRUNC(add_months(rw_crapdat.dtmvtolt,-4),'MONTH');

      /*  Leitura do crawepr  a ser excluido  */
      FOR rw_crawepr IN cr_crawepr( pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => vr_dtlimepr)
      LOOP
        -- Se cooperativa permite integração CDC
        IF rw_crapcop.flintcdc = 1 and rw_crawepr.cdoperad='AUTOCDC' THEN

          -- Devemos verificar o tipo de finalidade da proposta
          OPEN cr_crapfin(pr_cdcooper => pr_cdcooper
                         ,pr_cdfinemp => rw_crawepr.cdfinemp);
          FETCH cr_crapfin INTO rw_crapfin;

          -- Se não encontrar finalidade de emprestimo
          IF cr_crapfin%NOTFOUND THEN
            -- Fechar cursor
            CLOSE cr_crapfin;
            -- Gerar crítica
            vr_cdcritic := 0;
            vr_dscritic := 'Finalidade de emprestimo nao encontrada.';
            -- Levatar exceção
            RAISE vr_exc_saida;
          END IF;
          -- Fechar cursor
          CLOSE cr_crapfin;

          -- Se for CDC devemos ignorar
          IF rw_crapfin.tpfinali = 3 THEN
            continue;
          END IF;
        END IF;

        /* Excluindo as informaoes das propostas de emprestimo */
        BEGIN
          DELETE FROM  crapprp
                 WHERE crapprp.cdcooper = pr_cdcooper
                 AND   crapprp.nrdconta = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapprp.tpctrato = 90                  -- Tipo de contrato
                 AND   crapprp.nrctrato = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            -- gera critica
            vr_dscritic := 'Erro na exclusao das propostas de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpa os avalistas terceiros */
        BEGIN
          DELETE FROM  crapavt
                 WHERE crapavt.cdcooper = pr_cdcooper
                 AND   crapavt.tpctrato = 1                  -- Tipo de contrato
                 AND   crapavt.nrdconta = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapavt.nrctremp = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos avalistas terceiros da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpeza dos avalistas */
        BEGIN
          DELETE FROM  crapavl
                 WHERE crapavl.cdcooper = pr_cdcooper
                 AND   crapavl.tpctrato = 1                   -- Tipo de contrato (empréstimo)
                 AND   crapavl.nrctaavd = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapavl.nrctravd = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos avalistas da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpar os bens da proposta */
        BEGIN
          DELETE FROM  crapbpr
                 WHERE crapbpr.cdcooper = pr_cdcooper
                 AND   crapbpr.nrdconta = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapbpr.tpctrpro = 90                  --tipo da proposta de emprestimo
                 AND   crapbpr.nrctrpro = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos bens da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpar os rendimentos da proposta */
        BEGIN
          DELETE FROM  craprpr
                 WHERE craprpr.cdcooper = pr_cdcooper
                 AND   craprpr.nrdconta = rw_crawepr.nrdconta --Conta do associado
                 AND   craprpr.nrctrato = rw_crawepr.nrctremp --numero do contrato
                 AND   craprpr.tpctrato = 90;                 --Tipo(1-Empr/2-Descto Chq/3-Chq Esp/4-Cartao/5-Cont,6-Jur,7-RL)
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos rendimentos da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpa as parcelas do contrato de emprestimos e seus respectivos valores */
        BEGIN
          DELETE FROM  crappep
                 WHERE crappep.cdcooper = pr_cdcooper
                 AND   crappep.nrdconta = rw_crawepr.nrdconta --conta do associado
                 AND   crappep.nrctremp = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            -- gera critica
            vr_dscritic := 'Erro na exclusao das parcelas da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;
        
        -- remover o vinculo da cobertura
        BLOQ0001.pc_vincula_cobertura_operacao (pr_idcobertura_anterior => rw_crawepr.idcobope 
                                               ,pr_idcobertura_nova => 0
                                               ,pr_nrcontrato => 0
                                               ,pr_dscritic => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          -- finaliza a execucao
          RAISE vr_exc_saida;
        END IF;

        -- eliminando informações de riscos e rating dos empréstimos
        BEGIN

          -- Históricos das operações do Rating por Produto/Contrato
          DELETE FROM tbrating_historicos th
                WHERE th.cdcooper = pr_cdcooper
                  AND th.nrdconta = rw_crawepr.nrdconta
                  AND th.nrctremp = rw_crawepr.nrctremp
                  AND th.tpctrato = 90;
        EXCEPTION
          WHEN OTHERS THEN
           cecred.pc_internal_exception;
           -- gera critica
           vr_dscritic := 'Erro na exclusao do historico da operacao de risco de emprestimo. '||SQLERRM;
           -- finaliza a execucao
           RAISE vr_exc_saida;
        END;

        BEGIN
          -- Detalhes do Rating da Operação
          DELETE FROM tbrating_detalhes td
                WHERE td.idrating IN (SELECT tbo.idrating
                                        FROM tbrisco_operacoes tbo
                                       WHERE tbo.cdcooper = pr_cdcooper
                                         AND tbo.nrdconta = rw_crawepr.nrdconta
                                         AND tbo.nrctremp = rw_crawepr.nrctremp
                                         AND tbo.tpctrato = 90);
        EXCEPTION
          WHEN OTHERS THEN
           cecred.pc_internal_exception;
           -- gera critica
           vr_dscritic := 'Erro na exclusao dos detalhes da operacao de risco de emprestimo. '||SQLERRM;
           -- finaliza a execucao
           RAISE vr_exc_saida;
        END;

        BEGIN
          -- Centralizadora de Riscos da Operação
          DELETE FROM tbrisco_operacoes tbo
                WHERE tbo.cdcooper = pr_cdcooper
                  AND tbo.nrdconta = rw_crawepr.nrdconta
                  AND tbo.nrctremp = rw_crawepr.nrctremp
                  AND tbo.tpctrato = 90;

        EXCEPTION
          WHEN OTHERS THEN
           cecred.pc_internal_exception;
           -- gera critica
           vr_dscritic := 'Erro na exclusao da operacao de risco de emprestimo. '||SQLERRM;
           -- finaliza a execucao
           RAISE vr_exc_saida;
        END;
        -- eliminando informações de riscos e rating dos empréstimos

        -- eliminando as informacoes da proposta de cartoes de credito
        BEGIN
          DELETE FROM crawepr
                 WHERE ROWID = rw_crawepr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
           -- gera critica
           vr_dscritic := 'Erro na exclusao da proposta de emprestimo. '||SQLERRM;
           -- finaliza a execucao
           RAISE vr_exc_saida;
        END;

        -- Se for uma proposta de renegociacao
        IF rw_crawepr.tpemprst = 3 THEN
          
            --
            BEGIN
              DELETE FROM tbepr_renegociacao_contrato
                    WHERE cdcooper = pr_cdcooper
                      AND nrdconta = rw_crawepr.nrdconta
                      AND nrctremp = rw_crawepr.nrctremp;
            EXCEPTION
              WHEN OTHERS THEN
               -- gera critica
               vr_dscritic := 'Erro na exclusao na tbepr_renegociacao_contrato. '||SQLERRM;
               -- finaliza a execucao
               RAISE vr_exc_saida;
            END;
            --
            IF SQL%ROWCOUNT > 0 THEN
              BEGIN
                DELETE FROM tbepr_renegociacao
                      WHERE cdcooper = pr_cdcooper
                        AND nrdconta = rw_crawepr.nrdconta
                        AND nrctremp = rw_crawepr.nrctremp;
              EXCEPTION
                WHEN OTHERS THEN
                 -- gera critica
                 vr_dscritic := 'Erro na exclusao na tbepr_renegociacao. '||SQLERRM;
                 -- finaliza a execucao
                 RAISE vr_exc_saida;
              END;
            END IF;  
            --
            --PRJ0022826_R3
            BEGIN
              DELETE FROM credito.tbepr_renegociacao_contrato_simula
                    WHERE cdcooper = pr_cdcooper
                      AND nrdconta = rw_crawepr.nrdconta
                      AND nrctremp = rw_crawepr.nrctremp;
            EXCEPTION
              WHEN OTHERS THEN
               -- gera critica
               vr_dscritic := 'Erro na exclusao na tbepr_renegociacao_contrato_simula. '||SQLERRM;
               -- finaliza a execucao
               RAISE vr_exc_saida;
            END;
            --
            IF SQL%ROWCOUNT > 0 THEN
              BEGIN
                DELETE FROM credito.tbepr_renegociacao_simula
                      WHERE cdcooper = pr_cdcooper
                        AND nrdconta = rw_crawepr.nrdconta
                        AND nrctremp = rw_crawepr.nrctremp;
              EXCEPTION
                WHEN OTHERS THEN
                 -- gera critica
                 vr_dscritic := 'Erro na exclusao na tbepr_renegociacao_simula. '||SQLERRM;
                 -- finaliza a execucao
                 RAISE vr_exc_saida;
              END;
            END IF;
            --            
        END IF;

        vr_qtproepr := nvl(vr_qtproepr,0) + 1;

      END LOOP;--FOR rw_crawepr IN cr_crawepr( pr_cdcooper => pr_cdcooper

      /*  Imprime no log do processo o total de cartao de credito   */
      -- 661 - DELETADOS NO
      vr_cdcritic := 661;
      -- Busca a descrição e concatena as informações de quantidade
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                     ' WEPR = ' ||
                     to_char(nvl(vr_qtproepr,0),'fm999G990');
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic 
                                ,pr_nmarqlog     => 'proc_message'); 

      -- limpando as variaveis de controle de critica
      vr_cdcritic := 0;
      vr_dscritic := ' ';

      ----------------- EXCLUSÃO DOS DEMAIS REGISTROS -------------------
      
      delete from cecred.tbepr_renegociacao_crapepr where cdcooper = pr_cdcooper and nrdconta = pr_nrdconta;

      delete from cecred.tbepr_renegociacao_craplem where cdcooper = pr_cdcooper and nrdconta = pr_nrdconta;

      delete from cecred.tbepr_renegociacao_crappep where cdcooper = pr_cdcooper and nrdconta = pr_nrdconta;

      delete from cecred.tbepr_renegociacao_crapprp where cdcooper = pr_cdcooper and nrdconta = pr_nrdconta;

      delete from cecred.tbepr_renegociacao_crawepr where cdcooper = pr_cdcooper and nrdconta = pr_nrdconta;

      delete from cecred.tbepr_renegociacao_saldo where cdcooper = pr_cdcooper and nrdconta = pr_nrdconta;

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
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
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
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
       
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        
        -- Efetuar rollback
        ROLLBACK;
  
end;
0
0
