BEGIN
 
DELETE crapmfx a
WHERE a.cdcooper = 16
AND a.dtmvtolt >= to_date('01/07/2022','dd/mm/yyyy');
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
