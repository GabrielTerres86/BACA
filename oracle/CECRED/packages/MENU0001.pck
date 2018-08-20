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
                                   pr_idorigem IN INTEGER,               --> ID origem da requisição
                                   pr_cdagenci IN crapage.cdagenci%TYPE, --> Código da agencia
                                   pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE, --> Numero do caixa
                                   pr_nmdatela IN craptel.nmdatela%TYPE, --> Nome da tela
                                   pr_dsxml    OUT NOCOPY XMLType,       --> XML com os itens de menu que são configuraveis em cada canal
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
  --  Alteracoes: 09/05/2018 Criação (Douglas Quisinski)
  --    
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina para devolver os itens que devem ser exibidos/escondidos no menu dos canais
  PROCEDURE pc_carrega_config_menu(pr_cdcooper IN INTEGER,               --> Codigo da Cooperativa
                                   pr_nrdconta IN INTEGER DEFAULT 0,     --> Numero da Conta
                                   pr_idseqttl IN crapttl.idseqttl%TYPE, --> Sequencial do titular
                                   pr_nrcpfope IN crapopi.nrcpfope%TYPE, --> CPF do operador juridico
                                   pr_idorigem IN INTEGER,               --> ID origem da requisição
                                   pr_cdagenci IN crapage.cdagenci%TYPE, --> Código da agencia
                                   pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE, --> Numero do caixa
                                   pr_nmdatela IN craptel.nmdatela%TYPE, --> Nome da tela
                                   pr_dsxml    OUT NOCOPY XMLType,       --> XML com os itens de menu que são configuraveis em cada canal
                                   pr_dscritic OUT VARCHAR2) IS          --> Mensagem de erro
  BEGIN
    /* .............................................................................
    Programa: pc_carrega_config_menu
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : MENU
    Autor   : Douglas Quisinski
    Data    : 09/05/2018                        Ultima atualizacao: 
    
    Dados referentes ao programa:
      Se for necessário adicionar mais itens de menu configuráveis para exibir/esconder, deverão ser adicionadas novas tags "item_menu", e os campos:
      - "codigo" baseado na lista de demínio
      - "canal" retonar o parametro que foi recebido
      - "habilitado" item
      
      Lista de Domínio para criação dos códigos:
        1 - Recarga de Celular
        2 - Imagem de Cheque
        3 - Pré-Aprovado
        4 - Desconto de Titulos
        5 - Plano de Previdencia Privada
        6 - Benefício do INSS para acessar o ECO
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para listar a configuracao dos itens de menu que podem ser exibidos/escondidos
    
    Alteracoes: 09/05/2018 - Criação (Douglas Quisinski)
    
    ............................................................................. */
    DECLARE
      -- Flag Recarga de Celular
      vr_flgsitrc INTEGER;
      -- Flag Pré-Aprovado
      vr_flgpreap INTEGER;
      -- Flag Desconto Titulo
      vr_flgdscti INTEGER;
      -- Flag Imagem Cheque
      vr_flgsitim INTEGER;
      -- Flag Plano de Previdencia Privada
      vr_flgprevd INTEGER;
      -- Flag Benefício do INSS
      vr_flgbinss INTEGER;
      
      -- XML
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
      
      -- Função para gerar o XML de cada item que deve ser devolvido e sua respectiva configuração
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
      -------------- VERIFICAR SE A IMAGEM DE CHEQUE ESTÁ HABILITADA NA COOPERATIVA---------
      --------------------------------------------------------------------------------------
      -- Inicializar a imagem de cheque como como desabilitada do menu
      vr_flgsitim := 0;
      
      --------------------------------------------------------------------------------------
      -------------- VERIFICAR SE A RECARGA DE CELULAR ESTÁ HABILITADA NO CANAL ------------
      --------------------------------------------------------------------------------------
      -- Inicializar a recarga de celular como desabilitada do menu
      vr_flgsitrc := 0;

      --------------------------------------------------------------------------------------
      ----------------- VERIFICAR SE O PRE-APROVADO ESTÁ HABILITADA A CONTA ----------------
      --------------------------------------------------------------------------------------
      -- Inicializar o pré-aprovado como desabilitado do menu
      vr_flgpreap := 0;

      --------------------------------------------------------------------------------------
      ----------------- VERIFICAR SE O DESCONTO DE TIUTLOS ESTÁ HABILITADA NA CONTA --------
      --------------------------------------------------------------------------------------
      -- Inicializar como desabilitado do menu
      vr_flgdscti := 0;

      --------------------------------------------------------------------------------------
      ----------- VERIFICAR SE O PLANO DE PREVIDENCIA PRIVADA ESTÁ HABILITADA NA CONTA -----
      --------------------------------------------------------------------------------------
      -- Sempre será habilitado
      -- No momento foi definido que sempre ficará habilitado, 
      -- para evitar mudanças futuras no serviço foi adicionado o valor fixo
      vr_flgprevd := 1;

      --------------------------------------------------------------------------------------
      ----------------- VERIFICAR SE O COOPERADO RECEBE BENEFICIO DO INSS ------------------
      --------------------------------------------------------------------------------------
      -- Inicializar como desabilitado do menu
      vr_flgbinss := 0;

      --------------------------------------------------------------------------------------
      ------------------------------- GERAR O XML DE RETORNO -------------------------------
      --------------------------------------------------------------------------------------
      -- Monta Retorno XML
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
                  
      -- Cabecalho do XML
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><CECRED>');
      
      -- Adicionar o Item de Menu da Recarga de celular
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo => 1 -- Lista de Dominio "1 - Recarga de Celular"
                                                                        ,pr_canal  => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flgsitrc) ); -- Identifica se a recarga de celular está habilitada para o canal
      
      -- Adicionar o Item de Menu da Imagem de Cheque
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo => 2 -- Lista de Dominio "2 - Imagem de Cheque"
                                                                        ,pr_canal  => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flgsitim) ); -- Identifica se a imagem de cheque está habilitada para o canal

      -- Adicionar o Item de Menu dO Pré-Aprovado
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo => 3 -- Lista de Dominio "3 - Pré-Aprovado"
                                                                        ,pr_canal  => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flgpreap) ); -- Identifica se o cooperado possui pré aprovado para contratação e habilita no canal

      -- Adicionar o Item de Menu do Desconto de Titulos
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 4 -- Lista de Dominio "4 - Desconto de Titulos"
                                                                        ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flgdscti) ); -- Identifica se o cooperado possui pré aprovado para contratação e habilita no canal

      -- Adicionar o Item de Menu do Plano de Previdencia Privada
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 5 -- Lista de Dominio "5 - Plano de Previdencia Privada"
                                                                        ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flgprevd) ); -- Identifica se o cooperado possui o plano de Previdencia Privada e habilita no canal

      -- Adicionar o Item de Menu do Emprestimo Consignado Online "ECO"
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 6 -- Lista de Dominio "6 - Empréstimo Consignado Online"
                                                                        ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flgbinss) ); -- Identifica se o cooperado possui beneficio do INSS para acessar o ECO e habilita no canal


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
