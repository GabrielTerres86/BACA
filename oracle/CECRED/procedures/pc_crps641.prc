CREATE OR REPLACE PROCEDURE CECRED.pc_crps641 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código da cooperativa
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Descrição da crítica
  BEGIN
    /* ..........................................................................

     Programa: Fontes/crps641.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CECRED
     Autor   : Adriano
   Data    : Marco/2013                     Ultima atualizacao: 21/03/2018

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Atualiza o risco da crapgrp com risco do ultimo dia do mes
                 na crapris.

     Alteracoes: 18/04/2013 - Colocado no-undo na declaracao das temp-tables
                              tt-erro, tt-grupo-economico (Adriano).

                 22/10/2013 - Conversão Progress >> Oracle PLSQL (Edison-AMcom).

                 04/03/2014 - Validação e ajustes para execução (Petter-Supero).

               14/12/2017 - Padronização mensagens
                          - Tratamento erros others - cecred.pc_internal_exception
                          - Inclusão mensagens controle início e fim de execução
                           (Ana - Envolti - Chamado 813391)
                           
               21/03/2018 - Substituição da rotina pc_gera_log_batch pela pc_log_programa
                            para os códigos 1066 e 1067
                           (Ana - Envolti - Chamado INC0011087)
  ............................................................................. */

    DECLARE
      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Variáveis para execução
      vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS641'; --> Nome do programa
      vr_exc_saida    EXCEPTION;                                   --> Controle de saída para erros tratados
      vr_exc_fimprg   EXCEPTION;                                   --> Controle para fim de execução
      vr_cdcritic     crapcri.cdcritic%TYPE;                       --> Código da crítica
      vr_dscritic     VARCHAR2(4000);                              --> Descrição da crítica
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;                 --> Cursor para datas parametrizadas
      vr_dstextab     craptab.dstextab%TYPE;                       --> Descrição da taxa de tabela
      vr_persocio     NUMBER;                                      --> Percentual de sócio
      vr_tab_grupo    geco0001.typ_tab_crapgrp;                    --> PL Table para armazenar grupos econômicos
      vr_cdoperad     VARCHAR2(40);                                --> Código do cooperado
    vr_dsparam      VARCHAR2(4000);                              --> Parâmetros da rotina para as mensagens
    vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;      

    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => null);

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                ,pr_flgbatch => 1
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_cdcritic => vr_cdcritic);

      -- Se retornou critica aborta programa
      IF vr_cdcritic <> 0 THEN
        -- Descricao do erro recebe mensagam da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio do log de erro
        RAISE vr_exc_saida;
      END IF;

	    -- Verificação do calendário
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;

        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Se o mês do movimento atual (dtmvtolt) é diferente do mês ref. ao próximo movimento(dtmvtopr)
      -- sai do programa e volta para a cadeia.
			IF to_char(rw_crapdat.dtmvtolt,'MM') <> to_char(rw_crapdat.dtmvtopr,'MM') THEN
      --Inclusão tratamento para datas diferentes - Chamado 813391
      vr_cdcritic := 1068;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                     ||' '||to_char(rw_crapdat.dtmvtolt,'MM')||' <> '||to_char(rw_crapdat.dtmvtopr,'MM');
        RAISE vr_exc_fimprg;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic:= 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Busca o percentual societário da cooperativa
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'PROVISAOCL'
                                               ,pr_tpregist => 999);

      -- Se não encontrar o percentual gera exceção e sai do programa
      IF vr_dstextab IS NULL THEN
      vr_cdcritic := 1193;  --Valor do Percentual Societário Exigido não foi encontrado para a cooperativa
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)|| rw_crapcop.nmrescop||'.';

        RAISE vr_exc_saida;
      ELSE
        -- Alimenta a variável com o percentual societário
        vr_persocio := substr(vr_dstextab, 91,6);
      END IF;

    --Chamado 813391
    vr_dsparam := 'cooper:'||pr_cdcooper||', cdagenci:0, nrdcaixa:0'||', cdoperad:'||vr_cdoperad
                  ||', cdprogra:'||vr_cdprogra||', idorigem:1'||', persocio:'||vr_persocio;

    --Inclusão log para acompanhamento de tempo de execução - Chamado 813391
    --Registra o início
    --> Controlar geração de log de execução dos jobs                                
    --Substituicao da rotina pc_gera_log_batch pela pc_log_programa - Chamado INC0011087
    CECRED.pc_log_programa(pr_dstiplog      => 'O',
                           pr_cdcooper      => rw_crapcop.cdcooper,
                           pr_tpocorrencia  => 1,  --Mensagem
                           pr_cdprograma    => vr_cdprogra,
                           pr_tpexecucao    => 1, --Batch
                           pr_cdcriticidade => 0,
                           pr_cdmensagem    => 1066, -- Inicio execucao
                           pr_dsmensagem    => gene0001.fn_busca_critica(1066)
                                               ||'pc_forma_grupo_economico '
                                               ||rw_crapcop.nmrescop||'. '||vr_dsparam,
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => NULL);
--
      -- Controlando a formação dos grupos economicos
      geco0001.pc_forma_grupo_economico(pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => vr_cdoperad
                                       ,pr_cdprogra => lower(vr_cdprogra)
                                       ,pr_idorigem => 1
                                       ,pr_persocio => vr_persocio
                                       ,pr_tab_crapdat => rw_crapdat
                                       ,pr_tab_grupo => vr_tab_grupo
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreram eerros
    --Aqui, embora tenha sido cadastrado o código 1191 para a mensagem abaixo,
    --o mesmo não é gravado na vr_cdcritic, pois neste caso, omitiria o retorno da 
    --pc_forma_grupo_economico. Por isso o conteúdo da variável vr_dscritic tem uma
    --parte fixa concatenada com o retorno da rotina.
      IF vr_dscritic <> 'OK' THEN
      vr_dscritic := '1191 - Nao foi possivel atualizar o risco da CRAPGRP com risco do ultimo dia do mes na CRAPRIS. '|| vr_dscritic;

        -- Gravar mensagem de erro em LOG
        RAISE vr_exc_saida;
    ELSE
      --Se executou com sucesso, registra o término na tabela de logs
      --Inclusão log para acompanhamento de tempo de execução - Chamado 813391
      --> Controlar geração de log de execução dos jobs                                
      --Substituicao da rotina pc_gera_log_batch pela pc_log_programa - Chamado INC0011087
      CECRED.pc_log_programa(pr_dstiplog      => 'O',
                             pr_cdcooper      => rw_crapcop.cdcooper,
                             pr_tpocorrencia  => 1,  --Mensagem
                             pr_cdprograma    => vr_cdprogra,
                             pr_tpexecucao    => 1, --Batch
                             pr_cdcriticidade => 0,
                             pr_cdmensagem    => 1067, --Termino execucao
                             pr_dsmensagem    => gene0001.fn_busca_critica(1067)
                                                 ||'pc_forma_grupo_economico '
                                                 ||rw_crapcop.nmrescop||'. '||vr_dsparam,
                             pr_idprglog      => vr_idprglog,
                             pr_nmarqlog      => NULL);

      END IF;

      -- Alimentando a mensagem de sucesso que será impressa no log
    vr_cdcritic := 1192;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Atualizacao do risco da CRAPGRP com risco do ultimo dia do mes na CRAPRIS realizado com sucesso

    --> Controlar geração de log de execução dos jobs
    --Como executa na cadeira, utiliza pc_gera_log_batch
    btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                              ,pr_ind_tipo_log  => 2 -- Erro tratato
                              ,pr_dstiplog      => 'E'
                              ,pr_cdprograma    => vr_cdprogra
                              ,pr_tpexecucao    => 1 -- batch
                              ,pr_cdcriticidade => 1
                              ,pr_cdmensagem    => vr_cdcritic
                              ,pr_des_log       => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   ||vr_cdprogra||' --> '||vr_dscritic);


      -- Limpando a variável de crítica
      vr_dscritic := '';

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Efetuar Commit de informações pendentes de gravação
      COMMIT;
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
        --Padronização log do erro - Chamado 813391
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,pr_nmarqlog      => 'proc_batch.log'
                                  ,pr_dstiplog      => 'E'
                                  ,pr_cdprograma    => vr_cdprogra
                                  ,pr_tpexecucao    => 1 -- Batch
                                  ,pr_cdcriticidade => 1
                                  ,pr_cdmensagem    => vr_cdcritic
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                       ||vr_cdprogra||' --> '||vr_dscritic);
        END IF;

        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);

        -- Efetuar commit pois gravaremos o que foi processo até então
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

      --Inclusão log do erro - Chamado 813391
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 2 -- Erro tratado
                                ,pr_nmarqlog      => 'proc_batch.log'
                                ,pr_dstiplog      => 'E'
                                ,pr_cdprograma    => vr_cdprogra
                                ,pr_tpexecucao    => 1 -- Batch
                                ,pr_cdcriticidade => 1
                                ,pr_cdmensagem    => pr_cdcritic
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                     ||vr_cdprogra||' --> '||pr_dscritic);

        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
      -- Padronização - Chamado 813391
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||SQLERRM;

      --Inclusão log do erro - Chamado 813391
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 3 -- Erro nao tratado
                                ,pr_nmarqlog      => 'proc_batch.log'
                                ,pr_dstiplog      => 'E'
                                ,pr_cdprograma    => vr_cdprogra
                                ,pr_tpexecucao    => 1 -- Batch
                                ,pr_cdcriticidade => 2
                                ,pr_cdmensagem    => pr_cdcritic
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                     ||vr_cdprogra||' --> '||pr_dscritic);

      -- No caso de erro de programa gravar tabela especifica de log - 14/12/2017 - Chamado 813391
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps641;
/
