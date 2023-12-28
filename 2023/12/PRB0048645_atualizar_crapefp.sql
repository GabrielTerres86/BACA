DECLARE 
  vr_nrdrowid        ROWID;
  vr_nmprograma      CECRED.tbgen_prglog.cdprograma%TYPE := 'Atualizar crapefp - PRB0048645';
  vr_cdoperad        CECRED.craplgm.cdoperad%TYPE := 't0035324';
  vr_cdempres_novo   CECRED.crapemp.cdempres%TYPE := 445;
  vr_cdempres_antigo CECRED.crapemp.cdempres%TYPE := 441;
  vr_cdcooper        CECRED.crapemp.cdcooper%TYPE := 12;
  vr_nrdconta        CECRED.crapemp.nrdconta%TYPE := 144290;
  
  CURSOR cr_crapefp IS
   SELECT efp.cdcooper
         ,efp.nrdconta
         ,efp.cdempres
         ,efp.nrcpfemp
     FROM CECRED.crapefp efp
    WHERE efp.cdcooper = vr_cdcooper
      AND efp.cdempres = vr_cdempres_antigo;

BEGIN
  FOR rw_crapefp IN cr_crapefp LOOP
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => rw_crapefp.cdcooper
                               ,pr_nrdconta => vr_nrdconta
                               ,pr_idseqttl => rw_crapefp.cdempres
                               ,pr_cdoperad => vr_cdoperad
                               ,pr_dscritic => rw_crapefp.nrcpfemp
                               ,pr_dsorigem => 'PAGTO'
                               ,pr_dstransa => vr_nmprograma
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 1
                               ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                               ,pr_nmdatela => 'crapefp'
                               ,pr_nrdrowid => vr_nrdrowid);
  END LOOP;
  
  UPDATE CECRED.crapefp efp
     SET efp.cdempres = vr_cdempres_novo
   WHERE efp.cdcooper = vr_cdcooper
     AND efp.cdempres = vr_cdempres_antigo;
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper
                                ,pr_compleme => ' Script: => ' || vr_nmprograma); 
END;
