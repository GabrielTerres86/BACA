CREATE OR REPLACE PROCEDURE CECRED.pc_crps159 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps159 (Fontes/crps159.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Abril/96                         Ultima atualizacao: 13/06/2016

       Dados referentes ao programa:

       Frequencia: Diario (Batch - Background).
       Objetivo  : Atende a solicitacao 049.
                   Fazer limpeza das poupancas programadas canceladas.
                   Rodara no processo de limpeza de junho.

       Alteracoes: 28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   10/11/2004 - Alterado para excluir tambem o registro da craptab
                                (Poupanca Bloqueada), se existir (Evandro).

                   15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   12/03/2014 - Conversão Progress >> PLSQL (Edison - AMcom).
                   
                   05/01/2015 - Retirar restrição da EXELIMPCAD 
                                para não depender do processo de microfilmagem
                                que foi desativado SD368030 (Odirlei-AMcom)

                   13/06/2016 - Ajustado cursor da craptab para otimizar o cursor
                                utilizando o indice da tabela (Douglas - Chamado 454248)
    ............................................................................ */

    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      --Tipo de registro para armazenar os registros da craptab
      TYPE typ_reg_craptab IS RECORD(idcraptab ROWID);
      TYPE typ_tab_craptab IS TABLE OF typ_reg_craptab INDEX BY VARCHAR2(100);

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS159';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

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

      --seleciona dados do cadastro de poupanca programada
      --cuja data de cancelamento seja menor que a data limite
      CURSOR cr_craprpp( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtlimite IN DATE) IS
        SELECT craprpp.nrdconta
              ,craprpp.nrctrrpp
              ,craprpp.rowid
        FROM   craprpp
        WHERE  craprpp.cdcooper = pr_cdcooper
        AND    craprpp.dtcancel < pr_dtlimite
        AND    NOT EXISTS( SELECT 1
                           FROM  craplpp
                           WHERE craplpp.cdcooper = craprpp.cdcooper
                           AND   craplpp.nrdconta = craprpp.nrdconta
                           AND   craplpp.nrctrrpp = craprpp.nrctrrpp);

      --seleciona as informacoes da tabela generica
      CURSOR cr_craptab IS
        SELECT craptab.cdacesso
              ,craptab.dstextab
              ,craptab.rowid
        FROM   craptab
        WHERE  craptab.cdcooper = pr_cdcooper
        AND    UPPER(craptab.nmsistem) = 'CRED'
        AND    UPPER(craptab.tptabela) = 'BLQRGT'
        AND    TRIM(UPPER(craptab.cdacesso)) IS NOT NULL 
        AND    craptab.cdempres = 0
        AND    craptab.tpregist > 0;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      vr_dtlimite DATE;
      vr_qtrppdel NUMBER;
      vr_qttabdel NUMBER;
      vr_indcraptab VARCHAR2(100);
      vr_tab_craptab typ_tab_craptab;

      --------------------------- SUBROTINAS INTERNAS --------------------------

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

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

      --Monta data limite para efetuar a limpeza
      --vai para o primeiro dia do ano
      vr_dtlimite := trunc(rw_crapdat.dtmvtolt,'YEAR');

      --carregando a tabela temporaria para validacao da tab
      FOR rw_craptab IN cr_craptab LOOP
        --gerando o indexador da tabela
        vr_indcraptab := lpad(rw_craptab.cdacesso,10,'0')||substr(rw_craptab.dstextab,1,7);
        -- carregando a tabela
        vr_tab_craptab(vr_indcraptab).idcraptab := rw_craptab.rowid;
      END LOOP;

      --percorre a tabela de poupanca programada levando em conta a
      --data de cancelamento
      FOR rw_craprpp IN cr_craprpp( pr_cdcooper => pr_cdcooper
                                   ,pr_dtlimite => vr_dtlimite) LOOP

        --gera o indice para verificar se o registro existe na tabela generica
        vr_indcraptab := lpad(rw_craprpp.nrdconta,10,'0')||lpad(rw_craprpp.nrctrrpp,7,'0');

        --se o registro existir, será eliminado
        IF vr_tab_craptab.EXISTS(vr_indcraptab) THEN

          --exclui o registro da craptab
          BEGIN
            DELETE FROM craptab WHERE ROWID = vr_tab_craptab(vr_indcraptab).idcraptab;
          EXCEPTION
            WHEN OTHERS THEN
              -- gera critica e aborta a execucao
              vr_dscritic := 'Erro ao excluir o registro da tabela craprpp para a conta: '||rw_craprpp.nrdconta||
                             ' numero da poupanca: '||rw_craprpp.nrctrrpp||'. '||SQLERRM;
              --aborta a execucao
              RAISE vr_exc_saida;
          END;

          --contando os registros da craptab que foram eliminados
          vr_qttabdel := nvl(vr_qttabdel,0) + 1;

        END IF;

        --exclui o registro de poupanca programada
        BEGIN
          DELETE FROM craprpp WHERE ROWID = rw_craprpp.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            --gera critica
            vr_dscritic := 'Erro ao excluir o registro da tabela craprpp para a conta: '||rw_craprpp.nrdconta||
                           ' numero da poupanca: '||rw_craprpp.nrctrrpp||'. '||SQLERRM;
            --aborta a execucao
            RAISE vr_exc_saida;
        END;

        --contanto a quantidade de registros de poupanca programada que foram eliminados
        vr_qtrppdel := nvl(vr_qtrppdel,0) + 1;
      END LOOP;

      /*  Imprime no log do processo os totais das exclusoes   */
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || 'Deletados no RPP = '||nvl(vr_qtrppdel,0));

      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || 'Deletados no TAB = '||nvl(vr_qttabdel,0));

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

  END pc_crps159;
/
