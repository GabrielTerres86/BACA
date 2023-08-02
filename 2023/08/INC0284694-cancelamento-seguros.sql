BEGIN 
  
UPDATE cecred.tbseg_prestamista 
   SET tpregist = 0
 WHERE cdcooper = 2
   AND nrdconta = 630489
   AND nrctremp = 472878
   AND nrctrseg = 326521;
   
UPDATE cecred.crapseg 
   SET cdsitseg = 2,
       dtcancel = TRUNC(sysdate),
       cdmotcan = 4
 WHERE cdcooper = 2
   AND nrdconta = 630489
   AND nrctrseg = 326521
   AND tpseguro = 4;   
   
UPDATE cecred.tbseg_prestamista 
   SET tpregist = 0
 WHERE cdcooper = 2
   AND nrdconta = 204340
   AND nrctremp = 473092
   AND nrctrseg = 328484;   
   
UPDATE cecred.crapseg 
   SET cdsitseg = 2,
       dtcancel = TRUNC(sysdate),
       cdmotcan = 4
 WHERE cdcooper = 2
   AND nrdconta = 204340
   AND nrctrseg = 328484
   AND tpseguro = 4;    
  
UPDATE cecred.tbseg_prestamista 
   SET tpregist = 0
 WHERE cdcooper = 5
   AND nrdconta = 341274
   AND nrctremp = 101017
   AND nrctrseg = 84544;
   
UPDATE cecred.tbseg_prestamista 
   SET tpregist = 0
 WHERE cdcooper = 10
   AND nrdconta = 29025
   AND nrctremp = 45148
   AND nrctrseg = 54488;
   
UPDATE cecred.tbseg_prestamista 
   SET tpregist = 0
 WHERE cdcooper = 11
   AND nrdconta = 231444
   AND nrctremp = 332745
   AND nrctrseg = 54488;
   
UPDATE cecred.tbseg_prestamista 
   SET tpregist = 0
 WHERE cdcooper = 13
   AND nrdconta = 14855160
   AND nrctremp = 274402
   AND nrctrseg = 449288;
   
UPDATE cecred.tbseg_prestamista 
   SET tpregist = 0
 WHERE cdcooper = 13
   AND nrdconta = 139505
   AND nrctremp = 275676
   AND nrctrseg = 451283;
   
UPDATE cecred.tbseg_prestamista 
   SET tpregist = 0
 WHERE cdcooper = 13
   AND nrdconta = 92428
   AND nrctremp = 210823
   AND nrctrseg = 407367;
   
COMMIT;
END;   
                    
