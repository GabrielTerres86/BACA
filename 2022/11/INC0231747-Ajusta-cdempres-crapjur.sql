declare

  vr_nmdireto           VARCHAR2(100);
  vr_nmarqbkp           VARCHAR2(50) := 'INC0231747_contas_ROLLBACK.sql';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  CURSOR cr_atualiza IS
    SELECT j.nrdconta
      , j.cdcooper
      , j.cdempres
    FROM CECRED.CRAPJUR J
    WHERE J.CDEMPRES = 0;
  
  rw_atualiza cr_atualiza%ROWTYPE;
  
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
begin
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0231747';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  
  OPEN cr_atualiza;
  LOOP
    FETCH cr_atualiza INTO rw_atualiza;
    EXIT WHEN cr_atualiza%NOTFOUND;
    
    UPDATE CECRED.crapjur
      SET cdempres = 88
    WHERE nrdconta = rw_atualiza.nrdconta
      AND cdcooper = rw_atualiza.cdcooper;
      
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '      UPDATE CECRED.crapjur SET  '
                                                    || '   cdempres = '   || rw_atualiza.cdempres
                                                    || ' WHERE nrdconta = ' || rw_atualiza.nrdconta
                                                    || '   AND cdcooper = ' || rw_atualiza.cdcooper || '; ' );
    
  END LOOP;
  
  CLOSE cr_atualiza;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
  COMMIT;

exception
  when others then
    
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO AO RODAR SCRIPT: ' || SQLERRM);
    
end;
