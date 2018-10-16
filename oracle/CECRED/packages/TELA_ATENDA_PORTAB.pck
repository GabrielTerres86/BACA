CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_PORTAB IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_PORSOL
  --  Sistema  : Procedimentos para tela Atenda / Portabilidade de Salario
  --  Sigla    : CRED
  --  Autor    : Anderson Alan - Supero
  --  Data     : Setembro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Portabilidade de Salário
  --
  -- Alteracoes:
  ---------------------------------------------------------------------------------------------------------------


  PROCEDURE pc_busca_dados(pr_nrdconta        IN crapcdr.nrdconta%TYPE --> Numero da conta
                          ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro       OUT VARCHAR2) ; --> Erros do processo

END TELA_ATENDA_PORTAB;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_PORTAB IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_PORSOL
  --  Sistema  : Procedimentos para tela Atenda / Portabilidade de Salario
  --  Sigla    : CRED
  --  Autor    : Anderson Alan - Supero
  --  Data     : Setembro/2018.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Portabilidade de Salário
  --
  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------
  
  
  PROCEDURE pc_busca_dados(pr_nrdconta        IN crapcdr.nrdconta%TYPE --> Numero da conta
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
    Autor   : Anderson Alan
    Data    : Setembro/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

    -- Selecionar o CPF, Nome, 
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrcpfcgc, crapass.nmprimtl
      FROM crapass
      WHERE crapass.cdcooper = pr_cdcooper
      AND crapass.nrdconta = pr_nrdconta;    
    
	  -- Seleciona o Telefone 
	  CURSOR cr_craptfc(pr_cdcooper IN crapass.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS
	    SELECT craptfc.nrtelefo
		  FROM craptfc
		  WHERE craptfc.cdcooper = pr_cdcooper
		  AND craptfc.nrdconta = pr_nrdconta
		  AND craptfc.tptelefo = 2
		   OR craptfc.tptelefo = 1
		   OR craptfc.tptelefo = 3;
	  
    -- Selecionar o Email
    CURSOR cr_crapcem(pr_cdcooper IN crapenc.cdcooper%TYPE,
                      pr_nrdconta IN crapenc.nrdconta%TYPE) IS
      SELECT crapcem.dsdemail
      FROM crapcem
      WHERE crapcem.cdcooper = pr_cdcooper
      AND crapcem.nrdconta = pr_nrdconta
      ORDER BY crapcem.dtmvtolt, crapcem.hrtransa DESC;
    
    -- Selecionar o codigo da empresa
    CURSOR cr_crapttl(pr_cdcooper IN crapenc.cdcooper%TYPE,
                      pr_nrdconta IN crapenc.nrdconta%TYPE) IS
      SELECT crapttl.cdempres
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta;
    
    -- Seleciona a Instituicao Destinatario
    CURSOR cr_crapban_crapcop(pr_cdcooper IN crapenc.cdcooper%TYPE) IS
      SELECT b.nrispbif,
             c.nrdocnpj,
             c.cdagectl
        FROM crapban  b,
             crapcop  c
       WHERE b.cdbccxlt = c.cdbcoctl
         AND c.cdcooper = pr_cdcooper;
    
    -- Seleciona Portab Envia
    CURSOR cr_portab_envia(pr_cdcooper IN crapenc.cdcooper%TYPE,
                           pr_nrdconta IN crapenc.nrdconta%TYPE) IS
      SELECT d.dscodigo,
             t.dtretorno,
             d.nmdominio
        FROM tbcc_dominio_campo d,
             tbcc_portabilidade_envia t
       WHERE d.nmdominio = 'SIT_PORTAB_SALARIO_ENVIA'
         AND d.cddominio = t.idsituacao
         AND t.cdcooper  = pr_cdcooper
         AND t.nrdconta  = pr_nrdconta
    ORDER BY t.dtsolicitacao DESC;
    
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

	  -- Variaveis para CADA0008.pc_busca_inf_emp
	  vr_nmpessoa tbcadast_pessoa.nmpessoa%TYPE;
	  vr_idaltera PLS_INTEGER;
    vr_idseqttl crapttl.idseqttl%TYPE := 1;
    vr_nrdocnpj crapemp.nrdocnpj%TYPE;
    vr_cdempres crapemp.cdempres%TYPE;
    vr_nmpessot tbcadast_pessoa.nmpessoa%TYPE;
    vr_nrcnpjot crapemp.nrdocnpj%TYPE;
    vr_nmempout crapemp.nmresemp%TYPE;
    vr_cdemprot crapemp.cdempres%TYPE;
    
    -- Variaveis Gerais
    vr_nrcpfcgc crapass.nrcpfcgc%TYPE;
    vr_nmprimtl crapass.nmprimtl%TYPE;
	  vr_nrtelefo craptfc.nrtelefo%TYPE;
	  vr_dsdemail crapcem.dsdemail%TYPE;
    vr_nrispbif_cop crapban.nrispbif%TYPE;
    vr_nrdocnpj_cop crapcop.nrdocnpj%TYPE;
    vr_cdagectl_cop crapcop.cdagectl%TYPE;
    vr_dscodigo tbcc_dominio_campo.dscodigo%TYPE;
    vr_dtretorno tbcc_portabilidade_envia.dtretorno%TYPE;
    vr_nmdominio tbcc_dominio_campo.nmdominio%TYPE;
    
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
      
      -- Selecionar o CPF, Nome
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO vr_nrcpfcgc
                          , vr_nmprimtl;
      IF cr_crapass%NOTFOUND THEN
        vr_dscritic := 'Cooperado não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapass;
			
	    -- Selecionar o Telefone
      OPEN cr_craptfc(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_craptfc INTO vr_nrtelefo;
      CLOSE cr_craptfc;
	    
      -- Selecionar o Email
      OPEN cr_crapcem(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcem INTO vr_dsdemail;
      CLOSE cr_crapcem;
      
      -- Selecionar o codigo da empresa
      OPEN cr_crapttl(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapttl INTO vr_cdempres;
      
      IF cr_crapttl%NOTFOUND THEN
        vr_dscritic := 'Codigo da empresa do titular da conta não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapttl;
		  
	    -- Busca informacoes da empresa
      CADA0008.pc_busca_inf_emp(pr_cdcooper => vr_cdcooper,
                                pr_cdempres => vr_cdempres,
                                pr_nrdconta => pr_nrdconta,
                                pr_idseqttl => vr_idseqttl,
                                pr_nrdocnpj => vr_nrdocnpj,
                                pr_nmpessoa => vr_nmpessoa, 
                                pr_nmpessot => vr_nmpessot,
                                pr_idaltera => vr_idaltera,
                                pr_nrcnpjot => vr_nrcnpjot,
                                pr_nmempout => vr_nmempout,
                                pr_cdemprot => vr_cdemprot,
                                pr_dscritic => vr_dscritic);
      
      -- Selecionar a instituicao destinataria
      OPEN cr_crapban_crapcop(pr_cdcooper => vr_cdcooper);
      FETCH cr_crapban_crapcop INTO vr_nrispbif_cop, vr_nrdocnpj_cop, vr_cdagectl_cop;
      IF cr_crapban_crapcop%NOTFOUND THEN
        vr_dscritic := 'Instituição Destinatária não encontrada.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapban_crapcop;
      
      -- Seleciona Portab Envia
      OPEN cr_portab_envia(pr_cdcooper => vr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
      FETCH cr_portab_envia INTO vr_dscodigo, vr_dtretorno, vr_nmdominio;
      CLOSE cr_portab_envia;
    
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
    
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nrdconta'
                            ,pr_tag_cont => pr_nrdconta
                            ,pr_des_erro => vr_dscritic);
			
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nrcpfcgc'
                            ,pr_tag_cont => vr_nrcpfcgc
                            ,pr_des_erro => vr_dscritic);
      
	    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmprimtl'
                            ,pr_tag_cont => vr_nmprimtl
                            ,pr_des_erro => vr_dscritic);
    
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nrtelefo'
                            ,pr_tag_cont => vr_nrtelefo
                            ,pr_des_erro => vr_dscritic);
    
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dsdemail'
                            ,pr_tag_cont => vr_dsdemail
                            ,pr_des_erro => vr_dscritic);
    
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nrdocnpj_emp'
                            ,pr_tag_cont => vr_nrdocnpj
                            ,pr_des_erro => vr_dscritic);
    
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmprimtl_emp'
                            ,pr_tag_cont => vr_nmpessoa
                            ,pr_des_erro => vr_dscritic);
    
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nrispbif'
                            ,pr_tag_cont => vr_nrispbif_cop
                            ,pr_des_erro => vr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nrdocnpj'
                            ,pr_tag_cont => vr_nrdocnpj_cop
                            ,pr_des_erro => vr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cdagectl'
                            ,pr_tag_cont => vr_cdagectl_cop
                            ,pr_des_erro => vr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nrconta'
                            ,pr_tag_cont => pr_nrdconta
                            ,pr_des_erro => vr_dscritic);
    
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dscodigo'
                            ,pr_tag_cont => vr_dscodigo
                            ,pr_des_erro => vr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dtretorno'
                            ,pr_tag_cont => vr_dtretorno
                            ,pr_des_erro => vr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dsmotivo'
                            ,pr_tag_cont => vr_nmdominio
                            ,pr_des_erro => vr_dscritic);
    
	  -- Se houve retorno de erro
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
	  
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
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
        
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_dados;  
 
END TELA_ATENDA_PORTAB;
/
