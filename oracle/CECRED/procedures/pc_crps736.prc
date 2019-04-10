CREATE OR REPLACE PROCEDURE CECRED.pc_crps736(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                             ,pr_cdagenci  IN PLS_INTEGER DEFAULT 0     --> Agencia
                                             ,pr_idparale  IN PLS_INTEGER DEFAULT 0     --> Id da transacao de paralelismo
                                             ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps736
     Sistema : Crédito - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Lazari (GFT)
     Data    : Junho/2018                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Atualizar o saldo devedor de títulos vencidos descontados.

     Alteracoes: 
               07/08/2018 - Alterado para paralelismo - Luis Fernando (GFT)

               27/08/2018 - Adicionado leitura da crapljt para inserir registros no lançamento de borderô com o 
                            histórico ctb 2667 (Apropriação Juros Remuneratórios), assim pode ser consultado os 
                            valores na tela LISLOT (Paulo Penteado GFT)

               25/09/2018 - Alterado o valor do lançamento da apropriação dos juros de mora (histor 2668). Anteriormente 
                            lançava o valor acumulado dos juros de mora calculado no título, agora irá lançar somente o
                            valor do juros apropriado no mês (Paulo Penteado GFT)

               25/10/2018 - Inserção do valor de lançamento de juros de atualização (histor 2798). (Vitor S Assanuma - GFT)                            
  			   
			   29/11/2018 - Correção na apropriação de juros de mora mensal (Lucas Lazari - GFT)
	
               31/03/2019 - Reestruturado o programa para gravação de logs e melhor controle. (Daniel - AILOS)
	
  ............................................................................ */
  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS736';
    
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);

    vr_vlmtatit NUMBER;
    vr_vlmratit NUMBER;
    vr_vlioftit NUMBER;
    
    -- Paralelismo 
    vr_jobname        VARCHAR2(500);
    vr_dsplsql        VARCHAR2(3000);
    vr_qtdjobs        NUMBER;
    vr_qterro         NUMBER;
    vr_idparale       NUMBER;
    vr_idlog_ini_ger  NUMBER;
    vr_idlog_ini_par  NUMBER;
    vr_tpexecucao     tbgen_prglog.tpexecucao%TYPE; 
    
    --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
    vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;
    
    ------------------------------- CURSORES ---------------------------------
    -- Cursor generico de calendario
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Código da cooperativa
    SELECT cop.nmrescop,
           cop.nrtelura
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
 
    -- Cursor para trazer as agencias para o paralelismo
    CURSOR cr_crapage(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_cdagenci IN crapass.cdagenci%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                     ,pr_cdprogra IN tbgen_batch_controle.cdprogra%TYPE
                     ,pr_qterro   IN NUMBER) IS  
      SELECT age.cdagenci
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = decode(pr_cdagenci, 0, age.cdagenci, pr_cdagenci)
         AND (pr_qterro = 0 OR
             (pr_qterro > 0 AND EXISTS
              (SELECT 1
                  FROM tbgen_batch_controle
                 WHERE tbgen_batch_controle.cdcooper = pr_cdcooper
                   AND tbgen_batch_controle.cdprogra = pr_cdprogra
                   AND tbgen_batch_controle.tpagrupador = 1
                   AND tbgen_batch_controle.cdagrupador = age.cdagenci
                   AND tbgen_batch_controle.insituacao = 1
                   AND tbgen_batch_controle.dtmvtolt = pr_dtmvtolt)))
       ORDER BY age.cdagenci ASC;
    
    --  Busca todos os títulos liberados que estão vencidos
    CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT craptdb.ROWID,
             craptdb.nrdconta,
             craptdb.dtvencto,
             craptdb.nrborder,
             craptdb.cdbandoc,
             craptdb.nrcnvcob,
             craptdb.nrdctabb,
             craptdb.nrdocmto,
             craptdb.vlmratit,
             craptdb.vlpagmra,
             craptdb.nrtitulo
        FROM craptdb,
             crapbdt
       WHERE craptdb.cdcooper =  crapbdt.cdcooper
         AND craptdb.nrdconta =  crapbdt.nrdconta
         AND craptdb.nrborder =  crapbdt.nrborder
         AND craptdb.cdcooper =  pr_cdcooper
         AND craptdb.dtvencto <= pr_dtmvtolt
         AND craptdb.insittit =  4  -- liberado
         AND crapbdt.cdagenci = decode(pr_cdagenci,0,crapbdt.cdagenci,pr_cdagenci)
         AND crapbdt.inprejuz = 0 -- somente borderôs que não estão em prejuízo
         AND crapbdt.flverbor =  1; -- bordero liberado na nova versão
    
    CURSOR cr_crapljt(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT ljt.nrdconta,
           ljt.nrborder,
           SUM(ljt.vldjuros) vldjuros
      FROM crapass ass,
           crapbdt bdt,
           crapljt ljt
     WHERE ass.cdagenci = decode(pr_cdagenci, 0, ass.cdagenci, pr_cdagenci)
       AND ass.cdcooper = ljt.cdcooper
       AND ass.nrdconta = ljt.nrdconta
       AND bdt.flverbor = 1
       AND bdt.inprejuz = 0 -- somente borderôs que não estão em prejuízo
       AND bdt.nrborder = ljt.nrborder
       AND bdt.cdcooper = ljt.cdcooper
       AND ljt.cdcooper = pr_cdcooper
       AND ljt.dtrefere = pr_dtmvtolt
     GROUP BY ljt.nrdconta,
              ljt.nrborder;
    
    CURSOR cr_lancboraprop(pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                          ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                          ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                          ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                          ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico do lancamento
                          ,pr_cdbandoc IN craptdb.cdbandoc%TYPE --> Codigo do banco impresso no boleto
                          ,pr_nrdctabb IN craptdb.nrdctabb%TYPE --> Numero da conta base do titulo
                          ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE --> Numero do convenio de cobranca
                          ,pr_nrdocmto IN craptdb.nrdocmto%TYPE --> Numero do documento
                          ) IS
    SELECT SUM(lcb.vllanmto) vllanmto
      FROM tbdsct_lancamento_bordero lcb
     WHERE lcb.cdcooper = pr_cdcooper
       AND lcb.nrdconta = pr_nrdconta
       AND lcb.nrborder = pr_nrborder
       AND lcb.cdbandoc = pr_cdbandoc
       AND lcb.nrdctabb = pr_nrdctabb
       AND lcb.nrcnvcob = pr_nrcnvcob
       AND lcb.nrdocmto = pr_nrdocmto
       AND lcb.cdhistor = pr_cdhistor
       AND lcb.dtmvtolt <= pr_dtmvtolt;
    rw_lancboraprop cr_lancboraprop%ROWTYPE;

  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);

    --Apenas valida a cooperativa quando for o programa principal, paralelos não tem necessidade.
    IF pr_idparale = 0 THEN
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar registros montar mensagem de critica
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        --Buscar mensagem de erro
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapcop;
      END IF;
    END IF;
    
    -- Validações iniciais do programa
    btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => vr_cdcritic);

    -- Caso retorno crítica busca a descrição
    IF vr_cdcritic <> 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
      -- Buscar quantidade parametrizada de Jobs
      vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper --> Código da coopertiva
                                                 ,vr_cdprogra); --> Código do programa
  
    -- Paralelismo visando performance
    IF vr_qtdjobs           > 0 AND 
	   rw_crapdat.inproces  > 2 AND
       pr_cdagenci          = 0 THEN
      
      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_id_paralelo;
      
      -- Se houver algum erro, o id vira zerado
      IF vr_idparale = 0 THEN
         -- Levantar exceção
         vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_id_paralelo.';
         RAISE vr_exc_erro;
      END IF;
      
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I',    
                      pr_cdprograma => vr_cdprogra,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger);
                      
      -- Verifica se algum job paralelo executou com erro
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                    pr_cdprogra    => vr_cdprogra,
                                                    pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                    pr_tpagrupador => 1,
                                                    pr_nrexecucao  => 1);
      
      
      -- Retorna todas as Agências para criação dos Jobs.
      FOR rw_crapage in cr_crapage (pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_qterro   => vr_qterro
                                    ) LOOP
                                    
        -- Montar o prefixo do código do programa para o jobname
        vr_jobname := vr_cdprogra ||'_'|| rw_crapage.cdagenci || '$'; 
          
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => LPAD(rw_crapage.cdagenci,3,'0') --> Utiliza a agência como id programa
                                  ,pr_des_erro => vr_dscritic);
                                    
        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_erro;
        END IF;                            
                                    
        -- Montar o bloco PLSQL que será executado
        -- Ou seja, executaremos a geração dos dados
        -- para a agência atual atraves de Job no banco
        vr_dsplsql := 'DECLARE'            ||chr(13)||
                      ' wpr_stprogra  binary_integer; '||chr(13)||
                      ' wpr_infimsol  binary_integer; '||chr(13)||
                      ' wpr_cdcritic  number(5); '     ||chr(13)||
                      ' wpr_dscritic  varchar2(4000); '||chr(13)||
                      ' BEGIN '||chr(13)||
                      '   cecred.pc_crps736('||pr_cdcooper||','||chr(13)||
                                               rw_crapage.cdagenci||','||chr(13)||
                                               vr_idparale||','||chr(13)||
                                               'wpr_stprogra,' ||chr(13)||
                                               'wpr_infimsol,' ||chr(13)||
                                               'wpr_cdcritic,' ||chr(13)||
                                               'wpr_dscritic'  ||chr(13)||
                                               ');'||chr(13)||
                      'END;';
                      
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                                ,pr_cdprogra => vr_cdprogra  --> Código do programa
                                ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname  => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro => vr_dscritic);    

          -- Testar saida com erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Chama rotina que irá pausar este processo controlador
          -- caso tenhamos excedido a quantidade de JOBS em execuçao
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => vr_qtdjobs
                                      ,pr_des_erro => vr_dscritic);
                                      
          -- Testar saida com erro
          IF vr_dscritic IS NOT NULL THEN 
            -- Levantar exceçao
            RAISE vr_exc_erro;
          END IF;                            
          

      END LOOP;
      
      -- Chama rotina de aguardo agora passando 0, para esperarmos
      --até que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => 0
                                  ,pr_des_erro => vr_dscritic);
                                  
      -- Testar saida com erro
      IF vr_dscritic IS NOT NULL THEN 
        -- Levantar exceçao
        RAISE vr_exc_erro;
      END IF;
      
      --Realiza commit para manter dados mesmo que algum job Falhe
      COMMIT;
      
      -- Verifica se algum job paralelo executou com erro
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                    pr_cdprogra    => vr_cdprogra,
                                                    pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                    pr_tpagrupador => 1,
                                                    pr_nrexecucao  => 1);
      IF vr_qterro > 0 THEN 
        vr_cdcritic := 0;
        vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
        RAISE vr_exc_erro;
      END IF;
      

    ELSE
      
      --Classifica o tipo de execução de acordo com a informação no campo agência.    
      IF pr_cdagenci <> 0 THEN
        vr_tpexecucao := 2;
      ELSE
        vr_tpexecucao := 1;
      END IF;
      
      -- Grava controle de batch por agência
      gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                      ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt       -- Data de Movimento
                                      ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                      ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                      ,pr_cdrestart   => NULL                      -- Controle do registro de restart em caso de erro na execucao
                                      ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                      ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                      ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                      ,pr_dscritic    => vr_dscritic              
                                       );   
      -- Testar saida com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Levantar exceçao
        RAISE vr_exc_erro;
      END IF;                                         
    
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I',    
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => vr_tpexecucao,     -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par); 
                      
                      
      -- Grava LOG de ocorrência
      pc_log_programa(pr_dstiplog           => 'O',
                      pr_cdprograma         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Início - cursor cr_craptdb. AGENCIA: '||pr_cdagenci,
                      pr_idprglog           => vr_idlog_ini_par); 
      
      -- Loop principal dos títulos vencidos
      FOR rw_craptdb IN cr_craptdb(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
        
        -- Caso o titulo venca num feriado ou fim de semana, pula pois sera pego no proximo dia util 
        IF rw_craptdb.dtvencto > rw_crapdat.dtmvtoan AND rw_craptdb.dtvencto < rw_crapdat.dtmvtolt THEN
          CONTINUE;
        END IF;
        
        
        OPEN cr_lancboraprop(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_craptdb.nrdconta
                            ,pr_nrborder => rw_craptdb.nrborder
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmra
                            ,pr_cdbandoc => rw_craptdb.cdbandoc
                            ,pr_nrdctabb => rw_craptdb.nrdctabb
                            ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                            ,pr_nrdocmto => rw_craptdb.nrdocmto
                            );
        FETCH cr_lancboraprop INTO rw_lancboraprop;
        CLOSE cr_lancboraprop;
        
        -- calcula o juros da mensal
        DSCT0003.pc_calcula_atraso_tit(pr_cdcooper => pr_cdcooper    
                                      ,pr_nrdconta => rw_craptdb.nrdconta    
                                      ,pr_nrborder => rw_craptdb.nrborder    
                                      ,pr_cdbandoc => rw_craptdb.cdbandoc    
                                      ,pr_nrdctabb => rw_craptdb.nrdctabb    
                                      ,pr_nrcnvcob => rw_craptdb.nrcnvcob    
                                      ,pr_nrdocmto => rw_craptdb.nrdocmto    
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt    
                                      ,pr_vlmtatit => vr_vlmtatit    
                                      ,pr_vlmratit => vr_vlmratit    
                                      ,pr_vlioftit => vr_vlioftit    
                                      ,pr_cdcritic => vr_cdcritic    
                                      ,pr_dscritic => vr_dscritic);
        
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        IF (vr_vlmratit - nvl(rw_lancboraprop.vllanmto,0)) > 0 THEN
        
        -- Lança os juros de mora mensal na operação de desconto de titulos
        DSCT0003.pc_inserir_lancamento_bordero( pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => rw_craptdb.nrdconta
                                               ,pr_nrborder => rw_craptdb.nrborder
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                               ,pr_cdorigem => 7 -- batch
                                               ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmra
                                               --,pr_vllanmto => (rw_craptdb.vlmratit - nvl(rw_lancboraprop.vllanmto,0))
                                               ,pr_vllanmto => (vr_vlmratit - nvl(rw_lancboraprop.vllanmto,0))
                                               ,pr_cdbandoc => rw_craptdb.cdbandoc
                                               ,pr_nrdctabb => rw_craptdb.nrdctabb
                                               ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                               ,pr_nrdocmto => rw_craptdb.nrdocmto
                                               ,pr_nrtitulo => rw_craptdb.nrtitulo
                                               ,pr_dscritic => vr_dscritic );
        
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        END IF;
          
      END LOOP;
      
      -- Grava LOG de ocorrência
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Fim - cursor cr_craptdb. AGENCIA: '||pr_cdagenci,
                      PR_IDPRGLOG           => vr_idlog_ini_par); 

      -- Grava LOG de ocorrência
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Início - cursor cr_crapljt. AGENCIA: '||pr_cdagenci,
                      PR_IDPRGLOG           => vr_idlog_ini_par); 
    
      -- Buscar e registrar Apropriação Juros Remuneratórios
      FOR rw_crapljt IN cr_crapljt(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => last_day(rw_crapdat.dtmvtolt)) LOOP
                                   
        IF rw_crapljt.vldjuros > 0 THEN                            
                        
        DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => rw_crapljt.nrdconta
                                              ,pr_nrborder => rw_crapljt.nrborder
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_cdorigem => 7 -- batch
                                              ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurrem
                                              ,pr_vllanmto => rw_crapljt.vldjuros
                                              ,pr_dscritic => vr_dscritic );
      
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        END IF;
      END LOOP;
      
      -- Grava LOG de ocorrência
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Fim - cursor cr_crapljt. AGENCIA: '||pr_cdagenci,
                      PR_IDPRGLOG           => vr_idlog_ini_par); 

      -- Grava LOG de ocorrência
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Início - procedure pc_lanc_jratu_mensal. AGENCIA: '||pr_cdagenci,
                      PR_IDPRGLOG           => vr_idlog_ini_par); 

      -- Grava LOG de ocorrência
      DSCT0003.pc_lanc_jratu_mensal(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Grava LOG de ocorrência
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Fim - procedure pc_lanc_jratu_mensal. AGENCIA: '||pr_cdagenci,
                      PR_IDPRGLOG           => vr_idlog_ini_par); 
                      
                      
      --Grava data fim para o JOB na tabela de LOG 
      pc_log_programa(pr_dstiplog   => 'F',    
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par,
                      pr_flgsucesso => 1);  
                                    
    END IF;
    
    --Se for o programa principal - executado no batch
    IF pr_idparale = 0 THEN
      
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      IF vr_idcontrole <> 0 THEN
        
        -- Atualiza finalização do batch na tabela de controle 
        gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                           ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                           ,pr_dscritic   => vr_dscritic);
                                           
        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN 
          -- Levantar exceçao
          RAISE vr_exc_erro;
        END IF; 
                                                        
      END IF;    
      
      IF vr_qtdjobs > 0 THEN 
        --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_ger,
                        pr_flgsucesso => 1);                 
      END IF;

      -- Salvar informacoes
      COMMIT;

    --Se for job chamado pelo programa do batch     
    ELSE
      
      -- Atualiza finalização do batch na tabela de controle 
      gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                         ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                         ,pr_dscritic   => vr_dscritic);  

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);  

      -- Salvar informacoes
      COMMIT;

    END IF;

  EXCEPTION

    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      IF pr_idparale <> 0 THEN 
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(pr_dstiplog           => 'E',
                        pr_cdprograma         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||pr_dscritic,
                        pr_idprglog           => vr_idlog_ini_par);  

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);  
                        
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
      END IF;    
      
      -- Efetuar rollback
      ROLLBACK;

    WHEN OTHERS THEN
      
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;

      IF pr_idparale <> 0 THEN 
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(pr_dstiplog           => 'E',
                        pr_cdprograma         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||pr_dscritic,
                        pr_idprglog           => vr_idlog_ini_par);   

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);  
      
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
      END IF;  
        

      -- Efetuar rollback
      ROLLBACK;

  END;

END pc_crps736;
/
