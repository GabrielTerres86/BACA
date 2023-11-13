BEGIN
  
  UPDATE cecred.crapsld a
  SET a.dtrefere = to_date('12/11/2023','dd/mm/yyyy')
  where A.CDCOOPER = 6;

 COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
