CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS082
                    (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_cdoperad IN crapdev.cdoperad%TYPE   --> Operador conectado
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

     Programa: pc_crps082 (Antigo Fontes/crps082.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Deborah/Edson
     Data    : Janeiro/94.                         Ultima atualizacao: 12/09/2017

     Dados referentes ao programa:

     Frequencia: Diario (Batch - Background).
     Objetivo  : Atende a solicitacao 4.
                 Emite relatorio com os emprestimos por linhas de credito e
                 finalidade (67 e 68).

     Alteracoes: 24/04/1998 - Tratamento para milenio e troca para V8 (Margarete).

                 05/01/2001 - Alterar o nome dos formularios de impressao para
                              132dm. (Eduardo).

                 24/01/2006 - Desconsiderar contratos em prejuizo (Evandro).

                 25/06/2008 - Incluir 'Vlr Atraso' e '%Atraso' crrl068(Guilherme).

                 29/12/2008 - Inclusao taxa do mes(Mirtes)

                 15/05/2013 - Conversão Progress >> Oracle PLSQL (Marcos)

                 09/08/2013 - Troca da busca do mes por extenso com to_char para
                              utilizarmos o vetor gene0001.vr_vet_nmmesano (Marcos-Supero)

                 30/08/2013 - Incluí join com a tabela crawepr no cursor cr_crapepr para
                              evitar uma nova abertura de cursor para cada empréstimo lido. (Daniel - Supero)

                 10/10/2013 - Ajuste para correto funcionamento da cadeia (Gabriel)

                 29/10/2013 - Remoção da cooperativa 1 que estava fixa no código (Marcos-Supero)

                 22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                              ser acionada em caso de saída para continuação da cadeia,
                              e não em caso de problemas na execução (Marcos-Supero)

                 15/01/2014 - Correção no loop de agencias, executante teste de quantidade
                              antes do loop para então evitar numeric or value error
                              (Marcos-Supero)

             	   14/04/2014 - Alterado posição dos campos de linha de crédito e finalidade
                            - Adicionado totalizador por finalidade e linha de crédito 
                              (Reinert).
															
                 15/05/2014 - Aumentado o format do campo cdlcremp de 3 ára 4
                              posicoes (Tiago/Gielow SD137074).     
                              
                 02/03/2016 - Removido coluna "% atraso" do relatório crrl068 conforme
                              solicitado no chamado 400346 (Kelvin).
                              
                 12/09/2017 - #749442 Alterado o tipo da variável e parametro qtprepag das
                              rotinas empr0001.pc_leitura_lem e pc_leitura_lem_car para 
                              crapepr.qtprecal para suportar a quantidade de parcelas (Carlos)
  ............................................................................. */
    DECLARE

      ------------------------------- CURSORES ---------------------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nrtelura
              ,cop.dsdircop
              ,cop.cdbcoctl
              ,cop.cdagectl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      -- Busca o cadastro de linhas de crédito
      CURSOR cr_craplcr IS
        SELECT lcr.cdlcremp,
               lcr.dslcremp,
               lcr.txdiaria,
               lcr.txmensal
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper;
      -- Leitura dos empréstimos ativos
      CURSOR cr_crapepr IS
        select ass.cdagenci,
               epr.cdlcremp,
               epr.cdfinemp,
               epr.nrdconta,
               epr.nrctremp,
               ass.inpessoa,
               epr.dtmvtolt,
               epr.inprejuz,
               epr.vlemprst,
               epr.vlsdeved,
               epr.inliquid,
               epr.txjuremp,
               epr.vljuracu,
               epr.qtprepag,
               epr.qtprecal,
               epr.qtpreemp,
               epr.dtdpagto,
               decode(nvl(wepr.nrdconta, 0),
                      0, epr.dtdpagto,
                      wepr.dtdpagto) dtdpagto_cpl,
               epr.flgpagto,
               epr.qtmesdec,
               epr.vlpreemp,
               epr.dtultpag
          from crawepr wepr,
               crapass ass,
               crapepr epr
         where epr.cdcooper = pr_cdcooper
           and ass.cdcooper = epr.cdcooper
           and ass.nrdconta = epr.nrdconta
           and wepr.cdcooper (+) = epr.cdcooper
           and wepr.nrdconta (+) = epr.nrdconta
           and wepr.nrctremp (+) = epr.nrctremp;
      -- Verificar se existe aviso de débito em conta corrente não processado
      CURSOR cr_crapavs(pr_nrdconta IN crapavs.nrdconta%TYPE) IS
        SELECT 'S'
          FROM crapavs
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdhistor = 108
           AND dtrefere = rw_crapdat.dtultdma --> Ultimo dia mes anterior
           AND tpdaviso = 1
           AND flgproce = 0; --> Não processado
      vr_flghaavs CHAR(1);
      -- Buscar nome da agência
      CURSOR cr_crapage(pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT nmresage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;
      vr_nmresage crapage.nmresage%TYPE;
      -- Busca das finalidades de empréstimo
      CURSOR cr_crapfin IS
        SELECT cdfinemp
              ,dsfinemp
          FROM crapfin
         WHERE cdcooper = pr_cdcooper;

      ------------------- TIPOS E TABELAS DE MEMÓRIA -----------------------

      -- Definição de tipo para armazenar os dados de linhas de credito sendo a
      -- chave o código da linha de crédito e armazenaremos algumas informações
      TYPE typ_reg_craplcr IS
        RECORD(txdiaria craplcr.txdiaria%TYPE
              ,txmensal craplcr.txmensal%TYPE
              ,dslcremp craplcr.dslcremp%TYPE);
      TYPE typ_tab_craplcr IS
        TABLE OF typ_reg_craplcr
          INDEX BY PLS_INTEGER;
      vr_tab_craplcr typ_tab_craplcr;

      -- Definição de tipo para armazenar os dados de finalidade de emprestimo sendo a
      -- chave o código da finalidade e armazenaremos algumas informações
      TYPE typ_tab_crapfin IS
        TABLE OF crapfin.dsfinemp%TYPE
          INDEX BY PLS_INTEGER;
      vr_tab_crapfin typ_tab_crapfin;

      -- Definição de tabela para armazenar contas de associados
      TYPE typ_tab_associ IS
        TABLE OF NUMBER
          INDEX BY PLS_INTEGER;


      -- Definição de tipo para armazenar as informações dos empréstimos em processo
      -- Chave composta por VARCHAR2(11), sendo:
      --                    1 IndiceRelatorio
      --                    3 Agencia
      --                    3 LinhaCredito
      --                    3 FinalidadeEmprestimo
      TYPE typ_reg_empres IS
        RECORD(inrelato NUMBER(1)
              ,cdagenci crapass.cdagenci%TYPE
              ,cdlcremp crapepr.cdlcremp%TYPE
              ,cdfinemp crapepr.cdfinemp%TYPE
              ,tbassoci typ_tab_associ --> Temp table para armazenar as contas ligadas ao registro
              ,qtctremp NUMBER
              ,vlempfis crapepr.vlsdeved%TYPE
              ,vlempjur crapepr.vlsdeved%TYPE
              ,vlratras NUMBER
              );
      TYPE typ_tab_empres IS
        TABLE OF typ_reg_empres
          INDEX BY VARCHAR2(11);
      vr_tab_empres typ_tab_empres;
      -- Chave para a temp-table
      vr_des_chave_empres VARCHAR2(11);

      -- Definição de tipo para armazenar o resumo geral por agência
      -- Chave composta pelo código da agência
      TYPE typ_reg_resumo IS
        RECORD(nmresage crapage.nmresage%TYPE
              ,qtctremp NUMBER
              ,vlsdeved crapepr.vlsdeved%TYPE);
      TYPE typ_tab_resumo IS
        TABLE OF typ_reg_resumo
          INDEX BY PLS_INTEGER;
      vr_tab_resumo typ_tab_resumo;

      ----------------------------- VARIAVEIS ------------------------------

      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros
      vr_exc_saida   exception;
      vr_exc_fimprg  exception;

      -- Variaveis do processo --
      vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab
      vr_inusatab     BOOLEAN;                --> Indicador S/N de utilização de tabela de juros
      vr_dtinipag     DATE;                   --> Data de início de pagamento do empréstimo
      vr_qtmesdec     crapepr.qtmesdec%TYPE;  --> Qtde de meses decorridos do empréstimo
      vr_vlratras     NUMBER;                 --> Valor do atraso

      -- Variaveis para o relatório --
      vr_rel_nmmesref VARCHAR2(20);

      -- Variáveis para passagem a rotina pc_calcula_lelem
      vr_diapagto INTEGER;
      vr_qtprepag     crapepr.qtprecal%TYPE;
      vr_qtprecal     crapepr.qtprecal%TYPE;
      vr_qtprecal_lem crapepr.qtprecal%TYPE;
      vr_vlprepag     craplem.vllanmto%TYPE;
      vr_vljuracu     crapepr.vljuracu%TYPE;
      vr_vljurmes     crapepr.vljurmes%TYPE;
      vr_vlsdeved     crapepr.vlsdeved%TYPE;
      vr_dtultpag     crapepr.dtultpag%TYPE;
      vr_txdjuros     crapepr.txjuremp%TYPE;

      -- Variaveis para os XMLs e relatórios
      vr_clobxml_1  CLOB;    --> crrl227
      vr_clobxml_2  CLOB;    --> crrl354
      vr_nom_direto VARCHAR2(200);
      vr_dsfinemp   crapfin.dsfinemp%TYPE; --> Descrição da finalidade
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(2000);
      vr_flgpares   BOOLEAN := FALSE;      --> Flag que indica quando for PA 999
      vr_chave_resumo vr_des_chave_empres%TYPE;

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_clobxml  IN OUT NOCOPY CLOB
                              ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobxml, length(pr_desdados),pr_desdados);
      END;


      -- SubRotina para adicionar os dados no vetor para o relatório
      PROCEDURE pc_adiciona_emprest(pr_inrelato IN NUMBER
                                   ,pr_cdagenci IN crapass.cdagenci%TYPE
                                   ,pr_cdlcremp IN crapepr.cdlcremp%TYPE
                                   ,pr_cdfinemp IN crapepr.cdfinemp%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_inpessoa IN crapass.inpessoa%TYPE
                                   ,pr_vlsdeved IN crapepr.vlsdeved%TYPE
                                   ,pr_vlratras IN NUMBER) IS
      BEGIN
        -- Montar chave composta por 11 caracteres, sendo:
        --                    1 IndiceRelatorio
        --                    3 Agencia
        --                    3 LinhaCredito
        --                    3 FinalidadeEmprestimo
        vr_des_chave_empres := pr_inrelato
                            || lpad(pr_cdagenci,3,'0')
                            || lpad(pr_cdfinemp,3,'0')
                            || lpad(pr_cdlcremp,4,'0');
                            
        -- Verificar se a chave ainda não foi criada no vetor
        IF NOT vr_tab_empres.EXISTS(vr_des_chave_empres) THEN
          -- Criar o registro no vetor
          vr_tab_empres(vr_des_chave_empres).inrelato := pr_inrelato;
          vr_tab_empres(vr_des_chave_empres).cdagenci := pr_cdagenci;
          vr_tab_empres(vr_des_chave_empres).cdfinemp := pr_cdfinemp;
          vr_tab_empres(vr_des_chave_empres).cdlcremp := pr_cdlcremp;
          vr_tab_empres(vr_des_chave_empres).qtctremp := 0;
          vr_tab_empres(vr_des_chave_empres).vlempfis := 0;
          vr_tab_empres(vr_des_chave_empres).vlempjur := 0;
          vr_tab_empres(vr_des_chave_empres).vlratras := 0;
        END IF;
    -- Gravar campo de valor emprestimo cfme tipo de pessoa
        IF pr_inpessoa = 1 THEN
          -- Fisica
          vr_tab_empres(vr_des_chave_empres).vlempfis := vr_tab_empres(vr_des_chave_empres).vlempfis + round(nvl(pr_vlsdeved,0),2);
        ELSE
          -- Juridica
          vr_tab_empres(vr_des_chave_empres).vlempjur := vr_tab_empres(vr_des_chave_empres).vlempjur + round(nvl(pr_vlsdeved,0),2);
        END IF;        -- Adicionar atraso
        vr_tab_empres(vr_des_chave_empres).vlratras := vr_tab_empres(vr_des_chave_empres).vlratras + round(nvl(pr_vlratras,0),2);
        -- Incrementar contador de contratos
        vr_tab_empres(vr_des_chave_empres).qtctremp := vr_tab_empres(vr_des_chave_empres).qtctremp + 1;
        -- Adiciona a conta na temp-table de contas do registro
        -- OBs. Como a conta é a chave, se a mesma existir, não é criado
        --      um novo registro, e assim podemos facilidade contar quantas
        --      contas estão vinculadas ao TpRelatorio, Agencia, Linha Credito e Finalidade
        vr_tab_empres(vr_des_chave_empres).tbassoci(pr_nrdconta) := pr_nrdconta;
      END;
    BEGIN
      -- Código do programa
      vr_cdprogra := 'CRPS082';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS082'
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


      -- Busca do cadastro de linhas de crédito de empréstimo
      FOR rw_craplcr IN cr_craplcr LOOP
        -- Por fim guardamos tbm a taxa, a descrição e o tipo de operação
        vr_tab_craplcr(rw_craplcr.cdlcremp).txdiaria := rw_craplcr.txdiaria;
        vr_tab_craplcr(rw_craplcr.cdlcremp).txmensal := rw_craplcr.txmensal;
        vr_tab_craplcr(rw_craplcr.cdlcremp).dslcremp := rw_craplcr.dslcremp;
      END LOOP;
      -- BUsca das finalidades de empréstimo
      FOR rw_crapfin IN cr_crapfin LOOP
        -- Armazena a descrição na tabela
        vr_tab_crapfin(rw_crapfin.cdfinemp) := rw_crapfin.dsfinemp;
      END LOOP;
      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Se a primeira posição do campo
        -- dstextab for diferente de zero
        IF SUBSTR(vr_dstextab,1,1) != '0' THEN
          -- É porque existe tabela parametrizada
          vr_inusatab := TRUE;
        ELSE
          -- Não existe
          vr_inusatab := FALSE;
        END IF;
      ELSE
        -- Não existe
        vr_inusatab := FALSE;
      END IF;
      -- Montar o mes por extenso do processo
      vr_rel_nmmesref := gene0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt,'MM'))||'/'||to_char(rw_crapdat.dtmvtolt,'YYYY');
      -- Leitura inicial dos empréstimos
      FOR rw_crapepr IN cr_crapepr LOOP
        -- Se a parcela vence no mês corrente
        IF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapepr.dtmvtolt,'mm') THEN
          -- Desconsiderar prejuizo
          IF rw_crapepr.inprejuz > 0 THEN
            -- Ir ao próximo
            CONTINUE;
          END IF;
          -- Enviamos o registro do tipo 1 para a tabela de memória
          pc_adiciona_emprest(pr_inrelato => 1
                             ,pr_cdagenci => rw_crapepr.cdagenci
                             ,pr_cdlcremp => rw_crapepr.cdlcremp
                             ,pr_cdfinemp => rw_crapepr.cdfinemp
                             ,pr_nrdconta => rw_crapepr.nrdconta
                             ,pr_inpessoa => rw_crapepr.inpessoa
                             ,pr_vlsdeved => rw_crapepr.vlemprst
                             ,pr_vlratras => 0);
          -- Enviamos também o registro totalizador
          pc_adiciona_emprest(pr_inrelato => 1
                             ,pr_cdagenci => 999 -- Fixo Resumo
                             ,pr_cdlcremp => rw_crapepr.cdlcremp
                             ,pr_cdfinemp => rw_crapepr.cdfinemp
                             ,pr_nrdconta => rw_crapepr.nrdconta
                             ,pr_inpessoa => rw_crapepr.inpessoa
                             ,pr_vlsdeved => rw_crapepr.vlemprst
                             ,pr_vlratras => 0);
        END IF;
        -- Se o saldo devedor estiver zerado
        IF rw_crapepr.vlsdeved = 0 THEN
          -- Ignoramos o restante abaixo
          CONTINUE;
        END IF;

        -- Povoar variáveis para o calculo com os valores do empréstimo
        vr_diapagto := 0;
        vr_qtprepag := NVL(rw_crapepr.qtprepag,0);
        vr_vlprepag := 0;
        vr_vlsdeved := NVL(rw_crapepr.vlsdeved,0);
        vr_vljuracu := NVL(rw_crapepr.vljuracu,0);
        vr_vljurmes := 0;
        vr_dtultpag := rw_crapepr.dtultpag;
        -- Se está setado para utilizarmos a tabela de juros e o empréstimo estiver em aberto
        IF vr_inusatab AND rw_crapepr.inliquid = 0 THEN
          -- Iremos buscar a tabela de juros nas linhas de crédito
          vr_txdjuros := vr_tab_craplcr(rw_crapepr.cdlcremp).txdiaria;
        ELSE
          -- Usar taxa cadastrada no empréstimo
          vr_txdjuros := rw_crapepr.txjuremp;
        END IF;
        -- Se o empréstimo não estiver ativo
        IF rw_crapepr.inliquid = 0 THEN
          -- Utilizar a quantidade de parcelas calculadas do empréstimo
          vr_qtprecal := rw_crapepr.qtprecal;
        ELSE
          -- Utilizar a quantidade de parcelas total do empréstimo
          vr_qtprecal := rw_crapepr.qtpreemp;
        END IF;
        -- Chamar rotina de cálculo externa
        empr0001.pc_leitura_lem(pr_cdcooper    => pr_cdcooper
                               ,pr_cdprogra    => vr_cdprogra
                               ,pr_rw_crapdat  => rw_crapdat
                               ,pr_nrdconta    => rw_crapepr.nrdconta
                               ,pr_nrctremp    => rw_crapepr.nrctremp
                               ,pr_dtcalcul    => NULL
                               ,pr_diapagto    => vr_diapagto
                               ,pr_txdjuros    => vr_txdjuros
                               ,pr_qtprepag    => vr_qtprepag
                               ,pr_qtprecal    => vr_qtprecal_lem
                               ,pr_vlprepag    => vr_vlprepag
                               ,pr_vljuracu    => vr_vljuracu
                               ,pr_vljurmes    => vr_vljurmes
                               ,pr_vlsdeved    => vr_vlsdeved
                               ,pr_dtultpag    => vr_dtultpag
                               ,pr_cdcritic    => vr_cdcritic
                               ,pr_des_erro    => vr_dscritic);
        -- Se a rotina retornou com erro
        IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_saida;
        END IF;
        -- Data de pagto.
        -- Se existe cadastro complementar (crawepr), utiliza esta data. Caso contrário, utiliza a crapepr.
        -- Tratamento feito no cursor para ter ganho de performance.
        vr_dtinipag := rw_crapepr.dtdpagto_cpl;
        -- Para empréstimos de debito em conta
        IF rw_crapepr.flgpagto = 0 THEN
          -- Se a parcela vence no mês corrente
          IF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapepr.dtdpagto,'mm') THEN
            -- Se ainda não foi pago
            IF rw_crapepr.dtdpagto <= rw_crapdat.dtmvtolt THEN
              -- Incrementar a quantidade de parcelas
              vr_qtmesdec := rw_crapepr.qtmesdec + 1;
            ELSE
              -- Consideramos a quantidade já calculadao
              vr_qtmesdec := rw_crapepr.qtmesdec;
            END IF;
          -- Se foi paga no mês corrente
          ELSIF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapepr.dtmvtolt,'mm') THEN
            -- Se for um contrato do mês
            IF to_char(vr_dtinipag,'mm') = to_char(rw_crapdat.dtmvtolt,'mm') THEN
              -- Devia ter pago a primeira no mes do contrato
              vr_qtmesdec := rw_crapepr.qtmesdec + 1;
            ELSE
              -- Paga a primeira somente no mes seguinte
              vr_qtmesdec := rw_crapepr.qtmesdec;
            END IF;
          ELSE
            -- Se a parcela vai vencer OU foi paga no mês corrEnte
            IF rw_crapepr.dtdpagto > rw_crapdat.dtmvtolt OR (rw_crapepr.dtdpagto < rw_crapdat.dtmvtolt AND to_char(rw_crapepr.dtdpagto,'dd') <= to_char(rw_crapdat.dtmvtolt,'dd')) THEN
              -- Incrementar a quantidade de parcelas
              vr_qtmesdec := rw_crapepr.qtmesdec + 1;
            ELSE
              -- Consideramos a quantidade já calculadao
              vr_qtmesdec := rw_crapepr.qtmesdec;
            END IF;
          END IF;
        ELSE --> Para desconto em folha
          -- Para contratos do Mes
          IF trunc(rw_crapepr.dtmvtolt,'mm') = trunc(rw_crapdat.dtmvtolt,'mm') THEN
            -- Ainda nao atualizou o qtmesdec
            vr_qtmesdec := rw_crapepr.qtmesdec;
          ELSE
            -- Verificar se existe aviso de débito em conta corrente não processado
            vr_flghaavs := 'N';
            OPEN cr_crapavs(pr_nrdconta => rw_crapepr.nrdconta);
            FETCH cr_crapavs
             INTO vr_flghaavs;
            CLOSE cr_crapavs;
            -- Se houve
            IF vr_flghaavs = 'S' THEN
              -- Utilizar a quantidade já calculada
              vr_qtmesdec := rw_crapepr.qtmesdec;
            ELSE
              -- Adicionar 1 mês a quantidade calculada
              vr_qtmesdec := rw_crapepr.qtmesdec + 1;
            END IF;
          END IF;
        END IF;
        -- Garantir que a quantidade decorrida não seja negativa
        IF vr_qtmesdec < 0 THEN
          vr_qtmesdec := 0;
        END IF;
        -- Se o empréstimo ainda estiver ativo
        IF rw_crapepr.inliquid = 0 THEN
          -- Adicionar a quantidade de parcelas calculadas, o valor calculado
          -- na include lelem
          vr_qtprecal := vr_qtprecal + vr_qtprecal_lem;
        END IF;
        -- Se a quantidade calculada for superior a quantidade de meses decorridos
        -- E a data do pagamento já venceu
        -- E for um empréstimo de débito em conta
        IF rw_crapepr.qtprecal > rw_crapepr.qtmesdec
        AND rw_crapepr.dtdpagto <= rw_crapdat.dtmvtolt
        AND rw_crapepr.flgpagto = 0 THEN
          -- Calcular o atraso com base no valor do empréstimo - o que foi pago
          vr_vlratras := rw_crapepr.vlpreemp - vr_vlprepag;
          -- Garantir que o valor não fique negativo
          IF vr_vlratras < 0 THEN
            vr_vlratras := 0;
          END IF;
        ELSE
          -- Se a diferença de meses decorridos e qtde calculada
          -- for superior a zero
          IF (vr_qtmesdec - vr_qtprecal) > 0 THEN
            -- Valor do atraso é essa diferença * valor da parcela
            vr_vlratras := round((vr_qtmesdec - vr_qtprecal) * rw_crapepr.vlpreemp,2);
          ELSE
            -- Não há atraso
            vr_vlratras := 0;
          END IF;
        END IF;
        -- Se a Qtde de meses decorridos for superior a qtde de parcelas do empréstimo
        -- OU Se o valor do atraso for superior ao devedor
        IF vr_qtmesdec > rw_crapepr.qtpreemp OR vr_vlratras > vr_vlsdeved THEN
          -- Considerar como atraso o saldo devedor calculado
          vr_vlratras := ROUND(vr_vlsdeved,2);
        END IF;
        -- Garantir que o valor do atraso não seja negativo
        IF vr_vlratras < 0 THEN
          vr_vlratras := 0;
        END IF;

        -- Criar o registro tipo 2 para o relatório
        pc_adiciona_emprest(pr_inrelato => 2
                           ,pr_cdagenci => rw_crapepr.cdagenci
                           ,pr_cdlcremp => rw_crapepr.cdlcremp
                           ,pr_cdfinemp => rw_crapepr.cdfinemp
                           ,pr_nrdconta => rw_crapepr.nrdconta
                           ,pr_inpessoa => rw_crapepr.inpessoa
                           ,pr_vlsdeved => rw_crapepr.vlsdeved
                           ,pr_vlratras => vr_vlratras);
        -- Enviamos também o registro totalizador por finalidade
        pc_adiciona_emprest(pr_inrelato => 2
                           ,pr_cdagenci => 999 -- Fixo
                           ,pr_cdlcremp => rw_crapepr.cdlcremp
                           ,pr_cdfinemp => rw_crapepr.cdfinemp
                           ,pr_nrdconta => rw_crapepr.nrdconta
                           ,pr_inpessoa => rw_crapepr.inpessoa
                           ,pr_vlsdeved => rw_crapepr.vlsdeved
                           ,pr_vlratras => vr_vlratras);
        -- Enviamos também o registro totalizador por linha de crédito
        pc_adiciona_emprest(pr_inrelato => 2
                           ,pr_cdagenci => 999 -- Fixo
                           ,pr_cdlcremp => rw_crapepr.cdlcremp
                           ,pr_cdfinemp => '000'
                           ,pr_nrdconta => rw_crapepr.nrdconta
                           ,pr_inpessoa => rw_crapepr.inpessoa
                           ,pr_vlsdeved => rw_crapepr.vlsdeved
                           ,pr_vlratras => vr_vlratras);                   
                                   
      END LOOP; --> Fim Leitura empréstimos
      -- Se houve inserção na tabela temporária
      IF vr_tab_empres.COUNT > 0 THEN
        -- Ao final da preparação das informações sob a temp-table, iremos criar
        -- os clobs para armazenar as informações XML dos relatórios.
        -- Obs: Já enviamos o mes de referência como um atributo da raiz de dados
        -- Para o crrl067.lst
        dbms_lob.createtemporary(vr_clobxml_1, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobxml_1, dbms_lob.lob_readwrite);
        pc_escreve_xml(vr_clobxml_1,'<?xml version="1.0" encoding="utf-8"?><raiz nmmesref="'||vr_rel_nmmesref||'">');
        -- Para o crr068.lst
        dbms_lob.createtemporary(vr_clobxml_2, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobxml_2, dbms_lob.lob_readwrite);
        pc_escreve_xml(vr_clobxml_2,'<?xml version="1.0" encoding="utf-8"?><raiz nmmesref="'||vr_rel_nmmesref||'">');
        -- Enfim, buscamos o primeiro registro do vetor de dados
        vr_des_chave_empres := vr_tab_empres.FIRST;
        LOOP
          -- Sair quando não existirem mais registros a processar
          EXIT WHEN vr_des_chave_empres IS NULL;
          -- Se mudou o PAC ou é o primeiro registro
          IF vr_des_chave_empres = vr_tab_empres.FIRST OR vr_tab_empres(vr_tab_empres.PRIOR(vr_des_chave_empres)).cdagenci <> vr_tab_empres(vr_des_chave_empres).cdagenci THEN
            -- Buscar nome da agência caso não seja a 999
            IF vr_tab_empres(vr_des_chave_empres).cdagenci <> 999 THEN
              OPEN cr_crapage(vr_tab_empres(vr_des_chave_empres).cdagenci);
              FETCH cr_crapage
               INTO vr_nmresage;
              CLOSE cr_crapage;
              -- Criar o registro na temp table de resumo somente para relatório tipo 1 (067)
              IF vr_tab_empres(vr_des_chave_empres).inrelato = 1 THEN
                vr_tab_resumo(vr_tab_empres(vr_des_chave_empres).cdagenci).nmresage := vr_nmresage;
                vr_tab_resumo(vr_tab_empres(vr_des_chave_empres).cdagenci).qtctremp := 0;
                vr_tab_resumo(vr_tab_empres(vr_des_chave_empres).cdagenci).vlsdeved := 0;
              END IF;
            ELSE
              -- Fixo Resumo
              vr_nmresage := 'RESUMO';
            END IF;
            -- Abrir a tag de agencia nos dois arquivos, desde que o registro seja do tipo correspondente
            -- Para o relatório do tipo 1 - 067
            IF vr_tab_empres(vr_des_chave_empres).inrelato = 1 THEN
              pc_escreve_xml(vr_clobxml_1,'<agencia cdagenci="'||vr_tab_empres(vr_des_chave_empres).cdagenci||'" nmagenci="'||vr_nmresage||'">');
            ELSE
              pc_escreve_xml(vr_clobxml_2,'<agencia cdagenci="'||vr_tab_empres(vr_des_chave_empres).cdagenci||'" nmagenci="'||vr_nmresage||'">');

              IF vr_tab_empres(vr_des_chave_empres).cdagenci = 999 AND vr_tab_empres(vr_des_chave_empres).cdfinemp = 0 THEN 
                 vr_chave_resumo := vr_des_chave_empres;
                 vr_flgpares := TRUE;
            END IF;
            END IF;
          END IF;
          -- Para o relatório do tipo 1 - 067
          IF vr_tab_empres(vr_des_chave_empres).inrelato = 1 THEN
            -- Para o primeiro registro de finalidade ou quando houve mudança nas quebras anteriores
            IF vr_des_chave_empres = vr_tab_empres.FIRST
            OR vr_tab_empres(vr_tab_empres.PRIOR(vr_des_chave_empres)).cdfinemp <> vr_tab_empres(vr_des_chave_empres).cdfinemp
            OR vr_tab_empres(vr_tab_empres.PRIOR(vr_des_chave_empres)).cdagenci <> vr_tab_empres(vr_des_chave_empres).cdagenci THEN
            -- Se existe a finalidade de empréstimo
            IF vr_tab_crapfin.EXISTS(vr_tab_empres(vr_des_chave_empres).cdfinemp) THEN
              -- Usá-la
              vr_dsfinemp := substr(vr_tab_crapfin(vr_tab_empres(vr_des_chave_empres).cdfinemp),1,25);
            ELSE
              -- Não cadastrada
              vr_dsfinemp := 'NAO CADASTRADA!';
            END IF;
              -- Enviar a tag de finalidade
              pc_escreve_xml(vr_clobxml_1,'<finalida cdfinemp="'||LPAD(vr_tab_empres(vr_des_chave_empres).cdfinemp,3,'0')||'" dsfinemp="'||vr_dsfinemp||'">');
            END IF;            
            -- Enfim enviar o registro de detalhe, que envolve as informações por linha de crédito
            pc_escreve_xml(vr_clobxml_1,'<linhacred>'
                                      ||  '<cdlcremp>'||LPAD(vr_tab_empres(vr_des_chave_empres).cdlcremp,4,'0')||'</cdlcremp>'
                                      ||  '<dslcremp>'||substr(vr_tab_craplcr(vr_tab_empres(vr_des_chave_empres).cdlcremp).dslcremp,1,25)||'</dslcremp>'
                                      ||  '<qtassoci>'||to_char(vr_tab_empres(vr_des_chave_empres).tbassoci.COUNT,'fm999g999g999g990')||'</qtassoci>'
                                      ||  '<qtctremp>'||to_char(vr_tab_empres(vr_des_chave_empres).qtctremp,'fm999g999g999g990')||'</qtctremp>'
                                      ||  '<vlslddev>'||to_char(vr_tab_empres(vr_des_chave_empres).vlempfis+vr_tab_empres(vr_des_chave_empres).vlempjur,'fm999g999g999g990d00')||'</vlslddev>'
                                      ||'</linhacred>');
            -- Prever o ultimo registro de finalidade (ou das quebras posteriores)
            IF vr_des_chave_empres = vr_tab_empres.LAST
            OR vr_tab_empres(vr_tab_empres.NEXT(vr_des_chave_empres)).cdfinemp <> vr_tab_empres(vr_des_chave_empres).cdfinemp
            OR vr_tab_empres(vr_tab_empres.NEXT(vr_des_chave_empres)).cdagenci <> vr_tab_empres(vr_des_chave_empres).cdagenci THEN
              -- Enviar a tag de finalidade
              pc_escreve_xml(vr_clobxml_1,'</finalida>');
            END IF;
            -- Caso não seja a agencia de resumo 999
            IF vr_tab_empres(vr_des_chave_empres).cdagenci <> 999 THEN
              -- Acumular as informações na temp table de resumo
              vr_tab_resumo(vr_tab_empres(vr_des_chave_empres).cdagenci).qtctremp := vr_tab_resumo(vr_tab_empres(vr_des_chave_empres).cdagenci).qtctremp + vr_tab_empres(vr_des_chave_empres).qtctremp;
              vr_tab_resumo(vr_tab_empres(vr_des_chave_empres).cdagenci).vlsdeved := vr_tab_resumo(vr_tab_empres(vr_des_chave_empres).cdagenci).vlsdeved + vr_tab_empres(vr_des_chave_empres).vlempfis+vr_tab_empres(vr_des_chave_empres).vlempjur;
            END IF;
          ELSE -- Para o 2 - 068
            
            -- Não imprimir resumo de linha de crédito
            IF vr_tab_empres(vr_des_chave_empres).cdagenci = 999 AND vr_tab_empres(vr_des_chave_empres).cdfinemp = 0 THEN
               vr_des_chave_empres := vr_tab_empres.NEXT(vr_des_chave_empres);
               CONTINUE;
            END IF;
          
            -- Se mudar o tipo de operação ou o PA ou a finalidade 
            IF vr_des_chave_empres = vr_tab_empres.FIRST
            OR vr_tab_empres(vr_tab_empres.PRIOR(vr_des_chave_empres)).cdfinemp <> vr_tab_empres(vr_des_chave_empres).cdfinemp
            OR vr_tab_empres(vr_tab_empres.PRIOR(vr_des_chave_empres)).cdagenci <> vr_tab_empres(vr_des_chave_empres).cdagenci THEN
              
              -- Se existe a finalidade de empréstimo
              IF vr_tab_crapfin.EXISTS(vr_tab_empres(vr_des_chave_empres).cdfinemp) THEN
                -- Usá-la
                vr_dsfinemp := substr(vr_tab_crapfin(vr_tab_empres(vr_des_chave_empres).cdfinemp),1,25);
              ELSE
                -- Não cadastrada
                vr_dsfinemp := 'NAO CADASTRADA!';
              END IF;
            
              -- Enviar a tag de tipo de operação somente para o relatório 068
              pc_escreve_xml(vr_clobxml_2,'<operaca>');
              pc_escreve_xml(vr_clobxml_2,'<finalida cdfinemp="'||LPAD(vr_tab_empres(vr_des_chave_empres).cdfinemp,3,'0')||'" dsfinemp="'||vr_dsfinemp||'">');
           END IF;
            
            -- Enfim enviar o registro de detalhe, que envolve as informações por linha de credito e finalidade 000
            pc_escreve_xml(vr_clobxml_2,'<linhcred>'
                                      ||  '<cdlcremp>'||LPAD(vr_tab_empres(vr_des_chave_empres).cdlcremp,4,0)||'</cdlcremp>'
                                      ||  '<dslcremp>'||substr(vr_tab_craplcr(vr_tab_empres(vr_des_chave_empres).cdlcremp).dslcremp,1,25)||'</dslcremp>'
                                      ||  '<qtassoci>'||to_char(vr_tab_empres(vr_des_chave_empres).tbassoci.COUNT,'fm999g999g999g990')||'</qtassoci>'
                                      ||  '<qtctremp>'||to_char(vr_tab_empres(vr_des_chave_empres).qtctremp,'fm999g999g999g990')||'</qtctremp>'
                                      ||  '<txmensal>'||to_char(vr_tab_craplcr(vr_tab_empres(vr_des_chave_empres).cdlcremp).txmensal,'fm90d000000')||'</txmensal>'
                                      ||  '<vlempfis>'||to_char(vr_tab_empres(vr_des_chave_empres).vlempfis,'fm999g999g999g990d00')||'</vlempfis>'
                                      ||  '<vlempjur>'||to_char(vr_tab_empres(vr_des_chave_empres).vlempjur,'fm999g999g999g990d00')||'</vlempjur>'
                                      ||  '<vlslddev>'||(vr_tab_empres(vr_des_chave_empres).vlempfis+vr_tab_empres(vr_des_chave_empres).vlempjur)||'</vlslddev>'
                                      ||  '<vlratras>'||vr_tab_empres(vr_des_chave_empres).vlratras||'</vlratras>'
                                      ||'</linhcred>');
            -- Se for ultimo registro do mesmo tipo de operação ou da agencia
            IF vr_des_chave_empres = vr_tab_empres.LAST
            OR vr_tab_empres(vr_tab_empres.NEXT(vr_des_chave_empres)).cdfinemp <> vr_tab_empres(vr_des_chave_empres).cdfinemp
            OR vr_tab_empres(vr_tab_empres.NEXT(vr_des_chave_empres)).cdagenci <> vr_tab_empres(vr_des_chave_empres).cdagenci THEN
              -- Fechar a tag de finalidade
              pc_escreve_xml(vr_clobxml_2,'</finalida>');
              -- Fechar a tag de tipo de operação somente para o relatório 068
              pc_escreve_xml(vr_clobxml_2,'</operaca>');
            END IF;
          END IF;
          -- Se for o ultimo registro da tabela ou ultimo da agencia atual
          IF vr_des_chave_empres = vr_tab_empres.LAST OR vr_tab_empres(vr_tab_empres.NEXT(vr_des_chave_empres)).cdagenci <> vr_tab_empres(vr_des_chave_empres).cdagenci THEN
            -- Fechar a tag de agencia nos dois arquivos, desde que o registro seja do tipo correspondente
            -- Para o relatório do tipo 1 - 067
            IF vr_tab_empres(vr_des_chave_empres).inrelato = 1 THEN
              pc_escreve_xml(vr_clobxml_1,'</agencia>');
            ELSE
              pc_escreve_xml(vr_clobxml_2,'</agencia>');
            END IF;
          END IF;
          -- Buscar o próximo registro do registro correten
          vr_des_chave_empres := vr_tab_empres.NEXT(vr_des_chave_empres);
        END LOOP; -- Fim leitura temp-table
        -- Se resumo possuir registros
        IF vr_flgpares THEN
          pc_escreve_xml(vr_clobxml_2, '<resumolcr>');
          LOOP
            EXIT WHEN vr_chave_resumo IS NULL;
              
              -- Somente totalizador de linha de crédito
              IF vr_tab_empres(vr_chave_resumo).cdfinemp = 0 THEN 
             				
                -- Enfim enviar o registro de detalhe, que envolve as informações por linha de credito
                -- Escrever total da linha de crédito
                pc_escreve_xml(vr_clobxml_2, '<linhcred>'
                                        ||        '<cdlcremp>'||LPAD(vr_tab_empres(vr_chave_resumo).cdlcremp,4,0)|| '</cdlcremp>'
                                        ||        '<dslcremp>'||substr(vr_tab_craplcr(vr_tab_empres(vr_chave_resumo).cdlcremp).dslcremp,1,25)||'</dslcremp>'
                                        ||        '<qtassoci>'||to_char(vr_tab_empres(vr_chave_resumo).tbassoci.COUNT,'fm999g999g999g990')||'</qtassoci>'
                                        ||        '<qtctremp>'||to_char(vr_tab_empres(vr_chave_resumo).qtctremp,'fm999g999g999g990')||'</qtctremp>'
                                        ||        '<txmensal>'||to_char(vr_tab_craplcr(vr_tab_empres(vr_chave_resumo).cdlcremp).txmensal,'fm90d000000')||'</txmensal>'
                                        ||        '<vlempfis>'||to_char(vr_tab_empres(vr_chave_resumo).vlempfis,'fm999g999g999g990d00')||'</vlempfis>'
                                        ||        '<vlempjur>'||to_char(vr_tab_empres(vr_chave_resumo).vlempjur,'fm999g999g999g990d00')||'</vlempjur>'
                                        ||        '<vlslddev>'||(vr_tab_empres(vr_chave_resumo).vlempfis+vr_tab_empres(vr_chave_resumo).vlempjur)||'</vlslddev>'
                                        ||        '<vlratras>'||vr_tab_empres(vr_chave_resumo).vlratras||'</vlratras>'
                                        ||   '</linhcred>');
          		END IF;
              
              -- Se for ultimo registro do mesmo tipo de operação ou da agencia ou a finalidade for diferente de 0
              IF vr_chave_resumo = vr_tab_empres.LAST	
              OR vr_tab_empres(vr_tab_empres.NEXT(vr_chave_resumo)).cdagenci <> vr_tab_empres(vr_chave_resumo).cdagenci 
              OR vr_tab_empres(vr_chave_resumo).cdfinemp <> 0 THEN
                pc_escreve_xml(vr_clobxml_2, '</resumolcr>');
                vr_chave_resumo := NULL;
                CONTINUE;
              END IF;		            
            	
            vr_chave_resumo := vr_tab_empres.NEXT(vr_chave_resumo);                                              
          END LOOP;				
        END IF;
        -- Varrer a temp-table de resumo para enviar as informações para o relatório 067
        IF vr_tab_resumo.COUNT > 0 THEN
          FOR vr_cdagenci IN vr_tab_resumo.FIRST..vr_tab_resumo.LAST LOOP
            -- Se existir nesta posição
            IF vr_tab_resumo.EXISTS(vr_cdagenci) THEN
              -- Adicionar o nó resumo ao XML
              pc_escreve_xml(vr_clobxml_1,'<resumo>'
                                        ||'  <cdagenci>'||LPAD(vr_cdagenci,3,' ')||'</cdagenci>'
                                        ||'  <nmresage>'||vr_tab_resumo(vr_cdagenci).nmresage||'</nmresage>'
                                        ||'  <qtctremp>'||to_char(vr_tab_resumo(vr_cdagenci).qtctremp,'fm999g999g999g990')||'</qtctremp>'
                                        ||'  <vlsdeved>'||to_char(vr_tab_resumo(vr_cdagenci).vlsdeved,'fm999g999g999g990d00')||'</vlsdeved>'
                                        ||'</resumo>');
            END IF;
          END LOOP;
        END IF;
        -- Encerrar a tag raiz ainda aberta para os relatórios
        pc_escreve_xml(vr_clobxml_1,'</raiz>');
        pc_escreve_xml(vr_clobxml_2,'</raiz>');
        -- Busca do diretório base da cooperativa para a geração de relatórios
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/rl');     --> Utilizaremos o rl
                                              
        -- Submeter o relatório 67
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml_1                         --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/raiz'                              --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl067.jasper'                     --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null                                 --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_nom_direto||'/crrl067.lst'        --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132                                  --> 132 colunas
                                   ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                   ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '132col'                             --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                                    --> Número de cópias
                                   ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                   ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_saida;
        END IF;

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clobxml_1);
        dbms_lob.freetemporary(vr_clobxml_1);
        
        
        -- Submeter o relatório 68
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml_2                         --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/raiz'                              --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl068.jasper'                     --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null                                 --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_nom_direto||'/crrl068.lst'        --> Arquivo final com o path
                                   ,pr_qtcoluna  => 234                                  --> 132 colunas
                                   ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                   ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '234dh'                              --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                                    --> Número de cópias
                                   ,pr_sqcabrel  => 2                                    --> Qual a seq do cabrel
                                   ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
                                
                          
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_saida;
        END IF;
                
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clobxml_2);
        dbms_lob.freetemporary(vr_clobxml_2);

        -- Processo OK, devemos chamar a fimprg
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      END IF;
   EXCEPTION
     WHEN vr_exc_fimprg THEN
       -- Se foi retornado apenas código
       IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       -- Se foi gerada critica para envio ao log
       IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_dscritic );
       END IF;
       -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);
       -- Efetuar commit pois gravaremos o que foi processo até então
       COMMIT;
     WHEN vr_exc_saida THEN
       -- Se foi retornado apenas código
       IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       -- Devolvemos código e critica encontradas
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

  END pc_crps082;
/
