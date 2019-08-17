PL/SQL Developer Test script 3.0
324
-----------------------------------------------------------------
-- [COOPER 2 | NRDCONTA 573094 | BORDERO 47374 | TITULO 3185 ] --
-----------------------------------------------------------------
declare 
  -- Cursor dos títulos
  CURSOR cr_craptdb IS
  SELECT * FROM craptdb WHERE cdcooper = 2 AND nrborder = 47374 AND nrdocmto = 3185;
  rw_craptdb cr_craptdb%ROWTYPE;
  
  -- Vars locais
  vr_saldo    NUMBER;
  vr_vlmtatit craptdb.vlmtatit%TYPE;
  vr_vlmratit craptdb.vlmratit%TYPE;
  vr_vlioftit craptdb.vliofcpl%TYPE;
  vr_vlultmora craptdb.vlmratit%TYPE;
  
  vr_vlpgmtatit craptdb.vlmtatit%TYPE;
  vr_vlpgmratit craptdb.vlmratit%TYPE;
  vr_vlpgioftit craptdb.vliofcpl%TYPE;
  vr_vlpgsldtit craptdb.vlsldtit%TYPE;
  
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
BEGIN
  -- Atualizando a TDB para retirar os pagamentos e alterar a situação do título.
  UPDATE craptdb
  SET vlpagiof = 0, vlpagmta = 0, vlpagmra = 0 -- ZERAR OS VALORES DE PAGAMENTO DE IOF MULTA E MORA
     ,vlsldtit = craptdb.vltitulo -- Volta o valor do saldo do titulo para o valor do título 
     ,insittit = 4    -- Situacao LIBERADO    
     ,vlultmra = 6.37 -- Ultima mora no dia 29/03/2019
     ,dtultpag = NULL
  WHERE cdcooper = 2 
    AND nrborder = 47374 
    AND nrdocmto = 3185;

  -- Abre cursor da TDB
  OPEN cr_craptdb();
  FETCH cr_craptdb INTO rw_craptdb;
  IF cr_craptdb%NOTFOUND THEN
    CLOSE cr_craptdb;
    dbms_output.put_line('erro: Abrir cursor TDB');
    RETURN;
  END IF;
  CLOSE cr_craptdb;
  
  -- Recalcula os juros
  cecred.dsct0003.pc_calcula_atraso_tit(pr_cdcooper => rw_craptdb.cdcooper,
                                        pr_nrdconta => rw_craptdb.nrdconta,
                                        pr_nrborder => rw_craptdb.nrborder,
                                        pr_cdbandoc => rw_craptdb.cdbandoc,
                                        pr_nrdctabb => rw_craptdb.nrdctabb,
                                        pr_nrcnvcob => rw_craptdb.nrcnvcob,
                                        pr_nrdocmto => rw_craptdb.nrdocmto,
                                        pr_dtmvtolt => to_date('04/04/2019', 'DD/MM/RRRR'),
                                        pr_vlmtatit => vr_vlmtatit,
                                        pr_vlmratit => vr_vlmratit,
                                        pr_vlioftit => vr_vlioftit,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);
  -- Verifica crítica               
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;                                        
                                        
  -- Atualizando a TDB para retirar os pagamentos e alterar a situação do título.
  UPDATE craptdb
  SET vliofcpl = vr_vlioftit, vlmtatit = vr_vlmtatit, vlmratit = vr_vlmratit -- Atualizar os valores de IOF, MULTA e MORA
  WHERE cdcooper = 2 
    AND nrborder = 47374 
    AND nrdocmto = 3185;
   
  -- Retirando os registro da Lancamentos Bordero.
  DELETE FROM tbdsct_lancamento_bordero
  WHERE cdcooper = 2 
    AND nrborder = 47374 
    AND nrtitulo = 7
    AND (vllanmto = 480.00 OR vllanmto = 0.01 OR vllanmto = 16.89 OR vllanmto = 0.28 OR vllanmto = 9.60 OR vllanmto = 0.64) AND dtmvtolt IN  ('02/04/2019', '04/04/2019');

  -- Faz os lançamentos de MORA e MULTA no extrato do borderô
  IF (vr_vlmratit > 0) THEN
    DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                           ,pr_nrdconta => 573094
                                           ,pr_nrborder => 47374
                                           ,pr_dtmvtolt => to_date('04/04/2019','DD/MM/RRRR')
                                           ,pr_cdbandoc => 85
                                           ,pr_nrdctabb => 10210
                                           ,pr_nrcnvcob => 10210
                                           ,pr_nrdocmto => 3185
                                           ,pr_nrtitulo => 7
                                           ,pr_cdorigem => 7
                                           ,pr_cdhistor => 2668 --APROPR. JUROS DE MORA DESCONTO DE TITULO
                                           ,pr_vllanmto => vr_vlmratit - rw_craptdb.vlultmra
                                           ,pr_dscritic => vr_dscritic );
    
    -- Condicao para verificar se houve critica                             
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
  END IF;
  
  IF (vr_vlmtatit > 0) THEN
    DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                           ,pr_nrdconta => 573094
                                           ,pr_nrborder => 47374
                                           ,pr_dtmvtolt => to_date('04/04/2019','DD/MM/RRRR')
                                           ,pr_cdbandoc => 85
                                           ,pr_nrdctabb => 10210
                                           ,pr_nrcnvcob => 10210
                                           ,pr_nrdocmto => 3185
                                           ,pr_nrtitulo => 7
                                           ,pr_cdorigem => 7
                                           ,pr_cdhistor => 2669 --APROPR. MULTA DESCONTO DE TITULO
                                           ,pr_vllanmto => vr_vlmtatit
                                           ,pr_dscritic => vr_dscritic );
    
    -- Condicao para verificar se houve critica                             
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
  END IF;
  

  -- Saldo para abater
  vr_saldo      := 16.92;
  vr_vlpgioftit := 0;
  vr_vlpgmtatit := 0;
  vr_vlpgmratit := 0;
  vr_vlpgsldtit := 0;
  
  -- Verifica o quanto do IOF consegue pagar.
  vr_saldo := vr_saldo - vr_vlioftit;
  IF (vr_saldo >= 0) THEN
    vr_vlpgioftit := vr_vlioftit; -- Se sobrar saldo, paga o IOF inteiro e tenta pagar a Multa
    vr_saldo := vr_saldo - vr_vlmtatit;
    IF (vr_saldo >= 0) THEN
      vr_vlpgmtatit := vr_vlmtatit; -- Se sobrar saldo, paga a Multa intera e tenta pagar a Mora
      vr_saldo := vr_saldo - vr_vlmratit;
      IF (vr_saldo >= 0) THEN
        vr_vlpgmratit := vr_vlmratit; -- Se sobrar saldo, paga a Mora inteira e tenta pagar o título
        vr_saldo := vr_saldo - rw_craptdb.vltitulo;
        IF (vr_saldo >= 0) THEN
          vr_vlpgsldtit := rw_craptdb.vltitulo;
        ELSE
          vr_vlpgsldtit := vr_saldo + rw_craptdb.vltitulo;
        END IF;
      ELSE
        vr_vlpgmratit := vr_saldo + vr_vlmratit;
      END IF;
    ELSE
      vr_vlpgmtatit := vr_saldo + vr_vlmtatit;
    END IF;
  ELSE
    vr_vlpgioftit := vr_saldo + vr_vlioftit;
  END IF;
  
  -- Atualiza a TDB com os valores pagos.
  UPDATE craptdb
  SET vlpagiof = vr_vlpgioftit, 
      vlpagmta = vr_vlpgmtatit, 
      vlpagmra = vr_vlpgmratit,
      vlsldtit = vlsldtit - vr_vlpgsldtit,
      vlultmra = vr_vlmratit, -- Ultima mora no dia 29/03/2019
      dtultpag = to_date('04/04/2019')
  WHERE cdcooper = 2 
    AND nrborder = 47374 
    AND nrdocmto = 3185;
  
  IF (vr_vlpgioftit > 0) THEN
    -- UPDATE LCM
    UPDATE craplcm
    SET vllanmto = vr_vlpgioftit -- IOF de R$0.02 para R$0.30
    WHERE cdcooper = 2 
      AND nrdconta = 573094 
      AND dtmvtolt = to_date('04/04/2019')
      AND cdhistor = 2321
      AND nrdocmto = 3185;
  END IF;
  
  IF (vr_vlpgmtatit > 0) THEN
    -- Update LCM
    UPDATE craplcm
    SET vllanmto = vr_vlpgmtatit -- Parcela de R$16.89, alterado para Multa de R$7.02
       ,cdhistor = 2681
    WHERE cdcooper = 2 
      AND nrdconta = 573094 
      AND dtmvtolt = to_date('04/04/2019')
      AND cdhistor = 2670
      AND nrdocmto = 3185;
      
    -- Extrato do borderô
    DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                           ,pr_nrdconta => 573094
                                           ,pr_nrborder => 47374
                                           ,pr_dtmvtolt => to_date('04/04/2019','DD/MM/RRRR')
                                           ,pr_cdbandoc => 85
                                           ,pr_nrdctabb => 10210
                                           ,pr_nrcnvcob => 10210
                                           ,pr_nrdocmto => 3185
                                           ,pr_nrtitulo => 7
                                           ,pr_cdorigem => 7
                                           ,pr_cdhistor => 2682 --PAGTO DE MULTA SOBRE DESCONTO DE TITULO (operacao credito)
                                           ,pr_vllanmto => vr_vlpgmtatit
                                           ,pr_dscritic => vr_dscritic );
    
    -- Condicao para verificar se houve critica                             
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
  END IF;
  
  --Faz lançamento de MORA no extrato
  IF (vr_vlpgmratit > 0) THEN  
    -- Update LCM
    UPDATE craplcm
    SET vllanmto = vr_vlpgmratit -- Mora de R$0.01 para R$9.60
    WHERE cdcooper = 2 
      AND nrdconta = 573094 
      AND dtmvtolt = to_date('04/04/2019')
      AND cdhistor = 2685
      AND nrdocmto = 3185;
  
    -- Extrato borderô
    DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                           ,pr_nrdconta => 573094
                                           ,pr_nrborder => 47374
                                           ,pr_dtmvtolt => to_date('04/04/2019','DD/MM/RRRR')
                                           ,pr_cdbandoc => 85
                                           ,pr_nrdctabb => 10210
                                           ,pr_nrcnvcob => 10210
                                           ,pr_nrdocmto => 3185
                                           ,pr_nrtitulo => 7
                                           ,pr_cdorigem => 7
                                           ,pr_cdhistor => 2686  --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO (operacao credito)
                                           ,pr_vllanmto => vr_vlpgmratit
                                           ,pr_dscritic => vr_dscritic );

    -- Condicao para verificar se houve critica                             
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
  END IF;
  
  IF (vr_vlpgsldtit > 0) THEN
    --Faz lançamento de PAGAMENTO DE TITULO no extrato
    DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                           ,pr_nrdconta => 573094
                                           ,pr_nrborder => 47374
                                           ,pr_dtmvtolt => to_date('04/04/2019','DD/MM/RRRR')
                                           ,pr_cdbandoc => 85
                                           ,pr_nrdctabb => 10210
                                           ,pr_nrcnvcob => 10210
                                           ,pr_nrdocmto => 3185
                                           ,pr_nrtitulo => 7
                                           ,pr_cdorigem => 7
                                           ,pr_cdhistor => 2671  --PAGTO DESCONTO DE TITULO (operacao credito)
                                           ,pr_vllanmto => vr_vlpgsldtit
                                           ,pr_dscritic => vr_dscritic );

    -- Condicao para verificar se houve critica                    
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
  END IF;
  
  -- Guarda o valor da ultima Mora
  vr_vlultmora := vr_vlmratit;
  -- Recalcula os juros para a Mora mensal
  cecred.dsct0003.pc_calcula_atraso_tit(pr_cdcooper => rw_craptdb.cdcooper,
                                        pr_nrdconta => rw_craptdb.nrdconta,
                                        pr_nrborder => rw_craptdb.nrborder,
                                        pr_cdbandoc => rw_craptdb.cdbandoc,
                                        pr_nrdctabb => rw_craptdb.nrdctabb,
                                        pr_nrcnvcob => rw_craptdb.nrcnvcob,
                                        pr_nrdocmto => rw_craptdb.nrdocmto,
                                        pr_dtmvtolt => to_date('30/04/2019', 'DD/MM/RRRR'),
                                        pr_vlmtatit => vr_vlmtatit,
                                        pr_vlmratit => vr_vlmratit,
                                        pr_vlioftit => vr_vlioftit,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);
  -- Verifica crítica               
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;  
  
  --Faz lançamento de PAGAMENTO DE TITULO no extrato
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                         ,pr_nrdconta => 573094
                                         ,pr_nrborder => 47374
                                         ,pr_dtmvtolt => to_date('30/04/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 10210
                                         ,pr_nrcnvcob => 10210
                                         ,pr_nrdocmto => 3185
                                         ,pr_nrtitulo => 7
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2668 --APROPR. JUROS DE MORA DESCONTO DE TITULO
                                         ,pr_vllanmto => vr_vlmratit - vr_vlultmora -- O valor calculado no mês, menos o valor já lançado.
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                    
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
  
  -- ***************
  -- Guarda o valor da ultima Mora
  vr_vlultmora := vr_vlmratit;
  -- Recalcula os juros para a Mora mensal
  cecred.dsct0003.pc_calcula_atraso_tit(pr_cdcooper => rw_craptdb.cdcooper,
                                        pr_nrdconta => rw_craptdb.nrdconta,
                                        pr_nrborder => rw_craptdb.nrborder,
                                        pr_cdbandoc => rw_craptdb.cdbandoc,
                                        pr_nrdctabb => rw_craptdb.nrdctabb,
                                        pr_nrcnvcob => rw_craptdb.nrcnvcob,
                                        pr_nrdocmto => rw_craptdb.nrdocmto,
                                        pr_dtmvtolt => to_date('31/05/2019', 'DD/MM/RRRR'),
                                        pr_vlmtatit => vr_vlmtatit,
                                        pr_vlmratit => vr_vlmratit,
                                        pr_vlioftit => vr_vlioftit,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);
  -- Verifica crítica               
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;  
  
  --Faz lançamento de PAGAMENTO DE TITULO no extrato
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                         ,pr_nrdconta => 573094
                                         ,pr_nrborder => 47374
                                         ,pr_dtmvtolt => to_date('31/05/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 10210
                                         ,pr_nrcnvcob => 10210
                                         ,pr_nrdocmto => 3185
                                         ,pr_nrtitulo => 7
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2668 --APROPR. JUROS DE MORA DESCONTO DE TITULO
                                         ,pr_vllanmto => vr_vlmratit - vr_vlultmora -- O valor calculado no mês, menos o valor já lançado.
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                    
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
  
  -- Atualiza a TDB com o valor da Mora
  UPDATE craptdb
  SET vlmratit = vr_vlmratit, -- Valor da Mora atualizado
      vlultmra = vr_vlmratit -- Ultima mora no dia 29/03/2019
  WHERE cdcooper = 2 
    AND nrborder = 47374 
    AND nrdocmto = 3185;
    
  -- Commita toda a operação
  COMMIT;
end;
13
pr_cdcooper
0
-5
pr_nrdconta
0
-5
pr_nrborder
0
-5
pr_cdbandoc
0
-5
pr_nrdctabb
0
-5
pr_nrcnvcob
0
-5
pr_nrdocmto
0
-5
pr_dtmvtolt
0
-5
pr_vlmtatit
0
-5
pr_vlmratit
0
-5
pr_vlioftit
0
-5
pr_cdcritic
0
-5
pr_dscritic
0
-5
0
