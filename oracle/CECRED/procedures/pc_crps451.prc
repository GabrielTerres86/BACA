CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS451" (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

       Programa: pc_crps451 (Antigo fontes/crps451.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Mirtes
       Data    : Junho/2005                     Ultima atualizacao: 29/04/2014
       Dados referentes ao programa:

       Frequencia: Diaria.
       Objetivo  : Gerar relatorio 423 - Relacao Cooperados que tiveram
                   movimentacao Conta Corrente/Emprestimos.  (Solicitacao 76)
       Alteracoes:
                   21/07/2005 - Alterado layout relatorio(Mirtes/Diego)

                   03/08/2005 - Desprezados historicos 441/443(Mirtes)

                   04/08/2005 - Alterando layout e excluidos campos referente
                                dias de atraso e prejuizo (Diego).

                   11/08/2005 - Alterado layout relatorio (Diego).

                   01/09/2005 - Somente calcular saldo emprestimo quando nao for
                                proc. mensal e desconsiderar historico 98(Mirtes)

                   03/10/2005 - Verifica todos os empretimos(Mirtes)

                   17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   22/05/2006 - Listar tambem as contas que tiveram registro no
                                CADSPC (Magui).

                   08/06/2006 - Ajuste para Saldo de Emprestimo Negativos (Ze).

                   25/10/2006 - Tratamento do campo rel_nrcpfcgc para receber
                                cpf e cnpj (David).

                   26/01/2007 - Alterado formato dos campos do tipo DATE de
                                "99/99/99" para "99/99/9999" (Elton).

                   05/03/2008 - Desprezar os historicos 046,047,100,351 e 504
                                na leitura da craplcm (Gabriel).

                   18/03/2009 - Nao considerar historicos de debito, e listar
                                somente Devedores de Emprestimos que estejam no SPC
                                com Saldo a Regularizar = 0 ou em Prejuizo e com
                                Saldo Devedor = 0 (Diego).

                   29/05/2009 - Adicionado campo cdlcremp - "Linha de Credito" no
                                relatorio (Fernando).

                   29/03/2010 - Incluir coluna descricao tp de registro (dsinsttu)
                                (Sandro-GATI)

                   25/05/2010 - Correcao da ultima coluna incluida (Gabriel).

                   25/10/2010 - Alteracao para gerar relatorio em txt
                                (GATI-Sandro)

                   15/02/2011 - Inclusao para gerar txt para Acredicoop;
                              - Alteracao para mover arquivos para diretorio
                                salvar (GATI - Eder).

                   12/03/2012 - Declarado as variaveis necessarias para utilizacao
                                da include lelem.i (Tiago).

                   29/03/2012 - Ajustado para funcionamento correto quando nao
                                tiver a segunda parte do registro. (Jorge)

                   23/05/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                   25/07/2013 - Ajustes na chamada da fn_mask_cpf_cnpj para passar o
                                inpessoa (Marcos-Supero)
                                
                   29/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                                posicoes (Tiago/Gielow SD137074).             

    ............................................................................ */

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
        SELECT lcr.cdlcremp
              ,lcr.txdiaria
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper;

      -- Busca dos associados com inadimplencia do SPC
      CURSOR cr_crapass IS
        SELECT nrdconta
              ,cdagenci
              ,nmprimtl
              ,dtdsdspc
              ,nrcpfcgc
              ,inpessoa
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND dtdsdspc IS NOT NULL; --> Inadimplentes

      -- Busca do instituto cadastro do cooperados no SPC
      CURSOR cr_crapspc(pr_nrdconta crapspc.nrdconta%TYPE
                       ,pr_nrcpfcgc crapspc.nrcpfcgc%TYPE) IS
        SELECT spc.tpinsttu
          FROM crapspc spc
         WHERE spc.cdcooper = pr_cdcooper
           AND spc.nrcpfcgc = pr_nrcpfcgc
           AND spc.nrdconta = pr_nrdconta
           AND spc.dtdbaixa IS NULL
           AND spc.tpidenti = 1 -- Devedor
        ORDER BY spc.progress_recid DESC;

      -- Busca se existe lançamento de deposito a vista que não seja de débito
      CURSOR cr_craplcm_exist(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT 'S'
          FROM craphis his
              ,craplcm lcm
         WHERE lcm.cdcooper = his.cdcooper
           AND lcm.cdhistor = his.cdhistor
           AND lcm.cdcooper = pr_cdcooper
           AND lcm.nrdconta = pr_nrdconta
           AND lcm.dtmvtolt >= rw_crapdat.dtmvtolt
           AND his.indebcre <> 'D';

      -- Busca se existe lançamento de empréstimo que não seja de débito
      CURSOR cr_craplem_exist(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT 'S'
          FROM craphis his
              ,craplem lem
         WHERE lem.cdcooper = his.cdcooper
           AND lem.cdhistor = his.cdhistor
           AND lem.cdcooper = pr_cdcooper
           AND lem.nrdconta = pr_nrdconta
           AND lem.dtmvtolt >= rw_crapdat.dtmvtolt
           AND his.indebcre <> 'D';

      -- Busca do ultimo saldo para a conta
      CURSOR cr_crapsda(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT vlsddisp
              ,vllimcre
          FROM crapsda
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
         ORDER BY dtmvtolt DESC;
      rw_crapsda cr_crapsda%ROWTYPE;

      -- Retornar todos os empréstimos da conta
      CURSOR cr_crapepr(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT nrctremp
              ,vlsdeved
              ,inprejuz
              ,cdlcremp
              ,inliquid
              ,txjuremp
              ,qtprepag
              ,vljuracu
              ,qtprecal
              ,dtultpag
              ,qtpreemp
              ,dtdpagto
              ,flgpagto
              ,qtmesdec
              ,dtmvtolt
              ,vlpreemp
              ,vlsdevat
              ,qtlcalat
          FROM crapepr
         WHERE cdcooper = pr_cdcooper
           ANd nrdconta = pr_nrdconta;

      -- Buscar dados do cadastro complementar de empréstimo
      CURSOR cr_crawepr(pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT dtdpagto
              ,nrctaav1
              ,SUBSTR(dscpfav1,1,34) dscpfav1
              ,nrctaav2
              ,SUBSTR(dscpfav2,1,34) dscpfav2
          FROM crawepr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;

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
      CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE) IS
        SELECT nmresage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;
      vr_nmresage crapage.nmresage%TYPE;

      -- Busca de CPF cfme a conta passada
      CURSOR cr_crapass_cpfcgc(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT nrcpfcgc
              ,inpessoa
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;

      ------------------- TIPOS E TABELAS DE MEMÓRIA -----------------------

      -- Definição de tipo para armazenar os dados de linhas de credito sendo a
      -- chave o código da linha de crédito e armazenaremos sua taxa diária
      TYPE typ_tab_craplcr IS
        TABLE OF craplcr.txdiaria%TYPE
          INDEX BY PLS_INTEGER;
      vr_tab_craplcr typ_tab_craplcr;

      -- Tipo para busca da empresa tanto de pessoa física quanto juridica
      -- Obs. A chave é o número da conta
      TYPE typ_tab_empresa IS
        TABLE OF crapjur.cdempres%TYPE
          INDEX BY PLS_INTEGER;
      vr_tab_empresa typ_tab_empresa;

      -- Definição de temp table para armazenar os cooperados a processar
      -- Obs: A chave é a conta do associados
      TYPE typ_reg_cooperado IS
        RECORD(cdagenci crapass.cdagenci%TYPE
              ,tpinsttu crapspc.tpinsttu%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,dtdsdspc crapass.dtdsdspc%TYPE
              ,nrcpfcgc crapass.nrcpfcgc%TYPE
              ,inpessoa crapass.inpessoa%TYPE);
      TYPE typ_tab_cooperado IS
        TABLE OF typ_reg_cooperado
          INDEX BY PLS_INTEGER;
      vr_tab_cooperado typ_tab_cooperado;
      vr_nrdconta crapass.nrdconta%TYPE;

      -- Definição de temp table para armazenar os dados da tabela
      -- que serve de base ao relatório.
      -- Obs: A chave é composta por 26 caracteres sendo:
      --     (5) Agencia + 10 Conta + (1) Tipo Registro + (4) Sequencia
      TYPE typ_reg_relato IS
        RECORD(tpregist PLS_INTEGER
              ,cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,inpessoa crapass.inpessoa%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,dtdsdspc crapass.dtdsdspc%TYPE
              ,vlsddisp crapsda.vlsddisp%TYPE
              ,nrcpfcgc crapass.nrcpfcgc%TYPE
              ,nrctremp crapepr.nrctremp%TYPE
              ,vlsdeved NUMBER
              ,nrctaavd crapavl.nrctaavd%TYPE
              ,nrctravd crapepr.nrctremp%TYPE
              ,cdlcremp crapepr.cdlcremp%TYPE
              ,tpinsttu crapspc.tpinsttu%TYPE
              ,dsinsttu VARCHAR2(6));
      TYPE typ_tab_relato IS
        TABLE OF typ_reg_relato
          INDEX BY VARCHAR2(20);
      vr_tab_relato typ_tab_relato;
      vr_chv_relato VARCHAR2(20);

      ----------------------------- VARIAVEIS ------------------------------

      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros
      vr_exc_fimprg exception;
      vr_exc_saida  exception;
      vr_exc_pula   exception;
      vr_cdcritic   crapcri.cdcritic%TYPE;--> Código de critica encontrada
      vr_dscritic   VARCHAR(4000);        --> Retorno de Erro

      -- Variáveis auxiliares ao processo
      vr_dstextab craptab.dstextab%TYPE;      --> Busca na craptab
      vr_inusatab BOOLEAN;                    --> Indicador S/N de utilização de tabela de juros
      vr_flglanct VARCHAR2(1);                --> Teste de existencia de lançamento <> Débito
      vr_vlsdeved NUMBER(14,2);               --> Saldo devedor do empréstimo
      vr_sldaregu NUMBER;                     --> Saldo a regularizar do empréstimo
      vr_qtprecal crapepr.qtprecal%TYPE;      --> Quantidade de parcelas do empréstimo
      vr_dtinipag DATE;                       --> Data de início de pagamento do empréstimo
      vr_qtmesdec crapepr.qtmesdec%TYPE;      --> Qtde de meses decorridos do empréstimo
      vr_flgtempr boolean;                    --> Flag de existencia do empréstimo

      -- Dia e data de pagamento de empréstimo
      vr_tab_diapagto NUMBER;
      vr_tab_dtcalcul DATE;
      -- Flag para desconto em folha
      vr_tab_flgfolha BOOLEAN;
      -- Configuração para mês novo
      vr_tab_ddmesnov INTEGER;

      -- Variáveis para passagem a rotina pc_calcula_lelem
      vr_diapagto INTEGER;
      vr_qtprepag     crapepr.qtprepag%TYPE;
      vr_qtprecal_lem crapepr.qtprecal%TYPE;
      vr_vlprepag     craplem.vllanmto%TYPE;
      vr_vljuracu     crapepr.vljuracu%TYPE;
      vr_vljurmes     crapepr.vljurmes%TYPE;
      vr_dtultpag     crapepr.dtultpag%TYPE;
      vr_txdjuros     crapepr.txjuremp%TYPE;

      -- Variaveis para os XMLs e relatórios
      vr_clobarq    CLOB;                   -- Clob para conter o dados do excel
      vr_clobxml    CLOB;                   -- Clob para conter o XML de dados
      vr_nom_direto VARCHAR2(200);          -- Diretório para gravação do arquivo
      vr_conta_cpf1 VARCHAR2(40);           -- Var dinâmica para o relatório
      vr_conta_cpf2 VARCHAR2(40);           -- Var dinâmica para o relatório
      vr_conta_avg  VARCHAR2(40);           -- Var dinamica para os avalistas
      vr_nrctaavg   crapass.nrdconta%TYPE;  -- Var dinamica para os avalistas
      vr_cpfctavg   VARCHAR2(34);           -- Var dinamica para os avalistas
      vr_inpesavg   crapass.inpessoa%TYPE;  -- Indicador de pessoa para o avalista
      vr_dspathcopia VARCHAR2(4000);        -- Path para cópia do arquivo exportado


      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

    BEGIN
      -- Código do programa
      vr_cdprogra := 'CRPS451';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS451'
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
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
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
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
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
                               ,pr_cdcritic => pr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF pr_cdcritic <> 0 THEN
        -- Buscar descrição da crítica
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

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

      -- Busca do cadastro de linhas de crédito de empréstimo
      FOR rw_craplcr IN cr_craplcr LOOP
        -- Guardamos tbm a taxa
        vr_tab_craplcr(rw_craplcr.cdlcremp) := rw_craplcr.txdiaria;
      END LOOP;

      -- Carregar associados inadimplentes
      FOR rw_crapass IN cr_crapass LOOP
        -- Adicioná-lo a PLTable
        vr_tab_cooperado(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_cooperado(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
        vr_tab_cooperado(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
        vr_tab_cooperado(rw_crapass.nrdconta).dtdsdspc := rw_crapass.dtdsdspc;
        vr_tab_cooperado(rw_crapass.nrdconta).nrcpfcgc := rw_crapass.nrcpfcgc;
        vr_tab_cooperado(rw_crapass.nrdconta).tpinsttu := 0;
        -- Busca do instituto cadastro do cooperados no SPC
        OPEN cr_crapspc(pr_nrdconta => rw_crapass.nrdconta
                       ,pr_nrcpfcgc => rw_crapass.nrcpfcgc);
        FETCH cr_crapspc
         INTO vr_tab_cooperado(rw_crapass.nrdconta).tpinsttu;
        CLOSE cr_crapspc;
      END LOOP;

      -- Fazer a varredura na tabela para retornar todos os associados carregados
      vr_nrdconta := vr_tab_cooperado.FIRST;
      LOOP
        -- Sair quando não encontrar mais registros
        EXIT WHEN vr_nrdconta IS NULL;
        -- Resetar flag de lançamento
        vr_flglanct := 'N';
        -- Busca se existe lançamento de deposito a vista que não seja de débito
        OPEN cr_craplcm_exist(pr_nrdconta => vr_nrdconta);
        FETCH cr_craplcm_exist
         INTO vr_flglanct;
        CLOSE cr_craplcm_exist;
        -- Se ainda não achou lançamento
        IF vr_flglanct = 'N' THEN
          -- Busca se existe lançamento de empréstimo que não seja de débito
          OPEN cr_craplem_exist(pr_nrdconta => vr_nrdconta);
          FETCH cr_craplem_exist
           INTO vr_flglanct;
          CLOSE cr_craplem_exist;
        END IF;
        -- Se encontrou algum lançamento
        IF vr_flglanct = 'S' THEN
          -- Montar a chave para o registro do relatório
          --  (5) Agencia + 10 Conta + (1) Tipo Registro + (4) Sequencia
          vr_chv_relato := lpad(vr_tab_cooperado(vr_nrdconta).cdagenci,5,'0')||lpad(vr_nrdconta,10,'0')||'0'||lpad('0',4,'0');
          -- Após a montagem da chave, enviar as informações para a PLTable
          vr_tab_relato(vr_chv_relato).tpregist := 0; -- Devedor
          vr_tab_relato(vr_chv_relato).nrdconta := vr_nrdconta;
          vr_tab_relato(vr_chv_relato).inpessoa := vr_tab_cooperado(vr_nrdconta).inpessoa;
          vr_tab_relato(vr_chv_relato).cdagenci := vr_tab_cooperado(vr_nrdconta).cdagenci;
          vr_tab_relato(vr_chv_relato).nmprimtl := vr_tab_cooperado(vr_nrdconta).nmprimtl;
          vr_tab_relato(vr_chv_relato).dtdsdspc := vr_tab_cooperado(vr_nrdconta).dtdsdspc;
          vr_tab_relato(vr_chv_relato).tpinsttu := vr_tab_cooperado(vr_nrdconta).tpinsttu;
          vr_tab_relato(vr_chv_relato).nrcpfcgc := vr_tab_cooperado(vr_nrdconta).nrcpfcgc;
          -- Busca do ultimo saldo para a conta
          rw_crapsda := NULL;
          OPEN cr_crapsda(pr_nrdconta => vr_nrdconta);
          FETCH cr_crapsda
           INTO rw_crapsda;
          CLOSE cr_crapsda;
          -- Se o saldo disponível for inferior a zero
          IF rw_crapsda.vlsddisp < 0 THEN
            -- Usar o limite no saldo
            vr_tab_relato(vr_chv_relato).vlsddisp := nvl(rw_crapsda.vllimcre,0) + rw_crapsda.vlsddisp;
          ELSE
            -- Usar apenas o saldo disponível
            vr_tab_relato(vr_chv_relato).vlsddisp := nvl(rw_crapsda.vlsddisp,0);
          END IF;
          -- Retornar todos os empréstimos da conta
          FOR rw_crapepr IN cr_crapepr(pr_nrdconta => vr_nrdconta) LOOP
            BEGIN
              -- Inicializar o saldo devedor e saldo a regularizar
              vr_vlsdeved := 0;
              vr_sldaregu := 0;
              -- Se for no processo mensal
              IF TRUNC(rw_crapdat.dtmvtolt,'mm') <> TRUNC(rw_crapdat.dtmvtopr,'mm') THEN
                -- Saldo calculado pelo 78
                vr_vlsdeved := rw_crapepr.vlsdeved;
              ELSE
                -- Se não for um empréstimo de prejuízo
                IF rw_crapepr.inprejuz <> 1 THEN
                  -- Calcular prestacoes calculadas
                  IF rw_crapepr.inliquid = 0 THEN
                    vr_vlsdeved := rw_crapepr.vlsdevat;
                  ELSE
                    vr_vlsdeved := 0;
                  END IF;

                 /* empr0001.pc_calc_saldo_epr(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                            ,pr_rw_crapdat => rw_crapdat          --> Vetor com dados de parâmetro (CRAPDAT)
                                            ,pr_cdprogra   => vr_cdprogra         --> Programa que solicitou o calculo
                                            ,pr_nrdconta   => vr_nrdconta         --> Numero da conta do empréstimo
                                            ,pr_nrctremp   => rw_crapepr.nrctremp --> Numero do contrato do empréstimo
                                            ,pr_inusatab   => vr_inusatab         --> Indicador de utilização da tabela de juros
                                            ,pr_vlsdeved   => vr_vlsdeved         --> Saldo devedor do empréstimo
                                            ,pr_qtprecal   => vr_qtprecal         --> Quantidade de parcelas do empréstimo
                                            ,pr_cdcritic   => vr_cdcritic         --> Código de critica encontrada
                                            ,pr_des_erro   => vr_dscritic);       --> Retorno de Erro
                  -- Se houve qualquer erro no cálculo, ignorar este empréstimo
                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    -- Ignorar este registro
                    RAISE vr_exc_pula;
                  END IF;*/
                END IF;
              END IF;
              ------- Verifica se tem Saldo A Regularizar  -------
              -- Buscar a configuração de empréstimo cfme a empresa da conta
              empr0001.pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper      --> Código da Cooperativa
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data atual
                                                 ,pr_nrdconta => vr_nrdconta      --> Numero da conta do empréstimo
                                                 ,pr_dtcalcul => vr_tab_dtcalcul  --> Data calculada de pagamento
                                                 ,pr_diapagto => vr_tab_diapagto  --> Dia de pagamento das parcelas
                                                 ,pr_flgfolha => vr_tab_flgfolha  --> Flag de desconto em folha S/N
                                                 ,pr_ddmesnov => vr_tab_ddmesnov  --> Configuração para mês novo
                                                 ,pr_cdcritic => pr_cdcritic      --> Código do erro
                                                 ,pr_des_erro => pr_dscritic);    --> Retorno de Erro
              -- Se houve erro na rotina
              IF pr_dscritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN
                -- Levantar exceção
                RAISE vr_exc_saida;
              END IF;
              -- Povoar variáveis para o calculo com os valores do empréstimo
              vr_diapagto := vr_tab_diapagto;
              vr_qtprepag := NVL(rw_crapepr.qtprepag,0);
              vr_vlprepag := 0;
              vr_vlsdeved := NVL(rw_crapepr.vlsdeved,0);
              vr_vljuracu := NVL(rw_crapepr.vljuracu,0);
              vr_vljurmes := 0;
              vr_dtultpag := rw_crapepr.dtultpag;
              -- Se está setado para utilizarmos a tabela de juros e o empréstimo estiver em aberto
              IF vr_inusatab AND rw_crapepr.inliquid = 0 THEN
                -- Iremos buscar a tabela de juros nas linhas de crédito
                vr_txdjuros := vr_tab_craplcr(rw_crapepr.cdlcremp);
              ELSE
                -- Usar taxa cadastrada no empréstimo
                vr_txdjuros := rw_crapepr.txjuremp;
              END IF;
              -- Se o empréstimo não estiver ativo
              IF rw_crapepr.inliquid = 0 THEN
                -- Utilizar a quantidade de parcelas calculadas do empréstimo
                vr_qtprecal := NVL(rw_crapepr.qtprecal,0) + NVL(rw_crapepr.qtlcalat,0);
              ELSE
                -- Utilizar a quantidade de parcelas total do empréstimo
                vr_qtprecal := NVL(rw_crapepr.qtpreemp,0);
              END IF;

              -- Verificar se existe cadastro complementar de empréstimo
              OPEN cr_crawepr(pr_nrdconta => vr_nrdconta
                             ,pr_nrctremp => rw_crapepr.nrctremp);
              FETCH cr_crawepr
               INTO rw_crawepr;
              -- Se tiver encontrado
              IF cr_crawepr%FOUND THEN
                -- Utilizarmos a informação complementar
                vr_dtinipag := rw_crawepr.dtdpagto;
              ELSE
                -- Utilizarmos da tabela padrão
                vr_dtinipag := rw_crapepr.dtdpagto;
              END IF;
              -- Fechar cursor
              CLOSE cr_crawepr;
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
                  OPEN cr_crapavs(pr_nrdconta => vr_nrdconta);
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
              -- Se a quantidade calculada for superior a quantidade de meses decorridos
              -- E a data do pagamento já venceu
              -- E for um empréstimo de débito em conta
              IF rw_crapepr.qtprecal > rw_crapepr.qtmesdec
              AND rw_crapepr.dtdpagto <= rw_crapdat.dtmvtolt
              AND rw_crapepr.flgpagto = 0 THEN
                -- Calcular o atraso com base no valor do empréstimo - o que foi pago
                vr_sldaregu := rw_crapepr.vlpreemp - vr_vlprepag;
                -- Garantir que o valor não fique negativo
                IF vr_sldaregu < 0 THEN
                  vr_sldaregu := 0;
                END IF;
              ELSE
                -- Se a diferença de meses decorridos e qtde calculada
                -- for superior a zero
                IF (vr_qtmesdec - vr_qtprecal) > 0 THEN
                  -- Valor do atraso é essa diferença * valor da parcela
                  vr_sldaregu := (vr_qtmesdec - vr_qtprecal) * rw_crapepr.vlpreemp;
                ELSE
                  -- Não há atraso
                  vr_sldaregu := 0;
                END IF;
              END IF;
              -- Se a Qtde de meses decorridos for superior a qtde de parcelas do empréstimo
              -- OU Se o valor do atraso for superior ao devedor
              IF vr_qtmesdec > rw_crapepr.qtpreemp THEN -- ANDRINO OR vr_sldaregu > vr_vlsdeved THEN
                -- Considerar como atraso o saldo devedor calculado
                vr_sldaregu := vr_vlsdeved;
              ELSIF vr_sldaregu > rw_crapepr.vlsdeved THEN
                vr_sldaregu := rw_crapepr.vlsdeved;
              END IF;
              -- Garantir que o valor do atraso não seja negativo
              IF vr_sldaregu < 0 THEN
                vr_sldaregu := 0;
              END IF;
              -- Se o empréstimo tem saldo a regularizar
              -- OU for um empréstimo de Prejuízo com saldo devedor zerado
              IF vr_sldaregu = 0 OR (rw_crapepr.inprejuz = 1 AND vr_vlsdeved = 0) THEN
                -- Montar a chave para o registro do relatório
                --  (5) Agencia + 10 Conta + (1) Tipo Registro + (4) Sequencia
                vr_chv_relato := lpad(vr_tab_cooperado(vr_nrdconta).cdagenci,5,'0')||lpad(vr_nrdconta,10,'0')||'1'||lpad(cr_crapepr%rowcount,4,'0');
                -- Após a montagem da chave, enviar as informações para a PLTable
                vr_tab_relato(vr_chv_relato).tpregist := 1; -- Contrato Emprestimo
                vr_tab_relato(vr_chv_relato).nrdconta := vr_nrdconta;
                vr_tab_relato(vr_chv_relato).nrctremp := rw_crapepr.nrctremp;
                vr_tab_relato(vr_chv_relato).cdagenci := vr_tab_cooperado(vr_nrdconta).cdagenci;
                vr_tab_relato(vr_chv_relato).inpessoa := vr_tab_cooperado(vr_nrdconta).inpessoa;
                vr_tab_relato(vr_chv_relato).nmprimtl := vr_tab_cooperado(vr_nrdconta).nmprimtl;
                vr_tab_relato(vr_chv_relato).cdlcremp := rw_crapepr.cdlcremp;
                vr_tab_relato(vr_chv_relato).tpinsttu := vr_tab_cooperado(vr_nrdconta).tpinsttu;
                vr_tab_relato(vr_chv_relato).nrcpfcgc := vr_tab_cooperado(vr_nrdconta).nrcpfcgc;
                vr_tab_relato(vr_chv_relato).vlsdeved := vr_vlsdeved;
              END IF;
            EXCEPTION
              WHEN vr_exc_pula THEN
                -- Apenas ignorar
                null;
            END;
          END LOOP;
        END IF;
        -- Buscar a próxima conta
        vr_nrdconta := vr_tab_cooperado.NEXT(vr_nrdconta);
      END LOOP;

      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Inicializar as informações do arquivo de exportação de dados
      dbms_lob.createtemporary(vr_clobarq, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobarq, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobarq,'PA;Nome;Conta;CPF/CNPJ;Inc.SPC;Saldo Disp.;Contrato;Saldo;Lin.;AVAIS;AVAIS;Instituicao'||chr(13));

      -- Varrer a tabela de informações para o relatório
      vr_chv_relato := vr_tab_relato.FIRST;
      LOOP
        -- Sair quando não existir mais informação
        EXIT WHEN vr_chv_relato IS NULL;
        -- Preencher a descrição da instituição
        IF vr_tab_relato(vr_chv_relato).tpinsttu = 1 THEN
          vr_tab_relato(vr_chv_relato).dsinsttu := 'SPC';
        ELSIF vr_tab_relato(vr_chv_relato).tpinsttu = 2 THEN
          vr_tab_relato(vr_chv_relato).dsinsttu := 'SERASA';
        END IF;
        -- Se for o primeiro registro ou o primeiro do PAC
        IF vr_chv_relato = vr_tab_relato.FIRST OR vr_tab_relato(vr_chv_relato).cdagenci <> vr_tab_relato(vr_tab_relato.PRIOR(vr_chv_relato)).cdagenci THEN
          -- Buscar o nome do PAC
          OPEN cr_crapage(vr_tab_relato(vr_chv_relato).cdagenci);
          FETCH cr_crapage
           INTO vr_nmresage;
          CLOSE cr_crapage;
          -- Inicializar a tag de PAC
          pc_escreve_clob(vr_clobxml,'<pac id="'||LPAD(vr_tab_relato(vr_chv_relato).cdagenci,3,' ')||'" nmresage="'||substr(vr_nmresage,1,15)||'">');
        END IF;
        -- Se for primeiro registro ou o primeiro da conta atual
        IF vr_chv_relato = vr_tab_relato.FIRST OR vr_tab_relato(vr_chv_relato).nrdconta <> vr_tab_relato(vr_tab_relato.PRIOR(vr_chv_relato)).nrdconta THEN
          -- Inicializar a tag do associado
          pc_escreve_clob(vr_clobxml,'<associ id="'||gene0002.fn_mask_conta(vr_tab_relato(vr_chv_relato).nrdconta)||'">'
                                   ||'  <nmprimtl>'||substr(vr_tab_relato(vr_chv_relato).nmprimtl,1,28)||'</nmprimtl>'
                                   ||'  <dtdsdspc>'||LPAD(to_char(vr_tab_relato(vr_chv_relato).dtdsdspc,'dd/mm/rrrr'),10,' ')||'</dtdsdspc>'
                                   ||'  <vlsddisp>'||to_char(vr_tab_relato(vr_chv_relato).vlsddisp,'fm999g999g999g990d00')||'</vlsddisp>'
                                   ||'  <nrcpfcgc>'||gene0002.fn_mask_cpf_cnpj(vr_tab_relato(vr_chv_relato).nrcpfcgc,vr_tab_relato(vr_chv_relato).inpessoa)||'</nrcpfcgc>'
                                   ||'  <dsinsttu>'||vr_tab_relato(vr_chv_relato).dsinsttu||'</dsinsttu>');
          -- Inicia controle de existencia de empréstimo
          vr_flgtempr := false;
          -- Adicionamos também as informações para o arquivo de exportação de dados
          pc_escreve_clob(vr_clobarq,LPAD(vr_tab_relato(vr_chv_relato).cdagenci,3,' ')||';'
                                   ||RPAD(SUBSTR(vr_tab_relato(vr_chv_relato).nmprimtl,1,28),28,' ')||';'
                                   ||gene0002.fn_mask_conta(vr_tab_relato(vr_chv_relato).nrdconta)||';'
                                   ||gene0002.fn_mask_cpf_cnpj(vr_tab_relato(vr_chv_relato).nrcpfcgc,vr_tab_relato(vr_chv_relato).inpessoa)||';'
                                   ||gene0002.fn_mask(to_char(vr_tab_relato(vr_chv_relato).dtdsdspc,'dd/mm/rrrr'),'zzzzzzzzzz')||';'
                                   ||to_char(vr_tab_relato(vr_chv_relato).vlsddisp,'99999g990d00')||';'
                                   ||';;;;;'
                                   ||RPAD(vr_tab_relato(vr_chv_relato).dsinsttu,6,' ')
                                   ||chr(13));
        END IF;
        -- Somente para o tipo de registro 1
        IF vr_tab_relato(vr_chv_relato).tpregist = 1 THEN
          -- Reinicializar as variaveis dinamicas
          vr_conta_cpf1 := ' ';
          vr_conta_cpf2 := ' ';
          -- Busca do cadastro complementar de empréstimos para buscar os avalistas
          OPEN cr_crawepr(pr_nrdconta => vr_tab_relato(vr_chv_relato).nrdconta
                         ,pr_nrctremp => vr_tab_relato(vr_chv_relato).nrctremp);
          FETCH cr_crawepr
           INTO rw_crawepr;
          -- Se encontrar registro
          IF cr_crawepr%FOUND THEN
            -- Fechar o cursor e continuar a busca
            CLOSE cr_crawepr;
            -- Efetuar laço abaixo para buscar duas vezes cfme nrctaav1 e nrctaav2
            FOR vr_ind IN 1..2 LOOP
              -- No primeiro laço
              IF vr_ind = 1 THEN
                -- Usar nrctaav1
                vr_nrctaavg := rw_crawepr.nrctaav1;
                vr_cpfctavg := rw_crawepr.dscpfav1;
              ELSE
                -- Usar nrctaav2
                vr_nrctaavg := rw_crawepr.nrctaav2;
                vr_cpfctavg := rw_crawepr.dscpfav2;
              END IF;
              -- Se existir informação no campo atual
              IF vr_nrctaavg > 0 THEN
                -- Busca do CPF do avalista
                OPEN cr_crapass_cpfcgc(pr_nrdconta => vr_nrctaavg);
                FETCH cr_crapass_cpfcgc
                 INTO vr_cpfctavg
                     ,vr_inpesavg;
                CLOSE cr_crapass_cpfcgc;
                -- Montar a descrição com o CPF
                vr_conta_avg := 'CONTA/CPF  ' || gene0002.fn_mask_conta(vr_nrctaavg) || ' ' || gene0002.fn_mask_cpf_cnpj(vr_cpfctavg,vr_inpesavg);
              ELSIF vr_cpfctavg <> ' ' THEN
                -- Montar a descrição somente com a conta
                vr_conta_avg := 'DOCTO ' || vr_cpfctavg;
              END IF;
              -- Copiar a informação montada conforme o laço atual
              IF vr_ind = 1 THEN
                vr_conta_cpf1 := vr_conta_avg;
              ELSE
                vr_conta_cpf2 := vr_conta_avg;
              END IF;
              -- Limpar o campo genérico
              vr_conta_avg := null;
            END LOOP;
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crawepr;
          END IF;
          -- Enviar o registro para o relatório
          pc_escreve_clob(vr_clobxml,'<empresti>'
                                   ||'  <nrctremp>'||LTRIM(gene0002.fn_mask(vr_tab_relato(vr_chv_relato).nrctremp,'zzz.zzz.zz9'))||'</nrctremp>'
                                   ||'  <vlsdeved>'||to_char(vr_tab_relato(vr_chv_relato).vlsdeved,'fm999g999g999g990d00')||'</vlsdeved>'
                                   ||'  <cdlcremp>'||vr_tab_relato(vr_chv_relato).cdlcremp||'</cdlcremp>'
                                   ||'  <aux_cpf1>'||vr_conta_cpf1||'</aux_cpf1>'
                                   ||'  <aux_cpf2>'||vr_conta_cpf2||'</aux_cpf2>'
                                   ||'</empresti>');
          -- Enviamos também as informações para o arquivo de exmportação
          pc_escreve_clob(vr_clobarq,LPAD(vr_tab_relato(vr_chv_relato).cdagenci,3,' ')||';'
                                     ||';;;;;'
                                     ||gene0002.fn_mask(vr_tab_relato(vr_chv_relato).nrctremp,'z.zzz.zz9')||';'
                                     ||to_char(vr_tab_relato(vr_chv_relato).vlsdeved,'99999g990d00')||';'
                                     ||gene0002.fn_mask(vr_tab_relato(vr_chv_relato).cdlcremp,'zzz9')||';'
                                     ||RPAD(vr_conta_cpf1,40,' ')||';'
                                     ||RPAD(vr_conta_cpf2,40,' ')||';'
                                     ||chr(13));
          -- Indica que encontrou pelo menos um empréstimo
          vr_flgtempr := true;
        END IF;
        -- Se for o ultimo ou o ultimo da conta atual
        IF vr_chv_relato = vr_tab_relato.LAST OR vr_tab_relato(vr_chv_relato).nrdconta <> vr_tab_relato(vr_tab_relato.NEXT(vr_chv_relato)).nrdconta THEN
          -- Se não foi encontrado nenhum empréstimo para a conta
          IF NOT vr_flgtempr THEN
            -- Criação de um registro vazia de empréstimo para facilitar a montagem do relatório depois
            -- Já que nem todos os associados terão empréstimo listado
            pc_escreve_clob(vr_clobxml,'<empresti/>');
          END IF;
          -- Encerrar a tag do associado
          pc_escreve_clob(vr_clobxml,'</associ>');
        END IF;
        -- Se for o ultimo ou o ultimo do PAC
        IF vr_chv_relato = vr_tab_relato.LAST OR vr_tab_relato(vr_chv_relato).cdagenci <> vr_tab_relato(vr_tab_relato.NEXT(vr_chv_relato)).cdagenci THEN
          -- Encerrar a tag de PAC
          pc_escreve_clob(vr_clobxml,'</pac>');
        END IF;
        -- Buscar o próximo registro da tabela
        vr_chv_relato := vr_tab_relato.NEXT(vr_chv_relato);
      END LOOP;

      -- Finalizar o nó raiz
      pc_escreve_clob(vr_clobxml,'</raiz>');
      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper);
      -- Submeter o relatório 423
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/pac/associ/empresti'          --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl423.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl423.lst'     --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '234dh'                              --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => pr_dscritic);                        --> Saída com erro
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);
      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Incluir o diretório salvar para copiar o arquivo
      vr_dspathcopia := vr_nom_direto||'/salvar';
      -- Quando execução na Viacredi e Acredi
      IF pr_cdcooper IN(1,2) THEN
        -- Efetuar a cópia do arquivo crrl354.txt também para diretório parametrizado
        vr_dspathcopia := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL423_COPIA');
      END IF;

      -- Submeter a geração do arquivo txt puro
      gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                       --> Cooperativa conectada
                                         ,pr_cdprogra  => vr_cdprogra                       --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt               --> Data do movimento atual
                                         ,pr_dsxml     => vr_clobarq                        --> Arquivo XML de dados
                                         ,pr_cdrelato  => '423'                             --> Código do relatório
                                         ,pr_dsarqsaid => vr_nom_direto||'/salvar/crrl423.txt' --> Arquivo final com o path
                                         ,pr_flg_gerar => 'N'                               --> Geraçao na hora
                                         ,pr_dspathcop => vr_dspathcopia                    --> Copiar para o diretório
                                         ,pr_fldoscop  => 'S'                               --> Copiar como DOS
                                         ,pr_flgremarq => 'N'                               --> Após cópia, remover arquivo de origem
                                         ,pr_des_erro  => pr_dscritic);                     --> Saída com erro
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobarq);
      dbms_lob.freetemporary(vr_clobarq);
      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || pr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);

        -- É um erro tratado, entao limpa as variaveis de retorno
        pr_dscritic := NULL;
        pr_cdcritic := 0;
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps451;
/

