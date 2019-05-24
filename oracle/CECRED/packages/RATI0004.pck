CREATE OR REPLACE PACKAGE CECRED.RATI0004 IS

   ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RATI0004                     Antiga:
  --  Sistema  : Rotinas para Rating dos Produtos
  --  Sigla    : RATI
  --  Autor    : Anderson Luiz Heckmann - AMcom
  --  Data     : Mar�o/2019.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para comunica��o com o WebService para enviar e retornar o Rating dos Produtos.
  --
  -- Alteracao:
  --
  ---------------------------------------------------------------------------------------------------------------

  --> Rotina responsavel por enviar o contrato para o motor afim de obter o Rating
  PROCEDURE pc_enviar_analise_rating(pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_cdagenci    IN crapage.cdagenci%TYPE  --> Codigo da agencia                                          
                                    ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> codigo do operador
                                    ,pr_cdorigem    IN INTEGER                --> Origem da operacao
                                    ,pr_nrdconta    IN PLS_INTEGER            --> Numero da conta do cooperado
                                    ,pr_nrctrato    IN PLS_INTEGER            --> Numero do Contrato
                                    ,pr_tpctrato    IN PLS_INTEGER DEFAULT 0  --> Tipo do contrato de rating
                                    ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE  --> Data do movimento                                      
                                    ,pr_comprecu    IN VARCHAR2               --> Complemento do recuros da URI
                                    ,pr_dsmetodo    IN VARCHAR2               --> Descricao do metodo
                                    ,pr_conteudo    IN CLOB                   --> Conteudo no Json para comunicacao
                                    ,pr_dsoperacao  IN VARCHAR2               --> Operacao realizada
                                    ,pr_tpenvest    IN VARCHAR2 DEFAULT NULL  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                                    ,pr_dsprotocolo OUT VARCHAR2              --> Protocolo retornado na requisi�ao
                                    ,pr_dscritic    OUT VARCHAR2              --> Descritivo do erro
                                    );
                                    
  --> Rotina para solicitar analises nao respondidas via POST ou solicitar a proposta enviada
  PROCEDURE pc_solicita_retorno(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                               ,pr_nrdconta IN PLS_INTEGER             --> Numero da conta do cooperado
                               ,pr_nrctrato IN PLS_INTEGER             --> Numero do contrato
                               ,pr_tpctrato IN PLS_INTEGER DEFAULT 0   --> Tipo do contrato de rating
                               ,pr_dsprotoc IN VARCHAR2                --> Protocolo retornado na requisi�ao
                               ,pr_strating IN tbrisco_operacoes.insituacao_rating%TYPE DEFAULT NULL  --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada no processo
                               ,pr_dscritic OUT VARCHAR2               --> Descritivo do erro
                               );

  --> Gravar a analise do Rating a partir do retorno do Motor                             
  PROCEDURE pc_busca_rating_motor(pr_cdcooper              IN tbrisco_operacoes.cdcooper%TYPE                    --> Codigo da cooperativa 
                                 ,pr_nrdconta              IN tbrisco_operacoes.nrdconta%TYPE                    --> Numero da proposta de limite
                                 ,pr_nrctrato              IN tbrisco_operacoes.nrctremp%TYPE                    --> Numero da Proposta
                                 ,pr_tpctrato              IN tbrisco_operacoes.tpctrato%TYPE                    --> Tipo da proposta de limite
                                 ,pr_dtmvtolt              IN crapdat.dtmvtolt%TYPE                              --> Data do movimento
                                 ,pr_dsconteudo_requisicao IN tbgen_webservice_aciona.dsconteudo_requisicao%TYPE --> Conteudo da requiscao
                                 ,pr_cdcritic             OUT NUMBER                                             --> C�digo da Cr�tica
                                 ,pr_dscritic             OUT VARCHAR2);                                         --> Descritivo do erro

