CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS299(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdoperad IN crapope.cdoperad%TYPE   --> Codigo do operador
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

         Programa: pc_crps299 (Antigo Fontes/crps299.p)
         Sistema : Conta-Corrente - Cooperativa de Credito
         Sigla   : CRED
         Autor   : Eduardo.
         Data    : Novembro/2000.                    Ultima atualizacao: 08/08/2017

         Dados referentes ao programa:

         Frequencia: Mensal (Batch - Background).
         Objetivo  : Atende a solicitacao 004 (mensal - relatorios)
                     Relatorio : 251 (234 colunas)
                     Ordem do programa na solicitacao : 4
                     Emite: relatorio geral de emprestimos.

         Alteracoes: 09/01/2004 - Alterar formulario para que todas as informacoes
                                  de um emprestimo aparecam na mesma linha (Junior).

                     16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                     01/09/2008 - Alteracao CDEMPRES (Kbase).

                     02/02/2011 - Ajuste do format do campo qtprepag (Henrique).

                     03/01/2012 - Alteração do campo 'crapepr.qtprepag'
                                  por 'crapepr.qtprecal' (Lucas).

                     28/05/2013 - Conversão Progress >> Oracle PLSQL (Marcos)

                     29/05/2013 - Alterado contador de cooperados (Jean).

                     21/06/2013 - Leitura da tabela crapebn. (Fabricio).

                     02/07/2013 - 2a fase projeto Credito (Gabriel).

                     07/10/2013 - Ajuste no contador de associados (Gabriel).

                     22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                                  ser acionada em caso de saída para continuação da cadeia,
                                  e não em caso de problemas na execução (Marcos-Supero)

                     06/02/2013 - Ajuste ao calcular o campo vlsdvctr (Odirlei-AMcom)

                     27/12/2013 - Ajuste para melhorar a performance (James)

                     03/02/2014 - Removido a procedure "busca_pagamentos_parcelas"
                                  (James)

                     18/02/2014 - Ajustes referentes às alterações de dezembro e
                                  fevereiro realizadas no progress (Daniel - Supero)

                     29/12/2014 - Realizar copia do relatorio crrl251.lst para 
                                  o diretorio /micros/[cooperativa]/contab/.
                                  (Jaison - SD: 238547)
                                  
                     20/03/2015 - Projeto de separação contábeis de PF e PJ.
                                  (Andre Santos - SUPERO)
																	
									   25/09/2015 - Alterações na composição do crrl251 
										              (Lucas Lunelli SD 324285)

                     08/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

  ............................................................................. */
    DECLARE

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;

      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca o cadastro de linhas de crédito
      CURSOR cr_craplcr IS
        SELECT lcr.cdlcremp
              ,lcr.txmensal
              ,lcr.dsoperac
              ,lcr.dslcremp
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper;

      -- Busca das empresas em titulares de conta
      CURSOR cr_crapttl IS
        SELECT nrdconta
              ,cdempres
          FROM crapttl
         WHERE cdcooper = pr_cdcooper
           AND idseqttl = 1; --> Somente titulares

      -- Busca das empresas no cadastro de pessoas juridicas
      CURSOR cr_crapjur IS
        SELECT nrdconta
              ,cdempres
          FROM crapjur
         WHERE cdcooper = pr_cdcooper;

      -- Leitura dos empréstimos ativos
      CURSOR cr_crapepr IS
        select ass.nrdconta,
               epr.nrctremp,
               ass.cdagenci,
               epr.cdagenci cdagenci_epr,
               ass.nmprimtl,
               epr.cdlcremp,
               epr.cdfinemp,
               DECODE(ass.inpessoa,1,'PF',2,'PJ',NULL) dspessoa,
               ass.inpessoa,
               epr.vlsdeved,
               epr.vljurmes,
               epr.dtmvtolt,
               epr.cdbccxlt,
               epr.nrdolote,
               epr.vlemprst,
               epr.vlpreemp,
               epr.qtprecal,
               epr.qtpreemp,
               epr.txjuremp,
               epr.tpemprst,
               epr.vlsdvctr
          from crapass ass,
               crapepr epr
         where epr.cdcooper = pr_cdcooper
           and epr.cdcooper = ass.cdcooper
           and epr.nrdconta = ass.nrdconta
           -- Para aqueles com saldo devedor zerado, trazer somente com juros
           and (  (    epr.vlsdeved = 0 
                   and epr.vljurmes > 0) 
                or epr.vlsdeved <> 0);

      -- Leitura de emprestimos com o BNDES
      CURSOR cr_crapebn IS
        SELECT ass.nrdconta
              ,ass.cdagenci
              ,ass.nmprimtl
              ,DECODE(ass.inpessoa,1,'PF',2,'PJ',NULL) dspessoa
              ,ebn.dtinictr
							,ebn.dtlibera
              ,ebn.qtparabe
              ,ebn.nrctremp
              ,ebn.vlropepr
              ,ebn.vlparepr
              ,ebn.qtparctr
              ,ebn.vlsdeved
          FROM crapass ass
              ,crapebn ebn
         WHERE ebn.cdcooper = pr_cdcooper
           AND ebn.cdcooper = ass.cdcooper
           AND ebn.nrdconta = ass.nrdconta
           AND ebn.vlsdeved > 0;

      -- Buscar nome da agência
      CURSOR cr_crapage(pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT nmextage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;
      vr_nmextage crapage.nmextage%TYPE;

      CURSOR cr_crapris (pr_cdcooper crapepr.cdcooper%type,
                         pr_nrdconta crapepr.nrdconta%type,
                         pr_nrctremp crapepr.nrctremp%type,
                         pr_dtultdia crapdat.dtultdia%type) IS
        SELECT vljura60
          FROM crapris s1
         WHERE s1.cdcooper = pr_cdcooper
           AND s1.nrdconta = pr_nrdconta
           AND s1.nrctremp = pr_nrctremp
           AND s1.cdorigem = 3
           AND s1.dtrefere = pr_dtultdia
         ORDER BY progress_recid;
      rw_crapris cr_crapris%rowtype;

      ------------------- TIPOS E TABELAS DE MEMÓRIA -----------------------

      -- Definição de tipo para armazenar a taxa da linha de crédito
      TYPE typ_reg_craplcr IS
           RECORD (txmensal craplcr.txmensal%TYPE
                  ,dsoperac craplcr.dsoperac%TYPE
                  ,dslcremp craplcr.dslcremp%TYPE);

      TYPE typ_tab_craplcr IS
        TABLE OF typ_reg_craplcr
          INDEX BY PLS_INTEGER;
      vr_tab_craplcr typ_tab_craplcr;

      -- Tipo para busca da empresa tanto de pessoa física quanto juridica
      -- Obs. A chave é o número da conta
      TYPE typ_tab_empresa IS
        TABLE OF crapjur.cdempres%TYPE
          INDEX BY PLS_INTEGER;
      vr_tab_empresa typ_tab_empresa;

      -- Registros de contratos para listagem ordenada por Conta / Contrato
      TYPE typ_reg_contratos IS
        RECORD(nrdconta crapass.nrdconta%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,cdempres crapemp.cdempres%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,dspessoa VARCHAR(2)
							,dtmvtolt crapepr.dtmvtolt%TYPE
              ,nrctremp crapepr.nrctremp%TYPE
              ,cdfinemp VARCHAR2(20)
              ,cdlcremp VARCHAR2(20)
              ,dspesqui VARCHAR2(40)
              ,vlemprst crapepr.vlemprst%TYPE
              ,vlpreemp crapepr.vlpreemp%TYPE
              ,vlsdeved crapepr.vlsdeved%TYPE
              ,txjurmes NUMBER(10,7)
              ,txjuremp NUMBER(10,7)
              ,vljurmes NUMBER(10,2)
              ,vlsdvctr NUMBER(10,2)
              ,vljura60 crapris.vljura60%type
              ,dsemprst varchar2(5)
              ,dspresta varchar2(15));

      -- Tabela para listagem ordenada por Conta / Contrato
      TYPE typ_tab_contratos IS
        TABLE OF typ_reg_contratos
          INDEX BY VARCHAR2(30);

      vr_tab_contratos typ_tab_contratos;

      -- Definição de tipo para armazenar o resumo geral por agência
      -- Chave composta pelo código da agência
      TYPE typ_reg_resumo IS
        RECORD(tpoperac number
              ,tpemprst crapepr.tpemprst%type
              ,cdagenci crapass.cdagenci%type
              ,dsoperac craplcr.dsoperac%TYPE
              ,dsemprst varchar2(5)
              ,qtdsocio NUMBER
              ,qtdcrtos NUMBER
              ,vljurmes NUMBER
              ,vlpresta NUMBER
              ,vlsaldev NUMBER
              ,vlsdvctr number
              ,vljura60 number);

      TYPE typ_tab_resumo IS
        TABLE OF typ_reg_resumo
          INDEX BY varchar2(11);-- +tpoperac (1) + tpemprst(5) + cdagenci(5)
      vr_tab_resumo typ_tab_resumo;

      -- type para controlar o contador de associados
      TYPE typ_tab_contas_gerais IS
        TABLE OF NUMBER
          INDEX BY varchar2(21);-- +tpoperac (1) + tpemprst(5) + cdagenci(5) + conta(10)
      vr_tab_ctager typ_tab_contas_gerais;

      ----------------------------- VARIAVEIS ------------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS299';
      -- Tratamento de erros
      vr_exc_erro exception;
      vr_exc_fimprg exception;
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);

      -- Variaveis do processo --
      vr_exc_next     EXCEPTION;              --> Desviar fluxo para ir ao próximo registro

      -- Variaveis para os XMLs e relatórios
      vr_clobxml    CLOB;
      vr_nom_direto VARCHAR2(200);
      vr_nom_dirmic VARCHAR2(200);
      vr_dspesqui   VARCHAR2(31); -- 26
      vr_qtprepag   NUMBER(10);

      vr_chave_contratos VARCHAR2(30);

      vr_tpoperac   number(1);
      vr_idxger     varchar2(11);
      vr_idxcta     varchar2(21);

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(vr_clobxml, length(pr_desdados),pr_desdados);
      END;

    BEGIN

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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1 -- true
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Buscar descrição da crítica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      -- Carregar PLTABLE de titulares de conta
      FOR rw_crapttl IN cr_crapttl LOOP
        vr_tab_empresa(rw_crapttl.nrdconta) := rw_crapttl.cdempres;
      END LOOP;
      -- Carregar PLTABLE de empresas
      FOR rw_crapjur IN cr_crapjur LOOP
        vr_tab_empresa(rw_crapjur.nrdconta) := rw_crapjur.cdempres;
      END LOOP;
      -- Busca do cadastro de linhas de crédito de empréstimo
      FOR rw_craplcr IN cr_craplcr LOOP
        -- Guardamos a taxa
        vr_tab_craplcr(rw_craplcr.cdlcremp).txmensal := rw_craplcr.txmensal;
        vr_tab_craplcr(rw_craplcr.cdlcremp).dsoperac := rw_craplcr.dsoperac;
        vr_tab_craplcr(rw_craplcr.cdlcremp).dslcremp := rw_craplcr.dslcremp;
        
      END LOOP;

      -- Criar o XML para envio das informações
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz><emprestimos>');

      -- Leitura inicial dos empréstimos
      FOR rw_crapepr IN cr_crapepr LOOP

        IF vr_tab_craplcr(rw_crapepr.cdlcremp).dsoperac = 'FINANCIAMENTO' THEN
          vr_tpoperac := 1;
        ELSE
          vr_tpoperac := 2;
        END IF;

        vr_idxger := vr_tpoperac ||
                     lpad(rw_crapepr.tpemprst,5,0)||
                     lpad(rw_crapepr.cdagenci,5,0);

        BEGIN
          -- Verificar se ainda não foi criado o resumo para o PAC atual
          IF NOT vr_tab_resumo.EXISTS(vr_idxger) THEN
            -- Inicializa os contadores
            vr_tab_resumo(vr_idxger).qtdsocio := 0;
            vr_tab_resumo(vr_idxger).qtdcrtos := 0;
            vr_tab_resumo(vr_idxger).vljurmes := 0;
            vr_tab_resumo(vr_idxger).vlpresta := 0;
            vr_tab_resumo(vr_idxger).vlsaldev := 0;
            vr_tab_resumo(vr_idxger).tpoperac := vr_tpoperac;
            vr_tab_resumo(vr_idxger).tpemprst := rw_crapepr.tpemprst;
            vr_tab_resumo(vr_idxger).cdagenci := rw_crapepr.cdagenci;
            vr_tab_resumo(vr_idxger).dsoperac := vr_tab_craplcr(rw_crapepr.cdlcremp).dsoperac;

            IF rw_crapepr.tpemprst = 0 THEN
              vr_tab_resumo(vr_idxger).dsemprst := 'TR';
            ELSIF rw_crapepr.tpemprst = 1 THEN
              vr_tab_resumo(vr_idxger).dsemprst := 'PP';
            ELSIF rw_crapepr.tpemprst = 2 THEN
              vr_tab_resumo(vr_idxger).dsemprst := 'POS';
            END IF;

          END IF;

          -- Se o saldo devedor do empréstimos estiver zerado iremos acumular
          -- apenas os juros do mês e não listar o empréstimo no relatório
          IF rw_crapepr.vlsdeved = 0 THEN
            -- Apenas acumular
            vr_tab_resumo(vr_idxger).vljurmes := vr_tab_resumo(vr_idxger).vljurmes
                                                            +  rw_crapepr.vljurmes;
            -- Ir ao próximo
            RAISE vr_exc_next;
          END IF;

          /* Para contador de associados por Produto, tipo de operacao e PAC */
          vr_idxcta := vr_tpoperac ||
                     lpad(rw_crapepr.tpemprst,5,0)||
                     lpad(rw_crapepr.cdagenci,5,0)||
                     lpad(rw_crapepr.nrdconta,10,0);

          /* Se este cooperado nao foi contado ainda, somar + 1 */
          IF NOT vr_tab_ctager.exists(vr_idxcta) THEN
            vr_tab_resumo(vr_idxger).qtdsocio := vr_tab_resumo(vr_idxger).qtdsocio + 1;
            /* Incluir o cooperado na temp-table para controle */
            vr_tab_ctager(vr_idxcta) := 1;
          END IF;

          -- Se não existir informação de linha de crédito para a linha atual
          IF NOT vr_tab_craplcr.EXISTS(rw_crapepr.cdlcremp) THEN
            vr_dscritic := 'Linha de crédito '||rw_crapepr.cdlcremp||' não cadastrada!';
            RAISE vr_exc_erro;
          END IF;
          
          vr_dspesqui := SUBSTR(vr_tab_craplcr(rw_crapepr.cdlcremp).dslcremp,1,31);
          /*
          -- Montar o campo de pesquisa
          vr_dspesqui := to_char(rw_crapepr.dtmvtolt,'dd/mm/yyyy') || '-'
                      || to_char(rw_crapepr.cdagenci_epr,'fm000')  || '-'
                      || to_char(rw_crapepr.cdbccxlt,'fm000')      || '-'
                      || to_char(rw_crapepr.nrdolote,'fm000g000');
          */            
          -- Guardar os valores para listar ordenados por CONTA e CONTRATO
          vr_chave_contratos := lpad(to_char(rw_crapepr.nrdconta),10,'0') || '0' || lpad(to_char(rw_crapepr.nrctremp),10,'0');

          IF rw_crapepr.tpemprst IN (1,2) THEN -- PP ou POS
            vr_tab_contratos(vr_chave_contratos).vlsdvctr := rw_crapepr.vlsdvctr;
          ELSE
            vr_tab_contratos(vr_chave_contratos).vlsdvctr := 0;
          END IF;

          OPEN cr_crapris (pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => rw_crapepr.nrdconta,
                           pr_nrctremp => rw_crapepr.nrctremp,
                           pr_dtultdia => rw_crapdat.dtultdia);
           FETCH cr_crapris
           INTO rw_crapris;
          IF cr_crapris%NOTFOUND THEN
            vr_tab_contratos(vr_chave_contratos).vljura60 := 0;
            CLOSE cr_crapris;
          ELSE
            vr_tab_contratos(vr_chave_contratos).vljura60 := rw_crapris.vljura60;
            CLOSE cr_crapris;
          END IF;

          vr_tab_contratos(vr_chave_contratos).nrdconta := rw_crapepr.nrdconta;
          vr_tab_contratos(vr_chave_contratos).cdagenci := rw_crapepr.cdagenci;
          vr_tab_contratos(vr_chave_contratos).cdempres := vr_tab_empresa(rw_crapepr.nrdconta);
          vr_tab_contratos(vr_chave_contratos).nmprimtl := rw_crapepr.nmprimtl;
          vr_tab_contratos(vr_chave_contratos).dspessoa := rw_crapepr.dspessoa;
					vr_tab_contratos(vr_chave_contratos).dtmvtolt := rw_crapepr.dtmvtolt;
          vr_tab_contratos(vr_chave_contratos).nrctremp := rw_crapepr.nrctremp;
          vr_tab_contratos(vr_chave_contratos).dsemprst := vr_tab_resumo(vr_idxger).dsemprst;
          vr_tab_contratos(vr_chave_contratos).cdfinemp := rw_crapepr.cdfinemp;
          vr_tab_contratos(vr_chave_contratos).cdlcremp := rw_crapepr.cdlcremp;
          vr_tab_contratos(vr_chave_contratos).dspesqui := vr_dspesqui;
          vr_tab_contratos(vr_chave_contratos).vlemprst := rw_crapepr.vlemprst;
          vr_tab_contratos(vr_chave_contratos).vlpreemp := rw_crapepr.vlpreemp;
          vr_tab_contratos(vr_chave_contratos).dspresta := trim(to_char(round(rw_crapepr.qtprecal,2),'9G990D00'))|| '/'||
                                                           gene0002.fn_mask(rw_crapepr.qtpreemp,'999');
          vr_tab_contratos(vr_chave_contratos).vlsdeved := rw_crapepr.vlsdeved;
          vr_tab_contratos(vr_chave_contratos).txjurmes := vr_tab_craplcr(rw_crapepr.cdlcremp).txmensal;
          vr_tab_contratos(vr_chave_contratos).txjuremp := rw_crapepr.txjuremp;
          vr_tab_contratos(vr_chave_contratos).vljurmes := rw_crapepr.vljurmes;

          -- Sumarizar informações por PAC
          vr_tab_resumo(vr_idxger).qtdcrtos := vr_tab_resumo(vr_idxger).qtdcrtos + 1;
          vr_tab_resumo(vr_idxger).vljurmes := vr_tab_resumo(vr_idxger).vljurmes + rw_crapepr.vljurmes;
          vr_tab_resumo(vr_idxger).vlpresta := vr_tab_resumo(vr_idxger).vlpresta + rw_crapepr.vlpreemp;
          vr_tab_resumo(vr_idxger).vlsaldev := vr_tab_resumo(vr_idxger).vlsaldev + rw_crapepr.vlsdeved;
          vr_tab_resumo(vr_idxger).vlsdvctr := nvl(vr_tab_resumo(vr_idxger).vlsdvctr,0) + vr_tab_contratos(vr_chave_contratos).vlsdvctr;
          vr_tab_resumo(vr_idxger).vljura60 := nvl(vr_tab_resumo(vr_idxger).vljura60,0) + vr_tab_contratos(vr_chave_contratos).vljura60;

        EXCEPTION
          WHEN vr_exc_next THEN
            NULL; --> Apenas ignorar
        END;
      END LOOP; --> Fim Leitura empréstimos

      -- Leitura dos emprestimos BNDES
      FOR rw_crapebn IN cr_crapebn LOOP

        vr_idxger := vr_tpoperac ||
                     '00000'     || --> tpemprst
                     lpad(rw_crapebn.cdagenci,5,0);
        -- Verificar se ainda não foi criado o resumo para o PAC atual
        IF NOT vr_tab_resumo.EXISTS(vr_idxger) THEN
          -- Inicializa os contadores
          vr_tab_resumo(vr_idxger).qtdsocio := 0;
          vr_tab_resumo(vr_idxger).qtdcrtos := 0;
          vr_tab_resumo(vr_idxger).vljurmes := 0;
          vr_tab_resumo(vr_idxger).vlpresta := 0;
          vr_tab_resumo(vr_idxger).vlsaldev := 0;
          vr_tab_resumo(vr_idxger).tpoperac := vr_tpoperac;
          vr_tab_resumo(vr_idxger).tpemprst := 0;
          vr_tab_resumo(vr_idxger).cdagenci := rw_crapebn.cdagenci;
          vr_tab_resumo(vr_idxger).dsoperac := 'BNDES';
          vr_tab_resumo(vr_idxger).dsemprst := 'BNDES';
        END IF;

        /* Para contador de associados por Produto, tipo de operacao e PAC */
          vr_idxcta := vr_tpoperac ||
                       '00000'     || --> tpemprst
                       lpad(rw_crapebn.cdagenci,5,0)||
                       lpad(rw_crapebn.nrdconta,10,0);

          /* Se este cooperado nao foi contado ainda, somar + 1 */
          IF NOT vr_tab_ctager.exists(vr_idxcta) THEN
            vr_tab_resumo(vr_idxger).qtdsocio := vr_tab_resumo(vr_idxger).qtdsocio + 1;
            /* Incluir o cooperado na temp-table para controle */
            vr_tab_ctager(vr_idxcta) := 1;
          END IF;

        -- Montar o campo de pesquisa
        vr_dspesqui := to_char(rw_crapebn.dtinictr,'dd/mm/yyyy');
        vr_qtprepag := rw_crapebn.qtparctr - rw_crapebn.qtparabe;

        vr_chave_contratos := lpad(to_char(rw_crapebn.nrdconta),10,'0') || '1' || lpad(to_char(rw_crapebn.nrctremp),10,'0');

        vr_tab_contratos(vr_chave_contratos).nrdconta := rw_crapebn.nrdconta;
        vr_tab_contratos(vr_chave_contratos).cdagenci := rw_crapebn.cdagenci;
        vr_tab_contratos(vr_chave_contratos).cdempres := vr_tab_empresa(rw_crapebn.nrdconta);
        vr_tab_contratos(vr_chave_contratos).nmprimtl := rw_crapebn.nmprimtl;
        vr_tab_contratos(vr_chave_contratos).dspessoa := rw_crapebn.dspessoa;
				vr_tab_contratos(vr_chave_contratos).dtmvtolt := rw_crapebn.dtlibera;
        vr_tab_contratos(vr_chave_contratos).nrctremp := rw_crapebn.nrctremp;
        vr_tab_contratos(vr_chave_contratos).cdfinemp := '   ';
        vr_tab_contratos(vr_chave_contratos).cdlcremp := 'BNDES';
        vr_tab_contratos(vr_chave_contratos).dspresta := trim(to_char(round(vr_qtprepag,2),'9G999D99'))|| '/'||
                                                         gene0002.fn_mask(rw_crapebn.qtparctr,'999');
        vr_tab_contratos(vr_chave_contratos).dspesqui := to_char(vr_dspesqui);
        vr_tab_contratos(vr_chave_contratos).vlemprst := to_char(rw_crapebn.vlropepr);
        vr_tab_contratos(vr_chave_contratos).vlpreemp := to_char(rw_crapebn.vlparepr);
        vr_tab_contratos(vr_chave_contratos).vlsdeved := to_char(rw_crapebn.vlsdeved);
        vr_tab_contratos(vr_chave_contratos).txjurmes := 0;
        vr_tab_contratos(vr_chave_contratos).txjuremp := 0;
        vr_tab_contratos(vr_chave_contratos).vljurmes := 0;

        -- Sumarizar informações por PAC
        vr_tab_resumo(vr_idxger).qtdcrtos := vr_tab_resumo(vr_idxger).qtdcrtos + 1;
        vr_tab_resumo(vr_idxger).vlpresta := vr_tab_resumo(vr_idxger).vlpresta + rw_crapebn.vlparepr;
        vr_tab_resumo(vr_idxger).vlsaldev := vr_tab_resumo(vr_idxger).vlsaldev + rw_crapebn.vlsdeved;

      END LOOP; --> Fim da leitura de emprestimos BNDES
       vr_chave_contratos := vr_tab_contratos.FIRST;

      -- Criar XML dos contratos
      LOOP

        EXIT WHEN NOT vr_tab_contratos.EXISTS(vr_chave_contratos);

        -- Enviar tag para o relatório
        pc_escreve_xml('<empresti>'
                     ||'  <nrdconta>'||ltrim(gene0002.fn_mask_conta(vr_tab_contratos(vr_chave_contratos).nrdconta))||'</nrdconta>'||chr(13)
                     ||'  <cdagenci>'||vr_tab_contratos(vr_chave_contratos).cdagenci||'</cdagenci>'||chr(13)
                     ||'  <cdempres>'||vr_tab_empresa(vr_tab_contratos(vr_chave_contratos).nrdconta)||'</cdempres>'||chr(13)
                     ||'  <nmprimtl>'||substr(vr_tab_contratos(vr_chave_contratos).nmprimtl,1,28)||'</nmprimtl>'||chr(13)
                     ||'  <dspessoa>'||vr_tab_contratos(vr_chave_contratos).dspessoa||'</dspessoa>'||chr(13)										 
                     ||'  <dtmvtolt>'||to_char(vr_tab_contratos(vr_chave_contratos).dtmvtolt,'dd/mm/rrrr')||'</dtmvtolt>'||chr(13)										 																				 
                     ||'  <nrctremp>'||gene0002.fn_mask(vr_tab_contratos(vr_chave_contratos).nrctremp,'zz.zzz.zz9')||'</nrctremp>'||chr(13)
                     ||'  <dsemprst>'||vr_tab_contratos(vr_chave_contratos).dsemprst||'</dsemprst>'||chr(13)
                     ||'  <cdfinemp>'||vr_tab_contratos(vr_chave_contratos).cdfinemp||'</cdfinemp>'||chr(13)
                     ||'  <cdlcremp>'||vr_tab_contratos(vr_chave_contratos).cdlcremp||'</cdlcremp>'||chr(13)
                     ||'  <dspesqui>'||vr_tab_contratos(vr_chave_contratos).dspesqui||'</dspesqui>'||chr(13)
                     ||'  <vlemprst>'||to_char(vr_tab_contratos(vr_chave_contratos).vlemprst,'fm999g999g999g990d00')||'</vlemprst>'||chr(13)
                     ||'  <vlpreemp>'||to_char(vr_tab_contratos(vr_chave_contratos).vlpreemp,'fm999g999g999g990d00')||'</vlpreemp>'||chr(13)
                     ||'  <dspresta>'||vr_tab_contratos(vr_chave_contratos).dspresta||'</dspresta>'||chr(13)
                     ||'  <vlsdvctr>'||to_char(vr_tab_contratos(vr_chave_contratos).vlsdvctr,'fm999g999g999g990d00')||'</vlsdvctr>'||chr(13)
                     ||'  <vlsdeved>'||to_char(vr_tab_contratos(vr_chave_contratos).vlsdeved,'fm999g999g999g990d0099999999')||'</vlsdeved>'||chr(13)
                     ||'  <txjurmes>'||to_char(vr_tab_contratos(vr_chave_contratos).txjurmes,'fm990d000000')||'%'||'</txjurmes>'||chr(13)
                     ||'  <txjuremp>'||to_char(vr_tab_contratos(vr_chave_contratos).txjuremp,'fm0d0000000')||'</txjuremp>'||chr(13)
                     ||'  <vljurmes>'||to_char(vr_tab_contratos(vr_chave_contratos).vljurmes,'fm999g999g999g990d00')||'</vljurmes>'||chr(13)
                     ||'  <vljura60>'||to_char(vr_tab_contratos(vr_chave_contratos).vljura60,'fm999g999g999g990d00')||'</vljura60>'||chr(13)
                     ||'</empresti>'||chr(13));

        vr_chave_contratos := vr_tab_contratos.NEXT(vr_chave_contratos);

      END LOOP;

      -- Encerramos a tag agrupadora de empréstimo e iniciamos a de resumo
      pc_escreve_xml('</emprestimos><resumo_pac>'||chr(13));

      -- Varrer a temp-table de resumo para enviar as informações agrupadas por pac
      IF vr_tab_resumo.count > 0 THEN
        vr_idxger := vr_tab_resumo.FIRST;

        LOOP
          EXIT WHEN vr_idxger IS NULL;
          -- Se existir nesta posição e a quantidade de associados for superior a 0
          IF vr_tab_resumo.EXISTS(vr_idxger) AND vr_tab_resumo(vr_idxger).qtdsocio > 0 THEN
            -- Buscar o nome por extenso da agência
            OPEN cr_crapage(pr_cdagenci => vr_tab_resumo(vr_idxger).cdagenci);
            FETCH cr_crapage
             INTO vr_nmextage;
            CLOSE cr_crapage;

            IF vr_tab_resumo.FIRST = vr_idxger OR
               (vr_tab_resumo(vr_idxger).tpemprst <> vr_tab_resumo(vr_tab_resumo.PRIOR(vr_idxger)).tpemprst or
                vr_tab_resumo(vr_idxger).dsoperac <> vr_tab_resumo(vr_tab_resumo.PRIOR(vr_idxger)).dsoperac) THEN
              IF vr_tab_resumo.FIRST <> vr_idxger THEN
                pc_escreve_xml('</tipo>');
              END IF;
              pc_escreve_xml('<tipo dsoperac="'||vr_tab_resumo(vr_idxger).dsoperac||'"'||
                                   ' dsemprst="'||vr_tab_resumo(vr_idxger).dsemprst||'">
                             '||chr(13));
            END IF;

            -- Adicionar o nó resumo ao XML
            pc_escreve_xml('<pac>'
                         ||'  <nmextage>'||substr(vr_tab_resumo(vr_idxger).cdagenci||' - '||vr_nmextage,1,30)||'</nmextage>'||chr(13)
                         ||'  <qtdsocio>'||to_char(vr_tab_resumo(vr_idxger).qtdsocio,'fm999g999g999g990')||'</qtdsocio>'||chr(13)
                         ||'  <qtdcrtos>'||to_char(vr_tab_resumo(vr_idxger).qtdcrtos,'fm999g999g999g990')||'</qtdcrtos>'||chr(13)
                         ||'  <vljurmes>'||to_char(vr_tab_resumo(vr_idxger).vljurmes,'fm999g999g999g990d00')||'</vljurmes>'||chr(13)
                         ||'  <vlpresta>'||to_char(vr_tab_resumo(vr_idxger).vlpresta,'fm999g999g999g990d00')||'</vlpresta>'||chr(13)
                         ||'  <vlsaldev>'||to_char(vr_tab_resumo(vr_idxger).vlsaldev,'fm999g999g999g990d0099999999')||'</vlsaldev>'||chr(13)
                         ||'  <vlsdvctr>'||to_char(vr_tab_resumo(vr_idxger).vlsdvctr,'fm999g999g999g990d00')||'</vlsdvctr>'||chr(13)
                         ||'  <vljura60>'||to_char(vr_tab_resumo(vr_idxger).vljura60,'fm999g999g999g990d00')||'</vljura60>'||chr(13)
                         ||'</pac>'||chr(13));
          END IF;
          vr_idxger := vr_tab_resumo.NEXT(vr_idxger);
        END LOOP;
        pc_escreve_xml('</tipo>');
      END IF;

      -- Encerrar a tag resumo e raiz ainda aberta
      pc_escreve_xml('</resumo_pac></raiz>');

      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl');     --> Utilizaremos o rl

      -- Busca o diretorio micros contab
      vr_nom_dirmic := GENE0001.fn_diretorio(pr_tpdireto => 'M' --> /micros
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'contab');
																						
      -- Submeter o relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'                              --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl251.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/crrl251.lst'        --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_dspathcop => vr_nom_dirmic                        --> Copiar para a Micros
                                 ,pr_fldoscop  => 'S'                                  --> Efetuar cópia com Ux2Dos
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '234dh'                              --> Usar duplex horizontal
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_parser    => 'D'                                  --> Metodo de parrser do XML
                                 ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_erro;
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

      WHEN vr_exc_erro THEN
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
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps299;
/

