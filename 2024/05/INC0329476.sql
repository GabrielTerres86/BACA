Declare 
  
  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  gr_nrdconta cecred.crapass.nrdconta%type;
  gr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid ROWID;


  vc_dstransaSensbCRAPSLD             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSLD) por script - INC0329476';

  vr_erro_geralog EXCEPTION;
  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_crapsld is
    SELECT a.nrdconta
          ,a.vlsddisp
          ,contas.cdcooper     
          ,contas.valor
      from CECRED.crapsld a
          ,(select 1 as cdcooper,   6173	 as nrdconta,   1.94     as valor from dual
            union
            select 1 as cdcooper,	16896	 as nrdconta,   2.93     as valor from dual
            union
            select 1 as cdcooper,	941336	 as nrdconta,   0.22     as valor from dual
            union
            select 1 as cdcooper,	1838032	 as nrdconta,   0.12     as valor from dual
            union
            select 1 as cdcooper,	1985000	 as nrdconta,   0.80     as valor from dual
            union
            select 1 as cdcooper,	2363089	 as nrdconta,   1.31     as valor from dual
            union
            select 1 as cdcooper,	2385341	 as nrdconta,   0.85     as valor from dual
            union
            select 1 as cdcooper,	2639181	 as nrdconta,   0.49     as valor from dual
            union
            select 1 as cdcooper,	2651084	 as nrdconta,   0.05     as valor from dual
            union
            select 1 as cdcooper,	2666901	 as nrdconta,   1.81     as valor from dual
            union
            select 1 as cdcooper,	2790319	 as nrdconta,   23.49    as valor from dual
            union
            select 1 as cdcooper,	2816091	 as nrdconta,   0.41     as valor from dual
            union
            select 1 as cdcooper,	3536513	 as nrdconta,   0.15     as valor from dual
            union
            select 1 as cdcooper,	3586081	 as nrdconta,   3.66     as valor from dual
            union
            select 1 as cdcooper,	3785050	 as nrdconta,   0.07     as valor from dual
            union
            select 1 as cdcooper,	3949427	 as nrdconta,   0.38     as valor from dual
            union
            select 1 as cdcooper,	6090168	 as nrdconta,   0.11     as valor from dual
            union
            select 1 as cdcooper,	6206735	 as nrdconta,   8.38     as valor from dual
            union
            select 1 as cdcooper,	6252613	 as nrdconta,   0.16     as valor from dual
            union
            select 1 as cdcooper,	6252818	 as nrdconta,   0.28     as valor from dual
            union
            select 1 as cdcooper,	6285406	 as nrdconta,   1.96     as valor from dual
            union
            select 1 as cdcooper,	6385109 as nrdconta,	1.55     as valor from dual
            union
            select 1 as cdcooper,	6741061 as nrdconta,	8.71     as valor from dual
            union
            select 1 as cdcooper,	6774482 as nrdconta,	5.73     as valor from dual
            union
            select 1 as cdcooper,	6852602 as nrdconta,	0.30     as valor from dual
            union
            select 1 as cdcooper,	7095945 as nrdconta,	4.82     as valor from dual
            union
            select 1 as cdcooper,	7166940 as nrdconta,	0.99     as valor from dual
            union
            select 1 as cdcooper,	7168004 as nrdconta,	17.99    as valor from dual
            union
            select 1 as cdcooper,	7272677 as nrdconta,	1.11     as valor from dual
            union
            select 1 as cdcooper,	7417152 as nrdconta,	3.59     as valor from dual
            union
            select 1 as cdcooper,	7459173 as nrdconta,	0.45     as valor from dual
            union
            select 1 as cdcooper,	7866208 as nrdconta,	14.37    as valor from dual
            union
            select 1 as cdcooper,	7902638 as nrdconta,	1.02     as valor from dual
            union
            select 1 as cdcooper,	7985010 as nrdconta,	750.00   as valor from dual
            union
            select 1 as cdcooper,	8146713 as nrdconta,	1.69     as valor from dual
            union
            select 1 as cdcooper,	8150966 as nrdconta,	1.02     as valor from dual
            union
            select 1 as cdcooper,	8370710 as nrdconta,	0.47     as valor from dual
            union
            select 1 as cdcooper,	8533539 as nrdconta,	0.16     as valor from dual
            union
            select 1 as cdcooper,	8609250 as nrdconta,	0.95     as valor from dual
            union
            select 1 as cdcooper,	8671800 as nrdconta,	0.32     as valor from dual
            union
            select 1 as cdcooper,	8732094 as nrdconta,	7.05     as valor from dual
            union
            select 1 as cdcooper,	8877041 as nrdconta,	2.30     as valor from dual
            union
            select 1 as cdcooper,	8904847 as nrdconta,	0.46     as valor from dual
            union
            select 1 as cdcooper,	9027777 as nrdconta,	0.15     as valor from dual
            union
            select 1 as cdcooper,	9086943 as nrdconta,	3.11     as valor from dual
            union
            select 1 as cdcooper,	9093869 as nrdconta,	0.47     as valor from dual
            union
            select 1 as cdcooper,	9153594 as nrdconta,	0.59     as valor from dual
            union
            select 1 as cdcooper,	9237348 as nrdconta,	4.80     as valor from dual
            union
            select 1 as cdcooper,	9263276 as nrdconta,	1.61     as valor from dual
            union
            select 1 as cdcooper,	9328246 as nrdconta,	0.24     as valor from dual
            union
            select 1 as cdcooper,	9447750 as nrdconta,	0.68     as valor from dual
            union
            select 1 as cdcooper,	9608397 as nrdconta,	1.13     as valor from dual
            union
            select 1 as cdcooper,	9655921 as nrdconta,	6.89     as valor from dual
            union
            select 1 as cdcooper,	9713689 as nrdconta,	0.38     as valor from dual
            union
            select 1 as cdcooper,	9725555 as nrdconta,	0.99     as valor from dual
            union
            select 1 as cdcooper,	9863648 as nrdconta,	0.88     as valor from dual
            union
            select 1 as cdcooper,	9883495 as nrdconta,	0.69     as valor from dual
            union
            select 1 as cdcooper,	10014764 as nrdconta,	1.51     as valor from dual
            union
            select 1 as cdcooper,	10149937 as nrdconta,	0.79     as valor from dual
            union
            select 1 as cdcooper,	10325093 as nrdconta,	1.36     as valor from dual
            union
            select 1 as cdcooper,	10482407 as nrdconta,	0.35     as valor from dual
            union
            select 1 as cdcooper,	10541101 as nrdconta,	0.04     as valor from dual
            union
            select 1 as cdcooper,	10803572 as nrdconta,	0.92     as valor from dual
            union
            select 1 as cdcooper,	10906487 as nrdconta,	1.00     as valor from dual
            union
            select 1 as cdcooper,	10974008 as nrdconta,	8.16     as valor from dual
            union
            select 1 as cdcooper,	11203013 as nrdconta,	0.18     as valor from dual
            union
            select 1 as cdcooper,	11211156 as nrdconta,	2.87     as valor from dual
            union
            select 1 as cdcooper,	11249250 as nrdconta,	0.43     as valor from dual
            union
            select 1 as cdcooper,	11651032 as nrdconta,	25.98    as valor from dual
            union
            select 1 as cdcooper,	11881143 as nrdconta,	0.23     as valor from dual
            union
            select 1 as cdcooper,	12417394 as nrdconta,	1.70     as valor from dual
            union
            select 1 as cdcooper,	12535753 as nrdconta,	0.20     as valor from dual
            union
            select 1 as cdcooper,	12716413 as nrdconta,	1.60     as valor from dual
            union
            select 1 as cdcooper,	12777838 as nrdconta,	2.93     as valor from dual
            union
            select 1 as cdcooper,	12783390 as nrdconta,	0.66     as valor from dual
            union
            select 1 as cdcooper,	13354469 as nrdconta,	6.00     as valor from dual
            union
            select 1 as cdcooper,	13527436 as nrdconta,	0.09     as valor from dual
            union
            select 1 as cdcooper,	13572989 as nrdconta,	17.86    as valor from dual
            union
            select 1 as cdcooper,	13663291 as nrdconta,	0.87     as valor from dual
            union
            select 1 as cdcooper,	13972600 as nrdconta,	0.49     as valor from dual
            union
            select 1 as cdcooper,	14367394 as nrdconta,	3.39     as valor from dual
            union
            select 1 as cdcooper,	14479729 as nrdconta,	3.15     as valor from dual
            union
            select 1 as cdcooper,	15117391 as nrdconta,	0.54     as valor from dual
            union
            select 1 as cdcooper,	15199002 as nrdconta,	0.45     as valor from dual
            union
            select 1 as cdcooper,	15511235 as nrdconta,	0.72     as valor from dual
            union
            select 1 as cdcooper,	15580202 as nrdconta,	19.49    as valor from dual
            union
            select 1 as cdcooper,	16040163 as nrdconta,	1.76     as valor from dual
            union
            select 1 as cdcooper,	16158121 as nrdconta,	3.83     as valor from dual
            union
            select 1 as cdcooper,	16633296 as nrdconta,	0.97     as valor from dual
            union
            select 1 as cdcooper,	16793048 as nrdconta,	0.39     as valor from dual
            union
            select 1 as cdcooper,	16817010 as nrdconta,	0.10     as valor from dual
            union
            select 1 as cdcooper,	16999177 as nrdconta,	1.17     as valor from dual
            union
            select 1 as cdcooper,	17205255 as nrdconta,	4.40     as valor from dual
            union
            select 1 as cdcooper,	80361773 as nrdconta,	0.70     as valor from dual
            union
            select 1 as cdcooper,	2041448  as nrdconta,	2.28     as valor from dual
            union
            select 1 as cdcooper,	2467364  as nrdconta,	2.92     as valor from dual
            union
            select 1 as cdcooper,	2653311  as nrdconta,	1.44     as valor from dual
            union
            select 1 as cdcooper,	2915375  as nrdconta,	6.14     as valor from dual
            union
            select 1 as cdcooper,	3508064  as nrdconta,	0.07     as valor from dual
            union
            select 1 as cdcooper,	3591646  as nrdconta,	0.75     as valor from dual
            union
            select 1 as cdcooper,	3629252  as nrdconta,	0.46     as valor from dual
            union
            select 1 as cdcooper,	3704815  as nrdconta,	2.06     as valor from dual
            union
            select 1 as cdcooper,	3724484  as nrdconta,	0.38     as valor from dual
            union
            select 1 as cdcooper,	3777944  as nrdconta,	0.38     as valor from dual
            union
            select 1 as cdcooper,	3902420  as nrdconta,	0.35     as valor from dual
            union
            select 1 as cdcooper,	6466893  as nrdconta,	0.26     as valor from dual
            union
            select 1 as cdcooper,	6535984  as nrdconta,	1.08     as valor from dual
            union
            select 1 as cdcooper,	6646700  as nrdconta,	0.48     as valor from dual
            union
            select 1 as cdcooper,	6912966  as nrdconta,	1.61     as valor from dual
            union
            select 1 as cdcooper,	6954774  as nrdconta,	0.86     as valor from dual
            union
            select 1 as cdcooper,	6990851  as nrdconta,	1.95     as valor from dual
            union
            select 1 as cdcooper,	7118287  as nrdconta,	1.35     as valor from dual
            union
            select 1 as cdcooper,	7237715  as nrdconta,	1.89     as valor from dual
            union
            select 1 as cdcooper,	7368585  as nrdconta,	5.66     as valor from dual
            union
            select 1 as cdcooper,	7534701  as nrdconta,	0.16     as valor from dual
            union
            select 1 as cdcooper,	7562977  as nrdconta,	0.31     as valor from dual
            union
            select 1 as cdcooper,	7673302  as nrdconta,	2.02     as valor from dual
            union
            select 1 as cdcooper,	7774028  as nrdconta,	0.27     as valor from dual
            union
            select 1 as cdcooper,	7865600  as nrdconta,	0.78     as valor from dual
            union
            select 1 as cdcooper,	7947380  as nrdconta,	7.90     as valor from dual
            union
            select 1 as cdcooper,	8035300  as nrdconta,	0.11     as valor from dual
            union
            select 1 as cdcooper,	8041270  as nrdconta,	3.81     as valor from dual
            union
            select 1 as cdcooper,	8401659  as nrdconta,	0.68     as valor from dual
            union
            select 1 as cdcooper,	8469164  as nrdconta,	0.09     as valor from dual
            union
            select 1 as cdcooper,	8471550  as nrdconta,	0.37     as valor from dual
            union
            select 1 as cdcooper,	8767912  as nrdconta,	0.27     as valor from dual
            union
            select 1 as cdcooper,	8777330  as nrdconta,	0.37     as valor from dual
            union
            select 1 as cdcooper,	8805342  as nrdconta,	0.33     as valor from dual
            union
            select 1 as cdcooper,	9034366  as nrdconta,	0.42     as valor from dual
            union
            select 1 as cdcooper,	9121412  as nrdconta,	0.14     as valor from dual
            union
            select 1 as cdcooper,	9327304  as nrdconta,	19.38    as valor from dual
            union
            select 1 as cdcooper,	9389806  as nrdconta,	0.52     as valor from dual
            union
            select 1 as cdcooper,	9416420  as nrdconta,	1.24     as valor from dual
            union
            select 1 as cdcooper,	9520970  as nrdconta,	0.10     as valor from dual
            union
            select 1 as cdcooper,	9649204  as nrdconta,	6.31     as valor from dual
            union
            select 1 as cdcooper,	9653252  as nrdconta,	0.72     as valor from dual
            union
            select 1 as cdcooper,	9740651  as nrdconta,	0.19     as valor from dual
            union
            select 1 as cdcooper,	9751440  as nrdconta,	8.64     as valor from dual
            union
            select 1 as cdcooper,	9981675  as nrdconta,	0.10     as valor from dual
            union
            select 1 as cdcooper,	10030360 as nrdconta,	3.14     as valor from dual
            union
            select 1 as cdcooper,	10133747 as nrdconta,	2.86     as valor from dual
            union
            select 1 as cdcooper,	10237755 as nrdconta,	1.52     as valor from dual
            union
            select 1 as cdcooper,	10268537 as nrdconta,	3.10     as valor from dual
            union
            select 1 as cdcooper,	10276696 as nrdconta,	2.54     as valor from dual
            union
            select 1 as cdcooper,	10417818 as nrdconta,	1.18     as valor from dual
            union
            select 1 as cdcooper,	10736158 as nrdconta,	0.38     as valor from dual
            union
            select 1 as cdcooper,	10736310 as nrdconta,	1.43     as valor from dual
            union
            select 1 as cdcooper,	10978712 as nrdconta,	0.58     as valor from dual
            union
            select 1 as cdcooper,	11048204 as nrdconta,	1.54     as valor from dual
            union
            select 1 as cdcooper,	11163577 as nrdconta,	0.58     as valor from dual
            union
            select 1 as cdcooper,	11246200 as nrdconta,	0.23     as valor from dual
            union
            select 1 as cdcooper,	11254017 as nrdconta,	1.11     as valor from dual
            union
            select 1 as cdcooper,	11406968 as nrdconta,	1.38     as valor from dual
            union
            select 1 as cdcooper,	11437170 as nrdconta,	2.33     as valor from dual
            union
            select 1 as cdcooper,	11593857 as nrdconta,	1.30     as valor from dual
            union
            select 1 as cdcooper,	11617381 as nrdconta,	1.42     as valor from dual
            union
            select 1 as cdcooper,	11654961 as nrdconta,	0.31     as valor from dual
            union
            select 1 as cdcooper,	11687932 as nrdconta,	1.10     as valor from dual
            union
            select 1 as cdcooper,	11927224 as nrdconta,	0.35     as valor from dual
            union
            select 1 as cdcooper,	11973935 as nrdconta,	990.00   as valor from dual
            union
            select 1 as cdcooper,	12003174 as nrdconta,	1.38     as valor from dual
            union
            select 1 as cdcooper,	12052604 as nrdconta,	950.00   as valor from dual
            union
            select 1 as cdcooper,	12069361 as nrdconta,	0.81     as valor from dual
            union
            select 1 as cdcooper,	12078654 as nrdconta,	2.32     as valor from dual
            union
            select 1 as cdcooper,	12327891 as nrdconta,	0.26     as valor from dual
            union
            select 1 as cdcooper,	12442445 as nrdconta,	0.44     as valor from dual
            union
            select 1 as cdcooper,	12675180 as nrdconta,	1170.00  as valor from dual
            union
            select 1 as cdcooper,	13091000 as nrdconta,	0.98     as valor from dual
            union
            select 1 as cdcooper,	13355635 as nrdconta,	0.49     as valor from dual
            union
            select 1 as cdcooper,	13377256 as nrdconta,	0.50     as valor from dual
            union
            select 1 as cdcooper,	13477595 as nrdconta,	0.32     as valor from dual
            union
            select 1 as cdcooper,	13597272 as nrdconta,	0.91     as valor from dual
            union
            select 1 as cdcooper,	14138816 as nrdconta,	0.72     as valor from dual
            union
            select 1 as cdcooper,	14170914 as nrdconta,	0.48     as valor from dual
            union
            select 1 as cdcooper,	14299453 as nrdconta,	4.00     as valor from dual
            union
            select 1 as cdcooper,	14371715 as nrdconta,	0.53     as valor from dual
            union
            select 1 as cdcooper,	14780160 as nrdconta,	2.10     as valor from dual
            union
            select 1 as cdcooper,	15193322 as nrdconta,	1.43     as valor from dual
            union
            select 1 as cdcooper,	15593274 as nrdconta,	0.47     as valor from dual
            union
            select 1 as cdcooper,	15674878 as nrdconta,	0.61     as valor from dual
            union
            select 1 as cdcooper,	15710726 as nrdconta,	0.69     as valor from dual
            union
            select 1 as cdcooper,	15798429 as nrdconta,	0.22     as valor from dual
            union
            select 1 as cdcooper,	16113233 as nrdconta,	0.69     as valor from dual
            union
            select 1 as cdcooper,	17129249 as nrdconta,	1.06     as valor from dual
            union
            select 1 as cdcooper,	17991340 as nrdconta,	0.69     as valor from dual ) contas		
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
