BEGIN
    
  BEGIN 
    UPDATE cecred.crapsda t
       SET t.vlsdbloq = ((NVL(t.vlsdbloq,0) - 45000000) + 45000)
     WHERE t.cdcooper = 7
       AND t.nrdconta = 163384
       AND t.dtmvtolt = to_date('17/01/2024','dd/mm/yyyy');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'Erro ao alterar CRAPSDA: '||SQLERRM);
  END;
    
  BEGIN 
    UPDATE cecred.crapsld t
       SET t.vlsdbloq = ((NVL(t.vlsdbloq,0) - 45000000) + 45000)
     WHERE t.cdcooper = 7
       AND t.nrdconta = 163384;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20002,'Erro ao alterar CRAPSLD: '||SQLERRM);
  END;

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
