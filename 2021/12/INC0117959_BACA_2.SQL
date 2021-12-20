DECLARE

pr_stprogra_v integer;
pr_infimsol_v integer;
pr_cdcritic_v crapcri.cdcritic%TYPE;
pr_dscritic_v VARCHAR2(250);

begin

CECRED.pc_crps784(pr_cdcooper => 10  
                    ,pr_stprogra => pr_stprogra_v
                    ,pr_infimsol => pr_infimsol_v
                    ,pr_cdcritic => pr_cdcritic_v
                    ,pr_dscritic => pr_dscritic_v);
                    
if pr_dscritic_v is not null then
   rollback;      
end if;               
                                                 
end;
