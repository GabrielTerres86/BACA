DECLARE
  CURSOR cr_his (pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                ,pr_cdhistor IN cecred.craphis.cdhistor%TYPE)IS
    SELECT t.cdhistor, t.dshistor, t.indebcre
      FROM cecred.craphis t
     WHERE t.cdcooper = pr_cdcooper
       AND t.cdhistor = pr_cdhistor;
  rw_his  cr_his%ROWTYPE;
  
  CURSOR cr_sld_prj (pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                    ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE)IS
    SELECT t.vlsdprej, t.idprejuizo
      FROM cecred.tbcc_prejuizo t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta;
  rw_sld_prj  cr_sld_prj%ROWTYPE;

  vr_indebcre  cecred.craphis.indebcre%TYPE;
  vr_found     BOOLEAN;

  vr_incidente VARCHAR2(15);
  vr_cdcooper  cecred.crapcop.cdcooper%TYPE;
  vr_nrdconta  cecred.crapass.nrdconta%TYPE;
  vr_vllanmto  cecred.tbcc_prejuizo.vlsdprej%TYPE;
  vr_cdhistor  cecred.craphis.cdhistor%TYPE;
  vr_idlancto  cecred.tbcc_prejuizo_detalhe.idlancto%TYPE;
  vr_nrdocmto  INTEGER;
  vr_incrineg  INTEGER;
  vr_tab_retorno  cecred.LANC0001.typ_reg_retorno;
  rw_crapdat   cecred.BTCH0001.cr_crapdat%ROWTYPE;
  
  vr_cdcritic  NUMBER;
  vr_dscritic  VARCHAR2(1000);
  vr_excerro   EXCEPTION;
  vr_des_erro  VARCHAR2(1000);
  
BEGIN
  
  vr_cdcooper  := 14;
  
  OPEN cecred.BTCH0001.cr_crapdat(vr_cdcooper);
  FETCH cecred.BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE cecred.BTCH0001.cr_crapdat;

  vr_nrdocmto  := fn_sequence('CRAPLCT',
                              'NRDOCMTO',
                              vr_cdcooper || ';' ||
                              TRIM(to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY')) || ';' || 61);
  
  vr_nrdconta  := 83088920;
  vr_vllanmto  := 10000;
  vr_cdhistor  := 362;
  
  cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => vr_cdcooper,
                                           pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                           pr_cdagenci    => 1,
                                           pr_cdbccxlt    => 1,
                                           pr_nrdolote    => 600040,
                                           pr_nrdctabb    => vr_nrdconta,
                                           pr_nrdocmto    => vr_nrdocmto,
                                           pr_cdhistor    => vr_cdhistor,
                                           pr_vllanmto    => vr_vllanmto,
                                           pr_nrdconta    => vr_nrdconta,
                                           pr_hrtransa    => cecred.gene0002.fn_busca_time,
                                           pr_cdorigem    => 0,
                                           pr_inprolot    => 1,
                                           pr_tab_retorno => vr_tab_retorno,
                                           pr_incrineg    => vr_incrineg,
                                           pr_cdcritic    => vr_cdcritic,
                                           pr_dscritic    => vr_dscritic);
    
  IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_excerro;
  END IF;
                     
  COMMIT;

EXCEPTION   
  WHEN vr_excerro THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||vr_dscritic);
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||vr_dscritic);    
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));    
END;
