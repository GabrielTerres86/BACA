CREATE OR REPLACE PACKAGE CECRED.TELA_TAB089 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB089
  --  Sistema  : Rotinas utilizadas pela Tela TAB089
  --  Sigla    : EMPR
  --  Autor    : Guilherme/AMcom
  --  Data     : Janeiro/2018                 Ultima atualizacao: 14/09/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TAB089
  --
  -- Alteracoes:  12/01/2018 - Conversão Ayllos Web (Guilherme/AMcom)
  --              10/07/2018 - PJ 438 - Agilidade nas Contratações de Crédito - Márcio (Mouts)  
  --              31/07/2018 - Inclusão de campo de taxa de juros remuneratório de prejuízo (pctaxpre)
  --                           PRJ 450 - Diego Simas (AMcom)
  --              31/07/2018 - Inclusão do campo Prazo p/ transferência de valor da conta transitória para a CC	
  --                           PRJ 450 - Diego Simas (AMcom)
  --			  14/09/2018 - Adicionado parametro valor max de estorno para desconto de titulo - Cássia de Oliveira (GFT)
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------



  ---------------------------------- ROTINAS --------------------------------
  PROCEDURE pc_consultar(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_alterar( pr_prtlmult  IN INTEGER
                       ,pr_prestorn  IN INTEGER
                       ,pr_prpropos  IN VARCHAR
                       ,pr_vlempres  IN NUMBER
                       ,pr_pzmaxepr  IN INTEGER
                       ,pr_vlmaxest  IN NUMBER
                       -- Novos Campos
                       ,pr_pcaltpar  IN NUMBER -- Alteração de parcela - PORCENTAGEM
                       ,pr_vltolemp  IN NUMBER -- Tolerância por valor de empréstimo - REAIS
                       -- PROPOSTAS PA - Prazo de validade da análise para efetivação 
                       ,pr_qtdpaimo  IN INTEGER -- Imovel - Quantidade Dias PA Imovel
                       ,pr_qtdpaaut  IN INTEGER -- Automovel - Quantidade Dias PA Automovel
                       ,pr_qtdpaava  IN INTEGER -- Aval - Quantidade Dias PA Aval
                       ,pr_qtdpaapl  IN INTEGER -- Aplicacao - Quantidade Dias PA Aplicacao
                       ,pr_qtdpasem  IN INTEGER -- Sem Garantia - Quantidade Dias PA Sem Garantia
                       ,pr_qtdpameq  IN INTEGER -- PJ438 - Márcio (Mouts) 
                        -- PROPOSTAS Mobile/IB/TAA - Prazo de validade da análise para efetivação 
                       ,pr_qtdibaut  IN INTEGER -- Automovel
                       ,pr_qtdibapl  IN INTEGER -- Aplicacao
                       ,pr_qtdibsem  IN INTEGER -- Sem Garantia
                       -- Títulos - Prazo de validade da análise para efetivação
                       ,pr_qtditava  IN INTEGER -- Avalista -- PJ438 - Márcio (Mouts) 
                       ,pr_qtditapl  IN INTEGER -- Aplicacao -- PJ438 - Márcio (Mouts) 
                       ,pr_qtditsem  IN INTEGER -- Sem Garantia -- PJ438 - Márcio (Mouts) 
                       -- Prejuízo
                       ,pr_pctaxpre  IN NUMBER  -- Taxa de juros remuneratório de prejuízo - PORCENTAGEM
                       ,pr_qtdictcc  IN INTEGER -- Quantidade de dias para Transferência de valor da conta transitória para a CC
                                             
                       -- Prj438 -Sprint5
                       ,pr_avtperda  IN NUMBER  -- Alteração em Avalista perde aprovação - PRJ438 - Paulo (Mouts)
                       ,pr_vlperavt  IN NUMBER  -- Valor para perda de aprovação referente ao Avalista - PRJ438 - Paulo (Mouts)                       
                       ,pr_vlmaxdst  IN NUMBER  -- Valor maximo de estorno par desconto de titulo 
                       ,pr_xmllog      IN VARCHAR2  --> XML com informações de LOG
                       ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro   OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_mtv_anulacao(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_insere_mtv_anulacao(pr_dsmotivo     IN tbcadast_motivo_anulacao.dsmotivo%TYPE     --> Descrição do motivo
						      								,pr_tpproduto    IN tbcadast_motivo_anulacao.tpproduto%TYPE    --> Tipo do produto
									      					,pr_inobservacao IN tbcadast_motivo_anulacao.inobservacao%TYPE --> Exige observacao (0-Nao/1-Sim)
      														,pr_xmllog       IN VARCHAR2                                   --> XML com informações de LOG
			      											,pr_cdcritic     OUT PLS_INTEGER                               --> Código da crítica
						      								,pr_dscritic     OUT VARCHAR2                                  --> Descrição da crítica
									      					,pr_retxml       IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
      														,pr_nmdcampo     OUT VARCHAR2                                  --> Nome do Campo
			      											,pr_des_erro     OUT VARCHAR2);                                --> Saida OK/NOK

  PROCEDURE pc_atualiza_mtv_anulacao(pr_cdmotivo     IN tbcadast_motivo_anulacao.cdmotivo%TYPE     --> Código do motivo
  						      								,pr_tpproduto    IN tbcadast_motivo_anulacao.tpproduto%TYPE    --> Tipo do produto
                                    ,pr_dsmotivo     IN tbcadast_motivo_anulacao.dsmotivo%TYPE     --> Descrição do motivo
  									      					,pr_inobservacao IN tbcadast_motivo_anulacao.inobservacao%TYPE --> Exige observacao (0-Nao/1-Sim)
                                    ,pr_idativo      IN tbcadast_motivo_anulacao.idativo%TYPE      --> Identificador de ativa (0-nao / 1-sim)                                        
         													  ,pr_xmllog       IN VARCHAR2                                   --> XML com informações de LOG
       	 													  ,pr_cdcritic     OUT PLS_INTEGER                               --> Código da crítica
														        ,pr_dscritic     OUT VARCHAR2                                  --> Descrição da crítica
       														  ,pr_retxml       IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
			      											  ,pr_nmdcampo     OUT VARCHAR2                                  --> Nome do Campo
						      								  ,pr_des_erro     OUT VARCHAR2);                                --> Saida OK/NOK                                                   
                                    
  PROCEDURE pc_busca_email_proposta(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_insere_email_proposta(pr_tpproduto        IN tbcadast_email_proposta.tpproduto%TYPE        --> Tipo do produto
  									      					,pr_qt_periodicidade IN tbcadast_email_proposta.qt_periodicidade%TYPE --> Quantidade de dias entre cada notificacao do operador
                                    ,pr_qt_envio         IN tbcadast_email_proposta.qt_envio%TYPE         --> Quantidade de envios realizadas no dia da notificacao
  									      					,pr_ds_assunto       IN tbcadast_email_proposta.ds_assunto%TYPE       --> Descricao do Assunto do E-mail
                                    ,pr_ds_corpo         IN tbcadast_email_proposta.ds_corpo%TYPE         --> Descricao do corpo do E-mail
        														,pr_xmllog           IN VARCHAR2 --> XML com informações de LOG
			        											,pr_cdcritic         OUT PLS_INTEGER --> Código da crítica
				  		      								,pr_dscritic         OUT VARCHAR2 --> Descrição da crítica
					  				      					,pr_retxml           IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
      			  											,pr_nmdcampo         OUT VARCHAR2 --> Nome do Campo
			      	  										,pr_des_erro         OUT VARCHAR2);                                --> Saida OK/NOK

  PROCEDURE pc_atualiza_email_proposta(pr_tpproduto        IN tbcadast_email_proposta.tpproduto%TYPE        --> Tipo do produto
    									      					,pr_qt_periodicidade IN tbcadast_email_proposta.qt_periodicidade%TYPE --> Quantidade de dias entre cada notificacao do operador
                                      ,pr_qt_envio         IN tbcadast_email_proposta.qt_envio%TYPE         --> Quantidade de envios realizadas no dia da notificacao
  		  							      					,pr_ds_assunto       IN tbcadast_email_proposta.ds_assunto%TYPE       --> Descricao do Assunto do E-mail
                                      ,pr_ds_corpo         IN tbcadast_email_proposta.ds_corpo%TYPE         --> Descricao do corpo do E-mail
                                      ,pr_idativo          IN NUMBER                                     --> Identificador de ativa (0-nao / 1-sim)                                                                                                                    
           													  ,pr_xmllog           IN VARCHAR2                                   --> XML com informações de LOG
       	   													  ,pr_cdcritic         OUT PLS_INTEGER                               --> Código da crítica
					  									        ,pr_dscritic         OUT VARCHAR2                                  --> Descrição da crítica
       			  											  ,pr_retxml           IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
			      	  										  ,pr_nmdcampo         OUT VARCHAR2                                  --> Nome do Campo
						        								  ,pr_des_erro         OUT VARCHAR2);                                --> Saida OK/NOK                                                   
                                    

END TELA_TAB089;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TAB089 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB089
  --  Sistema  : Rotinas utilizadas pela Tela TAB089
  --  Sigla    : EMPR
  --  Autor    : Guilherme/AMcom
  --  Data     : Janeiro/2018                 Ultima atualizacao: 14/09/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TAB089
  --
  -- Alteracoes:  12/01/2018 - Conversão Ayllos Web (Guilherme/AMcom)
  --              10/07/2018 - PJ 438 - Agilidade nas Contratações de Crédito - Márcio (Mouts)
  --              31/07/2018 - Inclusão de campo de taxa de juros remuneratório de prejuízo (pctaxpre)
  --                           PRJ 450 - Diego Simas (AMcom) 
  --              31/07/2018 - Inclusão do campo Prazo p/ transferência de valor da conta transitória para a CC	
  --                           PRJ 450 - Diego Simas (AMcom)
  --              14/09/2018 - Adicionado parametro valor max de estorno para desconto de titulo - Cássia de Oliveira (GFT)
  --
  ---------------------------------------------------------------------------
  PROCEDURE pc_consultar(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_consultar
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Guilherme/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao: 14/09/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar Op. Taxas Pre-fixadas

        Observacao: -----

        Alteracoes: 10/07/2018 - PJ 438 - Agilidade nas Contratações de Crédito - Márcio (Mouts)        
                    31/07/2018 - Inclusão de campo de taxa de juros remuneratório de prejuízo (pctaxpre)
                                 PRJ 450 - Diego Simas (AMcom)
                    31/07/2018 - Inclusão do campo Prazo p/ transferência de valor da conta transitória para a CC	
                                 PRJ 450 - Diego Simas (AMcom) 
					14/09/2018 - Adicionado parametro valor max de estorno para desconto de titulo - Cássia de Oliveira (GFT)
             
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      
      vr_dstextab craptab.dstextab%TYPE;
      vr_dsvlrprm crapprm.dsvlrprm%TYPE;

      vr_prtlmult INTEGER :=0;
      vr_prestorn INTEGER :=0;
      vr_prpropos VARCHAR2(8);
      vr_vlempres NUMBER  :=0;
      vr_pzmaxepr INTEGER :=0;
      vr_vlmaxest NUMBER  :=0;
      vr_pcaltpar NUMBER  :=0;
      vr_vltolemp NUMBER  :=0;
      vr_qtdpaimo INTEGER :=0; 
      vr_qtdpaaut INTEGER :=0;
      vr_qtdpaava INTEGER :=0;
      vr_qtdpaapl INTEGER :=0;
      vr_qtdpasem INTEGER :=0;
      vr_qtdpameq INTEGER :=0; -- PJ438 - Márcio (Mouts)
      vr_qtdibaut INTEGER :=0;      
      vr_qtdibapl INTEGER :=0;      
      vr_qtdibsem INTEGER :=0;      
      vr_qtditava INTEGER :=0; -- PJ438 - Márcio (Mouts)
      vr_qtditapl INTEGER :=0; -- PJ438 - Márcio (Mouts)
      vr_qtditsem INTEGER :=0; -- PJ438 - Márcio (Mouts)                  
      vr_pctaxpre NUMBER  :=0;
      vr_qtdictcc NUMBER  :=0;                
      vr_avtperda NUMBER  :=0; -- PJ438 - Paulo (Mouts) Sprint 5
      vr_vlperavt NUMBER  :=0; -- PJ438 - Paulo (Mouts) Sprint 5      
	  vr_vlmaxdst NUMBER  :=0;
      
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      ---------->> CURSORES <<--------
   CURSOR cr_crapprm(vr_cdcooper IN CRAPCOP.CDCOOPER%TYPE) IS
     SELECT dsvlrprm
       FROM crapprm
      WHERE cdcooper = vr_cdcooper
        AND cdacesso = 'VL_MAX_ESTORN_DST';


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
      
      -- Buscar valor max para desc de titulo
      OPEN cr_crapprm(vr_cdcooper => vr_cdcooper);
        FETCH cr_crapprm
         INTO vr_dsvlrprm;
         CLOSE cr_crapprm;

      -- Buscar dados da TAB
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPREST'
                                               ,pr_tpregist => 01);

      --Se nao encontrou parametro
      IF TRIM(vr_dstextab) IS NULL THEN
        vr_cdcritic := 55;
        RAISE vr_exc_saida;
      ELSE
        -- EFETUA OS PROCEDIMENTOS COM O DADO RETORNADO DA CRAPTAB
        vr_prtlmult := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,3));
        vr_prestorn := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,9,3));
        vr_prpropos := SUBSTR(vr_dstextab,13,8);
        vr_vlempres := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,22,12));
        vr_pzmaxepr := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,35,4));
        vr_vlmaxest := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,40,12));
        --
        vr_pcaltpar := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,53,6)),0);
        vr_vltolemp := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,60,12)),0);
        --
        vr_qtdpaimo := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,73,3)),0);
        vr_qtdpaaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,77,3)),0);
        vr_qtdpaava := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,81,3)),0);
        vr_qtdpaapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,85,3)),0);
        vr_qtdpasem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,89,3)),0);
        --
        vr_qtdibaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,93,3)),0);
        vr_qtdibapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,97,3)),0);
        vr_qtdibsem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,101,3)),0);

        vr_qtdpameq := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,105,3)),0);  -- PJ438 - Márcio (Mouts)      

        vr_qtditava := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,109,3)),0);  -- PJ438 - Márcio (Mouts)      
        vr_qtditapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,113,3)),0);  -- PJ438 - Márcio (Mouts)      
        vr_qtditsem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,117,3)),0);  -- PJ438 - Márcio (Mouts)                              
        
        vr_pctaxpre := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,121,6)),0);
        vr_qtdictcc := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,128,3)),0);
        
        vr_avtperda := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,132,1)),0); -- PJ438 - Paulo (Mouts) Sprint 5
        vr_vlperavt := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,134,12)),0); -- PJ438 - Paulo (Mouts) Sprint 5  
        
		vr_vlmaxdst := gene0002.fn_char_para_number(vr_dsvlrprm);
      END IF;

      -- PASSA OS DADOS PARA O XML RETORNO      
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
      
      -- CAMPOS
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'prtlmult',
                             pr_tag_cont => to_char(vr_prtlmult),
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'prestorn',
                             pr_tag_cont => to_char(vr_prestorn),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'prpropos',
                             pr_tag_cont => vr_prpropos,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlempres',
                             pr_tag_cont => to_char(vr_vlempres,
                                                    '999999999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pzmaxepr',
                             pr_tag_cont => to_char(vr_pzmaxepr,
                                                    '9990',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmaxest',
                             pr_tag_cont => to_char(vr_vlmaxest,
                                                    '999999999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
                                  
      -- NOVOS (2)
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcaltpar',
                             pr_tag_cont => to_char(vr_pcaltpar,
                                                    '999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vltolemp',
                             pr_tag_cont => to_char(vr_vltolemp,
                                                    '999999999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      -- NOVOS (5)
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdpaimo',
                             pr_tag_cont => to_char(vr_qtdpaimo),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdpaaut',
                             pr_tag_cont => to_char(vr_qtdpaaut),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdpaava',
                             pr_tag_cont => to_char(vr_qtdpaava),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdpaapl',
                             pr_tag_cont => to_char(vr_qtdpaapl),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdpasem',
                             pr_tag_cont => to_char(vr_qtdpasem),
                             pr_des_erro => vr_dscritic);

      -- NOVOS (3)
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdibaut',
                             pr_tag_cont => to_char(vr_qtdibaut),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdibapl',
                             pr_tag_cont => to_char(vr_qtdibapl),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdibsem',
                             pr_tag_cont => to_char(vr_qtdibsem),
                             pr_des_erro => vr_dscritic);

      -- Início PJ438 - Márcio (Mouts)
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdpameq',
                             pr_tag_cont => to_char(vr_qtdpameq),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtditava',
                             pr_tag_cont => to_char(vr_qtditava),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtditapl',
                             pr_tag_cont => to_char(vr_qtditapl),
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtditsem',
                             pr_tag_cont => to_char(vr_qtditsem),
                             pr_des_erro => vr_dscritic);                                                          
      -- Fim PJ438 - Márcio (Mouts)
      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctaxpre',
                             pr_tag_cont => to_char(vr_pctaxpre,
                                                    '990D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);   
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdictcc',
                             pr_tag_cont => to_char(vr_qtdictcc),
                             pr_des_erro => vr_dscritic);
                                   
      --PRJ438 - Sprint 5 - Paulo (Mouts)
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'avtperda',
                             pr_tag_cont => to_char(vr_avtperda),
                             pr_des_erro => vr_dscritic);

	    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlperavt',
                             pr_tag_cont => to_char(vr_vlperavt,
                                                    '999999999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);  
     --PRJ438 - Sprint 5 - Paulo (Mouts) 
                                   
	  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmaxdst',
                             pr_tag_cont => to_char(vr_vlmaxdst,
                                                    '999999999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
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
  END pc_consultar;

  PROCEDURE pc_alterar( pr_prtlmult  IN INTEGER
                       ,pr_prestorn  IN INTEGER
                       ,pr_prpropos  IN VARCHAR
                       ,pr_vlempres  IN NUMBER
                       ,pr_pzmaxepr  IN INTEGER
                       ,pr_vlmaxest  IN NUMBER
                       -- Novos Campos
                       ,pr_pcaltpar  IN NUMBER -- Alteração de parcela - PORCENTAGEM
                       ,pr_vltolemp  IN NUMBER -- Tolerância por valor de empréstimo - REAIS
                       -- PROPOSTAS PA - Prazo de validade da análise para efetivação 
                       ,pr_qtdpaimo  IN INTEGER -- Imovel - Quantidade Dias PA Imovel
                       ,pr_qtdpaaut  IN INTEGER -- Automovel - Quantidade Dias PA Automovel
                       ,pr_qtdpaava  IN INTEGER -- Aval - Quantidade Dias PA Aval
                       ,pr_qtdpaapl  IN INTEGER -- Aplicacao - Quantidade Dias PA Aplicacao
                       ,pr_qtdpasem  IN INTEGER -- Sem Garantia - Quantidade Dias PA Sem Garantia
                       ,pr_qtdpameq  IN INTEGER -- PJ438 - Márcio (Mouts) 
                        -- PROPOSTAS Mobile/IB/TAA - Prazo de validade da análise para efetivação 
                       ,pr_qtdibaut  IN INTEGER -- Automovel
                       ,pr_qtdibapl  IN INTEGER -- Aplicacao
                       ,pr_qtdibsem  IN INTEGER -- Sem Garantia
                       -- Títulos - Prazo de validade da análise para efetivação
                       ,pr_qtditava  IN INTEGER -- Avalista -- PJ438 - Márcio (Mouts) 
                       ,pr_qtditapl  IN INTEGER -- Aplicacao -- PJ438 - Márcio (Mouts) 
                       ,pr_qtditsem  IN INTEGER -- Sem Garantia -- PJ438 - Márcio (Mouts) 
                       -- Prejuízo
                       ,pr_pctaxpre  IN NUMBER  -- Taxa de juros remuneratório de prejuízo - PORCENTAGEM
                       ,pr_qtdictcc  IN INTEGER -- Quantidade de dias para Transferência de valor da conta transitória para a CC

                       ,pr_avtperda  IN NUMBER  -- Alteração em Avalista perde aprovação - PRJ438 - Paulo (Mouts)
                       ,pr_vlperavt  IN NUMBER  -- Valor para perda de aprovação referente ao Avalista - PRJ438 - Paulo (Mouts)
                       ,pr_vlmaxdst  IN NUMBER  -- Valor maximo de estorno para desconto de titulo
                       ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Guilherme/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao: 14/09/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para alterar Op. Taxas Pre-fixadas

        Observacao: -----

        Alteracoes: 10/07/2018 - PJ 438 - Agilidade nas Contratações de Crédito - Márcio (Mouts)        
                    31/07/2018 - Inclusão de campo de taxa de juros remuneratório de prejuízo (pctaxpre)
                                 PRJ 450 - Diego Simas (AMcom)                                 
                    31/07/2018 - Inclusão do campo Prazo p/ transferência de valor da conta transitória para a CC	
                                 PRJ 450 - Diego Simas (AMcom)               
					14/09/2018 - Adicionado parametro valor max de estorno para desconto de titulo - Cássia de Oliveira (GFT)
        
    ..............................................................................*/

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_cdacesso VARCHAR2(100);

    vr_dstextab craptab.dstextab%TYPE;
    vr_dsvlrprm crapprm.dsvlrprm%TYPE;

    vr_prtlmult INTEGER :=0;
    vr_prestorn INTEGER :=0;
    vr_prpropos VARCHAR2(8);
    vr_vlempres NUMBER  :=0;
    vr_pzmaxepr INTEGER :=0;
    vr_vlmaxest NUMBER  :=0;
    vr_pcaltpar NUMBER  :=0;
    vr_vltolemp NUMBER  :=0;
    vr_qtdpaimo INTEGER :=0; 
    vr_qtdpaaut INTEGER :=0;
    vr_qtdpaava INTEGER :=0;
    vr_qtdpaapl INTEGER :=0;
    vr_qtdpasem INTEGER :=0;
    vr_qtdpameq INTEGER :=0; --PJ438 - Márcio (Mouts)
    vr_qtdibaut INTEGER :=0;      
    vr_qtdibapl INTEGER :=0;      
    vr_qtdibsem INTEGER :=0;
    vr_qtditava INTEGER :=0; --PJ438 - Márcio (Mouts)
    vr_qtditapl INTEGER :=0; --PJ438 - Márcio (Mouts)
    vr_qtditsem INTEGER :=0; --PJ438 - Márcio (Mouts)
    vr_pctaxpre NUMBER  :=0;
    vr_qtdictcc INTEGER :=0;
    vr_avtperda NUMBER  :=0; -- PJ438 - Paulo (Mouts) Sprint 5
    vr_vlperavt NUMBER  :=0; -- PJ438 - Paulo (Mouts) Sprint 5 
	vr_vlmaxdst NUMBER  :=0;
    
    ---------->> CURSORES <<--------
   CURSOR cr_crapprm(vr_cdcooper IN CRAPCOP.CDCOOPER%TYPE) IS
     SELECT dsvlrprm
       FROM crapprm
      WHERE cdcooper = vr_cdcooper
        AND cdacesso = 'VL_MAX_ESTORN_DST';

    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --------------->>> SUB-ROTINA <<<-----------------
    --> Gerar Log da tela
    PROCEDURE pc_log_tab089(pr_cdcooper IN crapcop.cdcooper%TYPE,
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
                                 pr_nmarqlog => 'tab089',
                                 pr_flfinmsg => 'N');
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
    

    -- Buscar dados da TAB
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'PAREMPREST'
                                             ,pr_tpregist => 01);

    --Se encontrou parametro, atribui valor. Caso contrario, mantem Zero 
    IF TRIM(vr_dstextab) IS NOT NULL THEN
      -- EFETUA OS PROCEDIMENTOS COM O DADO RETORNADO DA CRAPTAB
      vr_prtlmult := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,3));
      vr_prestorn := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,9,3));
      vr_prpropos := SUBSTR(vr_dstextab,13,8);
      vr_vlempres := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,22,12));
      vr_pzmaxepr := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,35,4));
      vr_vlmaxest := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,40,12));
      --
      vr_pcaltpar := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,53,6)),0);
      vr_vltolemp := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,60,12)),0);
      --                                                                
      vr_qtdpaimo := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,73,3)),0);
      vr_qtdpaaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,77,3)),0);
      vr_qtdpaava := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,81,3)),0);
      vr_qtdpaapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,85,3)),0);
      vr_qtdpasem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,89,3)),0);
      --                                                                
      vr_qtdibaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,93,3)),0);
      vr_qtdibapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,97,3)),0);
      vr_qtdibsem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,101,3)),0);

      vr_qtdpameq := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,105,3)),0);--      PJ438 - Márcio (Mouts)
      
      vr_qtditava := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,109,3)),0);  -- PJ438 - Márcio (Mouts)      
      vr_qtditapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,113,3)),0);  -- PJ438 - Márcio (Mouts)      
      vr_qtditsem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,117,3)),0);  -- PJ438 - Márcio (Mouts)                              
      
      vr_pctaxpre := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,121,6)),0);
      vr_qtdictcc := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,128,3)),0);
                  
      vr_avtperda := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,132,1)),0); -- PJ438 - Paulo (Mouts) Sprint 5
      vr_vlperavt := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,134,12)),0); -- PJ438 - Paulo (Mouts) Sprint 5          
    END IF;
    
    -- Buscar valor max para desc de titulo
      OPEN cr_crapprm(vr_cdcooper => vr_cdcooper);
        FETCH cr_crapprm
         INTO vr_dsvlrprm;
         CLOSE cr_crapprm;
                  
    --Se encontrou parametro valor max para estorno de desconto de titulo, atribui valor. Caso contrario, mantem Zero
    IF TRIM(vr_dsvlrprm) IS NOT NULL THEN
       vr_vlmaxdst := gene0002.fn_char_para_number(vr_dsvlrprm);
    END IF;

    vr_dstextab := to_char(pr_prtlmult,   'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(0          ,   'FM000')       || ' ' ||  -- POSICAO NAO UTILIZADA
                   to_char(pr_prestorn,   'FM000')       || ' ' ||
                   pr_prpropos                           || ' ' ||
                   to_char(pr_vlempres,   'FM000000000D00'  , 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_pzmaxepr,   'FM0000', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_vlmaxest,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   
                   to_char(pr_pcaltpar,   'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_vltolemp,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   
                   to_char(pr_qtdpaimo,   'FM000')       || ' ' ||
                   to_char(pr_qtdpaaut,   'FM000')       || ' ' ||
                   to_char(pr_qtdpaava,   'FM000')       || ' ' ||
                   to_char(pr_qtdpaapl,   'FM000')       || ' ' ||
                   to_char(pr_qtdpasem,   'FM000')       || ' ' ||
                   
                   to_char(pr_qtdibaut,   'FM000')       || ' ' ||
                   to_char(pr_qtdibapl,   'FM000')       || ' ' ||
                   to_char(pr_qtdibsem,   'FM000')       || ' ' ||
                   to_char(pr_qtdpameq,   'FM000')       || ' ' || --PJ438 - Márcio (Mouts)
                   to_char(pr_qtditava,   'FM000')       || ' ' || --PJ438 - Márcio (Mouts)
                   to_char(pr_qtditapl,   'FM000')       || ' ' || --PJ438 - Márcio (Mouts)                                                      
                   to_char(pr_qtditsem,   'FM000')       || ' ' || --PJ438 - Márcio (Mouts)
                   to_char(pr_pctaxpre,   'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_qtdictcc,   'FM000') || ' ' ||
                   to_char(pr_avtperda)|| ' ' || --PJ438 - Paulo (Mouts)  
                   to_char(pr_vlperavt,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''')|| ''; --PJ438 - Paulo (Mouts)  
    vr_dsvlrprm := to_char(pr_vlmaxdst,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''');

    BEGIN
      UPDATE craptab tab
         SET tab.dstextab = vr_dstextab
       WHERE tab.cdcooper        = vr_cdcooper
         AND upper(tab.nmsistem) = 'CRED'
         AND upper(tab.tptabela) = 'USUARI'
         AND tab.cdempres        = 11
         AND upper(tab.cdacesso) = 'PAREMPREST'
         AND tab.tpregist        = 01;
           
       UPDATE crapprm prm
          SET prm.dsvlrprm = vr_dsvlrprm
        WHERE prm.cdcooper = vr_cdcooper
          AND prm.cdacesso = 'VL_MAX_ESTORN_DST';

    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar Parametros!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;

    END;


    IF vr_prtlmult <> pr_prtlmult THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Prazo de tolerancia para incidencia de multa e juros de mora de ' ||
                                    to_char(vr_prtlmult,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_prtlmult,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_prestorn <> pr_prestorn THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Prazo maximo para estorno de contratos com alienacao/hipoteca de imoveis de ' ||
                                    to_char(vr_prestorn,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_prestorn,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;

    IF vr_prpropos <> pr_prpropos THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Prazo maximo de validade da proposta de ' ||
                                    vr_prpropos ||
                                    ' para ' || pr_prpropos);

    END IF;

    IF vr_vlempres <> pr_vlempres THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Valor minimo para cobranca de emprestimo de ' ||
                                    to_char(vr_vlempres,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_vlempres,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;

    IF vr_pzmaxepr <> pr_pzmaxepr THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Prazo maximo para liberacao do emprestimo de ' ||
                                    to_char(vr_pzmaxepr,'FM0000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_pzmaxepr,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_vlmaxest <> pr_vlmaxest THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Vl. max. de estorno perm. sem autorizacao da coordenacao/gerencia de ' ||
                                    to_char(vr_vlmaxest,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_vlmaxest,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;

    IF vr_pcaltpar <> pr_pcaltpar THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou % Alteracao de parcela de ' ||
                                    to_char(vr_pcaltpar,'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_pcaltpar,'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;

    IF vr_vltolemp <> pr_vltolemp THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Tolerancia por valor de emprestimo de ' ||
                                    to_char(vr_vltolemp,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_vltolemp,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdpaimo <> pr_qtdpaimo THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou PA - Prazo de validade Operacao com garantia de Imovel de ' ||
                                    to_char(vr_qtdpaimo,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdpaimo,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdpaaut <> pr_qtdpaaut THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou PA - Prazo de validade Operacao com garantia de Automovel de ' ||
                                    to_char(vr_qtdpaaut,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdpaaut,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdpaava <> pr_qtdpaava THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou PA - Prazo de validade Operacao com garantia de Aval de ' ||
                                    to_char(vr_qtdpaava,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdpaava,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdpaapl <> pr_qtdpaapl THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou PA - Prazo de validade Operacao com garantia de Aplicacao de ' ||
                                    to_char(vr_qtdpaapl,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdpaapl,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdpasem <> pr_qtdpasem THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou PA - Prazo de validade Operacao Sem Garantia de ' ||
                                    to_char(vr_qtdpasem,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdpasem,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

 -- Início PJ438 - Márcio (Mouts)
    IF vr_qtdpameq <> pr_qtdpameq THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou PA - Prazo de validade Operacao com garantia de Maquinas e Equipamentos de ' ||
                                    to_char(vr_qtdpameq,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdpameq,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtditava <> pr_qtditava THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Títulos - Prazo de validade Operação com garantia de Aval de ' ||
                                    to_char(vr_qtditava,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtditava,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtditapl <> pr_qtditapl THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Títulos - Prazo de validade Operação com garantia de Aplicação de ' ||
                                    to_char(vr_qtditapl,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtditapl,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtditsem <> pr_qtditsem THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Títulos - Prazo de validade Operação sem garantia de ' ||
                                    to_char(vr_qtditsem,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtditsem,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

 
 -- Fim PJ438 - Márcio (Mouts)

    IF vr_pctaxpre <> pr_pctaxpre THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou % Taxa de juros remuneratorio de prejuizo de ' ||
                                    to_char(vr_pctaxpre,'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_pctaxpre,'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;  
    
    IF vr_qtdictcc <> pr_qtdictcc THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Prejuizo - Prazo p/ transferencia de valor da conta transitoria para a CC de ' ||
                                    to_char(vr_qtdictcc,'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdictcc,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;  

    IF vr_qtdibaut <> pr_qtdibaut THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Mobile/IB/TAA - Prazo de validade Operacao com garantia de Automovel de ' ||
                                    to_char(vr_qtdibaut,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdibaut,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdibapl <> pr_qtdibapl THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Mobile/IB/TAA - Prazo de validade Operacao com garantia de Aplicacao de ' ||
                                    to_char(vr_qtdibapl,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdibapl,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdibsem <> pr_qtdibsem THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Mobile/IB/TAA - Prazo de validade Operacao Sem Garantia de ' ||
                                    to_char(vr_qtdibsem,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdibsem,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    -- PRJ438 - Paulo Martins (Mouts)
    IF vr_avtperda <> pr_avtperda THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou perda de aprovacao para alteração de avalista de ' ||
                                    to_char(vr_avtperda) ||
                                    ' para ' || to_char(pr_avtperda));

    END IF;
    
    IF vr_vlperavt <> pr_vlperavt THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Valor para perda de aprovação quando altera avalista de ' ||
                                    to_char(vr_vlperavt,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_vlperavt,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;    
    --Fim PRJ438    

    IF vr_vlmaxdst <> pr_vlmaxdst THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Vl. max. de estorno perm. para desconto de titulo sem autorizacao da coordenacao/gerencia de ' ||
                                    to_char(vr_vlmaxdst,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_vlmaxdst,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

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
  END pc_alterar;

  PROCEDURE pc_busca_mtv_anulacao(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_mtv_anulacao
    Sistema : CECRED
    Sigla   : EMPR
    Autor   : Márcio (Mouts)
    Data    : Agosto/2018                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar os motivos de anulação do emprestimo (tabela CECRED.TBCADAST_MOTIVO_ANULACAO)
    
    Alteracoes: 
    ............................................................................. */
  
    --Cursor para pegar motivos de anulação
    CURSOR cr_motivo_anulacao(vr_cdcooper IN CRAPCOP.CDCOOPER%TYPE) IS
      SELECT t.cdcooper,
             t.cdmotivo,
             t.dsmotivo,
             t.tpproduto,
             decode(t.tpproduto,1,'1 - Empréstimos/Financiamento'
                               ,2,'2 - Desconto Cheques - Limite'
                               ,3,'3 - Desconto Títulos - Limite'
                               ,4,'4 - Cartão de Crédito'
                               ,5,'5 - Limite de Crédito'
                               ,6,'6 - Desconto Cheque – Borderô'
                               ,7,'7 - Desconto de Título – Borderô'
                               ,t.tpproduto||'- Tipo não definido') dsproduto,
             to_char(t.dtcadastro,'DD/MM/YYYY') dtcadastro,
             t.inobservacao,
             t.idativo
        FROM tbcadast_motivo_anulacao t
       WHERE t.cdcooper = vr_cdcooper
        order by t.cdcooper,t.tpproduto,t.cdmotivo;

    rw_motivo_anulacao cr_motivo_anulacao%ROWTYPE;
  
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis locais
    vr_contador INTEGER := 0;
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
  
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
      RAISE vr_exc_erro;
    END IF;                                
    --   
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');  
    --
    -- Carregar arquivo com a tabela tbcadast_motivo_anulacao
    FOR rw_motivo_anulacao IN cr_motivo_anulacao(vr_cdcooper) LOOP
      --Escrever no XML
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'motivo',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdmotivo',
                               pr_tag_cont => rw_motivo_anulacao.cdmotivo,
                               pr_des_erro => vr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsmotivo',
                               pr_tag_cont => rw_motivo_anulacao.dsmotivo,
                               pr_des_erro => vr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'tpproduto',
                               pr_tag_cont => rw_motivo_anulacao.tpproduto,
                               pr_des_erro => vr_dscritic);                       
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsproduto',
                               pr_tag_cont => rw_motivo_anulacao.dsproduto,
                               pr_des_erro => vr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dtcadastro',
                               pr_tag_cont => rw_motivo_anulacao.dtcadastro,
                               pr_des_erro => vr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'inobservacao',
                               pr_tag_cont => rw_motivo_anulacao.inobservacao,
                               pr_des_erro => vr_dscritic);  
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'idativo',
                               pr_tag_cont => rw_motivo_anulacao.idativo,
                               pr_des_erro => vr_dscritic);  

        vr_contador := vr_contador + 1;
        --
    END LOOP;
    --
    pr_des_erro := 'OK';
    --
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
      pr_dscritic := 'Erro na TELA_TAB089.pc_busca_mtv_anulacao --> ' ||
                     SQLERRM;
                                  
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
  END pc_busca_mtv_anulacao;

  PROCEDURE pc_insere_mtv_anulacao(pr_dsmotivo     IN tbcadast_motivo_anulacao.dsmotivo%TYPE     --> Descrição do motivo
						      								,pr_tpproduto    IN tbcadast_motivo_anulacao.tpproduto%TYPE    --> Tipo do produto
									      					,pr_inobservacao IN tbcadast_motivo_anulacao.inobservacao%TYPE --> Exige observacao (0-Nao/1-Sim)
      														,pr_xmllog       IN VARCHAR2 --> XML com informações de LOG
			      											,pr_cdcritic     OUT PLS_INTEGER --> Código da crítica
						      								,pr_dscritic     OUT VARCHAR2 --> Descrição da crítica
									      					,pr_retxml       IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
      														,pr_nmdcampo     OUT VARCHAR2 --> Nome do Campo
			      											,pr_des_erro     OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_insere_mtv_anulacao
    Sistema : CECRED
    Sigla   : EMPR
    Autor   : Márcio (Mouts)
    Data    : Agosto/2018                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para inserir os motivos de anulação do emprestimo (tabela CECRED.TBCADAST_MOTIVO_ANULACAO)
    
    Alteracoes: 
    ............................................................................. */
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
   
	  -- Vairáveis auxliares
	  vr_cdmotivo tbcadast_motivo_anulacao.cdmotivo%TYPE;
		
    --Controle de erro
    vr_exc_erro EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);    
    
    vr_nrdrowid ROWID;     
  
  BEGIN
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
    --
    pr_des_erro := 'NOK';
    --
    BEGIN
    -- Busca o proximo Código
		vr_cdmotivo := fn_sequence(pr_nmtabela => 'tbcadast_motivo_anulacao'
															,pr_nmdcampo => 'cdmotivo'
															,pr_dsdchave => vr_cdcooper || ';' || pr_tpproduto);
															
    INSERT INTO tbcadast_motivo_anulacao 
      (cdcooper,
       cdmotivo,
       dsmotivo,
       tpproduto,
       dtcadastro,
       inobservacao,
       idativo
      )
    VALUES
      (vr_cdcooper
      ,vr_cdmotivo
			,pr_dsmotivo
      ,pr_tpproduto
      ,sysdate
      ,pr_inobservacao
      ,1
      );
    EXCEPTION
      WHEN dup_val_on_index THEN
         vr_dscritic := 'Registro ja existente!';
         RAISE vr_exc_erro;
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir registro!';
         RAISE vr_exc_erro;
    END;
    -- Gravar LOG
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => vr_dscritic
                        ,pr_dsorigem => vr_idorigem
                        ,pr_dstransa => 'Tela TAB089 - Inclusão do motivo de anulação do empréstimo - tbcadast_motivo_anulacao'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 0
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 0
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => 0
                        ,pr_nrdrowid => vr_nrdrowid);
          
    -- Gravar Item do LOG
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => vr_cdcooper);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo de Produto'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_tpproduto);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cód. Motivo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => vr_cdmotivo);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Desc. Motivo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsmotivo);		  
                                                            
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data Cadastro'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => sysdate);		                               
                               
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Exige observação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_inobservacao);	
                               
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Identificador de ativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 1);	
    --  
    COMMIT;
    --
    pr_des_erro := 'OK';
    --
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
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_TAB089.pc_insere_mtv_anulacao --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
  
  END pc_insere_mtv_anulacao;

  PROCEDURE pc_atualiza_mtv_anulacao(pr_cdmotivo     IN tbcadast_motivo_anulacao.cdmotivo%TYPE     --> Código do motivo
  						      								,pr_tpproduto    IN tbcadast_motivo_anulacao.tpproduto%TYPE    --> Tipo do produto
                                    ,pr_dsmotivo     IN tbcadast_motivo_anulacao.dsmotivo%TYPE     --> Descrição do motivo
  									      					,pr_inobservacao IN tbcadast_motivo_anulacao.inobservacao%TYPE --> Exige observacao (0-Nao/1-Sim)
                                    ,pr_idativo      IN tbcadast_motivo_anulacao.idativo%TYPE      --> Identificador de ativa (0-nao / 1-sim)                                        
         													  ,pr_xmllog       IN VARCHAR2                                   --> XML com informações de LOG
       	 													  ,pr_cdcritic     OUT PLS_INTEGER                               --> Código da crítica
														        ,pr_dscritic     OUT VARCHAR2                                  --> Descrição da crítica
       														  ,pr_retxml       IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
			      											  ,pr_nmdcampo     OUT VARCHAR2                                  --> Nome do Campo
						      								  ,pr_des_erro     OUT VARCHAR2) IS                              --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_atualiza_mtv_anulacao
    Sistema : CECRED
    Sigla   : EMPR
    Autor   : Márcio (Mouts)
    Data    : Agosto/2018                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para atualizar os motivos de anulação do emprestimo (tabela CECRED.TBCADAST_MOTIVO_ANULACAO)
    
    Alteracoes: 
    ............................................................................. */

    CURSOR cr_motivo_anulacao(pr_cdcooper  IN tbcadast_motivo_anulacao.cdcooper%TYPE) IS
      SELECT t.cdmotivo,
			       t.dsmotivo,
						 t.inobservacao,
             t.idativo
        FROM tbcadast_motivo_anulacao t
       WHERE t.cdcooper  = pr_cdcooper
         AND t.cdmotivo  = pr_cdmotivo
         AND t.tpproduto = pr_tpproduto;
       
    rw_motivo_anulacao cr_motivo_anulacao%ROWTYPE;
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Controle de erro
    vr_exc_erro EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);    
    
    vr_nrdrowid ROWID;    
  
  BEGIN
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
                             
    pr_des_erro := 'NOK';
   
    -- Abre indicador 
    OPEN cr_motivo_anulacao(vr_cdcooper);
    FETCH cr_motivo_anulacao INTO rw_motivo_anulacao;
		
    -- Se não existe
    IF cr_motivo_anulacao%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_motivo_anulacao;
        -- Gera crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Motivo não encontrado!';
        -- Levanta exceção
        RAISE vr_exc_erro;
    END IF;

    -- Fecha cursor
    CLOSE cr_motivo_anulacao;
    
    BEGIN
      --
      UPDATE tbcadast_motivo_anulacao t
         SET t.dsmotivo     = pr_dsmotivo,
             t.inobservacao = pr_inobservacao,
             t.idativo      = pr_idativo
       WHERE t.cdcooper     = vr_cdcooper
         AND t.cdmotivo     = pr_cdmotivo
         AND t.tpproduto    = pr_tpproduto;
       --
    EXCEPTION
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro!';
         RAISE vr_exc_erro;
    END;
    
    IF SQL%ROWCOUNT = 0 THEN
     vr_dscritic := 'Registro não encontrado!';
     RAISE vr_exc_erro;
    END IF;
    --    
    -- Gravar LOG
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => vr_dscritic
                        ,pr_dsorigem => vr_idorigem
                        ,pr_dstransa => 'Tela TAB089 - Alteração do motivo de anulação do empréstimo - tbcadast_motivo_anulacao'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 0
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 0
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => 0
                        ,pr_nrdrowid => vr_nrdrowid);
          
    -- Gravar Item do LOG
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => vr_cdcooper
                               ,pr_dsdadatu => vr_cdcooper);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo de Produto'
                               ,pr_dsdadant => pr_tpproduto
                               ,pr_dsdadatu => pr_tpproduto);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cód. Motivo'
                               ,pr_dsdadant => pr_cdmotivo
                               ,pr_dsdadatu => pr_cdmotivo);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Desc. Motivo'
                               ,pr_dsdadant => rw_motivo_anulacao.dsmotivo
                               ,pr_dsdadatu => pr_dsmotivo);		  
                                                            
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Exige observação'
                               ,pr_dsdadant => rw_motivo_anulacao.inobservacao
                               ,pr_dsdadatu => pr_inobservacao);	

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Identificador de ativa'
                               ,pr_dsdadant => rw_motivo_anulacao.idativo
                               ,pr_dsdadatu => pr_idativo);	

                               
    COMMIT;
    pr_des_erro := 'OK';
    --
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
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_TAB089.pc_atualiza_mtv_anulacao --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_atualiza_mtv_anulacao;

  PROCEDURE pc_busca_email_proposta(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_email_proposta
    Sistema : CECRED
    Sigla   : EMPR
    Autor   : Márcio (Mouts)
    Data    : Agosto/2018                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar os parâmetros de envio do e-mail de proposta (tabela CECRED.TBCADAST_EMAIL_PROPOSTA)
    
    Alteracoes: 
    ............................................................................. */
  
    --Cursor para pegar motivos de anulação
    CURSOR cr_email_proposta(vr_cdcooper IN CRAPCOP.CDCOOPER%TYPE) IS
      SELECT t.cdcooper,
             t.tpproduto,
             decode(t.tpproduto,1,'1 - Empréstimos/Financiamento'
                               ,2,'2 - Desconto Cheques - Limite'
                               ,3,'3 - Desconto Títulos - Limite'
                               ,4,'4 - Cartão de Crédito'
                               ,5,'5 - Limite de Crédito'
                               ,6,'6 - Desconto Cheque – Borderô'
                               ,7,'7 - Desconto de Título – Borderô'
                               ,t.tpproduto||'- Tipo não definido') dsproduto,
             t.qt_periodicidade,
             t.qt_envio,
             t.ds_assunto,
             t.ds_corpo,
             t.idativo
        FROM tbcadast_email_proposta t
       WHERE t.cdcooper = vr_cdcooper
        order by t.cdcooper,t.tpproduto;

    rw_email_proposta cr_email_proposta%ROWTYPE;
  
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis locais
    vr_contador INTEGER := 0;
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
  
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
      RAISE vr_exc_erro;
    END IF;                                
    --   
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');  
    --
    -- Carregar arquivo com a tabela tbcadast_email_proposta
    FOR rw_email_proposta IN cr_email_proposta(vr_cdcooper) LOOP
      --Escrever no XML
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'parametro',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'parametro',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'tpproduto',
                               pr_tag_cont => rw_email_proposta.tpproduto,
                               pr_des_erro => vr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'parametro',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsproduto',
                               pr_tag_cont => rw_email_proposta.dsproduto,
                               pr_des_erro => vr_dscritic);	                                     
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'parametro',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'qt_periodicidade',
                               pr_tag_cont => rw_email_proposta.qt_periodicidade,
                               pr_des_erro => vr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'parametro',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'qt_envio',
                               pr_tag_cont => rw_email_proposta.qt_envio,
                               pr_des_erro => vr_dscritic);  
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'parametro',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'ds_assunto',
                               pr_tag_cont => rw_email_proposta.ds_assunto,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'parametro',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'ds_corpo',
                               pr_tag_cont => rw_email_proposta.ds_corpo,
                               pr_des_erro => vr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'parametro',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'idativo',
                               pr_tag_cont => rw_email_proposta.idativo,
                               pr_des_erro => vr_dscritic);                                
                               

        vr_contador := vr_contador + 1;
        --
    END LOOP;
    --
    pr_des_erro := 'OK';
    --gene0002.pc_XML_para_arquivo(pr_retxml
    --                           ,'/usr/coop/cecred/'
    --                           ,'TESTE.xml'
    --                           ,pr_dscritic );    
    
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
      pr_dscritic := 'Erro na TELA_TAB089.pc_busca_email_proposta --> ' ||
                     SQLERRM;
                                  
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
  END pc_busca_email_proposta;
  
  PROCEDURE pc_insere_email_proposta(pr_tpproduto        IN tbcadast_email_proposta.tpproduto%TYPE        --> Tipo do produto
  									      					,pr_qt_periodicidade IN tbcadast_email_proposta.qt_periodicidade%TYPE --> Quantidade de dias entre cada notificacao do operador
                                    ,pr_qt_envio         IN tbcadast_email_proposta.qt_envio%TYPE         --> Quantidade de envios realizadas no dia da notificacao
  									      					,pr_ds_assunto       IN tbcadast_email_proposta.ds_assunto%TYPE       --> Descricao do Assunto do E-mail
                                    ,pr_ds_corpo         IN tbcadast_email_proposta.ds_corpo%TYPE         --> Descricao do corpo do E-mail
        														,pr_xmllog           IN VARCHAR2 --> XML com informações de LOG
			        											,pr_cdcritic         OUT PLS_INTEGER --> Código da crítica
				  		      								,pr_dscritic         OUT VARCHAR2 --> Descrição da crítica
					  				      					,pr_retxml           IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
      			  											,pr_nmdcampo         OUT VARCHAR2 --> Nome do Campo
			      	  										,pr_des_erro         OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_insere_email_proposta
    Sistema : CECRED
    Sigla   : EMPR
    Autor   : Márcio (Mouts)
    Data    : Agosto/2018                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para inserir os parâmetros de envio do e-mail de proposta (tabela CECRED.TBCADAST_EMAIL_PROPOSTA)
    
    Alteracoes: 
    ............................................................................. */
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
   
	  -- Vairáveis auxliares
		
    --Controle de erro
    vr_exc_erro EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);    
    
    vr_nrdrowid ROWID;     
  
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
      RAISE vr_exc_erro;
    END IF;    
    --
    BEGIN
															
    INSERT INTO tbcadast_email_proposta
      (cdcooper,
       tpproduto,
       qt_periodicidade,
       qt_envio,
       ds_assunto,
       ds_corpo,
       idativo
      )
    VALUES
      (vr_cdcooper,
       pr_tpproduto,
       pr_qt_periodicidade,
       pr_qt_envio,
       pr_ds_assunto,
       pr_ds_corpo,
       1
      );
    EXCEPTION
      WHEN dup_val_on_index THEN
         vr_dscritic := 'Registro ja existente!';
         RAISE vr_exc_erro;
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir registro!';
         RAISE vr_exc_erro;
    END;
    -- Gravar LOG
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => vr_dscritic
                        ,pr_dsorigem => vr_idorigem
                        ,pr_dstransa => 'Tela TAB089 - Inclusão dos parâmeros de envio do E-mail da Proposta - tbcadast_email_proposta'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 0
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 0
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => 0
                        ,pr_nrdrowid => vr_nrdrowid);
          
    -- Gravar Item do LOG
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => vr_cdcooper);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo de Produto'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_tpproduto);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Periodicidade'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_qt_periodicidade);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Qtde. De Envios'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_qt_envio);		  
                                                            
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Assunto do E-mail'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_ds_assunto);		                               
                               
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Corpo do E-mail'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_ds_corpo);	
                               
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Identificador de ativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 1);	                               
                               
    --  
    COMMIT;
    --
    pr_des_erro := 'OK';
    --
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
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_TAB089.pc_insere_email_proposta --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
  
  END pc_insere_email_proposta;

  PROCEDURE pc_atualiza_email_proposta(pr_tpproduto        IN tbcadast_email_proposta.tpproduto%TYPE        --> Tipo do produto
    									      					,pr_qt_periodicidade IN tbcadast_email_proposta.qt_periodicidade%TYPE --> Quantidade de dias entre cada notificacao do operador
                                      ,pr_qt_envio         IN tbcadast_email_proposta.qt_envio%TYPE         --> Quantidade de envios realizadas no dia da notificacao
  		  							      					,pr_ds_assunto       IN tbcadast_email_proposta.ds_assunto%TYPE       --> Descricao do Assunto do E-mail
                                      ,pr_ds_corpo         IN tbcadast_email_proposta.ds_corpo%TYPE         --> Descricao do corpo do E-mail
                                      ,pr_idativo          IN NUMBER                                     --> Identificador de ativa (0-nao / 1-sim)                                                                              
           													  ,pr_xmllog           IN VARCHAR2                                   --> XML com informações de LOG
       	   													  ,pr_cdcritic         OUT PLS_INTEGER                               --> Código da crítica
					  									        ,pr_dscritic         OUT VARCHAR2                                  --> Descrição da crítica
       			  											  ,pr_retxml           IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
			      	  										  ,pr_nmdcampo         OUT VARCHAR2                                  --> Nome do Campo
						        								  ,pr_des_erro         OUT VARCHAR2) IS                              --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_atualiza_email_proposta
    Sistema : CECRED
    Sigla   : EMPR
    Autor   : Márcio (Mouts)
    Data    : Agosto/2018                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para atualizar os parâmetros de envio do e-mail de proposta (tabela CECRED.TBCADAST_EMAIL_PROPOSTA)
    
    Alteracoes: 
    ............................................................................. */

    CURSOR cr_email_proposta(pr_cdcooper  IN tbcadast_motivo_anulacao.cdcooper%TYPE) IS
      SELECT t.qt_periodicidade
            ,t.qt_envio
    				,t.ds_assunto
            ,t.ds_corpo
            ,t.idativo
        FROM tbcadast_email_proposta t
       WHERE t.cdcooper  = pr_cdcooper
         AND t.tpproduto = pr_tpproduto;
       
    rw_email_proposta cr_email_proposta%ROWTYPE;
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Controle de erro
    vr_exc_erro EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);    
    
    vr_nrdrowid ROWID;    
  
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
      RAISE vr_exc_erro;
    END IF;
   
    -- Abre indicador 
    OPEN cr_email_proposta(vr_cdcooper);
    FETCH cr_email_proposta INTO rw_email_proposta;
		
    -- Se não existe
    IF cr_email_proposta%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_email_proposta;
        -- Gera crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Parâmetro de envio de E-mail não encontrado!';
        -- Levanta exceção
        RAISE vr_exc_erro;
    END IF;

    -- Fecha cursor
    CLOSE cr_email_proposta;
    
    BEGIN
      --
      UPDATE tbcadast_email_proposta t
         SET t.qt_periodicidade = pr_qt_periodicidade
            ,t.qt_envio         = pr_qt_envio
    				,t.ds_assunto       = pr_ds_assunto
            ,t.ds_corpo         = pr_ds_corpo
            ,t.idativo          = pr_idativo
       WHERE t.cdcooper     = vr_cdcooper
         AND t.tpproduto    = pr_tpproduto;
       --
    EXCEPTION
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro!';
         RAISE vr_exc_erro;
    END;
    
    IF SQL%ROWCOUNT = 0 THEN
     vr_dscritic := 'Registro não encontrado!';
     RAISE vr_exc_erro;
    END IF;
    --    
    -- Gravar LOG
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => vr_dscritic
                        ,pr_dsorigem => vr_idorigem
                        ,pr_dstransa => 'Tela TAB089 - Alteração dos parâmetros do E-mail da Proposta - tbcadast_email_proposta'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 0
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 0
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => 0
                        ,pr_nrdrowid => vr_nrdrowid);
          
    -- Gravar Item do LOG
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => vr_cdcooper
                               ,pr_dsdadatu => vr_cdcooper);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo de Produto'
                               ,pr_dsdadant => pr_tpproduto
                               ,pr_dsdadatu => pr_tpproduto);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Periodicidade'
                               ,pr_dsdadant => rw_email_proposta.qt_periodicidade
                               ,pr_dsdadatu => pr_qt_periodicidade);		

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Qtde. De Envios'
                               ,pr_dsdadant => rw_email_proposta.qt_envio
                               ,pr_dsdadatu => pr_qt_envio);		  
                                                            
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Assunto do E-mail'
                               ,pr_dsdadant => rw_email_proposta.ds_assunto
                               ,pr_dsdadatu => pr_ds_assunto);		                               
                               
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Corpo do E-mail'
                               ,pr_dsdadant => rw_email_proposta.ds_corpo
                               ,pr_dsdadatu => pr_ds_corpo);	
                               
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Identificador de ativa'
                               ,pr_dsdadant => rw_email_proposta.idativo
                               ,pr_dsdadatu => pr_idativo);	                               
                               
    COMMIT;
    pr_des_erro := 'OK';
    --
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
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_TAB089.pc_atualiza_email_proposta --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_atualiza_email_proposta;

----------------------------------
END TELA_TAB089;
/
