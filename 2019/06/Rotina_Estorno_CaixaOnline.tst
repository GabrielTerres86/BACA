PL/SQL Developer Test script 3.0
102
-- Created on 23/05/2019 by T0031859 
declare 
  /* Cursor genérico de calendário */
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;
  
   
  --Valores de saída da calcula_atraso_tit
  vr_vlioftit craptdb.vliofcpl%TYPE;
  
  -- Criticas
  vr_cdcritic     crapcri.cdcritic%TYPE;
  vr_dscritic     crapcri.dscritic%TYPE;
  
  vr_tab_erro     gene0001.typ_tab_erro;
  vr_des_erro     VARCHAR2(10000);
BEGIN
  -- Fix do título
  UPDATE craptdb 
  SET insittit = 2, dtultpag = to_date('25/03/2019', 'DD/MM/RRRR'), vliofcpl = 0, vlpagiof = 0, dtdpagto = to_date('25/03/2019', 'DD/MM/RRRR')
  WHERE cdcooper = 1 AND nrborder = 547833 AND nrdocmto = 179;

  -- Fix do extrato do borderô
  DELETE FROM tbdsct_lancamento_bordero 
  WHERE cdcooper = 1 AND nrborder = 547833 AND nrdocmto = 179 
  AND ((dtmvtolt = '25/02/2019' AND cdhistor = 2673) -- Pagamento do dia 25/02
    OR (dtmvtolt = '25/03/2019' AND cdhistor = 2804)); -- Lançamento valor a mais 25/03
  
  OPEN  cr_crapdat(pr_cdcooper => 1);
  FETCH cr_crapdat into rw_crapdat;
  CLOSE cr_crapdat;
  
  --Valor do IOF a partir da data de pagamento
  SELECT SUM(vllanmto) INTO vr_vlioftit FROM craplcm 
  WHERE cdhistor = 2321 AND nrdconta = 9442952 AND dtmvtolt >= to_date('25/02/2019') AND nrdocmto = 179  AND cdpesqbb LIKE '%547833%';
  
  -- Fix LCM
/*  DSCT0001.pc_abatimento_juros_titulo(pr_cdcooper => 1,
                                      pr_nrdconta => 9442952,
                                      pr_nrborder => 547833,
                                      pr_cdbandoc => 85,
                                      pr_nrdctabb => 101002,
                                      pr_nrcnvcob => 101002,
                                      pr_nrdocmto => 179,
                                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                      pr_cdagenci => 76,
                                      pr_cdoperad => 1,
                                      pr_cdorigpg => 0,
                                      pr_dtdpagto => to_date('25/03/2019', 'DD/MM/RRRR'),
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
                                                       
    -- Condicao para verificar se houve critica
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;*/
                                             
   DSCT0003.pc_efetua_lanc_cc (pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_cdagenci => 76
                              ,pr_cdbccxlt => 700
                              ,pr_nrdconta => 9442952
                              ,pr_vllanmto => vr_vlioftit --Calculado na rotina anterior
                              ,pr_cdhistor => 325
                              ,pr_cdcooper => 1
                              ,pr_cdoperad => '1'
                              ,pr_nrborder => 547833
                              ,pr_cdpactra => 0
                              ,pr_nrdocmto => 179
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
                              
    -- Condicao para verificar se houve critica
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    
    DSCT0001.pc_efetua_liquidacao_bordero(pr_cdcooper => 1,
                                          pr_cdagenci => 76,
                                          pr_nrdcaixa => 700,
                                          pr_cdoperad => 1,
                                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                          pr_idorigem => 1,
                                          pr_nrdconta => 9442952,
                                          pr_nrborder => 547833,
                                          pr_tab_erro => vr_tab_erro,
                                          pr_des_erro => vr_des_erro,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
                                          
    -- Condicao para verificar se houve critica
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
  
   COMMIT;
end;
0
0
