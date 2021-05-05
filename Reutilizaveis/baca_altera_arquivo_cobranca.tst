PL/SQL Developer Test script 3.0
154
DECLARE

  vr_diretorio    VARCHAR2(2000);
  vr_nmarquivo    VARCHAR2(70);
  vr_versao       NUMBER;
  vr_reproc       VARCHAR2(5) := 'N';
  
  vr_lstdarqv          VARCHAR2(4000); 
  vr_nome_novo_arquivo VARCHAR2(70);
  vr_handle_leitura    utl_file.file_type;  
  vr_handle_escrita    utl_file.file_type;  
  vr_vet_nmarquiv      GENE0002.typ_split;
  vr_setlinha          VARCHAR2(4000);
  vr_dsarquiv          VARCHAR2(2000);

  vr_cdcritic   NUMBER;
  vr_dscritic   VARCHAR2(20000) := NULL;
  vr_exc_saida  EXCEPTION; -- Falha que deverá parar o processamento                                                       
BEGIN
  vr_reproc := upper(substr(:pr_reproc,1,5));
  -- validacoes dos parametros
  IF :pr_diretorio IS NULL THEN
    vr_dscritic := 'É preciso informar o caminho que encontra-se o arquivo';
  ELSIF :pr_nmarquivo IS NULL THEN
    vr_dscritic := 'É preciso informar o nome do arquivo';
  ELSIF NOT cecred.comp0003.fn_existe_arquivo(:pr_diretorio,:pr_nmarquivo) THEN
    vr_dscritic := 'Arquivo não encontrado no diretório: '|| :pr_diretorio || ' o arquivo: '|| :pr_nmarquivo;
  ELSIF :pr_versao IS NULL THEN 
    vr_dscritic := 'É preciso informar o número da versão desejada';
  ELSIF  to_number(:pr_versao) < 1 THEN
    vr_dscritic := 'O número da versão deve ser maior que zero';    
  ELSIF  to_number(:pr_versao) > 9999999 THEN    
    vr_dscritic := 'O número da versão inválido';    
  ELSIF vr_reproc IS NULL THEN
    vr_dscritic := 'É preciso informar o pr_reproc, somente permitido "S" para Sim e "N" para Não';
  ELSIF vr_reproc NOT IN ('S','N') THEN
    vr_dscritic := 'Parâmetro reproc inválido, somente permitido "S" para Sim e "N" para Não';
  END IF;  
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_diretorio := :pr_diretorio;
  vr_nmarquivo := :pr_nmarquivo;
  vr_versao    := :pr_versao;
  
  --
  gene0001.pc_lista_arquivos(pr_path     => vr_diretorio
                            ,pr_pesq     => vr_nmarquivo
                            ,pr_listarq  => vr_lstdarqv
                            ,pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  --
  vr_vet_nmarquiv := GENE0002.fn_quebra_string(pr_string => vr_lstdarqv);
  --Se nao encontrou arquivo
  IF vr_vet_nmarquiv.COUNT <= 0 THEN
    vr_dscritic := 'Não encontrou o arquivo para processar';
    RAISE vr_exc_saida;
  END IF;
  vr_nome_novo_arquivo := vr_nmarquivo||'_'|| to_char(vr_versao,'fm0000000');
  -- Criar um novo arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_diretorio  --> Diretório do arquivo
                          ,pr_nmarquiv => vr_nome_novo_arquivo  --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_handle_escrita  --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> Erro
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF; 
  --
  FOR idx IN 1..vr_vet_nmarquiv.COUNT() LOOP
    --
    -- abrir o arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_diretorio, --> Diretorio do arquivo
                             pr_nmarquiv => vr_vet_nmarquiv(idx), --> Nome do arquivo
                             pr_tipabert => 'R',               --> Modo de abertura (R,W,A)
                             pr_utlfileh => vr_handle_leitura, --> Handle do arquivo aberto
                             pr_des_erro => vr_dscritic);      --> Erro
            
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;   
    LOOP
      vr_dsarquiv := NULL;
      BEGIN
          -- loop para ler a linha do arquivo
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_leitura, --> Handle do arquivo aberto
                                       pr_des_text => vr_setlinha); --> Texto lido
      EXCEPTION
        WHEN no_data_found THEN
          --Chegou ao final arquivo, sair do loop
          EXIT;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na leitura do arquivo: '||vr_vet_nmarquiv(idx)||'. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      IF substr(vr_setlinha,1,10) = '0000000000' THEN -- header
        vr_dsarquiv := substr(vr_setlinha,1,53) ||  to_char(vr_versao,'fm0000000')|| substr(vr_setlinha,61);
        
      ELSIF substr(vr_setlinha,1,10) = '9999999999' THEN -- trailer
        vr_dsarquiv := substr(vr_setlinha,1,53) ||  to_char(vr_versao,'fm0000000')|| substr(vr_setlinha,61);
          
      ELSIF substr(vr_setlinha,1,10) = '      9999' THEN -- fechamento
        vr_dsarquiv := substr(vr_setlinha,1,84) ||  to_char(vr_versao,'fm0000000')|| substr(vr_setlinha,92);
        IF vr_reproc = 'S' THEN
          vr_dsarquiv := substr(vr_dsarquiv,1,148) ||'48'|| substr(vr_dsarquiv,151);
        END IF;        
      ELSE -- detalhe          
        vr_dsarquiv := substr(vr_setlinha,1,96) ||  to_char(vr_versao,'fm0000000')|| substr(vr_setlinha,104);
        IF vr_reproc = 'S' THEN
          vr_dsarquiv := substr(vr_dsarquiv,1,148) ||'48'|| substr(vr_dsarquiv,151);
        END IF;
      END IF;
      
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_escrita --> Handle do arquivo aberto
                                    ,pr_des_text => vr_dsarquiv);  
    END LOOP;
  END LOOP;
  --     
  BEGIN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_leitura); --> Handle do arquivo aberto;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_escrita); --> Handle do arquivo aberto;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Problema ao fechar o novo arquivo  ' || SQLERRM;
      RAISE vr_exc_saida;
  END;  
  :pr_dscritic := 'Arquivo gerado com sucesso! diretório: '|| vr_diretorio ||
                 ' o arquivo: ' || vr_nome_novo_arquivo;
  
EXCEPTION
  WHEN vr_exc_saida THEN
    :pr_dscritic := vr_dscritic;
    cecred.comp0003.pc_remover_arq(pr_nmarquivo          => vr_nome_novo_arquivo,
                                   pr_nmdiretorio_origem => vr_diretorio,
                                   pr_cdcritic           => vr_cdcritic,
                                   pr_dscritic           => vr_dscritic); 
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;    
  WHEN OTHERS THEN
    :pr_dscritic := vr_dscritic ||' '||SQLERRM;
    cecred.comp0003.pc_remover_arq(pr_nmarquivo          => vr_nome_novo_arquivo,
                                   pr_nmdiretorio_origem => :pr_diretorio,
                                   pr_cdcritic           => vr_cdcritic,
                                   pr_dscritic           => vr_dscritic); 
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;    
END;
5
pr_diretorio
0
5
pr_nmarquivo
0
5
pr_versao
0
4
pr_reproc
0
5
pr_dscritic
0
5
1
vr_dsarquiv
