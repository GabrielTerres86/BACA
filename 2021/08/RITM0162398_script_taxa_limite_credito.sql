-- RITM0162398 - Script ajuste taxa limite de credito
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
  vr_setlinha   VARCHAR2(5000);               
  vr_vet_campos gene0002.typ_split;  
  
  -- Variaveis de controle
  vr_aux_cdcooper  crapcop.cdcooper%TYPE := 5;  -- Acentra 
  vr_aux_dtlancam  crapdat.dtmvtolt%TYPE := TO_DATE('01/06/2021','DD/MM/RRRR'); -- Data do lancamento
  rw_crapdat       BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_erro      VARCHAR2(10000); 
  vr_aux_nrconta   NUMBER;
  vr_aux_vlrtaxa   NUMBER;
  vr_nrseqdig      craplot.nrseqdig%TYPE;
  vr_incrineg      INTEGER;
  vr_tab_retorno   LANC0001.typ_reg_retorno; 
    
  -- Contadores
  vr_total_regis   INTEGER;
  vr_regis_encon   INTEGER;
  vr_total_difer   NUMBER;
  vr_total_final   NUMBER;
  vr_regis_lanc    INTEGER;
    
  -- Arquivo utilizados
/*   
  --LOCAL
  vr_nmarq_carga    VARCHAR2(200) := '/progress/t0032597/micros/script_ajuste_taxa/RITM0162398/Limites_Acentra.csv';           -- Arquivo a ser lido
  vr_nmarq_log      VARCHAR2(200) := '/progress/t0032597/micros/script_ajuste_taxa/RITM0162398/Limites_Acentra_LOG.txt';       -- Arquivo de Log
  vr_nmarq_rollback VARCHAR2(200) := '/progress/t0032597/micros/script_ajuste_taxa/RITM0162398/Limites_Acentra_ROLLBACK.sql';  -- Arquivo de Rollback
 */ 
  
