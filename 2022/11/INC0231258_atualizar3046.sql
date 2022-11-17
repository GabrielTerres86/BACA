declare

  pr_stprogra NUMBER;
  pr_infimsol NUMBER;
  pr_cdcritic NUMBER;
  pr_dscritic VARCHAR2(2000);

begin

  delete from cecred.tbbi_opf_header o where o.dtbase = to_date('30/09/2022', 'dd/mm/yyyy');
  commit;
  delete from cecred.crapopf o where o.dtrefere = to_date('30/09/2022', 'dd/mm/yyyy');
  commit;
  delete from cecred.crapvop o where o.dtrefere = to_date('30/09/2022', 'dd/mm/yyyy');
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
  commit;
end;
/
