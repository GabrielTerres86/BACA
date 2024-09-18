DECLARE
  CURSOR cr_crapthi(pd_cdcooper IN NUMBER) IS
    SELECT *
      FROM crapthi
     WHERE crapthi.cdhistor = 4561
       AND crapthi.cdcooper = pd_cdcooper;
  rw_crapthi cr_crapthi%ROWTYPE;

  CURSOR cr_craphis(pd_cdcooper IN NUMBER) IS
    SELECT *
      FROM craphis
     WHERE craphis.cdhistor = 4561
       AND craphis.cdcooper = pd_cdcooper;
  rw_craphis cr_craphis%ROWTYPE;
BEGIN
  FOR i IN (SELECT cdcooper
              FROM crapcop) LOOP
    OPEN cr_crapthi(i.cdcooper);
    FETCH cr_crapthi
      INTO rw_crapthi;
  
    IF cr_crapthi%FOUND THEN
      rw_crapthi.cdhistor       := 4593;
      rw_crapthi.progress_recid := rw_crapthi.progress_recid + 1000000;
    INSERT INTO crapthi VALUES rw_crapthi;
    END IF;
    CLOSE cr_crapthi;
    
    OPEN cr_craphis(i.cdcooper);
    FETCH cr_craphis
      INTO rw_craphis;
  
    IF cr_craphis%FOUND THEN
      rw_craphis.cdhistor       := 4593;
      rw_craphis.progress_recid := rw_craphis.progress_recid + 1000000;
    INSERT INTO craphis VALUES rw_craphis;
    END IF;
    CLOSE cr_craphis;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO ' || SQLERRM);
    ROLLBACK;
END;
