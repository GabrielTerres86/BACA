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
                                                                                   
END CHEQ0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CHEQ0003 AS
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CHEQ0003
  --  Sistema  : Rotinas focadas no sistema de Cheques - Devolução automática de cheques
  --  Sigla    : CHEQ
  --  Autor    : Andre (Mouts)
  --  Data     : Outubro/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Processar a devolução automática de cheques 
  --               
  --   Alteracoes: 18/02/2019 - Incluir nova procedure pc_gera_pesq_deposito_cheque
  --                            Problema PRB0040612 (Andre - MoutS)
  --               16/04/2019 - Remover verificação de Dev. Aut. Cheques para cheques com Contra-Ordem
                                RITM0011849 (Jefferson - MoutS)
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
                                              pr_cdhistor => (CASE pr_tpopechq WHEN 1 THEN 351 ELSE 399 END), 
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
                                          pr_cdhistor => (CASE pr_tpopechq WHEN 1 THEN 351 ELSE 399 END), 
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

END CHEQ0003;
/
