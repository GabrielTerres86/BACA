BEGIN
  update crapsda
     set vlsddisp = 2000000
   where cdcooper = 1
     and nrdconta = 834300
     and dtmvtolt = to_date('30/06/2022','dd/mm/yyyy');
  COMMIT;
END;        