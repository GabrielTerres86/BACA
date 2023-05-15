DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0234191_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0234191_script_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'RITM0234191_relatorio_exec.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arquiv2        utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_msgalt             VARCHAR2(600);
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_org_exp IS
    SELECT (MAX(e.idorgao_expedidor) + 1) id_org_exp
    FROM CECRED.TBGEN_ORGAO_EXPEDIDOR e;
  
  vr_id_org_exp   CECRED.TBGEN_ORGAO_EXPEDIDOR.IDORGAO_EXPEDIDOR%TYPE;
  
  CURSOR cr_exist_oexp IS
    SELECT e.*
    FROM TBGEN_ORGAO_EXPEDIDOR E
    WHERE E.CDORGAO_EXPEDIDOR = 'CNR';
  
  rg_exist_oexp  cr_exist_oexp%ROWTYPE;
  
BEGIN
  
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0234191';
  
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  OPEN cr_exist_oexp;
  FETCH cr_exist_oexp INTO rg_exist_oexp;
  
  IF cr_exist_oexp%FOUND THEN
    
    vr_dscritic := 'Órgão expedidor CNR já existe com o código | descrição: ' || rg_exist_oexp.idorgao_expedidor || ' | ' || rg_exist_oexp.nmorgao_expedidor;
    RAISE vr_exception;
    
  END IF;
  
  CLOSE cr_exist_oexp;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');

  OPEN cr_org_exp;
  FETCH cr_org_exp INTO vr_id_org_exp;
  CLOSE cr_org_exp;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor 
    , cdorgao_expedidor 
    , nmorgao_expedidor 
  ) VALUES (
    vr_id_org_exp
    , 'CNR' 
    , 'Confederação Nacional de Notários e Registradores' 
  );
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE CECRED.TBGEN_ORGAO_EXPEDIDOR WHERE idorgao_expedidor = ' || vr_id_org_exp || '; ');
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' *** ERRO ao inserir órgão expedidor: ' || vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' *** ERRO ao inserir órgão expedidor: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20001, 'ERRO: ' || SQLERRM);
    
END;
