BEGIN
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (35044,35036,35029,35039);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - (274.16 + 274.16 + 274.16 + 274.16)
   WHERE cdcooper = 1
     AND nrdconta = 7409389;
  commit;     
END;