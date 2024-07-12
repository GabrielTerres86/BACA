BEGIN
  UPDATE cecred.craptxi a SET a.vlrdtaxa = 10.50 WHERE a.CDDINDEX = 3 AND a.dtiniper = to_date('01/07/2024', 'DD/MM/YYYY');
  COMMIT;
END;
