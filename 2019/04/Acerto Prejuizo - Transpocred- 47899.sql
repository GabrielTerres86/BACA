DECLARE
  pr_cdcooper   craplcm.cdcooper%TYPE := 9;
  pr_nrdconta   craplcm.nrdconta%TYPE := 47899;
  pr_vllanmto   craplcm.vllanmto%TYPE := 1673.02;
  pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
--  pr_cdhistor IN  craplcm.cdhistor%TYPE
  pr_cdoperad   craplcm.cdoperad%TYPE := 1;
  pr_nrdocmto   craplcm.nrdocmto%type := 1;
  pr_cdagenci   craplcm.cdagenci%type := 1;
  pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
  pr_nrdctabb   craplcm.nrdctabb%TYPE := 56111;
  pr_cdcritic   NUMBER;
  pr_dscritic   VARCHAR2(10000);
  --
  vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;
  --
  vr_exc_saida      EXCEPTION;

BEGIN
  BEGIN
    SELECT dtmvtolt
      INTO pr_dtmvtolt
      FROM crapdat
     WHERE cdcooper = pr_cdcooper;
  EXCEPTION
  WHEN OTHERS THEN
    pr_dscritic := 'Erro ao buscar DTMVTOLT = '||SQLERRM;
  END;
  --
  BEGIN
    SELECT a.idprejuizo
      INTO vr_idprejuizo
      FROM tbcc_prejuizo a
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
  EXCEPTION
  WHEN OTHERS THEN
    pr_dscritic := 'Erro ao buscar idprejuizo = '||SQLERRM;
  END;
  --
  BEGIN
    INSERT INTO tbcc_prejuizo_detalhe
           (dtmvtolt
           ,nrdconta
           ,cdhistor
           ,vllanmto
           ,dthrtran
           ,cdoperad
           ,cdcooper
           ,idprejuizo
           ,dsjustificativa
           )
    VALUES (pr_dtmvtolt
           ,pr_nrdconta
           ,2722
           ,pr_vllanmto
           ,SYSDATE
           ,pr_cdoperad
           ,pr_cdcooper
           ,vr_idprejuizo
           ,'Pagamento Indevido'
           );
  EXCEPTION
  WHEN OTHERS THEN
    pr_cdcritic := NULL;
    pr_dscritic := 'Erro de insert na tbcc_prejuizo_detalhe: '||SQLERRM;
    RAISE vr_exc_saida;
  END;
  --
  COMMIT;
EXCEPTION
WHEN vr_exc_saida THEN
  if pr_cdcritic is not null and pr_dscritic is null then
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
  end if;
  rollback;
  RAISE_APPLICATION_ERROR(-20500,pr_dscritic);
WHEN OTHERS THEN
  pr_dscritic := 'Erro ao atualizar CRAPSLD = '||SQLERRM;
  rollback;
  RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
end;
