DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0251990_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0251990_script_ROLLBACK_02.sql';
  vr_nmarqbkpnovo       VARCHAR2(50);
  vr_nmarqlog           VARCHAR2(50) := 'INC0251990_relatorio_exec_02.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arquiv2        utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_tot          PLS_INTEGER;
  vr_count_enc          PLS_INTEGER;
  vr_commit             PLS_INTEGER;
  
  vr_cdcooper           CECRED.crapass.CDCOOPER%TYPE;
  vr_nrdconta           CECRED.crapass.NRDCONTA%TYPE;
  vr_nrcpfcgc           CECRED.crapass.NRCPFCGC%TYPE;
  vr_dtnasttl_new       CECRED.crapttl.DTNASTTL%TYPE;
  vr_dtnasttl_atu       CECRED.crapttl.DTNASTTL%TYPE;
  vr_dtmvtolt           DATE;
  vr_lgrowid            ROWID;
  vr_msgalt             VARCHAR2(150);
  vr_seqarquiv          PLS_INTEGER;
  vr_dsmodule           VARCHAR2(100);
  
  CURSOR cr_dados IS 
    SELECT e.rowid  id_reg
      , e.nrdconta
      , e.cdcooper
      , e.idseqttl
      , e.cdseqinc
      , e.complend
    FROM cecred.CRAPENC E
    WHERE E.COMPLEND IS NULL;
  
  rg_dados  cr_dados%ROWTYPE;
  
  vr_atualiza_seq BOOLEAN;
  vr_maior        NUMBER;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0251990';
  
  vr_seqarquiv := 1;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp || '_' || lpad(vr_seqarquiv, 4, '0')
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
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início do Script: ' || to_char(sysdate, 'DD/MM/RRRR HH24:MI:SS'));
  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  
  vr_count     := 0;
  vr_count_enc := 0;
  vr_count_tot := 0;
  vr_commit    := 0;
  
  OPEN cr_dados;
  LOOP
    FETCH cr_dados INTO rg_dados;
    EXIT WHEN cr_dados%NOTFOUND;
    
    vr_count     := vr_count + 1;
    vr_count_tot := vr_count_tot + 1;
    vr_count_enc := vr_count_enc + 1;
    vr_commit    := vr_commit + 1;
    
    BEGIN
      
      UPDATE cecred.crapenc
        SET complend = ' '
      WHERE rowid = rg_dados.id_reg;
      
      IF SQL%ROWCOUNT <> 1 THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ###### ATENÇÃO: Quantidade de registros atualizados diferente de 1 (coop;conta;seqttl;cdseqinc): ' 
          || rg_dados.cdcooper || ';'
          || rg_dados.nrdconta || ';'
          || rg_dados.idseqttl || ';'
          || rg_dados.cdseqinc);
        
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        
        CLOSE cr_dados;
        vr_dscritic := 'Erro ao atualizar tabela CRAPENC: ' || SQLERRM;
        RAISE vr_exception;
        
    END;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE cecred.crapenc SET complend = NULL '
                                               || ' WHERE ROWID = ''' || rg_dados.id_reg || '''; ' );
    
    IF vr_count >= 8000 THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
      
      vr_seqarquiv := (vr_seqarquiv + 1);
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' *** Quebra de arquivo: ' || vr_seqarquiv || ' (Total:' || vr_count_tot || ')' || ' (crapenc: ' || vr_count_enc || ')');
      
      vr_nmarqbkpnovo := vr_nmarqbkp || '_' || lpad(vr_seqarquiv, 4, '0');
      
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                              ,pr_nmarquiv => vr_nmarqbkpnovo
                              ,pr_tipabert => 'W'
                              ,pr_utlfileh => vr_ind_arquiv
                              ,pr_des_erro => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        
        vr_dscritic := 'Erro ao abrir o arquivo ' || vr_nmarqbkpnovo;
        RAISE vr_exception;
        
      END IF;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
      
      vr_count := 0;
      
    END IF;
    
    IF vr_commit >= 500 THEN
      
      COMMIT;
      
      vr_commit := 0;
      
    END IF;
    
  END LOOP;
  
  CLOSE cr_dados;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || to_char(sysdate, 'DD/MM/RRRR HH24:MI:SS'));
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION 
  
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
END;
