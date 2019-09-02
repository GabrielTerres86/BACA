CREATE OR REPLACE PACKAGE CECRED.CHEQ0003 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CHEQ0003
  --  Sistema  : Rotinas focadas no sistema de Cheques - Devolução de cheques
  --  Sigla    : CHEQ
  --  Autor    : André Bohn (Mouts)
  --  Data     : Outubro/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Processar a devolução automática de cheques
  --
  --   Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------


  -- Efetiva a devolução do cheque
  PROCEDURE pc_trata_devolucao_cheque(pr_cdcoopch IN crapchd.cdcooper%TYPE  --> Cooperativa do emitente do cheque
                                      ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                      ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                      ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                      ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                     -- ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE  --> Data da compensação
                                      ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                      ,pr_cdcoopdp IN crapchd.cdcooper%TYPE  --> Cooperativa da conta do depositante
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da conta depositante
                                      ,pr_cdagenci IN craplot.cdagenci%TYPE  --> Agência lote lançamento depositante
                                      ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE  --> 
                                      ,pr_nrdolote IN craplot.nrdolote%TYPE  --> Número do lote do lançamento depositante 		                                     
                                      ,pr_tpopechq IN pls_integer            --> 1 - Custódia 2 - Desconto
                                      ,pr_rw_crapdat  IN  btch0001.cr_crapdat%ROWTYPE
                                      ,pr_cdalinea OUT pls_integer           -- 0 - Não devolveu cheque / 1 - Devolveu cheque
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2);            --> Texto de erro/critica encontrada
                                      
  -- Trata a devolução de cheques da mesma cooperativa, no momento da liberação da custódia
  PROCEDURE pc_efetiva_devchq_depositante(pr_cdcoopch IN crapchd.cdcooper%TYPE  --> Cooperativa emitente cheque
                                         ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                         ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                         ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                         ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                         ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE  --> Data da compensação
                                         ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                         ,pr_cdcoopdp IN crapchd.cdcooper%TYPE  --> Cooperativa da conta do depositante
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da conta depositante
                                         ,pr_cdagenci IN craplot.cdagenci%TYPE  --> Agência lote lançamento depositante
                                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE  --> 
                                         ,pr_nrdolote IN craplot.nrdolote%TYPE  --> Número do lote do lançamento depositante
                                         ,pr_tpopechq IN pls_integer            --> 1 - Custódia / 2 - Desconto 		                                     
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                         ,pr_dscritic OUT VARCHAR2);                                   
                                                                                   
  -- Procedimento para inserir o registro de cheque na crapchd para ser possível consultar na tela PESQDP
  PROCEDURE pc_gera_pesq_deposito_cheque(pr_cdcooper IN crapchd.cdcooper%TYPE  --> Cooperativa emitente cheque
                                        ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                        ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                        ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                        ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                        ,pr_nrcheque IN crapchd.nrcheque%TYPE
                                        ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                        ,pr_dscritic OUT VARCHAR2) ;  

  -- Rotina para atualizar os códigos HASH e SEGURANÇA na tabela tbchq_seguranca_cheque e também ATUALIZAR o STATUS para processado ou erro
  PROCEDURE pc_atualiza_cod_seguranca_chq(pr_cdcooper     IN tbchq_seguranca_cheque.cdcooper%TYPE
                                         ,pr_cdbanchq     IN tbchq_seguranca_cheque.cdbanchq%TYPE
                                         ,pr_cdagechq     IN tbchq_seguranca_cheque.cdagechq%TYPE
                                         ,pr_nrctachq     IN tbchq_seguranca_cheque.nrctachq%TYPE
                                         ,pr_nrcheque     IN tbchq_seguranca_cheque.nrcheque%TYPE
                                         ,pr_cdhashcode   IN tbchq_seguranca_cheque.cdhashcode%TYPE
                                         ,pr_cdseguranca  IN tbchq_seguranca_cheque.cdseguranca%TYPE
                                         ,pr_cdcritic     OUT crapcri.cdcritic%TYPE
                                         ,pr_dscritic     OUT crapcri.dscritic%TYPE
                                         );

  -- Rotina para atualizar os códigos HASH e SEGURANÇA na tabela tbchq_seguranca_cheque e também ATUALIZAR o STATUS para processado ou erro
  PROCEDURE pc_verifica_pendencia_cod_seg(pr_cdcooper     IN tbchq_seguranca_cheque.cdcooper%TYPE
                                         ,pr_cdbanchq     IN tbchq_seguranca_cheque.cdbanchq%TYPE
                                         ,pr_cdagechq     IN tbchq_seguranca_cheque.cdagechq%TYPE
                                         ,pr_nrctachq     IN tbchq_seguranca_cheque.nrctachq%TYPE
                                         ,pr_nrcheque     IN tbchq_seguranca_cheque.nrcheque%TYPE
                                         ,pr_idprocessado OUT NUMBER -- retorna 0 se ainda tem registros pendentes, ou 1 para TODOS PROCESSADOS
                                         ,pr_cdcritic     OUT crapcri.cdcritic%TYPE
                                         ,pr_dscritic     OUT crapcri.dscritic%TYPE
                                         );

  PROCEDURE pc_gera_crapfdc (pr_cdcooper in craptab.cdcooper%TYPE
                            ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                            ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                            ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                            ,pr_cdcritic out crapcri.cdcritic%TYPE
                            ,pr_dscritic out varchar2);

  PROCEDURE pc_gera_arq_grafica_cheque (pr_cdcooper in craptab.cdcooper%TYPE
                     ,pr_nrpedido  IN crapreq.nrpedido%TYPE                     
                     ,pr_tprequis  IN crapreq.tprequis%TYPE
                     ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                     ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                     ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                     ,pr_cdcritic out crapcri.cdcritic%TYPE
                     ,pr_dscritic out varchar2);
                     
  PROCEDURE pc_obtem_hashcode (pr_nrcpfcnpj IN NUMBER,
                               pr_nrdconta IN NUMBER,
                               pr_nrdocumento IN NUMBER,
                               pr_cdhashcode OUT VARCHAR2);

END CHEQ0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CHEQ0003 AS
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CHEQ0003
  --  Sistema  : Rotinas focadas no sistema de Cheques - Devolução automática de cheques
  --  Sigla    : CHEQ
  --  Autor    : Andre (Mouts)
  --  Data     : Outubro/2018.                   Ultima atualizacao: Maio/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Processar a devolução automática de cheques 
  --               
  --   Alteracoes: 18/02/2019 - Incluir nova procedure pc_gera_pesq_deposito_cheque
  --                            Problema PRB0040612 (Andre - MoutS)
  --               16/04/2019 - Remover verificação de Dev. Aut. Cheques para cheques com Contra-Ordem
  --                            RITM0011849 (Jefferson - MoutS)
  --               29/05/2019 - Projeto 565 - RF20 - Alteração histórico 351 para hstórico 2973 no tratamento de devolução
  --                            (Fernanda Kelli - AMcom)
  --               16/05/2019 - Inclusão rotinas tratamento código de segurança cheque - projeto 505
  --                            (Renato Cordeiro - AMcom)
  --               17/07/2019 - Tratamento para multiplas solicitações de talões - PJ505 código de segurança cheque
  --                            (Renato Cordeiro - AMcom)
  --               19/07/2019 - Gera numeração de cheques com digito no relatório 392 - PJ505 código de segurança cheque
  --                            (Renato Cordeiro - AMcom)
  --               24/07/2019 - Acerto relatório 392 mostrar todos os taloes solicitados - PJ505 código de segurança cheque
  --                            (Renato Cordeiro - AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------

-- Valida a alinea caso cheque esteja com contra-ordem
procedure pc_valida_alinea_contra_ordem(pr_cdcooper IN crapchd.cdcooper%TYPE  --> Cooperativa
                                       ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                       ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                       ,pr_nrctachq IN crapass.nrdconta%TYPE  --> Número da conta do cheque
                                       ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                       ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE  --> Data da compensação
                                       ,pr_cdalinea OUT crapali.cdalinea%TYPE -- Alínea retornada
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) is
      

    CURSOR cr_crapcor (pr_cdcooper IN crapcor.cdcooper%TYPE
                      ,pr_cdbanchq IN crapcor.cdbanchq%TYPE
                      ,pr_cdagechq IN crapcor.cdagechq%TYPE
                      ,pr_nrctachq IN crapcor.nrctachq%TYPE
                      ,pr_nrcheque IN crapcor.nrcheque%TYPE
                      ,pr_flgativo IN crapcor.flgativo%TYPE) IS
      SELECT crapcor.dtvalcor
            ,crapcor.dtemscor
            ,crapcor.cdhistor
      FROM crapcor crapcor
      WHERE crapcor.cdcooper = pr_cdcooper
      AND   crapcor.cdbanchq = pr_cdbanchq
      AND   crapcor.cdagechq = pr_cdagechq
      AND   crapcor.nrctachq = pr_nrctachq
      AND   crapcor.nrcheque = pr_nrcheque
      AND   crapcor.flgativo = pr_flgativo;
      rw_crapcor cr_crapcor%ROWTYPE;
      
      --Selecionar os lancamentos
      CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                        ,pr_nrdconta IN craplcm.nrdconta%TYPE
                        ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
        SELECT craplcm.dtmvtolt
          FROM craplcm craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
           AND craplcm.nrdconta = pr_nrdconta
           AND craplcm.nrdocmto = pr_nrdocmto
           AND craplcm.cdpesqbb = '21'
           AND craplcm.cdhistor IN (47, 191, 338, 573)
         ORDER BY craplcm.progress_recid DESC;
      rw_craplcm cr_craplcm%ROWTYPE;
      vr_dsparame  varchar2(4000);
    
begin
  -- Incluido nome do módulo logado
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_valida_alinea_contra_ordem');
  
  --Inicializar variaveis critica
  pr_cdcritic := 0;
  pr_dscritic := NULL;
    
  --Agrupa os parametros
  vr_dsparame := ' pr_cdcooper:' || pr_cdcooper ||
                 ' ,pr_cdbanchq:' || pr_cdbanchq  ||
                 ' ,pr_cdagechq:' || pr_cdagechq  ||
                 ' ,pr_nrctachq:' || pr_nrctachq  ||
                 ' ,pr_nrcheque:' || pr_nrcheque  ||
                 ' ,pr_dtmvtolt:' || pr_dtmvtolt;  
  -- 
  BEGIN
    pr_cdalinea := 0;
    OPEN cr_crapcor (pr_cdcooper => pr_cdcooper
                    ,pr_cdbanchq => pr_cdbanchq
                    ,pr_cdagechq => pr_cdagechq
                    ,pr_nrctachq => pr_nrctachq
                    ,pr_nrcheque => pr_nrcheque
                    ,pr_flgativo => 1);
                    
    --Posicionar no proximo registro
    FETCH cr_crapcor INTO rw_crapcor;
    --Se nao encontrou
    IF cr_crapcor%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcor;

      /* Contra Ordem Provisoria */
      IF rw_crapcor.dtvalcor >= pr_dtmvtolt AND rw_crapcor.dtvalcor IS NOT NULL  THEN
        pr_cdalinea:= 70;
      ELSIF rw_crapcor.cdhistor = 835 THEN
        pr_cdalinea:= 28;
      ELSIF rw_crapcor.cdhistor = 818 THEN
        pr_cdalinea:= 20;
      ELSIF rw_crapcor.cdhistor = 815 THEN
        pr_cdalinea:= 21;
      ELSE
        pr_cdalinea:= 21;
      END IF;
      
      IF  pr_cdalinea = 21 THEN
        /* Se ja existir devolucao com a alinea 21, devolver com a alinea 43 */
        --Selecionar os lancamentos
        OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrctachq
                        ,pr_nrdocmto => pr_nrcheque);
        --Posicionar no proximo registro
        FETCH cr_craplcm INTO rw_craplcm;
        --Se encontrou registro
        IF cr_craplcm%FOUND THEN
          pr_cdalinea:= 43;
        END IF;
        --Fechar cursor
        CLOSE cr_craplcm;
      END IF;
      
    END IF; --cr_crapcor%NOTFOUND
    --Fechar Cursor
    IF cr_crapcor%ISOPEN THEN
      CLOSE cr_crapcor;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
 
      pr_cdcritic:= 9999;
      pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                    'CHEQ0003.pc_valida_alinea_contra_ordem. '||sqlerrm||vr_dsparame||'.';
  END;  
end pc_valida_alinea_contra_ordem;
                            
-- Valida a alinea quando a conta do cheque está com insuficiência de saldo 
PROCEDURE pc_valida_alinea_sem_fundo(pr_cdcooper IN crapchd.cdcooper%TYPE  --> Cooperativa
                                    ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                    ,pr_cdageass IN crapass.cdagenci%TYPE  --> Código da agência do cooperado    
                                    ,pr_nrctachq IN crapass.nrdconta%TYPE  --> Número da conta do cheque
                                    ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                    ,pr_vlcheque IN crapfdc.vlcheque%TYPE  --> Valor do cheque
                                    ,pr_vllimcre IN crapass.vllimcre%TYPE  -- Limite de crédito do cooperado
                                    ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE  --> Data do movimento
                                    ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                    ,pr_cdalinea OUT crapali.cdalinea%TYPE -- Alínea retornada 
                                    ,pr_rw_crapdat  IN  btch0001.cr_crapdat%ROWTYPE 
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2) IS

  CURSOR cr_crapdpb(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_dtlibban IN crapdat.dtmvtolt%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT dpb.vllanmto
      FROM crapdpb dpb, craplcm lcm
     WHERE dpb.cdcooper = pr_cdcooper
       AND dpb.dtliblan = pr_dtlibban
       AND dpb.nrdconta = pr_nrdconta
       AND dpb.cdcooper = lcm.cdcooper
       AND dpb.dtmvtolt = lcm.dtmvtolt
       AND dpb.cdagenci = lcm.cdagenci
       AND dpb.cdbccxlt = lcm.cdbccxlt
       AND dpb.nrdolote = lcm.nrdolote
       AND dpb.nrdconta = lcm.nrdconta
       AND dpb.nrdocmto = lcm.nrdocmto
       AND dpb.cdhistor = lcm.cdhistor
       AND dpb.inlibera = 1;
  rw_crapdpb cr_crapdpb%ROWTYPE;

  --Selecionar Saldos Negativos e Devolucoes de Cheque
  CURSOR cr_crapneg_reg (pr_cdcooper IN crapneg.cdcooper%TYPE,
                         pr_nrdconta IN crapneg.nrdconta%TYPE,
                         pr_nrdocmto IN crapneg.nrdocmto%TYPE,
                         pr_cdobserv IN NUMBER ) IS
    SELECT /*+ index (crapneg crapneg##crapneg7) */
           crapneg.nrdconta
          ,crapneg.nrdocmto
          ,crapneg.cdobserv
     FROM crapneg crapneg
    WHERE crapneg.cdcooper = pr_cdcooper
      AND crapneg.cdhisest = 1
      AND crapneg.nrdconta = pr_nrdconta
      AND crapneg.nrdocmto = pr_nrdocmto
      AND crapneg.cdobserv = pr_cdobserv
      AND crapneg.dtfimest IS NULL;
  rw_crapneg_reg cr_crapneg_reg%ROWTYPE;
       
  --Selecionar Saldos Negativos e Devolucoes de Cheque
  CURSOR cr_crapneg (pr_cdcooper IN crapneg.cdcooper%TYPE,
                       pr_nrdconta IN crapneg.nrdconta%TYPE,
                       pr_nrdocmto IN crapneg.nrdocmto%TYPE) IS
    SELECT /*+ index (crapneg crapneg##crapneg7) */
           crapneg.nrdconta
          ,crapneg.nrdocmto
          ,crapneg.cdobserv
    FROM crapneg crapneg
    WHERE crapneg.cdcooper = pr_cdcooper
      AND crapneg.cdhisest = 1
      AND crapneg.nrdconta = pr_nrdconta
      AND crapneg.nrdocmto = pr_nrdocmto
      AND crapneg.cdobserv IN (11,12,13,14,20,25,28,30,35,43,44,45)
      AND crapneg.dtfimest IS NULL;
  rw_crapneg cr_crapneg%ROWTYPE;  
             
  vr_cdcritic  crapcri.cdcritic%TYPE;
  vr_dscritic  VARCHAR2(4000);   
  vr_tab_erro  gene0001.typ_tab_erro;
  vr_exc_erro  EXCEPTION;
  --Tipo da tabela de saldos
  vr_tab_saldo EXTR0001.typ_tab_saldos;
  rw_crapdat   btch0001.cr_crapdat%ROWTYPE;  
  vr_vlsddisp  crapsda.vlsddisp%TYPE;
  vr_vldeplib  crapdpb.vllanmto%TYPE;
  vr_dsparame  varchar2(4000);
                              
BEGIN
  -- Incluido nome do módulo logado
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_valida_alinea_sem_fundo');

  --Inicializar variaveis critica
  vr_cdcritic := 0;
  vr_dscritic := NULL;
  
  --Agrupa os parametros
  vr_dsparame := ' pr_cdcooper:' || pr_cdcooper || 
                 ' ,pr_cdbanchq:' || pr_cdbanchq  ||
                 ' ,pr_cdageass:' || pr_cdageass  ||
                 ' ,pr_nrctachq:' || pr_nrctachq  ||
                 ' ,pr_nrcheque:' || pr_nrcheque  ||
                 ' ,pr_vlcheque:' || pr_vlcheque  ||
                 ' ,pr_vllimcre:' || pr_vllimcre  ||
                 ' ,pr_dtmvtolt:' || pr_dtmvtolt  ||
                 ' ,pr_cdcmpchq:' || pr_cdcmpchq;

  BEGIN       
    -- Verifica se a cooperativa esta cadastrada
    rw_crapdat := pr_rw_crapdat;
    IF rw_crapdat.rowid IS NULL THEN
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
    END IF;
                       
    extr0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper, 
                                pr_rw_crapdat => rw_crapdat, 
                                pr_cdagenci => pr_cdageass, 
                                pr_nrdcaixa => 0, 
                                pr_cdoperad => '1', 
                                pr_nrdconta => pr_nrctachq, 
                                pr_vllimcre => pr_vllimcre, 
                                pr_dtrefere => pr_dtmvtolt, 
                                pr_flgcrass => FALSE, 
                                pr_tipo_busca => 'A', -- Tipo Busca(A-dtmvtoan)
                                pr_des_reto => vr_dscritic, 
                                pr_tab_sald => vr_tab_saldo, 
                                pr_tab_erro => vr_tab_erro);
                                                                
    --Se ocorreu erro
    IF vr_dscritic = 'NOK' THEN
      -- Tenta buscar o erro no vetor de erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| vr_dsparame;
      ELSE
        -- 1072 - Nao foi possivel consultar o saldo para a operacao.
        vr_cdcritic:= 1072;
      END IF;

      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      vr_dscritic:= NULL;
    END IF;
    --Verificar o saldo retornado
    IF vr_tab_saldo.Count = 0 THEN
      -- 1072 - Nao foi possivel consultar o saldo para a operacao.
      vr_cdcritic:= 1072;
                          
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      vr_vlsddisp := nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                     nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
    END IF; 
                                
    /* considerar cheques que terao o valor desbloqueado 
      no dia seguinte como parte do saldo */
    vr_vldeplib := 0;
                                  
    FOR rw_crapdpb IN cr_crapdpb(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrctachq
                                ,pr_dtlibban => pr_dtmvtolt) LOOP
      vr_vldeplib := nvl(vr_vldeplib,0) + nvl(rw_crapdpb.vllanmto,0);
    END LOOP;
    
    vr_vlsddisp := nvl(vr_vlsddisp,0) + nvl(vr_vldeplib,0);         
                          
    -- Caso o saldo seja insuficiente
    IF pr_vlcheque > vr_vlsddisp THEN
                              
      /***********************************************************
      **************** ALINEA DE DEVOLUÇÃO ***********************
      ***********************************************************/
                                  
      IF cr_crapneg%ISOPEN THEN
        CLOSE cr_crapneg;  
      END IF;  
      -- Verificar se existe alineas ja devolvidas
      OPEN cr_crapneg(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrctachq
                     ,pr_nrdocmto => pr_nrcheque);
      FETCH cr_crapneg INTO rw_crapneg;                                      
                                        
      -- Caso houver alguma alinea devolvida
      IF cr_crapneg%FOUND THEN
        CLOSE cr_crapneg;        
                                    
        IF cr_crapneg_reg%ISOPEN THEN
          CLOSE cr_crapneg_reg;  
        END IF;  
                                        
        OPEN cr_crapneg_reg(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrctachq
                           ,pr_nrdocmto => pr_nrcheque
                           ,pr_cdobserv => 12);
        FETCH cr_crapneg_reg INTO rw_crapneg_reg;                                      
                                      
        -- Caso encontre registro de devolucao automatica com alinea 12
        IF cr_crapneg_reg%FOUND THEN
          CLOSE cr_crapneg_reg;  
          pr_cdalinea := 49;
        ELSE 
          CLOSE cr_crapneg_reg;  
          OPEN cr_crapneg_reg(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrctachq
                             ,pr_nrdocmto => pr_nrcheque
                             ,pr_cdobserv => 11);
          FETCH cr_crapneg_reg INTO rw_crapneg_reg;                                      
                                        
          -- Caso encontre registro de devolucao automatica com alinea 11
          IF cr_crapneg_reg%FOUND THEN
            CLOSE cr_crapneg_reg;  
            pr_cdalinea := 12;
          ELSE
             CLOSE cr_crapneg_reg;  
            pr_cdalinea := 49;
          END IF;
        END IF;
      ELSE
        CLOSE cr_crapneg;  
        pr_cdalinea := 11;
      END IF;
    END IF; 
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdalinea := 0;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic||vr_dsparame||'.';
    WHEN OTHERS THEN      
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
 
      pr_cdcritic:= 9999;
      pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                    'CHEQ0003.pc_valida_alinea_sem_fundo. '||sqlerrm||vr_dsparame||'.';
  END;                               
END pc_valida_alinea_sem_fundo;
         
-- Retorna o número do documento não duplicado na tabela craplcm        
FUNCTION fn_gera_nr_docto(pr_cdcooper IN craplcm.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplcm.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplcm.nrdolote%TYPE
                         ,pr_nrdctabb IN craplcm.nrdctabb%TYPE
                         ,pr_nrdocmto IN craplcm.nrdocmto%TYPE
                         ,pr_nrdigchq IN crapfdc.nrdigchq%TYPE
                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                         ,pr_dscritic OUT VARCHAR2) return number is
    
    --Selecionar os lançamentos
    CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                      ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                      ,pr_cdagenci IN craplcm.cdagenci%TYPE
                      ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                      ,pr_nrdolote IN craplcm.nrdolote%TYPE
                      ,pr_nrdctabb IN craplcm.nrdctabb%TYPE
                      ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
                      
      SELECT craplcm.rowid
        FROM craplcm craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdagenci = pr_cdagenci
         AND craplcm.cdbccxlt = pr_cdbccxlt
         AND craplcm.nrdolote = pr_nrdolote
         AND craplcm.nrdctabb = pr_nrdctabb
         AND craplcm.nrdocmto = pr_nrdocmto;
    rw_craplcm cr_craplcm%ROWTYPE;
    
    vr_flgachou  BOOLEAN;
    vr_nrdocmto  craplcm.nrdocmto%TYPE;
    vr_dsparame  varchar2(4000);
            
