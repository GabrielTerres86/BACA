DECLARE
  CURSOR cr_crapthi(pd_cdcooper IN NUMBER) IS
    SELECT *
      FROM crapthi
     WHERE crapthi.cdhistor = 4561
       AND crapthi.cdcooper = pd_cdcooper;
  rw_crapthi cr_crapthi%ROWTYPE;

BEGIN
  FOR i IN (SELECT cdcooper
              FROM crapcop) LOOP
    OPEN cr_crapthi(i.cdcooper);
    FETCH cr_crapthi
      INTO rw_crapthi;
  
    IF cr_crapthi%FOUND THEN
      rw_crapthi.cdhistor       := 4572;
      rw_crapthi.progress_recid := rw_crapthi.progress_recid + 100000;
    INSERT INTO crapthi VALUES rw_crapthi;
    END IF;
    CLOSE cr_crapthi;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO ' || SQLERRM);
    ROLLBACK;
END;
