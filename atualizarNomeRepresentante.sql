BEGIN
  UPDATE crapcrl t 
     SET t.nmrespon = 'ANALU CASTRO TESTE REPRESENTANTE'
   WHERE t.nrcpfcgc = 2967789070;
 
  COMMIT;
  
END;
