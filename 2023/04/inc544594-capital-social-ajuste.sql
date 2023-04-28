DECLARE
  vr_cdcooper     craplct.cdcooper%TYPE := 12;
  vr_nrdconta     craplct.nrdconta%TYPE := 99935163;
  vr_vllanmto     craplct.vllanmto%TYPE := 94.55;
  vr_dtmvtolt     crapdat.dtmvtolt%TYPE := TRUNC(SYSDATE);
  vr_cdcritic     crapcri.cdcritic%TYPE;
  vr_dscritic     crapcri.dscritic%TYPE;
  vr_exc_erro     EXCEPTION;
  vr_nrdrowid     ROWID;
  vr_nrseqdig_lot craplot.nrseqdig%TYPE;
  vr_busca        VARCHAR2(100);
  vr_nrdocmto     craplct.nrdocmto%TYPE;
  vr_nrdolote     craplot.nrdolote%TYPE;
  vr_tab_retorno  LANC0001.typ_reg_retorno;
  vr_incrineg     INTEGER;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta
          ,ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = vr_cdcooper
       AND ass.nrdconta = vr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);

  FETCH cr_crapass
    INTO rw_crapass;

  IF cr_crapass%NOTFOUND
  THEN
    CLOSE cr_crapass;
    vr_dscritic := 'Associado nao encontrado - ' || vr_cdcooper || ' Conta: ' || vr_nrdconta;
    RAISE vr_exc_erro;
  END IF;

  CLOSE cr_crapass;

  vr_nrdolote := 900039;

  vr_busca := TRIM(to_char(vr_cdcooper)) || ';' || TRIM(to_char(vr_dtmvtolt, 'DD/MM/RRRR')) || ';' ||
              TRIM(to_char(rw_crapass.cdagenci)) || ';' || '100;' || vr_nrdolote || ';' ||
              TRIM(to_char(vr_nrdconta));

  vr_nrdocmto := fn_sequence('CRAPLCT', 'NRDOCMTO', vr_busca);

  vr_nrseqdig_lot := fn_sequence('CRAPLOT',
                                 'NRSEQDIG',
                                 '' || vr_cdcooper || ';' || to_char(vr_dtmvtolt, 'DD/MM/RRRR') || ';' ||
                                 rw_crapass.cdagenci || ';100;' || vr_nrdolote);

  BEGIN
    cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => vr_cdcooper,
                                              pr_dtmvtolt    => vr_dtmvtolt,
                                              pr_dtrefere    => vr_dtmvtolt,
                                              pr_cdagenci    => rw_crapass.cdagenci,
                                              pr_cdbccxlt    => 100,
                                              pr_nrdolote    => vr_nrdolote,
                                              pr_nrdconta    => vr_nrdconta,
                                              pr_nrdctabb    => vr_nrdconta,
                                              pr_nrdctitg    => TO_CHAR(cecred.gene0002.fn_mask(vr_nrdconta,
                                                                                                '99999999')),
                                              pr_nrdocmto    => vr_nrdocmto,
                                              pr_cdhistor    => 535,
                                              pr_vllanmto    => vr_vllanmto,
                                              pr_nrseqdig    => vr_nrseqdig_lot,
                                              pr_tab_retorno => vr_tab_retorno,
                                              pr_incrineg    => vr_incrineg,
                                              pr_cdcritic    => vr_cdcritic,
                                              pr_dscritic    => vr_dscritic);
    
    IF nvl(vr_cdcritic, 0) > 0
       OR vr_dscritic IS NOT NULL
    THEN
      RAISE vr_exc_erro;
    END IF;
    
    INSERT INTO cecred.craplct
      (cdcooper
      ,cdagenci
      ,cdbccxlt
      ,nrdolote
      ,dtmvtolt
      ,cdhistor
      ,nrctrpla
      ,nrdconta
      ,nrdocmto
      ,nrseqdig
      ,vllanmto)
    VALUES
      (vr_cdcooper
      ,rw_crapass.cdagenci
      ,100
      ,vr_nrdolote
      ,vr_dtmvtolt
      ,61
      ,vr_nrdconta
      ,vr_nrdconta
      ,vr_nrdocmto
      ,vr_nrseqdig_lot
      ,vr_vllanmto);
  
    UPDATE cecred.crapcot
       SET vldcotas = vldcotas + vr_vllanmto
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta;
  
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Não foi possível efetuar o saque parcial.' || SQLERRM;
      RAISE vr_exc_erro;
  END;
  
  COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    IF vr_cdcritic <> 0
    THEN
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' Cooperativa ' ||
                     vr_cdcooper || ' Conta: ' || vr_nrdconta;
    ELSE
      vr_cdcritic := NVL(vr_cdcritic, 0);
      vr_dscritic := vr_dscritic;
    END IF;
    
    ROLLBACK;
  WHEN OTHERS THEN
    vr_cdcritic := NULL;
    vr_dscritic := 'Erro na inc544594-capital-social-ajuste --> ' || SQLERRM;
    
    ROLLBACK;
END;
/
