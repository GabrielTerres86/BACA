BEGIN
  UPDATE cecred.craptxi t SET t.vlrdtaxa = 13.25 WHERE t.cddindex = 3 AND t.dtiniper = '09/08/2023';
  COMMIT;
END;