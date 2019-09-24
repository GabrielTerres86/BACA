BEGIN
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (34275);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 530.00
   WHERE cdcooper = 16
     AND nrdconta = 220361;
  commit;     
END;