BEGIN
  UPDATE cecred.crapcyc a
     SET a.flextjud = 1
   WHERE a.cdcooper = 1
     AND a.cdorigem = 1
     AND a.nrdconta = 99139553;
  COMMIT;
END;
