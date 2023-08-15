DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0280894_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0280894_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0280894_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_nrcpfcgc           CECRED.crapass.NRCPFCGC%TYPE;
  vr_nmrescop           CECRED.crapcop.NMRESCOP%TYPE;
  vr_cdcooper           CECRED.crapcop.CDCOOPER%TYPE;
  vr_nrdconta           CECRED.crapass.NRDCONTA%TYPE;
  vr_vlrenda            CECRED.crapttl.VLDRENDI##1%TYPE;
  vr_dsjusren           VARCHAR2(500);
  vr_dtmvtolt           CECRED.crapalt.DTALTERA%TYPE;
  vr_comments           VARCHAR2(2000);
  vr_msgalt             VARCHAR2(1000);
  vr_hrtransa           CECRED.craplgm.HRTRANSA%TYPE;
  vr_nrdrowid           ROWID;
  vr_registrar_log      BOOLEAN;
  vr_nmcampologTP       VARCHAR2(50);
  vr_nmcampologVL       VARCHAR2(50);
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_crapttl (pr_cooperativa  IN CECRED.crapass.CDCOOPER%TYPE
                   , pr_conta        IN CECRED.crapass.NRDCONTA%TYPE
                   , pr_cpf          IN CECRED.crapttl.NRCPFCGC%TYPE) IS
    SELECT tpdrendi##1
      , vldrendi##1
    FROM CECRED.crapttl 
    WHERE cdcooper = pr_cooperativa
      AND nrdconta = pr_conta
      AND nrcpfcgc = pr_cpf;
  
  rg_crapttl  cr_crapttl%ROWTYPE;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0280894';
  
  vr_count_file := 0;
  vr_seq_file   := 1;
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp || LPAD(vr_seq_file, 3, '0') || '.sql'
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqlog
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arqlog
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarquiv
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_input_file
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                              ,pr_des_text => vr_setlinha);
  
  vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
  
  vr_cdcooper := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1, vr_setlinha, ';') ) );
  vr_nrdconta := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2, vr_setlinha, ';') ) );
  vr_nrcpfcgc := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(3, vr_setlinha, ';') ) );
  
  OPEN cr_crapttl(vr_cdcooper, vr_nrdconta, vr_nrcpfcgc);
  FETCH cr_crapttl INTO rg_crapttl;
  CLOSE cr_crapttl;
  
  BEGIN
    
    UPDATE CECRED.crapttl 
      SET vldrendi##1 = 0
    WHERE cdcooper = vr_cdcooper
      and nrdconta = vr_nrdconta
      and nrcpfcgc = vr_nrcpfcgc;
    
    vr_count := SQL%ROWCOUNT;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.crapttl SET vldrendi##1 = ' || TRIM( replace( to_char(rg_crapttl.vldrendi##1, 'FM99999999D99'), ',', '.') )
                                                  || ' WHERE cdcooper = ' || vr_cdcooper 
                                                  || '   and nrdconta = ' || vr_nrdconta 
                                                  || '   and nrcpfcgc = ' || vr_nrcpfcgc || ';');
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Alterados ' || vr_count || ' registros. ');
    
  EXCEPTION
    WHEN OTHERS THEN
      
      vr_dscritic := 'Erro ao atualizar crapass: ' || SQLERRM;
      RAISE vr_exception;
      
  END;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20003, 'Erro: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20004, 'ERRO NÃO TRATADO: ' || SQLERRM);
    
END;
