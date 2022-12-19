DECLARE

  TYPE typ_reg_crappep IS RECORD(cdcooper  cecred.crappep.cdcooper%TYPE,
                                 nrdconta  cecred.crappep.nrdconta%TYPE,
                                 nrctremp  cecred.crappep.nrctremp%TYPE,
                                 nrparepr  cecred.crappep.nrparepr%TYPE,
                                 vlsdvpar  cecred.crappep.vlsdvpar%TYPE);
  TYPE typ_tab_crappep IS TABLE OF typ_reg_crappep INDEX BY PLS_INTEGER;
  vr_tab_crappep typ_tab_crappep;
  
  CURSOR cr_crappep IS
    SELECT pep.cdcooper,
           pep.nrdconta,
           pep.nrctremp,
           pep.nrparepr,
           (pep.vlparepr - pep.vlpagpar) vlsdvpar
      FROM cecred.crapepr epr,
           cecred.crappep pep
     WHERE pep.cdcooper = epr.cdcooper
       AND pep.nrdconta = epr.nrdconta
       AND pep.nrctremp = epr.nrctremp
       AND epr.tpemprst = 1
       AND epr.tpdescto = 2
       AND epr.inliquid = 0
       AND pep.inliquid = 0
       AND pep.vlsdvpar = 0;
       
  rw_crappep cr_crappep%ROWTYPE;
  vr_count NUMBER := 0;
  vr_count_commit NUMBER := 0;
BEGIN
  
  FOR rw_crappep IN cr_crappep LOOP
    vr_count := vr_count + 1;
    vr_tab_crappep(vr_count).cdcooper := rw_crappep.cdcooper;
    vr_tab_crappep(vr_count).nrdconta := rw_crappep.nrdconta;
    vr_tab_crappep(vr_count).nrctremp := rw_crappep.nrctremp;
    vr_tab_crappep(vr_count).nrparepr := rw_crappep.nrparepr;
    vr_tab_crappep(vr_count).vlsdvpar := rw_crappep.vlsdvpar;    
  END LOOP;
  
  FORALL vr_idx IN INDICES OF vr_tab_crappep SAVE EXCEPTIONS
    UPDATE cecred.crappep pep
       SET pep.vlsdvpar = vr_tab_crappep(vr_idx).vlsdvpar
     WHERE pep.cdcooper = vr_tab_crappep(vr_idx).cdcooper 
       AND pep.nrdconta = vr_tab_crappep(vr_idx).nrdconta
       AND pep.nrctremp = vr_tab_crappep(vr_idx).nrctremp
       AND pep.nrparepr = vr_tab_crappep(vr_idx).nrparepr;
       
    vr_count_commit := vr_count_commit + 1;
    
    IF MOD(vr_count_commit,1000) = 0 THEN
     COMMIT;
    END IF;
  COMMIT;  
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => 3);
      ROLLBACK;
END;  
