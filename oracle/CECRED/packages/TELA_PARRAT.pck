CREATE OR REPLACE PACKAGE CECRED.TELA_PARRAT IS

  ---------------------------------------------------------------------------
  --

  --   programa: pc_consultar
  --   sistema : CECRED
  --   sigla   : PARRAT
  --   autor   : Daniele rocha/amcom
  --   data    : Janeiro/2019             ultima atualizacao: --
  --
  -- dados referentes ao programa:
  --
  -- frequencia: -----
  -- objetivo  :
  -- alteracoes:
  --
  ---------------------------------------------------------------------------

  ---------------------------- estruturas de registro -----------------------

  ---------------------------------- rotinas --------------------------------
  PROCEDURE pc_consultar(pr_inpessoa                  IN INTEGER,
                         pr_tpproduto                 IN INTEGER,
                         pr_cooperat                  IN INTEGER,
                         pr_xmllog                    IN VARCHAR2 ,--> xml com informações de log
                         pr_cdcritic                  OUT PLS_INTEGER, --> código da crítica
                         pr_dscritic                  OUT VARCHAR2 ,--> descrição da crítica
                         pr_retxml                    IN OUT NOCOPY XMLTYPE , --> ARQUIvo de retorno do xml
                         pr_nmdcampo                  OUT VARCHAR2 ,--> NOMe do campo com erro
                         pr_des_erro                  OUT VARCHAR2);

  PROCEDURE pc_alterar(pr_inpessoa                    IN INTEGER,
                       pr_tpproduto                   IN INTEGER,
                       pr_qtdias_niveis_reducao       IN tbrat_param_geral.qtdias_niveis_reducao%type, -->      quantidade de niveis de rating para melhora/reducao do risco
                       pr_idnivel_risco_permite_reduc IN tbrat_param_geral.idnivel_risco_permite_reducao%type, -->    indicador dos niveis de risco de rating para melhora/reducao - exemplo: b, c, d
                       pr_qtdias_atencede_atualizacao IN tbrat_param_geral.qtdias_atencede_atualizacao%type, -->      prazo de antecedencia para atualizar rating
                       pr_qtdias_reaproveitamento     IN tbrat_param_geral.qtdias_reaproveitamento%type, -->      quantidade de dias para reaproveitamento da nota de rating
                       pr_qtmeses_expiracao_nota      IN tbrat_param_geral.qtmeses_expiracao_nota%type, -->        quantidade de meses para expiracao da nota de rating
                       pr_qtdias_atual_autom_baixo    IN tbrat_param_geral.qtdias_atualizacao_autom_baixo%type ,-->        quantidade de dias para atualizacao automatica rating conforme risco baixo em cc
                       pr_qtdias_atual_autom_medio    IN tbrat_param_geral.qtdias_atualizacao_autom_medio%type, -->      quantidade de dias para automatica rating conforme risco medio em cc
                       pr_qtdias_atual_autom_alto     IN tbrat_param_geral.qtdias_atualizacao_autom_alto%type, -->        quantidade de dias para automatica rating conforme risco alto em cc
                       pr_qtdias_atual_manual         IN tbrat_param_geral.qtdias_atualizacao_manual%type, -->    quantidade de dias para atualizacao manual
                       pr_incontingencia              IN INTEGER,
                       pr_cooperat                    IN INTEGER,
                       pr_xmllog                      IN VARCHAR2, --> Xml com informações de log
                       pr_cdcritic                    OUT PLS_INTEGER, --> código da crítica
                       pr_dscritic                    OUT VARCHAR2, --> DESCrição da crítica
                       pr_retxml                      IN OUT NOCOPY XMLTYPE, --> ARQUIvo de retorno do xml
                       pr_nmdcampo                    OUT VARCHAR2, --> NOME DO campo com erro
                       pr_des_erro                    OUT VARCHAR2); --> ERROS do processo

  PROCEDURE pc_consulta_param_alter_rating(pr_cooperat                  IN INTEGER,
                                           pr_xmllog                    IN VARCHAR2, --> XML com informações de LOG
                                           pr_cdcritic                  OUT PLS_INTEGER, --> Código da crítica
                                           pr_dscritic                  OUT VARCHAR2, --> Descrição da crítica
                                           pr_retxml                    IN OUT NOCOPY XMLType ,--> Arquivo de retorno do XML
                                           pr_nmdcampo                  OUT VARCHAR2 ,--> Nome do campo com erro
                                           pr_des_erro                  OUT VARCHAR2) ;

  PROCEDURE pc_altera_param_alter_rating(  pr_inpermite_alterar          IN INTEGER,
                                           pr_cooperat                   IN INTEGER,
                                           pr_xmllog                     IN VARCHAR2, --> xml com informações de log
                                           pr_cdcritic                   OUT PLS_INTEGER, --> código da crítica
                                           pr_dscritic                   OUT VARCHAR2, --> descrição da crítica
                                           pr_retxml                     IN OUT NOCOPY XMLTYPE, --> arquivo de retorno do xml
                                           pr_nmdcampo                   OUT VARCHAR2 ,--> nome do campo com erro
                                           pr_des_erro                   OUT VARCHAR2) ;

  PROCEDURE pc_consulta_param_biro(pr_xmllog    IN VARCHAR2, --> XML com informações de LOG
                                   pr_cdcritic  OUT PLS_INTEGER, --> Código da crítica
                                   pr_dscritic  OUT VARCHAR2, --> Descrição da crítica
                                   pr_retxml    IN OUT NOCOPY XMLType ,--> Arquivo de retorno do XML
                                   pr_nmdcampo  OUT VARCHAR2 ,--> Nome do campo com erro
                                   pr_des_erro  OUT VARCHAR2);

  PROCEDURE pc_altera_param_biro(pr_inbiro_ibratan    IN INTEGER,
                                 pr_cooperat          IN INTEGER,
                                 pr_xmllog            IN VARCHAR2, --> xml com informações de log
                                 pr_cdcritic          OUT PLS_INTEGER, --> código da crítica
                                 pr_dscritic          OUT VARCHAR2, --> descrição da crítica
                                 pr_retxml            IN OUT NOCOPY XMLTYPE, --> ARQUivo de retorno do xml
                                 pr_nmdcampo          OUT VARCHAR2, --> Nome do campo com erro
                                 pr_des_erro          OUT VARCHAR2);

  FUNCTION fn_busca_descricao_dominio (pr_nmdominio IN VARCHAR2
                                      ,pr_cddominio IN INTEGER) RETURN VARCHAR2;

  FUNCTION fn_buscar_reaproveitamento(pr_cdcooper IN craprbi.cdcooper%TYPE
                                     ,pr_inpessoa IN craprbi.inpessoa%TYPE DEFAULT 0
                                     ,pr_tpctrato IN NUMBER                DEFAULT 0)
    RETURN INTEGER;

   --> Consultar o valor do parametro na CRAPPRM
  PROCEDURE pc_consulta_param_crapprm (pr_cdcooper  IN INTEGER,
                                       pr_cdacesso  IN crapprm.cdacesso%TYPE, --> Código do acesso do parâmetro
                                       pr_xmllog    IN VARCHAR2, --> XML com informações de LOG
                                       pr_cdcritic  OUT PLS_INTEGER, --> Código da crítica
                                       pr_dscritic  OUT VARCHAR2, --> Descrição da crítica
                                       pr_retxml    IN OUT NOCOPY XMLType ,--> Arquivo de retorno do XML
                                       pr_nmdcampo  OUT VARCHAR2 ,--> Nome do campo com erro
                                       pr_des_erro  OUT VARCHAR2);

  PROCEDURE pc_consulta_param_modelo(pr_xmllog    IN VARCHAR2, --> XML com informações de LOG
                                     pr_cdcritic  OUT PLS_INTEGER, --> Código da crítica
                                     pr_dscritic  OUT VARCHAR2, --> Descrição da crítica
                                     pr_retxml    IN OUT NOCOPY XMLType ,--> Arquivo de retorno do XML
                                     pr_nmdcampo  OUT VARCHAR2 ,--> Nome do campo com erro
                                     pr_des_erro  OUT VARCHAR2);
                                     
  PROCEDURE pc_altera_param_modelo(pr_modelo_ibratan    IN INTEGER,
                                   pr_cooperat          IN INTEGER,
                                   pr_xmllog            IN VARCHAR2, --> xml com informações de log
                                   pr_cdcritic          OUT PLS_INTEGER, --> código da crítica
                                   pr_dscritic          OUT VARCHAR2, --> descrição da crítica
                                   pr_retxml            IN OUT NOCOPY XMLTYPE, --> ARQUivo de retorno do xml
                                   pr_nmdcampo          OUT VARCHAR2, --> Nome do campo com erro
                                   pr_des_erro          OUT VARCHAR2);

  PROCEDURE pc_log_parrat(pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_cdoperad IN crapope.cdoperad%TYPE,
                          pr_dscdolog IN VARCHAR2);

