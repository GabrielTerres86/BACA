CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_CVNCDC IS

  TYPE typ_reg_info_cdc
	     IS RECORD(dsendere tbsite_cooperado_cdc.dslogradouro%TYPE
                  ,nrendere tbsite_cooperado_cdc.nrendereco%TYPE
                  ,complend tbsite_cooperado_cdc.dscomplemento%TYPE
                  ,nmbairro tbsite_cooperado_cdc.nmbairro%TYPE
                  ,nrcepend tbsite_cooperado_cdc.nrcep%TYPE
                  ,nmcidade crapenc.nmcidade%TYPE
                  ,cdufende crapenc.cdufende%TYPE
                  ,idcidade tbsite_cooperado_cdc.idcidade%TYPE
                  ,nrtelefo tbsite_cooperado_cdc.dstelefone%TYPE
                  ,dsdemail tbsite_cooperado_cdc.dsemail%TYPE
                  ,nmfansia tbsite_cooperado_cdc.nmfantasia%TYPE);

  PROCEDURE pc_busca_dados(pr_nrdconta        IN crapcdr.nrdconta%TYPE --> Numero da conta
                          ,pr_inpessoa        IN crapass.inpessoa%TYPE --> Tipo de pessoa
                          ,pr_idmatriz        IN tbsite_cooperado_cdc.idmatriz%TYPE
                          ,pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE
                          ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro       OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_dados(pr_cdcooper           IN crapcop.cdcooper%TYPE --> Cód da cooperativa
                          ,pr_cdoperad           IN crapope.cdoperad%TYPE --> Operador
                          ,pr_idorigem           IN INTEGER               --> Origem
                          ,pr_nmdatela           IN VARCHAR2              -- Nome da tela
                          ,pr_nrdconta           IN crapcdr.nrdconta%TYPE --> Numero da conta
                          ,pr_inpessoa           IN crapass.inpessoa%TYPE --> Tipo de pessoa
                          ,pr_idmatriz           IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE --> Identificador da Matriz
                          ,pr_idcooperado_cdc    IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE --> Identificador do cooperado no CDC
                          ,pr_flgconve           IN crapcdr.flgconve%TYPE --> Indicador se cooperado possui convenio CDC
                          ,pr_dtinicon           IN VARCHAR2 --> Data de inicio de convenio
                          ,pr_nmfantasia         IN tbsite_cooperado_cdc.nmfantasia%TYPE --> Nome fantasia
                          ,pr_cdcnae             IN tbsite_cooperado_cdc.cdcnae%TYPE --> Codigo da classificacao CNAE
                          ,pr_dslogradouro       IN tbsite_cooperado_cdc.dslogradouro%TYPE --> Descricao do logradouro
                          ,pr_dscomplemento      IN tbsite_cooperado_cdc.dscomplemento%TYPE --> Complemento da localizacao
                          ,pr_nrendereco         IN tbsite_cooperado_cdc.nrendereco%TYPE --> Numero do endereco da localizacao
                          ,pr_nmbairro           IN tbsite_cooperado_cdc.nmbairro%TYPE --> Bairro da localizacao
                          ,pr_nrcep              IN tbsite_cooperado_cdc.nrcep%TYPE --> CEP da localizacao
                          ,pr_idcidade           IN tbsite_cooperado_cdc.idcidade%TYPE --> Codigo da cidade da localizacao
                          ,pr_dstelefone         IN tbsite_cooperado_cdc.dstelefone%TYPE --> Telefone do conveniado CDC
                          ,pr_dsemail            IN tbsite_cooperado_cdc.dsemail%TYPE --> E-mail de contato
                          ,pr_dslink_google_maps IN tbsite_cooperado_cdc.dslink_google_maps%TYPE --> Link da localizacao no google maps
                          ,pr_cdcritic          OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic          OUT VARCHAR2 --> Descricao da critica
                          ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro          OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_dados_web(pr_nrdconta           IN crapcdr.nrdconta%TYPE --> Numero da conta
															,pr_inpessoa           IN crapass.inpessoa%TYPE --> Tipo de pessoa
															,pr_idmatriz           IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE --> Identificador da Matriz
															,pr_idcooperado_cdc    IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE --> Identificador do cooperado no CDC
															,pr_flgconve           IN crapcdr.flgconve%TYPE --> Indicador se cooperado possui convenio CDC
															,pr_dtinicon           IN VARCHAR2 --> Data de inicio de convenio
															,pr_nmfantasia         IN tbsite_cooperado_cdc.nmfantasia%TYPE --> Nome fantasia
															,pr_cdcnae             IN tbsite_cooperado_cdc.cdcnae%TYPE --> Codigo da classificacao CNAE
															,pr_dslogradouro       IN tbsite_cooperado_cdc.dslogradouro%TYPE --> Descricao do logradouro
															,pr_dscomplemento      IN tbsite_cooperado_cdc.dscomplemento%TYPE --> Complemento da localizacao
															,pr_nrendereco         IN tbsite_cooperado_cdc.nrendereco%TYPE --> Numero do endereco da localizacao
															,pr_nmbairro           IN tbsite_cooperado_cdc.nmbairro%TYPE --> Bairro da localizacao
															,pr_nrcep              IN tbsite_cooperado_cdc.nrcep%TYPE --> CEP da localizacao
															,pr_idcidade           IN tbsite_cooperado_cdc.idcidade%TYPE --> Codigo da cidade da localizacao
															,pr_dstelefone         IN tbsite_cooperado_cdc.dstelefone%TYPE --> Telefone do conveniado CDC
															,pr_dsemail            IN tbsite_cooperado_cdc.dsemail%TYPE --> E-mail de contato
															,pr_dslink_google_maps IN tbsite_cooperado_cdc.dslink_google_maps%TYPE --> Link da localizacao no google maps
															,pr_xmllog             IN VARCHAR2 --> XML com informacoes de LOG
															,pr_cdcritic          OUT PLS_INTEGER --> Codigo da critica
															,pr_dscritic          OUT VARCHAR2 --> Descricao da critica
															,pr_retxml         IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
															,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
															,pr_des_erro          OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_filial(pr_idmatriz     IN tbsite_cooperado_cdc.idmatriz%TYPE
                           ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_exclui_filial(pr_nrdconta        IN crapcdr.nrdconta%TYPE --> Numero da conta
                            ,pr_idmatriz        IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE
                            ,pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE
                            ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro       OUT VARCHAR2); --> Erros do processo

	PROCEDURE pc_replica_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa
		                      ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Conta
													,pr_cdoperad IN crapope.cdoperad%TYPE   --> Operador
													,pr_idorigem IN INTEGER                 --> Origem
													,pr_nmdatela IN VARCHAR2                --> Nome da tela
													,pr_flendere IN INTEGER                 --> Flag replicar endereço
													,pr_fltelefo IN INTEGER                 --> Flag replicar telefone
													,pr_flgemail IN INTEGER                 --> Flag replicar email
													,pr_flnmfant IN INTEGER                 --> Flag replicar nome fantasia
													,pr_cdcritic OUT PLS_INTEGER            --> Cód. da crítica
													,pr_dscritic OUT VARCHAR2);             --> Descrição da crítica

	PROCEDURE pc_busca_codigo_cidade(pr_nmcidade IN crapenc.nmcidade%TYPE --> Cidade
																	,pr_cdufende IN crapenc.cdufende%TYPE --> UF
																	,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
																	,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
																	,pr_dscritic OUT VARCHAR2             --> Descricao da critica
																	,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2);           --> Erros do processo

	PROCEDURE pc_busca_informacoes_cadastro(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta
		                                     ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
																				 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
																				 ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
																				 ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
																				 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
																				 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

END TELA_ATENDA_CVNCDC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_CVNCDC IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_CVNCDC
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Agosto - 2016                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela Convenio CDC
  --
  -- Alteracoes: 19/01/2016 - Adicionadas procedures para replicação dos dados
  --						  cadastrais do cooperado para o CDC. (Reinert)
  --
  ---------------------------------------------------------------------------
  
  -- Definicao do tipo de registro
  TYPE typ_reg_cdr_cdc IS
  RECORD (flgconve           crapcdr.flgconve%TYPE
         ,dtinicon           crapcdr.dtinicon%TYPE
         ,idcooperado_cdc    tbsite_cooperado_cdc.idcooperado_cdc%TYPE
         ,nmfantasia         tbsite_cooperado_cdc.nmfantasia%TYPE
         ,cdcnae             tbsite_cooperado_cdc.cdcnae%TYPE
         ,dslogradouro       tbsite_cooperado_cdc.dslogradouro%TYPE
         ,dscomplemento      tbsite_cooperado_cdc.dscomplemento%TYPE
         ,idcidade           tbsite_cooperado_cdc.idcidade%TYPE
         ,nmbairro           tbsite_cooperado_cdc.nmbairro%TYPE
         ,nrendereco         tbsite_cooperado_cdc.nrendereco%TYPE
         ,nrcep              tbsite_cooperado_cdc.nrcep%TYPE
         ,dstelefone         tbsite_cooperado_cdc.dstelefone%TYPE
         ,dsemail            tbsite_cooperado_cdc.dsemail%TYPE
         ,dslink_google_maps tbsite_cooperado_cdc.dslink_google_maps%TYPE);

  -- Definicao do tipo de tabela registro
  TYPE typ_tab_cdr_cdc IS TABLE OF typ_reg_cdr_cdc INDEX BY PLS_INTEGER;

  -- Vetor para armazenar os dados da tabela
  vr_tab_cdr_cdc typ_tab_cdr_cdc;

  -- Busca o nome
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;

  PROCEDURE pc_carrega_dados(pr_cdcooper        IN crapcdr.cdcooper%TYPE --> Codigo da cooperativa
                            ,pr_nrdconta        IN crapcdr.nrdconta%TYPE --> Numero da conta
                            ,pr_idmatriz        IN tbsite_cooperado_cdc.idmatriz%TYPE
                            ,pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE
                          	,pr_tab_cdr_cdc    OUT typ_tab_cdr_cdc --> PLTABLE com os dados
                            ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic       OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_carrega_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Agosto/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_crapcdr(pr_cdcooper IN crapcdr.cdcooper%TYPE
                       ,pr_nrdconta IN crapcdr.nrdconta%TYPE) IS
        SELECT crapcdr.flgconve
              ,crapcdr.dtinicon
          FROM crapcdr
         WHERE crapcdr.cdcooper = pr_cdcooper
           AND crapcdr.nrdconta = pr_nrdconta;
      rw_crapcdr cr_crapcdr%ROWTYPE;

      -- Selecionar os dados para o site da cooperativa
      CURSOR cr_tbsite_cooperado_cdc(pr_cdcooper        IN tbsite_cooperado_cdc.cdcooper%TYPE
                                    ,pr_nrdconta        IN tbsite_cooperado_cdc.nrdconta%TYPE
                                    ,pr_idmatriz        IN tbsite_cooperado_cdc.idmatriz%TYPE
                                    ,pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE) IS
        SELECT t.idcooperado_cdc
              ,t.nmfantasia
              ,t.cdcnae
              ,t.dslogradouro
              ,t.dscomplemento
              ,t.idcidade
              ,t.nmbairro
              ,t.nrendereco
              ,t.nrcep
              ,t.dstelefone
              ,t.dsemail
              ,t.dslink_google_maps
          FROM tbsite_cooperado_cdc t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND ((pr_idmatriz = 0 AND t.idmatriz IS NULL) OR
                (pr_idmatriz = t.idmatriz AND t.idcooperado_cdc = pr_idcooperado_cdc));
      rw_tbsite_cooperado_cdc cr_tbsite_cooperado_cdc%ROWTYPE;
      
      -- Variaveis Gerais
      vr_blnfound BOOLEAN;

    BEGIN
      -- Limpa PLTABLE
      pr_tab_cdr_cdc.DELETE;

      -- Selecionar os dados
      OPEN cr_crapcdr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcdr INTO rw_crapcdr;
      -- Alimenta a booleana
      vr_blnfound := cr_crapcdr%FOUND;
      -- Fechar o cursor
      CLOSE cr_crapcdr;

      -- Se encontrou
      IF vr_blnfound THEN

        -- Carrega os dados na PLTRABLE
        pr_tab_cdr_cdc(pr_nrdconta).flgconve := rw_crapcdr.flgconve;
        pr_tab_cdr_cdc(pr_nrdconta).dtinicon := rw_crapcdr.dtinicon;

        -- Selecionar os dados para o site da cooperativa
        OPEN cr_tbsite_cooperado_cdc(pr_cdcooper	      => pr_cdcooper
                                    ,pr_nrdconta        => pr_nrdconta
                                    ,pr_idmatriz        => pr_idmatriz
                                    ,pr_idcooperado_cdc => pr_idcooperado_cdc);
        FETCH cr_tbsite_cooperado_cdc INTO rw_tbsite_cooperado_cdc;
        -- Alimenta a booleana
        vr_blnfound := cr_tbsite_cooperado_cdc%FOUND;
        -- Fechar o cursor
        CLOSE cr_tbsite_cooperado_cdc;

        -- Se encontrou
        IF vr_blnfound THEN

          -- Carrega os dados na PLTRABLE
          pr_tab_cdr_cdc(pr_nrdconta).idcooperado_cdc    := rw_tbsite_cooperado_cdc.idcooperado_cdc;
          pr_tab_cdr_cdc(pr_nrdconta).nmfantasia         := rw_tbsite_cooperado_cdc.nmfantasia;
          pr_tab_cdr_cdc(pr_nrdconta).cdcnae             := rw_tbsite_cooperado_cdc.cdcnae;
          pr_tab_cdr_cdc(pr_nrdconta).dslogradouro       := rw_tbsite_cooperado_cdc.dslogradouro;
          pr_tab_cdr_cdc(pr_nrdconta).dscomplemento      := rw_tbsite_cooperado_cdc.dscomplemento;
          pr_tab_cdr_cdc(pr_nrdconta).idcidade           := rw_tbsite_cooperado_cdc.idcidade;
          pr_tab_cdr_cdc(pr_nrdconta).nmbairro           := rw_tbsite_cooperado_cdc.nmbairro;
          pr_tab_cdr_cdc(pr_nrdconta).nrendereco         := rw_tbsite_cooperado_cdc.nrendereco;
          pr_tab_cdr_cdc(pr_nrdconta).nrcep              := rw_tbsite_cooperado_cdc.nrcep;
          pr_tab_cdr_cdc(pr_nrdconta).dstelefone         := rw_tbsite_cooperado_cdc.dstelefone;
          pr_tab_cdr_cdc(pr_nrdconta).dsemail            := rw_tbsite_cooperado_cdc.dsemail;
          pr_tab_cdr_cdc(pr_nrdconta).dslink_google_maps := rw_tbsite_cooperado_cdc.dslink_google_maps;

        END IF;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;
    END;

  END pc_carrega_dados;

  PROCEDURE pc_busca_dados(pr_nrdconta        IN crapcdr.nrdconta%TYPE --> Numero da conta
                          ,pr_inpessoa        IN crapass.inpessoa%TYPE --> Tipo de pessoa
                          ,pr_idmatriz        IN tbsite_cooperado_cdc.idmatriz%TYPE
                          ,pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE
                          ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro       OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Agosto/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar o CNAE
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.cdclcnae
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;    
    
      -- Selecionar a UF
      CURSOR cr_crapenc(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE
                       ,pr_tpendass IN crapenc.tpendass%TYPE) IS
        SELECT crapenc.cdufende
          FROM crapenc
         WHERE crapenc.cdcooper = pr_cdcooper
           AND crapenc.nrdconta = pr_nrdconta
           AND crapenc.tpendass = pr_tpendass;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis Gerais
      vr_cdclcnae crapass.cdclcnae%TYPE;
      vr_cdufende crapenc.cdufende%TYPE;

      -- Vetor para armazenar os dados da tabela
      vr_tab_crapmun CADA0003.typ_tab_crapmun;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      -- Selecionar a UF
      OPEN cr_crapenc(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_tpendass => (CASE WHEN pr_inpessoa = 1 THEN 10 ELSE 9 END)); -- PF: 10-Residencial / PJ: 9-Comercial
      FETCH cr_crapenc INTO vr_cdufende;
      CLOSE cr_crapenc;

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cdufende'
                            ,pr_tag_cont => vr_cdufende
                            ,pr_des_erro => vr_dscritic);

      -- Carrega os dados
      pc_carrega_dados(pr_cdcooper        => vr_cdcooper
                      ,pr_nrdconta        => pr_nrdconta
                      ,pr_idmatriz        => pr_idmatriz
                      ,pr_idcooperado_cdc => pr_idcooperado_cdc
                      ,pr_tab_cdr_cdc     => vr_tab_cdr_cdc
                      ,pr_cdcritic        => vr_cdcritic
                      ,pr_dscritic        => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Se encontrou registro
      IF vr_tab_cdr_cdc.EXISTS(pr_nrdconta) THEN

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flgconve'
                              ,pr_tag_cont => NVL(vr_tab_cdr_cdc(pr_nrdconta).flgconve, 0)
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dtinicon'
                              ,pr_tag_cont => TO_CHAR(vr_tab_cdr_cdc(pr_nrdconta).dtinicon, 'DD/MM/RRRR')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idcooperado_cdc'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).idcooperado_cdc
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmfantasia'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).nmfantasia
                              ,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dslogradouro'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).dslogradouro
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dscomplemento'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).dscomplemento
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmbairro'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).nmbairro
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrendereco'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).nrendereco
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrcep'
                              ,pr_tag_cont => GENE0002.fn_mask(NVL(vr_tab_cdr_cdc(pr_nrdconta).nrcep, 0),'99.999-999')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dstelefone'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).dstelefone
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsemail'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).dsemail
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dslink_google_maps'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).dslink_google_maps
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idcidade'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).idcidade
                              ,pr_des_erro => vr_dscritic);

        -- Se possui cidade cadastrada
        IF vr_tab_cdr_cdc(pr_nrdconta).idcidade > 0 THEN

          -- Busca o nome da cidade
          CADA0003.pc_busca_cidades(pr_idcidade    => vr_tab_cdr_cdc(pr_nrdconta).idcidade
                                   ,pr_cdcidade    => 0
                                   ,pr_dscidade    => ''
                                   ,pr_cdestado    => ''
                                   ,pr_infiltro    => 1 -- CETIP
                                   ,pr_intipnom    => 1 -- SEM ACENTUACAO
                                   ,pr_tab_crapmun => vr_tab_crapmun
                                   ,pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic);
          -- Se retornou erro
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Se encontrou
          IF vr_tab_crapmun.COUNT > 0 THEN

            GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'dscidade'
                                  ,pr_tag_cont => vr_tab_crapmun(1).dscidade
                                  ,pr_des_erro => vr_dscritic);

            GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'cdestado'
                                  ,pr_tag_cont => vr_tab_crapmun(1).cdestado
                                  ,pr_des_erro => vr_dscritic);

          END IF;

        END IF; -- rw_tbsite_cooperado_cdc.idcidade > 0

        -- Se for PF busca o CNAE da tbsite_cooperado_cdc
        IF pr_inpessoa = 1 THEN
          vr_cdclcnae := vr_tab_cdr_cdc(pr_nrdconta).cdcnae;
        END IF;

      END IF; -- vr_tab_cdr_cdc.EXISTS(pr_nrdconta)

      -- Se for PJ busca o CNAE da crapass
      IF pr_inpessoa = 2 THEN
        -- Selecionar o CNAE
        OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass INTO vr_cdclcnae;
        CLOSE cr_crapass;
      END IF;

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cdcnae'
                            ,pr_tag_cont => vr_cdclcnae
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_dados;

  PROCEDURE pc_grava_dados(pr_cdcooper           IN crapcop.cdcooper%TYPE --> Cód da cooperativa
		                      ,pr_cdoperad           IN crapope.cdoperad%TYPE --> Operador
													,pr_idorigem           IN INTEGER               --> Origem
													,pr_nmdatela           IN VARCHAR2              -- Nome da tela
		                      ,pr_nrdconta           IN crapcdr.nrdconta%TYPE --> Numero da conta
                          ,pr_inpessoa           IN crapass.inpessoa%TYPE --> Tipo de pessoa
                          ,pr_idmatriz           IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE --> Identificador da Matriz
                          ,pr_idcooperado_cdc    IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE --> Identificador do cooperado no CDC
                          ,pr_flgconve           IN crapcdr.flgconve%TYPE --> Indicador se cooperado possui convenio CDC
                          ,pr_dtinicon           IN VARCHAR2 --> Data de inicio de convenio
                          ,pr_nmfantasia         IN tbsite_cooperado_cdc.nmfantasia%TYPE --> Nome fantasia
                          ,pr_cdcnae             IN tbsite_cooperado_cdc.cdcnae%TYPE --> Codigo da classificacao CNAE
                          ,pr_dslogradouro       IN tbsite_cooperado_cdc.dslogradouro%TYPE --> Descricao do logradouro
                          ,pr_dscomplemento      IN tbsite_cooperado_cdc.dscomplemento%TYPE --> Complemento da localizacao
                          ,pr_nrendereco         IN tbsite_cooperado_cdc.nrendereco%TYPE --> Numero do endereco da localizacao
                          ,pr_nmbairro           IN tbsite_cooperado_cdc.nmbairro%TYPE --> Bairro da localizacao
                          ,pr_nrcep              IN tbsite_cooperado_cdc.nrcep%TYPE --> CEP da localizacao
                          ,pr_idcidade           IN tbsite_cooperado_cdc.idcidade%TYPE --> Codigo da cidade da localizacao
                          ,pr_dstelefone         IN tbsite_cooperado_cdc.dstelefone%TYPE --> Telefone do conveniado CDC
                          ,pr_dsemail            IN tbsite_cooperado_cdc.dsemail%TYPE --> E-mail de contato
                          ,pr_dslink_google_maps IN tbsite_cooperado_cdc.dslink_google_maps%TYPE --> Link da localizacao no google maps
                          ,pr_cdcritic          OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic          OUT VARCHAR2 --> Descricao da critica
                          ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Agosto/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para cadastrar os dados do Convenio CDC.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Seleciona o CNAE
      CURSOR cr_tbgen_cnae(pr_cdcnae IN tbgen_cnae.cdcnae%TYPE) IS
        SELECT GENE0007.fn_caract_acento(dscnae) dscnae
          FROM tbgen_cnae
         WHERE cdcnae = pr_cdcnae;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
      -- Variaveis
      vr_idcooperado_cdc    tbsite_cooperado_cdc.idcooperado_cdc%TYPE;
      vr_nrendereco         tbsite_cooperado_cdc.nrendereco%TYPE;
      vr_nrcep              tbsite_cooperado_cdc.nrcep%TYPE;
      vr_idcidade           tbsite_cooperado_cdc.idcidade%TYPE;
      vr_cdcnae             tbsite_cooperado_cdc.cdcnae%TYPE;
      vr_dslink_google_maps tbsite_cooperado_cdc.dslink_google_maps%TYPE;
      vr_dscnae_new         tbgen_cnae.dscnae%TYPE;
      vr_dscnae_old         tbgen_cnae.dscnae%TYPE;
      vr_dscidade_new       crapmun.dscidade%TYPE;
      vr_dscidade_old       crapmun.dscidade%TYPE;
      vr_nmrescop           crapcop.nmrescop%TYPE;
      vr_dtinicon_old       VARCHAR2(10);
      vr_dsconteudo_mail    VARCHAR2(10000) := '';
      vr_emaildst           VARCHAR2(4000);
      vr_rowid              ROWID;

      -- Vetor para armazenar os dados da tabela
      vr_tab_crapmun CADA0003.typ_tab_crapmun;

    BEGIN
      -- Seta as variaveis
      vr_cdcnae     := (CASE WHEN pr_inpessoa = 1 AND pr_idmatriz = 0 THEN pr_cdcnae ELSE NULL END);
      vr_nrcep      := (CASE WHEN pr_nrcep = 0      THEN NULL ELSE pr_nrcep      END);
      vr_idcidade   := (CASE WHEN pr_idcidade = 0   THEN NULL ELSE pr_idcidade   END);
      vr_nrendereco := (CASE WHEN pr_nrendereco = 0 THEN NULL ELSE pr_nrendereco END);

      -- Carrega os dados
      pc_carrega_dados(pr_cdcooper        => pr_cdcooper
                      ,pr_nrdconta        => pr_nrdconta
                      ,pr_idmatriz        => pr_idmatriz
                      ,pr_idcooperado_cdc => pr_idcooperado_cdc
                      ,pr_tab_cdr_cdc     => vr_tab_cdr_cdc
                      ,pr_cdcritic        => vr_cdcritic
                      ,pr_dscritic        => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Se NAO encontrou registro, cria um vazio
      IF NOT vr_tab_cdr_cdc.EXISTS(pr_nrdconta) THEN
        vr_tab_cdr_cdc(pr_nrdconta).flgconve := 0;
      END IF;

      -- Insere ou atualiza os dados
      BEGIN
        INSERT INTO crapcdr
                   (cdcooper
                   ,nrdconta
                   ,flgconve
                   ,dtinicon
                   ,cdoperad)
             VALUES(pr_cdcooper
                   ,pr_nrdconta
                   ,pr_flgconve
                   ,TO_DATE(pr_dtinicon, 'DD/MM/RRRR')
                   ,pr_cdoperad);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          -- Se ja existir atualiza
          UPDATE crapcdr
             SET crapcdr.flgconve = pr_flgconve
                ,crapcdr.dtinicon = TO_DATE(pr_dtinicon, 'DD/MM/RRRR')
                ,crapcdr.cdoperad = pr_cdoperad
           WHERE crapcdr.cdcooper = pr_cdcooper
             AND crapcdr.nrdconta = pr_nrdconta;

        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao gravar dados: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Seta o ID do registro
      vr_idcooperado_cdc := pr_idcooperado_cdc;

      -- Insere ou atualiza os dados para o site
      BEGIN
        -- Se for um registro novo
        IF vr_idcooperado_cdc = 0 THEN
          INSERT INTO tbsite_cooperado_cdc
                     (cdcooper
                     ,nrdconta
                     ,idmatriz
                     ,nmfantasia)
               VALUES(pr_cdcooper
                     ,pr_nrdconta
                     ,DECODE(pr_idmatriz, 0, NULL, pr_idmatriz)
                     ,pr_nmfantasia)
            RETURNING idcooperado_cdc 
                 INTO vr_idcooperado_cdc;
        END IF;

        -- Remove o CDATA da String
        vr_dslink_google_maps := GENE0007.fn_remove_cdata(pr_dslink_google_maps);

        -- Grava os demais dados
        UPDATE tbsite_cooperado_cdc t
           SET t.nmfantasia = pr_nmfantasia
              ,t.cdcnae = vr_cdcnae
              ,t.dslogradouro = pr_dslogradouro
              ,t.dscomplemento = pr_dscomplemento
              ,t.idcidade = vr_idcidade
              ,t.nmbairro = pr_nmbairro
              ,t.nrendereco = vr_nrendereco
              ,t.nrcep = vr_nrcep
              ,t.dstelefone = pr_dstelefone
              ,t.dsemail = pr_dsemail
              ,t.dslink_google_maps = vr_dslink_google_maps
         WHERE t.idcooperado_cdc = vr_idcooperado_cdc;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao gravar dados: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      -- Verifica as diferencas
      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).flgconve, '0') <> NVL(pr_flgconve, '0') THEN
        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>Possui Convênio CDC:</b> de '''
                           || (CASE WHEN vr_tab_cdr_cdc(pr_nrdconta).flgconve = 0 THEN 'Não' ELSE 'Sim' END)
                           || ''' para '''
                           || (CASE WHEN pr_flgconve = 0 THEN 'Não' ELSE 'Sim' END)
                           || '''<br>';
      END IF;

      vr_dtinicon_old := TO_CHAR(vr_tab_cdr_cdc(pr_nrdconta).dtinicon, 'DD/MM/RRRR');
      IF NVL(vr_dtinicon_old, ' ') <> NVL(pr_dtinicon, ' ') THEN
        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>Data Início Convênio:</b> de ''' || vr_dtinicon_old
                           || ''' para ''' || pr_dtinicon || '''<br>';
      END IF;

      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).nmfantasia, ' ') <> NVL(pr_nmfantasia, ' ') THEN
        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>Nome fantasia:</b> de ''' || vr_tab_cdr_cdc(pr_nrdconta).nmfantasia
                           || ''' para ''' || pr_nmfantasia || '''<br>';
      END IF;

      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).cdcnae, '0') <> NVL(vr_cdcnae, '0') THEN
        -- Velho CNAE
        OPEN cr_tbgen_cnae(pr_cdcnae => vr_tab_cdr_cdc(pr_nrdconta).cdcnae);
        FETCH cr_tbgen_cnae INTO vr_dscnae_old;
        CLOSE cr_tbgen_cnae;

        -- Novo CNAE
        OPEN cr_tbgen_cnae(pr_cdcnae => vr_cdcnae);
        FETCH cr_tbgen_cnae INTO vr_dscnae_new;
        CLOSE cr_tbgen_cnae;

        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>CNAE:</b> de ''' || vr_dscnae_old
                           || ''' para ''' || vr_dscnae_new || '''<br>';
      END IF;

      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).dslogradouro, ' ') <> NVL(pr_dslogradouro, ' ') THEN
        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>Endereço:</b> de ''' || vr_tab_cdr_cdc(pr_nrdconta).dslogradouro
                           || ''' para ''' || pr_dslogradouro || '''<br>';
      END IF;

      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).dscomplemento, ' ') <> NVL(pr_dscomplemento, ' ') THEN
        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>Complemento:</b> de ''' || vr_tab_cdr_cdc(pr_nrdconta).dscomplemento
                           || ''' para ''' || pr_dscomplemento || '''<br>';
      END IF;

      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).nrendereco, '0') <> NVL(vr_nrendereco, '0') THEN
        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>Número:</b> de ''' || vr_tab_cdr_cdc(pr_nrdconta).nrendereco
                           || ''' para ''' || vr_nrendereco || '''<br>';
      END IF;

      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).nmbairro, ' ') <> NVL(pr_nmbairro, ' ') THEN
        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>Bairro:</b> de ''' || vr_tab_cdr_cdc(pr_nrdconta).nmbairro
                           || ''' para ''' || pr_nmbairro || '''<br>';
      END IF;

      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).nrcep, '0') <> NVL(vr_nrcep, '0') THEN
        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>CEP:</b> de ''' || vr_tab_cdr_cdc(pr_nrdconta).nrcep
                           || ''' para ''' || vr_nrcep || '''<br>';
      END IF;

      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).idcidade, '0') <> NVL(vr_idcidade, '0') THEN

        IF vr_tab_cdr_cdc(pr_nrdconta).idcidade > 0 THEN
          -- Busca o nome da cidade
          CADA0003.pc_busca_cidades(pr_idcidade    => vr_tab_cdr_cdc(pr_nrdconta).idcidade
                                   ,pr_cdcidade    => 0
                                   ,pr_dscidade    => ''
                                   ,pr_cdestado    => ''
                                   ,pr_infiltro    => 1 -- CETIP
                                   ,pr_intipnom    => 1 -- SEM ACENTUACAO
                                   ,pr_tab_crapmun => vr_tab_crapmun
                                   ,pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic);
          -- Se retornou erro
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Se encontrou
          IF vr_tab_crapmun.COUNT > 0 THEN
            vr_dscidade_old := vr_tab_crapmun(1).dscidade;
          END IF;
        END IF;

        IF vr_idcidade > 0 THEN
          -- Busca o nome da cidade
          CADA0003.pc_busca_cidades(pr_idcidade    => vr_idcidade
                                   ,pr_cdcidade    => 0
                                   ,pr_dscidade    => ''
                                   ,pr_cdestado    => ''
                                   ,pr_infiltro    => 1 -- CETIP
                                   ,pr_intipnom    => 1 -- SEM ACENTUACAO
                                   ,pr_tab_crapmun => vr_tab_crapmun
                                   ,pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic);
          -- Se retornou erro
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Se encontrou
          IF vr_tab_crapmun.COUNT > 0 THEN
            vr_dscidade_new := vr_tab_crapmun(1).dscidade;
          END IF;
        END IF;

        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>Cidade:</b> de ''' || vr_dscidade_old
                           || ''' para ''' || vr_dscidade_new || '''<br>';
      END IF;

      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).dstelefone, ' ') <> NVL(pr_dstelefone, ' ') THEN
        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>Telefone:</b> de ''' || vr_tab_cdr_cdc(pr_nrdconta).dstelefone
                           || ''' para ''' || pr_dstelefone || '''<br>';
      END IF;

      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).dsemail, ' ') <> NVL(pr_dsemail, ' ') THEN
        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>E-mail:</b> de ''' || vr_tab_cdr_cdc(pr_nrdconta).dsemail
                           || ''' para ''' || pr_dsemail || '''<br>';
      END IF;

      IF NVL(vr_tab_cdr_cdc(pr_nrdconta).dslink_google_maps, ' ') <> NVL(vr_dslink_google_maps, ' ') THEN
        vr_dsconteudo_mail := vr_dsconteudo_mail
                           || '<b>Link Google Maps:</b> de ''' || vr_tab_cdr_cdc(pr_nrdconta).dslink_google_maps
                           || ''' para ''' || vr_dslink_google_maps || '''<br>';
      END IF;

      -- Caso algum campo foi alterado
      IF TRIM(vr_dsconteudo_mail) IS NOT NULL THEN

        -- Gerar LOG
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => GENE0001.vr_vet_des_origens(pr_idorigem)
                            ,pr_dstransa => 'Gravacao dados Convenio CDC.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 -- TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'CVNCDC'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_rowid);

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).flgconve, '0') <> NVL(pr_flgconve, '0') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'flgconve' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).flgconve
                                   ,pr_dsdadatu => pr_flgconve);
        END IF;

        IF NVL(vr_dtinicon_old, ' ') <> NVL(pr_dtinicon, ' ') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'dtinicon' 
                                   ,pr_dsdadant => vr_dtinicon_old
                                   ,pr_dsdadatu => pr_dtinicon);
        END IF;

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).nmfantasia, ' ') <> NVL(pr_nmfantasia, ' ') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'nmfantasia' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).nmfantasia
                                   ,pr_dsdadatu => pr_nmfantasia);
        END IF;

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).cdcnae, '0') <> NVL(vr_cdcnae, '0') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'cdcnae' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).cdcnae
                                   ,pr_dsdadatu => vr_cdcnae);
        END IF;

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).dslogradouro, ' ') <> NVL(pr_dslogradouro, ' ') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'dslogradouro' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).dslogradouro
                                   ,pr_dsdadatu => pr_dslogradouro);
        END IF;

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).dscomplemento, ' ') <> NVL(pr_dscomplemento, ' ') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'dscomplemento' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).dscomplemento
                                   ,pr_dsdadatu => pr_dscomplemento);
        END IF;

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).nrendereco, '0') <> NVL(vr_nrendereco, '0') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'nrendereco' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).nrendereco
                                   ,pr_dsdadatu => vr_nrendereco);
        END IF;

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).nmbairro, ' ') <> NVL(pr_nmbairro, ' ') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'nmbairro' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).nmbairro
                                   ,pr_dsdadatu => pr_nmbairro);
        END IF;

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).nrcep, '0') <> NVL(vr_nrcep, '0') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'nrcep' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).nrcep
                                   ,pr_dsdadatu => vr_nrcep);
        END IF;

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).idcidade, '0') <> NVL(vr_idcidade, '0') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'idcidade' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).idcidade
                                   ,pr_dsdadatu => vr_idcidade);
        END IF;

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).dstelefone, ' ') <> NVL(pr_dstelefone, ' ') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'dstelefone' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).dstelefone
                                   ,pr_dsdadatu => pr_dstelefone);
        END IF;

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).dsemail, ' ') <> NVL(pr_dsemail, ' ') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'dsemail' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).dsemail
                                   ,pr_dsdadatu => pr_dsemail);
        END IF;

        IF NVL(vr_tab_cdr_cdc(pr_nrdconta).dslink_google_maps, ' ') <> NVL(vr_dslink_google_maps, ' ') THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                   ,pr_nmdcampo => 'dslink_google_maps' 
                                   ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).dslink_google_maps
                                   ,pr_dsdadatu => vr_dslink_google_maps);
        END IF;
        
        -- Busca o nome
        OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop INTO vr_nmrescop;
        CLOSE cr_crapcop;

        -- Destinatarios das alteracoes dos dados para o site
        vr_emaildst :=  GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_cdacesso => 'EMAIL_ALT_DADOS_SITE_CDC');

        -- Adiciona cooperativa e conta
        vr_dsconteudo_mail := '<b>' || vr_nmrescop ||'</b><br>'
                           || '<b>Conta:</b> ' || pr_nrdconta 
                           || '<br><br>' || vr_dsconteudo_mail;

        -- Faz a solicitacao do envio do email
        GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => pr_nmdatela
                                  ,pr_des_destino     => vr_emaildst
                                  ,pr_des_assunto     => 'Alteração de dados do Convênio CDC'
                                  ,pr_des_corpo       => vr_dsconteudo_mail
                                  ,pr_des_anexo       => NULL
                                  ,pr_des_erro        => vr_dscritic);

        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END IF; -- TRIM(vr_dsconteudo_mail) IS NOT NULL

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
				-- Efetuar rollback
				ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;
				-- Efetuar rollback
				ROLLBACK;				
    END;

  END pc_grava_dados;

  PROCEDURE pc_grava_dados_web(pr_nrdconta           IN crapcdr.nrdconta%TYPE --> Numero da conta
															,pr_inpessoa           IN crapass.inpessoa%TYPE --> Tipo de pessoa
															,pr_idmatriz           IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE --> Identificador da Matriz
															,pr_idcooperado_cdc    IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE --> Identificador do cooperado no CDC
															,pr_flgconve           IN crapcdr.flgconve%TYPE --> Indicador se cooperado possui convenio CDC
															,pr_dtinicon           IN VARCHAR2 --> Data de inicio de convenio
															,pr_nmfantasia         IN tbsite_cooperado_cdc.nmfantasia%TYPE --> Nome fantasia
															,pr_cdcnae             IN tbsite_cooperado_cdc.cdcnae%TYPE --> Codigo da classificacao CNAE
															,pr_dslogradouro       IN tbsite_cooperado_cdc.dslogradouro%TYPE --> Descricao do logradouro
															,pr_dscomplemento      IN tbsite_cooperado_cdc.dscomplemento%TYPE --> Complemento da localizacao
															,pr_nrendereco         IN tbsite_cooperado_cdc.nrendereco%TYPE --> Numero do endereco da localizacao
															,pr_nmbairro           IN tbsite_cooperado_cdc.nmbairro%TYPE --> Bairro da localizacao
															,pr_nrcep              IN tbsite_cooperado_cdc.nrcep%TYPE --> CEP da localizacao
															,pr_idcidade           IN tbsite_cooperado_cdc.idcidade%TYPE --> Codigo da cidade da localizacao
															,pr_dstelefone         IN tbsite_cooperado_cdc.dstelefone%TYPE --> Telefone do conveniado CDC
															,pr_dsemail            IN tbsite_cooperado_cdc.dsemail%TYPE --> E-mail de contato
															,pr_dslink_google_maps IN tbsite_cooperado_cdc.dslink_google_maps%TYPE --> Link da localizacao no google maps
															,pr_xmllog             IN VARCHAR2 --> XML com informacoes de LOG
															,pr_cdcritic          OUT PLS_INTEGER --> Codigo da critica
															,pr_dscritic          OUT VARCHAR2 --> Descricao da critica
															,pr_retxml         IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
															,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
															,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Agosto/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para cadastrar os dados do Convenio CDC.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis
      vr_idcooperado_cdc    tbsite_cooperado_cdc.idcooperado_cdc%TYPE;
      vr_nrendereco         tbsite_cooperado_cdc.nrendereco%TYPE;
      vr_nrcep              tbsite_cooperado_cdc.nrcep%TYPE;
      vr_idcidade           tbsite_cooperado_cdc.idcidade%TYPE;
      vr_cdcnae             tbsite_cooperado_cdc.cdcnae%TYPE;
      vr_dslink_google_maps tbsite_cooperado_cdc.dslink_google_maps%TYPE;
      vr_dscnae_new         tbgen_cnae.dscnae%TYPE;
      vr_dscnae_old         tbgen_cnae.dscnae%TYPE;
      vr_dscidade_new       crapmun.dscidade%TYPE;
      vr_dscidade_old       crapmun.dscidade%TYPE;
      vr_nmrescop           crapcop.nmrescop%TYPE;
      vr_dtinicon_old       VARCHAR2(10);
      vr_dsconteudo_mail    VARCHAR2(10000) := '';
      vr_emaildst           VARCHAR2(4000);
      vr_rowid              ROWID;

      -- Vetor para armazenar os dados da tabela
      vr_tab_crapmun CADA0003.typ_tab_crapmun;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Se NAO foi informado nome fantasia e ativar
      IF TRIM(pr_dtinicon) IS NULL AND pr_flgconve = 1 THEN
        vr_dscritic := 'Informe a data de início do convênio.';
        RAISE vr_exc_erro;
      END IF;

      -- Se NAO foi informado nome fantasia e ativar
      IF TRIM(pr_nmfantasia) IS NULL AND pr_flgconve = 1 THEN
        vr_dscritic := 'Informe o nome fantasia.';
        RAISE vr_exc_erro;
      END IF;

      -- Seta as variaveis
      vr_cdcnae     := (CASE WHEN pr_inpessoa = 1 AND pr_idmatriz = 0 THEN pr_cdcnae ELSE NULL END);
      vr_nrcep      := (CASE WHEN pr_nrcep = 0      THEN NULL ELSE pr_nrcep      END);
      vr_idcidade   := (CASE WHEN pr_idcidade = 0   THEN NULL ELSE pr_idcidade   END);
      vr_nrendereco := (CASE WHEN pr_nrendereco = 0 THEN NULL ELSE pr_nrendereco END);

      -- Se for PJ e Matriz e NAO foi informado CNAE e ativar
      IF pr_inpessoa = 1 AND pr_idmatriz = 0 AND vr_cdcnae IS NULL AND pr_flgconve = 1 THEN
        vr_dscritic := 'Informe o nome CNAE.';
        RAISE vr_exc_erro;
      END IF;

      pc_grava_dados(pr_cdcooper => vr_cdcooper
										,pr_cdoperad => vr_cdoperad
										,pr_idorigem => vr_idorigem
										,pr_nmdatela => vr_nmdatela
										,pr_nrdconta => pr_nrdconta
										,pr_inpessoa => pr_inpessoa
										,pr_idmatriz => pr_idmatriz
										,pr_idcooperado_cdc => pr_idcooperado_cdc
										,pr_flgconve => pr_flgconve
										,pr_dtinicon => pr_dtinicon
										,pr_nmfantasia => pr_nmfantasia
										,pr_cdcnae => pr_cdcnae
										,pr_dslogradouro => pr_dslogradouro
										,pr_dscomplemento => pr_dscomplemento
										,pr_nrendereco => pr_nrendereco
										,pr_nmbairro => pr_nmbairro
										,pr_nrcep => pr_nrcep
										,pr_idcidade => pr_idcidade
										,pr_dstelefone => pr_dstelefone
										,pr_dsemail => pr_dsemail
										,pr_dslink_google_maps => pr_dslink_google_maps 
										,pr_cdcritic => vr_cdcritic
										,pr_dscritic => vr_dscritic
										,pr_nmdcampo => pr_nmdcampo
										,pr_des_erro => pr_des_erro);

      -- Se houver alguma crítica
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_grava_dados_web;

  PROCEDURE pc_busca_filial(pr_idmatriz     IN tbsite_cooperado_cdc.idmatriz%TYPE
                           ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_filial
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Agosto/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as filiais.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar as filiais
      CURSOR cr_tbsite_cooperado_cdc(pr_idmatriz IN tbsite_cooperado_cdc.idmatriz%TYPE) IS
        SELECT t.idcooperado_cdc
              ,t.nmfantasia
              ,t.idcidade
              ,t.nmbairro
          FROM tbsite_cooperado_cdc t
         WHERE t.idmatriz = pr_idmatriz;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
      -- Variaveis Gerais
      vr_contador INTEGER := 0;

      -- Vetor para armazenar os dados da tabela
      vr_tab_crapmun CADA0003.typ_tab_crapmun;

    BEGIN

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de riscos
      FOR rw_tbsite_cooperado_cdc IN cr_tbsite_cooperado_cdc(pr_idmatriz => pr_idmatriz) LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'filial'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'filial'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'idcooperado_cdc'
                              ,pr_tag_cont => rw_tbsite_cooperado_cdc.idcooperado_cdc
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'filial'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nmfantasia'
                              ,pr_tag_cont => rw_tbsite_cooperado_cdc.nmfantasia
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'filial'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nmbairro'
                              ,pr_tag_cont => rw_tbsite_cooperado_cdc.nmbairro
                              ,pr_des_erro => vr_dscritic);

        -- Se possui cidade cadastrada
        IF rw_tbsite_cooperado_cdc.idcidade > 0 THEN

          -- Busca o nome da cidade
          CADA0003.pc_busca_cidades(pr_idcidade    => rw_tbsite_cooperado_cdc.idcidade
                                   ,pr_cdcidade    => 0
                                   ,pr_dscidade    => ''
                                   ,pr_cdestado    => ''
                                   ,pr_infiltro    => 1 -- CETIP
                                   ,pr_intipnom    => 1 -- SEM ACENTUACAO
                                   ,pr_tab_crapmun => vr_tab_crapmun
                                   ,pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic);
          -- Se retornou erro
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Se encontrou
          IF vr_tab_crapmun.COUNT > 0 THEN
            GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'filial'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dscidade'
                                  ,pr_tag_cont => vr_tab_crapmun(1).dscidade
                                  ,pr_des_erro => vr_dscritic);
          END IF;

        END IF;

        vr_contador := vr_contador + 1;
      END LOOP;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_filial;

  PROCEDURE pc_exclui_filial(pr_nrdconta        IN crapcdr.nrdconta%TYPE --> Numero da conta
                            ,pr_idmatriz        IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE
                            ,pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE
                            ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro       OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_exclui_filial
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Agosto/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir a filial.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis
      vr_nmrescop        crapcop.nmrescop%TYPE;
      vr_dsconteudo_mail VARCHAR2(10000) := '';
      vr_emaildst        VARCHAR2(4000);
      vr_rowid           ROWID;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Carrega os dados
      pc_carrega_dados(pr_cdcooper        => vr_cdcooper
                      ,pr_nrdconta        => pr_nrdconta
                      ,pr_idmatriz        => pr_idmatriz
                      ,pr_idcooperado_cdc => pr_idcooperado_cdc
                      ,pr_tab_cdr_cdc     => vr_tab_cdr_cdc
                      ,pr_cdcritic        => vr_cdcritic
                      ,pr_dscritic        => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      BEGIN
        -- Exclui a filial
        DELETE FROM tbsite_cooperado_cdc
              WHERE tbsite_cooperado_cdc.idcooperado_cdc = pr_idcooperado_cdc;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao excluir filial: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Gerar LOG
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                          ,pr_dstransa => 'Exclusao filial Convenio CDC.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 -- TRUE
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CVNCDC'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_rowid);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                               ,pr_nmdcampo => 'nmfantasia' 
                               ,pr_dsdadant => vr_tab_cdr_cdc(pr_nrdconta).nmfantasia
                               ,pr_dsdadatu => ' ');

      -- Busca o nome
      OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
      FETCH cr_crapcop INTO vr_nmrescop;
      CLOSE cr_crapcop;

      -- Destinatarios das alteracoes dos dados para o site
      vr_emaildst :=  GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => vr_cdcooper
                                               ,pr_cdacesso => 'EMAIL_ALT_DADOS_SITE_CDC');

      -- Adiciona cooperativa e conta
      vr_dsconteudo_mail := '<b>' || vr_nmrescop ||'</b><br>'
                         || '<b>Conta:</b> ' || pr_nrdconta 
                         || '<br><br><b>Nome fantasia:</b> ' || vr_tab_cdr_cdc(pr_nrdconta).nmfantasia;

      -- Faz a solicitacao do envio do email
      GENE0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                                ,pr_cdprogra        => vr_nmdatela
                                ,pr_des_destino     => vr_emaildst
                                ,pr_des_assunto     => 'Exclusão de filial do Convênio CDC'
                                ,pr_des_corpo       => vr_dsconteudo_mail
                                ,pr_des_anexo       => NULL
                                ,pr_des_erro        => vr_dscritic);

      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_exclui_filial;

  PROCEDURE pc_busca_endereco_cdc(pr_cdcooper IN crapenc.cdcooper%TYPE
		                             ,pr_nrdconta IN crapenc.nrdconta%TYPE
																 ,pr_info_cdc IN OUT typ_reg_info_cdc
																 ,pr_cdcritic OUT crapcri.cdcritic%TYPE
																 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
  /* .............................................................................

    Programa: pc_busca_endereco_cdc
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar informações de endereço da conta para o cdc

    Alteracoes: -----
    ..............................................................................*/																	 
		DECLARE
    
		  vr_exc_erro EXCEPTION;
			
			vr_cdcritic NUMBER;
			vr_dscritic VARCHAR2(4000);
		
		  -- Busca endereço do cooperado
		  CURSOR cr_crapenc(pr_cdcooper IN crapenc.cdcooper%TYPE
			                 ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
			  SELECT enc.dsendere
							,enc.nrendere
							,enc.complend
							,enc.nmbairro
							,enc.nrcepend
							,enc.nmcidade
							,enc.cdufende
					FROM crapenc enc
				 WHERE enc.cdcooper = pr_cdcooper
					 AND enc.nrdconta = pr_nrdconta
					 AND enc.idseqttl = 1
					 AND enc.tpendass = 9 /* Comercial */
			ORDER BY cdseqinc;
      rw_crapenc cr_crapenc%ROWTYPE;
		BEGIN
		  -- Busca endereço
		  OPEN cr_crapenc(pr_cdcooper => pr_cdcooper
			               ,pr_nrdconta => pr_nrdconta);
		  FETCH cr_crapenc INTO rw_crapenc;
			
			pr_info_cdc.dsendere := rw_crapenc.dsendere;
			pr_info_cdc.nrendere := rw_crapenc.nrendere;
      pr_info_cdc.complend := rw_crapenc.complend;
      pr_info_cdc.nmbairro := rw_crapenc.nmbairro;
      pr_info_cdc.nrcepend := rw_crapenc.nrcepend;
      pr_info_cdc.nmcidade := rw_crapenc.nmcidade;
      pr_info_cdc.cdufende := rw_crapenc.cdufende;
			pr_info_cdc.idcidade := cada0003.fn_busca_codigo_cidade(pr_cdestado => rw_crapenc.cdufende
	                                                           ,pr_dscidade => rw_crapenc.nmcidade);
					
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

    END;		
	END pc_busca_endereco_cdc;
	
  PROCEDURE pc_busca_telefone_cdc(pr_cdcooper IN crapenc.cdcooper%TYPE
		                             ,pr_nrdconta IN crapenc.nrdconta%TYPE
																 ,pr_info_cdc IN OUT typ_reg_info_cdc
																 ,pr_cdcritic OUT crapcri.cdcritic%TYPE
																 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
  /* .............................................................................

    Programa: pc_busca_telefone_cdc
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar telefone da conta para o cdc

    Alteracoes: -----
    ..............................................................................*/																	 
		DECLARE
    
		  vr_exc_erro EXCEPTION;
			
			vr_cdcritic NUMBER;
			vr_dscritic VARCHAR2(4000);
		
		  -- Busca telefone do cooperado
		  CURSOR cr_craptfc(pr_cdcooper IN crapenc.cdcooper%TYPE
			                 ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
				SELECT '('||lpad(tfc.nrdddtfc,2,'0')||') '|| tfc.nrtelefo nrtelefo
				  FROM craptfc tfc
				 WHERE tfc.cdcooper = pr_cdcooper
					 AND tfc.nrdconta = pr_nrdconta
					 AND tfc.idseqttl = 1
					 AND tfc.tptelefo = 3 /* Comercial */
			ORDER BY tfc.cdseqtfc;
      rw_craptfc cr_craptfc%ROWTYPE;
		BEGIN
		  -- Busca telefone
		  OPEN cr_craptfc(pr_cdcooper => pr_cdcooper
			               ,pr_nrdconta => pr_nrdconta);
		  FETCH cr_craptfc INTO rw_craptfc;
				
			pr_info_cdc.nrtelefo := rw_craptfc.nrtelefo;
					
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

    END;		
	END pc_busca_telefone_cdc;

  PROCEDURE pc_busca_email_cdc(pr_cdcooper IN crapenc.cdcooper%TYPE
														  ,pr_nrdconta IN crapenc.nrdconta%TYPE
														  ,pr_info_cdc IN OUT typ_reg_info_cdc
														  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
														  ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
  /* .............................................................................

    Programa: pc_busca_email_cdc
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar o email da conta para o cdc

    Alteracoes: -----
    ..............................................................................*/																	 
		DECLARE
    
		  vr_exc_erro EXCEPTION;
			
			vr_cdcritic NUMBER;
			vr_dscritic VARCHAR2(4000);
		
		  -- Busca email do cooperado
		  CURSOR cr_crapcem(pr_cdcooper IN crapenc.cdcooper%TYPE
			                 ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
				SELECT cem.dsdemail
					FROM crapcem cem
				 WHERE cem.cdcooper = pr_cdcooper
					 AND cem.nrdconta = pr_nrdconta
					 AND cem.idseqttl = 1;
      rw_crapcem cr_crapcem%ROWTYPE;
		BEGIN
		  -- Busca email
		  OPEN cr_crapcem(pr_cdcooper => pr_cdcooper
			               ,pr_nrdconta => pr_nrdconta);
		  FETCH cr_crapcem INTO rw_crapcem;
					
			pr_info_cdc.dsdemail := rw_crapcem.dsdemail;
					
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

    END;		
	END pc_busca_email_cdc;

  PROCEDURE pc_busca_nmfansia_cdc(pr_cdcooper IN crapenc.cdcooper%TYPE
														     ,pr_nrdconta IN crapenc.nrdconta%TYPE
														     ,pr_info_cdc IN OUT typ_reg_info_cdc
														     ,pr_cdcritic OUT crapcri.cdcritic%TYPE
														     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
  /* .............................................................................

    Programa: pc_busca_nmfansia_cdc
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar o nome fantasia da conta para o cdc

    Alteracoes: -----
    ..............................................................................*/																	 
		DECLARE
    
		  vr_exc_erro EXCEPTION;
			
			vr_cdcritic NUMBER;
			vr_dscritic VARCHAR2(4000);
		
		  -- Busca nome fantasia do cooperado
		  CURSOR cr_crapjur(pr_cdcooper IN crapenc.cdcooper%TYPE
			                 ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
				SELECT jur.nmfansia
					FROM crapjur jur
				 WHERE jur.cdcooper = pr_cdcooper
					 AND jur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
		BEGIN
		  -- Busca nome fantasia do cooperado
		  OPEN cr_crapjur(pr_cdcooper => pr_cdcooper
			               ,pr_nrdconta => pr_nrdconta);
		  FETCH cr_crapjur INTO rw_crapjur;
					
			pr_info_cdc.nmfansia := rw_crapjur.nmfansia;
					
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

    END;		
	END pc_busca_nmfansia_cdc;
	
	PROCEDURE pc_replica_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa
		                      ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Conta
													,pr_cdoperad IN crapope.cdoperad%TYPE   --> Operador
													,pr_idorigem IN INTEGER                 --> Origem
													,pr_nmdatela IN VARCHAR2                --> Nome da tela
													,pr_flendere IN INTEGER                 --> Flag replicar endereço
													,pr_fltelefo IN INTEGER                 --> Flag replicar telefone
													,pr_flgemail IN INTEGER                 --> Flag replicar email
													,pr_flnmfant IN INTEGER                 --> Flag replicar nome fantasia
													,pr_cdcritic OUT PLS_INTEGER            --> Cód. da crítica
													,pr_dscritic OUT VARCHAR2) IS           --> Descrição da crítica
  BEGIN													
  /* .............................................................................

    Programa: pc_replica_cdc
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para replicar informações para o cdc

    Alteracoes: -----
    ..............................................................................*/																	 
		DECLARE
    
		  vr_exc_erro EXCEPTION;
			
			vr_cdcritic NUMBER;
			vr_dscritic VARCHAR2(4000);
			vr_nmdcampo VARCHAR2(100);
			vr_des_erro VARCHAR2(4000);
	
	    vr_info_cdc typ_reg_info_cdc;
			vr_tab_cdr_cdc typ_tab_cdr_cdc;
			
			-- Buscar dados da filial
			CURSOR cr_cooperado_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE
			                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT t.idcooperado_cdc
				      ,t.cdcnae
				  FROM tbsite_cooperado_cdc t
				 WHERE t.cdcooper = pr_cdcooper
				   AND t.nrdconta = pr_nrdconta
					 AND t.idmatriz IS NULL;
			rw_cooperado_cdc cr_cooperado_cdc%ROWTYPE;
			
			-- Buscar cooperado
			CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
			  SELECT ass.inpessoa
				  FROM crapass ass
				 WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta;
			rw_crapass cr_crapass%ROWTYPE;
			
    BEGIN
      -- Sera o modulo de execucao
      GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_CVNCDC'
                                ,pr_action => 'TELA_ATENDA_CVNCDC.pc_replica_cdc');

			
			-- Buscar cooperado
			OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;
			
			IF cr_crapass%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_crapass;
				-- Gerar crítica
				vr_cdcritic := 9;
				vr_dscritic := '';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Buscar filial CDC
			OPEN cr_cooperado_cdc(pr_cdcooper => pr_cdcooper
			                     ,pr_nrdconta => pr_nrdconta);
			FETCH cr_cooperado_cdc INTO rw_cooperado_cdc;
					
      -- Carrega os dados
      pc_carrega_dados(pr_cdcooper        => pr_cdcooper
                      ,pr_nrdconta        => pr_nrdconta
                      ,pr_idmatriz        => 0
                      ,pr_idcooperado_cdc => rw_cooperado_cdc.idcooperado_cdc
                      ,pr_tab_cdr_cdc     => vr_tab_cdr_cdc
                      ,pr_cdcritic        => vr_cdcritic
                      ,pr_dscritic        => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
	
			-- Se replica endereço
		  IF pr_flendere = 1 THEN
				-- Busca informações do endereço do cooperado
				pc_busca_endereco_cdc(pr_cdcooper => pr_cdcooper
				                     ,pr_nrdconta => pr_nrdconta
														 ,pr_info_cdc => vr_info_cdc
														 ,pr_cdcritic => vr_cdcritic
														 ,pr_dscritic => vr_dscritic);
														 
				-- Se retornou alguma crítica	 
			  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro;
				END IF;
			ELSE
        -- Utiliza informações anteriores
				vr_info_cdc.dsendere := vr_tab_cdr_cdc(pr_nrdconta).dslogradouro;
				vr_info_cdc.nrendere := vr_tab_cdr_cdc(pr_nrdconta).nrendereco;
				vr_info_cdc.complend := vr_tab_cdr_cdc(pr_nrdconta).dscomplemento;
				vr_info_cdc.nmbairro := vr_tab_cdr_cdc(pr_nrdconta).nmbairro;
				vr_info_cdc.nrcepend := vr_tab_cdr_cdc(pr_nrdconta).nrcep;
				vr_info_cdc.idcidade := vr_tab_cdr_cdc(pr_nrdconta).idcidade;

			END IF;
			
			-- Se replica telefone
		  IF pr_fltelefo = 1 THEN
				-- Busca telefone do cooperado
				pc_busca_telefone_cdc(pr_cdcooper => pr_cdcooper
				                     ,pr_nrdconta => pr_nrdconta
														 ,pr_info_cdc => vr_info_cdc
														 ,pr_cdcritic => vr_cdcritic
														 ,pr_dscritic => vr_dscritic);
														 
				-- Se retornou alguma crítica	 
			  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro;
				END IF;
			ELSE
        -- Utiliza informações anteriores
			  vr_info_cdc.nrtelefo := vr_tab_cdr_cdc(pr_nrdconta).dstelefone;
			END IF;
			
			-- Se replica email
		  IF pr_flgemail = 1 THEN
				-- Busca email do cooperado
				pc_busca_email_cdc(pr_cdcooper => pr_cdcooper
				                  ,pr_nrdconta => pr_nrdconta
											 	  ,pr_info_cdc => vr_info_cdc
													,pr_cdcritic => vr_cdcritic
													,pr_dscritic => vr_dscritic);
														 
				-- Se retornou alguma crítica	 
			  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro;
				END IF;
			ELSE
        -- Utiliza informações anteriores
			  vr_info_cdc.dsdemail := vr_tab_cdr_cdc(pr_nrdconta).dsemail;
			END IF;

			-- Se replica nome fantasia
		  IF pr_flnmfant = 1 OR vr_tab_cdr_cdc(pr_nrdconta).nmfantasia IS NULL THEN
				-- Busca nome fantasia do cooperado
				pc_busca_nmfansia_cdc(pr_cdcooper => pr_cdcooper
				                     ,pr_nrdconta => pr_nrdconta
											 	     ,pr_info_cdc => vr_info_cdc
													   ,pr_cdcritic => vr_cdcritic
												     ,pr_dscritic => vr_dscritic);
														 
				-- Se retornou alguma crítica	 
			  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro;
				END IF;
			ELSE
        -- Utiliza informações anteriores
			  vr_info_cdc.nmfansia := vr_tab_cdr_cdc(pr_nrdconta).nmfantasia;
			END IF;			
			
      pc_grava_dados(pr_cdcooper => pr_cdcooper
										,pr_cdoperad => pr_cdoperad
										,pr_idorigem => pr_idorigem
										,pr_nmdatela => pr_nmdatela
										,pr_nrdconta => pr_nrdconta
										,pr_inpessoa => rw_crapass.inpessoa
										,pr_idmatriz => 0
										,pr_idcooperado_cdc => nvl(rw_cooperado_cdc.idcooperado_cdc,0)
										,pr_flgconve => vr_tab_cdr_cdc(pr_nrdconta).flgconve
										,pr_dtinicon => to_char(vr_tab_cdr_cdc(pr_nrdconta).dtinicon, 'DD/MM/RRRR')
										,pr_nmfantasia => vr_info_cdc.nmfansia
										,pr_cdcnae => rw_cooperado_cdc.cdcnae
										,pr_dslogradouro => vr_info_cdc.dsendere
										,pr_dscomplemento => vr_info_cdc.complend
										,pr_nrendereco => vr_info_cdc.nrendere
										,pr_nmbairro => vr_info_cdc.nmbairro
										,pr_nrcep => vr_info_cdc.nrcepend
										,pr_idcidade => vr_info_cdc.idcidade
										,pr_dstelefone => vr_info_cdc.nrtelefo
										,pr_dsemail => vr_info_cdc.dsdemail
										,pr_dslink_google_maps => '<![CDATA[' || vr_tab_cdr_cdc(pr_nrdconta).dslink_google_maps || ']]>'
										,pr_cdcritic => vr_cdcritic
										,pr_dscritic => vr_dscritic
										,pr_nmdcampo => vr_nmdcampo
										,pr_des_erro => vr_des_erro);

      -- Se houver alguma crítica
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;

	  EXCEPTION									
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;
				
		END;
	END pc_replica_cdc;
	
	PROCEDURE pc_busca_codigo_cidade(pr_nmcidade IN crapenc.nmcidade%TYPE --> Cidade
																	,pr_cdufende IN crapenc.cdufende%TYPE --> UF
																	,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
																	,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
																	,pr_dscritic OUT VARCHAR2             --> Descricao da critica
																	,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

  /* .............................................................................

    Programa: pc_busca_codigo_cidade
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar o código da cidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis Gerais
      vr_idcidade crapmun.idcidade%TYPE;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Buscar o código da cidade
      vr_idcidade := cada0003.fn_busca_codigo_cidade(pr_cdestado => pr_cdufende
			                                              ,pr_dscidade => pr_nmcidade);

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>'
			                               || '<idcidade>' || to_char(nvl(vr_idcidade,0)) || '</idcidade></Root>');

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
	END pc_busca_codigo_cidade;

	PROCEDURE pc_busca_informacoes_cadastro(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta
		                                     ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
																				 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
																				 ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
																				 ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
																				 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
																				 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  /* .............................................................................

    Programa: pc_busca_informacoes_cadastro
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as informações de cadastro da conta

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
			vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(10000);
			vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis Gerais
 	    vr_info_cdc typ_reg_info_cdc;
			
						-- Buscar cooperado
			CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
			  SELECT ass.inpessoa
				  FROM crapass ass
				 WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta;
			rw_crapass cr_crapass%ROWTYPE;

    BEGIN
      -- Sera o modulo de execucao
      GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_CVNCDC'
                                ,pr_action => 'TELA_ATENDA_CVNCDC.pc_replica_cdc');			
		
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

			
			-- Buscar cooperado
			OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;
			
			IF cr_crapass%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_crapass;
				-- Gerar crítica
				vr_cdcritic := 9;
				vr_dscritic := '';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
									
			-- Busca informações do endereço do cooperado
			pc_busca_endereco_cdc(pr_cdcooper => vr_cdcooper
													 ,pr_nrdconta => pr_nrdconta
													 ,pr_info_cdc => vr_info_cdc
													 ,pr_cdcritic => vr_cdcritic
													 ,pr_dscritic => vr_dscritic);
														 
			-- Se retornou alguma crítica	 
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;
			
			-- Busca telefone do cooperado
			pc_busca_telefone_cdc(pr_cdcooper => vr_cdcooper
													 ,pr_nrdconta => pr_nrdconta
													 ,pr_info_cdc => vr_info_cdc
													 ,pr_cdcritic => vr_cdcritic
													 ,pr_dscritic => vr_dscritic);
														 
			-- Se retornou alguma crítica	 
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;
			
			-- Busca email do cooperado
			pc_busca_email_cdc(pr_cdcooper => vr_cdcooper
												,pr_nrdconta => pr_nrdconta
												,pr_info_cdc => vr_info_cdc
												,pr_cdcritic => vr_cdcritic
												,pr_dscritic => vr_dscritic);
														 
			-- Se retornou alguma crítica	 
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;

			-- Busca nome fantasia do cooperado
			pc_busca_nmfansia_cdc(pr_cdcooper => vr_cdcooper
													 ,pr_nrdconta => pr_nrdconta
													 ,pr_info_cdc => vr_info_cdc
													 ,pr_cdcritic => vr_cdcritic
													 ,pr_dscritic => vr_dscritic);
														 
			-- Se retornou alguma crítica	 
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
																		 || '<dsendere>' || vr_info_cdc.dsendere || '</dsendere>'
																		 || '<nrendere>' || vr_info_cdc.nrendere || '</nrendere>'
																		 || '<complend>' || vr_info_cdc.complend || '</complend>'
																		 || '<nmbairro>' || vr_info_cdc.nmbairro || '</nmbairro>'
																		 || '<nrcepend>' || vr_info_cdc.nrcepend || '</nrcepend>'
																		 || '<nmcidade>' || vr_info_cdc.nmcidade || '</nmcidade>'
																		 || '<cdufende>' || vr_info_cdc.cdufende || '</cdufende>'
																		 || '<idcidade>' || vr_info_cdc.idcidade || '</idcidade>'
																		 || '<nrtelefo>' || vr_info_cdc.nrtelefo || '</nrtelefo>'
																		 || '<dsdemail>' || vr_info_cdc.dsdemail || '</dsdemail>'
																		 || '<nmfansia>' || vr_info_cdc.nmfansia || '</nmfansia>'
			                               || '</Dados></Root>');

    EXCEPTION
			WHEN vr_exc_erro THEN
				-- Se tiver código de crítica
			  IF vr_cdcritic > 0 THEN
					-- Buscar descrição
					vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				END IF;
			
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
				
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
	END pc_busca_informacoes_cadastro;
  	
END TELA_ATENDA_CVNCDC;
/
