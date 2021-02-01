BEGIN
  
  UPDATE crappro p
     SET p.dsinform##2 = REPLACE(p.dsinform##2, '´',NULL)
   WHERE p.cdcooper = 13
     AND p.nrdconta = 198021
     AND p.dsprotoc = '2903.1F10.0D04.0115.3624.4653';
     
  COMMIT;

END;
