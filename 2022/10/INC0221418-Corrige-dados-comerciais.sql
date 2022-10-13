DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0221418_cpfs.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0221418_cpfs_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'INC0221418_log_execucao.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  CURSOR cr_crapttl ( pr_cdcooper IN CECRED.crapttl.CDCOOPER%TYPE
                    , pr_nrdconta IN CECRED.crapttl.NRDCONTA%TYPE
                    , pr_nrseqttl IN CECRED.crapttl.IDSEQTTL%TYPE) IS
    SELECT t.dsproftl
      , t.cdturnos
      , t.cdnvlcgo
    FROM CECRED.CRAPTTL t
    WHERE t.nrdconta = pr_nrdconta
      AND t.cdcooper = pr_cdcooper
      AND t.Idseqttl = pr_nrseqttl;
  
  rw_crapttl     cr_crapttl%ROWTYPE;
  
  vr_idseqttl    CECRED.crapttl.IDSEQTTL%TYPE;
  vr_cdcooper    CECRED.crapass.CDCOOPER%TYPE;
  vr_nrdconta    CECRED.crapass.NRDCONTA%TYPE;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0221418';
  
  gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto
                           ,pr_nmarquiv => vr_nmarquiv
                           ,pr_tipabert => 'R'
                           ,pr_utlfileh => vr_input_file
                           ,pr_des_erro => vr_dscritic);
  
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
    
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
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
  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');

  vr_count := 0;
  
  LOOP
    
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                ,pr_des_text => vr_setlinha);
    
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    vr_nrdconta := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1,vr_setlinha,';') ) );
    vr_cdcooper := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2,vr_setlinha,';') ) );
    vr_idseqttl := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(3,vr_setlinha,';') ) );
    
    OPEN cr_crapttl(pr_cdcooper => vr_cdcooper
                  , pr_nrdconta => vr_nrdconta
                  , pr_nrseqttl => vr_idseqttl);
    FETCH cr_crapttl INTO rw_crapttl;
    CLOSE cr_crapttl;
    
    UPDATE CECRED.CRAPTTL t
      SET t.dsproftl = 'ATUALIZAR'
        , t.cdnvlcgo = 6
        , t.cdturnos = 4
    WHERE t.idseqttl = vr_idseqttl
      AND t.cdcooper = vr_cdcooper
      AND t.nrdconta = vr_nrdconta;
      
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    UPDATE CECRED.CRAPTTL SET  '
                                                    || ' dsproftl = '''  || rw_crapttl.dsproftl || ''' '
                                                    || ' , cdnvlcgo = '  || NVL( to_char(rw_crapttl.cdnvlcgo), 'NULL' )
                                                    || ' , cdturnos = '  || NVL( to_char(rw_crapttl.cdturnos), 'NULL' )
                                                    || ' WHERE nrdconta = ' || vr_nrdconta
                                                    || '   AND cdcooper = ' || vr_cdcooper
                                                    || '   AND idseqttl = ' || vr_idseqttl || '; ' );
      
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, SQL%ROWCOUNT || ' registros atualizados na CRAPTTL para Conta x Cooperativa x Seq. Tit. : ' 
                                                  || vr_nrdconta || ' x ' || vr_cdcooper || ' x ' || vr_idseqttl);
    
  END LOOP;
  
  COMMIT;
  

EXCEPTION 
  WHEN no_data_found THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    COMMIT;
    
  WHEN vr_exception THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
END;

