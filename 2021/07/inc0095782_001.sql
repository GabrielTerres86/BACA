--685
declare
    PROCEDURE PC_CRPS685_poupanca (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

    BEGIN
    /*..............................................................................

     Programa: pc_crps685
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Carlos Rafael Tanholi
     Data    : Setembro/2014                       Ultima atualizacao: 08/07/2020

     Dados referentes ao programa:

     Frequencia: Mensal.

     Objetivo  : Calcula a provisao sobre o saldo das aplicacoes ativas mensalmente

     Alterações: 15/07/2018 - Proj. 411.2, desconsiderar as Aplicações Programadas. (Cláudio - CIS Corporate)

                 14/11/2019 - Melhoria performance (PRB0042298 Lucas Ranghetti)

                 08/07/2020 - Otimização dos cursores para melhoria no desempenho (Andre Clemer - Supero)

                 10/11/2020 - Ajuste na carga do valor craprac.vlslfmes e no calculo da qtd.
                              de dias no prazo das aplicacao (Anderson)

    ...............................................................................*/

    DECLARE

      ------------------------------- VARIAVEIS -------------------------------

      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE DEFAULT 'CRPS685';
      -- Tratamento de erros
      vr_exc_erro exception;
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- variaveis de retorno do calculo de provisao
      vr_idgravir NUMBER := 0; -- nenhuma imunidade do cooperado
      vr_idtipbas NUMBER := 2; -- tipo base de calculo
      vr_vlbascal NUMBER := 0; -- valor base de calculo
      vr_vlsldtot NUMBER := 0;
      vr_vlsldrgt NUMBER := 0;
      vr_vlultren NUMBER := 0;
      vr_vlrentot NUMBER := 0;
      vr_vlrevers NUMBER := 0;
      vr_vlrdirrf NUMBER := 0;
      vr_percirrf NUMBER := 0;

      vr_qtdias_prazo NUMBER := 0;

      vr_cdcooper crapcop.cdcooper%TYPE;

      vr_flgrgprb BOOLEAN;

      vr_index_lac NUMBER := 1;
      vr_index_rac VARCHAR(40);

      -- valor de saldo anterior
      vr_vlsldant craprac.vlsldant%TYPE;
      -- data do saldo anterior
      vr_dtsldant craprac.dtsldant%TYPE;
      --data movimento
      vr_dtmvtolt crapdat.dtmvtolt%TYPE;
      -- numero da conta da cooperativa
      vr_nrctactl crapcop.nrctactl%TYPE;

      vr_idprglog NUMBER := 0;
      vr_idxcraprac NUMBER := 0;

      ------------------------------- PLTABLE -------------------------------

      -- Tabela temporaria CRAPCPC
      TYPE typ_reg_crapcpc IS
       RECORD(cdprodut crapcpc.cdprodut%TYPE --> Codigo do Produto
             ,cddindex crapcpc.cddindex%TYPE --> Codigo do Indexador
             ,nmprodut crapcpc.nmprodut%TYPE --> Nome do Produto
             ,idsitpro crapcpc.idsitpro%TYPE --> Situação
             ,idtippro crapcpc.idtippro%TYPE --> Tipo
             ,idtxfixa crapcpc.idtxfixa%TYPE --> Taxa Fixa
             ,idacumul crapcpc.idacumul%TYPE --> Taxa Cumulativa
             ,cdhscacc crapcpc.cdhscacc%TYPE --> Débito Aplicação
             ,cdhsvrcc crapcpc.cdhsvrcc%TYPE --> Crédito Resgate/Vencimento Aplicação
             ,cdhsraap crapcpc.cdhsraap%TYPE --> Crédito Renovação Aplicação
             ,cdhsnrap crapcpc.cdhsnrap%TYPE --> Crédito Aplicação Recurso Novo
             ,cdhsprap crapcpc.cdhsprap%TYPE --> Crédito Atualização Juros
             ,cdhsrvap crapcpc.cdhsrvap%TYPE --> Débito Reversão Atualização Juros
             ,cdhsrdap crapcpc.cdhsrdap%TYPE --> Crédito Rendimento
             ,cdhsirap crapcpc.cdhsirap%TYPE --> Débito IRRF
             ,cdhsrgap crapcpc.cdhsrgap%TYPE --> Débito Resgate
             ,cdhsvtap crapcpc.cdhsvtap%TYPE --> Débito Vencimento
             ,indanive crapcpc.indanive%TYPE); --> Produto por Aniversario


      TYPE typ_tab_crapcpc IS TABLE OF typ_reg_crapcpc INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os dados dos produtos de captacao
      vr_tab_crapcpc typ_tab_crapcpc;

      -- Tabela temporaria CRAPLAC
      TYPE typ_reg_craplac IS
       RECORD(cdcooper craplac.cdcooper%TYPE --> Codigo da Cooperativa
             ,nrdconta craplac.nrdconta%TYPE --> Numero da Conta
             ,nraplica craplac.nraplica%TYPE --> Numero da Aplicacao
             ,nrdocmto craplac.nrdocmto%TYPE --> Numero do Documento
             ,nrseqdig craplac.nrseqdig%TYPE --> Numero da Sequencia
             ,vllanmto craplac.vllanmto%TYPE --> Valor do Lancamento
             ,cdhistor craplac.cdhistor%TYPE); --> Codigo de Historico


      TYPE typ_tab_craplac IS TABLE OF typ_reg_craplac INDEX BY PLS_INTEGER;
      vr_tab_craplac typ_tab_craplac;

      -- Tabela temporaria CRAPRAC
      TYPE typ_reg_craprac IS
       RECORD(cdprodut craprac.cdprodut%TYPE --> Codigo do Produto
             ,dtatlsld craprac.dtatlsld%TYPE --> Data de Atualizacao de Saldo
             ,vlsldatl craprac.vlsldatl%TYPE --> Valor do saldo atualizado da aplicacao
             ,txaplica craprac.txaplica%TYPE --> Taxa contratada da aplicacao
             ,vlultren NUMBER); --> Valor Último Rendimento

      TYPE typ_tab_craprac IS TABLE OF typ_reg_craprac INDEX BY VARCHAR(40);
      vr_tab_craprac typ_tab_craprac;

      ------------------------------- CURSORES ---------------------------------

      -- Busca aplicacoes ativas
      CURSOR cr_craprac(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT craprac.cdcooper
              ,craprac.cdprodut
              ,craprac.nrdconta
              ,craprac.nraplica
              ,craprac.dtmvtolt
              ,craprac.dtvencto
              ,craprac.dtatlsld
              ,craprac.txaplica
              ,craprac.qtdiacar
              ,craprac.vlsldant
              ,craprac.dtsldant
              ,craprac.vlsldatl
              ,NVL(craprac.vlslfmes,0) vlslfmes
              ,craprac.rowid
          FROM craprac
         WHERE craprac.cdcooper = pr_cdcooper
           AND craprac.idsaqtot = 0
           AND craprac.cdprodut = 1109--AUT. POUP
           AND craprac.dtmvtolt < to_date('01/07/2021','dd/mm/yyyy');--AUT. POUP

      TYPE typ_craprac IS TABLE OF cr_craprac%ROWTYPE INDEX BY PLS_INTEGER;
      rw_craprac typ_craprac;

      -- valida a existencia de registros de provisao
      CURSOR cr_craplot(pr_cdcooper IN craprac.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT lot.cdcooper
             ,lot.nrseqdig
             ,lot.qtinfoln
             ,lot.qtcompln
             ,lot.vlinfocr
             ,lot.vlcompcr
             ,lot.nrdolote
             ,lot.cdbccxlt
             ,lot.cdagenci
             ,lot.dtmvtolt
             ,lot.rowid
             ,lot.tplotmov
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = 1
         AND lot.cdbccxlt = 100
         AND lot.nrdolote = 8506;

       rw_craplot cr_craplot%ROWTYPE;

       -- valida existencia de informacoes referentes a aplicacoes para o BNDES
      CURSOR cr_crapbnd(pr_cdcooper IN craprac.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_nrdconta IN craprac.nrdconta%TYPE) IS
      SELECT crapbnd.cdcooper
        FROM crapbnd
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND nrdconta = pr_nrdconta;

       rw_crapbnd cr_crapbnd%ROWTYPE;

       -- cursor utilizado para armazenar dados da cooperativa
       CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT cdcooper
             ,nmrescop
             ,nrctactl
         FROM crapcop
        WHERE cdcooper = pr_cdcooper;

       rw_crapcop cr_crapcop%ROWTYPE;


      -- cursor usado para carregar dados de produtos de captacao na PLTABLE
      CURSOR cr_crapcpc IS
      SELECT cdprodut
            ,cddindex
            ,nmprodut
            ,idsitpro
            ,idtippro
            ,idtxfixa
            ,idacumul
            ,cdhscacc
            ,cdhsvrcc
            ,cdhsraap
            ,cdhsnrap
            ,cdhsprap
            ,cdhsrvap
            ,cdhsrdap
            ,cdhsirap
            ,cdhsrgap
            ,cdhsvtap
            ,indanive
        FROM crapcpc cpc
       WHERE cpc.cddindex = 6;--AUT. POUP

       rw_crapcpc cr_crapcpc%ROWTYPE;

       -- resource(row) para retorno de cursor externo(btch0001)
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;

       vr_achou BOOLEAN;

      --------------------------- SUBROTINAS INTERNAS --------------------------

      -- REGISTRA O SALDO DA APLICACAO
      PROCEDURE pc_registra_saldo_aplicacao(pr_nrctactl IN crapcop.nrctactl%TYPE
                                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                           ,pr_cddprazo IN NUMBER
                                           ,pr_vlslfmes IN craprac.vlslfmes%TYPE
                                           ,pr_cdprodut IN crapcpc.cdprodut%TYPE
                                           ,pr_cdcooper IN crapcop.cdcooper%TYPE
                                           ,pr_flgrgprb IN BOOLEAN) IS


        BEGIN

         /*..............................................................................

           Programa: pc_registra_saldo_aplicacao
           Sistema : Conta-Corrente - Cooperativa de Credito
           Sigla   : CRED
           Autor   : Carlos Rafael Tanholi
           Data    : Setembro/2014                       Ultima atualizacao: 12/09/2014

           Dados referentes ao programa:

           Frequencia: Mensal.

           Objetivo  : Registra saldo de aplicacoes dos cooperados das cooperativas
                       singulares para disponibilizar ao BNDES.

         ...............................................................................*/

        DECLARE
        vr_cdorigem NUMBER := 0;
         CURSOR cr_crapprb(pr_nrctactl IN crapcop.nrctactl%TYPE
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                          ,pr_cddprazo IN NUMBER
                          ,pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_cdorigem IN NUMBER) IS

          SELECT 1 FROM crapprb
                  WHERE cdcooper = pr_cdcooper
                    AND nrdconta = pr_nrctactl
                    AND dtmvtolt = pr_dtmvtolt
                    AND cdorigem = pr_cdorigem
                    AND cddprazo = pr_cddprazo;

         rw_crapprb cr_crapprb%ROWTYPE;

         BEGIN
          IF pr_cdprodut = 1109 THEN
            vr_cdorigem := 11;
          ELSE
            vr_cdorigem := 10;
          END IF;
          IF pr_flgrgprb THEN
            --consulta a existencia de um resgistro na crapprb
            OPEN cr_crapprb(pr_nrctactl => pr_nrctactl
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_cddprazo => pr_cddprazo
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_cdorigem => vr_cdorigem);

            FETCH cr_crapprb INTO rw_crapprb;

            IF cr_crapprb%NOTFOUND THEN
               BEGIN
                 INSERT INTO crapprb(cdcooper
                                    ,dtmvtolt
                                    ,nrdconta
                                    ,cdorigem
                                    ,cddprazo
                                    ,vlretorn)
                              VALUES(pr_cdcooper
                                    ,pr_dtmvtolt
                                    ,pr_nrctactl
                                    ,vr_cdorigem
                                    ,pr_cddprazo
                                    ,pr_vlslfmes);

                 EXCEPTION
                   WHEN OTHERS THEN
                     cecred.pc_internal_exception;
                     -- Gerar erro e fazer rollback
                     vr_dscritic := 'Erro ao inserir saldo das aplicacoes (crapprb). Detalhes: '||sqlerrm;
                     RAISE vr_exc_erro;
               END;
            ELSE
               BEGIN

                 UPDATE crapprb SET vlretorn = vlretorn + pr_vlslfmes
                           WHERE cdcooper = pr_cdcooper
                             AND nrdconta = pr_nrctactl
                             AND dtmvtolt = pr_dtmvtolt
                             AND cdorigem = vr_cdorigem
                             AND cddprazo = pr_cddprazo;

                 EXCEPTION
                   WHEN OTHERS THEN
                     cecred.pc_internal_exception;
                     -- Gerar erro e fazer rollback
                     vr_dscritic := 'Erro ao atualizar saldo das aplicacoes (crapprb). Detalhes: '||sqlerrm;
                     RAISE vr_exc_erro;
                 END;

            END IF;
          END IF;
         END;

      END pc_registra_saldo_aplicacao;


      BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        vr_nrctactl := rw_crapcop.nrctactl;
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- busca a ultima data de movimento
       OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        vr_dtmvtolt := rw_crapdat.dtmvtoan;--ALT. POUP
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa  ANALISAR
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      -- carregamento pltable usadas
      FOR rw_crapcpc IN cr_crapcpc
       LOOP

          vr_tab_crapcpc(rw_crapcpc.cdprodut).cddindex := rw_crapcpc.cddindex;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).nmprodut := rw_crapcpc.nmprodut;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).idsitpro := rw_crapcpc.idsitpro;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).idtippro := rw_crapcpc.idtippro;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).idtxfixa := rw_crapcpc.idtxfixa;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).idacumul := rw_crapcpc.idacumul;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhscacc := rw_crapcpc.cdhscacc;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsvrcc := rw_crapcpc.cdhsvrcc;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsraap := rw_crapcpc.cdhsraap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsnrap := rw_crapcpc.cdhsnrap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsprap := rw_crapcpc.cdhsprap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsrvap := rw_crapcpc.cdhsrvap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsrdap := rw_crapcpc.cdhsrdap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsirap := rw_crapcpc.cdhsirap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsrgap := rw_crapcpc.cdhsrgap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsvtap := rw_crapcpc.cdhsvtap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).indanive := rw_crapcpc.indanive;

      END LOOP;

      -- VALIDA a existencia de um resgistro na craplot
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => vr_dtmvtolt);

      FETCH cr_craplot INTO rw_craplot;

      -- insere o registro obrigatorio
      IF cr_craplot%NOTFOUND THEN
        BEGIN
          INSERT INTO craplot(cdcooper
                             ,dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,tplotmov
                             ,nrseqdig
                             ,qtinfoln
                             ,qtcompln
                             ,vlinfocr
                             ,vlcompcr)
                       VALUES(pr_cdcooper
                             ,vr_dtmvtolt
                             ,1
                             ,100
                             ,8506
                             ,9
                             ,0
                             ,0
                             ,0
                             ,0
                             ,0);

        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            -- Gerar erro e fazer rollback
            vr_dscritic := 'Erro ao inserir capas de lotes (craplot). Detalhes: '||sqlerrm;
          RAISE vr_exc_erro;
        END;

      END IF;

      CLOSE cr_craplot;

      vr_tab_craprac.delete;

      -- filtra as aplicacoes da cooperativa
     OPEN cr_craprac(pr_cdcooper);
       LOOP
       FETCH cr_craprac BULK COLLECT INTO rw_craprac LIMIT 5000;
       EXIT WHEN rw_craprac.COUNT = 0;

       vr_idxcraprac := vr_idxcraprac +1;
       FOR idx IN rw_craprac.FIRST..rw_craprac.LAST LOOP

       -- valida o cadastro do historico para o produto da aplicacao
         IF vr_tab_crapcpc(rw_craprac(idx).cdprodut).cdhsprap <= 0 THEN

         -- Gerar log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr HH:mm:ss') || ' - crps685 --> ' ||
                                                       'Campo de historico (cdhsprap) nao informado. ' ||
                                                         'Conta: ' || trim(gene0002.fn_mask_conta(rw_craprac(idx).nrdconta)) ||
                                                         ', Aplic.: ' || trim(gene0002.fn_mask(rw_craprac(idx).nraplica,'zzz.zz9')) ||
                                                         ', Prod.: ' || trim(rw_craprac(idx).cdprodut));
         CONTINUE;

       END IF;

         vr_achou := FALSE;
         vr_index_rac := LPAD(rw_craprac(idx).cdprodut, 10, '0') ||
                         to_char(trunc(rw_craprac(idx).dtatlsld), 'rrrrmmdd') ||
                         LPAD(REPLACE(TRIM(to_char(NVL(rw_craprac(idx).vlsldatl, '0'),'9999999999D99')), ','), 12,'0') ||
                         LPAD(REPLACE(TRIM(to_char(NVL(rw_craprac(idx).txaplica, '0'),'99999999D99')), ','), 10, '0');

        IF vr_tab_craprac.COUNT > 0 THEN
          IF vr_tab_craprac.EXISTS(vr_index_rac) THEN
              -- encontrou registro similar
              vr_achou := TRUE;
              vr_vlultren := vr_tab_craprac(vr_index_rac).vlultren; --> Valor Último Rendimento
          END IF;
        END IF;

        /* Nao precisa calcular e provisionar produtos por aniversario */
        IF vr_tab_crapcpc(rw_craprac(idx).cdprodut).indanive = 1 AND vr_tab_crapcpc(rw_craprac(idx).cdprodut).cddindex <> 6 THEN
          vr_achou := TRUE;
          vr_vlultren := 0;
        END IF;

        IF vr_tab_crapcpc(rw_craprac(idx).cdprodut).idtippro = 1 AND vr_achou = FALSE THEN
        -- procedures para criacao dos lancamentos
          APLI0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac(idx).cdcooper,
                                                  pr_nrdconta => rw_craprac(idx).nrdconta,
                                                  pr_nraplica => rw_craprac(idx).nraplica,
                                                  pr_dtiniapl => rw_craprac(idx).dtmvtolt,
                                                  pr_txaplica => rw_craprac(idx).txaplica,
                                                  pr_idtxfixa => vr_tab_crapcpc(rw_craprac(idx).cdprodut).idtxfixa,
                                                  pr_cddindex => vr_tab_crapcpc(rw_craprac(idx).cdprodut).cddindex,
                                                  pr_qtdiacar => rw_craprac(idx).qtdiacar,
                                                pr_idgravir => vr_idgravir,
                                                pr_idaplpgm => 0,                   -- Aplicação Programada  (0-Não/1-Sim)
                                                  pr_dtinical => rw_craprac(idx).dtatlsld,
                                                pr_dtfimcal => vr_dtmvtolt,
                                                pr_idtipbas => vr_idtipbas,
                                                pr_vlbascal => vr_vlbascal,
                                                pr_vlsldtot => vr_vlsldtot,
                                                pr_vlsldrgt => vr_vlsldrgt,
                                                pr_vlultren => vr_vlultren,
                                                pr_vlrentot => vr_vlrentot,
                                                pr_vlrevers => vr_vlrevers,
                                                pr_vlrdirrf => vr_vlrdirrf,
                                                pr_percirrf => vr_percirrf,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);

        ELSIF vr_tab_crapcpc(rw_craprac(idx).cdprodut).idtippro = 2 AND vr_achou = FALSE and vr_tab_crapcpc(rw_craprac(idx).cdprodut).cddindex <> 6 THEN
        -- procedures para criacao dos lancamentos
          APLI0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac(idx).cdcooper,
                                                  pr_nrdconta => rw_craprac(idx).nrdconta,
                                                  pr_nraplica => rw_craprac(idx).nraplica,
                                                  pr_dtiniapl => rw_craprac(idx).dtmvtolt,
                                                  pr_txaplica => rw_craprac(idx).txaplica,
                                                  pr_idtxfixa => vr_tab_crapcpc(rw_craprac(idx).cdprodut).idtxfixa,
                                                  pr_cddindex => vr_tab_crapcpc(rw_craprac(idx).cdprodut).cddindex,
                                                  pr_qtdiacar => rw_craprac(idx).qtdiacar,
                                                pr_idgravir => vr_idgravir,
                                                pr_idaplpgm => 0,                   -- Aplicação Programada  (0-Não/1-Sim)
                                                  pr_dtinical => rw_craprac(idx).dtatlsld,
                                                pr_dtfimcal => vr_dtmvtolt,
                                                pr_idtipbas => vr_idtipbas,
                                                pr_incalliq => 0,                   --> Nao calcula saldo liquido
                                                pr_vlbascal => vr_vlbascal,
                                                pr_vlsldtot => vr_vlsldtot,
                                                pr_vlsldrgt => vr_vlsldrgt,
                                                pr_vlultren => vr_vlultren,
                                                pr_vlrentot => vr_vlrentot,
                                                pr_vlrevers => vr_vlrevers,
                                                pr_vlrdirrf => vr_vlrdirrf,
                                                pr_percirrf => vr_percirrf,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);

      ELSIF vr_tab_crapcpc(rw_craprac(idx).cdprodut).cddindex = 6 AND vr_achou = FALSE THEN

        APLI0012.pc_provisao_poupanca(pr_cdcooper => rw_craprac(idx).cdcooper,
                    pr_nrdconta => rw_craprac(idx).nrdconta,
                    pr_nraplica => rw_craprac(idx).nraplica,
                    pr_dtmvtolt => vr_dtmvtolt,
                    pr_vlultren => vr_vlultren,
                    pr_cdcritic => vr_cdcritic,
                    pr_dscritic => vr_dscritic);

      END IF;

        -- Se não encontrou popula a temp table com os dados obtidos da posicao do saldo
        IF vr_achou = FALSE THEN
            -- Cabecalho
            vr_tab_craprac(vr_index_rac).cdprodut := rw_craprac(idx).cdprodut; --> Codigo do produto
            vr_tab_craprac(vr_index_rac).dtatlsld := rw_craprac(idx).dtatlsld; --> Data de Atualizacao de Saldo
            vr_tab_craprac(vr_index_rac).vlsldatl := rw_craprac(idx).vlsldatl; --> Valor do saldo atualizado da aplicacao
            vr_tab_craprac(vr_index_rac).txaplica := rw_craprac(idx).txaplica; --> Taxa da Apliacacao
            -- Dados
            vr_tab_craprac(vr_index_rac).vlultren := vr_vlultren; --> Valor Último Rendimento
            vr_index_rac := vr_tab_craprac.COUNT()+1;
        END IF;

      -- tratamento para possiveis erros gerados pelas rotinas anteriores
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro;
      END IF;

      -- valida o ultimo rendimento
      IF vr_vlultren > 0 THEN

        OPEN cr_craplot(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => vr_dtmvtolt);

        FETCH cr_craplot INTO rw_craplot;

        CLOSE cr_craplot;

        -- de acordo com o INSERT executado no inicio deste script
        -- nao ha necessidade de verificacao de existencia do registro
        -- na CRAPLOT entao atualiza o registro ja criado na CRAPLOT
        BEGIN
          UPDATE craplot SET tplotmov = 9
                            ,nrseqdig = rw_craplot.nrseqdig + 1
                            ,qtinfoln = rw_craplot.qtinfoln + 1
                            ,qtcompln = rw_craplot.qtcompln + 1
                            ,vlinfocr = rw_craplot.vlinfocr + vr_vlultren
                            ,vlcompcr = rw_craplot.vlcompcr + vr_vlultren
                       WHERE craplot.rowid = rw_craplot.rowid
                   RETURNING tplotmov, nrseqdig, qtinfoln, qtcompln, vlinfocr, vlcompcr, ROWID
                        INTO rw_craplot.tplotmov, rw_craplot.nrseqdig, rw_craplot.qtinfoln,
                             rw_craplot.qtcompln, rw_craplot.vlinfocr, rw_craplot.vlcompcr, rw_craplot.rowid;

        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            -- Gerar erro e fazer rollback
            vr_dscritic := 'Erro ao atualizar valores do lote(craplot). Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;

        -- armazena o lancamento de provisao
          vr_tab_craplac(vr_index_lac).cdcooper := rw_craprac(idx).cdcooper;
          vr_tab_craplac(vr_index_lac).nrdconta := rw_craprac(idx).nrdconta;
          vr_tab_craplac(vr_index_lac).nraplica := rw_craprac(idx).nraplica;
          vr_tab_craplac(vr_index_lac).nrdocmto := rw_craplot.nrseqdig;
          vr_tab_craplac(vr_index_lac).nrseqdig := rw_craplot.nrseqdig;
          vr_tab_craplac(vr_index_lac).vllanmto := vr_vlultren;
          vr_tab_craplac(vr_index_lac).cdhistor := vr_tab_crapcpc(rw_craprac(idx).cdprodut).cdhsprap;
          vr_index_lac := vr_tab_craplac.COUNT()+1;

      END IF;

      IF (vr_tab_crapcpc(rw_craprac(idx).cdprodut).cddindex = 6) THEN
        rw_craprac(idx).vlslfmes := rw_craprac(idx).vlsldatl + vr_vlultren; 
      ELSE
      -- valida a execucao da ultima atualizacao da aplicacao
        IF rw_craprac(idx).dtatlsld <> vr_dtmvtolt THEN
       -- atualiza os campos valor saldo anterior e data saldo anterior, com os dados atuais na craprac
          vr_vlsldant := rw_craprac(idx).vlsldatl;
          vr_dtsldant := rw_craprac(idx).dtatlsld;
        ELSE -- caso ja tenha atualizado no dia mantem os mesmos valores ja cadastrados
          vr_vlsldant := rw_craprac(idx).vlsldant;
          vr_dtsldant := rw_craprac(idx).dtsldant;
         END IF;

        rw_craprac(idx).vlsldatl := rw_craprac(idx).vlsldatl + vr_vlultren;
        rw_craprac(idx).dtatlsld := vr_dtmvtolt;
        rw_craprac(idx).vlslfmes := rw_craprac(idx).vlsldatl;
        rw_craprac(idx).vlsldant := vr_vlsldant;
        rw_craprac(idx).dtsldant := vr_dtsldant;
      END IF;
      -- Somente para a CECRED
        IF rw_craprac(idx).cdcooper = 3 THEN -- armazena os saldo provisionado das aplicações das cooperativas singulares

        -- verifica a existencia de lancamentos
          OPEN cr_crapbnd(pr_cdcooper => rw_craprac(idx).cdcooper
                       ,pr_dtmvtolt => vr_dtmvtolt
                         ,pr_nrdconta => rw_craprac(idx).nrdconta);

        FETCH cr_crapbnd INTO rw_crapbnd;

          IF cr_crapbnd%NOTFOUND THEN
            BEGIN
             -- grava registro
             INSERT INTO crapbnd (cdcooper
                                 ,dtmvtolt
                                 ,nrdconta
                                 ,vlaplprv)
                            VALUES (rw_craprac(idx).cdcooper
                                 ,vr_dtmvtolt
                                   ,rw_craprac(idx).nrdconta
                                   ,rw_craprac(idx).vlslfmes);

           EXCEPTION
             WHEN OTHERS THEN
               cecred.pc_internal_exception;
               CLOSE cr_crapbnd;
               -- Gerar erro e fazer rollback
               vr_dscritic := 'Erro ao inserir registro de aplicação(crapbnd). Detalhes: '||sqlerrm;
               RAISE vr_exc_erro;
           END;

          ELSE
            BEGIN
              -- atualiza registro
                UPDATE crapbnd SET vlaplprv = vlaplprv + rw_craprac(idx).vlslfmes
                 WHERE cdcooper = rw_craprac(idx).cdcooper
                   AND dtmvtolt = rw_craprac(idx).dtmvtolt
                   AND nrdconta = rw_craprac(idx).nrdconta;

            EXCEPTION
              WHEN OTHERS THEN
                cecred.pc_internal_exception;
                CLOSE cr_crapbnd;
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar aplicação(craprac). Detalhes: '||sqlerrm;
                RAISE vr_exc_erro;
            END;

          END IF;

        CLOSE cr_crapbnd;

        vr_flgrgprb := FALSE;
      ELSE
        vr_flgrgprb := TRUE;
      END IF;

      -- grava os registros separados por conta do cooperado
        pc_registra_saldo_aplicacao(rw_craprac(idx).nrdconta
                                   ,vr_dtmvtolt
                                   ,0
                                   ,rw_craprac(idx).vlslfmes
                                   ,rw_craprac(idx).cdprodut
                                   ,rw_craprac(idx).cdcooper
                                   ,TRUE);

      -- utliza esta variavel para registrar o saldo das aplicacoes
      vr_cdcooper := 3;

      /* Calcula qtd de dias ateh o vencimento da aplicacao */
      vr_qtdias_prazo := (rw_craprac(idx).dtvencto - vr_dtmvtolt);
      
        IF vr_tab_crapcpc(rw_craprac(idx).cdprodut).cddindex = 6  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,0,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo <= 90 THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,90,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 91 AND 180  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,180,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 181 AND 270  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,270,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 271 AND 360  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,360,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 361 AND 720  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,720,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 721 AND 1080  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,1080,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 1081 AND 1440  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,1440,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 1441 AND 1800  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,1800,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 1801 AND 2160  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,2160,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 2161 AND 2520  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,2520,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 2521 AND 2880  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,2880,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 2881 AND 3240  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,3240,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 3241 AND 3600  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,3600,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 3961 AND 4320  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,4320,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 4321 AND 4680  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,4680,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo BETWEEN 4681 AND 5400  THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,5400,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);

        ELSIF vr_qtdias_prazo >= 5401 THEN
          pc_registra_saldo_aplicacao(vr_nrctactl,vr_dtmvtolt,5401,rw_craprac(idx).vlslfmes,rw_craprac(idx).cdprodut,vr_cdcooper, vr_flgrgprb);
      END IF;

      END LOOP; -- loop do bulk collect

      BEGIN
        FORALL idx IN 1..rw_craprac.COUNT SAVE EXCEPTIONS
          UPDATE craprac
             SET vlsldatl = rw_craprac(idx).vlsldatl
                ,dtatlsld = rw_craprac(idx).dtatlsld
                ,vlslfmes = rw_craprac(idx).vlslfmes
                ,vlsldant = rw_craprac(idx).vlsldant
                ,dtsldant = rw_craprac(idx).dtsldant
           WHERE rowid = rw_craprac(idx).rowid;

      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          CLOSE cr_craprac;

          FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
            cecred.pc_log_programa(PR_DSTIPLOG => 'E'
                                  ,PR_CDPROGRAMA => vr_cdprogra
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_dsmensagem => 'craprac -' ||
                                                    ' rowid: '    || rw_craprac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).rowid ||
                                                    ' vlsldatl: ' || rw_craprac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlsldatl ||
                                                    ' dtatlsld: ' || rw_craprac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).dtatlsld ||
                                                    ' vlslfmes: ' || rw_craprac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlslfmes ||
                                                    ' vlsldant: ' || rw_craprac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlsldant ||
                                                    ' dtsldant: ' || rw_craprac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).dtsldant ||
                                                    ' Oracle error: ' || SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE)
                                  ,PR_IDPRGLOG => vr_idprglog);
          END LOOP;

          vr_dscritic := 'Erro ao atualizar aplicação(craprac). Detalhes: '||sqlerrm;
          RAISE vr_exc_erro;
      END;

    END LOOP; -- loop do fetch

    vr_tab_craprac.delete;
    CLOSE cr_craprac;

    BEGIN
      FORALL idx IN 1..vr_tab_craplac.COUNT SAVE EXCEPTIONS
        INSERT INTO craplac(cdcooper
                           ,dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,nrdconta
                           ,nraplica
                           ,nrdocmto
                           ,nrseqdig
                           ,vllanmto
                           ,cdhistor)
                     VALUES(vr_tab_craplac(idx).cdcooper
                           ,vr_dtmvtolt
                           ,1 -- Fixo
                           ,100 -- Fixo
                           ,8506 -- Fixo
                           ,vr_tab_craplac(idx).nrdconta
                           ,vr_tab_craplac(idx).nraplica
                           ,vr_tab_craplac(idx).nrdocmto
                           ,vr_tab_craplac(idx).nrseqdig
                           ,vr_tab_craplac(idx).vllanmto
                           ,vr_tab_craplac(idx).cdhistor);

    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        CLOSE cr_craprac;
        --CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO
        FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
          cecred.pc_log_programa(PR_DSTIPLOG => 'E'
                                ,PR_CDPROGRAMA => vr_cdprogra
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_dsmensagem => 'craplac -' ||
                                                  ' cdcooper: ' || vr_tab_craplac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).cdcooper ||
                                                  ' dtmvtolt: ' || vr_dtmvtolt ||
                                                  ' nrdconta: ' || vr_tab_craplac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrdconta ||
                                                  ' nrdocmto: ' || vr_tab_craplac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrdocmto ||
                                                  ' Oracle error: ' || SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE)
                                ,PR_IDPRGLOG => vr_idprglog);
        END LOOP;

        vr_dscritic := 'Erro ao inserir lancamentos(craplac). Detalhes: ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
        RAISE vr_exc_erro;
    END;

    vr_tab_craplac.DELETE;

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 THEN
          -- Buscar a descrição
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

