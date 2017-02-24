CREATE OR REPLACE PROCEDURE CECRED.pc_crps778 (pr_dscritic OUT VARCHAR2) IS           --> Descricao da critica

  /* ............................................................................

     Programa: pc_crps778
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Julho/2016                         Ultima atualizacao: 22/02/2017

     Dados referentes ao programa:

     Frequencia: Diario (CRON).
     Objetivo  : Integrar arquivos de cobran�a via FTP

     Alteracao : 22/07/2016 - Cria��o do fonte crps778 (Odirlei-AMcom)             

                 25/08/2016 - Ajuste para mover o arquivo processado para o diret�rio salvar
                              (Andrei - RKAM).

                 14/02/2017 - Ajsute para efetuar o commit por arquivo e n�o mais por cooperativa
							                (Andrei - Mouts).
                              
                 22/02/2017 - #551199 Melhorias de performance e inclus�o de logs de controle de execu��o (Carlos)
  ............................................................................ */

  ------------------------------- CURSORES ---------------------------------
			
    -- Selecionar os dados de cada Cooperativa
    CURSOR cr_crapcoop IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.dsdircop
      FROM crapcop cop
      WHERE cop.cdcooper <> 3
        AND cop.flgativo = 1
      ORDER BY cop.cdcooper;
    rw_crapcoop cr_crapcoop%ROWTYPE;
			
    CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE) IS 
    SELECT ceb.nrdconta 
      FROM crapceb ceb 
     WHERE ceb.cdcooper = pr_cdcooper AND -- Cooperativa
           ceb.insitceb = 1           AND -- Ativo
           ceb.inenvcob = 2;              -- ftp
		  
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    --Tabela para receber arquivos lidos no unix
    vr_tab_arquivo     gene0002.typ_split := gene0002.typ_split();
      
    --Tabela para receber rejeicoes
    vr_tab_rejeita     COBR0006.typ_tab_rejeita; 
    vr_tab_crawrej     COBR0006.typ_tab_crawrej;    
                  
    TYPE typ_reg_cratarq IS 
      RECORD(nrdconta craphcc.nrdconta%TYPE
            ,nmarquiv VARCHAR2(100)
            ,nrsequen INTEGER);							
    TYPE typ_tab_cratarq IS
      TABLE OF typ_reg_cratarq
        INDEX BY VARCHAR2(100);
    vr_tab_cratarq typ_tab_cratarq;  
    
    ------------------------------- VARIAVEIS -------------------------------

    -- Codigo do programa
    vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS778';
      
    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;				
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
    vr_chave         VARCHAR2(100);
      
    -- vari�veis de paramatros ftp
    vr_serv_ftp     VARCHAR2(100);
    vr_user_ftp     VARCHAR2(100);
    vr_pass_ftp     VARCHAR2(100);
    vr_comando_ftp  VARCHAR2(500);
			
    -- vari�veis auxiliares
    vr_des_reto    VARCHAR2(10);
    vr_tparquiv    VARCHAR2(100);
    vr_cddbanco    INTEGER;
    vr_hrtransa    INTEGER;
    vr_nrprotoc    VARCHAR2(200);
    idx INTEGER;
	  
    --Enquanto nao existir operador "ftp", dever� usar o Internet
    vr_cdoperad     crapope.cdoperad%TYPE := '996'; 
    
    vr_dscomand     VARCHAR2(4000);
    vr_typ_said     VARCHAR2(500);    
                  
	--Variaveis novas em funcao da pc_identifica_arq_cnab    
    vr_rec_rejeita  COBR0006.typ_tab_rejeita;   --> Dados invalidados    
    vr_nrdconta     crapass.nrdconta%TYPE;

    vr_nomdojob  CONSTANT VARCHAR2(100) := 'jbcobran_crps778';
    vr_flgerlog  BOOLEAN := FALSE;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    PROCEDURE pc_gerar_log(pr_cdcooper crapcop.cdcooper%TYPE,
                           pr_dscdolog VARCHAR2)IS
      vr_dscdolog VARCHAR2(4000);
    BEGIN
    
      vr_dscdolog := to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' - '||vr_cdprogra ||' -> '||pr_dscdolog;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => vr_dscdolog, 
                                 pr_nmarqlog     => 'cobranca_por_arquivo' );
    END;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informa��o
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN

    --> Controlar gera��o de log de execu��o dos jobs 
    BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

  END pc_controla_log_batch;

  BEGIN
    --------------- VALIDACOES INICIAIS -----------------

    -- Executar apenas quando as cooperativas estiverem online
    IF btch0001.fn_cooperativas_online = FALSE THEN
      RETURN;
    END IF;

    -- Executar apenas em dias �teis na cecred
    IF gene0005.fn_valida_dia_util(pr_cdcooper => 3, pr_dtmvtolt => trunc(SYSDATE)) <> trunc(SYSDATE) THEN
      RETURN;
    END IF;

    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);

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
					
        -- Leitura do calend�rio da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcoop.cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        IF btch0001.cr_crapdat%NOTFOUND THEN            
          -- Fechar o cursor pois efetuaremos raise
          CLOSE btch0001.cr_crapdat;
          vr_cdcritic := 1;
          -- gera excecao
          RAISE vr_exc_erro;
        ELSE
          CLOSE btch0001.cr_crapdat;            
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
        vr_caminho_arq     := vr_caminho_cooper||'/upload/ftp';							
					
        FOR rw_crapceb IN cr_crapceb(rw_crapcoop.cdcooper) LOOP      
      
          vr_caminho_conta := rw_crapcoop.dsdircop || '/' || 
                              TRIM(to_char(rw_crapceb.nrdconta)) || '/REMESSA';
          vr_comando_ftp := vr_script_cust                                        || ' ' || 
          '-recebe'                                                               || ' ' || 
          '-srv '          || vr_serv_ftp                                         || ' ' ||  
          '-usr '          || vr_user_ftp                                         || ' ' ||
          '-arq ''CBR_*'   || TRIM(to_char(rw_crapceb.nrdconta)) || '*.REM'''     || ' ' ||
          '-pass '         || vr_pass_ftp                                         || ' ' || 
          '-dir_local '''  || vr_caminho_arq   || ''''                            || ' ' || -- /usr/coop/<cooperativa>/upload
          '-dir_remoto ''' || vr_caminho_conta || ''''                            || ' ' || -- <cooperativa>/<conta do cooperado>/REMESSA 
          '-move_remoto ''/' || vr_caminho_conta  || '/PROC'''                    || ' ' || -- <cooperativa>/<conta do cooperado>/REMESSA/PROC 
          '-log /usr/coop/' || rw_crapcoop.dsdircop || '/log/cbr_por_arquivo.log' || ' ' || -- /usr/coop/<cooperativa>/log/cbr_por_arquivo.log
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

        --Listar arquivos de custodia
        gene0001.pc_lista_arquivos( pr_path     => vr_caminho_arq
                                   ,pr_pesq     => 'CBR%.REM'
                                   ,pr_listarq  => vr_listadir
                                   ,pr_des_erro => vr_dscritic);

        -- se ocorrer erro ao recuperar lista de arquivos
        -- registra no log
        IF TRIM(vr_dscritic) IS NOT NULL THEN			
          -- Registrar Log;
          pc_gerar_log(pr_cdcooper => rw_crapcoop.cdcooper,
                       pr_dscdolog => vr_dscritic);
        END IF;
          
        /* Nao existem arquivos para serem importados */
        IF TRIM(vr_listadir) IS NULL THEN
          -- Registrar Log;
          pc_gerar_log(pr_cdcooper => rw_crapcoop.cdcooper,
                       pr_dscdolog => 'Nao existem arquivos para serem importados');                                 
        END IF;                  
          
        --Carregar a lista de arquivos na temp table
        vr_tab_arquivo.delete;
        vr_tab_cratarq.delete;
        vr_tab_arquivo := gene0002.fn_quebra_string(pr_string => vr_listadir);

        -- Se retornou informacoes na temp table
        IF vr_tab_arquivo.count() > 0 THEN
          
          pc_controla_log_batch('I'); -- logar� o in�cio da execu��o assim que encontrar o primeiro arquivo
            
          -- carrega informacoes na cratarq
          FOR vr_ind IN vr_tab_arquivo.first .. vr_tab_arquivo.last LOOP
              
            -- Monta a chave da temp-table
            vr_chave := rpad(vr_tab_arquivo(vr_ind),55,'#')|| lpad(rw_crapcoop.cdcooper,2,'0')||lpad(vr_ind,4,'0');
              
            -- alterar permissao do arquivo
            gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||
                                                          vr_caminho_arq || '/' || 
                                                          vr_tab_arquivo(vr_ind));     
                                                                                   
            -- Abre o arquivo em modo de leitura
            gene0001.pc_abre_arquivo (pr_nmcaminh => vr_caminho_arq || '/' || 
                                                     vr_tab_arquivo(vr_ind)    --> Diret�rio do arquivo
                                     ,pr_tipabert => 'R'                       --> Modo de abertura (R,W,A)
                                     ,pr_utlfileh => vr_input_file             --> Handle do arquivo aberto
                                     ,pr_des_erro => vr_dscritic);             --> Descricao do erro
		                                  
            -- Se retornou erro
            IF  vr_dscritic IS NOT NULL  THEN
                -- Registrar Log;
                pc_gerar_log(pr_cdcooper => rw_crapcoop.cdcooper,
                             pr_dscdolog => 'Erro ao abrir arquivo ' || vr_tab_arquivo(vr_ind) || '--> ' || vr_dscritic);
                                               
                -- Ignora arquivo, pula para o pr�ximo                                           
                CONTINUE;
                  
            END IF;

            -- Verifica se o arquivo esta aberto
            IF  utl_file.IS_OPEN(vr_input_file) THEN
                --Fechar o arquivo para pc_identifica_arq ler e identificar o tipo, banco e conta
                utl_file.fclose(vr_input_file);
                
                -- Rafael: identificar arquivo cnab
                cobr0006.pc_identifica_arq_cnab(pr_cdcooper => rw_crapcoop.cdcooper
                                              , pr_nmarqint => vr_caminho_arq || '/' || vr_tab_arquivo(vr_ind)    --> Diret�rio do arquivo
                                              , pr_tparquiv => vr_tparquiv
                                              , pr_cddbanco => vr_cddbanco
                                              , pr_nrdconta => vr_nrdconta
                                              , pr_rec_rejeita => vr_rec_rejeita
                                              , pr_cdcritic => vr_cdcritic
                                              , pr_dscritic => vr_dscritic
                                              , pr_des_reto => vr_des_reto);
                                              
                -- carrega a temp-table com a lista de arquivos que devem ser processados e dados do header                                                        
                vr_tab_cratarq(vr_chave).nmarquiv := vr_tab_arquivo(vr_ind);
                vr_tab_cratarq(vr_chave).nrsequen := to_number(vr_ind);
                vr_tab_cratarq(vr_chave).nrdconta := vr_nrdconta;
                
                
            END IF;                                   

          END LOOP;
					
        END IF;      

        /*--------------------------  Processa arquivos  -------------------------*/
		      
        IF vr_tab_cratarq.COUNT() > 0 THEN
          -- Atribui � chave o primeiro registro da vr_tab_cratarq
          vr_chave := vr_tab_cratarq.FIRST;
  		      
          LOOP
            -- Sai quando nao houver mais registros na vr_tab_cratarq
            EXIT WHEN vr_chave IS NULL;
            
            vr_tab_rejeita.delete;
            
            -- Rotina para validar arquivo de remessa  
            COBR0006.pc_valida_arquivo_cobranca
                                       (pr_cdcooper    => rw_crapcoop.cdcooper,    --> Codigo da cooperativa
                                        pr_nmarqint    => vr_caminho_arq || '/' ||vr_tab_cratarq(vr_chave).nmarquiv,  --> Nome do arquivo a ser validado
                                        pr_tpenvcob    => 2,                      --> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                                        pr_rec_rejeita => vr_tab_rejeita,         --> Dados invalidados
                                        pr_des_reto    => vr_des_reto);           --> Retorno OK/NOK            

            -- Se retornou erro
            IF vr_des_reto <> 'OK'  THEN                                            
              FOR idx IN vr_tab_rejeita.first..vr_tab_rejeita.last LOOP
                -- Gera log
               pc_gerar_log(pr_cdcooper => rw_crapcoop.cdcooper,
                            pr_dscdolog => 'Arquivo: '|| vr_tab_cratarq(vr_chave).nmarquiv||
                                           ',linha: ' || vr_tab_rejeita(idx).nrlinseq||
                                           ': '       || vr_tab_rejeita(idx).dscritic); 
              
              END LOOP; 
                           
              -- Arquivo possui erros criticos, aborta processo de valida��o
              COBR0006.pc_rejeitar_arquivo(pr_cdcooper => rw_crapcoop.cdcooper
                                          ,pr_nrdconta => vr_tab_cratarq(vr_chave).nrdconta
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_nmarquiv => vr_tab_cratarq(vr_chave).nmarquiv
                                          ,pr_idorigem => 3 --FTP pr_idorigem
                                          ,pr_cdoperad => vr_cdoperad
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
              
              IF nvl(vr_cdcritic,0) > 0 OR  
                 TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro; 
              END IF;   
            
              -- Erro ja esta sendo logado na procedure
              vr_cdcritic := 0;
              vr_dscritic := '';
              vr_chave := vr_tab_cratarq.NEXT(vr_chave);
              CONTINUE;                   
  					  	                                                  
            END IF;
            
            --> Identificar arquivo CNAB
            COBR0006.pc_identifica_arq_cnab(pr_cdcooper    => rw_crapcoop.cdcooper       --> Codigo da cooperativa
                                           ,pr_nmarqint    => vr_caminho_arq || '/' ||vr_tab_cratarq(vr_chave).nmarquiv --> Nome do arquivo
                                           ,pr_tparquiv    => vr_tparquiv                --> Tipo do arquivo
                                           ,pr_cddbanco    => vr_cddbanco                --> Codigo do banco
										   ,pr_nrdconta    => vr_nrdconta                --> Recebe nrdconta
                                           ,pr_rec_rejeita => vr_tab_rejeita             --> Tabela com rejeitados
                                           ,pr_cdcritic    => vr_cdcritic                --> C�digo da critica
                                           ,pr_dscritic    => vr_dscritic                --> Descri��o da critica
                                           ,pr_des_reto    => vr_des_reto);              --> Retorno OK/NOK                                    

            -- Se retornou erro
            IF vr_des_reto <> 'OK'  THEN                                            
              FOR idx IN vr_tab_rejeita.first..vr_tab_rejeita.last LOOP
                -- Gera log
                pc_gerar_log(pr_cdcooper => rw_crapcoop.cdcooper,
                             pr_dscdolog => 'Arquivo: '|| vr_tab_cratarq(vr_chave).nmarquiv||
                                            ',linha: ' || vr_tab_rejeita(idx).nrlinseq||
                                            ': '       || vr_tab_rejeita(idx).dscritic); 
              
              END LOOP; 
              
              IF nvl(vr_cdcritic,0) > 0 OR  
                 TRIM(vr_dscritic) IS NOT NULL THEN
                -- Gera log
                pc_gerar_log(pr_cdcooper => rw_crapcoop.cdcooper,
                             pr_dscdolog => 'Arquivo: '|| vr_tab_cratarq(vr_chave).nmarquiv||
                                            ': '       || vr_cdcritic||'-'||vr_dscritic); 
              END IF;
                           
              -- Arquivo possui erros criticos, aborta processo de valida��o
              COBR0006.pc_rejeitar_arquivo(pr_cdcooper => rw_crapcoop.cdcooper
                                          ,pr_nrdconta => vr_tab_cratarq(vr_chave).nrdconta
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_nmarquiv => vr_tab_cratarq(vr_chave).nmarquiv
                                          ,pr_idorigem => 3 --FTP pr_idorigem
                                          ,pr_cdoperad => vr_cdoperad
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
              
              IF nvl(vr_cdcritic,0) > 0 OR  
                 TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro; 
              END IF;   
            
              -- Erro ja esta sendo logado na procedure
              vr_cdcritic := 0;
              vr_dscritic := '';
              vr_chave := vr_tab_cratarq.NEXT(vr_chave);
              CONTINUE;                   
  					  	                                                  
            END IF;
            
            -- Apenas permitr layout CNAB
            IF NOT (vr_tparquiv = 'CNAB240' AND vr_cddbanco = 1 )       AND
               NOT (vr_tparquiv = 'CNAB240' AND vr_cddbanco = 85)       AND
               NOT (vr_tparquiv = 'CNAB400' AND vr_cddbanco = 85)       THEN
              -- Gera log
              pc_gerar_log(pr_cdcooper => rw_crapcoop.cdcooper,
                           pr_dscdolog => 'Arquivo: '|| vr_tab_cratarq(vr_chave).nmarquiv||
                                          ': '       || 'Formato de arquivo invalido.');               
                           
              -- Arquivo possui erros criticos, aborta processo de valida��o
              COBR0006.pc_rejeitar_arquivo(pr_cdcooper => rw_crapcoop.cdcooper
                                          ,pr_nrdconta => vr_tab_cratarq(vr_chave).nrdconta
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_nmarquiv => vr_tab_cratarq(vr_chave).nmarquiv
                                          ,pr_idorigem => 3 --FTP pr_idorigem
                                          ,pr_cdoperad => vr_cdoperad
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
              
              IF nvl(vr_cdcritic,0) > 0 OR  
                 TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro; 
              END IF;   
            
              -- Erro ja esta sendo logado na procedure
              vr_cdcritic := 0;
              vr_dscritic := '';
              vr_chave := vr_tab_cratarq.NEXT(vr_chave);
              CONTINUE;
            END IF;
            
            --> Processar arquivo conforme o seu layout 
            IF vr_tparquiv = 'CNAB240' AND
               vr_cddbanco = 1         THEN
                 
              COBR0006.pc_intarq_remes_cnab240_001(pr_cdcooper  => rw_crapcoop.cdcooper  --> Codigo da cooperativa
                                                  ,pr_nrdconta  => vr_tab_cratarq(vr_chave).nrdconta   --> Numero da conta do cooperado
                                                  ,pr_nmarquiv  => vr_caminho_arq || '/' ||vr_tab_cratarq(vr_chave).nmarquiv   --> Nome do arquivo a ser importado               
                                                  ,pr_idorigem  => 1                     --> Identificador de origem
                                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt   --> Data do movimento
                                                  ,pr_cdoperad  => vr_cdoperad           --> Codigo do operador
                                                  ,pr_nmdatela  => vr_cdprogra           --> Nome da Tela
                                                  ,pr_tab_crawrej => vr_tab_crawrej      --> Registros rejeitados
                                                  ,pr_hrtransa  => vr_hrtransa   --> Hora da transacao
                                                  ,pr_nrprotoc  => vr_nrprotoc   --> Numero do Protocolo
                                                  ,pr_des_reto  => vr_des_reto   --> OK ou NOK
                                                  ,pr_cdcritic  => vr_cdcritic   --> Codigo de critica
                                                  ,pr_dscritic  => vr_dscritic); --> Descricao da critica
                 
            ELSIF vr_tparquiv = 'CNAB240' AND
                  vr_cddbanco = 85        THEN
                    
              COBR0006.pc_intarq_remes_cnab240_085(pr_cdcooper  => rw_crapcoop.cdcooper  --> Codigo da cooperativa
                                                  ,pr_nrdconta  => vr_tab_cratarq(vr_chave).nrdconta   --> Numero da conta do cooperado
                                                  ,pr_nmarquiv  => vr_caminho_arq || '/' ||vr_tab_cratarq(vr_chave).nmarquiv   --> Nome do arquivo a ser importado               
                                                  ,pr_idorigem  => 1                     --> Identificador de origem
                                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt   --> Data do movimento
                                                  ,pr_cdoperad  => vr_cdoperad           --> Codigo do operador
                                                  ,pr_nmdatela  => vr_cdprogra           --> Nome da Tela
                                                  ,pr_tab_crawrej => vr_tab_crawrej --> Registros rejeitados
                                                  ,pr_hrtransa  => vr_hrtransa   --> Hora da transacao
                                                  ,pr_nrprotoc  => vr_nrprotoc   --> Numero do Protocolo
                                                  ,pr_des_reto  => vr_des_reto   --> OK ou NOK
                                                  ,pr_cdcritic  => vr_cdcritic   --> Codigo de critica
                                                  ,pr_dscritic  => vr_dscritic); --> Descricao da critica
                  
              
            ELSIF vr_tparquiv = 'CNAB400' AND
                  vr_cddbanco = 85        THEN
                    
              COBR0006.pc_intarq_remes_cnab400_085(pr_cdcooper  => rw_crapcoop.cdcooper  --> Codigo da cooperativa
                                                  ,pr_nrdconta  => vr_tab_cratarq(vr_chave).nrdconta   --> Numero da conta do cooperado
                                                  ,pr_nmarquiv  => vr_caminho_arq || '/' ||vr_tab_cratarq(vr_chave).nmarquiv   --> Nome do arquivo a ser importado               
                                                  ,pr_idorigem  => 1                     --> Identificador de origem
                                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt   --> Data do movimento
                                                  ,pr_cdoperad  => vr_cdoperad           --> Codigo do operador
                                                  ,pr_nmdatela  => vr_cdprogra           --> Nome da Tela
                                                  ,pr_tab_crawrej => vr_tab_crawrej --> Registros rejeitados
                                                  ,pr_hrtransa  => vr_hrtransa --> Hora da transacao
                                                  ,pr_nrprotoc  => vr_nrprotoc --> Numero do Protocolo
                                                  ,pr_des_reto  => vr_des_reto --> OK ou NOK
                                                  ,pr_cdcritic  => vr_cdcritic --> Codigo de critica
                                                  ,pr_dscritic  => vr_dscritic);    
                
            END IF;
  		      
            -- Se retornou erro
            IF vr_des_reto <> 'OK'  THEN                                            
              FOR idx IN vr_tab_crawrej.first..vr_tab_crawrej.last LOOP
                -- Gera log
                pc_gerar_log(pr_cdcooper => rw_crapcoop.cdcooper,
                             pr_dscdolog => 'Arquivo: '|| vr_tab_cratarq(vr_chave).nmarquiv||
                                            ',conta: ' || vr_tab_crawrej(idx).nrdconta||
                                            ',documento: ' || vr_tab_crawrej(idx).nrdocmto||
                                            ': '       || vr_tab_crawrej(idx).dscritic); 
              
              END LOOP; 
              
              IF nvl(vr_cdcritic,0) > 0 OR  
                 TRIM(vr_dscritic) IS NOT NULL THEN
                -- Gera log
                pc_gerar_log(pr_cdcooper => rw_crapcoop.cdcooper,
                             pr_dscdolog => 'Arquivo: '|| vr_tab_cratarq(vr_chave).nmarquiv||
                                            ': '       || vr_cdcritic||'-'||vr_dscritic); 
              END IF;
                           
              -- Arquivo possui erros criticos, aborta processo de valida��o
              COBR0006.pc_rejeitar_arquivo(pr_cdcooper => rw_crapcoop.cdcooper
                                          ,pr_nrdconta => vr_tab_cratarq(vr_chave).nrdconta
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_nmarquiv => vr_tab_cratarq(vr_chave).nmarquiv
                                          ,pr_idorigem => 3 --FTP pr_idorigem
                                          ,pr_cdoperad => vr_cdoperad
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
              
              IF nvl(vr_cdcritic,0) > 0 OR  
                 TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro; 
              END IF;   
            
              -- Erro ja esta sendo logado na procedure
              vr_cdcritic := 0;
              vr_dscritic := '';
              vr_chave := vr_tab_cratarq.NEXT(vr_chave);
              CONTINUE;                   
  					  	                                                  
            END IF;                       
              
            -- Move o Arquivo UNIX para o "salvar"
            vr_dscomand := 'mv -f '|| vr_caminho_arq || '/' || vr_tab_cratarq(vr_chave).nmarquiv || ' ' || 
                           vr_caminho_cooper || '/salvar';
                                             
            -- Executa comando
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic);
            
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              -- O comando shell executou com erro
              vr_cdcritic := 0;        
              
              -- Gera log
              pc_gerar_log(pr_cdcooper => rw_crapcoop.cdcooper,
                           pr_dscdolog => 'Arquivo: '|| vr_tab_cratarq(vr_chave).nmarquiv||
                                          ': '       || vr_cdcritic||'-'||
                                          'Erro ao mover arquivo ' || vr_tab_cratarq(vr_chave).nmarquiv || 
                                          ' para o salvar: ' || vr_dscritic); 
                                            
              -- Erro ja esta sendo logado na procedure
              vr_cdcritic := 0;
              vr_dscritic := '';
              vr_chave := vr_tab_cratarq.NEXT(vr_chave);
              CONTINUE; 
              
            END IF;
             
            -- Busca pr�xima chave de arquivos
            vr_chave := vr_tab_cratarq.NEXT(vr_chave);
  		        
            -- Efetuar commit por arquivo
            COMMIT;
		       
          END LOOP; -- Loop por arquivo
             
        END IF; --Fim da importa��o dos arquivos
                       
        EXCEPTION
          WHEN vr_exc_erro THEN
            
            -- Verifica se houve c�digo de erro
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
            
            IF vr_dscritic IS NOT NULL THEN
              -- Envio centralizado de log de erro							 
              -- Gera log 
              pc_gerar_log(pr_cdcooper => rw_crapcoop.cdcooper,
                           pr_dscdolog => vr_dscritic);
            END IF;

            vr_cdcritic := 0;
            vr_dscritic := NULL;
            
            -- Efetuar rollback				  
            ROLLBACK;
             
       END;
				
     END LOOP; -- FOR rw_crapcoop
			     
    -- Log de fim da execucao
    pc_controla_log_batch(pr_dstiplog => 'F');

    -- Efetuar Commit de informacoes pendentes de gravacao
    COMMIT;
       
   EXCEPTION   
       
     WHEN OTHERS THEN
       
       btch0001.pc_log_internal_exception(3);
          
       -- Efetuar retorno do erro nao tratado
       pr_dscritic := sqlerrm;

       -- Log de erro de execucao
       vr_flgerlog := TRUE;
       pc_controla_log_batch(pr_dstiplog => 'E',
                             pr_dscritic => pr_dscritic);
       
       -- Efetuar rollback
       ROLLBACK;
  END pc_crps778;
/
