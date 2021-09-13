BEGIN
  
  DELETE crapvri s
   WHERE s.cdcooper = 8
     AND s.dtrefere > to_date('09/08/2021', 'DD/MM/RRRR');
  
  COMMIT;
     
END;  
