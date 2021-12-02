DECLARE
  vr_incidente VARCHAR2(15) := 'INC0115197';
  vr_cdhistor  craphis.cdhistor%TYPE := 2971;
  vr_idx       NUMBER;

  TYPE typ_reg_conta IS RECORD(
    cdcooper crapcop.cdcooper%TYPE,
    nrdconta crapass.nrdconta%TYPE,
    vllanmto tbcc_prejuizo.vlsdprej%TYPE);

  TYPE typ_tab_conta IS TABLE OF typ_reg_conta INDEX BY PLS_INTEGER;

  vr_tab_conta typ_tab_conta;

  PROCEDURE registrarVerLog(pr_cdcooper IN crawepr.cdcooper%TYPE
                           ,pr_nrdconta IN crawepr.nrdconta%TYPE
                           ,pr_dstransa IN VARCHAR2
                           ,pr_dscampo  IN VARCHAR
                           ,pr_antes    IN VARCHAR2
                           ,pr_depois   IN VARCHAR2) IS
    vr_dstransa       craplgm.dstransa%TYPE;
    vr_descitem       craplgi.nmdcampo%TYPE;
    vr_nrdrowid       ROWID;
    vr_risco_anterior VARCHAR2(10);
  BEGIN
    vr_dstransa := pr_dstransa;
  
    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_dstransa => vr_dstransa,
                         pr_dscritic => '',
                         pr_cdoperad => '1',
                         pr_dsorigem => 'SCRIPT',
                         pr_dttransa => trunc(SYSDATE),
                         pr_flgtrans => 0,
                         pr_hrtransa => gene0002.fn_busca_time,
                         pr_idseqttl => 1,
                         pr_nmdatela => '',
                         pr_nrdrowid => vr_nrdrowid);
  
    IF TRIM(pr_dscampo) IS NOT NULL THEN
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => pr_dscampo,
                                pr_dsdadant => pr_antes,
                                pr_dsdadatu => pr_depois);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
  END registrarVerLog;

  PROCEDURE prc_gera_lct(prm_cdcooper IN craplcm.cdcooper%TYPE
                        ,prm_nrdconta IN craplcm.nrdconta%TYPE
                        ,prm_vllanmto IN craplcm.vllanmto%TYPE
                        ,prm_cdhistor IN craplcm.cdhistor%TYPE) IS
    vr_dtmvtolt   craplcm.dtmvtolt%TYPE;
    vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;
    vr_cdhistor   tbcc_prejuizo_detalhe.cdhistor%TYPE;
    vr_erro EXCEPTION;
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(1000);
  BEGIN
    BEGIN
      SELECT dtmvtolt
        INTO vr_dtmvtolt
        FROM crapdat
       WHERE cdcooper = prm_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar Data da Cooperatriva. Erro: ' || substr(SQLERRM, 1, 255);
        RAISE vr_erro;
    END;
  
    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (LCM VLR):');
    dbms_output.put_line('     Cooperativa....: ' || prm_cdcooper);
    dbms_output.put_line('     Conta..........: ' || prm_nrdconta);
    dbms_output.put_line('     Data...........: ' || to_char(vr_dtmvtolt, 'dd/mm/yyyy'));
    dbms_output.put_line('     Valor..........: ' || prm_vllanmto);
    dbms_output.put_line(' ');
  
    BEGIN
      SELECT a.idprejuizo
        INTO vr_idprejuizo
        FROM tbcc_prejuizo a
       WHERE a.cdcooper = prm_cdcooper
         AND a.nrdconta = prm_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar chave prejuizo. Erro: ' || substr(SQLERRM, 1, 255);
        RAISE vr_erro;
    END;
  
    prej0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => prm_cdcooper,
                                      pr_nrdconta   => prm_nrdconta,
                                      pr_dtmvtolt   => vr_dtmvtolt,
                                      pr_cdhistor   => prm_cdhistor,
                                      pr_idprejuizo => vr_idprejuizo,
                                      pr_vllanmto   => prm_vllanmto,
                                      pr_dthrtran   => SYSDATE,
                                      pr_cdcritic   => vr_cdcritic,
                                      pr_dscritic   => vr_dscritic);
    IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_erro;
    END IF;
    
    registrarVerLog(pr_cdcooper => prm_cdcooper,
                    pr_nrdconta => prm_nrdconta,
                    pr_dstransa => 'Ajuste Contabil - ' || to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'),
                    pr_dscampo  => 'pc_gera_lcto_extrato_prj',
                    pr_antes    => '',
                    pr_depois   => prm_vllanmto);        
    COMMIT;
    
    dbms_output.put_line('   Lançamento do Histórico ' || prm_cdhistor || ' efetuado com Sucesso na Coop/Conta ' || prm_cdcooper || '/' || prm_nrdconta || '.'); 
  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('prc_gera_lct: ' || vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      raise_application_error(-20001, vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('prc_gera_lct: Erro: ' || substr(SQLERRM, 1, 255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      raise_application_error(-20002, 'Erro Geral no prc_gera_lct. Erro: ' || substr(SQLERRM, 1, 255));
  END prc_gera_lct;
BEGIN
  --------------------------- BLOCO PRINCIPAL ---------------------------
  dbms_output.put_line('Script iniciado em ' || to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- ' || vr_incidente || ' - INICIO --------');
  -----------------------------------------------------------------------
  vr_tab_conta(1).cdcooper := 2;
  vr_tab_conta(1).nrdconta := 582956;
  vr_tab_conta(1).vllanmto := 32.22;

  vr_tab_conta(2).cdcooper := 11;
  vr_tab_conta(2).nrdconta := 428647;
  vr_tab_conta(2).vllanmto := 27.45;

  vr_tab_conta(3).cdcooper := 11;
  vr_tab_conta(3).nrdconta := 234729;
  vr_tab_conta(3).vllanmto := 22.87;

  vr_tab_conta(4).cdcooper := 11;
  vr_tab_conta(4).nrdconta := 389250;
  vr_tab_conta(4).vllanmto := 19.50;

  vr_tab_conta(5).cdcooper := 6;
  vr_tab_conta(5).nrdconta := 79979;
  vr_tab_conta(5).vllanmto := 11.34;

  vr_tab_conta(6).cdcooper := 6;
  vr_tab_conta(6).nrdconta := 46442;
  vr_tab_conta(6).vllanmto := 3.00;

  vr_tab_conta(7).cdcooper := 16;
  vr_tab_conta(7).nrdconta := 289078;
  vr_tab_conta(7).vllanmto := 25.62;

  vr_tab_conta(8).cdcooper := 16;
  vr_tab_conta(8).nrdconta := 429201;
  vr_tab_conta(8).vllanmto := 10.00;

  vr_tab_conta(9).cdcooper := 16;
  vr_tab_conta(9).nrdconta := 563404;
  vr_tab_conta(9).vllanmto := 27.00;

  vr_idx := vr_tab_conta.first;
  WHILE vr_idx IS NOT NULL LOOP
    prc_gera_lct(prm_cdcooper => vr_tab_conta(vr_idx).cdcooper,
                 prm_nrdconta => vr_tab_conta(vr_idx).nrdconta,
                 prm_vllanmto => vr_tab_conta(vr_idx).vllanmto,
                 prm_cdhistor => vr_cdhistor);
    
    vr_idx := vr_tab_conta.next(vr_idx);
  END LOOP;
  -----------------------------------------------------------------------
  dbms_output.put_line('-------- ' || vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
  -----------------------------------------------------------------------
  dbms_output.put_line(' ');
  dbms_output.put_line('Script finalizado com Sucesso em ' || to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
  ------------------------ BLOCO PRINCIPAL - FIM ------------------------
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: ' || substr(SQLERRM, 1, 255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    raise_application_error(-20002, 'Erro Geral no Script. Erro: ' || substr(SQLERRM, 1, 255));
END;