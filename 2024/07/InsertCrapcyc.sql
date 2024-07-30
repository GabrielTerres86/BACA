BEGIN
  UPDATE cecred.crapcyb a
     SET a.nrctremp = 99662957
   WHERE a.cdcooper = 14
     AND a.nrdconta = 99662957
     AND a.cdorigem = 1
     AND a.nrctremp = 336980;
  COMMIT;
END;
