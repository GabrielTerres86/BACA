CREATE OR REPLACE PACKAGE EXPURGO.EXPU0001 AUTHID CURRENT_USER  is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : EXPU0001
      Sistema  : Rotinas referentes expurgo de dados para a base historica
      Sigla    : EXPU
      Autor    : Odirlei Busana - AMcom
      Data     : março/2017.                   Ultima atualizacao: 03/03/2017

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes expurgo de dados para a base historica.

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  -- Armazenar os Comandos de deleção que só podem ser executados no final
  -- da copia dos filhos
  TYPE typ_rec_comand 
        IS RECORD (dscomand VARCHAR2(32000),
                   idcontrole tbhst_controle.idcontrole%TYPE,
                   nmtabela VARCHAR2(300),
                   nmowner  VARCHAR2(300),
                   qtdregis INTEGER);
  TYPE typ_tab_comand IS TABLE OF typ_rec_comand
       INDEX BY PLS_INTEGER;
  
  --> Rotina para realizar processamento do expurgo
  PROCEDURE pc_processar_expurgo (pr_cdcritic  OUT INTEGER,
                                  pr_dscritic  OUT VARCHAR2 );
                                  
  PROCEDURE pc_processar_expurgo_dep (pr_idcontrole       IN INTEGER,  --> Id de controle de expurgo principal/anterior 
                                      pr_nrdias_retencao  IN INTEGER,  --> Numero de dias de retenção de dados
                                      pr_dsdwhere         IN VARCHAR2, --> Clausula where
                                      pr_tab_comand       IN OUT NOCOPY typ_tab_comand,  --> Retornar os comandos de deleção, a serem efetuados no final de todas as copias
                                      pr_dscritic  OUT VARCHAR2 );
                                      
  --> Rotina para realizar o expurgo da tabela
  PROCEDURE pc_expurgo_tabela (pr_idcontrole       IN INTEGER,  --> Id de controle
                               pr_nmowner          IN VARCHAR2, --> Nome do owner onde a tabela se encontra
                               pr_nmtabela         IN VARCHAR2, --> Nome da tabela a ser copiada
                               pr_dscampos         IN VARCHAR2, --> Campos da chave, para opcao somente copia
                               pr_tpoperacao       IN INTEGER,  --> Tipo de operacao (1-somente copia/ 2- copia e exclui/ 3-somente exclui)                               
                               pr_dsdwhere         IN VARCHAR2, --> Clausula where
                               pr_tab_comand       IN OUT NOCOPY typ_tab_comand,  --> Retornar os comandos de deleção, a serem efetuados no final de todas as copias
                               pr_qtdregis        OUT INTEGER,  --> Retorna a quantidade de registros copiados/excluidos 
                               pr_dscritic        OUT VARCHAR2  --> Retorna critica
                               );
                                
  --> Rotina para realizar processamento do expurgo outros
  PROCEDURE pc_processar_expurgo_outros (pr_dscritic  OUT VARCHAR2 );                                
                                       
