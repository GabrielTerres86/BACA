PL/SQL Developer Test script 3.0
184
DECLARE

  --  
  vr_cntigual NUMBER;
  vr_cntdiff  NUMBER;
  vr_excupdt  NUMBER := 1; -- (0 não faz o update, 1 faz o update)
  --
  CURSOR cr_crapepr IS
    SELECT epr.cdcooper,
           epr.nrdconta,
           epr.nrctremp,
           epr.vlsdeved,
           ris.vldivida,
           ris.vljura60,
           epr.vlsdevat,
           DECODE(lcr.dsoperac,
                  'FINANCIAMENTO',
                  'FINANCIAMENTO',
                  'EMPRESTIMO') dsoperac,
           epr.dtmvtolt,
           ass.inpessoa,
           ass.cdagenci
      FROM crapepr epr, crapris ris, crapdat dat, craplcr lcr, crapass ass
     WHERE epr.cdcooper = ris.cdcooper
       AND epr.nrdconta = ris.nrdconta
       AND epr.nrctremp = ris.nrctremp
       AND epr.cdcooper = dat.cdcooper
       AND ris.dtrefere = dat.dtultdma
       AND epr.tpemprst = 2
       AND epr.inliquid = 0
       AND ris.cdcooper >= 1
       AND lcr.cdcooper = epr.cdcooper
       AND lcr.cdlcremp = epr.cdlcremp
       AND ass.cdcooper = ris.cdcooper
       AND ass.nrdconta = ris.nrdconta;
  --
  CURSOR cr_lem_his(pr_cdcooper IN crappep.cdcooper%TYPE,
                    pr_nrdconta IN crappep.nrdconta%TYPE,
                    pr_nrctremp IN crappep.nrctremp%TYPE) IS
    SELECT SUM(CASE
                 WHEN craphis.indebcre = 'C' THEN
                  craplem.vllanmto
                 WHEN craphis.indebcre = 'D' THEN
                  craplem.vllanmto * -1
               END) vlsldlem
      FROM craplem
      JOIN craphis
        ON (craphis.cdcooper = craplem.cdcooper AND
           craphis.cdhistor = craplem.cdhistor)
      JOIN crapdat
        ON (craplem.cdcooper = crapdat.cdcooper)
     WHERE craplem.cdcooper = pr_cdcooper
       AND craplem.nrdconta = pr_nrdconta
       AND craplem.nrctremp = pr_nrctremp
       AND craplem.dtmvtolt <= crapdat.dtultdma
       AND craplem.cdhistor NOT IN (2365,
                                    2363,
                                    2349,
                                    2348 -- Multa
                                   ,
                                    2367,
                                    2369 -- Multa Aval
                                   ,
                                    2375,
                                    2377 -- Juros de Mora Aval
                                   ,
                                    2566,
                                    2567 -- Desconto
                                   ,
                                    2540,
                                    2539,
                                    2607,
                                    2608); -- IOF
  rw_lem_his cr_lem_his%ROWTYPE;
  --

  CURSOR cr_craplem(pr_cdcooper IN crappep.cdcooper%TYPE,
                    pr_nrdconta IN crappep.nrdconta%TYPE,
                    pr_nrctremp IN crappep.nrctremp%TYPE) IS
    SELECT SUM(CASE
                 WHEN craphis.indebcre = 'C' THEN
                  craplem.vllanmto
                 WHEN craphis.indebcre = 'D' THEN
                  craplem.vllanmto * -1
               END) vlsldlem
      FROM craplem
      JOIN craphis
        ON (craphis.cdcooper = craplem.cdcooper AND
           craphis.cdhistor = craplem.cdhistor)
      JOIN crapdat
        ON (craplem.cdcooper = crapdat.cdcooper)
     WHERE craplem.cdcooper = pr_cdcooper
       AND craplem.nrdconta = pr_nrdconta
       AND craplem.nrctremp = pr_nrctremp
       AND craplem.cdhistor NOT IN (2365,
                                    2363,
                                    2349,
                                    2348 -- Multa
                                   ,
                                    2367,
                                    2369 -- Multa Aval
                                   ,
                                    2375,
                                    2377 -- Juros de Mora Aval
                                   ,
                                    2566,
                                    2567 -- Desconto
                                   ,
                                    2540,
                                    2539,
                                    2607,
                                    2608); -- IOF
  rw_craplem cr_craplem%ROWTYPE;

BEGIN

  dbms_output.enable(1000000);

  vr_cntigual := 0;
  vr_cntdiff  := 0;

  FOR rw_crapepr IN cr_crapepr LOOP
  
    -- Busca o extrato
    OPEN cr_lem_his(rw_crapepr.cdcooper,
                    rw_crapepr.nrdconta,
                    rw_crapepr.nrctremp);
    FETCH cr_lem_his
      INTO rw_lem_his;
  
    OPEN cr_craplem(rw_crapepr.cdcooper,
                    rw_crapepr.nrdconta,
                    rw_crapepr.nrctremp);
    FETCH cr_craplem
      INTO rw_craplem;
  
    -- Ignora os registros que apresentaram diferença menor que 10 centavos
    IF (abs(rw_crapepr.vldivida + rw_lem_his.vlsldlem) > 0.1) THEN
    
      vr_cntdiff := vr_cntdiff + 1;
    
      dbms_output.put_line('UPDATE crapepr p SET p.vlsdeved = ' ||
                           REPLACE(rw_crapepr.vlsdeved, ',', '.') ||
                           ' WHERE p.cdcooper = ' || rw_crapepr.cdcooper ||
                           ' AND p.nrdconta = ' || rw_crapepr.nrdconta ||
                           ' AND p.nrctremp = ' || rw_crapepr.nrctremp);
    
      IF vr_excupdt = 1 THEN
        UPDATE crapepr p
           SET p.vlsdeved =
               (rw_craplem.vlsldlem * -1)
         WHERE p.cdcooper = rw_crapepr.cdcooper
           AND p.nrdconta = rw_crapepr.nrdconta
           AND p.nrctremp = rw_crapepr.nrctremp;
      END IF;
      /*
       dbms_output.put_line(rw_crapepr.cdcooper -- Cooperativa
                             || ';' || rw_crapepr.nrdconta -- Conta 
                             || ';' || rw_crapepr.nrctremp -- Contrato
                             || ';' ||  rw_craplem.vlsldlem * -1
                             );
      */
    ELSE
      vr_cntigual := vr_cntigual + 1;
    END IF;
  
    CLOSE cr_lem_his;
  
    CLOSE cr_craplem;
    --
  END LOOP;

  IF vr_excupdt = 1 THEN
    COMMIT;
  END IF;
  --

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro: ' || SQLERRM);
    ROLLBACK;
    CLOSE cr_lem_his;
    CLOSE cr_craplem;
END;
0
0
