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
   
update cecred.tbseg_prestamista b set b.VLPRODUT = 60.32 where b.NRPROPOSTA = '202308752196' and b.CDCOOPER =  2 and b.nrdconta = 584290;
update cecred.crawseg s           set s.vlpremio = 60.32 where s.nrdconta   = 584290         and s.CDCOOPER =  2 and s.NRCTRSEG = 324020  and s.NRPROPOSTA = '202308752196';
update cecred.crapseg s           set s.vlpremio = 60.32 where s.nrdconta   = 584290         and s.CDCOOPER =  2 and s.NRCTRSEG = 324020;

 

update cecred.tbseg_prestamista b set b.VLPRODUT = 987.37 where b.NRPROPOSTA = '202309897247' and b.CDCOOPER =  8 and b.nrdconta = 10278;
update cecred.crawseg s           set s.vlpremio = 987.37 where s.nrdconta   = 10278          and s.CDCOOPER =  8 and s.NRCTRSEG = 23450  and s.NRPROPOSTA = '202309897247';
update cecred.crapseg s           set s.vlpremio = 987.37 where s.nrdconta   = 10278          and s.CDCOOPER =  8 and s.NRCTRSEG = 23450;

 

update cecred.tbseg_prestamista b set b.VLPRODUT = 467.84 where b.NRPROPOSTA = '202309027071' and b.CDCOOPER =  14 and b.nrdconta = 83810;
update cecred.crawseg s           set s.vlpremio = 467.84 where s.nrdconta   = 83810          and s.CDCOOPER =  14 and s.NRCTRSEG = 23450  and s.NRPROPOSTA = '202309027071';
update cecred.crapseg s           set s.vlpremio = 467.84 where s.nrdconta   = 83810          and s.CDCOOPER =  14 and s.NRCTRSEG = 23450;   
   
COMMIT;

END;   
                    
