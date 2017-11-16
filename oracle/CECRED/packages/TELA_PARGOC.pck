CREATE OR REPLACE PACKAGE CECRED.TELA_PARGOC AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_PARGOC
--    Autor   : Lucas Afonso
--    Data    : Outubro/2016                      Ultima Atualizacao:  /  /
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da tela PARGOC (Parâmetros Gerais para Garantias Operações Crédito)
--
--    Alteracoes:
--    
---------------------------------------------------------------------------------------------------------------

  -- Rotina para buscar as cooperativas
  PROCEDURE pc_busca_coop_pargoc(pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  -- Rotina para buscar os horarios do PA SEDE da cooperativa selecionada
  PROCEDURE pc_busca_params_pargoc(pr_cdcooper   IN INTEGER            --> Codigo da Cooperativa
                                    ,pr_cddopcao   IN VARCHAR2           --> Codigo da Opcao
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
                                  
  -- Rotina para alterar os horarios de pagamentos/estornos das cooperativas
  PROCEDURE pc_altera_params_pargoc(pr_cddopcao                 IN VARCHAR2           --> Opcao
                                   ,pr_cdcooper                 IN INTEGER            --> Codigo da Cooperativa (zero para todas)
                                   ,pr_inresgate_automatico     IN NUMBER             --> Resgate Automático
                                   ,pr_qtdias_atraso_permitido  IN NUMBER             --> Dias de atraso p/ resgate automático
                                   ,pr_peminimo_cobertura       IN NUMBER             --> % Mín Cobertura p/ Garantia
                                   ,pr_xmllog                   IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic                OUT PLS_INTEGER        --> Código da crítica
                                   ,pr_dscritic                OUT VARCHAR2           --> Descrição da crítica
                                   ,pr_retxml                   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo                OUT VARCHAR2           --> Nome do campo com erro
                                   ,pr_des_erro                OUT VARCHAR2);         --> Erros do processo
END TELA_PARGOC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARGOC AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_PARGOC
--    Autor   : Lucas Afonso
--    Data    : Outubro/2017                      Ultima Atualizacao:   /  /
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da tela PARGOC (Parâmetros Gerais para Garantias Operações Crédito)
--
--    Alteracoes: 
--
---------------------------------------------------------------------------------------------------------------
  -- Rotina para buscar as cooperativas 
  PROCEDURE pc_busca_coop_pargoc(pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    Programa: pc_busca_coop_pargoc
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Afonso
    Data    : 04/10/2017                      Ultima atualizacao:   /  /

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as cooperativas ativas

    Alteracoes:            
    ............................................................................. */
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
          FROM crapcop
         WHERE (pr_cdcooper = 3
           AND crapcop.cdcooper <> 3
           AND crapcop.flgativo = 1)
           OR (pr_cdcooper <> 3
           AND cdcooper = pr_cdcooper)
      ORDER BY crapcop.cdcooper;
      
      --Variaveis xml
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_dscritic crapcri.dscritic%TYPE;
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      /* Extrai os dados */
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
                              
      -- Verifica se houve erro                      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><cooperativas></cooperativas></Root>');
      
      FOR rw_crapcop IN cr_crapcop(vr_cdcooper) LOOP
        -- Cooperativas
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/cooperativas'
                                            ,XMLTYPE('<cooperativa>'
                                                   ||'  <cdcooper>'||rw_crapcop.cdcooper||'</cdcooper>'
                                                   ||'  <nmrescop>'||UPPER(rw_crapcop.nmrescop)||'</nmrescop>'
                                                   ||'</cooperativa>'));
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARGOC.pc_busca_coop_pargoc): ' || SQLERRM;
         -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_busca_coop_pargoc;

  -- Rotina para buscar os parametros da cooperativa selecionada
  PROCEDURE pc_busca_params_pargoc(pr_cdcooper   IN INTEGER            --> Codigo da Cooperativa
                                  ,pr_cddopcao   IN VARCHAR2           --> Codigo da Opcao
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo

    /* .............................................................................
    Programa: pc_busca_params_pargoc
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Afonso
    Data    : 05/10/2017                        Ultima atualizacao:   /  /

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar os parametros da Cooperativa selecionada

    Alteracoes:            
    ............................................................................. */
      -- Buscar os parametros da cooperativa
      CURSOR cr_tbgar_parame_geral (pr_cdcooper IN tbgar_parame_geral.cdcooper%TYPE) IS
        SELECT par.inresgate_automatico
              ,par.qtdias_atraso_permitido
              ,to_char(par.peminimo_cobertura,'990d00') peminimo_cobertura
          FROM tbgar_parame_geral par
         WHERE par.cdcooper = pr_cdcooper;
      rw_tbgar_parame_geral cr_tbgar_parame_geral%ROWTYPE; 
      
      -- Variavies xml
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
            
      -- Erros
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
    
    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PARGOC'
                                ,pr_action => null);
      
      /* Extrai os dados */
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
                              
      -- Verifica se houve erro                      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Verifica se é a cooperativa certa
      IF pr_cdcooper <> vr_cdcooper AND
         vr_cdcooper <> 3           THEN
        vr_dscritic := 'Não é possível buscar os parâmetros de outra cooperativa.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Buscar os parametros
      OPEN cr_tbgar_parame_geral(pr_cdcooper  => pr_cdcooper);
      FETCH cr_tbgar_parame_geral INTO rw_tbgar_parame_geral;
      --Se nao encontrou
      IF cr_tbgar_parame_geral%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_tbgar_parame_geral;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Parãmetros não encontrados para esta cooperativa.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_tbgar_parame_geral;
      
      -- Criar XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                     '<Root>' ||
                                     '  <parametros>' ||
                                     '    <inresgate_automatico>' || NVL(rw_tbgar_parame_geral.inresgate_automatico,'0') || '</inresgate_automatico>' || -- Resgate Automático
                                     '    <qtdias_atraso_permitido>' || NVL(rw_tbgar_parame_geral.qtdias_atraso_permitido,'0') || '</qtdias_atraso_permitido>' || -- Dias de atraso p/ resgate automático
                                     '    <peminimo_cobertura>' || NVL(rw_tbgar_parame_geral.peminimo_cobertura,'0.00') || '</peminimo_cobertura>' ||                -- % Mín Cobertura p/ Garantia
                                     '  </parametros>' ||
                                     '</Root>');
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARGOC.pc_busca_params_pargoc): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_busca_params_pargoc;

  -- Rotina para alterar os parametros das cooperativas
  PROCEDURE pc_altera_params_pargoc(pr_cddopcao                 IN VARCHAR2           --> Opcao
                                   ,pr_cdcooper                 IN INTEGER            --> Codigo da Cooperativa (zero para todas)
                                   ,pr_inresgate_automatico     IN NUMBER             --> Resgate Automático
                                   ,pr_qtdias_atraso_permitido  IN NUMBER             --> Dias de atraso p/ resgate automático
                                   ,pr_peminimo_cobertura       IN NUMBER             --> % Mín Cobertura p/ Garantia
                                   ,pr_xmllog                   IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic                OUT PLS_INTEGER        --> Código da crítica
                                   ,pr_dscritic                OUT VARCHAR2           --> Descrição da crítica
                                   ,pr_retxml                   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo                OUT VARCHAR2           --> Nome do campo com erro
                                   ,pr_des_erro                OUT VARCHAR2) IS       --> Erros do processo

    /* .............................................................................
    Programa: pc_altera_horario_pargoc
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Afonso
    Data    : 06/10/2017                        Ultima atualizacao:   /  /

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para alterar os parametros da cooperativa selecionada

    Alteracoes:                       
    ............................................................................. */
      -- CURSORES --
      -- Buscar os parametros da cooperativa
      CURSOR cr_tbgar_parame_geral (pr_cdcooper IN tbgar_parame_geral.cdcooper%TYPE) IS
        SELECT par.inresgate_automatico
              ,par.qtdias_atraso_permitido
              ,par.peminimo_cobertura
          FROM tbgar_parame_geral par
         WHERE par.cdcooper = pr_cdcooper;
      rw_tbgar_parame_geral cr_tbgar_parame_geral%ROWTYPE; 
     
      -- Buscar informacoes do operador
      CURSOR cr_crapope (pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_cdoperad IN crapope.cdoperad%TYPE ) IS
        SELECT ope.nmoperad
          FROM crapope ope
         WHERE ope.cdcooper = pr_cdcooper  
           AND ope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%rowtype;
      
      -- Variaveis de erro
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
    
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis auxiliares
      vr_qtdias_atraso_permitido NUMBER(3);
      vr_caminho                 VARCHAR2(200);
      vr_dscooper                VARCHAR2(200);
    
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PARGOC'
                                ,pr_action => null);
      
      /* Extrai os dados */
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      -- Verifica se houve erro                      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Buscar informacoes do operador
      OPEN cr_crapope (pr_cdcooper => vr_cdcooper,
                       pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      
      -- caso nao encontrar o operador
      IF cr_crapope%NOTFOUND THEN
        CLOSE cr_crapope;
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel encontrar o operador.';
        -- gerar critica e retornar ao programa chamador
        RAISE vr_exc_erro;
      ELSE 
        -- Fecha Cursor
        CLOSE cr_crapope;
      END IF;
      
      -- Verifica se é a cooperativa certa
      IF pr_cdcooper <> vr_cdcooper AND
         vr_cdcooper <> 3           THEN
        vr_dscritic := 'Não é possível alterar os parâmetros de outra cooperativa.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Valida campos
      IF pr_inresgate_automatico  = 0 THEN
        vr_qtdias_atraso_permitido := 0;
      ELSE
        vr_qtdias_atraso_permitido := pr_qtdias_atraso_permitido;
      END IF;
      
      IF pr_qtdias_atraso_permitido < 0 OR
         pr_qtdias_atraso_permitido > 30 THEN
        vr_dscritic := 'Quantidade de dias de atraso p/ resgate automático inválida! Favor informar a quantidade entre 0 e 30 dias.';
        RAISE vr_exc_erro;
      END IF;
      
      IF pr_peminimo_cobertura < 0.01 OR
         pr_peminimo_cobertura > 300  THEN
        vr_dscritic := 'Percentual Míninimo Cobertura para Garantia deve ser entre 0.01 e 300.00%.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Buscar os parametros
      OPEN cr_tbgar_parame_geral(pr_cdcooper  => pr_cdcooper);
      FETCH cr_tbgar_parame_geral INTO rw_tbgar_parame_geral;
      --Se nao encontrou
      IF cr_tbgar_parame_geral%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_tbgar_parame_geral;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Parãmetros não encontrados para esta cooperativa.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_tbgar_parame_geral;
      
      -- Atualiza os parametros
      BEGIN
        UPDATE tbgar_parame_geral par
           SET inresgate_automatico = pr_inresgate_automatico
              ,qtdias_atraso_permitido = pr_qtdias_atraso_permitido
              ,peminimo_cobertura = pr_peminimo_cobertura
         WHERE par.cdcooper = pr_cdcooper;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar os parâmetros. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      -- Pega o diretorio do log
      vr_caminho := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                ,pr_cdcooper => vr_cdcooper
                                                ,pr_nmsubdir => '/log');
      -- Se alterou "Resgate Automatico"
      IF pr_inresgate_automatico <> rw_tbgar_parame_geral.inresgate_automatico THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'pargoc.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' --> Operador: ' || vr_cdoperad || ' ' ||
                                                      rw_crapope.nmoperad || 
                                                      ' Alterou "Resgate Automatico" de "' || 
                                                      (CASE rw_tbgar_parame_geral.inresgate_automatico WHEN 1 THEN 'Sim' WHEN 0 THEN 'Nao' END) || 
                                                      '" para "' ||
                                                      (CASE pr_inresgate_automatico WHEN 1 THEN 'Sim' WHEN 0 THEN 'Nao' END) || 
                                                      '"'
                                  ,pr_flfinmsg     => 'N');
      END IF;
      
      -- Se alterou "Dias de Atraso p/ Resgate Automatico"
      IF pr_qtdias_atraso_permitido <> rw_tbgar_parame_geral.qtdias_atraso_permitido THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'pargoc.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' --> Operador: ' || vr_cdoperad || ' ' ||
                                                      rw_crapope.nmoperad || 
                                                      ' Alterou "Dias de Atraso p/ Resgate Automatico" de "' || 
                                                      rw_tbgar_parame_geral.qtdias_atraso_permitido || 
                                                      '" para "' ||
                                                      pr_qtdias_atraso_permitido || 
                                                      '"'
                                  ,pr_flfinmsg     => 'N');
      END IF;
      
      -- Se alterou "% Min. Cobertura p/ Garantia"
      IF pr_peminimo_cobertura <> rw_tbgar_parame_geral.peminimo_cobertura THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'pargoc.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' --> Operador: ' || vr_cdoperad || ' ' ||
                                                      rw_crapope.nmoperad || 
                                                      ' Alterou "% Min. Cobertura p/ Garantia" de "' || 
                                                      TRIM(to_char(rw_tbgar_parame_geral.peminimo_cobertura,'990d00')) || 
                                                      '"% para "' ||
                                                      TRIM(to_char(pr_peminimo_cobertura,'990d00')) || 
                                                      '%"'
                                  ,pr_flfinmsg     => 'N');
      END IF;
      
      -- Efetiva as alterações
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARGOC.pc_altera_params_pargoc): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_altera_params_pargoc;

END TELA_PARGOC;
/
