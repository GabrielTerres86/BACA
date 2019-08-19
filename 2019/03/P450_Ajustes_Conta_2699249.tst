PL/SQL Developer Test script 3.0
49
-- Created on 26/03/2019 by T0031667 
declare 
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
BEGIN
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => 1);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;  

  -- Redefine data de início de atraso para corrigir problema da mensagem de erro ao recuperar saldo 59 dias de atraso da conta
  UPDATE crapsld
     SET dtrisclq = to_date('30/04/2018', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 2699249;
   
  UPDATE crapris 
     SET dtinictr = to_date('30/04/2018', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 2699249
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtmvtoan;
  
  -- Incrementa prejuízo com valor de 0,43 referente a IOF do pagamento que foi estornado
  PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => 1
                                  , pr_nrdconta => 2699249
                                  , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  , pr_cdhistor => 2408
                                  , pr_vllanmto => 0.43
                                  , pr_cdcritic => :pr_cdcritic
                                  , pr_dscritic => :pr_dscritic);
                                  
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
    RETURN;
  END IF;
  
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej + 0.43
   WHERE cdcooper = 1
     AND nrdconta = 2699249
     AND dtliquidacao IS NULL;
     
  -- Redefine a data do último estorno do contrato para permitir estornas parcelas pagas em '19/03/2019'
  UPDATE crapepr
     SET dtultest = to_date('19/04/2018', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 2699249
     AND nrctremp = 557298;
     
  COMMIT;
end;
2
pr_cdcritic
0
5
pr_dscritic
0
5
0
