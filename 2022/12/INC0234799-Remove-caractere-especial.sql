DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarqbkp           VARCHAR2(50) := 'INC0234799_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'INC0234799_log_execucao.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_total        PLS_INTEGER;
    
  CURSOR cr_crapbem IS
    select b.nrdconta
      , b.cdcooper
      , b.idseqbem
      , b.idseqttl
      , b.dsrelbem
      , TRIM(
          replace(
            replace(
              b.dsrelbem
              , chr('9')
              , chr(32) 
            )
            , chr(32)||chr(32)
            , '' 
          ) 
        ) dsbem_tratado
    from crapbem b
    where b.dsrelbem like '%' || chr(9) || '%';
  
  rg_crapbem  cr_crapbem%ROWTYPE;
  
  CURSOR cr_crapenc IS
    select e.cdcooper
      , e.nrdconta
      , e.idseqttl
      , e.cdseqinc
      , e.tpendass
      , e.complend
      , TRIM(
          replace(
            replace(
              e.complend
              , chr('9')
              , chr(32) 
            )
            , chr(32)||chr(32)
            , '' 
          )
        ) complend_tratado
      , e.dsendere
      , trim(
          regexp_replace(
            e.dsendere
            , '[' || chr(141) || chr(191) || ']'
            , ' ' 
          ) 
        ) dsendere_tratado
    from crapenc e
    where e.complend like '%' || chr(9)   || '%'
      OR e.dsendere like  '%' || chr(141) || '%'
      OR e.dsendere like  '%' || chr(191) || '%';
  
  rg_crapenc  cr_crapenc%ROWTYPE;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0234799';
  
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
  vr_count_total := 0;
  
  
  OPEN cr_crapbem;
  LOOP
    FETCH cr_crapbem INTO rg_crapbem;
    EXIT WHEN cr_crapbem%NOTFOUND;
    
    BEGIN
      
      UPDATE CECRED.crapbem b
        SET b.dsrelbem = rg_crapbem.dsbem_tratado
      WHERE b.nrdconta = rg_crapbem.nrdconta
        AND b.cdcooper = rg_crapbem.cdcooper
        AND b.idseqttl = rg_crapbem.idseqttl
        AND b.idseqbem = rg_crapbem.idseqbem;
        
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    UPDATE CECRED.crapbem SET  '
                                                      || ' dsrelbem = '''    || rg_crapbem.dsrelbem || ''' '
                                                      || 'WHERE nrdconta = ' || rg_crapbem.nrdconta
                                                      || ' AND cdcooper = '  || rg_crapbem.cdcooper
                                                      || ' AND idseqttl = '  || rg_crapbem.idseqttl
                                                      || ' AND idseqbem = '  || rg_crapbem.idseqbem || '; ' );
      vr_count := vr_count + 1;
      vr_count_total := vr_count_total + 1;
      
      IF vr_count >= 500 THEN
        
        vr_count := 0;
        COMMIT;
        
      END IF;
      
    EXCEPTION 
      WHEN OTHERS THEN
        
        CLOSE cr_crapbem;
        vr_dscritic := 'Erro ao atualizar a CRAPBEM: ' || SQLERRM;
        RAISE vr_exception;
        
    END;
    
  END LOOP;
  
  CLOSE cr_crapbem;
  
  OPEN cr_crapenc;
  LOOP
    FETCH cr_crapenc INTO rg_crapenc;
    EXIT WHEN cr_crapenc%NOTFOUND;
    
    BEGIN
      
      UPDATE CECRED.crapenc e
        SET complend = rg_crapenc.complend_tratado
          , e.dsendere = rg_crapenc.dsendere_tratado
      WHERE e.cdcooper = rg_crapenc.cdcooper
        AND e.nrdconta = rg_crapenc.nrdconta
        AND e.idseqttl = rg_crapenc.idseqttl
        AND e.cdseqinc = rg_crapenc.cdseqinc
        AND e.tpendass = rg_crapenc.tpendass;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    UPDATE CECRED.crapenc SET  '
                                                      || ' complend = '''    || rg_crapenc.complend || ''' '
                                                      || ' , dsendere = '''  || rg_crapenc.dsendere || ''' '
                                                      || 'WHERE nrdconta = ' || rg_crapenc.nrdconta
                                                      || ' AND cdcooper = '  || rg_crapenc.cdcooper
                                                      || ' AND idseqttl = '  || rg_crapenc.idseqttl
                                                      || ' AND cdseqinc = '  || rg_crapenc.cdseqinc 
                                                      || ' AND tpendass = '  || rg_crapenc.tpendass || '; ' );
      vr_count := vr_count + 1;
      vr_count_total := vr_count_total + 1;
      
      IF vr_count >= 500 THEN
        
        vr_count := 0;
        COMMIT;
        
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        
        CLOSE cr_crapenc;
        vr_dscritic := 'Erro ao atualizar endereço: ' || SQLERRM;
        RAISE vr_exception;
        
    END;
    
  END LOOP;
  
  CLOSE cr_crapenc;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script - SUCESSO. ' || vr_count_total || ' registros atualizados com sucesso.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'Erro na execução do script: ' || vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script. ERRO: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Total de ' || vr_count_total || ' registros encontrados até o erro.');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'Erro na execução do script: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script. ERRO: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Total de ' || vr_count_total || ' registros encontrados até o erro.');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20001, 'ERRO GERAL: ' || SQLERRM);
END;
