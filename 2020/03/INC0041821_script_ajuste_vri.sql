DECLARE
  --
  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE
                   ) IS
    SELECT cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper = nvl(pr_cdcooper, cop.cdcooper); -- Ativo
  
  CURSOR cr_contrato(pr_cdcooper crapepr.cdcooper%TYPE
                    ) IS
    SELECT tab.cdcooper
          ,tab.nrdconta
          ,tab.nrctremp
          ,tab.vldivida
          ,tab.vlempres
          ,tab.vlempres/tab.vldivida vldifere
          ,MIN(pep.dtvencto) dtvencto
          ,MIN(pep.dtvencto) + 59 dt59dias
          ,(SELECT MAX(vri.dtrefere)
              FROM crapvri vri
             WHERE vri.cdcooper = tab.cdcooper
               AND vri.dtrefere >= '01/01/2020') - MIN(pep.dtvencto) qtdiavnc
      FROM( SELECT vri.cdcooper
                  ,vri.nrdconta
                  ,vri.nrctremp
                  ,sum(vri.vldivida) vldivida
                  ,sum(vri.vlempres) vlempres
              FROM crapvri vri
                  ,crapepr epr
             WHERE epr.cdcooper = vri.cdcooper
               AND epr.nrdconta = vri.nrdconta
               AND epr.nrctremp = vri.nrctremp
               AND epr.tpemprst = 2 -- Fixo
               AND vri.cdcooper = NVL(pr_cdcooper, vri.cdcooper)
               AND vri.dtrefere = (SELECT MAX(vri.dtrefere)
                                     FROM crapvri vri
                                    WHERE vri.cdcooper = epr.cdcooper
                                      AND vri.dtrefere >= '01/01/2020') -- Fixo
             GROUP BY vri.cdcooper
                     ,vri.nrdconta
                     ,vri.nrctremp
          ) tab
          ,crappep pep
     WHERE pep.cdcooper = tab.cdcooper
       AND pep.nrdconta = tab.nrdconta
       AND pep.nrctremp = tab.nrctremp
       AND (pep.inliquid = 0 OR pep.inprejuz = 1)
       AND pep.dtvencto <= (SELECT MAX(vri.dtrefere)
                              FROM crapvri vri
                             WHERE vri.cdcooper = tab.cdcooper
                               AND vri.dtrefere >= '01/01/2020')
       AND tab.vldivida <> tab.vlempres
       AND tab.vlempres/tab.vldivida < 0.95
     GROUP BY tab.cdcooper
             ,tab.nrdconta
             ,tab.nrctremp
             ,tab.vldivida
             ,tab.vlempres
             ,tab.vlempres/tab.vldivida;
  --
  CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                   ,pr_nrdconta crapepr.nrdconta%TYPE
                   ,pr_nrctremp crapepr.nrctremp%TYPE
                   ) IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.dtmvtolt
          ,epr.cdlcremp
          ,epr.vlemprst
          ,epr.txmensal
          ,wpr.dtdpagto
          ,epr.vlsprojt
          ,epr.qttolatr
      FROM crapepr epr
          ,crawepr wpr
     WHERE epr.cdcooper = wpr.cdcooper
       AND epr.nrdconta = wpr.nrdconta
       AND epr.nrctremp = wpr.nrctremp
       AND epr.cdcooper = pr_cdcooper
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp;
  --
  CURSOR cr_crapris(pr_cdcooper crapris.cdcooper%TYPE
                   ,pr_nrdconta crapris.nrdconta%TYPE
                   ,pr_nrctremp crapris.nrctremp%TYPE
                   ) IS
    SELECT ris.vldivida
      FROM crapris ris
     WHERE ris.cdcooper = pr_cdcooper
       AND ris.nrdconta = pr_nrdconta
       AND ris.nrctremp = pr_nrctremp
       AND ris.dtrefere = (SELECT MAX(vri2.dtrefere)
                             FROM crapvri vri2
                            WHERE vri2.cdcooper = ris.cdcooper
                              AND vri2.dtrefere >= '01/01/2020');
  --
  CURSOR cr_crapvri(pr_cdcooper crapvri.cdcooper%TYPE
                   ,pr_nrdconta crapvri.nrdconta%TYPE
                   ,pr_nrctremp crapvri.nrctremp%TYPE
                   ) IS
    SELECT vri.nrdconta
          ,vri.dtrefere
          ,vri.cdcooper
          ,vri.nrctremp
          ,vri.cdvencto
          ,vri.vldivida
      FROM crapvri vri
     WHERE vri.cdcooper = pr_cdcooper
       AND vri.nrdconta = pr_nrdconta
       AND vri.nrctremp = pr_nrctremp
       AND vri.dtrefere = (SELECT MAX(vri2.dtrefere)
                             FROM crapvri vri2
                            WHERE vri2.cdcooper = vri.cdcooper
                              AND vri2.dtrefere >= '01/01/2020'); -- Fixo
  --
  vr_tab_parcelas  empr0011.typ_tab_parcelas;
  vr_tab_calculado empr0011.typ_tab_calculado;
  --
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  --
  rw_crapvri cr_crapvri%ROWTYPE;
  --
  vr_cdcooper NUMBER := NULL; -- Trocar para NULL se for executar para todas as cooperativas
  vr_dtmvtoan DATE;
  vr_vldivida NUMBER;
  vr_vlempres NUMBER;
  vr_vleprtot NUMBER;
  --
