DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0309814_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0309814_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'RITM0309814_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_nrcpfcgc           CECRED.crapass.NRCPFCGC%TYPE;
  vr_dsnatjur           VARCHAR2(255);
  vr_cdnatjur           CECRED.crapjur.NATJURID%TYPE;
  vr_dtmvtolt           CECRED.crapalt.DTALTERA%TYPE;
  vr_comments           VARCHAR2(2000);
  vr_msgalt             VARCHAR2(1000);
  vr_hrtransa           CECRED.craplgm.HRTRANSA%TYPE;
  vr_nrdrowid           ROWID;
  
  CURSOR cr_crapjur (pr_nrcpfcgc IN CECRED.crapass.NRCPFCGC%TYPE) IS 
    SELECT a.cdcooper
      , a.nrdconta
      , j.natjurid
      , j.rowid          rowid_update
    FROM CECRED.crapass a
    JOIN CECRED.crapjur j ON a.cdcooper = j.cdcooper
                             AND a.nrdconta = j.nrdconta
    WHERE a.nrcpfcgc = pr_nrcpfcgc
      AND a.cdcooper = 1;
    
  rg_crapjur            cr_crapjur%ROWTYPE;
  
  CURSOR cr_natjur (pr_cdnatjur IN CECRED.GNCDNTJ.CDNATJUR%TYPE) IS
    SELECT c.* 
    FROM CECRED.GNCDNTJ c
    WHERE c.cdnatjur = pr_cdnatjur;
  
  rg_natjur             cr_natjur%ROWTYPE;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  PROCEDURE registraAltera (pr_cdcooper  IN CECRED.crapalt.CDCOOPER%TYPE
                          , pr_nrdconta  IN CECRED.crapalt.NRDCONTA%TYPE
                          , pr_idseqttl IN CECRED.crapttl.IDSEQTTL%TYPE DEFAULT 1
                          , pr_tpaltera IN CECRED.crapalt.TPALTERA%TYPE DEFAULT 1) IS
    
    CURSOR cr_crapalt ( pr_cdcooper IN CECRED.crapalt.CDCOOPER%TYPE
                      , pr_nrdconta IN CECRED.crapalt.NRDCONTA%TYPE
                      , pr_dtmvtolt IN CECRED.crapalt.DTALTERA%TYPE ) IS
      SELECT a.dsaltera
      FROM CECRED.crapalt a
      WHERE a.cdcooper = pr_cdcooper
        AND a.nrdconta = pr_nrdconta
        AND a.dtaltera = pr_dtmvtolt;
    
    vr_dsaltera CECRED.crapalt.dsaltera%TYPE;
    
  BEGIN
    
    OPEN cr_crapalt(pr_cdcooper, pr_nrdconta, vr_dtmvtolt);
    FETCH cr_crapalt INTO vr_dsaltera;
    
    IF cr_crapalt%NOTFOUND THEN
        
      BEGIN
            
        INSERT INTO CECRED.crapalt (
          nrdconta
          , dtaltera
          , cdoperad
          , dsaltera
          , tpaltera
          , cdcooper
        ) VALUES (
          pr_nrdconta
          , vr_dtmvtolt
          , 1
          , vr_msgalt || ', ' 
          , pr_tpaltera
          , pr_cdcooper
        );
          
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '   DELETE cecred.crapalt '
                                                   || ' WHERE nrdconta = ' || pr_nrdconta
                                                   || '   and cdcooper = ' || pr_cdcooper
                                                   || '   and dtaltera = to_date( ''' || to_char(vr_dtmvtolt, 'dd/mm/rrrr') || ''', ''dd/mm/rrrr'')'
                                                   || '; ' );
          
      EXCEPTION
        WHEN OTHERS THEN
            
          vr_dscritic := 'Erro ao Inserir atualização cadastral para conta ' || pr_nrdconta || ' / ' || pr_cdcooper
                         || ' - ' || SQLERRM;
            
          CLOSE cr_crapalt;
            
          RAISE vr_exception;
            
      END;
        
    ELSE 
        
      BEGIN
              
        UPDATE CECRED.crapalt
          SET dsaltera = vr_dsaltera || ' ' || vr_msgalt || ', '
            , tpaltera = pr_tpaltera
        WHERE nrdconta = pr_nrdconta
          AND cdcooper = pr_cdcooper
          AND dtaltera = vr_dtmvtolt;
            
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE cecred.crapalt '
                                                   || ' SET dsaltera = ''' || vr_dsaltera || ''' '
                                                   || ' WHERE nrdconta = ' || pr_nrdconta
                                                   || '   and cdcooper = ' || pr_cdcooper
                                                   || '   and dtaltera = to_date( ''' || to_char(vr_dtmvtolt, 'dd/mm/rrrr') || ''', ''dd/mm/rrrr'')'
                                                   || '; ');
          
      EXCEPTION
        WHEN OTHERS THEN
                
          vr_dscritic := 'Erro ao Complementar atualização cadastral para conta ' || pr_nrdconta || ' / ' || pr_cdcooper
                         || ' - ' || SQLERRM;
            
          CLOSE cr_crapalt;
          RAISE vr_exception;
                
      END;
        
    END IF;
      
    CLOSE cr_crapalt;
      
  END;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0309814';
  
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
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarquiv
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_input_file
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  LOOP
    
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                ,pr_des_text => vr_setlinha);
    
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    vr_nrcpfcgc := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1, vr_setlinha, ';') ) );
    vr_dsnatjur := TRIM( gene0002.fn_busca_entrada(2, vr_setlinha, ';') );
    vr_cdnatjur := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(3, vr_setlinha, ';') ) );
    
    OPEN cr_crapjur(vr_nrcpfcgc);
    FETCH cr_crapjur INTO rg_crapjur;
    
    IF cr_crapjur%NOTFOUND THEN
      
      gene0001.pc_escr_linha_arquivo(
        vr_ind_arqlog
        , ' *** NÃO foi licalizada conta para atualização: ' || chr(10)
          || ' cpf: ' || vr_nrcpfcgc || ' | DS natjur: ' || vr_dsnatjur || ' | CD natjur: ' || vr_cdnatjur
      );
      
    ELSE
      
      OPEN cr_natjur(vr_cdnatjur);
      FETCH cr_natjur INTO rg_natjur;
      
      IF cr_natjur%FOUND THEN
        
        BEGIN
          
          UPDATE CECRED.crapjur
            SET natjurid = vr_cdnatjur
          WHERE ROWID = rg_crapjur.rowid_update;
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.crapjur SET natjurid = ' || rg_crapjur.natjurid || ' WHERE ROWID = ''' || rg_crapjur.rowid_update || '''; ');
          
          vr_msgalt   := 'RITM0309814 - Atualização de natureza jurídica para base enriquecida CSC1285116';
          vr_dtmvtolt := SISTEMA.datascooperativa(rg_crapjur.cdcooper).dtmvtolt;
                
          vr_comments := 'Registra log para exibição na ALTERA com "tpaltera = 1" - Atualiza data da revisão cadastral';
          registraAltera(
            pr_cdcooper   => rg_crapjur.cdcooper
            , pr_nrdconta => rg_crapjur.nrdconta
            , pr_idseqttl => 1
            , pr_tpaltera => 1
          );
          
          vr_comments := 'Registra log para exibição na VERLOG';
          vr_hrtransa := gene0002.fn_busca_time;
          
          INSERT INTO craplgm(cdcooper
           ,cdoperad
           ,dscritic
           ,dsorigem
           ,dstransa
           ,dttransa
           ,flgtrans
           ,hrtransa
           ,idseqttl
           ,nmdatela
           ,nrdconta)
          VALUES(rg_crapjur.cdcooper
           ,1
           ,null
           ,'Script'
           ,vr_msgalt
           ,vr_dtmvtolt
           ,1
           ,vr_hrtransa
           ,1
           ,'JOB'
           ,rg_crapjur.nrdconta)
          RETURNING ROWID INTO vr_nrdrowid;
          
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                          ,pr_nmdcampo  => 'natjurid'
                                          ,pr_dsdadant  => to_char(rg_crapjur.natjurid)
                                          ,pr_dsdadatu  => to_char(vr_cdnatjur)
                                          );
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '   DELETE cecred.craplgi i '
                                                        || ' WHERE EXISTS '
                                                        || ' ( SELECT 1 FROM cecred.craplgm m '
                                                        || '   WHERE m.rowid = ''' || vr_nrdrowid || ''' ' 
                                                        || '     AND i.cdcooper = m.cdcooper '
                                                        || '     AND i.nrdconta = m.nrdconta '
                                                        || '     AND i.idseqttl = m.idseqttl '
                                                        || '     AND i.dttransa = m.dttransa '
                                                        || '     AND i.hrtransa = m.hrtransa '
                                                        || '     AND i.nrsequen = m.nrsequen);' );
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '   DELETE cecred.craplgm WHERE rowid = ''' || vr_nrdrowid || '''; ' );
          
        EXCEPTION
          WHEN OTHERS THEN
            
            vr_dscritic := 'Erro ao atualizar Natureza Jurídica na CRAPJUR: ' || SQLERRM;
            gene0001.pc_escr_linha_arquivo(
              vr_ind_arqlog
              , ' *** Erro ao atualizar Natureza Jurídica na CRAPJUR: ' || CHR(10)
                || ' cpf: ' || vr_nrcpfcgc || ' | DS natjur: ' || vr_dsnatjur || ' | CD natjur: ' || vr_cdnatjur
                || CHR(10) || SQLERRM 
            );
            
        END;
        
      ELSE
        
        gene0001.pc_escr_linha_arquivo(
          vr_ind_arqlog
          , ' *** Natureza Jurídica informada NÃO existente: ' || chr(10)
            || ' cpf: ' || vr_nrcpfcgc || ' | DS natjur: ' || vr_dsnatjur || ' | CD natjur: ' || vr_cdnatjur
        );
        
      END IF;
      
      CLOSE cr_natjur;
      
    END IF;
    
    CLOSE cr_crapjur;
    
    vr_count := vr_count + 1;
    IF vr_count > 500 THEN
      
      COMMIT;
      
      vr_count := 0;
      
    END IF;
  
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
    WHEN no_data_found THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    COMMIT;
    
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
