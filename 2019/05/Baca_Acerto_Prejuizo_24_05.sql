BEGIN
-- ================================================================================================= 1
  begin
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE idlancto IN (26807);
    --
    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - 9.9
     WHERE cdcooper = 1
       AND nrdconta = 7203985;
  end;
-- ================================================================================================= 2
  begin
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE idlancto IN (26808);
    --
    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - 9.9
     WHERE cdcooper = 1
       AND nrdconta = 8760250;
  end;
-- ================================================================================================= 3
  begin
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE idlancto IN (26806);
    --
    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - 9.9
     WHERE cdcooper = 7
       AND nrdconta = 54976;
  end;
-- ================================================================================================= 4
  DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 1;
    pr_nrdconta   craplcm.nrdconta%TYPE := 2079127;
    pr_vllanmto   craplcm.vllanmto%TYPE := 0.17;
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
       SET vlsdprej = 0
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
    --
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
-- ================================================================================================= 5
  DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 13;
    pr_nrdconta   craplcm.nrdconta%TYPE := 80616;
    pr_vllanmto   craplcm.vllanmto%TYPE := 592.64;
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
       SET vlsdprej = 0
          ,vljuprej = 0
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
    --
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
-- ================================================================================================= 6
  DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 9;
    pr_nrdconta   craplcm.nrdconta%TYPE := 47899;
    pr_vllanmto   craplcm.vllanmto%TYPE := 1601.53;
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
       SET vlsdprej = nvl(vlsdprej, 0) + pr_vllanmto
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
    RETURNING a.idprejuizo INTO vr_idprejuizo;
    --
    -- Lança débito referente ao pagamento do prejuízo
    PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                            , pr_nrdconta => pr_nrdconta
                            , pr_dtmvtolt => pr_dtmvtolt
                            , pr_cdhistor => 2722
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
                            , pr_cdhistor => 2732
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
                           , pr_cdhistor => 2726
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
-- ================================================================================================= 7
  DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 1;
    pr_nrdconta   craplcm.nrdconta%TYPE := 7662050;
    pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
  --  pr_cdhistor IN  craplcm.cdhistor%TYPE
    pr_nrdocmto   craplcm.nrdocmto%type := 1;
    pr_cdagenci   craplcm.cdagenci%type := 1;
    pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
    pr_vllanmto   craplcm.vllanmto%TYPE := 684.15;
    pr_nrdctabb   craplcm.nrdctabb%TYPE := 7662050;
    pr_cdcritic   NUMBER;
    pr_dscritic   VARCHAR2(10000);

    vr_exc_saida      EXCEPTION;

  BEGIN
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
    prej0003.pc_gera_transf_cta_prj(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_cdoperad => 1
                                   ,pr_vllanmto => pr_vllanmto
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_versaldo => 0 -- pr_versaldo
                                   ,pr_atsldlib => 0 -- pr_atsldlib
                                   ,pr_cdcritic => pr_cdcritic
                                   ,pr_dscritic => pr_dscritic);
    if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
      RAISE vr_exc_saida;
    end if;
    --
  EXCEPTION
  WHEN vr_exc_saida THEN
    if pr_cdcritic is not null and pr_dscritic is null then
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    end if;
    rollback;
    RAISE_APPLICATION_ERROR(-20500,pr_dscritic);
  WHEN OTHERS THEN
    pr_dscritic := 'Erro ao atualizar CRAPSLD = '||SQLERRM;
    rollback;
    RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
  end;
-- ================================================================================================= 8
  DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 1;
    pr_nrdconta   craplcm.nrdconta%TYPE := 9938;
    pr_vllanmto   craplcm.vllanmto%TYPE := 978.51;
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
       SET dtliquidacao = null
          ,vlsdprej = 3403.81 + pr_vllanmto
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
    RETURNING a.idprejuizo INTO vr_idprejuizo;
    --
    PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                           , pr_nrdconta => pr_nrdconta
                           , pr_dtmvtolt => pr_dtmvtolt
                           , pr_cdhistor => 2408
                           , pr_idprejuizo => vr_idprejuizo
                           , pr_vllanmto => pr_vllanmto
                           , pr_cdcritic => pr_cdcritic
                           , pr_dscritic => pr_dscritic);
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
-- ================================================================================================= 9
  BEGIN
    UPDATE tbcc_prejuizo a
       SET vlsdprej = 0
     WHERE cdcooper = 7
       AND nrdconta = 15946;
  END;
