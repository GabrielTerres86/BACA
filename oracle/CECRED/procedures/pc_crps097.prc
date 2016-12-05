CREATE OR REPLACE PROCEDURE CECRED.pc_crps097(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa Solicitada
                                             ,pr_flgresta IN PLS_INTEGER --> Flag 0/1 para utilizar restart na chamada
                                             ,pr_stprogra OUT PLS_INTEGER --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS --> Texto de erro/critica encontrada
  /* ..........................................................................

   Programa: Fontes/crps097.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/94.                           Ultima atualizacao: 28/11/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Efetuar o lote de devolucoes e taxas de devolucoes para contra-ordem.

   Alteracoes: 16/05/95 - Incluido o campo crapdev.cdalinea (Edson).

               26/10/95 - Tratar lancamento 46, leitura de taxa devolucao de
                          cheque, nao criar lancamento zerado. (Odair).

               21/01/97 - Alterado para tratar historico 191 no lugar do
                          47 (Deborah).

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               16/12/98 - Tratar historico 47 para digitacao fora compe
                          para tratamento da contabilidade (Odair)

               24/06/99 - Tratar historico 338 (Odair)

               04/08/99 - Fazer o tratamento para andar junto com as devolucoes
                          diarias da tela devolu (Odair)

               17/05/2001 - Tratar devolucao de cheque TB do bancoob (Edson).

               24/11/2002 - Tratar o nrdocmto no histor. 46 (Ze Eduardo).

               27/03/2003 - Tratar historico 156 (Dev. chq. CEF) (Edson)

               25/06/2003 - Tratar Alinea 49 (Dev. alineas 12 e 13) (Ze).

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm,crapavs e crapalt (Diego).

               12/12/2005 - Alteracao de crapchq p/ crapfdc (Ze).             

               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               12/02/2007 - Alterar consultas com indice crapfdc1 (David).

               07/03/2007 - Ajustes para o Bancoob (Magui).

               16/06/2009 - Alimentar res_nrctachq com digito 0 e nao X
                          - Validar se crapavs ja exite antes da 
                            criacao do crapavs para cdhistor 46(Guilherme).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               08/01/2010 - Acrescentar historico 573 no mesmo CAN-DO do 338
                            (Guilherme/Supero)
                            
               06/08/2010 - Incluir controle para o envio do arquivo de Dev.
                            (Ze).

               09/09/2010 - Alterado o valor de indevarq para novo padrao.
                            De 0 para 1 e de 1 para 2. (Guilherme/Supero)
                            
               24/09/2010 - Acerto na atualizacao do campo indevarq (Ze).
               
               04/10/2010 - Identificar quando lancamento foi enviado para
                            ABBC na 1a ou 2a Devolucao (Ze).
                            
               17/11/2010 - Acerto no valor do VLB Truncagem (Ze).
               
               07/01/2011 - Desprezar a criacao no lcm das ctas cadastradas
                            no TCO - Migracao de PACs (Ze).
                            
               30/03/2012 - Ignorar os registros de devolucao com nrdconta = 0
                            e alinea = 37. (Fabricio)
                            
               18/06/2012 - Alteraçăo na leitura da craptco (David Kruger).
               
               20/12/2012 - Adaptacao para a Migracao AltoVale (Ze).
               
               21/03/2013 - Ajustes referentes ao projeto tarifas fase 2 
                            Grupo de cheques (Lucas R).
                            
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               14/01/2014 - Inclusao de VALIDATE craplot e craplcm (Carlos)
               
               25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                            tari0001.pc_cria_lan_auto_tarifa, projeto de 
                            Tarifas-218(Jean Michel) 

              16/08/2016 - Ajuste para alterar o campo indevarq para 2 também
                           quando forem cheques VLB, pois o crps264 precisa
                           identificar estes cheques para envia-los a ABBC
                           no primeiro horário da manhă
                           (Adriano - SD 501761).

              18/08/2016 - Efetuada a troca da nomenclatura "ERRO" para "CRITICA"
                           caso o aviso de debito ja existir, evitando acionamento
                           desnecessario visto que essa critica nao abortado a
                           execucao do processo. (Daniel)

              23/11/2016 - Conversao Progress >> PLSQL. (Jaison/Daniel)

              23/11/2016 - Para as devolucoes por falta de saldo (11 e 12) nao vamos efetuar o 
                           lancamento atraves deste programa (Lucas Ranghetti/Elton - Melhoria 69) 

              24/11/2016 - Alterar ordem da verificacao das alineas 11 e 12 
                           (Lucas Ranghetti/Elton - Melhoria 69)

              28/11/2016 - Somente vamos atualizar a situaçao da devolucao caso 
                           nao seja alinea de cheque ja entrou, caso contrario 
                           daremos um next (Lucas Ranghetti/Elton)

  ............................................................................. */

BEGIN

  DECLARE

    -- Variaveis de criticas
    vr_cdcritic INTEGER;
    vr_cdprogra VARCHAR2(10);
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de excecao
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_tab_erro   GENE0001.typ_tab_erro;
  
    -- Cadastro da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    -- Devolucao de cheques ou taxa de devolucao
    CURSOR cr_crapdev(pr_cdcooper IN crapdev.cdcooper%TYPE) IS
      SELECT crapdev.cdcooper,
             crapdev.nrdconta,
             crapdev.nrdctitg,
             crapdev.cdalinea,
             crapdev.cdhistor,
             crapdev.cdbanchq,
             crapdev.cdagechq,
             crapdev.nrctachq,
             crapdev.nrcheque,
             crapdev.vllanmto,
             crapdev.nrdctabb,
             crapdev.indevarq,
             crapdev.cdoperad,
             crapdev.ROWID
        FROM crapdev
       WHERE crapdev.cdcooper = pr_cdcooper
         AND crapdev.insitdev = 0; -- A devolver
  
    -- Cadastro do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.cdagenci
            ,crapass.cdsecext
            ,crapass.inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    -- Cadastro de folhas de cheques
    CURSOR cr_crapfdc(pr_cdcooper IN crapfdc.cdcooper%TYPE
                     ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE
                     ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                     ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                     ,pr_nrcheque IN crapfdc.nrcheque%TYPE) IS
      SELECT crapfdc.dtliqchq,
             crapfdc.cdcmpchq,
             crapfdc.cdbanchq,
             crapfdc.ROWID
        FROM crapfdc 
       WHERE crapfdc.cdcooper = pr_cdcooper
         AND crapfdc.cdbanchq = pr_cdbanchq
         AND crapfdc.cdagechq = pr_cdagechq
         AND crapfdc.nrctachq = pr_nrctachq
         AND crapfdc.nrcheque = pr_nrcheque;
    rw_crapfdc cr_crapfdc%ROWTYPE;
  
    -- Tabela de contas transferidas entre cooperativas
    CURSOR cr_craptco(pr_cdcooper IN craptco.cdcooper%TYPE
                     ,pr_nrctaant IN craptco.nrctaant%TYPE) IS
      SELECT 1
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.nrctaant = pr_nrctaant
         AND craptco.tpctatrf = 1
         AND craptco.flgativo = 1;
    rw_craptco cr_craptco%ROWTYPE;
  
    -- Compensacao de Cheques da Central
    CURSOR cr_gncpchq(pr_cdcooper IN gncpchq.cdcooper%TYPE
                     ,pr_dtmvtolt IN gncpchq.dtmvtolt%TYPE
                     ,pr_cdtipreg IN gncpchq.cdtipreg%TYPE
                     ,pr_cdcmpchq IN gncpchq.cdcmpchq%TYPE
                     ,pr_cdbanchq IN gncpchq.cdbanchq%TYPE
                     ,pr_cdagechq IN gncpchq.cdagechq%TYPE
                     ,pr_nrctachq IN gncpchq.nrctachq%TYPE
                     ,pr_nrcheque IN gncpchq.nrcheque%TYPE
                     ,pr_vlcheque IN gncpchq.vlcheque%TYPE) IS
      SELECT gncpchq.cdalinea,
             gncpchq.ROWID
        FROM gncpchq
       WHERE gncpchq.cdcooper = pr_cdcooper
         AND gncpchq.dtmvtolt = pr_dtmvtolt
         AND gncpchq.cdtipreg = pr_cdtipreg
         AND gncpchq.cdcmpchq = pr_cdcmpchq
         AND gncpchq.cdbanchq = pr_cdbanchq
         AND gncpchq.cdagechq = pr_cdagechq
         AND gncpchq.nrctachq = pr_nrctachq
         AND gncpchq.nrcheque = pr_nrcheque
         AND gncpchq.vlcheque = pr_vlcheque;
    rw_gncpchq cr_gncpchq%ROWTYPE;
  
    -- Cadastro dos avisos de debito em conta corrente
    CURSOR cr_crapavs(pr_cdcooper IN crapavs.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapavs.dtmvtolt%TYPE
                     ,pr_cdagenci IN crapavs.cdagenci%TYPE
                     ,pr_cdsecext IN crapavs.cdsecext%TYPE
                     ,pr_nrdconta IN crapavs.nrdconta%TYPE
                     ,pr_nrdocmto IN crapavs.nrdocmto%TYPE) IS
      SELECT 1
        FROM crapavs
       WHERE crapavs.cdcooper = pr_cdcooper
         AND crapavs.dtmvtolt = pr_dtmvtolt
         AND crapavs.cdempres = 0
         AND crapavs.cdagenci = pr_cdagenci
         AND crapavs.cdsecext = pr_cdsecext
         AND crapavs.nrdconta = pr_nrdconta
         AND crapavs.dtdebito = pr_dtmvtolt
         AND crapavs.cdhistor = 46
         AND crapavs.nrdocmto = pr_nrdocmto;
    rw_crapavs cr_crapavs%ROWTYPE;

    -- Tipo de dado para receber os dados da tabela craplot
    rw_craplot LOTE0001.cr_craplot%ROWTYPE;

    -- Tipo de dado para receber as datas da tabela crapdat
    rw_crapdat btch0001.rw_crapdat%TYPE;

    -- Variaveis Gerais
    vr_blnfound BOOLEAN;
    vr_cdtarifa VARCHAR2(10);
    vr_cdtarbac VARCHAR2(10);
    vr_cdhistor INTEGER;
    vr_cdhisest INTEGER;
    vr_vltarifa NUMBER;
    vr_dtdivulg DATE;
    vr_dtvigenc DATE;
    vr_cdfvlcop INTEGER;
    vr_cdhisbac INTEGER;
    vr_vltarbac NUMBER;
    vr_cdfvlbac INTEGER;
    vr_dstextab craptab.dstextab%TYPE;
    vr_ctpsqitg craplcm.nrdctabb%TYPE;
    vr_nrdctitg crapass.nrdctitg%TYPE;
    vr_rowidlcm ROWID;
    vr_rowidlat ROWID;
    vr_qtcompln INTEGER := 0;
    vr_qtinfoln INTEGER := 0;
    vr_vltotlan NUMBER := 0;

  BEGIN
  
    ----------------------
    -- Validações iniciais
    ----------------------
  
    vr_cdprogra := 'CRPS097';
  
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => NULL);
  
    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
  
    -- Se retornou critica aborta programa
    IF vr_cdcritic <> 0 THEN
      RAISE vr_exc_saida;
    END IF;
  
    -------------------
    -- Rotina Principal
    -------------------
  
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
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
  
    -- Busca a data Atual
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
  
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Remove registros devolvidos
    BEGIN
      DELETE
        FROM crapdev
       WHERE crapdev.cdcooper = pr_cdcooper
         AND crapdev.insitdev = 1; -- Devolvido
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := 'Problema ao excluir CRAPDEV: ' || SQLERRM;
      RAISE vr_exc_saida;
    END;

    -- Busca valor VLB
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                              pr_nmsistem => 'CRED',
                                              pr_tptabela => 'GENERI',
                                              pr_cdempres => 0,
                                              pr_cdacesso => 'VALORESVLB',
                                              pr_tpregist => 0);
    -- Se NAO encontrou
    IF TRIM(vr_dstextab) IS NULL THEN
      vr_cdcritic := 55;
      RAISE vr_exc_saida;
    END IF;

    -- Listagem dos lancamentos automaticos
    FOR rw_crapdev IN cr_crapdev(pr_cdcooper => pr_cdcooper) LOOP

      IF rw_crapdev.nrdconta = 0        AND 
         rw_crapdev.cdalinea IN (35,37) AND 
         rw_crapdev.cdhistor = 47       THEN
         -- Somente vamos atualizar a situaçao da devolucao caso 
         -- nao seja alinea de cheque ja entrou(alinea 35), caso contrario 
         -- daremos um next
         IF rw_crapdev.cdalinea <> 35 THEN
           BEGIN
             UPDATE crapdev
                SET indevarq = 2
                   ,insitdev = 1
              WHERE ROWID    = rw_crapdev.ROWID;
           EXCEPTION
             WHEN OTHERS THEN
               NULL;
           END;
         END IF;
         CONTINUE;
      END IF;

      -- Efetua a busca do registro
      OPEN cr_crapass(pr_cdcooper => rw_crapdev.cdcooper
                     ,pr_nrdconta => rw_crapdev.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapass%FOUND;
      -- Fecha cursor
      CLOSE cr_crapass;
      -- Se NAO achou faz raise
      IF NOT vr_blnfound THEN
        vr_dscritic := GENE0002.fn_mask_conta(rw_crapdev.nrdconta)
                    || ' - ' || GENE0001.fn_busca_critica(251);
        RAISE vr_exc_saida;
      END IF;

      -- Para as devolucoes por falta de saldo (11 e 12) nao vamos efetuar o 
      -- lancamento atraves deste programa (Lucas Ranghetti/Elton)

      IF rw_crapdev.cdalinea IN (11,12) THEN
        CONTINUE;
      END IF;

      IF rw_crapass.inpessoa = 1 THEN
        vr_cdtarifa := 'DEVOLCHQPF';
        vr_cdtarbac := 'DEVCHQBCPF';
      ELSE
        vr_cdtarifa := 'DEVOLCHQPJ';
        vr_cdtarbac := 'DEVCHQBCPJ';
      END IF;
      
      IF vr_cdtarifa = 'DEVOLCHQPF' OR
         vr_cdtarifa = 'DEVOLCHQPJ' THEN

         -- Busca o valor da tarifa
         TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper   -- Codigo Cooperativa
                                               ,pr_cdbattar  => vr_cdtarifa   -- Codigo Tarifa
                                               ,pr_vllanmto  => 1             -- Valor Lancamento
                                               ,pr_cdprogra  => vr_cdprogra   -- Codigo Programa
                                               ,pr_cdhistor  => vr_cdhistor   -- Codigo Historico
                                               ,pr_cdhisest  => vr_cdhisest   -- Historico Estorno
                                               ,pr_vltarifa  => vr_vltarifa   -- Valor tarifa
                                               ,pr_dtdivulg  => vr_dtdivulg   -- Data Divulgacao
                                               ,pr_dtvigenc  => vr_dtvigenc   -- Data Vigencia
                                               ,pr_cdfvlcop  => vr_cdfvlcop   -- Codigo faixa valor cooperativa
                                               ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
                                               ,pr_dscritic  => vr_dscritic   -- Descricao Critica
                                               ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
         -- Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           -- Se possui erro no vetor
           IF vr_tab_erro.COUNT > 0 THEN
             vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
             vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
           ELSE
             vr_cdcritic := 0;
             vr_dscritic := 'Nao foi possivel carregar a tarifa.';
           END IF;
           -- Levantar Excecao
           RAISE vr_exc_saida;
         END IF;

      END IF; -- vr_cdtarifa

      -- Busca informacoes da taxa bacen
      IF vr_cdtarbac = 'DEVCHQBCPF' OR
         vr_cdtarbac = 'DEVCHQBCPJ' THEN

         -- Busca o valor da tarifa
         TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper   -- Codigo Cooperativa
                                               ,pr_cdbattar  => vr_cdtarbac   -- Codigo Tarifa
                                               ,pr_vllanmto  => 1             -- Valor Lancamento
                                               ,pr_cdprogra  => vr_cdprogra   -- Codigo Programa
                                               ,pr_cdhistor  => vr_cdhisbac   -- Codigo Historico
                                               ,pr_cdhisest  => vr_cdhisest   -- Historico Estorno
                                               ,pr_vltarifa  => vr_vltarbac   -- Valor tarifa
                                               ,pr_dtdivulg  => vr_dtdivulg   -- Data Divulgacao
                                               ,pr_dtvigenc  => vr_dtvigenc   -- Data Vigencia
                                               ,pr_cdfvlcop  => vr_cdfvlbac   -- Codigo faixa valor cooperativa
                                               ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
                                               ,pr_dscritic  => vr_dscritic   -- Descricao Critica
                                               ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
         -- Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           -- Se possui erro no vetor
           IF vr_tab_erro.COUNT > 0 THEN
             vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
             vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
           ELSE
             vr_cdcritic := 0;
             vr_dscritic := 'Nao foi possivel carregar a tarifa.';
           END IF;
           -- Levantar Excecao
           RAISE vr_exc_saida;
         END IF;

      END IF; -- vr_cdtarbac

      --  47 = Devolucao de cheque fora compe
      -- 156 = Devolucao de cheque CEF (Concredi)
      -- 191 = Devolucao de cheque BB
      -- 338 = Devolucao de cheque BANCOOB
      --  78 = Devolucao de cheque Transferencia

      vr_ctpsqitg := 0;
      vr_nrdctitg := rw_crapdev.nrdctitg;

      -- Executar rotina para extrair digito zero da conta integracao
      GENE0005.pc_conta_itg_digito_zero(pr_nrdctitg => vr_nrdctitg
                                       ,pr_ctpsqitg => vr_ctpsqitg
                                       ,pr_des_erro => vr_dscritic);
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Devolucao cheque normal
      IF rw_crapdev.cdhistor IN (47,78,156,191,338,573) THEN

        -- Cadastro de folhas de cheques
        OPEN cr_crapfdc(pr_cdcooper => pr_cdcooper
                       ,pr_cdbanchq => rw_crapdev.cdbanchq
                       ,pr_cdagechq => rw_crapdev.cdagechq
                       ,pr_nrctachq => rw_crapdev.nrctachq
                       ,pr_nrcheque => TO_NUMBER(SUBSTR(GENE0002.fn_mask(rw_crapdev.nrcheque,'99999999'),1,7)));
        FETCH cr_crapfdc INTO rw_crapfdc;
        -- Alimenta a booleana se achou ou nao
        vr_blnfound := cr_crapfdc%FOUND;
        -- Fecha cursor
        CLOSE cr_crapfdc;
        -- Se NAO achou faz raise
        IF NOT vr_blnfound THEN
          vr_dscritic := GENE0001.fn_busca_critica(268)
                      || ' COOP: ' || pr_cdcooper
                      || ' CTA:'   || rw_crapdev.nrdconta
                      || ' ITG: '  || rw_crapdev.nrdctitg
                      || ' DOC: '  || rw_crapdev.nrcheque;
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se a conta esta cadastrado no TCO - Se existir 
        -- despreza a criacao do lanc. Soh ira criar no dia seguinte 
        -- pela tela DEVOLU - Risco em criar o lanc. mas a outra coop
        -- ja rodou crps001 (Ze).

        IF pr_cdcooper IN (1,2) THEN

          -- Cadastro de folhas de cheques
          OPEN cr_craptco(pr_cdcooper => pr_cdcooper
                         ,pr_nrctaant => rw_crapdev.nrdconta);
          FETCH cr_craptco INTO rw_craptco;
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_craptco%FOUND;
          -- Fecha cursor
          CLOSE cr_craptco;
          -- Se achou continua
          IF vr_blnfound THEN
            CONTINUE;
          END IF;

        END IF;

        -- Seta os valores
        vr_qtcompln := vr_qtcompln + 1;
        vr_qtinfoln := vr_qtinfoln + 1;
        vr_vltotlan := vr_vltotlan + rw_crapdev.vllanmto;

        -- Procedimento para inserir o lote e nao deixar tabela lockada
        LOTE0001.pc_insere_lote(pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdagenci => 1
                               ,pr_cdbccxlt => 100
                               ,pr_nrdolote => 8451
                               ,pr_cdoperad => '1'
                               ,pr_nrdcaixa => 0
                               ,pr_tplotmov => 1
                               ,pr_cdhistor => 0
                               ,pr_craplot  => rw_craplot
                               ,pr_dscritic => vr_dscritic);
        -- Se ocorreu erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Cria registro na tabela de lancamentos
        BEGIN
          INSERT INTO craplcm
            (cdcooper
            ,dtmvtolt
            ,cdagenci
            ,cdbccxlt
            ,nrdolote
            ,nrdctabb
            ,nrdocmto
            ,vllanmto
            ,nrdconta
            ,cdhistor
            ,nrseqdig
            ,nrdctitg
            ,cdpesqbb
            ,cdbanchq
            ,cdagechq
            ,nrctachq)
          VALUES
            (pr_cdcooper
            ,rw_craplot.dtmvtolt
            ,rw_craplot.cdagenci
            ,rw_craplot.cdbccxlt
            ,rw_craplot.nrdolote
            ,rw_crapdev.nrdctabb
            ,rw_crapdev.nrcheque
            ,rw_crapdev.vllanmto
            ,rw_crapdev.nrdconta
            ,rw_crapdev.cdhistor
            ,rw_craplot.nrseqdig
            ,rw_crapdev.nrdctitg
            ,(CASE WHEN rw_crapdev.cdalinea <> 0 THEN TO_CHAR(rw_crapdev.cdalinea) ELSE '21' END)
            ,rw_crapdev.cdbanchq
            ,rw_crapdev.cdagechq
            ,rw_crapdev.nrctachq)
         RETURNING craplcm.ROWID
              INTO vr_rowidlcm;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao inserir CRAPLCM: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Se existir crapfdc
        IF rw_crapfdc.ROWID IS NOT NULL THEN
          BEGIN
            UPDATE crapfdc
               SET incheque = incheque - 5
                  ,dtliqchq = NULL
                  ,vlcheque = 0
                  ,vldoipmf = 0
             WHERE ROWID    = rw_crapfdc.ROWID
         RETURNING crapfdc.dtliqchq
              INTO rw_crapfdc.dtliqchq;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao atualizar CRAPFDC: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;

        IF rw_crapdev.cdbanchq = 85 THEN

          -- Atribui Valor para Alinea na GNCPCHQ
          IF rw_crapfdc.ROWID IS NOT NULL THEN

            -- Compensacao de Cheques da Central
            OPEN cr_gncpchq(pr_cdcooper => rw_crapdev.cdcooper
                           ,pr_dtmvtolt => rw_crapfdc.dtliqchq
                           ,pr_cdtipreg => 3
                           ,pr_cdcmpchq => rw_crapfdc.cdcmpchq
                           ,pr_cdbanchq => rw_crapfdc.cdbanchq
                           ,pr_cdagechq => rw_crapdev.cdagechq
                           ,pr_nrctachq => rw_crapdev.nrctachq
                           ,pr_nrcheque => TO_NUMBER(rw_crapdev.nrcheque)
                           ,pr_vlcheque => rw_crapdev.vllanmto);
            FETCH cr_gncpchq INTO rw_gncpchq;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_gncpchq%FOUND;
            -- Fecha cursor
            CLOSE cr_gncpchq;
            -- Se achou
            IF vr_blnfound THEN
              -- Atualiza
              BEGIN
                UPDATE gncpchq
                   SET cdalinea = (CASE WHEN rw_crapdev.cdalinea <> 0 THEN rw_crapdev.cdalinea ELSE 21 END)
                 WHERE ROWID    = rw_gncpchq.ROWID;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;

          END IF;

          -- Atualiza
          BEGIN
            UPDATE crapdev
               SET indevarq = 2
             WHERE ROWID    = rw_crapdev.ROWID;
            UPDATE craplcm
               SET dsidenti = '2'
             WHERE ROWID    = vr_rowidlcm;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

        END IF; -- rw_crapdev.cdbanchq = 85

      ELSIF rw_crapdev.cdhistor = 46 AND (vr_vltarifa > 0 OR vr_vltarbac > 0) THEN

        -- Verifica se a conta esta cadastrado no TCO - Se existir 
        -- despreza a criacao do lanc. Soh ira criar no dia seguinte 
        -- pela tela DEVOLU - Risco em criar o lanc. mas a outra coop
        -- ja rodou crps001 (Ze).

        IF pr_cdcooper IN (1,2) THEN

          -- Cadastro de folhas de cheques
          OPEN cr_craptco(pr_cdcooper => pr_cdcooper
                         ,pr_nrctaant => rw_crapdev.nrdconta);
          FETCH cr_craptco INTO rw_craptco;
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_craptco%FOUND;
          -- Fecha cursor
          CLOSE cr_craptco;
          -- Se achou continua
          IF vr_blnfound THEN
            CONTINUE;
          END IF;

        END IF;

        -- Cadastro dos avisos de debito
        OPEN cr_crapavs(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_cdagenci => rw_crapass.cdagenci
                       ,pr_cdsecext => rw_crapass.cdsecext
                       ,pr_nrdconta => rw_crapass.nrdconta
                       ,pr_nrdocmto => rw_crapdev.nrcheque);
        FETCH cr_crapavs INTO rw_crapavs;
        -- Alimenta a booleana se achou ou nao
        vr_blnfound := cr_crapavs%FOUND;
        -- Fecha cursor
        CLOSE cr_crapavs;
        -- Caso o aviso de debito ja existir gera erro no LOG e continua a execucao
        IF vr_blnfound THEN
          -- Escreve no log
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || 'CRITICA: Registro de aviso de debito ja existe - '
                                                      || 'Conta: '  || TO_CHAR(rw_crapass.nrdconta) || ' '
                                                      || 'Cheque: ' || TO_CHAR(rw_crapdev.nrcheque));
          CONTINUE;
        END IF;
        
        IF vr_cdtarifa IN ('DEVOLCHQPF','DEVOLCHQPJ') AND rw_crapass.inpessoa <> 3 THEN

          -- Criar Lancamento automatico tarifa
          TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                          ,pr_nrdconta      => rw_crapass.nrdconta
                                          ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                          ,pr_cdhistor      => vr_cdhistor
                                          ,pr_vllanaut      => vr_vltarifa
                                          ,pr_cdoperad      => '1'
                                          ,pr_cdagenci      => 1
                                          ,pr_cdbccxlt      => 100
                                          ,pr_nrdolote      => 8452
                                          ,pr_tpdolote      => 1
                                          ,pr_nrdocmto      => rw_crapdev.nrcheque
                                          ,pr_nrdctabb      => rw_crapdev.nrdctabb
                                          ,pr_nrdctitg      => rw_crapdev.nrdctitg
                                          ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(rw_crapdev.nrcheque)
                                          ,pr_cdbanchq      => rw_crapdev.cdbanchq
                                          ,pr_cdagechq      => rw_crapdev.cdagechq
                                          ,pr_nrctachq      => rw_crapdev.nrctachq
                                          ,pr_flgaviso      => TRUE
                                          ,pr_tpdaviso      => 2
                                          ,pr_cdfvlcop      => vr_cdfvlcop
                                          ,pr_inproces      => rw_crapdat.inproces
                                          ,pr_rowid_craplat => vr_rowidlat
                                          ,pr_tab_erro      => vr_tab_erro
                                          ,pr_cdcritic      => vr_cdcritic
                                          ,pr_dscritic      => vr_dscritic);
          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Se possui erro no vetor
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Erro no lancamento tarifa de devolucao de cheque.';
            END IF;
            -- Levantar Excecao
            RAISE vr_exc_saida;
          END IF;

        END IF; -- vr_cdtarifa / rw_crapass.inpessoa <> 3

        IF vr_cdtarbac IN ('DEVCHQBCPF','DEVCHQBCPJ') AND rw_crapass.inpessoa <> 3 THEN

          -- Criar Lancamento automatico tarifa
          TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                          ,pr_nrdconta      => rw_crapass.nrdconta
                                          ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                          ,pr_cdhistor      => vr_cdhisbac
                                          ,pr_vllanaut      => vr_vltarbac
                                          ,pr_cdoperad      => rw_crapdev.cdoperad
                                          ,pr_cdagenci      => 1
                                          ,pr_cdbccxlt      => 100
                                          ,pr_nrdolote      => 8452
                                          ,pr_tpdolote      => 1
                                          ,pr_nrdocmto      => 0
                                          ,pr_nrdctabb      => rw_crapdev.nrdctabb
                                          ,pr_nrdctitg      => rw_crapdev.nrdctitg
                                          ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(rw_crapdev.nrcheque)
                                          ,pr_cdbanchq      => rw_crapdev.cdbanchq
                                          ,pr_cdagechq      => rw_crapdev.cdagechq
                                          ,pr_nrctachq      => rw_crapdev.nrctachq
                                          ,pr_flgaviso      => FALSE
                                          ,pr_tpdaviso      => 0
                                          ,pr_cdfvlcop      => vr_cdfvlbac
                                          ,pr_inproces      => rw_crapdat.inproces
                                          ,pr_rowid_craplat => vr_rowidlat
                                          ,pr_tab_erro      => vr_tab_erro
                                          ,pr_cdcritic      => vr_cdcritic
                                          ,pr_dscritic      => vr_dscritic);
          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Se possui erro no vetor
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Erro no lancamento tarifa de devolucao de cheque.';
            END IF;
            -- Levantar Excecao
            RAISE vr_exc_saida;
          END IF;

        END IF; -- vr_cdtarbac / rw_crapass.inpessoa <> 3

      END IF; -- rw_crapdev.cdhistor

      -- Atualiza a situacao
      BEGIN
        UPDATE crapdev
           SET insitdev = 1
         WHERE ROWID    = rw_crapdev.ROWID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

    END LOOP; -- cr_crapdev

    -- Atualiza a capa do lote
    BEGIN
      UPDATE craplot
         SET qtcompln = qtcompln + vr_qtcompln
            ,qtinfoln = qtinfoln + vr_qtinfoln
            ,vlinfocr = vlinfocr + vr_vltotlan
            ,vlcompcr = vlcompcr + vr_vltotlan
       WHERE ROWID    = rw_craplot.ROWID;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Problema ao atualizar CRAPLOT: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na procedure PC_CRPS097. ' || SQLERRM;
      ROLLBACK;

  END;

END;
/
