DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0280195_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0280195_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0280195_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  vr_comments           VARCHAR2(2000);
  vr_status             VARCHAR2(10);
  
  vr_setlinha           VARCHAR2(10000);
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  vr_count              number;
  vr_stsnrcal           BOOLEAN;
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_dados IS
    SELECT p.*
    FROM cecred.tbcadast_pessoa p
    WHERE NVL(p.tppessoa, 0) = 2
      AND length(p.nrcpfcgc) <= 11;

  rg_dados       cr_dados%rowtype;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0280195';
  
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
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  
  vr_count := 0;
  
  vr_comments := ' Cabeçalho para geração do log de execução ';
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
    'TIPO' || 
    ';idpessoa' || 
    ';nrcpfcgc' || 
    ';nmpessoa' || 
    ';nmpessoa_receita' || 
    ';tppessoa' || 
    ';dtconsulta_spc' || 
    ';dtconsulta_rfb' || 
    ';cdsituacao_rfb' || 
    ';tpconsulta_rfb' || 
    ';dtatualiza_telefone' || 
    ';dtconsulta_scr' || 
    ';tpcadastro' || 
    ';cdoperad_altera' || 
    ';idcorrigido' || 
    ';dtalteracao' || 
    ';dtrevisao_cadastral' || 
    ';nrtentativa' || 
    ';nrdconta' || 
    ';cdcooper'
  );
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  
  OPEN cr_dados;
  LOOP
    FETCH cr_dados into rg_dados;
    EXIT WHEN cr_dados%NOTFOUND;
    
    vr_stsnrcal := FALSE;
    vr_status   := 'OK';
    CECRED.gene0005.pc_valida_cpf(pr_nrcalcul => rg_dados.nrcpfcgc
                  ,pr_stsnrcal => vr_stsnrcal);
    
    IF vr_stsnrcal = TRUE THEN
      
      BEGIN
        
        UPDATE CECRED.TBCADAST_PESSOA
          SET tppessoa = 1
        WHERE idpessoa = rg_dados.idpessoa;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.TBCADAST_PESSOA SET tppessoa = ' || NVL( TO_CHAR(rg_dados.tppessoa), 'NULL') || ' WHERE idpessoa = ' || rg_dados.idpessoa || '; ');
        
      EXCEPTION
        WHEN OTHERS THEN
          
          vr_status   := ' ERRO ';
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO ao atualizar registro;' || SQLERRM );
          
      END;
      
      vr_count := vr_count + 1;
      
      vr_comments := ' Geração dos dados alterados em arquivo de log para posterior conferência ';
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,
        'CPF ' || vr_status ||  
        ';'    || rg_dados.idpessoa || 
        ';'    || rg_dados.nrcpfcgc || 
        ';'    || rg_dados.nmpessoa || 
        ';'    || rg_dados.nmpessoa_receita || 
        ';'    || rg_dados.tppessoa || 
        ';'    || rg_dados.dtconsulta_spc || 
        ';'    || rg_dados.dtconsulta_rfb || 
        ';'    || rg_dados.cdsituacao_rfb || 
        ';'    || rg_dados.tpconsulta_rfb || 
        ';'    || rg_dados.dtatualiza_telefone || 
        ';'    || rg_dados.dtconsulta_scr || 
        ';'    || rg_dados.tpcadastro || 
        ';'    || rg_dados.cdoperad_altera || 
        ';'    || rg_dados.idcorrigido || 
        ';'    || rg_dados.dtalteracao || 
        ';'    || rg_dados.dtrevisao_cadastral || 
        ';'    || rg_dados.nrtentativa || 
        ';'    || rg_dados.nrdconta || 
        ';'    || rg_dados.cdcooper
      );
      
    END IF;
    
  END LOOP;
  
  CLOSE cr_dados;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Total de ' || vr_count || ' registros encontrados.');
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
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
