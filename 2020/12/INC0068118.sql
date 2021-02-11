DECLARE

  vr_cdcritic NUMBER(3);
  vr_dscritic VARCHAR2(1000);
  vr_exc_erro EXCEPTION;
  vr_cdcooper NUMBER(2)  := 1;
  vr_nrdconta NUMBER(10) := 6658016;
  vr_nrctremp NUMBER(10) := 1986372;
  vr_dtmvtolt DATE       := to_date('16/11/2020','dd/mm/rrrr');

  BEGIN

    EMPR0001.pc_cria_lancamento_lem(
             pr_cdcooper => vr_cdcooper
            ,pr_dtmvtolt => vr_dtmvtolt
            ,pr_cdagenci => 90
            ,pr_cdbccxlt => 100
            ,pr_cdoperad => '1'
            ,pr_cdpactra => 90
            ,pr_tplotmov => 5
            ,pr_nrdolote => 600012
            ,pr_nrdconta => vr_nrdconta
            ,pr_cdhistor => 1044
            ,pr_nrctremp => vr_nrctremp
            ,pr_vllanmto => 64.56
            ,pr_dtpagemp => vr_dtmvtolt
            ,pr_txjurepr => 0.0298703
            ,pr_vlpreemp => 64.77
            ,pr_nrsequni => 9
            ,pr_nrparepr => 9
            ,pr_flgincre => true
            ,pr_flgcredi => true
            ,pr_nrseqava => 0
            ,pr_cdorigem => 3
            ,pr_cdcritic => vr_cdcritic
            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    ELSE
      UPDATE craplem l
         SET l.dthrtran = to_date('16/11/2020 14:36:16','dd/mm/yyyy hh24:mi:ss')
       WHERE l.cdcooper = vr_cdcooper
         AND l.nrdconta = vr_nrdconta
         AND l.nrctremp = vr_nrctremp
         AND l.dtmvtolt = vr_dtmvtolt
         AND l.nrdolote = 600012
         AND l.cdhistor = 1044;
    END IF;

    FOR r1 IN (SELECT l.rowid
                 FROM craplem l
                WHERE l.cdcooper = vr_cdcooper
                  AND l.nrdconta = vr_nrdconta
                  AND l.nrctremp = vr_nrctremp
             ORDER BY l.dtmvtolt,
                      l.progress_recid) LOOP
      UPDATE craplem l
         SET l.progress_recid = CRAPLEM_SEQ.NEXTVAL
       WHERE l.rowid = r1.rowid;	   
    END LOOP;

    COMMIT;
    dbms_output.put_line('Sucesso!');

  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE(vr_cdcritic || ' - ' || vr_dscritic);

    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
