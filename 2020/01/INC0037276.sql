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

  -- Viacredi: 9790470
  OPEN cr_tbcc_prejuizo_detalhe(pr_cdcooper => 1
                               ,pr_nrdconta => 9790470
                               ,pr_cdhistor => 2408
                               ,pr_dtmvtolt => to_date('21/01/2020','dd/mm/rrrr')
                               ,pr_vllanmto => 352.26);
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

    -- Liquida prejuizo
    UPDATE tbcc_prejuizo tbprj
       SET tbprj.vlsldlib     = 0
          ,tbprj.vlsdprej     = 0
          ,tbprj.vljuprej     = 0
         , tbprj.dtliquidacao = to_date('29/11/2019','dd/mm/rrrr')
     WHERE tbprj.cdcooper     = vr_cdcooper
       AND tbprj.nrdconta     = vr_nrdconta;
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
