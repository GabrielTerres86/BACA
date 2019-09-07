CREATE OR REPLACE PACKAGE CECRED."LIMI0002" AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : LIMI0002
  --  Sistema  : Rotinas referentes ao limite de credito
  --  Sigla    : LIMI
  --  Autor    : James Prust Junior
  --  Data     : Dezembro - 2014.                   Ultima atualizacao: 23/05/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente ao limite de credito

  -- Alteracoes:
  --             29/06/2017 - Colocado Log no padrão
  --                          Setar modulo
  --                          (Belli - Envolti - Chamado 660306)
  --
  --             15/02/2018 - Adicionado o procedimento pc_apaga_estudo_limdesctit (Paulo Penteado GFT)
  --
  --             09/03/2018 - Adicionado o procedimento pc_renova_autom_limdesctit (Paulo Penteado GFT)
  --
  --             15/03/2018 - PC_CANCELA_LIMITE_INADIM  - Cancelar limites de crédito para contas com atraso conforme parâmetro da cooperativa - Daniel(AMcom)
  --
  --             23/05/2018 - PC_CANCELA_LIMITE_CREDITO - Rotina para cancelamento de Limite de Crédito - Daniel(AMcom)
  --             23/08/2018 - Alteraçao na pc_renova_limdesctit: Registrar a renovação na tabela de histórico de alteraçao
  --                          de contrato de limite (Andrew Albuquerque - GFT)
  --
  ---------------------------------------------------------------------------------------------------------------

  ------------------------------- TIPOS DE REGISTROS -----------------------
  type typ_reg_crapldc is record
      (flgstlcr crapldc.flgstlcr%type); -- Situacao da linha

  -- Tabela temporaria para os tipos de risco
  type typ_reg_craptab is record
      (dsdrisco craptab.dstextab%type);

  ------------------------------- TIPOS DE DADOS ---------------------------
  type typ_tab_crapldc  is table of typ_reg_crapldc index by pls_integer;
  type typ_tab_craptab  is table of typ_reg_craptab index by pls_integer;

  ----------------------------- VETORES DE MEMORIA -------------------------
  vr_tab_crapldc  typ_tab_crapldc;
  vr_tab_craptab  typ_tab_craptab;



  -- Rotina referente a consulta da tela de Limite de Saque do TAA
  PROCEDURE pc_tela_lim_saque_consultar(pr_nrdconta tbtaa_limite_saque.nrdconta%TYPE --> Numero da Conta
                                       ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  -- Rotina referente a alteracao da tela de Limite de Saque do TAA
  PROCEDURE pc_tela_lim_saque_alterar(pr_nrdconta                tbtaa_limite_saque.nrdconta%TYPE                --> Numero da Conta
                                     ,pr_dtmvtolt IN VARCHAR2                                                        --> Data de Movimentacao
                                     ,pr_vllimite_saque          tbtaa_limite_saque.vllimite_saque%TYPE          --> Valor do Limite do Saque
                                     ,pr_flgemissao_recibo_saque tbtaa_limite_saque.flgemissao_recibo_saque%TYPE --> Recibo Saque
                                     ,pr_xmllog   IN VARCHAR2                                                    --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER                                                --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                                                   --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType                                          --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                                                   --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);
                                                                               --> Erros do processo
  PROCEDURE pc_crps517(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_cancela_limite_inadim(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2);             --> Texto de erro/critica encontrada

  PROCEDURE pc_cancela_limite_credito(pr_cdcooper   IN crapcop.cdcooper%TYPE    --> Código da Cooperativa
                                     ,pr_cdagenci   IN crapass.cdagenci%TYPE    --> Código da agência
                                     ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE    --> Número do caixa
                                     ,pr_cdoperad   IN crapnrc.cdoperad%TYPE    --> Código do operador
                                     ,pr_nrdconta   IN crapass.nrdconta%TYPE    --> Conta do associado
                                     ,pr_nrctrlim   IN NUMBER                   --> Número do contrato de Rating
                                     ,pr_inadimp    IN NUMBER                   --> 1-Inadimplência 0-Normal
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2);             --> Texto de erro/critica encontrada

END LIMI0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED."LIMI0002" AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : LIMI0002
  --  Sistema  : Rotinas referentes ao limite de credito
  --  Sigla    : LIMI
  --  Autor    : James Prust Junior
  --  Data     : Dezembro - 2014.                   Ultima atualizacao: 23/05/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente ao limite de credito

  /* Alteracoes: 30/03/2016

                 30/03/2016 - Adicionar procedure pc_crps517.
                              Alterar chamada da procedure pc_carrega_dados_tar_vigente
                              para chamar dentro do loop da craplim e passar o valor do
                              limite ao inves de um valor fixo - M214 (Lucas Ranghetti #402276)

                 29/06/2017 - Colocado Log no padrão
                              Setar modulo
                              (Belli - Envolti - Chamado 660306)

                 20/09/2017 - Ajustado para não gravar nmarqlog, pois so gera a tbgen_prglog
                              (Ana - Envolti - Chamado 746134)

                 15/02/2018 - Adicionado o procedimento pc_apaga_estudo_limdesctit (Paulo Penteado GFT) que será
                              chamado no procedimento pc_crps517

                 12/03/2018 - Adicionado a procedure pc_renova_limdesctit que centraliza as regras de renovação e
                              validações das configurações do CADLIM. (Paulo Penteado (GFT))

                 04/04/2018 - Comentado a utilização da pc_apaga_estudo_limdesctit. Devido a criação da estrutura
                              de proposta do limite de desconto de titulos tabela (crawlim) não vai mais precisar
                              desse processo de apagar os titulos em estudo (Paulo Penteado (GFT))

                 15/03/2018 - PC_CANCELA_LIMITE_INADIM  - Cancelar limites de crédito para contas com atraso conforme parâmetro da cooperativa - Daniel(AMcom)

                 23/05/2018 - PC_CANCELA_LIMITE_CREDITO - Rotina para cancelamento de Limite de Crédito - Daniel(AMcom)

                 23/08/2018 - Alteraçao na pc_renova_limdesctit: Registrar a renovação na tabela de histórico de alteraçao
                              de contrato de limite (Andrew Albuquerque - GFT)

                 16/08/2019 - P450 - Adicionada rotina pc_grava_rating_operacao na pc_renova_limdesctit
                              para salvar rating como vencido para enviar para o LOTE para nova análise.
                              (Luiz Otavio Olinger Momm - AMCOM)

                 16/08/2019 - P450 - Adicionada rotina pc_grava_rating_operacao na pc_crps517
                              para salvar rating como vencido para enviar para o LOTE para nova análise.
                              (Luiz Otavio Olinger Momm - AMCOM)
  */
  ---------------------------------------------------------------------------------------------------------------

   -- Código do programa
   vr_cdprogra constant crapprg.cdprogra%type := 'CRPS517';
   vr_acao     varchar2(100)                  := 'LIMI0002.pc_crps517';
   vr_idprglog tbgen_prglog.idprglog%type     := 0;

  /* Rotina para solicitar o envio de email */
  PROCEDURE pc_email_critica(pr_cdcooper    in crapcop.cdcooper%type
                            ,pr_cdprogra    in varchar2
                            ,pr_email_dest  in varchar2
                            ,pr_des_assunto in varchar2
                            ,pr_des_corpo   in varchar2) is

     vr_des_erro varchar2(1000);
  BEGIN
     /* Envio do arquivo detalhado via e-mail */
     gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                               ,pr_cdprogra        => pr_cdprogra
                               ,pr_des_destino     => pr_email_dest
                               ,pr_des_assunto     => pr_des_assunto
                               ,pr_des_corpo       => pr_des_corpo
                               ,pr_des_anexo       => null
                               ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                               ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                               ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                               ,pr_des_erro        => vr_des_erro);
  END;

  PROCEDURE pc_tela_lim_saque_consultar(pr_nrdconta tbtaa_limite_saque.nrdconta%TYPE  --> Numero da Conta
                                       ,pr_xmllog   IN VARCHAR2                       --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS                  --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_lim_saque_consultar
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Julho/15.                    Ultima atualizacao: 29/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Consultar a tela de limite de saque do TAA

     Observacao: -----
     Alteracoes:
                 29/06/2017 - Setar modulo
                              (Belli - Envolti - Chamado 660306)
     ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_tbtaa_limite_saque(pr_cdcooper IN tbtaa_limite_saque.cdcooper%TYPE
                                  ,pr_nrdconta IN tbtaa_limite_saque.nrdconta%TYPE) IS
        SELECT vllimite_saque,
               flgemissao_recibo_saque,
               dtalteracao_limite,
               cdoperador_alteracao
          FROM tbtaa_limite_saque
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_tbtaa_limite_saque cr_tbtaa_limite_saque%ROWTYPE;

      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT nmoperad
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND crapope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Variaveis do Limite de Saque
      vr_vllimite_saque           tbtaa_limite_saque.vllimite_saque%TYPE;
      vr_flgemissao_recibo_saque  tbtaa_limite_saque.flgemissao_recibo_saque%TYPE;
      vr_dtalteracao_limite       tbtaa_limite_saque.dtalteracao_limite%TYPE;
      vr_cdoperador_alteracao     tbtaa_limite_saque.cdoperador_alteracao%TYPE;
      vr_nmoperad                 crapope.nmoperad%TYPE;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Incluir nome do módulo logado - Chamado 660306 29/06/2017
      GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'LIMI0002.pc_tela_lim_saque_consultar');

      -- Cursor com os dados do limite de saque
      OPEN cr_tbtaa_limite_saque(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta);
      FETCH cr_tbtaa_limite_saque INTO rw_tbtaa_limite_saque;
      IF cr_tbtaa_limite_saque%FOUND THEN
        CLOSE cr_tbtaa_limite_saque;
        -- Armazena os valores em variaveis
        vr_vllimite_saque           := rw_tbtaa_limite_saque.vllimite_saque;
        vr_flgemissao_recibo_saque  := rw_tbtaa_limite_saque.flgemissao_recibo_saque;
        vr_dtalteracao_limite       := rw_tbtaa_limite_saque.dtalteracao_limite;
        vr_cdoperador_alteracao     := rw_tbtaa_limite_saque.cdoperador_alteracao;
      ELSE
        CLOSE cr_tbtaa_limite_saque;
      END IF;

      -- Verifica se possui operador cadastrado
      IF rw_tbtaa_limite_saque.cdoperador_alteracao <> ' ' THEN
        -- Buscar Dados do Operador
        OPEN cr_crapope (pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => rw_tbtaa_limite_saque.cdoperador_alteracao);
        FETCH cr_crapope
         INTO rw_crapope;
        IF cr_crapope%FOUND THEN
          CLOSE cr_crapope;
          vr_nmoperad := rw_crapope.nmoperad;
        ELSE
          CLOSE cr_crapope;
        END IF;

      END IF; /* END IF rw_tbtaa_limite_saque.cdoperador_alteracao <> ' ' THEN */

      -- Cria o XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimite_saque', pr_tag_cont => vr_vllimite_saque, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgemissao_recibo_saque', pr_tag_cont => vr_flgemissao_recibo_saque, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dtalteracao_limite', pr_tag_cont => TO_CHAR(vr_dtalteracao_limite,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdoperador_alteracao', pr_tag_cont => vr_cdoperador_alteracao, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmoperador_alteracao', pr_tag_cont => vr_nmoperad, pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        -- Colocado Log no padrão - 29/06/2017 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em LIMI0002.pc_tela_lim_saque_consultar: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_tela_lim_saque_consultar;

  PROCEDURE pc_tela_lim_saque_alterar(pr_nrdconta                tbtaa_limite_saque.nrdconta%TYPE                --> Numero da Conta
                                     ,pr_dtmvtolt IN VARCHAR2                                                        --> Data de Movimentacao
                                     ,pr_vllimite_saque          tbtaa_limite_saque.vllimite_saque%TYPE          --> Valor do Limite do Saque
                                     ,pr_flgemissao_recibo_saque tbtaa_limite_saque.flgemissao_recibo_saque%TYPE --> Recibo Saque
                                     ,pr_xmllog   IN VARCHAR2                                                    --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER                                                --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                                                   --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType                                          --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                                                   --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS                                               --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_lim_saque_alterar
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Julho/15.                    Ultima atualizacao: 29/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Alterar as regras do limite de saque do TAA

     Observacao: -----
     Alteracoes:
                 29/06/2017 - Setar modulo
                              (Belli - Envolti - Chamado 660306)
     ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_tbtaa_limite_saque(pr_cdcooper IN tbtaa_limite_saque.cdcooper%TYPE
                                  ,pr_nrdconta IN tbtaa_limite_saque.nrdconta%TYPE) IS
        SELECT vllimite_saque,
               flgemissao_recibo_saque,
               CASE WHEN flgemissao_recibo_saque = 0 THEN 'Nao Emite'
                    ELSE 'Emite'
               END AS emissao_recibo_saque
          FROM tbtaa_limite_saque
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_tbtaa_limite_saque cr_tbtaa_limite_saque%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      vr_dtmvtolt      DATE;

      -- Variaveis de log
      vr_dstransa             VARCHAR2(1000);
      vr_dsorigem             VARCHAR2(1000);
      vr_emissao_recibo_saque VARCHAR2(100);
      --vr_indtrans             INTEGER;
      vr_nrdrowid             ROWID;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Incluir nome do módulo logado - Chamado 660306 29/06/2017
      GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'LIMI0002.pc_tela_lim_saque_consultar');

      vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));
      vr_dstransa := 'Inclusao/Alteracao Limite Saque TAA';
      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/RRRR');

      IF pr_vllimite_saque <= 0 THEN
        vr_dscritic := 'Limite de saque invalido.';
        RAISE vr_exc_saida;
      END IF;

      IF pr_flgemissao_recibo_saque NOT IN (0,1) THEN
        vr_dscritic := 'Indicador invalido para emissao de recibo de saque.';
        RAISE vr_exc_saida;
      END IF;

      -- Cursor com os dados do limite de saque
      OPEN cr_tbtaa_limite_saque(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta);
      FETCH cr_tbtaa_limite_saque
       INTO rw_tbtaa_limite_saque;
      IF cr_tbtaa_limite_saque%FOUND THEN
        CLOSE cr_tbtaa_limite_saque;
        -- Atualiza os dados do Limite de Saque
        BEGIN
          UPDATE tbtaa_limite_saque SET
                 vllimite_saque          = pr_vllimite_saque
                ,flgemissao_recibo_saque = pr_flgemissao_recibo_saque
                ,dtalteracao_limite      = vr_dtmvtolt
                ,cdoperador_alteracao    = vr_cdoperad
           WHERE cdcooper = vr_cdcooper
             AND nrdconta = pr_nrdconta;
        EXCEPTION
          WHEN OTHERS THEN
            -- Colocado Log no padrão - 29/06/2017 - Chamado 660306
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);
            vr_dscritic := 'Erro ao alterar o limite de saque: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

      ELSE
        CLOSE cr_tbtaa_limite_saque;

        -- Grava os dados do Limite de saque do TAA
        BEGIN
          INSERT INTO tbtaa_limite_saque
                      (cdcooper
                      ,nrdconta
                      ,vllimite_saque
                      ,flgemissao_recibo_saque
                      ,dtalteracao_limite
                      ,cdoperador_alteracao)
               VALUES (vr_cdcooper
                      ,pr_nrdconta
                      ,pr_vllimite_saque
                      ,pr_flgemissao_recibo_saque
                      ,vr_dtmvtolt
                      ,vr_cdoperad);
        EXCEPTION
          WHEN OTHERS THEN
            -- Colocado Log no padrão - 29/06/2017 - Chamado 660306
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);
            vr_dscritic := 'Erro ao inserir limite de saque. '||SQLERRM;
            RAISE vr_exc_saida;
        END;

      END IF;

      -- Chamar geracao de LOG
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => SYSDATE
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Limite de Saque'
                               ,pr_dsdadatu => To_Char(nvl(pr_vllimite_saque,0),'fm999g999g990d00')
                               ,pr_dsdadant => To_Char(nvl(rw_tbtaa_limite_saque.vllimite_saque,0),'fm999g999g990d00'));

      -- Verifica o Recibo de Saque
      IF pr_flgemissao_recibo_saque = 0 THEN
        vr_emissao_recibo_saque := 'Nao Emite';
      ELSE
        vr_emissao_recibo_saque := 'Emite';
      END IF;

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Recibo de Saque'
                               ,pr_dsdadatu => nvl(vr_emissao_recibo_saque,' ')
                               ,pr_dsdadant => nvl(rw_tbtaa_limite_saque.emissao_recibo_saque,' '));

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
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
        -- Colocado Log no padrão - 29/06/2017 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em LIMI0002.pc_tela_lim_saque_alterar: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_tela_lim_saque_alterar;


  PROCEDURE pc_apaga_estudo_limdesctit(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                      ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Codigo do operador
                                      ,pr_idorigem IN INTEGER               --> Indicador da origem da chamada
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ) is
    /* .............................................................................

     Programa: pc_apaga_estudo_limdesctit
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : Paulo Penteado
     Data    : fevereiro/2018.                    Ultima atualizacao: 15/02/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Excluir do sistema todos os limites de desconto em estudo por mais de 30 dias a partir
                 da liberação desta melhoria, para limpeza da base de dados.

                 O parâmetro pr_cdcooper é alimentado com todas as coop ativas, pois a procedure  limi0002.pc_crps517
                 é chamada dentro do loop das coop ativas dentro da procedure cecred.pc_crps517

     Observacao: -----
     Alteracoes: 15/02/2018 - Criação (Paulo Penteado GFT)

     ..............................................................................*/

    vr_dtretro date;

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;

    -- Variaveis de log
    vr_dsorigem      VARCHAR2(1000);
    vr_nrdrowid      rowid;

    -- cursor sobre os contratos de limites de credito que estão em estudo
    cursor cr_craplim is
    select lim.tpctrlim
         , lim.nrctrlim
         , lim.nrdconta
    from   craplim lim
    where  lim.dtpropos <= vr_dtretro
    and    lim.tpctrlim  = 3
    and    lim.Insitlim  = 1
    and    lim.cdcooper  = pr_cdcooper;
    rw_craplim cr_craplim%rowtype;

  begin
    BEGIN
      vr_dtretro  := add_months(trunc(sysdate),-1);
      vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(pr_idorigem));

      open  cr_craplim;
      loop
            fetch cr_craplim into rw_craplim;
            exit  when cr_craplim%notfound;

            delete craplim lim
            where  lim.tpctrlim = rw_craplim.tpctrlim
            and    lim.nrctrlim = rw_craplim.nrctrlim
            and    lim.cdcooper = pr_cdcooper;

            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => null
                                ,pr_dsorigem => vr_dsorigem
                                ,pr_dstransa => 'Decurso de Prazo'
                                ,pr_dttransa => SYSDATE
                                ,pr_flgtrans => 1
                                ,pr_hrtransa => GENE0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'ATENDA'
                                ,pr_nrdconta => rw_craplim.nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
      end   loop;
      close cr_craplim;

      COMMIT;
    exception
      WHEN OTHERS then
        pr_dscritic := 'Falha em LIMI0002.pc_apaga_estudo_limdesctit, erro: ' || SQLERRM;

        -- Desfaz as alterações da base
        ROLLBACK;
    END;
  end pc_apaga_estudo_limdesctit;


