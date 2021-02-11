DECLARE
--
  vr_cdcooper    craplem.cdcooper%type := 1; -- Viacredi
  vr_dtmvtolt    craplem.dtmvtolt%type := to_date('21/10/2020', 'dd/mm/yyyy'); -- Alterar aqui
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
                     ,pr_dtmvtolt  in craplcm.dtmvtolt%type
                    ) is
     select  lcm.*
     from    craplcm   lcm
     where lcm.cdcooper  = pr_cdcooper
     and   lcm.nrdconta in (10314318, 7381271, 8797510, 9476903 )
     and   lcm.dtmvtolt  = pr_dtmvtolt
     and   lcm.cdhistor  = 15 -- CR.EMPRESTIMO
     order by  lcm.dtmvtolt desc
              ,lcm.nrdconta
              ,lcm.nrparepr;
--
  CURSOR cr_crapepr ( pr_cdcooper  in craplcm.cdcooper%type
                     ,pr_nrdconta  in craplcm.nrdconta%type
                     ,pr_dtmvtolt  in craplcm.dtmvtolt%type
                    ) is
    SELECT  *
    FROM    crapepr   epr
    WHERE epr.cdcooper = pr_cdcooper
    AND   epr.nrdconta = pr_nrdconta
    AND   epr.dtmvtolt = pr_dtmvtolt;
--
  rw_crapepr   cr_crapepr%rowtype;
--
  CURSOR cr_crawepr ( pr_cdcooper  in craplcm.cdcooper%type
                     ,pr_nrdconta  in craplcm.nrdconta%type
                     ,pr_dtmvtolt  in craplcm.dtmvtolt%type
                    ) is
    SELECT  *
    FROM    crawepr   epr
    WHERE epr.cdcooper = pr_cdcooper
    AND   epr.nrdconta = pr_nrdconta
    AND   epr.dtmvtolt = pr_dtmvtolt;
--
  rw_crawepr   cr_crawepr%rowtype;
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
     and   lem.dtmvtolt >= pr_dtmvtolt
     and   lem.nrparepr  = pr_nrparepr
     and   lem.cdhistor  = 1036
     order by  lem.dtmvtolt desc
              ,lem.nrdconta
              ,lem.nrctremp
              ,lem.nrparepr;
--
  rw_craplem_pagto   cr_craplem_pagto%rowtype;
--
BEGIN
--
  OPEN cr_crapdat ( pr_cdcooper => vr_cdcooper );
  FETCH  cr_crapdat
  INTO  rw_crapdat;
  CLOSE cr_crapdat;
--
  FOR rw_craplcm IN cr_craplcm ( pr_cdcooper  => vr_cdcooper
                                ,pr_dtmvtolt  => vr_dtmvtolt
                               ) LOOP
--
    OPEN cr_crapepr ( pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => rw_craplcm.nrdconta
                     ,pr_dtmvtolt => vr_dtmvtolt );
    FETCH  cr_crapepr
    INTO  rw_crapepr;
    CLOSE cr_crapepr;
--
    OPEN cr_crawepr ( pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => rw_craplcm.nrdconta
                     ,pr_dtmvtolt => vr_dtmvtolt );
    FETCH  cr_crawepr
    INTO  rw_crawepr;
    CLOSE cr_crawepr;
--
    OPEN cr_craplem_pagto ( pr_cdcooper  => rw_craplcm.cdcooper
                           ,pr_nrdconta  => rw_craplcm.nrdconta
                           ,pr_nrctremp  => rw_crapepr.nrctremp
                           ,pr_dtmvtolt  => rw_craplcm.dtmvtolt
                           ,pr_dtmvtolt2 => vr_dtmvtolt
                           ,pr_nrparepr  => rw_craplcm.nrparepr
                           );
    FETCH cr_craplem_pagto
    INTO  rw_craplem_pagto;
--
    IF cr_craplem_pagto%notfound THEN -- Incluir o pagto da parcela na craplem caso não encontrado.
--
      cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => rw_craplcm.cdcooper,
                                             pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                             pr_cdagenci => rw_craplcm.cdagenci,
                                             pr_cdbccxlt => rw_craplcm.cdbccxlt,
                                             pr_cdoperad => 1,
                                             pr_cdpactra => rw_craplcm.cdagenci,
                                             pr_tplotmov => 4, -- Tipo de movimento do histórico 1036
                                             pr_nrdolote => rw_craplcm.nrdolote,
                                             pr_nrdconta => rw_craplcm.nrdconta,
                                             pr_cdhistor => 1036, -- Liberação do crédito --aquiadriano. Validar se é isso mesmo
                                             pr_nrctremp => rw_crapepr.nrctremp,
                                             pr_vllanmto => rw_craplcm.vllanmto,
                                             pr_dtpagemp => rw_crapdat.dtmvtolt,
                                             pr_txjurepr => rw_crawepr.txdiaria,
                                             pr_vlpreemp => 0,
                                             pr_nrsequni => rw_craplcm.nrparepr,
                                             pr_nrparepr => rw_craplcm.nrparepr,
                                             pr_flgincre => true,
                                             pr_flgcredi => true,
                                             pr_nrseqava => rw_craplcm.nrseqava,
                                             pr_cdorigem => 3, -- Caixa online
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
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN others THEN
    ROLLBACK;
    raise_application_error(-20599, sqlerrm);
END;
/
