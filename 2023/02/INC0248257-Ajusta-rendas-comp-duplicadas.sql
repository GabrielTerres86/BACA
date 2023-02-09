DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0248257_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0248257_script_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'INC0248257_relatorio_exec.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  vr_cdcooper           CECRED.crapass.CDCOOPER%TYPE;
  vr_nrdconta           CECRED.crapass.NRDCONTA%TYPE;
  vr_nrcpfcgc           CECRED.crapass.NRCPFCGC%TYPE;
  vr_dtnasttl_new       CECRED.crapttl.DTNASTTL%TYPE;
  vr_dtnasttl_atu       CECRED.crapttl.DTNASTTL%TYPE;
  vr_dtmvtolt           DATE;
  vr_lgrowid            ROWID;
  vr_msgalt             VARCHAR2(150);
  
  CURSOR cr_dados IS 
    select rc.idpessoa
      , count(*)
    from tbcadast_pessoa_rendacompl rc
    where rc.tprenda = 6

    group by rc.idpessoa
    having count(*) > 1;
  
  rg_dados  cr_dados%ROWTYPE;
  
  CURSOR cr_excluir (pr_idpessoa IN NUMBER) IS
    SELECT p.nrcpfcgc
      , rc.*
    FROM tbcadast_pessoa_rendacompl rc
    JOIN tbcadast_pessoa p ON rc.idpessoa = p.idpessoa
    WHERE rc.idpessoa = pr_idpessoa
      AND rc.tprenda = 6
      AND rc.nrseq_renda <> ( SELECT MAX(rc2.nrseq_renda)
                              FROM tbcadast_pessoa_rendacompl rc2 
                              WHERE rc2.idpessoa = rc.idpessoa
                                AND rc2.tprenda  = rc.tprenda );
  
  rg_excluir     cr_excluir%ROWTYPE;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0248257';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
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
  
  OPEN cr_dados;
  LOOP
    FETCH cr_dados INTO rg_dados;
    EXIT WHEN cr_dados%NOTFOUND;
    
    OPEN cr_excluir(rg_dados.idpessoa);
    LOOP
      FETCH cr_excluir INTO rg_excluir;
      EXIT WHEN cr_excluir%NOTFOUND;
      
      BEGIN
        
        DELETE CECRED.Tbcadast_Pessoa_Rendacompl
        WHERE idpessoa    = rg_excluir.idpessoa
          AND nrseq_renda = rg_excluir.nrseq_renda
          AND tprenda     = rg_excluir.tprenda;
        
        IF SQL%ROWCOUNT = 1 THEN
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    INSERT INTO CECRED.Tbcadast_Pessoa_Rendacompl '
                                                        || '   ( idpessoa, 
                                                                  nrseq_renda, 
                                                                  tprenda, 
                                                                  vlrenda, 
                                                                  tpfixo_variavel, 
                                                                  cdoperad_altera, 
                                                                  nrdconta, 
                                                                  cdcooper )
                                                             VALUES (
                                                                 ' || rg_excluir.idpessoa || ', 
                                                                 ' || rg_excluir.nrseq_renda || ', 
                                                                 ' || rg_excluir.tprenda || ', 
                                                                 ' || NVL( TO_CHAR( replace(rg_excluir.vlrenda, ',', '.') ), '0' ) || ', 
                                                                 ' || NVL( TO_CHAR( rg_excluir.tpfixo_variavel ), 'NULL') || ', 
                                                                 ''' || rg_excluir.cdoperad_altera || ''', 
                                                                 ' || NVL( TO_CHAR( rg_excluir.nrdconta ), 'NULL') || ', 
                                                                 ' || NVL( TO_CHAR( rg_excluir.cdcooper ), 'NULL') || '
                                                             );' );
        ELSE
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, rg_excluir.nrcpfcgc 
                                                      || ';' || rg_excluir.idpessoa
                                                      || ';ERRO' 
                                                      || ';Quantidade de linhas excluidas diferente de 1 ' || SQL%ROWCOUNT );
          
        END IF;
        
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao deletar registro: ' || SQLERRM;
          RAISE vr_exception;
      END;
      
    END LOOP;
    
    CLOSE cr_excluir;
    
  END LOOP;
  
  CLOSE cr_dados;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION 
  
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
END;
