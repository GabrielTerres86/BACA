CREATE OR REPLACE PACKAGE CECRED.TELA_GAROPC IS

  PROCEDURE pc_busca_dados(pr_idcobert     IN tbgar_cobertura_operacao.idcobertura%TYPE --> Identificador da cobertura
                          ,pr_tipaber      IN VARCHAR2 -->  Tipo da abertura da tela (Consulta, Alteracao, Inclusao)
                          ,pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                          ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                          ,pr_codlinha     IN INTEGER --> Codigo da linha
						  ,pr_cdfinemp     IN INTEGER --> Código da finalidade
                          ,pr_vlropera     IN NUMBER --> Valor da operacao
                          ,pr_dsctrliq     IN VARCHAR2 --> Lista de contratos a liquidar separados por ";"
                          ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2); --> Erros do processo
  
  PROCEDURE pc_busca_saldos(pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                           ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                           ,pr_nrctaliq     IN crapadt.nrdconta%TYPE --> Numero da conta
                           ,pr_dsctrliq     IN VARCHAR2 --> Lista de contratos a liquidar separados por ";"
                           ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro    OUT VARCHAR2); --> Erros do processo
  
  PROCEDURE pc_grava_dados(pr_nmdatela     IN VARCHAR2 --> Nome da tela que chamou
                          ,pr_idcobert     IN tbgar_cobertura_operacao.idcobertura%TYPE --> Identificador da cobertura
                          ,pr_tipaber      IN VARCHAR2 -->  Tipo da abertura da tela
                          ,pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                          ,pr_nrctater     IN crapadt.nrdconta%TYPE --> Numero da conta terceiro
                          ,pr_lintpctr     IN craplcr.tpctrato%TYPE --> Tipo de contrato utilizado pela linha
                          ,pr_vlropera     IN NUMBER --> Valor da operacao
                          ,pr_permingr     IN NUMBER --> Percentual de Garantia Necessaria
                          ,pr_inresper     IN INTEGER --> Resgate permitido
                          ,pr_diatrper     IN INTEGER --> Qtde dias permitidos atraso antes do resgate
                          ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                          ,pr_inaplpro     IN INTEGER --> Aplicacao propria
                          ,pr_vlaplpro     IN NUMBER --> Valor da Aplicacao propria
                          ,pr_inpoupro     IN INTEGER --> Poupanca propria
                          ,pr_vlpoupro     IN NUMBER --> Valor da Poupanca propria
                          ,pr_inresaut     IN INTEGER --> Resgate automatico
                          ,pr_inaplter     IN INTEGER --> Aplicacao terceiro
                          ,pr_vlaplter     IN NUMBER --> Valor da Aplicacao terceiro
                          ,pr_inpouter     IN INTEGER --> Poupanca terceiro
                          ,pr_vlpouter     IN NUMBER --> Valor da Poupanca terceiro
                          ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_valida_dados(pr_nmdatela     IN VARCHAR2 --> Nome da tela que chamou
                           ,pr_tipaber      IN VARCHAR2 -->  Tipo da abertura da tela
                           ,pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                           ,pr_nrctater     IN crapadt.nrdconta%TYPE --> Numero da conta terceiro
                           ,pr_lintpctr     IN craplcr.tpctrato%TYPE --> Tipo de contrato utilizado pela linha
                           ,pr_vlropera     IN NUMBER --> Valor da operacao
                           ,pr_permingr     IN NUMBER --> Percentual de Garantia Necessaria
                           ,pr_inresper     IN INTEGER --> Resgate permitido
                           ,pr_diatrper     IN INTEGER --> Qtde dias permitidos atraso antes do resgate
                           ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                           ,pr_inaplpro     IN INTEGER --> Aplicacao propria
                           ,pr_vlaplpro     IN NUMBER --> Valor da Aplicacao propria
                           ,pr_inpoupro     IN INTEGER --> Poupanca propria
                           ,pr_vlpoupro     IN NUMBER --> Valor da Poupanca propria
                           ,pr_inresaut     IN INTEGER --> Resgate automatico
                           ,pr_inaplter     IN INTEGER --> Aplicacao terceiro
                           ,pr_vlaplter     IN NUMBER --> Valor da Aplicacao terceiro
                           ,pr_inpouter     IN INTEGER --> Poupanca terceiro
                           ,pr_vlpouter     IN NUMBER --> Valor da Poupanca terceiro
                           ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro    OUT VARCHAR2
                             );
END TELA_GAROPC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_GAROPC IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_GAROPC
  --  Sistema  : Rotinas utilizadas pela Tela GAROPC
  --  Sigla    : EMPR
  --  Autor    : Jaison Fernando
  --  Data     : Novembro/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela GAROPC
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  
  PROCEDURE pc_busca_dados(pr_idcobert     IN tbgar_cobertura_operacao.idcobertura%TYPE --> Identificador da cobertura
                          ,pr_tipaber      IN VARCHAR2 -->  Tipo da abertura da tela (Consulta, Alteracao, Inclusao)
                          ,pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                          ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                          ,pr_codlinha     IN INTEGER --> Codigo da linha
						  ,pr_cdfinemp     IN INTEGER --> Código da finalidade
                          ,pr_vlropera     IN NUMBER --> Valor da operacao
                          ,pr_dsctrliq     IN VARCHAR2 --> Lista de contratos a liquidar separados por ";"
                          ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados para tela GAROPC.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Seleciona dados da Linha de Credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT craplcr.permingr
              ,craplcr.tpctrato
              ,craplcr.dslcremp deslinha
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
           AND craplcr.cdlcremp = pr_cdlcremp;

		-- Verificar se finalidade é de CDC
		CURSOR cr_crapfin(pr_cdcooper IN craplcr.cdcooper%TYPE
						 ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
		    SELECT 1
			  FROM crapfin fin
			 WHERE fin.cdcooper = pr_cdcooper
			   AND fin.cdfinemp = pr_cdfinemp
			   AND (upper(fin.dsfinemp) LIKE '%CDC%' OR upper(fin.dsfinemp) LIKE '%C DC%');
		rw_crapfin cr_crapfin%ROWTYPE;
			
      -- Seleciona dados da Linha de Credito Rotativo
      CURSOR cr_craplrt(pr_cdcooper IN craplrt.cdcooper%TYPE
                       ,pr_cddlinha IN craplrt.cddlinha%TYPE) IS
        SELECT craplrt.permingr
              ,craplrt.tpctrato
              ,craplrt.dsdlinha deslinha
          FROM craplrt
         WHERE craplrt.cdcooper = pr_cdcooper
           AND craplrt.cddlinha = pr_cddlinha;

      -- Seleciona dados da Linha de Desconto
      CURSOR cr_crapldc(pr_cdcooper IN crapldc.cdcooper%TYPE
                       ,pr_cddlinha IN crapldc.cddlinha%TYPE
                       ,pr_tpdescto IN crapldc.tpdescto%TYPE) IS
        SELECT crapldc.permingr
              ,crapldc.tpctrato
              ,crapldc.dsdlinha deslinha
          FROM crapldc
         WHERE crapldc.cdcooper = pr_cdcooper
           AND crapldc.cddlinha = pr_cddlinha
           AND crapldc.tpdescto = pr_tpdescto;
      rw_linha cr_crapldc%ROWTYPE;

      -- Seleciona parametro de configuracao geral
      CURSOR cr_param(pr_cdcooper IN crapldc.cdcooper%TYPE) IS
        SELECT tpg.inresgate_automatico
              ,tpg.peminimo_cobertura
              ,tpg.qtdias_atraso_permitido
          FROM tbgar_parame_geral tpg
         WHERE tpg.cdcooper = pr_cdcooper;
      rw_param cr_param%ROWTYPE;

      -- Seleciona garantias para operacoes de credito
      CURSOR cr_cobertura(pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
        SELECT tco.inresgate_automatico
              ,tco.perminimo
              ,tco.inaplicacao_propria
              ,tco.inpoupanca_propria
              ,tco.nrconta_terceiro
              ,tco.inaplicacao_terceiro
              ,tco.inpoupanca_terceiro
              ,tco.cdoperador_desbloq
              ,tco.dtdesbloq
              ,tco.vldesbloq
          FROM tbgar_cobertura_operacao tco
         WHERE tco.idcobertura = pr_idcobert;
      rw_cobertura cr_cobertura%ROWTYPE;

      -- Seleciona associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nmprimtl
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;

      -- Seleciona operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT crapope.nmoperad
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND crapope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;


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
      vr_blnachou                BOOLEAN;
      vr_permingr                NUMBER;
      vr_vlgarnec                NUMBER;
      vr_lablinha                VARCHAR2(25);
      vr_labgaran                VARCHAR2(25);
      vr_vlsaldo_aplica          NUMBER;
      vr_vlsaldo_poupa           NUMBER;
      vr_vlsaldo_aplica_terceiro NUMBER;
      vr_vlsaldo_poup_terceiro   NUMBER;
      vr_inresgate_permitido     INTEGER;
      vr_inresgate_automatico    INTEGER;
      vr_qtdias_atraso_permitido INTEGER;
      vr_inaplicacao_propria     NUMBER;
      vr_inpoupanca_propria      NUMBER;
      vr_nrconta_terceiro        NUMBER;
      vr_nmprimtl_terceiro       crapass.nmprimtl%TYPE;
      vr_inaplicacao_terceiro    NUMBER;
      vr_inpoupanca_terceiro     NUMBER;
      vr_desdesbloq              VARCHAR2(200);
      vr_dtdesbloq               DATE;
      vr_cdoperador_desbloq      VARCHAR2(10);
      vr_vldesbloq               NUMBER;
	  vr_flgfincdc               NUMBER := 0;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_GAROPC'
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

      -- Se NAO for Consulta, Alteracao ou Inclusao
      IF NOT pr_tipaber IN ('C','A','I','AI') THEN
        vr_dscritic := 'Tipo de Abertura inválido, favor verificar!';
        RAISE vr_exc_erro;
      END IF;

      -- Se for Consulta ou Alteracao e NAO possui ID
      IF pr_tipaber IN ('C','A','AI') AND NVL(pr_idcobert,0) = 0 THEN
        vr_dscritic := 'ID da configuração anterior não foi enviado, favor verificar!';
        RAISE vr_exc_erro;
      END IF;

      -- Se NAO foi passado cooperativa
      IF NVL(vr_cdcooper,0) = 0 THEN
        vr_dscritic := 'Cooperativa não enviada, favor verificar!';
        RAISE vr_exc_erro;
      END IF;

      -- Se NAO foi passado conta
      IF NVL(pr_nrdconta,0) = 0 THEN
        vr_dscritic := 'Conta não enviada, favor verificar!';
        RAISE vr_exc_erro;
      END IF;

      -- Se Tipo de Contrato NAO estiver na listagem
      IF NOT pr_tpctrato IN (1, 2, 3, 90) THEN
        vr_dscritic := 'Tipo de Contratação inválida, favor verificar!';
        RAISE vr_exc_erro;
      END IF;

      -- Se NAO foi passado linha
      IF NVL(pr_codlinha,0) = 0 THEN
        vr_dscritic := 'Linha de Crédito/Desconto não enviada, favor prenchê-la antes de continuar!';
        RAISE vr_exc_erro;
      END IF;

      -- Se NAO foi passado valor
      IF NVL(pr_vlropera,0) = 0 THEN
        vr_dscritic := 'Valor da operação inválida, favor preenchê-lo antes de continuar!';
        RAISE vr_exc_erro;
      END IF;

      -- Carrega o label da linha
      CASE pr_tpctrato
        WHEN 1  THEN vr_lablinha := 'Linha Crédito Rotativo:';
        WHEN 90 THEN vr_lablinha := 'Linha de Crédito:';
        ELSE         vr_lablinha := 'Linha de Desconto:';
      END CASE;

      -- Se for Emprestimo/Financiamento
      IF pr_tpctrato = 90 THEN
        -- Seleciona dados da Linha de Credito
        OPEN cr_craplcr(pr_cdcooper => vr_cdcooper
                       ,pr_cdlcremp => pr_codlinha);
        FETCH cr_craplcr INTO rw_linha;
        vr_blnachou := cr_craplcr%FOUND;
        CLOSE cr_craplcr;
        -- Se NAO achou
        IF NOT vr_blnachou THEN
          vr_dscritic := 'Problema na checagem da Linha de Crédito, favor preencher uma linha correta!';
          RAISE vr_exc_erro;
        END IF;

		-- Verificar se finalidade é de CDC
		OPEN cr_crapfin(pr_cdcooper => vr_cdcooper
                       ,pr_cdfinemp => pr_cdfinemp);
        FETCH cr_crapfin INTO rw_crapfin;

        -- Se encontrou
        IF cr_crapfin%FOUND THEN
			-- Encontrou finalidade de CDC
			vr_flgfincdc := 1;
		END IF;
		CLOSE cr_crapfin;
      -- Se for Cheque Especial
      ELSIF pr_tpctrato = 1 THEN
        -- Seleciona dados da Linha de Credito Rotativo
        OPEN cr_craplrt(pr_cdcooper => vr_cdcooper
                       ,pr_cddlinha => pr_codlinha);
        FETCH cr_craplrt INTO rw_linha;
        vr_blnachou := cr_craplrt%FOUND;
        CLOSE cr_craplrt;
        -- Se NAO achou
        IF NOT vr_blnachou THEN
          vr_dscritic := 'Problema na checagem da Linha de Crédito Rotativo, favor preencher uma linha correta!';
          RAISE vr_exc_erro;
        END IF;

      -- Se for Desconto Cheques ou Desconto Titulos
      ELSE
        -- Seleciona dados da Linha de Desconto
        OPEN cr_crapldc(pr_cdcooper => vr_cdcooper
                       ,pr_cddlinha => pr_codlinha
                       ,pr_tpdescto => pr_tpctrato);
        FETCH cr_crapldc INTO rw_linha;
        vr_blnachou := cr_crapldc%FOUND;
        CLOSE cr_crapldc;
        -- Se NAO achou
        IF NOT vr_blnachou THEN
          vr_dscritic := 'Problema na checagem da Linha de Desconto, favor preencher uma linha correta!';
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Seleciona parametro de configuracao geral
      OPEN cr_param(pr_cdcooper => vr_cdcooper);
      FETCH cr_param INTO rw_param;
      vr_blnachou := cr_param%FOUND;
      CLOSE cr_param;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_dscritic := 'Problema na recuperação da parametrização geral, operação não poderá ser continuada!';
        RAISE vr_exc_erro;
      END IF;

      -- Carrega os parametros gerais
      vr_permingr := rw_param.peminimo_cobertura;
      vr_inresgate_permitido := rw_param.inresgate_automatico;
      vr_qtdias_atraso_permitido := rw_param.qtdias_atraso_permitido;

      -- Se NAO for Limite de Credito ou Emprestimo/Financiamento
      IF NOT pr_tpctrato IN (1, 90) THEN
        vr_inresgate_permitido := 0;
        vr_qtdias_atraso_permitido := 0;
      END IF;

      -- Se for uma linha com Modelo = 4 (Aplicacao)
      IF rw_linha.tpctrato = 4 THEN
        vr_permingr := rw_linha.permingr;
        vr_labgaran := 'Garantia Obrigatória:';
        -- Se for inclusao e parametro geral de resgate for sim
        IF pr_tipaber = 'I' AND vr_inresgate_permitido = 1 THEN
           vr_inresgate_automatico := 0;       
        END IF;
      ELSE
        vr_labgaran := 'Garantia Sugerida:';
        vr_inresgate_permitido := 0;
      END IF;

      -- Se for Consulta ou Alteracao
      IF pr_tipaber IN ('C','A','AI') THEN

        -- Seleciona garantias para operacoes de credito
        OPEN cr_cobertura(pr_idcobert => pr_idcobert);
        FETCH cr_cobertura INTO rw_cobertura;
        vr_blnachou := cr_cobertura%FOUND;
        CLOSE cr_cobertura;
        -- Se NAO achou
        IF NOT vr_blnachou THEN
          vr_dscritic := 'Erro ao buscar Cobertura cadastrada anteriormente, favor tentar novamente!';
          RAISE vr_exc_erro;
        END IF;

        -- Carrega as variaveis
        vr_inresgate_automatico := rw_cobertura.inresgate_automatico;
        vr_inaplicacao_propria  := rw_cobertura.inaplicacao_propria;
        vr_inpoupanca_propria   := rw_cobertura.inpoupanca_propria;
        vr_nrconta_terceiro     := rw_cobertura.nrconta_terceiro;
        vr_inaplicacao_terceiro := rw_cobertura.inaplicacao_terceiro;
        vr_inpoupanca_terceiro  := rw_cobertura.inpoupanca_terceiro;
        vr_cdoperador_desbloq   := rw_cobertura.cdoperador_desbloq;
        vr_dtdesbloq            := rw_cobertura.dtdesbloq;
        vr_vldesbloq            := NVL(rw_cobertura.vldesbloq,0);
		IF pr_tipaber = 'C' OR rw_linha.tpctrato <> 4 THEN
           vr_permingr             := rw_cobertura.perminimo;
		END IF;
        
        -- Se for Consulta
        IF pr_tipaber = 'C' THEN

          -- Se houve desbloqueio
          IF vr_vldesbloq > 0 THEN

            -- Seleciona operador
            OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperador_desbloq);
            FETCH cr_crapope INTO rw_crapope;
            CLOSE cr_crapope;
            
            vr_desdesbloq := '*** Liberação de R$ '
                          || TO_CHAR(vr_vldesbloq,'FM999G999G999G990D00')
                          || ' em ' || TO_CHAR(vr_dtdesbloq,'DD/MM/RRRR')
                          || ' por ' || vr_cdoperador_desbloq || '-'
                          || rw_crapope.nmoperad;
          END IF;

        END IF;

      END IF; -- pr_tipaber IN ('C','A','AI')

      -- Valor da garantia necessaria
      vr_vlgarnec := pr_vlropera * (vr_permingr / 100);

      -- Busca os saldos da conta
      BLOQ0001.pc_retorna_saldos_conta(pr_cdcooper       => vr_cdcooper
                                      ,pr_nrdconta       => pr_nrdconta
                                      ,pr_tpctrato       => pr_tpctrato
                                      ,pr_nrctaliq       => pr_nrdconta
                                      ,pr_dsctrliq       => pr_dsctrliq
                                      ,pr_vlsaldo_aplica => vr_vlsaldo_aplica
                                      ,pr_vlsaldo_poupa  => vr_vlsaldo_poupa
                                      ,pr_dscritic       => vr_dscritic);
      -- Se ocorreu erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Seta conta de terceiro
      vr_nrconta_terceiro := NVL(vr_nrconta_terceiro,0);

      -- Se possui conta de terceiro
      IF vr_nrconta_terceiro > 0 THEN
        -- Busca os saldos da conta do terceiro
        BLOQ0001.pc_retorna_saldos_conta(pr_cdcooper       => vr_cdcooper
                                        ,pr_nrdconta       => vr_nrconta_terceiro
                                        ,pr_tpctrato       => pr_tpctrato
                                        ,pr_nrctaliq       => pr_nrdconta
                                        ,pr_dsctrliq       => pr_dsctrliq
                                        ,pr_vlsaldo_aplica => vr_vlsaldo_aplica_terceiro
                                        ,pr_vlsaldo_poupa  => vr_vlsaldo_poup_terceiro
                                        ,pr_dscritic       => vr_dscritic);
        -- Se ocorreu erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Seleciona associado
        OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => vr_nrconta_terceiro);
        FETCH cr_crapass INTO vr_nmprimtl_terceiro;
        CLOSE cr_crapass;
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
                            ,pr_tag_nova => 'lintpctr'
                            ,pr_tag_cont => rw_linha.tpctrato
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'labgaran'
                            ,pr_tag_cont => vr_labgaran
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'lablinha'
                            ,pr_tag_cont => vr_lablinha
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'deslinha'
                            ,pr_tag_cont => rw_linha.deslinha
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'permingr'
                            ,pr_tag_cont => TO_CHAR(vr_permingr,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlgarnec'
                            ,pr_tag_cont => TO_CHAR(vr_vlgarnec,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'desbloqu'
                            ,pr_tag_cont => TRIM(vr_desdesbloq)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inaplpro'
                            ,pr_tag_cont => NVL(vr_inaplicacao_propria,0)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlaplpro'
                            ,pr_tag_cont => TO_CHAR(NVL(vr_vlsaldo_aplica,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inpoupro'
                            ,pr_tag_cont => NVL(vr_inpoupanca_propria,0)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlpoupro'
                            ,pr_tag_cont => TO_CHAR(NVL(vr_vlsaldo_poupa,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inresaut'
                            ,pr_tag_cont => NVL(vr_inresgate_automatico,0)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inresper'
                            ,pr_tag_cont => vr_inresgate_permitido
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'diatrper'
                            ,pr_tag_cont => vr_qtdias_atraso_permitido
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inaplter'
                            ,pr_tag_cont => NVL(vr_inaplicacao_terceiro,0)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlaplter'
                            ,pr_tag_cont => TO_CHAR(NVL(vr_vlsaldo_aplica_terceiro,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inpouter'
                            ,pr_tag_cont => NVL(vr_inpoupanca_terceiro,0)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlpouter'
                            ,pr_tag_cont => TO_CHAR(NVL(vr_vlsaldo_poup_terceiro,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nrctater'
                            ,pr_tag_cont => (CASE WHEN vr_nrconta_terceiro > 0 THEN vr_nrconta_terceiro ELSE '' END)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmctater'
                            ,pr_tag_cont => (CASE WHEN vr_nrconta_terceiro > 0 THEN vr_nmprimtl_terceiro ELSE '' END)
                            ,pr_des_erro => vr_dscritic);
														
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flgfincdc'
                            ,pr_tag_cont => nvl(vr_flgfincdc,0)
                            ,pr_des_erro => vr_dscritic);														

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela GAROPC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_dados;
  
  PROCEDURE pc_busca_saldos(pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                           ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                           ,pr_nrctaliq     IN crapadt.nrdconta%TYPE --> Numero da conta
                           ,pr_dsctrliq     IN VARCHAR2 --> Lista de contratos a liquidar separados por ";"
                           ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_saldos
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os saldos para tela GAROPC.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

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
      vr_vlsaldo_aplica_terceiro NUMBER;
      vr_vlsaldo_poup_terceiro   NUMBER;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_GAROPC'
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

      -- Busca os saldos da conta do terceiro
      BLOQ0001.pc_retorna_saldos_conta(pr_cdcooper       => vr_cdcooper
                                      ,pr_nrdconta       => pr_nrdconta
                                      ,pr_tpctrato       => pr_tpctrato
                                      ,pr_nrctaliq       => pr_nrctaliq
                                      ,pr_dsctrliq       => pr_dsctrliq
                                      ,pr_vlsaldo_aplica => vr_vlsaldo_aplica_terceiro
                                      ,pr_vlsaldo_poupa  => vr_vlsaldo_poup_terceiro
                                      ,pr_dscritic       => vr_dscritic);
      -- Se ocorreu erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
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
                            ,pr_tag_nova => 'vlaplter'
                            ,pr_tag_cont => TO_CHAR(NVL(vr_vlsaldo_aplica_terceiro,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlpouter'
                            ,pr_tag_cont => TO_CHAR(NVL(vr_vlsaldo_poup_terceiro,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela GAROPC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_saldos;

  PROCEDURE pc_grava_dados(pr_nmdatela     IN VARCHAR2 --> Nome da tela que chamou
                          ,pr_idcobert     IN tbgar_cobertura_operacao.idcobertura%TYPE --> Identificador da cobertura
                          ,pr_tipaber      IN VARCHAR2 -->  Tipo da abertura da tela
                          ,pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                          ,pr_nrctater     IN crapadt.nrdconta%TYPE --> Numero da conta terceiro
                          ,pr_lintpctr     IN craplcr.tpctrato%TYPE --> Tipo de contrato utilizado pela linha
                          ,pr_vlropera     IN NUMBER --> Valor da operacao
                          ,pr_permingr     IN NUMBER --> Percentual de Garantia Necessaria
                          ,pr_inresper     IN INTEGER --> Resgate permitido
                          ,pr_diatrper     IN INTEGER --> Qtde dias permitidos atraso antes do resgate
                          ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                          ,pr_inaplpro     IN INTEGER --> Aplicacao propria
                          ,pr_vlaplpro     IN NUMBER --> Valor da Aplicacao propria
                          ,pr_inpoupro     IN INTEGER --> Poupanca propria
                          ,pr_vlpoupro     IN NUMBER --> Valor da Poupanca propria
                          ,pr_inresaut     IN INTEGER --> Resgate automatico
                          ,pr_inaplter     IN INTEGER --> Aplicacao terceiro
                          ,pr_vlaplter     IN NUMBER --> Valor da Aplicacao terceiro
                          ,pr_inpouter     IN INTEGER --> Poupanca terceiro
                          ,pr_vlpouter     IN NUMBER --> Valor da Poupanca terceiro
                          ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os dados para tela GAROPC.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Seleciona garantias para operacoes de credito
      CURSOR cr_cobertura(pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
        SELECT tco.perminimo           
              ,tco.inaplicacao_propria 
              ,tco.inpoupanca_propria  
              ,tco.nrconta_terceiro    
              ,tco.inaplicacao_terceiro
              ,tco.inpoupanca_terceiro 
              ,tco.inresgate_automatico
              ,tco.qtdias_atraso_permitido
			  ,tco.nrcontrato
          FROM tbgar_cobertura_operacao tco
         WHERE tco.idcobertura = pr_idcobert;
      rw_cobertura cr_cobertura%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
	  vr_exc_null EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis locais
      vr_blnachou BOOLEAN;
      vr_blupdate BOOLEAN := FALSE;
      vr_idcobert tbgar_cobertura_operacao.idcobertura%TYPE;
	  vr_nrdconta_aux crapass.nrdconta%TYPE;
      vr_perde_aprovacao NUMBER(1) := 0; -- 0 Nao perde e 1 Perde aprovacao
      vr_indx            PLS_INTEGER;
      vr_nrdrowid        ROWID;
      --Será utilizado para gravar todas as alterações
      TYPE typ_reg_alteracoes IS RECORD(dsmotivo varchar2(100)   --> Motivos da Perda
                                       ,nmcampo  varchar2(200)   --> Nome do campo
                                       ,dsdadant varchar2(4000)   --> Valor Anterior
                                       ,dsdadatu varchar2(4000)); --> Valor Atual
      /* Definição de tabela que compreenderá os registros acima declarados */
      TYPE typ_tab_alteracoes IS TABLE OF typ_reg_alteracoes INDEX BY PLS_INTEGER;
      /* Variável que armazenará uma instancia da tabela */
      vr_tab_alteracoes typ_tab_alteracoes;      

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_GAROPC'
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

      -- Se veio da ADITIV eh necessario ter selecionado ao menos um sim 
      -- entre aplicacao e poupanca programada propria ou de terceiros
      IF pr_nmdatela = 'ADITIV' AND
         NVL(pr_inaplpro,0) = 0 AND
         NVL(pr_inpoupro,0) = 0 AND
         NVL(pr_inaplter,0) = 0 AND
         NVL(pr_inpouter,0) = 0 THEN
         vr_dscritic := 'Não é possível criar este tipo de Aditivo Contratual sem Cobertura da Operação.';
         RAISE vr_exc_erro;
      END IF;

      -- Se for um percentual invalido
      IF pr_permingr > 999.99 THEN
         vr_dscritic := 'Percentual da garantia sugerida não permitida!';
         RAISE vr_exc_erro;
      END IF;

      -- Se o percentual for zero e foi selecionado aplicacao ou poupanca programada
      IF pr_permingr = 0 AND 
        (NVL(pr_inaplpro,0) = 1 OR
         NVL(pr_inpoupro,0) = 1 OR
         NVL(pr_inaplter,0) = 1 OR
         NVL(pr_inpouter,0) = 1) THEN
         vr_dscritic := 'Não será permitido utilizar Aplicação ou Aplicação Programada com valor de cobertura de garantia igual a 0!';
         RAISE vr_exc_erro;
      END IF;

      -- Se o percentual for maior que zero e não foi selecionado aplicacao ou poupanca programada
      IF pr_permingr > 0 AND 
        (NVL(pr_inaplpro,0) = 0 AND
         NVL(pr_inpoupro,0) = 0 AND
         NVL(pr_inaplter,0) = 0 AND
         NVL(pr_inpouter,0) = 0) THEN
         vr_dscritic := 'Não é permitido informar um percentual mínimo de cobertura sem vincular uma aplicação ou aplicação programada!';
         RAISE vr_exc_erro;
      END IF;

      -- Se conta do proponente for a mesma do terceiro
      IF pr_nrdconta = pr_nrctater THEN
         vr_dscritic := 'Não é permitido utilizar a conta do proponente como garantia de aplicação de terceiro!';
         RAISE vr_exc_erro;
      END IF;

      -- Valida o bloqueio da garantia
      BLOQ0001.pc_valida_bloqueio_garantia(pr_vlropera          => pr_vlropera
                                          ,pr_permingar         => pr_permingr
                                          ,pr_resgate_libera    => pr_inresper
                                          ,pr_tpctrato          => pr_lintpctr
                                          ,pr_inaplica_propria  => pr_inaplpro
                                          ,pr_vlaplica_propria  => pr_vlaplpro
                                          ,pr_inpoupa_propria   => pr_inpoupro
                                          ,pr_vlpoupa_propria   => pr_vlpoupro
                                          ,pr_resgate_automa    => pr_inresaut
                                          ,pr_inaplica_terceiro => pr_inaplter
                                          ,pr_vlaplica_terceiro => pr_vlaplter
                                          ,pr_inpoupa_terceiro  => pr_inpouter
                                          ,pr_vlpoupa_terceiro  => pr_vlpouter
                                          ,pr_dscritic          => vr_dscritic);
      -- Se ocorreu erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Seta o ID
      vr_idcobert := pr_idcobert;
      
      -- Se ja existe cadastro
      IF vr_idcobert > 0 THEN
        -- Se for inclusao
        IF pr_tipaber IN('I','AI') THEN
            vr_blupdate := TRUE;
        ELSE
          -- Seleciona garantias para operacoes de credito
          OPEN cr_cobertura(pr_idcobert => vr_idcobert);
          FETCH cr_cobertura INTO rw_cobertura;
          vr_blnachou := cr_cobertura%FOUND;
          CLOSE cr_cobertura;
          -- Se achou registro
          IF vr_blnachou THEN
            -- Se todos os campos sao iguais, seta para atualizar
            IF rw_cobertura.perminimo            = pr_permingr AND
               rw_cobertura.inaplicacao_propria  = pr_inaplpro AND
               rw_cobertura.inpoupanca_propria   = pr_inpoupro AND
               rw_cobertura.nrconta_terceiro     = pr_nrctater AND
               rw_cobertura.inaplicacao_terceiro = pr_inaplter AND
               rw_cobertura.inpoupanca_terceiro  = pr_inpouter THEN
               vr_blupdate := TRUE;
            END IF;
          END IF;
        END IF;
      END IF;

      -- Se o percentual for igual a zero e não foi selecionado aplicacao ou poupanca programada
      IF pr_permingr = 0 AND 
		 vr_blupdate = FALSE AND
        (NVL(pr_inaplpro,0) = 0 AND
         NVL(pr_inpoupro,0) = 0 AND
         NVL(pr_inaplter,0) = 0 AND
         NVL(pr_inpouter,0) = 0) THEN
		-- Não criaremos nem atualizaremos o registro de cobertura, apenas retornamos o valor zerado
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
													,pr_tag_nova => 'idcobert'
													,pr_tag_cont => 0
													,pr_des_erro => vr_dscritic);				 
        vr_indx := 1;
        -- Validar se perde aprovação
        -- Percentual minimo da cobertura da garantia no momento da contratacao
        IF nvl(rw_cobertura.perminimo,0) <> nvl(pr_permingr,0) THEN
          vr_perde_aprovacao := 1;
        END IF;
        --
        -- Utilizacao de aplicacao propria para cobertura da garantia da operacao (0-Nao/ 1-Sim)
        IF nvl(rw_cobertura.inaplicacao_propria,0) <> nvl(pr_inaplpro,0) THEN
          vr_perde_aprovacao := 1;
        END IF;
        --
        -- Utilizacao de poupanca programada propria para cobertura (0-Nao/ 1-Sim)
        IF nvl(rw_cobertura.inpoupanca_propria,0) <> nvl(pr_inpoupro,0) THEN
          vr_perde_aprovacao := 1;
        END IF;
        -- Conta de cooperado terceiro para cobertura da garantia da operacao
        IF nvl(rw_cobertura.nrconta_terceiro,0) <> nvl(pr_nrctater,0) THEN
          vr_perde_aprovacao := 1;            
        END IF;
        -- Utilizacao de aplicacao terceiro para cobertura da garantia (0-Nao/ 1-Sim)
        IF nvl(rw_cobertura.inaplicacao_terceiro,0) <> nvl(pr_inaplter,0) THEN
          vr_perde_aprovacao := 1;            
        END IF; 

        -- Utilizacao de poupanca programada terceiro para cobertura da garantia (0-Nao/ 1-Sim)
        IF nvl(rw_cobertura.inpoupanca_terceiro,0) <> nvl(pr_inpouter,0) THEN
          vr_perde_aprovacao := 1;            
        END IF;
        -- Resgate Automatico da Garantia (0-Nao/ 1-Sim)
        IF nvl(rw_cobertura.inresgate_automatico,0) <> nvl(pr_inresaut,0) THEN
          vr_perde_aprovacao := 1;            
        END IF;          
        -- Quantidade de dias permitidos de atraso antes do resgate automatico
        IF nvl(rw_cobertura.qtdias_atraso_permitido,0) <> nvl(pr_diatrper,0) THEN
          vr_perde_aprovacao := 1;            
        END IF;
        --
       GENE0007.pc_insere_tag(pr_xml   => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'ingarapr'
                          ,pr_tag_cont => vr_perde_aprovacao
                          ,pr_des_erro => vr_dscritic);  
                            
         RAISE vr_exc_null;
      END IF;

      vr_indx  := 1;
      -- Grava os dados
      BEGIN
        -- Se for para atualizar
        IF vr_blupdate THEN
          -- Validar se perde aprovação
          -- Percentual minimo da cobertura da garantia no momento da contratacao
          IF nvl(rw_cobertura.perminimo,0) <> nvl(pr_permingr,0) THEN
            vr_perde_aprovacao := 1;
          END IF;
          --
          -- Utilizacao de aplicacao propria para cobertura da garantia da operacao (0-Nao/ 1-Sim)
          IF nvl(rw_cobertura.inaplicacao_propria,0) <> nvl(pr_inaplpro,0) THEN
            vr_perde_aprovacao := 1;
          END IF;
          --
          -- Utilizacao de poupanca programada propria para cobertura (0-Nao/ 1-Sim)
          IF nvl(rw_cobertura.inpoupanca_propria,0) <> nvl(pr_inpoupro,0) THEN
            vr_perde_aprovacao := 1;
          END IF;
          -- Conta de cooperado terceiro para cobertura da garantia da operacao
          IF nvl(rw_cobertura.nrconta_terceiro,0) <> nvl(pr_nrctater,0) THEN
            vr_perde_aprovacao := 1;            
          END IF;
          -- Utilizacao de aplicacao terceiro para cobertura da garantia (0-Nao/ 1-Sim)
          IF nvl(rw_cobertura.inaplicacao_terceiro,0) <> nvl(pr_inaplter,0) THEN
            vr_perde_aprovacao := 1;            
          END IF; 

          -- Utilizacao de poupanca programada terceiro para cobertura da garantia (0-Nao/ 1-Sim)
          IF nvl(rw_cobertura.inpoupanca_terceiro,0) <> nvl(pr_inpouter,0) THEN
            vr_perde_aprovacao := 1;            
          END IF;
          -- Resgate Automatico da Garantia (0-Nao/ 1-Sim)
          IF nvl(rw_cobertura.inresgate_automatico,0) <> nvl(pr_inresaut,0) THEN
            vr_perde_aprovacao := 1;            
          END IF;          
          -- Quantidade de dias permitidos de atraso antes do resgate automatico
          IF nvl(rw_cobertura.qtdias_atraso_permitido,0) <> nvl(pr_diatrper,0) THEN
            vr_perde_aprovacao := 1;            
          END IF;
          --
          UPDATE tbgar_cobertura_operacao
             SET perminimo               = pr_permingr
                ,inaplicacao_propria     = pr_inaplpro
                ,inpoupanca_propria      = pr_inpoupro
                ,nrconta_terceiro        = pr_nrctater
                ,inaplicacao_terceiro    = pr_inaplter
                ,inpoupanca_terceiro     = pr_inpouter
                ,inresgate_automatico    = pr_inresaut
                ,qtdias_atraso_permitido = pr_diatrper
           WHERE idcobertura             = vr_idcobert;
        ELSE
          IF nvl(pr_permingr,0) > 0  THEN
            vr_perde_aprovacao := 1;
          END IF;
          --
          -- Utilizacao de aplicacao propria para cobertura da garantia da operacao (0-Nao/ 1-Sim)
          IF nvl(pr_inaplpro,0) > 0 THEN
            vr_perde_aprovacao := 1;
          END IF;
          --
          -- Utilizacao de poupanca programada propria para cobertura (0-Nao/ 1-Sim)
          IF nvl(pr_inpoupro,0) > 0 THEN
            vr_perde_aprovacao := 1;
          END IF;
          -- Conta de cooperado terceiro para cobertura da garantia da operacao
          IF nvl(pr_nrctater,0) > 0 THEN
            vr_perde_aprovacao := 1;            
          END IF;
          -- Utilizacao de aplicacao terceiro para cobertura da garantia (0-Nao/ 1-Sim)
          IF nvl(pr_inaplter,0) > 0 THEN
            vr_perde_aprovacao := 1;            
          END IF; 

          -- Utilizacao de poupanca programada terceiro para cobertura da garantia (0-Nao/ 1-Sim)
          IF nvl(pr_inpouter,0) > 0 THEN            
            vr_perde_aprovacao := 1;            
          END IF;
          -- Resgate Automatico da Garantia (0-Nao/ 1-Sim)
          IF nvl(pr_inresaut,0) > 0 THEN
            vr_perde_aprovacao := 1;            
          END IF;          
          -- Quantidade de dias permitidos de atraso antes do resgate automatico
          IF nvl(pr_diatrper,0) > 0 THEN
            vr_perde_aprovacao := 1;            
          END IF;
          --
          INSERT INTO tbgar_cobertura_operacao
                     (cdcooper
                     ,nrdconta
                     ,tpcontrato
                     ,nrcontrato
                     ,insituacao
                     ,perminimo
                     ,inaplicacao_propria
                     ,inpoupanca_propria
                     ,nrconta_terceiro
                     ,inaplicacao_terceiro
                     ,inpoupanca_terceiro
                     ,inresgate_automatico
                     ,qtdias_atraso_permitido)
                VALUES
                     (vr_cdcooper
                     ,pr_nrdconta
                     ,pr_tpctrato
                     ,0
                     ,0 -- Em estudo
                     ,pr_permingr
                     ,pr_inaplpro
                     ,pr_inpoupro
                     ,pr_nrctater
                     ,pr_inaplter
                     ,pr_inpouter
                     ,pr_inresaut
                     ,pr_diatrper)
            RETURNING idcobertura
                 INTO vr_idcobert;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao gravar dados na TBGAR_COBERTURA_OPERACAO: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      COMMIT;

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
                            ,pr_tag_nova => 'idcobert'
                            ,pr_tag_cont => vr_idcobert
                            ,pr_des_erro => vr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'ingarapr'
                            ,pr_tag_cont => vr_perde_aprovacao
                            ,pr_des_erro => vr_dscritic);
    EXCEPTION
	  WHEN vr_exc_null THEN
	    NULL;
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela GAROPC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_dados;

PROCEDURE pc_valida_dados(pr_nmdatela     IN VARCHAR2 --> Nome da tela que chamou
                         ,pr_tipaber      IN VARCHAR2 -->  Tipo da abertura da tela
                         ,pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                         ,pr_nrctater     IN crapadt.nrdconta%TYPE --> Numero da conta terceiro
                         ,pr_lintpctr     IN craplcr.tpctrato%TYPE --> Tipo de contrato utilizado pela linha
                         ,pr_vlropera     IN NUMBER --> Valor da operacao
                         ,pr_permingr     IN NUMBER --> Percentual de Garantia Necessaria
                         ,pr_inresper     IN INTEGER --> Resgate permitido
                         ,pr_diatrper     IN INTEGER --> Qtde dias permitidos atraso antes do resgate
                         ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                         ,pr_inaplpro     IN INTEGER --> Aplicacao propria
                         ,pr_vlaplpro     IN NUMBER --> Valor da Aplicacao propria
                         ,pr_inpoupro     IN INTEGER --> Poupanca propria
                         ,pr_vlpoupro     IN NUMBER --> Valor da Poupanca propria
                         ,pr_inresaut     IN INTEGER --> Resgate automatico
                         ,pr_inaplter     IN INTEGER --> Aplicacao terceiro
                         ,pr_vlaplter     IN NUMBER --> Valor da Aplicacao terceiro
                         ,pr_inpouter     IN INTEGER --> Poupanca terceiro
                         ,pr_vlpouter     IN NUMBER --> Valor da Poupanca terceiro
                         ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                         ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                         ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                         ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro    OUT VARCHAR2
                           ) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_valida_dados
    Sistema : Ayllos Web
    Autor   : Rafael Monteiro
    Data    : Abril/2019                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os dados para tela GAROPC.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_exc_null EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis locais
      vr_blnachou BOOLEAN;
      vr_blupdate BOOLEAN := FALSE;
      vr_idcobert tbgar_cobertura_operacao.idcobertura%TYPE;
      vr_nrdconta_aux crapass.nrdconta%TYPE;
      vr_perde_aprovacao NUMBER(1) := 0; -- 0 Nao perde e 1 Perde aprovacao
      vr_indx            PLS_INTEGER;
      vr_nrdrowid        ROWID;
      --Será utilizado para gravar todas as alterações
      TYPE typ_reg_alteracoes IS RECORD(dsmotivo varchar2(100)   --> Motivos da Perda
                                       ,nmcampo  varchar2(200)   --> Nome do campo
                                       ,dsdadant varchar2(4000)   --> Valor Anterior
                                       ,dsdadatu varchar2(4000)); --> Valor Atual
      /* Definição de tabela que compreenderá os registros acima declarados */
      TYPE typ_tab_alteracoes IS TABLE OF typ_reg_alteracoes INDEX BY PLS_INTEGER;
      /* Variável que armazenará uma instancia da tabela */
      vr_tab_alteracoes typ_tab_alteracoes;      

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_GAROPC'
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

      -- Se veio da ADITIV eh necessario ter selecionado ao menos um sim 
      -- entre aplicacao e poupanca programada propria ou de terceiros
      IF pr_nmdatela = 'ADITIV' AND
         NVL(pr_inaplpro,0) = 0 AND
         NVL(pr_inpoupro,0) = 0 AND
         NVL(pr_inaplter,0) = 0 AND
         NVL(pr_inpouter,0) = 0 THEN
         vr_dscritic := 'Não é possível criar este tipo de Aditivo Contratual sem Cobertura da Operação.';
         RAISE vr_exc_erro;
      END IF;

      -- Se for um percentual invalido
      IF pr_permingr > 999.99 THEN
         vr_dscritic := 'Percentual da garantia sugerida não permitida!';
         RAISE vr_exc_erro;
      END IF;

      -- Se o percentual for zero e foi selecionado aplicacao ou poupanca programada
      IF pr_permingr = 0 AND 
        (NVL(pr_inaplpro,0) = 1 OR
         NVL(pr_inpoupro,0) = 1 OR
         NVL(pr_inaplter,0) = 1 OR
         NVL(pr_inpouter,0) = 1) THEN
         vr_dscritic := 'Não será permitido utilizar Aplicação ou Poupança Programada com valor de cobertura de garantia igual a 0!';
         RAISE vr_exc_erro;
      END IF;

      -- Se o percentual for maior que zero e não foi selecionado aplicacao ou poupanca programada
      IF pr_permingr > 0 AND 
        (NVL(pr_inaplpro,0) = 0 AND
         NVL(pr_inpoupro,0) = 0 AND
         NVL(pr_inaplter,0) = 0 AND
         NVL(pr_inpouter,0) = 0) THEN
         vr_dscritic := 'Não é permitido informar um percentual mínimo de cobertura sem vincular uma aplicação/poupança!';
         RAISE vr_exc_erro;
      END IF;

      -- Se conta do proponente for a mesma do terceiro
      IF pr_nrdconta = pr_nrctater THEN
         vr_dscritic := 'Não é permitido utilizar a conta do proponente como garantia de aplicação de terceiro!';
         RAISE vr_exc_erro;
      END IF;

      -- Valida o bloqueio da garantia
      BLOQ0001.pc_valida_bloqueio_garantia(pr_vlropera          => pr_vlropera
                                          ,pr_permingar         => pr_permingr
                                          ,pr_resgate_libera    => pr_inresper
                                          ,pr_tpctrato          => pr_lintpctr
                                          ,pr_inaplica_propria  => pr_inaplpro
                                          ,pr_vlaplica_propria  => pr_vlaplpro
                                          ,pr_inpoupa_propria   => pr_inpoupro
                                          ,pr_vlpoupa_propria   => pr_vlpoupro
                                          ,pr_resgate_automa    => pr_inresaut
                                          ,pr_inaplica_terceiro => pr_inaplter
                                          ,pr_vlaplica_terceiro => pr_vlaplter
                                          ,pr_inpoupa_terceiro  => pr_inpouter
                                          ,pr_vlpoupa_terceiro  => pr_vlpouter
                                          ,pr_dscritic          => vr_dscritic);
      -- Se ocorreu erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

                              
    EXCEPTION
    WHEN vr_exc_null THEN
      NULL;
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela GAROPC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_valida_dados;
  
END TELA_GAROPC;
/
