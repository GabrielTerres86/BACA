BEGIN
 
update crapseg p set p.cdsitseg = 2 where nrdconta = 3502813 and nrctrseg = 1034200 and cdcooper = 1;
update crapseg p set p.cdsitseg = 2 where nrdconta = 726230 and nrctrseg = 195944 and cdcooper = 16;
update crapseg p set p.cdsitseg = 5 where nrdconta = 726230 and nrctrseg = 195948 and cdcooper = 16;

update tbseg_prestamista p set p.tpregist = 2 where nrdconta = 3502813 and nrctrseg = 1034200 and cdcooper = 1;
update tbseg_prestamista p set p.tpregist = 2 where nrdconta = 726230 and nrctrseg = 195944 and cdcooper = 16;
update tbseg_prestamista p set p.tpregist = 2 where nrdconta = 726230 and nrctrseg = 195948 and cdcooper = 16;
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/