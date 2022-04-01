BEGIN
  UPDATE crapcyb a
     SET a.dtmvtolt = to_date('01/04/2022', 'dd/mm/rrrr')
   WHERE a.cdorigem = 6
     AND a.dtmvtolt = to_date('31/03/2022', 'dd/mm/rrrr')
     AND a.dtdbaixa IS NULL;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
