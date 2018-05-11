CREATE OR REPLACE PACKAGE CECRED.TELA_PRMPOS IS
  
  -- Definicao do tipo de registro
  TYPE typ_reg_param IS
  RECORD (vlminimo_emprestado tbepr_posfix_param.vlminimo_emprestado%TYPE
         ,vlmaximo_emprestado tbepr_posfix_param.vlmaximo_emprestado%TYPE
         ,qtdminima_parcela   tbepr_posfix_param.qtdminima_parcela%TYPE
         ,qtdmaxima_parcela   tbepr_posfix_param.qtdmaxima_parcela%TYPE);

  -- Definicao do tipo de tabela registro
  TYPE typ_tab_param IS TABLE OF typ_reg_param INDEX BY PLS_INTEGER;

  PROCEDURE pc_carrega_dados(pr_tab_param OUT typ_tab_param --> PLTABLE com os dados
                            ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic  OUT VARCHAR2); --> Descricao da critica

  PROCEDURE pc_busca_dados(pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_indexador(pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_carencia(pr_flghabilitado IN tbepr_posfix_param_carencia.flghabilitado%TYPE --> Habilitado (0-Nao/1-Sim/2-Todos)
                             ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                             ,pr_cdcritic     OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic     OUT VARCHAR2 --> Descricao da critica
                             ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo     OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro     OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_dados(pr_vlminimo_emprestado    IN tbepr_posfix_param.vlminimo_emprestado%TYPE --> Valor Minimo Emprestado
                        	,pr_vlmaximo_emprestado    IN tbepr_posfix_param.vlmaximo_emprestado%TYPE --> Valor Maximo Emprestado
                        	,pr_qtdminima_parcela      IN tbepr_posfix_param.qtdminima_parcela%TYPE --> Quantidade Minima Parcela
                        	,pr_qtdmaxima_parcela      IN tbepr_posfix_param.qtdmaxima_parcela%TYPE --> Quantidade Maxima Parcela
                          ,pr_strPeriodicidadeIndex  IN VARCHAR2 --> Contem as Periodicidades dos Indexadores
                          ,pr_strPeriodicidadeCaren  IN VARCHAR2 --> Contem as Periodicidades das Carencias
                          ,pr_xmllog                 IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic              OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic              OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml             IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo              OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro              OUT VARCHAR2); --> Erros do processo

END TELA_PRMPOS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PRMPOS IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_PRMPOS
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Marco - 2017                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela PRMPOS
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  
  -- Definicao do tipo de registro
  TYPE typ_reg_index IS
  RECORD (cddindex      crapind.cddindex%TYPE
         ,nmdindex      crapind.nmdindex%TYPE
         ,tpatualizacao tbepr_posfix_param_index.tpatualizacao%TYPE);

  TYPE typ_reg_caren IS
  RECORD (idcarencia    tbepr_posfix_param_carencia.idcarencia%TYPE
         ,dscarencia    tbepr_posfix_param_carencia.dscarencia%TYPE
         ,qtddias       tbepr_posfix_param_carencia.qtddias%TYPE
         ,flghabilitado tbepr_posfix_param_carencia.flghabilitado%TYPE);

  TYPE typ_reg_perio IS RECORD(nmperiodo VARCHAR2(10));

  -- Definicao do tipo de tabela registro
  TYPE typ_tab_index IS TABLE OF typ_reg_index INDEX BY PLS_INTEGER;
  TYPE typ_tab_caren IS TABLE OF typ_reg_caren INDEX BY PLS_INTEGER;
  TYPE typ_tab_perio IS TABLE OF typ_reg_perio INDEX BY PLS_INTEGER;

  -- Vetor para armazenar os dados da tabela
  vr_tab_param typ_tab_param;
  vr_tab_index typ_tab_index;
  vr_tab_caren typ_tab_caren;
  vr_tab_perio typ_tab_perio;

  PROCEDURE pc_carrega_dados(pr_tab_param OUT typ_tab_param --> PLTABLE com os dados
                            ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic  OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_carrega_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_param IS
        SELECT param.vlminimo_emprestado
              ,param.vlmaximo_emprestado
              ,param.qtdminima_parcela
              ,param.qtdmaxima_parcela
          FROM tbepr_posfix_param param
         WHERE param.idparametro = 1;
      rw_param cr_param%ROWTYPE;
      
      -- Variaveis Gerais
      vr_blnfound BOOLEAN;

    BEGIN
      -- Limpa PLTABLE
      pr_tab_param.DELETE;

      -- Selecionar os dados
      OPEN cr_param;
      FETCH cr_param INTO rw_param;
      -- Alimenta a booleana
      vr_blnfound := cr_param%FOUND;
      -- Fechar o cursor
      CLOSE cr_param;

      -- Se encontrou
      IF vr_blnfound THEN

        -- Carrega os dados na PLTRABLE
        pr_tab_param(0).vlminimo_emprestado := rw_param.vlminimo_emprestado;
        pr_tab_param(0).vlmaximo_emprestado := rw_param.vlmaximo_emprestado;
        pr_tab_param(0).qtdminima_parcela   := rw_param.qtdminima_parcela;
        pr_tab_param(0).qtdmaxima_parcela   := rw_param.qtdmaxima_parcela;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela PRMPOS: ' || SQLERRM;
    END;

  END pc_carrega_dados;

  PROCEDURE pc_carrega_indexador(pr_tab_index OUT typ_tab_index --> PLTABLE com os dados
                                ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic  OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_carrega_indexador
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_param IS
        SELECT crapind.cddindex
              ,crapind.nmdindex
              ,param.tpatualizacao
          FROM tbepr_posfix_param_index param
              ,crapind
         WHERE param.cddindex    = crapind.cddindex
           AND param.idparametro = 1
      ORDER BY crapind.cddindex;

      -- Variaveis
      vr_contador INTEGER := 0;

    BEGIN
      -- Limpa PLTABLE
      pr_tab_index.DELETE;

      -- Listagem de parametro
      FOR rw_param IN cr_param LOOP

        -- Carrega os dados na PLTRABLE
        pr_tab_index(vr_contador).cddindex      := rw_param.cddindex;
        pr_tab_index(vr_contador).nmdindex      := rw_param.nmdindex;
        pr_tab_index(vr_contador).tpatualizacao := rw_param.tpatualizacao;

        vr_contador := vr_contador + 1;

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela PRMPOS: ' || SQLERRM;
    END;

  END pc_carrega_indexador;

  PROCEDURE pc_carrega_carencia(pr_flghabilitado IN tbepr_posfix_param_carencia.flghabilitado%TYPE --> Habilitado (0-Nao/1-Sim/2-Todos)
                               ,pr_tab_caren    OUT typ_tab_caren --> PLTABLE com os dados
                               ,pr_cdcritic     OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic     OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_carrega_carencia
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_param(pr_flghabilitado IN tbepr_posfix_param_carencia.flghabilitado%TYPE) IS
        SELECT param.idcarencia
              ,param.dscarencia
              ,param.qtddias
              ,param.flghabilitado
          FROM tbepr_posfix_param_carencia param
         WHERE param.idparametro = 1
           AND param.flghabilitado = DECODE(pr_flghabilitado, 2, param.flghabilitado, pr_flghabilitado)
      ORDER BY param.idcarencia;

      -- Variaveis
      vr_contador INTEGER := 0;

    BEGIN
      -- Limpa PLTABLE
      pr_tab_caren.DELETE;

      -- Listagem de parametro
      FOR rw_param IN cr_param(pr_flghabilitado => pr_flghabilitado) LOOP

        -- Carrega os dados na PLTRABLE
        pr_tab_caren(vr_contador).idcarencia    := rw_param.idcarencia;
        pr_tab_caren(vr_contador).dscarencia    := rw_param.dscarencia;
        pr_tab_caren(vr_contador).qtddias       := rw_param.qtddias;
        pr_tab_caren(vr_contador).flghabilitado := rw_param.flghabilitado;

        vr_contador := vr_contador + 1;

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela PRMPOS: ' || SQLERRM;
    END;

  END pc_carrega_carencia;

  PROCEDURE pc_busca_dados(pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
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
    Data    : Marco/2017                 Ultima atualizacao: 

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
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_PRMPOS'
                                ,pr_action => NULL);
      -- Carrega os dados
      pc_carrega_dados(pr_tab_param => vr_tab_param
                      ,pr_cdcritic  => vr_cdcritic
                      ,pr_dscritic  => vr_dscritic);

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
                              ,pr_tag_nova => 'vlminimo_emprestado'
                              ,pr_tag_cont => TO_CHAR(vr_tab_param(0).vlminimo_emprestado,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vlmaximo_emprestado'
                              ,pr_tag_cont => TO_CHAR(vr_tab_param(0).vlmaximo_emprestado,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'qtdminima_parcela'
                              ,pr_tag_cont => vr_tab_param(0).qtdminima_parcela
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'qtdmaxima_parcela'
                              ,pr_tag_cont => vr_tab_param(0).qtdmaxima_parcela
                              ,pr_des_erro => vr_dscritic);
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
        pr_dscritic := 'Erro geral na rotina da tela PRMPOS: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_dados;

  PROCEDURE pc_busca_indexador(pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_indexador
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os indexadores.

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
      pc_carrega_indexador(pr_tab_index => vr_tab_index
                          ,pr_cdcritic  => vr_cdcritic
                          ,pr_dscritic  => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Buscar Primeiro registro
      vr_index:= vr_tab_index.FIRST;

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
                              ,pr_tag_nova => 'cddindex'
                              ,pr_tag_cont => vr_tab_index(vr_index).cddindex
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'param'
                              ,pr_posicao  => vr_index
                              ,pr_tag_nova => 'nmdindex'
                              ,pr_tag_cont => vr_tab_index(vr_index).nmdindex
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'param'
                              ,pr_posicao  => vr_index
                              ,pr_tag_nova => 'tpatualizacao'
                              ,pr_tag_cont => vr_tab_index(vr_index).tpatualizacao
                              ,pr_des_erro => vr_dscritic);

        -- Proximo Registro
        vr_index:= vr_tab_index.NEXT(vr_index);
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
        pr_dscritic := 'Erro geral na rotina da tela PRMPOS: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_indexador;

  PROCEDURE pc_busca_carencia(pr_flghabilitado IN tbepr_posfix_param_carencia.flghabilitado%TYPE --> Habilitado (0-Nao/1-Sim/2-Todos)
                             ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                             ,pr_cdcritic     OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic     OUT VARCHAR2 --> Descricao da critica
                             ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo     OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro     OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_carencia
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as carencias.

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
      pc_carrega_carencia(pr_flghabilitado => pr_flghabilitado
                         ,pr_tab_caren     => vr_tab_caren
                         ,pr_cdcritic      => vr_cdcritic
                         ,pr_dscritic      => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Buscar Primeiro registro
      vr_index:= vr_tab_caren.FIRST;

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
                              ,pr_tag_nova => 'idcarencia'
                              ,pr_tag_cont => vr_tab_caren(vr_index).idcarencia
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'param'
                              ,pr_posicao  => vr_index
                              ,pr_tag_nova => 'dscarencia'
                              ,pr_tag_cont => vr_tab_caren(vr_index).dscarencia
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'param'
                              ,pr_posicao  => vr_index
                              ,pr_tag_nova => 'qtddias'
                              ,pr_tag_cont => vr_tab_caren(vr_index).qtddias
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'param'
                              ,pr_posicao  => vr_index
                              ,pr_tag_nova => 'flghabilitado'
                              ,pr_tag_cont => vr_tab_caren(vr_index).flghabilitado
                              ,pr_des_erro => vr_dscritic);

        -- Proximo Registro
        vr_index:= vr_tab_caren.NEXT(vr_index);
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
        pr_dscritic := 'Erro geral na rotina da tela PRMPOS: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_carencia;

  PROCEDURE pc_item_log(pr_cdcooper IN INTEGER --> Codigo da cooperativa
                       ,pr_cdoperad IN VARCHAR2 --> Codigo do operador
                       ,pr_dsdcampo IN VARCHAR2 --> Descricao do campo
                       ,pr_vldantes IN VARCHAR2 --> Valor antes
                       ,pr_vldepois IN VARCHAR2) IS  --> Valor depois
  BEGIN

    /* .............................................................................

    Programa: pc_item_log
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os itens do LOG.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

    BEGIN
      -- Se nao tem diferenca, retorna
      IF pr_vldantes = pr_vldepois THEN
        RETURN;
      END IF;

    	-- Geral LOG
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratado
                                ,pr_nmarqlog     => 'prmpos.log'
                                ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                    ' --> Operador ' || pr_cdoperad ||
                                                    ' alterou o campo ' || pr_dsdcampo ||
                                                    ' de ' || pr_vldantes ||
                                                    ' para ' || pr_vldepois);
    END;

  END pc_item_log;

  PROCEDURE pc_grava_indexador(pr_cdcooper              IN INTEGER --> Codigo da cooperativa
                              ,pr_cdoperad              IN VARCHAR2 --> Codigo do operador
                              ,pr_strPeriodicidadeIndex IN VARCHAR2 --> Contem as Periodicidades dos Indexadores
                              ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic             OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_grava_indexador
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os indexadores.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis
      vr_index         PLS_INTEGER;
      vr_strperiod     GENE0002.typ_split;
      vr_cddindex      tbepr_posfix_param_index.cddindex%TYPE;
      vr_nmdindex      crapind.nmdindex%TYPE;
      vr_tpatualizacao tbepr_posfix_param_index.tpatualizacao%TYPE;
      vr_vldantes      VARCHAR2(50);

    BEGIN
      -- Carrega os nomes
      vr_tab_perio(1).nmperiodo := 'Diario';
      vr_tab_perio(2).nmperiodo := 'Quinzenal';
      vr_tab_perio(3).nmperiodo := 'Mensal';

      -- Carrega os dados
      pc_carrega_indexador(pr_tab_index => vr_tab_index
                          ,pr_cdcritic  => vr_cdcritic
                          ,pr_dscritic  => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      BEGIN
        DELETE
          FROM tbepr_posfix_param_index
         WHERE idparametro = 1;

        -- Quebra a string
        vr_strperiod := GENE0002.fn_quebra_string(pr_string  => pr_strPeriodicidadeIndex
                                                 ,pr_delimit => '#');
        FOR vr_ind IN 1..vr_strperiod.COUNT() LOOP

          vr_cddindex      := GENE0002.fn_busca_entrada(1,vr_strperiod(vr_ind),'_');
          vr_tpatualizacao := GENE0002.fn_busca_entrada(2,vr_strperiod(vr_ind),'_');

          INSERT INTO tbepr_posfix_param_index
                     (idparametro
                     ,cddindex
                     ,tpatualizacao)
               VALUES(1
                     ,vr_cddindex
                     ,vr_tpatualizacao);

          -- Reseta variavel
          vr_vldantes := '';

          -- Buscar Primeiro registro
          vr_index:= vr_tab_index.FIRST;
          -- Percorrer todos os registros
          WHILE vr_index IS NOT NULL LOOP
            IF vr_tab_index(vr_index).cddindex = vr_cddindex THEN
               vr_nmdindex := vr_tab_index(vr_index).nmdindex;
               vr_vldantes := vr_tab_perio(vr_tab_index(vr_index).tpatualizacao).nmperiodo;
               EXIT;
            END IF;
            -- Proximo Registro
            vr_index:= vr_tab_index.NEXT(vr_index);
          END LOOP;

          pc_item_log(pr_cdcooper   => pr_cdcooper
                     ,pr_cdoperad   => pr_cdoperad
                     ,pr_dsdcampo   => vr_nmdindex
                     ,pr_vldantes   => vr_vldantes
                     ,pr_vldepois   => vr_tab_perio(vr_tpatualizacao).nmperiodo);

        END LOOP;

      EXCEPTION
	      WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;

        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao cadastrar indexadores: ' || SQLERRM;
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
        pr_dscritic := 'Erro geral na rotina da tela PRMPOS: ' || SQLERRM;

    END;

  END pc_grava_indexador;

  PROCEDURE pc_grava_carencia(pr_cdcooper              IN INTEGER --> Codigo da cooperativa
                             ,pr_cdoperad              IN VARCHAR2 --> Codigo do operador
                             ,pr_strPeriodicidadeCaren IN VARCHAR2 --> Contem as Periodicidades dos Indexadores
                             ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic             OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_grava_carencia
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar as carencias.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis
      vr_index         PLS_INTEGER;
      vr_strperiod     GENE0002.typ_split;
      vr_idcarencia    tbepr_posfix_param_carencia.idcarencia%TYPE;
      vr_dscarencia    tbepr_posfix_param_carencia.dscarencia%TYPE;
      vr_flghabilitado tbepr_posfix_param_carencia.flghabilitado%TYPE;
      vr_vldantes      VARCHAR2(50);

    BEGIN
      -- Carrega os dados
      pc_carrega_carencia(pr_flghabilitado => 2 -- Todos
                         ,pr_tab_caren     => vr_tab_caren
                         ,pr_cdcritic      => vr_cdcritic
                         ,pr_dscritic      => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      BEGIN
        -- Quebra a string
        vr_strperiod := GENE0002.fn_quebra_string(pr_string  => pr_strPeriodicidadeCaren
                                                 ,pr_delimit => '#');
        FOR vr_ind IN 1..vr_strperiod.COUNT() LOOP

          vr_idcarencia    := GENE0002.fn_busca_entrada(1,vr_strperiod(vr_ind),'_');
          vr_flghabilitado := GENE0002.fn_busca_entrada(2,vr_strperiod(vr_ind),'_');

          UPDATE tbepr_posfix_param_carencia
             SET flghabilitado = vr_flghabilitado
           WHERE idparametro   = 1
             AND idcarencia    = vr_idcarencia;

          -- Reseta variavel
          vr_vldantes := '';

          -- Buscar Primeiro registro
          vr_index:= vr_tab_caren.FIRST;
          -- Percorrer todos os registros
          WHILE vr_index IS NOT NULL LOOP
            IF vr_tab_caren(vr_index).idcarencia = vr_idcarencia THEN
               vr_dscarencia := vr_tab_caren(vr_index).dscarencia;
               vr_vldantes   := vr_tab_caren(vr_index).flghabilitado;
               EXIT;
            END IF;
            -- Proximo Registro
            vr_index:= vr_tab_caren.NEXT(vr_index);
          END LOOP;

          pc_item_log(pr_cdcooper   => pr_cdcooper
                     ,pr_cdoperad   => pr_cdoperad
                     ,pr_dsdcampo   => 'Periodicidade de Carencia - ' || vr_dscarencia
                     ,pr_vldantes   => (CASE WHEN vr_vldantes = 1      THEN 'H' ELSE 'Des' END) || 'abilitado'
                     ,pr_vldepois   => (CASE WHEN vr_flghabilitado = 1 THEN 'H' ELSE 'Des' END) || 'abilitado');
        END LOOP;

      EXCEPTION
	      WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;

        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao cadastrar carencias: ' || SQLERRM;
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
        pr_dscritic := 'Erro geral na rotina da tela PRMPOS: ' || SQLERRM;

    END;

  END pc_grava_carencia;

  PROCEDURE pc_grava_dados(pr_vlminimo_emprestado    IN tbepr_posfix_param.vlminimo_emprestado%TYPE --> Valor Minimo Emprestado
                        	,pr_vlmaximo_emprestado    IN tbepr_posfix_param.vlmaximo_emprestado%TYPE --> Valor Maximo Emprestado
                        	,pr_qtdminima_parcela      IN tbepr_posfix_param.qtdminima_parcela%TYPE --> Quantidade Minima Parcela
                        	,pr_qtdmaxima_parcela      IN tbepr_posfix_param.qtdmaxima_parcela%TYPE --> Quantidade Maxima Parcela
                        	,pr_strPeriodicidadeIndex  IN VARCHAR2 --> Contem as Periodicidades dos Indexadores
                          ,pr_strPeriodicidadeCaren  IN VARCHAR2 --> Contem as Periodicidades das Carencias
                          ,pr_xmllog                 IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic              OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic              OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml             IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo              OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro              OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2017                 Ultima atualizacao: 

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

      -- Valida valor minimo
      IF pr_vlminimo_emprestado <= 0 THEN
         vr_dscritic := 'Valor mínimo deverá ser maior que zero.###vlminimo_emprestado';
         RAISE vr_exc_saida;
      END IF;

      -- Se valor minimo maior que maximo
      IF pr_vlminimo_emprestado > pr_vlmaximo_emprestado AND
         pr_vlmaximo_emprestado > 0                      THEN
         vr_dscritic := 'Valor máximo deverá ser maior que o mínimo.###vlmaximo_emprestado';
         RAISE vr_exc_saida;
      END IF;

      -- Valida quantidade minima
      IF pr_qtdminima_parcela <= 0 THEN
         vr_dscritic := 'Quantidade mínima deverá ser maior que zero.###qtdminima_parcela';
         RAISE vr_exc_saida;
      END IF;

      -- Se quantidade minima maior que maxima
      IF pr_qtdminima_parcela > pr_qtdmaxima_parcela AND
         pr_qtdmaxima_parcela > 0                    THEN
         vr_dscritic := 'Quantidade máxima deverá ser maior que a mínima.###qtdmaxima_parcela';
         RAISE vr_exc_saida;
      END IF;

      -- Carrega os dados
      pc_carrega_dados(pr_tab_param => vr_tab_param
                      ,pr_cdcritic  => vr_cdcritic
                      ,pr_dscritic  => vr_dscritic);
      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se encontrou registro
      IF vr_tab_param.COUNT > 0 THEN

        -- Atualiza dados
        BEGIN
          UPDATE tbepr_posfix_param
             SET vlminimo_emprestado = pr_vlminimo_emprestado
                ,vlmaximo_emprestado = pr_vlmaximo_emprestado
                ,qtdminima_parcela   = pr_qtdminima_parcela
                ,qtdmaxima_parcela   = pr_qtdmaxima_parcela
           WHERE idparametro         = 1;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao alterar dados na tabela tbepr_posfix_param: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

      END IF; -- vr_tab_param.COUNT > 0

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_dsdcampo => 'valor minimo'
                 ,pr_vldantes => (CASE WHEN vr_tab_param.COUNT > 0 THEN TO_CHAR(vr_tab_param(0).vlminimo_emprestado,'FM999G999G999G990D00') ELSE '' END)
                 ,pr_vldepois => TO_CHAR(pr_vlminimo_emprestado,'FM999G999G999G990D00'));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_dsdcampo => 'valor maximo'
                 ,pr_vldantes => (CASE WHEN vr_tab_param.COUNT > 0 THEN TO_CHAR(vr_tab_param(0).vlmaximo_emprestado,'FM999G999G999G990D00') ELSE '' END)
                 ,pr_vldepois => TO_CHAR(pr_vlmaximo_emprestado,'FM999G999G999G990D00'));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_dsdcampo => 'quantidade minima'
                 ,pr_vldantes => (CASE WHEN vr_tab_param.COUNT > 0 THEN vr_tab_param(0).qtdminima_parcela ELSE '' END)
                 ,pr_vldepois => pr_qtdminima_parcela);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_dsdcampo => 'quantidade maxima'
                 ,pr_vldantes => (CASE WHEN vr_tab_param.COUNT > 0 THEN vr_tab_param(0).qtdmaxima_parcela ELSE '' END)
                 ,pr_vldepois => pr_qtdmaxima_parcela);

      -- Chama gravacao dos indexadores
      pc_grava_indexador(pr_cdcooper              => vr_cdcooper
                        ,pr_cdoperad              => vr_cdoperad
                        ,pr_strPeriodicidadeIndex => pr_strPeriodicidadeIndex
                        ,pr_cdcritic              => vr_cdcritic
                        ,pr_dscritic              => vr_dscritic);
      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Chama gravacao das carencias
      pc_grava_carencia(pr_cdcooper              => vr_cdcooper
                       ,pr_cdoperad              => vr_cdoperad
                       ,pr_strPeriodicidadeCaren => pr_strPeriodicidadeCaren
                       ,pr_cdcritic              => vr_cdcritic
                       ,pr_dscritic              => vr_dscritic);
      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

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
        pr_dscritic := 'Erro geral na rotina da tela PRMPOS: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_dados;

END TELA_PRMPOS;
/
