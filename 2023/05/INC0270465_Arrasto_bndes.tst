PL/SQL Developer Test script 3.0
230
DECLARE  

  vr_dtrefere    DATE := to_date('30/04/2023','DD/MM/RRRR');
  vr_nmarquiv    VARCHAR2(100) := 'Arrasto_BNDES_202304.csv';
  vr_diretorio   VARCHAR2(500);
  vr_cdcritic    NUMBER;
  vr_dscritic    VARCHAR2(1000);
  vr_des_erro    VARCHAR2(1000);
  vr_dslinha     VARCHAR2(6000);
  vr_dsrollback  VARCHAR2(4000);
  vr_arquivo     utl_file.file_type;
  vr_arquivo_log utl_file.file_type;
  vr_arquivo_rollback utl_file.file_type;
  vr_excerro     EXCEPTION;
  vr_linha       NUMBER := 0;
  vr_dados       cecred.GENE0002.typ_split;
  
  
  vr_cdcooper    NUMBER(10);
  vr_nrdconta    NUMBER(10);
  vr_nrctremp    NUMBER(10);
  vr_innivris_atual VARCHAR2(2);
  vr_innivris_novo  VARCHAR2(2);
  
  CURSOR cr_crapris(pr_cdcooper NUMBER
                   ,pr_dtrefere DATE
                   ,pr_nrdconta NUMBER
                   ,pr_nrctremp NUMBER) IS
    SELECT r.rowid,
           r.innivris,
           r.innivori
      FROM crapris r
     WHERE r.cdcooper = pr_cdcooper
       AND r.dtrefere = pr_dtrefere
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp
       AND r.dsinfaux = 'BNDES';
       
  rw_crapris cr_crapris%ROWTYPE;
  
  PROCEDURE registrarVERLOG(pr_cdcooper IN cecred.crawepr.cdcooper%TYPE
                           ,pr_nrdconta IN cecred.crawepr.nrdconta%TYPE
                           ,pr_dstransa IN VARCHAR2
                           ,pr_dsCampo  IN VARCHAR
                           ,pr_antes    IN VARCHAR2
                           ,pr_depois   IN VARCHAR2) IS
    vr_dstransa       cecred.craplgm.dstransa%TYPE;
    vr_descitem       cecred.craplgi.nmdcampo%TYPE;
    vr_nrdrowid       ROWID;
    vr_risco_anterior VARCHAR2(10);
    
  BEGIN
    
    vr_dstransa := pr_dstransa;
  
    cecred.GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_dstransa => vr_dstransa,
                                pr_dscritic => '',
                                pr_cdoperad => '1',
                                pr_dsorigem => 'SCRIPT',
                                pr_dttransa => TRUNC(SYSDATE),
                                pr_flgtrans => 0,
                                pr_hrtransa => cecred.gene0002.fn_busca_time,
                                pr_idseqttl => 1,
                                pr_nmdatela => '',
                                pr_nrdrowid => vr_nrdrowid);
                                
    IF TRIM(pr_dsCampo) IS NOT NULL THEN
      cecred.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => pr_dsCampo,
                                       pr_dsdadant => pr_antes,
                                       pr_dsdadatu => pr_depois);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
  END registrarVERLOG;
  
  PROCEDURE pc_abrir_arquivos IS
  BEGIN
    sistema.abrirArquivo(pr_nmdireto => vr_diretorio,
                         pr_nmarquiv => 'Arrasto_BNDES_'||to_char(SYSDATE,'RRRRMMDD')||'.log',
                         pr_tipabert => 'A',
                         pr_utlfileh => vr_arquivo_log,
                         pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Arquivo contas.txt não encontrado.';
      RAISE vr_excerro;
    END IF;
    
    sistema.abrirArquivo(pr_nmdireto => vr_diretorio,
                         pr_nmarquiv => 'rollback_Arrasto_BNDES_'||to_char(SYSDATE,'RRRRMMDD')||'.log',
                         pr_tipabert => 'A',
                         pr_utlfileh => vr_arquivo_rollback,
                         pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Arquivo contas.txt não encontrado.';
      RAISE vr_excerro;
    END IF;
  
  END;    
  
  PROCEDURE pc_fechar_arquivos IS
  BEGIN
    sistema.fecharArquivo(pr_utlfileh => vr_arquivo);
    sistema.fecharArquivo(pr_utlfileh => vr_arquivo_log);
    sistema.fecharArquivo(pr_utlfileh => vr_arquivo_rollback);
  END;  
  
  
  PROCEDURE pc_gera_log(pr_tipo VARCHAR2 DEFAULT 'L',
                        pr_dsmensagen VARCHAR2) IS
  
    vr_utlfileh   utl_file.file_type;
    vr_dsmensagen VARCHAR2(4000);
  BEGIN
    IF pr_tipo = 'R' THEN
      vr_utlfileh := vr_arquivo_rollback;
      vr_dsmensagen := pr_dsmensagen;
    ELSE
      vr_utlfileh := vr_arquivo_log;
      vr_dsmensagen := to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' -> '||pr_dsmensagen;
    END IF;    
    sistema.escrevelinhaarquivo(pr_utlfileh => vr_utlfileh, 
                                pr_des_text => vr_dsmensagen);
  
  END;    
  

BEGIN
  dbms_output.enable(buffer_size => NULL);  
  vr_diretorio := sistema.obterParametroSistema(pr_nmsistem => 'CRED'
                                               ,pr_cdacesso => 'ROOT_MICROS') || 'cpd/bacas/RISCO/BNDES';
                                               
  pc_abrir_arquivos;
  
  pc_gera_log(pr_dsmensagen => 'Iniciando Script'||chr(13));

  sistema.abrirArquivo(pr_nmdireto => vr_diretorio,
                       pr_nmarquiv => vr_nmarquiv,
                       pr_tipabert => 'R',
                       pr_utlfileh => vr_arquivo,
                       pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Arquivo contas.txt não encontrado.';
    RAISE vr_excerro;
  END IF;

  LOOP
    IF utl_file.IS_OPEN(vr_arquivo) THEN
      BEGIN
        vr_linha := vr_linha + 1;                
        sistema.leituraLinhaArquivo(pr_utlfileh => vr_arquivo
                                   ,pr_des_text => vr_dslinha);
      
        vr_dslinha := REPLACE(REPLACE(TRIM(vr_dslinha),chr(13)),chr(10));
        vr_dados := cecred.GENE0002.fn_quebra_string(pr_string => vr_dslinha
                                                    ,pr_delimit => ';');
        pc_gera_log(pr_dsmensagen => 'Processando Linha:'||vr_linha||' -> '||vr_dslinha);
        
        IF vr_dados.COUNT > 0 AND vr_linha > 1 THEN
          
          vr_cdcooper := vr_dados(1);
          vr_nrdconta := vr_dados(2);
          vr_nrctremp := vr_dados(3);
          vr_innivris_atual := vr_dados(4);
          vr_innivris_Novo := vr_dados(5);
          
          rw_crapris := NULL;
          OPEN cr_crapris(pr_cdcooper => vr_cdcooper
                         ,pr_dtrefere => vr_dtrefere
                         ,pr_nrdconta => vr_nrdconta
                         ,pr_nrctremp => vr_nrctremp
                         );
          FETCH cr_crapris INTO rw_crapris;
          CLOSE cr_crapris;
          
          IF rw_crapris.rowid IS NOT NULL THEN
            
            UPDATE crapris r
               SET r.innivris = risc0004.fn_traduz_nivel_risco(vr_innivris_Novo),
                   r.innivori = rw_crapris.innivris
             WHERE r.rowid = rw_crapris.rowid;
                          
             vr_dsrollback := 'UPDATE crapris r SET r.innivris = '''||rw_crapris.innivris||''', r.innivori = '''||rw_crapris.innivori||''' WHERE r.rowid = '''||rw_crapris.rowid||''';';
             pc_gera_log( pr_tipo       => 'R',
                          pr_dsmensagen => vr_dsrollback);
                          
             registrarVERLOG( pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => vr_nrdconta
                             ,pr_dstransa => 'Alterado risco final do contrato '||vr_nrctremp
                             ,pr_dsCampo  => 'CRAPRIS.innivris'
                             ,pr_antes    => rw_crapris.innivris 
                             ,pr_depois   => vr_innivris_Novo);
            
            pc_gera_log(pr_dsmensagen => ' - Alterado risco de '||risc0004.fn_traduz_risco(rw_crapris.innivris) ||' para '||vr_innivris_Novo);    
            
          ELSE
            pc_gera_log(pr_dsmensagen => ' - Operacao nao encontrada na central de risco');    
          END IF;
          
        END IF;      
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          EXIT;
      END;
    END IF;
  END LOOP;
  
  COMMIT;

  pc_gera_log(pr_dsmensagen => 'Script finalizado');
  pc_fechar_arquivos;
  

EXCEPTION
  WHEN vr_excerro THEN
    ROLLBACK;
    pc_gera_log(pr_dsmensagen => 'Erro Geral no Script. Erro: ' || vr_dscritic);
    pc_gera_log(pr_dsmensagen => 'Efetuado Rollback.');
    pc_fechar_arquivos;
    
  WHEN OTHERS THEN
    ROLLBACK;
    pc_gera_log(pr_dsmensagen => 'Erro Geral no Script. Erro: ' || SubStr(SQLERRM, 1, 255));
    pc_gera_log(pr_dsmensagen => 'Efetuado Rollback.');
    pc_fechar_arquivos;
    
END;
0
1
pr_dsnivris
