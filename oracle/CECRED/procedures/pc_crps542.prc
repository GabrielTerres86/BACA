CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS542 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                          ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                          ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                          ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

       Programa: pr_crps542 (Antigo Fontes/crps542.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Elton
       Data    : Novembro/2009.                  Ultima atualizacao: 08/06/2015

       Dados referentes ao programa:

       Frequencia: Mensal.
       Objetivo  : Solicitacao: 004.
                   Emitir o acompanhamento das operacoes de microcredito.
                   Emite relatorio 528.

       Alteracoes:  11/05/2010 - Remover flgstlcr da busca de dados da LCR
                                (Guilherme/Supero)

                    12/03/2012 - Declarado variaveis necessarias para utilizacao
                                 da include lelem.i (Tiago).

                    30/04/2012 - Substituido qtprepag por qtprecal (Irlan).

                    27/05/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                    09/08/2013 - Troca da busca do mes por extenso com to_char para
                                 utilizarmos o vetor gene0001.vr_vet_nmmesano (Marcos-Supero)
                                 
                    16/06/2014 - Alterar cdlcremp de 3 posições para 4 Softdesk 137074 (Lucas R.)
                    
                    24/10/2014 - Correção na procedure pc_init_tab_prazos pois o indice das posições 
                                 13 e 14 estavam errados para o campo qtmmpraz.
                                 A definição das variaveis vr_vlemprst e vr_ematraso foi modificada
                                 para number(18,2) para evitar problema de arredondamento no crrl528.

                    08/06/2015 - #273450 Ajuste das definições de tipo number para conterem 8 casas 
                                 decimais, aumentando assim a precisão dos cálculos;
                                 Remoção de variável não utilizada no procedimento pc_escreve_clob (Carlos)
                                 
                    13/11/2018 -  Caso não forem encontrados os dados da empresa, atribuir zero e continuar 
                                  a execução, pois na rotina que efetua o cálculo do empréstimo será ignorada 
                                  essa informação e utilizará a data de vencimento original da parcela 
                                  (PRB0040215 - Kelvin)
    ............................................................................ */

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

      -- Busca dos empréstimos de micro-crédito
      CURSOR cr_crapepr IS
        SELECT epr.nrdconta
              ,epr.nrctremp
              ,epr.inliquid
              ,epr.qtpreemp
              ,epr.qtprecal
              ,epr.vlsdeved
              ,epr.dtmvtolt
              ,epr.inprejuz
              ,epr.txjuremp
              ,epr.vljuracu
              ,epr.dtdpagto
              ,epr.flgpagto
              ,epr.qtmesdec
              ,epr.vlpreemp
              ,epr.cdlcremp
              ,epr.qtprepag
              ,epr.dtultpag
              ,lcr.dslcremp
              ,lcr.txdiaria
              ,ROW_NUMBER () OVER (PARTITION BY epr.cdlcremp
                                       ORDER BY epr.cdlcremp) sqatureg
              ,COUNT(1) OVER (PARTITION BY epr.cdlcremp) qtregtot
          FROM craplcr lcr
              ,crapepr epr
         WHERE epr.cdcooper = lcr.cdcooper
           AND epr.cdlcremp = lcr.cdlcremp
           AND epr.cdcooper = pr_cdcooper --> Coop conectada
           AND epr.vlsdeved > 0    --> Ainda possua saldo devedor
           AND lcr.cdusolcr = 1           --> Micro Credito
         ORDER BY lcr.cdlcremp;

      -- Buscar dados do cadastro complementar de empréstimo
      CURSOR cr_crawepr(pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT dtdpagto
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

      ------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Definição de temp table para armazenar os valores e quantidades
      -- conforme a quantidade de meses pendentes do empréstimo
      TYPE typ_reg_prazos IS
        RECORD(qtddpraz PLS_INTEGER
              ,qtmmpraz PLS_INTEGER
              ,vldivida NUMBER(18,8)
              ,qtempres PLS_INTEGER);
      TYPE typ_tab_prazos IS
        TABLE OF typ_reg_prazos
          INDEX BY PLS_INTEGER; --> A chave será a quantidade de meses
      -- Instanciamos dois vetores, um para PNMPO e outro para o livre
      vr_tab_prazo_pmnpo typ_tab_prazos;
      vr_tab_prazo_livre typ_tab_prazos;

      ----------------------------- VARIAVEIS ------------------------------
      vr_qtpreres PLS_INTEGER;  -- Qtde parcelas pendentes
      vr_vlmensal NUMBER(18,8); -- Valor pendente proporcional aos meses pendentes

      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros
      vr_exc_erro exception;
      vr_exc_pula exception;

      -- Variáveis auxiliares ao processo
      vr_dstextab craptab.dstextab%TYPE;      --> Busca na craptab
      vr_inusatab BOOLEAN;                    --> Indicador S/N de utilização de tabela de juros
      vr_vlsdeved NUMBER(18,8);                     --> Saldo devedor do empréstimo
      vr_vlratras NUMBER;                     --> Saldo a regularizar do empréstimo
      vr_qtprecal crapepr.qtprecal%TYPE;      --> Quantidade de parcelas do empréstimo
      vr_dtinipag DATE;                       --> Data de início de pagamento do empréstimo
      vr_qtmesdec crapepr.qtmesdec%TYPE;      --> Qtde de meses decorridos do empréstimo
      vr_vlemprst NUMBER(18,8);                     --> Acumulador do valor por linha de crédito
      vr_ematraso NUMBER(18,8);                     --> Acumulador do valor em atraso por linha de crédito
      vr_peratras NUMBER;                     --> Percentual em atraso por linha de crédito
      vr_vlacumul NUMBER;                     --> Valor para acumulo
      vr_dsdprazo VARCHAR2(30);               --> Descrição genérica para os prazos

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
      vr_vldescto     NUMBER(18,6);


      -- Variaveis para os XMLs e relatórios
      vr_clobxml    CLOB;                   -- Clob para conter o XML de dados
      vr_nom_direto VARCHAR2(200);          -- Diretório para gravação do arquivo

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

      -- Subrotina para inicializar os vetores de prazos / valores
      PROCEDURE pc_init_tab_prazos(pr_tab_prazo OUT typ_tab_prazos) IS
      BEGIN
        --
        pr_tab_prazo(01).qtddpraz := 90;
        pr_tab_prazo(01).qtmmpraz := 0;
        pr_tab_prazo(01).vldivida := 0;
        pr_tab_prazo(01).qtempres := 0;
        --
        pr_tab_prazo(02).qtddpraz := 180;
        pr_tab_prazo(02).qtmmpraz := 3;
        pr_tab_prazo(02).vldivida := 0;
        pr_tab_prazo(02).qtempres := 0;
        --
        pr_tab_prazo(03).qtddpraz := 270;
        pr_tab_prazo(03).qtmmpraz := 6;
        pr_tab_prazo(03).vldivida := 0;
        pr_tab_prazo(03).qtempres := 0;
        --
        pr_tab_prazo(04).qtddpraz := 360;
        pr_tab_prazo(04).qtmmpraz := 9;
        pr_tab_prazo(04).vldivida := 0;
        pr_tab_prazo(04).qtempres := 0;
        --
        pr_tab_prazo(05).qtddpraz := 720;
        pr_tab_prazo(05).qtmmpraz := 12;
        pr_tab_prazo(05).vldivida := 0;
        pr_tab_prazo(05).qtempres := 0;
        --
        pr_tab_prazo(06).qtddpraz := 1080;
        pr_tab_prazo(06).qtmmpraz := 24;
        pr_tab_prazo(06).vldivida := 0;
        pr_tab_prazo(06).qtempres := 0;
        --
        pr_tab_prazo(07).qtddpraz := 1440;
        pr_tab_prazo(07).qtmmpraz := 36;
        pr_tab_prazo(07).vldivida := 0;
        pr_tab_prazo(07).qtempres := 0;
        --
        pr_tab_prazo(08).qtddpraz := 1800;
        pr_tab_prazo(08).qtmmpraz := 48;
        pr_tab_prazo(08).vldivida := 0;
        pr_tab_prazo(08).qtempres := 0;
        --
        pr_tab_prazo(09).qtddpraz := 2160;
        pr_tab_prazo(09).qtmmpraz := 60;
        pr_tab_prazo(09).vldivida := 0;
        pr_tab_prazo(09).qtempres := 0;
        --
        pr_tab_prazo(10).qtddpraz := 2520;
        pr_tab_prazo(10).qtmmpraz := 72;
        pr_tab_prazo(10).vldivida := 0;
        pr_tab_prazo(10).qtempres := 0;
        --
        pr_tab_prazo(11).qtddpraz := 2880;
        pr_tab_prazo(11).qtmmpraz := 84;
        pr_tab_prazo(11).vldivida := 0;
        pr_tab_prazo(11).qtempres := 0;
        --
        pr_tab_prazo(12).qtddpraz := 3240;
        pr_tab_prazo(12).qtmmpraz := 96;
        pr_tab_prazo(12).vldivida := 0;
        pr_tab_prazo(12).qtempres := 0;
        --
        pr_tab_prazo(13).qtddpraz := 3600;
        pr_tab_prazo(13).qtmmpraz := 108;    
        pr_tab_prazo(13).vldivida := 0;
        pr_tab_prazo(13).qtempres := 0;
        --
        pr_tab_prazo(14).qtddpraz := 3600;
        pr_tab_prazo(14).qtmmpraz := 120;     
        pr_tab_prazo(14).vldivida := 0;
        pr_tab_prazo(14).qtempres := 0;
      END;

      -- Subrotina para acumular nos vetores o valor conforme o prazo passado
      PROCEDURE pc_acumula_retorno(pr_qtpreres  IN PLS_INTEGER
                                  ,pr_vlmensal  IN NUMBER
                                  ,pr_vlsaldev  IN NUMBER
                                  ,pr_tab_prazo IN OUT NOCOPY typ_tab_prazos) IS
        -- Valor temporario da dívida e saldo devedor
        vr_vldivida NUMBER(18,8);
        vr_vlsaldev NUMBER(18,8);
        -- Quantidade temporária de meses
        vr_qtpreres PLS_INTEGER;
      BEGIN
        -- Copiar o valor do parâmetro para a variavel local
        -- pois a mesma será decrementada para gravação em todos os
        -- prazos equivalentes
        vr_qtpreres := pr_qtpreres;
        -- Copiar também o salvo devedor inicial pois o mesmo também será alterado
        vr_vlsaldev := pr_vlsaldev;
        -- Efetuar um laço de 1 a 14 para que a quantidade seja
        -- copiada para cada com prazo inferior a quantidade calculada
        FOR vr_ind IN REVERSE 1..14 LOOP
          -- Se a quantidade de meses temporaria for superior a do prazo atual
          IF vr_qtpreres > pr_tab_prazo(vr_ind).qtmmpraz THEN
            -- Para o primeiro prazo
            IF vr_ind = 1 THEN
              -- Simplesmente assumir o saldo devedor
              vr_vldivida := vr_vlsaldev;
              -- Limpar o saldo devedor
              vr_vlsaldev := 0;
            ELSE
              -- Calcular valor da dívida diminuindo a quantidade de meses do prazo atual
              vr_vldivida := (pr_vlmensal * (vr_qtpreres - pr_tab_prazo(vr_ind).qtmmpraz));
              -- Decrementar do saldo devedor
              vr_vlsaldev := vr_vlsaldev - vr_vldivida;
            END IF;
            -- Incrementar o valor da dívida na posição atual
            pr_tab_prazo(vr_ind).vldivida := pr_tab_prazo(vr_ind).vldivida + vr_vldivida;
            -- Incrementar a quantidade de empréstimo no prazo
            pr_tab_prazo(vr_ind).qtempres := pr_tab_prazo(vr_ind).qtempres + 1;
            -- Substituir a variavel temporária com o prazo atual
            -- para que dessa forma todos os prazos inferiores também
            -- tenham o valor armazenado
            vr_qtpreres := pr_tab_prazo(vr_ind).qtmmpraz;
          END IF;
        END LOOP;
      END;

    BEGIN
      -- Código do programa
      vr_cdprogra := 'CRPS542';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS542'
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
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
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
        RAISE vr_exc_erro;
      END IF;

      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se encontrar
      IF trim(vr_dstextab) IS NOT NULL THEN
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

      -- Incializar os vetores de valores por prazo
      pc_init_tab_prazos(vr_tab_prazo_pmnpo);
      pc_init_tab_prazos(vr_tab_prazo_livre);

      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz><linhas_cred>');

      -- Busca dos empréstimos de micro-crédito
      FOR rw_crapepr IN cr_crapepr LOOP
        -- Para o primeiro registro da linha de crédito
        IF rw_crapepr.sqatureg = 1 THEN
          -- Inicializar os contadores por linha de crédito
          vr_vlemprst := 0;
          vr_ematraso := 0;
        END IF;
        -- Criar bloco para tratar desvio de fluxo (next record)
        BEGIN
          -- Para empréstimos ativo
          IF rw_crapepr.inliquid = 0 THEN
            -- Calcular quantidade pedente com base nas parcelas totais - calculadas
            vr_qtpreres := rw_crapepr.qtpreemp - rw_crapepr.qtprecal;
            -- Garantir que o valor não fique negativo ou zerado
            vr_qtpreres := ABS(vr_qtpreres);
            IF vr_qtpreres = 0 THEN
              vr_qtpreres := 1;
            END IF;
            -- Calcular valor mensal pendente proporcionalmente ao saldo devedor e meses pendentes
            vr_vlmensal := rw_crapepr.vlsdeved / vr_qtpreres;
            -- Verificar retorno dos empréstimos conforme a linha de crédito
            IF rw_crapepr.dslcremp LIKE '%PNMPO%'
            OR rw_crapepr.dslcremp LIKE '%BNDES%'
            OR rw_crapepr.dslcremp LIKE '%BB%' THEN
              -- Acumulo específico PNMPO/BNDES
              pc_acumula_retorno(pr_qtpreres  => vr_qtpreres
                                ,pr_vlmensal  => vr_vlmensal
                                ,pr_vlsaldev  => rw_crapepr.vlsdeved
                                ,pr_tab_prazo => vr_tab_prazo_pmnpo);
            ELSE
              -- Acumulo no livre
              pc_acumula_retorno(pr_qtpreres => vr_qtpreres
                                ,pr_vlmensal => vr_vlmensal
                                ,pr_vlsaldev => rw_crapepr.vlsdeved
                                ,pr_tab_prazo => vr_tab_prazo_livre);
            END IF;
          END IF;
          -- Se for um contrato do mês com prejuízo
          IF trunc(rw_crapepr.dtmvtolt,'mm') = trunc(rw_crapdat.dtmvtolt,'mm') AND rw_crapepr.inprejuz > 0 THEN
            -- Desconsiderar prejuizo
            RAISE vr_exc_pula;
          END IF;
          
          -- Buscar a configuração de empréstimo cfme a empresa da conta
          empr0001.pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper         --> Código da Cooperativa
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data atual
                                             ,pr_nrdconta => rw_crapepr.nrdconta --> Numero da conta do empréstimo
                                             ,pr_dtcalcul => vr_tab_dtcalcul  --> Data calculada de pagamento
                                             ,pr_diapagto => vr_tab_diapagto  --> Dia de pagamento das parcelas
                                             ,pr_flgfolha => vr_tab_flgfolha  --> Flag de desconto em folha S/N
                                             ,pr_ddmesnov => vr_tab_ddmesnov  --> Configuração para mês novo
                                             ,pr_cdcritic => pr_cdcritic      --> Código do erro
                                             ,pr_des_erro => pr_dscritic);    --> Retorno de Erro
          -- Se houve erro na rotina
          IF pr_dscritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN  
            /*******************Kelvin/Rodrigo******************************************
            Caso não forem encontrados os dados da empresa, atribuir zero e continuar 
            a execução, pois na rotina que efetua o cálculo do empréstimo será ignorada 
            essa informação e utilizará a data de vencimento original da parcela.
            ***************************************************************************/
            pr_cdcritic := NULL;        
            pr_dscritic := NULL; 
            vr_tab_diapagto := 0;
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
            vr_txdjuros := rw_crapepr.txdiaria;
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
                                 ,pr_diapagto    => vr_tab_diapagto
                                 ,pr_txdjuros    => vr_txdjuros
                                 ,pr_qtprepag    => vr_qtprepag
                                 ,pr_qtprecal    => vr_qtprecal_lem
                                 ,pr_vlprepag    => vr_vlprepag
                                 ,pr_vljuracu    => vr_vljuracu
                                 ,pr_vljurmes    => vr_vljurmes
                                 ,pr_vlsdeved    => vr_vlsdeved
                                 ,pr_dtultpag    => vr_dtultpag
                                 ,pr_cdcritic    => pr_cdcritic
                                 ,pr_des_erro    => pr_dscritic);
          -- Se a rotina retornou com erro
          IF pr_dscritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_erro;
          END IF;
          -- Se o empréstimo não estiver ativo
          IF rw_crapepr.inliquid = 0 THEN
            -- Acumular a quantidade calculada
            vr_qtprecal := vr_qtprecal + vr_qtprecal_lem;
          END IF;
          -- Verificar se existe cadastro complementar de empréstimo
          OPEN cr_crawepr(pr_nrdconta => rw_crapepr.nrdconta
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
              vr_vlratras := (vr_qtmesdec - vr_qtprecal) * rw_crapepr.vlpreemp;
            ELSE
              -- Não há atraso
              vr_vlratras := 0;
            END IF;
          END IF;
          -- Se a Qtde de meses decorridos for superior a qtde de parcelas do empréstimo
          -- OU Se o valor do atraso for superior ao devedor
          IF vr_qtmesdec > rw_crapepr.qtpreemp OR vr_vlratras > vr_vlsdeved THEN
            -- Considerar como atraso o saldo devedor calculado
            vr_vlratras := vr_vlsdeved;
          END IF;
          -- Garantir que o valor do atraso não seja negativo
          IF vr_vlratras < 0 THEN
            vr_vlratras := 0;
          END IF;
          -- Sumarizar os valores calculados para a linha de crédito
          vr_vlemprst := vr_vlemprst + rw_crapepr.vlsdeved;
          vr_ematraso := vr_ematraso + vr_vlratras;
        EXCEPTION
          WHEN vr_exc_pula THEN
            -- Apensar ignorar e processar o próximo registro
            null;
        END;
        -- Para o ultimo registro da linha de crédito
        IF rw_crapepr.sqatureg = rw_crapepr.qtregtot THEN
          -- Calcular o % em atraso para a linha
          IF vr_vlemprst <> 0 THEN
            vr_peratras := (100 * vr_ematraso) / vr_vlemprst;
          ELSE
            vr_peratras := 0;
          END IF;
          -- Enviar a tag com os valores da linha de crédito atual
          pc_escreve_clob(vr_clobxml,'<linha id="'||rw_crapepr.cdlcremp||'">'
                                   ||'  <dslcremp>'||substr(lpad(rw_crapepr.cdlcremp,4,' ')||'-'||rw_crapepr.dslcremp,1,31)||'</dslcremp>'
                                   ||'  <vldivida>'||to_char(vr_vlemprst,'fm999g999g999g990d00')||'</vldivida>'
                                   ||'  <vlatraso>'||to_char(vr_ematraso,'fm999g999g999g990d00')||'</vlatraso>'
                                   ||'  <peratras>'||to_char(vr_peratras,'fm999g999g999g990d00')||'</peratras>'
                                   ||'</linha>');
        END IF;
      END LOOP;
      -- Finalizar o nó das linhas de crédito e inicializar o de prazos
      pc_escreve_clob(vr_clobxml,'</linhas_cred><prazos dstitulo="Microcredito Livre">');
      -- Varrer o vetor com os valores por microcredito livre
      vr_vlacumul := 0;
      FOR vr_ind IN 1..14 LOOP
        -- Somente no ultimo prazo
        IF vr_ind = 14 THEN
          -- Utilizar mais de
          vr_dsdprazo := 'MAIS DE';
        ELSE
          -- Utilizar até
          vr_dsdprazo := 'ATE';
        END IF;
        -- Se não houver divida no prazo atual
        IF vr_tab_prazo_livre(vr_ind).vldivida = 0 THEN
          -- Zerar o acumulador pois não existe mais valores nos próximos prazos
          vr_vlacumul := 0;
        ELSE
          -- Acumular o valor total
          vr_vlacumul := vr_vlacumul + vr_tab_prazo_livre(vr_ind).vldivida;
        END IF;
        -- Para cada prazo, enviá-lo, juntamente com seu valor acumulado
        pc_escreve_clob(vr_clobxml,'<prazo id="'||vr_ind||'">'
                                   ||'  <dsddpraz>'||vr_dsdprazo||' '||vr_tab_prazo_livre(vr_ind).qtddpraz||' DIAS</dsddpraz>'
                                   ||'  <vldivida>'||to_char(vr_tab_prazo_livre(vr_ind).vldivida,'fm999g999g999g990d00')||'</vldivida>'
                                   ||'  <vlacumul>'||to_char(vr_vlacumul,'fm999g999g999g990d00')||'</vlacumul>'
                                   ||'  <qtempres>'||to_char(vr_tab_prazo_livre(vr_ind).qtempres,'fm999g999g999g990')||'</qtempres>'
                                   ||'</prazo>');
      END LOOP;
      -- Fechar prazos livre e iniciar PNMPO
      pc_escreve_clob(vr_clobxml,'</prazos><prazos dstitulo="Microcredito PNMPO/BNDES">');
      -- Varrer o vetor com os valores por microcredito PNMPO
      vr_vlacumul := 0;
      FOR vr_ind IN 1..14 LOOP
        -- Somente no ultimo prazo
        IF vr_ind = 14 THEN
          -- Utilizar mais de
          vr_dsdprazo := 'MAIS DE';
        ELSE
          -- Utilizar até
          vr_dsdprazo := 'ATE';
        END IF;
        -- Se não houver divida no prazo atual
        IF vr_tab_prazo_pmnpo(vr_ind).vldivida = 0 THEN
          -- Zerar o acumulador pois não existe mais valores nos próximos prazos
          vr_vlacumul := 0;
        ELSE
          -- Acumular o valor total
          vr_vlacumul := vr_vlacumul + vr_tab_prazo_pmnpo(vr_ind).vldivida;
        END IF;
        -- Para cada prazo, enviá-lo, juntamente com seu valor acumulado
        pc_escreve_clob(vr_clobxml,'<prazo id="'||vr_ind||'">'
                                   ||'  <dsddpraz>'||vr_dsdprazo||' '||vr_tab_prazo_livre(vr_ind).qtddpraz||' DIAS</dsddpraz>'
                                   ||'  <vldivida>'||to_char(vr_tab_prazo_pmnpo(vr_ind).vldivida,'fm999g999g999g990d00')||'</vldivida>'
                                   ||'  <vlacumul>'||to_char(vr_vlacumul,'fm999g999g999g990d00')||'</vlacumul>'
                                   ||'  <qtempres>'||to_char(vr_tab_prazo_pmnpo(vr_ind).qtempres,'fm999g999g999g990')||'</qtempres>'
                                   ||'</prazo>');
      END LOOP;
      -- Finalizar o nó raiz e de prazos
      pc_escreve_clob(vr_clobxml,'</prazos></raiz>');
      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper);
      
      
      -- Submeter o relatório 528      
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'                              --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl528.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => 'PR_MESREF##'||gene0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt,'MM'))||'/'||to_char(rw_crapdat.dtmvtolt,'rrrr') --> Mês base
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl528.lst'     --> Arquivo final com o path
                                 ,pr_qtcoluna  => 80                                   --> 80 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => pr_dscritic);                        --> Saída com erro
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);
      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
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
      WHEN vr_exc_erro THEN
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

  END pc_crps542;
/
