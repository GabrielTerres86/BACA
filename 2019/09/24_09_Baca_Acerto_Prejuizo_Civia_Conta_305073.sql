DECLARE
  pr_cdcooper   craplcm.cdcooper%TYPE := 13;
  pr_nrdconta   craplcm.nrdconta%TYPE := 305073;
  pr_vllanmto   craplcm.vllanmto%TYPE := 1490.62;
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
  vr_nrseqdig       craplot.nrseqdig%TYPE;   -- Aramazena o valor do campo "nrseqdig" da CRAPLOT para refer�ncia na CRAPLCM  
  pr_cdoperad   craplcm.cdoperad%TYPE := 1;  
  --
  vr_exc_saida  EXCEPTION;
BEGIN
  --Excluir o lan�amento 2408 do dia 09/09 no valor de 1.500,00
  BEGIN
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE idlancto IN (38386);

    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - 1500.00
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
  END;
  
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
  -- Lan�a d�bito referente ao pagamento do preju�zo
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
  -- Lan�a cr�dito referente ao pagamento do preju�zo
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
  -- Valor pago do saldo devedor principal do preju�zo
  PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                         , pr_nrdconta => pr_nrdconta
                         , pr_dtmvtolt => pr_dtmvtolt
                         , pr_cdhistor => 2726
                         , pr_idprejuizo => vr_idprejuizo
                         , pr_vllanmto => 1468.08
                         , pr_dthrtran => vr_dthrtran
                         , pr_cdcritic => pr_cdcritic
                         , pr_dscritic => pr_dscritic);
  IF NVL(pr_cdcritic,0) > 0
  OR pr_dscritic IS NOT NULL
  THEN
    RAISE vr_exc_saida;
  END IF;
  -- Valor de Juros + 60
  PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                         , pr_nrdconta => pr_nrdconta
                         , pr_dtmvtolt => pr_dtmvtolt
                         , pr_cdhistor => 2728
                         , pr_idprejuizo => vr_idprejuizo
                         , pr_vllanmto => 11.36
                         , pr_dthrtran => vr_dthrtran
                         , pr_cdcritic => pr_cdcritic
                         , pr_dscritic => pr_dscritic);
  IF NVL(pr_cdcritic,0) > 0
  OR pr_dscritic IS NOT NULL
  THEN
    RAISE vr_exc_saida;
  END IF;
  -- Valor de Juros + 60
  PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                         , pr_nrdconta => pr_nrdconta
                         , pr_dtmvtolt => pr_dtmvtolt
                         , pr_cdhistor => 2730
                         , pr_idprejuizo => vr_idprejuizo
                         , pr_vllanmto => 11.18
                         , pr_dthrtran => vr_dthrtran
                         , pr_cdcritic => pr_cdcritic
                         , pr_dscritic => pr_dscritic);
  IF NVL(pr_cdcritic,0) > 0
  OR pr_dscritic IS NOT NULL
  THEN
    RAISE vr_exc_saida;
  END IF;
-------------------------------------------------------------------------
--E rodar o hist. 362 na conta corrente no valor de R$9,38.
        -- Gera valor do campo "nrseqdig" a partir da sequence (para n�o usar CRAPLOT)
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
        , 362 -- pr_cdhistor
        , vr_nrseqdig
        , 9.38
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

-------------------------------------------------------------------------    
  commit;

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
