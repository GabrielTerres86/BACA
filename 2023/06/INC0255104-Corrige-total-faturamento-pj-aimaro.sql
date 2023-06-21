DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0255104_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0255104_script_ROLLBACK';
  vr_nmarqlog           VARCHAR2(50) := 'INC0255104_relatorio_exec.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arquiv2        utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  CURSOR cr_crapjur IS
    select j.rowid          rowid_jur
      , j.nrdconta
      , j.cdcooper
      , j.vlfatano
      , sum(
          nvl(fa.vlrftbru##1, 0)
              + nvl(fa.vlrftbru##2, 0)
              + nvl(fa.vlrftbru##3, 0)
              + nvl(fa.vlrftbru##4, 0)
              + nvl(fa.vlrftbru##5, 0)
              + nvl(fa.vlrftbru##6, 0)
              + nvl(fa.vlrftbru##7, 0)
              + nvl(fa.vlrftbru##8, 0)
              + nvl(fa.vlrftbru##9, 0)
              + nvl(fa.vlrftbru##10, 0)
              + nvl(fa.vlrftbru##11, 0)
              + nvl(fa.vlrftbru##12, 0)
      ) somatorio
    from crapjur j
    join crapjfn fa on j.nrdconta = fa.nrdconta
                      AND J.CDCOOPER = Fa.CDCOOPER
    having sum(
          nvl(fa.vlrftbru##1, 0)
              + nvl(fa.vlrftbru##2, 0)
              + nvl(fa.vlrftbru##3, 0)
              + nvl(fa.vlrftbru##4, 0)
              + nvl(fa.vlrftbru##5, 0)
              + nvl(fa.vlrftbru##6, 0)
              + nvl(fa.vlrftbru##7, 0)
              + nvl(fa.vlrftbru##8, 0)
              + nvl(fa.vlrftbru##9, 0)
              + nvl(fa.vlrftbru##10, 0)
              + nvl(fa.vlrftbru##11, 0)
              + nvl(fa.vlrftbru##12, 0)
      ) <> j.vlfatano
    group by j.nrdconta
      , j.cdcooper
      , j.vlfatano
      , j.rowid
    ;
  
  rg_crapjur        cr_crapjur%ROWTYPE;
  
  vr_dsmodule       VARCHAR2(100);
  
  vr_dscritic       VARCHAR2(2000);
  vr_exception      EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0255104';
  
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
  
  OPEN cr_crapjur;
  LOOP
    FETCH cr_crapjur INTO rg_crapjur;
    EXIT WHEN cr_crapjur%NOTFOUND;
    
    BEGIN
      
      CADA0016.pc_sessao_trigger( pr_tpmodule => 1,
                                  pr_dsmodule => vr_dsmodule);
      
      UPDATE CECRED.crapjur
        SET vlfatano = rg_crapjur.somatorio
      WHERE ROWID = rg_crapjur.rowid_jur;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.crapjur SET vlfatano = ' || replace(rg_crapjur.vlfatano, ',', '.') || ' WHERE ROWID = ''' || rg_crapjur.rowid_jur || '''; ');
      
      
      CADA0016.pc_sessao_trigger( pr_tpmodule => 2,
                                  pr_dsmodule => vr_dsmodule); 
      
    EXCEPTION
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO ao atualizar somatório do faturamento na CRAPJUR. Cooper | Cta | Rowid: ' 
                                                      || rg_crapjur.cdcooper  || ' | '  
                                                      || rg_crapjur.nrdconta  || ' | '
                                                      || rg_crapjur.rowid_jur || ' | '
                                                      || chr(10) || 'JFN SUM: ' || rg_crapjur.somatorio
                                                      || chr(10) || 'JUR vlfatano: ' || rg_crapjur.vlfatano
                                                      || chr(10) || SQLERRM);
        
    END;
    
    vr_count := vr_count + 1;
    
    IF vr_count >= 500 THEN
      
      vr_count := 0;
      
      COMMIT;
      
    END IF;
    
    vr_count_file := vr_count_file + 1;
    
    IF vr_count_file > 7000 THEN
      
      vr_seq_file   := vr_seq_file + 1;
      vr_count_file := 0;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
      
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                              ,pr_nmarquiv => vr_nmarqbkp || LPAD(vr_seq_file, 3, '0') || '.sql'
                              ,pr_tipabert => 'W'
                              ,pr_utlfileh => vr_ind_arquiv
                              ,pr_des_erro => vr_dscritic);
                              
      IF vr_dscritic IS NOT NULL THEN
        
        vr_dscritic := 'Erro ao fechar arquivo parcial. ' || vr_dscritic;
        RAISE vr_exception;
         
      END IF;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
      
    END IF;
    
  END LOOP;
  
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
