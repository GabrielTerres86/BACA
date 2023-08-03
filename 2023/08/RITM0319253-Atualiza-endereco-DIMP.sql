DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0319253_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0319253_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'RITM0319253_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_nrcpfcgc           CECRED.crapass.NRCPFCGC%TYPE;
  vr_dtmvtolt           CECRED.crapalt.DTALTERA%TYPE;
  vr_comments           VARCHAR2(2000);
  vr_msgalt             VARCHAR2(1000);
  vr_hrtransa           CECRED.craplgm.HRTRANSA%TYPE;
  vr_nrdrowid           ROWID;
  
  vr_countCta           NUMBER(3);
  vr_lastCta            VARCHAR2(50);
  vr_chave              VARCHAR2(50);
  
  vr_cdseqinc           CECRED.crapenc.CDSEQINC%TYPE;
  vr_dsendere           CECRED.crapenc.DSENDERE%TYPE;
  vr_nrendere           CECRED.crapenc.NRENDERE%TYPE;
  vr_complend           CECRED.crapenc.COMPLEND%TYPE;
  vr_nmbairro           CECRED.crapenc.NMBAIRRO%TYPE;
  vr_nmcidade           CECRED.crapenc.NMCIDADE%TYPE;
  vr_cdufende           CECRED.crapenc.CDUFENDE%TYPE;
  vr_nrcepend           CECRED.crapenc.NRCEPEND%TYPE;
  vr_rowidenc           ROWID;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_nextseqenc(pr_cdcooper  CECRED.Crapenc.CDCOOPER%TYPE
                     , pr_nrdconta  CECRED.Crapenc.NRDCONTA%TYPE
                     , pr_idseqttl  CECRED.Crapenc.IDSEQTTL%TYPE) IS
    SELECT (MAX(en.cdseqinc) + 1) cdseqinc_next
    FROM CECRED.crapenc en
    WHERE en.cdcooper = pr_cdcooper
      AND en.nrdconta = pr_nrdconta
      AND en.idseqttl = pr_idseqttl;
  
  CURSOR cr_crapcop (pr_nmrescop IN CECRED.crapcop.NMRESCOP%TYPE) IS
    SELECT c.cdcooper
    FROM CECRED.Crapcop c
    WHERE c.nmrescop = TRIM( UPPER( pr_nmrescop ) );
  
  CURSOR cr_crapttl (pr_nrcpfcgc  IN CECRED.crapttl.NRCPFCGC%TYPE ) IS
    SELECT E.ROWID     rowid_enc
      , T.CDCOOPER
      , T.NRDCONTA
      , T.NRCPFCGC
      , T.IDSEQTTL
      , A.DTADMISS
      , A.DTDEMISS
      , E.tpendass
      , E.cdseqinc
      , E.dsendere
      , E.nrendere
      , E.complend
      , E.nmbairro
      , E.nmcidade
      , E.cdufende
      , E.nrcepend
      , E.incasprp
      , E.nranores
      , E.vlalugue
      , E.nrcxapst
      , E.dtaltenc
      , E.dtinires
      , E.nrdoapto
      , E.cddbloco
      , E.progress_recid
      , E.idorigem
    FROM CRAPTTL T
    LEFT JOIN CRAPENC E ON T.CDCOOPER = E.CDCOOPER
                           AND T.NRDCONTA = E.NRDCONTA
                           AND T.IDSEQTTL = E.IDSEQTTL
                           AND NVL(E.TPENDASS, 10) = 10
    JOIN CRAPASS A ON T.CDCOOPER = A.CDCOOPER
                      AND T.NRDCONTA = A.NRDCONTA
    WHERE T.NRCPFCGC = pr_nrcpfcgc
    ORDER BY t.nrcpfcgc, t.cdcooper, t.nrdconta, t.idseqttl;
  
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
            , tpaltera = pr_tpaltera
        WHERE nrdconta = pr_nrdconta
          AND cdcooper = pr_cdcooper
          AND dtaltera = vr_dtmvtolt;
            
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '   UPDATE cecred.crapalt '
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
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0319253';
  
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
                                
    vr_comments := ' [1] CPF;     [2] Logradouro;   [3] Numero; [4] Complemento; [5] Bairro;       [6] Cidade;    [7] UF; [8] Cep ';
    vr_comments := ' 00004148916; MANOEL PIZZOLATI;   ;         BL A 4 AP 12;    JARDIM ATLANTICO; FLORIANOPOLIS; SC;     88095360';
    
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    
    vr_nrcpfcgc := CECRED.gene0002.fn_char_para_number( TRIM(                    gene0002.fn_busca_entrada(1, vr_setlinha, ';') ) );
    vr_dsendere := UPPER( SUBSTR( GENE0007.fn_caract_acento(pr_texto => TRIM(    gene0002.fn_busca_entrada(2, vr_setlinha, ';') ) ), 1, 50) );
    vr_nrendere := CECRED.gene0002.fn_char_para_number( TRIM(                    gene0002.fn_busca_entrada(3, vr_setlinha, ';') ) );
    vr_complend := UPPER( SUBSTR( GENE0007.fn_caract_acento(pr_texto => TRIM(    gene0002.fn_busca_entrada(4, vr_setlinha, ';') ) ), 1, 60) );
    vr_nmbairro := UPPER( SUBSTR( GENE0007.fn_caract_acento(pr_texto => TRIM(    gene0002.fn_busca_entrada(5, vr_setlinha, ';') ) ), 1, 50) );
    vr_nmcidade := UPPER( SUBSTR( GENE0007.fn_caract_acento(pr_texto => TRIM(    gene0002.fn_busca_entrada(6, vr_setlinha, ';') ) ), 1, 50) );
    vr_cdufende := UPPER( SUBSTR( GENE0007.fn_caract_acento(pr_texto => TRIM(    gene0002.fn_busca_entrada(7, vr_setlinha, ';') ) ), 1, 2) );
    vr_nrcepend := CECRED.gene0002.fn_char_para_number( TRIM(                    gene0002.fn_busca_entrada(8, vr_setlinha, ';') ) );
    
    OPEN cr_crapttl(pr_nrcpfcgc => vr_nrcpfcgc);
    FETCH cr_crapttl INTO rg_crapttl;
    
    IF cr_crapttl%NOTFOUND THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Alerta;' || ' *** Não foi encontrado registro de conta na TTL para atualização do endereço. ;'
                                                    || vr_nrcpfcgc 
      );
      
      CLOSE cr_crapttl;
      vr_comments := 'Se não encontrar um registro n TTL, passa para o próximo registro registrando o alerta em Log';
      
      CONTINUE;
      
    END IF;
    
    vr_countCta := 0;
    vr_lastCta  := null;
    vr_chave    := null;
    
    LOOP
      
      vr_comments := 'CONTROLAR PARA QUE A INCLUSÃO / ATUALIZAÇÃO ATUE SOMENTE NA PRIMEIRA CONTA ENCONTRADA.';
      vr_comments := 'PARA AS DEMAIS, INCLUIR APENAS O REGISTRO DA "ALTERA" E "VERLOG", POIS O CENTRALIZADO IRÁ REPLICAR OS DADOS PARA AS OUTRAS CONTAS DO COOPERADO.';
      
      vr_chave := rg_crapttl.nrdconta || '.' || rg_crapttl.cdcooper;
      
      IF NVL(vr_lastCta, ' ') = vr_chave AND NVL(vr_countCta, 0) = 1 THEN
        vr_countCta := 1;
      ELSE
        vr_countCta := vr_countCta + 1;
      END IF;
      
      vr_lastCta := vr_chave;
      
      IF vr_countCta = 1 THEN
        
        IF TRIM(rg_crapttl.rowid_enc) IS NULL THEN
          
          vr_comments := 'INCLUIR ENDEREÇO PARA AQUELES QUE NÃO TEM.';
          
          OPEN cr_nextseqenc(rg_crapttl.cdcooper, rg_crapttl.nrdconta, rg_crapttl.idseqttl);
          FETCH cr_nextseqenc INTO vr_cdseqinc;
          CLOSE cr_nextseqenc;
          
          vr_rowidenc := NULL;
          
          INSERT INTO CECRED.crapenc (
            cdcooper
            , nrdconta
            , idseqttl
            , tpendass
            , cdseqinc
            , dsendere
            , nrendere
            , complend
            , nmbairro
            , nmcidade
            , cdufende
            , nrcepend
          ) VALUES (
            rg_crapttl.cdcooper
            , rg_crapttl.nrdconta
            , rg_crapttl.idseqttl
            , 10
            , NVL(vr_cdseqinc, 1)
            , vr_dsendere
            , vr_nrendere
            , vr_complend
            , vr_nmbairro
            , vr_nmcidade
            , vr_cdufende
            , vr_nrcepend
          ) RETURNING ROWID INTO vr_rowidenc;
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE CECRED.Crapenc WHERE ROWID = ''' || vr_rowidenc || '''; ');
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Informativo;' || ' INCLUSÃO de endereço para o cooperado ' || vr_chave || ' ;'
                                                        || vr_nrcpfcgc 
          );
          
        ELSE
          
          vr_comments := 'ATUALIZAR ENDEREÇO PARA AQUELES QUE JÁ POSSUEM ENDEREÇO.';
          
          UPDATE CECRED.Crapenc
            SET dsendere = vr_dsendere
              , nrendere = NVL(vr_nrendere, 0)
              , complend = NVL(vr_complend, ' ')
              , nmbairro = vr_nmbairro
              , nmcidade = vr_nmcidade
              , cdufende = vr_cdufende
              , nrcepend = vr_nrcepend
          WHERE ROWID = rg_crapttl.rowid_enc;
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.Crapenc '
                                                       || ' SET dsendere = ''' || rg_crapttl.dsendere || ''' '
                                                       || '   , nrendere = '   || NVL( TO_CHAR(rg_crapttl.nrendere), 'NULL' )
                                                       || '   , complend = ''' || rg_crapttl.complend || ''' '
                                                       || '   , nmbairro = ''' || rg_crapttl.nmbairro || ''' '
                                                       || '   , nmcidade = ''' || rg_crapttl.nmcidade || ''' '
                                                       || '   , cdufende = ''' || rg_crapttl.cdufende || ''' '
                                                       || '   , nrcepend = '   || NVL( TO_CHAR(rg_crapttl.nrcepend), 'NULL' )
                                                       || ' WHERE ROWID = '''  || rg_crapttl.rowid_enc || '''; ');
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Informativo;' || ' Atualização de endereço para o cooperado ' || vr_chave || ' ;'
                                                        || vr_nrcpfcgc 
          );
          
        END IF;
        
      ELSE
        
        vr_comments := 'REGISTRAR APENAS ALTERA E VERLOG, POIS TRATA-SE DE UMA OUTRA CONTA DO MESMO CPF.';
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Informativo;' || ' Registrado APENAS Altera e Verlog para a "conta.cooperativa" do cooperado ' || vr_chave || ' ;'
                                                      || vr_nrcpfcgc 
        );
        
      END IF;
      
      vr_comments := 'REGISTRAR ALTERA E VERLOG. **** SEM REGISTRO DE ATUALIZAÇÃO CADASTRAL - tpaltera = 2.';
      
      vr_msgalt   := 'RITM0319253 - Atualização de base enriquecida BVS, FDR nº 700 (Ofício nº 12.324/23) e regulatório DIMP.';
      vr_dtmvtolt := SISTEMA.datascooperativa(rg_crapttl.cdcooper).dtmvtolt;
      
      registraAltera(
        pr_cdcooper   => rg_crapttl.cdcooper
        , pr_nrdconta => rg_crapttl.nrdconta
        , pr_idseqttl => rg_crapttl.idseqttl
        , pr_tpaltera => 2
      );
      
      vr_hrtransa := gene0002.fn_busca_time();
          
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
      VALUES(rg_crapttl.cdcooper
       ,1
       ,null
       ,'Script'
       ,vr_msgalt
       ,vr_dtmvtolt
       ,1
       ,vr_hrtransa
       ,rg_crapttl.idseqttl
       ,'JOB'
       ,rg_crapttl.nrdconta)
      RETURNING ROWID INTO vr_nrdrowid;
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => 'crapenc.cdseqinc'
                                      ,pr_dsdadant  => NVL( TRIM( TO_CHAR(rg_crapttl.cdseqinc) ), ' ' )
                                      ,pr_dsdadatu  => NVL( TRIM( TO_CHAR( NVL(vr_cdseqinc, 1) ) ), ' ' )
                                      );
          
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => 'crapenc.dsendere'
                                      ,pr_dsdadant  => NVL( TRIM( rg_crapttl.dsendere ), ' ' )
                                      ,pr_dsdadatu  => NVL( TRIM( vr_dsendere ), ' ' )
                                      );
          
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => 'crapenc.nrendere'
                                      ,pr_dsdadant  => NVL( TRIM( TO_CHAR(rg_crapttl.nrendere) ), ' ' )
                                      ,pr_dsdadatu  => NVL( TRIM( TO_CHAR(vr_nrendere) ), ' ' )
                                      );
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => 'crapenc.complend'
                                      ,pr_dsdadant  => NVL( TRIM( rg_crapttl.complend ), ' ' )
                                      ,pr_dsdadatu  => NVL( TRIM( vr_complend ), ' ' )
                                      );
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => 'crapenc.nmbairro'
                                      ,pr_dsdadant  => NVL( TRIM( rg_crapttl.nmbairro ), ' ' )
                                      ,pr_dsdadatu  => NVL( TRIM( vr_nmbairro ), ' ' )
                                      );
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => 'crapenc.nmcidade'
                                      ,pr_dsdadant  => NVL( TRIM( rg_crapttl.nmcidade ), ' ' )
                                      ,pr_dsdadatu  => NVL( TRIM( vr_nmcidade ), ' ' )
                                      );
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => 'crapenc.cdufende'
                                      ,pr_dsdadant  => NVL( TRIM( rg_crapttl.cdufende ), ' ' )
                                      ,pr_dsdadatu  => NVL( TRIM( vr_cdufende ), ' ' )
                                      );
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => 'crapenc.nrcepend'
                                      ,pr_dsdadant  => NVL( TRIM( TO_CHAR(rg_crapttl.nrcepend) ), ' ' )
                                      ,pr_dsdadatu  => NVL( TRIM( TO_CHAR(vr_nrcepend) ), ' ' )
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
      
      FETCH cr_crapttl INTO rg_crapttl;
      EXIT WHEN cr_crapttl%NOTFOUND;
      
    END LOOP;
    
    CLOSE cr_crapttl;
    
    vr_comments := 'São executadas 10 DMLs em cada loop, por isso o incremento de 10 em 10.';
    vr_count := vr_count + 10;
    IF vr_count > 500 THEN
      
      COMMIT;
      
      vr_count := 0;
      
    END IF;
    
    vr_comments := 'São criadas 4 linhas de ROLLBACK em cada loop, por isso o incremento de 4 em 4.';
    vr_count_file := vr_count_file + 4;
    
    vr_comments := 'Define a cada quantas linhas faz a quebra dos arquivos de ROLLBACK';
    IF vr_count_file > 5000 THEN
      
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
