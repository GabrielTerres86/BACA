CREATE OR REPLACE PROCEDURE CECRED.pc_crps706 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                              ,pr_flgresta IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da critica
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da critica
  BEGIN
  /* ............................................................................

     Programa: pc_crps706  
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei - RKAM
     Data    : Julho/2016                         Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diario (CRON).
     Objetivo  : Integrar arquivos CNAB

     Alteracao :                

  ............................................................................ */

    DECLARE

      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrdocnpj
              ,cop.cdagedbb
              ,cop.dsdircop
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Selecionar os dados de cada Cooperativa
      CURSOR cr_crapcoop IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.dsdircop
        FROM crapcop cop
        WHERE cop.cdcooper <> 3;
      rw_crapcoop cr_crapcop%ROWTYPE;
      
      CURSOR cr_crapccc(pr_cdcooper IN crapccc.cdcooper%TYPE) IS 
      SELECT ccc.nrdconta 
        FROM crapccc ccc 
       WHERE ccc.cdcooper = pr_cdcooper AND -- Cooperativa
             ccc.idretorn = 2           AND --(FTP)
             ccc.flghomol = 1;              -- homologado
      
      -- Codigo do programa
      vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS678';
      -- Tratamento de erros
      vr_exc_saida    EXCEPTION;
      vr_exc_fimprg   EXCEPTION;
      vr_exc_erro     EXCEPTION;            
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      vr_typ_saida    VARCHAR2(3);
    
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;

      --Variaveis de Arquivo
      vr_input_file  utl_file.file_type;

      -- Diretorios das cooperativas
      vr_caminho_cooper  VARCHAR2(200);
      vr_caminho_arq     VARCHAR2(200);
      vr_caminho_conta   VARCHAR2(200);
      vr_script_cust     VARCHAR2(200);

      -- variaveis de controle de comandos shell
      vr_listadir      VARCHAR2(4000);
      vr_listadir_cnab VARCHAR2(4000);
      vr_chave         VARCHAR2(100);

      -- variáveis de controle de arquivos
      vr_setlinha     VARCHAR2(298);
      
      -- variáveis de paramatros ftp
      vr_serv_ftp     VARCHAR2(100);
      vr_user_ftp     VARCHAR2(100);
      vr_pass_ftp     VARCHAR2(100);
      vr_comando_ftp  VARCHAR2(300);
      
      -- variáveis auxiliares
      vr_nrremess    craphcc.nrremret%TYPE;
      vr_nrremret    craphcc.nrremret%TYPE;
      vr_des_reto    VARCHAR2(10);
      vr_tparquiv    VARCHAR2(100);
      vr_cddbanco    INTEGER;
      vr_nrdconta    crapass.nrdconta%TYPE;
      vr_hrtransa    INTEGER;
      vr_nrprotoc    VARCHAR2(200);
      
      --Tabela para receber arquivos lidos no unix
      vr_tab_arquivo     gene0002.typ_split := gene0002.typ_split();
      
      --Tabela para receber rejeicoes
      vr_tab_rejeita     COBR0006.typ_tab_rejeita; 
      vr_tab_crawrej     COBR0006.typ_tab_crawrej;
    
                  
      TYPE typ_reg_cratarq IS 
        RECORD(nrdconta craphcc.nrdconta%TYPE
              ,nrconven VARCHAR2(100)
              ,nmarquiv VARCHAR2(100)
              ,nrsequen INTEGER);              
      TYPE typ_tab_cratarq IS
        TABLE OF typ_reg_cratarq
          INDEX BY VARCHAR2(100);
      vr_tab_cratarq typ_tab_cratarq; 
  
    -- INICIO
    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop( pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
    
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Busca nome do servidor
      vr_serv_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_SERV_FTP'); 
      -- Busca nome de usuario                                                
      vr_user_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_USER_FTP');
      -- Busca senha do usuario
      vr_pass_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_PASS_FTP');                                              
      -- Busca caminho do script                                        
      vr_script_cust := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => '0'
                                                 ,pr_cdacesso => 'SCRIPT_ENV_REC_ARQ_CUST');                                                                                            

      FOR rw_crapcoop IN cr_crapcoop LOOP
        
        BEGIN
          
          -- Leitura do calendário da cooperativa
          OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcoop.cdcooper);
          
          FETCH btch0001.cr_crapdat INTO rw_crapdat;
          
          -- Se não encontrar
          IF btch0001.cr_crapdat%NOTFOUND THEN
            
            -- Fechar o cursor pois efetuaremos raise
            CLOSE btch0001.cr_crapdat;
            
            -- Montar mensagem de critica
            vr_cdcritic := 1;
            
            -- gera excecao
            RAISE vr_exc_erro;
            
          ELSE
            -- Apenas fechar o cursor
            CLOSE btch0001.cr_crapdat;
          END IF;
          
          IF rw_crapdat.inproces <> 1 THEN
            CONTINUE;
          END IF;
          
          IF vr_tab_arquivo.count() > 0 THEN
            -- Limpa tabela
            vr_tab_arquivo.delete;
          END IF;
          
          -- Busca o diretorio da cooperativa conectada
          vr_caminho_cooper := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                     ,pr_cdcooper => rw_crapcoop.cdcooper
                                                     ,pr_nmsubdir => '');
                                                     
          -- Setando os diretorios auxiliares
          vr_caminho_arq     := vr_caminho_cooper||'/upload';              
          
          FOR rw_crapccc IN cr_crapccc(rw_crapcoop.cdcooper) LOOP
      
            vr_caminho_conta := rw_crapcoop.dsdircop || '/' || 
                                TRIM(to_char(rw_crapccc.nrdconta)) || '/REMESSA';
            vr_comando_ftp := vr_script_cust                                        || ' ' || 
            '-recebe'                                                               || ' ' || 
            '-srv '          || vr_serv_ftp                                         || ' ' ||  
            '-usr '          || vr_user_ftp                                         || ' ' ||
            '-arq ''CST*.REM,CBR_*'''                                               || ' ' ||
            '-pass '         || vr_pass_ftp                                         || ' ' || 
            '-dir_local '''  || vr_caminho_arq   || ''''                            || ' ' || -- /usr/coop/<cooperativa>/upload
            '-dir_remoto ''' || vr_caminho_conta || ''''                            || ' ' || -- <cooperativa>/<conta do cooperado>/REMESSA 
            '-move_remoto ''/' || vr_caminho_conta  || '/PROC'''                    || ' ' || -- /<conta do cooperado>/REMESSA/PROC 
            '-log /usr/coop/' || rw_crapcoop.dsdircop || '/log/cst_por_arquivo.log' || ' ' || -- /usr/coop/<cooperativa>/log/cst_por_arquivo.log
            '-UC';
                        
            -- Chama procedure de envio e recebimento via ftp
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => vr_comando_ftp
                                 ,pr_flg_aguard  => 'S'                             
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_dscritic);
          
             -- Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando_ftp || 
                            ' - Erro: ' || vr_dscritic;
              RAISE vr_exc_erro;
            END IF;

          END LOOP;
                    
          --Listar arquivos
          gene0001.pc_lista_arquivos( pr_path     => vr_caminho_arq
                                     ,pr_pesq     => 'CBR_%'
                                     ,pr_listarq  => vr_listadir_cnab
                                     ,pr_des_erro => vr_dscritic);

          -- se ocorrer erro ao recuperar lista de arquivos
          -- registra no log
          IF TRIM(vr_dscritic) IS NOT NULL THEN             
             RAISE vr_exc_erro;
          END IF;

          /* Nao existem arquivos para serem importados */
          IF TRIM(vr_listadir_cnab) IS NULL THEN
            -- Finaliza o programa mantendo o processamento da cadeia
            vr_dscritic := 'Nao existem arquivos para serem importados';
            RAISE vr_exc_fimprg;
          END IF;
          
          /*###########################################
          
                Importação de arquivos CNAB  
                
          ###########################################*/
          --Carregar a lista de arquivos na temp table
          vr_tab_arquivo := gene0002.fn_quebra_string(pr_string => vr_listadir_cnab);

          -- Se retornou informacoes na temp table
          IF vr_tab_arquivo.count() > 0 THEN
            
            -- Processa todos os arquivos encontrados
            FOR vr_ind IN vr_tab_arquivo.first .. vr_tab_arquivo.last LOOP
              
              --Pega o numero da conta do arquivo em questao
              vr_nrdconta := gene0002.fn_busca_entrada(pr_postext => 2
                                                      ,pr_dstext  => vr_tab_arquivo(vr_ind)
                                                      ,pr_delimitador => '_');
                                                      
              -- alterar permissao do arquivo
              gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||
                                                            vr_caminho_arq || '/' || 
                                                            vr_tab_arquivo(vr_ind));   
                                                                                     
              COBR0006.pc_valida_arquivo_cobranca(pr_cdcooper    => rw_crapcoop.cdcooper    --> Codigo da cooperativa
                                                 ,pr_nmarqint    => vr_caminho_arq || '/' ||  vr_tab_arquivo(vr_ind)    --> Nome do arquivo a ser validado
                                                 ,pr_rec_rejeita => vr_tab_rejeita --> Dados invalidados
                                                 ,pr_des_reto    => vr_des_reto);  --> Retorno OK/NOK
               
              IF vr_tab_rejeita.count() > 0 THEN
                     
                vr_dscritic := 'Erro ao abrir arquivo ' || vr_tab_arquivo(vr_ind) || '--> ' || 'Arquivo com rejeicoes.';                                 
                                         
              ELSE
                
                vr_dscritic:= 'Erro ao abrir arquivo ' || vr_tab_arquivo(vr_ind) || '--> ' || 'Nao foi possivel validar o arquivo de cobranca.';
                                    
              END IF;
                
              btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcoop.cdcooper,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '|| vr_cdprogra ||' --> ' || vr_dscritic                                                               ,
                                         pr_nmarqlog     => 'cnab_por_arquivo.log');
                
              -- Ignora arquivo, pula para o próximo                                           
              CONTINUE;  
                                                                  
              COBR0006.pc_identifica_arq_cnab(pr_cdcooper => rw_crapcoop.cdcooper                              --> Codigo da cooperativa
                                             ,pr_nmarqint => vr_caminho_arq || '/' ||  vr_tab_arquivo(vr_ind) --> Nome do arquivo
                                             ,pr_tparquiv => vr_tparquiv               --> Tipo do arquivo
                                             ,pr_cddbanco => vr_cddbanco               --> Codigo do banco
                                             ,pr_nrdconta => vr_nrdconta               --> Numero da conta
                                             ,pr_rec_rejeita => vr_tab_rejeita         --> Dados invalidados
                                             ,pr_cdcritic => vr_cdcritic               --> Código da critica
                                             ,pr_dscritic => vr_dscritic               -->Descrição da critica
                                             ,pr_des_reto => vr_des_reto) ;            --> Retorno OK/NOK  
          
              IF vr_tab_rejeita.count() > 0 THEN
                    
                vr_dscritic:= 'Erro ao abrir arquivo ' || vr_tab_arquivo(vr_ind) || '--> ' || 'Arquivo com rejeicoes.';
                
                btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcoop.cdcooper,
                                           pr_ind_tipo_log => 2, --> erro tratado
                                           pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                              ' - '||vr_cdprogra ||' --> ' || vr_dscritic                                                               ,
                                           pr_nmarqlog     => 'cnab_por_arquivo.log');
                                             
                -- Ignora arquivo, pula para o próximo                                           
                CONTINUE;  
                                         
              ELSIF vr_des_reto <> 'OK' THEN
                  
                vr_dscritic:= 'Erro ao abrir arquivo ' || vr_tab_arquivo(vr_ind) || '--> ' || 'Nao foi possivel identificar o arquivo de cobranca.';
                
                btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcoop.cdcooper,
                                           pr_ind_tipo_log => 2, --> erro tratado
                                           pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                              ' - '||vr_cdprogra ||' --> ' || vr_dscritic                                                               ,
                                           pr_nmarqlog     => 'cnab_por_arquivo.log');
                                             
                -- Ignora arquivo, pula para o próximo                                           
                CONTINUE;   
                  
              END IF;                                                       
              
              IF NOT (vr_tparquiv = 'CNAB240' AND
                      vr_cddbanco = 1 )       AND
                 NOT (vr_tparquiv = 'CNAB240' AND
                      vr_cddbanco = 85)       AND
                 NOT (vr_tparquiv = 'CNAB400' AND
                      vr_cddbanco = 85)       THEN
              
                btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcoop.cdcooper,
                                           pr_ind_tipo_log => 2, --> erro tratado
                                           pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                              ' - '||vr_cdprogra ||' --> ' || 'Erro ao abrir arquivo ' || vr_tab_arquivo(vr_ind) || '--> ' || 'Formato de arquivo invalido.'                                                              ,
                                           pr_nmarqlog     => 'cnab_por_arquivo.log');
                                             
                -- Ignora arquivo, pula para o próximo                                           
                CONTINUE;
              
              END IF;   
              
              IF vr_tparquiv = 'CNAB240' AND
                 vr_cddbanco = 1         THEN
                   
                COBR0006.pc_intarq_remes_cnab240_001(pr_cdcooper  => rw_crapcoop.cdcooper   --> Codigo da cooperativa
                                                    ,pr_nrdconta  => vr_nrdconta   --> Numero da conta do cooperado
                                                    ,pr_nmarquiv  => vr_caminho_arq || '/' ||  vr_tab_arquivo(vr_ind)   --> Nome do arquivo a ser importado               
                                                    ,pr_idorigem  => 1             --> Identificador de origem
                                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt   --> Data do movimento
                                                    ,pr_cdoperad  => '996'             --> Codigo do operador
                                                    ,pr_nmdatela  => 'INTERNETBANK'   --> Nome da Tela
                                                    ,pr_tab_crawrej => vr_tab_crawrej --> Registros rejeitados
                                                    ,pr_hrtransa  => vr_hrtransa   --> Hora da transacao
                                                    ,pr_nrprotoc  => vr_nrprotoc   --> Numero do Protocolo
                                                    ,pr_des_reto  => vr_des_reto   --> OK ou NOK
                                                    ,pr_cdcritic  => vr_cdcritic   --> Codigo de critica
                                                    ,pr_dscritic  => vr_dscritic); --> Descricao da critica
                   
              ELSIF vr_tparquiv = 'CNAB240' AND
                    vr_cddbanco = 85        THEN
                      
                COBR0006.pc_intarq_remes_cnab240_085(pr_cdcooper  => rw_crapcoop.cdcooper   --> Codigo da cooperativa
                                                    ,pr_nrdconta  => vr_nrdconta   --> Numero da conta do cooperado
                                                    ,pr_nmarquiv  => vr_caminho_arq || '/' ||  vr_tab_arquivo(vr_ind)  --> Nome do arquivo a ser importado               
                                                    ,pr_idorigem  => 1             --> Identificador de origem
                                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt   --> Data do movimento
                                                    ,pr_cdoperad  => '996'   --> Codigo do operador
                                                    ,pr_nmdatela  => 'INTERNETBANK'   --> Nome da Tela
                                                    ,pr_tab_crawrej => vr_tab_crawrej --> Registros rejeitados
                                                    ,pr_hrtransa  => vr_hrtransa   --> Hora da transacao
                                                    ,pr_nrprotoc  => vr_nrprotoc   --> Numero do Protocolo
                                                    ,pr_des_reto  => vr_des_reto   --> OK ou NOK
                                                    ,pr_cdcritic  => vr_cdcritic   --> Codigo de critica
                                                    ,pr_dscritic  => vr_dscritic); --> Descricao da critica
                    
                
              ELSIF vr_tparquiv = 'CNAB400' AND
                    vr_cddbanco = 85        THEN
                      
                COBR0006.pc_intarq_remes_cnab400_085(pr_cdcooper  => rw_crapcoop.cdcooper --> Codigo da cooperativa
                                                    ,pr_nrdconta  => vr_nrdconta --> Numero da conta do cooperado
                                                    ,pr_nmarquiv  => vr_caminho_arq || '/' ||  vr_tab_arquivo(vr_ind) --> Nome do arquivo a ser importado               
                                                    ,pr_idorigem  => 1           --> Identificador de origem
                                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento
                                                    ,pr_cdoperad  => '996' --> Codigo do operador
                                                    ,pr_nmdatela  => 'INTERNETBANK' --> Nome da Tela
                                                    ,pr_tab_crawrej => vr_tab_crawrej --> Registros rejeitados
                                                    ,pr_hrtransa  => vr_hrtransa --> Hora da transacao
                                                    ,pr_nrprotoc  => vr_nrprotoc --> Numero do Protocolo
                                                    ,pr_des_reto  => vr_des_reto --> OK ou NOK
                                                    ,pr_cdcritic  => vr_cdcritic --> Codigo de critica
                                                    ,pr_dscritic  => vr_dscritic);    
                  
              END IF;
                      
              IF vr_tab_crawrej.count() > 0 THEN
                    
                btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcoop.cdcooper,
                                           pr_ind_tipo_log => 2, --> erro tratado
                                           pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                              ' - '||vr_cdprogra ||' --> ' || 'Erro ao abrir arquivo ' || vr_tab_arquivo(vr_ind) || '--> ' || 'Arquivo com rejeicoes.',
                                           pr_nmarqlog     => 'cnab_por_arquivo.log');
                                                                        
                -- Ignora arquivo, pula para o próximo                                           
                CONTINUE;
                                         
              ELSIF vr_des_reto <> 'OK' THEN
                  
                btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcoop.cdcooper,
                                           pr_ind_tipo_log => 2, --> erro tratado
                                           pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                              ' - '||vr_cdprogra ||' --> ' || 'Erro ao abrir arquivo ' || vr_tab_arquivo(vr_ind) || '--> ' || 'Nao foi possivel identificar o arquivo de cobranca.',
                                           pr_nmarqlog     => 'cnab_por_arquivo.log');
                                                                        
                -- Ignora arquivo, pula para o próximo                                           
                CONTINUE; 
                                                                       
              END IF;
              
            END LOOP;
          
          END IF;      
 
         -- Efetuar commit por cooperativa
         COMMIT;  
         
         EXCEPTION
           WHEN vr_exc_erro THEN
             -- Se foi retornado apenas codigo
             IF NVL(vr_cdcritic, 0) > 0 AND trim(vr_dscritic) IS NULL THEN
               -- Buscar a descricao
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             END IF;
            
             IF NVL(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
               -- Envio centralizado de log de erro
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                          pr_ind_tipo_log => 2, --> erro tratado
                                          pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                             ' - '||vr_cdprogra ||' --> ' || vr_cdcritic || vr_dscritic,
                                          pr_nmarqlog     => 'cnab_por_arquivo.log');
                   
             END IF;          
            
             vr_cdcritic := 0;
             vr_dscritic := NULL;
             -- Efetuar rollback          
             ROLLBACK;
             
           WHEN vr_exc_fimprg THEN
             -- Se foi retornado apenas codigo
             IF NVL(vr_cdcritic, 0) > 0 AND trim(vr_dscritic) IS NULL THEN
               -- Buscar a descricao
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             END IF;
             
             -- Se foi gerada critica para envio ao log
             IF NVL(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
               -- Envio centralizado de log de erro
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                          pr_ind_tipo_log => 2, --> erro tratado
                                          pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                             ' - '||vr_cdprogra ||' --> ' || vr_cdcritic || vr_dscritic,
                                          pr_nmarqlog     => 'cnab_por_arquivo.log');
             END IF;
            
             -- Efetuar commit pois gravaremos o que foi processo ateh entao
             COMMIT;
         END;
        
       END LOOP; -- FOR rw_crapcoop
           
       -- Efetuar Commit de informacoes pendentes de gravacao
       COMMIT;
       
     EXCEPTION
       WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas codigo
         IF NVL(vr_cdcritic, 0) > 0 AND trim(vr_dscritic) IS NULL THEN
           -- Buscar a descricao
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Se foi gerada critica para envio ao log
         IF NVL(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN           
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                      pr_ind_tipo_log => 2, --> erro tratado
                                      pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                         ' - '||vr_cdprogra ||' --> ' || vr_cdcritic || vr_dscritic,
                                      pr_nmarqlog     => 'cnab_por_arquivo.log');
         END IF;         
         -- Efetuar commit pois gravaremos o que foi processo ateh entao
         COMMIT;
       WHEN vr_exc_saida THEN
         -- Se foi retornado apenas codigo
         IF NVL(vr_cdcritic, 0) > 0 AND trim(vr_dscritic) IS NULL THEN
           -- Buscar a descricao
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos codigo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
         -- Efetuar rollback
         ROLLBACK;

       WHEN OTHERS THEN
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;
         -- Efetuar rollback
         ROLLBACK;

    END;
  END pc_crps706;
/
