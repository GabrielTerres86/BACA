Declare 
  
  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  gr_nrdconta cecred.crapass.nrdconta%type;
  gr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid ROWID;


  vc_dstransaSensbCRAPSLD             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSLD) por script - INC0285180';
  vc_dstransaSensbCRAPSDA             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSDA) por script - INC0285180';
  vc_dtinicioCRAPSDA                  CONSTANT DATE           := to_date('01/08/2023','dd/mm/yyyy');

  vr_erro_geralog EXCEPTION;
  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_crapsld is
    SELECT a.nrdconta
          ,a.vlsddisp
          ,contas.cdcooper
          ,contas.valor
      from CECRED.crapsld a
          ,(select 1 as cdcooper, 850004  as nrdconta, -118973.65  as valor from dual
            union all
            select 1 as cdcooper, 11613491  as nrdconta, -10250.02 as valor from dual
            union all
            select 1 as cdcooper, 11460555  as nrdconta, -6332.16 as valor from dual
            union all
            select 1 as cdcooper, 8579997  as nrdconta, -100410.37 as valor from dual
            union all
            select 1 as cdcooper, 10430210  as nrdconta, -4849.03 as valor from dual
            ) contas
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper;

  CURSOR cr_crapsda is
    SELECT a.nrdconta, a.vlsddisp, a.dtmvtolt, contas.valor, contas.cdcooper
      from CECRED.crapsda a
          ,(select 1 as cdcooper, 850004  as nrdconta, -118973.65  as valor from dual
            union all
            select 1 as cdcooper, 11613491  as nrdconta, -10250.02 as valor from dual
            union all
            select 1 as cdcooper, 11460555  as nrdconta, -6332.16 as valor from dual
            union all
            select 1 as cdcooper, 8579997  as nrdconta, -100410.37 as valor from dual
            union all
            select 1 as cdcooper, 10430210  as nrdconta, -4849.03 as valor from dual
            ) contas
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper
       AND a.dtmvtolt BETWEEN vc_dtinicioCRAPSDA AND TRUNC(SYSDATE)
     ORDER BY a.nrdconta, a.dtmvtolt asc;

     CURSOR cr_contas is
    SELECT contas.cdcooper, contas.nrdconta
        from (select 1 as cdcooper, 850004  as nrdconta from dual
              union all
              select 1 as cdcooper, 11613491  as nrdconta from dual
              union all
              select 1 as cdcooper, 11460555  as nrdconta from dual
              union all
              select 1 as cdcooper, 8579997  as nrdconta from dual
              union all
              select 1 as cdcooper, 10430210  as nrdconta from dual
              ) contas;

    Cursor cr_lcm (p_nrdconta number)is
       select lcm.cdcooper, 
              lcm.dtmvtolt, 
              lcm.cdagenci,
              lcm.cdbccxlt, 
              lcm.nrdolote, 
        lcm.nrdconta,
             (select nvl(max(nrseqdig)+1,1) 
                from craplcm b 
               where b.cdcooper = lcm.cdcooper
                 and b.dtmvtolt = to_Date('01/08/2023','dd/mm/yyyy')
                 and b.cdagenci = lcm.cdagenci
                 and b.cdbccxlt = lcm.cdbccxlt
                 and b.nrdolote = lcm.nrdolote) NRSEQDIG
         from cecred.craplcm lcm
        where lcm.cdcooper = 1 
          and lcm.nrdconta = p_nrdconta
          and lcm.dtmvtolt = to_Date('31/07/2023','dd/mm/yyyy')
          and lcm.cdhistor = 2972;
    rg_lcm cr_lcm%rowtype;



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
  
  
  
  for rg_contas in cr_contas LOOP
       
     open cr_lcm(rg_contas.nrdconta);
     fetch cr_lcm into rg_lcm;
     if rg_lcm.nrdconta   = 11613491 THEN
        insert into cecred.craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR, PROGRESS_RECID, NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
          values (to_date('01/08/2023', 'dd/mm/yyyy'), rg_lcm.cdagenci, rg_lcm.cdbccxlt, rg_lcm.nrdolote, 11613491, 1, 2972, rg_lcm.nrseqdig, 10250.02, 11613491, '         0', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, null, 30304, 'F0015969', ' ', 1, '11613491', ' ', 0, 0, 0, 0, null, 0, 0, 0, 0, '01/08/23 08:25:04,000000');

     
     elsif rg_lcm.nrdconta = 8579997 THEN
           insert into cecred.craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR, PROGRESS_RECID, NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
             values (to_date('01-08-2023', 'dd-mm-yyyy'), rg_lcm.cdagenci, rg_lcm.cdbccxlt, rg_lcm.nrdolote, 8579997, 1, 2972, rg_lcm.nrseqdig, 100410.37, 8579997, '         0', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, null, 30472, 'F0015969', ' ', 1, '08579997', ' ', 0, 0, 0, 0, null, 0, 0, 0, 0, '01/08/23 08:27:52,000000');
 
     
     elsif rg_lcm.nrdconta = 11460555 THEN
           insert into cecred.craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR, PROGRESS_RECID, NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
             values (to_date('01-08-2023', 'dd-mm-yyyy'), rg_lcm.cdagenci, rg_lcm.cdbccxlt, rg_lcm.nrdolote, 11460555, 1, 2972, rg_lcm.nrseqdig, 6332.16, 11460555, '         0', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, null, 30356, 'F0015969', ' ', 1, '11460555', ' ', 0, 0, 0, 0, null, 0, 0, 0, 0, '01/08/23 08:25:56,000000');

        
     elsif rg_lcm.nrdconta = 10430210 THEN
           insert into cecred.craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR, PROGRESS_RECID, NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
             values (to_date('01-08-2023', 'dd-mm-yyyy'), rg_lcm.cdagenci, rg_lcm.cdbccxlt, rg_lcm.nrdolote, 10430210, 1, 2972, rg_lcm.nrseqdig, 4849.03, 10430210, '         0', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, null, 30525, 'F0015969', ' ', 1, '10430210', ' ', 0, 0, 0, 0, null, 0, 0, 0, 0, '01/08/23 08:28:45,000000');

     elsif rg_lcm.nrdconta = 850004 THEN
           insert into cecred.craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR, PROGRESS_RECID, NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
             values (to_date('01-08-2023', 'dd-mm-yyyy'), rg_lcm.cdagenci, rg_lcm.cdbccxlt, rg_lcm.nrdolote, 850004, 2, 2972, rg_lcm.nrseqdig, 118973.65, 850004, '         0', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, null, 30583, 'F0015969', ' ', 1, '00850004', ' ', 0, 0, 0, 0, null, 0, 0, 0, 0, '01/08/23 08:29:43,000000');

     end if;
     
     
     close cr_lcm;
   
   
   
   
   end loop;
  
   delete from cecred.craplcm lcm
   where lcm.nrdconta in (850004,11613491,11460555,8579997,10430210)
     and lcm.cdcooper = 1
     and lcm.dtmvtolt = to_Date('31/07/2023','dd/mm/yyyy')
     and lcm.cdhistor = 2972;
   

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