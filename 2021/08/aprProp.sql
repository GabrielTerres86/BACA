BEGIN
  UPDATE crawepr l 
     SET l.insitapr = 1
        ,l.insitest = 3 
   WHERE l.cdcooper = 2
     AND l.nrdconta = 807664
     AND l.nrctremp = 316622;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
