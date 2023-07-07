DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0279576_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0279576_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0279576_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_cdcooper           CECRED.crapass.CDCOOPER%TYPE;
  vr_nrdconta           CECRED.crapass.NRDCONTA%TYPE;
  vr_dsnatjur           VARCHAR2(255);
  vr_cdnatjur           CECRED.crapjur.NATJURID%TYPE;
  vr_dtmvtolt           CECRED.crapalt.DTALTERA%TYPE;
  vr_comments           VARCHAR2(2000);
  vr_msgalt             VARCHAR2(1000);
  vr_hrtransa           CECRED.craplgm.HRTRANSA%TYPE;
  vr_nrdrowid           ROWID;
  vr_seq_enc            NUMBER(3);
  vr_dsmodule           VARCHAR2(100);
  
  CURSOR cr_conta IS 
    SELECT e.cdcooper
      , e.nrdconta
    FROM crapenc e
    WHERE e.progress_recid = 4704090;
  
  CURSOR cr_max_seqenc(pr_cooper  IN CECRED.crapass.CDCOOPER%TYPE
                     , pr_conta   IN CECRED.crapass.NRDCONTA%TYPE ) IS
    SELECT ( max(e.cdseqinc) + 1 ) cdseqinc
    from CECRED.crapenc e
    WHERE e.NRDCONTA in pr_conta
        AND E.CDCOOPER = pr_cooper;
  
  CURSOR cr_endereco(pr_coop  IN CECRED.crapass.CDCOOPER%TYPE
                   , pr_cont  IN CECRED.crapass.NRDCONTA%TYPE ) IS 
    SELECT 1 ordem_exec
      , ROWID   rowid_update
      , e.*
    FROM CRAPENC E
    WHERE E.NRDCONTA in pr_cont
      AND E.CDCOOPER = pr_coop
      AND e.tpendass <> 9
    UNION ALL 
    SELECT 2 ordem
      , ROWID   rowid_update
      , e.*
    FROM CRAPENC E
    WHERE E.NRDCONTA in pr_cont
      AND E.CDCOOPER = pr_coop
      AND e.tpendass = 9
    ORDER BY 1;
    
  rg_endereco            cr_endereco%ROWTYPE;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0279576';
  
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
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'DECLARE vr_dsmodule VARCHAR2(100); BEGIN CADA0016.pc_sessao_trigger( pr_tpmodule => 1, pr_dsmodule => vr_dsmodule); ');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  OPEN cr_conta;
  FETCH cr_conta INTO vr_cdcooper, vr_nrdconta;
  CLOSE cr_conta;
  
  OPEN cr_max_seqenc(vr_cdcooper, vr_nrdconta);
  FETCH cr_max_seqenc INTO vr_seq_enc;
  CLOSE cr_max_seqenc;
  
  OPEN cr_endereco(vr_cdcooper, vr_nrdconta);
  LOOP
    FETCH cr_endereco INTO rg_endereco;
    EXIT WHEN cr_endereco%NOTFOUND;
    
    CADA0016.pc_sessao_trigger( pr_tpmodule => 1,
                                pr_dsmodule => vr_dsmodule);
    
    IF rg_endereco.tpendass <> 9 THEN
      
      BEGIN
        
        UPDATE CECRED.crapenc 
          SET cdseqinc = vr_seq_enc
        WHERE ROWID = rg_endereco.rowid_update;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'OK - Alterado sequencial de: (' || rg_endereco.cdseqinc || ') - Para: (' || vr_seq_enc || ')' || chr(10)
                                                      || rg_endereco.cdcooper || ' - ' 
                                                      || rg_endereco.nrdconta || ' - '
                                                      || rg_endereco.tpendass );
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  UPDATE CECRED.crapenc SET cdseqinc = ' || rg_endereco.cdseqinc || ' WHERE ROWID = ''' || rg_endereco.rowid_update || '''; ' );
        
        vr_seq_enc := (vr_seq_enc + 1);
        
      EXCEPTION
        WHEN OTHERS THEN
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NÃO TRATADO Outros Tipos: ' || SQLERRM || CHR(10) 
                                                    || rg_endereco.cdcooper || ' - ' 
                                                    || rg_endereco.nrdconta || ' - '
                                                    || rg_endereco.tpendass || ' - '
                                                    || rg_endereco.cdseqinc || ' - ' );
          
      END;
      
    ELSIF rg_endereco.tpendass = 9 THEN
      
      BEGIN
        
        UPDATE CECRED.crapenc 
          SET cdseqinc = 1
        WHERE ROWID = rg_endereco.rowid_update;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'OK - Alterado sequencial de: (' || rg_endereco.cdseqinc || ') - Para: (1)' || chr(10)
                                                      || rg_endereco.cdcooper || ' - ' 
                                                      || rg_endereco.nrdconta || ' - '
                                                      || rg_endereco.tpendass );
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  UPDATE CECRED.crapenc SET cdseqinc = ' || rg_endereco.cdseqinc || ' WHERE ROWID = ''' || rg_endereco.rowid_update || '''; ' );
        
      EXCEPTION
        WHEN OTHERS THEN
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NÃO TRATADO Tipo Comercial (9): ' || SQLERRM || CHR(10) 
                                                    || rg_endereco.cdcooper || ' - ' 
                                                    || rg_endereco.nrdconta || ' - '
                                                    || rg_endereco.tpendass || ' - '
                                                    || rg_endereco.cdseqinc || ' - ' );
          
      END;
      
    ELSE 
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Fluxo inesperado: ' 
                                                    || rg_endereco.cdcooper || ' - ' 
                                                    || rg_endereco.nrdconta || ' - '
                                                    || rg_endereco.tpendass || ' - '
                                                    || rg_endereco.cdseqinc || ' - ' );
      
    END IF;
    
    CADA0016.pc_sessao_trigger( pr_tpmodule => 2,
                                pr_dsmodule => vr_dsmodule); 
    
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  CADA0016.pc_sessao_trigger( pr_tpmodule => 2, pr_dsmodule => vr_dsmodule); ');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  COMMIT; ');
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
