CREATE OR REPLACE PACKAGE CECRED.TELA_CONLOG AS

/* -------------------------------------------------------------------------------------------------------------
  Programa: TELA_CONLOG                           
  Autor   : Ana Lúcia E. Volles - Envolti
  Data    : Setembro/2018                Ultima atualizacao: 20/09/2018

  Objetivo: Ler ocorrencias das tabelas de logs e apresentar em tela de conulta

  Alteracoes: 
 -------------------------------------------------------------------------------------------------------------*/
  -- Procedure para buscar as cooperativas
  PROCEDURE pc_buscar_cooperativas(pr_flcecred   IN INTEGER            --> 0- Nao traz CECRED / 1 - Traz cecred 
                                  ,pr_flgtodas   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS  
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  -- Procedure para consultar as ocorrencias de logs
  PROCEDURE pc_consulta_log (pr_cdcoptel  IN tbgen_prglog.cdcooper%TYPE    --Codigo Cooperativa
                            ,pr_cdprogra  IN tbgen_prglog.cdprograma%TYPE  --Programa
                            ,pr_dtde      IN varchar2                      --Data Inicial
                            ,pr_dtate     IN varchar2                      --Data Final
                            ,pr_nmarqlog  IN VARCHAR2                      --Nome do arquivo de log
                            ,pr_cdmensag  IN VARCHAR2                      --Código da mensagem
                            ,pr_dsmensag  IN VARCHAR2                      --Descrição da mensagem
                            ,pr_tpocorre  IN VARCHAR2                      --Tipo de Ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                            ,pr_cdcriti   IN VARCHAR2                      --Criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                            ,pr_clausula  IN VARCHAR2                      --IN ou NOT IN para o parâmetro pr_dsmensag
                            ,pr_tpexecuc  IN VARCHAR2                      --Tipo de execução (1-Batch/ 2-Job/ 3-Online)
                            ,pr_chamaber  IN VARCHAR2                      --Possui chamado aberto?
                            ,pr_nrchamad  IN VARCHAR2                      --Número do chamado
                             -------> OUT <--------
                            ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                            ,pr_cdcritic     OUT PLS_INTEGER    --> Codigo da critica
                            ,pr_dscritic     OUT VARCHAR2       --> Descricao da critica
                            ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo     OUT VARCHAR2       --> Nome do campo com erro
                            ,pr_des_erro     OUT VARCHAR2);     --> Erros do processo

  -- Procedure para consultar as ocorrencias de logs
  PROCEDURE pc_consulta_log_det (pr_cdcoptel  IN tbgen_prglog.cdcooper%TYPE    --Codigo Cooperativa
                                ,pr_cdprogra  IN tbgen_prglog.cdprograma%TYPE  --Programa
                                ,pr_dtde      IN varchar2                      --Data Inicial
                                ,pr_dtate     IN varchar2                      --Data Final
                                ,pr_nmarqlog  IN VARCHAR2                      --Nome do arquivo de log
                                ,pr_cdmensag  IN VARCHAR2                      --Código da mensagem
                                ,pr_dsmensag  IN VARCHAR2                      --Descrição da mensagem
                                ,pr_tpocorre  IN VARCHAR2                      --Tipo de Ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                                ,pr_cdcriti   IN VARCHAR2                      --Criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                ,pr_idprglog  IN NUMBER                        --Id log
                                ,pr_clausula  IN VARCHAR2                      --IN ou NOT IN para o parâmetro pr_dsmensag
                                ,pr_tpexecuc  IN VARCHAR2                      --Tipo de execução (1-Batch/ 2-Job/ 3-Online)
                                ,pr_chamaber  IN VARCHAR2                      --Possui chamado aberto?
                                ,pr_nrchamad  IN VARCHAR2                      --Número do chamado
                                 -------> OUT <--------
                                ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                ,pr_cdcritic     OUT PLS_INTEGER    --> Codigo da critica
                                ,pr_dscritic     OUT VARCHAR2       --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo     OUT VARCHAR2       --> Nome do campo com erro
                                ,pr_des_erro     OUT VARCHAR2);     --> Erros do processo

  -- Procedure para consultar os erros Oracle
  PROCEDURE pc_consulta_erro (pr_cdcoptel  IN tbgen_prglog.cdcooper%TYPE --Codigo Cooperativa
                             ,pr_dtde      IN varchar2                   --Data Inicial
                             ,pr_dtate     IN varchar2                   --Data Final
                             ,pr_dsmensag  IN VARCHAR2                   --Descrição da mensagem
                             ,pr_clausula  IN VARCHAR2                   --IN ou NOT IN para o parâmetro pr_dsmensag
                              -------> OUT <--------
                             ,pr_xmllog       IN VARCHAR2       --> XML com informacoes de LOG
                             ,pr_cdcritic    OUT PLS_INTEGER    --> Codigo da critica
                             ,pr_dscritic    OUT VARCHAR2       --> Descricao da critica
                             ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo    OUT VARCHAR2       --> Nome do campo com erro
                             ,pr_des_erro    OUT VARCHAR2);     --> Erros do processo

  /* Procedure para incluir uma nova TAG em um nodo XML com CDATA */
  PROCEDURE pc_insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                         ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                         ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                         ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                         ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                         ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  -- Procedure para buscar os nomes de arquivos de log
  PROCEDURE pc_busca_arqlog(pr_flcecred   IN INTEGER            --> 0- Nao traz CECRED / 1 - Traz cecred 
                           ,pr_flgtodas   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS  
                           ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
END TELA_CONLOG;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CONLOG AS

/* --------------------------------------------------------------------------------
  Programa: TBGE0001                           
  Autor   : Ana Lúcia E. Volles - Envolti
  Data    : Setembro/2018                Ultima atualizacao: 20/09/2018

  Objetivo  : Ler ocorrencias das tabelas de logs e apresentar em tela de conulta

  Alteracoes: 
 ---------------------------------------------------------------------------------*/

  vr_cdprogra      tbgen_prglog.cdprograma%type := 'TELA_CONLOG';

  --> Grava informações para resolver erro de programa/ sistema
  PROCEDURE pc_gera_log(pr_cdcooper      IN PLS_INTEGER           --> Cooperativa
                       ,pr_dstiplog      IN VARCHAR2              --> Tipo Log
                       ,pr_dscritic      IN VARCHAR2 DEFAULT NULL --> Descricao da critica
                       ,pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0
                       ,pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0
                       ,pr_ind_tipo_log  IN tbgen_prglog_ocorrencia.tpocorrencia%type DEFAULT 2
                       ,pr_nmarqlog      IN tbgen_prglog.nmarqlog%type DEFAULT NULL) IS
    -----------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_log
    --  Sistema  : Rotina para gravar logs em tabelas
    --  Sigla    : CRED
    --  Autor    : Ana Lúcia E. Volles - Envolti
    --  Data     : Setembro/2018           Ultima atualizacao: 20/09/2018
    --  Chamado  : REQ0026142
    --
    -- Dados referentes ao programa:
    -- Frequencia: Rotina executada em qualquer frequencia.
    -- Objetivo  : Controla gravação de log em tabelas.
    --
    -- Alteracoes:  
    --             
    ------------------------------------------------------------------------------------------------------------   
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    --
  BEGIN         
    --> Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E'), 
                           pr_cdcooper      => pr_cdcooper, 
                           pr_tpocorrencia  => pr_ind_tipo_log, 
                           pr_cdprograma    => vr_cdprogra, 
                           pr_tpexecucao    => 3, --Online
                           pr_cdcriticidade => pr_cdcriticidade,
                           pr_cdmensagem    => pr_cdmensagem,    
                           pr_dsmensagem    => pr_dscritic,               
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => pr_nmarqlog);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
  END pc_gera_log;

  -- Procedure para buscar as cooperativas
  PROCEDURE pc_buscar_cooperativas(pr_flcecred   IN INTEGER            --> 0- Nao traz CECRED / 1 - Traz cecred 
                                  ,pr_flgtodas   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS  
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    Programa: pc_buscar_cooperativas
    Sistema  : Cred
    Sigla    : TELA_CONLOG
    Autor    : Ana Lúcia E. Volles
    Data     : Setembro/2018              Ultima atualizacao: 20/09/2018
    Chamado  : REQ0026142

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as cooperativas ativas 
    Detalhes  : CRAPACA: Package: "TELA_CONLOG" e Ação: "BUSCA_COOPER"

    Alteracoes:                            
    ............................................................................. */
      CURSOR cr_crapcop IS
      SELECT crapcop.cdcooper
            ,crapcop.nmrescop
        FROM crapcop
       WHERE (crapcop.cdcooper <> 3 AND pr_flcecred = 0)
          OR pr_flcecred = 1 
      ORDER BY crapcop.cdcooper;
      
      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_dsparame VARCHAR2(4000);
      
      --Variaveis de Criticas
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
             
      --Variaveis de Excecoes
      vr_exc_erro  EXCEPTION;
      
  BEGIN
    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'TELA_CONLOG.pc_buscar_cooperativas');

    vr_dsparame := ' - pr_flcecred:'||pr_flcecred
                  ||', pr_flgtodas:'||pr_flgtodas
                  ||', pr_xmllog:'  ||pr_xmllog;
      
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

    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'TELA_CONLOG.pc_buscar_cooperativas');

    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><cooperativas></cooperativas></Root>');
      
    IF pr_flgtodas = 1 AND vr_cdcooper = 3 THEN
      pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                         ,'/Root/cooperativas'
                                         ,XMLTYPE('<cooperativa>'
                                                ||'  <cdcooper>0</cdcooper>'
                                                ||'  <nmrescop>TODAS</nmrescop>'
                                                ||'</cooperativa>'));
    END IF;                                                                                                
                                                  
    FOR rw_crapcop IN cr_crapcop LOOP
      IF vr_cdcooper <> 3                   AND 
         rw_crapcop.cdcooper <> vr_cdcooper THEN 
        
        continue;
      END IF;         
          
      -- Criar nodo filho
      pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                          ,'/Root/cooperativas'
                                          ,XMLTYPE('<cooperativa>'
                                                 ||'  <cdcooper>'||rw_crapcop.cdcooper||'</cdcooper>'
                                                 ||'  <nmrescop>'||UPPER(rw_crapcop.nmrescop)||'</nmrescop>'
                                                 ||'</cooperativa>'));
    END LOOP;
    
    -- Retorno OK          
    pr_des_erro:= 'OK';

    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
          
  EXCEPTION
    WHEN vr_exc_erro THEN 

      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'cdcooper';
      pr_des_erro := 'NOK'; 

      --Grava tabela de log
      pc_gera_log(pr_cdcooper      => nvl(vr_cdcooper,0),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
      WHEN OTHERS THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';

        CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'TELA_CONLOG.pc_buscar_cooperativas. '||sqlerrm||vr_dsparame;

        --Grava tabela de log
        pc_gera_log(pr_cdcooper      => nvl(vr_cdcooper,0),
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_buscar_cooperativas;

  -- Procedure para consultar as ocorrencias de logs - cabeçalhos
  PROCEDURE pc_consulta_log (pr_cdcoptel  IN tbgen_prglog.cdcooper%TYPE    --Codigo Cooperativa
                            ,pr_cdprogra  IN tbgen_prglog.cdprograma%TYPE  --Programa
                            ,pr_dtde      IN varchar2                      --Data Inicial
                            ,pr_dtate     IN varchar2                      --Data Final
                            ,pr_nmarqlog  IN VARCHAR2                      --Nome do arquivo de log
                            ,pr_cdmensag  IN VARCHAR2                      --Código da mensagem
                            ,pr_dsmensag  IN VARCHAR2                      --Descrição da mensagem
                            ,pr_tpocorre  IN VARCHAR2                      --Tipo de Ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                            ,pr_cdcriti   IN VARCHAR2                      --Criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                            ,pr_clausula  IN VARCHAR2                      --IN ou NOT IN para o parâmetro pr_dsmensag
                            ,pr_tpexecuc  IN VARCHAR2                      --Tipo de execução (1-Batch/ 2-Job/ 3-Online)
                            ,pr_chamaber  IN VARCHAR2                      --Possui chamado aberto? (S-Sim/N-Não)
                            ,pr_nrchamad  IN VARCHAR2                      --Número do chamado
                             -------> OUT <--------
                            ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                            ,pr_cdcritic     OUT PLS_INTEGER    --> Codigo da critica
                            ,pr_dscritic     OUT VARCHAR2       --> Descricao da critica
                            ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo     OUT VARCHAR2       --> Nome do campo com erro
                            ,pr_des_erro     OUT VARCHAR2) IS   --> Erros do processo
  -- ...........................................................................................
  --
  --  Programa: pc_consulta_log
  --  Sistema : Cred
  --  Sigla   : TELA_CONLOG
  --  Autor   : Ana Lúcia E. Volles
  --  Data    : Setembro/2018              Ultima atualizacao: 20/09/2018
  --  Chamado : REQ0026142
  --
  --  Dados referentes ao programa:
  --  Frequencia: Sempre que for chamado
  --  Objetivo  : Procedure para consultar as ocorrências (cabeçalhos) de logs nas tabelas tbgen
  --  Detalhes  : CRAPACA: Package: "TELA_CONLOG" e Ação: "CONSULTA_LOG"
  --
  --  Alterações:
  --
  -- ...........................................................................................

  BEGIN
    DECLARE
      vr_dsparame     VARCHAR2(4000);
      vr_cdcooper     INTEGER;
      vr_cdoperad     VARCHAR2(100);
      vr_nmdatela     VARCHAR2(100);
      vr_nmeacao      VARCHAR2(100);
      vr_cdagenci     VARCHAR2(100);
      vr_nrdcaixa     VARCHAR2(100);
      vr_idorigem     VARCHAR2(100);
      -- Variável de críticas
      vr_cdcritic     crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic     VARCHAR2(1000);        --> Desc. Erro
      
      -- Tratamento de erros
      vr_exc_erro     EXCEPTION;

      -- Variáveis gerais da procedure
      vr_cont         INTEGER := 0; -- Contador

      CURSOR cr_Ocorrencias IS
        select distinct prl.cdcooper,
                        prl.idprglog,
                        prl.cdprograma,
                        prl.dhinicio,
                        prl.dhfim,
                        prl.nmarqlog,
                        prl.tpexecucao
          from tbgen_prglog_ocorrencia oco,
               tbgen_prglog            prl
         where trunc(prl.dhinicio) between to_date(pr_dtde, 'dd/mm/yyyy') and to_date(pr_dtate, 'dd/mm/yyyy')
           and prl.cdcooper = decode(pr_cdcoptel,
                                     0, prl.cdcooper,
                                     pr_cdcoptel)
           and (pr_cdprogra is null or instr(upper(prl.cdprograma), upper(pr_cdprogra)) > 0)
           and (pr_nmarqlog is null or instr(prl.nmarqlog, pr_nmarqlog) > 0)
           and nvl(prl.tpexecucao, -1) = decode(pr_tpexecuc,
                                                null, nvl(prl.tpexecucao, -1),
                                                pr_tpexecuc)
           --
           and oco.idprglog = prl.idprglog
           --
           and trunc(oco.dhocorrencia) between to_date(pr_dtde, 'dd/mm/yyyy') and to_date(pr_dtate, 'dd/mm/yyyy')
           and nvl(oco.cdmensagem, -1) = decode(pr_cdmensag,
                                                null, nvl(oco.cdmensagem, -1),
                                                pr_cdmensag)
           and (   pr_clausula is null
                or (    pr_clausula = 'IN'
                    and (pr_dsmensag is null or instr(upper(oco.dsmensagem), upper(pr_dsmensag)) > 0))
                or (    pr_clausula = 'NOT IN'
                    and (pr_dsmensag is null or instr(upper(oco.dsmensagem), upper(pr_dsmensag)) = 0)))
           and nvl(oco.cdcriticidade, -1) = decode(pr_cdcriti,
                                                   null, nvl(oco.cdcriticidade, -1),
                                                   pr_cdcriti)
           and nvl(oco.tpocorrencia, -1) = decode(pr_tpocorre,
                                                  null, nvl(oco.tpocorrencia, -1),
                                                  pr_tpocorre)
           and nvl(oco.nrchamado, -1) = decode(pr_nrchamad,
                                               null, nvl(oco.nrchamado, -1),
                                               pr_nrchamad)
           and (   pr_chamaber is null
                or (pr_chamaber = 'S' and oco.nrchamado is not null)
                or (pr_chamaber = 'N' and oco.nrchamado is null))
         order by prl.cdcooper,
                  prl.idprglog,
                  prl.cdprograma;

    rw_Ocorrencias cr_Ocorrencias%ROWTYPE;
  --                    
  BEGIN  
    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'TELA_CONLOG.pc_consulta_log');

    vr_dsparame := ' - pr_cdcoptel:'  ||pr_cdcoptel
                  ||', pr_cdprograma:'||pr_cdprogra
                  ||', pr_dtde:'      ||pr_dtde
                  ||', pr_dtate:'     ||pr_dtate
                  ||', pr_nmarqlog:'  ||pr_nmarqlog
                  ||', pr_tpocorre:'  ||pr_tpocorre
                  ||', pr_cdcritic:'  ||pr_cdcriti
                  ||', pr_cdmensag:'  ||pr_cdmensag
                  ||', pr_dsmensag:'  ||pr_dsmensag
                  ||', pr_clausula:'  ||pr_clausula
                  ||', pr_tpexecuc:'  ||pr_tpexecuc
                  ||', pr_chamaber:'  ||pr_chamaber
                  ||', pr_nrchamad:'  ||pr_nrchamad;

    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Tratar requisição
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;                 

    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'TELA_CONLOG.pc_consulta_log');

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                            pr_tag_pai  => 'Root',
                            pr_posicao  => 0,
                            pr_tag_nova => 'Logs',
                            pr_tag_cont => NULL,
                            pr_des_erro => vr_dscritic);

    -- Carregar tabela memoria execucoes programas exclusivos
    FOR rw_Ocorrencias IN cr_Ocorrencias LOOP

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Logs',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Log',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Log',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'Cooper',
                               pr_tag_cont => rw_Ocorrencias.cdcooper,
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Log',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'Idprglog',
                               pr_tag_cont => rw_Ocorrencias.idprglog,
                               pr_des_erro => pr_dscritic);    
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Log',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'Programa',
                               pr_tag_cont => rw_Ocorrencias.cdprograma,
                               pr_des_erro => pr_dscritic);    

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Log',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'ArquivoLog',
                               pr_tag_cont => rw_Ocorrencias.nmarqlog,
                               pr_des_erro => pr_dscritic);    

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Log',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'DhInicio',
                               pr_tag_cont => to_char(rw_Ocorrencias.dhinicio,'dd/mm/yyyy hh24:mi:ss'),
                               pr_des_erro => pr_dscritic);    

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Log',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'DhFim',
                               pr_tag_cont => to_char(rw_Ocorrencias.dhfim,'dd/mm/yyyy hh24:mi:ss'),
                               pr_des_erro => pr_dscritic);    
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Log',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'TpExecuc',
                               pr_tag_cont => rw_Ocorrencias.tpexecucao,
                               pr_des_erro => pr_dscritic);    
                               
        vr_cont := vr_cont + 1;          

    END LOOP;

    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      --Grava tabela de log
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcoptel,0),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcoptel);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'TELA_CONLOG.pc_consulta_log. '||sqlerrm||vr_dsparame;

        --Grava tabela de log
        pc_gera_log(pr_cdcooper      => nvl(pr_cdcoptel,0),
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
    
  END pc_consulta_log;

  -- Procedure para consultar as ocorrencias de logs - detalhes
  PROCEDURE pc_consulta_log_det (pr_cdcoptel  IN tbgen_prglog.cdcooper%TYPE    --Codigo Cooperativa
                                ,pr_cdprogra  IN tbgen_prglog.cdprograma%TYPE  --Programa
                                ,pr_dtde      IN varchar2                      --Data Inicial
                                ,pr_dtate     IN varchar2                      --Data Final
                                ,pr_nmarqlog  IN VARCHAR2                      --Nome do arquivo de log
                                ,pr_cdmensag  IN VARCHAR2                      --Código da mensagem
                                ,pr_dsmensag  IN VARCHAR2                      --Descrição da mensagem
                                ,pr_tpocorre  IN VARCHAR2                      --Tipo de Ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                                ,pr_cdcriti   IN VARCHAR2                      --Criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                ,pr_idprglog  IN NUMBER                        --Id log
                                ,pr_clausula  IN VARCHAR2                      --IN ou NOT IN para o parâmetro pr_dsmensag
                                ,pr_tpexecuc  IN VARCHAR2                      --Tipo de execução (1-Batch/ 2-Job/ 3-Online)
                                ,pr_chamaber  IN VARCHAR2                      --Possui chamado aberto?
                                ,pr_nrchamad  IN VARCHAR2                      --Número do chamado
                                 -------> OUT <--------
                                ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                ,pr_cdcritic     OUT PLS_INTEGER    --> Codigo da critica
                                ,pr_dscritic     OUT VARCHAR2       --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo     OUT VARCHAR2       --> Nome do campo com erro
                                ,pr_des_erro     OUT VARCHAR2) IS   --> Erros do processo
  -- ...........................................................................................
  --
  --  Programa: pc_consulta_log_det
  --  Sistema : Cred
  --  Sigla   : TELA_CONLOG
  --  Autor   : Ana Lúcia E. Volles
  --  Data    : Setembro/2018              Ultima atualizacao: 20/09/2018
  --  Chamado : REQ0026142
  --
  --  Dados referentes ao programa:
  --  Frequencia: Sempre que for chamado
  --  Objetivo  : Procedure para consultar as ocorrências de logs nas tabelas tbgen
  --  Detalhes  : CRAPACA: Package: "TELA_CONLOG" e Ação: "CONSULTA_LOG_DET"
  --
  --  Alterações:
  --
  -- ...........................................................................................

  BEGIN
    DECLARE
    vr_dsparame     VARCHAR2(4000);
    vr_cdcooper     INTEGER;
    vr_cdoperad     VARCHAR2(100);
    vr_nmdatela     VARCHAR2(100);
    vr_nmeacao      VARCHAR2(100);
    vr_cdagenci     VARCHAR2(100);
    vr_nrdcaixa     VARCHAR2(100);
    vr_idorigem     VARCHAR2(100);
    -- Variável de críticas
    vr_cdcritic     crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic     VARCHAR2(1000);        --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    -- Variáveis gerais da procedure
    vr_cont INTEGER := 0; -- Contador
      
    CURSOR cr_Ocorrencias IS
      select prl.cdcooper,
             prl.cdprograma,
             prl.dhinicio,
             prl.dhfim,
             oco.cdmensagem,
             replace(replace(oco.dsmensagem, '<', ' < '),'>', ' > ') dsmensagem,
             oco.nrchamado,
             oco.idocorrencia,
             oco.dhocorrencia,
             oco.tpocorrencia,
             oco.cdcriticidade,
             prl.nmarqlog,
             oco.flgrecorrente,
             trunc(oco.dhocorrencia),
             prl.idprglog,
             prl.tpexecucao
        from tbgen_prglog_ocorrencia oco,
             tbgen_prglog            prl
       where trunc(prl.dhinicio) between to_date(pr_dtde, 'dd/mm/yyyy') and to_date(pr_dtate, 'dd/mm/yyyy')
         and prl.cdcooper = decode(pr_cdcoptel,
                                   0, prl.cdcooper,
                                   pr_cdcoptel)
         and (pr_cdprogra is null or instr(upper(prl.cdprograma), upper(pr_cdprogra)) > 0)
         and (pr_nmarqlog is null or instr(prl.nmarqlog, pr_nmarqlog) > 0)
         and nvl(prl.tpexecucao, -1) = decode(pr_tpexecuc,
                                              null, nvl(prl.tpexecucao, -1),
                                              pr_tpexecuc)
         --
         and oco.idprglog = prl.idprglog
         --
         and trunc(oco.dhocorrencia) between to_date(pr_dtde, 'dd/mm/yyyy') and to_date(pr_dtate, 'dd/mm/yyyy')
         and nvl(oco.cdmensagem, -1) = decode(pr_cdmensag,
                                              null, nvl(oco.cdmensagem, -1),
                                              pr_cdmensag)
         and (   pr_clausula is null
              or (    pr_clausula = 'IN'
                  and (pr_dsmensag is null or instr(upper(oco.dsmensagem), upper(pr_dsmensag)) > 0))
              or (    pr_clausula = 'NOT IN'
                  and (pr_dsmensag is null or instr(upper(oco.dsmensagem), upper(pr_dsmensag)) = 0)))
         and nvl(oco.cdcriticidade, -1) = decode(pr_cdcriti,
                                                 null, nvl(oco.cdcriticidade, -1),
                                                 pr_cdcriti)
         and nvl(oco.tpocorrencia, -1) = decode(pr_tpocorre,
                                                null, nvl(oco.tpocorrencia, -1),
                                                pr_tpocorre)
         and nvl(oco.nrchamado, -1) = decode(pr_nrchamad,
                                             null, nvl(oco.nrchamado, -1),
                                             pr_nrchamad)
         and (   pr_chamaber is null
              or (pr_chamaber = 'S' and oco.nrchamado is not null)
              or (pr_chamaber = 'N' and oco.nrchamado is null))
         and nvl(oco.idprglog, -1) = decode(pr_idprglog,
                                            null, nvl(oco.idprglog, -1),
                                            pr_idprglog)
       order by prl.cdcooper,
                prl.idprglog,
                prl.cdprograma,
                oco.idocorrencia;
    rw_Ocorrencias cr_Ocorrencias%ROWTYPE;
  --                    
  BEGIN  
    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'TELA_CONLOG.pc_consulta_log_det');

    vr_dsparame := ' - pr_cdcoptel:'  ||pr_cdcoptel
                  ||', pr_cdprograma:'||pr_cdprogra
                  ||', pr_dtde:'      ||pr_dtde
                  ||', pr_dtate:'     ||pr_dtate
                  ||', pr_nmarqlog:'  ||pr_nmarqlog 
                  ||', pr_tpocorre:'  ||pr_tpocorre
                  ||', pr_cdcritic:'  ||pr_cdcriti
                  ||', pr_cdmensag:'  ||pr_cdmensag
                  ||', pr_dsmensag:'  ||pr_dsmensag
                  ||', pr_clausula:'  ||pr_clausula
                  ||', pr_tpexecuc:'  ||pr_tpexecuc
                  ||', pr_chamaber:'  ||pr_chamaber
                  ||', pr_nrchamad:'  ||pr_nrchamad
                  ||', pr_idprglog:'  ||pr_idprglog;

    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Tratar requisição
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;                 

    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'TELA_CONLOG.pc_consulta_log_det');

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                            pr_tag_pai  => 'Root',
                            pr_posicao  => 0,
                            pr_tag_nova => 'Logs',
                            pr_tag_cont => NULL,
                            pr_des_erro => vr_dscritic);

    -- Carregar tabela memoria execucoes programas exclusivos
    FOR rw_Ocorrencias IN cr_Ocorrencias LOOP

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Logs',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Detalhes', --'Log',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Detalhes',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'Cdmensagem',
                               pr_tag_cont => rw_Ocorrencias.cdmensagem,
                               pr_des_erro => pr_dscritic);    

        --Utiliza rotina local para CDATA
        pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Detalhes',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'Descricao',
                               pr_tag_cont => rw_Ocorrencias.dsmensagem,
                               pr_des_erro => pr_dscritic);    

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Detalhes',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'IdOcorrencia',
                               pr_tag_cont => rw_Ocorrencias.idocorrencia,
                               pr_des_erro => pr_dscritic);    

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Detalhes',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'DhOcorrencia',
                               pr_tag_cont => to_char(rw_Ocorrencias.dhocorrencia,'dd/mm/yyyy hh24:mi:ss'),
                               pr_des_erro => pr_dscritic);    

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Detalhes',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'TipoOcorrencia',
                               pr_tag_cont => rw_Ocorrencias.tpocorrencia,
                               pr_des_erro => pr_dscritic);    

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Detalhes',
                               pr_posicao  => vr_cont,
                               pr_tag_nova => 'Criticidade',
                               pr_tag_cont => rw_Ocorrencias.cdcriticidade,
                               pr_des_erro => pr_dscritic);    

        vr_cont := vr_cont + 1;          

    END LOOP;

    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      --Grava tabela de log
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcoptel,0),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcoptel);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'TELA_CONLOG.pc_consulta_log_det. '||sqlerrm||vr_dsparame;

        --Grava tabela de log
        pc_gera_log(pr_cdcooper      => nvl(pr_cdcoptel,0),
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
    
  END pc_consulta_log_det;

  -- Procedure para consultar os erros Oracle
  PROCEDURE pc_consulta_erro (pr_cdcoptel  IN tbgen_prglog.cdcooper%TYPE --Codigo Cooperativa
                             ,pr_dtde      IN varchar2                   --Data Inicial
                             ,pr_dtate     IN varchar2                   --Data Final
                             ,pr_dsmensag  IN VARCHAR2                   --Descrição da mensagem
                             ,pr_clausula  IN VARCHAR2                   --IN ou NOT IN para o parâmetro pr_dsmensag
                              -------> OUT <--------
                              ,pr_xmllog       IN VARCHAR2       --> XML com informacoes de LOG
                              ,pr_cdcritic    OUT PLS_INTEGER    --> Codigo da critica
                              ,pr_dscritic    OUT VARCHAR2       --> Descricao da critica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo    OUT VARCHAR2       --> Nome do campo com erro
                              ,pr_des_erro    OUT VARCHAR2) IS   --> Erros do processo
  -- ...........................................................................................
  --
  --  Programa: pc_consulta_erro
  --  Sistema : Cred
  --  Sigla   : TELA_CONLOG
  --  Autor   : Ana Lúcia E. Volles
  --  Data    : Setembro/2018              Ultima atualizacao: 20/09/2018
  --  Chamado : REQ0026142
  --
  --  Dados referentes ao programa:
  --  Frequencia: Sempre que for chamado
  --  Objetivo  : Procedure para consultar os erros Oracle na tabela tbgen_erro_sistema
  --  Detalhes  :
  --    $xmlResult = mensageria($xmlCarregaDados
  --              ,"CONLOG"
  --              ,"CONSULTA_ERRO"
  --              ,$glbvars["cdcooper"]
  --              ,$glbvars["cdagenci"]
  --              ,$glbvars["nrdcaixa"]
  --              ,$glbvars["idorigem"]
  --              ,$glbvars["cdoperad"]
  --              ,"</Root>");
  --
  --  Alterações:
  --
  -- ...........................................................................................

  BEGIN
    DECLARE
      vr_dsparame    VARCHAR2(4000);
      vr_cdcooper    INTEGER;
      vr_cdoperad    VARCHAR2(100);
      vr_nmdatela    VARCHAR2(100);
      vr_nmeacao     VARCHAR2(100);
      vr_cdagenci    VARCHAR2(100);
      vr_nrdcaixa    VARCHAR2(100);
      vr_idorigem    VARCHAR2(100);

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic      VARCHAR2(1000);        --> Desc. Erro
      
      -- Tratamento de erros
      vr_exc_erro      EXCEPTION;

      -- Variáveis gerais da procedure
      vr_cont INTEGER := 0; -- Contador

      CURSOR cr_Erros IS
        select tes.cdcooper,
               tes.dherro,
               tes.dserro,
               tes.nrsqlcode
          from tbgen_erro_sistema tes
         where trunc(tes.dherro) between to_date(pr_dtde, 'dd/mm/yyyy') and to_date(pr_dtate, 'dd/mm/yyyy')
           and tes.cdcooper = decode(pr_cdcoptel,
                                     0, tes.cdcooper,
                                     pr_cdcoptel)
           and (   pr_clausula is null
                or (    pr_clausula = 'IN'
                    and (pr_dsmensag is null or instr(upper(tes.dserro), upper(pr_dsmensag)) > 0))
                or (    pr_clausula = 'NOT IN'
                    and (pr_dsmensag is null or instr(upper(tes.dserro), upper(pr_dsmensag)) = 0)))
         order by tes.cdcooper, tes.dherro;

      rw_Erros cr_Erros%ROWTYPE;
    
  --                    
  BEGIN  
    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'TELA_CONLOG.pc_consulta_erro');

    vr_dsparame := ' - pr_cdcoptel:' ||pr_cdcoptel
                  ||', pr_dtde:'     ||pr_dtde
                  ||', pr_dtate:'    ||pr_dtate
                  ||', pr_dsmensag:' ||pr_dsmensag
                  ||', pr_clausula:' ||pr_clausula;

    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Tratar requisição
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;                 

    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'TELA_CONLOG.pc_consulta_erro');

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                            pr_tag_pai  => 'Root',
                            pr_posicao  => 0,
                            pr_tag_nova => 'Erros',
                            pr_tag_cont => NULL,
                            pr_des_erro => vr_dscritic);

    -- Carregar tabela memoria execucoes programas exclusivos
    FOR rw_Erros IN cr_Erros LOOP

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Erros',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Erro',
                             pr_tag_cont => NULL,
                             pr_des_erro => pr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Erro',
                             pr_posicao  => vr_cont,
                             pr_tag_nova => 'Cooper',
                             pr_tag_cont => rw_Erros.cdcooper,
                             pr_des_erro => pr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Erro',
                             pr_posicao  => vr_cont,
                             pr_tag_nova => 'Data',
                             pr_tag_cont => to_char(rw_Erros.dherro,'dd/mm/yyyy hh24:mi:ss'),
                             pr_des_erro => pr_dscritic);    
                               
      --Utiliza rotina local para CDATA
      pc_insere_tag(pr_xml      => pr_retxml, 
                             pr_tag_pai  => 'Erro',
                             pr_posicao  => vr_cont,
                             pr_tag_nova => 'Descricao',
                             pr_tag_cont => rw_Erros.dserro,
                             pr_des_erro => pr_dscritic);    

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Erro',
                             pr_posicao  => vr_cont,
                             pr_tag_nova => 'Sqlcode',
                             pr_tag_cont => rw_Erros.nrsqlcode,
                             pr_des_erro => pr_dscritic);    

        vr_cont := vr_cont + 1;          
    END LOOP;

    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      --Grava tabela de log
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcoptel,0),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcoptel);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'TELA_CONLOG.pc_consulta_erro. '||sqlerrm||vr_dsparame;

        --Grava tabela de log
        pc_gera_log(pr_cdcooper      => nvl(pr_cdcoptel,0),
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
    
  END pc_consulta_erro;

  /* Procedure para incluir uma nova TAG em um nodo XML com CDATA */
  PROCEDURE pc_insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                         ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                         ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                         ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                         ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                         ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
  -- ..........................................................................
  --
  --  Programa: pc_insere_tag
  --  Sistema : Rotina de tratamento e interface de dados com sistema Web
  --  Sigla   : TELA_CONLOG
  --  Autor   : Ana Lúcia E. Volles
  --  Data    : Setembro/2018              Ultima atualizacao: 20/09/2018
  --  Chamado : REQ0026142
  --
  --  Dados referentes ao programa:
  --
  --   Frequencia: Sempre que for chamado
  --   Objetivo  : Inserir uma nova TAG em um nodo XML.
  --
  --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  -- .............................................................................
BEGIN
  DECLARE
    vr_dsparame  VARCHAR2(4000);
    vr_domDoc    DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)
    vr_elemento  DBMS_XMLDOM.DOMElement;       --> Novo elemento que será adicionado
    vr_novoNodo  DBMS_XMLDOM.DOMNode;          --> Novo nodo baseado no elemento
    vr_paiNodo   DBMS_XMLDOM.DOMNode;          --> Nodo pai
    vr_texto     DBMS_XMLDOM.DOMCDATASection;  --> Texto que será incluido para utilização de CDATA
    vr_cdcritic  INTEGER;
    vr_dscritic  VARCHAR2(4000);

  BEGIN
    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'TELA_CONLOG.pc_insere_tag');

    vr_dsparame := ' - pr_tag_pai:' ||pr_tag_pai
                  ||', pr_posicao:' ||pr_posicao
                  ||', pr_tag_nova:'||pr_tag_nova
                  ||', pr_tag_cont:'||pr_tag_cont;

    -- Cria o documento DOM com base no XML enviado
    vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_xml);
    -- Criar novo elemento
    vr_elemento := DBMS_XMLDOM.createElement(vr_domDoc, pr_tag_nova);
    -- Criar novo nodo
    vr_novoNodo := DBMS_XMLDOM.makeNode(vr_elemento);
    -- Definir nodo pai
    vr_paiNodo := DBMS_XMLDOM.makeNode(DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(vr_domDoc, pr_tag_pai), pr_posicao)));
    -- Adiciona novo nodo no nodo pai
    vr_novoNodo := DBMS_XMLDOM.appendChild(vr_paiNodo, vr_novoNodo);
    -- Adiciona o conteúdo ao novo nodo utilizando CDATA
    vr_texto := DBMS_XMLDOM.createCDATASection(vr_domDoc, pr_tag_cont);
    vr_novoNodo := DBMS_XMLDOM.appendChild(vr_novoNodo, DBMS_XMLDOM.makeNode(vr_texto));

    -- Gerar o novo stream XML
    pr_xml := DBMS_XMLDOM.getxmltype(vr_domDoc);
      
    -- Liberar uso de memória
    dbms_xmldom.freeDocument(vr_domDoc);

    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => 0);

      -- Erro
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'TELA_CONLOG.pc_insere_tag. '||sqlerrm||vr_dsparame;

      --Grava tabela de log
      pc_gera_log(pr_cdcooper      => 0,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => vr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

    END;
  END pc_insere_tag;

  -- Procedure para buscar os nomes de arquivos de log
  PROCEDURE pc_busca_arqlog(pr_flcecred   IN INTEGER            --> 0- Nao traz CECRED / 1 - Traz cecred 
                           ,pr_flgtodas   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS  
                           ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
  -- ...........................................................................................
  --
  --  Programa: pc_busca_arqlog
  --  Sistema : Cred
  --  Sigla   : TELA_CONLOG
  --  Autor   : Ana Lúcia E. Volles
  --  Data    : Setembro/2018              Ultima atualizacao: 18/10/2018
  --  Chamado : REQ0026142
  --
  --  Dados referentes ao programa:
  --  Frequencia: Sempre que for chamado
  --  Objetivo  : Procedure para buscar os nomes de arquivos de logs existentes na tabela tbgen_prglog
  --  Detalhes  : CRAPACA: Package: "TELA_CONLOG" e Ação: "BUSCA_ARQLOG"
  --
  --  Alterações:
  --
  -- ...........................................................................................
    CURSOR cr_nmarqlog IS
      SELECT DISTINCT a.nmarqlog
      FROM tbgen_prglog a
      ORDER BY a.nmarqlog;
        
    -- Variaveis de locais
    vr_nmarqlog tbgen_prglog.nmarqlog%TYPE;
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dsparame VARCHAR2(4000);
    vr_cont     INTEGER := 0; -- Contador
        
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
               
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;
        
  BEGIN
  -- Inclui nome do modulo logado
  GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'TELA_CONLOG.pc_busca_arqlog');

  vr_dsparame := ' - pr_flcecred:'||pr_flcecred
                ||', pr_flgtodas:'||pr_flgtodas
                ||', pr_xmllog:'  ||pr_xmllog;
        
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

  -- Inclui nome do modulo logado
  GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'TELA_CONLOG.pc_busca_arqlog');

  -- Verifica se houve erro recuperando informacoes de log                              
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF; 
        
  -- Criar cabecalho do XML
  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Arquivos></Arquivos></Root>');
        
  FOR rw_nmarqlog IN cr_nmarqlog LOOP
          
    -- Criar nodo filho
    pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                        ,'/Root/Arquivos'
                                        ,XMLTYPE('  <nmarqlog>'||rw_nmarqlog.nmarqlog||'</nmarqlog>'));

  END LOOP;
      
  -- Retorno OK          
  pr_des_erro:= 'OK';

  -- Inclui nome do modulo logado
  GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
            
  EXCEPTION
    WHEN vr_exc_erro THEN 

      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'nmarqlog';
      pr_des_erro := 'NOK'; 

      --Grava tabela de log
      pc_gera_log(pr_cdcooper      => nvl(vr_cdcooper,0),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                         
      WHEN OTHERS THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';

        CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'TELA_CONLOG.pc_busca_arqlog. '||sqlerrm||vr_dsparame;

        --Grava tabela de log
        pc_gera_log(pr_cdcooper      => nvl(vr_cdcooper,0),
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_busca_arqlog;
	
END TELA_CONLOG;
/
