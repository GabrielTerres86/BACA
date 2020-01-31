DECLARE
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

  -- Viacredi: 8471657
  FOR rw_tbcc_prejuizo_detalhe IN (
    SELECT cdcooper, nrdconta, idlancto, vllanmto
      FROM tbcc_prejuizo_detalhe
     WHERE cdcooper = 1
       AND nrdconta = 8471657
       AND cdhistor = 2408
       AND dtmvtolt = to_date('30/12/2019','dd/mm/rrrr')
       AND vllanmto = 14200
    )
  LOOP
     vr_cdcooper := rw_tbcc_prejuizo_detalhe.cdcooper;
     vr_nrdconta := rw_tbcc_prejuizo_detalhe.nrdconta;
     vr_idlancto := rw_tbcc_prejuizo_detalhe.idlancto;
     BEGIN
       DELETE FROM tbcc_prejuizo_detalhe
        WHERE idlancto = vr_idlancto
          AND nrdconta = vr_nrdconta
          AND cdcooper = vr_cdcooper;
     END;
  END LOOP;

  BEGIN
    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - 85200
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta;
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
