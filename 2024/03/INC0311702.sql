Declare 
  
  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  gr_nrdconta cecred.crapass.nrdconta%type;
  gr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid ROWID;


  vc_dstransaSensbCRAPSLD             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSLD) por script - INC0311702b';

  vr_erro_geralog EXCEPTION;
  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_crapsld is
    SELECT a.nrdconta
          ,a.vlsddisp
          ,contas.cdcooper     
          ,contas.valor
      from CECRED.crapsld a
          ,(select 1 as cdcooper, 1975293    as nrdconta,  -512.51   as valor from dual
            union all
            select 1 as cdcooper, 1995251    as nrdconta,  -1771.31   as valor from dual
			union all
			select 1 as cdcooper, 2223589    as nrdconta,  -257.82   as valor from dual
            union all
			select 1 as cdcooper, 2858096    as nrdconta,  -479.11   as valor from dual
			union all
			select 1 as cdcooper, 3069540   as nrdconta,  -1.8   as valor from dual
			union all
			select 1 as cdcooper, 3555674   as nrdconta,  -0.31   as valor from dual
			union all
			select 1 as cdcooper, 3704815   as nrdconta,  -0.48   as valor from dual
			union all
			select 1 as cdcooper, 3719715   as nrdconta,  -407.06   as valor from dual
			union all
			select 1 as cdcooper, 3993000   as nrdconta,  -92.9    as valor from dual
			union all
			select 1 as cdcooper, 6589014 as nrdconta,   -250.14    as valor from dual
			union all
			select 1 as cdcooper, 6908179 as nrdconta,  -9.14 as valor from dual
			union all
			select 1 as cdcooper, 7454058 as nrdconta, -1.83 as valor from dual
			union all
			select 1 as cdcooper, 7626819 as nrdconta, -183.83 as valor from dual
			union all
			select 1 as cdcooper, 8469164 as nrdconta, -0.68 as valor from dual
			union all
			select 1 as cdcooper, 8604053 as nrdconta, -165.63 as valor from dual
			union all
			select 1 as cdcooper, 8743037 as nrdconta, -123.52 as valor from dual
			union all
			select 1 as cdcooper, 8985375 as nrdconta, -122.63 as valor from dual
			union all
			select 1 as cdcooper, 9163794 as nrdconta, -153.03 as valor from dual
			union all
			select 1 as cdcooper, 9226117 as nrdconta, -102 as valor from dual
			union all
			select 1 as cdcooper, 9296778 as nrdconta, -121.49 as valor from dual
			union all
			select 1 as cdcooper, 9382143 as nrdconta, -255.4 as valor from dual
			union all
			select 1 as cdcooper, 9389806 as nrdconta, -0.08 as valor from dual
			union all
			select 1 as cdcooper, 9424059 as nrdconta, -0.26 as valor from dual
			union all
			select 1 as cdcooper, 9593047 as nrdconta, -132.93 as valor from dual
			union all
			select 1 as cdcooper, 9686703 as nrdconta, -0.29 as valor from dual
			union all
			select 1 as cdcooper, 9688056 as nrdconta, -0.65 as valor from dual
			union all
			select 1 as cdcooper, 9957570 as nrdconta, -2583.05 as valor from dual
			union all
			select 1 as cdcooper, 10107592 as nrdconta, -761.14 as valor from dual
			union all
			select 1 as cdcooper, 10318100 as nrdconta, -252.99 as valor from dual
			union all
			select 1 as cdcooper, 10432639 as nrdconta, -371.94 as valor from dual
			union all
			select 1 as cdcooper, 10920994 as nrdconta, -1324.83 as valor from dual
			union all
			select 1 as cdcooper, 11099917 as nrdconta, -304.25 as valor from dual
			union all
			select 1 as cdcooper, 11246200 as nrdconta, -0.59 as valor from dual
			union all
			select 1 as cdcooper, 11282819 as nrdconta, -370.59 as valor from dual
			union all
			select 1 as cdcooper, 11667397 as nrdconta, -99.54 as valor from dual
			union all
			select 1 as cdcooper, 11682663 as nrdconta, -1092.74 as valor from dual
			union all
			select 1 as cdcooper, 11886315 as nrdconta, -408.35 as valor from dual
			union all
			select 1 as cdcooper, 12026816 as nrdconta, -1686.45 as valor from dual
			union all
			select 1 as cdcooper, 12311855 as nrdconta, -265.37 as valor from dual
			union all
			select 1 as cdcooper, 13538098 as nrdconta, -5.68 as valor from dual
			union all
			select 1 as cdcooper, 13754041 as nrdconta, -2.70 as valor from dual
			union all
			select 1 as cdcooper, 15588467 as nrdconta, -0.07 as valor from dual
			union all 
			select 1 as cdcooper, 17917280 as nrdconta, -140.87 as valor from dual
			) contas
			
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
