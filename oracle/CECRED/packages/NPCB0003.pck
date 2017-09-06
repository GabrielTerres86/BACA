CREATE OR REPLACE PACKAGE CECRED.NPCB0003 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : NPCB0003
      Sistema  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos
      Sigla    : NPCB
      Autor    : Renato Darosci - Supero
      Data     : Dezembro/2016.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes ao WebService da Nova Plataforma de Cobrança de Boletos
  ---------------------------------------------------------------------------------------------------------------*/

  FUNCTION fn_url_SendSoapNPC (pr_idservic IN INTEGER ) 
                               RETURN VARCHAR2;
                              
  PROCEDURE  PC_TESTA_CONEXAO;
  -- Configurar a collection que conterá os campos que serão inclusos no SOAP
  TYPE typ_reg_campos_soap IS RECORD (dsNomTag   VARCHAR2(30)   --> Nome da TAG enviado no SOAP
                                     ,dsValTag   VARCHAR2(1000) --> Valor do TAG enviado no SOAP
                                     ,dsTypTag   VARCHAR2(10)); --> Tipo do valor enviado na TAG
  TYPE typ_tab_campos_soap IS TABLE OF typ_reg_campos_soap INDEX BY BINARY_INTEGER;
  
  -- Rotina para verificar se houve retorno de erro do Webservice - Fault Packet
  PROCEDURE pc_xmlsoap_fault_packet(pr_cdcooper  IN NUMBER            --> Código da cooperativa para registro de log
                                   ,pr_cdctrlcs  IN VARCHAR2 DEFAULT NULL --> Código de controle de consulta
                                   ,pr_dsxmlreq  IN CLOB DEFAULT NULL --> XML da requisição realizada
                                   ,pr_dsxmlerr  IN CLOB              --> XML para avaliar se houve erro
                                   ,pr_cdcritic OUT NUMBER            --> Retornar o código da crítica
                                   ,pr_dscritic OUT VARCHAR2);        --> Retornar a descrição da critica
  
  --> Rotina para converter o XML do titulo para a tabela de memória
  PROCEDURE pc_xmlsoap_extrair_titulo(pr_dsxmltit  IN CLOB                       --> XML de retorno
                                     ,pr_tbtitulo OUT NPCB0001.typ_reg_TituloCIP --> Collection com os dados do título
                                     ,pr_des_erro OUT VARCHAR2                   --> Indicador erro OK/NOK
                                     ,pr_dscritic OUT VARCHAR2);                 --> Descrição do erro
  
  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_wscip_requisitar_titulo(pr_cdcooper  IN NUMBER          --> Código da cooperativa
                                      ,pr_cdctrlcs  IN VARCHAR2        --> Identificador da consulta
                                      ,pr_cdbarras  IN VARCHAR2        --> Código de barras
                                      ,pr_dtmvtolt  IN DATE            --> Data de movimento
                                      ,pr_cdcidade  IN NUMBER          --> Código da cidade da tabela CAF
                                      ,pr_dsxmltit OUT CLOB            --> XML de retorno
                                      ,pr_tpconcip OUT NUMBER          --> Tipo de Consulta CIP
                                      ,pr_des_erro OUT VARCHAR2        --> Indicador erro OK/NOK
                                      ,pr_cdcritic OUT NUMBER          --> Código do erro
                                      ,pr_dscritic OUT VARCHAR2);      --> Descrição do erro


   /* Procedure para gerar o corpo do soap */
  PROCEDURE pc_xmlsoap_monta_estrutura(pr_cdservic  IN NUMBER  --> Chamve do Serviço requisitado
                                      ,pr_cdmetodo  IN NUMBER  --> Chave do Método requisitado
                                      ,pr_xml      OUT xmltype --> Objeto do XML criado
                                      ,pr_des_erro OUT VARCHAR2 --> Descricao erro OK/NOK
                                      ,pr_dscritic OUT VARCHAR2);--> Descricao erro
                                      
  /* Procedure para incluir as tags comuns (SE NECESSÁRIAS) no XML */
  PROCEDURE pc_xmlsoap_tag_padrao(pr_tbcampos IN OUT NPCB0003.typ_tab_campos_soap
                                 ,pr_des_erro OUT VARCHAR2    --> Identificador erro OK/NOK
                                 ,pr_dscritic OUT VARCHAR2);  --> Descrição erro                                      
                                 
  /* Procedure para incluir os campos e montar a requisição */
  PROCEDURE pc_xmlsoap_monta_requisicao(pr_cdservic  IN NUMBER        --> Chamve do Serviço requisitado
                                       ,pr_cdmetodo  IN NUMBER        --> Chave do Método requisitado
                                       ,pr_tbcampos  IN NPCB0003.typ_tab_campos_soap --> tabela com as tags
                                       ,pr_xml      OUT xmltype       --> Objeto do XML criado
                                       ,pr_des_erro OUT VARCHAR2      --> Descricao erro OK/NOK
                                       ,pr_dscritic OUT VARCHAR2);    --> Descricao erro  
                                       
  --> Rotina para listar títulos do pagador
  PROCEDURE pc_wscip_listar_titulo(pr_tppessoa  IN VARCHAR2        --> Tipo da pessoa (F/J)
                                  ,pr_nrcpfcgc  IN NUMBER          --> Número do documento do pagador
                                  ,pr_dsxmlret OUT CLOB            --> XML de retorno
                                  ,pr_des_erro OUT VARCHAR2        --> Indicador erro OK/NOK
                                  ,pr_cdcritic OUT NUMBER          --> Código do erro
                                  ,pr_dscritic OUT VARCHAR2);      --> Descrição do erro                               

  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_wscip_requisitar_baixa(pr_cdcooper  IN NUMBER             --> Código da cooperativa
                                     ,pr_dtmvtolt  IN DATE               --> data de movimento
                                     ,pr_dscodbar  IN VARCHAR2           --> Codigo de barra
                                     ,pr_cdctrlcs  IN VARCHAR2           --> Identificador da consulta
                                     ,pr_idtitdda  IN NUMBER             --> Identificador Titulo DDA
                                     ,pr_tituloCIP IN npcb0001.typ_reg_TituloCIP --> Dados do titulo na CIP
                                     ,pr_flmobile  IN NUMBER             --> Indicador do Mobile
                                     --,pr_xml_frag OUT NOCOPY xmltype     --> Fragmento do XML de retorno
                                     ,pr_des_erro OUT VARCHAR2           --> Indicador erro OK/NOK
                                     ,pr_dscritic OUT VARCHAR2);         --> Descricao erro

END NPCB0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.NPCB0003 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : NPCB0003
      Sistema  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos
      Sigla    : NPCB
      Autor    : Renato Darosci - Supero
      Data     : Dezembro/2016.                   Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas de transações da Nova Plataforma de Cobrança de Boletos

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  -- Declaração de variáveis/constantes gerais
  vr_usercip         CONSTANT VARCHAR2(20) := 'u'; -- 'anonymous';
  vr_passcip         CONSTANT VARCHAR2(20) := 's';
  vr_dsarqlg         CONSTANT VARCHAR2(20) := 'npc_'||to_char(SYSDATE,'RRRRMM')||'.log'; -- nome do arquivo de log mensal
  vr_datetimeformat  CONSTANT VARCHAR2(30) := 'YYYY-MM-DD"T"HH24:MI:SS';
  vr_dateformat      CONSTANT VARCHAR2(10) := 'YYYY-MM-DD';
  
  --> Declaração geral de exception
  vr_exc_erro    EXCEPTION;
  
  /* COLECTION DESTINADA A CONTER OS SERVIÇOS DO WEBSERVICE */
  TYPE typ_tab_metodos IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  TYPE typ_rec_servico IS RECORD (dsservico  VARCHAR2(50)
                                 ,dsinterfa  VARCHAR2(50)
                                 ,tbmetodos  typ_tab_metodos);
  TYPE typ_tab_wscip   IS TABLE OF typ_rec_servico INDEX BY BINARY_INTEGER;
  vr_wscip_services    typ_tab_wscip;
  /**********************************************************/
  

  FUNCTION fn_url_SendSoapNPC (pr_idservic IN INTEGER ) 
                              RETURN VARCHAR2 IS
  
    vr_dssrdom VARCHAR2(4000);
  BEGIN
  
    /************* MONTAR O LINK DE ACESSO AO SERVIÇO DO WEBSERVICE *************/
    -- Busca o service domain conforme parâmetro NPC_SERVICE_DOMAIN
    vr_dssrdom := 'http://'||gene0001.fn_param_sistema('CRED'
                                                      ,0
                                                      ,'NPC_SERVICE_DOMAIN');
    vr_dssrdom := vr_dssrdom
               || '/JDNPC_WEB/JDNPCWS_'
               || NPCB0003.vr_wscip_services(pr_idservic).dsservico
               || '.dll/soap/'||NPCB0003.vr_wscip_services(pr_idservic).dsinterfa; -- wsdl
    /************* MONTAR O LINK DE ACESSO AO SERVIÇO DO WEBSERVICE *************/
    RETURN vr_dssrdom;
  EXCEPTION  
    WHEN OTHERS THEN
      RETURN NULL;
  END;


PROCEDURE  PC_TESTA_CONEXAO IS
   
  pr_requisicao   UTL_HTTP.REQ;     --> Objeto HTTP para requisição
  vr_endpoint     VARCHAR2(100) := 'http://0302npcwts03/JDNPC_WEB/JDNPCWS_RecebimentoPgtoTit.dll/wsdl/IJDNPCWS_RecebimentoPgtoTit';
  pr_erro         VARCHAR2(1000);
BEGIN 
  pr_requisicao := UTL_HTTP.begin_request(vr_endpoint, 'POST','HTTP/1.0');

EXCEPTION
  WHEN utl_http.request_failed THEN
    pr_erro := 'REQUEST_FAILED: ' || UTL_HTTP.get_detailed_sqlerrm;
    dbms_output.put_line(pr_erro);
  WHEN utl_http.http_server_error THEN
    pr_erro := 'HTTP_SERVER_ERROR: ' || UTL_HTTP.get_detailed_sqlerrm;
    dbms_output.put_line(pr_erro);
  WHEN utl_http.http_client_error THEN
    pr_erro := 'HTTP_CLIENT_ERROR: ' || UTL_HTTP.get_detailed_sqlerrm;
    dbms_output.put_line(pr_erro);
  WHEN OTHERS THEN
    pr_erro := 'ERRO: ' || SQLERRM;
    dbms_output.put_line(pr_erro);
