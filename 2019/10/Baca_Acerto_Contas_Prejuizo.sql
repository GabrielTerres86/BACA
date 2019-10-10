DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE ;
    pr_nrdconta   craplcm.nrdconta%TYPE ;
    pr_vllanmto   craplcm.vllanmto%TYPE ;
    pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
  --  pr_cdhistor IN  craplcm.cdhistor%TYPE
    pr_cdoperad   craplcm.cdoperad%TYPE := 1;  
    pr_nrdocmto   craplcm.nrdocmto%type := 1;
    pr_cdagenci   craplcm.cdagenci%type := 1;
    pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
    pr_nrdctabb   craplcm.nrdctabb%TYPE;
    pr_cdcritic   NUMBER;
    pr_dscritic   VARCHAR2(10000);
    --
    vr_dthrtran   DATE := SYSDATE;
    vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;
    vr_idlancto_prejuizo  tbcc_prejuizo_detalhe.idlancto%TYPE := NULL;    
    --
    vr_exc_saida  EXCEPTION;
  BEGIN
dbms_output.put_line('In�cio   Conta: 9.051-4');
--Coop: Civia
--Fazer um cr�dito no bloqueado preju�zo no valor de R$9,25
    pr_cdcooper  := 13;
    pr_nrdconta  := 90514 ;
    pr_vllanmto  := 9.25;
    pr_nrdctabb  := 56111;
    BEGIN
      SELECT dtmvtolt
        INTO pr_dtmvtolt
        FROM crapdat
       WHERE cdcooper = pr_cdcooper;
    EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao buscar DTMVTOLT = '||SQLERRM;
    END;
    -- Efetua lancamento de d�bito na contra transit�ria
    BEGIN
      INSERT INTO tbcc_prejuizo_lancamento(dtmvtolt
                                          ,cdagenci
                                          ,nrdconta
                                          ,cdhistor
                                          ,nrdocmto
                                          ,vllanmto
                                          ,dthrtran
                                          ,cdoperad
                                          ,cdcooper
                                          ,dsoperac)
                                    VALUES(pr_dtmvtolt      -- dtmvtolt
                                          ,1                -- cdagenci
                                          ,pr_nrdconta      -- nrdconta
                                          ,2738             -- cdhistor
                                          ,990109           -- nrdocmto
                                          ,pr_vllanmto      -- vllanmto
                                          ,SYSDATE          -- dthrtran
                                          ,pr_cdoperad      -- cdoperad
                                          ,pr_cdcooper
                                          ,0);
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

dbms_output.put_line('Fim   Conta: 9.051-4');    

--------------------------------------------------------------------------------------------------------

dbms_output.put_line('In�cio   Conta: 345245');
--Coop: Alto Vale
--Rodar o hist�rico 2721 no valor de R$0,78
    pr_cdcooper   := 16;
    pr_nrdconta   := 345245;
    pr_vllanmto   := 0.78;
    vr_idprejuizo := null;
    vr_dthrtran   := SYSDATE;    
  
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
    -- Lan�a d�bito referente ao pagamento do preju�zo
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
    -- Lan�a cr�dito referente ao pagamento do preju�zo
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
    -- Valor pago do saldo devedor principal do preju�zo
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

dbms_output.put_line('Fim   Conta: 345245');    

--------------------------------------------------------------------------------------------------------

dbms_output.put_line('In�cio   Conta: 9768513');
--Coop: Viacredi
--Rodar o hist�rico 2721 no valor de R$0,92
    pr_cdcooper   := 1;
    pr_nrdconta   := 9768513;
    pr_vllanmto   := 0.92;
    vr_idprejuizo := null;
    vr_dthrtran   := SYSDATE;    
  
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
    -- Lan�a d�bito referente ao pagamento do preju�zo
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
    -- Lan�a cr�dito referente ao pagamento do preju�zo
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
    -- Valor pago do saldo devedor principal do preju�zo
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
dbms_output.put_line('Fim   Conta: 9768513');    

--------------------------------------------------------------------------------------------------------

dbms_output.put_line('In�cio   Conta: 7711034');
--Coop: Viacredi
--Excluir o hist�rico 2408 no valor de R$500,00 do dia 20/09.
BEGIN
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (39515);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 500.00
   WHERE cdcooper = 1
     AND nrdconta = 7711034;
END;

dbms_output.put_line('Fim   Conta: 7711034');    
--------------------------------------------------------------------------------------------------------
  --
   COMMIT;
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
  
  
  
