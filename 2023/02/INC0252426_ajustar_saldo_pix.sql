DECLARE 

  CURSOR cr_contas IS
    SELECT t.cdcooper
         , t.nrdconta
         , t.cdagenci
      FROM cecred.crapass t
     WHERE t.progress_recid = 23836;
  rw_contas cr_contas%ROWTYPE;
  
  CURSOR cr_saldos(pr_cdcooper  NUMBER
                  ,pr_nrdconta  NUMBER
                  ,pr_dtmvtolt  DATE) IS
    SELECT ROWID dsdrowid
         , t.vlsddisp
         , t.dtmvtolt
      FROM cecred.crapsda t
     WHERE t.cdcooper  = pr_cdcooper
       AND t.nrdconta  = pr_nrdconta
       AND t.dtmvtolt >= pr_dtmvtolt;
  
  vr_nrdolote     NUMBER;
  vr_nrdocmto     NUMBER;
  vr_nrseqdig     NUMBER;
  vr_dtmvtolt     DATE;
  vr_incrineg     NUMBER;
  vr_tab_retorno  LANC0001.typ_reg_retorno;
  vr_cdcritic     NUMBER;
  vr_dscritic     VARCHAR2(2000);
  
BEGIN

  OPEN  cr_contas;
  FETCH cr_contas INTO rw_contas;
  CLOSE cr_contas;
                                          
  vr_nrdolote := 700001;
  vr_nrdocmto := 205354747;    
  vr_dtmvtolt := to_date('12/01/2023','DD/MM/YYYY');
       
  vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_contas.cdcooper ||';'||
                                                   to_char(vr_dtmvtolt,'DD/MM/RRRR')||';'||
                                                   '90;85;'||vr_nrdolote); 
  
  LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => vr_dtmvtolt
                                    ,pr_cdagenci    => 90
                                    ,pr_cdbccxlt    => 85
                                    ,pr_nrdolote    => vr_nrdolote
                                    ,pr_nrdconta    => rw_contas.nrdconta
                                    ,pr_nrdocmto    => vr_nrdocmto
                                    ,pr_cdhistor    => 3320
                                    ,pr_nrseqdig    => vr_nrseqdig
                                    ,pr_vllanmto    => 550
                                    ,pr_nrdctabb    => rw_contas.nrdconta
                                    ,pr_cdpesqbb    => 'PAG. ID E8263945120230222122836696098207'
                                    ,pr_dtrefere    => vr_dtmvtolt
                                    ,pr_hrtransa    => gene0002.fn_busca_time
                                    ,pr_cdoperad    => '996'
                                    ,pr_cdcooper    => rw_contas.cdcooper
                                    ,pr_cdorigem    => 21
                                    ,pr_incrineg    => vr_incrineg
                                    ,pr_tab_retorno => vr_tab_retorno
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
  
  IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    IF TRIM(vr_dscritic) IS NULL THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    
    RAISE_APPLICATION_ERROR(-20001,'Erro ao gerar lançamento: '||vr_dscritic);
  END IF;
  
  FOR saldo IN cr_saldos(rw_contas.cdcooper,rw_contas.nrdconta,vr_dtmvtolt) LOOP
    
    UPDATE cecred.crapsda  t
       SET t.vlsddisp = t.vlsddisp - 550
     WHERE ROWID = saldo.dsdrowid;
  
  END LOOP;
  
  UPDATE cecred.crapsld t 
     SET t.vlsddisp = t.vlsddisp - 550
   WHERE t.cdcooper = rw_contas.cdcooper
     AND t.nrdconta = rw_contas.nrdconta;
  
  COMMIT;
    
EXCEPTION 
  WHEN OTHERS then
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'ERRON NO SCRIPT: '||SQLERRM);         
END;
