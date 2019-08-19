BEGIN
-- ================================================================================================= 1
DECLARE
/* o script foi montado com base na PC_CRPS002 - PCVERIFICA_CONTA_PREJUIZO */
  pr_cdcooper   craplcm.cdcooper%TYPE := 1;
  pr_nrdconta   craplcm.nrdconta%TYPE := 9455124;
  pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
  pr_vllanmto   craplcm.vllanmto%TYPE := 26.46;
--  pr_cdhistor IN  craplcm.cdhistor%TYPE
  pr_nrdocmto   craplcm.nrdocmto%type := 1;
  pr_cdagenci   craplcm.cdagenci%type := 1;
  pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
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
    if prej0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta) then

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
                                    , pr_cdoperad => 1
                                    , pr_vlrlanc =>  pr_vllanmto
                                    , pr_dtmvtolt => pr_dtmvtolt
                                    , pr_cdcritic => pr_cdcritic
                                    , pr_dscritic => pr_dscritic);
        if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
          RAISE vr_exc_saida;
        end if;
    end if;
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
begin

  -- Conta 8811539 / 1-Viacredi
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (15927);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 119.90
   WHERE cdcooper = 7
     AND nrdconta = 8811539;
  -- FIM - Conta 8811539 / 1-Viacredi

  COMMIT;
end;
-- ================================================================================================= 3
begin

  -- Conta 2699249 / 1-Viacredi
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (13023);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 0.43
   WHERE cdcooper = 7
     AND nrdconta = 2699249;
  -- FIM - Conta 2699249 / 1-Viacredi

  COMMIT;
end;
-- ================================================================================================= 4
begin

  -- Conta 7769946 / 1-Viacredi
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (15922,15923,15925,15924,15926,15901);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 760.52
   WHERE cdcooper = 7
     AND nrdconta = 7769946;
  -- FIM - Conta 7769946 / 1-Viacredi

  COMMIT;
end;
-- ================================================================================================= 5
DECLARE
  pr_cdcooper   craplcm.cdcooper%TYPE := 1;
  pr_nrdconta   craplcm.nrdconta%TYPE := 80287549;
  pr_vllanmto   craplcm.vllanmto%TYPE := 196.23;
  pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
--  pr_cdhistor IN  craplcm.cdhistor%TYPE
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
  --
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
  rollback;
  RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
end;
-- ================================================================================================= 6
DECLARE
  pr_cdcooper   craplcm.cdcooper%TYPE := 1;
  pr_nrdconta   craplcm.nrdconta%TYPE := 2699249;
--  pr_vllanmto   craplcm.vllanmto%TYPE := &vllanmto;
  pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
--  pr_cdhistor IN  craplcm.cdhistor%TYPE
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
  --
  PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_cdoperad => pr_cdoperad
                              , pr_vlrlanc =>  800
                              , pr_dtmvtolt => pr_dtmvtolt
                              , pr_cdcritic => pr_cdcritic
                              , pr_dscritic => pr_dscritic);
  if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
    RAISE vr_exc_saida;
  end if;
  --
  PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_cdoperad => pr_cdoperad
                              , pr_vlrlanc =>  2588.47
                              , pr_dtmvtolt => pr_dtmvtolt
                              , pr_cdcritic => pr_cdcritic
                              , pr_dscritic => pr_dscritic);
  if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
    RAISE vr_exc_saida;
  end if;
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
  rollback;
  RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
end;
-- ================================================================================================= 7
DECLARE
  pr_cdcooper   craplcm.cdcooper%TYPE := 1;
  pr_nrdconta   craplcm.nrdconta%TYPE := 8179034;
  pr_vllanmto   craplcm.vllanmto%TYPE := .9;
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
-- ================================================================================================= 8
BEGIN
  BEGIN
    UPDATE tbcc_prejuizo
       SET VLSDPREJ = 0
     WHERE cdcooper = 16
       AND nrdconta = 34924;
  EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(20501,'Erro no acerto da conta = 34924 '||sqlerrm);
  END;

  BEGIN
    UPDATE tbcc_prejuizo
       SET VLSDPREJ = 0
     WHERE cdcooper = 1
       AND nrdconta = 3599469;
  EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(20501,'Erro no acerto da conta = 3599469 '||sqlerrm);
  END;

  BEGIN
    UPDATE tbcc_prejuizo
       SET VLSDPREJ = 0
     WHERE cdcooper = 1
       AND nrdconta = 3222322;
  EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(20501,'Erro no acerto da conta = 3222322 '||sqlerrm);
  END;

  BEGIN
    UPDATE tbcc_prejuizo
       SET VLSDPREJ = 0
     WHERE cdcooper = 13
       AND nrdconta = 404152;
  EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(20501,'Erro no acerto da conta = 404152 '||sqlerrm);
  END;

  COMMIT;
END;
-- ================================================================================================= 9
DECLARE
  pr_cdcooper   craplcm.cdcooper%TYPE := 9;
  pr_nrdconta   craplcm.nrdconta%TYPE := 3476;
  pr_vllanmto   craplcm.vllanmto%TYPE := 49.78;
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
-- ================================================================================================= 10
-- ================================================================================================= 11
-- ================================================================================================= 12
END;
