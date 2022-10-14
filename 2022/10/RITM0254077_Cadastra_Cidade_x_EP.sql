DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0254077_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0254077_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'RITM0254077_relatorio.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  CURSOR cr_tbgen_cid_atuacao_coop ( pr_cdcooper IN CECRED.crapttl.CDCOOPER%TYPE
                                  ,  pr_cdcidade IN CECRED.tbgen_cid_atuacao_coop.CDCIDADE%TYPE) IS
    SELECT c.cdcooper,
      c.cdcidade,
      c.progress_recid,
      c.idautoriza_ente_pub,
      c.dsata_avaliacao
    FROM CECRED.tbgen_cid_atuacao_coop c
    WHERE c.cdcooper = pr_cdcooper
      AND c.cdcidade = pr_cdcidade;
  
  rw_cid_coop    cr_tbgen_cid_atuacao_coop%ROWTYPE;
  
  CURSOR cr_crapmun ( pr_dscidade  IN CECRED.crapmun.DSCIDADE%TYPE
                    , pr_cdestado  IN CECRED.crapmun.CDESTADO%TYPE
                    , pr_dscidesp  IN CECRED.crapmun.DSCIDESP%TYPE) IS
    SELECT m.cdcidade
    FROM CECRED.crapmun m
    WHERE UPPER( m.cdestado ) = UPPER( pr_cdestado )
      AND ( 
        UPPER( m.dscidade )    = UPPER( pr_dscidade )
        OR UPPER( m.dscidesp ) = UPPER( pr_dscidesp )
      );
  
  rw_crapmun     cr_crapmun%ROWTYPE;
  
  CURSOR cr_tbcc_associados(pr_cdcooper IN NUMBER, pr_cdcidade IN NUMBER) IS
    SELECT nrdconta
    FROM tbcc_associados
    WHERE cdcooper          = pr_cdcooper
      AND idgrupo_municipal = pr_cdcidade;
  
  rw_tbcc_associados cr_tbcc_associados%ROWTYPE;
  
  vr_idseqttl    CECRED.crapttl.IDSEQTTL%TYPE;
  vr_cdcooper    CECRED.crapass.CDCOOPER%TYPE;
  vr_dscidade    CECRED.crapmun.DSCIDADE%TYPE;
  vr_dscidesp    CECRED.crapmun.DSCIDESP%TYPE;
  vr_dsestado    CECRED.crapmun.CDESTADO%TYPE;
  vr_nmcooper    VARCHAR(60);
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0254077';
  
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
    vr_nmcooper := CASE WHEN vr_cdcooper = 7 THEN 'CREDCREA' ELSE 'EVOLUA' END;
    vr_dscidesp := UPPER( TRIM( gene0002.fn_busca_entrada(2,vr_setlinha,';') ) );
    vr_dsestado := UPPER( TRIM( gene0002.fn_busca_entrada(3,vr_setlinha,';') ) );
    
    vr_dscidade := GENE0007.fn_caract_acento( pr_texto     => vr_dscidesp
                                            , pr_insubsti  => 1);
    
    OPEN cr_crapmun(vr_dscidade, vr_dsestado, vr_dscidesp);
    FETCH cr_crapmun INTO rw_crapmun;
    
    IF cr_crapmun%NOTFOUND THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Não encontrada;Cidade / UF NÃO encontrada no Aimaro;' || vr_dscidade || ';' || vr_dsestado);
      
    ELSE
      
      OPEN cr_tbgen_cid_atuacao_coop(pr_cdcooper => vr_cdcooper
                                   , pr_cdcidade => rw_crapmun.cdcidade);
      FETCH cr_tbgen_cid_atuacao_coop INTO rw_cid_coop;
      
      IF cr_tbgen_cid_atuacao_coop%NOTFOUND THEN
        
        OPEN cr_tbcc_associados(vr_cdcooper, rw_crapmun.cdcidade);
        FETCH cr_tbcc_associados INTO rw_tbcc_associados;
            
        IF cr_tbcc_associados%FOUND THEN
              
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Não Permitido;' || vr_nmcooper || '. Municipio vinculado a um ente publico municipal. Alteracao nao permitida;' || vr_dscidade || ';' || vr_dsestado);
          
        ELSE
          
          INSERT INTO CECRED.tbgen_cid_atuacao_coop (
            cdcidade
            , cdcooper
            , idautoriza_ente_pub
            , dsata_avaliacao
          ) VALUES (
            rw_crapmun.cdcidade
            , vr_cdcooper
            , 1
            , CASE WHEN vr_cdcooper = 7 THEN '30 AGE 28/07/2020' ELSE '29 AGE 08/04/2022' END
          );
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    DELETE CECRED.tbgen_cid_atuacao_coop '
                                                          || ' WHERE cdcooper = ' || vr_cdcooper
                                                          || '   AND cdcidade = ' || rw_crapmun.cdcidade || '; ' );
            
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'OK;' || SQL%ROWCOUNT || ' registros Inseridos para Cooperativa: ' || vr_nmcooper
                                                        || ';' || vr_dscidade || ';' || vr_dsestado );
        END IF;
        
        CLOSE cr_tbcc_associados;
        
      ELSE
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Cadastro Pré-Existente;' || vr_nmcooper || ' - Cidade / UF já está cadastrada no Aimaro. Nro. ATA: ' || rw_cid_coop.dsata_avaliacao || ';' || vr_dscidade || ';' || vr_dsestado );
        
      END IF;
      
      CLOSE cr_tbgen_cid_atuacao_coop;
      
    END IF;
    
    CLOSE cr_crapmun;
    
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
