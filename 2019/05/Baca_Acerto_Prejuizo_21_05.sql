BEGIN
-- ================================================================================================= 1
  DECLARE
  /* o script foi montado com base na PC_CRPS002 - PCVERIFICA_CONTA_PREJUIZO */
    pr_cdcooper   craplcm.cdcooper%TYPE := 1;
    pr_nrdconta   craplcm.nrdconta%TYPE := 9938;
    pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
    pr_vllanmto   craplcm.vllanmto%TYPE := 4382.32;
    pr_nrdocmto   craplcm.nrdocmto%type := 1;
    pr_cdagenci   craplcm.cdagenci%type := 1;
    pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
    pr_cdoperad   craplcm.cdoperad%TYPE := 1;
    vr_idprejuizo NUMBER;
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
--      if prej0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta) then

          vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                    to_char(pr_dtmvtolt, 'DD/MM/RRRR')||';'||
                                    '1;100;650009');

          -- Efetua débito do valor que será transferido para a Conta Transitória (créditos bloqueados por prejuízo em conta)
          lanc0001.pc_gerar_lancamento_conta(
             pr_dtmvtolt => pr_dtmvtolt,
             pr_cdagenci => pr_cdagenci,
             pr_cdbccxlt => pr_cdbccxlt,
             pr_nrdolote => 650009,
             pr_nrdconta => pr_nrdconta,
             pr_nrdocmto => pr_nrdocmto,
             pr_cdhistor => 2719,
             pr_nrseqdig => vr_nrseqdig,
             pr_vllanmto => pr_vllanmto,
             pr_nrdctabb => pr_nrdconta,
             pr_cdpesqbb => 'ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO',
             pr_dtrefere => pr_dtmvtolt,
             pr_hrtransa => gene0002.fn_busca_time,
             pr_cdoperad => 1,
             pr_cdcooper => pr_cdcooper,
             pr_cdorigem => 5,
             pr_tab_retorno => vr_tab_retorno,
             pr_incrineg => vr_incrineg,
             pr_cdcritic => pr_cdcritic,
             pr_dscritic => pr_dscritic
          );

          if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
             RAISE vr_exc_saida;
          end if;

          PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
                                      , pr_nrdconta => pr_nrdconta
                                      , pr_cdoperad => pr_cdoperad
                                      , pr_vlrlanc =>  pr_vllanmto
                                      , pr_dtmvtolt => pr_dtmvtolt
                                      , pr_cdcritic => pr_cdcritic
                                      , pr_dscritic => pr_dscritic);
          if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
            RAISE vr_exc_saida;
          end if;
--      end if;
    --
    pr_vllanmto := 3403.81;
    --
    SELECT idprejuizo
      INTO vr_idprejuizo
      FROM tbcc_prejuizo
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    --
    BEGIN
      UPDATE crapass pass
         SET pass.inprejuz = 1
           , pass.cdsitdct = 2
       WHERE pass.cdcooper = pr_cdcooper
         AND pass.nrdconta = pr_nrdconta;
    EXCEPTION
       WHEN OTHERS THEN
         pr_cdcritic :=0;
         pr_dscritic := 'Erro de update na CRAPASS: '||SQLERRM;
       RETURN;
    END;

    PREJ0003.pc_lanca_transf_extrato_prj(pr_idprejuizo => vr_idprejuizo
                               , pr_cdcooper   => pr_cdcooper
                               , pr_nrdconta   => pr_nrdconta
                               , pr_vlsldprj   => pr_vllanmto
                               , pr_vljur60_ctneg => 0
                               , pr_vljur60_lcred => 0
                               , pr_dtmvtolt   => pr_dtmvtolt
                               , pr_tpope      => 'N'
                               , pr_cdcritic   => pr_cdcritic
                               , pr_dscritic   => pr_dscritic);

    if nvl(pr_cdcritic,0) > 0  or TRIM(pr_dscritic) is not null then
      RETURN;
    end if;

    UPDATE crapsld  sld
       SET vlsmnmes = 0
         , vlsmnesp = 0
         , vlsmnblq = 0
         , vljurmes = 0
         , vljuresp = 0
         , vljursaq = 0
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
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
    pr_cdcooper   craplcm.cdcooper%TYPE := 1;
    pr_nrdconta   craplcm.nrdconta%TYPE := 8731560;
    pr_vllanmto   craplcm.vllanmto%TYPE := 16442.90;
    pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
--    pr_cdhistor IN  craplcm.cdhistor%TYPE
    pr_cdoperad   craplcm.cdoperad%TYPE := 1;
    pr_nrdocmto   craplcm.nrdocmto%type := 1;
    pr_cdagenci   craplcm.cdagenci%type := 1;
    pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
    pr_nrdctabb   craplcm.nrdctabb%TYPE := 56111;
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
    -- Efetua lancamento de débito na contra transitória
    BEGIN
      INSERT INTO tbcc_prejuizo_lancamento(dtmvtolt
                                          ,cdagenci
                                          ,nrdconta
                                          ,cdhistor
                                          ,nrdocmto
                                          ,vllanmto
                                          ,dthrtran
                                          ,cdoperad
                                          ,cdcooper)
                                    VALUES(pr_dtmvtolt      -- dtmvtolt
                                          ,1                -- cdagenci
                                          ,pr_nrdconta      -- nrdconta
                                          ,2738             -- cdhistor
                                          ,990102           -- nrdocmto
                                          ,pr_vllanmto      -- vllanmto
                                          ,SYSDATE          -- dthrtran
                                          ,pr_cdoperad      -- cdoperad
                                          ,pr_cdcooper);
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro de insert na TBCC_PREJUIZO_LANCAMENTO:'||SQLERRM;
        RAISE vr_exc_saida;
    END;
    --
    if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
      RAISE vr_exc_saida;
    end if;
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
-- ================================================================================================= 3
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
-- ================================================================================================= 4
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
-- ================================================================================================= 6
-- ================================================================================================= 7
-- ================================================================================================= 8
-- ================================================================================================= 9
-- ================================================================================================= 10
-- ================================================================================================= 11
-- ================================================================================================= 12
  COMMIT;
END;
