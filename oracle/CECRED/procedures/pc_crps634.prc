CREATE OR REPLACE PROCEDURE CECRED.pc_crps634(pr_cdcooper  IN NUMBER         --> Código da cooperativa
                                      ,pr_flgresta  IN PLS_INTEGER    --> Indicador para utilização de restart
                                      ,pr_stprogra  OUT PLS_INTEGER   --> Saída de termino da execução
                                      ,pr_infimsol  OUT PLS_INTEGER   --> Saída de termino da solicitação
                                      ,pr_cdcritic  OUT NUMBER        --> Código crítica
                                      ,pr_dscritic  OUT VARCHAR2) AS  --> Descrição crítica
/* ..........................................................................

   Programa: Fontes/crps634.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CECRED
   Autor   : Adriano
   Data    : Dezembro/2012                     Ultima atualizacao: 21/03/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Realiza a formacao do grupo economico.


   Alteracoes: 22/03/2013 - Ajuste para alimentar a aux_persocio com as posicoes
                            "91,6" ao inves de "28,6" (Adriano).

               17/01/2014 - Conversao Progresso -> Oracle (Gabriel).

               03/03/2014 - Validação e ajustes para execução (Petter-Supero).

               13/12/2017 - Padronização mensagens 
                          - Tratamento erros others - cecred.pc_internal_exception
                          - Nova exception para não gerar log, pois a rotina GECO0001 já gera
                           (Ana - Envolti - Chamado 813390)

               21/03/2018 - Substituição da rotina pc_gera_log_batch pela pc_log_programa
                            para os códigos 1066 e 1067
                           (Ana - Envolti - Chamado INC0011087)
............................................................................. */

  vr_cdprogra          VARCHAR2(10);                   --> Nome do programa
  vr_cdcritic          crapcri.cdcritic%TYPE;          --> Codigo da critica
  vr_dscritic          VARCHAR2(2000);                 --> Descricao da critica
  vr_persocio          NUMBER(10,2);                   --> Sócios
  vr_cdoperad          VARCHAR2(40);                   --> Código do cooperado
  vr_exc_saida         EXCEPTION;                      --> Controle de exceção - gera log
  vr_exc_saida_sem_log EXCEPTION;                      --> Controle de exceção - nao gera log
  vr_exc_fimprg        EXCEPTION;                      --> Controle de exceção
  rw_crapdat           btch0001.cr_crapdat%rowtype;    --> Dados para fetch de cursor genérico
  vr_dsparam           VARCHAR2(4000);                 --> Parâmetros da rotina para as mensagens
  vr_idprglog          tbgen_prglog.idprglog%TYPE := 0;      

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> Código da cooperativa
    SELECT cop.nmrescop
          ,cop.nrtelura
          ,cop.dsdircop
    FROM crapcop cop
    WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca dados de taxas
  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE               --> Código cooperativa
                   ,pr_nmsistem IN craptab.nmsistem%TYPE               --> Nome sistema
                   ,pr_tptabela IN craptab.tptabela%TYPE               --> Tipo tabela
                   ,pr_cdempres IN craptab.cdempres%TYPE               --> código empresa
                   ,pr_cdacesso IN craptab.cdacesso%TYPE               --> Código acesso
                   ,pr_tpregist IN craptab.tpregist%TYPE) IS           --> Tipo de registro
    SELECT SUBSTR(cb.dstextab, 49, 15) dstextabs
          ,cb.dstextab
    FROM craptab cb
    WHERE cb.cdcooper = pr_cdcooper
      AND cb.nmsistem = pr_nmsistem
      AND cb.tptabela = pr_tptabela
      AND cb.cdempres = pr_cdempres
      AND cb.cdacesso = pr_cdacesso
      AND cb.tpregist = pr_tpregist;
  rw_craptab cr_craptab%rowtype;

