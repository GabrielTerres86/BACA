PL/SQL Developer Test script 3.0
391
DECLARE
  vr_dscritic        VARCHAR2(2000);

  FUNCTION fn_busca_situacao_proposta(pr_cdcooper  IN craplim.cdcooper%TYPE
                                     ,pr_nrdconta  IN craplim.nrdconta%TYPE
                                     ,pr_nrctrato  IN craplim.nrctrlim%TYPE
                                     ,pr_tpctrato  IN craplim.tpctrlim%TYPE
                                     ,pr_cdcritic OUT INTEGER
                                     ,pr_dscritic OUT VARCHAR2) RETURN VARCHAR2 IS
    -- Tratamento de erros
    vr_exc_saida            EXCEPTION;
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             crapcri.dscritic%TYPE;
    --
    vr_insitest             NUMBER(2);
    --
  BEGIN
    IF Nvl(pr_tpctrato,0) = 90 THEN --Empréstimo
      BEGIN
        SELECT a.insitest
        INTO   vr_insitest
        FROM   crawepr  a
        WHERE  a.cdcooper = pr_cdcooper
        AND    a.nrdconta = pr_nrdconta
        AND    a.nrctremp = pr_nrctrato
        AND    NOT EXISTS (SELECT 1
                           FROM   crapepr  b
                           WHERE  b.cdcooper = a.cdcooper
                           AND    b.nrdconta = a.nrdconta
                           AND    b.nrctremp = a.nrctremp);
      EXCEPTION
        WHEN No_Data_Found THEN
          vr_insitest := NULL;
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao Verificar Situação da Proposta de Empréstimo. Coop: '||pr_cdcooper||' | Conta: '||pr_nrdconta||' | Contrato: '||pr_nrctrato||'. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_exc_saida;
      END;
    END IF;
    --Retorno
    RETURN (vr_insitest);
    --
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro Geral ao Buscar Situação da Proposta. Coop: '||pr_cdcooper||' | Conta: '||pr_nrdconta||' | Tipo: '||pr_tpctrato||' | Contrato: '||pr_nrctrato||'. Erro: '||SubStr(SQLERRM,1,255);
  END fn_busca_situacao_proposta;

  PROCEDURE pc_grava_rating_manual(pr_cdcooper        IN crapass.cdcooper%TYPE --> Cooperativa
                                  ,pr_nrdconta        IN crapass.nrdconta%TYPE --> CONTA
                                  ,pr_nrctrato        IN crapepr.nrctremp%TYPE --> CONTRATO
                                  ,pr_tpctrato        IN INTEGER
                                  ,pr_nrcpfcnpj_base  IN crapass.nrcpfcnpj_base%TYPE DEFAULT NULL--> CPF/CNPJ
                                  ,pr_rating_sugerido IN VARCHAR2
                                  ,pr_justificativa   IN VARCHAR2
                                  ,pr_cdoperad_rat    IN crapope.cdoperad%TYPE
                                  ,pr_dsorigem        IN VARCHAR2
                                  ,pr_nmdatela        IN VARCHAR2   -- Tela que acionou a rotina
                                  ,pr_nmrotina        IN VARCHAR2   -- Nome da Rotina da tela
                                  ,pr_dscritic        OUT VARCHAR2
                                   ) IS

    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic      VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_exc_sair      EXCEPTION;

    vr_dstransa      VARCHAR2(500);
    vr_nrdrowid      ROWID;
    vr_rating_antes  VARCHAR2(2);
    vr_rat_sugerido       tbrisco_operacoes.inrisco_rating%TYPE;
    vr_rat_efetivo        tbrisco_operacoes.inrisco_rating%TYPE;
    vr_insituacao_rating  tbrisco_operacoes.insituacao_rating%TYPE;
    vr_dtrisco_rating     tbrisco_operacoes.dtrisco_rating%TYPE;
    vr_nrcpfcnpj_base     crapass.nrcpfcnpj_base%TYPE;
    vr_nrctrato           crawlim.nrctrlim%TYPE; -- Codigo contrato pai quando proposta majorada
    vr_rating_sugerido    tbrating_historicos.ds_justificativa%TYPE;

    vr_insit_proposta     NUMBER(2);                                --14/01/2020 - Estórias 27285, 27286, 27288, 27289 - Alteração nota de Rating e Risco Inclusão.
    vr_innivris           tbrisco_operacoes.insituacao_rating%TYPE; --14/01/2020 - Estórias 27285, 27286, 27288, 27289 - Alteração nota de Rating e Risco Inclusão.

   CURSOR cr_crawlim_maj(pr_nrctrlim IN crawlim.nrctrlim%TYPE) is
     SELECT nrctrmnt                   -- Numero do Contrato a sofrer Manutencao
       FROM crawlim
      WHERE tpctrlim = 3
        AND cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND nrctrlim = pr_nrctrlim;

   CURSOR cr_tbrisco_operacoes(pr_nrctrlim IN crawlim.nrctrlim%TYPE) IS
     SELECT nvl(trim(o.inrisco_rating),o.inrisco_rating_autom) inrisco_rating
           ,o.insituacao_rating
           ,o.dtrisco_rating
           ,o.idrating
       FROM tbrisco_operacoes o
      WHERE o.cdcooper       = pr_cdcooper
        AND o.nrdconta       = pr_nrdconta
        AND o.nrctremp       = pr_nrctrlim
        AND o.tpctrato       = pr_tpctrato;

  CURSOR cr_crapass (pr_cdcooper  IN crapass.cdcooper%TYPE     --> Coop. conectada
                    ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS --> Codigo Conta
  SELECT ass.nrcpfcnpj_base
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.nrdconta = pr_nrdconta;

   CURSOR cr_tbrating_detalhes(pr_idrating IN tbrating_detalhes.idrating%TYPE) IS
     SELECT a.flpermite_alterar
           ,a.idrating
     FROM   tbrating_detalhes  a
     WHERE  a.idrating = pr_idrating;
   rw_tbrating_detalhes cr_tbrating_detalhes%ROWTYPE;

   rw_crapass           cr_crapass%ROWTYPE;
   rw_tbrisco_operacoes cr_tbrisco_operacoes%ROWTYPE;
   rw_crapdat           btch0001.cr_crapdat%ROWTYPE;
   rw_crawlim_maj       cr_crawlim_maj%rowtype;

  BEGIN

    IF pr_nrcpfcnpj_base IS NULL THEN
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;
      vr_nrcpfcnpj_base := rw_crapass.nrcpfcnpj_base;
    ELSE
      vr_nrcpfcnpj_base := pr_nrcpfcnpj_base;
    END IF;

    vr_rating_sugerido := upper(pr_rating_sugerido);
    vr_nrctrato := pr_nrctrato;

    -- Busca a data do sistema
    OPEN BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    -- Apenas para pegar o Rating atual do contrato
    OPEN cr_tbrisco_operacoes(pr_nrctrlim => vr_nrctrato);
    FETCH cr_tbrisco_operacoes INTO rw_tbrisco_operacoes;

    vr_rating_antes := RISC0004.fn_traduz_risco(innivris => rw_tbrisco_operacoes.inrisco_rating );
    vr_rat_sugerido := RISC0004.fn_traduz_nivel_risco(pr_dsnivris => vr_rating_sugerido);

    -- Alterado manualmente, SEMPRE efetiva
    vr_insituacao_rating := 4;
    vr_rat_efetivo       := vr_rat_sugerido;

    -- CHAMAR A ROTINA DE GRAVAR O RATING
    -- pc_grava_rating_operacao....
    RATI0003.pc_grava_rating_operacao(pr_cdcooper           => pr_cdcooper,
                                      pr_nrdconta           => pr_nrdconta,
                                      pr_tpctrato           => pr_tpctrato,
                                      pr_nrctrato           => vr_nrctrato,
                                      pr_strating           => vr_insituacao_rating,
                                      pr_ntrataut           => vr_rat_sugerido,
                                      pr_ntrating           => vr_rat_sugerido,
                                      pr_dtrataut           => rw_crapdat.dtmvtolt,
                                      pr_dtrating           => rw_crapdat.dtmvtolt,
                                      pr_orrating           => 6,  -- nova Origem => 6-MANUAL
                                      pr_cdoprrat           => pr_cdoperad_rat,
                                      pr_nrcpfcnpj_base     => vr_nrcpfcnpj_base,
                                      pr_cdoperad           => pr_cdoperad_rat,
                                      pr_dtmvtolt           => rw_crapdat.dtmvtolt,
                                      pr_justificativa      => pr_justificativa,
                                      pr_cdcritic           => vr_cdcritic,
                                      pr_dscritic           => vr_dscritic);
    IF vr_cdcritic <> 0
    OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    ELSE
      vr_insit_proposta := fn_busca_situacao_proposta(pr_cdcooper => pr_cdcooper
                                                     ,pr_nrdconta => pr_nrdconta
                                                     ,pr_nrctrato => vr_nrctrato
                                                     ,pr_tpctrato => pr_tpctrato
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);
      IF Nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      --Se for proposta e estiver com Análise Finalizada
      IF Nvl(vr_insit_proposta,-1) = 3 THEN
        --Busca Risco Detalhes
        OPEN cr_tbrating_detalhes(rw_tbrisco_operacoes.idrating);
        FETCH cr_tbrating_detalhes
        INTO  rw_tbrating_detalhes;
        IF cr_tbrating_detalhes%NOTFOUND THEN
          rw_tbrating_detalhes.flpermite_alterar := 1; --Permite Alterar Rating Manual se não encontrar registro na Risco Detalhes
        END IF;
        CLOSE cr_tbrating_detalhes;

        --Se Indicador da Risco Detalhes estiver "Permite Alterar" (flpermite_alterar = 1)
        --ou não encontrou registro na Risco Detalhes
        --e Proposta estiver com Análise Finalizada
        IF Nvl(rw_tbrating_detalhes.flpermite_alterar,0) = 1 THEN
          -- Atualizar Flag Permite Alterar da Risco Detalhes
          rati0005.pc_altera_flag_alterar(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctrato => vr_nrctrato
                                         ,pr_tpctrato => pr_tpctrato
                                         ,pr_flgalter => 0 --Não Permite Alterar
                                         ,pr_dscritic => vr_dscritic);
          IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
          END IF;
        END IF;

         risc0004.pc_calcula_risco_inclusao(pr_cdcooper   => pr_cdcooper
                                           ,pr_nrdconta   => pr_nrdconta
                                           ,pr_dsctrliq   => NULL
                                           ,pr_rw_crapdat => rw_crapdat
                                           ,pr_nrctremp   => vr_nrctrato
                                           ,pr_tpctrato   => pr_tpctrato
                                           ,pr_innivris   => vr_innivris
                                           ,pr_cdcritic   => vr_cdcritic
                                           ,pr_dscritic   => vr_dscritic);
         IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_saida;
         END IF;

         risc0004.pc_grava_risco_inclusao(pr_cdcooper         => pr_cdcooper
                                         ,pr_nrdconta         => pr_nrdconta
                                         ,pr_nrctremp         => pr_nrctrato
                                         ,pr_tpctrato         => pr_tpctrato
                                         ,pr_nrcpfcnpj_base   => vr_nrcpfcnpj_base
                                         ,pr_inrisco_inclusao => vr_innivris
                                         ,pr_dscritic         => vr_dscritic);
         IF TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_saida;
         END IF;
      END IF;
      --Fim 14/01/2020 - Estórias 27285, 27286, 27288, 27289 - Alteração nota de Rating e Risco Inclusão.
    END IF;

    -- Se for um contrato já efetivado
    IF vr_insit_proposta IS NULL THEN
      rati0005.pc_altera_flag_alterar(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctrato => pr_nrctrato
                                     ,pr_tpctrato => pr_tpctrato
                                     ,pr_flgalter => 0 -- Não
                                     ,pr_dscritic => vr_dscritic);
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;

    --P450 - 23218 - Atualizar o Tipo do Rating para Manual
    rati0005.pc_altera_tprating_detalhes( pr_cdcooper      => pr_cdcooper
                                         ,pr_nrdconta      => pr_nrdconta
                                         ,pr_nrctrato      => pr_nrctrato
                                         ,pr_tpctrato      => pr_tpctrato
                                         ,pr_intipo_rating => 3  -- 1-Concessao / 2-Manutencao / 3-Manual
                                         ,pr_cdcritic      => vr_cdcritic
                                         ,pr_dscritic      => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- VERLOG - Gerar log das Alterações
    vr_dstransa := 'RATING - ALTERACAO MANUAL - ' ||
                           'DE ' || upper(vr_rating_antes) || ' PARA ' || vr_rating_sugerido;
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad_rat
                        ,pr_dscritic => vr_dscritic
                        ,pr_dsorigem => 'AIMARO'
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 0
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    -- Log do Item - Campo Contrato
    GENE0001.pc_gera_log_item
                    (pr_nrdrowid => vr_nrdrowid
                    ,pr_nmdcampo => 'Contrato'
                    ,pr_dsdadant => ' '
                    ,pr_dsdadatu => pr_nrctrato);
    -- Log do Item - Campo Rating
    GENE0001.pc_gera_log_item
                    (pr_nrdrowid => vr_nrdrowid
                    ,pr_nmdcampo => 'Valor Rating'
                    ,pr_dsdadant => vr_rating_antes
                    ,pr_dsdadatu => vr_rating_sugerido);
    -- Log do Item - Campo Justificativa
    GENE0001.pc_gera_log_item
                    (pr_nrdrowid => vr_nrdrowid
                    ,pr_nmdcampo => 'Justificativa'
                    ,pr_dsdadant => ' '
                    ,pr_dsdadatu => pr_justificativa);
    -- Log do Item - Campo Operador
    GENE0001.pc_gera_log_item
                    (pr_nrdrowid => vr_nrdrowid
                    ,pr_nmdcampo => 'Operador'
                    ,pr_dsdadant => ' '
                    ,pr_dsdadatu => pr_cdoperad_rat);
    -- Log do Item - Campo Origem
    GENE0001.pc_gera_log_item
                    (pr_nrdrowid => vr_nrdrowid
                    ,pr_nmdcampo => 'Origem'
                    ,pr_dsdadant => ' '
                    ,pr_dsdadatu => nvl(pr_nmrotina,pr_nmdatela) || '/' ||pr_dsorigem);
    -- VERLOG - Gerar log das Alterações

  EXCEPTION
    WHEN vr_exc_sair THEN
      pr_dscritic := 'Endividamento do cooperado, não atingiu o valor mínimo para a analise de Rating! ';

    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;

    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral ao gravar Rating Manual: ' ||
                     SQLERRM;

  END pc_grava_rating_manual;
/*
PF/PJ Conta Contrato  Score Interno (BS)  Score Externo (CS)  Segmento  Dias de Atraso Hoje Rating Novo
PF  43  9939  354 359 AVALISTAS 0 A
PJ  1201  2762  344 291 COMPOSICAO  0 C
PJ  1201  3858  344 291 COMPOSICAO  0 C
PJ  16500 2490  326 257 COMPOSICAO  0 D
*/
BEGIN
  pc_grava_rating_manual(pr_cdcooper => 10
                        ,pr_nrdconta => 43
                        ,pr_nrctrato => 9939
                        ,pr_tpctrato => 90
                        ,pr_rating_sugerido => 'A'
                        ,pr_justificativa => '31354 - Solicitação de BACA [#INC0053197#]'
                        ,pr_cdoperad_rat => 1
                        ,pr_dsorigem => 5
                        ,pr_nmdatela => 'RATMOV'
                        ,pr_nmrotina => 'RATMOV'
                        ,pr_dscritic => vr_dscritic);

  pc_grava_rating_manual(pr_cdcooper => 10
                        ,pr_nrdconta => 1201
                        ,pr_nrctrato => 2762
                        ,pr_tpctrato => 90
                        ,pr_rating_sugerido => 'C'
                        ,pr_justificativa => '31354 - Solicitação de BACA [#INC0053197#]'
                        ,pr_cdoperad_rat => 1
                        ,pr_dsorigem => 5
                        ,pr_nmdatela => 'RATMOV'
                        ,pr_nmrotina => 'RATMOV'
                        ,pr_dscritic => vr_dscritic);

  pc_grava_rating_manual(pr_cdcooper => 10
                        ,pr_nrdconta => 1201
                        ,pr_nrctrato => 3858
                        ,pr_tpctrato => 90
                        ,pr_rating_sugerido => 'C'
                        ,pr_justificativa => '31354 - Solicitação de BACA [#INC0053197#]'
                        ,pr_cdoperad_rat => 1
                        ,pr_dsorigem => 5
                        ,pr_nmdatela => 'RATMOV'
                        ,pr_nmrotina => 'RATMOV'
                        ,pr_dscritic => vr_dscritic);

  pc_grava_rating_manual(pr_cdcooper => 10
                        ,pr_nrdconta => 16500
                        ,pr_nrctrato => 2490
                        ,pr_tpctrato => 90
                        ,pr_rating_sugerido => 'D'
                        ,pr_justificativa => '31354 - Solicitação de BACA [#INC0053197#]'
                        ,pr_cdoperad_rat => 1
                        ,pr_dsorigem => 5
                        ,pr_nmdatela => 'RATMOV'
                        ,pr_nmrotina => 'RATMOV'
                        ,pr_dscritic => vr_dscritic);
  COMMIT;
END;
0
0
