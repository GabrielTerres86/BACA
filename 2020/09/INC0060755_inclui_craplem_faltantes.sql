DECLARE
--
  vr_cdcooper    craplem.cdcooper%type := 13; -- Civia
  vr_nrdconta    craplem.nrdconta%type := 148407; -- Alterar aqui
  vr_dtmvtolt    craplem.dtmvtolt%type := to_date('04/09/2020', 'dd/mm/yyyy'); -- Alterar aqui
  vr_dtmvtolt2   craplem.dtmvtolt%type := to_date('08/09/2020', 'dd/mm/yyyy'); -- Alterar aqui
  vr_nrctremp    craplem.nrctremp%type := 62768; -- Alterar aqui
  vr_vlpreemp    craplem.vlpreemp%type := 186.9; -- Alterar aqui
  vr_nrparepr    craplem.nrparepr%type;
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
  CURSOR cr_craplcm ( pr_cdcooper  in craplcm.cdcooper%type
                     ,pr_nrdconta  in craplcm.nrdconta%type
                     ,pr_dtmvtolt  in craplcm.dtmvtolt%type
                     ,pr_dtmvtolt2 in craplcm.dtmvtolt%type
                    ) is
     select  lcm.*
     from    craplcm   lcm
     where lcm.cdcooper  = pr_cdcooper
     and   lcm.nrdconta  = pr_nrdconta
     and   lcm.dtmvtolt in (pr_dtmvtolt, pr_dtmvtolt2)
     and   lcm.cdhistor  = 108
     order by  lcm.dtmvtolt desc
              ,lcm.nrdconta
              ,lcm.nrparepr;
--
  CURSOR cr_craplem_pagto ( pr_cdcooper  in craplem.cdcooper%type
                           ,pr_nrdconta  in craplem.nrdconta%type
                           ,pr_nrctremp  in craplem.nrctremp%type
                           ,pr_dtmvtolt  in craplem.dtmvtolt%type
                           ,pr_dtmvtolt2 in craplem.dtmvtolt%type
                           ,pr_nrparepr  in craplem.nrparepr%type
                           ) is
     select  lem.*
     from    craplem   lem
     where lem.cdcooper  = pr_cdcooper
     and   lem.nrdconta  = pr_nrdconta
     and   lem.nrctremp  = pr_nrctremp
     and   lem.dtmvtolt in (pr_dtmvtolt, pr_dtmvtolt2, rw_crapdat.dtmvtolt)
     and   lem.nrparepr  = pr_nrparepr
     and   lem.cdhistor in (1044, 3027)
     order by  lem.dtmvtolt desc
              ,lem.nrdconta
              ,lem.nrctremp
              ,lem.nrparepr;
--
  rw_craplem_pagto   cr_craplem_pagto%rowtype;
--
  CURSOR cr_craplem_explo ( pr_cdcooper  in craplem.cdcooper%type
                           ,pr_nrdconta  in craplem.nrdconta%type
                           ,pr_nrctremp  in craplem.nrctremp%type
                           ,pr_dtmvtolt  in craplem.dtmvtolt%type
                           ,pr_dtmvtolt2 in craplem.dtmvtolt%type
                           ,pr_nrparepr  in craplem.nrparepr%type
                           ) is
     select  lem.*
     from    craplem   lem
     where lem.cdcooper  = pr_cdcooper
     and   lem.nrdconta  = pr_nrdconta
     and   lem.nrctremp  = pr_nrctremp
     and   lem.dtmvtolt in (pr_dtmvtolt, pr_dtmvtolt2, rw_crapdat.dtmvtolt)
     and   lem.nrparepr  = pr_nrparepr
     and   lem.cdhistor  = 1044
     order by  lem.dtmvtolt desc
              ,lem.nrdconta
              ,lem.nrctremp
              ,lem.nrparepr;
--
  rw_craplem_explo   cr_craplem_explo%rowtype;
--
  CURSOR cr_craplem_desco ( pr_cdcooper  in craplem.cdcooper%type
                           ,pr_nrdconta  in craplem.nrdconta%type
                           ,pr_nrctremp  in craplem.nrctremp%type
                           ,pr_dtmvtolt  in craplem.dtmvtolt%type
                           ,pr_dtmvtolt2 in craplem.dtmvtolt%type
                           ,pr_nrparepr  in craplem.nrparepr%type
                           ) is
     select  lem.*
     from    craplem   lem
     where lem.cdcooper  = pr_cdcooper
     and   lem.nrdconta  = pr_nrdconta
     and   lem.nrctremp  = pr_nrctremp
     and   lem.dtmvtolt in (pr_dtmvtolt, pr_dtmvtolt2, rw_crapdat.dtmvtolt)
     and   lem.nrparepr  = pr_nrparepr
     and   lem.cdhistor  = 1048
     order by  lem.dtmvtolt desc
              ,lem.nrdconta
              ,lem.nrctremp
              ,lem.nrparepr;
--
  rw_craplem_desco   cr_craplem_desco%rowtype;
