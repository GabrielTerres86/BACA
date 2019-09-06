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

  PROCEDURE pc_busca_dados_envia(pr_nrdconta IN crapcdr.nrdconta%TYPE --> Numero da conta
                                ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2); --> Descricao do erro
                                
  PROCEDURE pc_busca_dados_contest_en(pr_nrdconta IN crapcdr.nrdconta%TYPE --> Numero da conta
                                     ,pr_nrsolicitacao IN tbcc_portabilidade_envia.nrsolicitacao%TYPE
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2); --> Descricao do erro
                                     
  PROCEDURE pc_busca_dados_contest_re(pr_nrnu_portabilidade IN tbcc_portabilidade_envia.nrnu_portabilidade%TYPE
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2); --> Descricao do erro

  PROCEDURE pc_busca_dados_recebe(pr_nrdconta IN crapcdr.nrdconta%TYPE --> Numero da conta
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2); --> Descricao do erro

  PROCEDURE pc_busca_bancos_folha(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2); --> Descricao do erro

  PROCEDURE pc_solicita_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                     ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE --> Codigo do banco folha
									 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2); --> Descricao do erro
                                     
  PROCEDURE pc_busca_motivos_regularizar(pr_idsituacao IN tbcc_portabilidade_recebe.idsituacao%TYPE
                                        ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                                        ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                                        ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2);

  PROCEDURE pc_busca_motivos_cancelamento(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2); --> Descricao do erro
                                         
  PROCEDURE pc_busca_motivos_contestacao(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2); --> Descricao do erro
                                        
  PROCEDURE pc_busca_motivos_responder(pr_cdmotivo IN tbcc_dominio_campo.cddominio%TYPE --> Codigo do Motivo
                                      ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2); 

  PROCEDURE pc_cancela_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                    ,pr_cdmotivo IN tbcc_portabilidade_envia.cdmotivo%TYPE --> Motivo do cancelamento
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2); --> Descricao do erro

  PROCEDURE pc_imprimir_termo_portab(pr_dsrowid  IN VARCHAR2 --> Rowid da tabela
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2); --> Descricao do erro
                                    
  PROCEDURE pc_imprimir_termo_conta(pr_cdcooper IN crapenc.cdcooper%TYPE --> Numero da cooperativa
                                    ,pr_nrdconta IN crapenc.nrdconta%TYPE --> Numero da conta
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);
                                    
  PROCEDURE pc_contesta_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                     ,pr_cdmotivo IN tbcc_portab_env_contestacao.cdmotivo%TYPE --> Motivo da contestacao
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2); --> Descricao do erro
                                     
  PROCEDURE pc_responde_contestacao(pr_dsrowid  IN VARCHAR2
                                   ,pr_cdmotivo IN tbcc_portab_rec_contestacao.cdmotivo%TYPE --> Motivo da resposta
                                   ,pr_idstatus IN tbcc_portab_rec_contestacao.idsituacao%TYPE --> Status da Situação
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2); --> Erros do processo
                                       
  PROCEDURE pc_regulariza_portabilidade(pr_cdmotivo IN tbcc_portab_regularizacao.cdmotivo%TYPE --> Motivo da regularização
                                       ,pr_dsrowid  IN VARCHAR2 --> registro selecionado
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);
                                       
  PROCEDURE pc_busca_dados_regularizacao(pr_nrnu_portabilidade IN tbcc_portabilidade_envia.nrnu_portabilidade%TYPE --> Numero da Portabilidade
                                	    ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);                

