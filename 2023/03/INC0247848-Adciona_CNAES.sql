DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0247848_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0247848_script_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'INC0247848_relatorio_exec.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arquiv2        utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  TYPE TP_CNAE IS RECORD (
    cdcnae       CECRED.TBGEN_CNAE.CDCNAE%TYPE
    , dscnae     CECRED.TBGEN_CNAE.DSCNAE%TYPE
    , flserasa   CECRED.TBGEN_CNAE.FLSERASA%TYPE
    , vlrrisco   CECRED.TBGEN_CNAE.VLRRISCO%TYPE
  );
  
  TYPE TP_CNAES IS TABLE OF TP_CNAE INDEX BY BINARY_INTEGER;
  vtCnaes           TP_CNAES;
  
  vr_nrdrowid       ROWID;
  vr_dscritic       VARCHAR2(2000);
  vr_mesref         VARCHAR2(10);
  vr_dtmvtolt       DATE := SISTEMA.datascooperativa(3).dtmvtolt;
  vr_exception      EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0247848';
  
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
  
  vtCnaes(1).cdcnae    := 4541206;
  vtCnaes(1).dscnae    := 'Comercio a varejo de pecas e acessorios novos para motocicletas e motonetas';
  vtCnaes(1).flserasa  := 1;
  vtCnaes(1).vlrrisco  := 3;
  
  vtCnaes(2).cdcnae    := 1610204;
  vtCnaes(2).dscnae    := 'Serrarias sem desdobramento de madeira em bruto - resserragem';
  vtCnaes(2).flserasa  := 1;
  vtCnaes(2).vlrrisco  := 1;
  
  vtCnaes(3).cdcnae    := 6203100;
  vtCnaes(3).dscnae    := 'Desenvolvimento e licenciamento de programas de computador nao customizaveis';
  vtCnaes(3).flserasa  := 1;
  vtCnaes(3).vlrrisco  := 1;
  
  vtCnaes(4).cdcnae    := 1610205;
  vtCnaes(4).dscnae    := 'Servico de tratamento de madeira realizado sob contrato';
  vtCnaes(4).flserasa  := 1;
  vtCnaes(4).vlrrisco  := 1;
  
  vtCnaes(5).cdcnae    := 4713004;
  vtCnaes(5).dscnae    := 'Lojas de departamentos ou magazines, exceto lojas francas (duty free)';
  vtCnaes(5).flserasa  := 1;
  vtCnaes(5).vlrrisco  := 2;
  
  vtCnaes(6).cdcnae    := 4713005;
  vtCnaes(6).dscnae    := 'Lojas francas (duty free) de aeroportos, portos e em fronteiras terrestres';
  vtCnaes(6).flserasa  := 1;
  vtCnaes(6).vlrrisco  := 2;
  
  vtCnaes(7).cdcnae    := 5231103;
  vtCnaes(7).dscnae    := 'Gestao de terminais aquaviarios';
  vtCnaes(7).flserasa  := 1;
  vtCnaes(7).vlrrisco  := 2;
  
  vtCnaes(8).cdcnae    := 6438799;
  vtCnaes(8).dscnae    := 'Outras instituicoes de intermediacao nao monetaria nao especificadas anteriormente';
  vtCnaes(8).flserasa  := 1;
  vtCnaes(8).vlrrisco  := 3;
  
  FOR idx IN vtCnaes.FIRST..vtCnaes.LAST LOOP
    
    BEGIN
      
      INSERT INTO CECRED.TBGEN_CNAE (
        cdcnae
        , dscnae
        , flserasa
        , vlrrisco
      ) VALUES(
        vtCnaes(idx).cdcnae
        , vtCnaes(idx).dscnae
        , vtCnaes(idx).flserasa
        , vtCnaes(idx).vlrrisco
      );
    
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE CECRED.TBGEN_CNAE WHERE cdcnae = ' || vtCnaes(idx).cdcnae || '; ');
      
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'CNAE já existente na tabela: ' || vtCnaes(idx).cdcnae || '.');
        
      WHEN OTHERS THEN
        
        vr_dscritic := 'Erro ao inserir CNAE ' || vtCnaes(idx).cdcnae || ': ' || SQLERRM;
        RAISE vr_exception;
        
    END;
    
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
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
