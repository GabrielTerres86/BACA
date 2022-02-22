BEGIN 
  UPDATE gncontr ntr 
     SET ntr.cdsitret = 2 
   WHERE ntr.cdsitret = 1 
     AND ntr.dtmvtolt = TO_DATE('15/02/2022', 'DD/MM/YYYY');  
  COMMIT;
END;
