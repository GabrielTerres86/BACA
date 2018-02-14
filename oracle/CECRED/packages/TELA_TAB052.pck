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

  ------------------------- ESTRUTURAS DE REGISTRO --------------------------
  --
  --  POSIÇÃO  CAMPO        CONTEÚDO        PARÂMETROS       COMENTÁRIO
  --  -------  -----        --------        ----------       ----------
  --  01       vllimite     000150000,00;   pr_vllimite      Operacional - Limite Máximo do Contrato
  --  02       vlconsul     000000500,00;   pr_vlconsul      Operacional - Consultar CPF/CNPJ (Pagador) Acima de
  --  03    ** vlmaxsac     000010000,00;   pr_vlmaxsac      Operacional - Valor Máximo Permitido por Título [EXCLUÍDO]
  --  04       vlminsac     000000100,00;   pr_vlminsac      Operacional - Valor Mínimo Permitido por Título
  --  05       qtremcrt     003;            pr_qtremcrt      Operacional - Qtd. Remessa em Cartório
  --  06       qttitprt     001;            pr_qttitprt      Operacional - Qtd. de Títulos Protestado
  --  07    ** qtrenova     02;             pr_qtrenova      Operacional - Qtd. de Renovações [EXCLUÍDO]
  --  08       qtdiavig     0120;           pr_qtdiavig      Operacional - Vigência Mínima
  --  09       qtprzmin     010;            pr_qtprzmin      Operacional - Prazo Mínimo
  --  10       qtprzmax     120;            pr_qtprzmax      Operacional - Prazo Máximo
  --  11       qtminfil     000;            pr_qtminfil      Operacional - Tempo Mínimo de Filiação
  --  12       nrmespsq     03;             pr_nrmespsq      Operacional - Nr. de Meses para Pesquisa de Pagador
  --  13       pctitemi     030;            pr_pctitemi      Operacional - Percentual de Títulos por Pagador
  --  14       pctolera     010;            pr_pctolera      Operacional - Tolerância para Limite Excedido
  --  15       pcdmulta     002,000000;     pr_pcdmulta      Operacional - Percentual de Multa
  --  16       vllimite_c   000150000,00;   pr_vllimite_c    CECRED      - Limite Máximo do Contrato
  --  17       vlconsul_c   000000500,00;   pr_vlconsul_c    CECRED      - Consultar CPF/CNPJ (Pagador) Acima de
  --  18    ** vlmaxsac_c   000010000,00;   pr_vlmaxsac_c    CECRED      - Valor Máximo Permitido por Título [EXCLUÍDO]
  --  19       vlminsac_c   000000100,00;   pr_vlminsac_c    CECRED      - Valor Mínimo Permitido por Título
  --  20       qtremcrt_c   003;            pr_qtremcrt_c    CECRED      - Qtd. Remessa em Cartório
  --  21       qttitprt_c   001;            pr_qttitprt_c    CECRED      - Qtd. de Títulos Protestado
  --  22    ** qtrenova_c   02;             pr_qtrenova_c    CECRED      - Qtd. de Renovações
  --  23       qtdiavig_c   0180;           pr_qtdiavig_c    CECRED      - Vigência Mínima
  --  24       qtprzmin_c   010;            pr_qtprzmin_c    CECRED      - Prazo Mínimo
  --  25       qtprzmax_c   180;            pr_qtprzmax_c    CECRED      - Prazo Máximo
  --  26       qtminfil_c   000;            pr_qtminfil_c    CECRED      - Tempo Mínimo de Filiação
  --  27       nrmespsq_c   03;             pr_nrmespsq_c    CECRED      - Nr. de Meses para Pesquisa de Pagador
  --  28       pctitemi_c   030;            pr_pctitemi_c    CECRED      - Percentual de Títulos por Pagador
  --  29       pctolera_c   010;            pr_pctolera_c    CECRED      - Tolerância para Limite Excedido
  --  30       pcdmulta_c   002,000000;     pr_pcdmulta_c    CECRED      - Percentual de Multa
  --  31       cardbtit     005;            pr_cardbtit      Operacional - Carência Débito Título Vencido
  --  32       cardbtit_c   005;            pr_cardbtit_c    CECRED      - Carência Débito Título Vencido
  --  33       pcnaopag     040;            pr_pcnaopag      Operacional - Perc. de Títulos Não Pago Beneficiário
  --  34       qtnaopag     0002;           pr_qtnaopag      Operacional - Qtd. de Títulos Não Pago Pagador
  --  35       qtprotes     0100;           pr_qtprotes      Operacional - Qtd. de Títulos Protestados (Cooperado)
  --  36       pcnaopag_c   040;            pr_pcnaopag_c    CECRED      - Perc. de Títulos Não Pago Beneficiário
  --  37       qtnaopag_c   0002;           pr_qtnaopag_c    CECRED      - Qtd. de Títulos Não Pago Pagador
  --  38       qtprotes_c   0100;           pr_qtprotes_c    CECRED      - Qtd. de Títulos Protestados (Cooperado)
  --
  --  39	     vlmxassi 		000000100,00;   pr_vlmxassi      Operacional - Valor Máximo Dispensa Assinatura
  --  40	     flemipar     0;              pr_flemipar      Operacional - Verificar Relacionamento Emitente (Cônjuge/Sócio)
  --  41	     flpjzemi     0;              pr_flpjzemi      Operacional - Verificar Cooperado Possui Prejuizo na Cooperativa
  --  42	     flpdctcp     0;              pr_flpdctcp      Operacional - Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
  --  43	     qttliqcp     001;            pr_qttliqcp      Operacional - Minimo de Liquidez do Cedente x Pagador (Qtd. de Titulos)
  --  44	     vltliqcp     001;            pr_vltliqcp      Operacional - Minimo de Liquidez do Cedente x Pagador (Valor dos Titulos)
  --  45	     qtmintgc     001;            pr_qtmintgc      Operacional - Minimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos)
  --  46	     vlmintgc     001;            pr_vlmintgc      Operacional - Minimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos)
  --  47	     qtmesliq     010;            pr_qtmesliq      Operacional - Período em meses para realizar o cálculo de liquidez
  --  48	     vlmxprat     0;              pr_vlmxprat      Operacional - Valor máximo permitido por ramo de atividade
  --  49	     pcmxctip     010;            pr_pcmxctip      Operacional - Concentração máxima de títulos por pagador
  --  50	  ** flcocpfp     0;              pr_flcocpfp      Operacional - Consulta de CPF/CNPJ pagador
  --  51	     qtmxdene     010;            pr_qtmxdene      Operacional - Quantidade máxima de dias para envio para Esteira
  --  52       qtdiexbo     010;            pr_qtdiexbo      Operacional - Dias para expirar borderô
  --  53       qtmxtbib     010;            pr_qtmxtbib      Operacional - Quantidade máxima de títulos por borderô IB
  --  54       qtmxtbay     010;            pr_qtmxtbay      Operacional - Quantidade máxima de títulos por borderô Ayllos
  --
  --  55       vlmxassi_c   000000100,00;   pr_vlmxassi_c    CECRED      - Valor Máximo Dispensa Assinatura
  --  56       flemipar_c   0;              pr_flemipar_c    CECRED      - Verificar Relacionamento Emitente (Cônjuge/Sócio)
  --  57       flpjzemi_c   0;              pr_flpjzemi_c    CECRED      - Verificar Cooperado Possui Prejuizo na Cooperativa
  --  58       flpdctcp_c   0;              pr_flpdctcp_c    CECRED      - Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
  --  59       qttliqcp_c   001;            pr_qttliqcp_c    CECRED      - Minimo de Liquidez do Cedente x Pagador (Qtd. de Titulos)
  --  60       vltliqcp_c   001;            pr_vltliqcp_c    CECRED      - Minimo de Liquidez do Cedente x Pagador (Valor dos Titulos)
  --  61       qtmintgc_c   001;            pr_qtmintgc_c    CECRED      - Minimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos)
  --  62       vlmintgc_c   001;            pr_vlmintgc_c    CECRED      - Minimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos)
  --  63	     qtmesliq_c   010;            pr_qtmesliq_c    CECRED      - Período em meses para realizar o cálculo de liquidez
  --  64	     vlmxprat_c   0;              pr_vlmxprat_c    CECRED      - Valor máximo permitido por ramo de atividade
  --  65	     pcmxctip_c   010;            pr_pcmxctip_c    CECRED      - Concentração máxima de títulos por pagador
  --  66	  ** flcocpfp_c   0;              pr_flcocpfp_c    CECRED      - Consulta de CPF/CNPJ pagador
  --  67	     qtmxdene_c   010;            pr_qtmxdene_c    CECRED      - Quantidade máxima de dias para envio para Esteira
  --  68	     qtdiexbo_c   010;            pr_qtdiexbo_c    CECRED      - Dias para expirar borderô
  --  69	     qtmxtbib_c   010;            pr_qtmxtbib_c    CECRED      - Quantidade máxima de títulos por borderô IB
  --  70	     qtmxtbay_c   010;            pr_qtmxtbay_c    CECRED      - Quantidade máxima de títulos por borderô Ayllos
  --
  --  71	     qtmitdcl     010;            pr_qtmitdcl      Operacional - Quantidade mínima de títulos descontados para cálculo da liquidez
  --  72	     vlmintcl     000000100,00;   pr_vlmintcl      Operacional - Valor mínimo para cálculo liquidez
  --  73	     pctitpag     010;            pr_pctitpag      Operacional - Percentual de títulos por pagador
  --
  --  74	     qtmitdcl_c   010;            pr_qtmitdcl_c    CECRED      - Quantidade mínima de títulos descontados para cálculo da liquidez
  --  75	     vlmintcl_c   000000100,00;   pr_vlmintcl_c    CECRED      - Valor mínimo para cálculo liquidez
  --  76	     pctitpag_c   010;            pr_qtmxtbay_c    CECRED      - Percentual de títulos por pagador
  --
  ---------------------------------------------------------------------------

  ---------------------------------- ROTINAS --------------------------------
  PROCEDURE pc_consulta_web(
                            pr_tpcobran IN NUMBER             --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                           ,pr_inpessoa IN NUMBER             --> Tipo de pessoa:   1 = Fisica / 2 = Juridica
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);        --> Erros do processo



  PROCEDURE pc_alterar_tab052(
                              pr_tpcobran    IN NUMBER --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                             ,pr_inpessoa    IN NUMBER --> Tipo de pessoa:   1 = Fisica / 2 = Juridica
                             ,pr_vllimite    IN NUMBER
                             ,pr_vlconsul    IN NUMBER
                             ,pr_vlmaxsac    IN NUMBER --> Excluir (DEFAULT 0 ?)
                             ,pr_vlminsac    IN NUMBER
                             ,pr_qtremcrt    IN NUMBER
                             ,pr_qttitprt    IN NUMBER
                             ,pr_qtrenova    IN NUMBER --> Excluir (DEFAULT 0 ?)
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
                             ,pr_vlmaxsac_c  IN NUMBER --> Excluir (DEFAULT 0 ?)
                             ,pr_vlminsac_c  IN NUMBER
                             ,pr_qtremcrt_c  IN NUMBER
                             ,pr_qttitprt_c  IN NUMBER
                             ,pr_qtrenova_c  IN NUMBER --> Excluir (DEFAULT 0 ?)
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
                              ---- NOVOS CAMPOS ----
                             ,pr_vlmxassi    IN NUMBER    -- Valor Máximo Dispensa Assinatura
                             ,pr_flemipar    IN NUMBER    -- Verificar se Emitente é Cônjugue do Cooperado (no caso de Pessoa Física) / Verificar se Emitente é Sócio do Cooperado (no caso de Pessoa Jurídica)
                             ,pr_flpjzemi    IN NUMBER    -- Verificar Prejuízo do Emitente
                             ,pr_flpdctcp    IN NUMBER    -- Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
                             ,pr_qttliqcp    IN NUMBER    -- Mínimo de Liquidez do Cedente x Pagador (Qtd. de Titulos)
                             ,pr_vltliqcp    IN NUMBER    -- Mínimo de Liquidez do Cedente x Pagador (Valor dos Titulos)
                             ,pr_qtmintgc    IN NUMBER    -- Mínimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos)
                             ,pr_vlmintgc    IN NUMBER    -- Mínimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos)
                             ,pr_qtmesliq    IN NUMBER    -- Qtd. Meses Cálculo Percentual de Liquidez
                             ,pr_vlmxprat    IN NUMBER    -- Valor máximo permitido por ramo de atividade
                             ,pr_pcmxctip    IN NUMBER    -- Concentração máxima de títulos por pagador
                             ,pr_flcocpfp    IN NUMBER    -- Consulta de CPF/CNPJ do pagador                 --> Excluir (DEFAULT 0 ?)
                             ,pr_qtmxdene    IN NUMBER    -- Quantidade máxima de dias para envio para Esteira
                             ,pr_qtdiexbo    IN NUMBER    -- Dias para expirar borderô                       --> Excluir (DEFAULT 0 ?)
                             ,pr_qtmxtbib    IN NUMBER    -- Quantidade máxima de títulos por borderô IB     --> Excluir (DEFAULT 0 ?)
                             ,pr_qtmxtbay    IN NUMBER    -- Quantidade máxima de títulos por borderô Ayllos --> Excluir (DEFAULT 0 ?)
                              ----------------------
                             ,pr_vlmxassi_c  IN NUMBER    -- Valor Máximo Dispensa Assinatura
                             ,pr_flemipar_c  IN NUMBER    -- Verificar se Emitente é Cônjugue do Cooperado (no caso de Pessoa Física) / Verificar se Emitente é Sócio do Cooperado (no caso de Pessoa Jurídica)
                             ,pr_flpjzemi_c  IN NUMBER    -- Verificar Prejuízo do Emitente
                             ,pr_flpdctcp_c  IN NUMBER    -- Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
                             ,pr_qttliqcp_c  IN NUMBER    -- Mínimo de Liquidez do Cedente x Pagador (Qtd. de Titulos)
                             ,pr_vltliqcp_c  IN NUMBER    -- Mínimo de Liquidez do Cedente x Pagador (Valor dos Titulos)
                             ,pr_qtmintgc_c  IN NUMBER    -- Mínimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos)
                             ,pr_vlmintgc_c  IN NUMBER    -- Mínimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos)
                             ,pr_qtmesliq_c  IN NUMBER    -- Qtd. Meses Cálculo Percentual de Liquidez
                             ,pr_vlmxprat_c  IN NUMBER    -- Valor máximo permitido por ramo de atividade
                             ,pr_pcmxctip_c  IN NUMBER    -- Concentração máxima de títulos por pagador
                             ,pr_flcocpfp_c  IN NUMBER    -- Consulta de CPF/CNPJ do pagador                 --> Excluir (DEFAULT 0 ?)
                             ,pr_qtmxdene_c  IN NUMBER    -- Quantidade máxima de dias para envio para Esteira
                             ,pr_qtdiexbo_c  IN NUMBER    -- Dias para expirar borderô                       --> Excluir (DEFAULT 0 ?)
                             ,pr_qtmxtbib_c  IN NUMBER    -- Quantidade máxima de títulos por borderô IB     --> Excluir (DEFAULT 0 ?)
                             ,pr_qtmxtbay_c  IN NUMBER    -- Quantidade máxima de títulos por borderô Ayllos --> Excluir (DEFAULT 0 ?)

                             ,pr_qtmitdcl    IN NUMBER    -- Quantidade mínima de títulos descontados para cálculo da liquidez
                             ,pr_vlmintcl    IN NUMBER    -- Valor mínimo para cálculo liquidez
                             ,pr_pctitpag    IN NUMBER    -- Percentual de títulos por pagador

                             ,pr_qtmitdcl_c  IN NUMBER    -- Quantidade mínima de títulos descontados para cálculo da liquidez
                             ,pr_vlmintcl_c  IN NUMBER    -- Valor mínimo para cálculo liquidez
                             ,pr_pctitpag_c  IN NUMBER    -- Percentual de títulos por pagador
                              ----------------------
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


  -----------------------------------------------------------------------------------------
  -- Procedure de Consulta da Tela TAB052
  -----------------------------------------------------------------------------------------
  PROCEDURE pc_consulta_web(
                            pr_tpcobran IN NUMBER             --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                           ,pr_inpessoa IN NUMBER             --> Tipo de pessoa:   1 = Fisica / 2 = Juridica
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
      vr_cdagenci crapage.cdagenci%TYPE; --> Código da Agência
      vr_nrdcaixa crapbcx.nrdcaixa%TYPE; --> Número do Caixa do Operador
      vr_cdoperad crapope.cdoperad%TYPE; --> Código do Operador
      vr_dtmvtolt crapdat.dtmvtolt%TYPE; --> Data do Movimento
      vr_idorigem INTEGER;               --> Identificador de Origem
      vr_nmdatela VARCHAR2(100);         --> Nome da Tela
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
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml,
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

      --> Buscar parametros gerais de desconto de titulo - TAB052
      DSCT0002.pc_busca_parametros_dsctit
                              (  pr_cdcooper => vr_cdcooper   --> Código da Cooperativa
                                ,pr_cdagenci => vr_cdagenci   --> Código da agencia
                                ,pr_nrdcaixa => vr_nrdcaixa   --> Numero do caixa do operador
                                ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                                ,pr_dtmvtolt => vr_dtmvtolt   --> data do movimento
                                ,pr_idorigem => vr_idorigem   --> Identificador de Origem
                                ,pr_tpcobran => pr_tpcobran   --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                ,pr_inpessoa => pr_inpessoa   --> Tipo de Pessoa:   1 = Física / 2 = Jurídica
                                ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> Tabela contendo os pârametros da Cooperativa
                                ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os pârametros da CECRED
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


    	------------------ dsdepart
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'dsdepart',
                             pr_tag_cont => rw_crapope.dsdepart,
                             pr_des_erro => vr_dscritic);


    	------------------ vllimite
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vllimite',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).vllimite,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vllimite_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).vllimite,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);


    ------------------ vlconsul
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlconsul',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).vlconsul,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlconsul_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).vlconsul,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

    ------------------ vlminsac
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlminsac',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).vlminsac,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlminsac_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).vlminsac,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

    ------------------ vlmaxsac --> Excluir
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmaxsac',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).vlmaxsac,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmaxsac_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).vlmaxsac,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

    ------------------ qtremcrt
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtremcrt',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtremcrt),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtremcrt_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtremcrt),
                             pr_des_erro => vr_dscritic);

    ------------------ qttitprt
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qttitprt',
                             pr_tag_cont => vr_tab_dados_dsctit(1).qttitprt,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qttitprt_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qttitprt),
                             pr_des_erro => vr_dscritic);

    ------------------ qtrenova --> Excluir
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtrenova',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtrenova),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtrenova_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtrenova),
                             pr_des_erro => vr_dscritic);

    ------------------ qtdiavig
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiavig',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtdiavig),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiavig_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtdiavig),
                             pr_des_erro => vr_dscritic);

    ------------------ qtprzmin
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmin',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtprzmin),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmin_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtprzmin),
                             pr_des_erro => vr_dscritic);

    ------------------ qtprzmax
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmax',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtprzmax),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmax_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtprzmax),
                             pr_des_erro => vr_dscritic);

    ------------------ cardbtit
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'cardbtit',
                             pr_tag_cont => to_char(0), -- Na consulta, retornar sempre 0. -- to_char(vr_tab_dados_dsctit(1).cardbtit),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'cardbtit_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).cardbtit),
                             pr_des_erro => vr_dscritic);

    ------------------ qtminfil
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtminfil',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtminfil),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtminfil_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtminfil),
                             pr_des_erro => vr_dscritic);

		------------------ nrmespsq
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nrmespsq',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).nrmespsq),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nrmespsq_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).nrmespsq),
                             pr_des_erro => vr_dscritic);

		------------------ pctitemi
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctitemi',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).pctitemi),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctitemi_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).pctitemi),
                             pr_des_erro => vr_dscritic);

		------------------ pctolera
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctolera',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).pctolera),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctolera_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).pctolera),
                             pr_des_erro => vr_dscritic);

		------------------ pcdmulta
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcdmulta',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).pcdmulta),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcdmulta_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).pcdmulta),
                             pr_des_erro => vr_dscritic);

		------------------ pcnaopag
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcnaopag',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).pcnaopag),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcnaopag_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).pcnaopag),
                             pr_des_erro => vr_dscritic);

		------------------ qtnaopag
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtnaopag',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtnaopag),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtnaopag_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtnaopag),
                             pr_des_erro => vr_dscritic);

		------------------ qtprotes
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprotes',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtprotes),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprotes_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtprotes),
                             pr_des_erro => vr_dscritic);

    ------------------ NOVOS CAMPOS ------------------

    ------------------ vlmxassi
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmxassi',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).vlmxassi,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmxassi_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).vlmxassi,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

		------------------ flemipar
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'flemipar',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).flemipar),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'flemipar_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).flemipar),
                             pr_des_erro => vr_dscritic);

		------------------ flpjzemi
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'flpjzemi',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).flpjzemi),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'flpjzemi_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).flpjzemi),
                             pr_des_erro => vr_dscritic);

		------------------ flpdctcp
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'flpdctcp',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).flpdctcp),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'flpdctcp_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).flpdctcp),
                             pr_des_erro => vr_dscritic);

		------------------ qttliqcp
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qttliqcp',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qttliqcp),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qttliqcp_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qttliqcp),
                             pr_des_erro => vr_dscritic);

		------------------ vltliqcp
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vltliqcp',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).vltliqcp),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vltliqcp_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).vltliqcp),
                             pr_des_erro => vr_dscritic);

		------------------ qtmintgc
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmintgc',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtmintgc),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmintgc_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtmintgc),
                             pr_des_erro => vr_dscritic);

		------------------ vlmintgc
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmintgc',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).vlmintgc),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmintgc_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).vlmintgc),
                             pr_des_erro => vr_dscritic);

		------------------ qtmesliq
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmesliq',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtmesliq),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmesliq_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtmesliq),
                             pr_des_erro => vr_dscritic);

		------------------ vlmxprat
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmxprat',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).vlmxprat),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmxprat_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).vlmxprat),
                             pr_des_erro => vr_dscritic);

		------------------ pcmxctip
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcmxctip',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).pcmxctip),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcmxctip_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).pcmxctip),
                             pr_des_erro => vr_dscritic);

		------------------ flcocpfp
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'flcocpfp',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).flcocpfp),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'flcocpfp_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).flcocpfp),
                             pr_des_erro => vr_dscritic);

		------------------ qtmxdene
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmxdene',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtmxdene),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmxdene_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtmxdene),
                             pr_des_erro => vr_dscritic);



		------------------ qtdiexbo
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiexbo',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtdiexbo),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiexbo_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtdiexbo),
                             pr_des_erro => vr_dscritic);

		------------------ qtmxtbib
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmxtbib',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtmxtbib),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmxtbib_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtmxtbib),
                             pr_des_erro => vr_dscritic);

		------------------ qtmxtbay
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmxtbay',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtmxtbay),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmxtbay_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtmxtbay),
                             pr_des_erro => vr_dscritic);

		------------------ qtmitdcl
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmitdcl',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).qtmitdcl),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtmitdcl_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).qtmitdcl),
                             pr_des_erro => vr_dscritic);

		------------------ vlmintcl
    gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmintcl',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).vlmintcl,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmintcl_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).vlmintcl,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

		------------------ pctitpag
	  gene0007.pc_insere_tag(pr_xml        => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctitpag',
                             pr_tag_cont => to_char(vr_tab_dados_dsctit(1).pctitpag),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctitpag_c',
                             pr_tag_cont => to_char(vr_tab_cecred_dsctit(1).pctitpag),
                             pr_des_erro => vr_dscritic);

		------------------ FIM ------------------


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
-- Procedure de Alteração da Tela TAB052
-----------------------------------------------------------------------------------------
  PROCEDURE pc_alterar_tab052(
                              pr_tpcobran    IN NUMBER --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                             ,pr_inpessoa    IN NUMBER --> Tipo de Pessoa:   1 = Física       / 2 = Jurídica
                             ,pr_vllimite    IN NUMBER
                             ,pr_vlconsul    IN NUMBER
                             ,pr_vlmaxsac    IN NUMBER --> Excluir 
                             ,pr_vlminsac    IN NUMBER
                             ,pr_qtremcrt    IN NUMBER
                             ,pr_qttitprt    IN NUMBER
                             ,pr_qtrenova    IN NUMBER --> Excluir 
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
                             ,pr_vlmaxsac_c  IN NUMBER --> Excluir 
                             ,pr_vlminsac_c  IN NUMBER
                             ,pr_qtremcrt_c  IN NUMBER
                             ,pr_qttitprt_c  IN NUMBER
                             ,pr_qtrenova_c  IN NUMBER --> Excluir 
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
                              ---- NOVOS CAMPOS ----
                             ,pr_vlmxassi    IN NUMBER  -- Valor Máximo Dispensa Assinatura
                             ,pr_flemipar    IN NUMBER  -- Verificar se Emitente é Cônjugue do Cooperado (no caso de Pessoa Física) / Verificar se Emitente é Sócio do Cooperado (no caso de Pessoa Jurídica)
                             ,pr_flpjzemi    IN NUMBER  -- Verificar Prejuízo do Emitente
                             ,pr_flpdctcp    IN NUMBER  -- Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
                             ,pr_qttliqcp    IN NUMBER  -- Mínimo de Liquidez do Cedente x Pagador (Qtd. de Titulos)
                             ,pr_vltliqcp    IN NUMBER  -- Mínimo de Liquidez do Cedente x Pagador (Valor dos Titulos)
                             ,pr_qtmintgc    IN NUMBER  -- Mínimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos)
                             ,pr_vlmintgc    IN NUMBER  -- Mínimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos)
                             ,pr_qtmesliq    IN NUMBER  -- Qtd. Meses Cálculo Percentual de Liquidez
                             ,pr_vlmxprat    IN NUMBER  -- Valor máximo permitido por ramo de atividade
                             ,pr_pcmxctip    IN NUMBER  -- Concentração máxima de títulos por pagador
                             ,pr_flcocpfp    IN NUMBER  -- Consulta de CPF/CNPJ do pagador                 
                             ,pr_qtmxdene    IN NUMBER  -- Quantidade máxima de dias para envio para Esteira
                             ,pr_qtdiexbo    IN NUMBER  -- Dias para expirar borderô                       
                             ,pr_qtmxtbib    IN NUMBER  -- Quantidade máxima de títulos por borderô IB     
                             ,pr_qtmxtbay    IN NUMBER  -- Quantidade máxima de títulos por borderô Ayllos 
                              ----------------------
                             ,pr_vlmxassi_c  IN NUMBER  -- Valor Máximo Dispensa Assinatura
                             ,pr_flemipar_c  IN NUMBER  -- Verificar se Emitente é Cônjugue do Cooperado (no caso de Pessoa Física) / Verificar se Emitente é Sócio do Cooperado (no caso de Pessoa Jurídica)
                             ,pr_flpjzemi_c  IN NUMBER  -- Verificar Prejuízo do Emitente
                             ,pr_flpdctcp_c  IN NUMBER  -- Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
                             ,pr_qttliqcp_c  IN NUMBER  -- Mínimo de Liquidez do Cedente x Pagador (Qtd. de Titulos)
                             ,pr_vltliqcp_c  IN NUMBER  -- Mínimo de Liquidez do Cedente x Pagador (Valor dos Titulos)
                             ,pr_qtmintgc_c  IN NUMBER  -- Mínimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos)
                             ,pr_vlmintgc_c  IN NUMBER  -- Mínimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos)
                             ,pr_qtmesliq_c  IN NUMBER  -- Qtd. Meses Cálculo Percentual de Liquidez
                             ,pr_vlmxprat_c  IN NUMBER  -- Valor máximo permitido por ramo de atividade
                             ,pr_pcmxctip_c  IN NUMBER  -- Concentração máxima de títulos por pagador
                             ,pr_flcocpfp_c  IN NUMBER  -- Consulta de CPF/CNPJ do pagador                  
                             ,pr_qtmxdene_c  IN NUMBER  -- Quantidade máxima de dias para envio para Esteira
                             ,pr_qtdiexbo_c  IN NUMBER  -- Dias para expirar borderô                        
                             ,pr_qtmxtbib_c  IN NUMBER  -- Quantidade máxima de títulos por borderô IB      
                             ,pr_qtmxtbay_c  IN NUMBER  -- Quantidade máxima de títulos por borderô Ayllos  
                             ,pr_qtmitdcl    IN NUMBER  -- Quantidade mínima de títulos descontados para cálculo da liquidez  
                             ,pr_vlmintcl    IN NUMBER  -- Valor mínimo para cálculo liquidez 
                             ,pr_pctitpag    IN NUMBER  -- Percentual de títulos por pagador 
                             ,pr_qtmitdcl_c  IN NUMBER  -- Quantidade mínima de títulos descontados para cálculo da liquidez  
                             ,pr_vlmintcl_c  IN NUMBER  -- Valor mínimo para cálculo liquidez 
                             ,pr_pctitpag_c  IN NUMBER  -- Percentual de títulos por pagador 
                              ----------------------
                             ,pr_xmllog      IN VARCHAR2      --> XML com informações de LOG
                             ,pr_cdcritic    OUT PLS_INTEGER  --> Código da crítica
                             ,pr_dscritic    OUT VARCHAR2     --> Descrição da crítica
                             ,pr_retxml      IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo    OUT VARCHAR2     --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) AS    --> Erros do processo
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


    IF pr_inpessoa = 1 THEN -- Pessoa Física
      IF pr_tpcobran = 1 THEN -- Cobrança Registrada
        vr_cdacesso := 'LIMDESCTITCRPF';
      ELSIF pr_tpcobran = 0 THEN -- Cobrança Sem Registro
        vr_cdacesso := 'LIMDESCTITPF';
      END IF;

    ELSIF pr_inpessoa = 2 THEN -- Pessoa Jurídica
      IF  pr_tpcobran = 1 THEN -- Cobrança Registrada
        vr_cdacesso := 'LIMDESCTITCRPJ';
      ELSIF pr_tpcobran = 0 THEN -- Cobrança Sem Registro
        vr_cdacesso := 'LIMDESCTITPJ';
      END IF;
    END IF;

    DSCT0002.pc_busca_parametros_dsctit
                            (  pr_cdcooper => vr_cdcooper   --> Código da Cooperativa
                              ,pr_cdagenci => vr_cdagenci   --> Código da agencia
                              ,pr_nrdcaixa => vr_nrdcaixa   --> Numero do caixa do operador
                              ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                              ,pr_dtmvtolt => vr_dtmvtolt   --> data do movimento
                              ,pr_idorigem => vr_idorigem   --> Identificador de Origem
                              ,pr_tpcobran => pr_tpcobran   --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                              ,pr_inpessoa => pr_inpessoa   --> Tipo de Pessoa:   1 = Física / 2 = Jurídica
                              ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> Tabela contendo os parametros da cooperativa
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


    OPEN  cr_crapope(pr_cdcooper => vr_cdcooper, pr_cdoperad => vr_cdoperad);
    FETCH cr_crapope
    INTO  rw_crapope;

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

    ---- VALIDAÇÕES OPERACIONAL ----
    IF pr_vllimite > pr_vllimite_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor do Limite Máximo do Contrato deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'vllimite';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;
    
    /* -- Campo excluído da Tela
    IF pr_vlmaxsac > pr_vlmaxsac_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O Valor Máximo Permitido por Título deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'vlmaxsac';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;
    */
    
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

    ---- VALIDAÇÕES NOVOS CAMPOS - OPERACIONAL ----
/*    
    IF pr_vlmxassi > pr_vlmxassi_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Valor Máximo Dispensa Assinatura Internet Banking deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'vlmxassi';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF pr_qttliqcp > pr_qttliqcp_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Minimo de Liquidez do Cedente x Pagador (Qtd. de Titulos) deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qttliqcp';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF pr_vltliqcp > pr_vltliqcp_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Minimo de Liquidez do Cedente x Pagador (Valor dos Titulos) deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'vltliqcp';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF pr_qtmintgc > pr_qtmintgc_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Minimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos) deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qtmintgc';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF pr_vlmintgc > pr_vlmintgc_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Minimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos) deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'vlmintgc';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF pr_qtmesliq > pr_qtmesliq_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Período em meses para realizar o cálculo de liquidez deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qtmesliq';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF pr_pcmxctip > pr_pcmxctip_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Concentração máxima de títulos por pagador deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'pcmxctip';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF pr_qtmxdene > pr_qtmxdene_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Quantidade máxima de dias para envio para Esteira deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qtmxdene';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF pr_qtdiexbo > pr_qtdiexbo_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Quantidade de dias para expirar borderô deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qtdiexbo';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF pr_qtmxtbib > pr_qtmxtbib_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Quantidade máxima de títulos por borderô IB deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qtmxtbib';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    IF pr_qtmxtbay > pr_qtmxtbay_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Quantidade máxima de títulos por borderô Ayllos deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qtmxtbay';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
*/

    ---- VALIDAÇÕES CECRED ----
    IF pr_vllimite > pr_vllimite_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor não pode ser menor que o da cooperativa';
      pr_nmdcampo := 'vllimite_c';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    /* -- Campo excluído da Tela
    IF pr_vlmaxsac > pr_vlmaxsac_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor não pode ser menor que o da cooperativa';
      pr_nmdcampo := 'vlmaxsac_c';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;
    */

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

    ---- VALIDAÇÕES NOVOS CAMPOS - CECRED ----


    vr_dstextab := to_char(pr_vllimite,     'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlconsul,     'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlmaxsac,     'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlminsac,     'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_qtremcrt,     'FM000')                                           ||';'||
                   to_char(pr_qttitprt,     'FM000')                                           ||';'||
                   to_char(pr_qtrenova,     'FM00')                                           ||';'|| -- ***
                   to_char(pr_qtdiavig,     'FM0000')                                          ||';'||
                   to_char(pr_qtprzmin,     'FM000')                                           ||';'||
                   to_char(pr_qtprzmax,     'FM000')                                           ||';'||
                   to_char(pr_qtminfil,     'FM000')                                           ||';'||
                   to_char(pr_nrmespsq,     'FM00')                                           ||';'|| -- **
                   to_char(pr_pctitemi,     'FM000')                                           ||';'||
                   to_char(pr_pctolera,     'FM000')                                           ||';'||
                   to_char(pr_pcdmulta,     'FM000D000000', 'NLS_NUMERIC_CHARACTERS='',.''')   ||';'||
                   to_char(pr_vllimite_c,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlconsul_c,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlmaxsac_c,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_vlminsac_c,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_qtremcrt_c,   'FM000')                                           ||';'||
                   to_char(pr_qttitprt_c,   'FM000')                                           ||';'||
                   to_char(pr_qtrenova_c,   'FM00')                                           ||';'|| -- **
                   to_char(pr_qtdiavig_c,   'FM0000')                                          ||';'||
                   to_char(pr_qtprzmin_c,   'FM000')                                           ||';'||
                   to_char(pr_qtprzmax_c,   'FM000')                                           ||';'||
                   to_char(pr_qtminfil_c,   'FM000')                                           ||';'||
                   to_char(pr_nrmespsq_c,   'FM00')                                           ||';'|| -- **
                   to_char(pr_pctitemi_c,   'FM000')                                           ||';'||
                   to_char(pr_pctolera_c,   'FM000')                                           ||';'||
                   to_char(pr_pcdmulta_c,   'FM000D000000', 'NLS_NUMERIC_CHARACTERS='',.''')   ||';'||
                   to_char(pr_cardbtit,     'FM000')                                           ||';'||
                   to_char(pr_cardbtit_c,   'FM000')                                           ||';'||
                   to_char(pr_pcnaopag,     'FM000')                                           ||';'||
                   to_char(pr_qtnaopag,     'FM0000')                                          ||';'||
                   to_char(pr_qtprotes,     'FM0000')                                          ||';'||
                   to_char(pr_pcnaopag_c,   'FM000')                                           ||';'||
                   to_char(pr_qtnaopag_c,   'FM0000')                                          ||';'||
                   to_char(pr_qtprotes_c, 	'FM0000')                                          ||';'||
                   ---- NOVOS CAMPOS - OPERACIONAL ----
                   to_char(pr_vlmxassi,     'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_flemipar,	    'FM0')                                             ||';'||
                   to_char(pr_flpjzemi,	    'FM0')                                             ||';'||
                   to_char(pr_flpdctcp,	    'FM0')                                             ||';'||
                   to_char(pr_qttliqcp,	    'FM000')                                           ||';'||
                   to_char(pr_vltliqcp,	    'FM000')                                           ||';'||
                   to_char(pr_qtmintgc,	    'FM000')                                           ||';'||
                   to_char(pr_vlmintgc,	    'FM000')                                           ||';'||
                   to_char(pr_qtmesliq,	    'FM0000')                                          ||';'||
                   to_char(pr_vlmxprat,	    'FM0')                                             ||';'||
                   to_char(pr_pcmxctip,	    'FM0000')                                          ||';'||
                   to_char(pr_flcocpfp,	    'FM0')                                             ||';'||
                   to_char(pr_qtmxdene,	    'FM0000')                                          ||';'||
                   to_char(pr_qtdiexbo,	    'FM0000')                                          ||';'||
                   to_char(pr_qtmxtbib,	    'FM0000')                                          ||';'||
                   to_char(pr_qtmxtbay,	    'FM0000')                                          ||';'||
                   
                   ---- NOVOS CAMPOS - CECRED ----
                   to_char(pr_vlmxassi_c,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_flemipar_c,   'FM0')                                             ||';'||
                   to_char(pr_flpjzemi_c,   'FM0')                                             ||';'||
                   to_char(pr_flpdctcp_c,   'FM0')                                             ||';'||
                   to_char(pr_qttliqcp_c,   'FM000', 'NLS_NUMERIC_CHARACTERS='',.''')          ||';'||
                   to_char(pr_vltliqcp_c,   'FM000', 'NLS_NUMERIC_CHARACTERS='',.''')          ||';'||
                   to_char(pr_qtmintgc_c,   'FM000')                                           ||';'||
                   to_char(pr_vlmintgc_c,   'FM000', 'NLS_NUMERIC_CHARACTERS='',.''')          ||';'||
                   to_char(pr_qtmesliq_c,   'FM0000')                                          ||';'||
                   to_char(pr_vlmxprat_c,   'FM0')                                             ||';'||
                   to_char(pr_pcmxctip_c,   'FM0000')                                          ||';'||
                   to_char(pr_flcocpfp_c,   'FM0')                                             ||';'||
                   to_char(pr_qtmxdene_c,   'FM0000')                                          ||';'||
                   to_char(pr_qtdiexbo_c,   'FM0000')                                          ||';'||
                   to_char(pr_qtmxtbib_c,   'FM0000')                                          ||';'||
                   to_char(pr_qtmxtbay_c,   'FM0000')                                          ||';'||

                   to_char(pr_qtmitdcl,	    'FM0000')                                          ||';'||
                   to_char(pr_vlmintcl,	    'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_pctitpag,	    'FM0000')                                          ||';'||

                   to_char(pr_qtmitdcl_c,	  'FM0000')                                          ||';'||
                   to_char(pr_vlmintcl_c,	  'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||';'||
                   to_char(pr_pctitpag_c,	  'FM0000');

                   ---- FIM ----

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


----> vllimite
    IF vr_tab_dados_dsctit(1).vllimite <> pr_vllimite THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o limite maximo do contrato de R$ ' ||
                                    to_char(vr_tab_dados_dsctit(1).vllimite,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vllimite,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> vllimite_c
    IF vr_tab_cecred_dsctit(1).vllimite <> pr_vllimite_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o limite maximo do contrato CECRED de R$ ' ||
                                    to_char(vr_tab_cecred_dsctit(1).vllimite,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vllimite_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;

----> qtdiavig
    IF vr_tab_dados_dsctit(1).qtdiavig <> pr_qtdiavig THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias da vigencia minima de ' ||
                                    to_char(vr_tab_dados_dsctit(1).qtdiavig) ||
                                    ' para ' || to_char(pr_qtdiavig));

    END IF;

----> qtdiavig_c
    IF vr_tab_cecred_dsctit(1).qtdiavig <> pr_qtdiavig_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias da vigencia minima de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtdiavig) ||
                                    ' para ' || to_char(pr_qtdiavig_c));

    END IF;

----> qtprzmin
    IF vr_tab_dados_dsctit(1).qtprzmin <> pr_qtprzmin THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias de prazo minimo do cheque de ' ||
                                    to_char(vr_tab_dados_dsctit(1).qtprzmin) ||
                                    ' para ' || to_char(pr_qtprzmin));

    END IF;

----> qtprzmax
    IF vr_tab_dados_dsctit(1).qtprzmax <> pr_qtprzmax THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias de prazo maximo do cheque de ' ||
                                    to_char(vr_tab_dados_dsctit(1).qtprzmax) ||
                                    ' para ' || to_char(pr_qtprzmax));
    END IF;

----> qtprzmax_c
    IF vr_tab_cecred_dsctit(1).qtprzmax <> pr_qtprzmax_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias de prazo maximo do titulo CECRED de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtprzmax) ||
                                    ' para ' || to_char(pr_qtprzmax_c));

    END IF;

