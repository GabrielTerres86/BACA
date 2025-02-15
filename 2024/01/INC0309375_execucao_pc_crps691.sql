DECLARE

  vr_stprogra    PLS_INTEGER;
  vr_infimsol    PLS_INTEGER;
  vr_cdcritic    NUMBER;
  vr_dscritic    VARCHAR2(2000);
  
BEGIN
  
  cecred.pc_crps691(pr_cdcooper => 1 
                   ,pr_flgresta => 0 
                   ,pr_stprogra => vr_stprogra
                   ,pr_infimsol => vr_infimsol
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);
                   
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    IF vr_dscritic IS NULL THEN 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000,'Erro PC_CRPS691: '||vr_dscritic);
  END IF;

 
  COMMIT;
END;