END EXPU0001;
/
CREATE OR REPLACE PACKAGE BODY EXPURGO.EXPU0001  is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : EXPU0001
      Sistema  : Rotinas referentes expurgo de dados para a base historica
      Sigla    : EXPU
      Autor    : Odirlei Busana - AMcom
      Data     : março/2017.                   Ultima atualizacao: 03/03/2017

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes expurgo de dados para a base historica.

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
  
  vr_dblink_hist VARCHAR2(30) := 'hstayllos';
  vr_dtdiaatu    DATE         := SYSDATE;
  
  --> Rotina para geração de log de expurgo
  PROCEDURE pc_log_expurgo (pr_idcontrole  IN INTEGER,             --> Id de controle de expurgo
                            pr_tpoperacao  IN INTEGER DEFAULT 1,   --> tipo de operacao realizada (1-copia/ 3-exclusao) 
                            pr_qtdregis    IN INTEGER,             --> Qtd de registros excluidos
                            pr_qtdtempo    IN INTEGER,             --> Tempo de processamento
                            pr_dslogexp    IN VARCHAR2,            --> Descrição de critica/log do expurgo     
                            pr_dscritic   OUT VARCHAR2 ) IS        --> Retorna critica
  /* ..........................................................................
    
      Programa : pc_log_expurgo        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Fevereiro/2017.                   Ultima atualizacao: 03/02/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para geração de log de expurgo
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros    
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;   
    
    PRAGMA AUTONOMOUS_TRANSACTION;
    
  BEGIN
  
    INSERT INTO tbhst_log
                ( idcontrole, 
                  dhoperacao, 
                  qtdreg_operacao, 
                  qtdtempo_operacao,
                  dserro, 
                  tpoperacao  )
          VALUES (pr_idcontrole, 
                  SYSDATE, 
                  nvl(pr_qtdregis,0), 
                  nvl(pr_qtdtempo,0),
                  substr(pr_dslogexp,1,500),
                  pr_tpoperacao );     
  
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      ROLLBACK;
      pr_dscritic := 'Não foi possivel gerar log do expurgo: '||SQLERRM;
  END pc_log_expurgo; 
  
  --> Rotina para realizar processamento do expurgo
  PROCEDURE pc_processar_expurgo (pr_cdcritic  OUT INTEGER,
                                  pr_dscritic  OUT VARCHAR2 )  IS
  /* ..........................................................................
    
      Programa : pc_processar_expurgo        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Fevereiro/2017.                   Ultima atualizacao: 03/02/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para realizar processamento do expurgo
      
      Alteração : 22/11/2017 - Inclusão de geração da estatitistica da tabela 
                               apos exclusao dos dados.
                               SD755804 (Odirlei-AMcom)
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar tabelas que possuem configuração
    CURSOR cr_tbhstctl (pr_dtdiaatu DATE )IS
      SELECT ctl.nmowner,
             ctl.nmtabela,
             ctl.nmcampo_refere,
             ctl.nrdias_refere,
             ctl.idcontrole,
             ctl.tpoperacao,
             ctl.rowid             
        FROM tbhst_controle ctl
        --> Registro deve ser registro principal        
       WHERE NOT EXISTS (SELECT 1
                           FROM tbhst_dependencia dep
                          WHERE dep.iddepende = ctl.idcontrole )
         AND ctl.nmtabela NOT IN ('CRAPSQU')
         --> Respeitar o inicio das execuções
         AND ctl.dtinicio <= TRUNC(pr_dtdiaatu)
         --> Para intervalos diferentes de diario, rodarão apenas nos domingos                 
         AND ( (ctl.tpintervalo <> 1 AND to_char(pr_dtdiaatu,'D') = 1) OR
               ctl.tpintervalo = 1)
         AND ( TRUNC(ctl.dhultima_operacao) <= 
               (TRUNC(pr_dtdiaatu - DECODE(ctl.tpintervalo,1, 1,  --> Diario
                                                           2, 7,  --> Semana
                                                           3,15,  --> Quinzenal
                                                           4,30,  --> Mensal 
                                                           5,365))--> Anual
                ) OR 
              ctl.dhultima_operacao IS NULL )
         --> Processar conforme os tipos de operação
         --> Primeiro as cargas de de tabelas nao transacionais, configuradas como "1- apenas copia"     
         ORDER BY ctl.tpoperacao;
       
    --> Buscar tabelas dependentes
    CURSOR cr_tbhstdep (pr_idcontrole INTEGER)IS
      SELECT dep.tpcontrole,
             ctl.nmowner,
             ctl.nmtabela,
             ctl.nmcampo_refere,
             dep.iddepende
          
        FROM tbhst_controle ctl,
             tbhst_dependencia dep
       WHERE ctl.idcontrole = dep.iddepende
         AND dep.idcontrole = pr_idcontrole;     
    
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_dscritic_aux VARCHAR2(4000);
    vr_exc_erro EXCEPTION;   
    vr_exc_prox EXCEPTION;   
    vr_qtdregis INTEGER;
    vr_qtregexc INTEGER;
    vr_tempoini NUMBER;
    vr_qtdtempo NUMBER;
    vr_dsdwhere VARCHAR2(10000);
    vr_tab_comand   typ_tab_comand;
    
    
  BEGIN
  
    --> buscar todas as tabelas pendentes para realizar o expurgo
    FOR rw_tbhstctl IN cr_tbhstctl(pr_dtdiaatu => vr_dtdiaatu ) LOOP
      BEGIN
        vr_tab_comand.delete;
        
        --> INICIAR PROCESSO TABELA PRINCIPAL        
        vr_tempoini := DBMS_UTILITY.get_time;
        
        --> Nao montar clausula where para opcao de somente copia
        --> Está irá fazer carga total da tabela
        vr_dsdwhere := NULL;
        IF rw_tbhstctl.tpoperacao <> 1 THEN
          vr_dsdwhere := ''||rw_tbhstctl.nmtabela||'.'||rw_tbhstctl.nmcampo_refere||' < '||
                         'TO_DATE('''|| to_char(vr_dtdiaatu - rw_tbhstctl.nrdias_refere,'DD/MM/RRRR')||''',''DD/MM/RRRR'')';
        END IF;  
        --> Realizar expurgo dos dados
        pc_expurgo_tabela (pr_idcontrole       => rw_tbhstctl.idcontrole,      --> Id de controle
                           pr_nmowner          => rw_tbhstctl.nmowner,         --> Nome do owner onde a tabela se encontra
                           pr_nmtabela         => rw_tbhstctl.nmtabela,        --> Nome da tabela a ser copiada
                           pr_dscampos         => rw_tbhstctl.nmcampo_refere,  --> Campos da chave, para opcao somente copia
                           pr_tpoperacao       => rw_tbhstctl.tpoperacao,      --> Tipo de operacao (1-somente copia/ 2- copia e exclui/ 3-somente exclui)
                           pr_dsdwhere         => vr_dsdwhere,                        
                           pr_tab_comand       => vr_tab_comand,               --> Retornar os comandos de deleção, a serem efetuados no final de todas as copias
                           pr_qtdregis         => vr_qtdregis,                 --> Retorna a quantidade de registros copiados/excluidos 
                           pr_dscritic         => vr_dscritic_aux);                --> Retorna critica
            
        
        vr_qtdtempo := (DBMS_UTILITY.get_time - vr_tempoini)/100;
               
        
        --> Gerar log apenas se nao for operação de apenas exclui(pois esta o log será gerado em outro monento)
        IF rw_tbhstctl.tpoperacao <> 3 OR 
           vr_dscritic_aux IS NOT NULL THEN
           
          --> Gerar log da operacao
          pc_log_expurgo (pr_idcontrole  => rw_tbhstctl.idcontrole,      --> Id de controle de expurgo
                          pr_tpoperacao  => 1,                           --> tipo de operacao realizada (1-copia/ 3-exclusao) 
                          pr_qtdregis    => vr_qtdregis,                 --> Qtd de registros excluidos
                          pr_qtdtempo    => vr_qtdtempo,                 --> Tempo de processamento
                          pr_dslogexp    => vr_dscritic_aux,             --> Descrição de critica/log do expurgo     
                          pr_dscritic    => vr_dscritic);                --> Retorna critica
        
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;   
          
          -- Caso retornou erro, ir para a proxima tabela
          IF vr_dscritic_aux IS NOT NULL THEN
            vr_dscritic_aux := NULL;
            RAISE vr_exc_prox; 
          END IF;        
          
        END IF;             
      
        --> VERIFICAR/PROCESSAR TABELAS DEPENDENTES
        pc_processar_expurgo_dep (pr_idcontrole       => rw_tbhstctl.idcontrole,    --> Id de controle de expurgo principal/anterior 
                                  pr_nrdias_retencao  => rw_tbhstctl.nrdias_refere, --> Numero de dias de retenção de dados
                                  pr_dsdwhere         => vr_dsdwhere,               --> Clausula where
                                  pr_tab_comand       => vr_tab_comand,             --> Retornar os comandos de deleção, a serem efetuados no final de todas as copias
                                  pr_dscritic         => vr_dscritic_aux );
        
        -- Caso retornou erro, ir para a proxima tabela
        -- Ja foi gerado log na rotina de dependentes
        IF vr_dscritic_aux IS NOT NULL THEN
          vr_dscritic_aux := NULL;
          RAISE vr_exc_prox; 
        END IF; 
        
        --> Apenas realizar a deleção se nao for  1-apenas copia
        IF rw_tbhstctl.tpoperacao <> 1 THEN
        
          IF vr_tab_comand.count = 0 THEN
            vr_dscritic_aux := 'Comandos de Deleção não encontrados.';
            RAISE vr_exc_prox;          
          END IF;
        
          --> BUSCAR COMANDOS DE DELEÇÃO
          FOR vr_idx IN REVERSE vr_tab_comand.first..vr_tab_comand.last LOOP
          
            vr_tempoini := DBMS_UTILITY.get_time;
            
            --> Executar comando de exclusao
            BEGIN
              EXECUTE IMMEDIATE vr_tab_comand(vr_idx).dscomand;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic_aux := 'Erro ao efetuar exclusao '||vr_tab_comand(vr_idx).nmtabela||
                                   ': '||SQLERRM;      
            END;
            
            vr_qtdtempo := (DBMS_UTILITY.get_time - vr_tempoini)/100;          
            vr_qtregexc := SQL%ROWCOUNT;
            
            --> apenas validar qnt se nao ja apresentou erro
            IF vr_dscritic_aux IS NULL AND
               --> Somente exclusao nao precisa validar qtd 
               rw_tbhstctl.tpoperacao <> 3 THEN
              IF vr_qtregexc <> nvl(vr_tab_comand(vr_idx).qtdregis,0) THEN
                vr_dscritic_aux := 'Quantidade de registro copiados e excluidos da tabela '||
                                   vr_tab_comand(vr_idx).nmtabela || ' não conferem';      
              END IF;
            END IF;
            
            --> Gerar log da operacao
            pc_log_expurgo (pr_idcontrole  => vr_tab_comand(vr_idx).idcontrole,   --> Id de controle de expurgo
                            pr_tpoperacao  => 3,                           --> tipo de operacao realizada (1-copia/ 3-exclusao) 
                            pr_qtdregis    => vr_qtregexc,                 --> Qtd de registros excluidos
                            pr_qtdtempo    => vr_qtdtempo,                 --> Tempo de processamento
                            pr_dslogexp    => NULL,                        --> Descrição de critica/log do expurgo     
                            pr_dscritic    => vr_dscritic);                --> Retorna critica
          
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            
            IF vr_dscritic_aux IS NOT NULL THEN
              vr_dscritic_aux := NULL;
              RAISE vr_exc_prox;
            END IF;
            
            -->> GERAR ESTATISTICA DE BANCO DAS TABELAS QUE SOFRERAM EXCLUSAO <<--
            vr_tempoini := DBMS_UTILITY.get_time;
            cecreddba.proc_gather_table_stats(schema_user => upper(vr_tab_comand(vr_idx).nmowner),
                                              table_user  => upper(vr_tab_comand(vr_idx).nmtabela));
            vr_qtdtempo := (DBMS_UTILITY.get_time - vr_tempoini)/100;   
                   
            --> Gerar log da operacao
            pc_log_expurgo (pr_idcontrole  => vr_tab_comand(vr_idx).idcontrole,   --> Id de controle de expurgo
                            pr_tpoperacao  => 4,                           --> tipo de operacao realizada (1-copia/ 3-exclusao) 
                            pr_qtdregis    => 0,                           --> Qtd de registros excluidos
                            pr_qtdtempo    => vr_qtdtempo,                 --> Tempo de processamento
                            pr_dslogexp    => NULL,                        --> Descrição de critica/log do expurgo     
                            pr_dscritic    => vr_dscritic);                --> Retorna critica
          
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              --ignorar caso apresente falha na geracao deste log
              NULL;
            END IF;
            
          
          END LOOP;
        END IF;
        --> Atualizar controle com a data de execução
        BEGIN
          UPDATE tbhst_controle ctl
             SET ctl.dhultima_operacao = SYSDATE
           WHERE ctl.rowid = rw_tbhstctl.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic_aux := 'Nao foi possivel atualizar tbhst_controle: '||SQLERRM;
            RAISE vr_exc_prox;
        END;
        
        COMMIT;
      
      EXCEPTION
        WHEN vr_exc_prox THEN
          ROLLBACK;
          
          -- Gravar log apenas se possuir critica
          IF  vr_dscritic_aux IS NOT NULL THEN
            vr_dscritic_aux := 'Erro ao processar tabela '||rw_tbhstctl.nmtabela||': '||vr_dscritic_aux;
            --> Gerar log da operacao
            pc_log_expurgo (pr_idcontrole  => rw_tbhstctl.idcontrole,      --> Id de controle de expurgo
                            pr_qtdregis    => 0,                 --> Qtd de registros excluidos
                            pr_qtdtempo    => 0,                 --> Tempo de processamento
                            pr_dslogexp    => vr_dscritic_aux,             --> Descrição de critica/log do expurgo     
                            pr_dscritic    => vr_dscritic);                --> Retorna critica
          
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
          
        WHEN OTHERS THEN
          ROLLBACK;
          vr_dscritic_aux := 'Erro ao processar tabela '||rw_tbhstctl.nmtabela||': '||SQLERRM;
        
          --> Gerar log da operacao
          pc_log_expurgo (pr_idcontrole  => rw_tbhstctl.idcontrole,      --> Id de controle de expurgo
                          pr_qtdregis    => 0,                 --> Qtd de registros excluidos
                          pr_qtdtempo    => 0,                 --> Tempo de processamento
                          pr_dslogexp    => vr_dscritic_aux,             --> Descrição de critica/log do expurgo     
                          pr_dscritic    => vr_dscritic);                --> Retorna critica
        
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
      END;
    END LOOP;
    
    --> Processar expurgo de tabelas que não possuem padrão
    pc_processar_expurgo_outros (pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  
  

  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      RAISE_application_error(-20501,pr_dscritic);
    
    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar expurgo: '||SQLERRM;
      RAISE_application_error(-20501,pr_dscritic);
  END pc_processar_expurgo; 
  
  PROCEDURE pc_processar_expurgo_dep (pr_idcontrole       IN INTEGER,  --> Id de controle de expurgo principal/anterior 
                                      pr_nrdias_retencao  IN INTEGER,  --> Numero de dias de retenção de dados
                                      pr_dsdwhere         IN VARCHAR2, --> Clausula where
                                      pr_tab_comand       IN OUT NOCOPY typ_tab_comand,  --> Retornar os comandos de deleção, a serem efetuados no final de todas as copias
                                      pr_dscritic  OUT VARCHAR2 )  IS
  /* ..........................................................................
    
      Programa : pc_processar_expurgo        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Fevereiro/2017.                   Ultima atualizacao: 03/02/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para realizar processamento do expurgo
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
       
    --> Buscar tabelas dependentes
    CURSOR cr_tbexpdep (pr_idcontrole INTEGER)IS
      SELECT dep.tpcontrole,
             ctl.idcontrole,
             ctl.nmowner,
             ctl.nmtabela,
             ctl.tpoperacao,
             ctl.nmcampo_refere,
             dep.iddepende,
             ctl_pri.nmtabela nmtabela_pri,
             ctl_pri.nmowner nmowner_pri
        FROM tbhst_controle ctl,
             tbhst_controle ctl_pri,
             tbhst_dependencia dep
       WHERE ctl.idcontrole = dep.iddepende
         AND dep.idcontrole = ctl_pri.idcontrole
         AND dep.idcontrole = pr_idcontrole;     
    
    
    --> Buscar os campos para montagem do join
    CURSOR cr_join (pr_nmtabela     VARCHAR2,
                    pr_nmtabela_pri VARCHAR2,
                    pr_nmowner      VARCHAR2) IS 
      SELECT l1.TABLE_NAME tbname1
            ,l1.COLUMN_NAME tbcol1
            ,l2.TABLE_NAME  tbname2
            ,l2.COLUMN_NAME tbcol2
        FROM All_Constraints  c1 --> tabela filha
            ,All_Cons_Columns l1
            ,All_Constraints  c2 --> tabela pai
            ,All_Cons_Columns l2
       WHERE l1.OWNER = c1.OWNER
         AND l1.CONSTRAINT_NAME = c1.CONSTRAINT_NAME
         AND l1.TABLE_NAME      = c1.TABLE_NAME
         AND l2.OWNER = c2.OWNER
         AND l2.CONSTRAINT_NAME = c2.CONSTRAINT_NAME
         AND l2.TABLE_NAME      = c2.TABLE_NAME
            
         AND c1.OWNER = c2.OWNER
         AND c1.R_CONSTRAINT_NAME = c2.CONSTRAINT_NAME
         
         AND c2.OWNER = UPPER(pr_nmowner)
         AND c2.TABLE_NAME = UPPER(pr_nmtabela_pri)
         AND c2.CONSTRAINT_TYPE = 'P'
            
         AND c1.TABLE_NAME = UPPER(pr_nmtabela)
         AND c1.CONSTRAINT_TYPE = 'R'
         AND c1.OWNER = UPPER(pr_nmowner);
         
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    --vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_dscritic_aux VARCHAR2(4000);
    vr_exc_erro EXCEPTION;  
    vr_exc_prox EXCEPTION;  
    vr_qtdregis INTEGER;
    vr_tempoini NUMBER;
    vr_qtdtempo NUMBER;
    vr_dsdwhere VARCHAR2(20000);
    vr_dsdjoin  VARCHAR2(3000) := NULL;
    vr_idcontrole INTEGER;
    
    
  BEGIN
       
    --> VERIFICAR/PROCESSAR TABELAS DEPENDENTES
    FOR rw_tbexpdep IN cr_tbexpdep(pr_idcontrole => pr_idcontrole) LOOP
    
      --> Armazenar para usar no log
      vr_idcontrole := rw_tbexpdep.iddepende;
        
      IF rw_tbexpdep.nmowner <> rw_tbexpdep.nmowner_pri THEN
        vr_dscritic_aux := 'Owner das tabelas pai/dependente diferentes.';
        RAISE vr_exc_erro;            
      END IF;
      
      --> Se for dependencia por FK
      IF rw_tbexpdep.tpcontrole = 1 THEN
        FOR rw_join IN cr_join (pr_nmtabela      => rw_tbexpdep.nmtabela,
                                pr_nmtabela_pri  => rw_tbexpdep.nmtabela_pri,
                                pr_nmowner       => rw_tbexpdep.nmowner ) LOOP
          
          IF vr_dsdjoin IS NOT NULL THEN
            vr_dsdjoin := vr_dsdjoin ||' and ';
          END IF;
          
          vr_dsdjoin := rw_join.tbname1||'.'||rw_join.tbcol1 ||' = '||
                        rw_join.tbname2||'.'||rw_join.tbcol2;
        
        END LOOP;
        
        vr_dsdwhere := ' EXISTS (SELECT 1 FROM '||rw_tbexpdep.nmowner_pri||'.'||rw_tbexpdep.nmtabela_pri ||
                       ' WHERE '|| vr_dsdjoin ||
                       ' AND '|| pr_dsdwhere  ||
                       ' )';
      
      -- Exclusao da tabela dependente por referencia do nome do campo
      ELSIF rw_tbexpdep.tpcontrole = 2 THEN

        vr_dsdwhere := ' '||rw_tbexpdep.nmtabela||'.'||rw_tbexpdep.nmcampo_refere||' < '||
                       'TO_DATE('''|| to_char(vr_dtdiaatu - pr_nrdias_retencao,'DD/MM/RRRR')||''',''DD/MM/RRRR'')';

      
      END IF;                               
                
      vr_tempoini := DBMS_UTILITY.get_time;
          
      --> Realizar expurgo dos dados
      pc_expurgo_tabela (pr_idcontrole       => rw_tbexpdep.iddepende,       --> Id de controle
                         pr_nmowner          => rw_tbexpdep.nmowner,         --> Nome do owner onde a tabela se encontra
                         pr_nmtabela         => rw_tbexpdep.nmtabela,        --> Nome da tabela a ser copiada                           
                         pr_dscampos         => rw_tbexpdep.nmcampo_refere,  --> Campos da chave, para opcao somente copia
                         pr_tpoperacao       => rw_tbexpdep.tpoperacao,      --> Tipo de operacao (1-somente copia/ 2- copia e exclui/ 3-somente exclui)
                         pr_dsdwhere         => vr_dsdwhere,                 --> clausula where                           
                         pr_tab_comand       => pr_tab_comand,               --> Retornar os comandos de deleção, a serem efetuados no final de todas as copias
                         pr_qtdregis         => vr_qtdregis,                 --> Retorna a quantidade de registros copiados/excluidos 
                         pr_dscritic         => vr_dscritic_aux);         
          
          
      vr_qtdtempo := (DBMS_UTILITY.get_time - vr_tempoini)/100;
          
      --> Gerar log da operacao
      pc_log_expurgo (pr_idcontrole  => rw_tbexpdep.iddepende,      --> Id de controle de expurgo
                      pr_qtdregis    => vr_qtdregis,                 --> Qtd de registros excluidos
                      pr_qtdtempo    => vr_qtdtempo,                 --> Tempo de processamento
                      pr_dslogexp    => vr_dscritic_aux,             --> Descrição de critica/log do expurgo     
                      pr_dscritic    => vr_dscritic);                --> Retorna critica
        
      IF TRIM(vr_dscritic)     IS NOT NULL OR
         TRIM(vr_dscritic_aux) IS NOT NULL THEN
         
        IF vr_dscritic IS NULL THEN
          vr_dscritic := vr_dscritic_aux;
        END IF; 
        
        RAISE vr_exc_prox;
      END IF;
      
      --> Verificar se possui dependentes e realizar expurgo
      pc_processar_expurgo_dep (pr_idcontrole       => rw_tbexpdep.iddepende,  --> Id de controle de expurgo principal/anterior 
                                pr_nrdias_retencao  => pr_nrdias_retencao,     --> Numero de dias de retenção de dados
                                pr_dsdwhere         => vr_dsdwhere,            --> Clausula where
                                pr_tab_comand       => pr_tab_comand,          --> Retornar os comandos de deleção, a serem efetuados no final de todas as copias
                                pr_dscritic         => pr_dscritic );
      
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro; 
      END IF; 
        
    END LOOP;
      
  
  EXCEPTION
    WHEN vr_exc_prox THEN
      pr_dscritic := vr_dscritic;      
      
    WHEN vr_exc_erro THEN
      
      pr_dscritic := vr_dscritic;  
      
      --> Gerar log da operacao
      pc_log_expurgo (pr_idcontrole  => vr_idcontrole,       --> Id de controle de expurgo
                      pr_qtdregis    => vr_qtdregis,         --> Qtd de registros excluidos
                      pr_qtdtempo    => vr_qtdtempo,         --> Tempo de processamento
                      pr_dslogexp    => pr_dscritic,         --> Descrição de critica/log do expurgo     
                      pr_dscritic    => vr_dscritic);        --> Retorna critica    
     
    WHEN OTHERS THEN
      
      pr_dscritic := 'Não foi possivel realizar expurgo dependentes: '||SQLERRM;
      
      --> Gerar log da operacao
      pc_log_expurgo (pr_idcontrole  => vr_idcontrole,       --> Id de controle de expurgo
                      pr_qtdregis    => vr_qtdregis,         --> Qtd de registros excluidos
                      pr_qtdtempo    => vr_qtdtempo,         --> Tempo de processamento
                      pr_dslogexp    => pr_dscritic,         --> Descrição de critica/log do expurgo     
                      pr_dscritic    => vr_dscritic);        --> Retorna critica
      
     
  END pc_processar_expurgo_dep; 
  
  
  --> Rotina para realizar o expurgo da tabela
  PROCEDURE pc_expurgo_tabela (pr_idcontrole       IN INTEGER,  --> Id de controle
                               pr_nmowner          IN VARCHAR2, --> Nome do owner onde a tabela se encontra
                               pr_nmtabela         IN VARCHAR2, --> Nome da tabela a ser copiada
                               pr_dscampos         IN VARCHAR2, --> Campos da chave, para opcao somente copia
                               pr_tpoperacao       IN INTEGER,  --> Tipo de operacao (1-somente copia/ 2- copia e exclui/ 3-somente exclui)
                               pr_dsdwhere         IN VARCHAR2, --> Clausula where
                               pr_tab_comand      IN OUT NOCOPY typ_tab_comand,  --> Retornar os comandos de deleção, a serem efetuados no final de todas as copias
                               pr_qtdregis        OUT INTEGER,  --> Retorna a quantidade de registros copiados/excluidos 
                               pr_dscritic        OUT VARCHAR2  --> Retorna critica
                               ) IS
  /* ..........................................................................
    
      Programa : pc_processar_expurgo        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Fevereiro/2017.                   Ultima atualizacao: 03/02/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel em incluir analise na fila  
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    --vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;   
    
    vr_dscmdsql VARCHAR2(30000);
    vr_dsdfrom  VARCHAR2(3000);
    vr_dsdwhere VARCHAR2(10000);
    vr_tab_campos cecred.gene0002.typ_split;
    
    
    vr_qtregcop INTEGER;
    --vr_qtregexc INTEGER;
    vr_idx      PLS_INTEGER;
    
    
    
    
    
  BEGIN
    
    vr_dsdwhere := ' WHERE '|| pr_dsdwhere;
  
    --> Montar clausulas
    vr_dsdfrom  := pr_nmowner ||'.'||pr_nmtabela;    
    
    
    --> TRUNCAR TABELA DESTINO para a opção 1- Somente copia
    IF pr_tpoperacao IN (1) THEN
    
      IF pr_dscampos IS NOT NULL THEN
        vr_tab_campos := gene0002.fn_quebra_string(pr_string  => pr_dscampos, 
                                                   pr_delimit => ';');
       
        
        IF vr_tab_campos.count > 0 THEN
        
          vr_dsdwhere := ' WHERE not exists (SELECT 1 FROM '|| 
                         pr_nmowner||'.'||pr_nmtabela||'@'||vr_dblink_hist||
                         ' hst WHERE ';
                          
        
          FOR i IN vr_tab_campos.first..vr_tab_campos.last LOOP
            IF i > 1 THEN            
              vr_dsdwhere := vr_dsdwhere || ' AND ';
            END IF;
            
            vr_dsdwhere := vr_dsdwhere || ' hst.'||vr_tab_campos(i)||
                          ' = '|| pr_nmowner||'.'||pr_nmtabela||'.' ||vr_tab_campos(i);          
          
          END LOOP;
          
          vr_dsdwhere := vr_dsdwhere  ||')';
        END IF;
      END IF;
    
    END IF;
    
    
    --> REALIZAR COPIA para as opçoes 1- Somente copia e 2-Copia e Exclui
    IF pr_tpoperacao IN (1,2) THEN
    
      --> Montar comando de copia
      vr_dscmdsql := ' INSERT INTO '  ||pr_nmowner||'.'||pr_nmtabela||'@'||vr_dblink_hist||
                     ' SELECT * FROM '||vr_dsdfrom || vr_dsdwhere;
      
      BEGIN
        EXECUTE IMMEDIATE vr_dscmdsql;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao efetuar copia: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      vr_qtregcop := SQL%ROWCOUNT;
      pr_qtdregis                    := vr_qtregcop;
    END IF;
    
    --> MONTAR COMANDO DE EXCLUSÃO as opçoes 2-Copia e Exclui e 3-Apenas Exclui
    IF pr_tpoperacao IN (2,3) THEN
    
      --> Montar comando de exclusao
      vr_dscmdsql := ' DELETE '||vr_dsdfrom || vr_dsdwhere;
      
      --> Armazenar comando de deleção
      vr_idx := pr_tab_comand.count;       
      pr_tab_comand(vr_idx).idcontrole := pr_idcontrole;
      pr_tab_comand(vr_idx).dscomand   := vr_dscmdsql;
      pr_tab_comand(vr_idx).nmtabela   := pr_nmtabela;
      pr_tab_comand(vr_idx).nmowner    := pr_nmowner;      
      pr_tab_comand(vr_idx).qtdregis   := vr_qtregcop;   
      
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel realizar expurgo: '||SQLERRM;
  END pc_expurgo_tabela; 
  
  --> Rotina para realizar processamento do expurgo outros
  PROCEDURE pc_processar_expurgo_outros (pr_dscritic  OUT VARCHAR2 )  IS
  /* ..........................................................................
    
      Programa : pc_processar_expurgo_outros        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Abril/2017.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para realizar processamento do expurgo outros
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar tabelas que possuem configuração
    CURSOR cr_tbhstctl (pr_dtdiaatu DATE )IS
      SELECT ctl.nmowner,
             ctl.nmtabela,
             ctl.nmcampo_refere,
             ctl.nrdias_refere,
             ctl.idcontrole,
             ctl.tpoperacao,
             ctl.rowid             
        FROM tbhst_controle ctl
       WHERE ctl.nmtabela IN ('CRAPSQU')
         --> Respeitar o inicio das execuções
         AND ctl.dtinicio <= TRUNC(pr_dtdiaatu)         
         --> Para intervalos diferentes de diario, rodarão apenas nos domingos                 
         AND ( (ctl.tpintervalo <> 1 AND to_char(pr_dtdiaatu,'D') = 1) OR
               ctl.tpintervalo = 1)       
         AND ( TRUNC(ctl.dhultima_operacao) <= 
               (TRUNC(pr_dtdiaatu - DECODE(ctl.tpintervalo,1, 1,  --> Diario
                                                           2, 7,  --> Semana
                                                           3,15,  --> Quinzenal
                                                           4,30,  --> Mensal 
                                                           5,365))--> Anual
                ) OR 
              ctl.dhultima_operacao IS NULL )         
         ORDER BY ctl.tpoperacao;
    
    
    --> Buscar configuracao da sequence que possua campo DTMVTOLT
    CURSOR cr_crapsqt IS 
      SELECT sqt.nmtabela
            ,sqt.nmdcampo
            ,sqt.dsdchave
        FROM crapsqt sqt
       WHERE UPPER(sqt.dsdchave) LIKE '%DTMVTOLT%';
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_dscritic     VARCHAR2(4000);
    vr_dscritic_aux VARCHAR2(4000);
    vr_exc_erro     EXCEPTION;   
    vr_exc_prox     EXCEPTION;   
    vr_qtdregis     INTEGER;
    vr_qtdregis_tot INTEGER;
    vr_qtregexc     INTEGER;
    vr_qtregexc_tot INTEGER;
    vr_tempoini     NUMBER;
    vr_qtdtempo     NUMBER;
    vr_dsdwhere     VARCHAR2(10000);
    vr_tab_comand   typ_tab_comand;
    vr_dsdchave     crapsqt.dsdchave%type;
    vr_nrposcmp     INTEGER;
    
    
  BEGIN
  
    --> buscar todas as tabelas pendentes para realizar o expurgo
    FOR rw_tbhstctl IN cr_tbhstctl(pr_dtdiaatu => vr_dtdiaatu ) LOOP
      BEGIN
        vr_tab_comand.delete;
        
        --> INICIAR PROCESSO TABELA PRINCIPAL        
        vr_tempoini := DBMS_UTILITY.get_time;
        
        IF rw_tbhstctl.nmtabela = 'CRAPSQU' THEN
          
          IF rw_tbhstctl.tpoperacao IN (1) THEN
            vr_dscritic_aux := 'Opcao somente copia não é permitido para esta tabela.';
            RAISE vr_exc_prox;
          END IF;
        
           --> Buscar configuracao da sequence que possua campo DTMVTOLT
          FOR rw_crapsqt  IN cr_crapsqt LOOP
          
            --> Identificar em qual posição esta o campo DTMVTOLT
            vr_dsdchave := rw_crapsqt.dsdchave;
            --> Manter texto somente até o campo interessado
            vr_dsdchave := substr(vr_dsdchave,1,INSTR(vr_dsdchave,'DTMVTOLT')-1);
            --> Contar a quantidade de ";" existentes, assim saberemos a posição do campo 
            vr_nrposcmp := REGEXP_COUNT(vr_dsdchave,';',1,'i') + 1;
            
            vr_dsdwhere := 'crapsqu.nmtabela = '''|| rw_crapsqt.nmtabela ||''' AND '||
                           'crapsqu.nmdcampo = '''|| rw_crapsqt.nmdcampo ||''' AND '||
                           'to_date(substr(crapsqu.dsdchave,instr(crapsqu.dsdchave,'';'',1,'||vr_nrposcmp||'-1) +1,10),''DD/MM/RRRR'')'||
                           --> Funcões nao podem ser utilizadas em dblink
                           --'to_date(gene0002.fn_busca_entrada('||vr_nrposcmp||',crapsqu.dsdchave,'';''),''DD/MM/RRRR'') '||
                           '<= '|| 'TO_DATE('''|| to_char(vr_dtdiaatu - rw_tbhstctl.nrdias_refere,'DD/MM/RRRR')||''',''DD/MM/RRRR'')'
                           ;

            
          
            --> Realizar expurgo dos dados
            pc_expurgo_tabela (pr_idcontrole       => rw_tbhstctl.idcontrole,      --> Id de controle
                               pr_nmowner          => rw_tbhstctl.nmowner,         --> Nome do owner onde a tabela se encontra
                               pr_nmtabela         => rw_tbhstctl.nmtabela,        --> Nome da tabela a ser copiada
                               pr_dscampos         => rw_tbhstctl.nmcampo_refere,  --> Campos da chave, para opcao somente copia
                               pr_tpoperacao       => rw_tbhstctl.tpoperacao,      --> Tipo de operacao (1-somente copia/ 2- copia e exclui/ 3-somente exclui)
                               pr_dsdwhere         => vr_dsdwhere,                        
                               pr_tab_comand       => vr_tab_comand,               --> Retornar os comandos de deleção, a serem efetuados no final de todas as copias
                               pr_qtdregis         => vr_qtdregis,                 --> Retorna a quantidade de registros copiados/excluidos 
                               pr_dscritic         => vr_dscritic_aux);                --> Retorna critica
              
             IF vr_dscritic_aux IS NOT NULL THEN 
               vr_dscritic_aux := ' nmtabela: '||rw_crapsqt.nmtabela ||
                                  ' nmdcampo: '||rw_crapsqt.nmdcampo || 
                                  ' -> '|| vr_dscritic_aux;
               --> Gerar log da operacao
               pc_log_expurgo (pr_idcontrole  => rw_tbhstctl.idcontrole,      --> Id de controle de expurgo
                               pr_tpoperacao  => 1,                           --> tipo de operacao realizada (1-copia/ 3-exclusao) 
                               pr_qtdregis    => 0,                           --> Qtd de registros excluidos
                               pr_qtdtempo    => vr_qtdtempo,                 --> Tempo de processamento
                               pr_dslogexp    => vr_dscritic_aux,             --> Descrição de critica/log do expurgo     
                               pr_dscritic    => vr_dscritic);                --> Retorna critica
              
               IF TRIM(vr_dscritic) IS NOT NULL THEN
                 RAISE vr_exc_erro;
               END IF; 
               
               vr_dscritic_aux := NULL;
               
             END IF;
             
             vr_qtdregis_tot := nvl(vr_qtdregis_tot,0) + nvl(vr_qtdregis,0);
          
          END LOOP;
          
          vr_qtdtempo := (DBMS_UTILITY.get_time - vr_tempoini)/100;
          
          --> Gerar log apenas se nao for operação de apenas exclui(pois esta o log será gerado em outro monento)
          IF rw_tbhstctl.tpoperacao <> 3 THEN
             
            --> Gerar log da operacao
            pc_log_expurgo (pr_idcontrole  => rw_tbhstctl.idcontrole,      --> Id de controle de expurgo
                            pr_tpoperacao  => 1,                           --> tipo de operacao realizada (1-copia/ 3-exclusao) 
                            pr_qtdregis    => vr_qtdregis_tot,                 --> Qtd de registros excluidos
                            pr_qtdtempo    => vr_qtdtempo,                 --> Tempo de processamento
                            pr_dslogexp    => vr_dscritic_aux,             --> Descrição de critica/log do expurgo     
                            pr_dscritic    => vr_dscritic);                --> Retorna critica
          
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;                   
            
          END IF;           
          
          --> Apenas realizar a deleção se nao for  1-apenas copia
          IF rw_tbhstctl.tpoperacao <> 1 THEN
          
            IF vr_tab_comand.count = 0 THEN
              vr_dscritic_aux := 'Comandos de Deleção não encontrados.';
              RAISE vr_exc_prox;          
            END IF;
          
            vr_tempoini := DBMS_UTILITY.get_time;
            
            --> BUSCAR COMANDOS DE DELEÇÃO
            FOR vr_idx IN vr_tab_comand.first..vr_tab_comand.last LOOP
              
              --> Executar comando de exclusao
              BEGIN
                EXECUTE IMMEDIATE vr_tab_comand(vr_idx).dscomand;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic_aux := 'Erro ao efetuar exclusao '||vr_tab_comand(vr_idx).nmtabela||
                                     ': '||SQLERRM;      
              END;              
              
              vr_qtregexc := SQL%ROWCOUNT;
              
              --> apenas validar qnt se nao ja apresentou erro
              IF vr_dscritic_aux IS NULL AND
                 --> Somente exclusao nao precisa validar qtd 
                 rw_tbhstctl.tpoperacao <> 3 THEN
                IF vr_qtregexc <> nvl(vr_tab_comand(vr_idx).qtdregis,0) THEN
                  vr_dscritic_aux := 'Quantidade de registro copiados e excluidos da tabela '||
                                     vr_tab_comand(vr_idx).nmtabela || ' não conferem';      
                END IF;
              END IF;
              
              IF vr_dscritic_aux IS NOT NULL THEN
                RAISE vr_exc_prox;
              END IF;
              
              vr_qtregexc_tot := nvl(vr_qtregexc_tot,0) + nvl(vr_qtregexc,0); 
              
            
            END LOOP;
            
            vr_qtdtempo := (DBMS_UTILITY.get_time - vr_tempoini)/100;          
            --> Gerar log da operacao
            pc_log_expurgo (pr_idcontrole  => rw_tbhstctl.idcontrole,   --> Id de controle de expurgo
                            pr_tpoperacao  => 3,                        --> tipo de operacao realizada (1-copia/ 3-exclusao) 
                            pr_qtdregis    => vr_qtregexc_tot,          --> Qtd de registros excluidos
                            pr_qtdtempo    => vr_qtdtempo,              --> Tempo de processamento
                            pr_dslogexp    => NULL,                     --> Descrição de critica/log do expurgo     
                            pr_dscritic    => vr_dscritic);             --> Retorna critica
            
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
              
            
            
          END IF;
          
        
        
        END IF;
        
        --> Atualizar controle com a data de execução
        BEGIN
          UPDATE tbhst_controle ctl
             SET ctl.dhultima_operacao = SYSDATE
           WHERE ctl.rowid = rw_tbhstctl.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic_aux := 'Nao foi possivel atualizar tbhst_controle: '||SQLERRM;
            RAISE vr_exc_prox;
        END;
        
        COMMIT;
      
      EXCEPTION
        WHEN vr_exc_prox THEN
          ROLLBACK;
          
          -- Gravar log apenas se possuir critica
          IF  vr_dscritic_aux IS NOT NULL THEN
            vr_dscritic_aux := 'Erro ao processar tabela '||rw_tbhstctl.nmtabela||': '||vr_dscritic_aux;
            --> Gerar log da operacao
            pc_log_expurgo (pr_idcontrole  => rw_tbhstctl.idcontrole,      --> Id de controle de expurgo
                            pr_qtdregis    => 0,                 --> Qtd de registros excluidos
                            pr_qtdtempo    => 0,                 --> Tempo de processamento
                            pr_dslogexp    => vr_dscritic_aux,             --> Descrição de critica/log do expurgo     
                            pr_dscritic    => vr_dscritic);                --> Retorna critica
          
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
          
        WHEN OTHERS THEN
          ROLLBACK;
          vr_dscritic_aux := 'Erro ao processar tabela '||rw_tbhstctl.nmtabela||': '||SQLERRM;
        
          --> Gerar log da operacao
          pc_log_expurgo (pr_idcontrole  => rw_tbhstctl.idcontrole,      --> Id de controle de expurgo
                          pr_qtdregis    => 0,                 --> Qtd de registros excluidos
                          pr_qtdtempo    => 0,                 --> Tempo de processamento
                          pr_dslogexp    => vr_dscritic_aux,             --> Descrição de critica/log do expurgo     
                          pr_dscritic    => vr_dscritic);                --> Retorna critica
        
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
      END;
    END LOOP;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_dscritic := vr_dscritic;
      
      RAISE_application_error(-20501,pr_dscritic);
    
    WHEN OTHERS THEN
      ROLLBACK;
      pr_dscritic := 'Não foi possivel realizar expurgo: '||SQLERRM;
      RAISE_application_error(-20501,pr_dscritic);
  END pc_processar_expurgo_outros; 
  
END EXPU0001;
/
