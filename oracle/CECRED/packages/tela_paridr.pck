CREATE OR REPLACE PACKAGE CECRED.tela_paridr IS

	PROCEDURE pc_obtem_indicadores(pr_cdcooper IN INTEGER            --> Cooperativa
		                            ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2);        --> Erros do processo
                                
  PROCEDURE pc_obtem_vinculacoes(pr_cdcooper IN INTEGER            --> Cooperativa
		                            ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2);        --> Erros do processo

	PROCEDURE pc_obtem_idindicador(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2);        --> Erros do processo

 	PROCEDURE pc_insere_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
															 ,pr_nmindica IN tbrecip_indicador.nmindicador%TYPE --> Nome do indicador
		                           ,pr_tpindica IN tbrecip_indicador.tpindicador%TYPE --> Tipo do indicador ('M' - Moeda, 'Q' - Quantidade e 'A' - Adesão)
															 ,pr_flgativo IN tbrecip_indicador.flgativo%TYPE    --> Disponibilidade do indicador (0 - Inativo, 1 - Ativo)
															 ,pr_dsindica IN tbrecip_indicador.dsindicador%TYPE --> Descrição do indicador
		                           ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
															 ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
															 ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
															 ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
															 ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
															 ,pr_des_erro OUT VARCHAR2);                        --> Erros do processo
                               
  PROCEDURE pc_altera_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
                               ,pr_nmindica IN tbrecip_indicador.nmindicador%TYPE --> Nome do indicador
                               ,pr_tpindica IN tbrecip_indicador.tpindicador%TYPE --> Tipo do indicador ('M' - Moeda, 'Q' - Quantidade e 'A' - Adesão)
                               ,pr_flgativo IN tbrecip_indicador.flgativo%TYPE    --> Disponibilidade do indicador (0 - Inativo, 1 - Ativo)
                               ,pr_dsindica IN tbrecip_indicador.dsindicador%TYPE --> Descrição do indicador
                               ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);                        --> Erros do processo

	PROCEDURE pc_exclui_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
                               ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);                        --> Erros do processo

	PROCEDURE pc_pesquisa_indicadores(pr_nmindicador   IN VARCHAR2           --> Descrição parcial do Indicador
																	 ,pr_xmllog        IN VARCHAR2           --> XML com informações de LOG
																	 ,pr_cdcritic     OUT PLS_INTEGER        --> Código da crítica
																	 ,pr_dscritic     OUT VARCHAR2           --> Descrição da crítica
																	 ,pr_retxml        IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
																	 ,pr_nmdcampo     OUT VARCHAR2           --> Nome do campo com erro
																	 ,pr_des_erro     OUT VARCHAR2);         --> Erros do processo
                                   
  PROCEDURE pc_pesquisa_vinculacoes(pr_nmvinculacao  IN VARCHAR2           --> Descrição parcial do Indicador
																	 ,pr_xmllog        IN VARCHAR2           --> XML com informações de LOG
																	 ,pr_cdcritic     OUT PLS_INTEGER        --> Código da crítica
																	 ,pr_dscritic     OUT VARCHAR2           --> Descrição da crítica
																	 ,pr_retxml        IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
																	 ,pr_nmdcampo     OUT VARCHAR2           --> Nome do campo com erro
																	 ,pr_des_erro     OUT VARCHAR2);         --> Erros do processo

	PROCEDURE pc_pesquisa_produtos(pr_dsproduto     IN VARCHAR2           --> Descrição parcial do Produto
														  	,pr_xmllog        IN VARCHAR2           --> XML com informações de LOG
															  ,pr_cdcritic     OUT PLS_INTEGER        --> Código da crítica
															  ,pr_dscritic     OUT VARCHAR2           --> Descrição da crítica
															  ,pr_retxml        IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
															  ,pr_nmdcampo     OUT VARCHAR2           --> Nome do campo com erro
															  ,pr_des_erro     OUT VARCHAR2);         --> Erros do processo

	PROCEDURE pc_valida_indicador(pr_idindica IN INTEGER                  --> Indicador
		                           ,pr_xmllog   IN VARCHAR2                 --> XML com informações de LOG
															 ,pr_cdcritic OUT PLS_INTEGER             --> Código da crítica
															 ,pr_dscritic OUT VARCHAR2                --> Descrição da crítica
														 	 ,pr_retxml   IN OUT NOCOPY xmltype       --> Arquivo de retorno do XML
															 ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
															 ,pr_des_erro OUT VARCHAR2);              --> Erros do processo
                               
  PROCEDURE pc_valida_vinculacao(pr_idvinculacao IN INTEGER        --> Vinculacao
                                ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);        --> Erros do processo

	PROCEDURE pc_valida_produto(pr_cdproduto IN INTEGER           --> Produto
														 ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
														 ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
														 ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
														 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
														 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
														 ,pr_des_erro OUT VARCHAR2);        --> Erros do processo

	PROCEDURE pc_insere_param_indica(pr_cdcooper IN INTEGER            --> Cooperativa
		                              ,pr_idindica IN INTEGER            --> Id. do indicador
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
																	,pr_vlminimo IN NUMBER             --> Valor mínimo
																	,pr_vlmaximo IN NUMBER             --> Valor máximo
																	,pr_perscore IN NUMBER             --> Percentual de score
																	,pr_pertoler IN NUMBER             --> Percentual de tolerância
                                  ,pr_perpeso  IN NUMBER             --> Percentual peso
                                  ,pr_perdesc  IN NUMBER             --> Percentual de desconto
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2);        --> Erros do processo
                                  
  PROCEDURE pc_insere_param_vinculacao(pr_cdcooper IN INTEGER        --> Cooperativa
		                              ,pr_idvinculacao IN INTEGER        --> Id. da vinculacao
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
                                  ,pr_perpeso  IN NUMBER             --> Percentual peso
                                  ,pr_perdesc  IN NUMBER             --> Percentual de desconto
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2);        --> Erros do processo

	PROCEDURE pc_altera_param_indica(pr_cdcooper IN INTEGER            --> Cooperativa
		                              ,pr_idindica IN INTEGER            --> Id. do indicador
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
																	,pr_vlminimo IN NUMBER             --> Valor mínimo
																	,pr_vlmaximo IN NUMBER             --> Valor máximo
																	,pr_perscore IN NUMBER             --> Percentual de score
																	,pr_pertoler IN NUMBER             --> Percentual de tolerância
                                  ,pr_perpeso  IN NUMBER             --> Percentual peso
                                  ,pr_perdesc  IN NUMBER             --> Percentual de desconto
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2);        --> Erros do processo
                                  
  PROCEDURE pc_altera_param_vinculacao(pr_cdcooper IN INTEGER        --> Cooperativa
		                              ,pr_idvinculacao IN INTEGER        --> Id. da vinculacao
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
                                  ,pr_perpeso  IN NUMBER             --> Percentual peso
                                  ,pr_perdesc  IN NUMBER             --> Percentual de desconto
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2);        --> Erros do processo

	PROCEDURE pc_exclui_param_indica(pr_cdcooper IN INTEGER            --> Cooperativa
		                              ,pr_idindica IN INTEGER            --> Id. do indicador
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2);        --> Erros do processo
                                  
  PROCEDURE pc_exclui_param_vinculacao(pr_cdcooper IN INTEGER        --> Cooperativa
		                              ,pr_idvinculacao IN INTEGER        --> Id. da vinculacao
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2);        --> Erros do processo

