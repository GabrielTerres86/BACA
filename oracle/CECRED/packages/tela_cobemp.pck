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

  PROCEDURE pc_busca_prazo_venc(pr_xmllog   IN VARCHAR2                       --> XML com informações de LOG
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
      Data    : Agosto/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a busca dos boletos de contratos para Web

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
      Data    : Agosto/15.                    Ultima atualizacao: 14/11/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a busca dos boletos de contratos para Web

      Observacao: -----

      Alteracoes: 14/11/2017 - Ajsute para devolver informacao de liquidacao do contrato (Jonata - RKAM P364).
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
							gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'inliquid', pr_tag_cont => vr_tab_dados_epr(vr_ind_cde).inliquid, pr_des_erro => vr_dscritic);              

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
                                       ,pr_cdorigem => 3
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

  PROCEDURE pc_busca_prazo_venc(pr_xmllog   IN VARCHAR2                       --> XML com informações de LOG
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
		Data    : Agosto/15.                    Ultima atualizacao: --/--/----

		Dados referentes ao programa:

		Frequencia: Sempre que for chamado

		Objetivo  : Rotina para buscar o prazo máximo de vencimento da cooperativa

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
  
END TELA_COBEMP;
/