end TELA_PARRAT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARRAT IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_PARRAT
  --  Sistema  : Rotinas utilizadas pela Tela PARRAT
  --  Sigla    : PARRAT
  --  Autor    : DANIELE ROCHA/AMcom
  --  Data     : Janeiro/2019                 Ultima atualizacao: 05/06/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela PARRAT
  --
  -- Alteracoes: 14/05/2019 - Ajustes P450 - Ignorar Tipo de Pessoa -
  --                          Luiz Otávio Olinger Momm (AMCOM)
  --
  --             05/06/2019 - P450 - Adicionada o atributo inbiro_ibratan (Heckmann - AMcom)
  --
  --             11/06/2019 - P450 - Adicionado consulta e altração do atributo
  --                                 inbiro_ibratan (Luiz Otávio Oligenger Momm - AMcom)
  --
  --             13/08/2019 - P450 - Adicionada a função para a pesquisa de reaproveitamento
  --                                 da IBRANTA fn_buscar_reaproveitamento
  --                                 inbiro_ibratan (Luiz Otávio Oligenger Momm - AMcom)
  --
  --             14/08/2019 - P450 - Adicionada a procedure para consultar e alterar
  --                                 parametro do modelo de calculo para Ibranta
  --                                 (Luiz Otávio Oligenger Momm - AMcom)
  ---------------------------------------------------------------------------

  PROCEDURE pc_consultar(pr_inpessoa  IN INTEGER,
                         pr_tpproduto IN INTEGER,
                         pr_cooperat  IN INTEGER,
                         pr_xmllog    IN VARCHAR2, --> XML com informações de LOG
                         pr_cdcritic  OUT PLS_INTEGER, --> Código da crítica
                         pr_dscritic  OUT VARCHAR2, --> Descrição da crítica
                         pr_retxml    IN OUT NOCOPY XMLType ,--> Arquivo de retorno do XML
                         pr_nmdcampo  OUT VARCHAR2 ,--> Nome do campo com erro
                         pr_des_erro  OUT VARCHAR2) IS
    --> Erros do processo
    /* .............................................................................

        Programa: pc_consultar
        Sistema : CECRED
        Sigla   : PARRAT
        Autor   : Daniele Rocha/AMcom
        Data    : Janeiro/2019                 Ultima atualizacao: --

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  :

        Observacao: -----

        Alteracoes:

    ..............................................................................*/
    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

    vr_qtdias_niveis_reducao       tbrat_param_geral.qtdias_niveis_reducao%type; -->      quantidade de niveis de rating para melhora/reducao do risco
    vr_idnivel_risco_permite_reduc tbrat_param_geral.idnivel_risco_permite_reducao%type; -->    indicador dos niveis de risco de rating para melhora/reducao - exemplo: b, c, d
    vr_qtdias_atencede_atualizacao tbrat_param_geral.qtdias_atencede_atualizacao%type; -->      prazo de antecedencia para atualizar rating
    vr_qtdias_reaproveitamento     tbrat_param_geral.qtdias_reaproveitamento%type; -->      quantidade de dias para reaproveitamento da nota de rating
    vr_qtmeses_expiracao_nota      tbrat_param_geral.qtmeses_expiracao_nota%type; -->        quantidade de meses para expiracao da nota de rating
    vr_qtdias_atual_autom_baixo    tbrat_param_geral.qtdias_atualizacao_autom_baixo%type; -->        quantidade de dias para atualizacao automatica rating conforme risco baixo em cc
    vr_qtdias_atual_autom_medio    tbrat_param_geral.qtdias_atualizacao_autom_medio%type; -->      quantidade de dias para automatica rating conforme risco medio em cc
    vr_qtdias_atual_autom_alto     tbrat_param_geral.qtdias_atualizacao_autom_alto%type; -->        quantidade de dias para automatica rating conforme risco alto em cc
    vr_qtdias_atual_manual         tbrat_param_geral.qtdias_atualizacao_manual%type; -->    quantidade de dias para atualizacao manual
    vr_inpermite_alterar           INTEGER;
    vr_inbiro_ibratan              tbrat_param_geral.inbiro_ibratan%TYPE; --> Indicador de qual Biro sera utilizado na Ibratan (Dominio: tbgen_dominio_campo)
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_incontingencia INTEGER;
    vr_cooperativa INTEGER;
    -- paramentro a mais retornado xml para servir como parametro da consulta

    ---------->> CURSORES <<--------
    CURSOR cr_tbrat_param_geral IS
      SELECT c.inpessoa,
             c.tpproduto,
             c.qtdias_niveis_reducao,
             c.idnivel_risco_permite_reducao,
             c.qtdias_atencede_atualizacao,
             0 AS qtdias_reaproveitamento,
             c.qtmeses_expiracao_nota,
             c.qtdias_atualizacao_autom_baixo,
             c.qtdias_atualizacao_autom_medio,
             c.qtdias_atualizacao_autom_alto,
             c.qtdias_atualizacao_manual,
             c.cdcooper,
             c.incontingencia,
             c.inpermite_alterar,
             c.inbiro_ibratan
        FROM cecred.tbrat_param_geral C
       WHERE cdcooper  = pr_cooperat
         and inpessoa  = pr_inpessoa
         and tpproduto = pr_tpproduto;

    rw_tbrat_param_geral cr_tbrat_param_geral%ROWTYPE;

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

    -- Buscar parâmetros
    OPEN cr_tbrat_param_geral;

    FETCH cr_tbrat_param_geral
     INTO rw_tbrat_param_geral;

    --Se nao encontrou parametro
    IF cr_tbrat_param_geral%NOTFOUND THEN
      CLOSE cr_tbrat_param_geral;
      vr_cdcritic := 1230;
      RAISE vr_exc_saida;

    ELSE
      --Se encontrou, passa os valores para as variáveis criadas
      CLOSE cr_tbrat_param_geral;
      vr_qtdias_niveis_reducao       := rw_tbrat_param_geral.qtdias_niveis_reducao;
      vr_idnivel_risco_permite_reduc := rw_tbrat_param_geral.idnivel_risco_permite_reducao;
      vr_qtdias_atencede_atualizacao := rw_tbrat_param_geral.qtdias_atencede_atualizacao;
      vr_qtdias_reaproveitamento     := 0;
      vr_qtmeses_expiracao_nota      := rw_tbrat_param_geral.qtmeses_expiracao_nota;
      vr_qtdias_atual_autom_baixo    := rw_tbrat_param_geral.qtdias_atualizacao_autom_baixo;
      vr_qtdias_atual_autom_medio    := rw_tbrat_param_geral.qtdias_atualizacao_autom_medio;
      vr_qtdias_atual_autom_alto     := rw_tbrat_param_geral.qtdias_atualizacao_autom_alto;
      vr_qtdias_atual_manual         := rw_tbrat_param_geral.qtdias_atualizacao_manual;
      vr_cooperativa                 := rw_tbrat_param_geral.cdcooper;
      vr_incontingencia              := rw_tbrat_param_geral.incontingencia;
      vr_inpermite_alterar           := rw_tbrat_param_geral.inpermite_alterar;
      vr_inbiro_ibratan              := rw_tbrat_param_geral.inbiro_ibratan;

    END IF;

    -- PASSA OS DADOS PARA O XML RETORNO
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -- campos
    -- 1    vr_qtdias_niveis_reducao
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_qtdias_niveis_reducao',
                           pr_tag_cont => to_char(vr_qtdias_niveis_reducao),
                           pr_des_erro => vr_dscritic);
    -- 2  vr_idnivel_risco_permite_reducao
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_idnivel_risco_permite_reduc',
                           pr_tag_cont => to_char(vr_idnivel_risco_permite_reduc),
                           pr_des_erro => vr_dscritic);
    --3   vr_qtdias_atencede_atualizacao
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_qtdias_atencede_atualizacao',
                           pr_tag_cont => to_char(vr_qtdias_atencede_atualizacao),
                           pr_des_erro => vr_dscritic);

    --4   vr_qtdias_reaproveitamento
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_qtdias_reaproveitamento',
                           pr_tag_cont => to_char(0),
                           pr_des_erro => vr_dscritic);
    -- 5  vr_qtmeses_expiracao_nota
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_qtmeses_expiracao_nota',
                           pr_tag_cont => to_char(vr_qtmeses_expiracao_nota),
                           pr_des_erro => vr_dscritic);

    --6 vr_qtdias_atual_autom_baixo
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_qtdias_atual_autom_baixo',
                           pr_tag_cont => to_char(vr_qtdias_atual_autom_baixo),
                           pr_des_erro => vr_dscritic);

    --7 vr_qtdias_atual_autom_medio
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_qtdias_atual_autom_medio',
                           pr_tag_cont => to_char(vr_qtdias_atual_autom_medio),
                           pr_des_erro => vr_dscritic);
    --  8 vr_qtdias_atual_autom_alto
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_qtdias_atual_autom_alto',
                           pr_tag_cont => to_char(vr_qtdias_atual_autom_alto),
                           pr_des_erro => vr_dscritic);
    -- 9    pr_qtdias_atual_manual
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_qtdias_atual_manual',
                           pr_tag_cont => to_char(vr_qtdias_atual_manual),
                           pr_des_erro => vr_dscritic);

    -- 10    cooperativa
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_cooperat',
                           pr_tag_cont => to_char(vr_cooperativa),
                           pr_des_erro => vr_dscritic);

    -- 11    contingencia
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_incontingencia',
                           pr_tag_cont => to_char(vr_incontingencia),
                           pr_des_erro => vr_dscritic);

    -- 12    parametro de permitir ou nao realizar a alteração do rating
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_inpermite_alterar',
                           pr_tag_cont => to_char(vr_inpermite_alterar),
                           pr_des_erro => vr_dscritic);

    -- 13    Indicador de qual Biro sera utilizado na Ibratan (Dominio: tbgen_dominio_campo)
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'vr_inbiro_ibratan',
                           pr_tag_cont => to_char(vr_inbiro_ibratan),
                           pr_des_erro => vr_dscritic);


  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;

  END pc_consultar;

  PROCEDURE pc_alterar(pr_inpessoa                    IN INTEGER,
                       pr_tpproduto                   IN INTEGER,
                       pr_qtdias_niveis_reducao       IN tbrat_param_geral.qtdias_niveis_reducao%type, -->      quantidade de niveis de rating para melhora/reducao do risco
                       pr_idnivel_risco_permite_reduc IN tbrat_param_geral.idnivel_risco_permite_reducao%type ,-->    indicador dos niveis de risco de rating para melhora/reducao - exemplo: b, c, d
                       pr_qtdias_atencede_atualizacao IN tbrat_param_geral.qtdias_atencede_atualizacao%type ,-->      prazo de antecedencia para atualizar rating
                       pr_qtdias_reaproveitamento     IN tbrat_param_geral.qtdias_reaproveitamento%type ,-->      quantidade de dias para reaproveitamento da nota de rating
                       pr_qtmeses_expiracao_nota      IN tbrat_param_geral.qtmeses_expiracao_nota%type, -->        quantidade de meses para expiracao da nota de rating
                       pr_qtdias_atual_autom_baixo    IN tbrat_param_geral.qtdias_atualizacao_autom_baixo%type, -->        quantidade de dias para atualizacao automatica rating conforme risco baixo em cc
                       pr_qtdias_atual_autom_medio    IN tbrat_param_geral.qtdias_atualizacao_autom_medio%type, -->      quantidade de dias para automatica rating conforme risco medio em cc
                       pr_qtdias_atual_autom_alto     IN tbrat_param_geral.qtdias_atualizacao_autom_alto%type, -->        quantidade de dias para automatica rating conforme risco alto em cc
                       pr_qtdias_atual_manual         IN tbrat_param_geral.qtdias_atualizacao_manual%type, -->    quantidade de dias para atualizacao manual
                       pr_incontingencia              IN INTEGER,
                       pr_cooperat                    IN INTEGER,
                       pr_xmllog                      IN VARCHAR2, --> xml com informações de log
                       pr_cdcritic                    OUT PLS_INTEGER, --> código da crítica
                       pr_dscritic                    OUT VARCHAR2, --> descrição da crítica
                       pr_retxml                      IN OUT NOCOPY XMLTYPE, --> ARQuivo de retorno do xml
                       pr_nmdcampo                    OUT VARCHAR2 ,--> nome do campo com erro
                       pr_des_erro                    OUT VARCHAR2) IS
    --> erros do processo
    /* .............................................................................

        Programa: PC_ALTERAR
        Sistema : CECRED
        Sigla   : PARRAT
        Autor   : Daniele Rocha/AMcom
        Data    : Janeiro/2019                 Ultima atualizacao: --

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para alterar parâmetros do Risco

        Observacao: -----

        Alteracoes:

        10/05/2019 - P450 - Alterar forma de atualização da contingência, será sempre por cooperativa e tipo de produto,
                     independente do tipo de pessoa (Heckmann - AMcom).

                     P450 - Retirado a validação da data de reaproveitamento pois foi migrado para
                     a rotina CONAUT - Consultas Automatizadas

    ..............................................................................*/

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_dstextab craptab.dstextab%TYPE;
    vr_dsvlrprm crapprm.dsvlrprm%TYPE;

    vr_msg varchar2(4000);
    ---------->> CURSORES <<--------
    CURSOR cr_tbrat_param_geral(vr_cooperat  IN tbrisco_central_parametros.CDCOOPER%TYPE,
                                vr_inpessoa  in tbrat_param_geral.inpessoa%type,
                                vr_tpproduto in tbrat_param_geral.tpproduto%type) IS
      SELECT c.inpessoa,
             c.tpproduto,
             c.qtdias_niveis_reducao,
             c.idnivel_risco_permite_reducao,
             c.qtdias_atencede_atualizacao,
             0 AS qtdias_reaproveitamento,
             c.qtmeses_expiracao_nota,
             c.qtdias_atualizacao_autom_baixo,
             c.qtdias_atualizacao_autom_medio,
             c.qtdias_atualizacao_autom_alto,
             c.qtdias_atualizacao_manual,
             c.cdcooper,
             c.incontingencia,
             c.inbiro_ibratan
        FROM cecred.tbrat_param_geral C
       WHERE cdcooper = vr_cooperat
         and inpessoa = vr_inpessoa
         and tpproduto = vr_tpproduto;

    rw_tbrat_param_geral cr_tbrat_param_geral%ROWTYPE;

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

    -- pode vir , ou vazio da tela PHp
    IF (NVL(pr_idnivel_risco_permite_reduc, ',') = ',') THEN
      vr_dscritic := 'Informe mínimo uma flag "Permite melhorar os Níveis de Risco" !';
      RAISE vr_exc_saida;
    END IF;

    IF (NVL(pr_qtdias_niveis_reducao, 0) <= 0) THEN
      vr_dscritic := 'Quantidade de níveis de Rating para Melhora/redução: ' ||
                     pr_qtdias_niveis_reducao ||
                     ' deve ser maior que zero!';
      RAISE vr_exc_saida;
    END IF;

    IF (NVL(pr_qtdias_atencede_atualizacao, 0) <= 0) THEN
      vr_dscritic := 'Prazo de antecedência para atualizar Rating: ' ||
                     pr_qtdias_atencede_atualizacao ||
                     '(dias) deve ser maior que zero!';
      RAISE vr_exc_saida;
    END IF;

    IF (NVL(pr_qtmeses_expiracao_nota, 0) <= 0) THEN
      vr_dscritic := 'Prazo de Expiração do Rating:  ' ||
                     pr_qtmeses_expiracao_nota ||
                     ' (meses) deve ser maior que zero!';
      RAISE vr_exc_saida;
    END IF;

    IF (NVL(pr_qtmeses_expiracao_nota, 0) <= 0) THEN
      vr_dscritic := 'Prazo atualização automática Rating conforme Risco CC:  ' ||
                     pr_qtmeses_expiracao_nota ||
                     ' (meses) deve ser maior que zero!';
      RAISE vr_exc_saida;
    END IF;

    IF (NVL(pr_qtdias_atual_autom_baixo, 0) <= 0) THEN
      vr_dscritic := 'Prazo atualização automática Rating conforme baixo Risco CC:  ' ||
                     pr_qtdias_atual_autom_baixo ||
                     ' (meses) deve ser maior que zero!';
      RAISE vr_exc_saida;
    END IF;

    IF (NVL(pr_qtdias_atual_autom_medio, 0) <= 0) THEN
      vr_dscritic := 'Prazo atualização automática Rating conforme médio Risco CC:  ' ||
                     pr_qtdias_atual_autom_medio ||
                     ' (meses) deve ser maior que zero!';
      RAISE vr_exc_saida;
    END IF;

    IF (NVL(pr_qtdias_atual_autom_alto, 0) <= 0) THEN
      vr_dscritic := 'Prazo atualização automática Rating conforme alto Risco CC:  ' ||
                     pr_qtdias_atual_autom_alto ||
                     ' (meses) deve ser maior que zero!';
      RAISE vr_exc_saida;
    END IF;

    IF (NVL(pr_qtdias_atual_manual, 0) <= 0) THEN
      vr_dscritic := 'Prazo de atualização manual:  ' ||
                     pr_qtdias_atual_manual ||
                     ' (dias) deve ser maior que zero!';
      RAISE vr_exc_saida;
    END IF;

    -- Buscar parametros de risco   para cooperativa
    OPEN cr_tbrat_param_geral(vr_cooperat  => pr_cooperat,
                              vr_inpessoa  => pr_inpessoa,
                              vr_tpproduto => pr_tpproduto);

    FETCH cr_tbrat_param_geral
      INTO rw_tbrat_param_geral;

    --Se encontrou registro da cooperativa
    IF cr_tbrat_param_geral%FOUND THEN
      CLOSE cr_tbrat_param_geral;

      --encontrou registro, faz update se for diferente

      IF (pr_qtdias_niveis_reducao        <>         rw_tbrat_param_geral.qtdias_niveis_reducao) OR
         (pr_idnivel_risco_permite_reduc  <>         rw_tbrat_param_geral.idnivel_risco_permite_reducao) OR
         (pr_qtdias_atencede_atualizacao  <>         rw_tbrat_param_geral.qtdias_atencede_atualizacao) OR
         (pr_qtmeses_expiracao_nota       <>         rw_tbrat_param_geral.qtmeses_expiracao_nota) OR
         (pr_qtdias_atual_autom_baixo     <>         rw_tbrat_param_geral.qtdias_atualizacao_autom_baixo) OR
         (pr_qtdias_atual_autom_medio     <>         rw_tbrat_param_geral.qtdias_atualizacao_autom_medio) OR
         (pr_qtdias_atual_autom_alto      <>         rw_tbrat_param_geral.qtdias_atualizacao_autom_alto) OR
         (pr_qtdias_atual_manual          <>         rw_tbrat_param_geral.qtdias_atualizacao_manual) THEN

        BEGIN
          UPDATE cecred.tbrat_param_geral
             SET qtdias_niveis_reducao          = pr_qtdias_niveis_reducao,
                 idnivel_risco_permite_reducao  = pr_idnivel_risco_permite_reduc,
                 qtdias_atencede_atualizacao    = pr_qtdias_atencede_atualizacao,
                 qtdias_reaproveitamento        = 0,
                 qtmeses_expiracao_nota         = pr_qtmeses_expiracao_nota,
                 qtdias_atualizacao_autom_baixo = pr_qtdias_atual_autom_baixo,
                 qtdias_atualizacao_autom_medio = pr_qtdias_atual_autom_medio,
                 qtdias_atualizacao_autom_alto  = pr_qtdias_atual_autom_alto,
                 qtdias_atualizacao_manual      = pr_qtdias_atual_manual
           WHERE cdcooper  = pr_cooperat
