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
  FUNCTION fn_getxml RETURN CLOB;
  
  -- Rotina para verificar se houve retorno de erro do Webservice - Fault Packet
  PROCEDURE pc_xmlsoap_fault_packet(pr_dsxmlerr  IN CLOB         --> XML para avaliar se houve erro
                                   ,pr_cdcritic OUT NUMBER       --> Retornar o código da crítica
                                   ,pr_dscritic OUT VARCHAR2);   --> Retornar a descrição da critica
  
  --> Rotina para converter o XML do titulo para a tabela de memória
  PROCEDURE pc_xmlsoap_extrair_titulo(pr_dsxmltit  IN CLOB                       --> XML de retorno
                                     ,pr_tbtitulo OUT NPCB0001.typ_reg_TituloCIP --> Collection com os dados do título
                                     ,pr_des_erro OUT VARCHAR2                   --> Indicador erro OK/NOK
                                     ,pr_dscritic OUT VARCHAR2);                 --> Descrição do erro
  
  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_wscip_requisitar_titulo(pr_cdlegado  IN VARCHAR2        --> Codigo Legado
                                      ,pr_nrispbif  IN VARCHAR2        --> Numero ISPB IF
                                      ,pr_idtitdda  IN NUMBER          --> Identificador Titulo DDA
                                      ,pr_dsxmltit OUT CLOB            --> Fragmento do XML de retorno
                                      ,pr_tpconcip OUT NUMBER          --> Tipo de Consulta CIP
                                      ,pr_des_erro OUT VARCHAR2        --> Indicador erro OK/NOK
                                      ,pr_dscritic OUT VARCHAR2);      --> Descrição do erro

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
  --> Declaração geral de exception
  vr_exc_erro        EXCEPTION;
  
  vr_teste_faul      CONSTANT CLOB := '<?xml version="1.0"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:xsd="http://www.w3.org/2001/XMLSchema"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/">