----> pcdmulta
    IF vr_tab_dados_dsctit(1).pcdmulta <> pr_pcdmulta THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o percentual de multa sobre devolucao de ' ||
                                    to_char(vr_tab_dados_dsctit(1).pcdmulta) ||
                                    ' para ' || to_char(pr_pcdmulta));

    END IF;

----> vlconsul
    IF vr_tab_dados_dsctit(1).vlconsul <> pr_vlconsul THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor do titulo a ser consultado de R$ ' ||
                                    to_char(vr_tab_dados_dsctit(1).vlconsul,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vlconsul,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> vlmaxsac
    IF vr_tab_dados_dsctit(1).vlmaxsac <> pr_vlmaxsac THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor maximo permitido por emitente de R$ ' ||
                                    to_char(vr_tab_dados_dsctit(1).vlmaxsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vlmaxsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> vlmaxsac_c
    IF vr_tab_cecred_dsctit(1).vlmaxsac <> pr_vlmaxsac_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor maximo permitido por emitente CECRED de R$ ' ||
                                    to_char(vr_tab_cecred_dsctit(1).vlmaxsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vlmaxsac_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> vlminsac
    IF vr_tab_dados_dsctit(1).vlminsac <> pr_vlminsac THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor maximo permitido por emitente de R$ ' ||
                                    to_char(vr_tab_dados_dsctit(1).vlminsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vlminsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> vlminsac_c
    IF vr_tab_cecred_dsctit(1).vlminsac <> pr_vlminsac_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor maximo permitido por emitente CECRED de R$ ' ||
                                    to_char(vr_tab_cecred_dsctit(1).vlminsac,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vlminsac_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;


----> qtrenova
    IF vr_tab_dados_dsctit(1).qtrenova <> pr_qtrenova THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou Qtd. de Renovacoes de ' ||
                                    to_char(vr_tab_dados_dsctit(1).qtrenova,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_qtrenova,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> qtrenova_c
    IF vr_tab_cecred_dsctit(1).qtrenova <> pr_qtrenova_c THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou Qtd. de Renovacoes CECRED de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtrenova,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_qtrenova_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;


----> pctitemi
    IF vr_tab_dados_dsctit(1).pctitemi <> pr_pctitemi THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o percentual de cheques por emitente de ' ||
                                    to_char(vr_tab_dados_dsctit(1).pctitemi) ||
                                    ' para ' || to_char(pr_pctitemi));
    END IF;

----> pctitemi_c
    IF vr_tab_cecred_dsctit(1).pctitemi <> pr_pctitemi_c THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o percentual de cheques por emitente CECRED de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).pctitemi) ||
                                    ' para ' || to_char(pr_pctitemi_c));
    END IF;


---- LOG NOVOS CAMPOS ----


----> vlmxassi
    IF vr_tab_dados_dsctit(1).vlmxassi <> pr_vlmxassi THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Valor Máximo Dispensa Assinatura IB de R$ ' ||
                                    to_char(vr_tab_dados_dsctit(1).vlmxassi,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vllimite,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

----> vlmxassi_c
    IF vr_tab_cecred_dsctit(1).vlmxassi <> pr_vlmxassi_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Valor Máximo Dispensa Assinatura IB CECRED de R$ ' ||
                                    to_char(vr_tab_cecred_dsctit(1).vlmxassi,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para R$ ' || to_char(pr_vlmxassi_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;
-----------> ok


----> flemipar
    IF vr_tab_dados_dsctit(1).flemipar <> pr_flemipar THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou Verificar Relacionamento Emitente (Cônjuge/Sócio) de ' ||
                                    to_char(vr_tab_dados_dsctit(1).flemipar) ||
                                    ' para ' || to_char(pr_flemipar));
    END IF;

----> flemipar_c
    IF vr_tab_cecred_dsctit(1).flemipar <> pr_flemipar_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou Verificar Relacionamento Emitente (Cônjuge/Sócio) de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).flemipar) ||
                                    ' para ' || to_char(pr_flemipar_c));

    END IF;
