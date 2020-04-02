DECLARE
  --
  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE
                   ) IS
    SELECT cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper = nvl(pr_cdcooper, cop.cdcooper); -- Ativo
  
  CURSOR cr_contrato(pr_cdcooper crapepr.cdcooper%TYPE
                    ,pr_dtrefere crapvri.dtrefere%TYPE
                    ) IS
    SELECT tab.cdcooper
          ,tab.nrdconta
          ,tab.nrctremp
          ,tab.vldivida
          ,tab.vlempres
          ,tab.vlempres/tab.vldivida vldifere
          ,MIN(pep.dtvencto) dtvencto
          ,MIN(pep.dtvencto) + 59 dt59dias
          ,pr_dtrefere - MIN(pep.dtvencto) qtdiavnc
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
               AND vri.dtrefere = pr_dtrefere
             GROUP BY vri.cdcooper
                     ,vri.nrdconta
                     ,vri.nrctremp
          ) tab
          ,crappep pep
     WHERE pep.cdcooper = tab.cdcooper
       AND pep.nrdconta = tab.nrdconta
       AND pep.nrctremp = tab.nrctremp
       AND (pep.inliquid = 0 OR pep.inprejuz = 1)
       AND pep.dtvencto <= pr_dtrefere
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
                   ,pr_dtrefere crapris.dtrefere%TYPE
                   ) IS
    SELECT ris.vldivida
          ,ris.vldivida - ris.vljura60 - ris.vljurantpp totempre
      FROM crapris ris
     WHERE ris.cdcooper = pr_cdcooper
       AND ris.nrdconta = pr_nrdconta
       AND ris.nrctremp = pr_nrctremp
       AND ris.dtrefere = pr_dtrefere;
  --
  CURSOR cr_crapvri(pr_cdcooper crapvri.cdcooper%TYPE
                   ,pr_nrdconta crapvri.nrdconta%TYPE
                   ,pr_nrctremp crapvri.nrctremp%TYPE
                   ,pr_dtrefere crapvri.dtrefere%TYPE
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
       AND vri.dtrefere = pr_dtrefere;
  --
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  --
  rw_crapvri cr_crapvri%ROWTYPE;
  --
  vr_cdcooper NUMBER := NULL; -- Trocar para NULL se for executar para todas as cooperativas
  vr_dtrefere DATE   := '31/03/2020'; -- Trocar para a data desejada
  vr_vldivida NUMBER;
  vr_totempre NUMBER;
  vr_vlempres NUMBER;
  vr_vleprtot NUMBER;
  --
BEGIN
  --
  FOR rw_crapcop IN cr_crapcop(pr_cdcooper => vr_cdcooper
                              ) LOOP
    --
    FOR rw_contrato IN cr_contrato(pr_cdcooper => rw_crapcop.cdcooper
                                  ,pr_dtrefere => vr_dtrefere
                                  ) LOOP
      --
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => rw_contrato.cdcooper
                                  ,pr_nrdconta => rw_contrato.nrdconta
                                  ,pr_nrctremp => rw_contrato.nrctremp
                                  ) LOOP
        --
        OPEN cr_crapris(rw_crapepr.cdcooper
                       ,rw_crapepr.nrdconta
                       ,rw_crapepr.nrctremp
                       ,vr_dtrefere
                       );
        FETCH cr_crapris INTO vr_vldivida, vr_totempre;
        CLOSE cr_crapris;
        --
        vr_vleprtot := 0;
        --
        OPEN cr_crapvri(rw_crapepr.cdcooper
                       ,rw_crapepr.nrdconta
                       ,rw_crapepr.nrctremp
                       ,vr_dtrefere
                       );
        LOOP
          --
          FETCH cr_crapvri INTO rw_crapvri;
          EXIT WHEN cr_crapvri%NOTFOUND;
          --
          vr_vlempres := ROUND((rw_crapvri.vldivida / vr_vldivida) * vr_totempre, 2);
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
        vr_vleprtot := vr_totempre - vr_vleprtot;
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
