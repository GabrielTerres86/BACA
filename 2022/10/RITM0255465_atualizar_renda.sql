DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0255465_base_rendas.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0255465_ROLLBACK_rendas.sql';
  vr_nmarqlog           VARCHAR2(50) := 'RITM0255465_log_execucao.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  CURSOR cr_crapttl(pr_cdcooper IN CECRED.crapttl.CDCOOPER%TYPE
                   ,pr_nrcpfcgc IN CECRED.crapttl.NRCPFCGC%TYPE) IS
    SELECT t.vlsalari
      , t.tpdrendi##1
      , t.vldrendi##1
      , t.tpdrendi##2
      , t.vldrendi##2
      , t.tpdrendi##3
      , t.vldrendi##3
      , t.tpdrendi##4
      , t.vldrendi##4
      , t.tpdrendi##5
      , t.vldrendi##5
      , t.tpdrendi##6
      , t.vldrendi##6
      , t.dsjusren
      , t.idseqttl
      , t.nrdconta
      , t.cdcooper
    FROM CECRED.CRAPTTL t
    WHERE t.cdcooper = pr_cdcooper
      AND t.nrcpfcgc = pr_nrcpfcgc;

  rw_crapttl cr_crapttl%ROWTYPE;
    
  
  
  CURSOR cr_crapalt ( pr_cdcooper IN CECRED.crapalt.CDCOOPER%TYPE
                    , pr_nrdconta IN CECRED.crapalt.NRDCONTA%TYPE
                    , pr_dtmvtolt IN CECRED.crapalt.DTALTERA%TYPE ) IS
    SELECT a.dsaltera
    FROM CECRED.crapalt a
    WHERE a.cdcooper = pr_cdcooper
      AND a.nrdconta = pr_nrdconta
      AND a.dtaltera = pr_dtmvtolt;
  
  vr_dsaltera crapalt.dsaltera%TYPE;
  
  TYPE           TP_ALT IS ARRAY(4) OF VARCHAR2(60);
  vt_msgalt      TP_ALT;
  vr_msgalt      VARCHAR2(150);
  
  vr_nrdrowid    ROWID;
  vr_cdcooper    CECRED.crapttl.CDCOOPER%TYPE;
  vr_nrcpfcgc    CECRED.crapttl.NRCPFCGC%TYPE;
  vr_vldrendi    CECRED.Crapttl.VLDRENDI##1%TYPE;
  vr_dtmvtolt    CECRED.crapdat.DTMVTOLT%TYPE;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
