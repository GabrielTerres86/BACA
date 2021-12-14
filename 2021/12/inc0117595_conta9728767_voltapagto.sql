declare 
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  vr_exc_saida     EXCEPTION;
  rw_crapdat       BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto      varchar(3);
  vr_tab_erro      GENE0001.typ_tab_erro;
  
  vr_cdcooper      crapcop.cdcooper%TYPE := 1;
  vr_nrdconta      crapass.nrdconta%TYPE := 9728767;
  vr_nrctremp      craplem.nrctremp%TYPE := 2387718;

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

  -- Cria o lancamento de estorno
  EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => rw_crapass.cdagenci
                                 ,pr_cdbccxlt => 100
                                 ,pr_cdoperad => 1
                                 ,pr_cdpactra => rw_crapass.cdagenci
                                 ,pr_tplotmov => 5
                                 ,pr_nrdolote => 600031
                                 ,pr_nrdconta => vr_nrdconta
                                 ,pr_cdhistor => 3273
                                 ,pr_nrctremp => vr_nrctremp
                                 ,pr_vllanmto => 152.59
                                 ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                 ,pr_txjurepr => 0
                                 ,pr_vlpreemp => 0
                                 ,pr_nrsequni => 0
                                 ,pr_nrparepr => 0
                                 ,pr_flgincre => FALSE
                                 ,pr_flgcredi => FALSE
                                 ,pr_nrseqava => 0
                                 ,pr_cdorigem => 5
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  -- Cria o lancamento de contrapartida ao 2471 
  EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => rw_crapass.cdagenci
                                 ,pr_cdbccxlt => 100
                                 ,pr_cdoperad => 1
                                 ,pr_cdpactra => rw_crapass.cdagenci
                                 ,pr_tplotmov => 5
                                 ,pr_nrdolote => 600031
                                 ,pr_nrdconta => vr_nrdconta
                                 ,pr_cdhistor => 2472
                                 ,pr_nrctremp => vr_nrctremp
                                 ,pr_vllanmto => 152.5
                                 ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                 ,pr_txjurepr => 0
                                 ,pr_vlpreemp => 0
                                 ,pr_nrsequni => 0
                                 ,pr_nrparepr => 0
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
                                ,pr_nrdolote => 600031        --> Numero do Lote
                                ,pr_nrdconta => vr_nrdconta   --> Número da conta
                                ,pr_cdhistor => 3689   --> Codigo historico
                                ,pr_vllanmto => 152.59   
                                ,pr_nrparepr => 0   
                                ,pr_nrctremp => vr_nrctremp   --> Numero do contrato de emprestimo
                                ,pr_nrseqava => 0   --> Pagamento: Sequencia do avalista
                                ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
                                        
  IF vr_des_reto <> 'OK' THEN
    RAISE vr_exc_saida;
  END IF;

  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
end;
