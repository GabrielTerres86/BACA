DECLARE 
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0291294_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0291294_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0291294_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);

  CURSOR cr_crapcop IS
    SELECT cdcooper
    FROM cecred.crapcop c
    WHERE c.flgativo = 1;
  
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_nextval IS
    SELECT (MAX(t.tpregist) + 1) tpregist
    FROM cecred.craptab t
    WHERE nmsistem = 'CRED'      
      AND tptabela = 'GENERI'    
      AND cdempres = 0
      AND cdacesso = 'DIGITALIZA';
      
  CURSOR cr_validainclusao (pr_tpregist   IN cecred.craptab.tpregist%TYPE) IS
    SELECT *
    FROM cecred.craptab t
    WHERE nmsistem = 'CRED'
      AND tptabela = 'GENERI'
      AND cdempres = 0
      AND cdacesso = 'DIGITALIZA'
      AND tpregist = pr_tpregist;
  
  rg_validainclusao  cr_validainclusao%ROWTYPE;
  
  CURSOR cr_exists IS
    SELECT t.tpregist
    FROM cecred.craptab t
    WHERE nmsistem = 'CRED'      
      AND tptabela = 'GENERI'    
      AND cdempres = 0
      AND cdacesso = 'DIGITALIZA'
      AND upper(t.dstextab) like '%;301%';
      
  rg_exists    cr_exists%ROWTYPE;
  
  vr_tpregist  cecred.craptab.tpregist%TYPE;
  vr_rowid     ROWID;
  
  vr_dscritic  VARCHAR2(2000);
  vr_exception EXCEPTION; 

BEGIN
  
  OPEN cr_exists;
  FETCH cr_exists INTO rg_exists;
  
  IF cr_exists%NOTFOUND THEN
  
    vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0291294';
    
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
    
    OPEN cr_nextval;
    FETCH cr_nextval INTO vr_tpregist;
    CLOSE cr_nextval;
    
    vr_tpregist := NVL(vr_tpregist, 130);
    
    FOR rw_crapcop IN cr_crapcop LOOP
      
      BEGIN
        
        INSERT INTO CECRED.craptab (
          nmsistem
          ,tptabela
          ,cdempres
          ,cdacesso
          ,tpregist
          ,dstextab
          ,cdcooper
        ) VALUES(
          'CRED'
          ,'GENERI'
          ,0
          ,'DIGITALIZA'
          ,vr_tpregist
          ,'DOCUMENTOS RESPONSÁVEL LEGAL - ADMISSÃO;0,00;301;0,00'
          ,rw_crapcop.cdcooper
        ) RETURNING ROWID INTO vr_rowid;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  DELETE CECRED.craptab WHERE ROWID = ''' || vr_rowid || '''; ');
                
      EXCEPTION
        WHEN OTHERS THEN
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO AO INSERIR. tpregist | Cooper: ' || vr_tpregist || ' | ' || rw_crapcop.cdcooper || SQLERRM );
           
      END;
                
    END LOOP;
    
    COMMIT;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, CHR(10) || ' *** Valida inclusão dos parâmetros.');
    OPEN cr_validainclusao(vr_tpregist);
    
    LOOP
      FETCH cr_validainclusao INTO rg_validainclusao;
      EXIT WHEN cr_validainclusao%NOTFOUND;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,
        rg_validainclusao.nmsistem || ' ; ' || 
        rg_validainclusao.tptabela || ' ; ' || 
        rg_validainclusao.cdempres || ' ; ' || 
        rg_validainclusao.cdacesso || ' ; ' || 
        rg_validainclusao.tpregist || ' ; ' || 
        rg_validainclusao.dstextab || ' ; ' || 
        rg_validainclusao.cdcooper
      );
      
    END LOOP;
    
    CLOSE cr_validainclusao;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, chr(10) || 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
  END IF;
  
  CLOSE cr_exists;
  
  
EXCEPTION
  WHEN OTHERS THEN
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO AO EXECUTAR O script: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);

    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-2000, 'Erro não tratado: ' || SQLERRM);
    
END;
