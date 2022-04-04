BEGIN
 
     DELETE crapcyb a
     WHERE a.cdcooper = 16
     AND a.dtmvtolt = to_date('30/03/2022','dd/mm/yyyy');
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
