BEGIN
 delete craplap
 where cdcooper = 1
   and ((nrdconta = 97933740 AND nraplica =  167087) OR
        (nrdconta = 97976750 AND nraplica in (244856, 188035)))
   and dtmvtolt = to_date('24/04/2024','dd/mm/yyyy');
   
  COMMIT;
END;     