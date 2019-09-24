BEGIN
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (34959,34960,35030,35031,35037,35038,35040,35041,35042,35043);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - (877.01+515.99+877.01+515.99+877.01+515.99+877.01+515.99+877.01+515.99)
   WHERE cdcooper = 1
     AND nrdconta = 3601285;
  commit;     
END;