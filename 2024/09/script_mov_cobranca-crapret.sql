BEGIN    
    DELETE crapret a
     WHERE a.cdcooper = 7 
       AND a.dtcredit > to_date('13/09/2024', 'dd/mm/yyyy');

    COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;

