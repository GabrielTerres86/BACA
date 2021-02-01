declare
  vr_cdcooper       crapepr.cdcooper%TYPE := 13; -- Civia
--
  CURSOR cr_crapmfx IS
    SELECT  tpmoefix
           ,max(dtmvtolt)   dtmvtolt
    FROM    crapmfx
    WHERE tpmoefix in (6,8,20)
    AND    cdcooper = vr_cdcooper
    GROUP BY tpmoefix
    ORDER BY tpmoefix;
--
  rw_crapdat        btch0001.cr_crapdat%ROWTYPE;
BEGIN
  OPEN  btch0001.cr_crapdat(vr_cdcooper);
  FETCH  btch0001.cr_crapdat
  INTO   rw_crapdat;
  CLOSE btch0001.cr_crapdat;
--
  FOR rw_crapmfx IN cr_crapmfx LOOP
    FOR i in 1..(rw_crapdat.dtmvtolt - rw_crapmfx.dtmvtolt + 30) LOOP
      BEGIN
        INSERT INTO crapmfx SELECT  dtmvtolt + i, tpmoefix, vlmoefix, cdcooper, NULL
                            FROM    crapmfx
                            WHERE tpmoefix = rw_crapmfx.tpmoefix
                            AND   cdcooper = vr_cdcooper
                            AND   dtmvtolt = rw_crapmfx.dtmvtolt;
      EXCEPTION
        WHEN others THEN
          NULL;
      END;
    END LOOP;
  END LOOP;
--
  COMMIT;
END;
/
