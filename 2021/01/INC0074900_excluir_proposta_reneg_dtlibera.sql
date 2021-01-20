  BEGIN

    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------
      -- Cadastro auxiliar dos emprestimos com movimento a mais de 4 meses
      -- que não estejam cadastrados na crapepr
      /*CURSOR cr_crawepr IS
        SELECT crawepr.cdcooper
              ,crawepr.nrdconta --Numero da conta/dv do associado
              ,crawepr.nrctremp --Numero do contrato de emprestimo
              ,crawepr.tpemprst --Tipo do emprestimo (0 - atual, 1 - pre-fixada)
              ,crawepr.idcobope --Cobertura
              ,crawepr.cdfinemp --Finalidade de emprestimo
              ,crawepr.cdoperad --Usuario de criacao da proposta
              ,crawepr.rowid    --id do registro
        FROM  crawepr
        WHERE crawepr.tpemprst = 3*/
		
		CURSOR cr_crawepr IS
		SELECT wr.cdcooper
              ,wr.nrdconta --Numero da conta/dv do associado
              ,wr.nrctremp --Numero do contrato de emprestimo
              ,wr.tpemprst --Tipo do emprestimo (0 - atual, 1 - pre-fixada)
              ,wr.idcobope --Cobertura
              ,wr.cdfinemp --Finalidade de emprestimo
              ,wr.cdoperad --Usuario de criacao da proposta
              ,wr.rowid    --id do registro
		FROM crapepr e
			  ,crawepr w
			  ,crawepr wr --crawepr capa
			  ,tbepr_renegociacao r
			  ,tbepr_renegociacao_contrato c
		WHERE e.cdfinemp IN (62,63) 
			AND e.cdcooper = w.cdcooper
			AND e.nrdconta = w.nrdconta
			AND e.nrctremp = w.nrctremp
			AND c.cdcooper = e.cdcooper
			AND c.nrdconta = e.nrdconta
			AND c.nrctrepr = e.nrctremp
			AND r.cdcooper = c.cdcooper
			AND r.nrdconta = c.nrdconta
			AND r.nrctremp = c.nrctremp
			AND r.cdcooper = wr.cdcooper
			AND r.nrdconta = wr.nrdconta
			AND r.nrctremp = wr.nrctremp
			AND NOT EXISTS (SELECT 1 FROM tbepr_renegociacao_crapepr re
									WHERE c.cdcooper = re.cdcooper
									AND c.nrdconta = re.nrdconta
									AND c.nrctrepr = re.nrctremp
									AND c.nrversao = re.nrversao)
			AND Nvl(w.flgreneg,0) = 1
			AND r.dtlibera >= '15/12/2020'
			AND wr.tpemprst = 3
			GROUP BY r.cdcooper
				,r.nrdconta
				,r.nrctremp
				,r.dtlibera
				,wr.insitapr
				,wr.insitest		
		
      -- renegociados nao efetivados somente
      CURSOR cr_renegociacao(pr_cdcooper IN tbepr_renegociacao.cdcooper%TYPE,
                             pr_nrdconta IN tbepr_renegociacao.nrdconta%TYPE,
                             pr_nrctremp IN tbepr_renegociacao.nrctremp%TYPE) IS
        SELECT 1 
          FROM tbepr_renegociacao r
         WHERE r.cdcooper = pr_cdcooper
           AND r.nrdconta = pr_nrdconta
           AND r.nrctremp = pr_nrctremp;
           --AND r.dtlibera IS NULL;
      rw_renegociacao cr_renegociacao%ROWTYPE;

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

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- limpando as variaveis de controle de critica
      vr_cdcritic := 0;
      vr_dscritic := ' ';

      /*  Leitura do crawepr  a ser excluido  */
      FOR rw_crawepr IN cr_crawepr
      LOOP
                   
        -- Se for uma proposta de renegociacao
        IF rw_crawepr.tpemprst = 3 THEN
          -- se passou do limite de tempo e nao foi liberado
          OPEN cr_renegociacao(pr_cdcooper => rw_crawepr.cdcooper,
                               pr_nrdconta => rw_crawepr.nrdconta,
                               pr_nrctremp => rw_crawepr.nrctremp);
          FETCH cr_renegociacao INTO rw_renegociacao;
          IF cr_renegociacao%FOUND THEN
            CLOSE cr_renegociacao;
          ELSE
            CLOSE cr_renegociacao;
            -- Nao apagar nada da capa da renegociacao se estiver efetivada
            CONTINUE;
          END IF;
        END IF;

        /* Excluindo as informaoes das propostas de emprestimo */
        BEGIN
          DELETE FROM  crapprp
                 WHERE crapprp.cdcooper = rw_crawepr.cdcooper
                 AND   crapprp.nrdconta = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapprp.tpctrato = 90                  -- Tipo de contrato
                 AND   crapprp.nrctrato = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            -- gera critica
            vr_dscritic := 'Erro na exclusao das propostas de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpa os avalistas terceiros */
        BEGIN
          DELETE FROM  crapavt
                 WHERE crapavt.cdcooper = rw_crawepr.cdcooper
                 AND   crapavt.tpctrato = 1                  -- Tipo de contrato
                 AND   crapavt.nrdconta = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapavt.nrctremp = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos avalistas terceiros da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpeza dos avalistas */
        BEGIN
          DELETE FROM  crapavl
                 WHERE crapavl.cdcooper = rw_crawepr.cdcooper
                 AND   crapavl.tpctrato = 1                   -- Tipo de contrato (empréstimo)
                 AND   crapavl.nrctaavd = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapavl.nrctravd = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos avalistas da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpar os bens da proposta */
        BEGIN
          DELETE FROM  crapbpr
                 WHERE crapbpr.cdcooper = rw_crawepr.cdcooper
                 AND   crapbpr.nrdconta = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapbpr.tpctrpro = 90                  --tipo da proposta de emprestimo
                 AND   crapbpr.nrctrpro = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos bens da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpar os rendimentos da proposta */
        BEGIN
          DELETE FROM  craprpr
                 WHERE craprpr.cdcooper = rw_crawepr.cdcooper
                 AND   craprpr.nrdconta = rw_crawepr.nrdconta --Conta do associado
                 AND   craprpr.nrctrato = rw_crawepr.nrctremp --numero do contrato
                 AND   craprpr.tpctrato = 90;                 --Tipo(1-Empr/2-Descto Chq/3-Chq Esp/4-Cartao/5-Cont,6-Jur,7-RL)
        EXCEPTION
          WHEN OTHERS THEN
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos rendimentos da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpa as parcelas do contrato de emprestimos e seus respectivos valores */
        BEGIN
          DELETE FROM  crappep
                 WHERE crappep.cdcooper = rw_crawepr.cdcooper
                 AND   crappep.nrdconta = rw_crawepr.nrdconta --conta do associado
                 AND   crappep.nrctremp = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
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
                WHERE th.cdcooper = rw_crawepr.cdcooper
                  AND th.nrdconta = rw_crawepr.nrdconta
                  AND th.nrctremp = rw_crawepr.nrctremp
                  AND th.tpctrato = 90;
        EXCEPTION
          WHEN OTHERS THEN
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
                                       WHERE tbo.cdcooper = rw_crawepr.cdcooper
                                         AND tbo.nrdconta = rw_crawepr.nrdconta
                                         AND tbo.nrctremp = rw_crawepr.nrctremp
                                         AND tbo.tpctrato = 90);
        EXCEPTION
          WHEN OTHERS THEN
           -- gera critica
           vr_dscritic := 'Erro na exclusao dos detalhes da operacao de risco de emprestimo. '||SQLERRM;
           -- finaliza a execucao
           RAISE vr_exc_saida;
        END;

        BEGIN
          -- Centralizadora de Riscos da Operação
          DELETE FROM tbrisco_operacoes tbo
                WHERE tbo.cdcooper = rw_crawepr.cdcooper
                  AND tbo.nrdconta = rw_crawepr.nrdconta
                  AND tbo.nrctremp = rw_crawepr.nrctremp
                  AND tbo.tpctrato = 90;

        EXCEPTION
          WHEN OTHERS THEN
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
                    WHERE cdcooper = rw_crawepr.cdcooper
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
            BEGIN
              DELETE FROM tbepr_renegociacao
                    WHERE cdcooper = rw_crawepr.cdcooper
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

        vr_qtproepr := nvl(vr_qtproepr,0) + 1;

      END LOOP;--FOR rw_crawepr IN cr_crawepr( pr_cdcooper => pr_cdcooper

      -- Salvar informações atualizadas
      COMMIT;
      DBMS_OUTPUT.put_line('Execução terminou com sucesso! Quantidade Total: ' || nvl(vr_qtproepr,0));

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        DBMS_OUTPUT.put_line(vr_dscritic);
        
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        DBMS_OUTPUT.put_line(vr_dscritic);
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        -- Efetuar retorno do erro não tratado
        DBMS_OUTPUT.put_line(vr_dscritic);
        -- Efetuar rollback
        ROLLBACK;
    END;

  END;