<SOAP-ENV:Body>
<SOAP-ENV:Fault>
<faultactor>JDNPC_PagadorEletronico.ConsultarTermoAdesao</faultactor>
<faultcode>SOAP-ENV:-151</faultcode>
<faultstring>ISPB IF não cadastrado</faultstring>
<detail>
<NS1:ERemotableException xmlns:NS1="urn:InvokeRegistry" 
xsi:type="NS1:ERemotableException"/>
</detail>
</SOAP-ENV:Fault>
</SOAP-ENV:Body>
</SOAP-ENV:Envelope>';

  FUNCTION fn_getxml RETURN CLOB IS
    vr_dsxmltit  CLOB;
    vr_des_erro  VARCHAR2(3);
    vr_tpconcip  NUMBER;
    vr_dscritic  VARCHAR2(1000);
  BEGIN
    
    npcb0003.pc_wscip_requisitar_titulo(pr_cdlegado => 'LEG',
                                        pr_nrispbif => NULL,
                                        pr_idtitdda => NULL,
                                        pr_dsxmltit => vr_dsxmltit,
                                        pr_tpconcip => vr_tpconcip,
                                        pr_des_erro => vr_des_erro,
                                        pr_dscritic => vr_dscritic);
                                        
    RETURN vr_dsxmltit;
  
  END;
  
  -- Rotina para verificar se houve retorno de erro do Webservice - Fault Packet
  PROCEDURE pc_xmlsoap_fault_packet(pr_dsxmlerr  IN CLOB         --> XML para avaliar se houve erro
                                   ,pr_cdcritic OUT NUMBER       --> Retornar o código da crítica
                                   ,pr_dscritic OUT VARCHAR2) IS --> Retornar a descrição da critica
    
    -- Extrair erros do XML
    CURSOR cr_faultpacket IS
      WITH DATA AS (SELECT pr_dsxmlerr xml FROM dual)
      SELECT ABS(TO_NUMBER(substr(faultcode,INSTR(faultcode,':')+1))) faultcode
           , faultstring
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'SOAP-ENV:Fault' AS "fault")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/SOAP-ENV:Fault'
                      PASSING XMLTYPE(xml)
                      COLUMNS faultcode   VARCHAR2(25)   PATH 'faultcode'
                            , faultstring VARCHAR2(1000) PATH 'faultstring');
    
    -- VARIÁVEIS
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);
    
  BEGIN
    
    -- Buscar a critica no XML
    OPEN  cr_faultpacket;
    FETCH cr_faultpacket INTO vr_cdcritic
                            , vr_dscritic;
    
    -- Se não retornou nenhum registro
    IF cr_faultpacket%NOTFOUND THEN
      -- Não retornar crítica
      pr_cdcritic := 0;
      pr_dscritic := NULL;
    ELSE
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
           , TO_DATE(DtHrSitTit, 'YYYYMMDDHH24MISS') DtHrSitTit
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
           , TO_DATE(DtVencTit, 'YYYYMMDD') DtVencTit
           , TO_NUMBER(VlrTit)   VlrTit
           , CodEspTit        
           , QtdDiaPrott      
           , TO_DATE(DtLimPgtoTit,'YYYYMMDD') DtLimPgtoTit
           , IndrBloqPgto      
           , IndrPgtoParcl      
           , QtdPgtoParcl      
           , TO_NUMBER(VlrAbattTit) VlrAbattTit
           , TO_DATE(DtJurosTit, 'YYYYMMDD') DtJurosTit      
           , CodJurosTit     
           , TO_NUMBER(Vlr_PercJurosTit)     Vlr_PercJurosTit
           , TO_DATE(DtMultaTit, 'YYYYMMDD') DtMultaTit      
           , CodMultaTit     
           , TO_NUMBER(Vlr_PercMultaTit)     Vlr_PercMultaTit
           , IndrVlr_PercMinTit  
           , TO_NUMBER(Vlr_PercMinTit)       Vlr_PercMinTit
           , IndrVlr_PercMaxTit  
           , TO_NUMBER(Vlr_PercMaxTit)       Vlr_PercMaxTit
           , TpModlCalc      
           , TpAutcRecbtVlrDivgte
           , QtdPgtoParclRegtd
           , TO_NUMBER(VlrSldTotAtlPgtoTit)  VlrSldTotAtlPgtoTit
           , SitTitPgto
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPC_PagadorEletronicoAgregadoIntf-IJDNPC_PagadorEletronicoAgregado' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:TituloResponse'
                      PASSING XMLTYPE(xml)
                      COLUMNS NumCtrlPart             VARCHAR2(14) PATH 'NumCtrlPart'
                            , ISPBPartRecbdrPrincipal NUMBER       PATH 'ISPBPartRecbdrPrincipal'
                            , ISPBPartRecebdrAdmtd    NUMBER       PATH 'ISPBPartRecebdrAdmtd'
                            , NumIdentcTit            NUMBER       PATH 'NumIdentcTit'
                            , DtHrSitTit              VARCHAR2(14) PATH 'DtHrSitTit'
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
                            , DtVencTit               VARCHAR2(8)  PATH 'DtVencTit'
                            , VlrTit                  VARCHAR2(20) PATH 'VlrTit'
                            , CodEspTit               VARCHAR2(2)  PATH 'CodEspTit'
                            , QtdDiaPrott             NUMBER       PATH 'QtdDiaPrott'
                            , DtLimPgtoTit            VARCHAR2(8)  PATH 'DtLimPgtoTit'
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
                            , SitTitPgto              VARCHAR2(2)  PATH 'SitTitPgto')
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPC_PagadorEletronicoAgregadoIntf-IJDNPC_PagadorEletronicoAgregado' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:TituloResponse/JurosTit'
                      PASSING XMLTYPE(xml)
                      COLUMNS DtJurosTit              VARCHAR2(8)  PATH 'DtJurosTit'
                            , CodJurosTit             VARCHAR2(1)  PATH 'CodJurosTit'
                            , Vlr_PercJurosTit        VARCHAR2(20) PATH 'Vlr_PercJurosTit')
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPC_PagadorEletronicoAgregadoIntf-IJDNPC_PagadorEletronicoAgregado' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:TituloResponse/MultaTit'
                      PASSING XMLTYPE(xml)
                      COLUMNS DtMultaTit              VARCHAR2(8)  PATH 'DtMultaTit'
                            , CodMultaTit             VARCHAR2(1)  PATH 'CodMultaTit'
                            , Vlr_PercMultaTit        VARCHAR2(20) PATH 'Vlr_PercMultaTit');
    rw_dadostitulo    cr_dadostitulo%ROWTYPE;
    
    -- Cursor para ler os descontos do título
    CURSOR cr_desctitulo IS
      WITH DATA AS (SELECT pr_dsxmltit xml FROM dual)
      SELECT ROWNUM   idregist
           , TO_DATE(DtDesctTit,'YYYYMMDD') DtDesctTit
           , CodDesctTit
           , TO_NUMBER(Vlr_PercDesctTit) Vlr_PercDesctTit
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPC_PagadorEletronicoAgregadoIntf-IJDNPC_PagadorEletronicoAgregado' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:TituloResponse/RepetDesctTit/DesctTit'
                      PASSING XMLTYPE(xml)
                      COLUMNS DtDesctTit       VARCHAR2(8)  PATH 'DtDesctTit'
                            , CodDesctTit      VARCHAR2(1)  PATH 'CodDesctTit'
                            , Vlr_PercDesctTit VARCHAR2(20) PATH 'Vlr_PercDesctTit');

    -- Cursor para ler os valores calculados do boleto
    CURSOR cr_valorestitulo IS
      WITH DATA AS (SELECT pr_dsxmltit xml FROM dual)
      SELECT ROWNUM  idregist
           , TO_NUMBER(VlrCalcdJuros)         VlrCalcdJuros
           , TO_NUMBER(VlrCalcdMulta)         VlrCalcdMulta
           , TO_NUMBER(VlrCalcdDesct)         VlrCalcdDesct
           , TO_NUMBER(VlrTotCobrar )         VlrTotCobrar 
           , TO_DATE(DtValiddCalc,'YYYYMMDD') DtValiddCalc 
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPC_PagadorEletronicoAgregadoIntf-IJDNPC_PagadorEletronicoAgregado' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:TituloResponse/RepetCalcTit/CalcTit'
                      PASSING XMLTYPE(xml)
                      COLUMNS VlrCalcdJuros VARCHAR2(20) PATH 'VlrCalcdJuros'
                            , VlrCalcdMulta VARCHAR2(20) PATH 'VlrCalcdMulta'
                            , VlrCalcdDesct VARCHAR2(20) PATH 'VlrCalcdDesct'
                            , VlrTotCobrar  VARCHAR2(20) PATH 'VlrTotCobrar'
                            , DtValiddCalc  VARCHAR2(8)  PATH 'DtValiddCalc');
    
    -- Cursor para ler as baixas operacionais
    CURSOR cr_baixaoperacional IS
      WITH DATA AS (SELECT pr_dsxmltit xml FROM dual)
      SELECT ROWNUM  idregist
           , TO_NUMBER(NumIdentcBaixaOperac)                 NumIdentcBaixaOperac    
           , TO_NUMBER(NumRefAtlBaixaOperac)                 NumRefAtlBaixaOperac   
           , TO_NUMBER(NumSeqAtlzBaixaOperac)                NumSeqAtlzBaixaOperac  
           , TO_DATE(DtProcBaixaOperac,'YYYYMMDD')           DtProcBaixaOperac      
           , TO_DATE(DtHrProcBaixaOperac,'YYYYMMDDHH24MISS') DtHrProcBaixaOperac    
           , TO_DATE(DtHrSitBaixaOperac,'YYYYMMDDHH24MISS')  DtHrSitBaixaOperac     
           , TO_NUMBER(VlrBaixaOperacTit)                    VlrBaixaOperacTit      
           , NumCodBarrasBaixaOperac                         NumCodBarrasBaixaOperac
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPC_PagadorEletronicoAgregadoIntf-IJDNPC_PagadorEletronicoAgregado' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:TituloResponse/RepetBaixaOperac/BaixaOperac'
                      PASSING XMLTYPE(xml)
                      COLUMNS NumIdentcBaixaOperac    NUMBER       PATH 'NumIdentcBaixaOperac'
                            , NumRefAtlBaixaOperac    NUMBER       PATH 'NumRefAtlBaixaOperac'
                            , NumSeqAtlzBaixaOperac   NUMBER       PATH 'NumSeqAtlzBaixaOperac'
                            , DtProcBaixaOperac       VARCHAR2(8)  PATH 'DtProcBaixaOperac'
                            , DtHrProcBaixaOperac     VARCHAR2(14) PATH 'DtHrProcBaixaOperac'
                            , DtHrSitBaixaOperac      VARCHAR2(14) PATH 'DtHrSitBaixaOperac'
                            , VlrBaixaOperacTit       VARCHAR2(20) PATH 'VlrBaixaOperacTit'
                            , NumCodBarrasBaixaOperac VARCHAR2(44) PATH 'NumCodBarrasBaixaOperac');
    
    -- Cursor para ler as baixas operacionais
    CURSOR cr_baixaefetiva IS
      WITH DATA AS (SELECT pr_dsxmltit xml FROM dual)
      SELECT ROWNUM  idregist
           , TO_NUMBER(NumIdentcBaixaEft)                 NumIdentcBaixaEft    
           , TO_NUMBER(NumRefAtlBaixaEft)                 NumRefAtlBaixaEft   
           , TO_NUMBER(NumSeqAtlzBaixaEft)                NumSeqAtlzBaixaEft  
           , TO_DATE(DtProcBaixaEft,'YYYYMMDD')           DtProcBaixaEft      
           , TO_DATE(DtHrProcBaixaEft,'YYYYMMDDHH24MISS') DtHrProcBaixaEft    
           , TO_NUMBER(VlrBaixaEftTit)                    VlrBaixaEftTit      
           , NumCodBarrasBaixaEft                         NumCodBarrasBaixaEft
           , CanPgto                                      CanPgto
           , MeioPgto                                     MeioPgto
           , TO_DATE(DtHrSitBaixaEft,'YYYYMMDDHH24MISS')  DtHrSitBaixaEft
        FROM DATA
           , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                   ,'urn:JDNPC_PagadorEletronicoAgregadoIntf-IJDNPC_PagadorEletronicoAgregado' AS "NS1")
                                   ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:TituloResponse/RepetBaixaEft/BaixaEft'
                      PASSING XMLTYPE(xml)
                      COLUMNS NumIdentcBaixaEft    NUMBER       PATH 'NumIdentcBaixaEft' 
                            , NumRefAtlBaixaEft    NUMBER       PATH 'NumRefAtlBaixaEft'  
                            , NumSeqAtlzBaixaEft   NUMBER       PATH 'NumSeqAtlzBaixaEft'  
                            , DtProcBaixaEft       VARCHAR2(8)  PATH 'DtProcBaixaEft'
                            , DtHrProcBaixaEft     VARCHAR2(14) PATH 'DtHrProcBaixaEft'
                            , VlrBaixaEftTit       VARCHAR2(20) PATH 'VlrBaixaEftTit'
                            , NumCodBarrasBaixaEft VARCHAR2(44) PATH 'NumCodBarrasBaixaEft'
                            , CanPgto              NUMBER       PATH 'CanPgto'
                            , MeioPgto             NUMBER       PATH 'MeioPgto'
                            , DtHrSitBaixaEft      VARCHAR2(14) PATH 'DtHrSitBaixaEft');
                          
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
    pr_tbtitulo.DtJurosTit              := rw_dadostitulo.DtJurosTit;
    pr_tbtitulo.CodJurosTit             := rw_dadostitulo.CodJurosTit;
    pr_tbtitulo.Vlr_PercJurosTit        := rw_dadostitulo.Vlr_PercJurosTit;
    pr_tbtitulo.DtMultaTit              := rw_dadostitulo.DtMultaTit;
    pr_tbtitulo.CodMultaTit             := rw_dadostitulo.CodMultaTit;
    pr_tbtitulo.Vlr_PercMultaTit        := rw_dadostitulo.Vlr_PercMultaTit;
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
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrCalcdJuros := rw_valorestitulo.VlrCalcdJuros;    
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrCalcdMulta := rw_valorestitulo.VlrCalcdMulta;
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrCalcdDesct := rw_valorestitulo.VlrCalcdDesct;
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).VlrTotCobrar  := rw_valorestitulo.VlrTotCobrar;
      pr_tbtitulo.TabCalcTit(rw_valorestitulo.idregist).DtValiddCalc  := rw_valorestitulo.DtValiddCalc;
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


  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_wscip_requisitar_titulo(pr_cdlegado  IN VARCHAR2        --> Codigo Legado
                                      ,pr_nrispbif  IN VARCHAR2        --> Numero ISPB IF
                                      ,pr_idtitdda  IN NUMBER          --> Identificador Titulo DDA
                                      ,pr_dsxmltit OUT CLOB            --> Fragmento do XML de retorno
                                      ,pr_tpconcip OUT NUMBER          --> Tipo de Consulta CIP
                                      ,pr_des_erro OUT VARCHAR2        --> Indicador erro OK/NOK
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
    vr_dscritic      VARCHAR2(1000);
    
  BEGIN
    -- Indica que a rotina não foi executada por completo
    pr_des_erro := 'NOK';

    pr_tpconcip := 1; -- Indicar o tipo de consulta como CIP
    pr_dsxmltit := '<?xml version="1.0"?>
            <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/">
            <SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
            <NS1:TituloResponse xmlns:NS1="urn:JDNPC_PagadorEletronicoAgregadoIntf-IJDNPC_PagadorEletronicoAgregado"> 
              <NumCtrlPart xsi:type="xsd:string">12354561354641234567</NumCtrlPart>
              <ISPBPartRecbdrPrincipal xsi:type="xsd:int">12345678</ISPBPartRecbdrPrincipal>
              <ISPBPartRecebdrAdmtd xsi:type="xsd:int">12345678</ISPBPartRecebdrAdmtd>
              <NumIdentcTit xsi:type="xsd:int">1234567890132456789</NumIdentcTit>
              <DtHrSitTit xsi:type="xsd:string">20161229110435</DtHrSitTit>
              <ISPBPartDestinatario xsi:type="xsd:int">12345678</ISPBPartDestinatario>
              <CodPartDestinatario xsi:type="xsd:string">085</CodPartDestinatario>
              <TpPessoaBenfcrioOr xsi:type="xsd:string">F</TpPessoaBenfcrioOr>
              <CNPJ_CPFBenfcrioOr xsi:type="xsd:int">12345678901234</CNPJ_CPFBenfcrioOr>
              <Nom_RzSocBenfcrioOr xsi:type="xsd:string">ABCDEFDASGAGASGASAS ASDASASDASFASDLK ASFASFKJDSFLK</Nom_RzSocBenfcrioOr>
              <NomFantsBenfcrioOr xsi:type="xsd:string">SADFLKJHASDFLKJHASDFLKJ ASDFKJHASDFLKJHASDF KLJHASDFLKJHASDF KJHASDFKJHASDFLKJHK</NomFantsBenfcrioOr>
              <LogradBenfcrioOr xsi:type="xsd:string">POIUQWER OIUQWERPOIUQWEROUY QEWROIU QWER</LogradBenfcrioOr>
              <CidBenfcrioOr xsi:type="xsd:string">NBZXCVNBZXCM NMZXBCVMNBXCZV NMBXCV MNBX CVMNBXC DV</CidBenfcrioOr>
              <UFBenfcrioOr xsi:type="xsd:string">SC</UFBenfcrioOr>
              <CEPBenfcrioOr xsi:type="xsd:int">89042000</CEPBenfcrioOr>
              <TpPessoaBenfcrioFinl xsi:type="xsd:string">F</TpPessoaBenfcrioFinl>
              <CNPJ_CPFBenfcrioFinl xsi:type="xsd:int">12345678901234</CNPJ_CPFBenfcrioFinl>
              <Nom_RzSocBenfcrioFinl xsi:type="xsd:string">ASDOIEWVN IOENVAWOIAWNEVOAIW ENVAWOIEVNA WEOVINAWV</Nom_RzSocBenfcrioFinl>
              <NomFantsBenfcrioFinl xsi:type="xsd:string">IDFJAOSDIF ASDOIFJASDOIFJ DDFODIJFASD;OIASDDFOFIJA DOANSDVJNAKSUDVH ASKDHNASDHHK</NomFantsBenfcrioFinl>
              <TpPessoaPagdr xsi:type="xsd:string">J</TpPessoaPagdr>
              <CNPJ_CPFPagdr xsi:type="xsd:int">12345678901234</CNPJ_CPFPagdr>
              <Nom_RzSocPagdr xsi:type="xsd:string">ASDOIEWVN IOENVAWOIAWNEVOAIW ENVAWOIEVNA WEOVINAWV</Nom_RzSocPagdr>
              <NomFantsPagdr xsi:type="xsd:string">IDFJAOSDIF ASDOIFJASDOIFJ DDFODIJFASD;OIASDDFOFIJA DOANSDVJNAKSUDVH ASKDHNASDHHK</NomFantsPagdr>
              <CodMoedaCNAB xsi:type="xsd:string">99</CodMoedaCNAB>
              <NumCodBarras xsi:type="xsd:string">12345678901234567890123456789012345678901234</NumCodBarras>
              <NumLinhaDigtvl xsi:type="xsd:string">12345678901234567890123456789012345678901234567</NumLinhaDigtvl>
              <DtVencTit xsi:type="xsd:string">20161231</DtVencTit>
              <VlrTit xsi:type="xsd:float">98765432109876543,99</VlrTit>
              <CodEspTit xsi:type="xsd:string">25</CodEspTit>
              <QtdDiaPrott xsi:type="xsd:int">789789</QtdDiaPrott>
              <DtLimPgtoTit xsi:type="xsd:string">20170120</DtLimPgtoTit>
              <IndrBloqPgto xsi:type="xsd:string">N</IndrBloqPgto>
              <IndrPgtoParcl xsi:type="xsd:string">S</IndrPgtoParcl>
              <QtdPgtoParcl xsi:type="xsd:int">123</QtdPgtoParcl>
              <VlrAbattTit xsi:type="xsd:float">12345678901234567,99</VlrAbattTit>
              <JurosTit>
                <DtJurosTit xsi:type="xsd:string">20170115</DtJurosTit>
                <CodJurosTit xsi:type="xsd:string">5</CodJurosTit>
                <Vlr_PercJurosTit xsi:type="xsd:float">123456789012,55</Vlr_PercJurosTit>
              </JurosTit>
              <MultaTit>
                <DtMultaTit xsi:type="xsd:string">20170116</DtMultaTit>
                <CodMultaTit xsi:type="xsd:string">9</CodMultaTit>
                <Vlr_PercMultaTit xsi:type="xsd:float">123456789012,66</Vlr_PercMultaTit>
              </MultaTit>
              <RepetDesctTit>
                <DesctTit>
                  <DtDesctTit xsi:type="xsd:string">20170105</DtDesctTit>
                  <CodDesctTit xsi:type="xsd:string">8</CodDesctTit>
                  <Vlr_PercDesctTit xsi:type="xsd:float">123456789012,44</Vlr_PercDesctTit>
                </DesctTit>
                <DesctTit>
                  <DtDesctTit xsi:type="xsd:string">20170106</DtDesctTit>
                  <CodDesctTit xsi:type="xsd:string">8</CodDesctTit>
                  <Vlr_PercDesctTit xsi:type="xsd:float">123456789012,50</Vlr_PercDesctTit>
                </DesctTit>
              </RepetDesctTit>
              <IndrVlr_PercMinTit xsi:type="xsd:string">P</IndrVlr_PercMinTit>
              <Vlr_PercMinTit xsi:type="xsd:float">123456789012,55</Vlr_PercMinTit>
              <IndrVlr_PercMaxTit xsi:type="xsd:string">P</IndrVlr_PercMaxTit>
              <Vlr_PercMaxTit xsi:type="xsd:float">123456789012</Vlr_PercMaxTit>
              <TpModlCalc xsi:type="xsd:string">04</TpModlCalc>
              <TpAutcRecbtVlrDivgte xsi:type="xsd:string">04</TpAutcRecbtVlrDivgte>
              <RepetCalcTit>
                <CalcTit>
                  <VlrCalcdJuros xsi:type="xsd:float">12345678901234567,11</VlrCalcdJuros>
                  <VlrCalcdMulta xsi:type="xsd:float">12345678901234567,11</VlrCalcdMulta>
                  <VlrCalcdDesct xsi:type="xsd:float">12345678901234567,11</VlrCalcdDesct>
                  <VlrTotCobrar xsi:type="xsd:float">12345678901234567,11</VlrTotCobrar>
                  <DtValiddCalc xsi:type="xsd:string">20161228</DtValiddCalc>
                </CalcTit>
                <CalcTit>
                  <VlrCalcdJuros xsi:type="xsd:float">12345678907654321,22</VlrCalcdJuros>
                  <VlrCalcdMulta xsi:type="xsd:float">12345678907654321,22</VlrCalcdMulta>
                  <VlrCalcdDesct xsi:type="xsd:float">12345678907654321,22</VlrCalcdDesct>
                  <VlrTotCobrar xsi:type="xsd:float">12345678907654321,22</VlrTotCobrar>
                  <DtValiddCalc xsi:type="xsd:string">20161229</DtValiddCalc>
                </CalcTit>
                <CalcTit>
                  <VlrCalcdJuros xsi:type="xsd:float">12345678909876543,33</VlrCalcdJuros>
                  <VlrCalcdMulta xsi:type="xsd:float">12345678909876543,33</VlrCalcdMulta>
                  <VlrCalcdDesct xsi:type="xsd:float">12345678909876543,33</VlrCalcdDesct>
                  <VlrTotCobrar xsi:type="xsd:float">12345678909876543,33</VlrTotCobrar>
                  <DtValiddCalc xsi:type="xsd:string">20161230</DtValiddCalc>
                </CalcTit>
              </RepetCalcTit>
              <QtdPgtoParclRegtd xsi:type="xsd:int">123</QtdPgtoParclRegtd>
              <VlrSldTotAtlPgtoTit xsi:type="xsd:float">11111111111111111,22</VlrSldTotAtlPgtoTit>
              <RepetBaixaOperac>
                <BaixaOperac>
                  <NumIdentcBaixaOperac xsi:type="xsd:int">1234567890123456789</NumIdentcBaixaOperac>
                  <NumRefAtlBaixaOperac xsi:type="xsd:int">1234567890123456789</NumRefAtlBaixaOperac>
                  <NumSeqAtlzBaixaOperac xsi:type="xsd:int">1234567890123456789</NumSeqAtlzBaixaOperac>
                  <DtProcBaixaOperac xsi:type="xsd:string">20170105</DtProcBaixaOperac>
                  <DtHrProcBaixaOperac xsi:type="xsd:string">20170106200542</DtHrProcBaixaOperac>
                  <DtHrSitBaixaOperac xsi:type="xsd:string">20170106200602</DtHrSitBaixaOperac>
                  <VlrBaixaOperacTit xsi:type="xsd:float">12345678909876543,99</VlrBaixaOperacTit>
                  <NumCodBarrasBaixaOperac xsi:type="xsd:string">98765432109876543210987654321098765432109876</NumCodBarrasBaixaOperac>
                </BaixaOperac>
                <BaixaOperac>
                  <NumIdentcBaixaOperac xsi:type="xsd:int">9876543210987654321</NumIdentcBaixaOperac>
                  <NumRefAtlBaixaOperac xsi:type="xsd:int">9876543210987654321</NumRefAtlBaixaOperac>
                  <NumSeqAtlzBaixaOperac xsi:type="xsd:int">9876543210987654321</NumSeqAtlzBaixaOperac>
                  <DtProcBaixaOperac xsi:type="xsd:string">20170106</DtProcBaixaOperac>
                  <DtHrProcBaixaOperac xsi:type="xsd:string">20170107200542</DtHrProcBaixaOperac>
                  <DtHrSitBaixaOperac xsi:type="xsd:string">20170107200602</DtHrSitBaixaOperac>
                  <VlrBaixaOperacTit xsi:type="xsd:float">12345678909879876,98</VlrBaixaOperacTit>
                  <NumCodBarrasBaixaOperac xsi:type="xsd:string">98754321098765432109876543210987654321065842</NumCodBarrasBaixaOperac>
                </BaixaOperac>
              </RepetBaixaOperac>
              <RepetBaixaEft>
                <BaixaEft>
                  <NumIdentcBaixaEft xsi:type="xsd:int">9876543210987654321</NumIdentcBaixaEft>
                  <NumRefAtlBaixaEft xsi:type="xsd:int">9876543210987654321</NumRefAtlBaixaEft>
                  <NumSeqAtlzBaixaEft xsi:type="xsd:int">9876543210987654321</NumSeqAtlzBaixaEft>
                  <DtProcBaixaEft xsi:type="xsd:string">20170106</DtProcBaixaEft>
                  <DtHrProcBaixaEft xsi:type="xsd:string">20170107202015</DtHrProcBaixaEft>
                  <VlrBaixaEftTit xsi:type="xsd:float">12345678909879876,98</VlrBaixaEftTit>
                  <NumCodBarrasBaixaEft xsi:type="xsd:string">98754321098765432109876543210987654321065842</NumCodBarrasBaixaEft>
                  <CanPgto xsi:type="xsd:int">4</CanPgto>
                  <MeioPgto xsi:type="xsd:int">3</MeioPgto>
                  <DtHrSitBaixaEft xsi:type="xsd:string">20170120160105</DtHrSitBaixaEft>
                </BaixaEft>
              </RepetBaixaEft>
              <SitTitPgto xsi:type="xsd:string">5</SitTitPgto>
            </NS1:TituloResponse>
            </SOAP-ENV:Body>
            </SOAP-ENV:Envelope>';
    
    -- Indica que a rotina foi executada com sucesso
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_dscritic := SQLERRM;
      pr_des_erro := 'NOK';
  END pc_wscip_requisitar_titulo;

  
  

END NPCB0003;
/