-- ================================================================================================= 10
  DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 10;
    pr_nrdconta   craplcm.nrdconta%TYPE := 73563;
    pr_vllanmto   craplcm.vllanmto%TYPE := 107.07;
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
       SET vlsdprej = nvl(vlsdprej, 0) + pr_vllanmto
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
    RETURNING a.idprejuizo INTO vr_idprejuizo;
    --
    -- Lança débito referente ao pagamento do prejuízo
    PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                            , pr_nrdconta => pr_nrdconta
                            , pr_dtmvtolt => pr_dtmvtolt
                            , pr_cdhistor => 2722
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
                            , pr_cdhistor => 2732
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
-- ================================================================================================= 11
  DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 7;
    pr_nrdconta   craplcm.nrdconta%TYPE := 127124;
    pr_vllanmto   craplcm.vllanmto%TYPE := 1938.61;
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
       SET vlsdprej = nvl(vlsdprej, 0) + pr_vllanmto
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
    RETURNING a.idprejuizo INTO vr_idprejuizo;
    --
    -- Lança débito referente ao pagamento do prejuízo
    PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                            , pr_nrdconta => pr_nrdconta
                            , pr_dtmvtolt => pr_dtmvtolt
                            , pr_cdhistor => 2722
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
                            , pr_cdhistor => 2732
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
-- ================================================================================================= 12
  DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 9;
    pr_nrdconta   craplcm.nrdconta%TYPE := 39101;
    pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
  --  pr_cdhistor IN  craplcm.cdhistor%TYPE
    pr_nrdocmto   craplcm.nrdocmto%type := 1;
    pr_cdagenci   craplcm.cdagenci%type := 1;
    pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
    pr_vllanmto   craplcm.vllanmto%TYPE := 424.46;
    pr_nrdctabb   craplcm.nrdctabb%TYPE := 39101;
    pr_cdcritic   NUMBER;
    pr_dscritic   VARCHAR2(10000);

    vr_exc_saida      EXCEPTION;

  BEGIN
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
    prej0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper,
                                  pr_nrdconta => pr_nrdconta,
                                  pr_cdoperad => '1',
                                  pr_vlrlanc  => pr_vllanmto,
                                  pr_dtmvtolt => pr_dtmvtolt,
                                  pr_nrdocmto => pr_nrdocmto,
                                  pr_cdcritic => pr_cdcritic,
                                  pr_dscritic => pr_dscritic);

    if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
      RAISE vr_exc_saida;
    end if;
    --
  EXCEPTION
  WHEN vr_exc_saida THEN
    if pr_cdcritic is not null and pr_dscritic is null then
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    end if;
    rollback;
    RAISE_APPLICATION_ERROR(-20500,pr_dscritic);
  WHEN OTHERS THEN
    pr_dscritic := 'Erro ao atualizar CRAPSLD = '||SQLERRM;
    rollback;
    RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
  end;
-- ================================================================================================= 13
  BEGIN
    UPDATE tbcc_prejuizo a
       SET vlsdprej = 0
          ,vljuprej = 0
     WHERE cdcooper = 13
       AND nrdconta = 80616;
  END;
-- ================================================================================================= 14
  DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 7;
    pr_nrdconta   craplcm.nrdconta%TYPE := 141909;
    pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
  --  pr_cdhistor IN  craplcm.cdhistor%TYPE
    pr_nrdocmto   craplcm.nrdocmto%type := 1;
    pr_cdagenci   craplcm.cdagenci%type := 1;
    pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
    pr_vllanmto   craplcm.vllanmto%TYPE := 2040.37;
    pr_nrdctabb   craplcm.nrdctabb%TYPE := 7662050;
    pr_cdcritic   NUMBER;
    pr_dscritic   VARCHAR2(10000);
    vr_nrseqdig       craplot.nrseqdig%TYPE;   -- Aramazena o valor do campo "nrseqdig" da CRAPLOT para referência na CRAPLCM
    vr_tab_retorno    lanc0001.typ_reg_retorno;
    vr_incrineg       INTEGER;

    vr_exc_saida      EXCEPTION;

  BEGIN
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
    prej0003.pc_gera_transf_cta_prj(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_cdoperad => 1
                                   ,pr_vllanmto => pr_vllanmto
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_versaldo => 0 -- pr_versaldo
                                   ,pr_atsldlib => 0 -- pr_atsldlib
                                   ,pr_cdcritic => pr_cdcritic
                                   ,pr_dscritic => pr_dscritic);
    if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
      RAISE vr_exc_saida;
    end if;
    --
    vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                              ,pr_nmdcampo => 'NRSEQDIG'
                              ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                              to_char(pr_dtmvtolt, 'DD/MM/RRRR')||';'||
                              '1;100;650010');
    -- Efetua lancamento de crédito na CRAPLCM(LANC0001)
    LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_cdagenci => 1
                                      ,pr_cdbccxlt => 100
                                      ,pr_nrdolote => 650010
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrdocmto => pr_nrdctabb
                                      ,pr_cdoperad => 1
                                      ,pr_nrdctabb => pr_nrdconta
                                      ,pr_nrseqdig => vr_nrseqdig
                                      ,pr_dtrefere => pr_dtmvtolt
                                      ,pr_vllanmto => pr_vllanmto
                                      ,pr_cdhistor => 535
                                      -- OUTPUT --
                                      ,pr_tab_retorno => vr_tab_retorno
                                      ,pr_incrineg => vr_incrineg
                                      ,pr_cdcritic => pr_cdcritic
                                      ,pr_dscritic => pr_dscritic);

    IF nvl(pr_cdcritic, 0) > 0 OR pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
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
    rollback;
    RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
  end;
-- ================================================================================================= 15
  COMMIT;
END;
