-- Script ajustes lancamentos de pix
/*
-- Verificar antes de executar
   - Caminho dos arquivos a serem utilizados no ambiente correto
   - Arquivo de LOG e ROLLBACK precisam existir e ter chmod777
   - Variaveis do Vetor da carga do arquivo
*/

DECLARE

  -- Variaveis auxiliares
  /*########################*/
  vr_aux_ambiente INTEGER       := 3;            -- Em qual ambiente rodar: 1=Local, 2=Test, 3=Producao
  vr_aux_diretor  VARCHAR2(100) := 'INC0122353'; -- Usar numero do chamado para nomear diretorio
  vr_aux_arquivo  VARCHAR2(100) := 'contas';     -- Nome do arquivo
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
  vr_aux_inpessoa   VARCHAR2(10);
  vr_aux_slddisd6   NUMBER;
  vr_aux_ttlcredi   NUMBER;
  vr_aux_somamvt7   NUMBER;
  vr_aux_slddisd7   NUMBER;
  vr_aux_sldprvd7   NUMBER;
  vr_aux_adp7       crapsld.vlsmnmes%TYPE;
  vr_ttl_vlsmnmes   crapsld.vlsmnmes%TYPE;
  vr_aux_lim7       crapsld.vlsmnesp%TYPE;
  vr_ttl_vlsmnesp   crapsld.vlsmnesp%TYPE;
  vr_aux_vliofmes   NUMBER;
  vr_aux_ttliof     NUMBER;
  
  /***
  #Campos do arquivo#
  COOPER
  CONTA   
  PESSOA  
  SALDO DISP DIA 6   
  TOTAL CREDITOS  
  SOMA MOVTO. DIA 7 
  SALDO DISP DIA 7  
  SALDO PREV. DIA 7
  ***/
  
  -- Vetor da carga do arquivo
  TYPE typ_reg_carga IS RECORD(cdcooper  crapass.cdcooper%TYPE
                              ,nrdconta  crapass.nrdconta%TYPE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  
  -- Vetor da carga da tabela crapsda
  TYPE typ_reg_carga_sda IS RECORD(vllimcre  crapsda.vllimcre%TYPE
                                  ,vllimutl7 crapsda.vllimutl%TYPE
                                  ,vladdutl7 crapsda.vladdutl%TYPE);
  TYPE typ_tab_carga_sda IS TABLE OF typ_reg_carga_sda INDEX BY PLS_INTEGER;
  vr_tab_carga_sda typ_tab_carga_sda;
  
   
  CURSOR cr_crapsda(pr_cdcooper IN crapsda.cdcooper%TYPE     
                   ,pr_nrdconta IN crapsda.nrdconta%TYPE) IS     
       SELECT sda.cdcooper
             ,sda.nrdconta
             ,sda.dtmvtolt
             ,sda.vllimcre -- Valor de limite de credito
             ,sda.vllimutl -- valor do limite utilizado
             ,sda.vladdutl -- Valor do ADP
             ,sda.vlsddisp
         FROM crapsda sda
        WHERE sda.cdcooper = pr_cdcooper
          AND sda.nrdconta = pr_nrdconta
          AND sda.dtmvtolt = to_date('07/01/2022', 'dd/mm/RRRR')
        ORDER BY sda.dtmvtolt;
    rw_crapsda cr_crapsda%ROWTYPE;
       
   CURSOR cr_crapsld(pr_cdcooper IN crapsld.cdcooper%TYPE    
                    ,pr_nrdconta IN crapsld.nrdconta%TYPE) IS    
     SELECT sld.vlsmnmes
           ,sld.vlsmnesp
           ,sld.vlsdchsl
           ,sld.vliofmes
       FROM crapsld sld
      WHERE sld.cdcooper = pr_cdcooper
        AND sld.nrdconta = pr_nrdconta;
    rw_crapsld cr_crapsld%ROWTYPE;
       
   CURSOR cr_ioflanc(pr_cdcooper IN tbgen_iof_lancamento.cdcooper%TYPE    
                    ,pr_nrdconta IN tbgen_iof_lancamento.nrdconta%TYPE) IS 
     SELECT IDLANCTO
           ,CDCOOPER
           ,NRDCONTA
           ,DTMVTOLT
           ,TPPRODUTO
           ,TPIOF
           ,NRCONTRATO
           ,IDLAUTOM
           ,DTMVTOLT_LCM
           ,CDAGENCI_LCM
           ,CDBCCXLT_LCM
           ,NRDOLOTE_LCM
           ,NRSEQDIG_LCM
           ,INIMUNIDADE
           ,VLIOF
           ,NRPARCELA_EPR
           ,VLIOF_PRINCIPAL
           ,VLIOF_ADICIONAL
           ,VLIOF_COMPLEMENTAR
           ,VLTAXAIOF_PRINCIPAL
           ,VLTAXAIOF_ADICIONAL
           ,NRACORDO
           ,IDLANCTO_PREJUIZO
       FROM tbgen_iof_lancamento a
      WHERE a.cdcooper = pr_cdcooper
        AND a.nrdconta = pr_nrdconta
        AND a.tpproduto = 5
        AND a.tpiof IN (1, 2)
        AND a.dtmvtolt = to_date('07/01/2022', 'dd/mm/RRRR');
    rw_ioflanc cr_ioflanc%ROWTYPE;
    
    
BEGIN 
  
--##################################################################################### 
  -- Definir em qual ambiente ira buscar os arquivos para leitura/escrita
  IF vr_aux_ambiente = 1 THEN --LOCAL      
    vr_nmarq_carga    := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';           -- Arquivo a ser lido
    vr_nmarq_log      := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';       -- Arquivo de Log
    vr_nmarq_rollback := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';  -- Arquivo de Rollback 
  ELSIF vr_aux_ambiente = 2 THEN --TEST        
    vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';          -- Arquivo a ser lido
    vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      -- Arquivo de Log
    vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; -- Arquivo de Rollback   
  ELSIF vr_aux_ambiente = 3 THEN --PRODUCAO
    vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';          -- Arquivo a ser lido
    vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      -- Arquivo de Log
    vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; -- Arquivo de Rollback
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
  
          EXCEPTION
            WHEN OTHERS THEN
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                            ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' --> ' || SQLERRM);
              
            CONTINUE;
          END;             

          -- Alimentar vetor com dados do arquivo
          vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
          vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;

          
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
                                    ,pr_des_text => 'Coop;Conta;Critica - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));

   
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
             vr_aux_adp7 := 0;          
             vr_aux_lim7 := 0; 
             vr_ttl_vlsmnmes := 0;
             vr_ttl_vlsmnesp := 0;
             vr_aux_vliofmes := 0;
             vr_aux_ttliof   := 0;
          
             -- Buscar lancamento do dia 07/01
             FOR rw_crapsda IN cr_crapsda(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                         ,pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta) LOOP
                vr_tab_carga_sda(vr_idx1).vllimcre  := rw_crapsda.vllimcre;
                vr_tab_carga_sda(vr_idx1).vllimutl7 := rw_crapsda.vllimutl;
                vr_tab_carga_sda(vr_idx1).vladdutl7 := rw_crapsda.vladdutl;                   
             END LOOP;
          
             -- Buscar informacoes do saldo
             OPEN cr_crapsld(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper,
                             pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta);
             FETCH cr_crapsld INTO rw_crapsld;
             CLOSE cr_crapsld;


            /*### ADP ###*/
            --Se conta estava COM ADP lancado no dia 07/01
            IF NVL(vr_tab_carga_sda(vr_idx1).vladdutl7,0) > 0  THEN 
               --Se vlsmnmes possui valor lancado, o campo deve ser atualizado, valor atual(negativo) mais o valor calculado de ADP para o dia 07/01
               IF NVL(rw_crapsld.vlsmnmes,0) < 0 THEN
                 vr_aux_adp7 := round(NVL(vr_tab_carga_sda(vr_idx1).vladdutl7,0) / rw_crapdat.qtdiaute,2);
               END IF;
 
            END IF;  
            /*### FIM ADP ###*/
 
            
            /*### Limite de credito ###*/
            --Se conta tinha limite de credito utilizado no dia 07/01
            IF NVL(vr_tab_carga_sda(vr_idx1).vllimutl7,0) > 0  THEN 
               IF NVL(rw_crapsld.vlsmnesp,0) < 0 THEN
                  vr_aux_lim7 := round(NVL(vr_tab_carga_sda(vr_idx1).vllimutl7,0) / rw_crapdat.qtdiaute,2);
               END IF;
            END IF;  
            /*### FIM Limite de credito ###*/
            
            
            
            FOR rw_ioflanc IN cr_ioflanc(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                        ,pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta) LOOP 
                                        
             vr_aux_ttliof := NVL(vr_aux_ttliof,0) + NVL(rw_ioflanc.vliof,0); 
             
             --#######
             BEGIN
                DELETE tbgen_iof_lancamento a
                 WHERE cdcooper = vr_tab_carga(vr_idx1).cdcooper
                   AND nrdconta = vr_tab_carga(vr_idx1).nrdconta
                   AND a.tpproduto = 5
                   AND a.tpiof IN (1,2)
                   AND a.dtmvtolt = to_date('07/01/2022', 'dd/mm/RRRR');
             EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar o lancamento: (tbgen_iof_lancamento)' || SQLERRM;
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                              vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                              vr_dscritic);                                               
            END;  
                                     
            -- Grava script de rollback
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                          ,pr_des_text => 'INSERT INTO tbgen_iof_lancamento(IDLANCTO,CDCOOPER,NRDCONTA,DTMVTOLT,TPPRODUTO,TPIOF,NRCONTRATO,IDLAUTOM,DTMVTOLT_LCM,CDAGENCI_LCM,CDBCCXLT_LCM,NRDOLOTE_LCM,NRSEQDIG_LCM,INIMUNIDADE,VLIOF,NRPARCELA_EPR,VLIOF_PRINCIPAL,VLIOF_ADICIONAL,VLIOF_COMPLEMENTAR,VLTAXAIOF_PRINCIPAL,VLTAXAIOF_ADICIONAL,NRACORDO,IDLANCTO_PREJUIZO)
                                                        VALUES('|| rw_ioflanc.idlancto ||',' || rw_ioflanc.cdcooper ||',' || rw_ioflanc.nrdconta ||',' || 'to_date('|| ''''|| rw_ioflanc.dtmvtolt ||'''' ||',' || '''dd/mm/RRRR''' || ')' ||',' || rw_ioflanc.tpproduto ||',' || rw_ioflanc.tpiof ||',' || rw_ioflanc.nrcontrato || ',' || ''''||rw_ioflanc.idlautom||''''||','|| '''' || rw_ioflanc.dtmvtolt_lcm || ''''||',' || ''''||rw_ioflanc.cdagenci_lcm||''''||',' || ''''||rw_ioflanc.cdbccxlt_lcm||''''||',' || ''''||rw_ioflanc.nrdolote_lcm||''''||',' || ''''||rw_ioflanc.nrseqdig_lcm||''''|| ',' || ''''||rw_ioflanc.inimunidade||''''||
                                                            ',' || REPLACE(rw_ioflanc.vliof,',','.')||',' || ''''||rw_ioflanc.nrparcela_epr||''''||',' || ''''||rw_ioflanc.vliof_principal||''''||',' || ''''||rw_ioflanc.vliof_adicional||''''|| ',' || ''''||rw_ioflanc.vliof_complementar||''''||',' || ''''||rw_ioflanc.vltaxaiof_principal||''''|| ',' || ''''||rw_ioflanc.vltaxaiof_adicional||'''' || ',' || ''''||rw_ioflanc.nracordo||''''|| ',' || ''''||rw_ioflanc.idlancto_prejuizo||''''|| ');'); 
            END LOOP;
           
            /*### Calculo ADP ###*/
            vr_ttl_vlsmnmes := NVL(rw_crapsld.vlsmnmes,0) + NVL(vr_aux_adp7,0);
           
          
           /*### Calculo Limite ###*/
            vr_ttl_vlsmnesp := NVL(rw_crapsld.vlsmnesp,0) + NVL(vr_aux_lim7,0);

            
            /*### IOF ###*/
            --Abater o valor de IOF calculado para o lancamento do PIX no dia 07/01
            vr_aux_vliofmes := NVL(rw_crapsld.vliofmes,0) - NVL(vr_aux_ttliof,0); 
            /*### FIM IOF ###*/
            
           
            --#######   
            BEGIN
              UPDATE crapsld SET
                     vlsmnmes = vr_ttl_vlsmnmes,
                     vlsmnesp = vr_ttl_vlsmnesp,
                     vliofmes = vr_aux_vliofmes
               WHERE cdcooper = vr_tab_carga(vr_idx1).cdcooper
                 AND nrdconta = vr_tab_carga(vr_idx1).nrdconta;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao ajustar o saldo: (crapsld)' || SQLERRM;
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                              vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                              vr_dscritic);                                              
            END;

            -- Grava script de rollback
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                        ,pr_des_text => 'UPDATE crapsld SET '
                                                        ||' vlsmnmes = '|| REPLACE(rw_crapsld.vlsmnmes, ',','.')
                                                        ||' ,vlsmnesp = '|| REPLACE(rw_crapsld.vlsmnesp, ',','.')
                                                        ||' ,vliofmes = '|| REPLACE(rw_crapsld.vliofmes, ',','.')
                                                        ||' WHERE cdcooper = '||vr_tab_carga(vr_idx1).cdcooper
                                                        ||'   AND nrdconta = '||vr_tab_carga(vr_idx1).nrdconta ||';');

            
            COMMIT;

          END IF;
          
          -- Grava commit script de rollback
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                        ,pr_des_text => 'COMMIT;');
                                        
      END LOOP;
  
      
 --#####################################################################################
      -- Fechar arquivo de Rollback e log  
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,pr_des_text => 'COMMIT;');
      
      -- Escrever horario de fim 
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Horario de fim da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
          
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);              
--#####################################################################################       
      
      
      
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
