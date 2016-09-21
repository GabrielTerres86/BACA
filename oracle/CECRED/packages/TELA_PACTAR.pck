CREATE OR REPLACE PACKAGE CECRED.TELA_PACTAR AS

  -- Definicao de TEMP TABLE para consulta do saldo de aplicacao RDCA
  TYPE typ_reg_tbtarif_pacotes IS
    RECORD(cdpacote            tbtarif_pacotes.cdpacote%TYPE            --> Codigo do pacote
          ,dspacote            tbtarif_pacotes.dspacote%TYPE            --> Descricao do pacote
          ,cdtarifa_lancamento tbtarif_pacotes.cdtarifa_lancamento%TYPE --> Codigo da tarifa de lancamento
          ,flgsituacao         tbtarif_pacotes.flgsituacao%TYPE         --> Indica a situação do pacote de tarifas(0=inativo, 1=ativo)
          ,dtmvtolt            tbtarif_pacotes.dtmvtolt%TYPE            --> Data do movimento
          ,dtcancelamento      tbtarif_pacotes.dtcancelamento%TYPE      --> Data do cancelamento
          ,tppessoa            tbtarif_pacotes.tppessoa%TYPE            --> Indica o tipo de pessoa a quem se destina o pacote (1=Pessoa Fisica, 2=Pessoa Juridica))
          ,dspessoa            VARCHAR2(50)                             --> Descricao do Tipo de Pessoa
          ,dstarifa            VARCHAR2(50)                             --> Descricao da tarifa
          ,cddopcao            VARCHAR2(2)                              --> Tipo de Opcao Selecionada
          ,vlpacote            VARCHAR2(50));                           --> Valor do Pacote de Tarifas

  -- Definicao de tipo de tabela para acumulo Aplicacoes
  TYPE typ_tab_tbtarif_pacotes IS
    TABLE OF typ_reg_tbtarif_pacotes
    INDEX BY BINARY_INTEGER;
     
  PROCEDURE pc_consulta_codigo(pr_cddopcao IN VARCHAR2           --> Código da Opcao
                              ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);        --> Saida OK/NOK

  PROCEDURE pc_valida_pacote_tarifa(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao
                                   ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE            --> Codigo do Pacote
                                   ,pr_tppessoa IN tbtarif_pacotes.tppessoa%TYPE            --> Tipo de Pessoa
                                   ,pr_cdtarifa IN tbtarif_pacotes.cdtarifa_lancamento%TYPE --> Codigo da Tarifa
                                   ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE            --> Descricao do Pacote
                                   ,pr_dstarifa IN VARCHAR2                                 --> Descrição da Tarifa    
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE                   --> Codigo de Erro
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE);                 --> Descricao de Erro

  PROCEDURE pc_val_pct_tarifa_web(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao
                                 ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE            --> Codigo do Pacote
                                 ,pr_tppessoa IN tbtarif_pacotes.tppessoa%TYPE            --> Tipo de Pessoa
                                 ,pr_cdtarifa IN tbtarif_pacotes.cdtarifa_lancamento%TYPE --> Codigo da Tarifa
                                 ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE            --> Descricao do Pacote
                                 ,pr_dstarifa IN VARCHAR2                                 --> Descrição da Tarifa    
                                 ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                                --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);                              --> Saida OK/NOK

  PROCEDURE pc_consulta_tarifa(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao
                              ,pr_tppessoa IN tbtarif_pacotes.tppessoa%TYPE            --> Tipo de Pessoa
                              ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                                --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);                              --> Saida OK/NOK

  -- Rotina geral para consulta de pacotes de tarifas
  PROCEDURE pc_consulta_pacote_tarifa(pr_cddopcao IN VARCHAR2           --> Código da Opcao
                                     ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE               --> Código do Pacote de Tarifas
                                     ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE               --> Descricao do Pacote de Tarifas
                                     ,pr_nrregist IN NUMBER                                      --> Numero de Registros Exibidos
                                     ,pr_nrinireg IN NUMBER                                      --> Registro Inicial
                                     ,pr_qtregist OUT NUMBER                                     --> Quantidade de Registros
                                     ,pr_tbtarif_pacotes OUT TELA_PACTAR.typ_tab_tbtarif_pacotes --> Tabela com os dados de pacotes
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Código da crítica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE);                    --> Descrição da crítica

  -- Rotina para consulta de pacotes de tarifas via PROGRESS
  PROCEDURE pc_consulta_pct_tar_car(pr_cddopcao IN VARCHAR2           --> Código da Opcao
                                   ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Código do Pacote de Tarifas
                                   ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE --> Descricao do Pacote de Tarifas
                                   ,pr_nrregist IN NUMBER                        --> Numero de Registros Exibidos
                                   ,pr_nrinireg IN NUMBER                        --> Registro Inicial
                                   ,pr_qtregist OUT NUMBER                       --> Quantidade de Registros
                                   ,pr_clobxmlc OUT CLOB                         --> XML com dos Pacotes de tarifas
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Código da crítica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE);      --> Descrição da crítica
  
  -- Rotina para consulta de pacotes de tarifas via AYLLOS WEB
  PROCEDURE pc_consulta_pct_tar_web(pr_cddopcao IN VARCHAR2           --> Código da Opcao
                                   ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Código do Pacote de Tarifas
                                   ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE --> Descricao do Pacote de Tarifas
                                   ,pr_nrregist IN NUMBER                        --> Numero de Registros Exibidos
                                   ,pr_nrinireg IN NUMBER                        --> Registro Inicial
                                   ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2);                   --> Saida OK/NOK
  
  -- Rotina para consulta de descricao da tariga
  PROCEDURE pc_consulta_desc_tarifa(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao                                 
                                   ,pr_tppessoa IN tbtarif_pacotes.tppessoa%TYPE            --> Tipo de Pessoa
                                   ,pr_cdtarifa IN tbtarif_pacotes.cdtarifa_lancamento%TYPE --> Codigo da Tarifa
                                   ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                                --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2);                              --> Saida OK/NOK

  -- Rotina para cadastrar pacote de tarifas
  PROCEDURE pc_incluir_pct_tarifa(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao                                 
                                 ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE            --> Codigo do Pacote
                                 ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE            --> Descricao do Pacote
                                 ,pr_tppessoa IN tbtarif_pacotes.tppessoa%TYPE            --> Tipo de Pessoa
                                 ,pr_cdtarifa IN tbtarif_pacotes.cdtarifa_lancamento%TYPE --> Codigo da Tarifa
                                 ,pr_dstarifa IN craptar.dstarifa%TYPE                    --> Descricao da Tarifa	
                                 ,pr_strtarif IN VARCHAR2                                 --> String com codigos e valores das tarifas que compoe o pacote
                                 ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                                --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);                              --> Saida OK/NOK

  -- Rotina para consultar dados gerais do pacote de tarifas
  PROCEDURE pc_consulta_inf_pacote(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao                                 
                                  ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE            --> Codigo do Pacote
                                  ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2                                --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2);                              --> Saida OK/NOK

  -- Rotina para validar e desativar pacote de tarifas
  PROCEDURE pc_desativa_pacote(pr_cddopcao IN VARCHAR2                      --> Código da Opcao                                 
                              ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote
                              ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);                   --> Saida OK/NOK
    