-----------> ok


----> flpjzemi
    IF vr_tab_dados_dsctit(1).flpjzemi <> pr_flpjzemi THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou Verificar Cooperado Possui Prejuizo na Cooperativa de ' ||
                                    to_char(vr_tab_dados_dsctit(1).flpjzemi) ||
                                    ' para ' || to_char(pr_flpjzemi));
    END IF;

----> flpjzemi_c
    IF vr_tab_cecred_dsctit(1).flpjzemi <> pr_flpjzemi_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou Verificar Cooperado Possui Prejuizo na Cooperativa de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).flpjzemi) ||
                                    ' para ' || to_char(pr_flpjzemi_c));

    END IF;
-----------> ok


----> flpdctcp
    IF vr_tab_dados_dsctit(1).flpdctcp <> pr_flpdctcp THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador de ' ||
                                    to_char(vr_tab_dados_dsctit(1).flpdctcp) ||
                                    ' para ' || to_char(pr_flpdctcp));
    END IF;

----> flpdctcp_c
    IF vr_tab_cecred_dsctit(1).flpdctcp <> pr_flpdctcp_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).flpdctcp) ||
                                    ' para ' || to_char(pr_flpdctcp_c));

    END IF;
-----------> ok


----> qttliqcp
    IF vr_tab_dados_dsctit(1).qttliqcp <> pr_qttliqcp THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Minimo de Liquidez do Cedente x Pagador (Qtd. de Titulos) de ' ||
                                    to_char(vr_tab_dados_dsctit(1).qttliqcp) ||
                                    ' para ' || to_char(pr_qttliqcp));
    END IF;

