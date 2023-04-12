DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0295315_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0295315_script_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'RITM0295315_relatorio_exec.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arquiv2        utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  CURSOR cr_gncdntj (pr_cdnatjur IN CECRED.GNCDNTJ.cdnatjur%TYPE) IS
    SELECT n.dsnatjur
      , n.rsnatjur
      , n.cdnatjur
    FROM CECRED.GNCDNTJ n
    WHERE n.cdnatjur = pr_cdnatjur;
    
  rg_gncdntj   cr_gncdntj%ROWTYPE;
  
  TYPE RG IS RECORD (
    cdnatjur        CECRED.GNCDNTJ.cdnatjur%TYPE
    , dsnatjur      CECRED.GNCDNTJ.dsnatjur%TYPE
    , rsnatjur      CECRED.GNCDNTJ.rsnatjur%TYPE
  );
  
  TYPE ARR IS TABLE OF RG INDEX BY BINARY_INTEGER;
  vt_natjurs  ARR;
  
  vr_dscritic       VARCHAR2(2000);
  vr_exception      EXCEPTION;

BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0295315';
  
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
  
  vt_natjurs(1).cdnatjur := 2330; vt_natjurs(1).dsnatjur := 'Cooperativas de Consumo';                                 vt_natjurs(1).rsnatjur := 'COOP CONSUMO';
  vt_natjurs(2).cdnatjur := 2348; vt_natjurs(2).dsnatjur := 'Empresa Simples de Inovacao - Inova Simples';             vt_natjurs(2).rsnatjur := 'INOVA SIMPLES';
  vt_natjurs(3).cdnatjur := 3298; vt_natjurs(3).dsnatjur := 'Frente Plebiscitaria ou Referendaria';                    vt_natjurs(3).rsnatjur := 'FRENTE PLEB REF';
  vt_natjurs(4).cdnatjur := 3301; vt_natjurs(4).dsnatjur := 'Organizacao Social (OS)';                                 vt_natjurs(4).rsnatjur := 'ORGANIZ. SOCIAL';
  vt_natjurs(5).cdnatjur := 3310; vt_natjurs(5).dsnatjur := 'Demais Condominios';                                      vt_natjurs(5).rsnatjur := 'DEMAIS COND.';
  vt_natjurs(6).cdnatjur := 3328; vt_natjurs(6).dsnatjur := 'Plano de Beneficios de Previdencia Complementar Fechada'; vt_natjurs(6).rsnatjur := 'B PREV COMP FEC';
  vt_natjurs(7).cdnatjur := 4022; vt_natjurs(7).dsnatjur := 'Segurado Especial';                                       vt_natjurs(7).rsnatjur := 'SEGUR. ESPECIAL';
  vt_natjurs(8).cdnatjur := 4111; vt_natjurs(8).dsnatjur := 'Leiloeiro ';                                              vt_natjurs(8).rsnatjur := 'LEILOEIRO';
  vt_natjurs(9).cdnatjur := 4120; vt_natjurs(9).dsnatjur := 'Produtor Rural (Pessoa Fisica)';                          vt_natjurs(9).rsnatjur := 'PRODUTOR RURAL';
  
  FOR ind IN vt_natjurs.FIRST..vt_natjurs.LAST LOOP
    
    BEGIN
      
      INSERT INTO CECRED.GNCDNTJ (
        cdnatjur
        , dsnatjur
        , rsnatjur
        , flgprsoc
        , flentpub
        , cdgrpnat
      ) VALUES (
        vt_natjurs(ind).cdnatjur
        , vt_natjurs(ind).dsnatjur
        , vt_natjurs(ind).rsnatjur
        , 0
        , 0
        , 0
      );
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE CECRED.GNCDNTJ WHERE cdnatjur = ' || vt_natjurs(ind).cdnatjur || '; ');
      
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        
        OPEN cr_gncdntj(vt_natjurs(ind).cdnatjur);
        FETCH cr_gncdntj INTO rg_gncdntj;
        
        IF cr_gncdntj%NOTFOUND THEN
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'DUP_VAL_ON_INDEX - Natureza Jurídica com código ' || vt_natjurs(ind).cdnatjur || ' Não foi encontrada para fazer o update. ' || SQLERRM);
          CLOSE cr_gncdntj;
          
          CONTINUE;
          
        END IF;
          
        CLOSE cr_gncdntj;
      
        BEGIN
          
          UPDATE CECRED.GNCDNTJ
            SET dsnatjur = vt_natjurs(ind).dsnatjur
              , rsnatjur = vt_natjurs(ind).rsnatjur
          WHERE cdnatjur = vt_natjurs(ind).cdnatjur;
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.GNCDNTJ '
                                                     || ' SET dsnatjur = ''' || rg_gncdntj.dsnatjur || ''' '
                                                     || '   , rsnatjur = ''' || rg_gncdntj.rsnatjur || ''' '
                                                     || '  WHERE cdnatjur = ' || vt_natjurs(ind).cdnatjur || '; ');
          
        EXCEPTION 
          WHEN OTHERS THEN
          
            gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ERRO ao fazer UPDATE na GNCDNTJ para a Natureza Jurídica (' || vt_natjurs(ind).cdnatjur || '): ' || sqlerrm);
            NULL;
          
        END;
      
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ERRO ao INSERIR na GNCDNTJ para a Natureza Jurídica (' || vt_natjurs(ind).cdnatjur || '): ' || sqlerrm);
        NULL;
      
    END;
    
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    
END;
