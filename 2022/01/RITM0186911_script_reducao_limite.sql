-- Script reducao de limite de credito
/*
-- Verificar antes de executar
   - Caminho dos arquivos a serem utilizados no ambiente correto
   - Arquivo de LOG e ROLLBACK precisam existir e ter chmod777
   - Variaveis do Vetor da carga do arquivo
*/

DECLARE

  -- Variaveis auxiliares
  /*########################*/
  vr_aux_ambiente INTEGER       := 2;                    -- Em qual ambiente rodar: 1=Local, 2=Test, 3=Producao
  vr_aux_diretor  VARCHAR2(100) := 'RITM0191408';        -- Usar numero do chamado para nomear diretorio
  vr_aux_arquivo  VARCHAR2(100) := 'reducao_acredicoop'; -- Nome do arquivo
  /*########################*/
  
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;

  -- Manipulação de arquivos
  vr_input_file UTL_FILE.FILE_TYPE; 
  vr_handle     UTL_FILE.FILE_TYPE; 
  vr_handle_log UTL_FILE.FILE_TYPE; 
  vr_nrcontad   PLS_INTEGER := 0;
  vr_idx_carga  PLS_INTEGER;                            
  vr_setlinha   VARCHAR2(5000);                
  vr_vet_campos gene0002.typ_split; 
  
  --Variaveis armazenar arquivos de leitura/escrita
  vr_nmarq_carga    VARCHAR2(200);
  vr_nmarq_log      VARCHAR2(200);
  vr_nmarq_rollback VARCHAR2(200);
  
  -- Variaveis de controle
  rw_crapdat        BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_erro       VARCHAR2(10000);   
  vr_aux_cdcooper   NUMBER;
  vr_aux_nrdconta   NUMBER;
  vr_aux_novolimite NUMBER;
 
  /***Campos do arquivo***/
  --Cooperativa
  --Conta
  --Limite Concedido
  --Limite novo 
  

  -- Vetor da carga do arquivo
  TYPE typ_reg_carga IS RECORD(cdcooper  craplim.cdcooper%TYPE
                              ,nrdconta  craplim.nrdconta%TYPE
                              ,vllimite  craplim.vllimite%TYPE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  
  
  CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE     --> Código da Cooperativa
                   ,pr_nrdconta IN craplim.nrdconta%TYPE) IS     --> Número da Conta
      SELECT craplim.cdcooper, 
             craplim.nrdconta, 
             craplim.nrctrlim,
             craplim.vllimite                       
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.tpctrlim = 1
         AND craplim.insitlim = 2;-- ativa
    rw_craplim cr_craplim%ROWTYPE;

BEGIN 
  
--##################################################################################### 
  -- Definir em qual ambiente ira buscar os arquivos para leitura/escrita
  IF vr_aux_ambiente = 1 THEN --LOCAL      
    vr_nmarq_carga    := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';           -- Arquivo a ser lido
    vr_nmarq_log      := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';       -- Arquivo de Log
    vr_nmarq_rollback := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';  -- Arquivo de Rollback 
  ELSIF vr_aux_ambiente = 2 THEN --TEST        
    vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';          -- Arquivo a ser lido
    vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      -- Arquivo de Log
    vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; -- Arquivo de Rollback   
  ELSIF vr_aux_ambiente = 3 THEN --PRODUCAO
    vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';          -- Arquivo a ser lido
    vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      -- Arquivo de Log
    vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; -- Arquivo de Rollback
  ELSE
    vr_dscritic := 'Erro ao apontar ambiente de execucao.';
    RAISE vr_exc_erro;
  END IF;
--##################################################################################### 

      
--##################################################################################### 
      -- Leitura do arquivo com registros
      GENE0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_carga
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_input_file
                              ,pr_des_erro => vr_dscritic);                                                                       
      IF vr_dscritic IS NOT NULL THEN 
         vr_dscritic := 'Erro ao abrir o arquivo para leitura: '||vr_nmarq_carga || ' - ' || vr_dscritic;
         RAISE vr_exc_erro;
      END IF;

      -- Abrir o arquivo de LOG
      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log
                              ,pr_tipabert => 'W'              
                              ,pr_utlfileh => vr_handle_log   
                              ,pr_des_erro => vr_des_erro);
      if vr_des_erro is not null then
        vr_dscritic := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
        RAISE vr_exc_erro;
      end if;
             
      LOOP -- Inicio loop de leitura do arquivo
        BEGIN
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido
      
          vr_nrcontad := vr_nrcontad + 1; -- Incrementar quantidade linhas
          
          IF vr_nrcontad = 1 THEN -- Desconsiderar a linha de header do arquivo
            continue;
          END IF;

          vr_setlinha := REPLACE(REPLACE(vr_setlinha,chr(13),''),chr(10),''); -- Remover caracteres quebra de linha "\r\n"

          vr_vet_campos := gene0002.fn_quebra_string(TRIM(vr_setlinha),';');  -- Separar os campos da linha
          
          IF vr_nrcontad = 2 THEN -- Na leitura do primeiro registro busca data da cooperativa
            -- Busca data cooperativa
            OPEN BTCH0001.cr_crapdat(pr_cdcooper =>  vr_vet_campos(1));
            FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
            CLOSE BTCH0001.cr_crapdat;
          END IF;
          
          -- Converter valores da linha para numeral
          BEGIN
            vr_aux_cdcooper := TO_NUMBER(vr_vet_campos(1));
            vr_aux_nrdconta := TO_NUMBER(vr_vet_campos(2));
            vr_aux_novolimite := TO_NUMBER(vr_vet_campos(4));
          EXCEPTION
            WHEN OTHERS THEN
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                            ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' --> ' || SQLERRM);
              
            CONTINUE;
          END;             

          -- Alimentar vetor com dados do arquivo
          vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
          vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;
          vr_tab_carga(vr_nrcontad).vllimite := vr_aux_novolimite;

        EXCEPTION
          WHEN no_data_found THEN
            EXIT;
          WHEN vr_exc_erro THEN
            RAISE vr_exc_erro;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na leitura da linha '||vr_nrcontad||' --> '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      END LOOP; -- Fim loop de leitura do arquivo     
