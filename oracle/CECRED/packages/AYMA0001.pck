CREATE OR REPLACE PACKAGE CECRED.AYMA0001 AS

  /*------------------------------------------------------------------------
  
    Programa : AYMA0001
    Sistema  : Rotinas genéricas para acesso ao Aymaru
    Sigla    : AYMA
    Autor    : Ricardo Linhares
    Data     : Outubro/2016.                   Ultima atualizacao: 
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Fornecer funcionalidades para acessar o Aymaru
                
  ---------------------------------------------------------------------------*/


  -- Tipo da Reposta do Aymaru
  TYPE typ_http_response_aymaru IS RECORD(status_code    NUMBER -- Código do status da resposta do servidor
                                         ,status_message VARCHAR2(4000) -- Mensagem da resposta do servidor
                                         ,conteudo       json -- Content da resposta do servidor
                                         ,cabecalho WRES0001.typ_tab_http_cabecalho
                                         );                             

  -- Procedure para consumir Aymaru
  PROCEDURE pc_consumir_ws_rest_aymaru(pr_rota       IN VARCHAR2                          -- rota do serviço no aymaru
                                      ,pr_verbo      IN VARCHAR2                          -- verbo do serviço (GET, POST, PUT)
                                      ,pr_servico     IN VARCHAR2                         -- versão do serviço no Aymaru
                                      ,pr_parametros IN WRES0001.typ_tab_http_parametros  -- Parâmetros do GET
                                      ,pr_conteudo   IN JSON                              -- Conteúdo para POST
                                      ,pr_resposta   OUT typ_http_response_aymaru         --  Resposta do Aymaru
                                      ,pr_dscritic   OUT crapcri.dscritic%TYPE
                                      ,pr_cdcritic   OUT crapcri.cdcritic%TYPE);
                                      
                                     
