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
        7 - Pacote de Serviços
        8 - Pagamento por Arquivo - Remessa
        9 - Pagamento por Arquivo - Retorno
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para listar a configuracao dos itens de menu que podem ser exibidos/escondidos
    
    Alteracoes: 09/05/2018 - Criação (Douglas Quisinski)
    
                
                10/07/2018 - Adicionado nova opção 5 - Plano de Previdencia Privada (PRJ468 - Lombardi)
                
                01/08/2018 - Adicionado nova opção 6 - Benefício do INSS para acessar o ECO (PRJ ECO - Douglas Quisinski)
                
                10/10/2018 - Adicionado as opções 7 - Pacote de Serviços, 8 - Pagamento por Arquivo - Remessa e 
                             9 - Pagamento por Arquivo - Retorno (Dougas - Prj 285 Nova Conta Online)
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
      -- Flag Pacote de Serviço
      vr_flgpctse INTEGER;
      -- Flag Pagamento por Arquivo - Remessa
      vr_fluppgto INTEGER;
      -- Flag Pagamento por Arquivo - Retorno
      vr_flrempgt INTEGER;
      
      -- Retorna dados do credito pre aprovado      
      vr_tab_dados_cpa EMPR0002.typ_tab_dados_cpa;
      
      -- Retorna dados dos beneficios do cooperado
      vr_tab_benef INSS0003.typ_tab_beneficio_inss;
      vr_habilita_consulta_eco VARCHAR2(4000);
      
      -- Convenio para Pagamento por Arquivo
      vr_nrconven INTEGER;
      vr_dtadesao DATE;
      vr_flghomol INTEGER;
      vr_idretorn INTEGER;
      
      -- Pacote de serviços
      vr_xmldoc xmltype; --> Variável do XML de entrada
      vr_clobxmlc CLOB;

      vr_tagoco   INTEGER;
      vr_vlrtag   VARCHAR2(4000);
      
      
      -- Variáveis de ERRO
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(5000);
      vr_des_reto VARCHAR2(5);
      vr_tab_erro gene0001.typ_tab_erro;
      
      -- XML
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
      
      -- Cursor para buscar os dados da conta do cooperado
      CURSOR cr_crapass (pr_cdcooper IN INTEGER
                        ,pr_nrdconta IN INTEGER) IS
        SELECT ass.inpessoa
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper 
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Cursor para buscar o CPF do titular PF
      CURSOR cr_crapttl (pr_cdcooper IN INTEGER
                        ,pr_nrdconta IN INTEGER
                        ,pr_idseqttl IN INTEGER) IS
        SELECT ttl.nrcpfcgc
          FROM crapttl ttl
         WHERE ttl.cdcooper = pr_cdcooper 
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = pr_idseqttl;
      rw_crapttl cr_crapttl%ROWTYPE;
      
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
      BEGIN 
        -- Carregar a opcao que é cadatrasda na tela PARREC na CECRED
        RCEL0001.pc_situacao_canal_recarga(pr_cdcooper => pr_cdcooper,
                                           pr_idorigem => pr_idorigem,
                                           pr_flgsitrc => vr_flgsitrc,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.Pc_Internal_Exception(pr_cdcooper => pr_cdcooper 
                                      ,pr_compleme => 'MENU0001.pc_carrega_config_menu - Recarga de Celular.');
      END;

      --------------------------------------------------------------------------------------
      ----------------- VERIFICAR SE O PRE-APROVADO ESTÁ HABILITADA A CONTA ----------------
      --------------------------------------------------------------------------------------
      -- Inicializar o pré-aprovado como desabilitado do menu
      vr_flgpreap := 0;
      BEGIN 
        -- Verificar se o cooperado possui pré-aprovado
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
        -- Verificar se não ocorreu erro
        IF NVL(vr_des_reto,'OK') != 'NOK' THEN
          -- Verificar se existe informação de contratação do pré-aprovado
          IF vr_tab_dados_cpa.COUNT > 0 THEN
            -- Verificar se o valor para contratação do pré-aprovado é maior que zero
            IF vr_tab_dados_cpa(vr_tab_dados_cpa.FIRST).vldiscrd > 0 THEN
              vr_flgpreap := 1;
            END IF;
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.Pc_Internal_Exception(pr_cdcooper => pr_cdcooper 
                                      ,pr_compleme => 'MENU0001.pc_carrega_config_menu - Pré-Aprovado.');
      END;

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
      BEGIN 
        -- Primeiro temos que validar se a opcao esta habilitada
        vr_habilita_consulta_eco := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                             ,pr_cdcooper => 0
                                                             ,pr_cdacesso => 'HABILITAR_CONSULTA_ECO');
        
        -- Se a configuracao está habilitada, vamos realizar as consultas
        IF vr_habilita_consulta_eco = '1' THEN
          -- Beneficio eh so para pessoa fisica
          OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => pr_idseqttl);
          FETCH cr_crapttl INTO rw_crapttl;
          -- Verifica se encontrou o titular
          IF cr_crapttl%FOUND THEN
            -- Verificar se o cooperado recebe o beneficio do INSS na Ailos, para habilitar a consulta ao ECO
            INSS0003.pc_consultar_beneficios(pr_cdcooper => pr_cdcooper,  --> Codigo da Cooperativa
                                             pr_nrdconta => pr_nrdconta,  --> Numero da Conta
                                             pr_nrcpfcgc => rw_crapttl.nrcpfcgc,  --> CPF do Cooperado
                                             pr_tab_bene => vr_tab_benef, --> PL TABLE para listar os beneficios
                                             pr_dscritic => vr_dscritic); --> Mensagem de erro 
                                    
            IF vr_tab_benef.COUNT > 0 THEN
              vr_flgbinss := 1;
            END IF;
          END IF;
          -- Fechar o Cursor
          CLOSE cr_crapttl;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.Pc_Internal_Exception(pr_cdcooper => pr_cdcooper 
                                      ,pr_compleme => 'MENU0001.pc_carrega_config_menu - Beneficio do INSS');
      END;

      --------------------------------------------------------------------------------------
      ----------------- VERIFICAR SE DEVERA EXIBIR O PACOTE DE SERVICOS  -------------------
      --------------------------------------------------------------------------------------
      -- Inicializar como desabilitado do menu
      vr_flgpctse := 0;

      BEGIN 
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        
        IF cr_crapass%FOUND THEN
          
          -- Buscar os dados do pacote de tarifas
          TARI0002.pc_busca_pacote_tarifas(pr_cdcooper => pr_cdcooper 
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_inpessoa => rw_crapass.inpessoa
                                          ,pr_inconsul => 0
                                          ,pr_clobxmlc => vr_clobxmlc
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

          -- Transformar o retorno em XML
          vr_xmldoc := xmltype.createXML(vr_clobxmlc);

          -- Descobre o número de ocorrências do nodo
          gene0007.pc_lista_nodo(pr_xml      => vr_xmldoc
                                ,pr_nodo     => 'possuipac'
                                ,pr_cont     => vr_tagoco
                                ,pr_des_erro => vr_dscritic);

          -- Percorrer todos os nodos para verificar se algum deles possui valor
          FOR vr_pos_exc IN 0 .. vr_tagoco - 1  LOOP
            vr_vlrtag := GENE0007.fn_valor_tag(pr_xml     => vr_xmldoc
                                              ,pr_pos_exc => vr_pos_exc
                                              ,pr_nomtag  => 'possuipac');
              
            -- Verificar se existe valor '1'
            IF vr_vlrtag = '1' THEN
              -- Habilitar o item de menu
              vr_flgpctse := 1;
            END IF;
          END LOOP;
          
        END IF;
        
        -- Fechar Cursor
        CLOSE cr_crapass;
        
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.Pc_Internal_Exception(pr_cdcooper => pr_cdcooper 
                                      ,pr_compleme => 'MENU0001.pc_carrega_config_menu - Pagamento por Arquivo');
      END;
      
      
      --------------------------------------------------------------------------------------
      --------------- VERIFICAR SE O COOPERADO REALIZA PAGAMENTO POR ARQUIVO  --------------
      --------------------------------------------------------------------------------------
      -- Inicializar como desabilitado do menu
      vr_fluppgto := 0;
      vr_flrempgt := 0;
      
      BEGIN 
        PGTA0001.pc_verifica_conv_pgto(pr_cdcooper => pr_cdcooper   -- Código da cooperativa
                                      ,pr_nrdconta => pr_nrdconta   -- Numero Conta do cooperado
                                      ,pr_nrconven => vr_nrconven   -- Numero do Convenio
                                      ,pr_dtadesao => vr_dtadesao   -- Data de adesao
                                      ,pr_flghomol => vr_flghomol   -- Convenio esta homologado
                                      ,pr_idretorn => vr_idretorn   -- Retorno para o Cooperado (1-Internet/2-FTP)
                                      ,pr_fluppgto => vr_fluppgto   -- Flag possui convenio habilitado
                                      ,pr_flrempgt => vr_flrempgt   -- Flag possui arquivo de remessa enviado
                                      ,pr_cdcritic => vr_cdcritic   -- Codigo do Erro 
                                      ,pr_dscritic => vr_dscritic); -- Descricao do Erro
      
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.Pc_Internal_Exception(pr_cdcooper => pr_cdcooper 
                                      ,pr_compleme => 'MENU0001.pc_carrega_config_menu - Pagamento por Arquivo');
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
      -- Adicionar o Item de Menu do Pacote de Serviços
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 7 -- Lista de Dominio "7 - Pacote de Serviços"
                                                                        ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flgpctse) ); -- Identifica se o cooperado possui acesso ao pacote de serviços

      -- Adicionar o Item de Menu do Pagamento por Arquivos - Remessa
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 8 -- Lista de Dominio "8 - Pagamento por Arquivo - Remessa"
                                                                        ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_fluppgto) ); -- Identifica se o cooperado realiza Pagamentos por Arquivo

      -- Adicionar o Item de Menu do Pagamento por Arquivos - Retorno 
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 9 -- Lista de Dominio "9 - Pagamento por Arquivo - Retorno"
                                                                        ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                        ,pr_habilitado => vr_flrempgt) ); -- Identifica se o cooperado realiza Pagamentos por Arquivo

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
