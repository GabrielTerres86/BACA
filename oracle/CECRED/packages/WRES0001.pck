CREATE OR REPLACE PACKAGE CECRED.WRES0001 AS

  /*------------------------------------------------------------------------
  
    Programa : WRES0001
    Sistema  : Rotinas genéricas para acesso a um serviço HTTP
    Sigla    : WRES
    Autor    : Ricardo Linhares
    Data     : Outubro/2016.                   Ultima atualizacao: 11/07/2017
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Fornecer funcionalidades para acessar um serviço HTTP

   Alterações: 11/07/2017 - Alterado timeout default para 110 (Ricardo).
                
  ---------------------------------------------------------------------------*/

  -- Constantes para definição de Verbos HTTP
  PUT  CONSTANT VARCHAR2(5) := 'PUT';
  GET  CONSTANT VARCHAR2(5) := 'GET';
  POST  CONSTANT VARCHAR2(5) := 'POST';
  DELETE  CONSTANT VARCHAR2(6) := 'DELETE';

  -- Tipo dicionário
  TYPE typ_reg_dicionario IS RECORD(
     chave VARCHAR2(200)
    ,valor VARCHAR2(200));
    
  TYPE typ_tab_http_cabecalho IS TABLE OF typ_reg_dicionario INDEX BY PLS_INTEGER;
  TYPE typ_tab_http_parametros IS TABLE OF typ_reg_dicionario INDEX BY PLS_INTEGER;    

  TYPE typ_http_request IS RECORD(endereco  VARCHAR2(1000) -- Diretório do Servidor. Ex: http://mobilebankhml.cecred.coop.br/apí
                                 ,rota      VARCHAR2(255) -- Rota completa da Api. Ex: conta/cooperativas
                                 ,verbo     VARCHAR2(10) -- Método da requisição HTTP, Ex: GET
                                 ,timeout   NUMBER DEFAULT 110 -- Tempo máximo para espera de uma resposta da requisição HTTP
                                 ,cabecalho   typ_tab_http_cabecalho -- Lista de propriedades do header da requisição HTTP
                                 ,parametros  typ_tab_http_parametros -- Lista de parâmetros GET (na URL) da requisição HTTP
                                 ,conteudo     CLOB -- Content da requisição HTTP
                                 );
                                 
        
  
  TYPE typ_http_response IS RECORD(status_code    NUMBER -- Código do status da resposta do servidor
                                  ,status_message VARCHAR2(4000) -- Mensagem da resposta do servidor
                                  ,conteudo        CLOB DEFAULT NULL -- Content da resposta do servidor
                                  ,cabecalho typ_tab_http_cabecalho
                                  );    
    
  PROCEDURE pc_consumir_rest(pr_requisicao IN typ_http_request
                            ,pr_resposta  OUT typ_http_response
                            ,pr_dscritic OUT crapcri.dscritic%TYPE
                            ,pr_cdcritic OUT crapcri.cdcritic%TYPE);