END AYMA0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.AYMA0001 AS

  /*------------------------------------------------------------------------
  
    Programa : AYMA0001
    Sistema  : Rotinas genéricas para acesso ao Aymaru
    Sigla    : AYMA
    Autor    : Ricardo Linhares
    Data     : Outubro/2016.                   Ultima atualizacao: 
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Fornecer funcionalidades para acessar o Aymaru
                
  ---------------------------------------------------------------------------*/


  FUNCTION fn_buscar_versao_api(pr_api      IN VARCHAR2
                               ,pr_dscritic OUT crapcri.dscritic%TYPE
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE)
    RETURN VARCHAR2 IS
    
    -- ..........................................................................
    --
    --  Programa : fn_buscar_versao_api
    --  Sistema  : Rotinas do Aymaru
    --  Sigla    : AYMA0001
    --  Autor    : Ricardo Linhares
    --  Data     : Outubro/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Obter a versão do serviço que será utilizado no Aymaru.

    -- .............................................................................    
    
  BEGIN
  
    DECLARE
      vr_exc_erro EXCEPTION;
      vr_vet_api gene0002.typ_split; --vetor da api
      vr_vet_ver gene0002.typ_split; --vetor de versões da api
     
      -- Cursor da tabela de parâmetros
      CURSOR cr_crapprm IS
        SELECT dsvlrprm
          FROM crapprm
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'SERVICO.AYMARU';
      rw_crapprm cr_crapprm%ROWTYPE;
      
    
    BEGIN
    
      OPEN cr_crapprm;
      FETCH cr_crapprm
        INTO rw_crapprm;
    
      IF cr_crapprm%NOTFOUND THEN
        CLOSE cr_crapprm;
        pr_dscritic := 'Não foi possível consultar os parâmetros.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapprm;
      END IF;
    
      vr_vet_ver := gene0002.fn_quebra_string(rw_crapprm.dsvlrprm, ';');
    
      -- Varrre os parâmetros em busca da API
      FOR i IN 1 .. vr_vet_ver.count LOOP
        vr_vet_api := gene0002.fn_quebra_string(vr_vet_ver(i), ',');
        IF (vr_vet_api(1) = pr_api) THEN
          RETURN vr_vet_api(2);
        END IF;
      
      END LOOP;
    
      pr_dscritic := 'API não encontrada';
    
      RETURN NULL;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := SQLERRM;
    END;
  
  END fn_buscar_versao_api;

  PROCEDURE pc_consumir_ws_rest_aymaru(pr_rota       IN VARCHAR2                        -- rota do serviço no aymaru Ex: '/Cadastral/Cooperativa/Consultar'
                                      ,pr_verbo      IN VARCHAR2                        -- verbo do serviço Ex: 'GET'
                                      ,pr_servico     IN VARCHAR2                       -- versão do serviço no Aymaru Ex: '1'
                                      ,pr_parametros IN WRES0001.typ_tab_http_parametros-- Parâmetros do GET (Dicionário Chave/Valor)
                                      ,pr_conteudo   IN JSON                            -- Conteúdo para POST (Conteúdo no formato JSON)
                                      ,pr_resposta   OUT typ_http_response_aymaru       
                                      ,pr_dscritic   OUT crapcri.dscritic%TYPE
                                      ,pr_cdcritic   OUT crapcri.cdcritic%TYPE) IS
                                      
  -- ..........................................................................
    --
    --  Programa : pc_consumir_ws_rest_aymaru
    --  Sistema  : Rotinas do Aymaru
    --  Sigla    : AYMA0001
    --  Autor    : Ricardo Linhares
    --  Data     : Outubro/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Efetua uma requisição Rest para o Aymaru.

    -- .............................................................................                                        
    
  BEGIN
  
    DECLARE
    
      vr_index_http_cabecalho PLS_INTEGER; -- index dos headers
      vr_exc_erro EXCEPTION;
      vr_requisicao WRES0001.typ_http_request;
      vr_cabecalho  WRES0001.typ_tab_http_cabecalho;
      vr_endereco_aymaru VARCHAR2(100);
    
      -- Cursor de tokens do aymaru
      CURSOR cr_token_aymaru IS
        SELECT gene0002.fn_busca_entrada(pr_postext     => 1
                                        ,pr_dstext      => dsvlrprm
                                        ,pr_delimitador => ';') authentication_id
              ,gene0002.fn_busca_entrada(pr_postext     => 2
                                        ,pr_dstext      => dsvlrprm
                                        ,pr_delimitador => ';') authentication_secred
          FROM crapprm
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'TOKEN.AYMARU';
    
      rw_token_aymaru cr_token_aymaru%ROWTYPE;
      
      -- Cursor de parâmetros
      CURSOR cr_crapprm IS
        SELECT dsvlrprm
          FROM crapprm
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'ENDERECO.AYMARU';
    
      rw_crapprm cr_crapprm%ROWTYPE;      
      vr_resposta WRES0001.typ_http_response;
      vr_conteudo CLOB;

      vr_versao_api VARCHAR2(3);
      vr_lista json_list := json_list();
      
      --exceções
      parser_exception exception;
      pragma exception_init(parser_exception, -20101);      
    
    BEGIN
      
      -- Buscar versão da API
      vr_versao_api := fn_buscar_versao_api(pr_api      => pr_servico
                                           ,pr_dscritic => pr_dscritic
                                           ,pr_cdcritic => pr_cdcritic);    
    
    
      -- header para tipo de conteúdo
      vr_index_http_cabecalho := 0;
      vr_cabecalho(vr_index_http_cabecalho).chave := 'Content-Type';
      vr_cabecalho(vr_index_http_cabecalho).valor := 'application/json';
    
      -- header para versao do servico
      vr_index_http_cabecalho := vr_index_http_cabecalho + 1;
      vr_cabecalho(vr_index_http_cabecalho).chave := 'Cecred-Api-Version';
      vr_cabecalho(vr_index_http_cabecalho).valor := vr_versao_api;
      
      -- Consulta os parâmetros
      OPEN cr_token_aymaru;
      FETCH cr_token_aymaru
        INTO rw_token_aymaru;
    
      IF cr_token_aymaru%NOTFOUND THEN
        CLOSE cr_token_aymaru;
        pr_dscritic := 'Não foi possível consultar parâmetros.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_token_aymaru;
      END IF;
    
      -- header para Authentication ID
      vr_index_http_cabecalho := vr_index_http_cabecalho + 1;
      vr_cabecalho(vr_index_http_cabecalho).chave := TRIM(gene0002.fn_busca_entrada(pr_postext     => 1
                                                                                   ,pr_dstext      => rw_token_aymaru.authentication_id
                                                                                   ,pr_delimitador => ':'));
      vr_cabecalho(vr_index_http_cabecalho).valor := TRIM(gene0002.fn_busca_entrada(pr_postext     => 2
                                                                                     ,pr_dstext      => rw_token_aymaru.authentication_id
                                                                                     ,pr_delimitador => ':'));
      -- header para Authentication Secret
      vr_index_http_cabecalho := vr_index_http_cabecalho + 1;
      vr_cabecalho(vr_index_http_cabecalho).chave := TRIM(gene0002.fn_busca_entrada(pr_postext     => 1
                                                                                   ,pr_dstext      => rw_token_aymaru.authentication_secred
                                                                                   ,pr_delimitador => ':'));
      vr_cabecalho(vr_index_http_cabecalho).valor := TRIM(gene0002.fn_busca_entrada(pr_postext     => 2
                                                                                     ,pr_dstext      => rw_token_aymaru.authentication_secred
                                                                                     ,pr_delimitador => ':'));

    
     -- Busca o endereço do servidor do Aymaru                                                                                 
      OPEN cr_crapprm;
      FETCH cr_crapprm
        INTO rw_crapprm;
    
      IF cr_crapprm%NOTFOUND THEN
        CLOSE cr_crapprm;
        pr_dscritic := 'Não foi possível consultar parâmetros.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapprm;
      END IF;         
      
      vr_endereco_aymaru := rw_crapprm.dsvlrprm;                                                                       

      -- Salva o JSON em CLOB
      dbms_lob.createtemporary(vr_conteudo, TRUE);
      pr_conteudo.to_clob(vr_conteudo, FALSE);          
    
      -- monta requisicao
      vr_requisicao.endereco := vr_endereco_aymaru;
      vr_requisicao.rota := pr_rota;
      vr_requisicao.verbo := pr_verbo;
      vr_requisicao.cabecalho := vr_cabecalho;
      vr_requisicao.parametros := pr_parametros;
      vr_requisicao.conteudo := vr_conteudo;
    
      -- chamada para consumidor REST
      WRES0001.pc_consumir_rest(pr_requisicao => vr_requisicao
                      ,pr_resposta   => vr_resposta
                      ,pr_dscritic   => pr_dscritic
                      ,pr_cdcritic   => pr_cdcritic);
                      
      pr_resposta.status_code := vr_resposta.status_code;
      pr_resposta.status_message := vr_resposta.status_message;

      -- Verifica se há conteúdo na resposta      
      IF(length(vr_resposta.conteudo) > 0) THEN
        BEGIN
          pr_resposta.conteudo := json(vr_resposta.conteudo);      
        EXCEPTION
          WHEN parser_exception THEN
            vr_lista := json_list(vr_resposta.conteudo);
            pr_resposta.conteudo := json(vr_lista);
         END;
       END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        NULL;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao consumir Aymaru: ' || SQLERRM;
      
    END;
  
  END pc_consumir_ws_rest_aymaru;


END AYMA0001;
/