PROCEDURE pc_renova_limdesctit(pr_cdcooper in crapcop.cdcooper%type   --> Cooperativa solicitada
                              ,pr_nrdconta in crapass.nrdconta%type  --> Número da Conta
                              ,pr_nrctrlim in craplim.nrctrlim%type  --> Numero Contrato
                              ,pr_tpctrlim in craplim.tpctrlim%type  --> Tipo Contrato
                              ,pr_cdoperad in crapdev.cdoperad%type  --> Codigo do operador
                              ,pr_nmdatela in varchar2               --> Nome da tela
                              ,pr_cdcritic out crapcri.cdcritic%type --> Critica encontrada
                              ,pr_dscritic out varchar2              --> Texto de erro/critica encontrada
                              ) is
BEGIN
   /*........................................................................

   Programa: pc_renova_autom_limdesctit
   Sistema : Limite Desconto Titulo - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Paulo Penteado (GFT)
   Data    : Março/2018                      Ultima Atualizacao: 09/03/2018
   Dados referente ao programa:

   Frequencia: Diario.
   Objetivo  : Renovacao automatica do limite de desconto de titulo.

   Alteração : 09/03/2018 - Criação (Paulo Penteado (GFT))

               16/08/2019 - P450 - Adicionada rotina pc_grava_rating_operacao para salvar rating
                            como vencido para enviar para o LOTE para nova análise.
                            (Luiz Otavio Olinger Momm - AMCOM)

   ............................................................................ */

DECLARE
   -- Tratamento de erros
   vr_exc_saida  exception;
   vr_cdcritic   pls_integer;
   vr_dscritic   varchar2(4000);

   -- Regras
   vr_dtaltera   date;           --> Data de revisao cadastral
   vr_dtmincta   date;           --> Data do Tempo Minimo de Conta
   vr_dstextab   varchar2(1000); --> Campo da tabela generica
   vr_vlarrast   number;         --> Valor Arrasto
   vr_nivrisco   varchar2(2);    --> Nivel de Risco

   -- Auxiliares
   vr_liquidez   number;         --> Percentual de liquidez
   vr_vllimite   number;         --> Valor limite do contrato
   vr_dtultmes_ant date;         --> Data ultimo dia mês anterior
   vr_in_risco_rat INTEGER;      --> Indice do Risco

   -- Consulta de limite
   vr_tab_dados_dsctit  dsct0002.typ_tab_dados_dsctit;
   vr_tab_cecred_dsctit dsct0002.typ_tab_cecred_dsctit;

   -- Parametro de Flag Rating Renovacao Ativo: 0-Não Ativo, 1-Ativo
   vr_flg_Rating_Renovacao_Ativo    NUMBER := 0;

   --     Busca dos dados da cooperativa
   cursor cr_crapcop is
   select cop.nmrescop
         ,cop.nmextcop
         ,cop.nrdocnpj
   from   crapcop cop
   where  cop.cdcooper = pr_cdcooper;
   rw_crapcop cr_crapcop%rowtype;

   --     Listagem de alterações cadastrais
   cursor cr_crapalt(pr_nrdconta in crapcyb.nrdconta%type) is
   select /*+index_desc (crapalt  CRAPALT##CRAPALT1) */
          crapalt.dtaltera
   from   crapalt
   where  crapalt.cdcooper = pr_cdcooper
   and    crapalt.nrdconta = pr_nrdconta
   and    crapalt.tpaltera = 1
   and    rownum = 1;
   rw_crapalt cr_crapalt%rowtype;

   --     Verifica se possui registro no CYBER
   cursor cr_crapcyb(pr_nrdconta in crapcyb.nrdconta%type
                    ,pr_cdorigem varchar2
                    ,pr_qtdiaatr in crapcyb.qtdiaatr%type) is
   select qtdiaatr
   from   crapcyb -- Contratos que estao em cobranca no sistema CYBER
   where  crapcyb.cdcooper      = pr_cdcooper
   and    crapcyb.nrdconta      = pr_nrdconta
   and    ','||pr_cdorigem||',' like ('%,'||crapcyb.cdorigem||',%')
   and    crapcyb.qtdiaatr      > pr_qtdiaatr
   and    crapcyb.dtdbaixa      is null
   and    rownum                = 1;
   rw_crapcyb cr_crapcyb%rowtype;

   --     Limite de desconto
   cursor cr_craplim_crapass(pr_inpessoa in crapass.inpessoa%type
                            ,pr_dtmvtolt in crapdat.dtmvtolt%type
                            ,pr_qtdiaren in craprli.qtdiaren%type
                            ) is
   select lim.cdcooper
         ,lim.nrdconta
         ,lim.vllimite
         ,lim.qtrenova
         ,lim.cddlinha
         ,lim.qtdiavig
         ,lim.nrctrlim
         ,nvl(lim.dtfimvig, lim.dtinivig + lim.qtdiavig) as dtfimvig
         ,lim.rowid
         ,ass.nmprimtl
         ,ass.cdagenci
         ,ass.dtadmiss
         ,ass.cdsitdct
         ,ass.nrdctitg
         ,ass.flgctitg
         ,ass.flgrenli
         ,ass.inpessoa
         ,ass.nrcpfcnpj_base
   from   crapass ass
         ,craplim lim
   where  ass.inpessoa = pr_inpessoa
   and    ass.nrdconta = lim.nrdconta
   and    ass.cdcooper = lim.cdcooper
   and    -- Tentativas Diárias de Renovações (Dias Corridos)
          (nvl(lim.dtfimvig, lim.dtinivig + lim.qtdiavig) >= (pr_dtmvtolt - pr_qtdiaren))
   and    lim.tpctrlim = pr_tpctrlim
   and    lim.nrctrlim = pr_nrctrlim
   and    lim.nrdconta = pr_nrdconta
   and    lim.cdcooper = pr_cdcooper;
   rw_craplim_crapass cr_craplim_crapass%rowtype;

   --     Regras do limite de desconto
   --     tplimite = 3: Regras CADLIM
   cursor cr_cadlim is
   select craprli.cdcooper
         ,craprli.inpessoa
         ,craprli.vlmaxren -- Valor Máximo do Limite (R$)
         ,craprli.nrrevcad -- Revisão Cadastral (Meses)
         ,craprli.qtmincta -- Tempo de Conta (Meses)
         ,craprli.qtdiaren -- Tentativas Diárias de Renovações (Dias Corridos)
         ,craprli.qtmaxren -- Qtde. Máxima de Renovações
         ,craprli.qtdiaatr -- Operações de Crédito em Atraso (Dias)
         ,craprli.qtatracc -- Conta Corrente em Atraso (Dias)
         ,craprli.dssitdop -- Situação da Conta
         ,craprli.dsrisdop -- Risco da Conta
         ,craprli.pcliqdez -- Percentual de Liquidez (%)
         ,craprli.qtdialiq -- Qtd. Dias Calculo % de Liquidez
         ,craprli.qtcarpag -- Período de Carência de Pagamento (Dias)
   from   craprli
   where  craprli.tplimite = 3
   and    craprli.cdcooper = pr_cdcooper;

   --     Risco com divida (Valor Arrasto)
   cursor cr_ris_comdiv(pr_nrdconta in crapris.nrdconta%type
                       ,pr_dtrefere in crapris.dtrefere%type
                       ,pr_inddocto in crapris.inddocto%type
                       ,pr_vldivida in crapris.vldivida%type) is
   select /*+index_desc (CRAPRIS CRAPRIS##CRAPRIS1)*/
          innivris
   from   crapris
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    dtrefere = pr_dtrefere
   and    inddocto = pr_inddocto
   and    vldivida > pr_vldivida
   and    rownum   = 1;
   rw_ris_comdiv cr_ris_comdiv%rowtype;

   --     Risco sem divida
   cursor cr_ris_semdiv(pr_nrdconta in crapris.nrdconta%type
                       ,pr_dtrefere in crapris.dtrefere%type
                       ,pr_inddocto in crapris.inddocto%type) is
   select max(innivris) innivris
   from   crapris
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    dtrefere = pr_dtrefere
   and    inddocto = pr_inddocto;
   rw_ris_semdiv cr_ris_semdiv%rowtype;

   --     Valor Total Descontado com vencimento dentro do período
   cursor cr_craptdb_desc(pr_nrdconta     in crapass.nrdconta%type
                         ,pr_dtmvtolt_de  in crapdat.dtmvtolt%type
                         ,pr_dtmvtolt_ate in crapdat.dtmvtolt%type) is
   select nvl(sum(tdb.vltitulo), 0) vltitulo
   from   craptdb tdb -- Titulos contidos do Bordero de desconto de titulos
         ,crapbdt dbt -- Cadastro de borderos de descontos de titulos
   where  tdb.dtresgat is null
   and    tdb.dtlibbdt is not null -- somente os titulos que realmente foram descontados
   and    tdb.dtvencto between pr_dtmvtolt_de and pr_dtmvtolt_ate
   and    tdb.nrborder = dbt.nrborder
   and    tdb.nrdconta = dbt.nrdconta
   and    tdb.cdcooper = dbt.cdcooper
   and    dbt.nrdconta = pr_nrdconta
   and    dbt.cdcooper = pr_cdcooper
   --     Não considerar como título pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo próprio emitente
   and    not exists( select 1
                      from   craptit tit
                      where  tit.cdcooper = tdb.cdcooper
                      and    tit.dtmvtolt = tdb.dtdpagto
                      and    tdb.nrdconta = substr(upper(tit.dscodbar), 26, 8)
                      and    tdb.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
                      and    tit.cdbandst = 85
                      and    tit.cdagenci in (90,91) );
   rw_craptdb_desc cr_craptdb_desc%rowtype;

   --     Valor Total descontado pago com atraso de até x dias e não pagos
   cursor cr_craptdb_npag(pr_nrdconta     in crapass.nrdconta%type
                         ,pr_dtmvtolt_de  in crapdat.dtmvtolt%type
                         ,pr_dtmvtolt_ate in crapdat.dtmvtolt%type
                         ,pr_qtcarpag     in craprli.qtcarpag%type) is
   select nvl(sum(tdb.vltitulo),0) vltitulo
   from   craptdb tdb
         ,crapbdt dbt
   where  tdb.dtresgat                is null
   and    tdb.dtlibbdt                is not null
   and   (tdb.dtvencto + pr_qtcarpag) <= nvl(tdb.dtdpagto, trunc(sysdate))
   and   (tdb.dtvencto + pr_qtcarpag) between pr_dtmvtolt_de and pr_dtmvtolt_ate
   and    tdb.nrborder                = dbt.nrborder
   and    tdb.nrdconta                = dbt.nrdconta
   and    tdb.cdcooper                = dbt.cdcooper
   and    dbt.nrdconta                = pr_nrdconta
   and    dbt.cdcooper                = pr_cdcooper
   --     Não considerar como título pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo próprio emitente
   and    not exists( select 1
                      from   craptit tit
                      where  tit.cdcooper = tdb.cdcooper
                      and    tit.dtmvtolt = tdb.dtdpagto
                      and    tdb.nrdconta = substr(upper(tit.dscodbar), 26, 8)
                      and    tdb.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
                      and    tit.cdbandst = 85
                      and    tit.cdagenci in (90,91));
   rw_craptdb_npag cr_craptdb_npag%rowtype;

   --     Linhas de desconto
   cursor cr_crapldc is
   select crapldc.cddlinha
         ,crapldc.flgstlcr
         ,crapldc.tpdescto
   from   crapldc
   where  crapldc.cdcooper = pr_cdcooper
   and    crapldc.tpdescto = 3;

   /*cursor cr_craptdb_proc(pr_cddlinha in craplim.cddlinha%type
                         ,pr_dtmvtolt in crapdat.dtmvtolt%type) is
   select lim.cdcooper
   from   craptdb tdb -- Titulos contidos do Bordero de desconto de titulos
         ,crapbdt bdt -- Cadastro de borderos de descontos de titulos
         ,craplim lim
   where  tdb.dtlibbdt >= pr_dtmvtolt
   and    tdb.insittit  = 2 -- Processado
   and    tdb.nrborder  = bdt.nrborder
   and    tdb.nrdconta  = bdt.nrdconta
   and    tdb.cdcooper  = bdt.cdcooper
   and    bdt.nrdconta  = lim.nrdconta
   and    bdt.cdcooper  = lim.cdcooper
   and    bdt.nrctrlim  = lim.nrctrlim
   and    lim.tpctrlim  = pr_tpctrlim
   and    lim.insitlim  = 2
   and    lim.cddlinha  = pr_cddlinha
   and    lim.cdcooper  = pr_cdcooper
   and    rownum        = 1;
   rw_craptdb_proc cr_craptdb_proc%rowtype;*/

   -- Cursor genérico de calendário
   rw_crapdat       btch0001.cr_crapdat%rowtype;
   vr_habrat        VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)
   vr_vlendivid     craplim.vllimite%TYPE; -- Valor do Endividamento do Cooperado
   vr_vllimrating   craplim.vllimite%TYPE; -- Valor do Parametro Rating (Limite) TAB056
   vr_strating      tbrisco_operacoes.insituacao_rating%TYPE; -- Identificador da Situacao Rating
   vr_dtrating      tbrisco_operacoes.dtrisco_rating%TYPE; -- Data para efetivar o rating;

   ----------------------------- PROCEDURES ---------------------------------
   -- Procedure para limpar os dados das tabelas de memoria
   PROCEDURE pc_limpa_tabela is
   BEGIN
      vr_tab_crapldc.delete;
      vr_tab_craptab.delete;
   EXCEPTION
      when others then
           vr_dscritic := 'Erro ao limpar tabelas de memória. Rotina pc_crps710.pc_limpa_tabela. '||sqlerrm;
           raise vr_exc_saida;
   END;

   -- Registra LOG de alteração para a tela ALTERA
   PROCEDURE pc_gera_log_alteracao(pr_cdcooper in crapcop.cdcooper%type
                                  ,pr_nrdconta in crapcop.nrdconta%type
                                  ,pr_dtmvtolt in crapdat.dtmvtolt%type
                                  ,pr_cdoperad in crapope.cdoperad%type
                                  ,pr_nrctrlim in craplim.nrctrlim%type
                                  ,pr_nrdctitg in crapass.nrdctitg%type
                                  ,pr_flgctitg in crapass.flgctitg%type) is
      -- Variaveis de Log de Alteracao
      vr_flgctitg crapalt.flgctitg%type;
      vr_dsaltera long;

      -- Variaveis com erros
      vr_des_erro   varchar2(4000);

      --     Cursor alteracao de cadastro
      cursor cr_crapalt is
      select crapalt.dsaltera
            ,crapalt.rowid
      from   crapalt
      where  crapalt.cdcooper = pr_cdcooper
      and    crapalt.nrdconta = pr_nrdconta
      and    crapalt.dtaltera = pr_dtmvtolt;
      rw_crapalt cr_crapalt%rowtype;

   BEGIN
      -- Por default fica como 3
      vr_flgctitg  := 3;
      vr_dsaltera  := 'Renov. Aut. Limite Desc. de Titulo: ' || pr_nrctrlim || ',';

      --  Se for conta integracao ativa, seta a flag para enviar ao BB
      if  trim(pr_nrdctitg) is not null and pr_flgctitg = 2 then  -- Ativa
          --Conta Integracao
          vr_flgctitg := 0;
      end if;

      --    Verifica se jah possui alteracao
      open  cr_crapalt;
      fetch cr_crapalt into rw_crapalt;
      if    cr_crapalt%found then
            close cr_crapalt;

            begin
               update crapalt
               set    crapalt.dsaltera = rw_crapalt.dsaltera || vr_dsaltera
                     ,crapalt.flgctitg = vr_flgctitg
               where  crapalt.rowid = rw_crapalt.rowid;
            exception
               when others then
                    vr_des_erro := 'Conta: '||pr_nrdconta ||'.Contrato: ' || pr_nrctrlim ||'.'||
                                   'Erro ao atualizar crapalt. '||sqlerrm;

               -- Catalogar o Erro
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            ||vr_cdprogra || ' --> '|| vr_des_erro);
            end;
      else
            close cr_crapalt;

            begin
               insert into crapalt
                      (nrdconta
                      ,dtaltera
                      ,tpaltera
                      ,dsaltera
                      ,cdcooper
                      ,flgctitg
                      ,cdoperad)
               values (pr_nrdconta
                      ,pr_dtmvtolt
                      ,2
                      ,vr_dsaltera
                      ,pr_cdcooper
                      ,vr_flgctitg
                      ,pr_cdoperad);
            exception
               when others then
                    vr_des_erro:= 'Conta: '||pr_nrdconta||'.Contrato: '||pr_nrctrlim ||'.'||
                                  'Erro ao inserir crapalt. '||sqlerrm;

                    -- Catalogar o Erro
                    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                  ||vr_cdprogra || ' --> ' || vr_des_erro);
            end;
      end   if;
   END pc_gera_log_alteracao;

   -- Procedure para atualizar a nao renovacao do limite de desconto
   PROCEDURE pc_nao_renovar(pr_craplim_crapass in cr_craplim_crapass%rowtype
                           ,pr_dsnrenov        in varchar2
                           ,pr_dsvlrmot        in varchar2) is
      -- Variaveis com erros
      vr_exc_erro   exception;
      vr_des_erro   varchar2(4000);
   BEGIN
      -- Atualizar a tabela de limite de desconto de titulo
      update craplim
      set    dsnrenov = pr_dsnrenov || '|' || pr_dsvlrmot
      where  rowid    = pr_craplim_crapass.rowid;
   EXCEPTION
      when others then
           --Variavel de erro recebe erro ocorrido
           vr_des_erro := 'Conta: '    || pr_craplim_crapass.nrdconta ||'.'||
                          'Contrato: ' || pr_craplim_crapass.nrctrlim ||'.'||
                          'Erro ao atualizar tabela craplim. Rotina limi0002.pc_crps517. '||sqlerrm;
           -- Catalogar o erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '|| vr_des_erro);
   END;

