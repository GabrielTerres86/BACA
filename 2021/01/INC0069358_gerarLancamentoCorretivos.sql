DECLARE

  -- CONSTANTES
  vc_cdcooper     CONSTANT NUMBER := 1; -- Cooperativa Viacredi
  vc_nrdconta     CONSTANT NUMBER := 10597018; -- Conta encerrada com saldos indevidos
  
  -- Valor de reembolso de taxas indevidas
  vc_vldtaxas     CONSTANT NUMBER := 2.54;
  vc_vldcotas     CONSTANT NUMBER := 30.79;
  vc_vlsobras     CONSTANT NUMBER := 8.24;
  
  -- Historicos para lançamento
  vc_hsdtaxas     CONSTANT NUMBER := 362;  -- CREDITO EM CONTA CORRENTE VIA EXTRACAIXA
  vc_hsdebcot     CONSTANT NUMBER := 2136; -- DEBITO DE COTAS - CRAPLCT
  vc_hscrecap     CONSTANT NUMBER := 2137; -- CREDITO PROVENIENTE DE CAPITAL - CRAPLCM
  vc_hsdebenc     CONSTANT NUMBER := 2079; -- CAPITAL DISPONIVEL PARA SAQUE CONTA ENCERRADA PF - CRAPLCT
  
  vr_exc_erro     EXCEPTION;
  
  -- VARIÁVEIS
  vr_tab_retorno  LANC0001.typ_reg_retorno;
  vr_incrineg     NUMBER;
  vr_cdcritic     NUMBER;
  vr_dscritic     VARCHAR2(2000);
  
  vr_nrseqdig     NUMBER;
  