BEGIN
  -- Incluido nome do módulo logado
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.fn_gera_nr_docto');
  
  --Inicializar variaveis critica
  pr_cdcritic := 0;
  pr_dscritic := NULL;
  
  -- Agrupa os parâmetros  
  vr_dsparame := 'pr_cdcooper:' || pr_cdcooper || 
                 ' ,pr_dtmvtolt:' || pr_dtmvtolt  ||
                 ' ,pr_cdagenci:' || pr_cdagenci  ||
                 ' ,pr_cdbccxlt:' || pr_cdbccxlt  ||
                 ' ,pr_nrdolote:' || pr_nrdolote  ||
                 ' ,pr_nrdctabb:' || pr_nrdctabb  ||
                 ' ,pr_nrdocmto:' || pr_nrdocmto;
  
  BEGIN
    vr_flgachou:= FALSE;
    vr_nrdocmto:= TO_NUMBER(TO_CHAR(pr_nrdocmto,'FM999999')||To_Char(pr_nrdigchq,'FM9'));
    WHILE NOT vr_flgachou LOOP
      --Selecionar lancamentos
      OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => pr_cdagenci
                       ,pr_cdbccxlt => pr_cdbccxlt
                       ,pr_nrdolote => pr_nrdolote
                       ,pr_nrdctabb => pr_nrdctabb
                       ,pr_nrdocmto => vr_nrdocmto);
      --Posicionar no proximo registro
      FETCH cr_craplcm INTO rw_craplcm;
      --Se encontrou registro
      IF cr_craplcm%FOUND THEN
        vr_nrdocmto:= (vr_nrdocmto + 1000000);
      ELSE
        vr_flgachou:= TRUE;
      END IF;
      --Fechar cursor
      CLOSE cr_craplcm;
    END LOOP; --WHILE vr_flgachou = FALSE
  EXCEPTION
    WHEN OTHERS THEN      
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
 
      pr_cdcritic:= 9999;
      pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                    'CHEQ0003.fn_gera_nr_docto. '||sqlerrm||vr_dsparame||'.';      
  END;   
  RETURN vr_nrdocmto;
END fn_gera_nr_docto;
                       
-- Trata a devolução de cheques da mesma cooperativa
PROCEDURE pc_trata_devolucao_cheque(pr_cdcoopch IN crapchd.cdcooper%TYPE  --> Cooperativa emitente cheque
                                   ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                   ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                   ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                   ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                   ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                   ,pr_cdcoopdp IN crapchd.cdcooper%TYPE  --> Cooperativa da conta do depositante
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da conta depositante
                                   ,pr_cdagenci IN craplot.cdagenci%TYPE  --> Agência lote lançamento depositante
                                   ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE  --> 
                                   ,pr_nrdolote IN craplot.nrdolote%TYPE  --> Número do lote do lançamento depositante 		                                     
                                   ,pr_tpopechq IN pls_integer            --> 1 - Custódia / 2 - Desconto
                                   ,pr_rw_crapdat IN  btch0001.cr_crapdat%ROWTYPE
                                   ,pr_cdalinea OUT pls_integer           -- Código da alínea retornada
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                   ,pr_dscritic OUT VARCHAR2) IS
                                  
   -- Verificar se devolucao é automatica
   CURSOR cr_tbchq_param_conta(pr_cdcooper crapcop.cdcooper%TYPE
                              ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT tbchq.flgdevolu_autom
      FROM tbchq_param_conta tbchq
     WHERE tbchq.cdcooper = pr_cdcooper
       AND tbchq.nrdconta = pr_nrdconta;
    rw_tbchq_param_conta cr_tbchq_param_conta%ROWTYPE;
    
    --Cursor para encontrar as folhas de cheques
      CURSOR cr_crapfdc(pr_cdcooper crapfdc.cdcooper%TYPE,
                        pr_cdbanchq crapfdc.cdbanchq%TYPE,
                        pr_cdagechq crapfdc.cdagechq%TYPE,
                        pr_nrctachq crapfdc.nrctachq%TYPE,
                        pr_nrcheque crapfdc.nrcheque%TYPE) IS
        SELECT ROWID,
               fdc.nrdconta,
               fdc.incheque,
               fdc.tpcheque,
               fdc.vlcheque,
               fdc.dtemschq,
               fdc.dtretchq,
               fdc.cdbanchq,
               fdc.cdagechq,
               fdc.nrctachq,
               fdc.dtliqchq,
               fdc.nrdigchq
          FROM crapfdc fdc
         WHERE fdc.cdcooper = pr_cdcooper
           AND fdc.cdbanchq = pr_cdbanchq
           AND fdc.cdagechq = pr_cdagechq
           AND fdc.nrctachq = pr_nrctachq
           AND fdc.nrcheque = pr_nrcheque;
      rw_crapfdc cr_crapfdc%ROWTYPE;

    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
     SELECT crapass.cdagenci,
            crapass.vllimcre
       FROM crapass crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;      
      
   vr_cdalinea    crapali.cdalinea%TYPE;
   vr_cdcritic  crapcri.cdcritic%TYPE;
   vr_dscritic  VARCHAR2(4000);   
   vr_dsparame  varchar2(4000);
   vr_exc_erro  EXCEPTION;   
   vr_tab_retorno lanc0001.typ_reg_retorno;  
   vr_incrineg  INTEGER;
   vr_nrdocmto    craplcm.nrdocmto%TYPE;
       
BEGIN
  -- Incluido nome do módulo logado
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_trata_devolucao_cheque');
  
  --Inicializar variaveis critica
  vr_cdcritic := 0;
  vr_dscritic := NULL;
  
  -- Agrupa os parâmetros
  vr_dsparame := 'pr_cdcoopch:' || pr_cdcoopch ||
                 ' ,pr_cdbanchq:' || pr_cdbanchq  ||
                 ' ,pr_cdagechq:' || pr_cdagechq  ||
                 ' ,pr_nrctachq:' || pr_nrctachq  ||
                 ' ,pr_nrcheque:' || pr_nrcheque  ||
                 ' ,pr_cdcmpchq:' || pr_cdcmpchq  ||
                 ' ,pr_cdcoopdp:' || pr_cdcoopdp  ||
                 ' ,pr_nrdconta:' || pr_nrdconta  ||
                 ' ,pr_cdagenci:' || pr_cdagenci  ||
                 ' ,pr_cdbccxlt:' || pr_cdbccxlt  ||
                 ' ,pr_nrdolote:' || pr_nrdolote  ||                                  
                 ' ,pr_tpopechq:' || pr_tpopechq;
  
  -- Inicia a alínea como cheque não devolvido
  pr_cdalinea := 0;
  
  BEGIN
    IF cr_tbchq_param_conta%ISOPEN THEN
      CLOSE cr_tbchq_param_conta;  
    END IF;                         
                          
    OPEN cr_tbchq_param_conta(pr_cdcooper => pr_cdcoopch
                             ,pr_nrdconta => pr_nrctachq);
    FETCH cr_tbchq_param_conta INTO rw_tbchq_param_conta;                                      
    CLOSE cr_tbchq_param_conta; 
                                 
    -- Caso encontre registro de devolucao automatica  
    IF rw_tbchq_param_conta.flgdevolu_autom is not null THEN
      -- se for devolucao automatica
      IF rw_tbchq_param_conta.flgdevolu_autom = 1 THEN 
        OPEN cr_crapfdc (pr_cdcooper => pr_cdcoopch
                                       ,pr_cdbanchq => pr_cdbanchq
                                       ,pr_cdagechq => pr_cdagechq
                                       ,pr_nrctachq => pr_nrctachq
                                       ,pr_nrcheque => pr_nrcheque);
        --Posicionar no primeiro registro
        FETCH cr_crapfdc INTO rw_crapfdc;
        IF cr_crapfdc%FOUND THEN
          CLOSE cr_crapfdc;
          vr_cdalinea := 0;
          if nvl(rw_crapfdc.incheque,0) in (1,2) then
            -- Verifica alinea de contra-ordem
            pc_valida_alinea_contra_ordem(pr_cdcooper => pr_cdcoopch
                                         ,pr_cdbanchq => pr_cdbanchq      
                                         ,pr_cdagechq => pr_cdagechq    
                                         ,pr_nrctachq => pr_nrctachq
                                         ,pr_nrcheque => TO_NUMBER(TO_CHAR(pr_nrcheque,'FM999999')||To_Char(rw_crapfdc.nrdigchq,'FM9')) 
                                         ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                         ,pr_cdalinea => vr_cdalinea
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                         
            -- Retornando nome do módulo logado
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_trata_devolucao_cheque');                                         
          end if;
                                       
         /* Não verificar saldo por solicitação da área de negócio 17/01/2019
           IF nvl(vr_cdalinea,0) = 0 THEN
            OPEN cr_crapass(pr_cdcooper => pr_cdcoopch
                           ,pr_nrdconta => pr_nrctachq);
            FETCH cr_crapass INTO rw_crapass;
                    
            --Se encontrou 
            IF cr_crapass%FOUND THEN
              CLOSE cr_crapass;
              -- Verifica alinea de cheque sem fundos
              pc_valida_alinea_sem_fundo(pr_cdcooper => pr_cdcoopch
                                           ,pr_cdbanchq => pr_cdbanchq    
                                           ,pr_cdageass => rw_crapass.cdagenci    
                                           ,pr_nrctachq => pr_nrctachq
                                           ,pr_nrcheque => TO_NUMBER(TO_CHAR(pr_nrcheque,'FM999999')||To_Char(rw_crapfdc.nrdigchq,'FM9'))
                                           ,pr_vlcheque => rw_crapfdc.vlcheque
                                           ,pr_vllimcre => rw_crapass.vllimcre
                                           ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                           ,pr_cdcmpchq => pr_cdcmpchq
                                           ,pr_cdalinea => vr_cdalinea
                                           ,pr_rw_crapdat => pr_rw_crapdat
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
                                           
              -- Retornando nome do módulo logado
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_trata_devolucao_cheque'); 
            ELSE   
               CLOSE cr_crapass;                            
            END IF;                              
          END IF; */
        
          IF nvl(vr_cdalinea,0) > 0 THEN
            -- Lança movimento Devolução na conta do emitente
            vr_nrdocmto := fn_gera_nr_docto(pr_cdcooper => pr_cdcoopch
                                           ,pr_dtmvtolt => pr_rw_crapdat.dtmvtopr
                                           ,pr_cdagenci => 1
                                           ,pr_cdbccxlt => 100
                                           ,pr_nrdolote => 7600
                                           ,pr_nrdctabb => pr_nrctachq
                                           ,pr_nrdocmto => pr_nrcheque
                                           ,pr_nrdigchq => rw_crapfdc.nrdigchq
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
  
            Lanc0001.pc_gerar_lancamento_conta( pr_dtmvtolt => pr_rw_crapdat.dtmvtopr, 
                                                pr_dtrefere => pr_rw_crapdat.dtmvtopr, 
                                                pr_cdagenci => 1,
                                                pr_cdbccxlt => 100, 
                                                pr_nrdolote => 7600,
                                                pr_nrdconta => pr_nrctachq, 
                                                pr_nrdctabb => pr_nrctachq,
                                                pr_nrdocmto => nvl(vr_nrdocmto, 0),
                                                pr_cdhistor => 47, --(CASE rw_crapfdc.tpcheque WHEN 1 THEN 573 ELSE 78 END), 
                                                pr_vllanmto => rw_crapfdc.vlcheque, 
                                                pr_cdcooper => pr_cdcoopch, 
                                                pr_cdbanchq => rw_crapfdc.cdbanchq, 
                                                pr_cdagechq => rw_crapfdc.cdagechq, 
                                                pr_nrctachq => rw_crapfdc.nrctachq,
                                                pr_cdpesqbb => vr_cdalinea, 
                                                pr_cdcoptfn => 0,
                                                pr_dsidenti => 2,
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_inprolot => 1,
                                                pr_incrineg => vr_incrineg,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);
               
               -- Retornando nome do módulo logado
               GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_trata_devolucao_cheque'); 
            
               -- Indica a alínea que o cheque foi devolvido
               pr_cdalinea := vr_cdalinea;
                                                
               -- Lança movimento Devolução na conta do depositante                                 
               IF nvl(pr_nrdconta,0) > 0 THEN
                  vr_nrdocmto := fn_gera_nr_docto(pr_cdcooper => pr_cdcoopdp
                                           ,pr_dtmvtolt => pr_rw_crapdat.dtmvtopr
                                           ,pr_cdagenci => pr_cdagenci
                                           ,pr_cdbccxlt => pr_cdbccxlt
                                           ,pr_nrdolote => pr_nrdolote
                                           ,pr_nrdctabb => pr_nrdconta
                                           ,pr_nrdocmto => pr_nrcheque
                                           ,pr_nrdigchq => rw_crapfdc.nrdigchq
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
  
                  Lanc0001.pc_gerar_lancamento_conta( pr_dtmvtolt => pr_rw_crapdat.dtmvtopr, 
                                                      pr_dtrefere => pr_rw_crapdat.dtmvtopr, 
                                                      pr_cdagenci => pr_cdagenci,
                                                      pr_cdbccxlt => pr_cdbccxlt, 
                                                      pr_nrdolote => pr_nrdolote,
                                                      pr_nrdconta => pr_nrdconta, 
                                                      pr_nrdctabb => pr_nrdconta,
                                                      pr_nrdocmto => nvl(vr_nrdocmto, 0),
                                                      pr_cdhistor => (CASE pr_tpopechq WHEN 1 THEN 2973 ELSE 399 END), 
                                                      pr_vllanmto => rw_crapfdc.vlcheque, 
                                                      pr_cdcooper => pr_cdcoopdp, 
                                                      pr_cdbanchq => rw_crapfdc.cdbanchq, 
                                                      pr_cdagechq => rw_crapfdc.cdagechq, 
                                                      pr_nrctachq => rw_crapfdc.nrctachq,
                                                      pr_cdpesqbb => vr_cdalinea, 
                                                      pr_cdcoptfn => 0,
                                                      pr_dsidenti => 2,
                                                      pr_tab_retorno => vr_tab_retorno,
                                                      pr_inprolot => 1,
                                                      pr_incrineg => vr_incrineg,
                                                      pr_cdcritic => pr_cdcritic,
                                                      pr_dscritic => pr_dscritic); 
                                                      
                 -- Retornando nome do módulo logado
                 GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_trata_devolucao_cheque');                                                               
               
               END IF; -- Conta do depositante informada                                   
              
        -- Seta nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_gera_pesq_deposito_cheque');
           
        pc_gera_pesq_deposito_cheque(pr_cdcooper => pr_cdcoopch
                                    ,pr_cdcmpchq => pr_cdcmpchq  
                                    ,pr_cdbanchq => pr_cdbanchq      
                                    ,pr_cdagechq => pr_cdagechq    
                                    ,pr_nrctachq => pr_nrctachq
                                    ,pr_nrcheque => pr_nrcheque 
                                    ,pr_dtmvtopr => pr_rw_crapdat.dtmvtopr
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_dscritic => pr_dscritic);        
            
        -- Retornando nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_trata_devolucao_cheque');                   
          END IF; -- Alinea <> 0  
        ELSE
          IF cr_crapfdc%ISOPEN THEN
            CLOSE cr_crapfdc;   
          END IF;                           
        END IF; -- Achou registro do cheque
      END IF; -- Cooperado está configurado para devolução automática 
    END IF; -- Encontrou registro parametro de devoluçao automática
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic||'CHEQ0003.pc_trata_devolucao_cheque. '||vr_dsparame;
    WHEN OTHERS THEN      
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcoopch);     
 
      pr_cdcritic:= 9999;
      pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                    'CHEQ0003.pc_trata_devolucao_cheque. '||sqlerrm||vr_dsparame||'.';      
  END;  
END pc_trata_devolucao_cheque;

-- Trata a devolução de cheques da mesma cooperativa, no momento da liberação da custódia
PROCEDURE pc_efetiva_devchq_depositante(pr_cdcoopch IN crapchd.cdcooper%TYPE  --> Cooperativa emitente cheque
                                       ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                       ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                       ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                       ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                       ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE  --> Data da compensação
                                       ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                       ,pr_cdcoopdp IN crapchd.cdcooper%TYPE  --> Cooperativa da conta do depositante
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da conta depositante
                                       ,pr_cdagenci IN craplot.cdagenci%TYPE  --> Agência lote lançamento depositante
                                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE  --> 
                                       ,pr_nrdolote IN craplot.nrdolote%TYPE  --> Número do lote do lançamento depositante
                                       ,pr_tpopechq IN pls_integer            --> 1 - Custódia / 2 - Desconto 		                                     
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS
                                  
   -- Verificar se devolucao é automatica
   CURSOR cr_tbchq_param_conta(pr_cdcooper crapcop.cdcooper%TYPE
                              ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT tbchq.flgdevolu_autom
      FROM tbchq_param_conta tbchq
     WHERE tbchq.cdcooper = pr_cdcooper
       AND tbchq.nrdconta = pr_nrdconta;
    rw_tbchq_param_conta cr_tbchq_param_conta%ROWTYPE;
    
    --Cursor para encontrar as folhas de cheques
      CURSOR cr_crapfdc(pr_cdcooper crapfdc.cdcooper%TYPE,
                        pr_cdbanchq crapfdc.cdbanchq%TYPE,
                        pr_cdagechq crapfdc.cdagechq%TYPE,
                        pr_nrctachq crapfdc.nrctachq%TYPE,
                        pr_nrcheque crapfdc.nrcheque%TYPE) IS
        SELECT ROWID,
               fdc.nrdconta,
               fdc.incheque,
               fdc.tpcheque,
               fdc.vlcheque,
               fdc.dtemschq,
               fdc.dtretchq,
               fdc.cdbanchq,
               fdc.cdagechq,
               fdc.nrctachq,
               fdc.dtliqchq,
               fdc.nrdigchq
          FROM crapfdc fdc
         WHERE fdc.cdcooper = pr_cdcooper
           AND fdc.cdbanchq = pr_cdbanchq
           AND fdc.cdagechq = pr_cdagechq
           AND fdc.nrctachq = pr_nrctachq
           AND fdc.nrcheque = pr_nrcheque;
      rw_crapfdc cr_crapfdc%ROWTYPE;

      
   vr_cdalinea    crapali.cdalinea%TYPE;
   vr_cdcritic  crapcri.cdcritic%TYPE;
   vr_dscritic  VARCHAR2(4000);   
   vr_dsparame  varchar2(4000);
   vr_exc_erro  EXCEPTION;   
   vr_tab_retorno lanc0001.typ_reg_retorno;  
   vr_incrineg  INTEGER;
   vr_nrdocmto    craplcm.nrdocmto%TYPE;
       
BEGIN
  -- Incluido nome do módulo logado
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_trata_devchq_depositante');
  
  --Inicializar variaveis critica
  vr_cdcritic := 0;
  vr_dscritic := NULL;
  
  -- Agrupa os parâmetros
  vr_dsparame := 'pr_cdcoopch:' || pr_cdcoopch ||
                 ' ,pr_cdbanchq:' || pr_cdbanchq  ||
                 ' ,pr_cdagechq:' || pr_cdagechq  ||
                 ' ,pr_nrctachq:' || pr_nrctachq  ||
                 ' ,pr_nrcheque:' || pr_nrcheque  ||
                 ' ,pr_dtmvtolt:' || pr_dtmvtolt  ||
                 ' ,pr_cdcmpchq:' || pr_cdcmpchq  ||
                 ' ,pr_cdcoopdp:' || pr_cdcoopdp  ||
                 ' ,pr_nrdconta:' || pr_nrdconta  ||
                 ' ,pr_cdagenci:' || pr_cdagenci  ||
                 ' ,pr_cdbccxlt:' || pr_cdbccxlt  ||
                 ' ,pr_nrdolote:' || pr_nrdolote  ||                                  
                 ' ,pr_tpopechq:' || pr_tpopechq;
  
 
  BEGIN
    IF cr_tbchq_param_conta%ISOPEN THEN
      CLOSE cr_tbchq_param_conta;  
    END IF;                         
                          
    OPEN cr_tbchq_param_conta(pr_cdcooper => pr_cdcoopch
                             ,pr_nrdconta => pr_nrctachq);
    FETCH cr_tbchq_param_conta INTO rw_tbchq_param_conta;                                      
    CLOSE cr_tbchq_param_conta;                        
    -- Caso encontre registro de devolucao automatica  
    IF rw_tbchq_param_conta.flgdevolu_autom is not null THEN
      -- se for devolucao automatica
      IF rw_tbchq_param_conta.flgdevolu_autom = 1 THEN 
        OPEN cr_crapfdc (pr_cdcooper => pr_cdcoopch
                                       ,pr_cdbanchq => pr_cdbanchq
                                       ,pr_cdagechq => pr_cdagechq
                                       ,pr_nrctachq => pr_nrctachq
                                       ,pr_nrcheque => pr_nrcheque);
        --Posicionar no primeiro registro
        FETCH cr_crapfdc INTO rw_crapfdc;
        IF cr_crapfdc%FOUND THEN
          CLOSE cr_crapfdc;
          -- Lança movimento Devolução na conta do depositante                                 
          vr_nrdocmto := fn_gera_nr_docto(pr_cdcooper => pr_cdcoopdp
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_cdbccxlt => pr_cdbccxlt
                                   ,pr_nrdolote => pr_nrdolote
                                   ,pr_nrdctabb => pr_nrdconta
                                   ,pr_nrdocmto => pr_nrcheque
                                   ,pr_nrdigchq => rw_crapfdc.nrdigchq
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
  
          Lanc0001.pc_gerar_lancamento_conta( pr_dtmvtolt => pr_dtmvtolt, 
                                              pr_dtrefere => pr_dtmvtolt, 
                                              pr_cdagenci => pr_cdagenci,
                                              pr_cdbccxlt => pr_cdbccxlt, 
                                              pr_nrdolote => pr_nrdolote,
                                              pr_nrdconta => pr_nrdconta, 
                                              pr_nrdctabb => pr_nrdconta,
                                              pr_nrdocmto => nvl(vr_nrdocmto, 0),
                                              pr_cdhistor => (CASE pr_tpopechq WHEN 1 THEN 2973 ELSE 399 END), -- Quando devolução contra ordem tambem por Historico 2973
                                              pr_vllanmto => rw_crapfdc.vlcheque, 
                                              pr_cdcooper => pr_cdcoopdp, 
                                              pr_cdbanchq => rw_crapfdc.cdbanchq, 
                                              pr_cdagechq => rw_crapfdc.cdagechq, 
                                              pr_nrctachq => rw_crapfdc.nrctachq,
                                              pr_cdpesqbb => vr_cdalinea, 
                                              pr_cdcoptfn => 0,
                                              pr_dsidenti => 2,
                                              pr_tab_retorno => vr_tab_retorno,
                                              pr_inprolot => 1,
                                              pr_incrineg => vr_incrineg,
                                              pr_cdcritic => pr_cdcritic,
                                              pr_dscritic => pr_dscritic); 
                                                      
           -- Retornando nome do módulo logado
           GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_efetiva_devchq_depositante'); 
        ELSE
          IF cr_crapfdc%ISOPEN THEN
            CLOSE cr_crapfdc;   
          END IF;                                                                           
        END IF; -- Achou registro do cheque
      END IF; -- Cooperado está configurado para devolução automática 
    END IF; -- Encontrou registro parametro de devoluçao automática
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic||'CHEQ0003.pc_efetiva_devchq_depositante. '||vr_dsparame;
    WHEN OTHERS THEN      
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcoopch);     
 
      pr_cdcritic:= 9999;
      pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                    'CHEQ0003.pc_efetiva_devchq_depositante. '||sqlerrm||vr_dsparame||'.';      
  END;  
END pc_efetiva_devchq_depositante;
                            
-- Procedimento para inserir o registro de cheque na crapchd para ser possível consultar na tela PESQDP
PROCEDURE pc_gera_pesq_deposito_cheque(pr_cdcooper IN crapchd.cdcooper%TYPE  --> Cooperativa emitente cheque
                                      ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                      ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                      ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                      ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                      ,pr_nrcheque IN crapchd.nrcheque%TYPE
                                      ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS

    --Selecionar Custodia de Cheques
    CURSOR cr_crapcst   (pr_cdcooper IN crapfdc.cdcooper%TYPE
                        ,pr_cdcmpchq IN crapfdc.cdcmpchq%TYPE
                        ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE
                        ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                        ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                        ,pr_nrcheque IN crapfdc.nrcheque%TYPE) IS
      SELECT  crapcst.cdagechq      
             ,crapcst.cdagenci
             ,crapcst.cdbanchq
             ,crapcst.cdbccxlt
             ,crapcst.cdcmpchq
             ,crapcst.cdoperad
             ,crapcst.dsdocmc7
             ,crapcst.dtmvtolt
             ,crapcst.inchqcop
             ,crapcst.cdcooper
             ,crapcst.insitchq
             ,crapcst.nrcheque
             ,crapcst.nrctachq
             ,crapcst.nrdconta
             ,crapcst.nrddigc1
             ,crapcst.nrddigc2
             ,crapcst.nrddigc3
             ,crapcst.nrdocmto
             ,crapcst.nrdolote
             ,crapcst.nrseqdig
             ,crapcst.vlcheque
             ,crapcst.nrborder
             ,crapcst.insitprv
        FROM crapcst crapcst
       WHERE crapcst.cdcooper = pr_cdcooper
         AND crapcst.cdcmpchq = pr_cdcmpchq
         AND crapcst.cdbanchq = pr_cdbanchq
         AND crapcst.cdagechq = pr_cdagechq
         AND crapcst.nrctachq = pr_nrctachq
         AND crapcst.nrcheque = pr_nrcheque;
    rw_crapcst cr_crapcst%ROWTYPE;

    --Selecionar Cheques Contidos do Bordero de desconto de cheques
    CURSOR cr_crapcdb   (pr_cdcooper IN crapfdc.cdcooper%TYPE
                        ,pr_cdcmpchq IN crapfdc.cdcmpchq%TYPE
                        ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE
                        ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                        ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                        ,pr_nrcheque IN crapfdc.nrcheque%TYPE) IS
      SELECT  crapcdb.cdagechq      
             ,crapcdb.cdagenci
             ,crapcdb.cdbanchq
             ,crapcdb.cdbccxlt
             ,crapcdb.cdcmpchq
             ,crapcdb.cdoperad
             ,crapcdb.dsdocmc7
             ,crapcdb.dtmvtolt
             ,crapcdb.inchqcop
             ,crapcdb.cdcooper
             ,crapcdb.insitchq
             ,crapcdb.nrcheque
             ,crapcdb.nrctachq
             ,crapcdb.nrdconta
             ,crapcdb.nrddigc1
             ,crapcdb.nrddigc2
             ,crapcdb.nrddigc3
             ,crapcdb.nrdocmto
             ,crapcdb.nrdolote
             ,crapcdb.nrseqdig
             ,crapcdb.vlcheque
        FROM crapcdb crapcdb
       WHERE crapcdb.cdcooper = pr_cdcooper
         AND crapcdb.cdcmpchq = pr_cdcmpchq
         AND crapcdb.cdbanchq = pr_cdbanchq
         AND crapcdb.cdagechq = pr_cdagechq
         AND crapcdb.nrctachq = pr_nrctachq
         AND crapcdb.nrcheque = pr_nrcheque;
    rw_crapcdb cr_crapcdb%ROWTYPE;
    
    tab_vlchqmai  NUMBER;
    tab_incrdcta  pls_integer;
    tab_intracst  pls_integer; 
    tab_inchqcop  pls_integer; 
  
    vr_inserir    BOOLEAN;
    vr_nrdcampo   NUMBER;
    vr_lsdigctr   VARCHAR2(2000);
    vr_dstextab   VARCHAR2(2000);
    vr_dsparame   varchar2(4000);
    
    vr_cdagechq   crapcst.cdagechq%TYPE;      
    vr_cdagenci   crapcst.cdagenci%TYPE;
    vr_cdbanchq   crapcst.cdbanchq%TYPE;
    vr_cdbccxlt   crapcst.cdbccxlt%TYPE;
    vr_cdcmpchq   crapcst.cdcmpchq%TYPE;
    vr_cdoperad   crapcst.cdoperad%TYPE;
    vr_dsdocmc7   crapcst.dsdocmc7%TYPE;
    vr_dtmvtolt   crapcst.dtmvtolt%TYPE;
    vr_inchqcop   crapcst.inchqcop%TYPE;
    vr_cdcooper   crapcst.cdcooper%TYPE;
    vr_insitchq   crapcst.insitchq%TYPE;
    vr_nrcheque   crapcst.nrcheque%TYPE;
    vr_nrctachq   crapcst.nrctachq%TYPE;
    vr_nrdconta   crapcst.nrdconta%TYPE;
    vr_nrddigc1   crapcst.nrddigc1%TYPE;
    vr_nrddigc2   crapcst.nrddigc2%TYPE;
    vr_nrddigc3   crapcst.nrddigc3%TYPE;
    vr_nrdocmto   crapcst.nrdocmto%TYPE;
    vr_nrdolote   crapcst.nrdolote%TYPE;
    vr_nrseqdig   crapcst.nrseqdig%TYPE;
    vr_vlcheque   crapcst.vlcheque%TYPE;    
    vr_insitprv   crapcst.insitprv%TYPE;   
    vr_cdsitatu   crapchd.cdsitatu%TYPE;
    vr_nrterfin   crapchd.nrterfin%TYPE;
    vr_cdtipchq   crapchd.cdtipchq%TYPE;
    vr_tpdmovto   crapchd.tpdmovto%TYPE;     
    vr_nrddigv1   crapchd.nrddigv1%TYPE; 
    vr_nrddigv2   crapchd.nrddigv2%TYPE;
    vr_nrddigv3   crapchd.nrddigv3%TYPE;

BEGIN
  -- Incluido nome do módulo logado
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_gera_pesq_deposito_cheque');
  
  --Inicializar variaveis critica
  pr_cdcritic := 0;
  pr_dscritic := NULL;
  
  -- Agrupa os parâmetros
  vr_dsparame := 'pr_cdcooper:' || pr_cdcooper ||
                 ' ,pr_cdcmpchq:' || pr_cdcmpchq  ||
                 ' ,pr_cdbanchq:' || pr_cdbanchq  ||
                 ' ,pr_cdagechq:' || pr_cdagechq  ||
                 ' ,pr_nrctachq:' || pr_nrctachq  ||
                 ' ,pr_nrcheque:' || pr_nrcheque;
  
  -- Iniciar Variáveis     
  tab_vlchqmai := 0;
 
  BEGIN
    --Selecionar Custodia do Cheque
    OPEN cr_crapcst (pr_cdcooper => pr_cdcooper
                    ,pr_cdcmpchq => pr_cdcmpchq
                    ,pr_cdbanchq => pr_cdbanchq
                    ,pr_cdagechq => pr_cdagechq
                    ,pr_nrctachq => pr_nrctachq
                    ,pr_nrcheque => pr_nrcheque);
    --Posicionar na primeira linha
    FETCH cr_crapcst INTO rw_crapcst;
    --Fechar Cursor
    CLOSE cr_crapcst;
    
    --Se encontrou custodia
    IF rw_crapcst.nrctachq IS NOT NULL THEN
       vr_inserir := TRUE;
       vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'USUARI'
                                                ,pr_cdempres => 11
                                                ,pr_cdacesso => 'MAIORESCHQ'
                                                ,pr_tpregist => 001);
                 
       tab_vlchqmai := to_number(SUBSTR(vr_dstextab,1,15));
       
       IF nvl(rw_crapcst.nrborder,0) = 0 THEN -- Se for custódia
         vr_cdagechq := rw_crapcst.cdagechq;      
         vr_cdagenci := 1;
         vr_cdbanchq := rw_crapcst.cdbanchq;
         vr_cdbccxlt := rw_crapcst.cdbccxlt;
         vr_cdcmpchq := rw_crapcst.cdcmpchq;
         vr_cdoperad := rw_crapcst.cdoperad;
         vr_cdsitatu := 1;
         vr_dsdocmc7 := rw_crapcst.dsdocmc7;
         vr_dtmvtolt := pr_dtmvtopr;
         vr_inchqcop := rw_crapcst.inchqcop;
         vr_cdcooper := pr_cdcooper;
         vr_nrcheque := rw_crapcst.nrcheque;
         
         IF (rw_crapcdb.cdbanchq = 1)THEN
             vr_nrctachq := to_number(substr(rw_crapcdb.dsdocmc7,23,10));
         ELSE
             vr_nrctachq := rw_crapcst.nrctachq;
         END IF;
         
         vr_nrdconta := rw_crapcst.nrdconta;
         vr_nrddigc1 := rw_crapcst.nrddigc1;
         vr_nrddigc2 := rw_crapcst.nrddigc2;
         vr_nrddigc3 := rw_crapcst.nrddigc3;
         vr_nrdocmto := rw_crapcst.nrdocmto;
         vr_nrdolote := 999999;
         vr_nrseqdig := rw_crapcst.nrseqdig;
         vr_nrterfin := 0;
         vr_cdtipchq := TO_NUMBER(SUBSTR(rw_crapcst.dsdocmc7,20,1));
         vr_vlcheque := rw_crapcst.vlcheque; 
         vr_insitprv := rw_crapcst.insitprv;
         
         vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'CUSTOD'
                                                  ,pr_cdempres => 00
                                                  ,pr_cdacesso => to_char(rw_crapcst.nrdconta)
                                                  ,pr_tpregist => 0);

         IF vr_dstextab IS NULL   THEN
            tab_incrdcta := 1;
            tab_intracst := 1;   /*  Tratamento comp. CREDIHERING  */
            tab_inchqcop := 1;
         ELSE
            tab_incrdcta := TO_NUMBER(SUBSTR(vr_dstextab,05,01));
            tab_intracst := TO_NUMBER(SUBSTR(vr_dstextab,07,01));
            tab_inchqcop := TO_NUMBER(SUBSTR(vr_dstextab,09,01));
         END IF;   

         IF rw_crapcst.inchqcop = 1   THEN   /*  Cheque CREDIHERING  */
           IF tab_incrdcta = 2   THEN        /*  Nao Credita em CC  */
             IF tab_intracst = 2   THEN      /*  Comp. Terceiros  */
                IF tab_inchqcop = 1   THEN   /*  Nao trata chq CREDIHERING */
                  vr_inserir := FALSE; 
                END IF;
             ELSE
               vr_inserir := FALSE; 
             END IF; 
           END IF;   
         END IF;    
         
         IF tab_intracst = 2 THEN
           IF rw_crapcst.inchqcop = 1 THEN
             IF tab_inchqcop = 1 THEN
                vr_insitchq := rw_crapcst.insitchq;
             ELSE 
                vr_insitchq := 3;
             END IF;
           ELSE 
             vr_insitchq := 3;
           END IF;
         ELSE 
           vr_insitchq := rw_crapcst.insitchq ;
         END IF;   
       ELSE
        --Selecionar Desconto do Cheque
        OPEN cr_crapcdb (pr_cdcooper => pr_cdcooper
                        ,pr_cdcmpchq => pr_cdcmpchq
                        ,pr_cdbanchq => pr_cdbanchq
                        ,pr_cdagechq => pr_cdagechq
                        ,pr_nrctachq => pr_nrctachq
                        ,pr_nrcheque => pr_nrcheque);
        FETCH cr_crapcdb INTO rw_crapcdb;
        --Fechar Cursor
        CLOSE cr_crapcdb;
             
        IF rw_crapcdb.nrctachq IS NOT NULL THEN -- Se encontrou Desconto do Cheque
           vr_cdagechq := rw_crapcdb.cdagechq;      
           vr_cdagenci := 1;
           vr_cdbanchq := rw_crapcdb.cdbanchq;
           vr_cdbccxlt := rw_crapcdb.cdbccxlt;
           vr_cdcmpchq := rw_crapcdb.cdcmpchq;
           vr_cdoperad := rw_crapcdb.cdoperad;
           vr_cdsitatu := 1;
           vr_dsdocmc7 := rw_crapcdb.dsdocmc7;
           vr_dtmvtolt := pr_dtmvtopr;
           vr_inchqcop := rw_crapcdb.inchqcop;
           vr_cdcooper := rw_crapcdb.cdcooper;
           vr_insitchq := rw_crapcdb.insitchq;
           vr_nrcheque := rw_crapcdb.nrcheque;
           
           IF (rw_crapcdb.cdbanchq = 1) AND
              (rw_crapcdb.inchqcop = 0) THEN
             vr_nrctachq := to_number(substr(rw_crapcdb.dsdocmc7,23,10));
           ELSE
             vr_nrctachq := rw_crapcdb.nrctachq;
           END IF;
           
           vr_nrdconta := rw_crapcdb.nrdconta;
           vr_nrddigc1 := rw_crapcdb.nrddigc1;
           vr_nrddigc2 := rw_crapcdb.nrddigc2;
           vr_nrddigc3 := rw_crapcdb.nrddigc3;
           vr_nrdocmto := rw_crapcdb.nrdocmto;
           vr_nrdolote := 888888;
           vr_nrseqdig := rw_crapcdb.nrseqdig;
           vr_nrterfin := 0;
           vr_cdtipchq := to_number(substr(rw_crapcdb.dsdocmc7,20,1));
           vr_vlcheque := rw_crapcdb.vlcheque;
           vr_insitprv := 0;
         ELSE
           vr_inserir := FALSE;
         END IF;
       END IF;
       
      IF vr_inserir THEN
             
         cheq0001.pc_dig_cmc7(vr_dsdocmc7, vr_nrdcampo, vr_lsdigctr);  
         vr_nrddigv1 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(1,vr_lsdigctr,',')));   
         vr_nrddigv2 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(2,vr_lsdigctr,','))); 
         vr_nrddigv3 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(3,vr_lsdigctr,','))); 
               
         IF tab_vlchqmai <= vr_vlcheque THEN
             vr_tpdmovto := 1;
         ELSE        
             vr_tpdmovto := 2;
         END IF;  
                
              
         INSERT INTO crapchd (cdagechq, 
                              cdagenci, 
                              cdbanchq, 
                              cdbccxlt, 
                              cdcmpchq, 
                              cdoperad, 
                              cdsitatu, 
                              dsdocmc7,
                              dtmvtolt, 
                              inchqcop, 
                              cdcooper, 
                              insitchq, 
                              nrcheque, 
                              nrctachq, 
                              nrdconta, 
                              nrddigc1,
                              nrddigc2, 
                              nrddigc3, 
                              nrddigv1, 
                              nrddigv2, 
                              nrddigv3, 
                              nrdocmto, 
                              nrdolote, 
                              nrseqdig,
                              nrterfin, 
                              cdtipchq, 
                              tpdmovto, 
                              vlcheque, 
                              insitprv)
                      VALUES
                             (vr_cdagechq     
                              ,vr_cdagenci
                              ,vr_cdbanchq
                              ,vr_cdbccxlt
                              ,vr_cdcmpchq
                              ,vr_cdoperad
                              ,vr_cdsitatu
                              ,vr_dsdocmc7
                              ,vr_dtmvtolt
                              ,vr_inchqcop
                              ,vr_cdcooper
                              ,vr_insitchq
                              ,vr_nrcheque
                              ,vr_nrctachq
                              ,vr_nrdconta
                              ,vr_nrddigc1
                              ,vr_nrddigc2
                              ,vr_nrddigc3
                              ,vr_nrddigv1
                              ,vr_nrddigv2
                              ,vr_nrddigv3
                              ,vr_nrdocmto
                              ,vr_nrdolote
                              ,vr_nrseqdig
                              ,vr_nrterfin
                              ,vr_cdtipchq
                              ,vr_tpdmovto
                              ,vr_vlcheque	 
                              ,vr_insitprv); 
                            
          END IF;       
       
     END IF;  -- rw_crapcst.nrctachq IS NOT NULL

  EXCEPTION
    WHEN OTHERS THEN      
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
   
      pr_cdcritic:= 9999;
      pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                    'CHEQ0003.pc_gera_pesq_deposito_cheque. '||sqlerrm||vr_dsparame||'.';      
  END;        