END TELA_PACTAR;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PACTAR AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_PACTAR
  --    Autor   : Jean Michel
  --    Data    : Marco/2016                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela PACTAR (Ayllos Web)
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_consulta_codigo(pr_cddopcao IN VARCHAR2           --> Código da Opcao
                              ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2          --> Descriçao da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS      --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_consulta_codigo
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar proximo codigo para cadastro de dados de Gestao de Garantias
    
    Alteracoes: 
    ............................................................................. */
      
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes IS
      SELECT MAX(tar.cdpacote) AS cdpacote
        FROM tbtarif_pacotes tar;

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE;  
  
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    -- Diversas
    vr_cdpacote tbtarif_pacotes.cdpacote%TYPE := 0; 
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
    
    -- Consulta codigo na tabela para se certificar que codigo e valido e nao havera registro duplicado
    OPEN cr_tbtarif_pacotes();

    FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;

    -- Verifica se encontrou registros com o codigo informado
    IF cr_tbtarif_pacotes%NOTFOUND THEN
      CLOSE cr_tbtarif_pacotes;
      vr_cdpacote := 1;          
    ELSE
      CLOSE cr_tbtarif_pacotes;
      vr_cdpacote := NVL(rw_tbtarif_pacotes.cdpacote,0) + 1;
    END IF;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdpacote', pr_tag_cont => TO_CHAR(vr_cdpacote), pr_des_erro => vr_dscritic);
  
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
      pr_des_erro := 'NOK';
    
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PACTAR.PC_CONSULTA_CODIGO --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_consulta_codigo;

  PROCEDURE pc_valida_pacote_tarifa(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao
                                   ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE            --> Codigo do Pacote
                                   ,pr_tppessoa IN tbtarif_pacotes.tppessoa%TYPE            --> Tipo de Pessoa
                                   ,pr_cdtarifa IN tbtarif_pacotes.cdtarifa_lancamento%TYPE --> Codigo da Tarifa
                                   ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE            --> Descricao do Pacote
                                   ,pr_dstarifa IN VARCHAR2                                 --> Descriçao da Tarifa    
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE                   --> Codigo de Erro
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS               --> Descricao de Erro

    /* .............................................................................
    Programa: pc_valida_pacote_tarifa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar a inclusao de pacotes de tarifas
    
    Alteracoes: 
    ............................................................................. */
        
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
      SELECT tar.cdpacote
        FROM tbtarif_pacotes tar
       WHERE tar.cdpacote = pr_cdpacote;

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE;   
      
    CURSOR cr_craptar(pr_cdtarifa craptar.cdtarifa%TYPE
                     ,pr_inpessoa craptar.inpessoa%TYPE) IS
      SELECT tar.cdtarifa
            ,tar.dstarifa
        FROM craptar tar
       WHERE tar.cdtarifa = pr_cdtarifa
        -- AND tar.flutlpct = 1
         AND tar.inpessoa = pr_inpessoa;

    rw_craptar cr_craptar%ROWTYPE; 
    
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
      
    IF pr_cddopcao = 'I' THEN

      -- Valida codigo do pacote a ser inserido
      IF NVL(pr_cdpacote,0) <= 0 THEN
        vr_dscritic := 'Código do pacote de tarifas informado é inválido.';
      ELSE
        -- Consulta codigo na tabela para se certificar que codigo e valido e nao havera registro duplicado
        OPEN cr_tbtarif_pacotes(pr_cdpacote => pr_cdpacote);

        FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;

        -- Verifica se encontrou registros com o codigo informado
        IF cr_tbtarif_pacotes%NOTFOUND THEN
          CLOSE cr_tbtarif_pacotes;          
        ELSE
          -- Caso tenha encontrado algum registro, retorna critica
          CLOSE cr_tbtarif_pacotes;
          vr_dscritic := 'Código de pacote de tarifas já cadastrado.';
          RAISE vr_exc_erro;
        END IF;
      
      END IF; 

      -- Valida tipo de pessoa (1-Fisica / 2-Juridica)
      IF pr_tppessoa NOT IN (1,2) THEN
        vr_dscritic := 'Tipo de pessoa informado inválido.';
      END IF; 

      -- Valida codigo da tarifa
      IF NVL(pr_cdtarifa,0) > 0 THEN
        -- Verifica se codigo da tarifa informado e valido e ainda nao existe
        OPEN cr_craptar(pr_cdtarifa => pr_cdtarifa
                       ,pr_inpessoa => pr_tppessoa);

        FETCH cr_craptar INTO rw_craptar;

        IF cr_craptar%NOTFOUND THEN
          CLOSE cr_craptar;
          vr_dscritic := 'Tarifa não cadastrada ou não permitida para o tipo de pessoa informado.';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_craptar;
          IF pr_dstarifa <> rw_craptar.dstarifa THEN
            vr_dscritic := 'Descrição da tarifa informada inválida.';
          END IF;
        END IF;               

      ELSE
        vr_dscritic := 'Código da tarifa informada inválido.';
      END IF;

      IF TRIM(pr_dspacote) IS NULL THEN
        vr_dscritic := 'Descrição do pacote de tarifas informada inválida.';
      END IF;      
           
    END IF;
  
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      ROLLBACK;  

    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PACTAR.PC_VALIDA_PACOTE_TARIFA --> ' || SQLERRM;
      
      ROLLBACK;
          
  END pc_valida_pacote_tarifa;

  PROCEDURE pc_val_pct_tarifa_web(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao
                                 ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE            --> Codigo do Pacote
                                 ,pr_tppessoa IN tbtarif_pacotes.tppessoa%TYPE            --> Tipo de Pessoa
                                 ,pr_cdtarifa IN tbtarif_pacotes.cdtarifa_lancamento%TYPE --> Codigo da Tarifa
                                 ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE            --> Descricao do Pacote
                                 ,pr_dstarifa IN VARCHAR2                                 --> Descriçao da Tarifa    
                                 ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                                --> Descriçao da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS                            --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_val_pct_tarifa_web
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar a inclusao de pacotes de tarifas
    
    Alteracoes: 
    ............................................................................. */
        
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
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
    
    TELA_PACTAR.pc_valida_pacote_tarifa(pr_cddopcao => pr_cddopcao   --> Código da Opcao
                                       ,pr_cdpacote => pr_cdpacote   --> Codigo do Pacote
                                       ,pr_tppessoa => pr_tppessoa   --> Tipo de Pessoa
                                       ,pr_cdtarifa => pr_cdtarifa   --> Codigo da Tarifa
                                       ,pr_dspacote => pr_dspacote   --> Descricao do Pacote
                                       ,pr_dstarifa => pr_dstarifa   --> Descriçao da Tarifa    
                                       ,pr_cdcritic => vr_cdcritic   --> Codigo de Erro
                                       ,pr_dscritic => vr_dscritic); --> Descricao de Erro
                                       
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
       
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
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
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PACTAR.PC_VAL_PCT_TARIFA_WEB --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_val_pct_tarifa_web;

  PROCEDURE pc_consulta_tarifa(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao                                 
                              ,pr_tppessoa IN tbtarif_pacotes.tppessoa%TYPE            --> Tipo de Pessoa
                              ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                                --> Descriçao da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS                            --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_consulta_tarifa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar tarifas
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_craptar(pr_inpessoa craptar.inpessoa%TYPE) IS
      SELECT tar.cdtarifa
            ,tar.dstarifa
        FROM craptar tar
       WHERE tar.flutlpct = 1
         AND tar.inpessoa = pr_inpessoa;

    rw_craptar cr_craptar%ROWTYPE; 
 
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    -- Gerais
    vr_auxconta INTEGER := 0;
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
        
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Para cada registro de tarifa
	  FOR rw_craptar IN cr_craptar(pr_inpessoa => pr_tppessoa) LOOP

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdtarifa', pr_tag_cont => TO_CHAR(rw_craptar.cdtarifa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dstarifa', pr_tag_cont => TO_CHAR(rw_craptar.dstarifa), pr_des_erro => vr_dscritic);

      -- Incrementa contador p/ posicao no XML
      vr_auxconta := vr_auxconta + 1;
    END LOOP;
   
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
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
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PACTAR.PC_CONSULTA_TARIFA --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_consulta_tarifa;

  PROCEDURE pc_consulta_pacote_tarifa(pr_cddopcao         IN VARCHAR2           --> Código da Opcao
                                     ,pr_cdpacote         IN tbtarif_pacotes.cdpacote%TYPE       --> Código do Pacote de Tarifas
                                     ,pr_dspacote         IN tbtarif_pacotes.dspacote%TYPE       --> Descricao do Pacote de Tarifas
                                     ,pr_nrregist         IN NUMBER                              --> Numero de Registros Exibidos
                                     ,pr_nrinireg         IN NUMBER                              --> Registro Inicial
                                     ,pr_qtregist        OUT NUMBER                              --> Quantidade de Registros
                                     ,pr_tbtarif_pacotes OUT TELA_PACTAR.typ_tab_tbtarif_pacotes --> Tabela com os dados de pacotes
                                     ,pr_cdcritic        OUT crapcri.cdcritic%TYPE               --> Código da crítica
                                     ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS           --> Descriçao da crítica

    /* .............................................................................
    Programa: pc_consulta_pacote_tarifa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina geral para consulta de pacotes de tarifas
    
    Alteracoes: 
    ............................................................................. */
        
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cddopcao VARCHAR2
                             ,pr_cdpacote tbtarif_pacotes.cdpacote%TYPE
                             ,pr_dspacote tbtarif_pacotes.dspacote%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tar.cdtarifa_lancamento
            ,tar.flgsituacao
            ,TRUNC(tar.dtmvtolt) AS dtmvtolt      
            ,TRUNC(tar.dtcancelamento) AS dtcancelamento
            ,tar.tppessoa
            ,decode(tar.tppessoa,1,'PESSOA FISICA',2,'PESSOA JURIDICA',3,'ADMINISTRATIVA','N.A') AS dspessoa
            ,tari.dstarifa AS dstarifa  
            ,COUNT(tar.cdpacote)   
               OVER() AS contador     
        FROM tbtarif_pacotes tar,
             craptar tari
       WHERE (tar.cdpacote = pr_cdpacote OR pr_cdpacote = 0)
         AND (UPPER(tar.dspacote) LIKE UPPER('%' || pr_dspacote || '%') OR TRIM(pr_dspacote) IS NULL)
         AND ((pr_cddopcao IN('D','H') AND tar.flgsituacao = 1) OR pr_cddopcao = 'C')
         AND tar.cdtarifa_lancamento = tari.cdtarifa
    ORDER BY tar.tppessoa, tar.cdpacote;

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE;
        
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    vr_tbtarif_pacotes TELA_PACTAR.typ_tab_tbtarif_pacotes;
    vr_ind_pacotes NUMBER(10);
    
    vr_nrregist NUMBER(10) := 0;
    vr_nrinireg NUMBER(10) := 0;

  BEGIN

    vr_tbtarif_pacotes.DELETE();

    OPEN cr_tbtarif_pacotes(pr_cddopcao => pr_cddopcao        --> Codigo da Opcao em Tela
                           ,pr_cdpacote => NVL(pr_cdpacote,0) --> Código do Pacote
                           ,pr_dspacote => pr_dspacote);      --> Descricao do Pacote

      LOOP

        FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;

        pr_qtregist := rw_tbtarif_pacotes.contador;
        vr_nrregist := NVL(vr_nrregist,0) + 1;

        EXIT WHEN cr_tbtarif_pacotes%NOTFOUND;

        -- Buscar qual a quantidade atual de registros no vetor para posicionar na próxima
        vr_ind_pacotes := vr_tbtarif_pacotes.COUNT() + 1;

        IF pr_nrinireg <= vr_nrregist AND vr_nrregist <= (pr_nrregist + pr_nrinireg) THEN
          -- Criar um registro no vetor de extratos a enviar
          vr_tbtarif_pacotes(vr_ind_pacotes).cdpacote            := rw_tbtarif_pacotes.cdpacote;
          vr_tbtarif_pacotes(vr_ind_pacotes).dspacote            := rw_tbtarif_pacotes.dspacote;
          vr_tbtarif_pacotes(vr_ind_pacotes).cdtarifa_lancamento := rw_tbtarif_pacotes.cdtarifa_lancamento;
          vr_tbtarif_pacotes(vr_ind_pacotes).dstarifa            := SUBSTR(rw_tbtarif_pacotes.dstarifa,0,50);
          vr_tbtarif_pacotes(vr_ind_pacotes).flgsituacao         := rw_tbtarif_pacotes.flgsituacao;
          vr_tbtarif_pacotes(vr_ind_pacotes).dtmvtolt            := NVL(rw_tbtarif_pacotes.dtmvtolt,TO_DATE('01/01/1900','dd/mm/RRRR'));
          vr_tbtarif_pacotes(vr_ind_pacotes).dtcancelamento      := NVL(rw_tbtarif_pacotes.dtcancelamento,TO_DATE('01/01/1900','dd/mm/RRRR'));
          vr_tbtarif_pacotes(vr_ind_pacotes).tppessoa            := rw_tbtarif_pacotes.tppessoa;
          vr_tbtarif_pacotes(vr_ind_pacotes).dspessoa            := rw_tbtarif_pacotes.dspessoa;
          vr_tbtarif_pacotes(vr_ind_pacotes).cddopcao            := pr_cddopcao;

        END IF;
        
      END LOOP;

      CLOSE cr_tbtarif_pacotes;

      pr_tbtarif_pacotes := vr_tbtarif_pacotes;

  EXCEPTION
    WHEN vr_exc_erro THEN
      
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      ROLLBACK;  

    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PACTAR.PC_CONSULTA_PACOTE_TARIFA --> ' || SQLERRM;
      
      ROLLBACK;
          
  END pc_consulta_pacote_tarifa;

  -- Rotina geral para consulta de pacotes de tarifas
  PROCEDURE pc_consulta_pct_tar_car(pr_cddopcao IN VARCHAR2           --> Código da Opcao
                                   ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Código do Pacote de Tarifas
                                   ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE --> Descricao do Pacote de Tarifas
                                   ,pr_nrregist IN NUMBER                        --> Numero de Registros Exibidos
                                   ,pr_nrinireg IN NUMBER                        --> Registro Inicial
                                   ,pr_qtregist OUT NUMBER                       --> Quantidade de Registros
                                   ,pr_clobxmlc OUT CLOB                         --> XML com dos Pacotes de tarifas
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Código da crítica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS    --> Descriçao da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_consult_pct_tar_car
     Sistema : Novos Produtos de Captaçao
     Sigla   : TARI
     Autor   : Jean Michel
     Data    : Marco/16.                    Ultima atualizacao: 08/03/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de pacotes de tarifas.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      vr_tab_tbtarif_pacotes TELA_PACTAR.typ_tab_tbtarif_pacotes;
      vr_xml_temp VARCHAR2(32767);

    BEGIN
      -- Leitura de pacote de tarifas
      TELA_PACTAR.pc_consulta_pacote_tarifa(pr_cddopcao        => pr_cddopcao            --> Código da Opcao
                                           ,pr_cdpacote        => pr_cdpacote            --> Código do Pacote de Tarifas
                                           ,pr_dspacote        => pr_dspacote            --> Descricao do Pacote de Tarifas
                                           ,pr_nrregist        => pr_nrregist            --> Numero de Registros Exibidos
                                           ,pr_nrinireg        => pr_nrinireg            --> Registro Inicial
                                           ,pr_qtregist        => pr_qtregist            --> Quantidade de Registros
                                           ,pr_tbtarif_pacotes => vr_tab_tbtarif_pacotes --> Tabela com os dados de pacotes
                                           ,pr_cdcritic        => pr_cdcritic            --> Código da crítica
                                           ,pr_dscritic        => pr_dscritic);          --> Descriçao da crítica

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_tab_tbtarif_pacotes.count() > 0 THEN
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
        dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       

        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
  			
                               
        -- Percorre todas as aplicações de captaçao da conta											 
        FOR vr_contador IN vr_tab_tbtarif_pacotes.FIRST..vr_tab_tbtarif_pacotes.LAST LOOP
          
          IF NOT vr_tab_tbtarif_pacotes.exists(vr_contador) THEN
            CONTINUE;
          END IF;
         
          -- Montar XML com registros de aplicaçao
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                 ,pr_texto_completo => vr_xml_temp 
                                 ,pr_texto_novo     => '<pacote>'															                    
                                                    ||  '<cdpacote>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).cdpacote),'0') || '</cdpacote>'
                                                    ||  '<dspacote>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dspacote),'0') || '</dspacote>'
                                                    ||  '<cdtarifa_lancamento>' || NVL(vr_tab_tbtarif_pacotes(vr_contador).cdtarifa_lancamento,0) || '</cdtarifa_lancamento>'
                                                    ||  '<flgsituacao>' || NVL(TRIM(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).flgsituacao)),'0') || '</flgsituacao>'
                                                    ||  '<dtmvtolt>' || TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dtmvtolt,'dd/mm/RRRR') || '</dtmvtolt>'                                                    
                                                    ||  '<dtcancelamento>' || TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dtcancelamento,'dd/mm/RRRR') || '</dtcancelamento>'
                                                    ||  '<tppessoa>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).tppessoa),'0') || '</tppessoa>'
                                                    ||  '<dspessoa>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dspessoa),'0') || '</dspessoa>'
                                                    ||  '<cddopcao>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).cddopcao),'0') || '</cddopcao>'
                                                    ||  '<dstarifa>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dstarifa),'0') || '</dstarifa>'
                                                    ||  '<vlpacote>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).vlpacote),'0') || '</vlpacote>'
                                                    || '</pacote>');	

        END LOOP;
  			
        -- Encerrar a tag raiz 
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</root>' 
                               ,pr_fecha_xml      => TRUE);
		  END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Pacotes de Tarifas TELA_PACTAR.PC_CONSULTA_PCT_TAR_CAR: ' || SQLERRM;
    END;

  END pc_consulta_pct_tar_car;

  PROCEDURE pc_consulta_pct_tar_web(pr_cddopcao IN VARCHAR2           --> Código da Opcao
                                   ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Código do Pacote de Tarifas
                                   ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE --> Descricao do Pacote de Tarifas
                                   ,pr_nrregist IN NUMBER                        --> Numero de Registros Exibidos
                                   ,pr_nrinireg IN NUMBER                        --> Registro Inicial
                                   ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                     --> Descriçao da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2) IS                 --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_consult_pct_tar_web
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar tarifas via Ayllos Web
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_craptar(pr_cdtarifa craptar.cdtarifa%TYPE
                     ,pr_inpessoa craptar.inpessoa%TYPE) IS
      SELECT tar.cdtarifa
            ,tar.dstarifa
        FROM craptar tar
       WHERE tar.cdtarifa = pr_cdtarifa
         AND tar.flutlpct = 1
         AND tar.inpessoa = pr_inpessoa;

    rw_craptar cr_craptar%ROWTYPE; 
 
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    -- Gerais
    vr_auxconta INTEGER := 0;
    vr_qtregist INTEGER := 0;

    vr_tab_tbtarif_pacotes TELA_PACTAR.typ_tab_tbtarif_pacotes;

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
    
    -- Leitura de pacote de tarifas
    TELA_PACTAR.pc_consulta_pacote_tarifa(pr_cddopcao        => pr_cddopcao            --> Código da Opcao
                                         ,pr_cdpacote        => pr_cdpacote            --> Código do Pacote de Tarifas
                                         ,pr_dspacote        => pr_dspacote            --> Descricao do Pacote de Tarifas
                                         ,pr_nrregist        => pr_nrregist            --> Numero de Registros Exibidos
                                         ,pr_nrinireg        => pr_nrinireg            --> Registro Inicial
                                         ,pr_qtregist        => vr_qtregist            --> Quantidade de Registros
                                         ,pr_tbtarif_pacotes => vr_tab_tbtarif_pacotes --> Tabela com os dados de pacotes
                                         ,pr_cdcritic        => vr_cdcritic            --> Código da crítica
                                         ,pr_dscritic        => vr_dscritic);          --> Descriçao da crítica

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Para cada registro de tarifa
	  FOR vr_contador IN vr_tab_tbtarif_pacotes.FIRST..vr_tab_tbtarif_pacotes.LAST LOOP
          
      IF NOT vr_tab_tbtarif_pacotes.exists(vr_contador) THEN
        CONTINUE;
      END IF;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdpacote           ', pr_tag_cont => TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).cdpacote           ), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dspacote           ', pr_tag_cont => TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dspacote           ), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdtarifa_lancamento', pr_tag_cont => TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).cdtarifa_lancamento), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'flgsituacao        ', pr_tag_cont => TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).flgsituacao        ), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtmvtolt           ', pr_tag_cont => TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dtmvtolt           ), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtcancelamento     ', pr_tag_cont => TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dtcancelamento     ), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'tppessoa           ', pr_tag_cont => TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).tppessoa           ), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dspessoa           ', pr_tag_cont => TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dspessoa           ), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cddopcao           ', pr_tag_cont => TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).cddopcao           ), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dstarifa           ', pr_tag_cont => TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dstarifa           ), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlpacote           ', pr_tag_cont => TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).vlpacote           ), pr_des_erro => vr_dscritic);
                                                                                
      -- Incrementa contador p/ posicao no XML
      vr_auxconta := vr_auxconta + 1;
    END LOOP;
   
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
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
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PACTAR.PC_CONSULTA_PCT_TAR_WEB --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_consulta_pct_tar_web;

  -- Rotina para consulta de descricao da tariga
  PROCEDURE pc_consulta_desc_tarifa(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao                                 
                                   ,pr_tppessoa IN tbtarif_pacotes.tppessoa%TYPE            --> Tipo de Pessoa
                                   ,pr_cdtarifa IN tbtarif_pacotes.cdtarifa_lancamento%TYPE --> Codigo da Tarifa
                                   ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                                --> Descriçao da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2) IS                            --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_consulta_desc_tarifa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar descricao de tarifas
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_craptar(pr_cdtarifa craptar.cdtarifa%TYPE
                     ,pr_inpessoa craptar.inpessoa%TYPE) IS
      SELECT tar.cdtarifa
            ,tar.dstarifa
        FROM craptar tar
       WHERE /*tar.flutlpct = 1
         AND*/ tar.inpessoa = pr_inpessoa
         AND tar.cdtarifa = pr_cdtarifa;

    rw_craptar cr_craptar%ROWTYPE; 
 
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
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
    
    -- Consulta descricao da tarifa
    OPEN cr_craptar(pr_cdtarifa => pr_cdtarifa
                   ,pr_inpessoa => pr_tppessoa); 
    
    FETCH cr_craptar INTO rw_craptar;

    IF cr_craptar%FOUND THEN
      CLOSE cr_craptar;
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdtarifa', pr_tag_cont => TO_CHAR(rw_craptar.cdtarifa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dstarifa', pr_tag_cont => TO_CHAR(rw_craptar.dstarifa), pr_des_erro => vr_dscritic);
    ELSE
      CLOSE cr_craptar;
      vr_cdcritic := 0;
      vr_dscritic := 'Tarifa não cadastrada ou não permitida para o tipo de pessoa informado.';
      RAISE vr_exc_erro;
    END IF;
     
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
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
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PACTAR.PC_CONSULTA_TARIFA --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_consulta_desc_tarifa;

  -- Rotina para cadastrar pacote de tarifas
  PROCEDURE pc_incluir_pct_tarifa(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao                                 
                                 ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE            --> Codigo do Pacote
                                 ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE            --> Descricao do Pacote
                                 ,pr_tppessoa IN tbtarif_pacotes.tppessoa%TYPE            --> Tipo de Pessoa
                                 ,pr_cdtarifa IN tbtarif_pacotes.cdtarifa_lancamento%TYPE --> Codigo da Tarifa
                                 ,pr_dstarifa IN craptar.dstarifa%TYPE                    --> Descricao da Tarifa	
                                 ,pr_strtarif IN VARCHAR2                                 --> String com codigos e valores das tarifas que compoe o pacote
                                 ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                                --> Descriçao da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS                            --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_incluir_pct_tarifa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para cadastrar pacotes de tarifas
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
      SELECT tar.cdpacote
        FROM tbtarif_pacotes tar
       WHERE tar.cdpacote = pr_cdpacote;

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE; 
 
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;

    -- Gerais
    vr_cdpacote INTEGER := 0;

    vr_tarifa_geral GENE0002.typ_split;
    vr_tarifa_dados GENE0002.typ_split;
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
      
    -- Efetua validacao do pacote de tarifa
    pc_valida_pacote_tarifa(pr_cddopcao => pr_cddopcao   --> Código da Opcao
                           ,pr_cdpacote => pr_cdpacote   --> Codigo do Pacote
                           ,pr_tppessoa => pr_tppessoa   --> Tipo de Pessoa
                           ,pr_cdtarifa => pr_cdtarifa   --> Codigo da Tarifa
                           ,pr_dspacote => pr_dspacote   --> Descricao do Pacote
                           ,pr_dstarifa => pr_dstarifa   --> Descriçao da Tarifa    
                           ,pr_cdcritic => vr_cdcritic   --> Codigo de Erro
                           ,pr_dscritic => vr_dscritic); --> Descricao de Erro

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
   
    vr_cdpacote := NVL(pr_cdpacote,0);

    LOOP
      -- Consulta codigo na tabela para se certificar que codigo e valido e nao havera registro duplicado
      OPEN cr_tbtarif_pacotes(pr_cdpacote => vr_cdpacote);

      FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;

      -- Verifica se encontrou registros com o codigo informado
      IF cr_tbtarif_pacotes%NOTFOUND THEN
        CLOSE cr_tbtarif_pacotes;
        EXIT;   
      ELSE
        -- Caso tenha encontrado algum registro, incrementa valor
        CLOSE cr_tbtarif_pacotes;
        vr_cdpacote := NVL(vr_cdpacote,0) + 1;
        CONTINUE;
      END IF;
    END LOOP;

    BEGIN
      INSERT INTO tbtarif_pacotes(
        cdpacote,dspacote,cdtarifa_lancamento,flgsituacao,dtmvtolt,tppessoa)
      VALUES(
        vr_cdpacote,UPPER(pr_dspacote),pr_cdtarifa,1,SYSDATE,pr_tppessoa);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao inserir pacote de tarifas. Erro: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

    vr_tarifa_geral := gene0002.fn_quebra_string(pr_string => pr_strtarif,pr_delimit => '|');    

    FOR ind_registro IN vr_tarifa_geral.FIRST..vr_tarifa_geral.LAST LOOP
      
      vr_tarifa_dados := gene0002.fn_quebra_string(pr_string => vr_tarifa_geral(ind_registro),pr_delimit => '#');
      
      BEGIN
        INSERT INTO tbtarif_servicos(cdpacote, cdtarifa, qtdoperacoes)
          VALUES(vr_cdpacote,TO_NUMBER(vr_tarifa_dados(1)),TO_NUMBER(vr_tarifa_dados(2)));
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir registro de pacote de tarifas, Tarifa: ' || TO_CHAR(pr_strtarif) || ' . Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
    END LOOP;    

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
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
    
      ROLLBACK;
    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PACTAR.PC_INCLUIR_PCT_TARIFA --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;

  END pc_incluir_pct_tarifa;

  -- Rotina para consultar dados gerais do pacote de tarifas
  PROCEDURE pc_consulta_inf_pacote(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao                                 
                                  ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE            --> Codigo do Pacote
                                  ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2                                --> Descriçao da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2) IS                            --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_consulta_inf_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar informacoes dos pacotes de tarifas
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE
                             ,pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tar.cdtarifa_lancamento
            ,tari.dstarifa
            ,tar.flgsituacao
            ,tar.dtmvtolt
            ,tar.dtcancelamento
            ,tar.tppessoa
            ,fco.vltarifa AS vlpacote
        FROM tbtarif_pacotes tar,
             craptar tari,
             crapfvl fvl,
             crapfco fco
       WHERE tar.cdpacote = pr_cdpacote
         AND tar.cdtarifa_lancamento = tari.cdtarifa
         AND fvl.cdtarifa = tar.cdtarifa_lancamento
         AND fco.cdfaixav = fvl.cdfaixav
         AND (fco.cdcooper = pr_cdcooper OR pr_cdcooper = 3);

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE; 

    CURSOR cr_crapfvl(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
      SELECT count(fvl.cdtarifa) AS contador
        FROM tbtarif_pacotes tar,
             crapfvl fvl
       WHERE tar.cdpacote = pr_cdpacote
         AND fvl.cdtarifa = tar.cdtarifa_lancamento
     UNION
       SELECT tbtarif_pacotes.cdtarifa_lancamento
         FROM tbtarif_pacotes 
        WHERE tbtarif_pacotes.cdpacote = pr_cdpacote;

    rw_crapfvl cr_crapfvl%ROWTYPE; 
 
    CURSOR cr_tbtarif_servicos(pr_cdpacote tbtarif_servicos.cdpacote%TYPE) IS
      SELECT ser.cdpacote
            ,ser.cdtarifa
            ,tar.dstarifa
            ,ser.qtdoperacoes 
        FROM tbtarif_servicos ser,
             craptar tar
       WHERE ser.cdpacote = pr_cdpacote
         AND ser.cdtarifa = tar.cdtarifa;

    rw_tbtarif_servicos cr_tbtarif_servicos%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    -- Gerais
    vr_auxconta INTEGER := 0;
    vr_vlpacote NUMBER;
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
    
    -- Consulta codigo na tabela para se certificar que codigo e valido e nao havera registro duplicado
    OPEN cr_tbtarif_pacotes(pr_cdpacote => pr_cdpacote
                           ,pr_cdcooper => vr_cdcooper);

    FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;

    -- Verifica se encontrou registros com o codigo informado
    IF cr_tbtarif_pacotes%NOTFOUND THEN
      CLOSE cr_tbtarif_pacotes;
      vr_dscritic := 'Pacote de tarifas não cadastrado.'; 
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_tbtarif_pacotes;
      IF rw_tbtarif_pacotes.flgsituacao = 0 AND (pr_cddopcao IN('D','H')) THEN
        vr_dscritic := 'Pacote de tarifas não encontrado.';
        --vr_dscritic := 'Pacote de tarifas já esta cancelado.'; 
        RAISE vr_exc_erro;
      END IF;      
    END IF;

    -- Verifica faixas de valores do pacote
    OPEN cr_crapfvl(pr_cdpacote => pr_cdpacote);

    FETCH cr_crapfvl INTO rw_crapfvl;

    IF cr_crapfvl%NOTFOUND THEN
      -- Fecha cursor
      CLOSE cr_crapfvl;
      FETCH cr_crapfvl INTO rw_crapfvl;
      vr_dscritic := 'Não foi possível obter o valor da tarifa ' || rw_crapfvl.contador ||'. Verifique as faixas de valores';
      RAISE vr_exc_erro;
    ELSE
      -- Fecha cursor
      CLOSE cr_crapfvl;
      IF rw_crapfvl.contador > 1 OR
         rw_crapfvl.contador = 0 THEN
         vr_dscritic := 'Não foi possível obter o valor da tarifa ' || rw_crapfvl.contador ||'. Verifique as faixas de valores';
         RAISE vr_exc_erro;
      END IF;      
    END IF;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Informacoes de cabecalho de pacote
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdpacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.cdpacote), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dspacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.dspacote), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdtarifa', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.cdtarifa_lancamento), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dstarifa', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.dstarifa), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'flgsitua', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.flgsituacao), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.dtmvtolt,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dtcancel', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.dtcancelamento,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'tppessoa', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.tppessoa), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'vlpacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.vlpacote,'999g990d00'), pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'tar', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    
    -- Para cada registro de tarifa
	  FOR rw_tbtarif_servicos IN cr_tbtarif_servicos(pr_cdpacote => pr_cdpacote) LOOP
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tar', pr_posicao => 0     , pr_tag_nova => 'tarifa', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tarifa', pr_posicao => vr_auxconta, pr_tag_nova => 'cdtarifa', pr_tag_cont => TO_CHAR(rw_tbtarif_servicos.cdtarifa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tarifa', pr_posicao => vr_auxconta, pr_tag_nova => 'dstarifa', pr_tag_cont => TO_CHAR(rw_tbtarif_servicos.dstarifa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tarifa', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdopera', pr_tag_cont => TO_CHAR(rw_tbtarif_servicos.qtdoperacoes), pr_des_erro => vr_dscritic);

      -- Incrementa contador p/ posicao no XML
      vr_auxconta := vr_auxconta + 1;
    END LOOP;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtd', pr_tag_cont => TO_CHAR(vr_auxconta), pr_des_erro => vr_dscritic);

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
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
    
      ROLLBACK;
    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PACTAR.PC_CONSULTA_INF_PACOTE --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;

  END pc_consulta_inf_pacote;

  -- Rotina para validar e desativar pacote de tarifas
  PROCEDURE pc_desativa_pacote(pr_cddopcao IN VARCHAR2                      --> Código da Opcao                                 
                              ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote
                              ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                     --> Descriçao da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS                 --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_desativa_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar e desativar pacote de tarifas
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tar.cdtarifa_lancamento
            ,tar.flgsituacao
            ,tar.dtmvtolt
            ,tar.dtcancelamento
            ,tar.tppessoa 
        FROM tbtarif_pacotes tar
       WHERE tar.cdpacote = pr_cdpacote;

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE; 
 
    CURSOR cr_tbtarif_pacotes_coop(pr_cdpacote tbtarif_pacotes_coop.cdpacote%TYPE) IS 
      SELECT 
        t.*
        FROM tbtarif_pacotes_coop t
       WHERE t.cdpacote = pr_cdpacote
         AND t.flgsituacao = 1;

    rw_tbtarif_pacotes_coop cr_tbtarif_pacotes_coop%ROWTYPE;     

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
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
    
    -- Verifica se Pacote de Tarifas é valido
    OPEN cr_tbtarif_pacotes(pr_cdpacote => pr_cdpacote); -- Codigo do Pacote

    FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;

    IF cr_tbtarif_pacotes%NOTFOUND THEN
      CLOSE cr_tbtarif_pacotes;
      vr_dscritic := 'Pacote de tarifas não encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_tbtarif_pacotes;
    END IF;    

    IF rw_tbtarif_pacotes.flgsituacao = 0 THEN
      vr_dscritic := 'Pacote de tarifas já esta cancelado.';
      RAISE vr_exc_erro;
    END IF;

    -- Consulta pacotes nas cooperativas
    OPEN cr_tbtarif_pacotes_coop(pr_cdpacote => pr_cdpacote);

    FETCH cr_tbtarif_pacotes_coop INTO rw_tbtarif_pacotes_coop;

    IF cr_tbtarif_pacotes_coop%FOUND THEN
      CLOSE cr_tbtarif_pacotes_coop;
      vr_dscritic := 'Operação não efetuada! Pacote de tarifas encontra-se Ativo na(s) singular(es).';
      pr_nmdcampo := 'SINGULAR';      
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_tbtarif_pacotes_coop;
    END IF;
    
    -- Desativa pacote de tarifas
    IF pr_cddopcao = 'D' THEN
      BEGIN
        UPDATE 
          tbtarif_pacotes
        SET
          tbtarif_pacotes.flgsituacao = 0,
          tbtarif_pacotes.dtcancelamento = SYSDATE
        WHERE 
          tbtarif_pacotes.cdpacote = pr_cdpacote;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao desativar pacote de tarifas. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;       
      END;
    END IF;

    pr_des_erro := 'OK';

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
    
      ROLLBACK;
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PACTAR.PC_DESATIVA_PACOTE --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;

  END pc_desativa_pacote;

END TELA_PACTAR;
/
