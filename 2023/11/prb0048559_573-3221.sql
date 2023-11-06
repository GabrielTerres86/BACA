Declare 
  
  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  gr_nrdconta cecred.crapass.nrdconta%type;
  gr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid ROWID;


  vc_dstransaSensbCRAPSLD             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSLD) por script - prb0048559_573-3221';
  vc_dstransaSensbCRAPSDA             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSDA) por script - prb0048559_573-3221';
  vc_dtinicioCRAPSDA                  CONSTANT DATE           := to_date('01/11/2023','dd/mm/yyyy');

  vr_erro_geralog EXCEPTION;
  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_crapsld is
    SELECT a.nrdconta
          ,a.vlsddisp
          ,contas.cdcooper     
          ,contas.valor
      from CECRED.crapsld a
          ,(
SELECT 1 AS cdcooper, 1924079 AS nrdconta, - 4500 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 2441110 AS nrdconta, - 300 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 3576728 AS nrdconta, - 800 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 3576728 AS nrdconta, - 800 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 6668925 AS nrdconta, - 1570 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 7598394 AS nrdconta, - 22397 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 8037582 AS nrdconta, - 1500 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 8290296 AS nrdconta, - 3278 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 8927472 AS nrdconta, - 3000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 8987785 AS nrdconta, - 10000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 9441549 AS nrdconta, - 7700 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 9441549 AS nrdconta, - 5000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 9708766 AS nrdconta, - 2750 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 9708766 AS nrdconta, - 2750 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 9877673 AS nrdconta, - 2779.37 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 11166231 AS nrdconta, - 4800 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 11928700 AS nrdconta, - 5000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 12052760 AS nrdconta, - 13580 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 12052760 AS nrdconta, - 15000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 13192043 AS nrdconta, - 10000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 13548336 AS nrdconta, - 9230 AS valor FROM dual UNION ALL
SELECT 2 AS cdcooper, 1082620 AS nrdconta, - 10120 AS valor FROM dual UNION ALL
SELECT 2 AS cdcooper, 1082620 AS nrdconta, - 10120 AS valor FROM dual UNION ALL
SELECT 2 AS cdcooper, 1082620 AS nrdconta, - 10120 AS valor FROM dual UNION ALL
SELECT 2 AS cdcooper, 15333000 AS nrdconta, - 5000 AS valor FROM dual UNION ALL
SELECT 2 AS cdcooper, 15335259 AS nrdconta, - 5000 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 114600 AS nrdconta, - 3000 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 135542 AS nrdconta, - 2434.52 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 354473 AS nrdconta, - 5000 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 354473 AS nrdconta, - 4050 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 358266 AS nrdconta, - 1000 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 368377 AS nrdconta, - 1250 AS valor FROM dual UNION ALL
SELECT 7 AS cdcooper, 417882 AS nrdconta, - 31250 AS valor FROM dual UNION ALL
SELECT 9 AS cdcooper, 211893 AS nrdconta, - 1415 AS valor FROM dual UNION ALL
SELECT 9 AS cdcooper, 330574 AS nrdconta, - 10000 AS valor FROM dual UNION ALL
SELECT 9 AS cdcooper, 330574 AS nrdconta, - 23333.33 AS valor FROM dual UNION ALL
SELECT 9 AS cdcooper, 361216 AS nrdconta, - 2500 AS valor FROM dual UNION ALL
SELECT 9 AS cdcooper, 443956 AS nrdconta, - 3670 AS valor FROM dual UNION ALL
SELECT 10 AS cdcooper, 25542 AS nrdconta, - 20000 AS valor FROM dual UNION ALL
SELECT 11 AS cdcooper, 233390 AS nrdconta, - 630.3 AS valor FROM dual UNION ALL
SELECT 11 AS cdcooper, 15684539 AS nrdconta, - 2500 AS valor FROM dual UNION ALL
SELECT 11 AS cdcooper, 16932617 AS nrdconta, - 7500 AS valor FROM dual UNION ALL
SELECT 12 AS cdcooper, 86940 AS nrdconta, - 9793 AS valor FROM dual UNION ALL
SELECT 13 AS cdcooper, 242888 AS nrdconta, - 2673 AS valor FROM dual UNION ALL
SELECT 13 AS cdcooper, 596698 AS nrdconta, - 1000 AS valor FROM dual UNION ALL
SELECT 14 AS cdcooper, 35521 AS nrdconta, - 30000 AS valor FROM dual UNION ALL
SELECT 16 AS cdcooper, 6641890 AS nrdconta, - 3250 AS valor FROM dual
			) contas
			
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper;

  CURSOR cr_crapsda is
    SELECT a.nrdconta, a.vlsddisp, a.dtmvtolt, contas.valor, contas.cdcooper
      from CECRED.crapsda a
          ,(
SELECT 1 AS cdcooper, 1924079 AS nrdconta, - 4500 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 2441110 AS nrdconta, - 300 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 3576728 AS nrdconta, - 800 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 3576728 AS nrdconta, - 800 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 6668925 AS nrdconta, - 1570 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 7598394 AS nrdconta, - 22397 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 8037582 AS nrdconta, - 1500 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 8290296 AS nrdconta, - 3278 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 8927472 AS nrdconta, - 3000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 8987785 AS nrdconta, - 10000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 9441549 AS nrdconta, - 7700 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 9441549 AS nrdconta, - 5000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 9708766 AS nrdconta, - 2750 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 9708766 AS nrdconta, - 2750 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 9877673 AS nrdconta, - 2779.37 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 11166231 AS nrdconta, - 4800 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 11928700 AS nrdconta, - 5000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 12052760 AS nrdconta, - 13580 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 12052760 AS nrdconta, - 15000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 13192043 AS nrdconta, - 10000 AS valor FROM dual UNION ALL
SELECT 1 AS cdcooper, 13548336 AS nrdconta, - 9230 AS valor FROM dual UNION ALL
SELECT 2 AS cdcooper, 1082620 AS nrdconta, - 10120 AS valor FROM dual UNION ALL
SELECT 2 AS cdcooper, 1082620 AS nrdconta, - 10120 AS valor FROM dual UNION ALL
SELECT 2 AS cdcooper, 1082620 AS nrdconta, - 10120 AS valor FROM dual UNION ALL
SELECT 2 AS cdcooper, 15333000 AS nrdconta, - 5000 AS valor FROM dual UNION ALL
SELECT 2 AS cdcooper, 15335259 AS nrdconta, - 5000 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 114600 AS nrdconta, - 3000 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 135542 AS nrdconta, - 2434.52 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 354473 AS nrdconta, - 5000 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 354473 AS nrdconta, - 4050 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 358266 AS nrdconta, - 1000 AS valor FROM dual UNION ALL
SELECT 5 AS cdcooper, 368377 AS nrdconta, - 1250 AS valor FROM dual UNION ALL
SELECT 7 AS cdcooper, 417882 AS nrdconta, - 31250 AS valor FROM dual UNION ALL
SELECT 9 AS cdcooper, 211893 AS nrdconta, - 1415 AS valor FROM dual UNION ALL
SELECT 9 AS cdcooper, 330574 AS nrdconta, - 10000 AS valor FROM dual UNION ALL
SELECT 9 AS cdcooper, 330574 AS nrdconta, - 23333.33 AS valor FROM dual UNION ALL
SELECT 9 AS cdcooper, 361216 AS nrdconta, - 2500 AS valor FROM dual UNION ALL
SELECT 9 AS cdcooper, 443956 AS nrdconta, - 3670 AS valor FROM dual UNION ALL
SELECT 10 AS cdcooper, 25542 AS nrdconta, - 20000 AS valor FROM dual UNION ALL
SELECT 11 AS cdcooper, 233390 AS nrdconta, - 630.3 AS valor FROM dual UNION ALL
SELECT 11 AS cdcooper, 15684539 AS nrdconta, - 2500 AS valor FROM dual UNION ALL
SELECT 11 AS cdcooper, 16932617 AS nrdconta, - 7500 AS valor FROM dual UNION ALL
SELECT 12 AS cdcooper, 86940 AS nrdconta, - 9793 AS valor FROM dual UNION ALL
SELECT 13 AS cdcooper, 242888 AS nrdconta, - 2673 AS valor FROM dual UNION ALL
SELECT 13 AS cdcooper, 596698 AS nrdconta, - 1000 AS valor FROM dual UNION ALL
SELECT 14 AS cdcooper, 35521 AS nrdconta, - 30000 AS valor FROM dual UNION ALL
SELECT 16 AS cdcooper, 6641890 AS nrdconta, - 3250 AS valor FROM dual
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
