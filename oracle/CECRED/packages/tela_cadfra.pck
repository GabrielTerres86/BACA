CREATE OR REPLACE PACKAGE CECRED.TELA_CADFRA IS

  PROCEDURE pc_busca_dados(pr_cddopcao     IN VARCHAR2 --> Opcao
                          ,pr_cdoperacao   IN tbgen_analise_fraude_param.cdoperacao%TYPE --> Codigo da operacao
                          ,pr_tpoperacao   IN tbgen_analise_fraude_param.tpoperacao%TYPE --> Tipo da operacao
                          ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_intervalo(pr_cdoperacao   IN tbgen_analise_fraude_interv.cdoperacao%TYPE --> Codigo da operacao
                              ,pr_tpoperacao   IN tbgen_analise_fraude_interv.tpoperacao%TYPE --> Tipo da operacao
                              ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_dados(pr_cdoperacao        IN tbgen_analise_fraude_param.cdoperacao%TYPE --> Codigo da operacao
                          ,pr_tpoperacao        IN tbgen_analise_fraude_param.tpoperacao%TYPE --> Tipo da operacao
                          ,pr_hrretencao        IN VARCHAR2 --> Horario fixo
                          ,pr_strhoraminutos    IN VARCHAR2 --> Contem os horarios e minutos
                          ,pr_flgemail_entrega  IN tbgen_analise_fraude_param.flgemail_entrega%TYPE --> Flag para enviar email
                          ,pr_dsemail_entrega   IN tbgen_analise_fraude_param.dsemail_entrega%TYPE --> Endereco de email
                          ,pr_dsassunto_entrega IN tbgen_analise_fraude_param.dsassunto_entrega%TYPE --> Assunto do email
                          ,pr_dscorpo_entrega   IN tbgen_analise_fraude_param.dscorpo_entrega%TYPE --> Corpo do email
                          ,pr_flgemail_retorno  IN tbgen_analise_fraude_param.flgemail_retorno%TYPE --> Flag para enviar email
                          ,pr_dsemail_retorno   IN tbgen_analise_fraude_param.dsemail_retorno%TYPE --> Endereco de email
                          ,pr_dsassunto_retorno IN tbgen_analise_fraude_param.dsassunto_retorno%TYPE --> Assunto do email
                          ,pr_dscorpo_retorno   IN tbgen_analise_fraude_param.dscorpo_retorno%TYPE --> Corpo do email
                          ,pr_xmllog            IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic          OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic          OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml         IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro          OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_exclui_dados(pr_cdoperacao IN tbgen_analise_fraude_param.cdoperacao%TYPE --> Codigo da operacao
                        	 ,pr_tpoperacao IN tbgen_analise_fraude_param.tpoperacao%TYPE --> Tipo da operacao
                           ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml  IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro   OUT VARCHAR2); --> Erros do processo

END TELA_CADFRA;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADFRA IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CADFRA
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Fevereiro - 2017                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CADFRA
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  
  -- Definicao do tipo de registro
  TYPE typ_reg_param IS
  RECORD (hrretencao        tbgen_analise_fraude_param.hrretencao%TYPE
         ,flgemail_entrega  tbgen_analise_fraude_param.flgemail_entrega%TYPE
         ,dsemail_entrega   tbgen_analise_fraude_param.dsemail_entrega%TYPE
         ,dsassunto_entrega tbgen_analise_fraude_param.dsassunto_entrega%TYPE
         ,dscorpo_entrega   tbgen_analise_fraude_param.dscorpo_entrega%TYPE
         ,flgemail_retorno  tbgen_analise_fraude_param.flgemail_retorno%TYPE
         ,dsemail_retorno   tbgen_analise_fraude_param.dsemail_retorno%TYPE
         ,dsassunto_retorno tbgen_analise_fraude_param.dsassunto_retorno%TYPE
         ,dscorpo_retorno   tbgen_analise_fraude_param.dscorpo_retorno%TYPE);

  TYPE typ_reg_interv IS
  RECORD (hrinicio          tbgen_analise_fraude_interv.hrinicio%TYPE
         ,hrfim             tbgen_analise_fraude_interv.hrfim%TYPE
         ,qtdminutos        tbgen_analise_fraude_interv.qtdminutos_retencao%TYPE);

  -- Definicao do tipo de tabela registro
  TYPE typ_tab_param  IS TABLE OF typ_reg_param  INDEX BY PLS_INTEGER;
  TYPE typ_tab_interv IS TABLE OF typ_reg_interv INDEX BY PLS_INTEGER;

  -- Vetor para armazenar os dados da tabela
  vr_tab_param  typ_tab_param;
  vr_tab_interv typ_tab_interv;

  PROCEDURE pc_carrega_dados(pr_cdoperacao  IN tbgen_analise_fraude_param.cdoperacao%TYPE --> Codigo da operacao
                            ,pr_tpoperacao  IN tbgen_analise_fraude_param.tpoperacao%TYPE --> Tipo da operacao
                            ,pr_tab_param  OUT typ_tab_param --> PLTABLE com os dados
                            ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic   OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_carrega_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_param(pr_cdoperacao IN tbgen_analise_fraude_param.cdoperacao%TYPE
                     ,pr_tpoperacao IN tbgen_analise_fraude_param.tpoperacao%TYPE) IS
        SELECT param.hrretencao
              ,param.flgemail_entrega
              ,param.dsemail_entrega
              ,param.dsassunto_entrega
              ,param.dscorpo_entrega
              ,param.flgemail_retorno
              ,param.dsemail_retorno
              ,param.dsassunto_retorno
              ,param.dscorpo_retorno
          FROM tbgen_analise_fraude_param param
         WHERE param.cdoperacao = pr_cdoperacao
           AND param.tpoperacao = pr_tpoperacao;
      rw_param cr_param%ROWTYPE;
      
      -- Variaveis Gerais
      vr_blnfound BOOLEAN;

    BEGIN
      -- Limpa PLTABLE
      pr_tab_param.DELETE;

      -- Selecionar os dados
      OPEN cr_param(pr_cdoperacao => pr_cdoperacao
                   ,pr_tpoperacao => pr_tpoperacao);
      FETCH cr_param INTO rw_param;
      -- Alimenta a booleana
      vr_blnfound := cr_param%FOUND;
      -- Fechar o cursor
      CLOSE cr_param;

      -- Se encontrou
      IF vr_blnfound THEN

        -- Carrega os dados na PLTRABLE
        pr_tab_param(0).hrretencao        := rw_param.hrretencao;
        pr_tab_param(0).flgemail_entrega  := rw_param.flgemail_entrega;
        pr_tab_param(0).dsemail_entrega   := rw_param.dsemail_entrega;
        pr_tab_param(0).dsassunto_entrega := rw_param.dsassunto_entrega;
        pr_tab_param(0).dscorpo_entrega   := rw_param.dscorpo_entrega;
        pr_tab_param(0).flgemail_retorno  := rw_param.flgemail_retorno;
        pr_tab_param(0).dsemail_retorno   := rw_param.dsemail_retorno;
        pr_tab_param(0).dsassunto_retorno := rw_param.dsassunto_retorno;
        pr_tab_param(0).dscorpo_retorno   := rw_param.dscorpo_retorno;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela CADFRA: ' || SQLERRM;
    END;

  END pc_carrega_dados;

  PROCEDURE pc_carrega_interv(pr_cdoperacao  IN tbgen_analise_fraude_interv.cdoperacao%TYPE --> Codigo da operacao
                             ,pr_tpoperacao  IN tbgen_analise_fraude_interv.tpoperacao%TYPE --> Tipo da operacao
                             ,pr_tab_interv OUT typ_tab_interv --> PLTABLE com os dados
                             ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic   OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_carrega_interv
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_param(pr_cdoperacao IN tbgen_analise_fraude_interv.cdoperacao%TYPE
                     ,pr_tpoperacao IN tbgen_analise_fraude_interv.tpoperacao%TYPE) IS
        SELECT param.hrinicio
              ,param.hrfim
              ,param.qtdminutos_retencao
          FROM tbgen_analise_fraude_interv param
         WHERE param.cdoperacao = pr_cdoperacao
           AND param.tpoperacao = pr_tpoperacao;

      -- Variaveis
      vr_contador INTEGER := 0;

    BEGIN
      -- Limpa PLTABLE
      pr_tab_interv.DELETE;

      -- Listagem de parametro
      FOR rw_param IN cr_param(pr_cdoperacao => pr_cdoperacao
                              ,pr_tpoperacao => pr_tpoperacao) LOOP

        -- Carrega os dados na PLTRABLE
        pr_tab_interv(vr_contador).hrinicio   := rw_param.hrinicio;
        pr_tab_interv(vr_contador).hrfim      := rw_param.hrfim;
        pr_tab_interv(vr_contador).qtdminutos := rw_param.qtdminutos_retencao;

        vr_contador := vr_contador + 1;

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela CADFRA: ' || SQLERRM;
    END;

  END pc_carrega_interv;

  PROCEDURE pc_busca_dados(pr_cddopcao     IN VARCHAR2 --> Opcao
                          ,pr_cdoperacao   IN tbgen_analise_fraude_param.cdoperacao%TYPE --> Codigo da operacao
                          ,pr_tpoperacao   IN tbgen_analise_fraude_param.tpoperacao%TYPE --> Tipo da operacao
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
    Data    : Fevereiro/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

    BEGIN
      -- NAO foi informado codigo
      IF pr_cdoperacao = 0 THEN
        vr_cdcritic := 451;
        RAISE vr_exc_erro;
      END IF;

      -- Carrega os dados
      pc_carrega_dados(pr_cdoperacao => pr_cdoperacao
                      ,pr_tpoperacao => pr_tpoperacao
                      ,pr_tab_param  => vr_tab_param
                      ,pr_cdcritic   => vr_cdcritic
                      ,pr_dscritic   => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Se encontrou
      IF vr_tab_param.COUNT > 0 THEN

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
                              ,pr_tag_nova => 'hrretencao'
                              ,pr_tag_cont => to_char(GENE0002.fn_converte_time_data(vr_tab_param(0).hrretencao))
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flgemail_entrega'
                              ,pr_tag_cont => vr_tab_param(0).flgemail_entrega
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsemail_entrega'
                              ,pr_tag_cont => vr_tab_param(0).dsemail_entrega
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsassunto_entrega'
                              ,pr_tag_cont => vr_tab_param(0).dsassunto_entrega
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dscorpo_entrega'
                              ,pr_tag_cont => REPLACE(vr_tab_param(0).dscorpo_entrega, CHR(10), '<br>')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flgemail_retorno'
                              ,pr_tag_cont => vr_tab_param(0).flgemail_retorno
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsemail_retorno'
                              ,pr_tag_cont => vr_tab_param(0).dsemail_retorno
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsassunto_retorno'
                              ,pr_tag_cont => vr_tab_param(0).dsassunto_retorno
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dscorpo_retorno'
                              ,pr_tag_cont => vr_tab_param(0).dscorpo_retorno
                              ,pr_des_erro => vr_dscritic);

      -- Se NAO encontrou e for consulta ou exclusao
      ELSIF pr_cddopcao IN ('C','E') THEN
        vr_cdcritic := 530;
        RAISE vr_exc_erro;
      END IF;

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
        pr_dscritic := 'Erro geral na rotina da tela CADFRA: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_dados;

  PROCEDURE pc_busca_intervalo(pr_cdoperacao   IN tbgen_analise_fraude_interv.cdoperacao%TYPE --> Codigo da operacao
                              ,pr_tpoperacao   IN tbgen_analise_fraude_interv.tpoperacao%TYPE --> Tipo da operacao
                              ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_intervalo
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os intervalos.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis
      vr_index    PLS_INTEGER;

    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Carrega os dados
      pc_carrega_interv(pr_cdoperacao => pr_cdoperacao
                       ,pr_tpoperacao => pr_tpoperacao
                       ,pr_tab_interv => vr_tab_interv
                       ,pr_cdcritic   => vr_cdcritic
                       ,pr_dscritic   => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Buscar Primeiro registro
      vr_index:= vr_tab_interv.FIRST;

      -- Percorrer todos os registros
      WHILE vr_index IS NOT NULL LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'param'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'param'
                              ,pr_posicao  => vr_index
                              ,pr_tag_nova => 'hrinicio'
                              ,pr_tag_cont => to_char(GENE0002.fn_converte_time_data(vr_tab_interv(vr_index).hrinicio))
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'param'
                              ,pr_posicao  => vr_index
                              ,pr_tag_nova => 'hrfim'
                              ,pr_tag_cont => to_char(GENE0002.fn_converte_time_data(vr_tab_interv(vr_index).hrfim))
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'param'
                              ,pr_posicao  => vr_index
                              ,pr_tag_nova => 'qtdminutos_retencao'
                              ,pr_tag_cont => vr_tab_interv(vr_index).qtdminutos
                              ,pr_des_erro => vr_dscritic);

        -- Proximo Registro
        vr_index:= vr_tab_interv.NEXT(vr_index);
      END LOOP;

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
        pr_dscritic := 'Erro geral na rotina da tela CADFRA: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_intervalo;

  PROCEDURE pc_item_log(pr_cdcooper   IN INTEGER --> Codigo da cooperativa
                       ,pr_cddopcao   IN VARCHAR2 --> Opcao
                       ,pr_cdoperad   IN VARCHAR2 --> Codigo do operador
                       ,pr_cdoperacao IN INTEGER --> Codigo da operacao
                       ,pr_tpoperacao IN INTEGER --> Tipo da operacao
                       ,pr_dsdcampo   IN VARCHAR2 --> Descricao do campo
                       ,pr_vldantes   IN VARCHAR2 --> Valor antes
                       ,pr_vldepois   IN VARCHAR2) IS  --> Valor depois
  BEGIN

    /* .............................................................................

    Programa: pc_item_log
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os itens do LOG.

    Alteracoes: 
    ..............................................................................*/
    DECLARE
      -- Busca a operacao
      CURSOR cr_operacao(pr_cdoperacao IN tbcc_operacao.cdoperacao%TYPE) IS
        SELECT ope.dsoperacao
          FROM tbcc_operacao ope
         WHERE ope.cdoperacao = pr_cdoperacao;

    	vr_dsoperacao VARCHAR2(50);
      vr_dstipopera VARCHAR2(50);

    BEGIN
      -- Se for alteracao e nao tem diferenca, retorna
      IF pr_cddopcao = 'A' AND pr_vldantes = pr_vldepois THEN
        RETURN;
      END IF;

    	OPEN  cr_operacao(pr_cdoperacao => pr_cdoperacao);
      FETCH cr_operacao INTO vr_dsoperacao;
      CLOSE cr_operacao;
      vr_dstipopera := (CASE WHEN pr_tpoperacao = 1 THEN 'Online' ELSE 'Agendada' END);

      IF pr_cddopcao = 'A' THEN
        -- Geral LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_nmarqlog     => 'cadfra.log'
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                      ' --> Operador ' || pr_cdoperad ||
                                                      ' alterou o campo ' || pr_dsdcampo ||
                                                      ' de ' || pr_vldantes ||
                                                      ' para ' || pr_vldepois || 
                                                      ' na operacao ' || vr_dsoperacao ||
                                                      ' (' || vr_dstipopera || ')');
      ELSE

        IF pr_cddopcao = 'I' THEN
          -- Geral LOG
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratado
                                    ,pr_nmarqlog     => 'cadfra.log'
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                        ' --> Operador ' || pr_cdoperad ||
                                                        ' incluiu o campo ' || pr_dsdcampo ||
                                                        ' com o valor ' || pr_vldepois ||
                                                        ' na operacao ' || vr_dsoperacao ||
                                                        ' (' || vr_dstipopera || ')');
        ELSE

          IF pr_cddopcao = 'E' THEN
            -- Geral LOG
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratado
                                      ,pr_nmarqlog     => 'cadfra.log'
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                          ' --> Operador ' || pr_cdoperad ||
                                                          ' excluiu a operacao ' || vr_dsoperacao ||
                                                          ' (' || vr_dstipopera || ')');
          END IF;

        END IF;

      END IF;

    END;

  END pc_item_log;

  PROCEDURE pc_grava_intervalo(pr_cdcooper       IN INTEGER --> Codigo da cooperativa
                              ,pr_cddopcao       IN VARCHAR2 --> Opcao
                              ,pr_cdoperad       IN INTEGER --> Codigo do operador
                              ,pr_cdoperacao     IN tbgen_analise_fraude_interv.cdoperacao%TYPE --> Codigo da operacao
                        	    ,pr_tpoperacao     IN tbgen_analise_fraude_interv.tpoperacao%TYPE --> Tipo da operacao
                              ,pr_strhoraminutos IN VARCHAR2 --> Contem os horarios e minutos
                              ,pr_cdcritic      OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic      OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_grava_intervalo
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os intervalos.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_param(pr_cdoperacao IN tbgen_analise_fraude_interv.cdoperacao%TYPE
                     ,pr_tpoperacao IN tbgen_analise_fraude_interv.tpoperacao%TYPE
                     ,pr_hroperacao IN tbgen_analise_fraude_interv.hrinicio%TYPE) IS
        SELECT 1
          FROM tbgen_analise_fraude_interv param
         WHERE param.cdoperacao  = pr_cdoperacao
           AND param.tpoperacao  = pr_tpoperacao
           AND param.hrinicio   <= pr_hroperacao
           AND param.hrfim      >= pr_hroperacao;
      rw_param cr_param%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis
      vr_hrinicio   INTEGER;
      vr_hrfim      INTEGER;
      vr_hrcompara  INTEGER;
      vr_qtdminutos INTEGER;
      vr_blnachou   BOOLEAN;
      vr_index      PLS_INTEGER;
      vr_strhormin  GENE0002.typ_split;

    BEGIN
      IF pr_cddopcao = 'A' THEN
        -- Carrega os dados
        pc_carrega_interv(pr_cdoperacao => pr_cdoperacao
                         ,pr_tpoperacao => pr_tpoperacao
                         ,pr_tab_interv => vr_tab_interv
                         ,pr_cdcritic   => vr_cdcritic
                         ,pr_dscritic   => vr_dscritic);

        -- Se houve retorno de erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Buscar Primeiro registro
        vr_index:= vr_tab_interv.FIRST;

        -- Percorrer todos os registros
        WHILE vr_index IS NOT NULL LOOP
          pc_item_log(pr_cdcooper   => pr_cdcooper
                     ,pr_cddopcao   => pr_cddopcao
                     ,pr_cdoperad   => pr_cdoperad
                     ,pr_cdoperacao => pr_cdoperacao
                     ,pr_tpoperacao => pr_tpoperacao
                     ,pr_dsdcampo   => 'intervalo anterior linha ' || (vr_index + 1)
                     ,pr_vldantes   => to_char(GENE0002.fn_converte_time_data(vr_tab_interv(vr_index).hrinicio))
                                    || ' - ' || to_char(GENE0002.fn_converte_time_data(vr_tab_interv(vr_index).hrfim))
                                    || ' - ' || vr_tab_interv(vr_index).qtdminutos || 'min'
                     ,pr_vldepois   => '');
          -- Proximo Registro
          vr_index:= vr_tab_interv.NEXT(vr_index);
        END LOOP;
      END IF;

      BEGIN
        DELETE
          FROM tbgen_analise_fraude_interv
         WHERE cdoperacao = pr_cdoperacao
           AND tpoperacao = pr_tpoperacao;

        -- Quebra a string
        vr_strhormin := GENE0002.fn_quebra_string(pr_string  => pr_strhoraminutos
                                                 ,pr_delimit => '#');

        FOR vr_ind IN 1..vr_strhormin.COUNT() LOOP
          vr_qtdminutos := GENE0002.fn_busca_entrada(3,vr_strhormin(vr_ind),'_');

          -- Valida o horario de Inicio
          BEGIN
            vr_hrinicio  := GENE0002.fn_char_para_number(to_char(to_date(GENE0002.fn_busca_entrada(1,vr_strhormin(vr_ind),'_'),'HH24MI'),'SSSSS'));
            vr_hrcompara := GENE0002.fn_char_para_number(to_char(to_date(GENE0002.fn_busca_entrada(1,vr_strhormin(vr_ind),'_'),'HH24MI') + (vr_qtdminutos / (24*60)),'SSSSS'));
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Horário inválido.###hrinicio###0';
              RAISE vr_exc_erro;
          END;

          -- Valida o horario de Fim
          BEGIN
            vr_hrfim := GENE0002.fn_char_para_number(to_char(to_date(GENE0002.fn_busca_entrada(2,vr_strhormin(vr_ind),'_'),'HH24MI'),'SSSSS'));
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Horário inválido.###hrfim###0';
              RAISE vr_exc_erro;
          END;

          -- Valida os minutos
          IF vr_hrfim < vr_hrcompara THEN
            vr_dscritic := 'O horário final deve respeitar os minutos após início.###hrfim###0';
            RAISE vr_exc_erro;
          END IF;

          -- Verifica a Data de Inicio
          OPEN  cr_param(pr_cdoperacao => pr_cdoperacao
                        ,pr_tpoperacao => pr_tpoperacao
                        ,pr_hroperacao => vr_hrinicio);
          FETCH cr_param INTO rw_param;
          vr_blnachou := cr_param%FOUND;
          CLOSE cr_param;
          IF vr_blnachou THEN
            vr_dscritic := 'Horário informado não poderá sobrepor outro existente.###hrinicio###0';
            RAISE vr_exc_erro;
          END IF;

          -- Verifica a Data de Fim
          OPEN  cr_param(pr_cdoperacao => pr_cdoperacao
                        ,pr_tpoperacao => pr_tpoperacao
                        ,pr_hroperacao => vr_hrfim);
          FETCH cr_param INTO rw_param;
          vr_blnachou := cr_param%FOUND;
          CLOSE cr_param;
          IF vr_blnachou THEN
            vr_dscritic := 'Horário informado não poderá sobrepor outro existente.###hrfim###0';
            RAISE vr_exc_erro;
          END IF;

          INSERT INTO tbgen_analise_fraude_interv
                     (cdoperacao
                     ,tpoperacao
                     ,hrinicio
                     ,hrfim
                     ,qtdminutos_retencao)
               VALUES(pr_cdoperacao
                     ,pr_tpoperacao
                     ,vr_hrinicio
                     ,vr_hrfim
                     ,vr_qtdminutos);

          pc_item_log(pr_cdcooper   => pr_cdcooper
                     ,pr_cddopcao   => pr_cddopcao
                     ,pr_cdoperad   => pr_cdoperad
                     ,pr_cdoperacao => pr_cdoperacao
                     ,pr_tpoperacao => pr_tpoperacao
                     ,pr_dsdcampo   => 'intervalo atual linha ' || vr_ind
                     ,pr_vldantes   => ''
                     ,pr_vldepois   => to_char(GENE0002.fn_converte_time_data(vr_hrinicio))
                                    || ' - ' || to_char(GENE0002.fn_converte_time_data(vr_hrfim))
                                    || ' - ' || vr_qtdminutos || 'min');
        END LOOP;

      EXCEPTION
	      WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;

        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao cadastrar intervalos: ' || SQLERRM;
        RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADFRA: ' || SQLERRM;

    END;

  END pc_grava_intervalo;

  PROCEDURE pc_grava_dados(pr_cdoperacao        IN tbgen_analise_fraude_param.cdoperacao%TYPE --> Codigo da operacao
                        	,pr_tpoperacao        IN tbgen_analise_fraude_param.tpoperacao%TYPE --> Tipo da operacao
                          ,pr_hrretencao        IN VARCHAR2 --> Horario fixo
                          ,pr_strhoraminutos    IN VARCHAR2 --> Contem os horarios e minutos
                          ,pr_flgemail_entrega  IN tbgen_analise_fraude_param.flgemail_entrega%TYPE --> Flag para enviar email
                          ,pr_dsemail_entrega   IN tbgen_analise_fraude_param.dsemail_entrega%TYPE --> Endereco de email
                          ,pr_dsassunto_entrega IN tbgen_analise_fraude_param.dsassunto_entrega%TYPE --> Assunto do email
                          ,pr_dscorpo_entrega   IN tbgen_analise_fraude_param.dscorpo_entrega%TYPE --> Corpo do email
                          ,pr_flgemail_retorno  IN tbgen_analise_fraude_param.flgemail_retorno%TYPE --> Flag para enviar email
                          ,pr_dsemail_retorno   IN tbgen_analise_fraude_param.dsemail_retorno%TYPE --> Endereco de email
                          ,pr_dsassunto_retorno IN tbgen_analise_fraude_param.dsassunto_retorno%TYPE --> Assunto do email
                          ,pr_dscorpo_retorno   IN tbgen_analise_fraude_param.dscorpo_retorno%TYPE --> Corpo do email
                          ,pr_xmllog            IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic          OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic          OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml         IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os dados.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
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

      -- Variaveis
      vr_cddopcao   VARCHAR2(1);
      vr_hrretencao NUMBER := NULL;
      vr_dscorpo_entrega tbgen_analise_fraude_param.dscorpo_entrega%TYPE;
      vr_dscorpo_retorno tbgen_analise_fraude_param.dscorpo_retorno%TYPE;

    BEGIN
      -- Limpa PLTABLE
      vr_tab_param.DELETE;

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

      -- Se for do tipo Online
      IF pr_tpoperacao = 1 THEN

        -- Se NAO foi informado nada
        IF TRIM(pr_strhoraminutos) IS NULL THEN
          vr_dscritic := 'Informe um intervalo.###qtdminutos_retencao###0';
          RAISE vr_exc_saida;
        END IF;

      -- Se for do tipo Agendada
      ELSIF pr_tpoperacao = 2 THEN

        -- Se NAO foi informado nada
        IF TRIM(pr_hrretencao) IS NULL THEN
          vr_dscritic := 'Informe o horário.###hrretencao###0';
          RAISE vr_exc_saida;
        ELSE
          -- Valida o horario
          BEGIN
            vr_hrretencao := GENE0002.fn_char_para_number(to_char(to_date(pr_hrretencao,'HH24:MI'),'SSSSS'));
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Horário inválido.###hrretencao###0';
              RAISE vr_exc_saida;
          END;
        END IF;

      END IF;

      -- Carrega os dados da agencia
      pc_carrega_dados(pr_cdoperacao => pr_cdoperacao
                      ,pr_tpoperacao => pr_tpoperacao
                      ,pr_tab_param  => vr_tab_param
                      ,pr_cdcritic   => vr_cdcritic
                      ,pr_dscritic   => vr_dscritic);
      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Remove o CDATA da String
      vr_dscorpo_entrega := GENE0007.fn_remove_cdata(pr_dscorpo_entrega);
      vr_dscorpo_retorno := GENE0007.fn_remove_cdata(pr_dscorpo_retorno);

      -- Se encontrou registro
      IF vr_tab_param.COUNT > 0 THEN
        vr_cddopcao := 'A';

        -- Atualiza dados
        BEGIN
          UPDATE tbgen_analise_fraude_param
             SET hrretencao        = vr_hrretencao
                ,flgemail_entrega  = pr_flgemail_entrega
                ,dsemail_entrega   = pr_dsemail_entrega
                ,dsassunto_entrega = pr_dsassunto_entrega
                ,dscorpo_entrega   = vr_dscorpo_entrega
                ,flgemail_retorno  = pr_flgemail_retorno
                ,dsemail_retorno   = pr_dsemail_retorno
                ,dsassunto_retorno = pr_dsassunto_retorno
                ,dscorpo_retorno   = vr_dscorpo_retorno
           WHERE cdoperacao        = pr_cdoperacao
             AND tpoperacao        = pr_tpoperacao;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao alterar dados na tabela tbgen_analise_fraude_param: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

      ELSE
        vr_cddopcao := 'I';

        -- Insere dados
        BEGIN
          INSERT INTO tbgen_analise_fraude_param
                     (cdoperacao
                     ,tpoperacao
                     ,hrretencao
                     ,flgemail_entrega
                     ,dsemail_entrega
                     ,dsassunto_entrega
                     ,dscorpo_entrega
                     ,flgemail_retorno
                     ,dsemail_retorno
                     ,dsassunto_retorno
                     ,dscorpo_retorno)
               VALUES(pr_cdoperacao
                     ,pr_tpoperacao
                     ,vr_hrretencao
                     ,pr_flgemail_entrega
                     ,pr_dsemail_entrega
                     ,pr_dsassunto_entrega
                     ,vr_dscorpo_entrega
                     ,pr_flgemail_retorno
                     ,pr_dsemail_retorno
                     ,pr_dsassunto_retorno
                     ,vr_dscorpo_retorno);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir dados na tabela tbgen_analise_fraude_param: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

      END IF; -- vr_tab_param.COUNT > 0

      -- Se for do tipo Online
      IF pr_tpoperacao = 1 THEN

        -- Chama a validacao e gravacao dos intervalos
        pc_grava_intervalo(pr_cdcooper       => vr_cdcooper
                          ,pr_cddopcao       => vr_cddopcao
                          ,pr_cdoperad       => vr_cdoperad
                          ,pr_cdoperacao     => pr_cdoperacao
                        	,pr_tpoperacao     => pr_tpoperacao
                          ,pr_strhoraminutos => pr_strhoraminutos
                          ,pr_cdcritic       => vr_cdcritic
                          ,pr_dscritic       => vr_dscritic);
        -- Se retornou erro
        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      -- Se for do tipo Agendada
      ELSIF pr_tpoperacao = 2 THEN

        pc_item_log(pr_cdcooper   => vr_cdcooper
                   ,pr_cddopcao   => vr_cddopcao
                   ,pr_cdoperad   => vr_cdoperad
                   ,pr_cdoperacao => pr_cdoperacao
                   ,pr_tpoperacao => pr_tpoperacao
                   ,pr_dsdcampo   => 'retencao'
                   ,pr_vldantes   => (CASE WHEN vr_tab_param.COUNT > 0 THEN to_char(GENE0002.fn_converte_time_data(vr_tab_param(0).hrretencao)) ELSE '' END)
                   ,pr_vldepois   => pr_hrretencao);

      END IF;

      pc_item_log(pr_cdcooper   => vr_cdcooper
                 ,pr_cddopcao   => vr_cddopcao
                 ,pr_cdoperad   => vr_cdoperad
                 ,pr_cdoperacao => pr_cdoperacao
                 ,pr_tpoperacao => pr_tpoperacao
                 ,pr_dsdcampo   => 'enviar email na entrega'
                 ,pr_vldantes   => (CASE WHEN vr_tab_param.COUNT > 0 THEN (CASE WHEN vr_tab_param(0).flgemail_entrega = 1 THEN 'Sim' ELSE 'Nao' END) ELSE '' END)
                 ,pr_vldepois   => (CASE WHEN pr_flgemail_entrega = 1 THEN 'Sim' ELSE 'Nao' END));

      pc_item_log(pr_cdcooper   => vr_cdcooper
                 ,pr_cddopcao   => vr_cddopcao
                 ,pr_cdoperad   => vr_cdoperad
                 ,pr_cdoperacao => pr_cdoperacao
                 ,pr_tpoperacao => pr_tpoperacao
                 ,pr_dsdcampo   => 'email da entrega'
                 ,pr_vldantes   => (CASE WHEN vr_tab_param.COUNT > 0 THEN NVL(vr_tab_param(0).dsemail_entrega,' ') ELSE '' END)
                 ,pr_vldepois   => NVL(pr_dsemail_entrega,' '));

      pc_item_log(pr_cdcooper   => vr_cdcooper
                 ,pr_cddopcao   => vr_cddopcao
                 ,pr_cdoperad   => vr_cdoperad
                 ,pr_cdoperacao => pr_cdoperacao
                 ,pr_tpoperacao => pr_tpoperacao
                 ,pr_dsdcampo   => 'assunto da entrega'
                 ,pr_vldantes   => (CASE WHEN vr_tab_param.COUNT > 0 THEN NVL(vr_tab_param(0).dsassunto_entrega,' ') ELSE '' END)
                 ,pr_vldepois   => NVL(pr_dsassunto_entrega,' '));

      pc_item_log(pr_cdcooper   => vr_cdcooper
                 ,pr_cddopcao   => vr_cddopcao
                 ,pr_cdoperad   => vr_cdoperad
                 ,pr_cdoperacao => pr_cdoperacao
                 ,pr_tpoperacao => pr_tpoperacao
                 ,pr_dsdcampo   => 'conteudo da entrega'
                 ,pr_vldantes   => (CASE WHEN vr_tab_param.COUNT > 0 THEN NVL(vr_tab_param(0).dscorpo_entrega,' ') ELSE '' END)
                 ,pr_vldepois   => NVL(vr_dscorpo_entrega,' '));

      pc_item_log(pr_cdcooper   => vr_cdcooper
                 ,pr_cddopcao   => vr_cddopcao
                 ,pr_cdoperad   => vr_cdoperad
                 ,pr_cdoperacao => pr_cdoperacao
                 ,pr_tpoperacao => pr_tpoperacao
                 ,pr_dsdcampo   => 'enviar email no retorno'
                 ,pr_vldantes   => (CASE WHEN vr_tab_param.COUNT > 0 THEN (CASE WHEN vr_tab_param(0).flgemail_retorno = 1 THEN 'Sim' ELSE 'Nao' END) ELSE '' END)
                 ,pr_vldepois   => (CASE WHEN pr_flgemail_retorno = 1 THEN 'Sim' ELSE 'Nao' END));

      pc_item_log(pr_cdcooper   => vr_cdcooper
                 ,pr_cddopcao   => vr_cddopcao
                 ,pr_cdoperad   => vr_cdoperad
                 ,pr_cdoperacao => pr_cdoperacao
                 ,pr_tpoperacao => pr_tpoperacao
                 ,pr_dsdcampo   => 'email do retorno'
                 ,pr_vldantes   => (CASE WHEN vr_tab_param.COUNT > 0 THEN NVL(vr_tab_param(0).dsemail_retorno,' ') ELSE '' END)
                 ,pr_vldepois   => NVL(pr_dsemail_retorno,' '));

      pc_item_log(pr_cdcooper   => vr_cdcooper
                 ,pr_cddopcao   => vr_cddopcao
                 ,pr_cdoperad   => vr_cdoperad
                 ,pr_cdoperacao => pr_cdoperacao
                 ,pr_tpoperacao => pr_tpoperacao
                 ,pr_dsdcampo   => 'assunto do retorno'
                 ,pr_vldantes   => (CASE WHEN vr_tab_param.COUNT > 0 THEN NVL(vr_tab_param(0).dsassunto_retorno,' ') ELSE '' END)
                 ,pr_vldepois   => NVL(pr_dsassunto_retorno,' '));

      pc_item_log(pr_cdcooper   => vr_cdcooper
                 ,pr_cddopcao   => vr_cddopcao
                 ,pr_cdoperad   => vr_cdoperad
                 ,pr_cdoperacao => pr_cdoperacao
                 ,pr_tpoperacao => pr_tpoperacao
                 ,pr_dsdcampo   => 'conteudo do retorno'
                 ,pr_vldantes   => (CASE WHEN vr_tab_param.COUNT > 0 THEN NVL(vr_tab_param(0).dscorpo_retorno,' ') ELSE '' END)
                 ,pr_vldepois   => NVL(vr_dscorpo_retorno,' '));

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
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
        pr_dscritic := 'Erro geral na rotina da tela CADFRA: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_dados;

  PROCEDURE pc_exclui_dados(pr_cdoperacao IN tbgen_analise_fraude_param.cdoperacao%TYPE --> Codigo da operacao
                        	 ,pr_tpoperacao IN tbgen_analise_fraude_param.tpoperacao%TYPE --> Tipo da operacao
                           ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml  IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro   OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_exclui_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir os dados.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
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

      BEGIN

        DELETE 
          FROM tbgen_analise_fraude_interv
         WHERE tbgen_analise_fraude_interv.cdoperacao = pr_cdoperacao
           AND tbgen_analise_fraude_interv.tpoperacao = pr_tpoperacao;

        DELETE 
          FROM tbgen_analise_fraude_param
         WHERE tbgen_analise_fraude_param.cdoperacao = pr_cdoperacao
           AND tbgen_analise_fraude_param.tpoperacao = pr_tpoperacao;

      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao excluir: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      pc_item_log(pr_cdcooper   => vr_cdcooper
                 ,pr_cddopcao   => 'E'
                 ,pr_cdoperad   => vr_cdoperad
                 ,pr_cdoperacao => pr_cdoperacao
                 ,pr_tpoperacao => pr_tpoperacao
                 ,pr_dsdcampo   => ''
                 ,pr_vldantes   => ''
                 ,pr_vldepois   => '');

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
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
        pr_dscritic := 'Erro geral na rotina da tela CADFRA: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_exclui_dados;

END TELA_CADFRA;
/
