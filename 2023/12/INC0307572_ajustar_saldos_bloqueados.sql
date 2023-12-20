DECLARE

  CURSOR cr_craplcm IS
    SELECT t.cdcooper
         , t.nrdconta
         , t.vllanmto 
      FROM craplcm t 
     WHERE cdcooper <> 3 
       AND dtmvtolt = to_date('18/12/2023','dd/mm/yyyy')
       AND cdhistor = 2433;

BEGIN
  
  FOR reg IN cr_craplcm LOOP
    
    BEGIN 
      UPDATE crapsda t
         SET t.vlsdbloq = NVL(t.vlsdbloq,0) - NVL(reg.vllanmto,0)
           , t.vlsddisp = t.vlsddisp + NVL(reg.vllanmto,0)
       WHERE t.cdcooper = reg.cdcooper
         AND t.nrdconta = reg.nrdconta
         AND t.dtmvtolt = to_date('19/12/2023','dd/mm/yyyy');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001,'Erro ao alterar CRAPSDA: '||SQLERRM);
    END;
    
    BEGIN 
      UPDATE crapsld t
         SET t.vlsdbloq = NVL(t.vlsdbloq,0) - NVL(reg.vllanmto,0)
           , t.vlsddisp = t.vlsddisp + NVL(reg.vllanmto,0)
       WHERE t.cdcooper = reg.cdcooper
         AND t.nrdconta = reg.nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao alterar CRAPSLD: '||SQLERRM);
    END;

  END LOOP;
  
END;
