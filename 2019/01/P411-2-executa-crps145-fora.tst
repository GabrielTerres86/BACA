PL/SQL Developer Test script 3.0
9
begin
  -- Call the procedure
  cecred.pc_crps145_teste(pr_cdcooper => 1,
                          pr_flgresta => 0,
                          pr_stprogra => :pr_stprogra,
                          pr_infimsol => :pr_infimsol,
                          pr_cdcritic => :pr_cdcritic,
                          pr_dscritic => :pr_dscritic);
end;
0
0
