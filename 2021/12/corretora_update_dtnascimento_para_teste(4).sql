BEGIN
  UPDATE crapass c
     SET c.dtnasctl = TO_DATE('01/01/1945','DD/MM/RRRR')
   WHERE c.cdcooper = 1
     AND c.nrdconta =  11931205;
     
  UPDATE tbseg_prestamista c
     SET c.dtnasctl = TO_DATE('01/01/1945','DD/MM/RRRR')
   WHERE c.cdcooper = 1
     AND c.nrdconta =  11931205;     
  COMMIT;
END;
/
