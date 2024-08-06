
BEGIN
  UPDATE crapcre c SET c.dtmvtolt = trunc(SYSDATE) WHERE c.rowid IN ('AAAljBAABAAOfL4AAS');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'AAAljBAABAAOfL4AAS');
    RAISE;
END;
