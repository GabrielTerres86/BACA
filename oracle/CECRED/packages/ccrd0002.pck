CREATE OR REPLACE PACKAGE CECRED.CCRD0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCRD0002
  --  Sistema  : Rotinas genericas referente ao CABAL
  --  Sigla    : CCRD
  --  Autor    : Adriano - CECRED
  --  Data     : Abril - 2014.                   Ultima atualizacao: 06/12/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas referente a mensageria CABALISO

  -- Alteracoes: Oscar - Substituir aspas duplas no id do terminal causando exeption no isobrige
  --
  --             01/12/2014 - Ajuste para pegar a sequencia do lancamento apartir da sequence. (James)
  --             28/01/2015 - Quando DataAtual > dtmvtocd, utilizar 'dtmvtopr' senao 'dtmvtocd'. 
  --                          (Jaison - SD: 246552)
  --             
  --             18/03/2015 - Ajuste no bit41 da procedure pc_trata_mensagem_cabal para quando a mensagem vier
  --                          com o caracter &quot; nao converter para aspas duplas. (James)                              
  --
  --             16/02/2016 - Ajustes referentes ao projeto melhoria 157(Lucas Ranghetti #330322)
  --             06/04/2016 - Retirar o lote, ajuste de lançamento duplicado quando a ordem das mensagens
  ---                         chega invertida (420, 220, 200), ajustes de performance. (Oscar 379672)  
  --
  --             06/12/2016 - Tratado cursor cr_crapcrd para buscar apenas o cartao na
  --                          cooperativa que esta ativa (Incorporacao Transposul). 
  --                          (Fabricio)
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina tratar as mensagens referente ao CABAL 
  PROCEDURE pc_trata_mensagem_cabal(pr_req_xml IN VARCHAR2,
                                    pr_res_xml OUT VARCHAR2,
                                    pr_dsretorn OUT VARCHAR2, --OK - NOK
                                    pr_pcdcriti OUT NUMBER,
                                    pr_pdscriti OUT VARCHAR2);

  -- Monta o xml de retorno e o envia a cabal
  PROCEDURE pc_gera_retorno_cabal(pr_tpmensag IN crapdcb.tpmensag%TYPE,
                                  pr_nrcrcard IN crapdcb.nrcrcard%TYPE,
                                  pr_cdproces IN crapdcb.cdproces%TYPE,
                                  pr_vldtrans IN crapdcb.vldtrans%TYPE,
                                  pr_nrnsucap IN crapdcb.nrnsucap%TYPE,
                                  pr_dtorigem IN NUMBER,
                                  pr_hrorigem IN NUMBER,
                                  pr_cdredorg IN NUMBER,
                                  pr_idtrterm IN crapdcb.idtrterm%TYPE,
                                  pr_cddmoeda IN crapdcb.cddmoeda%TYPE,
                                  pr_cdhislan IN VARCHAR2,
                                  pr_cdrespos IN VARCHAR2,
                                  pr_cdgerred IN NUMBER,
                                  pr_vlsddisp IN NUMBER,
                                  pr_dtdtrgmt IN VARCHAR2,
                                  pr_res_xml  OUT VARCHAR2,
                                  pr_cdautori OUT crapdcb.cdautori%TYPE,
                                  pr_des_reto OUT VARCHAR2, --OK - NOK
                                  pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                  pr_dscritic OUT crapcri.dscritic%TYPE);

  -- Responsável por gravar na base as mensagens de recebeimento e resposta do sistema CABAl.
  PROCEDURE pc_grava_mensagem_cabal(pr_tpmensag IN crapdcb.tpmensag%TYPE,
                                    pr_tpmsgres IN crapdcb.tpmensag%TYPE,
                                    pr_nrnsucap IN crapdcb.nrnsucap%TYPE,
                                    pr_dtdtrgmt IN VARCHAR2,
                                    pr_cdcooper IN crapdcb.cdcooper%TYPE,
                                    pr_nrdconta IN crapdcb.nrdconta%TYPE,
                                    pr_cdagenci IN crapdcb.cdagenci%TYPE,
                                    pr_dstrorig IN crapdcb.dstrorig%TYPE,
                                    pr_dstrreto IN crapdcb.dstrorig%TYPE,
                                    pr_cdautori IN crapdcb.cdautori%TYPE,
                                    pr_vldtrans IN crapdcb.vldtrans%TYPE,
                                    pr_nrcrcard IN crapdcb.nrcrcard%TYPE,
                                    pr_cdhislan IN crapdcb.cdhistor%TYPE,
                                    pr_cdproces IN crapdcb.cdproces%TYPE,
                                    pr_cddmoeda IN crapdcb.cddmoeda%TYPE,
                                    pr_idtrterm IN crapdcb.idtrterm%TYPE,
                                    pr_cdtrresp IN crapdcb.cdtrresp%TYPE,
                                    pr_dtorigem IN crapdcb.dtdtrans%TYPE,
                                    pr_dsdtrans IN crapdcb.dsdtrans%TYPE,
                                    pr_nrinstit IN crapdcb.nrinstit%TYPE,                                    
                                    pr_dtmvtolt IN crapdcb.dtmvtolt%TYPE,
                                    pr_nrnsuori IN crapdcb.nrnsuori%TYPE,                                   
                                    pr_des_reto OUT VARCHAR2,
                                    pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                    pr_dscritic OUT crapcri.dscritic%TYPE);

  -- Procedure responsavel por criar e atualizar o lote        
  -- Procedure responsavel por gerar o credíto/débito na conta                             
  PROCEDURE pc_cria_lancamento_cc(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                                  pr_cdagenci IN crapass.cdagenci%TYPE,
                                  pr_cdbccxlt IN craperr.nrdcaixa%TYPE,
                                  pr_nrdolote IN craplot.nrdolote%TYPE,
                                  pr_nrdconta IN crapepr.nrdconta%TYPE,
                                  pr_cdhistor IN craphis.cdhistor%TYPE,
                                  pr_vllanmto IN NUMBER,
                                  pr_nrcrcard IN crapdcb.nrcrcard%TYPE,
                                  pr_nrdocmto IN craplcm.nrdocmto%TYPE,
                                  pr_dtrefere IN craplcm.dtrefere%TYPE,
                                  pr_hrtransa IN craplcm.hrtransa%TYPE,
                                  pr_cdorigem IN craplcm.cdorigem%TYPE,
                                  pr_des_reto OUT VARCHAR2,
                                  pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                  pr_dscritic OUT crapcri.dscritic%TYPE);
                                  
  /* Retonar o numero unico da transação */
  FUNCTION fn_busca_nsu_transacao(pr_tpmensag in crapdcb.tpmensag%TYPE, --> Tipo da mensagem
                                  pr_nrnsucap in crapdcb.nrnsucap%TYPE, --> NSU da transacao de origem
                                  pr_dtdtrgmt in VARCHAR2)              --> Data e Hora da transacao de origem MMDDHHMISS
                                  RETURN NUMBER; 
END CCRD0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CCRD0002 AS

  -- Definir um record para formatar dados da MSG de resposta.
    TYPE typ_reg_dados_msg_iso IS
      RECORD (tpmensag VARCHAR2(04),
              nrcrcard VARCHAR2(16),
              cdproces VARCHAR2(06),
              vldtrans VARCHAR2(12),
              nrnsucap VARCHAR2(06),
              dtorigem VARCHAR2(04),
              hrorigem VARCHAR2(06),
              cdredorg VARCHAR2(11),
              idtrterm crapdcb.idtrterm%TYPE,
              cddmoeda VARCHAR2(03),
              cdhislan VARCHAR2(10),      
              cdrespos VARCHAR2(02),
              cdgerred VARCHAR2(03),
              vlsddisp VARCHAR2(20),
              cdautori VARCHAR2(06),
              dtdtrgmt VARCHAR2(10));

  -- Indentificar se lancamento foi feito 
  CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE,
                    pr_cdagenci IN craplcm.cdagenci%TYPE,
                    pr_cdbccxlt IN craplcm.cdbccxlt%TYPE,
                    pr_nrdolote IN craplcm.nrdolote%TYPE,
                    pr_nrdconta IN craplcm.nrdconta%TYPE,
                    pr_nrdocmto IN craplcm.nrdocmto%TYPE,
                    pr_nrcrcard IN crapdcb.nrcrcard%TYPE,
                    pr_vldtrans IN craplcm.vllanmto%TYPE,
                    pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) IS

    SELECT 1 FROM craplcm
     WHERE craplcm.cdcooper = pr_cdcooper
       AND craplcm.cdagenci = pr_cdagenci
       AND craplcm.cdbccxlt = pr_cdbccxlt
       AND craplcm.nrdolote = pr_nrdolote
       AND craplcm.nrdconta = pr_nrdconta
       AND craplcm.nrdctabb = pr_nrdconta
       AND craplcm.nrdocmto = pr_nrdocmto 
       AND craplcm.cdpesqbb = pr_nrcrcard
       AND craplcm.vllanmto = pr_vldtrans
       AND craplcm.dtmvtolt >= pr_dtmvtoan
       AND rownum = 1;
  
  rw_craplcm cr_craplcm%ROWTYPE;
  
  -- Cursor cooperativa 
  CURSOR cr_crapcop (pr_cdcooper in crapcop.cdcooper%TYPE) IS
  SELECT crapcop.cdcooper 
    FROM crapcop 
   WHERE crapcop.cdcooper = pr_cdcooper;

  rw_crapcop cr_crapcop%ROWTYPE;  

  -- Cursor generico de calendario
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  -- Cursor para encontrar as informações do cartão
  CURSOR cr_crapcrd (pr_nrcrcard IN crapcrd.nrcrcard%TYPE) IS
  SELECT crd.cdcooper
        ,crd.nrdconta
        ,crd.nrctrcrd
    FROM crapcrd crd,
         crapcop cop
   WHERE cop.cdcooper = crd.cdcooper
     AND crd.nrcrcard = pr_nrcrcard
     AND crd.cdadmcrd >= 10  --Bancoob 
     AND crd.cdadmcrd <= 80  --Bancoob
     AND cop.flgativo = 1;
  rw_crapcrd cr_crapcrd%ROWTYPE;
   
  -- Cursor para buscar as informações do associado
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
  SELECT ass.cdcooper
        ,ass.nrdconta
        ,ass.cdagenci
        ,ass.vllimcre
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  -- Cursor para buscar regitro da mensagem
  CURSOR cr_crapdcb(pr_tpmensag IN crapdcb.tpmensag%TYPE
                   ,pr_nrnsucap IN crapdcb.nrnsucap%TYPE
                   ,pr_dtdtrgmt IN crapdcb.dtdtrgmt%TYPE
                   ,pr_hrdtrgmt IN crapdcb.hrdtrgmt%TYPE
                   ,pr_cdcooper IN crapdcb.cdcooper%TYPE
                   ,pr_nrdconta IN crapdcb.nrdconta%TYPE) IS
  SELECT 1
    FROM crapdcb dcb
   WHERE UPPER(dcb.tpmensag) = pr_tpmensag
     AND dcb.nrnsucap = pr_nrnsucap
     AND dcb.dtdtrgmt = pr_dtdtrgmt
     AND dcb.hrdtrgmt = pr_hrdtrgmt
     AND dcb.cdcooper = pr_cdcooper
     AND dcb.nrdconta = pr_nrdconta
     AND ROWNUM = 1;
  rw_crapdcb cr_crapdcb%ROWTYPE;
   
   CURSOR cr_crapdcb_nrnsuori
                    (pr_tpmensag IN crapdcb.tpmensag%TYPE
                    ,pr_dtdtrgmt IN crapdcb.dtdtrgmt%TYPE
                    ,pr_nrnsuori IN crapdcb.nrnsuori%TYPE
                    ,pr_cdcooper IN crapdcb.cdcooper%TYPE
                    ,pr_nrdconta IN crapdcb.nrdconta%TYPE) IS
   SELECT 1
     FROM crapdcb dcb
    WHERE UPPER(dcb.tpmensag) = pr_tpmensag
      AND dcb.dtdtrgmt = pr_dtdtrgmt
      AND dcb.nrnsuori = pr_nrnsuori
      AND dcb.cdcooper = pr_cdcooper
      AND dcb.nrdconta = pr_nrdconta
      AND rownum = 1;

   rw_crapdcb_nrnsuori cr_crapdcb_nrnsuori%ROWTYPE;
 
    -- cursor para busca dos vinculos da transacao bancoob
    CURSOR cr_craphcb (pr_cdtrnbcb IN craphcb.cdtrnbcb%TYPE
                      ,pr_cdcooper IN craphis.cdcooper%TYPE) IS
    SELECT tbcrd.cdhistor
      FROM craphcb hcb,
           tbcrd_his_vinculo_bancoob tbcrd
   JOIN craphis ON craphis.cdcooper = pr_cdcooper
                  AND craphis.cdhistor = tbcrd.cdhistor

     WHERE hcb.cdtrnbcb = pr_cdtrnbcb
       AND tbcrd.cdtrnbcb = hcb.cdtrnbcb
       AND tbcrd.tphistorico = 0; -- 0 - ONLINE/ 1 - OFFLINE  
  rw_craphcb cr_craphcb%ROWTYPE;

  FUNCTION fn_busca_nsu_transacao(pr_tpmensag in crapdcb.tpmensag%TYPE, --> Tipo da mensagem
                                  pr_nrnsucap in crapdcb.nrnsucap%TYPE, --> NSU da transacao de origem
                                  pr_dtdtrgmt in VARCHAR2               --> Data da transacao de origem
                                  ) RETURN NUMBER IS
      
      vr_nrdocmto  craplcm.nrdocmto%TYPE;  
  BEGIN
      /* TTTT - Tipo de Mensagem
         NNNNNN - NSU Rede
         MMDDHHMISS - Data Hora transação (Bit 7)
      */  
      vr_nrdocmto := TO_NUMBER(TRIM(pr_tpmensag) || 
                               TRIM(TO_CHAR(pr_nrnsucap, '000000')) || 
                               TRIM(TO_CHAR(pr_dtdtrgmt))); 
      RETURN vr_nrdocmto;                                
  END fn_busca_nsu_transacao;

  -- Rotina para tratar a mensageria CABAL 
  PROCEDURE pc_trata_mensagem_cabal(pr_req_xml IN VARCHAR2,
                                    pr_res_xml OUT VARCHAR2,
                                    pr_dsretorn OUT VARCHAR2, --OK - NOK
                                    pr_pcdcriti OUT NUMBER,
                                    pr_pdscriti OUT VARCHAR2) IS
  BEGIN    
    DECLARE
    
      -- Variáveis para leitura do XML
      vr_xmltype XMLTYPE;
      
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_exc_sair EXCEPTION;
      
      -- Temp-Table com o saldo do dia
      vr_tab_sald EXTR0001.typ_tab_saldos; 
      
      -- Temp-table para armazenar o erro
      vr_tab_erro GENE0001.typ_tab_erro;
      
      -- Variaveis para receber as informações do xml
      vr_tpmensag crapdcb.tpmensag%TYPE;
      vr_tpmsgres crapdcb.tpmensag%TYPE;      
      vr_nrcrcard crapdcb.nrcrcard%TYPE;      
      vr_cdproces crapdcb.cdproces%TYPE;
      vr_vldtrans NUMBER(12); 
      vr_dtdtrgmt VARCHAR2(10) := (TO_CHAR(SYSDATE,'MMDD') || TO_CHAR(SYSDATE,'HH24MMSS'));
      vr_nrnsucap crapdcb.nrnsucap%TYPE;
      vr_dtorigem VARCHAR2(4);
      vr_hrorigem VARCHAR2(6);
      vr_cdredorg VARCHAR2(11);
      vr_idtrterm crapdcb.idtrterm%TYPE;
      vr_cddmoeda crapdcb.cddmoeda%TYPE;
      vr_infbit62 VARCHAR2(100);
      vr_dstrorig crapdcb.dstrorig%TYPE;
      vr_nmdoesta VARCHAR2(40);
      vr_cddsenha VARCHAR2(16);
      vr_cdgerred NUMBER(3);
      vr_dadtrnor VARCHAR2(42);      
      vr_cdrespos VARCHAR2(2) := '00'; -- '00' (Aprovar)
      vr_cdautori crapdcb.cdautori%TYPE;
      vr_exlancta BOOLEAN := FALSE;
      vr_dtrefere DATE;
      -- Indice sobre a temp-table vr_tab_sald
      vr_ind_sald PLS_INTEGER;  
      
      -- Valor de saldo disponivel			
      vr_vlsddisp NUMBER(17,2); 
      -- Numero unico da transacao 
      vr_nrdocmto craplcm.nrdocmto%TYPE := 0;
      -- Numero unico da transacao de origem
      vr_nrdoctro craplcm.nrdocmto%TYPE := 0;
      vr_cdhistor craplcm.cdhistor%TYPE := 0;
      vr_nrnsuori crapdcb.nrnsuori%TYPE := 0;
  
      BEGIN    
        -- BLOCO PARA TRATAR O XML
        DECLARE
        
          -- Variáveis para tratamento do XML
          vr_node_list       xmldom.DOMNodeList;
          vr_parser          xmlparser.Parser;
          vr_doc             xmldom.DOMDocument;
          vr_lenght          NUMBER;
          vr_node_name       VARCHAR2(100);
          vr_item_node       xmldom.DOMNode;
          vr_node_root       xmldom.DOMNode; -- <isomsg>
          vr_node_field      xmldom.DOMNode; -- <field>    

        BEGIN
          vr_dstrorig := pr_req_xml;
          pr_pdscriti := '';
          pr_pcdcriti := 0;
          -- Cria o XML a partir do CLOB carregado
          vr_xmltype := XMLType.createxml(pr_req_xml);

          -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
          vr_parser := xmlparser.newParser;
          xmlparser.parseClob(vr_parser,vr_xmltype.getClobVal());
          vr_doc := xmlparser.getDocument(vr_parser);
          xmlparser.freeParser(vr_parser);

          -- Faz o get de toda a lista de elementos
          vr_node_list := xmldom.getElementsByTagName(vr_doc,'*');
          vr_lenght := xmldom.getLength(vr_node_list);

          -- Percorrer os elementos
          FOR i IN 0..vr_lenght-1 LOOP
          
            -- Pega o item
            vr_item_node := xmldom.item(vr_node_list, i);

            -- Captura o nome do nodo
            vr_node_name := xmldom.getNodeName(vr_item_node);

            -- Verifica qual nodo esta sendo lido
            IF upper(vr_node_name) = 'ISOMSG' THEN
               vr_node_root := vr_item_node;
               vr_node_field:= NULL;
               CONTINUE; -- Descer para o próximo filho
               
            ELSIF upper(vr_node_name) = 'FIELD' THEN

              vr_node_field  := vr_item_node;              
                         
              -- Código da mensagem
              IF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 0 THEN
                vr_tpmensag := xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value');   
                
                -- Pega o código da mensagem de retorno de acordo com o tipo de mensagem recebida
                CASE vr_tpmensag
                  -- Transações de compra a vista com cartão na função débito ou Saque em ATM com cartão na função débito
                  WHEN '0200' THEN 
                    -- Resposta da transação de compra a vista com cartão na função débito ou Resposta saque em ATM com cartão na função débito  
                    vr_tpmsgres := '0210';
                  -- Mensagem de aviso de transação de compra ou saque off-line
                  WHEN '0220' THEN 
                    -- Resposta do aviso transação de compra ou saque off-line
                    vr_tpmsgres := '0230';
                  -- Desfazimento de compra ou saque com cartão na função débito
                  WHEN '0420' THEN 
                    -- Resposta de desfazimento de compra ou saque com cartão na função débito
                    vr_tpmsgres := '0430';
                  -- Cancelamento de compra ou saque em ATM com cartão na função débito
                  WHEN '0400' THEN 
                    -- Resposta de cancelamento de compra ou saque em ATM com car~tao na função débito
                    vr_tpmsgres := '0410';
                  -- Consulta de saldo da conta corrente em ATM
                  WHEN '0900' THEN 
                    -- Resposta de consulta de saldo da conta corrente em ATM
                    vr_tpmsgres := '0910';
                  -- Echo teste
                  WHEN '0800' THEN 
                    -- Resposta de Echo test
                    vr_tpmsgres := '0810';
                  -- Desbloqueio e troca de senha
                  WHEN '9080' THEN 
                    -- Resposta de desbloqueio e troca de senha
                    vr_tpmsgres := '9090';
                  -- Cancelamento do cartão on-line
                  WHEN '9085' THEN 
                    -- Resposta de cancelamento do cartão on-line
                    vr_tpmsgres := '9095';

                END CASE;
                
              -- Número do cartão
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 2 THEN
                vr_nrcrcard := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value'));
                
              --  Código do processo 
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 3 THEN
                vr_cdproces := xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value');   
                
              -- Valor da transação  
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 4 THEN
                vr_vldtrans := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value'));   
                
              -- Data e hora GMT
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 7 THEN                
                vr_dtdtrgmt := xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value');
                
              -- NSU origem  
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 11 THEN
                vr_nrnsucap := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value'));                   
                
              -- Hora de origem  
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 12 THEN
               vr_hrorigem := xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value');
               
              -- Data de origem
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 13 THEN
                vr_dtorigem := xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value');
                
              -- Código da rede de origem
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 32 THEN
                vr_cdredorg := xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value');                                   
              
              -- Identificação do terminal  
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 41 THEN
                vr_idtrterm := replace(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value'),'"','&quot;');
                
              -- Nome do estabelecimento
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 43 THEN
                vr_nmdoesta := xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value');
                   
              -- Código da moeda
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 49 THEN
                vr_cddmoeda := TO_NUMBER(to_char(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value')));

              -- Senha criptografada 
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 52 THEN
                vr_cddsenha := to_char(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value'));                
                
              -- Recebe uma informação especifica da mensagem que está sendo tratada
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 62 THEN
                IF ((vr_tpmensag = '9085') OR (vr_tpmensag = '9080')) THEN
                   vr_infbit62 := '0';  
                ELSE
                   vr_infbit62 := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value'));  
                END IF;
              -- Código de gerenciamento de rede
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 70 THEN
                vr_cdgerred := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value'));                
              
              -- Dados da transação original
              ELSIF TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'id'),'9999') = 90 THEN
                vr_dadtrnor := xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_field),'value');                
              
              END IF;            
              CONTINUE; -- Descer para o próximo filho          
            ELSE              
              CONTINUE; -- Descer para o próximo filho
            END IF;
         
        END LOOP;
          
        -- Echo test
        IF vr_tpmensag = '0800' THEN 
          -- Gera mensagem de retorno
          pc_gera_retorno_cabal(pr_tpmensag => vr_tpmsgres
                               ,pr_nrcrcard => vr_nrcrcard
                               ,pr_cdproces => vr_cdproces
                               ,pr_vldtrans => vr_vldtrans                              
                               ,pr_nrnsucap => vr_nrnsucap                               
                               ,pr_dtorigem => vr_dtorigem
                               ,pr_hrorigem => vr_hrorigem
                               ,pr_cdredorg => vr_cdredorg
                               ,pr_idtrterm => vr_idtrterm
                               ,pr_cddmoeda => vr_cddmoeda
                               ,pr_cdhislan => vr_infbit62
                               ,pr_cdrespos => vr_cdrespos
                               ,pr_cdgerred => vr_cdgerred
                               ,pr_res_xml  => pr_res_xml
                               ,pr_vlsddisp => vr_vlsddisp
                               ,pr_dtdtrgmt => vr_dtdtrgmt
                               ,pr_cdautori => vr_cdautori
                               ,pr_des_reto => pr_dsretorn
                               ,pr_cdcritic => pr_pcdcriti
                               ,pr_dscritic => pr_pdscriti);                               
                               
          -- Se houve retorno não Ok
          IF pr_dsretorn <> 'OK' THEN
            pr_res_xml := NULL;
            -- Monta mensagem de critica
            IF pr_pcdcriti = 0 AND pr_pdscriti IS NULL THEN
               pr_pdscriti := 'Nao foi possivel gerar mensagem de retorno (' || vr_tpmsgres || ') - CABAL.';
            END IF;
              
            -- Gera exceção
            RAISE vr_exc_erro;
          END IF;       
                                   
          -- Retorno OK
          pr_dsretorn := 'OK';
          
          RETURN;
        END IF;
        
        -- Busca informações do cartão
        OPEN cr_crapcrd(pr_nrcrcard => vr_nrcrcard);         
        FETCH cr_crapcrd INTO rw_crapcrd;
                  
        -- Se não encontrar
        IF cr_crapcrd%NOTFOUND THEN
          
          -- Fecha o cursor pois haverá RAISE
          CLOSE cr_crapcrd;
          
          -- Mensagem de cancelamento
          IF vr_tpmensag IN ('9080','9085') THEN
            vr_cdrespos := '00';
          ELSE  
            vr_cdrespos := '76'; -- Conta Corrente com problemas
            
          END IF;
          
          -- Gera mensagem de retorno
          pc_gera_retorno_cabal(pr_tpmensag => vr_tpmsgres
                               ,pr_nrcrcard => vr_nrcrcard
                               ,pr_cdproces => vr_cdproces
                               ,pr_vldtrans => vr_vldtrans 
                               ,pr_nrnsucap => vr_nrnsucap                               
                               ,pr_dtorigem => vr_dtorigem
                               ,pr_hrorigem => vr_hrorigem
                               ,pr_cdredorg => vr_cdredorg
                               ,pr_idtrterm => vr_idtrterm
                               ,pr_cddmoeda => vr_cddmoeda
                               ,pr_cdhislan => vr_infbit62
                               ,pr_cdrespos => vr_cdrespos
                               ,pr_res_xml  => pr_res_xml
                               ,pr_cdgerred => vr_cdgerred
                               ,pr_vlsddisp => vr_vlsddisp
                               ,pr_dtdtrgmt => vr_dtdtrgmt
                               ,pr_cdautori => vr_cdautori
                               ,pr_des_reto => pr_dsretorn
                               ,pr_cdcritic => pr_pcdcriti
                               ,pr_dscritic => pr_pdscriti);
                    
          -- Se houve retorno não Ok
          IF pr_dsretorn <> 'OK' THEN
             pr_res_xml := NULL;
            -- Monta mensagem de critica
            IF pr_pcdcriti = 0 AND pr_pdscriti IS NULL THEN
              pr_pdscriti := 'Nao foi possivel gerar mensagem de retorno (' || vr_tpmsgres || ') - CABAL.';
            END IF;
            
            -- Gera exceção
            RAISE vr_exc_erro;
          END IF;
          
          -- Mensagem de cancelamento
          IF vr_tpmensag IN ('9080','9085') THEN
            RAISE vr_exc_sair;
          ELSE
            -- Monta a mensagem de critica
            pr_pcdcriti := 546;
            pr_pdscriti := gene0001.fn_busca_critica(pr_cdcritic => pr_pcdcriti);   
                     
            -- Gera exceção
            RAISE vr_exc_erro;          
          END IF;
          
        ELSE
          -- Apenas fecha o cursor
          CLOSE cr_crapcrd;         
        END IF;
        
        -- Busca dados do associado
        OPEN cr_crapass(pr_cdcooper => rw_crapcrd.cdcooper
                       ,pr_nrdconta => rw_crapcrd.nrdconta);            
        FETCH cr_crapass INTO rw_crapass;
                  
        IF cr_crapass%NOTFOUND THEN
          -- Fecha o cursor pois havera RAISE
          CLOSE cr_crapass;
          
          -- Gera mensagem de retorno Conta Corrente com problemas
          pc_gera_retorno_cabal(pr_tpmensag => vr_tpmsgres
                               ,pr_nrcrcard => vr_nrcrcard
                               ,pr_cdproces => vr_cdproces
                               ,pr_vldtrans => vr_vldtrans 
                               ,pr_nrnsucap => vr_nrnsucap
                               ,pr_dtorigem => vr_dtorigem
                               ,pr_hrorigem => vr_hrorigem
                               ,pr_cdredorg => vr_cdredorg
                               ,pr_idtrterm => vr_idtrterm
                               ,pr_cddmoeda => vr_cddmoeda
                               ,pr_cdhislan => vr_infbit62
                               ,pr_cdrespos => 76
                               ,pr_res_xml  => pr_res_xml
                               ,pr_cdgerred => vr_cdgerred
                               ,pr_vlsddisp => vr_vlsddisp
                               ,pr_dtdtrgmt => vr_dtdtrgmt
                               ,pr_cdautori => vr_cdautori
                               ,pr_des_reto => pr_dsretorn
                               ,pr_cdcritic => pr_pcdcriti
                               ,pr_dscritic => pr_pdscriti);          
                               
           -- Se houve retorno não Ok
          IF pr_dsretorn <> 'OK' THEN
            -- Monta a mensagem de critica
            pr_res_xml := NULL;
            IF pr_pcdcriti = 0 AND pr_pdscriti IS NULL THEN
              pr_pdscriti := 'Nao foi possivel gerar mensagem de retorno (' || vr_tpmsgres || ') - CABAL.';
            END IF;
            
            -- Gera exceção
            RAISE vr_exc_erro;
          END IF;

          -- Monta a mensagem de critica
          pr_pcdcriti := 9;
          pr_pdscriti := gene0001.fn_busca_critica(pr_cdcritic => pr_pcdcriti);
              
          -- Gera exceção
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fecha o cursor
          CLOSE cr_crapass;
        END IF;       
        
         -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop(pr_cdcooper => rw_crapass.cdcooper);       
        FETCH cr_crapcop INTO rw_crapcop;
                   
	       -- Se não encontrar
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapcop;
          -- Montar mensagem de critica
          pr_pcdcriti := 651;
          pr_pdscriti := gene0001.fn_busca_critica(pr_cdcritic => pr_pcdcriti);
          pr_res_xml := NULL;
          -- Gera exceção
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapcop;
        END IF;
            

   
        -- Verificacao do calendario
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapass.cdcooper);       
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
                  
        -- Se nao encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE BTCH0001.cr_crapdat;
          
          -- Montar mensagem de critica
          pr_pcdcriti := 1;
          pr_pdscriti := gene0001.fn_busca_critica(pr_cdcritic => pr_pcdcriti);
          
          -- Gera exceção
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;

        -- Caso a DataAtual seja maior que dtmvtocd utilizar dtmvtopr senao dtmvtocd
        IF trunc(sysdate) > rw_crapdat.dtmvtocd THEN
          vr_dtrefere := rw_crapdat.dtmvtopr;
        ELSE
          vr_dtrefere := rw_crapdat.dtmvtocd;
        END IF;

        IF vr_tpmensag = '0200' OR   -- Saque ATM com cartão na função débito  
           vr_tpmensag = '0900' THEN -- Consulta de saldo da conta corrente em ATM
          -- Obter valores de saldos diários
          extr0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crapass.cdcooper,
                                      pr_rw_crapdat => rw_crapdat,
                                      pr_cdagenci   => rw_crapass.cdagenci,
                                      pr_nrdcaixa   => 0,
                                      pr_cdoperad   => '',
                                      pr_nrdconta   => rw_crapass.nrdconta,
                                      pr_vllimcre   => rw_crapass.vllimcre,
                                      pr_dtrefere   => vr_dtrefere,
                                      pr_flgcrass   => FALSE,
                                      pr_des_reto   => pr_dsretorn,
                                      pr_tab_sald   => vr_tab_sald,
                                      pr_tab_erro   => vr_tab_erro);
                            
          -- Se encontrar erro                                     
          IF pr_dsretorn <> 'OK' THEN
            -- Presente na tabela de erros
            IF vr_tab_erro.count > 0 THEN
              -- Adquire descrição 
              pr_pdscriti := vr_tab_erro(vr_tab_erro.FIRST).dscritic;                         
            END IF;          
            
            -- Gera exceção
            RAISE vr_exc_erro;           
          END IF;                                    
                    
          -- Alimenta indice da temp-table        
          vr_ind_sald := vr_tab_sald.last;

          -- Adquire saldo disponível total da conta
          vr_vlsddisp := NVL(vr_tab_sald(vr_ind_sald).vlsddisp + vr_tab_sald(vr_ind_sald).vllimcre,0);              
        
          -- Não aprova transação se o valor desta, for maior que saldo disponível
          IF vr_tpmensag = '0200'             AND
            (vr_vldtrans / 100) > vr_vlsddisp THEN
            -- Saldo insuficiente                               
            vr_cdrespos := '51';                 
          END IF;
        END IF;
        
        -- Gera mensagem de retorno a CABAL
        pc_gera_retorno_cabal(pr_tpmensag => vr_tpmsgres
                             ,pr_nrcrcard => vr_nrcrcard
                             ,pr_cdproces => vr_cdproces
                             ,pr_vldtrans => vr_vldtrans
                             ,pr_nrnsucap => vr_nrnsucap
                             ,pr_dtorigem => vr_dtorigem
                             ,pr_hrorigem => vr_hrorigem
                             ,pr_cdredorg => vr_cdredorg
                             ,pr_idtrterm => vr_idtrterm
                             ,pr_cddmoeda => vr_cddmoeda
                             ,pr_cdhislan => vr_infbit62
                             ,pr_cdrespos => vr_cdrespos
                             ,pr_res_xml  => pr_res_xml
                             ,pr_cdgerred => vr_cdgerred
                             ,pr_vlsddisp => vr_vlsddisp
                             ,pr_dtdtrgmt => vr_dtdtrgmt
                             ,pr_cdautori => vr_cdautori
                             ,pr_des_reto => pr_dsretorn
                             ,pr_cdcritic => pr_pcdcriti
                             ,pr_dscritic => pr_pdscriti); 
                               
        -- Se houve retorno não Ok
        IF pr_dsretorn <> 'OK' THEN
          pr_res_xml := NULL;
          -- Monta mensagem de critica
          IF pr_pcdcriti = 0 AND pr_pdscriti IS NULL THEN
            pr_pdscriti := 'Nao foi possivel gerar mensagem de retorno (' || vr_tpmsgres || ') - CABAL.';
          END IF;
            
          -- Gera exceção
          RAISE vr_exc_erro;      
        END IF; 
        
        -- Busca codigo do historico 
        vr_cdhistor := 0;
        OPEN cr_craphcb(pr_cdtrnbcb => vr_infbit62,
                        pr_cdcooper => rw_crapass.cdcooper);
        FETCH cr_craphcb INTO rw_craphcb;
        IF cr_craphcb%FOUND THEN
           vr_cdhistor := rw_craphcb.cdhistor;
        END IF;
        CLOSE cr_craphcb;        
        
        vr_nrnsuori := vr_nrnsucap;
        
        -- Para estes 4 tipos, será necessário criar um lançamento
        IF vr_tpmensag = '0400' OR   -- Cancelamento de compra/saque on-line
           vr_tpmensag = '0200' OR   -- Compra/Saque on-line
           vr_tpmensag = '0220' OR   -- Aviso de compra/saque off-line
           vr_tpmensag = '0420' THEN -- Dezfazimento pode ser credito ou debito

           -- Verificar se existe histórico cadastrado para fazer o lancamento na conta
           IF vr_cdhistor = 0 THEN
              pr_pcdcriti := 611; 
              pr_pdscriti := gene0001.fn_busca_critica(pr_cdcritic => pr_pcdcriti);
              pr_res_xml := NULL;
              RAISE vr_exc_erro;
           END IF;

           -- Calcular o NSU unico da transacao
           vr_nrdocmto:= fn_busca_nsu_transacao(pr_tpmensag => vr_tpmensag,
                                                pr_nrnsucap => vr_nrnsucap,
                                                pr_dtdtrgmt => vr_dtdtrgmt);
                                                
           IF vr_nrdocmto = 0 THEN
              pr_res_xml := NULL;
              -- Monta mensagem de critica
              IF pr_pcdcriti = 0 AND pr_pdscriti IS NULL THEN
                 pr_pdscriti := 'Erro ao gerar o NSU.';
              END IF;
              -- Gera exceção
              RAISE vr_exc_erro; 
           END IF;

           /* Somente gerar o lancamento de se não existir lancamento feito */  
           OPEN cr_craplcm(pr_cdcooper => rw_crapass.cdcooper,
                           pr_cdagenci => rw_crapass.cdagenci,
                           pr_cdbccxlt => 0100,
                           pr_nrdolote => 6902,
                           pr_nrdconta => rw_crapass.nrdconta,
                           pr_nrdocmto => vr_nrdocmto,
                           pr_nrcrcard => vr_nrcrcard,
                           pr_vldtrans => (vr_vldtrans / 100 ),
                           pr_dtmvtoan => rw_crapdat.dtmvtoan);
                                    
           FETCH cr_craplcm INTO rw_craplcm;                

           vr_exlancta := cr_craplcm%NOTFOUND;

           CLOSE cr_craplcm;
           
           /* Tratar a ordem de mensagem invertida quando a 0200 chega depois 
           da mensagem 0220 não fazer o lançamento da 0200 apenas se houver um
           desfazimento para a 0200 e responder transação feita para cabal */
           IF vr_tpmensag = '0200'AND vr_exlancta THEN
             
              OPEN cr_crapdcb_nrnsuori(pr_tpmensag => '0420'
                                      ,pr_dtdtrgmt => TO_DATE(substr(vr_dtdtrgmt,1,4),'MMDD')
                                      ,pr_nrnsuori => vr_nrnsucap 
                                      ,pr_cdcooper => rw_crapass.cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta);                       
              
              FETCH cr_crapdcb_nrnsuori INTO rw_crapdcb_nrnsuori;
              
              vr_exlancta := cr_crapdcb_nrnsuori%NOTFOUND;

              CLOSE cr_crapdcb_nrnsuori;
              
           ELSIF vr_tpmensag = '0420' THEN 
             
             vr_nrnsuori := TO_NUMBER(SUBSTR(vr_dadtrnor, 5, 6));
           
             IF vr_exlancta THEN
              
               -- Calcular o NSU unico da transacao de origem                                     
               vr_nrdoctro:= fn_busca_nsu_transacao(pr_tpmensag => SUBSTR(vr_dadtrnor, 1, 4),
                                                    pr_nrnsucap => vr_nrnsuori,
                                                    pr_dtdtrgmt => SUBSTR(vr_dadtrnor, 11, 10));
                                                   
               IF vr_nrdoctro = 0 THEN
                 pr_res_xml := NULL;
                 -- Monta mensagem de critica
                 IF pr_pcdcriti = 0 AND pr_pdscriti IS NULL THEN
                    pr_pdscriti := 'Erro ao gerar o NSU de origem.';
                 END IF;
                 -- Gera exceção
                 RAISE vr_exc_erro; 
               END IF;                                     

               OPEN cr_craplcm(pr_cdcooper => rw_crapass.cdcooper,
                               pr_cdagenci => rw_crapass.cdagenci,
                               pr_cdbccxlt => 0100,
                               pr_nrdolote => 6902,
                               pr_nrdconta => rw_crapass.nrdconta,
                               pr_nrdocmto => vr_nrdoctro,
                               pr_nrcrcard => vr_nrcrcard,
                               pr_vldtrans => (vr_vldtrans / 100 ),
                               pr_dtmvtoan => rw_crapdat.dtmvtoan);
                                     
               FETCH cr_craplcm INTO rw_craplcm;                
               /* Gerar lancamento de desfazimento se origem existir */  
               vr_exlancta := cr_craplcm%FOUND;

               CLOSE cr_craplcm;
               
             END IF; -- END IF vr_exlancta THEN
               
           END IF; -- END IF vr_tpmensag = '0420'
              
              
         IF vr_exlancta AND (TO_NUMBER(vr_cdrespos) = 0) THEN
            -- Gera lançamento de débito ou crédito conforme histórico
            pc_cria_lancamento_cc (pr_cdcooper => rw_crapass.cdcooper
                                  ,pr_dtmvtolt => vr_dtrefere
                                  ,pr_cdagenci => rw_crapass.cdagenci
                                  ,pr_cdbccxlt => 100
                                  ,pr_nrdolote => 6902 
                                  ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_cdhistor => vr_cdhistor
                                  ,pr_vllanmto => (vr_vldtrans / 100 )
                                  ,pr_nrcrcard => vr_nrcrcard
                                  ,pr_nrdocmto => vr_nrdocmto                                 
                                  ,pr_dtrefere => to_date(vr_dtorigem,'MMDD')
                                  ,pr_hrtransa => vr_hrorigem
                                  ,pr_cdorigem => 8
                                  ,pr_des_reto => pr_dsretorn
                                  ,pr_cdcritic => pr_pcdcriti
                                  ,pr_dscritic => pr_pdscriti);
                                              
            -- Se houve retorno não Ok
            IF pr_dsretorn <> 'OK' THEN
              pr_res_xml := NULL;
              -- Monta mensagem de critica
              IF pr_pcdcriti = 0     AND
                 pr_pdscriti IS NULL THEN
                pr_pdscriti := 'Nao foi gerar o lancamento na conta.';
              END IF;
              -- Gera exceção
              RAISE vr_exc_erro;  
            END IF;
          END IF;
          
      /* Cancelamento de Cartao */    
      ELSIF vr_tpmensag = '9085' THEN
          
        BEGIN
          UPDATE crawcrd SET
                 insitcrd = 6,
                 dtcancel = vr_dtrefere,
                 cdmotivo = 3
           WHERE crawcrd.cdcooper = rw_crapcrd.cdcooper
             AND crawcrd.nrdconta = rw_crapcrd.nrdconta
             AND crawcrd.nrctrcrd = rw_crapcrd.nrctrcrd
             AND crawcrd.nrcrcard = vr_nrcrcard;
        EXCEPTION
          WHEN OTHERS THEN
            pr_res_xml := NULL;
            -- Monta mensagem de critica
            pr_pdscriti := 'Erro ao atualizar crawcrd. Cartao: ' || TO_CHAR(vr_nrcrcard) || '. '|| SQLERRM;
            -- Gera exceção
            RAISE vr_exc_erro;  
        END;
      
      END IF;
      
      -- Grava mensagens de envio/recebimento
      pc_grava_mensagem_cabal(pr_tpmensag => vr_tpmensag
                             ,pr_tpmsgres => vr_tpmsgres
                             ,pr_nrnsucap => vr_nrnsucap
                             ,pr_dtdtrgmt => vr_dtdtrgmt
                             ,pr_cdcooper => rw_crapass.cdcooper
                             ,pr_nrdconta => rw_crapass.nrdconta
                             ,pr_cdagenci => rw_crapass.cdagenci
                             ,pr_dstrorig => vr_dstrorig
                             ,pr_dstrreto => pr_res_xml
                             ,pr_cdautori => vr_cdautori
                             ,pr_vldtrans => vr_vldtrans
                             ,pr_nrcrcard => vr_nrcrcard
                             ,pr_cdhislan => vr_cdhistor
                             ,pr_cdproces => vr_cdproces
                             ,pr_cddmoeda => vr_cddmoeda
                             ,pr_idtrterm => vr_idtrterm
                             ,pr_cdtrresp => vr_cdrespos
                             ,pr_dtorigem => to_date(vr_dtorigem,'MMDD')
                             ,pr_dsdtrans => vr_nmdoesta                             
                             ,pr_nrinstit => vr_cdredorg
                             ,pr_dtmvtolt => vr_dtrefere
                             ,pr_nrnsuori => vr_nrnsuori
                             ,pr_des_reto => pr_dsretorn
                             ,pr_cdcritic => pr_pcdcriti
                             ,pr_dscritic => pr_pdscriti);          
          
      -- Se houve retorno não Ok
      IF pr_dsretorn <> 'OK' THEN
        pr_res_xml := NULL;
        -- Monta mensagem de critica
        IF pr_pcdcriti = 0 AND pr_pdscriti IS NULL THEN
          pr_pdscriti := 'Nao foi possivel gravar as mensagens - CABAL.';
        END IF;
        -- Gera exceção
        RAISE vr_exc_erro; 
      END IF;
      
      -- Retorno OK
      pr_dsretorn := 'OK';
      -- Efetua commit      
      COMMIT;
      EXCEPTION        
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;
        WHEN vr_exc_sair THEN
          RAISE vr_exc_sair;
        WHEN OTHERS THEN
          -- Define a mensagem de erro
          pr_pdscriti := pr_pdscriti || SQLERRM;
          RAISE vr_exc_erro;
      END; 
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_res_xml := NULL; 
        -- Monta mensagem de erro
        pr_pcdcriti := NVL(pr_pcdcriti, 0);
        -- Retorno não OK
        pr_dsretorn := 'NOK';
        ROLLBACK;
      WHEN vr_exc_sair THEN
        pr_pcdcriti := 0;
        -- Retorno OK
        pr_dsretorn := 'OK';
        -- Efetua commit      
        COMMIT;          
      WHEN OTHERS THEN
        pr_res_xml := NULL; 
        pr_pcdcriti := NVL(pr_pcdcriti, 0);
        -- Define a mensagem de erro
        pr_pdscriti := 'Erro ao tratar mensagem CABAL => ' || pr_pdscriti || SQLERRM;
        -- Retorno não OK
        pr_dsretorn := 'NOK';                                  
        ROLLBACK;
    END;        
  END pc_trata_mensagem_cabal;
          
  -- Monta o xml de retorno e o envia a cabal
  PROCEDURE pc_gera_retorno_cabal(pr_tpmensag IN crapdcb.tpmensag%TYPE
                                 ,pr_nrcrcard IN crapdcb.nrcrcard%TYPE
                                 ,pr_cdproces IN crapdcb.cdproces%TYPE
                                 ,pr_vldtrans IN crapdcb.vldtrans%TYPE                              
                                 ,pr_nrnsucap IN crapdcb.nrnsucap%TYPE
                                 ,pr_dtorigem IN NUMBER
                                 ,pr_hrorigem IN NUMBER
                                 ,pr_cdredorg IN NUMBER
                                 ,pr_idtrterm IN crapdcb.idtrterm%TYPE
                                 ,pr_cddmoeda IN crapdcb.cddmoeda%TYPE
                                 ,pr_cdhislan IN VARCHAR2      
                                 ,pr_cdrespos IN VARCHAR2
                                 ,pr_cdgerred IN NUMBER
                                 ,pr_vlsddisp IN NUMBER
                                 ,pr_dtdtrgmt IN VARCHAR2
                                 ,pr_res_xml  OUT VARCHAR2
                                 ,pr_cdautori OUT crapdcb.cdautori%TYPE
                                 ,pr_des_reto OUT VARCHAR2 
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
                                                            
  BEGIN    
    DECLARE 
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_dadosres typ_reg_dados_msg_iso;
    BEGIN
      -- Gera um sequencial para ser utilizado na gravação da mensagem de retorno
      pr_cdautori := SEQDCB_CDAUTORI.NEXTVAL;
      -- Formatar com zeros a esquerda 
      vr_dadosres.tpmensag := TRIM(TO_CHAR(pr_tpmensag, '0000'));
      vr_dadosres.nrcrcard := TRIM(TO_CHAR(pr_nrcrcard, '0000000000000000'));
      vr_dadosres.cdproces := TRIM(TO_CHAR(pr_cdproces, '000000'));
      vr_dadosres.vldtrans := TRIM(TO_CHAR(pr_vldtrans, '000000000000'));
      vr_dadosres.nrnsucap := TRIM(TO_CHAR(pr_nrnsucap, '000000'));
      vr_dadosres.dtorigem := TRIM(TO_CHAR(pr_dtorigem, '0000'));
      vr_dadosres.hrorigem := TRIM(TO_CHAR(pr_hrorigem, '000000'));
      vr_dadosres.cdredorg := TRIM(pr_cdredorg);
      vr_dadosres.idtrterm := TRIM(pr_idtrterm);
      vr_dadosres.cddmoeda := TRIM(TO_CHAR(pr_cddmoeda, '000'));
      vr_dadosres.cdhislan := pr_cdhislan;      
      vr_dadosres.cdrespos := TRIM(TO_CHAR(pr_cdrespos, '00'));
      vr_dadosres.cdgerred := TRIM(TO_CHAR(pr_cdgerred, '000'));
      vr_dadosres.vlsddisp := TO_CHAR(pr_vlsddisp * 100);
      vr_dadosres.cdautori := TRIM(TO_CHAR(pr_cdautori, '000000'));
      vr_dadosres.dtdtrgmt := TRIM(TO_CHAR(pr_dtdtrgmt, '0000000000'));
      
      -- Inicilizar as informações do XML
      pr_res_xml := '<isomsg><field id="0" value="' || pr_tpmensag || '"/>';
      
      -- Resposta de transações de compra a vista com cartão na funação débito
      IF pr_tpmensag = '0210' THEN
        pr_res_xml := pr_res_xml || '<field id="2" value="' || vr_dadosres.nrcrcard || '"/>' ||
                                    '<field id="3" value="' || vr_dadosres.cdproces || '"/>' ||     
                                    '<field id="4" value="' || vr_dadosres.vldtrans || '"/>' ||        
                                    '<field id="7" value="' || vr_dadosres.dtdtrgmt || '"/>' ||
                                   -- '<field id="7" value="' || (TO_CHAR(SYSDATE,'MMDD') || TO_CHAR(SYSDATE,'HH24MMSS')) || '"/>' || 
                                    '<field id="11" value="' || vr_dadosres.nrnsucap || '"/>' || 
                                    '<field id="12" value="' || vr_dadosres.hrorigem || '"/>' || 
                                    '<field id="13" value="' || vr_dadosres.dtorigem || '"/>' || 
                                    '<field id="32" value="' || vr_dadosres.cdredorg || '"/>' ||                                    
                                    '<field id="38" value="' || vr_dadosres.cdautori || '"/>' ||                      
                                    '<field id="39" value="' || vr_dadosres.cdrespos || '"/>' ||               
                                    '<field id="41" value="' || vr_dadosres.idtrterm || '"/>' ||               
                                    '<field id="49" value="' || vr_dadosres.cddmoeda || '"/>' ||                            
                                    '<field id="62" value="' || vr_dadosres.cdhislan || '"/>';                    
               
      -- Resposta do aviso de compra ou saque off-line
      ELSIF pr_tpmensag = '0230' THEN   
        pr_res_xml := pr_res_xml || '<field id="2" value="' || vr_dadosres.nrcrcard || '"/>' ||
                                    '<field id="3" value="' || vr_dadosres.cdproces || '"/>' ||     
                                    '<field id="4" value="' || vr_dadosres.vldtrans || '"/>' ||       
                                    '<field id="7" value="' || vr_dadosres.dtdtrgmt || '"/>' ||
                                    --'<field id="7" value="' || (TO_CHAR(SYSDATE,'MMDD') || TO_CHAR(SYSDATE,'HH24MMSS')) || '"/>' ||
                                    '<field id="11" value="' || vr_dadosres.nrnsucap || '"/>' ||
                                    '<field id="12" value="' || vr_dadosres.hrorigem || '"/>' ||
                                    '<field id="13" value="' || vr_dadosres.dtorigem || '"/>' ||
                                    '<field id="32" value="' || vr_dadosres.cdredorg || '"/>' ||                                   
                                    '<field id="38" value="' || vr_dadosres.cdautori || '"/>' ||                  
                                    '<field id="39" value="' || vr_dadosres.cdrespos || '"/>' ||              
                                    '<field id="41" value="' || vr_dadosres.idtrterm || '"/>' ||              
                                    '<field id="49" value="' || vr_dadosres.cddmoeda || '"/>' ||                              
                                    '<field id="62" value="' || vr_dadosres.cdhislan || '"/>';                    
      
      ELSIF pr_tpmensag = '0410' OR   -- Resposta de cancelamento de compra ou saque em ATM com cartão na função débito
            pr_tpmensag = '0430' THEN -- Resposta de desfazimento de compra ou saque com cartão na função débitop
        pr_res_xml := pr_res_xml || '<field id="2" value="' || vr_dadosres.nrcrcard || '"/>' ||
                                    '<field id="3" value="' || vr_dadosres.cdproces || '"/>' ||     
                                    '<field id="4" value="' || vr_dadosres.vldtrans || '"/>' ||       
                                    '<field id="7" value="' || vr_dadosres.dtdtrgmt || '"/>' ||
                                    --'<field id="7" value="' || (TO_CHAR(SYSDATE,'MMDD') || TO_CHAR(SYSDATE,'HH24MMSS')) || '"/>' ||
                                    '<field id="11" value="' || vr_dadosres.nrnsucap || '"/>' ||
                                    '<field id="12" value="' || vr_dadosres.hrorigem || '"/>' ||
                                    '<field id="13" value="' || vr_dadosres.dtorigem || '"/>' ||
                                    '<field id="32" value="' || vr_dadosres.cdredorg || '"/>' ||        
                                    '<field id="38" value="' || vr_dadosres.cdautori || '"/>' ||                    
                                    '<field id="39" value="' || vr_dadosres.cdrespos || '"/>' ||              
                                    '<field id="41" value="' || vr_dadosres.idtrterm || '"/>' ||             
                                    '<field id="49" value="' || vr_dadosres.cddmoeda || '"/>' ||                              
                                    '<field id="62" value="' || vr_dadosres.cdhislan || '"/>';
        
      -- Resposta de Echo Test
      ELSIF pr_tpmensag = '0810' THEN
        pr_res_xml := pr_res_xml || '<field id="7" value="'  || vr_dadosres.dtdtrgmt || '"/>' ||--'<field id="7" value="' || (TO_CHAR(SYSDATE,'MMDD') || TO_CHAR(SYSDATE,'HH24MMSS')) || '"/>' ||
                                    '<field id="11" value="' || vr_dadosres.nrnsucap || '"/>' ||
                                    '<field id="39" value="' || vr_dadosres.cdrespos || '"/>' ||      
                                    '<field id="62" value="' || vr_dadosres.cdhislan || '1"/>' ||
                                    '<field id="70" value="' || vr_dadosres.cdgerred || '"/>';                     
        
      -- Resposta de consulta de saldo da conta corrente em ATM
      ELSIF pr_tpmensag = '0910' THEN
        pr_res_xml := pr_res_xml || '<field id="2" value="' || vr_dadosres.nrcrcard || '"/>' ||
                                    '<field id="3" value="' || vr_dadosres.cdproces || '"/>' ||
                                    '<field id="7" value="' || vr_dadosres.dtdtrgmt || '"/>' ||        
                                    --'<field id="7" value="' || (TO_CHAR(SYSDATE,'MMDD') || TO_CHAR(SYSDATE,'HH24MMSS')) || '"/>' ||
                                    '<field id="11" value="' || vr_dadosres.nrnsucap || '"/>' ||
                                    '<field id="12" value="' || vr_dadosres.hrorigem || '"/>' ||
                                    '<field id="13" value="' || vr_dadosres.dtorigem || '"/>' ||     
                                    '<field id="38" value="' || vr_dadosres.cdautori || '"/>' ||                  
                                    '<field id="39" value="' || vr_dadosres.cdrespos || '"/>' ||           
                                    '<field id="41" value="' || vr_dadosres.idtrterm || '"/>' ||             
                                    '<field id="62" value="' || vr_dadosres.vlsddisp || '"/>';                            
      
      ELSIF pr_tpmensag = '9090' OR   -- Resposta de desbloqueio e troca de senha 
            pr_tpmensag = '9095' THEN -- Resposta de cancelamento de cartão on-line
        pr_res_xml := pr_res_xml || '<field id="2" value="' || vr_dadosres.nrcrcard || '"/>' ||
                                    '<field id="3" value="' || vr_dadosres.cdproces || '"/>' ||
                                    '<field id="7" value="' || vr_dadosres.dtdtrgmt || '"/>' ||        
                                    --'<field id="7" value="' || (TO_CHAR(SYSDATE,'MMDD') || TO_CHAR(SYSDATE,'HH24MMSS')) || '"/>' ||
                                    '<field id="11" value="' || vr_dadosres.nrnsucap || '"/>' ||
                                    '<field id="12" value="' || vr_dadosres.hrorigem || '"/>' ||
                                    '<field id="13" value="' || vr_dadosres.dtorigem || '"/>' ||
                                    '<field id="38" value="' || vr_dadosres.cdautori || '"/>' ||                    
                                    '<field id="39" value="' || vr_dadosres.cdrespos || '"/>' ||
                                    '<field id="41" value="' || vr_dadosres.idtrterm || '"/>';                  
      END IF;
      
      -- Finalizar arquivo XML
      pr_res_xml := pr_res_xml || '</isomsg>';        
      
      -- Retorno
      pr_des_reto := 'OK';      
    EXCEPTION           
      WHEN OTHERS THEN
       -- Monta mensagem de critica
        pr_cdcritic := 0;
        pr_dscritic := 'Erro nao tratado na rotina CCRD0002.pc_gera_retorno_cabal: ' || SQLERRM;
        
        -- Retorno não OK
        pr_des_reto := 'NOK';
    END;                             
  END pc_gera_retorno_cabal;    
 
  -- Responsável por gravar na base as mensagens de recebeimento e resposta do sistema CABAL. 
  PROCEDURE pc_grava_mensagem_cabal(pr_tpmensag IN crapdcb.tpmensag%TYPE
                                   ,pr_tpmsgres IN crapdcb.tpmensag%TYPE
                                   ,pr_nrnsucap IN crapdcb.nrnsucap%TYPE
                                   ,pr_dtdtrgmt IN VARCHAR2
                                   ,pr_cdcooper IN crapdcb.cdcooper%TYPE
                                   ,pr_nrdconta IN crapdcb.nrdconta%TYPE
                                   ,pr_cdagenci IN crapdcb.cdagenci%TYPE
                                   ,pr_dstrorig IN crapdcb.dstrorig%TYPE
                                   ,pr_dstrreto IN crapdcb.dstrorig%TYPE
                                   ,pr_cdautori IN crapdcb.cdautori%TYPE
                                   ,pr_vldtrans IN crapdcb.vldtrans%TYPE
                                   ,pr_nrcrcard IN crapdcb.nrcrcard%TYPE
                                   ,pr_cdhislan IN crapdcb.cdhistor%TYPE
                                   ,pr_cdproces IN crapdcb.cdproces%TYPE
                                   ,pr_cddmoeda IN crapdcb.cddmoeda%TYPE
                                   ,pr_idtrterm IN crapdcb.idtrterm%TYPE
                                   ,pr_cdtrresp IN crapdcb.cdtrresp%TYPE
                                   ,pr_dtorigem IN crapdcb.dtdtrans%TYPE
                                   ,pr_dsdtrans IN crapdcb.dsdtrans%TYPE
                                   ,pr_nrinstit IN crapdcb.nrinstit%TYPE
                                   ,pr_dtmvtolt IN crapdcb.dtmvtolt%TYPE
                                   ,pr_nrnsuori IN crapdcb.nrnsuori%TYPE
                                   ,pr_des_reto OUT VARCHAR2
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE)IS
                                                                                        
  BEGIN    
    DECLARE
    
      -- Variáveis de critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      -- Consulta se já há registro da mensagem de recebimento
      OPEN cr_crapdcb(pr_tpmensag => pr_tpmensag
                     ,pr_nrnsucap => pr_nrnsucap
                     ,pr_dtdtrgmt => TO_DATE(substr(pr_dtdtrgmt,1,4),'MMDD')
                     ,pr_hrdtrgmt => TO_NUMBER(SUBSTR(pr_dtdtrgmt,5,6)) 
                     ,pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);                       
      
      FETCH cr_crapdcb INTO rw_crapdcb;
      
      -- Se Encontrou
      IF cr_crapdcb%NOTFOUND THEN
        --Fecha o Cursor
        CLOSE cr_crapdcb;
            
        BEGIN
          -- Insere registro da mensagem recebida
          INSERT INTO crapdcb(crapdcb.tpmensag
                             ,crapdcb.nrnsucap
                             ,crapdcb.dtdtrgmt
                             ,crapdcb.hrdtrgmt
                             ,crapdcb.cdcooper
                             ,crapdcb.nrdconta
                             ,crapdcb.dstrorig
                             ,crapdcb.cdagenci
                             ,crapdcb.vldtrans
                             ,crapdcb.nrcrcard
                             ,crapdcb.cdhistor
                             ,crapdcb.cdproces
                             ,crapdcb.cddmoeda
                             ,crapdcb.idtrterm
                             ,crapdcb.dtdtrans
                             ,crapdcb.dsdtrans
                             ,crapdcb.cdautban
                             ,crapdcb.dtmvtolt
                             ,crapdcb.nrinstit
                             ,crapdcb.nrnsuori)
                      VALUES (pr_tpmensag
                             ,pr_nrnsucap
                             ,to_date(substr(pr_dtdtrgmt,1,4),'MMDD')
                             ,to_number(substr(pr_dtdtrgmt,5,6)) 
                             ,pr_cdcooper
                             ,pr_nrdconta
                             ,pr_dstrorig
                             ,pr_cdagenci
                             ,pr_vldtrans / 100
                             ,pr_nrcrcard
                             ,pr_cdhislan
                             ,pr_cdproces
                             ,pr_cddmoeda
                             ,pr_idtrterm
                             ,pr_dtorigem
                             ,pr_dsdtrans
                             ,pr_nrnsucap
                             ,pr_dtmvtolt
                             ,pr_nrinstit
                             ,pr_nrnsuori);
        EXCEPTION
          WHEN OTHERS THEN
            -- Monta mensagem de critica
            vr_dscritic := 'Erro ao inserir mensagem de recebimento na tabela crapdcb. '|| SQLERRM;
            
            -- Gera exceção
            RAISE vr_exc_erro;
        END;
      ELSE      
        CLOSE cr_crapdcb;
      END IF;
      
      -- Consulta se já há registro da mensagem de envio
      OPEN cr_crapdcb(pr_tpmensag => pr_tpmsgres 
                     ,pr_nrnsucap => pr_nrnsucap
                     ,pr_dtdtrgmt => to_date(substr(pr_dtdtrgmt,1,4),'MMDD') --TO_DATE((SUBSTR(pr_dtdtrgmt,3, 2) || SUBSTR(pr_dtdtrgmt,1, 2)),'DDMM')
                     ,pr_hrdtrgmt => TO_NUMBER(SUBSTR(pr_dtdtrgmt,5,6)) 
                     ,pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
        
      FETCH cr_crapdcb INTO rw_crapdcb;
        
      -- Se Encontrou
      IF cr_crapdcb%NOTFOUND THEN
         
        -- Fecha o Cursor
        CLOSE cr_crapdcb;
        
        BEGIN
          -- Insere registro da mensagem de envio
          INSERT INTO crapdcb(crapdcb.tpmensag
                             ,crapdcb.nrnsucap
                             ,crapdcb.dtdtrgmt
                             ,crapdcb.hrdtrgmt
                             ,crapdcb.cdcooper
                             ,crapdcb.nrdconta                             
                             ,crapdcb.cdautori
                             ,crapdcb.dstrorig
                             ,crapdcb.cdagenci
                             ,crapdcb.nrcrcard
                             ,crapdcb.vldtrans
                             ,crapdcb.cdhistor
                             ,crapdcb.cdproces
                             ,crapdcb.cddmoeda
                             ,crapdcb.cdtrresp
                             ,crapdcb.dsdtrans
                             ,crapdcb.cdautban
                             --,crapdcb.dtlancta
                             ,crapdcb.dtdtrans
                             ,crapdcb.nrinstit)
                      VALUES (pr_tpmsgres
                             ,pr_nrnsucap
                             ,to_date(substr(pr_dtdtrgmt,1,4),'MMDD')
                             ,to_number(substr(pr_dtdtrgmt,5,6)) 
                             ,pr_cdcooper
                             ,pr_nrdconta
                             ,pr_cdautori
                             ,pr_dstrreto
                             ,pr_cdagenci
                             ,pr_nrcrcard
                             ,pr_vldtrans / 100
                             ,pr_cdhislan
                             ,pr_cdproces
                             ,pr_cddmoeda
                             ,pr_cdtrresp
                             ,pr_dsdtrans
                             ,pr_nrnsucap
                             --,pr_dtmvtocd
                             ,pr_dtorigem
                             ,pr_nrinstit);
                 
        EXCEPTION
          WHEN OTHERS THEN
            -- Monta mensagem de critica
            vr_dscritic := 'Erro ao inserir mensagem de envio na tabela crapdcb. '|| SQLERRM;
            
            -- Gera exceção
            RAISE vr_exc_erro;
        END;
      ELSE
        CLOSE cr_crapdcb;
      END IF;        
      
      -- Retorno OK
      pr_des_reto := 'OK';
               
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        
        -- Retorno não OK
        pr_des_reto := 'NOK';
        
      WHEN OTHERS THEN
        
        -- Monta mensagem de critica
        pr_cdcritic := 0;
        pr_dscritic := 'Erro nao tratado na rotina CCRD0002.pc_grava_mensagem_cabal: ' || SQLERRM;
        
        -- Retorno não OK
        pr_des_reto := 'NOK';
        
    END;
                                                          
  END pc_grava_mensagem_cabal;

  -- Criar o lancamento na Conta Corrente  
  PROCEDURE pc_cria_lancamento_cc (pr_cdcooper IN crapcop.cdcooper%TYPE  
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE  
                                  ,pr_cdbccxlt IN craperr.nrdcaixa%TYPE  
                                  ,pr_nrdolote IN craplot.nrdolote%TYPE  
                                  ,pr_nrdconta IN crapepr.nrdconta%TYPE  
                                  ,pr_cdhistor IN craphis.cdhistor%TYPE  
                                  ,pr_vllanmto IN NUMBER    
                                  ,pr_nrcrcard IN crapdcb.nrcrcard%TYPE
                                  ,pr_nrdocmto IN craplcm.nrdocmto%TYPE                                  
                                  ,pr_dtrefere IN craplcm.dtrefere%TYPE
                                  ,pr_hrtransa IN craplcm.hrtransa%TYPE
                                  ,pr_cdorigem IN craplcm.cdorigem%TYPE
                                  ,pr_des_reto OUT VARCHAR2               
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE)IS 
  BEGIN
    DECLARE
      -- Variaveis Locais
      vr_nrseqdig INTEGER;
        
      -- Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
      
    BEGIN
      -- Inicializar variavel erro
      pr_des_reto:= 'OK';
      -- Valor Lancamento maior zero
      IF ROUND(pr_vllanmto,2) > 0 THEN
                                
        vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',''||pr_cdcooper||';'||
                                      to_char(pr_dtmvtolt,'dd/mm/yyyy')||';'||
                                                            pr_cdagenci||';'||
                                                            pr_cdbccxlt||';'||
                                                            pr_nrdolote||'');
        IF vr_nrseqdig IS NULL OR vr_nrseqdig = 0 THEN
          RAISE vr_exc_erro;
        END IF;
          
        -- Inserir Lancamento
        BEGIN
          
          INSERT INTO craplcm(craplcm.dtmvtolt
                             ,craplcm.cdagenci
                             ,craplcm.cdbccxlt
                             ,craplcm.nrdolote
                             ,craplcm.nrdconta
                             ,craplcm.nrdctabb
                             ,craplcm.nrdctitg
                             ,craplcm.nrdocmto
                             ,craplcm.cdhistor
                             ,craplcm.nrseqdig
                             ,craplcm.vllanmto
                             ,craplcm.cdcooper
                             ,craplcm.cdpesqbb
                             ,craplcm.dtrefere
                             ,craplcm.hrtransa
                             ,craplcm.cdorigem)
                      VALUES(pr_dtmvtolt
                            ,pr_cdagenci
                            ,pr_cdbccxlt
                            ,pr_nrdolote
                            ,pr_nrdconta
                            ,pr_nrdconta 
                            ,gene0002.fn_mask(pr_nrdconta,'99999999')
                            ,pr_nrdocmto
                            ,pr_cdhistor
                            ,vr_nrseqdig
                            ,pr_vllanmto
                            ,pr_cdcooper
                            ,pr_nrcrcard
                            ,pr_dtrefere
                            ,pr_hrtransa
                            ,pr_cdorigem); 
                            
        EXCEPTION
          WHEN OTHERS THEN
            
            -- Monta mensagem de erro
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir registro na craplcm. ' || SQLERRM;
            
            -- Gera exceção
            RAISE vr_exc_erro;
            
        END;      
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Variavel de erro recebe erro ocorrido
        pr_cdcritic:= NVL(vr_cdcritic,0);
        pr_dscritic:= vr_dscritic;
          
        -- Retorno não OK
        pr_des_reto := 'NOK';
        
      WHEN OTHERS THEN
       
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina CCRD0002.pc_inclui_altera_lote. ' || sqlerrm;
          
        -- Retorno não OK
        pr_des_reto := 'NOK';
       
    END;    
    
  END pc_cria_lancamento_cc;  
  
END CCRD0002;
/
