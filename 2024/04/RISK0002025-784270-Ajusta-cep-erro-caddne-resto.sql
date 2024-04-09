DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(60) := 'RISK0002025_registros_corrigir_individualmente.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(60) := 'RISK0002025_corrige_resto_crapdne_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(60) := 'RISK0002025_corrige_resto_crapdne_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  vr_base_log           VARCHAR2(3000);
  
  
  vr_progress_recid     CECRED.CRAPDNE.PROGRESS_RECID%TYPE;
  vr_nrcep              CECRED.CRAPDNE.NRCEPLOG%TYPE;
  vr_nome_cidade        CECRED.CRAPDNE.NMEXTCID%TYPE;
  vr_uf                 CECRED.CRAPDNE.CDUFLOGR%TYPE;
  
  vr_comments           VARCHAR2(2000);
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_valida_correcao ( pr_cep_corrigir IN NUMBER
                            , pr_uf_corrigir  IN VARCHAR2 ) IS
    WITH FAIXA_CEP_ESTADO AS (
      SELECT 01000000 INICIO, 19999999 FIM, 'SP' SIGLA, 01031000 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 20000000 INICIO, 28999999 FIM, 'RJ' SIGLA, 20230010 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 29000000 INICIO, 29999999 FIM, 'ES' SIGLA, 29010410 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 30000000 INICIO, 39999999 FIM, 'MG' SIGLA, 30180000 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 40000000 INICIO, 48999999 FIM, 'BA' SIGLA, 40020210 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 49000000 INICIO, 49999999 FIM, 'SE' SIGLA, 49010020 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 50000000 INICIO, 56999999 FIM, 'PE' SIGLA, 50090700 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 57000000 INICIO, 57999999 FIM, 'AL' SIGLA, 57020070 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 58000000 INICIO, 58999999 FIM, 'PB' SIGLA, 58013010 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 59000000 INICIO, 59999999 FIM, 'RN' SIGLA, 59114200 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 60000000 INICIO, 63999999 FIM, 'CE' SIGLA, 60035000 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 64000000 INICIO, 64999999 FIM, 'PI' SIGLA, 64000160 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 65000000 INICIO, 65999999 FIM, 'MA' SIGLA, 65010904 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 66000000 INICIO, 68899999 FIM, 'PA' SIGLA, 66823215 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 68900000 INICIO, 68999999 FIM, 'AP' SIGLA, 68900013 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69000000 INICIO, 69299999 FIM, 'AM' SIGLA, 69020030 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69300000 INICIO, 69399999 FIM, 'RR' SIGLA, 69301380 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69400000 INICIO, 69899999 FIM, 'AM' SIGLA, 69020030 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69900000 INICIO, 69999999 FIM, 'AC' SIGLA, 69908500 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 70000000 INICIO, 72799999 FIM, 'DF' SIGLA, 71690845 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 72800000 INICIO, 72999999 FIM, 'GO' SIGLA, 72856728 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 73000000 INICIO, 73699999 FIM, 'DF' SIGLA, 71690845 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 73700000 INICIO, 76799999 FIM, 'GO' SIGLA, 74055050 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 76800000 INICIO, 76999999 FIM, 'RO' SIGLA, 76801084 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 77000000 INICIO, 77999999 FIM, 'TO' SIGLA, 77064540 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 78000000 INICIO, 78899999 FIM, 'MT' SIGLA, 78104970 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 79000000 INICIO, 79999999 FIM, 'MS' SIGLA, 79002363 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 80000000 INICIO, 87999999 FIM, 'PR' SIGLA, 80020330 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 88000000 INICIO, 89999999 FIM, 'SC' SIGLA, 89010008 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 90000000 INICIO, 99999999 FIM, 'RS' SIGLA, 90010284 CEP_VALIDO_CAPITAL FROM DUAL 
    )
    SELECT 1 
    FROM FAIXA_CEP_ESTADO V
    WHERE pr_cep_corrigir BETWEEN V.INICIO AND V.FIM
      AND pr_uf_corrigir = V.SIGLA;
      
  rg_valida_correcao cr_valida_correcao%ROWTYPE;
  
  CURSOR cr_cria_rbk_delete IS 
    SELECT *
    FROM CECRED.CRAPDNE D
    WHERE D.PROGRESS_RECID IN (
      5,
      6,
      133692,
      10230920,
      10230921,
      10230941,
      10230968,
      10230979);
  
  rg_cria_rbk  cr_cria_rbk_delete%ROWTYPE;
  
  CURSOR cr_crapdne (pr_progres_recid  IN CECRED.CRAPDNE.PROGRESS_RECID%TYPE) IS
    SELECT *
    FROM CECRED.CRAPDNE DNE
    WHERE DNE.PROGRESS_RECID = pr_progres_recid;
    
  rg_crapdne  cr_crapdne%ROWTYPE;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RISK0002025';
  
  vr_count_file := 0;
  vr_seq_file   := 1;
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarquiv
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_input_file
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
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
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'PROGRESS ID CORRIGIR;CEP CAD;UF CAD;CIDADE CAD - EXT e RES;UF CORRETA;CEP CORRETO;NOME CIDADE CORRETO;STATUS;DETALHES;');
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  
  vr_comments := 'Cria o Rollback antes de DELETAR os registros inválidos.';
  OPEN cr_cria_rbk_delete;
  LOOP
    FETCH cr_cria_rbk_delete INTO rg_cria_rbk;
    EXIT WHEN cr_cria_rbk_delete%NOTFOUND;
    
    vr_comments := 'Gera ROLLBACK com os dados de produção.';
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  INSERT INTO CECRED.CRAPDNE (' 
                                                    || 'nrceplog, nmextlog, nmreslog, dscmplog, dstiplog, nmextbai, nmresbai, nmextcid, nmrescid, cduflogr, idoricad, idtipdne, progress_recid, cdcidibge '
                                                    || ' ) VALUES ( '
                                                    || rg_cria_rbk.nrceplog
                                                    || ', ' || CASE WHEN rg_cria_rbk.nmextlog IS NOT NULL THEN ' ''' || rg_cria_rbk.nmextlog || ''' ' ELSE 'NULL' END
                                                    || ', ' || CASE WHEN rg_cria_rbk.nmreslog IS NOT NULL THEN ' ''' || rg_cria_rbk.nmreslog || ''' ' ELSE 'NULL' END
                                                    || ', ' || CASE WHEN rg_cria_rbk.dscmplog IS NOT NULL THEN ' ''' || rg_cria_rbk.dscmplog || ''' ' ELSE 'NULL' END
                                                    || ', ' || CASE WHEN rg_cria_rbk.dstiplog IS NOT NULL THEN ' ''' || rg_cria_rbk.dstiplog || ''' ' ELSE 'NULL' END
                                                    || ', ' || CASE WHEN rg_cria_rbk.nmextbai IS NOT NULL THEN ' ''' || rg_cria_rbk.nmextbai || ''' ' ELSE 'NULL' END
                                                    || ', ' || CASE WHEN rg_cria_rbk.nmresbai IS NOT NULL THEN ' ''' || rg_cria_rbk.nmresbai || ''' ' ELSE 'NULL' END
                                                    || ', ' || CASE WHEN rg_cria_rbk.nmextcid IS NOT NULL THEN ' ''' || rg_cria_rbk.nmextcid || ''' ' ELSE 'NULL' END
                                                    || ', ' || CASE WHEN rg_cria_rbk.nmrescid IS NOT NULL THEN ' ''' || rg_cria_rbk.nmrescid || ''' ' ELSE 'NULL' END
                                                    || ', ' || CASE WHEN rg_cria_rbk.cduflogr IS NOT NULL THEN ' ''' || rg_cria_rbk.cduflogr || ''' ' ELSE 'NULL' END
                                                    || ', ' || NVL(TO_CHAR(rg_cria_rbk.idoricad), 'NULL')
                                                    || ', ' || NVL(TO_CHAR(rg_cria_rbk.idtipdne), 'NULL')
                                                    || ', ' || NVL(TO_CHAR(rg_cria_rbk.progress_recid), 'NULL')
                                                    || ', ' || NVL(TO_CHAR(rg_cria_rbk.cdcidibge), 'NULL')
                                                    || '); ');
                                                         
    BEGIN
      
      vr_comments := 'Exclusão de registros completamente inválidos.';
      DELETE CECRED.CRAPDNE WHERE PROGRESS_RECID = rg_cria_rbk.progress_recid;
      
    EXCEPTION WHEN OTHERS THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO;Erro nao tratado ao DELETAR registros invalidos na caddne.: ' || SQLERRM);
      
    END;
    
  END LOOP;
    
  CLOSE cr_cria_rbk_delete;
  
  LOOP
    
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                ,pr_des_text => vr_setlinha);
    
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    
    vr_comments := 'PROGRESS_RECID ; CEP ; NOME CIDADE ; UF';
    
    vr_progress_recid := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1, vr_setlinha, ';') ) );
    vr_nrcep          := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2, vr_setlinha, ';') ) );
    vr_nome_cidade    := UPPER( TRIM( gene0002.fn_busca_entrada(3, vr_setlinha, ';') ) );
    vr_uf             := UPPER( TRIM( gene0002.fn_busca_entrada(4, vr_setlinha, ';') ) );
    
    IF NVL(vr_progress_recid, 0) > 0 THEN
      
      OPEN cr_crapdne(vr_progress_recid);
      FETCH cr_crapdne INTO rg_crapdne;
      CLOSE cr_crapdne;
      
      vr_base_log := rg_crapdne.PROGRESS_RECID                           || ';' ||
                     rg_crapdne.NRCEPLOG                                 || ';' ||
                     rg_crapdne.CDUFLOGR                                 || ';' ||
                     rg_crapdne.NMEXTCID || ' (' || rg_crapdne.NMRESCID  || ');' ||
                     vr_uf                                               || ';' ||
                     vr_nrcep                                            || ';' ||
                     vr_nome_cidade                                      || ';';
      
      vr_comments := 'Validando se a combinação é coerente e mantem a integridade entre UF e Faixa do CEP.';
      OPEN cr_valida_correcao(vr_nrcep, vr_uf);
      FETCH cr_valida_correcao INTO rg_valida_correcao;
      
      IF cr_valida_correcao%NOTFOUND THEN
        
        vr_comments := 'A correcao individual nao deu certo, o cadastro precisara ser revisado novamente.';
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ALERTA - Aplic. Correcao Indiv.;' || vr_comments);
        CLOSE cr_valida_correcao;
        
        CONTINUE;
        
      END IF;
      
      CLOSE cr_valida_correcao;
      
      BEGIN
        
        UPDATE CECRED.CRAPDNE D
          SET D.NRCEPLOG = vr_nrcep
            , D.NMEXTCID = vr_nome_cidade
            , D.NMRESCID = SUBSTR(vr_nome_cidade, 1, 25)
            , D.CDUFLOGR = vr_uf
        WHERE D.PROGRESS_RECID = vr_progress_recid;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  UPDATE CECRED.CRAPDNE ' 
                                                      || ' SET NRCEPLOG = ' || rg_crapdne.NRCEPLOG
                                                      || ' , CDUFLOGR = '''   || rg_crapdne.CDUFLOGR || ''' '
                                                      || ' , NMRESCID = '''   || rg_crapdne.NMRESCID || ''' '
                                                      || ' , NMEXTCID = '''   || rg_crapdne.NMEXTCID || ''' ' ||
                                                      '  WHERE PROGRESS_RECID = ' || rg_crapdne.PROGRESS_RECID || '; ');
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'SUCESSO;Registro corrigido com sucesso.');
        
      EXCEPTION
        WHEN OTHERS THEN
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ERRO;Erro nao tratado ao corrigir CEP na caddne.: ' || SQLERRM);
          
      END;
      
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
