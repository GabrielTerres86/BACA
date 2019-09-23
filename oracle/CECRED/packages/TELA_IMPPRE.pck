CREATE OR REPLACE PACKAGE CECRED.TELA_IMPPRE AS
  -- Lista Cargas Disponíveis SAS
  PROCEDURE pc_lista_cargas_SAS(pr_nrregist  IN NUMBER                -- Quantidade de registros
                               ,pr_nriniseq  IN NUMBER                -- Id inicial de sequencia de registros
                               -- Interface da Mensageria PHP
                               ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                               ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK

  -- Executa Carga SAS
  PROCEDURE pc_proc_carga_sas(pr_skcarga    IN NUMBER            -- Id Carga SAS
                             ,pr_cddopcao   IN VARCHAR2          -- Opção (Importar ou Bloquear)
                             ,pr_dsrejeicao IN VARCHAR2          -- Texto da rejeição
                              -- Interface da Mensageria PHP
                             ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                             ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
  
  -- Executa Carga Manual
  PROCEDURE pc_proc_carga_manual(pr_tpexecuc  IN VARCHAR2           -- Tipo da Execução ([S]imular / [I]mportar)
                                ,pr_dsdiretor IN VARCHAR2           -- Diretorio do arquivo download
                                ,pr_dsarquivo IN VARCHAR2           -- Nome do arquivo para download
                                 -- Interface da Mensageria PHP
                                ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
  
  -- Lista Histórico/Detalhes da Carga
  PROCEDURE pc_lista_hist_cargas(pr_cdcoptel  IN crapcop.cdcooper%TYPE -- Cooperativa da filtragem
                                ,pr_idcarga   IN NUMBER                -- ID da Carga
                                ,pr_tpcarga   IN VARCHAR2              -- Tipo da Carga (Todas, Manual ou Automatica)
                                ,pr_indsitua  IN VARCHAR2              -- Situação da Carga (Bloqueada, Liberada ou Todas)
                                ,pr_dtlibera  IN VARCHAR2              -- Data da Liberação
                                ,pr_dtliberafim  IN VARCHAR2           -- Data da Liberação Final
                                ,pr_dtvigencia   IN VARCHAR2           -- Data da Vigencia da Carga
                                ,pr_dtvigenciafim IN VARCHAR2          -- Data da Vigencia da Carga
                                ,pr_skcarga   IN NUMBER                -- Id Carga SAS
                                ,pr_dscarga   IN VARCHAR2              -- Descrição da Carga (Ação)
                                ,pr_tpretorn  IN VARCHAR2              -- Tipo do Retorno (Tela ou CSV)
                                ,pr_nrregist  IN NUMBER                -- Quantidade de registros
                                ,pr_nriniseq  IN NUMBER                -- Id inicial de sequencia de registros
                                 -- Interface da Mensageria PHP
                                ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
  
  -- Executa Exclusão via Arquivo
  PROCEDURE pc_proc_exclu_manual(pr_tpexecuc  IN VARCHAR2           -- Tipo da Execução ([S]imular / [I]mportar)
                                ,pr_dsdiretor IN VARCHAR2           -- Diretorio do arquivo download
                                ,pr_dsarquivo IN VARCHAR2           -- Nome do arquivo para download
                                 -- Interface da Mensageria PHP
                                ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
  
  -- Processo de Bloqueio de Carga
  PROCEDURE pc_proc_bloq_carga(pr_idcarga   IN NUMBER             -- Id Carga 
                               -- Interface da Mensageria PHP
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
  
  -- Variaveis de log
  vr_cdprogra crapprg.cdprogra%TYPE := 'IMPPRE';
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);
  
  --Controle de erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_saida EXCEPTION;
  -- Tabela de Erros
  vr_des_reto  VARCHAR2(3);      
  vr_tab_erro      GENE0001.typ_tab_erro;      
  
  -- Contagem de registros
  vr_qtdregis NUMBER;
  
  -- Cursor generico de calendario
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  
  -- Traduz o campo cdsituacao para ser usado no csv.
  FUNCTION fn_traduz_cdsituacao(pr_cdsituacao IN crapcpa.cdsituacao%TYPE) RETURN VARCHAR2 IS
  BEGIN
   
    DECLARE
    vr_retorno VARCHAR2(40) := pr_cdsituacao;
    BEGIN
      CASE pr_cdsituacao
       WHEN 'A' THEN vr_retorno:= 'Aceita';
       WHEN 'B' THEN vr_retorno:= 'Bloqueada';
       WHEN 'R' THEN vr_retorno:= 'Recusada';
       WHEN 'S' THEN vr_retorno:= 'Substituida';
       ELSE vr_retorno:= pr_cdsituacao;
      END CASE;
     return vr_retorno;
    END;
  END fn_traduz_cdsituacao;

    -- Traduz o campo de bloqueio manual para ser usado no csv.
  FUNCTION fn_traduz_bloq_manual(pr_bloq_manual NUMBER) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
    vr_retorno VARCHAR2(40) := pr_bloq_manual;
    BEGIN
      CASE pr_bloq_manual
       WHEN 0 THEN vr_retorno:= 'Nao';
       WHEN 1 THEN vr_retorno:= 'Sim';
      END CASE;
     return vr_retorno;
    END;
  END fn_traduz_bloq_manual;
  
  -- Lista Cargas Disponíveis SAS
  PROCEDURE pc_lista_cargas_SAS(pr_nrregist  IN NUMBER                -- Quantidade de registros
                               ,pr_nriniseq  IN NUMBER                -- Id inicial de sequencia de registros
                                -- Interface da Mensageria PHP
                               ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                               ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    /* .............................................................................
      Programa: pc_lista_cargas_SAS
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : EMPR - Pré-Aprovado
      Autor   : Marcos Martini
      Data    : Janeiro/2019                       Ultima atualizacao: 
      
      Dados referentes ao programa:
      
      Frequencia: Sempre que for chamado
      Objetivo  : Listar as cargas disponíveis para carga do Pre-Aproado no SAS
      
      Alteracoes: 
      ............................................................................. */
  BEGIN
    DECLARE
    
      -- Variáveis para criação de cursor dinâmico
      vr_nom_owner     VARCHAR2(100) := gene0005.fn_get_owner_sas;
      vr_nom_dblink    VARCHAR2(100);
      vr_num_cursor    number;
      vr_num_retor     number;
      vr_sql_cursor    varchar2(32000);
      vr_contador      INTEGER := 0;
      
      -- Variaveis para a consulta
      vr_skcarga         NUMBER;
      vr_cdcopcar        NUMBER;
      vr_dscarga         VARCHAR2(500);
      vr_vlpotenlimtotal NUMBER := 0;      
      vr_qtpfcarregados  NUMBER := 0;      
      vr_qtpjcarregados  NUMBER := 0;      
      vr_dtcarga         DATE;
      vr_dthoraini       DATE;
      vr_dthorafim       DATE;
      vr_indsituac       NUMBER := 0;
      vr_dessituac       VARCHAR2(100);
      
    BEGIN
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
        RAISE vr_exc_saida;
      END IF;
      -- Incluir nome
      GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                ,pr_action => 'pc_lista_cargas_SAS'); 
      
      -- Buscar dblink
      vr_nom_dblink := gene0005.fn_get_dblink_sas('W');
      IF vr_nom_dblink IS NULL THEN
        vr_dscritic := 'Nao foi possivel retornar o DBLink do SAS, verifique!';
        RAISE vr_exc_saida;
      END IF;
      
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      -- Iniciar contador
      vr_qtdregis := 0;
      
      -- Montaremos a query base com os registros para carga ou reprovação
      vr_sql_cursor := 'SELECT pot.skcarga '
                    || '      ,pot.cdcooper '
                    || '      ,pot.dscarga '
                    || '      ,pot.vlpotenlimtotal '
                    || '      ,pot.qtpfcarregados '
                    || '      ,pot.qtpjcarregados '
                    || '      ,pot.dtcarga '
                    || '      ,car.dthorainicioprocesso '
                    || '      ,car.dthorafimprocesso '
                    || '      ,nvl(carAim.Indsituacao_Carga,0) indsituac '
                    || '  FROM '||vr_nom_owner||'sas_preaprovado_carga@'||vr_nom_dblink||' pot '
                    || '      ,'||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink||' car '
                    || '      ,tbepr_carga_pre_aprv       carAim '
                    || ' WHERE car.skcarga = carAim.Skcarga_Sas(+) '
                    || '   AND pot.skcarga = car.skcarga '
                    || '   AND car.qtregistroprocessado > 0 '
                    || '   AND car.dthorafiminclusao is not null '
                    || '   AND nvl(carAim.Indsituacao_Carga,0) IN(0,1) '
                    || ' ORDER BY pot.dtcarga desc ';
      
      -- Cria cursor dinâmico
      vr_num_cursor := dbms_sql.open_cursor;

      -- Comando Parse
      dbms_sql.parse(vr_num_cursor, vr_sql_cursor, 1);
      -- Definindo Colunas de retorno
      dbms_sql.define_column(vr_num_cursor, 1, vr_skcarga);
      dbms_sql.define_column(vr_num_cursor, 2, vr_cdcopcar);
      dbms_sql.define_column(vr_num_cursor, 3, vr_dscarga, 500);
      dbms_sql.define_column(vr_num_cursor, 4, vr_vlpotenlimtotal);
      dbms_sql.define_column(vr_num_cursor, 5, vr_qtpfcarregados);
      dbms_sql.define_column(vr_num_cursor, 6, vr_qtpjcarregados);
      dbms_sql.define_column(vr_num_cursor, 7, vr_dtcarga);
      dbms_sql.define_column(vr_num_cursor, 8, vr_dthoraini);
      dbms_sql.define_column(vr_num_cursor, 9, vr_dthorafim);
      dbms_sql.define_column(vr_num_cursor, 10, vr_indsituac);
      
      -- Execução do select dinamico
      vr_num_retor := dbms_sql.execute(vr_num_cursor);
      LOOP 
        -- Verifica se há alguma linha de retorno do cursor
        vr_num_retor := dbms_sql.fetch_rows(vr_num_cursor);
        IF vr_num_retor = 0 THEN
          -- Se o cursor dinamico está aberto
          IF dbms_sql.is_open(vr_num_cursor) THEN
            -- Fecha o mesmo
            dbms_sql.close_cursor(vr_num_cursor);
          END IF;
          EXIT; 
        ELSE 
          -- Carrega variáveis com o retorno do cursor
          dbms_sql.column_value(vr_num_cursor, 1, vr_skcarga);
          dbms_sql.column_value(vr_num_cursor, 2, vr_cdcopcar);
          dbms_sql.column_value(vr_num_cursor, 3, vr_dscarga);
          dbms_sql.column_value(vr_num_cursor, 4, vr_vlpotenlimtotal);
          dbms_sql.column_value(vr_num_cursor, 5, vr_qtpfcarregados);
          dbms_sql.column_value(vr_num_cursor, 6, vr_qtpjcarregados);
          dbms_sql.column_value(vr_num_cursor, 7, vr_dtcarga);
          dbms_sql.column_value(vr_num_cursor, 8, vr_dthoraini);
          dbms_sql.column_value(vr_num_cursor, 9, vr_dthorafim);
          dbms_sql.column_value(vr_num_cursor, 10, vr_indsituac);

          vr_qtdregis := vr_qtdregis + 1;
          -- Checar paginação
          IF pr_nrregist > 0 AND ((vr_qtdregis >= pr_nriniseq) AND (vr_qtdregis < (pr_nriniseq + pr_nrregist))) THEN
            -- Validar a situação
            IF vr_indsituac = 0 THEN
              -- Verificar se o processo já não está em execução
              IF vr_dthoraini IS NULL THEN
                vr_dessituac := 'Gerada';
              ELSE
                vr_dessituac := 'Importando';
              END IF;
            ELSE
              vr_dessituac := 'Importada';
            END IF;

            -- No raiz do Score
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Carga'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
            -- Campos
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Carga'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'skcarga'
                                  ,pr_tag_cont => vr_skcarga
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Carga'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'cdcooper'
                                  ,pr_tag_cont => vr_cdcopcar
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Carga'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dscarga'
                                  ,pr_tag_cont => vr_dscarga
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Carga'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dssituac'
                                  ,pr_tag_cont => vr_dessituac
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Carga'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'qtpfcarregados'
                                  ,pr_tag_cont => to_char(vr_qtpfcarregados,'fm999g999g999g990')
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Carga'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'qtpjcarregados'
                                  ,pr_tag_cont => to_char(vr_qtpjcarregados,'fm999g999g999g990')
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Carga'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'vllimitetotal'
                                  ,pr_tag_cont => to_char(vr_vlpotenlimtotal,'fm999g999g999g990d00')
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Carga'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dtcarga'
                                  ,pr_tag_cont => to_char(vr_dtcarga,'dd/mm/rr')
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Carga'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dthorini'
                                  ,pr_tag_cont => to_char(vr_dthoraini,'dd/mm/rr hh24:mi:ss')
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Carga'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dthorfim'
                                  ,pr_tag_cont => to_char(vr_dthorafim,'dd/mm/rr hh24:mi:ss')
                                  ,pr_des_erro => vr_dscritic);
            -- Incrementar o contador
            vr_contador := vr_contador + 1;
          END IF;
        END IF;
      END LOOP;

      -- Retornar quantidade de registros
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdregis'
                            ,pr_tag_cont => vr_qtdregis
                            ,pr_des_erro => vr_dscritic);

                
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela IMPPRE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_lista_cargas_SAS;                             

  -- Executa Carga SAS
  PROCEDURE pc_proc_carga_sas(pr_skcarga    IN NUMBER            -- Id Carga SAS
                             ,pr_cddopcao   IN VARCHAR2          -- Opção (Importar ou Bloquear)
                             ,pr_dsrejeicao IN VARCHAR2          -- Texto da rejeição
                              -- Interface da Mensageria PHP
                             ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                             ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                             ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    /* .............................................................................
      Programa: pc_proc_carga_sas
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : EMPR - Pré-Aprovado
      Autor   : Marcos Martini
      Data    : Janeiro/2019                       Ultima atualizacao: 
      
      Dados referentes ao programa:
      
      Frequencia: Sempre que for chamado
      Objetivo  : Proceder com a carga do SAS
      
      Alteracoes: 
      ............................................................................. */
  BEGIN
    DECLARE
      -- Job name dos processos criados
      vr_jobname       varchar2(30);
      -- Bloco PLSQL para chamar a execução paralela do pc_crps750
      vr_dsplsql       varchar2(4000);
    vr_sql_cursor_int   VARCHAR2(32000);
      vr_nom_owner        VARCHAR2(100) := gene0005.fn_get_owner_sas;
      vr_nom_dblink_rw    VARCHAR2(100) := gene0005.fn_get_dblink_sas('W');
      vr_num_cursor_int   PLS_INTEGER;
      vr_num_retor_int    PLS_INTEGER;
          
    BEGIN
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
        RAISE vr_exc_saida;
      END IF; 
      -- Incluir nome
      GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                ,pr_action => 'pc_proc_carga_sas'); 

      -- Validar Modelo
      IF vr_cdcooper IS NULL THEN
        vr_dscritic := 'Cooperativa deve ser informado!';
        RAISE vr_exc_saida;
      END IF;
      -- Validar SKCarga
      IF pr_skcarga IS NULL THEN
        vr_dscritic := 'ID Carga deve ser informado!';
        RAISE vr_exc_saida;
      END IF;
      -- Validar Opção
      IF pr_cddopcao IS NULL OR pr_cddopcao NOT IN('I','L','R') THEN
        vr_dscritic := 'Opcao invalida! Favor enviar [I]mportar, [L]iberar ou [R]eprovar!';
        RAISE vr_exc_saida;
      END IF;
      -- Validar Operador
      IF vr_cdoperad IS NULL THEN
        vr_dscritic := 'Operador conectado deve ser informado!';
        RAISE vr_exc_saida;
      END IF;
      -- Validar Motivo Rejeicao
      IF pr_cddopcao = 'R' AND pr_dsrejeicao IS NULL THEN
        vr_dscritic := 'Motivo da Rejeicao e obrigatorio para esta opcao!';
        RAISE vr_exc_saida;
      END IF; 
      
      -- Caso a execução seja de importação
      IF pr_cddopcao = 'I' THEN
    -- Travar data de início para definir que a carga está em processo de importação
        BEGIN
          vr_sql_cursor_int := 'update '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink_rw||' car '
                            || ' set car.dthorainicioprocesso = to_date(''' || TO_CHAR(SYSDATE, 'ddmmrrrrhh24miss') || ''',''ddmmrrrrhh24miss'') '
                            || ' where car.skcarga = '||pr_skcarga;
          
          vr_num_cursor_int := dbms_sql.open_cursor;
          dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
          vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
          dbms_sql.close_cursor(vr_num_cursor_int);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na carga do PreAprovado: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Nome do Job
        vr_jobname := 'JBEPR_CARGA_SAS';
        -- Iremos submeter a execução do procedimento sem travar a tela
        vr_dsplsql := 'DECLARE' || chr(13) 
                   || '  wpr_dscritic VARCHAR2(4000);' || chr(13) 
                   || 'BEGIN' || chr(13) 
                   || '  empr0002.pc_carga_autom_via_SAS('||vr_cdcooper||chr(13)
                   || '                                 ,'''||vr_cdoperad||''''||chr(13)
                   || '                                 ,'||vr_idorigem||chr(13)
                   || '                                 ,'''||vr_cdprogra||''''||chr(13)
                   || '                                 ,'||pr_skcarga||chr(13)
                   || '                                 ,'''||pr_cddopcao||''''||chr(13)
                   || '                                 ,'''||pr_dsrejeicao||''''||chr(13)
                   || '                                 ,wpr_dscritic);'||chr(13)
                   || 'END;'; 
         -- Faz a chamada ao programa paralelo atraves de JOB
         gene0001.pc_submit_job(pr_cdcooper => vr_cdcooper  --> Código da cooperativa
                               ,pr_cdprogra => vr_cdprogra  --> Código do programa
                               ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                               ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                               ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                               ,pr_jobname  => vr_jobname   --> Nome randomico criado
                               ,pr_des_erro => vr_dscritic);    
       
         IF vr_dscritic IS NOT NULL THEN
           -- Remover trava de data de início para definir que a carga está em processo de importação em caso de erro
            BEGIN
              vr_sql_cursor_int := 'update '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink_rw||' car '
                                || ' set car.dthorainicioprocesso = null '
                                || ' where car.skcarga = '||pr_skcarga;
              
              vr_num_cursor_int := dbms_sql.open_cursor;
              dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
              vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
              dbms_sql.close_cursor(vr_num_cursor_int);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro na carga do PreAprovado: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
         END IF;
       ELSE
         -- Outros casos, ou seja, rejeição ou liberação, será feito on-line
         empr0002.pc_carga_autom_via_SAS(pr_cdcooper   => vr_cdcooper
                                        ,pr_cdoperad   => vr_cdoperad
                                        ,pr_idorigem   => vr_idorigem
                                        ,pr_cdprogra   => vr_cdprogra
                                        ,pr_skcarga    => pr_skcarga
                                        ,pr_cddopcao   => pr_cddopcao
                                        ,pr_dsrejeicao => pr_dsrejeicao
                                        ,pr_dscritic   => vr_dscritic);
       END IF;                        
                                    
       -- Testar saida com erro
       if vr_dscritic is not null then 
         -- Levantar exceçao
         raise vr_exc_saida;
       end if;
      
       -- Efetuar gravação
       COMMIT;                  
                                
    EXCEPTION
      WHEN vr_exc_saida THEN        
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela IMPPRE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_proc_carga_sas;
  
  -- Executa Carga Manual
  PROCEDURE pc_proc_carga_manual(pr_tpexecuc  IN VARCHAR2           -- Tipo da Execução ([S]imular / [I]mportar)
                                ,pr_dsdiretor IN VARCHAR2           -- Diretorio do arquivo download
                                ,pr_dsarquivo IN VARCHAR2           -- Nome do arquivo para download
                                 -- Interface da Mensageria PHP
                                ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    /* .............................................................................
      Programa: pc_proc_carga_manual
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : EMPR - Pré-Aprovado
      Autor   : Marcos Martini
      Data    : Janeiro/2019                       Ultima atualizacao: 
      
      Dados referentes ao programa:
      
      Frequencia: Sempre que for chamado
      Objetivo  : Receber um arquivo e proceder com a carga manual dos cooperados do mesmo
      
      Alteracoes: 
      ............................................................................. */
  BEGIN
    DECLARE
      vr_xmldados CLOB;
    BEGIN
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
        RAISE vr_exc_saida;
      END IF;      
      
      -- Incluir nome
      GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                ,pr_action => 'pc_proc_carga_manual');  
      
      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_xmldados, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xmldados, dbms_lob.lob_readwrite);
      
      
      -- Direcionar para o procedimento de baixa e processamento do arquivo
      empr0002.pc_carga_manual_via_arquivo(pr_cdcooper => vr_cdcooper
                                          ,pr_cdoperad => vr_cdoperad
                                          ,pr_idorigem => vr_idorigem
                                          ,pr_cdprogra => vr_cdprogra
                                          ,pr_tpexecuc => pr_tpexecuc
                                          ,pr_dsdireto => pr_dsdiretor
                                          ,pr_nmarquiv => pr_dsarquivo
                                          ,pr_xmldados => vr_xmldados
                                          ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Somente Quando simulação
      IF pr_tpexecuc = 'S' THEN
        pr_retxml := xmltype.createxml(vr_xmldados);        
        --Fechar Clob e Liberar Memoria  
        dbms_lob.close(vr_xmldados);
        dbms_lob.freetemporary(vr_xmldados);  
      END IF;  
      
      -- Efetuar gravação
      COMMIT;                   
                                
    EXCEPTION
      WHEN vr_exc_saida THEN        
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela IMPPRE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_proc_carga_manual;
  
  -- Lista Histórico/Detalhes da Carga
  PROCEDURE pc_lista_hist_cargas(pr_cdcoptel  IN crapcop.cdcooper%TYPE -- Cooperativa da filtragem
                                ,pr_idcarga   IN NUMBER                -- ID da Carga
                                ,pr_tpcarga   IN VARCHAR2              -- Tipo da Carga (Todas, Manual ou Automatica)
                                ,pr_indsitua  IN VARCHAR2              -- Situação da Carga (Bloqueada, Liberada ou Todas)
                                ,pr_dtlibera  IN VARCHAR2              -- Data da Liberação
                                ,pr_dtliberafim  IN VARCHAR2           -- Data da Liberação Final
                                ,pr_dtvigencia   IN VARCHAR2           -- Data da Vigencia da Carga
                                ,pr_dtvigenciafim IN VARCHAR2          -- Data da Vigencia Final da Carga
                                ,pr_skcarga   IN NUMBER                -- Id Carga SAS
                                ,pr_dscarga   IN VARCHAR2              -- Descrição da Carga (Ação)
                                ,pr_tpretorn  IN VARCHAR2              -- Tipo do Retorno (Tela ou CSV)
                                ,pr_nrregist  IN NUMBER                -- Quantidade de registros
                                ,pr_nriniseq  IN NUMBER                -- Id inicial de sequencia de registros
                                 -- Interface da Mensageria PHP
                                ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    /* .............................................................................
      Programa: pc_lista_hist_cargas
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : EMPR - Pré-Aprovado
      Autor   : Marcos Martini
      Data    : Janeiro/2019                       Ultima atualizacao: 25-02-2019
      
      Dados referentes ao programa:
      
      Frequencia: Sempre que for chamado
      Objetivo  : Listar o histórico de cargas automáticas e manuais
      
      Alteracoes:                               
        06/03/2019 - Inclusão dos campos dtvigencia e dtliberafim - Christian Grauppe - ENVOLTI   
                12/03/2019 - Inclusão dos campos dtvigenciafim e ajustes na busca e ~listagem CSV - Christian Grauppe - ENVOLTI                                                     
      ............................................................................. */
  BEGIN
    DECLARE
 
      -- Cursor para validacao da cooperativa conectada
      CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
      SELECT cdcooper
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%rowtype;    
    
      -- Histórico de Cargas
      CURSOR cr_hist_cargas(pr_dtrefvigencia DATE, pr_dtrefvigenciafim DATE, pr_dtreflibera DATE, pr_dtrefliberafim DATE) IS
        SELECT car.idcarga
              ,car.cdcooper
              ,cop.nmrescop dscooper
              ,car.tpcarga
              ,decode(car.tpcarga,1,'Manual','Auto') dstpcarga
              ,car.skcarga_sas
              ,CASE WHEN car.tpcarga = 1 THEN
                 car.idcarga
               ELSE
                 car.skcarga_sas
               END cdCarga
              ,car.dscarga
              ,car.indsituacao_carga
              ,car.dsmotivo_rejeicao
              ,car.flgcarga_bloqueada
              ,car.dtfinal_vigencia
              ,car.dtliberacao
              ,car.dtcalculo
              ,car.qtcarga_pf
              ,car.qtcarga_pj
              ,(car.qtcarga_pf+car.qtcarga_pj) qtcarga
              ,COUNT(1) OVER (PARTITION BY 1) qtdregis
          FROM crapcop cop
              ,tbepr_carga_pre_aprv car
         WHERE car.cdcooper = cop.cdcooper
           AND car.cdcooper = DECODE(pr_cdcoptel,0,car.cdcooper,pr_cdcoptel)
           AND car.tpcarga = DECODE(pr_tpcarga,'M',1,'A',2,car.tpcarga)
           AND car.flgcarga_bloqueada = DECODE(pr_indsitua,'L',0,'B',1,car.flgcarga_bloqueada)
           AND (       (car.dtliberacao >= pr_dtreflibera OR pr_dtreflibera IS NULL) 
                   AND (car.dtliberacao <= pr_dtrefliberafim OR pr_dtrefliberafim IS NULL)
                )
           AND (       (car.dtfinal_vigencia >= pr_dtrefvigencia OR pr_dtrefvigencia IS NULL) 
                   AND (car.dtfinal_vigencia <= pr_dtrefvigenciafim OR pr_dtrefvigenciafim IS NULL)
                )
           AND (car.skcarga_sas = NVL(pr_skcarga,car.skcarga_sas)
                OR car.idcarga = NVL(pr_skcarga, car.idcarga))
           AND UPPER(NVL(car.dscarga,' ')) LIKE '%'||UPPER(NVL(pr_dscarga,NVL(car.dscarga,' ')))||'%'
           AND car.indsituacao_carga = DECODE(pr_indsitua,'S',4,'R',3,'L',2,'B',2,car.indsituacao_carga)
           AND car.indsituacao_carga in(2,3,4) -- Liberada, Rejeitada ou Substituida
           AND TRUNC(car.dtliberacao) >= TO_DATE('15/03/2019', 'DD/MM/RRRR')
         ORDER BY car.cdcooper
                 ,car.idcarga;
      
      -- Buscar sumarização da carga com dados somente de pre-aprovados
      CURSOR cr_det_carga(pr_idcarga crapcpa.iddcarga%TYPE) IS     
        SELECT AVG(cpa.vlcalpar) med_parcel
              ,MAX(cpa.vlcalpar) max_parcel
              ,SUM(cpa.vlcalpre) tot_libera
              ,COUNT(1) qtd_regis
              ,COUNT(CASE WHEN cpa.tppessoa = 1 THEN 1 END) qtd_regis_pf
              ,COUNT(CASE WHEN cpa.tppessoa = 2 THEN 1 END) qtd_regis_pj
          FROM crapcpa cpa
             , tbepr_carga_pre_aprv car
             , crapdat dat
         WHERE cpa.iddcarga = pr_idcarga
           AND car.idcarga = cpa.iddcarga
           AND dat.cdcooper = cpa.cdcooper
           AND cpa.vlcalpre > 0
           AND cpa.vlcalpar > 0
           AND (car.indsituacao_carga <> 2
              OR (car.indsituacao_carga = 2
                  AND car.flgcarga_bloqueada = 0
                  AND (car.dtfinal_vigencia is null or car.dtfinal_vigencia >= dat.dtmvtolt)
                  AND cpa.cdsituacao = 'A'
                  AND 0 = EMPR0002.fn_tem_bloq_preaprov_manual(cpa.cdcooper, cpa.nrcpfcnpj_base))
                  );
      rw_det_carga cr_det_carga%ROWTYPE;
      
      -- Buscar limite minimo para parcela da carga desconsiderando limite ZERO
      CURSOR cr_det_carga_min(pr_idcarga crapcpa.iddcarga%TYPE) IS
        SELECT MIN(cpa2.vlcalpar) min_parcel
        FROM crapcpa cpa2
        WHERE cpa2.iddcarga = pr_idcarga
          AND cpa2.vlcalpar > 0;
      rw_det_carga_min cr_det_carga_min%ROWTYPE;                        
   
      -- Quantidade de cooperados rejeitados na carga 
      CURSOR cr_qtremov_manual(pr_idcarga crapcpa.iddcarga%TYPE) IS     
        SELECT COUNT(1)
          FROM crapcpa cpa
         WHERE cpa.iddcarga = pr_idcarga
           AND cpa.cdsituacao = 'R' -- Rejeitado na carga
           AND UPPER(cpa.dscritica) LIKE UPPER('Encontrada carga manual%'); -- Carga Manual
      
      -- Buscar cooperados da Carga
      CURSOR cr_info_carga(pr_idcarga crapcpa.iddcarga%TYPE) IS     
        SELECT car.tpcarga
                ,decode(car.tpcarga,1,'Manual','Auto') dstpcarga
                ,car.skcarga_sas
                ,CASE WHEN car.tpcarga = 1 THEN
                   car.idcarga
                 ELSE
                   car.skcarga_sas
                 END cdcarga
                ,car.dscarga
                ,car.indsituacao_carga
                ,car.dsmotivo_rejeicao
                ,car.flgcarga_bloqueada
                ,to_char(car.dtfinal_vigencia,'dd/mm/rrrr') dtfinal_vigencia
                ,to_char(car.dtliberacao,'dd/mm/rrrr') dtliberacao
                ,to_char(car.dtcalculo,'dd/mm/rrrr') dtcalculo
                ,car.qtcarga_pf
                ,car.qtcarga_pj
                ,(car.qtcarga_pf+car.qtcarga_pj) qtcarga  
                ,cpa.vlcalpar
                ,cpa.vlcalpre
                ,cpa.nrcpfcnpj_base
                ,cpa.cdlcremp                
                ,TO_CHAR(cpa.vlcalpar,'fm999g999g999g990d00') vlcalpar_csv
                ,TO_CHAR(cpa.vlcalpre,'fm999g999g999g990d00') vlcalpre_csv
                ,cpa.tppessoa
                ,DECODE(cpa.tppessoa, 1, 'PF', 2, 'PJ') dstppessoa
                ,cop.nmrescop dscooper
                ,cpa.cdsituacao
                ,EMPR0002.fn_tem_bloq_preaprov_manual(cpa.cdcooper, cpa.nrcpfcnpj_base) bloq_manual
           FROM tbepr_carga_pre_aprv car
                ,crapcpa cpa
                ,crapcop cop  
          WHERE car.idcarga  = cpa.iddcarga  
            AND cpa.cdcooper = cop.cdcooper
            AND cpa.iddcarga = pr_idcarga;     

      -- Cursor para buscar carga automatica previa
      CURSOR cr_carga_atm_prev(pr_idcarga  tbepr_carga_pre_aprv.idcarga%TYPE
                              ,pr_cdcooper tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT SUM(cpa.vlcalpre) tot_libera_prev
        FROM crapcpa cpa
        WHERE cpa.iddcarga = (SELECT idcarga
                              FROM (SELECT idcarga
                                    FROM tbepr_carga_pre_aprv
                                    WHERE idcarga < pr_idcarga
                                      AND tpcarga = 2
                                      AND cdcooper = pr_cdcooper
                                    ORDER BY idcarga DESC)
                              WHERE ROWNUM = 1);
      rw_carga_atm_prev cr_carga_atm_prev%ROWTYPE;

      -- Cursor para buscar a primeira carga do mes da carga original
      CURSOR cr_carga_atm_mes(pr_dtcalculo  tbepr_carga_pre_aprv.dtcalculo%TYPE
                             ,pr_cdcooper   tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT SUM(cpa.vlcalpre) tot_libera_mes
        FROM crapcpa cpa
        WHERE cpa.nrdconta <> 0
          AND cpa.iddcarga = (SELECT idcarga
                              FROM (SELECT idcarga
                                    FROM tbepr_carga_pre_aprv
                                    WHERE TRUNC(dtcalculo, 'MM') = TRUNC(pr_dtcalculo, 'MM') 
                                      AND tpcarga = 2
                                      AND cdcooper = pr_cdcooper
                                      AND vllimite_total IS NOT NULL
                                    ORDER BY idcarga DESC)
                              WHERE ROWNUM = 1);
      rw_carga_atm_mes cr_carga_atm_mes%ROWTYPE;              

      -- Cursor para retornar valor total sem ponderação de média
      CURSOR cr_cpa_sp(pr_idcarga IN crapcpa.iddcarga%TYPE) IS 
        SELECT SUM(cpa.vlcalpre) tot_libera_sp
        FROM crapcpa cpa
           , tbepr_carga_pre_aprv car
           , crapdat dat
        WHERE cpa.iddcarga = pr_idcarga
          AND car.idcarga = cpa.iddcarga
          AND dat.cdcooper = cpa.cdcooper
          AND (car.indsituacao_carga <> 2
          OR (car.indsituacao_carga = 2
          AND car.flgcarga_bloqueada = 0
          AND (car.dtfinal_vigencia is null or car.dtfinal_vigencia >= dat.dtmvtolt)
          AND cpa.cdsituacao = 'A'
          AND 0 = EMPR0002.fn_tem_bloq_preaprov_manual(cpa.cdcooper, cpa.nrcpfcnpj_base)));

      rw_cpa_sp cr_cpa_sp%ROWTYPE;
	  
      -- Controle de mudanças de registros
      vr_idcarpri crapcpa.iddcarga%TYPE := 0;
      vr_vllibpri crapcpa.vlcalpre%TYPE := 0;
      vr_idcarant crapcpa.iddcarga%TYPE := 0;
      
      vr_dtcarant crapcpa.dtmvtolt%TYPE;
      
      -- Validação de parâmetros
      vr_dtrefvigencia                  DATE;
      vr_dtrefvigenciafim               DATE;
      vr_dtreflibera                    DATE;
      vr_dtrefliberafim                 DATE;
      
      -- Valores para processamento linha a linha
      vr_dssitua     VARCHAR2(100);
      vr_qtremovman  NUMBER;
      vr_pervariault NUMBER;
      vr_pervarapri  NUMBER;
      vr_dscarga     VARCHAR2(100);
      vr_dtcarvig    VARCHAR2(100);
      vr_dscooper    VARCHAR2(100);
      vr_dstpcarga   VARCHAR2(100);
      vr_skcarga     NUMBER;
      vr_dtliberacao VARCHAR2(100);
      vr_parc_min    NUMBER;
                  
      -- Gravação em CLOB
      vr_dstexto     VARCHAR2(32700);      
      vr_clobxml     CLOB;       
      vr_nmdireto VARCHAR2(100);      
      vr_nmarquiv VARCHAR2(100);
                 
    BEGIN
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
        RAISE vr_exc_saida;
      END IF;       
      
      -- Incluir nome
      GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                ,pr_action => 'pc_lista_hist_cargas'); 
      
      
      /* Garantir parametros obrigatórios */
      -- Validar existencia da cooperativa informada
      IF pr_cdcoptel <> 0 THEN      
        OPEN cr_crapcop(pr_cdcoptel);      
        FETCH cr_crapcop INTO rw_crapcop;      
        -- Gerar critica 794 se nao encontrar
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          vr_cdcritic := 794;
          -- Sair
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapcop;
          -- Continuaremos
        END IF;
      END IF;
      
      BEGIN                                                  
        --Realiza a conversao da data
        vr_dtrefvigencia := to_date(pr_dtvigencia,'DD/MM/RRRR'); 
      EXCEPTION
        WHEN OTHERS THEN
          --Monta mensagem de critica
          vr_dscritic := 'Data de vigencia inicial invalida.';
          pr_nmdcampo := 'dtvigencia';
          --Gera exceção
          RAISE vr_exc_saida;
      END;
      
      BEGIN                                                  
        --Realiza a conversao da data
        vr_dtrefvigenciafim := to_date(pr_dtvigenciafim,'DD/MM/RRRR'); 
      EXCEPTION
        WHEN OTHERS THEN
          --Monta mensagem de critica
          vr_dscritic := 'Data de vigencia final invalida.';
          pr_nmdcampo := 'dtvigenciafim';
          --Gera exceção
          RAISE vr_exc_saida;
      END;
      
      BEGIN                                                  
        --Realiza a conversao da data
        vr_dtreflibera := to_date(pr_dtlibera,'DD/MM/RRRR'); 
      EXCEPTION
        WHEN OTHERS THEN
          --Monta mensagem de critica
          vr_dscritic := 'Data de Liberacao inicial invalida.';              
          pr_nmdcampo := 'dtlibera';
          --Gera exceção
          RAISE vr_exc_saida;
      END;      
      
      BEGIN                                                  
        --Realiza a conversao da data
        vr_dtrefliberafim := to_date(pr_dtliberafim,'DD/MM/RRRR'); 
      EXCEPTION
        WHEN OTHERS THEN
          --Monta mensagem de critica
          vr_dscritic := 'Data de Liberacao final invalida.';
          pr_nmdcampo := 'dtliberafim';
          --Gera exceção
          RAISE vr_exc_saida;
      END;

      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);          
 
      IF pr_tpretorn = 'TELA' THEN
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'<?xml version="1.0" encoding="UTF-8"?><Root>');      
      END IF;

      -- Iniciar contador
      vr_qtdregis := 0;

      -- Efetuar a consulta
      FOR rw_his IN cr_hist_cargas(vr_dtrefvigencia ,vr_dtrefvigenciafim, vr_dtreflibera, vr_dtrefliberafim) LOOP                        
        -- Para o primeiro registro
        IF cr_hist_cargas%ROWCOUNT = 1 THEN
          -- Montar XML ou CSV, conforme o tipo solicitado
          IF pr_tpretorn = 'TELA' THEN
            -- Escrever a raiz do XML
            gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                     '<Dados qtdregis="'||rw_his.qtdregis||'">');
          ELSE
            --vars usadas na listagem de cooperados
            vr_dscarga  := rw_his.dscarga;
            vr_dtcarvig := to_char(rw_his.dtfinal_vigencia,'dd/mm/rrrr');
            vr_dscooper := rw_his.dscooper;
            vr_dstpcarga := rw_his.dstpcarga;
            vr_skcarga := rw_his.skcarga_sas;
            vr_dtliberacao := to_char(rw_his.dtliberacao,'dd/mm/rrrr');              
          END IF;
        END IF;  
      
        -- Contagem de registros
        vr_qtdregis := vr_qtdregis + 1;
        
        -- Para CSV não há contagem de registros
        IF pr_tpretorn = 'CSV' OR pr_nrregist > 0 AND ((vr_qtdregis >= pr_nriniseq) AND (vr_qtdregis < (pr_nriniseq + pr_nrregist))) THEN
          -- Buscar cooperados da carga para busca das informações adicionais
          rw_det_carga := null;
          OPEN cr_det_carga(pr_idcarga => rw_his.idcarga);
          FETCH cr_det_carga INTO rw_det_carga;
          CLOSE cr_det_carga;
          
          -- Buscar sumarização da carga para limite mínimo
          OPEN cr_det_carga_min(pr_idcarga => rw_his.idcarga);
          FETCH cr_det_carga_min INTO rw_det_carga_min;
          
          IF cr_det_carga_min%NOTFOUND THEN
            vr_parc_min := 0;
          ELSE
            vr_parc_min := rw_det_carga_min.min_parcel;
          END IF;
          
          CLOSE cr_det_carga_min;            
  
          -- Leitura do calendario do registro corrente
          OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_his.cdcooper);
          FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
          CLOSE BTCH0001.cr_crapdat;              
      
          -- Montagem da situação
          IF rw_his.indsituacao_carga = 2 THEN
            IF rw_his.flgcarga_bloqueada = 1 THEN
              vr_dssitua := 'Bloq.';
            ELSE
              IF rw_his.dtfinal_vigencia < trunc(rw_crapdat.dtmvtolt) THEN
                vr_dssitua := 'Inat.';
              ELSE
                vr_dssitua := 'Ativa';
              END IF;
            END IF;
          ELSIF rw_his.indsituacao_carga = 3 THEN 
            vr_dssitua := 'Rejeit.';  
          ELSE
            vr_dssitua := 'Subst.';  
          END IF;  

          -- Zerar contados
          vr_qtremovman := 0;
          vr_pervariault := 0;
          vr_pervarapri := 0;

          -- Somente para as automaticas
          IF rw_his.tpcarga = 2 THEN
            -- Buscar quantidade de cooperados removidos devido haver carga manual ativa
            OPEN cr_qtremov_manual(pr_idcarga => rw_his.idcarga);
            FETCH cr_qtremov_manual
             INTO vr_qtremovman;
            CLOSE cr_qtremov_manual;            

            -- Tratar mudança de mês
            IF vr_dtcarant IS NOT NULL THEN
              -- Se mudou o mês
              IF trunc(rw_his.dtliberacao,'mm') <> trunc(vr_dtcarant,'mm') THEN
                -- Guardar o ID da primeira carga do mês
                vr_idcarpri := rw_his.idcarga;
                vr_vllibpri := nvl(rw_det_carga.tot_libera, 0);
              END IF;
            END IF;            

            -- Se existe uma carga anterior e for diferente da atual
            IF vr_idcarant IS NOT NULL AND vr_idcarant <> rw_his.idcarga THEN
              OPEN cr_carga_atm_prev(pr_idcarga => rw_his.idcarga, pr_cdcooper => rw_his.cdcooper);
              FETCH cr_carga_atm_prev INTO rw_carga_atm_prev;
              CLOSE cr_carga_atm_prev;

              -- Comparar o valor liberado na carga anterior
              IF rw_carga_atm_prev.tot_libera_prev > 0 THEN
                 vr_pervariault := ((rw_det_carga.tot_libera - rw_carga_atm_prev.tot_libera_prev) / rw_carga_atm_prev.tot_libera_prev) * 100;
              END IF;
            END IF;

            -- Se existe a carga do começo do mês e 
            IF vr_idcarpri IS NOT NULL AND vr_idcarpri <> rw_his.idcarga THEN
              OPEN cr_carga_atm_mes(pr_dtcalculo => rw_his.dtcalculo, pr_cdcooper => rw_his.cdcooper);
              FETCH cr_carga_atm_mes INTO rw_carga_atm_mes;
              CLOSE cr_carga_atm_mes;

              -- Comparar o valor liberado na carga anterior
              IF rw_carga_atm_mes.tot_libera_mes > 0 THEN
                 vr_pervarapri := ((rw_det_carga.tot_libera - rw_carga_atm_mes.tot_libera_mes) / rw_carga_atm_mes.tot_libera_mes) * 100;
              END IF;
            END IF;           
          END IF;  

          -- Enviar as tags para tela ou texto quando CSV enviar as informações separadas por ';'
          IF pr_tpretorn = 'TELA' THEN
            -- Buscar totalização sem ponderação de média
            OPEN cr_cpa_sp(pr_idcarga => rw_his.idcarga);
            FETCH cr_cpa_sp INTO rw_cpa_sp;
            CLOSE cr_cpa_sp;				
          
            gene0002.pc_escreve_xml(vr_clobxml
                                   ,vr_dstexto
                                   , '<HistorCarga>'
                                   ||  '<idcarga>'||rw_his.idcarga||'</idcarga>'
                                   ||  '<cdcooper>'||rw_his.cdcooper||'</cdcooper>'
                                   ||  '<dscooper>'||rw_his.dscooper||'</dscooper>'
                                   ||  '<tpcarga>'||rw_his.dstpcarga||'</tpcarga>'
                                   ||  '<skcarga>'||rw_his.skcarga_sas||'</skcarga>'
                                   ||  '<cdCarga>'||rw_his.cdCarga||'</cdCarga>'
                                   ||  '<dscarga><![CDATA['||rw_his.dscarga||']]></dscarga>'
                                   ||  '<dssitua>'||vr_dssitua||'</dssitua>'
                                   ||  '<dsmotivo>'||rw_his.dsmotivo_rejeicao||'</dsmotivo>'
                                   ||  '<dtliberacao>'||to_char(rw_his.dtliberacao,'dd/mm/rrrr')||'</dtliberacao>'
                                   ||  '<dtvigencia>'||to_char(rw_his.dtfinal_vigencia,'dd/mm/rrrr')||'</dtvigencia>'
                                   ||  '<qtregistros>'||to_char(rw_his.qtcarga,'fm999g999g999g990')||'</qtregistros>'
                                   ||  '<vlrtotal>'||to_char(nvl(rw_det_carga.tot_libera, 0),'fm999g999g999g990d00')||'</vlrtotal>'
                                   ||  '<vlrmediapar>'||to_char(nvl(rw_det_carga.med_parcel, 0),'fm999g999g999g990d00')||'</vlrmediapar>'
                                   ||  '<qtregispf>'||to_char(nvl(rw_his.qtcarga_pf, 0),'fm999g999g999g990')||'</qtregispf>'
                                   ||  '<qtregispj>'||to_char(nvl(rw_his.qtcarga_pj, 0),'fm999g999g999g990')||'</qtregispj>'
                                   ||  '<vlrparmax>'||to_char(nvl(rw_det_carga.max_parcel, 0),'fm999g999g999g990d00')||'</vlrparmax>'
                                   ||  '<vlmincarga>'||to_char(nvl(vr_parc_min, 0),'fm999g999g999g990d00')||'</vlmincarga>'
                                   ||  '<qtremovman>'||to_char(vr_qtremovman,'fm999g999g999g990')||'</qtremovman>'
                                   ||  '<pervariault>'||to_char(nvl(vr_pervariault, 0),'fm999g999g999g990d00')||'</pervariault>'
                                   ||  '<pervarapri>'||to_char(nvl(vr_pervarapri, 0),'fm999g999g999g990d00')||'</pervarapri>'
                                   ||  '<qtdregcarga>'||to_char(rw_det_carga.qtd_regis,'fm999g999g999g990')||'</qtdregcarga>'
                                   ||  '<qtdregcargapf>'||to_char(rw_det_carga.qtd_regis_pf,'fm999g999g999g990')||'</qtdregcargapf>'
                                   ||  '<qtdregcargapj>'||to_char(rw_det_carga.qtd_regis_pj,'fm999g999g999g990')||'</qtdregcargapj>'
                                   ||  '<vlrtotalsp>'||to_char(nvl(rw_cpa_sp.tot_libera_sp, 0),'fm999g999g999g990d00')||'</vlrtotalsp>'
                                   ||'</HistorCarga>');  
          END IF;
        END IF;

        -- Somente para as automaticas
        IF rw_his.tpcarga = 2 THEN
          -- Armazenar a carga anterior e data anterior antes de mudar de registro
          vr_dtcarant := rw_his.dtliberacao;
          vr_idcarant := rw_his.idcarga;
       
        END IF;  
        
      END LOOP;

      -- Após a leitura dos registros, caso for tela precisamos fechar as tags e devolver 
      IF pr_tpretorn = 'TELA' THEN
        -- Somente se havia algo
        IF vr_qtdregis > 0 THEN
          -- Finalizar o CLOB
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_dstexto
                                 ,'</Dados>');
        END IF;

        -- Finalizar o CLOB
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'</Root>'
                               ,TRUE);  

        -- Devolver o CLOB
        pr_retxml := xmltype.createXML(vr_clobxml);
        --Fechar Clob e Liberar Memoria  
        dbms_lob.close(vr_clobxml);
        dbms_lob.freetemporary(vr_clobxml); 
      ELSE

      -- Enviar o cabeçalho para o CSV
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                              'Cooperativa;tipo carga;numero carga;descricao carga;tipo pessoa;CPF ou CNPJ base;linha de credito;parcela;limite;data de liberacao;data de vigencia;Situacao;Bloqueio Manual'||CHR(10));

        -- Efetuar a consulta dos cooperados da carga
        FOR rw_info IN cr_info_carga(pr_idcarga) LOOP      
      gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_dstexto
                                 ,rw_info.dscooper||';'
                                 ||rw_info.dstpcarga||';'
                                 ||rw_info.cdcarga||';'
                                 ||rw_info.dscarga||';'
                                 ||rw_info.dstppessoa||';'
                                 ||rw_info.nrcpfcnpj_base||';'
                                 ||rw_info.cdlcremp||';'
                                 ||rw_info.vlcalpar_csv||';'
                                 ||rw_info.vlcalpre_csv ||';'
                                 ||rw_info.dtliberacao||';'
                                 ||rw_info.dtfinal_vigencia||';'
                                 ||fn_traduz_cdsituacao(rw_info.cdsituacao)||';'
                                 ||fn_traduz_bloq_manual(rw_info.bloq_manual)||';'
                                 ||CHR(10));
        END LOOP;
    
        -- Finalizar o CLOB
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,''
                               ,TRUE);
        -- Buscar Diretorio Padrao da Cooperativa
        vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => 'rl');
        --Nome do Arquivo
        vr_nmarquiv:= to_char(sysdate,'RRRRMMDD')           || '_' || 
                      vr_cdoperad                           ||
                      Trunc(DBMS_RANDOM.Value(50000,99999)) || '.csv';
        -- Criar o arquivo no diretorio especificado 
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_clobxml 
                                     ,pr_caminho  => vr_nmdireto 
                                     ,pr_arquivo  => vr_nmarquiv 
                                     ,pr_des_erro => vr_dscritic); 
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;         
        -- Envia-lo ao servidor web.           
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_nmarqpdf => vr_nmdireto||'/'|| vr_nmarquiv
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN                  
          --Se tem erro na tabela 
          IF vr_tab_erro.COUNT > 0 THEN
            --Mensagem Erro
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Erro ao devolver arquivo CSV para AimaroWeb.';  
          END IF;                   
          --Sair 
          RAISE vr_exc_saida;                  
        END IF; 
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root><Dados/></Root>');
                
        -- Incrementa o contador           
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'arquivo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'arquivo', pr_posicao => 0, pr_tag_nova => 'nmarquivo', pr_tag_cont => vr_nmarquiv, pr_des_erro => vr_dscritic);
      END IF;
      
      -- Finalizar como OK
      pr_des_erro := 'OK';        
      COMMIT;
                  
    EXCEPTION
      WHEN vr_exc_saida THEN                                              
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN                                     
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela IMPPRE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_lista_hist_cargas;
  
  -- Executa Exclusão via Arquivo
  PROCEDURE pc_proc_exclu_manual(pr_tpexecuc  IN VARCHAR2           -- Tipo da Execução ([S]imular / [I]mportar)
                                ,pr_dsdiretor IN VARCHAR2           -- Diretorio do arquivo download
                                ,pr_dsarquivo IN VARCHAR2           -- Nome do arquivo para download
                                 -- Interface da Mensageria PHP
                                ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    /* .............................................................................
      Programa: pc_proc_exclu_manual
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : EMPR - Pré-Aprovado
      Autor   : Marcos Martini
      Data    : Janeiro/2019                       Ultima atualizacao: 
      
      Dados referentes ao programa:
      
      Frequencia: Sempre que for chamado
      Objetivo  : Receber arquivo e remover os cooperados no mesmo da carga pre-aprovado atual
      
      Alteracoes: 
      ............................................................................. */
  BEGIN
    DECLARE
      vr_xmldados CLOB;
    BEGIN
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
        RAISE vr_exc_saida;
      END IF;       
      -- Incluir nome
      GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                ,pr_action => 'pc_proc_exclu_manual'); 
      
      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_xmldados, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xmldados, dbms_lob.lob_readwrite);
      
      -- Direcionar para o procedimento de baixa e processamento do arquivo
      empr0002.pc_carga_exclus_via_arquivo(pr_cdcooper => vr_cdcooper
                                          ,pr_cdoperad => vr_cdoperad
                                          ,pr_idorigem => vr_idorigem
                                          ,pr_cdprogra => vr_cdprogra
                                          ,pr_tpexecuc => pr_tpexecuc
                                          ,pr_dsdireto => pr_dsdiretor
                                          ,pr_nmarquiv => pr_dsarquivo
                                          ,pr_xmldados => vr_xmldados
                                          ,pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Somente Quando simulação
      IF pr_tpexecuc = 'S' THEN
        pr_retxml := xmltype.createxml(vr_xmldados);        
        --Fechar Clob e Liberar Memoria  
        dbms_lob.close(vr_xmldados);
        dbms_lob.freetemporary(vr_xmldados);  
      END IF;  
      
      -- Efetuar gravação
      COMMIT;                                    
                                
                                
    EXCEPTION
      WHEN vr_exc_saida THEN        
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela IMPPRE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_proc_exclu_manual;
  
  -- Processo de Bloqueio de Carga
  PROCEDURE pc_proc_bloq_carga(pr_idcarga   IN NUMBER             -- Id Carga 
                               -- Interface da Mensageria PHP
                              ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                              ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    /* .............................................................................
      Programa: pc_proc_bloq_carga
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : EMPR - Pré-Aprovado
      Autor   : Marcos Martini
      Data    : Janeiro/2019                       Ultima atualizacao: 
      
      Dados referentes ao programa:
      
      Frequencia: Sempre que for chamado
      Objetivo  : Bloquear uma carga liberada
      
      Alteracoes: 
      ............................................................................. */
  BEGIN
    DECLARE
      -- Busca da carga
      CURSOR cr_carga IS
        SELECT nvl(pre.flgcarga_bloqueada,0)
          FROM tbepr_carga_pre_aprv pre
         WHERE pre.idcarga = pr_idcarga;
      vr_flgcarga_bloqueada tbepr_carga_pre_aprv.flgcarga_bloqueada%TYPE;
      vr_bloq_libe VARCHAR2(1);
      
    BEGIN
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
        RAISE vr_exc_saida;
      END IF;       
      -- Incluir nome
      GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                ,pr_action => 'pc_proc_bloq_carga'); 
      -- Buscar se a carga atual está liberada ou não
      OPEN cr_carga;
      FETCH cr_carga
       INTO vr_flgcarga_bloqueada;
      CLOSE cr_carga;
      -- Se não encontar 
      IF vr_flgcarga_bloqueada IS NULL THEN
        vr_dscritic := 'Favor selecionar uma carga valida!';
        RAISE vr_exc_saida;
      END IF;                           
      -- Acionar o procedimento de bloqueio/liberação conforme a situação da carga
      IF vr_flgcarga_bloqueada = 1 THEN
        vr_bloq_libe := 'L';
      ELSE
        vr_bloq_libe := 'B';
      END IF;
      
      -- Acionar procedimento de Liberação/Bloqueio
      empr0002.pc_bloq_libera_carga(pr_cdcooper => vr_cdcooper
                                   ,pr_cdprogra  => vr_nmdatela
                                   ,pr_cdoperad => vr_cdoperad
                                   ,pr_idcarga  => pr_idcarga
                                   ,pr_acao     => vr_bloq_libe
                                   ,pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;                             
           
    EXCEPTION
      WHEN vr_exc_saida THEN        
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela IMPPRE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_proc_bloq_carga;
  
END TELA_IMPPRE;
/
