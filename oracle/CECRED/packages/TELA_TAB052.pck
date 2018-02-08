CREATE OR REPLACE PACKAGE CECRED.TELA_TAB052 AS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB052 - Parâmetros para Desconto de Títulos
  --  Sistema  : Rotinas utilizadas pela Tela TAB052
  --  Sigla    : DSCT
  --  Autor    : Gustavo Guedes de Sene - Company: GFT
  --  Data     : Janeiro - 2018           Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Diario (on-line)
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TAB052
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------
  /*POSIÇÃO  CAMPO        CONTEÚDO        PARÂMETROS       COMENTÁRIO
    01       vllimite     000150000,00;   pr_vllimite      Operacional - Limite Máximo do Contrato
    02       vlconsul     000000500,00;   pr_vlconsul      Operacional - Consultar CPF/CNPJ (Pagador) Acima de
    03       vlmaxsac     000010000,00;   pr_vlmaxsac      Operacional - Valor Mínimo Permitido por Título
    04       vlminsac     000000100,00;   pr_vlminsac      Operacional - Valor Máximo Permitido por Título
    05       qtremcrt     003;            pr_qtremcrt      Operacional - Qtd. Remessa em Cartório
    06       qttitprt     001;            pr_qttitprt      Operacional - Qtd. de Títulos Protestado
    07       qtrenova     02;             pr_qtrenova      Operacional - Qtd. de Renovações
    08       qtdiavig     0120;           pr_qtdiavig      Operacional - Vigência Mínima
    09       qtprzmin     010;            pr_qtprzmin      Operacional - Prazo Mínimo
    10       qtprzmax     120;            pr_qtprzmax      Operacional - Prazo Máximo
    11       qtminfil     000;            pr_qtminfil      Operacional - Tempo Mínimo de Filiação
    12       nrmespsq     03;             pr_nrmespsq      Operacional - Nr. de Meses para Pesquisa de Pagador
    13       pctitemi     030;            pr_pctitemi      Operacional - Percentual de Títulos por Pagador
    14       pctolera     010;            pr_pctolera      Operacional - Tolerância para Limite Excedido
    15       pcdmulta     002,000000;     pr_pcdmulta      Operacional - Percentual de Multa
    16       vllimite_c   000150000,00;   pr_vllimite_c    CECRED      - Limite Máximo do Contrato
    17       vlconsul_c   000000500,00;   pr_vlconsul_c    CECRED      - Consultar CPF/CNPJ (Pagador) Acima de
    18       vlmaxsac_c   000010000,00;   pr_vlmaxsac_c    CECRED      - Valor Mínimo Permitido por Título
    19       vlminsac_c   000000100,00;   pr_vlminsac_c    CECRED      - Valor Máximo Permitido por Título
    20       qtremcrt_c   003;            pr_qtremcrt_c    CECRED      - Qtd. Remessa em Cartório
    21       qttitprt_c   001;            pr_qttitprt_c    CECRED      - Qtd. de Títulos Protestado
    22       qtrenova_c   02;             pr_qtrenova_c    CECRED      - Qtd. de Renovações
    23       qtdiavig_c   0180;           pr_qtdiavig_c    CECRED      - Vigência Mínima
    24       qtprzmin_c   010;            pr_qtprzmin_c    CECRED      - Prazo Mínimo
    25       qtprzmax_c   180;            pr_qtprzmax_c    CECRED      - Prazo Máximo
    26       qtminfil_c   000;            pr_qtminfil_c    CECRED      - Tempo Mínimo de Filiação
    27       nrmespsq_c   03;             pr_nrmespsq_c    CECRED      - Nr. de Meses para Pesquisa de Pagador
    28       pctitemi_c   030;            pr_pctitemi_c    CECRED      - Percentual de Títulos por Pagador
    29       pctolera_c   010;            pr_pctolera_c    CECRED      - Tolerância para Limite Excedido
    30       pcdmulta_c   002,000000;     pr_pcdmulta_c    CECRED      - Percentual de Multa
    31       cardbtit     005;            pr_cardbtit      Operacional - Carência Débito Título Vencido
    32       cardbtit_c   005;            pr_cardbtit_c    CECRED      - Carência Débito Título Vencido
    33       pcnaopag     040;            pr_pcnaopag      Operacional - Perc. de Títulos Não Pago Beneficiário
    34       qtnaopag     0002;           pr_qtnaopag      Operacional - Qtd. de Títulos Não Pago Pagador
    35       qtprotes     0100;           pr_qtprotes      Operacional - Qtd. de Títulos Protestados (Cooperado)
    36       pcnaopag_c   040;            pr_pcnaopag_c    CECRED      - Perc. de Títulos Não Pago Beneficiário
    37       qtnaopag_c   0002;           pr_qtnaopag_c    CECRED      - Qtd. de Títulos Não Pago Pagador
    38       qtprotes_c   0100            pr_qtprotes_c    CECRED      - Qtd. de Títulos Protestados (Cooperado)
  */
  ---------------------------------- ROTINAS --------------------------------
  PROCEDURE pc_consulta_web(
                            pr_tpcobran IN NUMBER             --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                         --  ,pr_inpessoa IN NUMBER             --> Tipo de pessoa:   1 = Fisica / 2 = Juridica
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);        --> Erros do processo



  PROCEDURE pc_alterar_tab052(
                           -- pr_inpessoa    IN NUMBER [FUTURO] Fisica / Juridica
                              pr_tpcobran    IN NUMBER --> Tipo de Cobrança: 0 = Sem Registro | 1 = Com Registro

                             ,pr_vllimite    IN NUMBER
                             ,pr_vlconsul    IN NUMBER
                             ,pr_vlmaxsac    IN NUMBER
                             ,pr_vlminsac    IN NUMBER
                             ,pr_qtremcrt    IN NUMBER
                             ,pr_qttitprt    IN NUMBER
                             ,pr_qtrenova    IN NUMBER
                             ,pr_qtdiavig    IN NUMBER
                             ,pr_qtprzmin    IN NUMBER
                             ,pr_qtprzmax    IN NUMBER
                             ,pr_qtminfil    IN NUMBER
                             ,pr_nrmespsq    IN NUMBER
                             ,pr_pctitemi    IN NUMBER
                             ,pr_pctolera    IN NUMBER
                             ,pr_pcdmulta    IN NUMBER
                             ,pr_vllimite_c  IN NUMBER
                             ,pr_vlconsul_c  IN NUMBER
                             ,pr_vlmaxsac_c  IN NUMBER
                             ,pr_vlminsac_c  IN NUMBER
                             ,pr_qtremcrt_c  IN NUMBER
                             ,pr_qttitprt_c  IN NUMBER
                             ,pr_qtrenova_c  IN NUMBER
                             ,pr_qtdiavig_c  IN NUMBER
                             ,pr_qtprzmin_c  IN NUMBER
                             ,pr_qtprzmax_c  IN NUMBER
                             ,pr_qtminfil_c  IN NUMBER
                             ,pr_nrmespsq_c  IN NUMBER
                             ,pr_pctitemi_c  IN NUMBER
                             ,pr_pctolera_c  IN NUMBER
                             ,pr_pcdmulta_c  IN NUMBER
                             ,pr_cardbtit    IN NUMBER
                             ,pr_cardbtit_c  IN NUMBER
                             ,pr_pcnaopag    IN NUMBER
                             ,pr_qtnaopag    IN NUMBER
                             ,pr_qtprotes    IN NUMBER
                             ,pr_pcnaopag_c  IN NUMBER
                             ,pr_qtnaopag_c  IN NUMBER
                             ,pr_qtprotes_c  IN NUMBER
                              --
                             ,pr_xmllog   IN VARCHAR2      --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER  --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2     --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2     --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);

  
