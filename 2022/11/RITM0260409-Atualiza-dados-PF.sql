DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0260409_Base_enriquecida_CPF_csv.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0260409_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'RITM0260409_log_execucao.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  CURSOR cr_crapttl(pr_nrcpfcgc IN CECRED.CRAPTTL.NRCPFCGC%TYPE
                  , pr_cdcooper IN CECRED.CRAPTTL.CDCOOPER%TYPE) IS
    SELECT t.vlsalari
      , t.tpdrendi##1
      , t.vldrendi##1
      , t.tpdrendi##2
      , t.vldrendi##2
      , t.tpdrendi##3
      , t.vldrendi##3
      , t.tpdrendi##4
      , t.vldrendi##4
      , t.dsjusren
      , t.idseqttl
      , t.nrdconta
      , t.cdcooper
      , (SELECT count(*) 
         FROM crapttl t2
         WHERE t.nrcpfcgc = t2.nrcpfcgc
           AND t.nrdconta <> t2.nrdconta) qtd_contas
    FROM CECRED.CRAPTTL t
    WHERE t.cdcooper = pr_cdcooper
      AND t.nrcpfcgc = pr_nrcpfcgc;

  rw_crapttl cr_crapttl%ROWTYPE;

  CURSOR cr_crapdat(pr_cdcooper IN CECRED.CRAPTTL.CDCOOPER%TYPE) IS
    SELECT d.dtmvtolt
    FROM CECRED.crapdat d
    WHERE d.cdcooper = pr_cdcooper;
    
  vr_dtmvtolt CECRED.crapdat.DTMVTOLT%TYPE;
  
  CURSOR cr_crapalt ( pr_cdcooper IN CECRED.crapalt.CDCOOPER%TYPE
                    , pr_nrdconta IN CECRED.crapalt.NRDCONTA%TYPE
                    , pr_dtmvtolt IN CECRED.crapalt.DTALTERA%TYPE ) IS
    SELECT a.dsaltera
    FROM CECRED.crapalt a
    WHERE a.cdcooper = pr_cdcooper
      AND a.nrdconta = pr_nrdconta
      AND a.dtaltera = pr_dtmvtolt;
  
  vr_dsaltera crapalt.dsaltera%TYPE;
  
  CURSOR cr_crapcem ( pr_cdcooper IN CECRED.crapttl.cdcooper%TYPE
                    , pr_nrdconta IN CECRED.crapttl.nrdconta%TYPE
                    , pr_idseqttl IN CECRED.crapttl.idseqttl%TYPE
                    , pr_dsemail  IN CECRED.crapcem.DSDEMAIL%TYPE) IS
    SELECT e.dsdemail
    FROM CECRED.crapcem e
    WHERE e.nrdconta = pr_nrdconta
      AND e.cdcooper = pr_cdcooper
      AND e.idseqttl = pr_idseqttl
      AND upper(e.dsdemail) = trim( upper(pr_dsemail) );
  
  rg_crapcem     cr_crapcem%ROWTYPE;
  
  CURSOR cr_craptfc_MAX( pr_cdcooper IN CECRED.crapttl.cdcooper%TYPE
                       , pr_nrdconta IN CECRED.crapttl.nrdconta%TYPE
                       , pr_idseqttl IN CECRED.crapttl.idseqttl%TYPE
                       ) IS
    SELECT ( NVL( MAX( t.cdseqtfc ), 0 ) + 1 ) cdseqtfc
    FROM CECRED.craptfc t
    WHERE t.nrdconta = pr_nrdconta
      AND t.cdcooper = pr_cdcooper
      AND t.idseqttl = pr_idseqttl;
  
  vr_cdseqtfc    CECRED.craptfc.CDSEQTFC%TYPE;
  
  CURSOR cr_craptfc( pr_cdcooper IN CECRED.crapttl.cdcooper%TYPE
                   , pr_nrdconta IN CECRED.crapttl.nrdconta%TYPE
                   , pr_idseqttl IN CECRED.crapttl.idseqttl%TYPE
                   , pr_nrdddtfc IN CECRED.craptfc.NRDDDTFC%TYPE
                   , pr_nrtelefo IN CECRED.craptfc.NRTELEFO%TYPE
                   ) IS
    SELECT t.nrtelefo
      , t.nrdddtfc
    FROM CECRED.craptfc t
    WHERE t.nrdconta = pr_nrdconta
      AND t.cdcooper = pr_cdcooper
      AND t.idseqttl = pr_idseqttl
      AND t.nrdddtfc = NVL(pr_nrdddtfc, 0)
      AND t.nrtelefo = NVL(pr_nrtelefo, 0);
      
  rg_craptfc     cr_craptfc%ROWTYPE;
  
  TYPE           TP_ALT IS ARRAY(4) OF VARCHAR2(50);
  vt_msgalt      TP_ALT;
  vr_msgalt      VARCHAR2(1000);
  
  vr_cdcooper    CECRED.CRAPCOP.CDCOOPER%TYPE;
  vr_nrdrowid    ROWID;
  vr_nrcpfcgc    CECRED.crapttl.NRCPFCGC%TYPE;
  vr_vldrendi    CECRED.Crapttl.VLDRENDI##1%TYPE;
  vr_ddd01       CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_fone01      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_ddd02       CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_fone02      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_ddd03       CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_fone03      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_dddcel01    CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_celu01      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_dddcel02    CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_celu02      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_dddcel03    CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_celu03      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_email       CECRED.CRAPCEM.DSDEMAIL%TYPE;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
  FUNCTION getIdLogCabecalho RETURN ROWID IS
    
  BEGIN
    
    IF vr_nrdrowid IS NULL THEN
    
      CECRED.GENE0001.pc_gera_log( pr_cdcooper => rw_crapttl.cdcooper,
                                   pr_cdoperad => 1,
                                   pr_dscritic => null,
                                   pr_dsorigem => 'Aimaro',
                                   pr_dstransa => 'RITM0260409 - Enriquecimento de base Boa Vista, outubro de 2022.',
                                   pr_dttransa => vr_dtmvtolt,
                                   pr_flgtrans => 1,
                                   pr_hrtransa => gene0002.fn_busca_time,
                                   pr_idseqttl => rw_crapttl.idseqttl,
                                   pr_nmdatela => 'JOB', 
                                   pr_nrdconta => rw_crapttl.nrdconta,
                                   pr_nrdrowid => vr_nrdrowid);
    
    END IF;
    
    RETURN(vr_nrdrowid);
    
  END;
  
  PROCEDURE cadastraTelefone(pr_nrdddtfc  IN CECRED.craptfc.NRDDDTFC%TYPE
                           , pr_nrtelefo  IN CECRED.craptfc.NRTELEFO%TYPE
                           , pr_tptelefo  IN CECRED.craptfc.TPTELEFO%TYPE
                           , pr_det_log   IN VARCHAR2) IS
    
  BEGIN
    
    IF NVL(pr_nrdddtfc, 0) > 0 OR NVL(pr_nrtelefo, 0) > 0 THEN
    
      OPEN cr_craptfc( rw_crapttl.cdcooper
                       , rw_crapttl.nrdconta
                       , rw_crapttl.idseqttl
                       , NVL(pr_nrdddtfc, 0)
                       , NVL(pr_nrtelefo, 0)
                       );
        
      FETCH cr_craptfc INTO rg_craptfc;
        
      IF cr_craptfc%NOTFOUND THEN
      
        vr_cdseqtfc := NULL;
          
        OPEN cr_craptfc_MAX( rw_crapttl.cdcooper
                           , rw_crapttl.nrdconta
                           , rw_crapttl.idseqttl
                           );
        FETCH cr_craptfc_MAX INTO vr_cdseqtfc;
        CLOSE cr_craptfc_MAX;
          
        BEGIN
          
          INSERT INTO CECRED.CRAPTFC (
            cdcooper
            , nrdconta
            , idseqttl
            , nrdddtfc
            , nrtelefo
            , cdseqtfc
            , tptelefo
            , idsittfc
            , idorigem
            , dtinsori
            , inprincipal
          ) VALUES (
            rw_crapttl.cdcooper
            , rw_crapttl.nrdconta
            , rw_crapttl.idseqttl
            , NVL(pr_nrdddtfc, 0)
            , NVL(pr_nrtelefo, 0)
            , vr_cdseqtfc
            , pr_tptelefo
            , 1
            , 4
            , SYSDATE
            , 0
          );
          
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            
            gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, '  ???? ' || vr_nrcpfcgc || '[' || rw_crapttl.cdcooper || '] ' || rw_crapttl.nrdconta 
                                                          || ' - Telefone repetido (' || NVL(pr_nrdddtfc, 0) || ') ' || NVL(pr_nrtelefo, 0) || ' - ' || sqlerrm );
            
          WHEN OTHERS THEN
            
            RAISE_APPLICATION_ERROR(-20000, 'Erro ao inserir telefone (' || NVL(pr_nrdddtfc, 0) || ').' || NVL(pr_nrtelefo, 0) || sqlerrm);
            
        END;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    DELETE CECRED.CRAPTFC '
                                                      || ' WHERE nrdconta = ' || rw_crapttl.nrdconta
                                                      || '   AND cdcooper = ' || rw_crapttl.cdcooper
                                                      || '   AND idseqttl = ' || rw_crapttl.idseqttl 
                                                      || '   AND nrdddtfc = ' || NVL(pr_nrdddtfc, 0) 
                                                      || '   AND nrtelefo = ' || NVL(pr_nrtelefo, 0) || '; ' );
          
        vr_nrdrowid := getIdLogCabecalho();
            
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Telefone'
                                        ,pr_dsdadant => ' '
                                        ,pr_dsdadatu => TRIM( to_char( pr_nrtelefo, '99999999999' ) ) ) ;
            
            
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'DDD'
                                        ,pr_dsdadant => ' '
                                        ,pr_dsdadatu => TRIM( to_char( pr_nrdddtfc, '99999999999' ) ) ) ;
        
        vr_msgalt := vr_msgalt || 'Add telef(' || pr_det_log || ').' || rw_crapttl.idseqttl || '.ttl,';
        
      END IF;
      
      CLOSE cr_craptfc;
    
    END IF;
    
  END;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0260409';
  vr_cdcooper := 1;
  
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

  OPEN cr_crapdat(vr_cdcooper);
  FETCH cr_crapdat INTO vr_dtmvtolt;
  CLOSE cr_crapdat;
  
  vr_count := 0;
  
  LOOP
    
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                ,pr_des_text => vr_setlinha);
    
    vr_nrdrowid := NULL;
    vr_msgalt   := NULL;
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    
    vr_nrcpfcgc := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2,vr_setlinha,';') ) );
    vr_ddd01    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(3,vr_setlinha,';') ) );
    vr_fone01   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(4,vr_setlinha,';') ) );
    vr_ddd02    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(5,vr_setlinha,';') ) );
    vr_fone02   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(6,vr_setlinha,';') ) );
    vr_ddd03    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(7,vr_setlinha,';') ) );
    vr_fone03   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(8,vr_setlinha,';') ) );
    vr_dddcel01 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(9,vr_setlinha,';') ) );
    vr_celu01   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(10,vr_setlinha,';') ) );
    vr_dddcel02 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(11,vr_setlinha,';') ) );
    vr_celu02   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(12,vr_setlinha,';') ) );
    vr_dddcel03 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(13,vr_setlinha,';') ) );
    vr_celu03   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(14,vr_setlinha,';') ) );
    vr_email    := TRIM( gene0002.fn_busca_entrada(15,vr_setlinha,';') );
    vr_vldrendi := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(16,vr_setlinha,';') ) );
  
    OPEN cr_crapttl(vr_nrcpfcgc, vr_cdcooper);
    FETCH cr_crapttl INTO rw_crapttl;
    
    IF cr_crapttl%NOTFOUND THEN
      
      CLOSE cr_crapttl;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_nrcpfcgc || '     CPF Não encontrado na TTL.');
      
      CONTINUE;
      
    END IF;
    
    CLOSE cr_crapttl;
    
    IF vr_vldrendi > 1 THEN
    
      BEGIN
        
        UPDATE CECRED.Crapttl
          SET tpdrendi##1   = 0
              , vldrendi##1 = 0
              , tpdrendi##2 = 0
              , vldrendi##2 = 0
              , tpdrendi##3 = 0
              , vldrendi##3 = 0
              , tpdrendi##4 = 0
              , vldrendi##4 = 0
              , vlsalari    = vr_vldrendi
              , dsjusren    = ' '
        WHERE nrdconta = rw_crapttl.nrdconta
          and cdcooper = rw_crapttl.cdcooper
          and nrcpfcgc = vr_nrcpfcgc;
          
        IF SQL%ROWCOUNT > 1 THEN
            
          vr_dscritic := 'ERRO - ' || SQL%ROWCOUNT || ' registros atualizados para a conta ' || rw_crapttl.nrdconta || ' referente ao CPF ' || vr_nrcpfcgc;
          RAISE vr_exception2;
            
        END IF;
          
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    UPDATE CECRED.Crapttl SET  '
                                                      || ' tpdrendi##1 = '   || rw_crapttl.tpdrendi##1
                                                      || ' , vldrendi##1 = ' || replace( rw_crapttl.vldrendi##1, ',', '.' )
                                                      || ' , tpdrendi##2 = ' || rw_crapttl.tpdrendi##2
                                                      || ' , vldrendi##2 = ' || replace( rw_crapttl.vldrendi##2, ',', '.' )
                                                      || ' , tpdrendi##3 = ' || rw_crapttl.tpdrendi##3
                                                      || ' , vldrendi##3 = ' || replace( rw_crapttl.vldrendi##3, ',', '.' )
                                                      || ' , tpdrendi##4 = ' || rw_crapttl.tpdrendi##4
                                                      || ' , vldrendi##4 = ' || replace( rw_crapttl.vldrendi##4, ',', '.' )
                                                      || ' , vlsalari = '    || replace( rw_crapttl.vlsalari, ',', '.' )
                                                      || ' , dsjusren = '''  || rw_crapttl.dsjusren || ''' '
                                                      || 'WHERE nrdconta = ' || rw_crapttl.nrdconta
                                                      || ' AND cdcooper = '  || rw_crapttl.cdcooper
                                                      || ' AND nrcpfcgc = '  || vr_nrcpfcgc || '; ' );
        
      EXCEPTION
        WHEN vr_exception2 THEN
          
          RAISE vr_exception;
        
        WHEN OTHERS THEN
          
          vr_dscritic := 'Erro ao atualizar a conta ' || rw_crapttl.nrdconta || ' referente ao CPF ' || vr_nrcpfcgc || ' - ' || sqlerrm;
          RAISE vr_exception;
          
      END;
      
      vr_msgalt := vr_msgalt || 'salario ' || rw_crapttl.idseqttl || '.ttl,';
      
      vr_nrdrowid := getIdLogCabecalho();
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Rendimento principal ttl'
                                      ,pr_dsdadant => TRIM( to_char( rw_crapttl.vlsalari, '999999999D99' ) )
                                      ,pr_dsdadatu => TRIM( to_char( vr_vldrendi, '999999999D99' ) ) );
      
      IF TRIM(rw_crapttl.dsjusren) IS NOT NULL THEN
        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Justificativa Outras Rendas'
                                        ,pr_dsdadant => NVL( TRIM(rw_crapttl.dsjusren), ' ' )
                                        ,pr_dsdadatu => ' ' );
        
        vr_msgalt := vr_msgalt || 'justificativa rend. ' || rw_crapttl.idseqttl || '.ttl,';
        
      END IF;
      
      IF NVL(rw_crapttl.vldrendi##1, 0) > 0 THEN
        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Outros Rendimentos 01'
                                        ,pr_dsdadant => TRIM( to_char( rw_crapttl.vldrendi##1, '999999999D99' ) )
                                        ,pr_dsdadatu => '0,00' ) ;
        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Tipo de Outros Rendimentos 01'
                                        ,pr_dsdadant => TRIM( to_char( rw_crapttl.tpdrendi##1, '999999999' ) )
                                        ,pr_dsdadatu => '0' );
        
        vr_msgalt := vr_msgalt || 'valor rend_01. ' || rw_crapttl.idseqttl || '.ttl,tip.rend_01. ' || rw_crapttl.idseqttl || '.ttl,';
        
      END IF;
      
      IF NVL(rw_crapttl.vldrendi##2, 0) > 0 THEN
        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Outros Rendimentos 02'
                                        ,pr_dsdadant => TRIM( to_char( rw_crapttl.vldrendi##2, '999999999D99' ) )
                                        ,pr_dsdadatu => '0' ) ;
        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Tipo de Outros Rendimentos 02'
                                        ,pr_dsdadant => TRIM( to_char( rw_crapttl.tpdrendi##2, '999999999' ) )
                                        ,pr_dsdadatu => '0' );
        
        vr_msgalt := vr_msgalt || 'valor rend_02. ' || rw_crapttl.idseqttl || '.ttl,tip.rend_02. ' || rw_crapttl.idseqttl || '.ttl,';
        
      END IF;
      
      IF rw_crapttl.vldrendi##3 > 0 THEN
        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Outros Rendimentos 03'
                                        ,pr_dsdadant => TRIM( to_char( rw_crapttl.vldrendi##3, '999999999D99' ) )
                                        ,pr_dsdadatu => '0' ) ;
        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Tipo de Outros Rendimentos 03'
                                        ,pr_dsdadant => TRIM( to_char( rw_crapttl.tpdrendi##3, '999999999' ) )
                                        ,pr_dsdadatu => '0' );
        
        vr_msgalt := vr_msgalt || 'valor rend_03. ' || rw_crapttl.idseqttl || '.ttl,tip.rend_03. ' || rw_crapttl.idseqttl || '.ttl,';
        
      END IF;
      
      IF rw_crapttl.vldrendi##4 > 0 THEN
        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Outros Rendimentos 04'
                                        ,pr_dsdadant => TRIM( to_char( rw_crapttl.vldrendi##4, '999999999D99' ) )
                                        ,pr_dsdadatu => '0' ) ;
        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Tipo de Outros Rendimentos 04'
                                        ,pr_dsdadant => TRIM( to_char( rw_crapttl.tpdrendi##4, '999999999' ) )
                                        ,pr_dsdadatu => '0' );
        
        vr_msgalt := vr_msgalt || 'valor rend_04. ' || rw_crapttl.idseqttl || '.ttl,tip.rend_04. ' || rw_crapttl.idseqttl || '.ttl,';
        
      END IF;
      
    ELSE
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, '  --- ' || vr_nrcpfcgc || ' | ' || rw_crapttl.nrdconta || ' | ' || rw_crapttl.cdcooper || ' Valor de rendimento inferior a R$ 1,00. ' || TRIM( to_char( NVL(vr_vldrendi, 0), '999999999D99' ) ));
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
    END IF;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_ddd01
                     , pr_nrtelefo  => vr_fone01
                     , pr_tptelefo  => 1
                     , pr_det_log   => 'res.01'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_ddd01 || ') ' || vr_fone01 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_ddd02
                     , pr_nrtelefo  => vr_fone02
                     , pr_tptelefo  => 1
                     , pr_det_log   => 'res.02'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_ddd02 || ') ' || vr_fone02 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_ddd03
                     , pr_nrtelefo  => vr_fone03
                     , pr_tptelefo  => 1
                     , pr_det_log   => 'res.03'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_ddd03 || ') ' || vr_fone03 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddcel01
                     , pr_nrtelefo  => vr_celu01
                     , pr_tptelefo  => 2
                     , pr_det_log   => 'cel.01'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddcel01 || ') ' || vr_celu01 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddcel02
                     , pr_nrtelefo  => vr_celu02
                     , pr_tptelefo  => 2
                     , pr_det_log   => 'cel.02'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddcel02 || ') ' || vr_celu02 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddcel03
                     , pr_nrtelefo  => vr_celu03
                     , pr_tptelefo  => 2
                     , pr_det_log   => 'cel.03'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddcel03 || ') ' || vr_celu03 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    IF TRIM(vr_email) IS NOT NULL THEN
      
      OPEN cr_crapcem ( rw_crapttl.cdcooper
                       , rw_crapttl.nrdconta
                       , rw_crapttl.idseqttl
                       , vr_email);
      FETCH cr_crapcem INTO rg_crapcem;
      
      IF cr_crapcem%NOTFOUND THEN
        
        BEGIN
          
          INSERT INTO CECRED.crapcem (
            cdoperad
            , nrdconta
            , dsdemail
            , dtmvtolt
            , hrtransa
            , cdcooper
            , idseqttl
            , dtinsori
            , inprincipal
          ) VALUES (
            1
            , rw_crapttl.nrdconta
            , vr_email
            , vr_dtmvtolt
            , gene0002.fn_busca_time
            , rw_crapttl.cdcooper
            , rw_crapttl.idseqttl
            , SYSDATE
            , 0
          );
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  DELETE CECRED.CRAPCEM '
                                                      || ' WHERE nrdconta = ' || rw_crapttl.nrdconta
                                                      || '   AND cdcooper = ' || rw_crapttl.cdcooper
                                                      || '   AND idseqttl = ' || rw_crapttl.idseqttl 
                                                      || '   AND dsdemail = ''' || vr_email || '''; ' );
          
          vr_nrdrowid := getIdLogCabecalho();
      
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                          ,pr_nmdcampo => 'E-mail'
                                          ,pr_dsdadant => ' '
                                          ,pr_dsdadatu => TRIM( vr_email ) );
          
          vr_msgalt := vr_msgalt || 'Add e-mail.' || rw_crapttl.idseqttl || '.ttl,';
          
        EXCEPTION
          WHEN OTHERS THEN
            
            CLOSE cr_crapcem;
            vr_dscritic := 'Erro ao cadastrar o e-mail: ' || vr_email || ' - ' || sqlerrm;
            
        END;
        
      END IF;
      
      CLOSE cr_crapcem;
    
    END IF;
    
    IF TRIM(vr_msgalt) IS NOT NULL THEN
      
      CADASTRO.registrarAlteracaoAssociado(pr_cdcooper => rw_crapttl.cdcooper
                                          ,pr_nrdconta => rw_crapttl.nrdconta
                                          ,pr_dtaltera => vr_dtmvtolt
                                          ,pr_cdoperad => 1
                                          ,pr_dsaltera => 'RITM0260409 - Enriquecimento de base Boa Vista, outubro de 2022. ' || vr_msgalt
                                          ,pr_tpaltera => 2
                                          ,pr_flgctitg => 3
                                          ,pr_dtmvtolt => vr_dtmvtolt);
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_nrcpfcgc || ' | ' || rw_crapttl.nrdconta || ' | ' || rw_crapttl.cdcooper || ' - ' || vr_msgalt);
    
    ELSE
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, '    ### ' || vr_nrcpfcgc || ' | ' || rw_crapttl.nrdconta || ' | ' || rw_crapttl.cdcooper || ' - CPF SEM ALTERAÇÕES NO ARQUIVO. ' );
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
    END IF;
    
    vr_count := vr_count + 1;
    
    if rw_crapttl.qtd_contas > 0 then
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, '  ****** ' || vr_nrcpfcgc || ' | ' || rw_crapttl.nrdconta || ' | ' || rw_crapttl.cdcooper || ' QTD outras contas: ' || rw_crapttl.qtd_contas);
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
    end if;
    
    IF vr_count > 500 THEN
      
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

