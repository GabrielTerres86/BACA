DECLARE
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto VARCHAR(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  TYPE dados_typ IS RECORD(
    vr_cdcooper crapcop.cdcooper%TYPE,
    vr_nrdconta crapass.nrdconta%TYPE,
    vr_vllanmto craplem.vllanmto%TYPE,
    vr_cdhistor craplem.cdhistor%TYPE);

  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados t_dados_tab := t_dados_tab();

BEGIN

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12293750;
  v_dados(v_dados.last()).vr_vllanmto := 295.77;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12293750;
  v_dados(v_dados.last()).vr_vllanmto := 0.68;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12293750;
  v_dados(v_dados.last()).vr_vllanmto := 0.04;
  v_dados(v_dados.last()).vr_cdhistor := 1667; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12293750;
  v_dados(v_dados.last()).vr_vllanmto := 0.4;
  v_dados(v_dados.last()).vr_cdhistor := 320; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12293750;
  v_dados(v_dados.last()).vr_vllanmto := 4.75;
  v_dados(v_dados.last()).vr_cdhistor := 1667; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12293750;
  v_dados(v_dados.last()).vr_vllanmto := 8.2;
  v_dados(v_dados.last()).vr_cdhistor := 320; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12058556;
  v_dados(v_dados.last()).vr_vllanmto := 299.5;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12058556;
  v_dados(v_dados.last()).vr_vllanmto := 2.56;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12058556;
  v_dados(v_dados.last()).vr_vllanmto := .58;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12058556;
  v_dados(v_dados.last()).vr_vllanmto := 2.28;
  v_dados(v_dados.last()).vr_cdhistor := 320; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12431796;
  v_dados(v_dados.last()).vr_vllanmto := 23.93;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12431796;
  v_dados(v_dados.last()).vr_vllanmto := 35.69;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12431796;
  v_dados(v_dados.last()).vr_vllanmto := 0.13;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12431796;
  v_dados(v_dados.last()).vr_vllanmto := 0.93;
  v_dados(v_dados.last()).vr_cdhistor := 1667; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12431796;
  v_dados(v_dados.last()).vr_vllanmto := 0.13;
  v_dados(v_dados.last()).vr_cdhistor := 320; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11921340;
  v_dados(v_dados.last()).vr_vllanmto := 76.17;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11921340;
  v_dados(v_dados.last()).vr_vllanmto := 82.85;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11921340;
  v_dados(v_dados.last()).vr_vllanmto := 0.9;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11921340;
  v_dados(v_dados.last()).vr_vllanmto := 0.1;
  v_dados(v_dados.last()).vr_cdhistor := 1667; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11921340;
  v_dados(v_dados.last()).vr_vllanmto := 10.16;
  v_dados(v_dados.last()).vr_cdhistor := 320; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13928244;
  v_dados(v_dados.last()).vr_vllanmto := 83.73;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13928244;
  v_dados(v_dados.last()).vr_vllanmto := 0.8;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13928244;
  v_dados(v_dados.last()).vr_vllanmto := 2.63;
  v_dados(v_dados.last()).vr_cdhistor := 1667; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13928244;
  v_dados(v_dados.last()).vr_vllanmto := 10.01;
  v_dados(v_dados.last()).vr_cdhistor := 320; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11674270;
  v_dados(v_dados.last()).vr_vllanmto := 15.91;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3156133;
  v_dados(v_dados.last()).vr_vllanmto := 76.15;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3156133;
  v_dados(v_dados.last()).vr_vllanmto := 24.24;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3156133;
  v_dados(v_dados.last()).vr_vllanmto := 190.16;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3156133;
  v_dados(v_dados.last()).vr_vllanmto := 18.89;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3156133;
  v_dados(v_dados.last()).vr_vllanmto := 92.61;
  v_dados(v_dados.last()).vr_cdhistor := 1667; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 125709;
  v_dados(v_dados.last()).vr_vllanmto := 66.17;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 125709;
  v_dados(v_dados.last()).vr_vllanmto := 301.82;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 125709;
  v_dados(v_dados.last()).vr_vllanmto := 6.06;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 125709;
  v_dados(v_dados.last()).vr_vllanmto := 13.68;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 125709;
  v_dados(v_dados.last()).vr_vllanmto := 2.42;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 125709;
  v_dados(v_dados.last()).vr_vllanmto := 72.91;
  v_dados(v_dados.last()).vr_cdhistor := 1667; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12389056;
  v_dados(v_dados.last()).vr_vllanmto := 7.4;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12389056;
  v_dados(v_dados.last()).vr_vllanmto := 21.59;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12389056;
  v_dados(v_dados.last()).vr_vllanmto := 37.29;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12389056;
  v_dados(v_dados.last()).vr_vllanmto := 0.19;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12389056;
  v_dados(v_dados.last()).vr_vllanmto := 0.7;
  v_dados(v_dados.last()).vr_cdhistor := 1667; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12389056;
  v_dados(v_dados.last()).vr_vllanmto := 3.45;
  v_dados(v_dados.last()).vr_cdhistor := 320; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 237914;
  v_dados(v_dados.last()).vr_vllanmto := 97.41;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 237914;
  v_dados(v_dados.last()).vr_vllanmto := 88.43;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 237914;
  v_dados(v_dados.last()).vr_vllanmto := 16.29;
  v_dados(v_dados.last()).vr_cdhistor := 1667; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 14079;
  v_dados(v_dados.last()).vr_vllanmto := 0.09;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 14079;
  v_dados(v_dados.last()).vr_vllanmto := 0.34;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 14079;
  v_dados(v_dados.last()).vr_vllanmto := 0.48;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 14079;
  v_dados(v_dados.last()).vr_vllanmto := 3.4;
  v_dados(v_dados.last()).vr_cdhistor := 1667; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 14079;
  v_dados(v_dados.last()).vr_vllanmto := 4.75;
  v_dados(v_dados.last()).vr_cdhistor := 320; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9468609;
  v_dados(v_dados.last()).vr_vllanmto := 21.56;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9468609;
  v_dados(v_dados.last()).vr_vllanmto := 33.63;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 89141;
  v_dados(v_dados.last()).vr_vllanmto := 240.53;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 89141;
  v_dados(v_dados.last()).vr_vllanmto := 878.09;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 89141;
  v_dados(v_dados.last()).vr_vllanmto := 129.88;
  v_dados(v_dados.last()).vr_cdhistor := 3967; ----

  FOR x IN (v_dados.first()) .. (v_dados.last()) LOOP
  
    OPEN btch0001.cr_crapdat(pr_cdcooper => v_dados(x).vr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
  
    OPEN cr_crapass(pr_cdcooper => v_dados(x).vr_cdcooper,
                    pr_nrdconta => v_dados(x).vr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    CLOSE cr_crapass;
  
    EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => v_dados(x).vr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_cdagenci => rw_crapass.cdagenci,
                                   pr_cdbccxlt => 100,
                                   pr_cdoperad => 1,
                                   pr_cdpactra => rw_crapass.cdagenci,
                                   pr_nrdolote => 600031,
                                   pr_nrdconta => v_dados(x).vr_nrdconta,
                                   pr_cdhistor => v_dados(x).vr_cdhistor,
                                   pr_vllanmto => v_dados(x).vr_vllanmto,
                                   pr_nrparepr => 0,
                                   pr_nrctremp => NULL,
                                   pr_nrseqava => 0,
                                   pr_des_reto => vr_des_reto,
                                   pr_tab_erro => vr_tab_erro);
  
    IF vr_des_reto <> 'OK' THEN
      RAISE vr_exc_saida;
    END IF;
  
  END LOOP;
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
    RAISE_application_error(-20500, vr_des_reto);
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
  
end;
