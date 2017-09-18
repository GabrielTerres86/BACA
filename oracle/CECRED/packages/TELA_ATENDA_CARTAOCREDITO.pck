CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_CARTAOCREDITO IS

  PROCEDURE pc_busca_hist_limite_crd(pr_cdcooper  IN tbcrd_limite_atualiza.cdcooper%TYPE       --> Cooperativa
                                    ,pr_nrdconta  IN tbcrd_limite_atualiza.nrdconta%TYPE       --> Conta
                                    ,pr_nrcctitg  IN tbcrd_limite_atualiza.nrconta_cartao%TYPE --> Cartão
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

END TELA_ATENDA_CARTAOCREDITO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_CARTAOCREDITO IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_CARTAOCREDITO
  --  Sistema  : Ayllos Web
  --  Autor    : Renato Darosci
  --  Data     : Agosto/2017                 Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela de Cartão de Crédito
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_hist_limite_crd(pr_cdcooper  IN tbcrd_limite_atualiza.cdcooper%TYPE       --> Cooperativa
                                    ,pr_nrdconta  IN tbcrd_limite_atualiza.nrdconta%TYPE       --> Conta
                                    ,pr_nrcctitg  IN tbcrd_limite_atualiza.nrconta_cartao%TYPE --> Cartão
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
  /* .............................................................................

    Programa: pc_busca_hist_limite_crd
    Sistema : Ayllos Web
    Autor   : Renato Darosci
    Data    : Agosto/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar o histórico de alteração de limite de 
                cartão de crédito

    Alteracoes: 
  ..............................................................................*/

    -- Buscar todos os lançamentos
    CURSOR cr_limite IS
      SELECT to_char(atu.dtretorno,'DD/MM/YYYY')  dtretorno
           , DECODE(atu.cdcanal, 14, 'AUTOMATICA'   /* SAS */
                                   , 'MANUAL' )   dstipatu
           , atu.vllimite_anterior
           , atu.vllimite_alterado
        FROM tbcrd_limite_atualiza atu
       WHERE atu.cdcooper       = pr_cdcooper
         AND atu.nrdconta       = pr_nrdconta
         AND atu.nrconta_cartao = pr_nrcctitg
         AND atu.tpsituacao     = 3 /* Concluido com sucesso */
       ORDER BY atu.dtretorno DESC
              , atu.vllimite_alterado DESC;

    -- Variavel de criticas
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis gerais
    vr_cont_tag PLS_INTEGER := 0;
    
  BEGIN
    -- Extrai os dados vindos do XML
  /*  GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);*/

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    -- Para cada um dos históricos de alteração de limite
    FOR rw_limite IN cr_limite LOOP
      -- Insere o nodo de histórico
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'historico'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      -- Insere a data de alteração do limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'dtaltera'
                            ,pr_tag_cont => rw_limite.dtretorno
                            ,pr_des_erro => vr_dscritic);
                            
      -- Insere a forma de atualização do limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'dstipalt'
                            ,pr_tag_cont => rw_limite.dstipatu
                            ,pr_des_erro => vr_dscritic);
                            
      -- Valor de limite antigo
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'vllimold'
                            ,pr_tag_cont => TO_CHAR(rw_limite.vllimite_anterior,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                            ,pr_des_erro => vr_dscritic);
      -- Novo valor de limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'vllimnew'
                            ,pr_tag_cont => TO_CHAR(rw_limite.vllimite_alterado,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                            ,pr_des_erro => vr_dscritic);

      -- Incrementa o contador de tags
      vr_cont_tag := vr_cont_tag + 1;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PC_BUSCA_HIST_LIMITE_CRD: ' || SQLERRM;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_hist_limite_crd;

END TELA_ATENDA_CARTAOCREDITO;
/
