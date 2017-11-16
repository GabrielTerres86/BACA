CREATE OR REPLACE PACKAGE CECRED.TELA_CADMAT AS

  PROCEDURE pc_busca_dados_conta(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta
		                            ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_consulta_pre_inclusao(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> Numero do CPF / CGC do cooperado
																		,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																		,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																		,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																		,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																		,pr_des_erro OUT VARCHAR2);            --> Erros do processo

END TELA_CADMAT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADMAT AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_CADMAT
  --    Autor   : Lucas Reinert
  --    Data    : Setembro/2017                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package para agrupar rotinas da tela CADMAT
  --
  --    Alteracoes: 
  --    
  ---------------------------------------------------------------------------------------------------------------
  
  PROCEDURE pc_busca_dados_conta(pr_nrdconta IN crapass.nrdconta%TYPE --> NR. da conta
		                            ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_dados_conta
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : Setembro/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar os dados da conta do cooperado
    
    Alteracoes: 
    ............................................................................. */
  
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

	
    --Cursor para buscar dados da conta do cooperado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
		                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.cdagenci
						,to_char(ass.dtadmiss, 'DD/MM/RRRR') dtadmiss
						,ass.nrmatric
						,ass.nrdconta
						,ass.inpessoa
						,to_char(ass.dtdemiss, 'DD/MM/RRRR') dtdemiss
						,(SELECT dom.dscodigo
						    FROM tbcadast_dominio_campo dom 
							 WHERE dom.nmdominio = 'CRAPASS.INTIPSAI'
							   AND dom.cddominio = ass.intipsai) dstipsai
						,(SELECT dom.dscodigo
						    FROM tbcadast_dominio_campo dom 
							 WHERE dom.nmdominio = 'CRAPASS.ININCTVA'
							   AND dom.cddominio = ass.ininctva) dsinctva
            ,ass.cdmotdem
						,tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
						                           ,pr_nmsistem => 'CRED'
																			 ,pr_tptabela => 'GENERI'
																			 ,pr_cdempres => 0
																			 ,pr_cdacesso => 'MOTIVODEMI'
																			 ,pr_tpregist => ass.cdmotdem) dsmotdem
		        ,age.nmresage
						,ass.nrcpfcgc	
						,ass.nmprimtl
						,emp.cdempres
						,emp.nmresemp
        FROM crapass ass
				    ,crapage age
						,crapttl ttl
						,crapemp emp
			 WHERE ass.cdcooper = pr_cdcooper
			   AND ass.nrdconta = pr_nrdconta
				 AND age.cdcooper = ass.cdcooper
				 AND age.cdagenci = ass.cdagenci
				 AND ttl.cdcooper (+) = ass.cdcooper
				 AND ttl.nrdconta (+) = ass.nrdconta
				 AND emp.cdcooper (+) = ttl.cdcooper
				 AND emp.cdempres (+) = ttl.cdempres;
    rw_crapass cr_crapass%ROWTYPE;
		
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis locais
    vr_contador INTEGER := 0;
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
		
		-- Incluir nome do módulo logado
		GENE0001.pc_informa_acesso(pr_module => 'TELA_CADMAT'
															,pr_action => null); 
			
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

    -- Buscar dados do cooperado
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
		
		-- Se não encontrou cooperado
		IF cr_crapass%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapass;
			-- Gerar crítica
			vr_cdcritic := 9;  --> Associado não encontrado
			vr_dscritic := '';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_crapass;
		
		-- Iniciar o XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');  
		
		--Escrever no XML
		-- Conta
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
													 pr_tag_pai  => 'Dados',
													 pr_posicao  => vr_contador,
													 pr_tag_nova => 'nrdconta',
													 pr_tag_cont => rw_crapass.nrdconta,
													 pr_des_erro => vr_dscritic);
	  -- Natureza
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
													 pr_tag_pai  => 'Dados',
													 pr_posicao  => vr_contador,
													 pr_tag_nova => 'inpessoa',
													 pr_tag_cont => rw_crapass.inpessoa,
													 pr_des_erro => vr_dscritic);
    -- CPF/CNPJ
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
													 pr_tag_pai  => 'Dados',
													 pr_posicao  => vr_contador,
													 pr_tag_nova => 'nrcpfcgc',
													 pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa),
													 pr_des_erro => vr_dscritic);
    -- Nome tit.
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'nmpessoa',
											 pr_tag_cont => rw_crapass.nmprimtl,
											 pr_des_erro => vr_dscritic);
    -- Cód. PA
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'cdagenci',
											 pr_tag_cont => rw_crapass.cdagenci,
											 pr_des_erro => vr_dscritic);
    -- Nome PA
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'nmresage',
											 pr_tag_cont => rw_crapass.nmresage,
											 pr_des_erro => vr_dscritic);											 
											 
    -- Cód. Empresa
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'cdempres',
											 pr_tag_cont => rw_crapass.cdempres,
											 pr_des_erro => vr_dscritic);
    -- Nome Empresa
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'nmresemp',
											 pr_tag_cont => rw_crapass.nmresemp,
											 pr_des_erro => vr_dscritic);											 
    -- Admissão
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'dtadmiss',
											 pr_tag_cont => rw_crapass.dtadmiss,
											 pr_des_erro => vr_dscritic);
    -- Nr. Matrícula
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'nrmatric',
											 pr_tag_cont => rw_crapass.nrmatric,
											 pr_des_erro => vr_dscritic);
    -- Data Demissão
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'dtdemiss',
											 pr_tag_cont => rw_crapass.dtdemiss,
											 pr_des_erro => vr_dscritic);
    -- Tipo saída
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'dstipsai',
											 pr_tag_cont => rw_crapass.dstipsai,
											 pr_des_erro => vr_dscritic);											 											 
    -- Iniciativa
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'dsinctva',
											 pr_tag_cont => rw_crapass.dsinctva,
											 pr_des_erro => vr_dscritic);											 											 
    -- Cód motivo
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'cdmotdem',
											 pr_tag_cont => rw_crapass.cdmotdem,
											 pr_des_erro => vr_dscritic);											 											 
    -- Desc. motivo
		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
											 pr_tag_pai  => 'Dados',
											 pr_posicao  => vr_contador,
											 pr_tag_nova => 'dsmotdem',
											 pr_tag_cont => rw_crapass.dsmotdem,
											 pr_des_erro => vr_dscritic);											 											 
											 											 
    pr_des_erro := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADMAT.pc_busca_dados_conta --> ' ||
                     SQLERRM;
                                  
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
  END pc_busca_dados_conta;

  PROCEDURE pc_consulta_pre_inclusao(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> Numero do CPF / CGC do cooperado
																		,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																		,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																		,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																		,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																		,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
    /* .............................................................................
    Programa: pc_consulta_pre_inclusao
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : Outubro/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar os dados do cooperado no CRM
    
    Alteracoes: 
    ............................................................................. */

		-- Variável de críticas
		vr_cdcritic      crapcri.cdcritic%TYPE;
		vr_dscritic      VARCHAR2(10000);

		-- Variaveis de log
		vr_cdoperad      VARCHAR2(100);
		vr_cdcooper      NUMBER;
		vr_nmdatela      VARCHAR2(100);
		vr_nmeacao       VARCHAR2(100);
		vr_cdagenci      VARCHAR2(100);
		vr_nrdcaixa      VARCHAR2(100);
		vr_idorigem      VARCHAR2(100);

		-- Tratamento de erros
		vr_exc_erro      EXCEPTION;
		
		-- Variáveis auxiliares
		vr_contador      NUMBER := 0;
    vr_flgdpcnt      NUMBER := 0;

    -- Buscar os dados de cadastro
    CURSOR cr_tbcadast_pessoa(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
      SELECT pss.dtconsulta_rfb dtconsultaRfb      
            ,pss.nrcpfcgc 
            ,pss.cdsituacao_rfb cdsituacaoRfb
            ,pss.nmpessoa
            ,pss.nmpessoa_receita nmpessoaReceita
						,pss.tppessoa
            ,psf.tpsexo
            ,psf.dtnascimento
            ,psf.tpdocumento
            ,psf.nrdocumento
            ,psf.idorgao_expedidor idorgaoExpedidor
            ,psf.cduf_orgao_expedidor cdufOrgaoExpedidor
            ,psf.dtemissao_documento dtemissaoDocumento
						,psf.cdnacionalidade
            ,psf.tpnacionalidade
            ,psf.inhabilitacao_menor inhabilitacaoMenor
            ,psf.dthabilitacao_menor dthabilitacaoMenor
            ,psf.cdestado_civil cdestadoCivil 
            ,pre.cdocupacao cdNaturezaOcupacao 
            ,pre.nrcadastro cdCadastroEmpresa 
            ,pssMae.Nmpessoa nmmae
            ,pssConjugue.Nmpessoa nmconjugue
            ,pssPai.Nmpessoa nmpai
            ,munNaturalidade.dscidade naturalidadeDsCidade
            ,munNaturalidade.cdestado naturalidadeCdEstado
            ,(SELECT nrddd
                FROM (SELECT ptlComercialDdd.nrddd 
                            ,ptlComercialDdd.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlComercialDdd
                       WHERE ptlComercialDdd.tptelefone = 3
                       ORDER BY ptlComercialDdd.Idpessoa, ptlComercialDdd.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) comercialNrddd 
            ,(SELECT Nrtelefone
                FROM (SELECT ptlComercialTelefone.Nrtelefone 
                            ,ptlComercialTelefone.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlComercialTelefone
                       WHERE ptlComercialTelefone.tptelefone = 3
                       ORDER BY ptlComercialTelefone.Idpessoa, ptlComercialTelefone.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) comercialNrTelefone  
            ,(SELECT nrddd
                FROM (SELECT ptlResidencialDdd.nrddd 
                            ,ptlResidencialDdd.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlResidencialDdd
                       WHERE ptlResidencialDdd.tptelefone = 1
                       ORDER BY ptlResidencialDdd.Idpessoa, ptlResidencialDdd.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) residencialNrddd                   
            
            ,(SELECT Nrtelefone
                FROM (SELECT ptlResidencialTelefone.Nrtelefone 
                            ,ptlResidencialTelefone.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlResidencialTelefone
                       WHERE ptlResidencialTelefone.tptelefone = 1
                       ORDER BY ptlResidencialTelefone.Idpessoa, ptlResidencialTelefone.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) residencialNrTelefone                 
            ,(SELECT cdoperadora
                FROM (SELECT ptlCelularOperadora.cdoperadora 
                            ,ptlCelularOperadora.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlCelularOperadora
                       WHERE ptlCelularOperadora.tptelefone = 2
                       ORDER BY ptlCelularOperadora.Idpessoa, ptlCelularOperadora.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) celularCdOperadora                                            
            ,(SELECT nrddd
                FROM (SELECT ptlCelularDdd.nrddd 
                            ,ptlCelularDdd.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlCelularDdd
                       WHERE ptlCelularDdd.tptelefone = 2
                       ORDER BY ptlCelularDdd.Idpessoa, ptlCelularDdd.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) celularNrDdd            
            ,(SELECT Nrtelefone
                FROM (SELECT ptlCelularTelefone.Nrtelefone 
                            ,ptlCelularTelefone.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlCelularTelefone
                       WHERE ptlCelularTelefone.tptelefone = 2
                       ORDER BY ptlCelularTelefone.Idpessoa, ptlCelularTelefone.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) celularNrTelefone
            ,(SELECT Dsemail
                FROM (SELECT pemEmail.Dsemail 
                            ,pemEmail.Idpessoa 
                        FROM tbcadast_pessoa_email pemEmail
                       ORDER BY pemEmail.Idpessoa, pemEmail.Nrseq_Email)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) dsdemail     
            ,penResidencial.nrcep residencialNrCep             
            ,penResidencial.nmlogradouro residencialNmLogradouro   
            ,penResidencial.nrlogradouro residencialNrLogradouro  
            ,penResidencial.dscomplemento residencialDsComplemento   
            ,penResidencial.nmbairro residencialNmBairro    
            ,munResidencial.Cdestado residencialCdEstado
            ,munResidencial.Dscidade residencialDsCidade    
            ,penResidencial.tporigem_cadastro residencialTporigem
            ,penCorrespondencia.nrcep correspondenciaNrCep             
            ,penCorrespondencia.nmlogradouro correspondenciaNmLogradouro   
            ,penCorrespondencia.nrlogradouro correspondenciaNrLogradouro  
            ,penCorrespondencia.dscomplemento correspondenciaDsComplemento   
            ,penCorrespondencia.nmbairro correspondenciaNmBairro    
            ,munCorrespondencia.Cdestado correspondenciaCdEstado
            ,munCorrespondencia.Dscidade correspondenciaDsCidade
            ,penCorrespondencia.tporigem_cadastro correspondenciaTporigem 
            ,penComercial.nrcep comercialNrCep             
            ,penComercial.nmlogradouro comercialNmLogradouro   
            ,penComercial.nrlogradouro comercialNrLogradouro  
            ,penComercial.dscomplemento comercialDsComplemento   
            ,penComercial.nmbairro comercialNmBairro    
            ,munComercial.Cdestado comercialCdEstado
            ,munComercial.Dscidade comercialDsCidade    
            ,penComercial.tporigem_cadastro comercialTporigem
            ,nac.dsnacion
            ,oxp.cdorgao_expedidor cdExpedidor
            ,pju.nmfantasia
            ,pju.nrinscricao_estadual nrInscricao
            ,pju.nrlicenca_ambiental nrLicenca
            ,pju.cdnatureza_juridica cdNatureza
            ,pju.cdsetor_economico cdSetor
            ,pju.cdramo_atividade cdRamo
            ,pju.Cdcnae
            ,pju.dtinicio_atividade dtInicioAtividade
        FROM tbcadast_pessoa pss
            ,tbcadast_pessoa_fisica psf
            ,tbcadast_pessoa_relacao prlConjugue
            ,tbcadast_pessoa pssConjugue
            ,tbcadast_pessoa_relacao prlPai
            ,tbcadast_pessoa pssPai
            ,tbcadast_pessoa_relacao prlMae
            ,tbcadast_pessoa pssMae
            ,crapmun munNaturalidade
            ,tbcadast_pessoa_endereco penResidencial
            ,crapmun munResidencial
            ,tbcadast_pessoa_endereco penCorrespondencia
            ,crapmun munCorrespondencia
            ,tbcadast_pessoa_endereco penComercial
            ,crapmun munComercial
            ,crapnac nac
            ,tbgen_orgao_expedidor oxp 
            ,tbcadast_pessoa_juridica pju            
            ,tbcadast_pessoa_renda pre
       WHERE psf.idpessoa(+)                  = pss.idpessoa
         AND prlConjugue.Idpessoa(+)          = pss.idpessoa
         AND prlConjugue.tprelacao(+)         = 1
         AND pssConjugue.Idpessoa(+)          = prlConjugue.Idpessoa_Relacao   
         AND prlPai.Idpessoa(+)               = pss.idpessoa
         AND prlPai.tprelacao(+)              = 3
         AND pssPai.Idpessoa(+)               = prlPai.Idpessoa_Relacao   
         AND prlMae.Idpessoa(+)               = pss.idpessoa
         AND prlMae.tprelacao(+)              = 4
         AND pssMae.Idpessoa(+)               = prlMae.Idpessoa_Relacao   
         AND munNaturalidade.idcidade(+)      = psf.cdnaturalidade  
         AND penResidencial.idpessoa(+)       = pss.idpessoa
         AND penResidencial.tpendereco(+)     = 10   
         AND munResidencial.Idcidade(+)       = penResidencial.Idcidade     
         AND penCorrespondencia.idpessoa(+)   = pss.idpessoa
         AND penCorrespondencia.tpendereco(+) = 13     
         AND munCorrespondencia.Idcidade(+)   = penCorrespondencia.Idcidade
         AND penComercial.idpessoa(+)         = pss.idpessoa
         AND penComercial.tpendereco(+)       = 9   
         AND munComercial.Idcidade(+)         = penComercial.Idcidade   
         AND nac.cdnacion(+)  = psf.cdnacionalidade
         AND oxp.idorgao_expedidor(+) = psf.idorgao_expedidor
         AND pju.idpessoa(+) = pss.idpessoa
         AND pre.idpessoa(+)           = pss.idpessoa 
         AND pre.nrseq_renda(+)        = 1            
         AND pss.nrcpfcgc = pr_nrcpfcgc;
      rw_tbcadast_pessoa cr_tbcadast_pessoa%ROWTYPE;
			
    -- Cursor sobre a tabela de associados que podem possuir contas duplicadas
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
		                 ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
      SELECT nrdconta,
             dtadmiss
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrcpfcgc = pr_nrcpfcgc
         AND dtdemiss IS NULL -- Nao exibir demitidos
         AND dtelimin IS NULL -- Nao exibir contas que possuam valores eliminados
         AND cdsitdtl NOT IN (5,6,7,8) -- Nao exibir contas com prejuizo
         AND cdsitdtl NOT IN (2,4,6,8) -- Titular da conta bloqueado
       ORDER BY dtadmiss DESC;

		-- Buscar PA do operador
		CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
		                 ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
		  SELECT age.cdagenci
			      ,age.nmresage
			  FROM crapage age
			 WHERE age.cdcooper = pr_cdcooper
			   AND age.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;
  BEGIN
		
		-- Incluir nome do módulo logado
		GENE0001.pc_informa_acesso(pr_module => 'TELA_CADMAT'
															,pr_action => null); 
			
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

    -- Buscar informações de cadastro
		OPEN cr_tbcadast_pessoa(pr_nrcpfcgc);
		FETCH cr_tbcadast_pessoa INTO rw_tbcadast_pessoa;
		
		-- Se não encontrou registro
		IF cr_tbcadast_pessoa%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_tbcadast_pessoa;
      -- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Informações cadastrais não encontradas.';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		
		-- Buscar PA do operador
		OPEN cr_crapage(pr_cdcooper => vr_cdcooper
		               ,pr_cdagenci => vr_cdagenci);
		FETCH cr_crapage INTO rw_crapage;

    -- Cria XML		
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
		
		-- Loop sob as possíveis contas a serem duplicadas
		FOR rw_crapass IN cr_crapass (pr_cdcooper => vr_cdcooper
		                             ,pr_nrcpfcgc => pr_nrcpfcgc)LOOP
            
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => gene0002.fn_mask_conta(rw_crapass.nrdconta), pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtadmiss', pr_tag_cont => to_char(rw_crapass.dtadmiss,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);

			vr_contador := vr_contador + 1;
            
		END LOOP; 

    -- Se contador for maior que zero, encontrou pelo menos uma conta para duplicar
		IF vr_contador > 0 THEN
			vr_flgdpcnt := 1;
		END IF;
		
		-- Gravar os dados consultados no XML
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'      , pr_posicao => 0, pr_tag_nova => 'infcadastro', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_tbcadast_pessoa.nrcpfcgc,rw_tbcadast_pessoa.tppessoa),  pr_des_erro => vr_dscritic);
	  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'tpdocptl', pr_tag_cont => rw_tbcadast_pessoa.tpdocumento, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrdocptl', pr_tag_cont => rw_tbcadast_pessoa.nrdocumento, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmttlrfb', pr_tag_cont => rw_tbcadast_pessoa.nmpessoaReceita,  pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdsitcpf', pr_tag_cont => rw_tbcadast_pessoa.cdsituacaoRfb, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmprimtl', pr_tag_cont => rw_tbcadast_pessoa.nmpessoa, pr_des_erro => vr_dscritic);		
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dtcnscpf', pr_tag_cont => to_char(rw_tbcadast_pessoa.dtconsultaRfb,'DD/MM/RRRR'),  pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dsdemail', pr_tag_cont => rw_tbcadast_pessoa.dsdemail, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrcepcor', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaNrCep, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dsendcor', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaNmLogradouro, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrendcor', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaNrLogradouro, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'complcor', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaDsComplemento, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmbaicor', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaNmBairro, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdufcorr', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaCdEstado, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmcidcor', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaDsCidade, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'idoricor', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaTporigem, pr_des_erro => vr_dscritic);
	  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'inpessoa', pr_tag_cont => rw_tbcadast_pessoa.tppessoa, pr_des_erro => vr_dscritic);
	  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_crapage.cdagenci, pr_des_erro => vr_dscritic);
	  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmresage', pr_tag_cont => rw_crapage.nmresage, pr_des_erro => vr_dscritic);
				
		IF rw_tbcadast_pessoa.tppessoa = 1 THEN
    -- PF		
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dsnacion', pr_tag_cont => rw_tbcadast_pessoa.dsnacion, pr_des_erro => vr_dscritic);
	 	   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'inhabmen', pr_tag_cont => rw_tbcadast_pessoa.inhabilitacaoMenor, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dthabmen', pr_tag_cont => to_char(rw_tbcadast_pessoa.dthabilitacaoMenor,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdestcvl', pr_tag_cont => rw_tbcadast_pessoa.cdestadoCivil, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'tpnacion', pr_tag_cont => rw_tbcadast_pessoa.tpnacionalidade, pr_des_erro => vr_dscritic);
       gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdnacion', pr_tag_cont => rw_tbcadast_pessoa.cdNacionalidade, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdoedptl', pr_tag_cont => rw_tbcadast_pessoa.cdExpedidor, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdufdptl', pr_tag_cont => rw_tbcadast_pessoa.cdufOrgaoExpedidor, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dtemdptl', pr_tag_cont => to_char(rw_tbcadast_pessoa.dtemissaoDocumento,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dtnasctl', pr_tag_cont => to_char(rw_tbcadast_pessoa.dtnascimento,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmconjug', pr_tag_cont => rw_tbcadast_pessoa.nmconjugue, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmmaettl', pr_tag_cont => rw_tbcadast_pessoa.nmmae,  pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmpaittl', pr_tag_cont => rw_tbcadast_pessoa.nmpai,  pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dsnatura', pr_tag_cont => rw_tbcadast_pessoa.naturalidadeDsCidade, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdufnatu', pr_tag_cont => rw_tbcadast_pessoa.naturalidadeCdEstado,  pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrdddres', pr_tag_cont => rw_tbcadast_pessoa.residencialNrddd, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrtelres', pr_tag_cont => rw_tbcadast_pessoa.residencialNrTelefone, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdopetfn', pr_tag_cont => rw_tbcadast_pessoa.celularCdOperadora, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrdddcel', pr_tag_cont => rw_tbcadast_pessoa.celularNrDdd, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrtelcel', pr_tag_cont => rw_tbcadast_pessoa.celularNrTelefone, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrcepend', pr_tag_cont => rw_tbcadast_pessoa.residencialNrCep, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dsendere', pr_tag_cont => rw_tbcadast_pessoa.residencialNmLogradouro, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrendere', pr_tag_cont => rw_tbcadast_pessoa.residencialNrLogradouro, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'complend', pr_tag_cont => rw_tbcadast_pessoa.residencialDsComplemento, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmbairro', pr_tag_cont => rw_tbcadast_pessoa.residencialNmBairro, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdufende', pr_tag_cont => rw_tbcadast_pessoa.residencialCdEstado, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_tbcadast_pessoa.residencialDsCidade, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'idorigee', pr_tag_cont => rw_tbcadast_pessoa.residencialTporigem, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdocpttl', pr_tag_cont => rw_tbcadast_pessoa.cdNaturezaOcupacao, pr_des_erro => vr_dscritic);
       gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrcadast', pr_tag_cont => rw_tbcadast_pessoa.cdCadastroEmpresa, pr_des_erro => vr_dscritic);            
       gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdsexotl', pr_tag_cont => rw_tbcadast_pessoa.tpsexo, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'idorgexp', pr_tag_cont => rw_tbcadast_pessoa.idorgaoExpedidor,  pr_des_erro => vr_dscritic);
			 
		ELSE 
		-- PJ	
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmfansia', pr_tag_cont => rw_tbcadast_pessoa.nmfantasia, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrcepend', pr_tag_cont => rw_tbcadast_pessoa.comercialNrCep, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dsendere', pr_tag_cont => rw_tbcadast_pessoa.comercialNmLogradouro, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrendere', pr_tag_cont => rw_tbcadast_pessoa.comercialNrLogradouro, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'complend', pr_tag_cont => rw_tbcadast_pessoa.comercialDsComplemento, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmbairro', pr_tag_cont => rw_tbcadast_pessoa.comercialNmBairro, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdufende', pr_tag_cont => rw_tbcadast_pessoa.comercialCdEstado, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_tbcadast_pessoa.comercialDsCidade, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'idorigee', pr_tag_cont => rw_tbcadast_pessoa.comercialTporigem, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrdddtfc', pr_tag_cont => rw_tbcadast_pessoa.comercialNrddd, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrtelefo', pr_tag_cont => rw_tbcadast_pessoa.comercialNrTelefone, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrinsest', pr_tag_cont => rw_tbcadast_pessoa.nrInscricao, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrlicamb', pr_tag_cont => rw_tbcadast_pessoa.nrLicenca, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'natjurid', pr_tag_cont => rw_tbcadast_pessoa.cdNatureza, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdseteco', pr_tag_cont => rw_tbcadast_pessoa.cdSetor, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdrmativ', pr_tag_cont => rw_tbcadast_pessoa.cdRamo, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdcnae'  , pr_tag_cont => rw_tbcadast_pessoa.cdCnae, pr_des_erro => vr_dscritic);
		   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dtiniatv', pr_tag_cont => to_char(rw_tbcadast_pessoa.dtInicioAtividade,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
			 
		END IF;
		
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0, pr_tag_nova => 'flgopcao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'flgopcao', pr_posicao => 0, pr_tag_nova => 'flgdpcnt', pr_tag_cont => vr_flgdpcnt, pr_des_erro => vr_dscritic);
		
		-- Retorno OK						 											 
    pr_des_erro := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADMAT.pc_consulta_pre_inclusao --> ' ||
                     SQLERRM;
                                  
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
  END pc_consulta_pre_inclusao;
	
		
  PROCEDURE pc_verifica_botoes(pr_nrdconta IN crapass.nrdconta%TYPE --> NR. da conta
		                          ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_verifica_botoes
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : Outubro/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para verificar quais botões devem ser habilitados na tela
    
    Alteracoes: 
    ............................................................................. */
  
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    --Cursor para verificar saque parcial
    CURSOR cr_saque_parcial(pr_cdcooper IN crapass.cdcooper%TYPE
		                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT a.nrdconta,
			       a.vlsaque,
						 a.cdmotivo
			  FROM tbcotas_saque_controle a
			 WHERE a.cdcooper = pr_cdcooper
			   AND a.nrdconta = pr_nrdconta
				 AND a.tpsaque  = 1 -- Saque parcial
				 AND a.dtefetivacao IS NULL; -- Processo de devolução ainda não efetivado
		rw_saque_parcial cr_saque_parcial%ROWTYPE;
		
		--Cursor para verificar desligamento
    CURSOR cr_desligamento(pr_cdcooper IN crapass.cdcooper%TYPE
		                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT a.nrdconta,
			       a.vlsaque,
						 a.cdmotivo
			  FROM tbcotas_saque_controle a
			 WHERE a.cdcooper = pr_cdcooper
			   AND a.nrdconta = pr_nrdconta
				 AND a.tpsaque  = 2 -- Desligamento
				 AND a.iddevolucao = 1 OR (a.iddevolucao = 2 AND a.dtago IS NOT NULL)
				 AND a.dtefetivacao IS NULL; -- Processo de devolução ainda não efetivado
		rw_desligamento cr_desligamento%ROWTYPE;
		
		-- Verificar se cooperado está desligado
		CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
		  SELECT 1
			  FROM crapass ass
			 WHERE ass.cdcooper = pr_cdcooper
			   AND ass.nrdconta = pr_nrdconta
				 AND ass.dtdemiss IS NOT NULL;
		rw_crapass cr_crapass%ROWTYPE;
		
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis locais
    vr_flgsaqpr NUMBER := 0;
    vr_flgdesli NUMBER := 0;
		vr_flgterde NUMBER := 0;
		vr_nrdconta NUMBER;
		vr_vlsaque_  NUMBER;
		vr_cdmotivo NUMBER;
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_exc_fim  EXCEPTION;
	
  BEGIN
		
		-- Incluir nome do módulo logado
		GENE0001.pc_informa_acesso(pr_module => 'TELA_CADMAT'
															,pr_action => null); 
			
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

    -- Buscar dados do cooperado
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    -- Se encontrou, devemos desabilitar todos os botoões
    IF cr_crapass%FOUND THEN
			-- Fechar cursor
			CLOSE cr_crapass;
			-- Desabilitar botões
			vr_flgsaqpr := 0;
			vr_flgdesli := 0;
			vr_flgterde := 0;
			-- Encerrar verificação
			RAISE vr_exc_fim;
		END IF;
		-- Fechar cursor
		CLOSE cr_crapass;

    -- Verificar botão de saque parcial
    OPEN cr_saque_parcial(pr_cdcooper => vr_cdcooper
		                     ,pr_nrdconta => pr_nrdconta);
    FETCH cr_saque_parcial INTO rw_saque_parcial;
		    	
	  -- Se encontrou	
		IF cr_saque_parcial%FOUND THEN
			-- Habilitar botão
			vr_flgsaqpr := 1;
		END IF;
		-- Fechar cursor
		CLOSE cr_saque_parcial;
		
		-- Verificar botão de desligamento
		OPEN cr_desligamento(pr_cdcooper => vr_cdcooper
		                    ,pr_nrdconta => pr_nrdconta);
    FETCH cr_desligamento INTO rw_desligamento;
		
		-- Se encontrou
		IF cr_desligamento%FOUND THEN
			-- Habilitar botão
			vr_flgdesli := 1;
		END IF;
		-- Fechar cursor
		CLOSE cr_desligamento;
		
		-- Encerrar verificação
		RAISE vr_exc_fim;

  EXCEPTION
    WHEN vr_exc_fim THEN
      -- Retorno não OK          
      pr_des_erro := 'OK';
          
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>' || 
																		   '<vr_flgsaqpr>' || vr_flgsaqpr || '</vr_flgsaqpr>' ||
																		   '<vr_flgdesli>' || vr_flgdesli || '</vr_flgdesli>' ||
																		   '<vr_flgterde>' || vr_flgterde || '</vr_flgterde>' ||
																		 '</Dados></Root>');

    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADMAT.pc_busca_dados_conta --> ' ||
                     SQLERRM;
                                  
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
  END pc_verifica_botoes;	
	
END TELA_CADMAT;
/
