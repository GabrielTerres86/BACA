BEGIN
  UPDATE craplcm a
     SET a.dtmvtolt = to_date('07/02/2022', 'dd/mm/rrrr')
   WHERE a.progress_recid = 1352347040;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
