BEGIN 
  UPDATE gncontr ntr 
     SET ntr.cdsitret = 2 
   WHERE ntr.cdsitret = 1 
     AND ntr.dtmvtolt = '15/02/2022';    
  COMMIT;
END;