--
  CURSOR cr_crappep ( pr_cdcooper in craplem.cdcooper%type
                     ,pr_nrdconta in craplem.nrdconta%type
                     ,pr_nrctremp in craplem.nrctremp%type
                     ,pr_nrparepr in craplem.nrparepr%type
                     ) is
     select  pep.*
            ,pep.rowid
     from    crappep   pep
     where pep.cdcooper = pr_cdcooper
     and   pep.nrdconta = pr_nrdconta
     and   pep.nrctremp = pr_nrctremp
     and   pep.nrparepr = pr_nrparepr
     order by  pep.nrdconta
              ,pep.nrctremp
              ,pep.nrparepr;
--
  CURSOR cr_tcpt ( pr_cdcooper in craplem.cdcooper%type
                  ,pr_nrdconta in craplem.nrdconta%type
                  ,pr_nrctremp in craplem.nrctremp%type
                  ,pr_dtmvtolt2  in craplem.dtmvtolt%type
                 ) is
    SELECT  tcpt.*
           ,tcpt.rowid
    FROM    tbepr_consig_parcelas_tmp   tcpt
    WHERE tcpt.cdcooper = pr_cdcooper
    AND   tcpt.nrdconta = pr_nrdconta
    AND   tcpt.nrctremp = pr_nrctremp
    AND   tcpt.dtmovimento = pr_dtmvtolt2;

--
BEGIN
--
  OPEN cr_crapdat ( pr_cdcooper => vr_cdcooper );
  FETCH  cr_crapdat
  INTO  rw_crapdat;
  CLOSE cr_crapdat;
--
  FOR rw_craplcm IN cr_craplcm ( pr_cdcooper  => vr_cdcooper
                                ,pr_nrdconta  => vr_nrdconta
                                ,pr_dtmvtolt  => vr_dtmvtolt
                                ,pr_dtmvtolt2 => vr_dtmvtolt2
                               ) LOOP
--
    if rw_craplcm.nrparepr = 4 then
      vr_nrparepr := 72;
    elsif rw_craplcm.nrparepr = 73 then
      vr_nrparepr := 60;
    else
      vr_nrparepr := rw_craplcm.nrparepr - 1;
    end if;
--
    OPEN cr_craplem_explo ( pr_cdcooper  => rw_craplcm.cdcooper
                           ,pr_nrdconta  => rw_craplcm.nrdconta
                           ,pr_nrctremp  => vr_nrctremp
                           ,pr_dtmvtolt  => rw_craplcm.dtmvtolt
                           ,pr_dtmvtolt2 => vr_dtmvtolt2
                           ,pr_nrparepr  => vr_nrparepr
                           );
    FETCH cr_craplem_explo
    INTO  rw_craplem_explo;
    CLOSE cr_craplem_explo;
--
    OPEN cr_craplem_pagto ( pr_cdcooper  => rw_craplcm.cdcooper
                           ,pr_nrdconta  => rw_craplcm.nrdconta
                           ,pr_nrctremp  => vr_nrctremp
                           ,pr_dtmvtolt  => rw_craplcm.dtmvtolt
                           ,pr_dtmvtolt2 => vr_dtmvtolt2
                           ,pr_nrparepr  => rw_craplcm.nrparepr
                           );
    FETCH cr_craplem_pagto
    INTO  rw_craplem_pagto;
--
    IF cr_craplem_pagto%notfound THEN -- Incluir o pagto da parcela na craplem caso não encontrado.
      rw_craplem_pagto.nrdocmto := rw_craplem_explo.nrdocmto + 2;
      rw_craplem_pagto.nrseqdig := rw_craplem_explo.nrseqdig + 2;
      rw_craplem_pagto.nrautdoc := rw_craplcm.nrautdoc;
      rw_craplem_pagto.qtdiacal := rw_craplem_explo.qtdiacal;
      rw_craplem_pagto.vltaxper := rw_craplem_explo.vltaxper;
      rw_craplem_pagto.vltaxprd := rw_craplem_explo.vltaxprd;

      cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => rw_craplcm.cdcooper,
                                             pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                             pr_cdagenci => rw_craplcm.cdagenci,
                                             pr_cdbccxlt => rw_craplcm.cdbccxlt,
                                             pr_cdoperad => 1,
                                             pr_cdpactra => rw_craplcm.cdagenci,
                                             pr_tplotmov => 5,
                                             pr_nrdolote => rw_craplcm.nrdolote,
                                             pr_nrdconta => rw_craplcm.nrdconta,
                                             pr_cdhistor => 1044, -- PAGAM.PARCELA
                                             pr_nrctremp => vr_nrctremp,
                                             pr_vllanmto => rw_craplcm.vllanmto,
                                             pr_dtpagemp => rw_crapdat.dtmvtolt,
                                             pr_txjurepr => rw_craplem_explo.txjurepr,
                                             pr_vlpreemp => vr_vlpreemp,
                                             pr_nrsequni => rw_craplcm.nrparepr,
                                             pr_nrparepr => rw_craplcm.nrparepr,
                                             pr_flgincre => true,
                                             pr_flgcredi => true,
                                             pr_nrseqava => rw_craplcm.nrseqava,
                                             pr_cdorigem => rw_craplem_explo.cdorigem,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
