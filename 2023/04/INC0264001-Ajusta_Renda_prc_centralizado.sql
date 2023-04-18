DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0264001_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0264001_script_ROLLBACK_';
  vr_nmarqlog           VARCHAR2(50) := 'INC0264001_relatorio_exec.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arquiv2        utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  
  CURSOR cr_dados IS 
    select p.nrcpfcgc
      , t.tpcompro
      , pr.tpcomprov_renda
      , pr.nrdconta
      , pr.cdcooper
      , pr.ROWID             rowidrenda
    from cecred.crapttl t
    join cecred.tbcadast_pessoa p on t.nrcpfcgc = p.nrcpfcgc
    join cecred.tbcadast_pessoa_renda pr on p.idpessoa = pr.idpessoa
    where nvl(t.tpcompro, 99) <> nvl(pr.tpcomprov_renda, 99)
      and pr.tpcomprov_renda is null 
      and t.tpcompro is not null
    group by p.nrcpfcgc
      , t.tpcompro
      , pr.tpcomprov_renda
      , pr.nrdconta
      , pr.cdcooper
      , pr.ROWID
    ;
  
  rw_dados          cr_dados%ROWTYPE;
  
  vr_seqFile        NUMBER(3);
  vr_countFile      NUMBER(5);
  vr_count          NUMBER(3);
  
  vr_dscritic       VARCHAR2(2000);
  vr_exception      EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0264001';
  
  vr_seqFile  := 1;
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp || LPAD( TO_CHAR(vr_seqFile), 3, '0' ) || '.sql'
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
  
  vr_countFile := 1;
  vr_count     := 1;
  
  OPEN cr_dados;
  LOOP
    FETCH cr_dados INTO rw_dados;
    EXIT WHEN cr_dados%NOTFOUND;
    
    BEGIN
      
      UPDATE CECRED.Tbcadast_Pessoa_Renda
        SET tpcomprov_renda = rw_dados.tpcompro
          , nrdconta = 0
          , cdcooper = 0
      WHERE ROWID = rw_dados.rowidrenda;
    
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.Tbcadast_Pessoa_Renda ' ||
                                                    '   set tpcomprov_renda = ' || NVL( TO_CHAR(rw_dados.tpcomprov_renda), 'NULL' ) || 
                                                    rpad('     , nrdconta =  ' || NVL( TO_CHAR(rw_dados.nrdconta), 'NULL' ), 25, ' ') || 
                                                    rpad('     , cdcooper =  ' || NVL( TO_CHAR(rw_dados.cdcooper), 'NULL' ), 25, ' ') || 
                                                    ' WHERE rowid = ''' || rw_dados.rowidrenda || '''; ');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Erro ao atualizar tipo de renda para o CPF ' || rw_dados.nrcpfcgc || ': ' || SQLERRM);
        
    END;
    
    IF vr_countFile >= 10000 THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
      
      vr_seqFile := (vr_seqFile + 1);
      
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                              ,pr_nmarquiv => vr_nmarqbkp || LPAD( TO_CHAR(vr_seqFile), 3, '0' ) || '.sql'
                              ,pr_tipabert => 'W'
                              ,pr_utlfileh => vr_ind_arquiv
                              ,pr_des_erro => vr_dscritic);
                              
      IF vr_dscritic IS NOT NULL THEN
        CLOSE cr_dados;
        RAISE vr_exception;
      END IF;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
      
      vr_countFile := 0;
      
    END IF;
    
    IF vr_count >= 500 THEN
      
      COMMIT;
      vr_count := 0;
      
    END IF;
    
    vr_count     := (vr_count + 1);
    
    vr_countFile := (vr_countFile + 1);
    
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
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, ' -- ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20003, 'Erro: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, ' -- ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20004, 'ERRO NÃO TRATADO: ' || SQLERRM);
    
END;
