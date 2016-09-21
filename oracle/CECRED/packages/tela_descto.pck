CREATE OR REPLACE PACKAGE CECRED.TELA_DESCTO AS

  /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa: TELA_DESCTO                     Antiga: 
  --  Autor   : Jaison
  --  Data    : Setembro/2016                   Ultima Atualizacao: 
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo DESCTO - Controle de Desconto de Cheques.
  --
  --  Alteracoes: 
  --  
  --------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_rel_bordero_nao_liberados(pr_dtiniper   IN crapbdc.dtmvtolt%TYPE --> Data inicial
                                        ,pr_dtfimper   IN crapbdc.dtmvtolt%TYPE --> Data final
                                        ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Numero do PA
                                        ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrborder   IN crapbdc.nrborder%TYPE --> Numero do bordero
                                        ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

END TELA_DESCTO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_DESCTO AS

 /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa: TELA_DESCTO                     Antiga: 
  --  Autor   : Jaison
  --  Data    : Setembro/2016                   Ultima Atualizacao: 
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo DESCTO - Controle de Desconto de Cheques.
  --
  --  Alteracoes: 
  --  
  --------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_rel_bordero_nao_liberados(pr_dtiniper   IN crapbdc.dtmvtolt%TYPE --> Data inicial
                                        ,pr_dtfimper   IN crapbdc.dtmvtolt%TYPE --> Data final
                                        ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Numero do PA
                                        ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrborder   IN crapbdc.nrborder%TYPE --> Numero do bordero
                                        ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_rel_bordero_nao_liberados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para chamar as impressoes.

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

      -- Variaveis gerais
      vr_nmarqpdf VARCHAR2(1000);

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gera_impressao'
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

      -- Se NAO informou data inicial
      IF TRIM(pr_dtiniper) IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe a data.###dtiniper';
        RAISE vr_exc_erro;
      END IF;

      -- Se NAO informou data final
      IF TRIM(pr_dtfimper) IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe a data.###dtfimper';
        RAISE vr_exc_erro;
      END IF;

      -- Se foi informado intervalo superior a 60 dias
      IF (pr_dtiniper - pr_dtfimper) > 60 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe um intervalo de até 60 dias.###dtfimper';
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
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
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
        pr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_rel_bordero_nao_liberados;

END TELA_DESCTO;
/
