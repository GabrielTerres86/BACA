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
  --  Alteracoes:
  --
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Variaveis Globais
  vr_xml xmltype; -- XML qye sera enviado


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
	PROCEDURE pc_busca_crapttl_compl( pr_nrcpfcgc     IN crapttl.nrcpfcgc%TYPE,
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
                                   FROM TBCADAST_DOMINIO_CAMPO
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
	PROCEDURE pc_busca_crapttl_compl( pr_nrcpfcgc     IN crapttl.nrcpfcgc%TYPE,
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
    --  Alteração :
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
    
	BEGIN
  
    --> retonar dados da pessoa fisica
    OPEN cr_pessoa_fisica;
    FETCH cr_pessoa_fisica INTO rw_pessoa_fisica;
    CLOSE cr_pessoa_fisica;
    
    --> buscar dados da renda
    OPEN cr_pessoa_renda (pr_idpessoa => rw_pessoa_fisica.idpessoa);
    FETCH cr_pessoa_renda INTO rw_pessoa_renda;
    CLOSE cr_pessoa_renda;		
    
    pr_cdnatopc := rw_pessoa_fisica.cdnatureza_ocupacao;
    pr_cdocpttl := rw_pessoa_renda.cdocupacao;
    pr_tpcttrab := rw_pessoa_renda.tpcontrato_trabalho;
    pr_nmextemp := substr(rw_pessoa_renda.nmpessoa,1,40);
    pr_nrcpfemp := rw_pessoa_renda.nrcpfcgc;
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
                                   'Entrou');

      
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
    
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_marca_replica_ayllos-'||w_nmtabela||': ' ||
                     SQLERRM;
                     
     btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'CRM' 
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         pr_dscritic);                     
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
        pr_idaltera := 1; -- Permite alterar
      END IF;
    END IF;
    CLOSE cr_pessoa;
  EXCEPTION
    WHEN OTHERS THEN
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
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao previsto CADA0008.PC_BUSCA_NOME_PESSOA_XML: '||SQLERRM;
  END pc_busca_nome_pessoa_xml;
  
END;
/
