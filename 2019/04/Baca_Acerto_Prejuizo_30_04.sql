BEGIN
-- ================================================================================================= 1
DECLARE
/* o script foi montado com base na PC_CRPS002 - PCVERIFICA_CONTA_PREJUIZO */
  pr_cdcooper   craplcm.cdcooper%TYPE := 1;
  pr_nrdconta   craplcm.nrdconta%TYPE := 9451404;
  pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
  pr_vllanmto   craplcm.vllanmto%TYPE := 8.34;
--  pr_cdhistor IN  craplcm.cdhistor%TYPE
  pr_nrdocmto   craplcm.nrdocmto%type := 1;
  pr_cdagenci   craplcm.cdagenci%type := 1;
  pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
  pr_cdoperad   craplcm.cdoperad%TYPE := 1;
--  pr_nrdctabb IN  craplcm.nrdctabb%TYPE
  pr_cdcritic   NUMBER;
  pr_dscritic   VARCHAR2(10000);

  vr_nrseqdig       craplot.nrseqdig%TYPE;   -- Aramazena o valor do campo "nrseqdig" da CRAPLOT para referência na CRAPLCM
  vr_tab_retorno    lanc0001.typ_reg_retorno;
  vr_incrineg       INTEGER;
  vr_exc_saida      EXCEPTION;

begin
    BEGIN
      SELECT dtmvtolt
        INTO pr_dtmvtolt
        FROM crapdat
       WHERE cdcooper = pr_cdcooper;
    EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao buscar DTMVTOLT = '||SQLERRM;
    END;
    --
      -- Gera valor do campo "nrseqdig" a partir da sequence (para não usar CRAPLOT)
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(pr_dtmvtolt, 'DD/MM/RRRR') ||';'||
                                '1;100;650010');

    INSERT INTO craplcm (
        dtmvtolt
      , cdagenci
      , cdbccxlt
      , nrdolote
      , nrdconta
      , nrdocmto
      , cdhistor
      , nrseqdig
      , vllanmto
      , nrdctabb
      , cdpesqbb
      , vldoipmf
      , nrautdoc
      , nrsequni
      , cdbanchq
      , cdcmpchq
      , cdagechq
      , nrctachq
      , nrlotchq
      , sqlotchq
      , dtrefere
      , hrtransa
      , cdoperad
      , dsidenti
      , cdcooper
      , nrdctitg
      , dscedent
      , cdcoptfn
      , cdagetfn
      , nrterfin
      , nrparepr
      , nrseqava
      , nraplica
      , cdorigem
      , idlautom
    )
    VALUES (
        pr_dtmvtolt
      , 1      -- pr_cdagenci
      , 100    -- pr_cdbccxlt
      , 650010 -- pr_nrdolote
      , pr_nrdconta
      , pr_nrdocmto
      , 2720 -- pr_cdhistor
      , vr_nrseqdig
      , pr_vllanmto
      , 0 -- pr_nrdctabb
      , ' ' -- pr_cdpesqbb
      , 0 -- pr_vldoipmf
      , 0 -- pr_nrautdoc
      , 0 -- pr_nrsequni
      , 0 -- pr_cdbanchq
      , 0 -- pr_cdcmpchq
      , 0 -- pr_cdagechq
      , 0 -- pr_nrctachq
      , 0 -- pr_nrlotchq
      , 0 -- pr_sqlotchq
      , NULL -- pr_dtrefere
      , 0 -- pr_hrtransa
      , pr_cdoperad
      , ' ' -- pr_dsidenti
      , pr_cdcooper
      , ' ' -- pr_nrdctitg
      , ' ' -- pr_dscedent
      , 0 -- pr_cdcoptfn
      , 0 -- pr_cdagetfn
      , 0 -- pr_nrterfin
      , 0 -- pr_nrparepr
      , 0 -- pr_nrseqava
      , 0 -- pr_nraplica
      , 0 -- pr_cdorigem
      , 0 -- pr_idlautom
    );
    COMMIT;
  EXCEPTION
  WHEN vr_exc_saida THEN
    if pr_cdcritic is not null and pr_dscritic is null then
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    end if;
    rollback;
    RAISE_APPLICATION_ERROR(-20500,pr_dscritic);
  WHEN OTHERS THEN
    pr_dscritic := 'Erro ao atualizar CRAPSLD = '||SQLERRM;
    RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