BEGIN
  
  vt_msgalt    := TP_ALT();
  vt_msgalt.EXTEND(1);
  vt_msgalt(1) := 'tip.ren. 1.ttl,';
  vt_msgalt.EXTEND(1);
  vt_msgalt(2) := 'justificativa rend. 1.ttl,';
  vt_msgalt.EXTEND(1);
  vt_msgalt(3) := 'valor ren. 1.ttl,';
  vt_msgalt.EXTEND(1);
  vt_msgalt(4) := 'Confirmação da Rendasalario 1.ttl,';
  vt_msgalt.EXTEND(1);
  vt_msgalt(5) := 'Enriquecimento de base interna - base Setembro 2022,';
  
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0255465';
  
  gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto
                           ,pr_nmarquiv => vr_nmarquiv
                           ,pr_tipabert => 'R'
                           ,pr_utlfileh => vr_input_file
                           ,pr_des_erro => vr_dscritic);
  
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
    
  END IF;
  
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
  
  vr_dtmvtolt := datascooperativa(2).dtmvtolt;
  
  LOOP
    
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                ,pr_des_text => vr_setlinha);
    
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    vr_cdcooper := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1,vr_setlinha,';') ) );
    vr_nrcpfcgc := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2,vr_setlinha,';') ) );
    vr_vldrendi := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(3,vr_setlinha,';') ) );
  
    OPEN  cr_crapttl(vr_cdcooper,vr_nrcpfcgc);
    FETCH cr_crapttl INTO rw_crapttl;
    
    IF cr_crapttl%NOTFOUND THEN
      
      CLOSE cr_crapttl;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_nrcpfcgc || '     CPF Não encontrado na TTL. Rendimento: ' || vr_vldrendi);
      
      CONTINUE;
      
    END IF;
    
    CLOSE cr_crapttl;
    
    BEGIN
      
      UPDATE CECRED.crapttl
        SET tpdrendi##1 = 0
          , vldrendi##1 = 0
          , tpdrendi##2 = 0
          , vldrendi##2 = 0
          , tpdrendi##3 = 0
          , vldrendi##3 = 0
          , tpdrendi##4 = 0
          , vldrendi##4 = 0
          , tpdrendi##5 = 0
          , vldrendi##5 = 0
          , tpdrendi##6 = 0
          , vldrendi##6 = 0
          , vlsalari    = vr_vldrendi
          , dsjusren    = ' '
      WHERE nrdconta = rw_crapttl.nrdconta
        AND cdcooper = vr_cdcooper
        AND nrcpfcgc = vr_nrcpfcgc;
      
      IF SQL%ROWCOUNT > 1 THEN
        
        vr_dscritic := 'ERRO - ' || SQL%ROWCOUNT || ' registros atualizados para a conta ' || rw_crapttl.nrdconta || ' referente ao CPF ' || vr_nrcpfcgc;
        RAISE vr_exception2;
        
      END IF;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    UPDATE CECRED.crapttl SET  '
                                                    || '   tpdrendi##1 = ' || rw_crapttl.tpdrendi##1
                                                    || ' , vldrendi##1 = ' || replace( rw_crapttl.vldrendi##1, ',', '.' )
                                                    || ' , tpdrendi##2 = ' || rw_crapttl.tpdrendi##2
                                                    || ' , vldrendi##2 = ' || replace( rw_crapttl.vldrendi##2, ',', '.' )
                                                    || ' , tpdrendi##3 = ' || rw_crapttl.tpdrendi##3
                                                    || ' , vldrendi##3 = ' || replace( rw_crapttl.vldrendi##3, ',', '.' )
                                                    || ' , tpdrendi##4 = ' || rw_crapttl.tpdrendi##4
                                                    || ' , vldrendi##4 = ' || replace( rw_crapttl.vldrendi##4, ',', '.' )
                                                    || ' , tpdrendi##5 = ' || rw_crapttl.tpdrendi##5
                                                    || ' , vldrendi##5 = ' || replace( rw_crapttl.vldrendi##5, ',', '.' )
                                                    || ' , tpdrendi##6 = ' || rw_crapttl.tpdrendi##6
                                                    || ' , vldrendi##6 = ' || replace( rw_crapttl.vldrendi##6, ',', '.' )
                                                    || ' , vlsalari = '    || replace( rw_crapttl.vlsalari, ',', '.' )
                                                    || ' , dsjusren = '''  || rw_crapttl.dsjusren || ''' '
                                                    || 'WHERE nrdconta = ' || rw_crapttl.nrdconta
                                                    || ' AND cdcooper = ' || vr_cdcooper
                                                    || ' AND nrcpfcgc = '  || vr_nrcpfcgc || '; ' );
      
    EXCEPTION
      WHEN vr_exception2 THEN
        
        RAISE vr_exception;
      
      WHEN OTHERS THEN
        
        vr_dscritic := 'Erro ao atualizar a coop/conta '||vr_cdcooper||'/'|| rw_crapttl.nrdconta || ' referente ao CPF ' || vr_nrcpfcgc;
        RAISE vr_exception;
        
    END;
    
    OPEN cr_crapalt(vr_cdcooper, rw_crapttl.nrdconta, vr_dtmvtolt);
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
          rw_crapttl.nrdconta
          , vr_dtmvtolt
          , '1'
          , 'salario ' || rw_crapttl.idseqttl || '.ttl,tip.ren. ' || rw_crapttl.idseqttl || '.ttl,valor ren. ' || rw_crapttl.idseqttl || 
            '.ttl,justificativa rend. ' || rw_crapttl.idseqttl || '.ttl,Enriquecimento de base interna - base Setembro 2022,'
          , 1
          , vr_cdcooper
        );
          
      EXCEPTION
        WHEN OTHERS THEN
            
          vr_dscritic := 'Erro ao Inserir atualização cadastral para coop/conta '||vr_cdcooper||'/'|| rw_crapttl.nrdconta 
                         || ' - CPF: ' || vr_nrcpfcgc || ' - ' || SQLERRM;
          RAISE vr_exception;
            
      END;
        
        
    ELSE 
      
      vr_msgalt := '';
      
      FOR j IN 1..vt_msgalt.COUNT() LOOP
        
        IF INSTR( UPPER( vr_dsaltera ) , UPPER( vt_msgalt(j) ) , 1 ) = 0 THEN
          
          vr_msgalt := vr_msgalt || vt_msgalt(j);
          
        END IF;
        
      END LOOP;
      
      BEGIN
            
        UPDATE CECRED.crapalt
          SET dsaltera = vr_dsaltera || vr_msgalt
            , tpaltera = 1
        WHERE nrdconta = rw_crapttl.nrdconta
          AND cdcooper = vr_cdcooper
          AND dtaltera = vr_dtmvtolt;
          
      EXCEPTION
        WHEN OTHERS THEN
              
          vr_dscritic := 'Erro ao Complementar atualização cadastral para coop/conta '||vr_cdcooper||'/'|| rw_crapttl.nrdconta 
                         || ' - CPF: ' || vr_nrcpfcgc || ' - ' || SQLERRM;
          RAISE vr_exception;
              
      END;
      
    END IF;
    
    CLOSE cr_crapalt;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => '1',
                                pr_dscritic => NULL,
                                pr_dsorigem => 'Aimaro',
                                pr_dstransa => 'Altera dados Comerciais',
                                pr_dttransa => vr_dtmvtolt,
                                pr_flgtrans => 1,
                                pr_hrtransa => gene0002.fn_busca_time,
                                pr_idseqttl => rw_crapttl.idseqttl,
                                pr_nmdatela => 'JOB', 
                                pr_nrdconta => rw_crapttl.nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'vlsalari'
                                    ,pr_dsdadant => TRIM( to_char( rw_crapttl.vlsalari, '999999999D99' ) )
                                    ,pr_dsdadatu => TRIM( to_char( vr_vldrendi, '999999999D99' ) ) );
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => '1',
                                pr_dscritic => NULL,
                                pr_dsorigem => 'Aimaro',
                                pr_dstransa => 'RITM0255465 - Enriquecimento de base Outubro de 2022',
                                pr_dttransa => vr_dtmvtolt,
                                pr_flgtrans => 1,
                                pr_hrtransa => gene0002.fn_busca_time,
                                pr_idseqttl => rw_crapttl.idseqttl,
                                pr_nmdatela => 'JOB', 
                                pr_nrdconta => rw_crapttl.nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'Rendimento ttl'
                                    ,pr_dsdadant => TRIM( to_char( rw_crapttl.vlsalari, '999999999D99' ) )
                                    ,pr_dsdadatu => TRIM( to_char( vr_vldrendi, '999999999D99' ) ) );
    
    IF rw_crapttl.tpdrendi##1 = 6 OR 
       rw_crapttl.tpdrendi##2 = 6 OR 
       rw_crapttl.tpdrendi##3 = 6 OR 
       rw_crapttl.tpdrendi##4 = 6 OR 
       rw_crapttl.tpdrendi##5 = 6 OR 
       rw_crapttl.tpdrendi##6 = 6 THEN 
       
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Justificativa Outras Rendas'
                                      ,pr_dsdadant => NVL( TRIM(rw_crapttl.dsjusren), ' ' )
                                      ,pr_dsdadatu => ' ' );
    END IF;
    
    IF rw_crapttl.tpdrendi##1 > 0 THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Outros Rendimentos 01'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.vldrendi##1, '999999999D99' ) )
                                      ,pr_dsdadatu => '0' ) ;
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Tipo de Outros Rendimentos 01'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.tpdrendi##1, '999999999' ) )
                                      ,pr_dsdadatu => '0' );
    END IF;
    
    IF rw_crapttl.tpdrendi##2 > 0 THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Outros Rendimentos 02'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.vldrendi##2, '999999999D99' ) )
                                      ,pr_dsdadatu => '0' ) ;
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Tipo de Outros Rendimentos 02'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.tpdrendi##2, '999999999' ) )
                                      ,pr_dsdadatu => '0' );
    END IF;
    
    IF rw_crapttl.tpdrendi##3 > 0 THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Outros Rendimentos 03'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.vldrendi##3, '999999999D99' ) )
                                      ,pr_dsdadatu => '0' ) ;
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Tipo de Outros Rendimentos 03'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.tpdrendi##3, '999999999' ) )
                                      ,pr_dsdadatu => '0' );
    END IF;
    
    IF rw_crapttl.tpdrendi##4 > 0 THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Outros Rendimentos 04'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.vldrendi##4, '999999999D99' ) )
                                      ,pr_dsdadatu => '0' ) ;
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Tipo de Outros Rendimentos 04'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.tpdrendi##4, '999999999' ) )
                                      ,pr_dsdadatu => '0' );
    END IF;
    
    IF rw_crapttl.tpdrendi##5 > 0 THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Outros Rendimentos 05'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.vldrendi##5, '999999999D99' ) )
                                      ,pr_dsdadatu => '0' ) ;
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Tipo de Outros Rendimentos 05'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.tpdrendi##5, '999999999' ) )
                                      ,pr_dsdadatu => '0' );
    END IF;
    
    IF rw_crapttl.tpdrendi##6 > 0 THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Outros Rendimentos 06'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.vldrendi##6, '999999999D99' ) )
                                      ,pr_dsdadatu => '0' ) ;
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Tipo de Outros Rendimentos 06'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.tpdrendi##6, '999999999' ) )
                                      ,pr_dsdadatu => '0' );
    END IF;
    
    vr_count := vr_count + 1;
    
    IF vr_count > 500 THEN
      
      vr_count := 0;
      COMMIT;
      
    END IF;
    
  END LOOP;
  
  
  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;

EXCEPTION 
  WHEN no_data_found THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    COMMIT;
    
  WHEN vr_exception THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
END;

