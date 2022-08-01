BEGIN
 
update crapseg p set p.cdsitseg = 2, dtcancel = to_date('18/05/2022','dd/mm/yyyy') where nrdconta = 291692 and nrctrseg = 252402 and cdcooper = 16;

update tbseg_prestamista p set p.tpregist = 2 where nrdconta = 291692 and nrctrseg = 252402 and cdcooper = 16;

    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/