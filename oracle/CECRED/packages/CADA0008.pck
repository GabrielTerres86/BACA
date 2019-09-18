CREATE OR REPLACE PACKAGE CECRED.CADA0008 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0008
  --  Sistema  : Rotinas acessadas pelas telas de cadastros Web
  --  Sigla    : CADA
  --  Autor    : Marcelo Telles Coelho         - Mount´s
  --  Data     : Outubro/2017.                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas utilizadas para as telas CADCTA referente a cadastros
  --
  --  Alteracoes: 07/03/2019 - Novas regras para alteracao de cadastro. Alteracao no retorno das variaveis
  --                           de alteracao e razao social. Gabriel Marcos (Mouts) - Chamado PRB0040571.
  --
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Variaveis Globais
  vr_xml xmltype; -- XML qye sera enviado

  -- Buscar dados complementares do titular para cadastramento do titular
  PROCEDURE pc_ret_dados_pessoa( pr_nrcpfcgc     IN crapttl.nrcpfcgc%TYPE,
                               pr_nmpessoa OUT crapavt.nmdavali%TYPE,
                               pr_tpdocume OUT crapavt.tpdocava%TYPE,
                               pr_nrdocume OUT crapavt.nrdocava%TYPE,
                               pr_nmconjug OUT crapavt.nmconjug%TYPE,
                               pr_nrcpfcjg OUT crapavt.nrcpfcjg%TYPE,
                               pr_tpdoccjg OUT crapavt.tpdoccjg%TYPE,
                               pr_nrdoccjg OUT crapavt.nrdoccjg%TYPE,
                               pr_dsendre1 OUT crapavt.dsendres##1%TYPE,
                               pr_dsbairro OUT crapavt.dsendres##2%TYPE,
                               pr_nrfonres OUT crapavt.nrfonres%TYPE,
                               pr_dsdemail OUT crapavt.dsdemail%TYPE,
                               pr_nmcidade OUT crapavt.nmcidade%TYPE,
                               pr_cdufresd OUT crapavt.cdufresd%TYPE,
                               pr_nrcepend OUT crapavt.nrcepend%TYPE,
                               pr_dsnacion OUT crapnac.dsnacion%TYPE,
                               pr_vledvmto OUT crapavt.vledvmto%TYPE,
                               pr_vlrenmes OUT crapavt.vlrenmes%TYPE,
                               pr_complend OUT VARCHAR2,
                               pr_nrendere OUT crapavt.nrendere%TYPE,                                       
                               pr_inpessoa OUT crapavt.inpessoa%TYPE,
                               pr_dtnascto OUT crapavt.dtnascto%TYPE,
                               pr_tpnacion OUT crapttl.tpnacion%TYPE,
                               pr_cdnacion OUT crapavt.cdnacion%TYPE,
                               pr_cdufddoc OUT crapavt.cdufddoc%TYPE,
                               pr_dtemddoc OUT crapavt.dtemddoc%TYPE,
                               pr_cdsexcto OUT crapavt.cdsexcto%TYPE,
                               pr_cdestcvl OUT crapavt.cdestcvl%TYPE,
                               pr_cdnatura OUT crapmun.idcidade%TYPE,
                               pr_dsnatura OUT crapnat.dsnatura%TYPE,
                               pr_cdufnatu OUT crapttl.cdufnatu%TYPE,
                               pr_nmmaecto OUT crapavt.nmmaecto%TYPE,
                               pr_nmpaicto OUT crapavt.nmpaicto%TYPE,
                               pr_inhabmen OUT crapavt.inhabmen%TYPE,
                               pr_dthabmen OUT crapavt.dthabmen%TYPE,  
                               pr_cdorgao_expedidor OUT tbgen_orgao_expedidor.cdorgao_expedidor%TYPE,                            
                               pr_cdsitrfb OUT tbcadast_pessoa.cdsituacao_rfb%TYPE,
                               pr_dtconrfb OUT tbcadast_pessoa.dtconsulta_rfb%TYPE,
                               pr_grescola OUT tbcadast_pessoa_fisica.cdgrau_escolaridade%TYPE,
                               pr_cdfrmttl OUT tbcadast_pessoa_fisica.cdcurso_superior%TYPE,                               
                               pr_dscritic OUT VARCHAR2);
                               
  
  
  -- Buscar dados da pessoa para utilização como avalista - Chamada progress
  PROCEDURE pc_ret_dados_pessoa_prog
                             ( pr_nrcpfcgc  IN crapttl.nrcpfcgc%TYPE,
                               pr_dsxmlret OUT CLOB,
                               pr_dscritic OUT crapcri.dscritic%TYPE);
                                                              
  -- Atualiza os dados alterados na tela CADCTA
  PROCEDURE pc_atualiza_dados_cadcta(pr_cdcooper IN crapcop.cdcooper%TYPE                                    
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE
                                    ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE
                                    ,pr_idorigem IN INTEGER
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE
                                    ,pr_cdbcochq IN crapass.cdbcochq%TYPE
                                    ,pr_cdconsul IN tbcc_consultor.cdconsultor%TYPE
                                    ,pr_cdagedbb IN crapcop.cdagedbb%TYPE
                                    ,pr_nrdctitg IN crapass.nrdctitg%TYPE
                                    ,pr_nrctacns IN crapass.nrctacns%TYPE
                                    ,pr_incadpos IN crapass.incadpos%TYPE
                                    ,pr_flgiddep IN crapass.flgiddep%TYPE
                                    ,pr_flgrestr IN crapass.flgrestr%TYPE
                                    ,pr_indserma IN crapass.indserma%TYPE
                                    ,pr_inlbacen IN crapass.inlbacen%TYPE
                                    ,pr_nmtalttl IN crapttl.nmtalttl%TYPE
                                    ,pr_qtfoltal IN crapass.qtfoltal%TYPE
                                    ,pr_cdempres IN crapttl.cdempres%TYPE
                                    ,pr_nrinfcad IN crapttl.nrinfcad%TYPE
                                    ,pr_nrpatlvr IN crapttl.nrpatlvr%TYPE
                                    ,pr_dsinfadi IN crapttl.dsinfadi%TYPE         --> Numero da conta                                    
                                    ,pr_nmctajur IN crapjur.nmctajur%TYPE     -->  Nome conta juridica
                                    ,pr_cdcritic OUT INTEGER                  --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                 --> Descrição da crítica
                                    );    

  -- Rotina para retornar os titulares de uma conta
  PROCEDURE pc_retorna_titulares(pr_cdcooper IN NUMBER                 --> Codigo da cooperativa
                                ,pr_nrdconta IN NUMBER                 --> Numero da conta
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);            --> Retorno de Erro

	-- Buscar nr. de sequência de endereço
	PROCEDURE pc_busca_nrseqend(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE
		                         ,pr_tpendass IN tbcadast_pessoa_endereco.tpendereco%TYPE
														 ,pr_nrseqend OUT tbcadast_pessoa_endereco.nrseq_endereco%TYPE
														 ,pr_dscritic OUT crapcri.dscritic%TYPE);

	-- Buscar nr. de sequência de telefone para inclusoes de telefone pela MATRIC
	PROCEDURE pc_busca_nrseqtel(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE
		                         ,pr_tptelefo IN tbcadast_pessoa_telefone.tptelefone%TYPE
														 ,pr_nrseqtel OUT tbcadast_pessoa_telefone.nrseq_telefone%TYPE
														 ,pr_dscritic OUT crapcri.dscritic%TYPE);

  -- Buscar nr. de sequência de telefone para inclusoes de telefone pela MATRIC
	PROCEDURE pc_busca_crapjur(pr_nrcpfcgc IN  tbcadast_pessoa.nrcpfcgc%TYPE
		                        ,pr_qtfuncio out tbcadast_pessoa_juridica.qtfuncionario%TYPE
                            ,pr_vlcaprea out tbcadast_pessoa_juridica.vlcapital%TYPE
                            ,pr_dtregemp out tbcadast_pessoa_juridica.dtregistro%TYPE
                            ,pr_nrregemp out tbcadast_pessoa_juridica.nrregistro%TYPE
                            ,pr_orregemp out tbcadast_pessoa_juridica.dsorgao_registro%TYPE
                            ,pr_nrcdnire out tbcadast_pessoa_juridica.nrnire%TYPE
                            ,pr_dtinsmun out tbcadast_pessoa_juridica.dtinscricao_municipal%TYPE
                            ,pr_flgrefis out tbcadast_pessoa_juridica.inrefis%TYPE
                            ,pr_dsendweb out tbcadast_pessoa_juridica.dssite%TYPE
                            ,pr_nrinsmun out tbcadast_pessoa_juridica.nrinscricao_municipal%TYPE
                            ,pr_vlfatano out tbcadast_pessoa_juridica.vlfaturamento_anual%TYPE
                            ,pr_nrlicamb out tbcadast_pessoa_juridica.nrlicenca_ambiental%TYPE
                            ,pr_dtvallic out tbcadast_pessoa_juridica.dtvalidade_licenca_amb%TYPE
                            ,pr_tpregtrb out tbcadast_pessoa_juridica.tpregime_tributacao%TYPE
                            ,pr_qtfilial OUT tbcadast_pessoa_juridica.qtfilial%TYPE
													  ,pr_dscritic OUT crapcri.dscritic%TYPE);


  -- Buscar dados complementares do titular para cadastramento do titular
	PROCEDURE pc_busca_crapttl_compl( pr_cdcooper     IN crapttl.cdcooper%TYPE,
                                    pr_cdempres     IN crapttl.cdempres%TYPE,
                                    pr_nrcpfcgc     IN crapttl.nrcpfcgc%TYPE,         
                              pr_cdnatopc    OUT crapttl.cdnatopc%TYPE,
                              pr_cdocpttl    OUT crapttl.cdocpttl%TYPE,
                              pr_tpcttrab    OUT crapttl.tpcttrab%TYPE,
                              pr_nmextemp    OUT crapttl.nmextemp%TYPE,
                              pr_nrcpfemp    OUT crapttl.nrcpfemp%TYPE,
                              pr_dtadmemp    OUT crapttl.dtadmemp%TYPE,
                              pr_dsproftl    OUT crapttl.dsproftl%TYPE,
                              pr_cdnvlcgo    OUT crapttl.cdnvlcgo%TYPE,
                              pr_vlsalari    OUT crapttl.vlsalari%TYPE,
                              pr_cdturnos    OUT crapttl.cdturnos%TYPE,
                              pr_dsjusren    OUT crapttl.dsjusren%TYPE,
                              pr_dtatutel    OUT crapttl.dtatutel%TYPE,
                              pr_cdgraupr    OUT crapttl.cdgraupr%TYPE,
                              pr_cdfrmttl    OUT crapttl.cdfrmttl%TYPE,
                              pr_tpdrendi##1 OUT crapttl.tpdrendi##1%TYPE,
                              pr_vldrendi##1 OUT crapttl.vldrendi##1%TYPE,
                              pr_tpdrendi##2 OUT crapttl.tpdrendi##1%TYPE,
                              pr_vldrendi##2 OUT crapttl.vldrendi##1%TYPE,
                              pr_tpdrendi##3 OUT crapttl.tpdrendi##1%TYPE,
                              pr_vldrendi##3 OUT crapttl.vldrendi##1%TYPE,
                              pr_tpdrendi##4 OUT crapttl.tpdrendi##1%TYPE,
                              pr_vldrendi##4 OUT crapttl.vldrendi##1%TYPE,
                              pr_tpdrendi##5 OUT crapttl.tpdrendi##1%TYPE,
                              pr_vldrendi##5 OUT crapttl.vldrendi##1%TYPE,
                              pr_tpdrendi##6 OUT crapttl.tpdrendi##1%TYPE,
                              pr_vldrendi##6 OUT crapttl.vldrendi##1%TYPE,
                              pr_nmpaittl    OUT crapttl.nmpaittl%TYPE,
                              pr_nmmaettl    OUT crapttl.nmmaettl%TYPE,
                              pr_dscritic    OUT crapcri.dscritic%TYPE) ;                                    
                            
                                              
  -- Rotina para marcar registros da TBCADAST_PESSOA_* a serem replicados para o AYLLOS
  PROCEDURE pc_marca_replica_ayllos (pr_cdcooper IN NUMBER  -- Codigo da cooperativa
                                    ,pr_nrdconta IN NUMBER  -- Numero da conta
                                    ,pr_idseqttl IN NUMBER DEFAULT 1 -- Sequencia do titular
                                    ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para buscar o nome da pessoa e indicador se o nome pode ser alterado ou nao
  PROCEDURE pc_busca_nome_pessoa(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE,
                                 pr_nmpessoa OUT tbcadast_pessoa.nmpessoa%TYPE,
                                 pr_idaltera OUT PLS_INTEGER, -- Indicador se permite alterar nome (0-Nao permite, 1-Permite alterar nome)
                                 pr_dscritic OUT VARCHAR2);

  -- Rotina para buscar o nome da pessoa e indicador se o nome pode ser alterado ou nao
  PROCEDURE pc_busca_nome_pessoa_xml(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE,
                                     pr_xmllog   IN VARCHAR2,               --> XML com informações de LOG
                                     pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                     pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                     pr_retxml   IN OUT NOCOPY XMLType,     --> Arquivo de retorno do XML
                                     pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                     pr_des_erro OUT VARCHAR2);             --> Erros do processo

  -- Rotina para realizar a chamada da CADA0012.pc_valida_acesso_operador                           
  PROCEDURE pc_valida_acesso_operador_web(pr_nrdconta IN NUMBER        --> Número da conta do Cooperado
                                         ,pr_xmllog   IN VARCHAR2      --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER  --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2     --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2     --> Nome do Campo
                                         ,pr_des_erro OUT VARCHAR2);   --> Saida OK/NOK
                                         
  -- Rotina para buscar os dados para saque de cotas da tabela TBCOTAS_SAQUE_CONTROLE
  PROCEDURE pc_busca_saque_controle_web(pr_nrdconta IN NUMBER        --> Número da conta do Cooperado
                                       ,pr_tpdsaque IN NUMBER        --> Tipo de saque (1-Saque Parcial/2-Desligamento)
                                       ,pr_xmllog   IN VARCHAR2      --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER  --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2     --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2     --> Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);   --> Saida OK/NOK
                                       
  -- Rotina para validar os dados de cotas e chamar a rotina de devolução
  PROCEDURE pc_devolucao_desligamento(pr_nrdconta  IN crapass.nrdconta%TYPE    --> Número da conta
                                     ,pr_vldcotas  IN crapcot.vldcotas%TYPE   --> Valor de cotas                                        
                                     ,pr_formadev  IN INTEGER                 --> Forma de devolução 1 = total / 2 = parcelado 
                                     ,pr_qtdparce  IN INTEGER                 --> Quantidade de parcelas 
                                     ,pr_datadevo  IN VARCHAR2                --> Valor de cotas                                          
                                     ,pr_mtdemiss  IN INTEGER                 --> Motivo informado pelo operador na tela matric
                                     ,pr_dtdemiss  IN VARCHAR2                --> Data informada pelo operador na tela matric
                                     ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                     ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2);             --> Descrição do erro
                                   
  -- Rotina para validar os dados de cotas e chamar a rotina de saque parcial
  PROCEDURE pc_efetuar_saque_parcial(pr_nrctaori  IN crapass.nrdconta%TYPE --> Número da conta origem
                                    ,pr_nrctadst  IN crapass.nrdconta%TYPE --> Número da conta destino
                                    ,pr_vldsaque  IN crapcot.vldcotas%TYPE --> Valor do saque
                                    ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2);           --> Erros do processo
                                      
  PROCEDURE pc_busca_inf_emp_xml(pr_cdempres IN crapemp.cdempres%TYPE,
                                 pr_cdcooper IN crapcop.cdcooper%TYPE,
                                 pr_nrdconta IN crapass.nrdconta%TYPE,
                                 pr_idseqttl IN crapttl.idseqttl%TYPE,
                                 pr_nrdocnpj IN crapemp.nrdocnpj%TYPE,
                                 pr_nmpessoa IN tbcadast_pessoa.nmpessoa%TYPE,                             
                                 pr_xmllog   IN VARCHAR2,               --> XML com informações de LOG
                                 pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                 pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                 pr_retxml   IN OUT NOCOPY XMLType,     --> Arquivo de retorno do XML
                                 pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                 pr_des_erro OUT VARCHAR2);   

  PROCEDURE pc_busca_inf_emp(pr_cdcooper IN crapemp.cdcooper%TYPE,
                             pr_cdempres IN crapemp.cdempres%TYPE,    
                             pr_nrdconta IN crapass.nrdconta%TYPE,
                             pr_idseqttl IN crapttl.idseqttl%TYPE,
                             pr_nrdocnpj IN crapemp.nrdocnpj%TYPE,
                             pr_nmpessoa IN tbcadast_pessoa.nmpessoa%TYPE,
                             pr_nmpessot OUT tbcadast_pessoa.nmpessoa%TYPE,
                             pr_idaltera OUT PLS_INTEGER, -- Indicador se permite alterar nome (0-Nao permite, 1-Permite alterar nome)
                             pr_nrcnpjot OUT crapemp.nrdocnpj%TYPE,
                             pr_nmempout OUT crapemp.nmresemp%TYPE,
                             pr_cdemprot OUT crapemp.cdempres%TYPE,
                             pr_dscritic OUT VARCHAR2);                                     
                              
                                      
END CADA0008;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0008 IS

  -- Rotina para retornar os titulares de uma conta
  PROCEDURE pc_retorna_titulares(pr_cdcooper IN NUMBER                 --> Codigo da cooperativa
                                ,pr_nrdconta IN NUMBER                 --> Numero da conta
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
    -- Cursor para buscar o ID_PESSOA da conta
    CURSOR cr_busca_inpessoa IS
      SELECT inpessoa
            ,nrcpfcgc
        FROM crapass a
       WHERE nrdconta = pr_nrdconta
         AND cdcooper = pr_cdcooper;

    -- Cursor para buscar titulares pessoa física
    CURSOR cr_busca_tit_fis IS
      SELECT a.*
            ,COUNT(*) OVER (PARTITION BY a.cdcooper,a.nrdconta) qtdregis
        FROM crapttl a
       WHERE nrdconta = pr_nrdconta
         AND cdcooper = pr_cdcooper;

    -- Cursor para buscar titular pessoa jurídica
    CURSOR cr_busca_tit_jur IS
      SELECT *
        FROM crapjur a
       WHERE nrdconta = pr_nrdconta
         AND cdcooper = pr_cdcooper;
    -- Variaveis
    w_dsgraupr       VARCHAR2(100);
    vr_contador      number;
    --Variaveis de LOG
    vr_cdoperad      VARCHAR2(100);
    vr_cdcooper      NUMBER;
    vr_nmdatela      VARCHAR2(100);
    vr_nmeacao       VARCHAR2(100);
    vr_cdagenci      VARCHAR2(100);
    vr_nrdcaixa      VARCHAR2(100);
    vr_idorigem      VARCHAR2(100);

  BEGIN
    vr_contador := 0;
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);
    vr_xml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Insere o nó principal
    gene0007.pc_insere_tag(pr_xml      => vr_xml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Titulares'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => pr_dscritic);

    FOR r_busca_inpessoa IN cr_busca_inpessoa LOOP
      IF r_busca_inpessoa.inpessoa = 1 THEN
        FOR r_busca_tit_fis IN cr_busca_tit_fis LOOP
          gene0007.pc_gera_atributo(pr_xml      => vr_xml
                                   ,pr_tag      => 'Titulares'
                                   ,pr_atrib    => 'qtregist'
                                   ,pr_atval    => r_busca_tit_fis.qtdregis
                                   ,pr_numva    => 0
                                   ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titulares'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'Titular'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => pr_dscritic);
          w_dsgraupr := null;
          FOR r_grau_parente in (SELECT dscodigo
                                   FROM TBCC_DOMINIO_CAMPO
                                  WHERE nmdominio = 'CRAPTTL.CDGRAUPR'
                                    AND cddominio = r_busca_tit_fis.cdgraupr)
          LOOP
            w_dsgraupr := r_grau_parente.dscodigo;
          END LOOP;
          --
          -- Insere os detalhes
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'idseqttl'
                                ,pr_tag_cont => r_busca_tit_fis.idseqttl
                                ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'nrcadast'
                                ,pr_tag_cont => r_busca_tit_fis.nrcadast
                                ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'nmextttl'
                                ,pr_tag_cont => r_busca_tit_fis.nmextttl
                                ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'nrcpfcgc'
                                ,pr_tag_cont => r_busca_tit_fis.nrcpfcgc
                                ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dsgraupr'
                                ,pr_tag_cont => r_busca_tit_fis.cdgraupr||'-'||w_dsgraupr
                                ,pr_des_erro => pr_dscritic);
          vr_contador := vr_contador + 1;
        END LOOP;
      ELSE
        FOR r_busca_tit_jur IN cr_busca_tit_jur LOOP
          gene0007.pc_gera_atributo(pr_xml      => vr_xml
                                   ,pr_tag      => 'Titulares'
                                   ,pr_atrib    => 'qtregist'
                                   ,pr_atval    => 1
                                   ,pr_numva    => 0
                                   ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titulares'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'Titular'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => pr_dscritic);
          -- Insere os detalhes
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'idseqttl'
                                ,pr_tag_cont => 1
                                ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'nrcadast'
                                ,pr_tag_cont => pr_nrdconta
                                ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'nmextttl'
                                ,pr_tag_cont => r_busca_tit_jur.nmextttl
                                ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'nrcpfcgc'
                                ,pr_tag_cont => r_busca_inpessoa.nrcpfcgc
                                ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dsgraupr'
                                ,pr_tag_cont => 0
                                ,pr_des_erro => pr_dscritic);
        END LOOP;
      END IF;
    END LOOP;
    pr_retxml := vr_xml;

  END pc_retorna_titulares;
	
	-- Buscar nr. de sequência de endereço para inclusoes de endereco pela MATRIC
	PROCEDURE pc_busca_nrseqend(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE
		                         ,pr_tpendass IN tbcadast_pessoa_endereco.tpendereco%TYPE
														 ,pr_nrseqend OUT tbcadast_pessoa_endereco.nrseq_endereco%TYPE
														 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    /* ..........................................................................
    --
    --  Programa : pc_busca_nrseqend
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Lucas Reinert
    --  Data     : Outubro/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para retornar nr. de sequência do endereço do cooperado
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
		
		/* Buscar nr. seq. do endereço*/
		CURSOR cr_pessoa_endereco(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE
		                         ,pr_tpendass IN tbcadast_pessoa_endereco.tpendereco%TYPE) IS
			SELECT tend.nrseq_endereco
			  FROM tbcadast_pessoa tpes,
				     tbcadast_pessoa_endereco tend
			 WHERE tpes.nrcpfcgc = pr_nrcpfcgc
			   AND tend.idpessoa = tpes.idpessoa
				 AND tend.tpendereco = pr_tpendass;
		rw_pessoa_endereco cr_pessoa_endereco%ROWTYPE;
		
	BEGIN
		-- Buscar nr. seq. do endereço do associado
	  OPEN cr_pessoa_endereco(pr_nrcpfcgc => pr_nrcpfcgc
		                       ,pr_tpendass => pr_tpendass);
		FETCH cr_pessoa_endereco INTO rw_pessoa_endereco;
		
		IF cr_pessoa_endereco%NOTFOUND THEN
			-- Se não encontrou endereço, não possui cadastro, iniciamos sequencial com '1'
			pr_nrseqend := 1;
		ELSE
			-- Se encontrou retornamos o número de sequencial
			pr_nrseqend := rw_pessoa_endereco.nrseq_endereco;
		END IF;
		-- Fechar cursor
		CLOSE cr_pessoa_endereco;
		
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_busca_nrseqend: ' ||
                     SQLERRM;		
	END pc_busca_nrseqend;
	
  
	-- Buscar nr. de sequência de telefone para inclusoes de telefone pela MATRIC
	PROCEDURE pc_busca_nrseqtel(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE
		                         ,pr_tptelefo IN tbcadast_pessoa_telefone.tptelefone%TYPE
														 ,pr_nrseqtel OUT tbcadast_pessoa_telefone.nrseq_telefone%TYPE
														 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    /* ..........................................................................
    --
    --  Programa : pc_busca_nrseqtel
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Lucas Reinert
    --  Data     : Outubro/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para retornar nr. de sequência do telefone do cooperado
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
		
		/* Buscar nr. seq. do telefone utilizando o tipo de telefone */
		CURSOR cr_pessoa_telefone IS
			SELECT a.nrseq_telefone
			  FROM tbcadast_pessoa b,
				     tbcadast_pessoa_telefone a
			 WHERE b.nrcpfcgc   = pr_nrcpfcgc
			   AND a.idpessoa   = b.idpessoa
				 AND a.tptelefone = pr_tptelefo
        ORDER BY a.nrseq_telefone;

		/* Buscar nr. seq. do telefone */
		CURSOR cr_pessoa_telefone_max IS
			SELECT nvl(max(a.nrseq_telefone),0) 
			  FROM tbcadast_pessoa b,
				     tbcadast_pessoa_telefone a
			 WHERE b.nrcpfcgc   = pr_nrcpfcgc
			   AND a.idpessoa   = b.idpessoa;
		
	BEGIN
		-- Buscar nr. seq. do telefone do associado
	  OPEN cr_pessoa_telefone;
		FETCH cr_pessoa_telefone INTO pr_nrseqtel;
		
    -- Se nao encontrou para o tipo de telefone
		IF cr_pessoa_telefone%NOTFOUND THEN
			-- Se não encontrou telefone por tipo, verifica se existe sem tipo
  	  OPEN cr_pessoa_telefone_max;
      FETCH cr_pessoa_telefone_max INTO pr_nrseqtel;
      CLOSE cr_pessoa_telefone_max;
      
      -- Se existir valor na TBCADAST_PESSOA_TELEFONE
      IF pr_nrseqtel <> 0 THEN
        pr_nrseqtel := pr_nrseqtel + 1;
      END IF;
      
		END IF;
		-- Fechar cursor
		CLOSE cr_pessoa_telefone;
		
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_busca_nrseqtel: ' ||
                     SQLERRM;		
	END pc_busca_nrseqtel;
  
    -- Buscar dados da pessoa para utilização como avalista
  PROCEDURE pc_ret_dados_pessoa( pr_nrcpfcgc  IN crapttl.nrcpfcgc%TYPE,
                               pr_nmpessoa OUT crapavt.nmdavali%TYPE,
                               pr_tpdocume OUT crapavt.tpdocava%TYPE,
                               pr_nrdocume OUT crapavt.nrdocava%TYPE,
                               pr_nmconjug OUT crapavt.nmconjug%TYPE,
                               pr_nrcpfcjg OUT crapavt.nrcpfcjg%TYPE,
                               pr_tpdoccjg OUT crapavt.tpdoccjg%TYPE,
                               pr_nrdoccjg OUT crapavt.nrdoccjg%TYPE,
                               pr_dsendre1 OUT crapavt.dsendres##1%TYPE,
                               pr_dsbairro OUT crapavt.dsendres##2%TYPE,
                               pr_nrfonres OUT crapavt.nrfonres%TYPE,
                               pr_dsdemail OUT crapavt.dsdemail%TYPE,
                               pr_nmcidade OUT crapavt.nmcidade%TYPE,
                               pr_cdufresd OUT crapavt.cdufresd%TYPE,
                               pr_nrcepend OUT crapavt.nrcepend%TYPE,
                               pr_dsnacion OUT crapnac.dsnacion%TYPE,
                               pr_vledvmto OUT crapavt.vledvmto%TYPE,
                               pr_vlrenmes OUT crapavt.vlrenmes%TYPE,
                               pr_complend OUT VARCHAR2,
                               pr_nrendere OUT crapavt.nrendere%TYPE,
                               pr_inpessoa OUT crapavt.inpessoa%TYPE,
                               pr_dtnascto OUT crapavt.dtnascto%TYPE,
                               pr_tpnacion OUT crapttl.tpnacion%TYPE,
                               pr_cdnacion OUT crapavt.cdnacion%TYPE,
                               pr_cdufddoc OUT crapavt.cdufddoc%TYPE,
                               pr_dtemddoc OUT crapavt.dtemddoc%TYPE,
                               pr_cdsexcto OUT crapavt.cdsexcto%TYPE,
                               pr_cdestcvl OUT crapavt.cdestcvl%TYPE,
                               pr_cdnatura OUT crapmun.idcidade%TYPE,
                               pr_dsnatura OUT crapnat.dsnatura%TYPE,
                               pr_cdufnatu OUT crapttl.cdufnatu%TYPE,
                               pr_nmmaecto OUT crapavt.nmmaecto%TYPE,
                               pr_nmpaicto OUT crapavt.nmpaicto%TYPE,
                               pr_inhabmen OUT crapavt.inhabmen%TYPE,
                               pr_dthabmen OUT crapavt.dthabmen%TYPE,   
                               pr_cdorgao_expedidor OUT tbgen_orgao_expedidor.cdorgao_expedidor%TYPE,                            
                               pr_cdsitrfb OUT tbcadast_pessoa.cdsituacao_rfb%TYPE,
                               pr_dtconrfb OUT tbcadast_pessoa.dtconsulta_rfb%TYPE,
                               pr_grescola OUT tbcadast_pessoa_fisica.cdgrau_escolaridade%TYPE,
                               pr_cdfrmttl OUT tbcadast_pessoa_fisica.cdcurso_superior%TYPE,                               
                               pr_dscritic OUT VARCHAR2) IS
    /* ..........................................................................
    --
    --  Programa : pc_ret_dados_aval
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana (AMcom)
    --  Data     : Outubro/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar dados da pessoa para utilização como avalista
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    --> Retonar dados da pessoa
    CURSOR cr_pessoa IS
      SELECT a.nmpessoa,
             a.tppessoa,
             a.idpessoa,
             a.cdsituacao_rfb,
             a.dtconsulta_rfb             
        FROM tbcadast_pessoa a
       WHERE a.nrcpfcgc       = pr_nrcpfcgc
         AND a.tpcadastro     > 2; -- Somente buscar intermediario ou completo
    rw_pessoa cr_pessoa%ROWTYPE;

    --> Retonar dados da pessoa fisica
    CURSOR cr_pessoa_fisica(pr_idpessoa NUMBER) IS
      SELECT b.tpdocumento,
             b.nrdocumento,
             b.cdnacionalidade,
             n.dsnacion,
             b.tpnacionalidade,
             b.dtnascimento,             
             d.nrcpf nrcpf_conjuge,
             d.nmpessoa nmpessoa_conjuge,
             d.tpdocumento tpdocumento_conjuge,
             d.nrdocumento nrdocumento_conjuge,
             e.nrcep,
             e.nmlogradouro,
             e.nrlogradouro,
             e.dscomplemento,
             e.nmbairro,
             f.dscidade,
             f.cdestado,
             i.nrtelefone,
             j.dsemail,
             nvl(g.vlrenda,0) + NVL(h.vlrenda,0) vlrenda,
             o.cdorgao_expedidor,
             b.cdgrau_escolaridade,
             b.cdcurso_superior,
             --             
             b.CDUF_ORGAO_EXPEDIDOR,
             b.DTEMISSAO_DOCUMENTO,
             b.tpsexo,
             b.CDESTADO_CIVIL,
             b.CDNATURALIDADE,
             t.dscidade dsnatura,
             t.cdestado cdufnatu,
             ka.nmpessoa nmpessoa_mae,
             la.nmpessoa nmpessoa_pai,
             b.inhabilitacao_menor,
             b.dthabilitacao_menor
             
        FROM (SELECT idpessoa, SUM(x.vlrenda) vlrenda FROM tbcadast_pessoa_rendacompl x GROUP BY x.idpessoa) h,
             tbcadast_pessoa_email j,
             tbcadast_pessoa_telefone i,
             tbcadast_pessoa_renda g,
             crapmun f,
             tbcadast_pessoa_endereco e,
             vwcadast_pessoa_fisica d, -- Dados do conjuge
             tbcadast_pessoa_relacao c,
             tbcadast_pessoa_fisica b,
             crapnac n,        
             crapmun t,     
             tbgen_orgao_expedidor o,
             --
             tbcadast_pessoa_relacao k, -- Mãe
             tbcadast_pessoa ka,
             tbcadast_pessoa_relacao l, -- Pai
             tbcadast_pessoa la
       WHERE b.idpessoa       = pr_idpessoa
         AND c.idpessoa  (+)  = b.idpessoa
         AND c.tprelacao (+)  = 1 -- Conjuge
         AND d.idpessoa (+)   = c.idpessoa_relacao
         AND e.idpessoa (+)   = b.idpessoa
         AND e.tpendereco (+) = 10 -- Residencial
         AND f.idcidade (+)   = e.idcidade
         AND g.idpessoa (+)   = b.idpessoa
         AND h.idpessoa (+)   = b.idpessoa
         AND i.idpessoa (+)   = b.idpessoa
         AND j.idpessoa (+)   = b.idpessoa
         AND n.cdnacion (+)   = b.cdnacionalidade
         AND t.idcidade (+)   = b.cdnaturalidade
         AND o.idorgao_expedidor(+) = b.idorgao_expedidor
         --
         AND k.idpessoa(+)    = b.idpessoa
         AND k.tprelacao(+)   = 4 -- Mãe
         AND ka.idpessoa(+)   = k.idpessoa_relacao
         AND l.idpessoa(+)    = b.idpessoa
         AND l.tprelacao(+)   = 3 -- Pai
         AND la.idpessoa(+)   = l.idpessoa_relacao
        ORDER BY i.tptelefone, i.nrseq_telefone, j.nrseq_email;
    rw_pessoa_fisica cr_pessoa_fisica%ROWTYPE;

    --> Retonar dados da pessoa juridica
    CURSOR cr_pessoa_juridica(pr_idpessoa NUMBER) IS
      SELECT e.nrcep,
             e.nmlogradouro,
             e.nrlogradouro,
             e.dscomplemento,
             e.nmbairro,
             f.dscidade,
             f.cdestado,
             i.nrtelefone,
             j.dsemail,
             nvl(g.vlrenda,0) + NVL(h.vlrenda,0) vlrenda
        FROM (SELECT idpessoa, SUM(x.vlrenda) vlrenda FROM tbcadast_pessoa_rendacompl x GROUP BY x.idpessoa) h,
             tbcadast_pessoa_email j,
             tbcadast_pessoa_telefone i,
             tbcadast_pessoa_renda g,
             crapmun f,
             tbcadast_pessoa_endereco e,
             tbcadast_pessoa_juridica b
       WHERE b.idpessoa       = pr_idpessoa
         AND e.idpessoa (+)   = b.idpessoa
         AND e.tpendereco (+) = 9 -- Comercial
         AND f.idcidade (+)   = e.idcidade
         AND g.idpessoa (+)   = b.idpessoa
         AND h.idpessoa (+)   = b.idpessoa
         AND i.idpessoa (+)   = b.idpessoa
         AND j.idpessoa (+)   = b.idpessoa
        ORDER BY i.tptelefone, i.nrseq_telefone, j.nrseq_email;
    rw_pessoa_juridica cr_pessoa_juridica%ROWTYPE;

  BEGIN

    --> Retonar dados da pessoa
    OPEN cr_pessoa;
    FETCH cr_pessoa INTO rw_pessoa;
    CLOSE cr_pessoa;

    IF rw_pessoa.tppessoa = 1 THEN
      --> retonar dados da pessoa fisica
      OPEN cr_pessoa_fisica(pr_idpessoa => rw_pessoa.idpessoa);
      FETCH cr_pessoa_fisica INTO rw_pessoa_fisica;
      IF cr_pessoa_fisica%FOUND THEN
        CLOSE cr_pessoa_fisica;

        pr_nmpessoa := rw_pessoa.nmpessoa;

        pr_tpdocume := rw_pessoa_fisica.tpdocumento;
        pr_nrdocume := rw_pessoa_fisica.nrdocumento;
        pr_nmconjug := rw_pessoa_fisica.nmpessoa_conjuge;
        pr_nrcpfcjg := rw_pessoa_fisica.nrcpf_conjuge;
        pr_tpdoccjg := rw_pessoa_fisica.tpdocumento_conjuge;
        pr_nrdoccjg := rw_pessoa_fisica.nrdocumento_conjuge;
        pr_inpessoa := 1;

        pr_dsendre1 := rw_pessoa_fisica.nmlogradouro;
        pr_dsbairro := rw_pessoa_fisica.nmbairro;

        pr_nrfonres := rw_pessoa_fisica.nrtelefone;
        pr_dsdemail := rw_pessoa_fisica.dsemail;

        pr_nmcidade := rw_pessoa_fisica.dscidade;

        pr_cdufresd := rw_pessoa_fisica.cdestado;

        pr_nrcepend := rw_pessoa_fisica.nrcep;

        pr_dsnacion := rw_pessoa_fisica.dsnacion;
        pr_vledvmto := 0;
        pr_vlrenmes := rw_pessoa_fisica.vlrenda;

        pr_complend := trim(rw_pessoa_fisica.dscomplemento);

        pr_nrendere := rw_pessoa_fisica.nrlogradouro;
        pr_dtnascto := rw_pessoa_fisica.dtnascimento;
        pr_cdnacion := rw_pessoa_fisica.cdnacionalidade;
        pr_tpnacion := rw_pessoa_fisica.tpnacionalidade;
        
        
        pr_cdufddoc := rw_pessoa_fisica.cduf_orgao_expedidor;
        pr_dtemddoc := rw_pessoa_fisica.dtemissao_documento;
        pr_cdsexcto := rw_pessoa_fisica.tpsexo;
        pr_cdestcvl := rw_pessoa_fisica.cdestado_civil;
        pr_cdnatura := rw_pessoa_fisica.cdnaturalidade;
        pr_cdufnatu := rw_pessoa_fisica.cdufnatu;
        pr_dsnatura := rw_pessoa_fisica.dsnatura;
        pr_nmmaecto := rw_pessoa_fisica.nmpessoa_mae;
        pr_nmpaicto := rw_pessoa_fisica.nmpessoa_pai;
        pr_inhabmen := rw_pessoa_fisica.inhabilitacao_menor;
        pr_dthabmen := rw_pessoa_fisica.dthabilitacao_menor;
        
        pr_cdorgao_expedidor := rw_pessoa_fisica.cdorgao_expedidor;
        
        pr_cdsitrfb := rw_pessoa.cdsituacao_rfb;
        pr_dtconrfb := rw_pessoa.dtconsulta_rfb;
        pr_grescola := rw_pessoa_fisica.cdgrau_escolaridade;
        pr_cdfrmttl := rw_pessoa_fisica.cdcurso_superior;
        
        
      ELSE
        CLOSE cr_pessoa_fisica;
      END IF;

    ELSE
      --> Retonar dados da pessoa juridica
      OPEN cr_pessoa_juridica(pr_idpessoa => rw_pessoa.idpessoa);
      FETCH cr_pessoa_juridica INTO rw_pessoa_juridica;

      IF cr_pessoa_juridica%FOUND THEN
        CLOSE cr_pessoa_juridica;
        pr_nmpessoa := rw_pessoa.nmpessoa;
        pr_tpdocume := NULL;
        pr_nrdocume := NULL;
        pr_nmconjug := NULL;
        pr_nrcpfcjg := NULL;
        pr_tpdoccjg := NULL;
        pr_nrdoccjg := NULL;
        pr_dsendre1 := rw_pessoa_juridica.nmlogradouro;
        pr_dsbairro := rw_pessoa_juridica.nmbairro;
        pr_nrfonres := rw_pessoa_juridica.nrtelefone;
        pr_dsdemail := rw_pessoa_juridica.dsemail;
        pr_nmcidade := rw_pessoa_juridica.dscidade;
        pr_cdufresd := rw_pessoa_juridica.cdestado;
        pr_nrcepend := rw_pessoa_juridica.nrcep;
        pr_dsnacion := NULL;
        pr_vledvmto := 0;
        pr_vlrenmes := rw_pessoa_juridica.vlrenda;
        pr_complend := rw_pessoa_juridica.dscomplemento;
        pr_nrendere := rw_pessoa_juridica.nrlogradouro;
        pr_inpessoa := 2;
        pr_dtnascto := NULL;
        pr_cdnacion := NULL;
        pr_cdsitrfb := rw_pessoa.cdsituacao_rfb;
        pr_dtconrfb := rw_pessoa.dtconsulta_rfb;
      ELSE
        CLOSE cr_pessoa_juridica;
      END IF;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    
      pr_nmconjug := NULL;
      pr_nrcpfcjg := NULL;
      pr_tpdoccjg := NULL;
      pr_nrdoccjg := NULL;
        
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_ret_dados_pessoa: ' ||
                     SQLERRM;
  END pc_ret_dados_pessoa;
  
  
  -- Buscar dados da pessoa   - Chamada progress
  PROCEDURE pc_ret_dados_pessoa_prog
                             ( pr_nrcpfcgc  IN crapttl.nrcpfcgc%TYPE,
                               pr_dsxmlret OUT CLOB,
                               pr_dscritic OUT crapcri.dscritic%TYPE) IS
    /* ..........................................................................
    --
    --  Programa : pc_ret_dados_pessoa_prog
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana (AMcom)
    --  Data     : Outubro/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar dados da pessoa - Chamada progress
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    -------> VARIAVEIS <-------
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(2000);
    
    vr_dstexto     VARCHAR2(32767);
		vr_string      VARCHAR2(32767);
    
    vr_nmpessoa crapavt.nmdavali%TYPE;
    vr_tpdocava crapavt.tpdocava%TYPE;
    vr_nrdocava crapavt.nrdocava%TYPE;
    vr_nmconjug crapavt.nmconjug%TYPE;
    vr_nrcpfcjg crapavt.nrcpfcjg%TYPE;
    vr_tpdoccjg crapavt.tpdoccjg%TYPE;
    vr_nrdoccjg crapavt.nrdoccjg%TYPE;
    vr_dsendre1 crapavt.dsendres##1%TYPE;
    vr_dsbairro crapavt.dsendres##2%TYPE;
    vr_nrfonres crapavt.nrfonres%TYPE;
    vr_dsdemail crapavt.dsdemail%TYPE;
    vr_nmcidade crapavt.nmcidade%TYPE;
    vr_cdufresd crapavt.cdufresd%TYPE;
    vr_nrcepend crapavt.nrcepend%TYPE;
    vr_dsnacion crapnac.dsnacion%TYPE;
    vr_vledvmto crapavt.vledvmto%TYPE;
    vr_vlrenmes crapavt.vlrenmes%TYPE;
    vr_complend VARCHAR2(500);
    vr_nrendere crapavt.nrendere%TYPE;
    vr_inpessoa crapavt.inpessoa%TYPE;
    vr_dtnascto crapavt.dtnascto%TYPE;
    vr_cdnacion crapavt.cdnacion%TYPE;
    vr_cdufddoc crapavt.cdufddoc%TYPE;
    vr_dtemddoc crapavt.dtemddoc%TYPE;
    vr_cdsexcto crapavt.cdsexcto%TYPE;
    vr_cdestcvl crapavt.cdestcvl%TYPE;
    vr_cdnatura crapmun.idcidade%TYPE;
    vr_dsnatura crapnat.dsnatura%TYPE;
    vr_cdufnatu crapttl.cdufnatu%TYPE;
    vr_nmmaecto crapavt.nmmaecto%TYPE;
    vr_nmpaicto crapavt.nmpaicto%TYPE;
    vr_inhabmen crapavt.inhabmen%TYPE;
    vr_dthabmen crapavt.dthabmen%TYPE; 
    vr_cdorgao_expedidor tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
    vr_cdsitrfb tbcadast_pessoa.cdsituacao_rfb%TYPE;
    vr_dtconrfb tbcadast_pessoa.dtconsulta_rfb%TYPE;
    vr_grescola tbcadast_pessoa_fisica.cdgrau_escolaridade%TYPE;
    vr_cdfrmttl tbcadast_pessoa_fisica.cdcurso_superior%TYPE;   
    vr_tpnacion crapttl.tpnacion%TYPE;                             
    

  BEGIN
  
    -- Buscar dados da pessoa para utilização como avalista
    pc_ret_dados_pessoa( pr_nrcpfcgc => pr_nrcpfcgc,
                       pr_nmpessoa => vr_nmpessoa,
                       pr_tpdocume => vr_tpdocava,
                       pr_nrdocume => vr_nrdocava,
                       pr_nmconjug => vr_nmconjug,
                       pr_nrcpfcjg => vr_nrcpfcjg,
                       pr_tpdoccjg => vr_tpdoccjg,
                       pr_nrdoccjg => vr_nrdoccjg,
                       pr_dsendre1 => vr_dsendre1,
                       pr_dsbairro => vr_dsbairro,
                       pr_nrfonres => vr_nrfonres,
                       pr_dsdemail => vr_dsdemail,
                       pr_nmcidade => vr_nmcidade,
                       pr_cdufresd => vr_cdufresd,
                       pr_nrcepend => vr_nrcepend,
                       pr_dsnacion => vr_dsnacion,
                       pr_vledvmto => vr_vledvmto,
                       pr_vlrenmes => vr_vlrenmes,
                       pr_complend => vr_complend,
                       pr_nrendere => vr_nrendere,
                       pr_inpessoa => vr_inpessoa,
                       pr_dtnascto => vr_dtnascto,
                       pr_tpnacion => vr_tpnacion,
                       pr_cdnacion => vr_cdnacion,
                       pr_cdufddoc => vr_cdufddoc,
                       pr_dtemddoc => vr_dtemddoc,
                       pr_cdsexcto => vr_cdsexcto,
                       pr_cdestcvl => vr_cdestcvl,
                       pr_cdnatura => vr_cdnatura,
                       pr_dsnatura => vr_dsnatura,
                       pr_cdufnatu => vr_cdufnatu,
                       pr_nmmaecto => vr_nmmaecto,
                       pr_nmpaicto => vr_nmpaicto,
                       pr_inhabmen => vr_inhabmen,
                       pr_dthabmen => vr_dthabmen,
                       pr_cdorgao_expedidor => vr_cdorgao_expedidor,
                       pr_cdsitrfb => vr_cdsitrfb,
                       pr_dtconrfb => vr_dtconrfb,
                       pr_grescola => vr_grescola,
                       pr_cdfrmttl => vr_cdfrmttl,
                       pr_dscritic => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_nmpessoa IS NOT NULL THEN
      -- Criar documento XML
      dbms_lob.createtemporary(pr_dsxmlret, TRUE);
      dbms_lob.open(pr_dsxmlret, dbms_lob.lob_readwrite);
  				
      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_dsxmlret,
                              pr_texto_completo => vr_dstexto,
                              pr_texto_novo     => '<root>');
  				
      vr_string := '<avalista>' || 
                      '<nmpessoa>'||    vr_nmpessoa  ||'</nmpessoa>'||
                      '<tpdocume>'||    vr_tpdocava  ||'</tpdocume>'||
                      '<nrdocume>'||    vr_nrdocava  ||'</nrdocume>'||
                      '<nmconjug>'||    vr_nmconjug  ||'</nmconjug>'||
                      '<nrcpfcjg>'||    vr_nrcpfcjg  ||'</nrcpfcjg>'||
                      '<tpdoccjg>'||    vr_tpdoccjg  ||'</tpdoccjg>'||
                      '<nrdoccjg>'||    vr_nrdoccjg  ||'</nrdoccjg>'||
                      '<dsendre1>'||    vr_dsendre1  ||'</dsendre1>'||
                      '<dsbairro>'||    vr_dsbairro  ||'</dsbairro>'||
                      '<nrfonres>'||    vr_nrfonres  ||'</nrfonres>'||
                      '<dsdemail>'||    vr_dsdemail  ||'</dsdemail>'||
                      '<nmcidade>'||    vr_nmcidade  ||'</nmcidade>'||
                      '<cdufresd>'||    vr_cdufresd  ||'</cdufresd>'||
                      '<nrcepend>'||    vr_nrcepend  ||'</nrcepend>'||
                      '<dsnacion>'||    vr_dsnacion  ||'</dsnacion>'||
                      '<vledvmto>'||    vr_vledvmto  ||'</vledvmto>'||
                      '<vlrenmes>'||    vr_vlrenmes  ||'</vlrenmes>'||
                      '<complend>'||    vr_complend  ||'</complend>'||
                      '<nrendere>'||    vr_nrendere  ||'</nrendere>'||
                      '<inpessoa>'||    vr_inpessoa  ||'</inpessoa>'||
                      '<dtnascto>'||    to_char(vr_dtnascto,'DD/MM/RRRR')  ||'</dtnascto>'||                      
                      '<tpnacion>'||    vr_tpnacion  ||'</tpnacion>'||   
                      '<cdnacion>'||    vr_cdnacion  ||'</cdnacion>'||   
                      '<cdufddoc>'||    vr_cdufddoc  ||'</cdufddoc>'||   
                      '<dtemddoc>'||    to_char(vr_dtemddoc,'DD/MM/RRRR')  ||'</dtemddoc>'||   
                      '<cdsexcto>'||    vr_cdsexcto  ||'</cdsexcto>'||   
                      '<cdestcvl>'||    vr_cdestcvl  ||'</cdestcvl>'||   
                      '<cdnatura>'||    vr_cdnatura  ||'</cdnatura>'||   
                      '<dsnatura>'||    vr_dsnatura  ||'</dsnatura>'||   
                      '<cdufnatu>'||    vr_cdufnatu  ||'</cdufnatu>'||                         
                      '<nmmaecto>'||    vr_nmmaecto  ||'</nmmaecto>'||   
                      '<nmpaicto>'||    vr_nmpaicto  ||'</nmpaicto>'||   
                      '<inhabmen>'||    vr_inhabmen  ||'</inhabmen>'||   
                      '<dthabmen>'||    to_char(vr_dthabmen,'DD/MM/RRRR')  ||'</dthabmen>'||                                            
                      '<cdorgemi>'||    vr_cdorgao_expedidor || '</cdorgemi>'||                                  
                      '<cdsitrfb>'||    vr_cdsitrfb || '</cdsitrfb>'||
                      '<dtconrfb>'||    to_char(vr_dtconrfb,'DD/MM/RRRR')  ||'</dtconrfb>'||
                      '<grescola>'||    vr_grescola  ||'</grescola>'||   
                      '<cdfrmttl>'||    vr_cdfrmttl  ||'</cdfrmttl>'||   
       '</avalista>';
  						
      -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_dsxmlret,
                              pr_texto_completo => vr_dstexto,
                              pr_texto_novo     => vr_string,
                              pr_fecha_xml      => FALSE);
  				
      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_dsxmlret,
                              pr_texto_completo => vr_dstexto,
                              pr_texto_novo     => '</root>',
                              pr_fecha_xml      => TRUE);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
          
        
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_ret_dados_pessoa_prog: ' ||
                     SQLERRM;
  END pc_ret_dados_pessoa_prog;
  
  -- Atualiza os dados alterados na tela CADCTA
  PROCEDURE pc_atualiza_dados_cadcta(pr_cdcooper IN crapcop.cdcooper%TYPE                                    
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE
                                    ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE
                                    ,pr_idorigem IN INTEGER
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE
                                    ,pr_cdbcochq IN crapass.cdbcochq%TYPE
                                    ,pr_cdconsul IN tbcc_consultor.cdconsultor%TYPE
                                    ,pr_cdagedbb IN crapcop.cdagedbb%TYPE
                                    ,pr_nrdctitg IN crapass.nrdctitg%TYPE
                                    ,pr_nrctacns IN crapass.nrctacns%TYPE
                                    ,pr_incadpos IN crapass.incadpos%TYPE
                                    ,pr_flgiddep IN crapass.flgiddep%TYPE
                                    ,pr_flgrestr IN crapass.flgrestr%TYPE
                                    ,pr_indserma IN crapass.indserma%TYPE
                                    ,pr_inlbacen IN crapass.inlbacen%TYPE
                                    ,pr_nmtalttl IN crapttl.nmtalttl%TYPE
                                    ,pr_qtfoltal IN crapass.qtfoltal%TYPE
                                    ,pr_cdempres IN crapttl.cdempres%TYPE
                                    ,pr_nrinfcad IN crapttl.nrinfcad%TYPE
                                    ,pr_nrpatlvr IN crapttl.nrpatlvr%TYPE
                                    ,pr_dsinfadi IN crapttl.dsinfadi%TYPE     
                                    ,pr_nmctajur IN crapjur.nmctajur%TYPE     -->  Nome conta juridica
                                    ,pr_cdcritic OUT INTEGER                  --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                 --> Descrição da crítica
                                    ) IS               
                                         
	/* ..........................................................................
    --
    --  Programa : pc_atualiza_dados_cadcta
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Mateus Zimmermann (Mouts)
    --  Data     : Outubro/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Atualizados os dados alterados na tela CADCTA
    --
    --  Alteração :
    --
    --		05/08/2019 - Não atualizar o flag do cadastro positivo através das 
    --                   telas do Aimaro. (	Miguel Rodrigues - Supero )
    -- ..........................................................................*/
  
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      vr_inpessoa      INTEGER;
      

    BEGIN

      
        
        IF pr_qtfoltal <> 10 AND pr_qtfoltal <> 20 THEN
          vr_dscritic := 'Quantidade de folhas do talao de cheques deve ser 10 ou 20.';
          RAISE vr_exc_saida;
        END IF;
        
        IF pr_nmtalttl = '' THEN
          vr_dscritic := 'Nome que aparecera no talao de cheques deve ser informado.';
          RAISE vr_exc_saida;
        END IF;                  

        -- Atualizar CRAPASS
        BEGIN
          UPDATE crapass
            SET cdbcochq = pr_cdbcochq,
                nrdctitg = pr_nrdctitg,
                nrctacns = pr_nrctacns,
                --incadpos = pr_incadpos,  -- Não atualizar flag de cadastro positivo
                flgiddep = pr_flgiddep,
                flgrestr = pr_flgrestr,
                indserma = pr_indserma,
                inlbacen = pr_inlbacen,
                qtfoltal = pr_qtfoltal 
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta
           RETURNING inpessoa INTO vr_inpessoa;
            
        EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao atualizar CRAPASS: '||SQLERRM;
           RAISE vr_exc_saida;
        END;
        
      IF vr_inpessoa = 1 THEN
      
        -- Atualizar CRAPASS
        BEGIN
          UPDATE crapttl
             SET nmtalttl = upper(pr_nmtalttl)
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND idseqttl = pr_idseqttl;
              
        EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao atualizar CRAPTTL: '||SQLERRM;
           RAISE vr_exc_saida;
        END;
      
      ELSE 
        -- Atualizar CRAPASS
        BEGIN
          UPDATE crapjur
             SET nmctajur = upper(pr_nmctajur),
                 nmtalttl = upper(pr_nmtalttl)
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta;
              
        EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao atualizar CRAPJUR: '||SQLERRM;
           RAISE vr_exc_saida;
        END;
      
      END IF;
      
    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PC_ATUALIZA_DADOS_CADCTA: ' || SQLERRM;
        
  END pc_atualiza_dados_cadcta;
  
  -- Buscar nr. de sequência de telefone para inclusoes de telefone pela MATRIC
	PROCEDURE pc_busca_crapjur(pr_nrcpfcgc IN  tbcadast_pessoa.nrcpfcgc%TYPE
		                        ,pr_qtfuncio out tbcadast_pessoa_juridica.qtfuncionario%TYPE
                            ,pr_vlcaprea out tbcadast_pessoa_juridica.vlcapital%TYPE
                            ,pr_dtregemp out tbcadast_pessoa_juridica.dtregistro%TYPE
                            ,pr_nrregemp out tbcadast_pessoa_juridica.nrregistro%TYPE
                            ,pr_orregemp out tbcadast_pessoa_juridica.dsorgao_registro%TYPE
                            ,pr_nrcdnire out tbcadast_pessoa_juridica.nrnire%TYPE
                            ,pr_dtinsmun out tbcadast_pessoa_juridica.dtinscricao_municipal%TYPE
                            ,pr_flgrefis out tbcadast_pessoa_juridica.inrefis%TYPE
                            ,pr_dsendweb out tbcadast_pessoa_juridica.dssite%TYPE
                            ,pr_nrinsmun out tbcadast_pessoa_juridica.nrinscricao_municipal%TYPE
                            ,pr_vlfatano out tbcadast_pessoa_juridica.vlfaturamento_anual%TYPE
                            ,pr_nrlicamb out tbcadast_pessoa_juridica.nrlicenca_ambiental%TYPE
                            ,pr_dtvallic out tbcadast_pessoa_juridica.dtvalidade_licenca_amb%TYPE
                            ,pr_tpregtrb out tbcadast_pessoa_juridica.tpregime_tributacao%TYPE
                            ,pr_qtfilial OUT tbcadast_pessoa_juridica.qtfilial%TYPE
													  ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    /* ..........................................................................
    --
    --  Programa : pc_busca_crapjur
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Andrino Carlos de Souza Junior (Mouts)
    --  Data     : Outubro/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para retornar os dados da conjuta juridica que nao foram
    --               informados pela tela MATRIC
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
		
		/* Buscar os dados da conta juridica que nao existem na tela matric */
		CURSOR cr_pessoa IS
			SELECT a.qtfuncionario,
             a.vlcapital,
             a.dtregistro,
             a.nrregistro,
             a.dsorgao_registro,
             a.nrnire,
             a.dtinscricao_municipal,
             a.inrefis,
             a.dssite,
             a.nrinscricao_municipal,
             a.vlfaturamento_anual,
             a.nrlicenca_ambiental,
             a.dtvalidade_licenca_amb,
             a.tpregime_tributacao,
             a.qtfilial
			  FROM tbcadast_pessoa_juridica a,
             tbcadast_pessoa b
			 WHERE b.nrcpfcgc   = pr_nrcpfcgc
         AND b.tpcadastro > 2 -- Somente intermediario ou completo
			   AND a.idpessoa   = b.idpessoa;
	  rw_pessoa cr_pessoa%ROWTYPE;
	BEGIN
		-- Buscar nr. seq. do telefone do associado
	  OPEN cr_pessoa;
		FETCH cr_pessoa INTO rw_pessoa;
		
    -- Se encontrou pessoa
    IF cr_pessoa%FOUND THEN
      -- Efetua a devolucao nas variaveis
      pr_qtfuncio := rw_pessoa.qtfuncionario;
      pr_vlcaprea := rw_pessoa.vlcapital;
      pr_dtregemp := rw_pessoa.dtregistro;
      pr_nrregemp := rw_pessoa.nrregistro;
      pr_orregemp := rw_pessoa.dsorgao_registro;
      pr_nrcdnire := rw_pessoa.nrnire;
      pr_dtinsmun := rw_pessoa.dtinscricao_municipal;
      pr_flgrefis := rw_pessoa.inrefis;
      pr_dsendweb := rw_pessoa.dssite;
      pr_nrinsmun := rw_pessoa.nrinscricao_municipal;
      pr_vlfatano := rw_pessoa.vlfaturamento_anual;
      pr_nrlicamb := rw_pessoa.nrlicenca_ambiental;
      pr_dtvallic := rw_pessoa.dtvalidade_licenca_amb;
      pr_tpregtrb := rw_pessoa.tpregime_tributacao;
      pr_qtfilial := rw_pessoa.qtfilial;
    END IF;

		-- Fechar cursor
		CLOSE cr_pessoa;
		
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_busca_crapjur: ' ||
                     SQLERRM;		
	END pc_busca_crapjur;
  
  
  -- Buscar dados complementares do titular para cadastramento do titular
	PROCEDURE pc_busca_crapttl_compl( pr_cdcooper     IN crapttl.cdcooper%TYPE,
                                    pr_cdempres     IN crapttl.cdempres%TYPE,
                                    pr_nrcpfcgc     IN crapttl.nrcpfcgc%TYPE,
                                    pr_cdnatopc    OUT crapttl.cdnatopc%TYPE,
                                    pr_cdocpttl    OUT crapttl.cdocpttl%TYPE,
                                    pr_tpcttrab    OUT crapttl.tpcttrab%TYPE,
                                    pr_nmextemp    OUT crapttl.nmextemp%TYPE,
                                    pr_nrcpfemp    OUT crapttl.nrcpfemp%TYPE,
                                    pr_dtadmemp    OUT crapttl.dtadmemp%TYPE,
                                    pr_dsproftl    OUT crapttl.dsproftl%TYPE,
                                    pr_cdnvlcgo    OUT crapttl.cdnvlcgo%TYPE,
                                    pr_vlsalari    OUT crapttl.vlsalari%TYPE,
                                    pr_cdturnos    OUT crapttl.cdturnos%TYPE,
                                    pr_dsjusren    OUT crapttl.dsjusren%TYPE,
                                    pr_dtatutel    OUT crapttl.dtatutel%TYPE,
                                    pr_cdgraupr    OUT crapttl.cdgraupr%TYPE,
                                    pr_cdfrmttl    OUT crapttl.cdfrmttl%TYPE,
                                    pr_tpdrendi##1 OUT crapttl.tpdrendi##1%TYPE,
                                    pr_vldrendi##1 OUT crapttl.vldrendi##1%TYPE,
                                    pr_tpdrendi##2 OUT crapttl.tpdrendi##1%TYPE,
                                    pr_vldrendi##2 OUT crapttl.vldrendi##1%TYPE,
                                    pr_tpdrendi##3 OUT crapttl.tpdrendi##1%TYPE,
                                    pr_vldrendi##3 OUT crapttl.vldrendi##1%TYPE,
                                    pr_tpdrendi##4 OUT crapttl.tpdrendi##1%TYPE,
                                    pr_vldrendi##4 OUT crapttl.vldrendi##1%TYPE,
                                    pr_tpdrendi##5 OUT crapttl.tpdrendi##1%TYPE,
                                    pr_vldrendi##5 OUT crapttl.vldrendi##1%TYPE,
                                    pr_tpdrendi##6 OUT crapttl.tpdrendi##1%TYPE,
                                    pr_vldrendi##6 OUT crapttl.vldrendi##1%TYPE,
                                    pr_nmpaittl    OUT crapttl.nmpaittl%TYPE,
                                    pr_nmmaettl    OUT crapttl.nmmaettl%TYPE,
                                    pr_dscritic    OUT crapcri.dscritic%TYPE) IS
    /* ..........................................................................
    --
    --  Programa : pc_busca_dados_ttl_compl
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana (AMcom)
    --  Data     : Outubro/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Buscar dados complementares do titular para cadastramento do titular
    --
    --  Alteração : 06/09/2018 - Ajustes nas rotinas envolvidas na unificação cadastral e CRM para
    --                           corrigir antigos e evitar futuros problemas. (INC002926 - Kelvin)
    --
    --
    -- ..........................................................................*/
		
		--> retonar dados da pessoa fisica
		CURSOR cr_pessoa_fisica IS
			SELECT *
			  FROM vwcadast_pessoa_fisica p
			 WHERE p.nrcpf = pr_nrcpfcgc;
    rw_pessoa_fisica cr_pessoa_fisica%ROWTYPE;
    
    --> buscar dados da renda   
    CURSOR cr_pessoa_renda (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE )IS
			SELECT r.*,
             e.nrcpfcgc,
             e.nmpessoa             
			  FROM tbcadast_pessoa_renda r,
             tbcadast_pessoa e
			 WHERE r.idpessoa = pr_idpessoa
         AND r.idpessoa_fonte_renda = e.idpessoa;
    rw_pessoa_renda cr_pessoa_renda%ROWTYPE;
    
		
    --> buscar dados da renda complementar
    CURSOR cr_pessoa_renda_compl (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE )IS
			SELECT r.*
			  FROM tbcadast_pessoa_rendacompl r
			 WHERE r.idpessoa = pr_idpessoa
       ORDER BY r.nrseq_renda ASC;
    rw_pessoa_renda_compl cr_pessoa_renda_compl%ROWTYPE;
    
    CURSOR cr_crapemp(pr_cdcooper crapttl.cdcooper%TYPE
                     ,pr_cdempres crapttl.cdempres%TYPE) IS
      SELECT emp.nrdocnpj
            ,emp.nmextemp
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.cdempres = pr_cdempres;
         
      rw_crapemp cr_crapemp%ROWTYPE;
	BEGIN
  
    --> retonar dados da pessoa fisica
    OPEN cr_pessoa_fisica;
      FETCH cr_pessoa_fisica 
        INTO rw_pessoa_fisica;
    CLOSE cr_pessoa_fisica;
    
    --> buscar dados da renda
    OPEN cr_pessoa_renda (pr_idpessoa => rw_pessoa_fisica.idpessoa);
      FETCH cr_pessoa_renda 
        INTO rw_pessoa_renda;
    CLOSE cr_pessoa_renda;		
    
    OPEN cr_crapemp(pr_cdcooper
                   ,pr_cdempres);
      FETCH cr_crapemp
        INTO rw_crapemp;
    CLOSE cr_crapemp;
      
    pr_cdnatopc := rw_pessoa_fisica.cdnatureza_ocupacao;
    pr_cdocpttl := rw_pessoa_renda.cdocupacao;
    pr_tpcttrab := rw_pessoa_renda.tpcontrato_trabalho;
    
    --Atribuicao dos valores atraves da tabela crapemp
    pr_nmextemp := NVL(substr(rw_crapemp.nmextemp,1,40),' ');
    pr_nrcpfemp := NVL(rw_crapemp.nrdocnpj,0);      

    pr_dtadmemp := rw_pessoa_renda.dtadmissao;
    pr_dsproftl := rw_pessoa_fisica.dsprofissao ;
    pr_cdnvlcgo := rw_pessoa_renda.cdnivel_cargo;
    pr_vlsalari := rw_pessoa_renda.vlrenda;
    pr_cdturnos := rw_pessoa_renda.cdturno;
    pr_dsjusren := rw_pessoa_fisica.dsjustific_outros_rend;
    pr_dtatutel := rw_pessoa_fisica.dtatualiza_telefone;    
    pr_cdgraupr := rw_pessoa_fisica.cdgrau_escolaridade;    
    pr_cdfrmttl := rw_pessoa_fisica.cdcurso_superior;
    pr_nmpaittl := cada0016.fn_nome_pes_relacao(pr_idpessoa  => rw_pessoa_fisica.idpessoa, 
                                                pr_tprelacao => 3);
                                                  
    pr_nmmaettl := cada0016.fn_nome_pes_relacao(pr_idpessoa  => rw_pessoa_fisica.idpessoa, 
                                                pr_tprelacao => 4); 
    
    
    --> buscar dados da renda complementar
    FOR rw_pessoa_renda_compl IN cr_pessoa_renda_compl (pr_idpessoa => rw_pessoa_fisica.idpessoa) LOOP
      
      CASE rw_pessoa_renda_compl.nrseq_renda 
        WHEN 1 THEN
          pr_tpdrendi##1 := rw_pessoa_renda_compl.tprenda;
          pr_vldrendi##1 := rw_pessoa_renda_compl.vlrenda;
        WHEN 2 THEN
          pr_tpdrendi##2 := rw_pessoa_renda_compl.tprenda;
          pr_vldrendi##2 := rw_pessoa_renda_compl.vlrenda;
        WHEN 3 THEN
          pr_tpdrendi##3 := rw_pessoa_renda_compl.tprenda;
          pr_vldrendi##3 := rw_pessoa_renda_compl.vlrenda;
        WHEN 4 THEN
          pr_tpdrendi##4 := rw_pessoa_renda_compl.tprenda;
          pr_vldrendi##4 := rw_pessoa_renda_compl.vlrenda;
        WHEN 5 THEN
          pr_tpdrendi##5 := rw_pessoa_renda_compl.tprenda;
          pr_vldrendi##5 := rw_pessoa_renda_compl.vlrenda;
        WHEN 6 THEN
          pr_tpdrendi##6 := rw_pessoa_renda_compl.tprenda;
          pr_vldrendi##6 := rw_pessoa_renda_compl.vlrenda;
        ELSE
          NULL;
      END CASE;
    
    END LOOP;
		
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_busca_crapttl_compl: ' ||
                     SQLERRM;		
	END pc_busca_crapttl_compl; 

  -- Rotina para marcar registros da TBCADAST_PESSOA_* a serem replicados para o AYLLOS
  PROCEDURE pc_marca_replica_ayllos (pr_cdcooper IN NUMBER  -- Codigo da cooperativa
                                    ,pr_nrdconta IN NUMBER  -- Numero da conta
                                    ,pr_idseqttl IN NUMBER DEFAULT 1 -- Sequencia do titular
                                    ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
    -- Cursor para buscar o ID_PESSOA da conta
    CURSOR cr_busca_idpessoa IS

      SELECT tps.idpessoa,
             ttl.cdestcvl
        FROM tbcadast_pessoa tps
            ,crapass         ass
            ,crapttl         ttl
       WHERE ass.nrdconta     = pr_nrdconta
         AND ass.cdcooper     = pr_cdcooper
         AND ass.dtdemiss    IS NULL
         AND ttl.nrdconta (+) = ass.nrdconta
         AND ttl.cdcooper (+) = ass.cdcooper
         AND ttl.idseqttl (+) = pr_idseqttl
         AND tps.nrcpfcgc     = nvl(ttl.nrcpfcgc,ass.nrcpfcgc);
    -- Variaveis
    w_dscritic VARCHAR2(1000);
    w_nmtabela VARCHAR2(1000);

  BEGIN

    FOR r_busca_idpessoa in cr_busca_idpessoa LOOP

      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1 -- Processo normal
                                ,pr_nmarqlog => 'CRM' 
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                   'Parâmetros -> cdcooper: '|| pr_cdcooper 
                                             || ', nrdconta: '|| pr_nrdconta
                                             || ', idseqttl: '|| pr_idseqttl);

      
      --> marcar registro para ser processado apenas 
      --> pela rotina de replicacao online
      --> para nao gerar lock qnd executado via job
      BEGIN
        UPDATE tbcadast_pessoa_atualiza a
           SET a.insit_atualiza = 4 --> processar online 
         WHERE a.insit_atualiza = 1 --> pendente
           AND a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta;
      EXCEPTION 
        WHEN OTHERS THEN
          --se deu algum erro deixar para replicacao job
          NULL;
      END;
      
      pr_dscritic := null;

      -- Rotina para processar registros pendentes de atualização
      cada0015.pc_processa_pessoa_atlz( pr_cdcooper => pr_cdcooper, --> Codigo da coperativa quando processo de replic. online
                                        pr_nrdconta => pr_nrdconta, --> Nr. da conta quando processo de replic. online 
                                        pr_dscritic => w_dscritic);
      IF w_dscritic IS NOT NULL THEN
        pr_dscritic := 'Erro não tratado na pc_marca_replica_ayllos: ' ||
                       w_dscritic;
      END IF;

      IF pr_dscritic IS NULL THEN

        -- Marcar registros a serem replicados para o AYLLOS

        w_nmtabela := 'TBCADAST_PESSOA';
        UPDATE TBCADAST_PESSOA
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_BEM';
        UPDATE TBCADAST_PESSOA_BEM
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_EMAIL';
        UPDATE TBCADAST_PESSOA_EMAIL
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_ENDERECO';
        UPDATE TBCADAST_PESSOA_ENDERECO
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_ESTRANGEIRA';
        UPDATE TBCADAST_PESSOA_ESTRANGEIRA
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_FISICA';
        UPDATE TBCADAST_PESSOA_FISICA
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_FISICA_DEP';
        UPDATE TBCADAST_PESSOA_FISICA_DEP
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_FISICA_RESP';
        UPDATE TBCADAST_PESSOA_FISICA_RESP
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_JURIDICA';
        UPDATE TBCADAST_PESSOA_JURIDICA
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_JURIDICA_BCO';
        UPDATE TBCADAST_PESSOA_JURIDICA_BCO
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_JURIDICA_FAT';
        UPDATE TBCADAST_PESSOA_JURIDICA_FAT
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_JURIDICA_FNC';
        UPDATE TBCADAST_PESSOA_JURIDICA_FNC
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_JURIDICA_PTP';
        UPDATE TBCADAST_PESSOA_JURIDICA_PTP
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_JURIDICA_REP';
        UPDATE TBCADAST_PESSOA_JURIDICA_REP
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_POLEXP';
        UPDATE TBCADAST_PESSOA_POLEXP
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_REFERENCIA';
        UPDATE TBCADAST_PESSOA_REFERENCIA
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_RELACAO';
        -- Se o estado civil nao tiver conjuge, exclui o mesmo
        IF nvl(r_busca_idpessoa.cdestcvl,0) IN (1,5,6,7) THEN
          DELETE TBCADAST_PESSOA_RELACAO
           WHERE idpessoa = r_busca_idpessoa.idpessoa
             AND tprelacao = 1; -- Conjuge
        END IF;
          
        UPDATE TBCADAST_PESSOA_RELACAO
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_RENDA';
        UPDATE TBCADAST_PESSOA_RENDA
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_RENDACOMPL';
        UPDATE TBCADAST_PESSOA_RENDACOMPL
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

        w_nmtabela := 'TBCADAST_PESSOA_TELEFONE';
        UPDATE TBCADAST_PESSOA_TELEFONE
           SET idpessoa = idpessoa
         WHERE idpessoa = r_busca_idpessoa.idpessoa;

      END IF;
    END LOOP;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                   , pr_compleme => 'cdcooper: '|| pr_cdcooper 
                                               || ', nrdconta: '|| pr_nrdconta
                                               || ', idseqttl: '|| pr_idseqttl);       
    
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_marca_replica_ayllos-'||w_nmtabela||': ' ||
                     SQLERRM;
                     
     btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'CRM' 
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                       'Parâmetros -> cdcooper: '|| pr_cdcooper 
                                             || ', nrdconta: '|| pr_nrdconta
                                             || ', idseqttl: '|| pr_idseqttl 
                                             || ', Erro -> '  || pr_dscritic);                     
  END pc_marca_replica_ayllos;
  
  -- Rotina para buscar o nome da pessoa e indicador se o nome pode ser alterado ou nao
  PROCEDURE pc_busca_nome_pessoa(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE,
                                 pr_nmpessoa OUT tbcadast_pessoa.nmpessoa%TYPE,
                                 pr_idaltera OUT PLS_INTEGER, -- Indicador se permite alterar nome (0-Nao permite, 1-Permite alterar nome)
                                 pr_dscritic OUT VARCHAR2) IS
    -- Cursor sobre o cadastro de pessoa
    CURSOR cr_pessoa IS
      SELECT a.nmpessoa,
             a.tpcadastro
        FROM tbcadast_pessoa a
       WHERE a.nrcpfcgc = pr_nrcpfcgc;                                 
    rw_pessoa cr_pessoa%ROWTYPE;
    -- Cursor sobre o cadastro de empresa
    CURSOR cr_crapemp (pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT emp.cdempres
      FROM crapemp emp
     WHERE emp.nrdocnpj = pr_nrcpfcgc;                                 
    rw_crapemp cr_crapemp%ROWTYPE;    
  BEGIN
    -- Busca os dados da pessoa
    OPEN cr_pessoa;
    FETCH cr_pessoa INTO rw_pessoa;
    IF cr_pessoa%NOTFOUND THEN
      pr_idaltera := 1; -- Permite alterar
    ELSE
      pr_nmpessoa := rw_pessoa.nmpessoa;
      -- Se o tipo de cadastro for intermediario ou completo, eh que possui conta.
      -- Neste caso, nao deve permitir alterar o nome
      IF rw_pessoa.tpcadastro IN (3,4) THEN
        pr_idaltera := 0; -- Nao permite alterar
      ELSE -- Nao possui conta
        OPEN cr_crapemp (pr_nrcpfcgc);
        FETCH cr_crapemp INTO rw_crapemp;
        CLOSE cr_crapemp;
        IF rw_crapemp.cdempres IS NOT NULL THEN
          pr_idaltera := 0; -- Nao permite alterar
        ELSE	
        pr_idaltera := 1; -- Permite alterar
      END IF;
    END IF;
    END IF;
    CLOSE cr_pessoa;
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception();
      pr_dscritic := 'Erro nao previsto CADA0008.PC_BUSCA_NOME_PESSOA: '||SQLERRM;
  END pc_busca_nome_pessoa;
  
  -- Rotina para buscar o nome da pessoa e indicador se o nome pode ser alterado ou nao
  PROCEDURE pc_busca_nome_pessoa_xml(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE,
                                     pr_xmllog   IN VARCHAR2,               --> XML com informações de LOG
                                     pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                     pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                     pr_retxml   IN OUT NOCOPY XMLType,     --> Arquivo de retorno do XML
                                     pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                     pr_des_erro OUT VARCHAR2) IS           --> Erros do processo

    --Variaveis
    vr_nmpessoa tbcadast_pessoa.nmpessoa%TYPE;
    vr_idaltera PLS_INTEGER;
    
    -- Controle de erro
    vr_dscritic VARCHAR2(1000);
    vr_exc_saida     EXCEPTION;
    
    --Variaveis de LOG
    vr_cdoperad      VARCHAR2(100);
    vr_cdcooper      NUMBER;
    vr_nmdatela      VARCHAR2(100);
    vr_nmeacao       VARCHAR2(100);
    vr_cdagenci      VARCHAR2(100);
    vr_nrdcaixa      VARCHAR2(100);
    vr_idorigem      VARCHAR2(100);

  BEGIN
    -- Busca o nome da pessoa
    CADA0008.pc_busca_nome_pessoa(pr_nrcpfcgc => pr_nrcpfcgc,
                                  pr_nmpessoa => vr_nmpessoa,
                                  pr_idaltera => vr_idaltera,
                                  pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;  

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
    -- Preenche os dados
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmpessoa', pr_tag_cont => vr_nmpessoa, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'idaltera', pr_tag_cont => vr_idaltera, pr_des_erro => vr_dscritic);
                                  
  EXCEPTION
    WHEN vr_exc_saida THEN
      CECRED.pc_internal_exception();
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      CECRED.pc_internal_exception();
      pr_dscritic := 'Erro nao previsto CADA0008.PC_BUSCA_NOME_PESSOA_XML: '||SQLERRM;
  END pc_busca_nome_pessoa_xml;
  
  -- Rotina para buscar informacoes da empresa 
  PROCEDURE pc_busca_inf_emp(pr_cdcooper IN crapemp.cdcooper%TYPE,
                             pr_cdempres IN crapemp.cdempres%TYPE,    
                             pr_nrdconta IN crapass.nrdconta%TYPE,
                             pr_idseqttl IN crapttl.idseqttl%TYPE,
                             pr_nrdocnpj IN crapemp.nrdocnpj%TYPE,
                             pr_nmpessoa IN tbcadast_pessoa.nmpessoa%TYPE,
                             pr_nmpessot OUT tbcadast_pessoa.nmpessoa%TYPE,
                             pr_idaltera OUT PLS_INTEGER, -- Indicador se permite alterar nome (0-Nao permite, 1-Permite alterar nome)
                             pr_nrcnpjot OUT crapemp.nrdocnpj%TYPE,
                             pr_nmempout OUT crapemp.nmresemp%TYPE,
                             pr_cdemprot OUT crapemp.cdempres%TYPE,
                             pr_dscritic OUT VARCHAR2) IS
                             
    /* ..........................................................................
    --
    --  Programa : pc_busca_inf_emp_xml
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Kelvin Ott
    --  Data     : Julho/2018.                   Ultima atualizacao: 20/09/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para buscar informacoes da empresa 
    --
    --  Alteração : 20/09/2018 - Ajustes nas rotinas envolvidas na unificação cadastral e CRM para
    --                           corrigir antigos e evitar futuros problemas. (INC002926 - Kelvin)
 	--              24/10/2018 - AJuste para não retornar dados incorretos para a tela
	--                           CONTAS >> DADOS COMERCIAL : Alcemir (Mouts) - INC0024687.                 
    --
    -- ..........................................................................*/
    
    -- Cursor sobre o cadastro de pessoa
    CURSOR cr_crapemp (pr_cdcooper IN crapemp.cdcooper%TYPE,
                       pr_cdempres IN crapemp.cdempres%TYPE) IS
      SELECT emp.nrdocnpj
            ,emp.nmextemp
            ,emp.nmresemp
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.cdempres = pr_cdempres;
      
    rw_crapemp cr_crapemp%ROWTYPE;
  
    CURSOR cr_crapttl (pr_cdcooper IN crapemp.cdcooper%TYPE,
                       pr_nrdconta IN crapemp.cdempres%TYPE,
                       pr_idseqttl IN crapttl.idseqttl%TYPE) IS
      SELECT ttl.nrcpfemp
           , ttl.nmextemp
           , ttl.cdempres
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl;

    rw_crapttl cr_crapttl%ROWTYPE;
  
    -- Cursor sobre o cadastro de pessoa
    CURSOR cr_crapemp_cnpj (pr_cdcooper IN crapemp.cdcooper%TYPE,
                            pr_nrdocnpj IN crapemp.nrdocnpj%TYPE) IS
      SELECT emp.cdempres 
            ,emp.nmextemp
            ,emp.nrdocnpj  
            ,emp.nmresemp         
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.nrdocnpj = pr_nrdocnpj;
      
    rw_crapemp_cnpj cr_crapemp_cnpj%ROWTYPE;
    
    --Variaveis
    vr_nmpessoa tbcadast_pessoa.nmpessoa%TYPE;
    vr_idaltera PLS_INTEGER;
    
    -- Controle de erro
    vr_dscritic VARCHAR2(1000);
    vr_exc_saida     EXCEPTION;
    
  BEGIN
    -- Busca os dados da empresa
    OPEN cr_crapemp(pr_cdcooper
                   ,pr_cdempres);
      FETCH cr_crapemp 
        INTO rw_crapemp;
    CLOSE cr_crapemp;
    
    --Significa que é alguma empresa especial ou empresas diversas
    IF rw_crapemp.nrdocnpj = 0 THEN
      pr_nmpessot := '';
      pr_idaltera := 1; --Permite alterar
    
      IF nvl(pr_nrdocnpj,0) <> 0 THEN
        
        OPEN cr_crapemp_cnpj(pr_cdcooper
                            ,pr_nrdocnpj);
          FETCH cr_crapemp_cnpj
            INTO rw_crapemp_cnpj;
        CLOSE cr_crapemp_cnpj;
        
        IF rw_crapemp_cnpj.cdempres IS NOT NULL THEN
          pr_cdemprot := rw_crapemp_cnpj.cdempres;  
          pr_nmempout := rw_crapemp_cnpj.nmresemp;
          pr_nmpessot := rw_crapemp_cnpj.nmextemp;
          pr_nrcnpjot := rw_crapemp_cnpj.nrdocnpj; 
          pr_idaltera := 0;         
        ELSE
          --------
          -- Tenta localizar a pessoa no cadastro unificado
          --------
          
          CADA0008.pc_busca_nome_pessoa(pr_nrcpfcgc => pr_nrdocnpj,
                                        pr_nmpessoa => vr_nmpessoa,
                                        pr_idaltera => vr_idaltera,
                                        pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF; 

          pr_idaltera := vr_idaltera; 
          
          -- Ajuste para retornar o nome digitado em tela
          -- caso o cadastro permita alteracao (alt = 1)
          if pr_idaltera = 1 then
            pr_nmpessot := NVL(pr_nmpessoa,vr_nmpessoa);
          else
          pr_nmpessot := NVL(vr_nmpessoa,pr_nmpessoa);
          end if;
          
          pr_cdemprot := pr_cdempres;
          pr_nmempout := rw_crapemp.nmresemp;          
          pr_nrcnpjot := pr_nrdocnpj;

        END IF;        
      ELSE
        IF rw_crapemp.nmextemp LIKE '%APOSENTADO%' THEN
          pr_nmpessot := 'APOSENTADOS';
          pr_nrcnpjot := rw_crapemp.nrdocnpj;
          pr_cdemprot := pr_cdempres;
          pr_nmempout := rw_crapemp.nmresemp;
        ELSE
            OPEN cr_crapttl(pr_cdcooper, pr_nrdconta, pr_idseqttl);
              FETCH cr_crapttl 
                INTO rw_crapttl;
            CLOSE cr_crapttl;
                
            IF (nvl(rw_crapttl.nrcpfemp,0) <> 0
            OR TRIM(rw_crapttl.nmextemp) IS NOT NULL) AND nvl(pr_nrdocnpj,0) <> 0 THEN
              pr_nrcnpjot := rw_crapttl.nrcpfemp;
              pr_nmpessot := rw_crapttl.nmextemp;
              pr_cdemprot := pr_cdempres;
              pr_nmempout := rw_crapemp.nmresemp;
            ELSE
              pr_nrcnpjot := pr_nrdocnpj; 
              pr_nmpessot := pr_nmpessoa;
              pr_cdemprot := pr_cdempres;
              pr_nmempout := rw_crapemp.nmresemp;
            END IF;
          END IF;
      END IF;      
    ELSE
     
      -- Busca o nome da empresa
      CADA0008.pc_busca_nome_pessoa(pr_nrcpfcgc => rw_crapemp.nrdocnpj,
                                    pr_nmpessoa => vr_nmpessoa,
                                    pr_idaltera => vr_idaltera,
                                    pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF; 
       
      pr_idaltera := vr_idaltera;

      -- Ajuste para retornar o nome digitado em tela
      -- caso o cadastro permita alteracao (alt = 1)
      if pr_idaltera = 1 then
        pr_nmpessot := NVL(pr_nmpessoa,vr_nmpessoa);
      else
        pr_nmpessot := NVL(vr_nmpessoa,pr_nmpessoa);
      end if; 
        
      pr_nrcnpjot := rw_crapemp.nrdocnpj;
      pr_cdemprot := pr_cdempres;  
      pr_nmempout := rw_crapemp.nmresemp;
        
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception();
      pr_dscritic := 'Erro nao previsto CADA0008.PC_BUSCA_NOME_PESSOA: '||SQLERRM;
  END pc_busca_inf_emp;
  
  -- Rotina para buscar informacoes da empresa 
  PROCEDURE pc_busca_inf_emp_xml(pr_cdempres IN crapemp.cdempres%TYPE,
                                 pr_cdcooper IN crapcop.cdcooper%TYPE,
                                 pr_nrdconta IN crapass.nrdconta%TYPE,
                                 pr_idseqttl IN crapttl.idseqttl%TYPE,
                                 pr_nrdocnpj IN crapemp.nrdocnpj%TYPE,
                                 pr_nmpessoa IN tbcadast_pessoa.nmpessoa%TYPE,                             
                                 pr_xmllog   IN VARCHAR2,               --> XML com informações de LOG
                                 pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                 pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                 pr_retxml   IN OUT NOCOPY XMLType,     --> Arquivo de retorno do XML
                                 pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                 pr_des_erro OUT VARCHAR2) IS           --> Erros do processo

    /* ..........................................................................
    --
    --  Programa : pc_busca_inf_emp_xml
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Kelvin Ott
    --  Data     : Julho/2018.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para buscar informacoes da empresa 
    --
    --  Alteração : 20/09/2018 - Ajustes nas rotinas envolvidas na unificação cadastral e CRM para
    --                           corrigir antigos e evitar futuros problemas. (INC002926 - Kelvin)
    --
    --
    -- ..........................................................................*/
    
    --Variaveis
    vr_nmpessoa tbcadast_pessoa.nmpessoa%TYPE;
    vr_idaltera PLS_INTEGER;
    vr_nrcnpjot crapemp.nrdocnpj%TYPE;
    vr_cdemprot crapemp.cdempres%TYPE;
    vr_nmempout crapemp.nmresemp%TYPE;
    
    -- Controle de erro
    vr_dscritic VARCHAR2(1000);
    vr_exc_saida     EXCEPTION;
    
    --Variaveis de LOG
    vr_cdoperad      VARCHAR2(100);
    vr_cdcooper      NUMBER;
    vr_nmdatela      VARCHAR2(100);
    vr_nmeacao       VARCHAR2(100);
    vr_cdagenci      VARCHAR2(100);
    vr_nrdcaixa      VARCHAR2(100);
    vr_idorigem      VARCHAR2(100);

  BEGIN   
    -- Busca informacoes da empresa
    CADA0008.pc_busca_inf_emp(pr_cdcooper => pr_cdcooper,
                              pr_cdempres => pr_cdempres,
                              pr_nrdconta => pr_nrdconta,
                              pr_idseqttl => pr_idseqttl,
                              pr_nrdocnpj => pr_nrdocnpj,
                              pr_nmpessoa => pr_nmpessoa,
                              pr_nmpessot => vr_nmpessoa,
                              pr_nrcnpjot => vr_nrcnpjot,
                              pr_nmempout => vr_nmempout,
                              pr_idaltera => vr_idaltera,
                              pr_cdemprot => vr_cdemprot,
                              pr_dscritic => vr_dscritic);
                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;  

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
    -- Preenche os dados
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmpessoa', pr_tag_cont => vr_nmpessoa, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'idaltera', pr_tag_cont => vr_idaltera, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nrcnpjot', pr_tag_cont => vr_nrcnpjot, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cdemprot', pr_tag_cont => vr_cdemprot, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmempout', pr_tag_cont => vr_nmempout, pr_des_erro => vr_dscritic);
                                  
  EXCEPTION
    WHEN vr_exc_saida THEN
      CECRED.pc_internal_exception();
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      CECRED.pc_internal_exception();
      pr_dscritic := 'Erro nao previsto CADA0008.PC_BUSCA_INF_EMP_XML: '||SQLERRM;
  END pc_busca_inf_emp_xml;
  
  
  -- Rotina para realizar a chamada da CADA0012.pc_valida_acesso_operador                           
  PROCEDURE pc_valida_acesso_operador_web(pr_nrdconta IN NUMBER        --> Número da conta do Cooperado
                                         ,pr_xmllog   IN VARCHAR2      --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER  --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2     --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2     --> Nome do Campo
                                         ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* ..........................................................................
    --
    --  Programa : pc_valida_acesso_operador_web
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Renato Darosci
    --  Data     : Dezembro/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para realizar a chamada da CADA0012.pc_valida_acesso_operador via 
    --               mensageria, além de verificar os acessos aos botões de Desligamento e
    --               Saque Parcial da tela MATRIC.
    --
    --  Alteração : 13/02/2019 - Incluído cursor para verificar se realiza saque parcial e desligamento pelo Aimaro.
    --                           Retorno INSAQDES --> XML
    --
    -- ..........................................................................*/
    
    -- Cursor para verificar o controle de saque 
    CURSOR cr_ctrl_saque(pr_cdcooper  tbcotas_saque_controle.cdcooper%TYPE
                        ,pr_nrdconta  tbcotas_saque_controle.nrdconta%TYPE
                        ,pr_tpsaque   tbcotas_saque_controle.tpsaque%TYPE) IS
      SELECT 1  
        FROM tbcotas_saque_controle tb
       WHERE tb.cdcooper = pr_cdcooper
         AND tb.nrdconta = pr_nrdconta
         AND tb.tpsaque  = pr_tpsaque
         AND tb.dtefetivacao IS NULL; -- Processo de devolução ainda não efetivado
    
    -- Cursor para verificar se o operador realiza saques parciais e desligamento diretamente pelo Aimaro.
    CURSOR cr_insaqdes (pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT insaqdes, inutlcrm
      FROM crapope
      WHERE cdcooper = pr_cdcooper
      AND   cdoperad = pr_cdoperad;
      
    
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis
    vr_dstoken  VARCHAR2(1000);
    vr_string   VARCHAR2(1000);
    vr_dstexto  VARCHAR2(1000);
    vr_indsaque NUMBER; 
    vr_inutlcrm NUMBER;    
    vr_insaqdes NUMBER; --Indicador de saque parcial e desligamento (0-NAO, 1-SIM)
    vr_dsxmlret CLOB;
        
    -- Tratamento de erros  																			
		vr_exc_erro EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);
																			
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

    -- Se retornou algum erro
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;          
    
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  				
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml(pr_xml            => vr_dsxmlret,
                            pr_texto_completo => vr_dstexto,
                            pr_texto_novo     => '<root>');
    
    -- Verificar se o operador possui acesso ao sistema
    CADA0012.pc_valida_acesso_operador(pr_cdcooper => vr_cdcooper
                                      ,pr_cdoperad => vr_cdoperad
                                      ,pr_cdagenci => vr_cdagenci
                                      ,pr_fltoken => 'N'
                                      ,pr_dstoken  => vr_dstoken
                                      ,pr_dscritic => vr_dscritic);
                                        
    -- Se retornou algum erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Indica Operador sem acesso
      vr_string := '<flgacesso>N</flgacesso>';                   
    ELSE
      -- Indica Operador com acesso
      vr_string := '<flgacesso>S</flgacesso>';
    END IF;                   
      
    
    -- Verificar se o botão Desligar será exibido
    OPEN  cr_ctrl_saque(vr_cdcooper
                       ,pr_nrdconta
                       ,2); -- DESLIGAMENTO
    FETCH cr_ctrl_saque INTO vr_indsaque;
      
    -- Verifica se retornou registro
    IF cr_ctrl_saque%FOUND THEN
      vr_string := vr_string||'<flgdemiss>S</flgdemiss>';
    ELSE
      vr_string := vr_string||'<flgdemiss>N</flgdemiss>';
    END IF;
      
    CLOSE cr_ctrl_saque;
      
    -- Verificar se o botão Saque Parcial será exibido
    OPEN  cr_ctrl_saque(vr_cdcooper
                       ,pr_nrdconta
                       ,1); -- SAQUE PARCIAL
    FETCH cr_ctrl_saque INTO vr_indsaque;
      
    -- Verifica se retornou registro
    IF cr_ctrl_saque%FOUND THEN
      vr_string := vr_string||'<flgsaqprc>S</flgsaqprc>';
    ELSE
      vr_string := vr_string||'<flgsaqprc>N</flgsaqprc>';
    END IF;
      
    CLOSE cr_ctrl_saque;
    
    -- Verifica se o operador realiza saques parciais e desligamento pelo Aimaro
    OPEN  cr_insaqdes(vr_cdcooper
                     ,vr_cdoperad);
    FETCH cr_insaqdes INTO vr_insaqdes, vr_inutlcrm;
      
    -- Só deve considerar o valor do indicador de saque/desligamento se for opção de acesso for 2 (CRM + AIMARO)
    -- Seguindo a mesma regra da tela OPERAD
    IF (vr_insaqdes=1) and (vr_inutlcrm=2) THEN
      vr_string := vr_string||'<insaqdes>1</insaqdes>';
    ELSE
      vr_string := vr_string||'<insaqdes>0</insaqdes>';
    END IF;  
    
    CLOSE cr_insaqdes;      
      
    
    -- Escrever no XML
    gene0002.pc_escreve_xml(pr_xml            => vr_dsxmlret,
                            pr_texto_completo => vr_dstexto,
                            pr_texto_novo     => vr_string,
                            pr_fecha_xml      => FALSE);
  				
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => vr_dsxmlret,
                            pr_texto_completo => vr_dstexto,
                            pr_texto_novo     => '</root>',
                            pr_fecha_xml      => TRUE);
    
    -- Cria o XML a ser retornado
    pr_retxml := xmltype.createXML(xmlData => vr_dsxmlret);
    
  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possui código da crítica
			IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar descrição da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			-- Retornar crítica parametrizada
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_valida_acesso_operador_web: ' ||
                     SQLERRM;
  END pc_valida_acesso_operador_web;
  
  -- Rotina para buscar os dados para saque de cotas da tabela TBCOTAS_SAQUE_CONTROLE
  PROCEDURE pc_busca_saque_controle_web(pr_nrdconta IN NUMBER        --> Número da conta do Cooperado
                                       ,pr_tpdsaque IN NUMBER        --> Tipo de saque (1-Saque Parcial/2-Desligamento)
                                       ,pr_xmllog   IN VARCHAR2      --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER  --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2     --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2     --> Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* ..........................................................................
    --
    --  Programa : pc_busca_saque_controle_web
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Renato Darosci
    --  Data     : Dezembro/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para buscar os dados para saque de cotas da 
    --               tabela TBCOTAS_SAQUE_CONTROLE
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    -- Cursor para verificar o controle de saque 
    CURSOR cr_ctrl_saque(pr_cdcooper  tbcotas_saque_controle.cdcooper%TYPE
                        ,pr_nrdconta  tbcotas_saque_controle.nrdconta%TYPE
                        ,pr_tpsaque   tbcotas_saque_controle.tpsaque%TYPE) IS
      SELECT tb.nrdconta
           , tb.vlsaque
           , tb.cdmotivo
           , tb.rowid  dsdrowid
        FROM tbcotas_saque_controle tb
       WHERE tb.cdcooper = pr_cdcooper
         AND tb.nrdconta = pr_nrdconta
         AND tb.tpsaque  = pr_tpsaque
         AND tb.dtefetivacao IS NULL; -- Processo de devolução ainda não efetivado
    rw_ctrl_saque   cr_ctrl_saque%ROWTYPE;
    
    -- Cursor para buscar o motivo do saque para Saque Parcial
    CURSOR cr_motivo_saque(pr_cdmotivo tbcotas_motivo_saqueparcial.cdmotivo%TYPE) IS
      SELECT tb.dsmotivo
        FROM tbcotas_motivo_saqueparcial tb
       WHERE tb.cdmotivo = pr_cdmotivo;
    
    -- Cursor para buscar o motivo do saque para Desligamento
    CURSOR cr_motivo_desligamento(pr_cdmotivo tbcotas_motivo_desligamento.cdmotivo%TYPE) IS
      SELECT tb.dsmotivo
        FROM tbcotas_motivo_desligamento tb
       WHERE tb.cdmotivo = pr_cdmotivo;
       
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis
    vr_string   VARCHAR2(1000);
    vr_dstexto  VARCHAR2(1000);
    vr_dsxmlret CLOB;
    vr_dsmotivo VARCHAR2(200);
        
    -- Tratamento de erros  																			
		vr_exc_erro EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);
																			
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

    -- Se retornou algum erro
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;          
    
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  				
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml(pr_xml            => vr_dsxmlret,
                            pr_texto_completo => vr_dstexto,
                            pr_texto_novo     => '<root>');
    
    -- Busca os dados relacionados ao saque das cotas
    OPEN  cr_ctrl_saque(vr_cdcooper
                       ,pr_nrdconta
                       ,pr_tpdsaque);
    FETCH cr_ctrl_saque INTO rw_ctrl_saque;
    -- Fechar o cursor
    CLOSE cr_ctrl_saque;
      
    -- Montar o XML de retorno com os dados
    vr_string := '<vldsaque>'||to_char(rw_ctrl_saque.vlsaque,'FM999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') ||'</vldsaque>'||
                 '<nrdconta>'||rw_ctrl_saque.nrdconta||'</nrdconta>'||
                 '<cdmotivo>'||rw_ctrl_saque.cdmotivo||'</cdmotivo>';
    
    -- Se o tipo do saque for Saque Parcial
    IF pr_tpdsaque = 1 THEN
      -- Buscar o motivo do saque como Saque Parcial
      OPEN  cr_motivo_saque(rw_ctrl_saque.cdmotivo);
      FETCH cr_motivo_saque INTO vr_dsmotivo;
      CLOSE cr_motivo_saque;
    
    ELSIF pr_tpdsaque = 2 THEN
      -- Buscar o motivo do saque como Desligamento
      OPEN  cr_motivo_desligamento(rw_ctrl_saque.cdmotivo);
      FETCH cr_motivo_desligamento INTO vr_dsmotivo;
      CLOSE cr_motivo_desligamento;
    
    END IF;

    -- Inclui a descrição do motivo no xml de retorno
    vr_string := vr_string||'<dsmotivo>'||vr_dsmotivo||'</dsmotivo>'||
                            '<dsdrowid>'||rw_ctrl_saque.dsdrowid||'</dsdrowid>';  
     
    
    -- Escrever no XML
    gene0002.pc_escreve_xml(pr_xml            => vr_dsxmlret,
                            pr_texto_completo => vr_dstexto,
                            pr_texto_novo     => vr_string,
                            pr_fecha_xml      => FALSE);
  				
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => vr_dsxmlret,
                            pr_texto_completo => vr_dstexto,
                            pr_texto_novo     => '</root>',
                            pr_fecha_xml      => TRUE);
    
    -- Cria o XML a ser retornado
    pr_retxml := xmltype.createXML(xmlData => vr_dsxmlret);
    
  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possui código da crítica
			IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar descrição da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			-- Retornar crítica parametrizada
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_busca_saque_controle_web: ' ||
                     SQLERRM;
  END pc_busca_saque_controle_web;
  
  -- Rotina para validar os dados de cotas e chamar a rotina de devolução
  PROCEDURE pc_devolucao_desligamento(pr_nrdconta  IN crapass.nrdconta%TYPE    --> Número da conta
                                     ,pr_vldcotas  IN crapcot.vldcotas%TYPE   --> Valor de cotas                                        
                                     ,pr_formadev  IN INTEGER                 --> Forma de devolução 1 = total / 2 = parcelado 
                                     ,pr_qtdparce  IN INTEGER                 --> Quantidade de parcelas 
                                     ,pr_datadevo  IN VARCHAR2                --> Valor de cotas                                          
                                     ,pr_mtdemiss  IN INTEGER                 --> Motivo informado pelo operador na tela matric
                                     ,pr_dtdemiss  IN VARCHAR2                --> Data informada pelo operador na tela matric
                                     ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                     ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2) IS           --> Descrição do erro
    /* ..........................................................................
    --
    --  Programa : pc_devolucao_desligamento
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Renato Darosci
    --  Data     : Dezembro/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para validar os dados de cotas e chamar a rotina 
    --               de devolução
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
       
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis
    vr_vlcotlib NUMBER;
        
    -- Tratamento de erros  																			
		vr_exc_erro EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);
																			
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

    -- Se retornou algum erro
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;          
    
    -- Chamar a rotina para buscar as cotas liberadas
    CADA0012.pc_retorna_cotas_liberada(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_vldcotas => vr_vlcotlib
                                      ,pr_dscritic => vr_dscritic);
    
    -- Se retornou algum erro
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF; 
    
    -- Verifica se o valor das cotas cotas liberadas é menor que o valor de saque
    IF vr_vlcotlib < pr_vldcotas THEN
      -- Crítica
      vr_dscritic := 'Valor de cotas liberadas para saque é menor que o valor para devolução.';
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF; 
    
    -- Se não apresentou crítica até este ponto, chama a rotina de devolução
    CADA0003.pc_devol_cotas_desligamentos(pr_nrdconta => pr_nrdconta
                                         ,pr_vldcotas => pr_vldcotas
                                         ,pr_formadev => pr_formadev
                                         ,pr_qtdparce => pr_qtdparce
                                         ,pr_datadevo => pr_datadevo
                                         ,pr_mtdemiss => pr_mtdemiss
                                         ,pr_dtdemiss => pr_dtdemiss
                                         ,pr_xmllog   => pr_xmllog  
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_retxml   => pr_retxml  
                                         ,pr_nmdcampo => pr_nmdcampo
                                         ,pr_des_erro => pr_des_erro);
    
    -- Se retornou algum erro
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF; 
    
  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possui código da crítica
			IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar descrição da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			-- Retornar crítica parametrizada
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_devolucao_desligamento: ' ||
                     SQLERRM;
  END pc_devolucao_desligamento;
  
  -- Rotina para validar os dados de cotas e chamar a rotina de saque parcial
  PROCEDURE pc_efetuar_saque_parcial(pr_nrctaori  IN crapass.nrdconta%TYPE --> Número da conta origem
                                    ,pr_nrctadst  IN crapass.nrdconta%TYPE --> Número da conta destino
                                    ,pr_vldsaque  IN crapcot.vldcotas%TYPE --> Valor do saque
                                    ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo
    /* ..........................................................................
    --
    --  Programa : pc_efetuar_saque_parcial
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Renato Darosci
    --  Data     : Dezembro/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para validar os dados de cotas e chamar a rotina 
    --               de saque parcial
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
       
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis
    vr_vlcotlib NUMBER;
        
    -- Tratamento de erros  																			
		vr_exc_erro EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);
																			
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

    -- Se retornou algum erro
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;          
    
    -- Chamar a rotina para buscar as cotas liberadas
    CADA0012.pc_retorna_cotas_liberada(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrctaori
                                      ,pr_vldcotas => vr_vlcotlib
                                      ,pr_dscritic => vr_dscritic);
    
    -- Se retornou algum erro
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF; 
    
    -- Verifica se o valor das cotas cotas liberadas é menor que o valor de saque
    IF vr_vlcotlib < pr_vldsaque THEN
      -- Crítica
      vr_dscritic := 'Valor de cotas liberadas para saque é menor que o valor do saque.';
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF; 
    
    -- Se não apresentou crítica até este ponto, chama a rotina de devolução
    CADA0003.pc_efetuar_saque_parcial_cotas(pr_nrctaori => pr_nrctaori
                                           ,pr_nrctadst => pr_nrctadst
                                           ,pr_vldsaque => pr_vldsaque
                                           ,pr_xmllog   => pr_xmllog  
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           ,pr_retxml   => pr_retxml  
                                           ,pr_nmdcampo => pr_nmdcampo
                                           ,pr_des_erro => pr_des_erro);
    
    
    -- Se retornou algum erro
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF; 
    
  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possui código da crítica
			IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar descrição da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			-- Retornar crítica parametrizada
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_efetuar_saque_parcial: ' ||
                     SQLERRM;
  END pc_efetuar_saque_parcial;
  
END;
/
