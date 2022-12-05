DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarqatv           VARCHAR2(50) := 'RITM0263765_base_ativar_itg.csv';
  vr_nmarqint           VARCHAR2(50) := 'RITM0263765_base_inativar_itg.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0263765_ROLLBACK_status_itg.sql';
  vr_nmarqlog           VARCHAR2(50) := 'RITM0263765_log_execucao.txt';
  vr_input_ativa        UTL_FILE.FILE_TYPE;
  vr_input_inativa      UTL_FILE.FILE_TYPE;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
    
  CURSOR cr_crapass(pr_cdcooper IN CECRED.crapass.CDCOOPER%TYPE
                   ,pr_nrdconta IN CECRED.crapass.NRDCONTA%TYPE ) IS
    SELECT a.flgctitg
      FROM CECRED.crapass a
    WHERE a.cdcooper = pr_cdcooper
      AND a.nrdconta = pr_nrdconta;
  rg_crapass   cr_crapass%ROWTYPE;
    
  vr_nrdrowid    ROWID;
  vr_cdcooper    CECRED.crapass.CDCOOPER%TYPE;
  vr_nrdconta    CECRED.crapass.NRCPFCGC%TYPE;
    
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0263765';
  
  gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto
                           ,pr_nmarquiv => vr_nmarqatv
                           ,pr_tipabert => 'R'
                           ,pr_utlfileh => vr_input_ativa
                           ,pr_des_erro => vr_dscritic);
  
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exception;
  END IF;
  
  gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto
                           ,pr_nmarquiv => vr_nmarqint
                           ,pr_tipabert => 'R'
                           ,pr_utlfileh => vr_input_inativa
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
  
  LOOP
    
    BEGIN
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_inativa
                                  ,pr_des_text => vr_setlinha);
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
    END;
    
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    vr_cdcooper := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1,vr_setlinha,';') ) );
    vr_nrdconta := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2,vr_setlinha,';') ) );
    
    BEGIN
      
      OPEN  cr_crapass(vr_cdcooper,vr_nrdconta);
      FETCH cr_crapass INTO rg_crapass;
      CLOSE cr_crapass;
      
      UPDATE CECRED.crapass ass 
         SET ass.flgctitg = 3 
       WHERE ass.cdcooper = vr_cdcooper
         AND ass.nrdconta = vr_nrdconta;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  UPDATE CECRED.crapass SET flgctitg = ' || rg_crapass.flgctitg
                                                 || ' WHERE nrdconta = ' || vr_nrdconta
                                                 || ' AND cdcooper = ' || vr_cdcooper || '; ' );
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar a coop/conta '||vr_cdcooper||'/'||vr_nrdconta;
        RAISE vr_exception;
    END;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => '1',
                                pr_dscritic => NULL,
                                pr_dsorigem => 'Aimaro',
                                pr_dstransa => 'RITM0263765 - Alteracao situacao conta ITG',
                                pr_dttransa => datascooperativa(vr_cdcooper).dtmvtolt,
                                pr_flgtrans => 1,
                                pr_hrtransa => gene0002.fn_busca_time,
                                pr_idseqttl => 0,
                                pr_nmdatela => 'JOB', 
                                pr_nrdconta => vr_nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'Situacao ITG'
                                    ,pr_dsdadant => rg_crapass.flgctitg
                                    ,pr_dsdadatu => 3 );
    
  END LOOP;
  
  LOOP
    
    BEGIN
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_ativa
                                  ,pr_des_text => vr_setlinha);
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
    END;
    
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    vr_cdcooper := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1,vr_setlinha,';') ) );
    vr_nrdconta := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2,vr_setlinha,';') ) );
    
    BEGIN
      
      OPEN  cr_crapass(vr_cdcooper,vr_nrdconta);
      FETCH cr_crapass INTO rg_crapass;
      CLOSE cr_crapass;
    
      UPDATE CECRED.crapass ass 
         SET ass.flgctitg = 2
       WHERE ass.cdcooper = vr_cdcooper
         AND ass.nrdconta = vr_nrdconta;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  UPDATE CECRED.crapass SET flgctitg = ' || rg_crapass.flgctitg
                                                 || ' WHERE nrdconta = ' || vr_nrdconta
                                                 || ' AND cdcooper = ' || vr_cdcooper || '; ' );
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar a coop/conta '||vr_cdcooper||'/'||vr_nrdconta;
        RAISE vr_exception;
    END;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => '1',
                                pr_dscritic => NULL,
                                pr_dsorigem => 'Aimaro',
                                pr_dstransa => 'RITM0263765 - Alteracao situacao conta ITG',
                                pr_dttransa => datascooperativa(vr_cdcooper).dtmvtolt,
                                pr_flgtrans => 1,
                                pr_hrtransa => gene0002.fn_busca_time,
                                pr_idseqttl => 0,
                                pr_nmdatela => 'JOB', 
                                pr_nrdconta => vr_nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'Situacao ITG'
                                    ,pr_dsdadant => rg_crapass.flgctitg
                                    ,pr_dsdadatu => 2 );
    
  END LOOP;
  
  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_inativa);
  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_ativa);

  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;

EXCEPTION 
  WHEN vr_exception THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_inativa);
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_ativa);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_inativa);
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_ativa);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
END;