end;
-- ================================================================================================= 2
DECLARE
  pr_cdcooper   craplcm.cdcooper%TYPE := 9;
  pr_nrdconta   craplcm.nrdconta%TYPE := 131725;
  pr_vllanmto   craplcm.vllanmto%TYPE := 282;
  pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
--  pr_cdhistor IN  craplcm.cdhistor%TYPE
  pr_nrdocmto   craplcm.nrdocmto%type := 1;
  pr_cdagenci   craplcm.cdagenci%type := 1;
  pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
--  pr_nrdctabb IN  craplcm.nrdctabb%TYPE
  pr_cdcritic   NUMBER;
  pr_dscritic   VARCHAR2(10000);
  --
  vr_dthrtran   DATE := SYSDATE;
  vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;
  --
  vr_exc_saida  EXCEPTION;
BEGIN
  BEGIN
    SELECT dtmvtolt
      INTO pr_dtmvtolt
      FROM crapdat
     WHERE cdcooper = pr_cdcooper;
  EXCEPTION
  WHEN OTHERS THEN
    pr_dscritic := 'Erro ao buscar DTMVTOLT = '||SQLERRM;
    RAISE vr_exc_saida;
  END;
  --
  UPDATE tbcc_prejuizo a
     SET vlsdprej = nvl(vlsdprej, 0) - pr_vllanmto
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
  RETURNING a.idprejuizo INTO vr_idprejuizo;
  --
  -- Lança débito referente ao pagamento do prejuízo
  PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                          , pr_nrdconta => pr_nrdconta
                          , pr_dtmvtolt => pr_dtmvtolt
                          , pr_cdhistor => 2721
                          , pr_idprejuizo => vr_idprejuizo
                          , pr_vllanmto => pr_vllanmto
                          , pr_dthrtran => vr_dthrtran
                          , pr_cdcritic => pr_cdcritic
                          , pr_dscritic => pr_dscritic);
  IF NVL(pr_cdcritic,0) > 0
  OR pr_dscritic IS NOT NULL
  THEN
    RAISE vr_exc_saida;
  END IF;
  -- Lança crédito referente ao pagamento do prejuízo
  PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                          , pr_nrdconta => pr_nrdconta
                          , pr_dtmvtolt => pr_dtmvtolt
                          , pr_cdhistor => 2733
                          , pr_idprejuizo => vr_idprejuizo
                          , pr_vllanmto => pr_vllanmto
                          , pr_dthrtran => vr_dthrtran
                          , pr_cdcritic => pr_cdcritic
                          , pr_dscritic => pr_dscritic);
  IF NVL(pr_cdcritic,0) > 0
  OR pr_dscritic IS NOT NULL
  THEN
    RAISE vr_exc_saida;
  END IF;
  -- Valor pago do saldo devedor principal do prejuízo
  PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                         , pr_nrdconta => pr_nrdconta
                         , pr_dtmvtolt => pr_dtmvtolt
                         , pr_cdhistor => 2725
                         , pr_idprejuizo => vr_idprejuizo
                         , pr_vllanmto => pr_vllanmto
                         , pr_dthrtran => vr_dthrtran
                         , pr_cdcritic => pr_cdcritic
                         , pr_dscritic => pr_dscritic);
  IF NVL(pr_cdcritic,0) > 0
  OR pr_dscritic IS NOT NULL
  THEN
    RAISE vr_exc_saida;
  END IF;
  --
  COMMIT;
EXCEPTION
WHEN vr_exc_saida THEN
  if pr_cdcritic is not null and pr_dscritic is null then
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
  end if;
  rollback;
  RAISE_APPLICATION_ERROR(-20500,pr_dscritic);
WHEN OTHERS THEN
  pr_dscritic := 'Erro ao atualizar CRAPSLD = '||SQLERRM;
  RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
