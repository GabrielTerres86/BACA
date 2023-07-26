DECLARE

  CURSOR cr_crapcob IS
    SELECT cob.rowid dsdrowid
      FROM cecred.crapret ret 
         , cecred.crapcob cob 
         , cecred.crapcco cco
     WHERE cco.cdcooper > 0
       AND cco.cddbanco = 85
       AND ret.cdcooper = cco.cdcooper
       AND ret.nrcnvcob = cco.nrconven
       AND ret.dtocorre > '01/06/2023'
       AND ret.cdocorre = 9
       AND ret.cdmotivo = '14'
       AND cob.cdcooper = ret.cdcooper
       AND cob.nrdconta = ret.nrdconta
        AND cob.nrcnvcob = ret.nrcnvcob
       AND cob.nrdocmto = ret.nrdocmto
       AND cob.incobran = 3
       AND cob.ininscip = 1;
  
  vr_arq_path    VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/INC0283281'; 

  vr_nmarqrol    VARCHAR2(100) := 'INC0283281_script_rollback.sql';
  vr_dscritic    VARCHAR2(2000);

  vr_flarqrol    utl_file.file_type;
  vr_exc_erro    EXCEPTION;
  
BEGIN
 
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                                 ,pr_nmarquiv => vr_nmarqrol   
                                 ,pr_tipabert => 'W'           
                                 ,pr_utlfileh => vr_flarqrol   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na abertura do arquivo '||vr_nmarqrol||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                       ,pr_des_text => 'BEGIN'); 
  
  FOR reg IN cr_crapcob LOOP
    
    BEGIN 
      UPDATE cecred.crapcob t
         SET t.ininscip = 2
       WHERE ROWID = reg.dsdrowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar registro da CRAPCOB('||reg.dsdrowid||'): '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => '  UPDATE CECRED.crapcob '); 
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => '     SET ininscip = 1 '); 
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => '   WHERE rowid = '''||reg.dsdrowid||''';');
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => ' ');
    
  END LOOP;
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol, pr_des_text => '  COMMIT;');
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol, pr_des_text => 'END;');
  CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    IF UTL_FILE.is_open(vr_flarqrol) THEN
      CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    END IF;
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20001, vr_dscritic);
  WHEN OTHERS THEN
    IF UTL_FILE.is_open(vr_flarqrol) THEN
      CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    END IF;
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: '||SQLERRM);
END;
