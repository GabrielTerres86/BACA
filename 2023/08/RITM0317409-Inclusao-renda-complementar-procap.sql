DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0317409_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0317409_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'RITM0317409_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_nrcpfcgc           CECRED.crapass.NRCPFCGC%TYPE;
  vr_nmrescop           CECRED.crapcop.NMRESCOP%TYPE;
  vr_cdcooper           CECRED.crapcop.CDCOOPER%TYPE;
  vr_nrdconta           CECRED.crapass.NRDCONTA%TYPE;
  vr_vlrenda            CECRED.crapttl.VLDRENDI##1%TYPE;
  vr_dsjusren           VARCHAR2(500);
  vr_dtmvtolt           CECRED.crapalt.DTALTERA%TYPE;
  vr_comments           VARCHAR2(2000);
  vr_msgalt             VARCHAR2(1000);
  vr_hrtransa           CECRED.craplgm.HRTRANSA%TYPE;
  vr_nrdrowid           ROWID;
  vr_registrar_log      BOOLEAN;
  vr_nmcampologTP       VARCHAR2(50);
  vr_nmcampologVL       VARCHAR2(50);
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_crapcop (pr_nmrescop IN CECRED.crapcop.NMRESCOP%TYPE) IS
    SELECT c.cdcooper
    FROM CECRED.Crapcop c
    WHERE c.nmrescop = TRIM( UPPER( pr_nmrescop ) );
  
  CURSOR cr_crapttl (pr_nrcpfcgc  IN CECRED.crapttl.NRCPFCGC%TYPE
                   , pr_nrdconta  IN CECRED.crapttl.NRDCONTA%TYPE
                   , pr_cdcooper  IN CECRED.crapttl.CDCOOPER%TYPE ) IS
    SELECT ROWID     rowid_ttl
      , t.nrdconta
      , t.dsjusren
      , t.vldrendi##1
      , t.vldrendi##2
      , t.vldrendi##3
      , t.vldrendi##4
      , t.tpdrendi##1
      , t.tpdrendi##2
      , t.tpdrendi##3
      , t.tpdrendi##4
      , t.idseqttl
      , CASE 
         WHEN t.tpdrendi##1 = 6
           THEN 1
         WHEN t.tpdrendi##2 = 6
           THEN 2
         WHEN t.tpdrendi##3 = 6
           THEN 3
         WHEN t.tpdrendi##4 = 6
           THEN 4
         ELSE 0 END              seq_tipo_6
    FROM CECRED.crapttl t
    WHERE t.nrcpfcgc = pr_nrcpfcgc
      AND t.nrdconta = pr_nrdconta
      AND t.cdcooper = pr_cdcooper;
  
  rg_crapttl       cr_crapttl%ROWTYPE;
  
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
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0317409';
  
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
                                
    vr_comments := ' [1] Cooperativa ; [2] C/C    ; [3] CPF     ; [4] PA ; [5] Valor Renda ; [6] Campos Outras Rendas Central ';
    vr_comments := ' VIACREDI        ; 643815     ; 62534521934 ; 1      ; 1               ; Atualização Birô Vínculo CNPJ/Autônomo -  (Procap)';
    
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    
    vr_nrdconta := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2, vr_setlinha, ';') ) );
    
    IF NVL(vr_nrdconta, 0) = 0 THEN
      
      vr_comments := ' Caso o CSV venha com cabeçalho, ignora o loop onde não tenha um número de conta ';
      CONTINUE;
      
    END IF;
    
    vr_nrcpfcgc := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(3, vr_setlinha, ';') ) );
    vr_vlrenda  := 1;
    vr_dsjusren := TRIM( gene0002.fn_busca_entrada(6, vr_setlinha, ';') );
    
    vr_nmrescop := UPPER( TRIM( gene0002.fn_busca_entrada(1, vr_setlinha, ';') ) );
    OPEN cr_crapcop(vr_nmrescop);
    FETCH cr_crapcop INTO vr_cdcooper;
    
    IF cr_crapcop%NOTFOUND THEN
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Alerta;' || ' ** ERRO ao buscar código para a Cooperativa informada no arquivo de carga. ;'
                                                    || vr_nrcpfcgc || ' ; '
                                                    || vr_nrdconta || ' ; '
                                                    || vr_nmrescop
      );
      
      CLOSE cr_crapcop;
      
      vr_comments := 'Se não encontrar a cooperativa, passa para o próximo registro registrando o alerta em Log';
      CONTINUE;
      
    END IF;
    
    CLOSE cr_crapcop;
    
    vr_msgalt   := 'RITM0317409 - Enriquecimento Cadastral realizado pela Central com informações do birô de Crédito Boa Vista e Banco de Dados da Neoway - Aderência ao Programa Procapcred.';
    vr_dtmvtolt := SISTEMA.datascooperativa(vr_cdcooper).dtmvtolt;
    vr_hrtransa := gene0002.fn_busca_time;
    
    OPEN cr_crapttl(pr_nrcpfcgc => vr_nrcpfcgc
                  , pr_nrdconta => vr_nrdconta
                  , pr_cdcooper => vr_cdcooper
    );
    FETCH cr_crapttl INTO rg_crapttl;
    
    IF cr_crapttl%NOTFOUND THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Alerta;' || ' *** Não foi encontrado registro de conta na TTL para atualização de renda. ;'
                                                    || vr_nrcpfcgc || ' ; '
                                                    || vr_nrdconta || ' ; '
                                                    || vr_nmrescop
      );
      
      CLOSE cr_crapttl;
      vr_comments := 'Se não encontrar um registro n TTL, passa para o próximo registro registrando o alerta em Log';
      
      CONTINUE;
      
    END IF;
    
    CLOSE cr_crapttl;
    
    IF NVL( rg_crapttl.seq_tipo_6, 0 ) > 0 THEN
      
      vr_dsjusren := rg_crapttl.dsjusren || ' ' || vr_dsjusren;
      IF length(vr_dsjusren) <= 162 THEN
        
        BEGIN
          
          UPDATE CECRED.crapttl
            SET dsjusren = vr_dsjusren
          WHERE ROWID = rg_crapttl.rowid_ttl;
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.crapttl SET dsjusren = ''' || rg_crapttl.dsjusren || ''' WHERE ROWID = ''' || rg_crapttl.rowid_ttl || '''; ');
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Informativo 1;' || ' **** Já existe uma renda do tipo 6, Outros, para o Cooperado. Ajustando apenas a Justificativa da renda. ;'
                                                        || vr_nrcpfcgc || ' ; '
                                                        || vr_nrdconta || ' ; '
                                                        || vr_nmrescop
          );
          
          registraAltera(
            pr_cdcooper   => vr_cdcooper
            , pr_nrdconta => vr_nrdconta
            , pr_idseqttl => rg_crapttl.idseqttl
            , pr_tpaltera => 2
          );
          
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
          VALUES(vr_cdcooper
           ,1
           ,null
           ,'Script'
           ,vr_msgalt
           ,vr_dtmvtolt
           ,1
           ,vr_hrtransa
           ,1
           ,'JOB'
           ,vr_nrdconta)
          RETURNING ROWID INTO vr_nrdrowid;
              
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                          ,pr_nmdcampo  => 'crapttl.dsjusren'
                                          ,pr_dsdadant  => NVL( TRIM( rg_crapttl.dsjusren ) , ' ' )
                                          ,pr_dsdadatu  => vr_dsjusren
                                          );
          
        EXCEPTION
          WHEN OTHERS THEN
            
            gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO;' || ' Erro não tratado ao atualizar justificativa de renda: ' || SQLERRM || ' ;'
                                                          || vr_nrcpfcgc || ' ; '
                                                          || vr_nrdconta || ' ; '
                                                          || vr_nmrescop
            );
            
        END;
        
      ELSE
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Alerta;' || ' Justificativa maior que o tamanho limite (' 
                                                      || LENGTH(vr_dsjusren) || ' caracteres). Necessário tratar manualmente via Aimaro. (' || vr_dsjusren || ') ;'
                                                      || vr_nrcpfcgc || ' ; '
                                                      || vr_nrdconta || ' ; '
                                                      || vr_nmrescop
        );
        
      END IF;
      
      vr_comments := 'Pula para o próximo registro após atualizar APENAS a justificativa.';
      CONTINUE;
      
    END IF;
    
    vr_nmcampologTP := ' ';
    vr_nmcampologVL := ' ';
    
    BEGIN
      
      vr_registrar_log := TRUE;
      
      IF NVL(rg_crapttl.tpdrendi##1, 0) = 0 AND NVL(rg_crapttl.vldrendi##1, 0) = 0 THEN
        
        vr_nmcampologTP := 'rg_crapttl.tpdrendi##1';
        vr_nmcampologVL := 'rg_crapttl.vldrendi##1';
        
        UPDATE CECRED.crapttl 
          SET dsjusren = SUBSTR(vr_dsjusren, 1, 160)
            , tpdrendi##1 = 6
            , vldrendi##1 = vr_vlrenda
        WHERE ROWID = rg_crapttl.rowid_ttl;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.crapttl ' || 
                                                      '   SET dsjusren = '''    || rg_crapttl.dsjusren || ''' ' ||
                                                      '    , tpdrendi##1 = '    || rg_crapttl.tpdrendi##1 ||
                                                      '    , vldrendi##1 = '    || rg_crapttl.vldrendi##1 ||
                                                      ' WHERE ROWID = '''       || rg_crapttl.rowid_ttl || ''' ; ');
        
      ELSIF NVL(rg_crapttl.tpdrendi##2, 0) = 0 AND NVL(rg_crapttl.vldrendi##2, 0) = 0 THEN
        
        vr_nmcampologTP := 'rg_crapttl.tpdrendi##2';
        vr_nmcampologVL := 'rg_crapttl.vldrendi##2';
        
        UPDATE CECRED.crapttl 
          SET dsjusren = SUBSTR(vr_dsjusren, 1, 160)
            , tpdrendi##2 = 6
            , vldrendi##2 = vr_vlrenda
        WHERE ROWID = rg_crapttl.rowid_ttl;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.crapttl ' || 
                                                      '   SET dsjusren = '''    || rg_crapttl.dsjusren || ''' ' ||
                                                      '    , tpdrendi##2 = '    || rg_crapttl.tpdrendi##2 ||
                                                      '    , vldrendi##2 = '    || rg_crapttl.vldrendi##2 ||
                                                      ' WHERE ROWID = '''       || rg_crapttl.rowid_ttl || ''' ; ');
        
      ELSIF NVL(rg_crapttl.tpdrendi##3, 0) = 0 AND NVL(rg_crapttl.vldrendi##3, 0) = 0 THEN
        
        vr_nmcampologTP := 'rg_crapttl.tpdrendi##3';
        vr_nmcampologVL := 'rg_crapttl.vldrendi##3';
        
        UPDATE CECRED.crapttl 
          SET dsjusren = SUBSTR(vr_dsjusren, 1, 160)
            , tpdrendi##3 = 6
            , vldrendi##3 = vr_vlrenda
        WHERE ROWID = rg_crapttl.rowid_ttl;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.crapttl ' || 
                                                      '   SET dsjusren = '''    || rg_crapttl.dsjusren || ''' ' ||
                                                      '    , tpdrendi##3 = '    || rg_crapttl.tpdrendi##3 ||
                                                      '    , vldrendi##3 = '    || rg_crapttl.vldrendi##3 ||
                                                      ' WHERE ROWID = '''       || rg_crapttl.rowid_ttl || ''' ; ');
        
      ELSIF NVL(rg_crapttl.tpdrendi##4, 0) = 0 AND NVL(rg_crapttl.vldrendi##4, 0) = 0 THEN
        
        vr_nmcampologTP := 'rg_crapttl.tpdrendi##4';
        vr_nmcampologVL := 'rg_crapttl.vldrendi##4';
        
        UPDATE CECRED.crapttl 
          SET dsjusren = SUBSTR(vr_dsjusren, 1, 160)
            , tpdrendi##4 = 6
            , vldrendi##4 = vr_vlrenda
        WHERE ROWID = rg_crapttl.rowid_ttl;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.crapttl ' || 
                                                      '   SET dsjusren = '''    || rg_crapttl.dsjusren || ''' ' ||
                                                      '    , tpdrendi##4 = '    || rg_crapttl.tpdrendi##4 ||
                                                      '    , vldrendi##4 = '    || rg_crapttl.vldrendi##4 ||
                                                      ' WHERE ROWID = '''       || rg_crapttl.rowid_ttl || ''' ; ');
        
      ELSE
        
        vr_registrar_log := FALSE;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' Alerta;' || ' ***** Não foi encontrada uma posição livre na CRAPTTL para cadastrar a renda para o Cooperado. ; '
                                                      || vr_nrcpfcgc || ' ; '
                                                      || vr_nrdconta || ' ; '
                                                      || vr_nmrescop
        );
        
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ERRO;' || ' ****** ERRO ao atualizar renda na CRAPTTL. ' || SQLERRM || ' ; '
                                                      || vr_nrcpfcgc || ' ; '
                                                      || vr_nrdconta || ' ; '
                                                      || vr_nmrescop
        );
        
    END;
    
    IF vr_registrar_log = TRUE THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Informativo 2;' || ' Renda no valor R$ ' || TRIM( to_char(vr_vlrenda, 'FM999999999D99') ) || ' incluída com sucesso. ;'
                                                    || vr_nrcpfcgc || ' ; '
                                                    || vr_nrdconta || ' ; '
                                                    || vr_nmrescop
      );
      
      registraAltera(
        pr_cdcooper   => vr_cdcooper
        , pr_nrdconta => vr_nrdconta
        , pr_idseqttl => rg_crapttl.idseqttl
        , pr_tpaltera => 2
      );
      
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
      VALUES(vr_cdcooper
       ,1
       ,null
       ,'Script'
       ,vr_msgalt
       ,vr_dtmvtolt
       ,1
       ,vr_hrtransa
       ,1
       ,'JOB'
       ,vr_nrdconta)
      RETURNING ROWID INTO vr_nrdrowid;
          
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => 'crapttl.dsjusren'
                                      ,pr_dsdadant  => NVL( TRIM( rg_crapttl.dsjusren ) , ' ' )
                                      ,pr_dsdadatu  => SUBSTR(vr_dsjusren, 1, 160)
                                      );
          
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => vr_nmcampologTP
                                      ,pr_dsdadant  => '0'
                                      ,pr_dsdadatu  => '6'
                                      );
          
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => vr_nmcampologVL
                                      ,pr_dsdadant  => '0,00'
                                      ,pr_dsdadatu  => TRIM( to_char(vr_vlrenda, 'FM999999999D99') )
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
      
    ELSE
      
      vr_comments := 'A entrada neste ELSE indica que Não houve um UPDATE na ttl. Passar para o próximo registro.';
      CONTINUE;
      
    END IF;
    
    vr_comments := 'São executadas 6 DMLs em cada loop, por isso o incremento de 6 em 6.';
    vr_count := vr_count + 6;
    IF vr_count > 500 THEN
      
      COMMIT;
      
      vr_count := 0;
      
    END IF;
    
    vr_comments := 'São criadas 4 linhas de ROLLBACK em cada loop, por isso o incremento de 4 em 4.';
    vr_count_file := vr_count_file + 4;
    
    vr_comments := 'Define a cada quantas linhas faz a quebra dos arquivos de ROLLBACK';
    IF vr_count_file > 4000 THEN
      
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
