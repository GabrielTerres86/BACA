DECLARE
/* o script foi montado com base na PC_CRPS002 - PCVERIFICA_CONTA_PREJUIZO */
  pr_cdcooper   craplcm.cdcooper%TYPE := 14;
  pr_nrdconta   craplcm.nrdconta%TYPE := 56111;
  pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
--  pr_cdhistor IN  craplcm.cdhistor%TYPE
  pr_nrdocmto   craplcm.nrdocmto%type := 1;
  pr_cdagenci   craplcm.cdagenci%type := 1;
  pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
  pr_vllanmto   craplcm.vllanmto%TYPE := 444.49;
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

        -- Insere lançamento do crédito transferido para a Conta Transitória
        INSERT INTO TBCC_PREJUIZO_LANCAMENTO (
               dtmvtolt
             , cdagenci
             , nrdconta
             , nrdocmto
             , cdhistor
             , vllanmto
             , dthrtran
             , cdoperad
             , cdcooper
             , cdorigem
        )
        VALUES (
               pr_dtmvtolt
             , pr_cdagenci
             , pr_nrdconta
             , pr_nrdocmto
             , 2738
             , pr_vllanmto
             , SYSDATE
             , 1
             , pr_cdcooper
             , 5
        );
      update crapsld s
         set s.vlsddisp = vlsddisp - pr_vllanmto,
             s.vlindext = 1
       where s.cdcooper = pr_cdcooper
         and s.nrdconta = pr_nrdconta;

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
    RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
  end;