END TELA_TAB052;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TAB052 AS
  -----------------------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB052 - Parâmetros para Desconto de Títulos
  --  Sistema  : Rotinas utilizadas pela Tela TAB052
  --  Sigla    : DSCT
  --  Autor    : Gustavo Guedes de Sene   Company: GFT
  --  Criação  : Janeiro/2018             Ultima atualizacao: 01/02/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Diario (on-line)
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TAB052
  --
  -- Histórico de Alterações: 
  --  25/01/2017 - Versão Inicial: Conversão Progress para Oracle 
  --              (Gustavo Sene - GFT)
  --  
  --  01/02/2018 - Inclusão de Parâmetro de entrada por tipo de pessoa: Física / Jurídica
  --              (Gustavo Sene - GFT)
  -----------------------------------------------------------------------------------------

  PROCEDURE pc_consulta_web(
                            pr_tpcobran IN NUMBER             --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                        -- ,pr_inpessoa IN NUMBER             --> Tipo de pessoa:   1 = Fisica / 2 = Juridica
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) AS      --> Erros do processo
    ----------------------------------------------------------------------------------
    -- Programa: pc_consulta_web
    -- Sistema : CECRED
    -- Sigla   : DSCT
    -- Autor   : Gustavo Guedes de Sene - Company: GFT
    -- Data    : Janeiro/2018             Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que for chamado
    --
    -- Objetivo  : Rotina de consulta referente à Aplicação
    --            TAB052 - Parametros para Desconto de Titulos
    --
    -- Observacao: -----
    --
    -- Alteracoes:
    ----------------------------------------------------------------------------------

      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      -- vr_cdcooper INTEGER;
      -- vr_cdoperad VARCHAR2(100);
      -- vr_nmdatela VARCHAR2(100);
      -- vr_nmeacao  VARCHAR2(100);
      -- vr_cdagenci VARCHAR2(100);
      -- vr_nrdcaixa VARCHAR2(100);
      -- vr_idorigem VARCHAR2(100);

      vr_cdcooper crapcop.cdcooper%TYPE; --> Código da Cooperativa
      vr_cdagenci crapage.cdagenci%TYPE; --> Código da agencia
      vr_nrdcaixa crapbcx.nrdcaixa%TYPE; --> Numero do caixa do operador
      vr_cdoperad crapope.cdoperad%TYPE; --> Código do Operador
      vr_dtmvtolt crapdat.dtmvtolt%TYPE; --> data do movimento 
      vr_idorigem INTEGER;               --> Identificador de Origem
      vr_nmdatela VARCHAR2(100);         --> Nome da tela
      vr_nmeacao  VARCHAR2(100);         --> Ação (Consultar / Alterar)

      vr_tab_dados_dsctit  dsct0002.typ_tab_dados_dsctit;
      vr_tab_cecred_dsctit dsct0002.typ_tab_cecred_dsctit;

      ---------->> CURSORES <<--------
      --> Buscar dados operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT dpo.dsdepart
          FROM crapope ope
              ,crapdpo dpo
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.cdoperad = pr_cdoperad
           AND dpo.cddepart = ope.cddepart
           AND dpo.cdcooper = ope.cdcooper;
      rw_crapope cr_crapope%ROWTYPE;

    BEGIN

      pr_des_erro := 'OK';
      -- Extrai dados do xml
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

