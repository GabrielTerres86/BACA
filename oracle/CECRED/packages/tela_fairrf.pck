CREATE OR REPLACE PACKAGE CECRED.tela_fairrf IS

  PROCEDURE pc_busca_faixa_irrf_por_pessoa(pr_inpessoa IN tbcotas_faixas_irrf.inpessoa%TYPE
                                          ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_mantem_faixa_irrf(pr_cdfaixa           IN tbcotas_faixas_irrf.cdfaixa%TYPE
                                ,pr_inpessoa          IN tbcotas_faixas_irrf.inpessoa%TYPE
                                ,pr_vlfaixa_inicial   IN tbcotas_faixas_irrf.vlfaixa_inicial%TYPE
                                ,pr_vlfaixa_final     IN tbcotas_faixas_irrf.vlfaixa_final%TYPE
                                ,pr_vlpercentual_irrf IN tbcotas_faixas_irrf.vlpercentual_irrf%TYPE
                                ,pr_vldeducao         IN tbcotas_faixas_irrf.vldeducao%TYPE
                                ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro          OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_exclui_faixa_irrf(pr_cdfaixa           IN tbcotas_faixas_irrf.cdfaixa%TYPE
                                ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro          OUT VARCHAR2); --> Erros do processo

END tela_fairrf;
/

CREATE OR REPLACE PACKAGE BODY CECRED.tela_fairrf IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_FAIRRF
  --  Sistema  : Ayllos Web
  --  Autor    : Dionathan Henchel
  --  Data     : Dezembro - 2015.                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela FAIRRF
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_faixa_irrf_por_pessoa(pr_inpessoa IN tbcotas_faixas_irrf.inpessoa%TYPE
                                          ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_faixa_irrf_por_pessoa
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Dezembro/2015                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar faixas de IRRF sobre rendimento do capital.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_fairrf IS
        SELECT *
          FROM tbcotas_faixas_irrf fairrf
         WHERE fairrf.inpessoa = pr_inpessoa
         ORDER BY fairrf.vlfaixa_inicial;
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      -- Variaveis de log
      /* vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);*/
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
    BEGIN
      -- Não precisa executar pois neste processo não utilizamos estes dados
      /*gene0004.pc_extrai_dados(pr_xml      => pr_retxml
      ,pr_cdcooper => vr_cdcooper
      ,pr_nmdatela => vr_nmdatela
      ,pr_nmeacao  => vr_nmeacao
      ,pr_cdagenci => vr_cdagenci
      ,pr_nrdcaixa => vr_nrdcaixa
      ,pr_idorigem => vr_idorigem
      ,pr_cdoperad => vr_cdoperad
      ,pr_dscritic => vr_dscritic);*/
    
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
    
      FOR rw_fairrf IN cr_fairrf LOOP
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'faixa'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'faixa'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdfaixa'
                              ,pr_tag_cont => to_char(rw_fairrf.cdfaixa)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'faixa'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'inpessoa'
                              ,pr_tag_cont => to_char(rw_fairrf.inpessoa)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'faixa'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vlfaixa_inicial'
                              ,pr_tag_cont => to_char(rw_fairrf.vlfaixa_inicial)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'faixa'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vlfaixa_final'
                              ,pr_tag_cont => to_char(rw_fairrf.vlfaixa_final)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'faixa'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vlpercentual_irrf'
                              ,pr_tag_cont => to_char(rw_fairrf.vlpercentual_irrf)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'faixa'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vldeducao'
                              ,pr_tag_cont => to_char(rw_fairrf.vldeducao)
                              ,pr_des_erro => vr_dscritic);
      
        vr_auxconta := vr_auxconta + 1;
      
      END LOOP;
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Qtdregis'
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
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela FAIRRF: ' || SQLERRM;
      
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;
  
  END pc_busca_faixa_irrf_por_pessoa;

  PROCEDURE pc_mantem_faixa_irrf(pr_cdfaixa           IN tbcotas_faixas_irrf.cdfaixa%TYPE
                                ,pr_inpessoa          IN tbcotas_faixas_irrf.inpessoa%TYPE
                                ,pr_vlfaixa_inicial   IN tbcotas_faixas_irrf.vlfaixa_inicial%TYPE
                                ,pr_vlfaixa_final     IN tbcotas_faixas_irrf.vlfaixa_final%TYPE
                                ,pr_vlpercentual_irrf IN tbcotas_faixas_irrf.vlpercentual_irrf%TYPE
                                ,pr_vldeducao         IN tbcotas_faixas_irrf.vldeducao%TYPE
                                ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_faixa_irrf_por_pessoa
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Dezembro/2015                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para inserir novas faixas de IRRF sobre rendimento do capital.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_valida_faixa IS
        SELECT DISTINCT 1
          FROM tbcotas_faixas_irrf fairrf
         WHERE fairrf.inpessoa = pr_inpessoa
           AND fairrf.cdfaixa <> NVL(pr_cdfaixa, 0)
           AND fairrf.vlfaixa_inicial <= pr_vlfaixa_final
           AND fairrf.vlfaixa_final >= pr_vlfaixa_inicial;
      vr_valida_faixa NUMBER(1);
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      -- Variaveis de log
      /*vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);*/
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ registros atualizados
    
    BEGIN
      -- Não precisa executar pois neste processo não utilizamos estes dados
      /*gene0004.pc_extrai_dados(pr_xml      => pr_retxml
      ,pr_cdcooper => vr_cdcooper
      ,pr_nmdatela => vr_nmdatela
      ,pr_nmeacao  => vr_nmeacao
      ,pr_cdagenci => vr_cdagenci
      ,pr_nrdcaixa => vr_nrdcaixa
      ,pr_idorigem => vr_idorigem
      ,pr_cdoperad => vr_cdoperad
      ,pr_dscritic => vr_dscritic);*/
    
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
              
      -- Valida se Valor Inicial é menor que Valor Final
      IF pr_vlfaixa_inicial > pr_vlfaixa_final THEN
        vr_dscritic := 'Valor Inicial deve ser menor que Valor Final.';
        RAISE vr_exc_saida;
      END IF;
    
      -- Valida se a faixa atual corrompe outra faixa cadastrada
      vr_valida_faixa := 0;
      OPEN cr_valida_faixa;
      FETCH cr_valida_faixa
        INTO vr_valida_faixa;
      CLOSE cr_valida_faixa;
    
      IF vr_valida_faixa = 1 THEN
        vr_dscritic := 'Os valores desta faixa invadem outra faixa cadastrada.';
        RAISE vr_exc_saida;
      END IF;
    
      IF pr_cdfaixa = 0 OR pr_cdfaixa IS NULL THEN
        -- EXECUTA INSERÇÃO
        BEGIN
        
          INSERT INTO tbcotas_faixas_irrf fairrf
            (cdfaixa
            ,inpessoa
            ,vlfaixa_inicial
            ,vlfaixa_final
            ,vlpercentual_irrf
            ,vldeducao)
          VALUES
            ((SELECT NVL(MAX(cdfaixa), 0) + 1
               FROM tbcotas_faixas_irrf fairrf)
            ,pr_inpessoa
            ,pr_vlfaixa_inicial
            ,pr_vlfaixa_final
            ,pr_vlpercentual_irrf
            ,pr_vldeducao);
        
          vr_auxconta := SQL%ROWCOUNT;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Ocorreu um erro ao inserir o registro.';
            RAISE vr_exc_saida;
        END;
      
        IF vr_auxconta = 0 THEN
          vr_dscritic := 'Nenhum registro inserido.';
          RAISE vr_exc_saida;
        END IF;
      ELSE
        -- EXECUTA ALTERAÇÃO
        BEGIN
        
          UPDATE tbcotas_faixas_irrf fairrf
             SET inpessoa          = pr_inpessoa
                ,vlfaixa_inicial   = pr_vlfaixa_inicial
                ,vlfaixa_final     = pr_vlfaixa_final
                ,vlpercentual_irrf = pr_vlpercentual_irrf
                ,vldeducao         = pr_vldeducao
           WHERE cdfaixa = pr_cdfaixa;
        
          vr_auxconta := SQL%ROWCOUNT;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Ocorreu um erro ao atualizar o registro.';
            RAISE vr_exc_saida;
        END;
      
        IF vr_auxconta = 0 THEN
          vr_dscritic := 'Nenhum registro atualizado.';
          RAISE vr_exc_saida;
        END IF;
      
      END IF;
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);
    
    COMMIT;
    
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
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela FAIRRF: ' || SQLERRM;
      
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;
  
  END pc_mantem_faixa_irrf;

  PROCEDURE pc_exclui_faixa_irrf(pr_cdfaixa           IN tbcotas_faixas_irrf.cdfaixa%TYPE
                                ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_faixa_irrf_por_pessoa
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Dezembro/2015                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para excluir faixas de IRRF sobre rendimento do capital.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      -- Variaveis de log
      /*vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);*/
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ registros atualizados
    
    BEGIN
      -- Não precisa executar pois neste processo não utilizamos estes dados
      /*gene0004.pc_extrai_dados(pr_xml      => pr_retxml
      ,pr_cdcooper => vr_cdcooper
      ,pr_nmdatela => vr_nmdatela
      ,pr_nmeacao  => vr_nmeacao
      ,pr_cdagenci => vr_cdagenci
      ,pr_nrdcaixa => vr_nrdcaixa
      ,pr_idorigem => vr_idorigem
      ,pr_cdoperad => vr_cdoperad
      ,pr_dscritic => vr_dscritic);*/
    
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
    
      -- EXECUTA EXCLUSÃO
      BEGIN
      
        DELETE
          FROM tbcotas_faixas_irrf fairrf
         WHERE fairrf.cdfaixa = pr_cdfaixa;
      
        vr_auxconta := SQL%ROWCOUNT;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Ocorreu um erro ao inserir o registro';
          RAISE vr_exc_saida;
      END;
    
      IF vr_auxconta = 0 THEN
        vr_dscritic := 'Nenhum registro inserido';
        RAISE vr_exc_saida;
      END IF;
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);
    
    COMMIT;
    
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
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela FAIRRF: ' || SQLERRM;
      
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;
  
  END pc_exclui_faixa_irrf;

END tela_fairrf;
/

