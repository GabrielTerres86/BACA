DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0222158_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0222158_dados_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'INC0222158_log_execucao.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  CURSOR cr_CONTAS ( pr_cdcooper IN CECRED.crapass.CDCOOPER%TYPE
                   , pr_nrdconta IN CECRED.crapass.NRDCONTA%TYPE ) IS
    SELECT a.dtadmiss
         , a.dtmvtolt
         , a.dtabtcct
    FROM CECRED.CRAPASS A
    WHERE a.nrdconta = pr_nrdconta
      AND a.cdcooper = pr_cdcooper;
  
  rw_contas       cr_contas%ROWTYPE;
  
 
  
  vr_nrcpfcgc    CECRED.crapttl.NRCPFCGC%TYPE;
  vr_tabela      VARCHAR2(20);
  vr_cdcooper    CECRED.crapass.CDCOOPER%TYPE;
  vr_nrdconta    CECRED.crapass.NRDCONTA%TYPE;
  vr_data        CECRED.crapass.DTADMISS%TYPE;
  vr_nome        CECRED.crapass.NMPRIMTL%TYPE;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0222158';
  
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
    vr_cdcooper := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1,vr_setlinha,';') ) );
    vr_nrdconta := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2,vr_setlinha,';') ) );
    vr_data     := to_date( gene0002.fn_busca_entrada(3,vr_setlinha,';'), 'DD/MM/YYYY' );
  
    
    rw_contas   := NULL;
 
    
    
      OPEN cr_contas(vr_cdcooper, vr_nrdconta);
      FETCH cr_contas INTO rw_contas;
      
      IF cr_contas%NOTFOUND THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ***** A Conta x Cooperativa x CPF NÃO foi localizada. ' || vr_nrdconta || ' x ' || vr_cdcooper || ' x ' || vr_nrcpfcgc);
        
      END IF;
      
      CLOSE cr_contas;
    
      
      UPDATE CECRED.CRAPASS a
        SET a.dtadmiss = vr_data
          , a.dtabtcct = vr_data
          , a.dtmvtolt = vr_data
      WHERE a.cdcooper = vr_cdcooper
        AND a.nrdconta = vr_nrdconta;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    UPDATE CECRED.CRAPASS SET  '
                                                      || '   dtadmiss = to_date( '''  || rw_contas.dtadmiss || ''',''DD/MM/YYYY'') '
                                                      || ' , dtabtcct = to_date( '''  || rw_contas.dtabtcct || ''',''DD/MM/YYYY'') '
                                                      || ' , dtmvtolt = to_date( '''  || rw_contas.dtmvtolt || ''',''DD/MM/YYYY'') ' 
                                                      || 'WHERE nrdconta = ' || vr_nrdconta
                                                      || '  AND cdcooper = ' || vr_cdcooper || '; ' );
                                                   
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, SQL%ROWCOUNT || ' registros atualizados na CRAPASS para Conta x Cooperativa  : ' || vr_nrdconta || ' x ' || vr_cdcooper || ' x ' || vr_nrcpfcgc);
      
   
    
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

