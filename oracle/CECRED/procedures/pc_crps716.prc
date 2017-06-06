CREATE OR REPLACE PROCEDURE CECRED.pc_crps716 (pr_cdcooper IN crapcop.cdcooper%TYPE ) IS   --> Cooperativa solicitada
  /* .............................................................................

     Programa: pc_crps716
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Março/2017                     Ultima atualizacao: 27/03/2017

     Dados referentes ao programa:

     Frequencia: Executado via Job
     Objetivo  : Realizar importação do arquivo de faturas atradas de cartão de credito.

     Alteracoes:

  ............................................................................ */

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- Código do programa
  vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS716';
  vr_cdcooper   NUMBER  := 3;

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_erro   EXCEPTION;  
  vr_exc_prox   EXCEPTION;  
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  ------------------------------- CURSORES ---------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.cdcooper
          ,cop.cdagebcb
      FROM crapcop cop
     WHERE cop.cdcooper = decode(pr_cdcooper,3,cop.cdcooper,pr_cdcooper)
       AND cop.cdcooper <> 3
       AND cop.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;


  -- buscar nome do programa
  CURSOR cr_crapprg IS
    SELECT lower(crapprg.dsprogra##1) dsprogra##1
      FROM crapprg
     WHERE cdcooper = vr_cdcooper
       AND cdprogra = vr_cdprogra;
  rw_crapprg cr_crapprg%ROWTYPE;
  
  --> Verificar se existe cartao cadastrado
  CURSOR cr_crapcrd (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_nrcartao NUMBER)  IS      
    SELECT nrdconta
      FROM tbcrd_conta_cartao crd
     WHERE crd.cdcooper = pr_cdcooper
       AND crd.nrconta_cartao = pr_nrcartao;
  rw_crapcrd cr_crapcrd%ROWTYPE;

  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE; 
  
  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  vr_tab_linhas   gene0009.typ_tab_linhas;
  vr_tab_arquivo  gene0002.typ_split;
  ------------------------------- VARIAVEIS -------------------------------
  
  -- Nome do diretorio da cooperativa
  vr_nmdireto     VARCHAR2(500);  
  vr_nmarqdat     VARCHAR2(500);
  vr_listdarq     VARCHAR2(500);
  vr_nmarqlog     VARCHAR2(500);

  vr_cdagebcb     crapcop.cdagebcb%TYPE;
  vr_vlsldfat     crapepr.vlemprst%TYPE;  
  vr_qtdiaatr     INTEGER;  
  vr_nrcartao     NUMBER;
  
  --------------------------- SUBROTINAS INTERNAS --------------------------

  vr_nomdojob    VARCHAR2(40) := 'JBCRD_ARQ_FAT_ATRASO';
  vr_flgerlog    BOOLEAN := FALSE;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    --> Controlar geração de log de execução dos jobs
    BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  END pc_controla_log_batch;
  
  --> Gerar log 
  PROCEDURE pc_gerar_log (pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
  
    --> se variavel ainda estiver nula
    IF vr_nmarqlog IS NULL THEN
      vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                               pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
    END IF; 
    
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                               pr_ind_tipo_log => 1, 
                               pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| pr_dscritic, 
                               pr_nmarqlog     => vr_nmarqlog );
  
  
  END pc_gerar_log;



BEGIN

  --------------- VALIDACOES INICIAIS -----------------
  
  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);

  -- Buscar nome do programa
  OPEN cr_crapprg;
  FETCH cr_crapprg INTO rw_crapprg;
  CLOSE cr_crapprg;


  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  FOR rw_crapcop IN cr_crapcop LOOP
    BEGIN
      vr_flgerlog   := FALSE;
      
      -- Log de fim da execução
      pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dstiplog => 'I');
     
    
      --> Limpar tabela de alerta
      BEGIN
        DELETE tbcrd_alerta_atraso alt
         WHERE alt.cdcooper = rw_crapcop.cdcooper;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel limpar tabela de alerta: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);

      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN

        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      
      -- Busca do diretório do arquivo
      vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'M', --> micros
                                           pr_cdcooper => rw_crapcop.cdcooper,
                                           pr_nmsubdir => '/cecred_cartoes');
     

      vr_nmarqdat := '756-2011-'|| rw_crapcop.cdagebcb ||'-RELTCABALCARTOESATRASO%'||
                     to_char(rw_crapdat.dtmvtolt,'DDMMRRRR')||'.TXT';
                     
      --> Listar arquivos localizados
      gene0001.pc_lista_arquivos(pr_path     => vr_nmdireto, 
                                 pr_pesq     => vr_nmarqdat, 
                                 pr_listarq  => vr_listdarq, 
                                 pr_des_erro => vr_dscritic);
  
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_listdarq IS NULL THEN
        vr_dscritic := 'Nenhum Arquivo '||vr_nmarqdat||' não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      
      --> Quebrar lista em tabela
      vr_tab_arquivo := gene0002.fn_quebra_string(pr_string => vr_listdarq, 
                                                  pr_delimit => ',');
      
      IF vr_tab_arquivo.count > 0 THEN
      
        --> Importar arquivos
        FOR i IN vr_tab_arquivo.first..vr_tab_arquivo.last LOOP
          BEGIN
          
            --> Importar o arquivo texto
            gene0009.pc_importa_arq_layout(pr_nmlayout   => 'CARTAO_ATRASO', 
                                           pr_dsdireto   => vr_nmdireto, 
                                           pr_nmarquiv   => vr_tab_arquivo(i), 
                                           pr_dscritic   => vr_dscritic, 
                                           pr_tab_linhas => vr_tab_linhas);
            
            
            IF vr_tab_linhas.count = 0 THEN
              vr_dscritic := 'Arquivo ' || vr_tab_arquivo(i) || '.csv não possui conteúdo!';    
              RAISE vr_exc_prox;
            END IF;            
            
            --> ler linhas do arquivo
            FOR vr_idx IN vr_tab_linhas.first..vr_tab_linhas.last LOOP
              BEGIN
                --> Ignorar cabecalho 
                --> e rodapé
                IF vr_idx <= 21 OR               
                   nvl(vr_tab_linhas(vr_idx)('CDEMISSOR').NUMERO,0) <> 756 THEN
                  continue;
                END IF;
                
                --Problemas com importacao do layout
                IF vr_tab_linhas(vr_idx).exists('$ERRO$') THEN 
                  vr_dscritic := 'Erro ao importar linha '|| vr_idx ||': '||
                                  vr_tab_linhas(vr_idx)('$ERRO$').texto;
                  RAISE vr_exc_prox;
                END IF;
                  
                vr_cdagebcb := vr_tab_linhas(vr_idx)('CDAGEBCB').NUMERO;              
                vr_nrcartao := vr_tab_linhas(vr_idx)('NRCARTAO').NUMERO;
                vr_vlsldfat := to_number(TRIM(vr_tab_linhas(vr_idx)('VLSLDFAT').TEXTO),
                                         'FM99999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''');
                vr_qtdiaatr := vr_tab_linhas(vr_idx)('QTDIAATRASO').NUMERO;
                
                
                --> Identificar numero da conta do cooperado
                OPEN cr_crapcrd(pr_cdcooper => rw_crapcop.cdcooper,
                                pr_nrcartao => vr_nrcartao);
                FETCH cr_crapcrd INTO rw_crapcrd;
                
                IF cr_crapcrd%NOTFOUND THEN
                  CLOSE cr_crapcrd;
                  vr_dscritic := 'Não foi possivel identificar conta para o cartão '||vr_nrcartao;
                  RAISE vr_exc_prox;
                END IF;
                
                CLOSE cr_crapcrd;
                                
                --> Gravar informações na tabela
                BEGIN
                  INSERT INTO tbcrd_alerta_atraso
                              (  cdcooper
                                ,nrdconta
                                ,nrconta_cartao
                                ,qtdias_atraso
                                ,vlsaldo_devedor)
                       VALUES (  rw_crapcop.cdcooper  --> cdcooper
                                ,rw_crapcrd.nrdconta  --> nrdconta
                                ,vr_nrcartao          --> nrconta_cartao
                                ,vr_qtdiaatr          --> qtdias_atraso
                                ,vr_vlsldfat);        --> vlsaldo_devedor
                                  
                EXCEPTION
                  WHEN OTHERS THEN 
                    vr_dscritic := 'Nao foi possivel inserir tbcrd_alerta_atraso: '||SQLERRM;
                    RAISE vr_exc_prox;
                END;
                
              EXCEPTION
                WHEN vr_exc_prox THEN
                  pc_gerar_log (pr_cdcooper => rw_crapcop.cdcooper,
                                pr_dscritic => vr_dscritic);
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao processar linha '||vr_idx||': '||SQLERRM;
                  pc_gerar_log (pr_cdcooper => rw_crapcop.cdcooper,
                                pr_dscritic => vr_dscritic);
              END;
            END LOOP; --> Fim loop linhas
            
          EXCEPTION
            WHEN vr_exc_prox THEN
              pc_gerar_log (pr_cdcooper => rw_crapcop.cdcooper,
                                pr_dscritic => vr_dscritic);
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao processar arquivo '||vr_tab_arquivo(i)||': '||SQLERRM;
              pc_gerar_log (pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dscritic => vr_dscritic);
          END;
          
        END LOOP; --> Fim loop arquivos
      
      END IF;  
            
      -- Log de fim da execução
      pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dstiplog =>'F');

      -- Salvar informações atualizadas
      COMMIT;
      
      
    EXCEPTION
    
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                              pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
      
        vr_dscritic := NULL;  
        
                          
      
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel importar arquivo de faturas em atraso: '||SQLERRM;
        pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                              pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
        vr_dscritic := NULL;    
       
    END;
  END LOOP;  

  ----------------- ENCERRAMENTO DO PROGRAMA -------------------

  

EXCEPTION
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;

    pc_controla_log_batch('E', vr_dscritic);
    
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    vr_dscritic := sqlerrm;

    -- Envio centralizado de log de erro
    vr_flgerlog := TRUE;
    pc_controla_log_batch('E', vr_dscritic);
    -- Efetuar rollback
    ROLLBACK;

END pc_crps716;
/
