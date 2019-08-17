PL/SQL Developer Test script 3.0
288
-- Created on 23/04/2019 by T0031667 
declare 
  CURSOR cr_nrdocmto(pr_cdcooper NUMBER
                   , pr_dtmvtolt DATE
                   , pr_cdagenci NUMBER
                   , pr_cdbccxlt NUMBER
                   , pr_nrdolote NUMBER
                   , pr_nrdctabb NUMBER) IS 
  SELECT nvl(MAX(nrdocmto), 0) + 1 nrdocmto
    FROM craplcm
   WHERE cdcooper = pr_cdcooper
     AND dtmvtolt = pr_dtmvtolt
     AND cdagenci = pr_cdagenci
     AND cdbccxlt = pr_cdbccxlt
     AND nrdctabb = pr_nrdctabb;
     
  vr_nrdocmto NUMBER;  
  vr_incrineg INTEGER;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  vr_nrseqdig craplcm.nrseqdig%TYPE;
  
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
BEGIN
  OPEN BTCH0001.cr_crapdat(1);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;

  -- Test statements here
  OPEN cr_nrdocmto(pr_cdcooper => 1
                 , pr_dtmvtolt => rw_crapdat.dtmvtolt
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 650009
                 , pr_nrdctabb => 8770514);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(1)||';'||
                                    to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')||';'||
                                    '1;100;650009');

  -- Efetua débito do valor que será transferido para a Conta Transitória (créditos bloqueados por prejuízo em conta)
  INSERT INTO craplcm (
      dtmvtolt
    , cdagenci
    , cdbccxlt
    , nrdolote
    , nrdconta
    , nrdocmto
    , cdhistor
    , nrseqdig
    , vllanmto
    , nrdctabb
    , cdpesqbb
    , dtrefere
    , hrtransa
    , cdoperad
    , cdcooper
    , cdorigem
  )
  VALUES (
      rw_crapdat.dtmvtolt
    , 1
    , 100
    , 650009
    , 8770514
    , vr_nrdocmto
    , 2719
    , vr_nrseqdig
    , 501.37 
    , 8770514
    , 'ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO'
    , rw_crapdat.dtmvtolt
    , gene0002.fn_busca_time
    , 1
    , 1
    , 5
  );

  -- Insere lançamento do crédito transferido para a Conta Transitória
  INSERT INTO TBCC_PREJUIZO_LANCAMENTO (
         dtmvtolt
       , cdagenci
       , nrdconta
       , nrdocmto
       , cdhistor
       , vllanmto
       , dthrtran
       , cdoperad
       , cdcooper
       , cdorigem
  )
  VALUES (
         rw_crapdat.dtmvtolt
       , 1
       , 8770514
       , vr_nrdocmto
       , 2738 
       , 501.37 
       , SYSDATE
       , 1
       , 1
       , 5
  );  
  
  -- Insere lançamento do crédito transferido para a Conta Transitória
  INSERT INTO TBCC_PREJUIZO_LANCAMENTO (
         dtmvtolt
       , cdagenci
       , nrdconta
       , nrdocmto
       , cdhistor
       , vllanmto
       , dthrtran
       , cdoperad
       , cdcooper
       , cdorigem
  )
  VALUES (
         rw_crapdat.dtmvtolt
       , 1
       , 8770514
       , vr_nrdocmto + 1
       , 2739
       , 501.37 
       , SYSDATE
       , 1
       , 1
       , 5
  );
  
  OPEN cr_nrdocmto(pr_cdcooper => 1
                 , pr_dtmvtolt => rw_crapdat.dtmvtolt
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 650009
                 , pr_nrdctabb => 8770514);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(1)||';'||
                                    to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')||';'||
                                    '1;100;650009');

  -- Efetua débito do valor que será transferido para a Conta Transitória (créditos bloqueados por prejuízo em conta)
  INSERT INTO craplcm (
      dtmvtolt
    , cdagenci
    , cdbccxlt
    , nrdolote
    , nrdconta
    , nrdocmto
    , cdhistor
    , nrseqdig
    , vllanmto
    , nrdctabb
    , cdpesqbb
    , dtrefere
    , hrtransa
    , cdoperad
    , cdcooper
    , cdorigem
  )
  VALUES (
      rw_crapdat.dtmvtolt
    , 1
    , 100
    , 650009
    , 8770514
    , vr_nrdocmto
    , 2719
    , vr_nrseqdig
    , 2.11
    , 8770514
    , 'ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO'
    , rw_crapdat.dtmvtolt
    , gene0002.fn_busca_time
    , 1
    , 1
    , 5
  );

  -- Insere lançamento do crédito transferido para a Conta Transitória
  INSERT INTO TBCC_PREJUIZO_LANCAMENTO (
         dtmvtolt
       , cdagenci
       , nrdconta
       , nrdocmto
       , cdhistor
       , vllanmto
       , dthrtran
       , cdoperad
       , cdcooper
       , cdorigem
  )
  VALUES (
         rw_crapdat.dtmvtolt
       , 1
       , 8770514
       , vr_nrdocmto
       , 2738 
       , 2.11
       , SYSDATE
       , 1
       , 1
       , 5
  );  
  
  -- Insere lançamento do crédito transferido para a Conta Transitória
  INSERT INTO TBCC_PREJUIZO_LANCAMENTO (
         dtmvtolt
       , cdagenci
       , nrdconta
       , nrdocmto
       , cdhistor
       , vllanmto
       , dthrtran
       , cdoperad
       , cdcooper
       , cdorigem
  )
  VALUES (
         rw_crapdat.dtmvtolt
       , 1
       , 8770514
       , vr_nrdocmto + 1
       , 2739
       , 2.11
       , SYSDATE
       , 1
       , 1
       , 5
  );
  
  prej0003.pc_gera_lcto_extrato_prj(pr_cdcooper => 1
                                  , pr_nrdconta => 8770514
                                  , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  , pr_cdhistor => 384
                                  , pr_vllanmto => 501.37
                                  , pr_nrctremp => 1039405
                                  , pr_dthrtran => SYSDATE
                                  , pr_cdcritic => :pr_cdcritic
                                  , pr_dscritic => :pr_dscritic);                                 
                                  
  IF trim(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
    RETURN;
  END IF;
  
  prej0003.pc_gera_lcto_extrato_prj(pr_cdcooper => 1
                                  , pr_nrdconta => 8770514
                                  , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  , pr_cdhistor => 2795
                                  , pr_vllanmto => 2.11
                                  , pr_nrctremp => 1039405
                                  , pr_dthrtran => SYSDATE
                                  , pr_cdcritic => :pr_cdcritic
                                  , pr_dscritic => :pr_dscritic);                                 
                                  
  IF trim(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
    RETURN;
  END IF;
  
  UPDATE crapepr epr
     SET epr.vlpiofpr = epr.vlpiofpr + 2.11
   WHERE cdcooper = 1
     AND nrdconta = 8770514
     AND nrctremp = 1039405;
     
  UPDATE crapsld 
     SET dtrisclq = to_Date('30/04/2018', 'DD/MM/YYYY')
       , qtddsdev = (rw_crapdat.dtmvtoan - to_date('28/11/2018', 'DD/MM/YYYY')) + 211
   WHERE cdcooper = 1
     AND nrdconta = 8770514;
     
  UPDATE crapris 
     SET dtinictr = to_Date('30/04/2018', 'DD/MM/YYYY')
       , qtdiaatr = (rw_crapdat.dtmvtoan - to_date('28/11/2018', 'DD/MM/YYYY')) + 211
   WHERE cdcooper = 1
     AND nrdconta = 8770514
     AND dtrefere = rw_crapdat.dtmvtoan
     AND cdmodali = 101;
  
  COMMIT;
end;
2
pr_cdcritic
1
0
5
pr_dscritic
0
5
0
