CREATE OR REPLACE PACKAGE CECRED.soap0001 AS
/*..............................................................................

   Programa: soap0001
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Petter Rafael - Supero Tecnologia
   Data    : Agosto/2013                Ultima Atualizacao:

   Dados referentes ao programa:

   Objetivo  : Cliente para webservice.
.................................................................................*/
  PROCEDURE pc_cliente_webservice (pr_endpoint    IN VARCHAR2        --> URL do endpoint
                                  ,pr_acao        IN VARCHAR2        --> Ação do webservice
                                  ,pr_wallet_path IN VARCHAR2        --> Path do arquivo para wallet
                                  ,pr_wallet_pass IN VARCHAR2        --> Senha para acessar wallet
                                  ,pr_xml_req     IN xmltype         --> XML de requisição
                                  ,pr_xml_res     OUT NOCOPY xmltype --> XML de resposta
                                  ,pr_erro        OUT VARCHAR2);     --> Mensagem Erro
                                  
  PROCEDURE pc_soap_jdctc_client (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo da cooperativa
                                 ,pr_idservic IN INTEGER               --Identificador Servico    
                                 ,pr_arqenvio IN VARCHAR2              --XML de requisição
                                 ,pr_arqreceb IN VARCHAR2              --XML de resposta
                                 ,pr_des_reto OUT VARCHAR2);                    --Mensagem Erro                                  
                                  
END soap0001;
/

