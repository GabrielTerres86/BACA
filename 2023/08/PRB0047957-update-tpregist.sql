BEGIN
  
UPDATE CECRED.tbseg_prestamista
   SET tpregist = 0
 WHERE cdcooper = 12
   AND nrdconta = 120561
   AND nrproposta IN ('770657810193','770657810207');

DELETE FROM CECRED.tbseg_prestamista 
 WHERE cdcooper = 16 
   AND nrdconta = 462233 
   AND nrctrseg = 79755 
   AND nrctremp = 103352;

UPDATE CECRED.crapseg
   SET cdsitseg = 2
 WHERE cdcooper = 16
   AND nrdconta = 462233
   AND nrctrseg = 234472
   AND tpseguro = 4;   

COMMIT;
END;