END;
  
  -- Rotina para verificar se houve retorno de erro do Webservice - Fault Packet
  PROCEDURE pc_xmlsoap_fault_packet(pr_cdcooper  IN NUMBER            --> Código da cooperativa para registro de log
                                   ,pr_cdctrlcs  IN VARCHAR2 DEFAULT NULL --> Código de controle de consulta
                                   ,pr_dsxmlreq  IN CLOB DEFAULT NULL --> XML da requisição realizada
                                   ,pr_dsxmlerr  IN CLOB              --> XML para avaliar se houve erro
                                   ,pr_cdcritic OUT NUMBER            --> Retornar o código da crítica
                                   ,pr_dscritic OUT VARCHAR2) IS      --> Retornar a descrição da critica
    
    /* ..........................................................................

      Programa : pc_xmlsoap_fault_packet
      Sistema  : Cobrança - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Renato Darosci(Supero)
      Data     : Janeiro/2016.                   Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para verificar se houve critica de retorno via SOUP e em
                  caso afirmativo, retornar a mesma.

      Alteração :
    ..........................................................................*/
  
    -- Extrair erros do XML
    CURSOR cr_faultpacket IS
      WITH DATA AS (SELECT pr_dsxmlerr xml FROM dual)
      SELECT faultcode
           , faultstring
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'SOAP-ENV:Fault' AS "fault")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/SOAP-ENV:Fault'
                      PASSING XMLTYPE(xml)
                      COLUMNS faultcode   VARCHAR2(25)   PATH 'faultcode'
                            , faultstring VARCHAR2(1000) PATH 'faultstring');
    
    -- VARIÁVEIS
    vr_cdauxcri     VARCHAR2(25);
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);
    vr_idlogarq     crapprm.dsvlrprm%TYPE;
    
  BEGIN
    
    -- Buscar a critica no XML
    OPEN  cr_faultpacket;
    FETCH cr_faultpacket INTO vr_cdauxcri
                            , vr_dscritic;
    
    -- Se não retornou nenhum registro
    IF cr_faultpacket%NOTFOUND THEN
      -- Não retornar crítica
      pr_cdcritic := 0;
      pr_dscritic := NULL;
    ELSE
      
      BEGIN
        -- Converter código de erro
        vr_cdcritic := ABS(TO_NUMBER(substr(vr_cdauxcri,INSTR(vr_cdauxcri,':')+1)));
      EXCEPTION 
        WHEN OTHERS THEN
          -- Caso houver erro... é porque não retornou código numerico, neste caso retornar zero
          vr_cdcritic := 0;
      END;
    
      -- Buscar parametro de geração de log
      vr_idlogarq := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'NPC_LOG_FAULTPACKET');
      
      -- Se estiver indicando a geracão de log em arquivo
      IF NVL(vr_idlogarq,'0') = '1' THEN
        -- Bloco para escrever log de eventos NPB
        BEGIN
          -- Se o XML da requisição foi informado
          IF pr_dsxmlreq IS NOT NULL THEN
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_des_log      => to_char(sysdate,'DD/MM/YYYY - HH24:MI:SS')||' - '
                                                        || 'FAULT PACKET --> '
                                                        || '['||pr_cdctrlcs||'] '
                                                        || pr_dsxmlreq
                                       ,pr_nmarqlog     => vr_dsarqlg);
          END IF;
        
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'DD/MM/YYYY - HH24:MI:SS')||' - '
                                                      || 'FAULT PACKET --> '
                                                      || '['||pr_cdctrlcs||'] '
                                                      || vr_cdcritic||' - '
                                                      || vr_dscritic
                                     ,pr_nmarqlog     => vr_dsarqlg);
        
        EXCEPTION
          WHEN OTHERS THEN
            NULL; -- Não impactar no processo em caso de erro
        END;
      END IF;
      
      -- Retornar a crítica encontrada
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    END IF;
    
    -- Fechar o cursor antes de encerrar a rotina
    CLOSE cr_faultpacket;
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_dscritic := 'Erro ao verificar Fault Packet: '||SQLERRM;
  END pc_xmlsoap_fault_packet;
  
  --> Rotina para converter o XML do titulo para a tabela de memória
  PROCEDURE pc_xmlsoap_extrair_titulo(pr_dsxmltit  IN CLOB                       --> XML de retorno
                                     ,pr_tbtitulo OUT NPCB0001.typ_reg_TituloCIP --> Collection com os dados do título
                                     ,pr_des_erro OUT VARCHAR2                   --> Indicador erro OK/NOK
                                     ,pr_dscritic OUT VARCHAR2) IS               --> Descrição do erro
  
    /* ..........................................................................

      Programa : pc_convert_xmlsoap
      Sistema  : Cobrança - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Renato Darosci(Supero)
      Data     : Dezembro/2016.                   Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para converter o xml retornado via webservice em collection

      Alteração :
    ..........................................................................*/
  
    -- Cursor para ler todos os nodos que não possuem iteração
    CURSOR cr_dadostitulo IS
      WITH DATA AS (SELECT pr_dsxmltit xml FROM dual)
      SELECT NumCtrlPart
           , ISPBPartRecbdrPrincipal
           , ISPBPartRecebdrAdmtd
           , NumIdentcTit
           , NumRefAtlCadTit
           , TO_DATE(DtHrSitTit, vr_datetimeformat) DtHrSitTit 
           , ISPBPartDestinatario
           , CodPartDestinatario
           , TpPessoaBenfcrioOr
           , CNPJ_CPFBenfcrioOr
           , Nom_RzSocBenfcrioOr
           , NomFantsBenfcrioOr
           , LogradBenfcrioOr
           , CidBenfcrioOr
           , UFBenfcrioOr
           , CEPBenfcrioOr
           , TpPessoaBenfcrioFinl
           , CNPJ_CPFBenfcrioFinl
           , Nom_RzSocBenfcrioFinl  
           , NomFantsBenfcrioFinl  
           , TpPessoaPagdr      
           , CNPJ_CPFPagdr      
           , Nom_RzSocPagdr      
           , NomFantsPagdr      
           , CodMoedaCNAB      
           , NumCodBarras      
           , NumLinhaDigtvl      
           , TO_DATE(DtVencTit, vr_dateformat) DtVencTit
           , NPCB0001.fn_convert_number(VlrTit)   VlrTit 
           , CodEspTit        
           , QtdDiaPrott      
           , TO_DATE(DtLimPgtoTit,vr_dateformat) DtLimPgtoTit
           , IndrBloqPgto      
           , IndrPgtoParcl      
           , QtdPgtoParcl      
           , NPCB0001.fn_convert_number(VlrAbattTit) VlrAbattTit
           
           
           , IndrVlr_PercMinTit  
           , NPCB0001.fn_convert_number(Vlr_PercMinTit)    Vlr_PercMinTit
           , IndrVlr_PercMaxTit  
           , NPCB0001.fn_convert_number(Vlr_PercMaxTit)  Vlr_PercMaxTit
           , TpModlCalc      
           , TpAutcRecbtVlrDivgte
           , QtdPgtoParclRegtd
           , NPCB0001.fn_convert_number(VlrSldTotAtlPgtoTit)  VlrSldTotAtlPgtoTit
           , SitTitPgto
           , TO_DATE(DtValiddCalcJD, vr_dateformat) DtValiddCalcJD
           , NPCB0001.fn_convert_number(VlrCalcdJDAbatt)          VlrCalcdJDAbatt    
           , NPCB0001.fn_convert_number(VlrCalcdJDJuros)          VlrCalcdJDJuros    
           , NPCB0001.fn_convert_number(VlrCalcdJDMulta)          VlrCalcdJDMulta    
           , NPCB0001.fn_convert_number(VlrCalcdJDDesct)          VlrCalcdJDDesct    
           , NPCB0001.fn_convert_number(VlrCalcdJDTotCobrar)      VlrCalcdJDTotCobrar
           , NPCB0001.fn_convert_number(VlrCalcdJDMin)            VlrCalcdJDMin      
           , NPCB0001.fn_convert_number(VlrCalcdJDMax)            VlrCalcdJDMax      
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPCWS_RecebimentoPgtoTitIntf-IJDNPCWS_RecebimentoPgtoTit' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:*/return/*'
                      PASSING XMLTYPE(xml)
                      COLUMNS NumCtrlPart             VARCHAR2(20) PATH 'NumCtrlPart'
                            , ISPBPartRecbdrPrincipal NUMBER       PATH 'ISPBPartRecbdrPrincipal'
                            , ISPBPartRecebdrAdmtd    NUMBER       PATH 'ISPBPartRecebdrAdmtd'
                            , NumIdentcTit            NUMBER       PATH 'NumIdentcTit'
                            , NumRefAtlCadTit         NUMBER       PATH 'NumRefAtlCadTit'
                            , DtHrSitTit              VARCHAR2(20) PATH 'DtHrSitTit'
                            , ISPBPartDestinatario    NUMBER       PATH 'ISPBPartDestinatario'
                            , CodPartDestinatario     VARCHAR2(3)  PATH 'CodPartDestinatario'
                            , TpPessoaBenfcrioOr      VARCHAR2(1)  PATH 'TpPessoaBenfcrioOr'
                            , CNPJ_CPFBenfcrioOr      NUMBER       PATH 'CNPJ_CPFBenfcrioOr'
                            , Nom_RzSocBenfcrioOr     VARCHAR2(50) PATH 'Nom_RzSocBenfcrioOr'
                            , NomFantsBenfcrioOr      VARCHAR2(80) PATH 'NomFantsBenfcrioOr'
                            , LogradBenfcrioOr        VARCHAR2(40) PATH 'LogradBenfcrioOr'
                            , CidBenfcrioOr           VARCHAR2(50) PATH 'CidBenfcrioOr'
                            , UFBenfcrioOr            VARCHAR2(2)  PATH 'UFBenfcrioOr'
                            , CEPBenfcrioOr           NUMBER       PATH 'CEPBenfcrioOr'
                            , TpPessoaBenfcrioFinl    VARCHAR2(1)  PATH 'TpPessoaBenfcrioFinl'
                            , CNPJ_CPFBenfcrioFinl    NUMBER       PATH 'CNPJ_CPFBenfcrioFinl'
                            , Nom_RzSocBenfcrioFinl   VARCHAR2(50) PATH 'Nom_RzSocBenfcrioFinl'
                            , NomFantsBenfcrioFinl    VARCHAR2(80) PATH 'NomFantsBenfcrioFinl'
                            , TpPessoaPagdr           VARCHAR2(1)  PATH 'TpPessoaPagdr'
                            , CNPJ_CPFPagdr           NUMBER       PATH 'CNPJ_CPFPagdr'
                            , Nom_RzSocPagdr          VARCHAR2(50) PATH 'Nom_RzSocPagdr'
                            , NomFantsPagdr           VARCHAR2(80) PATH 'NomFantsPagdr'
                            , CodMoedaCNAB            VARCHAR2(2)  PATH 'CodMoedaCNAB'
                            , NumCodBarras            VARCHAR2(44) PATH 'NumCodBarras'
                            , NumLinhaDigtvl          VARCHAR2(47) PATH 'NumLinhaDigtvl'
                            , DtVencTit               VARCHAR2(10) PATH 'DtVencTit'
                            , VlrTit                  VARCHAR2(20) PATH 'VlrTit'
                            , CodEspTit               VARCHAR2(2)  PATH 'CodEspTit'
                            , QtdDiaPrott             NUMBER       PATH 'QtdDiaPrott'
                            , DtLimPgtoTit            VARCHAR2(10) PATH 'DtLimPgtoTit'
                            , IndrBloqPgto            VARCHAR2(1)  PATH 'IndrBloqPgto'
                            , IndrPgtoParcl           VARCHAR2(1)  PATH 'IndrPgtoParcl'
                            , QtdPgtoParcl            NUMBER       PATH 'QtdPgtoParcl'
                            , VlrAbattTit             VARCHAR2(20) PATH 'VlrAbattTit'
                            , IndrVlr_PercMinTit      VARCHAR2(1)  PATH 'IndrVlr_PercMinTit'
                            , Vlr_PercMinTit          VARCHAR2(20) PATH 'Vlr_PercMinTit'
                            , IndrVlr_PercMaxTit      VARCHAR2(1)  PATH 'IndrVlr_PercMaxTit'
                            , Vlr_PercMaxTit          VARCHAR2(20) PATH 'Vlr_PercMaxTit'
                            , TpModlCalc              VARCHAR2(2)  PATH 'TpModlCalc'
                            , TpAutcRecbtVlrDivgte    VARCHAR2(1)  PATH 'TpAutcRecbtVlrDivgte'
                            , QtdPgtoParclRegtd       NUMBER       PATH 'QtdPgtoParclRegtd'
                            , VlrSldTotAtlPgtoTit     VARCHAR2(20) PATH 'VlrSldTotAtlPgtoTit'
                            , SitTitPgto              VARCHAR2(2)  PATH 'SitTitPgto'
                            , DtValiddCalcJD          VARCHAR2(10) PATH 'DtValiddCalcJD'
                            , VlrCalcdJDAbatt         VARCHAR2(20) PATH 'VlrCalcdJDAbatt'
                            , VlrCalcdJDJuros         VARCHAR2(20) PATH 'VlrCalcdJDJuros'
                            , VlrCalcdJDMulta         VARCHAR2(20) PATH 'VlrCalcdJDMulta'
                            , VlrCalcdJDDesct         VARCHAR2(20) PATH 'VlrCalcdJDDesct'
                            , VlrCalcdJDTotCobrar     VARCHAR2(20) PATH 'VlrCalcdJDTotCobrar'
                            , VlrCalcdJDMin           VARCHAR2(20) PATH 'VlrCalcdJDMin'
                            , VlrCalcdJDMax           VARCHAR2(20) PATH 'VlrCalcdJDMax') ;
    rw_dadostitulo    cr_dadostitulo%ROWTYPE;
    
    -- Cursor para ler os juros do título
    CURSOR cr_jurostit IS
      WITH DATA AS (SELECT pr_dsxmltit xml FROM dual)
      SELECT ROWNUM   idregist
           , TO_DATE(DtJurosTit, vr_dateformat) DtJurosTit      
           , CodJurosTit   
           , NPCB0001.fn_convert_number(Vlr_PercJurosTit)  Vlr_PercJurosTit
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPCWS_RecebimentoPgtoTitIntf-IJDNPCWS_RecebimentoPgtoTit' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:*/return/*/JurosTit'
                      PASSING XMLTYPE(xml)
                      COLUMNS DtJurosTit              VARCHAR2(10) PATH 'DtJurosTit'
                            , CodJurosTit             VARCHAR2(1)  PATH 'CodJurosTit'
                            , Vlr_PercJurosTit        VARCHAR2(20) PATH 'Vlr_PercJurosTit');
    rw_jurostit cr_jurostit%ROWTYPE;
    
    -- Cursor para ler os juros do título
    CURSOR cr_multatit IS
      WITH DATA AS (SELECT pr_dsxmltit xml FROM dual)
      SELECT ROWNUM   idregist
           , TO_DATE(DtMultaTit, vr_dateformat) DtMultaTit      
           , CodMultaTit     
           , NPCB0001.fn_convert_number(Vlr_PercMultaTit)  Vlr_PercMultaTit
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPCWS_RecebimentoPgtoTitIntf-IJDNPCWS_RecebimentoPgtoTit' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:*/return/*/MultaTit'
                      PASSING XMLTYPE(xml)
                      COLUMNS DtMultaTit              VARCHAR2(10) PATH 'DtMultaTit'
                            , CodMultaTit             VARCHAR2(1)  PATH 'CodMultaTit'
                            , Vlr_PercMultaTit        VARCHAR2(20) PATH 'Vlr_PercMultaTit');
    rw_multatit cr_multatit%ROWTYPE;
    
    
    -- Cursor para ler os descontos do título
    CURSOR cr_desctitulo IS
      WITH DATA AS (SELECT pr_dsxmltit xml FROM dual)
      SELECT ROWNUM   idregist
           , TO_DATE(DtDesctTit, vr_dateformat) DtDesctTit
           , CodDesctTit
           , NPCB0001.fn_convert_number(Vlr_PercDesctTit) Vlr_PercDesctTit
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPCWS_RecebimentoPgtoTitIntf-IJDNPCWS_RecebimentoPgtoTit' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:*/return/*/RepetDesctTit/DesctTit'
                      PASSING XMLTYPE(xml)
                      COLUMNS DtDesctTit       VARCHAR2(100) PATH 'DtDesctTit'
                            , CodDesctTit      VARCHAR2(10)  PATH 'CodDesctTit'
                            , Vlr_PercDesctTit VARCHAR2(200) PATH 'Vlr_PercDesctTit');

    -- Cursor para ler os valores calculados do boleto
    CURSOR cr_valorestitulo IS
      WITH DATA AS (SELECT pr_dsxmltit xml FROM dual)
      SELECT ROWNUM  idregist
           , TO_DATE(DtValiddCalc,vr_dateformat)            DtValiddCalc  
           , CdMunicipio                                    CdMunicipio
           , TO_DATE(DtCalcdVencTit,vr_dateformat)          DtCalcdVencTit
           , NPCB0001.fn_convert_number(VlrCalcdAbatt)      VlrCalcdAbatt
           , NPCB0001.fn_convert_number(VlrCalcdJuros)            VlrCalcdJuros
           , NPCB0001.fn_convert_number(VlrCalcdMulta)            VlrCalcdMulta
           , NPCB0001.fn_convert_number(VlrCalcdDesct)            VlrCalcdDesct
           , NPCB0001.fn_convert_number(VlrTotCobrar )            VlrTotCobrar 
           , NPCB0001.fn_convert_number(VlrCalcdMin  )      VlrCalcdMin
           , NPCB0001.fn_convert_number(VlrCalcdMax  )      VlrCalcdMax
           
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPCWS_RecebimentoPgtoTitIntf-IJDNPCWS_RecebimentoPgtoTit' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:*/return/*/JDCalcTit'
                      PASSING XMLTYPE(xml)
                      COLUMNS   DtValiddCalc  VARCHAR2(10) PATH 'DtValiddCalcJD'
                              , CdMunicipio   VARCHAR2(20) PATH 'CdMunicipio'
                              , DtCalcdVencTit VARCHAR2(20) PATH 'DtCalcdJDVencTit'
                              , VlrCalcdAbatt VARCHAR2(20) PATH 'VlrCalcdJDAbatt'    
                              , VlrCalcdJuros VARCHAR2(20) PATH 'VlrCalcdJDJuros'
                              , VlrCalcdMulta VARCHAR2(20) PATH 'VlrCalcdJDMulta'
                              , VlrCalcdDesct VARCHAR2(20) PATH 'VlrCalcdJDDesct'    
                              , VlrTotCobrar  VARCHAR2(20) PATH 'VlrCalcdJDTotCobrar'
                              , VlrCalcdMin   VARCHAR2(20) PATH 'VlrCalcdJDMin'
                              , VlrCalcdMax   VARCHAR2(20) PATH 'VlrCalcdJDMax');
                            
    
    
    
    -- Cursor para ler as baixas operacionais
    CURSOR cr_baixaoperacional IS
      WITH DATA AS (SELECT pr_dsxmltit xml FROM dual)
      SELECT ROWNUM  idregist
           , NPCB0001.fn_convert_number(NumIdentcBaixaOperac)  NumIdentcBaixaOperac    
           , NPCB0001.fn_convert_number(NumRefAtlBaixaOperac)  NumRefAtlBaixaOperac   
           , NPCB0001.fn_convert_number(NumSeqAtlzBaixaOperac) NumSeqAtlzBaixaOperac  
           , TO_DATE(DtProcBaixaOperac,vr_dateformat)             DtProcBaixaOperac      
           , TO_DATE(DtHrProcBaixaOperac,vr_datetimeformat)   DtHrProcBaixaOperac    
           , TO_DATE(DtHrSitBaixaOperac,vr_datetimeformat)    DtHrSitBaixaOperac     
           , NPCB0001.fn_convert_number(VlrBaixaOperacTit)     VlrBaixaOperacTit      
           , NumCodBarrasBaixaOperac                           NumCodBarrasBaixaOperac
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPCWS_RecebimentoPgtoTitIntf-IJDNPCWS_RecebimentoPgtoTit' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:*/return/*/RepetBaixaOperac/BaixaOperac'
                      PASSING XMLTYPE(xml)
                      COLUMNS NumIdentcBaixaOperac    NUMBER       PATH 'NumIdentcBaixaOperac'
                            , NumRefAtlBaixaOperac    NUMBER       PATH 'NumRefAtlBaixaOperac'
                            , NumSeqAtlzBaixaOperac   NUMBER       PATH 'NumSeqAtlzBaixaOperac'
                            , DtProcBaixaOperac       VARCHAR2(10) PATH 'DtProcBaixaOperac'
                            , DtHrProcBaixaOperac     VARCHAR2(30) PATH 'DtHrProcBaixaOperac'
                            , DtHrSitBaixaOperac      VARCHAR2(30) PATH 'DtHrSitBaixaOperac'
                            , VlrBaixaOperacTit       VARCHAR2(20) PATH 'VlrBaixaOperacTit'
                            , NumCodBarrasBaixaOperac VARCHAR2(44) PATH 'NumCodBarrasBaixaOperac');
    
    -- Cursor para ler as baixas operacionais
    CURSOR cr_baixaefetiva IS
      WITH DATA AS (SELECT pr_dsxmltit  xml FROM dual)
      SELECT ROWNUM  idregist
           , NPCB0001.fn_convert_number(NumIdentcBaixaEft)  NumIdentcBaixaEft    
           , NPCB0001.fn_convert_number(NumRefAtlBaixaEft)  NumRefAtlBaixaEft   
           , NPCB0001.fn_convert_number(NumSeqAtlzBaixaEft) NumSeqAtlzBaixaEft  
           , TO_DATE(DtProcBaixaEft,vr_dateformat)          DtProcBaixaEft      
           , TO_DATE(DtHrProcBaixaEft,vr_datetimeformat)    DtHrProcBaixaEft    
           , NPCB0001.fn_convert_number(VlrBaixaEftTit)     VlrBaixaEftTit      
           , NumCodBarrasBaixaEft                           NumCodBarrasBaixaEft
           , CanPgto                                        CanPgto
           , MeioPgto                                       MeioPgto
           , TO_DATE(DtHrSitBaixaEft,vr_datetimeformat)     DtHrSitBaixaEft
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPCWS_RecebimentoPgtoTitIntf-IJDNPCWS_RecebimentoPgtoTit' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:*/return/*/RepetBaixaEft/BaixaEft'
                      PASSING XMLTYPE(xml)
                      COLUMNS NumIdentcBaixaEft    NUMBER       PATH 'NumIdentcBaixaEft' 
                            , NumRefAtlBaixaEft    NUMBER       PATH 'NumRefAtlBaixaEft'  
                            , NumSeqAtlzBaixaEft   NUMBER       PATH 'NumSeqAtlzBaixaEft'  
                            , DtProcBaixaEft       VARCHAR2(10) PATH 'DtProcBaixaEft'
                            , DtHrProcBaixaEft     VARCHAR2(30) PATH 'DtHrProcBaixaEft'
                            , VlrBaixaEftTit       VARCHAR2(20) PATH 'VlrBaixaEftTit'
                            , NumCodBarrasBaixaEft VARCHAR2(44) PATH 'NumCodBarrasBaixaEft'
                            , CanPgto              NUMBER       PATH 'CanPgto'
                            , MeioPgto             NUMBER       PATH 'MeioPgto'
                            , DtHrSitBaixaEft      VARCHAR2(30) PATH 'DtHrSitBaixaEft');
                          
  BEGIN
    
    -- Inicializar indicando que a rotina não foi concluída
    pr_des_erro := 'NOK';
  
    -- Busca o registro contendo os dados extraídos do XML
    OPEN  cr_dadostitulo;
    FETCH cr_dadostitulo INTO rw_dadostitulo;
    
    -- Se não retornar o registro
    IF cr_dadostitulo%NOTFOUND THEN
      -- Gerar Erro
      pr_dscritic := 'Não foi possível extrair dados do XML.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fecha o cursor     
    CLOSE cr_dadostitulo;
  
    -- Garantir que não há informações no registro
    pr_tbtitulo := NULL;
    
    -- Incluir as informações do XML no registro
    pr_tbtitulo.NumCtrlPart             := rw_dadostitulo.NumCtrlPart;
    pr_tbtitulo.ISPBPartRecbdrPrincipal := rw_dadostitulo.ISPBPartRecbdrPrincipal;
    pr_tbtitulo.ISPBPartRecebdrAdmtd    := rw_dadostitulo.ISPBPartRecebdrAdmtd;
    pr_tbtitulo.NumIdentcTit            := rw_dadostitulo.NumIdentcTit;
    pr_tbtitulo.NumRefAtlCadTit         := rw_dadostitulo.NumRefAtlCadTit;
    pr_tbtitulo.DtHrSitTit              := rw_dadostitulo.DtHrSitTit;
    pr_tbtitulo.ISPBPartDestinatario    := rw_dadostitulo.ISPBPartDestinatario;
    pr_tbtitulo.CodPartDestinatario     := rw_dadostitulo.CodPartDestinatario;
    pr_tbtitulo.TpPessoaBenfcrioOr      := rw_dadostitulo.TpPessoaBenfcrioOr;
    pr_tbtitulo.CNPJ_CPFBenfcrioOr      := rw_dadostitulo.CNPJ_CPFBenfcrioOr;
    pr_tbtitulo.Nom_RzSocBenfcrioOr     := rw_dadostitulo.Nom_RzSocBenfcrioOr;
    pr_tbtitulo.NomFantsBenfcrioOr      := rw_dadostitulo.NomFantsBenfcrioOr;
    pr_tbtitulo.LogradBenfcrioOr        := rw_dadostitulo.LogradBenfcrioOr;
    pr_tbtitulo.CidBenfcrioOr           := rw_dadostitulo.CidBenfcrioOr;
    pr_tbtitulo.UFBenfcrioOr            := rw_dadostitulo.UFBenfcrioOr;
    pr_tbtitulo.CEPBenfcrioOr           := rw_dadostitulo.CEPBenfcrioOr;
    pr_tbtitulo.TpPessoaBenfcrioFinl    := rw_dadostitulo.TpPessoaBenfcrioFinl;
    pr_tbtitulo.CNPJ_CPFBenfcrioFinl    := rw_dadostitulo.CNPJ_CPFBenfcrioFinl;
    pr_tbtitulo.Nom_RzSocBenfcrioFinl   := rw_dadostitulo.Nom_RzSocBenfcrioFinl;
    pr_tbtitulo.NomFantsBenfcrioFinl    := rw_dadostitulo.NomFantsBenfcrioFinl;
    pr_tbtitulo.TpPessoaPagdr           := rw_dadostitulo.TpPessoaPagdr;
    pr_tbtitulo.CNPJ_CPFPagdr           := rw_dadostitulo.CNPJ_CPFPagdr;
    pr_tbtitulo.Nom_RzSocPagdr          := rw_dadostitulo.Nom_RzSocPagdr;
    pr_tbtitulo.NomFantsPagdr           := rw_dadostitulo.NomFantsPagdr;
    pr_tbtitulo.CodMoedaCNAB            := rw_dadostitulo.CodMoedaCNAB;
    pr_tbtitulo.NumCodBarras            := rw_dadostitulo.NumCodBarras;
    pr_tbtitulo.NumLinhaDigtvl          := rw_dadostitulo.NumLinhaDigtvl;
    pr_tbtitulo.DtVencTit               := rw_dadostitulo.DtVencTit;
    pr_tbtitulo.VlrTit                  := rw_dadostitulo.VlrTit;
    pr_tbtitulo.CodEspTit               := rw_dadostitulo.CodEspTit;
    pr_tbtitulo.QtdDiaPrott             := rw_dadostitulo.QtdDiaPrott;
    pr_tbtitulo.DtLimPgtoTit            := rw_dadostitulo.DtLimPgtoTit;
    pr_tbtitulo.IndrBloqPgto            := rw_dadostitulo.IndrBloqPgto;
    pr_tbtitulo.IndrPgtoParcl           := rw_dadostitulo.IndrPgtoParcl;
    pr_tbtitulo.QtdPgtoParcl            := rw_dadostitulo.QtdPgtoParcl;
    pr_tbtitulo.VlrAbattTit             := rw_dadostitulo.VlrAbattTit;
    
    
    pr_tbtitulo.IndrVlr_PercMinTit      := rw_dadostitulo.IndrVlr_PercMinTit;
    pr_tbtitulo.Vlr_PercMinTit          := rw_dadostitulo.Vlr_PercMinTit;
    pr_tbtitulo.IndrVlr_PercMaxTit      := rw_dadostitulo.IndrVlr_PercMaxTit;
    pr_tbtitulo.Vlr_PercMaxTit          := rw_dadostitulo.Vlr_PercMaxTit;
    pr_tbtitulo.TpModlCalc              := rw_dadostitulo.TpModlCalc;
    pr_tbtitulo.TpAutcRecbtVlrDivgte    := rw_dadostitulo.TpAutcRecbtVlrDivgte;
    pr_tbtitulo.QtdPgtoParclRegtd       := rw_dadostitulo.QtdPgtoParclRegtd;
    pr_tbtitulo.VlrSldTotAtlPgtoTit     := rw_dadostitulo.VlrSldTotAtlPgtoTit;
    pr_tbtitulo.SitTitPgto              := rw_dadostitulo.SitTitPgto;
   
    -- Limpar e carregar as informações de descontos de títulos
    pr_tbtitulo.TabDesctTit.DELETE();
    
    OPEN cr_jurostit;
    FETCH cr_jurostit INTO rw_jurostit;
    CLOSE cr_jurostit; 
    
    pr_tbtitulo.DtJurosTit              := rw_jurostit.DtJurosTit;
    pr_tbtitulo.CodJurosTit             := rw_jurostit.CodJurosTit;
    pr_tbtitulo.Vlr_PercJurosTit        := rw_jurostit.Vlr_PercJurosTit;
    
    OPEN cr_multatit;
    FETCH cr_multatit INTO rw_multatit;
    CLOSE cr_multatit; 
    
    pr_tbtitulo.DtMultaTit              := rw_multatit.DtMultaTit;
    pr_tbtitulo.CodMultaTit             := rw_multatit.CodMultaTit;
    pr_tbtitulo.Vlr_PercMultaTit        := rw_multatit.Vlr_PercMultaTit;
    
    
    -- Percorrer os descontos do título
    FOR rw_desctitulo IN cr_desctitulo LOOP
      -- Popular os dados
      pr_tbtitulo.TabDesctTit(rw_desctitulo.idregist).DtDesctTit       := rw_desctitulo.DtDesctTit;    
      pr_tbtitulo.TabDesctTit(rw_desctitulo.idregist).CodDesctTit      := rw_desctitulo.CodDesctTit;
      pr_tbtitulo.TabDesctTit(rw_desctitulo.idregist).Vlr_PercDesctTit := rw_desctitulo.Vlr_PercDesctTit;
    END LOOP;
    
    -- Limpar e carregar os calculos do titulo
    pr_tbtitulo.TabCalcTit.DELETE();
    
    -- Percorrer os valores calculados do título
    FOR rw_valorestitulo IN cr_valorestitulo LOOP
      -- Popular os dados
      
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).DtValiddCalc  := rw_valorestitulo.DtValiddCalc;
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).CdMunicipio   := rw_valorestitulo.CdMunicipio;   
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).DtCalcdVencTit:= rw_valorestitulo.DtCalcdVencTit;
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrCalcdAbatt := rw_valorestitulo.VlrCalcdAbatt; 
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrCalcdJuros := rw_valorestitulo.VlrCalcdJuros;    
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrCalcdMulta := rw_valorestitulo.VlrCalcdMulta;
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrCalcdDesct := rw_valorestitulo.VlrCalcdDesct;
      
      -- IF necessário quando a CIP não retorna grupo de cálculo DDA110_Calc (Rafael)
      IF nvl(rw_valorestitulo.VlrTotCobrar,0) = 0 THEN 
        pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrTotCobrar := nvl(pr_tbtitulo.VlrTit,0);
      ELSE       
        pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrTotCobrar  := rw_valorestitulo.VlrTotCobrar;
      END IF;
      
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrCalcdMin   := rw_valorestitulo.VlrCalcdMin;
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrCalcdMax   := rw_valorestitulo.VlrCalcdMax;
      
    END LOOP;        
    
    -- Limpar e carregar as informações de baixas operacionais
    pr_tbtitulo.TabBaixaOperac.DELETE();
        
    -- Percorrer as baixas operacionais do titulo
    FOR rw_baixaoperacional IN cr_baixaoperacional LOOP
      -- Popular os dados
      pr_tbtitulo.TabBaixaOperac(rw_baixaoperacional.idregist).NumIdentcBaixaOperac    := rw_baixaoperacional.NumIdentcBaixaOperac;
      pr_tbtitulo.TabBaixaOperac(rw_baixaoperacional.idregist).NumRefAtlBaixaOperac    := rw_baixaoperacional.NumRefAtlBaixaOperac;
      pr_tbtitulo.TabBaixaOperac(rw_baixaoperacional.idregist).NumSeqAtlzBaixaOperac   := rw_baixaoperacional.NumSeqAtlzBaixaOperac;
      pr_tbtitulo.TabBaixaOperac(rw_baixaoperacional.idregist).DtProcBaixaOperac       := rw_baixaoperacional.DtProcBaixaOperac;
      pr_tbtitulo.TabBaixaOperac(rw_baixaoperacional.idregist).DtHrProcBaixaOperac     := rw_baixaoperacional.DtHrProcBaixaOperac;
      pr_tbtitulo.TabBaixaOperac(rw_baixaoperacional.idregist).DtHrSitBaixaOperac      := rw_baixaoperacional.DtHrSitBaixaOperac;
      pr_tbtitulo.TabBaixaOperac(rw_baixaoperacional.idregist).VlrBaixaOperacTit       := rw_baixaoperacional.VlrBaixaOperacTit;
      pr_tbtitulo.TabBaixaOperac(rw_baixaoperacional.idregist).NumCodBarrasBaixaOperac := rw_baixaoperacional.NumCodBarrasBaixaOperac;
    END LOOP;
        
    -- Limpar e carregar as informações de baixas efetivas
    pr_tbtitulo.TabBaixaEft.DELETE();
    
    -- Percorrer as baixas efetivas do titulo
    FOR rw_baixaefetiva IN cr_baixaefetiva LOOP
      -- Popular os dados
      pr_tbtitulo.TabBaixaEft(rw_baixaefetiva.idregist).NumIdentcBaixaEft    := rw_baixaefetiva.NumIdentcBaixaEft;
      pr_tbtitulo.TabBaixaEft(rw_baixaefetiva.idregist).NumRefAtlBaixaEft    := rw_baixaefetiva.NumRefAtlBaixaEft;
      pr_tbtitulo.TabBaixaEft(rw_baixaefetiva.idregist).NumSeqAtlzBaixaEft   := rw_baixaefetiva.NumSeqAtlzBaixaEft;
      pr_tbtitulo.TabBaixaEft(rw_baixaefetiva.idregist).DtProcBaixaEft       := rw_baixaefetiva.DtProcBaixaEft;
      pr_tbtitulo.TabBaixaEft(rw_baixaefetiva.idregist).DtHrProcBaixaEft     := rw_baixaefetiva.DtHrProcBaixaEft;
      pr_tbtitulo.TabBaixaEft(rw_baixaefetiva.idregist).VlrBaixaEftTit       := rw_baixaefetiva.VlrBaixaEftTit;
      pr_tbtitulo.TabBaixaEft(rw_baixaefetiva.idregist).NumCodBarrasBaixaEft := rw_baixaefetiva.NumCodBarrasBaixaEft;
      pr_tbtitulo.TabBaixaEft(rw_baixaefetiva.idregist).CanPgto              := rw_baixaefetiva.CanPgto;
      pr_tbtitulo.TabBaixaEft(rw_baixaefetiva.idregist).MeioPgto             := rw_baixaefetiva.MeioPgto;
      pr_tbtitulo.TabBaixaEft(rw_baixaefetiva.idregist).DtHrSitBaixaEft      := rw_baixaefetiva.DtHrSitBaixaEft;
    END LOOP;
    
    -- Indicar execução com sucesso
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro := 'NOK';
      -- Importante retornar registro em branco
      pr_tbtitulo := NULL;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_dscritic := SQLERRM;
      pr_des_erro := 'NOK';
      -- Importante retornar registro em branco
      pr_tbtitulo := NULL;
  END pc_xmlsoap_extrair_titulo;

  /* Procedure para gerar o corpo do soap */
  PROCEDURE pc_xmlsoap_monta_estrutura(pr_cdservic  IN NUMBER  --> Chamve do Serviço requisitado
                                      ,pr_cdmetodo  IN NUMBER  --> Chave do Método requisitado
                                      ,pr_xml      OUT xmltype --> Objeto do XML criado
                                      ,pr_des_erro OUT VARCHAR2 --> Descricao erro OK/NOK
                                      ,pr_dscritic OUT VARCHAR2) IS --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_xmlsoap_monta_estrutura
    --  Sistema  : Cobrança - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Renato Darosci - Supero Tecnologia
    --  Data     : Janeiro/2017.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para gerar cabecalho de envelope soap
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
    -- VARIÁVEIS
    vr_dsservic     VARCHAR2(100);
    vr_dsmetodo     VARCHAR2(100);
  
  BEGIN
    -- Indicar que o método não foi concluído
    pr_des_erro := 'NOK';
  
    -- Verificar se o código de serviço informado existe
    IF NOT NPCB0003.vr_wscip_services.EXISTS(pr_cdservic) THEN
      pr_dscritic := 'Código de Serviço informado não encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verificar se o código do método informado existe
    IF NOT NPCB0003.vr_wscip_services(pr_cdservic).tbmetodos.EXISTS(pr_cdmetodo) THEN
      pr_dscritic := 'Código do Método informado não encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    -- Manter o serviço e o método em variáveis - Apenas para facilitar a concatenação
    vr_dsservic := NPCB0003.vr_wscip_services(pr_cdservic).dsservico;
    vr_dsmetodo := NPCB0003.vr_wscip_services(pr_cdservic).tbmetodos(pr_cdmetodo);

    -- Criar cabeçalho do envelope SOAP
    pr_xml := xmltype.createxml('<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" '
                              ||'xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
                              ||'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"> '
                              ||'<SOAP-ENV:Header SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" '
                              ||'xmlns:NS1="urn:JDNPCWS_'||vr_dsservic||'Intf">'
	                            ||'  <NS1:TAutenticacao xsi:type="NS1:TAutenticacao">'
                              ||'    <Usuario xsi:type="xsd:string">'||vr_usercip||'</Usuario>'
                              ||'    <Senha xsi:type="xsd:string">'||vr_passcip||'</Senha>'
	                            ||'  </NS1:TAutenticacao>'
                              ||'</SOAP-ENV:Header>'
                              ||'<SOAP-ENV:Body xmlns:NS2="urn:JDNPCWS_'||vr_dsservic||'Intf-IJDNPCWS_'||vr_dsservic||'" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
                              ||'  <NS2:'||vr_dsmetodo||'>'
                              ||'  </NS2:'||vr_dsmetodo||'>'
                              ||'</SOAP-ENV:Body>'
                              ||'</SOAP-ENV:Envelope>');
    
    -- Retornar OK
    pr_des_erro := 'OK';
      
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_dscritic := 'Erro na PC_XMLSOAP_MONTA_ESTRUTURA: '||SQLERRM;
  END pc_xmlsoap_monta_estrutura;
  
  /* Procedure para criar tags no XML */
  PROCEDURE pc_xmlsoap_incluir_tag(pr_dsnomtag IN VARCHAR2   --> Nome TAG que será criada
                                  ,pr_dspaitag IN VARCHAR2   --> Nome TAG pai
                                  ,pr_dsvaltag IN VARCHAR2   --> Valor TAG que será criada
                                  ,pr_dstyptag IN VARCHAR2   --> Tipo de dado da TAG
                                  ,pr_inpostag IN PLS_INTEGER   --> Posição da tag
                                  ,pr_xml      IN OUT NOCOPY XMLType --> Handle XMLType
                                  ,pr_des_erro OUT VARCHAR2  --> Identificador erro OK/NOK
                                  ,pr_dscritic OUT VARCHAR2) IS --> Descrição erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_xmlsoap_incluir_tag
    --  Sistema  : Cobrança - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Renato Darosci - Supero
    --  Data     : Janeiro/2017                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para criar tags no XML/SOAP
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
  
  BEGIN
    -- Gerar TAGs dos parâmetros para o método
    gene0007.pc_insere_tag(pr_xml      => pr_xml
                          ,pr_tag_pai  => pr_dspaitag
                          ,pr_posicao  => pr_inpostag
                          ,pr_tag_nova => pr_dsnomtag
                          ,pr_tag_cont => pr_dsvaltag
                          ,pr_des_erro => pr_dscritic);
    
    -- Verifica se ocorreu erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Gera atributo com o tipo do dado
    gene0007.pc_gera_atributo(pr_xml      => pr_xml
                             ,pr_tag      => pr_dsnomtag
                             ,pr_atrib    => 'xsi:type'
                             ,pr_atval    => 'xsd:'||pr_dstyptag
                             ,pr_numva    => pr_inpostag
                             ,pr_des_erro => pr_dscritic);
    
    -- Verifica se ocorreu erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Retornar Ok
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro := 'NOK';
      pr_dscritic := pr_dscritic;
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_dscritic := 'Erro na rotina PC_XMLSOAP_INCLUIR_TAG: ' || SQLERRM;
  END pc_xmlsoap_incluir_tag;
  
  /* Procedure para incluir as tags comuns (SE NECESSÁRIAS) no XML */
  PROCEDURE pc_xmlsoap_tag_padrao(pr_tbcampos IN OUT NPCB0003.typ_tab_campos_soap
                                 ,pr_des_erro OUT VARCHAR2  --> Identificador erro OK/NOK
                                 ,pr_dscritic OUT VARCHAR2) IS --> Descrição erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_xmlsoap_tag_padrao
    --  Sistema  : Cobrança - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Renato Darosci - Supero
    --  Data     : Janeiro/2017                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para incluir as tags comuns (SE NECESSÁRIAS) no XML/SOAP, sendo importante se 
    --             atentar que nem toda requisição necessita das mesmas, então cada caso deve ser avaliado
    --             de forma individual. Lista de TAGS inclusas pelo procedimento:
    --                   -> CdLegado                => LEG
    --                   -> ISPBPartRecbdrPrincipal => CRAPBAN.NRISPBIF, quando CDBCCXLT = 85
    --                   -> ISPBPartRecebdrAdmtd    => CRAPBAN.NRISPBIF, quando CDBCCXLT = 85
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
    
    -- Buscar o numero do ISPB
    CURSOR cr_crapban IS
      SELECT ban.nrispbif
        FROM crapban ban
       WHERE ban.cdbccxlt = 085; -- CECRED
    
    -- VARIÁVEIS
    vr_nrispbif    crapban.nrispbif%TYPE;
    
  BEGIN
    -- Retornar NOk
    pr_des_erro := 'NOK';  
  
    -- Buscar o Numero do ISPB para a cooperativa
    OPEN  cr_crapban;
    FETCH cr_crapban INTO vr_nrispbif;
    
    -- Se não encontrar registros
    IF cr_crapban%NOTFOUND THEN
      pr_dscritic := 'Código ISPB não encontrado.';
      RAISE vr_exc_erro;
    END IF;
    -- Fechar o cursor
    CLOSE cr_crapban;
    
    -- Adiciona as tags
    pr_tbcampos(pr_tbcampos.COUNT()+1).dsNomTag := 'CdLegado';
    pr_tbcampos(pr_tbcampos.COUNT()  ).dsValTag := 'LEGWS';
    pr_tbcampos(pr_tbcampos.COUNT()  ).dsTypTag := 'string';
    --
    pr_tbcampos(pr_tbcampos.COUNT()+1).dsNomTag := 'ISPBPartRecbdrPrincipal';
    pr_tbcampos(pr_tbcampos.COUNT()  ).dsValTag := vr_nrispbif;
    pr_tbcampos(pr_tbcampos.COUNT()  ).dsTypTag := 'int';
    --
    pr_tbcampos(pr_tbcampos.COUNT()+1).dsNomTag := 'ISPBPartRecebdrAdmtd';
    pr_tbcampos(pr_tbcampos.COUNT()  ).dsValTag := vr_nrispbif;
    pr_tbcampos(pr_tbcampos.COUNT()  ).dsTypTag := 'int';
    
    -- Retornar Ok
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_dscritic := 'Erro na rotina PC_XMLSOAP_TAG_PADRAO: ' || SQLERRM;
  END pc_xmlsoap_tag_padrao;
  
  /* Procedure para incluir os campos e montar a requisição */
  PROCEDURE pc_xmlsoap_monta_requisicao(pr_cdservic  IN NUMBER  --> Chamve do Serviço requisitado
                                       ,pr_cdmetodo  IN NUMBER  --> Chave do Método requisitado
                                       ,pr_tbcampos  IN NPCB0003.typ_tab_campos_soap --> tabela com as tags
                                       ,pr_xml      OUT xmltype --> Objeto do XML criado
                                       ,pr_des_erro OUT VARCHAR2 --> Descricao erro OK/NOK
                                       ,pr_dscritic OUT VARCHAR2) IS --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_xmlsoap_monta_requisicao
    --  Sistema  : Cobrança - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Renato Darosci
    --  Data     : Janeiro/2017.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para montar toda a requisição do envelope soap
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
    -- VARIÁVEIS
    vr_dscritic     VARCHAR2(100);
    vr_xmlsoap      XMLTYPE;
  
  BEGIN
    -- Indicar que o método não foi concluído
    pr_des_erro := 'NOK';
  
    -- Chama a rotina que monta a estrutura principal do SOAP
    pc_xmlsoap_monta_estrutura(pr_cdservic
                              ,pr_cdmetodo
                              ,vr_xmlsoap     
                              ,pr_des_erro
                              ,vr_dscritic);
    
    -- Se houver algum problema na execução da rotina
    IF pr_des_erro = 'NOK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Se foram passadas as tags para serem inclusas na requisição
    IF pr_tbcampos.COUNT() > 0 THEN
      FOR ind IN pr_tbcampos.FIRST..pr_tbcampos.LAST LOOP
        -- Incluir as tags no SOAP
        pc_xmlsoap_incluir_tag(pr_dsnomtag => pr_tbcampos(ind).dsNomTag
                              ,pr_dspaitag => NPCB0003.vr_wscip_services(pr_cdservic).tbmetodos(pr_cdmetodo)
                              ,pr_dsvaltag => pr_tbcampos(ind).dsValTag
                              ,pr_dstyptag => pr_tbcampos(ind).dsTypTag
                              ,pr_inpostag => 0 --ind
                              ,pr_xml      => vr_xmlsoap
                              ,pr_des_erro => pr_des_erro
                              ,pr_dscritic => vr_dscritic);
        
        -- Se houver algum problema na execução da rotina
        IF pr_des_erro = 'NOK' THEN
          RAISE vr_exc_erro;
        END IF;
      END LOOP;    
    END IF;
    
    -- Retornar o XML gerado para requisição
    pr_xml := vr_xmlsoap;
    
    -- Retornar OK
    pr_des_erro := 'OK';
      
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro := 'NOK';
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_dscritic := 'Erro na PC_XMLSOAP_MONTA_REQUISICAO: '||SQLERRM;
  END pc_xmlsoap_monta_requisicao;
  
  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_wscip_requisitar_titulo(pr_cdcooper  IN NUMBER          --> Código da cooperativa
                                      ,pr_cdctrlcs  IN VARCHAR2        --> Identificador da consulta
                                      ,pr_cdbarras  IN VARCHAR2        --> Código de barras
                                      ,pr_dtmvtolt  IN DATE            --> Data de movimento
                                      ,pr_cdcidade  IN NUMBER          --> Código da cidade da tabela CAF
                                      ,pr_dsxmltit OUT CLOB            --> XML de retorno
                                      ,pr_tpconcip OUT NUMBER          --> Tipo de Consulta CIP
                                      ,pr_des_erro OUT VARCHAR2        --> Indicador erro OK/NOK
                                      ,pr_cdcritic OUT NUMBER          --> Código do erro
                                      ,pr_dscritic OUT VARCHAR2) IS    --> Descrição do erro

  /* ..........................................................................

      Programa : pc_wscip_requisitar_titulo
      Sistema  : Cobrança - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Renato Darosci(Supero)
      Data     : Dezembro/2016.                   Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para consultar via webservice o titulo na CIP, retornando
                  o XML com os dados recebidos

      Alteração :

    ..........................................................................*/

    -----------> CURSORES <-----------


    ----------> VARIAVEIS <-----------
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(1000);
    vr_cdmetodo      NUMBER;
    vr_xmlsoap       XMLTYPE;
    vr_dsxmltit      XMLTYPE;
    vr_tbcampos      NPCB0003.typ_tab_campos_soap;
    vr_dssrdom       VARCHAR2(1000); -- Var para retorno do Service Domain
    
  BEGIN
  
   /* pr_dsxmltit := '<?xml version="1.0"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:NS1="urn:JDNPCWS_RecebimentoPgtoTitIntf-IJDNPCWS_RecebimentoPgtoTit"><NS1:RequisitarTituloCIPCalcVlrResponse><return xsi:type="xsd:string"><RequisitarTituloCIP><NumCtrlPart>201707171358211234CX</NumCtrlPart><ISPBPartRecbdrPrincipal>05463212</ISPBPartRecbdrPrincipal><ISPBPartRecebdrAdmtd>05463212</ISPBPartRecebdrAdmtd><NumIdentcTit>2017070606000279285</NumIdentcTit><NumRefAtlCadTit>1500286255693000717</NumRefAtlCadTit><NumSeqAtlzCadTit>10</NumSeqAtlzCadTit><DtHrSitTit>2017-07-17T07:10:55</DtHrSitTit><ISPBPartDestinatario>33657248</ISPBPartDestinatario><CodPartDestinatario>007</CodPartDestinatario><TpPessoaBenfcrioOr>J</TpPessoaBenfcrioOr><CNPJ_CPFBenfcrioOr>33657248000189</CNPJ_CPFBenfcrioOr><Nom_RzSocBenfcrioOr>teste</Nom_RzSocBenfcrioOr><NomFantsBenfcrioOr>Banco Nacional de Desenvolvimento Econ?mico e Soci</NomFantsBenfcrioOr><LogradBenfcrioOr>Avenida República do Chile 100</LogradBenfcrioOr><CidBenfcrioOr>Rio de Janeiro</CidBenfcrioOr><UFBenfcrioOr>RJ</UFBenfcrioOr><CEPBenfcrioOr>20031917</CEPBenfcrioOr><TpPessoaPagdr>J</TpPessoaPagdr><CNPJ_CPFPagdr>82647165000114</CNPJ_CPFPagdr><Nom_RzSocPagdr>COOPERATIVA DE PRODUCAO E ABASTECIMENTO VALE DO IT</Nom_RzSocPagdr><NomFantsPagdr>COOPERATIVA DE PRODUCAO E ABASTECIMENTO VALE DO IT</NomFantsPagdr><CodMoedaCNAB>09</CodMoedaCNAB><NumCodBarras>00796722300316191180109019000043201707031446</NumCodBarras><NumLinhaDigtvl>00790109061900004320817070314467672230031619118</NumLinhaDigtvl><DtVencTit>2017-07-17</DtVencTit><VlrTit>316191.18</VlrTit><CodEspTit>24</CodEspTit><DtLimPgtoTit>2017-07-17</DtLimPgtoTit><IndrBloqPgto>N</IndrBloqPgto><IndrPgtoParcl>N</IndrPgtoParcl><VlrAbattTit>0.00</VlrAbattTit><TpModlCalc>03</TpModlCalc><TpAutcRecbtVlrDivgte>3</TpAutcRecbtVlrDivgte><RepetCalcTit><CalcTit>
    <VlrCalcdJuros>0.00</VlrCalcdJuros>
    <VlrCalcdMulta>0.00</VlrCalcdMulta>
    <VlrCalcdDesct>0.00</VlrCalcdDesct>
    <VlrTotCobrar>316191.18</VlrTotCobrar>
    <DtValiddCalc>2017-07-17</DtValiddCalc>
    </CalcTit></RepetCalcTit><SitTitPgto>12</SitTitPgto><JDCalcTit><DtValiddCalcJD>2017-07-17</DtValiddCalcJD><CdMunicipio>12311</CdMunicipio><DtCalcdJDVencTit>2017-07-17</DtCalcdJDVencTit><VlrCalcdJDAbatt>0</VlrCalcdJDAbatt><VlrCalcdJDJuros>0</VlrCalcdJDJuros><VlrCalcdJDMulta>0</VlrCalcdJDMulta><VlrCalcdJDDesct>0</VlrCalcdJDDesct><VlrCalcdJDTotCobrar>316191.18</VlrCalcdJDTotCobrar><VlrCalcdJDMin>316191.18</VlrCalcdJDMin><VlrCalcdJDMax>316191.18</VlrCalcdJDMax></JDCalcTit></RequisitarTituloCIP></return></NS1:RequisitarTituloCIPCalcVlrResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
    pr_des_erro := 'OK';
    pr_tpconcip := 1;
    RETURN;*/
  
    -- Indica que a rotina não foi executada por completo
    pr_des_erro := 'NOK';
    
    -- Limpa a tab de campos
    vr_tbcampos.DELETE();
    
    -- Chama rotina para fazer a inclusão das TAGS comuns
    pc_xmlsoap_tag_padrao(vr_tbcampos
                         ,pr_des_erro
                         ,vr_dscritic );
    
    -- Se houver algum problema na execução da rotina
    IF pr_des_erro = 'NOK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Adiciona as tags
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumCtrlPart';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_cdctrlcs;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumCodBarras';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_cdbarras;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
    --
    -- Verificar se foi informado cidade
    IF NVL(pr_cdcidade,0) > 0 THEN
      vr_cdmetodo := 2;  -- Requisitar Título CIP Cálculo do Valor
      
      -- Adicionar a Tag de municipio
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'CdMunicipio';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_cdcidade;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
    
    ELSE
      vr_cdmetodo := 1;  -- Requisitar titulo CIP
    END IF;
    
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'DtMovto';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := to_char(SYSDATE, 'YYYYMMDD'); -- pr_dtmvtolt 
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
    
    -- Montar o XML/SOAP para a requisição da consulta
    pc_xmlsoap_monta_requisicao(4  -- Recebimento Pagamento de Titulo
                               ,vr_cdmetodo  
                               ,vr_tbcampos
                               ,vr_xmlsoap     
                               ,pr_des_erro
                               ,vr_dscritic);    
    
    -- Se houver algum problema na execução da rotina
    IF pr_des_erro = 'NOK' THEN
      RAISE vr_exc_erro;
    END IF;
    --dbms_output.put_line('--------------------------------------------'); -- ver renato
    --dbms_output.put_line(vr_xmlsoap.getClobVal()); -- ver renato
    --dbms_output.put_line('--------------------------------------------'); -- ver renato
    -- Indicar o tipo de consulta como CIP
    pr_tpconcip := 1; 
    
    /************* MONTAR O LINK DE ACESSO AO SERVIÇO DO WEBSERVICE *************/
    
    vr_dssrdom := fn_url_SendSoapNPC (pr_idservic => 4);
    
    /************* MONTAR O LINK DE ACESSO AO SERVIÇO DO WEBSERVICE *************/

    -- Enviar requisição para webservice
    SOAP0001.pc_cliente_webservice(pr_endpoint    => vr_dssrdom
                                  ,pr_acao        => NULL
                                  ,pr_wallet_path => NULL
                                  ,pr_wallet_pass => NULL
                                  ,pr_xml_req     => vr_xmlsoap
                                  ,pr_xml_res     => vr_dsxmltit
                                  ,pr_erro        => vr_dscritic);
    
    -- Verifica se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Verificar se o XML retornado pelo WebService contem o Fault Packet
    pc_xmlsoap_fault_packet(pr_cdcooper => pr_cdcooper
                           ,pr_cdctrlcs => pr_cdctrlcs
                           ,pr_dsxmlreq => vr_xmlsoap.getClobVal()
                           ,pr_dsxmlerr => vr_dsxmltit.getClobVal()
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
    --dbms_output.put_line('******************************************');
    --dbms_output.put_line('======>>> '||vr_cdcritic);
    --dbms_output.put_line('******************************************');
    -- Se ocorreu crítica, mas a mesma é diferente da critica 940 - Tempo Excedido
    -- deve gerar o erro e encerrar a rotina
    IF (vr_cdcritic > 0 OR vr_dscritic IS NOT NULL) AND vr_cdcritic <> 940 THEN
      RAISE vr_exc_erro;
    
    -- Se ocorreu o erro 940 - Tempo excedido, deve chamar o método de consulta de 
    -- títulos diretamente na base do NPC
    ELSIF vr_cdcritic = 940 THEN
      
      -- Limpar o CLOB anterior e as variáveis de crítica
      vr_xmlsoap  := NULL;
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
      vr_dsxmltit := NULL;
      
      -- Montar o XML/SOAP para a requisição da consulta
      pc_xmlsoap_monta_requisicao(4  -- Recebimento Pagamento de Titulo
                                 ,3  -- Consultar Requisicao Titulo
                                 ,vr_tbcampos
                                 ,vr_xmlsoap     
                                 ,pr_des_erro
                                 ,vr_dscritic);   
      --dbms_output.put_line('++++++++++++++++++++++++++++++++++++++++++++'); -- ver renato
      --dbms_output.put_line(vr_xmlsoap.getClobVal()); -- ver renato
      --dbms_output.put_line('++++++++++++++++++++++++++++++++++++++++++++'); -- ver renato
      -- Se houver algum problema na execução da rotina
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Indicar o tipo de consulta como NPC
      pr_tpconcip := 2; 
      
      -- Enviar requisição para webservice
      SOAP0001.pc_cliente_webservice(pr_endpoint    => vr_dssrdom
                                    ,pr_acao        => NULL
                                    ,pr_wallet_path => NULL
                                    ,pr_wallet_pass => NULL
                                    ,pr_xml_req     => vr_xmlsoap
                                    ,pr_xml_res     => vr_dsxmltit
                                    ,pr_erro        => pr_dscritic);
    
      -- Verifica se ocorreu erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    	-- Verificar se o XML retornado pelo WebService contem o Fault Packet
      pc_xmlsoap_fault_packet(pr_cdcooper => pr_cdcooper
                             ,pr_cdctrlcs => pr_cdctrlcs
                             ,pr_dsxmlreq => vr_xmlsoap.getClobVal()
                             ,pr_dsxmlerr => vr_dsxmltit.getClobVal()
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
    
      -- Se ocorreu crítica, deve gerar o erro e encerrar a rotina
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;      
      END IF;
      
    END IF;
    
    -- Se passou pela validação de erros sem encontrar retorno do Fault Packet, deve retornar o XML
    pr_dsxmltit := REPLACE( REPLACE(vr_dsxmltit.getClobVal(),'&lt;','<') ,'&gt;','>');
    --dbms_output.PUT_LINE('#### RETORNO #######################################');
    --dbms_output.put_line(pr_dsxmltit);
    --dbms_output.PUT_LINE('####################################################');
    -- Indica que a rotina foi executada com sucesso
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      pr_des_erro := 'NOK';
  END pc_wscip_requisitar_titulo;


  --> Rotina para listar títulos do pagador
  PROCEDURE pc_wscip_listar_titulo(pr_tppessoa  IN VARCHAR2        --> Tipo da pessoa (F/J)
                                  ,pr_nrcpfcgc  IN NUMBER          --> Número do documento do pagador
                                  ,pr_dsxmlret OUT CLOB            --> XML de retorno
                                  ,pr_des_erro OUT VARCHAR2        --> Indicador erro OK/NOK
                                  ,pr_cdcritic OUT NUMBER          --> Código do erro
                                  ,pr_dscritic OUT VARCHAR2) IS    --> Descrição do erro

  /* ..........................................................................

      Programa : pc_wscip_listar_titulo
      Sistema  : Cobrança - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Renato Darosci(Supero)
      Data     : Janeiro/2017.                   Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para consultar via webservice a lista de titulos

      Alteração :

    ..........................................................................*/

    -----------> CURSORES <-----------


    ----------> VARIAVEIS <-----------
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(1000);
    vr_cdmetodo      NUMBER;
    vr_xmlsoap       XMLTYPE;
    vr_dsxmltit      XMLTYPE;
    vr_tbcampos      NPCB0003.typ_tab_campos_soap;
    vr_dssrdom       VARCHAR2(1000); -- Var para retorno do Service Domain
    
  BEGIN
    -- Indica que a rotina não foi executada por completo
    pr_des_erro := 'NOK';
    
    -- Limpa a tab de campos
    vr_tbcampos.DELETE();
    
    -- Chama rotina para fazer a inclusão das TAGS comuns
    pc_xmlsoap_tag_padrao(vr_tbcampos
                         ,pr_des_erro
                         ,vr_dscritic );
    
    -- Se houver algum problema na execução da rotina
    IF pr_des_erro = 'NOK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Adiciona as tags
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'TpPessoaPagdr';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_tppessoa;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'CPFCNPJPagdr';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_nrcpfcgc;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'ItemInicial';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := 1;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'ItemFinal';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := 20;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'JDNPCOrdemTit';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := 1;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
    
    -- Montar o XML/SOAP para a requisição 
    pc_xmlsoap_monta_requisicao(3  -- Títulos do Pagador
                               ,1  
                               ,vr_tbcampos
                               ,vr_xmlsoap     
                               ,pr_des_erro
                               ,vr_dscritic);    
    
    -- Se houver algum problema na execução da rotina
    IF pr_des_erro = 'NOK' THEN
      RAISE vr_exc_erro;
    END IF;
    --dbms_output.put_line('--- REQUISIÇÃO -----------------------------'); -- ver renato
    --dbms_output.put_line(vr_xmlsoap.getClobVal()); -- ver renato
    --dbms_output.put_line('--------------------------------------------'); -- ver renato
    
    /************* MONTAR O LINK DE ACESSO AO SERVIÇO DO WEBSERVICE *************/
    
    vr_dssrdom := fn_url_SendSoapNPC (pr_idservic => 4);
    
    /************* MONTAR O LINK DE ACESSO AO SERVIÇO DO WEBSERVICE *************/

    -- Enviar requisição para webservice
    SOAP0001.pc_cliente_webservice(pr_endpoint    => vr_dssrdom
                                  ,pr_acao        => NULL
                                  ,pr_wallet_path => NULL
                                  ,pr_wallet_pass => NULL
                                  ,pr_xml_req     => vr_xmlsoap
                                  ,pr_xml_res     => vr_dsxmltit
                                  ,pr_erro        => vr_dscritic);
    
    -- Verifica se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Verificar se o XML retornado pelo WebService contem o Fault Packet
    pc_xmlsoap_fault_packet(pr_cdcooper => 3
                           ,pr_cdctrlcs => NULL
                           ,pr_dsxmlreq => vr_xmlsoap.getClobVal()
                           ,pr_dsxmlerr => vr_dsxmltit.getClobVal()
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
    --dbms_output.put_line('******************************************');
    --dbms_output.put_line('======>>> '||vr_cdcritic);
    --dbms_output.put_line('******************************************');
    -- Se ocorreu crítica, mas a mesma é diferente da critica 940 - Tempo Excedido
    -- deve gerar o erro e encerrar a rotina
    IF (vr_cdcritic > 0 OR vr_dscritic IS NOT NULL) THEN
      RAISE vr_exc_erro;  
    END IF;
    
    -- Se passou pela validação de erros sem encontrar retorno do Fault Packet, deve retornar o XML
    pr_dsxmlret := vr_dsxmltit.getClobVal();
    
    --dbms_output.put_line('--- RETORNO --------------------------------'); -- ver renato
    --dbms_output.put_line(vr_xmlsoap.getClobVal()); -- ver renato
    --dbms_output.put_line('--------------------------------------------'); -- ver renato
    
    -- Indica que a rotina foi executada com sucesso
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      pr_des_erro := 'NOK';
  END pc_wscip_listar_titulo;

  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_wscip_requisitar_baixa(pr_cdcooper  IN NUMBER             --> Código da cooperativa
                                     ,pr_dtmvtolt  IN DATE               --> data de movimento
                                     ,pr_dscodbar  IN VARCHAR2           --> Codigo de barra
                                     ,pr_cdctrlcs  IN VARCHAR2           --> Identificador da consulta
                                    -- ,pr_nrispbif  IN VARCHAR2           --> ISPB recebedor baixa operacional
                                     ,pr_idtitdda  IN NUMBER             --> Identificador Titulo DDA
                                     ,pr_tituloCIP IN npcb0001.typ_reg_TituloCIP --> Dados do titulo na CIP
                                     ,pr_flmobile  IN NUMBER             --> Indicador do Mobile
                                     --,pr_xml_frag OUT NOCOPY xmltype     --> Fragmento do XML de retorno
                                     ,pr_des_erro OUT VARCHAR2           --> Indicador erro OK/NOK
                                     ,pr_dscritic OUT VARCHAR2) IS       --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_wscip_requisitar_baixa     (Antigo: procedures/b1wgen0079.p/baixa-operacional)
    --  Sistema  : Procedure para Executar Baixa Operacional
    --  Sigla    : CRED
    --  Autor    : Petter Rafael - Supero Tecnologia
    --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para Executar Baixa Operacional
    --
    -- Alteracoes: 01/08/2013 - conversão Progress >> PL/SQL (Oracle). Petter - Supero.
    --
    --             28/04/2017 - Alterar a procedure movendo a mesma para a package do NPC 
    ---------------------------------------------------------------------------------------------------------------

    vr_xml     XMLType; --> XML de requisição
    vr_exc_erro EXCEPTION; --> Controle de exceção
    vr_xml_res XMLType; --> XML de resposta
    --vr_tab_xml gene0007.typ_tab_tagxml; --> PL Table para armazenar conteúdo XML
    vr_cdcanal_npc INTEGER;                           
      
    --> Buscar dados do titulo pago
    CURSOR cr_craptit IS
      SELECT tit.nrispbds,
             tit.cdagenci, 
             decode(tit.inpessoa,1,'F','J') dsinpess,
             tit.nrdident,
             tit.nrcpfcgc,
             tit.tpbxoper,
             tit.dscodbar,
             tit.vldpagto,
             decode(tit.flgconti,1,'S','N') flgconti,
             tit.nrdconta,
             tit.flgpgdda,
             tit.intitcop,
             tit.rowid
        FROM craptit tit
       WHERE tit.cdcooper        = pr_cdcooper
         AND tit.dtmvtolt        = pr_dtmvtolt
         AND UPPER(tit.dscodbar) = UPPER(pr_dscodbar)
         AND UPPER(tit.cdctrlcs) = UPPER(pr_cdctrlcs);
    rw_craptit cr_craptit%ROWTYPE;
    
    --> Buscar boleto pelo nrdident
    CURSOR cr_crapcob (pr_nrdident crapcob.nrdident%TYPE )IS
      SELECT cob.nratutit
        FROM crapcob cob
       WHERE cob.nrdident = pr_nrdident;
    rw_crapcob cr_crapcob%ROWTYPE;   
    
    vr_tbcampos      NPCB0003.typ_tab_campos_soap;
    vr_cdctrbxo      VARCHAR2(100);
    vr_cdCanPgt      INTEGER;
    vr_cdmeiopg      INTEGER;
    vr_dssrdom       VARCHAR2(1000); -- Var para retorno do Service Domain
    vr_nratutit      crapcob.nratutit%TYPE;
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(1000);
    
  BEGIN
    
    -- Buscar registro do título
    OPEN  cr_craptit;
    FETCH cr_craptit INTO rw_craptit;
    
    -- Se o título não for encontrado
    IF cr_craptit%NOTFOUND THEN
      CLOSE cr_craptit;
      vr_dscritic := 'Registro de título não encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_craptit;
    
    vr_nratutit := NULL;
    
    --Se for titulo da propria cooperativa
    IF rw_craptit.intitcop = 1 THEN
      --> Buscar boleto pelo nrdident
      OPEN cr_crapcob (pr_nrdident => rw_craptit.nrdident);
      FETCH cr_crapcob INTO rw_crapcob;
      IF cr_crapcob%FOUND THEN
        vr_nratutit := rw_crapcob.nratutit;
      END IF;
      CLOSE cr_crapcob;            
      
    ELSE
      vr_nratutit := pr_tituloCIP.NumRefAtlCadTit; 
    END IF;
  
    -- Limpa a tab de campos
    vr_tbcampos.DELETE();
      
    -- Chama rotina para fazer a inclusão das TAGS comuns
    NPCB0003.pc_xmlsoap_tag_padrao(pr_tbcampos => vr_tbcampos
                                  ,pr_des_erro => pr_des_erro
                                  ,pr_dscritic => vr_dscritic);
    
    -- Montar o número de controle da baixa operacional
    vr_cdctrbxo := NPCB0001.fn_montar_NumCtrlPart(pr_cdbarras => rw_craptit.dscodbar
                                                 ,pr_cdagenci => rw_craptit.cdagenci
                                                 ,pr_flmobile => pr_flmobile);
    

    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'EnvioImediato';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := 'N';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';    
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumCtrlPart';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := vr_cdctrbxo;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';    
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumIdentcTit';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.nrdident;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumRefCadTitBaixaOperac';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := vr_nratutit;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'TpBaixaOperac';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.tpbxoper;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'ISPBPartRecbdrBaixaOperac';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := 5463212;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';    
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'CodPartRecbdrBaixaOperac';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := 85;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'TpPessoaPort';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.dsinpess;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'CPFCNPJPort';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.nrcpfcgc;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';          
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'VlrBaixaOperacTit';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := to_char(rw_craptit.vldpagto,'FM9999999999999999D99','NLS_NUMERIC_CHARACTERS=''.,''');
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'float';      
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'DtHrProcBaixaOperac';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := to_char(SYSDATE, 'RRRRMMDDHH24MISS'); --> AAAAMMDDhhmmss
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';      
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'DtProcBaixaOperac';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := to_char(SYSDATE,'RRRRMMDD');
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';      
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumCodBarrasBaixaOperac';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.dscodbar;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';      
    --
    --> Rotina para retornar o codigo do canal de pagamento do NPC
  /*  vr_cdcanal_npc := NPCB0001.fn_canal_pag_NPC( pr_cdagenci  => rw_craptit.cdagenci    --> Codigo da agencia
                                                ,pr_idtitdda  => rw_craptit.nrdident ); --> Indicador se foi pago pelo sistema de DDDA
                            
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'CanPgto';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := vr_cdcanal_npc;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';            
    */
    IF rw_craptit.flgpgdda = 1 THEN
      vr_cdCanPgt := 8; --> DDA
    ELSE
      CASE rw_craptit.cdagenci 
        WHEN 90 THEN
          vr_cdCanPgt := 3; --> Internet            
        WHEN 91 THEN
          vr_cdCanPgt := 2; --> Terminal de Auto-Atendimento
        ELSE
          vr_cdCanPgt := 1; --> Agências- Postos Tradicionai            
      END CASE;       
    END IF;
        
    IF nvl(rw_craptit.nrdconta,0) > 0 THEN
      vr_cdmeiopg := 2; --> Débito em conta;
    ELSE
      vr_cdmeiopg := 1; --> Espécie
    END IF;
    
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'CanPgto';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := vr_cdCanPgt;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';    
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'MeioPgto';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := vr_cdmeiopg;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';    
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'IndrOpContg';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.flgconti;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';      
    
    -- Monta a estrutura principal do SOAP
    NPCB0003.pc_xmlsoap_monta_requisicao(pr_cdservic => 4 --> RecebimentoPgtoTit
                                        ,pr_cdmetodo => 4 --> RequisitarBaixa
                                        ,pr_tbcampos => vr_tbcampos
                                        ,pr_xml      => vr_xml
                                        ,pr_des_erro => pr_des_erro
                                        ,pr_dscritic => vr_dscritic);
    
    -- Verifica se ocorreu erro
    IF pr_des_erro != 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    /************* MONTAR O LINK DE ACESSO AO SERVIÇO DO WEBSERVICE *************/
    -- Busca o service domain conforme parâmetro NPC_SERVICE_DOMAIN
    vr_dssrdom := fn_url_SendSoapNPC (pr_idservic => 4);
    
    
    --dbms_output.PUT_LINE('#### REQUISIÇÃO ####################################');
    --dbms_output.put_line(vr_xml.getClobVal());
    --DBMS_XSLPROCESSOR.CLOB2FILE(vr_xml.getclobval(), '/micros/cecred/odirlei/arq', 'req.xml', NLS_CHARSET_ID('UTF8'));
    --dbms_output.PUT_LINE('####################################################');
    
    
    -- Enviar requisição para webservice
    soap0001.pc_cliente_webservice(pr_endpoint    => vr_dssrdom
                                  ,pr_acao        => NULL
                                  ,pr_wallet_path => NULL
                                  ,pr_wallet_pass => NULL
                                  ,pr_xml_req     => vr_xml
                                  ,pr_xml_res     => vr_xml_res
                                  ,pr_erro        => vr_dscritic);
    
    -- Verifica se ocorreu erro
    IF trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    
    --dbms_output.PUT_LINE('#### RETORNO #######################################');
    --dbms_output.put_line(vr_xml_res.getClobVal());
    --dbms_output.PUT_LINE('####################################################');
    
    
    -- Verifica se ocorreu retorno com erro no XML
    pc_xmlsoap_fault_packet(pr_cdcooper => pr_cdcooper
                           --,pr_cdctrlcs => pr_cdctrlcs
                           ,pr_dsxmlreq => vr_xml.getClobVal()
                           ,pr_dsxmlerr => vr_xml_res.getClobVal()
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
                           
    -- Se ocorreu crítica, deve gerar o erro e encerrar a rotina
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;      
    END IF;
    
    --> Atualizar codigo de controle participante da baixa operacional
    --> utilizado caso necessario estornar o titulo
    BEGIN
        UPDATE craptit tit
           SET tit.cdctrbxo = vr_cdctrbxo
         WHERE tit.rowid = rw_craptit.rowid;           
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar titulo(cdctrbxo): '||SQLERRM;
      RAISE vr_exc_erro;
    END;
    
    --Retornar OK
    pr_des_erro := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_dscritic := 'Erro na rotina NPCB0003.pc_wscip_requisitar_baixa. ' ||SQLERRM;
  END pc_wscip_requisitar_baixa;


BEGIN --> Corpo da package 

  --> Carregar temptable com os serviços do webservice para NCP
  IF vr_wscip_services.count() = 0 THEN 
    --> SERVIÇO: PAGADOR ELETRONICO
    vr_wscip_services(1).dsservico := 'PagadorEletronico';
    vr_wscip_services(1).dsinterfa := 'IJDNPC_PagadorEletronico';
    -- Métodos
    vr_wscip_services(1).tbmetodos(1)  := 'ConsultarTermo';
    vr_wscip_services(1).tbmetodos(2)  := 'Incluir';
    vr_wscip_services(1).tbmetodos(3)  := 'Excluir';
    vr_wscip_services(1).tbmetodos(4)  := 'Alterar';
    vr_wscip_services(1).tbmetodos(5)  := 'ConsultaProprio';
    vr_wscip_services(1).tbmetodos(6)  := 'ConsultarPagadorConta';
    vr_wscip_services(1).tbmetodos(7)  := 'Verificar';
    vr_wscip_services(1).tbmetodos(8)  := 'VerificarLote';
    vr_wscip_services(1).tbmetodos(9)  := 'Aprovar';
    vr_wscip_services(1).tbmetodos(10) := 'Rejeitar';
    
    --> SERVIÇO: AGREGADO
    vr_wscip_services(2).dsservico := 'PagadorEletronicoAgregado';
    vr_wscip_services(2).dsinterfa := 'IJDNPC_PagadorEletronicoAgregado';
    -- Métodos
    vr_wscip_services(2).tbmetodos(1)  := 'Incluir';
    vr_wscip_services(2).tbmetodos(2)  := 'Excluir';
    vr_wscip_services(2).tbmetodos(3)  := 'Consultar';
    vr_wscip_services(2).tbmetodos(4)  := 'Aprovar';
    vr_wscip_services(2).tbmetodos(5)  := 'Rejeitar';
    
    --> SERVIÇO: TÍTULO DO PAGADOR
    vr_wscip_services(3).dsservico := 'TituloPagadorEletronico';
    vr_wscip_services(3).dsinterfa := 'IJDNPC_TituloPagadorEletronico';
    -- Métodos
    vr_wscip_services(3).tbmetodos(1)  := 'ListarTitulosResumo';
    vr_wscip_services(3).tbmetodos(2)  := 'PaginarListaTitulosResumo';
    vr_wscip_services(3).tbmetodos(3)  := 'ListarTitulos';
    vr_wscip_services(3).tbmetodos(4)  := 'PaginarListaTitulos';
    vr_wscip_services(3).tbmetodos(5)  := 'ConsultarLista';
    vr_wscip_services(3).tbmetodos(6)  := 'ConsultarLote';
    vr_wscip_services(3).tbmetodos(7)  := 'Detalhar';
    vr_wscip_services(3).tbmetodos(8)  := 'Aceitar';
    vr_wscip_services(3).tbmetodos(9)  := 'Rejeitar';
    vr_wscip_services(3).tbmetodos(10) := 'IncluirTerceiro';
    vr_wscip_services(3).tbmetodos(11) := 'AlterarTerceiro';
    vr_wscip_services(3).tbmetodos(12) := 'ExcluirTerceiro';
    vr_wscip_services(3).tbmetodos(13) := 'AtualizarSituacao';
    vr_wscip_services(3).tbmetodos(14) := 'ConsultarHistoricoAlteracao';
    vr_wscip_services(3).tbmetodos(15) := 'DetalharVersao';
    
    --> SERVIÇO: RECEBIMENTO PAGAMENTO TITULO
    vr_wscip_services(4).dsservico := 'RecebimentoPgtoTit';
    vr_wscip_services(4).dsinterfa := 'IJDNPCWS_RecebimentoPgtoTit';
    -- Métodos
    vr_wscip_services(4).tbmetodos(1) := 'RequisitarTituloCip';
    vr_wscip_services(4).tbmetodos(2) := 'RequisitarTituloCIPCalcVlr';
    vr_wscip_services(4).tbmetodos(3) := 'ConsultarRequisicaoTitulo';
    vr_wscip_services(4).tbmetodos(4) := 'RequisitarBaixa';
    vr_wscip_services(4).tbmetodos(5) := 'CancelarBaixa';
    vr_wscip_services(4).tbmetodos(6) := 'ConsultarRetornoBaixaOperacional';
    
  END IF;
  
END NPCB0003;
/
