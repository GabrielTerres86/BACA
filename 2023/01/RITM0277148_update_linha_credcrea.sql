BEGIN
   UPDATE cecred.craplcr 
      SET dsoperac = 'FINANCIAMENTO' 
    WHERE cdlcremp IN (60202, 60204) 
      AND cdcooper =  7;
  
  COMMIT;
END;

