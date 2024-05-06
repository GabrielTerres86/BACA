Declare 
  
  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  gr_nrdconta cecred.crapass.nrdconta%type;
  gr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid ROWID;


  vc_dstransaSensbCRAPSLD             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSLD) por script - INC0311702';
  vc_dstransaSensbCRAPSDA             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSDA) por script - INC0311702';
  vc_dtinicioCRAPSDA                  CONSTANT DATE           := to_date('22/01/2023','dd/mm/yyyy');

  vr_erro_geralog EXCEPTION;
  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_crapsld is
    SELECT a.nrdconta
          ,a.vlsddisp
          ,contas.cdcooper     
          ,contas.valor
      from CECRED.crapsld a
          ,(select 1 as cdcooper, 98024647    as nrdconta,  512.51   as valor from dual
            union all
            select 1 as cdcooper, 98004689    as nrdconta,  1771.31   as valor from dual
			union all
			select 1 as cdcooper, 97776351    as nrdconta,  257.82   as valor from dual
            union all
			select 1 as cdcooper, 97141844    as nrdconta,  479.11   as valor from dual
			union all
			select 1 as cdcooper, 96930390   as nrdconta,  1.8   as valor from dual
			union all
			select 1 as cdcooper, 96444266   as nrdconta,  0.31   as valor from dual
			union all
			select 1 as cdcooper, 96295120   as nrdconta,  0.48   as valor from dual
			union all
			select 1 as cdcooper, 96280220   as nrdconta,  407.06   as valor from dual
			union all
			select 1 as cdcooper, 96006935   as nrdconta,  92.9    as valor from dual
			union all
			select 1 as cdcooper, 93410921 as nrdconta,   250.14    as valor from dual
			union all
			select 1 as cdcooper, 93091761 as nrdconta,  9.14 as valor from dual
			union all
			select 1 as cdcooper, 92545882 as nrdconta, 1.83 as valor from dual
			union all
			select 1 as cdcooper, 92373127 as nrdconta, 183.83 as valor from dual
			union all
			select 1 as cdcooper, 91530776 as nrdconta, 0.68 as valor from dual
			union all
			select 1 as cdcooper, 91395887 as nrdconta, 165.63 as valor from dual
			union all
			select 1 as cdcooper, 91256909 as nrdconta, 123.52 as valor from dual
			union all
			select 1 as cdcooper, 91014565 as nrdconta, 122.63 as valor from dual
			union all
			select 1 as cdcooper, 90836146 as nrdconta, 153.03 as valor from dual
			union all
			select 1 as cdcooper, 90773829 as nrdconta, 102 as valor from dual
			union all
			select 1 as cdcooper, 90703162 as nrdconta, 121.49 as valor from dual
			union all
			select 1 as cdcooper, 90617797 as nrdconta, 255.4 as valor from dual
			union all
			select 1 as cdcooper, 90610130 as nrdconta, 0.08 as valor from dual
			union all
			select 1 as cdcooper, 90575881 as nrdconta, 0.26 as valor from dual
			union all
			select 1 as cdcooper, 90406893 as nrdconta, 132.93 as valor from dual
			union all
			select 1 as cdcooper, 90313232 as nrdconta, 0.29 as valor from dual
			union all
			select 1 as cdcooper, 90311884 as nrdconta, 0.65 as valor from dual
			union all
			select 1 as cdcooper, 90042360 as nrdconta, 2583.05 as valor from dual
			union all
			select 1 as cdcooper, 89892348 as nrdconta, 761.14 as valor from dual
			union all
			select 1 as cdcooper, 89681835 as nrdconta, 252.99 as valor from dual
			union all
			select 1 as cdcooper, 89567307 as nrdconta, 371.94 as valor from dual
			union all
			select 1 as cdcooper, 89078942 as nrdconta, 1324.83 as valor from dual
			union all
			select 1 as cdcooper, 88900029 as nrdconta, 304.25 as valor from dual
			union all
			select 1 as cdcooper, 88753735 as nrdconta, 0.59 as valor from dual
			union all
			select 1 as cdcooper, 88717127 as nrdconta, 370.59 as valor from dual
			union all
			select 1 as cdcooper, 88332543 as nrdconta, 99.54 as valor from dual
			union all
			select 1 as cdcooper, 88317277 as nrdconta, 1092.74 as valor from dual
			union all
			select 1 as cdcooper, 88113620 as nrdconta, 408.35 as valor from dual
			union all
			select 1 as cdcooper, 87973120 as nrdconta, 1686.45 as valor from dual
			union all
			select 1 as cdcooper, 87688085 as nrdconta, 265.37 as valor from dual
			union all
			select 1 as cdcooper, 86461842 as nrdconta, 5.68 as valor from dual
			union all
			select 1 as cdcooper, 86245899 as nrdconta, 2.70 as valor from dual
			union all
			select 1 as cdcooper, 84411473 as nrdconta, 0.07 as valor from dual
			union all 
			select 1 as cdcooper, 82082650 as nrdconta, 140.87 as valor from dual
			) contas
			
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper;

  CURSOR cr_crapsda is
    SELECT a.nrdconta, a.vlsddisp, a.dtmvtolt, contas.valor, contas.cdcooper
      from CECRED.crapsda a
          ,(select 1 as cdcooper, 98024647    as nrdconta,  512.51   as valor from dual
            union all
            select 1 as cdcooper, 98004689    as nrdconta,  1771.31   as valor from dual
			union all
			select 1 as cdcooper, 97776351    as nrdconta,  257.82   as valor from dual
            union all
			select 1 as cdcooper, 97141844    as nrdconta,  479.11   as valor from dual
			union all
			select 1 as cdcooper, 96930390   as nrdconta,  1.8   as valor from dual
			union all
			select 1 as cdcooper, 96444266   as nrdconta,  0.31   as valor from dual
			union all
			select 1 as cdcooper, 96295120   as nrdconta,  0.48   as valor from dual
			union all
			select 1 as cdcooper, 96280220   as nrdconta,  407.06   as valor from dual
			union all
			select 1 as cdcooper, 96006935   as nrdconta,  92.9    as valor from dual
			union all
			select 1 as cdcooper, 93410921 as nrdconta,   250.14    as valor from dual
			union all
			select 1 as cdcooper, 93091761 as nrdconta,  9.14 as valor from dual
			union all
			select 1 as cdcooper, 92545882 as nrdconta, 1.83 as valor from dual
			union all
			select 1 as cdcooper, 92373127 as nrdconta, 183.83 as valor from dual
			union all
			select 1 as cdcooper, 91530776 as nrdconta, 0.68 as valor from dual
			union all
			select 1 as cdcooper, 91395887 as nrdconta, 165.63 as valor from dual
			union all
			select 1 as cdcooper, 91256909 as nrdconta, 123.52 as valor from dual
			union all
			select 1 as cdcooper, 91014565 as nrdconta, 122.63 as valor from dual
			union all
			select 1 as cdcooper, 90836146 as nrdconta, 153.03 as valor from dual
			union all
			select 1 as cdcooper, 90773829 as nrdconta, 102 as valor from dual
			union all
			select 1 as cdcooper, 90703162 as nrdconta, 121.49 as valor from dual
			union all
			select 1 as cdcooper, 90617797 as nrdconta, 255.4 as valor from dual
			union all
			select 1 as cdcooper, 90610130 as nrdconta, 0.08 as valor from dual
			union all
			select 1 as cdcooper, 90575881 as nrdconta, 0.26 as valor from dual
			union all
			select 1 as cdcooper, 90406893 as nrdconta, 132.93 as valor from dual
			union all
			select 1 as cdcooper, 90313232 as nrdconta, 0.29 as valor from dual
			union all
			select 1 as cdcooper, 90311884 as nrdconta, 0.65 as valor from dual
			union all
			select 1 as cdcooper, 90042360 as nrdconta, 2583.05 as valor from dual
			union all
			select 1 as cdcooper, 89892348 as nrdconta, 761.14 as valor from dual
			union all
			select 1 as cdcooper, 89681835 as nrdconta, 252.99 as valor from dual
			union all
			select 1 as cdcooper, 89567307 as nrdconta, 371.94 as valor from dual
			union all
			select 1 as cdcooper, 89078942 as nrdconta, 1324.83 as valor from dual
			union all
			select 1 as cdcooper, 88900029 as nrdconta, 304.25 as valor from dual
			union all
			select 1 as cdcooper, 88753735 as nrdconta, 0.59 as valor from dual
			union all
			select 1 as cdcooper, 88717127 as nrdconta, 370.59 as valor from dual
			union all
			select 1 as cdcooper, 88332543 as nrdconta, 99.54 as valor from dual
			union all
			select 1 as cdcooper, 88317277 as nrdconta, 1092.74 as valor from dual
			union all
			select 1 as cdcooper, 88113620 as nrdconta, 408.35 as valor from dual
			union all
			select 1 as cdcooper, 87973120 as nrdconta, 1686.45 as valor from dual
			union all
			select 1 as cdcooper, 87688085 as nrdconta, 265.37 as valor from dual
			union all
			select 1 as cdcooper, 86461842 as nrdconta, 5.68 as valor from dual
			union all
			select 1 as cdcooper, 86245899 as nrdconta, 2.70 as valor from dual
			union all
			select 1 as cdcooper, 84411473 as nrdconta, 0.07 as valor from dual
			union all 
			select 1 as cdcooper, 82082650 as nrdconta, 140.87 as valor from dual) contas
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
