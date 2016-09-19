CREATE OR REPLACE PROCEDURE CECRED.pc_crps338(pr_cdcooper IN crapcop.cdcooper%TYPE     --> COOPERATIVA SOLICITADA
                                      ,pr_flgresta IN PLS_INTEGER               --> FLAG PADRÃO PARA UTILIZAÇÃO DE RESTART
                                      ,pr_stprogra OUT PLS_INTEGER              --> SAÍDA DE TERMINO DA EXECUÇÃO
                                      ,pr_infimsol OUT PLS_INTEGER              --> SAÍDA DE TERMINO DA SOLICITAÇÃO
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> CRITICA ENCONTRADA
                                      ,pr_dscritic OUT VARCHAR2) IS             --> TEXTO DE ERRO/CRITICA ENCONTRADA
BEGIN

  /* .............................................................................

   Programa: Fontes/crps338.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Abril/2003.                     Ultima atualizacao: 27/07/2012

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 013 (mensal - limpeza mensal)
               Emite: arquivo geral da CAIXA para microfilmagem.

   Alteracoes: 02/08/2004 - Alterar diretorio do win12 (Margarete).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               27/07/2012 - Ajuste do format no campo nmrescop (David Kruger).

               24/06/2014 - Conversão Progress >> Oracle (Renato - Supero)

  ............................................................................. */
  DECLARE

    ------------------------------- CURSORES ---------------------------------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
           , cop.nmrescop
           , cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper; -- CODIGO DA COOPERATIVA
    rw_crapcop     cr_crapcop%ROWTYPE;

    -- Buscar o diretorio no MAINFRAME da CIA HERING
    CURSOR cr_craptab(pr_nmsistem  craptab.nmsistem%TYPE
                     ,pr_tptabela  craptab.tptabela%TYPE
                     ,pr_cdempres  craptab.cdempres%TYPE
                     ,pr_cdacesso  craptab.cdacesso%TYPE
                     ,pr_tpregist  craptab.tpregist%TYPE)  IS
      SELECT dstextab
           , COUNT(*) over (PARTITION BY 1) qtregist
        FROM craptab
       WHERE craptab.cdcooper = pr_cdcooper
         AND craptab.nmsistem = pr_nmsistem
         AND craptab.tptabela = pr_tptabela
         AND craptab.cdempres = pr_cdempres
         AND craptab.cdacesso = pr_cdacesso
         AND craptab.tpregist = pr_tpregist;
    rw_craptab   cr_craptab%ROWTYPE;

    -- Buscar lançamentos a serem microfilmados
    CURSOR cr_craplcm(pr_dtiniper  DATE
                     ,pr_dtfimper  date) IS
      SELECT craplcm.cdcooper
           , craplcm.cdhistor
           , craplcm.dtmvtolt
           , craplcm.nrdconta
           , craplcm.nrdocmto
           , craplcm.vllanmto
           , craplcm.cdpesqbb
           , craplcm.nrdctabb
           , row_number() OVER(PARTITION BY craplcm.dtmvtolt ORDER BY craplcm.dtmvtolt) dtmvtini
           , COUNT(1)     OVER(PARTITION BY craplcm.dtmvtolt ORDER BY craplcm.dtmvtolt) dtqtdmvt
        FROM craplcm
       WHERE craplcm.cdcooper  = pr_cdcooper
         AND craplcm.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper
         AND craplcm.cdhistor IN (153,156)
       ORDER BY craplcm.dtmvtolt
              , craplcm.nrdctabb
              , craplcm.nrdocmto;

    -- Buscar os dados do histórico
    CURSOR cr_craphis(pr_cdcooper   craphis.cdcooper%TYPE
                     ,pr_cdhistor   craphis.cdhistor%TYPE) IS
      SELECT craphis.dshistor
           , craphis.indebcre
        FROM craphis
       WHERE craphis.cdcooper = pr_cdcooper
         AND craphis.cdhistor = pr_cdhistor;

    -- TIPOS
    TYPE tb_reg_cabmex IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

    -- CURSOR GENÉRICO DE CALENDÁRIO
    rw_crapdat      btch0001.cr_crapdat%ROWTYPE;

    -- VARIÁVEIS
    -- Código do programa
    vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS338';
    -- Registros de memória
    vr_tbcabmex     tb_reg_cabmex;
    -- Variáveis para relatório
    vr_rg_dshistor  VARCHAR2(100);
    vr_rg_indebcre  craphis.indebcre%TYPE;
    -- Variáveis diversas
    vr_nrdiglin     CONSTANT NUMBER := 132; -- indica a quantidade de caracteres padrão da linha
    vr_cfg_regis338 craptab.dstextab%TYPE;
    vr_cdhistor     craphis.cdhistor%TYPE;
    vr_dshistor     craphis.dshistor%TYPE;
    vr_indebcre     craphis.indebcre%TYPE;

    vr_idarquiv     UTL_FILE.file_type;

    vr_indsalto     CHAR;

    vr_des_erro     VARCHAR2(1000);
    vr_dsdireto     VARCHAR2(100);
    vr_nmarquiv     VARCHAR2(100);
    vr_nmmesref     VARCHAR2(20);
    vr_nmsufixo     VARCHAR2(10);

    vr_rg_nrdocmto  VARCHAR2(100);
    vr_rg_vllanmto  VARCHAR2(100);
    vr_rg_cdpesqbb  VARCHAR2(100);
    vr_rg_nrdctabb  VARCHAR2(100);
    vr_rg_nrdconta  VARCHAR2(100);
    vr_rg_lindetal  VARCHAR2(1000);

    vr_contlinh     NUMBER  := 0;
    vr_nrdordem     NUMBER  := 0;
    vr_tot_qtcompcr NUMBER  := 0;
    vr_tot_vlcompcr NUMBER  := 0;
    vr_tot_qtcompdb NUMBER  := 0;
    vr_tot_vlcompdb NUMBER  := 0;
    vr_ger_qtcompcr NUMBER  := 0;
    vr_ger_vlcompcr NUMBER  := 0;
    vr_ger_qtcompdb NUMBER  := 0;
    vr_ger_vlcompdb NUMBER  := 0;

    vr_flgfirst     BOOLEAN := TRUE;
    vr_regexist     BOOLEAN := FALSE;

    vr_dtmvtolt     DATE;
    vr_dtrefere     DATE;

    -- TRATAMENTO DE ERROS
    vr_exc_saida    EXCEPTION;
    vr_exc_fimprg   EXCEPTION;
    vr_cdcritic     PLS_INTEGER;
    vr_dscritic     VARCHAR2(4000);

    -- Função para adicionar os espaços na linha, para prencher com o total
    -- de dígitos, conforme definido na constante vr_nrdiglin
    FUNCTION fn_conflinh(pr_dsinform IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      -- Retornar a linha com os caracteres preenchidos
      RETURN RPAD(pr_dsinform, vr_nrdiglin,' ');
    END fn_conflinh;

  BEGIN

    -- INCLUIR NOME DO MÓDULO LOGADO
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);

    -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;

    -- SE NÃO ENCONTRAR
    IF cr_crapcop%NOTFOUND THEN
      -- FECHAR O CURSOR POIS HAVERÁ RAISE
      CLOSE cr_crapcop;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE cr_crapcop;
    END IF;

    -- LEITURA DO CALENDÁRIO DA COOPERATIVA
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;

    -- SE NÃO ENCONTRAR
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
      CLOSE btch0001.cr_crapdat;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- VALIDAÇÕES INICIAIS DO PROGRAMA
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);

    -- Este trecho estava comentado no fonte original
    -- SE A VARIAVEL DE ERRO É <> 0
    /*IF vr_cdcritic <> 0 THEN
      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      RAISE vr_exc_saida;
    END IF;*/

    -- Buscar o diretorio no MAINFRAME da CIA HERING
    OPEN  cr_craptab('CRED'              -- nmsistem
                    ,'CONFIG'            -- tptabela
                    ,rw_crapcop.cdcooper -- cdempres
                    ,'MICROFILMA'        -- cdacesso
                    ,000);               -- tpregist
    FETCH cr_craptab INTO rw_craptab;
    -- Verifica se retornou um registro... e apenas um
    IF cr_craptab%NOTFOUND OR rw_craptab.qtregist > 1 THEN
      -- Fecha o cursor
      CLOSE cr_craptab;

      -- Define a critica: 652 - Falta tabela de configuracao da cooperativa
      vr_cdcritic := 652;
      vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- ERRO TRATATO
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - '   || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic ||
                                                    ' - CRED-CONFIG-NN-MICROFILMA-000');

      -- Limpar as variáveis de erro
      vr_cdcritic := NULL;
      vr_dscritic := NULL;

      -- Sai da Rotina
      RETURN;

    END IF;

    -- Limpar o registro
    rw_craptab      := NULL;

    -- Fechamento do cursor
    CLOSE cr_craptab;

     -- Buscar os parametros de execucao do programa
    OPEN  cr_craptab('CRED'              -- nmsistem
                    ,'CONFIG'            -- tptabela
                    ,rw_crapcop.cdcooper -- cdempres
                    ,'MICROFILMA'        -- cdacesso
                    ,338);               -- tpregist
    FETCH cr_craptab INTO rw_craptab;
    -- Verifica se retornou um registro... e apenas um
    IF cr_craptab%NOTFOUND OR rw_craptab.qtregist > 1 THEN
      -- Fecha o cursor
      CLOSE cr_craptab;

      -- Define a critica: 652 - Falta tabela de configuracao da cooperativa
      vr_cdcritic := 652;
      vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- ERRO TRATATO
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - '   || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic ||
                                                    ' - CRED-CONFIG-NN-MICROFILMA-338');

      -- Limpar as variáveis de erro
      vr_cdcritic := NULL;
      vr_dscritic := NULL;

      -- Sai da Rotina
      RETURN;

    END IF;

    -- Guardar o valor do parametro
    vr_cfg_regis338 := rw_craptab.dstextab;

    -- Fechamento do cursor
    CLOSE cr_craptab;

    -- Verifica se o programa deve rodar para esta Cooperativa
    IF to_number(SUBSTR(vr_cfg_regis338,1,1)) <> 1   THEN
      -- CHAMAMOS A FIMPRG PARA ENCERRARMOS O PROCESSO SEM PARAR A CADEIA
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- EFETUAR COMMIT
      COMMIT;

      -- Sair da rotina
      RETURN;
    END IF;

    -- Limpar tabela de memória
    vr_tbcabmex.DELETE();

    -- Buscar o diretório e o prefixo do nome do arquivo dos parametros do sistema
    vr_dsdireto := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdacesso => 'CRPS338_DIR_MICROFILM');
    vr_nmarquiv := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'CRPS338_ARQ_MICROFILM');

    -- Definir a data -> Primeiro dia do mês anterior
    vr_dtmvtolt := TRUNC(ADD_MONTHS(rw_crapdat.dtmvtolt,-1),'MM');
    -- Definir a data -> Último dia do mês anterior
    vr_dtrefere := LAST_DAY(vr_dtmvtolt);
    -- Define o sufixo para os arquivos
    vr_nmsufixo := '.'||to_char(vr_dtrefere,'YYYYMM');
    -- Mes de referencia
    vr_nmmesref := GENE0001.vr_vet_nmmesano( to_number(to_char(vr_dtmvtolt,'MM')) )||'/'||to_char(vr_dtmvtolt,'YYYY');

    -- Definir texto de cabeçalho
    vr_tbcabmex(01) := RPAD(rw_crapcop.nmrescop,20,' ')||
                       ' **** LANCAMENTOS INTEGRADOS VIA COMPEN'||
                       'SACAO DA CAIXA ECONOMICA NO MES DE '||vr_nmmesref||' ****';

    vr_tbcabmex(03) := 'CONTA BASE     CONTA/DV   DOCUMENTO   COD. PESQUISA'||
                       '                    VALOR D/C HISTORICO            ';

    vr_tbcabmex(06) := LPAD('-',102,'-');

    -- Criar o arquivo a ser impresso pelo programa
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto              --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarquiv||vr_nmsufixo --> Nome do arquivo
                            ,pr_tipabert => 'W'                      --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_idarquiv              --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);

    -- Se retornar erro
    IF vr_des_erro IS NOT NULL THEN
      pr_cdcritic := 0;
      pr_dscritic := vr_des_erro;
      -- Raise para exception de saída
      RAISE vr_exc_saida;
    END IF;

    -- Pesquisa todos os lançamentos a serem microfilmados
    FOR rw_craplcm IN cr_craplcm(vr_dtmvtolt, vr_dtrefere) LOOP
      -- Verifica se mudou o código do histórico
      IF rw_craplcm.cdhistor <> NVL(vr_cdhistor,-1) THEN
        -- Atualizar o controle para o histório e limpar demais variáveis
        vr_cdhistor := rw_craplcm.cdhistor;
        vr_dshistor := NULL;
        vr_indebcre := NULL;

        -- Buscar os dados do histórico
        OPEN  cr_craphis(rw_craplcm.cdcooper
                        ,rw_craplcm.cdhistor);
        FETCH cr_craphis INTO vr_dshistor
                            , vr_indebcre;

        -- Se encontrar o registro de histórico
        IF cr_craphis%NOTFOUND THEN
          vr_rg_dshistor := to_char(rw_craplcm.cdhistor,'0000')||' - '||LPAD('*',15,'*');
          vr_rg_indebcre := '*';
        ELSE
          vr_rg_dshistor := to_char(rw_craplcm.cdhistor,'0000')||' - '||vr_dshistor;
          vr_rg_indebcre := vr_indebcre;
        END IF;

        -- fechar o cursor
        CLOSE cr_craphis;

      END IF;

      -- Guardar valores formatados
      vr_rg_nrdocmto := GENE0002.fn_mask(rw_craplcm.nrdocmto,'zzz.zzz.9');
      vr_rg_vllanmto := to_char(rw_craplcm.vllanmto,'FM999G999G999G999G990D00');
      vr_rg_cdpesqbb := RPAD(rw_craplcm.cdpesqbb,13,' ');
      vr_rg_nrdctabb := GENE0002.fn_mask_conta(rw_craplcm.nrdctabb);
      vr_rg_nrdconta := GENE0002.fn_mask_conta(rw_craplcm.nrdconta);
      -- Monta a linha
      vr_rg_lindetal := RPAD(vr_rg_nrdctabb,10,' ')||'   '||
                        RPAD(vr_rg_nrdconta,10,' ')||'   '||
                        RPAD(vr_rg_nrdocmto,09,' ')||'   '||
                        RPAD(vr_rg_cdpesqbb,13,' ')||'   '||
                        RPAD(vr_rg_vllanmto,22,' ')||'  ' ||
                        RPAD(vr_rg_indebcre,01,' ')||'  ' ||
                        RPAD(vr_rg_dshistor,21,' ');

      -- Se for a primeira quebra por data
      IF rw_craplcm.dtmvtini = 1 OR vr_contlinh = 84 THEN

        -- Se for o primeiro registro da data
        IF rw_craplcm.dtmvtini = 1 THEN
         -- Define o cabeçalho 2
          vr_tbcabmex(02) := 'DATA: '||to_char(rw_craplcm.dtmvtolt,'dd/mm/yyyy')||LPAD(' ',77,' ')||'SEQ.: ';
          -- Se a flag indicar que é o primeiro
          IF vr_flgfirst THEN
            -- Setar para False
            vr_flgfirst     := FALSE;
            vr_indsalto     := '+';
          ELSE
            vr_indsalto     := '1';
          END IF;
        ELSIF vr_contlinh = 84 THEN
          vr_indsalto := '1';
        END IF;

        -- Atualiza o contador de linha
        vr_contlinh := 5;

        --> Trecho - Include: crps046_1.i
        -- Escreve a linha no arquivo - Cabeçalho 1
        GENE0001.pc_escr_linha_arquivo(vr_idarquiv,vr_indsalto||fn_conflinh(vr_tbcabmex(01)));
        --> Fim Trecho - Include

        --> Trecho - Include: crps046_2.i
        -- Atualizar variável de número de ordem
        vr_nrdordem := NVL(vr_nrdordem,0) + 1;

        GENE0001.pc_escr_linha_arquivo(vr_idarquiv,'0'||fn_conflinh(vr_tbcabmex(02)||to_char(vr_nrdordem,'FM9G990')));
        --> Fim Trecho - Include

        --> Trecho - Include: crps046_3.i
        -- Escreve a linha no arquivo - Cabeçalho 3
        GENE0001.pc_escr_linha_arquivo(vr_idarquiv,'0'||fn_conflinh(vr_tbcabmex(03)));
        --> Fim Trecho - Include

      END IF; -- rw_craplcm.dtmvtini = 1 OR vr_contlinh = 84

      --> Trecho - Include: crps046_7.i
      -- Escreve a linha no arquivo - DETALHE
      GENE0001.pc_escr_linha_arquivo(vr_idarquiv,' '||fn_conflinh(vr_rg_lindetal));
      --> Fim Trecho - Include

      -- Se for indicado como Débito
      IF vr_rg_indebcre = 'D' THEN
        -- Adiciona a quantidade
        vr_tot_qtcompdb := NVL(vr_tot_qtcompdb,0) + 1;
        -- Sumariza o valor
        vr_tot_vlcompdb := NVL(vr_tot_vlcompdb,0) + rw_craplcm.vllanmto;
      ELSIF vr_rg_indebcre = 'C' THEN  -- Se for indicado como Crédito
         -- Adiciona a quantidade
        vr_tot_qtcompcr := NVL(vr_tot_qtcompcr,0) + 1;
        -- Sumariza o valor
        vr_tot_vlcompcr := NVL(vr_tot_vlcompcr,0) + rw_craplcm.vllanmto;
      END IF;

      -- Se for o último registro para a data de movimento
      IF rw_craplcm.dtqtdmvt = rw_craplcm.dtmvtini THEN
        -- montar a linha dos totais
        vr_tbcabmex(05) := 'TOTAIS:  A DEBITO: '||
                           to_char(vr_tot_qtcompdb,'FM999G990')||' - '||
                           to_char(vr_tot_vlcompdb,'FM999G999G999G999G990D00')||
                           '        A CREDITO: '||
                           to_char(vr_tot_qtcompcr,'FM999G990')||' - '||
                           to_char(vr_tot_vlcompcr,'FM999G999G999G999G990D00');

        -- Atualizar os valores dos totalizadores gerais
        vr_ger_qtcompcr := NVL(vr_ger_qtcompcr,0) + vr_tot_qtcompcr;
        vr_ger_vlcompcr := NVL(vr_ger_vlcompcr,0) + vr_tot_vlcompcr;
        vr_ger_qtcompdb := NVL(vr_ger_qtcompdb,0) + vr_tot_qtcompdb;
        vr_ger_vlcompdb := NVL(vr_ger_vlcompdb,0) + vr_tot_vlcompdb;
        -- Zerar os totalizadores parciais
        vr_tot_qtcompcr := 0;
        vr_tot_vlcompcr := 0;
        vr_tot_qtcompdb := 0;
        vr_tot_vlcompdb := 0;
        -- Zerar a variável de ordem
        vr_nrdordem := 0;

        -- Se contador de linha maior que 80
        IF vr_contlinh > 80 THEN
          vr_indsalto := '1';
          --> Trecho - Include: crps046_1.i
          -- Escreve a linha no arquivo - Cabeçalho 1
          GENE0001.pc_escr_linha_arquivo(vr_idarquiv,vr_indsalto||fn_conflinh(vr_tbcabmex(01)));
          --> Fim Trecho - Include

          --> Trecho - Include: crps046_2.i
          -- Atualizar variável de número de ordem
          vr_nrdordem := NVL(vr_nrdordem,0) + 1;

          -- atualiza o contador de linha
          vr_contlinh := 7;
        ELSE
          -- atualiza o contador de linha
          vr_contlinh := NVL(vr_contlinh,0) + 4;
        END IF;

        --> Trecho - Include: crps046_5.i
        -- Escreve a linha no arquivo - Informação 5
        GENE0001.pc_escr_linha_arquivo(vr_idarquiv,'0'||fn_conflinh(vr_tbcabmex(05)));
        --> Fim Trecho - Include

        --> Trecho - Include: crps046_6.i
        -- Escreve a linha no arquivo - Informação 6
        GENE0001.pc_escr_linha_arquivo(vr_idarquiv,'0'||fn_conflinh(vr_tbcabmex(06)));
        --> Fim Trecho - Include

      END IF; -- Last dtmvtolt

      -- flag indicando existencia de registros
      vr_regexist := TRUE;

    END LOOP; -- Fim do CR_CRAPLCM da pesquisa dos lancamentos

    -- Montar a linha dos totais gerais
    vr_tbcabmex(05) := '         A DEBITO: '||
                       to_char(vr_ger_qtcompdb,'FM999G990')||' - '||
                       to_char(vr_ger_vlcompdb,'FM999G999G999G999G990D00')||
                       '        A CREDITO: '||
                       to_char(vr_ger_qtcompcr,'FM999G990')||' - '||
                       to_char(vr_ger_vlcompcr,'FM999G999G999G999G990D00');
    -- Cabeçalho para total geral
    vr_tbcabmex(03) := 'TOTAL GERAL';
    -- Indicador da linha
    vr_indsalto := '1';

    --> Trecho - Include: crps046_1.i
    -- Escreve a linha no arquivo - Cabeçalho 1
    GENE0001.pc_escr_linha_arquivo(vr_idarquiv,vr_indsalto||fn_conflinh(vr_tbcabmex(01)));
    --> Fim Trecho - Include

    --> Trecho - Include: crps046_3.i
    -- Escreve a linha no arquivo - Cabeçalho 3
    GENE0001.pc_escr_linha_arquivo(vr_idarquiv,'0'||fn_conflinh(vr_tbcabmex(03)));
    --> Fim Trecho - Include

    --> Trecho - Include: crps046_5.i
    -- Escreve a linha no arquivo - Informação 5
    GENE0001.pc_escr_linha_arquivo(vr_idarquiv,'0'||fn_conflinh(vr_tbcabmex(05)));
    --> Fim Trecho - Include

    --> Trecho - Include: crps046_6.i
    -- Escreve a linha no arquivo - Informação 6
    GENE0001.pc_escr_linha_arquivo(vr_idarquiv,'0'||fn_conflinh(vr_tbcabmex(06)));
    --> Fim Trecho - Include

    -- Fechar o arquivo
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_idarquiv);


    -- PROCESSO OK, DEVEMOS CHAMAR A FIMPRG
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- SALVAR INFORMAÇÕES ATUALIZADAS
    COMMIT;
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- ERRO TRATATO
                                ,pr_des_log      => to_char(sysdate,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);

      -- CHAMAMOS A FIMPRG PARA ENCERRARMOS O PROCESSO SEM PARAR A CADEIA
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- EFETUAR COMMIT
      COMMIT;
    WHEN vr_exc_saida THEN
      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- DEVOLVEMOS CÓDIGO E CRITICA ENCONTRADAS DAS VARIAVEIS LOCAIS
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      -- EFETUAR ROLLBACK
      ROLLBACK;
    WHEN OTHERS THEN
      -- EFETUAR RETORNO DO ERRO NÃO TRATADO
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- EFETUAR ROLLBACK
      ROLLBACK;
  END;

END pc_crps338;
/

