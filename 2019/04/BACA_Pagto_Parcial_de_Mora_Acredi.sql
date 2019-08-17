DECLARE
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_vlmtatit craptdb.vlmtatit%TYPE;
  vr_vlmratit craptdb.vlmratit%TYPE;
  vr_vlioftit craptdb.vliofcpl%TYPE;
  vr_dtmvtolt crapdat.dtmvtolt%TYPE;                     
BEGIN
  
  /* 27/03/2019 -> Pagamento total de R$3109,17 */
  /* ======= AJUSTES NO EXTRATO DA OPERAÇÃO ======= */      

  -- Inserir apropriação de juros de mora (2668) no valor de R$22,04
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                         ,pr_nrdconta => 708763
                                         ,pr_nrborder => 46677
                                         ,pr_dtmvtolt => to_date('27/03/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 102030
                                         ,pr_nrcnvcob => 102030
                                         ,pr_nrdocmto => 1164
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2668
                                         ,pr_vllanmto => 22.04
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
  
  -- Inserir pagamento de juros de mora (2686) no valor de R$28,98
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                         ,pr_nrdconta => 708763
                                         ,pr_nrborder => 46677
                                         ,pr_dtmvtolt => to_date('27/03/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 102030
                                         ,pr_nrcnvcob => 102030
                                         ,pr_nrdocmto => 1164
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2686
                                         ,pr_vllanmto => 28.98
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
  
  -- Ajustar pagamento do sd. devedor (2671) de R$3107,71 para R$3078,73 
  UPDATE tbdsct_lancamento_bordero lbd
     SET lbd.vllanmto = 3078.73 
     where lbd.cdcooper = 2 
     and lbd.nrdconta = 708763 
     and lbd.nrborder = 46677 
     and lbd.nrdocmto = 1164 
     and lbd.dtmvtolt = to_date('27/03/2019','DD/MM/RRRR') 
     AND lbd.cdhistor = 2671 
     AND lbd.vllanmto = 3107.71; 
  
  
  /* 29/03/2019 -> Apropriação de juros de mora */
  /* ======= AJUSTES NO EXTRATO DA OPERAÇÃO ======= */      

  -- Inserir apropriação de juros de mora (2668) no valor de R$3,47
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                         ,pr_nrdconta => 708763
                                         ,pr_nrborder => 46677
                                         ,pr_dtmvtolt => to_date('29/03/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 102030
                                         ,pr_nrcnvcob => 102030
                                         ,pr_nrdocmto => 1164
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2668
                                         ,pr_vllanmto => 3.47
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;

        
/*     
03/04/2019 -> Pagamento total de R$5186,03         

    Incorreto:
    
        R$1,20 (IOF Complementar)
        R$5184,83 (Saldo devedor do título)
 
    Correto:
    
        R$1,20 (IOF Complementar)
        R$12,14 (Juros de Mora)
        R$5172,69 (Saldo devedor do título)
        
    * Extrato da operação (baca)
    
        Inserir apropriação de juros de mora (2668) no valor de R$8,67
        Inserir pagamento de juros de mora (2686) no valor de R$12,14
        Ajustar pagamento do sd. devedor (2671) de R$5.184,83 para R$5172,69 
    
    * Extrato da conta corrente (lançar manualmente)

        Inserir pagamento de juros de mora (2685) no valor de R$12,14
        Ajustar pagamento do sd. devedor (2670) de R$3107,71 para R$5172,69
        Remover lançamentos com o valor zerado
        
    # SALDO DEVEDOR DO TÍTULO: 52,98
*/

  /* 03/04/2019 -> Pagamento total de R$5186,03 */
  /* ======= AJUSTES NO EXTRATO DA OPERAÇÃO ======= */
  
  -- Inserir apropriação de juros de mora (2668) no valor de R$8,67
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                         ,pr_nrdconta => 708763
                                         ,pr_nrborder => 46677
                                         ,pr_dtmvtolt => to_date('03/04/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 102030
                                         ,pr_nrcnvcob => 102030
                                         ,pr_nrdocmto => 1164
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2668
                                         ,pr_vllanmto => 8.67
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
    
  -- Inserir pagamento de juros de mora (2686) no valor de R$12,14
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                         ,pr_nrdconta => 708763
                                         ,pr_nrborder => 46677
                                         ,pr_dtmvtolt => to_date('03/04/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 102030
                                         ,pr_nrcnvcob => 102030
                                         ,pr_nrdocmto => 1164
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2686
                                         ,pr_vllanmto => 12.14
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
  
  --Ajustar pagamento do sd. devedor (2671) de R$5.184,83 para R$5172,69 
  UPDATE tbdsct_lancamento_bordero lbd
     SET lbd.vllanmto = 5172.69  
   where lbd.cdcooper = 2 
     and lbd.nrdconta = 708763 
     and lbd.nrborder = 46677 
     and lbd.nrdocmto = 1164 
     and lbd.dtmvtolt = to_date('03/04/2019','DD/MM/RRRR') 
     AND lbd.cdhistor = 2671 
     AND lbd.vllanmto = 5184.83;
  
  /* ======= AJUSTES NO EXTRATO DO COOPERADO ======= */
  -- Remover lançamentos com o valor zerado
  delete  
    from craplcm lcm
   where lcm.cdcooper = 2 
     and lcm.nrdconta = 708763 
     and lcm.nrdocmto = 1164 
     and lcm.dtmvtolt = to_date('03/04/2019','DD/MM/RRRR')
     and lcm.vllanmto = 0.00; 
      
/*    
09/04/2019 -> Pagamento total de R$2,00
    
   Incorreto:
    
        R$1,10 (IOF Complementar)
        R$0,02 (Saldo devedor do título)
        R$0,88 (Saldo devedor do título)
 
    Correto:
    
        R$1,10 (IOF Complementar)
        R$0,02 (Juros de Mora)
        R$0,09 (Juros de Mora)
        R$0,79 (Saldo devedor do título)
        
    * Extrato da operação (baca)
        
        Remover pagamento de R$0,02 (Saldo devedor do título)
        Inserir apropriação de juros de mora (2668) no valor de R$0,11
        Inserir pagamento de juros de mora (2686) no valor de R$0,02
        Inserir pagamento de juros de mora (2686) no valor de R$0,09
        Ajustar pagamento do sd. devedor (2671) de R$0,88 para R$0,79 
    
    * Extrato da conta corrente (lançar manualmente)

        Inserir pagamento de juros de mora (2685) no valor de R$0,02
        Inserir pagamento de juros de mora (2685) no valor de R$0,09
        Ajustar pagamento do sd. devedor (2670) de R$0,88 para R$0,79
        
    # SALDO DEVEDOR DO TÍTULO: 52,19
*/
  
  /* 09/04/2019 -> Pagamento total de R$2,00 */
  /* ======= AJUSTES NO EXTRATO DA OPERAÇÃO ======= */

  --Remover pagamento de R$0,02 (Saldo devedor do título)
  delete  
    from tbdsct_lancamento_bordero lbd
   where lbd.cdcooper = 2
     and lbd.nrdconta = 708763
     and lbd.nrborder = 46677
     and lbd.nrdocmto = 1164
     and lbd.dtmvtolt = to_date('09/04/2019','DD/MM/RRRR')
     AND lbd.cdhistor = 2671
     and lbd.vllanmto = 0.02;
      
  -- Inserir apropriação de juros de mora (2668) no valor de R$0,11
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                         ,pr_nrdconta => 708763
                                         ,pr_nrborder => 46677
                                         ,pr_dtmvtolt => to_date('09/04/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 102030
                                         ,pr_nrcnvcob => 102030
                                         ,pr_nrdocmto => 1164
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2668
                                         ,pr_vllanmto => 0.11
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;      
  
  -- Inserir pagamento de juros de mora (2686) no valor de R$0,02
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                         ,pr_nrdconta => 708763
                                         ,pr_nrborder => 46677
                                         ,pr_dtmvtolt => to_date('09/04/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 102030
                                         ,pr_nrcnvcob => 102030
                                         ,pr_nrdocmto => 1164
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2686
                                         ,pr_vllanmto => 0.02
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
  
  -- Inserir pagamento de juros de mora (2686) no valor de R$0,09
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 2
                                         ,pr_nrdconta => 708763
                                         ,pr_nrborder => 46677
                                         ,pr_dtmvtolt => to_date('09/04/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 102030
                                         ,pr_nrcnvcob => 102030
                                         ,pr_nrdocmto => 1164
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2686
                                         ,pr_vllanmto => 0.09
                                         ,pr_dscritic => vr_dscritic );

  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
    RETURN;
  END IF;
  
  -- Ajustar pagamento do sd. devedor (2671) de R$0,88 para R$0,79 
  update tbdsct_lancamento_bordero lbd
     set lbd.vllanmto = 0.79
   where lbd.cdcooper = 2
     and lbd.nrdconta = 708763
     and lbd.nrborder = 46677
     and lbd.nrdocmto = 1164
     and lbd.dtmvtolt = to_date('09/04/2019','DD/MM/RRRR')
     AND lbd.cdhistor = 2671
     and lbd.vllanmto = 0.88;
  
  SELECT dtmvtolt INTO vr_dtmvtolt FROM crapdat dat where dat.cdcooper = 2;
  
  -- Ajustar dados da craptdb
  UPDATE craptdb tdb
     SET tdb.vlsldtit = tdb.vltitulo - (SELECT SUM(lbd.vllanmto) 
                                          FROM tbdsct_lancamento_bordero lbd 
                                         WHERE lbd.cdcooper = 2 
                                           and lbd.nrdconta = 708763 
                                           and lbd.nrborder = 46677 
                                           and lbd.nrdocmto = 1164 
                                           AND lbd.cdhistor IN (2671, 2672, 2673,2675)),
         tdb.dtultpag = (SELECT MAX(lbd.dtmvtolt) 
                           FROM tbdsct_lancamento_bordero lbd 
                          WHERE lbd.cdcooper = 2 
                            and lbd.nrdconta = 708763 
                            and lbd.nrborder = 46677 
                            and lbd.nrdocmto = 1164 
                            AND lbd.cdhistor IN (2671, 2672, 2673,2675)),
         tdb.vlultmra = 175.35                   
  where tdb.cdcooper = 2
    and tdb.nrdconta = 708763
    and tdb.nrborder = 46677
    and tdb.nrdocmto = 1164;
    
  -- Calcula o atraso do título
  DSCT0003.pc_calcula_atraso_tit (pr_cdcooper => 2
                                 ,pr_nrdconta => 708763
                                 ,pr_nrborder => 46677
                                 ,pr_cdbandoc => 85
                                 ,pr_nrdctabb => 102030
                                 ,pr_nrcnvcob => 102030
                                 ,pr_nrdocmto => 1164
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
                           WHERE lbd.cdcooper = 2 
                             and lbd.nrdconta = 708763 
                             and lbd.nrborder = 46677 
                             and lbd.nrdocmto = 1164 
                             AND lbd.cdhistor IN (2686, 2688))
  where tdb.cdcooper = 2
    and tdb.nrdconta = 708763
    and tdb.nrborder = 46677
    and tdb.nrdocmto = 1164;
      
END;