END;

  -- Rotina para atualizar os códigos HASH e SEGURANÇA na tabela tbchq_seguranca_cheque e também ATUALIZAR o STATUS para processado ou erro
  PROCEDURE pc_atualiza_cod_seguranca_chq(pr_cdcooper     IN tbchq_seguranca_cheque.cdcooper%TYPE
                                         ,pr_cdbanchq     IN tbchq_seguranca_cheque.cdbanchq%TYPE
                                         ,pr_cdagechq     IN tbchq_seguranca_cheque.cdagechq%TYPE
                                         ,pr_nrctachq     IN tbchq_seguranca_cheque.nrctachq%TYPE
                                         ,pr_nrcheque     IN tbchq_seguranca_cheque.nrcheque%TYPE
                                         ,pr_cdhashcode   IN tbchq_seguranca_cheque.cdhashcode%TYPE
                                         ,pr_cdseguranca  IN tbchq_seguranca_cheque.cdseguranca%TYPE
                                         ,pr_cdcritic     OUT crapcri.cdcritic%TYPE
                                         ,pr_dscritic     OUT crapcri.dscritic%TYPE
                                         ) IS
                                         
  BEGIN
    
    IF pr_cdhashcode IS NULL THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi informado o Hash Code.';
      return;
    elsif pr_cdseguranca  IS NULL THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi informado o codigo de seguranca.';
      return;
    end if;
 
   UPDATE tbchq_seguranca_cheque a
    SET a.cdhashcode = pr_cdhashcode,
        a.cdseguranca = pr_cdseguranca,
        a.idstatus_atualizacao_hsm = 2
    WHERE a.cdcooper = pr_cdcooper
      AND a.cdbanchq = pr_cdbanchq
      AND a.cdagechq = pr_cdagechq
      AND a.nrctachq = pr_nrctachq
      AND a.nrcheque = pr_nrcheque;
      
    pr_cdcritic := 0;
    pr_dscritic := null;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na atualizacao do código de segurança: '||pr_cdcooper||'/'||pr_cdbanchq||'/'||pr_cdagechq||'/'||pr_nrctachq||'/'||
      pr_nrcheque||'. '||SQLERRM;
      
  END pc_atualiza_cod_seguranca_chq;

  -- Rotina para atualizar os códigos HASH e SEGURANÇA na tabela tbchq_seguranca_cheque e também ATUALIZAR o STATUS para processado ou erro
  PROCEDURE pc_verifica_pendencia_cod_seg(pr_cdcooper     IN tbchq_seguranca_cheque.cdcooper%TYPE
                                         ,pr_cdbanchq     IN tbchq_seguranca_cheque.cdbanchq%TYPE
                                         ,pr_cdagechq     IN tbchq_seguranca_cheque.cdagechq%TYPE
                                         ,pr_nrctachq     IN tbchq_seguranca_cheque.nrctachq%TYPE
                                         ,pr_nrcheque     IN tbchq_seguranca_cheque.nrcheque%TYPE
                                         ,pr_idprocessado OUT NUMBER -- retorna 0 se ainda tem registros pendentes, ou 1 para TODOS PROCESSADOS
                                         ,pr_cdcritic     OUT crapcri.cdcritic%TYPE
                                         ,pr_dscritic     OUT crapcri.dscritic%TYPE
                                         ) IS
   CURSOR cr_verifica_pendencia IS
    SELECT count(*)
    FROM tbchq_seguranca_cheque a
    WHERE a.idstatus_atualizacao_hsm = 0;--0-hsm nao solicitado, 1-hsm solicitado, 2-hsm obtido com sucesso, 3-erro na obtencao do hsm.
   rw_verifica_pendencia cr_verifica_pendencia%ROWTYPE;
                                         
  BEGIN

     OPEN cr_verifica_pendencia;
     FETCH cr_verifica_pendencia INTO rw_verifica_pendencia;
     IF cr_verifica_pendencia%NOTFOUND THEN
       pr_idprocessado := 1;
     ELSE
       pr_idprocessado := 0;
     END IF;

    pr_cdcritic := 0;
    pr_dscritic := null;

  END pc_verifica_pendencia_cod_seg;

  PROCEDURE pc_gera_crapfdc (pr_cdcooper in craptab.cdcooper%TYPE
                            ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                            ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                            ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                            ,pr_cdcritic out crapcri.cdcritic%TYPE
                            ,pr_dscritic out varchar2) as

  -- Data do movimento
  cursor cr_crapdat(pr_cdcooper in craptab.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;

  -- Cursor para buscar os dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper in crapcop.cdcooper%type) is
    select crapcop.nmextcop,
           crapcop.cdageitg,
           crapcop.cdagebcb,
           crapcop.cdagectl,
           crapcop.cdbcoctl,
           crapcop.nmrescop,
           crapcop.dsendcop,
           crapcop.nrendcop,
           crapcop.nmbairro,
           crapcop.nrtelvoz,
           crapcop.nmcidade,
           crapcop.cdufdcop,
           crapcop.nrdocnpj
      from crapcop
     where crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Cursor para buscar os dados do ultimo cheque
  CURSOR cr_craptab(pr_cdcooper in craptab.cdcooper%type) is
    SELECT dstextab
      FROM craptab
     WHERE craptab.cdcooper = pr_cdcooper
      AND  upper(craptab.nmsistem) = 'CRED'
      AND  upper(craptab.tptabela) = 'GENERI'
      AND  craptab.cdempres = 0
      AND  upper(craptab.cdacesso) = 'NUMULTCHEQ'
      AND  craptab.tpregist = 0;
  rw_craptab cr_craptab%ROWTYPE;

  -- Codigo do programa
  vr_cdprogra      crapprg.cdprogra%type:='CRPS408';
  
  -- Lista Endereco de Email RRD
  vr_email_dest    VARCHAR2(4000) := NULL;

  -- Tratamento de erros
  vr_exc_fimprg    EXCEPTION;
  vr_exc_saida     EXCEPTION;

  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;

  -- Codigo da Empresa a ser Impresso os Cheques
  vr_cdempres      NUMBER := 0;
  vr_cdempres2     NUMBER := 0;
  vr_nmempres      VARCHAR2(20);

  -- Quantidade de Linhas no Arquivo
  vr_cdacesso      VARCHAR2(30);

  vr_dscomora  VARCHAR2(1000);
  vr_dsdirbin  VARCHAR2(1000);

  -- Variaveis envio SFTP
  vr_serv_sftp  VARCHAR2(100);
  vr_user_sftp  VARCHAR2(100);
  vr_pass_sftp  VARCHAR2(100);
  vr_comando    VARCHAR2(4000);
  vr_typ_saida  VARCHAR2(3);
  vr_dir_remoto VARCHAR2(4000);
  vr_script     VARCHAR2(4000);
  vr_des_saida  VARCHAR2(4000);
  
  vr_possuipr   VARCHAR2(1);
  vr_inimpede_talionario tbcc_situacao_conta_coop.inimpede_talionario%TYPE;
  vr_arquivo_zip   VARCHAR2(200);
  

  -- Subrotina que vai gerar o relatorio sobre o talonario
  PROCEDURE Pc_Gera_Talonario(pr_cdcooper     IN crapreq.cdcooper%TYPE,
                              pr_cdbanchq     IN crapass.cdbcochq%TYPE,
                              pr_nrcontab     IN NUMBER,
                              pr_nrdserie     IN NUMBER,
                              pr_nmarqui1     IN VARCHAR2,
                              pr_nmarqui2     IN VARCHAR2,
                              pr_nmarqui3     IN VARCHAR2,
                              pr_nmarqui4     IN VARCHAR2,
                              pr_flg_impri    IN VARCHAR2,
                              pr_cdempres     IN gnsequt.cdsequtl%TYPE,
                              pr_tprequis     IN crapreq.tprequis%type) IS

    -- Cursor para leitura de requisicoes de talonarios
    CURSOR cr_crapreq(pr_cdcooper     IN crapreq.cdcooper%TYPE,
                      pr_cdbanchq     IN crapcop.cdbcoctl%TYPE,
                      pr_tprequis     IN crapreq.tprequis%TYPE,
                      pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE) IS
      SELECT crapreq.ROWID,
             crapreq.cdagenci,
             crapreq.nrdconta,
             /*CASE 
         WHEN NVL(crapreq.qtreqtal,0) = 0 THEN 1
         ELSE crapreq.qtreqtal
       END AS qtreqtal,*/
             crapreq.qtreqtal,
             crapreq.tprequis,
             crapreq.insitreq,
             crapreq.tpformul,
             crapreq.nrpedido
        FROM crapass,
             crapreq
       WHERE crapreq.cdcooper  = pr_cdcooper
         AND ((crapreq.tprequis  = 1 and pr_tprequis=1)
          OR  ( (crapreq.tprequis = 3 and pr_tprequis=3)
          AND   crapreq.tpformul = 999))         
         AND (crapass.inpessoa, crapreq.cdtipcta) 
          IN (SELECT t.inpessoa
                   , t.tpconta
                FROM tbcc_produtos_coop t
               WHERE t.cdcooper  = pr_cdcooper
                       AND t.cdproduto = 38
                       AND (dtvigencia >= pr_dtmvtolt
                        OR  dtvigencia IS NULL)) -- Folhas de Cheque 
         AND crapreq.insitreq IN (1,4,5)
         AND crapass.cdcooper = crapreq.cdcooper
         AND crapass.nrdconta = crapreq.nrdconta
         AND crapass.cdbcochq = pr_cdbanchq
