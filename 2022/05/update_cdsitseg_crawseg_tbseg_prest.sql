BEGIN
 
update crapseg p set p.cdsitseg = 2, dtcancel = to_date('19/05/2022','dd/mm/yyyy') where nrdconta = 579408 and nrctrseg = 332431 and cdcooper = 13;
update crapseg p set p.cdsitseg = 5, dtcancel = to_date('19/05/2022','dd/mm/yyyy') where nrdconta = 641642 and nrctrseg = 332444 and cdcooper = 13;

update tbseg_prestamista p set p.tpregist = 2 where nrdconta = 579408 and nrctrseg = 332431 and cdcooper = 13;
update tbseg_prestamista p set p.tpregist = 2 where nrdconta = 641642 and nrctrseg = 332444 and cdcooper = 13;
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/