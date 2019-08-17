PL/SQL Developer Test script 3.0
192
-- Created on 19/02/2019 by T0031667 
declare 
  CURSOR cr_nrdocmto(pr_cdcooper NUMBER
                   , pr_nrdconta number) IS 
  SELECT nvl(MAX(nrdocmto), 0) + 1
    FROM craplcm
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
     AND dtmvtolt = TRUNC(SYSDATE)
  ;
  
  vr_nrseqdig craplcm.nrseqdig%TYPE;
  vr_nrdocmto craplcm.nrdocmto%TYPE;
BEGIN
  :RESULT:= 'Erro';
  
  -- Coop 1 / Conta 8834547
  OPEN cr_nrdocmto(1, 8834547);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(1)||';'||
                                    to_char(TRUNC(SYSDATE), 'DD/MM/RRRR')||';'||
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
      trunc(SYSDATE)
    , 1
    , 100
    , 650009
    , 8834547
    , vr_nrdocmto
    , 2719
    , vr_nrseqdig
    , 387.08
    , 8834547
    , 'ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO'
    , TRUNC(SYSDATE)
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
         TRUNC(SYSDATE)
       , 1
       , 8834547
       , vr_nrdocmto
       , 2738 
       , 387.08
       , SYSDATE
       , 1
       , 1
       , 5
  );  
  
  PREj0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 8834547
                              , pr_vlrlanc => 387.08
                              , pr_dtmvtolt => TRUNC(SYSDATE)
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_dscritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;
  
  -- Coop 1 / Conta 8731560
  OPEN cr_nrdocmto(1, 8731560);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(1)||';'||
                                    to_char(TRUNC(SYSDATE), 'DD/MM/RRRR')||';'||
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
      trunc(SYSDATE)
    , 1
    , 100
    , 650009
    , 8731560
    , vr_nrdocmto
    , 2719
    , vr_nrseqdig
    , 842.89
    , 8731560
    , 'ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO'
    , TRUNC(SYSDATE)
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
         TRUNC(SYSDATE)
       , 1
       , 8731560
       , vr_nrdocmto
       , 2738 
       , 842.89
       , SYSDATE
       , 1
       , 1
       , 5
  );
  
  PREj0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 8731560
                              , pr_vlrlanc => 842.89
                              , pr_dtmvtolt => TRUNC(SYSDATE)
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_dscritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;

  COMMIT;
  
  :RESULT:= 'Sucesso';
end;
3
RESULT
0
5
pr_cdcritic
0
5
pr_dscritic
0
5
0
