
BEGIN
  UPDATE crapcre c SET c.dtmvtolt = trunc(SYSDATE-1) WHERE c.rowid IN ('AAAljBAABAAOfL4AAU');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'AAAljBAABAAOfL4AAU');
    RAISE;
END;
