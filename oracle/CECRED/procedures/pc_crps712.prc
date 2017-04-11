CREATE OR REPLACE PROCEDURE CECRED.pc_crps712 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /*........................................................................

    Programa: PC_CRPS712
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : Março/2017                      Ultima Atualizacao: --/--/----
    Dados referente ao programa:

    Frequencia: Diario.
       Objetivo  : Efetuar lançamento na conta das filiadas na CENTRAL, referente ao 
                   valor total de débitos de recarga de celular efetuado na conta dos 
                   cooperados.
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS712';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      
      -- Auxiliares
      vr_vrreceita NUMBER;         --> Valor da receita
      
      ------------------------------- CURSORES ---------------------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nrdocnpj
              ,cop.nrctactl
              ,cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper <> 3
         ORDER BY cop.cdcooper;
      
      -- Totalizar o valor das recargas de celular por operadora
      CURSOR cr_tbrecarga(pr_cdcooper IN crapcyb.cdcooper%TYPE
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT SUM(ope.vlrecarga) total_vlrecarga  
              ,ope.cdoperadora
          FROM tbrecarga_operacao ope
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.dtdebito = pr_dtmvtolt
           AND ope.insit_operacao = 2
           GROUP BY ope.cdoperadora;
      
      -- Busca operadora
      CURSOR cr_operadora (pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE) IS
        SELECT opr.perreceita
              ,opr.cdhisdeb_centralizacao
              ,opr.nmoperadora
          FROM tbrecarga_operadora opr
         WHERE opr.cdoperadora = pr_cdoperadora;
      rw_operadora cr_operadora%ROWTYPE;
      
      --Selecionar informacoes dos lotes
		  CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
											  ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
											  ,pr_cdagenci IN craplot.cdagenci%TYPE
											  ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
											  ,pr_nrdolote IN craplot.nrdolote%TYPE)  IS
			  SELECT craplot.cdcooper
				      ,craplot.dtmvtolt
				 			,craplot.cdagenci
							,craplot.cdbccxlt
							,craplot.nrdolote
							,craplot.nrseqdig
							,craplot.rowid
			    FROM craplot craplot
			   WHERE craplot.cdcooper = pr_cdcooper
			     AND craplot.dtmvtolt = pr_dtmvtolt
			     AND craplot.cdagenci = pr_cdagenci
			     AND craplot.cdbccxlt = pr_cdbccxlt
			     AND craplot.nrdolote = pr_nrdolote;
		  rw_craplot cr_craplot%ROWTYPE;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      rw_craplcm craplcm%ROWTYPE;
      
    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);
      
      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_fimprg;
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
      
      FOR rw_crapcop IN cr_crapcop LOOP
        
        FOR rw_tbrecarga IN cr_tbrecarga (pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
          
          OPEN cr_operadora (rw_tbrecarga.cdoperadora);
          FETCH cr_operadora INTO rw_operadora;
          -- Busca operadora
          IF cr_operadora%NOTFOUND THEN
            CLOSE cr_operadora;
            vr_dscritic := 'Operadora não encontrada.';
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_operadora;
          END IF;
          
          -- multiplicar o valor total de recargas pelo percentual de receita da operadora
          -- Para deduzir do valor a ser lançado na conta da filiada. 
          vr_vrreceita :=  rw_tbrecarga.total_vlrecarga * (rw_operadora.perreceita / 100);
          
          --Verificar se o lote existe
          OPEN cr_craplot (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_cdagenci => 1
                          ,pr_cdbccxlt => 85
                          ,pr_nrdolote => 6000036);
          --Posicionar no proximo registro
          FETCH cr_craplot INTO rw_craplot;
          --Se encontrou registro
          IF cr_craplot%NOTFOUND THEN
            --Criar lote
            INSERT INTO craplot(cdcooper
                               ,nrdolote
                               ,cdbccxlt
                               ,cdagenci
                               ,dtmvtolt
                               ,tplotmov)
                         VALUES(pr_cdcooper
                               ,6000036
                               ,85
                               ,1
                               ,rw_crapdat.dtmvtolt
                               ,1)
                      RETURNING ROWID
											         ,cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,nrseqdig
                           INTO rw_craplot.rowid
													     ,rw_craplot.cdcooper
                               ,rw_craplot.dtmvtolt
                               ,rw_craplot.cdagenci
                               ,rw_craplot.cdbccxlt
                               ,rw_craplot.nrdolote
                               ,rw_craplot.nrseqdig;
          END IF;
          --Fechar Cursor
          CLOSE cr_craplot;
          
          --Inserir lancamento retornando o valor do rowid e do lançamento para uso posterior
          INSERT INTO craplcm (cdcooper
                              ,dtmvtolt
                              ,cdagenci
                              ,cdbccxlt
                              ,nrdolote
                              ,nrdconta
                              ,nrdctabb
                              ,nrdctitg
                              ,nrdocmto
                              ,cdhistor
                              ,nrseqdig
                              ,nrsequni
                              ,vllanmto
                              ,hrtransa
                              ,cdpesqbb)
                       VALUES (rw_craplot.cdcooper
                              ,rw_craplot.dtmvtolt
                              ,rw_craplot.cdagenci
                              ,rw_craplot.cdbccxlt
                              ,rw_craplot.nrdolote
                              ,rw_crapcop.nrctactl
                              ,rw_crapcop.nrctactl
                              ,to_char(rw_crapcop.nrctactl,'fm00000000')
                              ,rw_craplot.nrseqdig
                              ,rw_operadora.cdhisdeb_centralizacao
                              ,Nvl(rw_craplot.nrseqdig,0) + 1
                              ,Nvl(rw_craplot.nrseqdig,0) + 1
                              ,(rw_tbrecarga.total_vlrecarga - vr_vrreceita) -- valor total – percentual de receita
                              ,to_char(SYSDATE, 'SSSSS')
                              ,rw_operadora.nmoperadora)
                      RETURNING vllanmto
                               ,nrautdoc
                               ,nrdconta
                               ,nrdocmto
                               ,nrsequni
                               ,cdhistor
                               ,hrtransa
                           INTO rw_craplcm.vllanmto
                               ,rw_craplcm.nrautdoc
                               ,rw_craplcm.nrdconta
                               ,rw_craplcm.nrdocmto
                               ,rw_craplcm.nrsequni
                               ,rw_craplcm.cdhistor
                               ,rw_craplcm.hrtransa;

          -- Atualizar lote
          UPDATE craplot SET craplot.vlinfodb = Nvl(craplot.vlinfodb,0) + rw_craplcm.vllanmto
                            ,craplot.vlcompdb = Nvl(craplot.vlcompdb,0) + rw_craplcm.vllanmto
                            ,craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                            ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                            ,craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
                       WHERE craplot.ROWID = rw_craplot.ROWID;
  				
        END LOOP;
      END LOOP;
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
        --COMMIT;
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

  END pc_crps712;
/
