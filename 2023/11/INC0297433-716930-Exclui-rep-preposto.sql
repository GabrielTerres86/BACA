DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0297433_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0297433_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0297433_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_nrcpf              CECRED.crapass.NRCPFCGC%TYPE;
  vr_nrcnpj             CECRED.crapass.NRCPFCGC%TYPE;
  vr_deletou            BOOLEAN;
  
  vr_comments           VARCHAR2(2000);
  vr_ttlencontrado      BOOLEAN;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_dados (pr_cpf_rep     IN CECRED.crapass.NRCPFCGC%TYPE
                 , pr_cnpj        IN CECRED.crapass.NRCPFCGC%TYPE ) IS 
    SELECT ROWID rowid_prep
      , l.*
    FROM CECRED.Tbcc_Limite_Preposto l
    WHERE l.nrcpf = pr_cpf_rep
      AND EXISTS (
        SELECT 1
        FROM CECRED.CRAPASS a
        WHERE a.cdcooper = l.cdcooper
          AND a.nrdconta = l.nrdconta
          AND a.nrcpfcgc = pr_cnpj
      );
  
  rg_dados              cr_dados%ROWTYPE;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0297433';
  
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
    
  vr_comments := 'CPF Representante;CNPJ Cooperado';
  
  vr_nrcpf  := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1, vr_setlinha, ';') ) );
  vr_nrcnpj := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2, vr_setlinha, ';') ) );
  vr_deletou := FALSE;
    
  OPEN cr_dados(vr_nrcpf, vr_nrcnpj);
  LOOP
    FETCH cr_dados INTO rg_dados;
    EXIT WHEN cr_dados%NOTFOUND;
    
    BEGIN
      
      DELETE CECRED.tbcc_limite_preposto
      WHERE ROWID = rg_dados.rowid_prep;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Excluídos ' || SQL%ROWCOUNT || ' registros para o CPF ' || rg_dados.nrcpf);
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv ,
        '  INSERT INTO CECRED.tbcc_limite_preposto ( ' ||
          '  cdcooper ' || 
          '  , nrdconta ' || 
          '  , nrcpf ' || 
          '  , flgmaster ' || 
          '  , cdoperad ' || 
          '  , vllimite_transf ' || 
          '  , dtlimite_transf ' || 
          '  , vllimite_pagto ' || 
          '  , dtlimite_pagto ' || 
          '  , vllimite_ted ' || 
          '  , dtlimite_ted ' || 
          '  , vllimite_vrboleto ' || 
          '  , dtlimite_vrboleto ' || 
          '  , vllimite_folha ' || 
          '  , dtlimite_folha ' || 
          ' ) VALUES (' ||
            rg_dados.cdcooper || ', ' || 
            rg_dados.nrdconta || ', ' || 
            rg_dados.nrcpf || ', ' || 
            rg_dados.flgmaster || ', ' || 
            ' ''' || rg_dados.cdoperad || ''', ' || 
            REPLACE( REPLACE(rg_dados.vllimite_transf, '.', ''), ',', '.')  || ', ' || 
            CASE WHEN rg_dados.dtlimite_transf IS NOT NULL
              THEN 'TO_DATE(''' || TO_CHAR(rg_dados.dtlimite_transf, 'DD/MM/RRRR HH24:MI:SS') || ''', ''DD/MM/RRRR HH24:MI:SS'') ' 
              ELSE 'NULL'
              END || ', ' || 
            REPLACE( REPLACE(rg_dados.vllimite_pagto, '.', ''), ',', '.') || ', ' || 
            CASE WHEN rg_dados.dtlimite_pagto IS NOT NULL
              THEN 'TO_DATE(''' || TO_CHAR(rg_dados.dtlimite_pagto, 'DD/MM/RRRR HH24:MI:SS') || ''', ''DD/MM/RRRR HH24:MI:SS'') ' 
              ELSE 'NULL'
              END || ', ' ||
            REPLACE( REPLACE(rg_dados.vllimite_ted, '.', ''), ',', '.') || ', ' || 
            CASE WHEN rg_dados.dtlimite_ted IS NOT NULL
              THEN 'TO_DATE(''' || TO_CHAR(rg_dados.dtlimite_ted, 'DD/MM/RRRR HH24:MI:SS') || ''', ''DD/MM/RRRR HH24:MI:SS'') ' 
              ELSE 'NULL'
              END || ', ' ||
            REPLACE( REPLACE(rg_dados.vllimite_vrboleto, '.', ''), ',', '.') || ', ' || 
            CASE WHEN rg_dados.dtlimite_vrboleto IS NOT NULL
              THEN 'TO_DATE(''' || TO_CHAR(rg_dados.dtlimite_vrboleto, 'DD/MM/RRRR HH24:MI:SS') || ''', ''DD/MM/RRRR HH24:MI:SS'') ' 
              ELSE 'NULL'
              END || ', ' ||
            REPLACE( REPLACE(rg_dados.vllimite_folha, '.', ''), ',', '.') || ', ' || 
            CASE WHEN rg_dados.dtlimite_folha IS NOT NULL
              THEN 'TO_DATE(''' || TO_CHAR(rg_dados.dtlimite_folha, 'DD/MM/RRRR HH24:MI:SS') || ''', ''DD/MM/RRRR HH24:MI:SS'') ' 
              ELSE 'NULL'
              END ||
          ');'
      );
      
      vr_deletou := TRUE;
      
    EXCEPTION 
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Erro ao fazer o DELETE: ' || SQLERRM);
        
    END;
    
  END LOOP;
  
  CLOSE cr_dados;
  
  IF NOT vr_deletou THEN
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ATENÇÃO: Não foi encontrado um registro para deleção. CPF | CNPJ: ' || vr_nrcpf || ' | ' || vr_nrcnpj);
  END IF;
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
    WHEN no_data_found THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ARQUIVO COM DADOS PARA ATUALIZAÇÃO NÃO ENCONTRADO.');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(2000, 'ARQUIVO COM DADOS PARA ATUALIZAÇÃO NÃO ENCONTRADO.');
    
  WHEN vr_exception THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20003, 'Erro: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20004, 'ERRO NÃO TRATADO: ' || SQLERRM);
    
END;
