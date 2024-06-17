BEGIN
  
  DELETE cecred.craplgm t 
   WHERE t.cdcooper = 12
     AND t.nrdconta IN (99896184 
                       ,99887118 
                       ,99873389)
     AND t.dttransa < to_date('11/06/2024','dd/mm/yyyy');

  DELETE cecred.craplgi t 
   WHERE t.cdcooper = 12
     AND t.nrdconta IN (99896184 
                       ,99887118 
                       ,99873389)
     AND t.dttransa < to_date('11/06/2024','dd/mm/yyyy');

  DELETE cecred.craplgm_hst t 
   WHERE t.cdcooper = 12
     AND t.nrdconta IN (99896184 
                       ,99887118 
                       ,99873389)
     AND t.dttransa >= to_date('11/06/2024','dd/mm/yyyy');

  DELETE cecred.craplgi_hst t 
   WHERE t.cdcooper = 12
     AND t.nrdconta IN (99896184 
                       ,99887118 
                       ,99873389)
     AND t.dttransa >= to_date('11/06/2024','dd/mm/yyyy');
  
  COMMIT;
  
END;
