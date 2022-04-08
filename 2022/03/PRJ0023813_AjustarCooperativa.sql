BEGIN
  DELETE FROM crapsda a
   WHERE a.cdcooper = 14
     AND a.dtmvtolt > to_date('09/02/2022', 'dd/mm/rrrr');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
