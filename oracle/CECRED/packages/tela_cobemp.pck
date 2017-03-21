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

  PROCEDURE pc_buscar_email(pr_nrdconta IN INTEGER
                           ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                           ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_buscar_telefone(pr_nrdconta IN INTEGER
                              ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                              ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);
                              
  PROCEDURE pc_buscar_celular(pr_nrdconta IN INTEGER
                             ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                             ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                             ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);                              
                             
  PROCEDURE pc_buscar_log(pr_nrdconta IN INTEGER
                         ,pr_nrdocmto IN INTEGER
                         ,pr_nrcnvcob IN INTEGER
                         ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                         ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                         ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2);

	PROCEDURE pc_buscar_boletos_contratos_w (pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 0         --> PA
																					,pr_nrctremp IN tbepr_cobranca.nrctremp%TYPE DEFAULT 0  --> Nr. do Contrato
																					,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0         --> Nr. da Conta
																					,pr_dtbaixai IN VARCHAR2                                --> Data de baixa inicial
																					,pr_dtbaixaf IN VARCHAR2                                --> Data de baixa final
																					,pr_dtemissi IN VARCHAR2                                --> Data de emissão inicial
																					,pr_dtemissf IN VARCHAR2                                --> Data de emissão final
																					,pr_dtvencti IN VARCHAR2                                --> Data de vencimento inicial
																					,pr_dtvenctf IN VARCHAR2                                --> Data de vencimento final
																					,pr_dtpagtoi IN VARCHAR2                                --> Data de pagamento inicial
																					,pr_dtpagtof IN VARCHAR2                                --> Data de pagamento final
																					,pr_nriniseq IN INTEGER                                 --> Registro inicial da listagem
																					,pr_nrregist IN INTEGER                                 --> Numero de registros p/ paginaca
																					,pr_xmllog   IN VARCHAR2                                --> XML com informações de LOG
																					,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
																					,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
																					,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
																					,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
																					,pr_des_erro OUT VARCHAR2);                             --> Erros do processo

  PROCEDURE pc_buscar_contratos_w (pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0         --> Nr. da Conta
																	,pr_nriniseq IN INTEGER                                 --> Registro inicial da listagem
																	,pr_nrregist IN INTEGER                                 --> Numero de registros p/ paginaca
																	,pr_xmllog   IN VARCHAR2                                --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
																	,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2);

	PROCEDURE pc_verifica_gerar_boleto (pr_nrctacob IN crapass.nrdconta%TYPE                   --> Nr. da Conta Cob.
		                                 ,pr_nrdconta IN crapass.nrdconta%TYPE                   --> Nr. da Conta
																		 ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE                   --> Nr. do Convênio de Cobrança
																	 	 ,pr_nrctremp IN crapcob.nrctremp%TYPE                   --> Nr. do Contrato
																		 ,pr_xmllog   IN VARCHAR2                                --> XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
																		 ,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
																		 ,pr_des_erro OUT VARCHAR2);                             --> Erros do processo

  PROCEDURE pc_busca_texto_sms(pr_nrdconta IN INTEGER
                              ,pr_lindigit IN VARCHAR2
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_gerar_pdf_boletos_w (pr_nrdconta IN crapass.nrdconta%TYPE          --> Nr. da Conta
																	 ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE          --> Nr. do convenio
																	 ,pr_nrdocmto IN crapcob.nrdocmto%TYPE          --> Nr. Docmto
																	 ,pr_xmllog   IN VARCHAR2                       --> XML com informações de LOG
																	 ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
																	 ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
																	 ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
																	 ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
																	 ,pr_des_erro OUT VARCHAR2);                    --> Erros do processo

  PROCEDURE pc_busca_prazo_venc(pr_inprejuz IN INTEGER                        --> Indicador de prejuizo
                               ,pr_xmllog   IN VARCHAR2                       --> XML com informações de LOG
															 ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
															 ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
															 ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
															 ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
															 ,pr_des_erro OUT VARCHAR2);                    --> Erros do processo


PROCEDURE pc_lista_pa(pr_cdagenci IN INTEGER          
                       ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                       ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);
  
  PROCEDURE pc_busca_aval(pr_nrdconta   IN INTEGER --> Numero conta
                         ,pr_nrctremp   IN INTEGER --> Numero contrato
                         ,pr_xmllog     IN VARCHAR2 --> XML com informações de LOG
                         ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                         ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                         ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_desconto(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);        --> Erros do processo

	PROCEDURE pc_busca_arquivos(pr_dtarqini   IN VARCHAR2       --> Data inicial
                             ,pr_dtarqfim   IN VARCHAR2       --> Data final
                             ,pr_nmarquiv   IN VARCHAR2       --> Nome do arquivo
                             ,pr_nriniseq   IN INTEGER        --> Registro inicial da listagem
                             ,pr_nrregist   IN INTEGER        --> Numero de registros p/ paginaca
                             ,pr_xmllog     IN VARCHAR2       --> XML com informações de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER    --> Código da crítica
                             ,pr_dscritic  OUT VARCHAR2       --> Descrição da crítica
                             ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2);     --> Erros do processo

	PROCEDURE pc_importar_arquivo(pr_nmarquiv   IN VARCHAR2       --> Nome do arquivo
                               ,pr_flgreimp   IN INTEGER        --> Reimportacao: 0-Nao / 1-Sim
                               ,pr_xmllog     IN VARCHAR2       --> XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER    --> Código da crítica
                               ,pr_dscritic  OUT VARCHAR2       --> Descrição da crítica
                               ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2       --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2);     --> Erros do processo

END TELA_COBEMP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_COBEMP IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA0001
  --  Sistema  : Rotinas da Tela Ayllos Web COBEMP
  --  Sigla    : TELA
  --  Autor    : Daniel Zimmermann
  --  Data     : Agosto - 2015.                   Ultima atualizacao: 27/09/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas da Tela COBEMP
  --
  -- Alteracoes: 27/09/2016 - Inclusao de verificacao de contratos de acordos
  --                          nas procedures pc_verifica_gerar_boleto, Prj. 302 (Jean Michel).
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_buscar_email(pr_nrdconta IN INTEGER
                           ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                           ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_buscar_email
    Sistema : Cobrança - Cooperativa de Credito
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

      -- Variável de críticas
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
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Criar cabeçalho do XML
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

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_buscar_email;

  PROCEDURE pc_buscar_telefone(pr_nrdconta IN INTEGER
                              ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                              ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_buscar_email
    Sistema : Cobrança - Cooperativa de Credito
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

      -- Variável de críticas
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

      -- Criar cabeçalho do XML
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

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_buscar_telefone;
  
  PROCEDURE pc_buscar_celular(pr_nrdconta IN INTEGER
                             ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                             ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                             ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_buscar_celular
    Sistema : Cobrança - Cooperativa de Credito
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

      -- Variável de críticas
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

      -- Criar cabeçalho do XML
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

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
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
                         ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
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

      -- Variável de críticas
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

      -- Criar cabeçalho do XML
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

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
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
																					,pr_dtemissi IN VARCHAR2                                --> Data de emissão inicial
																					,pr_dtemissf IN VARCHAR2                                --> Data de emissão final
																					,pr_dtvencti IN VARCHAR2                                --> Data de vencimento inicial
																					,pr_dtvenctf IN VARCHAR2                                --> Data de vencimento final
																					,pr_dtpagtoi IN VARCHAR2                                --> Data de pagamento inicial
																					,pr_dtpagtof IN VARCHAR2                                --> Data de pagamento final
																					,pr_nriniseq IN INTEGER                                 --> Registro inicial da listagem
																					,pr_nrregist IN INTEGER                                 --> Numero de registros p/ paginaca
																					,pr_xmllog   IN VARCHAR2                                --> XML com informações de LOG
																					,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
																					,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
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
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- Cód. crítica
      vr_dscritic VARCHAR2(10000);       -- Desc. crítica

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
																						 ,pr_dtemissi => vr_dtemissi     --> Data de emissão inicial
																						 ,pr_dtemissf => vr_dtemissf     --> Data de emissão final
																						 ,pr_dtvencti => vr_dtvencti     --> Data de vencimento inicial
																						 ,pr_dtvenctf => vr_dtvenctf     --> Data de vencimento final
																						 ,pr_dtpagtoi => vr_dtpagtoi     --> Data de pagamento inicial
																						 ,pr_dtpagtof => vr_dtpagtof     --> Data de pagamento final
																						 ,pr_cdoperad => vr_cdoperad     --> Cód. Operador
																						 ,pr_cdcritic => vr_cdcritic     --> Cód. da crítica
																						 ,pr_dscritic => vr_dscritic     --> Descrição da crítica
																						 ,pr_tab_cde  => vr_tab_cde);    --> Pl/Table com os dados de cobrança de emprestimos

				-- Se retornou alguma crítica
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
					-- Levantar exceção
					RAISE vr_exc_saida;
				END IF;

        -- Se PL/Table possuir algum registro
        IF vr_tab_cde.count() > 0 THEN
          -- Atribui registro inicial como indice
          vr_ind_cde := pr_nriniseq;
          -- Se existe registro com o indice inicial
          IF vr_tab_cde.exists(vr_ind_cde) THEN
						-- Criar cabeçalho do XML
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

				      -- Sai do loop se for o último registro ou se chegar no número de registros solicitados
							EXIT WHEN (vr_ind_cde = vr_tab_cde.LAST OR vr_ind_cde = (pr_nriniseq + pr_nrregist) - 1);

							-- Busca próximo indice
							vr_ind_cde := vr_tab_cde.NEXT(vr_ind_cde);
		          vr_auxconta := vr_auxconta + 1;

						END LOOP;
						-- Quantidade total de registros
						gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai  => 'Root', pr_posicao  => 0, pr_tag_nova => 'Qtdregis', pr_tag_cont => vr_tab_cde.count(), pr_des_erro => vr_dscritic);
					END IF;
			  ELSE
					-- Atribui crítica
          vr_cdcritic := 0;
					vr_dscritic := 'Dados nao encontrados!';
					-- Levanta exceção
					RAISE vr_exc_saida;
				END IF;

			EXCEPTION
			WHEN vr_exc_saida THEN
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
				   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			  END IF;

        -- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			WHEN OTHERS THEN

        -- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_buscar_boletos_contratos_w: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			END;
	END pc_buscar_boletos_contratos_w;

  PROCEDURE pc_buscar_contratos_w (pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0         --> Nr. da Conta
																	,pr_nriniseq IN INTEGER                                 --> Registro inicial da listagem
																	,pr_nrregist IN INTEGER                                 --> Numero de registros p/ paginaca
																	,pr_xmllog   IN VARCHAR2                                --> XML com informações de LOG
																	,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
																	,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
																	,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
																	,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
																	,pr_des_erro OUT VARCHAR2) IS                           --> Erros do processo
		BEGIN
	 	  /* .............................................................................

      Programa: pc_buscar_contratos_w
      Sistema : CECRED
      Sigla   : TELA
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: 01/03/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a busca dos boletos de contratos para Web

      Observacao: -----

      Alteracoes: 01/03/2017 - Inclusao de indicador se possui avalista e coluna de Saldo Prejuizo. (P210.2 - Jaison/Daniel)
    ..............................................................................*/
			DECLARE
			----------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- Cód. crítica
      vr_dscritic VARCHAR2(10000);       -- Desc. crítica

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

      -- cursor genérico de calendário
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

			  -- Localizar convenio de cobrança
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
                                        ,pr_cdagenci => vr_cdagenci         --> Código da agência
                                        ,pr_nrdcaixa => vr_nrdcaixa         --> Número do caixa
                                        ,pr_cdoperad => vr_cdoperad         --> Código do operador
                                        ,pr_nmdatela => vr_nmdatela         --> Nome datela conectada
                                        ,pr_idorigem => vr_idorigem         --> Indicador da origem da chamada
                                        ,pr_nrdconta => pr_nrdconta         --> Conta do associado
                                        ,pr_idseqttl => 1 -- pr_idseqttl         --> Sequencia de titularidade da conta
                                        ,pr_rw_crapdat => rw_crapdat        --> Vetor com dados de parâmetro (CRAPDAT)
                                        ,pr_dtcalcul => rw_crapdat.dtmvtolt                --> Data solicitada do calculo
                                        ,pr_nrctremp => 0                   --> Número contrato empréstimo
                                        ,pr_cdprogra => 'COBEMP'            --> Programa conectado
                                        ,pr_inusatab => vr_inusatab         --> Indicador de utilização da tabela
                                        ,pr_flgerlog => 'N'                 --> Gerar log S/N
                                        ,pr_flgcondc => FALSE               --> Mostrar emprestimos liquidados sem prejuizo
                                        ,pr_nmprimtl => ' ' --rw_crapass.nmprimtl --> Nome Primeiro Titular
                                        ,pr_tab_parempctl => vr_parempctl   --> Dados tabela parametro
                                        ,pr_tab_digitaliza => vr_digitaliza --> Dados tabela parametro
                                        ,pr_nriniseq => 0                   --> Numero inicial paginacao
                                        ,pr_nrregist => 0                   --> Qtd registro por pagina
                                        ,pr_qtregist => vr_qtregist         --> Qtd total de registros
                                        ,pr_tab_dados_epr => vr_tab_dados_epr  --> Saida com os dados do empréstimo
                                        ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros

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
						-- Criar cabeçalho do XML
					  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

						LOOP
              
              vr_dstipcob := '';
              vr_vlsdeved := 0;
              vr_vlsdeved := (vr_tab_dados_epr(vr_ind_cde).vlsdeved + 
                              vr_tab_dados_epr(vr_ind_cde).vlmtapar +
                              vr_tab_dados_epr(vr_ind_cde).vlmrapar);   
              
              OPEN cr_epr (pr_cdcooper => vr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => vr_tab_dados_epr(vr_ind_cde).nrctremp);
              FETCH cr_epr INTO rw_epr;
              CLOSE cr_epr;
              
              -- verificar se o contrato eh prejuizo      
              IF nvl(rw_epr.inprejuz,0) = 1 THEN
                 -- verifica se o valor do saldo em prejuizo está em aberto
                 IF nvl(rw_epr.vlsdprej,0) > 0 THEN
                    vr_dstipcob := 'PRJ';
                 ELSE							
      				      -- Sai do loop se for o último registro ou se chegar no número de registros solicitados
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

              --IF ( vr_tab_dados_epr(vr_ind_cde).vltotpag > 0 ) THEN
                 vr_auxconta := vr_auxconta + 1;
              --END IF;   

				      -- Sai do loop se for o último registro ou se chegar no número de registros solicitados
							EXIT WHEN (vr_ind_cde = vr_tab_dados_epr.LAST OR vr_ind_cde = (pr_nriniseq + pr_nrregist) - 1);
							
              vr_ind_cde := vr_tab_dados_epr.NEXT(vr_ind_cde);
                
						END LOOP;
						-- Quantidade total de registros
						gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai  => 'Root', pr_posicao  => 0, pr_tag_nova => 'Qtdregis', pr_tag_cont => vr_tab_dados_epr.count(), pr_des_erro => vr_dscritic);
					END IF;
			  ELSE
					-- Atribui crítica
          vr_cdcritic := 0;
					vr_dscritic := 'Cooperado nao possui contratos em atraso!';
					-- Levanta exceção
					RAISE vr_exc_saida;
				END IF;

        IF ( vr_auxconta = 0 ) THEN
          -- Atribui crítica
          vr_cdcritic := 0;
					vr_dscritic := 'Cooperado nao possui contratos em atraso!';
					-- Levanta exceção
					RAISE vr_exc_saida;
        END IF;

			EXCEPTION
			WHEN vr_exc_saida THEN
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
				   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			  END IF;

        -- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			WHEN OTHERS THEN

        -- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_buscar_contratos_w: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			END;
	END pc_buscar_contratos_w;

	PROCEDURE pc_verifica_gerar_boleto (pr_nrctacob IN crapass.nrdconta%TYPE                   --> Nr. da Conta Cob.
		                                 ,pr_nrdconta IN crapass.nrdconta%TYPE                   --> Nr. da Conta
																		 ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE                   --> Nr. do Convênio de Cobrança
																	 	 ,pr_nrctremp IN crapcob.nrctremp%TYPE                   --> Nr. do Contrato
																		 ,pr_xmllog   IN VARCHAR2                                --> XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
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

      Objetivo  : Rotina para validação da utilização da rotina "Gerar Boleto"

      Observacao: -----

      Alteracoes: 27/09/2016 - Incluida verificacao de contratos de acordo,
                               Prj. 302 (Jean Michel).
    ..............................................................................*/
		DECLARE
		  -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- Cód. crítica
      vr_dscritic VARCHAR2(10000);       -- Desc. crítica
      vr_des_erro VARCHAR(3);            -- Retorno OK/NOK
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis utilizadas na extração dos dados do xml
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
                                       ,pr_flgativo => vr_flgativo
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
				RAISE vr_exc_saida;
      END IF;
          
      IF vr_flgativo = 1 THEN
        vr_dscritic := 'Geracao do boleto nao permitido, emprestimo em acordo.';
        -- Gerar exceção
				RAISE vr_exc_saida;
      END IF;
               
      -- Chama procedure de validação para gerar o boleto
 		  EMPR0007.pc_verifica_gerar_boleto (pr_cdcooper => vr_cdcooper      --> Cód. cooperativa
																				,pr_nrctacob => pr_nrctacob      --> Nr. da Conta Cob.
																				,pr_nrdconta => pr_nrdconta      --> Nr. da Conta
																				,pr_nrcnvcob => pr_nrcnvcob      --> Nr. do Convênio de Cobrança
																				,pr_nrctremp => pr_nrctremp      --> Nr. do Contrato
																				,pr_cdcritic => vr_cdcritic      --> Código da crítica
																				,pr_dscritic => vr_dscritic      --> Descrição da crítica
																				,pr_des_erro => vr_des_erro);    --> Erros do processo
      -- Se retornou erro
      IF vr_des_erro <> 'OK' THEN
				-- Gerar exceção
				RAISE vr_exc_saida;
			END IF;

		EXCEPTION
			WHEN vr_exc_saida THEN
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
				   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			  END IF;

        -- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN

        -- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_verifica_gerar_boleto: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		END;
	END pc_verifica_gerar_boleto;

  PROCEDURE pc_busca_texto_sms(pr_nrdconta IN INTEGER
                              ,pr_lindigit IN VARCHAR2
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_texto_sms
    Sistema : Cobrança - Cooperativa de Credito
    Sigla   : COB
    Autor   : Daniel Zimmermann
    Data    : Agosto/15.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina buscar texto a ser utilizado no envio de sms cobrança

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

      -- Variável de críticas
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
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
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

      -- Criar cabeçalho do XML
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

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_texto_sms;

  PROCEDURE pc_gerar_pdf_boletos_w (pr_nrdconta IN crapass.nrdconta%TYPE          --> Nr. da Conta
																	 ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE          --> Nr. do convenio
																	 ,pr_nrdocmto IN crapcob.nrdocmto%TYPE          --> Nr. Docmto
																	 ,pr_xmllog   IN VARCHAR2                       --> XML com informações de LOG
																	 ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
																	 ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
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
			-- Variável de críticas
			vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic VARCHAR2(10000);

			-- Tratamento de erros
			vr_exc_saida EXCEPTION;
			vr_tab_erro  gene0001.typ_tab_erro;

			-- PL/Table com as informações do boleto
			vr_tab_cob cobr0005.typ_tab_cob;

			 -- Variaveis de log
			vr_cdcooper INTEGER;
			vr_cdoperad VARCHAR2(100);
			vr_nmdatela VARCHAR2(100);
			vr_nmeacao  VARCHAR2(100);
			vr_cdagenci VARCHAR2(100);
			vr_nrdcaixa VARCHAR2(100);
			vr_idorigem VARCHAR2(100);

			vr_des_reto VARCHAR2(3);

			-- Variáveis para geração do relatório
			vr_clobxml    CLOB;
			vr_dstextorel VARCHAR2(32600);
			vr_dstexto    VARCHAR2(32600);
			vr_nmdireto   VARCHAR2(1000);
			vr_dsparams   VARCHAR2(1000);

			vr_nmarqpdf   VARCHAR2(1000);
	    
			vr_valords    NUMBER; 
			vr_valorad    NUMBER;

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

				-- Busca descrição da crítica se houver código
				IF vr_cdcritic <> 0 THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				ELSE
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;

				-- Carregar XML padrão para variável de retorno não utilizada.
				-- Existe para satisfazer exigência da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																			 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBEMP: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		END;
	END pc_gerar_pdf_boletos_w;

  PROCEDURE pc_busca_prazo_venc(pr_inprejuz IN INTEGER                        --> Indicador de prejuizo
                               ,pr_xmllog   IN VARCHAR2                       --> XML com informações de LOG
															 ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
															 ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
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

		Objetivo  : Rotina para buscar o prazo máximo de vencimento da cooperativa

		Observacao: -----

		Alteracoes: 08/03/2017 - Criacao de funcionamento quando prejuizo. (P210.2 - Jaison/Daniel)
	..............................................................................*/
		DECLARE
			----------------------------- VARIAVEIS ---------------------------------
			-- Variável de críticas
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

			-- Se há algum código ou descrição de crítica
			IF pr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

			-- Verifica se a cooperativa esta cadastrada
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
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

				-- Busca descrição da crítica se houver código
				IF vr_cdcritic <> 0 THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				ELSE
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;

				-- Carregar XML padrão para variável de retorno não utilizada.
				-- Existe para satisfazer exigência da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																			 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBEMP: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		END;
  END pc_busca_prazo_venc;
  
  PROCEDURE pc_lista_pa(pr_cdagenci IN INTEGER          
                       ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                       ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_lista_pa
    Sistema : Cobrança - Cooperativa de Credito
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

      -- Variável de críticas
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

      -- Criar cabeçalho do XML
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

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_lista_pa;   
  
  PROCEDURE pc_busca_aval(pr_nrdconta   IN INTEGER --> Numero conta
                         ,pr_nrctremp   IN INTEGER --> Numero contrato
                         ,pr_xmllog     IN VARCHAR2 --> XML com informações de LOG
                         ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                         ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                         ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_aval
    Sistema : Cobrança - Cooperativa de Credito
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

      -- Variável de críticas
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

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
    
    
      -- Listar avalistas de contratos
      DSCT0002.pc_lista_avalistas(pr_cdcooper => vr_cdcooper  --> Código da Cooperativa
                                 ,pr_cdagenci => vr_cdagenci  --> Código da agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                                 ,pr_cdoperad => vr_cdoperad  --> Código do Operador
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
                                 ,pr_cdcritic        => vr_cdcritic   --> Código da crítica
                                 ,pr_dscritic        => vr_dscritic); --> Descrição da crítica
      
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

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_aval;

  PROCEDURE pc_busca_desconto(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
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
			-- Variável de críticas
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

      -- Pltable com os dados de cobrança de empréstimos
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

		  -- Desconto Máximo Contrato Prejuízo
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

				-- Busca descrição da crítica se houver código
				IF vr_cdcritic <> 0 THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				ELSE
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;

				-- Carregar XML padrão para variável de retorno não utilizada.
				-- Existe para satisfazer exigência da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																			 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBEMP: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		END;
  END pc_busca_desconto;

	PROCEDURE pc_busca_arquivos(pr_dtarqini   IN VARCHAR2       --> Data inicial
                             ,pr_dtarqfim   IN VARCHAR2       --> Data final
                             ,pr_nmarquiv   IN VARCHAR2       --> Nome do arquivo
                             ,pr_nriniseq   IN INTEGER        --> Registro inicial da listagem
                             ,pr_nrregist   IN INTEGER        --> Numero de registros p/ paginaca
                             ,pr_xmllog     IN VARCHAR2       --> XML com informações de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER    --> Código da crítica
                             ,pr_dscritic  OUT VARCHAR2       --> Descrição da crítica
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
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- Cód. crítica
      vr_dscritic VARCHAR2(10000);       -- Desc. crítica

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
               DECODE(arq.situacaoarq, 0, 'Pendente', 'Processado') situacaoarq,
               (SELECT COUNT(imp.idarquivo)
                  FROM tbepr_boleto_import imp
                 WHERE imp.idarquivo = arq.idarquivo) qtd_boleto,
               (SELECT COUNT(DISTINCT cri.idboleto)
                  FROM tbepr_boleto_critic cri
                 WHERE cri.idarquivo = arq.idarquivo) qtd_critica
          FROM tbepr_boleto_arq arq
         WHERE (TRIM(pr_nmarquiv) IS NULL
            OR  UPPER(arq.nmarq_import) LIKE '%'||UPPER(pr_nmarquiv)||'%')
           AND ((TRIM(pr_dtarqini) IS NULL AND TRIM(pr_dtarqfim) IS NULL)
            OR  TRUNC(arq.dtarquivo) BETWEEN pr_dtarqini AND pr_dtarqfim);

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

        -- Criar cabeçalho do XML
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
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
				   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			  END IF;

        -- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			WHEN OTHERS THEN

        -- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na TELA_COBEMP.pc_busca_arquivos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


			END;

	END pc_busca_arquivos;

	PROCEDURE pc_importar_arquivo(pr_nmarquiv   IN VARCHAR2       --> Nome do arquivo
                               ,pr_flgreimp   IN INTEGER        --> Reimportacao: 0-Nao / 1-Sim
                               ,pr_xmllog     IN VARCHAR2       --> XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER    --> Código da crítica
                               ,pr_dscritic  OUT VARCHAR2       --> Descrição da crítica
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

    -- Variável de críticas
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
    vr_lin_tipenvio tbepr_boleto_import.tipo_envio%TYPE;
    vr_lin_per_acre tbepr_boleto_import.percent_acre%TYPE;
    vr_lin_per_desc tbepr_boleto_import.percent_desc%TYPE;
    vr_lin_dtvencto tbepr_boleto_import.dtvencto%TYPE;
    vr_lin_dsdnrddd tbepr_boleto_import.nrddd_envio%TYPE;
    vr_lin_telefone tbepr_boleto_import.telefone_envio%TYPE;
    vr_lin_dsdemail tbepr_boleto_import.email_envio%TYPE;
    vr_lin_endereco tbepr_boleto_import.endereco_envio%TYPE;

    -------------------------------- CURSORES --------------------------------------

		-- Cursor para consultar arquivo
		CURSOR cr_arquivo(pr_nmarquiv IN tbepr_boleto_arq.nmarq_import%TYPE) IS
      SELECT arq.idarquivo,
             arq.situacaoarq
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

    ----------------------------- SUBROTINAS INTERNAS -------------------------------

    -- Inclusao da critica
    PROCEDURE pc_inclui_critica(pr_idarquivo IN tbepr_boleto_critic.idarquivo%TYPE,
                                pr_idboleto  IN tbepr_boleto_critic.idboleto%TYPE,
                                pr_idmotivo  IN tbepr_boleto_critic.idmotivo%TYPE,
                                pr_vlrcampo  IN tbepr_boleto_critic.vlrcampo%TYPE) IS
    BEGIN

    	BEGIN
        INSERT INTO tbepr_boleto_critic (idarquivo,idboleto,idmotivo,vlrcampo)
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
        vr_dscritic := 'Extensão de arquivo não permitida.';
        RAISE vr_exc_saida;
      END IF;

      -- Se NAO encontrar o arquivo com a extensao em letras minusculas
      IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq) THEN
        vr_nmarquiv := vr_vet_arqv(1) || '.' || UPPER(vr_dsextens);
        vr_dsdirarq := vr_dsdireto || vr_nmarquiv;
        -- Se NAO encontrar o arquivo com a extensao em letras maiusculas
        IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq) THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Arquivo não encontrado no diretório.';
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Se for maior que 2MB 2117502
      IF GENE0001.fn_tamanho_arquivo(pr_caminho => vr_dsdirarq) > 2048000 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Arquivo informado possui tamanho superior ao permitido. Tamanho máximo 2MB.';
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
        IF rw_arquivo.situacaoarq = 1 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Arquivo já processado. Não permitido efetuar reimportação.';
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

          INSERT INTO tbepr_boleto_arq (idarquivo,dtarquivo,cdoperad,nmarq_import,situacaoarq)
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
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto   --> Diretório do arquivo
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
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 39, -- Cooperativa nao informada ou invalida.
                              pr_vlrcampo  => vr_vet_dado(1));
            vr_lin_cdcooper := NULL;
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
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 40, -- Conta nao informada ou invalida.
                              pr_vlrcampo  => vr_vet_dado(2));
            vr_lin_nrdconta := NULL;
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
            vr_lin_nrctremp := NULL;
          END IF;

          -- Valida CPF do Avalista -------------------------------------------
          BEGIN
            vr_blnachou     := TRUE;
            vr_lin_nrcpfava := TO_NUMBER(NVL(REPLACE(REPLACE(vr_vet_dado(4),'-',''),'.',''),0));
            IF vr_lin_nrcpfava > 0 THEN
              -- Listar avalistas de contratos
              DSCT0002.pc_lista_avalistas(pr_cdcooper => vr_lin_cdcooper  --> Código da Cooperativa
                                         ,pr_cdagenci => vr_cdagenci      --> Código da agencia
                                         ,pr_nrdcaixa => vr_nrdcaixa      --> Numero do caixa do operador
                                         ,pr_cdoperad => vr_cdoperad      --> Código do Operador
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
                                         ,pr_cdcritic        => vr_cdcritic   --> Código da crítica
                                         ,pr_dscritic        => vr_dscritic); --> Descrição da crítica
              
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
            -- Se NAO for 1 - Email / 2 – SMS / 3 – Carta
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
                              pr_idmotivo  => 43, -- Percentual de acrescimo invalido.
                              pr_vlrcampo  => vr_vet_dado(6));
            vr_lin_per_acre := NULL;
          END IF;

          -- Valida Percentual de Desconto -------------------------------------------
          BEGIN
            vr_blnachou     := TRUE;
            vr_lin_per_desc := TO_NUMBER(NVL(vr_vet_dado(7),0));
            IF vr_lin_per_desc >= 100 THEN
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

          -- Valida Data de Vencimento -------------------------------------------
          BEGIN
            vr_blnachou     := TRUE;
            vr_lin_dtvencto := TO_DATE(vr_vet_dado(8),'DD/MM/RRRR');
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
             vr_lin_endereco IS NULL THEN
            pc_inclui_critica(pr_idarquivo => rw_arquivo.idarquivo,
                              pr_idboleto  => vr_idboleto,
                              pr_idmotivo  => 49, -- Endereco nao informado.
                              pr_vlrcampo  => vr_lin_endereco);
            vr_lin_endereco := NULL;
          END IF;

          BEGIN

            INSERT INTO tbepr_boleto_import
              (idarquivo,idboleto,cdcooper,nrdconta,nrctremp,nrcpfaval,tipo_envio,percent_acre,
               percent_desc,dtvencto,nrddd_envio,telefone_envio,email_envio,endereco_envio)
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

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_COBEMP.pc_importar_arquivo: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;
		END;

  END pc_importar_arquivo;
  
END TELA_COBEMP;
/
