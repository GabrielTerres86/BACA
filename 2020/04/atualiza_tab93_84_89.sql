DECLARE
  CURSOR cr_crapcop IS
    SELECT *
      FROM crapcop
     WHERE cdcooper > 0;
     
  type tpregist IS VARRAY(2) OF INTEGER;
  tpregistros tpregist := tpregist(84, 89);
  
  vr_sql VARCHAR(2000);
BEGIN
  FOR rw_crapcop IN cr_crapcop LOOP
    FOR x IN 1..tpregistros.count LOOP
      vr_sql := 'UPDATE CRAPTAB
                    SET DSTEXTAB = DSTEXTAB || '';N''
                  WHERE CRAPTAB.NMSISTEM = ''CRED''
                    AND CRAPTAB.TPTABELA = ''GENERI''
                    AND CRAPTAB.CDEMPRES = 0
                    AND CRAPTAB.CDACESSO = ''DIGITALIZA''
                    AND CRAPTAB.CDCOOPER = '||rw_crapcop.cdcooper||'
                    AND CRAPTAB.TPREGIST = '||tpregistros(x);
      EXECUTE IMMEDIATE vr_sql;
      COMMIT;
    END LOOP;
  END LOOP;  
END;
