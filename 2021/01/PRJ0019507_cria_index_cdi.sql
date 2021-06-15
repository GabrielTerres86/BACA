declare
  vr_cdcooper       crapepr.cdcooper%TYPE := 13; -- Civia
--
  CURSOR cr_craptxi IS
    SELECT  max(dtiniper)   dtiniper
    FROM    craptxi
    WHERE cddindex = 1;
--
  rw_crapdat        btch0001.cr_crapdat%ROWTYPE;
BEGIN
  OPEN  btch0001.cr_crapdat(vr_cdcooper);
  FETCH  btch0001.cr_crapdat
  INTO   rw_crapdat;
  CLOSE btch0001.cr_crapdat;
--
  FOR rw_craptxi IN cr_craptxi LOOP
    FOR i in 1..(rw_crapdat.dtmvtolt - rw_craptxi.dtiniper + 30) LOOP
      BEGIN
        INSERT INTO craptxi SELECT  cddindex, dtiniper + i, dtfimper + i, vlrdtaxa, dtcadast + i, NULL
                            FROM    craptxi
                            WHERE cddindex = 1
                            AND   dtiniper = rw_craptxi.dtiniper;
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
