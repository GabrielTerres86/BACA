CREATE OR REPLACE PACKAGE TELA_ATENDA_SCORE IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0005
  --  Sistema  : Aimaro
  --  Sigla    : CRED
  --  Autor    : Marcos (Envolti)
  --  Data     : Outubro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funções auxiliares para carga e visualização de Score Behaviour (P442)
  --
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Retorna o Score Behaviour do Cooperado enviado
  FUNCTION fn_score_behaviour(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) RETURN VARCHAR2;
                              
  /* Listar Scores disponíveis para Carga */
  PROCEDURE pc_lista_scores_carga(/* Parametros base da Mensageria */
                                  pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);        --> Erros do processo  
                                 
  /* Executar carga selecionada */
  PROCEDURE pc_exec_carga_scores(pr_cdmodelo   IN NUMBER           --> Codigo modelo
                                ,pr_dtbase     IN VARCHAR2         --> Data base
                                ,pr_cddopcao   IN VARCHAR2         --> Opção ([A]provação ou [R]ejeição
                                ,pr_dsrejeicao IN VARCHAR2         --> Motivo da rejeicao
                                /* Parametros base da Mensageria */
                                ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);        --> Erros do processo
  
  /* Listar Scores disponíveis para Carga */
  PROCEDURE pc_lista_histor_scores_carga(/* Parametros base da Mensageria */
                                        pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);        --> Erros do processo                                 

  /* Listar os Scores do CPF enviado */
  PROCEDURE pc_lista_scores_cooperado(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE -- CPF/CNPJ desejado
                                      /* Parametros base da Mensageria */
                                     ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);        --> Erros do processo  

  /* Listar as Exclusoes do Scores do CPF enviado */
  PROCEDURE pc_lista_excl_scores_cooperado(pr_cdmodelo IN NUMBER        --> Codigo Modelo
                                          ,pr_nrcpfcgc IN NUMBER        --> CPF / CNPJ do Score
                                          ,pr_dtbase   IN VARCHAR2      --> Data base do Score
                                           /* Parametros base da Mensageria */
                                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);        --> Erros do processo  

END TELA_ATENDA_SCORE;
/
CREATE OR REPLACE PACKAGE BODY TELA_ATENDA_SCORE AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0005
  --  Sistema  : Aimaro
  --  Sigla    : CRED
  --  Autor    : Marcos (Envolti)
  --  Data     : Outubro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funções auxiliares para carga e visualização de Score Behaviour (P442)
  --
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Retorna o Score Behaviour do Cooperado enviado
  FUNCTION fn_score_behaviour(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) RETURN VARCHAR2 IS
  BEGIN
    /*OPEN RISC0004.cr_dat(pr_cdcooper);
    FETCH RISC0004.cr_dat INTO rw_dat;
    CLOSE RISC0004.cr_dat;*/
    RETURN 123;
  END fn_score_behaviour;
  
  /* Listar Scores disponíveis para Carga */
  PROCEDURE pc_lista_scores_carga(/* Parametros base da Mensageria */
                                  pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_lista_scores_carga
    Sistema : Ayllos Web
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro - 2018.                Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar Modelos Carga Scores Comportamentais do Cooperado enviad
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
        -- Selecionar os dados de indexadores pelo nome
        /*CURSOR cr_indicadores IS
            SELECT idindicador
                  ,nmindicador
                  ,dsindicador
                  ,decode(flgativo, 1, 'Sim', 'Não') flgativo
                  ,decode(tpindicador, 'Q', 'Quantidade', 'M', 'Moeda', 'Adesão') tpindicador
              FROM tbrecip_indicador
             ORDER BY idindicador;*/
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
        -- Variaveis auxiliares
        vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
    BEGIN
      
      -- Validar chamada
      
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      FOR idx IN 1..5 LOOP
        
        -- No raiz do Score
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'ScoreCarga'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        -- Campos
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ScoreCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdmodelo'
                              ,pr_tag_cont => idx
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ScoreCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsmodelo'
                              ,pr_tag_cont => 'Score Comportamental'
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ScoreCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dtbase'
                              ,pr_tag_cont => '29/10/2018'
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ScoreCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregistro'
                              ,pr_tag_cont => '17'
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ScoreCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregis_fisica'
                              ,pr_tag_cont => 12
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ScoreCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregis_juridi'
                              ,pr_tag_cont => '5'
                              ,pr_des_erro => vr_dscritic);               
        vr_auxconta := vr_auxconta + 1;
      
      END LOOP;
      
      -- Retornar quantidade de registros
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_saida THEN        
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela SCORE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_lista_scores_carga;  
  
  /* Executar carga selecionada */
  PROCEDURE pc_exec_carga_scores(pr_cdmodelo   IN NUMBER           --> Codigo modelo
                                ,pr_dtbase     IN VARCHAR2         --> Data base
                                ,pr_cddopcao   IN VARCHAR2         --> Opção ([A]provação ou [R]ejeição
                                ,pr_dsrejeicao IN VARCHAR2         --> Motivo da rejeicao
                                /* Parametros base da Mensageria */
                                ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_exec_carga_scores
    Sistema : Ayllos Web
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro - 2018.                Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para executar a carga do score selecionado
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
        -- Selecionar os dados de indexadores pelo nome
        /*CURSOR cr_indicadores IS
            SELECT idindicador
                  ,nmindicador
                  ,dsindicador
                  ,decode(flgativo, 1, 'Sim', 'Não') flgativo
                  ,decode(tpindicador, 'Q', 'Quantidade', 'M', 'Moeda', 'Adesão') tpindicador
              FROM tbrecip_indicador
             ORDER BY idindicador;*/
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
        -- Variaveis auxiliares
        vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
    BEGIN
      
      -- Validar chamada
      NULL;
      
    EXCEPTION
      WHEN vr_exc_saida THEN        
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela SCORE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_exec_carga_scores;     
  
  /* Listar Scores disponíveis para Carga */
  PROCEDURE pc_lista_histor_scores_carga(/* Parametros base da Mensageria */
                                        pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_lista_scores_carga
    Sistema : Ayllos Web
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro - 2018.                Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar Modelos Carga Scores Comportamentais do Cooperado enviad
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
        -- Selecionar os dados de indexadores pelo nome
        /*CURSOR cr_indicadores IS
            SELECT idindicador
                  ,nmindicador
                  ,dsindicador
                  ,decode(flgativo, 1, 'Sim', 'Não') flgativo
                  ,decode(tpindicador, 'Q', 'Quantidade', 'M', 'Moeda', 'Adesão') tpindicador
              FROM tbrecip_indicador
             ORDER BY idindicador;*/
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
        -- Variaveis auxiliares
        vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
    BEGIN
      
      -- Validar chamada
      
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      FOR idx IN 1..5 LOOP
        
        -- No raiz do Score
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'HistCarga'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        -- Campos
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdmodelo'
                              ,pr_tag_cont => idx
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsmodelo'
                              ,pr_tag_cont => 'Score Comportamental'
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dtbase'
                              ,pr_tag_cont => '29/10/2018'
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dtinicio'
                              ,pr_tag_cont => '29/10/2018 08:12:01'
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dttermino'
                              ,pr_tag_cont => '29/10/2018 08:14:15'
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdoperad'
                              ,pr_tag_cont => '1-SUPER USUARIO'
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregistro'
                              ,pr_tag_cont => 17
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregis_fisica'
                              ,pr_tag_cont => 12
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregis_juridi'
                              ,pr_tag_cont => '5'
                              ,pr_des_erro => vr_dscritic);               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dssituac'
                              ,pr_tag_cont => 'Rejeitada'
                              ,pr_des_erro => vr_dscritic);               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsrejeicao'
                              ,pr_tag_cont => 'Rejeitado....'
                              ,pr_des_erro => vr_dscritic);               
        vr_auxconta := vr_auxconta + 1;
      
      END LOOP;
      
      -- Retornar quantidade de registros
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_saida THEN        
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela SCORE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_lista_histor_scores_carga;   
  
  /* Listar os Scores do CPF enviado */
  PROCEDURE pc_lista_scores_cooperado(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE -- CPF/CNPJ desejado
                                      /* Parametros base da Mensageria */
                                     ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_lista_scores_cooperado
    Sistema : Ayllos Web
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro - 2018.                Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar Scores Comportamentais do Cooperado enviad
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
        -- Selecionar os dados de indexadores pelo nome
        /*CURSOR cr_indicadores IS
            SELECT idindicador
                  ,nmindicador
                  ,dsindicador
                  ,decode(flgativo, 1, 'Sim', 'Não') flgativo
                  ,decode(tpindicador, 'Q', 'Quantidade', 'M', 'Moeda', 'Adesão') tpindicador
              FROM tbrecip_indicador
             ORDER BY idindicador;*/
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
        -- Variaveis auxiliares
        vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
    BEGIN
      
      -- Validar chamada
      
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      FOR idx IN 1..5 LOOP
        
        -- No raiz do Score
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Score'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        -- Campos
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Score'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdmodelo'
                              ,pr_tag_cont => idx
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Score'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsmodelo_score'
                              ,pr_tag_cont => 'Modelo'
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Score'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dtbase'
                              ,pr_tag_cont => '29/10/2018'
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Score'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsclasse_score'
                              ,pr_tag_cont => 'Classe'
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Score'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'nrscore_alinhado'
                              ,pr_tag_cont => 55
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Score'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsexclusao_principal'
                              ,pr_tag_cont => 'Exclusao Principal'
                              ,pr_des_erro => vr_dscritic);                                
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Score'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dssituacao_score'
                              ,pr_tag_cont => 'Vigente'
                              ,pr_des_erro => vr_dscritic);               
        vr_auxconta := vr_auxconta + 1;
      
      END LOOP;
      
      -- Retornar quantidade de registros
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_saida THEN        
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela SCORE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_lista_scores_cooperado;  
  
  /* Listar as Exclusoes do Scores do CPF enviado */
  PROCEDURE pc_lista_excl_scores_cooperado(pr_cdmodelo IN NUMBER        --> Codigo Modelo
                                          ,pr_nrcpfcgc IN NUMBER        --> CPF / CNPJ do Score
                                          ,pr_dtbase   IN VARCHAR2      --> Data base do Score
                                           /* Parametros base da Mensageria */
                                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_lista_excl_scores_cooperado
    Sistema : Ayllos Web
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro - 2018.                Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar as Exclusões dos Scores Comportamentais do Cooperado enviado
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
        -- Selecionar os dados de indexadores pelo nome
        /*CURSOR cr_indicadores IS
            SELECT idindicador
                  ,nmindicador
                  ,dsindicador
                  ,decode(flgativo, 1, 'Sim', 'Não') flgativo
                  ,decode(tpindicador, 'Q', 'Quantidade', 'M', 'Moeda', 'Adesão') tpindicador
              FROM tbrecip_indicador
             ORDER BY idindicador;*/
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
        -- Variaveis auxiliares
        vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
    BEGIN
      
      -- Validar chamada
      
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      FOR idx IN 1..5 LOOP
        
        -- No raiz do Score
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'ExclScore'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        -- Campos
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ExclScore'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdexclusao'
                              ,pr_tag_cont => 111
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ExclScore'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsexclusao'
                              ,pr_tag_cont => 'Testesdsdsds dsdsdsds exclusao '||idx
                              ,pr_des_erro => vr_dscritic);          
        vr_auxconta := vr_auxconta + 1;
      
      END LOOP;
      
      -- Retornar quantidade de registros
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_saida THEN        
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela SCORE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_lista_excl_scores_cooperado;    

END TELA_ATENDA_SCORE;
/
