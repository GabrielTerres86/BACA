CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps083 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrao para utilizacao de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                    ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

   Programa: pc_crps083  (Antigo: Fontes/crps083.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 21/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 4.
               Emite relatorio com os emprestimos concedidos no mes (69).

   Alteracoes: 19/11/96 - Alterar a mascara do campo nrctremp (Odair).

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               30/10/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

             05/01/2001 - Alterar o nome dos formularios de impressao para
                          132dm. (Eduardo).

             06/08/2001 - Tratar prejuizo de conta corrente (Margarete).

             13/01/2005 - Gerar o relatorio 408 (Evandro).

             15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

             01/09/2008 - Alteracao CDEMPRES (Kbase).

             11/05/2009 - Alteracao CDOPERAD (Kbase).

             09/09/2013 - Nova forma de chamar as agencias, de PAC agora
                          a escrita sera PA (Andrao Euzebio - Supero).

             20/12/2013 - Conversao Progress -> Oracle (Edison - AMcom)

             21/01/2015 - Alterado o formato do campo nrctremp para 8
                          caracters (Kelvin - 233714)
    ............................................................................ */

    DECLARE
      -- tipo de registro para cooperados
      TYPE typ_reg_crapass IS
        RECORD( nrdconta crapass.nrdconta%TYPE
               ,nrmatric crapass.nrmatric%TYPE
               ,nmprimtl crapass.nmprimtl%TYPE
               );

      -- cadastro de associados
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
        INDEX BY PLS_INTEGER;

      -- tipo de registro para operadores
      TYPE typ_reg_crapope IS
        RECORD( cdoperad crapope.cdoperad%TYPE
               ,nmoperad crapope.nmoperad%TYPE
               );

      -- cadastro de operadores
      TYPE typ_tab_crapope IS
        TABLE OF typ_reg_crapope
        INDEX BY VARCHAR2(10);

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Codigo do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS083';

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
      -- cadastro de emprestimos
      CURSOR cr_crapepr ( pr_cdcooper crapepr.cdcooper%TYPE
                         ,pr_dtmvtolt crapepr.dtmvtolt%TYPE) IS
        SELECT  crapepr.nrdconta
               ,crapepr.dtmvtolt
               ,crapepr.cdagenci
               ,crapepr.cdbccxlt
               ,crapepr.nrdolote
               ,crapepr.vlemprst
               ,crapepr.cdempres
               ,crapepr.nrctremp
               ,crapepr.qtpreemp
        FROM crapepr
        WHERE  crapepr.cdcooper = pr_cdcooper
        AND    to_char(crapepr.dtmvtolt,'MMYYYY') = to_char(pr_dtmvtolt,'MMYYYY')
        AND    crapepr.inprejuz <> 1
        ORDER BY crapepr.nrdconta
                ,crapepr.nrctremp;
      -- rowtype de emprestimos
      rw_crapepr cr_crapepr%ROWTYPE;

      -- seleciona dados dos cooperados
      CURSOR cr_crapass( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.nrmatric
              ,crapass.nmprimtl
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper;

      -- seleciona os operadores da cooperativa
      CURSOR cr_crapope( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapope.cdoperad
              ,crapope.nmoperad
        FROM   crapope
        WHERE crapope.cdcooper = pr_cdcooper;


      -- Cursor generico de calendario
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      ------------------------------- VARIAVEIS -------------------------------
      vr_tab_crapass typ_tab_crapass;
      vr_tab_crapope typ_tab_crapope;
      vr_nrdconta    NUMBER;
      vr_cdpesqui    VARCHAR2(4000);
      vr_qtctremp    NUMBER;
      vr_vlemprst    NUMBER;
      vr_qtassoci    NUMBER;
      -- Variável de Controle de XML
      vr_des_xml      CLOB;
      vr_path_arquivo VARCHAR2(1000);
      vr_nmmesref     VARCHAR2(100);

      --------------------------- SUBROTINAS INTERNAS --------------------------
      --Procedure que escreve linha no arquivo CLOB
	    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

      -------------------------------------------
      --Procedure para gerar o relatório crrl408
      -------------------------------------------
      PROCEDURE pc_rel_408 IS
        -- lançamentos de estorno
        CURSOR cr_craplcm(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_dtmvtolt IN DATE
                         ,pr_dtmvtopr IN DATE
                           ) is
          SELECT craplcm.cdpesqbb
                ,craplcm.dtmvtolt
                ,craplcm.cdagenci
                ,craplcm.cdbccxlt
                ,craplcm.nrdolote
                ,craplcm.nrseqdig
                ,craplcm.nrdconta
                ,craplcm.vllanmto
          FROM   craplcm
          WHERE  craplcm.cdcooper = pr_cdcooper
            AND  craplcm.dtmvtolt > pr_dtmvtolt
            AND  craplcm.dtmvtolt < pr_dtmvtopr
            AND  craplcm.cdhistor = 317 /* estorno */
          ORDER  BY craplcm.cdagenci
                   ,craplcm.nrdconta;
        rw_craplcm cr_craplcm%ROWTYPE;

        -- seleciona os lotes
        CURSOR cr_craplot( pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dtmvtolt IN DATE
                          ,pr_cdagenci IN craplot.cdagenci%TYPE
                          ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                          ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
          SELECT craplot.cdoperad
          FROM   craplot
          WHERE  craplot.cdcooper = pr_cdcooper
          AND    craplot.dtmvtolt = pr_dtmvtolt
          AND    craplot.cdagenci = pr_cdagenci
          AND    craplot.cdbccxlt = pr_cdbccxlt
          AND    craplot.nrdolote = pr_nrdolote;
        rw_craplot cr_craplot%ROWTYPE;

        vr_dtmvtolt DATE;
        vr_dspesqui VARCHAR2(4000);
        vr_dsoperad VARCHAR2(4000);
        vr_nrctremp VARCHAR2(4000);
        vr_qtestorn NUMBER;
        vr_vlestorn craplcm.vllanmto%TYPE;

      BEGIN
        /* ultimo dia do mes anterior */
        vr_dtmvtolt := Trunc(rw_crapdat.dtmvtolt,'MONTH') - 1;

        -- inicializando os totais
        vr_qtestorn := 0;
        vr_vlestorn := 0;

        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -------------------------------------------
        -- Iniciando a geração do XML
        -------------------------------------------
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl408>');

        -- abrindo o cursor de lançamentos
        OPEN cr_craplcm ( pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => vr_dtmvtolt
                         ,pr_dtmvtopr => rw_crapdat.dtmvtopr);
        LOOP
          FETCH cr_craplcm INTO rw_craplcm;
          EXIT WHEN cr_craplcm%NOTFOUND;

          -- busca a primeira string delimitada pelo caracter ";"
          vr_nrctremp := gene0002.fn_busca_entrada( pr_postext     => 1   --> Posicao do parametro desejada
                                                   ,pr_dstext      => rw_craplcm.cdpesqbb --> Texto a ser analisado
                                                   ,pr_delimitador => ';'); --> Delimitador utilizado na string
          -- eliminando os zeros a esquerda
          vr_nrctremp := To_Number(REPLACE(vr_nrctremp,'.',''));

          -- montado o campo de pesquisa
          vr_dspesqui := to_char(rw_craplcm.dtmvtolt,'DD/MM/YYYY') ||
                          '-' || lpad(rw_craplcm.cdagenci, 3, '0') ||
                          '-' || lpad(rw_craplcm.cdbccxlt, 3, '0') ||
                          '-' || lpad(rw_craplcm.nrdolote, 6, '0') ||
                          '-' || lpad(Nvl(rw_craplcm.nrseqdig,0), 5, '0');

          -- abre o cursor dos lotes
          OPEN cr_craplot( pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => rw_craplcm.dtmvtolt
                          ,pr_cdagenci => rw_craplcm.cdagenci
                          ,pr_cdbccxlt => rw_craplcm.cdbccxlt
                          ,pr_nrdolote => rw_craplcm.nrdolote);
          FETCH cr_craplot INTO rw_craplot;

          -- se o lote existir, busca o nome do operador
          IF  cr_craplot%FOUND THEN
            -- Busca o nome do operador
            IF vr_tab_crapope.EXISTS(rw_craplot.cdoperad) THEN
              -- codigo e nome do operador
              vr_dsoperad := rpad(vr_tab_crapope(rw_craplot.cdoperad).cdoperad, 10, ' ') || '-' || vr_tab_crapope(rw_craplot.cdoperad).nmoperad;
            ELSE
              -- operador nao cadastrado
              vr_dsoperad := '** NAO CADASTRADO **';
            END IF;
          END IF;
          -- fechando o cursor
          CLOSE cr_craplot;

          -- verifica se o cooperado esta cadastrado
          IF NOT vr_tab_crapass.EXISTS(rw_craplcm.nrdconta) THEN
            -- 251 - Associado nao encontrado no crapass. ERRO DE SISTEMA.
            vr_cdcritic := 251;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic||' CONTA = '||
                                                      rw_craplcm.nrdconta);
            -- limpando as variaveis de erro
            vr_cdcritic := NULL;
            vr_dscritic := NULL;

            -- vai para o proximo registro do cursor
            CONTINUE;
          END IF;
          -------------------------------------------
          -- Escrevendo a linha de detalhe
          -------------------------------------------
          pc_escreve_xml('<lancamento>'||
                           '<cdagenci>'||rw_craplcm.cdagenci||'</cdagenci>'||
                           '<nrdconta>'||gene0002.fn_mask_conta(rw_craplcm.nrdconta)||'</nrdconta>'||
                           '<nrctremp>'||gene0002.fn_mask_contrato(vr_nrctremp)||'</nrctremp>'||
                           '<nmprimtl>'||vr_tab_crapass(rw_craplcm.nrdconta).nmprimtl||'</nmprimtl>'||
                           '<vllanmto>'||rw_craplcm.vllanmto||'</vllanmto>'||
                           '<dsoperad>'||SubStr(vr_dsoperad, 1, 20)||'</dsoperad>'||
                           '<dspesqui>'||vr_dspesqui||'</dspesqui>'||
                         '</lancamento>');

          -- totalizando a quantidade e o valor dos lancamentos de estorno
          vr_qtestorn := Nvl(vr_qtestorn,0) + 1;
          vr_vlestorn := Nvl(vr_vlestorn,0) + Nvl(rw_craplcm.vllanmto,0);
        END LOOP;
        -- fechando o cursor
        CLOSE cr_craplcm;

        -- se não possuir lançamentos, gera um registro em branco no xml
        IF Nvl(vr_qtestorn,0) = 0 THEN
          -------------------------------------------
          -- Escrevendo a linha de detalhe
          -------------------------------------------
          pc_escreve_xml('<lancamento>'||
                           '<cdagenci></cdagenci>'||
                           '<nrdconta></nrdconta>'||
                           '<nrctremp></nrctremp>'||
                           '<nmprimtl></nmprimtl>'||
                           '<vllanmto></vllanmto>'||
                           '<dsoperad></dsoperad>'||
                           '<dspesqui></dspesqui>'||
                         '</lancamento>');
        END IF;
        -- totalizando e encerrando o XML
        pc_escreve_xml('<qtestorn>'||gene0002.fn_mask(vr_qtestorn,'zzz.zz9')||'</qtestorn>'||
                      '<vlestorn>'||Nvl(vr_vlestorn,0)||'</vlestorn>'||
                      '</crrl408>');

        -- Gerando o relatorio
        gene0002.pc_solicita_relato(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra  => vr_cdprogra
                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                  ,pr_dsxml     => vr_des_xml
                                  ,pr_dsxmlnode => '/crrl408/lancamento'
                                  ,pr_dsjasper  => 'crrl408.jasper'
                                  ,pr_dsparams  => 'PR_MESREF##'||vr_nmmesref -- mes de referencia
                                  ,pr_dsarqsaid => vr_path_arquivo ||'/crrl408.lst'
                                  ,pr_flg_gerar => 'N'
                                  ,pr_qtcoluna  => 132
                                  ,pr_sqcabrel  => 2
                                  ,pr_flg_impri => 'S'
                                  ,pr_nmformul  => '132col'
                                  ,pr_nrcopias  => 1
                                  ,pr_des_erro  => vr_dscritic);

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
      END;

    BEGIN
      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverÃ¡ raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
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

      -- limpa a tabela de associados
      vr_tab_crapass.delete;

      -- carrega a tabela de associados
      FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapass(rw_crapass.nrdconta).nrdconta := rw_crapass.nrdconta;
        vr_tab_crapass(rw_crapass.nrdconta).nrmatric := rw_crapass.nrmatric;
        vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
      END LOOP;

      -- limpa a tabela de operadores
      vr_tab_crapope.delete;

      -- carrega a tabela de operadores
      FOR rw_crapope IN cr_crapope(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapope(rw_crapope.cdoperad).cdoperad := rw_crapope.cdoperad;
        vr_tab_crapope(rw_crapope.cdoperad).nmoperad := rw_crapope.nmoperad;
      END LOOP;

      -- Validacoes iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);

      -- Se a variavel de erro for <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Mês/ano referencia que será exibido no relatório
      vr_nmmesref := GENE0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt,'MM'))||'/'||to_char(rw_crapdat.dtmvtolt,'YYYY');

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Busca do diretório base da cooperativa e a subpasta de relatórios
      vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -------------------------------------------
      -- Iniciando a geração do XML
      -------------------------------------------
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl069>');

      -- inicializando os contadores e controles
      vr_nrdconta := 9999999999;
      vr_qtctremp := 0;
      vr_vlemprst := 0;

      -- Busca os dados dos emprestimos do mes atual
      OPEN cr_crapepr( pr_cdcooper => pr_cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
      LOOP
        FETCH cr_crapepr INTO rw_crapepr;
        EXIT WHEN cr_crapepr%NOTFOUND;
        -- se o número da conta de emprestimo for diferente do
        -- numero de conta auxiliar, verifica se o associado está cadastrado
        IF rw_crapepr.nrdconta <> vr_nrdconta THEN
          /*FIND crapass OF crapepr NO-LOCK NO-ERROR.*/
          IF NOT vr_tab_crapass.EXISTS(rw_crapepr.nrdconta) THEN
            -- 251 - Associado nao encontrado no crapass. ERRO DE SISTEMA.
            vr_cdcritic := 251;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic||' CONTA = '||
                                                      lpad(rw_crapepr.nrdconta, 9, '0'));

            -- limpando as variaveis de erro
            vr_cdcritic := NULL;
            vr_dscritic := NULL;

            --Fechando o cursor
            CLOSE cr_crapepr;

            --Abortando a execução do programa
            RAISE vr_exc_saida;
          END IF;

          vr_nrdconta := vr_tab_crapass(rw_crapepr.nrdconta).nrdconta;
          vr_qtassoci := Nvl(vr_qtassoci,0) + 1;
        END IF;

        -- totalizando a quantidade de contratos
        vr_qtctremp := Nvl(vr_qtctremp,0) + 1;
        -- totalizando o valor total dos emprestimos
        vr_vlemprst := Nvl(vr_vlemprst,0) + rw_crapepr.vlemprst;

        -- montando o código de pesquisa
        vr_cdpesqui := to_char(rw_crapepr.dtmvtolt,'dd/mm/yyyy') || '-' ||
                       LPad(rw_crapepr.cdagenci, 3, '0')         || '-' ||
                       LPad(rw_crapepr.cdbccxlt, 3, '0')         || '-' ||
                       LPad(rw_crapepr.nrdolote, 6, '0');

        -------------------------------------------
        -- Iniciando a geração do XML
        -------------------------------------------
        pc_escreve_xml('<conta>'||
                         '<nrdconta>'||gene0002.fn_mask_conta(rw_crapepr.nrdconta)||'</nrdconta>'||
                         '<cdempres>'||rw_crapepr.cdempres||'</cdempres>'||
                         '<nrmatric>'||gene0002.fn_mask(vr_tab_crapass(vr_nrdconta).nrmatric, 'zzz.zz9' )||'</nrmatric>'||
                         '<nmprimtl>'||substr(vr_tab_crapass(vr_nrdconta).nmprimtl, 1, 38)||'</nmprimtl>'||
                         '<nrctremp>'||gene0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9')||'</nrctremp>'||
                         '<qtpreemp>'||rw_crapepr.qtpreemp||'</qtpreemp>'||
                         '<vlemprst>'||rw_crapepr.vlemprst||'</vlemprst>'||
                         '<cdpesqui>'||vr_cdpesqui||'</cdpesqui>'||
                       '</conta>'
                       );
      END LOOP;
      -- fechando o cursor
      CLOSE cr_crapepr;
      -- totalizando e encerrando o XML
      pc_escreve_xml('<qtassoci>'||gene0002.fn_mask(vr_qtassoci,'zzz.zz9')||'</qtassoci>'||
                     '<qtctremp>'||gene0002.fn_mask(vr_qtctremp,'zzz.zz9')||'</qtctremp>'||
                     '<vlemprst>'||vr_vlemprst||'</vlemprst>'||
                     '</crrl069>');

      -- Gerando o relatorio
      gene0002.pc_solicita_relato(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra  => vr_cdprogra
                                ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                ,pr_dsxml     => vr_des_xml
                                ,pr_dsxmlnode => '/crrl069/conta'
                                ,pr_dsjasper  => 'crrl069.jasper'
                                ,pr_dsparams  => 'PR_MESREF##'||vr_nmmesref -- mes de referencia
                                ,pr_dsarqsaid => vr_path_arquivo ||'/crrl069.lst'
                                ,pr_flg_gerar => 'N'
                                ,pr_qtcoluna  => 132
                                ,pr_sqcabrel  => 1
                                ,pr_flg_impri => 'S'
                                ,pr_nmformul  => '132dm'
                                ,pr_nrcopias  => 1
                                ,pr_des_erro  => vr_dscritic);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      -- gerando o relatorio 408
      pc_rel_408;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informacoes atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descricao
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
        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descricao
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos codigo e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps083;
/

