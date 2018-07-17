CREATE OR REPLACE PACKAGE CECRED.MENU0001 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: MENU0001
  --    Autor   : Douglas Quisinski
  --    Data    : Maio/2018                      Ultima Atualizacao:   /  /    
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Configurar os itens de MENU que sao configurados para exibicao 
  --
  --    Alteracoes: 
  --    
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina para devolver os itens que devem ser exibidos/escondidos no menu dos canais
  PROCEDURE pc_carrega_config_menu(pr_cdcooper IN INTEGER,               --> Codigo da Cooperativa
                                   pr_nrdconta IN INTEGER DEFAULT 0,     --> Numero da Conta
                                   pr_idseqttl IN crapttl.idseqttl%TYPE, --> Sequencial do titular
                                   pr_nrcpfope IN crapopi.nrcpfope%TYPE, --> CPF do operador juridico
                                   pr_idorigem IN INTEGER,               --> ID origem da requisi��o
                                   pr_cdagenci IN crapage.cdagenci%TYPE, --> C�digo da agencia
                                   pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE, --> Numero do caixa
                                   pr_nmdatela IN craptel.nmdatela%TYPE, --> Nome da tela
                                   pr_dsxml    OUT NOCOPY XMLType,       --> XML com os itens de menu que s�o configuraveis em cada canal
                                   pr_dscritic OUT VARCHAR2);            --> Mensagem de erro

