DECLARE
  --
  CURSOR cr_lanc IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,lem.dtmvtolt
      FROM craplem lem
          ,crapepr epr
     WHERE epr.cdcooper = lem.cdcooper
       AND epr.nrdconta = lem.nrdconta
       AND epr.nrctremp = lem.nrctremp
       AND epr.tpemprst = 2
       AND epr.inprejuz = 1
       AND lem.cdhistor = 2409
       AND lem.dtmvtolt = (SELECT MAX(lem2.dtmvtolt)
                             FROM craplem lem2
                            WHERE lem2.cdcooper = epr.cdcooper
                              AND lem2.nrdconta = epr.nrdconta
                              AND lem2.nrctremp = epr.nrctremp
                              AND lem2.cdhistor = 2409);
  --
  rw_lanc cr_lanc%ROWTYPE;
  --
BEGIN
  --
  OPEN cr_lanc;
  --
  LOOP
    --
    FETCH cr_lanc INTO rw_lanc;
    EXIT WHEN cr_lanc%NOTFOUND;
    --
    BEGIN
      --
      UPDATE crapepr epr
         SET epr.diarefju = to_char(rw_lanc.dtmvtolt, 'DD')
            ,epr.mesrefju = to_char(rw_lanc.dtmvtolt, 'MM')
            ,epr.anorefju = to_char(rw_lanc.dtmvtolt, 'YYYY')
       WHERE epr.cdcooper = rw_lanc.cdcooper
         AND epr.nrdconta = rw_lanc.nrdconta
         AND epr.nrctremp = rw_lanc.nrctremp;
      --
    END;
    --
  END LOOP;
  --
  CLOSE cr_lanc;
  --
  COMMIT;
  --
END;
