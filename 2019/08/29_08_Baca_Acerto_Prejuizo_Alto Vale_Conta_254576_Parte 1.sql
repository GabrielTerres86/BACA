BEGIN
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (34812);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 970.67
   WHERE cdcooper = 16
     AND nrdconta = 254576;
  commit;     
END;