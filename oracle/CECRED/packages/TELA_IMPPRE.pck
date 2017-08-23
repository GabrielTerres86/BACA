CREATE OR REPLACE PACKAGE CECRED.TELA_IMPPRE AS
  
  -- Rotina para consulta de pacotes de tarifas via AYLLOS WEB
  PROCEDURE pc_inclui_carga (pr_descricao      IN VARCHAR2     --> Descricao da Carga
                            ,pr_final_vigencia IN VARCHAR2     --> Data Final da Vigencia
                            ,pr_indeterminado  IN NUMBER       --> Data Indeterminada (1 - SIM / 0 - NAO)
                            ,pr_mensagem       IN VARCHAR2     --> Mensagem de aviso
                            ,pr_nome_arquivo   IN VARCHAR2     --> Nome do arquivo
                            ,pr_iddcarga       IN INTEGER      --> ID da carga
                            ,pr_xmllog         IN VARCHAR2                      --> XML com informações de LOG
                            ,pr_cdcritic       OUT PLS_INTEGER                  --> Código da crítica
                            ,pr_dscritic       OUT VARCHAR2                     --> Descrição da crítica
                            ,pr_retxml         IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                            ,pr_nmdcampo       OUT VARCHAR2                     --> Nome do Campo
                            ,pr_des_erro       OUT VARCHAR2);                   --> Saida OK/NOK
  
  PROCEDURE pc_importar_carga (pr_idcarga   IN tbepr_carga_pre_aprv.idcarga%TYPE
                              ,pr_dscritic OUT VARCHAR2); -- Identificador da carga
  
  -- Busca cargas
  PROCEDURE pc_busca_carga (pr_cddopcao  IN VARCHAR2           --> Codigo da rotina
                           ,pr_nriniseq  IN VARCHAR2           --> Numero do primeiro registro a ser retornado
                           ,pr_qtregist  IN VARCHAR2           --> Numero de registros a serem retornados
                           ,pr_iddcarga  IN INTEGER            --> ID da carga
                           ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                           ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
  
  -- Bloqueia/Libera/Exclui cargas
  PROCEDURE pc_mantem_carga (pr_cddopcao  IN VARCHAR2           --> Codigo da rotina
                            ,pr_iddcarga  IN INTEGER            --> Codigo da carga
                            ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                            ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                            ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
   
END TELA_IMPPRE;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_IMPPRE AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_IMPPRE
  --    Autor   : lucas Lombardi
  --    Data    : Marco/2016                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela IMPPRE (Ayllos Web)
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------
  
  -- Insere linha no Log
  PROCEDURE pc_adiciona_linha_log (pr_dsdireto IN VARCHAR2      --> Diretório
                                  ,pr_nmarquiv IN VARCHAR2      --> Nome do arquivo
                                  ,pr_dsclinha IN VARCHAR2      --> Conteúdo
                                  ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_adiciona_linha_log
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : EMPR
    Autor   : Lucas Lombardi
    Data    : Julho/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para inserir linha no log
    
    Alteracoes: 
    ............................................................................. */
    
    vr_utlfileh utl_file.file_type;
    vr_exc_saida EXCEPTION;
    
  BEGIN
    
    pr_des_erro := 'OK';
    
    -- Abrir arquivo em modo de adição
    gene0001.pc_abre_arquivo(pr_nmdireto => pr_dsdireto
                            ,pr_nmarquiv => pr_nmarquiv
                            ,pr_tipabert => 'A'
                            ,pr_utlfileh => vr_utlfileh
                            ,pr_des_erro => pr_des_erro);

    -- Verifica se ocorreram erros
    IF pr_des_erro IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Gravar linha no arquivo
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                  ,pr_des_text => to_char(SYSDATE,'DD/MM/RRRR HH24:mi:ss') || ' -->  ' || pr_dsclinha);
    
    -- Fechar arquivo
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro := 'Erro ao gerar log: ' || pr_des_erro;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_des_erro := 'Erro ao gerar log: ' || SQLERRM;
      ROLLBACK;
  END pc_adiciona_linha_log;
  
  
  -- Inclui carga manual
  PROCEDURE pc_inclui_carga (pr_descricao      IN VARCHAR2     --> Descricao da Carga
                            ,pr_final_vigencia IN VARCHAR2     --> Data Final da Vigencia
                            ,pr_indeterminado  IN NUMBER       --> Data Indeterminada (1 - SIM / 0 - NAO)
                            ,pr_mensagem       IN VARCHAR2     --> Mensagem de aviso
                            ,pr_nome_arquivo   IN VARCHAR2     --> Nome do arquivo
                            ,pr_iddcarga       IN INTEGER      --> ID da carga
                            ,pr_xmllog         IN VARCHAR2     --> XML com informações de LOG
                            ,pr_cdcritic      OUT PLS_INTEGER       --> Código da crítica
                            ,pr_dscritic      OUT VARCHAR2          --> Descrição da crítica
                            ,pr_retxml         IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo      OUT VARCHAR2          --> Nome do Campo
                            ,pr_des_erro      OUT VARCHAR2) IS      --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_inclui_carga
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : EMPR
    Autor   : Lucas Lombardi
    Data    : Julho/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para incluir carga manual pre aprovado via Ayllos Web
    
    Alteracoes: 10/07/2017 - Alterado para quando incluir uma carga setar o horário
                             23:59:59 na data final de vigencia
                             M441 - Melhoria Pré-aprovado - Roberto Holz (Mout´s)
    ............................................................................. */
    
    -- Busca Carga Solicitada/Executando
    CURSOR cr_carga_pre_aprv (pr_cdcooper crapcop.cdcooper%TYPE
                             ,pr_nmarquivo VARCHAR2) IS
      SELECT 1
        FROM tbepr_carga_pre_aprv epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.indsituacao_carga in (2,3) --(2 - Solicitada, 3 - Executando)
         AND epr.nmarquivo = pr_nmarquivo;
    rw_carga_pre_aprv cr_carga_pre_aprv%ROWTYPE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variaveis auxiliares
    pr_dir_carga      VARCHAR2(100);
    vr_flgfound       BOOLEAN;
    vr_nrdrowid       ROWID;
    vr_idcarga        tbepr_carga_pre_aprv.idcarga%TYPE;
    vr_dsplsql        VARCHAR2(4000); -- Bloco PLSQL para chamar a execução paralela do pc_crps682
    vr_jobname        VARCHAR2(30);   -- Job name dos processos criados
    vr_final_vigencia DATE;
    vr_msglog         VARCHAR2(100);
    vr_msgretorno     VARCHAR2(100);
    
    --Controle de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;
    
  BEGIN
  
    pr_des_erro := 'OK';
  
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    EMPR0002.pc_valida_operador (pr_cdcooper => vr_cdcooper
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
    -- Verifica se houve erro ao validar operador
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    pr_dir_carga := gene0001.fn_param_sistema (pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'DIR_CARGA_PREAPROVADO') || '/importar/';
    
    -- Se id da carga estiver nullo faz validacoes do arquivo
    IF pr_iddcarga IS NULL OR pr_iddcarga = 0 THEN
      -- Verificar se existe arquivo
      IF gene0001.fn_exis_arquivo(pr_caminho => pr_dir_carga || pr_nome_arquivo || '.csv') = FALSE THEN
        vr_dscritic := 'Arquivo '||pr_nome_arquivo||' não encontrado.';
        RAISE vr_exc_erro;
      END IF;
    
      -- Verifica se carga ja foi solicitada ou esta executando
      OPEN cr_carga_pre_aprv (vr_cdcooper, pr_nome_arquivo);
      FETCH cr_carga_pre_aprv INTO rw_carga_pre_aprv;
      vr_flgfound := cr_carga_pre_aprv%FOUND;
      CLOSE cr_carga_pre_aprv;
      IF vr_flgfound THEN
        vr_dscritic := 'Arquivo '||pr_nome_arquivo||' já está em processamento.';
        RAISE vr_exc_erro;
      END IF;
    END IF;
    
    IF pr_indeterminado = 0 THEN
      vr_final_vigencia := to_date(pr_final_vigencia,'DD/MM/RRRR');
    ELSE
      vr_final_vigencia := NULL;
    END IF;
    
    -- Valida data
    IF vr_final_vigencia IS NOT NULL AND
       vr_final_vigencia < SYSDATE THEN
      vr_dscritic := 'Data final da vigencia não pode ser menor que a data de hoje.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Acrescenta 235959 na data de final de vigencia (M441);
    IF vr_final_vigencia is not null THEN
       vr_final_vigencia := to_date( to_char(vr_final_vigencia,'DDMMRRRR')||'235959','DDMMRRRRHH24MISS');
    END IF;
    --
    
    IF pr_iddcarga IS NULL OR pr_iddcarga = 0 THEN
      BEGIN-- Se idcarga for nulo cria novo registro
        INSERT INTO tbepr_carga_pre_aprv (cdcooper
                                         ,dtcalculo
                                         ,indsituacao_carga
                                         ,flgcarga_bloqueada
                                         ,vltotal_pre_aprv_pj
                                         ,vltotal_pre_aprv_pf
                                         ,tpcarga
                                         ,dscarga
                                         ,dtliberacao
                                         ,dtfinal_vigencia
                                         ,dsmensagem_aviso
                                         ,nmarquivo)
                                  VALUES (vr_cdcooper
                                         ,SYSDATE
                                         ,2 -- Solicitada
                                         ,1 -- Sim
                                         ,0
                                         ,0
                                         ,1 --Manual
                                         ,pr_descricao
                                         ,NULL
                                         ,vr_final_vigencia
                                         ,pr_mensagem
                                         ,pr_nome_arquivo)
                                  RETURNING idcarga INTO vr_idcarga;
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao incluir carga pre aprovado. ' || SQLERRM;
        RAISE vr_exc_erro;
      END;
      
      -- Chamar pc_importar_carga por JOB
      vr_dsplsql := 'DECLARE'||chr(13)
                 || '  vr_dscritic VARCHAR2(4000);'||chr(13)                   
                 || 'BEGIN'||chr(13)
                 || '  TELA_IMPPRE.pc_importar_carga('||vr_idcarga||',vr_dscritic);'||chr(13)
                 || 'END;';
                       
      -- Montar o prefixo do código do programa para o jobname
      vr_jobname := 'IMPPRE_CARGA_'||vr_idcarga||'$';
      -- Faz a chamada ao programa paralelo atraves de JOB
      GENE0001.pc_submit_job(pr_cdcooper  => vr_cdcooper  --> Código da cooperativa
                            ,pr_cdprogra  => 'IMPPRE'     --> Código do programa
                            ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                            ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                            ,pr_interva   => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                            ,pr_jobname   => vr_jobname   --> Nome randomico criado
                            ,pr_des_erro  => vr_dscritic);
      -- Testar saida com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Levantar exceçao
        RAISE vr_exc_erro;
      END IF;
      vr_msglog := 'IMPPRE - Inclusao da carga pre aprovado.';
      
    ELSE-- Se idcarga nao for nulo faz update no registro
      BEGIN-- Se idcarga for nulo cria novo registro
        UPDATE tbepr_carga_pre_aprv 
           SET dscarga = pr_descricao
              ,dtfinal_vigencia = vr_final_vigencia
              ,dsmensagem_aviso = pr_mensagem
         WHERE cdcooper = vr_cdcooper
           AND idcarga  = pr_iddcarga;
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar carga pre aprovado. ' || SQLERRM;
        RAISE vr_exc_erro;
      END;
      vr_msglog := 'IMPPRE - Alteracao da carga pre aprovado.';
    END IF;
    
    /* Inclusão de log com retorno do rowid */
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ''
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem) --> Origem enviada
                        ,pr_dstransa => vr_msglog
                        ,pr_dttransa => trunc(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 0
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => 0
                        ,pr_nrdrowid => vr_nrdrowid);
        
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Id Carga'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => vr_idcarga);
    
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Nome Arquivo'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => pr_nome_arquivo);
                             
    COMMIT;
    IF pr_iddcarga IS NULL OR pr_iddcarga = 0 THEN
      vr_msgretorno := 'A importação está sendo realizada, acompanhe a ' ||
                       'situação da carga através da opcao L - Liberar Carga';
    ELSE
      vr_msgretorno := 'Carga alterada com sucesso!';
    END IF;
    
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Dados>' || vr_msgretorno ||
                                   '</Dados></Root>');
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_IMPPRE.PC_INCLUI_CARGA: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_inclui_carga;
  
  -- Gera carga manual 
  PROCEDURE pc_importar_carga (pr_idcarga   IN tbepr_carga_pre_aprv.idcarga%TYPE
                              ,pr_dscritic OUT VARCHAR2) IS -- Identificador da carga

  BEGIN

    /* .............................................................................
    Programa: pc_importar_carga
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : EMPR
    Autor   : Lucas Lombardi
    Data    : Julho/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gerar carga manual pre aprovado
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- Buscar cooperativas
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop
         WHERE cdcooper <> 3
           AND flgativo = 1;
      
      -- Selecionar os dados
      CURSOR cr_carga (pr_idcarga IN tbepr_carga_pre_aprv.idcarga%TYPE) IS
        SELECT carga.idcarga
              ,carga.indsituacao_carga
              ,carga.nmarquivo
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.idcarga = pr_idcarga
           AND carga.indsituacao_carga = 2; -- 2-Solicitada
      rw_carga cr_carga%ROWTYPE;
      
      -- Verifica conta
      CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT inpessoa
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Verifica linha de credito
      CURSOR cr_craplcr (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT 1
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      
      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_loop_erro EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      vr_typ_said  VARCHAR2(10);
      
      -- Variaveis auxiliares
      vr_flgfound       BOOLEAN;
      pr_dir_importar   VARCHAR2(100);
      pr_dir_importados VARCHAR2(100);
      pr_dir_log_carga  VARCHAR2(100);
      pr_dir_rel_carga  VARCHAR2(100);
      vr_arquivo        utl_file.file_type; -- Handle do arquivo aberto
      vr_relatorio      utl_file.file_type; -- Handle do arquivo aberto
      vr_linha          VARCHAR2(500);
      vr_linha_rel      VARCHAR2(500);
      vr_comando        VARCHAR2(1000);
      vr_flgachou       BOOLEAN;            --> Booleano para controle
      vr_vllimdis_pf    tbepr_carga_pre_aprv.vltotal_pre_aprv_pf%TYPE;
      vr_vllimdis_pj    tbepr_carga_pre_aprv.vltotal_pre_aprv_pj%TYPE;
      -- Variaveis do arquivo
      vr_cdcooper INTEGER;
      vr_nrdconta INTEGER;
      vr_vllimite NUMBER;
      vr_qtmaxpar INTEGER;
      vr_cdlcremp INTEGER;
            
      BEGIN
        
        -- Diretorio de arquivos para importar
        pr_dir_importar := gene0001.fn_param_sistema (pr_nmsistem => 'CRED'
                                                     ,pr_cdcooper => 0
                                                     ,pr_cdacesso => 'DIR_CARGA_PREAPROVADO') || '/importar/';
        -- Diretorio de arquivos importados
        pr_dir_importados := gene0001.fn_param_sistema (pr_nmsistem => 'CRED'
                                                       ,pr_cdcooper => 0
                                                       ,pr_cdacesso => 'DIR_CARGA_PREAPROVADO') || '/importados/';
        -- Diretorio do log
        pr_dir_log_carga := gene0001.fn_param_sistema (pr_nmsistem => 'CRED'
                                                      ,pr_cdcooper => 0
                                                      ,pr_cdacesso => 'DIR_LOG_CARGA_P_APROV');
        -- Diretorio do relatorio
        pr_dir_rel_carga := gene0001.fn_param_sistema (pr_nmsistem => 'CRED'
                                                      ,pr_cdcooper => 0
                                                      ,pr_cdacesso => 'DIR_REL_CARGA_P_APROV');
        
        -- Percorre cooperativas para habilitar contas suspensas
        FOR rw_crapcop IN cr_crapcop LOOP
          
          -- Leitura do calendario
          OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
          FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
          vr_flgachou := BTCH0001.cr_crapdat%FOUND;
          CLOSE BTCH0001.cr_crapdat;
          -- Se nao achou
          IF NOT vr_flgachou THEN
            vr_cdcritic := 1;
            RAISE vr_exc_erro;
          END IF;
        
          -- Contas PF
          EMPR0002.pc_habilita_contas_suspensas (pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_inpessoa => 1 
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                ,pr_dscritic => vr_dscritic);
          -- Se ocorrer algum erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Contas PJ
          EMPR0002.pc_habilita_contas_suspensas (pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_inpessoa => 2
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                ,pr_dscritic => vr_dscritic);
           -- Se ocorrer algum erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
        END LOOP;
        
        -- Efetua a busca do registro
        OPEN cr_carga(pr_idcarga);
        FETCH cr_carga INTO rw_carga;
        -- Alimenta a booleana se achou ou nao
        vr_flgfound := cr_carga%FOUND;
        -- Fecha cursor
        CLOSE cr_carga;

        -- Se achou
        IF NOT vr_flgfound THEN
          pr_dscritic := 'Carga Solicitada nao existe.';
          RAISE vr_exc_erro;
        END IF;
        
        -- Atualizar situacao da carga
        BEGIN
          UPDATE tbepr_carga_pre_aprv
             SET indsituacao_carga = 3 -- Executando
           WHERE idcarga = pr_idcarga;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar situacao da carga para "gerado". ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        -- Log de inicializacao
        pc_adiciona_linha_log (pr_dsdireto => pr_dir_log_carga --> Diretório
                              ,pr_nmarquiv => 'imppre_carga_'||pr_idcarga||'.log'     --> Nome do arquivo
                              ,pr_dsclinha => 'Carga ' || pr_idcarga || ' Executando.'
                              ,pr_des_erro => vr_dscritic);
                                        
        -- Verificar se existe arquivo
        IF gene0001.fn_exis_arquivo(pr_caminho => pr_dir_importar || rw_carga.nmarquivo || '.csv') = FALSE THEN
          vr_dscritic := 'Arquivo '||rw_carga.nmarquivo||' não encontrado.';
          RAISE vr_exc_erro;
        END IF;
        
        -- Abrir arquivo
        GENE0001.pc_abre_arquivo(pr_nmdireto => pr_dir_importar    --> Diretório do arquivo
                                ,pr_nmarquiv => rw_carga.nmarquivo || '.csv' --> Nome do arquivo
                                ,pr_tipabert => 'R'                --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_arquivo         --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);      --> Erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        -- Criar arquivo do relatorio
        gene0001.pc_abre_arquivo(pr_nmdireto => pr_dir_rel_carga
                                ,pr_nmarquiv => to_char(SYSDATE,'RRRRMMDD')||'Carga'||pr_idcarga||'.csv'
                                ,pr_tipabert => 'A'
                                ,pr_utlfileh => vr_relatorio
                                ,pr_des_erro => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        -- Se o arquivo estiver aberto
        IF  utl_file.IS_OPEN(vr_arquivo) THEN
          
          -- Percorrer as linhas do arquivo
          BEGIN
            -- Pular a primeira linha
            gene0001.pc_le_linha_arquivo (vr_arquivo,vr_linha);
             -- Gravar linha no relatorio
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_relatorio
                                          ,pr_des_text => vr_linha);
            
            vr_vllimdis_pf := 0;
            vr_vllimdis_pj := 0;
            
            LOOP
              BEGIN
                gene0001.pc_le_linha_arquivo (vr_arquivo,vr_linha);
                -- Guarda linha para colocar no relatorio
                vr_linha_rel := vr_linha;
                
                vr_cdcooper := TRIM(substr(vr_linha, 0,INSTR(vr_linha,';') - 1));
                vr_linha := substr(vr_linha, INSTR(vr_linha,';') + 1,length(vr_linha));
                
                vr_nrdconta := TRIM(substr(vr_linha, 0,INSTR(vr_linha,';') - 1));
                vr_linha := substr(vr_linha, INSTR(vr_linha,';') + 1,length(vr_linha));
                
                -- Verifica se a conta existe na cooperativa
                OPEN cr_crapass (vr_cdcooper, vr_nrdconta);
                FETCH cr_crapass INTO rw_crapass;
                vr_flgfound := cr_crapass%FOUND;
                CLOSE cr_crapass;
                
                IF NOT vr_flgfound THEN
                   vr_dscritic := 'Conta ' || vr_nrdconta || ' não existe na Cooperativa ' || vr_cdcooper || '.';
                   RAISE vr_loop_erro;
                END IF;
                
                vr_vllimite := to_number(TRIM(substr(vr_linha, 0,INSTR(vr_linha,';') - 1)));
                vr_linha := substr(vr_linha, INSTR(vr_linha,';') + 1,length(vr_linha));
                
                vr_qtmaxpar := TRIM(substr(vr_linha, 0,INSTR(vr_linha,';') - 1));
                vr_linha := substr(vr_linha, INSTR(vr_linha,';') + 1,length(vr_linha));
                
                --Tira quebra de linhas
                vr_cdlcremp := TRIM(REPLACE(REPLACE(vr_linha,chr(10),''),chr(13),''));
                
                -- Verifica se a linha de credito existe na cooperativa
                OPEN cr_craplcr (vr_cdcooper, vr_cdlcremp);
                FETCH cr_craplcr INTO rw_craplcr;
                vr_flgfound := cr_craplcr%FOUND;
                CLOSE cr_craplcr;
                
                IF NOT vr_flgfound THEN
                   vr_dscritic := 'Linha de crédito ' || vr_cdlcremp || ' não existe na Cooperativa ' || vr_cdcooper || '.';
                   RAISE vr_loop_erro;
                END IF;
                
                BEGIN
                  --Insere registro na tablea crapcpa
                  INSERT INTO crapcpa (cdcooper
                                      ,nrdconta
                                      ,dtmvtolt
                                      ,vlcalpre
                                      ,vllimdis
                                      ,vlctrpre
                                      ,vlcalpar
                                      ,iddcarga
                                      ,cdlcremp
                                      ,vlcalcot
                                      ,vlcaldes
                                      ,vlcalren
                                      ,vlcalven
                                      ,dscalris)
                               VALUES (vr_cdcooper
                                      ,vr_nrdconta
                                      ,SYSDATE
                                      ,vr_vllimite
                                      ,vr_vllimite
                                      ,0
                                      ,vr_qtmaxpar
                                      ,pr_idcarga
                                      ,vr_cdlcremp
                                      ,0
                                      ,0
                                      ,0
                                      ,0
                                      ,NULL);
                EXCEPTION
                  WHEN dup_val_on_index THEN
                    vr_dscritic := 'Conta '|| vr_nrdconta || ' já cadastrada nesta carga de pré-aprovado para a cooperativa ' || vr_cdcooper || '.';
                    RAISE vr_loop_erro;
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir registro na tabela cracpa. ' || SQLERRM;
                    RAISE vr_loop_erro;
                END;
                
                IF rw_crapass.inpessoa = 1 THEN
                  vr_vllimdis_pf := vr_vllimdis_pf + vr_vllimite;
                ELSE
                  vr_vllimdis_pj := vr_vllimdis_pj + vr_vllimite;
                END IF;
                
                -- Gravar linha no relatorio
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_relatorio
                                              ,pr_des_text => vr_linha_rel);
                
              EXCEPTION
                WHEN no_data_found THEN
                  EXIT;
                WHEN vr_loop_erro THEN
                  pc_adiciona_linha_log (pr_dsdireto => pr_dir_log_carga --> Diretório
                                        ,pr_nmarquiv => 'imppre_carga_'||pr_idcarga||'.log'     --> Nome do arquivo
                                        ,pr_dsclinha => vr_dscritic      --> Conteúdo
                                        ,pr_des_erro => vr_dscritic);
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro não tratado. ' || SQLERRM;
                  pc_adiciona_linha_log (pr_dsdireto => pr_dir_log_carga --> Diretório
                                        ,pr_nmarquiv => 'imppre_carga_'||pr_idcarga||'.log'     --> Nome do arquivo
                                        ,pr_dsclinha => vr_dscritic      --> Conteúdo
                                        ,pr_des_erro => vr_dscritic);
              END;
            END LOOP; -- Fim LOOP linhas do arquivo
            
          EXCEPTION
            WHEN no_data_found THEN
              NULL;
          END;
        END IF;
        
        -- Atualizar situacao da carga
        BEGIN
          UPDATE tbepr_carga_pre_aprv
             SET indsituacao_carga = 1 -- Gerado
                ,vltotal_pre_aprv_pf = vr_vllimdis_pf
                ,vltotal_pre_aprv_pj = vr_vllimdis_pj
           WHERE idcarga = pr_idcarga;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar situacao da carga para "gerado". ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        -- Log de finalizacao
        pc_adiciona_linha_log (pr_dsdireto => pr_dir_log_carga --> Diretório
                              ,pr_nmarquiv => 'imppre_carga_'||pr_idcarga||'.log'     --> Nome do arquivo
                              ,pr_dsclinha => 'Carga ' || pr_idcarga || ' gerada.'
                              ,pr_des_erro => vr_dscritic);
                                        
        -- Comando para mover o arquivo para a pasta importados
        vr_comando := 'mv ' || pr_dir_importar || rw_carga.nmarquivo || '.csv ' || pr_dir_importados ||  to_char(SYSDATE,'RRMMDD') || 'Carga' || pr_idcarga || '.csv';
        -- Mover o arquivo
        GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comando
                                   ,pr_typ_saida   => vr_typ_said
                                   ,pr_des_saida   => pr_dscritic);
        -- Verificar retorno de erro
        IF vr_typ_said = 'ERR' THEN
          RAISE vr_exc_erro;
        END IF;
        
        BEGIN
          UPDATE tbepr_carga_pre_aprv
             SET nmarquivo = to_char(SYSDATE,'RRMMDD') || 'Carga' || pr_idcarga || '.csv'
         WHERE idcarga = pr_idcarga;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar nome do arquivo. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        COMMIT;
      EXCEPTION        
        WHEN vr_exc_erro THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND pr_dscritic IS NULL THEN
            -- Buscar a descrição
            pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          
          ROLLBACK;
          -- Atualizar situacao da carga
          BEGIN
            UPDATE tbepr_carga_pre_aprv
               SET indsituacao_carga = 1 -- Gerado
             WHERE idcarga = pr_idcarga;
            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar situacao da carga para "gerado". ' || SQLERRM;
          END;
          -- Log de finalizacao
          pc_adiciona_linha_log (pr_dsdireto => pr_dir_log_carga --> Diretório
                                ,pr_nmarquiv => 'imppre_carga_'||pr_idcarga||'.log'     --> Nome do arquivo
                                ,pr_dsclinha => pr_dscritic
                                ,pr_des_erro => vr_dscritic);
        WHEN OTHERS THEN
          pr_dscritic := 'Erro geral em IMPPRE: ' || SQLERRM;
          ROLLBACK;
          -- Atualizar situacao da carga
          BEGIN
            UPDATE tbepr_carga_pre_aprv
               SET indsituacao_carga = 1 -- Gerado
             WHERE idcarga = pr_idcarga;
            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar situacao da carga para "gerado". ' || SQLERRM;
          END;
          -- Log de finalizacao
          pc_adiciona_linha_log (pr_dsdireto => pr_dir_log_carga --> Diretório
                                ,pr_nmarquiv => 'imppre_carga_'||pr_idcarga||'.log'     --> Nome do arquivo
                                ,pr_dsclinha => pr_dscritic
                                ,pr_des_erro => vr_dscritic);
        
      END;
    
  END pc_importar_carga;
  
  -- Busca cargas
  PROCEDURE pc_busca_carga (pr_cddopcao  IN VARCHAR2           --> Codigo da rotina
                           ,pr_nriniseq  IN VARCHAR2           --> Numero do primeiro registro a ser retornado
                           ,pr_qtregist  IN VARCHAR2           --> Numero de registros a serem retornados
                           ,pr_iddcarga  IN INTEGER            --> ID da carga
                           ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                           ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_busca_carga
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : EMPR
    Autor   : Lucas Lombardi
    Data    : Julho/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar cargas manuais do pre aprovado
    
    Alteracoes: 10/07/2017 - Nas opções Alteração e Bloqueio alterado para não selecionar 
                             as cargas bloqueadas definitivamente, isto é , cargas que um
                             dia foram vigentes mas depois foram bloqueadas.
                             M441 - Melhoria Pré-aprovado - Roberto Holz (Mout´s)
    ..............................................................................*/ 
    DECLARE
      
      -- Busca Carga Solicitada/Executando
      CURSOR cr_carga_pre_aprv (pr_cddopcao VARCHAR2) IS
        SELECT idcarga idcarga
              ,dscarga descricao
              ,decode(flgcarga_bloqueada,0,'Não',1,'Sim') bloqueio
              ,decode(indsituacao_carga,1,'Gerada',2,'Solicitada',3,'Executando') situacao
              ,nvl(to_char(dtfinal_vigencia,'DD/MM/RRRR'),'Indeterminada') vigencia_final
              ,to_char(nvl(vltotal_pre_aprv_pf,0) + 
                       nvl(vltotal_pre_aprv_pj,0),'fm999g999g999g990d00') valor_total
          FROM tbepr_carga_pre_aprv
         WHERE tpcarga = 1
           AND ((upper(pr_cddopcao) = 'B'
           AND  flgcarga_bloqueada = 0)
           OR  (upper(pr_cddopcao) = 'L'
           AND  flgcarga_bloqueada = 1
           AND  flgbloq_definitivo <> 1)
           OR  (upper(pr_cddopcao) = 'E'
           AND  flgcarga_bloqueada = 1
           AND  indsituacao_carga  = 1)
           OR  (upper(pr_cddopcao) = 'A'
--           AND  flgcarga_bloqueada = 1  -- M441 -- (Roberto Holz - Mouts)
           AND  indsituacao_carga  = 1
           AND  flgbloq_definitivo <> 1))
           ORDER BY idcarga DESC;
      
      CURSOR cr_carga (pr_iddcarga INTEGER) IS
        SELECT idcarga
              ,dscarga
              ,to_char(dtfinal_vigencia,'DD/MM/RRRR') dtfinal_vigencia
              ,dsmensagem_aviso
              ,nmarquivo
          FROM tbepr_carga_pre_aprv
         WHERE idcarga = pr_iddcarga;
      rw_carga cr_carga%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      --Temporario
      vr_temp1 INTEGER := pr_nriniseq;
      vr_temp2 INTEGER := pr_qtregist;
      
      -- Variaveis auxiliares
      vr_contador  INTEGER := 0;
      vr_paginacao INTEGER := 1;
      vr_flgfound  BOOLEAN;
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN
        
        pr_des_erro := 'OK';
      
        -- Recupera dados de log para consulta posterior
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
      
        -- Verifica se houve erro recuperando informacoes de log                              
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        
        -- Se id da carga estiver nulo retornar lista
        IF pr_iddcarga IS NULL THEN
          -- Busca as cargas
          FOR rw_carga_pre_aprv IN cr_carga_pre_aprv(pr_cddopcao) LOOP
            IF vr_paginacao BETWEEN vr_temp1 AND (vr_temp1 + vr_temp2 - 1) THEN
              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'Dados'
                                    ,pr_posicao  => 0
                                    ,pr_tag_nova => 'carga'
                                    ,pr_tag_cont => NULL
                                    ,pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'carga'
                                    ,pr_posicao  => vr_contador
                                    ,pr_tag_nova => 'idcarga'
                                    ,pr_tag_cont => rw_carga_pre_aprv.idcarga
                                    ,pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'carga'
                                    ,pr_posicao  => vr_contador
                                    ,pr_tag_nova => 'descricao'
                                    ,pr_tag_cont => rw_carga_pre_aprv.descricao
                                    ,pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'carga'
                                    ,pr_posicao  => vr_contador
                                    ,pr_tag_nova => 'bloqueio'
                                    ,pr_tag_cont => rw_carga_pre_aprv.bloqueio
                                    ,pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'carga'
                                    ,pr_posicao  => vr_contador
                                    ,pr_tag_nova => 'situacao'
                                    ,pr_tag_cont => rw_carga_pre_aprv.situacao
                                    ,pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'carga'
                                    ,pr_posicao  => vr_contador
                                    ,pr_tag_nova => 'vigencia_final'
                                    ,pr_tag_cont => rw_carga_pre_aprv.vigencia_final
                                    ,pr_des_erro => vr_dscritic);
                                    
              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'carga'
                                    ,pr_posicao  => vr_contador
                                    ,pr_tag_nova => 'valor_total'
                                    ,pr_tag_cont => rw_carga_pre_aprv.valor_total
                                    ,pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'carga'
                                    ,pr_posicao  => vr_contador
                                    ,pr_tag_nova => 'dsmensagem_aviso'
                                    ,pr_tag_cont => rw_carga.dsmensagem_aviso
                                    ,pr_des_erro => vr_dscritic);
                                    
              vr_contador := vr_contador + 1; 
            END IF;
            vr_paginacao := vr_paginacao + 1;
          END LOOP;
          
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Root'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'qtregistros'
                                ,pr_tag_cont => vr_paginacao
                                ,pr_des_erro => vr_dscritic);
        ELSE 
          -- Se id da carga nao estiver nulo retornar carga especifica
          OPEN cr_carga(pr_iddcarga);
          FETCH cr_carga INTO rw_carga;
          vr_flgfound := cr_carga%FOUND;
          CLOSE cr_carga;
          
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'idcarga'
                                ,pr_tag_cont => rw_carga.idcarga
                                ,pr_des_erro => vr_dscritic);
           
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dscarga'
                                ,pr_tag_cont => rw_carga.dscarga
                                ,pr_des_erro => vr_dscritic);
           
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dtfinal_vigencia'
                                ,pr_tag_cont => rw_carga.dtfinal_vigencia
                                ,pr_des_erro => vr_dscritic);
          
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dsmensagem_aviso'
                                ,pr_tag_cont => rw_carga.dsmensagem_aviso
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'nmarquivo'
                                ,pr_tag_cont => rw_carga.nmarquivo
                                ,pr_des_erro => vr_dscritic);
        END IF;
        
        
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em IMPPRE: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_busca_carga;
    
  -- Bloqueia/Libera/Exclui cargas
  PROCEDURE pc_mantem_carga (pr_cddopcao  IN VARCHAR2           --> Codigo da rotina
                            ,pr_iddcarga  IN INTEGER            --> Codigo da carga
                            ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                            ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                            ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_busca_carga
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : EMPR
    Autor   : Lucas Lombardi
    Data    : Julho/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para bloquear/liberar/excluir cargas manuais do pre aprovado
    
    Alteracoes: 10/07/2017 - alterado para setar a data final de vigencia e
                             o indicador de bloqueio definitivo 
                             (M441 - Melhoria Pré-aprovado )  Roberto Holz (Mouts)
    ..............................................................................*/ 
    DECLARE
      
      -- Valida situacao da Carga
      -- B - flgcarga_bloqueada = [0 – nao].
      -- L - flgcarga_bloqueada = [1 – sim]
      --   e indsituacao_carga =  [1 – Gerada].
      -- E - flgcarga_bloqueada = [1 – sim]
      --   e indsituacao_carga =  [1 – Gerada].
      CURSOR cr_carga_pre_aprv (pr_cddopcao VARCHAR2
                               ,pr_iddcarga INTEGER) IS
        SELECT ap.indsituacao_carga
              ,ap.flgcarga_bloqueada
          FROM tbepr_carga_pre_aprv ap
         WHERE ap.tpcarga = 1
           AND ap.idcarga = pr_iddcarga;
      rw_carga_pre_aprv cr_carga_pre_aprv%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis auxiliares
      vr_contador INTEGER := 0;
      vr_flgfound BOOLEAN;
      vr_msgrepos VARCHAR2(100);
      vr_dstransa VARCHAR2(100);
      vr_nrdrowid ROWID;
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN
        
        pr_des_erro := 'OK';
      
        -- Recupera dados de log para consulta posterior
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
      
        -- Verifica se houve erro recuperando informacoes de log                              
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
        -- Validar situacao da carga
        OPEN cr_carga_pre_aprv(pr_cddopcao, pr_iddcarga);
        FETCH cr_carga_pre_aprv INTO rw_carga_pre_aprv;
        vr_flgfound := cr_carga_pre_aprv%FOUND;
        IF vr_flgfound THEN
          CASE pr_cddopcao
              WHEN 'B' THEN -- Bloquear
                IF rw_carga_pre_aprv.flgcarga_bloqueada = 1 THEN
                  vr_dscritic := 'Carga já está bloqueada.';
                  RAISE vr_exc_erro;
                END IF;
              WHEN 'L' THEN -- Liberar
                IF rw_carga_pre_aprv.indsituacao_carga <> 1 THEN
                  vr_dscritic := 'Aguarde o final do processamento antes de realizar a liberação da carga.';
                  RAISE vr_exc_erro;
                ELSIF rw_carga_pre_aprv.flgcarga_bloqueada = 0 THEN
                  vr_dscritic := 'Carga já está liberada.';
                  RAISE vr_exc_erro;
                END IF;
              WHEN 'E' THEN -- Excluir
                IF rw_carga_pre_aprv.indsituacao_carga <> 1 THEN
                  vr_dscritic := 'Aguarde o final do processamento antes de realizar a exclusão da carga.';
                  RAISE vr_exc_erro;
                ELSIF rw_carga_pre_aprv.flgcarga_bloqueada = 0 THEN
                  vr_dscritic := 'Carga já está liberada.';
                  RAISE vr_exc_erro;
                END IF;
            END CASE;
        ELSE
          vr_dscritic := 'Carga não encontrada.';
          RAISE vr_exc_erro;
        END IF;
        
        BEGIN 
          CASE pr_cddopcao
            WHEN 'B' THEN -- Bloquear carga
              UPDATE tbepr_carga_pre_aprv
                 SET flgcarga_bloqueada = 1
                    ,dtfinal_vigencia = sysdate -- M441 --
                    ,flgbloq_definitivo = 1
               WHERE idcarga = pr_iddcarga;
            WHEN 'L' THEN -- Liberar carga
              UPDATE tbepr_carga_pre_aprv
                 SET flgcarga_bloqueada = 0
                    ,dtliberacao = SYSDATE
               WHERE idcarga = pr_iddcarga;
            WHEN 'E' THEN -- Excluir carga              
              DELETE FROM tbepr_carga_pre_aprv
               WHERE idcarga = pr_iddcarga;
              -- Excluir itens da carga
              DELETE FROM crapcpa
               WHERE iddcarga = pr_iddcarga;
          END CASE;
        EXCEPTION
          WHEN OTHERS THEN
            CASE pr_cddopcao
              WHEN 'B' THEN -- Bloquear
                vr_dscritic := 'Erro ao bloquear carga. ' || SQLERRM;
              WHEN 'L' THEN -- Liberar
                vr_dscritic := 'Erro ao liberar carga. ' || SQLERRM;
              WHEN 'E' THEN -- Excluir
                vr_dscritic := 'Erro ao excluir carga. ' || SQLERRM;
            END CASE;
          RAISE vr_exc_erro;
        END;
        
        CASE pr_cddopcao
          WHEN 'B' THEN -- Bloquear
            vr_msgrepos := 'Carga bloqueada com sucesso.';
            vr_dstransa := 'IMPPRE - Bloqueio da carga pre aprovado.';
          WHEN 'L' THEN -- Liberar
            vr_msgrepos := 'Carga liberada com sucesso.';
            vr_dstransa := 'IMPPRE - Liberacao da carga pre aprovado.';
          WHEN 'E' THEN -- Excluir
            vr_msgrepos := 'Carga excluida com sucesso.';
            vr_dstransa := 'IMPPRE - Exclusao da carga pre aprovado.';
        END CASE;
        
        /* Inclusão de log com retorno do rowid */
        gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem) --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => trunc(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 0
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
            
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Id Carga'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => pr_iddcarga);
        
        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>' || vr_msgrepos || '</Dados></Root>');
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em IMPPRE: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_mantem_carga;
  
END TELA_IMPPRE;
/
