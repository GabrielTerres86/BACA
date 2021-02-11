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
      CURSOR cr_crawepr IS
        SELECT crawepr.cdcooper
              ,crawepr.nrdconta --Numero da conta/dv do associado
              ,crawepr.nrctremp --Numero do contrato de emprestimo
              ,crawepr.tpemprst --Tipo do emprestimo (0 - atual, 1 - pre-fixada)
              ,crawepr.idcobope --Cobertura
              ,crawepr.cdfinemp --Finalidade de emprestimo
              ,crawepr.cdoperad --Usuario de criacao da proposta
              ,crawepr.rowid    --id do registro
        FROM  crawepr
        WHERE crawepr.tpemprst = 3
		AND	  ((crawepr.cdcooper = 1	AND crawepr.nrdconta = 7419970	AND   crawepr.nrctremp = 2608283)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 2197677	AND   crawepr.nrctremp = 2628517)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6194095	AND   crawepr.nrctremp = 2733630)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6701779	AND   crawepr.nrctremp = 2757646)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8707995	AND   crawepr.nrctremp = 2763029)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8707995	AND   crawepr.nrctremp = 2763041)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8707995	AND   crawepr.nrctremp = 2763058)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8707995	AND   crawepr.nrctremp = 2763083)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8707995	AND   crawepr.nrctremp = 2763088)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6672850	AND   crawepr.nrctremp = 2764692)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 2771799	AND   crawepr.nrctremp = 2796248)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 772372	AND   crawepr.nrctremp = 2804273)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8810516	AND   crawepr.nrctremp = 2832435)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8340080	AND   crawepr.nrctremp = 2849929)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 90078292	AND   crawepr.nrctremp = 2860266)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 10306501	AND   crawepr.nrctremp = 2861515)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8693986	AND   crawepr.nrctremp = 2896190)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 80286054	AND   crawepr.nrctremp = 2932415)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 9887628	AND   crawepr.nrctremp = 2948312)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 10342680	AND   crawepr.nrctremp = 2957815)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3734447	AND   crawepr.nrctremp = 2961341)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3172562	AND   crawepr.nrctremp = 2966017)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 1903349	AND   crawepr.nrctremp = 2971167)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6447708	AND   crawepr.nrctremp = 2972581)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 9774610	AND   crawepr.nrctremp = 2978828)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 9043870	AND   crawepr.nrctremp = 3010134)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8889783	AND   crawepr.nrctremp = 3024827)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3577210	AND   crawepr.nrctremp = 3036442)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3653480	AND   crawepr.nrctremp = 3072555)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3715930	AND   crawepr.nrctremp = 3109140)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 7752822	AND   crawepr.nrctremp = 3126038)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3129292	AND   crawepr.nrctremp = 3142886)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 4085906	AND   crawepr.nrctremp = 3167534)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6192190	AND   crawepr.nrctremp = 3185698)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 9720626	AND   crawepr.nrctremp = 3208690)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 10965777	AND   crawepr.nrctremp = 3210084)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8601720	AND   crawepr.nrctremp = 3210124)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6995730	AND   crawepr.nrctremp = 3213577)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8036578	AND   crawepr.nrctremp = 3222377)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 2046997	AND   crawepr.nrctremp = 3234066)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8060088	AND   crawepr.nrctremp = 3259267)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 9491635	AND   crawepr.nrctremp = 3260856)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 7590709	AND   crawepr.nrctremp = 3263629)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 9666842	AND   crawepr.nrctremp = 3265486)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8221871	AND   crawepr.nrctremp = 3269161)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8532206	AND   crawepr.nrctremp = 3274256)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3768635	AND   crawepr.nrctremp = 3274978)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 2290421	AND   crawepr.nrctremp = 3287574)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3080145	AND   crawepr.nrctremp = 3293174)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3738361	AND   crawepr.nrctremp = 3293359)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 9450726	AND   crawepr.nrctremp = 3340060)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 11087625	AND   crawepr.nrctremp = 3238345)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 7216831	AND   crawepr.nrctremp = 3370704)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3928101	AND   crawepr.nrctremp = 3370837)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3928101	AND   crawepr.nrctremp = 3370844)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 7216831	AND   crawepr.nrctremp = 3373290)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 10251995	AND   crawepr.nrctremp = 3374102)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8923043	AND   crawepr.nrctremp = 3381284)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8557861	AND   crawepr.nrctremp = 3381317)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 10181849	AND   crawepr.nrctremp = 3388357)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3629708	AND   crawepr.nrctremp = 3389329)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8923043	AND   crawepr.nrctremp = 3390729)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8923043	AND   crawepr.nrctremp = 3394520)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 10232630	AND   crawepr.nrctremp = 3398907)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 10067639	AND   crawepr.nrctremp = 3400025)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 10232630	AND   crawepr.nrctremp = 3405354)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 9846697	AND   crawepr.nrctremp = 3405671)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8040338	AND   crawepr.nrctremp = 3407535)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 10232630	AND   crawepr.nrctremp = 3413207)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 3629708	AND   crawepr.nrctremp = 3419070)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8414998	AND   crawepr.nrctremp = 3420867)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6566120	AND   crawepr.nrctremp = 3425558)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 9846697	AND   crawepr.nrctremp = 3425747)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6566120	AND   crawepr.nrctremp = 3429426)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 8225770	AND   crawepr.nrctremp = 3431356)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 10360417	AND   crawepr.nrctremp = 3434700)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6706231	AND   crawepr.nrctremp = 3435658)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 10192301	AND   crawepr.nrctremp = 3436095)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6566120	AND   crawepr.nrctremp = 3436351)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6566120	AND   crawepr.nrctremp = 3441901)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 2798670	AND   crawepr.nrctremp = 3444169)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 6566120	AND   crawepr.nrctremp = 3447790)
			OR (crawepr.cdcooper = 1	AND crawepr.nrdconta = 2683580	AND   crawepr.nrctremp = 3448250)
			OR (crawepr.cdcooper = 2	AND crawepr.nrdconta = 166790	AND   crawepr.nrctremp = 267989)
			OR (crawepr.cdcooper = 10	AND crawepr.nrdconta = 78468	AND   crawepr.nrctremp = 19435)	
			OR (crawepr.cdcooper = 10	AND crawepr.nrdconta = 78468	AND   crawepr.nrctremp = 19528)	
			OR (crawepr.cdcooper = 10	AND crawepr.nrdconta = 117684	AND   crawepr.nrctremp = 19732)	
			OR (crawepr.cdcooper = 10	AND crawepr.nrdconta = 128899	AND   crawepr.nrctremp = 19736)	
			OR (crawepr.cdcooper = 10	AND crawepr.nrdconta = 115614	AND   crawepr.nrctremp = 18131)	
			OR (crawepr.cdcooper = 10	AND crawepr.nrdconta = 136255	AND   crawepr.nrctremp = 20058)	
			OR (crawepr.cdcooper = 10	AND crawepr.nrdconta = 136255	AND   crawepr.nrctremp = 20106)	
			OR (crawepr.cdcooper = 10	AND crawepr.nrdconta = 128899	AND   crawepr.nrctremp = 20439)	
			OR (crawepr.cdcooper = 13	AND crawepr.nrdconta = 150835	AND   crawepr.nrctremp = 75114)	
			OR (crawepr.cdcooper = 13	AND crawepr.nrdconta = 402648	AND   crawepr.nrctremp = 79982)	
			OR (crawepr.cdcooper = 13	AND crawepr.nrdconta = 323276	AND   crawepr.nrctremp = 85246)	
			OR (crawepr.cdcooper = 13	AND crawepr.nrdconta = 369721	AND   crawepr.nrctremp = 85303)	
			OR (crawepr.cdcooper = 13	AND crawepr.nrdconta = 369721	AND   crawepr.nrctremp = 96212)	
			OR (crawepr.cdcooper = 13	AND crawepr.nrdconta = 463019	AND   crawepr.nrctremp = 97381)	
			OR (crawepr.cdcooper = 13	AND crawepr.nrdconta = 369721	AND   crawepr.nrctremp = 97569)	
			OR (crawepr.cdcooper = 13	AND crawepr.nrdconta = 369721	AND   crawepr.nrctremp = 97822)	
			OR (crawepr.cdcooper = 13	AND crawepr.nrdconta = 369721	AND   crawepr.nrctremp = 98116)	
			OR (crawepr.cdcooper = 16	AND crawepr.nrdconta = 530530	AND   crawepr.nrctremp = 197150)
			OR (crawepr.cdcooper = 16	AND crawepr.nrdconta = 27588	AND   crawepr.nrctremp = 226311)
			OR (crawepr.cdcooper = 16	AND crawepr.nrdconta = 27588	AND   crawepr.nrctremp = 231148));
		
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
