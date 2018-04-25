CREATE OR REPLACE PROCEDURE CECRED.pc_crps201(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                          ,pr_flgresta IN PLS_INTEGER --> Flag padrao para utilizacao de restart
                                          ,pr_stprogra OUT PLS_INTEGER --> Saida de termino da execucao
                                          ,pr_infimsol OUT PLS_INTEGER --> Saida de termino da solicitacao
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                          ,pr_dscritic OUT VARCHAR2) IS

      /* ..........................................................................

       Programa: PC_CRPS201 (Antigo Fontes/crps201.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Junho/97.                       Ultima atualizacao: 30/06/2016 

       Dados referentes ao programa:

       Frequencia: Diario (Batch)
       Objetivo  : Atende a solicitacao .
                   Gerar estatistica  de talonarios.

       Alteracoes: 03/10/97 - Alterado para utilizar rotina padrao de calculo de
                              talonarios e ler crapreq utilizando o dia do movi-
                              mento e tipo de requisicao igual 1.

                   03/09/98 - Alterar para colocar numero de folhas (Odair).
                   14/08/00 - Incluir atualizacao de 2 novos campos
                              .qtrttbc e .qtsltlbc (Margarete)

                 22/10/2004 - Tratar conta de integracao (Margarete).

                 08/06/2005 - Tratar tipo 17 e 18(Mirtes)

                 30/06/2005 - Alimentado campo cdcooper da tabela crapger (Diego).

                 16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                 29/08/2008 - Comentar taloes retirados do log (Magui).

                 22/01/2009 - Alteracao cdempres (Diego).

                 08/10/2009 - Adaptacoes projeto IF CECRED (Guilherme).

                 17/05/2010 - Tratar crapger.cdempres com 9999 em vez de 999
                              (Diego).

                 27/09/2010 - Acertar atuazicoes para IF CECRED (Magui).

                 16/01/2014 - Inclusao de VALIDATE crapger (Carlos)

                 28/04/2015 -  Convers?o Progress >> Oracle PL/SQL (Lombardi)
                 
                 30/06/2016 - Retirar controle de restart e update na CRAPRES.
                              Incluir Exceptions dentro dos Loopings de Insert.
                              Tratar crapger.cdempres com 9999 em vez de 999
                              (Evandro).
                 
                 05/03/2018 - Removidas regras que contabilizam cheques do BB e do
                              Bancoob pelas cooperativas. PRJ366 (Lombardi).
    ............................................................................. */

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      --Constantes
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS201';

      --Variaveis para retorno de erro
      vr_cdcritic INTEGER := 0;
      vr_dscritic VARCHAR2(4000);

      --Variaveis de Controle de Restart
      vr_nrctares  INTEGER:= 0;
      --vr_inrestar  INTEGER:= 0;
      --vr_dsrestar  INTEGER:= 0;

      --Variaveis de Excecao
      vr_exc_final  EXCEPTION;
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;

      ------------------------------- TABELAS -------------------------------
      TYPE typ_reg_qt IS
        RECORD (qtretemp INT
               ,qtsolemp INT
               ,qtsolpac INT
               ,qtretpac INT);

      TYPE typ_tab_qt IS
        TABLE OF typ_reg_qt
        INDEX BY BINARY_INTEGER;

      ------------------------------- VARIAVEIS -------------------------------

      vr_regexist BOOLEAN;
      vr_dtdiault DATE;
      vr_contador INTEGER;
      vr_nrinicta INTEGER;
      vr_nrfincta INTEGER;
      vr_qttalona INTEGER;
      vr_cdempres INTEGER;
      vr_nrfolhas INTEGER;
      vr_nrcalcul DECIMAL;
      vr_nrposchq INTEGER;
      vr_qtsolemp INTEGER;
      vr_qtretemp INTEGER;
      vr_qtsolpac INTEGER;
      vr_qtretpac INTEGER;
      /*
      vr_tab_qt_bb typ_tab_qt;
      vr_tab_qt_bc typ_tab_qt;
      */
      vr_tab_qt_ct typ_tab_qt;

      ------------------------------- CURSORES ---------------------------------

      -- Buscar os dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT crapcop.nmrescop,
               crapcop.nrtelura,
               crapcop.dsdircop,
               crapcop.cdbcoctl,
               crapcop.cdagectl,
               crapcop.nrctactl,
               crapcop.cdcooper
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

      -- Buscar dados de requisic?o
      CURSOR cr_crapreq (pr_cdcooper IN crapreq.cdcooper%TYPE,
                         pr_dtmvtolt IN crapreq.dtmvtolt%TYPE) IS
        SELECT req.cdcooper
               ,req.nrdconta
               ,req.nrfinchq
               ,req.cdtipcta
               ,req.qtreqtal
               ,req.nrinichq
          FROM crapreq req
            WHERE req.cdcooper = pr_cdcooper
              AND req.tprequis = 1 -- 1-NORMAL
              AND req.dtmvtolt = pr_dtmvtolt;
      rw_crapreq cr_crapreq%ROWTYPE;

      -- Buscar dados do cadastro de associado
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                         pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.cdcooper
               ,ass.nrdconta
               ,ass.inpessoa
               ,ass.cdagenci
               ,ass.cdbcochq
           FROM crapass ass
          WHERE ass.cdcooper = pr_cdcooper
            AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Buscar dados de pessoa fisica
      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE,
                         pr_nrdconta IN crapttl.nrdconta%TYPE) IS
        SELECT ttl.cdcooper
               ,ttl.cdempres
           FROM crapttl ttl
          WHERE ttl.cdcooper = pr_cdcooper
            AND ttl.nrdconta = pr_nrdconta
            AND ttl.idseqttl = 1;
      rw_crapttl cr_crapttl%ROWTYPE;

      -- Buscar dados de pessoa juridica
      CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE,
                         pr_nrdconta IN crapjur.nrdconta%TYPE) IS
        SELECT jur.cdcooper
               ,jur.cdempres
           FROM crapjur jur
          WHERE jur.cdcooper = pr_cdcooper
            AND jur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;

      ---------------------------------------
      -- Inicio Bloco principal pc_crps201
      ---------------------------------------
    BEGIN
      --Limpar parametros saida
      pr_cdcritic := NULL;
      pr_dscritic := NULL;

      -- Incluir nome do modulo logado
      gene0001.pc_informa_acesso(pr_module => 'pc_' || vr_cdprogra,
                                 pr_action => NULL);

      -- Validac?es iniciais do programa
      btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                                pr_flgbatch => 1,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_cdcritic => vr_cdcritic);
                               
      -- Se ocorreu erro
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
      -- Verificar se existe informac?o, e gerar erro caso n?o exista
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapcop;
        -- Gerar excec?o
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(SYSDATE,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Buscar a data do movimento
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- Verificar se existe informac?o, e gerar erro caso n?o exista
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE btch0001.cr_crapdat;
        -- Gerar excec?o
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;
      CLOSE btch0001.cr_crapdat;

      -- Pega a data do ultimo dia do mes corrente
      vr_dtdiault := rw_crapdat.dtultdia;

      --
      vr_regexist := FALSE;
      vr_nrfolhas := 20;

      -- Busca as requisicoes de talonarios com a data do movimento atual.
      FOR rw_crapreq  IN cr_crapreq (pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

        -- Numero da ultima folha de cheque emitida nessa requisicao.
        vr_nrcalcul := rw_crapreq.nrfinchq;

        -- Calcular a quantidade de taloes e a posic?o do cheque no tal?o
        CHEQ0001.pc_numtal( pr_nrfolhas => vr_nrfolhas -- numero da primeira folha de cheque emitida nesse pedido
                           ,pr_nrcalcul => vr_nrcalcul
                           ,pr_nrtalchq => vr_nrfincta
                           ,pr_nrposchq => vr_nrposchq);

        -- Numero da primeira folha de cheque emitida nessa requisicao.
        vr_nrcalcul := rw_crapreq.nrinichq;

        -- Calcular a quantidade de taloes e a posic?o do cheque no tal?o
        CHEQ0001.pc_numtal( pr_nrfolhas => vr_nrfolhas -- numero da primeira folha de cheque emitida nesse pedido
                           ,pr_nrcalcul => vr_nrcalcul
                           ,pr_nrtalchq => vr_nrinicta
                           ,pr_nrposchq => vr_nrposchq);

        -- Quantidade de tal?es de cheque
        vr_qttalona := (vr_nrfincta - vr_nrinicta) + 1;
        vr_regexist := TRUE;

        -- Selecionar Dados do Associado
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_crapreq.nrdconta);
        FETCH cr_crapass INTO rw_crapass;

        -- Se nao encontrou associado
        IF cr_crapass%NOTFOUND THEN
          vr_cdcritic:= 9; -- 9 - Associado nao cadastrado.
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                        gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.9');
          -- Fechar Cursor
          CLOSE cr_crapass;
          -- Gera Log
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro Tratado
                                     pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                        ' -' || vr_cdprogra || ' --> '  ||
                                                        vr_dscritic);
          -- Efetua Raise
          RAISE vr_exc_saida;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapass;

        -- Verifica se e pessoa fisica ou juridica
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
           OPEN cr_crapttl(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => rw_crapreq.nrdconta);
           FETCH cr_crapttl INTO rw_crapttl;

           -- Se encontrou associado
           IF cr_crapttl%FOUND THEN
             vr_cdempres := rw_crapttl.cdempres;
           END IF;

           CLOSE cr_crapttl;

        ELSE-- Pessoa Juridica
           OPEN cr_crapjur(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => rw_crapreq.nrdconta);
           FETCH cr_crapjur INTO rw_crapjur;

           -- Se encontrou associado
           IF cr_crapjur%FOUND THEN
             vr_cdempres := rw_crapjur.cdempres;
           END IF;

           CLOSE cr_crapjur;
        END IF;

        -- Certifica que a quantidade de folhas de cheque emitidas nessa requisicao n?o seja negativa.
        IF rw_crapreq.nrfinchq < 1  THEN
          vr_qttalona := 0;
        END IF;
        /*
        IF rw_crapreq.cdtipcta < 5 OR -- 1-NORMAL | 2-ESPECIAL | 3-NORMAL CONJUNTA | 4-ESPEC. CONJUNTA
          (rw_crapreq.cdtipcta > 11 AND -- 12-NORMAL ITG | 13-ESPECIAL ITG | 14-NORMAL CJTA ITG | 15-ESPEC.CJTA ITG
          rw_crapreq.cdtipcta < 16) THEN
          -- Zerando as variaveis de auxilio
          vr_qtsolemp := 0;
          vr_qtretemp := 0;
          vr_qtsolpac := 0;
          vr_qtretpac := 0;

          -- Preenchimento das variaveis de auxilio para depois incrementar na tabela.
          IF vr_tab_qt_bb.EXISTS(vr_cdempres) THEN
            vr_qtsolemp := nvl(vr_tab_qt_bb(vr_cdempres).qtsolemp,0);
            vr_qtretemp := nvl(vr_tab_qt_bb(vr_cdempres).qtretemp,0);
          END IF;
          IF vr_tab_qt_bb.EXISTS(rw_crapass.cdagenci) THEN
            vr_qtsolpac := nvl(vr_tab_qt_bb(rw_crapass.cdagenci).qtsolpac,0);
            vr_qtretpac := nvl(vr_tab_qt_bb(rw_crapass.cdagenci).qtretpac,0);
          END IF;

          -- Quantidade de talonarios requisitados. Pelo codigo da empresa
          vr_tab_qt_bb(vr_cdempres).qtsolemp := vr_qtsolemp + rw_crapreq.qtreqtal;

          -- Quantidade de talonarios requisitados. Pelo codigo da agencia do associado
          vr_tab_qt_bb(rw_crapass.cdagenci).qtsolpac := vr_qtsolpac + rw_crapreq.qtreqtal;

          -- Quantidade de tal?es de cheque requisitados. Pelo codigo da empresa
          vr_tab_qt_bb(vr_cdempres).qtretemp := vr_qtretemp + vr_qttalona;

          -- Quantidade de tal?es de cheque requisitados. Pelo codigo da agencia do associado
          vr_tab_qt_bb(rw_crapass.cdagenci).qtretpac := vr_qtretpac + vr_qttalona;
        END IF;
        */
        -- Zerando as variaveis de auxilio
        vr_qtsolemp := 0;
        vr_qtretemp := 0;
        vr_qtsolpac := 0;
        vr_qtretpac := 0;
        /*
        IF rw_crapreq.cdtipcta > 7 AND -- 8-NORMAL CONVENIO | 9-ESPEC. CONVENIO | 10-CONJ. CONVENIO | 11-CONJ.ESP.CONV.
           rw_crapreq.cdtipcta < 12 THEN
          IF  rw_crapass.cdbcochq = rw_crapcop.cdbcoctl  THEN -- Se for CECRED
        */
            -- Preenchimento das variaveis de auxilio para depois incrementar na tabela.
            IF vr_tab_qt_ct.EXISTS(vr_cdempres) THEN
              vr_qtsolemp := nvl(vr_tab_qt_ct(vr_cdempres).qtsolemp,0);
              vr_qtretemp := nvl(vr_tab_qt_ct(vr_cdempres).qtretemp,0);
            END IF;
            IF vr_tab_qt_ct.EXISTS(rw_crapass.cdagenci) THEN
              vr_qtsolpac := nvl(vr_tab_qt_ct(rw_crapass.cdagenci).qtsolpac,0);
              vr_qtretpac := nvl(vr_tab_qt_ct(rw_crapass.cdagenci).qtretpac,0);
            END IF;

            -- Quantidade de talonarios requisitados. Pelo codigo da empresa
            vr_tab_qt_ct(vr_cdempres).qtsolemp := vr_qtsolemp + nvl(rw_crapreq.qtreqtal,0);

            -- Quantidade de talonarios requisitados. Pelo codigo da agencia do associado
            vr_tab_qt_ct(rw_crapass.cdagenci).qtsolpac := vr_qtsolpac + nvl(rw_crapreq.qtreqtal,0);

            -- Quantidade de tal?es de cheque requisitados. Pelo codigo da empresa
            vr_tab_qt_ct(vr_cdempres).qtretemp := vr_qtretemp + vr_qttalona;

            -- Quantidade de tal?es de cheque requisitados. Pelo codigo da agencia do associado
            vr_tab_qt_ct(rw_crapass.cdagenci).qtretpac := vr_qtretpac + vr_qttalona;
        /*
          ELSE -- Se for BANCOOB

            -- Preenchimento das variaveis de auxilio para depois incrementar na tabela.
            IF vr_tab_qt_bc.EXISTS(vr_cdempres) THEN
              vr_qtsolemp := nvl(vr_tab_qt_bc(vr_cdempres).qtsolemp,0);
              vr_qtretemp := nvl(vr_tab_qt_bc(vr_cdempres).qtretemp,0);
            END IF;
            IF vr_tab_qt_bc.EXISTS(rw_crapass.cdagenci) THEN
              vr_qtsolpac := nvl(vr_tab_qt_bc(rw_crapass.cdagenci).qtsolpac,0);
              vr_qtretpac := nvl(vr_tab_qt_bc(rw_crapass.cdagenci).qtretpac,0);
            END IF;

            -- Quantidade de talonarios requisitados. Pelo codigo da empresa
            vr_tab_qt_bc(vr_cdempres).qtsolemp := vr_qtsolemp + nvl(rw_crapreq.qtreqtal,0);

            -- Quantidade de talonarios requisitados. Pelo codigo da agencia do associado
            vr_tab_qt_bc(rw_crapass.cdagenci).qtsolpac := vr_qtsolpac + nvl(rw_crapreq.qtreqtal,0);

            -- Quantidade de tal?es de cheque requisitados. Pelo codigo da empresa
            vr_tab_qt_bc(vr_cdempres).qtretemp := vr_qtretemp + vr_qttalona;

            -- Quantidade de tal?es de cheque requisitados. Pelo codigo da agencia do associado
            vr_tab_qt_bc(rw_crapass.cdagenci).qtretpac := vr_qtretpac + vr_qttalona;
          END IF;
        END IF;
        */
      END LOOP;

      -- Se n?o existir registros, encerra o procedure
      IF NOT vr_regexist THEN
        RAISE vr_exc_fimprg;
      END IF;

      -- Acrescenta numero da conta de restart
      vr_nrctares := vr_nrctares + 1;

      -- Inicializa as variaveis que receber?o as somas
      /*
      -- Banco do Brasil
      IF NOT vr_tab_qt_bb.EXISTS(999) THEN
        vr_tab_qt_bb(999).qtsolemp := 0;
        vr_tab_qt_bb(999).qtsolpac := 0;
        vr_tab_qt_bb(999).qtretemp := 0;
        vr_tab_qt_bb(999).qtretpac := 0;
      END IF;

      -- Bancoob
      IF NOT vr_tab_qt_bc.EXISTS(999) THEN
        vr_tab_qt_bc(999).qtsolemp := 0;
        vr_tab_qt_bc(999).qtsolpac := 0;
        vr_tab_qt_bc(999).qtretemp := 0;
        vr_tab_qt_bc(999).qtretpac := 0;
      END IF;
      */
      -- Cecred
      IF NOT vr_tab_qt_ct.EXISTS(999) THEN
        vr_tab_qt_ct(999).qtsolemp := 0;
        vr_tab_qt_ct(999).qtsolpac := 0;
        vr_tab_qt_ct(999).qtretemp := 0;
        vr_tab_qt_ct(999).qtretpac := 0;
      END IF;

      FOR vr_contador IN vr_nrctares .. 998 LOOP
        /*
        -- Banco do Brasil
        IF NOT vr_tab_qt_bb.EXISTS(vr_contador) THEN -- Se n?o existir, inicializa os campos
          vr_tab_qt_bb(vr_contador).qtsolemp := 0;
          vr_tab_qt_bb(vr_contador).qtsolpac := 0;
          vr_tab_qt_bb(vr_contador).qtretemp := 0;
          vr_tab_qt_bb(vr_contador).qtretpac := 0;
        ELSE -- Se existir, acrescenta os valores nos campos
          vr_tab_qt_bb(999).qtsolemp := vr_tab_qt_bb(999).qtsolemp + vr_tab_qt_bb(vr_contador).qtsolemp;
          vr_tab_qt_bb(999).qtsolpac := vr_tab_qt_bb(999).qtsolpac + vr_tab_qt_bb(vr_contador).qtsolpac;
          vr_tab_qt_bb(999).qtretemp := vr_tab_qt_bb(999).qtretemp + vr_tab_qt_bb(vr_contador).qtretemp;
          vr_tab_qt_bb(999).qtretpac := vr_tab_qt_bb(999).qtretpac + vr_tab_qt_bb(vr_contador).qtretpac;
        END IF;

        -- Bancoob
        IF NOT vr_tab_qt_bc.EXISTS(vr_contador) THEN -- Se n?o existir, inicializa os campos
          vr_tab_qt_bc(vr_contador).qtsolemp := 0;
          vr_tab_qt_bc(vr_contador).qtsolpac := 0;
          vr_tab_qt_bc(vr_contador).qtretemp := 0;
          vr_tab_qt_bc(vr_contador).qtretpac := 0;
        ELSE -- Se existir, acrescenta os valores nos campos
          vr_tab_qt_bc(999).qtsolemp := vr_tab_qt_bc(999).qtsolemp + vr_tab_qt_bc(vr_contador).qtsolemp;
          vr_tab_qt_bc(999).qtsolpac := vr_tab_qt_bc(999).qtsolpac + vr_tab_qt_bc(vr_contador).qtsolpac;
          vr_tab_qt_bc(999).qtretemp := vr_tab_qt_bc(999).qtretemp + vr_tab_qt_bc(vr_contador).qtretemp;
          vr_tab_qt_bc(999).qtretpac := vr_tab_qt_bc(999).qtretpac + vr_tab_qt_bc(vr_contador).qtretpac;
        END IF;
        */
        -- Cecred
        IF NOT vr_tab_qt_ct.EXISTS(vr_contador) THEN -- Se n?o existir, inicializa os campos
          vr_tab_qt_ct(vr_contador).qtsolemp := 0;
          vr_tab_qt_ct(vr_contador).qtsolpac := 0;
          vr_tab_qt_ct(vr_contador).qtretemp := 0;
          vr_tab_qt_ct(vr_contador).qtretpac := 0;
        ELSE -- Se existir, acrescenta os valores nos campos
          vr_tab_qt_ct(999).qtsolemp := vr_tab_qt_ct(999).qtsolemp + vr_tab_qt_ct(vr_contador).qtsolemp;
          vr_tab_qt_ct(999).qtsolpac := vr_tab_qt_ct(999).qtsolpac + vr_tab_qt_ct(vr_contador).qtsolpac;
          vr_tab_qt_ct(999).qtretemp := vr_tab_qt_ct(999).qtretemp + vr_tab_qt_ct(vr_contador).qtretemp;
          vr_tab_qt_ct(999).qtretpac := vr_tab_qt_ct(999).qtretpac + vr_tab_qt_ct(vr_contador).qtretpac;
        END IF;

        IF /*vr_tab_qt_bb(vr_contador).qtsolpac > 0   OR
             vr_tab_qt_bb(vr_contador).qtretpac > 0   OR
             vr_tab_qt_bc(vr_contador).qtsolpac > 0   OR
             vr_tab_qt_bc(vr_contador).qtretpac > 0   OR*/
             vr_tab_qt_ct(vr_contador).qtsolpac > 0   OR
             vr_tab_qt_ct(vr_contador).qtretpac > 0   THEN

          BEGIN
            UPDATE crapger
               SET /*crapger.qtrettal = crapger.qtrettal + vr_tab_qt_bb(vr_contador).qtretpac
                  ,crapger.qtsoltal = crapger.qtsoltal + vr_tab_qt_bb(vr_contador).qtsolpac
                  ,crapger.qtrttlbc = crapger.qtrttlbc + vr_tab_qt_bc(vr_contador).qtretpac
                  ,crapger.qtsltlbc = crapger.qtsltlbc + vr_tab_qt_bc(vr_contador).qtsolpac*/
                   crapger.qtrttlct = crapger.qtrttlct + vr_tab_qt_ct(vr_contador).qtretpac
                  ,crapger.qtsltlct = crapger.qtsltlct + vr_tab_qt_ct(vr_contador).qtsolpac
            WHERE crapger.cdcooper = pr_cdcooper
              AND crapger.dtrefere = vr_dtdiault
              AND crapger.cdempres = 0
              AND crapger.cdagenci = vr_contador;
              
            EXCEPTION
             WHEN OTHERS THEN
              pr_cdcritic := 0;
              pr_dscritic := ' Erro ao atualizar registro na tabela crapger. '||SQLERRM;
              RAISE vr_exc_saida;
            END; 
            --Se nao atualizou
            IF sql%rowcount = 0 THEN
              BEGIN
               INSERT INTO crapger
                          (cdcooper
                          ,dtrefere
                          ,cdempres
                          ,cdagenci
                        /*,qtrettal
                          ,qtsoltal
                          ,qtrttlbc
                          ,qtsltlbc*/
                          ,qtrttlct
                          ,qtsltlct)
                    VALUES (pr_cdcooper
                           ,vr_dtdiault
                           ,0
                           ,vr_contador
                         /*,vr_tab_qt_bb(vr_contador).qtretpac
                           ,vr_tab_qt_bb(vr_contador).qtsolpac
                           ,vr_tab_qt_bc(vr_contador).qtretpac
                           ,vr_tab_qt_bc(vr_contador).qtsolpac*/
                           ,vr_tab_qt_ct(vr_contador).qtretpac
                           ,vr_tab_qt_ct(vr_contador).qtsolpac);
                EXCEPTION
                  WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := ' Erro ao criar registro na tabela crapger. '||SQLERRM;
                   RAISE vr_exc_saida;
                END;
            END IF;
         
        END IF;

        IF  /*vr_tab_qt_bb(vr_contador).qtsolemp > 0   OR
            vr_tab_qt_bb(vr_contador).qtretemp > 0   OR
            vr_tab_qt_bc(vr_contador).qtsolemp > 0   OR
            vr_tab_qt_bc(vr_contador).qtretemp > 0   OR*/
            vr_tab_qt_ct(vr_contador).qtsolemp > 0   OR
            vr_tab_qt_ct(vr_contador).qtretemp > 0   THEN
          BEGIN
            UPDATE crapger
               SET /*crapger.qtrettal = crapger.qtrettal + vr_tab_qt_bb(vr_contador).qtretemp
                  ,crapger.qtsoltal = crapger.qtsoltal + vr_tab_qt_bb(vr_contador).qtsolemp
                  ,crapger.qtrttlbc = crapger.qtrttlbc + vr_tab_qt_bc(vr_contador).qtretemp
                  ,crapger.qtsltlbc = crapger.qtsltlbc + vr_tab_qt_bc(vr_contador).qtsolemp*/
                   crapger.qtrttlct = crapger.qtrttlct + vr_tab_qt_ct(vr_contador).qtretemp
                  ,crapger.qtsltlct = crapger.qtsltlct + vr_tab_qt_ct(vr_contador).qtsolemp
            WHERE crapger.cdcooper = pr_cdcooper
              AND crapger.dtrefere = vr_dtdiault
              AND crapger.cdempres = vr_contador
              AND crapger.cdagenci = 0;
              
            EXCEPTION
              WHEN OTHERS THEN
               pr_cdcritic := 0;
               pr_dscritic := ' Erro ao atualizar registro na tabela crapger. '||SQLERRM;
              RAISE vr_exc_saida;
            END; 

            --Se nao atualizou
            IF sql%rowcount = 0 THEN
              BEGIN
               INSERT INTO crapger
                          (cdcooper
                          ,dtrefere
                          ,cdempres
                          ,cdagenci
                        /*,qtrettal
                          ,qtsoltal
                          ,qtrttlbc
                          ,qtsltlbc*/
                          ,qtrttlct
                          ,qtsltlct)
                    VALUES (pr_cdcooper
                           ,vr_dtdiault
                           ,vr_contador
                           ,0
                         /*,vr_tab_qt_bb(vr_contador).qtretemp
                           ,vr_tab_qt_bb(vr_contador).qtsolemp
                           ,vr_tab_qt_bc(vr_contador).qtretemp
                           ,vr_tab_qt_bc(vr_contador).qtsolemp*/
                           ,vr_tab_qt_ct(vr_contador).qtretemp
                           ,vr_tab_qt_ct(vr_contador).qtsolemp);
              EXCEPTION
                  WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := ' Erro ao criar registro na tabela crapger. '||SQLERRM;
                   RAISE vr_exc_saida;
              END;
            END IF;
        END IF;
                       
      END LOOP; -- Fim do FOR

      BEGIN
       --Tenta atualizar o registro com informacoes gerenciais
       UPDATE crapger
           SET /*crapger.qtrettal = crapger.qtrettal + vr_tab_qt_bb(999).qtretemp
              ,crapger.qtsoltal = crapger.qtsoltal + vr_tab_qt_bb(999).qtsolemp

              ,crapger.qtrttlbc = crapger.qtrttlbc + vr_tab_qt_bc(999).qtretemp
              ,crapger.qtsltlbc = crapger.qtsltlbc + vr_tab_qt_bc(999).qtsolemp*/

              crapger.qtrttlct = crapger.qtrttlct + vr_tab_qt_ct(999).qtretemp
              ,crapger.qtsltlct = crapger.qtsltlct + vr_tab_qt_ct(999).qtsolemp
        WHERE crapger.cdcooper = pr_cdcooper
          AND crapger.dtrefere = vr_dtdiault
          AND crapger.cdempres = 999999
          AND crapger.cdagenci = 0;
          
        EXCEPTION
          WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := ' Erro ao atualizar registro na tabela crapger. '||SQLERRM;
          RAISE vr_exc_saida;
        END;
        --Se nao atualizou
        IF sql%rowcount = 0 THEN
          BEGIN
        -- Cria um novo registro
           INSERT INTO crapger
                      (cdcooper
                      ,dtrefere
                      ,cdempres
                      ,cdagenci
                    /*,qtrettal
                      ,qtsoltal
                      ,qtrttlbc
                      ,qtsltlbc*/
                      ,qtrttlct
                      ,qtsltlct)
                VALUES (pr_cdcooper
                       ,vr_dtdiault
                       ,999999
                       ,0
                     /*,vr_tab_qt_bb(999).qtretemp
                       ,vr_tab_qt_bb(999).qtsolemp
                       ,vr_tab_qt_bc(999).qtretemp
                       ,vr_tab_qt_bc(999).qtsolemp*/
                       ,vr_tab_qt_ct(999).qtretemp
                       ,vr_tab_qt_ct(999).qtsolemp);

          EXCEPTION
            WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := ' Erro ao criar registro na tabela crapger. '||SQLERRM;
             RAISE vr_exc_saida;
          END;
        END IF;

      BEGIN
       --Tenta atualizar o registro com informacoes gerenciais
       UPDATE crapger
           SET /*crapger.qtrettal = crapger.qtrettal + vr_tab_qt_bb(999).qtretemp
              ,crapger.qtsoltal = crapger.qtsoltal + vr_tab_qt_bb(999).qtsolemp

              ,crapger.qtrttlbc = crapger.qtrttlbc + vr_tab_qt_bc(999).qtretemp
              ,crapger.qtsltlbc = crapger.qtsltlbc + vr_tab_qt_bc(999).qtsolemp*/

               crapger.qtrttlct = crapger.qtrttlct + vr_tab_qt_ct(999).qtretemp
              ,crapger.qtsltlct = crapger.qtsltlct + vr_tab_qt_ct(999).qtsolemp
        WHERE crapger.cdcooper = pr_cdcooper
          AND crapger.dtrefere = vr_dtdiault
          AND crapger.cdagenci = 0
          AND crapger.cdempres = 0;
          
        EXCEPTION
          WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := ' Erro ao alterar registro na tabela crapger. '||SQLERRM;
           RAISE vr_exc_saida;
       END;

        --Se nao atualizou
        IF sql%rowcount = 0 THEN
          BEGIN
        -- Cria um novo registro
           INSERT INTO crapger
                      (cdcooper
                      ,dtrefere
                      ,cdagenci
                      ,cdempres
                    /*,qtrettal
                      ,qtsoltal
                      ,qtrttlbc
                      ,qtsltlbc*/
                      ,qtrttlct
                      ,qtsltlct)
                VALUES (pr_cdcooper
                       ,vr_dtdiault
                       ,0
                       ,0
                     /*,vr_tab_qt_bb(999).qtretemp
                       ,vr_tab_qt_bb(999).qtsolemp
                       ,vr_tab_qt_bc(999).qtretemp
                       ,vr_tab_qt_bc(999).qtsolemp*/
                       ,vr_tab_qt_ct(999).qtretemp
                       ,vr_tab_qt_ct(999).qtsolemp);

          EXCEPTION
            WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := ' Erro ao criar registro na tabela crapger. '||SQLERRM;
             RAISE vr_exc_saida;
          END;
        END IF;

      --Finaliza a execuc?o com sucesso
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      COMMIT;

    EXCEPTION

      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descric?o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro

          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2 -- erro tratato
                                    ,
                                     pr_des_log      => to_char(sysdate,
                                                                'hh24:mi:ss') ||
                                                        ' - ' || vr_cdprogra ||
                                                        ' --> ' || vr_dscritic);

        END IF;

        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                  pr_cdprogra => vr_cdprogra,
                                  pr_infimsol => pr_infimsol,
                                  pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo ate ent?o
        COMMIT;

      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descric?o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos codigo e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

      WHEN OTHERS THEN
        -- Efetuar retorno do erro n?o tratado
        pr_cdcritic := 0;
        pr_dscritic := SQLERRM;
        -- Efetuar rollback
        ROLLBACK;

    END pc_crps201;
/
