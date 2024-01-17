BEGIN
    
  BEGIN 
    UPDATE cecred.crapdpb t
       SET t.vllanmto = 45000
     WHERE t.cdcooper = 7
       AND t.dtmvtolt = to_date('17/01/2024','dd/mm/yyyy')
       AND t.nrdconta = 163384
       AND t.nrdocmto = 595481;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20003,'Erro ao alterar CRAPDPB: '||SQLERRM);
  END;
  
  BEGIN
    UPDATE cecred.craplcm t 
       SET t.vllanmto = 45000
     WHERE t.cdcooper = 7 
       AND t.dtmvtolt = to_date('17/01/2024','dd/mm/yyyy')
       AND t.nrdconta = 163384
       AND t.nrdocmto = 595481
       AND t.nrdolote = 4500
       AND t.vllanmto = 45000000;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20004,'Erro ao alterar CRAPLCM: '||SQLERRM);
  END;
  
  COMMIT;
END;