END RATI0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RATI0004 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RATI0004                     Antiga:
  --  Sistema  : Rotinas para Rating dos Produtos
  --  Sigla    : RATI
  --  Autor    : Anderson Luiz Heckmann - AMcom
  --  Data     : Mar�o/2019.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para comunica��o com o WebService para enviar e retornar o Rating dos Produtos.
  --
  -- Alteracao:
  --
  ---------------------------------------------------------------------------------------------------------------

  --> Rotina responsavel por enviar o contrato para o motor afim de obter o Rating
  PROCEDURE pc_enviar_analise_rating(pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_cdagenci    IN crapage.cdagenci%TYPE  --> Codigo da agencia                                          
                                    ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> codigo do operador
                                    ,pr_cdorigem    IN INTEGER                --> Origem da operacao
                                    ,pr_nrdconta    IN PLS_INTEGER            --> Numero da conta do cooperado
                                    ,pr_nrctrato    IN PLS_INTEGER            --> Numero do contrato
                                    ,pr_tpctrato    IN PLS_INTEGER DEFAULT 0  --> Tipo do contrato de rating
                                    ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE  --> Data do movimento                                      
                                    ,pr_comprecu    IN VARCHAR2               --> Complemento do recuros da URI
                                    ,pr_dsmetodo    IN VARCHAR2               --> Descricao do metodo
                                    ,pr_conteudo    IN CLOB                   --> Conteudo no Json para comunicacao
                                    ,pr_dsoperacao  IN VARCHAR2               --> Operacao realizada
                                    ,pr_tpenvest    IN VARCHAR2 DEFAULT NULL  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                                    ,pr_dsprotocolo OUT VARCHAR2              --> Protocolo retornado na requisi�ao
                                    ,pr_dscritic    OUT VARCHAR2              --> Descritivo do erro
                                    ) IS                                             
    /* ..........................................................................

    Programa: pc_enviar_analise_rating
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Anderson Luiz Heckmann (AMcom)
    Data    : Mar�o/2019.                          Ultima Atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que chamado.
    Objetivo  : Rotina responsavel por enviar o contrato para o motor afim de obter o Rating.

    Alteracoes:

    ............................................................................. */
    
    -- Parametros
    vr_host_esteira  VARCHAR2(4000);
    vr_recurso_este  VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_autori_este   VARCHAR2(500);
    vr_chave_aplica  VARCHAR2(500);
    
    vr_dscritic      VARCHAR2(4000);
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;
    
    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;
    
    vr_idacionamento  tbgen_webservice_aciona.idacionamento%TYPE;
            
    vr_tab_split     gene0002.typ_split;
    vr_idx_split     VARCHAR2(1000);
    
  BEGIN
    
    -- Carregar parametros para a comunicacao com o motor/esteira
    este0001.pc_busca_param_ibra(pr_cdcooper     => pr_cdcooper
                                ,pr_tpenvest     => pr_tpenvest
                                ,pr_host_esteira => vr_host_esteira
                                ,pr_recurso_este => vr_recurso_este
                                ,pr_dsdirlog     => vr_dsdirlog
                                ,pr_autori_este  => vr_autori_este
                                ,pr_chave_aplica => vr_chave_aplica
                                ,pr_dscritic     => vr_dscritic);
    
    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    -- Atribuir valores necessarios para comunicacao
    vr_request.service_uri := vr_host_esteira;
    vr_request.api_route := vr_recurso_este||pr_comprecu;
    vr_request.method    := pr_dsmetodo;
    vr_request.timeout   := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
    
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('Authorization') := vr_autori_este;
    
    -- Se houver ApplicationKey
    IF vr_chave_aplica IS NOT NULL THEN 
      vr_request.headers('ApplicationKey') := vr_chave_aplica;
    END IF;
    
    -- Para envio do Motor
    IF pr_tpenvest = 'M' THEN
      -- Incluiremos o Reply-To para devolu�ao da An�lise
      vr_request.headers('Reply-To') := gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_MOTOR_DEVOLUC');
    END IF;
    
        
    vr_request.content := pr_conteudo;
    
    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'-- Este formato � o formato que deve ser passado, conforme alinhado com o Oscar
                               ,pr_dscritic          => vr_dscritic); 
                               
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
            
    --> Gravar dados log acionamento
    ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper         
                                 ,pr_cdagenci              => pr_cdagenci          
                                 ,pr_cdoperad              => pr_cdoperad          
                                 ,pr_cdorigem              => pr_cdorigem          
                                 ,pr_nrctrprp              => pr_nrctrato          
                                 ,pr_nrdconta              => pr_nrdconta          
                                 ,pr_tpacionamento         => 1  /* 1 - Envio, 2 � Retorno */      
                                 ,pr_dsoperacao            => pr_dsoperacao       
                                 ,pr_dsuriservico          => vr_host_esteira||vr_recurso_este||pr_comprecu
                                 ,pr_dtmvtolt              => pr_dtmvtolt       
                                 ,pr_cdstatus_http         => vr_response.status_code
                                 ,pr_dsconteudo_requisicao => pr_conteudo
                                 ,pr_dsresposta_requisicao => '{"StatusMessage":"'||vr_response.status_message||'"'||CHR(13)||
                                                              ',"Headers":"'||RTRIM(LTRIM(vr_response.headers,'""'),'""')||'"'||CHR(13)||
                                                              ',"Content":'||vr_response.content||'}'
                                 ,pr_tpproduto             => RATI0003.fn_conv_tpctrato_tpproduto(pr_tpctrato => pr_tpctrato)
                                 ,pr_idacionamento         => vr_idacionamento
                                 ,pr_dscritic              => vr_dscritic);
                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      -- Definir mensagem de critica
      CASE 
        WHEN pr_dsmetodo = 'POST' THEN
          vr_dscritic_aux := 'Nao foi possivel enviar o contrato para An�lise de Rating.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu IS NULL THEN   
          vr_dscritic_aux := 'Nao foi possivel reenviar o contrato para An�lise de Rating.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/numeroProposta' THEN   
          vr_dscritic_aux := 'Nao foi possivel alterar numero da proposta da An�lise de Rating.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/cancelar' THEN   
          vr_dscritic_aux := 'Nao foi possivel excluir o contrato da An�lise de Rating.';   
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/efetivar' THEN   
          vr_dscritic_aux := 'Nao foi possivel enviar a efetivacao do contrato da An�lise de Rating.';
        WHEN pr_dsmetodo = 'GET' THEN   
          vr_dscritic_aux := 'Nao foi possivel solicitar o retorno da An�lise Autom�tica de Rating.';
        ELSE
          vr_dscritic_aux := 'Nao foi possivel enviar informacoes para An�lise de Rating.';  
      END CASE;

      IF vr_response.status_code = 400 THEN
        pr_dscritic := este0001.fn_retorna_critica('{"Content":'||vr_response.content||'}');
        
        IF pr_dscritic IS NOT NULL THEN
          -- Tratar mensagem espec�fica de Fluxo Atacado:
          -- "Nao sera possivel enviar o contrato para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa"
          IF pr_dscritic != 'Nao sera possivel enviar a proposta para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa' THEN 
            -- Mensagens diferentes dela terao o prefixo, somente ela nao ter�
            pr_dscritic := vr_dscritic_aux||' '||pr_dscritic;            
          END IF;  
        ELSE
          pr_dscritic := vr_dscritic_aux;            
        END IF;
        
      ELSE  
        pr_dscritic := vr_dscritic_aux;    
      END IF;                         
      
    END IF;
            
    IF pr_tpenvest = 'M' AND pr_dsmetodo = 'POST' THEN
      -- Transformar texto em objeto json
      BEGIN
        -- Transformar os Headers em uma lista (\n � o separador)
        vr_tab_split := gene0002.fn_quebra_string(vr_response.headers,'\n');
        vr_idx_split  := vr_tab_split.first;
        -- Iterar sobre todos os headers at� encontrar o protocolo
        WHILE vr_idx_split IS NOT NULL AND pr_dsprotocolo IS NULL LOOP
          -- Testar se � o Location
          IF lower(vr_tab_split(vr_idx_split)) LIKE 'location%' THEN
            -- Extrair o final do atributo, ou seja, o conte�do ap�s a ultima barra
            pr_dsprotocolo := substr(vr_tab_split(vr_idx_split),instr(vr_tab_split(vr_idx_split),'/',-1)+1);
          END IF;        
          -- Buscar proximo header        
          vr_idx_split := vr_tab_split.next(vr_idx_split);    
        END LOOP;
        
        -- Se conseguiu encontrar Protocolo
        IF pr_dsprotocolo IS NOT NULL THEN 
          -- Atualizar acionamento                                                                                                                                                             
          UPDATE tbgen_webservice_aciona
             SET dsprotocolo = pr_dsprotocolo
           WHERE idacionamento = vr_idacionamento;
        ELSE    
          -- Gerar erro 
          vr_dscritic := 'Nao foi possivel retornar Protocolo da An�lise Autom�tica de Rating!';
          RAISE vr_exc_erro;                                                                                                                                     
        END IF;
      EXCEPTION
        WHEN OTHERS THEN   
          vr_dscritic := 'Nao foi possivel retornar Protocolo de An�lise Autom�tica de Rating!';
          RAISE vr_exc_erro;
      END;  
    END IF;
            
  EXCEPTION
    WHEN vr_exc_erro THEN      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel enviar o contrato para a An�lise de Rating: '||SQLERRM;  
  END pc_enviar_analise_rating;
  
  --> Rotina para solicitar analises nao respondidas via POST ou solicitar a proposta enviada
  PROCEDURE pc_solicita_retorno(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                               ,pr_nrdconta IN PLS_INTEGER             --> Numero da conta do cooperado
                               ,pr_nrctrato IN PLS_INTEGER             --> Numero do contrato
                               ,pr_tpctrato IN PLS_INTEGER DEFAULT 0   --> Tipo do contrato de rating
                               ,pr_dsprotoc IN VARCHAR2                --> Protocolo retornado na requisi�ao
                               ,pr_strating IN tbrisco_operacoes.insituacao_rating%TYPE DEFAULT NULL  --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada no processo
                               ,pr_dscritic OUT VARCHAR2) IS           --> Descritivo do erro
  /* .........................................................................
    
  Programa : pc_solicita_retorno
  Sistema  : 
  Sigla    : CRED
  Autor    : Anderson Luiz Heckmann (AMcom)
  Data     : Mar�o/2019                    Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Tem como objetivo solicitar o retorno da analise no Motor
  Altera�ao : 
        
  ..........................................................................*/

  
  --> Tratamento de exce�oes
  vr_exc_erro EXCEPTION; 
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
      
  --> Vari�veis auxiliares
  vr_qtsegund      crapprm.dsvlrprm%TYPE;-- Hora de Envio
  vr_hrenvest      crawepr.hrenvest%TYPE;
  vr_flganlok      BOOLEAN := FALSE;
  vr_dsprotoc      VARCHAR2(1000);
  vr_host_esteira  VARCHAR2(4000);
  vr_recurso_este  VARCHAR2(4000);
  vr_dsdirlog      VARCHAR2(500);
  vr_chave_aplica  VARCHAR2(500);
  vr_autori_este   VARCHAR2(500);
  vr_idacionamento tbgen_webservice_aciona.idacionamento%TYPE;
  vr_dsresana      VARCHAR2(100);
  vr_dssitret      VARCHAR2(100);
  vr_indrisco      VARCHAR2(100);
  vr_nrnotrat      VARCHAR2(100);
  vr_nrgarope      VARCHAR2(100);
  vr_innivel_rating  tbrisco_operacoes.innivel_rating%TYPE;
  vr_desc_nivel_rating  VARCHAR2(100);
      
  --> Objeto json da proposta
  vr_obj_retorno     json := json();
  vr_obj_indicadores json := json();
  vr_request         json0001.typ_http_request;
  vr_response        json0001.typ_http_response;
      
  --> Cursores
  rw_crapdat       btch0001.cr_crapdat%ROWTYPE;
    
  --> Cooperativas com an�lise autom�tica obrigat�ria
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE cdcooper = NVL(pr_cdcooper,cdcooper)
       AND flgativo = 1/*
       AND ((pr_tpctrato = 3 AND GENE0001.FN_PARAM_SISTEMA('CRED',cdcooper,'ANALISE_OBRIG_MOTOR_DESC') = 1)
           OR (pr_tpctrato = 90 AND GENE0001.FN_PARAM_SISTEMA('CRED',cdcooper,'ANALISE_OBRIG_MOTOR_CRED') = 1)
           OR (pr_tpctrato NOT IN (3,90)))*/;
       
  --> Buscar o CPF ou CNPJ base para gravar na tabela de opera��es (tbrisco_operacoes)
  CURSOR cr_crapass IS
    SELECT ass.nrcpfcnpj_base
          ,ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;    
  rw_crapass cr_crapass%ROWTYPE;
       
  -- Busca acionamentos de retorno de solicitacao de sugest�o
  CURSOR cr_sugret(pr_dsprotocolo VARCHAR2) IS
    SELECT idacionamento
          ,dsconteudo_requisicao
      FROM tbgen_webservice_aciona
     WHERE cdcooper = pr_cdcooper
       AND cdoperad = 'MOTOR'
       AND nrdconta = pr_nrdconta
       AND tpacionamento = 2 --> Apenas Retorno
       AND tpproduto = pr_tpctrato
       --AND ((pr_nrctrcrd IS NULL AND nrctrprp IS NULL) OR (nrctrprp = pr_nrctrcrd))
       AND dsprotocolo = pr_dsprotocolo;
  rw_sugret cr_sugret%ROWTYPE;
       
  --> Variaveis para DEBUG
  vr_flgdebug VARCHAR2(100);
  vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
              
  BEGIN
    --> Buscar todas as Coops com obrigatoriedade de An�lise Autom�tica de Rating   
    FOR rw_crapcop IN cr_crapcop LOOP
      
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_cdcritic := 0;
          vr_dscritic := 'Associado nao cadastrado. Conta: ' || pr_nrdconta;
          RAISE vr_exc_erro;
        END IF;
      CLOSE cr_crapass;
      
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      --> Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        --> Montar mensagem de critica
        vr_dscritic:= gene0001.fn_busca_critica(1);
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_erro;
      ELSE
        --> Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;        
      
      --> Desde que nao estejamos com processo em execu�ao ou o dia util
      IF rw_crapdat.inproces = 1 /*AND trunc(SYSDATE) = rw_crapdat.dtmvtolt */ THEN
        
        --> Buscar DEBUG ativo ou nao
        vr_flgdebug := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'DEBUG_MOTOR_IBRA');

        --> Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper         
                                       ,pr_cdagenci              => rw_crapass.cdagenci
                                       ,pr_cdoperad              => '1'          
                                       ,pr_cdorigem              => 5          
                                       ,pr_nrctrprp              => pr_nrctrato          
                                       ,pr_nrdconta              => pr_nrdconta          
                                       ,pr_tpacionamento         => 0  /* 0 - DEBUG */      
                                       ,pr_dsoperacao            => 'INICIO SOLICITA RETORNO'       
                                       ,pr_dsuriservico          => NULL       
                                       ,pr_dtmvtolt              => rw_crapdat.dtmvtolt       
                                       ,pr_cdstatus_http         => 0
                                       ,pr_dsconteudo_requisicao => null
                                       ,pr_dsresposta_requisicao => null
                                       ,pr_tpproduto             => RATI0003.fn_conv_tpctrato_tpproduto(pr_tpctrato => pr_tpctrato)
                                       ,pr_idacionamento         => vr_idaciona
                                       ,pr_dscritic              => vr_dscritic);
          --> Sem tratamento de exce�ao para DEBUG 
        END IF;   
      
        --> Carregar parametros para a comunicacao com a esteira
        este0001.pc_busca_param_ibra(pr_cdcooper      => pr_cdcooper
                                    ,pr_tpenvest      => 'M'
                                    ,pr_host_esteira  => vr_host_esteira     --> Host da esteira
                                    ,pr_recurso_este  => vr_recurso_este     --> URI da esteira
                                    ,pr_dsdirlog      => vr_dsdirlog         --> Diretorio de log dos arquivos 
                                    ,pr_autori_este   => vr_autori_este      --> Authorization 
                                    ,pr_chave_aplica  => vr_chave_aplica     --> Chave de acesso
                                    ,pr_dscritic      => vr_dscritic    );       
        --> Se retornou cr�tica
        IF TRIM(vr_dscritic)  IS NOT NULL THEN
          --> Levantar exce�ao
          RAISE vr_exc_erro;
        END IF; 
                  
        vr_recurso_este := vr_recurso_este||'/instance/'||pr_dsprotoc;

        vr_request.service_uri := vr_host_esteira;
        vr_request.api_route   := vr_recurso_este;
        vr_request.method      := 'GET';
        vr_request.timeout     := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
          
        vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
        vr_request.headers('Authorization') := vr_autori_este;
                  
         -- Incluiremos o Reply-To para devolu�ao da An�lise
        vr_request.headers('Reply-To') := gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_MOTOR_DEVOLUC');
                  
        --> Se houver ApplicationKey
        IF vr_chave_aplica IS NOT NULL THEN 
          vr_request.headers('ApplicationKey') := vr_chave_aplica;
        END IF;
          
        --> Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper         
                                       ,pr_cdagenci              => rw_crapass.cdagenci          
                                       ,pr_cdoperad              => 'MOTOR'          
                                       ,pr_cdorigem              => 5          
                                       ,pr_nrctrprp              => pr_nrctrato          
                                       ,pr_nrdconta              => pr_nrdconta         
                                       ,pr_tpacionamento         => 0  /* 0 - DEBUG */      
                                       ,pr_dsoperacao            => 'ANTES SOLICITA RETORNO'       
                                       ,pr_dsuriservico          => NULL       
                                       ,pr_dtmvtolt              => rw_crapdat.dtmvtolt       
                                       ,pr_cdstatus_http         => 0
                                       ,pr_dsconteudo_requisicao => null
                                       ,pr_dsresposta_requisicao => null
                                       ,pr_tpproduto             => RATI0003.fn_conv_tpctrato_tpproduto(pr_tpctrato => pr_tpctrato)
                                       ,pr_idacionamento         => vr_idaciona
                                       ,pr_dscritic              => vr_dscritic);
          --> Sem tratamento de exce�ao para DEBUG
        END IF;   
         
        vr_hrenvest := to_char(SYSDATE,'sssss');
        
        -- Buscar a quantidade de segundos de espera pela An�lise Autom�tica
        vr_qtsegund := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'TIME_RESP_MOTOR_IBRA'),30);

        IF vr_qtsegund = 0 THEN
          vr_qtsegund := 30;
        END IF;

        -- Efetuar la�o para esperarmos (N) segundos ou o termino da analise recebido via POST
        WHILE NOT vr_flganlok AND to_number(to_char(sysdate,'sssss')) - vr_hrenvest < vr_qtsegund LOOP

          -- Aguardar 0.5 segundo para evitar sobrecarga de processador
          sys.dbms_lock.sleep(0.5);

          --Verifica se j� gravou o protocolo
          OPEN cr_sugret(pr_dsprotocolo => vr_dsprotoc);
          FETCH cr_sugret INTO rw_sugret;
          IF cr_sugret%FOUND THEN
            vr_flganlok := TRUE;
          END IF;
          CLOSE cr_sugret;
        END LOOP;

        -- Se chegarmos neste ponto e a analise n�o voltou OK signifca que houve timeout
        IF NOT vr_flganlok THEN

          --> Disparo do REQUEST
          json0001.pc_executa_ws_json(pr_request           => vr_request
                                     ,pr_response          => vr_response
                                     ,pr_diretorio_log     => vr_dsdirlog
                                     ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'
                                     ,pr_dscritic          => vr_dscritic);
          IF TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
          END IF;
          IF vr_response.status_code = 404 THEN
             vr_dscritic := 'Proposta  ja existente na esteira!';
             RAISE vr_exc_erro;
          END IF;
        END IF;
          
        --> Iniciar status
        vr_dssitret := null;--'TEMPO ESGOTADO';
          
        --> HTTP 204 nao tem conte�do
        IF vr_response.status_code != 204 THEN
          --> Extrair dados de retorno
          vr_obj_retorno := json(vr_response.content);
          --> Resultado Analise Regra
          IF vr_obj_retorno.exist('resultadoAnaliseRegra') THEN
            vr_dsresana := ltrim(rtrim(vr_obj_retorno.get('resultadoAnaliseRegra').to_char(),'"'),'"');
            --> Montar a mensagem que ser� gravada no acionamento
            CASE lower(vr_dsresana)
              WHEN 'aprovar'  THEN vr_dssitret := 'APROVADO AUTOM.';
              WHEN 'reprovar' THEN vr_dssitret := 'REJEITADA AUTOM.';
              WHEN 'derivar'  THEN vr_dssitret := 'ENVIADA ANALISE MANUAL';
              WHEN 'erro'     THEN vr_dssitret := 'ERRO';
              ELSE vr_dssitret := 'DESCONHECIDA';
            END CASE;         
          END IF;  
        END IF; 

        --> Gravar dados log acionamento
        ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper         
                                     ,pr_cdagenci              => rw_crapass.cdagenci          
                                     ,pr_cdoperad              => 'MOTOR'
                                     ,pr_cdorigem              => 5 /*Ayllos*/
                                     ,pr_nrctrprp              => pr_nrctrato
                                     ,pr_nrdconta              => pr_nrdconta          
                                     ,pr_tpacionamento         => 2  /* 1 - Envio, 2 � Retorno */      
                                     ,pr_dsoperacao            => 'RETORNO ANALISE AUTOMATICA DO RATING '||vr_dssitret
                                     ,pr_dsuriservico          => vr_host_esteira||vr_recurso_este       
                                     ,pr_dtmvtolt              => rw_crapdat.dtmvtolt       
                                     ,pr_cdstatus_http         => vr_response.status_code
                                     ,pr_dsconteudo_requisicao => vr_response.content
                                     ,pr_dsresposta_requisicao => null
                                     ,pr_dsprotocolo           => pr_dsprotoc
                                     ,pr_tpproduto             => RATI0003.fn_conv_tpctrato_tpproduto(pr_tpctrato => pr_tpctrato)
                                     ,pr_idacionamento         => vr_idacionamento
                                     ,pr_dscritic              => vr_dscritic);
                                       
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        IF vr_response.status_code NOT IN(200,204,429) THEN
          vr_dscritic := 'Nao foi possivel consultar informa�oes do Rating, '||
                         'favor entrar em contato com a equipe responsavel.  '|| 
                         '(Cod:'||vr_response.status_code||')';    
          RAISE vr_exc_erro;
        END IF;
           
        --> Buscar IndicadoresCliente
        IF vr_obj_retorno.exist('indicadoresGeradosRegra') THEN
            
          vr_obj_indicadores := json(vr_obj_retorno.get('indicadoresGeradosRegra'));
            
          --> Nivel Risco Calculado --> 
          IF vr_obj_indicadores.exist('nivelRisco') THEN
            vr_indrisco := ltrim(rtrim(vr_obj_indicadores.get('nivelRisco').to_char(),'"'),'"');
          END IF;

          --> Rating Calculado --> 
          IF vr_obj_indicadores.exist('notaRating') THEN
            vr_nrnotrat := ltrim(rtrim(vr_obj_indicadores.get('notaRating').to_char(),'"'),'"');
          END IF;
          
          --> Garantia --> 
          IF vr_obj_indicadores.exist('garantia') THEN
            vr_nrgarope := ltrim(rtrim(vr_obj_indicadores.get('garantia').to_char(),'"'),'"');
          END IF;
          
          -- N�vel Rating --
          IF vr_obj_indicadores.exist('scoreRating') THEN
            vr_desc_nivel_rating := UPPER(ltrim(rtrim(vr_obj_indicadores.get('scoreRating').to_char(),'"'),'"'));
            -- Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto)
            IF vr_desc_nivel_rating = 'BAIXO' THEN
              vr_innivel_rating := 1;
            ELSIF vr_desc_nivel_rating = 'MEDIO' THEN
              vr_innivel_rating := 2;
            ELSIF vr_desc_nivel_rating = 'ALTO' THEN
              vr_innivel_rating := 3;
            END IF;
          END IF;  -- Fim n�vel rating


          IF vr_dssitret = 'APROVADO AUTOM.' 
            OR vr_dssitret = 'REJEITADA AUTOM.' 
            OR vr_dssitret = 'ENVIADA ANALISE MANUAL' THEN
            -- Gravar o Rating da opera��o que retornou do Ibratan
            RATI0003.pc_grava_rating_operacao(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_tpctrato => pr_tpctrato
                                             ,pr_nrctrato => pr_nrctrato
                                             ,pr_ntrating => NULL
                                             ,pr_ntrataut => risc0004.fn_traduz_nivel_risco(vr_indrisco) 
                                             ,pr_dtrating => NULL
                                             ,pr_dtrataut => rw_crapdat.dtmvtolt
                                             ,pr_strating => pr_strating
                                             ,pr_orrating => 1
                                             ,pr_cdoprrat => NULL
                                             ,pr_innivel_rating     => vr_innivel_rating
                                             ,pr_nrcpfcnpj_base     => rw_crapass.nrcpfcnpj_base
                                             ,pr_inpontos_rating    => gene0002.fn_char_para_number(vr_nrnotrat) --> Pontuacao do Rating retornada do Motor
                                             ,pr_insegmento_rating  => vr_nrgarope --> Informacao de qual Garantia foi utilizada para calculo Rating do Motor
                                             ,pr_inrisco_rat_inc    => NULL --> Nivel de Rating da Inclusao da Proposta
                                             ,pr_innivel_rat_inc    => NULL --> Classificacao do Nivel de Risco do Rating Inclusao (1-Baixo/2-Medio/3-Alto)
                                             ,pr_inpontos_rat_inc   => NULL --> Pontuacao do Rating retornada do Motor no momento da Inclusao
                                             ,pr_insegmento_rat_inc => NULL --> Informacao de qual Garantia foi utilizada para calculo Rating na Inclusao 
                                             --Vari�veis para gravar o hist�rico
                                             ,pr_cdoperad           => NULL  --> Operador que gerou historico de rating  
                                             ,pr_dtmvtolt           => rw_crapdat.dtmvtolt  --> Data/Hora do historico de rating
                                             ,pr_valor              => NULL  --> Valor Contratado/Operaca
                                             ,pr_rating_sugerido    => NULL  --> Nivel de Risco Rating Novo apos alteracao manual/automatica
                                             ,pr_justificativa      => NULL  --> Justificativa do operador para alteracao do Rating
                                             ,pr_tpoperacao_rating  => NULL  --> Tipo de Operacao que gerou historico de rating (Dominio: tbgen_dominio_campo)
                                             ,pr_cdcritic           => vr_cdcritic
                                             ,pr_dscritic           => vr_dscritic);
                                           
            IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
          
          --> Se o DEBUG estiver habilitado
          IF vr_flgdebug = 'S' THEN
            --> Gravar dados log acionamento
            ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper         
                                         ,pr_cdagenci              => rw_crapass.cdagenci          
                                         ,pr_cdoperad              => 'MOTOR'          
                                         ,pr_cdorigem              => 5          
                                         ,pr_nrctrprp              => pr_nrctrato
                                         ,pr_nrdconta              => pr_nrdconta
                                         ,pr_tpacionamento         => 0  /* 0 - DEBUG */      
                                         ,pr_dsoperacao            => 'GRAVA RETORNO RATING'       
                                         ,pr_dsuriservico          => NULL       
                                         ,pr_dtmvtolt              => rw_crapdat.dtmvtolt       
                                         ,pr_cdstatus_http         => 0
                                         ,pr_dsconteudo_requisicao => null
                                         ,pr_dsresposta_requisicao => null
                                         ,pr_tpproduto             => RATI0003.fn_conv_tpctrato_tpproduto(pr_tpctrato => pr_tpctrato)
                                         ,pr_idacionamento         => vr_idaciona
                                         ,pr_dscritic              => vr_dscritic);
            --> Sem tratamento de exce�ao para DEBUG
          END IF; 
          
        END IF;
        
      END IF;        
      --> Grava�ao para libera�ao do registro
      COMMIT;
    END LOOP;  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      --> Desfazer altera�oes
      ROLLBACK;
      --> Gerar log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 ||' - RATI0004 --> Erro ao solicitar retorno Protocolo '
                                                 ||pr_dsprotoc||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na rotina RATI0004.pc_solicita_retorno '||SQLERRM;
      --> Desfazer altera�oes
      ROLLBACK;
      --> Gerar log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 ||' - RATI0004 --> Erro ao solicitar retorno Protocolo '
                                                 ||pr_dsprotoc||': '||sqlerrm,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
   END pc_solicita_retorno;
   
   --> Gravar a analise do Rating a partir do retorno do Motor
   PROCEDURE pc_busca_rating_motor(pr_cdcooper              IN tbrisco_operacoes.cdcooper%TYPE                    --> Codigo da cooperativa 
                                  ,pr_nrdconta              IN tbrisco_operacoes.nrdconta%TYPE                    --> Numero da proposta de limite
                                  ,pr_nrctrato              IN tbrisco_operacoes.nrctremp%TYPE                    --> Numero da Proposta
                                  ,pr_tpctrato              IN tbrisco_operacoes.tpctrato%TYPE                    --> Tipo da proposta de limite
                                  ,pr_dtmvtolt              IN crapdat.dtmvtolt%TYPE                              --> Data do movimento
                                  ,pr_dsconteudo_requisicao IN tbgen_webservice_aciona.dsconteudo_requisicao%TYPE --> Conteudo da requiscao
                                  ,pr_cdcritic             OUT NUMBER                                             --> C�digo da Cr�tica
                                  ,pr_dscritic             OUT VARCHAR2) IS                                       --> Descri�ao da Critica
     /* .........................................................................

     Programa : pc_busca_rating_motor
     Sistema  :
     Sigla    : CRED
     Autor    : Anderson Luiz Heckmann (AMcom)
     Data     : Maio/2019                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado
     Objetivo  : Tem como objetivo gravar a analise do Rating a partir do retorno do Motor
     Altera�ao :

     ..........................................................................*/                           
                              
     --> Cursores                          
     --> Busca do nr cpfcnpj base do associado
     CURSOR cr_crapass_ope (pr_cdcooper  IN crapass.cdcooper%TYPE     --> Coop. conectada
                           ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS --> Codigo Conta
       SELECT ass.nrcpfcnpj_base
         FROM crapass ass
        WHERE ass.cdcooper = pr_cdcooper
          AND ass.nrdconta = pr_nrdconta;
     rw_crapass_ope   cr_crapass_ope%ROWTYPE;
                
     --> Variaveis do Rating
     vr_dsresana           VARCHAR2(100);
     vr_dssitret           VARCHAR2(100);
  	 vr_indrisco           VARCHAR2(100);
 		 vr_nrnotrat           VARCHAR2(100);
 		 vr_nrgarope           VARCHAR2(100);
     vr_desc_nivel_rating  VARCHAR2(100);
     vr_obj_retorno        json := json();
     vr_obj_indicadores    json := json();
     vr_in_risco_rat       INTEGER;
     vr_inpontos_rating    tbrisco_operacoes.inpontos_rating%type;
     vr_innivel_rating     tbrisco_operacoes.innivel_rating%type; 
    
     --> Tratamento de exce��es
	   vr_exc_erro           EXCEPTION;	
		 vr_cdcritic           PLS_INTEGER;
		 vr_dscritic           VARCHAR2(4000);

   BEGIN
     --> Iniciar status
     vr_dssitret := 'TEMPO ESGOTADO';
     --> Extrair dados de retorno
     vr_obj_retorno := json(pr_dsconteudo_requisicao);
     --> Resultado Analise Regra
     IF vr_obj_retorno.exist('resultadoAnaliseRegra') THEN
       vr_dsresana := ltrim(rtrim(vr_obj_retorno.get('resultadoAnaliseRegra').to_char(),'"'),'"');
       --> Montar a mensagem que ser� gravada no acionamento
       CASE lower(vr_dsresana)
         WHEN 'aprovar'  THEN vr_dssitret := 'APROVADO AUTOM.';
         WHEN 'reprovar' THEN vr_dssitret := 'REJEITADA AUTOM.';
         WHEN 'derivar'  THEN vr_dssitret := 'ENVIADA ANALISE MANUAL';
         WHEN 'erro'     THEN vr_dssitret := 'ERRO';
         ELSE vr_dssitret := 'DESCONHECIDA';
       END CASE;         
     END IF;               
                  
     --> Buscar IndicadoresCliente
     IF vr_obj_retorno.exist('indicadoresGeradosRegra') THEN
                    
       vr_obj_indicadores := json(vr_obj_retorno.get('indicadoresGeradosRegra'));
                  
       --> Nivel Risco Calculado 
       IF vr_obj_indicadores.exist('nivelRisco') THEN
         vr_indrisco := ltrim(rtrim(vr_obj_indicadores.get('nivelRisco').to_char(),'"'),'"');
       END IF;

       --> Rating Calculado 
       IF vr_obj_indicadores.exist('notaRating') THEN
         vr_nrnotrat := ltrim(rtrim(vr_obj_indicadores.get('notaRating').to_char(),'"'),'"');
       END IF;
 
       --> Garantia 
       IF vr_obj_indicadores.exist('garantia') THEN
         vr_nrgarope := ltrim(rtrim(vr_obj_indicadores.get('garantia').to_char(),'"'),'"');
       END IF;
                   
       --> Pontos Rating 
       IF vr_nrnotrat IS NOT NULL  THEN
         vr_inpontos_rating := gene0002.fn_char_para_number(vr_nrnotrat) ;
       END IF;
      
       -- N�vel Rating -- 
       IF vr_obj_indicadores.exist('scoreRating') THEN
         vr_desc_nivel_rating := ltrim(rtrim(vr_obj_indicadores.get('scoreRating').to_char(),'"'),'"');
         -- Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto) 
         IF UPPER(vr_desc_nivel_rating) = 'BAIXO' THEN
           vr_innivel_rating := 1;
         ELSIF UPPER(vr_desc_nivel_rating) = 'MEDIO' THEN
           vr_innivel_rating := 2;
         ELSIF UPPER(vr_desc_nivel_rating) = 'ALTO' THEN
           vr_innivel_rating := 3;  
         END IF;
       END IF;
                   
       IF vr_dssitret = 'APROVADO AUTOM.' 
         OR vr_dssitret = 'REJEITADA AUTOM.' 
         OR vr_dssitret = 'ENVIADA ANALISE MANUAL' THEN 
         
         OPEN cr_crapass_ope(pr_cdcooper
                            ,pr_nrdconta);
         FETCH cr_crapass_ope INTO rw_crapass_ope;
         CLOSE cr_crapass_ope;    

         vr_in_risco_rat  := risc0004.fn_traduz_nivel_risco(vr_indrisco);
               
         -- Gravar o Rating da opera��o que retornou do Ibratan
         RATI0003.pc_grava_rating_operacao(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_tpctrato => pr_tpctrato
                                          ,pr_nrctrato => pr_nrctrato
                                          --,pr_ntrating => vr_in_risco_rat
                                          ,pr_ntrataut => vr_in_risco_rat
                                          --,pr_dtrating => pr_dtmvtolt
                                          ,pr_strating => 2
                                          ,pr_orrating => 1
                                          ,pr_cdoprrat => NULL
                                          ,pr_dtrataut => pr_dtmvtolt
                                          ,pr_innivel_rating     => vr_innivel_rating
                                          ,pr_nrcpfcnpj_base     => rw_crapass_ope.nrcpfcnpj_base
                                          ,pr_inpontos_rating    => vr_inpontos_rating --> Pontuacao do Rating retornada do Motor
                                          ,pr_insegmento_rating  => vr_nrgarope --> Informacao de qual Garantia foi utilizada para calculo Rating do Motor
                                          ,pr_inrisco_rat_inc    => NULL --> Nivel de Rating da Inclusao da Proposta
                                          ,pr_innivel_rat_inc    => NULL --> Classificacao do Nivel de Risco do Rating Inclusao (1-Baixo/2-Medio/3-Alto)
                                          --,pr_inpontos_rat_inc   => vr_inpontos_rating --> Pontuacao do Rating retornada do Motor no momento da Inclusao
                                          ,pr_insegmento_rat_inc => NULL --> Informacao de qual Garantia foi utilizada para calculo Rating na Inclusao
                                          --Vari�veis para gravar o hist�rico
                                          ,pr_cdoperad           => NULL  --> Operador que gerou historico de rating
                                          ,pr_dtmvtolt           => pr_dtmvtolt  --> Data/Hora do historico de rating
                                          ,pr_valor              => NULL  --> Valor Contratado/Operaca
                                          ,pr_rating_sugerido    => NULL  --> Nivel de Risco Rating Novo apos alteracao manual/automatica
                                          ,pr_justificativa      => NULL  --> Justificativa do operador para alteracao do Rating
                                          ,pr_tpoperacao_rating  => NULL  --> Tipo de Operacao que gerou historico de rating (Dominio: tbgen_dominio_campo)
                                          ,pr_cdcritic           => vr_cdcritic
                                          ,pr_dscritic           => vr_dscritic);

         IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;
       END IF;  
     END IF;
                 
   EXCEPTION
     WHEN vr_exc_erro THEN
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       --> Desfazer altera�oes
       ROLLBACK;
     WHEN OTHERS THEN
       pr_cdcritic := 0;
       pr_dscritic := 'Erro na rotina RATI0004.pc_busca_rating_motor '||SQLERRM;
       --> Desfazer altera�oes
       ROLLBACK;                 
   END pc_busca_rating_motor;
  
 END RATI0004;
/
