DECLARE
  CURSOR cr_tbcc_prejuizo_detalhe(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE
                                 ,pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE
                                 ,pr_cdhistor IN tbcc_prejuizo_detalhe.cdhistor%TYPE
                                 ,pr_dtmvtolt IN tbcc_prejuizo_detalhe.dtmvtolt%TYPE
                                 ,pr_vllanmto IN tbcc_prejuizo_detalhe.vllanmto%TYPE) IS
    SELECT cdcooper, nrdconta, idlancto, vllanmto
      FROM tbcc_prejuizo_detalhe
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND cdhistor = pr_cdhistor
       AND dtmvtolt = pr_dtmvtolt
       AND vllanmto = pr_vllanmto;
  rw_tbcc_prejuizo_detalhe cr_tbcc_prejuizo_detalhe%ROWTYPE;

  vr_cdcritic   NUMBER;
  vr_dscritic   VARCHAR2(10000);
  vr_exc_saida  EXCEPTION;
  vr_idlancto   tbcc_prejuizo_detalhe.idlancto%TYPE;
  vr_vllanmto   tbcc_prejuizo_detalhe.vllanmto%TYPE;
  vr_cdcooper   tbcc_prejuizo_detalhe.cdcooper%TYPE;
  vr_nrdconta   tbcc_prejuizo_detalhe.nrdconta%TYPE;
  vr_dtmvtolt   craplcm.dtmvtolt%TYPE;
  vr_cdhistor   tbcc_prejuizo_detalhe.cdhistor%TYPE;
  vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;

BEGIN

  dbms_output.put_line('Inicio');

  -- Viacredi: 9246134
  OPEN cr_tbcc_prejuizo_detalhe(pr_cdcooper => 1
                               ,pr_nrdconta => 9246134
                               ,pr_cdhistor => 2408
                               ,pr_dtmvtolt => to_date('09/12/2019','dd/mm/rrrr')
                               ,pr_vllanmto => 500);
  FETCH cr_tbcc_prejuizo_detalhe INTO rw_tbcc_prejuizo_detalhe;
  IF cr_tbcc_prejuizo_detalhe%FOUND THEN
    vr_cdcooper := rw_tbcc_prejuizo_detalhe.cdcooper;
    vr_nrdconta := rw_tbcc_prejuizo_detalhe.nrdconta;
    vr_idlancto := rw_tbcc_prejuizo_detalhe.idlancto;
  ELSE
    vr_dscritic := 'Lançamento não encontrado';
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_tbcc_prejuizo_detalhe;

  BEGIN
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE idlancto = vr_idlancto
       AND nrdconta = vr_nrdconta
       AND cdcooper = vr_cdcooper;

    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - 1000
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta;
  END;

  OPEN cr_tbcc_prejuizo_detalhe(pr_cdcooper => 1
                               ,pr_nrdconta => 9246134
                               ,pr_cdhistor => 2408
                               ,pr_dtmvtolt => to_date('16/12/2019','dd/mm/rrrr')
                               ,pr_vllanmto => 500);
  FETCH cr_tbcc_prejuizo_detalhe INTO rw_tbcc_prejuizo_detalhe;
  IF cr_tbcc_prejuizo_detalhe%FOUND THEN
    vr_cdcooper := rw_tbcc_prejuizo_detalhe.cdcooper;
    vr_nrdconta := rw_tbcc_prejuizo_detalhe.nrdconta;
    vr_idlancto := rw_tbcc_prejuizo_detalhe.idlancto;
  ELSE
    vr_dscritic := 'Lançamento não encontrado';
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_tbcc_prejuizo_detalhe;

  BEGIN
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE idlancto = vr_idlancto
       AND nrdconta = vr_nrdconta
       AND cdcooper = vr_cdcooper;
  END;

  COMMIT;

  dbms_output.put_line('Término');

EXCEPTION

  WHEN vr_exc_saida THEN
    ROLLBACK;
    dbms_output.put_line('Mensagem: ' || vr_dscritic);
    RAISE_APPLICATION_ERROR(-20500,vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    vr_dscritic := 'Erro genérico: ' || SQLERRM;
    dbms_output.put_line('Mensagem: ' || vr_dscritic);
    RAISE_APPLICATION_ERROR(-20510,vr_dscritic);

END;
