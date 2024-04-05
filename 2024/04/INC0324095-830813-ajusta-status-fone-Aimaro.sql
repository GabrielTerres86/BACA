DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0324095_na.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0324095_ajusta_status_fone_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0324095_ajusta_status_fone_relatorio_exec.txt';
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
    SELECT T.IDPESSOA
      , T.INSITUACAO
      , 2               INSITUACAO_CORRIGIR
      , ROWID           ROWID_FONE
    FROM CECRED.TBCADAST_PESSOA_TELEFONE T
    WHERE NVL(T.INSITUACAO, 1) NOT IN (1,2);
  
  rg_dados              cr_dados%ROWTYPE;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0324095';
  
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
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'IDPESSOA;SITUACAO ATUAL;NOVA SITUACAO;ROWID REGISTRO;STATUS LOG;DETALHES');
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  OPEN cr_dados;
  LOOP
    FETCH cr_dados INTO rg_dados;
    EXIT WHEN cr_dados%NOTFOUND;
    
    vr_base_log := rg_dados.IDPESSOA || ';' ||
                   rg_dados.INSITUACAO || ';' ||
                   rg_dados.INSITUACAO_CORRIGIR || ';' ||
                   rg_dados.ROWID_FONE;
    
    BEGIN
      
      UPDATE CECRED.TBCADAST_PESSOA_TELEFONE
        SET INSITUACAO = rg_dados.INSITUACAO_CORRIGIR
      WHERE ROWID = rg_dados.ROWID_FONE;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  UPDATE CECRED.TBCADAST_PESSOA_TELEFONE SET INSITUACAO = ' || rg_dados.INSITUACAO || ' WHERE ROWID = ''' || rg_dados.ROWID_FONE || '''; ');
      
      vr_count := vr_count + 1;
      
    EXCEPTION 
      WHEN OTHERS THEN 
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ERRO;Erro nao tratado ao atualizar situacao na PESSOA_TELEFONE.: ' || SQLERRM);
        
    END;
    
    IF vr_count >= 1000 THEN
      
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
