PL/SQL Developer Test script 3.0
166
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
  vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;
BEGIN
  :RESULT:= 'Erro';
  
  UPDATE craphis 
     SET indebprj = 1
   WHERE cdhistor = 535;
  
  -- Coop 1 / Conta 8834547
  OPEN cr_nrdocmto(1, 8834547);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(1)||';'||
                                    to_char(TRUNC(SYSDATE), 'DD/MM/RRRR')||';'||
                                    '1;100;2220');

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
    , 2220
    , 8834547
    , vr_nrdocmto
    , 535
    , vr_nrseqdig
    , 386.11
    , 8834547
    , TRUNC(SYSDATE)
    , gene0002.fn_busca_time
    , 1
    , 1
    , 5
  );

  -- Coop 1 / Conta 8834547
  OPEN cr_nrdocmto(1, 8834547);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(1)||';'||
                                    to_char(TRUNC(SYSDATE), 'DD/MM/RRRR')||';'||
                                    '1;100;2220');

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
    , 2220
    , 8834547
    , vr_nrdocmto
    , 535
    , vr_nrseqdig
    , 387.57
    , 8834547
    , TRUNC(SYSDATE)
    , gene0002.fn_busca_time
    , 1
    , 1
    , 5
  );
  
  -- Coop 1 / Conta 8731560
  OPEN cr_nrdocmto(1, 8731560);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(1)||';'||
                                    to_char(TRUNC(SYSDATE), 'DD/MM/RRRR')||';'||
                                    '1;100;2220');

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
    , 2220
    , 8731560
    , vr_nrdocmto
    , 535
    , vr_nrseqdig
    , 842.89
    , 8731560
    , TRUNC(SYSDATE)
    , gene0002.fn_busca_time
    , 1
    , 1
    , 5
  );

  COMMIT;
  
  :RESULT:= 'Sucesso';
end;
3
RESULT
1
Sucesso
5
pr_cdcritic
1
0
5
pr_dscritic
0
5
0
