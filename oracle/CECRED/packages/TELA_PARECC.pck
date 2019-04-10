CREATE OR REPLACE PACKAGE CECRED.TELA_PARECC is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : TELA_PARECC
      Sistema  : Rotinas referentes a tela PARECC (Parâmetro de Envio de Cartão para o Endereço do Cooperado)
      Sigla    : PARECC
      Autor    : Luis Fernando - Supero
      Data     : Janeiro/2019.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas utilizadas pela tela PARECC para parametrização do envio do cartão.
  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Rotina para buscar os tipos de funcionalidade da tabela de dominio
  PROCEDURE pc_busca_dominio_parecc(pr_nmdominio IN tbcrd_dominio_campo.nmdominio%TYPE --> Nr. da Conta
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);
                                   
  -- Rotina para buscar todas as cooperativas disponiveis.                                 
  PROCEDURE pc_busca_coop_parecc(pr_xmllog      IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);

  -- Rotina para buscar os PAs da cooperativa selecionada
  PROCEDURE pc_busca_pa_coop(pr_cdcooperativa            IN crapage.cdcooper%TYPE
                            ,pr_idfuncionalidade         IN tbcrd_envio_cartao.idfuncionalidade%TYPE --> Codigo da funcionalidade
                            ,pr_idtipoenvio              IN tbcrd_tipo_envio_cartao.idtipoenvio%TYPE --> Habilitar cooperativa para envio ao endereço do cooperado
                            ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);
                                  
   -- Rotina para alterar os parametros das cooperativas
   PROCEDURE pc_altera_params_parecc(pr_cdcooperativa        IN tbcrd_envio_cartao.cdcooper%TYPE         --> Codigo da Cooperativa (zero para todas)
                                    ,pr_idfuncionalidade     IN tbcrd_envio_cartao.idfuncionalidade%TYPE --> Codigo da funcionalidade
                                    ,pr_flghabilitar         IN tbcrd_envio_cartao.flghabilitar%TYPE     --> Dias de atraso p/ resgate automático
                                    ,pr_idtipoenvio          IN tbcrd_tipo_envio_cartao.idtipoenvio%TYPE --> Habilitar cooperativa para envio ao endereço do cooperado
                                    ,pr_cdcooppodenviar      IN VARCHAR2           --> Lista das cooperativas que podem Enviar
                                    ,pr_xmllog               IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic            OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic            OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml               IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo            OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro            OUT VARCHAR2);         --> Erros do processo
  
  -- Rotina para buscar a flag Habilitar cooperativa para envio ao endereco do cooperado                                  
  PROCEDURE pc_busca_flghabilitar(pr_cdcooperativa    IN tbcrd_envio_cartao.cdcooper%TYPE         --> Codigo da Cooperativa (zero para todas)
                                 ,pr_idfuncionalidade IN tbcrd_envio_cartao.idfuncionalidade%TYPE --> Codigo da funcionalidade
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2); --> Erros do processo
END TELA_PARECC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARECC is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : TELA_PARECC
      Sistema  : Rotinas referentes a tela PARECC (Parâmetro de Envio de Cartão para o Endereço do Cooperado)
      Sigla    : PARECC
      Autor    : Luis Fernando - Supero
      Data     : Janeiro/2019.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas utilizadas pela tela PARECC para parametrização do envio do cartão.
  ---------------------------------------------------------------------------------------------------------------*/

    PROCEDURE pc_busca_dominio_parecc(pr_nmdominio IN tbcrd_dominio_campo.nmdominio%TYPE --> Nr. da Conta
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
        
            Programa: pc_busca_dominio
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Anderson-Alan (Supero)
            Data    : Janeiro/2019                 Ultima atualizacao: 
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo  : Retorna os valores do dominio
        
            Observacao: -----
        
            Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;

        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
        vr_cont_tag PLS_INTEGER := 0;


        CURSOR cr_dominio(pr_nmdominio IN tbcrd_dominio_campo.nmdominio%TYPE) IS
          SELECT tdc.cddominio
                ,tdc.dscodigo
            FROM tbcrd_dominio_campo tdc
           WHERE tdc.nmdominio = pr_nmdominio;
        rw_dominio cr_dominio%ROWTYPE;
    
    BEGIN
    
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
    
        FOR rw_dominio IN cr_dominio(pr_nmdominio) LOOP
          GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dominio'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
                            
                            
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dominio'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'cddominio'
                                ,pr_tag_cont => rw_dominio.cddominio
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dominio'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'dscodigo'
                                ,pr_tag_cont => rw_dominio.dscodigo
                                ,pr_des_erro => vr_dscritic);                                                        
        
          -- Incrementa o contador de tags
          vr_cont_tag := vr_cont_tag + 1;
        END LOOP;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_PARECC.pc_busca_dominio_parecc. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');        
    END pc_busca_dominio_parecc;
    
		PROCEDURE pc_busca_coop_parecc(pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    Programa: pc_busca_coop_parecc
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Afonso
    Data    : 04/10/2017                      Ultima atualizacao:   /  /

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as cooperativas ativas

    Alteracoes:            
    ............................................................................. */
      CURSOR cr_crapcop (pr_cdcooperativa IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
          FROM crapcop
         WHERE (pr_cdcooperativa = 3
           AND crapcop.cdcooper <> 3
           AND crapcop.flgativo = 1)
           OR (pr_cdcooperativa <> 3
           AND cdcooper = pr_cdcooperativa)
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
                                                   ||'  <cdcooperativa>'||rw_crapcop.cdcooper||'</cdcooperativa>'
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
        pr_dscritic := 'Erro geral (TELA_parecc.pc_busca_coop_parecc): ' || SQLERRM;
         -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_busca_coop_parecc;
  
  PROCEDURE pc_busca_pa_coop(pr_cdcooperativa    IN crapage.cdcooper%TYPE --> Codigo da cooperativa selecionada
                            ,pr_idfuncionalidade IN tbcrd_envio_cartao.idfuncionalidade%TYPE --> Codigo da funcionalidade
                            ,pr_idtipoenvio      IN tbcrd_tipo_envio_cartao.idtipoenvio%TYPE --> Habilitar cooperativa para envio ao endereço do cooperado
                            ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS
     
    /* .............................................................................
    Programa: pc_busca_pa_coop
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Luís Fernando - Supero
    Data    : 18/01/2019                      Ultima atualizacao:   /  /

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar os PA por cooperativas.

    Alteracoes:            
    ............................................................................. */
    
    -- Busca PAs com funcionalidade adicionada a cooperativa
    CURSOR cr_tbcrd_pa_envio_cartao IS
      SELECT 'PA ' || age.cdagenci || ' - ' || age.nmresage as nmresage, age.cdagenci
        FROM tbcrd_pa_envio_cartao tpec,
             crapage age
       WHERE tpec.cdcooper         = pr_cdcooperativa
         AND tpec.idfuncionalidade = pr_idfuncionalidade
         AND tpec.idtipoenvio      = pr_idtipoenvio
         AND age.cdagenci          = tpec.cdagencia
         AND age.cdcooper          = tpec.cdcooper;
    
    CURSOR cr_crapage (pr_cdcooperativa IN crapage.cdcooper%TYPE) IS
      SELECT 'PA ' || age.cdagenci || ' - ' || age.nmresage AS nmresage, age.cdagenci
       FROM crapage age
      WHERE age.cdagenci NOT IN (SELECT cdagencia
                                  FROM tbcrd_pa_envio_cartao tp
                                 WHERE tp.idfuncionalidade = pr_idfuncionalidade
                                   AND tp.idtipoenvio = pr_idtipoenvio
                                   AND tp.cdcooper = age.cdcooper)
        AND age.cdcooper = pr_cdcooperativa;
    
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
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><agencias></agencias><agenciasAtivas></agenciasAtivas></Root>');
      
      FOR rw_crapage IN cr_crapage(pr_cdcooperativa) LOOP
        -- Cooperativas
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/agencias'
                                            ,XMLTYPE('<agencia>'
                                                   ||'  <cdagenci>'||rw_crapage.cdagenci||'</cdagenci>'
                                                   ||'  <nmresage>'||UPPER(rw_crapage.nmresage)||'</nmresage>'
                                                   ||'</agencia>'));
      END LOOP;

      FOR rw_tbcrd_pa_envio_cartao IN cr_tbcrd_pa_envio_cartao LOOP
        -- Cooperativas
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/agenciasAtivas'
                                            ,XMLTYPE('<agencia>'
                                                   ||'  <cdagenci>'||rw_tbcrd_pa_envio_cartao.cdagenci||'</cdagenci>'
                                                   ||'  <nmresage>'||UPPER(rw_tbcrd_pa_envio_cartao.nmresage)||'</nmresage>'
                                                   ||'</agencia>'));
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
        pr_dscritic := 'Erro geral (TELA_parecc.pc_busca_coop_parecc): ' || SQLERRM;
         -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    
    END pc_busca_pa_coop;
    
    -- Rotina para alterar os parametros das cooperativas
    PROCEDURE pc_altera_params_parecc(pr_cdcooperativa            IN tbcrd_envio_cartao.cdcooper%TYPE         --> Codigo da Cooperativa (zero para todas)
                                     ,pr_idfuncionalidade         IN tbcrd_envio_cartao.idfuncionalidade%TYPE --> Codigo da funcionalidade
                                     ,pr_flghabilitar             IN tbcrd_envio_cartao.flghabilitar%TYPE     --> Habilitar cooperativa para envio ao endereço do cooperado
                                     ,pr_idtipoenvio              IN tbcrd_tipo_envio_cartao.idtipoenvio%TYPE --> Tipo de envio do cartao
                                     ,pr_cdcooppodenviar          IN VARCHAR2           --> Lista das cooperativas que podem Enviar
                                     ,pr_xmllog                   IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic                OUT PLS_INTEGER        --> Código da crítica
                                     ,pr_dscritic                OUT VARCHAR2           --> Descrição da crítica
                                     ,pr_retxml                   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo                OUT VARCHAR2           --> Nome do campo com erro
                                     ,pr_des_erro                OUT VARCHAR2) IS       --> Erros do processo

      /* .............................................................................
      Programa: pc_altera_horario_parecc
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Anderson-Alan (Supero)
      Data    : 29/01/2019                        Ultima atualizacao:   /  /

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para alterar os parametros da cooperativa selecionada

      Alteracoes:
      ............................................................................. */
        -- CURSORES --
        
        -- Busca PAs com funcionalidade adicionada a cooperativa
        CURSOR cr_tbcrd_pa_envio_cartao IS
          SELECT tpec.cdagencia, tpec.cdoperador
            FROM tbcrd_pa_envio_cartao tpec
           WHERE tpec.cdcooper         = pr_cdcooperativa
             AND tpec.idfuncionalidade = pr_idfuncionalidade
             AND tpec.idtipoenvio = pr_idtipoenvio;
        
        -- Buscar informacoes do operador
        CURSOR cr_crapope(pr_cdcooperativa IN crapcop.cdcooper%TYPE
                         ,pr_cdoperad IN crapope.cdoperad%TYPE ) IS
          SELECT ope.nmoperad
            FROM crapope ope
           WHERE ope.cdcooper = pr_cdcooperativa  
             AND ope.cdoperad = pr_cdoperad;
        rw_crapope cr_crapope%ROWTYPE;
        
        -- Cursor para verificar se operador tem acesso a opção de Alteracao da tela
		CURSOR cr_crapace(pr_cdcooper IN crapace.cdcooper%TYPE
                         ,pr_cdoperad IN crapace.cdoperad%TYPE) IS
		  SELECT 1
			FROM crapace ace
		   WHERE ace.cdcooper = pr_cdcooper
             AND UPPER(ace.cdoperad) = UPPER(pr_cdoperad)
             AND UPPER(ace.nmdatela) = 'PARECC'
		     AND ace.idambace = 2
			 AND UPPER(ace.cddopcao) LIKE '%A%';
		rw_crapace cr_crapace%ROWTYPE;
      
        -- Cursores de Log
        -- Buscar informacoes da Cooperativa
        CURSOR cr_crapcop(pr_cdcooperativa IN crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooperativa;
        rw_crapcop cr_crapcop%ROWTYPE;
      
        -- Busca tipo de envio
        CURSOR cr_dominio (pr_cddominio IN tbcrd_dominio_campo.cddominio%TYPE) IS
          SELECT tdc.dscodigo
            FROM tbcrd_dominio_campo tdc
           WHERE tdc.nmdominio = 'TPENDERECOENTREGA'
             AND tdc.cddominio = pr_cddominio;
        rw_dominio cr_dominio%ROWTYPE;
      
        -- Busca dados da Agencia
        CURSOR cr_crapage (pr_cdcooperativa IN crapage.cdcooper%TYPE
                          ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT age.nmresage
          FROM crapage age
         WHERE age.cdcooper = pr_cdcooperativa
           AND age.cdagenci = pr_cdagenci;
        rw_crapage cr_crapage%ROWTYPE;
      
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
        vr_listcdcooppodenviar gene0002.typ_split;
        vr_nrdrowid ROWID;
        
        -- Cursor sobre a tabela de datas
        rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
        
      BEGIN
        
        -- Incluir nome do módulo logado
        GENE0001.pc_informa_acesso(pr_module => 'PARECC'
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
        OPEN cr_crapope (pr_cdcooperativa => vr_cdcooper,
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
        
        
        -- Buscar informacoes da cooperativa
        OPEN cr_crapcop (pr_cdcooperativa => vr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        
        -- caso nao encontrar a cooperativa
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel encontrar a cooperativa.';
          -- gerar critica e retornar ao programa chamador
          RAISE vr_exc_erro;
        ELSE 
          -- Fecha Cursor
          CLOSE cr_crapcop;
        END IF;
        
        
        OPEN cr_crapace(pr_cdcooper => vr_cdcooper
                       ,pr_cdoperad => vr_cdoperad);
			  FETCH cr_crapace INTO rw_crapace;
			
			  IF cr_crapace%NOTFOUND AND vr_cdoperad <> '1' THEN
          CLOSE cr_crapace;
				  -- Atribui crítica
				  vr_cdcritic := 0;
				  vr_dscritic := 'Operador nao possui permissao de alteracao.';
				  -- Gera exceção
				  RAISE vr_exc_erro;
        ELSE
          -- Fecha Cursor
          CLOSE cr_crapace;
        END IF;
        
        
        -- Verifica se foi informado uma Cooperativa
        IF pr_cdcooperativa IS NULL THEN
          vr_dscritic := 'Uma Cooperativa deve ser selecionada.';
          RAISE vr_exc_erro;
        END IF;
        
        -- Verifica se foi informado uma Funcionalidade
        IF NOT nvl(pr_idfuncionalidade, 0) > 0 THEN
          vr_dscritic := 'Uma Funcionalidade deve ser selecionada.';
          RAISE vr_exc_erro;
        END IF;
        
        -- Verifica se foi informado um Tipo de Envio
        IF NOT nvl(pr_idtipoenvio, 0) > 0 THEN
          vr_dscritic := 'Um Tipo de Envio deve ser selecionado. ';
          RAISE vr_exc_erro;
        END IF;
        
        -- Busca a data do sistema
        OPEN btch0001.cr_crapdat(vr_cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
        
        BEGIN
          -- Inserir registro, Envio do Cartao
          INSERT INTO TBCRD_ENVIO_CARTAO
                     (TBCRD_ENVIO_CARTAO.CDCOOPER
                     ,TBCRD_ENVIO_CARTAO.IDFUNCIONALIDADE
                     ,TBCRD_ENVIO_CARTAO.FLGHABILITAR
                     ,TBCRD_ENVIO_CARTAO.DTATUALIZACAO
                     ,TBCRD_ENVIO_CARTAO.CDOPERADOR
                     )
               VALUES(pr_cdcooperativa
                     ,pr_idfuncionalidade
                     ,pr_flghabilitar
                     ,rw_crapdat.dtmvtolt
                     ,vr_cdoperad
                     );
        EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          -- Se ja existe deve alterar
          BEGIN
            UPDATE TBCRD_ENVIO_CARTAO
               SET TBCRD_ENVIO_CARTAO.FLGHABILITAR     = pr_flghabilitar
                  ,TBCRD_ENVIO_CARTAO.DTATUALIZACAO    = rw_crapdat.dtmvtolt
                  ,TBCRD_ENVIO_CARTAO.CDOPERADOR       = vr_cdoperad
             WHERE TBCRD_ENVIO_CARTAO.CDCOOPER         = pr_cdcooperativa
               AND TBCRD_ENVIO_CARTAO.IDFUNCIONALIDADE = pr_idfuncionalidade;

          EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao atualizar parametros: ' || SQLERRM;
          RAISE vr_exc_erro;
        END;
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao atualizar parametros: ' || SQLERRM;
          RAISE vr_exc_erro;
        END;
        
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooperativa
							,pr_cdoperad => vr_cdoperad
							,pr_dscritic => ' '
							,pr_dsorigem => GENE0001.vr_vet_des_origens(5) -- Aimaro WEB
							,pr_dstransa => 'PARECC: Criado registro de parametrizacao de entrega de cartao para o cooperado.'
							,pr_dttransa => TRUNC(SYSDATE)
							,pr_flgtrans => 1
							,pr_hrtransa => gene0002.fn_busca_time
							,pr_idseqttl => 1
							,pr_nmdatela => vr_nmdatela
							,pr_nrdconta => 0
							,pr_nrdrowid => vr_nrdrowid);
                            
				--
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Cooperativa'
																 ,pr_dsdadant => ''
																 ,pr_dsdadatu => rw_crapcop.nmrescop);
                                 
        --
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Funcionalidade'
																 ,pr_dsdadant => ''
																 ,pr_dsdadatu => 'Envio de cartão de crédito para o endereço do cooperado');
                                 
        --
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Habilitar cooperativa para envio ao endereço do cooperado'
																 ,pr_dsdadant => ''
																 ,pr_dsdadatu => nvl(pr_flghabilitar,0));
                                 
        --
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Operador'
																 ,pr_dsdadant => ''
																 ,pr_dsdadatu => nvl(vr_cdoperad,''));
        
        BEGIN
          -- Inserir registro, Tipo de Envio de Cartao
          INSERT INTO TBCRD_TIPO_ENVIO_CARTAO
                     (TBCRD_TIPO_ENVIO_CARTAO.CDCOOPER
                     ,TBCRD_TIPO_ENVIO_CARTAO.IDFUNCIONALIDADE
                     ,TBCRD_TIPO_ENVIO_CARTAO.IDTIPOENVIO
                     )
               VALUES(pr_cdcooperativa
                     ,pr_idfuncionalidade
                     ,pr_idtipoenvio
                     );
        EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao atualizar parametros: ' || SQLERRM;
          RAISE vr_exc_erro;
        END;
        
        vr_listcdcooppodenviar := gene0002.fn_quebra_string(pr_cdcooppodenviar, ',');
        
        -- Verifica se registros foram removidos
        FOR rw_tbcrd_pa_envio_cartao IN cr_tbcrd_pa_envio_cartao LOOP
          
          IF (gene0002.fn_existe_valor(pr_cdcooppodenviar, rw_tbcrd_pa_envio_cartao.cdagencia, ',') != 'S') THEN
            
            BEGIN
              DELETE FROM TBCRD_PA_ENVIO_CARTAO
                    WHERE TBCRD_PA_ENVIO_CARTAO.CDCOOPER = pr_cdcooperativa
                      AND TBCRD_PA_ENVIO_CARTAO.IDFUNCIONALIDADE = pr_idfuncionalidade
                      AND TBCRD_PA_ENVIO_CARTAO.CDAGENCIA = rw_tbcrd_pa_envio_cartao.cdagencia
                      AND TBCRD_PA_ENVIO_CARTAO.IDTIPOENVIO = pr_idtipoenvio;
                      
              GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooperativa
                                ,pr_cdoperad => vr_cdoperad
                                  ,pr_dscritic => ' '
                                  ,pr_dsorigem => GENE0001.vr_vet_des_origens(5) -- Aimaro WEB
                                  ,pr_dstransa => 'PARECC: Removido registro de relacionamento parametrizacao da lista de PAs para entrega de cartao ao cooperado.'
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 1
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nrdconta => 0
                                ,pr_nrdrowid => vr_nrdrowid);
                            
              --
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Cooperativa'
                                       ,pr_dsdadant => rw_crapcop.nmrescop
                                       ,pr_dsdadatu => '');
                                       
              --
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Funcionalidade'
                                       ,pr_dsdadant => 'Envio de cartão de crédito para o endereço do cooperado'
                                       ,pr_dsdadatu => '');
                                       
              
              -- Buscar informacoes da agencia
              OPEN cr_crapage(pr_cdcooperativa => pr_cdcooperativa
                             ,pr_cdagenci => rw_tbcrd_pa_envio_cartao.cdagencia);
              FETCH cr_crapage INTO rw_crapage;
              
              -- caso nao encontrar o tipo de envio
              IF cr_crapage%NOTFOUND THEN
                CLOSE cr_crapage;
                vr_cdcritic := 0;
                vr_dscritic := 'Nao foi possivel encontrar a agencia.';
                -- gerar critica e retornar ao programa chamador
                RAISE vr_exc_erro;
              ELSE
                -- Fecha Cursor
                CLOSE cr_crapage;
              END IF;
              --
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Agencia'
                                       ,pr_dsdadant => rw_crapage.nmresage
                                       ,pr_dsdadatu => '');
                                       
                                       
              -- Buscar informacoes do envio
              OPEN cr_dominio(pr_cddominio => pr_idtipoenvio);
              FETCH cr_dominio INTO rw_dominio;
              
              -- caso nao encontrar o tipo de envio
              IF cr_dominio%NOTFOUND THEN
                CLOSE cr_dominio;
                vr_cdcritic := 0;
                vr_dscritic := 'Nao foi possivel encontrar o tipo de envio.';
                -- gerar critica e retornar ao programa chamador
                RAISE vr_exc_erro;
              ELSE
                -- Fecha Cursor
                CLOSE cr_dominio;
              END IF;
              --
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Tipo de Envio'
                                       ,pr_dsdadant => rw_dominio.dscodigo
                                       ,pr_dsdadatu => '');
                                   
              --
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Operador'
                                       ,pr_dsdadant => rw_tbcrd_pa_envio_cartao.cdoperador
                                       ,pr_dsdadatu => '');
            EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao excluir registros: '||SQLERRM;
                  RAISE vr_exc_erro;
            END;
                                     
          END IF;
          
        END LOOP;
        
        -- Se há registros a processar
        IF vr_listcdcooppodenviar.COUNT() > 0 THEN
        
          -- Insere todos os novos registros e ignora os existentes
          FOR ind_registro IN vr_listcdcooppodenviar.first .. vr_listcdcooppodenviar.last LOOP
            BEGIN
              -- Inserir registro, Tipo de Envio de Cartao
              INSERT INTO TBCRD_PA_ENVIO_CARTAO
                         (TBCRD_PA_ENVIO_CARTAO.CDCOOPER
                         ,TBCRD_PA_ENVIO_CARTAO.IDFUNCIONALIDADE
                         ,TBCRD_PA_ENVIO_CARTAO.IDTIPOENVIO
                         ,TBCRD_PA_ENVIO_CARTAO.CDAGENCIA
                         ,TBCRD_PA_ENVIO_CARTAO.DTATUALIZACAO
                         ,TBCRD_PA_ENVIO_CARTAO.CDOPERADOR
                         )
                   VALUES(pr_cdcooperativa
                         ,pr_idfuncionalidade
                         ,pr_idtipoenvio
                         ,vr_listcdcooppodenviar(ind_registro)
                         ,rw_crapdat.dtmvtolt
                         ,vr_cdoperad
                         );
              
              GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooperativa
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => GENE0001.vr_vet_des_origens(5) -- Aimaro WEB
                                ,pr_dstransa => 'PARECC: Criado registro de relacionamento parametrizacao da lista de PAs para entrega de cartao ao cooperado.'
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 1
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nrdconta => 0
                                ,pr_nrdrowid => vr_nrdrowid);
                              
              --
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Cooperativa'
                                       ,pr_dsdadant => ''
                                       ,pr_dsdadatu => rw_crapcop.nmrescop);
                                       
              --
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Funcionalidade'
                                       ,pr_dsdadant => ''
                                       ,pr_dsdadatu => 'Envio de cartão de crédito para o endereço do cooperado');
                                       
              -- Buscar informacoes da agencia
              OPEN cr_crapage(pr_cdcooperativa => pr_cdcooperativa
                             ,pr_cdagenci => vr_listcdcooppodenviar(ind_registro));
              FETCH cr_crapage INTO rw_crapage;
              
              -- caso nao encontrar o tipo de envio
              IF cr_crapage%NOTFOUND THEN
                CLOSE cr_crapage;
                vr_cdcritic := 0;
                vr_dscritic := 'Nao foi possivel encontrar a agencia.';
                -- gerar critica e retornar ao programa chamador
                RAISE vr_exc_erro;
              ELSE
                -- Fecha Cursor
                CLOSE cr_crapage;
              END IF;
              --
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Agencia'
                                       ,pr_dsdadant => ''
                                       ,pr_dsdadatu => rw_crapage.nmresage);
                                       
              
              -- Buscar informacoes do envio
              OPEN cr_dominio(pr_cddominio => pr_idtipoenvio);
              FETCH cr_dominio INTO rw_dominio;
              
              -- caso nao encontrar o tipo de envio
              IF cr_dominio%NOTFOUND THEN
                CLOSE cr_dominio;
                vr_cdcritic := 0;
                vr_dscritic := 'Nao foi possivel encontrar o tipo de envio.';
                -- gerar critica e retornar ao programa chamador
                RAISE vr_exc_erro;
              ELSE
                -- Fecha Cursor
                CLOSE cr_dominio;
              END IF;
              --
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Tipo de Envio'
                                       ,pr_dsdadant => ''
                                       ,pr_dsdadatu => rw_dominio.dscodigo);
                                   
              --
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Operador'
                                       ,pr_dsdadant => ''
                                       ,pr_dsdadatu => nvl(vr_cdoperad,''));
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                --> Se o registro já existe e não será alterado para mentar o codigo do operador que o criou.
                CONTINUE;
              WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao excluir registros: '||SQLERRM;
                  RAISE vr_exc_erro;
            END;
            
          END LOOP;
        
        END IF; -- IF vr_listcdcooppodenviar.COUNT() > 0
        
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
          pr_dscritic := 'Erro geral (TELA_PARECC.pc_altera_params_parecc): ' || SQLERRM;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END pc_altera_params_parecc;
    
    PROCEDURE pc_busca_flghabilitar(pr_cdcooperativa    IN tbcrd_envio_cartao.cdcooper%TYPE         --> Codigo da Cooperativa (zero para todas)
                                   ,pr_idfuncionalidade IN tbcrd_envio_cartao.idfuncionalidade%TYPE --> Codigo da funcionalidade
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
        
            Programa: pc_busca_flghabilitar
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Anderson-Alan - Supero
            Data    : 06/02/2019                 Ultima atualizacao: 
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo  : Retorna os flag 'Habilitar cooperativa para envio ao endereço do cooperado'
        
            Observacao: -----
        
            Alteracoes:
        ..............................................................................*/
        
        -- CURSORES --
        -- Busca flghabilitar com funcionalidade adicionada a cooperativa
        CURSOR cr_tbcrd_envio_cartao IS
          SELECT tpec.flghabilitar
            FROM tbcrd_envio_cartao tpec
           WHERE tpec.cdcooper         = pr_cdcooperativa
             AND tpec.idfuncionalidade = pr_idfuncionalidade;
        rw_tbcrd_envio_cartao cr_tbcrd_envio_cartao%ROWTYPE;
        
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
        
        -- Variaveis auxiliares
        vr_flghabilitar tbcrd_envio_cartao.idfuncionalidade%TYPE;
    
    BEGIN
    
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
        
        -- Buscar informacoes do operador
        OPEN cr_tbcrd_envio_cartao;
        FETCH cr_tbcrd_envio_cartao INTO rw_tbcrd_envio_cartao;
        
        -- caso nao encontrar
        IF cr_tbcrd_envio_cartao%NOTFOUND THEN
          CLOSE cr_tbcrd_envio_cartao;
          vr_flghabilitar := 1;
        ELSE 
          -- Fecha Cursor
          CLOSE cr_tbcrd_envio_cartao;
          vr_flghabilitar := rw_tbcrd_envio_cartao.flghabilitar;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        
        GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flghabilitar'
                              ,pr_tag_cont => vr_flghabilitar
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
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_PARECC.pc_busca_flghabilitar. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');        
    END pc_busca_flghabilitar;
  
END TELA_PARECC;
/
