DECLARE
  vr_cdcooper cecred.crapcop.cdcooper%TYPE := 3;
  vr_nrdctaat cecred.crapass.nrdconta%TYPE := 850004;
  vr_nrdctanv cecred.crapass.nrdconta%TYPE;
BEGIN
  SELECT b.nrdconta
    INTO vr_nrdctanv
    FROM cecred.crapass b
   WHERE b.cdcooper = vr_cdcooper
     AND b.nrcadast = vr_nrdctaat;

  UPDATE cecred.crapprm a
     SET a.dsvlrprm = vr_nrdctanv
   WHERE a.cdacesso = 'COBEMP_NRDCONTA_BNF';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
