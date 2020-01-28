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

  -- Credifoz: 436976
  vr_cdcooper := 11;
  vr_nrdconta := 436976;
  vr_vllanmto := 24.87;
  vr_cdhistor := 2721;
  
  -- Busca Data Atual da Cooperativa
  BEGIN
    SELECT dtmvtolt
    INTO   vr_dtmvtolt
    FROM   crapdat
    WHERE  cdcooper = vr_cdcooper;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao Buscar Data da Cooperatriva. Erro: '||SubStr(SQLERRM,1,255);
      RAISE vr_exc_saida; 
  END;

  BEGIN
    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - vr_vllanmto
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta
    RETURNING idprejuizo 
      INTO vr_idprejuizo;

    INSERT INTO tbcc_prejuizo_detalhe (
        dtmvtolt
       ,nrdconta
       ,cdhistor
       ,vllanmto
       ,dthrtran
       ,cdoperad
       ,cdcooper
       ,idprejuizo
       ,nrctremp
      )
      VALUES (
        vr_dtmvtolt
       ,vr_nrdconta
       ,vr_cdhistor
       ,vr_vllanmto
       ,SYSDATE
       ,1
       ,vr_cdcooper
       ,vr_idprejuizo
       ,0
      );

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
