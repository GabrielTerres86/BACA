DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0352984_na.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0352984_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0352984_relat_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  vr_base_log           VARCHAR2(3000);
  
  vr_nrseq_email        NUMBER;
  vr_nrseq_email_ctr    NUMBER;
  
  vr_comments           VARCHAR2(2000);
  vr_ttlencontrado      BOOLEAN;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_dados IS 
    SELECT E.* 
      , T.NRCPFCGC
      , P.IDPESSOA
    FROM CECRED.CRAPCEM E
    JOIN CECRED.CRAPTTL T ON E.CDCOOPER = T.CDCOOPER
                      AND E.NRDCONTA = T.NRDCONTA
                      AND E.IDSEQTTL = T.IDSEQTTL
    JOIN CECRED.TBCADAST_PESSOA P ON T.NRCPFCGC = P.NRCPFCGC
    WHERE LOWER( TRIM(E.DSDEMAIL) ) LIKE '%@fourbank.com.br';
  
  TYPE TP_DADOS IS TABLE OF cr_dados%ROWTYPE;
  vt_dados   TP_DADOS;
  
  CURSOR cr_dados_ctr IS 
    SELECT E.* 
      , P.NRCPFCGC
    FROM CECRED.TBCADAST_PESSOA_EMAIL E
    JOIN CECRED.TBCADAST_PESSOA       P ON E.IDPESSOA = P.IDPESSOA
    WHERE LOWER( TRIM(E.DSEMAIL) ) LIKE '%@fourbank.com.br';
  
  TYPE TP_DADOS_CTR IS TABLE OF cr_dados_ctr%ROWTYPE;
  vt_dados_ctr   TP_DADOS_CTR;
  
  CURSOR cr_emails_ctr_integrar (pr_idpessoa  IN NUMBER) IS 
    SELECT EC.DTREVISAO
      , EC.IDPESSOA
      , EC.NRSEQ_EMAIL 
      , EC.DSEMAIL 
      , ( SELECT DISTINCT 1
          FROM CECRED.CRAPCEM EMA
          JOIN CECRED.CRAPTTL TTL ON EMA.CDCOOPER = TTL.CDCOOPER
                                     AND EMA.NRDCONTA = TTL.NRDCONTA
                                     AND EMA.IDSEQTTL = TTL.IDSEQTTL
          WHERE UPPER( TRIM(EMA.DSDEMAIL) ) = UPPER( TRIM(EC.DSEMAIL) )
            AND TTL.NRCPFCGC = P.NRCPFCGC
        )                      EXISTE_EMAIL_AIMARO
      , ( SELECT MAX(EMA.CDDEMAIL) MAIOR_SEQ
          FROM CECRED.CRAPCEM EMA
          JOIN CECRED.CRAPTTL TTL ON EMA.CDCOOPER = TTL.CDCOOPER
                                     AND EMA.NRDCONTA = TTL.NRDCONTA
                                     AND EMA.IDSEQTTL = TTL.IDSEQTTL
          WHERE TTL.NRCPFCGC = P.NRCPFCGC
        )                      NRSEQ_AIMARO
    FROM CECRED.TBCADAST_PESSOA_EMAIL EC
    JOIN CECRED.TBCADAST_PESSOA       P  ON EC.IDPESSOA = P.IDPESSOA
    WHERE P.IDPESSOA = pr_idpessoa;
  
  rg_integrar  cr_emails_ctr_integrar%ROWTYPE;
  
  CURSOR cr_next_nrseq_aimaro (pr_nrcpfcgc IN NUMBER) IS
    SELECT ( MAX(EMA.CDDEMAIL) + 1 ) MAIOR_SEQ
    FROM CECRED.CRAPCEM EMA
    JOIN CECRED.CRAPTTL TTL ON EMA.CDCOOPER = TTL.CDCOOPER
                               AND EMA.NRDCONTA = TTL.NRDCONTA
                               AND EMA.IDSEQTTL = TTL.IDSEQTTL
    WHERE TTL.NRCPFCGC = pr_nrcpfcgc;
  
  CURSOR cr_next_nrseq_ctr (pr_nrcpfcgc IN NUMBER) IS
    SELECT ( MAX( EC.NRSEQ_EMAIL ) + 1 ) MAX_SEQ_CTR
    FROM CECRED.TBCADAST_PESSOA_EMAIL EC
    JOIN CECRED.TBCADAST_PESSOA       P  ON EC.IDPESSOA = P.IDPESSOA
    WHERE P.NRCPFCGC = pr_nrcpfcgc;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0352984';
  
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
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'CDCOOPER;NRDCONTA;IDSEQTTL;NRCPFCGC;PROGRESS_RECID;CDDEMAIL;DSDEMAIL;DETALHES');
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  
  vr_comments := ' ###### PARTE 01 do script - Elimina os e-mails inválidos da base do Aimaro - CRAPCEM. ######';
  
  OPEN cr_dados;
  FETCH cr_dados BULK COLLECT INTO vt_dados;
  CLOSE cr_dados;
  
  IF vt_dados.COUNT() > 0 THEN
    
    FOR i IN vt_dados.FIRST..vt_dados.LAST LOOP
      
      vr_base_log := vt_dados(i).CDCOOPER || ';' ||
                     vt_dados(i).NRDCONTA || ';' ||
                     vt_dados(i).IDSEQTTL || ';' ||
                     vt_dados(i).NRCPFCGC || ';' ||
                     vt_dados(i).PROGRESS_RECID || ';' ||
                     vt_dados(i).CDDEMAIL  || ';' ||
                     vt_dados(i).DSDEMAIL || ';';
      
      BEGIN
        
        DELETE CECRED.CRAPCEM C
        WHERE C.PROGRESS_RECID = vt_dados(i).PROGRESS_RECID;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  INSERT INTO CECRED.CRAPCEM (' 
                                                      || '  cdoperad '
                                                      || '  , nrdconta '
                                                      || '  , dsdemail '
                                                      || '  , cddemail '
                                                      || '  , dtmvtolt '
                                                      || '  , hrtransa '
                                                      || '  , cdcooper '
                                                      || '  , idseqttl '
                                                      || '  , prgqfalt '
                                                      || '  , nmpescto '
                                                      || '  , secpscto '
                                                      || '  , progress_recid '
                                                      || '  , dtinsori '
                                                      || '  , dtrefatu '
                                                      || '  , inprincipal '
                                                      || ' ) VALUES ('
                                                      || '  '''   || vt_dados(i).cdoperad || ''' '
                                                      || '  , '   || vt_dados(i).nrdconta
                                                      || '  , ''' || vt_dados(i).dsdemail || ''' '
                                                      || '  , '   || vt_dados(i).cddemail
                                                      || '  , TO_DATE(''' || TO_CHAR(vt_dados(i).dtmvtolt, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                                      || '  , '   || vt_dados(i).hrtransa
                                                      || '  , '   || vt_dados(i).cdcooper 
                                                      || '  , '   || vt_dados(i).idseqttl
                                                      || '  , ''' || vt_dados(i).prgqfalt || ''' '
                                                      || '  , ''' || vt_dados(i).nmpescto || ''' '
                                                      || '  , ''' || vt_dados(i).secpscto || ''' '
                                                      || '  , '   || vt_dados(i).progress_recid
                                                      || '  , TO_DATE(''' || TO_CHAR(vt_dados(i).dtinsori, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                                      || '  , TO_DATE(''' || TO_CHAR(vt_dados(i).dtrefatu, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                                      || '  , '   || vt_dados(i).inprincipal
                                                      || ' );');
        
        vr_count := vr_count + 1;
        
      EXCEPTION 
        WHEN OTHERS THEN
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ERRO;Erro nao tratado ao excluir email inválido AIMARO: ' || SQLERRM);
          
      END;
      
      IF vr_count >= 500 THEN
        
        COMMIT;
        
        vr_count := 0;
        
      END IF;
      
    END LOOP;
  
  END IF;
  
  vr_comments := ' ###### PARTE 02 do script - Elimina os e-mails inválidos da base do CENTRALIZADO - TBCADAST_PESSOA_EMAIL. ######';
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, '---------------');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'IDPESSOA;NRSEQ_EMAIL;NRCPFCGC;DSEMAIL;DETALHES');
  
  OPEN cr_dados_ctr;
  FETCH cr_dados_ctr BULK COLLECT INTO vt_dados_ctr;
  CLOSE cr_dados_ctr;
  
  IF vt_dados_ctr.COUNT() > 0 THEN
    
    FOR j IN vt_dados_ctr.FIRST..vt_dados_ctr.LAST LOOP
      
      vr_base_log := vt_dados_ctr(j).IDPESSOA    || ';' ||
                     vt_dados_ctr(j).NRSEQ_EMAIL || ';' ||
                     vt_dados_ctr(j).NRCPFCGC    || ';' ||
                     vt_dados_ctr(j).DSEMAIL     || ';';
      
      BEGIN
        
        DELETE CECRED.TBCADAST_PESSOA_EMAIL EML
        WHERE EML.IDPESSOA = vt_dados_ctr(j).IDPESSOA
          AND EML.NRSEQ_EMAIL = vt_dados_ctr(j).NRSEQ_EMAIL;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  INSERT INTO CECRED.TBCADAST_PESSOA_EMAIL (' 
                                                      || '  idpessoa  '
                                                      || '  , nrseq_email  '
                                                      || '  , dsemail  '
                                                      || '  , nmpessoa_contato   '
                                                      || '  , nmsetor_pessoa_contato   '
                                                      || '  , cdoperad_altera   '
                                                      || '  , idcanal   '
                                                      || '  , insituacao   '
                                                      || '  , dtrevisao   '
                                                      || '  , inprincipal   '
                                                      || '  , nrdconta   '
                                                      || '  , cdcooper   '
                                                      || ' ) VALUES ('
                                                      || '    '   || vt_dados_ctr(j).idpessoa
                                                      || '  , '   || vt_dados_ctr(j).nrseq_email
                                                      || '  , ''' || vt_dados_ctr(j).dsemail || ''' '
                                                      || '  , ''' || vt_dados_ctr(j).nmpessoa_contato || ''' '
                                                      || '  , ''' || vt_dados_ctr(j).nmsetor_pessoa_contato || ''' '
                                                      || '  , ''' || vt_dados_ctr(j).cdoperad_altera || ''' '
                                                      || '  , '   || NVL( TO_CHAR(vt_dados_ctr(j).idcanal), 'NULL' )
                                                      || '  , '   || NVL( TO_CHAR(vt_dados_ctr(j).insituacao), 'NULL' )
                                                      || '  , TO_DATE(''' || TO_CHAR(vt_dados_ctr(j).dtrevisao, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                                      || '  , '   ||  NVL( TO_CHAR(vt_dados_ctr(j).inprincipal), 'NULL' )
                                                      || '  , '   || NVL( TO_CHAR(vt_dados_ctr(j).nrdconta), 'NULL' )
                                                      || '  , '   || NVL( TO_CHAR(vt_dados_ctr(j).cdcooper), 'NULL' )
                                                      || ' );');
        
        vr_count := vr_count + 1;
        
      EXCEPTION 
        WHEN OTHERS THEN
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ERRO;Erro nao tratado ao excluir email inválido CENTRALIZADO: ' || SQLERRM);
          
      END;
      
      IF vr_count >= 500 THEN
        
        COMMIT;
        
        vr_count := 0;
        
      END IF;
      
    END LOOP;
  
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, '---------------');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'CDCOOPER;NRDCONTA;IDSEQTTL;NRCPFCGC;PROGRESS_RECID;CDDEMAIL;DSDEMAIL Aimaro;DSDEMAIL Ctr;NRSEQ_EMAIL;DTREVISAO;NRSEQ_AIMARO;EXISTE_EMAIL_AIMARO;DETALHES');
  
  vr_comments := ' ###### PARTE 03 do script - Aciona a integração do CENTRALIZADO para o AIMARO, para carregar nas contas os e-mails corretos dos cooperados afetados. ######';
  
  IF vt_dados.COUNT() > 0 THEN
    
    FOR xz IN vt_dados.FIRST..vt_dados.LAST LOOP
      
      vr_comments := ' *** Obrigatório fazer outro Loop para conseguir criar o Rollback para o update da TBCADAST_PESSOA_EMAIL.';
      
      OPEN cr_emails_ctr_integrar(vt_dados(xz).IDPESSOA);
      LOOP
        FETCH cr_emails_ctr_integrar INTO rg_integrar;
        EXIT WHEN cr_emails_ctr_integrar%NOTFOUND;
        
        vr_base_log := vt_dados(xz).CDCOOPER || ';' ||
                       vt_dados(xz).NRDCONTA || ';' ||
                       vt_dados(xz).IDSEQTTL || ';' ||
                       vt_dados(xz).NRCPFCGC || ';' ||
                       vt_dados(xz).PROGRESS_RECID || ';' ||
                       vt_dados(xz).CDDEMAIL || ';' ||
                       vt_dados(xz).DSDEMAIL || ';' ||
                       rg_integrar.DSEMAIL   || ';' ||
                       rg_integrar.NRSEQ_EMAIL || ';' ||
                       TO_CHAR(rg_integrar.DTREVISAO, 'DD/MM/RRRR') || ';' ||
                       rg_integrar.NRSEQ_AIMARO  || ';' ||
                       rg_integrar.EXISTE_EMAIL_AIMARO  || ';';
        
        vr_nrseq_email := rg_integrar.NRSEQ_EMAIL;
        IF rg_integrar.EXISTE_EMAIL_AIMARO IS NULL AND NVL(rg_integrar.NRSEQ_AIMARO, 0) > 0 THEN
          
          OPEN cr_next_nrseq_aimaro(vt_dados(xz).NRCPFCGC);
          FETCH cr_next_nrseq_aimaro INTO vr_nrseq_email;
          CLOSE cr_next_nrseq_aimaro;
          
          OPEN cr_next_nrseq_ctr(vt_dados(xz).NRCPFCGC);
          FETCH cr_next_nrseq_ctr INTO vr_nrseq_email_ctr;
          CLOSE cr_next_nrseq_ctr;
          
          vr_nrseq_email := GREATEST(vr_nrseq_email, vr_nrseq_email_ctr);
          
          IF NVL(vr_nrseq_email, 0) = 0 THEN
            vr_nrseq_email := rg_integrar.NRSEQ_EMAIL;
          END IF;
          
        END IF;
        
        BEGIN
          
          UPDATE CECRED.TBCADAST_PESSOA_EMAIL PEM
            SET PEM.DTREVISAO = TRUNC(SYSDATE)
              , PEM.NRSEQ_EMAIL = vr_nrseq_email
          WHERE PEM.IDPESSOA = rg_integrar.IDPESSOA
            AND PEM.NRSEQ_EMAIL = rg_integrar.NRSEQ_EMAIL;
          
           gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  UPDATE CECRED.TBCADAST_PESSOA_EMAIL '
                                                         || '   SET DTREVISAO = TO_DATE(''' || TO_CHAR(rg_integrar.DTREVISAO, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                                         || '   , NRSEQ_EMAIL = ' || rg_integrar.NRSEQ_EMAIL
                                                         || ' WHERE IDPESSOA = ' || rg_integrar.IDPESSOA 
                                                         || '   AND NRSEQ_EMAIL =  ' || vr_nrseq_email || '; ');
          
        EXCEPTION 
          WHEN OTHERS THEN
            
            gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ERRO;Erro nao tratado atualizar data de revisão do email no CENTRALIZADO - DTREVISAO: ' || SQLERRM);
            
        END;
        
        IF vr_count >= 500 THEN
          
          COMMIT;
          
          vr_count := 0;
          
        END IF;
        
      END LOOP;
      
      CLOSE cr_emails_ctr_integrar;
      
    END LOOP;
    
  END IF;
  
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
