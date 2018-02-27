CREATE OR REPLACE PACKAGE CECRED.TELA_COBEMP IS

  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0007
  --  Sistema  : Rotinas referentes a Portabilidade de Credito
  --  Sigla    : EMPR
  --  Autor    : Lucas Reinert
  --  Data     : Julho - 2015.                   Ultima atualizacao: 27/09/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Portabilidade de Credito
  --
  -- Alteracoes: 27/09/2016 - Inclusao de verificacao de contratos de acordos
  --                          nas procedures pc_verifica_gerar_boleto, Prj. 302 (Jean Michel).
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  --Tipo de Registro para Parametros da cobemp
  TYPE typ_reg_cobemp IS RECORD(
    nrconven crapprm.dsvlrprm%TYPE,
    nrdconta crapprm.dsvlrprm%TYPE,
    pzmaxvct crapprm.dsvlrprm%TYPE,
    pzbxavct crapprm.dsvlrprm%TYPE,
    vlrminpp crapprm.dsvlrprm%TYPE,
    vlrmintr crapprm.dsvlrprm%TYPE,
    dslinha1 crapprm.dsvlrprm%TYPE,
    dslinha2 crapprm.dsvlrprm%TYPE,
    dslinha3 crapprm.dsvlrprm%TYPE,
    dslinha4 crapprm.dsvlrprm%TYPE,
    dstxtsms crapprm.dsvlrprm%TYPE,
    dstxtema crapprm.dsvlrprm%TYPE,
    blqemibo crapprm.dsvlrprm%TYPE,
    qtmaxbol crapprm.dsvlrprm%TYPE,
    blqrsgcc crapprm.dsvlrprm%TYPE);

  tab_import tbepr_boleto_import%ROWTYPE;

  PROCEDURE pc_buscar_email(pr_nrdconta IN INTEGER
                           ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                           ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                           ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_buscar_telefone(pr_nrdconta IN INTEGER
                              ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                              ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                              ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                              ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);
                              
  PROCEDURE pc_buscar_celular(pr_nrdconta IN INTEGER
                             ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                             ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                             ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                             ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);                              
                             
  PROCEDURE pc_buscar_log(pr_nrdconta IN INTEGER
                         ,pr_nrdocmto IN INTEGER
                         ,pr_nrcnvcob IN INTEGER
                         ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                         ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                         ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                         ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                         ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                         ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2);

	PROCEDURE pc_buscar_boletos_contratos_w (pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 0         --> PA
																					,pr_nrctremp IN tbepr_cobranca.nrctremp%TYPE DEFAULT 0  --> Nr. do Contrato
																					,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0         --> Nr. da Conta
																					,pr_dtbaixai IN VARCHAR2                                --> Data de baixa inicial
																					,pr_dtbaixaf IN VARCHAR2                                --> Data de baixa final
																					,pr_dtemissi IN VARCHAR2                                --> Data de emiss�o inicial
																					,pr_dtemissf IN VARCHAR2                                --> Data de emiss�o final
																					,pr_dtvencti IN VARCHAR2                                --> Data de vencimento inicial
																					,pr_dtvenctf IN VARCHAR2                                --> Data de vencimento final
																					,pr_dtpagtoi IN VARCHAR2                                --> Data de pagamento inicial
																					,pr_dtpagtof IN VARCHAR2                                --> Data de pagamento final
																					,pr_nriniseq IN INTEGER                                 --> Registro inicial da listagem
																					,pr_nrregist IN INTEGER                                 --> Numero de registros p/ paginaca
																					,pr_xmllog   IN VARCHAR2                                --> XML com informa��es de LOG
																					,pr_cdcritic OUT PLS_INTEGER                            --> C�digo da cr�tica
																					,pr_dscritic OUT VARCHAR2                               --> Descri��o da cr�tica
																					,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
																					,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
																					,pr_des_erro OUT VARCHAR2);                             --> Erros do processo

  PROCEDURE pc_buscar_contratos_w (pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0         --> Nr. da Conta
																	,pr_nriniseq IN INTEGER                                 --> Registro inicial da listagem
																	,pr_nrregist IN INTEGER                                 --> Numero de registros p/ paginaca
																	,pr_xmllog   IN VARCHAR2                                --> XML com informa��es de LOG
																	,pr_cdcritic OUT PLS_INTEGER                            --> C�digo da cr�tica
																	,pr_dscritic OUT VARCHAR2                               --> Descri��o da cr�tica
																	,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2);

	PROCEDURE pc_verifica_gerar_boleto (pr_nrctacob IN crapass.nrdconta%TYPE                   --> Nr. da Conta Cob.
		                                 ,pr_nrdconta IN crapass.nrdconta%TYPE                   --> Nr. da Conta
																		 ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE                   --> Nr. do Conv�nio de Cobran�a
																	 	 ,pr_nrctremp IN crapcob.nrctremp%TYPE                   --> Nr. do Contrato
																		 ,pr_xmllog   IN VARCHAR2                                --> XML com informa��es de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER                            --> C�digo da cr�tica
																		 ,pr_dscritic OUT VARCHAR2                               --> Descri��o da cr�tica
																		 ,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
																		 ,pr_des_erro OUT VARCHAR2);                             --> Erros do processo

  PROCEDURE pc_busca_texto_sms(pr_nrdconta IN INTEGER
                              ,pr_lindigit IN VARCHAR2
                              ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                              ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_gerar_pdf_boletos_w (pr_nrdconta IN crapass.nrdconta%TYPE          --> Nr. da Conta
																	 ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE          --> Nr. do convenio
																	 ,pr_nrdocmto IN crapcob.nrdocmto%TYPE          --> Nr. Docmto
																	 ,pr_xmllog   IN VARCHAR2                       --> XML com informa��es de LOG
																	 ,pr_cdcritic OUT PLS_INTEGER                   --> C�digo da cr�tica
																	 ,pr_dscritic OUT VARCHAR2                      --> Descri��o da cr�tica
																	 ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
																	 ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
																	 ,pr_des_erro OUT VARCHAR2);                    --> Erros do processo

  PROCEDURE pc_busca_prazo_venc(pr_inprejuz IN INTEGER                        --> Indicador de prejuizo
                               ,pr_xmllog   IN VARCHAR2                       --> XML com informa��es de LOG
															 ,pr_cdcritic OUT PLS_INTEGER                   --> C�digo da cr�tica
															 ,pr_dscritic OUT VARCHAR2                      --> Descri��o da cr�tica
															 ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
															 ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
															 ,pr_des_erro OUT VARCHAR2);                    --> Erros do processo


PROCEDURE pc_lista_pa(pr_cdagenci IN INTEGER          
                       ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                       ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                       ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                       ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                       ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);
  
  PROCEDURE pc_busca_aval(pr_nrdconta   IN INTEGER --> Numero conta
                         ,pr_nrctremp   IN INTEGER --> Numero contrato
                         ,pr_xmllog     IN VARCHAR2 --> XML com informa��es de LOG
                         ,pr_cdcritic  OUT PLS_INTEGER --> C�digo da cr�tica
                         ,pr_dscritic  OUT VARCHAR2 --> Descri��o da cr�tica
                         ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_desconto(pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                             ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);        --> Erros do processo

	PROCEDURE pc_busca_arquivos(pr_dtarqini   IN VARCHAR2       --> Data inicial
                             ,pr_dtarqfim   IN VARCHAR2       --> Data final
                             ,pr_nmarquiv   IN VARCHAR2       --> Nome do arquivo
                             ,pr_nriniseq   IN INTEGER        --> Registro inicial da listagem
                             ,pr_nrregist   IN INTEGER        --> Numero de registros p/ paginaca
                             ,pr_xmllog     IN VARCHAR2       --> XML com informa��es de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER    --> C�digo da cr�tica
                             ,pr_dscritic  OUT VARCHAR2       --> Descri��o da cr�tica
                             ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2);     --> Erros do processo

	PROCEDURE pc_importar_arquivo(pr_nmarquiv   IN VARCHAR2       --> Nome do arquivo
                               ,pr_flgreimp   IN INTEGER        --> Reimportacao: 0-Nao / 1-Sim
                               ,pr_xmllog     IN VARCHAR2       --> XML com informa��es de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER    --> C�digo da cr�tica
                               ,pr_dscritic  OUT VARCHAR2       --> Descri��o da cr�tica
                               ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2);     --> Erros do processo
  
  PROCEDURE pc_gera_relatorio(pr_idarquiv   IN INTEGER        --> Nome do arquivo
                             ,pr_flgcriti   IN INTEGER        --> Flag somente critica (0 - Completo / 1 - Somente criticas)
                             ,pr_xmllog     IN VARCHAR2       --> XML com informa��es de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER    --> C�digo da cr�tica
                             ,pr_dscritic  OUT VARCHAR2       --> Descri��o da cr�tica
                             ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2);     --> Erros do processo
  
  PROCEDURE pc_gera_boletagem(pr_idarquiv   IN INTEGER        --> Nome do arquivo
                             ,pr_xmllog     IN VARCHAR2       --> XML com informa��es de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER    --> C�digo da cr�tica
                             ,pr_dscritic  OUT VARCHAR2       --> Descri��o da cr�tica
                             ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2);     --> Erros do processo
                             
  PROCEDURE pc_gera_boleto_contrato(pr_cdcooper IN  crapcob.cdcooper%TYPE   --> C�digo da cooperativa;
																	 ,pr_nrdconta IN  crapcob.nrdconta%TYPE   --> Conta do cooperado do contrato;
																	 ,pr_nrctremp IN  crapcob.nrctremp%TYPE   --> N�mero do contrato de empr�stimo;
																	 ,pr_dtmvtolt IN  crapcob.dtmvtolt%TYPE   --> Data do movimento;
																	 ,pr_tpparepr IN  NUMBER                  --> Tipo de parcela 1 = Parcela Normal, 2 = Total do atraso 3 = Parcial do atraso 4 = Quita��o do contrato;
																	 ,pr_dsparepr IN  VARCHAR2 DEFAULT NULL  /* Descri��o das parcelas do empr�stimo �par1,par2,par..., parN�;
																	 																						Obs: empr�stimo TR => NULL;
																	 																						Obs2: Quando for ref a v�rias parcelas do contrato, parcela = NULL;
																	 																						Obs3: Quando for quita��o do contrato, parcela = 0; */
																	 ,pr_dtvencto IN  crapcob.dtvencto%TYPE   --> Vencimento do boleto;
																	 ,pr_vlparepr IN  crappep.vlparepr%TYPE   --> Valor da parcela;
																	 ,pr_cdoperad IN  crapcob.cdoperad%TYPE   --> C�digo do operador;
																	 ,pr_nmdatela IN VARCHAR2                 --> Nome da tela
														       ,pr_idorigem IN INTEGER                  --> ID Origem
                                   ,pr_nrcpfava IN NUMBER DEFAULT 0         --> CPF do avalista
																	 ,pr_idarquiv IN INTEGER DEFAULT 0        --> Id do arquivo (boletagem Massiva)
                                   ,pr_idboleto IN INTEGER DEFAULT 0        --> Id do boleto no arquivo (boletagem Massiva)
                                   ,pr_peracres IN NUMBER DEFAULT 0       --> Percentual de Desconto
                                   ,pr_perdesco IN NUMBER DEFAULT 0       --> Percentual de Acrescimo
                                   ,pr_vldescto IN NUMBER DEFAULT 0       --> Valor do desconto
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> C�digo da cr�tica
																	 ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descri��o da cr�tica
                                   
  PROCEDURE pc_calcular_saldo_contrato (pr_cdcooper   IN  crapcop.cdcooper%TYPE,  --> Codigo da Cooperativa
                                        pr_nrdconta   IN  crapass.cdcooper%TYPE,  --> N�mero da Conta
                                        pr_cdorigem   IN  INTEGER,                --> Origem
                                        pr_nrctremp   IN  crapepr.nrctremp%TYPE,  --> Numero do Contrato
                                        pr_rw_crapdat IN  btch0001.cr_crapdat%ROWTYPE, --> Datas da cooperativa
                                        pr_vllimcre   IN crapass.vllimcre%TYPE,   --> Limite de credito do cooperado     
                                        pr_vlsdeved  OUT  NUMBER,                 --> Valor Saldo Devedor
                                        pr_vlsdprej  OUT  NUMBER,                 --> Valor Saldo Prejuizo
                                        pr_vlatraso  OUT  NUMBER,                 --> Valor Atraso
                                        pr_cdcritic  OUT  NUMBER,                 --> C�digo da Cr�tica
                                        pr_dscritic  OUT  VARCHAR2);                           
  
  PROCEDURE pc_gera_arquivo_parca_web(pr_idarquiv   IN INTEGER        --> Nome do arquivo
                                     ,pr_xmllog     IN VARCHAR2       --> XML com informa��es de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER    --> C�digo da cr�tica
                                     ,pr_dscritic  OUT VARCHAR2       --> Descri��o da cr�tica
                                     ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2);     --> Erros do processo
	                                      
  PROCEDURE pc_gera_arquivo_parca(pr_idarquiv   IN INTEGER               --> Nome do arquivo
                                 ,pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                 ,pr_cdoperad   IN crapope.cdoperad%TYPE --> Codigo do operador
                                 ,pr_nmarquiv  OUT VARCHAR2              --> Nome do arquivo
                                 ,pr_cdcritic  OUT PLS_INTEGER           --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2);            --> Descri��o da cr�tica
  
END TELA_COBEMP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_COBEMP IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA0001
  --  Sistema  : Rotinas da Tela Ayllos Web COBEMP
  --  Sigla    : TELA
  --  Autor    : Daniel Zimmermann
  --  Data     : Agosto - 2015.                   Ultima atualizacao: 14/11/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas da Tela COBEMP
  --
  -- Alteracoes: 27/09/2016 - Inclusao de verificacao de contratos de acordos
  --                          nas procedures pc_verifica_gerar_boleto, Prj. 302 (Jean Michel).
  --
  --             14/11/2017 - Ajsute para devolver informacao de liquidacao do contrato (Jonata - RKAM P364).
  ---------------------------------------------------------------------------

  PROCEDURE pc_buscar_email(pr_nrdconta IN INTEGER
                           ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                           ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                           ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_buscar_email
    Sistema : Cobran�a - Cooperativa de Credito
    Sigla   : COB
    Autor   : Daniel Zimmermann
    Data    : Agosto/15.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina busca email boletos emprestimos.

    Observacao: -----

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_emails(pr_cdcooper IN crapcop.cdcooper%TYPE, pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT DISTINCT dsdemail, secpscto, nmpescto
          FROM crapcem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
        UNION
        SELECT DISTINCT dsemail, ' ', nmcontato
          FROM tbepr_cobranca
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dsemail IS NOT NULL;

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_contador INTEGER := 0; -- Contador p/ posicao no XML
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      vr_flgresgi BOOLEAN := FALSE;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Verifica se a cooperativa esta cadastrada
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      FOR rw_emails IN cr_emails(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta) LOOP

        vr_contador := vr_contador + 1;

        IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Dados',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'email',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'email',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'dsdemail',
                                 pr_tag_cont => TO_CHAR(rw_emails.dsdemail),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'email',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'secpscto',
                                 pr_tag_cont => TO_CHAR(rw_emails.secpscto),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'email',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nmpescto',
                                 pr_tag_cont => TO_CHAR(rw_emails.nmpescto),
                                 pr_des_erro => vr_dscritic);

          vr_auxconta := vr_auxconta + 1;
        END IF;

        vr_flgresgi := TRUE;

      END LOOP;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Qtdregis',
                             pr_tag_cont => vr_contador,
                             pr_des_erro => vr_dscritic);

      IF NOT vr_flgresgi THEN
        vr_dscritic := 'Nenhum E-mail localizado!';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_buscar_email;

  PROCEDURE pc_buscar_telefone(pr_nrdconta IN INTEGER
                              ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                              ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                              ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                              ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_buscar_email
    Sistema : Cobran�a - Cooperativa de Credito
    Sigla   : COB
    Autor   : Daniel Zimmermann
    Data    : Agosto/15.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina busca telefone boletos emprestimos.

    Observacao: -----

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_telefones(pr_cdcooper IN crapcop.cdcooper%TYPE, pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT DISTINCT nrdddtfc, nrtelefo, nrdramal, tptelefo, nmpescto, cdopetfn
          FROM craptfc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrtelefo > 0
--           AND cdopetfn > 0
        UNION
        SELECT DISTINCT nrddd_sms, nrtel_sms, 0 ramal, 0, nmcontato, 0
          FROM tbepr_cobranca
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrtel_sms > 0;

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_contador INTEGER := 0; -- Contador p/ posicao no XML
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      vr_flgresgi BOOLEAN := FALSE;

      vr_nmopetfn VARCHAR2(100);
      vr_destptfc VARCHAR2(100);

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      FOR rw_telefones IN cr_telefones(pr_cdcooper => vr_cdcooper,
                                       pr_nrdconta => pr_nrdconta) LOOP

        vr_contador := vr_contador + 1;

        IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN

          vr_nmopetfn := ' ';

          IF rw_telefones.cdopetfn > 0 THEN
            CASE rw_telefones.cdopetfn
              WHEN 10 THEN
                vr_nmopetfn := 'VIVO';
              WHEN 11 THEN
                vr_nmopetfn := 'TIM';
              WHEN 14 THEN
                vr_nmopetfn := 'OI/BRASIL TEL.';
              WHEN 21 THEN
                vr_nmopetfn := 'EMBRATEL';
              WHEN 23 THEN
                vr_nmopetfn := 'INTELIG';
              WHEN 36 THEN
                vr_nmopetfn := 'CLARO';
            END CASE;
          END IF;

          vr_destptfc := ' ';

          IF rw_telefones.tptelefo > 0 THEN
            CASE rw_telefones.tptelefo
              WHEN 1 THEN
                vr_destptfc := 'RESIDENCIAL';
              WHEN 2 THEN
                vr_destptfc := 'CELULAR';
              WHEN 3 THEN
                vr_destptfc := 'COMERCIAL';
              WHEN 4 THEN
                vr_destptfc := 'CONTATO';
            END CASE;
          END IF;

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Dados',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'telefone',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nrdddtfc',
                                 pr_tag_cont => TO_CHAR(rw_telefones.nrdddtfc),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nrtelefo',
                                 pr_tag_cont => TO_CHAR(rw_telefones.nrtelefo),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nrdramal',
                                 pr_tag_cont => TO_CHAR(rw_telefones.nrdramal),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'tptelefo',
                                 pr_tag_cont => vr_destptfc,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nmpescto',
                                 pr_tag_cont => TO_CHAR(rw_telefones.nmpescto),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nmopetfn',
                                 pr_tag_cont => vr_nmopetfn,
                                 pr_des_erro => vr_dscritic);

          vr_auxconta := vr_auxconta + 1;
        END IF;

        vr_flgresgi := TRUE;

      END LOOP;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Qtdregis',
                             pr_tag_cont => vr_contador,
                             pr_des_erro => vr_dscritic);

      IF NOT vr_flgresgi THEN
        vr_dscritic := 'Nenhum Numero de Telefone Localizado!';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_buscar_telefone;
  
  PROCEDURE pc_buscar_celular(pr_nrdconta IN INTEGER
                             ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                             ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                             ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                             ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_buscar_celular
    Sistema : Cobran�a - Cooperativa de Credito
    Sigla   : COB
    Autor   : Rafael Cechet
    Data    : Novembro/15.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina busca telefone celulares boletos emprestimos.

    Observacao: -----

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_telefones(pr_cdcooper IN crapcop.cdcooper%TYPE, pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT DISTINCT nrdddtfc, nrtelefo, nrdramal, tptelefo, nmpescto, cdopetfn
          FROM craptfc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrtelefo > 0
           AND cdopetfn > 0
        UNION
        SELECT DISTINCT nrddd_sms, nrtel_sms, 0 ramal, 0, nmcontato, 0
          FROM tbepr_cobranca
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrtel_sms > 0;

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_contador INTEGER := 0; -- Contador p/ posicao no XML
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      vr_flgresgi BOOLEAN := FALSE;

      vr_nmopetfn VARCHAR2(100);
      vr_destptfc VARCHAR2(100);

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      FOR rw_telefones IN cr_telefones(pr_cdcooper => vr_cdcooper,
                                       pr_nrdconta => pr_nrdconta) LOOP

        vr_contador := vr_contador + 1;

        IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN

          vr_nmopetfn := ' ';

          IF rw_telefones.cdopetfn > 0 THEN
            CASE rw_telefones.cdopetfn
              WHEN 10 THEN
                vr_nmopetfn := 'VIVO';
              WHEN 11 THEN
                vr_nmopetfn := 'TIM';
              WHEN 14 THEN
                vr_nmopetfn := 'OI/BRASIL TEL.';
              WHEN 21 THEN
                vr_nmopetfn := 'EMBRATEL';
              WHEN 23 THEN
                vr_nmopetfn := 'INTELIG';
              WHEN 36 THEN
                vr_nmopetfn := 'CLARO';
            END CASE;
          END IF;

          vr_destptfc := ' ';

          IF rw_telefones.tptelefo > 0 THEN
            CASE rw_telefones.tptelefo
              WHEN 1 THEN
                vr_destptfc := 'RESIDENCIAL';
              WHEN 2 THEN
                vr_destptfc := 'CELULAR';
              WHEN 3 THEN
                vr_destptfc := 'COMERCIAL';
              WHEN 4 THEN
                vr_destptfc := 'CONTATO';
            END CASE;
          END IF;

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Dados',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'telefone',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nrdddtfc',
                                 pr_tag_cont => TO_CHAR(rw_telefones.nrdddtfc),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nrtelefo',
                                 pr_tag_cont => TO_CHAR(rw_telefones.nrtelefo),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nrdramal',
                                 pr_tag_cont => TO_CHAR(rw_telefones.nrdramal),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'tptelefo',
                                 pr_tag_cont => vr_destptfc,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nmpescto',
                                 pr_tag_cont => TO_CHAR(rw_telefones.nmpescto),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'telefone',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nmopetfn',
                                 pr_tag_cont => vr_nmopetfn,
                                 pr_des_erro => vr_dscritic);

          vr_auxconta := vr_auxconta + 1;
        END IF;

        vr_flgresgi := TRUE;

      END LOOP;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Qtdregis',
                             pr_tag_cont => vr_contador,
                             pr_des_erro => vr_dscritic);

      IF NOT vr_flgresgi THEN
        vr_dscritic := 'Nenhum Numero de Telefone Localizado!';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_buscar_celular;  

  PROCEDURE pc_buscar_log(pr_nrdconta IN INTEGER
                         ,pr_nrdocmto IN INTEGER
                         ,pr_nrcnvcob IN INTEGER
                         ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                         ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                         ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                         ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                         ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                         ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_buscar_logs
    Sistema : COBEMP - Cooperativa de Credito
    Sigla   : TELA
    Autor   : Daniel Zimmermann
    Data    : Agosto/15.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina busca de log boletos.

    Observacao: -----

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_crapcol(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE,
                        pr_nrdocmto IN crapcob.nrdocmto%TYPE,
                        pr_nrcnvcob IN crapcob.nrcnvcob%TYPE) IS
        SELECT col.dtaltera,
               col.hrtransa,
               col.dslogtit,
               col.cdoperad,
               nvl(ope.nmoperad,col.cdoperad) nmoperad
          FROM crapcol col,
               crapope ope
         WHERE col.cdcooper = pr_cdcooper
           AND col.nrdconta = pr_nrdconta
           AND col.nrdocmto = pr_nrdocmto
           AND col.nrcnvcob = pr_nrcnvcob
           AND ope.cdcooper (+) = col.cdcooper
           AND ope.cdoperad (+) = col.cdoperad
           ORDER BY col.dtaltera DESC, col.hrtransa DESC;

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_contador INTEGER := 0; -- Contador p/ posicao no XML
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      vr_flgresgi BOOLEAN := FALSE;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      FOR rw_crapcol IN cr_crapcol(pr_cdcooper => vr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrdocmto => pr_nrdocmto,
                                   pr_nrcnvcob => pr_nrcnvcob) LOOP

        vr_contador := vr_contador + 1;

        IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Dados',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'log',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'log',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'dtaltera',
                                 pr_tag_cont => TO_CHAR(rw_crapcol.dtaltera, 'dd/mm/RRRR'),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'log',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'hrtransa',
                                 pr_tag_cont => GENE0002.fn_converte_time_data(rw_crapcol.hrtransa),
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'log',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'dslogtit',
                                 pr_tag_cont => rw_crapcol.dslogtit,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'log',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nmoperad',
                                 pr_tag_cont => rw_crapcol.nmoperad,
                                 pr_des_erro => vr_dscritic);

          vr_auxconta := vr_auxconta + 1;
        END IF;

        vr_flgresgi := TRUE;

      END LOOP;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Qtdregis',
                             pr_tag_cont => vr_contador,
                             pr_des_erro => vr_dscritic);

      IF NOT vr_flgresgi THEN
        vr_dscritic := 'Nenhum log localizados.';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_buscar_log;

	PROCEDURE pc_buscar_boletos_contratos_w (pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 0         --> PA
																					,pr_nrctremp IN tbepr_cobranca.nrctremp%TYPE DEFAULT 0  --> Nr. do Contrato
																					,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0         --> Nr. da Conta
																					,pr_dtbaixai IN VARCHAR2                                --> Data de baixa inicial
																					,pr_dtbaixaf IN VARCHAR2                                --> Data de baixa final
																					,pr_dtemissi IN VARCHAR2                                --> Data de emiss�o inicial
																					,pr_dtemissf IN VARCHAR2                                --> Data de emiss�o final
																					,pr_dtvencti IN VARCHAR2                                --> Data de vencimento inicial
																					,pr_dtvenctf IN VARCHAR2                                --> Data de vencimento final
																					,pr_dtpagtoi IN VARCHAR2                                --> Data de pagamento inicial
																					,pr_dtpagtof IN VARCHAR2                                --> Data de pagamento final
																					,pr_nriniseq IN INTEGER                                 --> Registro inicial da listagem
																					,pr_nrregist IN INTEGER                                 --> Numero de registros p/ paginaca
																					,pr_xmllog   IN VARCHAR2                                --> XML com informa��es de LOG
																					,pr_cdcritic OUT PLS_INTEGER                            --> C�digo da cr�tica
																					,pr_dscritic OUT VARCHAR2                               --> Descri��o da cr�tica
																					,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
																					,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
																					,pr_des_erro OUT VARCHAR2) IS                           --> Erros do processo
		BEGIN
	 	  /* .............................................................................

      Programa: pc_buscar_boletos_contratos_w
      Sistema : CECRED
      Sigla   : TELA
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: 03/03/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a busca dos boletos de contratos para Web

      Observacao: -----

      Alteracoes: 03/03/2017 - Busca do campo vr_tab_cde(vr_ind_cde).dsparcel. (P210.2 - Jaison/Daniel)

    ..............................................................................*/
			DECLARE
			----------------------------- VARIAVEIS ---------------------------------
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- C�d. cr�tica
      vr_dscritic VARCHAR2(10000);       -- Desc. cr�tica

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

			-- PL/Table
			vr_tab_cde EMPR0007.typ_tab_cde; -- PL/Table com os dados retornados da procedure
			vr_ind_cde INTEGER := 0;         -- Indice para a PL/Table retornada da procedure

			vr_auxconta INTEGER := 0;        -- Contador auxiliar p/ posicao no XML

       -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_dtbaixai DATE;
      vr_dtbaixaf DATE;
      vr_dtemissi DATE;
      vr_dtemissf DATE;
      vr_dtvencti DATE;
      vr_dtvenctf DATE;
      vr_dtpagtoi DATE;
      vr_dtpagtof DATE;

			BEGIN

        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
                                 pr_cdcooper => vr_cdcooper,
                                 pr_nmdatela => vr_nmdatela,
                                 pr_nmeacao  => vr_nmeacao,
                                 pr_cdagenci => vr_cdagenci,
                                 pr_nrdcaixa => vr_nrdcaixa,
                                 pr_idorigem => vr_idorigem,
                                 pr_cdoperad => vr_cdoperad,
                                 pr_dscritic => vr_dscritic);

        vr_dtbaixai := to_date(pr_dtbaixai,'DD/MM/RRRR');
        vr_dtbaixaf := to_date(pr_dtbaixaf,'DD/MM/RRRR');
        vr_dtemissi := to_date(pr_dtemissi,'DD/MM/RRRR');
        vr_dtemissf := to_date(pr_dtemissf,'DD/MM/RRRR');
        vr_dtvencti := to_date(pr_dtvencti,'DD/MM/RRRR');
        vr_dtvenctf := to_date(pr_dtvenctf,'DD/MM/RRRR');
        vr_dtpagtoi := to_date(pr_dtpagtoi,'DD/MM/RRRR');
        vr_dtpagtof := to_date(pr_dtpagtof,'DD/MM/RRRR');



			  EMPR0007.pc_buscar_boletos_contratos (pr_cdcooper => vr_cdcooper     --> Cooperativa
																						 ,pr_cdagenci => pr_cdagenci     --> PA
																						 ,pr_nrctremp => pr_nrctremp     --> Nr. do Contrato
																						 ,pr_nrdconta => pr_nrdconta     --> Nr. da Conta
																						 ,pr_dtbaixai => vr_dtbaixai     --> Data de baixa inicial
																						 ,pr_dtbaixaf => vr_dtbaixaf     --> Data de baixa final
																						 ,pr_dtemissi => vr_dtemissi     --> Data de emiss�o inicial
																						 ,pr_dtemissf => vr_dtemissf     --> Data de emiss�o final
																						 ,pr_dtvencti => vr_dtvencti     --> Data de vencimento inicial
																						 ,pr_dtvenctf => vr_dtvenctf     --> Data de vencimento final
																						 ,pr_dtpagtoi => vr_dtpagtoi     --> Data de pagamento inicial
																						 ,pr_dtpagtof => vr_dtpagtof     --> Data de pagamento final
																						 ,pr_cdoperad => vr_cdoperad     --> C�d. Operador
																						 ,pr_cdcritic => vr_cdcritic     --> C�d. da cr�tica
																						 ,pr_dscritic => vr_dscritic     --> Descri��o da cr�tica
																						 ,pr_tab_cde  => vr_tab_cde);    --> Pl/Table com os dados de cobran�a de emprestimos

				-- Se retornou alguma cr�tica
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
					-- Levantar exce��o
					RAISE vr_exc_saida;
				END IF;

        -- Se PL/Table possuir algum registro
        IF vr_tab_cde.count() > 0 THEN
          -- Atribui registro inicial como indice
          vr_ind_cde := pr_nriniseq;
          -- Se existe registro com o indice inicial
          IF vr_tab_cde.exists(vr_ind_cde) THEN
						-- Criar cabe�alho do XML
					  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

						LOOP
							-- Insere as tags
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdcooper', pr_tag_cont => vr_tab_cde(vr_ind_cde).cdcooper, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdagenci', pr_tag_cont => vr_tab_cde(vr_ind_cde).cdagenci, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrctremp', pr_tag_cont => vr_tab_cde(vr_ind_cde).nrctremp, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta', pr_tag_cont => vr_tab_cde(vr_ind_cde).nrdconta, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcnvcob', pr_tag_cont => vr_tab_cde(vr_ind_cde).nrcnvcob, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdocmto', pr_tag_cont => vr_tab_cde(vr_ind_cde).nrdocmto, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(vr_tab_cde(vr_ind_cde).dtmvtolt, 'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtvencto', pr_tag_cont => TO_CHAR(vr_tab_cde(vr_ind_cde).dtvencto, 'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlboleto', pr_tag_cont => vr_tab_cde(vr_ind_cde).vlboleto, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtdpagto', pr_tag_cont => TO_CHAR(vr_tab_cde(vr_ind_cde).dtdpagto, 'dd/mm/RRRR') , pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vldpagto', pr_tag_cont => vr_tab_cde(vr_ind_cde).vldpagto, pr_des_erro => vr_dscritic);              
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dstipenv', pr_tag_cont => vr_tab_cde(vr_ind_cde).dstipenv, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdopeenv', pr_tag_cont => vr_tab_cde(vr_ind_cde).cdopeenv, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtdenvio', pr_tag_cont => vr_tab_cde(vr_ind_cde).dtdenvio, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsdenvio', pr_tag_cont => vr_tab_cde(vr_ind_cde).dsdenvio, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dssituac', pr_tag_cont => vr_tab_cde(vr_ind_cde).dssituac, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtdbaixa', pr_tag_cont => TO_CHAR(vr_tab_cde(vr_ind_cde).dtdbaixa, 'dd/mm/RRRR') , pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsdemail', pr_tag_cont => vr_tab_cde(vr_ind_cde).dsdemail, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsdtelef', pr_tag_cont => vr_tab_cde(vr_ind_cde).dsdtelef, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmpescto', pr_tag_cont => vr_tab_cde(vr_ind_cde).nmpescto, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrctacob', pr_tag_cont => vr_tab_cde(vr_ind_cde).nrctacob, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'lindigit', pr_tag_cont => vr_tab_cde(vr_ind_cde).lindigit, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsparcel', pr_tag_cont => vr_tab_cde(vr_ind_cde).dsparcel, pr_des_erro => vr_dscritic);

				      -- Sai do loop se for o �ltimo registro ou se chegar no n�mero de registros solicitados
							EXIT WHEN (vr_ind_cde = vr_tab_cde.LAST OR vr_ind_cde = (pr_nriniseq + pr_nrregist) - 1);

							-- Busca pr�ximo indice
							vr_ind_cde := vr_tab_cde.NEXT(vr_ind_cde);
		          vr_auxconta := vr_auxconta + 1;

						END LOOP;
						-- Quantidade total de registros
						gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai  => 'Root', pr_posicao  => 0, pr_tag_nova => 'Qtdregis', pr_tag_cont => vr_tab_cde.count(), pr_des_erro => vr_dscritic);
					END IF;
			  ELSE
					-- Atribui cr�tica
          vr_cdcritic := 0;
					vr_dscritic := 'Dados nao encontrados!';
					-- Levanta exce��o
					RAISE vr_exc_saida;
				END IF;

			EXCEPTION
			WHEN vr_exc_saida THEN
				-- Se possui c�digo de cr�tica e n�o foi informado a descri��o
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descri��o da cr�tica
				   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			  END IF;

        -- Atribui exce��o para os parametros de cr�tica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			WHEN OTHERS THEN

        -- Atribui exce��o para os parametros de cr�tica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_buscar_boletos_contratos_w: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			END;
	END pc_buscar_boletos_contratos_w;

  PROCEDURE pc_buscar_contratos_w (pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0         --> Nr. da Conta
																	,pr_nriniseq IN INTEGER                                 --> Registro inicial da listagem
																	,pr_nrregist IN INTEGER                                 --> Numero de registros p/ paginaca
																	,pr_xmllog   IN VARCHAR2                                --> XML com informa��es de LOG
																	,pr_cdcritic OUT PLS_INTEGER                            --> C�digo da cr�tica
																	,pr_dscritic OUT VARCHAR2                               --> Descri��o da cr�tica
																	,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2) IS                           --> Erros do processo
		BEGIN
	 	  /* .............................................................................

      Programa: pc_buscar_contratos_w
      Sistema : CECRED
      Sigla   : TELA
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: 14/11/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a busca dos boletos de contratos para Web

      Observacao: -----

      Alteracoes: 01/03/2017 - Inclusao de indicador se possui avalista e coluna de Saldo Prejuizo. (P210.2 - Jaison/Daniel)

                  09/08/2017 - Nao permitir geracao para produto Pos-Fixado. (Jaison/James - PRJ298)
      Alteracoes: 14/11/2017 - Ajsute para devolver informacao de liquidacao do contrato (Jonata - RKAM P364).
    ..............................................................................*/
			DECLARE
			----------------------------- VARIAVEIS ---------------------------------
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- C�d. cr�tica
      vr_dscritic VARCHAR2(10000);       -- Desc. cr�tica

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

			-- PL/Table
		--	vr_tab_cde EMPR0007.typ_tab_cde; -- PL/Table com os dados retornados da procedure
			vr_ind_cde INTEGER := 0;         -- Indice para a PL/Table retornada da procedure

			vr_auxconta INTEGER := 0;        -- Contador auxiliar p/ posicao no XML

       -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_des_reto VARCHAR2(3);

      vr_qtregist INTEGER;
      vr_vlatraso crapepr.vlsdeved%TYPE;

      vr_dstextab    craptab.dstextab%TYPE;
      vr_parempctl   craptab.dstextab%TYPE;
      vr_digitaliza  craptab.dstextab%TYPE;
			vr_nrdconta_cob crapsab.nrdconta%TYPE;
			vr_nrcnvcob     crapcob.nrcnvcob%TYPE;
      vr_dstipcob    VARCHAR2(10);

      vr_inusatab BOOLEAN;
      vr_vlsdeved    crapepr.vlsdeved%TYPE;
      vr_avalista    INTEGER;

      --IOF
      vr_vliofpri NUMBER;
      vr_vliofadi NUMBER;
      vr_vliofcpl_tmp NUMBER;
      vr_vliofcpl NUMBER;
      vr_vltaxa_iof_principal VARCHAR2(20);
      vr_qtdiaiof NUMBER;
      vr_flgimune PLS_INTEGER;
      vr_dscatbem VARCHAR2(100);

      -- cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      --Tabela de Memoria de dados emprestimo
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;

      vr_tab_erro gene0001.typ_tab_erro;
      
      -- cursor Contrato
      CURSOR cr_epr (pr_cdcooper IN crapepr.cdcooper%TYPE
                    ,pr_nrdconta IN crapepr.nrdconta%TYPE
                    ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.inprejuz,
               epr.tpemprst,
               epr.vlsdprej
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_epr cr_epr%ROWTYPE;
           
      -- cursor Cyber - ativos
      CURSOR cr_cyb (pr_cdcooper IN crapcyb.cdcooper%TYPE
                    ,pr_nrdconta IN crapcyb.nrdconta%TYPE
                    ,pr_nrctremp IN crapcyb.nrctremp%TYPE) IS
        SELECT 1 flgativo FROM crapcyb cyb
         WHERE cyb.cdcooper = pr_cdcooper
           AND cyb.nrdconta = pr_nrdconta
           AND cyb.nrctremp = pr_nrctremp
           AND cyb.cdorigem IN (2,3)
           AND cyb.dtdbaixa IS NULL;
      rw_cyb cr_cyb%ROWTYPE;
      
      -- cursor Cyber - Judicial, Extrajudicial ou VIP
      CURSOR cr_cyc (pr_cdcooper IN crapcyc.cdcooper%TYPE
                    ,pr_nrdconta IN crapcyc.nrdconta%TYPE
                    ,pr_nrctremp IN crapcyc.nrctremp%TYPE) IS
        SELECT flgjudic,
               flextjud,
               flgehvip 
          FROM crapcyc cyc
         WHERE cyc.cdcooper = pr_cdcooper
           AND cyc.nrdconta = pr_nrdconta
           AND cyc.nrctremp = pr_nrctremp
           AND cyc.cdorigem = 3;
      rw_cyc cr_cyc%ROWTYPE;     

      -- Cursor para bens do contrato: 
      /*Faz o order by dscatbem pois "CASA" e "APARTAMENTO" reduzem as 3 aliquotas de IOF (principal, adicional e complementar) a zero.
      J� "MOTO" reduz apenas as al�quotas de IOF principal e complementar..
      Dessa forma, se tiver um bem que seja CASA ou APARTAMENTO, n�o precisa mais verificar os outros bens..*/
      CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS      
        SELECT b.dscatbem, t.cdlcremp
        FROM crapepr t
        INNER JOIN crapbpr b ON b.nrdconta = t.nrdconta AND b.cdcooper = t.cdcooper AND b.nrctrpro = t.nrctremp
        WHERE t.cdcooper = pr_cdcooper
              AND t.nrdconta = pr_nrdconta
              AND t.nrctremp = pr_nrctremp
              AND upper(b.dscatbem) IN ('APARTAMENTO', 'CASA', 'MOTO')
        ORDER BY upper(b.dscatbem) ASC;
      rw_crapbpr cr_crapbpr%ROWTYPE;
      
      
      --Cursor de parcelas dos Emprestimos
      CURSOR cr_crappep(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
       SELECT crappep.dtvencto, crappep.vlsdvpar
       FROM crappep
       WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.inliquid = 0
           AND crappep.dtvencto < pr_dtmvtolt;
      rw_crappep cr_crappep%ROWTYPE;

			BEGIN

        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
                                 pr_cdcooper => vr_cdcooper,
                                 pr_nmdatela => vr_nmdatela,
                                 pr_nmeacao  => vr_nmeacao,
                                 pr_cdagenci => vr_cdagenci,
                                 pr_nrdcaixa => vr_nrdcaixa,
                                 pr_idorigem => vr_idorigem,
                                 pr_cdoperad => vr_cdoperad,
                                 pr_dscritic => vr_dscritic);

        --Buscar Indicador Uso Taxa da tabela
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'USUARI'
                                                ,pr_cdempres => 11
                                                ,pr_cdacesso => 'TAXATABELA'
                                                ,pr_tpregist => 0);
        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          --Nao usa tabela
          vr_inusatab:= FALSE;
        ELSE
          IF  SUBSTR(vr_dstextab,1,1) = '0' THEN
            --Nao usa tabela
            vr_inusatab:= FALSE;
          ELSE
            --Nao usa tabela
            vr_inusatab:= TRUE;
          END IF;
        END IF;

   			-- Localizar conta do emitente do boleto, neste caso a cooperativa
			  vr_nrdconta_cob := GENE0002.fn_char_para_number(gene0001.fn_param_sistema(pr_cdcooper => vr_cdcooper
																										   ,pr_nmsistem => 'CRED'
																										   ,pr_cdacesso => 'COBEMP_NRDCONTA_BNF'));

			  -- Localizar convenio de cobran�a
			  vr_nrcnvcob := gene0001.fn_param_sistema(pr_cdcooper => vr_cdcooper
			                                          ,pr_nmsistem => 'CRED'
																							  ,pr_cdacesso => 'COBEMP_NRCONVEN');


        --Buscar Data do Sistema para a cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        --Se nao encontrou
        IF btch0001.cr_crapdat%NOTFOUND THEN
          -- Fechar Cursor
          CLOSE btch0001.cr_crapdat;
          -- montar mensagem de critica
          vr_cdcritic:= 1;
          vr_dscritic:= NULL;
          -- Levantar Excecao
          RAISE vr_exc_saida;
        ELSE
          -- apenas fechar o cursor
          CLOSE btch0001.cr_crapdat;
        END IF;

        -- Leitura do indicador de uso da tabela de taxa de juros
        vr_parempctl:= tabe0001.fn_busca_dstextab(pr_cdcooper => 3 /*Fixo Cecred*/
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'PAREMPCTL'
                                                 ,pr_tpregist => 1);


      -- busca o tipo de documento GED
      vr_digitaliza:= tabe0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'DIGITALIZA'
                                                ,pr_tpregist => 5);

        -- Busca saldo total de emprestimos
        EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => vr_cdcooper         --> Cooperativa conectada
                                        ,pr_cdagenci => vr_cdagenci         --> C�digo da ag�ncia
                                        ,pr_nrdcaixa => vr_nrdcaixa         --> N�mero do caixa
                                        ,pr_cdoperad => vr_cdoperad         --> C�digo do operador
                                        ,pr_nmdatela => vr_nmdatela         --> Nome datela conectada
                                        ,pr_idorigem => vr_idorigem         --> Indicador da origem da chamada
                                        ,pr_nrdconta => pr_nrdconta         --> Conta do associado
                                        ,pr_idseqttl => 1 -- pr_idseqttl         --> Sequencia de titularidade da conta
                                        ,pr_rw_crapdat => rw_crapdat        --> Vetor com dados de par�metro (CRAPDAT)
                                        ,pr_dtcalcul => rw_crapdat.dtmvtolt                --> Data solicitada do calculo
                                        ,pr_nrctremp => 0                   --> N�mero contrato empr�stimo
                                        ,pr_cdprogra => 'COBEMP'            --> Programa conectado
                                        ,pr_inusatab => vr_inusatab         --> Indicador de utiliza��o da tabela
                                        ,pr_flgerlog => 'N'                 --> Gerar log S/N
                                        ,pr_flgcondc => FALSE               --> Mostrar emprestimos liquidados sem prejuizo
                                        ,pr_nmprimtl => ' ' --rw_crapass.nmprimtl --> Nome Primeiro Titular
                                        ,pr_tab_parempctl => vr_parempctl   --> Dados tabela parametro
                                        ,pr_tab_digitaliza => vr_digitaliza --> Dados tabela parametro
                                        ,pr_nriniseq => 0                   --> Numero inicial paginacao
                                        ,pr_nrregist => 0                   --> Qtd registro por pagina
                                        ,pr_qtregist => vr_qtregist         --> Qtd total de registros
                                        ,pr_tab_dados_epr => vr_tab_dados_epr  --> Saida com os dados do empr�stimo
                                        ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);       --> Tabela com poss�ves erros

        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Se tem erro na tabela
          IF vr_tab_erro.COUNT > 0 THEN
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Nao foi possivel concluir a requisicao';
          END IF;
          --Sair com erro
          RAISE vr_exc_saida;
        END IF;


        -- Se PL/Table possuir algum registro
        IF vr_tab_dados_epr.count() > 0 THEN
          -- Atribui registro inicial como indice
          vr_ind_cde := pr_nriniseq;
          -- Se existe registro com o indice inicial
          IF vr_tab_dados_epr.exists(vr_ind_cde) THEN
						-- Criar cabe�alho do XML
					  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

						LOOP
              
              -- Se for Pos-Fixado, vai para proximo
              IF vr_tab_dados_epr(vr_ind_cde).tpemprst = 2 THEN
                -- Sai do loop se for o �ltimo registro ou se chegar no n�mero de registros solicitados
                EXIT WHEN (vr_ind_cde = vr_tab_dados_epr.LAST OR vr_ind_cde = (pr_nriniseq + pr_nrregist) - 1);
                vr_ind_cde := vr_tab_dados_epr.NEXT(vr_ind_cde);
                CONTINUE;
              END IF;

              vr_dstipcob := '';
              vr_vlsdeved := 0;

              -- Novo c�lculo de IOF
              vr_dscatbem := NULL;
              --Verifica o primeiro bem do contrato para saber se tem isen��o de al�quota
              OPEN cr_crapbpr(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => vr_tab_dados_epr(vr_ind_cde).nrctremp);
              FETCH cr_crapbpr INTO rw_crapbpr;
              IF cr_crapbpr%FOUND THEN
                vr_dscatbem := rw_crapbpr.dscatbem;                
              END IF;
              CLOSE cr_crapbpr;
              
              vr_vliofcpl := 0;
              vr_vliofcpl_tmp := 0;
              FOR rw_crappep IN cr_crappep(pr_cdcooper => vr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrctremp => vr_tab_dados_epr(vr_ind_cde).nrctremp 
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
                                          
                  --Dias de atraso
                  vr_qtdiaiof := rw_crapdat.dtmvtolt - rw_crappep.dtvencto;
                              
                  --Calcula o IOF
                  TIOF0001.pc_calcula_valor_iof_epr(pr_cdcooper => vr_cdcooper                             --> C�digo da cooperativa referente ao contrato de empr�stimos
                                                    ,pr_nrdconta => pr_nrdconta                            --> N�mero da conta referente ao empr�stimo
                                                    ,pr_nrctremp => vr_tab_dados_epr(vr_ind_cde).nrctremp  --> N�mero do contrato de empr�stimo
                                                    --,pr_vlemprst => vr_tab_dados_epr(vr_ind_cde).vlsdeved  --> Valor do empr�stimo para efeito de c�lculo
                                                    ,pr_vlemprst => rw_crappep.vlsdvpar  --> Valor do empr�stimo para efeito de c�lculo
                                                    ,pr_dscatbem => vr_dscatbem                            --> Descri��o da categoria do bem, valor default NULO 
                                                    ,pr_cdlcremp => vr_tab_dados_epr(vr_ind_cde).cdlcremp  --> Linha de cr�dito do empr�stimo
                                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt                    --> Data do movimento
                                                    ,pr_qtdiaiof => vr_qtdiaiof                            --> Quantidade de dias em atraso
                                                    ,pr_vliofpri => vr_vliofpri                            --> Valor do IOF principal
                                                    ,pr_vliofadi => vr_vliofadi                            --> Valor do IOF adicional
                                                    ,pr_vliofcpl => vr_vliofcpl_tmp                        --> Valor do IOF complementar
                                                    ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal    --> Valor da Taxa do IOF Principal
                                                    ,pr_flgimune => vr_flgimune                            --> Possui imunidade tribut�ria
                                                    ,pr_dscritic => vr_dscritic);                          --> Descri��o da cr�tica
                  IF NVL(vr_dscritic,' ') <> ' ' THEN
                    --Sair com erro
                    RAISE vr_exc_saida;
                  END IF;
                                              
                  --Imunidade....
                  IF vr_flgimune > 0 THEN
                    vr_vliofpri := 0;
                    vr_vliofadi := 0;
                    vr_vliofcpl_tmp := 0;
                  ELSE
                    vr_vliofcpl := NVL(vr_vliofcpl, 0) + ROUND(NVL(vr_vliofcpl_tmp, 0), 2);
                  END IF;
                        
              END LOOP;
                           
              vr_vlsdeved := (NVL(vr_tab_dados_epr(vr_ind_cde).vlsdeved,0) + 
                              NVL(vr_tab_dados_epr(vr_ind_cde).vlmtapar,0) +
                              NVL(vr_tab_dados_epr(vr_ind_cde).vlmrapar,0) + 
                              NVL(vr_vliofcpl,0));
                            
              
              OPEN cr_epr (pr_cdcooper => vr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => vr_tab_dados_epr(vr_ind_cde).nrctremp);
              FETCH cr_epr INTO rw_epr;
              CLOSE cr_epr;
              
              -- verificar se o contrato eh prejuizo      
              IF nvl(rw_epr.inprejuz,0) = 1 THEN
                 -- verifica se o valor do saldo em prejuizo est� em aberto
                 IF nvl(rw_epr.vlsdprej,0) > 0 THEN
                    vr_dstipcob := 'PRJ';
                 ELSE							
      				      -- Sai do loop se for o �ltimo registro ou se chegar no n�mero de registros solicitados
			      				EXIT WHEN (vr_ind_cde = vr_tab_dados_epr.LAST OR vr_ind_cde = (pr_nriniseq + pr_nrregist) - 1);
                   
                    vr_ind_cde := vr_tab_dados_epr.NEXT(vr_ind_cde);                    
                   
                    continue;
                 END IF;
              END IF;                          
              
              -- verificar se o contrato esta ativo no Cyber
              OPEN cr_cyb (pr_cdcooper => vr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => vr_tab_dados_epr(vr_ind_cde).nrctremp);
              FETCH cr_cyb INTO rw_cyb;
              CLOSE cr_cyb;
              
              IF nvl(rw_cyb.flgativo,0) = 1 THEN
                 
                 -- verificar que tipo contrato esta no Cyber
                 OPEN cr_cyc (pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => vr_tab_dados_epr(vr_ind_cde).nrctremp);
                 FETCH cr_cyc INTO rw_cyc;

                 IF cr_cyc%FOUND THEN
                   
                    CLOSE cr_cyc;            
                    
                    IF nvl(rw_cyc.flgehvip,0) = 1 THEN
                       vr_dstipcob := 'VIP';
                    END IF;                                           
                                        
                    IF nvl(rw_cyc.flextjud,0) = 1 THEN
                       vr_dstipcob := 'EXJ';
                    END IF;

                    IF nvl(rw_cyc.flgjudic,0) = 1 THEN
                       vr_dstipcob := 'JUD';
                    END IF;                    
                    
                 ELSE
                   CLOSE cr_cyc;                             
                 END IF;        
              
              END IF;
              
              IF vr_tab_dados_epr(vr_ind_cde).tpemprst = 0 THEN
                vr_vlatraso := vr_tab_dados_epr(vr_ind_cde).vltotpag;
              ELSE
                vr_vlatraso := vr_tab_dados_epr(vr_ind_cde).vlprvenc + vr_tab_dados_epr(vr_ind_cde).vlmtapar + vr_tab_dados_epr(vr_ind_cde).vlmrapar;                
              END IF;
              vr_vlatraso := vr_vlatraso + NVL(vr_vliofcpl,0);
              

              IF vr_tab_dados_epr(vr_ind_cde).dsdavali <> ' ' THEN
                vr_avalista := 1;
              ELSE
                vr_avalista := 0;
              END IF;
              
							-- Insere as tags
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdlcremp', pr_tag_cont => vr_tab_dados_epr(vr_ind_cde).cdlcremp, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdfinemp', pr_tag_cont => vr_tab_dados_epr(vr_ind_cde).cdfinemp, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'tpemprst', pr_tag_cont => vr_tab_dados_epr(vr_ind_cde).tpemprst, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(vr_tab_dados_epr(vr_ind_cde).dtmvtolt, 'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
					    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtpreemp', pr_tag_cont => vr_tab_dados_epr(vr_ind_cde).qtpreemp, pr_des_erro => vr_dscritic);
          		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlemprst', pr_tag_cont => vr_tab_dados_epr(vr_ind_cde).vlemprst, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlpreemp', pr_tag_cont => vr_tab_dados_epr(vr_ind_cde).vlpreemp, pr_des_erro => vr_dscritic);
					    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vltotpag', pr_tag_cont => vr_vlatraso, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlsdeved', pr_tag_cont => vr_vlsdeved, pr_des_erro => vr_dscritic);
						  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrctremp', pr_tag_cont => vr_tab_dados_epr(vr_ind_cde).nrctremp, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrctacob', pr_tag_cont => vr_nrdconta_cob, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcnvcob', pr_tag_cont => vr_nrcnvcob, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dstipcob', pr_tag_cont => vr_dstipcob, pr_des_erro => vr_dscritic);              
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'avalista', pr_tag_cont => vr_avalista, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'inprejuz', pr_tag_cont => nvl(vr_tab_dados_epr(vr_ind_cde).inprejuz,0), pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlsdprej', pr_tag_cont => vr_tab_dados_epr(vr_ind_cde).vlsdprej, pr_des_erro => vr_dscritic);
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'inliquid', pr_tag_cont => vr_tab_dados_epr(vr_ind_cde).inliquid, pr_des_erro => vr_dscritic);              
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vliofcpl', pr_tag_cont => vr_vliofcpl, pr_des_erro => vr_dscritic);

              --IF ( vr_tab_dados_epr(vr_ind_cde).vltotpag > 0 ) THEN
                 vr_auxconta := vr_auxconta + 1;
              --END IF;   

				      -- Sai do loop se for o �ltimo registro ou se chegar no n�mero de registros solicitados
							EXIT WHEN (vr_ind_cde = vr_tab_dados_epr.LAST OR vr_ind_cde = (pr_nriniseq + pr_nrregist) - 1);
							
              vr_ind_cde := vr_tab_dados_epr.NEXT(vr_ind_cde);
                
						END LOOP;
						-- Quantidade total de registros
						gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai  => 'Root', pr_posicao  => 0, pr_tag_nova => 'Qtdregis', pr_tag_cont => vr_tab_dados_epr.count(), pr_des_erro => vr_dscritic);
					END IF;
			  ELSE
					-- Atribui cr�tica
          vr_cdcritic := 0;
					vr_dscritic := 'Cooperado nao possui contratos em atraso!';
					-- Levanta exce��o
					RAISE vr_exc_saida;
				END IF;

        IF ( vr_auxconta = 0 ) THEN
          -- Atribui cr�tica
          vr_cdcritic := 0;
					vr_dscritic := 'Cooperado nao possui contratos em atraso!';
					-- Levanta exce��o
					RAISE vr_exc_saida;
        END IF;

			EXCEPTION
			WHEN vr_exc_saida THEN
				-- Se possui c�digo de cr�tica e n�o foi informado a descri��o
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descri��o da cr�tica
				   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			  END IF;

        -- Atribui exce��o para os parametros de cr�tica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			WHEN OTHERS THEN

        -- Atribui exce��o para os parametros de cr�tica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_buscar_contratos_w: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			END;
	END pc_buscar_contratos_w;

	PROCEDURE pc_verifica_gerar_boleto (pr_nrctacob IN crapass.nrdconta%TYPE                   --> Nr. da Conta Cob.
		                                 ,pr_nrdconta IN crapass.nrdconta%TYPE                   --> Nr. da Conta
																		 ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE                   --> Nr. do Conv�nio de Cobran�a
																	 	 ,pr_nrctremp IN crapcob.nrctremp%TYPE                   --> Nr. do Contrato
																		 ,pr_xmllog   IN VARCHAR2                                --> XML com informa��es de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER                            --> C�digo da cr�tica
																		 ,pr_dscritic OUT VARCHAR2                               --> Descri��o da cr�tica
																		 ,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
																		 ,pr_des_erro OUT VARCHAR2) IS                           --> Erros do processo
		BEGIN
	 	  /* .............................................................................

      Programa: pc_verifica_gerar_boleto
      Sistema : CECRED
      Sigla   : TELA
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: 27/09/2016

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para valida��o da utiliza��o da rotina "Gerar Boleto"

      Observacao: -----

      Alteracoes: 27/09/2016 - Incluida verificacao de contratos de acordo,
                               Prj. 302 (Jean Michel).
    ..............................................................................*/
		DECLARE
		  -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- C�d. cr�tica
      vr_dscritic VARCHAR2(10000);       -- Desc. cr�tica
      vr_des_erro VARCHAR(3);            -- Retorno OK/NOK
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis utilizadas na extra��o dos dados do xml
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_flgativo INTEGER := 0;

		BEGIN
			-- Extrai os dados do XML
			GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

      -- Verifica contratos de acordo
      RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => vr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_cdorigem => 3
                                       ,pr_flgativo => vr_flgativo
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        -- Gerar exce��o
				RAISE vr_exc_saida;
      END IF;
          
      IF vr_flgativo = 1 THEN
        vr_dscritic := 'Geracao do boleto nao permitido, emprestimo em acordo.';
        -- Gerar exce��o
				RAISE vr_exc_saida;
      END IF;
               
      -- Chama procedure de valida��o para gerar o boleto
 		  EMPR0007.pc_verifica_gerar_boleto (pr_cdcooper => vr_cdcooper      --> C�d. cooperativa
																				,pr_nrctacob => pr_nrctacob      --> Nr. da Conta Cob.
																				,pr_nrdconta => pr_nrdconta      --> Nr. da Conta
																				,pr_nrcnvcob => pr_nrcnvcob      --> Nr. do Conv�nio de Cobran�a
																				,pr_nrctremp => pr_nrctremp      --> Nr. do Contrato
																				,pr_cdcritic => vr_cdcritic      --> C�digo da cr�tica
																				,pr_dscritic => vr_dscritic      --> Descri��o da cr�tica
																				,pr_des_erro => vr_des_erro);    --> Erros do processo
      -- Se retornou erro
      IF vr_des_erro <> 'OK' THEN
				-- Gerar exce��o
				RAISE vr_exc_saida;
			END IF;

		EXCEPTION
			WHEN vr_exc_saida THEN
				-- Se possui c�digo de cr�tica e n�o foi informado a descri��o
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descri��o da cr�tica
				   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			  END IF;

        -- Atribui exce��o para os parametros de cr�tica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN

        -- Atribui exce��o para os parametros de cr�tica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_verifica_gerar_boleto: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		END;
	END pc_verifica_gerar_boleto;

  PROCEDURE pc_busca_texto_sms(pr_nrdconta IN INTEGER
                              ,pr_lindigit IN VARCHAR2
                              ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                              ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_texto_sms
    Sistema : Cobran�a - Cooperativa de Credito
    Sigla   : COB
    Autor   : Daniel Zimmermann
    Data    : Agosto/15.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina buscar texto a ser utilizado no envio de sms cobran�a

    Observacao: -----

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      CURSOR cr_crapass(pr_cdcooper    IN crapass.cdcooper%TYPE,
                        pr_nrdconta    IN crapass.nrdconta%TYPE) IS
      SELECT nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor para buscar os dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper in crapcop.cdcooper%type) is
        select crapcop.nmextcop,
               crapcop.cdageitg,
               crapcop.cdagebcb,
               crapcop.cdagectl,
               crapcop.cdbcoctl,
               crapcop.nmrescop,
               crapcop.dsendcop,
               crapcop.nrendcop,
               crapcop.nmbairro,
               crapcop.nrtelvoz,
               crapcop.nmcidade,
               crapcop.cdufdcop
          from crapcop
         where crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;


      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

 --     vr_tab_erro GENE0001.typ_tab_erro; --> Tabela com erros

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
   --   vr_contador INTEGER := 0; -- Contador p/ posicao no XML
   --   vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
  --    vr_flgresgi BOOLEAN := FALSE;

      vr_texto_sms VARCHAR2(4000);
      vr_nmextcop VARCHAR2(100);
      vr_nmprimtl VARCHAR2(100);

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Verifica se a cooperativa esta cadastrada
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Busca os dados da cooperativa
      OPEN cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapcop;

      -- Busca os dados do associado
      OPEN cr_crapass(vr_cdcooper,
                      pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

      vr_nmprimtl := rw_crapass.nmprimtl;
      vr_nmextcop := rw_crapcop.nmrescop;

      vr_texto_sms:= gene0001.fn_param_sistema(pr_cdcooper => vr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'COBEMP_TXT_SMS');


      vr_texto_sms := REPLACE(vr_texto_sms,'#Cooperativa#',vr_nmextcop);
      vr_texto_sms := REPLACE(vr_texto_sms,'#Cooperado#',vr_nmprimtl);
      vr_texto_sms := REPLACE(vr_texto_sms,'#LinhaDigitavel#',pr_lindigit);

      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);


      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Texto_SMS',
                             pr_tag_cont => vr_texto_sms,
                             pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_texto_sms;

  PROCEDURE pc_gerar_pdf_boletos_w (pr_nrdconta IN crapass.nrdconta%TYPE          --> Nr. da Conta
																	 ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE          --> Nr. do convenio
																	 ,pr_nrdocmto IN crapcob.nrdocmto%TYPE          --> Nr. Docmto
																	 ,pr_xmllog   IN VARCHAR2                       --> XML com informa��es de LOG
																	 ,pr_cdcritic OUT PLS_INTEGER                   --> C�digo da cr�tica
																	 ,pr_dscritic OUT VARCHAR2                      --> Descri��o da cr�tica
																	 ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
																	 ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
																	 ,pr_des_erro OUT VARCHAR2) IS                  --> Erros do processo
  BEGIN
	/* .............................................................................

		Programa: pc_gerar_pdf_boletos_w
		Sistema : CECRED
		Sigla   : EMPR
		Autor   : Lucas Reinert
		Data    : Agosto/15.                    Ultima atualizacao:

		Dados referentes ao programa:

		Frequencia: Sempre que for chamado

		Objetivo  : Rotina para gerar a impressao do boleto em pdf

		Observacao: -----

		Alteracoes:
	..............................................................................*/
		DECLARE
			----------------------------- VARIAVEIS ---------------------------------
			-- Vari�vel de cr�ticas
			vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic VARCHAR2(10000);

			-- Tratamento de erros
			vr_exc_saida EXCEPTION;
			vr_tab_erro  gene0001.typ_tab_erro;

			 -- Variaveis de log
			vr_cdcooper INTEGER;
			vr_cdoperad VARCHAR2(100);
			vr_nmdatela VARCHAR2(100);
			vr_nmeacao  VARCHAR2(100);
			vr_cdagenci VARCHAR2(100);
			vr_nrdcaixa VARCHAR2(100);
			vr_idorigem VARCHAR2(100);

			vr_des_reto VARCHAR2(3);

			vr_nmarqpdf   VARCHAR2(1000);
	    
			---------------------------- CURSORES -----------------------------------
		BEGIN

			---------------------------------- VALIDACOES INICIAIS --------------------------

			GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

      -- Chama rotina para gerar o pdf do boleto
      empr0007.pc_gerar_pdf_boletos(pr_cdcooper => vr_cdcooper
			                             ,pr_nrdconta => pr_nrdconta
																	 ,pr_nrcnvcob => pr_nrcnvcob
																	 ,pr_nrdocmto => pr_nrdocmto
																	 ,pr_cdoperad => vr_cdoperad
																	 ,pr_idorigem => vr_idorigem
																	 ,pr_nmarqpdf => vr_nmarqpdf
																	 ,pr_cdcritic => vr_cdcritic
																	 ,pr_dscritic => vr_dscritic
																	 ,pr_des_erro => vr_des_reto);

      IF vr_des_reto <> 'OK' THEN
				RAISE vr_exc_saida;
			END IF;

			-- Criar XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
																		 vr_nmarqpdf || '</nmarqpdf>');

		EXCEPTION
			WHEN vr_exc_saida THEN

				-- Busca descri��o da cr�tica se houver c�digo
				IF vr_cdcritic <> 0 THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				ELSE
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;

				-- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
				-- Existe para satisfazer exig�ncia da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																			 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBEMP: ' || SQLERRM;

			-- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
			-- Existe para satisfazer exig�ncia da interface.
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		END;
	END pc_gerar_pdf_boletos_w;

  PROCEDURE pc_busca_prazo_venc(pr_inprejuz IN INTEGER                        --> Indicador de prejuizo
                               ,pr_xmllog   IN VARCHAR2                       --> XML com informa��es de LOG
															 ,pr_cdcritic OUT PLS_INTEGER                   --> C�digo da cr�tica
															 ,pr_dscritic OUT VARCHAR2                      --> Descri��o da cr�tica
															 ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
															 ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
															 ,pr_des_erro OUT VARCHAR2) IS                  --> Erros do processo
	BEGIN
	/* .............................................................................

		Programa: pc_busca_prazo_venc
		Sistema : CECRED
		Sigla   : EMPR
		Autor   : Lucas Reinert
		Data    : Agosto/15.                    Ultima atualizacao: 08/03/2017

		Dados referentes ao programa:

		Frequencia: Sempre que for chamado

		Objetivo  : Rotina para buscar o prazo m�ximo de vencimento da cooperativa

		Observacao: -----

		Alteracoes: 08/03/2017 - Criacao de funcionamento quando prejuizo. (P210.2 - Jaison/Daniel)
	..............................................................................*/
		DECLARE
			----------------------------- VARIAVEIS ---------------------------------
			-- Vari�vel de cr�ticas
			vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic VARCHAR2(10000);

			-- Tratamento de erros
			vr_exc_saida EXCEPTION;

			-- Variaveis de log
			vr_cdcooper INTEGER;
			vr_cdoperad VARCHAR2(100);
			vr_nmdatela VARCHAR2(100);
			vr_nmeacao  VARCHAR2(100);
			vr_cdagenci VARCHAR2(100);
			vr_nrdcaixa VARCHAR2(100);
			vr_idorigem VARCHAR2(100);

			-- Variaveis locais
			vr_dtprzmax DATE;
			vr_qtdiaspz INTEGER;

			------------------------------ CURSORES --------------------------------
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

		BEGIN

			-- Extrai dados
			GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se h� algum c�digo ou descri��o de cr�tica
			IF pr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levanta exce��o
				RAISE vr_exc_saida;
			END IF;

			-- Verifica se a cooperativa esta cadastrada
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

			vr_qtdiaspz := to_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
																												,pr_cdcooper => vr_cdcooper
																												,pr_cdacesso => 'COBEMP_PRZ_MAX_VENCTO'));

			vr_dtprzmax := rw_crapdat.dtmvtolt;

      FOR dias IN 1..vr_qtdiaspz LOOP
				-- Busca caminho da imagem do logo do boleto da cecred
				vr_dtprzmax := gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
																									,pr_dtmvtolt => vr_dtprzmax + 1
																									,pr_tipo => 'P');
			END LOOP;

		  -- Se for prejuizo
      IF pr_inprejuz = 1 THEN
        -- Nao permite geracao de data maior ou igual que ultimo dia util do mes
        IF vr_dtprzmax >= rw_crapdat.dtultdia THEN
           vr_dtprzmax := gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
                                                     ,pr_dtmvtolt => rw_crapdat.dtultdia
                                                     ,pr_tipo => 'A');
           vr_dtprzmax := gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
                                                     ,pr_dtmvtolt => vr_dtprzmax - 1
                                                     ,pr_tipo => 'A');
        END IF;
      END IF;

      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><dtprzmax>'
			                              || to_char(vr_dtprzmax, 'DD/MM/RRRR') || '</dtprzmax>');

		EXCEPTION
			WHEN vr_exc_saida THEN

				-- Busca descri��o da cr�tica se houver c�digo
				IF vr_cdcritic <> 0 THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				ELSE
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;

				-- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
				-- Existe para satisfazer exig�ncia da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																			 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBEMP: ' || SQLERRM;

			-- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
			-- Existe para satisfazer exig�ncia da interface.
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		END;
  END pc_busca_prazo_venc;
  
  PROCEDURE pc_lista_pa(pr_cdagenci IN INTEGER          
                       ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                       ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                       ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                       ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                       ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_lista_pa
    Sistema : Cobran�a - Cooperativa de Credito
    Sigla   : TELA
    Autor   : Daniel Zimmermann
    Data    : Agosto/15.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotinapara lista pa.

    Observacao: -----

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_crapage(pr_cdagenci IN crapage.cdagenci%TYPE,
                        pr_cdcooper IN crapage.cdcooper%TYPE) IS
        SELECT age.cdagenci, age.nmresage
          FROM crapage age, crapcop cop
         WHERE age.cdcooper  = pr_cdcooper
           AND age.cdagenci >= pr_cdagenci
           AND cop.cdcooper = age.cdcooper
           AND age.cdagenci <> 999;

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_contador INTEGER := 0; -- Contador p/ posicao no XML
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      vr_flgresgi BOOLEAN := FALSE;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      FOR rw_crapage IN cr_crapage(pr_cdcooper => vr_cdcooper,
                                   pr_cdagenci => pr_cdagenci) LOOP

        vr_contador := vr_contador + 1;

        IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Dados',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'pa',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'pa',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'cdagenci',
                                 pr_tag_cont => TO_CHAR(rw_crapage.cdagenci),
                                 pr_des_erro => vr_dscritic);                       
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'pa',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nmresage',
                                 pr_tag_cont => TO_CHAR(rw_crapage.nmresage),
                                 pr_des_erro => vr_dscritic);
          
          vr_auxconta := vr_auxconta + 1;
        END IF;

        vr_flgresgi := TRUE;

      END LOOP;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'qtdregis',
                             pr_tag_cont => vr_contador,
                             pr_des_erro => vr_dscritic);

      IF NOT vr_flgresgi THEN
        vr_dscritic := 'Nenhum PA localizado!';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_lista_pa;   
  
  PROCEDURE pc_busca_aval(pr_nrdconta   IN INTEGER --> Numero conta
                         ,pr_nrctremp   IN INTEGER --> Numero contrato
                         ,pr_xmllog     IN VARCHAR2 --> XML com informa��es de LOG
                         ,pr_cdcritic  OUT PLS_INTEGER --> C�digo da cr�tica
                         ,pr_dscritic  OUT VARCHAR2 --> Descri��o da cr�tica
                         ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_aval
    Sistema : Cobran�a - Cooperativa de Credito
    Sigla   : TELA
    Autor   : Jaison Fernando
    Data    : Marco/2017.                    Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar os avalistas.

    Observacao: -----

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);

      -- Variaveis
      vr_index    PLS_INTEGER;
      vr_tab_aval DSCT0002.typ_tab_dados_avais;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
    
    
      -- Listar avalistas de contratos
      DSCT0002.pc_lista_avalistas(pr_cdcooper => vr_cdcooper  --> C�digo da Cooperativa
                                 ,pr_cdagenci => vr_cdagenci  --> C�digo da agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                                 ,pr_cdoperad => vr_cdoperad  --> C�digo do Operador
                                 ,pr_nmdatela => vr_nmdatela  --> Nome da tela
                                 ,pr_idorigem => vr_idorigem  --> Identificador de Origem
                                 ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                                 ,pr_idseqttl => 1            --> Sequencial do titular
                                 ,pr_tpctrato => 1            --> Emprestimo  
                                 ,pr_nrctrato => pr_nrctremp  --> Numero do contrato
                                 ,pr_nrctaav1 => 0            --> Numero da conta do primeiro avalista
                                 ,pr_nrctaav2 => 0            --> Numero da conta do segundo avalista
                                  --------> OUT <--------                                   
                                 ,pr_tab_dados_avais => vr_tab_aval   --> retorna dados do avalista
                                 ,pr_cdcritic        => vr_cdcritic   --> C�digo da cr�tica
                                 ,pr_dscritic        => vr_dscritic); --> Descri��o da cr�tica
      
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Buscar Primeiro registro
      vr_index:= vr_tab_aval.FIRST;

      -- Percorrer todos os registros
      WHILE vr_index IS NOT NULL LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'aval'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'aval'
                              ,pr_posicao  => vr_index - 1
                              ,pr_tag_nova => 'nmdavali'
                              ,pr_tag_cont => vr_tab_aval(vr_index).nmdavali
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'aval'
                              ,pr_posicao  => vr_index - 1
                              ,pr_tag_nova => 'nrcpfcgc'
                              ,pr_tag_cont => vr_tab_aval(vr_index).nrcpfcgc
                              ,pr_des_erro => vr_dscritic);

        -- Proximo Registro
        vr_index:= vr_tab_aval.NEXT(vr_index);
      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_aval;

  PROCEDURE pc_busca_desconto(pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                             ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
	BEGIN
	/* .............................................................................

		Programa: pc_busca_desconto
		Sistema : CECRED
		Sigla   : EMPR
		Autor   : Jaison Fernandp
		Data    : Marco/2017                    Ultima atualizacao: 

		Dados referentes ao programa:

		Frequencia: Sempre que for chamado

		Objetivo  : Rotina para buscar o percentual de desconto e se possui permissao de uso.

		Observacao: -----

		Alteracoes: 
	..............................................................................*/
		DECLARE
			----------------------------- VARIAVEIS ---------------------------------
			-- Vari�vel de cr�ticas
			vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic VARCHAR2(10000);

			-- Tratamento de erros
			vr_exc_saida EXCEPTION;

			-- Variaveis de log
			vr_cdcooper INTEGER;
			vr_cdoperad VARCHAR2(100);
			vr_nmdatela VARCHAR2(100);
			vr_nmeacao  VARCHAR2(100);
			vr_cdagenci VARCHAR2(100);
			vr_nrdcaixa VARCHAR2(100);
			vr_idorigem VARCHAR2(100);

      -- Pltable com os dados de cobran�a de empr�stimos
			vr_reg_cobemp EMPR0007.typ_reg_cobemp;

			-- Variaveis locais
			vr_inperdct INTEGER := 1;

		  -- Busca os convernios de emprestimo da cooperativa
		  CURSOR cr_crapprm(pr_cdcooper IN crapcop.cdcooper%TYPE
			                 ,pr_cdacesso IN crapprm.cdacesso%TYPE) IS
			  SELECT prm.dsvlrprm
				  FROM crapprm prm
				 WHERE prm.cdcooper = pr_cdcooper
				 	 AND prm.nmsistem = 'CRED'
					 AND prm.cdacesso = pr_cdacesso;

      -- Verificar se operador tem acesso a opcao de desconto
			CURSOR cr_crapace(pr_cdcooper IN crapcop.cdcooper%TYPE
			                 ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
			  SELECT 1
				  FROM crapace ace
				 WHERE ace.cdcooper = pr_cdcooper
				   AND UPPER(ace.cdoperad) = UPPER(pr_cdoperad)
           AND UPPER(ace.nmdatela) = 'COBEMP'
					 AND ace.idambace = 2     
					 AND UPPER(ace.cddopcao) = 'D';
      rw_crapace cr_crapace%ROWTYPE;

		BEGIN
			-- Extrai os dados vindos do XML
			GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

		  -- Desconto M�ximo Contrato Preju�zo
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_DSC_MAX_PREJU');
			FETCH cr_crapprm INTO vr_reg_cobemp.descprej;
			CLOSE cr_crapprm;

			-- Se NAO for SUPER-USUARIO
      IF vr_cdoperad <> '1' THEN 
        -- Verificar se operador tem acesso a opcao de desconto
        OPEN cr_crapace(pr_cdcooper => vr_cdcooper
                       ,pr_cdoperad => vr_cdoperad);
        FETCH cr_crapace INTO rw_crapace;
        IF cr_crapace%NOTFOUND THEN
          vr_inperdct := 0;
        END IF;
        CLOSE cr_crapace;
      END IF;

      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><descprej>' || NVL(vr_reg_cobemp.descprej, '0,00') || '</descprej>' ||
																		         '<inperdct>' || NVL(vr_inperdct, 0) || '</inperdct></Root>');

		EXCEPTION
			WHEN vr_exc_saida THEN

				-- Busca descri��o da cr�tica se houver c�digo
				IF vr_cdcritic <> 0 THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				ELSE
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;

				-- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
				-- Existe para satisfazer exig�ncia da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																			 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBEMP: ' || SQLERRM;

			-- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
			-- Existe para satisfazer exig�ncia da interface.
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		END;
  END pc_busca_desconto;

	PROCEDURE pc_busca_arquivos(pr_dtarqini   IN VARCHAR2       --> Data inicial
                             ,pr_dtarqfim   IN VARCHAR2       --> Data final
                             ,pr_nmarquiv   IN VARCHAR2       --> Nome do arquivo
                             ,pr_nriniseq   IN INTEGER        --> Registro inicial da listagem
                             ,pr_nrregist   IN INTEGER        --> Numero de registros p/ paginaca
                             ,pr_xmllog     IN VARCHAR2       --> XML com informa��es de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER    --> C�digo da cr�tica
                             ,pr_dscritic  OUT VARCHAR2       --> Descri��o da cr�tica
                             ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2) IS   --> Erros do processo
		BEGIN
	 	  /* .............................................................................

      Programa: pc_busca_arquivos
      Sistema : CECRED
      Sigla   : TELA
      Autor   : Jaison Fernando
      Data    : Marco/2017                    Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a busca dos arquivos de Boletagem Massiva.

      Observacao: -----

      Alteracoes: 

    ..............................................................................*/
			DECLARE
			----------------------------- VARIAVEIS ---------------------------------
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- C�d. cr�tica
      vr_dscritic VARCHAR2(10000);       -- Desc. cr�tica

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

			-- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_dtarqini DATE := NULL;
      vr_dtarqfim DATE := NULL;
      vr_contador INTEGER := 0;
      vr_auxarqui INTEGER := 0;

		  -- Busca os arquivos
      CURSOR cr_arquivos(pr_dtarqini IN tbepr_boleto_arq.dtarquivo%TYPE
                        ,pr_dtarqfim IN tbepr_boleto_arq.dtarquivo%TYPE
                        ,pr_nmarquiv IN tbepr_boleto_arq.nmarq_import%TYPE) IS
        SELECT arq.idarquivo,
               arq.dtarquivo,
               arq.nmarq_import,
               DECODE(arq.insitarq, 0, 'Pendente', 'Processado') situacaoarq,
               (SELECT COUNT(imp.idarquivo)
                  FROM tbepr_boleto_import imp
                 WHERE imp.idarquivo = arq.idarquivo) qtd_boleto,
               DECODE(arq.insitarq, 0, 
                     (SELECT COUNT(DISTINCT cri.idboleto)
                        FROM tbepr_boleto_critic cri
                       WHERE cri.idarquivo = arq.idarquivo),
                     (SELECT COUNT(DISTINCT imp.idboleto)
                        FROM tbepr_boleto_import imp
                       WHERE imp.idarquivo = arq.idarquivo
                         AND TRIM(imp.dserrger) IS NOT NULL)) qtd_critica
          FROM tbepr_boleto_arq arq
         WHERE (TRIM(pr_nmarquiv) IS NULL
            OR  UPPER(arq.nmarq_import) LIKE '%'||UPPER(pr_nmarquiv)||'%')
           AND ((TRIM(pr_dtarqini) IS NULL AND TRIM(pr_dtarqfim) IS NULL)
            OR  TRUNC(arq.dtarquivo) BETWEEN pr_dtarqini AND pr_dtarqfim)
          ORDER BY arq.idarquivo DESC;

			BEGIN

        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
                                 pr_cdcooper => vr_cdcooper,
                                 pr_nmdatela => vr_nmdatela,
                                 pr_nmeacao  => vr_nmeacao,
                                 pr_cdagenci => vr_cdagenci,
                                 pr_nrdcaixa => vr_nrdcaixa,
                                 pr_idorigem => vr_idorigem,
                                 pr_cdoperad => vr_cdoperad,
                                 pr_dscritic => vr_dscritic);

        IF TRIM(pr_dtarqini) IS NOT NULL AND
           TRIM(pr_dtarqfim) IS NOT NULL THEN
           vr_dtarqini := to_date(pr_dtarqini,'DD/MM/RRRR');
           vr_dtarqfim := to_date(pr_dtarqfim,'DD/MM/RRRR');
        END IF;

        -- Criar cabe�alho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Root',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Dados',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);

        FOR rw_arquivos IN cr_arquivos(pr_dtarqini => vr_dtarqini,
                                       pr_dtarqfim => vr_dtarqfim,
                                       pr_nmarquiv => pr_nmarquiv) LOOP

          vr_contador := vr_contador + 1;

          IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN

            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'Dados',
                                   pr_posicao  => 0,
                                   pr_tag_nova => 'arq',
                                   pr_tag_cont => NULL,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'arq',
                                   pr_posicao  => vr_auxarqui,
                                   pr_tag_nova => 'idarquivo',
                                   pr_tag_cont => rw_arquivos.idarquivo,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'arq',
                                   pr_posicao  => vr_auxarqui,
                                   pr_tag_nova => 'dtarquivo',
                                   pr_tag_cont => TO_CHAR(rw_arquivos.dtarquivo, 'dd/mm/RRRR'),
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'arq',
                                   pr_posicao  => vr_auxarqui,
                                   pr_tag_nova => 'nmarq_import',
                                   pr_tag_cont => rw_arquivos.nmarq_import,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'arq',
                                   pr_posicao  => vr_auxarqui,
                                   pr_tag_nova => 'qtd_boleto',
                                   pr_tag_cont => GENE0002.fn_mask_contrato(rw_arquivos.qtd_boleto),
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'arq',
                                   pr_posicao  => vr_auxarqui,
                                   pr_tag_nova => 'qtd_critica',
                                   pr_tag_cont => GENE0002.fn_mask_contrato(rw_arquivos.qtd_critica),
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'arq',
                                   pr_posicao  => vr_auxarqui,
                                   pr_tag_nova => 'situacaoarq',
                                   pr_tag_cont => rw_arquivos.situacaoarq,
                                   pr_des_erro => vr_dscritic);

            vr_auxarqui := vr_auxarqui + 1;
          END IF;

        END LOOP;

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Root',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Qtdregis',
                               pr_tag_cont => vr_contador,
                               pr_des_erro => vr_dscritic);
