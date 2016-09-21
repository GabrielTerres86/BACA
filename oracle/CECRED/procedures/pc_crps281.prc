CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS281" (pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS            --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps281 (Antigo Fontes/crps281.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Marco/2000.                         Ultima atualizacao: 23/07/2013

       Dados referentes ao programa:

       Frequencia: Mensal (Batch)
       Objetivo  : Calculo mensal da provisao de juros sobre o capital.
                   Atende a solicitacao 018. Emite relatorio 228.

       Alteracoes: 03/02/2004 - Calcular a previa para os 12 meses (Edson).


                   16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   14/02/2011 - Inclusao do calculo da remuneracao do capital
                                atraves da media. (Fabricio)

                   01/08/2011 - Alterado o format do campo que totaliza os saldos
                                medios (Henrique)

                   02/01/2012 - Alterado o Format "zzz,zzz,zz9.99" para
                                "zzz,zzz,zzz,zz9.99" pois estourava o format
                                anterior (Tiago).

                   23/07/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS281';

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca do valor da moeda no dia
      CURSOR cr_crapmfx IS
        SELECT vlmoefix
          FROM crapmfx
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = rw_crapdat.dtmvtolt
           AND tpmoefix = 2; -- Ufir
      vr_vlmoefix crapmfx.vlmoefix%TYPE;

      -- Buscar os PACs para carregar a tabela
      CURSOR cr_crapage IS
        SELECT age.cdagenci
              ,age.nmresage
          FROM crapage age
         WHERE age.cdcooper = pr_cdcooper
           AND EXISTS(SELECT 1
                        FROM crapass ass
                       WHERE ass.cdcooper = age.cdcooper
                         AND ass.cdagenci = age.cdagenci);

      -- Le registro de capital e calcula juros, com quebra por PA e Conta
      CURSOR cr_crapass IS
        SELECT ass.cdagenci
              ,cot.vlcapmes##1
              ,cot.vlcapmes##2
              ,cot.vlcapmes##3
              ,cot.vlcapmes##4
              ,cot.vlcapmes##5
              ,cot.vlcapmes##6
              ,cot.vlcapmes##7
              ,cot.vlcapmes##8
              ,cot.vlcapmes##9
              ,cot.vlcapmes##10
              ,cot.vlcapmes##11
              ,cot.vlcapmes##12
          FROM crapcot cot
              ,crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND cot.cdcooper = ass.cdcooper
           AND cot.nrdconta = ass.nrdconta
           AND ass.dtelimin IS NULL -- Nao paga p/ eliminados
           -- Para associados com bloqueio, não trazer aqueles
           -- que tiverem registro de transferência efetivado
           AND (   ass.cdsitdtl NOT IN(2,4)
                OR NOT EXISTS(SELECT 1
                                FROM craptrf trf
                               WHERE trf.cdcooper = ass.cdcooper
                                 AND trf.nrdconta = ass.nrdconta
                                 AND trf.tptransa = 1
                                 AND trf.insittrs = 2)
           )
         ORDER BY ass.cdagenci
                 ,ass.nrdconta;

      ------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Tipo e tabela para armazenar as taxas de juros por mês
      TYPE typ_reg_txjurcap IS
        RECORD(txjurcap NUMBER   --> Taxa dividido por 100
              ,txjurori NUMBER); --> Taxa original
      TYPE typ_tab_txjurcap IS
        TABLE OF typ_reg_txjurcap
          INDEX BY PLS_INTEGER; -- Obs. A chave é o mês (01 a 12)
      vr_tab_txjurcap typ_tab_txjurcap;

      -- Tabela para armazenar os totais de cotas por mês
      TYPE typ_tab_vlcapmes_cotas IS
        TABLE OF NUMBER
          INDEX BY PLS_INTEGER; -- Obs. A chave é o mês (01 a 12)
      vr_tab_vlcapmes_cotas typ_tab_vlcapmes_cotas;

      -- Estrutura de registros e tabela para armazenar
      -- os valores mês a mês para cada agência dos associados
      TYPE typ_reg_valormes IS
        TABLE OF NUMBER
          INDEX BY PLS_INTEGER; --> Chave será o mês
      TYPE typ_reg_agencia IS
        RECORD(nmresage crapage.nmresage%TYPE
              ,vljurcap typ_reg_valormes    --> Subregistro com valores mês a mês dentro
              ,vlsldmed typ_reg_valormes);  --> Subregistro com valores mês a mês dentro
      TYPE typ_tab_agencia IS
        TABLE OF typ_reg_agencia
          INDEX BY PLS_INTEGER; --> Código do histórico
      vr_tab_agencia typ_tab_agencia;

      ----------------------------- VARIAVEIS ------------------------------

      -- Variáveis auxiliares ao processo
      vr_dstextab       craptab.dstextab%TYPE;  --> Busca na craptab
      vr_split_txjurcap GENE0002.typ_split;     --> Split das taxas contidas numa string separada por ;

      vr_nrcontad       PLS_INTEGER;            --> Contador auxiliar
      vr_nrmesini       PLS_INTEGER;            --> Mês de início
      vr_nrmesfim       PLS_INTEGER;            --> Mês de fim (atual)

      -- Valores auxiliares para o cálculo
      vr_vljurcap       NUMBER; -- Taxa de juros capital
      vr_vlsldmed       NUMBER; -- Valor saldo médio do registro
      vr_vljurmfx       NUMBER(18,4); -- Valor dos juros sobre o capital com base na moeda

      -- Variaveis para os XMLs e relatórios
      vr_clobxml CLOB;                  -- Clob para conter o XML de dados
      vr_nmdiret VARCHAR2(200);         -- Diretório para gravação do arquivo


      ----------------- SUBROTINAS INTERNAS --------------------

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
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

      -- Carregar meses de início e fim (atual
      vr_nrmesini := 01;
      vr_nrmesfim := to_char(rw_crapdat.dtmvtolt,'mm');

      -- Carregar taxa de juros
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'EXEJUROCAP'
                                               ,pr_tpregist => 1);
      -- Se não encontrar
      IF vr_dstextab IS NULL THEN
        -- Gerar critica 260
        pr_cdcritic := 260;
        pr_dscritic := gene0001.fn_busca_critica(260);
        RAISE vr_exc_erro;
      ELSE
        -- Remover os 5 primeiros caracteres
        vr_dstextab := SUBSTR(vr_dstextab,5,200);
        -- Separar as taxas mes a mes separadas por ;
        vr_split_txjurcap := gene0002.fn_quebra_string(vr_dstextab,';');
        -- Se foi encontrada informação na tabela
        IF vr_split_txjurcap.count > 0 THEN
          -- Itera sobre o array para buscar as taxas
          FOR vr_idx IN 1..vr_split_txjurcap.COUNT LOOP
            -- Com a informação atual, usar apenas a partir da posição 5,
            -- converter para número
            vr_tab_txjurcap(vr_idx).txjurori := gene0002.fn_char_para_number(vr_split_txjurcap(vr_idx));
            -- Depois dividir por 100 para ter o valor da taxa
            vr_tab_txjurcap(vr_idx).txjurcap := vr_tab_txjurcap(vr_idx).txjurori/100;
          END LOOP;
        ELSE
          -- Também gerar critica 260
          pr_cdcritic := 260;
          pr_dscritic := gene0001.fn_busca_critica(260);
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Buscar valor da moeda no dia
      OPEN cr_crapmfx;
      FETCH cr_crapmfx
       INTO vr_vlmoefix;
      CLOSE cr_crapmfx;

      -- Buscar os PACs para carregar a tabela
      FOR rw_crapage IN cr_crapage LOOP
        -- Carregar o nome, o restante será buscado pelos associados
        vr_tab_agencia(rw_crapage.cdagenci).nmresage := rw_crapage.nmresage;
        -- Inicializar totalizadores mês a mês
        FOR vr_cont IN 1..12 LOOP
          vr_tab_agencia(rw_crapage.cdagenci).vljurcap(vr_cont) := 0;
          vr_tab_agencia(rw_crapage.cdagenci).vlsldmed(vr_cont) := 0;
        END LOOP;
      END LOOP;

      -- Le registro de capital e calcula juros dos associados
      FOR rw_crapass IN cr_crapass LOOP

        -- Acumular o capital deste associado mês a mes
        vr_tab_vlcapmes_cotas(1) := rw_crapass.vlcapmes##1;
        vr_tab_vlcapmes_cotas(2) := rw_crapass.vlcapmes##2;
        vr_tab_vlcapmes_cotas(3) := rw_crapass.vlcapmes##3;
        vr_tab_vlcapmes_cotas(4) := rw_crapass.vlcapmes##4;
        vr_tab_vlcapmes_cotas(5) := rw_crapass.vlcapmes##5;
        vr_tab_vlcapmes_cotas(6) := rw_crapass.vlcapmes##6;
        vr_tab_vlcapmes_cotas(7) := rw_crapass.vlcapmes##7;
        vr_tab_vlcapmes_cotas(8) := rw_crapass.vlcapmes##8;
        vr_tab_vlcapmes_cotas(9) := rw_crapass.vlcapmes##9;
        vr_tab_vlcapmes_cotas(10) := rw_crapass.vlcapmes##10;
        vr_tab_vlcapmes_cotas(11) := rw_crapass.vlcapmes##11;
        vr_tab_vlcapmes_cotas(12) := rw_crapass.vlcapmes##12;

        -- Calcular o juros sobre o capital do primeiro mês
        vr_vljurcap := ROUND(vr_tab_vlcapmes_cotas(vr_nrmesini) * vr_tab_txjurcap(vr_nrmesini).txjurcap,2);
        -- Calcular saldo médio
        vr_vlsldmed := ROUND(vr_tab_vlcapmes_cotas(vr_nrmesini) / 12, 2);

        -- Acumular o juros e saldo médio calculado no pac atual
        vr_tab_agencia(rw_crapass.cdagenci).vljurcap(vr_nrmesini) := vr_tab_agencia(rw_crapass.cdagenci).vljurcap(vr_nrmesini) + vr_vljurcap;
        vr_tab_agencia(rw_crapass.cdagenci).vlsldmed(vr_nrmesini) := vr_tab_agencia(rw_crapass.cdagenci).vlsldmed(vr_nrmesini) + vr_vlsldmed;

        -- Calcular o juros com base na moeda
        vr_vljurmfx := ROUND(vr_vljurcap / vr_vlmoefix,4);

        -- Partir do mês inicial até o mes final (atual)
        FOR vr_nrcontad IN vr_nrmesini+1..vr_nrmesfim LOOP
          -- Calcular o juros sobre o capital no mês do registro atual
          -- acumulando os juros calculados sobre o primeiro mês
          vr_vljurcap := ROUND((vr_tab_vlcapmes_cotas(vr_nrcontad) + (vr_vljurmfx * vr_vlmoefix)) * vr_tab_txjurcap(vr_nrcontad).txjurcap,2);

          -- Acumular os juros com base na moeda
          vr_vljurmfx := vr_vljurmfx + ROUND(vr_vljurcap / vr_vlmoefix,4);

          -- Acumular o juros calculado no pac atual
          vr_tab_agencia(rw_crapass.cdagenci).vljurcap(vr_nrcontad) := vr_tab_agencia(rw_crapass.cdagenci).vljurcap(vr_nrcontad) + vr_vljurcap;

          -- Calcular saldo médio
          vr_vlsldmed := 0;

          -- Acumular o capital dos meses anteriors
          FOR vr_nrcontad2 IN 1..vr_nrcontad LOOP
            vr_vlsldmed := vr_vlsldmed + vr_tab_vlcapmes_cotas(vr_nrcontad2);
          END LOOP;

          -- Calcular a média deste saldo acumulado
          vr_vlsldmed := ROUND(vr_vlsldmed / 12, 2);

          -- Copiar para o acumulador por pac e mes
          vr_tab_agencia(rw_crapass.cdagenci).vlsldmed(vr_nrcontad) := vr_tab_agencia(rw_crapass.cdagenci).vlsldmed(vr_nrcontad) + vr_vlsldmed;

        END LOOP; -- Leitura dos outros meses

      END LOOP; -- Leitura dos associados

      -- Buscar o caminho padrão rl
      vr_nmdiret := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => 'rl');

      -- Preparar o CLOB para o XML
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Criar a tag das informações com base na poupança
      pc_escreve_clob(vr_clobxml,'<tipo id="P" dstexto="==> Com base na poupanca:">');
      -- Efetuar leitura na pltable com os dados por pac para montagem da primeira parte
      FOR vr_cdagenci IN vr_tab_agencia.FIRST..vr_tab_agencia.LAST LOOP
        -- Se existir registro para o valor atual
        IF vr_tab_agencia.EXISTS(vr_cdagenci) THEN
          -- Criar a tag para o PAC e enviar os juros
          pc_escreve_clob(vr_clobxml,'<info><nmdesdet>'||lpad(vr_cdagenci,3,' ')||' - '||vr_tab_agencia(vr_cdagenci).nmresage||'</nmdesdet>');
          -- Iterar sobre os 12 meses
          FOR vr_nrcontad IN 1..12 LOOP
            -- Enviar o valor do mes atual
            pc_escreve_clob(vr_clobxml,'<vlmes'||to_char(vr_nrcontad,'fm00')||'>'||to_char(vr_tab_agencia(vr_cdagenci).vljurcap(vr_nrcontad),'fm999g999g999g990d00')||'</vlmes'||to_char(vr_nrcontad,'fm00')||'>');
          END LOOP;
          -- Fechar a tag de info de pac
          pc_escreve_clob(vr_clobxml,'</info>');
        END IF;
      END LOOP;
      -- Fechar a tag de base na poupança
      pc_escreve_clob(vr_clobxml,'</tipo>');

      -- Abrir nova tag para envio das informações de taxas
      pc_escreve_clob(vr_clobxml,'<tipo id="T"  dstexto=""><info><nmdesdet>TAXAS</nmdesdet>');
      -- Efetuar leitura na pltable com os dados de taxas por mês
      FOR vr_nrcontad IN vr_tab_txjurcap.FIRST..vr_tab_txjurcap.LAST LOOP
        -- Enviar o valor do mes atual
        pc_escreve_clob(vr_clobxml,'<vlmes'||to_char(vr_nrcontad,'fm00')||'>'||to_char(vr_tab_txjurcap(vr_nrcontad).txjurori,'fm990d000000')||'</vlmes'||to_char(vr_nrcontad,'fm00')||'>');
      END LOOP;
      -- Fechar a tag de base na poupança
      pc_escreve_clob(vr_clobxml,'</info></tipo>');

      -- Por fim, criar a tag com informações no saldo médido do capital
      pc_escreve_clob(vr_clobxml,'<tipo id="C" dstexto="==> Com base no saldo medio do capital:">');
      -- Efetuar leitura na pltable com os dados por pac
      FOR vr_cdagenci IN vr_tab_agencia.FIRST..vr_tab_agencia.LAST LOOP
        -- Se existir registro para o valor atual
        -- E encontrou algum associado para o pac
        IF vr_tab_agencia.EXISTS(vr_cdagenci) THEN
          -- Criar a tag para o PAC e enviar o saldo médio
          pc_escreve_clob(vr_clobxml,'<info><nmdesdet>'||lpad(vr_cdagenci,3,' ')||' - '||vr_tab_agencia(vr_cdagenci).nmresage||'</nmdesdet>');
          -- Iterar sobre os 12 meses
          FOR vr_nrcontad IN 1..12 LOOP
            -- Enviar o valor do saldo do mes atual
            pc_escreve_clob(vr_clobxml,'<vlmes'||to_char(vr_nrcontad,'fm00')||'>'||to_char(vr_tab_agencia(vr_cdagenci).vlsldmed(vr_nrcontad),'fm999g999g999g990d00')||'</vlmes'||to_char(vr_nrcontad,'fm00')||'>');
          END LOOP;
          -- Fechar a tag de info de pac
          pc_escreve_clob(vr_clobxml,'</info>');
        END IF;
      END LOOP;
      -- Fechar a tag de base no capital
      pc_escreve_clob(vr_clobxml,'</tipo>');

      -- Encerrar a tag raiz do XML
      pc_escreve_clob(vr_clobxml,'</raiz>');

      -- Submeter o relatório 228
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/tipo/info'                    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl228.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nmdiret||'/crrl228.lst'           --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                                  --> 234 colunas
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
        RAISE vr_exc_erro;
      END IF;

      -- Chegou ao fim da solicitação
      pr_infimsol := 1;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit final
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

  END pc_crps281;
/

