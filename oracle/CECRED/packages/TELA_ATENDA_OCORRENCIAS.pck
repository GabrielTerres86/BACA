CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_OCORRENCIAS IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_OCORRENCIAS
  --  Sistema  : Procedimentos para tela Atenda / Ocorrencias
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Setembro/2016.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Ocorrencias
  --
  -- Alterado: 23/01/2018 - Daniel AMcom
  -- Ajuste: Criada procedure pc_busca_dados_risco
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Busca contratos de acordos do Cooperado */
  PROCEDURE pc_busca_ctr_acordos(pr_nrdconta   IN crapceb.nrdconta%TYPE --Número da conta solicitada;
                                ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK

 PROCEDURE pc_busca_dados_risco(pr_nrdconta IN crawepr.nrdconta%TYPE --> Número da conta
                               ,pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

END TELA_ATENDA_OCORRENCIAS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_OCORRENCIAS IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_OCORRENCIAS
  --  Sistema  : Procedimentos para tela Atenda / Ocorrencias
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Setembro/2016.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Seguros
  --
  -- Alterado: 23/01/2018 - Reginaldo (AMcom)
  -- Ajuste: Criada procedure pc_busca_dados_risco
  --
  ---------------------------------------------------------------------------------------------------------------

  FUNCTION fn_busca_rating(pr_cdcooper NUMBER, pr_nrdconta NUMBER)
    RETURN crapnrc.indrisco%TYPE AS vr_rating crapnrc.indrisco%TYPE;
  BEGIN
     SELECT rat.indrisco
       INTO vr_rating
       FROM crapnrc rat
          , crapass a
      WHERE a.cdcooper = pr_cdcooper
        AND a.nrdconta = pr_nrdconta
        AND rat.cdcooper(+) = a.cdcooper
        AND rat.nrdconta(+) = a.nrdconta
        AND rat.insitrat(+) = 2
        AND ROWNUM = 1;

     RETURN vr_rating;
  END fn_busca_rating;

  FUNCTION fn_busca_riscos_contrato(pr_cdcooper NUMBER, pr_nrdconta NUMBER, pr_dtmvtoan DATE)
    RETURN crapris%ROWTYPE AS rw_risco crapris%ROWTYPE;
  BEGIN
     SELECT ris.*
        INTO rw_risco
       FROM crapris ris
			    , crapass aux
      WHERE aux.cdcooper = pr_cdcooper
			  AND aux.nrdconta = pr_nrdconta
			  AND ris.cdcooper(+) = aux.cdcooper
        AND ris.nrdconta(+) = aux.nrdconta
        AND ris.dtrefere(+) = pr_dtmvtoan
        AND ris.inddocto(+) = 1
        AND ROWNUM = 1;

     RETURN rw_risco;
  END fn_busca_riscos_contrato;

  FUNCTION fn_busca_risco_agravado(pr_cdcooper NUMBER, pr_nrdconta NUMBER)
    RETURN tbrisco_cadastro_conta.cdnivel_risco%TYPE AS vr_risco_agr tbrisco_cadastro_conta.cdnivel_risco%TYPE;
  BEGIN
    SELECT agr.cdnivel_risco
      INTO vr_risco_agr
      FROM tbrisco_cadastro_conta agr
         , crapass aux
     WHERE aux.cdcooper = pr_cdcooper
       AND aux.nrdconta = pr_nrdconta
       AND agr.cdcooper(+) = aux.cdcooper
       AND agr.nrdconta(+) = aux.nrdconta;

    RETURN vr_risco_agr;
  END fn_busca_risco_agravado;

  FUNCTION fn_busca_grupo_economico(pr_cdcooper NUMBER, pr_nrdconta NUMBER, pr_nrcpfcgc NUMBER)
    RETURN crapgrp%ROWTYPE AS rw_grp crapgrp%ROWTYPE;
  BEGIN
    SELECT g.*
      INTO rw_grp
      FROM crapgrp g
         , crapass aux
     WHERE aux.cdcooper = pr_cdcooper
       AND aux.nrdconta = pr_nrdconta
       AND aux.nrcpfcgc = pr_nrcpfcgc
       AND g.cdcooper(+) = aux.cdcooper
       AND g.nrctasoc(+) = aux.nrdconta
       AND g.nrdconta(+) = aux.nrdconta
       AND g.nrcpfcgc(+) = aux.nrcpfcgc;

    RETURN rw_grp;
  END fn_busca_grupo_economico;

  FUNCTION fn_calcula_risco_atraso(qtdiaatr NUMBER)
    RETURN crawepr.dsnivris%TYPE AS risco_atraso crawepr.dsnivris%TYPE;
  BEGIN
      risco_atraso :=  CASE WHEN qtdiaatr IS NULL THEN 'A'
			                      WHEN qtdiaatr <   15  THEN 'A'
                            WHEN qtdiaatr <=  30  THEN 'B'
                            WHEN qtdiaatr <=  60  THEN 'C'
                            WHEN qtdiaatr <=  90  THEN 'D'
                            WHEN qtdiaatr <= 120  THEN 'E'
                            WHEN qtdiaatr <= 150  THEN 'F'
                            WHEN qtdiaatr <= 180  THEN 'G'
                            ELSE 'H' END;
      RETURN risco_atraso;
  END fn_calcula_risco_atraso;

  PROCEDURE pc_busca_risco_ult_central(pr_cdcooper          IN crawepr.cdcooper%TYPE
                                      ,pr_nrdconta          IN crawepr.nrdconta%TYPE
                                      ,pr_dtultdma          IN crapdat.dtultdma%TYPE
                                      ,vr_risco_ult_central OUT crawepr.dsnivris%TYPE
                                      ,vr_data_ult_central  OUT crapris.dtdrisco%TYPE
                                      ,vr_valor_divida      OUT crapris.vldivida%TYPE) IS
  -- Variáveis
      vr_dstextab          craptab.dstextab%TYPE;
			vr_repete_busca      INTEGER := 0;
  BEGIN
      -- Recupera parâmetro da TAB089
      SELECT t.dstextab
         INTO vr_dstextab
        FROM craptab t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nmsistem = 'CRED'
         AND t.tptabela = 'USUARI'
         AND t.cdempres = 11
         AND t.cdacesso = 'RISCOBACEN'
         AND t.tpregist = 000 ;

      BEGIN
        -- Recupera dados da última central de riscos
        SELECT uc.innivris, uc.dtdrisco, uc.vldivida
          INTO vr_risco_ult_central, vr_data_ult_central, vr_valor_divida
          FROM crapris uc
         WHERE uc.cdcooper = pr_cdcooper
           AND uc.nrdconta = pr_nrdconta
           AND uc.dtrefere = pr_dtultdma
           AND uc.inddocto = 1
           AND uc.vldivida > TO_NUMBER(replace(substr(vr_dstextab, 3, 9), ',', '.'))
           AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
					vr_repete_busca := 1;
      END;

			IF vr_repete_busca = 1 THEN
			   BEGIN
				    SELECT uc.innivris, uc.dtdrisco, uc.vldivida
							INTO vr_risco_ult_central, vr_data_ult_central, vr_valor_divida
							FROM crapris uc
						 WHERE uc.cdcooper = pr_cdcooper
							 AND uc.nrdconta = pr_nrdconta
							 AND uc.dtrefere = pr_dtultdma
							 AND uc.inddocto = 1
							 AND ROWNUM = 1;
				 EXCEPTION
				   WHEN NO_DATA_FOUND THEN
					    vr_risco_ult_central := NULL;
							vr_data_ult_central := NULL;
							vr_valor_divida := NULL;
				 END;
			END IF;

  END pc_busca_risco_ult_central;

  FUNCTION fn_traduz_risco(innivris NUMBER) RETURN crawepr.dsnivris%TYPE AS dsnivris crawepr.dsnivris%TYPE;
  BEGIN
      dsnivris :=  CASE WHEN innivris = 2 THEN 'A'
                        WHEN innivris = 3 THEN 'B'
                        WHEN innivris = 4 THEN 'C'
                        WHEN innivris = 5 THEN 'D'
                        WHEN innivris = 6 THEN 'E'
                        WHEN innivris = 7 THEN 'F'
                        WHEN innivris = 8 THEN 'G'
                        WHEN innivris = 9 THEN 'H'
                        ELSE '' END;
      RETURN dsnivris;
  END fn_traduz_risco;

  PROCEDURE pc_monta_reg_conta_xml(pr_retxml       IN OUT NOCOPY XMLType
                               ,pr_pos_conta    IN INTEGER
                               ,pr_dscritic     IN OUT VARCHAR2
                               ,pr_num_conta    IN crapass.nrdconta%TYPE
                               ,pr_cpf_cnpj     IN crapass.nrcpfcgc%TYPE
                               ,pr_num_contrato IN crawepr.nrctremp%TYPE
                               ,pr_ris_inclusao IN crawepr.dsnivris%TYPE
                               ,pr_ris_grupo    IN crawepr.dsnivris%TYPE
                               ,pr_rating       IN crawepr.dsnivris%TYPE
                               ,pr_ris_atraso   IN crawepr.dsnivris%TYPE
                               ,pr_ris_agravado IN crawepr.dsnivris%TYPE
                               ,pr_ris_operacao IN crawepr.dsnivris%TYPE
                               ,pr_ris_cpf      IN crawepr.dsnivris%TYPE
                               ,pr_data_risco   IN VARCHAR2
                               ,pr_dias_risco   IN INTEGER
                               ,pr_numero_grupo IN crapgrp.nrdgrupo%TYPE) IS
  BEGIN
         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Contas',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Conta',
                             pr_tag_cont => NULL,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'numero_conta',
                             pr_tag_cont => pr_num_conta,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'cpf_cnpj',
                             pr_tag_cont => pr_cpf_cnpj,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'contrato',
                             pr_tag_cont => pr_num_contrato,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_inclusao',
                             pr_tag_cont => pr_ris_inclusao,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_grupo',
                             pr_tag_cont => pr_ris_grupo,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'rating',
                             pr_tag_cont => pr_rating,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_atraso',
                             pr_tag_cont => pr_ris_atraso,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_agravado',
                             pr_tag_cont => pr_ris_agravado,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_operacao',
                             pr_tag_cont => pr_ris_operacao,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_cpf',
                             pr_tag_cont => pr_ris_cpf,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'data_risco',
                             pr_tag_cont => pr_data_risco,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'dias_risco',
                             pr_tag_cont => pr_dias_risco,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'numero_gr_economico',
                             pr_tag_cont => pr_numero_grupo,
                             pr_des_erro => pr_dscritic);
  END pc_monta_reg_conta_xml;

  PROCEDURE pc_monta_reg_central_risco(pr_retxml           IN OUT NOCOPY XMLType
                                   ,pr_dscritic         IN OUT VARCHAR2
                                   ,pr_ris_ult_central  IN crawepr.dsnivris%TYPE
                                   ,pr_data_ult_central IN VARCHAR2
                                   ,pr_qtd_dias_risco   IN VARCHAR2
                                   ,pr_ris_final        IN crawepr.dsnivris%TYPE) IS
  BEGIN
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Central',
                             pr_tag_cont => NULL,
                             pr_des_erro => pr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'risco_ult_central',
                             pr_tag_cont => pr_ris_ult_central,
                             pr_des_erro => pr_dscritic);

     gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'data_ult_central',
                             pr_tag_cont => pr_data_ult_central,
                             pr_des_erro => pr_dscritic);

     gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'qtd_dias_risco',
                             pr_tag_cont => pr_qtd_dias_risco,
                             pr_des_erro => pr_dscritic);

     gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'risco_final',
                             pr_tag_cont => pr_ris_final,
                             pr_des_erro => pr_dscritic);
  END pc_monta_reg_central_risco;

  /* Busca contratos de acordos do Cooperado */
  PROCEDURE pc_busca_ctr_acordos(pr_nrdconta   IN crapceb.nrdconta%TYPE --Número da conta solicitada;
                                ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK

  BEGIN

    /* .............................................................................

    Programa: pc_busca_ctr_acordos
    Sistema : Ayllos Web
    Autor   : Jean Michel
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar a listagem de contratos de acordos e riscos(Daniel AMcom).

    Alteracoes:
    ..............................................................................*/

    DECLARE

      -- Cursores

      -- Consulta de contratos de acordos ativos
      CURSOR cr_acordo(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                      ,pr_nrdconta tbrecup_acordo.nrdconta%TYPE
                      ,pr_cdsituacao tbrecup_acordo.cdsituacao%TYPE) IS
        SELECT tbrecup_acordo.cdcooper AS cdcooper
              ,tbrecup_acordo_contrato.nracordo AS nracordo
              ,tbrecup_acordo.nrdconta AS nrdconta
              ,tbrecup_acordo_contrato.nrctremp AS nrctremp
              ,DECODE(tbrecup_acordo_contrato.cdorigem,1,'Estouro de Conta',2,'Empréstimo',3,'Empréstimo','Inexistente') AS dsorigem
          FROM tbrecup_acordo_contrato
          JOIN tbrecup_acordo
            ON tbrecup_acordo.nracordo = tbrecup_acordo_contrato.nracordo
         WHERE tbrecup_acordo.cdcooper = pr_cdcooper
           AND tbrecup_acordo.nrdconta = pr_nrdconta
           AND tbrecup_acordo.cdsituacao = pr_cdsituacao;

      rw_acordo cr_acordo%ROWTYPE;

      -- Variavel de criticas
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
      vr_contador INTEGER := 0;

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
      -- Se encontrar erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'acordos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      FOR rw_acordo IN cr_acordo(pr_cdcooper   => vr_cdcooper
                                ,pr_nrdconta   => pr_nrdconta
                                ,pr_cdsituacao => 1) LOOP
        -- Informacoes de cabecalho de pacote
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordos', pr_posicao => 0, pr_tag_nova => 'acordo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'nracordo', pr_tag_cont => TO_CHAR(rw_acordo.nracordo), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'dsorigem', pr_tag_cont => TO_CHAR(rw_acordo.dsorigem), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => GENE0002.fn_mask_contrato(rw_acordo.nrctremp), pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => TO_CHAR(vr_contador), pr_des_erro => vr_dscritic);


    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_OCORRENCIAS - pc_busca_ctr_acordos: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATENDA_OCORRENCIAS - pc_busca_ctr_acordos: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_ctr_acordos;

 PROCEDURE pc_busca_dados_risco(pr_nrdconta IN crawepr.nrdconta%TYPE --> Número da conta
                               ,pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* ............................................................................

        Programa: pc_busca_dados_risco
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel/AMcom & Reginaldo/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar dados de risco a partir de uma conta base
        Observacao: -----
        Alteracoes:
      ..............................................................................*/

      ----------->>> VARIAVEIS <<<--------

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variáveis gerais da procedure
      vr_auxconta          INTEGER := 0; -- Contador auxiliar para posicão no XML
      vr_rating            crapnrc.indrisco%TYPE;
      vr_risco_agr         tbrisco_cadastro_conta.cdnivel_risco%TYPE;
      vr_risco_final       crawepr.dsnivris%TYPE;
      vr_risco_ult_central crawepr.dsnivris%TYPE;
      vr_data_ult_central  crapris.dtdrisco%TYPE;
      vr_valor_divida      crapris.vldivida%TYPE;
      vr_qtd_dias_risco    INTEGER;
			vr_qtd_contratos     INTEGER := 0;

      rw_dat   crapdat%ROWTYPE;
      rw_grp   crapgrp%ROWTYPE;
      rw_cbase crapass%ROWTYPE; -- Registro para os dados da conta base
      rw_risco crapris%ROWTYPE;

      ---------->> CURSORES <<--------
      -- Contas de mesmo titular da conta base
      CURSOR cr_outras_contas_do_titular(rw_cbase IN crapass%ROWTYPE) IS
      SELECT c.cdcooper
           , c.nrdconta
           , c.nrcpfcgc
           , c.inpessoa
           , c.dsnivris
           , w.dsnivori
           , w.dsnivcal
           , w.nrctremp
        FROM crapass c
           , crawepr w
           , crapepr e
       WHERE c.cdcooper = rw_cbase.cdcooper
         AND DECODE(rw_cbase.inpessoa, 1,
             gene0002.fn_mask(c.nrcpfcgc, '99999999999'),
             substr(gene0002.fn_mask(c.nrcpfcgc, '99999999999999'), 1, 8)) =
             DECODE(rw_cbase.inpessoa, 1,
             gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999'),
             substr(gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999999'), 1, 8))
         AND w.cdcooper = c.cdcooper
         AND w.nrdconta = c.nrdconta
         AND e.cdcooper = w.cdcooper
         AND e.nrdconta = w.nrdconta
         AND e.nrctremp = w.nrctremp
         AND e.inliquid = 0;
      rw_outras_contas_do_titular cr_outras_contas_do_titular%ROWTYPE;

    -- Contas dos grupos econômicos aos quais o titular da conta base pertence
    CURSOR cr_contas_grupo_economico(rw_cbase IN crapass%ROWTYPE) IS
    SELECT cgr.cdcooper
         , cgr.nrdconta
         , cgr.nrcpfcgc
         , cgr.inpessoa
         , cgr.dsnivris
         , w.dsnivori
         , w.dsnivcal
         , w.nrctremp
         , grp.nrdgrupo
         , grp.dsdrisgp
      FROM crapass cgr
         , crapgrp grp
         , crawepr w
         , crapepr e
     WHERE grp.cdcooper =  rw_cbase.cdcooper
       AND grp.nrctasoc =  rw_cbase.nrdconta
       AND DECODE(rw_cbase.inpessoa, 1,
                  gene0002.fn_mask(grp.nrcpfcgc, '99999999999'),
                  substr(gene0002.fn_mask(grp.nrcpfcgc, '99999999999999'), 1, 8)) =
           DECODE(rw_cbase.inpessoa, 1,
                  gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999'),
                  substr(gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999999'), 1, 8))
       AND grp.nrdconta <> rw_cbase.nrdconta
       AND cgr.cdcooper =  grp.cdcooper
       AND cgr.nrdconta =  grp.nrdconta
       AND cgr.nrcpfcgc =  grp.nrcpfcgc
       AND w.cdcooper   =  cgr.cdcooper
       AND w.nrdconta   =  cgr.nrdconta
       AND e.cdcooper   =  w.cdcooper
       AND e.nrdconta   =  w.nrdconta
       AND e.inliquid   =  0;
    rw_contas_grupo_economico cr_contas_grupo_economico%ROWTYPE;

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

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Contas',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      -- Busca calendário para a cooperativa selecionada
      SELECT dat.*
        INTO rw_dat
        FROM crapdat dat
       WHERE dat.cdcooper = pr_cdcooper;

      -- Busca dados da conta base
      SELECT cb.*
        INTO rw_cbase
        FROM crapass cb
       WHERE cb.cdcooper = pr_cdcooper
         AND cb.nrdconta = pr_nrdconta;

      -- Percorre contas de mesmo CPF/CNPJ da conta base
      FOR rw_outras_contas_do_titular
       IN cr_outras_contas_do_titular(rw_cbase) LOOP
          -- Busca o grupo econômico da conta
          rw_grp := fn_busca_grupo_economico(rw_outras_contas_do_titular.cdcooper
                                        , rw_outras_contas_do_titular.nrdconta
                                        , rw_outras_contas_do_titular.nrcpfcgc);

          -- Busca o rating da conta
          vr_rating := fn_busca_rating(rw_outras_contas_do_titular.cdcooper
                                  , rw_outras_contas_do_titular.nrdconta);

          -- Busca os riscos para o contrato
          rw_risco := fn_busca_riscos_contrato(rw_outras_contas_do_titular.cdcooper
                                          , rw_outras_contas_do_titular.nrdconta
                                          , rw_dat.dtmvtoan);

          -- Busca o risco agravado para a conta
          vr_risco_agr := fn_busca_risco_agravado(rw_outras_contas_do_titular.cdcooper
                                             , rw_outras_contas_do_titular.nrdconta);

          -- Adiciona registro para a conta no XML de retorno
          pc_monta_reg_conta_xml(pr_retxml
                            , vr_auxconta
                            , vr_dscritic
                            , rw_outras_contas_do_titular.nrdconta
                            , rw_outras_contas_do_titular.nrcpfcgc
                            , rw_outras_contas_do_titular.nrctremp
                            , rw_outras_contas_do_titular.dsnivori
                            , rw_grp.dsdrisgp
                            , vr_rating
                            , fn_calcula_risco_atraso(rw_risco.qtdiaatr)
                            , fn_traduz_risco(vr_risco_agr)
                            , rw_outras_contas_do_titular.dsnivcal
                            , rw_outras_contas_do_titular.dsnivris
                            , TO_CHAR(rw_risco.dtdrisco, 'DD/MM/YYYY')
                            , rw_dat.dtmvtolt - rw_risco.dtdrisco
                            , rw_grp.nrdgrupo);

          vr_auxconta := vr_auxconta + 1;
          vr_risco_final := rw_risco.innivris; -- Aproveita risco já recuperado
					vr_qtd_contratos := vr_qtd_contratos + 1;
      END LOOP;

      -- Percorre contas dos grupos econômicos em que o titular da conta base faz parte
      FOR rw_contas_grupo_economico
        IN cr_contas_grupo_economico(rw_cbase) LOOP

        -- Busca o rating da conta
          vr_rating := fn_busca_rating(rw_contas_grupo_economico.cdcooper
                                  , rw_contas_grupo_economico.nrdconta);

          -- Busca os riscos para o contrato
          rw_risco := fn_busca_riscos_contrato(rw_contas_grupo_economico.cdcooper
                                          , rw_contas_grupo_economico.nrdconta
                                          , rw_dat.dtmvtoan);

          -- Busca o risco agravado para a conta
          vr_risco_agr := fn_busca_risco_agravado(rw_contas_grupo_economico.cdcooper
                                             , rw_contas_grupo_economico.nrdconta);

          -- Adiciona registro para a conta no XML de retorno
          pc_monta_reg_conta_xml(pr_retxml
                            , vr_auxconta
                            , vr_dscritic
                            , rw_contas_grupo_economico.nrdconta
                            , rw_contas_grupo_economico.nrcpfcgc
                            , rw_contas_grupo_economico.nrctremp
                            , rw_contas_grupo_economico.dsnivori
                            , rw_contas_grupo_economico.dsdrisgp
                            , vr_rating
                            , fn_calcula_risco_atraso(rw_risco.qtdiaatr)
                            , fn_traduz_risco(vr_risco_agr)
                            , rw_contas_grupo_economico.dsnivcal
                            , rw_contas_grupo_economico.dsnivris
                            , TO_CHAR(rw_risco.dtdrisco, 'DD/MM/YYYY')
                            , rw_dat.dtmvtolt - rw_risco.dtdrisco
                            , rw_contas_grupo_economico.nrdgrupo);

        vr_auxconta := vr_auxconta + 1;
				vr_qtd_contratos := vr_qtd_contratos + 1;
      END LOOP;

      pc_busca_risco_ult_central(pr_cdcooper
                               , pr_nrdconta
                               , rw_dat.dtultdma
                               , vr_risco_ult_central
                               , vr_data_ult_central
                               , vr_valor_divida);

      -- Adiciona registro com dados da central de riscos no XML de retorno
      pc_monta_reg_central_risco(pr_retxml
                            , vr_dscritic
                            , fn_traduz_risco(vr_risco_ult_central)
                            , CASE WHEN vr_risco_ult_central > 2 THEN TO_CHAR(vr_data_ult_central, 'DD/MM/YYYY') ELSE '' END
                            , CASE WHEN vr_risco_ult_central > 2 THEN TO_CHAR(rw_dat.dtmvtolt-vr_data_ult_central) ELSE '' END
                            , fn_traduz_risco(vr_risco_final));
														
			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'qtd_contratos',
                             pr_tag_cont => vr_qtd_contratos,
                             pr_des_erro => pr_dscritic);
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;

      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_dscritic := vr_dscritic;

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
  END pc_busca_dados_risco;

END TELA_ATENDA_OCORRENCIAS;
/
