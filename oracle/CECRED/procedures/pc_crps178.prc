CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps178 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
      /* .............................................................................

       Programa: pc_crps178                         (Fontes/crps178.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Data    : Novembro/96.                      Ultima atualizacao: 23/01/2014

       Dados referentes ao programa:

       Frequencia: Anual (Batch)
       Objetivo  : Calculo do retorno sobre o capital.
                   Atende a solicitacao 026, ordem 2.
                   Emite relatorio 148.

       Alteracoes: 09/11/98 - Tratar situacao em prejuizo (Deborah).

                   03/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

                  14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                  23/01/2014 - Conversão Progress para PLSQL (Odirlei/AMcom)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS178';

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
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      /*  Le registro de capital e calcula retorno sobre o capital  */
      CURSOR cr_crapcot IS
        SELECT nrdconta,
               rowid,
               vlcapmes##1,
               vlcapmes##2,
               vlcapmes##3,
               vlcapmes##4,
               vlcapmes##5,
               vlcapmes##6,
               vlcapmes##7,
               vlcapmes##8,
               vlcapmes##9,
               vlcapmes##10,
               vlcapmes##11,
               vlcapmes##12
          FROM crapcot
         WHERE crapcot.cdcooper = pr_cdcooper;

      /* Buscar associado do registro de capital */
      CURSOR cr_crapass (pr_nrdconta crapass.nrdconta%type) IS
        SELECT nrdconta,
               cdsitdtl,
               dtelimin,
               nrmatric,
               nmprimtl
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%rowtype;

      /* Buscar Transferencia e Duplicacao de Matricula */
      CURSOR cr_craptrf (pr_nrdconta crapass.nrdconta%type) IS
        SELECT 1
          FROM craptrf
         WHERE craptrf.cdcooper = pr_cdcooper
           AND craptrf.nrdconta = pr_nrdconta
           AND craptrf.tptransa = 1  -- Transferencia
           AND craptrf.insittrs = 2; -- Feito
      rw_craptrf cr_craptrf%rowtype;

      -- Buscar as informações para restart e Rowid para atualização posterior
      CURSOR cr_crapres IS
        SELECT res.dsrestar
              ,res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND res.cdprogra = vr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      -- type para armazenar taxas de retorno
      TYPE typ_txmesret is
         varray(12) of NUMBER(26,6);
      vr_tab_txmesret typ_txmesret := typ_txmesret(0,0,0,0,0,0,0,0,0,0,0,0);

      -- type para valor moeda fixada
      TYPE typ_vlmoefix is
         varray(12) of NUMBER(26,6);
      vr_tab_vlmoefix typ_vlmoefix := typ_vlmoefix(0,0,0,0,0,0,0,0,0,0,0,0);

      -- Type para armazenar os valores de capitalização mes
      TYPE typ_tab_vlcapmes IS VARRAY(12) OF NUMBER;
      vr_tab_vlcapmes typ_tab_vlcapmes := typ_tab_vlcapmes(0,0,0,0,0,0,0,0,0,0,0,0);

      -- type para valor retorno do capital
      TYPE typ_vlretcap is
         varray(12) of NUMBER(26,6);
      vr_tab_vlretcap typ_vlretcap;

      --armazenar os totais de mes
      vr_tot_vlretcap typ_vlretcap := typ_vlretcap(0,0,0,0,0,0,0,0,0,0,0,0);
      --armazenar os totais de capital por mes
      vr_tot_vlcapmes typ_vlretcap := typ_vlretcap(0,0,0,0,0,0,0,0,0,0,0,0);

      -- Type para armazenar os dados que serão exibidos no relatorio ordenado
      TYPE typ_rec_relat is
                record ( cddinteg     NUMBER
                        ,nrdconta     crapcot.nrdconta%type
                        ,nrmatric     crapass.nrmatric%type
                        ,nmprimtl     crapass.nmprimtl%type
                        ,tot_vlretmfx NUMBER(26,4)
                        ,vlretcap     typ_vlretcap := typ_vlretcap(0,0,0,0,0,0,0,0,0,0,0,0));
      type typ_tab_relat is table of typ_rec_relat
                           index by varchar2(11); --cddinteg(1)+nrdconta(11)
      vr_tab_relat typ_tab_relat;

      -- Temp table para armazenar os registros da crapcot, melhorar performace
      TYPE typ_reg_crapcot IS
        RECORD(nrdconta crapcot.nrdconta%TYPE,
               vlcapmes typ_tab_vlcapmes := typ_tab_vlcapmes(0,0,0,0,0,0,0,0,0,0,0,0),
               rowid_cot rowid
               );
      TYPE typ_tab_crapcot IS
        TABLE OF typ_reg_crapcot
          INDEX BY varchar2(15); -- Nrdconta
      vr_tab_crapcot typ_tab_crapcot;

      ------------------------------- VARIAVEIS -------------------------------
      -- Variáveis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE;      --> Número da conta de restart
      vr_dsrestar VARCHAR2(4000);             --> String genérica com informações para restart
      vr_inrestar INTEGER;                    --> Indicador de Restart

      vr_nmarqctr     VARCHAR2(500);      -- arquivo de controle "arq/calculo_178"
      vr_nmarqjur     VARCHAR2(500) := 'retorno178.dat'; -- arquivo com o retorno da 178
      vr_nmarqimp     VARCHAR2(500);      -- nome do relatorio
      vr_nom_direto   VARCHAR2(500);      -- diretorio padrçao da coop
      vr_contador     INTEGER;            -- Contador de mês
      vr_tot_vlretmfx NUMBER;             -- valores totais com taxa fixa
      vr_tot_vljurass NUMBER;             -- valores totais de juros do associado
      vr_ger_vlretcap NUMBER;             -- valore geral de retorno de capital
      vr_tot_vljurcre NUMBER;             -- valore totais de juros de credito
      vr_tot_vljurncr NUMBER;             -- valore totais de juros de associado
      vr_tot_qtjurncr NUMBER;             -- Qtd total de juros de associado
      vr_tot_qtjurcre NUMBER;             -- Qtd total de juros de credito
      vr_cddinteg     INTEGER;            -- identificação se integrou
      vr_nrdconta     crapass.nrdconta%type;           -- numero da conta
      vr_cdagenci     crapass.cdagenci%type := 1;      -- codigo da agencia que será apresentado no relatorio
      vr_cdbccxlt     crapban.cdbccxlt%type := 100;    -- Codigo do banco que será apresentado no relatorio
      vr_nrdolote     craplot.nrdolote%type := 8004;   -- numero do lote que será apresentado no relatorio
      vr_nrdocmto     craplcm.nrdocmto%type := 8004063;-- Numero do  documento que será apresentado no relatorio

      vr_idx          VARCHAR2(11);       -- Indice da temptable
      vr_utlfileh     UTL_FILE.file_type; -- Handle do arquivo
      vr_linhadet     VARCHAR2(4000);     -- Linha do arquivo
      vr_typ_said     VARCHAR2(100);      -- Tipo de saída do comando Host
      vr_tab_campos   gene0002.typ_split; -- Temp table para leitura dos campos da linha do arquivo txt
      vr_flgresum     BOOLEAN := FALSE;   -- Flag de controle de resumo
      vr_nrseqint     NUMBER := 0;        -- Sequancial de controle
      vr_vlmoefix     NUMBER(26,6) := 0;        -- Valor de moeda no parametro
      vr_txmesret     NUMBER(26,6) := 0;        -- Taxa de retorno no parametro

      -- Variavel para armazenar as informacos em XML
      vr_des_xml       clob;
      vr_Bufdes_xml    varchar2(32000) := null;

      vr_pos number := 0;
      --------------------------- SUBROTINAS INTERNAS --------------------------
      --Escrever no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN varchar2,
                               pr_fimarq    IN BOOLEAN default false) IS
      BEGIN
        --Verificar se ja atingiu o tamanho do buffer, ou se é o final do xml
        IF length(vr_Bufdes_xml) + length(pr_des_dados) > 31000 OR pr_fimarq THEN
          --Escrever no arquivo XML
          vr_des_xml := vr_des_xml||vr_Bufdes_xml||pr_des_dados;
          vr_Bufdes_xml := null;
        ELSE
          --armazena no buffer
          vr_Bufdes_xml := vr_Bufdes_xml||pr_des_dados;
        END IF;

      END;

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

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

      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Código de erro
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro
      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Se houver indicador de restart, mas não veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;
      END IF;

      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Buscar as informações para restart e Rowid para atualização posterior
        OPEN cr_crapres;
        FETCH cr_crapres
         INTO rw_crapres;
        -- Se não tiver encontrador
        IF cr_crapres%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crapres;
          -- Montar mensagem de critica
          vr_cdcritic := 151;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor para continuar
          CLOSE cr_crapres;
        END IF;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      IF TO_CHAR(rw_crapdat.dtmvtolt,'MM') <> '12' THEN           /*  Somente roda em DEZEMBRO  */
           pr_infimsol := 1;
           RAISE vr_exc_fimprg;
      END IF;

      --Buscar valores dos parametros
      vr_txmesret := gene0002.fn_char_para_number(gene0001.fn_param_sistema('CRED',pr_cdcooper,'TXMESRET_CRPS178'));
      vr_vlmoefix := gene0002.fn_char_para_number(gene0001.fn_param_sistema('CRED',pr_cdcooper,'VLMOEFIX_CRPS178'));

      -- Inicializar variaveis
      FOR idx IN 1..12 LOOP
       vr_tab_txmesret(idx) := vr_txmesret; /*    ver com Adelino   */
      END LOOP;

      FOR idx IN 1..12 LOOP
       vr_tab_vlmoefix(idx) := vr_vlmoefix; /*    ver com Adelino   */
      END LOOP;

      /*  Le registro de capital e calcula retorno sobre o capital  */
      FOR rw_crapcot IN cr_crapcot LOOP
        vr_tab_crapcot(rw_crapcot.nrdconta).nrdconta := rw_crapcot.nrdconta;
        vr_tab_crapcot(rw_crapcot.nrdconta).rowid_cot:= rw_crapcot.rowid;

        -- popular temptable com os valores de capital mes
        FOR idx IN 1..12 LOOP
          CASE idx
            WHEN  1 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##1;
            WHEN  2 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##2;
            WHEN  3 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##3;
            WHEN  4 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##4;
            WHEN  5 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##5;
            WHEN  6 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##6;
            WHEN  7 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##7;
            WHEN  8 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##8;
            WHEN  9 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##9;
            WHEN 10 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##10;
            WHEN 11 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##11;
            WHEN 12 THEN vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes(idx):= rw_crapcot.vlcapmes##12;
          END CASE;
        END LOOP;
      END LOOP;

      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                              ,pr_cdcooper => pr_cdcooper);

      vr_nmarqctr := vr_nom_direto||'/arq/calculo_178';

      /*  Verifica se o arquivo de retorno ja foi criado e esta completo .......... */
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqctr) = false THEN
        /*  Le registro de capital e calcula retorno sobre o capital  */
        FOR rw_crapcot IN cr_crapcot LOOP
          -- Buscar associado
          OPEN cr_crapass(pr_nrdconta => rw_crapcot.nrdconta);
          FETCH cr_crapass
            INTO rw_crapass;

          IF cr_crapass%NOTFOUND THEN
            --se não encontrar associado, gerar log e abortar
            vr_cdcritic  := 251;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic || ' CONTA = ' ||
                                                          rw_crapcot.nrdconta );
            close cr_crapass;
            RAISE vr_exc_saida;
          ELSE
            --somente fechar
            close cr_crapass;
          END IF;

          -- verificar se a conta esta bloqueada
          IF rw_crapass.cdsitdtl in ( 2,--	NORMAL C/BLOQ.
                                      4,--	DEMITIDO C/BLOQ
                                      5,--	NORMAL C/PREJ.
                                      6,--	NORMAL BLQ.PREJ
                                      7,--	DEMITIDO C/PREJ
                                      8	--DEM. BLOQ.PREJ.
                                      ) THEN
            -- Buscar transferencia feitas
            OPEN cr_craptrf(pr_nrdconta => rw_crapass.nrdconta);
            FETCH cr_craptrf
              INTO rw_craptrf;
            IF cr_craptrf%NOTFOUND THEN
              --se não existir apenas fechar
              CLOSE cr_craptrf;
            ELSE
              -- se encontra, ir para o proximo registro de capital
              CLOSE cr_craptrf;
              CONTINUE;
            END IF;

          END IF;

          -- popular temptable com os valores de capital mes
          FOR idx IN 1..12 LOOP
            CASE idx
              WHEN  1 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##1;
              WHEN  2 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##2;
              WHEN  3 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##3;
              WHEN  4 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##4;
              WHEN  5 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##5;
              WHEN  6 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##6;
              WHEN  7 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##7;
              WHEN  8 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##8;
              WHEN  9 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##9;
              WHEN 10 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##10;
              WHEN 11 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##11;
              WHEN 12 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##12;
            END CASE;
          END LOOP;

          -- inicializar variaveis
          vr_tab_vlretcap := typ_vlretcap(0,0,0,0,0,0,0,0,0,0,0,0);
          vr_contador := 1;

          --Calcular valor re retorno do capital para os 12 meses
          vr_tab_vlretcap(vr_contador) := apli0001.fn_round(vr_tab_vlcapmes(vr_contador) *
                                                             vr_tab_txmesret(vr_contador),2);

          vr_tot_vlretmfx := apli0001.fn_round(vr_tab_vlretcap(vr_contador) /
                                               vr_tab_vlmoefix(vr_contador),4);

          -- Calcular do mes 2 ao 12
          FOR vr_contador IN 2..12 LOOP
            vr_tab_vlretcap(vr_contador) := apli0001.fn_round( (vr_tab_vlcapmes(vr_contador) +
                                                               (vr_tot_vlretmfx * vr_tab_vlmoefix(vr_contador))) *
                                                              vr_tab_txmesret(vr_contador),2);

            vr_tot_vlretmfx := vr_tot_vlretmfx + apli0001.fn_round(vr_tab_vlretcap(vr_contador) /
                                                                   vr_tab_vlmoefix(vr_contador),4);
          END LOOP;


          IF rw_crapass.dtelimin is not null THEN   /*  Nao paga p/ eliminados  */
            vr_cddinteg := 2;
          ELSE
            vr_cddinteg := 1;
          END IF;

          --Popular temptable dos registros do relatorio ordenado por pelo indicador de integr. e conta ..
          vr_idx := vr_cddinteg || lpad(rw_crapcot.nrdconta,10,'0');
          vr_tab_relat(vr_idx).cddinteg := vr_cddinteg;
          vr_tab_relat(vr_idx).nrdconta := rw_crapcot.nrdconta;
          vr_tab_relat(vr_idx).nrmatric := rw_crapass.nrmatric;
          vr_tab_relat(vr_idx).nmprimtl := rw_crapass.nmprimtl;
          vr_tab_relat(vr_idx).tot_vlretmfx := vr_tot_vlretmfx;
          vr_tab_relat(vr_idx).vlretcap := vr_tab_vlretcap;

        END LOOP; -- Fim Loop cr_crapcot

        --Gerar arquivo .arq/retorno178.dat
        -- criar arquivo
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_direto||'/arq'  --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_nmarqjur    --> Nome do arquivo -- 'retorno178.dat'
                                ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_utlfileh    --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        vr_idx := vr_tab_relat.first;
        LOOP
          EXIT WHEN vr_idx is null;

          -- Montar linha do arquivo
          vr_linhadet :=   vr_tab_relat(vr_idx).cddinteg||' '||   /*  CONTR  */
                           gene0002.fn_mask(vr_tab_relat(vr_idx).nrdconta,'99999999')||' '||   /*  CONTA  */
                           TO_CHAR(vr_tab_relat(vr_idx).tot_vlretmfx,'fm00000000D0000')||' ';   /*  JURMFX */

          --gerar dados dos 12 meses
          FOR idx IN 1..12 LOOP
            vr_linhadet := vr_linhadet||TO_CHAR(vr_tab_relat(vr_idx).vlretcap(idx),'fm0000000000D00')||' '; /*  RET.  */
          END LOOP;

          --Gravar linha no arquivo
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh   --> Handle do arquivo aberto
                                        ,pr_des_text => vr_linhadet );--> Texto para escrita

          -- Ir para o proximo registro
          vr_idx := vr_tab_relat.next(vr_idx);
        END LOOP;

        -- Linha final do arquivo
        vr_linhadet := '9 99999999 99999999,9999 '||
                       '9999999999,99 9999999999,99 9999999999,99 '||
                       '9999999999,99 9999999999,99 9999999999,99 '||
                       '9999999999,99 9999999999,99 9999999999,99 '||
                       '9999999999,99 9999999999,99 9999999999,99';

        --Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh   --> Handle do arquivo aberto
                                      ,pr_des_text => vr_linhadet );--> Texto para escrita

        -- fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);

        /*  Criar arquivo de controle  */
        gene0001.pc_OScommand_Shell(pr_des_comando => '>  '||vr_nmarqctr ||' 2> /dev/null'
                                    ,pr_typ_saida   => vr_typ_said
                                    ,pr_des_saida   => vr_dscritic);
        -- Testar erro
        IF vr_typ_said = 'ERR' THEN
          -- O comando shell executou com erro, gerar log e sair do processo
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao mover cria o arquivo '||vr_nmarqctr;
          RAISE vr_exc_saida;
        END IF;


      ELSE

        --Se o arquivo de controle existe, deve ser lido as informações no arquivo retorno178.dat
        -- pois esta no restart
        IF vr_tab_relat.count = 0 THEN
          -- Abrir arquivo
          gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_direto||'/arq'  --> Diretorio do arquivo
                                  ,pr_nmarquiv => 'retorno178.dat' --> Nome do arquivo
                                  ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_utlfileh    --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- Ler Arquivo
          LOOP
            BEGIN
              gene0001.pc_le_linha_arquivo( pr_utlfileh => vr_utlfileh
                                           ,pr_des_text => vr_linhadet);

            EXCEPTION
              -- se apresentou erro de no_data_found é pq chegou no final do arquivo, fechar arquivo e sair do loop
              WHEN NO_DATA_FOUND THEN
                -- fechar arquivo
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
                EXIT;
            END;

            vr_cddinteg := NULL;
            vr_nrdconta := NULL;

            -- Retirar quebra de linha, para não gerar erros posteriormente ao qubrar a linha
            vr_linhadet := REPLACE(REPLACE(vr_linhadet,CHR(10)),CHR(13));

            --tratar linha
            vr_tab_campos := gene0002.fn_quebra_string( pr_string  => vr_linhadet
                                                       ,pr_delimit => ' ');
            --Ler informações
            IF vr_tab_campos.EXISTS(1) THEN
              vr_cddinteg := vr_tab_campos(1);
            END IF;

            IF vr_tab_campos.EXISTS(2) THEN
              vr_nrdconta := vr_tab_campos(2);
            END IF;
            --Gerar indice
            vr_idx := vr_cddinteg || lpad(vr_nrdconta,10,'0');
            vr_tab_relat(vr_idx).cddinteg := vr_cddinteg;
            vr_tab_relat(vr_idx).nrdconta := vr_nrdconta;

            IF vr_tab_campos.EXISTS(3) THEN
              vr_tab_relat(vr_idx).tot_vlretmfx := vr_tab_campos(3);
            END IF;
            -- buscar os valores dos 12 meses
            FOR idx IN 1..12 LOOP
              --verificar se existe informação na posição, começa apartir do 4
              IF vr_tab_campos.EXISTS(idx+3) THEN
                vr_tab_relat(vr_idx).vlretcap(idx) := vr_tab_campos(idx+3);
              END IF;
            END LOOP;

            -- se não for o ultimo registro, busca o associado
            IF vr_tab_relat(vr_idx).cddinteg <> 9    THEN
              -- Buscar associado
              OPEN cr_crapass(pr_nrdconta => vr_nrdconta);
              FETCH cr_crapass
                INTO rw_crapass;

              IF cr_crapass%NOTFOUND THEN
                --se não encontrar associado, gerar log e abortar
                vr_cdcritic  := 251;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_dscritic || ' CONTA = ' ||
                                                              vr_nrdconta );
                close cr_crapass;
                RAISE vr_exc_saida;
              ELSE
                --somente fechar
                close cr_crapass;
              END IF;

              vr_tab_relat(vr_idx).nrmatric := rw_crapass.nrmatric;
              vr_tab_relat(vr_idx).nmprimtl := rw_crapass.nmprimtl;
            END IF;
          END LOOP;

        END IF; -- Fim vr_tab_relat.count = 0
      END IF;

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      vr_pos := 0;

      vr_idx := vr_tab_relat.first;
      LOOP
        EXIT WHEN vr_idx is null;

        -- se for o 9, significa que é o ultimo registro
        IF vr_tab_relat(vr_idx).cddinteg = 9  THEN
          EXIT; --sair do loop
        END IF;

        -- Se for o primeiro registro, deve criar o inicio da tag
        IF vr_idx = vr_tab_relat.first THEN
            pc_escreve_xml('<creditos
                               dscredito="VALORES A SEREM CREDITADOS:"
                               idcredito="AC">');
        END IF;

        vr_tot_vljurass := apli0001.fn_round(vr_tab_relat(vr_idx).tot_vlretmfx * vr_tab_vlmoefix(12),2);
        vr_nrseqint     := nvl(vr_nrseqint,0) + 1;

        -- Se o juro do associado foi zero, pular para o proximo
        IF  vr_tot_vljurass = 0   THEN
          -- Ir para o proximo registro
          vr_idx := vr_tab_relat.next(vr_idx);
          continue;
        END IF;

        IF vr_tab_relat(vr_idx).cddinteg = 2 THEN
           -- verificar se deve exibir resumo
           IF NOT vr_flgresum THEN

             -- Somar valor dos 12 meses
             FOR idx IN 1..12 LOOP
               vr_ger_vlretcap := nvl(vr_ger_vlretcap,0) + vr_tot_vlretcap(idx);
             END LOOP;

             IF NVL(vr_tot_vljurcre,0) <> NVL(vr_ger_vlretcap,0)   THEN
               vr_tot_vlretcap(0012):= vr_tot_vlretcap(0012) +
                                       (NVL(vr_tot_vljurcre,0) - NVL(vr_ger_vlretcap,0));
               vr_ger_vlretcap      := vr_tot_vljurcre;
             END IF;

             --Montar nodo de resumo
             pc_escreve_xml('<resumo>');
             -- criar tags para os 12 meses
             FOR idx IN 1..12 LOOP
               pc_escreve_xml('  <Mes>
                                 <nmmesano>'||gene0001.vr_vet_nmmesano(idx)||'</nmmesano>
                                 <tot_vlcapmes>'||vr_tot_vlcapmes(idx)||'</tot_vlcapmes>
                                 <tot_vlretcap>'||vr_tot_vlretcap(idx)||'</tot_vlretcap>
                                 <tot_txmensal>'||TO_CHAR(vr_tab_txmesret(idx) * 100,'90D00000')||' %'||'</tot_txmensal>
                                 </Mes>
                              ');
             END LOOP;
             pc_escreve_xml('</resumo>
                             </creditos>');

             vr_flgresum := TRUE;

             -- inicar o segundo grupo de tag, referente aos registros de cddinteg = 2
             pc_escreve_xml('<creditos
                               dscredito="VALORES QUE NAO SERAO CREDITADOS - RETORNO CALCULADO PARA ASSOCIADOS EXCLUIDOS:"
                               idcredito="NC">');
           END IF; -- Fim NOT vr_flgresum

           -- Adicionar ao xml os não creditados
           pc_escreve_xml('<conta>
                              <nrdconta>'||gene0002.fn_mask_conta(vr_tab_relat(vr_idx).nrdconta)  ||'</nrdconta>
                              <nrmatric>'||gene0002.fn_mask_matric(vr_tab_relat(vr_idx).nrmatric) ||'</nrmatric>
                              <nmprimtl>'||substr(vr_tab_relat(vr_idx).nmprimtl,1,40)  ||'</nmprimtl>
                              <tot_vljurass>'|| vr_tot_vljurass  ||'</tot_vljurass>
                            </conta>');

           vr_tot_vljurncr := nvl(vr_tot_vljurncr,0) + nvl(vr_tot_vljurass,0);
           vr_tot_qtjurncr := nvl(vr_tot_qtjurncr,0) + 1;

           -- Ir para o proximo registro
           vr_idx := vr_tab_relat.next(vr_idx);
           continue; /*  Le o proximo registro  */
        END IF; -- FIM cddinteg = 2

        -- Adicionar ao xml os creditados
        pc_escreve_xml('<conta>
                          <nrdconta>'||gene0002.fn_mask_conta(vr_tab_relat(vr_idx).nrdconta)  ||'</nrdconta>
                          <nrmatric>'||gene0002.fn_mask_matric(vr_tab_relat(vr_idx).nrmatric) ||'</nrmatric>
                          <nmprimtl>'||substr(vr_tab_relat(vr_idx).nmprimtl,1,40)  ||'</nmprimtl>
                          <tot_vljurass>'|| vr_tot_vljurass  ||'</tot_vljurass>
                          <cdagenci>'|| vr_cdagenci          ||'</cdagenci>
                          <cdbccxlt>'|| vr_cdbccxlt          ||'</cdbccxlt>
                          <nrdolote>'|| gene0002.fn_mask(vr_nrdolote,'zzz.zz9')     ||'</nrdolote>
                          <nrdocmto>'|| gene0002.fn_mask_contrato(vr_nrdocmto)      ||'</nrdocmto>
                        </conta>');

        vr_tot_vljurcre := nvl(vr_tot_vljurcre,0) + nvl(vr_tot_vljurass,0);
        vr_tot_qtjurcre := nvl(vr_tot_qtjurcre,0) + 1;

        -- Buscar cota
        IF NOT vr_tab_crapcot.EXISTS(vr_tab_relat(vr_idx).nrdconta) THEN
          --se não encontrar, gerar log e abortar
          vr_cdcritic  := 169;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic || ' CONTA = ' ||
                                                        vr_tab_relat(vr_idx).nrdconta );
          RAISE vr_exc_saida;
        END IF;

        FOR idx IN 1..12 LOOP
          vr_tot_vlcapmes(idx) := nvl(vr_tot_vlcapmes(idx),0) + nvl(vr_tab_crapcot(vr_tab_relat(vr_idx).nrdconta).vlcapmes(idx),0);
          vr_tot_vlretcap(idx) := nvl(vr_tot_vlretcap(idx),0) +
                                  ROUND(ROUND(vr_tab_relat(vr_idx).vlretcap(idx) / vr_tab_vlmoefix(idx),4) *
                                        vr_tab_vlmoefix(12),2);
        END LOOP;

        -- Se estiver no restart, deve localizar o ultimo registro, equanto não encontrar vai para o proximo
        IF vr_inrestar > 0 THEN
          IF vr_nrseqint = vr_nrctares THEN
            vr_inrestar := 0;
            -- Ir para o proximo registro
            vr_idx := vr_tab_relat.next(vr_idx);
            continue; /*  Le o proximo registro  */
          ELSE
            -- Ir para o proximo registro
            vr_idx := vr_tab_relat.next(vr_idx);
            continue; /*  Le o proximo registro  */
          END IF;
        END IF;

        --Atualizar plano de capital
        BEGIN
          UPDATE crapcot
             SET crapcot.qtrsjmfx = vr_tot_vljurass
           WHERE crapcot.rowid = vr_tab_crapcot(vr_tab_relat(vr_idx).nrdconta).rowid_cot;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crapcot conta:'||vr_tab_relat(vr_idx).nrdconta||' :'||SQLerrm;
        END;

        --Fazer commit a cada 5000 contas processadas
        IF MOD(vr_nrseqint,5000) = 0 THEN
          --Atualizar restart
          BEGIN
            UPDATE crapres
               SET crapres.nrdconta = vr_nrseqint
             WHERE crapres.rowid = rw_crapres.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar restart(crapres) conta:'||vr_tab_relat(vr_idx).nrdconta||' :'||SQLerrm;
          END;
          -- efetua commit
          COMMIT;
        END IF;

        -- Ir para o proximo registro
        vr_idx := vr_tab_relat.next(vr_idx);
      END LOOP;

      IF vr_tot_vljurncr > 0 THEN
        pc_escreve_xml('</creditos>');
      ELSE
        -- Somar valor dos 12 meses
        FOR idx IN 1..12 LOOP
          vr_ger_vlretcap := nvl(vr_ger_vlretcap,0) + vr_tot_vlretcap(idx);
        END LOOP;

        IF vr_tot_vljurcre <> vr_ger_vlretcap   THEN
          vr_tot_vlretcap(0012) := vr_tot_vlretcap(0012) +
                                   vr_tot_vljurcre - vr_ger_vlretcap;

          vr_ger_vlretcap       := vr_tot_vljurcre;
        END IF;

        pc_escreve_xml('<conta/>');

        --Montar nodo de resumo
        pc_escreve_xml('<resumo>');
        -- criar tags para os 12 meses
        FOR idx IN 1..12 LOOP
          pc_escreve_xml('<Mes>
                            <nmmesano>'||gene0001.vr_vet_nmmesano(idx)||'</nmmesano>
                            <tot_vlcapmes>'||vr_tot_vlcapmes(idx)||'</tot_vlcapmes>
                            <tot_vlretcap>'||vr_tot_vlretcap(idx)||'</tot_vlretcap>
                            <tot_txmensal> %</tot_txmensal>
                          </Mes>
                         ');
        END LOOP;
        pc_escreve_xml('</resumo>
                        </creditos>');
      END IF;

      -- passar instrução para finalizar o buffer do clob
      pc_escreve_xml(null,true);

      -- Inclir tags de definição do xml, e grupo inicial
      vr_des_xml := '<?xml version="1.0" encoding="utf-8"?><crrl148>'||vr_des_xml||'</crrl148>';
      vr_nmarqimp := vr_nom_direto||'/rl/crrl148.lst' ;

      -- Solicitar relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl148/creditos'          --> No base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl148.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                 ,pr_dsarqsaid => vr_nmarqimp         --> Arquivo final com codigo da agencia
                                 ,pr_sqcabrel  => 1                   --> Sequencial do relatorio
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                 ,pr_nmformul  => '132dh'             --> Nome do formulario para impress?o
                                 ,pr_nrcopias  => 1                   --> Numero de copias
	                               ,pr_dspathcop => null                --> diretorio de copia do arquivo
                                 ,pr_des_erro  => vr_dscritic);       --> Saida com erro

      IF vr_dscritic IS NOT NULL THEN
        -- somente gera log
        -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra ||  ' --> relatorio:'||vr_nmarqimp||' --> '
                                                     || vr_dscritic );
      END IF;

      -- Liberando a memoria alocada pro CLOB
      dbms_lob.freetemporary(vr_des_xml);


      /*  Remover arquivo de controle  */
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm  '||vr_nmarqctr ||' 2> /dev/null'
                                  ,pr_typ_saida   => vr_typ_said
                                  ,pr_des_saida   => vr_dscritic);
      -- Testar erro
      IF vr_typ_said = 'ERR' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao remover o arquivo '||vr_nmarqctr;
        RAISE vr_exc_saida;
      END IF;

      /*  Copiar arquivo .dat para a pasta salvar  */
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nom_direto||'/arq/'||vr_nmarqjur ||' '||vr_nom_direto ||'/salvar 2> /dev/null'
                                  ,pr_typ_saida   => vr_typ_said
                                  ,pr_des_saida   => vr_dscritic);
      -- Testar erro
      IF vr_typ_said = 'ERR' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarqctr ||' para a pasta salvar';
        RAISE vr_exc_saida;
      END IF;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
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
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
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

  END pc_crps178;
/

