BEGIN
   
 delete from cecred.craplcm
  where cdcooper = 1
    and nrdconta = 8900876
    and dtmvtolt = to_date('30/09/2024','dd/mm/yyyy')
    and cdhistor = 2680
    and nrdocmto in (3365,3384,3386);


  COMMIT;

END;
/