CREATE OR REPLACE PACKAGE BODY CECRED.soap0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : soap0001
  --  Sistema  : Procedimentos e funcoes para comunicacao com webservice.
  --  Sigla    : CRED
  --  Autor    : Petter Rafael - Supero Tecnologia
  --  Data     : Julho/2013.
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Cliente para webservice.

  ---------------------------------------------------------------------------------------------------------------

  /* Efetua o parser XML em um CLOB */
  PROCEDURE pc_gera_xml(pr_xml_clob IN CLOB           --> XML em modo texto (CLOB)
                       ,pr_xml      OUT xmltype       --> XML com parser executado
                       ,pr_des_erro OUT VARCHAR2) IS  --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_xml
  --  Sistema  : SOAP
  --  Sigla    : CRED
  --  Autor    : Petter Rafael - Supero Tecnologia
  --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Executar parser XML.
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    BEGIN
      -- Efetuar parser XML
      pr_xml := xmltype.createxml(pr_xml_clob);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em SOAP0001.pc_gera_xml: ' || SQLERRM;
    END;
  END pc_gera_xml;


  /* Acesso ao cliente para webservice */
  PROCEDURE pc_cliente_webservice (pr_endpoint    IN VARCHAR2        --> URL do endpoint
                                  ,pr_acao        IN VARCHAR2        --> Ação do webservice
                                  ,pr_wallet_path IN VARCHAR2        --> Path do arquivo para wallet
                                  ,pr_wallet_pass IN VARCHAR2        --> Senha para acessar wallet
                                  ,pr_xml_req     IN xmltype         --> XML de requisição
                                  ,pr_xml_res     OUT NOCOPY xmltype --> XML de resposta
                                  ,pr_erro        OUT VARCHAR2) IS   --> Mensagem Erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_cliente_webservice
  --  Sistema  : SOAP
  --  Sigla    : CRED
  --  Autor    : Petter Rafael - Supero Tecnologia
  --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Consumir Webservice.
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      pr_requisicao   UTL_HTTP.REQ;     --> Objeto HTTP para requisição
      pr_response     UTL_HTTP.RESP;    --> Objeto HTTP para resposta
      pr_xml_clob     CLOB;             --> Variável para armazenar o XML de resposta
      vr_erro         EXCEPTION;        --> Tratamento de exceções

    BEGIN
      -- Verifica se irá existir wallet para a requisição
      IF pr_wallet_path IS NOT NULL AND pr_wallet_pass IS NOT NULL THEN
        UTL_HTTP.set_wallet(pr_wallet_path, pr_wallet_pass);
      END IF;

      -- Montar cabeçalho HTTP da requisição
      pr_requisicao := UTL_HTTP.begin_request(pr_endpoint, 'POST','HTTP/1.0');
      UTL_HTTP.set_header(pr_requisicao, 'Content-Type', 'text/xml');
      UTL_HTTP.set_header(pr_requisicao, 'Content-Length', length(TRIM(pr_xml_req.getclobval())));

      -- Verifica se existe ação específica para o webservice
      IF pr_acao IS NOT NULL THEN
        UTL_HTTP.set_header(pr_requisicao, 'SOAPAction', pr_acao);
      END IF;

      -- Faz o envio do envelope
      UTL_HTTP.write_text(pr_requisicao, pr_xml_req.getclobval());

      -- Captura a resposta
      pr_response := UTL_HTTP.get_response(pr_requisicao);
      UTL_HTTP.read_text(pr_response, pr_xml_clob);
      UTL_HTTP.end_response(pr_response);

      -- Executa parser no XML de retorno
      pc_gera_xml(pr_xml_clob => pr_xml_clob
                 ,pr_xml      => pr_xml_res
                 ,pr_des_erro => pr_erro);

      -- Verifica se ocorreram erros
      IF pr_erro IS NOT NULL THEN
        RAISE vr_erro;
      END IF;
    EXCEPTION
      WHEN vr_erro THEN
        pr_erro := 'Erro em SOAP0001.pc_cliente_webservice no parser XML: ' || pr_erro;
      WHEN utl_http.end_of_body THEN
        utl_http.end_response(pr_response);
      WHEN utl_http.request_failed THEN
        pr_erro := 'Requisição falhou em SOAP0001.pc_cliente_webservice: ' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN utl_http.http_server_error THEN
        pr_erro := 'Erro no servidor em SOAP0001.pc_cliente_webservice: ' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN utl_http.http_client_error THEN
        pr_erro := 'Erro no cliente em SOAP0001.pc_cliente_webservice: ' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN OTHERS THEN
        pr_erro := 'Erro geral em SOAP0001.pc_cliente_webservice: ' || SQLERRM;
    END;
  END pc_cliente_webservice;
  
  
  
  /* PROCEDURE GENERICA DE REQUISICOES SOAP AO WEBSERVICE DA JDCTC */
  PROCEDURE pc_soap_jdctc_client (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo da cooperativa
                                 ,pr_idservic IN INTEGER               --Identificador Servico    
                                 ,pr_arqenvio IN VARCHAR2              --XML de requisição
                                 ,pr_arqreceb IN VARCHAR2              --XML de resposta
                                 ,pr_des_reto OUT VARCHAR2) IS         --Mensagem Erro
  BEGIN
    
  /* .............................................................................
  
   Programa: pc_soap_jdctc_client
   Sistema : SOAP
   Sigla   : CRED
   Autor   : Carlos Rafael Tanholi
   Data    : Junho/15.                    Ultima atualizacao: 17/06/2015

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina de comunicacao SOAP com WEBSERVICE da JDCTC.

   Observacao: -----
   ..............................................................................*/    
  
    DECLARE
    
      vr_comando   VARCHAR2(32767);
      vr_typ_saida VARCHAR2(3);
      vr_dscomora  VARCHAR2(1000);
      vr_dsdirbin  VARCHAR2(1000); 
      
      --Variaveis de Erro
      vr_dscritic VARCHAR2(1000);
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
    
    BEGIN                                  
    
      --Buscar parametros 
      vr_dscomora:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_EXEC_SHELL');
      vr_dsdirbin:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_CECRED_BIN');

      --se nao encontrou
      IF vr_dscomora IS NULL OR vr_dsdirbin IS NULL THEN
        --Montar mensagem erro        
        vr_dscritic:= 'Nao foi possivel selecionar parametros.';
        
        RAISE vr_exc_erro;
      END IF;

      --Montar comando e Enviar Soap
      vr_comando:= vr_dscomora||' perl_remoto '|| vr_dsdirbin|| 'SendSoapJDCTC.pl --servico='||
                   chr(39)|| pr_idservic ||chr(39)||' < '|| pr_arqenvio||' > '|| pr_arqreceb;
                    
      --Executar Comando Unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);                                  
                                  
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        --Montar mensagem erro        
        vr_dscritic:= 'Nao foi possivel executar comando unix: '||
                      vr_comando||' - '||vr_dscritic;
        
        RAISE vr_exc_erro;
      END IF;   
                
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_reto := vr_dscritic;
      WHEN OTHERS THEN
        pr_des_reto := 'Erro na SOAP0001.pc_soap_jdctc_client. '||sqlerrm;
    END;      
        
                                    
  END pc_soap_jdctc_client;                                    
                                    
END soap0001;
/

