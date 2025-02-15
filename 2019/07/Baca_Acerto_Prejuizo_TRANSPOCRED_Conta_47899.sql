DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 9;
    pr_nrdconta   craplcm.nrdconta%TYPE := 47899;
    pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
    pr_vllanmto   craplcm.vllanmto%TYPE;
    pr_nrdocmto   craplcm.nrdocmto%type := 1;
    pr_cdagenci   craplcm.cdagenci%type := 1;
    pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
    pr_cdoperad   craplcm.cdoperad%TYPE := 1;
    pr_cdcritic   NUMBER;
    pr_dscritic   VARCHAR2(10000);
    vr_nrseqdig       craplot.nrseqdig%TYPE;   
    vr_tab_retorno    lanc0001.typ_reg_retorno;
    vr_incrineg       INTEGER;
    vr_exc_saida      EXCEPTION;
    vr_dthrtran   DATE := SYSDATE;    
    vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;    
    vr_idlancto_prejuizo  tbcc_prejuizo_detalhe.idlancto%TYPE := NULL;        
  begin
      BEGIN
          UPDATE tbcc_prejuizo a
             SET vlsdprej = 2259.29
           WHERE cdcooper = pr_cdcooper AND nrdconta = pr_nrdconta;
      END;
      BEGIN
        SELECT dtmvtolt
          INTO pr_dtmvtolt
          FROM crapdat
         WHERE cdcooper = pr_cdcooper;
      EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao buscar DTMVTOLT = '||SQLERRM;
      END;
      pr_vllanmto:=35.50;
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
      pr_vllanmto:=3.39;
      pr_nrdocmto:=2;
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
      pr_vllanmto   := 1559.49;
      UPDATE tbcc_prejuizo a
         SET vlsdprej = nvl(vlsdprej, 0) + pr_vllanmto
       WHERE cdcooper = pr_cdcooper  AND nrdconta = pr_nrdconta
      RETURNING a.idprejuizo INTO vr_idprejuizo;
      PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => pr_dtmvtolt
                              , pr_cdhistor => 2722
                              , pr_idprejuizo => vr_idprejuizo
                              , pr_vllanmto => pr_vllanmto
                              , pr_dthrtran => vr_dthrtran
    --, pr_idlancto_prejuizo => vr_idlancto_prejuizo -- Descomentar para executar no H3                                  
                              , pr_cdcritic => pr_cdcritic
                              , pr_dscritic => pr_dscritic);
                              
      IF NVL(pr_cdcritic,0) > 0 OR pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => pr_dtmvtolt
                              , pr_cdhistor => 2732
                              , pr_idprejuizo => vr_idprejuizo
                              , pr_vllanmto => pr_vllanmto
                              , pr_dthrtran => vr_dthrtran
    --, pr_idlancto_prejuizo => vr_idlancto_prejuizo -- Descomentar para executar no H3                                  
                              , pr_cdcritic => pr_cdcritic
                              , pr_dscritic => pr_dscritic);
      IF NVL(pr_cdcritic,0) > 0 OR pr_dscritic IS NOT NULL
      THEN
        RAISE vr_exc_saida;
      END IF;
      PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                             , pr_nrdconta => pr_nrdconta
                             , pr_dtmvtolt => pr_dtmvtolt
                             , pr_cdhistor => 2726
                             , pr_idprejuizo => vr_idprejuizo
                             , pr_vllanmto => pr_vllanmto
                             , pr_dthrtran => vr_dthrtran
   -- , pr_idlancto_prejuizo => vr_idlancto_prejuizo -- Descomentar para executar no H3                                 
                             , pr_cdcritic => pr_cdcritic
                             , pr_dscritic => pr_dscritic);
      IF NVL(pr_cdcritic,0) > 0 OR pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
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