END TELA_ATENDA_PORTAB;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_PORTAB IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_PORTAB
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

  PROCEDURE pc_busca_dados_envia(pr_nrdconta IN crapcdr.nrdconta%TYPE --> Numero da conta
                                ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_dados_envia
    Sistema : Ayllos Web
    Autor   : Augusto - Supero
    Data    : Outubro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar os dados de envio.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Selecionar o CPF, Nome
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrcpfcgc
              ,crapass.nmprimtl
              ,crapass.inpessoa
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
    
      -- Seleciona o Telefone
      CURSOR cr_craptfc(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT '(' || to_char(craptfc.nrdddtfc) || ')' || craptfc.nrtelefo
          FROM craptfc
         WHERE craptfc.cdcooper = pr_cdcooper
           AND craptfc.nrdconta = pr_nrdconta
           AND craptfc.tptelefo IN (1, 2, 3)
         ORDER BY CASE tptelefo
                    WHEN 2 THEN -- priorizar celular
                     0
                    ELSE -- demais telefones
                     tptelefo
                  END ASC;
    
      -- Selecionar o Email
      CURSOR cr_crapcem(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT crapcem.dsdemail
          FROM crapcem
         WHERE crapcem.cdcooper = pr_cdcooper
           AND crapcem.nrdconta = pr_nrdconta
					 AND crapcem.idseqttl = 1
         ORDER BY crapcem.dtmvtolt
                 ,crapcem.hrtransa DESC;
    
      -- Selecionar o codigo da empresa
      CURSOR cr_crapttl(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT crapttl.nrcpfemp
              ,crapttl.nmextemp
              ,crapttl.cdempres
          FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
           AND crapttl.nrdconta = pr_nrdconta
           AND crapttl.idseqttl = 1;
    
      -- Seleciona a Instituicao Destinatario
      CURSOR cr_crapban_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT b.nrispbif
              ,b.nrcnpjif
              ,c.cdagectl
          FROM crapban b
              ,crapcop c
         WHERE b.cdbccxlt = c.cdbcoctl
           AND c.cdcooper = pr_cdcooper;
    
      -- Seleciona Portab Envia
      CURSOR cr_portab_envia(pr_cdcooper IN crapenc.cdcooper%TYPE
                            ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT '(' || to_char(tpe.nrddd_telefone) || ')' || tpe.nrtelefone AS telefone
              ,tpe.dsdemail
              ,dom.dscodigo AS situacao
              ,dom.cddominio AS cdsituacao
              ,dcp.dscodigo AS motivo
              ,dcp.cddominio AS cdmotivo
              ,to_char(tpe.dtsolicitacao, 'DD/MM/RRRR HH24:MI:SS') AS dtsolicitacao
              ,to_char(tpe.dtretorno, 'DD/MM/RRRR HH24:MI:SS') AS dtretorno
              ,tpe.cdbanco_folha
              ,tpe.nrispb_banco_folha
              ,tpe.nrcnpj_banco_folha
              ,to_char(tpe.nrnu_portabilidade) AS nrnu_portabilidade
              ,tpe.nrcpfcgc
              ,tpe.nmprimtl
              ,tpe.nrcnpj_empregador
              ,tpe.dsnome_empregador
              ,tpe.ROWID dsrowid
							,tpe.nrsolicitacao
              ,tpe.tppessoa_empregador
          FROM tbcc_portabilidade_envia tpe
              ,tbcc_dominio_campo       dom
              ,tbcc_dominio_campo       dcp
         WHERE tpe.idsituacao = dom.cddominio
           AND dom.nmdominio = 'SIT_PORTAB_SALARIO_ENVIA'
           AND dcp.nmdominio(+) = tpe.dsdominio_motivo
           AND dcp.cddominio(+) = to_char(tpe.cdmotivo)
           AND tpe.nrdconta = pr_nrdconta
           AND tpe.cdcooper = pr_cdcooper
         ORDER BY tpe.dtsolicitacao DESC;
      rw_portab_envia cr_portab_envia%ROWTYPE;
    
			CURSOR cr_erros(pr_cdcooper tbcc_portabilidade_envia.cdcooper%TYPE
										 ,pr_nrdconta tbcc_portabilidade_envia.nrdconta%TYPE
										 ,pr_nrsolici tbcc_portabilidade_envia.nrsolicitacao%TYPE) IS
			  SELECT dom.dscodigo
				      ,dom.cddominio
					FROM tbcc_portabilidade_env_erros tee
							,tbcc_dominio_campo dom
				 WHERE tee.cdmotivo         = dom.cddominio
					 AND tee.dsdominio_motivo = dom.nmdominio
					 AND tee.cdcooper = pr_cdcooper
					 AND tee.nrdconta = pr_nrdconta
					 AND tee.nrsolicitacao = pr_nrsolici;
			rw_erros cr_erros%ROWTYPE;
    
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis de log
      vr_cdcooper   INTEGER;
      vr_cdoperad   VARCHAR2(100);
      vr_nmdatela   VARCHAR2(100);
      vr_nmeacao    VARCHAR2(100);
      vr_cdagenci   VARCHAR2(100);
      vr_nrdcaixa   VARCHAR2(100);
      vr_idorigem   VARCHAR2(100);
      vr_cdbanco_bf VARCHAR2(100);
      vr_nrispb_bf  VARCHAR2(100);
      vr_dscnpj_bf  VARCHAR2(100);
      vr_tppessoa_empregador tbcc_portabilidade_envia.tppessoa_empregador%TYPE;
    
      -- Variaveis para CADA0008.pc_busca_inf_emp
      vr_nrdocnpj tbcc_portabilidade_envia.nrcnpj_empregador%TYPE;
      vr_nmpessot tbcadast_pessoa.nmpessoa%TYPE;
      vr_cdempres crapttl.cdempres%TYPE;
    
      -- Variaveis Gerais
      vr_nrcpfcgc     crapass.nrcpfcgc%TYPE;
      vr_nmprimtl     crapass.nmprimtl%TYPE;
      vr_inpessoa     crapass.inpessoa%TYPE;
      vr_nrtelefo     VARCHAR2(100);
      vr_dsdemail     crapcem.dsdemail%TYPE;
      vr_nrispbif_cop crapban.nrispbif%TYPE;
      vr_nrdocnpj_cop VARCHAR2(100);
      vr_cdagectl_cop crapcop.cdagectl%TYPE;
			vr_dsmotivo VARCHAR2(5000);
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      -- Criar cabecalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
      -- Selecionar o CPF, Nome e Tipo de Conta
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass
        INTO vr_nrcpfcgc
            ,vr_nmprimtl
            ,vr_inpessoa;
      IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
        vr_dscritic := 'Cooperado não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapass;
    
      -- Se for pessoa júridica
      IF vr_inpessoa = 2 THEN
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Root',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inpessoa_invalido',
                               pr_tag_cont => '1',
                               pr_des_erro => vr_dscritic);
        RETURN;
      END IF;
    
      -- Seleciona Portab Envia
      OPEN cr_portab_envia(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
      FETCH cr_portab_envia
        INTO rw_portab_envia;
      CLOSE cr_portab_envia;
    
      -- Selecionar a instituicao destinataria
      OPEN cr_crapban_crapcop(pr_cdcooper => vr_cdcooper);
      FETCH cr_crapban_crapcop
        INTO vr_nrispbif_cop
            ,vr_nrdocnpj_cop
            ,vr_cdagectl_cop;
      IF cr_crapban_crapcop%NOTFOUND THEN
				CLOSE cr_crapban_crapcop;
        vr_dscritic := 'Instituição Destinatária não encontrada.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapban_crapcop;
    
      -- Se houver portabilidade pendente
      IF nvl(rw_portab_envia.cdsituacao, 0) NOT IN (1, 2, 3, 5, 6, 9) THEN
        
        -- Selecionar o Telefone
        OPEN cr_craptfc(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
        FETCH cr_craptfc
          INTO vr_nrtelefo;
        CLOSE cr_craptfc;
      
        -- Selecionar o Email
        OPEN cr_crapcem(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
        FETCH cr_crapcem
          INTO vr_dsdemail;
        CLOSE cr_crapcem;
      
        -- Selecionar o codigo da empresa
        OPEN cr_crapttl(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
        FETCH cr_crapttl
          INTO vr_nrdocnpj
              ,vr_nmpessot
              ,vr_cdempres;
      
        IF cr_crapttl%NOTFOUND THEN
					CLOSE cr_crapttl;
          vr_dscritic := 'Codigo da empresa do titular da conta não encontrado.';
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapttl;
      	   
        vr_tppessoa_empregador := 2;
          IF vr_cdempres = 9998 THEN
            vr_tppessoa_empregador := 1;
          END IF; 
      ELSE
        vr_nrcpfcgc   := rw_portab_envia.nrcpfcgc;
        vr_nmprimtl   := rw_portab_envia.nmprimtl;
        vr_nrtelefo   := rw_portab_envia.telefone;
        vr_dsdemail   := rw_portab_envia.dsdemail;
        vr_nrdocnpj   := rw_portab_envia.nrcnpj_empregador;
        vr_nmpessot   := rw_portab_envia.dsnome_empregador;
        vr_cdbanco_bf := rw_portab_envia.cdbanco_folha;
        vr_nrispb_bf  := rw_portab_envia.nrispb_banco_folha;
          vr_tppessoa_empregador := rw_portab_envia.tppessoa_empregador;
        IF NVL(rw_portab_envia.nrcnpj_banco_folha, 0) > 0 THEN
          vr_dscnpj_bf := gene0002.fn_mask_cpf_cnpj(rw_portab_envia.nrcnpj_banco_folha, 2);
        ELSE
          vr_dscnpj_bf := NULL;
        END IF;
      END IF;
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Cooperado
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrcpfcgc',
                             pr_tag_cont => gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc, 1),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nmprimtl',
                             pr_tag_cont => vr_nmprimtl,
                             pr_des_erro => vr_dscritic);
    
      IF TRIM(NVL(vr_nrtelefo,'')) = '()' THEN
				vr_nrtelefo := '';
			END IF;
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrtelefo',
                             pr_tag_cont => vr_nrtelefo,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsdemail',
                             pr_tag_cont => NVL(vr_dsdemail, ''),
                             pr_des_erro => vr_dscritic);
    
      -- Banco folha
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'cdbanco_folha',
                             pr_tag_cont => vr_cdbanco_bf,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrispb_banco_folha',
                             pr_tag_cont => lpad(vr_nrispb_bf, 8, '0'),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrcnpj_banco_folha',
                             pr_tag_cont => vr_dscnpj_bf,
                             pr_des_erro => vr_dscritic);
    
      -- Empregador
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'tppessoa_empregador',
                               pr_tag_cont => vr_tppessoa_empregador,
                               pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrdocnpj_emp',
                             pr_tag_cont => gene0002.fn_mask_cpf_cnpj(vr_nrdocnpj, vr_tppessoa_empregador),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nmprimtl_emp',
                             pr_tag_cont => vr_nmpessot,
                             pr_des_erro => vr_dscritic);
    
      -- Instituição Destinataria                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrispbif',
                             pr_tag_cont => lpad(vr_nrispbif_cop, 8, '0'),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrdocnpj',
                             pr_tag_cont => gene0002.fn_mask_cpf_cnpj(vr_nrdocnpj_cop, 2),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'cdagectl',
                             pr_tag_cont => vr_cdagectl_cop,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrdconta',
                             pr_tag_cont => gene0002.fn_mask_conta(pr_nrdconta),
                             pr_des_erro => vr_dscritic);
    
      -- Status da Solicitação
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dssituacao',
                             pr_tag_cont => rw_portab_envia.situacao,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrnu_portabilidade',
                             pr_tag_cont => rw_portab_envia.nrnu_portabilidade,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtsolicita',
                             pr_tag_cont => rw_portab_envia.dtsolicitacao,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtretorno',
                             pr_tag_cont => rw_portab_envia.dtretorno,
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrsolicitacao',
                             pr_tag_cont => rw_portab_envia.nrsolicitacao,
                             pr_des_erro => vr_dscritic);
    
			vr_dsmotivo := rw_portab_envia.motivo;
			--
			IF upper(rw_portab_envia.cdmotivo) = 'EGENPCPS' THEN
				vr_dsmotivo := '';
				FOR rw_erros IN cr_erros(pr_cdcooper => vr_cdcooper
																,pr_nrdconta => pr_nrdconta
																,pr_nrsolici => rw_portab_envia.nrsolicitacao) LOOP
					--
					vr_dsmotivo := vr_dsmotivo || chr(10) || rw_erros.cddominio || ' - ' || rw_erros.dscodigo;
					--
				END LOOP;
				--
				IF trim(vr_dsmotivo) IS NULL THEN
					vr_dsmotivo := rw_portab_envia.motivo;
				END IF;
			END IF;
			--														 

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsmotivo',
                             pr_tag_cont => gene0007.fn_convert_db_web(vr_dsmotivo),
                             pr_des_erro => vr_dscritic);
    
      -- extras        
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'cdsituacao',
                             pr_tag_cont => rw_portab_envia.cdsituacao,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsrowid',
                             pr_tag_cont => rw_portab_envia.dsrowid,
                             pr_des_erro => vr_dscritic);
    
      -- Se houve retorno de erro
      IF nvl(vr_cdcritic, 0) > 0 OR
         vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  
  END pc_busca_dados_envia;
  
  PROCEDURE pc_busca_dados_contest_en(pr_nrdconta IN crapcdr.nrdconta%TYPE --> Numero da conta
                                     ,pr_nrsolicitacao IN tbcc_portabilidade_envia.nrsolicitacao%TYPE
                                	   ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_dados_contest_en
    Sistema : Ayllos Web
    Autor   : Andrey Formigari - Supero
    Data    : Janeiro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar os dados da contestacao.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Seleciona Contestação
      CURSOR cr_portab_contest(pr_cdcooper IN crapenc.cdcooper%TYPE
                              ,pr_nrdconta IN crapenc.nrdconta%TYPE
                              ,pr_nrsolicitacao IN tbcc_portabilidade_envia.nrsolicitacao%TYPE) IS
        SELECT t.situacao
              ,t.dtsolicitacao
              ,t.dtretorno
              ,t.identificador
              ,t.motivo
              ,t.retorno
			  ,t.cddominio
          FROM (SELECT dom.dscodigo AS situacao
                      ,to_char(tpe.dtcontestacao, 'DD/MM/RRRR HH24:MI:SS') AS dtsolicitacao
                      ,to_char(tpe.dtretorno, 'DD/MM/RRRR HH24:MI:SS') AS dtretorno
                      ,tpe.dsnu_contestacao AS identificador
                      ,dcp.dscodigo AS motivo
					  ,dom.cddominio
                      ,(SELECT dscodigo
                          FROM tbcc_dominio_campo
                         WHERE nmdominio = tpe.dsdominio_motivo_retorno
                           AND cddominio = tpe.cdmotivo_retorno) AS retorno
                  FROM tbcc_portab_env_contestacao tpe
                      ,tbcc_dominio_campo          dom
                      ,tbcc_dominio_campo          dcp
                 WHERE tpe.idsituacao = dom.cddominio
                   AND dom.nmdominio = 'SIT_PORTAB_CONTESTACAO_ENVIA'
                   AND dcp.nmdominio(+) = tpe.dsdominio_motivo
                   AND dcp.cddominio(+) = to_char(tpe.cdmotivo)
                   AND tpe.nrdconta = pr_nrdconta
                   AND tpe.cdcooper = pr_cdcooper
                   AND tpe.nrsolicitacao = pr_nrsolicitacao
	             ORDER BY tpe.dtcontestacao DESC) t
           WHERE rownum = 1;
      rw_portab_contest cr_portab_contest%ROWTYPE;
    
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis de log
      vr_cdcooper   INTEGER;
      vr_cdoperad   VARCHAR2(100);
      vr_nmdatela   VARCHAR2(100);
      vr_nmeacao    VARCHAR2(100);
      vr_cdagenci   VARCHAR2(100);
      vr_nrdcaixa   VARCHAR2(100);
      vr_idorigem   VARCHAR2(100);
      vr_cdbanco_bf VARCHAR2(100);
      vr_nrispb_bf  VARCHAR2(100);
      vr_dscnpj_bf  VARCHAR2(100);
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      -- Criar cabecalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
      -- Seleciona Portab Envia
      OPEN cr_portab_contest(pr_cdcooper => vr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrsolicitacao => pr_nrsolicitacao);
      FETCH cr_portab_contest INTO rw_portab_contest;
      CLOSE cr_portab_contest;
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
    
      -- Status da Solicitação
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dssituacao',
                             pr_tag_cont => rw_portab_contest.situacao,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'identificador',
                             pr_tag_cont => rw_portab_contest.identificador,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtsolicita',
                             pr_tag_cont => rw_portab_contest.dtsolicitacao,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtretorno',
                             pr_tag_cont => rw_portab_contest.dtretorno,
                             pr_des_erro => vr_dscritic);												 

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsmotivo',
                             pr_tag_cont => rw_portab_contest.motivo,
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsretorno',
                             pr_tag_cont => gene0007.fn_convert_db_web(rw_portab_contest.retorno),
                             pr_des_erro => vr_dscritic);

	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'cddominio',
                             pr_tag_cont => rw_portab_contest.cddominio,
                             pr_des_erro => vr_dscritic);
    
      -- Se houve retorno de erro
      IF nvl(vr_cdcritic, 0) > 0 OR
         vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  
  END pc_busca_dados_contest_en;
  
  PROCEDURE pc_busca_dados_contest_re(pr_nrnu_portabilidade IN tbcc_portabilidade_envia.nrnu_portabilidade%TYPE --> Numero da Portabilidade
                                	   ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_dados_contest_re
    Sistema : Ayllos Web
    Autor   : Andrey Formigari - Supero
    Data    : Janeiro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar os dados da contestacao.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Seleciona Contestação
      CURSOR cr_portab_contest(pr_nrnu_portabilidade IN tbcc_portabilidade_envia.nrnu_portabilidade%TYPE) IS
        SELECT t.situacao
              ,t.dtsolicitacao
              ,t.dtretorno
              ,t.identificador
              ,t.motivo
              ,t.retorno
			  ,t.cddominio
          FROM (SELECT dom.dscodigo AS situacao
                      ,to_char(tpe.dtcontestacao, 'DD/MM/RRRR HH24:MI:SS') AS dtsolicitacao
                      ,to_char(tpe.dtretorno, 'DD/MM/RRRR HH24:MI:SS') AS dtretorno
                      ,tpe.dsnu_contestacao AS identificador
                      ,dcp.dscodigo AS motivo
					  ,dom.cddominio
                      ,(SELECT dscodigo
                          FROM tbcc_dominio_campo
                         WHERE nmdominio = tpe.dsdominio_motivo_retorno
                           AND cddominio = tpe.cdmotivo_retorno) AS retorno
                  FROM tbcc_portab_rec_contestacao tpe
                      ,tbcc_dominio_campo          dom
                      ,tbcc_dominio_campo          dcp
                 WHERE tpe.idsituacao = dom.cddominio
                   AND dom.nmdominio = 'SIT_PORTAB_CONTESTACAO_RECEBE'
                   AND dcp.nmdominio(+) = tpe.dsdominio_motivo
                   AND dcp.cddominio(+) = to_char(tpe.cdmotivo)
                   AND tpe.nrnu_portabilidade = pr_nrnu_portabilidade
	             ORDER BY tpe.dtcontestacao DESC) t
           WHERE rownum = 1;
      rw_portab_contest cr_portab_contest%ROWTYPE;
    
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis de log
      vr_cdcooper   INTEGER;
      vr_cdoperad   VARCHAR2(100);
      vr_nmdatela   VARCHAR2(100);
      vr_nmeacao    VARCHAR2(100);
      vr_cdagenci   VARCHAR2(100);
      vr_nrdcaixa   VARCHAR2(100);
      vr_idorigem   VARCHAR2(100);
      vr_cdbanco_bf VARCHAR2(100);
      vr_nrispb_bf  VARCHAR2(100);
      vr_dscnpj_bf  VARCHAR2(100);
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      -- Criar cabecalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
      -- Seleciona Portab Envia
      OPEN cr_portab_contest(pr_nrnu_portabilidade => pr_nrnu_portabilidade);
      FETCH cr_portab_contest INTO rw_portab_contest;
      CLOSE cr_portab_contest;
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
    
      -- Status da Solicitação
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dssituacao',
                             pr_tag_cont => rw_portab_contest.situacao,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'identificador',
                             pr_tag_cont => rw_portab_contest.identificador,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtsolicita',
                             pr_tag_cont => rw_portab_contest.dtsolicitacao,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtretorno',
                             pr_tag_cont => rw_portab_contest.dtretorno,
                             pr_des_erro => vr_dscritic);												 

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsmotivo',
                             pr_tag_cont => rw_portab_contest.motivo,
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsretorno',
                             pr_tag_cont => rw_portab_contest.retorno,
                             pr_des_erro => vr_dscritic);
							 
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'cddominio',
                             pr_tag_cont => rw_portab_contest.cddominio,
                             pr_des_erro => vr_dscritic);
							     
      -- Se houve retorno de erro
      IF nvl(vr_cdcritic, 0) > 0 OR
         vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  
  END pc_busca_dados_contest_re;
  
  PROCEDURE pc_busca_dados_regularizacao(pr_nrnu_portabilidade IN tbcc_portabilidade_envia.nrnu_portabilidade%TYPE --> Numero da Portabilidade
                                	      ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_dados_regularizacao
    Sistema : Ayllos Web
    Autor   : Andrey Formigari - Supero
    Data    : Janeiro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar os dados da regularização.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Seleciona Contestação
      CURSOR cr_portab_contest(pr_nrnu_portabilidade IN tbcc_portabilidade_envia.nrnu_portabilidade%TYPE) IS
        SELECT t.dtregularizacao
              ,t.dtretorno
              ,t.dsmotivo
              ,t.dssituacao
              ,t.idsituacao
              ,t.dsdominio_motivo_retorno dsdomret
              ,t.cdmotivo_retorno         cdmotret
          FROM (SELECT to_char(tpg.dtregularizacao, 'DD/MM/RRRR HH24:MI:SS') AS dtregularizacao
                      ,to_char(tpg.dtretorno, 'DD/MM/RRRR HH24:MI:SS') AS dtretorno
                      ,(SELECT dscodigo
                          FROM tbcc_dominio_campo
                         WHERE nmdominio = tpg.dsdominio_motivo
                           AND cddominio = tpg.cdmotivo) AS dsmotivo
                      ,dom.dscodigo AS dssituacao
                      ,tpg.idsituacao
                      ,tpg.dsdominio_motivo_retorno
                      ,tpg.cdmotivo_retorno
                  FROM tbcc_portab_regularizacao tpg
                      ,tbcc_dominio_campo        dom
                      ,tbcc_dominio_campo        dcp
                 WHERE tpg.idsituacao = dom.cddominio
                   AND dom.nmdominio = 'SIT_PORTAB_REGULARIZACAO'
                   AND dcp.nmdominio(+) = tpg.dsdominio_motivo
                   AND dcp.cddominio(+) = to_char(tpg.cdmotivo)
                   AND to_char(tpg.nrnu_portabilidade) = to_char(pr_nrnu_portabilidade)
                 ORDER BY tpg.dtregularizacao DESC) t
         WHERE rownum = 1;
      rw_portab_contest cr_portab_contest%ROWTYPE;
    
			CURSOR cr_dominio(pr_nmdominio tbcc_dominio_campo.nmdominio%TYPE
			                 ,pr_cddominio tbcc_dominio_campo.cddominio%TYPE) IS
					SELECT dom.dscodigo
		  	    FROM tbcc_dominio_campo dom
					 WHERE dom.nmdominio = pr_nmdominio
					   AND dom.cddominio = pr_cddominio;
			rw_dominio cr_dominio%ROWTYPE;
    
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis de log
      vr_cdcooper   INTEGER;
      vr_cdoperad   VARCHAR2(100);
      vr_nmdatela   VARCHAR2(100);
      vr_nmeacao    VARCHAR2(100);
      vr_cdagenci   VARCHAR2(100);
      vr_nrdcaixa   VARCHAR2(100);
      vr_idorigem   VARCHAR2(100);
      vr_cdbanco_bf VARCHAR2(100);
      vr_nrispb_bf  VARCHAR2(100);
      vr_dscnpj_bf  VARCHAR2(100);
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      -- Criar cabecalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
      -- Seleciona Portab Envia
      OPEN cr_portab_contest(pr_nrnu_portabilidade => pr_nrnu_portabilidade);
      FETCH cr_portab_contest INTO rw_portab_contest;
      CLOSE cr_portab_contest;
    
			IF rw_portab_contest.idsituacao = 5 THEN
				--
				IF rw_portab_contest.dsdomret IS NOT NULL AND rw_portab_contest.cdmotret IS NOT NULL THEN
					--
					OPEN cr_dominio(pr_nmdominio => rw_portab_contest.dsdomret
												 ,pr_cddominio => rw_portab_contest.cdmotret);
					FETCH cr_dominio INTO rw_dominio;
					--
					IF cr_dominio%FOUND THEN
					   rw_portab_contest.dsmotivo := rw_dominio.dscodigo;
					END IF;
          CLOSE cr_dominio;
				END IF;
			END IF;
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
    
      -- Status da Solicitação
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dssituacao',
                             pr_tag_cont => rw_portab_contest.dssituacao,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtregularizacao',
                             pr_tag_cont => rw_portab_contest.dtregularizacao,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtretorno',
                             pr_tag_cont => rw_portab_contest.dtretorno,
                             pr_des_erro => vr_dscritic);												 

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsmotivo',
                             pr_tag_cont => rw_portab_contest.dsmotivo,
                             pr_des_erro => vr_dscritic);                      
    
      -- Se houve retorno de erro
      IF nvl(vr_cdcritic, 0) > 0 OR
         vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  
  END pc_busca_dados_regularizacao;

  PROCEDURE pc_busca_dados_recebe(pr_nrdconta IN crapcdr.nrdconta%TYPE --> Numero da conta
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_dados_envia
    Sistema : Ayllos Web
    Autor   : Augusto - Supero
    Data    : Outubro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar os dados de envio.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Seleciona Portab Recebe
      CURSOR cr_portab_recebe(pr_cdcooper IN crapenc.cdcooper%TYPE
                             ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT to_char(tpr.nrnu_portabilidade) nrnu_portabilidade
              ,to_char(tpr.dtsolicitacao, 'DD/MM/RRRR HH24:MI:SS') dtsolicitacao
              ,tpr.nrcnpj_empregador
              ,tpr.dsnome_empregador
              ,lpad(ban.cdbccxlt, 3, '0') || ' - ' || ban.nmresbcc banco
              ,tpr.cdagencia_destinataria
              ,tpr.nrdconta_destinataria
              ,tpr.idsituacao
							,dom.dscodigo situacao
              ,dcp.dscodigo motivo
							,dcp.cddominio cdmotivo
							,to_char(tpr.dtavaliacao, 'DD/MM/RRRR HH24:MI:SS') dtavaliacao
              ,tpr.rowid
              ,tpr.tppessoa_empregador
              ,(SELECT tprc.idsituacao
                  FROM (SELECT t.nrnu_portabilidade
                             , t.idsituacao
                             , t.dtregularizacao
                             , MAX(t.dtregularizacao) OVER (PARTITION BY t.nrnu_portabilidade) dtmaxregulariz
                          FROM tbcc_portab_regularizacao t) tprc
                 WHERE tprc.dtregularizacao        = tprc.dtmaxregulariz 
                   AND tprc.nrnu_portabilidade   = tpr.nrnu_portabilidade
                   AND rownum = 1) AS idsituacao_regularizacao
          FROM tbcc_portabilidade_recebe tpr
              ,crapban                   ban
              ,tbcc_dominio_campo        dom
              ,tbcc_dominio_campo        dcp							
         WHERE ban.nrispbif(+) = tpr.nrispb_destinataria
				   AND tpr.idsituacao = dom.cddominio
           AND dom.nmdominio = 'SIT_PORTAB_SALARIO_RECEBE'
           AND dcp.nmdominio(+) = tpr.dsdominio_motivo
           AND dcp.cddominio(+) = to_char(tpr.cdmotivo)
           AND tpr.nrdconta = pr_nrdconta
           AND tpr.cdcooper = pr_cdcooper
         ORDER BY tpr.dtsolicitacao DESC;
      rw_portab_recebe cr_portab_recebe%ROWTYPE;
    
			CURSOR cr_erros(pr_nuportab tbcc_portabilidade_rcb_erros.nrnu_portabilidade%TYPE) IS
					SELECT dom.dscodigo
					      ,dom.cddominio
						FROM tbcc_portabilidade_rcb_erros tee
								,tbcc_dominio_campo           dom
					 WHERE tee.cdmotivo           = dom.cddominio
						 AND tee.dsdominio_motivo   = dom.nmdominio
						 AND tee.nrnu_portabilidade = pr_nuportab;
			rw_erros cr_erros%ROWTYPE;			
    
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
    
      -- Variaveis internas
      vr_dscnpjbc VARCHAR2(100);
			vr_dsmotivo VARCHAR2(5000);
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      -- Criar cabecalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
      -- Seleciona Portab Envia
      OPEN cr_portab_recebe(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
      FETCH cr_portab_recebe
        INTO rw_portab_recebe;
      CLOSE cr_portab_recebe;
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Portabilidade
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrnu_portabilidade',
                             pr_tag_cont => rw_portab_recebe.nrnu_portabilidade,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtsolicitacao',
                             pr_tag_cont => rw_portab_recebe.dtsolicitacao,
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsrowid',
                             pr_tag_cont => rw_portab_recebe.rowid,
                             pr_des_erro => vr_dscritic);
    
      -- Empregador
      IF NVL(rw_portab_recebe.nrcnpj_empregador, 0) > 0 THEN
        vr_dscnpjbc := gene0002.fn_mask_cpf_cnpj(rw_portab_recebe.nrcnpj_empregador, rw_portab_recebe.tppessoa_empregador);
      ELSE
        vr_dscnpjbc := NULL;
      END IF;
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrcnpj_empregador',
                             pr_tag_cont => vr_dscnpjbc,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsnome_empregador',
                             pr_tag_cont => rw_portab_recebe.dsnome_empregador,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'tppessoa_empregador',
                             pr_tag_cont => rw_portab_recebe.tppessoa_empregador,
                             pr_des_erro => vr_dscritic);
    
      -- Instituição Destinataria
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'banco',
                             pr_tag_cont => rw_portab_recebe.banco,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'cdagencia_destinataria',
                             pr_tag_cont => rw_portab_recebe.cdagencia_destinataria,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrdconta_destinataria',
                             pr_tag_cont => gene0002.fn_mask_conta(rw_portab_recebe.nrdconta_destinataria),
                             pr_des_erro => vr_dscritic);
														 
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtavaliacao',
                             pr_tag_cont => rw_portab_recebe.dtavaliacao,
                             pr_des_erro => vr_dscritic);
														 
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dssituacao',
                             pr_tag_cont => rw_portab_recebe.situacao,
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'idsituacao_regularizacao',
                             pr_tag_cont => rw_portab_recebe.idsituacao_regularizacao,
                             pr_des_erro => vr_dscritic);
														 
      vr_dsmotivo := rw_portab_recebe.motivo;
			--
			IF upper(rw_portab_recebe.cdmotivo) = 'EGENPCPS' THEN
				vr_dsmotivo := '';
				FOR rw_erros IN cr_erros(rw_portab_recebe.nrnu_portabilidade) LOOP
					--
					vr_dsmotivo := vr_dsmotivo || chr(10) || rw_erros.cddominio || ' - ' || rw_erros.dscodigo;
					--
				END LOOP;
				--
				IF trim(vr_dsmotivo) IS NULL THEN
					vr_dsmotivo := rw_portab_recebe.motivo;
				END IF;
			END IF;
			--														 

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsmotivo',
                             pr_tag_cont => gene0007.fn_convert_db_web(vr_dsmotivo),
                             pr_des_erro => vr_dscritic);
    
      -- extras        
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'cdsituacao',
                             pr_tag_cont => rw_portab_recebe.idsituacao,
                             pr_des_erro => vr_dscritic);
    
      -- Se houve retorno de erro
      IF nvl(vr_cdcritic, 0) > 0 OR
         vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  
  END pc_busca_dados_recebe;

  PROCEDURE pc_busca_bancos_folha(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_bancos_folha
    Sistema : Ayllos Web
    Autor   : Andre Clemer (Supero)
    Data    : Outubro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar os bancos folha.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Selecionar o CPF, Nome
      CURSOR cr_crapban IS
        SELECT lpad(t.cdbccxlt, 3, '0') || ' - ' || UPPER(t.nmextbcc) AS dsdbanco
              ,t.nrispbif
              ,t.nrcnpjif
              ,t.cdbccxlt
          FROM crapban t
         WHERE t.flgdispb = 1
           AND t.nrcnpjif > 0
         ORDER BY t.cdbccxlt;
    
      rw_crapban cr_crapban%ROWTYPE;
    
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
      vr_dscnpjif VARCHAR2(20);
    
      -- Variaveis locais
      vr_contador INTEGER := 0;
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Criar cabecalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
      FOR rw_crapban IN cr_crapban LOOP
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inf',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsdbanco',
                               pr_tag_cont => rw_crapban.dsdbanco,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrispbif',
                               pr_tag_cont => lpad(rw_crapban.nrispbif, 8, '0'),
                               pr_des_erro => vr_dscritic);
      
        IF NVL(rw_crapban.nrcnpjif, 0) > 0 THEN
          vr_dscnpjif := gene0002.fn_mask_cpf_cnpj(rw_crapban.nrcnpjif, 2);
        ELSE
          vr_dscnpjif := NULL;
        END IF;
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrcnpjif',
                               pr_tag_cont => vr_dscnpjif,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdbccxlt',
                               pr_tag_cont => rw_crapban.cdbccxlt,
                               pr_des_erro => vr_dscritic);
      
        vr_contador := vr_contador + 1;
      
      END LOOP;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  
  END pc_busca_bancos_folha;

  PROCEDURE pc_solicita_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                     ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE --> Codigo do banco folha
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_solicita_portabilidade
    Sistema : Ayllos Web
    Autor   : Andre Clemer (Supero)
    Data    : Outubro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para solicitar portabilidade.
    
    Alteracoes: -----
    
          07/05/2019 - Não permitir solicitações de portabilidade com CNPJ do 
                       empregador nulo ou igual a zero. (Renato Darosci - Supero)
    ..............................................................................*/
    DECLARE
    
      -- Selecionar o banco folha
      CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
        SELECT crapban.nrcnpjif
				      ,nvl(crapban.nrispbif, 0) nrispbif
          FROM crapban
         WHERE crapban.cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;
    
      -- Selecionar o CPF, Nome
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrcpfcgc
              ,crapass.nmprimtl
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
    
      -- Selecionar DDD + telefone
      CURSOR cr_craptfc(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT craptfc.nrdddtfc
             , craptfc.nrtelefo
          FROM craptfc
         WHERE craptfc.cdcooper = pr_cdcooper
           AND craptfc.nrdconta = pr_nrdconta
           AND craptfc.tptelefo IN (1, 2, 3)
         ORDER BY CASE tptelefo
                    WHEN 2 THEN -- priorizar celular
                     0
                    ELSE -- demais telefones
                     tptelefo
                  END ASC; -- retorna apenas uma ocorrencia conforme prioridade na ordenacao
      rw_craptfc cr_craptfc%ROWTYPE;
    
      -- Selecionar o Email
      CURSOR cr_crapcem(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT dsdemail
          FROM (SELECT crapcem.dsdemail
                  FROM crapcem
                 WHERE crapcem.cdcooper = pr_cdcooper
                   AND crapcem.nrdconta = pr_nrdconta
                 ORDER BY crapcem.dtmvtolt
                         ,crapcem.hrtransa DESC)
         WHERE rownum = 1; -- retorna apenas uma ocorrencia
      rw_crapcem cr_crapcem%ROWTYPE;
    
      -- Selecionar dados da empresa do cooperado
      CURSOR cr_crapttl(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT crapttl.nrcpfemp
              ,crapttl.nmextemp
              ,crapttl.cdempres
          FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
           AND crapttl.nrdconta = pr_nrdconta
           AND crapttl.idseqttl = 1;
      rw_crapttl cr_crapttl%ROWTYPE;
    
      -- Seleciona a Instituicao Destinatario
      CURSOR cr_crapcop(pr_cdcooper IN crapenc.cdcooper%TYPE) IS
        SELECT b.nrispbif
              ,b.nrcnpjif
              ,c.cdagectl
          FROM crapban b
              ,crapcop c
         WHERE b.cdbccxlt = c.cdbcoctl
           AND c.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
    
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      pr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
    
      -- Variaveis locais
      vr_nrsolicitacao tbcc_portabilidade_envia.nrsolicitacao%TYPE;
      vr_tppessoa_empregador tbcc_portabilidade_envia.tppessoa_empregador%TYPE;
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => pr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      /***
       ** INICIO DAS VALIDAÇÕES
      ***/
    
      -- Valida Nro da conta
      IF TRIM(pr_nrdconta) IS NULL THEN
        vr_dscritic := 'Numero de Conta nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
    
      -- Valida dados do Banco Folha
      IF TRIM(pr_cdbccxlt) IS NULL THEN
        vr_dscritic := 'Codigo do Banco Folha nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
    
      -- Busca dados do Banco Folha
      OPEN cr_crapban(pr_cdbccxlt);
      FETCH cr_crapban
        INTO rw_crapban;
    
      IF cr_crapban%NOTFOUND THEN
				CLOSE cr_crapban;
        vr_dscritic := 'Banco Folha nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
			CLOSE cr_crapban;			
			
		  IF rw_crapban.nrcnpjif = 0 THEN
        vr_dscritic := 'CNPJ do Banco Folha nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
    
      -- Busca informacoes do cooperado
      OPEN cr_crapass(vr_cdcooper, pr_nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
    
      -- Valida dados do cooperado
      IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
        vr_dscritic := 'Dados do cooperado nao encontrados.';
        RAISE vr_exc_erro;
      END IF;
			CLOSE cr_crapass;
    
      IF TRIM(rw_crapass.nmprimtl) IS NULL THEN
        vr_dscritic := 'Nome do cooperado nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
    
      IF TRIM(rw_crapass.nrcpfcgc) IS NULL THEN
        vr_dscritic := 'CPF do cooperado nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
    
      -- Busca telefone do cooperado
      OPEN cr_craptfc(vr_cdcooper, pr_nrdconta);
      FETCH cr_craptfc
        INTO rw_craptfc;
    
      IF length(rw_craptfc.nrdddtfc) <> 2 THEN
				CLOSE cr_craptfc;
        vr_dscritic := 'DDD do cooperado invalido.';
        RAISE vr_exc_erro;
      END IF;
			CLOSE cr_craptfc;
    
      IF length(rw_craptfc.nrtelefo) > 9 OR
         length(rw_craptfc.nrtelefo) < 6 THEN
        vr_dscritic := 'Numero do telefone do cooperado invalido.';
        RAISE vr_exc_erro;
      END IF;
    
      -- Busca email do cooperado
      OPEN cr_crapcem(vr_cdcooper, pr_nrdconta);
      FETCH cr_crapcem
        INTO rw_crapcem;
				
			CLOSE cr_crapcem;
    
      -- Busca CNPJ e Nome da empresa do cooperado    
      OPEN cr_crapttl(vr_cdcooper, pr_nrdconta);
      FETCH cr_crapttl
        INTO rw_crapttl;
    
      IF cr_crapttl%NOTFOUND THEN
				CLOSE cr_crapttl;
        vr_dscritic := 'Dados do empregador nao encontrados.';
        RAISE vr_exc_erro;
      END IF;
			CLOSE cr_crapttl;
    
      vr_tppessoa_empregador := 2;
      IF rw_crapttl.cdempres = 9998 THEN
        vr_tppessoa_empregador := 1;
      END IF;
    
      IF TRIM(rw_crapttl.nmextemp) IS NULL THEN
        vr_dscritic := 'Nome do empregador nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
    
      IF NVL(rw_crapttl.nrcpfemp,0) = 0 THEN
        vr_dscritic := 'CNPJ do empregador nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
    
      -- Busca dados da instituicao financeira destinataria
      OPEN cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
    
      IF cr_crapcop%NOTFOUND THEN
				CLOSE cr_crapcop;
        vr_dscritic := 'Dados da Instituicao Financeira Destinataria nao encontrados.';
        RAISE vr_exc_erro;
      END IF;
			CLOSE cr_crapcop;
    
      IF TRIM(rw_crapcop.nrispbif) IS NULL THEN
        vr_dscritic := 'ISPB da Instituicao Financeira Destinataria nao encontrada.';
        RAISE vr_exc_erro;
      END IF;
    
      IF TRIM(rw_crapcop.nrcnpjif) IS NULL THEN
        vr_dscritic := 'CNPJ da Instituicao Financeira Destinataria nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
    
      IF TRIM(rw_crapcop.cdagectl) IS NULL THEN
        vr_dscritic := 'Agencia da Instituicao Financeira Destinataria nao encontrada.';
        RAISE vr_exc_erro;
      END IF;
    
      /***
       ** FIM DAS VALIDAÇÕES.
      ***/
    
      BEGIN
      
        SELECT nvl(MAX(nrsolicitacao), 0) + 1
          INTO vr_nrsolicitacao
          FROM tbcc_portabilidade_envia
         WHERE cdcooper = vr_cdcooper
           AND nrdconta = pr_nrdconta;
      EXCEPTION
				WHEN no_data_found THEN
					vr_nrsolicitacao := 1;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao buscar Numero de solicitacao: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    
      BEGIN
        INSERT INTO tbcc_portabilidade_envia
          (cdcooper
          ,nrdconta
          ,nrsolicitacao
          ,dtsolicitacao
          ,nrcpfcgc
          ,nmprimtl
          ,nrddd_telefone
          ,nrtelefone
          ,dsdemail
          ,cdbanco_folha
          ,cdagencia_folha
          ,nrispb_banco_folha
          ,nrcnpj_banco_folha
          ,nrcnpj_empregador
          ,dsnome_empregador
          ,nrispb_destinataria
          ,nrcnpj_destinataria
          ,cdtipo_conta
          ,cdagencia
          ,idsituacao
          ,cdoperador
          ,tppessoa_empregador)
        VALUES
          (vr_cdcooper
          ,pr_nrdconta
          ,vr_nrsolicitacao
          ,SYSDATE
          ,rw_crapass.nrcpfcgc
          ,rw_crapass.nmprimtl
          ,rw_craptfc.nrdddtfc
          ,rw_craptfc.nrtelefo
          ,rw_crapcem.dsdemail
          ,pr_cdbccxlt
          ,0
          ,rw_crapban.nrispbif
          ,rw_crapban.nrcnpjif
          ,rw_crapttl.nrcpfemp
          ,rw_crapttl.nmextemp
          ,rw_crapcop.nrispbif
          ,rw_crapcop.nrcnpjif
          ,'CC' -- Conta Corrente
          ,rw_crapcop.cdagectl
          ,1 -- a solicitar
          ,vr_cdoperad
          ,vr_tppessoa_empregador);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao criar solicitacao de portabilidade: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    
      -- Abre o cursor de data
      OPEN btch0001.cr_crapdat(vr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      
      -- Gerar pendencia de digitalizacao
      DIGI0001.pc_gera_pend_digitalizacao(pr_cdcooper => vr_cdcooper -- Cooperativa
                                         ,pr_nrdconta => pr_nrdconta -- Conta
                                         ,pr_idseqttl => 1 -- Fixo   -- Sera gerado para o titular
                                         ,pr_nrcpfcgc => rw_crapass.nrcpfcgc -- CPF do cooperado
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data do dia
                                         ,pr_lstpdoct => 78          -- DOC: PORT SALARIO - TERMO DE ADESAO
                                         ,pr_cdoperad => vr_cdoperad -- Operador 
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic, 0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Efetua os inserts para apresentacao na tela VERLOG
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => ' ',
                           pr_dsorigem => '',
                           pr_dstransa => 'Solicitacao de Portabilidade de Salario',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                           pr_idseqttl => 1,
                           pr_nmdatela => ' ',
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);
    
      -- Gera o log para o CPF do cooperado
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'CPF',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc, 1));
      -- Gera o log para o nome do cooperado
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Nome',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_crapass.nmprimtl);
      -- Gera o log para o DDD do cooperado
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'DDD',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_craptfc.nrdddtfc);
      -- Gera o log para o Telefone do cooperado
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Telefone',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_craptfc.nrtelefo);
      -- Gera o log para o E-mail do cooperado
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'E-mail',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_crapcem.dsdemail);
      -- Gera o log para o Cod. Banco Folha
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Cod. Banco Folha',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => pr_cdbccxlt);
      -- Gera o log para o ISPB Banco Folha
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'ISPB Banco Folha',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_crapban.nrispbif);
      -- Gera o log para o CNPJ Banco Folha
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'CNPJ Banco Folha',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(rw_crapban.nrcnpjif, 2));
      -- Gera o log para o CNPJ Empregador
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'CNPJ Empregador',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(rw_crapttl.nrcpfemp, 2));
      -- Gera o log para o Nome Empregador
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Nome Empregador',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_crapttl.nmextemp);
      -- Gera o log para o ISPB Destinataria
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'ISPB Destinataria',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_crapcop.nrispbif);
      -- Gera o log para o CNPJ Destinataria
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'CNPJ Destinataria',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_crapcop.nrcnpjif);
      -- Gera o log para o Tipo Conta
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Tipo Conta CIP',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => 'Conta Corrente');
      -- Gera o log para o Agencia Destinataria
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Agencia Destinataria',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_crapcop.cdagectl);
    
      COMMIT;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
        ROLLBACK;
    END;
  
  END pc_solicita_portabilidade;

  PROCEDURE pc_busca_motivos_cancelamento(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_motivos_cancelamento
    Sistema : Ayllos Web
    Autor   : Andre Clemer (Supero)
    Data    : Outubro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar os motivos de cancelamento da portabilidade.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Buscar os motivos
      CURSOR cr_motivos IS
        SELECT cddominio
              ,nmdominio
              ,dscodigo
          FROM tbcc_dominio_campo
         WHERE nmdominio = 'MOTVCANCELTPORTDDCTSALR';
    
      rw_motivos cr_motivos%ROWTYPE;
    
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
    
      -- Variaveis locais
      vr_contador INTEGER := 0;
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Criar cabecalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
      FOR rw_motivos IN cr_motivos LOOP
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inf',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cddominio',
                               pr_tag_cont => rw_motivos.cddominio,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmdominio',
                               pr_tag_cont => rw_motivos.nmdominio,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dscodigo',
                               pr_tag_cont => rw_motivos.dscodigo,
                               pr_des_erro => vr_dscritic);
      
        vr_contador := vr_contador + 1;
      
      END LOOP;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  
  END pc_busca_motivos_cancelamento;
  
  PROCEDURE pc_busca_motivos_contestacao(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_motivos_contestacao
    Sistema : Ayllos Web
    Autor   : Andrey Formigari (Supero)
    Data    : Janeiro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar os motivos de contestação da portabilidade.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Buscar os motivos
      CURSOR cr_motivos IS
        SELECT cddominio
              ,nmdominio
              ,dscodigo
          FROM tbcc_dominio_campo
         WHERE nmdominio = 'MOTVCONTTC';
    
      rw_motivos cr_motivos%ROWTYPE;
    
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
    
      -- Variaveis locais
      vr_contador INTEGER := 0;
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Criar cabecalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
      FOR rw_motivos IN cr_motivos LOOP
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inf',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cddominio',
                               pr_tag_cont => rw_motivos.cddominio,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmdominio',
                               pr_tag_cont => rw_motivos.nmdominio,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dscodigo',
                               pr_tag_cont => rw_motivos.dscodigo,
                               pr_des_erro => vr_dscritic);
      
        vr_contador := vr_contador + 1;
      
      END LOOP;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  
  END pc_busca_motivos_contestacao;
  
  PROCEDURE pc_busca_motivos_responder(pr_cdmotivo IN tbcc_dominio_campo.cddominio%TYPE
                                      ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_motivos_responder
    Sistema : Ayllos Web
    Autor   : Andrey Formigari (Supero)
    Data    : Janeiro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar os motivos da opção "Responde Contestação"
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Buscar os motivos
      CURSOR cr_motivos(pr_nmdominio tbcc_dominio_campo.nmdominio%TYPE) IS
        SELECT cddominio
              ,nmdominio
              ,dscodigo
          FROM tbcc_dominio_campo
         WHERE nmdominio = pr_nmdominio;
      rw_motivos cr_motivos%ROWTYPE;
    
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
    
      -- Variaveis locais
      vr_contador INTEGER := 0;
      vr_nmdominio tbcc_dominio_campo.nmdominio%TYPE; 
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Criar cabecalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      IF pr_cdmotivo = '2' THEN
         vr_nmdominio := 'MOTVRESPCONTTCAPROVD';
      ELSIF pr_cdmotivo = '3' THEN
         vr_nmdominio := 'MOTVRESPCONTTCREPVD';
      END IF;
    
      FOR rw_motivos IN cr_motivos(vr_nmdominio) LOOP
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inf',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cddominio',
                               pr_tag_cont => rw_motivos.cddominio,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmdominio',
                               pr_tag_cont => rw_motivos.nmdominio,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dscodigo',
                               pr_tag_cont => rw_motivos.dscodigo,
                               pr_des_erro => vr_dscritic);
      
        vr_contador := vr_contador + 1;
      
      END LOOP;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  
  END pc_busca_motivos_responder;
  
  PROCEDURE pc_busca_motivos_regularizar(pr_idsituacao IN tbcc_portabilidade_recebe.idsituacao%TYPE
                                        ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                                        ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                                        ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_motivos_regularizar
    Sistema : Ayllos Web
    Autor   : Andrey Formigari (Supero)
    Data    : Janeiro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar os motivos da opção "Regularizar" de acordo com a pr_idsituacao.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Buscar os motivos
      CURSOR cr_motivos(pr_nmdominio tbcc_dominio_campo.nmdominio%TYPE) IS
        SELECT cddominio
              ,nmdominio
              ,dscodigo
          FROM tbcc_dominio_campo
         WHERE nmdominio = pr_nmdominio;
      rw_motivos cr_motivos%ROWTYPE;
    
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
    
      -- Variaveis locais
      vr_contador INTEGER := 0;
      vr_nmdominio tbcc_dominio_campo.nmdominio%TYPE; 
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Criar cabecalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      IF pr_idsituacao = 3 THEN
         vr_nmdominio := 'MOTVREGLZCAPROVD';
      ELSIF pr_idsituacao = 2 THEN
         vr_nmdominio := 'MOTVREGLZCREPVD';
      END IF;
      
      FOR rw_motivos IN cr_motivos(vr_nmdominio) LOOP
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inf',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cddominio',
                               pr_tag_cont => rw_motivos.cddominio,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmdominio',
                               pr_tag_cont => rw_motivos.nmdominio,
                               pr_des_erro => vr_dscritic);
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dscodigo',
                               pr_tag_cont => rw_motivos.dscodigo,
                               pr_des_erro => vr_dscritic);
      
        vr_contador := vr_contador + 1;
      
      END LOOP;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  
  END pc_busca_motivos_regularizar;
  
  PROCEDURE pc_cancela_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                    ,pr_cdmotivo IN tbcc_portabilidade_envia.cdmotivo%TYPE --> Motivo do cancelamento
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_cancela_portabilidade
    Sistema : Ayllos Web
    Autor   : Andre Clemer (Supero)
    Data    : Outubro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para cancelar portabilidade.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Buscar o motivo
      CURSOR cr_motivo(pr_cdmotivo IN tbcc_dominio_campo.cddominio%TYPE) IS
        SELECT cddominio
              ,nmdominio
              ,dscodigo
          FROM tbcc_dominio_campo
         WHERE nmdominio = 'MOTVCANCELTPORTDDCTSALR'
           AND cddominio = to_char(pr_cdmotivo);
    
      rw_motivo cr_motivo%ROWTYPE;
    
      -- Seleciona Portab Envia
      CURSOR cr_portab_envia(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT dsdrowid
              ,situacao
              ,cdsituacao
              ,motivo
              ,cdmotivo
              ,to_char(dtsolicitacao, 'DD/MM/RRRR HH24:MI:SS') dtsolicitacao
              ,to_char(dtretorno, 'DD/MM/RRRR HH24:MI:SS') dtretorno
              ,to_char(nrnu_portabilidade) nrnu_portabilidade
              ,cdbanco_folha
              ,nrispb_banco_folha
              ,nrcnpj_banco_folha
          FROM (SELECT dom.dscodigo           AS situacao
                      ,dom.cddominio          AS cdsituacao
                      ,dcp.dscodigo           AS motivo
                      ,dcp.cddominio          AS cdmotivo
                      ,tpe.dtsolicitacao      AS dtsolicitacao
                      ,tpe.dtretorno
                      ,tpe.nrnu_portabilidade
                      ,tpe.cdbanco_folha
                      ,tpe.nrispb_banco_folha
                      ,tpe.nrcnpj_banco_folha
                      ,tpe.rowid              dsdrowid
                  FROM tbcc_portabilidade_envia tpe
                      ,tbcc_dominio_campo       dom
                      ,tbcc_dominio_campo       dcp
                 WHERE tpe.idsituacao = dom.cddominio
                   AND dom.nmdominio = 'SIT_PORTAB_SALARIO_ENVIA'
                   AND dcp.nmdominio(+) = tpe.dsdominio_motivo
                   AND dcp.cddominio(+) = to_char(tpe.cdmotivo)
                   AND nrdconta = pr_nrdconta
                   AND cdcooper = pr_cdcooper
                 ORDER BY tpe.dtsolicitacao DESC)
         WHERE rownum = 1;
      rw_portab_envia cr_portab_envia%ROWTYPE;
    
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      pr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
    
      -- Variaveis locais
      vr_situacao tbcc_dominio_campo.cddominio%TYPE;
      vr_motivo   tbcc_dominio_campo.dscodigo%TYPE;
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => pr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Busca dados da instituicao financeira destinataria
      OPEN cr_portab_envia(vr_cdcooper, pr_nrdconta);
      FETCH cr_portab_envia
        INTO rw_portab_envia;
			CLOSE cr_portab_envia;
    
		  -- Solicitada
      IF rw_portab_envia.cdsituacao = 2 THEN        
        vr_situacao := 5; -- A cancelar
      ELSE 
        vr_situacao := 7; -- Cancelada
      END IF;
    
      OPEN cr_motivo(pr_cdmotivo);
      FETCH cr_motivo
        INTO rw_motivo;
    
      IF cr_motivo%NOTFOUND THEN
				CLOSE cr_motivo;
        vr_dscritic := 'Erro ao buscar motivo de cancelamento: ' || SQLERRM;
        RAISE vr_exc_erro;
      END IF;
			CLOSE cr_motivo;
    
      vr_motivo := rw_motivo.dscodigo;
    
      BEGIN
        UPDATE tbcc_portabilidade_envia
           SET idsituacao       = vr_situacao
              ,cdmotivo         = pr_cdmotivo
              ,dsdominio_motivo = 'MOTVCANCELTPORTDDCTSALR'
         WHERE ROWID = rw_portab_envia.dsdrowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao cancelar portabilidade: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    
      -- Efetua os inserts para apresentacao na tela VERLOG
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => ' ',
                           pr_dsorigem => '',
                           pr_dstransa => 'Cancelamento de Portabilidade de Salario',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                           pr_idseqttl => 1,
                           pr_nmdatela => ' ',
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);
    
      -- Gera o log para o NU Portabilidade
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'NU Portabilidade',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_portab_envia.nrnu_portabilidade);
      -- Gera o log para o Motivo Portabilidade
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Motivo',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => vr_motivo);
             
      -- Gravar os dados                   
      COMMIT;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                       
        ROLLBACK;
    END;
  
  END pc_cancela_portabilidade;

  PROCEDURE pc_imprimir_termo_portab(pr_dsrowid  IN VARCHAR2 --> Rowid da tabela
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS
    /* .............................................................................
    
    Programa: pc_imprimir_termo_portab
    Sistema : Ayllos Web
    Autor   : Augusto (Supero)
    Data    : Outubro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para retornar os dados para o termo de portabilidade
    
    Alteracoes: Rotina pc_efetua_copia_pdf foi alterado por Gilberto - Março/2019
    ..............................................................................*/
  
    -- Cria o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto VARCHAR2(10);
    
    -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      pr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_dssrvarq VARCHAR2(200);
      vr_dsdirarq VARCHAR2(200);
      vr_tab_erro gene0001.typ_tab_erro;
  
  BEGIN
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => pr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      -- Se houve retorno de erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
      END IF;
      ---- Alteração gilberto 07/03/2019
      PCPS0001.pc_gerar_termo_portab(pr_dsrowid  => pr_dsrowid
                                          ,pr_cdcooper => vr_cdcooper
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_dssrvarq => vr_dssrvarq
                                    ,pr_dsdirarq => vr_dsdirarq);
                                       
      -- Se houve retorno de erro
      IF nvl(vr_cdcritic, 0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    -- copia contrato pdf do diretorio da cooperativa para servidor web
    gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper,
                                 pr_cdagenci => NULL,
                                 pr_nrdcaixa => NULL,
                                   pr_nmarqpdf => vr_dsdirarq || vr_dssrvarq,
                                 pr_des_reto => vr_des_reto,
                                 pr_tab_erro => vr_tab_erro);
  
      -- Se houve retorno de erro
      IF nvl(vr_des_reto, 'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
           vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
           vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    -- Criar XML de retorno
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
                                   vr_dssrvarq || '</nmarqpdf>'); 
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_ATENDA_PORTAB.pc_imprimir_termo_portab: ' || SQLERRM;
      ROLLBACK;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_imprimir_termo_portab;

PROCEDURE pc_imprimir_termo_conta(pr_cdcooper IN crapenc.cdcooper%TYPE --> Numero da cooperativa
          	      ,pr_nrdconta IN crapenc.nrdconta%TYPE --> Numero da conta
									,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                  ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                  ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                  ,pr_des_erro OUT VARCHAR2) IS
    /* .............................................................................
    
    Programa: pc_imprimir_termo_conta
    Sistema : Ayllos Web
    Autor   : Lucas Schneider (Supero)
    Data    : Janeiro/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para retornar os dados para o termo de abertura de conta salário
    
    Alteracoes:
    ..............................................................................*/
  
    -- Cria o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_tab_erro gene0001.typ_tab_erro;
    vr_des_reto VARCHAR2(10);
  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
  
    -- Variaveis
    vr_xml_temp    VARCHAR2(32726) := '';
    vr_clob        CLOB;
	
    vr_nrcpfcgc_cop   VARCHAR2(200);
    vr_nrcpfcgc_ass   VARCHAR2(200);	
    vr_nrcpfcgc_resp   VARCHAR2(200); 
    vr_nrcpfcgc_emp   VARCHAR2(200);
	  vr_ds_responsavel VARCHAR2(10000) := ''; 
    nr_clausula_empregador number(1) := 2;
    nr_clausula_conta number(1) := 3;
    nr_clausula_pa number(1) := 4;
    
  
    vr_nom_direto VARCHAR2(200); --> Diretório para gravação do arquivo
    vr_dsjasper   VARCHAR2(100); --> nome do jasper a ser usado
    vr_nmarqim    VARCHAR2(50); --> nome do arquivo PDF
  
	  	  
	  -- Selecionar dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapenc.cdcooper%TYPE) IS
        SELECT crapcop.nmextcop as nmextcop
              ,crapcop.nmrescop as nmrescop
              ,crapcop.nrdocnpj as nrdocnpj
              ,crapcop.nmcidade as nmcidade
              ,crapcop.dsendcop as dsendcop
              ,crapcop.cdufdcop as cdufdcop
              ,crapcop.nrcepend as nrcepend
              ,crapcop.dsendweb as dsendweb
              ,crapcop.nrtelura as nrtelura
              ,crapcop.nrtelouv as nrtelouv
              ,crapcop.nmcidade||', '||to_char(to_date(SYSDATE),'dd" de "FMMonth" de "YYYY','nls_date_language=portuguese') as dataextenso
          FROM crapcop 
         WHERE crapcop.cdcooper = pr_cdcooper;		   
      rw_crapcop cr_crapcop%ROWTYPE;
	  
	  -- Selecionar dados do cooperado
	  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
					   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrdconta as nrdconta
            ,crapass.cdcooper as cdcooper
            ,crapass.nmprimtl as nmprimtl
            ,crapass.nrcpfcgc as nrcpfcgc
            ,crapnac.dsnacion as dsnacion
            ,gnetcvl.dsestcvl as dsestcvl
            ,tbcadast_pessoa_fisica_resp.idpessoa_resp_legal
            ,crapage.nmextage as nmextage
            ,crapenc.dsendere as dsendere
            ,crapenc.nrendere as nrendere
            ,crapenc.nmbairro as nmbairro
            ,crapenc.nmcidade as nmcidade
            ,crapenc.cdufende as cdufende
            ,crapenc.nrcepend as nrcepend
          FROM crapass
            ,crapenc
            ,crapage
            ,tbcadast_pessoa
            ,tbcadast_pessoa_fisica
            ,tbcadast_pessoa_fisica_resp
            ,crapnac
            ,gnetcvl
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta
           AND crapenc.cdcooper = crapass.cdcooper
           AND crapenc.nrdconta = crapass.nrdconta
           AND crapenc.idseqttl = 1
           AND crapenc.tpendass = 10
           AND crapage.cdcooper = crapass.cdcooper
           AND crapage.cdagenci = crapass.cdagenci
           AND tbcadast_pessoa.nrcpfcgc = crapass.nrcpfcgc
           AND tbcadast_pessoa_fisica_resp.idpessoa(+) = tbcadast_pessoa.idpessoa
           AND tbcadast_pessoa.idpessoa = tbcadast_pessoa_fisica.idpessoa
           AND crapnac.cdnacion = tbcadast_pessoa_fisica.cdnacionalidade
           AND gnetcvl.cdestcvl = tbcadast_pessoa_fisica.cdestado_civil;		   
          rw_crapass cr_crapass%ROWTYPE;
      	   
	  -- Selecionar dados do responsável do cooperado
      CURSOR cr_crapass_resp(pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE) IS      
          SELECT tbcadast_pessoa.nmpessoa as nmpessoa
            ,tbcadast_pessoa.nrcpfcgc as nrcpfcgc
            ,crapnac.dsnacion as dsnacion
            ,gnetcvl.dsestcvl as dsestcvl    
            ,tbcadast_pessoa_endereco.nmlogradouro as nmlogradouro
            ,tbcadast_pessoa_endereco.nrlogradouro as nrlogradouro
            ,tbcadast_pessoa_endereco.nmbairro as nmbairro
            ,crapmun.dscidade as dscidade
            ,crapmun.cdestado as cdestado
            ,tbcadast_pessoa_endereco.nrcep as nrcep
          FROM  tbcadast_pessoa
            ,tbcadast_pessoa_fisica
            ,tbcadast_pessoa_endereco
            ,crapnac
            ,gnetcvl
            ,crapmun
         WHERE tbcadast_pessoa.idpessoa = pr_idpessoa
          AND tbcadast_pessoa.idpessoa = tbcadast_pessoa_fisica.idpessoa
          AND tbcadast_pessoa_endereco.idcidade = crapmun.idcidade
          AND tbcadast_pessoa_endereco.idpessoa = tbcadast_pessoa_fisica.idpessoa
          AND tbcadast_pessoa_endereco.tpendereco = 10
          AND tbcadast_pessoa_endereco.nrseq_endereco = 1      
          AND crapnac.cdnacion = tbcadast_pessoa_fisica.cdnacionalidade
          AND gnetcvl.cdestcvl = tbcadast_pessoa_fisica.cdestado_civil;
          rw_crapass_resp cr_crapass_resp%ROWTYPE; 
	   	    
	  -- Selecionar dados da empresa do cooperado
      CURSOR cr_crapttl(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
          SELECT crapttl.nmextemp as nmextemp,
                 crapttl.nrcpfemp as nrcpfemp,
                 crapemp.dsendemp as dsendemp,
                 crapemp.nrcepend as nrcepend,
                 UPPER(crapemp.nmcidade) as nmcidade,
                 crapemp.nrendemp as nrendemp
            FROM crapttl, crapemp
           WHERE crapttl.cdcooper = pr_cdcooper
             AND crapttl.nrdconta = pr_nrdconta
             AND crapttl.idseqttl = 1
             AND crapttl.cdcooper = crapemp.cdcooper
             AND crapemp.cdempres = crapttl.cdempres;
          rw_crapttl cr_crapttl%ROWTYPE;
  
  BEGIN
    -- Extrai os dados vindos do XML
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
  
    -- Abre o cursor de data
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
  
    -- Abre o cursor com os dados da cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
  
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'Cooperativa nao encontrada.';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcop;
	
	-- Abre o cursor com os dados do cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
					pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass; 
	  
	  IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Cooperado nao encontrado.';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapass;
    
    IF (rw_crapass.idpessoa_resp_legal IS NOT NULL) THEN
      -- Abre o cursor com os dados do responsável legal do cooperado
      OPEN cr_crapass_resp(pr_idpessoa => rw_crapass.idpessoa_resp_legal);
      FETCH cr_crapass_resp
        INTO rw_crapass_resp;
  		
      IF cr_crapass_resp%NOTFOUND THEN
          CLOSE cr_crapass_resp;  
      ELSE         
          nr_clausula_empregador := 3;
          nr_clausula_conta := 4;
          nr_clausula_pa := 5;     	 		
          vr_ds_responsavel := '1.2. RESPONSÁVEL LEGAL: ' || nvl(trim(rw_crapass_resp.nmpessoa), '') || ', ' ||
                 nvl(trim(rw_crapass_resp.dsnacion), '') || ', ' || nvl(trim(rw_crapass_resp.dsestcvl), '') || 
                 ', inscrito(a) no CPF sob nº ' || vr_nrcpfcgc_resp || ', ' ||
                 'com residência na Rua ' || nvl(trim(rw_crapass_resp.nmlogradouro), '') || 
                 ', nº ' || nvl(trim(rw_crapass_resp.nrlogradouro), '') || 
                 ', bairro ' || nvl(trim(rw_crapass_resp.nmbairro), '') || 
                 ', cidade de ' || nvl(trim(rw_crapass_resp.dscidade), '') || '/' || 
                 nvl(trim(rw_crapass_resp.cdestado), '') || ', CEP ' || gene0002.fn_mask_cep(rw_crapass_resp.nrcep); 		
      END IF;
      CLOSE cr_crapass_resp;    
    END IF;

    -- Abre o cursor com os dados da empresa empregadora do cooperado
    OPEN cr_crapttl(pr_cdcooper => pr_cdcooper,
					pr_nrdconta => pr_nrdconta);
    FETCH cr_crapttl
      INTO rw_crapttl;   
    CLOSE cr_crapttl;

    vr_nrcpfcgc_cop := gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj, 2);
    vr_nrcpfcgc_ass := gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc, 1);
    vr_nrcpfcgc_resp := gene0002.fn_mask_cpf_cnpj(rw_crapass_resp.nrcpfcgc, 1);
    vr_nrcpfcgc_emp := gene0002.fn_mask_cpf_cnpj(rw_crapttl.nrcpfemp, 2);

    --busca diretorio padrao da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => 'rl');
  
    -- Monta documento XML de Dados
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
  
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><protocolo>');
    		
		gene0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '<cop_nmextcop>' || rw_crapcop.nmextcop || '</cop_nmextcop>' ||
												 '<cop_nmrescop>' || rw_crapcop.nmrescop || '</cop_nmrescop>' ||
                         '<cop_nrdocnpj>' || vr_nrcpfcgc_cop ||'</cop_nrdocnpj>' || 
												 '<cop_nmcidade>' || rw_crapcop.nmcidade ||'</cop_nmcidade>' || 
												 '<cop_dsendcop>' || rw_crapcop.dsendcop ||'</cop_dsendcop>' || 
												 '<cop_cdufdcop>' || rw_crapcop.cdufdcop ||'</cop_cdufdcop>' || 
												 '<cop_nrcepend>' || gene0002.fn_mask_cep(rw_crapcop.nrcepend) ||'</cop_nrcepend>' || 
												 '<cop_dsendweb>' || rw_crapcop.dsendweb ||'</cop_dsendweb>' || 
												 '<cop_dataextenso>' || rw_crapcop.dataextenso ||'</cop_dataextenso>' || 
												 '<cop_nrtelura>' || nvl(trim(rw_crapcop.nrtelura), ' ') ||'</cop_nrtelura>' || 
												 '<cop_nrtelouv>' || nvl(trim(rw_crapcop.nrtelouv), ' ') ||'</cop_nrtelouv>' ||  												 
												 '<tit_nrdconta>' || gene0002.fn_mask_conta(rw_crapass.nrdconta) ||'</tit_nrdconta>' ||  
												 '<tit_nmprimtl>' || nvl(trim(rw_crapass.nmprimtl), ' ') ||'</tit_nmprimtl>' ||  
												 '<tit_nrcpfcgc>' || vr_nrcpfcgc_ass ||'</tit_nrcpfcgc>' ||  
												 '<tit_xxx_dsnacion>' || nvl(trim(rw_crapass.dsnacion), ' ') ||'</tit_xxx_dsnacion>' ||  
												 '<tit_xxx_dsregcas>' || nvl(trim(rw_crapass.dsestcvl), ' ') ||'</tit_xxx_dsregcas>' ||  
												 '<tit_dsendere>' || nvl(trim(rw_crapass.dsendere), ' ') ||'</tit_dsendere>' ||  
												 '<tit_nrendere>' || nvl(trim(rw_crapass.nrendere), ' ') ||'</tit_nrendere>' ||  
												 '<tit_nmbairro>' || nvl(trim(rw_crapass.nmbairro), ' ') ||'</tit_nmbairro>' ||  
												 '<tit_nmcidade>' || nvl(trim(rw_crapass.nmcidade), ' ') ||'</tit_nmcidade>' ||  
                         '<tit_cdufende>' || nvl(trim(rw_crapass.cdufende), ' ') ||'</tit_cdufende>' ||  
                         '<tit_nrcepend>' || gene0002.fn_mask_cep(rw_crapass.nrcepend) ||'</tit_nrcepend>' ||  
                         '<tit_nmresage>' || rw_crapass.nmextage ||'</tit_nmresage>' ||                          
                         '<ds_responsavel>' || vr_ds_responsavel ||'</ds_responsavel>' ||                            
                         '<emp_nmextemp>' || nvl(trim(rw_crapttl.nmextemp), ' ') ||'</emp_nmextemp>' ||  
                         '<emp_nrcpfemp>' || vr_nrcpfcgc_emp ||'</emp_nrcpfemp>' ||  
                         '<emp_dsendere>' || nvl(trim(rw_crapttl.dsendemp), ' ') || ', nº ' || nvl(trim(rw_crapttl.nrendemp), '') ||'</emp_dsendere>' ||
                         '<emp_nrcepend>' || gene0002.fn_mask_cep(rw_crapttl.nrcepend) ||'</emp_nrcepend>' ||
                         '<emp_nmcidade>' || nvl(trim(rw_crapttl.nmcidade), ' ') ||'</emp_nmcidade>'||
                         '<nr_clausula_empregador>' || nr_clausula_empregador || '</nr_clausula_empregador>' ||
                         '<nr_clausula_conta>' || nr_clausula_conta || '</nr_clausula_conta>' ||
                         '<nr_clausula_pa>' || nr_clausula_pa || '</nr_clausula_pa>'
                         );
  
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '</protocolo>',
                            pr_fecha_xml      => TRUE);
  
    vr_dsjasper := 'termo_abertura_conta_salario.jasper';
    vr_nmarqim  := '/TermoAberturaContaSalario' || to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '.pdf';
  
    -- Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper,
                                pr_cdprogra  => 'ATENDA',
                                pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                                pr_dsxml     => vr_clob,
                                pr_dsxmlnode => '/protocolo',
                                pr_dsjasper  => vr_dsjasper,
                                pr_dsparams  => NULL,
                                pr_dsarqsaid => vr_nom_direto || vr_nmarqim,
                                pr_cdrelato  => 740,
                                pr_flg_gerar => 'S',
                                pr_qtcoluna  => 80,
                                pr_sqcabrel  => 1,
                                pr_flg_impri => 'N',
                                pr_nmformul  => ' ',
                                pr_nrcopias  => 1,
                                pr_parser    => 'R',
                                pr_nrvergrl  => 1,
                                pr_des_erro  => vr_dscritic);
  
    -- copia contrato pdf do diretorio da cooperativa para servidor web
    gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper,
                                 pr_cdagenci => NULL,
                                 pr_nrdcaixa => NULL,
                                 pr_nmarqpdf => vr_nom_direto || vr_nmarqim,
                                 pr_des_reto => vr_des_reto,
                                 pr_tab_erro => vr_tab_erro);
  
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);
  
    -- Criar XML de retorno
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
                                   vr_nmarqim || '</nmarqpdf>');
  
    COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_imprimir_termo_conta: ' || SQLERRM;
      ROLLBACK;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_imprimir_termo_conta;
  
  PROCEDURE pc_contesta_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                     ,pr_cdmotivo IN tbcc_portab_env_contestacao.cdmotivo%TYPE --> Motivo do cancelamento
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_contesta_portabilidade
    Sistema : Ayllos Web
    Autor   : Andrey Formigari (Supero)
    Data    : Janeiro/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para contestar a portabilidade.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Seleciona Portab Envia
      CURSOR cr_portab_envia(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT t.*
          FROM (SELECT *
                  FROM tbcc_portabilidade_envia
                 WHERE nrdconta = pr_nrdconta
                   AND cdcooper = pr_cdcooper
                 ORDER BY dtsolicitacao DESC) t 
          WHERE rownum = 1;
      rw_portab_envia cr_portab_envia%ROWTYPE;
      
      -- Gera Numero Contestacao
      CURSOR cr_gera_nrcontestacao(pr_cdcooper      IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE
                                  ,pr_nrsolicitacao IN tbcc_portab_env_contestacao.nrsolicitacao%TYPE) IS
        SELECT COUNT(1) + 1 AS nrcontestacao
          FROM tbcc_portab_env_contestacao t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.nrsolicitacao = pr_nrsolicitacao;
       rw_gera_nrcontestacao cr_gera_nrcontestacao%ROWTYPE;
    
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      pr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
    
      -- Variaveis locais
      vr_situacao tbcc_dominio_campo.cddominio%TYPE;
      vr_motivo   tbcc_dominio_campo.dscodigo%TYPE;
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => pr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Busca dados da instituicao financeira destinataria
      OPEN cr_portab_envia(vr_cdcooper, pr_nrdconta);
      FETCH cr_portab_envia
      INTO rw_portab_envia;
	  CLOSE cr_portab_envia;
    
      IF rw_portab_envia.idsituacao <> 3 THEN
         vr_dscritic := 'Situação da portabilidade não está aprovada.';
         RAISE vr_exc_erro;
      END IF;
      
      OPEN cr_gera_nrcontestacao(vr_cdcooper
                                ,pr_nrdconta
                                ,rw_portab_envia.nrsolicitacao);
      FETCH cr_gera_nrcontestacao INTO rw_gera_nrcontestacao;
      CLOSE cr_gera_nrcontestacao;
    
      BEGIN
          INSERT INTO tbcc_portab_env_contestacao 
                 (cdcooper, 
                  nrdconta, 
                  nrsolicitacao, 
                  nrcontestacao, 
                  dtcontestacao, 
                  dsdominio_motivo, 
                  cdmotivo, 
                  idsituacao, 
                  cdoperador) 
          VALUES (vr_cdcooper, -- cdcooper
                  pr_nrdconta, -- nrdconta
                  rw_portab_envia.nrsolicitacao, -- nrsolicitacao
                  rw_gera_nrcontestacao.nrcontestacao, -- generate nrcontestacao
                  SYSDATE, -- data de criacao
                  'MOTVCONTTC', -- chave do motivo
                  pr_cdmotivo, -- codigo do motivo
                  1, -- situacao da portabilidade (1 = enviado)
                  vr_cdoperad); -- codigo do operador
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao contestar a portabilidade: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    
      -- Efetua os inserts para apresentacao na tela VERLOG
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => ' ',
                           pr_dsorigem => '',
                           pr_dstransa => 'Contestação de Portabilidade',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                           pr_idseqttl => 1,
                           pr_nmdatela => ' ',
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);
    
      -- Gera o log para o NU Portabilidade
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'NU Portabilidade',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_portab_envia.nrnu_portabilidade);
      -- Gera o log para o Motivo Portabilidade
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Motivo',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => vr_motivo);
             
      -- Gravar os dados                   
      COMMIT;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                       
        ROLLBACK;
    END;
  
  END pc_contesta_portabilidade;
  
  PROCEDURE pc_responde_contestacao(pr_dsrowid  IN VARCHAR2
                                   ,pr_cdmotivo IN tbcc_portab_rec_contestacao.cdmotivo%TYPE --> Motivo da resposta
                                   ,pr_idstatus IN tbcc_portab_rec_contestacao.idsituacao%TYPE --> Status da Situação 
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_responde_contestacao
    Sistema : Ayllos Web
    Autor   : Andrey Formigari (Supero)
    Data    : Janeiro/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para responder uma contestacao recebida
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Seleciona Portab Recebe
      CURSOR cr_portab_recebe(pr_dsrowid VARCHAR2) IS
          SELECT nrnu_portabilidade, nrdconta
            FROM tbcc_portabilidade_recebe
           WHERE rowid = pr_dsrowid;
      rw_portab_recebe cr_portab_recebe%ROWTYPE;
    
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      pr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
    
      -- Variaveis locais
      vr_situacao tbcc_dominio_campo.cddominio%TYPE;
      vr_motivo   tbcc_dominio_campo.dscodigo%TYPE;
      vr_nmdominio tbcc_dominio_campo.nmdominio%TYPE; 
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => pr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Busca dados da instituicao financeira destinataria
      OPEN cr_portab_recebe(pr_dsrowid);
      FETCH cr_portab_recebe INTO rw_portab_recebe;
	    CLOSE cr_portab_recebe;
    
      /*IF rw_portab_envia.idsituacao <> 3 THEN
         vr_dscritic := 'Situação da portabilidade não está aprovada.';
         RAISE vr_exc_erro;
      END IF;*/
      
      IF pr_idstatus = '2' THEN
         vr_nmdominio := 'MOTVRESPCONTTCAPROVD';
      ELSIF pr_idstatus = '3' THEN
         vr_nmdominio := 'MOTVRESPCONTTCREPVD';
      END IF;
    
      BEGIN
          UPDATE tbcc_portab_rec_contestacao t
             SET t.idsituacao = pr_idstatus,
                 t.dsdominio_motivo_retorno = vr_nmdominio,
                 t.cdmotivo_retorno = pr_cdmotivo,
                 t.cdoperador = vr_cdoperad
           WHERE t.nrnu_portabilidade = rw_portab_recebe.nrnu_portabilidade;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao contestar a portabilidade: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    
      -- Efetua os inserts para apresentacao na tela VERLOG
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => ' ',
                           pr_dsorigem => '',
                           pr_dstransa => 'Responde Contestação',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                           pr_idseqttl => 1,
                           pr_nmdatela => ' ',
                           pr_nrdconta => rw_portab_recebe.nrdconta,
                           pr_nrdrowid => vr_nrdrowid);
    
      -- Gera o log para o NU Portabilidade
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Status da Resposta',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => pr_idstatus);
                                
      -- Gera o log para o Motivo Portabilidade
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Motivo',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => vr_motivo);
             
      -- Gravar os dados                   
      COMMIT;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                       
        ROLLBACK;
    END;
  
  END pc_responde_contestacao;
  
  PROCEDURE pc_regulariza_portabilidade(pr_cdmotivo IN tbcc_portab_regularizacao.cdmotivo%TYPE --> Motivo da regularização
                                       ,pr_dsrowid  IN VARCHAR2 --> registro selecionado
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_regulariza_portabilidade
    Sistema : Ayllos Web
    Autor   : Andrey Formigari (Supero)
    Data    : Janeiro/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para regularizar uma portabilidade
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Seleciona Portab Recebe
      CURSOR cr_portab_recebe(pr_dsrowid VARCHAR2) IS
          SELECT nrnu_portabilidade, idsituacao, nrdconta
            FROM tbcc_portabilidade_recebe
           WHERE rowid = pr_dsrowid;
      rw_portab_recebe cr_portab_recebe%ROWTYPE;
      
      CURSOR cr_sequencial_nrregularizacao(pr_nrnu_portabilidade tbcc_portab_regularizacao.nrnu_portabilidade%TYPE) IS
          SELECT COUNT(1) + 1 AS nrregularizacao
            FROM tbcc_portab_regularizacao
           WHERE to_char(nrnu_portabilidade) = to_char(pr_nrnu_portabilidade);
      rw_sequencial_nrregularizacao cr_sequencial_nrregularizacao%ROWTYPE;
    
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      pr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
    
      -- Variaveis locais
      vr_idaprrep  tbcc_portab_regularizacao.idaprova_reprova%TYPE;
      vr_nmdominio tbcc_dominio_campo.nmdominio%TYPE; 
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => pr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Busca dados da portabilidade
      OPEN cr_portab_recebe(pr_dsrowid);
      FETCH cr_portab_recebe INTO rw_portab_recebe;
	    CLOSE cr_portab_recebe;
      
      -- busca nr sequencial para regularizacao
      OPEN cr_sequencial_nrregularizacao(rw_portab_recebe.nrnu_portabilidade);
      FETCH cr_sequencial_nrregularizacao INTO rw_sequencial_nrregularizacao;
	    CLOSE cr_sequencial_nrregularizacao;
      
      IF rw_portab_recebe.idsituacao = 3 THEN
         vr_nmdominio   := 'MOTVREGLZCAPROVD';
         vr_idaprrep    := 1;
      ELSIF rw_portab_recebe.idsituacao = 2 THEN
         vr_nmdominio   := 'MOTVREGLZCREPVD';
         vr_idaprrep    := 2;
      END IF;
    
      BEGIN
          INSERT INTO tbcc_portab_regularizacao
              (NRNU_PORTABILIDADE
              ,NRREGULARIZACAO
              ,IDSITUACAO
              ,IDAPROVA_REPROVA
              ,DTREGULARIZACAO
              ,DSDOMINIO_MOTIVO
              ,CDMOTIVO
              ,CDOPERADOR)
          VALUES
              (rw_portab_recebe.nrnu_portabilidade
              ,rw_sequencial_nrregularizacao.nrregularizacao
              ,1
              ,vr_idaprrep
              ,SYSDATE
              ,vr_nmdominio
              ,pr_cdmotivo
              ,vr_cdoperad);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao contestar a portabilidade: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    
      -- Efetua os inserts para apresentacao na tela VERLOG
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => ' ',
                           pr_dsorigem => '',
                           pr_dstransa => 'Regulariza Portabilidade',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                           pr_idseqttl => 1,
                           pr_nmdatela => ' ',
                           pr_nrdconta => rw_portab_recebe.nrdconta,
                           pr_nrdrowid => vr_nrdrowid);
                                
      -- Gera o log para o Motivo Portabilidade
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Motivo',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => pr_cdmotivo);
             
      -- Gravar os dados                   
      COMMIT;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                       
        ROLLBACK;
    END;
  
  END pc_regulariza_portabilidade;


END TELA_ATENDA_PORTAB;
/