-- GGS
--Raise_Application_Error (-20001, 'antes DSCT0002.pc_busca_parametros_dsctit');

      --> Buscar parametros gerais de desconto de titulo - TAB052
      DSCT0002.pc_busca_parametros_dsctit
                              (  pr_cdcooper => vr_cdcooper   --> Código da Cooperativa
                                ,pr_cdagenci => vr_cdagenci   --> Código da agencia
                                ,pr_nrdcaixa => vr_nrdcaixa   --> Numero do caixa do operador
                                ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                                ,pr_dtmvtolt => vr_dtmvtolt   --> data do movimento
                                ,pr_idorigem => vr_idorigem   --> Identificador de Origem
                                ,pr_tpcobran => pr_tpcobran   --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                             -- ,pr_inpessoa => pr_inpessoa   --> Tipo de Pessoa:   0 = Todos / 1 = Física / 2 = Jurídica
                                ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> tabela contendo os parametros da cooperativa
                                ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                ,pr_dscritic => vr_dscritic   --> Descrição da crítica
                              );  

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL OR
        nvl(vr_cdcritic,0) > 0 THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      --> Buscar dados do operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper,
                      pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;

      -- Se nao encontrar
      IF cr_crapope%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapope;

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Operador não encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;

      -- Fechar o cursor
      CLOSE cr_crapope;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

  
    ------------------ vllimite

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vllimite',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).vllimite, 
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
-- GGS
-- RAISE_APPLICATION_ERROR(-20001, 'Sucesso: '|| PR_TPCOBRAN ||'-'|| VR_TAB_DADOS_DSCTIT(1).VLLIMITE);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vllimite_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).vllimite,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                                    
                             pr_des_erro => vr_dscritic);

    ------------------ vlconsul   
            
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlconsul',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).vlconsul, 
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlconsul_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).vlconsul,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                                    
                             pr_des_erro => vr_dscritic);
          
    ------------------ vlminsac

    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlminsac',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).vlminsac, 
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlminsac_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).vlminsac,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                                    
                             pr_des_erro => vr_dscritic);
               
    ------------------ vlmaxsac  

    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmaxsac',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).vlmaxsac, 
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmaxsac_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).vlmaxsac,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                                    
                             pr_des_erro => vr_dscritic);    

    ------------------ qtremcrt 

    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtremcrt',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).qtremcrt),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtremcrt_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).qtremcrt),                                                    
                             pr_des_erro => vr_dscritic);                 

    ------------------ qttitprt 

    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qttitprt',
                             pr_tag_cont => vr_tab_dados_dsctit(pr_tpcobran).qttitprt,                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qttitprt_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).qttitprt),                                                    
                             pr_des_erro => vr_dscritic);      
    
    
    ------------------ qtrenova 

    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtrenova',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).qtrenova),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtrenova_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).qtrenova),                                                    
                             pr_des_erro => vr_dscritic);
      
    ------------------ qtdiavig 

    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiavig',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).qtdiavig),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiavig_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).qtdiavig),                                                    
                             pr_des_erro => vr_dscritic);  
          
    ------------------ qtprzmin 
    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmin',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).qtprzmin),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmin_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).qtprzmin),                                                    
                             pr_des_erro => vr_dscritic);  
          
    ------------------ qtprzmax 
    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmax',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).qtprzmax),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmax_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).qtprzmax),                                                    
                             pr_des_erro => vr_dscritic);  
          
    ------------------ cardbtit                    
      
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'cardbtit',
                             pr_tag_cont => to_char(0), -- to_char(vr_tab_dados_dsctit(pr_tpcobran).cardbtit),                                                  
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'cardbtit_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).cardbtit),                                                    
                             pr_des_erro => vr_dscritic);  
          
    ------------------ qtminfil                
      
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtminfil',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).qtminfil),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtminfil_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).qtminfil),                                                    
                             pr_des_erro => vr_dscritic);	
				  
		------------------ nrmespsq
		
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nrmespsq',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).nrmespsq),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nrmespsq_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).nrmespsq),                                                    
                             pr_des_erro => vr_dscritic);	
				  
		------------------ pctitemi	
		
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctitemi',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).pctitemi),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctitemi_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).pctitemi),                                                    
                             pr_des_erro => vr_dscritic);	
				  
		------------------ pctolera	
		
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctolera',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).pctolera),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctolera_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).pctolera),                                                    
                             pr_des_erro => vr_dscritic);	
				  
		------------------ pcdmulta	
		
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcdmulta',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).pcdmulta),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcdmulta_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).pcdmulta),                                                    
                             pr_des_erro => vr_dscritic);	
				  
		------------------ pcnaopag	
							 
		
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcnaopag',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).pcnaopag),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcnaopag_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).pcnaopag),                                                    
                             pr_des_erro => vr_dscritic);	
				  
		------------------ qtnaopag								 
		
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtnaopag',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).qtnaopag),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtnaopag_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).qtnaopag),                                                    
                             pr_des_erro => vr_dscritic);	
				  
		------------------ qtprotes							 
			
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprotes',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(pr_tpcobran).qtprotes),                                                    
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprotes_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(pr_tpcobran).qtprotes),                                                    
                             pr_des_erro => vr_dscritic);	
				  
		------------------						 


  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consulta_web;

