BEGIN
  
  -- Atualizar os registros da CRAPSDA com o valor não contabilizado em 06/04/2021
  UPDATE crapsda t
     SET t.vlsddisp = t.vlsddisp + 407
   WHERE t.cdcooper = 1
     AND t.nrdconta = 80276180
     AND t.dtmvtolt BETWEEN '06/04/2021' AND TRUNC(SYSDATE);

  -- Atualizar os registros da CRAPSDA com o valor não contabilizado em 07/05/2021
  UPDATE crapsda t
     SET t.vlsddisp = t.vlsddisp + 407
   WHERE t.cdcooper = 1
     AND t.nrdconta = 80276180
     AND t.dtmvtolt BETWEEN '07/05/2021' AND TRUNC(SYSDATE);
  
  COMMIT;
  
END;
