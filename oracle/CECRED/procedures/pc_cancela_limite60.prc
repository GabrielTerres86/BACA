CREATE OR REPLACE PROCEDURE CECRED.PC_CANCELA_LIMITE60(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa
                                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                                      ,pr_dscritic OUT VARCHAR2) AS           --> Texto de erro/critica encontrada
  BEGIN
    /* ............................................................................
     Programa: PC_CANCELA_LIMITE60
     Sistema : Atenda - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Daniel Silva(AMcom)
     Data    : Março/2018                           Ultima atualizacao: 15/03/2018

     Dados referentes ao programa:

     Frequencia: Diária
     Objetivo  : Cancelar limites de crédito para contas com atraso igual ou maior que 60 dias
     Alteracoes:
    ..............................................................................*/

  DECLARE
  --*** VARIÁVEIS ***--
    vr_exc_saida exception;
    vr_exc_fimprg exception;
    vr_cdcritic crapcri.cdcritic%TYPE; -- Codigo da critica
    vr_dscritic VARCHAR2(2000);        -- Descricao da critica
    vr_inusatab BOOLEAN := FALSE;
    vr_des_reto VARCHAR2(3);
    vr_tab_erro GENE0001.typ_tab_erro;

    -- Cursor Genérico de Calendário
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  --**************************--
  --*** CURSORES GENÉRICOS ***--
  --**************************--
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

    -- Calendário da cooperativa selecionada
    CURSOR cr_dat(pr_cdcooper INTEGER) IS
    SELECT dat.dtmvtolt
         , (SELECT MAX(dtrefere) FROM crapris WHERE cdcooper = pr_cdcooper) dtmvtoan
         , dat.dtultdma
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
    rw_dat cr_dat%ROWTYPE;

    -- Busca conta corrente que possui limite de crédito e está em ADP
    CURSOR cr_conta(pr_cdcooper INTEGER) IS
    SELECT DISTINCT ris.cdcooper, ris.nrdconta, ris.nrctremp, rlim.nrctremp nrctrlim
      FROM crapris ris, crapass ass
         , (SELECT r.cdcooper, r.nrdconta, r.nrctremp, r.dtrefere
              FROM crapris r
             WHERE r.cdcooper = pr_cdcooper
               AND r.dtrefere = rw_dat.dtmvtoan -- Buscar Central Atual **Antes de Rodar a Central de Risco               
               AND r.cdmodali = 201) rlim -- Limite de crédito
     WHERE rlim.cdcooper = ris.cdcooper
       AND rlim.nrdconta = ris.nrdconta
       AND rlim.dtrefere = ris.dtrefere
       AND ris.cdcooper  = ass.cdcooper
       AND ris.nrdconta  = ass.nrdconta
       AND ass.flcnaulc  = 1 -- Cancelamento automatico do Limite de Crédito igual 'Sim'
       AND ris.qtdiaatr >= 60
       AND ris.cdmodali  = 101 -- ADP
       AND ris.cdorigem  = 1   -- Conta corrente
       AND ris.dtrefere  = rw_dat.dtmvtoan -- Buscar Central Atual **Antes de Rodar a Central de Risco
       AND ris.cdcooper  = pr_cdcooper;
     rw_conta cr_conta%ROWTYPE;

  --**************************--
  --***     PROCEDURES     ***--
  --**************************--
    -- Cancela limite de crédito
    PROCEDURE pc_cancela_limite(pr_cdcooper IN NUMBER         -- Cooperativa
                               ,pr_nrdconta IN NUMBER         -- Conta Corrente
                               ,pr_nrctrlim IN NUMBER         -- Contrato de Limite
                               ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                               ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Efetua cancelamento dos limites
        UPDATE craplim lim
           SET lim.insitlim        = 3 -- Cancelado
             , lim.ininadim        = 1 -- Inadimplencia
             , lim.cdmotcan        = 0
             , lim.cdopeexc        = '1'
             , lim.cdageexc        = 0
             , lim.dtinsexc = rw_dat.dtmvtolt
             , lim.dtfimvig = rw_dat.dtmvtolt
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.nrctrlim = pr_nrctrlim
           AND lim.tpctrlim = 1  -- Cheque especial
           AND lim.insitlim = 2; -- Ativo
         --
       EXCEPTION
         WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Erro PC_CANCELA_LIMITE: '||SQLERRM;
           -- Efetuar rollback
           ROLLBACK;
    END pc_cancela_limite;

    -- Cancela limite de crédito Conta
    PROCEDURE pc_cancela_limite_cta(pr_cdcooper IN NUMBER         -- Cooperativa
                                   ,pr_nrdconta IN NUMBER         -- Conta Corrente
                                   ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Efetua cancelamento dos limites
        UPDATE crapass ass
           SET ass.vllimcre = 0
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
         --
       EXCEPTION
         WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Erro PC_CANCELA_LIMITE_CTA: '||SQLERRM;
           -- Efetuar rollback
           ROLLBACK;
    END pc_cancela_limite_cta;

    -- Cancela Microfilmagem
    PROCEDURE pc_cancela_microfilmagem(pr_cdcooper IN NUMBER  -- Cooperativa
                                      ,pr_nrdconta IN NUMBER         -- Conta Corrente
                                      ,pr_nrctrlim IN NUMBER         -- Contrato de Limite
                                      ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Efetua cancelamento da microfilmagem
        -- Somente para registros com data de início de vigência maior que 04/01/2003(Regra TELA_ATENDA_OCORRENCIAS)
        UPDATE crapmcr mcr
           SET mcr.dtcancel = rw_dat.dtmvtolt
         WHERE mcr.cdcooper = pr_cdcooper
           AND mcr.nrdconta = pr_nrdconta
           AND mcr.nrcontra = pr_nrctrlim
           AND EXISTS (SELECT 1
                         FROM craplim lim
                        WHERE lim.cdcooper = mcr.cdcooper
                          AND lim.nrdconta = mcr.nrdconta
                          AND lim.nrctrlim = mcr.nrcontra
                          AND lim.dtinivig >= '04/01/2003');
         --
       EXCEPTION
         WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Erro PC_CANCELA_MICROFILMAGEM: '||SQLERRM;
           -- Efetuar rollback
           ROLLBACK;
    END pc_cancela_microfilmagem;

    --************************--
    --   INICIO DO PROGRAMA   --
    --************************--
    BEGIN
      vr_cdcritic := NULL;
      vr_dscritic := NULL;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;

      -- Se não encontrar registro da cooperativa
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Busca calendário para a cooperativa selecionada
      OPEN cr_dat(pr_cdcooper);
      FETCH cr_dat INTO rw_dat;
      -- Se não encontrar calendário
      IF cr_dat%NOTFOUND THEN
        CLOSE cr_dat;
        -- Montar mensagem de critica
        vr_cdcritic  := 794;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_dat;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        RAISE vr_exc_saida;
      ELSE
         -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
    --************************--
    --  INICIO PROCESSAMENTO  --
    --************************--      
      BEGIN
        FOR rw_conta IN cr_conta(pr_cdcooper) LOOP

          pc_cancela_limite(pr_cdcooper => pr_cdcooper        -- Cooperativa
                           ,pr_nrdconta => rw_conta.nrdconta  -- Conta Corrente
                           ,pr_nrctrlim => rw_conta.nrctrlim  -- Contrato de Limite
                           ,pr_cdcritic => vr_cdcritic        -- Código da crítica
                           ,pr_dscritic => vr_dscritic);      -- Erros do processo
          -- Verifica erro
          IF vr_cdcritic = 0 THEN
            RAISE vr_exc_saida;
          END IF;

          pc_cancela_limite_cta(pr_cdcooper => pr_cdcooper        -- Cooperativa
                               ,pr_nrdconta => rw_conta.nrdconta  -- Conta Corrente
                               ,pr_cdcritic => vr_cdcritic        -- Código da crítica
                               ,pr_dscritic => vr_dscritic);      -- Erros do processo
          -- Verifica erro
          IF vr_cdcritic = 0 THEN
            RAISE vr_exc_saida;
          END IF;

          pc_cancela_microfilmagem(pr_cdcooper => pr_cdcooper        -- Cooperativa
                                  ,pr_nrdconta => rw_conta.nrdconta  -- Conta Corrente
                                  ,pr_nrctrlim => rw_conta.nrctrlim  -- Contrato de Limite
                                  ,pr_cdcritic => vr_cdcritic        -- Código da crítica
                                  ,pr_dscritic => vr_dscritic);      -- Erros do processo
          -- Verifica erro
          IF vr_cdcritic = 0 THEN
            RAISE vr_exc_saida;
          END IF;

          -- Desativar Rating
          -- RATI0001.pc_desativa_rating
          -- Desativar o Rating associado a esta operação
          rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper          -- Cooperativa
                                     ,pr_cdagenci   => 0                    -- Agência
                                     ,pr_nrdcaixa   => 0                    -- Caixa
                                     ,pr_cdoperad   => '1'                  -- Operador
                                     ,pr_rw_crapdat => rw_crapdat           -- Vetor com dados de parâmetro (CRAPDAT)
                                     ,pr_nrdconta   => rw_conta.nrdconta    -- Conta do associado
                                     ,pr_tpctrrat   => 1                    -- Tipo do Rating (1-Limite de crédito)
                                     ,pr_nrctrrat   => rw_conta.nrctrlim    -- Contrato de Rating
                                     ,pr_flgefeti   => 'S'                  -- Flag para efetivação ou não do Rating
                                     ,pr_idseqttl   => 1                    -- Sequencia de titularidade da conta
                                     ,pr_idorigem   => 1                    -- Indicador da origem da chamada
                                     ,pr_inusatab   => vr_inusatab          -- Indicador de utilização da tabela de juros
                                     ,pr_nmdatela   => 'PC_CANCELA_LIMITE60'-- Nome datela conectada
                                     ,pr_flgerlog   => 'N'                  -- Gerar log S/N
                                     ,pr_des_reto   => vr_des_reto          -- Retorno OK / NOK
                                     ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros
           -- Verifica erro
           IF vr_des_reto = 'NOK' THEN
             --Se tem erro na tabela 
             IF vr_tab_erro.COUNT = 0 THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro na rati0001.pc_desativa_rating';
             ELSE
               vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
             END IF;    
             --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;
           --
        END LOOP;
        -- 
        COMMIT;
        --
      END;
    EXCEPTION
      WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro PC_CANCELA_LIMITE60. Detalhes: '||vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Retornar o erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na rotina PC_CANCELA_LIMITE60. Detalhes: '||sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
END PC_CANCELA_LIMITE60;
/