BEGIN
   -- Incluir nome do módulo logado
   gene0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);

   -- Verifica se a cooperativa esta cadastrada
   open  cr_crapcop;
   fetch cr_crapcop into rw_crapcop;
   if    cr_crapcop%notfound then
         close cr_crapcop;
         vr_cdcritic := 651;
         raise vr_exc_saida;
   end   if;
   close cr_crapcop;

   --    Leitura do calendário da cooperativa
   open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   fetch btch0001.cr_crapdat into rw_crapdat;
   if    btch0001.cr_crapdat%notfound then
         close btch0001.cr_crapdat;
         vr_cdcritic := 1;
         raise vr_exc_saida;
   end   if;
   close btch0001.cr_crapdat;

   pc_limpa_tabela;

   --> Buscar Parametro
   vr_flg_Rating_Renovacao_Ativo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                             ,pr_cdcooper => 0
                                                             ,pr_cdacesso => 'RATING_RENOVACAO_ATIVO');

   vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                          pr_cdcooper => pr_cdcooper,
                                          pr_cdacesso => 'HABILITA_RATING_NOVO');

   -- Incluir nome do módulo logado - Chamado 660306 29/06/2017
   gene0001.pc_set_modulo(pr_module => nvl(trim(pr_nmdatela),vr_cdprogra)
                         ,pr_action => vr_acao);

   -- Seleciona valor de arrasto da tabela generica
   vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'RISCOBACEN'
                                            ,pr_tpregist => 0);
   -- Atribui o valor do arrasto
   vr_vlarrast := nvl(gene0002.fn_char_para_number(substr(vr_dstextab, 3, 9)),0);
   -- Carrega os tipos de riscos
   vr_tab_craptab(1).dsdrisco  := 'AA';
   vr_tab_craptab(2).dsdrisco  := 'A';
   vr_tab_craptab(3).dsdrisco  := 'B';
   vr_tab_craptab(4).dsdrisco  := 'C';
   vr_tab_craptab(5).dsdrisco  := 'D';
   vr_tab_craptab(6).dsdrisco  := 'E';
   vr_tab_craptab(7).dsdrisco  := 'F';
   vr_tab_craptab(8).dsdrisco  := 'G';
   vr_tab_craptab(9).dsdrisco  := 'H';
   vr_tab_craptab(10).dsdrisco := 'H';

   --  Se retornou alguma crítica
   if  trim(vr_dscritic) is not null or nvl(vr_cdcritic,0) > 0 then
       raise vr_exc_saida;
   end if;

   -- Buscar todas as linhas de desconto de titulo
   for rw_crapldc in cr_crapldc loop
       vr_tab_crapldc(rw_crapldc.cddlinha).flgstlcr  := rw_crapldc.flgstlcr;

       -- Verifica se linha de credito de limite de desconto de titulo possui saldo
       -- Verificando existem se borderôs de desconto ativos
       /* Esse processo já está sendo executado na procedure pc_crps517
       open  cr_craptdb_proc(pr_cddlinha => rw_crapldc.cddlinha
                            ,pr_dtmvtolt => rw_crapdat.dtmvtoan);
       fetch cr_craptdb_proc into rw_craptdb_proc;
       if    cr_craptdb_proc%found then
             vr_flgsaldo := 1; -- Possui saldo
       else
             vr_flgsaldo := 0;-- Nao possui saldo
       end   if;
       close cr_craptdb_proc;

       -- Atualiza o indicador do Cadastro de Linhas de Desconto
       begin
          update crapldc
          set    flgsaldo = vr_flgsaldo
          where  cdcooper = pr_cdcooper
          and    tpdescto = 3
          and    cddlinha = rw_crapldc.cddlinha;
       exception
          when others then
               vr_dscritic := 'Erro ao atualizar tabela crapldc. Rotina pc_crps710. ' || sqlerrm;
               raise vr_exc_saida;
       end;*/
   end loop;

   --> Definir o ultimo dia do mes anterior com base no dia anterior
   vr_dtultmes_ant := last_day(add_months(rw_crapdat.dtmvtoan,-1));

   for rw_cadlim in cr_cadlim loop

       if  cr_craplim_crapass%isopen then
           close cr_craplim_crapass;
       end if;

       open  cr_craplim_crapass(pr_inpessoa => rw_cadlim.inpessoa
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_qtdiaren => rw_cadlim.qtdiaren);
       fetch cr_craplim_crapass into rw_craplim_crapass;
       if    cr_craplim_crapass%found then
             --  Verifica a situacao do limite do desconto
             if  nvl(rw_craplim_crapass.flgrenli,0) = 0 then
                 pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                               ,pr_dsnrenov        => 'Desabilitado Renovacao Automatica'
                               ,pr_dsvlrmot        => '');
                 continue;
             end if;

             --  Verifica se a linha rotativa esta cadastrada
             if  not vr_tab_crapldc.exists(rw_craplim_crapass.cddlinha) then
                 vr_dscritic := 'Linha de Credito nao cadastrada. Linha: ' || rw_craplim_crapass.cddlinha;
                 -- Envio centralizado de log de erro
                 btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                           ,pr_ind_tipo_log => 2 -- Erro tratato
                                           ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> '|| vr_dscritic);
                 continue;
             end if;

             --  Verifica a situacao do limite de desconto de titulo
             if  nvl(vr_tab_crapldc(rw_craplim_crapass.cddlinha).flgstlcr,0) = 0 then
                 pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                               ,pr_dsnrenov        => 'Linha de desconto bloqueada'
                               ,pr_dsvlrmot        => rw_craplim_crapass.cddlinha);
                 continue;
             end if;

             --  Verifica a situacao da conta
             if  (instr(';' || rw_cadlim.dssitdop || ';',';' || rw_craplim_crapass.cdsitdct || ';') <= 0) then
                 pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                               ,pr_dsnrenov        => 'Situacao da Conta'
                               ,pr_dsvlrmot        => rw_craplim_crapass.cdsitdct);
                 continue;
             end if;

             -- Consulta o limite de desconto por tipo de pessoa
             dsct0002.pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                                ,pr_cdagenci          => null -- não utiliza dentro da procedure
                                                ,pr_nrdcaixa          => null -- não utiliza dentro da procedure
                                                ,pr_cdoperad          => null -- não utiliza dentro da procedure
                                                ,pr_dtmvtolt          => null -- não utiliza dentro da procedure
                                                ,pr_idorigem          => null -- não utiliza dentro da procedure
                                                ,pr_tpcobran          => 0    -- Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                                ,pr_inpessoa          => rw_cadlim.inpessoa
                                                ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> Tabela contendo os parametros da cooperativa
                                                ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                                ,pr_cdcritic          => vr_cdcritic
                                                ,pr_dscritic          => vr_dscritic );

             --  Pega o menor valor
             if  nvl(rw_cadlim.vlmaxren,0) < vr_tab_dados_dsctit(1).vllimite then
                 vr_vllimite := rw_cadlim.vlmaxren;
             else
                 vr_vllimite := vr_tab_dados_dsctit(1).vllimite;
             end if;

             --  Valida se o limite do contrato respeita o Limite Maximo do Contrato
             if  nvl(rw_craplim_crapass.vllimite,0) > vr_vllimite then
                 pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                               ,pr_dsnrenov        => 'Valor do Limite'
                               ,pr_dsvlrmot        => to_char(rw_craplim_crapass.vllimite,'fm999g999g999g990d00'));
                 continue;
             end if;

             --  Verificar a quantidade maxima que pode renovar
             if  ((nvl(rw_cadlim.qtmaxren,0) > 0) and (nvl(rw_craplim_crapass.qtrenova,0) >= nvl(rw_cadlim.qtmaxren,0))) then
                 pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                               ,pr_dsnrenov        => 'Qtde. maxima de renovacao excedida'
                               ,pr_dsvlrmot        => rw_craplim_crapass.qtrenova);
                 continue;
             end if;

             -- Verificar o tempo de conta
             vr_dtmincta := add_months(rw_crapdat.dtmvtolt, - (rw_cadlim.qtmincta));
             if  rw_craplim_crapass.dtadmiss > vr_dtmincta then
                 pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                               ,pr_dsnrenov        => 'Tempo de Conta'
                               ,pr_dsvlrmot        => to_char(rw_craplim_crapass.dtadmiss,'DD/MM/RRRR'));
                 continue;
             end if;

             --    Risco com divida (Valor Arrasto)
             open  cr_ris_comdiv(pr_nrdconta => rw_craplim_crapass.nrdconta
                                ,pr_dtrefere => vr_dtultmes_ant
                                ,pr_inddocto => 1
                                ,pr_vldivida => vr_vlarrast);
             fetch cr_ris_comdiv into rw_ris_comdiv;
             close cr_ris_comdiv;

             if  rw_ris_comdiv.innivris is not null then
                 vr_nivrisco := trim(vr_tab_craptab(rw_ris_comdiv.innivris).dsdrisco);
             else
                 --   Risco sem divida
                 open cr_ris_semdiv(pr_nrdconta => rw_craplim_crapass.nrdconta
                                   ,pr_dtrefere => vr_dtultmes_ant
                                   ,pr_inddocto => 1);
                 fetch cr_ris_semdiv into rw_ris_semdiv;
                 close cr_ris_semdiv;

                 if  rw_ris_semdiv.innivris is not null then
                     -- Quando possuir operacao em Prejuizo, o risco da central sera H
                     if  rw_ris_semdiv.innivris = 10 then
                         vr_nivrisco := trim(vr_tab_craptab(rw_ris_semdiv.innivris).dsdrisco);
                     else
                         vr_nivrisco := trim(vr_tab_craptab(2).dsdrisco);
                     end if;
                 else
                     vr_nivrisco := trim(vr_tab_craptab(2).dsdrisco);
                 end if;
             end if;

             --  Caso seja uma classificacao antiga
             if  vr_nivrisco = 'AA' then
                 vr_nivrisco := 'A';
             end if;

             --  Verifica o risco da conta
             if  (instr(';' || rw_cadlim.dsrisdop || ';',';' || vr_nivrisco || ';') <= 0) then
                 pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                               ,pr_dsnrenov        => 'Risco da Conta'
                               ,pr_dsvlrmot        => vr_nivrisco);
                 continue;
             end if;

             vr_dtaltera := null;

             --    Revisão Cadastral
             open  cr_crapalt(pr_nrdconta => rw_craplim_crapass.nrdconta);
             fetch cr_crapalt into rw_crapalt;
             if    cr_crapalt%found then
                   vr_dtaltera := rw_crapalt.dtaltera;
             end   if;
             close cr_crapalt;

             --  Verifica a revisao cadastral se estah dentro do periodo
             if  ((add_months(rw_crapdat.dtmvtolt, - (rw_cadlim.nrrevcad)) > vr_dtaltera) or (vr_dtaltera is null)) then
                 pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                               ,pr_dsnrenov        => 'Revisao Cadastral'
                               ,pr_dsvlrmot        => to_char(vr_dtaltera,'DD/MM/RRRR'));
                 continue;
             end if;

             --    Verifica se o cooperado possui algum emprestimo em atraso no CYBER
             open  cr_crapcyb(pr_nrdconta => rw_craplim_crapass.nrdconta
                             ,pr_cdorigem => '2,3' -- 2-Descontos, 3-Emprestimos
                             ,pr_qtdiaatr => rw_cadlim.qtdiaatr);
             fetch cr_crapcyb into rw_crapcyb;
             if    cr_crapcyb%found then
                   close cr_crapcyb;
                   pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                                 ,pr_dsnrenov        => 'Qtde de dias Atraso do Emprestimo'
                                 ,pr_dsvlrmot        => nvl(rw_crapcyb.qtdiaatr,0));
                   continue;
             end   if;
             close cr_crapcyb;

             --    Verifica se o cooperado possui estouro de conta no CYBER
             open  cr_crapcyb(pr_nrdconta => rw_craplim_crapass.nrdconta
                             ,pr_cdorigem => '1' -- 1-Conta
                             ,pr_qtdiaatr => rw_cadlim.qtatracc);
             fetch cr_crapcyb into rw_crapcyb;
             if    cr_crapcyb%found then
                   close cr_crapcyb;
                   pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                                 ,pr_dsnrenov        => 'Qtde de dias Atraso Conta Corrente'
                                 ,pr_dsvlrmot        => nvl(rw_crapcyb.qtdiaatr,0));
                   continue;
             end   if;
             close cr_crapcyb;

             /* Calculo da Liquidez:
                Valor Total descontado pago com atraso de até x dias e não pagos,
                dividido pelo Valor Total Descontado com vencimento dentro do período,
                vezes 100 = percentual de liquidez.
               (Não considerar como título pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo próprio emitente) */

             --    Valor Total Descontado com vencimento dentro do período
             open  cr_craptdb_desc(pr_nrdconta     => rw_craplim_crapass.nrdconta
                                  ,pr_dtmvtolt_de  => rw_crapdat.dtmvtolt - rw_cadlim.qtdialiq
                                  ,pr_dtmvtolt_ate => rw_crapdat.dtmvtolt);
             fetch cr_craptdb_desc into rw_craptdb_desc;
             close cr_craptdb_desc;

             --  Se não houver desconto, liquidez é 100%
             if  rw_craptdb_desc.vltitulo = 0 then
                 vr_liquidez := 100;
             else
                 -- Valor Total descontado pago com atraso de até x dias e não pagos
                 open  cr_craptdb_npag(pr_nrdconta     => rw_craplim_crapass.nrdconta
                                      ,pr_dtmvtolt_de  => rw_crapdat.dtmvtolt - rw_cadlim.qtdialiq
                                      ,pr_dtmvtolt_ate => rw_crapdat.dtmvtolt
                                      ,pr_qtcarpag     => rw_cadlim.qtcarpag);
                 fetch cr_craptdb_npag into rw_craptdb_npag;
                 close cr_craptdb_npag;

                 vr_liquidez := (rw_craptdb_npag.vltitulo / rw_craptdb_desc.vltitulo) * 100;
             end if;

             --  Verifica se o cooperado possui liquidez no produto de desconto maior ou igual ao percentual cadastrado
             if  vr_liquidez < rw_cadlim.pcliqdez then
                 pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                               ,pr_dsnrenov        => 'Liquidez no produto de limite de desconto de titulos'
                               ,pr_dsvlrmot        => round(nvl(vr_liquidez,0),2));

                 continue;
             end if;

             -- P450 SPT13 - alteracao para habilitar rating novo
             IF (pr_cdcooper <> 3 AND vr_habrat = 'S') THEN
               -- Verifica processamento do Rating Renovacao
               IF vr_flg_Rating_Renovacao_Ativo = 1 THEN
                 -- Grava rating
                 -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
                 RATI0003.pc_busca_endivid_param(pr_cdcooper => rw_craplim_crapass.cdcooper
                                                ,pr_nrdconta => rw_craplim_crapass.nrdconta
                                                ,pr_vlendivi => vr_vlendivid
                                                ,pr_vlrating => vr_vllimrating
                                                ,pr_dscritic => vr_dscritic);

                 IF TRIM(vr_dscritic) IS NOT NULL THEN
                   vr_cdcritic := 0;
                   pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                                 ,pr_dsnrenov        => 'Erro ao buscar o endividamento no desconto de título LIMI0002.pc_renova_limdesctit.'
                                 ,pr_dsvlrmot        => ROUND(nvl(vr_liquidez,0),2));
                   CONTINUE;
                 END IF;

                 vr_strating := 2; -- Analisado
                 vr_dtrating := NULL;
                 IF (vr_vlendivid  > vr_vllimrating)  THEN
                   -- Gravar o Rating da operação, efetivando-o
                   vr_strating := 4; -- Efetivado
                   vr_dtrating := rw_crapdat.dtmvtolt;
                 END IF;

                 rati0003.pc_grava_rating_operacao( pr_cdcooper           => rw_craplim_crapass.cdcooper
                                                   ,pr_nrdconta           => rw_craplim_crapass.nrdconta
                                                   ,pr_tpctrato           => pr_tpctrlim
                                                   ,pr_nrctrato           => rw_craplim_crapass.nrctrlim
                                                   ,pr_strating           => vr_strating
                                                   ,pr_dtrataut           => rw_crapdat.dtmvtolt  --> Data da nova renovação
                                                   ,pr_dtmvtolt           => rw_crapdat.dtmvtolt  --> Data/Hora do historico de rating
                                                   ,pr_dtrating           => vr_dtrating
                                                   --Variáveis de crítica
                                                   ,pr_cdcritic           => vr_cdcritic     --> Critica encontrada no processo
                                                   ,pr_dscritic           => vr_dscritic);   --> Descritivo do erro

                 IF ( vr_cdcritic >= 0 AND vr_cdcritic IS NOT NULL) OR TRIM(vr_dscritic) IS NOT NULL THEN
                   vr_cdcritic := 0;
                   pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                                 ,pr_dsnrenov        => 'Erro ao atualizar o rating no desconto de título LIMI0002.pc_renova_limdesctit.'
                                 ,pr_dsvlrmot        => ROUND(nvl(vr_liquidez,0),2));
                   CONTINUE;
                 END IF;
               END IF;
             END IF;
             -- P450 SPT13 - alteracao para habilitar rating novo

             -- Atualiza os dados do limite de desconto de titulo
             begin
                 update craplim
                 set    dtrenova = rw_crapdat.dtmvtolt --rw_crapdat.dtmvtoan
                       ,dtinivig = rw_crapdat.dtmvtolt
                       ,dtfimvig = /*rw_crapdat.dtmvtoan*/rw_craplim_crapass.dtfimvig + nvl(qtdiavig,0)
                       ,tprenova = 'A'
                       ,dsnrenov = ' '
                       ,qtrenova = nvl(qtrenova,0) + 1
                 where  rowid = rw_craplim_crapass.rowid;
             exception
                 when others then
                      vr_dscritic := 'Conta: '    || rw_craplim_crapass.nrdconta ||'.'||
                                     'Contrato: ' || rw_craplim_crapass.nrctrlim ||'.'||
                                     'Erro ao atualizar tabela craplim. Rotina pc_crps710. ' || sqlerrm;
                      -- Catalogar o Erro
                      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '||
                                                                    vr_cdprogra || ' --> ' || vr_dscritic);
                      continue;
             end;

             -- Gerar histórico de renovação automática do contrato.
             cecred.tela_atenda_dscto_tit.pc_gravar_hist_alt_limite(pr_cdcooper => pr_cdcooper
                                                                   ,pr_nrdconta => pr_nrdconta
                                                                   ,pr_nrctrlim => pr_nrctrlim
                                                                   ,pr_tpctrlim => 3 -- Limite Desconto Titulo
                                                                   ,pr_dsmotivo => 'RENOVAÇÃO AUTOMÁTICA'
                                                                   ,pr_cdcritic => vr_cdcritic
                                                                   ,pr_dscritic => vr_dscritic
                                                                   );
             --  Se ocorreu erro
             if  vr_cdcritic is not null or trim(vr_dscritic) is not null then
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro no lancamento de histórido de limite de desconto de titulo';
                -- Envio centralizado de log de erro
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || vr_dscritic);

             end if;

             -- Gera Log de alteracao
             pc_gera_log_alteracao(pr_cdcooper => rw_craplim_crapass.cdcooper
                                  ,pr_nrdconta => rw_craplim_crapass.nrdconta
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_cdoperad => 1
                                  ,pr_nrctrlim => rw_craplim_crapass.nrctrlim
                                  ,pr_nrdctitg => rw_craplim_crapass.nrdctitg
                                  ,pr_flgctitg => rw_craplim_crapass.flgctitg);
       end   if;
       close cr_craplim_crapass;
   end loop; -- END LOOP FOR rw_cadlim

   pc_limpa_tabela;

   -- Salvar informações atualizadas
   COMMIT;

