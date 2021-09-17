-- Script manutencao de limite de credito
/*
-- Verificar antes de executar
   - Caminho dos arquivo a serem utilizados no ambiente correto
   - Arquivo de LOG e ROLLBACK precisam existir e ter chmod777
   - Variaveis do Vetor da carga do arquivo
*/

DECLARE
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
  
  -- Variaveis de controle
  rw_crapdat        BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_erro       VARCHAR2(10000); 
  vr_nrdrowid       rowid;
    
  vr_aux_cdcooper   NUMBER := 2; --Acredicoop
  vr_aux_nrdconta   NUMBER;
  vr_aux_inpessoa   NUMBER;
  vr_aux_vllimant   NUMBER;
  vr_aux_vllimnov   NUMBER;
    
  -- Arquivo utilizados
  /*   
  --LOCAL
  vr_nmarq_carga    VARCHAR2(200) := '/progress/t0032597/micros/script_manutencao/RITM0165645/manutencao_acredicoop.csv';           -- Arquivo a ser lido
  vr_nmarq_log      VARCHAR2(200) := '/progress/t0032597/micros/script_manutencao/RITM0165645/manutencao_acredicoop_LOG.txt';       -- Arquivo de Log
  vr_nmarq_rollback VARCHAR2(200) := '/progress/t0032597/micros/script_manutencao/RITM0165645/manutencao_acredicoop_ROLLBACK.sql';  -- Arquivo de Rollback 
  */
   
  /* 
  --TEST
  vr_nmarq_carga    VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cecred/daniel/RITM0165645/manutencao_acredicoop.csv';           -- Arquivo a ser lido
  vr_nmarq_log      VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cecred/daniel/RITM0165645/manutencao_acredicoop_LOG.txt';       -- Arquivo de Log
  vr_nmarq_rollback VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cecred/daniel/RITM0165645/manutencao_acredicoop_ROLLBACK.sql';  -- Arquivo de Rollback   
  */
  
  
  --PRODUCAO
  vr_nmarq_carga    VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/RITM0165645/manutencao_acredicoop.csv';          -- Arquivo a ser lido
  vr_nmarq_log      VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/RITM0165645/manutencao_acredicoop_LOG.txt';      -- Arquivo de Log
  vr_nmarq_rollback VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/RITM0165645/manutencao_acredicoop_ROLLBACK.sql'; -- Arquivo de Rollback
 


  /***Campos do arquivo***/
  --cdagenci - Agencia
  --nrdconta - Conta
  --inpessoa - TipoPessoa
  --vllimant - Limite antigo
  --vllimnov - Limtie novo
  
  -- Vetor da carga do arquivo
  TYPE typ_reg_carga IS RECORD(cdcooper  craplim.cdcooper%TYPE
                              ,nrdconta  craplim.nrdconta%TYPE
                              ,inpessoa  crapass.inpessoa%TYPE
                              ,nrctrlim  craplim.nrctrlim%TYPE
                              ,vllimant  craplim.vllimite%TYPE
                              ,vllimnov  craplim.vllimite%TYPE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  -- Busca contrato limite de credito
  CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE     --> Código da Cooperativa
                   ,pr_nrdconta IN craplim.nrdconta%TYPE) IS --> Número da Conta
   SELECT lim.nrctrlim
         ,lim.vllimite
     FROM craplim lim
    WHERE lim.cdcooper = pr_cdcooper
      AND lim.nrdconta = pr_nrdconta
      AND lim.tpctrlim = 1
      AND lim.insitlim = 2;
   rw_craplim cr_craplim%ROWTYPE; 
   
