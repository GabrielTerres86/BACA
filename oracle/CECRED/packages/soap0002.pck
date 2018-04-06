CREATE OR REPLACE PACKAGE CECRED.soap0002 AS
/*..............................................................................

   Programa: soap0001
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odirlei Busana - AMcom
   Data    : outubro/2017                Ultima Atualizacao:

   Dados referentes ao programa:

   Objetivo  : Centralizar rotinas para comunicação com o webservice do CRM.
.................................................................................*/
                                   
  --> COLECTION DESTINADA A CONTER OS SERVIÇOS DO WEBSERVICE 
  TYPE typ_tab_metodos IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  TYPE typ_rec_servico IS RECORD (dsservico  VARCHAR2(50)
                                 ,dsinterfa  VARCHAR2(50)
                                 ,tbmetodos  typ_tab_metodos);
  TYPE typ_tab_wscip   IS TABLE OF typ_rec_servico INDEX BY BINARY_INTEGER;
  vr_wscip_services    typ_tab_wscip;
  
  --> Procedure para gerar o corpo do soap 
  PROCEDURE pc_xmlsoap_monta_estrutura(pr_cdservic  IN NUMBER       --> Chamve do Serviço requisitado
                                      ,pr_cdmetodo  IN NUMBER       --> Chave do Método requisitado
                                      ,pr_xml      OUT xmltype      --> Objeto do XML criado
                                      ,pr_des_erro OUT VARCHAR2     --> Descricao erro OK/NOK
                                      ,pr_dscritic OUT VARCHAR2);   --> Descricao erro

  --> rotina para enviar requisição
  PROCEDURE pc_envia_requisicao (pr_cdservic  IN NUMBER       --> Chamve do Serviço requisitado
                                ,pr_cdmetodo  IN NUMBER       --> Chave do Método requisitado
                                ,pr_xml       IN xmltype      --> Objeto do XML criado
                                ,pr_cdcritic OUT VARCHAR2     --> codigo do ero
                                ,pr_dscritic OUT VARCHAR2     --> Descricao erro
                                ,pr_dsdetail OUT VARCHAR2);   --> Retornar os detalhes da critica
  
                                    
