BEGIN
  
  UPDATE cecred.crapsli
     SET vlsddisp = 16557.59
   WHERE cdcooper = 1
     AND nrdconta = 3663949
     AND dtrefere = to_date('31-07-2022', 'dd-mm-yyyy');

  COMMIT;
END;
