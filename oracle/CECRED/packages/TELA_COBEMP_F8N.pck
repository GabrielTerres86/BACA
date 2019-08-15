CREATE OR REPLACE PACKAGE CECRED.TELA_COBEMP_F8N IS

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
  -- 23/06/2018 - Rename da tabela tbepr_cobranca para tbrecup_cobranca e filtro tpproduto = 0 (Paulo Penteado GFT)
  --
  ---------------------------------------------------------------------------

    PROCEDURE pc_busca_prazo_venc_api(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                               ,pr_inprejuz  IN INTEGER                       --> Indicador de prejuizo
                               ,pr_tpemprst  IN INTEGER                       --> Tipo de Conta Emprestimo  
                               ,pr_dtmvtolt OUT VARCHAR2                      --> Data inicial
															 ,pr_dtprzmax OUT VARCHAR2                      --> Data máxima
                               ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
															 ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
                               );

    PROCEDURE pc_buscar_telefone_api(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_nrdconta IN INTEGER --> Número da conta
                                    ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                    ,pr_retxml   OUT NOCOPY xmltype); --> Arquivo de retorno do XML

    PROCEDURE pc_buscar_email_api(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_nrdconta IN INTEGER --> Número da conta
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   OUT NOCOPY xmltype); --> Arquivo de retorno do XML

