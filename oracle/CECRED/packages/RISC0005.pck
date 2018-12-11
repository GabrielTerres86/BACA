CREATE OR REPLACE PACKAGE RISC0005 IS

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

  -- Busca do SKProcesso do Score Behaviour
  FUNCTION fn_get_skprocesso_behavi return VARCHAR2;
  
  -- Busca do Owner SAS conforme o ambiente conectado
  FUNCTION fn_get_owner_sas return VARCHAR2;

  -- Busca do DBLink conforme o ambiente conectado
  FUNCTION fn_get_dblink_sas(pr_tpacesso IN VARCHAR2 DEFAULT 'R') return VARCHAR2;
                             
  -- Procedimento para execução da carga do Behaviour enviada
  PROCEDURE pc_efetua_carga_score_behavi(pr_cdmodelo IN tbcrd_carga_score.cdmodelo%TYPE      -- Codigo do Modelo
                                        ,pr_dtbase   IN tbcrd_carga_score.dtbase%TYPE        -- Data base 
                                        ,pr_cddopcao IN tbcrd_carga_score.cdopcao%TYPE       -- Opção ([A]provar ou [R]eprovar
                                        ,pr_cdoperad IN tbcrd_carga_score.cdoperad%TYPE      -- Operador
                                        ,pr_dsrejeicao IN tbcrd_carga_score.dsrejeicao%TYPE  -- Descricão da Rejeição
                                        ,pr_dscritic OUT VARCHAR2);                          -- Critica de saida        
                                        
  -- Procedimento para execução da carga do Behaviour enviada
  PROCEDURE pc_efetua_exclu_score_behavi(pr_cdmodelo IN tbcrd_carga_score.cdmodelo%TYPE      -- Codigo do Modelo
                                        ,pr_dtbase   IN tbcrd_carga_score.dtbase%TYPE        -- Data base 
                                        ,pr_cdoperad IN tbcrd_carga_score.cdoperad%TYPE      -- Operador
                                        ,pr_dscritic OUT VARCHAR2);                          -- Critica de saida                                                             

END RISC0005;
/
CREATE OR REPLACE PACKAGE BODY RISC0005 AS
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

  -- Nome do Operador
  cursor cr_crapope(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_cdoperad crapope.cdoperad%TYPE) is
    SELECT ope.nmoperad
          ,age.nmcidade
          ,age.cdufdcop
      FROM crapope ope
          ,crapage age
     WHERE ope.cdcooper = age.cdcooper
       AND ope.cdagenci = age.cdagenci
       AND ope.cdcooper = pr_cdcooper
       and ope.cdoperad = pr_cdoperad;
  rw_crapope cr_crapope%ROWTYPE;      

  -- Retorna o Score Behaviour do Cooperado enviado
  FUNCTION fn_score_behaviour(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) RETURN VARCHAR2 IS
    -- ..........................................................................
    -- 
    --   Programa: fn_score_behaviour
    --   Sigla   : CRED
    --   Autor   : Marcos Martini - Envolti
    --   Data    : Novembro/2018                         Ultima atualizacao: 
    --
    --   Dados referentes ao programa:
    --
    --   Frequencia: Sempre que solicitado
    --   Objetivo  : Retornar o Score vigente do Cooperado
    --
    --   Alteracoes: 
    --
  
    -- Busca do CPF ou CNPJ base do Cooperado
    CURSOR cr_crapass IS
      SELECT ass.inpessoa
            ,ass.nrcpfcnpj_base
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    vr_inpessoa crapass.inpessoa%TYPE;
    vr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE;
    
    -- Busca do ultimo score do Cooperado
    CURSOR cr_tbcrd_score(pr_cdcooper      crapass.cdcooper%TYPE
                         ,pr_inpessoa      crapass.inpessoa%TYPE
                         ,pr_nrcpfcnpjbase tbcrd_score.nrcpfcnpjbase%TYPE) IS
      SELECT sco.nrscore_alinhado
            ,sco.dsclasse_score
        FROM tbcrd_score sco
       WHERE sco.cdcooper      = pr_cdcooper
         AND sco.tppessoa      = pr_inpessoa
         AND sco.nrcpfcnpjbase = pr_nrcpfcnpjbase
         AND sco.flvigente     = 1
         AND sco.cdmodelo      = gene0001.fn_param_sistema('CRED',pr_cdcooper,'COD_SCORE_BEHAVIOUR');
    vr_nrscore_alinhado tbcrd_score.nrscore_alinhado%TYPE;
    vr_dsclass_score    tbcrd_score.dsclasse_score%TYPE;
    
  BEGIN
    -- Buscar cpf ou cnpj base
    OPEN cr_crapass;
    FETCH cr_crapass 
     INTO vr_inpessoa,vr_nrcpfcnpj_base;
    CLOSE cr_crapass;
    -- Busca o ultimo score
    OPEN cr_tbcrd_score(pr_cdcooper,vr_inpessoa,vr_nrcpfcnpj_base);
    FETCH cr_tbcrd_score
     INTO vr_nrscore_alinhado,vr_dsclass_score;
    CLOSE cr_tbcrd_score;
    IF vr_nrscore_alinhado IS NOT NULL AND vr_dsclass_score IS NOT NULL THEN
      -- Retornar o score 
      RETURN vr_nrscore_alinhado||':'||vr_dsclass_score;
    ELSE
      RETURN ' ';
    END IF;  
  END fn_score_behaviour; 
  
  -- Busca do SKProcesso do Score Behaviour
  FUNCTION fn_get_skprocesso_behavi return VARCHAR2 IS
  BEGIN
    RETURN gene0001.fn_param_sistema('CRED',0,'SKPROC_SCORE_BEHAVIOUR'); 
  END;    
  
  -- Busca do Owner conforme o ambiente conectado
  FUNCTION fn_get_owner_sas return VARCHAR2 IS
  BEGIN
    -- Somente buscar dblink de prod se estivermos em Prod
    IF gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',0,'DB_NAME_PRODUC') THEN --> Produção
      RETURN gene0001.fn_param_sistema('CRED',0,'OWNER_SAS_PROD'); 
    ELSE
      RETURN gene0001.fn_param_sistema('CRED',0,'OWNER_SAS_DESEN'); 
    END IF;
  END;  
  
  -- Busca do DBLink conforme o ambiente conectado
  FUNCTION fn_get_dblink_sas(pr_tpacesso IN VARCHAR2 DEFAULT 'R') return VARCHAR2 IS
    vr_cdacesso crapprm.cdacesso%TYPE;
  BEGIN
    -- Incluir sufixo do tipo de leitura
    IF pr_tpacesso = 'R' THEN
      -- Read-Only
      vr_cdacesso := '_RO';
    ELSE
      -- Read Write
      vr_cdacesso := '_RW';
    END IF;
    -- Somente buscar dblink de prod se estivermos em Prod
    IF gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',0,'DB_NAME_PRODUC') THEN --> Produção
      vr_cdacesso := gene0001.fn_param_sistema('CRED',0,'DBLINK_SAS_PROD'||vr_cdacesso); 
    ELSE
      vr_cdacesso := gene0001.fn_param_sistema('CRED',0,'DBLINK_SAS_DESEN'||vr_cdacesso); 
    END IF;
    -- Retornar valor montado
    RETURN vr_cdacesso;
  END;
  
  -- Procedimento para execução da carga do Behaviour enviada
  PROCEDURE pc_efetua_carga_score_behavi(pr_cdmodelo IN tbcrd_carga_score.cdmodelo%TYPE      -- Codigo do Modelo
                                        ,pr_dtbase   IN tbcrd_carga_score.dtbase%TYPE        -- Data base 
                                        ,pr_cddopcao IN tbcrd_carga_score.cdopcao%TYPE       -- Opção ([A]provar ou [R]eprovar
                                        ,pr_cdoperad IN tbcrd_carga_score.cdoperad%TYPE      -- Operador
                                        ,pr_dsrejeicao IN tbcrd_carga_score.dsrejeicao%TYPE  -- Descricão da Rejeição
                                        ,pr_dscritic OUT VARCHAR2)                           -- Critica de saida
                                         IS                      
    -- ..........................................................................
    -- 
    --   Programa: pc_efetua_carga_score_behavi
    --   Sigla   : CRED
    --   Autor   : Marcos Martini - Envolti
    --   Data    : Novembro/2018                         Ultima atualizacao: 
    --
    --   Dados referentes ao programa:
    --
    --   Frequencia: Sempre que solicitado
    --   Objetivo  : Efetuar a carga ou rejeição do score repassado
    --
    --   Alteracoes: 
    --
  
    -- Tratamento de criticas
    vr_dscritic VARCHAR2(4000);
    vr_excsaida EXCEPTION;
    -- Variáveis para criação de cursor dinâmico
    vr_nom_owner     VARCHAR2(100) := fn_get_owner_sas;
    vr_nom_dblink    VARCHAR2(100);
    vr_skprocesso    VARCHAR2(100) := fn_get_skprocesso_behavi;
    
    -- Queries externas
    vr_num_cursor    number;
    vr_num_retor     number;
    vr_sql_cursor    varchar2(32000);
    
    -- Queries dinamicas internas
    vr_num_cursor_int    number;
    vr_num_retor_int     number;
    vr_sql_cursor_int    varchar2(32000);
    -- Colunas do retorno da carga
    vr_skcarga        PLS_INTEGER := 0;
    vr_dsmodelo       tbcrd_carga_score.dsmodelo%TYPE;
    vr_inpessoa       crapass.inpessoa%TYPE;
    vr_rowidcarga     ROWID;
    
    vr_qtregis_tot    PLS_INTEGER := 0;
    vr_qtregistros    PLS_INTEGER := 0;
    vr_qtregis_fisica tbcrd_carga_score.qtregis_fisica%TYPE := 0;
    vr_qtregis_juridi tbcrd_carga_score.qtregis_juridi%TYPE := 0;
    vr_dtinicio  tbcrd_carga_score.dtinicio%TYPE; 
    vr_dtfinali  tbcrd_carga_score.dtinicio%TYPE; 
    
    -- Buscar a ultima carga
    CURSOR cr_Ult_carga IS
      SELECT car.dtbase
        FROM tbcrd_carga_score car
       WHERE car.cdmodelo = pr_cdmodelo
         AND car.cdopcao = 'A'
       ORDER BY car.dtbase DESC;
    vr_dtbase tbcrd_carga_score.dtbase%TYPE;
    -- Variavel para log 
    vr_deslog VARCHAR2(4000);
  BEGIN
    -- Validar Modelo
    IF pr_cdmodelo IS NULL THEN
      vr_dscritic := 'Modelo de Carga deve ser informado!';
      RAISE vr_excsaida;
    END IF;
    -- Validar DtBase
    IF pr_dtbase IS NULL THEN
      vr_dscritic := 'Data Base de Carga deve ser informado!';
      RAISE vr_excsaida;
    END IF;    
    -- Validar Opção
    IF pr_cddopcao IS NULL OR pr_cddopcao NOT IN('A','R') THEN
      vr_dscritic := 'Opcao invalida! Favor enviar [A]provar ou [R]eprovar!';
      RAISE vr_excsaida;
    END IF;        
    -- Validar Operador
    IF pr_cdoperad IS NULL THEN
      vr_dscritic := 'Operador conectado deve ser informado!';
      RAISE vr_excsaida;
    END IF;        
    -- Validar Motivo Rejeicao
    IF pr_cddopcao = 'R' AND pr_dsrejeicao IS NULL THEN
      vr_dscritic := 'Motivo da Rejeicao e obrigatorio para esta opcao!';
      RAISE vr_excsaida;
    END IF;        
    
    -- Buscar dblink
    vr_nom_dblink := fn_get_dblink_sas('R');
    IF vr_nom_dblink IS NULL THEN
      vr_dscritic := 'Nao foi possivel retornar o DBLink do SAS, verifique!';
      RAISE vr_excsaida;
    END IF;
    
    -- Buscar FatorControleCarga
    vr_sql_cursor := 'SELECT car.skcarga '
                  || '  FROM '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink||' car '
                  || ' WHERE car.skdtbase   = '||to_char(pr_dtbase, 'yyyymmdd')
                  || '   AND car.skprocesso = '||vr_skprocesso
                  || '   AND car.qtregistroprocessado > 0 '
                  || '   AND car.dthorafiminclusao is not null '
                  || '   AND car.dthorainicioprocesso is null ';
      
    -- Cria cursor dinâmico
    vr_num_cursor := dbms_sql.open_cursor;

    -- Comando Parse
    dbms_sql.parse(vr_num_cursor, vr_sql_cursor, 1);
    -- Definindo Colunas de retorno
    dbms_sql.define_column(vr_num_cursor, 1, vr_skcarga);
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
        -- Reiniciar contadores
        vr_qtregis_fisica := 0;
        vr_qtregis_juridi := 0;
        -- Carrega variáveis com o retorno do cursor
        dbms_sql.column_value(vr_num_cursor, 1, vr_skcarga);
        -- Para cada skcarga do FatorControleCarga
        -- Montaremos a query base com os registros para carga ou reprovação
        vr_sql_cursor_int := 'SELECT scm.dsmodelo '
                      || '      ,sco.tppessoa '
                      || '      ,COUNT(1) qtpessoa '
                      || '  FROM '||vr_nom_owner||'sas_score_modelo@'||vr_nom_dblink||' scm '
                      || '      ,'||vr_nom_owner||'sas_score@'||vr_nom_dblink||' sco '
                      || ' WHERE scm.cdmodelo = sco.cdmodelo '
                      || '   AND sco.cdmodelo = '||pr_cdmodelo
                      || '   AND sco.dtbase   = to_date('''||to_char(pr_dtbase, 'ddmmyyyy')||''', ''ddmmyyyy'')'
                      || '   AND sco.skcarga  = '||vr_skcarga
                      || '  GROUP BY scm.dsmodelo '
                      || '          ,sco.tppessoa ';
        
        -- Cria cursor dinâmico
        vr_num_cursor_int := dbms_sql.open_cursor;

        -- Comando Parse
        dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
        -- Definindo Colunas de retorno
        dbms_sql.define_column(vr_num_cursor_int, 1, vr_dsmodelo, 255);
        dbms_sql.define_column(vr_num_cursor_int, 2, vr_inpessoa);
        dbms_sql.define_column(vr_num_cursor_int, 3, vr_qtregistros);
        
        -- Execução do select dinamico
        vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
        LOOP 
          -- Verifica se há alguma linha de retorno do cursor
          vr_num_retor_int := dbms_sql.fetch_rows(vr_num_cursor_int);
          IF vr_num_retor_int = 0 THEN
            -- Se o cursor dinamico está aberto
            IF dbms_sql.is_open(vr_num_cursor_int) THEN
              -- Fecha o mesmo
              dbms_sql.close_cursor(vr_num_cursor_int);
            END IF;
            EXIT; 
          ELSE 
            -- Carrega variáveis com o retorno do cursor
            dbms_sql.column_value(vr_num_cursor_int, 1, vr_dsmodelo);
            dbms_sql.column_value(vr_num_cursor_int, 2, vr_inpessoa);
            dbms_sql.column_value(vr_num_cursor_int, 3, vr_qtregistros);
            -- Alimentar quantidade conforme tipo de pessoa
            IF vr_inpessoa = 1 THEN
              vr_qtregis_fisica := vr_qtregis_fisica + vr_qtregistros;
            ELSE 
              vr_qtregis_juridi := vr_qtregis_juridi + vr_qtregistros;
            END IF;
          END IF;    
        END LOOP;     

        -- Se encontrou algum registro
        IF vr_qtregis_fisica + vr_qtregis_juridi > 0 THEN
          
          -- Armazenar inicio do processo
          vr_dtinicio := SYSDATE;        
          
          -- Armazenar timestamp de inicio do processo nesse SKCarga
          BEGIN
            vr_sql_cursor_int := 'update '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink||' car '
                              || '   set car.dthorainicioprocesso = to_date('''||to_char(vr_dtinicio,'ddmmrrrrhh24miss')||''',''ddmmrrrrhh24miss'') '
                              || ' where car.skcarga = '||vr_skcarga;
            -- Cria cursor dinâmico
            vr_num_cursor_int := dbms_sql.open_cursor;
            -- Comando Parse
            dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
            -- Executar Update
            vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
            -- Close cursor
            dbms_sql.close_cursor(vr_num_cursor_int);        
          EXCEPTION
            WHEN vr_excsaida THEN
              RAISE vr_excsaida;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro na atualizacao de inicio da carga do Score: '||SQLERRM;
              RAISE vr_excsaida;  
          END;       
          
          -- Gravar após dar início a carga
          COMMIT;
              
        
          -- Incrementar totalizador
          vr_qtregis_tot := vr_qtregis_tot + vr_qtregis_fisica + vr_qtregis_juridi;
          
          -- Primeiro vamos gravar a tabela pai (somente se não gravada ainda)
          IF vr_rowidcarga IS NULL THEN
            BEGIN
              INSERT INTO tbcrd_carga_score(cdmodelo
                                           ,dtbase
                                           ,dsmodelo 
                                           ,dtinicio 
                                           ,dttermino
                                           ,cdopcao 
                                           ,cdoperad
                                           ,qtregis_fisica 
                                           ,qtregis_juridi
                                           ,dsrejeicao)
                                     VALUES(pr_cdmodelo
                                           ,pr_dtbase
                                           ,vr_dsmodelo
                                           ,vr_dtinicio
                                           ,SYSDATE
                                           ,pr_cddopcao
                                           ,pr_cdoperad
                                           ,0
                                           ,0
                                           ,pr_dsrejeicao)
                                     RETURNING ROWID INTO vr_rowidcarga;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar historico de carga: '||SQLERRM;
                RAISE vr_excsaida;
            END;  
          END IF;
            
          -- Se solicitado Aprovação, então faremos a carga das tabelas de score e exclusão mas se rejeição
          -- não faremos nada, apenas criamos histórico para que essa carga seja desprezada depois
          IF pr_cddopcao = 'A' THEN
            -- Na sequencia a carga do score
            BEGIN          
              vr_sql_cursor_int := 'INSERT INTO tbcrd_score(cdmodelo '
                            || '                       ,dtbase '
                            || '                       ,tppessoa '
                            || '                       ,cdcooper '
                            || '                       ,nrcpfcnpjbase '
                            || '                       ,nrscore_alinhado '
                            || '                       ,dsclasse_score '
                            || '                       ,dsexclusao_principal '
                            || '                       ,flvigente) '
                            || '                  SELECT sco.cdmodelo '
                            || '                        ,sco.dtbase '
                            || '                        ,sco.tppessoa '
                            || '                        ,sco.cdcooper '
                            || '                        ,sco.nrcpfcnpjbase '
                            || '                        ,sco.nrscorealinhado '
                            || '                        ,sco.dsclassescore '
                            || '                        ,sco.dsexclusaoprincipal '
                            || '                        ,1 '
                            || '                    FROM '||vr_nom_owner||'sas_score@'||vr_nom_dblink||' sco '
                            || '                   WHERE sco.cdmodelo = '||pr_cdmodelo
                            || '                     AND sco.dtbase   = to_date('''||to_char(pr_dtbase, 'ddmmyyyy')||''', ''ddmmyyyy'')'
                            || '                     AND sco.skcarga = '||vr_skcarga;
              -- Cria cursor dinâmico
              vr_num_cursor_int := dbms_sql.open_cursor;
              -- Comando Parse
              dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
              -- Executar insert
              vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
              -- Close cursor
              dbms_sql.close_cursor(vr_num_cursor_int);        
              -- Se não carregou nada
              IF vr_num_retor_int = 0 THEN
                vr_dscritic := 'Erro na carga do Score. Nenhum registro encontrado para o modelo e data base!';
                RAISE vr_excsaida;              
              END IF;
            EXCEPTION
              WHEN vr_excsaida THEN
                RAISE vr_excsaida;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro na carga do Score: '||SQLERRM;
                RAISE vr_excsaida;  
            END;

            -- Depois das exclusões
            BEGIN
              vr_sql_cursor_int := 'INSERT INTO tbcrd_score_exclusao '
                            || '                       (cdmodelo '
                            || '                       ,dtbase '
                            || '                       ,tppessoa '
                            || '                       ,cdcooper '
                            || '                       ,nrcpfcnpjbase '
                            || '                       ,cdexclusao '
                            || '                       ,dsexclusao) '
                            || '                  SELECT sce.cdmodelo '
                            || '                        ,sce.dtbase '
                            || '                        ,sce.tppessoa '
                            || '                        ,sce.cdcooper '
                            || '                        ,sce.nrcpfcnpjbase '
                            || '                        ,sce.cdexclusao '
                            || '                        ,sce.dsexclusao '
                            || '                    FROM '||vr_nom_owner||'sas_score_exclusao@'||vr_nom_dblink||' sce '
                            || '                   WHERE sce.cdmodelo = '||pr_cdmodelo
                            || '                     AND sce.dtbase   = to_date('''||to_char(pr_dtbase, 'ddmmyyyy')||''', ''ddmmyyyy'')'
                            || '                     AND sce.skcarga = '||vr_skcarga;
              -- Cria cursor dinâmico
              vr_num_cursor_int := dbms_sql.open_cursor;
              -- Comando Parse
              dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
              -- Executar insert
              vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
              -- Close cursor
              dbms_sql.close_cursor(vr_num_cursor_int);        
            EXCEPTION
              WHEN vr_excsaida THEN
                RAISE vr_excsaida;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro na carga de exclusoes do Score: '||SQLERRM;
                RAISE vr_excsaida;  
            END; 
            
            -- Buscar ultima data base vigente
            OPEN cr_Ult_carga;
            FETCH cr_Ult_carga
             INTO vr_dtbase;
            CLOSE cr_Ult_carga;
            
            -- Vamos setar todas os scores que não sejam da data base e modelo atual como não vigentes
            -- e as da ultima database como vigente
            BEGIN
              UPDATE tbcrd_score
                 SET flvigente = decode(dtbase,pr_dtbase,1,0)
               WHERE cdmodelo = pr_cdmodelo;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao remover vigencias de scores antigos: '||SQLERRM;
                RAISE vr_excsaida;
            END;               
            
            -- Guardar data de termino
            vr_dtfinali := SYSDATE;
            
            -- Atualizar FatorCarga com quantidade processada e fim da carga
            BEGIN
              vr_sql_cursor_int := 'update '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink||' car '
                                || '   set car.dthorafimprocesso = to_date('''||to_char(vr_dtfinali,'ddmmrrrrhh24miss')||''',''ddmmrrrrhh24miss'') '
                                || '      ,car.qtregistrook = '||to_char(vr_qtregis_fisica + vr_qtregis_juridi)
                                || ' where car.skcarga = '||vr_skcarga;
              -- Cria cursor dinâmico
              vr_num_cursor_int := dbms_sql.open_cursor;
              -- Comando Parse
              dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
              -- Executar Update
              vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
              -- Close cursor
              dbms_sql.close_cursor(vr_num_cursor_int);        
            EXCEPTION
              WHEN vr_excsaida THEN
                RAISE vr_excsaida;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro na atualizacao de finalização da carga do Score: '||SQLERRM;
                RAISE vr_excsaida;  
            END;       
            
          ELSE
            
            -- Guardar data de termino
            vr_dtfinali := SYSDATE;
            
            -- Atualizar FatorCarga com quantidade de registros rejeitados e fim da carga
            BEGIN
              vr_sql_cursor_int := 'update '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink||' car '
                                || '   set car.dthorafimprocesso = to_date('''||to_char(vr_dtfinali,'ddmmrrrrhh24miss')||''',''ddmmrrrrhh24miss'') '
                                || '      ,car.qtregistroerro = '||to_char(vr_qtregis_fisica + vr_qtregis_juridi)
                                || ' where car.skcarga = '||vr_skcarga;
              -- Cria cursor dinâmico
              vr_num_cursor_int := dbms_sql.open_cursor;
              -- Comando Parse
              dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
              -- Executar Update
              vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
              -- Close cursor
              dbms_sql.close_cursor(vr_num_cursor_int);        
            EXCEPTION
              WHEN vr_excsaida THEN
                RAISE vr_excsaida;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro na atualizacao de finalização da carga do Score: '||SQLERRM;
                RAISE vr_excsaida;  
            END; 
          END IF;
          
          -- Por fim atualizamos o horário final da carga e as quantidades processadas
          BEGIN
            UPDATE tbcrd_carga_score car
               SET car.dttermino = vr_dtfinali
                  ,car.qtregis_fisica = car.qtregis_fisica + vr_qtregis_fisica 
                  ,car.qtregis_juridi = car.qtregis_juridi + vr_qtregis_juridi
             WHERE ROWID = vr_rowidcarga;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar historico de carga: '||SQLERRM;
              RAISE vr_excsaida;
          END;
        END IF;
        
        -- Gravar a cada fator_controle_carga
        COMMIT;

      END IF;    
    END LOOP;   
    
    
    -- Se não encontrou nenhum registro
    IF vr_qtregis_tot = 0 THEN
      -- Gerar erro
      vr_dscritic := 'Modelo '||pr_cdmodelo||' na data base '||to_char(pr_dtbase,'dd/mm/rrrrr')||' sem registro para carga! Processo nao efetuado...';
      RAISE vr_excsaida;    
    END IF;
    
    -- Busca nome do operador
    open cr_crapope(3,pr_cdoperad);
    fetch cr_crapope into rw_crapope;
    CLOSE cr_crapope;
    
    -- Preencher o LOG
    IF pr_cddopcao = 'A' THEN
      vr_deslog := 'Aprovacao de Carga ';
    ELSE
      vr_deslog := 'Rejeicao de Carga ';
    END IF;
    -- Incrementar
    vr_deslog := vr_deslog 
              || 'Modelo '||pr_cdmodelo||'- '||vr_dsmodelo|| ' Data Base '||to_char(pr_dtbase,'mm/rrrr')
              || ' com '||to_char(vr_qtregis_tot)||' registros por '
              || 'Operador '||pr_cdoperad||' - '||rw_crapope.nmoperad;
    
    -- Gerar LOG
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'SCORE'
                              ,pr_flfinmsg     => 'N'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                               || ' --> ' || vr_deslog);

    -- Finalizar gravando as alterações
    COMMIT;
  EXCEPTION
    WHEN vr_excsaida THEN
      IF dbms_sql.is_open(vr_num_cursor) THEN
        -- Close cursor
        dbms_sql.close_cursor(vr_num_cursor);     
      END IF;
      IF dbms_sql.is_open(vr_num_cursor_int) THEN
        -- Close cursor
        dbms_sql.close_cursor(vr_num_cursor_int);     
      END IF;
      -- Devolucao de criticas
      pr_dscritic := 'Erro na execucao da Carga/Rejeicao: '||vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      IF dbms_sql.is_open(vr_num_cursor) THEN
        -- Close cursor
        dbms_sql.close_cursor(vr_num_cursor);     
      END IF;
      IF dbms_sql.is_open(vr_num_cursor_int) THEN
        -- Close cursor
        dbms_sql.close_cursor(vr_num_cursor_int);     
      END IF;
      -- Devolucao de criticas
      pr_dscritic := 'Erro nao tratado na execucao da Carga/Rejeicao: '||SQLERRM;
      ROLLBACK;
  END;  
  
  -- Procedimento para execução da carga do Behaviour enviada
  PROCEDURE pc_efetua_exclu_score_behavi(pr_cdmodelo IN tbcrd_carga_score.cdmodelo%TYPE      -- Codigo do Modelo
                                        ,pr_dtbase   IN tbcrd_carga_score.dtbase%TYPE        -- Data base 
                                        ,pr_cdoperad IN tbcrd_carga_score.cdoperad%TYPE      -- Operador
                                        ,pr_dscritic OUT VARCHAR2)                           -- Critica de saida
                                         IS                      
    -- ..........................................................................
    -- 
    --   Programa: pc_efetua_exclu_score_behavi
    --   Sigla   : CRED
    --   Autor   : Marcos Martini - Envolti
    --   Data    : Novembro/2018                         Ultima atualizacao: 
    --
    --   Dados referentes ao programa:
    --
    --   Frequencia: Sempre que solicitado
    --   Objetivo  : Efetuar a exclusão do score repassado
    --
    --   Alteracoes: 
    --
  
    -- Tratamento de criticas
    vr_dscritic VARCHAR2(4000);
    vr_excsaida EXCEPTION;
    
    -- Buscar dados da carga em exclusão
    CURSOR cr_carga IS
      SELECT car.dsmodelo
            ,car.cdopcao
            ,car.qtregis_fisica
            ,car.qtregis_juridi
        FROM tbcrd_carga_score car
       WHERE car.cdmodelo = pr_cdmodelo
         AND car.dtbase   = pr_dtbase
       ORDER BY car.dttermino DESC;
    rw_carga cr_carga%ROWTYPE;
    
    -- Buscar a ultima carga
    CURSOR cr_Ult_carga IS
      SELECT car.dtbase
        FROM tbcrd_carga_score car
       WHERE car.cdmodelo = pr_cdmodelo
         AND car.cdopcao = 'A'
       ORDER BY car.dtbase DESC;
    vr_dtbase tbcrd_carga_score.dtbase%TYPE;  
    
    -- Logs --
    vr_deslog VARCHAR2(4000);  
    
  BEGIN
    -- Validar Modelo
    IF pr_cdmodelo IS NULL THEN
      vr_dscritic := 'Modelo de Carga deve ser informado!';
      RAISE vr_excsaida;
    END IF;
    -- Validar DtBase
    IF pr_dtbase IS NULL THEN
      vr_dscritic := 'Data Base de Carga deve ser informado!';
      RAISE vr_excsaida;
    END IF;   
    
    -- Buscar dados da carga em exclusão
    OPEN cr_carga;
    FETCH cr_carga 
     INTO rw_carga;    
    -- Se não encontrar
    IF cr_carga%NOTFOUND THEN
      CLOSE cr_carga;
      vr_dscritic := 'Modelo e Data Base Carga para exlusao nao encontrados na base de dados!';
      RAISE vr_excsaida;
    ELSE
      CLOSE cr_carga;
    END IF;
    
    -- Buscar qual foi a ultima carga aprovada
    OPEN cr_Ult_carga;
    FETCH cr_Ult_carga
     INTO vr_dtbase;
    CLOSE cr_Ult_carga;
    
    -- Se a carga selecionada não for a vigente
    IF vr_dtbase <> pr_Dtbase THEN
      vr_dscritic := 'Data Base Carga para exlusao e invalida! Somente a data base vigente pode ser eliminada!';
      RAISE vr_excsaida;
    END IF;
    
    -- Eliminar tabela de exclusões
    BEGIN
      DELETE FROM tbcrd_score_exclusao 
            WHERE cdmodelo = pr_cdmodelo
              AND dtbase   = pr_dtbase;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na exclusao da Lista de Exclusoes: '||SQLERRM;
        RAISE vr_excsaida;
    END;
    
    -- Eliminar tabela de scores
    BEGIN
      DELETE FROM tbcrd_score
            WHERE cdmodelo = pr_cdmodelo
              AND dtbase   = pr_dtbase;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na exclusao dos Scores: '||SQLERRM;
        RAISE vr_excsaida;
    END;    
    
    -- Eliminar tabela de carga
    BEGIN
      DELETE FROM tbcrd_carga_score
            WHERE cdmodelo = pr_cdmodelo
              AND dtbase   = pr_dtbase;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na exclusao da Carga: '||SQLERRM;
        RAISE vr_excsaida;
    END;
    
    -- Buscar qual foi a ultima carga aprovada
    -- Refazemos a consulta pois agora será desprezada a recem eliminada
    OPEN cr_Ult_carga;
    FETCH cr_Ult_carga
     INTO vr_dtbase;
    CLOSE cr_Ult_carga;
    
    -- Se encontrou alguma carga
    IF vr_dtbase IS NOT NULL THEN
      -- Transformar a ultima carregada como vigente
      BEGIN
        UPDATE tbcrd_score sco
           SET sco.flvigente = decode(sco.dtbase,vr_dtbase,1,0)
         WHERE sco.cdmodelo = pr_cdmodelo;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na exclusao da Carga: '||SQLERRM;
          RAISE vr_excsaida;
      END;
    END IF;
    
    -- Busca nome do operador
    open cr_crapope(3,pr_cdoperad);
    fetch cr_crapope into rw_crapope;
    CLOSE cr_crapope;
    
    -- Preencher o LOG
    vr_deslog := 'Exclusao de Carga ';
    IF rw_carga.cdopcao = 'A' THEN
      vr_deslog := vr_deslog 
                || 'Aprovada';
    ELSE
      vr_deslog := vr_deslog 
                || 'Rejeitada';
    END IF;
    -- Incrementar
    vr_deslog := vr_deslog 
              || ' Modelo '||pr_cdmodelo||'- '||rw_carga.dsmodelo|| ' Data Base '||to_char(pr_dtbase,'mm/rrrr')
              || ' com '||to_char(rw_carga.qtregis_fisica+rw_carga.qtregis_juridi)||' registros por '
              || 'Operador '||pr_cdoperad||' - '||rw_crapope.nmoperad;
    
    -- Gerar LOG
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'SCORE'
                              ,pr_flfinmsg     => 'N'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                               || ' --> ' || vr_deslog);
    
    -- Finalizar gravando as alterações
    COMMIT;
  EXCEPTION
    WHEN vr_excsaida THEN
      -- Devolucao de criticas
      pr_dscritic := 'Erro na exclusão da Carga: '||vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      -- Devolucao de criticas
      pr_dscritic := 'Erro nao tratado na exclusão da Carga/Rejeicao: '||SQLERRM;
      ROLLBACK;
  END;    
  

END RISC0005;
/
