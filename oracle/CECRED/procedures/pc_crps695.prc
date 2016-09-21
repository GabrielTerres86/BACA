CREATE OR REPLACE PROCEDURE CECRED.pc_crps695 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps695 (Fontes/crps695.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Junho/2015                     Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Diario
       Objetivo  : Renovacao do seguro de vida

       Alteracoes:
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS695';      

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      
      vr_dtrenova   crapseg.dtrenova%type;

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Busca os dados do plano do seguro
      CURSOR cr_craptsg(pr_cdcooper craptsg.cdcooper%TYPE,
                        pr_tpplaseg craptsg.tpplaseg%TYPE,
                        pr_cdsegura craptsg.cdsegura%TYPE,
                        pr_tpseguro craptsg.tpseguro%TYPE) IS
        SELECT vlplaseg,
               vlmorada
          FROM craptsg
         WHERE cdcooper = pr_cdcooper
           AND tpplaseg = pr_tpplaseg
           AND cdsegura = pr_cdsegura
           AND tpseguro = pr_tpseguro;                           
      rw_craptsg cr_craptsg%ROWTYPE;

      -- Busca dos dados do seguro
      CURSOR cr_crapseg(pr_cdcooper crapseg.cdcooper%TYPE,
                        pr_dtmvtopr crapdat.dtmvtopr%TYPE) IS
        SELECT nrdconta,
               nrctrseg,
               dtinivig,
               tpplaseg,
               cdsegura,
               tpseguro,
               dtrenova
          FROM crapseg
         WHERE cdcooper = pr_cdcooper
           AND tpseguro = 3
           AND cdsitseg = 1
           AND dtrenova <= pr_dtmvtopr;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);
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
      
      -- LOOP com todos os seguros de vida que serao renovados
      FOR rw_crapseg IN cr_crapseg(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtopr => rw_crapdat.dtmvtopr) LOOP
                                   
        -- Leitura do plano do seguro
        OPEN cr_craptsg(pr_cdcooper => pr_cdcooper,
                        pr_tpplaseg => rw_crapseg.tpplaseg,
                        pr_cdsegura => rw_crapseg.cdsegura,
                        pr_tpseguro => rw_crapseg.tpseguro);
        FETCH cr_craptsg
         INTO rw_craptsg;
        -- Se não encontrar
        IF cr_craptsg%NOTFOUND THEN
          -- Fechar o cursor pois efetuaremos raise
          CLOSE cr_craptsg;          
          CONTINUE;
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_craptsg;
        END IF;        
        
        -- Calcula a data de renovacao
        vr_dtrenova := GENE0005.fn_calc_data(pr_dtmvtolt => rw_crapseg.dtrenova
                                            ,pr_qtmesano => 1
                                            ,pr_tpmesano => 'A'
                                            ,pr_des_erro => vr_dscritic);
                                            
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;
                                        
        -- Atualiza o valor do plano no seguro de vida
        BEGIN
          UPDATE crapseg
             SET vlpreseg = rw_craptsg.vlplaseg,
                 dtrenova = vr_dtrenova
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = rw_crapseg.nrdconta
             AND nrctrseg = rw_crapseg.nrctrseg;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPSEG: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Atualiza o valor do plano na proposta do seguro de vida
        BEGIN
          UPDATE crawseg
             SET vlpreseg = rw_craptsg.vlplaseg,
                 vlseguro = rw_craptsg.vlmorada
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = rw_crapseg.nrdconta
             AND nrctrseg = rw_crapseg.nrctrseg;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAWSEG: '||SQLERRM;
            RAISE vr_exc_saida;
        END;        
        
      END LOOP; /* END LOOP rw_crapseg */
      
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

  END pc_crps695;
/

