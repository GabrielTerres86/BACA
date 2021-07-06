BEGIN
  -- INC0093063 - remover 2 registros de R$160,48 lançados no dia: 02/06/2021 
  DELETE FROM craplem lem
   WHERE lem.cdcooper = 16
     AND lem.nrdconta = 350052
     AND lem.nrctremp = 132801
     AND lem.dtmvtolt = to_date('02/06/2021')
     AND lem.vllanmto = 160.48;

  COMMIT;
END;