EXCEPTION
   when vr_exc_saida then
        -- Se foi retornado apenas código
        if  vr_cdcritic > 0 and vr_dscritic is null then
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        end if;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        rollback;

   when others then
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        rollback;
END;
END pc_renova_limdesctit;


  PROCEDURE pc_crps517(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

  /* .............................................................................

    Programa: pc_crps517 (Fontes/crps517.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Outubro/2008                    Ultima Atualizacao: 20/09/2017

    Dados referente ao programa:

    Frequencia: Diario.

    Objetivo  : Controlar vigencia dos contratos de limite e o debito de
                titulos em desconto que atingiram a data de vencimento.

    Alteracoes: 06/01/2009 - Tratamento p/ feriados e fins de semana (Evandro).

                28/05/2009 - Antes de efetuar a baixa do titulo como vencido
                             verificar se o crapcob esta baixado, caso esteja
                             jogar uma critica no processo pois ocorreu problema
                             na baixa do titulo quando ele foi pago
                             (Compe ou Caixa e Internet) (Guilherme).

                02/06/2009 - Retirado a critica do log, porque foi colocado
                             tratamento de erros dentro de b2crap14(Guilherme).

                10/12/2009 - Imprimir cada relatorio 497 dos PAs (Evandro).

                30/11/2011 - Condiçao para nao executar relatórios 497 e nao dar
                             baixa nos títulos no último dia útil do ano (Lucas).

                28/06/2012 - Incluido novo parametro na busca_tarifas_dsctit.
                             (David Kruger).

                15/10/2012 - Incluido coluna Tipo Cobr. no relat. 497 (Rafael).

                06/11/2012 - Incluido chamada da procedure desativa-rating
                             da BO43 (Tiago).

                12/07/2013 - Alterado processo para busca valor tarifa renovacao,
                             projeto tarifas (Daniel).

                11/10/2013 - Incluido parametro cdprogra nas procedures da
                             b1wgen0153 que carregam dados de tarifas (Tiago).

                27/11/2013 - Incluido chamada do fimprg antes do return que
                             abortava o programa sendo que nao era um erro
                             (Tiago).

                28/11/2013 - Retirado return no caso de tarifa de renovacao zerada
                             (Daniel).

                23/12/2013 - Alterado totalizador de PAs de 99 para 999.
                             (Reinert)

                19/05/2014 - Conversao Progress => Oracle (Andrino-RKAM).

                13/11/2014 - Inclusão do titulo "Nova Vigencia" e "Fim Vigencia"
                             Projeto Conversao Progress / Oracle (Andrino-RKAM).

                10/02/2015 - Ajuste na sequencia do cabecalho do crrl497 (Andrino-RKAM).

                13/02/2015 - Ajuste para enviar por email a critica de tarifa não encontrada
                             SD250545 (Odirlei-AMcom).

                29/04/2015 - Alterado para substituir o "&" do nome do sacado por "e"
                             para não ocorrer erro no parse do xml (Odirlei-AMcom)

                25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                             tari0001.pc_cria_lan_auto_tarifa, projeto de
                             Tarifas-218(Jean Michel)

                17/02/2016 - Retirado debito de titulos vencidos
                            (Tiago/Rodrigo Melhoria 116 SD344086)

                30/03/2016 - Alterar chamada da procedure pc_carrega_dados_tar_vigente
                             para chamar dentro do loop da craplim e passar o valor do
                             limite ao inves de um valor fixo - M214 (Lucas Ranghetti #402276)

                29/06/2017 - Colocado Log no padrão
                             Setar modulo
                             (Belli - Envolti - Chamado 660306)

                20/09/2017 - Ajustado para não gravar nmarqlog, pois so gera a tbgen_prglog
                             (Ana - Envolti - Chamado 746134)

                15/02/2018 - Adicionado a chamada do procedimento pc_apaga_estudo_limdesctit (Paulo Penteado GFT)

                16/02/2018 - Adicionado o cursor cr_crapldc para atualização do saldo das linhas de desconto (Lucas Silva GFT)

                06/12/2018 - Verificação de qtd máx de renovações do contrato e cancelamento dos contratos da CRAWLIM quando cancelado a CRAPLIM. (Vitor S Assanuma GFT)

                16/08/2019 - P450 - Adicionada rotina pc_grava_rating_operacao para salvar rating
                             como vencido para enviar para o LOTE para nova análise.
                             (Luiz Otavio Olinger Momm - AMCOM)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS517';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Chamado 660306 - 10/07/2017
      -- Variaveis de inclusão de log
      vr_idprglog       tbgen_prglog.idprglog%TYPE := 0;
      vr_acao           VARCHAR2  (100)            := 'LIMI0002.pc_crps517';

      -- Extração dados XML
      vr_cdcooper   NUMBER;
      vr_cdoperad   VARCHAR2(100);
      vr_nmdatela   VARCHAR2(100);
      vr_nmeacao    VARCHAR2(100);
      vr_cdagenci   VARCHAR2(100);
      vr_nrdcaixa   VARCHAR2(100);
      vr_idorigem   VARCHAR2(100);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = vr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      /* Cursor genérico de parametrização */
      CURSOR cr_craptab(pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT tab.cdcooper
              ,tab.dstextab
          FROM craptab tab
         WHERE tab.cdcooper        = vr_cdcooper
           AND UPPER(tab.nmsistem) = pr_nmsistem
           AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres        = pr_cdempres
           AND UPPER(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist        = pr_tpregist;
      rw_craptab cr_craptab%ROWTYPE;

      -- cursor sobre os contratos de limites de credito
      cursor cr_craplim is
      select lim.nrctrlim
            ,lim.nrdconta
            ,lim.tpctrlim
            ,lim.insitlim
            ,lim.vllimite
            ,lim.dtinivig
            ,lim.dtfimvig
            ,lim.qtrenova
            ,lim.qtrenctr
            ,lim.qtdiavig
            ,lim.dtcancel
            ,lim.rowid
            ,rli.qtmaxren
      from   craplim lim
      INNER JOIN crapass ass ON lim.cdcooper = ass.cdcooper AND lim.nrdconta = ass.nrdconta
      LEFT join  craprli rli ON ass.cdcooper = rli.cdcooper AND ass.inpessoa = rli.inpessoa AND rli.tplimite = 3 -- Desconto de titulo
      where((lim.insitlim        = 2  /** Ativo **/
      and   (lim.dtfimvig between (lim.dtfimvig - 15) and rw_crapdat.dtmvtolt)
            ) or lim.insitlim    = 4) /** Vigente **/
      and    lim.tpctrlim        = 3
      and    lim.cdcooper        = vr_cdcooper
      order  by lim.insitlim, lim.dtfimvig;

      -- Cursor sobre os dados dos associados
      CURSOR cr_crapass IS
        SELECT nrdconta,
               inpessoa,
               cdagenci,
               nmprimtl
          FROM crapass
         WHERE crapass.cdcooper = vr_cdcooper;

      -- Cursor para verificar a quantidade de borderos pendentes
      CURSOR cr_crapbdt(pr_nrdconta craplim.nrdconta%TYPE,
                        pr_nrctrlim craplim.nrctrlim%TYPE) IS
        SELECT nvl(COUNT(1),0)
          FROM crapbdt
         WHERE crapbdt.cdcooper = vr_cdcooper
           AND crapbdt.nrdconta = pr_nrdconta
           AND crapbdt.nrctrlim = pr_nrctrlim
           AND crapbdt.insitbdt = 3; -- Pendente

      -- Cursor sobre os parametros do cadastro de cobranca
      CURSOR cr_crapcco(pr_nrconven crapcco.nrconven%TYPE) IS
        SELECT flgregis,
               flgutceb,
               cddbanco
          FROM crapcco
         WHERE crapcco.cdcooper = vr_cdcooper
           AND crapcco.nrconven = pr_nrconven;
      rw_crapcco cr_crapcco%ROWTYPE;

      -- Cursor sobre as emissoes de bloquetos
      CURSOR cr_crapceb(pr_nrdconta crapceb.nrdconta%TYPE,
                        pr_nrconven crapceb.nrconven%TYPE) IS
        SELECT nrcnvceb
          FROM crapceb
         WHERE crapceb.cdcooper = vr_cdcooper
           AND crapceb.nrdconta = pr_nrdconta
           AND crapceb.nrconven = pr_nrconven
           AND crapceb.insitceb = 1
         ORDER BY nrcnvceb DESC; -- Buscar o ultimo
      rw_crapceb cr_crapceb%ROWTYPE;


      -- cursor sobre o cadastro de sacados
      CURSOR cr_crapsab(pr_nrdconta crapsab.nrdconta%TYPE,
                        pr_nrinssac crapsab.nrinssac%TYPE) IS
        SELECT nmdsacad,
               cdtpinsc,
               nrinssac
          FROM crapsab
         WHERE crapsab.cdcooper = vr_cdcooper
           AND crapsab.nrdconta = pr_nrdconta
           AND crapsab.nrinssac = pr_nrinssac;
      rw_crapsab cr_crapsab%ROWTYPE;

      CURSOR cr_crapldc IS
        SELECT 0 AS flgsaldo_novo,
               ldc.cddlinha,
               ldc.tpdescto,
               ldc.flgsaldo
        FROM   crapldc ldc
        WHERE  ldc.tpdescto = 3
        AND    ldc.cdcooper = vr_cdcooper
        AND    flgsaldo = 1
        AND    NOT EXISTS(SELECT 1 FROM craplim lim WHERE insitlim IN (2,4) AND lim.cddlinha = ldc.cddlinha AND lim.tpctrlim = 3)
        UNION
        SELECT 1 AS flgsaldo_novo,
              ldc.cddlinha,
              ldc.tpdescto,
              ldc.flgsaldo
        FROM   crapldc ldc
        WHERE  ldc.tpdescto = 3
        AND    ldc.cdcooper = vr_cdcooper
        AND    flgsaldo = 0
        AND    EXISTS(SELECT 1 FROM craplim lim WHERE insitlim IN (2,4) AND lim.cddlinha = ldc.cddlinha AND lim.tpctrlim = 3);
      rw_crapldc cr_crapldc%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      -- Registro de limites das contas
      TYPE typ_reg_limite IS
        RECORD(insitlim craplim.insitlim%TYPE
              ,nrdconta craplim.nrdconta%TYPE
              ,nrctrlim craplim.nrctrlim%TYPE
              ,dtinivig craplim.dtinivig%TYPE
              ,dsqtdren VARCHAR2(50)
              ,qtdiavig craplim.qtdiavig%TYPE
              ,dtfimvig craplim.dtfimvig%TYPE
              ,vllimite craplim.vllimite%TYPE
              ,qtborati PLS_INTEGER);
      TYPE typ_tab_limite IS
        TABLE OF typ_reg_limite
          INDEX BY VARCHAR2(31);   --insitlim(05), nrdconta(10), nrctrlim(10), sequencial(6)
      TYPE typ_tab_titulos IS TABLE OF paga0001.typ_reg_titulos INDEX BY VARCHAR2(41);

      -- Registro de associados
      TYPE typ_reg_crapass IS
        RECORD(nrdconta crapass.nrdconta%TYPE,
               inpessoa crapass.inpessoa%TYPE,
               cdagenci crapass.cdagenci%TYPE,
               nmprimtl crapass.nmprimtl%TYPE);
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY PLS_INTEGER;

      ------------------------------- VARIAVEIS -------------------------------

      -- Variaveis para geracao de relatorio
      vr_texto_completo VARCHAR2(32600);             --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml      CLOB;                          --> XML do relatorio
      vr_nmarqimp     VARCHAR2(50);                  --> Nome do arquivo que sera gerado
      vr_nom_direto   VARCHAR2(100);                 --> Nome do diretorio para a geracao do arquivo de saida

      -- Variaveis utilizadas nos relatorios
      vr_dstitulo    VARCHAR2(50);                   --> Titulo do relatorio
      vr_dstitulo2   VARCHAR2(50);                   --> Titulo do relatorio
      vr_dstitulo3   VARCHAR2(50);                   --> Titulo do relatorio
      vr_dstitulo4   VARCHAR2(50);                   --> Titulo do relatorio

      -- Variaveis gerais
      vr_tt_erro     GENE0001.typ_tab_erro;          --> Registro com o retorno de erros das rotinas chamadas
      vr_cdhistor    crapfvl.cdhistor%TYPE;          --> Historico do lancamento
      --vr_cdhistor_pf crapfvl.cdhistor%TYPE;          --> Historico do lancamento pessoa fisica
      --vr_cdhistor_pj crapfvl.cdhistor%TYPE;          --> Historico do lancamento pessoa juridica
      vr_cdhisest    crapfvl.cdhisest%TYPE;          --> Codigo do historico do estouro
      --vr_vltarrnv    crapfco.vltarifa%TYPE;          --> Valor da tarifa
      --vr_vltarifa_pf crapfco.vltarifa%TYPE;          --> Valor da tarifa para pessoa fisica
      --vr_vltarifa_pj crapfco.vltarifa%TYPE;          --> Valor da tarifa para pessoa juridica
      vr_dtdivulg    DATE;                           --> Data de divulgacao da tarifa
      vr_dtvigenc    DATE;                           --> Data de vigencia da tarifa
      vr_cdfvlcop    crapfco.cdfvlcop%TYPE;          --> Codigo da faixa de valor por cooperativa
      --vr_cdfvlcop_pf crapfco.cdfvlcop%TYPE;          --> Codigo da faixa de valor por cooperativa para pessoa fisica
      --vr_cdfvlcop_pj crapfco.cdfvlcop%TYPE;          --> Codigo da faixa de valor por cooperativa para pessoa juridica
      vr_qtborati    PLS_INTEGER;                    --> Quantidade de borderos atvos
      vr_flgregis    BOOLEAN;                        --> Flag que indica se deve criar registro na temp-table vr_tab_limite
      --vr_inpessoa    crapass.inpessoa%TYPE;          --> Indicador de pessoa fisica / juridica
      --vr_rowid_craplat ROWID;                        --> Rowid da tabela craplat
      vr_inusatab    BOOLEAN;                        --> Indicador se existe tabela de taxa de juros
      vr_des_reto    VARCHAR2(10);                   --> Retorno OK ou NOK de rotina
      vr_tab_limite  typ_tab_limite;                 --> Tabela de limite de credito
      vr_ind         VARCHAR2(31);                   --> Indice da pl/table vr_tab_limite (insitlim(05), nrdconta(10), nrctrlim(10), sequencial(6)
      vr_seq         PLS_INTEGER := 0;               --> Sequencial do indice vr_ind
      --vr_dtdiauti    DATE;                           --> Dia util anterior a 31/12
      vr_dtrefere    DATE;                           --> Data de referencia de vencimento do titulo
      vr_tab_titulos paga0001.typ_tab_titulos;       --> Temp-table dos registros de titulos
      vr_ind_tit     VARCHAR2(20);                   --> Indice da temp-table vr_tab_titulos (nrdconta(10), sequencial(10))
      --vr_seq_tit     PLS_INTEGER := 0;               --> Sequencial do indice vr_ind_tit
      vr_tab_titulos_rel typ_tab_titulos;            --> Temp-table dos registros de titulos utilizada no relatorio com outro ordenador
      vr_ind_rel     VARCHAR2(41);                   --> Indice da pl/table vr_tab_limite (cdagenci(05) nrdconta(10), nrborder(10), nrdocmto(10), sequencial(06))
      vr_seq_rel     PLS_INTEGER := 0;               --> Sequencial do indice vr_ind
      vr_tab_crapass typ_tab_crapass;                --> Temp-table dos associados
      vr_nossonum    VARCHAR2(50);                   --> Campo contendo a informacao do "nosso numero"
      vr_nmdsacad    crapsab.nmdsacad%TYPE;          --> Nome do sacado
      vr_nrcpfcgc    VARCHAR2(20);                   --> Numero do CPF / CNPJ
      vr_desprazo    VARCHAR2(10);                   --> Descricao da quantidade de dias para o vencimento
      vr_dstipcob    VARCHAR2(10);                   --> Tipo de cobranca
      vr_email_tarif VARCHAR2(300);                  --> Email da area de taifa.
      vr_flvencid    BOOLEAN;                        --> Verificar se o contrato está vencido pela data final da vigencia
      vr_habrat      VARCHAR2(1) := 'N';                  --> P450 - Paramentro para Habilitar Novo Ratin (S/N)

      --------------------------- SUBROTINAS INTERNAS --------------------------
      -- Retorna a data anterior a data de ontem que seja dia util
      FUNCTION fn_calcula_data RETURN DATE IS
        vr_dtrefere DATE;
      BEGIN
       /* Pega o ultimo dia util antes de ontem */
       vr_dtrefere := rw_crapdat.dtmvtoan - 1;

       -- Verifica se a data de antes de ontem eh util
       vr_dtrefere := gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper,
                                                  pr_dtmvtolt => vr_dtrefere,
                                                  pr_tipo => 'A');

       /* Se teve fim de semana ou feriado antes de ontem */
       IF rw_crapdat.dtmvtoan - vr_dtrefere > 1   THEN
         RETURN vr_dtrefere;
       ELSE
         RETURN rw_crapdat.dtmvtoan;
       END IF;

      END;

    --> Rotina para cobrança das tarifas de renovação de contrato
   PROCEDURE pc_gera_tarifa_renova(pr_cdcooper crapcop.cdcooper%type
                                  ,pr_crapdat  btch0001.cr_crapdat%rowtype
                                  ) is
      cursor cr_craplim_tari is
      select ass.inpessoa
            ,ass.nrdconta
            ,lim.nrctrlim
            ,lim.vllimite
      from   craplim lim
            ,crapass ass
      where  lim.cdcooper = ass.cdcooper
      and    lim.nrdconta = ass.nrdconta
      and    lim.cdcooper = pr_cdcooper
      and    lim.tpctrlim = 3
      and    lim.insitlim = 2 -- Ativo
      and    lim.dtrenova = pr_crapdat.dtmvtolt
      and    lim.tprenova = 'A'
      and    lim.qtrenova > 0;

      --> Critica
      vr_cdcritic pls_integer;
      vr_dscritic varchar2(4000);
      vr_tab_erro gene0001.typ_tab_erro;

      -- Variaveis de tarifa
      vr_cdhistor craphis.cdhistor%type;
      vr_cdhisest craphis.cdhistor%type;
      vr_dtdivulg date;
      vr_dtvigenc date;
      vr_cdfvlcop crapfco.cdfvlcop%type;
      vr_vltarifa crapfco.vltarifa%type;
      vr_cdbattar varchar2(10);
      vr_rowid         rowid;
      vr_email_tarif VARCHAR2(300); --> Email da area de taifa.

   BEGIN
      --> buscar os limites renovados hj para cobrança de Tarifa
      for rw_craplim_tari in cr_craplim_tari loop
          --  1 - Pessoa Fisica
          if  rw_craplim_tari.inpessoa = 1 then
              vr_cdbattar := 'DSTRENOVPF'; -- Renovacao contrato pessoa fisica
          else
              vr_cdbattar := 'DSTRENOVPJ'; -- Renovacao contrato pessoa juridica
          end if;

          -- Busca valor da tarifa
          tari0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                               ,pr_cdbattar => vr_cdbattar
                                               ,pr_vllanmto => rw_craplim_tari.vllimite
                                               ,pr_cdprogra => vr_cdprogra
                                               ,pr_cdhistor => vr_cdhistor
                                               ,pr_cdhisest => vr_cdhisest
                                               ,pr_vltarifa => vr_vltarifa
                                               ,pr_dtdivulg => vr_dtdivulg
                                               ,pr_dtvigenc => vr_dtvigenc
                                               ,pr_cdfvlcop => vr_cdfvlcop
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic
                                               ,pr_tab_erro => vr_tab_erro);

          -- Incluir nome do módulo logado - Chamado 660306 29/06/2017
          gene0001.pc_set_modulo(pr_module => vr_nmdatela
                                ,pr_action => vr_acao);

          --  Se ocorreu erro
          if  vr_cdcritic is not null or trim(vr_dscritic) is not null then
              --  Se possui erro no vetor
              if  vr_tab_erro.count() > 0 then
                  vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
                  vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
              else
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
              end if;

              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || vr_dscritic || ' - ' || vr_cdbattar);
              -- Efetua Limpeza das variaveis de critica
              --vr_cdcritic := 0;
              --vr_dscritic := null;

              if  vr_email_tarif is null then
                  vr_email_tarif := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                             ,pr_cdcooper => pr_cdcooper
                                                             ,pr_cdacesso => 'EMAIL_TARIF');
              end if;

              pc_email_critica(pr_cdcooper    => pr_cdcooper
                              ,pr_cdprogra    => vr_cdprogra
                              ,pr_email_dest  => vr_email_tarif
                              ,pr_des_assunto => 'Erros log de tarifas ('||rw_crapcop.nmrescop ||')'
                              ,pr_des_corpo   => to_char(SYSDATE,'HH24:MI:SS') ||' - '||
                                                 vr_cdprogra ||' --> '|| vr_dscritic || ' - '||vr_cdbattar);

              -- Se não Existe Tarifa
              continue;
          end if;

          --  Verifica se valor da tarifa esta zerado
          if  vr_vltarifa = 0 then
              continue;
          end if;

          -- Criar Lançamento automatico Tarifas de contrato de desconto de titulo
          tari0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                          , pr_nrdconta     => rw_craplim_tari.nrdconta
                                          , pr_dtmvtolt     => pr_crapdat.dtmvtolt
                                          , pr_cdhistor     => vr_cdhistor
                                          , pr_vllanaut     => vr_vltarifa
                                          , pr_cdoperad     => vr_cdoperad
                                          , pr_cdagenci     => 1
                                          , pr_cdbccxlt     => 100
                                          , pr_nrdolote     => 10300
                                          , pr_tpdolote     => 1
                                          , pr_nrdocmto     => 0
                                          , pr_nrdctabb     => rw_craplim_tari.nrdconta
                                          , pr_nrdctitg     => gene0002.fn_mask(rw_craplim_tari.nrdconta,'99999999')
                                          , pr_cdpesqbb     => 'Fato gerador tarifa:' || to_char(rw_craplim_tari.nrctrlim)
                                          , pr_cdbanchq     => 0
                                          , pr_cdagechq     => 0
                                          , pr_nrctachq     => 0
                                          , pr_flgaviso     => false
                                          , pr_tpdaviso     => 0
                                          , pr_cdfvlcop     => vr_cdfvlcop
                                          , pr_inproces     => pr_crapdat.inproces
                                          , pr_rowid_craplat=> vr_rowid
                                          , pr_tab_erro     => vr_tab_erro
                                          , pr_cdcritic     => vr_cdcritic
                                          , pr_dscritic     => vr_dscritic);

          -- Incluir nome do módulo logado - Chamado 660306 29/06/2017
          GENE0001.pc_set_modulo(pr_module => vr_nmdatela
                                ,pr_action => vr_acao);

          --  Se ocorreu erro
          if  vr_cdcritic is not null or trim(vr_dscritic) is not null then
              --  Se possui erro no vetor
              if  vr_tab_erro.count > 0 then
                  --vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
                  vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
              else
                  --vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro no lancamento Tarifa de contrato de limite de desconto de titulo';
              end if;

              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> '||
                                                            gene0002.fn_mask_conta(rw_craplim_tari.nrdconta)||'- '|| vr_dscritic );

              vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra ||
                                     ' --> ERRO: ' ||vr_dscritic ||
                                     ' pr_cdcooper=' || pr_cdcooper ||
                                     ' ,pr_nrdconta=' || rw_craplim_tari.nrdconta ||
                                     ' ,pr_dtmvtolt=' || pr_crapdat.dtmvtolt ||
                                     ' ,pr_cdhistor=' || vr_cdhistor ||
                                     ' ,pr_vllanaut=' || vr_vltarifa ||
                                     ' ,pr_cdoperad=' || vr_cdoperad ||
                                     ' ,pr_nrdctabb=' || rw_craplim_tari.nrdconta ||
                                     ' ,pr_nrdctitg=' || to_char(rw_craplim_tari.nrdconta,'fm00000000') ||
                                     ' ,pr_cdpesqbb=' || TO_CHAR(rw_craplim_tari.nrctrlim) ||
                                     ' ,pr_cdfvlcop=' || vr_cdfvlcop ||
                                     ' ,pr_inproces=' || pr_crapdat.inproces ||
                                     ' ,pr_rowid_craplat=' || vr_rowid ||
                                     ' - Module: ' || vr_nmdatela ||
                                     ' - Action: ' || vr_acao;

              -- Colocado Log no padrão - 29/06/2017 - Chamado 660306
              -- Envio centralizado de log de erro
              cecred.pc_log_programa(pr_dstiplog      => 'O',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                                     pr_cdprograma    => vr_nmdatela,  -- tbgen_prglog
                                     pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                                     pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                     pr_tpocorrencia  => 1,            -- tbgen_prglog_ocorrencia -- 1 ERRO TRATADO
                                     pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 -- Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                     pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                                     pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 -- Indicador de sucesso da execução
                                     pr_nmarqlog      => NULL,
                                     pr_idprglog      => vr_idprglog
                                     );
              -- Limpa valores das variaveis de critica
              vr_cdcritic:= 0;
              vr_dscritic:= null;
          end if;
      end loop;

   EXCEPTION
      when others then
           vr_dscritic:= 'Não foi possivel gerar tarifa de renovação: '||sqlerrm;
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '|| vr_dscritic );
           -- Limpa valores das variaveis de critica
           --vr_cdcritic:= 0;
           --vr_dscritic:= null;
   END pc_gera_tarifa_renova;

      --------------- VALIDACOES INICIAIS -----------------
    BEGIN
      -- extrai dados do XML (para uso Ayllos WEB)
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => vr_cdcooper,
                                             pr_cdacesso => 'HABILITA_RATING_NOVO');

      -- Incluir nome do módulo logado - Chamado 660306 29/06/2017
      GENE0001.pc_set_modulo(pr_module => NVL(trim(vr_nmdatela),vr_cdprogra), pr_action => vr_acao);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Carrega a temp-table de associados
      FOR rw_crapass IN cr_crapass LOOP
        vr_tab_crapass(rw_crapass.nrdconta).nrdconta := rw_crapass.nrdconta;
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
      END LOOP;

      -- Leitura do indicador de uso da tabela de taxa de juros
      rw_craptab := NULL;
      OPEN cr_craptab(pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'TAXATABELA'
                     ,pr_tpregist => 0);
      FETCH cr_craptab INTO rw_craptab;
      -- Se encontrar
      IF cr_craptab%FOUND THEN
        -- Se a primeira posição do campo
        -- dstextab for diferente de zero
        IF SUBSTR(rw_craptab.dstextab,1,1) != '0' THEN
          -- É porque existe tabela parametrizada
          vr_inusatab := TRUE;
        ELSE
          -- Não existe
          vr_inusatab := FALSE;
        END IF;
      ELSE
        -- Não existe
        vr_inusatab := FALSE;
      END IF;
      CLOSE cr_craptab;

      /** Leitura dos limites de desconto de titulos **/
      FOR rw_craplim IN cr_craplim LOOP
        vr_qtborati := 0;
        vr_flgregis := TRUE;
        vr_flvencid := FALSE;

        IF (rw_craplim.dtfimvig + 60) < rw_crapdat.dtmvtolt THEN
          vr_flvencid := TRUE;
        END IF;

        /** Se nao atingiu limite de renovacoes, renovar limites ativos **/
        IF  rw_craplim.qtrenova < rw_craplim.qtmaxren AND rw_craplim.insitlim = 2 AND vr_flvencid = FALSE THEN

          pc_renova_limdesctit(pr_cdcooper => vr_cdcooper
                              ,pr_nrdconta => rw_craplim.nrdconta
                              ,pr_nrctrlim => rw_craplim.nrctrlim
                              ,pr_tpctrlim => rw_craplim.tpctrlim
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

          if  vr_dscritic is not null then
              raise vr_exc_saida;
          end if;

        ELSE
           /** Verifica quantidade de borderos pendente **/
          OPEN cr_crapbdt(rw_craplim.nrdconta, rw_craplim.nrctrlim);
          FETCH cr_crapbdt INTO vr_qtborati;
          CLOSE  cr_crapbdt;

          /** Altera flag para nao criar registro na temp-table vr_tab_limite **/
          IF rw_craplim.insitlim = 4  THEN
            vr_flgregis := FALSE;
          END IF;

          /** Se foi encontrado um bordero pendente para o limite **/
          IF vr_qtborati > 0 THEN
            IF rw_craplim.insitlim <> 4  THEN
              rw_craplim.insitlim := 4; /** Vigente **/
            END IF;
          ELSE
            rw_craplim.insitlim := 3; /** Cancelado **/
            rw_craplim.dtcancel := rw_crapdat.dtmvtolt;

            /* para rating novo, manter o rating atual senão desativar */
            IF (vr_cdcooper <> 3 AND vr_habrat = 'S') THEN          
              -- Chama rotina para desativar o rating
              rati0001.pc_desativa_rating(pr_cdcooper => vr_cdcooper,
                                          pr_cdagenci => 0,
                                          pr_nrdcaixa => 0,
                                          pr_cdoperad => vr_cdoperad,
                                          pr_rw_crapdat => rw_crapdat,
                                          pr_nrdconta => rw_craplim.nrdconta,
                                          pr_tpctrrat => rw_craplim.tpctrlim,
                                          pr_nrctrrat => rw_craplim.nrctrlim,
                                          pr_flgefeti => 'S',
                                          pr_idseqttl => 1,
                                          pr_idorigem => 1,
                                          pr_inusatab => vr_inusatab,
                                          pr_nmdatela => 'crps517',
                                          pr_flgerlog => 'S',
                                          pr_des_reto => vr_des_reto,
                                          pr_tab_erro => vr_tt_erro);

              -- Incluir nome do módulo logado - Chamado 660306 29/06/2017
              GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => vr_acao);

              -- Verifica se ocorreu erro
              IF vr_des_reto = 'NOK' THEN
                -- Tenta buscar o erro no vetor de erro
                IF vr_tt_erro.COUNT > 0 THEN
                  vr_cdcritic := vr_tt_erro(vr_tt_erro.FIRST).cdcritic;
                  vr_dscritic := vr_tt_erro(vr_tt_erro.FIRST).dscritic;
                ELSE
                  pr_dscritic := 'Retorno "NOK" na rati0001.pc_desativa_rating e pr_vet_erro vazia! Conta: '||rw_craplim.nrdconta;
                END IF;

                -- Se foi retornado apenas código
                IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
                  -- Buscar a descrição
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                ELSIF vr_cdcritic = 9999 AND vr_dscritic IS NOT NULL THEN
                  -- Buscar a descrição
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || vr_dscritic;

                END IF;

                vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra ||
                                       ' --> ' ||
                                       'ERRO: ' ||
                                       vr_dscritic ||
                                       ' pr_cdcooper=' || vr_cdcooper ||
                                       ' ,cdoperad=' || vr_cdoperad ||
                                       ' ,nrdconta=' || rw_craplim.nrdconta ||
                                       ' ,tpctrrat=' || rw_craplim.tpctrlim ||
                                       ' ,nrctrrat=' || rw_craplim.nrctrlim ||
                                       ' ,inusatab=' || sys.diutil.bool_to_int ( vr_inusatab ) ||
                                       ' - Module: ' || vr_nmdatela ||
                                       ' - Action: ' || vr_acao;

                -- Colocado Log no padrão - 29/06/2017 - Chamado 660306
                -- Envio centralizado de log de erro
                cecred.pc_log_programa(pr_dstiplog      => 'O',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                                       pr_cdprograma    => vr_nmdatela,  -- tbgen_prglog
                                       pr_cdcooper      => vr_cdcooper,  -- tbgen_prglog
                                       pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                       pr_tpocorrencia  => 1,            -- tbgen_prglog_ocorrencia -- 1 ERRO TRATADO
                                       pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 -- Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                       pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                                       pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 -- Indicador de sucesso da execução
                                       pr_nmarqlog      => NULL,
                                       pr_idprglog      => vr_idprglog
                                       );
                vr_dscritic := NULL;
                vr_cdcritic := 0;
              END IF;
            END IF;

          END IF;

          -- Atualiza a situacao e a data de cancelamento do limite de credito
          BEGIN
            UPDATE craplim
               SET insitlim = rw_craplim.insitlim,
                   dtcancel = rw_craplim.dtcancel
             WHERE ROWID = rw_craplim.rowid;

             -- Caso tenha sido cancelado o contrato, cancela as propostas de limite
             IF rw_craplim.insitlim = 3 THEN
               UPDATE crawlim
                 SET insitlim = 3
               WHERE cdcooper = vr_cdcooper
                 AND nrdconta = rw_craplim.nrdconta
                 AND tpctrlim = 3
                 AND nrctrlim = rw_craplim.nrctrlim;

               UPDATE crawlim
                 SET insitlim = 3
               WHERE cdcooper = vr_cdcooper
                 AND nrdconta = rw_craplim.nrdconta
                 AND tpctrlim = 3
                 AND nrctrmnt = rw_craplim.nrctrlim;
             END IF;
          EXCEPTION
            WHEN OTHERS THEN
              -- Colocado Log no padrão - 29/06/2017 - Chamado 660306
              CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);

              vr_dscritic := '2-Erro ao alterar CRAPLIM: ' ||SQLERRM;
              RAISE vr_exc_saida;
          END;

          IF vr_flgregis THEN
            -- Gerar histórico de cancelamento automática ou vigencia do contrato.
            cecred.tela_atenda_dscto_tit.pc_gravar_hist_alt_limite(pr_cdcooper => vr_cdcooper
                                                                  ,pr_nrdconta => rw_craplim.nrdconta
                                                                  ,pr_nrctrlim => rw_craplim.nrctrlim
                                                                  ,pr_tpctrlim => 3 -- Limite Desconto Titulo
                                                                  ,pr_dsmotivo => CASE WHEN rw_craplim.insitlim = 4 THEN
                                                                                            'VIGÊNCIA AUTOMÁTICA'
                                                                                       ELSE 'CANCELAMENTO AUTOMÁTICO'
                                                                                  END
                                                                  ,pr_cdcritic => vr_cdcritic
                                                                  ,pr_dscritic => vr_dscritic );

            IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        END IF;

        -- Verifica se a conta deve ser gerada no relatorio
        IF vr_flgregis THEN
          -- Monta o indice da vr_tab_limite
          vr_seq := vr_seq + 1;
          vr_ind := lpad(rw_craplim.insitlim,5,'0') ||lpad(rw_craplim.nrdconta,10,'0')||
                    lpad(rw_craplim.nrctrlim,10,'0')||lpad(vr_seq_rel,6,'0');

          -- Popula a temp/table de limites
          vr_tab_limite(vr_ind).insitlim := rw_craplim.insitlim;
          vr_tab_limite(vr_ind).nrdconta := rw_craplim.nrdconta;
          vr_tab_limite(vr_ind).nrctrlim := rw_craplim.nrctrlim;
          vr_tab_limite(vr_ind).dtinivig := rw_craplim.dtinivig;
          vr_tab_limite(vr_ind).dsqtdren := rw_craplim.qtrenova || ' de ' || rw_craplim.qtrenctr;
          vr_tab_limite(vr_ind).qtdiavig := rw_craplim.qtdiavig;
          vr_tab_limite(vr_ind).dtfimvig := rw_craplim.dtfimvig;
          vr_tab_limite(vr_ind).vllimite := rw_craplim.vllimite;
          vr_tab_limite(vr_ind).qtborati := vr_qtborati;
        END IF;

      END LOOP;

      --> Rotina para cobrança das tarifas de renovação de contrato
      pc_gera_tarifa_renova(pr_cdcooper => vr_cdcooper
                           ,pr_crapdat  => rw_crapdat);

      -- Atualização do saldo das linhas de desconto
      FOR rw_crapldc IN cr_crapldc LOOP
        BEGIN
          UPDATE crapldc
          SET    flgsaldo = rw_crapldc.flgsaldo_novo
          WHERE  tpdescto = rw_crapldc.tpdescto
          AND    cddlinha = rw_crapldc.cddlinha
          AND    cdcooper = vr_cdcooper;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);

            vr_dscritic := '2-Erro ao alterar CRAPLDC: ' ||SQLERRM;
            RAISE vr_exc_saida;
          END;
      END LOOP;

      ------------------------
      ------------------------ GERACAO DO RELATORIO CRRL492
      ------------------------

      -- Define o nome do relatorio
      vr_nmarqimp := '/crrl492.lst';

      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => 'rl');

      -- Inicializar o CLOB
      vr_des_xml := NULL;
      vr_texto_completo := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicializa o XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                  '<?xml version="1.0" encoding="utf-8"?><crrl492>');

      -- Inicializa o indice da temp/table vr_tab_limite
      vr_ind := vr_tab_limite.first;

      /** Mostrar limites renovados, cancelados ou vigentes no relatorio **/
      WHILE vr_ind IS NOT NULL LOOP

        -- Se for o primeiro registro ou a situacao de limite for diferente da anterior
        IF vr_ind = vr_tab_limite.first OR
           vr_tab_limite(vr_ind).insitlim <> vr_tab_limite(vr_tab_limite.prior(vr_ind)).insitlim THEN
          vr_qtborati := NULL;
          IF vr_tab_limite(vr_ind).insitlim = 2 THEN -- Renovado
            vr_dstitulo := 'CONTRATOS RENOVADOS AUTOMATICAMENTE';
            vr_dstitulo2 := NULL;
            vr_dstitulo3 := NULL;
            vr_dstitulo4 := 'Nova Vigencia';
          ELSIF vr_tab_limite(vr_ind).insitlim = 3 THEN -- Cancelado
            vr_dstitulo := 'CONTRATOS CANCELADOS AUTOMATICAMENTE';
            vr_dstitulo2 := NULL;
            vr_dstitulo3 := NULL;
            vr_dstitulo4 := 'Fim Vigencia';
          ELSIF vr_tab_limite(vr_ind).insitlim = 4 THEN -- Vencidos
            vr_dstitulo := 'CONTRATOS VENCIDOS NO DIA COM BORDEROS ATIVOS';
            vr_dstitulo2 := 'Borderos Ativos';
            vr_dstitulo3 := '---------------';
            vr_dstitulo4 := 'Fim Vigencia';
            vr_qtborati := vr_tab_limite(vr_ind).qtborati;
          END IF;
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
              '<cabecalho>'||
                '<dstitulo>'||vr_dstitulo||'</dstitulo>'||
                '<dstitulo2>'||vr_dstitulo2||'</dstitulo2>'||
                '<dstitulo3>'||vr_dstitulo3||'</dstitulo3>'||
                '<dstitulo4>'||vr_dstitulo4||'</dstitulo4>');
        END IF;

        -- Escreve a linha de detalhe
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
          '<conta>'||
            '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_limite(vr_ind).nrdconta)    ||'</nrdconta>'||
            '<nrctrlim>'||to_char(vr_tab_limite(vr_ind).nrctrlim,'fm9G999G990')     ||'</nrctrlim>'||
            '<dtinivig>'||to_char(vr_tab_limite(vr_ind).dtinivig,'dd/mm/yyyy')      ||'</dtinivig>'||
            '<dsqtdren>'||vr_tab_limite(vr_ind).dsqtdren                            ||'</dsqtdren>'||
            '<qtdiavig>'||vr_tab_limite(vr_ind).qtdiavig                            ||'</qtdiavig>'||
            '<dtfimvig>'||to_char(vr_tab_limite(vr_ind).dtfimvig,'dd/mm/yyyy')      ||'</dtfimvig>'||
            '<vllimite>'||to_char(vr_tab_limite(vr_ind).vllimite,'fm999G999G990D00')||'</vllimite>'||
            '<qtborati>'||vr_qtborati                                               ||'</qtborati>'||
          '</conta>');

        -- Se for o ultimo registro ou a situacao de limite for diferente da proxima
        IF vr_ind = vr_tab_limite.last OR
           vr_tab_limite(vr_ind).insitlim <> vr_tab_limite(vr_tab_limite.next(vr_ind)).insitlim THEN
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
              '</cabecalho>');
        END IF;

        -- Vai para o proximo registro
        vr_ind := vr_tab_limite.next(vr_ind);

      END LOOP;

      -- Verifica se a tabela estava vazia. Neste caso da mensagem que nao existe limite de desconto
      IF vr_tab_limite.first IS NULL THEN
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
            '<cabecalho>'||
              '<dstitulo>*** NENHUM LIMITE DE DESCONTO DE TITULO FOI RENOVADO OU CANCELADO NESSE DIA ***</dstitulo>'||
              '<dstitulo2></dstitulo2>'||
              '<conta></conta>'||
            '</cabecalho>');
      END IF;

      -- Finaliza o XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                  '</crrl492>',TRUE);

      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl492/cabecalho/conta',     --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl492.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_direto||vr_nmarqimp,     --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_nmformul  => '132col',                       --> Nome do formulario
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      ------------------------
      ------------------------ GERACAO DO RELATORIO CRRL497
      ------------------------

      -- move a temp/table vr_tab_titulos para vr_tab_titulos_rel
      vr_ind_tit := vr_tab_titulos.first;
      WHILE vr_ind_tit IS NOT NULL LOOP
        vr_seq_rel := vr_seq_rel + 1;
        vr_ind_rel := lpad(vr_tab_crapass(vr_tab_titulos(vr_ind_tit).nrdconta).cdagenci,5,'0')||
                      lpad(vr_tab_titulos(vr_ind_tit).nrdconta,10,'0')||lpad(vr_tab_titulos(vr_ind_tit).nrborder,10,'0')||
                      lpad(vr_tab_titulos(vr_ind_tit).nrdocmto,10,'0')||lpad(vr_seq_rel,6,'0');

        vr_tab_titulos_rel(vr_ind_rel) := vr_tab_titulos(vr_ind_tit);
        vr_ind_tit := vr_tab_titulos.next(vr_ind_tit);
      END LOOP;

      vr_ind_rel := vr_tab_titulos_rel.first;

      WHILE vr_ind_rel IS NOT NULL LOOP

        -- Se for o primeiro registro ou se a agencia atual for diferente da agencia anterior
        IF vr_ind_rel = vr_tab_titulos_rel.first OR
           vr_tab_crapass(vr_tab_titulos_rel(vr_ind_rel).nrdconta).cdagenci <> vr_tab_crapass(vr_tab_titulos_rel(vr_tab_titulos_rel.prior(vr_ind_rel)).nrdconta).cdagenci THEN

          -- Inicializar o CLOB
          vr_des_xml := NULL;
          vr_texto_completo := NULL;
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

          -- Inicializa o XML
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                      '<?xml version="1.0" encoding="utf-8"?><crrl497>');

          -- Define o nome do arquivo
          vr_nmarqimp := '/crrl497_'||to_char(vr_tab_crapass(vr_tab_titulos_rel(vr_ind_rel).nrdconta).cdagenci,'fm000')||'.lst';

        END IF;

        -- Se for o primeiro registro ou se o bordero atual for diferente do bordero anterior
        IF vr_ind_rel = vr_tab_titulos_rel.first OR
           vr_tab_titulos_rel(vr_ind_rel).nrborder <> vr_tab_titulos_rel(vr_tab_titulos_rel.prior(vr_ind_rel)).nrborder THEN

          -- Escreve o nó de bordero
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
              '<bordero>'||
                '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_titulos_rel(vr_ind_rel).nrdconta) ||'</nrdconta>'||
                '<nmprimtl>'||substr(vr_tab_crapass(vr_tab_titulos_rel(vr_ind_rel).nrdconta).nmprimtl,1,40)||'</nmprimtl>'||
                '<nrborder>'||to_char(vr_tab_titulos_rel(vr_ind_rel).nrborder,'fm9G999G990')  ||'</nrborder>');
        END IF;

        vr_nossonum := NULL;

        -- Cursor sobre os parametros do cadastro de cobranca
        OPEN cr_crapcco(vr_tab_titulos_rel(vr_ind_rel).nrcnvcob);
        FETCH cr_crapcco INTO rw_crapcco;

        IF cr_crapcco%FOUND THEN
          IF rw_crapcco.flgregis = 1 AND -- Se contem a situacao da cobranca registrada
             rw_crapcco.cddbanco = 085 THEN
            vr_nossonum := to_char(vr_tab_titulos_rel(vr_ind_rel).nrdconta, 'fm00000000') ||
                           to_char(vr_tab_titulos_rel(vr_ind_rel).nrdocmto, 'fm000000000');
          ELSIF rw_crapcco.flgutceb = 1 THEN -- Se utiliza sequencia CADCEB.
            OPEN cr_crapceb(vr_tab_titulos_rel(vr_ind_rel).nrdconta,
                            vr_tab_titulos_rel(vr_ind_rel).nrcnvcob);
            -- Busca a sequencia CADCEB
            FETCH cr_crapceb INTO rw_crapceb;
            IF cr_crapceb%FOUND THEN
              vr_nossonum := to_char(vr_tab_titulos_rel(vr_ind_rel).nrcnvcob,'fm0000000') ||
                             to_char(rw_crapceb.nrcnvceb,'fm0000') ||
                             to_char(vr_tab_titulos_rel(vr_ind_rel).nrdocmto,'fm000000');
            END IF;
            CLOSE cr_crapceb;
          ELSE -- utiliza apenas a conta e o documento como NOSSO NUMERO
            vr_nossonum := to_char(vr_tab_titulos_rel(vr_ind_rel).nrdconta,'fm00000000') ||
                           to_char(vr_tab_titulos_rel(vr_ind_rel).nrdocmto,'fm000000000');
          END IF;
        END IF; -- cr_crapcco%FOUND
        CLOSE cr_crapcco;

        -- Busca os dados do cadastro de sacados
        OPEN cr_crapsab(vr_tab_titulos_rel(vr_ind_rel).nrdconta, vr_tab_titulos_rel(vr_ind_rel).nrinssac);
        FETCH cr_crapsab INTO rw_crapsab;

        -- Se enocontrou dados de sacado
        IF cr_crapsab%FOUND THEN
          vr_nmdsacad := rw_crapsab.nmdsacad;

          IF rw_crapsab.cdtpinsc = 1  THEN  /** Pessoa Fisica **/
            vr_nrcpfcgc := gene0002.fn_mask(lpad(rw_crapsab.nrinssac,11,'0'),'999.999.999-99');
          ELSIF rw_crapsab.cdtpinsc = 2  THEN  /** Pessoa Juridica **/
            vr_nrcpfcgc := gene0002.fn_mask(lpad(rw_crapsab.nrinssac,14,'0'),'99.999.999/9999-99');
          END IF;
        ELSE
          -- joga vazio para o nome do sacado e o cpf/cnpj
          vr_nmdsacad := NULL;
          vr_nrcpfcgc := NULL;
        END IF;
        CLOSE cr_crapsab;

        vr_desprazo := to_char(vr_tab_titulos_rel(vr_ind_rel).dtvencto -
                               vr_tab_titulos_rel(vr_ind_rel).dtlibbdt) || ' dias';

        IF nvl(rw_crapcco.flgregis,1) = 1 THEN -- Se contem a situacao da cobranca registrada
          vr_dstipcob := 'C/Registro';
        ELSE
          vr_dstipcob := 'S/Registro';
        END IF;

        -- Escreve o nó do titulo
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
            '<titulo>'||
              '<dtvencto>'||to_char(vr_tab_titulos_rel(vr_ind_rel).dtvencto,'dd/mm/yyyy')      ||'</dtvencto>'||
              '<nossonum>'||vr_nossonum                                                        ||'</nossonum>'||
              '<dstipcob>'||vr_dstipcob                                                        ||'</dstipcob>'||
              '<vltitulo>'||to_char(vr_tab_titulos_rel(vr_ind_rel).vltitulo,'fm999G999G990D00')||'</vltitulo>'||
              '<vlliquid>'||to_char(vr_tab_titulos_rel(vr_ind_rel).vlliquid,'fm999G999G990D00')||'</vlliquid>'||
              '<desprazo>'||vr_desprazo                                                        ||'</desprazo>'||
              '<nmdsacad>'||substr(replace(replace(vr_nmdsacad,'&',' e '),'  '),1,30)                                           ||'</nmdsacad>'||
              '<nrcpfcgc>'||vr_nrcpfcgc                                                        ||'</nrcpfcgc>'||
            '</titulo>');

        -- Se for o ultimo registro ou se o bordero atual for diferente do proximo bordero
        IF vr_ind_rel = vr_tab_titulos_rel.last OR
           vr_tab_titulos_rel(vr_ind_rel).nrborder <> vr_tab_titulos_rel(vr_tab_titulos_rel.next(vr_ind_rel)).nrborder THEN

          -- Escreve o nó de fechamento do bordero
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
              '</bordero>');
        END IF;

        -- Se for o ultimo registro ou se a agencia atual for diferente da proxima agencia
        IF vr_ind_rel = vr_tab_titulos_rel.last OR
           vr_tab_crapass(vr_tab_titulos_rel(vr_ind_rel).nrdconta).cdagenci <> vr_tab_crapass(vr_tab_titulos_rel(vr_tab_titulos_rel.next(vr_ind_rel)).nrdconta).cdagenci THEN

          -- Escreve o nó de fechamento da agencia
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
              '</crrl497>',TRUE);

          -- Chamada do iReport para gerar o arquivo de saida
          gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper,                    --> Cooperativa conectada
                                      pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                      pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                      pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                      pr_dsxmlnode => '/crrl497/bordero/titulo',      --> No base do XML para leitura dos dados
                                      pr_dsjasper  => 'crrl497.jasper',               --> Arquivo de layout do iReport
                                      pr_dsparams  => NULL,                           --> Nao enviar parametro
                                      pr_dsarqsaid => vr_nom_direto||vr_nmarqimp,     --> Arquivo final
                                      pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                      pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                      pr_sqcabrel  => 2,                              --> Sequencia do cabecalho
                                      pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                      pr_nrcopias  => 1,                              --> Numero de copias
                                      pr_nmformul  => '132col',                       --> Nome do formulario
                                      pr_des_erro  => vr_dscritic);                   --> Saida com erro


          -- Verifica se ocorreu erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;

        -- Vai para o proximo registro
        vr_ind_rel := vr_tab_titulos_rel.next(vr_ind_rel);

      END LOOP;

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro><TpException>1</TpException></Root>');
      WHEN vr_exc_fimprg THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro><TpException>2</TpException></Root>');
      WHEN OTHERS THEN
        -- Colocado Log no padrão - 29/06/2017 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Falha em LIMI0002.pc_crps517, erro: ' || SQLERRM;

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      END;

  END pc_crps517;

  PROCEDURE pc_cancela_limite_inadim(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                               ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ............................................................................
     Programa: PC_CANCELA_LIMITE_INADIM
     Sistema : Atenda - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Daniel Silva(AMcom)
     Data    : Março/2018                           Ultima atualizacao: 15/03/2018

     Dados referentes ao programa:

     Frequencia: Diária
     Objetivo  : Cancelar limites de crédito para contas com atraso conforme parâmetro da cooperativa
     Alteracoes:
    ..............................................................................*/

  DECLARE
  --*** VARIÁVEIS ***--
    vr_exc_saida exception;
    vr_exc_fimprg exception;
    vr_cdcritic crapcri.cdcritic%TYPE; -- Codigo da critica
    vr_dscritic VARCHAR2(2000);        -- Descricao da critica
    --vr_inusatab BOOLEAN := FALSE;
    --vr_des_reto VARCHAR2(3);
    --vr_tab_erro GENE0001.typ_tab_erro;

    -- Cursor Genérico de Calendário
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- Calendário da cooperativa selecionada
    CURSOR cr_dat(pr_cdcooper INTEGER) IS
    SELECT dat.dtmvtolt
         , (SELECT MAX(dtrefere) FROM crapris WHERE cdcooper = pr_cdcooper) dtmvtoan
         , dat.dtultdma
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
    rw_dat cr_dat%ROWTYPE;

    -- Busca conta corrente que possui limite de crédito e está em ADP
    CURSOR cr_conta(pr_cdcooper INTEGER) IS
    SELECT DISTINCT ris.cdcooper, ris.nrdconta, ris.nrctremp, rlim.nrctremp nrctrlim
      FROM crapris ris, crapass ass
         , (SELECT r.cdcooper, r.nrdconta, r.nrctremp, r.dtrefere
              FROM crapris r
             WHERE r.cdcooper = pr_cdcooper
               AND r.dtrefere = rw_dat.dtmvtoan -- Buscar Central Atual **Antes de Rodar a Central de Risco
               AND r.cdmodali = 201) rlim -- Limite de crédito
     WHERE rlim.cdcooper = ris.cdcooper
       AND rlim.nrdconta = ris.nrdconta
       AND rlim.dtrefere = ris.dtrefere
       AND ris.cdcooper  = ass.cdcooper
       AND ris.nrdconta  = ass.nrdconta
       AND ass.flcnaulc  = 1 -- Cancelamento automatico do Limite de Crédito igual 'Sim'
       AND ris.qtdiaatr >= nvl((select distinct rli.qtdiatin -- qtde de dias de atraso
                              from craprli rli
                             where rli.cdcooper = pr_cdcooper
                               and rli.tplimite = 1 -- Limite de crédito
                               and rli.inpessoa = ass.inpessoa
                               and rli.cnauinad = 1 -- indicador de cancelamento
                               ), 999999)
       AND ris.cdmodali  = 101 -- ADP
       AND ris.cdorigem  = 1   -- Conta corrente
       AND ris.dtrefere  = rw_dat.dtmvtoan -- Buscar Central Atual **Antes de Rodar a Central de Risco
       AND ris.cdcooper  = pr_cdcooper;
     rw_conta cr_conta%ROWTYPE;


    --************************--
    --  INICIO PROCESSAMENTO  --
    --************************--

      BEGIN
        -- Busca calendário para a cooperativa selecionada
        OPEN cr_dat(pr_cdcooper);
        FETCH cr_dat INTO rw_dat;
        -- Se não encontrar calendário
        IF cr_dat%NOTFOUND THEN
          CLOSE cr_dat;
          -- Montar mensagem de critica
          vr_cdcritic  := 794;
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_dat;
        END IF;

      -- Leitura do calendário da cooperativa
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        RAISE vr_exc_saida;
      ELSE
         -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

        FOR rw_conta IN cr_conta(pr_cdcooper) LOOP
          pc_cancela_limite_credito(pr_cdcooper   => pr_cdcooper                -- Cooperativa
                                   ,pr_cdagenci   => 0                          -- Agência
                                   ,pr_nrdcaixa   => 0                          -- Caixa
                                   ,pr_cdoperad   => '1'                        -- Operador
                                   ,pr_nrdconta   => rw_conta.nrdconta          -- Conta do associado
                                   ,pr_nrctrlim   => rw_conta.nrctrlim          -- Contrato de Rating
                                   ,pr_inadimp    => 1                          -- 1-Inadimplência 0-Normal
                                   ,pr_cdcritic   => vr_cdcritic                -- Retorno OK / NOK
                                   ,pr_dscritic   => vr_dscritic);              -- Erros do processo
          -- Verifica erro
          IF vr_cdcritic = 0 THEN
            RAISE vr_exc_saida;
          END IF;
        --
        END LOOP;
      --END;
    EXCEPTION
      WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro PC_CANCELA_LIMITE_INADIM. Detalhes: '||vr_dscritic;
      WHEN OTHERS THEN
        -- Retornar o erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na rotina PC_CANCELA_LIMITE_INADIM. Detalhes: '||sqlerrm;
    END;
  END pc_cancela_limite_inadim;

  PROCEDURE pc_cancela_limite_credito(pr_cdcooper   IN crapcop.cdcooper%TYPE    --> Código da Cooperativa
                                     ,pr_cdagenci   IN crapass.cdagenci%TYPE    --> Código da agência
                                     ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE    --> Número do caixa
                                     ,pr_cdoperad   IN crapnrc.cdoperad%TYPE    --> Código do operador
                                     ,pr_nrdconta   IN crapass.nrdconta%TYPE    --> Conta do associado
                                     ,pr_nrctrlim   IN NUMBER                   --> Número do contrato de Rating
                                     ,pr_inadimp    IN NUMBER                   --> 1-Inadimplência 0-Normal
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2) IS              --> Texto de erro/critica encontrada
  BEGIN
    /* ............................................................................
     Programa: PC_CANCELA_LIMITE_CREDITO
     Sistema : Atenda - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Daniel Silva(AMcom)
     Data    : Maio/2018                           Ultima atualizacao: 23/05/2018

     Dados referentes ao programa:

     Frequencia: Subrotina
     Objetivo  : Rotina para cancelamento do Limite de Crédito
     Alteracoes:
    ..............................................................................*/

  DECLARE
  --*** VARIÁVEIS ***--
    vr_exc_saida exception;
    vr_exc_fimprg exception;
    vr_cdcritic crapcri.cdcritic%TYPE; -- Codigo da critica
    vr_dscritic VARCHAR2(2000);        -- Descricao da critica
    vr_inusatab BOOLEAN := FALSE;
    vr_des_reto VARCHAR2(3);
    vr_tab_erro GENE0001.typ_tab_erro;

    -- Cursor Genérico de Calendário
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  --**************************--
  --*** CURSORES GENÉRICOS ***--
  --**************************--
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

    -- Calendário da cooperativa selecionada
    CURSOR cr_dat(pr_cdcooper INTEGER) IS
    SELECT dat.dtmvtolt
         , (SELECT MAX(dtrefere) FROM crapris WHERE cdcooper = pr_cdcooper) dtmvtoan
         , dat.dtultdma
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
    rw_dat cr_dat%ROWTYPE;

  --**************************--
  --***     PROCEDURES     ***--
  --**************************--
    -- Cancela limite de crédito
    PROCEDURE pc_cancela_limite_cre(pr_cdcooper IN NUMBER         -- Cooperativa
                               ,pr_nrdconta IN NUMBER         -- Conta Corrente
                               ,pr_nrctrlim IN NUMBER         -- Contrato de Limite
                                   ,pr_inadimp  IN NUMBER         -- 1-Inadimplência 0-Normal
                               ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                               ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Efetua cancelamento dos limites
        UPDATE craplim lim
           SET lim.insitlim        = 3 -- Cancelado
             , lim.ininadim        = pr_inadimp -- 1 - Inadimplencia
             , lim.cdmotcan        = 0
             , lim.cdopeexc        = '1'
             , lim.cdageexc        = 0
             , lim.dtinsexc = rw_dat.dtmvtolt
             , lim.dtfimvig = rw_dat.dtmvtolt
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.nrctrlim = pr_nrctrlim
           AND lim.tpctrlim = 1  -- Cheque especial
           AND lim.insitlim = 2; -- Ativo
         --
       EXCEPTION
         WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Erro PC_CANCELA_LIMITE_CRE: '||SQLERRM;
           -- Efetuar rollback
           -- ROLLBACK;
    END pc_cancela_limite_cre;

    -- Cancela limite de crédito Conta
    PROCEDURE pc_cancela_limite_ass(pr_cdcooper IN NUMBER         -- Cooperativa
                                   ,pr_nrdconta IN NUMBER         -- Conta Corrente
                                   ,pr_nrctrlim IN NUMBER         -- Contrato de Limite
                                   ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Efetua cancelamento dos limites
        UPDATE crapass ass
           SET ass.vllimcre = 0
             , ass.tplimcre = (select DISTINCT inbaslim
                                 from craplim
                                where cdcooper = pr_cdcooper
                                  and nrdconta = pr_nrdconta
                                  and nrctrlim = pr_nrctrlim
                                  and rownum   = 1)
             , ass.dtultlcr = rw_dat.dtmvtolt
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
         --
       EXCEPTION
         WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Erro PC_CANCELA_LIMITE_ASS: '||SQLERRM;
           -- Efetuar rollback
           -- ROLLBACK;
    END pc_cancela_limite_ass;

    -- Cancela Microfilmagem
    PROCEDURE pc_cancela_microfilmagem(pr_cdcooper IN NUMBER  -- Cooperativa
                                      ,pr_nrdconta IN NUMBER         -- Conta Corrente
                                      ,pr_nrctrlim IN NUMBER         -- Contrato de Limite
                                      ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Efetua cancelamento da microfilmagem
        -- Somente para registros com data de início de vigência maior que 04/01/2003(Regra TELA_ATENDA_OCORRENCIAS)
        UPDATE crapmcr mcr
           SET mcr.dtcancel = rw_dat.dtmvtolt
         WHERE mcr.cdcooper = pr_cdcooper
           AND mcr.nrdconta = pr_nrdconta
           AND mcr.nrcontra = pr_nrctrlim
           AND EXISTS (SELECT 1
                         FROM craplim lim
                        WHERE lim.cdcooper = mcr.cdcooper
                          AND lim.nrdconta = mcr.nrdconta
                          AND lim.nrctrlim = mcr.nrcontra
                          AND lim.dtinivig >= TO_DATE('04/01/2003', 'dd/mm/yyyy'));
         --
       EXCEPTION
         WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Erro PC_CANCELA_MICROFILMAGEM: '||SQLERRM;
           -- Efetuar rollback
           -- ROLLBACK;
    END pc_cancela_microfilmagem;

    --************************--
    --   INICIO DO PROGRAMA   --
    --************************--
    BEGIN
      vr_cdcritic := NULL;
      vr_dscritic := NULL;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;

      -- Se não encontrar registro da cooperativa
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Busca calendário para a cooperativa selecionada
      OPEN cr_dat(pr_cdcooper);
      FETCH cr_dat INTO rw_dat;
      -- Se não encontrar calendário
      IF cr_dat%NOTFOUND THEN
        CLOSE cr_dat;
        -- Montar mensagem de critica
        vr_cdcritic  := 794;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_dat;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        RAISE vr_exc_saida;
      ELSE
         -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

    --************************--
    --  INICIO PROCESSAMENTO  --
    --************************--
      BEGIN
        pc_cancela_limite_cre(pr_cdcooper => pr_cdcooper   -- Cooperativa
                             ,pr_nrdconta => pr_nrdconta   -- Conta Corrente
                             ,pr_nrctrlim => pr_nrctrlim   -- Contrato de Limite
                             ,pr_inadimp  => pr_inadimp    -- 1-Inadimplência 0-Normal
                           ,pr_cdcritic => vr_cdcritic        -- Código da crítica
                           ,pr_dscritic => vr_dscritic);      -- Erros do processo
          -- Verifica erro
          IF vr_cdcritic = 0 THEN
            RAISE vr_exc_saida;
          END IF;

        pc_cancela_limite_ass(pr_cdcooper => pr_cdcooper   -- Cooperativa
                             ,pr_nrdconta => pr_nrdconta   -- Conta Corrente
                             ,pr_nrctrlim => pr_nrctrlim   -- Contrato de Limite
                               ,pr_cdcritic => vr_cdcritic        -- Código da crítica
                               ,pr_dscritic => vr_dscritic);      -- Erros do processo
          -- Verifica erro
          IF vr_cdcritic = 0 THEN
            RAISE vr_exc_saida;
          END IF;

          pc_cancela_microfilmagem(pr_cdcooper => pr_cdcooper        -- Cooperativa
                                ,pr_nrdconta => pr_nrdconta   -- Conta Corrente
                                ,pr_nrctrlim => pr_nrctrlim   -- Contrato de Limite
                                  ,pr_cdcritic => vr_cdcritic        -- Código da crítica
                                  ,pr_dscritic => vr_dscritic);      -- Erros do processo
          -- Verifica erro
          IF vr_cdcritic = 0 THEN
            RAISE vr_exc_saida;
          END IF;

          -- Desativar Rating
          -- RATI0001.pc_desativa_rating
          -- Desativar o Rating associado a esta operação
          rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper          -- Cooperativa
                                   ,pr_cdagenci   => pr_cdagenci                -- Agência
                                   ,pr_nrdcaixa   => pr_nrdcaixa                -- Caixa
                                   ,pr_cdoperad   => pr_cdoperad                -- Operador
                                     ,pr_rw_crapdat => rw_crapdat           -- Vetor com dados de parâmetro (CRAPDAT)
                                   ,pr_nrdconta   => pr_nrdconta                -- Conta do associado
                                     ,pr_tpctrrat   => 1                    -- Tipo do Rating (1-Limite de crédito)
                                   ,pr_nrctrrat   => pr_nrctrlim                -- Contrato de Rating
                                     ,pr_flgefeti   => 'S'                  -- Flag para efetivação ou não do Rating
                                     ,pr_idseqttl   => 1                    -- Sequencia de titularidade da conta
                                     ,pr_idorigem   => 1                    -- Indicador da origem da chamada
                                     ,pr_inusatab   => vr_inusatab          -- Indicador de utilização da tabela de juros
                                     ,pr_nmdatela   => 'PC_CANCELA_LIMITE_CREDITO'-- Nome datela conectada
                                     ,pr_flgerlog   => 'N'                  -- Gerar log S/N
                                     ,pr_des_reto   => vr_des_reto          -- Retorno OK / NOK
                                     ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros
           -- Verifica erro
           IF vr_des_reto = 'NOK' THEN
             --Se tem erro na tabela
             IF vr_tab_erro.COUNT = 0 THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro na rati0001.pc_desativa_rating';
             ELSE
               vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
             END IF;
             --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;
           --
      END;
    EXCEPTION
      WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro PC_CANCELA_LIMITE_CREDITO. Detalhes: '||vr_dscritic;
      WHEN OTHERS THEN
        -- Retornar o erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na rotina PC_CANCELA_LIMITE_CREDITO. Detalhes: '||sqlerrm;
    END;
  END pc_cancela_limite_credito;


end limi0002;
/
