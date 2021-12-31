DECLARE
  vr_stprogra PLS_INTEGER;
  vr_infimsol PLS_INTEGER;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
BEGIN
  pc_crps652(pr_cdcooper => 3,
             pr_cdcoppar => 0,
             pr_cdagepar => 0,
             pr_idparale => 0,
             pr_cdprogra => 'CRPS652',
             pr_qtdejobs => 10,
             pr_stprogra => vr_stprogra,
             pr_infimsol => vr_infimsol,
             pr_cdcritic => vr_cdcritic,
             pr_dscritic => vr_dscritic);
END;
