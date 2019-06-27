CREATE OR REPLACE PACKAGE cecred.tela_score IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0005
  --  Sistema  : Aimaro
  --  Sigla    : CRED
  --  Autor    : Marcos (Envolti)
  --  Data     : Outubro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para interface Web da tela Score
  --
  --
  ---------------------------------------------------------------------------------------------------------------

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
  PROCEDURE pc_lista_histor_scores_carga(pr_cdmodelo   IN NUMBER           --> Codigo modelo
                                        ,pr_dtbase     IN VARCHAR2         --> Data base
                                         /* Parametros base da Mensageria */
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);        --> Erros do processo            
                                       
  /* Executar carga selecionada */
  PROCEDURE pc_exclui_carga_scores(pr_cdmodelo   IN NUMBER           --> Codigo modelo
                                  ,pr_dtbase     IN VARCHAR2         --> Data base                                 
                                  /* Parametros base da Mensageria */
                                  ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);        --> Erros do processo                                       

END TELA_SCORE;
/
CREATE OR REPLACE PACKAGE BODY cecred.tela_score AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0005
  --  Sistema  : Aimaro
  --  Sigla    : CRED
  --  Autor    : Marcos (Envolti)
  --  Data     : Outubro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para interface Web da tela Score
  --
  --
  ---------------------------------------------------------------------------------------------------------------

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
    
      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);    
    
      -- Variáveis para criação de cursor dinâmico
      vr_nom_owner     VARCHAR2(100) := gene0005.fn_get_owner_sas;
      vr_nom_dblink    VARCHAR2(100);
      vr_num_cursor    number;
      vr_num_retor     number;
      vr_sql_cursor    varchar2(32000);
      
      -- Criar tabela de memória para facilitar gravação posterior
      TYPE typ_tab_carga_score IS TABLE OF tbcrd_carga_score%ROWTYPE INDEX BY PLS_INTEGER;
      vr_tab_carga_score typ_tab_carga_score;
      
      -- Variaveis para a consulta
      vr_cdmodelo       NUMBER;
      vr_dsmodelo       VARCHAR2(255);
      vr_dtbase         DATE;
      vr_inpessoa       NUMBER;
      vr_qtregistros    NUMBER := 0;
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
    BEGIN
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;       
      
      -- Buscar dblink
      vr_nom_dblink := gene0005.fn_get_dblink_sas('R');
      IF vr_nom_dblink IS NULL THEN
        vr_dscritic := 'Nao foi possivel retornar o DBLink do SAS, verifique!';
        RAISE vr_exc_saida;
      END IF;

      -- Montaremos a query base com os registros para carga ou reprovação
      vr_sql_cursor := 'SELECT smo.cdmodelo '
                    || '      ,smo.dsmodelo '
                    || '      ,sco.dtbase '
                    || '      ,sco.tppessoa '
                    || '      ,COUNT(1) qtpessoa '
                    || '  FROM '||vr_nom_owner||'sas_score_modelo@'||vr_nom_dblink||' smo '
                    || '      ,'||vr_nom_owner||'sas_score@'||vr_nom_dblink||'        sco '
                    || '      ,'||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink||' car '
                    || ' WHERE smo.cdmodelo = sco.cdmodelo '
                    || '   AND car.skcarga = sco.skcarga '
                    || '   AND car.skprocesso = '||risc0005.fn_get_skprocesso_behavi
                    || '   AND car.qtregistroprocessado > 0 '
                    || '   AND car.dthorafiminclusao is not null '
                    || '   AND car.dthorainicioprocesso is null '
                    || '   AND NOT EXISTS(SELECT 1 '
                    || '                    FROM tbcrd_carga_score cso '
                    || '                   WHERE cso.cdmodelo = smo.cdmodelo '
                    || '                     AND cso.dtbase = sco.dtbase) '
                    || ' GROUP BY smo.cdmodelo '
                    || '         ,smo.dsmodelo '
                    || '         ,sco.dtbase '
                    || '         ,sco.tppessoa '
                    || ' ORDER BY sco.dtbase desc '
                    || '         ,smo.cdmodelo ';
      
      -- Cria cursor dinâmico
      vr_num_cursor := dbms_sql.open_cursor;

      -- Comando Parse
      dbms_sql.parse(vr_num_cursor, vr_sql_cursor, 1);
      -- Definindo Colunas de retorno
      dbms_sql.define_column(vr_num_cursor, 1, vr_cdmodelo);
      dbms_sql.define_column(vr_num_cursor, 2, vr_dsmodelo, 255);
      dbms_sql.define_column(vr_num_cursor, 3, vr_dtbase/*, 10*/);
      dbms_sql.define_column(vr_num_cursor, 4, vr_inpessoa);
      dbms_sql.define_column(vr_num_cursor, 5, vr_qtregistros);
      
      -- Execução do select dinamico
      vr_num_retor := dbms_sql.execute(vr_num_cursor);
      LOOP 
        -- Verifica se há alguma linha de retorno do cursor
        vr_num_retor := dbms_sql.fetch_rows(vr_num_cursor);
        IF vr_num_retor = 0 THEN
          -- Se o cursor dinamico está aberto
          IF dbms_sql.is_open(vr_num_cursor) THEN
            -- Fecha o mesmo
            dbms_sql.close_cursor(vr_num_cursor);
          END IF;
          EXIT; 
        ELSE 
          -- Carrega variáveis com o retorno do cursor
          dbms_sql.column_value(vr_num_cursor, 1, vr_cdmodelo);
          dbms_sql.column_value(vr_num_cursor, 2, vr_dsmodelo);
          dbms_sql.column_value(vr_num_cursor, 3, vr_dtbase);
          dbms_sql.column_value(vr_num_cursor, 4, vr_inpessoa);
          dbms_sql.column_value(vr_num_cursor, 5, vr_qtregistros);
          -- Inicializar registro caso for o primeiro, ou houver mudança de Modelo e Data BAse
          IF vr_tab_carga_score.count() = 0 
          OR vr_tab_carga_score(vr_tab_carga_score.count()).cdmodelo <> vr_cdmodelo 
          OR vr_tab_carga_score(vr_tab_carga_score.count()).dtbase <> vr_dtbase THEN
            -- Alimentar tabela de memória criando um novo registro
            vr_tab_carga_score(vr_tab_carga_score.count()+1).cdmodelo := vr_cdmodelo;
            vr_tab_carga_score(vr_tab_carga_score.count()).dsmodelo := vr_dsmodelo;
            vr_tab_carga_score(vr_tab_carga_score.count()).dtbase   := vr_dtbase;
          END IF;  
          -- Alimentar quantidade conforme tipo de pessoa
          IF vr_inpessoa = 1 THEN
            vr_tab_carga_score(vr_tab_carga_score.count()).qtregis_fisica := nvl(vr_tab_carga_score(vr_tab_carga_score.count()).qtregis_fisica,0) + vr_qtregistros;
          ELSE 
            vr_tab_carga_score(vr_tab_carga_score.count()).qtregis_juridi := nvl(vr_tab_carga_score(vr_tab_carga_score.count()).qtregis_juridi,0) + vr_qtregistros;
          END IF;
        END IF;    
      END LOOP;      
      
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      -- Varrer a pltable
      FOR idx IN 1..vr_tab_carga_score.count() LOOP
        
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
                              ,pr_tag_cont => vr_tab_carga_score(idx).cdmodelo
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ScoreCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsmodelo'
                              ,pr_tag_cont => vr_tab_carga_score(idx).dsmodelo
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ScoreCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dtbase'
                              ,pr_tag_cont => to_char(vr_tab_carga_score(idx).dtbase,'dd/mm/rrrr')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ScoreCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregistro'
                              ,pr_tag_cont => replace(to_char(nvl(vr_tab_carga_score(idx).qtregis_fisica,0) + nvl(vr_tab_carga_score(idx).qtregis_juridi,0),'fm999g999g990'),',','.')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ScoreCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregis_fisica'
                              ,pr_tag_cont => replace(to_char(nvl(vr_tab_carga_score(idx).qtregis_fisica,0),'fm999g999g990'),',','.')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ScoreCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregis_juridi'
                              ,pr_tag_cont => replace(to_char(nvl(vr_tab_carga_score(idx).qtregis_juridi,0),'fm999g999g990'),',','.')
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
        IF dbms_sql.is_open(vr_num_cursor) THEN
          -- Close cursor
          dbms_sql.close_cursor(vr_num_cursor);     
        END IF;           
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
        IF dbms_sql.is_open(vr_num_cursor) THEN
          -- Close cursor
          dbms_sql.close_cursor(vr_num_cursor);     
        END IF;        
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
    
      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Conversão de datas
      vr_dat_base DATE;
    
    BEGIN
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;       
    
      -- Validar chamada
      BEGIN
        vr_dat_base := to_date(pr_dtbase,'dd/mm/rrrr');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Problema no recebimento da data base - Data invalida!';
          RAISE vr_exc_saida;
      END;
      
      -- Direcionar para a execução da carga
      risc0005.pc_efetua_carga_score_behavi(pr_cdmodelo   => pr_cdmodelo
                                           ,pr_dtbase     => vr_dat_base
                                           ,pr_cddopcao   => pr_cddopcao
                                           ,pr_cdoperad   => vr_cdoperad
                                           ,pr_dsrejeicao => pr_dsrejeicao
                                           ,pr_dscritic   => vr_dscritic);
      -- Testar possível critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
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
  PROCEDURE pc_lista_histor_scores_carga(pr_cdmodelo   IN NUMBER           --> Codigo modelo
                                        ,pr_dtbase     IN VARCHAR2         --> Data base
                                        /* Parametros base da Mensageria */
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
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
    
      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    
      -- Busca do histórico de cargas
      CURSOR cr_carga_score IS
          SELECT csc.cdmodelo
                ,csc.dsmodelo
                ,csc.dtbase
                ,csc.dtinicio
                ,csc.dttermino
                ,decode(csc.cdopcao,'A','Aprovada','Rejeitada') dsopcao
                ,csc.cdoperad
                ,csc.qtregis_fisica
                ,csc.qtregis_juridi
                ,csc.dsrejeicao
            FROM tbcrd_carga_score csc
           WHERE csc.cdmodelo = decode(pr_cdmodelo,NULL,csc.cdmodelo,pr_cdmodelo)
             AND to_char(csc.dtbase,'mm/rrrr')   = decode(pr_dtbase,NULL,to_char(csc.dtbase,'mm/rrrr'),pr_dtbase)
           ORDER BY csc.dttermino DESC;
      
      -- Busca do nome do operador
      CURSOR cr_crapope(pr_cdoperad crapope.cdoperad%TYPE) IS
        SELECT ope.nmoperad
          FROM crapope ope
         WHERE ope.cdcooper = 3 --> A carga sempre será feita na Central
           AND ope.cdoperad = pr_cdoperad;
      vr_nmoperad crapope.nmoperad%TYPE;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
    BEGIN
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;       
      
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      -- Buscar todo o histórico
      FOR rw_csc IN cr_carga_score LOOP
        
        -- Busca operador
        vr_nmoperad := NULL;
        OPEN cr_crapope(rw_csc.cdoperad);
        FETCH cr_crapope
         INTO vr_nmoperad;
        CLOSE cr_crapope;
      
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
                              ,pr_tag_cont => rw_csc.cdmodelo
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsmodelo'
                              ,pr_tag_cont => rw_csc.dsmodelo
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dtbase'
                              ,pr_tag_cont => to_char(rw_csc.dtbase,'dd/mm/rrrr')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dtinicio'
                              ,pr_tag_cont => to_char(rw_csc.dtinicio,'dd/mm/rrrr hh24:mi:ss')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dttermino'
                              ,pr_tag_cont => to_char(rw_csc.dttermino,'dd/mm/rrrr hh24:mi:ss')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdoperad'
                              ,pr_tag_cont => rw_csc.cdoperad || '-' || vr_nmoperad
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregistro'
                              ,pr_tag_cont => replace(to_char(rw_csc.qtregis_fisica + rw_csc.qtregis_juridi,'fm999g999g990'),',','.')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregis_fisica'
                              ,pr_tag_cont => replace(to_char(rw_csc.qtregis_fisica,'fm999g999g990'),',','.')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtregis_juridi'
                              ,pr_tag_cont => replace(to_char(rw_csc.qtregis_juridi,'fm999g999g990'),',','.')
                              ,pr_des_erro => vr_dscritic);               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dssituac'
                              ,pr_tag_cont => rw_csc.dsopcao
                              ,pr_des_erro => vr_dscritic);               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'HistCarga'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsrejeicao'
                              ,pr_tag_cont => rw_csc.dsrejeicao
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
  
  /* Executar carga selecionada */
  PROCEDURE pc_exclui_carga_scores(pr_cdmodelo   IN NUMBER           --> Codigo modelo
                                  ,pr_dtbase     IN VARCHAR2         --> Data base                                 
                                  /* Parametros base da Mensageria */
                                  ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_exclui_carga_scores
    Sistema : Ayllos Web
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro - 2018.                Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para executar a exclusão da carga do score selecionado
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Conversão de datas
      vr_dat_base DATE;
    
    BEGIN
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;       
    
      -- Validar chamada
      BEGIN
        vr_dat_base := to_date(pr_dtbase,'dd/mm/rrrr');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Problema no recebimento da data base - Data invalida!';
          RAISE vr_exc_saida;
      END;
      
      -- Direcionar para a execução da carga
      risc0005.pc_efetua_exclu_score_behavi(pr_cdmodelo   => pr_cdmodelo
                                           ,pr_dtbase     => vr_dat_base
                                           ,pr_cdoperad   => vr_cdoperad
                                           ,pr_dscritic   => vr_dscritic);
      -- Testar possível critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
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
  END pc_exclui_carga_scores;    
  

END tela_score;
/