END soap0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.soap0002 AS

  /*---------------------------------------------------------------------------------------------------------------
  Programa: soap0001
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odirlei Busana - AMcom
   Data    : outubro/2017                Ultima Atualizacao:

   Dados referentes ao programa:

   Objetivo  : Centralizar rotinas para comunicação com o webservice do CRM.

  ---------------------------------------------------------------------------------------------------------------*/
  
  vr_dsdeuser  VARCHAR2(50);
  vr_dsdepass  VARCHAR2(50);
  vr_dsendcom  VARCHAR2(200);
  vr_dsendser  VARCHAR2(200);
  vr_dsverser  VARCHAR2(10);
  vr_dstextab  craptab.dstextab%TYPE;
  
  -- Rotina para verificar se houve retorno de erro do Webservice - Fault Packet
  PROCEDURE pc_valid_ret_soap(pr_dsxmret   IN CLOB              --> XML para avaliar se houve erro
                             ,pr_cdcritic OUT NUMBER            --> Retornar o código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Retornar a descrição da critica
                             ,pr_dsdetail OUT VARCHAR2) IS      --> Retornar os detalhes da critica
    
    /* ..........................................................................

      Programa : pc_valid_ret_soap
      Sistema  : cecred
      Sigla    : CRED
      Autor    : Odirlei Busana - AMcom
      Data     : outubro/2017.                   Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para verificar se houve critica de retorno via SOAP e em
                  caso afirmativo, retornar a mesma.

      Alteração :
    ..........................................................................*/
  
    -- Extrair erros do XML
    CURSOR cr_faultpacket IS
      WITH DATA AS (SELECT replace(pr_dsxmret,'ns0:') xml FROM dual)
      SELECT faultcode
           , faultstring
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'SOAP-ENV:Fault' AS "fault")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/SOAP-ENV:Fault'
                      PASSING XMLTYPE(xml)
                      COLUMNS faultcode   VARCHAR2(25)   PATH 'faultcode'
                            , faultstring VARCHAR2(1000) PATH 'faultstring');
    
    rw_faultpacket  cr_faultpacket%ROWTYPE;
    
    -- Extrair erros do XML
    CURSOR cr_erroInfo IS
      WITH DATA AS (SELECT replace(pr_dsxmret,'ns0:') xml FROM dual)
      SELECT tipo
           , cod
           , msg
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'SOAP-ENV:Fault' AS "fault")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/SOAP-ENV:Fault/detail/errorInfoFault'
                      PASSING XMLTYPE(xml)
                      COLUMNS msg   VARCHAR2(1000)   PATH 'msg'
                             ,tipo  VARCHAR2(25)   PATH 'type'
                             ,cod   VARCHAR2(25)   PATH 'code'  );
    
    rw_erroInfo  cr_erroInfo%ROWTYPE;
    
    -- Extrair erros detalhes
    CURSOR cr_faultdetail IS
      WITH DATA AS (SELECT replace(pr_dsxmret,'ns0:') xml FROM dual)
      SELECT fault
        FROM DATA
            ,XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS
                                    "SOAP-ENV",
                                    'SOAP-ENV:Fault' AS "fault"),
                      '/SOAP-ENV:Envelope/SOAP-ENV:Body/SOAP-ENV:Fault/detail/errorInfoFault'
                      PASSING XMLTYPE(xml) 
                      COLUMNS fault VARCHAR2(1000) PATH'fault');
    
    rw_faultdetail  cr_faultdetail%ROWTYPE;
    
    -- VARIÁVEIS
    vr_cdauxcri     VARCHAR2(25);
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);
    vr_idlogarq     crapprm.dsvlrprm%TYPE;
    
    
  BEGIN
    
    -- Buscar a critica no XML
    OPEN  cr_faultpacket;
    FETCH cr_faultpacket INTO rw_faultpacket;   
    
    -- Se não retornou nenhum registro
    IF cr_faultpacket%NOTFOUND THEN
      
      -- Não retornar crítica
      pr_cdcritic := 0;
      pr_dscritic := NULL;
    ELSE
      CLOSE cr_faultpacket;
      
      -- Buscar a critica no XML
      rw_erroInfo := NULL;
      OPEN  cr_erroInfo;
      FETCH cr_erroInfo INTO rw_erroInfo;
      CLOSE cr_erroInfo;
      
      
      vr_cdauxcri := nvl(rw_erroInfo.cod,rw_faultpacket.faultcode);
      vr_dscritic := nvl(rw_erroInfo.msg,rw_faultpacket.faultstring);
      
      
      BEGIN
        -- Converter código de erro
        vr_cdcritic := ABS(TO_NUMBER(substr(vr_cdauxcri,INSTR(vr_cdauxcri,':')+1)));
      EXCEPTION 
        WHEN OTHERS THEN
          -- Caso houver erro... é porque não retornou código numerico, neste caso retornar zero
          vr_cdcritic := 0;
      END;
                
      -- Retornar a crítica encontrada
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      
      IF nvl(pr_cdcritic,0) > 0 OR
         TRIM(pr_dscritic) IS NOT NULL  THEN
        
        -- Buscar detalhes da critica
        OPEN  cr_faultdetail;
        FETCH cr_faultdetail INTO rw_faultdetail;   
        
        -- Se não retornou nenhum registro
        IF cr_faultdetail%FOUND THEN
          pr_dsdetail := rw_faultdetail.fault;
        END IF;
      
      END IF;    
      
    END IF;
        
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_dscritic := 'Erro pc_valid_ret_soap: '||SQLERRM;
  END pc_valid_ret_soap;
  
  --> Procedure para gerar o corpo do soap 
  PROCEDURE pc_xmlsoap_monta_estrutura(pr_cdservic  IN NUMBER       --> Chamve do Serviço requisitado
                                      ,pr_cdmetodo  IN NUMBER       --> Chave do Método requisitado
                                      ,pr_xml      OUT xmltype      --> Objeto do XML criado
                                      ,pr_des_erro OUT VARCHAR2     --> Descricao erro OK/NOK
                                      ,pr_dscritic OUT VARCHAR2) IS --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_xmlsoap_monta_estrutura
    --  Sistema  : cecred
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : outubro/2017.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para gerar cabecalho de envelope soap
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
    vr_exc_erro     EXCEPTION;
    
    -- VARIÁVEIS
    vr_dsservic     VARCHAR2(100);
    vr_dsinterf     VARCHAR2(100);
    vr_dsmetodo     VARCHAR2(100);    
    vr_clob         CLOB;
    
  BEGIN
    -- Indicar que o método não foi concluído
    pr_des_erro := 'NOK';
  
    -- Verificar se o código de serviço informado existe
    IF NOT vr_wscip_services.EXISTS(pr_cdservic) THEN
      pr_dscritic := 'Código de Serviço informado não encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verificar se o código do método informado existe
    IF NOT vr_wscip_services(pr_cdservic).tbmetodos.EXISTS(pr_cdmetodo) THEN
      pr_dscritic := 'Código do Método informado não encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    -- Manter o serviço e o método em variáveis - Apenas para facilitar a concatenação
    vr_dsservic := vr_wscip_services(pr_cdservic).dsservico;
    vr_dsinterf := vr_wscip_services(pr_cdservic).dsinterfa;
    vr_dsmetodo := vr_wscip_services(pr_cdservic).tbmetodos(pr_cdmetodo);

    vr_clob := '<?xml version="1.0" encoding="UTF-8"?>'
               ||'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" '
               ||'       xmlns:v1="'  || vr_dsendcom ||'/INF/MD/Global/MsgHeader/'||vr_dsverser||'" '
               ||'       xmlns:v11="' || vr_dsendcom ||'/INF/MD/Global/Map/'||vr_dsverser||'" '
               ||'       xmlns:wsdl="'|| vr_dsendcom ||'/Cadastro/SS/'||vr_dsinterf||'/v0100/wsdl" '
               ||'       xmlns:v01="' || vr_dsendcom ||'/Cadastro/SS/'||vr_dsinterf||'/v0100" '
               ||'       xmlns:v12="' || vr_dsendcom ||'/INF/LCD/Global/'||vr_dsverser||'" '
               ||'       xmlns:v13="' || vr_dsendcom ||'/INF/MD/Global/TiposDados/'||vr_dsverser||'">'
               ||' <soapenv:Header>'
               ||'       <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" '
               ||'                      xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> '
               ||'           <wsse:UsernameToken wsu:Id="UsernameToken-6D7572901155436BA515082640657172">'
               ||'             <wsse:Username>'||vr_dsdeuser||'</wsse:Username>'
               ||'             <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'||vr_dsdepass||'</wsse:Password>'
               ||'           </wsse:UsernameToken>'
               ||'       </wsse:Security> '   
               ||'       <v1:msgHeader>'
               ||'       </v1:msgHeader>'
               ||' </soapenv:Header>'
               ||' <soapenv:Body>'
               ||'   <wsdl:'||vr_dsmetodo||'>'
               ||'   </wsdl:'||vr_dsmetodo||'>'
               ||' </soapenv:Body>'
               ||'</soapenv:Envelope>';        
    
    -- Criar cabeçalho do envelope SOAP
    pr_xml := xmltype.createxml(vr_clob);
    
    
    
    -- Retornar OK
    pr_des_erro := 'OK';
      
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_dscritic := 'Erro na PC_XMLSOAP_MONTA_ESTRUTURA: '||SQLERRM;
  END pc_xmlsoap_monta_estrutura;
  
  --> rotina para enviar requisição
  PROCEDURE pc_envia_requisicao (pr_cdservic  IN NUMBER       --> Chamve do Serviço requisitado
                                ,pr_cdmetodo  IN NUMBER       --> Chave do Método requisitado
                                ,pr_xml       IN xmltype      --> Objeto do XML criado
                                ,pr_cdcritic OUT VARCHAR2     --> codigo do ero
                                ,pr_dscritic OUT VARCHAR2     --> Descricao erro
                                ,pr_dsdetail OUT VARCHAR2) IS --> Retornar os detalhes da critica
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_envia_requisicao
    --  Sistema  : cecred
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : outubro/2017.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para gerar cabecalho de envelope soap
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
    ---------------> CURSORES <----------------- 
    
    ---------------> VARIAVEIS <----------------- 
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     NUMBER;
    vr_dssrdom      VARCHAR2(1000); -- Var para retorno do Service Domain
    vr_xml_res      XMLType; --> XML de resposta
    
  
  BEGIN
    
    vr_dssrdom := vr_dsendser||vr_wscip_services(pr_cdservic).dsservico||'/'||vr_dsverser;
    
    -- Enviar requisição para webservice
    SOAP0001.pc_cliente_webservice(pr_endpoint    => vr_dssrdom
                                  ,pr_acao        => NULL
                                  ,pr_wallet_path => NULL
                                  ,pr_wallet_pass => NULL
                                  ,pr_xml_req     => pr_xml
                                  ,pr_xml_res     => vr_xml_res
                                  ,pr_erro        => vr_dscritic);
    
    -- Verifica se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    --> Tratar retorno
    pc_valid_ret_soap ( pr_dsxmret  => vr_xml_res.getClobVal   --> XML para avaliar se houve erro
                       ,pr_cdcritic => vr_cdcritic             --> Retornar o código da crítica
                       ,pr_dscritic => vr_dscritic             --> descrição critica
                       ,pr_dsdetail => pr_dsdetail);           --> Retornar os detalhes da critica
                               
    IF nvl(vr_cdcritic,0) > 0 OR 
       vr_dscritic IS NOT NULL THEN
       vr_dscritic := 'Retorno webservice: '||vr_cdcritic||'-'||vr_dscritic;
       RAISE vr_exc_erro;
    END IF;   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      pr_cdcritic := vr_cdcritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na pc_envia_requisicao: '||SQLERRM;
  END pc_envia_requisicao;
  
                                  