--         AND NVL(crapreq.qtreqtal, 0) >= 0 -- Somente quando tiver solicitacao de talao
         AND crapreq.qtreqtal > 0 -- Somente quando tiver solicitacao de talao
       ORDER BY crapreq.cdagenci,
                crapreq.nrdconta;

    -- Cursor para buscar os dados da agencia
    CURSOR cr_crapage(pr_cdcooper    IN crapage.cdcooper%TYPE,
                      pr_cdagenci    IN crapage.cdagenci%TYPE) IS
      SELECT crapage.nmresage,
             crapage.cdcomchq,
             crapage.dsinform##1,
             crapage.dsinform##2,
             crapage.dsinform##3
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;

    -- Cursor sobre os associados
    CURSOR cr_crapass(pr_cdcooper    IN crapass.cdcooper%TYPE,
                      pr_nrdconta    IN crapass.nrdconta%TYPE) IS
      SELECT ROWID,
             nrdconta,
             nrdctitg,
             flchqitg,
             nrflcheq,
             qtfoltal,
             nmprimtl,
             cdtipcta,
             cdsitdtl,
             inlbacen,
             dtdemiss,
             cdsitdct,
             flgctitg,
             inpessoa,
             nrcpfcgc,
             tpdocptl,
             nrdocptl,
             idorgexp,
             cdufdptl,
             dtabtcct,
             dtadmiss,
             cdcatego
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor sobre os titulares da conta para pessoa fisica
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE,
                      pr_idseqttl IN crapttl.idseqttl%TYPE) IS
      SELECT nmtalttl
            ,nmextttl
        FROM crapttl
       WHERE crapttl.cdcooper  = pr_cdcooper
         AND crapttl.nrdconta  = pr_nrdconta
         AND crapttl.idseqttl >= pr_idseqttl
       ORDER BY crapttl.idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- Cursor sobre os titulares da conta para pessoa juridica
    CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE,
                      pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT nmtalttl
        FROM crapjur
       WHERE crapjur.cdcooper  = pr_cdcooper
         AND crapjur.nrdconta  = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;

    -- Cursor para buscar o tipo de conta para os rejeitados
    CURSOR cr_tpconta(pr_inpessoa IN tbcc_tipo_conta.inpessoa%TYPE,
                      pr_cdtipcta IN tbcc_tipo_conta.cdtipo_conta%TYPE) IS
      SELECT tip.dstipo_conta
        FROM tbcc_tipo_conta tip
       WHERE tip.inpessoa     = pr_inpessoa
         AND tip.cdtipo_conta = pr_cdtipcta;
    rw_tpconta cr_tpconta%ROWTYPE;

    -- Cursor para buscar o nome do banco
    CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
      SELECT substr(nmresbcc,1,15) nmresbcc
        FROM crapban
       WHERE cdbccxlt = pr_cdbccxlt;

    -- Cursor para buscar a data em que o cooperado é cliente bancário
    CURSOR cr_crapsfn(pr_cdcooper IN crapsfn.cdcooper%TYPE,
                      pr_nrcpfcgc IN crapsfn.nrcpfcgc%TYPE) IS
      SELECT crapsfn.dtabtcct
        FROM crapsfn
       WHERE crapsfn.cdcooper = pr_cdcooper
         AND crapsfn.nrcpfcgc = pr_nrcpfcgc
         AND crapsfn.tpregist = 1
         AND crapsfn.dtabtcct IS NOT NULL
       ORDER BY crapsfn.dtabtcct;
    rw_crapsfn cr_crapsfn%ROWTYPE;

    -- Variavel da agencia anterior do loop de requisicoes;
    vr_cdagenci_ant    crapage.cdagenci%TYPE;
    vr_cdagenci_ant_fc crapage.cdagenci%TYPE;

    -- Variaveis auxiliares
    vr_nrctaitg        crapass.nrdctitg%TYPE;
    vr_nrinichq        crapass.nrflcheq%TYPE;
    vr_nrinichq_fc     crapass.nrflcheq%TYPE;
    vr_nrultchq        crapass.nrflcheq%TYPE;
    vr_nrflcheq        crapass.nrflcheq%TYPE;
    vr_nrflcheq_aux    crapass.nrflcheq%TYPE;
    vr_nrdigchq        crapfdc.nrdigchq%TYPE;
    vr_cdagechq        crapfdc.cdagechq%TYPE;
    vr_dsdocmc7        crapfdc.dsdocmc7%TYPE;
    vr_cdcritic        crapreq.cdcritic%TYPE;
    vr_insitreq        crapreq.insitreq%TYPE;
    vr_nmbanco         crapban.nmresbcc%TYPE;
    vr_retorno         BOOLEAN;
    vr_qttotreq        NUMBER(10);
    vr_qttotreq_tl     NUMBER(10);
    vr_qttotrej_tl     NUMBER(10);
    vr_qttottrf_tl     NUMBER(10);
    vr_qttotreq_fc     NUMBER(10);
    vr_qttotrej_fc     NUMBER(10);
    vr_qttottrf_fc     NUMBER(10);
    vr_qttotchq_tl     NUMBER(10);
    vr_qttottal_tl     NUMBER(10);
    vr_qttottal_fc     NUMBER(10);
    vr_qttotgerreq_fc  NUMBER(10);
    vr_qtreqtal        NUMBER(10);
    vr_dstipreq        VARCHAR2(02);
    vr_dssitdct        VARCHAR2(50);
    vr_dscritic        VARCHAR2(200);
    vr_des_erro        VARCHAR2(200);
    vr_auxiliar        NUMBER(15);
    vr_auxiliar2       NUMBER(15);
    vr_cddigage        NUMBER(01);
    vr_cddigtc1        NUMBER(01);
    vr_nrdctitg        VARCHAR2(07);
    vr_nrdigctb        VARCHAR2(01);
    vr_nrdctitg_aux    crapass.nrdctitg%TYPE;
    vr_nrcpfcgc        VARCHAR2(18);
    vr_tpdocptl        crapass.tpdocptl%TYPE;
    vr_nrdocptl        crapass.nrdocptl%TYPE;
    vr_cdorgexp        tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
    vr_nmorgexp        tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
    vr_cdufdptl        crapass.cdufdptl%TYPE;
    vr_nmprital        crapass.nmprimtl%TYPE;
    vr_nmsegtal        crapttl.nmextttl%TYPE;
    vr_dtabtcc2        DATE;
    vr_literal2        VARCHAR2(200);
    vr_literal3        VARCHAR2(200);
    vr_literal4        VARCHAR2(200);
    vr_literal5        VARCHAR2(200);
    vr_literal6        VARCHAR2(15);
    vr_literal7        VARCHAR2(200);
    vr_literal8        VARCHAR2(200);
    vr_literal9        VARCHAR2(200);
    vr_tpformul        VARCHAR2(02);
    vr_nrfolhas        NUMBER(10);
    vr_nrdigtc2        NUMBER(01);
    vr_dscpfcgc        VARCHAR2(05);
    vr_numtalon        crapass.flchqitg%TYPE;
    vr_dssituacao      tbcc_situacao_conta.dssituacao%TYPE;

    -- Variaveis para geracao do arquivo texto via utl_file
    vr_nmarqped        VARCHAR2(50);
    vr_nmarqtransm     VARCHAR2(50);
    vr_nmarqctrped     VARCHAR2(50);
    vr_nmarqdadped     VARCHAR2(50);
    vr_input_file_dad  utl_file.file_type;
    vr_input_file_ctr  utl_file.file_type;
    vr_lista_nmarq     VARCHAR2(50);

    -- Variável que indica se foi gerado arquivo de requisicao de talao/formulario de cheque
    vr_flggerou        boolean;
    
    -- variavel para verificacao do dia de processamento de envio da requisicao
    vr_dtcalcul        DATE;
    
    -- Número do pedido
    vr_nrpedido        NUMBER;

    TYPE typ_reg_pedido_conta IS
    RECORD (nrpedido_nrdconta    NUMBER);

    --Tipo de tabela para associados
    TYPE tab_reg_pedido_conta IS TABLE OF typ_reg_pedido_conta INDEX BY VARCHAR2(20);

    
    vr_tab_pedido_conta tab_reg_pedido_conta;
    vr_indice           varchar2(20);

    
    -- Controla a alteração da gnsequt
    PROCEDURE pc_altera_gnsequt (pr_cdcritic OUT crapcri.cdcritic%TYPE
                                ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
       
      -- Pragma - abre nova sessão para tratar a atualização
      PRAGMA AUTONOMOUS_TRANSACTION;
     
    BEGIN       
      -- Tenta atualizar o registro de controle de sequencia
      UPDATE gnsequt
         SET gnsequt.vlsequtl = NVL(gnsequt.vlsequtl,0) + 1
       WHERE gnsequt.cdsequtl = 001
       RETURNING gnsequt.vlsequtl INTO vr_nrpedido;

      -- Se não alterar registros, ou alterar mais de 1
      IF SQL%ROWCOUNT = 0 THEN
        -- Faz rollback das informações
        ROLLBACK;
        -- Define o erro
        pr_cdcritic := 151;
        -- Critica 151 - Registro de restart nao encontrado
        RETURN;
      END IF;
       
      -- Comita os dados desta sessão
      COMMIT;
    EXCEPTION 
      WHEN OTHERS THEN 
        -- Retornar erro do update
        pr_dscritic := 'Erro ao atualizar GNSEQUT: '||SQLERRM;
        ROLLBACK; 
    END pc_altera_gnsequt;

  BEGIN        
    
    -- Rotina para controlar a atualização da gnsequt, sem que a mesma fique em lock
    pc_altera_gnsequt (pr_cdcritic => pr_cdcritic
                      ,pr_dscritic => pr_dscritic);
    
    IF NVL(pr_cdcritic,0) > 0 OR pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Busca o codigo da agencia do cheque
    vr_cdagechq := rw_crapcop.cdagectl;

    -- Verifica se ha requisicoes a serem atendidas
    FOR rw_crapreq IN cr_crapreq(pr_cdcooper,
                                 pr_cdbanchq,
                                 pr_tprequis,
                                 vr_dtmvtolt) LOOP

     vr_indice := pr_cdcooper||rw_crapreq.nrdconta;
     if not (vr_tab_pedido_conta.exists(vr_indice)) then

      -- Busca os dados do associado
      OPEN cr_crapass(pr_cdcooper,
                      rw_crapreq.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

      /*   CHEQUE ESPECIAL  */
      CADA0006.pc_permite_produto_tipo (pr_cdprodut => 38
                                       ,pr_cdtipcta => rw_crapass.cdtipcta
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_inpessoa => rw_crapass.inpessoa
                                       ,pr_possuipr => vr_possuipr
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
      
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_cdcritic := 0;
      
      IF vr_possuipr = 'N' THEN
        vr_cdcritic := 65;-- 065 - Tipo de conta nao permite req.
      ELSE 
        vr_cdcritic := 0;
      END IF;

      -- Se não houver rejeição no associado
      IF nvl(vr_cdcritic,0) = 0 THEN
        
        CADA0006.pc_ind_impede_talonario(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => rw_crapass.nrdconta
                                ,pr_inimpede_talionario => vr_inimpede_talionario
                                ,pr_des_erro => vr_des_erro
                                ,pr_dscritic => vr_dscritic);
        IF vr_des_erro = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;
                
        IF vr_inimpede_talionario = 1 THEN -- Se nao houver impedimento para retirada de talionarios
          vr_cdcritic := 18; --018 - Situacao da conta errada.
        ELSIF rw_crapass.cdsitdtl IN (5,6,7,8) THEN --5=NORMAL C/PREJ., 6=NORMAL BLQ.PREJ, 7=DEMITIDO C/PREJ, 8=DEM. BLOQ.PREJ.
          vr_cdcritic := 695; --695 - ATENCAO! Houve prejuizo nessa conta
        ELSIF rw_crapass.cdsitdtl IN (2,4) THEN --2=NORMAL C/BLOQ., 4=DEMITIDO C/BLOQ
          vr_cdcritic := 95; --095 - Titular da conta bloqueado.
        ELSIF rw_crapass.inlbacen <> 0 THEN -- Indicador se o associado consta na lista do Banco Central
          vr_cdcritic := 720; --720 - Associado esta no CCF.
        END IF;
      END IF;

      -- Abre o cursor contendo os titulares da conta, mas somente a segunda pessoa em diante
      OPEN cr_crapttl(pr_cdcooper,
                      rw_crapass.nrdconta,
                      2);
      FETCH cr_crapttl INTO rw_crapttl;
      IF cr_crapttl%FOUND AND NVL(vr_cdcritic,0) = 0 THEN
        IF rw_crapass.cdcatego = 1 THEN --INDIVIDUAL
          vr_cdcritic := 832; --832 - Tipo de conta nao permite MAIS DE UM TITULAR.
        END IF;
      END IF;
      CLOSE cr_crapttl;

      -- Verifica se é formulario continuo
      -- Em caso positivo, faz os processos para o mesmo
      IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN
        -- Verifica se é uma agencia diferente do registro anterior
        IF rw_crapreq.cdagenci <> nvl(vr_cdagenci_ant_fc,-1) THEN

          -- busca o nome da agencia
          OPEN cr_crapage(pr_cdcooper,
                          rw_crapreq.cdagenci);
          FETCH cr_crapage INTO rw_crapage;
          IF cr_crapage%NOTFOUND THEN
            rw_crapage.nmresage := LPAD('*',15,'*');
            rw_crapage.cdcomchq := 16;
          END IF;
          CLOSE cr_crapage;

          -- Zera as variaveis de totais
          vr_qttotreq_fc := 0;
          vr_qttotrej_fc := 0;
          vr_qttottrf_fc := 0;


        END IF; -- If de agencia diferente de formulario continuo

      ELSE -- Se nao for formulario contionuo

        -- Verifica se é uma agencia diferente do registro anterior
        IF rw_crapreq.cdagenci <> nvl(vr_cdagenci_ant,-1) THEN

          -- busca o nome da agencia
          OPEN cr_crapage(pr_cdcooper,
                          rw_crapreq.cdagenci);
          FETCH cr_crapage INTO rw_crapage;
          IF cr_crapage%NOTFOUND THEN
            rw_crapage.nmresage := LPAD('*',15,'*');
            rw_crapage.cdcomchq := 16;
          END IF;
          CLOSE cr_crapage;

        END IF;  -- If de agencia diferente para formulario comum
      END IF;

      -- Se o cooperado nao estiver com situacao de rejeitado
      IF NVL(vr_cdcritic,0) = 0 THEN
        -- Inicializa variavel auxiliar de contados de taloes
        vr_qtreqtal := 1;

        -- Acumula o total de taloes
        IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN -- Se for FC
          vr_qttottal_fc    := vr_qttottal_fc + rw_crapreq.qtreqtal;
          vr_qttotgerreq_fc := vr_qttotgerreq_fc + 1;
          vr_nrinichq_fc    := 0;
        ELSE  -- Se for taloes
          vr_qttottal_tl := vr_qttottal_tl + rw_crapreq.qtreqtal;
        END IF;

        -- Contador para executar a cada solicitacao de talão, pois a mesma requisição pode solicitar mais de um talão
        LOOP
          EXIT WHEN vr_qtreqtal > rw_crapreq.qtreqtal;
          /*
          -- Busca do numero da conta de integracao
          IF pr_cdtipcta_ini = 12 THEN  -- NORMAL ITG
            vr_nrctaitg := rw_crapass.nrdctitg;
          ELSE
            vr_nrctaitg := rw_crapass.nrdconta;
          END IF;
          */
          vr_nrctaitg := rw_crapass.nrdconta;

          -- Atualiza o numero do talao
          rw_crapass.flchqitg := rw_crapass.flchqitg + 1;

          -- Busca o numero da folha inicial do cheque
          vr_nrinichq := (rw_crapass.nrflcheq + 1)*10;
          vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrinichq); -- O retorno é ignorado, pois a variável vr_nrinichq é atualiza pelo programa
          -- Atualiza o número da folha de cheque igualando ao numero da primeira folha de cheque sem o digito
          vr_nrflcheq := trunc(vr_nrinichq/10,0);

          IF vr_nrinichq_fc = 0 THEN
            vr_nrinichq_fc := vr_nrinichq;
          END IF;

          -- Se for Talão, entao busca a quantidade de cheques por talão
          IF  rw_crapreq.tprequis = 1  THEN
              vr_nrultchq := vr_nrflcheq + (rw_crapass.qtfoltal - 1);
          ELSE
              vr_nrultchq := vr_nrflcheq; -- Se for FC, vai ter apenas uma folha de cheque no talão
          END IF;

          -- Rotina para criar a tabela de cadastro de folhas de cheques emitidas para o cooperado.
          LOOP
            -- Calcula o digito do cheque
            vr_nrflcheq_aux := vr_nrflcheq * 10;
            vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrflcheq_aux); -- O retorno é ignorado, pois a variável vr_nrflcheq_aux é atualiza pelo programa
            vr_nrdigchq := MOD(vr_nrflcheq_aux,10);

            -- busca o CMC-7 do cheque
            cheq0001.pc_calc_cmc7_difcompe(pr_cdbanchq => pr_cdbanchq,
                                           pr_cdcmpchq => rw_crapage.cdcomchq,
                                           pr_cdagechq => vr_cdagechq,
                                           pr_nrctachq => vr_nrctaitg,
                                           pr_nrcheque => vr_nrflcheq,
                                           pr_tpcheque => 1,
                                           pr_dsdocmc7 => vr_dsdocmc7,
                                           pr_des_erro => pr_dscritic);
            IF pr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;


            -- Insere na tabela de cadastro de folhas de cheques emitidas para o cooperado.
            BEGIN
              INSERT INTO crapfdc
                (nrdconta,
                 nrdctabb,
                 nrctachq,
                 nrdctitg,
                 nrpedido,
                 nrcheque,
                 nrseqems,
                 nrdigchq,
                 tpcheque,
                 dtemschq,
                 dsdocmc7,
                 cdagechq,
                 cdbanchq,
                 cdcmpchq,
                 cdcooper,
                 dtconchq,
                 tpforchq)
               VALUES
                 (rw_crapass.nrdconta,  --nrdconta
                  vr_nrctaitg,          --nrdctabb
                  vr_nrctaitg,          --nrctachq
                  ' ',                  --nrdctitg
                  vr_nrpedido,          --nrpedido
                  vr_nrflcheq,          --nrcheque
                  rw_crapass.flchqitg,  --nrseqems
                  vr_nrdigchq,          --nrdigchq
                  1,                    --tpcheque
                  NULL,                 --dtemschq
                  vr_dsdocmc7,          --dsdocmc7
                  vr_cdagechq,          --cdagechq
                  pr_cdbanchq,          --cdbanchq
                  rw_crapage.cdcomchq,  --cdcmpchq
                  pr_cdcooper,          --cdcooper
                  vr_dtmvtolt,          --dtconchq
                  decode(rw_crapreq.tprequis,
                           3,'FC'
                            ,'TL'));
            EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao inserir crapfdc na conta '||rw_crapass.nrdconta||' e cheque '||
                             vr_nrflcheq||': '||SQLERRM;
              RAISE vr_exc_saida;
            END;
            BEGIN
              INSERT INTO tbchq_seguranca_cheque (
                 cdcooper, cdbanchq, 
                 cdagechq, nrctachq, 
                 nrcheque, idstatus_atualizacao_hsm, 
                 dserro_atualizacao_hsm, dtcriacao, 
                 dtatualizacao_hsm, cdhashcode, 
                 cdseguranca, tprequis,
                 nrpedido, nrdconta) values (
                 pr_cdcooper, pr_cdbanchq,
                 vr_cdagechq, vr_nrctaitg,
                 vr_nrflcheq, 0,
                 null, sysdate,
                 null, null,
                 null, rw_crapreq.tprequis,
                 vr_nrpedido, vr_nrctaitg);
            EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao inserir tbchq_seguranca_cheque na conta '||rw_crapass.nrdconta||' e cheque '||
                             vr_nrflcheq||': '||SQLERRM;
              RAISE vr_exc_saida;
            END;

            -- Acumula o total de folhas de cheques
            IF NOT (rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999) THEN -- Se for Talao
              vr_qttotchq_tl := vr_qttotchq_tl + 1;
            END IF;

            EXIT WHEN vr_nrflcheq >= vr_nrultchq;
            vr_nrflcheq := vr_nrflcheq + 1;
          END LOOP;

          -- Atualiza o numero da ultima folha de cheque com o digito
          vr_nrultchq := vr_nrultchq*10;
          vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrultchq); -- O retorno é ignorado, pois a variável vr_nrinichq é atualiza pelo programa

          -- Busca o tipo de requisicao
          IF rw_crapreq.tprequis = 3 THEN -- Se for formulario continuo
             vr_dstipreq := 'FC';
          ELSIF rw_crapreq.insitreq = 1 THEN -- Conta existente
             vr_dstipreq := '';
          ELSE
             vr_dstipreq := ' A';  -- CTA NOVA
          END IF;

		  -- Inicializa variaveis
          vr_tpdocptl := ' ';
          vr_nrdocptl := ' ';
          vr_cdorgexp := ' ';
          vr_cdufdptl := ' ';
          vr_nmsegtal := ' ';
          vr_literal6 := ' ';
		  vr_nmprital := rw_crapass.nmprimtl;

		  -- Busca o nome do primeito titular da conta
          IF rw_crapass.inpessoa = 1 THEN -- Se for pessoa fisica

            vr_dscpfcgc := 'CPF: ';
            vr_nrcpfcgc := gene0002.fn_mask(rw_crapass.nrcpfcgc,'999.999.999-99');
            vr_tpdocptl := rw_crapass.tpdocptl;
            vr_nrdocptl := rw_crapass.nrdocptl;
            vr_cdufdptl := rw_crapass.cdufdptl;

            -- Abre o cursor contendo os titulares da conta
            OPEN cr_crapttl(pr_cdcooper,
                            rw_crapass.nrdconta,
                            1);

            FETCH cr_crapttl INTO rw_crapttl;

            IF cr_crapttl%FOUND THEN
              IF nvl(rw_crapttl.nmtalttl,' ') <> ' ' THEN
                vr_nmprital := rw_crapttl.nmtalttl;
              ELSE
                vr_nmprital := rw_crapass.nmprimtl;
              END IF;

              -- Faz mais um fetch para buscar o segundo titular
              FETCH cr_crapttl INTO rw_crapttl;
              IF cr_crapttl%FOUND THEN
                IF nvl(rw_crapttl.nmtalttl,' ') <> ' ' THEN
                  vr_nmsegtal := rw_crapttl.nmtalttl;
                ELSE
                  vr_nmsegtal := rw_crapttl.nmextttl;
                END IF;
              END IF;

            END IF;

            CLOSE cr_crapttl;

          ELSE -- Se for pessoa juridica

            vr_dscpfcgc := 'CNPJ:';
            vr_nrcpfcgc := gene0002.fn_mask(rw_crapass.nrcpfcgc,'99.999.999/9999-99');

            -- Abre o cursor contendo os titulares da conta
            OPEN cr_crapjur(pr_cdcooper,
                            rw_crapass.nrdconta);

            FETCH cr_crapjur INTO rw_crapjur;

            IF cr_crapjur%FOUND THEN
              IF nvl(rw_crapjur.nmtalttl,' ') <> ' ' THEN
                vr_nmprital := rw_crapjur.nmtalttl;
              ELSE
                vr_nmprital := rw_crapass.nmprimtl;
              END IF;

            END IF;

            CLOSE cr_crapjur;

            vr_nmsegtal := ' ';

          END IF;

          rw_crapass.nrflcheq := vr_nrflcheq;
          -- Atualiza o numero do cheque
          BEGIN
            UPDATE crapass
               SET flchqitg = rw_crapass.flchqitg,
                   nrflcheq = vr_nrflcheq
             WHERE ROWID = rw_crapass.rowid;
          EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao marcar atualizar crapass: '||sqlerrm;
            raise vr_exc_saida;
          END;
          -- Indica que foi gerado arquivo de requisicao de talao/formulario de cheque
          vr_flggerou := true;

          /*-----------------------------------------------------*/
          -- Informações para serem geradas no arquivo de detalhe
          /*-----------------------------------------------------*/

          -- Inicializa variaveis
          rw_crapsfn.dtabtcct := NULL;

          -- Define o tipo de formulario
          IF rw_crapreq.tprequis = 1 THEN
            vr_tpformul := 'TL';
            vr_nrfolhas := rw_crapass.qtfoltal;
            vr_numtalon := rw_crapass.flchqitg;
          ELSE
            vr_tpformul := 'FC';
            vr_nrfolhas := rw_crapreq.qtreqtal;
            vr_numtalon := 0;
          END IF;
          
          vr_nrdctitg_aux := rw_crapass.nrdconta;
          vr_nrdctitg := substr(to_char(rw_crapass.nrdconta,'fm00000000'),1,7);
          vr_nrdigctb := substr(rw_crapass.nrdconta,-1,1);

          vr_auxiliar := vr_nrdctitg_aux * 10;
          vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_auxiliar); -- O retorno é ignorado, pois a variável vr_agencia é atualiza pelo programa
          vr_nrdigtc2 := MOD(vr_auxiliar,10);

          --> apenas buscar para pessoa fisica
          IF rw_crapass.inpessoa = 1 THEN
            --> Buscar orgão expedidor
            cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapass.idorgexp, 
                                              pr_cdorgao_expedidor => vr_cdorgexp, 
                                              pr_nmorgao_expedidor => vr_nmorgexp, 
                                              pr_cdcritic          => vr_cdcritic, 
                                              pr_dscritic          => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR 
              TRIM(vr_dscritic) IS NOT NULL THEN
              --> Caso nao encontrar enviar embranco 
              vr_cdorgexp := ' ';
              vr_nmorgexp := NULL; 
            END IF;
          ELSE
            vr_cdorgexp := ' ';
            vr_nmorgexp := NULL;   
          END IF;

            vr_literal2 := vr_nmsegtal;
            vr_literal3 := vr_dscpfcgc ||
                           rpad(vr_nrcpfcgc,18,' ')||
                           rpad(' ',7,' ') ||
                           gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z');
            vr_literal4 := rpad(vr_tpdocptl,3,' ') ||
                           SUBSTR(TRIM(vr_nrdocptl),1,15) || ' '||
                           TRIM(vr_cdorgexp)|| ' '||
                           TRIM(vr_cdufdptl);

          OPEN cr_crapsfn(pr_cdcooper,
                          rw_crapass.nrcpfcgc);
          FETCH cr_crapsfn INTO rw_crapsfn;
          CLOSE cr_crapsfn;

          IF rw_crapass.dtabtcct IS NOT NULL AND -- Se existir data de abertura da conta corrente
             rw_crapass.dtabtcct < rw_crapass.dtadmiss THEN -- Se a data de abertura da CC for menor que a data de admissao na CCOH
            vr_dtabtcc2 := rw_crapass.dtabtcct; -- utiliza a data de abertura da conta
          ELSE
            vr_dtabtcc2 := rw_crapass.dtadmiss; -- Utiliza a data de admissao como associado na CCOH
          END IF;


          IF rw_crapsfn.dtabtcct IS NOT NULL AND -- Se existir data de abertura de conta corrente no sistema financeiro do banco central
             rw_crapsfn.dtabtcct < vr_dtabtcc2 THEN
            vr_literal5 := 'Cliente Bancario desde: '||to_char(rw_crapsfn.dtabtcct,'MM/YYYY')||'   ';
          ELSE
            vr_literal5 := 'Cooperado desde: '||to_char(vr_dtabtcc2,'MM/YYYY')|| '          ';
          END IF;
          
          -- Se o cooperado tem cheque especial habilitado na conta
          IF CADA0003.fn_produto_habilitado(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => rw_crapass.nrdconta
                                           ,pr_cdproduto => 13) = 'S'   THEN
            vr_literal6 := 'CHEQUE ESPECIAL';
          END IF;
          IF nvl(rw_crapage.dsinform##1,' ') = ' ' AND
             nvl(rw_crapage.dsinform##2,' ') = ' ' AND
             nvl(rw_crapage.dsinform##3,' ') = ' ' THEN
            vr_literal7 := rw_crapcop.dsendcop ||','||
                           gene0002.fn_mask(rw_crapcop.nrendcop,'zz,zz9');
            vr_literal8 := rw_crapcop.nmbairro ||  ' - ' ||
                           rw_crapcop.nrtelvoz;
            vr_literal9 := rw_crapcop.nmcidade || ' - '||
                           rw_crapcop.cdufdcop;
          ELSE
            vr_literal7 := rw_crapage.dsinform##1;
            vr_literal8 := rw_crapage.dsinform##2;
            vr_literal9 := rw_crapage.dsinform##3;
          END IF;

          -- Atualiza o contados de requisicoes de talões
          vr_qtreqtal := vr_qtreqtal + 1;
        END LOOP;

        -- Atualiza a variavel de situacao de requisicao para depois atualizar na tabela CRAPREQ
        vr_insitreq := 2;

        -- Acumula o total de requisicoes para ser utilizado na insercao do crapped
        vr_qttotreq := vr_qttotreq + 1;

      ELSE -- Senao dos rejeitados

        -- Abre o cursor de tipo de conta
        OPEN cr_tpconta(pr_cdcooper,
                        rw_crapass.cdtipcta);
        FETCH cr_tpconta INTO rw_tpconta;
        IF cr_tpconta%NOTFOUND THEN
          rw_tpconta.dstipo_conta := '';
        END IF;
        CLOSE cr_tpconta;

        cada0006.pc_descricao_situacao_conta(pr_cdsituacao => rw_crapass.cdsitdct
                                            ,pr_dssituacao => vr_dssituacao
                                            ,pr_des_erro   => vr_des_erro
                                            ,pr_dscritic   => vr_dscritic);
        IF vr_des_erro = 'NOK' THEN
          vr_dssitdct := '';
        ELSE
          vr_dssitdct := rw_crapass.cdsitdct||'-'||vr_dssituacao;
        END IF;

        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);

        -- Atualiza a variavel de situacao de requisicao para depois atualizar na tabela CRAPREQ
        vr_insitreq := 3;
      END IF;

      IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN -- Se for FC
        vr_cdagenci_ant_fc := rw_crapreq.cdagenci;
      ELSE
        vr_cdagenci_ant := rw_crapreq.cdagenci;
      END IF;
      -- Atualiza a situacao da CRAPREQ
      BEGIN
        UPDATE crapreq
           SET insitreq = vr_insitreq,
               dtpedido = vr_dtmvtolt,
               nrpedido = vr_nrpedido,
               cdcritic = decode(vr_cdcritic,0,cdcritic,vr_cdcritic)
         WHERE ROWID = rw_crapreq.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar CRAPREQ para a conta '||rw_crapreq.nrdconta||': '||SQLERRM;
          RAISE vr_exc_saida;
      END;

     vr_indice := to_number(to_char(pr_cdcooper)||to_char(rw_crapreq.nrdconta));
     vr_tab_pedido_conta(vr_indice).nrpedido_nrdconta:= vr_indice;
     end if;

    END LOOP;

    ---------------------------------------------------------------------
    -- Inicio da geração do resumo
    ---------------------------------------------------------------------

    -- Insere no cadatro de pedidos de talonarios
    IF vr_flggerou THEN
      BEGIN
        INSERT INTO crapped
          (cdcooper,
           cdbanchq,
           nrpedido,
           nrseqped,
           dtsolped,
           nrdctabb,
           nrinichq,
           nrfinchq)
        VALUES
          (pr_cdcooper,
           pr_cdbanchq,
           vr_nrpedido,
           1,
           vr_dtmvtolt,
           0,
           0,
           vr_qttotreq);
      EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao inserir crapped no banco '||pr_cdbanchq||': '||SQLERRM;
        RAISE vr_exc_saida;
      END;
    END IF;

      OPEN cr_crapban(pr_cdbanchq);
      FETCH cr_crapban INTO vr_nmbanco;
      CLOSE cr_crapban;

  END;


/*------------------------------------
-- INICIO DA ROTINA PRINCIPAL
--------------------------------------*/
BEGIN

  -- Incluido nome do módulo logado
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CHEQ0003.pc_gera_crapfdc');

  -- Busca os dados da cooperativa
  OPEN cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  IF cr_crapcop%NOTFOUND THEN
    CLOSE cr_crapcop;
    pr_cdcritic := 651;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_crapcop;

  -- Busca a data do movimento
  OPEN cr_crapdat(pr_cdcooper);
    FETCH cr_crapdat INTO vr_dtmvtolt;
  CLOSE cr_crapdat;

  -- busca numero do ultimo cheque
  OPEN cr_craptab(pr_cdcooper);
  FETCH cr_craptab INTO rw_craptab;
  IF cr_craptab%NOTFOUND THEN
    CLOSE cr_craptab;
    pr_cdcritic := 247;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    raise vr_exc_saida;
  END IF;
  CLOSE cr_craptab;

  -- Monta Busca de Parametro com base dia da semana
  vr_cdacesso := 'CRPS408_CHEQUE_' || to_char(vr_dtmvtolt,'DY','NLS_DATE_LANGUAGE = PORTUGUESE'); 
     
  -- Busca Codigo da Empresa
  vr_cdempres := to_number(NVL(gene0001.fn_param_sistema('CRED',0,vr_cdacesso),0));

  -- Segunda e Quinta      - InterPrint
  -- Terça, Quarta e Sexta - RR Donnelley

  -- Caso não Encontrar Empresa
  IF NVL(vr_cdempres,0) = 0 THEN
    vr_cdempres := 2; -- RR Donnelley
  END IF;
  
  -- Sempre que for RR Donnelley busca lista de email
  IF ( vr_cdempres = 2 ) THEN
    --Recuperar emails de destino
    vr_email_dest := gene0001.fn_param_sistema('CRED',0,'CRPS408_EMAIL_RRD');
  ELSE 
    vr_email_dest := NULL;  
  END IF;  

  -- CECRED
  Pc_Gera_Talonario(pr_cdcooper     => pr_cdcooper,
                    pr_cdbanchq     => rw_crapcop.cdbcoctl,
                    pr_nrcontab     => 0,
                    pr_nrdserie     => 1,
                    pr_nmarqui1     => 'crrl392_03',
                    pr_nmarqui2     => 'crrl393_03',
                    pr_nmarqui3     => NULL, --'crrl572_03',
                    pr_nmarqui4     => NULL, --'crrl573_03',
                    pr_flg_impri    => 'S',
                    pr_cdempres     => vr_cdempres,
                    pr_tprequis     => 1);
  
  -- CECRED
  Pc_Gera_Talonario(pr_cdcooper     => pr_cdcooper,
                    pr_cdbanchq     => rw_crapcop.cdbcoctl,
                    pr_nrcontab     => 0,
                    pr_nrdserie     => 1,
                    pr_nmarqui1     => NULL, --'crrl392_03',
                    pr_nmarqui2     => NULL, --'crrl393_03',
                    pr_nmarqui3     => 'crrl572_03',
                    pr_nmarqui4     => 'crrl573_03',
                    pr_flg_impri    => 'S',
                    pr_cdempres     => vr_cdempres,
                    pr_tprequis     => 3);   


  -- Testar se houve erro
  IF pr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    pr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  --
  COMMIT;
EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || pr_dscritic );
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit
    COMMIT;
    pr_cdcritic := 0;
    pr_dscritic := NULL;

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
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
    
  END pc_gera_crapfdc;

  PROCEDURE pc_gera_arq_grafica_cheque (pr_cdcooper in craptab.cdcooper%TYPE
                     ,pr_nrpedido  IN crapreq.nrpedido%TYPE
                     ,pr_tprequis  IN crapreq.tprequis%TYPE
                     ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                     ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                     ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                     ,pr_cdcritic out crapcri.cdcritic%TYPE
                     ,pr_dscritic out varchar2) as

  -- Data do movimento
  cursor cr_crapdat(pr_cdcooper in craptab.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;

  -- Cursor para buscar os dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper in crapcop.cdcooper%type) is
    select crapcop.nmextcop,
           crapcop.cdageitg,
           crapcop.cdagebcb,
           crapcop.cdagectl,
           crapcop.cdbcoctl,
           crapcop.nmrescop,
           crapcop.dsendcop,
           crapcop.nrendcop,
           crapcop.nmbairro,
           crapcop.nrtelvoz,
           crapcop.nmcidade,
           crapcop.cdufdcop,
           crapcop.nrdocnpj
      from crapcop
     where crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Cursor para buscar os dados do ultimo cheque
  CURSOR cr_craptab(pr_cdcooper in craptab.cdcooper%type) is
    SELECT dstextab
      FROM craptab
     WHERE craptab.cdcooper = pr_cdcooper
      AND  upper(craptab.nmsistem) = 'CRED'
      AND  upper(craptab.tptabela) = 'GENERI'
      AND  craptab.cdempres = 0
      AND  upper(craptab.cdacesso) = 'NUMULTCHEQ'
      AND  craptab.tpregist = 0;
  rw_craptab cr_craptab%ROWTYPE;

      TYPE typ_reg_nrpedido IS
         RECORD (nrpedido crapfdc.nrpedido%type);

       --Tipo de tabela para associados
       TYPE tab_reg_nrpedido IS TABLE OF typ_reg_nrpedido INDEX BY PLS_INTEGER;

       --Tabela de memoria de associados
       vr_tab_nrpedido tab_reg_nrpedido;

  -- Codigo do programa
  vr_cdprogra      crapprg.cdprogra%type:='CRPS408';
  
  -- Lista Endereco de Email RRD
  vr_email_dest    VARCHAR2(4000) := NULL;

  -- Tratamento de erros
  vr_exc_fimprg    EXCEPTION;
  vr_exc_saida     EXCEPTION;

  -- Variavel para armazenar as informacoes em XML
  vr_des_xml          clob;
  vr_des_xml_rej      clob;
  vr_des_xml_fc       clob;
  vr_des_xml_fc_rej   clob;


  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;

  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio VARCHAR2(200);

  -- Codigo da Empresa a ser Impresso os Cheques
  vr_cdempres      NUMBER := 0;
  vr_cdempres2     NUMBER := 0;
  vr_nmempres      VARCHAR2(20);

  -- Quantidade de Linhas no Arquivo
  vr_qtlinhas  NUMBER := 0;

  vr_cdacesso      VARCHAR2(30);

  vr_dscomora  VARCHAR2(1000);
  vr_dsdirbin  VARCHAR2(1000);

  -- Variaveis envio SFTP
  vr_serv_sftp  VARCHAR2(100);
  vr_user_sftp  VARCHAR2(100);
  vr_pass_sftp  VARCHAR2(100);
  vr_comando    VARCHAR2(4000);
  vr_typ_saida  VARCHAR2(3);
  vr_dir_remoto VARCHAR2(4000);
  vr_script     VARCHAR2(4000);
  vr_des_saida  VARCHAR2(4000);
  
  vr_qtfoltal_10     NUMBER := 0;
  vr_qtfoltal_20     NUMBER := 0;

  vr_possuipr   VARCHAR2(1);
  vr_inimpede_talionario tbcc_situacao_conta_coop.inimpede_talionario%TYPE;
  vr_arquivo_zip   VARCHAR2(200);
  
  vr_primeira_vez  NUMBER(1) := 1;
  
  -- Procedimento para inserir texto no CLOB do arquivo XML
  PROCEDURE pc_escreve_xml(pr_des_dados in VARCHAR2,
                           pr_tpxml     IN NUMBER) is
  BEGIN
    IF pr_tpxml = 1 THEN -- Se o tipo de XML for de requisicoes aprovadas
      dbms_lob.writeappend(vr_des_xml,        length(pr_des_dados), pr_des_dados);
    ELSIF pr_tpxml = 2 THEN -- Se o tipo de XML for de requisicoes rejeitadas
      dbms_lob.writeappend(vr_des_xml_rej,    length(pr_des_dados), pr_des_dados);
    ELSIF pr_tpxml = 3 THEN -- Se o tipo de XML for de requisicoes aprovadas de formulário continuo
      dbms_lob.writeappend(vr_des_xml_fc,     length(pr_des_dados), pr_des_dados);
    ELSIF pr_tpxml = 4 THEN -- Se o tipo de XML for de requisicoes rejeitadas de formulário continuo
      dbms_lob.writeappend(vr_des_xml_fc_rej, length(pr_des_dados), pr_des_dados);
    END IF;
  end;

  PROCEDURE pc_envia_email_arq(pr_cdcooper    IN crapcop.cdcooper%TYPE   --> Coop conectada
                              ,pr_dsorigem    IN varchar2                --> Caminho com nome do Arquito
                              ,pr_des_erro    OUT VARCHAR2) IS           --> Erro no processo
                              
  cursor c_cop is 
   select c.nmrescop
     from crapcop c
    where c.cdcooper = pr_cdcooper;                               
                              
  vr_des_erro   varchar2(500);
  vr_exc_erro   exception;
  vr_assunto    varchar2(4000);
  vr_prm_emails varchar2(4000) := gene0001.fn_param_sistema('CRED',0,'EMAIL_SUPRI_PEDIDOS_RRD');
  vr_cooperativa crapcop.nmrescop%type;
  vr_corpo         varchar2(4000);  
  vr_proxima_linha varchar2(100) := '<br /><br />';  
  vr_flg_remove_anex char(1) := 'N';
  

  BEGIN
    --    Autor   : Paulo Martins (Mout-s)
    --    Data    : Julho/2018                         
    --
    --    Objetivo  : Em caso de erro no FTP para RR Donnelley, envia email para suprimentos com arquivo anexo 
    --                para processamento Manual.
    --
    IF vr_prm_emails IS NULL THEN
       vr_des_erro := 'Não localizou o parâmetro "EMAIL_SUPRI_PEDIDOS_RRD" com os e-mails para envio.';
       RAISE vr_exc_erro;    
    END IF; 
    --
    vr_assunto := 'Pedidos de talonários não enviado ao parceiro - Necessita processo manual';      
    
    open c_cop;
     fetch c_cop into vr_cooperativa;
    close c_cop;
    
    vr_corpo := 'Cooperativa: '||pr_cdcooper||' - '||vr_cooperativa||vr_proxima_linha;
    vr_corpo := vr_corpo||'Arquivo: '||pr_dsorigem||vr_proxima_linha;
    vr_corpo := vr_corpo||'Na data de '||to_char(sysdate,'DD/MM/RRRR')||' não foi possível entregar o arquivo (em anexo neste e-mail) para o parceiro,'||
                          'devido a problemas no canal de comunicação.'||vr_proxima_linha||
                          'É necessário que a área de suprimentos poste manualmente este arquivo no ambiente do parceiro.'||vr_proxima_linha;
    
    if pr_dsorigem is null then
      -- Envia e-mail sem anexo com alerta para abrir Incidente para sustentação
      vr_corpo := vr_corpo||'Atenção: Arquivo não encontrado, favor abrir Incidente para Sustentação!';
      vr_flg_remove_anex := 'S';
    end if;

    -- Chamar o agendamento deste e-mail
    gene0003.pc_solicita_email(pr_cdcooper    => pr_cdcooper
                              ,pr_cdprogra    => 'pc_crps408'
                              ,pr_des_destino => vr_prm_emails
                              ,pr_flg_remove_anex => vr_flg_remove_anex --> Manter os anexos
                              ,pr_des_assunto => vr_assunto
                              ,pr_des_corpo   => vr_corpo
                              ,pr_des_anexo   => pr_dsorigem||'.zip'
                              ,pr_des_erro    => vr_des_erro);
    -- Se houver erro
    IF vr_des_erro IS NOT NULL THEN
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN --> Erro tratado
      -- Efetuar rollback
      ROLLBACK;
      -- Concatenar o erro previamente montado e retornar
      pr_des_erro := 'pc_crps408.pc_envia_email_arq --> : ' || vr_des_erro;
    WHEN OTHERS THEN -- Gerar log de erro
      -- Efetuar rollback
      ROLLBACK;
      -- Retornar o erro contido na sqlerrm
      pr_des_erro := 'pc_crps408.pc_envia_email_arq --> : '|| sqlerrm;
  END pc_envia_email_arq;  
  
  
  -- Subrotina que vai gerar o relatorio sobre o talonario
  PROCEDURE pc_gera_arquivo(pr_cdcooper     IN crapreq.cdcooper%TYPE,
                              pr_cdbanchq     IN crapass.cdbcochq%TYPE,
                              pr_nrcontab     IN NUMBER,
                              pr_nrdserie     IN NUMBER,
                              pr_nmarqui1     IN VARCHAR2,
                              pr_nmarqui2     IN VARCHAR2,
                              pr_nmarqui3     IN VARCHAR2,
                              pr_nmarqui4     IN VARCHAR2,
                              pr_flg_impri    IN VARCHAR2,
                              pr_cdempres     IN gnsequt.cdsequtl%TYPE,
                              pr_tprequis     IN crapreq.tprequis%type) IS


    -- Cursor para leitura de requisicoes de talonarios
    CURSOR cr_crapreq(pr_cdcooper     IN crapreq.cdcooper%TYPE,
                      pr_cdbanchq     IN crapcop.cdbcoctl%TYPE,
                      pr_tprequis     IN crapreq.tprequis%TYPE,
                      pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE,
                      pr_nrpedido     IN crapreq.nrpedido%TYPE) IS
      SELECT crapreq.ROWID,
             crapreq.cdagenci,
             crapreq.nrdconta,
             /*CASE 
			   WHEN NVL(crapreq.qtreqtal,0) = 0 THEN 1
			   ELSE crapreq.qtreqtal
			 END AS qtreqtal,*/
             crapreq.qtreqtal,
             crapreq.tprequis,
             crapreq.insitreq,
             crapreq.tpformul,
             crapreq.nrpedido
        FROM crapass,
             crapreq
       WHERE crapreq.cdcooper  = pr_cdcooper
         AND (crapreq.tprequis  = 1
          OR  (crapreq.tprequis = 3
         AND   crapreq.tpformul = 999))
         AND crapreq.insitreq = 2
         AND (crapass.inpessoa, crapreq.cdtipcta) 
          IN (SELECT t.inpessoa
                   , t.tpconta
                FROM tbcc_produtos_coop t
               WHERE t.cdcooper  = pr_cdcooper
                       AND t.cdproduto = 38
                       AND (dtvigencia >= pr_dtmvtolt
                        OR  dtvigencia IS NULL)) -- Folhas de Cheque 
         AND crapass.cdcooper = crapreq.cdcooper
         AND crapass.nrdconta = crapreq.nrdconta
         AND crapass.cdbcochq = pr_cdbanchq
--         AND NVL(crapreq.qtreqtal, 0) >= 0 -- Somente quando tiver solicitacao de talao
         AND crapreq.qtreqtal > 0 -- Somente quando tiver solicitacao de talao
         AND crapreq.tprequis = pr_tprequis
         AND crapreq.nrpedido = pr_nrpedido
       ORDER BY crapreq.nrpedido,crapreq.cdagenci,crapreq.nrdconta;

    -- Cursor para buscar os dados da agencia
    CURSOR cr_crapage(pr_cdcooper    IN crapage.cdcooper%TYPE,
                      pr_cdagenci    IN crapage.cdagenci%TYPE) IS
      SELECT crapage.nmresage,
             crapage.cdcomchq,
             crapage.dsinform##1,
             crapage.dsinform##2,
             crapage.dsinform##3
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;

    -- Cursor sobre os associados
    CURSOR cr_crapass(pr_cdcooper    IN crapass.cdcooper%TYPE,
                      pr_nrdconta    IN crapass.nrdconta%TYPE) IS
      SELECT ROWID,
             nrdconta,
             nrdctitg,
             flchqitg,
             nrflcheq,
             qtfoltal,
             nmprimtl,
             cdtipcta,
             cdsitdtl,
             inlbacen,
             dtdemiss,
             cdsitdct,
             flgctitg,
             inpessoa,
             nrcpfcgc,
             tpdocptl,
             nrdocptl,
             idorgexp,
             cdufdptl,
             dtabtcct,
             dtadmiss,
             cdcatego
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor sobre os titulares da conta para pessoa fisica
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE,
                      pr_idseqttl IN crapttl.idseqttl%TYPE) IS
      SELECT nmtalttl
            ,nmextttl
        FROM crapttl
       WHERE crapttl.cdcooper  = pr_cdcooper
         AND crapttl.nrdconta  = pr_nrdconta
         AND crapttl.idseqttl >= pr_idseqttl
       ORDER BY crapttl.idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- Cursor sobre os titulares da conta para pessoa juridica
    CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE,
                      pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT nmtalttl
        FROM crapjur
       WHERE crapjur.cdcooper  = pr_cdcooper
         AND crapjur.nrdconta  = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;

    -- Cursor para buscar o tipo de conta para os rejeitados
    CURSOR cr_tpconta(pr_inpessoa IN tbcc_tipo_conta.inpessoa%TYPE,
                      pr_cdtipcta IN tbcc_tipo_conta.cdtipo_conta%TYPE) IS
      SELECT tip.dstipo_conta
        FROM tbcc_tipo_conta tip
       WHERE tip.inpessoa     = pr_inpessoa
         AND tip.cdtipo_conta = pr_cdtipcta;
    rw_tpconta cr_tpconta%ROWTYPE;

    -- Cursor para buscar o nome do banco
    CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
      SELECT substr(nmresbcc,1,15) nmresbcc
        FROM crapban
       WHERE cdbccxlt = pr_cdbccxlt;

    -- Cursor para buscar a data em que o cooperado é cliente bancário
    CURSOR cr_crapsfn(pr_cdcooper IN crapsfn.cdcooper%TYPE,
                      pr_nrcpfcgc IN crapsfn.nrcpfcgc%TYPE) IS
      SELECT crapsfn.dtabtcct
        FROM crapsfn
       WHERE crapsfn.cdcooper = pr_cdcooper
         AND crapsfn.nrcpfcgc = pr_nrcpfcgc
         AND crapsfn.tpregist = 1
         AND crapsfn.dtabtcct IS NOT NULL
       ORDER BY crapsfn.dtabtcct;
    rw_crapsfn cr_crapsfn%ROWTYPE;

    CURSOR cr_crapfdc (pr_nrpedido IN NUMBER, pr_nrdconta IN NUMBER) IS
      SELECT a.*, b.idstatus_atualizacao_hsm, b.dtcriacao, b.cdhashcode, b.cdseguranca, b.rowid linha
        FROM crapfdc a, tbchq_seguranca_cheque b
       WHERE a.CDCOOPER = b.cdcooper
         AND a.CDBANCHQ = b.cdbanchq
         AND a.CDAGECHQ = b.cdagechq
         AND a.NRCTACHQ = b.nrctachq
         AND a.NRCHEQUE = b.nrcheque
         AND b.nrpedido = a.nrpedido
         AND b.tprequis = pr_tprequis
         and a.cdcooper = pr_cdcooper
         AND b.nrpedido = nvl(pr_nrpedido,b.nrpedido)
         AND b.nrdconta = nvl(pr_nrdconta,b.nrdconta)
         AND b.idstatus_atualizacao_hsm = 2
       ORDER BY b.nrcheque;
    rw_crapfdc cr_crapfdc%ROWTYPE;

    -- Variavel da agencia anterior do loop de requisicoes;
    vr_cdagenci_ant    crapage.cdagenci%TYPE;
    vr_cdagenci_ant_fc crapage.cdagenci%TYPE;

    -- Variaveis auxiliares
    vr_nrctaitg        crapass.nrdctitg%TYPE;
    vr_nrinichq        crapass.nrflcheq%TYPE;
    vr_nrinichq_dig    crapass.nrflcheq%TYPE;
    vr_nrinichq_fc     crapass.nrflcheq%TYPE;
    vr_nrultchq        crapass.nrflcheq%TYPE;
    vr_nrultchq_dig    crapass.nrflcheq%TYPE;
    vr_nrflcheq        crapass.nrflcheq%TYPE;
    vr_nrflcheq_aux    crapass.nrflcheq%TYPE;
    vr_nrdigchq        crapfdc.nrdigchq%TYPE;
    vr_cdagechq        crapfdc.cdagechq%TYPE;
    vr_dsdocmc7        crapfdc.dsdocmc7%TYPE;
    vr_cdcritic        crapreq.cdcritic%TYPE;
    vr_insitreq        crapreq.insitreq%TYPE;
    vr_nmbanco         crapban.nmresbcc%TYPE;
    vr_retorno         BOOLEAN;
    vr_idrejeit_tl     BOOLEAN;
    vr_fechapac_req_tl BOOLEAN;
    vr_fechapac_rej_tl BOOLEAN;
    vr_idrejeit_fc     BOOLEAN;
    vr_fechapac_req_fc BOOLEAN;
    vr_fechapac_rej_fc BOOLEAN;
    vr_qttotreq        NUMBER(10);
    vr_qttotreq_tl     NUMBER(10);
    vr_qttotrej_tl     NUMBER(10);
    vr_qttottrf_tl     NUMBER(10);
    vr_qttotreq_fc     NUMBER(10);
    vr_qttotrej_fc     NUMBER(10);
    vr_qttottrf_fc     NUMBER(10);
    vr_qttotchq_tl     NUMBER(10);
    vr_qttottal_tl     NUMBER(10);
    vr_qttottal_fc     NUMBER(10);
    vr_qttotgerreq_fc  NUMBER(10);
    vr_qtreqtal        NUMBER(10);
    vr_dstipreq        VARCHAR2(02);
    vr_dssitdct        VARCHAR2(50);
    vr_dscritic        VARCHAR2(200);
    vr_des_erro        VARCHAR2(200);
    vr_auxiliar        NUMBER(15);
    vr_auxiliar2       NUMBER(15);
    vr_cddigage        NUMBER(01);
    vr_cddigtc1        NUMBER(01);
    vr_nrdctitg        VARCHAR2(07);
    vr_nrdigctb        VARCHAR2(01);
    vr_nrdctitg_aux    crapass.nrdctitg%TYPE;
    vr_nrcpfcgc        VARCHAR2(18);
    vr_tpdocptl        crapass.tpdocptl%TYPE;
    vr_nrdocptl        crapass.nrdocptl%TYPE;
    vr_cdorgexp        tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
    vr_nmorgexp        tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
    vr_cdufdptl        crapass.cdufdptl%TYPE;
    vr_nmprital        crapass.nmprimtl%TYPE;
    vr_nmsegtal        crapttl.nmextttl%TYPE;
    vr_dtabtcc2        DATE;
    vr_literal2        VARCHAR2(200);
    vr_literal3        VARCHAR2(200);
    vr_literal4        VARCHAR2(200);
    vr_literal5        VARCHAR2(200);
    vr_literal6        VARCHAR2(15);
    vr_literal7        VARCHAR2(200);
    vr_literal8        VARCHAR2(200);
    vr_literal9        VARCHAR2(200);
    vr_tpformul        VARCHAR2(02);
    vr_nrfolhas        NUMBER(10);
    vr_nrdigtc2        NUMBER(01);
    vr_dscpfcgc        VARCHAR2(05);
    vr_dsarqdad        VARCHAR2(2000);
    vr_numtalon        crapass.flchqitg%TYPE;
    vr_dssituacao      tbcc_situacao_conta.dssituacao%TYPE;

    -- Variaveis para geracao do arquivo texto via utl_file
    vr_nmarqped        VARCHAR2(50);
    vr_nmarqtransm     VARCHAR2(50);
    vr_nmarqctrped     VARCHAR2(50);
    vr_nmarqdadped     VARCHAR2(50);
    vr_input_file_dad  utl_file.file_type;
    vr_input_file_ctr  utl_file.file_type;
    vr_lista_nmarq     VARCHAR2(50);

    -- Variável que indica se foi gerado arquivo de requisicao de talao/formulario de cheque
    vr_flggerou        boolean;
    
    -- variavel para verificacao do dia de processamento de envio da requisicao
    vr_dtcalcul        DATE;
    
    TYPE typ_reg_pedido_conta IS
    RECORD (nrpedido_nrdconta    NUMBER);

    --Tipo de tabela para associados
    TYPE tab_reg_pedido_conta IS TABLE OF typ_reg_pedido_conta INDEX BY VARCHAR2(20);

    --Tabela de memoria de associados
    vr_tab_pedido_conta tab_reg_pedido_conta;
    vr_indice           varchar2(20);
    wr_qtfolha_gerada   crapass.qtfoltal%TYPE;
    vr_qttalao          crapreq.qtreqtal%TYPE;
    vr_qtfoltal         crapreq.qtreqtal%TYPE;
    vr_nrseqems_ant     rw_crapfdc.nrseqems%TYPE;
  BEGIN        

    vr_nmempres    := 'RR DONNELLEY';
    vr_nmarqped    := 'RRD'   ||to_char(pr_cdcooper,'fm000')||'-ctr-';
    vr_nmarqtransm := 'dRRD'  ||to_char(pr_cdcooper,'fm000')||'-ctr-';
    vr_nmarqctrped := 'ctRRD' ||to_char(pr_cdcooper,'fm000')||'-ctr-';
    vr_nmarqdadped := 'daRRD' ||to_char(pr_cdcooper,'fm000')||'-ctr-';

    vr_nmarqped    := vr_nmarqped    || to_char(pr_nrpedido,'fm000000');
    vr_nmarqtransm := vr_nmarqtransm || to_char(pr_nrpedido,'fm000000');
    vr_nmarqctrped := vr_nmarqctrped || to_char(pr_nrpedido,'fm000000');
    vr_nmarqdadped := vr_nmarqdadped || to_char(pr_nrpedido,'fm000000');
    vr_flggerou := FALSE;

    -- Tenta abrir o arquivo de detalhes em modo gravacao
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio||'/arq'   --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarqdadped             --> Nome do arquivo
                            ,pr_tipabert => 'W'                        --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_input_file_dad          --> Handle do arquivo aberto
                            ,pr_des_erro => pr_dscritic);              --> Erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Inicializar o CLOB para armazenar os arquivos XML
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    vr_des_xml_fc := NULL;
    dbms_lob.createtemporary(vr_des_xml_fc, TRUE);
    dbms_lob.open(vr_des_xml_fc, dbms_lob.lob_readwrite);

    vr_des_xml_rej := NULL;
    dbms_lob.createtemporary(vr_des_xml_rej, TRUE);
    dbms_lob.open(vr_des_xml_rej, dbms_lob.lob_readwrite);

    vr_des_xml_fc_rej := NULL;
    dbms_lob.createtemporary(vr_des_xml_fc_rej, TRUE);
    dbms_lob.open(vr_des_xml_fc_rej, dbms_lob.lob_readwrite);

    -- Inicializa a variavel de indicador de existencia de associado rejeitado
    vr_idrejeit_tl := FALSE;
    vr_idrejeit_fc := FALSE;

    -- Inicializa a variavel de fechamento de pac, informando que a mesma esta fechada
    vr_fechapac_req_tl := TRUE;
    vr_fechapac_rej_tl := TRUE;

    vr_fechapac_req_fc := TRUE;
    vr_fechapac_rej_fc := TRUE;

    -- Inicializa as variaveis totalizadoras
    vr_qttotreq       := 0;
    vr_qttotchq_tl    := 0;
    vr_qttottal_tl    := 0;
    vr_qttotreq_tl    := 0;
    vr_qttottrf_tl    := 0;
    vr_qttotrej_tl    := 0;
    vr_qttottal_fc    := 0;
    vr_qttotgerreq_fc := 0;
    vr_qttotreq_fc    := 0;
    vr_qttottrf_fc    := 0;
    vr_qttotrej_fc    := 0;

    -- Inicializa o arquivo XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps408>',1);
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps408>',3);

    -- Busca o codigo da agencia do cheque
    vr_cdagechq := rw_crapcop.cdagectl;

    -- Insere o nó inicial do relatorio de pedidos do XML
    pc_escreve_xml('<pedido>'||
                    '<requisicoes>',1);
    pc_escreve_xml( '<rejeitados>',2);

    pc_escreve_xml('<pedido>'||
                    '<requisicoes>',3);
    pc_escreve_xml( '<rejeitados>',4);

    -- Verifica se ha requisicoes a serem atendidas
    FOR rw_crapreq IN cr_crapreq(pr_cdcooper,
                                 pr_cdbanchq,
                                 pr_tprequis,
                                 vr_dtmvtolt,
                                 pr_nrpedido) LOOP
        
     vr_indice := rw_crapreq.nrpedido||rw_crapreq.nrdconta;
     if not (vr_tab_pedido_conta.exists(vr_indice)) then

      -- Busca os dados do associado
      OPEN cr_crapass(pr_cdcooper,
                      rw_crapreq.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

      /*   CHEQUE ESPECIAL  */
      CADA0006.pc_permite_produto_tipo (pr_cdprodut => 38
                                       ,pr_cdtipcta => rw_crapass.cdtipcta
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_inpessoa => rw_crapass.inpessoa
                                       ,pr_possuipr => vr_possuipr
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
      
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_cdcritic := 0;
      
      IF vr_possuipr = 'N' THEN
        vr_cdcritic := 65;-- 065 - Tipo de conta nao permite req.
      ELSE 
        vr_cdcritic := 0;
      END IF;

      -- Se não houver rejeição no associado
      IF nvl(vr_cdcritic,0) = 0 THEN
        
        CADA0006.pc_ind_impede_talonario(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => rw_crapass.nrdconta
                                ,pr_inimpede_talionario => vr_inimpede_talionario
                                ,pr_des_erro => vr_des_erro
                                ,pr_dscritic => vr_dscritic);
        IF vr_des_erro = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;
                
        IF vr_inimpede_talionario = 1 THEN -- Se nao houver impedimento para retirada de talionarios
          vr_cdcritic := 18; --018 - Situacao da conta errada.
        ELSIF rw_crapass.cdsitdtl IN (5,6,7,8) THEN --5=NORMAL C/PREJ., 6=NORMAL BLQ.PREJ, 7=DEMITIDO C/PREJ, 8=DEM. BLOQ.PREJ.
          vr_cdcritic := 695; --695 - ATENCAO! Houve prejuizo nessa conta
        ELSIF rw_crapass.cdsitdtl IN (2,4) THEN --2=NORMAL C/BLOQ., 4=DEMITIDO C/BLOQ
          vr_cdcritic := 95; --095 - Titular da conta bloqueado.
        ELSIF rw_crapass.inlbacen <> 0 THEN -- Indicador se o associado consta na lista do Banco Central
          vr_cdcritic := 720; --720 - Associado esta no CCF.
        END IF;
      END IF;

      -- Abre o cursor contendo os titulares da conta, mas somente a segunda pessoa em diante
      OPEN cr_crapttl(pr_cdcooper,
                      rw_crapass.nrdconta,
                      2);
      FETCH cr_crapttl INTO rw_crapttl;
      IF cr_crapttl%FOUND AND NVL(vr_cdcritic,0) = 0 THEN
        IF rw_crapass.cdcatego = 1 THEN --INDIVIDUAL
          vr_cdcritic := 832; --832 - Tipo de conta nao permite MAIS DE UM TITULAR.
        END IF;
      END IF;
      CLOSE cr_crapttl;

      -- Verifica se é formulario continuo
      -- Em caso positivo, faz os processos para o mesmo
      IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN
        -- Verifica se é uma agencia diferente do registro anterior
        IF rw_crapreq.cdagenci <> nvl(vr_cdagenci_ant_fc,-1) THEN

          -- busca o nome da agencia
          OPEN cr_crapage(pr_cdcooper,
                          rw_crapreq.cdagenci);
          FETCH cr_crapage INTO rw_crapage;
          IF cr_crapage%NOTFOUND THEN
            rw_crapage.nmresage := LPAD('*',15,'*');
            rw_crapage.cdcomchq := 16;
          END IF;
          CLOSE cr_crapage;

          -- Se teve registro anterior, entao fecha-se o no
          IF nvl(vr_cdagenci_ant_fc,0) <> 0 THEN
            pc_escreve_xml( '<qttotreq>'||vr_qttotreq_fc||'</qttotreq>'||
                            '<qttottrf>'||vr_qttottrf_fc||'</qttottrf>'||
                            '<qttotrej>'||vr_qttotrej_fc||'</qttotrej>'||
                           '</pac>',3);
          END IF;

          -- Insere o nó inicial
          pc_escreve_xml('<pac>'||
                           '<cdagenci>'||rw_crapreq.cdagenci||'</cdagenci>'||
                           '<nmresage>'||rw_crapage.nmresage||'</nmresage>'||
                           '<vlsequtl>'|| pr_nrpedido       ||'</vlsequtl>',3);
          vr_fechapac_req_fc := FALSE;

          -- Zera as variaveis de totais
          vr_qttotreq_fc := 0;
          vr_qttotrej_fc := 0;
          vr_qttottrf_fc := 0;

          -- Se no PAC anterior teve rejeitados, entao deve-se fechar o nó
          IF vr_idrejeit_fc THEN
            vr_fechapac_rej_fc := TRUE;
            pc_escreve_xml('</pac>',4);
            -- Limpa indicador de requisicoes rejeitadas
            vr_idrejeit_fc := FALSE;
          END IF;

        END IF; -- If de agencia diferente de formulario continuo

      ELSE -- Se nao for formulario contionuo

        -- Verifica se é uma agencia diferente do registro anterior
        IF rw_crapreq.cdagenci <> nvl(vr_cdagenci_ant,-1) THEN

          -- busca o nome da agencia
          OPEN cr_crapage(pr_cdcooper,
                          rw_crapreq.cdagenci);
          FETCH cr_crapage INTO rw_crapage;
          IF cr_crapage%NOTFOUND THEN
            rw_crapage.nmresage := LPAD('*',15,'*');
            rw_crapage.cdcomchq := 16;
          END IF;
          CLOSE cr_crapage;

          -- Se tiver agencia anterior deve-se fechar o nó do PAC
          IF nvl(vr_cdagenci_ant,0) <> 0 THEN
            pc_escreve_xml( '<qttotreq>'||vr_qttotreq_tl||'</qttotreq>'||
                            '<qttottrf>'||vr_qttottrf_tl||'</qttottrf>'||
                            '<qttotrej>'||vr_qttotrej_tl||'</qttotrej>'||
                           '</pac>',1);
          END IF;

          -- Insere o no do PAC
          pc_escreve_xml('<pac>'||
                           '<cdagenci>'||rw_crapreq.cdagenci||'</cdagenci>'||
                           '<nmresage>'||rw_crapage.nmresage||'</nmresage>'||
                           '<vlsequtl>'|| pr_nrpedido       ||'</vlsequtl>',1);
          vr_fechapac_req_tl := FALSE;

          -- Zera as variaveis de totais
          vr_qttotreq_tl := 0;
          vr_qttotrej_tl := 0;
          vr_qttottrf_tl := 0;

          -- Se no PAC anterior teve rejeitados, entao deve-se fechar o nó
          IF vr_idrejeit_tl THEN
            vr_fechapac_rej_tl := TRUE;
            pc_escreve_xml('</pac>',2);
            -- Limpa indicador de requisicoes rejeitadas
            vr_idrejeit_tl := FALSE;
          END IF;
        END IF;  -- If de agencia diferente para formulario comum
      END IF;

      -- Se o cooperado nao estiver com situacao de rejeitado
      IF NVL(vr_cdcritic,0) = 0 THEN
        -- Inicializa variavel auxiliar de contados de taloes
        vr_qtreqtal := 1;

        -- Acumula o total de taloes
        IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN -- Se for FC
          vr_qttottal_fc    := vr_qttottal_fc + rw_crapreq.qtreqtal;
          vr_qttotgerreq_fc := vr_qttotgerreq_fc + 1;
          vr_nrinichq_fc    := 0;
        ELSE  -- Se for taloes
          vr_qttottal_tl := vr_qttottal_tl + rw_crapreq.qtreqtal;
        END IF;
        IF NOT (rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999) THEN -- Se nao for FC
          -- Atualiza o contador de REQUISICOES ou TRANSF/ABT
          IF rw_crapreq.insitreq IN (4,5) THEN
            vr_qttottrf_tl := vr_qttottrf_tl + 1;
          ELSE
            vr_qttotreq_tl := vr_qttotreq_tl + 1;
          END IF;
              
          IF rw_crapass.qtfoltal = 10 THEN
            vr_qtfoltal_10 := vr_qtfoltal_10 + (rw_crapreq.qtreqtal);
          ELSE
            vr_qtfoltal_20 := vr_qtfoltal_20 + (rw_crapreq.qtreqtal);
          END IF;

        END IF;


        OPEN cr_crapfdc(rw_crapreq.nrpedido, rw_crapreq.nrdconta);
        FETCH cr_crapfdc INTO rw_crapfdc;
        -- Contador para executar a cada solicitacao de talão, pois a mesma requisição pode solicitar mais de um talão
        IF NOT (rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999) THEN -- Se nao for FC
          vr_qttalao  := rw_crapreq.qtreqtal;
          vr_qtfoltal := rw_crapass.qtfoltal;
        ELSE
          vr_qttalao := 1;
          vr_qtfoltal := rw_crapreq.qtreqtal;
        END IF;
        for rw_talao in 1 .. vr_qttalao loop
           vr_primeira_vez := 1;
           wr_qtfolha_gerada := 1;
        WHILE cr_crapfdc%FOUND and wr_qtfolha_gerada <= vr_qtfoltal LOOP

            vr_nrseqems_ant := rw_crapfdc.nrseqems;
            
            if vr_primeira_vez = 1 then
              vr_nrinichq := rw_crapfdc.nrcheque;
              vr_nrultchq := rw_crapfdc.nrcheque;
              vr_nrflcheq := trunc(vr_nrinichq/10,0);
              IF vr_nrinichq_fc = 0 THEN
                vr_nrinichq_fc := vr_nrinichq;
              END IF;
            end if;

            -- Acumula o total de folhas de cheques
            IF NOT (rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999) THEN -- Se for Talao
              vr_qttotchq_tl := vr_qttotchq_tl + 1;
            END IF;

          -- Busca o tipo de requisicao
          IF rw_crapreq.tprequis = 3 THEN -- Se for formulario continuo
             vr_dstipreq := 'FC';
          ELSIF rw_crapreq.insitreq = 1 THEN -- Conta existente
             vr_dstipreq := '';
          ELSE
             vr_dstipreq := ' A';  -- CTA NOVA
          END IF;

		  -- Inicializa variaveis
          vr_tpdocptl := ' ';
          vr_nrdocptl := ' ';
          vr_cdorgexp := ' ';
          vr_cdufdptl := ' ';
          vr_nmsegtal := ' ';
          vr_literal6 := ' ';
		  vr_nmprital := rw_crapass.nmprimtl;

		  -- Busca o nome do primeito titular da conta
          IF rw_crapass.inpessoa = 1 THEN -- Se for pessoa fisica

            vr_dscpfcgc := 'CPF: ';
            vr_nrcpfcgc := gene0002.fn_mask(rw_crapass.nrcpfcgc,'999.999.999-99');
            vr_tpdocptl := rw_crapass.tpdocptl;
            vr_nrdocptl := rw_crapass.nrdocptl;
            vr_cdufdptl := rw_crapass.cdufdptl;

            -- Abre o cursor contendo os titulares da conta
            OPEN cr_crapttl(pr_cdcooper,
                            rw_crapass.nrdconta,
                            1);

            FETCH cr_crapttl INTO rw_crapttl;

            IF cr_crapttl%FOUND THEN
              IF nvl(rw_crapttl.nmtalttl,' ') <> ' ' THEN
                vr_nmprital := rw_crapttl.nmtalttl;
              ELSE
                vr_nmprital := rw_crapass.nmprimtl;
              END IF;

              -- Faz mais um fetch para buscar o segundo titular
              FETCH cr_crapttl INTO rw_crapttl;
              IF cr_crapttl%FOUND THEN
                IF nvl(rw_crapttl.nmtalttl,' ') <> ' ' THEN
                  vr_nmsegtal := rw_crapttl.nmtalttl;
                ELSE
                  vr_nmsegtal := rw_crapttl.nmextttl;
                END IF;
              END IF;

            END IF;

            CLOSE cr_crapttl;

          ELSE -- Se for pessoa juridica

            vr_dscpfcgc := 'CNPJ:';
            vr_nrcpfcgc := gene0002.fn_mask(rw_crapass.nrcpfcgc,'99.999.999/9999-99');

            -- Abre o cursor contendo os titulares da conta
            OPEN cr_crapjur(pr_cdcooper,
                            rw_crapass.nrdconta);

            FETCH cr_crapjur INTO rw_crapjur;

            IF cr_crapjur%FOUND THEN
              IF nvl(rw_crapjur.nmtalttl,' ') <> ' ' THEN
                vr_nmprital := rw_crapjur.nmtalttl;
              ELSE
                vr_nmprital := rw_crapass.nmprimtl;
              END IF;

            END IF;

            CLOSE cr_crapjur;

            vr_nmsegtal := ' ';

          END IF;

          -- Indica que foi gerado arquivo de requisicao de talao/formulario de cheque
          vr_flggerou := true;

          /*-----------------------------------------------------*/
          -- Informações para serem geradas no arquivo de detalhe
          /*-----------------------------------------------------*/

          -- Inicializa variaveis
          rw_crapsfn.dtabtcct := NULL;

          -- Define o tipo de formulario
          IF rw_crapreq.tprequis = 1 THEN
            vr_tpformul := 'TL';
            vr_nrfolhas := rw_crapass.qtfoltal;
            vr_numtalon := rw_crapass.flchqitg;
          ELSE
            vr_tpformul := 'FC';
            vr_nrfolhas := rw_crapreq.qtreqtal;
            vr_numtalon := 0;
          END IF;
          
          vr_nrdctitg_aux := rw_crapass.nrdconta;
          vr_nrdctitg := substr(to_char(rw_crapass.nrdconta,'fm00000000'),1,7);
          vr_nrdigctb := substr(rw_crapass.nrdconta,-1,1);

          vr_auxiliar := vr_nrdctitg_aux * 10;
          vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_auxiliar); -- O retorno é ignorado, pois a variável vr_agencia é atualiza pelo programa
          vr_nrdigtc2 := MOD(vr_auxiliar,10);

          --> apenas buscar para pessoa fisica
          IF rw_crapass.inpessoa = 1 THEN
            --> Buscar orgão expedidor
            cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapass.idorgexp, 
                                              pr_cdorgao_expedidor => vr_cdorgexp, 
                                              pr_nmorgao_expedidor => vr_nmorgexp, 
                                              pr_cdcritic          => vr_cdcritic, 
                                              pr_dscritic          => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR 
              TRIM(vr_dscritic) IS NOT NULL THEN
              --> Caso nao encontrar enviar embranco 
              vr_cdorgexp := ' ';
              vr_nmorgexp := NULL; 
            END IF;
          ELSE
            vr_cdorgexp := ' ';
            vr_nmorgexp := NULL;   
          END IF;

            vr_literal2 := vr_nmsegtal;
            vr_literal3 := vr_dscpfcgc ||
                           rpad(vr_nrcpfcgc,18,' ')||
                           rpad(' ',7,' ') ||
                           gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z');
            vr_literal4 := rpad(vr_tpdocptl,3,' ') ||
                           SUBSTR(TRIM(vr_nrdocptl),1,15) || ' '||
                           TRIM(vr_cdorgexp)|| ' '||
                           TRIM(vr_cdufdptl);

          OPEN cr_crapsfn(pr_cdcooper,
                          rw_crapass.nrcpfcgc);
          FETCH cr_crapsfn INTO rw_crapsfn;
          CLOSE cr_crapsfn;

          IF rw_crapass.dtabtcct IS NOT NULL AND -- Se existir data de abertura da conta corrente
             rw_crapass.dtabtcct < rw_crapass.dtadmiss THEN -- Se a data de abertura da CC for menor que a data de admissao na CCOH
            vr_dtabtcc2 := rw_crapass.dtabtcct; -- utiliza a data de abertura da conta
          ELSE
            vr_dtabtcc2 := rw_crapass.dtadmiss; -- Utiliza a data de admissao como associado na CCOH
          END IF;


          IF rw_crapsfn.dtabtcct IS NOT NULL AND -- Se existir data de abertura de conta corrente no sistema financeiro do banco central
             rw_crapsfn.dtabtcct < vr_dtabtcc2 THEN
            vr_literal5 := 'Cliente Bancario desde: '||to_char(rw_crapsfn.dtabtcct,'MM/YYYY')||'   ';
          ELSE
            vr_literal5 := 'Cooperado desde: '||to_char(vr_dtabtcc2,'MM/YYYY')|| '          ';
          END IF;
          
          -- Se o cooperado tem cheque especial habilitado na conta
          IF CADA0003.fn_produto_habilitado(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => rw_crapass.nrdconta
                                           ,pr_cdproduto => 13) = 'S'   THEN
            vr_literal6 := 'CHEQUE ESPECIAL';
          END IF;
          IF nvl(rw_crapage.dsinform##1,' ') = ' ' AND
             nvl(rw_crapage.dsinform##2,' ') = ' ' AND
             nvl(rw_crapage.dsinform##3,' ') = ' ' THEN
            vr_literal7 := rw_crapcop.dsendcop ||','||
                           gene0002.fn_mask(rw_crapcop.nrendcop,'zz,zz9');
            vr_literal8 := rw_crapcop.nmbairro ||  ' - ' ||
                           rw_crapcop.nrtelvoz;
            vr_literal9 := rw_crapcop.nmcidade || ' - '||
                           rw_crapcop.cdufdcop;
          ELSE
            vr_literal7 := rw_crapage.dsinform##1;
            vr_literal8 := rw_crapage.dsinform##2;
            vr_literal9 := rw_crapage.dsinform##3;
          END IF;

          -- Se for formulario continuo ira gerar apenas uma vez o registro
          IF vr_primeira_vez = 1 THEN
            IF vr_tpformul = 'FC' AND vr_qtreqtal > 1 THEN
              NULL;
            ELSE
              --Escrever a linha de detalhe no arquivo
              vr_dsarqdad := vr_tpformul                               || -- TIPO FORMUL
                           to_char(rw_crapreq.cdagenci,'fm000')      || -- FILIAL
                           to_char(pr_nrcontab,'fm000')              || -- NUM. CONTAB
                           vr_nrdctitg                               || -- CONTA BASE
                           vr_nrdigctb                               || -- DIG CTA BASE
                           vr_nrdigtc2                               || -- DIG CTA BASE
                           to_char(rw_crapreq.nrdconta,'fm00000000') || -- CONTA/DV
                           to_char(vr_numtalon,'fm00000')            || -- NUM TALONAR.
                           to_char(pr_nrdserie,'fm000')              || -- NUM. SERIE
                           to_char(trunc(vr_nrinichq),'fm000000') || -- INICIO CHQ
                           to_char(vr_nrfolhas,'fm000000')           || -- NR FOLH. CONT
                           to_char(rw_crapage.cdcomchq,'fm000')      || -- CODIGO COMP.
                           rpad(vr_nmprital,40,' ')                  || -- LITERAL 1
                           rpad(vr_literal2,40,' ')                  || -- LITERAL 2
                           rpad(vr_literal3,40,' ')                  || -- LITERAL 3
                           rpad(vr_literal4,40,' ')                  || -- LITERAL 4
                           rpad(vr_literal5,34,' ')                  || -- LITERAL 5
                           rpad(vr_literal6,15,' ')                  || -- LITERAL 6
                           rpad(UPPER(vr_literal7),40,' ')           || -- LITERAL 7
                           rpad(UPPER(vr_literal8),40,' ')           || -- LITERAL 8
                           rpad(UPPER(vr_literal9),40,' ');          -- LITERAL 9

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file_dad --> Handle do arquivo aberto
                                          ,pr_des_text => vr_dsarqdad);

            -- Quantidade de Linhas do Arquivo
            vr_qtlinhas := vr_qtlinhas + 1;
            END IF;
         END IF;

          vr_dsarqdad := 'SEG'|| 
                        lpad(trunc(rw_crapfdc.nrcheque),7,'0')||
                       lpad(rw_crapfdc.cdseguranca,10,'0');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file_dad --> Handle do arquivo aberto
                                        ,pr_des_text => vr_dsarqdad);
          -- Quantidade de Linhas do Arquivo
          vr_qtlinhas := vr_qtlinhas + 1;
          
          vr_primeira_vez := 0;
          vr_nrultchq := rw_crapfdc.nrcheque;

          FETCH cr_crapfdc INTO rw_crapfdc;
          wr_qtfolha_gerada := wr_qtfolha_gerada + 1;
        END LOOP;

          IF NOT (rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999) THEN -- Se nao for FC
            vr_nrinichq_dig := vr_nrinichq*10;
            vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrinichq_dig); -- O retorno é ignorado, pois a variável vr_nrinichq é atualiza pelo programa
            vr_nrultchq_dig := vr_nrultchq*10;
            vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrultchq_dig); -- O retorno é ignorado, pois a variável vr_nrinichq é atualiza pelo programa

          -- Insere as informações de detalhes do pedido da requisicao no XML
          pc_escreve_xml('<requisicao>'||
                           '<nrdconta>'||gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z')||'</nrdconta>'||
                           '<nrctaitg>'||gene0002.fn_mask(vr_nrctaitg,'9.999.999-9')       ||'</nrctaitg>'||
                             '<flchqitg>'||gene0002.fn_mask(vr_nrseqems_ant,'zz.zzz')    ||'</flchqitg>'||
                             '<nrinichq>'||gene0002.fn_mask(vr_nrinichq_dig,'zzz.zzz.z')         ||'</nrinichq>'||
                             '<nrultchq>'||gene0002.fn_mask(vr_nrultchq_dig,'zzz.zzz.z')         ||'</nrultchq>'||
                           '<qtfoltal>'||to_char(rw_crapass.qtfoltal)  ||'</qtfoltal>'||
                           '<nmprimtl>'||substr(rw_crapass.nmprimtl,1,40)  ||'</nmprimtl>'||
                           '<nmsegntl>'||substr(vr_nmsegtal,1,38)  ||'</nmsegntl>'|| -- Colocado tamanho maximo de 38, pois se for maior vai distorcer o relatorio
                           '<dstipreq>'||vr_dstipreq||        '</dstipreq>'||
                         '</requisicao>',1);
        END IF;

        
        end loop;

        close cr_crapfdc;

        -- Atualiza o contados de requisicoes de talões
        vr_qtreqtal := vr_qtreqtal + 1;

        -- Se for formulario continuo, imprime somente depois do loop
        IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN -- Se for FC
          pc_escreve_xml('<requisicao>'||
                           '<nrdconta>'||gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z')||'</nrdconta>'||
                           '<flchqitg>'||rw_crapreq.qtreqtal                               ||'</flchqitg>'||
                           '<nrinichq>'||gene0002.fn_mask(vr_nrinichq_fc,'zzz.zzz.z')      ||'</nrinichq>'||
                           '<nrultchq>'||gene0002.fn_mask(vr_nrultchq,'zzz.zzz.z')         ||'</nrultchq>'||
                           '<nmprimtl>'||rw_crapass.nmprimtl||'</nmprimtl>'||
                         '</requisicao>',3);
          -- Atualiza o contador de REQUISICOES ou TRANSF/ABT
          IF rw_crapreq.insitreq IN (4,5) THEN
            vr_qttottrf_fc := vr_qttottrf_fc + 1;
          ELSE
            vr_qttotreq_fc := vr_qttotreq_fc + 1;
          END IF;
        END IF;

        -- Atualiza a variavel de situacao de requisicao para depois atualizar na tabela CRAPREQ
        vr_insitreq := 2;

        -- Acumula o total de requisicoes para ser utilizado na insercao do crapped
        vr_qttotreq := vr_qttotreq + 1;

      ELSE -- Senao dos rejeitados

        -- Se for a primeira vez que esta entrando no rejeitados para o PAC, então
        --   cria o cabecalho do PAC
        IF NOT vr_idrejeit_tl THEN
          vr_fechapac_rej_tl := FALSE;
          pc_escreve_xml('<pac>'||
                           '<cdagenci>'||rw_crapreq.cdagenci||'</cdagenci>'||
                           '<nmresage>'||rw_crapage.nmresage||'</nmresage>'||
                           '<vlsequtl>'|| pr_nrpedido       ||'</vlsequtl>',2);

          -- Atualiza indicador informando que houve requisicoes rejeitadas para o PAC
          vr_idrejeit_tl := TRUE;
        END IF;

        IF NOT vr_idrejeit_fc THEN
          vr_fechapac_rej_fc := FALSE;
          pc_escreve_xml('<pac>'||
                           '<cdagenci>'||rw_crapreq.cdagenci||'</cdagenci>'||
                           '<nmresage>'||rw_crapage.nmresage||'</nmresage>'||
                           '<vlsequtl>'|| pr_nrpedido       ||'</vlsequtl>',4);

          -- Atualiza indicador informando que houve requisicoes rejeitadas para o PAC
          vr_idrejeit_fc := TRUE;
        END IF;

        -- Abre o cursor de tipo de conta
        OPEN cr_tpconta(pr_cdcooper,
                        rw_crapass.cdtipcta);
        FETCH cr_tpconta INTO rw_tpconta;
        IF cr_tpconta%NOTFOUND THEN
          rw_tpconta.dstipo_conta := '';
        END IF;
        CLOSE cr_tpconta;

        cada0006.pc_descricao_situacao_conta(pr_cdsituacao => rw_crapass.cdsitdct
                                            ,pr_dssituacao => vr_dssituacao
                                            ,pr_des_erro   => vr_des_erro
                                            ,pr_dscritic   => vr_dscritic);
        IF vr_des_erro = 'NOK' THEN
          vr_dssitdct := '';
        ELSE
          vr_dssitdct := rw_crapass.cdsitdct||'-'||vr_dssituacao;
        END IF;

        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);

        IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN -- Se for FC
          pc_escreve_xml('<rejeitado>'||
                           '<nrdconta>'||gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z')||'</nrdconta>'||
                           '<nmprimtl>'||rw_crapass.nmprimtl||'</nmprimtl>'||
                           '<dtdemiss>'||to_char(rw_crapass.dtdemiss,'DD/MM/YYYY')||'</dtdemiss>'||
                           '<dstipcta>'||lpad(rw_crapass.cdtipcta,2,'0')||'-'||rw_tpconta.dstipo_conta||'</dstipcta>'||
                           '<dssitdct>'||vr_dssitdct        ||'</dssitdct>'||
                           '<qtreqtal>'||rw_crapreq.qtreqtal||'</qtreqtal>'||
                           '<dscritic>'||substr(vr_dscritic,1,34)    ||'</dscritic>'||
                         '</rejeitado>',4);
          vr_qttotrej_fc := vr_qttotrej_fc + 1;
        ELSE
          pc_escreve_xml('<rejeitado>'||
                           '<nrdconta>'||gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z')||'</nrdconta>'||
                           '<nmprimtl>'||substr(rw_crapass.nmprimtl,1,30)||'</nmprimtl>'||
                           '<dtdemiss>'||to_char(rw_crapass.dtdemiss,'DD/MM/YYYY')||'</dtdemiss>'||
                           '<dstipcta>'||lpad(rw_crapass.cdtipcta,2,'0')||'-'||rw_tpconta.dstipo_conta||'</dstipcta>'||
                           '<dssitdct>'||vr_dssitdct        ||'</dssitdct>'||
                           '<qtreqtal>'||rw_crapreq.qtreqtal||'</qtreqtal>'||
                           '<dscritic>'||substr(vr_dscritic,1,34)||'</dscritic>'||
                         '</rejeitado>',2);
          vr_qttotrej_tl := vr_qttotrej_tl + 1;
        END IF;
        -- Atualiza a variavel de situacao de requisicao para depois atualizar na tabela CRAPREQ
        vr_insitreq := 3;
      END IF;

      IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN -- Se for FC
        vr_cdagenci_ant_fc := rw_crapreq.cdagenci;
      ELSE
        vr_cdagenci_ant := rw_crapreq.cdagenci;
      END IF;

      vr_indice := to_number(to_char(rw_crapreq.nrpedido)||to_char(rw_crapreq.nrdconta));
      vr_tab_pedido_conta(vr_indice).nrpedido_nrdconta:= vr_indice;

     end if;

    END LOOP;

    vr_tab_pedido_conta.delete;

    -- Verifica se a tag PAC das requisicoes de Talões esta fechada. Em caso negativo, fecha a tag.
    IF NOT vr_fechapac_req_tl THEN
      pc_escreve_xml(       '<qttotreq>'||vr_qttotreq_tl||'</qttotreq>'||
                            '<qttottrf>'||vr_qttottrf_tl||'</qttottrf>'||
                            '<qttotrej>'||vr_qttotrej_tl||'</qttotrej>'||
                          '</pac>',1);
    END IF;
    pc_escreve_xml(     '</requisicoes>',1);

    -- Verifica se a tag PAC das requisicoes de FC esta fechada. Em caso negativo, fecha a tag.
    IF NOT vr_fechapac_req_fc THEN
      pc_escreve_xml(       '<qttotreq>'||vr_qttotreq_fc||'</qttotreq>'||
                            '<qttottrf>'||vr_qttottrf_fc||'</qttottrf>'||
                            '<qttotrej>'||vr_qttotrej_fc||'</qttotrej>'||
                          '</pac>',3);
    END IF;
    pc_escreve_xml(     '</requisicoes>',3);

    -- Verifica se a tag PAC dos rejeitados de Talões esta fechada. Em caso negativo, fecha a tag.
    IF NOT vr_fechapac_rej_tl THEN
      pc_escreve_xml(     '</pac>',2);
    END IF;
    pc_escreve_xml(   '</rejeitados>'||
                     '</pedido>'||
                   '</crps408>',2);
    dbms_lob.append(vr_des_xml,vr_des_xml_rej);

    -- Verifica se a tag PAC dos rejeitados de FC esta fechada. Em caso negativo, fecha a tag.
    IF NOT vr_fechapac_rej_fc THEN
      pc_escreve_xml(     '</pac>',4);
    END IF;
    pc_escreve_xml(   '</rejeitados>'||
                     '</pedido>'||
                   '</crps408>',4);
    dbms_lob.append(vr_des_xml_fc,vr_des_xml_fc_rej);
    --
    IF pr_nmarqui1 IS NOT NULL THEN
    -- Chamada do iReport para gerar o arquivo de saida
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/crps408/pedido',    --> No base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl392.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => 'PR_NMEMPRES##'||vr_nmempres, --> Enviar como parametro apenas a agencia
                                pr_dsarqsaid => vr_nom_diretorio||'/rl/'||pr_nmarqui1||'.lst', --> Arquivo final
                                pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                pr_qtcoluna  => 132,
                                pr_sqcabrel  => 1,
                                pr_flg_impri => pr_flg_impri,       --> Indicador se imprimira o relatorio
                                pr_nrcopias  => 1,                  --> Numero de copias
                                pr_dsextmail => 'pdf', 
                                pr_dsmailcop => vr_email_dest, --> Lista sep. por ';' de emails para envio do arquivo
                                pr_dsassmail => 'PEDIDO DE TALONARIOS - ' || rw_crapcop.nmrescop, --> Assunto do e-mail que enviará o arquivo
                                pr_dscormail => NULL, --> HTML corpo do email que enviará o arquivo
                                pr_fldosmail => 'S', --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                pr_des_erro  => pr_dscritic);       --> Saida com erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    END IF;

    IF vr_qttotgerreq_fc > 0 THEN -- Gerar relatorio de FC somente se existir dados
      IF pr_nmarqui3 IS NOT NULL THEN      
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                  pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml_fc,       --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crps408/pedido',   --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl572.jasper',    --> Arquivo de layout do iReport
                                  pr_dsparams  => 'PR_NMEMPRES##'||vr_nmempres, --> Enviar como parametro apenas a agencia
                                  pr_dsarqsaid => vr_nom_diretorio||'/rl/'||pr_nmarqui3||'.lst', --> Arquivo final
                                  pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                  pr_qtcoluna  => 132,
                                  pr_sqcabrel  => 3,
                                  pr_flg_impri => pr_flg_impri,       --> Indicador se imprimira o relatorio
                                  pr_nrcopias  => 1,                  --> Numero de copias
                                  
                                  pr_dsextmail => 'pdf', 
                                  pr_dsmailcop => vr_email_dest, --> Lista sep. por ';' de emails para envio do arquivo
                                  pr_dsassmail => 'REQUISICAO DE FORMULARIO CONTINUO - ' || rw_crapcop.nmrescop, --> Assunto do e-mail que enviará o arquivo
                                  pr_dscormail => NULL, --> HTML corpo do email que enviará o arquivo
                                  pr_fldosmail => 'S', --> Flag para converter o arquivo gerado em DOS antes do e-mail

                                  pr_des_erro  => pr_dscritic);       --> Saida com erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;
    END IF;

    -- Liberando a memoria alocada para os CLOBs
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    dbms_lob.close(vr_des_xml_fc);
    dbms_lob.freetemporary(vr_des_xml_fc);
    dbms_lob.close(vr_des_xml_rej);
    dbms_lob.freetemporary(vr_des_xml_rej);
    dbms_lob.close(vr_des_xml_fc_rej);
    dbms_lob.freetemporary(vr_des_xml_fc_rej);


    ---------------------------------------------------------------------
    -- Inicio da geração do arquivo de cabecalho
    ---------------------------------------------------------------------

    -- Tenta abrir o arquivo de cabecalho em modo gravacao
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio||'/arq'   --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarqctrped             --> Nome do arquivo
                            ,pr_tipabert => 'W'                        --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_input_file_ctr          --> Handle do arquivo aberto
                            ,pr_des_erro => pr_dscritic);              --> Erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

      --  Header do Arq. para CENTRAL

      -- Calcula o digito da agencia
      vr_auxiliar := rw_crapcop.cdagectl * 10;
      vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_auxiliar); -- O retorno é ignorado, pois a variável vr_agencia é atualiza pelo programa
      vr_cddigage := MOD(vr_auxiliar,10);

      -- Calcula o C1
      vr_auxiliar  := to_char(rw_crapage.cdcomchq) || to_char(rw_crapcop.cdbcoctl,'fm000');
      vr_auxiliar2 := to_char(vr_auxiliar)||to_char(rw_crapcop.cdagectl,'fm0000')||'0';
      vr_retorno   := gene0005.fn_calc_digito(pr_nrcalcul => vr_auxiliar2);
      vr_cddigtc1  := MOD(vr_auxiliar2,10);

      --Escrever o cabecalho no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file_ctr --> Handle do arquivo aberto
                                    ,pr_des_text => rpad(rw_crapcop.nmrescop,20,' ') ||       -- IDENTIFIC
                                                    to_char(vr_dtmvtolt,'DD/MM/YYYY')||       -- DATA PEDIDO
                                                    to_char(pr_nrpedido,'fm000000')|| -- NR DO PEDIDO
                                                    to_char(rw_crapcop.cdbcoctl,'fm000')||    -- CD BANCO
                                                    to_char(rw_crapcop.cdagectl,'fm0000')||   -- CD AGENCIA
                                                    vr_cddigage||                             -- DIG. AGE.
                                                    vr_cddigtc1||                             -- DIGITO C1
                                                    to_char(vr_qttottal_tl,'fm00000')||       -- QTD TALONAR.
                                                    to_char(vr_qttotchq_tl,'fm000000')||      -- QTD FOL CHQ
                                                    to_char(pr_cdcooper,'fm000')||            -- COOPERATIVA
                                                    'CECRED     '||                           -- CENTRAL
                                                    '00'||                                    -- GRUPO SETEC
                                                    rpad(' ',305,' '));                       -- ESPACOS

      -- Quantidade de Linhas do Arquivo
      vr_qtlinhas := vr_qtlinhas + 1;

    -- Fecha o arquivo de cabecalho
    BEGIN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file_ctr); --> Handle do arquivo aberto;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Problema ao fechar o arquivo <'||vr_nmarqctrped||'>: ' || sqlerrm;
        RAISE vr_exc_saida;
    END;
 
    -- Deve gerar Trailer apenas se for RR Donnelley
    IF pr_cdempres = 2 THEN

      -- Inclui Registro Trailer
      vr_qtlinhas := vr_qtlinhas + 1;

      vr_dsarqdad := '99' ||
                     to_char(vr_qtlinhas,'fm000000')||  -- Qtd. Linhas
                     rpad(' ',369,' '); -- Brancos

      -- Escreve Registro Trailher
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file_dad --> Handle do arquivo aberto
                                     ,pr_des_text => vr_dsarqdad);

                                     
    END IF;

    -- Fecha o arquivo de detalhes
    BEGIN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file_dad); --> Handle do arquivo aberto;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Problema ao fechar o arquivo <'||vr_nmarqdadped||'>: ' || sqlerrm;
        RAISE vr_exc_saida;
    END;


    ---------------------------------------------------------------------
    -- Inicio da geração do resumo
    ---------------------------------------------------------------------


    -- Inicializar o CLOB para armazenar os arquivos XML
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      OPEN cr_crapban(pr_cdbanchq);
      FETCH cr_crapban INTO vr_nmbanco;
      CLOSE cr_crapban;

    -- Escreve o resumo para taloes
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>'||
                   '<crps408>'||
                     '<pedido>'||
                       '<vlsequtl>'||pr_nrpedido                      ||'</vlsequtl>'||
                       '<dtmvtolt>'||to_char(vr_dtmvtolt,'DD/MM/YYYY')||'</dtmvtolt>'||
                       '<nmbanco>' ||vr_nmbanco                       ||'</nmbanco>'||
                       '<qttotchq>'||vr_qttotchq_tl                   ||'</qttotchq>'||
                       '<qttottal>'||vr_qttottal_tl                   ||'</qttottal>'||
                       '<qtfoltal10>'||vr_qtfoltal_10                   ||'</qtfoltal10>'||
                       '<qtfoltal20>'||vr_qtfoltal_20                   ||'</qtfoltal20>'||
                       '<nmrescop>'|| rw_crapcop.nmrescop             ||'</nmrescop>'||
                       '<nrdocnpj>'|| TO_CHAR(gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)) ||'</nrdocnpj>'||
                     '</pedido>'||
                   '</crps408>',1);
    IF pr_nmarqui2 IS NOT NULL THEN
    -- Chamada do iReport para gerar o arquivo de saida
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/crps408/pedido',    --> No base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl393.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => 'PR_NMEMPRES##'||vr_nmempres, --> Enviar como parametro apenas a agencia
                                pr_dsarqsaid => vr_nom_diretorio||'/rl/'||pr_nmarqui2||'.lst', --> Arquivo final
                                pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                pr_qtcoluna  => 132,
                                pr_sqcabrel  => 2,
                                pr_flg_impri => pr_flg_impri,       --> Indicador se imprimira o relatorio
                                pr_nrcopias  => 2,                  --> Numero de copias
                                pr_dsextmail => 'pdf', 
                                pr_dsmailcop => vr_email_dest, --> Lista sep. por ';' de emails para envio do arquivo
                                pr_dsassmail => 'RESUMO PEDIDO DE TALONARIOS - ' || rw_crapcop.nmrescop, --> Assunto do e-mail que enviará o arquivo
                                pr_dscormail => NULL, --> HTML corpo do email que enviará o arquivo
                                pr_fldosmail => 'S', --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                pr_des_erro  => pr_dscritic);       --> Saida com erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    END IF;

    -- Liberando a memoria alocada para os CLOBs
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

    -- Escreve o resumo para Formulario continuo
    IF vr_qttotgerreq_fc > 0 THEN
      IF pr_nmarqui4 IS NOT NULL THEN
      vr_des_xml_fc := NULL;
      dbms_lob.createtemporary(vr_des_xml_fc, true);
      dbms_lob.open(vr_des_xml_fc, dbms_lob.lob_readwrite);

      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>'||
                     '<crps408>'||
                       '<pedido>'||
                         '<vlsequtl>'||pr_nrpedido                      ||'</vlsequtl>'||
                         '<dtmvtolt>'||to_char(vr_dtmvtolt,'DD/MM/YYYY')||'</dtmvtolt>'||
                         '<nmbanco>' ||vr_nmbanco                       ||'</nmbanco>'||
                         '<qttotchq>'||vr_qttottal_fc                   ||'</qttotchq>'||
                         '<qttotreq>'||vr_qttotgerreq_fc                ||'</qttotreq>'||
                       '</pedido>'||
                     '</crps408>',3);

      -- Gerar arquivos XML
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                  pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml_fc,       --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crps408/pedido',   --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl573.jasper',    --> Arquivo de layout do iReport
                                  pr_dsparams  => 'PR_NMEMPRES##'||vr_nmempres, --> Enviar como parametro apenas a agencia
                                  pr_dsarqsaid => vr_nom_diretorio||'/rl/'||pr_nmarqui4||'.lst', --> Arquivo final
                                  pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                  pr_qtcoluna  => 132,
                                  pr_sqcabrel  => 3,
                                  pr_flg_impri => pr_flg_impri,       --> Indicador se imprimira o relatorio
                                  pr_nrcopias  => 2,                  --> Numero de copias
                                  
                                  pr_dsextmail => 'pdf', 
                                  pr_dsmailcop => vr_email_dest, --> Lista sep. por ';' de emails para envio do arquivo
                                  pr_dsassmail => 'RESUMO REQUISICOES DE FORMULARIO CONTINUO - ' || rw_crapcop.nmrescop, --> Assunto do e-mail que enviará o arquivo
                                  pr_dscormail => NULL, --> HTML corpo do email que enviará o arquivo
                                  pr_fldosmail => 'S', --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                  
                                  pr_des_erro  => pr_dscritic);       --> Saida com erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memoria alocada para os CLOBs
      dbms_lob.close(vr_des_xml_fc);
      dbms_lob.freetemporary(vr_des_xml_fc);
    END IF;
    END IF;

    -- Acumula o arquivo de cabecalho com o arquivo de dados no arquivo principal
    gene0001.pc_OScommand_Shell(pr_des_comando => 'cat '||vr_nom_diretorio||'/arq/'||vr_nmarqctrped || ' ' ||
                                                          vr_nom_diretorio||'/arq/'||vr_nmarqdadped || ' > ' ||
                                                          vr_nom_diretorio||'/arq/'||vr_nmarqped    ||
                                                          ' 2> /dev/null');

    -- Gera o arquivo de transmissao vazio
    gene0001.pc_OScommand_Shell(pr_des_comando => '> '||vr_nom_diretorio||'/arq/'||vr_nmarqtransm || ' 2> /dev/null');

    -- Efetua o processo de copia e/ou exclusao de arquivos
    IF vr_flggerou THEN

      IF pr_cdempres = 1 THEN
        gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||vr_nom_diretorio||'/arq/'||vr_nmarqped || ' '||
                                     gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'DIR_NEXXERA'));
      ELSE

        -- Caminho do script que envia/recebe via SFTP
        vr_script    := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => '0'
                                                 ,pr_cdacesso => 'RRD_SCRIPT');
        -- Endereço do Servidor SFTP                                                      
        vr_serv_sftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => '0'
                                                ,pr_cdacesso => 'RRD_SERV_SFTP');
        -- Usuario do Servidor SFTP                                                      
        vr_user_sftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => '0'
                                                ,pr_cdacesso => 'RRD_USER_FTP');
        -- Password do Servidor SFTP 
        vr_pass_sftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => '0'
                                                ,pr_cdacesso => 'RRD_PASS_FTP');
        -- Diretotio Remoto de Upload no Servidor SFTP                                         
        vr_dir_remoto := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => '0'
                                                  ,pr_cdacesso => 'RRD_DIR_UPLOAD');

        vr_comando := vr_script                                      || ' ' || -- Script Shell
    --  '-recebe'                                                    || ' ' ||
        '-envia'                                                     || ' ' || -- Enviar/Receber
        '-srv '         || vr_serv_sftp                              || ' ' || -- Servidor
        '-usr '         || vr_user_sftp                              || ' ' || -- Usuario
        '-pass '        || vr_pass_sftp                              || ' ' || -- Senha
        '-arq '         || CHR(39) || vr_nmarqped || CHR(39)         || ' ' || -- Nome do Arquivo .RET
        '-dir_local '   || vr_nom_diretorio || '/arq/'               || ' ' || -- /usr/coop/<cooperativa>/arq
        '-dir_remoto '  || vr_dir_remoto                             || ' ' || -- /<conta do cooperado>/RETORNO
        '-salvar '      || vr_nom_diretorio || '/salvar'             || ' ' || -- /usr/coop/<cooperativa>/salvar
        '-log '         || vr_nom_diretorio || '/log/env_arq_ftp_rrd.log';     -- /usr/coop/<cooperativa>/log/cst_por_arquivo.log


        --Buscar parametros
        vr_dscomora:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_EXEC_SHELL');
        vr_dsdirbin:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_CECRED_BIN');

        -- Comando para criptografar o arquivo
        vr_comando:= vr_dscomora ||' perl_remoto ' || vr_comando;

        --vr_comando := replace(vr_comando,'coopd','coop');
        --vr_comando := replace(vr_comando,'cooph','coop');
        
        -- Ajuste temporario, apenas para garantir a
        -- geração do arquivo antes de enviar.
        IF pr_cdcooper = 1 THEN
          -- Aguardar 10 segundos
          sys.dbms_lock.sleep(10);
        END IF;  
        
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_des_saida);

        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          -- Envio Centralizado de Log de Erro
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- ERRO TRATATO
                                     pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                        ' -' || vr_cdprogra || ' --> ' ||
                                                        'ERRO ao enviar arquivo(' || vr_nmarqped ||
                                                        ') via SFTP - ' || vr_des_saida);
        END IF;

        -- Inicio SCTASK0017339   
        -- Validar se realmente ocorreu o FTP com sucesso, realiza download e verifica se arquivo existe
        vr_comando := vr_script                                      || ' ' || -- Script Shell
        '-recebe'                                                    || ' ' || -- Enviar/Receber
        '-srv '         || vr_serv_sftp                              || ' ' || -- Servidor
        '-usr '         || vr_user_sftp                              || ' ' || -- Usuario
        '-pass '        || vr_pass_sftp                              || ' ' || -- Senha
        '-arq '         || CHR(39) || vr_nmarqped || CHR(39)         || ' ' || -- Nome do Arquivo .RET
        '-dir_local '   || vr_nom_diretorio || '/arq/ver'            || ' ' || -- /usr/coop/<cooperativa>/arq/ver
        '-dir_remoto '  || vr_dir_remoto                             || ' ' || -- /<conta do cooperado>/RETORNO
        '-log '         || vr_nom_diretorio || '/log/ver_arq_ftp_rrd.log';     -- /usr/coop/<cooperativa>/log/cst_por_arquivo.log    
        
        -- Comando para criptografar o arquivo
        vr_comando:= vr_dscomora ||' perl_remoto ' || vr_comando;        
        
        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_des_saida);                           
        IF vr_typ_saida = 'ERR' OR vr_des_saida IS NOT NULL THEN
          -- Envio Centralizado de Log de Erro
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- ERRO TRATATO
                                     pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                        ' -' || vr_cdprogra || ' --> ' ||
                                                        'ERRO ao copiar arquivo para validação (' || vr_nmarqped ||
                                                        ') via SFTP - ' || vr_des_saida);          
        END IF;     

        --Listar arquivo
        gene0001.pc_lista_arquivos( pr_path     => vr_nom_diretorio|| '/arq/ver/'
                                   ,pr_pesq     => vr_nmarqped
                                   ,pr_listarq  => vr_lista_nmarq
                                   ,pr_des_erro => vr_dscritic);
        vr_arquivo_zip := null; 
        -- Verificar se encontrou arquivo
        if trim(vr_lista_nmarq) is null then
          -- Necessário verificar se o Arquivo esta no diretório ainda, ou esta em salvar
          gene0001.pc_lista_arquivos( pr_path     => vr_nom_diretorio|| '/arq/'
                                     ,pr_pesq     => vr_nmarqped
                                     ,pr_listarq  => vr_lista_nmarq
                                     ,pr_des_erro => vr_dscritic);          
          
          
          IF trim(vr_lista_nmarq) is not null THEN -- Diretório onde arquivo é gerado
            vr_arquivo_zip := vr_nom_diretorio||'/arq/'||vr_nmarqped;
          ELSE
            gene0001.pc_lista_arquivos( pr_path     => vr_nom_diretorio|| '/salvar/'
                                       ,pr_pesq     => vr_nmarqped
                                       ,pr_listarq  => vr_lista_nmarq
                                       ,pr_des_erro => vr_dscritic);         
            IF trim(vr_lista_nmarq) is not null THEN                                
               vr_arquivo_zip := vr_nom_diretorio||'/salvar/'||vr_nmarqped;            
            END IF;
          END IF;
            
          if vr_arquivo_zip is not null then
            gene0002.pc_zipcecred(pr_cdcooper => pr_cdcooper                 --> Cooperativa conectada
                                 ,pr_tpfuncao => 'A'
                                 ,pr_dsorigem => vr_arquivo_zip                 --> Lista de arquivos a compactar (separados por espaço)
                                 ,pr_dsdestin => vr_arquivo_zip||'.zip' --> Caminho para o arquivo Zip a gerar
                                 ,pr_dspasswd => NULL
                                 ,pr_des_erro => vr_des_saida);   
            IF vr_des_saida IS NOT NULL THEN
              -- Envio Centralizado de Log de Erro
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- ERRO TRATATO
                                         pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                            ' -' || vr_cdprogra || ' --> ' ||
                                                            'ERRO ao zipar arquivo para e-mail (' || vr_nmarqped ||
                                                            ') via SFTP - ' || vr_des_saida);          
            END IF; 
          end if;  
          
          -- Envia e-mail para área de suprimentos com o Arquivo
          pc_envia_email_arq(pr_cdcooper => pr_cdcooper
                            ,pr_dsorigem => vr_arquivo_zip -- Caminho com nome do Arquivo
                            ,pr_des_erro => vr_des_saida);
          IF vr_des_saida IS NOT NULL THEN
            -- Envio Centralizado de Log de Erro
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, -- ERRO TRATATO
                                       pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                          ' -' || vr_cdprogra || ' --> ' ||
                                                          'ERRO ao enviar email para sustentação (' || vr_nmarqped ||
                                                          ') via SFTP - ' || vr_des_saida);          
          END IF; 

                              
        ELSE
          -- Remove arquivo do servidor
          gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||vr_nom_diretorio ||'/arq/ver/'|| vr_nmarqped);
          gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nom_diretorio||'/arq/ver/'||vr_nmarqped||' 2> /dev/null');          
        END IF;
        -- Fim SCTASK0017339   

      END IF;
    ELSE
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nom_diretorio||'/arq/'||vr_nmarqdadped||' 2> /dev/null');
    END IF;

    -- Efetua a movimentacao para o diretorio SALVAR
    gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nom_diretorio||'/arq/'||vr_nmarqped || ' '||
                                                         vr_nom_diretorio||'/salvar');

    OPEN cr_crapfdc(null,null);
    FETCH cr_crapfdc INTO rw_crapfdc;
    WHILE cr_crapfdc%found LOOP
      UPDATE tbchq_seguranca_cheque a
      SET a.idstatus_atualizacao_hsm=4
      WHERE rowid = rw_crapfdc.linha;
      FETCH cr_crapfdc INTO rw_crapfdc;
    END LOOP;
    close cr_crapfdc;
 
  END pc_gera_arquivo;


