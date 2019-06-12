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

  PROCEDURE pc_busca_prazo_venc(pr_cdcooper  IN crapcop.cdcooper%TYPE         --> Código da Cooperativa
                               ,pr_inprejuz  IN INTEGER                       --> Indicador de prejuizo
                               ,pr_tpemprst  IN INTEGER                       --> Tipo de Conta Emprestimo  
                               ,pr_dtmvtolt OUT VARCHAR2                      --> Data inicial
															 ,pr_dtprzmax OUT VARCHAR2                      --> Data máxima
                               ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
															 ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
                               );

END TELA_COBEMP_F8N;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_COBEMP_F8N IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_COBEMP_F8N
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
  -- Alteracoes: 
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_prazo_venc(pr_cdcooper  IN crapcop.cdcooper%TYPE         --> Código da Cooperativa
                               ,pr_inprejuz  IN INTEGER                       --> Indicador de prejuizo
                               ,pr_tpemprst  IN INTEGER                       --> Tipo de Conta Emprestimo  
                               ,pr_dtmvtolt OUT VARCHAR2                      --> Data inicial
															 ,pr_dtprzmax OUT VARCHAR2                      --> Data máxima
                               ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
															 ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
                               ) IS
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

		Alteracoes: 
	..............................................................................*/
		DECLARE
			----------------------------- VARIAVEIS ---------------------------------
			-- Variável de críticas
			vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic VARCHAR2(10000);

			-- Tratamento de erros
			vr_exc_saida EXCEPTION;

			-- Variaveis locais
			vr_dtprzmax DATE;
			vr_qtdiaspz INTEGER;

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

			vr_qtdiaspz := to_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
																												,pr_cdcooper => pr_cdcooper
																												,pr_cdacesso => 'COBEMP_PRZ_MAX_VENCTO'));
      vr_dtprzmax := rw_crapdat.dtmvtolt;

      FOR dias IN 1..vr_qtdiaspz LOOP 
         -- Busca caminho da imagem do logo do boleto da cecred
         vr_dtprzmax := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => vr_dtprzmax + 1
                                                   ,pr_tipo => 'P');
      END LOOP;
      
		  -- Se for prejuizo
      IF pr_inprejuz = 1 THEN
        -- Nao permite geracao de data maior ou igual que ultimo dia util do mes
        IF vr_dtprzmax >= rw_crapdat.dtultdia THEN
           vr_dtprzmax := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                     ,pr_dtmvtolt => rw_crapdat.dtultdia
                                                     ,pr_tipo => 'A');
           vr_dtprzmax := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                     ,pr_dtmvtolt => vr_dtprzmax - 1
                                                     ,pr_tipo => 'A');
        END IF;
      END IF;
      
      pr_dtmvtolt := to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
      pr_dtprzmax := to_char(vr_dtprzmax, 'DD/MM/RRRR');

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
		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBEMP: ' || SQLERRM;
		END;
  END pc_busca_prazo_venc;
  
END TELA_COBEMP_F8N;
/
