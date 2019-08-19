DECLARE 

CURSOR cr_craplfp IS
  SELECT craplfp.rowid, craplfp.*
    FROM craplfp
   WHERE cdcooper = 1
     AND cdempres = 3893
     AND nrseqpag = 1;
  
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_retxml   VARCHAR(3000);
BEGIN

FOR rw_craplfp IN cr_craplfp LOOP
  cecred.folh0002.pc_impressao_comprovante(pr_cdcooper => rw_craplfp.cdcooper
                                          ,pr_nrdconta => rw_craplfp.nrseqpag
                                          ,pr_idtipfol => 1
                                          ,pr_rowidpfp => rw_craplfp.rowid
                                          ,pr_iddspscp => 0
                                          ,pr_retxml => vr_retxml
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
END LOOP;

  
END;