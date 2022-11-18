declare
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarqbkp           VARCHAR2(50) := 'INC0232188_ROLLBACK.sql';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;

  CURSOR cr_crapass IS
    SELECT ass.dtnasctl
      , jur.dtiniatv
      , ass.nrdconta
      , ass.cdcooper
    FROM crapass ass
    JOIN crapjur jur ON ass.cdcooper = jur.cdcooper
                        AND ass.nrdconta = jur.nrdconta
    WHERE ass.cdcooper >= 1
       AND inpessoa = 2
       AND dtnasctl IS NULL;
  
  rg_crapass  cr_crapass%rowtype;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
begin
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0232188';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  
  OPEN cr_crapass;
  LOOP
    FETCH cr_crapass INTO rg_crapass;
    EXIT WHEN cr_crapass%NOTFOUND;
    
    UPDATE CECRED.crapass a
      SET dtnasctl = rg_crapass.dtiniatv
    where a.nrdconta = rg_crapass.nrdconta
      and a.cdcooper = rg_crapass.cdcooper;
      
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '      UPDATE CECRED.crapass SET  '
                                                    || '   dtnasctl = NULL '   
                                                    || ' WHERE nrdconta = ' || rg_crapass.nrdconta
                                                    || '   AND cdcooper = ' || rg_crapass.cdcooper || '; ' );
    
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  COMMIT;
  
exception
  when others then
    
    raise_application_error(-20000, 'erro ao executar o script: ' || sqlerrm);
    
    ROLLBACK;
    
END;
