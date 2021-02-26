DECLARE
  -- CONSTANTES
  vr_cdcooper     CONSTANT NUMBER := 1;        -- Cooperativa Viacredi
  vr_nrdconta     CONSTANT NUMBER := 10597018; -- Conta encerrada com saldos indevidos
  
  -- Valor de reembolso de taxas indevidas
  vr_valor1       CONSTANT NUMBER := 30.79;
  vr_valor2       CONSTANT NUMBER := 8.24;
  
  -- Historicos para lançamento
  vr_cdhistor     CONSTANT NUMBER := 2518;  -- DEVOLUCAO CAPITAL DISPONIVEL CONTA ENCERRADA PF
  vr_exc_erro     EXCEPTION;
  
  -- VARIÁVEIS
  vr_tab_retorno  LANC0001.typ_reg_retorno;
  vr_incrineg     NUMBER;
  vr_cdcritic     NUMBER;
  vr_dscritic     VARCHAR2(2000);

  vr_nrseqdig     NUMBER;
BEGIN
  -- Manter o lote do lançamento
  LANC0001.pc_inclui_altera_lote(pr_cdcooper => vr_cdcooper   -- Codigo Cooperativa
                                ,pr_dtmvtolt => datascooperativa(vr_cdcooper).dtmvtolt   -- Data 
                                ,pr_cdagenci => 900           -- Codigo Agencia
                                ,pr_cdbccxlt => 100           -- Codigo Caixa
                                ,pr_nrdolote => 600038        -- Numero Lote
                                ,pr_tplotmov => 1             -- Tipo movimento
                                ,pr_cdoperad => '1'           -- Operador
                                ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                ,pr_dtmvtopg => NULL          -- Data Pagamento Emprestimo
                                ,pr_vllanmto => vr_valor1     -- Valor Lancamento
                                ,pr_flgincre => TRUE          -- Incremento
                                ,pr_flgcredi => TRUE          -- Credito
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
                 VALUES(datascooperativa(vr_cdcooper).dtmvtolt -- dtmvtolt
                       ,900  -- cdagenci
                       ,100  -- cdbccxlt
                       ,600038 -- nrdolote
                       ,vr_nrdconta -- nrdconta
                       ,vr_nrseqdig -- nrdocmto
                       ,vr_cdhistor --cdhistor
                       ,vr_nrseqdig -- nrseqdig
                       ,vr_valor1   -- vllanmto
                       ,vr_cdcooper);
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir lançamento de cota: '||SQLERRM;
      RAISE vr_exc_erro;
  END;
  
  -- Manter o lote do lançamento
  LANC0001.pc_inclui_altera_lote(pr_cdcooper => vr_cdcooper   -- Codigo Cooperativa
                                ,pr_dtmvtolt => datascooperativa(vr_cdcooper).dtmvtolt   -- Data 
                                ,pr_cdagenci => 900           -- Codigo Agencia
                                ,pr_cdbccxlt => 100           -- Codigo Caixa
                                ,pr_nrdolote => 600038        -- Numero Lote
                                ,pr_tplotmov => 1             -- Tipo movimento
                                ,pr_cdoperad => '1'           -- Operador
                                ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                ,pr_dtmvtopg => NULL          -- Data Pagamento Emprestimo
                                ,pr_vllanmto => vr_valor2     -- Valor Lancamento
                                ,pr_flgincre => TRUE          -- Incremento
                                ,pr_flgcredi => TRUE          -- Credito
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
                 VALUES(datascooperativa(vr_cdcooper).dtmvtolt -- dtmvtolt
                       ,900  -- cdagenci
                       ,100  -- cdbccxlt
                       ,600038 -- nrdolote
                       ,vr_nrdconta -- nrdconta
                       ,vr_nrseqdig -- nrdocmto
                       ,vr_cdhistor --cdhistor
                       ,vr_nrseqdig -- nrseqdig
                       ,vr_valor2   -- vllanmto
                       ,vr_cdcooper);
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir lançamento de cota: '||SQLERRM;
      RAISE vr_exc_erro;
  END;

  -- TBCOTAS_DEVOLUCAO - Reduzir os valores lançados dos valores a devolver
  BEGIN
    UPDATE tbcotas_devolucao t
       SET t.vlcapital   = NVL(t.vlcapital,0) - vr_valor1 - vr_valor2
     WHERE t.cdcooper    = vr_cdcooper
       AND t.nrdconta    = vr_nrdconta
       AND t.tpdevolucao = 3; -- Cotas
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao atualizar lançamento de valores a devolver: '||SQLERRM;
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
