DECLARE

  CURSOR cr_ctr_div IS
    SELECT DISTINCT a.cdlcremp, a.cdcooper, a.nrdconta, a.nrctremp
      FROM cecred.crapepr a
     INNER JOIN cecred.tbepr_renegociacao_crapepr b
        ON a.cdcooper = b.cdcooper
           AND a.nrdconta = b.nrdconta
           AND a.nrctremp = b.nrctremp
     WHERE a.cdlcremp <> b.cdlcremp
           AND a.inliquid = 0;

  CURSOR cr_ctr_reneg(pr_cdcooper crapepr.cdcooper%TYPE
                     ,pr_nrdconta crapepr.nrdconta%TYPE
                     ,pr_nrctremp crapepr.nrctremp%TYPE) IS
    SELECT cdlcremp
      FROM cecred.tbepr_renegociacao_crapepr
     WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND nrversao = 1;
  rw_ctr_reneg cr_ctr_reneg%ROWTYPE;

BEGIN

  FOR ctr IN cr_ctr_div LOOP
  
    OPEN cr_ctr_reneg(pr_cdcooper => ctr.cdcooper
                     ,pr_nrdconta => ctr.nrdconta
                     ,pr_nrctremp => ctr.nrctremp);
    FETCH cr_ctr_reneg
      INTO rw_ctr_reneg;
    CLOSE cr_ctr_reneg;
  
    IF ctr.cdlcremp <> rw_ctr_reneg.cdlcremp THEN
    
      UPDATE cecred.crapepr
         SET cdlcremp = rw_ctr_reneg.cdlcremp
       WHERE cdcooper = ctr.cdcooper
             AND nrdconta = ctr.nrdconta
             AND nrctremp = ctr.nrctremp;
    
      UPDATE cecred.crawepr
         SET cdlcremp = rw_ctr_reneg.cdlcremp
       WHERE cdcooper = ctr.cdcooper
             AND nrdconta = ctr.nrdconta
             AND nrctremp = ctr.nrctremp;
    
    END IF;
  
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
