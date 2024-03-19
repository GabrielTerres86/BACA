DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RISK0002025_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'RISK0002025_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'RISK0002025_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_nrcpf              CECRED.crapass.NRCPFCGC%TYPE;
  vr_nrcnpj             CECRED.crapass.NRCPFCGC%TYPE;
  
  vr_comments           VARCHAR2(2000);
  vr_ttlencontrado      BOOLEAN;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_dados IS 
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
      SELECT 70000000 INICIO, 73699999 FIM, 'DF' SIGLA, 71690845 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 73700000 INICIO, 76799999 FIM, 'GO' SIGLA, 74055050 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 76800000 INICIO, 76999999 FIM, 'RO' SIGLA, 76801084 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 77000000 INICIO, 77999999 FIM, 'TO' SIGLA, 77064540 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 78000000 INICIO, 78899999 FIM, 'MT' SIGLA, 78104970 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 78900000 INICIO, 78999999 FIM, 'RO' SIGLA, 76801084 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 79000000 INICIO, 79999999 FIM, 'MS' SIGLA, 79002363 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 80000000 INICIO, 87999999 FIM, 'PR' SIGLA, 80020330 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 88000000 INICIO, 89999999 FIM, 'SC' SIGLA, 89010008 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 90000000 INICIO, 99999999 FIM, 'RS' SIGLA, 90010284 CEP_VALIDO_CAPITAL FROM DUAL
    ), CEP_ESTADO AS (
      SELECT D.NRCEPLOG
        , D.CDUFLOGR
        , COUNT(*)      TOTAL_ENDERECOS_CEP
      FROM CRAPDNE D
      JOIN FAIXA_CEP_ESTADO E ON D.NRCEPLOG BETWEEN E.INICIO AND E.FIM
                                 AND D.CDUFLOGR = E.SIGLA
      GROUP BY D.NRCEPLOG
        , D.CDUFLOGR
    )
    SELECT E.ROWID                               ROWID_ENDERECO
      , P.NRCPFCGC
      , P.TPPESSOA
      , P.TPCADASTRO
      , E.TPENDERECO 
      , M.DSCIDADE
      , M.CDESTADO                               UF_CADASTRO
      , DR.SIGLA                                 UF_CORRETA_CEP
      , E.NRCEP
      , DR2.CEP_VALIDO_CAPITAL                   CEP_APLICAR_CORRECAO
      , DR1.CDUFLOGR                             UF_CADDNE
      , DR1.NRCEPLOG                             CEP_CRAPDNE
    FROM TBCADAST_PESSOA_ENDERECO E
    JOIN TBCADAST_PESSOA          P   ON E.IDPESSOA = P.IDPESSOA
    LEFT JOIN CRAPMUN             M   ON E.IDCIDADE = M.IDCIDADE
    LEFT JOIN CEP_ESTADO          DR1 ON E.NRCEP  = DR1.NRCEPLOG
    LEFT JOIN FAIXA_CEP_ESTADO    DR  ON E.NRCEP BETWEEN INICIO AND FIM
    LEFT JOIN FAIXA_CEP_ESTADO    DR2 ON M.CDESTADO = DR2.SIGLA
    WHERE DR2.CEP_VALIDO_CAPITAL > 0
      AND NVL( TRIM(M.CDESTADO), NVL(DR.SIGLA, 'Y') ) <> NVL(DR.SIGLA, 'X')
      AND TRIM(M.CDESTADO) IS NOT NULL;
  
  rg_dados              cr_dados%ROWTYPE;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RISK0002025';
  
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
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'STATUS;CPF;TIPO ENDERECO;CIDADE;UF;CEP CADASTRO;CEP CORRIGIDO');
  
  OPEN cr_dados;
  LOOP
    FETCH cr_dados INTO rg_dados;
    EXIT WHEN cr_dados%NOTFOUND;
      
    BEGIN
      
      UPDATE CECRED.TBCADAST_PESSOA_ENDERECO E
        SET E.NRCEP = rg_dados.CEP_APLICAR_CORRECAO
      WHERE ROWID = rg_dados.ROWID_ENDERECO;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'SUCESSO'                || ';' || 
                                                    rg_dados.NRCPFCGC        || ';' || 
                                                    rg_dados.TPENDERECO      || ';' || 
                                                    rg_dados.DSCIDADE        || ';' || 
                                                    rg_dados.UF_CADASTRO     || ';' || 
                                                    rg_dados.NRCEP           || ';' || 
                                                    rg_dados.CEP_APLICAR_CORRECAO || ';' );
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,
        '  UPDATE CECRED.TBCADAST_PESSOA_ENDERECO E SET E.NRCEP = ' || NVL(TO_CHAR(rg_dados.NRCEP), 'NULL') || ' WHERE ROWID = ''' || rg_dados.ROWID_ENDERECO || ''';'
      );
      
      vr_count := vr_count + 1;
      
    EXCEPTION 
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO   '                || ';' || 
                                                      rg_dados.NRCPFCGC        || ';' || 
                                                      rg_dados.TPENDERECO      || ';' || 
                                                      rg_dados.DSCIDADE        || ';' || 
                                                      rg_dados.UF_CADASTRO     || ';' || 
                                                      rg_dados.NRCEP           || ';' || 
                                                      rg_dados.CEP_APLICAR_CORRECAO || ';' ||
                                                      'Erro ao atualizar CEP: ' || SQLERRM );
        
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
