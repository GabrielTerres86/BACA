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
  ---------------------------------------------------------------------------------------------------------------
  
  /* Busca contratos de acordos do Cooperado */
  PROCEDURE pc_busca_ctr_acordos(pr_nrdconta   IN crapceb.nrdconta%TYPE --Número da conta solicitada;
                                ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK

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
  ---------------------------------------------------------------------------------------------------------------

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

    Objetivo  : Retornar a listagem de contratos de acordos.

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

END TELA_ATENDA_OCORRENCIAS;
/
