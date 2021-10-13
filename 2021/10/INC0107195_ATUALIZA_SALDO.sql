BEGIN
  
  -- Atualizar os registros da CRAPSDA com o valor não contabilizado em 15/09/2021
  UPDATE crapsda t
     SET t.vlsddisp = t.vlsddisp + 30004.71
   WHERE t.cdcooper = 13
     AND t.nrdconta = 500100
     AND t.dtmvtolt BETWEEN to_date('15/09/2021','dd/mm/yyyy') AND TRUNC(SYSDATE);

  -- Atualizar os registros da CRAPSDA com o valor não contabilizado em 15/09/2021
  UPDATE crapsld t
     SET t.vlsddisp = t.vlsddisp + 30004.71
   WHERE t.cdcooper = 13
     AND t.nrdconta = 500100
     AND t.dtrefere BETWEEN to_date('15/09/2021','dd/mm/yyyy') AND TRUNC(SYSDATE);
  
  COMMIT;
  
END;
