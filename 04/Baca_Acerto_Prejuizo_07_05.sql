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

  vr_nrseqdig       craplot.nrseqdig%TYPE;   -- Aramazena o valor do campo "nrseqdig" da CRAPLOT para refer�ncia na CRAPLCM
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
      , 2719 -- pr_cdhistor
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
-- ================================================================================================= 3
-- ================================================================================================= 4
-- ================================================================================================= 5
-- ================================================================================================= 6
-- ================================================================================================= 7
-- ================================================================================================= 8
-- ================================================================================================= 9
-- ================================================================================================= 10
-- ================================================================================================= 11
-- ================================================================================================= 12
END;
