BEGIN
  UPDATE crapass c
     SET c.dtnasctl = '01/01/1930'
   WHERE c.cdcooper = 1
     AND c.nrdconta =  11931205;
     
  UPDATE tbseg_prestamista c
     SET c.dtnasctl = '01/01/1945'
   WHERE c.cdcooper = 1
     AND c.nrdconta =  11931205;     
COMMIT;
END;
/
