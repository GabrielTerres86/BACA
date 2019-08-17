PL/SQL Developer Test script 3.0
255
-- Created on 02/04/2019 by T0031667 
declare 
  vr_vlsld59d NUMBER;
  vr_vlju6037 NUMBER;
  vr_vlju6038 NUMBER;
  vr_vlju6057 NUMBER;
  
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
BEGIN
  UPDATE crapsld
     SET dtrisclq = to_date('29/12/2017', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 8284377;
     
  UPDATE crapris
     SET dtinictr = to_date('29/12/2017', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 8284377
     AND nrctremp = 8284377
     AND cdmodali = 101
     AND dtrefere = (SELECT dtultdma FROM crapdat WHERE cdcooper = 1);
     
  UPDATE crapris
     SET dtinictr = to_date('29/12/2017', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 8284377
     AND nrctremp = 8284377
     AND cdmodali = 101
     AND dtrefere = (SELECT dtmvtoan FROM crapdat WHERE cdcooper = 1);
     
     
     
  UPDATE crapsld
     SET dtrisclq = to_date('30/04/2018', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 8834547;
     
  UPDATE crapris
     SET dtinictr = to_date('30/04/2018', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 8834547
     AND nrctremp = 8834547
     AND cdmodali = 101
     AND dtrefere = (SELECT dtultdma FROM crapdat WHERE cdcooper = 1);
     
  UPDATE crapris
     SET dtinictr = to_date('30/04/2018', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 8834547
     AND nrctremp = 8834547
     AND cdmodali = 101
     AND dtrefere = (SELECT dtmvtoan FROM crapdat WHERE cdcooper = 1);
     
     
     
  UPDATE crapsld
     SET dtrisclq = to_date('30/04/2018', 'DD/MM/YYYY')
   WHERE cdcooper = 9
     AND nrdconta = 67326;
     
  UPDATE crapris
     SET dtinictr = to_date('30/04/2018', 'DD/MM/YYYY')
   WHERE cdcooper = 9
     AND nrdconta = 67326
     AND nrctremp = 67326
     AND cdmodali = 101
     AND dtrefere = (SELECT dtultdma FROM crapdat WHERE cdcooper = 9);
     
  UPDATE crapris
     SET dtinictr = to_date('30/04/2018', 'DD/MM/YYYY')
   WHERE cdcooper = 9
     AND nrdconta = 67326
     AND nrctremp = 67326
     AND cdmodali = 101
     AND dtrefere = (SELECT dtmvtoan FROM crapdat WHERE cdcooper = 9);
  
  OPEN BTCH0001.cr_crapdat(1);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;   
  
  TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60_det(pr_cdcooper => 1
                                                 , pr_nrdconta => 8284377
                                                 , pr_dtlimite => to_date('31/03/2019', 'DD/MM/YYYY')
                                                 , pr_dtinictr => to_date('29/12/2017', 'DD/MM/YYYY')
                                                 , pr_vlsld59d => vr_vlsld59d
                                                 , pr_vlju6037 => vr_vlju6037
                                                 , pr_vlju6038 => vr_vlju6038
                                                 , pr_vlju6057 => vr_vlju6057
                                                 , pr_cdcritic => :pr_cdcritic
                                                 , pr_dscritic => :pr_dscritic);
                                                 
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
    RETURN;
  END IF;
  
  UPDATE crapris
     SET vlsld59d = vr_vlsld59d
       , vljura60 = vr_vlju6037 + vr_vlju6038 + vr_vlju6057
   WHERE cdcooper = 1
     AND nrdconta = 8284377
     AND nrctremp = 8284377
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtultdma;
     
  UPDATE crapris
     SET vlsld59d = vr_vlsld59d
       , vljura60 = vr_vlju6037 + vr_vlju6038 + vr_vlju6057
   WHERE cdcooper = 1
     AND nrdconta = 8284377
     AND nrctremp = 8284377
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtmvtoan; 
     
  UPDATE crapvri
     SET vldivida = vr_vlsld59d
   WHERE cdcooper = 1
     AND nrdconta = 8284377
     AND nrctremp = 8284377
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtultdma;
  
  UPDATE crapvri
     SET vldivida = vr_vlsld59d
   WHERE cdcooper = 1
     AND nrdconta = 8284377
     AND nrctremp = 8284377
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtmvtoan;
     
  TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60_det(pr_cdcooper => 1
                                                 , pr_nrdconta => 8834547
                                                 , pr_dtlimite => to_date('31/03/2019', 'DD/MM/YYYY')
                                                 , pr_dtinictr => to_date('30/04/2018', 'DD/MM/YYYY')
                                                 , pr_vlsld59d => vr_vlsld59d
                                                 , pr_vlju6037 => vr_vlju6037
                                                 , pr_vlju6038 => vr_vlju6038
                                                 , pr_vlju6057 => vr_vlju6057
                                                 , pr_cdcritic => :pr_cdcritic
                                                 , pr_dscritic => :pr_dscritic);
                                                 
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
    RETURN;
  END IF;
  
  UPDATE crapris
     SET vlsld59d = vr_vlsld59d
       , vljura60 = vr_vlju6037 + vr_vlju6038 + vr_vlju6057
   WHERE cdcooper = 1
     AND nrdconta = 8834547
     AND nrctremp = 8834547
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtultdma;
     
  UPDATE crapris
     SET vlsld59d = vr_vlsld59d
       , vljura60 = vr_vlju6037 + vr_vlju6038 + vr_vlju6057
   WHERE cdcooper = 1
     AND nrdconta = 8834547
     AND nrctremp = 8834547
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtmvtoan; 
     
  UPDATE crapvri
     SET vldivida = vr_vlsld59d
   WHERE cdcooper = 1
     AND nrdconta = 8834547
     AND nrctremp = 8834547
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtultdma;
  
  UPDATE crapvri
     SET vldivida = vr_vlsld59d
   WHERE cdcooper = 1
     AND nrdconta = 8834547
     AND nrctremp = 8834547
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtmvtoan;
     
  OPEN BTCH0001.cr_crapdat(9);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;   
  
  TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60_det(pr_cdcooper => 9
                                                 , pr_nrdconta => 67326
                                                 , pr_dtlimite => to_date('31/03/2019', 'DD/MM/YYYY')
                                                 , pr_dtinictr => to_date('30/04/2018', 'DD/MM/YYYY')
                                                 , pr_vlsld59d => vr_vlsld59d
                                                 , pr_vlju6037 => vr_vlju6037
                                                 , pr_vlju6038 => vr_vlju6038
                                                 , pr_vlju6057 => vr_vlju6057
                                                 , pr_cdcritic => :pr_cdcritic
                                                 , pr_dscritic => :pr_dscritic);
                                                 
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
    RETURN;
  END IF;
  
  UPDATE crapris
     SET vlsld59d = vr_vlsld59d
       , vljura60 = vr_vlju6037 + vr_vlju6038 + vr_vlju6057
   WHERE cdcooper = 9
     AND nrdconta = 67326
     AND nrctremp = 67326
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtultdma;
     
  UPDATE crapris
     SET vlsld59d = vr_vlsld59d
       , vljura60 = vr_vlju6037 + vr_vlju6038 + vr_vlju6057
   WHERE cdcooper = 9
     AND nrdconta = 67326
     AND nrctremp = 67326
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtmvtoan; 
     
  UPDATE crapvri
     SET vldivida = vr_vlsld59d
   WHERE cdcooper = 9
     AND nrdconta = 67326
     AND nrctremp = 67326
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtultdma;
  
  UPDATE crapvri
     SET vldivida = vr_vlsld59d
   WHERE cdcooper = 9
     AND nrdconta = 67326
     AND nrctremp = 67326
     AND cdmodali = 101
     AND dtrefere = rw_crapdat.dtmvtoan;
     
  UPDATE crapvri
     SET vldivida = 103.42
   WHERE cdcooper = 1
     AND nrdconta = 2328933
     AND nrctremp = 1136856
     AND cdvencto = 165
     AND cdmodali = 299
     AND dtrefere = to_date('31/03/2019', 'DD/MM/YYYY');
     
  UPDATE crapvri
     SET vldivida = 62.94
   WHERE cdcooper = 1
     AND nrdconta = 7012969
     AND nrctremp = 1149532
     AND cdvencto = 165
     AND cdmodali = 299
     AND dtrefere = to_date('31/03/2019', 'DD/MM/YYYY');    
     
  UPDATE craphis
     SET intransf_cred_prejuizo = 0
   WHERE cdhistor = 662;
     
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