--             AND inpessoa  = pr_inpessoa
             AND tpproduto = pr_tpproduto;

        EXCEPTION
          WHEN OTHERS THEN
            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar Parametros!';
            -- volta para o programa chamador
            RAISE vr_exc_saida;

        END;

        -- Ajusta a msg do log para somente os campos ajustados
        vr_msg := 'Alterou os parametros do parâmetros do Rating de: ';
        if (pr_qtdias_niveis_reducao                   <>           rw_tbrat_param_geral.qtdias_niveis_reducao) then
          vr_msg := vr_msg || ' qtdias_niveis_reducao de ' ||
                    rw_tbrat_param_geral.qtdias_niveis_reducao || ' para ' ||
                    pr_qtdias_niveis_reducao;
        end if;
        if (pr_idnivel_risco_permite_reduc              <>           rw_tbrat_param_geral.idnivel_risco_permite_reducao) then
          vr_msg := vr_msg || ' idnivel_risco_permite_reducao de ' ||
                    rw_tbrat_param_geral.idnivel_risco_permite_reducao ||
                    ' para ' || pr_idnivel_risco_permite_reduc;
        end if;
        if (pr_qtdias_atencede_atualizacao               <>           rw_tbrat_param_geral.qtdias_atencede_atualizacao) then
          vr_msg := vr_msg || ' qtdias_atencede_atualizacao de ' ||
                    rw_tbrat_param_geral.qtdias_atencede_atualizacao ||
                    ' para ' || pr_qtdias_atencede_atualizacao;
        end if;
        if (pr_qtmeses_expiracao_nota                     <>           rw_tbrat_param_geral.qtmeses_expiracao_nota) then
          vr_msg := vr_msg || ' qtmeses_expiracao_nota de ' ||
                    rw_tbrat_param_geral.qtmeses_expiracao_nota || ' para ' ||
                    pr_qtmeses_expiracao_nota;
        end if;
        if (pr_qtdias_atual_autom_baixo                   <>           rw_tbrat_param_geral.qtdias_atualizacao_autom_baixo) then
          vr_msg := vr_msg || ' qtdias_atualizacao_autom_baixo de ' ||
                    rw_tbrat_param_geral.qtdias_atualizacao_autom_baixo ||
                    ' para ' || pr_qtdias_atual_autom_baixo;
        end if;
        if (pr_qtdias_atual_autom_medio                   <>           rw_tbrat_param_geral.qtdias_atualizacao_autom_medio) then
          vr_msg := vr_msg || ' qtdias_atualizacao_autom_medio de ' ||
                    rw_tbrat_param_geral.qtdias_atualizacao_autom_medio ||
                    ' para ' || pr_qtdias_atual_autom_medio;
        end if;
        if (pr_qtdias_atual_autom_alto                    <>           rw_tbrat_param_geral.qtdias_atualizacao_autom_alto) then
          vr_msg := vr_msg || ' qtdias_atualizacao_autom_alto de ' ||
                    rw_tbrat_param_geral.qtdias_atualizacao_autom_alto ||
                    ' para ' || pr_qtdias_atual_autom_alto;
        end if;
        if (pr_qtdias_atual_manual                         <>           rw_tbrat_param_geral.qtdias_atualizacao_manual) then
          vr_msg := vr_msg || ' qtdias_atualizacao_manual de ' ||
                    rw_tbrat_param_geral.qtdias_atualizacao_manual ||
                    ' para ' || pr_qtdias_atual_manual;
        end if;

        TELA_PARRAT.pc_log_parrat(pr_cdcooper => pr_cooperat,
                                  pr_cdoperad => vr_cdoperad,
                                  pr_dscdolog => vr_msg);
      END IF;

      IF (pr_incontingencia <> rw_tbrat_param_geral.incontingencia) THEN
        BEGIN
          -- Devera fazer update deste campo por cooperativa e produto, independente do tipo de pessoa
          UPDATE cecred.tbrat_param_geral
             SET incontingencia                 = pr_incontingencia
           WHERE cdcooper  = pr_cooperat
             AND tpproduto = pr_tpproduto;

        EXCEPTION
          WHEN OTHERS THEN
            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar Parametros!';
            -- volta para o programa chamador
            RAISE vr_exc_saida;
        END;

               vr_msg := vr_msg || ' Habilita  Contingência '||
                CASE
                 WHEN rw_tbrat_param_geral.Incontingencia =1 THEN
                  'Sim'
                 ELSE
                  'Não'
            END ||
          CASE
                 WHEN pr_incontingencia =1 THEN
                 'Sim'
                 ELSE
                  'Não'
                END;

        TELA_PARRAT.pc_log_parrat(pr_cdcooper => pr_cooperat,
                                  pr_cdoperad => vr_cdoperad,
                                  pr_dscdolog => vr_msg);

      END IF;
    ELSE
      CLOSE cr_tbrat_param_geral;
    END IF;
   COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;

  END pc_alterar;

  PROCEDURE pc_consulta_param_alter_rating (pr_cooperat  IN INTEGER,
                                            pr_xmllog    IN VARCHAR2, --> XML com informações de LOG
                                            pr_cdcritic  OUT PLS_INTEGER, --> Código da crítica
                                            pr_dscritic  OUT VARCHAR2, --> Descrição da crítica
                                            pr_retxml    IN OUT NOCOPY XMLType ,--> Arquivo de retorno do XML
                                            pr_nmdcampo  OUT VARCHAR2 ,--> Nome do campo com erro
                                            pr_des_erro  OUT VARCHAR2) IS

   /* .............................................................................

        Programa: PC_CONSULTA_PARAM_ALTER_RATING
        Sistema : CECRED
        Sigla   : PARRAT
        Autor   : Daniele Rocha/AMcom
        Data    : Março/2019                 Ultima atualizacao: --

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  :Consultar o parametro que indica se possibilita sugestão

        Observacao:

        Alteracoes:

    ..............................................................................*/
    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

    vr_inpermite_alterar INTEGER;
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper       INTEGER;
    vr_cdoperad       VARCHAR2(100);
    vr_nmdatela       VARCHAR2(100);
    vr_nmeacao        VARCHAR2(100);
    vr_cdagenci       VARCHAR2(100);
    vr_nrdcaixa       VARCHAR2(100);
    vr_idorigem       VARCHAR2(100);
    vr_incontingencia INTEGER;
    vr_cooperativa    INTEGER;
    -- paramentro a mais retornado xml para servir como parametro da consulta

    ---------->> CURSORES <<--------
    CURSOR cr_tbrat_param_geral IS
      -- campo inpermite_alterar ainda não criado
      SELECT     inpermite_alterar,
                 cdcooper
        FROM cecred.tbrat_param_geral C
       WHERE cdcooper  = pr_cooperat;

    rw_tbrat_param_geral cr_tbrat_param_geral%ROWTYPE;

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

    -- Buscar parâmetros
    OPEN cr_tbrat_param_geral;

    FETCH cr_tbrat_param_geral
     INTO rw_tbrat_param_geral;

    --Se nao encontrou parametro
    IF cr_tbrat_param_geral%NOTFOUND THEN
      CLOSE cr_tbrat_param_geral;
      vr_cdcritic := 1230;
      RAISE vr_exc_saida;

    ELSE
      --Se encontrou, passa os valores para as variáveis criadas
      CLOSE cr_tbrat_param_geral;
      vr_inpermite_alterar      := rw_tbrat_param_geral.inpermite_alterar;
      vr_cooperativa            := rw_tbrat_param_geral.cdcooper;
    END IF;

    -- PASSA OS DADOS PARA O XML RETORNO
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -- campos
    -- 1   cooperativa escolhida
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_cooperat',
                           pr_tag_cont => to_char(vr_cooperativa),
                           pr_des_erro => vr_dscritic);

    -- 2 permite ou não sugerir/alterar rating
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_inpermite_alterar',
                           pr_tag_cont => to_char(vr_inpermite_alterar),
                           pr_des_erro => vr_dscritic);


  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
  END pc_consulta_param_alter_rating;

  PROCEDURE pc_altera_param_alter_rating(pr_inpermite_alterar IN INTEGER,
                                         pr_cooperat          IN INTEGER,
                                         pr_xmllog            IN VARCHAR2, --> xml com informações de log
                                         pr_cdcritic          OUT PLS_INTEGER, --> código da crítica
                                         pr_dscritic          OUT VARCHAR2, --> descrição da crítica
                                         pr_retxml            IN OUT NOCOPY XMLTYPE, --> ARQUivo de retorno do xml
                                         pr_nmdcampo          OUT VARCHAR2, --> Nome do campo com erro
                                         pr_des_erro          OUT VARCHAR2) is

  /* .............................................................................

      Programa: PC_ALTERA_PARAM_ALTER_RATING
      Sistema : CECRED
      Sigla   : PARRAT
      Autor   : Daniele Rocha/AMcom
      Data    : março/2019                 Ultima atualizacao: --

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Alterar o parametro que indica se possibilita sugestão rating

      Observacao:

      Alteracoes:

  ..............................................................................*/

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_inpermite_alterar INTEGER;

    vr_dstextab craptab.dstextab%TYPE;
    vr_dsvlrprm crapprm.dsvlrprm%TYPE;

    vr_msg varchar2(4000);
    ---------->> CURSORES <<--------
    CURSOR cr_tbrat_param_geral IS
      SELECT inpermite_alterar
        FROM cecred.tbrat_param_geral C
       WHERE cdcooper = pr_cooperat;

    rw_tbrat_param_geral cr_tbrat_param_geral%ROWTYPE;

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

    IF (pr_inpermite_alterar IS NULL) THEN
      vr_dscritic := 'Obrigatório informar Se bloqueia ou não Alteração Rating!';
      RAISE vr_exc_saida;
    END IF;
    IF (pr_inpermite_alterar NOT IN (1, 2, 0)) THEN
      vr_dscritic := 'Informar corretamente se bloqueia ou não Alteração Rating!';
      RAISE vr_exc_saida;
    END IF;
    -- Buscar parametros de risco para cooperativa
    OPEN cr_tbrat_param_geral;

    FETCH cr_tbrat_param_geral
      INTO vr_inpermite_alterar;
    CLOSE cr_tbrat_param_geral;

    IF vr_inpermite_alterar IS NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Não localizado Parametro rating para cooperativa: ' ||
                     pr_cooperat;
      RAISE vr_exc_saida;
    END IF;
    --encontrou registro, faz update se for diferente

    IF (pr_inpermite_alterar <> vr_inpermite_alterar) THEN

      BEGIN
        UPDATE tbrat_param_geral
           SET inpermite_alterar =   pr_inpermite_alterar
         WHERE cdcooper =  pr_cooperat;

      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar Parametros!';
          -- volta para o programa chamador
          RAISE vr_exc_saida;

      END;

      TELA_PARRAT.pc_log_parrat(pr_cdcooper => pr_cooperat,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'Alterado o parâmetro Permissão Alterar o rating de ' ||
                                CASE
                                   WHEN vr_inpermite_alterar = 1 THEN
                                    'Permite Sugerir Alteração Rating.'
                                   WHEN vr_inpermite_alterar = 0 THEN
                                    'Bloqueia a Alteração do Rating.'
                                 END || '  para ' ||
                                 CASE
                                   WHEN rw_tbrat_param_geral.inpermite_alterar = 1 THEN
                                    'Permite Sugerir Alteração Rating.'
                                   WHEN rw_tbrat_param_geral.inpermite_alterar = 0 THEN
                                    'Bloqueia a Alteração do Rating.'
                                 END);

    END IF;
    COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
    ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
  END pc_altera_param_alter_rating;

  PROCEDURE pc_consulta_param_biro(pr_xmllog    IN VARCHAR2, --> XML com informações de LOG
                                   pr_cdcritic  OUT PLS_INTEGER, --> Código da crítica
                                   pr_dscritic  OUT VARCHAR2, --> Descrição da crítica
                                   pr_retxml    IN OUT NOCOPY XMLType ,--> Arquivo de retorno do XML
                                   pr_nmdcampo  OUT VARCHAR2 ,--> Nome do campo com erro
                                   pr_des_erro  OUT VARCHAR2) IS
  /* .............................................................................
  Programa: PC_CONSULTA_PARAM_BIRO
  Sistema : CECRED
  Sigla   : PARRAT
  Autor   : Luiz Otavio Olinger Momm/AMcom
  Data    : Junho/2019                 Ultima atualizacao: --

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo  :Consultar os parametros de birô de todas as cooperativas

  Observacao:

  Alteracoes:
  ..............................................................................*/
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

  -- Variaveis retornadas da gene0004.pc_extrai_dados
  vr_cdcooper       INTEGER;
  vr_cdoperad       VARCHAR2(100);
  vr_nmdatela       VARCHAR2(100);
  vr_nmeacao        VARCHAR2(100);
  vr_cdagenci       VARCHAR2(100);
  vr_nrdcaixa       VARCHAR2(100);
  vr_idorigem       VARCHAR2(100);
  -- paramentro a mais retornado xml para servir como parametro da consulta

  ---------->> CURSORES <<--------
  CURSOR cr_tbrat_param_biro IS
    SELECT DISTINCT crapcop.cdcooper AS cdcooper,
                    crapcop.nmrescop AS nmrescop,
                    tbrat_param_geral.inbiro_ibratan AS inbiro_ibratan
      FROM tbrat_param_geral
           ,crapcop
      WHERE tbrat_param_geral.cdcooper = crapcop.cdcooper
      ORDER BY crapcop.nmrescop;
  rw_biro cr_tbrat_param_biro%ROWTYPE;

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

    -- PASSA OS DADOS PARA O XML RETORNO
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'cooperativas',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    vr_auxconta := 0;
    FOR rw_biro IN cr_tbrat_param_biro LOOP

      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'cooperativas',
                             pr_posicao  => 0,
                             pr_tag_nova => 'cooperativa',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      -- 1   cooperativa escolhida
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'cooperativa',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'cdcooper',
                             pr_tag_cont => to_char(rw_biro.cdcooper),
                             pr_des_erro => vr_dscritic);

      -- 2 permite ou não sugerir/alterar rating
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'cooperativa',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nmrescop',
                             pr_tag_cont => rw_biro.nmrescop,
                             pr_des_erro => vr_dscritic);

      -- 3 permite ou não sugerir/alterar rating
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'cooperativa',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'inbiro',
                             pr_tag_cont => to_char(rw_biro.inbiro_ibratan),
                             pr_des_erro => vr_dscritic);

      vr_auxconta := vr_auxconta + 1;

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

        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
  END pc_consulta_param_biro;

  PROCEDURE pc_altera_param_biro(pr_inbiro_ibratan    IN INTEGER,
                  	             pr_cooperat          IN INTEGER,
                                 pr_xmllog            IN VARCHAR2, --> xml com informações de log
                                 pr_cdcritic          OUT PLS_INTEGER, --> código da crítica
                                 pr_dscritic          OUT VARCHAR2, --> descrição da crítica
                                 pr_retxml            IN OUT NOCOPY XMLTYPE, --> ARQUivo de retorno do xml
                                 pr_nmdcampo          OUT VARCHAR2, --> Nome do campo com erro
                                 pr_des_erro          OUT VARCHAR2) is
  /* .............................................................................

  Programa: PC_ALTERA_PARAM_BIRO
  Sistema : CECRED
  Sigla   : PARRAT
  Autor   : Luiz Otavio Olinger Momm/AMcom
  Data    : junho/2019                 Ultima atualizacao: --

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo  : Alterar o parametro que indica o birô do rating

  Observacao:

  Alteracoes:

  ..............................................................................*/

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  -- Variaveis retornadas da gene0004.pc_extrai_dados
  vr_cdcooper INTEGER;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);

  vr_inbiro_ibratan INTEGER;
  ---------->> CURSORES <<--------
  CURSOR cr_tbrat_param_geral IS
    SELECT inbiro_ibratan
      FROM cecred.tbrat_param_geral C
      WHERE cdcooper = pr_cooperat;

  rw_tbrat_param_geral cr_tbrat_param_geral%ROWTYPE;

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

    IF (pr_inbiro_ibratan IS NULL) THEN
       vr_dscritic := 'Obrigatório informar o Birô do Rating!';
       RAISE vr_exc_saida;
    END IF;

    -- Buscar parametros de risco para cooperativa
    OPEN cr_tbrat_param_geral;

    FETCH cr_tbrat_param_geral
      INTO vr_inbiro_ibratan;
    CLOSE cr_tbrat_param_geral;

    IF vr_inbiro_ibratan IS NULL THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Não localizado parâmetro rating para cooperativa: ' || pr_cooperat;
       RAISE vr_exc_saida;
    END IF;
    --encontrou registro, faz update se for diferente

    IF (pr_inbiro_ibratan <> vr_inbiro_ibratan) THEN
      BEGIN
        UPDATE tbrat_param_geral
          SET inbiro_ibratan = pr_inbiro_ibratan
          WHERE cdcooper = pr_cooperat;

        EXCEPTION
          WHEN OTHERS THEN
            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar Parâmetros!';
            -- volta para o programa chamador
          RAISE vr_exc_saida;
      END;

      TELA_PARRAT.pc_log_parrat(pr_cdcooper => pr_cooperat,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'Alterado o parâmetro Birô Rating de '
                                             || fn_busca_descricao_dominio('INBIRO_IBRATAN', vr_inbiro_ibratan)
                                             || '  para '
                                             || fn_busca_descricao_dominio('INBIRO_IBRATAN', rw_tbrat_param_geral.inbiro_ibratan));

    END IF;
    COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

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
  END pc_altera_param_biro;

  /* Rotina responsavel por buscar a descrição da situacao do contrato */
  FUNCTION fn_busca_descricao_dominio (pr_nmdominio IN VARCHAR2
                                      ,pr_cddominio IN INTEGER) RETURN VARCHAR2 IS
  BEGIN

   /* ..........................................................................

     Programa: fn_busca_descricao_dominio
     Sistema  : Rotinas utilizadas pela Tela PARRAT
     Sigla   : PARRAT
     Autor   : Luiz Otávio Olinger Momm (AMCOM)
     Data    : Junho/2019.                          Ultima Atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Buscar a descricao do Dominio

  ............................................................................. */
    DECLARE

      CURSOR cr_tbgen_dominio_campo(pr_cddominio IN tbgen_dominio_campo.cddominio%TYPE) IS
      SELECT tbgen_dominio_campo.dscodigo
        FROM tbgen_dominio_campo
       WHERE nmdominio = pr_nmdominio
         AND cddominio = pr_cddominio;
      rw_tbgen_dominio_campo cr_tbgen_dominio_campo%ROWTYPE;

    BEGIN
      OPEN cr_tbgen_dominio_campo(pr_cddominio => pr_cddominio);

      FETCH cr_tbgen_dominio_campo INTO rw_tbgen_dominio_campo;

      IF cr_tbgen_dominio_campo%NOTFOUND THEN

        --Fechar o cursor
        CLOSE cr_tbgen_dominio_campo;

        RETURN '***';
      ELSE
        --Fechar o cursor
        CLOSE cr_tbgen_dominio_campo;

        RETURN rw_tbgen_dominio_campo.dscodigo;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;

  END fn_busca_descricao_dominio;
  
  FUNCTION fn_buscar_reaproveitamento(pr_cdcooper IN craprbi.cdcooper%TYPE
                                     ,pr_inpessoa IN craprbi.inpessoa%TYPE DEFAULT 0
                                     ,pr_tpctrato IN NUMBER                DEFAULT 0)
    RETURN INTEGER IS
  BEGIN
  
    /* ..........................................................................
    
       Programa: fn_buscar_reaproveitamento
       Sistema  : Rotina para retornar reaproveitamento por cooperativa
       Sigla   : 
       Autor   : Luiz Otávio Olinger Momm (AMCOM)
       Data    : Agosto/2019.                          Ultima Atualizacao:
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que montar JSON para Ibratan na politica Rating
       Objetivo  : Retornar dias de aproveitamento para Ibratan configurados na PARRAT
    
    ............................................................................. */
    DECLARE
      /* Consulta na CONAUT para usar mesma rotina */
      CURSOR cr_nrdias IS
        SELECT NVL(MAX(NVL(qtdiarpv, 0)),0) AS qtdiarpv
          FROM craprbi
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa
           AND inprodut = DECODE(pr_tpctrato
                                     ,90, 1    -- 90 - Empréstimos/Financiamentos  = 1 - Emprestimos
                                     ,1,  3    -- 1 - Limite de Crédito            = 3 - Contrato limite cheque especial
                                     ,2,  4    -- 2 - Limite de Desconto de Cheque = 4 - Contrato limite desconto de cheque
                                     ,3,  5    -- 3 - Limite de Desconto de Título = 5 - Contrato Limite Desconto de Titulos
                                     );
      rw_nrdias cr_nrdias%ROWTYPE;
      vr_nrdias craprbi.qtdiarpv%TYPE;
    
    BEGIN
