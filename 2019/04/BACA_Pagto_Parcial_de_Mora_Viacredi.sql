DECLARE
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_vlmtatit craptdb.vlmtatit%TYPE;
  vr_vlmratit craptdb.vlmratit%TYPE;
  vr_vlioftit craptdb.vliofcpl%TYPE;
  vr_dtmvtolt crapdat.dtmvtolt%TYPE;                     
BEGIN
  
  /* Pagamento no dia 26/03/2019 no valor de R$1,90 */
  /* ======= AJUSTES NO EXTRATO DA OPERAÇÃO ======= */      

  -- Inserir apropriação de juros de mora (2668) no valor de R$0,92
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 1
                                         ,pr_nrdconta => 7543387
                                         ,pr_nrborder => 545527
                                         ,pr_dtmvtolt => to_date('26/03/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 101002
                                         ,pr_nrcnvcob => 101002
                                         ,pr_nrdocmto => 126
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2668
                                         ,pr_vllanmto => 0.92
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
  
  -- Inserir pagamento de juros de mora (2686) no valor de R$0,92
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 1
                                         ,pr_nrdconta => 7543387
                                         ,pr_nrborder => 545527
                                         ,pr_dtmvtolt => to_date('26/03/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 101002
                                         ,pr_nrcnvcob => 101002
                                         ,pr_nrdocmto => 126
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2686
                                         ,pr_vllanmto => 0.92
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
  
  -- Ajustar pagamento do sd. devedor (2671) de R$1,66 para R$0,74 
  UPDATE tbdsct_lancamento_bordero lbd
     SET lbd.vllanmto = 0.74 
   where lbd.cdcooper = 1 
     and lbd.nrdconta = 7543387 
     and lbd.nrborder = 545527 
     and lbd.nrdocmto = 126 
     and lbd.dtmvtolt = to_date('26/03/2019','DD/MM/RRRR') 
     AND lbd.cdhistor = 2671 
     AND lbd.vllanmto = 1.66; 
  
  
  /* 29/03/2019 -> Apropriação de juros de mora */
  /* ======= AJUSTES NO EXTRATO DA OPERAÇÃO ======= */      

  -- Inserir apropriação de juros de mora (2668) no valor de R$0,34
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 1
                                         ,pr_nrdconta => 7543387
                                         ,pr_nrborder => 545527
                                         ,pr_dtmvtolt => to_date('29/03/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 101002
                                         ,pr_nrcnvcob => 101002
                                         ,pr_nrdocmto => 126
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2668
                                         ,pr_vllanmto => 0.34
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;

  /* Pagamento no dia 09/04/2019 no valor de R12,93 */
  /* ======= AJUSTES NO EXTRATO DA OPERAÇÃO ======= */
  
  -- Inserir apropriação de juros de mora (2668) no valor de R$1,26
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 1
                                         ,pr_nrdconta => 7543387
                                         ,pr_nrborder => 545527
                                         ,pr_dtmvtolt => to_date('09/04/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 101002
                                         ,pr_nrcnvcob => 101002
                                         ,pr_nrdocmto => 126
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2668
                                         ,pr_vllanmto => 1.26
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
    
  -- Inserir pagamento de juros de mora (2686) no valor de R$1,60
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 1
                                         ,pr_nrdconta => 7543387
                                         ,pr_nrborder => 545527
                                         ,pr_dtmvtolt => to_date('09/04/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 101002
                                         ,pr_nrcnvcob => 101002
                                         ,pr_nrdocmto => 126
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2686
                                         ,pr_vllanmto => 1.60
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
  
  --Ajustar pagamento do sd. devedor (2671) de R$5.184,83 para R$5172,69 
  UPDATE tbdsct_lancamento_bordero lbd
     SET lbd.vllanmto = 10.89   
   where lbd.cdcooper = 1 
     and lbd.nrdconta = 7543387 
     and lbd.nrborder = 545527 
     and lbd.nrdocmto = 126 
     and lbd.dtmvtolt = to_date('09/04/2019','DD/MM/RRRR') 
     AND lbd.cdhistor = 2671 
     AND lbd.vllanmto = 12.49;
      

  SELECT dtmvtolt INTO vr_dtmvtolt FROM crapdat dat where dat.cdcooper = 1;
  
  -- Ajustar dados da craptdb
  UPDATE craptdb tdb
     SET tdb.vlsldtit = tdb.vltitulo - (SELECT SUM(lbd.vllanmto) 
                                          FROM tbdsct_lancamento_bordero lbd 
                                         WHERE lbd.cdcooper = 1 
                                           and lbd.nrdconta = 7543387 
                                           and lbd.nrborder = 545527 
                                           and lbd.nrdocmto = 126 
                                           AND lbd.cdhistor IN (2671, 2672, 2673,2675)),
         tdb.dtultpag = (SELECT MAX(lbd.dtmvtolt) 
                           FROM tbdsct_lancamento_bordero lbd 
                          WHERE lbd.cdcooper = 1 
                            and lbd.nrdconta = 7543387 
                            and lbd.nrborder = 545527 
                            and lbd.nrdocmto = 126 
                            AND lbd.cdhistor IN (2671, 2672, 2673,2675)),
         tdb.vlultmra = 16.48                   
  where tdb.cdcooper = 1
    and tdb.nrdconta = 7543387
    and tdb.nrborder = 545527
    and tdb.nrdocmto = 126;
    
  -- Calcula o atraso do título
  DSCT0003.pc_calcula_atraso_tit (pr_cdcooper => 1
                                 ,pr_nrdconta => 7543387
                                 ,pr_nrborder => 545527
                                 ,pr_cdbandoc => 85
                                 ,pr_nrdctabb => 101002
                                 ,pr_nrcnvcob => 101002
                                 ,pr_nrdocmto => 126
                                 ,pr_dtmvtolt => vr_dtmvtolt
                                 ,pr_vlmtatit => vr_vlmtatit
                                 ,pr_vlmratit => vr_vlmratit
                                 ,pr_vlioftit => vr_vlioftit
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic );

  IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
    RAISE_application_error(-20001,vr_cdcritic||' - '||vr_dscritic);
  END IF;  
  
  UPDATE craptdb tdb
     SET tdb.vlmratit = vr_vlmratit,
         tdb.vlpagmra = (SELECT SUM(lbd.vllanmto) 
                            FROM tbdsct_lancamento_bordero lbd 
                           WHERE lbd.cdcooper = 1 
                             and lbd.nrdconta = 7543387 
                             and lbd.nrborder = 545527 
                             and lbd.nrdocmto = 126 
                             AND lbd.cdhistor IN (2686, 2688))
  where tdb.cdcooper = 1
    and tdb.nrdconta = 7543387
    and tdb.nrborder = 545527
    and tdb.nrdocmto = 126;
      
END;
