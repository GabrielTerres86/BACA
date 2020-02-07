BEGIN
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (34620);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 1603.35
   WHERE cdcooper = 1
     AND nrdconta = 1386603;
  commit;     
END;