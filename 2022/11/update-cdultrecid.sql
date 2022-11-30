DECLARE
BEGIN
  UPDATE cecred.tbcc_prejuizo a SET a.cdultrecid = 0 WHERE a.cdultrecid IS NULL;
  COMMIT;
END;