END PC_CRPS685_poupanca;

begin
  declare
  vr_cdcritic  crapcri.cdcritic%TYPE;
  vr_dscritic  crapcri.dscritic%TYPE;
  vr_stprogra VARCHAR(40);
  vr_infimsol VARCHAR(40);
  begin
    vr_stprogra := 0;
    vr_infimsol := 0;
    PC_CRPS685_poupanca (pr_cdcooper => 1,
                         pr_flgresta => 0,
                         pr_stprogra => vr_stprogra,
                         pr_infimsol => vr_infimsol,
                         pr_cdcritic => vr_cdcritic,
                         pr_dscritic => vr_dscritic);
    --                         
    dbms_output.put_line('vr_cdcritic:'||vr_cdcritic);
    dbms_output.put_line('vr_dscritic:'||vr_dscritic);                    
    --
    vr_stprogra := 0;
    vr_infimsol := 0;
     PC_CRPS685_poupanca (pr_cdcooper => 16,
                          pr_flgresta => 0,
                          pr_stprogra => vr_stprogra,
                          pr_infimsol => vr_infimsol,
                          pr_cdcritic => vr_cdcritic,
                          pr_dscritic => vr_dscritic);
    --
    dbms_output.put_line('vr_cdcritic:'||vr_cdcritic);
    dbms_output.put_line('vr_dscritic:'||vr_dscritic); 
    --                          
  end;
end;
