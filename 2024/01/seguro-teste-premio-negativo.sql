BEGIN 
  
UPDATE cecred.crapseg 
   SET cdsitseg = 5
 WHERE cdcooper = 16 
   AND nrdconta = 99419238
   AND nrctrseg = 441811;
   
UPDATE cecred.tbseg_prestamista 
   SET tpregist = 0
 WHERE cdcooper = 16 
   AND nrdconta = 99419238 
   AND nrctrseg = 441811;
   
COMMIT;
END;      