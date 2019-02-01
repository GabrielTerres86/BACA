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

  -- Rotina para buscar os itens do menu mobile.																	 
  PROCEDURE pc_busca_itens_menumobile(pr_itens             OUT VARCHAR2 --> Itens do menumobile
                                     ,pr_des_erro          OUT VARCHAR2 --> C�digo da cr�tica
                                     ,pr_dscritic          OUT VARCHAR2); --> Descri��o da cr�tica																	 

END MENU0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.MENU0001 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: MENU0001
  --    Autor   : Douglas Quisinski
  --    Data    : Janeiro/2019                      Ultima Atualizacao:  01/02/2019   
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Configurar os itens de MENU que sao configurados para exibicao 
  --
  --  Alteracoes: 09/05/2018 Cria��o (Douglas Quisinski)
  --              01/02/2019 - Removido os menus da conta online para portabilidade de
  --              sal�rios (Lucas Skroch - Supero - P485)
  --    
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
    Data    : 09/05/2018                        Ultima atualizacao: 01/02/2019
    
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
        5 - Plano de Previdencia Privada
        6 - Benef�cio do INSS para acessar o ECO
        14 - Conta Corrente > Consultas > Extrato - PJ485 - Inicio
        15 - Conta Corrente > Consultas > Lan�amentos Futuros
        16 - Conta Corrente > Demais extratos > Extrato de Tarifas
        17 - Conta Corrente > Sal�rios > Comprovante Salarial
        18 - Conta Corrente > Provis�o de Opera��es > Agendamento de Saque em Esp�cie
        19 - Conta Corrente > Provis�o de Opera��es > Consulta de Agendamentos
        20 - Pagamentos > Contas > �gua, Luz, Telefone e Outras
        21 - Pagamentos > Contas > Boletos Diversos
        22 - Pagamentos > Tributos > GPS - Previd�ncia Social
        23 - Pagamentos > Tributos > DAS - Simples Nacional
        24 - Pagamentos > Tributos > DARF - Receitas Federais
        25 - Pagamentos > Tributos > FGTS - Fundo de Garantia
        26 - Pagamentos > Tributos > DAE - Simples Dom�stico/eSocial
        27 - Pagamentos > Tributos > Ve�culos (IPVA, DPVAT, Licenciamentos)
        28 - Pagamentos > DDA - D�bito Direto Autorizado > Pagamento de DDA
        29 - Pagamentos > D�bito Autom�tico > Cadastrar
        30 - Pagamentos > D�bito Autom�tico > Contas Cadastradas
        31 - Pagamentos > D�bito Autom�tico > Lan�amentos Programados
        32 - Pagamentos > D�bito Autom�tico > Servi�o de SMS
        33 - Pagamentos > Outros > Comprovantes
        34 - Pagamentos > Outros > Agendamentos
        35 - Pagamentos > Outros > Conv�nios Aceitos
        36 - Transfer�ncias > Entre Contas > Contas do Sistema AILOS
        37 - Transfer�ncias > Entre Contas > Outras Institui��es - TED
        38 - Transfer�ncias > Favorecidos > Cadastrar
        39 - Transfer�ncias > Favorecidos > Gerenciar Favorecidos
        40 - Transfer�ncias > Outros > Comprovantes
        41 - Transfer�ncias > Outros > Agendamentos
        42 - Investimentos > Cotas Capital > Consultar
        47 - Conveni�ncias > Perfil > Informa��es Cadastrais
        48 - Conveni�ncias > Perfil > Altera��o de Senha
        49 - Conveni�ncias > Perfil > Configura��o de Favoritos
        50 - Tela inicial ATM > Saque
        51 - Tela inicial ATM > Transfer�ncias
        52 - Tela inicial ATM > Meu Cadastro
        53 - Tela inicial ATM > Bot�o Pressione para visualizar seu saldo 
        54 - Tela inicial ATM > Pagamentos - PJ485 - FIM
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para listar a configuracao dos itens de menu que podem ser exibidos/escondidos
    
    Alteracoes: 09/05/2018 - Cria��o (Douglas Quisinski)
    
                30/01/2019 - Removido diversas op��es de menus da conta online para portabilidade de sal�rios (Lucas Skroch - Supero - P485)
				01/02/2019 - Adapta��o da rotina para enviar a camada de servi�os apenas os itens de menu 
                             a serem exibidos (Lucas Skroch - Supero - P485)
    ............................................................................. */
    DECLARE
      -- Flag Recarga de Celular
      vr_flgsitrc INTEGER;
      -- Flag Pr�-Aprovado
      vr_flgpreap INTEGER;
      -- Flag Desconto Titulo
      vr_flgdscti INTEGER;
      -- Flag Imagem Cheque
      vr_flgsitim INTEGER;
      -- Flag Plano de Previdencia Privada
      vr_flgprevd INTEGER;
      -- Flag Benef�cio do INSS
      vr_flgbinss INTEGER;
      -- Flag Conta Corrente > Consultas > Extrato - PJ485 - Inicio
      vr_flgconext INTEGER := 0;
      -- Flag Conta Corrente > Consultas > Lan�amentos Futuros
      vr_flglcmfut INTEGER := 0;
      -- Flag Conta Corrente > Demais extratos > Extrato de Tarifas
      vr_flgexttar INTEGER := 0;
      -- Flag Conta Corrente > Sal�rios > Comprovante Salarial
      vr_flgcmpsal INTEGER := 0;
      -- Flag Conta Corrente > Provis�o de Opera��es > Agendamento de Saque em Esp�cie
      vr_flgagesaq INTEGER := 0;
      -- Flag Conta Corrente > Provis�o de Opera��es > Consulta de Agendamentos
      vr_flgconage INTEGER := 0;
      -- Flag Pagamentos > Contas > �gua, Luz, Telefone e Outras
      vr_flgaltout INTEGER := 0;
      -- Flag Pagamentos > Contas > Boletos Diversos
      vr_flgboldiv INTEGER := 0;
      -- Flag Pagamentos > Tributos > GPS - Previd�ncia Social
      vr_flgpaggps INTEGER := 0;
      -- Flag Pagamentos > Tributos > DAS - Simples Nacional
      vr_flgpagdas INTEGER := 0;
      -- Flag Pagamentos > Tributos > DARF - Receitas Federais
      vr_flgpagdar INTEGER := 0;
      -- Flag Pagamentos > Tributos > FGTS - Fundo de Garantia
      vr_flgpagfgt INTEGER := 0;
      -- Flag Pagamentos > Tributos > DAE - Simples Dom�stico/eSocial
      vr_flgpagdae INTEGER := 0;
      -- Flag Pagamentos > Tributos > Ve�culos (IPVA, DPVAT, Licenciamentos)
      vr_flgveicos INTEGER := 0;
      -- Flag Pagamentos > DDA - D�bito Direto Autorizado > Pagamento de DDA
      vr_flgpagdda INTEGER := 0;     
      -- Flag Pagamentos > D�bito Autom�tico > Cadastrar
      vr_flgcaddeb INTEGER := 0;
      -- Flag Pagamentos > D�bito Autom�tico > Contas Cadastradas
      vr_flgconcad INTEGER := 0;
      -- Flag Pagamentos > D�bito Autom�tico > Lan�amentos Programados
      vr_flglcnprg INTEGER := 0;
      -- Flag Pagamentos > D�bito Autom�tico > Servi�o de SMS
      vr_flgsersms INTEGER := 0;
      -- Flag Pagamentos > Outros > Comprovantes
      vr_flgoutcmp INTEGER := 0;
      -- Flag Pagamentos > Outros > Agendamentos
      vr_flgoutage INTEGER := 0;
      -- Flag Pagamentos > Outros > Conv�nios Aceitos
      vr_flgconace INTEGER := 0;
      -- Flag Transfer�ncias > Entre Contas > Contas do Sistema AILOS
      vr_flgconsis INTEGER := 0;
      -- Flag Transfer�ncias > Entre Contas > Outras Institui��es - TED
      vr_flgoutted INTEGER := 0;
      -- Flag Transfer�ncias > Favorecidos > Cadastrar
      vr_flgfavcad INTEGER := 0;
      -- Flag Transfer�ncias > Favorecidos > Gerenciar Favorecidos
      vr_flggerfav INTEGER := 0;
      -- Flag Transfer�ncias > Outros > Comprovantes
      vr_flgtrscmp INTEGER := 0;
      -- Flag Transfer�ncias > Outros > Agendamentos
      vr_flgtrsage INTEGER := 0;
      -- Flag Investimentos > Cotas Capital > Consultar
      vr_flgcotcon INTEGER := 0;
      -- Flag Conveni�ncias > Perfil > Informa��es Cadastrais
      vr_flginfcad INTEGER := 0;
      -- Flag Conveni�ncias > Perfil > Altera��o de Senha
      vr_flgaltsen INTEGER := 0;
      -- Flag Conveni�ncias > Perfil > Configura��o de Favoritos
      vr_flgcfgfav INTEGER := 0;
      -- Flag Tela inicial ATM > Saque
      vr_flgatmsaq INTEGER := 0;
      -- Flag Tela inicial ATM > Transfer�ncias
      vr_flgatmtrs INTEGER := 0;
      -- Flag Tela inicial ATM > Meu Cadastro
      vr_flgatmcad INTEGER := 0;            
      -- FlagTela inicial ATM > Bot�o Pressione para visualizar seu saldo
      vr_flgatmsld INTEGER := 0; 
      -- FlagTela inicial ATM > Pagamentos
      vr_flgpagatm INTEGER := 0;
      -- PJ485 - Fim
      
      -- XML
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
      
      -- Cursor para verificar se existe a pessoa e o tipo de pessoa e conta - PJ485 - Inicio
      CURSOR cr_modalidade_tipo(pr_cdcooper IN crapass.cdcooper%type
                               ,pr_nrdconta IN crapass.nrdconta%type) IS
      
         SELECT nvl(c.cdmodalidade_tipo,0) cdmodalidade_tipo
           FROM crapass a,       
                tbcc_tipo_conta c
          WHERE c.inpessoa     = a.inpessoa
            AND c.cdtipo_conta = a.cdtipcta
            AND a.cdcooper     = pr_cdcooper
            AND a.nrdconta     = pr_nrdconta;
      rw_modalidade_tipo cr_modalidade_tipo%ROWTYPE;
	  -- PJ485 - Fim
      
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
      
      --------------------------------------------------------------------------------------
      -------------- VERIFICAR SE A RECARGA DE CELULAR EST� HABILITADA NO CANAL ------------
      --------------------------------------------------------------------------------------
      -- Inicializar a recarga de celular como desabilitada do menu
      vr_flgsitrc := 0;


      --------------------------------------------------------------------------------------
      ----------------- VERIFICAR SE O PRE-APROVADO EST� HABILITADA A CONTA ----------------
      --------------------------------------------------------------------------------------
      -- Inicializar o pr�-aprovado como desabilitado do menu
      vr_flgpreap := 0;

      --------------------------------------------------------------------------------------
      ----------------- VERIFICAR SE O DESCONTO DE TIUTLOS EST� HABILITADA NA CONTA --------
      --------------------------------------------------------------------------------------
      -- Inicializar como desabilitado do menu
      vr_flgdscti := 0;

      --------------------------------------------------------------------------------------
      ----------- VERIFICAR SE O PLANO DE PREVIDENCIA PRIVADA EST� HABILITADA NA CONTA -----
      --------------------------------------------------------------------------------------
      -- Sempre ser� habilitado
      -- No momento foi definido que sempre ficar� habilitado, 
      -- para evitar mudan�as futuras no servi�o foi adicionado o valor fixo
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
      
      /* Caso for conta sal�rio, envia apenas os menus a serem exibidos para conta sal�rio - PJ485 - Inicio
         Caso contr�rio, segue a rotina como funciona atualmente */
      BEGIN
        
        OPEN cr_modalidade_tipo(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta);
                          
        --Posicionar no proximo registro
        FETCH cr_modalidade_tipo INTO rw_modalidade_tipo;
        CLOSE cr_modalidade_tipo;
        
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
           
           -- Adicionar o Item de Menu de Conta Corrente > Consultas > Extrato na Conta Online
           GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                  ,pr_texto_completo => vr_xml_temp
                                  ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 14 -- Lista de Dominio "14 - Conta Corrente > Consultas > Extrato"
                                                                             ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                             ,pr_habilitado => vr_flgconext) ); 
                                                                              
           -- Adicionar o Item de Menu de Conta Corrente > Consultas > Lan�amentos Futuros na Conta Online
           GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                  ,pr_texto_completo => vr_xml_temp
                                  ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 15 -- Lista de Dominio "15 - Conta Corrente > Consultas > Lan�amentos Futuros"
                                                                             ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                             ,pr_habilitado => vr_flglcmfut) ); 
                                                                                                                                                      
            -- Adicionar o Item de Menu de Conta Corrente > Demais extratos > Extrato de Tarifas na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 16 -- Lista de Dominio "16 - Conta Corrente > Demais extratos > Extrato de Tarifas"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgexttar) ); 
                                                                              
            -- Adicionar o Item de Menu de Conta Corrente > Sal�rios > Comprovante Salarial na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 17 -- Lista de Dominio "17 - Conta Corrente > Sal�rios > Comprovante Salarial"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgcmpsal) ); 

            -- Adicionar o Item de Menu de CConta Corrente > Provis�o de Opera��es > Agendamento de Saque em Esp�cie na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 18 -- Lista de Dominio "18 - Conta Corrente > Provis�o de Opera��es > Agendamento de Saque em Esp�cie"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgagesaq) ); 
                                                                              
            -- Adicionar o Item de Menu de Conta Corrente > Provis�o de Opera��es > Consulta de Agendamentos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 19 -- Lista de Dominio "19 - Conta Corrente > Provis�o de Opera��es > Consulta de Agendamentos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgconage) ); 

            -- Adicionar o Item de Menu Pagamentos > Contas > �gua, Luz, Telefone e Outras na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 20 -- Lista de Dominio "20 - Pagamentos > Contas > �gua, Luz, Telefone e Outras"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgaltout) ); 
                                                                              
            -- Adicionar o Item de Menu de Pagamentos > Contas > Boletos Diversos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 21 -- Lista de Dominio "21 - Pagamentos > Contas > Boletos Diversos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgboldiv) ); 
                                                                                                                                                      
            -- Adicionar o Item de Menu de Pagamentos > Tributos > GPS - Previd�ncia Social na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 22 -- Lista de Dominio "22 - Pagamentos > Tributos > GPS - Previd�ncia Social"
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
                                                                              
            -- Adicionar o Item de Menu de APagamentos > Tributos > DAE - Simples Dom�stico/eSocial na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 26 -- Lista de Dominio "26 - Pagamentos > Tributos > DAE - Simples Dom�stico/eSocial"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgpagdae) ); 

            -- Adicionar o Item de Menu de Pagamentos > Tributos > Ve�culos (IPVA, DPVAT, Licenciamentos) na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 27 -- Lista de Dominio "27 - Pagamentos > Tributos > Ve�culos (IPVA, DPVAT, Licenciamentos)"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgveicos) ); 
                                                                                                                                                      
            -- Adicionar o Item de Menu de Pagamentos > DDA - D�bito Direto Autorizado > Pagamento de DDA na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 28 -- Lista de Dominio "28 - Pagamentos > DDA - D�bito Direto Autorizado > Pagamento de DDA"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgpagdda) ); 
                                                                              
            -- Adicionar o Item de Menu de Pagamentos > D�bito Autom�tico > Cadastrar na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 29 -- Lista de Dominio "29 - Pagamentos > D�bito Autom�tico > Cadastrar"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgcaddeb) ); 

            -- Adicionar o Item de Menu de Pagamentos > D�bito Autom�tico > Contas Cadastradas na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 30 -- Lista de Dominio "30 - Pagamentos > D�bito Autom�tico > Contas Cadastradas"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgconcad) ); 
                                                                              
            -- Adicionar o Item de Menu de Pagamentos > D�bito Autom�tico > Lan�amentos Programados na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 31 -- Lista de Dominio "31 - Pagamentos > D�bito Autom�tico > Lan�amentos Programados"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flglcnprg) ); 

            -- Adicionar o Item de Menu de Pagamentos > D�bito Autom�tico > Servi�o de SMS na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 32 -- Lista de Dominio "32 - Pagamentos > D�bito Autom�tico > Servi�o de SMS"
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
                                                                              
            -- Adicionar o Item de Menu de Pagamentos > Outros > Conv�nios Aceitos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 35 -- Lista de Dominio "35 - Pagamentos > Outros > Conv�nios Aceitos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgconace) ); 

            -- Adicionar o Item de Menu de Transfer�ncias > Entre Contas > Contas do Sistema AILOS na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 36 -- Lista de Dominio "36 - Transfer�ncias > Entre Contas > Contas do Sistema AILOS"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgconsis) ); 
                                                                              
            -- Adicionar o Item de Menu de Transfer�ncias > Entre Contas > Outras Institui��es - TED na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 37 -- Lista de Dominio "37 - Transfer�ncias > Entre Contas > Outras Institui��es - TED"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgoutted) ); 

            -- Adicionar o Item de Menu de Transfer�ncias > Favorecidos > Cadastrar na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 38 -- Lista de Dominio "38 - Transfer�ncias > Favorecidos > Cadastrar"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgfavcad) ); 
                                                                              
            -- Adicionar o Item de Menu de Transfer�ncias > Favorecidos > Gerenciar Favorecidos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 39 -- Lista de Dominio "39 - Transfer�ncias > Favorecidos > Gerenciar Favorecidos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flggerfav) ); 
                                                                                                                                                    
            -- Adicionar o Item de Menu de Transfer�ncias > Outros > Comprovantes na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 40 -- Lista de Dominio "40 - Transfer�ncias > Outros > Comprovantes"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgtrscmp) ); 
                                                                              
            -- Adicionar o Item de Menu de Transfer�ncias > Outros > Agendamentos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 41 -- Lista de Dominio "41 - Transfer�ncias > Outros > Agendamentos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgtrsage) ); 

            -- Adicionar o Item de Menu de Investimentos > Cotas Capital > Consultar na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 42 -- Lista de Dominio "Investimentos > Cotas Capital > Consultar"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgcotcon) ); 
                                                                
            -- Adicionar o Item de Menu de Conveni�ncias > Perfil > Informa��es Cadastrais na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 47 -- Lista de Dominio "47 - Conveni�ncias > Perfil > Informa��es Cadastrais"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flginfcad) ); 

            -- Adicionar o Item de Menu de Conveni�ncias > Perfil > Altera��o de Senha na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 48 -- Lista de Dominio "48 - Conveni�ncias > Perfil > Altera��o de Senha"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgaltsen) ); 
                                                                              
            -- Adicionar o Item de Menu de Conveni�ncias > Perfil > Configura��o de Favoritos na Conta Online
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 49 -- Lista de Dominio "49 - Conveni�ncias > Perfil > Configura��o de Favoritos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgcfgfav) ); 
                                                                               
            -- Adicionar o Item de Menu de Tela inicial ATM > Saque no ATM
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 50 -- Lista de Dominio "50 - Tela inicial ATM > Saque"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgatmsaq) ); 

            -- Adicionar o Item de Menu de Tela inicial ATM > Transfer�ncias no ATM
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 51 -- Lista de Dominio "51 - Tela inicial ATM > Transfer�ncias"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgatmtrs) ); 
                                                                              
            -- Adicionar o Item de Menu de Tela inicial ATM > Meu Cadastro no ATM
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 52 -- Lista de Dominio "52 - Tela inicial ATM > Meu Cadastro"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgatmcad) ); 
                                                                              
            -- Adicionar o Item de Menu de Tela inicial ATM > Bot�o Pressione para visualizar seu saldo no ATM
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 53 -- Lista de Dominio "53 - Tela inicial ATM > Bot�o Pressione para visualizar seu saldo"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgatmsld) ); 
                                                                              
            -- Adicionar o Item de Menu de Tela inicial ATM > Menu Pagamentos no ATM
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 54 -- Lista de Dominio "54 - Tela inicial ATM > Menu Pagamentos"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgpagatm) ); 
            
        ELSE
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

            -- Adicionar o Item de Menu do Plano de Previdencia Privada
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 5 -- Lista de Dominio "5 - Plano de Previdencia Privada"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgprevd) ); -- Identifica se o cooperado possui o plano de Previdencia Privada e habilita no canal

            -- Adicionar o Item de Menu do Emprestimo Consignado Online "ECO"
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => fn_adiciona_item_menu(pr_codigo     => 6 -- Lista de Dominio "6 - Empr�stimo Consignado Online"
                                                                              ,pr_canal      => pr_idorigem -- Canal de Origem da requisicao
                                                                              ,pr_habilitado => vr_flgbinss) ); -- Identifica se o cooperado possui beneficio do INSS para acessar o ECO e habilita no canal

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
                                     ,pr_des_erro          OUT VARCHAR2 --> C�digo da cr�tica
                                     ,pr_dscritic          OUT VARCHAR2) IS --> Descri��o da cr�tica
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
    
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
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
      
      -- Incluir nome do m�dulo logado
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
