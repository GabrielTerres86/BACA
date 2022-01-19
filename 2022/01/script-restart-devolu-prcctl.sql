/***
São scripts para gerar novamente a DEVOLU Diurno 
**/
BEGIN
  
  delete crapsol;

  update crapdev
  set insitdev = 0
  where /* cdcooper <> 1
  and */ insitdev = 1;

  delete craplcm where nrdolote = 10117 and dtmvtolt = to_date('28/12/2021','dd/mm/yyyy');     
  
  COMMIT; 
  
END;
