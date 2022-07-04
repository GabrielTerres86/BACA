DECLARE
  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  vr_nrdconta cecred.crapass.nrdconta%type;
  vr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;

  
  vc_dstransaAtuDtCRAPLCM             CONSTANT VARCHAR2(4000) := 'Atualizacao da Data de Lancamento (CRAPLCM) por script - INC0143823';
  vc_dtmvtoltCRAPLCM                  CONSTANT DATE           := to_date('02/05/2022','dd/mm/yyyy');

  vr_erro_geralog EXCEPTION;
  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_craplcm is
    SELECT l.nrdconta, l.cdcooper, l.dtmvtolt, l.progress_recid, l.cdagenci, l.cdbccxlt, l.nrdolote, l.nrseqdig
      from CECRED.craplcm l
     WHERE 1=1
       AND l.progress_recid IN (1446790866,
                                1446785056,
                                1446789335,
                                1446774654,
                                1446813016,
                                1446790125,
                                1446777221,
                                1446813023,
                                1446777223,
                                1446618116,
                                1446820310,
                                1446614990,
                                1446786923,
                                1446628751,
                                1446617420,
                                1446624427,
                                1446782271,
                                1446660652,
                                1446774656,
                                1446789691,
                                1446795742,
                                1446809271,
                                1446790126,
                                1446756102,
                                1446615098,
                                1446777225,
                                1446787712,
                                1446617748,
                                1446614874,
                                1446796729,
                                1446795741,
                                1446775917,
                                1446781393,
                                1446783074,
                                1446782273,
                                1446617826,
                                1446809276,
                                1446822990,
                                1446783073,
                                1446755437,
                                1446811917,
                                1446816899,
                                1446794819,
                                1446783436,
                                1446816901,
                                1446777228,
                                1446773513,
                                1446617697,
                                1446813584,
                                1446614030,
                                1446758538,
                                1446614173,
                                1446782275,
                                1446789692,
                                1446617421,
                                1446660043,
                                1446787715,
                                1446817515,
                                1446775918,
                                1446614204,
                                1446614991,
                                1446814047,
                                1446785057,
                                1446809297,
                                1446775919,
                                1446814048,
                                1446781395,
                                1446760952,
                                1446755909,
                                1446614144,
                                1446755458,
                                1446659062,
                                1446777234,
                                1446660182,
                                1446775920,
                                1446615851,
                                1446769715,
                                1446813607,
                                1446779723,
                                1446773515,
                                1446779724,
                                1446660570,
                                1446775921,
                                1446628865,
                                1446614924,
                                1446614875,
                                1446811934,
                                1446614031,
                                1446617727,
                                1446822992,
                                1446618117,
                                1446658971,
                                1446773295,
                                1446660183,
                                1446786568,
                                1446617422,
                                1446614234,
                                1446614145,
                                1446783075,
                                1446629144,
                                1446773296,
                                1446777236,
                                1446777239,
                                1446791354,
                                1446774657,
                                1446779728,
                                1446794821,
                                1446815754,
                                1446618252,
                                1446614391,
                                1446660727,
                                1446778035,
                                1446824638,
                                1446660469,
                                1446628752,
                                1446755973,
                                1446756647,
                                1446789339,
                                1446777242,
                                1446660470,
                                1446755827,
                                1446775928,
                                1446773297,
                                1446774659,
                                1446659959,
                                1446617830,
                                1446614841,
                                1446791355,
                                1446777677,
                                1446661319,
                                1446773300,
                                1446769716,
                                1446614925,
                                1446758539,
                                1446618118,
                                1446628866,
                                1446774660,
                                1446614392,
                                1446660571,
                                1446766371,
                                1446614069,
                                1446661213,
                                1446617749,
                                1446624701,
                                1446757481,
                                1446755287,
                                1446617698,
                                1446816905,
                                1446770476,
                                1446628964,
                                1446660728,
                                1446629145,
                                1446614236,
                                1446772570,
                                1446779730,
                                1446781396,
                                1446614174,
                                1446774663,
                                1446777245,
                                1446778036,
                                1446624702,
                                1446817517,
                                1446660831,
                                1446772933,
                                1446625163,
                                1446628965,
                                1446779737,
                                1446614926,
                                1446773516,
                                1446774667,
                                1446614340,
                                1446614842,
                                1446660832,
                                1446777679,
                                1446628966,
                                1446773303,
                                1446661029,
                                1446617750,
                                1446775932,
                                1446778038,
                                1446824641,
                                1446772571,
                                1446774669,
                                1446614205,
                                1446774670,
                                1446614109,
                                1446614237,
                                1446781399,
                                1446614175,
                                1446769719,
                                1446628868,
                                1446779739,
                                1446777250,
                                1446614876,
                                1446822999,
                                1446660068,
                                1446763147,
                                1446618119,
                                1446614653,
                                1446755421);
  
  PROCEDURE pr_atualiza_lcm(pr_cdcooper        IN NUMBER,
                            pr_nrdconta        IN NUMBER,
                            pr_dtmvtolt_old    IN DATE,
                            pr_dtmvtolt_new    IN DATE,
                            pr_cdagenci        IN NUMBER,
                            pr_cdbccxlt        IN NUMBER,
                            pr_nrdolote        IN NUMBER,
                            pr_nrseqdig        IN NUMBER,
                            pr_progressrecid   IN NUMBER,
                            pr_dscritic        OUT VARCHAR2) IS

  vr_nrdrowid               ROWID;
  vr_nrseqdig_new           cecred.craplcm.nrseqdig%type;
  
  BEGIN
  
    vr_nrdrowid := null;
    vr_nrseqdig_new := 0;

    select nvl(max(l.nrseqdig),0) + 1
      into vr_nrseqdig_new
      from cecred.craplcm l
     where l.cdcooper = pr_cdcooper
       and l.dtmvtolt = pr_dtmvtolt_new
       and l.cdagenci = pr_cdagenci
       and l.cdbccxlt = pr_cdbccxlt
       and l.nrdolote = pr_nrdolote;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                                pr_cdoperad => gr_cdoperad,
                                pr_dscritic => pr_dscritic,
                                pr_dsorigem => 'AIMARO',
                                pr_dstransa => vc_dstransaAtuDtCRAPLCM,
                                pr_dttransa => gr_dttransa,
                                pr_flgtrans => 1,
                                pr_hrtransa => gr_hrtransa,
                                pr_idseqttl => 0,
                                pr_nmdatela => NULL,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
                         
    IF pr_dscritic is NULL THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplcm.DTMVTOLT',
                                       pr_dsdadant => pr_dtmvtolt_old,
                                       pr_dsdadatu => pr_dtmvtolt_new);
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplcm.PROGRESS_RECID',
                                       pr_dsdadant => pr_progressrecid,
                                       pr_dsdadatu => pr_progressrecid);

      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplcm.NRSEQDIG',
                                       pr_dsdadant => pr_nrseqdig,
                                       pr_dsdadatu => vr_nrseqdig_new);
      
      
        UPDATE CECRED.craplcm l
           SET l.dtmvtolt = pr_dtmvtolt_new
              ,l.nrseqdig = vr_nrseqdig_new
         WHERE l.progress_recid = pr_progressrecid
           ;
    END IF;       
  END;

BEGIN
  gr_dttransa := trunc(sysdate);
  gr_hrtransa := GENE0002.fn_busca_time;

  FOR rg_craplcm IN cr_craplcm LOOP
    vr_cdcooper := rg_craplcm.cdcooper;        
    vr_nrdconta := rg_craplcm.nrdconta;
    
    pr_atualiza_lcm(vr_cdcooper,                      
                    vr_nrdconta,
                    rg_craplcm.dtmvtolt,
                    vc_dtmvtoltCRAPLCM,
                    rg_craplcm.cdagenci,
                    rg_craplcm.cdbccxlt,
                    rg_craplcm.nrdolote,
                    rg_craplcm.nrseqdig,
                    rg_craplcm.progress_recid,
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
                            vr_cdcooper || '/' || vr_nrdconta || ')- ' ||  vr_dscritic);
    
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1 , 64);    
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar saldo da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||  ' - ' || v_code || ' - ' || v_errm);
END;