-----------------------------------------------------------------------------------------
-- Procedure de Alteração
-----------------------------------------------------------------------------------------
  PROCEDURE pc_alterar_tab052(
                              pr_tpcobran IN NUMBER    --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                          -- ,pr_inpessoa IN NUMBER    --> Tipo de Pessoa:   0 = Todos / 1 = Física / 2 = Jurídica
                             ,pr_vllimite    IN NUMBER
                             ,pr_vlconsul    IN NUMBER
                             ,pr_vlmaxsac    IN NUMBER
                             ,pr_vlminsac    IN NUMBER
                             ,pr_qtremcrt    IN NUMBER
                             ,pr_qttitprt    IN NUMBER
                             ,pr_qtrenova    IN NUMBER
                             ,pr_qtdiavig    IN NUMBER
                             ,pr_qtprzmin    IN NUMBER
                             ,pr_qtprzmax    IN NUMBER
                             ,pr_qtminfil    IN NUMBER
                             ,pr_nrmespsq    IN NUMBER
                             ,pr_pctitemi    IN NUMBER
                             ,pr_pctolera    IN NUMBER
                             ,pr_pcdmulta    IN NUMBER
                             ,pr_vllimite_c  IN NUMBER
                             ,pr_vlconsul_c  IN NUMBER
                             ,pr_vlmaxsac_c  IN NUMBER
                             ,pr_vlminsac_c  IN NUMBER
                             ,pr_qtremcrt_c  IN NUMBER
                             ,pr_qttitprt_c  IN NUMBER
                             ,pr_qtrenova_c  IN NUMBER
                             ,pr_qtdiavig_c  IN NUMBER
                             ,pr_qtprzmin_c  IN NUMBER
                             ,pr_qtprzmax_c  IN NUMBER
                             ,pr_qtminfil_c  IN NUMBER
                             ,pr_nrmespsq_c  IN NUMBER
                             ,pr_pctitemi_c  IN NUMBER
                             ,pr_pctolera_c  IN NUMBER
                             ,pr_pcdmulta_c  IN NUMBER
                             ,pr_cardbtit    IN NUMBER
                             ,pr_cardbtit_c  IN NUMBER
                             ,pr_pcnaopag    IN NUMBER
                             ,pr_qtnaopag    IN NUMBER
                             ,pr_qtprotes    IN NUMBER
                             ,pr_pcnaopag_c  IN NUMBER
                             ,pr_qtnaopag_c  IN NUMBER
                             ,pr_qtprotes_c  IN NUMBER
                              --
                             ,pr_xmllog   IN VARCHAR2      --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER  --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2     --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2     --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) AS --> Erros do processo
  /* .............................................................................

    Programa: pc_alterar_tab052
    Sistema : CECRED
    Sigla   : DSCT
    Autor   : Gustavo Guedes de Sene - Company: GFT
    Data    : Janeiro/2018             Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina de alteração referente à Aplicação
                TAB052 - Parametros para Desconto de Titulos

    Observacao: -----

    Alteracoes:
  ..............................................................................*/


    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdacesso VARCHAR2(100);
    vr_dsccampo VARCHAR2(1000);

    vr_cdcooper crapcop.cdcooper%TYPE; --> Código da Cooperativa
    vr_cdagenci crapage.cdagenci%TYPE; --> Código da agencia
    vr_nrdcaixa crapbcx.nrdcaixa%TYPE; --> Numero do caixa do operador
    vr_cdoperad crapope.cdoperad%TYPE; --> Código do Operador
    vr_dtmvtolt crapdat.dtmvtolt%TYPE; --> data do movimento
    vr_idorigem INTEGER;               --> Identificador de Origem
    vr_nmdatela VARCHAR2(100);         --> Nome da tela
    vr_nmeacao  VARCHAR2(100);         --> Ação (Consultar / Alterar)

    vr_tab_dados_dsctit  dsct0002.typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit dsct0002.typ_tab_cecred_dsctit;

    vr_horalimt NUMBER;
    vr_horalim2 NUMBER;

    vr_dstextab VARCHAR2(2000);

    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
      SELECT dpo.dsdepart
        FROM crapope ope
            ,crapdpo dpo
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad
         AND dpo.cddepart = ope.cddepart
         AND dpo.cdcooper = ope.cdcooper;
    rw_crapope cr_crapope%ROWTYPE;


    --------------->>> SUB-ROTINA <<<---------------
    --> Gerar Log da Tela
    PROCEDURE pc_log_tab052(pr_cdcooper IN crapcop.cdcooper%TYPE,
                            pr_cdoperad IN crapope.cdoperad%TYPE,
                            pr_dscdolog IN VARCHAR2) IS
      vr_dscdolog VARCHAR2(500);
    BEGIN

      vr_dscdolog := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||' '|| to_char(SYSDATE,'HH24:MI:SS') ||
                     ' --> '|| vr_cdacesso || ' --> '|| 'Operador '|| pr_cdoperad ||
                     ' '||pr_dscdolog;

      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log  => vr_dscdolog,
                                 pr_nmarqlog => 'tab052',
                                 pr_flfinmsg => 'N');
    END;

    --Retornar descrição do indicador
    FUNCTION fn_retdsind (pr_indicador IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
      IF pr_indicador = 1 THEN
        RETURN 'Sim';
      ELSIF pr_indicador = 0 THEN
        RETURN 'Nao';
      END IF;

      RETURN NULL;

    END;

  BEGIN

    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;

    IF pr_tpcobran = 1 THEN
      vr_cdacesso := 'LIMDESCTITCR';
    ELSE
      vr_cdacesso := 'LIMDESCTIT';
    END IF;

    DSCT0002.pc_busca_parametros_dsctit
                            (  pr_cdcooper => vr_cdcooper   --> Código da Cooperativa
                              ,pr_cdagenci => vr_cdagenci   --> Código da agencia
                              ,pr_nrdcaixa => vr_nrdcaixa   --> Numero do caixa do operador
                              ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                              ,pr_dtmvtolt => vr_dtmvtolt   --> data do movimento
                              ,pr_idorigem => vr_idorigem   --> Identificador de Origem
                              ,pr_tpcobran => pr_tpcobran   --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                          --  ,pr_inpessoa => pr_inpessoa   --> Tipo de Pessoa:   0 = Todos / 1 = Física / 2 = Jurídica                              
                              ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> tabela contendo os parametros da cooperativa
                              ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                              ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                              ,pr_dscritic => vr_dscritic   --> Descrição da crítica
                            );


    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL OR
      nvl(vr_cdcritic,0) > 0 THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;


    OPEN cr_crapope(pr_cdcooper => vr_cdcooper, pr_cdoperad => vr_cdoperad);
    FETCH cr_crapope
      INTO rw_crapope;

    -- Se nao encontrar
    IF cr_crapope%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapope;

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao localizar operador!';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    -- Fechar o cursor
    CLOSE cr_crapope;


    IF pr_qtprzmin > pr_qtprzmax OR
       pr_qtprzmax > 360 THEN
      -- Montar mensagem de critica
      vr_cdcritic := 26;
      vr_dscritic := '';
      pr_nmdcampo := 'qtprzmin';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF pr_vllimite > pr_vllimite_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor do Limite Máximo do Contrato deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'vllimite';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF pr_vlmaxsac > pr_vlmaxsac_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O Valor Máximo Permitido por Título deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'vlmaxsac';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF pr_qtprzmax > pr_qtprzmax_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qtprzmax';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF to_number(pr_cardbtit) > 5 THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'A quantidade de dias de carencia de debito de titulo deve ser menor ou igual a 5';
      pr_nmdcampo := 'cardbtit';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF to_number(pr_pctolera) > to_number(pr_pctolera_c) THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'pctolera';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF pr_pcdmulta > 2 THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Valor nao deve ser superior a 2% (Exigencia Legal)';
      pr_nmdcampo := 'txdmulta';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;


    ---- VALIDAÇÕES CECRED ----
    IF pr_vllimite > pr_vllimite_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor não pode ser menor que o da cooperativa';
      pr_nmdcampo := 'vllimite_c';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF pr_vlmaxsac > pr_vlmaxsac_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor não pode ser menor que o da cooperativa';
      pr_nmdcampo := 'vlmaxsac_c';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF pr_qtprzmax > pr_qtprzmax_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor não pode ser menor que o da cooperativa';
      pr_nmdcampo := 'qtprzmax_c';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF to_number(pr_cardbtit) > 5 THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'A quantidade de dias de carencia de debito de titulo deve ser menor ou igual a 5';
      pr_nmdcampo := 'cardbtit_c';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF to_number(pr_pctolera) > to_number(pr_pctolera_c) THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor não pode ser menor que o da cooperativa.';
      pr_nmdcampo := 'pctolera_c';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;



    vr_dstextab := to_char(pr_vllimite,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlconsul,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlmaxsac,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlminsac,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_qtremcrt,   'FM000')                                           ||';'||
                   to_char(pr_qttitprt,   'FM000')                                           ||';'||
                   to_char(pr_qtrenova,   'FM00')                                            ||';'||
                   to_char(pr_qtdiavig,   'FM0000')                                          ||';'||
                   to_char(pr_qtprzmin,   'FM000')                                           ||';'||
                   to_char(pr_qtprzmax,   'FM000')                                           ||';'||
                   to_char(pr_qtminfil,   'FM000')                                           ||';'||
                   to_char(pr_nrmespsq,   'FM00')                                            ||';'||
                   to_char(pr_pctitemi,   'FM000')                                           ||';'||
                   to_char(pr_pctolera,   'FM000')                                           ||';'||
                   to_char(pr_pcdmulta,   'FM000D000000', 'NLS_NUMERIC_CHARACTERS='',.''')   ||';'||
                   to_char(pr_vllimite_c, 'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlconsul_c, 'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlmaxsac_c, 'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlminsac_c, 'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_qtremcrt_c, 'FM000')                                           ||';'||
                   to_char(pr_qttitprt_c, 'FM000')                                           ||';'||
                   to_char(pr_qtrenova_c, 'FM00')                                            ||';'||
                   to_char(pr_qtdiavig_c, 'FM0000')                                          ||';'||
                   to_char(pr_qtprzmin_c, 'FM000')                                           ||';'||
                   to_char(pr_qtprzmax_c, 'FM000')                                           ||';'||
                   to_char(pr_qtminfil_c, 'FM000')                                           ||';'||
                   to_char(pr_nrmespsq_c, 'FM00')                                            ||';'||
                   to_char(pr_pctitemi_c, 'FM000')                                           ||';'||
                   to_char(pr_pctolera_c, 'FM000')                                           ||';'||
                   to_char(pr_pcdmulta_c, 'FM000D000000', 'NLS_NUMERIC_CHARACTERS='',.''')   ||';'||
                   to_char(pr_cardbtit,   'FM000')                                           ||';'||
                   to_char(pr_cardbtit_c, 'FM000')                                           ||';'||
                   to_char(pr_pcnaopag,   'FM000')                                           ||';'||
                   to_char(pr_qtnaopag,   'FM0000')                                          ||';'||
                   to_char(pr_qtprotes,   'FM0000')                                          ||';'||
                   to_char(pr_pcnaopag_c, 'FM000')                                           ||';'||
                   to_char(pr_qtnaopag_c, 'FM0000')                                          ||';'||
                   to_char(pr_qtprotes_c, 'FM0000');

    BEGIN
      UPDATE craptab tab
         SET tab.dstextab = vr_dstextab
       WHERE tab.cdcooper = vr_cdcooper
         AND upper(tab.nmsistem) = 'CRED'
         AND upper(tab.tptabela) = 'USUARI'
         AND tab.cdempres = 11
         AND upper(tab.cdacesso) = upper(vr_cdacesso)
         AND tab.tpregist = 0;
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar Linha de Desconto!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;

    END;


----> ok 
    IF vr_tab_dados_dsctit(pr_tpcobran).vllimite <> pr_vllimite THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o limite maximo do contrato de R$ ' ||
                                    to_char(vr_tab_dados_dsctit(pr_tpcobran).vllimite,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vllimite,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> ok 
    IF vr_tab_cecred_dsctit(pr_tpcobran).vllimite <> pr_vllimite_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o limite maximo do contrato CECRED de R$ ' ||
                                    to_char(vr_tab_cecred_dsctit(pr_tpcobran).vllimite,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vllimite_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;

----> ok
    IF vr_tab_dados_dsctit(pr_tpcobran).qtdiavig <> pr_qtdiavig THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias da vigencia minima de ' ||
                                    to_char(vr_tab_dados_dsctit(pr_tpcobran).qtdiavig) ||
                                    ' para ' || to_char(pr_qtdiavig));

    END IF;

----> ok
    IF vr_tab_cecred_dsctit(pr_tpcobran).qtdiavig <> pr_qtdiavig_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias da vigencia minima de ' ||
                                    to_char(vr_tab_cecred_dsctit(pr_tpcobran).qtdiavig) ||
                                    ' para ' || to_char(pr_qtdiavig_c));

    END IF;

----> ok
    IF vr_tab_dados_dsctit(pr_tpcobran).qtprzmin <> pr_qtprzmin THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias de prazo minimo do cheque de ' ||
                                    to_char(vr_tab_dados_dsctit(pr_tpcobran).qtprzmin) ||
                                    ' para ' || to_char(pr_qtprzmin));

    END IF;

