PL/SQL Developer Test script 3.0
88
declare 
  CURSOR cr_nrdocmto IS 
  SELECT nvl(MAX(nrdocmto), 0) + 1
    FROM craplcm
   WHERE cdcooper = 2
     AND nrdconta = 583375
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
                                    ,pr_dsdchave => to_char(2)||';'||
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
    , 583375
    , vr_nrdocmto
    , 2719
    , vr_nrseqdig
    , 201.85
    , 583375
    , 'ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO'
    , TRUNC(SYSDATE)
    , gene0002.fn_busca_time
    , '1'
    , 2
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
       , 583375
       , vr_nrdocmto
       , 2738 
       , 201.85
       , SYSDATE
       , '1'
       , 2
       , 5
  );  

  COMMIT;
end;
0
0
