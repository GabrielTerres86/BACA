DECLARE
BEGIN
  UPDATE crapsda d
     SET d.vlsdbloq = -50
   WHERE d.cdcooper = 11
     AND d.nrdconta = 416371
     AND d.dtmvtolt > to_date('15/12/2021', 'dd/mm/yyyy');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
