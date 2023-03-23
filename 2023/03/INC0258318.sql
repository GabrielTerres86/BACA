DECLARE 

  CURSOR cr_contas IS
    SELECT t.cdcooper
         , t.nrdconta
         , t.cdagenci
         , contas.dtmvtolt
         , contas.nrdocmto
         , contas.cdhistor
         , contas.vllanmto
         , contas.cdpesqbb
         , contas.nrdolote
      FROM cecred.crapass t
          ,(select 763848 as progress_recid, to_date('13/03/2023','dd/mm/yyyy') as dtmvtolt, 213661158 as nrdocmto, 3371 as cdhistor, 2600 as vllanmto, 'PAG. ID 9B0DC1F6C4F1CC05E0530A293573BAD6' as cdpesqbb, '700007' as nrdolote from dual
            union all
            select 1811879 as progress_recid, to_date('13/03/2023','dd/mm/yyyy') as dtmvtolt, 213653037 as nrdocmto, 3320 as cdhistor, 4400 as vllanmto, 'PAG. ID E10311218202303131018044015336406' as cdpesqbb, '700001' as nrdolote from dual
           ) contas
     WHERE t.progress_recid = contas.progress_recid;
  
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

  FOR rw_contas IN cr_contas LOOP
         
    vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_contas.cdcooper ||';'||
                                                     to_char(rw_contas.dtmvtolt,'DD/MM/RRRR')||';'||
                                                     '90;85;'||rw_contas.nrdolote); 
    
    LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => rw_contas.dtmvtolt
                                      ,pr_cdagenci    => 90
                                      ,pr_cdbccxlt    => 85
                                      ,pr_nrdolote    => rw_contas.nrdolote
                                      ,pr_nrdconta    => rw_contas.nrdconta
                                      ,pr_nrdocmto    => rw_contas.nrdocmto
                                      ,pr_cdhistor    => rw_contas.cdhistor
                                      ,pr_nrseqdig    => vr_nrseqdig
                                      ,pr_vllanmto    => rw_contas.vllanmto
                                      ,pr_nrdctabb    => rw_contas.nrdconta
                                      ,pr_cdpesqbb    => rw_contas.cdpesqbb
                                      ,pr_dtrefere    => rw_contas.dtmvtolt
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
    
    FOR saldo IN cr_saldos(rw_contas.cdcooper,rw_contas.nrdconta,rw_contas.dtmvtolt) LOOP
      
      UPDATE cecred.crapsda  t
         SET t.vlsddisp = t.vlsddisp - rw_contas.vllanmto
       WHERE ROWID = saldo.dsdrowid;
    
    END LOOP;
    
    UPDATE cecred.crapsld t 
       SET t.vlsddisp = t.vlsddisp - rw_contas.vllanmto
     WHERE t.cdcooper = rw_contas.cdcooper
       AND t.nrdconta = rw_contas.nrdconta;
       
  END LOOP;
  
  COMMIT;
    
EXCEPTION 
  WHEN OTHERS then
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'ERRO NO SCRIPT: '||SQLERRM);         
END;