BEGIN --> Corpo da package 

  --> Carregar temptable com os serviços do webservice para CRM
  IF vr_wscip_services.count() = 0 THEN 
    --> SERVIÇO: PAGADOR ELETRONICO
    vr_wscip_services(1).dsservico := 'ListaDominioInternoService';
    vr_wscip_services(1).dsinterfa := 'ListaDominioInterno';
    -- Métodos
    vr_wscip_services(1).tbmetodos(1)  := 'manterConteudoCRMRequest';    
    vr_wscip_services(1).tbmetodos(2)  := 'excluirConteudoCRMRequest';    
  END IF;  
  
  --> Inicializar valores padroes
  vr_dstextab := NULL;
  vr_dstextab := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => 0,
                                           pr_cdacesso => 'WEBCRM_ENDERECO');
  
  --> carregar endereço dos componentes
  vr_dsendcom := gene0002.fn_busca_entrada(1,vr_dstextab,';');
  --> carregar endereço do serviço
  vr_dsendser := gene0002.fn_busca_entrada(2,vr_dstextab,';');
  --> carregar versao
  vr_dsverser := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => 0,
                                           pr_cdacesso => 'WEBCRM_VERSAO');
  --> carregar usuario e senha do serviço
  vr_dstextab := NULL;
  vr_dstextab := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => 0,
                                           pr_cdacesso => 'WEBCRM_USER_ACESSO');
  vr_dsdeuser := gene0002.fn_busca_entrada(1,vr_dstextab,';');
  vr_dsdepass := gene0002.fn_busca_entrada(2,vr_dstextab,';');
  
  
  
                                      
END soap0002;
/
