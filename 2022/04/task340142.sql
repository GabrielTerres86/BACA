DECLARE

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  vr_cdcooper cecred.crappep.cdcooper%TYPE := 2;
  vr_nrdconta cecred.crappep.nrdconta%TYPE := 1035673;
  vr_nrctremp cecred.crappep.nrctremp%TYPE := 320862;
  vr_nrparepr cecred.crappep.nrparepr%TYPE := 5;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  CURSOR cr_lancamento(pr_cdcooper IN cecred.crappep.cdcooper%TYPE
                      ,pr_nrdconta IN cecred.crappep.nrdconta%TYPE
                      ,pr_nrctremp IN cecred.crappep.nrctremp%TYPE
                      ,pr_nrparepr IN cecred.crappep.nrparepr%TYPE) IS
    select pr_cdcooper as cdcooper
          ,pr_nrdconta as nrdconta
          ,pr_nrctremp as nrctremp
          ,case
             when ds.nrparepr = 0 then
              NULL
             else
              ds.nrparepr
           end as nrparepr
          ,ds.cdhistor
          ,ds.vllanmto
      from (select case cl.cdhistor
                     when 1037 then
                      1041
                     when 1044 then
                      1705
                     when 1047 then
                      1708
                     when 1077 then
                      1711
                   end as cdhistor
                  ,cl.vllanmto
                  ,cl.nrparepr
              from cecred.craplem cl
             where cl.cdcooper = pr_cdcooper
               and cl.nrdconta = pr_nrdconta
               and cl.nrctremp = pr_nrctremp
               and trunc(cl.dtmvtolt) = trunc(to_date('11/02/2022', 'dd/mm/yyyy'))
               and cl.cdhistor in (1037, 1044, 1047, 1077)
            union all
            SELECT (select decode(empconsig.indautrepassecc, 1, 3026, 3027)
                      from cecred.tbcadast_empresa_consig empconsig
                     where empconsig.cdcooper = pr_cdcooper
                       and empconsig.cdempres = (select ttl.cdempres
                                                   from cecred.crapttl ttl
                                                  where cdcooper = pr_cdcooper
                                                    and nrdconta = pr_nrdconta)) as cdhistor
                  ,pep.vlparepr
                  ,pep.nrparepr
              from crappep pep
             where pep.cdcooper = pr_cdcooper
               and pep.nrdconta = pr_nrdconta
               and pep.nrctremp = pr_nrctremp
               and pep.nrparepr = pr_nrparepr) ds;

BEGIN

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;

  FOR rw_lancamentos IN cr_lancamento(pr_cdcooper => vr_cdcooper,
                                      pr_nrdconta => vr_nrdconta,
                                      pr_nrctremp => vr_nrctremp,
                                      pr_nrparepr => vr_nrparepr) LOOP
  
    EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => rw_lancamentos.cdcooper,
                                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                    pr_cdagenci => rw_crapass.cdagenci,
                                    pr_cdbccxlt => 100,
                                    pr_cdoperad => 1,
                                    pr_cdpactra => rw_crapass.cdagenci,
                                    pr_tplotmov => 5,
                                    pr_nrdolote => 600031,
                                    pr_nrdconta => rw_lancamentos.nrdconta,
                                    pr_cdhistor => rw_lancamentos.cdhistor,
                                    pr_nrctremp => rw_lancamentos.nrctremp,
                                    pr_vllanmto => rw_lancamentos.vllanmto,
                                    pr_dtpagemp => rw_crapdat.dtmvtolt,
                                    pr_txjurepr => 0,
                                    pr_vlpreemp => 0,
                                    pr_nrsequni => 0,
                                    pr_nrparepr => rw_lancamentos.nrparepr,
                                    pr_flgincre => FALSE,
                                    pr_flgcredi => FALSE,
                                    pr_nrseqava => 0,
                                    pr_cdorigem => 5,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
  
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  END LOOP;

  COMMIT;

EXCEPTION

  WHEN vr_exc_saida THEN
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
