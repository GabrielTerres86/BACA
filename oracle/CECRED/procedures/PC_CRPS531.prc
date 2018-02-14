CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS531(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                             ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                             ,pr_dscritic OUT varchar2) IS
  BEGIN

  /* ..........................................................................
     Programa: pc_crps531                         Antigo: Fontes/crps531.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Diego
     Data    : Setembro/2009.                     Ultima atualizacao: 01/08/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado.
     Objetivo  : Integrar mensagens(TED/TEC) recebidas via SPB.

     Observacoes: O script /usr/local/cecred/bin/mqcecred_recebe.pl baixa as
                  mensagens da fila de mensageria do MQ para o diretorio
                  /usr/coop/cecred/integra. Em seguida eh executado o script
                  /usr/local/cecred/bin/mqcecred_processa.pl que faz chamada do
                  CRPS531 para processar as mensagens. O programa identifica e
                  processa(em paralelo) cada mensagem na sua cooperativa de
                  destino.
                  Este procedimento esta configurado na CRON para rodar a cada
                  5 minutos.

     Alteracoes: 20/05/2010 - Criticar Numero de Conta Credito maior que 9
                              digitos;
                            - Efetuadas correcoes no LOG (Diego).

                 02/06/2010 - Desconsiderar zeros a esquerda na validacao do
                              numero da conta Credito (Diego).

                 14/06/2010 - Receber novas mensagens: STR0005R2, STR0007R2
                              PAG0106R2, PAG0107R2;
                            - Logar "Mensagem nao prevista" somente na CECRED;
                            - Gerar mensagem de devolucao(STR0010/PAG0111)
                              partindo da CECRED, quando codigo da agencia for
                              inexistente;
                            - Tratar mensagens Rejeitadas pela Cabine (Diego).

                 04/08/2010 - Buscar descricao dos motivos de devolucao da
                              craptab.cdacesso = "CDERROSSPB" (Diego).

                 27/08/2010 - Buscar motivos de devolução na TAB046
                            - Acerto no format do campo "Conta Dest" ref. log de
                              mensagens RECEBIDA OK (Diego).

                 01/12/2010 - Permitir o recebimento das mensagens: STR0018 e
                              STR0019
                            - Mostrar no LOG de rejeitadas o codigo da mensagem
                              original (Diego).

                 15/02/2011 - Modificacoes no layout do STR0018, STR0019 e
                              PAG0101 (Gabriel).

                 29/07/2011 - Validar ambas as contas quando for conta
                              conjunta. Especificar na TAG 'Hist' a descricao
                              da critica quando codigo do erro igual a 2
                              (Gabriel).

                 02/12/2011 - Rodar programa em paralelo;
                            - Processar todas as mensagens disponibilizadas em
                              um diretorio unico  (Gabriel)

                 20/05/2014 - Transferido criacao do registro de lote do 531_1
                              para ca. Cria o registro de lote para todas as
                              cooperativas e no 531_1 apenas le o registro e
                              atualiza (Problemas com chave duplicada no Oracle;
                              em virtude do 531_1 rodar em paralelo).
                              (Chamado 158826) - (Fabricio)

                 04/07/2017 - Adicionar o ID paralelo na mensagem de log
                              (Douglas - Chamado 524133)

                 01/08/2017 - Conversão Progress >> Oracle PLSQL (Andrei-MOUTs)
    
                 14/02/2018 - Alteração pc_lista_arquivos em java (Alexandre Borgmann-Mouts)

     ............................................................................ */
    DECLARE

      -- Constantes do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'crps531';
      vr_cdagenci CONSTANT PLS_INTEGER := 1;
      vr_nrdolote CONSTANT PLS_INTEGER := 10115;
      vr_tplotmov CONSTANT PLS_INTEGER := 1;

      -- Tratamento de erros
      vr_exc_saida  exception;

      -- Erro em chamadas da pc_gera_erro
      vr_dscritic VARCHAR2(4000);

      /* Busca dos dados da cooperativa */
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelura
              ,cop.dsdircop
              ,cop.cdbcoctl
              ,cop.cdagectl
          FROM crapcop cop
         WHERE cop.cdcooper = NVL(pr_cdcooper,cop.cdcooper);
      rw_crapcop cr_crapcop%ROWTYPE;

      /* Cursor genérico de calendário */
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      rw_crabdat btch0001.cr_crapdat%ROWTYPE;

      -- Checagem de lotes para gravação
      CURSOR cr_craplot(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt craplot.dtmvtolt%TYPE
                       ,pr_cdbccxlt crapcop.cdbcoctl%TYPE) IS
        SELECT 1
          FROM craplot
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = vr_cdagenci
           AND cdbccxlt = pr_cdbccxlt
           AND nrdolote = vr_nrdolote
           AND tplotmov = vr_tplotmov;
      vr_flexilot NUMBER;

      -- Variaveis para tratamento dos arquivos
      vr_dsdircop VARCHAR2(1000);
      vr_dtarqlog VARCHAR2(100);

      --Tabela para receber arquivos lidos no unix
      vr_tab_crawarq TYP_SIMPLESTRINGARRAY:= TYP_SIMPLESTRINGARRAY();
      vr_qtarqdir   INTEGER;   

      -- ID para o paralelismo
      vr_idparale INTEGER;

      -- Qtde parametrizada de Jobs
      vr_qtdjobs NUMBER;

      -- Bloco PLSQL para chamar a execução paralela do pc_crps414
      vr_dsplsql VARCHAR2(4000);
      -- Job name dos processos criados
      vr_jobname VARCHAR2(30);

    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL );

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Busca do diretório base da cooperativa
      vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper);


      gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_crawarq
                                ,pr_path          => vr_dsdircop || '/log'
                                ,pr_pesq          => 'crps531_%.log');
                              
      --Quantidade de arquivos encontrados
      vr_qtarqdir:= vr_tab_crawarq.COUNT();  

      -- Para cada arquivo de log encontrado
      IF vr_qtarqdir > 0 THEN
        FOR idx IN 1..vr_qtarqdir LOOP
          BEGIN
            vr_dtarqlog := TO_DATE(SUBSTR(vr_tab_crawarq(idx),9,8),'ddmmrrrr');
            -- Se o arquivo é de uma data anterior ao dia atual
            IF vr_dtarqlog < rw_crapdat.dtmvtolt THEN
              -- Mover arquivo de log do dia anterior para o /salvar
              gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsdircop||'/log/'||vr_tab_crawarq(idx) ||' '||vr_dsdircop||'/salvar');
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              -- Ignorar problema com conversão de data
              NULL;
          END;
        END LOOP;
      END IF;

      -- As mensagens estarao no diretorio /usr/coop/cecred/integra e o script ira executar com a variavel de ambiente CECRED
      gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_crawarq
                                ,pr_path          => vr_dsdircop || '/integra'
                                ,pr_pesq          => 'msgr_cecred_%.xml');
                              
      --Quantidade de arquivos encontrados
      vr_qtarqdir:= vr_tab_crawarq.COUNT();  

      -- se encontrar arquivos
      IF vr_qtarqdir <= 0 THEN
         RAISE vr_exc_saida;          
      END IF;          

      -- Criaremos registro de LOTE para todas as singulares
      FOR rw_crabcop IN cr_crapcop(NULL) LOOP
        -- Buscar o calendário desta
        -- Leitura do calendário da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crabcop.cdcooper);
        FETCH btch0001.cr_crapdat
         INTO rw_crabdat;
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois efetuaremos raise
          CLOSE btch0001.cr_crapdat;
          -- Montar mensagem de critica
          pr_cdcritic := 1;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor
          CLOSE btch0001.cr_crapdat;
        END IF;
        -- Verifica se o LOTE já foi criado para a Coperativa em questão
        OPEN cr_craplot(pr_cdcooper => rw_crabcop.cdcooper
                       ,pr_dtmvtolt => rw_crabdat.dtmvtolt
                       ,pr_cdbccxlt => rw_crabcop.cdbcoctl);
        FETCH cr_craplot
         INTO vr_flexilot;
        -- Se não encontrar
        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
          -- Inserir o registro de lote para utilização posterior
          BEGIN
            INSERT INTO craplot (cdcooper
                                ,dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov)
                          VALUES(rw_crabcop.cdcooper  -- cdcooper
                                ,rw_crabdat.dtmvtolt  -- dtmvtolt
                                ,vr_cdagenci          -- cdagenci
                                ,rw_crabcop.cdbcoctl  -- cdbccxlt
                                ,vr_nrdolote          -- nrdolote
                                ,vr_tplotmov);        -- tplotmov

          EXCEPTION
            WHEN dup_val_on_index THEN
              -- Lote já existe, critica 59
              vr_dscritic := gene0001.fn_busca_critica(59) || ' - LOTE = ' || to_char(vr_nrdolote,'fm000g000');
              RAISE vr_exc_saida;
            WHEN others THEN
              -- Erro não tratado
              vr_dscritic := ' na insercao do lote '||vr_nrdolote|| ' --> ' || sqlerrm;
              RAISE vr_exc_saida;
          END;
        ELSE
          CLOSE cr_craplot;
        END IF;
      END LOOP;

      -- Temos de Commitar neste ponto para garantir os LOTES
      COMMIT;

      -- Se houve encontro de arquivo
      IF vr_qtarqdir > 0 THEN

        -- Gerar o ID para o paralelismo
        vr_idparale := gene0001.fn_gera_ID_paralelo;

        -- Se houver algum erro, o id vira zerado
        IF vr_idparale = 0 THEN
          -- Levantar exceção
          pr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
          RAISE vr_exc_saida;
        END IF;

        -- Buscar quantidade parametrizada de Jobs
        vr_qtdjobs := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_PARALE_CRPS531'),10);

        -- Para cada mensagem (arquivo) recebido
        FOR idx IN 1..vr_qtarqdir LOOP

          -- Cadastra o programa paralelo
          gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                    ,pr_idprogra => LPAD(idx,6,'0') --> Utiliza idx do arquivo
                                    ,pr_des_erro => pr_dscritic);
          -- Testar saida com erro
          IF pr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_saida;
          END IF;
          -- Montar o bloco PLSQL que será executado
          -- Ou seja, executaremos a geração dos dados
          -- para a agência atual atraves de Job no banco
          vr_dsplsql := 'DECLARE'||chr(13)
                     || '  vr_cdcritic NUMBER;'||chr(13)
                     || '  vr_dscritic VARCHAR2(4000);'||chr(13)
                     || 'BEGIN'||chr(13)
                     || '  pc_crps531_1('||pr_cdcooper||','||vr_idparale||','||idx||','''||vr_dsdircop || '/integra/' || vr_tab_crawarq(idx)||''',vr_cdcritic,vr_dscritic);'||chr(13)
                     || 'END;';
          -- Montar o prefixo do código do programa para o jobname
          vr_jobname := 'jb_crps531_'||idx||'$';
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper  --> Código da cooperativa
                                ,pr_cdprogra  => vr_cdprogra  --> Código do programa
                                ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva   => NULL          --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname   => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro  => pr_dscritic);
          -- Testar saida com erro
          IF pr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_saida;
          END IF;
          -- Gerar LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- Processo normal
                                    ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                     || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> '
                                                     || 'Inicio da Execucao Paralela - PID: '
                                                     || ' - ' || vr_idparale|| ' Seq.: ' || to_char(idx,'fm99990')
                                                     || ' Mensagem: ' || vr_dsdircop || '/integra/' || vr_tab_crawarq(idx)
                                    ,pr_nmarqlog     => 'crps531_' || to_char(rw_crapdat.dtmvtolt,'ddmmrrrr'));
          -- Chama rotina que irá pausar este processo controlador
          -- caso tenhamos excedido a quantidade de JOBS em execuçao
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                      ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                      ,pr_des_erro => pr_dscritic);
          -- Testar saida com erro
          IF pr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_saida;
          END IF;
        END LOOP;

        -- Chama rotina de aguardo agora passando 0, para esperarmos
        -- até que todos os Jobs tenha finalizado seu processamento
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => 0
                                    ,pr_des_erro => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_saida;
        END IF;

      END IF;

      -- Efetuar commit
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END PC_CRPS531;
/