----> qttliqcp_c
    IF vr_tab_cecred_dsctit(1).qttliqcp <> pr_qttliqcp_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Minimo de Liquidez do Cedente x Pagador (Qtd. de Titulos) de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qttliqcp) ||
                                    ' para ' || to_char(pr_qttliqcp_c));

    END IF;
-----------> ok


  ----> vltliqcp
    IF vr_tab_dados_dsctit(1).vltliqcp <> pr_vltliqcp THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Minimo de Liquidez do Cedente x Pagador (Valor dos Titulos) de ' ||
                                    to_char(vr_tab_dados_dsctit(1).vltliqcp) ||
                                    ' para ' || to_char(pr_vltliqcp));
    END IF;

  ----> vltliqcp_c
    IF vr_tab_cecred_dsctit(1).vltliqcp <> pr_vltliqcp_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Minimo de Liquidez do Cedente x Pagador (Valor dos Titulos) de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).vltliqcp) ||
                                    ' para ' || to_char(pr_vltliqcp_c));

    END IF;

  ----> qtmintgc
    IF vr_tab_dados_dsctit(1).qtmintgc <> pr_qtmintgc THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Mínimo de Liquidez de Títulos Geral do Cedente (Qtd de Títulos) de ' ||
                                    to_char(vr_tab_dados_dsctit(1).qtmintgc) ||
                                    ' para ' || to_char(pr_qtmintgc));
    END IF;

  ----> qtmintgc_c
    IF vr_tab_cecred_dsctit(1).qtmintgc <> pr_qtmintgc_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Mínimo de Liquidez de Títulos Geral do Cedente (Qtd de Títulos) de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtmintgc) ||
                                    ' para ' || to_char(pr_qtmintgc_c));

    END IF;
	
  ----> vlmintgc
    IF vr_tab_dados_dsctit(1).vlmintgc <> pr_vlmintgc THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Mínimo de Liquidez de Titulos Geral do Cedente (Valor dos Títulos) ' ||
                                    to_char(vr_tab_dados_dsctit(1).vlmintgc) ||
                                    ' para ' || to_char(pr_vlmintgc));
    END IF;

  ----> vlmintgc_c
    IF vr_tab_cecred_dsctit(1).vlmintgc <> pr_vlmintgc_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Mínimo de Liquidez de Titulos Geral do Cedente (Valor dos Títulos) de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).vlmintgc) ||
                                    ' para ' || to_char(pr_vlmintgc_c));

    END IF;
	
  ----> qtmesliq
    IF vr_tab_dados_dsctit(1).qtmesliq <> pr_qtmesliq THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Período em meses para realizar o cálculo de liquidez de' ||
                                    to_char(vr_tab_dados_dsctit(1).qtmesliq) ||
                                    ' para ' || to_char(pr_qtmesliq));
    END IF;

  ----> qtmesliq_c
    IF vr_tab_cecred_dsctit(1).qtmesliq <> pr_qtmesliq_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Período em meses para realizar o cálculo de liquidez de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtmesliq) ||
                                    ' para ' || to_char(pr_qtmesliq_c));

    END IF;
	
	----> qtmesliq
    IF vr_tab_dados_dsctit(1).qtmesliq <> pr_qtmesliq THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Período em meses para realizar o cálculo de liquidez de' ||
                                    to_char(vr_tab_dados_dsctit(1).qtmesliq) ||
                                    ' para ' || to_char(pr_qtmesliq));
    END IF;

  ----> qtmesliq_c
    IF vr_tab_cecred_dsctit(1).qtmesliq <> pr_qtmesliq_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Período em meses para realizar o cálculo de liquidez de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtmesliq) ||
                                    ' para ' || to_char(pr_qtmesliq_c));

    END IF;
	
	----> vlmxprat
    IF vr_tab_dados_dsctit(1).vlmxprat <> pr_vlmxprat THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Verificar o valor máximo permitido por ramo de atividade (Cód. CNAE) de' ||
                                    to_char(vr_tab_dados_dsctit(1).vlmxprat) ||
                                    ' para ' || to_char(pr_vlmxprat));
    END IF;

  ----> vlmxprat_c
    IF vr_tab_cecred_dsctit(1).vlmxprat <> pr_vlmxprat_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Verificar o valor máximo permitido por ramo de atividade (Cód. CNAE) de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).vlmxprat) ||
                                    ' para ' || to_char(pr_vlmxprat_c));

    END IF;
	
	----> pcmxctip
    IF vr_tab_dados_dsctit(1).pcmxctip <> pr_pcmxctip THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Concentração máxima de títulos por pagador de' ||
                                    to_char(vr_tab_dados_dsctit(1).pcmxctip) ||
                                    ' para ' || to_char(pr_pcmxctip));
    END IF;

  ----> pcmxctip_c
    IF vr_tab_cecred_dsctit(1).pcmxctip <> pr_pcmxctip_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Concentração máxima de títulos por pagador de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).pcmxctip) ||
                                    ' para ' || to_char(pr_pcmxctip_c));

    END IF;
		
	----> flcocpfp
    IF vr_tab_dados_dsctit(1).flcocpfp <> pr_flcocpfp THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o flcocpfp de' ||
                                    to_char(vr_tab_dados_dsctit(1).flcocpfp) ||
                                    ' para ' || to_char(pr_flcocpfp));
    END IF;

  ----> flcocpfp_c
    IF vr_tab_cecred_dsctit(1).flcocpfp <> pr_flcocpfp_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o flcocpfp de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).flcocpfp) ||
                                    ' para ' || to_char(pr_flcocpfp_c));

    END IF;

	----> qtmxdene
    IF vr_tab_dados_dsctit(1).qtmxdene <> pr_qtmxdene THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Quantidade máxima de dias para envio para Esteira de' ||
                                    to_char(vr_tab_dados_dsctit(1).qtmxdene) ||
                                    ' para ' || to_char(pr_qtmxdene));
    END IF;

  ----> qtmxdene_c
    IF vr_tab_cecred_dsctit(1).qtmxdene <> pr_qtmxdene_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Quantidade máxima de dias para envio para Esteira de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtmxdene) ||
                                    ' para ' || to_char(pr_qtmxdene_c));

    END IF;

	----> qtdiexbo
    IF vr_tab_dados_dsctit(1).qtdiexbo <> pr_qtdiexbo THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Dias para expirar borderô de' ||
                                    to_char(vr_tab_dados_dsctit(1).qtdiexbo) ||
                                    ' para ' || to_char(pr_qtdiexbo));
    END IF;

  ----> qtdiexbo_c
    IF vr_tab_cecred_dsctit(1).qtdiexbo <> pr_qtdiexbo_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Dias para expirar borderô de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtdiexbo) ||
                                    ' para ' || to_char(pr_qtdiexbo_c));

    END IF;
	
	----> qtmxtbib
    IF vr_tab_dados_dsctit(1).qtmxtbib <> pr_qtmxtbib THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. máxima de títulos por borderô de' ||
                                    to_char(vr_tab_dados_dsctit(1).qtmxtbib) ||
                                    ' para ' || to_char(pr_qtmxtbib));
    END IF;

  ----> qtmxtbib_c
    IF vr_tab_cecred_dsctit(1).qtmxtbib <> pr_qtmxtbib_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. máxima de títulos por borderô de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtmxtbib) ||
                                    ' para ' || to_char(pr_qtmxtbib_c));

    END IF;
	
	
	----> qtmxtbay
    IF vr_tab_dados_dsctit(1).qtmxtbay <> pr_qtmxtbay THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. máxima de títulos por borderô de' ||
                                    to_char(vr_tab_dados_dsctit(1).qtmxtbay) ||
                                    ' para ' || to_char(pr_qtmxtbay));
    END IF;

  ----> qtmxtbay_c
    IF vr_tab_cecred_dsctit(1).qtmxtbay <> pr_qtmxtbay_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o qtmxtbay de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtmxtbay) ||
                                    ' para ' || to_char(pr_qtmxtbay_c));

    END IF;
	
	
	
	----> qtmitdcl
    IF vr_tab_dados_dsctit(1).qtmitdcl <> pr_qtmitdcl THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. Mínima de Títulos Descontados para Cálculo da Liquidez de' ||
                                    to_char(vr_tab_dados_dsctit(1).qtmitdcl) ||
                                    ' para ' || to_char(pr_qtmitdcl));
    END IF;

  ----> qtmitdcl_c
    IF vr_tab_cecred_dsctit(1).qtmitdcl <> pr_qtmitdcl_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. Mínima de Títulos Descontados para Cálculo da Liquidez de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtmitdcl) ||
                                    ' para ' || to_char(pr_qtmitdcl_c));

    END IF;
		
	----> vlmintcl
    IF vr_tab_dados_dsctit(1).vlmintcl <> pr_vlmintcl THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. Mínima de Títulos Descontados para Cálculo da Liquidez de' ||
                                    to_char(vr_tab_dados_dsctit(1).vlmintcl) ||
                                    ' para ' || to_char(pr_vlmintcl));
    END IF;

  ----> vlmintcl_c
    IF vr_tab_cecred_dsctit(1).vlmintcl <> pr_vlmintcl_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Valor Mínimo para Cálculo de Liquidez de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).vlmintcl) ||
                                    ' para ' || to_char(pr_vlmintcl_c));

    END IF;
	
	
	----> pctitpag
    IF vr_tab_dados_dsctit(1).pctitpag <> pr_pctitpag THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. Mínima de Títulos Descontados para Cálculo da Liquidez de' ||
                                    to_char(vr_tab_dados_dsctit(1).pctitpag) ||
                                    ' para ' || to_char(pr_pctitpag));
    END IF;

	----> pctitpag_c
    IF vr_tab_cecred_dsctit(1).pctitpag <> pr_pctitpag_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Valor Mínimo para Cálculo de Liquidez de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).pctitpag) ||
                                    ' para ' || to_char(pr_pctitpag_c));

    END IF;
	
	
	
	----> qtminfil
    IF vr_tab_dados_dsctit(1).qtminfil <> pr_qtminfil THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Tempo Mínimo de Filiação de' ||
                                    to_char(vr_tab_dados_dsctit(1).qtminfil) ||
                                    ' para ' || to_char(pr_qtminfil));
    END IF;

	----> qtminfil_c
    IF vr_tab_cecred_dsctit(1).qtminfil <> pr_qtminfil_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Tempo Mínimo de Filiação de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtminfil) ||
                                    ' para ' || to_char(pr_qtminfil_c));

    END IF;
	

	
	----> nrmespsq
    IF vr_tab_dados_dsctit(1).nrmespsq <> pr_nrmespsq THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. de Meses para Pesquisa de Pagador de' ||
                                    to_char(vr_tab_dados_dsctit(1).nrmespsq) ||
                                    ' para ' || to_char(pr_nrmespsq));
    END IF;

	----> nrmespsq_c
    IF vr_tab_cecred_dsctit(1).nrmespsq <> pr_nrmespsq_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. de Meses para Pesquisa de Pagador de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).nrmespsq) ||
                                    ' para ' || to_char(pr_nrmespsq_c));

    END IF;
	
	
	
	
	----> pctolera
    IF vr_tab_dados_dsctit(1).pctolera <> pr_pctolera THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Tolerância para Limite Excedido de' ||
                                    to_char(vr_tab_dados_dsctit(1).pctolera) ||
                                    ' para ' || to_char(pr_pctolera));
    END IF;

	----> pctolera_c
    IF vr_tab_cecred_dsctit(1).pctolera <> pr_pctolera_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Tolerância para Limite Excedido de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).pctolera) ||
                                    ' para ' || to_char(pr_pctolera_c));

    END IF;
	
	
	
	----> qtremcrt
    IF vr_tab_dados_dsctit(1).qtremcrt <> pr_qtremcrt THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. Remessa em Cartório de' ||
                                    to_char(vr_tab_dados_dsctit(1).qtremcrt) ||
                                    ' para ' || to_char(pr_qtremcrt));
    END IF;

	----> qtremcrt_c
    IF vr_tab_cecred_dsctit(1).pctolera <> pr_qtremcrt_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. Remessa em Cartório de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtremcrt) ||
                                    ' para ' || to_char(pr_qtremcrt_c));

    END IF;
	

	
	
		----> qttitprt
    IF vr_tab_dados_dsctit(1).qttitprt <> pr_qttitprt THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. Remessa em Cartório de' ||
                                    to_char(vr_tab_dados_dsctit(1).qttitprt) ||
                                    ' para ' || to_char(pr_qttitprt));
    END IF;

	----> qttitprt_c
    IF vr_tab_cecred_dsctit(1).qttitprt <> pr_qttitprt_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. de Títulos Protestados de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qttitprt) ||
                                    ' para ' || to_char(pr_qttitprt_c));

    END IF;
	
	
	----> cardbtit
    IF vr_tab_dados_dsctit(1).cardbtit <> pr_cardbtit THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. Remessa em Cartório de' ||
                                    to_char(vr_tab_dados_dsctit(1).cardbtit) ||
                                    ' para ' || to_char(pr_cardbtit));
    END IF;

	----> cardbtit_c
    IF vr_tab_cecred_dsctit(1).cardbtit <> pr_cardbtit_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. de Títulos Protestados de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).cardbtit) ||
                                    ' para ' || to_char(pr_cardbtit_c));

    END IF;
	
	----> cardbtit
    IF vr_tab_dados_dsctit(1).cardbtit <> pr_cardbtit THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Carência Débito Título Vencido de' ||
                                    to_char(vr_tab_dados_dsctit(1).cardbtit) ||
                                    ' para ' || to_char(pr_cardbtit));
    END IF;

	----> cardbtit_c
    IF vr_tab_cecred_dsctit(1).cardbtit <> pr_cardbtit_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Carência Débito Título Vencido de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).cardbtit) ||
                                    ' para ' || to_char(pr_cardbtit_c));

    END IF;
	
	----> cardbtit
    IF vr_tab_dados_dsctit(1).cardbtit <> pr_cardbtit THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Carência Débito Título Vencido de' ||
                                    to_char(vr_tab_dados_dsctit(1).cardbtit) ||
                                    ' para ' || to_char(pr_cardbtit));
    END IF;

	----> cardbtit_c
    IF vr_tab_cecred_dsctit(1).cardbtit <> pr_cardbtit_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Carência Débito Título Vencido de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).cardbtit) ||
                                    ' para ' || to_char(pr_cardbtit_c));

    END IF;
	
	
	
	----> pcnaopag
    IF vr_tab_dados_dsctit(1).pcnaopag <> pr_pcnaopag THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Perc. de Títulos Não Pagos Beneficiário de' ||
                                    to_char(vr_tab_dados_dsctit(1).pcnaopag) ||
                                    ' para ' || to_char(pr_pcnaopag));
    END IF;

	----> pcnaopag_c
    IF vr_tab_cecred_dsctit(1).pcnaopag <> pr_pcnaopag_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Perc. de Títulos Não Pagos Beneficiário de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).pcnaopag) ||
                                    ' para ' || to_char(pr_pcnaopag_c));

    END IF;
	
	
	
	----> qtnaopag
    IF vr_tab_dados_dsctit(1).qtnaopag <> pr_qtnaopag THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. de Títulos Não Pagos Pagador de' ||
                                    to_char(vr_tab_dados_dsctit(1).qtnaopag) ||
                                    ' para ' || to_char(pr_qtnaopag));
    END IF;

	----> qtnaopag_c
    IF vr_tab_cecred_dsctit(1).qtnaopag <> pr_qtnaopag_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. de Títulos Não Pagos Pagador de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtnaopag) ||
                                    ' para ' || to_char(pr_qtnaopag_c));

    END IF;


	----> qtprotes
    IF vr_tab_dados_dsctit(1).qtprotes <> pr_qtprotes THEN
      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. de Títulos Protestados-Cooperado de' ||
                                    to_char(vr_tab_dados_dsctit(1).qtprotes) ||
                                    ' para ' || to_char(pr_qtprotes));
    END IF;

	----> qtprotes_c
    IF vr_tab_cecred_dsctit(1).qtprotes <> pr_qtprotes_c THEN

      --> gerar log da tela
      pc_log_tab052(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o Qtd. de Títulos Protestados-Cooperado de ' ||
                                    to_char(vr_tab_cecred_dsctit(1).qtprotes) ||
                                    ' para ' || to_char(pr_qtprotes_c));

    END IF;
    -- FIM LOG --


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