/*
        IF vr_contador = 0 THEN
          vr_dscritic := 'Nenhum arquivo encontrado.';
          RAISE vr_exc_saida;
        END IF;
*/
			EXCEPTION
			WHEN vr_exc_saida THEN
				-- Se possui c�digo de cr�tica e n�o foi informado a descri��o
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descri��o da cr�tica
				   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			  END IF;

        -- Atribui exce��o para os parametros de cr�tica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			WHEN OTHERS THEN

        -- Atribui exce��o para os parametros de cr�tica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na TELA_COBEMP.pc_busca_arquivos: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			END;

	END pc_busca_arquivos;

	PROCEDURE pc_importar_arquivo(pr_nmarquiv   IN VARCHAR2       --> Nome do arquivo
                               ,pr_flgreimp   IN INTEGER        --> Reimportacao: 0-Nao / 1-Sim
                               ,pr_xmllog     IN VARCHAR2       --> XML com informa��es de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER    --> C�digo da cr�tica
                               ,pr_dscritic  OUT VARCHAR2       --> Descri��o da cr�tica
                               ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2) IS   --> Erros do processo
	  BEGIN
 	  /* .............................................................................

      Programa: pc_importar_arquivo
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Jaison Fernando
      Data    : Marco/2017                    Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a importacao da boletagem massiva.

      Observacao: -----

      Alteracoes: 
    ..............................................................................*/
		DECLARE

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis locais
    vr_index    PLS_INTEGER;
    vr_blnachou BOOLEAN;
    vr_idboleto INTEGER := 0;
    vr_dsextens varchar2(3);
    vr_nmarquiv VARCHAR2(100);
    vr_dsdireto VARCHAR2(1000);
    vr_dsdirarq VARCHAR2(1000);
    vr_dsdlinha VARCHAR2(2000);
    vr_arqhandl utl_file.file_type;
    vr_vet_arqv GENE0002.typ_split;
    vr_vet_dado GENE0002.typ_split;
    vr_tab_aval DSCT0002.typ_tab_dados_avais;

    vr_lin_cdcooper tbepr_boleto_import.cdcooper%TYPE;
    vr_lin_nrdconta tbepr_boleto_import.nrdconta%TYPE;
    vr_lin_nrctremp tbepr_boleto_import.nrctremp%TYPE;
    vr_lin_nrcpfava tbepr_boleto_import.nrcpfaval%TYPE;
    vr_lin_tipenvio tbepr_boleto_import.tpenvio%TYPE;
    vr_lin_per_acre tbepr_boleto_import.peracrescimo%TYPE;
    vr_lin_per_desc tbepr_boleto_import.perdesconto%TYPE;
    vr_lin_dtvencto tbepr_boleto_import.dtvencto%TYPE;
    vr_lin_dsdnrddd tbepr_boleto_import.nrddd_envio%TYPE;
    vr_lin_telefone tbepr_boleto_import.nrfone_envio%TYPE;
    vr_lin_dsdemail tbepr_boleto_import.dsemail_envio%TYPE;
    vr_lin_endereco tbepr_boleto_import.dsendereco_envio%TYPE;

    -------------------------------- CURSORES --------------------------------------

		-- Cursor para consultar arquivo
		CURSOR cr_arquivo(pr_nmarquiv IN tbepr_boleto_arq.nmarq_import%TYPE) IS
      SELECT arq.idarquivo,
             arq.insitarq
        FROM tbepr_boleto_arq arq
       WHERE UPPER(arq.nmarq_import) = UPPER(pr_nmarquiv);
		rw_arquivo cr_arquivo%ROWTYPE;

		-- Cursor para consultar cooperativa
		CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT 1
        FROM crapcop
       WHERE cdcooper = pr_cdcooper
         AND flgativo = 1;
		rw_crapcop cr_crapcop%ROWTYPE;

		-- Cursor para consultar associado
		CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT 1
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
		rw_crapass cr_crapass%ROWTYPE;
    
		-- Cursor para consultar contrato
		CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE,
                      pr_nrdconta IN crapepr.nrdconta%TYPE,
                      pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT 1
        FROM crapepr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp;
		rw_crapepr cr_crapepr%ROWTYPE;
    
    -- Vari�veis de controle de calend�rio
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    ----------------------------- SUBROTINAS INTERNAS -------------------------------

    -- Inclusao da critica
    PROCEDURE pc_inclui_critica(pr_idarquivo IN tbepr_boleto_critic.idarquivo%TYPE,
                                pr_idboleto  IN tbepr_boleto_critic.idboleto%TYPE,
                                pr_idmotivo  IN tbepr_boleto_critic.idmotivo%TYPE,
                                pr_vlrcampo  IN tbepr_boleto_critic.vlcampo%TYPE) IS
    BEGIN

    	BEGIN
        INSERT INTO tbepr_boleto_critic (idarquivo,idboleto,idmotivo,vlcampo)
             VALUES (pr_idarquivo,pr_idboleto,pr_idmotivo,pr_vlrcampo);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao incluir critica: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    END pc_inclui_critica;

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

      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      -- Seta as variaveis
      vr_nmarquiv := TRIM(pr_nmarquiv);
      vr_dsdireto := GENE0001.fn_param_sistema('CRED', vr_cdcooper, 'DIR_IMP_BOL_MASSIVA');
      vr_vet_arqv := GENE0002.fn_quebra_string(pr_string  => vr_nmarquiv, pr_delimit => '.');
      vr_dsextens := LOWER(vr_vet_arqv(2));
      vr_nmarquiv := vr_vet_arqv(1) || '.' || vr_dsextens;
      vr_dsdirarq := vr_dsdireto || vr_nmarquiv;

      -- Se NAO for CSV
      IF vr_dsextens <> 'csv' THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Extens�o de arquivo n�o permitida.';
        RAISE vr_exc_saida;
      END IF;

      -- Se NAO encontrar o arquivo com a extensao em letras minusculas
      IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq) THEN
        vr_nmarquiv := vr_vet_arqv(1) || '.' || UPPER(vr_dsextens);
        vr_dsdirarq := vr_dsdireto || vr_nmarquiv;
        -- Se NAO encontrar o arquivo com a extensao em letras maiusculas
        IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq) THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Arquivo n�o encontrado no diret�rio.';
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Se for maior que 2MB 2117502
      IF GENE0001.fn_tamanho_arquivo(pr_caminho => vr_dsdirarq) > 2048000 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Arquivo informado possui tamanho superior ao permitido. Tamanho m�ximo 2MB.';
        RAISE vr_exc_saida;
      END IF;

      -- Consulta arquivo
      OPEN cr_arquivo(pr_nmarquiv => vr_nmarquiv);
      FETCH cr_arquivo INTO rw_arquivo;
      vr_blnachou := cr_arquivo%FOUND;
      CLOSE cr_arquivo;

      -- Se achou
      IF vr_blnachou THEN

        -- Se ja estiver processado
        IF rw_arquivo.insitarq = 1 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Arquivo j� processado. N�o permitido efetuar reimporta��o.';
          RAISE vr_exc_saida;
        END IF;

        -- Se ainda NAO foi confirmado Reimportacao
        IF pr_flgreimp = 0 THEN
           pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><flgreimp>1</flgreimp></Root>');
           RETURN; -- Sai para pedir confirmacao
        END IF;

        BEGIN

          UPDATE tbepr_boleto_arq
             SET dtarquivo = SYSDATE
                ,cdoperad  = vr_cdoperad
           WHERE idarquivo = rw_arquivo.idarquivo;

        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar: ' || SQLERRM;
          RAISE vr_exc_saida;
        END;

      -- Se NAO achou
      ELSE

        BEGIN

          INSERT INTO tbepr_boleto_arq (idarquivo,dtarquivo,cdoperad,nmarq_import,insitarq)
               VALUES ((SELECT (NVL(MAX(idarquivo), 0) + 1) FROM tbepr_boleto_arq),
                        SYSDATE,vr_cdoperad,vr_nmarquiv,0) -- 0 = Pendente
            RETURNING idarquivo INTO rw_arquivo.idarquivo;

        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao incluir: ' || SQLERRM;
          RAISE vr_exc_saida;
        END;

      END IF; -- vr_blnachou

      BEGIN

        DELETE 
          FROM tbepr_boleto_import
         WHERE idarquivo = rw_arquivo.idarquivo;

        DELETE 
          FROM tbepr_boleto_critic
         WHERE idarquivo = rw_arquivo.idarquivo;

      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao excluir: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      -- Abrir arquivo
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto   --> Diret�rio do arquivo
                              ,pr_nmarquiv => vr_nmarquiv   --> Nome do arquivo
                              ,pr_tipabert => 'R'           --> Modo de abertura
                              ,pr_utlfileh => vr_arqhandl   --> Handle arquiv aberto
                              ,pr_des_erro => vr_dscritic); --> Erro
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

      LOOP
        -- Verifica se o arquivo esta aberto
        IF utl_file.IS_OPEN(vr_arqhandl) THEN

          vr_idboleto := vr_idboleto + 1;

          BEGIN 
            -- Faz a leitura da linha
            GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqhandl   --> Arquivo aberto
                                        ,pr_des_text => vr_dsdlinha); --> Texto lido
          EXCEPTION
            WHEN no_data_found THEN
              -- Fechamos o arquivo
              GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandl); 
              EXIT;
          END;

          --1COOPERATIVA;2CONTA;3CONTRATO;4CPF AVAL;5FORMA ENVIO;6%ACRESCIMO;7%DESCONTO;8DATA VENCTO;9DDD;10FONE;11EMAIL;12ENDERECO
          vr_vet_dado := GENE0002.fn_quebra_string(pr_string => vr_dsdlinha, pr_delimit => ';');

          -- Valida Cooperativa -------------------------------------------
          BEGIN
            vr_lin_cdcooper := TO_NUMBER(NVL(vr_vet_dado(1),0));
            OPEN cr_crapcop(pr_cdcooper => vr_lin_cdcooper);
            FETCH cr_crapcop INTO rw_crapcop;
            vr_blnachou := cr_crapcop%FOUND;
            CLOSE cr_crapcop;
          EXCEPTION
            WHEN OTHERS THEN
              vr_blnachou := FALSE;
          END;

          -- Se NAO achou
          IF NOT vr_blnachou THEN
            vr_dscritic := 'Arquivo possui Cooperativa nao informada ou invalida. Processo de Importacao Cancelado. (' || to_char(vr_idboleto) || ')';
            RAISE vr_exc_saida;
            
          END IF;

          -- Valida Associado -------------------------------------------
          BEGIN
            vr_lin_nrdconta := TO_NUMBER(NVL(vr_vet_dado(2),0));
            OPEN cr_crapass(pr_cdcooper => vr_lin_cdcooper,
                            pr_nrdconta => vr_lin_nrdconta);
            FETCH cr_crapass INTO rw_crapass;
            vr_blnachou := cr_crapass%FOUND;
            CLOSE cr_crapass;
          EXCEPTION
            WHEN OTHERS THEN
              vr_blnachou := FALSE;
          END;

          -- Se NAO achou
          IF NOT vr_blnachou THEN
            vr_dscritic := 'Arquivo possui Conta nao informada ou invalida. Processo de Importacao Cancelado. (' || to_char(vr_idboleto) || ')';
            RAISE vr_exc_saida;
          END IF;

          -- Valida Contrato -------------------------------------------
          BEGIN
            vr_lin_nrctremp := TO_NUMBER(NVL(vr_vet_dado(3),0));
            -- Consulta contrato
            OPEN cr_crapepr(pr_cdcooper => vr_lin_cdcooper,
                            pr_nrdconta => vr_lin_nrdconta,
                            pr_nrctremp => vr_lin_nrctremp);
            FETCH cr_crapepr INTO rw_crapepr;
            vr_blnachou := cr_crapepr%FOUND;
            CLOSE cr_crapepr;
          EXCEPTION
            WHEN OTHERS THEN
              vr_blnachou := FALSE;
          END;

          -- Se NAO achou
          IF NOT vr_blnachou THEN
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 41, -- Contrato nao informado ou invalido.
                              pr_vlrcampo  => vr_vet_dado(3));
            vr_lin_nrctremp := 0;
          END IF;

          -- Valida CPF do Avalista -------------------------------------------
          BEGIN
            vr_blnachou     := TRUE;
            vr_lin_nrcpfava := TO_NUMBER(NVL(REPLACE(REPLACE(vr_vet_dado(4),'-',''),'.',''),0));
            IF vr_lin_nrcpfava > 0 THEN
              -- Listar avalistas de contratos
              DSCT0002.pc_lista_avalistas(pr_cdcooper => vr_lin_cdcooper  --> C�digo da Cooperativa
                                         ,pr_cdagenci => vr_cdagenci      --> C�digo da agencia
                                         ,pr_nrdcaixa => vr_nrdcaixa      --> Numero do caixa do operador
                                         ,pr_cdoperad => vr_cdoperad      --> C�digo do Operador
                                         ,pr_nmdatela => vr_nmdatela      --> Nome da tela
                                         ,pr_idorigem => vr_idorigem      --> Identificador de Origem
                                         ,pr_nrdconta => vr_lin_nrdconta  --> Numero da conta do cooperado
                                         ,pr_idseqttl => 1                --> Sequencial do titular
                                         ,pr_tpctrato => 1                --> Emprestimo  
                                         ,pr_nrctrato => vr_lin_nrctremp  --> Numero do contrato
                                         ,pr_nrctaav1 => 0                --> Numero da conta do primeiro avalista
                                         ,pr_nrctaav2 => 0                --> Numero da conta do segundo avalista
                                          --------> OUT <--------                                   
                                         ,pr_tab_dados_avais => vr_tab_aval   --> retorna dados do avalista
                                         ,pr_cdcritic        => vr_cdcritic   --> C�digo da cr�tica
                                         ,pr_dscritic        => vr_dscritic); --> Descri��o da cr�tica
              
              IF NVL(vr_cdcritic,0) > 0 OR 
                 TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;

              -- Reseta booleana
              vr_blnachou := FALSE;
              -- Buscar Primeiro registro
              vr_index:= vr_tab_aval.FIRST;
              -- Percorrer todos os registros
              WHILE vr_index IS NOT NULL LOOP
                IF vr_lin_nrcpfava = vr_tab_aval(vr_index).nrcpfcgc THEN
                  vr_blnachou := TRUE;
                  EXIT; -- Sai do loop
                END IF;
                -- Proximo Registro
                vr_index:= vr_tab_aval.NEXT(vr_index);
              END LOOP;
            END IF; -- vr_lin_nrcpfava > 0
          EXCEPTION
            WHEN OTHERS THEN
              vr_blnachou := FALSE;
          END;

          -- Se NAO achou
          IF NOT vr_blnachou THEN
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 42, -- CPF do aval invalido.
                              pr_vlrcampo  => vr_vet_dado(4));
            vr_lin_nrcpfava := NULL;
          END IF;

          -- Valida Forma de Envio -------------------------------------------
          BEGIN
            vr_blnachou     := TRUE;
            vr_lin_tipenvio := TO_NUMBER(NVL(vr_vet_dado(5),0));
            -- Se NAO for 1 - Email / 2 � SMS / 3 � Carta
            IF vr_lin_tipenvio NOT IN (1,2,3) THEN
               vr_blnachou := FALSE;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              vr_blnachou := FALSE;
          END;

          -- Se NAO achou
          IF NOT vr_blnachou THEN
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 50, -- Forma de envio do boleto nao informada ou invalida.
                              pr_vlrcampo  => vr_vet_dado(5));
            vr_lin_tipenvio := NULL;
          END IF;

          -- Valida Percentual de Acrescimo -------------------------------------------
          BEGIN
            vr_blnachou     := TRUE;
            vr_lin_per_acre := TO_NUMBER(NVL(vr_vet_dado(6),0));
          EXCEPTION
            WHEN OTHERS THEN
              vr_blnachou := FALSE;
          END;

          -- Se NAO achou
          IF NOT vr_blnachou THEN
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 43, -- Percentual de acrescimo invalido ou maior que permitido.
                              pr_vlrcampo  => vr_vet_dado(6));
            vr_lin_per_acre := NULL;
          END IF;

          -- Valida Percentual de Desconto -------------------------------------------
          BEGIN
            vr_blnachou     := TRUE;
            vr_lin_per_desc := TO_NUMBER(NVL(vr_vet_dado(7),0));
            IF vr_lin_per_desc >= 100 OR vr_lin_per_desc = 0 THEN
               vr_blnachou := FALSE;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              vr_blnachou := FALSE;
          END;

          -- Se NAO achou
          IF NOT vr_blnachou THEN
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 44, -- Percentual de desconto invalido ou maior que permitido
                              pr_vlrcampo  => vr_vet_dado(7));
            vr_lin_per_desc := NULL;
          END IF;

          -- Valida Percentual de Acrescimo -------------------------------------------
          IF vr_lin_per_acre IS NOT NULL AND vr_lin_per_desc IS NOT NULL THEN
              
            IF vr_lin_per_acre > vr_lin_per_desc THEN
              pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                                pr_idboleto  => vr_idboleto,
                                pr_idmotivo  => 43, -- Percentual de acrescimo invalido ou maior que permitido.
                                pr_vlrcampo  => vr_vet_dado(6));
            END IF;
          
          END IF;

          -- Valida Data de Vencimento -------------------------------------------
          BEGIN
            vr_blnachou     := TRUE;
            vr_lin_dtvencto := TO_DATE(vr_vet_dado(8),'DD/MM/RRRR');
            
            IF vr_lin_dtvencto < rw_crapdat.dtmvtolt OR
               vr_lin_dtvencto > (rw_crapdat.dtmvtolt + 30) THEN
              vr_blnachou := FALSE;
            END IF;
            
          EXCEPTION
            WHEN OTHERS THEN
              vr_blnachou := FALSE;
          END;

          -- Se NAO achou
          IF NOT vr_blnachou THEN
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 45, -- Data de vencimento em branco ou invalida.
                              pr_vlrcampo  => vr_vet_dado(8));
            vr_lin_dtvencto := NULL;
          END IF;

          -- Valida DDD do Telefone -------------------------------------------
          BEGIN
            vr_blnachou     := TRUE;
            vr_lin_dsdnrddd := TO_NUMBER(NVL(vr_vet_dado(9),0));
            -- Se for SMS e NAO foi informado DDD
            IF vr_lin_tipenvio = 2         AND 
               LENGTH(vr_lin_dsdnrddd) < 2 THEN
               vr_blnachou := FALSE;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              vr_blnachou := FALSE;
          END;

          -- Se NAO achou
          IF NOT vr_blnachou THEN
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 46, -- DDD nao informado ou  invalido.
                              pr_vlrcampo  => vr_vet_dado(9));
            vr_lin_dsdnrddd := NULL;
          END IF;

          -- Valida Numero do Telefone -------------------------------------------
          BEGIN
            vr_blnachou     := TRUE;
            vr_lin_telefone := TO_NUMBER(NVL(REPLACE(vr_vet_dado(10),'-',''),0));
            -- Se for SMS e NAO foi informado Telefone
            IF vr_lin_tipenvio = 2         AND 
               LENGTH(vr_lin_telefone) < 9 THEN
               vr_blnachou := FALSE;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              vr_blnachou := FALSE;
          END;

          -- Se NAO achou
          IF NOT vr_blnachou THEN
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 47, -- Telefone nao informado ou  invalido.
                              pr_vlrcampo  => vr_vet_dado(10));
            vr_lin_telefone := NULL;
          END IF;

          -- Valida Email -------------------------------------------
          vr_lin_dsdemail := TRIM(vr_vet_dado(11));
          -- Se for Email e NAO foi informado Telefone
          IF vr_lin_tipenvio = 1                                           AND 
             GENE0003.fn_valida_email(pr_dsdemail => vr_lin_dsdemail) <> 1 THEN
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 48, -- E-mail nao informado ou  invalido.
                              pr_vlrcampo  => vr_lin_dsdemail);
            vr_lin_dsdemail := NULL;
          END IF;

          -- Valida Endereco -------------------------------------------
          vr_lin_endereco := TRIM(vr_vet_dado(12));
          -- Se for Carta e NAO foi informado Endereco
          IF vr_lin_tipenvio = 3     AND 
             TRIM(vr_lin_endereco) IS NULL THEN
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 49, -- Endereco nao informado.
                              pr_vlrcampo  => vr_lin_endereco);
            vr_lin_endereco := NULL;
          END IF;

          BEGIN

            INSERT INTO tbepr_boleto_import
              (idarquivo,idboleto,cdcooper,nrdconta,nrctremp,nrcpfaval,tpenvio,peracrescimo,
               perdesconto,dtvencto,nrddd_envio,nrfone_envio,dsemail_envio,dsendereco_envio)
            VALUES
              (rw_arquivo.idarquivo,vr_idboleto,vr_lin_cdcooper,vr_lin_nrdconta,vr_lin_nrctremp,
               vr_lin_nrcpfava,vr_lin_tipenvio,vr_lin_per_acre,vr_lin_per_desc,vr_lin_dtvencto,
               vr_lin_dsdnrddd,vr_lin_telefone,vr_lin_dsdemail,vr_lin_endereco);

          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir: ' || SQLERRM;
            RAISE vr_exc_saida;
          END;

        END IF; -- utl_file.IS_OPEN(vr_arqhandl)

      END LOOP; -- Linhas

      -- Geral LOG
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratado
                                ,pr_nmarqlog     => 'cobemp.log'
                                ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss')
                                                 || ' --> Operador ' || vr_cdoperad || ' '
                                                 || (CASE WHEN pr_flgreimp = 1 THEN 're' ELSE '' END)
                                                 || 'importou o arquivo ' || vr_nmarquiv || '.');
      COMMIT;

		EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_COBEMP.pc_importar_arquivo: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;
		END;

  END pc_importar_arquivo;
  
  PROCEDURE pc_gera_relatorio(pr_idarquiv   IN INTEGER        --> Nome do arquivo
                             ,pr_flgcriti   IN INTEGER        --> Flag somente critica (0 - Completo / 1 - Somente criticas)
                             ,pr_xmllog     IN VARCHAR2       --> XML com informa��es de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER    --> C�digo da cr�tica
                             ,pr_dscritic  OUT VARCHAR2       --> Descri��o da cr�tica
                             ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2) IS   --> Erros do processo
	  BEGIN
 	  /* .............................................................................

      Programa: pc_gera_relatorio
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lombardi
      Data    : Marco/2017                    Ultima atualizacao: 06/11/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a impressao do relatorio da remessa
                  (Pendente/Processada)

      Observacao: -----

      Alteracoes: Ajuste leitura crapcob (Daniel)
    ..............................................................................*/
		DECLARE

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto VARCHAR2(100);
    vr_tab_erro GENE0001.typ_tab_erro;
    
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis locais
    vr_nom_direto  VARCHAR2(200);
    vr_nom_arquivo VARCHAR2(200);
    vr_typsaida    VARCHAR2(100);
    vr_qtregistros INTEGER;
    
    -- Vari�vel para armazenar as informa��es em XML
    vr_des_xml CLOB;
      
    -------------------------------- CURSORES --------------------------------------

		-- Cursor para consultar arquivo
		CURSOR cr_arquivo(pr_idarquiv IN tbepr_boleto_arq.idarquivo%TYPE
                     ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT arq.idarquivo
            ,ope.nmoperad
            ,to_char(arq.dtarquivo, 'DD/MM/RRRR') dtarquivo
            ,to_char(arq.dtarquivo, 'HH:MI:SS') hrarquivo
            ,arq.nmarq_import
            ,arq.nmarq_gerado
            ,arq.insitarq idsituacao
            ,DECODE(arq.insitarq, 0, 'Pendente', 'Processado') dssituacao
        FROM tbepr_boleto_arq arq
            ,crapope ope
       WHERE arq.idarquivo = pr_idarquiv
         AND ope.cdcooper = pr_cdcooper
         AND UPPER(ope.cdoperad) = UPPER(arq.cdoperad);
		rw_arquivo cr_arquivo%ROWTYPE;

    -- Busca linhas de importa��o do boleto
		CURSOR cr_linha(pr_idarquiv IN tbepr_boleto_import.idarquivo%TYPE
                   ,pr_flgcriti IN INTEGER) IS
      SELECT imp.idarquivo
            ,imp.idboleto
            ,cop.nmrescop
            ,imp.nrdconta
            ,imp.nrctremp
            ,imp.nrcpfaval
            ,DECODE(imp.tpenvio,1,'E-mail',2,'SMS',3,'Carta') tpenvio
            ,to_char(imp.peracrescimo,'fm990d00') peracrescimo
            ,to_char(imp.perdesconto,'fm990d00') perdesconto
            ,to_char(imp.dtvencto,'DD/MM/RRRR') dtvencto
            ,DECODE(imp.tpenvio
                   ,1,imp.dsemail_envio
                   ,2,('('||imp.nrddd_envio||') '||gene0002.fn_mask(imp.nrfone_envio,'99999-9999'))
                   ,3,imp.dsendereco_envio) destino
        FROM tbepr_boleto_import imp
            ,crapcop cop
       WHERE imp.idarquivo = pr_idarquiv
         AND (pr_flgcriti = 0
         OR  EXISTS(SELECT 1
                      FROM tbepr_boleto_critic cri
                     WHERE cri.idarquivo = imp.idarquivo
                       AND cri.idboleto  = imp.idboleto))
         AND cop.cdcooper = imp.cdcooper;
    
    -- Busca qtd de linhas de importa��o do boleto
		CURSOR cr_linha_reg(pr_idarquiv IN tbepr_boleto_import.idarquivo%TYPE
                       ,pr_flgcriti IN INTEGER) IS
      SELECT COUNT(1) qtregistros
        FROM tbepr_boleto_import imp
            ,crapcop cop
       WHERE imp.idarquivo = pr_idarquiv
         AND (pr_flgcriti = 0
         OR  EXISTS(SELECT 1
                      FROM tbepr_boleto_critic cri
                     WHERE cri.idarquivo = imp.idarquivo
                       AND cri.idboleto  = imp.idboleto))
         AND cop.cdcooper = imp.cdcooper;
    rw_linha_reg cr_linha_reg%ROWTYPE;
    
    -- Busca as criticas do boleto
		CURSOR cr_critica(pr_idarquiv IN tbepr_boleto_critic.idarquivo%TYPE
                     ,pr_idboleto IN tbepr_boleto_critic.idboleto%TYPE) IS
      SELECT mot.dsmotivo
            ,cri.vlcampo
        FROM tbepr_boleto_critic cri
            ,tbgen_motivo mot
       WHERE cri.idarquivo = pr_idarquiv
         AND cri.idboleto = pr_idboleto
         AND mot.idmotivo = cri.idmotivo;
    
    --Busca boletos
    CURSOR cr_boleto(pr_idarquiv IN tbepr_boleto_arq.idarquivo%TYPE) IS
      SELECT cop.nmrescop
            ,gene0002.fn_mask_conta(epr.nrdconta) nrdconta
            ,gene0002.fn_mask_contrato(epr.nrctremp) nrctremp
            ,DECODE(imp.nrcpfaval, 0,'Devedor','Avalista') insacado
            ,sab.nmdsacad
            ,DECODE(imp.tpenvio,1,'E-mail',2,'SMS',3,'Carta') tpenvio
            ,to_char(cob.vltitulo,'fm999g999g999g990d00') vltitulo
            ,to_char(cob.dtvencto,'DD/MM/RRRR') dtvencto
            ,imp.dserrger
            ,imp.nrcpfaval
            ,ass.nrcpfcgc
        FROM tbepr_boleto_import imp
            ,tbepr_cobranca epr
            ,crapcob cob
            ,crapcop cop
            ,crapass ass
            ,crapsab sab
			,crapcco cco
       WHERE imp.idarquivo = pr_idarquiv
         AND epr.idarquivo = imp.idarquivo
         AND epr.idboleto  = imp.idboleto

		 -- Leitura CCO
         AND cco.cdcooper = epr.cdcooper
         AND cco.nrconven = epr.nrcnvcob

         AND cob.cdcooper = epr.cdcooper
         AND cob.nrdconta = epr.nrdconta_cob
         AND cob.nrcnvcob = epr.nrcnvcob
         AND cob.nrdocmto = epr.nrboleto

		 AND cob.cdbandoc = cco.cddbanco
         AND cob.nrdctabb = cco.nrdctabb

         AND cop.cdcooper = imp.cdcooper
         AND ass.cdcooper = imp.cdcooper
         AND ass.nrdconta = imp.nrdconta
         AND sab.cdcooper = cob.cdcooper
         AND sab.nrdconta = epr.nrdconta_cob
         AND sab.nrinssac = DECODE(imp.nrcpfaval, 0,ass.nrcpfcgc,imp.nrcpfaval);
    
    --Busca boletos
    CURSOR cr_boleto_reg(pr_idarquiv IN tbepr_boleto_arq.idarquivo%TYPE) IS
      SELECT count(1) qtregistros
        FROM tbepr_boleto_import imp
            ,tbepr_cobranca epr
            ,crapcob cob
            ,crapcop cop
            ,crapass ass
            ,crapsab sab
			,crapcco cco
       WHERE imp.idarquivo = pr_idarquiv
         AND epr.idarquivo = imp.idarquivo
         AND epr.idboleto  = imp.idboleto

		 -- Leitura CCO
         AND cco.cdcooper = epr.cdcooper
         AND cco.nrconven = epr.nrcnvcob

         AND cob.cdcooper = epr.cdcooper
         AND cob.nrdconta = epr.nrdconta_cob
         AND cob.nrcnvcob = epr.nrcnvcob
         AND cob.nrdocmto = epr.nrboleto

		 AND cob.cdbandoc = cco.cddbanco
         AND cob.nrdctabb = cco.nrdctabb

         AND cop.cdcooper = imp.cdcooper
         AND ass.cdcooper = imp.cdcooper
         AND ass.nrdconta = imp.nrdconta
         AND sab.cdcooper = cob.cdcooper
         AND sab.nrdconta = epr.nrdconta_cob
         AND sab.nrinssac = DECODE(imp.nrcpfaval, 0,ass.nrcpfcgc,imp.nrcpfaval);
    rw_boleto_reg cr_boleto_reg%ROWTYPE;
    
    --Busca criticas
    CURSOR cr_boleto_critica(pr_idarquiv IN tbepr_boleto_arq.idarquivo%TYPE) IS
      SELECT cop.nmrescop
            ,gene0002.fn_mask_conta(imp.nrdconta) nrdconta
            ,gene0002.fn_mask_contrato(imp.nrctremp) nrctremp
            ,DECODE(imp.nrcpfaval, 0,'Devedor','Avalista') insacado
            ,DECODE(imp.tpenvio,1,'E-mail',2,'SMS',3,'Carta') tpenvio
            ,to_char(imp.dtvencto,'DD/MM/RRRR') dtvencto
            ,imp.dserrger
        FROM tbepr_boleto_import imp
            ,crapcop cop
       WHERE imp.idarquivo = pr_idarquiv
         AND cop.cdcooper = imp.cdcooper
         AND TRIM(imp.dserrger) IS NOT NULL;
    
    --Busca criticas
    CURSOR cr_boleto_critica_reg(pr_idarquiv IN tbepr_boleto_arq.idarquivo%TYPE) IS
      SELECT COUNT(1) qtregistros
        FROM tbepr_boleto_import imp
            ,crapcop cop
       WHERE imp.idarquivo = pr_idarquiv
         AND cop.cdcooper = imp.cdcooper
         AND TRIM(imp.dserrger) IS NOT NULL;
    rw_boleto_critica_reg cr_boleto_critica_reg%ROWTYPE;
    
    -- Vari�veis de controle de calend�rio
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
    --Escrever no arquivo CLOB
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
    END;
    
    ----------------------------- SUBROTINAS INTERNAS -------------------------------

    BEGIN
            -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gera_relatorio'
                                ,pr_action => NULL);

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
      
      
      -- Se houver criticas
      IF vr_dscritic IS NOT NULL THEN
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;
      
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      OPEN cr_arquivo(pr_idarquiv => pr_idarquiv
                     ,pr_cdcooper => vr_cdcooper);
      FETCH cr_arquivo INTO rw_arquivo;
      IF cr_arquivo%NOTFOUND THEN
        CLOSE cr_arquivo;
        vr_cdcritic := 0;
        vr_dscritic := '';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_arquivo;
      
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      
      -- Inicilizar as informacoes do XML
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>' || 
                     '<raiz><cabecalho>' ||
                               '<idarquivo>'    || rw_arquivo.idarquivo    || '</idarquivo>'    ||
                               '<nmoperad>'     || rw_arquivo.nmoperad     || '</nmoperad>'     ||
                               '<dtarquivo>'    || rw_arquivo.dtarquivo    || '</dtarquivo>'    ||
                               '<hrarquivo>'    || rw_arquivo.hrarquivo    || '</hrarquivo>'    ||
                               '<nmarq_import>' || rw_arquivo.nmarq_import || '</nmarq_import>' ||
                               '<nmarq_gerado>' || rw_arquivo.nmarq_gerado || '</nmarq_gerado>' ||
                               '<dssituacao>'   || rw_arquivo.dssituacao   || '</dssituacao>'  ||
                           '</cabecalho>');
      
      -- Pendente
      IF rw_arquivo.idsituacao = 0 THEN
        
        --Verifica se tem registro
        OPEN cr_linha_reg(pr_idarquiv => pr_idarquiv
                         ,pr_flgcriti => pr_flgcriti);
        FETCH cr_linha_reg INTO rw_linha_reg;
        IF cr_linha_reg%FOUND THEN
          vr_qtregistros := rw_linha_reg.qtregistros;
        ELSE 
          vr_qtregistros := 0;
        END IF;
        CLOSE cr_linha_reg;
        
        -- Inicia XML
        pc_escreve_xml('<linhas qtlinhas="' || vr_qtregistros || '" >');
        
        FOR rw_linha IN cr_linha(pr_idarquiv => pr_idarquiv
                                ,pr_flgcriti => pr_flgcriti) LOOP
          
          -- popular linhas do XML
          pc_escreve_xml(
                      '<linha>' ||
                            '<idboleto>'       || rw_linha.idboleto         || '</idboleto>'     ||
                            '<nmrescop>'       || rw_linha.nmrescop         || '</nmrescop>'     ||
                            '<nrdconta>'       || rw_linha.nrdconta         || '</nrdconta>'     ||
                            '<nrctremp>'       || rw_linha.nrctremp         || '</nrctremp>'     ||
                            '<nrcpfaval>'      || rw_linha.nrcpfaval        || '</nrcpfaval>'    ||
                            '<tipo_envio>'     || rw_linha.tpenvio          || '</tipo_envio>'   ||
                            '<percent_acre>'   || rw_linha.peracrescimo     || '</percent_acre>' ||
                            '<percent_desc>'   || rw_linha.perdesconto      || '</percent_desc>' ||
                            '<dtvencto>'       || rw_linha.dtvencto         || '</dtvencto>'     ||
                            '<destino>'        || rw_linha.destino          || '</destino>'      ||
                            '<criticas>');

                            FOR rw_critica IN cr_critica(pr_idarquiv => pr_idarquiv
                                                        ,pr_idboleto => rw_linha.idboleto) LOOP
                                  
                              -- popular as criticas
                              pc_escreve_xml('<critica>' ||
                                                    '<dsmotivo>' || rw_critica.dsmotivo || '</dsmotivo>' ||
                                                    '<vlrcampo>' || rw_critica.vlcampo  || '</vlrcampo>' ||
                                             '</critica>');
                            END LOOP;
         
          pc_escreve_xml('</criticas></linha>');
          
        END LOOP;
      ELSE-- Processado
      
        --Verifica se tem registro
        OPEN cr_boleto_reg(pr_idarquiv => pr_idarquiv);
        FETCH cr_boleto_reg INTO rw_boleto_reg;
        IF cr_boleto_reg%FOUND THEN
          vr_qtregistros := rw_boleto_reg.qtregistros;
        ELSE 
          vr_qtregistros := 0;
        END IF;
        CLOSE cr_boleto_reg;
        
        -- Inicia XML
        pc_escreve_xml('<linhas qtlinhas="' || vr_qtregistros || '" >');
        
        FOR rw_boleto IN cr_boleto(pr_idarquiv => pr_idarquiv) LOOP
          
          -- popular linhas do XML
          pc_escreve_xml('<linha>' ||
                                '<nmrescop>' || rw_boleto.nmrescop   || '</nmrescop>' ||
                                '<nrdconta>' || rw_boleto.nrdconta   || '</nrdconta>' ||
                                '<nrctremp>' || rw_boleto.nrctremp   || '</nrctremp>' ||
                                '<insacado>' || rw_boleto.insacado   || '</insacado>' ||
                                '<nmdsacad>' || rw_boleto.nmdsacad   || '</nmdsacad>' ||
                                '<tpenvio>'  || rw_boleto.tpenvio    || '</tpenvio>'  ||
                                '<vltitulo>' || rw_boleto.vltitulo   || '</vltitulo>' ||
                                '<dtvencto>' || rw_boleto.dtvencto   || '</dtvencto>' ||
                         '</linha>');
        END LOOP;
        
      END IF;
      
      -- Fechar XML
      pc_escreve_xml('</linhas>');
      
      IF rw_arquivo.idsituacao = 1 THEN
        
        --Verifica se tem registro
        OPEN cr_boleto_critica_reg(pr_idarquiv => pr_idarquiv);
        FETCH cr_boleto_critica_reg INTO rw_boleto_critica_reg;
        IF cr_boleto_critica_reg%FOUND THEN
          vr_qtregistros := rw_boleto_critica_reg.qtregistros;
        ELSE 
          vr_qtregistros := 0;
        END IF;
        CLOSE cr_boleto_critica_reg;
        
        -- Inicia XML
        pc_escreve_xml('<criticas qtcriticas="' || vr_qtregistros || '" >');
        
        FOR rw_boleto_critica IN cr_boleto_critica(pr_idarquiv => pr_idarquiv) LOOP
          
          -- popular linhas do XML
           pc_escreve_xml('<critica>' ||
                                 '<nmrescop>' || rw_boleto_critica.nmrescop   || '</nmrescop>' ||
                                 '<nrdconta>' || rw_boleto_critica.nrdconta   || '</nrdconta>' ||
                                 '<nrctremp>' || rw_boleto_critica.nrctremp   || '</nrctremp>' ||
                                 '<insacado>' || rw_boleto_critica.insacado   || '</insacado>' ||
                                 '<tpenvio>'  || rw_boleto_critica.tpenvio    || '</tpenvio>'  ||
                                 '<dtvencto>' || rw_boleto_critica.dtvencto   || '</dtvencto>' ||
                                 '<dserrger>' || rw_boleto_critica.dserrger   || '</dserrger>' ||
                          '</critica>');
        END LOOP;
        
        -- Fechar XML	
        pc_escreve_xml('</criticas>');
        
      END IF;
      
      pc_escreve_xml('</raiz>');
      
      -- Busca do diret�rio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => 3 -- CECRED
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      -- Nome do arquivo
      vr_nom_arquivo := 'crrl733' || to_char( gene0002.fn_busca_time) || '.pdf';
      /*
      -- Escreve o clob no arquivo f�sico
      gene0002.pc_clob_para_arquivo(pr_clob => vr_des_xml
                                   ,pr_caminho => vr_nom_direto
                                   ,pr_arquivo => 'crrl733.xml'
                                   ,pr_des_erro => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      */
      -- Efetuar solicitacao de geracao de relatorio --
      gene0002.pc_solicita_relato (pr_cdcooper  => vr_cdcooper         --> Cooperativa conectada
                                  ,pr_cdprogra  => 'COBEMP'        --> Programa chamador
                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                  ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                  ,pr_dsxmlnode => '/raiz'             --> No base do XML para leitura dos dados
                                  ,pr_dsjasper  => 'crrl733.jasper'    --> Arquivo de layout do iReport
                                  ,pr_dsparams  => NULL                --> Titulo do relat�rio
                                  ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo --> Arquivo final
                                  ,pr_qtcoluna  => 234                 --> 132 colunas
                                  ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                  ,pr_flg_impri => 'N'                 --> Chamar a impress�o (Imprim.p)
                                  ,pr_nmformul  => NULL                --> Nome do formul�rio para impress�o
                                  ,pr_nrcopias  => 1                   --> N�mero de c�pias
                                  ,pr_flg_gerar => 'S'                 --> gerar PDF
                                  ,pr_nrvergrl  => 1                   --> JasperSoft Studio
                                  ,pr_dspathcop => ''                  --> Copiar arquivo para diretorio
                                  ,pr_flgremarq => 'N'                 --> Remover arquivo apos copia
                                  ,pr_des_erro  => vr_dscritic);       --> Sa�da com erro
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar excecao
        RAISE vr_exc_saida;
      END IF;
      
      -- Liberando a memoria alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                  ,pr_cdagenci => NULL
                                  ,pr_nrdcaixa => NULL
                                  ,pr_nmarqpdf => vr_nom_direto ||'/'||vr_nom_arquivo
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se retornou erro
      IF NVL(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_saida; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_nom_direto ||'/'||vr_nom_arquivo
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_saida; -- encerra programa
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nom_arquivo
                            ,pr_des_erro => vr_dscritic);
                    
		EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_COBEMP.pc_importar_arquivo: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;
		END;

  END pc_gera_relatorio;
  
  PROCEDURE pc_gera_boletagem(pr_idarquiv   IN INTEGER        --> Nome do arquivo
                             ,pr_xmllog     IN VARCHAR2       --> XML com informa��es de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER    --> C�digo da cr�tica
                             ,pr_dscritic  OUT VARCHAR2       --> Descri��o da cr�tica
                             ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2) IS   --> Erros do processo
	  BEGIN
 	  /* .............................................................................

      Programa: pc_gera_boletagem
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lombardi
      Data    : Marco/2017                    Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a geracao de boletos atraves da
                  boletagem massiva.

      Observacao: -----

      Alteracoes: 
    ..............................................................................*/
		DECLARE

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_flcritic BOOLEAN := FALSE;
    
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Vari�veis Auxiliares
    vr_vlsdeved crapepr.vlsdeved%TYPE;
    vr_vlatraso crapepr.vlsdeved%TYPE;
		vr_vlsdprej NUMBER(25,2);
    vr_vlparepr  NUMBER(25,2);
    vr_vldescto NUMBER(25,2);
    vr_vlacresc NUMBER(25,2);
    vr_vlorigem NUMBER(25,2);
    vr_tpparepr NUMBER;
    vr_dsmsg    VARCHAR2(200);
    vr_index    PLS_INTEGER;
    vr_nmarquiv VARCHAR2(200);
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_exc_critica EXCEPTION;
    
    vr_nrdconta_cob crapsab.nrdconta%TYPE;
    vr_nrcnvcob     crapcob.nrcnvcob%TYPE;
    
    -- Retorno OK/NOK
    vr_des_erro VARCHAR(3);            
    
    -- Tabela temporaria para os vencimento
    TYPE typ_reg_crapprm IS
     RECORD(nrctacob crapass.nrdconta%TYPE,
            nrcnvcob crapcob.nrcnvcob%TYPE);
    TYPE typ_tab_crapprm IS
      TABLE OF typ_reg_crapprm
        INDEX BY PLS_INTEGER;
    
    TYPE typ_reg_import IS
     RECORD(idarquivo        tbepr_boleto_import.idarquivo%TYPE
           ,idboleto         tbepr_boleto_import.idboleto%TYPE
           ,cdcooper         tbepr_boleto_import.cdcooper%TYPE
           ,nrdconta         tbepr_boleto_import.nrdconta%TYPE
           ,nrctremp         tbepr_boleto_import.nrctremp%TYPE
           ,nrcpfaval        tbepr_boleto_import.nrcpfaval%TYPE
           ,tpenvio          tbepr_boleto_import.tpenvio%TYPE
           ,peracrescimo     tbepr_boleto_import.peracrescimo%TYPE
           ,perdesconto      tbepr_boleto_import.perdesconto%TYPE
           ,dtvencto         tbepr_boleto_import.dtvencto%TYPE
           ,nrddd_envio      tbepr_boleto_import.nrddd_envio%TYPE
           ,nrfone_envio     tbepr_boleto_import.nrfone_envio%TYPE
           ,dsemail_envio    tbepr_boleto_import.dsemail_envio%TYPE
           ,dsendereco_envio tbepr_boleto_import.dsendereco_envio%TYPE
           ,row_id           ROWID);
    TYPE typ_tab_import IS
      TABLE OF typ_reg_import
        INDEX BY PLS_INTEGER;
    
    -- Vetor para armazenar os convenios e contas 
    vr_tab_crapprm typ_tab_crapprm;
    
    -- Vetor para armazenar os convenios e contas 
    vr_tab_import typ_tab_import;
    
    vr_flgativo INTEGER := 0;
      
    -------------------------------- CURSORES --------------------------------------

		-- Cursor para consultar arquivo
		CURSOR cr_arquivo(pr_idarquiv IN tbepr_boleto_arq.idarquivo%TYPE) IS
      SELECT arq.idarquivo
            ,to_char(arq.dtarquivo, 'DD/MM/RRRR') dtarquivo
            ,to_char(arq.dtarquivo, 'HH:MI:SS') hrarquivo
            ,arq.nmarq_import
            ,arq.nmarq_gerado
            ,arq.insitarq
        FROM tbepr_boleto_arq arq
       WHERE arq.idarquivo = pr_idarquiv;
       
		rw_arquivo cr_arquivo%ROWTYPE;

    -- Busca linhas de importa��o do boleto
		CURSOR cr_linha(pr_idarquiv IN tbepr_boleto_import.idarquivo%TYPE) IS
      SELECT imp.idarquivo
            ,imp.idboleto
            ,imp.cdcooper
            ,imp.nrdconta
            ,imp.nrctremp
            ,imp.nrcpfaval
            ,imp.tpenvio
            ,imp.peracrescimo
            ,imp.perdesconto
            ,imp.dtvencto
            ,imp.nrddd_envio
            ,imp.nrfone_envio
            ,imp.dsemail_envio
            ,imp.dsendereco_envio
            ,imp.rowid
        FROM tbepr_boleto_import imp
       WHERE imp.idarquivo = pr_idarquiv;
       
    CURSOR cr_criticas(pr_idarquiv IN tbepr_boleto_critic.idarquivo%TYPE) IS   
       SELECT COUNT(*) qtdcriticas
         FROM tbepr_boleto_critic cri
        WHERE cri.idarquivo = pr_idarquiv;
    rw_criticas cr_criticas%ROWTYPE;
        
    -- Cursor cooperativas ativas 
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.flgativo = 1;
       
    -- Cursor para localizar contrato de emprestimo
		CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN crapepr.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
			SELECT epr.tpemprst,
             epr.inliquid,
             epr.inprejuz
			  FROM crapepr epr
			 WHERE epr.cdcooper = pr_cdcooper
				 AND epr.nrdconta = pr_nrdconta
				 AND epr.nrctremp = pr_nrctremp;
		rw_crapepr cr_crapepr%ROWTYPE;   

    -- Vari�veis de controle de calend�rio
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
    ----------------------------- SUBROTINAS INTERNAS -------------------------------

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
      
      -- Se houver criticas
      IF vr_dscritic IS NOT NULL THEN
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;
      
      OPEN cr_arquivo(pr_idarquiv => pr_idarquiv);
      FETCH cr_arquivo INTO rw_arquivo;
      
      IF cr_arquivo%NOTFOUND THEN
        -- Fecha Cursor
        CLOSE cr_arquivo;
        
        vr_cdcritic := 0;
        vr_dscritic := 'Remessa n�o localizada.';
        RAISE vr_exc_saida;
      END IF;
      -- Fecha Cursor
      CLOSE cr_arquivo;
      
      -- Verifica se remessa j� foi processada
      IF rw_arquivo.insitarq = 1 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Remessa j� Processada. N�o permitido gera��o de boletagem.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se remessa possui criticas noa rquivo importado.
      OPEN cr_criticas(pr_idarquiv => pr_idarquiv);
      FETCH cr_criticas INTO rw_criticas;
      
      -- Fecha Cursor
      CLOSE cr_criticas;
      
      IF rw_criticas.qtdcriticas > 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Remessas com criticas. N�o permitido gera��o de boletagem.';
        RAISE vr_exc_saida;
      END IF;
      
      FOR rw_crapcop IN cr_crapcop LOOP
        
        -- Localizar conta do emitente do boleto, neste caso a cooperativa
        vr_nrdconta_cob := GENE0002.fn_char_para_number(gene0001.fn_param_sistema(pr_cdcooper => rw_crapcop.cdcooper
																										   ,pr_nmsistem => 'CRED'
																										   ,pr_cdacesso => 'COBEMP_NRDCONTA_BNF'));

        -- Localizar convenio de cobran�a
        vr_nrcnvcob := gene0001.fn_param_sistema(pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_cdacesso => 'COBEMP_NRCONVEN');
        
        IF vr_nrdconta_cob = 0 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Convenio n�o cadastrado para cooperativa: ' || to_char(rw_crapcop.cdcooper);
          RAISE vr_exc_saida;
        END IF;                                        
        
        vr_tab_crapprm(rw_crapcop.cdcooper).nrctacob := vr_nrdconta_cob;
        vr_tab_crapprm(rw_crapcop.cdcooper).nrcnvcob := vr_nrcnvcob;                                         
                                                                                      
      END LOOP; 
      
      vr_index := 0;
      FOR rw_linha IN cr_linha(pr_idarquiv => pr_idarquiv) LOOP
        vr_tab_import(vr_index).idarquivo        := rw_linha.idarquivo;
        vr_tab_import(vr_index).idboleto         := rw_linha.idboleto;
        vr_tab_import(vr_index).cdcooper         := rw_linha.cdcooper;
        vr_tab_import(vr_index).nrdconta         := rw_linha.nrdconta;
        vr_tab_import(vr_index).nrctremp         := rw_linha.nrctremp;
        vr_tab_import(vr_index).nrcpfaval        := rw_linha.nrcpfaval;
        vr_tab_import(vr_index).tpenvio          := rw_linha.tpenvio;
        vr_tab_import(vr_index).peracrescimo     := rw_linha.peracrescimo;
        vr_tab_import(vr_index).perdesconto      := rw_linha.perdesconto;
        vr_tab_import(vr_index).dtvencto         := rw_linha.dtvencto;
        vr_tab_import(vr_index).nrddd_envio      := rw_linha.nrddd_envio;
        vr_tab_import(vr_index).nrfone_envio     := rw_linha.nrfone_envio;
        vr_tab_import(vr_index).dsemail_envio    := rw_linha.dsemail_envio;
        vr_tab_import(vr_index).dsendereco_envio := rw_linha.dsendereco_envio;
        vr_tab_import(vr_index).row_id           := rw_linha.rowid;
        vr_index := vr_index + 1;
      END LOOP;
      
      -- Efetua limpeza das criticas de gera��o anterior.
      BEGIN
            
        UPDATE tbepr_boleto_import imp
           SET imp.dserrger  = ' '
         WHERE imp.idarquivo = pr_idarquiv;
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao atualizar boletos: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;                      
      
      -- Inicializa flag de erro
      vr_flcritic := FALSE;
      
      vr_index := vr_tab_import.first;
      
      WHILE vr_index IS NOT NULL LOOP
        
        BEGIN
        
          -- Chama procedure de valida��o para gerar o boleto
          EMPR0007.pc_verifica_gerar_boleto (pr_cdcooper => vr_tab_import(vr_index).cdcooper --> C�d. cooperativa
                                            ,pr_nrctacob => vr_tab_crapprm(vr_tab_import(vr_index).cdcooper).nrcnvcob       --> Nr. da Conta Cob.
                                            ,pr_nrdconta => vr_tab_import(vr_index).nrdconta --> Nr. da Conta
                                            ,pr_nrcnvcob => vr_tab_crapprm(vr_tab_import(vr_index).cdcooper).nrctacob       --> Nr. do Conv�nio de Cobran�a
                                            ,pr_nrctremp => vr_tab_import(vr_index).nrctremp --> Nr. do Contrato
                                            ,pr_idarquiv => pr_idarquiv       --> Nr. do Arquivo (<> 0 = boletagem massiva)
                                            ,pr_cdcritic => vr_cdcritic       --> C�digo da cr�tica
                                            ,pr_dscritic => vr_dscritic       --> Descri��o da cr�tica
                                            ,pr_des_erro => vr_des_erro);     --> Erros do processo
          -- Se retornou erro
          IF vr_des_erro <> 'OK' THEN
            
            IF vr_dscritic IS NULL THEN
              vr_dscritic := 'Erro na verificacao da geracao do boleto.';
            END IF;

            RAISE vr_exc_critica;
            
          END IF;
        
          -- Verifica contratos de acordo
          RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => vr_tab_import(vr_index).cdcooper
                                           ,pr_nrdconta => vr_tab_import(vr_index).nrdconta
                                           ,pr_nrctremp => vr_tab_import(vr_index).nrctremp
                                           ,pr_cdorigem => 3
                                           ,pr_flgativo => vr_flgativo
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            -- Gerar exce��o
            RAISE vr_exc_critica;
          END IF;
         
          IF vr_flgativo = 1 THEN
            vr_dscritic := 'Gera��o de boleto n�o permitido, emprestimo em acordo.';
            -- Gerar exce��o
            RAISE vr_exc_critica;
          END IF;
          
          OPEN cr_crapepr(pr_cdcooper => vr_tab_import(vr_index).cdcooper
                         ,pr_nrdconta => vr_tab_import(vr_index).nrdconta
                         ,pr_nrctremp => vr_tab_import(vr_index).nrctremp);
          FETCH cr_crapepr INTO rw_crapepr;
    			
          IF cr_crapepr%NOTFOUND THEN
            --Fecha cursor
            CLOSE cr_crapepr;
            --Atribui cr�ticas
            vr_cdcritic := 0;
            vr_dscritic := 'Contrato n�o localizado.';
            -- Gera exce��o
            RAISE vr_exc_critica;
          END IF;
          --Fecha cursor
          CLOSE cr_crapepr;
          
          -- Leitura do calend�rio da cooperativa
          OPEN btch0001.cr_crapdat(pr_cdcooper => vr_tab_import(vr_index).cdcooper);
          FETCH btch0001.cr_crapdat INTO rw_crapdat;
          -- Se n�o encontrar
          IF btch0001.cr_crapdat%NOTFOUND THEN
            -- Fechar o cursor pois efetuaremos raise
            CLOSE btch0001.cr_crapdat;
            -- Montar mensagem de critica
            vr_cdcritic := 1;
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor
            CLOSE btch0001.cr_crapdat;
          END IF;
          
          --> Calcula o saldo do contrado do cooperado
          pc_calcular_saldo_contrato (pr_cdcooper   => vr_tab_import(vr_index).cdcooper, --> Codigo da Cooperativa
                                      pr_nrdconta   => vr_tab_import(vr_index).nrdconta, --> N�mero da Conta
                                      pr_cdorigem   => 2,                                --> Origem
                                      pr_nrctremp   => vr_tab_import(vr_index).nrctremp, --> Numero do Contrato
                                      pr_rw_crapdat => rw_crapdat,         --> Datas da cooperativa
                                      pr_vllimcre   => 0,                  --> Limite de credito do cooperado     
                                      pr_vlsdeved   => vr_vlsdeved,        --> Valor Saldo Devedor
                                      pr_vlsdprej   => vr_vlsdprej,        --> Valor Saldo Prejuizo
                                      pr_vlatraso   => vr_vlatraso,        --> Valor Atraso
                                      pr_cdcritic   => vr_cdcritic,        --> C�digo da Cr�tica
                                      pr_dscritic   => vr_dscritic);       --> Descri��o da Cr�tica
          
          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN       
            RAISE vr_exc_critica;
          END IF;
          
          IF rw_crapepr.inprejuz = 1 THEN
            vr_vlparepr := vr_vlsdprej;
            vr_vlorigem := vr_vlsdprej;
            vr_tpparepr := 5; -- Saldo Prejuizo
          ELSE          
            vr_vlparepr := vr_vlsdeved;
            vr_vlorigem := vr_vlsdeved;
            vr_tpparepr := 4; -- Saldo Contrato
          END IF;   
          
          IF nvl(vr_tab_import(vr_index).perdesconto,0) = 0 THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Percentual de Desconto nao Informado.';
            RAISE vr_exc_critica;
          END IF;
          
          -- Verificar Desconto e Acrescimo
          -- 1� Desconto
          IF nvl(vr_tab_import(vr_index).perdesconto,0) > 0 THEN
             
             vr_vldescto := ( vr_vlparepr * nvl(vr_tab_import(vr_index).perdesconto,0) ) / 100;
             vr_vlparepr := vr_vlparepr - vr_vldescto;
          END IF;  
          
          -- 2� Acrescimo
          IF nvl(vr_tab_import(vr_index).peracrescimo,0) > 0 THEN
             
             vr_vlacresc := ( vr_vlparepr * nvl(vr_tab_import(vr_index).peracrescimo,0) ) / 100;
             vr_vlparepr := vr_vlparepr + vr_vlacresc;
          END IF;   
          
          IF vr_vlparepr > vr_vlorigem THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Valor calculado superios ao saldo devedor.';
            RAISE vr_exc_critica;
          END IF;
          
          IF vr_vlparepr <= 0 THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Contrato n�o possui saldo devedor.';
            RAISE vr_exc_critica;
          END IF;
          
          pc_gera_boleto_contrato(pr_cdcooper => vr_tab_import(vr_index).cdcooper
                                 ,pr_nrdconta => vr_tab_import(vr_index).nrdconta
                                 ,pr_nrctremp => vr_tab_import(vr_index).nrctremp
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_tpparepr => vr_tpparepr
                                 ,pr_dsparepr => NULL
                                 ,pr_dtvencto => vr_tab_import(vr_index).dtvencto
                                 ,pr_vlparepr => vr_vlparepr
                                 ,pr_cdoperad => vr_cdoperad
                                 ,pr_nmdatela => vr_nmdatela
                                 ,pr_idorigem => vr_idorigem
                                 ,pr_nrcpfava => vr_tab_import(vr_index).nrcpfaval
                                 ,pr_idarquiv => pr_idarquiv
                                 ,pr_idboleto => vr_tab_import(vr_index).idboleto
                                 ,pr_peracres => vr_tab_import(vr_index).peracrescimo
                                 ,pr_perdesco => vr_tab_import(vr_index).perdesconto
                                 ,pr_vldescto => vr_vldescto
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
          
          -- Se retornou alguma cr�tica
          IF vr_cdcritic <> 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
             -- Levanta exce��o
             RAISE vr_exc_critica;
          END IF;
        
        EXCEPTION
          WHEN vr_exc_critica THEN
            vr_flcritic := TRUE;
            
            BEGIN
              UPDATE tbepr_boleto_import imp
                 SET imp.dserrger = vr_dscritic
               WHERE imp.rowid = vr_tab_import(vr_index).row_id;
               vr_dscritic := '';
            EXCEPTION
              WHEN OTHERS THEN
              vr_dscritic := 'Problema ao gerar boletagem massiva: ' || SQLERRM;
              RAISE vr_exc_saida;
            END;
            
        END;
        vr_index := vr_tab_import.next(vr_index);
        
      END LOOP;
      
      -- Atualizar a situa��o da remessa para "Processada"
      BEGIN
        UPDATE tbepr_boleto_arq arq
           SET arq.insitarq = 1
         WHERE arq.idarquivo = pr_idarquiv;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar a situa��o da remessa: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;
      
      COMMIT;
      IF vr_flcritic THEN
        vr_dsmsg := 'Opera��o efetuada com cr�ticas. Verifique relat�rio';
      ELSE
        vr_dsmsg := 'Opera��o efetuada com sucesso.';
      END IF;
      
      -- Gera arquivo do parceiro
      pc_gera_arquivo_parca(pr_idarquiv => pr_idarquiv
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_nmarquiv => vr_nmarquiv
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
      
      IF vr_cdcritic <> 0 OR
         vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'msg'
                            ,pr_tag_cont => vr_dsmsg
                            ,pr_des_erro => vr_dscritic);
            
		EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_COBEMP.pc_importar_arquivo: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;
		END;

  END pc_gera_boletagem;
  
  PROCEDURE pc_gera_boleto_contrato(pr_cdcooper IN  crapcob.cdcooper%TYPE --> C�digo da cooperativa;
																	 ,pr_nrdconta IN  crapcob.nrdconta%TYPE --> Conta do cooperado do contrato;
																	 ,pr_nrctremp IN  crapcob.nrctremp%TYPE --> N�mero do contrato de empr�stimo;
																	 ,pr_dtmvtolt IN  crapcob.dtmvtolt%TYPE --> Data do movimento;
																	 ,pr_tpparepr IN  NUMBER                --> Tipo de parcela 1 = Parcela Normal, 2 = Total do atraso 3 = Parcial do atraso 4 = Quita��o do contrato;
																	 ,pr_dsparepr IN  VARCHAR2 DEFAULT NULL /* Descri��o das parcelas do empr�stimo �par1,par2,par..., parN�;
																	 																						Obs: empr�stimo TR => NULL;
																	 																						Obs2: Quando for ref a v�rias parcelas do contrato, parcela = NULL;
																	 																						Obs3: Quando for quita��o do contrato, parcela = 0; */
																	 ,pr_dtvencto IN  crapcob.dtvencto%TYPE --> Vencimento do boleto;
																	 ,pr_vlparepr IN  crappep.vlparepr%TYPE --> Valor da parcela;
																	 ,pr_cdoperad IN  crapcob.cdoperad%TYPE --> C�digo do operador;
																	 ,pr_nmdatela IN VARCHAR2               --> Nome da tela
														       ,pr_idorigem IN INTEGER                --> ID Origem
                                   ,pr_nrcpfava IN NUMBER DEFAULT 0       --> CPF do avalista
																	 ,pr_idarquiv IN INTEGER DEFAULT 0      --> Id do arquivo (boletagem Massiva)
                                   ,pr_idboleto IN INTEGER DEFAULT 0      --> Id do boleto no arquivo (boletagem Massiva)
                                   ,pr_peracres IN NUMBER DEFAULT 0       --> Percentual de Desconto
                                   ,pr_perdesco IN NUMBER DEFAULT 0       --> Percentual de Acrescimo
                                   ,pr_vldescto IN NUMBER DEFAULT 0       --> Valor do desconto
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> C�digo da cr�tica
																	 ,pr_dscritic OUT crapcri.dscritic%TYPE --> Descri��o da cr�tica
																	 ) IS
	  /* .............................................................................

      Programa: pc_gera_boleto_contrato
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lombardi
      Data    : Marco/2017                    Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para chamar a procedure pc_gera_boleto_contrato 
                  da EMPR0007 com pragma.
                  
      Observacao: -----

      Alteracoes: 
    ..............................................................................*/
     -- Pragma - abre nova sessao para tratar a atualizacao
     PRAGMA AUTONOMOUS_TRANSACTION;

    BEGIN
      EMPR0007.pc_gera_boleto_contrato(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_tpparepr => pr_tpparepr
                                      ,pr_dsparepr => pr_dsparepr
                                      ,pr_dtvencto => pr_dtvencto
                                      ,pr_vlparepr => pr_vlparepr
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_nmdatela => pr_nmdatela
                                      ,pr_idorigem => pr_idorigem
                                      ,pr_nrcpfava => pr_nrcpfava
                                      ,pr_idarquiv => pr_idarquiv
                                      ,pr_idboleto => pr_idboleto
                                      ,pr_peracres => pr_peracres
                                      ,pr_perdesco => pr_perdesco
                                      ,pr_vldescto => pr_vldescto
                                      ,pr_cdcritic => pr_cdcritic
                                      ,pr_dscritic => pr_dscritic);
		EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao gerar boleto: ' || SQLERRM;
        ROLLBACK;
  END pc_gera_boleto_contrato;
  
  PROCEDURE pc_calcular_saldo_contrato (pr_cdcooper   IN  crapcop.cdcooper%TYPE,  --> Codigo da Cooperativa
                                        pr_nrdconta   IN  crapass.cdcooper%TYPE,  --> N�mero da Conta
                                        pr_cdorigem   IN  INTEGER,                --> Origem
                                        pr_nrctremp   IN  crapepr.nrctremp%TYPE,  --> Numero do Contrato
                                        pr_rw_crapdat IN  btch0001.cr_crapdat%ROWTYPE, --> Datas da cooperativa
                                        pr_vllimcre   IN crapass.vllimcre%TYPE,   --> Limite de credito do cooperado     
                                        pr_vlsdeved  OUT  NUMBER,                 --> Valor Saldo Devedor
                                        pr_vlsdprej  OUT  NUMBER,                 --> Valor Saldo Prejuizo
                                        pr_vlatraso  OUT  NUMBER,                 --> Valor Atraso
                                        pr_cdcritic  OUT  NUMBER,                 --> C�digo da Cr�tica
                                        pr_dscritic  OUT  VARCHAR2)  IS           --> Descri��o da Cr�tica
  /* .............................................................................
   Programa: pc_calcula_saldo_contrato
   Sistema : CECRED
   Sigla   : EMPR
   Autor   : Lombardi
   Data    : Mar�o/2017.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Calcula o saldo do contrado do cooperado.

   Observacao: -----
   Alteracoes: 

   ..............................................................................*/                                    
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_cdcritic    INTEGER;
    vr_dscritic    VARCHAR2(10000);
    vr_exc_erro    EXCEPTION;
    vr_des_reto    VARCHAR2(10000);        
    vr_tab_erro    gene0001.typ_tab_erro;
    
    vr_tab_saldos  extr0001.typ_tab_saldos;
    vr_index_saldo BINARY_INTEGER := 0;
    vr_vlsomato    NUMBER;
    
    vr_dstextab    craptab.dstextab%TYPE;
    vr_inusatab    BOOLEAN;
    vr_parempct    craptab.dstextab%TYPE;
    vr_digitali    craptab.dstextab%TYPE;
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;
    vr_qtregist    INTEGER;
    
    --IOF
      vr_vliofpri NUMBER;
      vr_vliofadi NUMBER;
      vr_vliofcpl NUMBER;
      vr_vltaxa_iof_principal VARCHAR2(20);
      vr_qtdiaiof NUMBER;
      vr_flgimune PLS_INTEGER;
      vr_dscatbem VARCHAR2(100);
	  
	   -- Cursor para bens do contrato: 
      /*Faz o order by dscatbem pois "CASA" e "APARTAMENTO" reduzem as 3 aliquotas de IOF (principal, adicional e complementar) a zero.
      J� "MOTO" reduz apenas as al�quotas de IOF principal e complementar..
      Dessa forma, se tiver um bem que seja CASA ou APARTAMENTO, n�o precisa mais verificar os outros bens..*/
      CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS      
        SELECT b.dscatbem, t.cdlcremp
        FROM crapepr t
        INNER JOIN crapbpr b ON b.nrdconta = t.nrdconta AND b.cdcooper = t.cdcooper AND b.nrctrpro = t.nrctremp
        WHERE t.cdcooper = pr_cdcooper
              AND t.nrdconta = pr_nrdconta
              AND t.nrctremp = pr_nrctremp
              AND upper(b.dscatbem) IN ('APARTAMENTO', 'CASA', 'MOTO')
        ORDER BY upper(b.dscatbem) ASC;
      rw_crapbpr cr_crapbpr%ROWTYPE;
    
  BEGIN
      
    ---> ESTOURO DE CONTA <---
    IF pr_cdorigem = 1 THEN
      --Limpar tabela saldos
      vr_tab_saldos.DELETE;      
      --Obter Saldo do Dia
      EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => pr_rw_crapdat
                                 ,pr_cdagenci   => 1 
                                 ,pr_nrdcaixa   => 1 
                                 ,pr_cdoperad   => '1'
                                 ,pr_nrdconta   => pr_nrdconta
                                 ,pr_vllimcre   => pr_vllimcre
                                 ,pr_dtrefere   => pr_rw_crapdat.dtmvtolt
                                 ,pr_des_reto   => vr_des_reto                               
                                 ,pr_tab_sald   => vr_tab_saldos
                                 ,pr_tipo_busca => 'A'
                                 ,pr_flgcrass   => FALSE
                                 ,pr_tab_erro   => vr_tab_erro);    
      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        -- Se tem erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 983; -- N�o foi possivel calcular o saldo devedor
        END IF;
        --Sair com erro
        RAISE vr_exc_erro;
      END IF;
        
      --Buscar Indice
      vr_index_saldo := vr_tab_saldos.FIRST;
      IF vr_index_saldo IS NOT NULL THEN
        -- Acumular Saldo
        vr_vlsomato := ROUND( nvl(vr_tab_saldos(vr_index_saldo).vlsddisp, 0),2);
      END IF;
      
      IF vr_vlsomato < 0 THEN
        -- Saldo Devedor
        pr_vlsdeved := ABS(vr_vlsomato);
        -- Saldo Prejuizo
        pr_vlsdprej := 0;
        -- Valor em Atraso
        pr_vlatraso := ABS(vr_vlsomato);
      END IF;
      
    ---> EMPRESTIMO <---
    ELSIF pr_cdorigem IN (2,3) THEN
    
      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Se a primeira posi��o do campo
        -- dstextab for diferente de zero
        IF SUBSTR(vr_dstextab,1,1) != '0' THEN
          -- � porque existe tabela parametrizada
          vr_inusatab := TRUE;
        ELSE
          -- N�o existe
          vr_inusatab := FALSE;
        END IF;
      ELSE
        -- N�o existe
        vr_inusatab := FALSE;
      END IF;
          
      -- Leitura do indicador de uso da tabela de taxa de juros                                                    
      vr_parempct := tabe0001.fn_busca_dstextab(pr_cdcooper => 3 /*Fixo Cecred*/
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPCTL'
                                               ,pr_tpregist => 1);       
                                                 
      -- busca o tipo de documento GED    
      vr_digitali := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'DIGITALIZA'
                                               ,pr_tpregist => 5);                                               
                                                 
      vr_tab_dados_epr.delete;
      
      -- Busca saldo total de emprestimos
      EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdagenci => 1                   --> C�digo da ag�ncia
                                      ,pr_nrdcaixa => 1                   --> N�mero do caixa
                                      ,pr_cdoperad => '1'                 --> C�digo do operador
                                      ,pr_nmdatela => 'WEBSERVICE'        --> Nome datela conectada
                                      ,pr_idorigem => 9                   --> Indicador da origem da chamada
                                      ,pr_nrdconta => pr_nrdconta         --> Conta do associado
                                      ,pr_idseqttl => 1 -- pr_idseqttl    --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat => pr_rw_crapdat     --> Vetor com dados de par�metro (CRAPDAT)
                                      ,pr_dtcalcul => NULL                --> Data solicitada do calculo
                                      ,pr_nrctremp => pr_nrctremp         --> N�mero contrato empr�stimo
                                      ,pr_cdprogra => 'WEBSERVICE'        --> Programa conectado
                                      ,pr_inusatab => vr_inusatab         --> Indicador de utiliza��o da tabela
                                      ,pr_flgerlog => 'N'                 --> Gerar log S/N
                                      ,pr_flgcondc => FALSE               --> Mostrar emprestimos liquidados sem prejuizo
                                      ,pr_nmprimtl => ' '                 --> Nome Primeiro Titular
                                      ,pr_tab_parempctl => vr_parempct    --> Dados tabela parametro
                                      ,pr_tab_digitaliza => vr_digitali   --> Dados tabela parametro
                                      ,pr_nriniseq => 0                   --> Numero inicial paginacao
                                      ,pr_nrregist => 0                   --> Qtd registro por pagina
                                      ,pr_qtregist => vr_qtregist         --> Qtd total de registros
                                      ,pr_tab_dados_epr => vr_tab_dados_epr  --> Saida com os dados do empr�stimo
                                      ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com poss�ves erros

      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        -- Se tem erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 983; -- N�o foi possivel calcular o saldo devedor
        END IF;
        --Sair com erro
        RAISE vr_exc_erro;
      END IF;
    
      -- Condicao para verificar se encontrou contrato de emprestimo
      IF vr_tab_dados_epr.COUNT > 0 THEN
        
        -- Novo c�lculo de IOF
        vr_dscatbem := NULL;
        --Verifica o primeiro bem do contrato para saber se tem isen��o de al�quota
        OPEN cr_crapbpr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => vr_tab_dados_epr(1).nrctremp);
        FETCH cr_crapbpr INTO rw_crapbpr;
        IF cr_crapbpr%FOUND THEN
          vr_dscatbem := rw_crapbpr.dscatbem;
        END IF;
        CLOSE cr_crapbpr;
      
        --Dias de atraso
        vr_qtdiaiof := pr_rw_crapdat.dtmvtolt - vr_tab_dados_epr(1).dtdpagto;
        IF vr_qtdiaiof < 0 THEN
          vr_qtdiaiof := 0;
        END IF;
                              
        --Calcula o IOF
        TIOF0001.pc_calcula_valor_iof_epr(pr_cdcooper => pr_cdcooper                             --> C�digo da cooperativa referente ao contrato de empr�stimos
                                          ,pr_nrdconta => pr_nrdconta                            --> N�mero da conta referente ao empr�stimo
                                          ,pr_nrctremp => vr_tab_dados_epr(1).nrctremp           --> N�mero do contrato de empr�stimo
                                          ,pr_vlemprst => vr_tab_dados_epr(1).vlsdeved           --> Valor do empr�stimo para efeito de c�lculo
                                          ,pr_dscatbem => vr_dscatbem                            --> Descri��o da categoria do bem, valor default NULO 
                                          ,pr_cdlcremp => vr_tab_dados_epr(1).cdlcremp           --> Linha de cr�dito do empr�stimo
                                          ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt                 --> Data do movimento
                                          ,pr_qtdiaiof => vr_qtdiaiof                            --> Quantidade de dias em atraso
                                          ,pr_vliofpri => vr_vliofpri                            --> Valor do IOF principal
                                          ,pr_vliofadi => vr_vliofadi                            --> Valor do IOF adicional
                                          ,pr_vliofcpl => vr_vliofcpl                            --> Valor do IOF complementar
                                          ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal    --> Valor da Taxa do IOF Principal
                                          ,pr_flgimune => vr_flgimune                            --> Possui imunidade tribut�ria
                                          ,pr_dscritic => vr_dscritic);                          --> Descri��o da cr�tica
                           
        IF NVL(vr_dscritic,' ') <> ' ' THEN
          --Sair com erro
          RAISE vr_exc_erro;
        END IF;
                                                
        --Imunidade....
        IF vr_flgimune > 0 THEN
          vr_vliofpri := 0;
          vr_vliofadi := 0;
          vr_vliofcpl := 0;
        ELSE
          vr_vliofcpl := ROUND(NVL(vr_vliofcpl, 0), 2);
        END IF;  
      
        -- Saldo Devedor
        pr_vlsdeved := nvl(vr_tab_dados_epr(1).vlsdeved,0) + nvl(vr_tab_dados_epr(1).vlmtapar,0) + nvl(vr_tab_dados_epr(1).vlmrapar,0) + vr_vliofcpl;
        -- Saldo Prejuizo
        pr_vlsdprej := nvl(vr_tab_dados_epr(1).vlsdprej,0);
        -- Valor em Atraso
        pr_vlatraso := nvl(vr_tab_dados_epr(1).vltotpag,0) + vr_vliofcpl;
        
      END IF;
        
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN    
      --> Buscar descri��o critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);          
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel calcular saldo do contrato '||pr_nrctremp||': '||SQLERRM;      
      
  END pc_calcular_saldo_contrato; 
  
  PROCEDURE pc_gera_arquivo_parca_web(pr_idarquiv   IN INTEGER        --> Nome do arquivo
                                     ,pr_xmllog     IN VARCHAR2       --> XML com informa��es de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER    --> C�digo da cr�tica
                                     ,pr_dscritic  OUT VARCHAR2       --> Descri��o da cr�tica
                                     ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2) IS   --> Erros do processo
	  BEGIN
 	  /* .............................................................................

      Programa: pc_gera_arquivo_parca_web
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lombardi
      Data    : Marco/2017                    Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a geracao de arquivo csv para aprceiro no ayllos web.

      Observacao: -----

      Alteracoes: 
    ..............................................................................*/
		DECLARE

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Vari�veis Auxiliares
    vr_nmarquiv    VARCHAR2(200);
    vr_msg_retorno VARCHAR2(500);
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_exc_critica EXCEPTION;
    
    ----------------------------- SUBROTINAS INTERNAS -------------------------------

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
      
      
      -- Se houver criticas
      IF vr_dscritic IS NOT NULL THEN
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;
      
      pc_gera_arquivo_parca(pr_idarquiv => pr_idarquiv
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_nmarquiv => vr_nmarquiv
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
      IF vr_cdcritic <> 0 OR
         vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      IF vr_nmarquiv IS NOT NULL THEN 
        vr_msg_retorno := 'Arquivo ' || vr_nmarquiv || ' gerado com sucesso!';
      ELSE 
        vr_msg_retorno := 'N�o foram gerados boletos para essa remessa. N�o foi poss�vel gerar o arquivo!';
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'msg'
                            ,pr_tag_cont => vr_msg_retorno
                            ,pr_des_erro => vr_dscritic);
                            
		EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_COBEMP.pc_importar_arquivo: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;
		END;

  END pc_gera_arquivo_parca_web;
  
  PROCEDURE pc_gera_arquivo_parca(pr_idarquiv   IN INTEGER               --> Nome do arquivo
                                 ,pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                 ,pr_cdoperad   IN crapope.cdoperad%TYPE --> Codigo do operador
                                 ,pr_nmarquiv  OUT VARCHAR2              --> Nome do arquivo
                                 ,pr_cdcritic  OUT PLS_INTEGER           --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2) IS          --> Descri��o da cr�tica
                                 
	  BEGIN
 	  /* .............................................................................

      Programa: pc_gera_arquivo_parca
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lombardi
      Data    : Marco/2017                    Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a geracao de arquivo csv para aprceiro.

      Observacao: -----

      Alteracoes: 
    ..............................................................................*/
		DECLARE

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_exc_critica EXCEPTION;
     
    -- Variaveis auxiliares
    vr_tab_cob      cobr0005.typ_tab_cob;
    vr_arquivo      CLOB;
    vr_dsnmarq      VARCHAR2(100);
    vr_caminho_arq  VARCHAR2(200);
    
    -------------------------------- CURSORES --------------------------------------

		-- Cursor para consultar arquivo
		CURSOR cr_crapcob(pr_idarquiv IN tbepr_cobranca.idarquivo%TYPE) IS       
      SELECT epr.cdcooper
            ,epr.nrdconta
            ,epr.nrdconta_cob
            ,epr.nrctremp
            ,imp.nrcpfaval
            ,cob.nmdsacad
            ,DECODE(imp.tpenvio,1,'E-mail',2,'SMS',3,'Carta') tpenvio
            ,cob.vltitulo
            ,cob.dtvencto
            ,cob.nrcnvcob
            ,cob.nrdocmto
            ,imp.nrddd_envio
            ,imp.nrfone_envio
            ,imp.dsemail_envio
            ,imp.dsendereco_envio
        FROM tbepr_boleto_import imp
            ,tbepr_cobranca epr
            ,crapcob cob
       WHERE imp.idarquivo = pr_idarquiv
         AND epr.idarquivo = imp.idarquivo
         AND epr.idboleto  = imp.idboleto
         AND cob.cdcooper = epr.cdcooper
         AND cob.nrdconta = epr.nrdconta_cob
         AND cob.nrcnvcob = epr.nrcnvcob
         AND cob.nrdocmto = epr.nrboleto;
    
    CURSOR cr_arquivo(pr_idarquiv IN tbepr_cobranca.idarquivo%TYPE) IS       
       SELECT arq.dsarq_gerado
             ,arq.nmarq_gerado
        FROM tbepr_boleto_arq arq
       WHERE arq.idarquivo = pr_idarquiv;
    rw_arquivo cr_arquivo%ROWTYPE;
    
    -- Vari�veis de controle de calend�rio
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    --Escrever no arquivo CLOB
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(vr_arquivo,length(pr_des_dados),pr_des_dados);
    END;
    
    ----------------------------- SUBROTINAS INTERNAS -------------------------------

    BEGIN
      
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      -- Leitura do calend�rio da cooperativa
      OPEN cr_arquivo(pr_idarquiv);
      FETCH cr_arquivo INTO rw_arquivo;
      -- Se n�o encontrar
      IF cr_arquivo%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE cr_arquivo;
        -- Montar mensagem de critica
        vr_dscritic := 'Remessa n�o encontrada.';
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_arquivo;
      END IF;
      
      --Se tiver nulo � primeira gera��o
      IF rw_arquivo.dsarq_gerado IS NULL THEN
        
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_arquivo, TRUE);
        dbms_lob.open(vr_arquivo, dbms_lob.lob_readwrite);

        FOR rw_crapcob IN cr_crapcob(pr_idarquiv => pr_idarquiv) LOOP
          
          COBR0005.pc_buscar_titulo_cobranca(pr_cdcooper => rw_crapcob.cdcooper
                                            ,pr_nrdconta => rw_crapcob.nrdconta_cob
                                            ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                            ,pr_nrdocmto => rw_crapcob.nrdocmto
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nriniseq => 1
                                            ,pr_nrregist => 1
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_tab_cob  => vr_tab_cob);

          -- Verifica se retornou alguma cr�tica
          IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             -- Gera exce��o
             RAISE vr_exc_saida;
          END IF;
          
          IF vr_tab_cob.EXISTS(vr_tab_cob.FIRST) IS NOT NULL THEN
            
            pc_escreve_xml(rw_crapcob.cdcooper || ';' ||
                           rw_crapcob.nrdconta || ';' ||
                           rw_crapcob.nrctremp || ';' ||
                           vr_tab_cob(vr_tab_cob.FIRST).nmdsacad || ';' ||
                           vr_tab_cob(vr_tab_cob.FIRST).lindigit || ';' ||
                           to_char(vr_tab_cob(vr_tab_cob.FIRST).dtvencto,'DD/MM/RRRR') || ';' ||
                           vr_tab_cob(vr_tab_cob.FIRST).dsdinstr ||
                           vr_tab_cob(vr_tab_cob.FIRST).dsdinst1 ||
                           vr_tab_cob(vr_tab_cob.FIRST).dsdinst2 ||
                           vr_tab_cob(vr_tab_cob.FIRST).dsdinst3 ||
                           vr_tab_cob(vr_tab_cob.FIRST).dsdinst4 ||
                           vr_tab_cob(vr_tab_cob.FIRST).dsdinst5 || ';' ||
                           '(' || rw_crapcob.nrddd_envio || ') ' || gene0002.fn_mask(rw_crapcob.nrfone_envio,'99999-9999') || ';' ||
                           rw_crapcob.dsemail_envio || ';' ||
                           rw_crapcob.dsendereco_envio || '|');
          END IF;
        END LOOP;
        vr_dsnmarq := 'BPC_CECRED_' || lpad(pr_idarquiv,6,0) || '.csv';
        
        vr_arquivo := substr(vr_arquivo,1,length(vr_arquivo)-1) ;
       
        -- Salva arquivo na tabela da remessa
        BEGIN
          UPDATE tbepr_boleto_arq arq
             SET arq.nmarq_gerado = vr_dsnmarq
                ,arq.dsarq_gerado = vr_arquivo
           WHERE arq.idarquivo = pr_idarquiv;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao salvar registro do arquivo parceiro.';
            RAISE vr_exc_saida;
        END;
        
        -- Efetuar Commit
        COMMIT;
        
      ELSE -- Se tiver gravado pega do registro no banco
        vr_dsnmarq := rw_arquivo.nmarq_gerado;
        vr_arquivo := rw_arquivo.dsarq_gerado;
      END IF; -- dsarq_gerado IS NULL
      
      IF vr_arquivo IS NOT NULL THEN
        
        -- Busca o diretorio da cooperativa conectada
        vr_caminho_arq := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdcooper => 0
                                                   ,pr_cdacesso => 'DIR_EXP_BOL_MASSIVA');

        -- Escreve o clob no arquivo f�sico
        gene0002.pc_clob_para_arquivo(pr_clob => vr_arquivo
                                     ,pr_caminho => vr_caminho_arq
                                     ,pr_arquivo => vr_dsnmarq
                                     ,pr_des_erro => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        pr_nmarquiv := vr_dsnmarq;
      END IF;
      
		EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_COBEMP.pc_importar_arquivo: ' || SQLERRM;
         ROLLBACK;
		END;

  END pc_gera_arquivo_parca;
  
END TELA_COBEMP;
/
