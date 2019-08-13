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

  -- Rotina para buscar os itens do menu mobile.																	 
  PROCEDURE pc_busca_itens_menumobile(pr_itens             OUT VARCHAR2 --> Itens do menumobile
                                     ,pr_des_erro          OUT VARCHAR2 --> Código da crítica
                                     ,pr_dscritic          OUT VARCHAR2); --> Descrição da crítica																	 

END MENU0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.MENU0001 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: MENU0001
  --    Autor   : Douglas Quisinski
  --    Data    : Janeiro/2019                      Ultima Atualizacao:  06/05/2019   
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Configurar os itens de MENU que sao configurados para exibicao 
  --
  --  Alteracoes: 09/05/2018 Criação (Douglas Quisinski)
  --              01/02/2019 - Removido os menus da conta online para portabilidade de
  --              salários (Lucas Skroch - Supero - P485)
  --    
  --              06/06/2018 Adicionado nova opção 4 - Desconto Titulos (Paulo Penteado (GFT)) 
  --              20/02/2019 - Adicionado menus 55 e 56 e suas tratativas. (PRJ 438 - Douglas / AMcom)
  --
  --              26/02/2019 - Inclusão do item 57 (Gilberto - Supero)
  --              02/05/2019 - Adicionado controle para cooperativas habilitadas para os menus 55 e 56. (PRJ 438 - Douglas / AMcom)
  --  
  --    
  --              06/05/2019 - Adicionadas opcoes 58 e 59 - P485/2 (Diego). 
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
    Data    : 09/05/2018                        Ultima atualizacao: 01/02/2019
    
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
        14 - Conta Corrente > Consultas > Extrato - PJ485 - Inicio
        15 - Conta Corrente > Consultas > Lançamentos Futuros
        16 - Conta Corrente > Demais extratos > Extrato de Tarifas
        17 - Conta Corrente > Salários > Comprovante Salarial
        18 - Conta Corrente > Provisão de Operações > Agendamento de Saque em Espécie
        19 - Conta Corrente > Provisão de Operações > Consulta de Agendamentos
        20 - Pagamentos > Contas > Água, Luz, Telefone e Outras
        21 - Pagamentos > Contas > Boletos Diversos
        22 - Pagamentos > Tributos > GPS - Previdência Social
        23 - Pagamentos > Tributos > DAS - Simples Nacional
        24 - Pagamentos > Tributos > DARF - Receitas Federais
        25 - Pagamentos > Tributos > FGTS - Fundo de Garantia
        26 - Pagamentos > Tributos > DAE - Simples Doméstico/eSocial
        27 - Pagamentos > Tributos > Veículos (IPVA, DPVAT, Licenciamentos)
        28 - Pagamentos > DDA - Débito Direto Autorizado > Pagamento de DDA
        29 - Pagamentos > Débito Automático > Cadastrar
        30 - Pagamentos > Débito Automático > Contas Cadastradas
        31 - Pagamentos > Débito Automático > Lançamentos Programados
        32 - Pagamentos > Débito Automático > Serviço de SMS
        33 - Pagamentos > Outros > Comprovantes
        34 - Pagamentos > Outros > Agendamentos
        35 - Pagamentos > Outros > Convênios Aceitos
        36 - Transferências > Entre Contas > Contas do Sistema AILOS
        37 - Transferências > Entre Contas > Outras Instituições - TED
        38 - Transferências > Favorecidos > Cadastrar
        39 - Transferências > Favorecidos > Gerenciar Favorecidos
        40 - Transferências > Outros > Comprovantes
        41 - Transferências > Outros > Agendamentos
        42 - Investimentos > Cotas Capital > Consultar
        47 - Conveniências > Perfil > Informações Cadastrais
        48 - Conveniências > Perfil > Alteração de Senha
        49 - Conveniências > Perfil > Configuração de Favoritos
        50 - Tela inicial ATM > Saque
        51 - Tela inicial ATM > Transferências
        52 - Tela inicial ATM > Meu Cadastro
        53 - Tela inicial ATM > Botão Pressione para visualizar seu saldo 
        54 - Tela inicial ATM > Pagamentos - PJ485 - FIM
        55 - Simular e Contratar
        56 - Acompanhamento de Proposta Credito
        57 - Conta Corrente > Salários > Portabilidade de Salário	
        58 - Tela inicial ATM > Deposito
        59 - Tela inicial ATM > Saldo e Extrato
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para listar a configuracao dos itens de menu que podem ser exibidos/escondidos
    
    Alteracoes: 09/05/2018 - Criação (Douglas Quisinski)
    
                06/06/2018 - Adicionado nova opção 4 - Desconto Titulos (Paulo Penteado (GFT)) 
                
                10/07/2018 - Adicionado nova opção 5 - Plano de Previdencia Privada (PRJ468 - Lombardi)
                
                01/08/2018 - Adicionado nova opção 6 - Benefício do INSS para acessar o ECO (PRJ ECO - Douglas Quisinski)
                
                10/10/2018 - Adicionado as opções 7 - Pacote de Serviços, 8 - Pagamento por Arquivo - Remessa e 
                             9 - Pagamento por Arquivo - Retorno (Dougas - Prj 285 Nova Conta Online)

                01/03/2019 - Ajustar o PACOTE DE SERVICOS para ser exibido quando a cooperativa possuir qualquer pacote cadastrado
                            (Douglas - SCTASK0049271)  

                30/01/2019 - Removido diversas opções de menus da conta online para portabilidade de salários (Lucas Skroch - Supero - P485)

				01/02/2019 - Adaptação da rotina para enviar a camada de serviços apenas os itens de menu 
                             a serem exibidos (Lucas Skroch - Supero - P485)
                             
                20/02/2019 - Adicionado menus 55 e 56 e suas tratativas. (PRJ 438 - Douglas / AMcom)
                
                02/05/2019 - Adicionado controle para cooperativas habilitadas para os menus 55 e 56. (PRJ 438 - Douglas / AMcom)
                
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

      -- Flag Conta Corrente > Consultas > Extrato - PJ485 - Inicio
      vr_flgconext INTEGER := 0;
      -- Flag Conta Corrente > Consultas > Lançamentos Futuros
      vr_flglcmfut INTEGER := 0;
      -- Flag Conta Corrente > Demais extratos > Extrato de Tarifas
      vr_flgexttar INTEGER := 0;
      -- Flag Conta Corrente > Salários > Comprovante Salarial
      vr_flgcmpsal INTEGER := 0;
      -- Flag Conta Corrente > Provisão de Operações > Agendamento de Saque em Espécie
      vr_flgagesaq INTEGER := 0;
      -- Flag Conta Corrente > Provisão de Operações > Consulta de Agendamentos
      vr_flgconage INTEGER := 0;
      -- Flag Pagamentos > Contas > Água, Luz, Telefone e Outras
      vr_flgaltout INTEGER := 0;
      -- Flag Pagamentos > Contas > Boletos Diversos
      vr_flgboldiv INTEGER := 0;
      -- Flag Pagamentos > Tributos > GPS - Previdência Social
      vr_flgpaggps INTEGER := 0;
      -- Flag Pagamentos > Tributos > DAS - Simples Nacional
      vr_flgpagdas INTEGER := 0;
      -- Flag Pagamentos > Tributos > DARF - Receitas Federais
      vr_flgpagdar INTEGER := 0;
      -- Flag Pagamentos > Tributos > FGTS - Fundo de Garantia
      vr_flgpagfgt INTEGER := 0;
      -- Flag Pagamentos > Tributos > DAE - Simples Doméstico/eSocial
      vr_flgpagdae INTEGER := 0;
      -- Flag Pagamentos > Tributos > Veículos (IPVA, DPVAT, Licenciamentos)
      vr_flgveicos INTEGER := 0;
      -- Flag Pagamentos > DDA - Débito Direto Autorizado > Pagamento de DDA
      vr_flgpagdda INTEGER := 0;     
      -- Flag Pagamentos > Débito Automático > Cadastrar
      vr_flgcaddeb INTEGER := 0;
      -- Flag Pagamentos > Débito Automático > Contas Cadastradas
      vr_flgconcad INTEGER := 0;
      -- Flag Pagamentos > Débito Automático > Lançamentos Programados
      vr_flglcnprg INTEGER := 0;
      -- Flag Pagamentos > Débito Automático > Serviço de SMS
      vr_flgsersms INTEGER := 0;
      -- Flag Pagamentos > Outros > Comprovantes
      vr_flgoutcmp INTEGER := 0;
      -- Flag Pagamentos > Outros > Agendamentos
      vr_flgoutage INTEGER := 0;
      -- Flag Pagamentos > Outros > Convênios Aceitos
      vr_flgconace INTEGER := 0;
      -- Flag Transferências > Entre Contas > Contas do Sistema AILOS
      vr_flgconsis INTEGER := 0;
      -- Flag Transferências > Entre Contas > Outras Instituições - TED
      vr_flgoutted INTEGER := 0;
      -- Flag Transferências > Favorecidos > Cadastrar
      vr_flgfavcad INTEGER := 0;
      -- Flag Transferências > Favorecidos > Gerenciar Favorecidos
      vr_flggerfav INTEGER := 0;
      -- Flag Transferências > Outros > Comprovantes
      vr_flgtrscmp INTEGER := 0;
      -- Flag Transferências > Outros > Agendamentos
      vr_flgtrsage INTEGER := 0;
      -- Flag Investimentos > Cotas Capital > Consultar
      vr_flgcotcon INTEGER := 0;
      -- Flag Conveniências > Perfil > Informações Cadastrais
      vr_flginfcad INTEGER := 0;
      -- Flag Conveniências > Perfil > Alteração de Senha
      vr_flgaltsen INTEGER := 0;
      -- Flag Conveniências > Perfil > Configuração de Favoritos
      vr_flgcfgfav INTEGER := 0;
      -- Flag Tela inicial ATM > Saque
      vr_flgatmsaq INTEGER := 0;
      -- Flag Tela inicial ATM > Transferências
      vr_flgatmtrs INTEGER := 0;
      -- Flag Tela inicial ATM > Meu Cadastro
      vr_flgatmcad INTEGER := 0;            
      -- FlagTela inicial ATM > Botão Pressione para visualizar seu saldo
      vr_flgatmsld INTEGER := 0; 
      -- FlagTela inicial ATM > Pagamentos
      vr_flgpagatm INTEGER := 0;
      -- FlagTela inicial ATM > Deposito
      vr_flgatmdep INTEGER := 0;
      -- FlagTela inicial ATM > Saldo e Extrato
      vr_flgatmext INTEGER := 0;
      -- PJ485 - Fim
      -- FlagTela Portabilidade de Salário
      vr_flgctapot INTEGER := 0;
      
      --PRJ438
      --Flag Tela Simular e Contratar
      vr_flgsimcon INTEGER := 0;
      --Flag Tela Acompanhamento de Proposta Credito
      vr_flgacopro INTEGER := 0;
      --Controle para cooperativas habilitadas	
      vr_dslstcop VARCHAR2(4000);
      
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

      -- Cursor para verificar se existe a pessoa e o tipo de pessoa e conta - PJ485 - Inicio
      CURSOR cr_modalidade_tipo(pr_cdcooper IN crapass.cdcooper%type
                               ,pr_nrdconta IN crapass.nrdconta%type) IS
      
         SELECT nvl(c.cdmodalidade_tipo,0) cdmodalidade_tipo
               ,a.inpessoa
           FROM crapass a,       
                tbcc_tipo_conta c
          WHERE c.inpessoa     = a.inpessoa
            AND c.cdtipo_conta = a.cdtipcta
            AND a.cdcooper     = pr_cdcooper
            AND a.nrdconta     = pr_nrdconta;
      rw_modalidade_tipo cr_modalidade_tipo%ROWTYPE;
	  -- PJ485 - Fim
      
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
      BEGIN       
        -- Carregar a opcao que é cadastrada na tela PARREC na CECRED
        CHEQ0002.pc_situacao_img_chq_coop(pr_cdcooper => pr_cdcooper,
                                          pr_idorigem => pr_idorigem,
                                          pr_flgsitim => vr_flgsitim,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
      EXCEPTION
        WHEN OTHERS THEN
        CECRED.Pc_Internal_Exception(pr_cdcooper => pr_cdcooper 
                                    ,pr_compleme => 'MENU0001.pc_carrega_config_menu - Imagem de Cheque.');
      END;   
      
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
      ----------------- VERIFICAR SE O DESCONTO DE TITULOS ESTÁ HABILITADA NA CONTA --------
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
                                      ,pr_compleme => 'MENU0001.pc_carrega_config_menu - Desconto de Títulos.');
      END;

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
                                                                                                                                                      
          -- Verificar se existe algum pacote de tarifas cadastradas
          IF vr_tagoco > 0 THEN
              -- Habilitar o item de menu
              vr_flgpctse := 1;
            END IF;
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
      -------------- VERIFICAR SE A CONTA PERMITE SIMULAR E CONTRATAR EMPRESTIMOS  ---------
      --------------------------------------------------------------------------------------
      --Flag Tela Simular e Contratar
      vr_flgsimcon := 0;
      --Flag Tela Acompanhamento de Proposta Credito
      vr_flgacopro := 0;
      BEGIN       
        --Verifica se a cooperativa está habilitada para esta função
        vr_dslstcop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                 pr_cdcooper => pr_cdcooper, 
                                                 pr_cdacesso => 'LIBERA_COOP_SIMULA_IB');
                                                 
        --Só faz as validações se a cooperativa estiver habilitada                                           
        IF gene0002.fn_existe_valor(pr_base => vr_dslstcop
                                  , pr_busca => to_char(pr_cdcooper)
                                  , pr_delimite => ';') = 'S' THEN                                                     
          
          --Só faz as validações se NÃO for um operador
          IF (pr_nrcpfope is null OR pr_nrcpfope = 0) THEN
              
          -- Carrega a permissão da conta para o menu
          CADA0006.pc_valida_adesao_produto(pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_cdprodut => 31, --Emprestimo
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          IF (vr_cdcritic IS NULL AND vr_dscritic IS NULL) THEN
            --Tem permissao da conta mas
            --Só exibe o menu se for PF e primeiro titlar ou PJ
            OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta);
                            
            FETCH cr_crapass INTO rw_crapass;
            CLOSE cr_crapass;
            IF (rw_crapass.inpessoa = 1 and pr_idseqttl = 1)
            OR (rw_crapass.inpessoa = 2) THEN
              vr_flgsimcon := 1;
              vr_flgacopro := 1;
            END IF;
          END IF;
        END IF;
      END IF;
        
      EXCEPTION
        WHEN OTHERS THEN
        CECRED.Pc_Internal_Exception(pr_cdcooper => pr_cdcooper 
                                    ,pr_compleme => 'MENU0001.pc_carrega_config_menu - Simulacao Emprestimo.');
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
      
      /* Caso for conta salário, envia apenas os menus a serem exibidos para conta salário - PJ485 - Inicio
         Caso contrário, segue a rotina como funciona atualmente */
      BEGIN
        
        OPEN cr_modalidade_tipo(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta);
                          
        --Posicionar no proximo registro
        FETCH cr_modalidade_tipo INTO rw_modalidade_tipo;
        CLOSE cr_modalidade_tipo;
        
        IF  rw_modalidade_tipo.inpessoa = 1 THEN -- Pessoa Física
            vr_flgctapot := 1;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('rw_modalidade_tipo.inpessoa :'||rw_modalidade_tipo.inpessoa||' vr_flgctapot :'||vr_flgctapot);

        -- Caso encontrar e for de portabilidade de salario = 2, habilita os menus na conta online
        IF rw_modalidade_tipo.cdmodalidade_tipo = 2 THEN                                                      
           vr_flgconext := 1; -- item 14
           vr_flglcmfut := 1; -- item 15
           vr_flgexttar := 1; -- item 16
           vr_flgcmpsal := 1; -- item 17
           vr_flgagesaq := 1; -- item 18
           vr_flgconage := 1; -- item 19
           vr_flgaltout := 1; -- item 20
           vr_flgboldiv := 1; -- item 21
           vr_flgpaggps := 1; -- item 22
           vr_flgpagdas := 1; -- item 23
           vr_flgpagdar := 1; -- item 24
           vr_flgpagfgt := 1; -- item 25
           vr_flgpagdae := 1; -- item 26
           vr_flgveicos := 1; -- item 27
           vr_flgpagdda := 1; -- item 28     
           vr_flgcaddeb := 1; -- item 29
           vr_flgconcad := 1; -- item 30
           vr_flglcnprg := 1; -- item 31
           vr_flgsersms := 1; -- item 32
           vr_flgoutcmp := 1; -- item 33
           vr_flgoutage := 1; -- item 34
           vr_flgconace := 1; -- item 35
           vr_flgconsis := 1; -- item 36
           vr_flgoutted := 1; -- item 37
           vr_flgfavcad := 1; -- item 38
           vr_flggerfav := 1; -- item 39
           vr_flgtrscmp := 1; -- item 40
           vr_flgtrsage := 1; -- item 41
           vr_flgcotcon := 1; -- item 42
           vr_flginfcad := 1; -- item 47
           vr_flgaltsen := 1; -- item 48
           vr_flgcfgfav := 1; -- item 49
           vr_flgatmsaq := 1; -- item 50
           vr_flgatmtrs := 1; -- item 51
           vr_flgatmcad := 1; -- item 52
           vr_flgatmsld := 1; -- item 53
           vr_flgpagatm := 1; -- item 54
           vr_flgatmdep := 1; -- item 58
           vr_flgatmext := 1; -- item 59
           
           -- Adicionar o Item de Menu de Conta Corrente > Consultas > Extrato na Conta Online
           GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                  ,pr_texto_completo => vr_xml_temp
                                  ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 14 -- Lista de Dominio "14 - Conta Corrente > Consultas > Extrato"
                                                                             ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                             ,pr_habilitado => vr_flgconext) ); 
                                                                              
           -- Adicionar o Item de Menu de Conta Corrente > Consultas > Lançamentos Futuros na Conta Online
           GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                  ,pr_texto_completo => vr_xml_temp
                                  ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 15 -- Lista de Dominio "15 - Conta Corrente > Consultas > Lançamentos Futuros"
                                                                             ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                             ,pr_habilitado => vr_flglcmfut) ); 
                                                                                                                                                      
            -- Adicionar o Item de Menu de Conta Corrente > Demais extratos > Extrato de Tarifas na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 16 -- Lista de Dominio "16 - Conta Corrente > Demais extratos > Extrato de Tarifas"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgexttar) ); 
                                                                              
            -- Adicionar o Item de Menu de Conta Corrente > Salários > Comprovante Salarial na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 17 -- Lista de Dominio "17 - Conta Corrente > Salários > Comprovante Salarial"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgcmpsal) ); 

            -- Adicionar o Item de Menu de CConta Corrente > Provisão de Operações > Agendamento de Saque em Espécie na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 18 -- Lista de Dominio "18 - Conta Corrente > Provisão de Operações > Agendamento de Saque em Espécie"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgagesaq) ); 
                                                                              
            -- Adicionar o Item de Menu de Conta Corrente > Provisão de Operações > Consulta de Agendamentos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 19 -- Lista de Dominio "19 - Conta Corrente > Provisão de Operações > Consulta de Agendamentos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgconage) ); 

            -- Adicionar o Item de Menu Pagamentos > Contas > Água, Luz, Telefone e Outras na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 20 -- Lista de Dominio "20 - Pagamentos > Contas > Água, Luz, Telefone e Outras"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgaltout) ); 
                                                                              
            -- Adicionar o Item de Menu de Pagamentos > Contas > Boletos Diversos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 21 -- Lista de Dominio "21 - Pagamentos > Contas > Boletos Diversos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgboldiv) ); 
                                                                                                                                                      
            -- Adicionar o Item de Menu de Pagamentos > Tributos > GPS - Previdência Social na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 22 -- Lista de Dominio "22 - Pagamentos > Tributos > GPS - Previdência Social"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgpaggps) ); 
                                                                              
            -- Adicionar o Item de Menu de Pagamentos > Tributos > DAS - Simples Nacional na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 23 -- Lista de Dominio "23 - Pagamentos > Tributos > DAS - Simples Nacional
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgpagdas) ); 

            -- Adicionar o Item de Menu de Pagamentos > Tributos > DARF - Receitas Federais na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 24 -- Lista de Dominio "24 - Pagamentos > Tributos > DARF - Receitas Federais"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgpagdar) ); 
                                                                              
            -- Adicionar o Item de Menu de Pagamentos > Tributos > FGTS - Fundo de Garantia na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 25 -- Lista de Dominio "25 - Pagamentos > Tributos > FGTS - Fundo de Garantia"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgpagfgt) ); 
                                                                              
            -- Adicionar o Item de Menu de APagamentos > Tributos > DAE - Simples Doméstico/eSocial na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 26 -- Lista de Dominio "26 - Pagamentos > Tributos > DAE - Simples Doméstico/eSocial"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgpagdae) ); 

            -- Adicionar o Item de Menu de Pagamentos > Tributos > Veículos (IPVA, DPVAT, Licenciamentos) na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 27 -- Lista de Dominio "27 - Pagamentos > Tributos > Veículos (IPVA, DPVAT, Licenciamentos)"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgveicos) ); 
                                                                                                                                                      
            -- Adicionar o Item de Menu de Pagamentos > DDA - Débito Direto Autorizado > Pagamento de DDA na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 28 -- Lista de Dominio "28 - Pagamentos > DDA - Débito Direto Autorizado > Pagamento de DDA"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgpagdda) ); 
                                                                              
            -- Adicionar o Item de Menu de Pagamentos > Débito Automático > Cadastrar na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 29 -- Lista de Dominio "29 - Pagamentos > Débito Automático > Cadastrar"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgcaddeb) ); 

            -- Adicionar o Item de Menu de Pagamentos > Débito Automático > Contas Cadastradas na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 30 -- Lista de Dominio "30 - Pagamentos > Débito Automático > Contas Cadastradas"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgconcad) ); 
                                                                              
            -- Adicionar o Item de Menu de Pagamentos > Débito Automático > Lançamentos Programados na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 31 -- Lista de Dominio "31 - Pagamentos > Débito Automático > Lançamentos Programados"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flglcnprg) ); 

            -- Adicionar o Item de Menu de Pagamentos > Débito Automático > Serviço de SMS na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 32 -- Lista de Dominio "32 - Pagamentos > Débito Automático > Serviço de SMS"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgsersms) ); 

            -- Adicionar o Item de Menu de Pagamentos > Outros > Comprovantes na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 33 -- Lista de Dominio "33 - Pagamentos > Outros > Comprovantes"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgoutcmp) ); 
                                                                                                                                                      
            -- Adicionar o Item de Menu de Pagamentos > Outros > Agendamentos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 34 -- Lista de Dominio "34 - Pagamentos > Outros > Agendamentos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgoutage) ); 
                                                                              
            -- Adicionar o Item de Menu de Pagamentos > Outros > Convênios Aceitos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 35 -- Lista de Dominio "35 - Pagamentos > Outros > Convênios Aceitos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgconace) ); 

            -- Adicionar o Item de Menu de Transferências > Entre Contas > Contas do Sistema AILOS na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 36 -- Lista de Dominio "36 - Transferências > Entre Contas > Contas do Sistema AILOS"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgconsis) ); 
                                                                              
            -- Adicionar o Item de Menu de Transferências > Entre Contas > Outras Instituições - TED na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 37 -- Lista de Dominio "37 - Transferências > Entre Contas > Outras Instituições - TED"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgoutted) ); 

            -- Adicionar o Item de Menu de Transferências > Favorecidos > Cadastrar na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 38 -- Lista de Dominio "38 - Transferências > Favorecidos > Cadastrar"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgfavcad) ); 
                                                                              
            -- Adicionar o Item de Menu de Transferências > Favorecidos > Gerenciar Favorecidos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 39 -- Lista de Dominio "39 - Transferências > Favorecidos > Gerenciar Favorecidos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flggerfav) ); 
                                                                                                                                                    
            -- Adicionar o Item de Menu de Transferências > Outros > Comprovantes na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 40 -- Lista de Dominio "40 - Transferências > Outros > Comprovantes"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgtrscmp) ); 
                                                                              
            -- Adicionar o Item de Menu de Transferências > Outros > Agendamentos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 41 -- Lista de Dominio "41 - Transferências > Outros > Agendamentos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgtrsage) ); 

            -- Adicionar o Item de Menu de Investimentos > Cotas Capital > Consultar na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 42 -- Lista de Dominio "Investimentos > Cotas Capital > Consultar"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgcotcon) ); 
                                                                              
            -- Adicionar o Item de Menu de Conveniências > Perfil > Informações Cadastrais na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 47 -- Lista de Dominio "47 - Conveniências > Perfil > Informações Cadastrais"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flginfcad) ); 

            -- Adicionar o Item de Menu de Conveniências > Perfil > Alteração de Senha na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 48 -- Lista de Dominio "48 - Conveniências > Perfil > Alteração de Senha"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgaltsen) ); 
                                                                              
            -- Adicionar o Item de Menu de Conveniências > Perfil > Configuração de Favoritos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 49 -- Lista de Dominio "49 - Conveniências > Perfil > Configuração de Favoritos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgcfgfav) ); 
                                                                               
            -- Adicionar o Item de Menu de Tela inicial ATM > Saque no ATM
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 50 -- Lista de Dominio "50 - Tela inicial ATM > Saque"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgatmsaq) ); 

            -- Adicionar o Item de Menu de Tela inicial ATM > Transferências no ATM
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 51 -- Lista de Dominio "51 - Tela inicial ATM > Transferências"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgatmtrs) ); 
                                                                              
            -- Adicionar o Item de Menu de Tela inicial ATM > Meu Cadastro no ATM
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 52 -- Lista de Dominio "52 - Tela inicial ATM > Meu Cadastro"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgatmcad) ); 
                                                                              
            -- Adicionar o Item de Menu de Tela inicial ATM > Botão Pressione para visualizar seu saldo no ATM
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 53 -- Lista de Dominio "53 - Tela inicial ATM > Botão Pressione para visualizar seu saldo"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgatmsld) ); 
                                                                              
            -- Adicionar o Item de Menu de Tela inicial ATM > Menu Pagamentos no ATM
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 54 -- Lista de Dominio "54 - Tela inicial ATM > Menu Pagamentos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgpagatm) ); 
            
            -- Adicionar o Item de Menu de Tela inicial ATM > Deposito
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 58 -- Lista de Dominio "58 - Tela inicial ATM > Deposito"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgatmdep) ); 
                                                                              
            -- Adicionar o Item de Menu de Tela inicial ATM > Saldo e Extrato
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 59 -- Lista de Dominio "59 - Tela inicial ATM > Saldo e Extrato"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgatmext) ); 
            
        ELSE
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

            -- Adicionar o Item de Menu do Simular e Contratar 
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 55 -- Lista de Dominio "55 - Simular e Contratar"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgsimcon) ); -- Identifica se o cooperado pode simular e contratar emprestimo
           	
            -- Adicionar o Item de Menu do Acompanhamento de Proposta Credito  
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 56 -- Lista de Dominio "56 - Simular e Contratar"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgacopro) ); -- Identifica se o cooperado pode acompanhar Proposta Credito

	        -- Adicionar o Item de Menu de Tela Conta Corrente > Salários > Portabilidade de Salário
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 57 -- Lista de Dominio 57 - Conta Corrente > Salários > Portabilidade de Salário
                                                                          ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                          ,pr_habilitado => vr_flgctapot ) ); 

        END IF;
        
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.Pc_Internal_Exception(pr_cdcooper => pr_cdcooper 
                                      ,pr_compleme => 'MENU0001.pc_carrega_config_menu - Portabilidade de Salario.');
      END;  -- PJ485 - FIM
                                                                                                                                                  
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
	
  PROCEDURE pc_busca_itens_menumobile(pr_itens             OUT VARCHAR2 --> Itens do menumobile
                                     ,pr_des_erro          OUT VARCHAR2 --> Código da crítica
                                     ,pr_dscritic          OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_busca_itens_menumobile
        Sistema : CECRED MOBILE
        Sigla   : MENU
        Autor   : Augusto (Supero)
        Data    : Janeiro/19.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar os itens do menu mobile.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca tipo de conta
      CURSOR cr_itens IS
        SELECT menumobileid
				FROM (SELECT m.menumobileid
										,ltrim(sys_connect_by_path(m.nome, ' -> '), ' -> ') nome
										,sys_connect_by_path(lpad(m.sequencia, 3, '0'), '-') seq
								FROM (SELECT menumobileid
														,nome
														,menupaiid
														,sequencia
												FROM menumobile
											 WHERE versaomaximaapp IS NULL) m
							 START WITH m.menupaiid IS NULL
							CONNECT BY PRIOR m.menumobileid = m.menupaiid
							 ORDER BY seq);
      rw_itens cr_itens%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'MENU0001'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Busca os itens
      FOR rw_itens IN cr_itens LOOP
			    pr_itens := pr_itens || rw_itens.menumobileid || ',';
			END LOOP;
			
			IF TRIM(pr_itens) IS NOT NULL THEN
				pr_itens := SUBSTR(pr_itens, 0, LENGTH(pr_itens)-1);
			END IF;
      
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_busca_itens_menumobile: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_busca_itens_menumobile;	

END MENU0001;
/
