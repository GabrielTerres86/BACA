DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0330673_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0330673_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'RITM0330673_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_comments           VARCHAR2(2000);
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;

  CURSOR cr_crapprm IS 
    SELECT rowid rowid_prm
      , p.*
    FROM CECRED.crapprm p
    WHERE p.cdacesso = 'COD_FOLHA_RENDA'
      AND p.cdcooper = 0;
  
  rg_crapprm   cr_crapprm%ROWTYPE;
  
  CURSOR cr_crappco IS
    SELECT p.* 
      , p.rowid rowid_pco
    FROM CECRED.crapbat b
    JOIN CECRED.crappco p ON b.cdcadast = p.cdpartar
    WHERE cdbattar = 'HSTPARTICIPALRA';
  
  rg_crappco  cr_crappco%ROWTYPE;
  
  CURSOR cr_nextval_crappartar IS
    SELECT (MAX(t.cdpartar ) + 1) cdpartar
    FROM CECRED.crappat t;
  
  vr_cdcadastro CECRED.crappat.cdpartar%TYPE;
  
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
    FROM CECRED.crapcop c
    WHERE c.flgativo  = 1;
    
  rg_crapcop  cr_crapcop%ROWTYPE;
  
  vr_rowid    ROWID;
  
  vr_novos_hist   VARCHAR2(255);

BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0330673';
  
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
  
  
  OPEN cr_crapprm;
  FETCH cr_crapprm INTO rg_crapprm;
  
  IF cr_crapprm%FOUND THEN
    
    BEGIN
      
      DELETE CECRED.crapprm 
      WHERE ROWID = rg_crapprm.rowid_prm;
      
      IF SQL%ROWCOUNT > 1 THEN
        
        vr_dscritic := 'Erro ao atualizar CRAPPRM. Mais de um registro deletado no script. ';
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic );
        
        CLOSE cr_crapprm;
        RAISE vr_exception;
        
      END IF;
      
      IF SQL%ROWCOUNT < 1 THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ATENÇÃO: DELETE Não realizou exclusão do registro na CRAPPRM. SQL%ROWCOUNT = ' || SQL%ROWCOUNT );
        
      END IF;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' INSERT INTO CECRED.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID ) ' ||
                                                    ' VALUES (' ||
                                                       ' '''   || rg_crapprm.nmsistem || ''' ' ||
                                                       ' , '   || rg_crapprm.cdcooper ||
                                                       ' , ''' || rg_crapprm.cdacesso || ''' ' ||
                                                       ' , ''' || rg_crapprm.dstexprm || ''' ' ||
                                                       ' , ''' || rg_crapprm.dsvlrprm || ''' ' ||
                                                       ' , '   || rg_crapprm.progress_recid    || ' ); ' );
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'OK - Deletado registro da CRAPPRM. ' || rg_crapprm.dsvlrprm || ' - Rowid: ' || rg_crapprm.rowid_prm );
      
    EXCEPTION
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO o atualizar CECRED.crapprm: ' || SQLERRM );
        
    END;
  
  ELSE
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ATENÇÃO: Não foi encontrado registro na crapprm para atualização. ' );
    
  END IF;
  
  CLOSE cr_crapprm;
  
  vr_novos_hist := '0007,0008,0013,0101,0105,0550,0581,0623,0626,0629,0694,0772,0799,0997,0998,1022,1099,1118,1145,1399,1820,1822,1823,1824,1825,1827,1828,1829,1831,1832,1833,1925,1989,2101,2102,2103,2106,2107,2108,2525,2943,3297,3299,3300,3303,3304,3312,3400,3402,3404';
  
  OPEN cr_crappco;
  LOOP
    FETCH cr_crappco INTO rg_crappco;
    EXIT WHEN cr_crappco%NOTFOUND;
    
    BEGIN
      
      UPDATE CECRED.crappco
        SET dsconteu = vr_novos_hist
      WHERE ROWID = rg_crappco.rowid_pco;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.crappco ' ||
                                                    '   SET dsconteu = ''' || rg_crappco.dsconteu || ''' ' ||
                                                    ' WHERE ROWID = '''    || rg_crappco.rowid_pco || '''; ' );
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'OK - Alterado registro da CRAPPCO. ' || chr(10) || rg_crappco.dsconteu || chr(10) 
                                                    || ' Rowid: ' || rg_crappco.rowid_pco || chr(10) 
                                                    || ' Cooper: ' || rg_crappco.cdcooper );
    
    EXCEPTION
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO o atualizar CECRED.crappco: ' || SQLERRM );
        
    END;
    
  END LOOP;
  
  vr_comments := 'CRIAÇÃO DO NOVO PARÂMETRO DEVIDO AO ESTOURO DA CAPACIDADE DO ANTERIOR';
  
  OPEN cr_nextval_crappartar;
  FETCH cr_nextval_crappartar INTO vr_cdcadastro;
  CLOSE cr_nextval_crappartar;
  
  BEGIN
    
    INSERT INTO CECRED.crappat (
      cdpartar
      , nmpartar
      , tpdedado
      , cdprodut
    ) VALUES (
      vr_cdcadastro
      , 'HSTPARTICIPLRA2 CONTINUACAO DO CADASTRO DE HIST. DO HSTPARTICIPALRA'
      , 2
      , 0
    ) RETURNING ROWID INTO vr_rowid;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, CHR(10) || 
                                                  ' DELETE CECRED.crappat ' ||
                                                  ' WHERE ROWID = '''    || vr_rowid || '''; ' );
    
  EXCEPTION
    WHEN OTHERS THEN
      
      vr_dscritic := 'Erro ao criar novo parâmetro na CECECRED.crappat: ' || SQLERRM;
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic  );
      
      RAISE vr_exception;
      
  END;
  
  vr_rowid := NULL;
  
  BEGIN
    
    INSERT INTO CECRED.crapbat (
      cdbattar
      , nmidenti
      , tpcadast
      , cdcadast
    ) VALUES (
      'HSTPARTICIPLRA2'
      , 'PARAMETROS FOLHA CONTINUACAO DO PARAMETRO HSTPARTICIPALRA'
      , 2
      , vr_cdcadastro
    ) RETURNING ROWID INTO vr_rowid;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE CECRED.crapbat ' ||
                                                    ' WHERE ROWID = '''    || vr_rowid || '''; ' );
    
  EXCEPTION
    WHEN OTHERS THEN
      
      vr_dscritic := 'Erro ao criar novo parâmetro na CECRED.crapbat: ' || SQLERRM;
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic  );
      
      RAISE vr_exception;
      
  END;
  
  OPEN cr_crapcop;
  LOOP
    FETCH cr_crapcop INTO rg_crapcop;
    EXIT WHEN cr_crapcop%NOTFOUND;
    
    vr_rowid := NULL;
    
    BEGIN
      
      INSERT INTO CECRED.crappco (
        cdpartar
        , cdcooper
        , dsconteu
      ) VALUES (
        vr_cdcadastro
        , rg_crapcop.cdcooper
        , '3445,3446,3447,3625'
      ) RETURNING ROWID INTO vr_rowid;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE CECRED.crappco ' ||
                                                      ' WHERE ROWID = '''    || vr_rowid || '''; ' );
      
    EXCEPTION
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Erro ao inserir parâmetro na CECRED.crappco: ' || SQLERRM  );
        
    END;
    
  END LOOP;
  
  CLOSE cr_crapcop;
  
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
