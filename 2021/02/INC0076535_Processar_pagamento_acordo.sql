DECLARE
  CURSOR cr_boletos_pagos_acordos IS
    SELECT acp.nracordo
          ,acp.nrparcela
      FROM crapret                ret
          ,crapcob                cob
          ,tbrecup_acordo_parcela acp
          ,tbrecup_acordo         aco
          ,crapcco                cco
     WHERE ret.cdcooper = 7
       AND ret.nrcnvcob = 980106
       AND ret.cdocorre IN (6, 76)
       AND cob.cdcooper = ret.cdcooper
       AND cob.nrcnvcob = ret.nrcnvcob
       AND cob.nrdconta = ret.nrdconta
       AND cob.nrdocmto = ret.nrdocmto
       AND aco.cdcooper = cob.cdcooper
       AND acp.nrdconta_cob = cob.nrdconta
       AND acp.nrconvenio = cob.nrcnvcob
       AND acp.nrboleto = cob.nrdocmto
       AND cco.cdcooper = ret.cdcooper
       AND cco.nrconven = ret.nrcnvcob
       AND cob.cdbandoc = cco.cddbanco
       AND cob.nrdctabb = cco.nrdctabb
       AND aco.nracordo = acp.nracordo
       AND (
           aco.NRACORDO = 298320 AND ret.dtocorre = to_date('26/01/2021', 'dd/mm/yyyy')
        OR aco.NRACORDO = 301893 AND ret.dtocorre = to_date('18/01/2021', 'dd/mm/yyyy')
           );

  vr_vltotpag NUMBER;
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(5000);
BEGIN

  FOR rw_boletos_pagos_acordos IN cr_boletos_pagos_acordos LOOP
    
    vr_vltotpag := NULL;
    vr_cdcritic := NULL;
    vr_dscritic := NULL;
    
    recp0001.pc_pagar_contrato_acordo(pr_nracordo => rw_boletos_pagos_acordos.nracordo,
                                      pr_nrparcel => rw_boletos_pagos_acordos.nrparcela,
                                      pr_vlparcel => 0,
                                      pr_cdoperad => 1,
                                      pr_idorigem => 1,
                                      pr_nmtelant => 'CPS538',
                                      pr_vltotpag => vr_vltotpag,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('Erro ao pagar acordo ' || rw_boletos_pagos_acordos.nracordo || ': ' || vr_dscritic);
    ELSE
       dbms_output.put_line('Acordo: '|| rw_boletos_pagos_acordos.nracordo||' valor total pago: '||vr_vltotpag);
    END IF;
  END LOOP;
END;
