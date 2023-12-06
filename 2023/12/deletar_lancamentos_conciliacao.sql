BEGIN
 
  DELETE FROM craplcm
   WHERE cdcooper = 3  
     AND nrdconta = 99999862  
     AND dtmvtolt = to_date('05/12/2023', 'dd/mm/yyyy')  
     AND nrdocmto > 21950;
    COMMIT;
 
END;