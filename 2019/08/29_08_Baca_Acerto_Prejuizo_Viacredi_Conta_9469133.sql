BEGIN
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (34621);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 1328.92
   WHERE cdcooper = 1
     AND nrdconta = 9469133;
  commit;     
END;