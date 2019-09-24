BEGIN
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (34813);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 740.49
   WHERE cdcooper = 16
     AND nrdconta = 345245;
  commit;     
END;