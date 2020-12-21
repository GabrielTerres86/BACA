DECLARE
--
  vr_cdcooper   craplem.cdcooper%type := 1; -- Viacredi
  vr_nrdconta   craplem.nrdconta%type := 12026786; -- Alterar aqui
  vr_dtmvtolt   craplem.dtmvtolt%type := to_date('07/12/2020', 'dd/mm/yyyy'); -- Alterar aqui
  vr_nrctremp   craplem.nrctremp%type := 3215651; -- Alterar aqui
  vr_vlpreemp   craplem.vlpreemp%type := 853.84; -- Alterar aqui
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
  CURSOR cr_crappep ( pr_cdcooper in craplem.cdcooper%type
                     ,pr_nrdconta in craplem.nrdconta%type
                     ,pr_nrctremp in craplem.nrctremp%type
                     ) is
     select  pep.*
            ,pep.rowid
     from    crappep   pep
     where pep.cdcooper = pr_cdcooper
     and   pep.nrdconta = pr_nrdconta
     and   pep.nrctremp = pr_nrctremp
     order by  pep.nrdconta
              ,pep.nrctremp
              ,pep.nrparepr;
--
  CURSOR cr_tcpt ( pr_cdcooper in craplem.cdcooper%type
                  ,pr_nrdconta in craplem.nrdconta%type
                  ,pr_nrctremp in craplem.nrctremp%type
                  ,pr_dtmvtolt in craplem.dtmvtolt%type
                 ) is
    SELECT  tcpt.*
           ,tcpt.rowid
    FROM    tbepr_consig_parcelas_tmp   tcpt
    WHERE tcpt.cdcooper = pr_cdcooper
    AND   tcpt.nrdconta = pr_nrdconta
    AND   tcpt.nrctremp = pr_nrctremp
    AND   tcpt.dtmovimento = pr_dtmvtolt;

--
BEGIN
--
  OPEN cr_crapdat ( pr_cdcooper => vr_cdcooper );
  FETCH  cr_crapdat
  INTO  rw_crapdat;
  CLOSE cr_crapdat;
--
  FOR rw_crappep in cr_crappep ( pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => vr_nrdconta
                                ,pr_nrctremp => vr_nrctremp
                                ) LOOP
    UPDATE crappep
       set  inliquid = 1
           ,dtultpag = vr_dtmvtolt
           ,vlpagpar = vr_vlpreemp
           ,vlsdvsji = vr_vlpreemp
           ,vlsdvatu = 0
           ,vlsdvpar = 0
           ,vldespar = 0
           ,vlmtapar = 0
           ,vlmrapar = 0
           ,vliofcpl = 0
    where rowid = rw_crappep.rowid;
  END LOOP;
--
  FOR rw_tcpt in cr_tcpt ( pr_cdcooper => vr_cdcooper
                          ,pr_nrdconta => vr_nrdconta
                          ,pr_nrctremp => vr_nrctremp
                          ,pr_dtmvtolt => vr_dtmvtolt
                         ) LOOP
    IF nvl(rw_tcpt.instatusproces, 'N') <> 'P' THEN
      UPDATE tbepr_consig_parcelas_tmp
      SET instatusproces = 'P'
      WHERE rowid = rw_tcpt.rowid;
    END IF;
  END LOOP;
--
  UPDATE   crapepr
  set  dtultpag = vr_dtmvtolt
      ,qtprepag = 70
      ,qtprecal = 70
      ,dtliquid = vr_dtmvtolt
      ,VLSDEVED = 0
      ,INLIQUID = 1
  where cdcooper = vr_cdcooper
  and   nrdconta = vr_nrdconta
  and   nrctremp = vr_nrctremp;
--
  COMMIT;
exception
  WHEN others THEN
    ROLLBACK;
    raise_application_error(-20599, SQLERRM);
END;
/
