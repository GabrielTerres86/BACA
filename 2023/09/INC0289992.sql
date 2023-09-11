Declare 
  
  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  gr_nrdconta cecred.crapass.nrdconta%type;
  gr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid ROWID;


  vc_dstransaSensbCRAPSLD             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSLD) por script - INC0289992';
  vc_dstransaSensbCRAPSDA             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSDA) por script - INC0289992';
  vc_dtinicioCRAPSDA                  CONSTANT DATE           := to_date('28/07/2023','dd/mm/yyyy');

  vr_erro_geralog EXCEPTION;
  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_crapsld is
    SELECT a.nrdconta
          ,a.vlsddisp
          ,contas.cdcooper
          ,contas.valor
      from CECRED.crapsld a
          ,(select 10 as cdcooper, 38350    as nrdconta, -264.01   as valor from dual
            union all
            select 10 as cdcooper, 42170    as nrdconta, -309.79   as valor from dual
			union all
			select 10 as cdcooper, 57185    as nrdconta, -302.39   as valor from dual
            union all
			select 10 as cdcooper, 61654    as nrdconta, -173.52   as valor from dual
			union all
			select 10 as cdcooper, 153141   as nrdconta, -309.12   as valor from dual
			union all
			select 10 as cdcooper, 155225   as nrdconta, -173.86   as valor from dual
			union all
			select 10 as cdcooper, 197378   as nrdconta, -154.06   as valor from dual
			union all
			select 10 as cdcooper, 224553   as nrdconta, -617.86   as valor from dual
			union all
			select 10 as cdcooper, 226530   as nrdconta, -86.27    as valor from dual
			union all
			select 10 as cdcooper, 15012921 as nrdconta, -92.71    as valor from dual
			union all
			select 10 as cdcooper, 15258653 as nrdconta, -216.82   as valor from dual
			union all
			select 10 as cdcooper, 15901939 as nrdconta, -2263.72 as valor from dual
			union all
			select 10 as cdcooper, 16662784 as nrdconta, -92.71    as valor from dual
			union all
			select 10 as cdcooper, 16791754 as nrdconta, -276.17   as valor from dual
			union all
			select 10 as cdcooper, 16796500 as nrdconta, -521.7    as valor from dual
			union all
			select 10 as cdcooper, 17049644 as nrdconta, -619.15   as valor from dual
			union all
			select 10 as cdcooper, 17150019 as nrdconta, -275.88   as valor from dual
			union all
			select 10 as cdcooper, 16693884 as nrdconta, -347.30   as valor from dual
			union all
			select 10 as cdcooper, 16690818 as nrdconta, -617.86   as valor from dual
			union all
			select 10 as cdcooper, 16670051 as nrdconta, -309.79   as valor from dual
			) contas
			
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper;

  CURSOR cr_crapsda is
    SELECT a.nrdconta, a.vlsddisp, a.dtmvtolt, contas.valor, contas.cdcooper
      from CECRED.crapsda a
          ,(select 10 as cdcooper, 38350    as nrdconta, -264.01   as valor from dual
            union all
            select 10 as cdcooper, 42170    as nrdconta, -309.79   as valor from dual
			union all
			select 10 as cdcooper, 57185    as nrdconta, -302.39   as valor from dual
            union all
			select 10 as cdcooper, 61654    as nrdconta, -173.52   as valor from dual
			union all
			select 10 as cdcooper, 153141   as nrdconta, -309.12   as valor from dual
			union all
			select 10 as cdcooper, 155225   as nrdconta, -173.86   as valor from dual
			union all
			select 10 as cdcooper, 197378   as nrdconta, -154.06   as valor from dual
			union all
			select 10 as cdcooper, 224553   as nrdconta, -617.86   as valor from dual
			union all
			select 10 as cdcooper, 226530   as nrdconta, -86.27    as valor from dual
			union all
			select 10 as cdcooper, 15012921 as nrdconta, -92.71    as valor from dual
			union all
			select 10 as cdcooper, 15258653 as nrdconta, -216.82   as valor from dual
			union all
			select 10 as cdcooper, 15901939 as nrdconta, -2263.72 as valor from dual
			union all
			select 10 as cdcooper, 16662784 as nrdconta, -92.71    as valor from dual
			union all
			select 10 as cdcooper, 16791754 as nrdconta, -276.17   as valor from dual
			union all
			select 10 as cdcooper, 16796500 as nrdconta, -521.7    as valor from dual
			union all
			select 10 as cdcooper, 17049644 as nrdconta, -619.15   as valor from dual
			union all
			select 10 as cdcooper, 17150019 as nrdconta, -275.88   as valor from dual
			union all
			select 10 as cdcooper, 16693884 as nrdconta, -347.30   as valor from dual
			union all
			select 10 as cdcooper, 16690818 as nrdconta, -617.86   as valor from dual
			union all
			select 10 as cdcooper, 16670051 as nrdconta, -309.79   as valor from dual
			) contas
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper
       AND a.dtmvtolt BETWEEN vc_dtinicioCRAPSDA AND TRUNC(SYSDATE)
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
         SET a.VLSDDISP = a.VLSDDISP + pr_valor
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
           SET a.VLSDDISP = a.VLSDDISP + pr_valor
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
/
