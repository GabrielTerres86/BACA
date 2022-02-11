declare 
  
  vr_nmdireto    VARCHAR2(100);
  vr_nmarquiv    VARCHAR2(50) := 'estorna_pagamento_consignado.csv';  
  vr_nmarqbkp    VARCHAR2(50) := 'valida_estorno.csv';
  
  vr_input_file  UTL_FILE.FILE_TYPE;
  vr_texto_completo  VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_contlinha   INTEGER := 0;  
  vr_crapalt_progress_recid  VARCHAR2(30);
  vr_ind_arquiv      utl_file.file_type;  

---------
  vr_cdcooper NUMBER;
  vr_nrdconta NUMBER;
  vr_nrctremp NUMBER;  
  vr_des_reto VARCHAR(10);
  vr_tab_erro gene0001.typ_tab_erro;

-------------------------

  vr_des_xml         CLOB := NULL;
  vr_des_alt         CLOB := NULL;
  vr_des_ret         CLOB := NULL;
  vr_setlinha    VARCHAR2(10000);
  vr_cdcritic  crapcri.cdcritic%TYPE;
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_exc_saida   EXCEPTION;

  PROCEDURE pc_escreve_alt(pr_des_dados IN VARCHAR2
                          ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_alt
                           ,vr_texto_completo
                           ,pr_des_dados
                           ,pr_fecha_xml);
  END; 
  
  -- Arquivo de retorno da execução
  PROCEDURE pc_escreve_ret(pr_des_dados IN VARCHAR2
                          ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_ret
                           ,vr_texto_completo_ret
                           ,pr_des_dados
                           ,pr_fecha_xml);
  END; 


begin
  
  -- Buscar caminho do micros
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0125829/';
    
  -- Abrir o arquivo PESSOA FISICA
  gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto    --> Diretório do arquivo
                           ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                           ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                           ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                           ,pr_des_erro => vr_dscritic);  --> Erro
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqbkp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de critica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exc_saida;
  END IF;  
  
  vr_des_ret := NULL;
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COOP;CONTA;CONTRATO;RESULTADO'); 
  
  LOOP
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file ,pr_des_text => vr_setlinha);
    vr_contlinha:= vr_contlinha + 1;
          
    -- ignorar primeira linha
    IF vr_contlinha = 1 THEN
      continue;
    END IF;

    -- Retirar quebra de linha
    vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));
    
    vr_cdcooper  := TRIM(gene0002.fn_busca_entrada(1,vr_setlinha,';'));
    vr_nrdconta  := TRIM(gene0002.fn_busca_entrada(2,vr_setlinha,';'));
    vr_nrctremp  := TRIM(gene0002.fn_busca_entrada(3,vr_setlinha,';'));   
    
    empr0020.pc_efetua_estor_pgto_no_dia(pr_cdcooper => vr_cdcooper
                                       ,pr_cdagenci => 1
                                       ,pr_nrdcaixa => 1
                                       ,pr_cdoperad => 1
                                       ,pr_nmdatela => 'ESTORN'
                                       ,pr_idorigem => 5
                                       ,pr_nrdconta => vr_nrdconta
                                       ,pr_idseqttl => 1
                                       ,pr_dtmvtolt => to_date('11/02/2022', 'DD/MM/YYYY')
                                       ,pr_nrctremp => vr_nrctremp
                                       ,pr_nrparepr => 0
                                       ,pr_des_reto => vr_des_reto
                                       ,pr_tab_erro => vr_tab_erro);

    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_cdcooper || ';' || vr_nrdconta || ';' || vr_nrctremp || ';Erro no estorno: ' || vr_dscritic); 
        ROLLBACK;
        CONTINUE;
      END IF;   
    END IF;

    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_cdcooper || ';' || vr_nrdconta || ';' || vr_nrctremp || ';Estornado com sucesso'); 
    COMMIT;
 
  END LOOP; -- Loop Arquivo

 EXCEPTION 
    WHEN no_data_found THEN
    -- Fechar o arquivo
     GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;   
    
    WHEN vr_exc_saida THEN
     GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto; 
    
    WHEN OTHERS THEN
     cecred.pc_internal_exception;
     GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto; 

end;    
