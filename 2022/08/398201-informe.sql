BEGIN

  DELETE crapdir 
   WHERE cdcooper = 6
     AND nrdconta in (20010,14651114,117722,112887)
     AND dtmvtolt = to_date('31/12/2021','dd/mm/yyyy'); 

  UPDATE crapdir
     SET dtmvtolt = '31/12/2021'  
   WHERE cdcooper = 6
     AND nrdconta in (20010,14651114,117722,112887)
     AND dtmvtolt = to_date('30/12/2022','dd/mm/yyyy');

  UPDATE CONTABILIDADE.TBCONTAB_DIR_SALDO  a
     SET a.dtmvtolt = add_months(a.dtmvtolt,-12)
   WHERE cdcooper = 6
     AND nrdconta in (20010,14651114,117722,112887);
	 
	 COMMIT;

END;