end;
-- ================================================================================================= 3
 --
-- Ajuste de saldo de contas com movimentos gerados indevidamente em prejuizo
--
declare
  CURSOR cr_nrdocmto(pr_cdcooper NUMBER
                   , pr_nrdconta NUMBER) IS
  SELECT nvl(MAX(nrdocmto), 0) + 1 nrdocmto
    FROM craplem
   WHERE cdcooper = pr_cdcooper
     AND dtmvtolt = TRUNC(SYSDATE)
     AND cdagenci = 1
     AND cdbccxlt = 100
     AND nrdolote = 600029
     AND nrdconta = pr_nrdconta
  ;

  CURSOR cr_nrseqdig(pr_cdcooper NUMBER) IS
  SELECT nvl(MAX(nrseqdig), 0) + 1 nrseqdig
    FROM craplem
   WHERE cdcooper = pr_cdcooper
     AND dtmvtolt = TRUNC(SYSDATE)
     AND cdagenci = 1
     AND cdbccxlt = 100
     AND nrdolote = 600029
  ;
  pr_cdcooper   craplcm.cdcooper%TYPE := 1;
  pr_nrdconta   craplcm.nrdconta%TYPE := 8116407;
  pr_vllanmto   NUMBER := 6008.00;
  vr_nrdocmto  NUMBER(18);
  vr_nrseqdig  NUMBER(18);
  vr_cdhistor  NUMBER(18);
  vr_vlpago    NUMBER(18,4);
