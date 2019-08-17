begin
    
-- Conta 7203985
  DELETE from TBCC_PREJUIZO_DETALHE t 
  where t.cdcooper = 1 and t.nrdconta = 7203985 and t.cdhistor = 2408 and t.vllanmto = 9.90 and t.dtmvtolt = '12/07/2019';

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - (9.90)
   WHERE cdcooper = 1
     AND nrdconta = 7203985;

-- Conta 8056021     
  DELETE from TBCC_PREJUIZO_DETALHE t 
  where t.cdcooper = 1 and t.nrdconta = 8056021 and t.cdhistor = 2408 and t.vllanmto = 9.90 and t.dtmvtolt = '12/07/2019';

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - (9.90)
   WHERE cdcooper = 1
     AND nrdconta = 8056021;

-- Conta 8760250   
  DELETE from TBCC_PREJUIZO_DETALHE t 
  where t.cdcooper = 1 and t.nrdconta = 8760250 and t.cdhistor = 2408 and t.vllanmto = 9.90 and t.dtmvtolt = '12/07/2019';
  
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - (9.90)
   WHERE cdcooper = 1
     AND nrdconta = 8760250;

-- Conta 8811539 
  DELETE from TBCC_PREJUIZO_DETALHE t 
  where t.cdcooper = 1 and t.nrdconta = 8811539 and t.cdhistor = 2408 and t.vllanmto = 119.90 and t.dtmvtolt = '12/07/2019';
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - (119.90)
   WHERE cdcooper = 1
     AND nrdconta = 8811539;

-- Conta 8834857 
  DELETE from TBCC_PREJUIZO_DETALHE t 
  where t.cdcooper = 1 and t.nrdconta = 8834857 and t.cdhistor = 2408 and t.vllanmto = 700.00 and t.dtmvtolt = '12/07/2019';
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - (700.00)
   WHERE cdcooper = 1
     AND nrdconta = 8834857;

  COMMIT;
end;