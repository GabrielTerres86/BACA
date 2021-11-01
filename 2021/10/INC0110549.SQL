declare
  vr_nrsequenlgi INTEGER;
  vr_nrsequenlgm INTEGER;

  CURSOR cr_craplcm is
    SELECT DTMVTOLT,
           CDAGENCI,
           CDBCCXLT,
           NRDOLOTE,
           NRDCONTA,
           NRDOCMTO,
           CDHISTOR,
           NRSEQDIG,
           VLLANMTO,
           NRDCTABB,
           CDPESQBB,
           DTREFERE,
           HRTRANSA,
           CDCOOPER,
           DTTRANS
      from CRAPLCM a
     WHERE a.Cdagenci = 20
       and a.nrdconta = 6212034
       and a.cdhistor = 1545
       and a.nrseqdig = 22648298
       and a.vllanmto = 764.96;

  rg_craplcm cr_craplcm%rowtype;

begin

  vr_nrsequenlgi := 1;
  vr_nrsequenlgm := 1;

  open cr_craplcm;
  fetch cr_craplcm
    into rg_craplcm;

  delete craplcm a
   where a.Cdagenci = 20
     and a.nrdconta = 6212034
     and a.cdhistor = 1545
     and a.nrseqdig = 22648298
     and a.vllanmto = 764.96;
  INSERT INTO cecred.craplgm
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     dstransa,
     dsorigem,
     nmdatela,
     flgtrans,
     dscritic,
     cdoperad,
     nmendter)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgm,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     'INC0110549 - Lançamento de débito da fatura não sensibilizada.',
     'AIMARO',
     '',
     1,
     ' ',
     1,
     ' ');

  vr_nrsequenlgm := vr_nrsequenlgm + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.DTMVTOLT',
     rg_craplcm.DTMVTOLT,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.CDAGENCI',
     rg_craplcm.CDAGENCI,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.CDBCCXLT',
     rg_craplcm.CDBCCXLT,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.NRDOLOTE',
     rg_craplcm.NRDOLOTE,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.NRDCONTA',
     rg_craplcm.NRDCONTA,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.NRDOCMTO',
     rg_craplcm.NRDOCMTO,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.CDHISTOR',
     rg_craplcm.CDHISTOR,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.NRSEQDIG',
     rg_craplcm.NRSEQDIG,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.VLLANMTO',
     rg_craplcm.VLLANMTO,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.NRDCTABB',
     rg_craplcm.NRDCTABB,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.CDPESQBB',
     rg_craplcm.CDPESQBB,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.DTREFERE',
     rg_craplcm.DTREFERE,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.HRTRANSA',
     rg_craplcm.HRTRANSA,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.CDCOOPER',
     rg_craplcm.CDCOOPER,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     hrtransa,
     nrseqcmp,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (1,
     6212034,
     1,
     vr_nrsequenlgi,
     to_date('12-07-2021', 'dd-mm-yyyy'),
     46608,
     1,
     'craplcm.DTTRANS',
     rg_craplcm.DTTRANS,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  close cr_craplcm;
      
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
END;

