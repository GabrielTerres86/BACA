BEGIN
 
     DELETE crapcyb a
     WHERE a.cdcooper = 16
     AND a.dtmvtolt = '30/03/2022';
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
