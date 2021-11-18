DECLARE
  vr_cdprogra CONSTANT VARCHAR2(8) := 'RECP0001';
  vr_dsarqlog CONSTANT VARCHAR2(10) := 'acordo.log';

  vr_nracordo   tbrecup_acordo.nracordo%TYPE := 365195;
  vr_nrparcel   tbrecup_acordo_parcela.nrparcela%TYPE := 0;
  vr_vlparcel   NUMBER := 0;
  vr_cdoperad   VARCHAR2(100) := '1';
  vr_idorigem   NUMBER := 1;
  vr_nmtelant   VARCHAR2(100) := 'CRPS538';
  vr_vltotpag   NUMBER := 0;
  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   crapcri.dscritic%TYPE;
  vr_des_erro   VARCHAR2(1000);
  vr_tab_saldos EXTR0001.typ_tab_saldos;
  vr_tab_erro   GENE0001.typ_tab_erro;
  vr_exe_erro EXCEPTION;

  CURSOR cr_crapass(pr_nracordo tbrecup_acordo.nracordo%TYPE) IS
    SELECT ass.cdcooper
          ,ass.cdagenci
          ,ass.nrdconta
          ,ass.vllimcre
      FROM crapass        ass
          ,tbrecup_acordo acd
     WHERE ass.cdcooper = acd.cdcooper
       AND ass.nrdconta = acd.nrdconta
       AND acd.nracordo = pr_nracordo;
  rw_crapass cr_crapass%ROWTYPE;
  
  
BEGIN
  

  OPEN cr_crapass(pr_nracordo => vr_nracordo);
  FETCH cr_crapass
    INTO rw_crapass;

  IF cr_crapass%NOTFOUND THEN
    CLOSE cr_crapass;
    vr_dscritic := 'Acordo número ' || vr_nracordo || ' não foi encontrado.';
    RAISE vr_exe_erro;
  END IF;
  CLOSE cr_crapass;

  OPEN BTCH0001.cr_crapdat(rw_crapass.cdcooper);
  FETCH BTCH0001.cr_crapdat
    INTO BTCH0001.rw_crapdat;

  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    CLOSE BTCH0001.cr_crapdat;
    vr_dscritic := 'Erro ao buscar datas da cooperativa(' || rw_crapass.cdcooper || ').';
    RAISE vr_exe_erro;
  END IF;
  CLOSE BTCH0001.cr_crapdat;

  EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crapass.cdcooper,
                              pr_rw_crapdat => BTCH0001.rw_crapdat,
                              pr_cdagenci   => rw_crapass.cdagenci,
                              pr_nrdcaixa   => 100,
                              pr_cdoperad   => vr_cdoperad,
                              pr_nrdconta   => rw_crapass.nrdconta,
                              pr_vllimcre   => rw_crapass.vllimcre,
                              pr_dtrefere   => BTCH0001.rw_crapdat.dtmvtolt,
                              pr_des_reto   => vr_des_erro,
                              pr_tab_sald   => vr_tab_saldos,
                              pr_tipo_busca => 'A',
                              pr_tab_erro   => vr_tab_erro);
  IF vr_des_erro <> 'OK' THEN
    vr_dscritic := 'Erro ao obter saldo: ' || vr_tab_erro(vr_tab_erro.first).dscritic;
    RAISE vr_exe_erro;
  END IF;

  IF vr_tab_saldos.count() > 0 THEN
    vr_vlparcel := nvl(vr_tab_saldos(vr_tab_saldos.first).vlsddisp, 0);
  END IF;

  IF vr_vlparcel > 0 THEN
    vr_vlparcel := least(vr_vlparcel, 250);
    RECP0001.pc_pagar_contrato_acordo( pr_nracordo => vr_nracordo,
                                       pr_nrparcel => vr_nrparcel,
                                       pr_vlparcel => vr_vlparcel,
                                       pr_cdoperad => vr_cdoperad,
                                       pr_idorigem => vr_idorigem,
                                       pr_nmtelant => vr_nmtelant,
                                       pr_vltotpag => vr_vltotpag,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic, 0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exe_erro;
    END IF;
  ELSE
    vr_dscritic := 'Saldo insuficiente: ' || vr_vlparcel;
    RAISE vr_exe_erro;
  END IF;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exe_erro THEN
    ROLLBACK;
    raise_application_error(-20500, vr_cdcritic || ' - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