/*      
  --TEST
  vr_nmarq_carga    VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/RITM0162398/Limites_Acentra.csv';          -- Arquivo a ser lido
  vr_nmarq_log      VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/RITM0162398/Limites_Acentra_LOG.txt';      -- Arquivo de Log
  vr_nmarq_rollback VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/RITM0162398/Limites_Acentra_ROLLBACK.sql'; -- Arquivo de Rollback   
 */
  
  --PRODUCAO
  vr_nmarq_carga    VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/RITM0162398/Limites_Acentra.csv';          -- Arquivo a ser lido
  vr_nmarq_log      VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/RITM0162398/Limites_Acentra_LOG.txt';      -- Arquivo de Log
  vr_nmarq_rollback VARCHAR2(200) := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/RITM0162398/Limites_Acentra_ROLLBACK.sql'; -- Arquivo de Rollback
  
  
  /***Campos do arquivo***/
  --CONTA - Conta do cooperado
  --TAXA  - Taxa aplicada
  
  -- Vetor da carga do arquivo
  TYPE typ_reg_carga IS RECORD(nrdconta  craplim.nrdconta%TYPE
                              ,vlrtaxa   crapldc.txmensal%TYPE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  -- Obter valor da taxa aplicada e calcular diferenca a ser estornada
  CURSOR cr_craplcm(pr_nrdconta IN craplcm.nrdconta%TYPE
                   ,pr_txmensal IN NUMBER) IS
         SELECT (antes - depois) diff_lanc_320_craplcm
                ,antes
                ,depois
                ,dtmvtolt
                ,nrdconta
            FROM (SELECT ROUND(((l.vllanmto * 7.99) / pr_txmensal), 2) depois
                        ,l.vllanmto antes
                        ,l.dtmvtolt
                        ,l.nrdconta
                    FROM craplcm l
                   WHERE l.cdcooper = vr_aux_cdcooper
                     AND l.cdhistor = 38 -- JUROS LIM CRD
                     AND l.dtmvtolt = vr_aux_dtlancam
                     AND l.nrdconta = pr_nrdconta) x;
         rw_craplcm cr_craplcm%ROWTYPE;
   
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

          vr_setlinha := REPLACE(REPLACE(vr_setlinha,chr(13),''),chr(10),''); -- Remover caracteres quebra de linha "CRLF"

          vr_vet_campos := gene0002.fn_quebra_string(TRIM(vr_setlinha),';');  -- Separar os campos da linha
          
          -- Converter valores da linha para numeral
          BEGIN
            vr_aux_nrconta := TO_NUMBER(vr_vet_campos(1));
            vr_aux_vlrtaxa := TO_NUMBER(vr_vet_campos(2));
          EXCEPTION
            WHEN OTHERS THEN
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                            ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' --> ' || SQLERRM);
              
            CONTINUE;
          END;     

          -- Alimentar vetor com dados do arquivo
          vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrconta;
          vr_tab_carga(vr_nrcontad).vlrtaxa  := vr_aux_vlrtaxa;
          
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
                                    ,pr_des_text => 'Coop;Conta;Valor;Critica');
   
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
          --INICIO Ajuste da taxa limite de credito
          
          -- Obter valor da taxa aplicada e calcular diferenca a ser estornada
          OPEN cr_craplcm(pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta,
                          pr_txmensal => vr_tab_carga(vr_idx1).vlrtaxa);
          FETCH cr_craplcm INTO rw_craplcm;
       
          IF cr_craplcm%FOUND THEN
             vr_regis_encon := NVL(vr_regis_encon,0) + 1;

             vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT',
                                          pr_nmdcampo => 'NRSEQDIG',
                                          pr_dsdchave => to_char(vr_aux_cdcooper) || ';' || to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ';' || '1;100;8450');
   
             -- Rotina centralizada para incluir um novo lançamento na CRAPLCM e aplica as devidas regras de negócio
             LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                pr_cdagenci    => 1,
                                                pr_cdbccxlt    => 100,
                                                pr_nrdolote    => 8450,
                                                pr_nrdconta    => rw_craplcm.nrdconta,
                                                pr_nrdocmto    => 99999320,
                                                pr_cdhistor    => 320,
                                                pr_nrseqdig    => vr_nrseqdig,
                                                pr_vllanmto    => TO_NUMBER(rw_craplcm.diff_lanc_320_craplcm),
                                                pr_nrdctabb    => rw_craplcm.nrdconta,
                                                pr_cdpesqbb    => 'ESTORNO DE JUROS LIMITE DE CREDITO',
                                                pr_dtrefere    => rw_crapdat.dtmvtolt,
                                                pr_hrtransa    => gene0002.fn_busca_time,
                                                pr_cdoperad    => '1',
                                                pr_cdcooper    => vr_aux_cdcooper,
                                                pr_cdorigem    => 5,
                                                pr_incrineg    => vr_incrineg,
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
                                            
             IF (NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL) THEN
                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                               ,pr_des_text => vr_aux_cdcooper                || ';' || 
                                                               rw_craplcm.nrdconta            || ';' || 
                                                               vr_tab_carga(vr_idx1).vlrtaxa  || ';' || 
                                                               'Erro ao inserir Lancamento:  '|| vr_dscritic || ' - ' || SQLERRM);
             ELSE             
                                    
                 IF vr_tab_retorno.rowidlct IS NOT NULL THEN
                    -- Grava script de rollback 
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                  ,pr_des_text => 'DELETE FROM craplcm WHERE rowid = ' || vr_tab_retorno.rowidlct || ';');
                                                                                  
                    vr_total_final :=  NVL(vr_total_final,0) +  NVL(rw_craplcm.diff_lanc_320_craplcm,0);
                    vr_regis_lanc := NVL(vr_regis_lanc,0) + 1;
                 END IF;                                                   
             END IF;
               
              
             CLOSE cr_craplcm;
          ELSE
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                           ,pr_des_text => vr_aux_cdcooper                || ';' || 
                                                           vr_tab_carga(vr_idx1).nrdconta || ';' || 
                                                           vr_tab_carga(vr_idx1).vlrtaxa  || ';' || 
                                                           'Erro ao buscar dados: '||sqlerrm);
            CLOSE cr_craplcm;
          END IF;
          
          vr_total_regis := NVL(vr_total_regis,0) + 1;
 
          --FIM Ajuste da taxa limite de credito                
          --##################################################################################### 
          END IF;
      END LOOP;
      
      
      --#####################################################################################     
      -- Escrever Totalizadores no Log 
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => '#####################################################################################');
                                    
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Data da movimentacao ajustada: ' || vr_aux_dtlancam);
                                      
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Total de registros encontrados - base de dados X planilha: ' || vr_regis_encon || '/' || vr_total_regis);
                                    
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Total de lancamentos realizados com sucesso: ' || vr_regis_lanc || '/' || vr_total_regis);                              
 
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Valor total do estorno: ' || to_char(vr_total_final,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));         
 
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
