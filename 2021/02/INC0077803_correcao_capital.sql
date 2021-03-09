DECLARE
  type typ_reg_cooperado is record (cdcooper crapcop.cdcooper%type
                                   ,nrdconta crapass.nrdconta%type);
  type typ_tab_cooperado is table of typ_reg_cooperado index by pls_integer;
  vr_tab_cooperado typ_tab_cooperado;
  
  -- Valor de reembolso de taxas indevidas
  vr_valor1       CONSTANT NUMBER := 1;
  
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
  --Contas a serem ajustadas cooperativa 5
  vr_tab_cooperado(1).cdcooper := 5;
  vr_tab_cooperado(1).nrdconta := 12513;
  vr_tab_cooperado(2).cdcooper := 5;
  vr_tab_cooperado(2).nrdconta := 133426;
  vr_tab_cooperado(3).cdcooper := 5;
  vr_tab_cooperado(3).nrdconta := 252751;
  
  --Contas a serem ajustadas cooperativa 7
  vr_tab_cooperado(4).cdcooper := 7;
  vr_tab_cooperado(4).nrdconta := 122416;
  vr_tab_cooperado(5).cdcooper := 7;
  vr_tab_cooperado(5).nrdconta := 124176;
  vr_tab_cooperado(6).cdcooper := 7;
  vr_tab_cooperado(6).nrdconta := 125296;
  vr_tab_cooperado(7).cdcooper := 7;
  vr_tab_cooperado(7).nrdconta := 314579;
  
  --Contas a serem ajustadas cooperativa 9
  vr_tab_cooperado(8).cdcooper := 9;
  vr_tab_cooperado(8).nrdconta := 142972;
  vr_tab_cooperado(9).cdcooper := 9;
  vr_tab_cooperado(9).nrdconta := 144789;
  vr_tab_cooperado(10).cdcooper := 9;
  vr_tab_cooperado(10).nrdconta := 220116;
  vr_tab_cooperado(11).cdcooper := 9;
  vr_tab_cooperado(11).nrdconta := 230693;
  vr_tab_cooperado(12).cdcooper := 9;
  vr_tab_cooperado(12).nrdconta := 291650;
  
  --Contas a serem ajustadas cooperativa 13
  vr_tab_cooperado(13).cdcooper := 13;
  vr_tab_cooperado(13).nrdconta := 104647;
  vr_tab_cooperado(14).cdcooper := 13;
  vr_tab_cooperado(14).nrdconta := 126675;
  vr_tab_cooperado(15).cdcooper := 13;
  vr_tab_cooperado(15).nrdconta := 137510;
  vr_tab_cooperado(16).cdcooper := 13;
  vr_tab_cooperado(16).nrdconta := 174939;
  vr_tab_cooperado(17).cdcooper := 13;
  vr_tab_cooperado(17).nrdconta := 354813;
  vr_tab_cooperado(18).cdcooper := 13;
  vr_tab_cooperado(18).nrdconta := 372870;
  vr_tab_cooperado(19).cdcooper := 13;
  vr_tab_cooperado(19).nrdconta := 395358;
  vr_tab_cooperado(20).cdcooper := 13;
  vr_tab_cooperado(20).nrdconta := 490652;
  
  for i in vr_tab_cooperado.first..vr_tab_cooperado.last loop
    -- Manter o lote do lançamento
    LANC0001.pc_inclui_altera_lote(pr_cdcooper => vr_tab_cooperado(i).cdcooper   -- Codigo Cooperativa
                                  ,pr_dtmvtolt => datascooperativa(vr_tab_cooperado(i).cdcooper).dtmvtolt   -- Data 
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
                   VALUES(datascooperativa(vr_tab_cooperado(i).cdcooper).dtmvtolt -- dtmvtolt
                         ,900  -- cdagenci
                         ,100  -- cdbccxlt
                         ,600038 -- nrdolote
                         ,vr_tab_cooperado(i).nrdconta -- nrdconta
                         ,vr_nrseqdig -- nrdocmto
                         ,decode(vr_tab_cooperado(i).nrdconta,125296,2519,vr_cdhistor) --cdhistor --Essa conta tratada é PJ, por isso o histórico é diferente
                         ,vr_nrseqdig -- nrseqdig
                         ,vr_valor1   -- vllanmto
                         ,vr_tab_cooperado(i).cdcooper);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir lançamento de cota: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- TBCOTAS_DEVOLUCAO - Reduzir os valores lançados dos valores a devolver
    BEGIN
      UPDATE tbcotas_devolucao t
         SET t.vlcapital   = NVL(t.vlcapital,0) - vr_valor1
       WHERE t.cdcooper    = vr_tab_cooperado(i).cdcooper
         AND t.nrdconta    = vr_tab_cooperado(i).nrdconta
         AND t.tpdevolucao = 3; -- Cotas
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar lançamento de valores a devolver: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
  end loop;

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
