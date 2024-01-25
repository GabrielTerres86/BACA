BEGIN 
  
UPDATE cecred.crapseg 
   SET cdsitseg = 5
 WHERE cdcooper = 16 
   AND nrdconta = 82524815
   AND nrctrseg = 441835;
   
UPDATE cecred.tbseg_prestamista 
   SET tpregist = 0
 WHERE cdcooper = 16 
   AND nrdconta = 82524815 
   AND nrctrseg = 441835;
   
COMMIT;
END;      