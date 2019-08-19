PL/SQL Developer Test script 3.0
89
-- Created on 19/02/2019 by T0031667 
declare 
  CURSOR cr_nrdocmto IS 
  SELECT nvl(MAX(nrdocmto), 0) + 1
    FROM craplcm
   WHERE cdcooper = 11
     AND nrdconta = 389447
     AND dtmvtolt = TRUNC(SYSDATE)
  ;
  
  vr_nrseqdig craplcm.nrseqdig%TYPE;
  vr_nrdocmto craplcm.nrdocmto%TYPE;
BEGIN
  OPEN cr_nrdocmto;
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(11)||';'||
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
    , 389447
    , vr_nrdocmto
    , 2719
    , vr_nrseqdig
    , 900.00
    , 389447
    , 'ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO'
    , TRUNC(SYSDATE)
    , gene0002.fn_busca_time
    , 1
    , 11
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
       , 389447
       , vr_nrdocmto
       , 2738 
       , 900.00
       , SYSDATE
       , 1
       , 11
       , 5
  );  

  COMMIT;
end;
0
0
