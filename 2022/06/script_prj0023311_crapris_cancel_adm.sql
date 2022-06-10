BEGIN
 
DELETE crapris a
WHERE a.cdcooper =16
AND a.cdmodali IN (901,902,903)
AND a.nrctremp = 427288
AND a.dtrefere = to_date('31/05/2022', 'dd-mm-yyyy');
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
