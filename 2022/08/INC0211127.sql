DECLARE
  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  gr_nrdconta cecred.crapass.nrdconta%type;
  gr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;

  
  vc_dstransaSensbCRAPSLD             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSLD) por script - INC0211127';
  vc_dstransaSensbCRAPSDA             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSDA) por script - INC0211127';
  vc_dtinicioCRAPSDA                  CONSTANT DATE           := to_date('15/08/2022','dd/mm/yyyy');

  vr_erro_geralog EXCEPTION;
  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_crapsld is
    SELECT a.nrdconta
          ,a.vlsddisp
          ,contas.cdcooper
          ,contas.valor
      from CECRED.crapsld a
          ,(select 1 as cdcooper, 7093535 as nrdconta, -2410 as valor from dual) contas
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper;

  CURSOR cr_crapsda is
    SELECT a.nrdconta, a.vlsddisp, a.dtmvtolt, contas.valor, contas.cdcooper
      from CECRED.crapsda a
          ,(select 1 as cdcooper, 7093535 as nrdconta, -2410 as valor from dual) contas
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper
       AND a.dtmvtolt BETWEEN vc_dtinicioCRAPSDA AND
           TRUNC(SYSDATE)
     ORDER BY a.nrdconta, a.dtmvtolt asc;
     
  PROCEDURE pr_atualiza_sld(pr_cdcooper IN NUMBER,
                            pr_nrdconta IN NUMBER,
                            pr_vlsddisp IN NUMBER,
                            pr_valor    IN NUMBER,
                            pr_dscritic OUT VARCHAR2) IS
  vr_nrdrowid ROWID;
  
  BEGIN
  
    vr_nrdrowid := null;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                         pr_cdoperad => gr_cdoperad,
                         pr_dscritic => pr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => vc_dstransaSensbCRAPSLD,
                         pr_dttransa => gr_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => gr_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrdrowid => vr_nrdrowid);
                         
    IF pr_dscritic is NULL THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'crapsld.VLSDDISP',
                                pr_dsdadant => pr_vlsddisp,
                                pr_dsdadatu => pr_vlsddisp + pr_valor);
      UPDATE CECRED.crapsld a
         SET a.VLSDDISP = a.vlsddisp + pr_valor
       WHERE a.nrdconta = pr_nrdconta
         AND a.cdcooper = pr_cdcooper;
    END IF;       
  END;
    
  PROCEDURE pr_atualiza_sda(pr_cdcooper IN NUMBER,
                            pr_nrdconta IN NUMBER,
                            pr_dtmvtolt IN DATE,
                            pr_vlsddisp IN NUMBER,
                            pr_valor    IN NUMBER,
                            pr_dscritic OUT VARCHAR2) IS

  vr_nrdrowid ROWID;
  
  BEGIN
  
    vr_nrdrowid := null;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                         pr_cdoperad => gr_cdoperad,
                         pr_dscritic => pr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => vc_dstransaSensbCRAPSDA,
                         pr_dttransa => gr_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => gr_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrdrowid => vr_nrdrowid);
                         
    IF pr_dscritic is NULL THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'crapsda.DTMVTOLT',
                                pr_dsdadant => pr_dtmvtolt,
                                pr_dsdadatu => pr_dtmvtolt);
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'crapsda.VLSDDISP',
                                pr_dsdadant => pr_vlsddisp,
                                pr_dsdadatu => pr_vlsddisp + pr_valor);

        UPDATE CECRED.crapsda a
           SET a.VLSDDISP = a.vlsddisp + pr_valor
         WHERE a.nrdconta = pr_nrdconta
           AND a.cdcooper = pr_cdcooper
           AND a.dtmvtolt = pr_dtmvtolt;
    END IF;       
  END;
  


BEGIN
  gr_dttransa := trunc(sysdate);
  gr_hrtransa := GENE0002.fn_busca_time;

  FOR rg_crapsld IN cr_crapsld LOOP
    gr_nrdconta := rg_crapsld.nrdconta;
    gr_cdcooper := rg_crapsld.cdcooper;
    
    pr_atualiza_sld(gr_cdcooper,
                    gr_nrdconta,
                    rg_crapsld.vlsddisp,
                    rg_crapsld.valor,
                    vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_erro_geralog;
    END IF;
       
  END LOOP;

  FOR rg_crapsda IN cr_crapsda LOOP
    
    gr_nrdconta := rg_crapsda.nrdconta;
    gr_cdcooper := rg_crapsda.cdcooper;
    
    pr_atualiza_sda(gr_cdcooper,
                    gr_nrdconta,
                    rg_crapsda.dtmvtolt,
                    rg_crapsda.vlsddisp,
                    rg_crapsda.valor,
                    vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_erro_geralog;
    END IF;

   END LOOP;
   
  
  COMMIT;
  
EXCEPTION
  WHEN vr_erro_geralog THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao gerar log para cooperativa/conta (' ||
                            gr_cdcooper || '/' || gr_nrdconta || ')- ' ||  vr_dscritic);
    
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1 , 64);    
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar saldo da cooperativa/conta (' ||
                            gr_cdcooper || '/' || gr_nrdconta || ') - ' ||  ' - ' || v_code || ' - ' || v_errm);
END;