BEGIN 
  
  -- Manter o lote do lançamento
  LANC0001.pc_inclui_altera_lote(pr_cdcooper => vc_cdcooper   -- Codigo Cooperativa
                                ,pr_dtmvtolt => datascooperativa(vc_cdcooper).dtmvtolt   -- Data 
                                ,pr_cdagenci => 900           -- Codigo Agencia
                                ,pr_cdbccxlt => 100           -- Codigo Caixa
                                ,pr_nrdolote => 4125          -- Numero Lote
                                ,pr_tplotmov => 1             -- Tipo movimento
                                ,pr_cdoperad => '1'           -- Operador
                                ,pr_cdhistor => vc_hsdtaxas   -- Codigo Historico
                                ,pr_dtmvtopg => NULL          -- Data Pagamento Emprestimo
                                ,pr_vllanmto => vc_vldtaxas   -- Valor Lancamento
                                ,pr_flgincre => TRUE          -- Incremento
                                ,pr_flgcredi => TRUE          -- Credito
                                ,pr_nrseqdig => vr_nrseqdig   -- Numero Sequencia
                                ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                ,pr_dscritic => vr_dscritic); -- Descricao Erro

  -- Se ocorreu erro
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  -- CRAPLCM - Inserir lançamento referente a taxas cobradas indevidamente
  LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => datascooperativa(vc_cdcooper).dtmvtolt
                                    ,pr_cdagenci    => 900
                                    ,pr_cdbccxlt    => 100
                                    ,pr_nrdolote    => 4125
                                    ,pr_nrdconta    => vc_nrdconta
                                    ,pr_nrdocmto    => vr_nrseqdig
                                    ,pr_cdhistor    => vc_hsdtaxas
                                    ,pr_nrseqdig    => vr_nrseqdig
                                    ,pr_vllanmto    => vc_vldtaxas
                                    ,pr_nrdctabb    => vc_nrdconta
                                    ,pr_nrctachq    => vc_nrdconta
                                    ,pr_dtrefere    => datascooperativa(vc_cdcooper).dtmvtolt
                                    ,pr_hrtransa    => GENE0002.fn_busca_time()
                                    ,pr_cdoperad    => '1' -- Super usuário
                                    ,pr_cdcooper    => vc_cdcooper
                                    ,pr_nrdctitg    => LPAD(vc_nrdconta,8,'0')
                                    ,pr_tab_retorno => vr_tab_retorno
                                    ,pr_incrineg    => vr_incrineg
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
  
  -- Se apresentou erro na geração do lançamento
  IF TRIM(vr_dscritic) IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
    RAISE vr_exc_erro;
  END IF;
  
  
  
  -- Manter o lote do lançamento
  LANC0001.pc_inclui_altera_lote(pr_cdcooper => vc_cdcooper   -- Codigo Cooperativa
                                ,pr_dtmvtolt => datascooperativa(vc_cdcooper).dtmvtolt   -- Data 
                                ,pr_cdagenci => 900           -- Codigo Agencia
                                ,pr_cdbccxlt => 100           -- Codigo Caixa
                                ,pr_nrdolote => 600038        -- Numero Lote
                                ,pr_tplotmov => 1             -- Tipo movimento
                                ,pr_cdoperad => '1'           -- Operador
                                ,pr_cdhistor => vc_hsdebcot   -- Codigo Historico
                                ,pr_dtmvtopg => NULL          -- Data Pagamento Emprestimo
                                ,pr_vllanmto => vc_vldcotas   -- Valor Lancamento
                                ,pr_flgincre => TRUE          -- Incremento
                                ,pr_flgcredi => FALSE         -- Credito
                                ,pr_nrseqdig => vr_nrseqdig   -- Numero Sequencia
                                ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                ,pr_dscritic => vr_dscritic); -- Descricao Erro

  -- Se ocorreu erro
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  
  -- CRAPLCT - Lançar o débito de cotas para regularizar a conta
  BEGIN
    INSERT INTO craplct(dtmvtolt
                       ,cdagenci
                       ,cdbccxlt
                       ,nrdolote
                       ,nrdconta
                       ,nrdocmto
                       ,cdhistor
                       ,nrseqdig
                       ,vllanmto
                       ,cdcooper)
                 VALUES(datascooperativa(vc_cdcooper).dtmvtolt -- dtmvtolt
                       ,900  -- cdagenci
                       ,100  -- cdbccxlt
                       ,600038 -- nrdolote
                       ,vc_nrdconta -- nrdconta
                       ,vr_nrseqdig -- nrdocmto
                       ,vc_hsdebcot--cdhistor
                       ,vr_nrseqdig -- nrseqdig
                       ,vc_vldcotas -- vllanmto
                       ,vc_cdcooper);
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir lançamento de cota: '||SQLERRM;
      RAISE vr_exc_erro;
  END;
  
  
  -- Manter o lote do lançamento
  LANC0001.pc_inclui_altera_lote(pr_cdcooper => vc_cdcooper   -- Codigo Cooperativa
                                ,pr_dtmvtolt => datascooperativa(vc_cdcooper).dtmvtolt   -- Data 
                                ,pr_cdagenci => 900           -- Codigo Agencia
                                ,pr_cdbccxlt => 100           -- Codigo Caixa
                                ,pr_nrdolote => 600038        -- Numero Lote
                                ,pr_tplotmov => 1             -- Tipo movimento
                                ,pr_cdoperad => '1'           -- Operador
                                ,pr_cdhistor => vc_hsdebcot   -- Codigo Historico
                                ,pr_dtmvtopg => NULL          -- Data Pagamento Emprestimo
                                ,pr_vllanmto => vc_vldcotas   -- Valor Lancamento
                                ,pr_flgincre => TRUE          -- Incremento
                                ,pr_flgcredi => TRUE         -- Credito
                                ,pr_nrseqdig => vr_nrseqdig   -- Numero Sequencia
                                ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                ,pr_dscritic => vr_dscritic); -- Descricao Erro

  -- Se ocorreu erro
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  
  -- CRAPLCM - Lançar o crédito na conta para regularizar 
  LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => datascooperativa(vc_cdcooper).dtmvtolt
                                    ,pr_cdagenci    => 900
                                    ,pr_cdbccxlt    => 100
                                    ,pr_nrdolote    => 600038
                                    ,pr_nrdconta    => vc_nrdconta
                                    ,pr_nrdocmto    => vr_nrseqdig
                                    ,pr_cdhistor    => vc_hscrecap
                                    ,pr_nrseqdig    => vr_nrseqdig
                                    ,pr_vllanmto    => vc_vldcotas
                                    ,pr_nrdctabb    => vc_nrdconta
                                    ,pr_nrctachq    => vc_nrdconta
                                    ,pr_dtrefere    => datascooperativa(vc_cdcooper).dtmvtolt
                                    ,pr_hrtransa    => GENE0002.fn_busca_time()
                                    ,pr_cdoperad    => '1' -- Super usuário
                                    ,pr_cdcooper    => vc_cdcooper
                                    ,pr_nrdctitg    => LPAD(vc_nrdconta,8,'0')
                                    ,pr_tab_retorno => vr_tab_retorno
                                    ,pr_incrineg    => vr_incrineg
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
  
  -- Se apresentou erro na geração do lançamento
  IF TRIM(vr_dscritic) IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
    RAISE vr_exc_erro;
  END IF;
  
  
  -- Manter o lote do lançamento
  LANC0001.pc_inclui_altera_lote(pr_cdcooper => vc_cdcooper   -- Codigo Cooperativa
                                ,pr_dtmvtolt => datascooperativa(vc_cdcooper).dtmvtolt   -- Data 
                                ,pr_cdagenci => 900           -- Codigo Agencia
                                ,pr_cdbccxlt => 100           -- Codigo Caixa
                                ,pr_nrdolote => 8006        -- Numero Lote
                                ,pr_tplotmov => 1             -- Tipo movimento
                                ,pr_cdoperad => '1'           -- Operador
                                ,pr_cdhistor => vc_hsdebenc   -- Codigo Historico
                                ,pr_dtmvtopg => NULL          -- Data Pagamento Emprestimo
                                ,pr_vllanmto => vc_vlsobras   -- Valor Lancamento
                                ,pr_flgincre => TRUE          -- Incremento
                                ,pr_flgcredi => FALSE         -- Credito
                                ,pr_nrseqdig => vr_nrseqdig   -- Numero Sequencia
                                ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                ,pr_dscritic => vr_dscritic); -- Descricao Erro

  -- Se ocorreu erro
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  
  -- CRAPLCT - Lançar nos valores a devolver (recebido do retorno de sobras)
  BEGIN
    INSERT INTO craplct(dtmvtolt
                       ,cdagenci
                       ,cdbccxlt
                       ,nrdolote
                       ,nrdconta
                       ,nrdocmto
                       ,cdhistor
                       ,nrseqdig
                       ,vllanmto
                       ,cdcooper)
                 VALUES(datascooperativa(vc_cdcooper).dtmvtolt -- dtmvtolt
                       ,900  -- cdagenci
                       ,100  -- cdbccxlt
                       ,8006 -- nrdolote
                       ,vc_nrdconta -- nrdconta
                       ,vr_nrseqdig -- nrdocmto
                       ,vc_hsdebenc --cdhistor
                       ,vr_nrseqdig -- nrseqdig
                       ,vc_vlsobras -- vllanmto
                       ,vc_cdcooper);
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir lançamento de cota: '||SQLERRM;
      RAISE vr_exc_erro;
  END;
  
  -- TBCOTAS_DEVOLUCAO - Adicionar o valor de R$8,24 nos valores de capital a devolver
  BEGIN
    INSERT INTO tbcotas_devolucao(cdcooper
                                 ,nrdconta
                                 ,tpdevolucao
                                 ,vlcapital
                                 ,qtparcelas
                                 ,dtinicio_credito
                                 ,vlpago)
                           VALUES(vc_cdcooper
                                 ,vc_nrdconta
                                 ,3
                                 ,vc_vlsobras
                                 ,0
                                 ,datascooperativa(vc_cdcooper).dtmvtolt
                                 ,0);
  EXCEPTION 
    WHEN dup_val_on_index THEN
      BEGIN
        UPDATE tbcotas_devolucao t
           SET t.vlcapital   = NVL(t.vlcapital,0) + vc_vlsobras
         WHERE t.cdcooper    = vc_cdcooper
           AND t.nrdconta    = vc_nrdconta
           AND t.tpdevolucao = 3; -- Cotas
      
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar lançamento de valores a devolver: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao incluir lançamento de valores a devolver: '||SQLERRM;
      RAISE vr_exc_erro;
  END;
  
  BEGIN
    UPDATE crapcot t
       SET t.vldcotas = 0 -- Zerar o valor das cotas
     WHERE t.cdcooper = vc_cdcooper
       AND t.nrdconta = vc_nrdconta;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao atualizar valor total das cotas: '||SQLERRM;
      RAISE vr_exc_erro;
  END;
  
  -- Efetivar dados inseridos
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    -- Se foi retornado apenas código
    IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    ROLLBACK;
    
    -- Retornar erro
    raise_application_error(-20001,vr_dscritic);

  WHEN OTHERS THEN
    ROLLBACK;
    
    -- Retornar erro
    raise_application_error(-20000,'Erro ao incluir lançamentos: '||SQLERRM);
END;
