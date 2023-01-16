DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0240773_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0240773_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'INC0240773_relatorio.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  vr_cdcooper           CECRED.crapass.CDCOOPER%TYPE;
  vr_nrdconta           CECRED.crapass.NRDCONTA%TYPE;
  vr_nrcpfcgc           CECRED.crapass.NRCPFCGC%TYPE;
  vr_inhabmen_new       CECRED.crapttl.INHABMEN%TYPE;
  vr_dtmvtolt           DATE;
  vr_lgrowid            ROWID;
  vr_msgalt             VARCHAR2(150);
  
  CURSOR cr_crapalt ( pr_cdcooper IN CECRED.crapalt.CDCOOPER%TYPE
                    , pr_nrdconta IN CECRED.crapalt.NRDCONTA%TYPE
                    , pr_dtmvtolt IN CECRED.crapalt.DTALTERA%TYPE ) IS
    SELECT a.dsaltera
    FROM CECRED.crapalt a
    WHERE a.cdcooper = pr_cdcooper
      AND a.nrdconta = pr_nrdconta
      AND a.dtaltera = pr_dtmvtolt;
  
  vr_dsaltera CECRED.crapalt.dsaltera%TYPE;
  
  CURSOR cr_crapttl( pr_cdcooper    IN CECRED.crapttl.CDCOOPER%TYPE
                     , pr_nrdconta  IN CECRED.crapttl.NRDCONTA%TYPE
                     , pr_nrcpfcgc  IN CECRED.crapttl.NRCPFCGC%TYPE) IS
    SELECT t.inhabmen
    FROM CECRED.crapttl t
    WHERE t.cdcooper = pr_cdcooper
      AND t.nrdconta = pr_nrdconta
      AND t.nrcpfcgc = pr_nrcpfcgc;
  
  rg_crapttl  cr_crapttl%ROWTYPE;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0240773';
  
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
  
  LOOP
    
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                ,pr_des_text => vr_setlinha);
    
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    vr_cdcooper := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(1,vr_setlinha,';') ) );
    vr_nrdconta := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2,vr_setlinha,';') ) );
    vr_nrcpfcgc := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(3,vr_setlinha,';') ) );
    vr_inhabmen_new := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(5,vr_setlinha,';') ) );
    
    vr_dtmvtolt := SISTEMA.datascooperativa(vr_cdcooper).dtmvtolt;
    
    OPEN cr_crapttl(vr_cdcooper, vr_nrdconta, vr_nrcpfcgc);
    FETCH cr_crapttl INTO rg_crapttl;
    
    IF cr_crapttl%NOTFOUND THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_cdcooper 
                                                    || ';' || vr_nrdconta 
                                                    || ';' || vr_nrcpfcgc 
                                                    || ';ERRO'
                                                    || ';Conta / CPF NÃO encontrados no Aimaro');
      
    ELSE
      
      BEGIN
        
        UPDATE CECRED.Crapttl
          SET inhabmen = vr_inhabmen_new
        WHERE cdcooper = vr_cdcooper
          AND nrdconta = vr_nrdconta
          AND nrcpfcgc = vr_nrcpfcgc;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    UPDATE CECRED.Crapttl '
                                                      || '   SET inhabmen = ' || rg_crapttl.inhabmen
                                                      || ' WHERE cdcooper = ' || vr_cdcooper
                                                      || '   AND nrdconta = ' || vr_nrdconta
                                                      || '   AND nrcpfcgc = ' || vr_nrcpfcgc || '; ' );
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_cdcooper 
                                                      || ';' || vr_nrdconta 
                                                      || ';' || vr_nrcpfcgc 
                                                      || ';SUCESSO'
                                                      || ';Alteração realizada com sucesso'
                                                      || ';' || rg_crapttl.inhabmen 
                                                      || ';' || vr_inhabmen_new );
        
      EXCEPTION
        WHEN OTHERS THEN
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_cdcooper 
                                                        || ';' || vr_nrdconta 
                                                        || ';' || vr_nrcpfcgc 
                                                        || ';ERRO'
                                                        || ';Erro ao atualizar registro na TTL: ' || SQLERRM );
          
          vr_dscritic := 'Erro ao atualizar a CRAPTTL: ' || SQLERRM;
          
          CLOSE cr_crapttl;
          RAISE vr_exception;
          
      END;
      
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => '1',
                           pr_dscritic => ' ',
                           pr_dsorigem => 'AIMARO',
                           pr_dstransa => 'INC0240773 - Alteracao da Capacidade civil',
                           pr_dttransa => vr_dtmvtolt,
                           pr_flgtrans => 1,
                           pr_hrtransa => gene0002.fn_busca_time,
                           pr_idseqttl => 1,
                           pr_nmdatela => 'CONTAS',
                           pr_nrdconta => vr_nrdconta,
                           pr_nrdrowid => vr_lgrowid);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid,
                                pr_nmdcampo => 'inhabmen',
                                pr_dsdadant => rg_crapttl.inhabmen,
                                pr_dsdadatu => vr_inhabmen_new);
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE cecred.craplgi i '
                                                 || ' WHERE EXISTS (SELECT 1 '
                                                 || '               FROM cecred.craplgm m '
                                                 || '               WHERE m.rowid = ''' || vr_lgrowid || ''' ' 
                                                 || '                 AND i.cdcooper = m.cdcooper '
                                                 || '                 AND i.nrdconta = m.nrdconta '
                                                 || '                 AND i.idseqttl = m.idseqttl '
                                                 || '                 AND i.dttransa = m.dttransa '
                                                 || '                 AND i.hrtransa = m.hrtransa '
                                                 || '                 AND i.nrsequen = m.nrsequen);');

      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE cecred.craplgm WHERE rowid = ''' || vr_lgrowid || '''; ');
      
      OPEN cr_crapalt(vr_cdcooper, vr_nrdconta, vr_dtmvtolt);
      FETCH cr_crapalt INTO vr_dsaltera;
      
      vr_msgalt := 'capacidade civil .crapttl,';
      
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
            vr_nrdconta
            , vr_dtmvtolt
            , 1
            , vr_msgalt
            , 2
            , vr_cdcooper
          );
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE cecred.crapalt '
                                                     || ' WHERE nrdconta = ' || vr_nrdconta
                                                     || '   and cdcooper = ' || vr_cdcooper
                                                     || '   and dtaltera = to_date( ''' || to_char(vr_dtmvtolt, 'dd/mm/rrrr') || ''', ''dd/mm/rrrr'')'
                                                     || '; ' );
          
        EXCEPTION
          WHEN OTHERS THEN
            
            vr_dscritic := 'Erro ao Inserir atualização cadastral para conta ' || vr_nrdconta || ' / ' || vr_cdcooper
                           || ' - ' || SQLERRM;
            
            CLOSE cr_crapalt;
            
            RAISE vr_exception;
            
        END;
        
      ELSE 
        
        BEGIN
              
          UPDATE CECRED.crapalt
            SET dsaltera = vr_dsaltera || vr_msgalt
          WHERE nrdconta = vr_nrdconta
            AND cdcooper = vr_cdcooper
            AND dtaltera = vr_dtmvtolt;
            
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE cecred.crapalt '
                                                     || ' SET dsaltera = ''' || vr_dsaltera || ''' '
                                                     || ' WHERE nrdconta = ' || vr_nrdconta
                                                     || '   and cdcooper = ' || vr_cdcooper
                                                     || '   and dtaltera = to_date( ''' || to_char(vr_dtmvtolt, 'dd/mm/rrrr') || ''', ''dd/mm/rrrr'')'
                                                     || '; ');
          
        EXCEPTION
          WHEN OTHERS THEN
                
            vr_dscritic := 'Erro ao Complementar atualização cadastral para conta ' || vr_nrdconta || ' / ' || vr_cdcooper
                           || ' - ' || SQLERRM;
            
            CLOSE cr_crapalt;
            RAISE vr_exception;
                
        END;
        
      END IF;
      
      CLOSE cr_crapalt;
      
    END IF;
    
    CLOSE cr_crapttl;
    
    vr_count := vr_count + 1;
    
    IF vr_count >= 500 THEN
      
      vr_count := 0;
      COMMIT;
      
    END IF;
    
  END LOOP;
  
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
