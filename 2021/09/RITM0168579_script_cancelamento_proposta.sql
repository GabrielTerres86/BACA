-- RITM0168579 - Script Alteração Status proposta - cancelado
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
    
  vr_aux_cdcooper   NUMBER;
  vr_aux_nrdconta   NUMBER;
  vr_aux_nrctremp   NUMBER;
  vr_aux_insitapr   NUMBER;
  vr_aux_insitest   NUMBER;
    
  -- Arquivo utilizados
     
  --LOCAL
  vr_nmarq_carga    VARCHAR2(200) := '/progress/t0032597/micros/script_cancela_proposta/RITM0168579/RITM0168579_csv.csv';       -- Arquivo a ser lido
  vr_nmarq_log      VARCHAR2(200) := '/progress/t0032597/micros/script_cancela_proposta/RITM0168579/RITM0168579_LOG.txt';       -- Arquivo de Log
  vr_nmarq_rollback VARCHAR2(200) := '/progress/t0032597/micros/script_cancela_proposta/RITM0168579/RITM0168579_ROLLBACK.sql';  -- Arquivo de Rollback 

   
  /* 
  --TEST
  vr_nmarq_carga    VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cecred/jaison/RITM0168579/RITM0168579_csv.csv;        -- Arquivo a ser lido
  vr_nmarq_log      VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cecred/jaison/RITM0168579/RITM0168579_LOG.txt';       -- Arquivo de Log
  vr_nmarq_rollback VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cecred/jaison/RITM0168579/RITM0168579_ROLLBACK.sql';  -- Arquivo de Rollback   
  */
  
/*  
  --PRODUCAO
  vr_nmarq_carga    VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/jaison/RITM0168579/RITM0168579_csv.csv';      -- Arquivo a ser lido
  vr_nmarq_log      VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/jaison/RITM0168579/RITM0168579_LOG.txt';      -- Arquivo de Log
  vr_nmarq_rollback VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/jaison/RITM0168579/RITM0168579_ROLLBACK.sql'; -- Arquivo de Rollback
 
*/

  /***Campos do arquivo***/
  --cdcooper - Cooperativa
  --nrdconta - Conta
  --nrctremp - Proposta
  
  -- Vetor da carga do arquivo
  TYPE typ_reg_carga IS RECORD(cdcooper  crawepr.cdcooper%TYPE
                              ,nrdconta  crawepr.nrdconta%TYPE
                              ,nrctremp  crawepr.nrctremp%TYPE
                              ,insitapr  crawepr.insitapr%TYPE
                              ,insitest  crawepr.insitest%TYPE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  -- Busca proposta sem contrato
  CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE     --> Cooperativa
                   ,pr_nrdconta IN crawepr.nrdconta%TYPE     --> Conta
                   ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS --> Contrato
     SELECT a.insitapr,
            a.insitest
       FROM crawepr a
      WHERE a.cdcooper = pr_cdcooper
        AND a.nrdconta = pr_nrdconta
        AND a.nrctremp = pr_nrctremp
        AND NOT EXISTS (SELECT 1
               FROM crapepr p
              WHERE p.cdcooper = a.cdcooper
                AND p.nrdconta = a.nrdconta
                AND p.nrctremp = a.nrctremp);
    rw_crawepr cr_crawepr%ROWTYPE; 
   
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

          -- Converter valores da linha para numeral
          BEGIN
            vr_aux_cdcooper := TO_NUMBER(vr_vet_campos(1));
            vr_aux_nrdconta := TO_NUMBER(vr_vet_campos(2));
            vr_aux_nrctremp := TO_NUMBER(vr_vet_campos(3));
          EXCEPTION
            WHEN OTHERS THEN
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                            ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' --> ' || SQLERRM);
              
            CONTINUE;
          END;           
          
          -- Consultar proposta sem contrato
          OPEN cr_crawepr(pr_cdcooper => vr_aux_cdcooper,
                          pr_nrdconta => vr_aux_nrdconta,
                          pr_nrctremp => vr_aux_nrctremp);
          FETCH cr_crawepr INTO rw_crawepr;

          IF cr_crawepr%NOTFOUND THEN
             CLOSE cr_crawepr;
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                           ,pr_des_text => 'coop = ' || vr_aux_cdcooper || ' - ' ||
                                                           'conta = ' || vr_aux_nrdconta|| ' - ' ||
                                                           'contrato = ' || vr_aux_nrctremp || ' - ' ||
                                                           'Proposta ja possui um contrato.' || ' --> ' || SQLERRM);
             CONTINUE;                               
          ELSE
             CLOSE cr_crawepr;
          END IF; 


          -- Alimentar vetor com dados do arquivo
          vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
          vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;
          vr_tab_carga(vr_nrcontad).nrctremp := vr_aux_nrctremp;
          vr_tab_carga(vr_nrcontad).insitapr := rw_crawepr.insitapr;
          vr_tab_carga(vr_nrcontad).insitest := rw_crawepr.insitest;

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
                --INICIO Alteracao cancelamento proposta

                BEGIN
                  
                  UPDATE crawepr w
                     SET w.insitapr = 2,
                         w.insitest = 6
                   WHERE w.nrctremp = vr_tab_carga(vr_idx1).nrctremp
                     AND w.nrdconta = vr_tab_carga(vr_idx1).nrdconta
                     AND w.cdcooper = vr_tab_carga(vr_idx1).cdcooper;
                     

                   -- Grava script de rollback
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'UPDATE crawepr w '    ||
                                                                '   SET w.insitapr = ' || vr_tab_carga(vr_idx1).insitapr ||
                                                                '      ,w.insitest = ' || vr_tab_carga(vr_idx1).insitest ||
                                                                ' WHERE w.nrctremp = ' || vr_tab_carga(vr_idx1).nrctremp ||
                                                                '   AND w.nrdconta = ' || vr_tab_carga(vr_idx1).nrdconta ||
                                                                '   AND w.cdcooper = ' || vr_tab_carga(vr_idx1).cdcooper ||
                                                                ';');
                                             
                   -- Gravar registro de log da operacao                                                
                   GENE0001.pc_gera_log(pr_cdcooper =>  vr_tab_carga(vr_idx1).cdcooper
                                       ,pr_cdoperad => '1'
                                       ,pr_dscritic => ' '
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                                       ,pr_dstransa => 'Alteração status proposta - cancelado (RITM0168579)'
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
                                            pr_dsdadatu => vr_tab_carga(vr_idx1).nrctremp); 
                  
                  -- Grava sucesso da operação no arquivo de log                          
                  GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                vr_tab_carga(vr_idx1).nrdconta || ';' || 
                                                                vr_tab_carga(vr_idx1).nrctremp || ';' || 
                                                                ' - Sucesso na atualizacao do contrato.');                          
                                                                                           
                EXCEPTION
                  WHEN OTHERS THEN
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                  ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                  vr_tab_carga(vr_idx1).nrdconta || ';' || 
                                                                  vr_tab_carga(vr_idx1).nrctremp || ';' || 
                                                                  ' - Erro na atualizacao do contrato:'||sqlerrm);
                END;
                --FIM Alteracao cancelamento proposta            
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