END WRES0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.WRES0001 AS

  /*------------------------------------------------------------------------
  
    Programa : WRES0001
    Sistema  : Rotinas genéricas para acesso a um serviço HTTP
    Sigla    : WRES
    Autor    : Ricardo Linhares
    Data     : Outubro/2016.                   Ultima atualizacao: 
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Fornecer funcionalidades para acessar um serviço HTTP
                
  ---------------------------------------------------------------------------*/
  
  PROCEDURE pc_cabecalho_to_clob(pr_cabecalho IN typ_tab_http_cabecalho
                                ,pr_clob       OUT CLOB) IS
  BEGIN
    DECLARE
      vr_index_cabecalho PLS_INTEGER; -- index dos headers
      vr_linha_clob VARCHAR2(1300);   -- vr_chave + vr_valor
     BEGIN    
      dbms_lob.createtemporary(pr_clob, FALSE);
      vr_index_cabecalho := pr_cabecalho.first;
      WHILE vr_index_cabecalho IS NOT NULL LOOP
        vr_linha_clob := pr_cabecalho(vr_index_cabecalho).chave || ':' || pr_cabecalho(vr_index_cabecalho).valor || '; ';
        dbms_lob.writeappend(pr_clob, LENGTH(vr_linha_clob), vr_linha_clob);
        vr_index_cabecalho := pr_cabecalho.next(vr_index_cabecalho);
      END LOOP;
    END;
  END;
  
  PROCEDURE pc_log_rest(pr_requisicao   IN typ_http_request
                       ,pr_endereco     IN VARCHAR2
                       ,pr_dtrequisicao IN DATE
                       ,pr_resposta     IN typ_http_response
                       ,pr_dtresposta   IN DATE
                       ,pr_cdcritic     IN crapcri.cdcritic%TYPE) IS   
  PRAGMA AUTONOMOUS_TRANSACTION;                       
  BEGIN
   DECLARE
     vr_clob_cabecalho_requisicao CLOB;
     vr_clob_cabecalho_resposta   CLOB;

   BEGIN
     -- Cria um CLOB do cabeçalho da Requisição
     pc_cabecalho_to_clob(pr_cabecalho => pr_requisicao.cabecalho
                         ,pr_clob      => vr_clob_cabecalho_requisicao);
                         
     -- Cria um CLOB do cabeçalho da Resposta
     pc_cabecalho_to_clob(pr_cabecalho => pr_resposta.cabecalho
                         ,pr_clob      => vr_clob_cabecalho_resposta);                         
   
     INSERT INTO TBGEN_REQ_WEBSERVICE(dhrequis
                                     ,dhresposta
                                     ,dsservico
                                     ,dsverbo_http
                                     ,dscabecalho_requis
                                     ,dsconteudo_requis
                                     ,dscabecalho_resposta
                                     ,dsconteudo_resposta
                                     ,nrtimeout_requis
                                     ,cdhttp_resposta
                                     ,cdcritic)
                VALUES (pr_dtrequisicao
                       ,pr_dtresposta
                       ,pr_endereco
                       ,pr_requisicao.verbo
                       ,vr_clob_cabecalho_requisicao
                       ,pr_requisicao.conteudo
                       ,vr_clob_cabecalho_resposta
                       ,pr_resposta.conteudo
                       ,pr_requisicao.timeout
                       ,pr_resposta.status_code
                       ,pr_cdcritic);
                       
        COMMIT;
        
       EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
   
      END;                       

  END;

  PROCEDURE pc_consumir_rest(pr_requisicao IN typ_http_request
                            ,pr_resposta   OUT typ_http_response
                            ,pr_dscritic   OUT crapcri.dscritic%TYPE
                            ,pr_cdcritic   OUT crapcri.cdcritic%TYPE) IS
                            
    -- ..........................................................................
    --
    --  Programa : pc_consumir_rest
    --  Sistema  : Rotinas do HTTP
    --  Sigla    : WRES0001
    --  Autor    : Ricardo Linhares
    --  Data     : Outubro/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Efetuar uma requisição Rest para um servidor HTTP

    -- .............................................................................                                
  
  BEGIN
  
    DECLARE
    
      vr_req             utl_http.req; -- requisição http
      vr_res             utl_http.resp; -- resposta da requisição
      vr_index_cabecalho PLS_INTEGER; -- index dos headers
      vr_index_parametro PLS_INTEGER; -- index da content string
      vr_endereco        VARCHAR2(1000);
      vr_resposta        CLOB; -- corpo da resposta da requisição
      vr_resposta_texto  VARCHAR2(32000); --> Texto de resposta da requisição
      vr_exc_saida       EXCEPTION;
      vr_chave           VARCHAR2(256); -- chave para cabecalhos HTTP de resposta
      vr_valor           VARCHAR2(1024); -- valor para cabecalhos HTTP de reposta  
      vr_dtrequisicao    DATE;
      vr_dtresposta      DATE; 
    
    BEGIN
      
      BEGIN
    
      vr_endereco := pr_requisicao.endereco || pr_requisicao.rota;
    
      -- Monta a URL
      IF (pr_requisicao.parametros.count > 0) THEN
      
        vr_index_parametro := pr_requisicao.parametros.first;
        vr_endereco := vr_endereco || '?';
      
        WHILE vr_index_parametro IS NOT NULL LOOP
        
          vr_endereco := vr_endereco || pr_requisicao.parametros(vr_index_parametro).chave 
                                     || '=' || pr_requisicao.parametros(vr_index_parametro).valor;
        
          vr_index_parametro := pr_requisicao.parametros.next(vr_index_parametro);
          
          IF(vr_index_parametro IS NOT NULL) THEN
            vr_endereco := vr_endereco || '&';
          END IF;
        
        END LOOP;
      
      END IF;
      
      vr_dtrequisicao := SYSDATE;
      
      -- Abre a chamada HTTP
      BEGIN
        utl_http.set_transfer_timeout(pr_requisicao.timeout);
        vr_req := utl_http.begin_request(vr_endereco, pr_requisicao.verbo, utl_http.http_version_1_1);
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Nao foi possivel conectar ao serviço HTTP: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Monta o cabeçalho HTTP
      vr_index_cabecalho := pr_requisicao.cabecalho.first;
      WHILE vr_index_cabecalho IS NOT NULL LOOP
        utl_http.set_header(vr_req, pr_requisicao.cabecalho(vr_index_cabecalho).chave, pr_requisicao.cabecalho(vr_index_cabecalho).valor);
        vr_index_cabecalho := pr_requisicao.cabecalho.next(vr_index_cabecalho);
      END LOOP;

      utl_http.set_header(vr_req ,'User-Agent', 'Ayllos/PLSQL');

      -- Envia o conteúdo no Content se for um POST
      IF (pr_requisicao.verbo = WRES0001.post) THEN
        utl_http.set_header(vr_req ,'Content-Length', LENGTH(pr_requisicao.conteudo));
        utl_http.write_text(vr_req, pr_requisicao.conteudo);
      END IF;

      -- Pega o retnorno da chamada
      vr_res := utl_http.get_response(vr_req);
      vr_dtresposta := SYSDATE;
    
      -- Busca os cabeçalhos de retorno
      FOR i IN 1 .. utl_http.get_header_count(vr_res) LOOP
        utl_http.get_header(vr_res, i, vr_chave, vr_valor);
        IF(vr_chave != 'X-SourceFiles') THEN
          pr_resposta.cabecalho(i).chave := vr_chave;
          pr_resposta.cabecalho(i).valor := vr_valor;
        END IF;
      END LOOP;

      -- Obtém status da resposta
      pr_resposta.status_code := vr_res.status_code;
      pr_resposta.status_message := vr_res.reason_phrase;
    
      -- Copia o conteúdo da resposta para dentro de um CLOB
      IF(vr_res.status_code <> utl_http.http_no_content) THEN
        vr_resposta := NULL;
        dbms_lob.createtemporary(vr_resposta, FALSE);
        BEGIN
          LOOP
            utl_http.read_text(vr_res, vr_resposta_texto, 32000);
            dbms_lob.writeappend(vr_resposta, LENGTH(vr_resposta_texto), vr_resposta_texto);
          END LOOP;
        EXCEPTION
          WHEN utl_http.end_of_body THEN
            utl_http.end_response(vr_res);
          WHEN OTHERS THEN
            NULL;
         END;
        ELSE
          utl_http.end_response(vr_res);
        END IF;

      pr_resposta.conteudo := vr_resposta;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := SQLERRM;
    END;
    
    -- log da requisição
    pc_log_rest(pr_requisicao   => pr_requisicao
               ,pr_endereco     => vr_endereco
               ,pr_dtrequisicao => vr_dtrequisicao
               ,pr_resposta     => pr_resposta
               ,pr_dtresposta   => vr_dtresposta
               ,pr_cdcritic     => pr_cdcritic);        

   END;

  
  END pc_consumir_rest;

END WRES0001;
/
