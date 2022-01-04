DECLARE
BEGIN
  UPDATE crapsld d
     SET d.vlsdbloq = -50
   WHERE d.cdcooper = 11
     AND d.nrdconta = 416371;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
