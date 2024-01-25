BEGIN 
  
UPDATE cecred.crapseg 
   SET cdsitseg = 5
 WHERE cdcooper = 16 
   AND nrdconta = 97077240
   AND nrctrseg = 441817;
   
UPDATE cecred.tbseg_prestamista 
   SET tpregist = 0
 WHERE cdcooper = 16 
   AND nrdconta = 97077240 
   AND nrctrseg = 441817;
   
COMMIT;
END;      