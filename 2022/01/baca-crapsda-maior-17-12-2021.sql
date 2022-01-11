BEGIN

  DELETE FROM crapsda a
   WHERE a.dtmvtolt >= to_date('17/12/2021', 'dd/mm/yyyy')
     AND cdcooper = 1;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
