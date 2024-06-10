DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'US886878_crapenc_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'US886878_crapenc_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'US886878_crapenc_relatorio_exec.txt';
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
  
  CURSOR cr_busca_mat_cooperado ( pr_nrcpfcgc IN CECRED.CRAPASS.NRCPFCGC%TYPE
                                , pr_cdcooper IN CECRED.CRAPASS.CDCOOPER%TYPE ) IS
    SELECT A.NRMATRIC
    FROM CECRED.CRAPASS A
    WHERE A.NRCPFCGC = pr_nrcpfcgc
      AND A.CDCOOPER = pr_cdcooper
      AND A.NRMATRIC > 0
      AND NOT EXISTS ( SELECT 1
                       FROM CECRED.CRAPASS ASS
                       WHERE ASS.NRCPFCGC <> pr_nrcpfcgc
                         AND ASS.CDCOOPER = pr_cdcooper
                         AND ASS.NRMATRIC = A.NRMATRIC
        );
  
  vr_nrmatric_new       CECRED.CRAPASS.NRMATRIC%TYPE;
  
  CURSOR cr_valida_mat_duplicada ( pr_nrcpfcgc IN CECRED.CRAPASS.NRCPFCGC%TYPE
                                 , pr_cdcooper IN CECRED.CRAPASS.CDCOOPER%TYPE
                                 , pr_nrmatric IN CECRED.CRAPASS.NRMATRIC%TYPE) IS
    SELECT 1
    FROM CECRED.CRAPASS A
    WHERE A.CDCOOPER = pr_cdcooper
      AND A.NRMATRIC = pr_nrmatric
      AND A.NRCPFCGC <> pr_nrcpfcgc;
  
  vr_valida_mat         NUMBER(1);
  
  CURSOR cr_dados_rbk (pr_cdcooper IN CECRED.CRAPASS.CDCOOPER%TYPE
                     , pr_nrdconta IN CECRED.CRAPASS.NRDCONTA%TYPE
                     , pr_nrcpfcgc IN CECRED.CRAPASS.NRCPFCGC%TYPE) IS
    SELECT A.NRMATRIC
    FROM CECRED.CRAPASS A
    WHERE A.CDCOOPER = pr_cdcooper
      AND A.NRDCONTA = pr_nrdconta
      AND A.NRCPFCGC = pr_nrcpfcgc;
  
  rg_dados_rbk          cr_dados_rbk%ROWTYPE;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/US886878';
  
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
    
    vr_nrmatric_new := 0;
    
    IF vr_idseqttl = 1 THEN
      
      vr_comments := ' ### Tratativa para titular principal da conta.';
      
      IF vr_nrmatric = 0 THEN
        
        vr_comments := ' ### Quando o número da matrícula é zero, tem que:';
        vr_comments := '    1) Ver se o cooperado tem uma matrícula única e válida na cooperativa, caso sim, utilizar esta.';
        vr_comments := '    2) Caso não, criar uma para o Cooperado e vincular na conta dele.';
        
        OPEN cr_busca_mat_cooperado(vr_nrcpfcgc, vr_cdcooper);
        FETCH cr_busca_mat_cooperado INTO vr_nrmatric_new;
        
        IF cr_busca_mat_cooperado%NOTFOUND THEN
          CLOSE cr_busca_mat_cooperado;
          
          vr_nrmatric_new := CADASTRO.obterNovaMatricula(vr_cdcooper);
          
        END IF;
        
        IF cr_busca_mat_cooperado%ISOPEN THEN
          CLOSE cr_busca_mat_cooperado;
        END IF;
        
      ELSIF vr_nrmatric > 0 THEN
        
        vr_comments := ' ### Quando tem um número de matrícula, fazer algumas validações.';
        vr_comments := '    1) Confirmar se a matrícula realmente pertence a mais de um cooperado. Se pertencer apenas ao próprio cooperado, registrar log.';
        vr_comments := '    2) Caso confirmado problema, buscar alguma matrícula única na cooperativa pertencente ao Cooperado. Se não houver, criar uma nova.';
        
        OPEN cr_valida_mat_duplicada(vr_nrcpfcgc, vr_cdcooper, vr_nrmatric);
        FETCH cr_valida_mat_duplicada INTO vr_valida_mat;
        
        IF cr_valida_mat_duplicada%FOUND THEN
          
          CLOSE cr_valida_mat_duplicada;
          vr_comments := '    1) Confirmado. NR Matrícula pertence a mais de um cooperado.';
          
          vr_comments := '    2) Buscando um número de matrícula do cooperado.';
          OPEN cr_busca_mat_cooperado(vr_nrcpfcgc, vr_cdcooper);
          FETCH cr_busca_mat_cooperado INTO vr_nrmatric_new;
          
          IF cr_busca_mat_cooperado%NOTFOUND THEN
            CLOSE cr_busca_mat_cooperado;
            
            vr_comments := '    2) Caso não existir, criar uma nova e aplicar na conta.';
            vr_nrmatric_new := CADASTRO.obterNovaMatricula(vr_cdcooper);
            
          END IF;
          
          IF cr_busca_mat_cooperado%ISOPEN THEN
            CLOSE cr_busca_mat_cooperado;
          END IF;
          
        ELSE
          vr_comments := '    1) Gerar log para conferência pois a Matrícula pertence a um único cooperado.';
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ALERTA - ATENCAO'      || ';' || 
                                                        vr_base_log   || ';' ||
                                                        'A matricula pertence a um UNICO COOPERADO. Validar situacao. Pulando registro sem alteracoes no Aimaro.' );
          
          CLOSE cr_valida_mat_duplicada;
          
          CONTINUE;
          
        END IF;
        
        IF cr_valida_mat_duplicada%ISOPEN THEN
          CLOSE cr_valida_mat_duplicada;
        END IF;
        
      END IF;
      
    ELSE
      
      vr_comments := ' ### Removida a tratativa para titulares ADICIONAIS da conta, pois todos neste grupo também são titulares principais de alguma conta.';
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ALERTA'      || ';' || 
                                                    vr_base_log   || ';' ||
                                                    'Titular adicional identificado no Loop Principal.' );
      
      CONTINUE;
      
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
