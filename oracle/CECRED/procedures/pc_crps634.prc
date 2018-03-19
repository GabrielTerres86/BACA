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
   Data    : Dezembro/2012                     Ultima atualizacao: 17/01/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Realiza a formacao do grupo economico.


   Alteracoes: 22/03/2013 - Ajuste para alimentar a aux_persocio com as posicoes
                            "91,6" ao inves de "28,6" (Adriano).

               17/01/2014 - Conversao Progresso -> Oracle (Gabriel).

               03/03/2014 - Validação e ajustes para execução (Petter-Supero).

............................................................................. */

  vr_cdprogra        VARCHAR2(10);                   --> Nome do programa
  vr_cdcritic        crapcri.cdcritic%TYPE;          --> Codigo da critica
  vr_dscritic        VARCHAR2(2000);                 --> Descricao da critica
  vr_persocio        NUMBER(10,2);                   --> Sócios
  vr_cdoperad        VARCHAR2(40);                   --> Código do cooperado
  vr_exc_saida       EXCEPTION;                      --> Controle de exceção
  vr_exc_fimprg      EXCEPTION;                      --> Controle de exceção
  rw_crapdat         btch0001.cr_crapdat%rowtype;    --> Dados para fetch de cursor genérico
  vr_infimsol        PLS_INTEGER;
  vr_stprogra        PLS_INTEGER; 

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
  IF to_char(rw_crapdat.dtmvtolt,'mm') <> to_char(rw_crapdat.dtmvtopr,'mm')  THEN
    RAISE vr_exc_fimprg;
  END IF;

  -- Buscar a descrição das faixas contido na craptab
  OPEN cr_craptab(pr_cdcooper, 'CRED', 'GENERI', 00, 'PROVISAOCL', 999);
  FETCH cr_craptab INTO rw_craptab;

  -- Verifica se a tupla retornou registro
  IF cr_craptab%NOTFOUND THEN
    CLOSE cr_craptab;

    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> Valor do Percentual Societario Exigido ' ||
                                                  'nao foi encontrado para a ' || rw_crapcop.nmrescop
                              ,pr_nmarqlog     => 'PROC_BATCH');

    RAISE vr_exc_saida;
  ELSE
    CLOSE cr_craptab;
    vr_persocio := to_number(substr(rw_craptab.dstextab, 91, 6));
  END IF;
  
  
      -- limpa wrk para paralelismo
    DELETE
    from tbgen_batch_relatorio_wrk wrk
    where wrk.cdcooper    = pr_cdcooper
    and wrk.cdprograma  = 'pc_crps634_i'
    and wrk.dsrelatorio = 'rptGrupoEconomico';
    --and wrk.dtmvtolt    = rw_crapdat.dtmvtolt;

    
                -- limpa tabela de grupo.
            DELETE FROM crapgrp cp WHERE cp.cdcooper = pr_cdcooper;
            COMMIT; 

  -- Incluir include
  PC_CRPS634_I(pr_cdcooper    => pr_cdcooper
              ,pr_cdagenci    => 0
              ,pr_cdoperad    => vr_cdoperad
              ,pr_cdprogra    => vr_cdprogra
              ,pr_persocio    => vr_persocio
              ,pr_tab_crapdat => rw_crapdat
              ,pr_impcab      => 'S'
              ,pr_idparale    => 0
              ,pr_stprogra    => vr_stprogra
              ,pr_infimsol    => vr_infimsol              
              ,pr_cdcritic    => vr_cdcritic
              ,pr_dscritic    => vr_dscritic);

  -- Verifica se ocorreram erros
  IF vr_dscritic IS NOT NULL OR vr_cdcritic > 0 THEN
    RAISE vr_exc_saida;
  END IF;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
                           
    -- limpa wrk para paralelismo
    DELETE
    from tbgen_batch_relatorio_wrk wrk
    where wrk.cdcooper    = pr_cdcooper
    and wrk.cdprograma  = 'pc_crps634_i'
    and wrk.dsrelatorio = 'rptGrupoEconomico';
    --and wrk.dtmvtolt    = rw_crapdat.dtmvtolt;
                   
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
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
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

    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;

    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS634;
/
