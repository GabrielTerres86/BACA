DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0332449_na.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0332449_ajusta_dtvig_avt_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0332449_ajusta_dtvig_avt_relat_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  vr_base_log           VARCHAR2(3000);
  
  vr_nrcpf              CECRED.crapass.NRCPFCGC%TYPE;
  vr_nrcnpj             CECRED.crapass.NRCPFCGC%TYPE;
  
  vr_comments           VARCHAR2(2000);
  vr_ttlencontrado      BOOLEAN;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_dados IS 
    SELECT ROWID              ROWID_AJUSTAR
      , AV.CDCOOPER
      , AV.NRDCONTA
      , AV.NRCTREMP
      , AV.NRCPFCGC
      , AV.NRDCTATO
      , AV.DTADMSOC
      , AV.DTVALIDA
    FROM CRAPAVT AV
    WHERE AV.TPCTRATO = 6
      AND AV.DTVALIDA IS NULL;
  
  rg_dados              cr_dados%ROWTYPE;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0332449';
  
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
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'CDCOOPER;NRDCONTA;NRCTREMP;NRCPFCGC;NRDCTATO;DTADMSOC;DTVALIDA;ROWID_AJUSTAR;STATUS LOG;DETALHES');
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  OPEN cr_dados;
  LOOP
    FETCH cr_dados INTO rg_dados;
    EXIT WHEN cr_dados%NOTFOUND;
    
    vr_base_log := rg_dados.CDCOOPER || ';' ||
                   rg_dados.NRDCONTA || ';' ||
                   rg_dados.NRCTREMP || ';' ||
                   rg_dados.NRCPFCGC || ';' ||
                   rg_dados.NRDCTATO || ';' ||
                   rg_dados.DTADMSOC || ';' ||
                   rg_dados.DTVALIDA || ';' ||
                   rg_dados.ROWID_AJUSTAR || ';';
    
    BEGIN
      
      UPDATE CECRED.CRAPAVT
        SET DTVALIDA = TO_DATE('31/12/9999', 'DD/MM/RRRR')
      WHERE ROWID = rg_dados.ROWID_AJUSTAR;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  UPDATE CECRED.CRAPAVT SET DTVALIDA = NULL WHERE ROWID = ''' || rg_dados.ROWID_AJUSTAR || '''; ');
      
      vr_count := vr_count + 1;
      
    EXCEPTION 
      WHEN OTHERS THEN 
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ERRO;Erro nao tratado ao atualizar situacao na PESSOA_TELEFONE.: ' || SQLERRM);
        
    END;
    
    IF vr_count >= 500 THEN
      
      COMMIT;
      
      vr_count := 0;
      
    END IF;
    
  END LOOP;
  
  CLOSE cr_dados;
  
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
