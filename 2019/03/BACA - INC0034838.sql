BEGIN
 UPDATE crapcrl 
   SET crapcrl.nrdconta = 0,
       crapcrl.nmrespon = 'Carmelita Schmitz',
       crapcrl.nrcpfcgc =  14375432942,
       crapcrl.nridenti =  92675289
 WHERE crapcrl.cdcooper = 1 
   AND crapcrl.nrctamen = 6298990;
  IF SQL%ROWCOUNT = 1 THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
  