DECLARE

  rw_crapdat       btch0001.cr_crapdat%ROWTYPE;
  vr_tab_retorno   LANC0001.typ_reg_retorno;
  vr_incrineg      INTEGER;
  vr_nrseqdiglcm   CECRED.craplcm.nrseqdig%TYPE;
  vr_cdcooper      CECRED.crapcop.cdcooper%TYPE;
  vr_cdhistor      CECRED.craphis.cdhistor%TYPE;
  vr_nrdolote      CECRED.craplcm.nrdolote%TYPE;
  vr_qterros       PLS_INTEGER := 0;
  vr_qtprocessados PLS_INTEGER := 0;
  vr_qtfuturos     PLS_INTEGER := 0;
  vr_inlctfut      VARCHAR2(01);
  vr_coopdest      CECRED.crapcop.cdcooper%TYPE;
  vr_nrdconta      NUMBER(25);
  vr_dtprocesso    CECRED.crapdat.dtmvtolt%TYPE;
  vr_exc_saida     EXCEPTION;
  vr_cdcritic      CECRED.crapcri.cdcritic%TYPE;
  vr_dscritic      CECRED.crapcri.dscritic%TYPE;

  CURSOR cr_lancamento IS
    SELECT *
      FROM craplcm
     WHERE PROGRESS_RECID IN (1577555474,
                              1577555475,
                              1577555476,
                              1577555477,
                              1577555478,
                              1577555479,
                              1577555480,
                              1577555481,
                              1577555482,
                              1577555483,
                              1577555484,
                              1577555485,
                              1577555486,
                              1577555487,
                              1577555488,
                              1577555489,
                              1577555490,
                              1577555491,
                              1577555492,
                              1577555493,
                              1577555494,
                              1577555495,
                              1577555496,
                              1577555497,
                              1577555498,
                              1577555499,
                              1577555500,
                              1577555501,
                              1577555502,
                              1577555503,
                              1577555504,
                              1577555505,
                              1577555506,
                              1577555507,
                              1577555508,
                              1577555509,
                              1577555510,
                              1577555511,
                              1577555512,
                              1577555513,
                              1577555514,
                              1577555515,
                              1577555516,
                              1577555525,
                              1577555526,
                              1577555527,
                              1577555528,
                              1577555529,
                              1577555530,
                              1577555531,
                              1577555532,
                              1577555533,
                              1577555534,
                              1577555535,
                              1577555536,
                              1577555537,
                              1577555538,
                              1577555539,
                              1577555540,
                              1577555541,
                              1577555542,
                              1577555543,
                              1577555544,
                              1577555545,
                              1577555546,
                              1577555547,
                              1577555548,
                              1577555549,
                              1577555550,
                              1577555551,
                              1577555552,
                              1577555553,
                              1577555554,
                              1577555555,
                              1577555556,
                              1577555557,
                              1577555558,
                              1577555559,
                              1577555560,
                              1577555561,
                              1577555562,
                              1577555563,
                              1577555564,
                              1577555565,
                              1577555566,
                              1577555567,
                              1577555517,
                              1577555568,
                              1577555518,
                              1577555519,
                              1577555569,
                              1577555570,
                              1577555520,
                              1577555521,
                              1577555522,
                              1577555523,
                              1577555524,
                              1577555571,
                              1577555572,
                              1577555573,
                              1577555574,
                              1577555575);

  CURSOR cr_crapcop IS
    SELECT cdcooper
          ,cdagectl
          ,nmrescop
          ,flgativo
      FROM CECRED.crapcop;

  CURSOR cr_craptco(pr_cdcopant IN CECRED.crapcop.cdcooper%TYPE
                   ,pr_nrctaant IN craptco.nrctaant%TYPE) IS
    SELECT tco.nrdconta
          ,tco.cdcooper
      FROM CECRED.craptco tco
     WHERE tco.cdcopant = pr_cdcopant
       AND tco.nrctaant = pr_nrctaant;
  rw_craptco cr_craptco%ROWTYPE;

BEGIN

  FOR rw_lancamento IN cr_lancamento LOOP
  
    OPEN btch0001.cr_crapdat(vr_coopdest);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
  
    IF trunc(sysdate) IS NULL THEN
      IF rw_crapdat.inproces > 1 THEN
        vr_dtprocesso := rw_crapdat.dtmvtopr;
      ELSE
        vr_dtprocesso := rw_crapdat.dtmvtolt;
      END IF;
    ELSE
      vr_dtprocesso := trunc(sysdate);
    END IF;
  
    vr_nrdconta := rw_lancamento.nrdconta;
    vr_cdcooper := rw_lancamento.cdcooper;
    vr_nrdolote := 9666;
    vr_cdhistor := 2444;
    vr_dscritic := NULL;
  
    ccrd0006.pc_procura_ultseq_craplcm(pr_cdcooper    => vr_cdcooper,
                                       pr_dtmvtolt    => vr_dtprocesso,
                                       pr_cdagenci    => 1,
                                       pr_cdbccxlt    => 100,
                                       pr_nrdolote    => vr_nrdolote,
                                       pr_nrseqdiglcm => vr_nrseqdiglcm,
                                       pr_cdcritic    => vr_cdcritic,
                                       pr_dscritic    => vr_dscritic);
  
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    BEGIN
      LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => trunc(vr_dtprocesso),
                                         pr_cdagenci    => 1,
                                         pr_cdbccxlt    => 100,
                                         pr_nrdolote    => vr_nrdolote,
                                         pr_nrdconta    => vr_nrdconta,
                                         pr_nrdocmto    => vr_nrseqdiglcm,
                                         pr_cdhistor    => vr_cdhistor,
                                         pr_nrseqdig    => vr_nrseqdiglcm,
                                         pr_vllanmto    => rw_lancamento.vllanmto,
                                         pr_nrdctabb    => vr_nrdconta,
                                         pr_nrdctitg    => GENE0002.fn_mask(vr_nrdconta, '99999999'),
                                         pr_cdcooper    => vr_cdcooper,
                                         pr_dtrefere    => rw_lancamento.dtmvtolt,
                                         pr_cdoperad    => 1,
                                         pr_cdpesqbb    => rw_lancamento.cdpesqbb,
                                         pr_tab_retorno => vr_tab_retorno,
                                         pr_incrineg    => vr_incrineg,
                                         pr_cdcritic    => vr_cdcritic,
                                         pr_dscritic    => vr_dscritic);
    
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        RAISE vr_exc_saida;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir CRAPLCM: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
  
    vr_qtprocessados := vr_qtprocessados + 1;
  
    vr_dscritic := NULL;
  
  END LOOP;

  --COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
  
    ROLLBACK;
    raise_application_error(-20001,
                            'Erro: ' || ' ' || vr_cdcritic || ' ' ||
                            SQLERRM);
  
  WHEN OTHERS THEN
    raise_application_error(-20002, 'Erro: ' || SQLERRM);
  
    ROLLBACK;
  
END;