END MENU0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.MENU0001 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: MENU0001
  --    Autor   : Douglas Quisinski
  --    Data    : Maio/2018                      Ultima Atualizacao:   /  /    
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Configurar os itens de MENU que sao configurados para exibicao 
  --
  --  Alteracoes: ??/05/2018 Cria��o (Douglas Quisinski)
  --
  --              06/06/2018 Adicionado nova op��o 4 - Desconto Titulos (Paulo Penteado (GFT)) 
  --    
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina para devolver os itens que devem ser exibidos/escondidos no menu dos canais
  PROCEDURE pc_carrega_config_menu(pr_cdcooper IN INTEGER,               --> Codigo da Cooperativa
                                   pr_nrdconta IN INTEGER DEFAULT 0,     --> Numero da Conta
                                   pr_idseqttl IN crapttl.idseqttl%TYPE, --> Sequencial do titular
                                   pr_nrcpfope IN crapopi.nrcpfope%TYPE, --> CPF do operador juridico
                                   pr_idorigem IN INTEGER,               --> ID origem da requisi��o
                                   pr_cdagenci IN crapage.cdagenci%TYPE, --> C�digo da agencia
                                   pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE, --> Numero do caixa
                                   pr_nmdatela IN craptel.nmdatela%TYPE, --> Nome da tela
                                   pr_dsxml    OUT NOCOPY XMLType,       --> XML com os itens de menu que s�o configuraveis em cada canal
                                   pr_dscritic OUT VARCHAR2) IS          --> Mensagem de erro
  BEGIN
    /* .............................................................................
    Programa: pc_carrega_config_menu
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : MENU
    Autor   : Douglas Quisinski
    Data    : 09/05/2018                        Ultima atualizacao: 
    
    Dados referentes ao programa:
      Se for necess�rio adicionar mais itens de menu configur�veis para exibir/esconder, dever�o ser adicionadas novas tags "item_menu", e os campos:
      - "codigo" baseado na lista de dem�nio
      - "canal" retonar o parametro que foi recebido
      - "habilitado" item
      
      Lista de Dom�nio para cria��o dos c�digos:
        1 - Recarga de Celular
        2 - Imagem de Cheque
        3 - Pr�-Aprovado
        4 - Desconto de Titulos
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para listar a configuracao dos itens de menu que podem ser exibidos/escondidos
    
    Alteracoes: 09/05/2018 Cria��o (Douglas Quisinski)
    
                06/06/2018 Adicionado nova op��o 4 - Desconto Titulos (Paulo Penteado (GFT)) 
    ............................................................................. */
    DECLARE
      -- Flag Recarga de Celular
      vr_flgsitrc INTEGER;
      -- Flag Pr�-Aprovado
      vr_flgpreap INTEGER;
      -- Flag Imagem Cheque
      vr_flgsitim INTEGER;
      -- Flag Desconto Titulo
      vr_flgdscti INTEGER;
      
      -- Retorna dados do credito pre aprovado      
      vr_tab_dados_cpa EMPR0002.typ_tab_dados_cpa;
      
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(5000);
      vr_des_reto VARCHAR2(5);
      vr_tab_erro gene0001.typ_tab_erro;
      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;


      -- Fun��o para gerar o XML de cada item que deve ser devolvido e sua respectiva configura��o
      FUNCTION fn_adiciona_item_menu(pr_codigo INTEGER
                                    ,pr_canal  INTEGER
                                    ,pr_habilitado INTEGER) RETURN VARCHAR2 IS
      BEGIN
        RETURN '<item_menu>' || 
                 '<codigo>'|| to_char(pr_codigo) || '</codigo>' ||
                 '<canal>' || to_char(pr_canal) || '</canal>' ||
                 '<habilitado>' || to_char(pr_habilitado) || '</habilitado>' ||
               '</item_menu>';
      END fn_adiciona_item_menu;
    
    BEGIN

      --------------------------------------------------------------------------------------
      -------------- VERIFICAR SE A IMAGEM DE CHEQUE EST� HABILITADA NA COOPERATIVA---------
      --------------------------------------------------------------------------------------

      -- Inicializar a imagem de cheque como como desabilitada do menu
      
      vr_flgsitim := 0;
      -- Carregar a opcao que � cadatrasda na tela PARREC na CECRED
      CHEQ0002.pc_situacao_img_chq_coop(pr_cdcooper => pr_cdcooper,
                                              pr_idorigem => pr_idorigem,
                                              pr_flgsitim => vr_flgsitim,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);
                                               
      --------------------------------------------------------------------------------------
      -------------- VERIFICAR SE A RECARGA DE CELULAR EST� HABILITADA NO CANAL ------------
      --------------------------------------------------------------------------------------

      -- Inicializar a recarga de celular como desabilitada do menu
      vr_flgsitrc := 0;
      -- Carregar a opcao que � cadatrasda na tela PARREC na CECRED
      RCEL0001.pc_situacao_canal_recarga(pr_cdcooper => pr_cdcooper,
                                         pr_idorigem => pr_idorigem,
                                         pr_flgsitrc => vr_flgsitrc,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);
    
      --------------------------------------------------------------------------------------
      ----------------- VERIFICAR SE O PRE-APROVADO EST� HABILITADA A CONTA ----------------
      --------------------------------------------------------------------------------------
      -- Inicializar o pr�-aprovado como desabilitado do menu
      vr_flgpreap := 0;
      -- Verificar se o cooperado possui pr�-aprovado
      EMPR0002.pc_busca_dados_cpa(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_cdoperad => '1' -- InternetBank.w e TAA_autorizador enviam fixo '1'
                                 ,pr_nmdatela => pr_nmdatela
                                 ,pr_idorigem => pr_idorigem
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_nrcpfope => pr_nrcpfope
                                 ,pr_tab_dados_cpa => vr_tab_dados_cpa
                                 ,pr_des_reto => vr_des_reto
                                 ,pr_tab_erro => vr_tab_erro);
      -- Verificar se n�o ocorreu erro
      IF vr_des_reto = 'OK' THEN
        -- Verificar se existe informa��o de contrata��o do pr�-aprovado
        IF vr_tab_dados_cpa.COUNT > 0 THEN
          -- Verificar se o valor para contrata��o do pr�-aprovado � maior que zero
          IF vr_tab_dados_cpa(vr_tab_dados_cpa.FIRST).vldiscrd > 0 THEN
            vr_flgpreap := 1;
          END IF;
        END IF;
      END IF;

      --------------------------------------------------------------------------------------
      ----------------- VERIFICAR SE O DESCONTO DE TIUTLOS EST� HABILITADA NA CONTA --------
      --------------------------------------------------------------------------------------
      -- Inicializar como desabilitado do menu
      vr_flgdscti := 0;
      BEGIN 
        -- Verificar se o cooperado possui contrato de limite ativo
        vr_flgdscti := CASE WHEN cada0003.fn_produto_habilitado(pr_cdcooper  => pr_cdcooper
                                                               ,pr_nrdconta  => pr_nrdconta
                                                               ,pr_cdproduto => 37 --> Contrato de Limite de desconto de titulo
                                                               ) = 'S' THEN 1 
                            ELSE 0 
                       END;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.Pc_Internal_Exception(pr_cdcooper => pr_cdcooper 
                                      ,pr_compleme => 'MENU0001.pc_carrega_config_menu - Desconto de T�tulos.');
      END;
      

      --------------------------------------------------------------------------------------
      ------------------------------- GERAR O XML DE RETORNO -------------------------------
      --------------------------------------------------------------------------------------
      -- Monta Retorno XML
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
                  
      -- Cabecalho do XML
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="UTF-8"?><CECRED>');
      
      -- Adicionar o Item de Menu da Recarga de celular
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo => 1 -- Lista de Dominio "1 - Recarga de Celular"
                                                                        ,pr_canal  => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flgsitrc) ); -- Identifica se a recarga de celular est� habilitada para o canal
      
      -- Adicionar o Item de Menu da Imagem de Cheque
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo => 2 -- Lista de Dominio "2 - Imagem de Cheque"
                                                                        ,pr_canal  => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flgsitim) ); -- Identifica se a imagem de cheque est� habilitada para o canal

      -- Adicionar o Item de Menu dO Pr�-Aprovado
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo => 3 -- Lista de Dominio "3 - Pr�-Aprovado"
                                                                        ,pr_canal  => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flgpreap) ); -- Identifica se o cooperado possui pr� aprovado para contrata��o e habilita no canal

      -- Adicionar o Item de Menu do Desconto de Titulos
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 4 -- Lista de Dominio "4 - Desconto de Titulos"
                                                                        ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flgdscti) ); -- Identifica se o cooperado possui pr� aprovado para contrata��o e habilita no canal

      -- Fecha o XML de retorno
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</CECRED>'
                             ,pr_fecha_xml      => TRUE);

      -- Atualiza o XML de retorno
      pr_dsxml := xmltype(vr_clob);
               
      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);


    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'MENU0001.pc_carrega_config_menu - Erro na consulta da configuracao. ERRO: ' ||
                       SQLERRM;
    END;
  END pc_carrega_config_menu;

END MENU0001;
/