----> ok
    IF vr_tab_dados_dsctit(pr_tpcobran).qtprzmax <> pr_qtprzmax THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias de prazo maximo do cheque de ' ||
                                    to_char(vr_tab_dados_dsctit(pr_tpcobran).qtprzmax) ||
                                    ' para ' || to_char(pr_qtprzmax));
    END IF;

----> ok
    IF vr_tab_cecred_dsctit(pr_tpcobran).qtprzmax <> pr_qtprzmax_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias de prazo maximo do titulo CECRED de ' ||
                                    to_char(vr_tab_cecred_dsctit(pr_tpcobran).qtprzmax) ||
                                    ' para ' || to_char(pr_qtprzmax_c));

    END IF;

----> ok
    IF vr_tab_dados_dsctit(pr_tpcobran).pcdmulta <> pr_pcdmulta THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o percentual de multa sobre devolucao de ' ||
                                    to_char(vr_tab_dados_dsctit(pr_tpcobran).pcdmulta) ||
                                    ' para ' || to_char(pr_pcdmulta));

    END IF;

----> ok
    IF vr_tab_dados_dsctit(pr_tpcobran).vlconsul <> pr_vlconsul THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor do titulo a ser consultado de R$ ' ||
                                    to_char(vr_tab_dados_dsctit(pr_tpcobran).vlconsul,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vlconsul,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> ok
    IF vr_tab_dados_dsctit(pr_tpcobran).vlmaxsac <> pr_vlmaxsac THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor maximo permitido por emitente de R$ ' ||
                                    to_char(vr_tab_dados_dsctit(pr_tpcobran).vlmaxsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vlmaxsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> ok
    IF vr_tab_cecred_dsctit(pr_tpcobran).vlmaxsac <> pr_vlmaxsac_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor maximo permitido por emitente CECRED de R$ ' ||
                                    to_char(vr_tab_cecred_dsctit(pr_tpcobran).vlmaxsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vlmaxsac_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> ok
    IF vr_tab_dados_dsctit(pr_tpcobran).vlminsac <> pr_vlminsac THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor maximo permitido por emitente de R$ ' ||
                                    to_char(vr_tab_dados_dsctit(pr_tpcobran).vlminsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vlminsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> ok
    IF vr_tab_cecred_dsctit(pr_tpcobran).vlminsac <> pr_vlminsac_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor maximo permitido por emitente CECRED de R$ ' ||
                                    to_char(vr_tab_cecred_dsctit(pr_tpcobran).vlminsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vlminsac_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> ok
    IF vr_tab_dados_dsctit(pr_tpcobran).qtrenova <> pr_qtrenova THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou Qtd. de Renovacoes de ' ||
                                    to_char(vr_tab_dados_dsctit(pr_tpcobran).qtrenova,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_qtrenova,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> ok
    IF vr_tab_cecred_dsctit(pr_tpcobran).qtrenova <> pr_qtrenova_c THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou Qtd. de Renovacoes CECRED de ' ||
                                    to_char(vr_tab_cecred_dsctit(pr_tpcobran).qtrenova,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_qtrenova_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> ok
    IF vr_tab_dados_dsctit(pr_tpcobran).pctitemi <> pr_pctitemi THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o percentual de cheques por emitente de ' ||
                                    to_char(vr_tab_dados_dsctit(pr_tpcobran).pctitemi) ||
                                    ' para ' || to_char(pr_pctitemi));
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_alterar_tab052;

END TELA_TAB052;
/
