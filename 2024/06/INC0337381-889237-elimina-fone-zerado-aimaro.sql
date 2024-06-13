DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0337381_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0337381_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0337381_relatorio_exec.txt';
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
  
  CURSOR cr_dados IS
    SELECT T.NRCPFCGC
      , F.*
    FROM CRAPTFC F
    JOIN CRAPTTL T ON F.CDCOOPER = T.CDCOOPER
                      AND F.NRDCONTA = T.NRDCONTA
                      AND F.IDSEQTTL = T.IDSEQTTL
    WHERE F.NRTELEFO = 0;
  
  rg_dados              cr_dados%ROWTYPE;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  vr_dscritic_mat       VARCHAR2(4000);
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0337381';
  
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
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Inicio: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  vr_comments := ' ## Cabeçalho do log de execução.';
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'STATUS;CPF;DDD;TELEFONE;SEQ. FONE;DS LOG');
  
  OPEN cr_dados;
  LOOP
    FETCH cr_dados INTO rg_dados;
    EXIT WHEN cr_dados%NOTFOUND;
    
    vr_base_log := rg_dados.NRCPFCGC || ';' ||
                   rg_dados.NRDDDTFC || ';' ||
                   rg_dados.NRTELEFO || ';' ||
                   rg_dados.CDSEQTFC || ';';
    
    BEGIN
      
      DELETE CECRED.CRAPTFC 
      WHERE PROGRESS_RECID = rg_dados.PROGRESS_RECID;
      
      vr_qtd_regs_upd := SQL%ROWCOUNT;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,
        '  INSERT INTO CECRED.CRAPTFC (' || 
          '  cdcooper, ' || 
          '  nrdconta, ' || 
          '  idseqttl, ' || 
          '  cdseqtfc, ' || 
          '  cdopetfn, ' || 
          '  nrdddtfc, ' || 
          '  tptelefo, ' || 
          '  nmpescto, ' || 
          '  prgqfalt, ' || 
          '  nrtelefo, ' || 
          '  nrdramal, ' || 
          '  secpscto, ' || 
          '  progress_recid, ' || 
          '  idsittfc, ' || 
          '  idorigem, ' || 
          '  flgacsms, ' || 
          '  dtinsori, ' || 
          '  dtrefatu, ' || 
          '  inprincipal, ' || 
          '  inwhatsapp ' || 
        ' ) VALUES ( ' ||
          rg_dados.cdcooper || ', ' ||
          rg_dados.nrdconta || ', ' ||
          rg_dados.idseqttl || ', ' ||
          rg_dados.cdseqtfc || ', ' ||
          NVL( TRIM(TO_CHAR(rg_dados.cdopetfn) ), 'NULL' ) || ', ' ||
          NVL( TRIM(TO_CHAR(rg_dados.nrdddtfc) ), 'NULL' ) || ', ' ||
          NVL( TRIM(TO_CHAR(rg_dados.tptelefo) ), 'NULL' ) || ', ' ||
          ' ''' || rg_dados.nmpescto || ''', ' ||
          ' ''' || rg_dados.prgqfalt || ''', ' ||
          REPLACE(rg_dados.nrtelefo, ',', '.') || ', ' ||
          NVL( TRIM(TO_CHAR(rg_dados.nrdramal) ), 'NULL' ) || ', ' ||
          ' ''' || rg_dados.secpscto || ''', ' ||
          rg_dados.progress_recid || ', ' ||
          NVL( TRIM(TO_CHAR(rg_dados.idsittfc) ), 'NULL' ) || ', ' ||
          NVL( TRIM(TO_CHAR(rg_dados.idorigem) ), 'NULL' ) || ', ' ||
          NVL( TRIM(TO_CHAR(rg_dados.flgacsms) ), 'NULL' ) || ', ' ||
          'TO_DATE(''' || TO_CHAR(rg_dados.dtinsori, 'DD/MM/RRRR HH24:MI:SS') || ''', ''DD/MM/RRRR HH24:MI:SS''), ' ||
          'TO_DATE(''' || TO_CHAR(rg_dados.dtrefatu, 'DD/MM/RRRR HH24:MI:SS') || ''', ''DD/MM/RRRR HH24:MI:SS''), ' ||
          NVL( TRIM(TO_CHAR(rg_dados.inprincipal) ), 'NULL' ) || ', ' ||
          NVL( TRIM(TO_CHAR(rg_dados.inwhatsapp ) ), 'NULL' ) || 
        ' ) ;'
      );
      
      IF vr_qtd_regs_upd = 1 THEN
        vr_comments := ' ## SUCESSO DEL ';
          
      ELSE 
        vr_comments := ' ## ALERTA DEL ';
          
      END IF;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_comments  || ';' || 
                                                    vr_base_log  || ';' ||
                                                    'Qtd registros afetados DELETE: ' || vr_qtd_regs_upd || 
                                                    '. Exclusao do registro de telefone.');
      
      vr_count := vr_count + 1;
      
    EXCEPTION
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO'        || ';' || 
                                                      vr_base_log   || ';' ||
                                                      'Erro ao deletar o registro de telefone zerado.');
        
    END;
    
    IF vr_count >= 500 THEN
      
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
