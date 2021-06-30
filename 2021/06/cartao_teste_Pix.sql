BEGIN
  UPDATE crapcrd
     SET crapcrd.cdcooper = 16
        ,crapcrd.nrdconta = 785172
        ,crapcrd.nrcpftit = 81977760910
        ,crapcrd.cdadmcrd = 15
   WHERE crapcrd.nrcrcard = 5127070320149719;
 

  UPDATE crawcrd
     SET crawcrd.cdcooper = 16
        ,crawcrd.nrdconta = 785172
        ,crawcrd.nrcpftit = 81977760910
        ,crawcrd.cdadmcrd = 15
   WHERE crawcrd.nrcrcard = 5127070320149719;
 
   COMMIT;
END;