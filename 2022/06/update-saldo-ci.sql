BEGIN
  UPDATE cecred.crapsli
     SET vlsddisp = 278843.18
   WHERE cdcooper = 1 
     AND nrdconta = 6301282 
     AND dtrefere = to_date('30/06/2022','dd/mm/yyyy');
     
   COMMIT;
END;
