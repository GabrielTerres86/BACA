DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'EI902788_dados_atualizar.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'EI902788_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'EI902788_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  vr_base_log           VARCHAR(500);
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_nrmatric           CECRED.crapass.NRMATRIC%TYPE;
  vr_nrcpfcgc           CECRED.crapass.NRCPFCGC%TYPE;
  vr_nrdconta           CECRED.crapass.NRDCONTA%TYPE;
  vr_cdcooper           CECRED.crapass.CDCOOPER%TYPE;
  vr_idseqttl           CECRED.crapttl.IDSEQTTL%TYPE;
  vr_qtd_regs_upd       PLS_INTEGER;
  
  vr_comments           VARCHAR2(2000);
  
  vr_nrmatric_new       CECRED.CRAPASS.NRMATRIC%TYPE;
  
  TYPE TP_MAT_COOPERADO IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(30);
  
  vt_mat_cooperado TP_MAT_COOPERADO;
  
  vr_index         VARCHAR2(30);
  
  CURSOR cr_dados_rbk (pr_cdcooper IN CECRED.CRAPASS.CDCOOPER%TYPE
                     , pr_nrdconta IN CECRED.CRAPASS.NRDCONTA%TYPE
                     , pr_nrcpfcgc IN CECRED.CRAPASS.NRCPFCGC%TYPE) IS
    SELECT A.NRMATRIC
    FROM CADASTRO.TB_PESSOA_CRAPASS A
    WHERE A.CDCOOPER = pr_cdcooper
      AND A.NRDCONTA = pr_nrdconta
      AND A.NRCPFCGC = pr_nrcpfcgc;
  
  rg_dados_rbk          cr_dados_rbk%ROWTYPE;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  vr_dscritic_mat       VARCHAR2(4000);
  
  FUNCTION fn_gera_matricula_autonoma (pr_cooper  IN CECRED.crapass.CDCOOPER%TYPE) RETURN NUMBER IS
    vr_matricula_gerada  NUMBER(10);
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    vr_comments := ' ## Criada função autônoma para evitar Locks na base durante a execução do script.';
    
    vr_matricula_gerada := CADASTRO.obterNovaMatricula(pr_cooper);
    
    COMMIT;
    
    vr_dscritic_mat := NULL;
    RETURN vr_matricula_gerada;
    
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic_mat := 'ERRO ao gerar nova matricula: ' || SQLERRM;
  END;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/EI902788';
  
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
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Inicio: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  vr_comments := ' ## Cabeçalho do log de execução.';
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'STATUS;MATRICULA;CPF;CONTA;COOPERATIVA;SEQ TTL;DS LOG');
  
  LOOP
    
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                ,pr_des_text => vr_setlinha);
    
    vr_comments := ' 1) NRMATRIC, 2) NRCPFCGC, 3) NRDCONTA, 4) CDCOOPER, 5) IDSEQTTL';
    
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    
    vr_nrmatric := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1, vr_setlinha, ';') ) );
    vr_nrcpfcgc := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2, vr_setlinha, ';') ) );
    vr_nrdconta := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(3, vr_setlinha, ';') ) );
    vr_cdcooper := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(4, vr_setlinha, ';') ) );
    vr_idseqttl := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(5, vr_setlinha, ';') ) );
    
    vr_base_log := vr_nrmatric || ';' ||
                   vr_nrcpfcgc || ';' ||
                   vr_nrdconta || ';' ||
                   vr_cdcooper || ';' ||
                   vr_idseqttl || ';';
    
    vr_comments := ' GARANTIA DE INTEGRIDADE. VALIDANDO TODOS OS DADOS QUE DEVEM EXISTIR OBRIGATORIAMENTE';
    IF vr_nrmatric IS NULL OR
       vr_nrcpfcgc IS NULL OR
       vr_nrdconta IS NULL OR
       vr_cdcooper IS NULL OR
       vr_idseqttl IS NULL THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NO CSV PARA CORRECAO' || ';' || 
                                                    vr_base_log                 || ';' ||
                                                    'Algum valor obrigatorio foi enviado nulo para correcao das matriculas.');
      
      CONTINUE;
      
    END IF;
    
    vr_comments := ' Gerando apenas uma matrícula por cooperado e relacionando com todas as contas dele.';
    vr_index := vr_nrcpfcgc || ';' || vr_cdcooper;
    vr_nrmatric_new := 0;
    IF vt_mat_cooperado.EXISTS(vr_index) THEN
      vr_nrmatric_new := vt_mat_cooperado(vr_index);
    ELSE
      vr_nrmatric_new := fn_gera_matricula_autonoma(vr_cdcooper);
      vt_mat_cooperado(vr_index) := vr_nrmatric_new;
    END IF;
    
    vr_comments := ' ## Caso tenha encontrado alguma matrícula nova aplicável à conta do Cooperado, fazer o update.';
    IF NVL(vr_nrmatric_new, 0) > 0 THEN
      
      OPEN cr_dados_rbk(vr_cdcooper, vr_nrdconta, vr_nrcpfcgc);
      FETCH cr_dados_rbk INTO rg_dados_rbk;
      
      IF cr_dados_rbk%NOTFOUND THEN
        vr_comments := ' Conta não encontrada para atualização, pular o registro e gerar log.';
        
        CLOSE cr_dados_rbk;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO'        || ';' || 
                                                      vr_base_log   || ';' ||
                                                      'Conta NAO localizada para atualizacao da matricula.' );
      
        CONTINUE;
        
      END IF;
      
      CLOSE cr_dados_rbk;
      
      BEGIN
        
        UPDATE CECRED.CRAPASS A
          SET A.NRMATRIC = vr_nrmatric_new
        WHERE A.CDCOOPER = vr_cdcooper
          AND A.NRDCONTA = vr_nrdconta
          AND A.NRCPFCGC = vr_nrcpfcgc;
        
        vr_qtd_regs_upd := SQL%ROWCOUNT;
        
        IF vr_qtd_regs_upd = 1 THEN
          vr_comments := ' ## SUCESSO no UPDATE';
          
        ELSE 
          vr_comments := ' ## ERRO no UPDATE';
          
        END IF;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_comments  || ';' || 
                                                      vr_base_log  || ';' ||
                                                      'Qtd registros afetados update: ' || vr_qtd_regs_upd || 
                                                      '. Nova matricula: ' || vr_nrmatric_new);
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,
          '  UPDATE CECRED.CRAPASS A ' || 
          ' SET A.NRMATRIC = ' || rg_dados_rbk.nrmatric ||
          ' WHERE A.CDCOOPER = ' || vr_cdcooper ||
          '   AND A.NRDCONTA = ' || vr_nrdconta ||
          '   AND A.NRCPFCGC = ' || vr_nrcpfcgc || ' ;'
        );
        
        vr_count := vr_count + 1;
        
      EXCEPTION 
        WHEN OTHERS THEN 
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO   '    || ';' || 
                                                        vr_base_log  || ';' ||
                                                        'Erro ao atualizar Matricula na CRAPASS: ' || SQLERRM );
         
      END;
      
    ELSE
      
      vr_comments := ' ### Falha na geração do número de Matrícula para o cooperado.';
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NR MATRICULA'      || ';' || 
                                                    vr_base_log   || ';' ||
                                                    'Numero de matricula invalido para atualizacao na conta: ' || NVL( TRIM( TO_CHAR(vr_nrmatric_new) ), 'NULO') );
      
      CONTINUE;
      
    END IF;
    
    IF vr_count >= 10 THEN
      
      COMMIT;
      
      vr_count := 0;
      
    END IF;
  
  END LOOP;
    
  
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
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    COMMIT;
    
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
