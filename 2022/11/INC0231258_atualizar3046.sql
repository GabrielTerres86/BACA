declare

  pr_stprogra NUMBER;
  pr_infimsol NUMBER;
  pr_cdcritic NUMBER;
  pr_dscritic VARCHAR2;

begin

  delete from tbbi_opf_header o where o.dtbase = '30/09/2022'; -- 5
  commit;
  delete from crapopf o where o.dtrefere = '30/09/2022';       -- 1.414.866
  commit;
  delete from crapvop o where o.dtrefere = '30/09/2022';       -- 15.298.297
  commit;

  cecred.PC_CRPS572(pr_cdcooper => 3,
                    pr_flgresta => 0,
                    pr_stprogra => pr_stprogra,
                    pr_infimsol => pr_infimsol,
                    pr_cdcritic => pr_cdcritic,
                    pr_dscritic => pr_dscritic);

  DBMS_OUTPUT.put_line('pr_stprogra: ' || pr_stprogra);
  DBMS_OUTPUT.put_line('pr_infimsol: ' || pr_infimsol);
  DBMS_OUTPUT.put_line('pr_cdcritic: ' || pr_cdcritic);
  DBMS_OUTPUT.put_line('pr_dscritic: ' || pr_dscritic);

end;
/