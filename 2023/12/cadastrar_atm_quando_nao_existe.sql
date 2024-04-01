DECLARE

  vr_cdcooper INTEGER := 9;
  vr_cdagenci INTEGER := 1;
  vr_nrterfin INTEGER := 10;

  pr_nmnarede VARCHAR2(2000) := NULL;
  pr_nmterfin VARCHAR2(2000) := 'Nome TAA';
  pr_nrdendip VARCHAR2(2000) := '0.0.0.0';
  pr_nrtempor INTEGER := 120;
  pr_qtcasset INTEGER := 4;
  pr_dsfabtfn VARCHAR2(2000) := 'DIEBOLD';
  pr_dsmodelo VARCHAR2(2000) := 'ATM 4534-336';
  pr_dsdserie VARCHAR2(2000) := NULL;
  pr_flgntcem INTEGER := 0;

  CURSOR cr_crapdat(pr_cdcooper IN INTEGER) IS
    SELECT dat.*
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;

BEGIN

  OPEN cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH cr_crapdat
    INTO rw_crapdat;
  CLOSE cr_crapdat;

  INSERT INTO craptfn
    (cdcooper
    ,cdagenci
    ,cdsitfin
    ,nrterfin
    ,tpterfin
    ,nmnarede
    ,nrdendip
    ,nmterfin
    ,nrtempor
    ,qtcasset
    ,dsfabtfn
    ,dsmodelo
    ,dsdserie
    ,flsistaa
    ,flgntcem)
  VALUES
    (vr_cdcooper
    ,vr_cdagenci
    ,8
    ,vr_nrterfin
    ,6
    ,LOWER(TRIM(pr_nmnarede))
    ,TRIM(pr_nrdendip)
    ,UPPER(pr_nmterfin)
    ,pr_nrtempor
    ,pr_qtcasset
    ,UPPER(pr_dsfabtfn)
    ,UPPER(pr_dsmodelo)
    ,pr_dsdserie
    ,1 /* inicial desbloqueado */
    ,pr_flgntcem);

  -- Inserir o saldo do terminal financeiro para o dia atual
  INSERT INTO crapstf
    (cdcooper
    ,nrterfin
    ,dtmvtolt)
  VALUES
    (vr_cdcooper
    ,vr_nrterfin
    ,rw_crapdat.dtmvtolt);

  -- Inserir o saldo do terminal financeiro para o dia anterior
  INSERT INTO crapstf
    (cdcooper
    ,nrterfin
    ,dtmvtolt)
  VALUES
    (vr_cdcooper
    ,vr_nrterfin
    ,rw_crapdat.dtmvtoan);

  COMMIT;

END;