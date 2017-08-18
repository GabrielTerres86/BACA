CREATE OR REPLACE PROCEDURE CECRED.pc_crps273 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps273 (Fontes/crps273.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah
       Data    : Agosto/1999                       Ultima atualizacao: 07/08/2017

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Atende a solicitacao 001 (batch - atualizacao).
                   Roda somente no dia 10 ou seguinte.
                   Calcula o total de creditos do mes anterios (lavagem de
                   dinheiro).


       Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando.

                   09/06/2008 - Incluído o mecanismo de pesquisa no "for each" na
                                tabela CRAPHIS para buscar primeiro pela chave de
                                acesso (craphis.cdcooper = glb_cdcooper).
                                - Kbase IT Solutions - Paulo Ricardo Maciel.

                   19/10/2009 - Alteracao Codigo Historico (Kbase).

                   05/03/2010 - Alteracao Historico (GATI)

                   10/03/2014 - Conversão Progress >> PLSQL (Edison-Amcom).
                                
                   07/08/2017 - Não executar processo quando a data não for a da regra - Chamado 678813
                                Padronizar as mensagens - Chamado 721285
                                Tratar os exception others - Chamado 721285
                                Ajustada chamada para buscar a descrição da critica - Chamado 721285
                                Retirada exception vr_exc_fimprg
                               ( Belli - Envolti )                   

    ............................................................................ */
    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS273';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
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

      --tabela de saldos de todos os cooperados
      CURSOR cr_crapsld(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapsld.nrdconta
              ,crapsld.vlcremes
              ,crapsld.vltotcre##1
              ,crapsld.vltotcre##2
              ,crapsld.vltotcre##3
              ,crapsld.vltotcre##4
              ,crapsld.vltotcre##5
              ,crapsld.vltotcre##6
              ,crapsld.vltotcre##7
              ,crapsld.vltotcre##8
              ,crapsld.vltotcre##9
              ,crapsld.vltotcre##10
              ,crapsld.vltotcre##11
              ,crapsld.vltotcre##12
              ,ROWID
        FROM   crapsld
        WHERE  crapsld.cdcooper = pr_cdcooper
        ORDER BY crapsld.nrdconta;

      rw_crapsld cr_crapsld%ROWTYPE;

      --lancamentos na conta do cooperado no periodo e historicos
      --com indicador de crédito que somem na estatística
      CURSOR cr_craplcm( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_dtiniref IN DATE
                        ,pr_dtfimref IN DATE) IS
        SELECT craplcm.vllanmto
              ,craplcm.cdhistor
        FROM   craplcm
              ,craphis
        WHERE  craplcm.cdcooper = craphis.cdcooper
        AND    craplcm.cdhistor = craphis.cdhistor
        AND    craphis.incremes = 1 -- Indicador de credito do mes: 1-soma na estatistica
        AND    craplcm.cdcooper = pr_cdcooper
        AND    craplcm.nrdconta = pr_nrdconta
        AND    craplcm.dtmvtolt > pr_dtiniref
        AND    craplcm.dtmvtolt < pr_dtfimref
        ORDER BY craplcm.cdcooper
                ,craplcm.nrdconta
                ,craplcm.dtmvtolt
                ,craplcm.cdhistor
                ,craplcm.nrdocmto;

      ------------------------------- VARIAVEIS -------------------------------
      vr_dtfimref   DATE;
      vr_dtiniref   DATE;
      vr_dtmesref   NUMBER;

    PROCEDURE prc_processa
    IS
    BEGIN
      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      --vai para o último dia de dois meses anteriores
      vr_dtiniref := last_day(add_months(rw_crapdat.dtmvtolt,-2));
      --vai para o primeiro dia do mes de referencia
      vr_dtfimref := trunc(rw_crapdat.dtmvtolt,'MONTH');

      --calcula o mes de referencia
      IF to_number(to_char(rw_crapdat.dtmvtolt,'MM')) < 3 THEN
        vr_dtmesref := to_number(to_char(rw_crapdat.dtmvtolt,'MM')) + 10;
      ELSE
        vr_dtmesref := to_number(to_char(rw_crapdat.dtmvtolt,'MM')) - 2;
      END IF;

      -- inicio do processo
      FOR rw_crapsld IN cr_crapsld(pr_cdcooper => pr_cdcooper) LOOP

        --verifica e atribui os creditos do mes ao campo ref. ao mes do processamento
        CASE vr_dtmesref
          WHEN 01 THEN rw_crapsld.vltotcre##1  := rw_crapsld.vlcremes;
          WHEN 02 THEN rw_crapsld.vltotcre##2  := rw_crapsld.vlcremes;
          WHEN 03 THEN rw_crapsld.vltotcre##3  := rw_crapsld.vlcremes;
          WHEN 04 THEN rw_crapsld.vltotcre##4  := rw_crapsld.vlcremes;
          WHEN 05 THEN rw_crapsld.vltotcre##5  := rw_crapsld.vlcremes;
          WHEN 06 THEN rw_crapsld.vltotcre##6  := rw_crapsld.vlcremes;
          WHEN 07 THEN rw_crapsld.vltotcre##7  := rw_crapsld.vlcremes;
          WHEN 08 THEN rw_crapsld.vltotcre##8  := rw_crapsld.vlcremes;
          WHEN 09 THEN rw_crapsld.vltotcre##9  := rw_crapsld.vlcremes;
          WHEN 10 THEN rw_crapsld.vltotcre##10 := rw_crapsld.vlcremes;
          WHEN 11 THEN rw_crapsld.vltotcre##11 := rw_crapsld.vlcremes;
          WHEN 12 THEN rw_crapsld.vltotcre##12 := rw_crapsld.vlcremes;
        END CASE;

        --zerando o valor dos creditos do mes
        rw_crapsld.vlcremes := 0;

        --busca todos os lancamentos do periodo do cooperado
        --com indicador de crédito que somem na estatística
        --para recompor os creditos do mes
        FOR rw_craplcm IN cr_craplcm( pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_crapsld.nrdconta
                                     ,pr_dtiniref => vr_dtiniref
                                     ,pr_dtfimref => vr_dtfimref) LOOP

          --acumulando os valores do mes de referencia
          rw_crapsld.vlcremes := nvl(rw_crapsld.vlcremes,0) + nvl(rw_craplcm.vllanmto,0);

        END LOOP;

        --Atualizando a tabela de saldos
        BEGIN
          UPDATE crapsld
            SET vlcremes      = rw_crapsld.vlcremes
                ,vltotcre##1  = rw_crapsld.vltotcre##1
                ,vltotcre##2  = rw_crapsld.vltotcre##2
                ,vltotcre##3  = rw_crapsld.vltotcre##3
                ,vltotcre##4  = rw_crapsld.vltotcre##4
                ,vltotcre##5  = rw_crapsld.vltotcre##5
                ,vltotcre##6  = rw_crapsld.vltotcre##6
                ,vltotcre##7  = rw_crapsld.vltotcre##7
                ,vltotcre##8  = rw_crapsld.vltotcre##8
                ,vltotcre##9  = rw_crapsld.vltotcre##9
                ,vltotcre##10 = rw_crapsld.vltotcre##10
                ,vltotcre##11 = rw_crapsld.vltotcre##11
                ,vltotcre##12 = rw_crapsld.vltotcre##12
          WHERE ROWID = rw_crapsld.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 07/08/2017 - Chamado 721285        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
            vr_dscritic := 'Erro ao atualizar os valores da tabela crapsld. '||SQLERRM;
            RAISE vr_exc_saida;
        END;

      END LOOP;
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      RAISE vr_exc_saida;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 07/08/2017 - Chamado 721285        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
      vr_dscritic := 'prc_processa com erro: ' || SQLERRM;
      RAISE vr_exc_saida;

    END prc_processa;
    
    ---
    
    BEGIN

      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

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

      --
      -- Não executar processo quando a data não for a da regra - 07/08/2017 - Chamado 678813
      /* Roda somente no dia 10 (ou seguinte) de cada mes */
      IF NOT (to_number(TO_CHAR(rw_crapdat.dtmvtolt,'DD')) >= 10 AND
              to_number(to_char(rw_crapdat.dtmvtoan,'DD')) <  10) THEN

        --finaliza o programa sem gerar excecao
        NULL;
      ELSE
        prc_processa;
      END IF;
      --

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Ajustada chamada para buscar a descrição da critica - 07/08/2017 - Chamado 721285
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, vr_dscritic);
        -- Efetuar rollback
        ROLLBACK;     
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 07/08/2017 - Chamado 721285        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK; 
    END;

  END pc_crps273;
/