BEGIN
  --
  FOR rw_crapcop IN cr_crapcop(pr_cdcooper => vr_cdcooper
                              ) LOOP
    --
    FOR rw_contrato IN cr_contrato(pr_cdcooper => rw_crapcop.cdcooper
                                  ) LOOP
      --
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => rw_contrato.cdcooper
                                  ,pr_nrdconta => rw_contrato.nrdconta
                                  ,pr_nrctremp => rw_contrato.nrctremp
                                  ) LOOP
        --
        vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => rw_contrato.cdcooper
                                                  ,pr_dtmvtolt => rw_contrato.dt59dias - 1
                                                  ,pr_tipo     => 'A'
                                                  );
        -- Busca as parcelas para pagamento
        EMPR0011.pc_busca_pagto_parc_pos(pr_cdcooper      => rw_crapepr.cdcooper
                                        ,pr_cdprogra      => 'EMPR0011' -- Fixo
                                        ,pr_dtmvtolt      => rw_contrato.dt59dias
                                        ,pr_dtmvtoan      => vr_dtmvtoan
                                        ,pr_nrdconta      => rw_crapepr.nrdconta
                                        ,pr_nrctremp      => rw_crapepr.nrctremp
                                        ,pr_dtefetiv      => rw_crapepr.dtmvtolt
                                        ,pr_cdlcremp      => rw_crapepr.cdlcremp
                                        ,pr_vlemprst      => rw_crapepr.vlemprst
                                        ,pr_txmensal      => rw_crapepr.txmensal
                                        ,pr_dtdpagto      => rw_crapepr.dtdpagto
                                        ,pr_vlsprojt      => rw_crapepr.vlsprojt
                                        ,pr_qttolatr      => rw_crapepr.qttolatr
                                        ,pr_tab_parcelas  => vr_tab_parcelas
                                        ,pr_tab_calculado => vr_tab_calculado
                                        ,pr_cdcritic      => vr_cdcritic
                                        ,pr_dscritic      => vr_dscritic
                                        );
        --
        --dbms_output.put_line('vlsdeved: ' || vr_tab_calculado(1).vlsdeved);
        --
        OPEN cr_crapris(rw_crapepr.cdcooper
                       ,rw_crapepr.nrdconta
                       ,rw_crapepr.nrctremp
                       );
        FETCH cr_crapris INTO vr_vldivida;
        CLOSE cr_crapris;
        --
        vr_vleprtot := 0;
        --
        OPEN cr_crapvri(rw_crapepr.cdcooper
                       ,rw_crapepr.nrdconta
                       ,rw_crapepr.nrctremp
                       );
        LOOP
          --
          FETCH cr_crapvri INTO rw_crapvri;
          EXIT WHEN cr_crapvri%NOTFOUND;
          --
          vr_vlempres := ROUND((rw_crapvri.vldivida / vr_vldivida) * vr_tab_calculado(1).vlsdeved, 2);
          vr_vleprtot := vr_vleprtot + vr_vlempres;
          --
          UPDATE crapvri vri
             SET vri.vlempres = vr_vlempres
           WHERE vri.nrdconta = rw_crapvri.nrdconta
             AND vri.dtrefere = rw_crapvri.dtrefere
             AND vri.nrctremp = rw_crapvri.nrctremp
             AND vri.cdvencto = rw_crapvri.cdvencto
             AND vri.cdcooper = rw_crapvri.cdcooper;
          --
          COMMIT;
          --
        END LOOP;
        --
        vr_vleprtot := vr_tab_calculado(1).vlsdeved - vr_vleprtot;
        --
        IF NVL(vr_vleprtot, 0) <> 0 THEN
          --
          UPDATE crapvri vri
             SET vri.vlempres = vri.vlempres + vr_vleprtot
           WHERE vri.nrdconta = rw_crapvri.nrdconta
             AND vri.dtrefere = rw_crapvri.dtrefere
             AND vri.nrctremp = rw_crapvri.nrctremp
             AND vri.cdvencto = rw_crapvri.cdvencto
             AND vri.cdcooper = rw_crapvri.cdcooper;
          --
          COMMIT;
          --
        END IF;
        --
        CLOSE cr_crapvri;
        --
        dbms_output.put_line('vr_cdcritic: ' || vr_cdcritic);
        dbms_output.put_line('vr_dscritic: ' || vr_dscritic);
        --
      END LOOP;
      --
    END LOOP;
    --
  END LOOP;
  --
END;
