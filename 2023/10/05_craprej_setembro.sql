DECLARE
  vr_exc_saida        EXCEPTION;
  vr_dscritic         VARCHAR2(4000);
  vr_cdcritic         NUMBER;
  
  vr_dtrefere         DATE := to_date('02/10/2023', 'DD/MM/RRRR');
  vr_dtrefere_ris     DATE := to_date('30/09/2023', 'DD/MM/RRRR');  
  
  vr_dtmvtolt            cecred.crapdat.dtmvtolt%type;
  vr_dtmvtoan            cecred.crapdat.dtmvtoan%type;
  vr_dtmvtopr            cecred.crapdat.dtmvtopr%type;
  vr_dtultdia            cecred.crapdat.dtultdia%type;
  vr_dtultdia_prxmes     cecred.crapdat.dtultdia%type;
  
  rw_crapdat datascooperativa;
  
  CURSOR cr_craphis (pr_cdcooper IN cecred.craphis.cdcooper%TYPE) IS 
    SELECT upper(craphis.nmestrut) nmestrut,
           craphis.cdhistor cdhistor,
           craphis.tpctbcxa,
           craphis.tpctbccu,
           craphis.nrctacrd,
           craphis.nrctadeb
      FROM cecred.craphis
     WHERE craphis.cdcooper = pr_cdcooper
       AND (craphis.nrctadeb <> craphis.nrctacrd OR craphis.nrctadeb = 0)
       AND craphis.cdhstctb > 0
       AND craphis.cdhistor NOT IN (1154, 3361, 1019, 1414, 2515, 2937, 2969, 2936, 2967, 2938, 2968, 2941,  2940, 2939,
                                    3239, 3241, 3240, 3292, 3044, 3045, 3046, 3049, 3852) 
       AND upper(craphis.nmestrut) in ('CRAPLCT', 'CRAPLCM', 'CRAPLEM', 'CRAPLPP',
                                       'CRAPLAP', 'CRAPLFT', 'CRAPTVL', 'CRAPLAC',
                                       'TBDSCT_LANCAMENTO_BORDERO',
                                       'TBCC_PREJUIZO_DETALHE')
    UNION ALL
    SELECT UPPER(craphis.nmestrut) nmestrut
          ,craphis.cdhistor cdhistor
          ,craphis.tpctbcxa
          ,craphis.tpctbccu
          ,craphis.nrctacrd
          ,craphis.nrctadeb
      FROM cecred.craphis
     WHERE craphis.cdcooper = pr_cdcooper
       AND (craphis.nrctadeb <> craphis.nrctacrd OR craphis.nrctadeb = 0)
       AND craphis.cdhstctb > 0
       AND craphis.cdhistor IN (3843, 3844, 3846, 3847);
  rw_craphis    cr_craphis%ROWTYPE;

  CURSOR cr_crapthi (pr_cdcooper IN cecred.crapthi.cdcooper%TYPE,
                     pr_cdhistor IN cecred.craphis.cdhistor%TYPE,
                     pr_dsorigem IN cecred.crapthi.dsorigem%TYPE) IS
    SELECT vltarifa
      FROM cecred.crapthi
     WHERE crapthi.cdcooper = pr_cdcooper
       AND crapthi.cdhistor = pr_cdhistor
       AND crapthi.dsorigem = pr_dsorigem;
  rw_crapthi    cr_crapthi%ROWTYPE;
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
       AND a.cdcooper IN (1,16);
  rw_crapcop cr_crapcop%ROWTYPE;
BEGIN
  FOR rw_crapcop IN cr_crapcop LOOP

    GESTAODERISCO.obterCalendario(pr_cdcooper   => rw_crapcop.cdcooper
                                 ,pr_dtrefere   => vr_dtrefere
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdcritic   => vr_cdcritic
                                 ,pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    vr_dtmvtolt := rw_crapdat.dtmvtoan;
    
    vr_dtmvtopr := rw_crapdat.dtmvtolt;
                                               
    vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => rw_crapcop.cdcooper,
                                               pr_dtmvtolt => rw_crapdat.dtmvtoan -1,
                                               pr_tipo => 'A');
    FOR rw_craphis IN cr_craphis (rw_crapcop.cdcooper) LOOP
    
      OPEN cr_crapthi(rw_crapcop.cdcooper,
                      rw_craphis.cdhistor,
                      'AIMARO');
      FETCH cr_crapthi INTO rw_crapthi;
      IF cr_crapthi%NOTFOUND THEN
        CLOSE cr_crapthi;
        RAISE vr_exc_saida;                    
      END IF;
      CLOSE cr_crapthi;
      
      IF rw_craphis.tpctbcxa > 3 THEN
        cecred.pc_crps249_3(rw_crapcop.cdcooper,
                            vr_dtmvtolt,
                            rw_craphis.nmestrut,
                            rw_craphis.cdhistor,
                            vr_cdcritic,
                            vr_dscritic);
      ELSIF rw_craphis.nmestrut = 'CRAPLFT' THEN
        cecred.pc_crps249_2(rw_crapcop.cdcooper,
                            vr_dtmvtolt,
                            rw_craphis.nmestrut,
                            rw_craphis.cdhistor,
                            rw_craphis.tpctbcxa,
                            vr_cdcritic,
                            vr_dscritic);
      ELSIF rw_craphis.nmestrut = 'CRAPTVL' THEN
        cecred.pc_crps249_4(rw_crapcop.cdcooper,
                            vr_dtmvtolt,
                            rw_craphis.nmestrut,
                            rw_craphis.cdhistor,
                            rw_craphis.tpctbcxa,
                            vr_cdcritic,
                            vr_dscritic);
      ELSE
        cecred.pc_crps249_1(rw_crapcop.cdcooper,
                            vr_dtmvtolt,
                            vr_dtmvtoan,
                            rw_craphis.nmestrut,
                            rw_craphis.cdhistor,
                            rw_craphis.nrctadeb,
                            rw_craphis.nrctacrd,
                            rw_craphis.tpctbcxa,
                            rw_craphis.tpctbccu,
                            rw_crapthi.vltarifa,
                            vr_cdcritic,
                            vr_dscritic);
      END IF;
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      COMMIT;
      
    END LOOP;
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_saida THEN
    raise_application_error(-20000, vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
    ROLLBACK;
END;