--#####################################################################################
      

 

--#####################################################################################     
      -- Escrever cabecalho do arquivo de LOG 
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Coop;Conta;Contrato;Critica');
   
      -- Abrir o arquivo de ROLLBACK
      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback
                              ,pr_tipabert => 'W'              
                              ,pr_utlfileh => vr_handle   
                              ,pr_des_erro => vr_des_erro);
      if vr_des_erro is not null then
        vr_dscritic := 'Erro ao abrir arquivo de ROLLBACK: ' || vr_des_erro;
        RAISE vr_exc_erro;
      end if;          
--#####################################################################################                                         
  

      
      FOR vr_idx1 IN vr_tab_carga.first .. vr_tab_carga.last LOOP
          IF vr_tab_carga.exists(vr_idx1) THEN 
            
             --dbms_output.put_line('Conta:'|| vr_tab_carga(vr_idx1).nrdconta || ' - Limite:'|| vr_tab_carga(vr_idx1).vllimite);
             
              -- Consultar o limite de credito
              OPEN cr_craplim(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper,
                              pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta);
              FETCH cr_craplim INTO rw_craplim;
              -- Verifica se o limite de credito existe
              IF cr_craplim%NOTFOUND THEN
                CLOSE cr_craplim;
                vr_dscritic := 'Associado nao possui proposta de limite de credito Ativa. ';
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                              vr_tab_carga(vr_idx1).nrdconta || ';' || 
                                                              vr_dscritic);
                                                                                                            
              ELSE
                  CLOSE cr_craplim;
                  
              --#######   
                  BEGIN
                    UPDATE craplim SET
                           vllimite = vr_tab_carga(vr_idx1).vllimite
                     WHERE cdcooper = rw_craplim.cdcooper
                       AND nrdconta = rw_craplim.nrdconta
                       AND nrctrlim = rw_craplim.nrctrlim
                       AND insitlim = 2 -- Ativo
                       AND tpctrlim = 1; -- Limite Credito
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao ajustar o limite de credito: (craplim)' || SQLERRM;
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                    ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                    vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                    rw_craplim.nrctrlim || ';' || 
                                                                    vr_dscritic);
                  END;
                     
                  -- Grava script de rollback
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'UPDATE craplim SET '
                                                                ||' vllimite = '||''''||rw_craplim.vllimite||''''
                                                                ||' WHERE cdcooper = '||rw_craplim.cdcooper
                                                                ||'   AND nrdconta = '||rw_craplim.nrdconta
                                                                ||'   AND nrctrlim = '||rw_craplim.nrctrlim
                                                                ||'   AND insitlim = 2'
                                                                ||'   AND tpctrlim = 1;' -- Limite Credito        
                                                                 );
              --#######                                                   
                  BEGIN
                    UPDATE crawlim SET
                           vllimite = vr_tab_carga(vr_idx1).vllimite
                     WHERE cdcooper = rw_craplim.cdcooper
                       AND nrdconta = rw_craplim.nrdconta
                       AND nrctrlim = rw_craplim.nrctrlim
                       AND insitlim = 2; -- Ativo
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao ajustar o limite de credito: (crawlim)' || SQLERRM;
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                    ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                    vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                    rw_craplim.nrctrlim || ';' || 
                                                                    vr_dscritic);
                  END;
                     
                  -- Grava script de rollback
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'UPDATE crawlim SET '
                                                                ||' vllimite = '||''''||rw_craplim.vllimite||''''
                                                                ||' WHERE cdcooper = '||rw_craplim.cdcooper
                                                                ||'   AND nrdconta = '||rw_craplim.nrdconta
                                                                ||'   AND nrctrlim = '||rw_craplim.nrctrlim
                                                                ||'   AND insitlim = 2;'     
                                                                 );                                               
                  
                  
                  --#######                                                   
                  BEGIN
                    UPDATE crapass SET
                           vllimcre = vr_tab_carga(vr_idx1).vllimite
                     WHERE cdcooper = rw_craplim.cdcooper
                       AND nrdconta = rw_craplim.nrdconta; 
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao ajustar o limite de credito: (crapass)' || SQLERRM;
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                    ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                    vr_tab_carga(vr_idx1).nrdconta || ';' || 
                                                                    rw_craplim.nrctrlim || ';' || 
                                                                    vr_dscritic);
                  END;
                     
                  -- Grava script de rollback
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'UPDATE crapass SET '
                                                                ||' vllimcre = '||''''||rw_craplim.vllimite||''''
                                                                ||' WHERE cdcooper = '||rw_craplim.cdcooper
                                                                ||'   AND nrdconta = '||rw_craplim.nrdconta || ';'  
                                                                 );                                            
                                                                 
              END IF;

          END IF;
      END LOOP;
  
      
 --#####################################################################################
      -- Fechar arquivo de Rollback e log  
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,pr_des_text => 'COMMIT;');
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
          
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);              
--#####################################################################################       
      
      COMMIT;
      
EXCEPTION
    
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro arquivos: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro arquivos: ' || vr_dscritic || ' SQLERRM: ' || SQLERRM);      

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;  
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro geral: ' || ' SQLERRM: ' || SQLERRM);

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
END;
