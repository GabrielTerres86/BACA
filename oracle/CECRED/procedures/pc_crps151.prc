CREATE OR REPLACE PROCEDURE CECRED.
                pc_crps151 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_cdoperad  IN crapope.cdoperad%type  --> Código do operador
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps151 (Fontes/crps151.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Marco/96.                      Ultima atualizacao: 25/08/2015

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Atende a solicitacao 001.
                   Gerar lancamento de cobranca de contrato de cheque especial.

       Alteracoes: 23/08/96 - Alterado para desprezar lancamentos de limite
                          Credicad (Deborah).

                   27/08/97 - Alterado para incluir o campo flgproce na criacao
                              do crapavs (Deborah).

                   27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   25/09/2003 - Selecionar apenas os limite tipo 1 (Edson).

                   29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                                craplcm e crapavs (Diego).

                   10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

                   16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   12/04/2007 - Substituir tabela TRFACTRLIM pela craplrt. (Ze).

                   15/09/2010 - Alterado historico 163 p/ 892. Demandas auditoria
                                BACEN (Guilherme).

                   24/02/2011 - Alterar para utilizar o numero de documento =
                                craplim.nrctrlim (Vitor)

                   21/06/2011 - Controlar tarifas das linhas de credito através
                                da tabela CRATLR (Adriano).

                   11/07/2013 - Alterado processo de busca valor tarifa para
                                utilizar rotinas da b1wgen0153, projeto tarifas.
                                (Daniel)

                   11/10/2013 - Incluido parametro cdprogra nas procedures da
                                b1wgen0153 que carregam dados de tarifas (Tiago).

                   06/06/2014 - Conversão Progress >> Oracle PLSQL (Tiago Castro - RKAM).
    			   
                   02/07/2014 - Retirado tratamento de savepoint e tratamento restart.
                                Alterado estrutura para nao abortar programa em caso 
                                de critica. (Daniel/Ze).
                               
                   31/12/2014 - Ajuste para cobrar a tarifa quando o limite de credito
                                for renovado. (James)

                   25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                                tari0001.pc_cria_lan_auto_tarifa, projeto de 
                                Tarifas-218(Jean Michel)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS151';

      -- Tarifa
      vr_cdbattar VARCHAR2(10);
      vr_txctrchq NUMBER;

      vr_cdhistor INTEGER; -- codigo historico
      vr_cdhisest NUMBER; -- historico estorno

      vr_dtdivulg DATE; -- data divulgacao
      vr_dtvigenc DATE; -- data vigencia
      vr_cdfvlcop INTEGER; -- codigo faixa valor cooperativa
      vr_rowid    ROWID;


      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- tabela de erros
      vr_tab_erro   GENE0001.typ_tab_erro;

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Limite de credito
      CURSOR cr_craplim(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT  craplim.nrdconta
               ,craplim.cddlinha
               ,craplim.dtinivig
               ,craplim.dtrenova
               ,craplim.nrctrlim
        FROM    craplim
        WHERE   craplim.cdcooper = pr_cdcooper
        AND     craplim.tpctrlim = 1
        AND     craplim.insitlim = 2
        AND    (craplim.dtinivig = pr_dtmvtolt OR 
                craplim.dtrenova = pr_dtmvtolt);

      -- Cadastro do associado
      CURSOR cr_crapass(pr_nrdconta IN craplim.nrdconta%TYPE)IS
        SELECT  crapass.inpessoa
               ,crapass.vllimcre
        FROM    crapass
        WHERE   crapass.cdcooper = pr_cdcooper
        AND     crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Linha de credito rotativo
      CURSOR cr_crapltr(pr_cddlinha IN craplim.cddlinha%TYPE) IS
        SELECT  craplrt.cddlinha
        FROM    craplrt
        WHERE   craplrt.cdcooper = pr_cdcooper
        AND     craplrt.cddlinha = pr_cddlinha;
      rw_crapltr cr_crapltr%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------

      --------------------------- SUBROTINAS INTERNAS --------------------------


      --------------- VALIDACOES INICIAIS -----------------


    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
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
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- verifica limites de credito
      FOR rw_craplim IN cr_craplim(rw_crapdat.dtmvtolt)
      LOOP
        EXIT WHEN cr_craplim%NOTFOUND;
        OPEN cr_crapass(rw_craplim.nrdconta);--verifica conta associado
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          -- se nao encontrou gera erro
          CLOSE cr_crapass;

          vr_cdcritic := 251;
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '||
                                                     gene0002.fn_mask_conta(rw_craplim.nrdconta)||'- '
                                                     || vr_dscritic );

          CONTINUE;
        END IF;
        CLOSE cr_crapass;
        -- Leitura do credito rotativo com o valor da taxa de devolucao
        OPEN cr_crapltr(rw_craplim.cddlinha);
        FETCH cr_crapltr INTO rw_crapltr;
        IF cr_crapltr%NOTFOUND THEN -- se nao encontrou
          CLOSE cr_crapltr;
          vr_cdcritic := 363;
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '||
                                                     gene0002.fn_mask_conta(rw_craplim.nrdconta)||'- '
                                                     || vr_dscritic );
          CONTINUE;
        ELSE
          CLOSE cr_crapltr;
          -- Vamos verificar se o limite foi renovado ou incluido um novo
          IF rw_craplim.dtrenova = rw_crapdat.dtmvtolt THEN
            IF rw_crapass.inpessoa = 1 THEN -- pessoa fisica
              vr_cdbattar := 'RELIMCHQPF'; -- pessoa fisica
            ELSE
              vr_cdbattar := 'RELIMCHQPJ'; -- pessoa juridica
            END IF;
          ELSE            
            IF rw_crapass.inpessoa = 1 THEN -- pessoa fisica
              vr_cdbattar := 'COLIMCHQPF'; -- pessoa fisica
            ELSE
              vr_cdbattar := 'COLIMCHQPJ'; -- pessoa juridica
            END IF;            
            
          END IF;            
          
          vr_txctrchq := 0; -- zera valor tarifa
          -- Busca valor da tarifa de Emprestimo pessoa fisica
          tari0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                              , pr_cdbattar => vr_cdbattar
                                              , pr_vllanmto => rw_crapass.vllimcre
                                              , pr_cdprogra => vr_cdprogra
                                              , pr_cdhistor => vr_cdhistor
                                              , pr_cdhisest => vr_cdhisest
                                              , pr_vltarifa => vr_txctrchq
                                              , pr_dtdivulg => vr_dtdivulg
                                              , pr_dtvigenc => vr_dtvigenc
                                              , pr_cdfvlcop => vr_cdfvlcop
                                              , pr_cdcritic => vr_cdcritic
                                              , pr_dscritic => vr_dscritic
                                              , pr_tab_erro => vr_tab_erro);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Se possui erro no vetor
            IF vr_tab_erro.Count() > 0 THEN
              vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
            END IF;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||
                                                          gene0002.fn_mask_conta(rw_craplim.nrdconta)||'- '
                                                       || vr_dscritic );
            CONTINUE;                                           
          END IF;
        END IF;
        IF  nvl(vr_txctrchq,0) = 0 THEN   /*  Nao cobrar tarifa quando valor zerado  */
          CONTINUE;
        ELSE
          -- criar lancamento automatico tarifa
          tari0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                          , pr_nrdconta     => rw_craplim.nrdconta
                                          , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                          , pr_cdhistor     => vr_cdhistor
                                          , pr_vllanaut     => vr_txctrchq
                                          , pr_cdoperad     => pr_cdoperad
                                          , pr_cdagenci     => 1
                                          , pr_cdbccxlt     => 100
                                          , pr_nrdolote     => 8452
                                          , pr_tpdolote     => 1
                                          , pr_nrdocmto     => 0
                                          , pr_nrdctabb     => rw_craplim.nrdconta
                                          , pr_nrdctitg     => rw_craplim.nrdconta
                                          , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_craplim.nrctrlim)
                                          , pr_cdbanchq     => 0
                                          , pr_cdagechq     => 0
                                          , pr_nrctachq     => 0
                                          , pr_flgaviso     => TRUE
                                          , pr_tpdaviso     => 2
                                          , pr_cdfvlcop     => vr_cdfvlcop
                                          , pr_inproces     => rw_crapdat.inproces
                                          , pr_rowid_craplat=> vr_rowid
                                          , pr_tab_erro     => vr_tab_erro
                                          , pr_cdcritic     => vr_cdcritic
                                          , pr_dscritic     => vr_dscritic
                                          );
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= vr_tab_erro(1).cdcritic;
              vr_dscritic:= vr_tab_erro(1).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
            END IF;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||
                                                          gene0002.fn_mask_conta(rw_craplim.nrdconta)||'- '
                                                       || vr_dscritic );
          END IF;
        END IF;

      END LOOP;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps151;
/

