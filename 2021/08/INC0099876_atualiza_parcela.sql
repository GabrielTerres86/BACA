DECLARE
  vr_saldodeved NUMBER;

  CURSOR cr_iof(pr_cdcooper craplem.cdcooper%TYPE
               ,pr_nrdconta craplem.nrdconta%TYPE
               ,pr_nrctremp craplem.nrctremp%TYPE
               ,pr_nrparepr craplem.nrparepr%TYPE) IS
    SELECT a.vllanmto
      FROM craplem a
     WHERE a.cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND nrparepr = pr_nrparepr
       AND cdhistor = 2311; -- IOF S/EMPREST 
  rw_iof cr_iof%ROWTYPE;

  CURSOR cr_multa(pr_cdcooper craplem.cdcooper%TYPE
                 ,pr_nrdconta craplem.nrdconta%TYPE
                 ,pr_nrctremp craplem.nrctremp%TYPE
                 ,pr_nrparepr craplem.nrparepr%TYPE) IS
    SELECT a.vllanmto
      FROM craplem a
     WHERE a.cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND nrparepr = pr_nrparepr
       AND cdhistor = 1047; -- MULTA
  rw_multa cr_multa%ROWTYPE;

  CURSOR cr_mora(pr_cdcooper craplem.cdcooper%TYPE
                ,pr_nrdconta craplem.nrdconta%TYPE
                ,pr_nrctremp craplem.nrctremp%TYPE
                ,pr_nrparepr craplem.nrparepr%TYPE) IS
    SELECT a.vllanmto
      FROM craplem a
     WHERE a.cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND nrparepr = pr_nrparepr
       AND cdhistor = 1077; -- JUROS DE MORA 1077
  rw_mora cr_mora%ROWTYPE;

BEGIN

  UPDATE crawepr w
     SET vlpreemp = 108.00
   WHERE cdcooper = 1
     AND nrdconta = 3236609
     AND nrctremp = 2954120;

  UPDATE crappep w
     SET vlparepr = 108.00
   WHERE cdcooper = 1
     AND nrdconta = 3236609
     AND nrctremp = 2954120;

  FOR empr IN (SELECT a.cdcooper
                     ,a.nrdconta
                     ,a.nrctremp
                     ,SUM(a.vllanmto) vllanmto
                     ,a.dtpagemp
                     ,a.nrparepr
                 FROM craplem a
                INNER JOIN craphis h
                   ON a.cdcooper = h.cdcooper
                  AND a.cdhistor = h.cdhistor
                WHERE a.cdcooper = 1
                  AND nrdconta = 3236609
                  AND nrctremp = 2954120
                  AND h.cdhistor IN (1077, 1047, 2311, 1044)
                  AND nrparepr <= 5
                GROUP BY a.cdcooper
                        ,a.nrdconta
                        ,a.nrctremp
                        ,a.dtpagemp
                        ,a.nrparepr
                ORDER BY 6) LOOP
  
    vr_saldodeved := 0;
  
    OPEN cr_iof(empr.cdcooper, empr.nrdconta, empr.nrctremp, empr.nrparepr);
    FETCH cr_iof
      INTO rw_iof;
    CLOSE cr_iof;
  
    OPEN cr_multa(empr.cdcooper, empr.nrdconta, empr.nrctremp, empr.nrparepr);
    FETCH cr_multa
      INTO rw_multa;
    CLOSE cr_multa;
  
    OPEN cr_mora(empr.cdcooper, empr.nrdconta, empr.nrctremp, empr.nrparepr);
    FETCH cr_mora
      INTO rw_mora;
    CLOSE cr_mora;
  
    IF empr.vllanmto >= 108 THEN
      UPDATE crappep
         SET vlpagpar = empr.vllanmto
            ,vlparepr = 108.00
            ,inliquid = 1
            ,dtultpag = empr.dtpagemp
            ,vlsdvpar = 0.00
            ,vlmtapar = nvl(rw_multa.vllanmto, 0)
            ,vlmrapar = nvl(rw_mora.vllanmto, 0)
            ,vlpagmta = nvl(rw_multa.vllanmto, 0)
            ,vlpagmra = nvl(rw_mora.vllanmto, 0)
            ,vlpagiof = nvl(rw_iof.vllanmto, 0)
       WHERE cdcooper = empr.cdcooper
         AND nrdconta = empr.nrdconta
         AND nrctremp = empr.nrctremp
         AND nrparepr = empr.nrparepr;
    
    ELSIF empr.nrparepr = 5 THEN
      vr_saldodeved := 108.00 - empr.vllanmto;
      UPDATE crappep
         SET vlpagpar = empr.vllanmto
            ,vlparepr = 108.00
            ,inliquid = 0
            ,dtultpag = empr.dtpagemp
            ,vlsdvpar = vr_saldodeved
            ,vlmtapar = nvl(rw_multa.vllanmto, 0)
            ,vlmrapar = nvl(rw_mora.vllanmto, 0)
            ,vlpagmta = nvl(rw_multa.vllanmto, 0)
            ,vlpagmra = nvl(rw_mora.vllanmto, 0)
            ,vlpagiof = nvl(rw_iof.vllanmto, 0)
       WHERE cdcooper = empr.cdcooper
         AND nrdconta = empr.nrdconta
         AND nrctremp = empr.nrctremp
         AND nrparepr = empr.nrparepr;
    
    END IF;
  
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
