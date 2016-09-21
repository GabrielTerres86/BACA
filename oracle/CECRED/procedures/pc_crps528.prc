CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS528(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER           --> Indicador para utiliza��o de restart
                                             ,pr_stprogra OUT PLS_INTEGER           --> Sa�da de termino da execu��o
                                             ,pr_infimsol OUT PLS_INTEGER           --> Sa�da de termino da solicita��o
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN
    /* ............................................................................

     Programa: pc_crps528 (Antigo Fontes/crps528.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Fernando
     Data    : MAIO/2009                     Ultima atualizacao: 27/08/2014

     Dados referentes ao programa:

     Frequencia: Mensal
     Objetivo  : Atende a solicitacao 004.
                 Emitir relatorio dos saldos das aplicacoes
                 (RDCPOS, RDCPRE, RDCA30, RDCA60, RDPP).

     Altera��o
                 08/05/2013 - Convers�o Progress >> Oracle PLSQL (Marcos-Supero)
                 
                 14/01/2013 - Inclus�o de NVL durante a busca do par�metro TXADIAPLIC
                              pois em cooperativas sem este par�metro estava ocorrendo
                              null index table key (Marcos-Supero)
                              
                 27/08/2014 - Incluido tratamento das aplica��es de produtos de 
                              capta��o. (Reinert)

                 03/06/2015 - Alterado a chave da TT vr_tab_captacao para listar
                              de forma correta os registro do relatorio. (Jean Michel)             

  ............................................................................ */

    DECLARE
      -- C�digo do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros
      vr_exc_erro exception;

      ---------------- Cursores gen�ricos ----------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      ---------------- Defini��o de temp-tables da rotina  --------------

      -- Defini��o de tabela para aplica��es RDCPRE, RDCA30, RDCA60 e RDPP
      TYPE typ_reg_aplica IS
        RECORD(tpaplica craprda.tpaplica%TYPE   --                   "Tipo da aplica��o"
              ,totaplic craprda.vlslfmes%TYPE   --                   "Saldo Total"
              ,vlfaxini NUMBER(8,2)             -- "zzz,zz9.99"      "De"
              ,vlfaxfim NUMBER(11,2)            -- "zzz,zzz,zz9.99"  "Ate"
              ,txaplica NUMBER(9,6));           -- "zz9.999999"      "%CDI"
      TYPE typ_tab_aplica IS
        TABLE OF typ_reg_aplica
          INDEX BY VARCHAR2(18);
      vr_tab_aplica typ_tab_aplica;
      -- Chave para a tabela de aplica��es
      -- Seq Ordena��o (1) + Valor Faixa Inicial (8) + TxAplica (9)
      vr_dschave_aplica VARCHAR2(18);

      -- Defini��o de tabela para as aplica��es RDC-Pos
      TYPE typ_reg_rdcpos IS
        RECORD(txaplica craplap.txaplica%TYPE   -- "%CDI"
              ,totaplic craplap.vllanmto%TYPE   -- "Saldo Total"
              ,vlfaxini NUMBER(8,2)             -- "zzz,zz9.99"
              ,vlfaxfim NUMBER(11,2)            -- "zzz,zzz,zz9.99"
              ,qtdiacar PLS_INTEGER);           -- "Dias Carencia"
      TYPE typ_tab_rdcpos IS
        TABLE OF typ_reg_rdcpos
          INDEX BY VARCHAR2(30);
      -- Vetor para armazenar os dados de rdcpos
      -- Dias de Carencia (5) + TxAplica (25)
      vr_tab_rdcpos typ_tab_rdcpos;
      vr_dschave_rdcpos VARCHAR2(30);

      -- Defini�ao de tabela para armazenar as taxas por aplica�ao
      TYPE typ_reg_taxas IS
        RECORD(vlfaxini NUMBER(8,2)   -- "zzz,zz9.99"
              ,vlfaxfim NUMBER(11,2)  -- "zzz,zzz,zz9.99" --
              ,perapltx NUMBER(9,6)); -- "%Taxa"          --
      TYPE typ_tab_taxas IS
        TABLE OF typ_reg_taxas
          INDEX BY VARCHAR2(8);
      -- Vetor para armazenar os dados de rdcpos
      -- Valor Faixa Inicial (8)
      vr_tab_taxas typ_tab_taxas;
      vr_dschave_taxas VARCHAR2(8);
      
      -- Armazenar informa��es de aplica��es de capta��o
      TYPE typ_reg_captacao IS
        RECORD(txaplica craprac.txaplica%TYPE    --> Taxa da aplica��o
              ,totaplic craprac.vlslfmes%TYPE    --> Total da aplica��o
              ,qtdiacar craprac.qtdiacar%TYPE    --> Quantidade de dias de carencia
              ,nmprodut crapcpc.nmprodut%TYPE    --> Nome do produto
              ,cdprodut crapcpc.cdprodut%TYPE);  --> Codigo do produto
      TYPE typ_tab_captacao IS 
        TABLE OF typ_reg_captacao 
          INDEX BY VARCHAR2(30);
      
      vr_tab_captacao typ_tab_captacao;
      vr_dschave_captacao VARCHAR2(10);
      -- Vari�vel auxiliar para buscar a primeira taxa de aplica��o cadastrada na craplap
      vr_txaplica   craplap.txaplica%type;
      -- Vari�vel auxiliar para separar os produtos de capta��o no relat�rio crrl515
      vr_contpdto   INTEGER := 7;

      ------------------- Cursores do processo --------------------------

      -- Busca das aplica��es cfme o tipo passado
      CURSOR cr_craprda(pr_tpaplica craprda.tpaplica%TYPE) IS
        SELECT nrdconta
              ,nraplica
              ,dtmvtolt
              ,qtdiauti
              ,vlslfmes
              ,vlaplica
              ,vlsdrdca
              ,dtsdfmes
          FROM craprda
         WHERE cdcooper = pr_cdcooper
           AND tpaplica = pr_tpaplica
           AND insaqtot = 0; -- N�o sacada

      -- Busca das aplica��es RDC Pos
      CURSOR cr_craprda_rdc_pos IS
        select nrdconta,
               nraplica,
               dtmvtolt,
               qtdiauti,
               vlslfmes,
               vlaplica,
               vlsdrdca,
               dtsdfmes,
               txaplica
          from (select rda.nrdconta,
                       rda.nraplica,
                       rda.dtmvtolt,
                       rda.qtdiauti,
                       rda.vlslfmes,
                       rda.vlaplica,
                       rda.vlsdrdca,
                       rda.dtsdfmes,
                       lap.txaplica,
                       lap.progress_recid,
                       min(lap.progress_recid) over(partition by lap.cdcooper, lap.nrdconta, lap.nraplica, lap.dtmvtolt) min_recid
                  from craprda rda,
                       craplap lap
                 where rda.cdcooper = pr_cdcooper
                   and rda.tpaplica = 8
                   and rda.insaqtot = 0 -- N�o sacada
                   and lap.cdcooper = rda.cdcooper
                   and lap.nrdconta = rda.nrdconta
                   and lap.nraplica = rda.nraplica
                   and lap.dtmvtolt = rda.dtmvtolt)
         where progress_recid = min_recid;

      -- Busca o regid do ultimo lan�amento 180 da aplica��o no dia corrente
      CURSOR cr_craplap_180_r(pr_nrdconta IN craplap.nrdconta%TYPE
                             ,pr_nraplica IN craplap.nraplica%TYPE) IS
        SELECT MAX(progress_recid)
          FROM craplap
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nraplica = pr_nraplica
           AND dtmvtolt = rw_crapdat.dtmvtolt
           AND cdhistor = 180; --> PROVIS.RDCA60
      vr_progress_recid craplap.progress_recid%TYPE;

      -- Busca o valor do ultimo lan�amento 180 da aplica��o no dia corrente
      CURSOR cr_craplap_180_v(pr_progress_recid IN craplap.progress_recid%TYPE) IS
        SELECT vlsdlsap
          FROM craplap
         WHERE progress_recid = pr_progress_recid;
      vr_vlsdlsap craplap.vlsdlsap%TYPE;

      -- Busca se a aplica��o teve saldos somado para conseguir a nova taxa
      CURSOR cr_crapcap(pr_nrdconta IN crapcap.nrdconta%TYPE
                       ,pr_nraplica IN crapcap.nraplica%TYPE) IS
        SELECT SUM(vlsddapl)
          FROM crapcap
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nraplica = pr_nraplica;
      vr_vlsddapl crapcap.vlsddapl%TYPE;

      -- Busca das aplica��o de dep�sito programado
      CURSOR cr_craprpp IS
        SELECT vlslfmes
          FROM craprpp
         WHERE cdcooper = pr_cdcooper
           AND vlsdrdpp <> 0; --> Somente aquelas com saldo

      -- Busca das aplica��es de capta��o
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE) IS 
        SELECT rac.txaplica txaplica
              ,rac.qtdiacar qtdiacar
              ,rac.vlslfmes vlslfmes
              ,cpc.idtxfixa idtxfixa
              ,cpc.nmprodut nmprodut
              ,cpc.cdprodut cdprodut
          FROM crapcpc cpc, craprac rac
         WHERE rac.cdcooper = pr_cdcooper      AND
               rac.idsaqtot = 0                AND
               rac.cdprodut = cpc.cdprodut
         ORDER BY cpc.cdprodut;

      -- Vari�veis para cria��o do XML e gera��o dos relat�rios
      vr_des_xml  CLOB;             -- Dados do XML
      -- Vari�vel para o caminho e nome do arquivo base
      vr_nom_direto  VARCHAR2(200);

      -- Variaveis para o processo
      vr_ttaplcta NUMBER;               --> Total tempor�rio
      vr_nmaplica VARCHAR2(20);         --> Nome do tipo de aplica��o

      -------- SubRotinas para reaproveitamento de c�digo --------------

      -- Carregamento das taxas cfme o tipo da aplica��o
      PROCEDURE pc_carrega_taxas(pr_tpdataxa IN PLS_INTEGER) IS
        -- Tipo da taxa: 1 - RDCA30, 2 - RDPP, 3 - RDCA60, 7 - RDCPRE

        -- Busca de taxas para aplica��es RDC Pr�
        CURSOR cr_crapftx_rdcpre IS
          SELECT vlfaixas
                ,perapltx
            FROM crapftx
           WHERE cdcooper = pr_cdcooper
             AND tptaxrdc = 7 -- RdcPr�
           ORDER BY vlfaixas
                   ,cdperapl;
        -- Auxiliar para separa��o dos valores na craptab
        vr_vlfaxini NUMBER;
        vr_perapltx NUMBER;
        vr_cartaxas gene0002.typ_split;   --> Split de Taxas
      BEGIN
        -- Limpamos o vetor para reinicializ�-lo
        vr_tab_taxas.DELETE;
        -- Somente para RDC Pr�
        IF pr_tpdataxa = 7 THEN
          -- Carregar o vetor de taxas a partir da tabela crapftx
          FOR rw_crapftx IN cr_crapftx_rdcpre LOOP
            -- Montar a chave para o vetor:
            -- Valor Faixa Inicial (8) - Removendo o sinal de decimal
            vr_dschave_taxas := REPLACE(REPLACE(to_char(rw_crapftx.vlfaixas,'fm000000d00'),'.',''),',','');
            -- Criar o registro no vetor de taxas
            vr_tab_taxas(vr_dschave_taxas).vlfaxini := rw_crapftx.vlfaixas;
            vr_tab_taxas(vr_dschave_taxas).perapltx := rw_crapftx.perapltx;
          END LOOP;
        ELSE
          -- Criamos um bloco de la�o para efetuar a busca das taxas
          FOR vr_craptab IN btch0001.cr_craptab(pr_cdcooper, 'CRED', 'CONFIG', NULL, 'TXADIAPLIC', pr_tpdataxa, NULL) LOOP
            -- Quebra string retornada da consulta pelo delimitador ';'
            vr_cartaxas := gene0002.fn_quebra_string(vr_craptab.dstextab,';');
            -- Se foi encontrada informa��o na tabela
            IF vr_cartaxas.count > 0 THEN
              -- Itera sobre o array para encontrar os valores e agregar para as vari�veis
              FOR idx IN 1..vr_cartaxas.COUNT LOOP
                -- Com a informa��o atual, separ�-la atrav�s do # pois
                -- antes do mesmo temos o valor da faixa e ap�s o percentual
                vr_vlfaxini := NVL(gene0002.fn_busca_entrada(1, vr_cartaxas(idx), '#'),0);
                vr_perapltx := NVL(gene0002.fn_busca_entrada(2, vr_cartaxas(idx), '#'),0);
                -- Montar a chave para o vetor:
                -- Valor Faixa Inicial (8) - Removendo o sinal de decimal
                vr_dschave_taxas := REPLACE(REPLACE(to_char(vr_vlfaxini,'fm000000d00'),'.',''),',','');
                -- Criar o registro no vetor de taxas
                vr_tab_taxas(vr_dschave_taxas).vlfaxini := vr_vlfaxini;
                vr_tab_taxas(vr_dschave_taxas).perapltx := vr_perapltx;
              END LOOP;
            END IF;
          END LOOP;
        END IF;
        -- Varrer o vetor para ajustar o valor final da faixa conforme o valor do faixa anterior
        vr_dschave_taxas := vr_tab_taxas.FIRST;
        LOOP
          -- Sair quando terminou de ler o vetor
          EXIT WHEN vr_dschave_taxas IS NULL;
          -- Somente para o ultimo registro
          IF vr_dschave_taxas = vr_tab_taxas.LAST THEN
            -- Utilizar faixa final fixa
            vr_tab_taxas(vr_dschave_taxas).vlfaxfim := 999999999.99;
          ELSE
            -- Valor final � base no in�cio da pr�xima faixa -1 centavo
            vr_tab_taxas(vr_dschave_taxas).vlfaxfim := vr_tab_taxas(vr_tab_taxas.NEXT(vr_dschave_taxas)).vlfaxini-.01;
          END IF;
          -- Buscar o pr�ximo registro
          vr_dschave_taxas := vr_tab_taxas.NEXT(vr_dschave_taxas);
        END LOOP;
      END;

      -- SubRotina para montagem da chave para o vetor vr_tab_aplica
      FUNCTION fn_dschave_aplica(pr_sqordem IN PLS_INTEGER
                                ,pr_vlfaixa IN NUMBER
                                ,pr_peraplt IN NUMBER) RETURN VARCHAR2 IS
      BEGIN
        -- Montar a chave para a tabela, que envolve o valor da faixa e a taxa aplicada :
        -- Seq Ordena��o (1) + Valor Faixa Inicial (8) + TxAplica (9)
        RETURN pr_sqordem
            || REPLACE(REPLACE(to_char(pr_vlfaixa,'fm000000d00'),'.',''),',','')
            || REPLACE(REPLACE(to_char(pr_peraplt,'fm000d000000'),'.',''),',','');
      END;

      -- SubRotina para inicializar a faixa no vetor
      PROCEDURE pc_iniciali_faixa_aplica(pr_tpaplica IN craprda.tpaplica%TYPE
                                        ,pr_vlfaxini IN NUMBER
                                        ,pr_vlfaxfim IN NUMBER
                                        ,pr_perapltx IN NUMBER) IS
      BEGIN
        -- Somente continuar se a chave n�o existe no vetor
        IF NOT vr_tab_aplica.EXISTS(vr_dschave_aplica) THEN
          -- Inicializamos ent�o o vetor da aplica��o com a faixa
          vr_tab_aplica(vr_dschave_aplica).tpaplica := pr_tpaplica;
          vr_tab_aplica(vr_dschave_aplica).totaplic := 0;
          vr_tab_aplica(vr_dschave_aplica).vlfaxini := pr_vlfaxini;
          vr_tab_aplica(vr_dschave_aplica).vlfaxfim := pr_vlfaxfim;
          vr_tab_aplica(vr_dschave_aplica).txaplica := pr_perapltx;
        END IF;
      END;

      -- SubRotina para atualizar a faixa j� tenha no vetor
      PROCEDURE pc_atualiza_faixa_aplica(pr_vlslfmes IN NUMBER) IS
      BEGIN
        -- Adicionamos o valor aplicado no vetor
        vr_tab_aplica(vr_dschave_aplica).totaplic := vr_tab_aplica(vr_dschave_aplica).totaplic + pr_vlslfmes;
      END;

      -- Subrotina para escrever texto na vari�vel CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN
      -- C�digo do programa
      vr_cdprogra := 'CRPS528';

      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS528'
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se n�o encontrar
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

      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => pr_cdcritic);
      -- Se a variavel de erro � <> 0
      IF pr_cdcritic <> 0 THEN
        -- Buscar descri��o da cr�tica
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      -------- Inicio do processamendo das aplica��es ---------

      ------------------------- RDC P�s ----------------------------
      FOR rw_craprda IN cr_craprda_rdc_pos LOOP
        vr_txaplica := rw_craprda.txaplica;
        -- Montar a chave para o vetor RDC P�s que envolve:
        -- Dias de Carencia (5) + TxAplica (25)
        vr_dschave_rdcpos := lpad(rw_craprda.qtdiauti,5,'0')
                          || REPLACE(REPLACE(to_char(vr_txaplica,'fm00000000000000000000000d00'),'.',''),',','');
        -- Se n�o existir registro com a chave

        IF NOT vr_tab_rdcpos.EXISTS(vr_dschave_rdcpos) THEN
          -- Criar o registro na tabela
          vr_tab_rdcpos(vr_dschave_rdcpos).txaplica := vr_txaplica;
          vr_tab_rdcpos(vr_dschave_rdcpos).totaplic := 0;
          vr_tab_rdcpos(vr_dschave_rdcpos).qtdiacar := rw_craprda.qtdiauti;
        END IF;

        -- Somar ao vetor o saldo no final do m�s da aplica��o
        vr_tab_rdcpos(vr_dschave_rdcpos).totaplic := vr_tab_rdcpos(vr_dschave_rdcpos).totaplic + rw_craprda.vlslfmes;

        -- Se for um aplica��o do mes
        IF rw_craprda.vlslfmes = 0 THEN
          -- Somar o saldo atual
          vr_tab_rdcpos(vr_dschave_rdcpos).totaplic := vr_tab_rdcpos(vr_dschave_rdcpos).totaplic + rw_craprda.vlsdrdca;
        END IF;

      END LOOP;
      ------------------------- RDC Pr� ----------------------------
      -- Efetuar o carregamento das taxas para as aplica��es RDC Pr�
      pc_carrega_taxas(pr_tpdataxa => 7);
      -- Busca das aplica��es RDC Pr�
      FOR rw_craprda IN cr_craprda(pr_tpaplica => 7) LOOP
        -- Inicializar o total com o valor da aplica��o
        vr_ttaplcta := rw_craprda.vlaplica;
        -- Busca se a aplica��o teve saldos somado para conseguir a nova taxa
        vr_vlsddapl := 0;
        OPEN cr_crapcap(pr_nrdconta => rw_craprda.nrdconta
                       ,pr_nraplica => rw_craprda.nraplica);
        FETCH cr_crapcap
         INTO vr_vlsddapl;
        CLOSE cr_crapcap;
        -- Adicion�-la ao total
        vr_ttaplcta := vr_ttaplcta + NVL(vr_vlsddapl,0);
        -- Varrer o vetor das faixas para totalizarmos na faixa que a aplica��o se enquadra
        vr_dschave_taxas := vr_tab_taxas.FIRST;
        LOOP
          -- Sair quando terminou de ler o vetor
          EXIT WHEN vr_dschave_taxas IS NULL;
          -- Montar a possivel chave para a tabela, que envolve o valor da faixa e a taxa aplicada :
          vr_dschave_aplica := fn_dschave_aplica('1',vr_tab_taxas(vr_dschave_taxas).vlfaxini,vr_tab_taxas(vr_dschave_taxas).perapltx);
          -- Inicializar a faixa para o tipo de aplica��o
          pc_iniciali_faixa_aplica(pr_tpaplica => 7
                                  ,pr_vlfaxini => vr_tab_taxas(vr_dschave_taxas).vlfaxini
                                  ,pr_vlfaxfim => vr_tab_taxas(vr_dschave_taxas).vlfaxfim
                                  ,pr_perapltx => vr_tab_taxas(vr_dschave_taxas).perapltx);
          -- Se o valor do acumulado enquandra-se na faixa atual
          IF vr_ttaplcta > vr_tab_taxas(vr_dschave_taxas).vlfaxini AND vr_ttaplcta <= vr_tab_taxas(vr_dschave_taxas).vlfaxfim THEN
            -- Atualizar o valor na faixa da aplica��o
            pc_atualiza_faixa_aplica(pr_vlslfmes => rw_craprda.vlslfmes);
            -- Sair pois j� enviou o saldo
            EXIT;
          END IF;
          -- Para aplicacoes feitas no mes
          IF rw_craprda.vlslfmes = 0 THEN
            -- Se o valor de saldo enquandra-se na faixa atual
            IF rw_craprda.vlsdrdca > vr_tab_taxas(vr_dschave_taxas).vlfaxini AND rw_craprda.vlsdrdca <= vr_tab_taxas(vr_dschave_taxas).vlfaxfim THEN
              -- Atualizar o saldo na faixa da aplica��o
              pc_atualiza_faixa_aplica(pr_vlslfmes => rw_craprda.vlsdrdca);
              -- Sair pois j� enviamos os valores necess�rios
              EXIT;
            END IF;
          END IF;
          -- Buscar o pr�ximo registro
          vr_dschave_taxas := vr_tab_taxas.NEXT(vr_dschave_taxas);
        END LOOP; -- Fim varredura das faixas
      END LOOP; -- Fim leitura RDC PR�

      -------------------------- RDCA30 -----------------------------
      -- Efetuar o carregamento das taxas para as aplica��es RDCA30
      pc_carrega_taxas(pr_tpdataxa => 1);
      -- Busca das aplica��es RDCA30
      FOR rw_craprda IN cr_craprda(pr_tpaplica => 3) LOOP
        -- Inicializar o total com o valor saldo final do mes
        vr_ttaplcta := rw_craprda.vlslfmes;

        -- Se rodou o mensal no dia corrente
        IF rw_craprda.dtsdfmes = rw_crapdat.dtmvtolt THEN
          -- Varrer o vetor das faixas para totalizarmos na faixa que a aplica��o se enquadra
          vr_dschave_taxas := vr_tab_taxas.FIRST;
          LOOP
            -- Sair quando terminou de ler o vetor
            EXIT WHEN vr_dschave_taxas IS NULL;
            -- Montar a possivel chave para a tabela, que envolve o valor da faixa e a taxa aplicada :
            vr_dschave_aplica := fn_dschave_aplica('2',vr_tab_taxas(vr_dschave_taxas).vlfaxini,vr_tab_taxas(vr_dschave_taxas).perapltx);
            -- Inicializar a faixa para o tipo de aplica��o
            pc_iniciali_faixa_aplica(pr_tpaplica => 1
                                    ,pr_vlfaxini => vr_tab_taxas(vr_dschave_taxas).vlfaxini
                                    ,pr_vlfaxfim => vr_tab_taxas(vr_dschave_taxas).vlfaxfim
                                    ,pr_perapltx => vr_tab_taxas(vr_dschave_taxas).perapltx);
            -- Se o valor do acumulado enquandra-se na faixa atual
            IF vr_ttaplcta > vr_tab_taxas(vr_dschave_taxas).vlfaxini AND vr_ttaplcta <= vr_tab_taxas(vr_dschave_taxas).vlfaxfim THEN
              -- Atualizar o valor na faixa da aplica��o
              pc_atualiza_faixa_aplica(pr_vlslfmes => rw_craprda.vlslfmes);
              -- Podemos sair da busca pois j� foi encontrado
              EXIT;
            END IF;
            -- Buscar o pr�ximo registro
            vr_dschave_taxas := vr_tab_taxas.NEXT(vr_dschave_taxas);
          END LOOP; -- Fim varredura das faixas
        END IF; -- Se rodou o mensal
      END LOOP; -- Fim leitura RDCA30

      -------------------------- RDCA60 -----------------------------
      -- Efetuar o carregamento das taxas para as aplica��es RDCA60
      pc_carrega_taxas(pr_tpdataxa => 3);
      -- Busca das aplica��es RDCA30
      FOR rw_craprda IN cr_craprda(pr_tpaplica => 5) LOOP
        -- Busca o regid do ultimo lan�amento 180 da aplica��o no dia corrente
        vr_progress_recid := NULL;
        -- Inicializar o total com o saldo final mes da aplica��o
        vr_ttaplcta := rw_craprda.vlslfmes;

        OPEN cr_craplap_180_r(pr_nrdconta => rw_craprda.nrdconta
                             ,pr_nraplica => rw_craprda.nraplica);
        FETCH cr_craplap_180_r
         INTO vr_progress_recid;
        CLOSE cr_craplap_180_r;
        -- Continuar somente se encontrou registro
        IF vr_progress_recid IS NOT NULL THEN
          -- Enfim, busca o valor do lan�amento acima
          vr_vlsdlsap := 0;
          OPEN cr_craplap_180_v(pr_progress_recid => vr_progress_recid);
          FETCH cr_craplap_180_v
           INTO vr_vlsdlsap;
          CLOSE cr_craplap_180_v;
          -- Inicializar o total com o valor lan�ado + saldo final mes da aplica��o que ja foi atribuido a variavel total
          vr_ttaplcta := NVL(vr_vlsdlsap,0) + vr_ttaplcta;
          -- Varrer o vetor das faixas para totalizarmos na faixa que a aplica��o se enquadra
          vr_dschave_taxas := vr_tab_taxas.FIRST;
          LOOP
            -- Sair quando terminou de ler o vetor
            EXIT WHEN vr_dschave_taxas IS NULL;
            -- Montar a possivel chave para a tabela, que envolve o valor da faixa e a taxa aplicada :
            vr_dschave_aplica := fn_dschave_aplica('3',vr_tab_taxas(vr_dschave_taxas).vlfaxini,vr_tab_taxas(vr_dschave_taxas).perapltx);
            -- Inicializar a faixa para o tipo de aplica��o
            pc_iniciali_faixa_aplica(pr_tpaplica => 3
                                    ,pr_vlfaxini => vr_tab_taxas(vr_dschave_taxas).vlfaxini
                                    ,pr_vlfaxfim => vr_tab_taxas(vr_dschave_taxas).vlfaxfim
                                    ,pr_perapltx => vr_tab_taxas(vr_dschave_taxas).perapltx);
            -- Se o valor do acumulado enquandra-se na faixa atual
            IF vr_ttaplcta > vr_tab_taxas(vr_dschave_taxas).vlfaxini AND vr_ttaplcta <= vr_tab_taxas(vr_dschave_taxas).vlfaxfim THEN
              -- Enviar o valor para a tabela de aplica��o na faixa enquadrada
              pc_atualiza_faixa_aplica(pr_vlslfmes => rw_craprda.vlslfmes);
              -- Podemos sair da busca pois j� foi encontrado
              EXIT;
            END IF;
            -- Buscar o pr�ximo registro
            vr_dschave_taxas := vr_tab_taxas.NEXT(vr_dschave_taxas);
          END LOOP; -- Fim varredura das faixas
        END IF; -- Se encontrou craplap
      END LOOP; -- Fim leitura RDCA60

      -------------------------- RDPP -----------------------------
      -- Efetuar o carregamento das taxas para as aplica��es de poupan�a programada
      pc_carrega_taxas(pr_tpdataxa => 2);
      -- Busca das aplica��es de dep�sito programado
      FOR rw_craprpp IN cr_craprpp LOOP
        -- Varrer o vetor das faixas para totalizarmos na faixa que a aplica��o se enquadra
        vr_dschave_taxas := vr_tab_taxas.FIRST;
        LOOP
          -- Sair quando terminou de ler o vetor
          EXIT WHEN vr_dschave_taxas IS NULL;
          -- Montar a possivel chave para a tabela, que envolve o valor da faixa e a taxa aplicada :
          vr_dschave_aplica := fn_dschave_aplica('4',vr_tab_taxas(vr_dschave_taxas).vlfaxini,vr_tab_taxas(vr_dschave_taxas).perapltx);
          -- Inicializar a faixa para o tipo de aplica��o
          pc_iniciali_faixa_aplica(pr_tpaplica => 2
                                  ,pr_vlfaxini => vr_tab_taxas(vr_dschave_taxas).vlfaxini
                                  ,pr_vlfaxfim => vr_tab_taxas(vr_dschave_taxas).vlfaxfim
                                  ,pr_perapltx => vr_tab_taxas(vr_dschave_taxas).perapltx);
          -- Se o valor saldo fim m�s enquandra-se na faixa atual
          IF rw_craprpp.vlslfmes > vr_tab_taxas(vr_dschave_taxas).vlfaxini AND rw_craprpp.vlslfmes <= vr_tab_taxas(vr_dschave_taxas).vlfaxfim THEN
            -- Enviar o valor para a tabela de aplica��o na faixa enquadrada
            pc_atualiza_faixa_aplica(pr_vlslfmes => rw_craprpp.vlslfmes);
            -- Podemos sair da busca pois j� foi encontrado
            EXIT;
          END IF;
          -- Buscar o pr�ximo registro
          vr_dschave_taxas := vr_tab_taxas.NEXT(vr_dschave_taxas);
        END LOOP; -- Fim varredura das faixas
      END LOOP; -- Fim leitura RDPP
      
      ---------------------- PRODUTOS DE CAPTA��O -----------------
      -- Para cada registro de aplica��o de capta��o
      FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper) LOOP
        
        -- Produto com taxa fixa (1-Sim/2-Nao)
        IF rw_craprac.idtxfixa = 1 THEN          
          vr_txaplica := 100 + rw_craprac.txaplica;          
        ELSE
          vr_txaplica := rw_craprac.txaplica;
        END IF;
        
        -- Alimenta chave da PLTABLE
        vr_dschave_captacao := lpad(rw_craprac.cdprodut,5,'0') ||
                               lpad(rw_craprac.qtdiacar,5,'0'); /* ||
                               REPLACE(REPLACE(to_char(vr_txaplica,
                               'fm00000000000000000000000d00'),'.',''),',','');*/

        -- Alimenta informa��es da PLTABLE
        vr_tab_captacao(vr_dschave_captacao).txaplica := vr_txaplica;
        vr_tab_captacao(vr_dschave_captacao).totaplic := nvl(vr_tab_captacao(vr_dschave_captacao).totaplic, 0) +
                                                         rw_craprac.vlslfmes;
        vr_tab_captacao(vr_dschave_captacao).qtdiacar := rw_craprac.qtdiacar;        
        vr_tab_captacao(vr_dschave_captacao).nmprodut := rw_craprac.nmprodut;
        vr_tab_captacao(vr_dschave_captacao).cdprodut := rw_craprac.cdprodut;
      
      END LOOP;

      -------------------- INICIO DA GERACAO DO RELATORIO --------------------------

      -- Busca do diret�rio base da cooperativa para a gera��o de relat�rios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl');     --> Utilizaremos o rl

      -- Inicializar o CLOB (XML)
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informa��es do XML
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
      -- Primeiramente enviar as informa��es de RDC Pos
      /* ID do tipo da aplica��o rdcpos = 8 concatenado com 0 para indicar que n�o � um produto de capta��o
         para o agrupamento das informa��es no IReport */
      pc_escreve_xml('<tpAplica id="80" nmaplica="RDCPOS">');
      vr_dschave_rdcpos := vr_tab_rdcpos.FIRST;
      LOOP
        -- Sair quando n�o existirem mais registros a enviar
        EXIT WHEN vr_dschave_rdcpos IS NULL;
        -- Para cada registro, envia as informa��es da faixa
        pc_escreve_xml('<faixa>'
                     ||'  <txaplica>'||to_char(vr_tab_rdcpos(vr_dschave_rdcpos).txaplica,'fm990d000000')||'</txaplica>'
                     ||'  <qtdiacar>'||to_char(vr_tab_rdcpos(vr_dschave_rdcpos).qtdiacar,'fm999g990')||'</qtdiacar>'
                     ||'  <totaplic>'||to_char(vr_tab_rdcpos(vr_dschave_rdcpos).totaplic,'fm999g999g999g990d00')||'</totaplic>'
                     ||'</faixa>');
        -- Buscar o pr�ximo registro
        vr_dschave_rdcpos := vr_tab_rdcpos.NEXT(vr_dschave_rdcpos);
      END LOOP;
      -- Fechar a tah do RDC POS
      pc_escreve_xml('</tpAplica>');

      -- Buscar primeiro registro da PLTABLE
      vr_dschave_captacao := vr_tab_captacao.FIRST;    
      
      --Buscar todas as aplica��es de capta��o
      LOOP
        -- Sair quando n�o existir mais registros na PLTABLE
        EXIT WHEN vr_dschave_captacao IS NULL;

         -- Se for o primeiro registro, ou mudou o tipo de aplica��o com rela��o a anterior
        IF vr_dschave_captacao = vr_tab_captacao.FIRST OR 
           vr_tab_captacao(vr_dschave_captacao).nmprodut <> vr_tab_captacao(vr_tab_captacao.PRIOR(vr_dschave_captacao)).nmprodut THEN
           vr_contpdto := vr_contpdto + 1;
          -- Abrir a tag de tipo de aplica��o
          /* ID do tipo da aplica��o � o contador de produtos de capta��o concatenado com 1 
             para indicar que � um produto de capta��o para o agrupamento das informa��es no IReport */
          pc_escreve_xml('<tpAplica id="' || vr_contpdto || '1" nmaplica="'||vr_tab_captacao(vr_dschave_captacao).nmprodut||'">');
        END IF;        
        -- Enviar a tag de faixa
        pc_escreve_xml('<faixa>'
                     ||'  <txaplica>'||to_char(vr_tab_captacao(vr_dschave_captacao).txaplica,'fm990d000000')||'</txaplica>'
                     ||'  <qtdiacar>'||to_char(vr_tab_captacao(vr_dschave_captacao).qtdiacar,'fm999g990')||'</qtdiacar>'
                     ||'  <totaplic>'||to_char(vr_tab_captacao(vr_dschave_captacao).totaplic,'fm999g999g999g990d00')||'</totaplic>'
                     ||'</faixa>');

         -- No ultimo registro ou no ultimo da aplica��o atual
        IF vr_dschave_captacao = vr_tab_captacao.LAST OR 
           vr_tab_captacao(vr_dschave_captacao).nmprodut <> vr_tab_captacao(vr_tab_captacao.NEXT(vr_dschave_captacao)).nmprodut THEN
          -- Encerrrar a tag do tipo de aplica��o atual
          pc_escreve_xml('</tpAplica>');
        END IF;
        -- Buscar o pr�ximo registro
        vr_dschave_captacao := vr_tab_captacao.NEXT(vr_dschave_captacao);
        
      END LOOP;

      -- Buscar agora o restante das aplica��es, que tem a mesma estrutura e est�o na tabela vr_tab_aplic
      vr_dschave_aplica := vr_tab_aplica.FIRST;
      LOOP
        -- Sair quando n�o existir mais informa��a na temp-table
        EXIT WHEN vr_dschave_aplica IS NULL;
        -- Se for o primeiro registro, ou mudou o tipo de aplica��o com rela��o a anterior
        IF vr_dschave_aplica = vr_tab_aplica.FIRST OR vr_tab_aplica(vr_dschave_aplica).tpaplica <> vr_tab_aplica(vr_tab_aplica.PRIOR(vr_dschave_aplica)).tpaplica THEN
          -- Buscar a descri��o cfme o tipo
          CASE vr_tab_aplica(vr_dschave_aplica).tpaplica
            WHEN 1 THEN
              vr_nmaplica := 'RDCA30';
            WHEN 2 THEN
              vr_nmaplica := 'RDPP';
            WHEN 3 THEN
              vr_nmaplica := 'RDCA60';
            WHEN 7 THEN
              vr_nmaplica := 'RDCPRE';
            ELSE
              vr_nmaplica := null;
          END CASE;
          -- Abrir a tag de tipo de aplica��o
          /* ID do tipo da aplica��o � concatenado com 0 para indicar que n�o � um produto de capta��o 
             para o agrupamento das informa��es no IReport */
          pc_escreve_xml('<tpAplica id="'||vr_tab_aplica(vr_dschave_aplica).tpaplica||'0" nmaplica="'||vr_nmaplica||'">');
        END IF;
        -- Enviar a tag de faixa
        pc_escreve_xml('<faixa>'
                     ||'  <vlfaxini>'||to_char(vr_tab_aplica(vr_dschave_aplica).vlfaxini,'fm999g999g999g990d00')||'</vlfaxini>'
                     ||'  <vlfaxfim>'||to_char(vr_tab_aplica(vr_dschave_aplica).vlfaxfim,'fm999g999g999g990d00')||'</vlfaxfim>'
                     ||'  <txaplica>'||to_char(vr_tab_aplica(vr_dschave_aplica).txaplica,'fm990d000000')||'</txaplica>'
                     ||'  <totaplic>'||to_char(vr_tab_aplica(vr_dschave_aplica).totaplic,'fm999g999g999g990d00')||'</totaplic>'
                     ||'</faixa>');
        -- No ultimo registro ou no ultimo da aplica��o atual
        IF vr_dschave_aplica = vr_tab_aplica.LAST OR vr_tab_aplica(vr_dschave_aplica).tpaplica <> vr_tab_aplica(vr_tab_aplica.NEXT(vr_dschave_aplica)).tpaplica THEN
          -- Encerrrar a tag do tipo de aplica��o atual
          pc_escreve_xml('</tpAplica>');
        END IF;
        -- Buscar o pr�ximo registro
        vr_dschave_aplica := vr_tab_aplica.NEXT(vr_dschave_aplica);
      END LOOP;
      
      -- Finalizar o arquivo XML de dados
      pc_escreve_xml('</raiz>');
      -- Ao terminar de ler os registros, iremos gravar o XML para arquivo totalizador--
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/tpAplica/faixa'               --> N� base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl515.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem par�metros
                                 ,pr_dsarqsaid => vr_nom_direto||'/crrl515.lst'        --> Arquivo final com o path
                                 ,pr_qtcoluna  => 80                                   --> 80 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Gera�ao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impress�o (Imprim.p)
                                 ,pr_nmformul  => '80col'                              --> Nome do formul�rio para impress�o
                                 ,pr_nrcopias  => 1                                    --> N�mero de c�pias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => pr_dscritic);                        --> Sa�da com erro
      -- Liberando a mem�ria alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
        -- Gerar exce��o
        pr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit final
      COMMIT;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas c�digo
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descri��o
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps528;
/

