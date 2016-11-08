CREATE OR REPLACE PROCEDURE CECRED.pc_crps108(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: PC_CRPS108      (Antigo Fontes/crps108.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Dezembro/94                     Ultima atualizacao: 22/09/2016

       Dados referentes ao programa:

       Frequencia: Diario (Batch - Background).
       Objetivo  : Atende a solicitacao 013.
                   Fazer limpeza mensal dos resgates de RDCA.
                   Rodara na primeira sexta-feira apos o processo mensal.

       Alteracoes: 20/04/98 - Tratar milenio e v8 (Odair).

                   10/01/2000 - Padronizar mensagens (Deborah).

                   25/06/2001 - Permitir que o usuario solicite o resgate de
                                poupancas progrmadas. (Ze Eduardo).

                   12/04/2001 - Tratar insresgat = 3 (Mag).

                   15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   29/03/2011 - Limpar aplicacoes rdcpos com data de resgate
                                menor que a data limite (Magui).

                   17/03/2014 - Conversão Progress >> Oracle (Petter - Supero)

                   22/09/2016 - Alterei a gravacao do log 661,662 do proc_batch para 
                                o proc_message SD 402979. (Carlos Rafael Tanholi)
    ............................................................................ */

    DECLARE
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS108';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Variáveis de regra de negócio
      vr_dtlimite   DATE;
      vr_qtlrgdel   PLS_INTEGER := 0;
      vr_qtlotdel   PLS_INTEGER := 0;
      vr_qtdeleta   PLS_INTEGER := 0;
      vr_qtlotres   PLS_INTEGER := 0;

      ------------------------------- CURSORES ---------------------------------
      -- Busca dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca dados para verificar permissão de execução
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cb.dstextab
        FROM craptab cb
        WHERE cb.cdcooper = pr_cdcooper
          AND cb.nmsistem = 'CRED'
          AND cb.tptabela = 'GENERI'
          AND cb.cdempres = 0
          AND cb.cdacesso = 'EXELIMPEZA'
          AND cb.tpregist = 1;
      rw_craptab cr_craptab%ROWTYPE;

      -- Busca dados das capas de lote
      CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                       ,pr_dtlimite IN craplot.dtmvtolt%TYPE) IS
        SELECT co.dtmvtolt
              ,co.cdbccxlt
              ,co.cdagenci
              ,co.nrdolote
              ,co.qtinfoln
              ,co.rowid
        FROM craplot co
        WHERE co.cdcooper = pr_cdcooper
          AND co.tplotmov = 11
          AND co.dtmvtolt < pr_dtlimite;

    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;

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
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

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
      -- Verificar se deve executar limpeza
      OPEN cr_craptab(pr_cdcooper);
      FETCH cr_craptab INTO rw_craptab;

      -- Verifica se a tupla retornou registro dos parametros de limpeza.
      -- Se existir o registro e a descrição do parâmetro for 1 irá gerar crítica.
      IF cr_craptab%NOTFOUND THEN
        -- Gerar critica
        vr_cdcritic := 176;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic
                                  ,pr_nmarqlog     => 'PROC_BATCH');

        RAISE vr_exc_saida;
      ELSE
        IF rw_craptab.dstextab = '1' THEN
          -- Gerar critica
          vr_cdcritic := 177;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

          btch0001.pc_gera_log_batch(pr_cdcooper   => pr_cdcooper
                                  ,pr_ind_tipo_log => 2
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic
                                  ,pr_nmarqlog     => 'PROC_BATCH');

          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Buscar data limite (este trecho de código está programado conforme regra no Progress para fins de compatibilidade)
      vr_dtlimite := rw_crapdat.dtmvtolt - TO_CHAR(rw_crapdat.dtmvtolt, 'DD');
      vr_dtlimite := vr_dtlimite - (TO_CHAR(vr_dtlimite, 'DD') + 1);

      -- Iterar sobre as capas de lote
      FOR rw_craplot IN cr_craplot(pr_cdcooper, vr_dtlimite) LOOP
        vr_qtdeleta := 0;

        -- Apagar registros de lancamentos de resgates solicitados
        BEGIN
          DELETE craplrg cr
          WHERE cr.cdcooper = pr_cdcooper
            AND cr.dtmvtolt = rw_craplot.dtmvtolt
            AND cr.cdagenci = rw_craplot.cdagenci
            AND cr.cdbccxlt = rw_craplot.cdbccxlt
            AND cr.nrdolote = rw_craplot.nrdolote
            AND (cr.inresgat IN (1, 2, 3)
                 OR (cr.inresgat = 0 AND cr.dtresgat < vr_dtlimite));
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao apagar registros da CRAPLRG: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Verifica se registros foram apagados
        IF SQL%ROWCOUNT > 0 THEN
          vr_qtlrgdel := vr_qtlrgdel + SQL%ROWCOUNT;
          vr_qtdeleta := SQL%ROWCOUNT;
        END IF;

        -- Verifica se o número de registros apagados coincide com registro em tabela
        IF rw_craplot.qtinfoln = vr_qtdeleta THEN
          -- Apagar registro e atualizar contador
          BEGIN
            DELETE craplot ct
            WHERE ct.rowid = rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao apagar registros da CRAPLOT: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          vr_qtlotdel := vr_qtlotdel + 1;
        ELSE
          -- Atualizar registro e atualizar contador
          BEGIN
            UPDATE craplot ct
            SET ct.qtinfoln = ct.qtinfoln - NVL(vr_qtdeleta, 0)
            WHERE ct.rowid = rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar registros da CRAPLOT: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          vr_qtlotres := vr_qtlotres + 1;
        END IF;
      END LOOP;

      -- Definir código de crítica
      vr_cdcritic := 661;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

      -- Gerar mensagem no LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 3
                                ,pr_des_log      => TO_CHAR(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                                                    ' LRG = ' || TO_CHAR(vr_qtlrgdel, 'FM9G999G990')
	                              ,pr_nmarqlog     => 'proc_message'); 

      -- Gerar mensagem no LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 3
                                ,pr_des_log      => TO_CHAR(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                                                    ' LOT = ' || TO_CHAR(vr_qtlotdel, 'FM9G999G990')
                                ,pr_nmarqlog     => 'proc_message');                                                     

      -- Gerar código de crítica
      vr_cdcritic := 662;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

      -- Gerar mensagens no LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 3
                                ,pr_des_log      => TO_CHAR(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                                                    ' LRG = ' || TO_CHAR(vr_qtlotres, 'FM9G999G990')
                                ,pr_nmarqlog     => 'proc_message');                                                     

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
                                  ,pr_des_log      => TO_CHAR(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );

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
  END pc_crps108;
/
