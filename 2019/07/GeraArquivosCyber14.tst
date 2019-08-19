PL/SQL Developer Test script 3.0
23
DECLARE
  pr_cdcritic NUMBER;
  pr_dscritic VARCHAR2(1500);
  pr_stprogra NUMBER;
  pr_infimsol NUMBER;
  vr_dscritic VARCHAR2(4000) := '';
  vr_exc_saida EXCEPTION;

BEGIN
  pc_crps652(3,
             14,
             1,
             0,
             'CRPS652',
             1,
             pr_stprogra,
             pr_infimsol,
             pr_cdcritic,
             pr_dscritic);

  commit;

END;
0
0
