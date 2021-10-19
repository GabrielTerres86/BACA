PL/SQL Developer Test script 3.0
64
DECLARE 
  vr_exc_erro   exception;
  vr_stprogra   PLS_INTEGER;
  vr_infimsol   PLS_INTEGER;
  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   crapcri.dscritic%TYPE;  
begin
    -- 1, 11, 12, 13, 16
    cecred.pc_crps249(pr_cdcooper => 11,
                        pr_flgresta => 0,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    cecred.pc_crps249(pr_cdcooper => 12,
                        pr_flgresta => 0,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    cecred.pc_crps249(pr_cdcooper => 13,
                        pr_flgresta => 0,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    cecred.pc_crps249(pr_cdcooper => 16,
                        pr_flgresta => 0,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    cecred.pc_crps249(pr_cdcooper => 1,
                        pr_flgresta => 0,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
      
end;
0
0