/*
  Cadastro de dias de reaproveitamento nas consultas do Biro.
  Caso o mesmo CPF/CNPJ for consultado dentro do limite de dias,
  sera utilizada a ultima consulta.
  CRAPRBI.CDCOOPER
  CRAPRBI.INPESSOA - Indicador de pessoa (1-Fisica, 2-Juridica)
  CRAPRBI.INPRODUT - Indicador de produto
          1-Emprestimos
          2-Financiamentos
          3-Contrato limite cheque especial
          4-Contrato limite desconto de cheque
          5-Contrato Limite Desconto de Titulos
  CRAPRBI.QTDIARPV - Dias
*/

      OPEN cr_nrdias;
      FETCH cr_nrdias
        INTO rw_nrdias;
      IF cr_nrdias%NOTFOUND THEN
        --Fechar o cursor
        CLOSE cr_nrdias;
        vr_nrdias := 7; -- padrão 7 dicas caso não existir
      ELSE
        --Fechar o cursor
        CLOSE cr_nrdias;
        vr_nrdias := rw_nrdias.qtdiarpv;
        IF vr_nrdias = 0 THEN
          vr_nrdias := 7; -- padrão 7 dicas caso não existir
        END IF;
      END IF;
      RETURN vr_nrdias;
    END;
  
  END fn_buscar_reaproveitamento;
  
  --> Consultar o valor do parametro na CRAPPRM
  PROCEDURE pc_consulta_param_crapprm (pr_cdcooper  IN INTEGER,
                                       pr_cdacesso  IN crapprm.cdacesso%TYPE, --> Código do acesso do parâmetro
                                       pr_xmllog    IN VARCHAR2, --> XML com informações de LOG
                                       pr_cdcritic  OUT PLS_INTEGER, --> Código da crítica
                                       pr_dscritic  OUT VARCHAR2, --> Descrição da crítica
                                       pr_retxml    IN OUT NOCOPY XMLType ,--> Arquivo de retorno do XML
                                       pr_nmdcampo  OUT VARCHAR2 ,--> Nome do campo com erro
                                       pr_des_erro  OUT VARCHAR2) IS

   /* .............................................................................

        Programa: PC_CONSULTA_PARAM_CRAPPRM
        Sistema : CECRED
        Sigla   : PARRAT
        Autor   : Anderson Luiz Heckmann/AMcom
        Data    : Julho/2019                 Ultima atualizacao: --

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo: Consultar o valor do parametro na CRAPPRM

        Observacao:

        Alteracoes:

    ..............................................................................*/
    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic       crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic       VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida      EXCEPTION;

    -- Contador auxiliar p/ posicao no XML
    vr_auxconta       INTEGER := 0; 

    -- Variavel para o retorno com o valor da descrição do parametro
    vr_dsvlrprm       crapprm.dsvlrprm%TYPE; 
     
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper       INTEGER;
    vr_cdoperad       VARCHAR2(100);
    vr_nmdatela       VARCHAR2(100);
    vr_nmeacao        VARCHAR2(100);
    vr_cdagenci       VARCHAR2(100);
    vr_nrdcaixa       VARCHAR2(100);
    vr_idorigem       VARCHAR2(100);

    ---------->> CURSORES <<--------
    CURSOR cr_crapprm IS
      SELECT prm.dsvlrprm
        FROM crapprm prm
       WHERE prm.cdcooper = pr_cdcooper
         AND prm.cdacesso = pr_cdacesso;

    rw_crapprm cr_crapprm%ROWTYPE;

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

    -- Buscar parâmetros
    OPEN cr_crapprm;
    FETCH cr_crapprm
    INTO rw_crapprm;

    --Se nao encontrou parametro
    IF cr_crapprm%NOTFOUND THEN
      CLOSE cr_crapprm;
      vr_cdcritic := 1230;
      RAISE vr_exc_saida;
    ELSE
      --Se encontrou, passa os valores para as variáveis criadas
      vr_dsvlrprm := rw_crapprm.dsvlrprm;
      CLOSE cr_crapprm;
    END IF;

    -- PASSA OS DADOS PARA O XML RETORNO
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -- campos
    -- 1 - cooperativa escolhida
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_cooperat',
                           pr_tag_cont => to_char(pr_cdcooper),
                           pr_des_erro => vr_dscritic);

    -- 2 - permite ou não habilitar rating
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'pr_dsvlrprm',
                           pr_tag_cont => vr_dsvlrprm,
                           pr_des_erro => vr_dscritic);


  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
 END pc_consulta_param_crapprm;
  
 
  PROCEDURE pc_consulta_param_modelo(pr_xmllog    IN VARCHAR2, --> XML com informações de LOG
                                     pr_cdcritic  OUT PLS_INTEGER, --> Código da crítica
                                     pr_dscritic  OUT VARCHAR2, --> Descrição da crítica
                                     pr_retxml    IN OUT NOCOPY XMLType ,--> Arquivo de retorno do XML
                                     pr_nmdcampo  OUT VARCHAR2 ,--> Nome do campo com erro
                                     pr_des_erro  OUT VARCHAR2) IS
  /* .............................................................................
  Programa: PC_CONSULTA_PARAM_MODELO
  Sistema : CECRED
  Sigla   : PARRAT
  Autor   : Luiz Otavio Olinger Momm/AMcom
  Data    : Agosto/2019                 Ultima atualizacao: --

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo  :Consultar os parametros do modelo de calculo Ibratan de todas as cooperativas

  Observacao:

  Alteracoes:
  ..............................................................................*/
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

  -- Variaveis retornadas da gene0004.pc_extrai_dados
  vr_cdcooper       INTEGER;
  vr_cdoperad       VARCHAR2(100);
  vr_nmdatela       VARCHAR2(100);
  vr_nmeacao        VARCHAR2(100);
  vr_cdagenci       VARCHAR2(100);
  vr_nrdcaixa       VARCHAR2(100);
  vr_idorigem       VARCHAR2(100);
  -- paramentro a mais retornado xml para servir como parametro da consulta

  ---------->> CURSORES <<--------
  CURSOR cr_tbrat_param_modelo IS
    SELECT DISTINCT crapcop.cdcooper AS cdcooper,
                    crapcop.nmrescop AS nmrescop,
                    tbrat_param_geral.tpmodelo_rating AS inmodelo
      FROM tbrat_param_geral
          ,crapcop
      WHERE tbrat_param_geral.cdcooper = crapcop.cdcooper
      ORDER BY crapcop.nmrescop;
  rw_modelo cr_tbrat_param_modelo%ROWTYPE;

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

    -- PASSA OS DADOS PARA O XML RETORNO
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'cooperativas',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    vr_auxconta := 0;
    FOR rw_modelo IN cr_tbrat_param_modelo LOOP

      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'cooperativas',
                             pr_posicao  => 0,
                             pr_tag_nova => 'cooperativa',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      -- 1   cooperativa escolhida
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'cooperativa',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'cdcooper',
                             pr_tag_cont => to_char(rw_modelo.cdcooper),
                             pr_des_erro => vr_dscritic);

      -- 2 permite ou não sugerir/alterar rating
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'cooperativa',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nmrescop',
                             pr_tag_cont => rw_modelo.nmrescop,
                             pr_des_erro => vr_dscritic);

      -- 3 permite ou não sugerir/alterar rating
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'cooperativa',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'inmodelo',
                             pr_tag_cont => to_char(rw_modelo.inmodelo),
                             pr_des_erro => vr_dscritic);

      vr_auxconta := vr_auxconta + 1;

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

        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
  END pc_consulta_param_modelo;

  PROCEDURE pc_altera_param_modelo(pr_modelo_ibratan    IN INTEGER,
                                   pr_cooperat          IN INTEGER,
                                   pr_xmllog            IN VARCHAR2, --> xml com informações de log
                                   pr_cdcritic          OUT PLS_INTEGER, --> código da crítica
                                   pr_dscritic          OUT VARCHAR2, --> descrição da crítica
                                   pr_retxml            IN OUT NOCOPY XMLTYPE, --> ARQUivo de retorno do xml
                                   pr_nmdcampo          OUT VARCHAR2, --> Nome do campo com erro
                                   pr_des_erro          OUT VARCHAR2) is
  /* .............................................................................

  Programa: PC_ALTERA_PARAM_MODELO
  Sistema : CECRED
  Sigla   : PARRAT
  Autor   : Luiz Otavio Olinger Momm/AMcom
  Data    : Agosto/2019                 Ultima atualizacao: --

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo  : Alterar o parametro que indica o modelo do calculo que e enviado para Ibratan

  Observacao:

  Alteracoes:

  ..............................................................................*/

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  -- Variaveis retornadas da gene0004.pc_extrai_dados
  vr_cdcooper INTEGER;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);

  vr_modelo_ibratan INTEGER;
  ---------->> CURSORES <<--------
  CURSOR cr_tbrat_param_geral IS
    SELECT MAX(tpmodelo_rating)
      FROM cecred.tbrat_param_geral
      WHERE cdcooper = pr_cooperat;

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

    IF (pr_modelo_ibratan IS NULL) THEN
       vr_dscritic := 'Obrigatório informar o Modelo de Cálculo do Rating!';
       RAISE vr_exc_saida;
    END IF;

    -- Buscar parametros de risco para cooperativa
    OPEN cr_tbrat_param_geral;

    FETCH cr_tbrat_param_geral
      INTO vr_modelo_ibratan;
    CLOSE cr_tbrat_param_geral;

    IF vr_modelo_ibratan IS NULL THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Não localizado parâmetro rating para cooperativa: ' || pr_cooperat;
       RAISE vr_exc_saida;
    END IF;
    --encontrou registro, faz update se for diferente

    IF (pr_modelo_ibratan <> vr_modelo_ibratan) THEN
      BEGIN
        UPDATE tbrat_param_geral
          SET tpmodelo_rating = pr_modelo_ibratan
          WHERE cdcooper = pr_cooperat;

        EXCEPTION
          WHEN OTHERS THEN
            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar Parâmetros!';
            -- volta para o programa chamador
          RAISE vr_exc_saida;
      END;

      pc_log_parrat(pr_cdcooper => pr_cooperat,
                                   pr_cdoperad => vr_cdoperad,
                                   pr_dscdolog => 'Alterado o parâmetro Modelo Rating de '
                                                || fn_busca_descricao_dominio('INMODELO_IBRATAN', vr_modelo_ibratan)
                                                || '  para '
                                                || fn_busca_descricao_dominio('INMODELO_IBRATAN', pr_modelo_ibratan));

    END IF;
    COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

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
  END pc_altera_param_modelo;
  
  ---------------------------------------------------------------------------
  /* Gerar Log da tela */
  PROCEDURE pc_log_parrat(pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_cdoperad IN crapope.cdoperad%TYPE,
                          pr_dscdolog IN VARCHAR2) IS

    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    vr_dscdolog VARCHAR2(500);
    vr_cdacesso VARCHAR2(100);
  BEGIN
    vr_dscdolog := to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ' ' ||
                   to_char(SYSDATE, 'HH24:MI:SS') || ' --> ' || vr_cdacesso ||
                   ' --> ' || 'Operador ' || pr_cdoperad || ' ' ||
                   pr_dscdolog;

    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 1,
                               pr_des_log      => vr_dscdolog,
                               pr_nmarqlog     => 'PARRAT',
                               pr_flfinmsg     => 'N');
  END pc_log_parrat;
  ---------------------------------------------------------------------------

END TELA_PARRAT;
/