END TELA_COBEMP_F8N;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_COBEMP_F8N IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_COBEMP_F8N
    --  Sistema  : Rotinas de acesso através de API (Cyber)
    --  Sigla    : EMPR
    --  Autor    : André Clemer
    --  Data     : Junho - 2019.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
    -- Objetivo  : Centralizar rotinas da Tela COBEMP (via API)
  --
  -- Alteracoes: 
  ---------------------------------------------------------------------------

    PROCEDURE pc_busca_prazo_venc_api(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                               ,pr_inprejuz  IN INTEGER                       --> Indicador de prejuizo
                               ,pr_tpemprst  IN INTEGER                       --> Tipo de Conta Emprestimo  
                               ,pr_dtmvtolt OUT VARCHAR2                      --> Data inicial
															 ,pr_dtprzmax OUT VARCHAR2                      --> Data máxima
                               ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
															 ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
                               ) IS
	BEGIN
	/* .............................................................................

          Programa: pc_busca_prazo_venc_api
		Sistema : CECRED
		Sigla   : EMPR
          Autor   : André Clemer
          Data    : Junho/19.                    Ultima atualizacao: --/--/---

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

			------------------------------ CURSORES --------------------------------
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

		BEGIN
			-- Verifica se a cooperativa esta cadastrada
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

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

			tela_cobemp.pc_busca_prazo_venc(pr_cdcooper => pr_cdcooper
                                           ,pr_inprejuz => pr_inprejuz
                                           ,pr_dtprzmax => pr_dtprzmax
                                           ,pr_cdcritic => pr_cdcritic
                                           ,pr_dscritic => pr_dscritic);
      
      pr_dtmvtolt := to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');

		EXCEPTION
			WHEN vr_exc_saida THEN

				-- Busca descrição da crítica se houver código
				IF vr_cdcritic <> 0 THEN
					pr_cdcritic := vr_cdcritic;
                    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				ELSE
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBEMP: ' || SQLERRM;
		END;
    END pc_busca_prazo_venc_api;

    PROCEDURE pc_buscar_telefone_api(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_nrdconta IN INTEGER
                                    ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                    ,pr_retxml   OUT NOCOPY xmltype) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_buscar_telefone_api
        Sistema : Cobrança - Cooperativa de Credito
        Sigla   : COB
        Autor   : Dioni/Supero
        Data    : Abril/19.                    Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina busca telefone boletos emprestimos.
        
        Observacao: -----
        
        Alteracoes: -----
        ..............................................................................*/
        DECLARE
        
            -- Variável de críticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
            vr_null      EXCEPTION;
        
            -- Variaveis de log
            vr_contador INTEGER := 0; -- Contador p/ posicao no XML
            vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
            vr_flgresgi BOOLEAN := FALSE;
        
            vr_ind_tel INTEGER := 0; -- Indice para a PL/Table retornada da procedure
        
            vr_tab_tel tela_cobemp.type_tab_tel; -- PL/Table com os dados retornados da procedure
        
        BEGIN
        
            tela_cobemp.pc_buscar_telefone(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_cdcritic => pr_cdcritic
                                          ,pr_dscritic => pr_dscritic
                                          ,pr_tab_tel  => vr_tab_tel);
        
            
            -- Criar cabeçalho do XML
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Root'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Dados'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            IF vr_tab_tel.count() > 0 THEN
              FOR vr_ind_tel IN vr_tab_tel.first .. vr_tab_tel.last LOOP
              
                  vr_contador := vr_contador + 1;
              
                  gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                        ,pr_tag_pai  => 'Dados'
                                        ,pr_posicao  => 0
                                        ,pr_tag_nova => 'telefone'
                                        ,pr_tag_cont => NULL
                                        ,pr_des_erro => vr_dscritic);
                  gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                        ,pr_tag_pai  => 'telefone'
                                        ,pr_posicao  => vr_auxconta
                                        ,pr_tag_nova => 'nrdddtfc'
                                        ,pr_tag_cont => to_char(vr_tab_tel(vr_ind_tel).nrdddtfc)
                                        ,pr_des_erro => vr_dscritic);
                  gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                        ,pr_tag_pai  => 'telefone'
                                        ,pr_posicao  => vr_auxconta
                                        ,pr_tag_nova => 'nrtelefo'
                                        ,pr_tag_cont => to_char(vr_tab_tel(vr_ind_tel).nrtelefo)
                                        ,pr_des_erro => vr_dscritic);
                  gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                        ,pr_tag_pai  => 'telefone'
                                        ,pr_posicao  => vr_auxconta
                                        ,pr_tag_nova => 'nrdramal'
                                        ,pr_tag_cont => to_char(vr_tab_tel(vr_ind_tel).nrdramal)
                                        ,pr_des_erro => vr_dscritic);
                  gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                        ,pr_tag_pai  => 'telefone'
                                        ,pr_posicao  => vr_auxconta
                                        ,pr_tag_nova => 'tptelefo'
                                        ,pr_tag_cont => vr_tab_tel(vr_ind_tel).destptfc
                                        ,pr_des_erro => vr_dscritic);
                  gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                        ,pr_tag_pai  => 'telefone'
                                        ,pr_posicao  => vr_auxconta
                                        ,pr_tag_nova => 'nmpescto'
                                        ,pr_tag_cont => vr_tab_tel(vr_ind_tel).nmpescto
                                        ,pr_des_erro => vr_dscritic);
                  gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                        ,pr_tag_pai  => 'telefone'
                                        ,pr_posicao  => vr_auxconta
                                        ,pr_tag_nova => 'nmopetfn'
                                        ,pr_tag_cont => vr_tab_tel(vr_ind_tel).nmopetfn
                                        ,pr_des_erro => vr_dscritic);
              
                  vr_auxconta := vr_auxconta + 1;
              
                  vr_flgresgi := TRUE;
              
              END LOOP;
            END IF;

            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Root'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Qtdregis'
                                  ,pr_tag_cont => vr_contador
                                  ,pr_des_erro => vr_dscritic);
        
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
                    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                ELSE
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                END IF;
            
                -- Carregar XML padrão para variável de retorno não utilizada.
                -- Existe para satisfazer exigência da interface.
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            WHEN OTHERS THEN
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;
            
                -- Carregar XML padrão para variável de retorno não utilizada.
                -- Existe para satisfazer exigência da interface.
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
        END;
    
    END pc_buscar_telefone_api;

    PROCEDURE pc_buscar_email_api(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_nrdconta IN INTEGER --> Numero da conta
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   OUT NOCOPY xmltype) IS --> Arquivo de retorno do XML
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_buscar_email_api
        Sistema : Cobrança - Cooperativa de Credito
        Sigla   : API - Crédito
        Autor   : Dioni/Supero
        Data    : Marco/19.                    Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina busca email boletos emprestimos.
        
        Observacao: -----
        
        Alteracoes: -----
        ..............................................................................*/
        DECLARE
        
            -- Variável de críticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
            vr_null      EXCEPTION;
        
            -- Variaveis de log
            vr_contador INTEGER := 0; -- Contador p/ posicao no XML
            vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
            vr_flgresgi BOOLEAN := FALSE;
        
            vr_ind_email INTEGER := 0; -- Indice para a PL/Table retornada da procedure    
            vr_tab_email tela_cobemp.type_tab_email; -- PL/Table com os dados retornados da procedure
        
        BEGIN
        
            tela_cobemp.pc_buscar_email(pr_cdcooper  => pr_cdcooper
                                       ,pr_nrdconta  => pr_nrdconta
                                       ,pr_cdcritic  => vr_cdcritic
                                       ,pr_dscritic  => vr_dscritic
                                       ,pr_tab_email => vr_tab_email);
        
            
            
            -- Criar cabeçalho do XML
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Root'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Dados'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            IF vr_tab_email.count() > 0 THEN
              FOR vr_ind_email IN vr_tab_email.first .. vr_tab_email.last LOOP
              
                  vr_contador := vr_contador + 1;
              
                  gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                        ,pr_tag_pai  => 'Dados'
                                        ,pr_posicao  => 0
                                        ,pr_tag_nova => 'email'
                                        ,pr_tag_cont => NULL
                                        ,pr_des_erro => vr_dscritic);
                  gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                        ,pr_tag_pai  => 'email'
                                        ,pr_posicao  => vr_auxconta
                                        ,pr_tag_nova => 'dsdemail'
                                        ,pr_tag_cont => to_char(vr_tab_email(vr_ind_email).dsdemail)
                                        ,pr_des_erro => vr_dscritic);
                  gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                        ,pr_tag_pai  => 'email'
                                        ,pr_posicao  => vr_auxconta
                                        ,pr_tag_nova => 'secpscto'
                                        ,pr_tag_cont => to_char(vr_tab_email(vr_ind_email).secpscto)
                                        ,pr_des_erro => vr_dscritic);
                  gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                        ,pr_tag_pai  => 'email'
                                        ,pr_posicao  => vr_auxconta
                                        ,pr_tag_nova => 'nmpescto'
                                        ,pr_tag_cont => to_char(vr_tab_email(vr_ind_email).nmpescto)
                                        ,pr_des_erro => vr_dscritic);
              
                  vr_auxconta := vr_auxconta + 1;
              
                  vr_flgresgi := TRUE;
              
              END LOOP;
            END IF;
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Root'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Qtdregis'
                                  ,pr_tag_cont => vr_contador
                                  ,pr_des_erro => vr_dscritic);
        
            IF NOT vr_flgresgi THEN
                vr_cdcritic := 812;
                vr_dscritic := 'Nenhum E-mail localizado!';
                RAISE vr_exc_saida;
            END IF;
        
        EXCEPTION
            WHEN vr_null THEN
                NULL;
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
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            WHEN OTHERS THEN
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;
            
                -- Carregar XML padrão para variável de retorno não utilizada.
                -- Existe para satisfazer exigência da interface.
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
        END;
    
  END pc_buscar_email_api;
  
END TELA_COBEMP_F8N;
/