--
      IF vr_cdcritic > 0
      OR vr_dscritic is not null then
         raise_application_error(-20501, 'Erro : ' || vr_cdcritic || ' - ' || vr_dscritic);
      END IF;
    END IF;
--
    CLOSE cr_craplem_pagto;
--
--
    OPEN cr_craplem_desco ( pr_cdcooper  => rw_craplcm.cdcooper
                           ,pr_nrdconta  => rw_craplcm.nrdconta
                           ,pr_nrctremp  => vr_nrctremp
                           ,pr_dtmvtolt  => rw_craplcm.dtmvtolt
                           ,pr_dtmvtolt2 => vr_dtmvtolt2
                           ,pr_nrparepr  => rw_craplcm.nrparepr
                           );
    FETCH cr_craplem_desco
    INTO  rw_craplem_desco;
--
    IF cr_craplem_desco%notfound THEN -- Incluir o pagto da parcela na craplem caso não encontrado.
      cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => rw_craplcm.cdcooper,
                                             pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                             pr_cdagenci => rw_craplcm.cdagenci,
                                             pr_cdbccxlt => rw_craplcm.cdbccxlt,
                                             pr_cdoperad => 1,
                                             pr_cdpactra => rw_craplcm.cdagenci,
                                             pr_tplotmov => 5,
                                             pr_nrdolote => rw_craplcm.nrdolote,
                                             pr_nrdconta => rw_craplcm.nrdconta,
                                             pr_cdhistor => 1048, -- DESC.ANT.EMP
                                             pr_nrctremp => vr_nrctremp,
                                             pr_vllanmto => vr_vlpreemp - rw_craplcm.vllanmto,
                                             pr_dtpagemp => rw_crapdat.dtmvtolt,
                                             pr_txjurepr => rw_craplem_explo.txjurepr,
                                             pr_vlpreemp => vr_vlpreemp,
                                             pr_nrsequni => rw_craplcm.nrparepr,
                                             pr_nrparepr => rw_craplcm.nrparepr,
                                             pr_flgincre => true,
                                             pr_flgcredi => true,
                                             pr_nrseqava => rw_craplcm.nrseqava,
                                             pr_cdorigem => rw_craplem_explo.cdorigem,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
--
      IF vr_cdcritic > 0
      OR vr_dscritic is not null then
         raise_application_error(-20502, 'Erro : ' || vr_cdcritic || ' - ' || vr_dscritic);
      END IF;
    END IF;
--
    CLOSE cr_craplem_desco;
--
    FOR rw_crappep in cr_crappep ( pr_cdcooper => rw_craplcm.cdcooper
                                  ,pr_nrdconta => rw_craplcm.nrdconta
                                  ,pr_nrctremp => vr_nrctremp
                                  ,pr_nrparepr => rw_craplcm.nrparepr
                                  ) LOOP
       if rw_crappep.dtultpag is null THEN
          UPDATE crappep
             set  dtultpag = rw_crapdat.dtmvtolt
          where rowid = rw_crappep.rowid;
       END IF;
--
       if rw_crappep.inliquid  = 0
       or rw_crappep.vlpagpar  = 0
       or rw_crappep.vlsdvsji  = 0
       or rw_crappep.vlsdvatu <> 0THEN
          UPDATE crappep
             set  inliquid = 1
                 ,vlpagpar = vr_vlpreemp
                 ,vlsdvsji = vr_vlpreemp
                 ,vlsdvatu = 0
                 ,vlsdvpar = 0
                 ,vldespar = 0
                 ,vlmtapar = 0
                 ,vlmrapar = 0
                 ,vliofcpl = 0
          where rowid = rw_crappep.rowid;
       END IF;
    END LOOP;
--
    FOR rw_tcpt in cr_tcpt ( pr_cdcooper  => rw_craplcm.cdcooper
                            ,pr_nrdconta  => rw_craplcm.nrdconta
                            ,pr_nrctremp  => vr_nrctremp
                            ,pr_dtmvtolt2 => vr_dtmvtolt2
                           ) LOOP
      IF nvl(rw_tcpt.instatusproces, 'N') <> 'P' THEN
        UPDATE tbepr_consig_parcelas_tmp
        SET instatusproces = 'P'
        WHERE rowid = rw_tcpt.rowid;
      END IF;
    END LOOP;

--
  END LOOP;
--
  UPDATE   crapepr
  set  dtultpag = rw_crapdat.dtmvtolt
      ,qtprepag = 84
      ,qtprecal = 84
      ,dtliquid = rw_crapdat.dtmvtolt
  where cdcooper = vr_cdcooper
  and   nrdconta = vr_nrdconta
  and   nrctremp = vr_nrctremp;
--
  commit;
END;
/
