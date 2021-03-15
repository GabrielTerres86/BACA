DECLARE
--
  vr_cdcooper   craplem.cdcooper%type := 1; -- Viacredi
  vr_nrdconta   craplem.nrdconta%type := 6037550; -- Alterar aqui
  vr_nrctremp   craplem.nrctremp%type := 2158838; -- Alterar aqui
  vr_vllanmto   craplem.vllanmto%type := 635.18; -- Alterar aqui
--
  vr_cdcritic    number;
  vr_dscritic    varchar2(2000);
--
  CURSOR cr_crapdat ( pr_cdcooper in craplcm.cdcooper%type ) is
     select  dat.*
     from    crapdat   dat
     where dat.cdcooper = pr_cdcooper;
--
  rw_crapdat   cr_crapdat%rowtype;
--
BEGIN
--
  OPEN cr_crapdat ( pr_cdcooper => vr_cdcooper );
  FETCH  cr_crapdat
  INTO  rw_crapdat;
  CLOSE cr_crapdat;
--
  cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
                                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                         pr_cdagenci => 85,
                                         pr_cdbccxlt => 100,
                                         pr_cdoperad => 1,
                                         pr_cdpactra => 85, -- rw_craplem.cdagenci,
                                         pr_tplotmov => 5,
                                         pr_nrdolote => 600031, -- rw_craplcm.nrdolote,
                                         pr_nrdconta => vr_nrdconta,
                                         pr_cdhistor => 3272, -- EST.JUROS REM
                                         pr_nrctremp => vr_nrctremp,
                                         pr_vllanmto => vr_vllanmto,
                                         pr_dtpagemp => rw_crapdat.dtmvtolt,
                                         pr_txjurepr => 0.0529252,
                                         pr_vlpreemp => null, -- vr_vlpreemp,
                                         pr_nrsequni => 0,
                                         pr_nrparepr => 0,
                                         pr_flgincre => true,
                                         pr_flgcredi => true,
                                         pr_nrseqava => 0,
                                         pr_cdorigem => 7,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);
--
  IF vr_cdcritic > 0
  OR vr_dscritic is not null then
     raise_application_error(-20501, 'Erro : ' || vr_cdcritic || ' - ' || vr_dscritic);
  END IF;
--
  COMMIT;
exception
  WHEN others THEN
    ROLLBACK;
    raise_application_error(-20599, SQLERRM);
END;
/