BEGIN
  -- Atribuição de valores iniciais da procedure
  vr_cdprogra := 'CRPS634';
  vr_persocio := 0;

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS634', pr_action => NULL);

  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;

  -- Se não encontrar registros montar mensagem de critica
  IF cr_crapcop%NOTFOUND THEN
    CLOSE cr_crapcop;

    vr_cdcritic := 651;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

    RAISE vr_exc_saida;
  ELSE
    CLOSE cr_crapcop;
  END IF;

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                            ,pr_flgbatch => 1
                            ,pr_cdprogra => vr_cdprogra
                            ,pr_infimsol => pr_infimsol
                            ,pr_cdcritic => vr_cdcritic);

  -- Caso retorno crítica busca a descrição
  IF vr_cdcritic <> 0 THEN
    RAISE vr_exc_saida;
  END IF;

  -- Selecionar informacoes das datas
  OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  -- Nao rodar na mensal
  IF to_char(rw_crapdat.dtmvtolt,'mm') <> to_char(rw_crapdat.dtmvtopr,'mm') THEN
    --Inclusão tratamento para datas diferntes - Chamado 813391
    vr_cdcritic := 1068;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                   ||' '||to_char(rw_crapdat.dtmvtolt,'MM')||' <> '||to_char(rw_crapdat.dtmvtopr,'MM');
    RAISE vr_exc_fimprg;
  END IF;

  -- Buscar a descrição das faixas contido na craptab
  OPEN cr_craptab(pr_cdcooper, 'CRED', 'GENERI', 00, 'PROVISAOCL', 999); --GEBNERI
  FETCH cr_craptab INTO rw_craptab;

  -- Verifica se a tupla retornou registro
  IF cr_craptab%NOTFOUND THEN
    CLOSE cr_craptab;

    vr_cdcritic := 1193;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)|| rw_crapcop.nmrescop||'.';

    RAISE vr_exc_saida;
  ELSE
    CLOSE cr_craptab;
    vr_persocio := to_number(substr(rw_craptab.dstextab, 91, 6));
  END IF;

  vr_dsparam := 'cooper:'||pr_cdcooper||', cdagenci:0, cdoperad:'||vr_cdoperad||', cdprogra:'||vr_cdprogra
                ||', persocio:'||vr_persocio||', dtmvtolt:'||rw_crapdat.dtmvtolt;

  --Inclusao log para acompanhamento de tempo de execução - Chamado 813390
  --Registra o início
  --Substituicao da rotina pc_gera_log_batch pela pc_log_programa - Chamado INC0011087
  CECRED.pc_log_programa(pr_dstiplog      => 'O',
                         pr_cdcooper      => pr_cdcooper,
                         pr_tpocorrencia  => 1,  --Mensagem
                         pr_cdprograma    => vr_cdprogra,
                         pr_tpexecucao    => 1, --Batch
                         pr_cdcriticidade => 0,
                         pr_cdmensagem    => 1066, -- Inicio execucao
                         pr_dsmensagem    => gene0001.fn_busca_critica(1066)
                                             ||'PC_CRPS634_I '
                                             ||rw_crapcop.nmrescop||'. '||vr_dsparam,
                         pr_idprglog      => vr_idprglog,
                         pr_nmarqlog      => NULL);

  -- Incluir include
  PC_CRPS634_I(pr_cdcooper    => pr_cdcooper
              ,pr_cdagenci    => 0
              ,pr_cdoperad    => vr_cdoperad
              ,pr_cdprogra    => vr_cdprogra
              ,pr_persocio    => vr_persocio
              ,pr_tab_crapdat => rw_crapdat
              ,pr_impcab      => 'S'
              ,pr_cdcritic    => vr_cdcritic
              ,pr_dscritic    => vr_dscritic);

  -- Verifica se ocorreram erros
  IF vr_dscritic IS NOT NULL OR vr_cdcritic > 0 THEN
    --Ja registra na tbgen na rotina CRPS634_I
    RAISE vr_exc_saida_sem_log;
  ELSE
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS634', pr_action => NULL);

    --Se executou com sucesso, registra o término na tabela de logs
    --Inclusao log para acompanhamento de tempo de execução - Chamado 813390
    --Substituicao da rotina pc_gera_log_batch pela pc_log_programa - Chamado INC0011087
    CECRED.pc_log_programa(pr_dstiplog      => 'O',
                           pr_cdcooper      => pr_cdcooper,
                           pr_tpocorrencia  => 1,  --Mensagem
                           pr_cdprograma    => vr_cdprogra,
                           pr_tpexecucao    => 1, --Batch
                           pr_cdcriticidade => 0,
                           pr_cdmensagem    => 1067, --Termino execucao
                           pr_dsmensagem    => gene0001.fn_busca_critica(1067)
                                               ||'PC_CRPS634_I '
                                               ||rw_crapcop.nmrescop||'. '||vr_dsparam,
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => NULL);
  END IF;
  --

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  COMMIT;
EXCEPTION
  WHEN vr_exc_fimprg  THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      --Padronização log do erro - Chamado 813390
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper             
                                ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                ,pr_nmarqlog      => 'proc_batch.log'          
                                ,pr_dstiplog      => 'E' 
                                ,pr_cdprograma    => vr_cdprogra                      
                                ,pr_tpexecucao    => 1 -- Batch                       
                                ,pr_cdcriticidade => 1                    
                                ,pr_cdmensagem    => vr_cdcritic                      
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                     ||vr_cdprogra||' --> ' ||vr_dscritic);
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
  WHEN vr_exc_saida_sem_log THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;

    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    -- Padronização - Chamado 813390
    pr_cdcritic := 9999;
    pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||SQLERRM;

    --Inclusão log do erro - Chamado 813390 - utilizado mesmo critério da pc_crps634_i
    btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper             
                              ,pr_ind_tipo_log  => 3 -- Erro nao tratado
                              ,pr_nmarqlog      => 'proc_batch.log'          
                              ,pr_dstiplog      => 'E' 
                              ,pr_cdprograma    => vr_cdprogra                      
                              ,pr_tpexecucao    => 1 -- Batch                       
                              ,pr_cdcriticidade => 2                    
                              ,pr_cdmensagem    => pr_cdcritic                      
                              ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                   ||vr_cdprogra||' --> ' ||pr_dscritic);

    -- No caso de erro de programa gravar tabela especifica de log - 13/12/2017 - Chamado 813390
    CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS634;
/