/*------------------------------------
-- INICIO DA ROTINA PRINCIPAL
--------------------------------------*/
BEGIN

  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'CHEQ0003.pc_gera_arq_grafica_cheque',
                             pr_action => vr_cdprogra);


  -- Busca os dados da cooperativa
  OPEN cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  IF cr_crapcop%NOTFOUND THEN
    CLOSE cr_crapcop;
    pr_cdcritic := 651;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_crapcop;

  -- Busca a data do movimento
  OPEN cr_crapdat(pr_cdcooper);
    FETCH cr_crapdat INTO vr_dtmvtolt;
  CLOSE cr_crapdat;

  -- Rotina para buscar o diretorio onde o arquivo sera gerado
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper); --> Utilizaremos o rl

    vr_cdempres := 2; -- RR Donnelley

    --Recuperar emails de destino
    vr_email_dest := gene0001.fn_param_sistema('CRED',0,'CRPS408_EMAIL_RRD');

  -- CECRED
  if pr_tprequis = 1 then
    pc_gera_arquivo(pr_cdcooper     => pr_cdcooper,
                    pr_cdbanchq     => rw_crapcop.cdbcoctl,
                    pr_nrcontab     => 0,
                    pr_nrdserie     => 1,
                    pr_nmarqui1     => 'crrl392_03',
                    pr_nmarqui2     => 'crrl393_03',
                    pr_nmarqui3     => NULL, --'crrl572_03',
                    pr_nmarqui4     => NULL, --'crrl573_03',
                    pr_flg_impri    => 'S',
                    pr_cdempres     => vr_cdempres,
                    pr_tprequis     => 1);
  end if;                  
  
  -- CECRED
  if pr_tprequis = 3 then
    pc_gera_arquivo(pr_cdcooper     => pr_cdcooper,
                    pr_cdbanchq     => rw_crapcop.cdbcoctl,
                    pr_nrcontab     => 0,
                    pr_nrdserie     => 1,
                    pr_nmarqui1     => NULL, --'crrl392_03',
                    pr_nmarqui2     => NULL, --'crrl393_03',
                    pr_nmarqui3     => 'crrl572_03',
                    pr_nmarqui4     => 'crrl573_03',
                    pr_flg_impri    => 'S',
                    pr_cdempres     => vr_cdempres,
                    pr_tprequis     => 3);   
  end if;

  -- Testar se houve erro
  IF pr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    pr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  --
  COMMIT;
EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || pr_dscritic );
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit
    COMMIT;
    pr_cdcritic := 0;
    pr_dscritic := NULL;

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
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;



END pc_gera_arq_grafica_cheque;

PROCEDURE pc_obtem_hashcode (pr_nrcpfcnpj IN NUMBER,
                             pr_nrdconta IN NUMBER,
                             pr_nrdocumento IN NUMBER,
                             pr_cdhashcode OUT VARCHAR2) IS
                             
BEGIN
  SELECT a.cdhashcode
  INTO pr_cdhashcode
  FROM tbchq_seguranca_cheque a
  WHERE a.nrcpfcnpj = pr_nrcpfcnpj
    AND a.nrdconta = pr_nrdconta
    AND a.nrcheque = pr_nrdocumento;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    pr_cdhashcode:=null;
END pc_obtem_hashcode;


END CHEQ0003;
/