-------------------------------------
BEGIN

  FOR rw_craplem IN
  (SELECT cdcooper
        , nrdconta
        , nrctremp
        , cdagenci
        , cdbccxlt
        , nrdolote
        , cdhistor
        , vllanmto
        , cdorigem
        , progress_recid
     FROM craplem
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta
      AND nrctremp IN (1016475)
      AND dtmvtolt BETWEEN to_date('30/04/2019', 'DD/MM/YYYY') AND to_date('30/04/2019', 'DD/MM/YYYY')
      AND cdhistor IN (2701, 2388, 2390, 2473, 2389, 2475)
  ) LOOP
    OPEN cr_nrdocmto(rw_craplem.cdcooper
                   , rw_craplem.nrdconta);
    FETCH cr_nrdocmto INTO vr_nrdocmto;
    CLOSE cr_nrdocmto;

    OPEN cr_nrseqdig(rw_craplem.cdcooper);
    FETCH cr_nrseqdig INTO vr_nrseqdig;
    CLOSE cr_nrseqdig;

    IF rw_craplem.cdhistor = 2701 THEN
      vr_cdhistor := 2702;
    ELSIF rw_craplem.cdhistor = 2388 THEN
      vr_cdhistor := 2392;
    ELSIF rw_craplem.cdhistor = 2390 THEN
      vr_cdhistor := 2394;
    ELSIF rw_craplem.cdhistor = 2473 THEN
      vr_cdhistor := 2474;
    ELSIF rw_craplem.cdhistor = 2389 THEN
      vr_cdhistor := 2393;
    ELSIF rw_craplem.cdhistor = 2475 THEN
      vr_cdhistor := 2476;
    END IF;

    INSERT INTO craplem (
        dtmvtolt
      , cdagenci
      , cdbccxlt
      , nrdolote
      , nrdconta
      , nrdocmto
      , cdhistor
      , nrseqdig
      , nrctremp
      , vllanmto
      , dtpagemp
      , dthrtran
      , cdorigem
      , cdcooper
    )
    VALUES (
        trunc(SYSDATE)
      , rw_craplem.cdagenci
      , rw_craplem.cdbccxlt
      , rw_craplem.nrdolote
      , rw_craplem.nrdconta
      , vr_nrdocmto
      , vr_cdhistor
      , vr_nrseqdig
      , rw_craplem.nrctremp
      , rw_craplem.vllanmto
      , TRUNC(SYSDATE)
      , SYSDATE
      , rw_craplem.cdorigem
      , rw_craplem.cdcooper
    );

    UPDATE craplem
       SET dtestorn = trunc(SYSDATE)
     WHERE progress_recid = rw_craplem.progress_recid;

    IF rw_craplem.cdhistor = 2701 THEN
      UPDATE crapepr e
         SET vlpgjmpr = 0
           , vlpgmupr = 0
           , vlsdprej = vlsdprej + rw_craplem.vllanmto
           , inliquid = 0
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = rw_craplem.nrctremp;
    END IF;
  END LOOP rw_craplem;
  --
  -- Retirar do saldo prejuízo a Multa e Juros de Mora que já havian sido cobrados no histórico 2701.
  UPDATE crapepr e
     SET vlsdprej = vlsdprej - (103.73+347.87)
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
     AND nrctremp = 1016475;
  --
  DECLARE
    vr_nrdolote NUMBER;
    vr_des_reto VARCHAR2(1000);
    vr_tab_erro             gene0001.typ_tab_erro ;
    vr_exc_saida EXCEPTION;
  pr_cdcritic   NUMBER;
  pr_dscritic   VARCHAR2(10000);
    --
    -- Buscar proximo Lote
    CURSOR c_busca_prx_lote(pr_dtmvtolt DATE
                           ,pr_cdcooper NUMBER
                           ,pr_cdagenci NUMBER) IS
      SELECT MAX(nrdolote) nrdolote
        FROM craplot
       WHERE craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdcooper = pr_cdcooper
         AND craplot.cdagenci = pr_cdagenci;
  BEGIN
      OPEN c_busca_prx_lote(pr_dtmvtolt => TRUNC(sysdate)
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1);
      fetch c_busca_prx_lote into vr_nrdolote;
      close c_busca_prx_lote;

      vr_nrdolote := nvl(vr_nrdolote,0) + 1;
      --
      empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => trunc(sysdate)
                                    ,pr_cdagenci => 1
                                    ,pr_cdbccxlt => 100
                                    ,pr_cdoperad => '1'
                                    ,pr_cdpactra => 1
                                    ,pr_nrdolote => vr_nrdolote
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_cdhistor => 2387 -- EST.RECUP.PREJUIZO
                                    ,pr_vllanmto => pr_vllanmto
                                    ,pr_nrparepr => 0
                                    ,pr_nrctremp => 1016475
                                    ,pr_nrseqava => 0
                                    ,pr_idlautom => 0
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro );

      IF vr_des_reto <> 'OK' THEN
        IF vr_tab_erro.count() > 0 THEN
          -- Atribui críticas às variaveis
          pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          pr_dscritic := 'Falha estorno Pagamento '||vr_tab_erro(vr_tab_erro.first).dscritic;
          RAISE vr_exc_saida;
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := 'Falha ao Estornar Pagamento '||sqlerrm;
          raise vr_exc_saida;
        END IF;
      END IF;
  EXCEPTION
  WHEN vr_exc_saida THEN
    if pr_cdcritic is not null and pr_dscritic is null then
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    end if;
    rollback;
    RAISE_APPLICATION_ERROR(-20500,pr_dscritic);
  WHEN OTHERS THEN
    pr_dscritic := 'Erro ao atualizar CRAPSLD = '||SQLERRM;
    RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
  END;
  --
  COMMIT;
end;
-- ================================================================================================= 4
 --
-- Ajuste de saldo de contas com movimentos gerados indevidamente em prejuizo
--
declare
  CURSOR cr_nrdocmto(pr_cdcooper NUMBER
                   , pr_nrdconta NUMBER) IS
  SELECT nvl(MAX(nrdocmto), 0) + 1 nrdocmto
    FROM craplem
   WHERE cdcooper = pr_cdcooper
     AND dtmvtolt = TRUNC(SYSDATE)
     AND cdagenci = 1
     AND cdbccxlt = 100
     AND nrdolote = 600029
     AND nrdconta = pr_nrdconta
  ;

  CURSOR cr_nrseqdig(pr_cdcooper NUMBER) IS
  SELECT nvl(MAX(nrseqdig), 0) + 1 nrseqdig
    FROM craplem
   WHERE cdcooper = pr_cdcooper
     AND dtmvtolt = TRUNC(SYSDATE)
     AND cdagenci = 1
     AND cdbccxlt = 100
     AND nrdolote = 600029
  ;
  pr_cdcooper   craplcm.cdcooper%TYPE := 1;
  pr_nrdconta   craplcm.nrdconta%TYPE := 8812845;
  pr_vllanmto   NUMBER := 2034.68;
  vr_nrdocmto  NUMBER(18);
  vr_nrseqdig  NUMBER(18);
  vr_cdhistor  NUMBER(18);
  vr_vlpago    NUMBER(18,4);