BEGIN 
  
  -- Busca data cooperativa
  OPEN BTCH0001.cr_crapdat(pr_cdcooper =>  vr_aux_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;
      
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

          if vr_vet_campos(3) = 'PF' then
             vr_aux_inpessoa := 1;
          else
             vr_aux_inpessoa := 2;
          end if;  

          -- Converter valores da linha para numeral
          BEGIN
            vr_aux_nrdconta := TO_NUMBER(vr_vet_campos(2));
            vr_aux_inpessoa := TO_NUMBER(vr_aux_inpessoa);
            vr_aux_vllimant := TO_NUMBER(vr_vet_campos(4));
            vr_aux_vllimnov := TO_NUMBER(vr_vet_campos(5));
          EXCEPTION
            WHEN OTHERS THEN
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                            ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' --> ' || SQLERRM);
              
            CONTINUE;
          END; 
          
          -- Consultar o limite de credito
          OPEN cr_craplim(pr_cdcooper => vr_aux_cdcooper,
                          pr_nrdconta => vr_aux_nrdconta);
          FETCH cr_craplim INTO rw_craplim;
          -- Verifica se o limite de credito existe
          IF cr_craplim%NOTFOUND THEN
             CLOSE cr_craplim;
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                           ,pr_des_text => vr_aux_nrdconta || ' - Conta nao possui contrato de limite de credito ativo.' || ' --> ' || SQLERRM);
             CONTINUE;                               
          ELSE
             CLOSE cr_craplim;
          END IF;    

          -- Alimentar vetor com dados do arquivo
          vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
          vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;
          vr_tab_carga(vr_nrcontad).inpessoa := vr_aux_inpessoa;
          vr_tab_carga(vr_nrcontad).nrctrlim := rw_craplim.nrctrlim;
          vr_tab_carga(vr_nrcontad).vllimant := vr_aux_vllimant;
          vr_tab_carga(vr_nrcontad).vllimnov := vr_aux_vllimnov;

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

                --##################################################################################### 
                --INICIO Alteracao valor do limite de credito

                BEGIN
                  UPDATE craplim lim
                     SET lim.vllimite = vr_tab_carga(vr_idx1).vllimnov
                   WHERE lim.nrctrlim = vr_tab_carga(vr_idx1).nrctrlim
                     AND lim.nrdconta = vr_tab_carga(vr_idx1).nrdconta
                     AND lim.cdcooper = vr_tab_carga(vr_idx1).cdcooper
                     AND lim.tpctrlim = 1;
                    
                  UPDATE crawlim lim
                     SET lim.vllimite = vr_tab_carga(vr_idx1).vllimnov
                   WHERE lim.nrctrlim = vr_tab_carga(vr_idx1).nrctrlim
                     AND lim.nrdconta = vr_tab_carga(vr_idx1).nrdconta
                     AND lim.cdcooper = vr_tab_carga(vr_idx1).cdcooper
                     AND lim.tpctrlim = 1;
                                          
                  UPDATE crapass ass
                     SET ass.vllimcre = vr_tab_carga(vr_idx1).vllimnov
                   WHERE ass.nrdconta = vr_tab_carga(vr_idx1).nrdconta
                     AND ass.cdcooper = vr_tab_carga(vr_idx1).cdcooper;   
                     
                 
                   -- Grava script de rollback
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'UPDATE craplim lim '    ||
                                                                '   SET lim.vllimite = ' || vr_tab_carga(vr_idx1).vllimant ||
                                                                ' WHERE lim.cdcooper = ' || vr_tab_carga(vr_idx1).cdcooper ||
                                                                '   AND lim.nrdconta = ' || vr_tab_carga(vr_idx1).nrdconta ||
                                                                '   AND lim.nrctrlim = ' || vr_tab_carga(vr_idx1).nrctrlim ||
                                                                '   AND lim.tpctrlim = 1 ' ||
                                                                ';');

                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                  ,pr_des_text => 'UPDATE crawlim lim '    ||
                                                                  '   SET lim.vllimite = ' || vr_tab_carga(vr_idx1).vllimant ||
                                                                  ' WHERE lim.cdcooper = ' || vr_tab_carga(vr_idx1).cdcooper ||
                                                                  '   AND lim.nrdconta = ' || vr_tab_carga(vr_idx1).nrdconta ||
                                                                  '   AND lim.nrctrlim = ' || vr_tab_carga(vr_idx1).nrctrlim ||
                                                                  '   AND lim.tpctrlim = 1 ' ||
                                                                  ';');
                    
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                  ,pr_des_text => 'UPDATE crapass ass '    ||
                                                                  '   SET ass.vllimcre = ' || vr_tab_carga(vr_idx1).vllimant ||
                                                                  ' WHERE ass.cdcooper = ' || vr_tab_carga(vr_idx1).cdcooper ||
                                                                  '   AND ass.nrdconta = ' || vr_tab_carga(vr_idx1).nrdconta ||
                                                                  ';');                                              
                                                                  
                  
                   -- Gravar registro de log da operacao                                                
                   GENE0001.pc_gera_log(pr_cdcooper =>  vr_tab_carga(vr_idx1).cdcooper
                                       ,pr_cdoperad => '1'
                                       ,pr_dscritic => ' '
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                                       ,pr_dstransa => 'Alteração valor do limite de credito (RITM0165645)'
                                       ,pr_dttransa => TRUNC(SYSDATE)
                                       ,pr_flgtrans => 1
                                       ,pr_hrtransa => gene0002.fn_busca_time
                                       ,pr_idseqttl => 1
                                       ,pr_nmdatela => 'Script'
                                       ,pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta
                                       ,pr_nrdrowid => vr_nrdrowid);

                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                            pr_nmdcampo => 'Contrato',
                                            pr_dsdadant => NULL,
                                            pr_dsdadatu => vr_tab_carga(vr_idx1).nrctrlim);
                                                                                           
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                            pr_nmdcampo => 'Valor',
                                            pr_dsdadant => NULL,
                                            pr_dsdadatu => vr_tab_carga(vr_idx1).vllimnov);                                                
                EXCEPTION
                  WHEN OTHERS THEN
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                  ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                  vr_tab_carga(vr_idx1).nrdconta || ';' || 
                                                                  vr_tab_carga(vr_idx1).nrctrlim || ';' || 
                                                                  'Erro na atualizacao do contrato:'||sqlerrm);
                END;
                --FIM Alteracao valor do limite de credito             
                --##################################################################################### 

               

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
