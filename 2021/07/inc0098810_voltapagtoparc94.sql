declare 
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  vr_exc_saida     EXCEPTION;
  rw_crapdat       BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto      varchar(3);
  vr_tab_erro      GENE0001.typ_tab_erro;
  
 
  vr_cdcooper      crapcop.cdcooper%TYPE := 3;
  vr_nrdconta      crapass.nrdconta%TYPE := 94;
  vr_nrctremp      craplem.nrctremp%TYPE := 211409;
  vr_vllanmto      craplem.vllanmto%TYPE := 73077.39; --valor da parcela 3
  vr_cdhistor      craplem.cdhistor%TYPE := 2330; 
  vr_vlsdeved      crapepr.vlsdeved%TYPE := 24999336.51;
  vr_vlsprojt      crapepr.vlsprojt%TYPE := 24999336.51;
  vr_qtprecal      crapepr.qtprecal%TYPE;
  
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
BEGIN
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass INTO rw_crapass;
  CLOSE cr_crapass;
  
   -- Atualiza os dados da Parcela
  BEGIN
    UPDATE crappep c
       SET inliquid = 1
           ,vldespar = 0
           ,vlsdvpar = 0
           ,vlpagpar = 73077.39
           ,dtultpag = rw_crapdat.dtmvtolt
           ,dtdstjur = rw_crapdat.dtmvtolt
           ,vlparepr = 73077.39
           ,vlmtapar = 0
           ,vlmrapar = 0
           ,vlsdvatu = 0
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       AND c.nrparepr = 3;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => rw_crapass.cdagenci
                                 ,pr_cdbccxlt => 100
                                 ,pr_cdoperad => 1
                                 ,pr_cdpactra => rw_crapass.cdagenci
                                 ,pr_tplotmov => 5
                                 ,pr_nrdolote => 650004
                                 ,pr_nrdconta => vr_nrdconta
                                 ,pr_cdhistor => vr_cdhistor
                                 ,pr_nrctremp => vr_nrctremp
                                 ,pr_vllanmto => vr_vllanmto
                                 ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                 ,pr_txjurepr => 0
                                 ,pr_vlpreemp => 0
                                 ,pr_nrsequni => 0
                                 ,pr_nrparepr => 3
                                 ,pr_flgincre => FALSE
                                 ,pr_flgcredi => FALSE
                                 ,pr_nrseqava => 0
                                 ,pr_cdorigem => 5
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => vr_cdcooper   --> Cooperativa conectada
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Movimento atual
                                ,pr_cdagenci => rw_crapass.cdagenci   --> Codigo da agencia
                                ,pr_cdbccxlt => 100           --> Numero do caixa
                                ,pr_cdoperad => 1   --> Codigo do operador
                                ,pr_cdpactra => rw_crapass.cdagenci   --> PA da transacao
                                ,pr_nrdolote => 650003        --> Numero do Lote
                                ,pr_nrdconta => vr_nrdconta   --> Número da conta
                                ,pr_cdhistor => 2332   --> Codigo historico
                                ,pr_vllanmto => vr_vllanmto   
                                ,pr_nrparepr => 3   
                                ,pr_nrctremp => vr_nrctremp   --> Numero do contrato de emprestimo
                                ,pr_nrseqava => 0   --> Pagamento: Sequencia do avalista
                                ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
                                        
  IF vr_des_reto <> 'OK' THEN
    RAISE vr_exc_saida;
  END IF;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 84853.72
          ,vlsdvpar = 84853.72
          ,vlsdvatu = 84853.72
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 4;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 88901.63
          ,vlsdvpar = 88901.63
          ,vlsdvatu = 88901.63
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 5;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 84853.72
          ,vlsdvpar = 84853.72
          ,vlsdvatu = 84853.72
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 6;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 76760.14
          ,vlsdvpar = 76760.14
          ,vlsdvatu = 76760.14
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 7;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 88901.54
          ,vlsdvpar = 88901.54
          ,vlsdvatu = 88901.54
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 8;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 88901.63
          ,vlsdvpar = 88901.63
          ,vlsdvatu = 88901.63
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 9;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 88901.54
          ,vlsdvpar = 88901.54
          ,vlsdvatu = 88901.54
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 10;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 72714.21
          ,vlsdvpar = 72714.21
          ,vlsdvatu = 72714.21
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 11;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
   BEGIN
    UPDATE crappep c
       SET vlparepr = 88901.63
          ,vlsdvpar = 88901.63
          ,vlsdvatu = 88901.63
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 12;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 669253.86  
          ,vlsdvpar = 669253.86
          ,vlsdvatu = 669253.86
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr between 13 and 51;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 669253.86  
          ,vlsdvpar = 160150.85
          ,vlsdvatu = 160150.85
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 52;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
    -- Atualiza os dados do Emprestimo
  BEGIN
    UPDATE crapepr
       SET crapepr.vlsdeved = vr_vlsdeved
          ,crapepr.vlsprojt = vr_vlsprojt
          ,crapepr.dtultpag = rw_crapdat.dtmvtolt
          ,crapepr.vlpreemp = 84853.72
          ,crapepr.dtdpagto = to_date('15/08/2021','dd/mm/yyyy')
     WHERE crapepr.cdcooper = vr_cdcooper
       AND crapepr.nrdconta = vr_nrdconta
       AND crapepr.nrctremp = vr_nrctremp;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  COMMIT;
  
  EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
