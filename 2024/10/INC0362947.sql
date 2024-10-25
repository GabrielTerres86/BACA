Declare 
  
  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  gr_nrdconta cecred.crapass.nrdconta%type;
  gr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid ROWID;


  vc_dstransaSensbCRAPSLD             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSLD) por script - INC0362947';

  vr_erro_geralog EXCEPTION;
  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_crapsld is
    SELECT a.nrdconta
          ,a.vlsddisp
          ,contas.cdcooper     
          ,contas.valor
      from CECRED.crapsld a
          ,(select 1 as cdcooper, 10736158 as nrdconta, 0.46 as valor from dual)  contas
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper;

 



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
         SET a.VLSDDISP = a.VLSDDISP + pr_valor
       WHERE a.nrdconta = pr_nrdconta
         AND a.cdcooper = pr_cdcooper;
     
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
/