-------------------------------------
BEGIN

  FOR rw_craplem IN
  (SELECT cdcooper
        , nrdconta
        , nrctremp
        , cdagenci
        , cdbccxlt
        , nrdolote
        , cdhistor
        , vllanmto
        , cdorigem
        , progress_recid
     FROM craplem
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta
      AND nrctremp IN (1092658)
      AND dtmvtolt BETWEEN to_date('30/04/2019', 'DD/MM/YYYY') AND to_date('30/04/2019', 'DD/MM/YYYY')
      AND cdhistor IN (2701, 2388, 2390, 2473, 2389, 2475)
  ) LOOP
    OPEN cr_nrdocmto(rw_craplem.cdcooper
                   , rw_craplem.nrdconta);
    FETCH cr_nrdocmto INTO vr_nrdocmto;
    CLOSE cr_nrdocmto;

    OPEN cr_nrseqdig(rw_craplem.cdcooper);
    FETCH cr_nrseqdig INTO vr_nrseqdig;
    CLOSE cr_nrseqdig;

    IF rw_craplem.cdhistor = 2701 THEN
      vr_cdhistor := 2702;
    ELSIF rw_craplem.cdhistor = 2388 THEN
      vr_cdhistor := 2392;
    ELSIF rw_craplem.cdhistor = 2390 THEN
      vr_cdhistor := 2394;
    ELSIF rw_craplem.cdhistor = 2473 THEN
      vr_cdhistor := 2474;
    ELSIF rw_craplem.cdhistor = 2389 THEN
      vr_cdhistor := 2393;
    ELSIF rw_craplem.cdhistor = 2475 THEN
      vr_cdhistor := 2476;
    END IF;

    INSERT INTO craplem (
        dtmvtolt
      , cdagenci
      , cdbccxlt
      , nrdolote
      , nrdconta
      , nrdocmto
      , cdhistor
      , nrseqdig
      , nrctremp
      , vllanmto
      , dtpagemp
      , dthrtran
      , cdorigem
      , cdcooper
    )
    VALUES (
        trunc(SYSDATE)
      , rw_craplem.cdagenci
      , rw_craplem.cdbccxlt
      , rw_craplem.nrdolote
      , rw_craplem.nrdconta
      , vr_nrdocmto
      , vr_cdhistor
      , vr_nrseqdig
      , rw_craplem.nrctremp
      , rw_craplem.vllanmto
      , TRUNC(SYSDATE)
      , SYSDATE
      , rw_craplem.cdorigem
      , rw_craplem.cdcooper
    );

    UPDATE craplem
       SET dtestorn = trunc(SYSDATE)
     WHERE progress_recid = rw_craplem.progress_recid;

    IF rw_craplem.cdhistor = 2701 THEN
      UPDATE crapepr e
         SET vlpgjmpr = 0
           , vlpgmupr = 0
           , vlsdprej = vlsdprej + rw_craplem.vllanmto
           , inliquid = 0
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = rw_craplem.nrctremp;
    END IF;
  END LOOP rw_craplem;
  --
  --
  -- Retirar do saldo prejuízo a Multa e Juros de Mora que já havian sido cobrados no histórico 2701.
  UPDATE crapepr e
     SET vlsdprej = vlsdprej - (16.60+49.05)
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
     AND nrctremp = 1092658;
  --
  DECLARE
    vr_nrdolote NUMBER;
    vr_des_reto VARCHAR2(1000);
    vr_tab_erro             gene0001.typ_tab_erro ;
    vr_exc_saida EXCEPTION;
  pr_cdcritic   NUMBER;
  pr_dscritic   VARCHAR2(10000);
    --
    -- Buscar proximo Lote
    CURSOR c_busca_prx_lote(pr_dtmvtolt DATE
                           ,pr_cdcooper NUMBER
                           ,pr_cdagenci NUMBER) IS
      SELECT MAX(nrdolote) nrdolote
        FROM craplot
       WHERE craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdcooper = pr_cdcooper
         AND craplot.cdagenci = pr_cdagenci;
  BEGIN
      OPEN c_busca_prx_lote(pr_dtmvtolt => TRUNC(sysdate)
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1);
      fetch c_busca_prx_lote into vr_nrdolote;
      close c_busca_prx_lote;

      vr_nrdolote := nvl(vr_nrdolote,0) + 1;
      --
      -- Gera valor do campo "nrseqdig" a partir da sequence (para não usar CRAPLOT)
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(TRUNC(SYSDATE), 'DD/MM/RRRR') ||';'||
                                '1;100;650010');
      --
      INSERT INTO craplcm (
        dtmvtolt
      , cdagenci
      , cdbccxlt
      , nrdolote
      , nrdconta
      , nrdocmto
      , cdhistor
      , nrseqdig
      , vllanmto
      , nrdctabb
      , cdpesqbb
      , vldoipmf
      , nrautdoc
      , nrsequni
      , cdbanchq
      , cdcmpchq
      , cdagechq
      , nrctachq
      , nrlotchq
      , sqlotchq
      , dtrefere
      , hrtransa
      , cdoperad
      , dsidenti
      , cdcooper
      , nrdctitg
      , dscedent
      , cdcoptfn
      , cdagetfn
      , nrterfin
      , nrparepr
      , nrseqava
      , nraplica
      , cdorigem
      , idlautom
    )
    VALUES (
        TRUNC(SYSDATE)
      , 1      -- pr_cdagenci
      , 100    -- pr_cdbccxlt
      , vr_nrdolote
      , pr_nrdconta
      , 1092658
      , 2387 -- pr_cdhistor
      , vr_nrseqdig
      , pr_vllanmto
      , 8812845
      , ' ' -- pr_cdpesqbb
      , 0 -- pr_vldoipmf
      , 0 -- pr_nrautdoc
      , 0 -- pr_nrsequni
      , 0 -- pr_cdbanchq
      , 0 -- pr_cdcmpchq
      , 0 -- pr_cdagechq
      , 0 -- pr_nrctachq
      , 0 -- pr_nrlotchq
      , 0 -- pr_sqlotchq
      , NULL -- pr_dtrefere
      , 0 -- pr_hrtransa
      , '1'
      , ' ' -- pr_dsidenti
      , pr_cdcooper
      , ' ' -- pr_nrdctitg
      , ' ' -- pr_dscedent
      , 0 -- pr_cdcoptfn
      , 0 -- pr_cdagetfn
      , 0 -- pr_nrterfin
      , 0 -- pr_nrparepr
      , 0 -- pr_nrseqava
      , 0 -- pr_nraplica
      , 0 -- pr_cdorigem
      , 0 -- pr_idlautom
    );
  EXCEPTION
  WHEN vr_exc_saida THEN
    if pr_cdcritic is not null and pr_dscritic is null then
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    end if;
    rollback;
    RAISE_APPLICATION_ERROR(-20500,pr_dscritic);
  WHEN OTHERS THEN
    pr_dscritic := 'Erro ao atualizar CRAPSLD = '||SQLERRM;
    RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
  END;
  --
  COMMIT;
end;
-- ================================================================================================= 5
-- ================================================================================================= 6
-- ================================================================================================= 7
-- ================================================================================================= 8
-- ================================================================================================= 9
-- ================================================================================================= 10
-- ================================================================================================= 11
-- ================================================================================================= 12
END;