END tela_paridr;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_paridr IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_PARIDR
  --  Sistema  : Ayllos Web
  --  Autor    : Lucas Reinert
  --  Data     : Fevereiro - 2016.                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela PARIDR
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_obtem_indicadores(pr_cdcooper IN INTEGER  --> Cooperativa
		                            ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_obtem_indicadores
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar indicadores de reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_indicadores IS
				SELECT prc.idindicador
							,upper(irc.nmindicador) nmindicador
							,decode(irc.tpindicador,'Q','Quantidade','M','Moeda','Adesão') tpindicador
							,prd.cdproduto
							,prd.dsproduto
							,decode(prc.inpessoa,1,'Física','Jurídica') inpessoa
							,prc.inpessoa inpessoa2
							,decode(irc.tpindicador, 'A', '-', RCIP0001.FN_FORMAT_VALOR_INDICADOR(pr_idindicador => prc.idindicador
							                                                                     ,pr_vlaformatar => prc.vlminimo)) vlminimo
							,decode(irc.tpindicador, 'A', '-', RCIP0001.FN_FORMAT_VALOR_INDICADOR(pr_idindicador => prc.idindicador
							                                                                     ,pr_vlaformatar => prc.vlmaximo)) vlmaximo
							,to_char(prc.perscore, 'fm990d00') perscore
							,decode(irc.tpindicador, 'A', '-', to_char(prc.pertolera, 'fm990d00')) pertolera
              ,to_char(nvl(prc.vlpercentual_peso,0), 'fm990d00') vlpercentual_peso
              ,to_char(nvl(prc.vlpercentual_desconto,0), 'fm990d00') vlpercentual_desconto
					FROM tbcc_produto prd
							,tbrecip_parame_indica_coop prc
							,tbrecip_indicador irc
				 WHERE prc.cdcooper    = pr_cdcooper
					 AND prc.idindicador = irc.idindicador
					 AND prc.cdproduto   = prd.cdproduto;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

    BEGIN

		  gene0001.pc_informa_acesso(pr_module => 'TELA_PARIDR');

      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      FOR rw_indicadores IN cr_indicadores LOOP

        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'indicador'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'idindicador'
                              ,pr_tag_cont => to_char(rw_indicadores.idindicador)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'nmindicador'
                              ,pr_tag_cont => to_char(rw_indicadores.nmindicador)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdproduto'
                              ,pr_tag_cont => to_char(rw_indicadores.cdproduto)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsproduto'
                              ,pr_tag_cont => to_char(rw_indicadores.dsproduto)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'inpessoa'
                              ,pr_tag_cont => to_char(rw_indicadores.inpessoa)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'inpessoa2'
                              ,pr_tag_cont => to_char(rw_indicadores.inpessoa2)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'tpindicador'
                              ,pr_tag_cont => to_char(rw_indicadores.tpindicador)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vlminimo'
                              ,pr_tag_cont => to_char(rw_indicadores.vlminimo)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vlmaximo'
                              ,pr_tag_cont => to_char(rw_indicadores.vlmaximo)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'perscore'
                              ,pr_tag_cont => rw_indicadores.perscore
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'pertolera'
                              ,pr_tag_cont => rw_indicadores.pertolera
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vlpercentual_peso'
                              ,pr_tag_cont => rw_indicadores.vlpercentual_peso
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vlpercentual_desconto'
                              ,pr_tag_cont => rw_indicadores.vlpercentual_desconto
                              ,pr_des_erro => vr_dscritic);


        vr_auxconta := vr_auxconta + 1;

      END LOOP;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_obtem_indicadores;
  
  PROCEDURE pc_obtem_vinculacoes(pr_cdcooper IN INTEGER  --> Cooperativa
		                            ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_obtem_vinculacoes
    Sistema : Ayllos Web
    Autor   : Andre Clemer
    Data    : Agosto - 2018.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar vinculacoes de reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_vinculacoes IS
				SELECT vnc.idvinculacao
							,upper(vnc.nmvinculacao) nmvinculacao
							,prd.cdproduto
							,prd.dsproduto
							,decode(vpc.inpessoa,1,'Física','Jurídica') inpessoa
							,vpc.inpessoa inpessoa2
              ,to_char(nvl(vpc.vlpercentual_peso,0), 'fm990d00') vlpercentual_peso
              ,to_char(nvl(vpc.vlpercentual_desconto,0), 'fm990d00') vlpercentual_desconto
					FROM tbcc_produto prd
              ,tbrecip_vinculacao_parame_coop vpc
							,tbrecip_vinculacao vnc
				 WHERE vpc.cdcooper               = pr_cdcooper
					 AND vpc.idvinculacao_reciproci = vnc.idvinculacao
					 AND vpc.cdproduto              = prd.cdproduto;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

    BEGIN

		  gene0001.pc_informa_acesso(pr_module => 'TELA_PARIDR');

      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      FOR rw_vinculacoes IN cr_vinculacoes LOOP

        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vinculacao'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'vinculacao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'idvinculacao'
                              ,pr_tag_cont => to_char(rw_vinculacoes.idvinculacao)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'vinculacao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'nmvinculacao'
                              ,pr_tag_cont => to_char(rw_vinculacoes.nmvinculacao)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'vinculacao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdproduto'
                              ,pr_tag_cont => to_char(rw_vinculacoes.cdproduto)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'vinculacao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsproduto'
                              ,pr_tag_cont => to_char(rw_vinculacoes.dsproduto)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'vinculacao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'inpessoa'
                              ,pr_tag_cont => to_char(rw_vinculacoes.inpessoa)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'vinculacao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'inpessoa2'
                              ,pr_tag_cont => to_char(rw_vinculacoes.inpessoa2)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'vinculacao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vlpercentual_peso'
                              ,pr_tag_cont => rw_vinculacoes.vlpercentual_peso
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'vinculacao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vlpercentual_desconto'
                              ,pr_tag_cont => rw_vinculacoes.vlpercentual_desconto
                              ,pr_des_erro => vr_dscritic);


        vr_auxconta := vr_auxconta + 1;

      END LOOP;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_obtem_vinculacoes;

	PROCEDURE pc_obtem_idindicador(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_obtem_idindicador
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar último idindicador disponivel para inserção

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_indicadores IS
				SELECT nvl(max(idindicador),0) + 1 idindicador
          FROM tbrecip_indicador;
			rw_indicadores cr_indicadores%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

    BEGIN

      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Busca idindicador disponível
      OPEN cr_indicadores;
			FETCH cr_indicadores INTO rw_indicadores;

			IF cr_indicadores%FOUND THEN
			  -- Insere tag
				gene0007.pc_insere_tag(pr_xml      => pr_retxml
															,pr_tag_pai  => 'Dados'
															,pr_posicao  => vr_auxconta
															,pr_tag_nova => 'idindicador'
															,pr_tag_cont => to_char(rw_indicadores.idindicador)
															,pr_des_erro => vr_dscritic);
		  END IF;

			CLOSE cr_indicadores;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_obtem_idindicador;

	PROCEDURE pc_insere_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
                               ,pr_nmindica IN tbrecip_indicador.nmindicador%TYPE --> Nome do indicador
                               ,pr_tpindica IN tbrecip_indicador.tpindicador%TYPE --> Tipo do indicador ('M' - Moeda, 'Q' - Quantidade e 'A' - Adesão)
                               ,pr_flgativo IN tbrecip_indicador.flgativo%TYPE    --> Disponibilidade do indicador (0 - Inativo, 1 - Ativo)
                               ,pr_dsindica IN tbrecip_indicador.dsindicador%TYPE --> Descrição do indicador
                               ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS                      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_insere_indicador
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para inserir indicador de reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados do indicador
			CURSOR cr_indicador IS
			  SELECT ind.idindicador,
				       ind.nmindicador,
							 ind.tpindicador,
							 decode(flgativo,1,'Ativo','Inativo') flgativo,
							 ind.dsindicador
				  FROM tbrecip_indicador ind
				 WHERE ind.idindicador = pr_idindica;
			rw_indicador cr_indicador%ROWTYPE;

      CURSOR cr_nmindicador IS
				SELECT 1
          FROM tbrecip_indicador ind
				 WHERE ind.nmindicador = pr_nmindica;
			rw_nmindicador cr_nmindicador%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

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

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Inclusao indicador de reciprocidade';
			vr_nrdrowid ROWID;
			vr_dsfativo VARCHAR2(10);

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

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

      -- Abre cursor para verificar se já existe indicador cadastrado com o id parametrizado
		  OPEN cr_indicador;
			FETCH cr_indicador INTO rw_indicador;

			-- Se existe
			IF cr_indicador%FOUND THEN
				-- Fecha cursor
				CLOSE cr_indicador;
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Atenção! Já existe outro indicador com este ID. Favor revisar o cadastro!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
			-- Fecha cursor
			CLOSE cr_indicador;

		  -- Abre cursor para verificar se existe indicador com o mesmo nome
		  OPEN cr_nmindicador;
			FETCH cr_nmindicador INTO rw_nmindicador;

 			-- Se existe
			IF cr_nmindicador%FOUND THEN
				-- Fecha cursor
				CLOSE cr_nmindicador;
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Atenção! Já existe outro indicador com este nome, favor revisar o cadastro!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
			-- Fecha cursor
			CLOSE cr_nmindicador;

      BEGIN
				INSERT INTO tbrecip_indicador(idindicador, nmindicador, dsindicador, tpindicador, flgativo)
				                       VALUES(pr_idindica, pr_nmindica, pr_dsindica, pr_tpindica, pr_flgativo);
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a gravação, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

			-- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Indicador',
																pr_dsdadant => '',
																pr_dsdadatu => to_char(pr_idindica));

		  -- Nome Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Nome Indicador',
																pr_dsdadant => '',
																pr_dsdadatu => pr_nmindica);

		  -- Tipo Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Indicador',
																pr_dsdadant => '',
																pr_dsdadatu => pr_tpindica);

      IF pr_flgativo = 0 THEN
				vr_dsfativo := 'Inativo';
			ELSE
				vr_dsfativo := 'Ativo';
			END IF;

		  -- Atividade Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Indicador',
																pr_dsdadant => '',
																pr_dsdadatu => vr_dsfativo);

		  -- Descrição Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Descricao Indicador',
																pr_dsdadant => '',
																pr_dsdadatu => pr_dsindica);

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_insere_indicador;

	PROCEDURE pc_altera_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
                               ,pr_nmindica IN tbrecip_indicador.nmindicador%TYPE --> Nome do indicador
                               ,pr_tpindica IN tbrecip_indicador.tpindicador%TYPE --> Tipo do indicador ('M' - Moeda, 'Q' - Quantidade e 'A' - Adesão)
                               ,pr_flgativo IN tbrecip_indicador.flgativo%TYPE    --> Disponibilidade do indicador (0 - Inativo, 1 - Ativo)
                               ,pr_dsindica IN tbrecip_indicador.dsindicador%TYPE --> Descrição do indicador
                               ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS                      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_altera_indicador
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar indicador de reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

		  -- Buscar informações do indicador
		  CURSOR cr_indicador IS
			  SELECT ind.idindicador,
				       ind.nmindicador,
							 ind.tpindicador,
							 decode(flgativo,1,'Ativo','Inativo') flgativo,
							 ind.dsindicador
				  FROM tbrecip_indicador ind
				 WHERE ind.idindicador = pr_idindica;
			rw_indicador cr_indicador%ROWTYPE;

      -- Cursor para verificar se existe outro indicador com o mesmo nome
      CURSOR cr_nmindicador IS
				SELECT 1
          FROM tbrecip_indicador ind
				 WHERE ind.nmindicador = pr_nmindica
				   AND ind.idindicador <> pr_idindica;
			rw_nmindicador cr_nmindicador%ROWTYPE;

      -- Cursor para verificar se indicador já está em uso
      CURSOR cr_tpindicador IS
				SELECT 1
				  FROM TBRECIP_PARAME_INDICA_COOP
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_PARAME_INDICA_CALCULO
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_INDICA_CALCULO
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_APURACAO_INDICA
	       WHERE idindicador = pr_idindica;
      rw_tpindicador cr_tpindicador%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

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

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Alteracao indicador de reciprocidade';
			vr_nrdrowid ROWID;
			vr_dsfativo VARCHAR2(10);

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

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

		  -- Abre indicador
		  OPEN cr_indicador;
			FETCH cr_indicador INTO rw_indicador;

		  IF cr_indicador%FOUND THEN
				IF (rw_indicador.tpindicador = 'A'          AND
					  rw_indicador.tpindicador <> pr_tpindica) OR
				   (rw_indicador.tpindicador IN ('Q','M')   AND
					  pr_tpindica = 'A')                     THEN
					-- Verifica se indicador já foi utilizado
					OPEN cr_tpindicador;
					FETCH cr_tpindicador INTO rw_tpindicador;

					-- Se encontrou está sendo utilizado
					IF cr_tpindicador%FOUND THEN
						-- Fecha cursores
				    CLOSE cr_indicador;
            CLOSE cr_tpindicador;
						-- Gera crítica
						vr_cdcritic := 0;
						vr_dscritic := 'Tipo não pode ser alterado se já estiver em uso!';
						-- Levanta exceção
						RAISE vr_exc_saida;
					END IF;
					-- Fecha cursor
					CLOSE cr_tpindicador;
				END IF;
			END IF;

			-- Fecha cursor
			CLOSE cr_indicador;

		  -- Abre cursor para verificar se existe indicador com o mesmo nome
		  OPEN cr_nmindicador;
			FETCH cr_nmindicador INTO rw_nmindicador;

 			-- Se existe
			IF cr_nmindicador%FOUND THEN
				-- Fecha cursor
				CLOSE cr_nmindicador;
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Atenção! Já existe outro indicador com este nome, favor revisar o cadastro!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
			-- Fecha cursor
			CLOSE cr_nmindicador;

      BEGIN
				UPDATE tbrecip_indicador ind
				SET ind.nmindicador = pr_nmindica,
				    ind.dsindicador = pr_dsindica,
						ind.tpindicador = pr_tpindica,
						ind.flgativo    = pr_flgativo
				WHERE ind.idindicador = pr_idindica;
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a gravação, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

      -- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Indicador',
																pr_dsdadant => to_char(rw_indicador.idindicador),
																pr_dsdadatu => to_char(pr_idindica));

		  -- Nome Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Nome Indicador',
																pr_dsdadant => to_char(rw_indicador.nmindicador),
																pr_dsdadatu => pr_nmindica);

		  -- Tipo Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Indicador',
																pr_dsdadant => to_char(rw_indicador.tpindicador),
																pr_dsdadatu => pr_tpindica);

      IF pr_flgativo = 0 THEN
				vr_dsfativo := 'Inativo';
			ELSE
				vr_dsfativo := 'Ativo';
			END IF;

		  -- Atividade Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Indicador',
																pr_dsdadant => to_char(rw_indicador.flgativo),
																pr_dsdadatu => vr_dsfativo);

		  -- Descrição Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Descricao Indicador',
																pr_dsdadant => to_char(rw_indicador.dsindicador),
																pr_dsdadatu => pr_dsindica);

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_altera_indicador;

	PROCEDURE pc_exclui_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
                               ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS                      --> Erros do processo
  BEGIN
    /* .............................................................................

    Programa: pc_exclui_indicador
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir indicador de reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

		  -- Verificar se indicador existe
		  CURSOR cr_indicador IS
			  SELECT ind.idindicador,
				       ind.nmindicador,
							 ind.tpindicador,
							 decode(flgativo,1,'Ativo','Inativo') flgativo,
							 ind.dsindicador
				  FROM tbrecip_indicador ind
				 WHERE ind.idindicador = pr_idindica;
			rw_indicador cr_indicador%ROWTYPE;

      -- Cursor para verificar se indicador já está em uso
      CURSOR cr_indicador_em_uso IS
				SELECT 1
				  FROM TBRECIP_PARAME_INDICA_COOP
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_PARAME_INDICA_CALCULO
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_INDICA_CALCULO
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_APURACAO_INDICA
	       WHERE idindicador = pr_idindica;
      rw_indicador_em_uso cr_indicador_em_uso%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

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

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Exclusao indicador de reciprocidade';
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

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

		  -- Abre indicador
		  OPEN cr_indicador;
			FETCH cr_indicador INTO rw_indicador;

		  -- Se não existe
		  IF cr_indicador%NOTFOUND THEN
					-- Fecha cursor
					CLOSE cr_indicador;
					-- Gera crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Indicador não encontrado!';
					-- Levanta exceção
					RAISE vr_exc_saida;
			END IF;

			-- Fecha cursor
			CLOSE cr_indicador;

			-- Verificar se indicador está em uso por alguma cooperativa
			OPEN cr_indicador_em_uso;
			FETCH cr_indicador_em_uso INTO rw_indicador_em_uso;

			-- Se encontrou está em uso
			IF cr_indicador_em_uso%FOUND THEN
 					-- Fecha cursor
					CLOSE cr_indicador;
					-- Gera crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Indicador não pode ser excluído! Motivo: Está em uso em pelo menos uma cooperativa.';
					-- Levanta exceção
					RAISE vr_exc_saida;
			END IF;

      BEGIN
				DELETE FROM tbrecip_indicador ind
				WHERE ind.idindicador = pr_idindica;
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a exclusão, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

	    -- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Indicador',
																pr_dsdadant => to_char(rw_indicador.idindicador),
																pr_dsdadatu => '');

		  -- Nome Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Nome Indicador',
																pr_dsdadant => to_char(rw_indicador.nmindicador),
																pr_dsdadatu => '');

		  -- Tipo Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Indicador',
																pr_dsdadant => to_char(rw_indicador.tpindicador),
																pr_dsdadatu => '');

		  -- Atividade Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Indicador',
																pr_dsdadant => to_char(rw_indicador.flgativo),
																pr_dsdadatu => '');

		  -- Descrição Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Descricao Indicador',
																pr_dsdadant => to_char(rw_indicador.dsindicador),
																pr_dsdadatu => '');

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_exclui_indicador;

	PROCEDURE pc_pesquisa_indicadores(pr_nmindicador   IN VARCHAR2           --> Descrição parcial do Indicador
																	 ,pr_xmllog        IN VARCHAR2           --> XML com informações de LOG
																	 ,pr_cdcritic     OUT PLS_INTEGER        --> Código da crítica
																	 ,pr_dscritic     OUT VARCHAR2           --> Descrição da crítica
																	 ,pr_retxml        IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
																	 ,pr_nmdcampo     OUT VARCHAR2           --> Nome do campo com erro
																	 ,pr_des_erro     OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_pesquisa_indicadores
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 07/03/2016                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar os indicadores pelo nome

    Alteracoes:
    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro  EXCEPTION;

      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      CURSOR cr_indicadores IS
         SELECT ind.idindicador
               ,ind.nmindicador
               ,decode(ind.tpindicador,'Q','Quantidade','M','Moeda','Adesão') tpindica
							 ,ind.tpindicador
           FROM TBRECIP_INDICADOR ind
          WHERE ind.flgativo = 1
					  AND UPPER(ind.nmindicador) LIKE UPPER('%' || NVL(pr_nmindicador,'') || '%')
						AND RCIP0001.fn_indicador_valido(pr_idindicador => ind.idindicador) = 'S';

    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><indicadores></indicadores></Root>');

      FOR rw_indicadores IN cr_indicadores LOOP
        -- Criar nodo filho
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/indicadores'
                                            ,XMLTYPE('<indicador>'
                                                   ||'  <idindicador>'||rw_indicadores.idindicador||'</idindicador>'
                                                   ||'  <nmindicador>'||UPPER(rw_indicadores.nmindicador)||'</nmindicador>'
                                                   ||'  <tpindicador>'||UPPER(rw_indicadores.tpindicador)||'</tpindicador>'
                                                   ||'  <tpindica>'||UPPER(rw_indicadores.tpindica)||'</tpindica>'
                                                   ||'</indicador>'));
      END LOOP;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (TELA_PARIDR.pc_pesquisa_indicadores): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_pesquisa_indicadores;
  
  PROCEDURE pc_pesquisa_vinculacoes(pr_nmvinculacao  IN VARCHAR2           --> Descrição parcial do Indicador
																	 ,pr_xmllog        IN VARCHAR2           --> XML com informações de LOG
																	 ,pr_cdcritic     OUT PLS_INTEGER        --> Código da crítica
																	 ,pr_dscritic     OUT VARCHAR2           --> Descrição da crítica
																	 ,pr_retxml        IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
																	 ,pr_nmdcampo     OUT VARCHAR2           --> Nome do campo com erro
																	 ,pr_des_erro     OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_pesquisa_vinculacoes
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andre Clemer
    Data    : 17/08/2018                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar as vinculacoes pelo nome

    Alteracoes:
    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro  EXCEPTION;

      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      CURSOR cr_vinculacoes IS
         SELECT vin.idvinculacao
               ,vin.nmvinculacao
           FROM tbrecip_vinculacao vin
          WHERE vin.flgativo = 1
					  AND UPPER(vin.nmvinculacao) LIKE UPPER('%' || NVL(pr_nmvinculacao,'') || '%');

    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><vinculacoes></vinculacoes></Root>');

      FOR rw_vinculacoes IN cr_vinculacoes LOOP
        -- Criar nodo filho
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/vinculacoes'
                                            ,XMLTYPE('<vinculacao>'
                                                   ||'  <idvinculacao>'||rw_vinculacoes.idvinculacao||'</idvinculacao>'
                                                   ||'  <nmvinculacao>'||UPPER(rw_vinculacoes.nmvinculacao)||'</nmvinculacao>'
                                                   ||'</vinculacao>'));
      END LOOP;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (TELA_PARIDR.pc_pesquisa_indicadores): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_pesquisa_vinculacoes;

	PROCEDURE pc_pesquisa_produtos(pr_dsproduto     IN VARCHAR2           --> Descrição parcial do Produto
														  	,pr_xmllog        IN VARCHAR2           --> XML com informações de LOG
															  ,pr_cdcritic     OUT PLS_INTEGER        --> Código da crítica
															  ,pr_dscritic     OUT VARCHAR2           --> Descrição da crítica
															  ,pr_retxml        IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
															  ,pr_nmdcampo     OUT VARCHAR2           --> Nome do campo com erro
															  ,pr_des_erro     OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_pesquisa_produtos
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 07/03/2016                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar os produtos pela descrição

    Alteracoes:
    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro  EXCEPTION;

      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      CURSOR cr_produtos IS
        SELECT prd.cdproduto
              ,prd.dsproduto
          FROM TBCC_PRODUTO prd
         WHERE UPPER(prd.dsproduto) LIKE UPPER('%' || NVL(pr_dsproduto,'') || '%');

    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><produtos></produtos></Root>');

      FOR rw_produtos IN cr_produtos LOOP
        -- Criar nodo filho
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/produtos'
                                            ,XMLTYPE('<produto>'
                                                   ||'  <cdproduto>'||rw_produtos.cdproduto||'</cdproduto>'
                                                   ||'  <dsproduto>'||UPPER(rw_produtos.dsproduto)||'</dsproduto>'
                                                   ||'</produto>'));
      END LOOP;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (TELA_PARIDR.pc_pesquisa_produtos): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_pesquisa_produtos;

	PROCEDURE pc_valida_indicador(pr_idindica IN INTEGER            --> Indicador
		                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
															 ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
															 ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
														 	 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
															 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
															 ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_valida_indicador
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Março - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para validar indicador inserido

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_indicador IS
				SELECT upper(nmindicador) nmindicador
							,tpindicador
					FROM TBRECIP_INDICADOR
				 WHERE idindicador = pr_idindica
					 AND flgativo = 1
					AND RCIP0001.fn_indicador_valido(pr_idindicador => idindicador) = 'S';
			rw_indicador cr_indicador%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

    BEGIN

      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      OPEN cr_indicador;
			FETCH cr_indicador INTO rw_indicador;

      IF cr_indicador%NOTFOUND THEN
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Indicador não cadastrado!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

			gene0007.pc_insere_tag(pr_xml      => pr_retxml
														,pr_tag_pai  => 'Dados'
														,pr_posicao  => 0
														,pr_tag_nova => 'indicador'
														,pr_tag_cont => NULL
														,pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml      => pr_retxml
														,pr_tag_pai  => 'indicador'
														,pr_posicao  => vr_auxconta
														,pr_tag_nova => 'nmindicador'
														,pr_tag_cont => to_char(rw_indicador.nmindicador)
														,pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml      => pr_retxml
														,pr_tag_pai  => 'indicador'
														,pr_posicao  => vr_auxconta
														,pr_tag_nova => 'tpindicador'
														,pr_tag_cont => to_char(rw_indicador.tpindicador)
														,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_valida_indicador;

	PROCEDURE pc_valida_produto(pr_cdproduto IN INTEGER           --> Produto
														 ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
														 ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
														 ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
														 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
														 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
														 ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_valida_produto
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Março - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para validar produto inserido

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados do produto pelo código
      CURSOR cr_produto IS
				SELECT upper(dsproduto) dsproduto
					FROM TBCC_PRODUTO
				 WHERE cdproduto = pr_cdproduto;
			rw_produto cr_produto%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

    BEGIN

      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      OPEN cr_produto;
			FETCH cr_produto INTO rw_produto;

      IF cr_produto%NOTFOUND THEN
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Produto não cadastrado!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

			gene0007.pc_insere_tag(pr_xml      => pr_retxml
														,pr_tag_pai  => 'Dados'
														,pr_posicao  => 0
														,pr_tag_nova => 'produto'
														,pr_tag_cont => NULL
														,pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml      => pr_retxml
														,pr_tag_pai  => 'produto'
														,pr_posicao  => vr_auxconta
														,pr_tag_nova => 'dsproduto'
														,pr_tag_cont => to_char(rw_produto.dsproduto)
														,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_valida_produto;
  
  PROCEDURE pc_valida_vinculacao(pr_idvinculacao IN INTEGER        --> Vinculacao
                                ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_valida_vinculacao
    Sistema : Ayllos Web
    Autor   : Andre Clemer - Supero
    Data    : Agosto - 2018.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para validar vinculacao inserida

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados do produto pelo código
      CURSOR cr_vinculacao IS
				SELECT upper(nmvinculacao) nmvinculacao
					FROM tbrecip_vinculacao
				 WHERE idvinculacao = pr_idvinculacao
					 AND tbrecip_vinculacao.flgativo = 1;
			rw_vinculacao cr_vinculacao%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

    BEGIN

      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      OPEN cr_vinculacao;
			FETCH cr_vinculacao INTO rw_vinculacao;

      IF cr_vinculacao%NOTFOUND THEN
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Vinculação não cadastrada!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

			gene0007.pc_insere_tag(pr_xml      => pr_retxml
														,pr_tag_pai  => 'Dados'
														,pr_posicao  => 0
														,pr_tag_nova => 'vinculacao'
														,pr_tag_cont => NULL
														,pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml      => pr_retxml
														,pr_tag_pai  => 'vinculacao'
														,pr_posicao  => vr_auxconta
														,pr_tag_nova => 'nmvinculacao'
														,pr_tag_cont => to_char(rw_vinculacao.nmvinculacao)
														,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_valida_vinculacao;

	PROCEDURE pc_insere_param_indica(pr_cdcooper IN INTEGER            --> Cooperativa
		                              ,pr_idindica IN INTEGER            --> Id. do indicador
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
																	,pr_vlminimo IN NUMBER             --> Valor mínimo
																	,pr_vlmaximo IN NUMBER             --> Valor máximo
																	,pr_perscore IN NUMBER             --> Percentual de score
																	,pr_pertoler IN NUMBER             --> Percentual de tolerância
                                  ,pr_perpeso  IN NUMBER             --> Percentual peso
                                  ,pr_perdesc  IN NUMBER             --> Percentual de desconto
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_insere_param_indica
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Março - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para inserir parametros por cooperativa de indicadores de
		            reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

		  -- Verificar se já existe parametrização
		  CURSOR cr_param_exis IS
			  SELECT 1
				  FROM tbrecip_parame_indica_coop indp
				 WHERE indp.cdcooper = pr_cdcooper
				   AND indp.idindicador = pr_idindica
					 AND indp.cdproduto = pr_cdprodut
					 AND indp.inpessoa = pr_inpessoa;
		  rw_param_exis cr_param_exis%ROWTYPE;

			-- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

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

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Inclusao parametro de indicador de reciprocidade';
			vr_nrdrowid ROWID;
			vr_inpessoa VARCHAR2(10);

    BEGIN

		  gene0001.pc_informa_acesso(pr_module => 'TELA_PARIDR');

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
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Verifica se já existe parametrização
		  OPEN cr_param_exis;
			FETCH cr_param_exis INTO rw_param_exis;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

			IF cr_param_exis%FOUND THEN
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Parametrização existente! Favor selecionar outra combinação ' ||
				               'de ''Indicador'', ''Produto'' e ''Tipo de Pessoa'' para a Cooperativa!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

      BEGIN
				INSERT INTO tbrecip_parame_indica_coop(cdcooper, idindicador, cdproduto, inpessoa, vlminimo, vlmaximo, perscore, pertolera, vlpercentual_peso, vlpercentual_desconto, flgativo)
				                       VALUES(pr_cdcooper, pr_idindica, pr_cdprodut, pr_inpessoa, pr_vlminimo, pr_vlmaximo, pr_perscore, pr_pertoler, pr_perpeso, pr_perdesc, 1);
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a gravação, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

			-- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

 		  -- Cooperativa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cooperativa',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_cdcooper));


		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Indicador',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_idindica));

		  -- Cód. do produto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cod. do produto',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_cdprodut));

      IF pr_inpessoa = 1 THEN
				vr_inpessoa := 'Fisica';
			ELSE
				vr_inpessoa := 'Juridica';
			END IF;

		  -- Tipo Pessoa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Pessoa',
																pr_dsdadant => ' ',
																pr_dsdadatu => vr_inpessoa);

		  -- Atividade Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Indicador',
																pr_dsdadant => ' ',
																pr_dsdadatu => 'Ativo');

		  -- Valor Minimo
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Minimo',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_vlminimo, 'fm999g999g999g990d00'));

		  -- Valor Maximo
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Maximo',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_vlmaximo, 'fm999g999g999g990d00'));

		  -- Percentual Score
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Score',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_perscore, 'fm990d00') || '%');

		  -- Percentual Tolerancia
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Tolerancia',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_pertoler, 'fm990d00') || '%');

		  -- Percentual Peso
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Peso',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_perpeso, 'fm990d00') || '%');

		  -- Percentual Desconto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Desconto',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_perdesc, 'fm990d00') || '%');


      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;
	END pc_insere_param_indica;
  
  PROCEDURE pc_insere_param_vinculacao(pr_cdcooper IN INTEGER            --> Cooperativa
		                              ,pr_idvinculacao IN INTEGER            --> Id. da vinculacao
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
                                  ,pr_perpeso  IN NUMBER             --> Percentual peso
                                  ,pr_perdesc  IN NUMBER             --> Percentual de desconto
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_insere_param_vinculacao
    Sistema : Ayllos Web
    Autor   : Andre Clemer
    Data    : Agosto - 2018.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para inserir parametros por cooperativa de vinculacao de
		            reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

		  -- Verificar se já existe parametrização
		  CURSOR cr_param_exis IS
			  SELECT 1
				  FROM tbrecip_vinculacao_parame_coop vinp
				 WHERE vinp.cdcooper = pr_cdcooper
				   AND vinp.idvinculacao_reciproci = pr_idvinculacao
					 AND vinp.cdproduto = pr_cdprodut
					 AND vinp.inpessoa = pr_inpessoa;
		  rw_param_exis cr_param_exis%ROWTYPE;

			-- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

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

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Inclusao parametro de indicador de reciprocidade';
			vr_nrdrowid ROWID;
			vr_inpessoa VARCHAR2(10);

    BEGIN

		  gene0001.pc_informa_acesso(pr_module => 'TELA_PARIDR');

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
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Verifica se já existe parametrização
		  OPEN cr_param_exis;
			FETCH cr_param_exis INTO rw_param_exis;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

			IF cr_param_exis%FOUND THEN
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Parametrização existente! Favor selecionar outra combinação ' ||
				               'de ''Vinculacao'', ''Produto'' e ''Tipo de Pessoa'' para a Cooperativa!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

      BEGIN
				INSERT INTO tbrecip_vinculacao_parame_coop(cdcooper, idvinculacao_reciproci, cdproduto, inpessoa, vlpercentual_peso, vlpercentual_desconto)
				                       VALUES(pr_cdcooper, pr_idvinculacao, pr_cdprodut, pr_inpessoa, pr_perpeso, pr_perdesc);
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a gravação, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

			-- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

 		  -- Cooperativa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cooperativa',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_cdcooper));


		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Vinculacao',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_idvinculacao));

		  -- Cód. do produto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cod. do produto',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_cdprodut));

      IF pr_inpessoa = 1 THEN
				vr_inpessoa := 'Fisica';
			ELSE
				vr_inpessoa := 'Juridica';
			END IF;

		  -- Tipo Pessoa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Pessoa',
																pr_dsdadant => ' ',
																pr_dsdadatu => vr_inpessoa);

		  -- Atividade Vinculacao
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Vinculacao',
																pr_dsdadant => ' ',
																pr_dsdadatu => 'Ativo');

		  -- Percentual Peso
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Peso',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_perpeso, 'fm990d00') || '%');

		  -- Percentual Desconto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Desconto',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_perdesc, 'fm990d00') || '%');


      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;
	END pc_insere_param_vinculacao;

	PROCEDURE pc_altera_param_indica(pr_cdcooper IN INTEGER            --> Cooperativa
		                              ,pr_idindica IN INTEGER            --> Id. do indicador
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
																	,pr_vlminimo IN NUMBER             --> Valor mínimo
																	,pr_vlmaximo IN NUMBER             --> Valor máximo
																	,pr_perscore IN NUMBER             --> Percentual de score
																	,pr_pertoler IN NUMBER             --> Percentual de tolerância
                                  ,pr_perpeso  IN NUMBER             --> Percentual peso
                                  ,pr_perdesc  IN NUMBER             --> Percentual de desconto
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_altera_param_indica
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Março - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para inserir parametros por cooperativa de indicadores de
		            reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

		  -- Verificar se existe parametrização
		  CURSOR cr_param_exis IS
			  SELECT indp.vlminimo
              ,indp.vlmaximo
              ,indp.perscore
              ,indp.pertolera
              ,indp.vlpercentual_peso
              ,indp.vlpercentual_desconto
				  FROM tbrecip_parame_indica_coop indp
				 WHERE indp.cdcooper = pr_cdcooper
				   AND indp.idindicador = pr_idindica
					 AND indp.cdproduto = pr_cdprodut
					 AND indp.inpessoa = pr_inpessoa;
		  rw_param_exis cr_param_exis%ROWTYPE;

			-- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

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

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Alteracao parametro de indicador de reciprocidade';
			vr_nrdrowid ROWID;
			vr_inpessoa VARCHAR2(10);

    BEGIN

		  gene0001.pc_informa_acesso(pr_module => 'TELA_PARIDR');

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
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Verifica se já existe parametrização
		  OPEN cr_param_exis;
			FETCH cr_param_exis INTO rw_param_exis;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

			IF cr_param_exis%NOTFOUND THEN
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Parametrização não encontrada para a Cooperativa!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

      BEGIN
				UPDATE tbrecip_parame_indica_coop indp
				   SET vlminimo = pr_vlminimo
							,vlmaximo = pr_vlmaximo
							,perscore = pr_perscore
							,pertolera = pr_pertoler
              ,vlpercentual_peso = pr_perpeso
              ,vlpercentual_desconto = pr_perdesc
				 WHERE indp.cdcooper = pr_cdcooper
				   AND indp.idindicador = pr_idindica
					 AND indp.cdproduto = pr_cdprodut
					 AND indp.inpessoa = pr_inpessoa;

			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a gravação, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

			-- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

 		  -- Cooperativa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cooperativa',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_cdcooper));


		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Indicador',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_idindica));

		  -- Cód. do produto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cod. do produto',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_cdprodut));

      IF pr_inpessoa = 1 THEN
				vr_inpessoa := 'Fisica';
			ELSE
				vr_inpessoa := 'Juridica';
			END IF;

		  -- Tipo Pessoa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Pessoa',
																pr_dsdadant => ' ',
																pr_dsdadatu => vr_inpessoa);

		  -- Atividade Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Indicador',
																pr_dsdadant => ' ',
																pr_dsdadatu => 'Ativo');

		  -- Valor Minimo
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Minimo',
																pr_dsdadant => to_char(rw_param_exis.vlminimo, 'fm999g999g999g990d00'),
																pr_dsdadatu => to_char(pr_vlminimo, 'fm999g999g999g990d00'));

		  -- Valor Maximo
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Maximo',
																pr_dsdadant => to_char(rw_param_exis.vlmaximo, 'fm999g999g999g990d00'),
																pr_dsdadatu => to_char(pr_vlmaximo, 'fm999g999g999g990d00'));

		  -- Percentual Score
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Score',
																pr_dsdadant => to_char(rw_param_exis.perscore, 'fm990d00') || '%',
																pr_dsdadatu => to_char(pr_perscore, 'fm990d00') || '%');

		  -- Percentual Tolerancia
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Tolerancia',
																pr_dsdadant => to_char(rw_param_exis.pertolera, 'fm990d00') || '%',
																pr_dsdadatu => to_char(pr_pertoler, 'fm990d00') || '%');
                                
      -- Percentual Peso
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Peso',
																pr_dsdadant => to_char(rw_param_exis.vlpercentual_peso, 'fm990d00') || '%',
																pr_dsdadatu => to_char(pr_perpeso, 'fm990d00') || '%');
                                
      -- Percentual Desconto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Desconto',
																pr_dsdadant => to_char(rw_param_exis.vlpercentual_desconto, 'fm990d00') || '%',
																pr_dsdadatu => to_char(pr_perdesc, 'fm990d00') || '%');


      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;
	END pc_altera_param_indica;
  
  PROCEDURE pc_altera_param_vinculacao(pr_cdcooper IN INTEGER            --> Cooperativa
		                              ,pr_idvinculacao IN INTEGER            --> Id. da vinculacao
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
                                  ,pr_perpeso  IN NUMBER             --> Percentual peso
                                  ,pr_perdesc  IN NUMBER             --> Percentual de desconto
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_altera_param_vinculacao
    Sistema : Ayllos Web
    Autor   : Andre Clemer
    Data    : Agosto - 2018.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para inserir parametros por cooperativa de vinculacoes de
		            reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

		  -- Verificar se existe parametrização
		  CURSOR cr_param_exis IS
			  SELECT vinp.vlpercentual_peso
              ,vinp.vlpercentual_desconto
				  FROM tbrecip_vinculacao_parame_coop vinp
				 WHERE vinp.cdcooper = pr_cdcooper
				   AND vinp.idvinculacao_reciproci = pr_idvinculacao
					 AND vinp.cdproduto = pr_cdprodut
					 AND vinp.inpessoa = pr_inpessoa;
		  rw_param_exis cr_param_exis%ROWTYPE;

			-- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

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

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Alteracao parametro de vinculacao de reciprocidade';
			vr_nrdrowid ROWID;
			vr_inpessoa VARCHAR2(10);

    BEGIN

		  gene0001.pc_informa_acesso(pr_module => 'TELA_PARIDR');

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
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  BEGIN
				UPDATE tbrecip_vinculacao_parame_coop vinp
				   SET vlpercentual_peso = pr_perpeso
              ,vlpercentual_desconto = pr_perdesc
				 WHERE vinp.cdcooper = pr_cdcooper
				   AND vinp.idvinculacao_reciproci = pr_idvinculacao
					 AND vinp.cdproduto = pr_cdprodut
					 AND vinp.inpessoa = pr_inpessoa;

			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a gravação, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

			-- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

 		  -- Cooperativa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cooperativa',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_cdcooper));


		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Vinculacao',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_idvinculacao));

		  -- Cód. do produto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cod. do produto',
																pr_dsdadant => ' ',
																pr_dsdadatu => to_char(pr_cdprodut));

      IF pr_inpessoa = 1 THEN
				vr_inpessoa := 'Fisica';
			ELSE
				vr_inpessoa := 'Juridica';
			END IF;

		  -- Tipo Pessoa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Pessoa',
																pr_dsdadant => ' ',
																pr_dsdadatu => vr_inpessoa);

		  -- Atividade Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Vinculacao',
																pr_dsdadant => ' ',
																pr_dsdadatu => 'Ativo');

      -- Percentual Peso
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Peso',
																pr_dsdadant => to_char(rw_param_exis.vlpercentual_peso, 'fm990d00') || '%',
																pr_dsdadatu => to_char(pr_perpeso, 'fm990d00') || '%');
                                
      -- Percentual Desconto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Desconto',
																pr_dsdadant => to_char(rw_param_exis.vlpercentual_desconto, 'fm990d00') || '%',
																pr_dsdadatu => to_char(pr_perdesc, 'fm990d00') || '%');


      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;
	END pc_altera_param_vinculacao;

	PROCEDURE pc_exclui_param_indica(pr_cdcooper IN INTEGER            --> Cooperativa
		                              ,pr_idindica IN INTEGER            --> Id. do indicador
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_exclui_param_indica
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Março - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir parametros por cooperativa de indicadores de
		            reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

		  -- Verificar se existe parametrização
		  CURSOR cr_param_exis IS
			  SELECT indp.vlminimo
              ,indp.vlmaximo
              ,indp.perscore
              ,indp.pertolera
				  FROM tbrecip_parame_indica_coop indp
				 WHERE indp.cdcooper = pr_cdcooper
				   AND indp.idindicador = pr_idindica
					 AND indp.cdproduto = pr_cdprodut
					 AND indp.inpessoa = pr_inpessoa;
		  rw_param_exis cr_param_exis%ROWTYPE;

			-- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

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

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Exclusao parametro de indicador de reciprocidade';
			vr_nrdrowid ROWID;
			vr_inpessoa VARCHAR2(10);

    BEGIN

		  gene0001.pc_informa_acesso(pr_module => 'TELA_PARIDR');

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
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Verifica se já existe parametrização
		  OPEN cr_param_exis;
			FETCH cr_param_exis INTO rw_param_exis;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

			IF cr_param_exis%NOTFOUND THEN
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Parametrização não encontrada para a Cooperativa!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

      BEGIN
				DELETE FROM tbrecip_parame_indica_coop indp
				 WHERE indp.cdcooper = pr_cdcooper
				   AND indp.idindicador = pr_idindica
					 AND indp.cdproduto = pr_cdprodut
					 AND indp.inpessoa = pr_inpessoa;

			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a gravação, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

			-- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

 		  -- Cooperativa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cooperativa',
																pr_dsdadant => to_char(pr_cdcooper),
																pr_dsdadatu => ' ');


		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Indicador',
																pr_dsdadant => to_char(pr_idindica),
																pr_dsdadatu => ' ');

		  -- Cód. do produto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cod. do produto',
																pr_dsdadant => to_char(pr_cdprodut),
																pr_dsdadatu => ' ');

      IF pr_inpessoa = 1 THEN
				vr_inpessoa := 'Fisica';
			ELSE
				vr_inpessoa := 'Juridica';
			END IF;

		  -- Tipo Pessoa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Pessoa',
																pr_dsdadant => vr_inpessoa,
																pr_dsdadatu => ' ');

		  -- Atividade Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Indicador',
																pr_dsdadant => 'Ativo',
																pr_dsdadatu => ' ');

		  -- Valor Minimo
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Minimo',
																pr_dsdadant => to_char(rw_param_exis.vlminimo, 'fm999g999g999g990d00'),
																pr_dsdadatu => ' ');

		  -- Valor Maximo
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Maximo',
																pr_dsdadant => to_char(rw_param_exis.vlmaximo, 'fm999g999g999g990d00'),
																pr_dsdadatu => ' ');

		  -- Percentual Score
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Score',
																pr_dsdadant => to_char(rw_param_exis.perscore, 'fm990d00') || '%',
																pr_dsdadatu => ' ');

		  -- Percentual Score
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Percentual Tolerancia',
																pr_dsdadant => to_char(rw_param_exis.pertolera, 'fm990d00') || '%',
																pr_dsdadatu => ' ');


      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;
	END pc_exclui_param_indica;
  
  PROCEDURE pc_exclui_param_vinculacao(pr_cdcooper IN INTEGER            --> Cooperativa
		                              ,pr_idvinculacao IN INTEGER            --> Id. da vinculacao
																	,pr_cdprodut IN INTEGER            --> Cód. do produto
																	,pr_inpessoa IN INTEGER            --> PF/PJ
																	,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																	,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_exclui_param_vinculacao
    Sistema : Ayllos Web
    Autor   : Andre Clemer
    Data    : Agosto - 2018.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir parametros por cooperativa de vinculacoes de
		            reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

		  -- Verificar se existe parametrização
		  CURSOR cr_param_exis IS
			  SELECT vinp.vlpercentual_peso
              ,vinp.vlpercentual_desconto
				  FROM tbrecip_vinculacao_parame_coop vinp
				 WHERE vinp.cdcooper = pr_cdcooper
				   AND vinp.idvinculacao_reciproci = pr_idvinculacao
					 AND vinp.cdproduto = pr_cdprodut
					 AND vinp.inpessoa = pr_inpessoa;
		  rw_param_exis cr_param_exis%ROWTYPE;

			-- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

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

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Exclusao parametro de vinculacao de reciprocidade';
			vr_nrdrowid ROWID;
			vr_inpessoa VARCHAR2(10);

    BEGIN

		  gene0001.pc_informa_acesso(pr_module => 'TELA_PARIDR');

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
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Verifica se já existe parametrização
		  OPEN cr_param_exis;
			FETCH cr_param_exis INTO rw_param_exis;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

			IF cr_param_exis%NOTFOUND THEN
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Parametrização não encontrada para a Cooperativa!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

      BEGIN
				DELETE FROM tbrecip_vinculacao_parame_coop indp
				 WHERE indp.cdcooper = pr_cdcooper
				   AND indp.idvinculacao_reciproci = pr_idvinculacao
					 AND indp.cdproduto = pr_cdprodut
					 AND indp.inpessoa = pr_inpessoa;

			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a gravação, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

			-- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

 		  -- Cooperativa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cooperativa',
																pr_dsdadant => to_char(pr_cdcooper),
																pr_dsdadatu => ' ');


		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Vinculacao',
																pr_dsdadant => to_char(pr_idvinculacao),
																pr_dsdadatu => ' ');

		  -- Cód. do produto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Cod. do produto',
																pr_dsdadant => to_char(pr_cdprodut),
																pr_dsdadatu => ' ');

      IF pr_inpessoa = 1 THEN
				vr_inpessoa := 'Fisica';
			ELSE
				vr_inpessoa := 'Juridica';
			END IF;

		  -- Tipo Pessoa
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Pessoa',
																pr_dsdadant => vr_inpessoa,
																pr_dsdadatu => ' ');

		  -- Atividade Vinculacao
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Vinculacao',
																pr_dsdadant => 'Ativo',
																pr_dsdadatu => ' ');

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;
	END pc_exclui_param_vinculacao;

END tela_paridr;
/
