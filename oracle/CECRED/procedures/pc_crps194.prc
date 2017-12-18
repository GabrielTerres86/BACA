CREATE OR REPLACE PROCEDURE CECRED.pc_crps194 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps194 (Fontes/crps194.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Abril/97                           Ultima atualizacao: 15/12/2017

       Dados referentes ao programa:

       Frequencia: Diario (Batch - Background).
       Objetivo  : Atende a solicitacao 013.
                   Fazer limpeza de propostas nao aprovadas.
                   Rodara no processo de limpeza mensal.

       Alteracoes: 13/08/98 - Incluida a limpeza dos cartoes solicitados (insitcrd
                              = 2) e nao recebidos (Deborah).

                   14/10/98 - Alterar a data limite da limpeza das propostas de
                              planos de capital (Deborah).

                   10/01/2000 - Padronizar mensagens (Deborah).

                   07/02/2000 - Acerto no numero da mensagem (Deborah).

                   07/02/2002 - Aumento do numero de dias para a limpeza das
                                propostas de emprestimos (+ 30 dias) (Edson).

                   11/04/2003 - Aumento do numero de dias para a limpeza das
                                propostas de emprestimos (+ 60 dias) (Edson).

                   30/06/2004 - Prever Avalistar Terceiros(Mirtes).

                   26/08/2005 - Excluida a limpeza dos cartoes em situacao
                                (insitcrd = 2) (Diego).

                   16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   06/03/2006 - Excluir a crapavt para os emprestimos (Evandro).

                   27/04/2010 - As poupanças nao passam mais pelo estado de
                                estudo, portanto nao sao mais criados os
                                registros (Gabriel).

                   22/07/2010 - Excluir dados da proposta , os bens dos contratos
                                e os rendimentos (Gabriel).

                   30/08/2011 - Caso crawepr.tpemprst = 1 (pre-fixada)
                                entao, executar limpeza na crappep
                                (parcelas do emprestimo). (Fabricio)

                   29/01/2014 - Conversao Progress -> Oracle (Edison - AMcom)

                   15/10/2014 - #147831 Adicionada a limpeza dos avalistas (crapavl) (Carlos)
                   
                   22/03/2016 - Incluido busca do parametro QTD_MES_LIMPEZA_WEPR
                                que define limite para limpeza.
                                PRJ207 - Esteira (Odirlei-AMcom)

                   22/09/2016 - Alterei a gravacao do log 661 do proc_batch para 
                                o proc_message SD 402979. (Carlos Rafael Tanholi)
																 
                   15/12/2017 - Remover o vinculo com a cobertura. PRJ404 (Lombardi)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS194';

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

      -- Cadastro auxiliar de controle de cartoes de credito que estejam
      -- na situacao em estudo, cuja data de proposta seja menor que o
      -- primeiro dia do mes anterior a data do processamento
      CURSOR cr_crawcrd ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_dtpropos IN DATE) IS
        SELECT crawcrd.nrctaav1 --primeiro avalista
              ,crawcrd.nrctaav2 --segundo avalista
              ,crawcrd.nrctrcrd --numero da proposta
              ,crawcrd.nrdconta --Numero da conta/dv do associado
              ,crawcrd.rowid    --id do registro
        FROM   crawcrd
        WHERE crawcrd.cdcooper = pr_cdcooper
        AND   crawcrd.insitcrd = 0 --Situacao (0-estudo,1-aprov.,2-solic.,3-liber.,4-em uso,5-canc.)
        AND   crawcrd.dtpropos < pr_dtpropos;

      -- Cadastro auxiliar dos emprestimos com movimento a mais de 4 meses
      -- que não estejam cadastrados na crapepr
      CURSOR cr_crawepr ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_dtmvtolt IN DATE) IS
        SELECT crawepr.nrdconta --Numero da conta/dv do associado
              ,crawepr.nrctremp --Numero do contrato de emprestimo
              ,crawepr.tpemprst --Tipo do emprestimo (0 - atual, 1 - pre-fixada)	   
              ,crawepr.idcobope --Cobertura
              ,crawepr.rowid    --id do registro
        FROM  crawepr
        WHERE crawepr.cdcooper = pr_cdcooper
        AND   crawepr.dtmvtolt < pr_dtmvtolt --data do movimento
        AND   NOT EXISTS ( SELECT 1
                           FROM   crapepr
                           WHERE  crapepr.cdcooper = crawepr.cdcooper
                           AND    crapepr.nrdconta = crawepr.nrdconta
                           AND    crapepr.nrctremp = crawepr.nrctremp);

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      vr_dtlimite     DATE;
      vr_dtlimpla     DATE;
      vr_dtlimepr     DATE;
      vr_qtmeslim     INTEGER := 0;
      vr_qtprocrd     INTEGER;
      vr_qtpropla     INTEGER;
      vr_qtproepr     INTEGER;
      vr_dstextab     craptab.dstextab%TYPE;

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

      -- busca o valor do parametro EXELIMPEZA
      vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'EXELIMPEZA'
                                                ,pr_tpregist => 1);

      -- se nao encontrar o parametro, aborta a execucao
      IF TRIM(vr_dstextab) IS NULL THEN
        -- gera critica 387 - Falta tabela de execucao da limpeza do cadastro.
        vr_cdcritic := 387;
        -- finaliza a execucao
        RAISE vr_exc_saida;
      END IF;

      -- verifica se a limpeza já foi executada em outra oportunidade
      IF vr_dstextab = '1' THEN
        -- gera critica 177 - Limpeza ja rodou este mes.
        vr_cdcritic := 177;
        -- finaliza a execucao
        RAISE vr_exc_saida;
      END IF;

      /*  Monta data limite para efetuar a limpeza  */

      -- primeiro dia do mês anterior (60 dias)
      vr_dtlimite := TRUNC(add_months(rw_crapdat.dtmvtolt,-1),'MONTH');

      
      --> Buscar parametro que define quantidade de meses para limpeza
      -- Parametro utilizado também no CRPS704
      vr_qtmeslim := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                               pr_cdcooper => pr_cdcooper, 
                                               pr_cdacesso => 'QTD_MES_LIMPEZA_WEPR');
      
      IF nvl(vr_qtmeslim,0) = 0 THEN
        vr_dscritic := 'Quantidade de meses para limpeza nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        -- primeiro dia de 4 meses atras (120 dias)
        vr_dtlimepr := TRUNC(add_months(rw_crapdat.dtmvtolt,vr_qtmeslim*-1),'MONTH');                                      
      END IF;

      -- primeiro dia de 4 meses atras (120 dias)
      vr_dtlimpla := TRUNC(add_months(rw_crapdat.dtmvtolt,-4),'MONTH');

      -- processa todos os cartoes de credito que estejam
      -- na situacao em estudo, cuja data de proposta seja menor que o
      -- primeiro dia do mes anterior a data do processamento
      FOR rw_crawcrd IN cr_crawcrd( pr_cdcooper => pr_cdcooper
                                   ,pr_dtpropos => vr_dtlimite)
      LOOP
        -- se o numero da conta do primeiro avalista for diferente de zero:
        -- exclui todos os avalistas da proposta
        IF rw_crawcrd.nrctaav1 <> 0 THEN

          -- excluindo as informacoes do primeiro avalista da proposta
          BEGIN
            DELETE FROM  crapavl
                   WHERE crapavl.cdcooper = pr_cdcooper
                   AND   crapavl.nrdconta = rw_crawcrd.nrctaav1 -- numero da conta do primeiro avalista
                   AND   crapavl.nrctravd = rw_crawcrd.nrctrcrd -- numero da proposta
                   AND   crapavl.tpctrato = 4; -- 4-Cartao
          EXCEPTION
           WHEN OTHERS THEN
             -- gera critica
             vr_dscritic := 'Erro na exclusao das informacoes do primeiro avalista. '||SQLERRM;
             -- finaliza a execucao
             RAISE vr_exc_saida;
          END;
        END IF;

        -- se o numero da conta do segundo avalista for diferente de zero:
        IF rw_crawcrd.nrctaav2 <> 0 THEN
          -- excluindo as informacoes do segundo avalista da proposta
          BEGIN
            DELETE FROM  crapavl
                   WHERE crapavl.cdcooper = pr_cdcooper
                   AND   crapavl.nrdconta = rw_crawcrd.nrctaav2 -- numero da conta do segundo avalista
                   AND   crapavl.nrctravd = rw_crawcrd.nrctrcrd -- numero da proposta
                   AND   crapavl.tpctrato = 4; -- 4-Cartao
          EXCEPTION
           WHEN OTHERS THEN
             -- gera critica
             vr_dscritic := 'Erro na exclusao das informacoes do segundo avalista. '||SQLERRM;
             -- finaliza a execucao
             RAISE vr_exc_saida;
          END;
        END IF;

        -- Excluindo as Cadastro de avalistas terceiros, contatos da pessoa fisica e
        -- referencias comerciais e bancarias da pessoa juridica.
        BEGIN
          DELETE FROM  crapavt
                 WHERE crapavt.cdcooper = pr_cdcooper
                 AND   crapavt.tpctrato = 4                   -- 4-Cartao
                 AND   crapavt.nrdconta = rw_crawcrd.nrdconta -- numero da conta do associado
                 AND   crapavt.nrctremp = rw_crawcrd.nrctrcrd; -- numero da proposta
        EXCEPTION
          WHEN OTHERS THEN
            -- gera critica
            vr_dscritic := 'Erro na exclusao das informacoes do terceiro avalista. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        -- eliminando as informacoes da proposta de cartoes de credito
        BEGIN
          DELETE FROM crawcrd
                 WHERE ROWID = rw_crawcrd.rowid;
        EXCEPTION
          WHEN OTHERS THEN
           -- gera critica
           vr_dscritic := 'Erro na exclusao da proposta do cartao de credito. '||SQLERRM;
           -- finaliza a execucao
           RAISE vr_exc_saida;
        END;

        -- contando a quantidade de registros processados
        vr_qtprocrd := nvl(vr_qtprocrd,0) + 1;

      END LOOP; --FOR rw_crawcrd IN rw_crawcrd( pr_cdcooper => pr_cdcooper

      /*  Imprime no log do processo o total de cartao de credito   */
      -- 661 - DELETADOS NO
      vr_cdcritic := 661;
      -- Busca a descrição e concatena as informações de quantidade
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                     ' WCRD = ' ||
                     to_char(nvl(vr_qtprocrd,0),'fm999G990');
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic 
                                ,pr_nmarqlog     => 'proc_message'); 

      -- limpando as variaveis de controle de critica
      vr_cdcritic := 0;
      vr_dscritic := ' ';

      /*  Leitura do crappla  a ser excluido  */
      -- excluindo informacoes dos planos de capitalizacao
      BEGIN
        DELETE FROM  crappla
               WHERE crappla.cdcooper = pr_cdcooper
               AND   crappla.cdsitpla = 9            -- Situacao do plano(?)
               AND   crappla.dtinipla < vr_dtlimpla; -- Data de inicio do plano

        -- armazena a quantidade de linhas excluidas
        vr_qtpropla := SQL%ROWCOUNT;

      EXCEPTION
        WHEN OTHERS THEN
          -- gera critica
          vr_dscritic := 'Erro na exclusao dos planos de capitalizacao. '||SQLERRM;
          -- finaliza a execucao
          RAISE vr_exc_saida;
      END;

      /*  Imprime no log do processo o total de cartao de credito   */
      -- 661 - DELETADOS NO
      vr_cdcritic := 661;
      -- Busca a descrição e concatena as informações de quantidade
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                     ' PLA = ' ||
                     to_char(nvl(vr_qtpropla,0),'fm999G990');
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic 
                                ,pr_nmarqlog     => 'proc_message');                                                  

      -- limpando as variaveis de controle de critica
      vr_cdcritic := 0;
      vr_dscritic := ' ';

      /*  Leitura do crawepr  a ser excluido  */
      FOR rw_crawepr IN cr_crawepr( pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => vr_dtlimepr)
      LOOP
        /* Excluindo as informaoes das propostas de emprestimo */
        BEGIN
          DELETE FROM  crapprp
                 WHERE crapprp.cdcooper = pr_cdcooper
                 AND   crapprp.nrdconta = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapprp.tpctrato = 90                  -- Tipo de contrato
                 AND   crapprp.nrctrato = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            -- gera critica
            vr_dscritic := 'Erro na exclusao das propostas de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpa os avalistas terceiros */
        BEGIN
          DELETE FROM  crapavt
                 WHERE crapavt.cdcooper = pr_cdcooper
                 AND   crapavt.tpctrato = 1                  -- Tipo de contrato
                 AND   crapavt.nrdconta = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapavt.nrctremp = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos avalistas terceiros da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpeza dos avalistas */
        BEGIN
          DELETE FROM  crapavl
                 WHERE crapavl.cdcooper = pr_cdcooper
                 AND   crapavl.tpctrato = 1                   -- Tipo de contrato (empréstimo)
                 AND   crapavl.nrctaavd = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapavl.nrctravd = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos avalistas da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpar os bens da proposta */
        BEGIN
          DELETE FROM  crapbpr
                 WHERE crapbpr.cdcooper = pr_cdcooper
                 AND   crapbpr.nrdconta = rw_crawepr.nrdconta -- Conta do associado
                 AND   crapbpr.tpctrpro = 90                  --tipo da proposta de emprestimo
                 AND   crapbpr.nrctrpro = rw_crawepr.nrctremp;--numero do contrato
        EXCEPTION
          WHEN OTHERS THEN
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos bens da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        /* Limpar os rendimentos da proposta */
        BEGIN
          DELETE FROM  craprpr
                 WHERE craprpr.cdcooper = pr_cdcooper
                 AND   craprpr.nrdconta = rw_crawepr.nrdconta --Conta do associado
                 AND   craprpr.nrctrato = rw_crawepr.nrctremp --numero do contrato
                 AND   craprpr.tpctrato = 90;                 --Tipo(1-Empr/2-Descto Chq/3-Chq Esp/4-Cartao/5-Cont,6-Jur,7-RL)
        EXCEPTION
          WHEN OTHERS THEN
            -- gera critica
            vr_dscritic := 'Erro na exclusao dos rendimentos da proposta de emprestimo. '||SQLERRM;
            -- finaliza a execucao
            RAISE vr_exc_saida;
        END;

        -- se o tipo do emprestimo for 1 - pre-fixada
        IF rw_crawepr.tpemprst = 1 THEN
          /* Limpa as parcelas do contrato de emprestimos e seus respectivos valores */
          BEGIN
            DELETE FROM  crappep
                   WHERE crappep.cdcooper = pr_cdcooper
                   AND   crappep.nrdconta = rw_crawepr.nrdconta --conta do associado
                   AND   crappep.nrctremp = rw_crawepr.nrctremp;--numero do contrato
          EXCEPTION
            WHEN OTHERS THEN
              -- gera critica
              vr_dscritic := 'Erro na exclusao das parcelas da proposta de emprestimo. '||SQLERRM;
              -- finaliza a execucao
              RAISE vr_exc_saida;
          END;
        END IF;
        
        -- remover o vinculo da cobertura
        BLOQ0001.pc_vincula_cobertura_operacao (pr_idcobertura_anterior => rw_crawepr.idcobope 
                                               ,pr_idcobertura_nova => 0
                                               ,pr_nrcontrato => 0
                                               ,pr_dscritic => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          -- finaliza a execucao
          RAISE vr_exc_saida;
        END IF;

        -- eliminando as informacoes da proposta de cartoes de credito
        BEGIN
          DELETE FROM crawepr
                 WHERE ROWID = rw_crawepr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
           -- gera critica
           vr_dscritic := 'Erro na exclusao da proposta de emprestimo. '||SQLERRM;
           -- finaliza a execucao
           RAISE vr_exc_saida;
        END;

        vr_qtproepr := nvl(vr_qtproepr,0) + 1;

      END LOOP;--FOR rw_crawepr IN cr_crawepr( pr_cdcooper => pr_cdcooper

      /*  Imprime no log do processo o total de cartao de credito   */
      -- 661 - DELETADOS NO
      vr_cdcritic := 661;
      -- Busca a descrição e concatena as informações de quantidade
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                     ' WEPR = ' ||
                     to_char(nvl(vr_qtproepr,0),'fm999G990');
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic 
                                ,pr_nmarqlog     => 'proc_message'); 

      -- limpando as variaveis de controle de critica
      vr_cdcritic := 0;
      vr_dscritic := ' ';

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
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
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
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
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

  END pc_crps194;
/
