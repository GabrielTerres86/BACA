DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0270274_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0270274_script_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'INC0270274_relatorio_exec.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arquiv2        utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              NUMBER(4);
  
  vr_nrdrowid       ROWID;
  vr_dscritic       VARCHAR2(2000);
  vr_exception      EXCEPTION;
  
  CURSOR cr_crapavt IS 
    SELECT av.nrcpfcgc
      , av.cdcooper
      , av.nrdconta
      , av.nrdctato
      , pd.nrctapro
      , count(*)      total_poderes
    FROM crapavt av
    JOIN crapass ass ON av.cdcooper = ass.cdcooper
                        AND av.nrdconta = ass.nrdconta
    JOIN crappod pd ON av.cdcooper     = pd.cdcooper
                       AND av.nrdconta = pd.nrdconta
                       AND av.nrcpfcgc = pd.nrcpfpro
                       AND av.nrdctato <> pd.nrctapro
    WHERE av.tpctrato = 6
      AND ass.cdsitdct NOT IN (3,4)
      AND NOT EXISTS (
                       SELECT 1
                       FROM crappod pod
                       WHERE av.nrdconta = pod.nrdconta
                         and av.cdcooper = pod.cdcooper
                         and av.nrcpfcgc = pod.nrcpfpro
                         and pd.nrctapro <> pod.nrctapro
                     )
    group by av.nrcpfcgc
      , av.cdcooper
      , av.nrdconta
      , av.nrdctato
      , pd.nrctapro
    ORDER BY av.cdcooper
      , av.nrdconta;
  
  rg_crapavt   cr_crapavt%ROWTYPE;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0270274';
  
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
  
  OPEN cr_crapavt;
  LOOP
    FETCH cr_crapavt INTO rg_crapavt;
    EXIT WHEN cr_crapavt%NOTFOUND;
    
    BEGIN
      
      UPDATE CECRED.crappod p
        SET p.nrctapro = rg_crapavt.nrdctato
      WHERE p.nrdconta = rg_crapavt.nrdconta
        AND p.cdcooper = rg_crapavt.cdcooper
        AND p.nrcpfpro = rg_crapavt.nrcpfcgc
        AND p.nrctapro = rg_crapavt.nrctapro
        ;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.crappod '
                                                 || '   SET nrctapro = '   || rg_crapavt.nrctapro
                                                 || ' WHERE nrdconta = ' || rg_crapavt.nrdconta
                                                 || '   AND cdcooper = ' || rg_crapavt.cdcooper 
                                                 || '   AND nrcpfpro = ' || rg_crapavt.nrcpfcgc
                                                 || '   AND nrctapro = ' || rg_crapavt.nrdctato || '; ');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Erro ao atualizar relacionamento com Poderes do Representante - CRAPPOD: ' || SQLERRM);
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Detalhes do registro com erro tentando aplicar nrdctato (' || rg_crapavt.nrdctato || ' ): '
                                                      || ' p.nrdconta = '     || rg_crapavt.nrdconta
                                                      || ' AND p.cdcooper = ' || rg_crapavt.cdcooper
                                                      || ' AND p.nrcpfpro = ' || rg_crapavt.nrcpfcgc
                                                      || ' AND p.nrctapro = ' || rg_crapavt.nrctapro
                                                      || chr(10) );
        
    END;
    
    IF vr_count >= 500 THEN
      
      vr_count := 0;
      
      COMMIT;
      
    END IF;
    
    vr_count := vr_count + 1;
    
  END LOOP;
  
  CLOSE cr_crapavt;
  
  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
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
