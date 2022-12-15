DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_exception          EXCEPTION;
  vr_dscritic           VARCHAR2(2000);
  vr_nrcpfcgc_novo      NUMBER;
  vr_nrcpfcgc_antigo    NUMBER;
  
  vr_nmarqbkp           VARCHAR2(50) := 'INC0236190_ROLLBACK.sql';
  vr_ind_arquiv         utl_file.file_type;
  
  vr_nmarq              VARCHAR2(50) := 'INC0236190_registro_alterar.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0236190';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarq
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_input_file
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  
  LOOP
    
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                ,pr_des_text => vr_setlinha);
    
    vr_nrcpfcgc_novo   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1,vr_setlinha,';') ) );
    vr_nrcpfcgc_antigo := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2,vr_setlinha,';') ) );
    
    BEGIN
  
      UPDATE CECRED.TBCADAST_PESSOA 
        SET nrcpfcgc = vr_nrcpfcgc_novo
      WHERE idpessoa = 8410861;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,  '    UPDATE CECRED.TBCADAST_PESSOA '
                                                       || '   SET nrcpfcgc = ' || vr_nrcpfcgc_antigo
                                                       || ' WHERE idpessoa = 8410861; ' );
  
    EXCEPTION
      WHEN OTHERS THEN
        
        vr_dscritic := 'Erro ao atualizar pessoa: ' || SQLERRM;
        RAISE vr_exception;
        
    END;
  
  
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN no_data_found THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    COMMIT;
    
  WHEN vr_exception THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
END;
