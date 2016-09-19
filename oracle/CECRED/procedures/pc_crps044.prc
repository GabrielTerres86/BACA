CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps044 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

   Programa: pc_crps044 (Fontes/crps044.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/92.                    Ultima atualizacao: 12/02/2013

   Dados referentes ao programa:

   Frequencia: Anual (Batch)
   Objetivo  : Calculo anual dos juros sobre capital.
               Atende a solicitacao 026. Emite relatorio 39.

   Alteracoes: 27/03/95 - Alterado para alimentar o campo craplct.qtlanmfx com
                          o campo tot_vljurmfx (Edson).

               28/06/95 - Alterado para calculo no mes de junho/95 (Edson).

               26/09/95 - Alterado para calculo no mes de setembro/95 (Edson).

               18/12/95 - Alterado para calculo no mes de dezembro/95 (Edson).

               28/03/96 - Alterado para calculo no mes de marco/96 (Edson).

               24/06/96 - Alterado para calculo no mes de junho/96 (Edson).

               12/07/96 - Alterado para nao calcular juros para contas trans-
                          feridas (Odair).

               01/08/97 - Alterado para utilizar 6 casas decimal na taxa de
                          calculo dos juros (Edson).

               09/11/98 - Tratar situacao em prejuizo (Deborah).

               14/03/2000 - Tratar taxas diferenciadas para cada mes (Edson).

               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               26/12/2000 - Identificar se semestral ou anual e acrescentar
                            campos de controle na tabela (Deborah).

               05/01/2001 - Alterar o nome dos formularios de impressao para
                            132dm. (Eduardo).

               27/07/2001 - Ignorar os campos de controle na tabela (Edson).

               16/12/2002 - Alterado para efetuar o calculo anual dos juros
                            sobre o capital e armazena-lo na tabela crapjsc
                            (Edson).

               28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplct e crapjsc (Diego).

               16/01/2006 - Criar o registro no crapjsc com data do ULTIMO dia
                            do ano - 31/12/...  (Edson).

               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               30/01/2008 - Alteracao LABEL de JUROS para ATUALIZACAO
                            (Guilherme).

               14/05/2010 - Quando crapcot.vlcapmes negativo assumir zeros
                            no calculo e dar mensagem no log (Magui).

              30/11/2010 - 001 / Alterado Format "x(40)" para Format "x(50)" (Danielle/Kbase)

              21/12/2010 - Incluido campo Saldo Medio Capital.
                         - Incluidos totais de saldo medio, cooperados com
                           movimentacao e demitidos (Henrique).

              19/01/2011 - Alteracao do layout do relatorio. Agrupar por PAC
                           e dividir os cooperados em 3 grupos. (Henrique)

              28/02/2011 - Alteracao nos totais e na exibicao dos cooperados
                           (Henrique).

              03/04/2012 - Ajuste nas 2 ultimas alteracoes (David).

              06/09/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

              12/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS044';

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

      -- Cursor sobre as cotas dos associados
      CURSOR cr_crapcot IS
        SELECT nrdconta,
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
         WHERE cdcooper = pr_cdcooper;

      -- Cursor sobre os dados dos associados
      CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT cdsitdtl,
               dtelimin,
               dtdemiss,
               cdagenci,
               nrmatric,
               nmprimtl
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor sobre a transferencia e duplicacao de matricula
      CURSOR cr_craptrf(pr_nrdconta craptrf.nrdconta%TYPE) IS
        SELECT 1
          FROM craptrf
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND tptransa = 1
           AND insittrs = 2
         ORDER BY nrsconta;
      rw_craptrf cr_craptrf%ROWTYPE;

      -- Cursor para a busca do nome da agencia
      CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE) IS
        SELECT crapage.nmresage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;
      rw_crapage cr_crapage%ROWTYPE;


      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      -- Criacao do tipo de registro para a tabela de taxa de juros
      TYPE typ_reg_txjurcap IS
        RECORD(txjurcap number(15,8));
      TYPE typ_tab_txjurcap IS
        TABLE OF typ_reg_txjurcap
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os dados para a tabela de taxa de juros
      vr_tab_txjurcap typ_tab_txjurcap;

      -- Criacao do tipo de registro para a tabela de valor de juros
      TYPE typ_reg_vljurcap IS
        RECORD(vljurcap number(15,2));
      TYPE typ_tab_vljurcap IS
        TABLE OF typ_reg_vljurcap
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os dados para a tabela de taxa de juros
      vr_tab_vljurcap typ_tab_vljurcap;

      -- Criacao do tipo de registro para o acumuldo de meses
      TYPE typ_reg_mes IS
        RECORD(vljurcap NUMBER(15,2),
               vlcapmes number(15,2));
      TYPE typ_tab_mes IS
        TABLE OF typ_reg_mes
          INDEX BY PLS_INTEGER;
      --Vetor para armazenar os dados acumulados por mes
      vr_tab_tot_mes typ_tab_mes;
      vr_tab_tot_mes_ger typ_tab_mes;


      -- Criacao do tipo de registro para a tabela de moedas
      TYPE typ_reg_vlmoefix IS
        RECORD(vlmoefix number(15,8));
      TYPE typ_tab_vlmoefix IS
        TABLE OF typ_reg_vlmoefix
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os dados para a tabela de taxa de juros
      vr_tab_vlmoefix typ_tab_vlmoefix;


      -- Criacao do tipo de registro para o relatorio crrl039.lst
      TYPE typ_reg_creditados IS
        RECORD(nrdconta crapass.nrdconta%TYPE,
               nrmatric crapass.nrmatric%TYPE,
               nmprimtl crapass.nmprimtl%TYPE,
               vljurass NUMBER(17,2),
               sldmdcap NUMBER(17,2),
               dtdemiss crapass.dtdemiss%TYPE,
               cdagenci crapass.cdagenci%TYPE,
               flstatus PLS_INTEGER, /* 1-ATIVOS 2-DEMITIDOS NO ANO CORRENTE 3-DEMITIDOS */
               flcredit PLS_INTEGER, /* 10-CREDITADO 11-NAO CREDITADO */
               mes      typ_tab_mes);
      TYPE typ_tab_creditados IS
        TABLE OF typ_reg_creditados
          INDEX BY VARCHAR2(18);  --flcredit(2) cdagenci(5) flstatus(1) nrdconta(10)
      -- Vetor para armazenar os dados para o relatorio crrl039.lst
      vr_tab_creditados typ_tab_creditados;



      ------------------------------- VARIAVEIS -------------------------------
      vr_dstextab   craptab.dstextab%TYPE; --> Retorno da rotina TABE0001.fn_busca_dstextab
      vr_utlfile    UTL_FILE.file_type;    --> Handle do arquivo JUROSCAP.DAT
      vr_des_xml    CLOB;                  --> XML do relatorio crrl039.lst
      vr_nom_direto VARCHAR2(500);         --> Diretorio para geracao do arquivo
      vr_vljurcap   NUMBER(17,2);          --> Valor do juros capital
      vr_contador   PLS_INTEGER;           --> Contador auxiliar de meses
      vr_nrmesini   PLS_INTEGER;           --> Numero do ms inicial
      vr_nrmesfin   PLS_INTEGER;           --> numero do mes final
      vr_vlcapmes   NUMBER(17,2);          --> Valor de capital no mes
      vr_tot_vljurmfx NUMBER(17,4);        --> Valor de juros total
      vr_cddinteg   PLS_INTEGER;           --> Codigo identificador de integracao de pagamentos
      vr_indice     VARCHAR2(18);          --> Indice para a pl/table vr_tab_creditados
      vr_totmdcap   NUMBER(17,2);          --> Valor total medio de capital
      vr_qtdmdcap   PLS_INTEGER;           --> Quantidade medio de capital
      vr_flstatus   PLS_INTEGER;           --> Status de demissao
      vr_sldmdcap   NUMBER(17,2);          --> Valor saldo medio de capital
      vr_tot_vljurass NUMBER(17,2);        --> Valor total de juros dos associados
      vr_texto_completo  varchar2(32600);  --> Variável para armazenar os dados do XML antes de incluir no CLOB

      -- Variaveis totalizadoras por PA
      vr_qtsldati   PLS_INTEGER    := 0;   --> Quantidade de saldo de ativos
      vr_vlsldati   NUMBER(17,2)   := 0;   --> Valor de saldo de ativos
      vr_qtpouati   PLS_INTEGER    := 0;   --> Quantidade de poupanca de ativos
      vr_vlpouati   NUMBER(17,2)   := 0;   --> Valor de poupanca de ativos
      vr_qtslddem   PLS_INTEGER    := 0;   --> Quantidade de saldo de demitidos
      vr_vlslddem   NUMBER(17,2)   := 0;   --> Valor de saldo de demitidos
      vr_qtpoudem   PLS_INTEGER    := 0;   --> Quantidade de poupanca de demitidos
      vr_vlpoudem   NUMBER(17,2)   := 0;   --> Valor de poupanca de demitidos
      vr_qtsldant   PLS_INTEGER    := 0;   --> Quantidade de saldo de antigos
      vr_vlsldant   NUMBER(17,2)   := 0;   --> Valor de saldo de antigos
      vr_qtpouant   PLS_INTEGER    := 0;   --> Quantidade de poupanca de antigos
      vr_vlpouant   NUMBER(17,2)   := 0;   --> Valor de poupanca de antigos
      vr_tot_qtdsdmed PLS_INTEGER  := 0;   --> Quantidade total de saldo medio
      vr_tot_vlrsdmed NUMBER(17,2) := 0;   --> Valor total de saldo medio
      vr_tot_qtdpomed PLS_INTEGER  := 0;   --> Quantidade total de poupanca media
      vr_tot_vlrpomed NUMBER(17,2) := 0;   --> Valor total de poupanca media
      vr_vljurcaptot  NUMBER(17,2) := 0;   --> Valor total por PA de juros do capital

      -- Variaveis totalizadoras do relatorio
      vr_qtsldati_ger   PLS_INTEGER    := 0;   --> Quantidade de saldo de ativos
      vr_vlsldati_ger   NUMBER(17,2)   := 0;   --> Valor de saldo de ativos
      vr_qtpouati_ger   PLS_INTEGER    := 0;   --> Quantidade de poupanca de ativos
      vr_vlpouati_ger   NUMBER(17,2)   := 0;   --> Valor de poupanca de ativos
      vr_qtslddem_ger   PLS_INTEGER    := 0;   --> Quantidade de saldo de demitidos
      vr_vlslddem_ger   NUMBER(17,2)   := 0;   --> Valor de saldo de demitidos
      vr_qtpoudem_ger   PLS_INTEGER    := 0;   --> Quantidade de poupanca de demitidos
      vr_vlpoudem_ger   NUMBER(17,2)   := 0;   --> Valor de poupanca de demitidos
      vr_qtsldant_ger   PLS_INTEGER    := 0;   --> Quantidade de saldo de antigos
      vr_vlsldant_ger   NUMBER(17,2)   := 0;   --> Valor de saldo de antigos
      vr_qtpouant_ger   PLS_INTEGER    := 0;   --> Quantidade de poupanca de antigos
      vr_vlpouant_ger   NUMBER(17,2)   := 0;   --> Valor de poupanca de antigos
      vr_tot_qtdsdmed_ger PLS_INTEGER  := 0;   --> Quantidade total de saldo medio
      vr_tot_vlrsdmed_ger NUMBER(17,2) := 0;   --> Valor total de saldo medio
      vr_tot_qtdpomed_ger PLS_INTEGER  := 0;   --> Quantidade total de poupanca media
      vr_tot_vlrpomed_ger NUMBER(17,2) := 0;   --> Valor total de poupanca media
      vr_vljurcaptot_ger  NUMBER(17,2) := 0;   --> Valor total por PA de juros do capital

      --------------------------- SUBROTINAS INTERNAS --------------------------

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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      vr_texto_completo := NULL;
      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'salvar'); --> Utilizaremos o contab

      -- criar arquivo JUROSCAP.DAT
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_direto  --> Diretorio do arquivo
                              ,pr_nmarquiv => 'juroscap.dat' --> Nome do arquivo
                              ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_utlfile     --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);

      -- Carrega taxa de juros anual sobre capital
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'EXEJUROCAP'
                                               ,pr_tpregist => 1);

      -- Se nao encontrar gera erro
      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 260;
        RAISE vr_exc_saida;
      END IF;

      vr_dstextab := substr(vr_dstextab,5,200);


      -- Popula a pl/tabel de taxa de juros
      FOR ind IN 1..12 LOOP
        vr_tab_txjurcap(ind).txjurcap := gene0002.fn_busca_entrada(ind,vr_dstextab,';') / 100;
      END LOOP;

      /*  Numero do mes INICIAL e FINAL para efeito do calculo  */
      vr_nrmesini := 1;
      vr_nrmesfin := 12;

      /*  Moeda fixa a ser utilizada  */
      vr_tab_vlmoefix(01).vlmoefix := 0.828700;
      vr_tab_vlmoefix(02).vlmoefix := 0.828700;
      vr_tab_vlmoefix(03).vlmoefix := 0.828700;
      vr_tab_vlmoefix(04).vlmoefix := 0.828700;
      vr_tab_vlmoefix(05).vlmoefix := 0.828700;
      vr_tab_vlmoefix(06).vlmoefix := 0.828700;
      vr_tab_vlmoefix(07).vlmoefix := 0.828700;
      vr_tab_vlmoefix(08).vlmoefix := 0.828700;
      vr_tab_vlmoefix(09).vlmoefix := 0.828700;
      vr_tab_vlmoefix(10).vlmoefix := 0.828700;
      vr_tab_vlmoefix(11).vlmoefix := 0.828700;
      vr_tab_vlmoefix(12).vlmoefix := 0.828700;

      /*  Verifica se a taxa esta zerada, caso positivo sai sem calcular os juros  */
      IF vr_tab_txjurcap(to_char(rw_crapdat.dtmvtolt,'MM')).txjurcap = 0  THEN
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;

      /*  Le registro de capital e calcula juros  */

      -- Efetua um loop sobre as cotas dos associados
      FOR rw_crapcot IN cr_crapcot LOOP

        -- Busca os dados dos associados
        OPEN cr_crapass(rw_crapcot.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_cdcritic := 251;
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass;

        IF rw_crapass.cdsitdtl IN (2,4,5,6,7,8) THEN
          -- Abre cursor de transferencia e duplicacao de matricula
          OPEN cr_craptrf(rw_crapcot.nrdconta);
          FETCH cr_craptrf INTO rw_craptrf;
          IF cr_craptrf%FOUND THEN
            CLOSE cr_craptrf;
            continue; -- Vai para o proximo registro da CRAPCOT
          END IF;
          CLOSE cr_craptrf;
        END IF;

        vr_vljurcap := 0;
        vr_contador := vr_nrmesini;
        IF vr_contador = 1 THEN
          vr_vlcapmes := rw_crapcot.vlcapmes##1;
        ELSIF vr_contador = 2 THEN
          vr_vlcapmes := rw_crapcot.vlcapmes##2;
        ELSIF vr_contador = 3 THEN
          vr_vlcapmes := rw_crapcot.vlcapmes##3;
        ELSIF vr_contador = 4 THEN
          vr_vlcapmes := rw_crapcot.vlcapmes##4;
        ELSIF vr_contador = 5 THEN
          vr_vlcapmes := rw_crapcot.vlcapmes##5;
        ELSIF vr_contador = 6 THEN
          vr_vlcapmes := rw_crapcot.vlcapmes##6;
        ELSIF vr_contador = 7 THEN
          vr_vlcapmes := rw_crapcot.vlcapmes##7;
        ELSIF vr_contador = 8 THEN
          vr_vlcapmes := rw_crapcot.vlcapmes##8;
        ELSIF vr_contador = 9 THEN
          vr_vlcapmes := rw_crapcot.vlcapmes##9;
        ELSIF vr_contador = 10 THEN
          vr_vlcapmes := rw_crapcot.vlcapmes##10;
        ELSIF vr_contador = 11 THEN
          vr_vlcapmes := rw_crapcot.vlcapmes##11;
        ELSE
          vr_vlcapmes := rw_crapcot.vlcapmes##12;
        END IF;

        -- Se o valor captado no mes for negativo, gera log e zera o valor
        IF vr_vlcapmes < 0 THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || ' CONTA = ' || rw_crapcot.nrdconta ||
                                                        ' crapcot.vlcapmes negativo no mes ' || vr_contador || ' ' ||
                                                        vr_vlcapmes);
          vr_vlcapmes := 0;
        END IF;

        vr_tab_vljurcap(vr_contador).vljurcap :=
                               ROUND(vr_vlcapmes *
                                             vr_tab_txjurcap(vr_nrmesini).txjurcap,2);

        vr_tot_vljurmfx := ROUND(vr_tab_vljurcap(vr_contador).vljurcap /
                                       vr_tab_vlmoefix(vr_contador).vlmoefix,4);

        FOR vr_contador IN vr_nrmesini + 1..vr_nrmesfin LOOP
          IF vr_contador = 1 THEN
            vr_vlcapmes := rw_crapcot.vlcapmes##1;
          ELSIF vr_contador = 2 THEN
            vr_vlcapmes := rw_crapcot.vlcapmes##2;
          ELSIF vr_contador = 3 THEN
            vr_vlcapmes := rw_crapcot.vlcapmes##3;
          ELSIF vr_contador = 4 THEN
            vr_vlcapmes := rw_crapcot.vlcapmes##4;
          ELSIF vr_contador = 5 THEN
            vr_vlcapmes := rw_crapcot.vlcapmes##5;
          ELSIF vr_contador = 6 THEN
            vr_vlcapmes := rw_crapcot.vlcapmes##6;
          ELSIF vr_contador = 7 THEN
            vr_vlcapmes := rw_crapcot.vlcapmes##7;
          ELSIF vr_contador = 8 THEN
            vr_vlcapmes := rw_crapcot.vlcapmes##8;
          ELSIF vr_contador = 9 THEN
            vr_vlcapmes := rw_crapcot.vlcapmes##9;
          ELSIF vr_contador = 10 THEN
            vr_vlcapmes := rw_crapcot.vlcapmes##10;
          ELSIF vr_contador = 11 THEN
            vr_vlcapmes := rw_crapcot.vlcapmes##11;
          ELSE
            vr_vlcapmes := rw_crapcot.vlcapmes##12;
          END IF;

          -- Se o valor captado no mes for negativo, gera log e zera o valor
          IF vr_vlcapmes < 0 THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || ' CONTA = ' || rw_crapcot.nrdconta ||
                                                          ' crapcot.vlcapmes negativo no mes ' || vr_contador || ' ' ||
                                                          vr_vlcapmes);
            vr_vlcapmes := 0;
          END IF;

          vr_tab_vljurcap(vr_contador).vljurcap :=
                         ROUND((vr_vlcapmes +
                               (vr_tot_vljurmfx * vr_tab_vlmoefix(vr_contador).vlmoefix)) *
                                vr_tab_txjurcap(vr_contador).txjurcap,2);

          vr_tot_vljurmfx := vr_tot_vljurmfx +
                                    ROUND(vr_tab_vljurcap(vr_contador).vljurcap /
                                                vr_tab_vlmoefix(vr_contador).vlmoefix,4);

        END LOOP;

        /*  Nao paga p/ eliminados  */
        IF rw_crapass.dtelimin IS NOT NULL THEN
          vr_cddinteg := 2;
        ELSE
          vr_cddinteg := 1;
        END IF;
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfile,           --> Handle do arquivo aberto
          pr_des_text => to_char(vr_cddinteg,'fm0') ||                                       /*  CONTR  */
                  ' ' || to_char(rw_crapcot.nrdconta,'fm00000000')  ||                       /*  CONTA  */
                  ' ' || to_char(vr_tot_vljurmfx,'fm00000000D0000') ||                       /*  JURMFX */
                  ' ' || to_char(nvl(vr_tab_vljurcap(1).vljurcap,0),'fm0000000000D00') ||    /*  JUROS  */
                  ' ' || to_char(nvl(vr_tab_vljurcap(2).vljurcap,0),'fm0000000000D00') ||    /*  JUROS  */
                  ' ' || to_char(nvl(vr_tab_vljurcap(3).vljurcap,0),'fm0000000000D00') ||    /*  JUROS  */
                  ' ' || to_char(nvl(vr_tab_vljurcap(4).vljurcap,0),'fm0000000000D00') ||    /*  JUROS  */
                  ' ' || to_char(nvl(vr_tab_vljurcap(5).vljurcap,0),'fm0000000000D00') ||    /*  JUROS  */
                  ' ' || to_char(nvl(vr_tab_vljurcap(6).vljurcap,0),'fm0000000000D00') ||    /*  JUROS  */
                  ' ' || to_char(nvl(vr_tab_vljurcap(7).vljurcap,0),'fm0000000000D00') ||    /*  JUROS  */
                  ' ' || to_char(nvl(vr_tab_vljurcap(8).vljurcap,0),'fm0000000000D00') ||    /*  JUROS  */
                  ' ' || to_char(nvl(vr_tab_vljurcap(9).vljurcap,0),'fm0000000000D00') ||    /*  JUROS  */
                  ' ' || to_char(nvl(vr_tab_vljurcap(10).vljurcap,0),'fm0000000000D00') ||   /*  JUROS  */
                  ' ' || to_char(nvl(vr_tab_vljurcap(11).vljurcap,0),'fm0000000000D00') ||   /*  JUROS  */
                  ' ' || to_char(nvl(vr_tab_vljurcap(12).vljurcap,0),'fm0000000000D00'));    /*  JUROS  */


        -- Geracao da Pl/Table para geracao do relatorio CRRL039.lst
        /* SALDO MEDIO CAPITAL */
        vr_sldmdcap := round((greatest(0,rw_crapcot.vlcapmes##1) +
                              greatest(0,rw_crapcot.vlcapmes##2) +
                              greatest(0,rw_crapcot.vlcapmes##3) +
                              greatest(0,rw_crapcot.vlcapmes##4) +
                              greatest(0,rw_crapcot.vlcapmes##5) +
                              greatest(0,rw_crapcot.vlcapmes##6) +
                              greatest(0,rw_crapcot.vlcapmes##7) +
                              greatest(0,rw_crapcot.vlcapmes##8) +
                              greatest(0,rw_crapcot.vlcapmes##9) +
                              greatest(0,rw_crapcot.vlcapmes##10) +
                              greatest(0,rw_crapcot.vlcapmes##11) +
                              greatest(0,rw_crapcot.vlcapmes##12))/12,2);

        vr_totmdcap := vr_totmdcap + vr_sldmdcap;
        vr_qtdmdcap := vr_qtdmdcap + 1;

        /* SALDO MEDIO CAPITAL - FIM */

        vr_tot_vljurass := ROUND(vr_tot_vljurmfx * vr_tab_vlmoefix(vr_nrmesfin).vlmoefix,2);

        IF vr_tot_vljurass = 0   THEN
          continue;
        END IF;

        -- Atualiza o status de demissao
        IF rw_crapass.dtdemiss IS NULL THEN -- Se nao foi demitido
          vr_flstatus := 1;
        ELSIF rw_crapass.dtdemiss >= trunc(rw_crapdat.dtmvtolt,'YYYY') THEN -- Se foi demitido neste ano
          vr_flstatus := 2;
        ELSE -- Se for demissao antiga
          vr_flstatus := 3;
        END IF;

        IF vr_cddinteg = 2 THEN
          -- Cria o indice para a pl/table
          vr_indice := '11'||                            -- flcredit
                       lpad(rw_crapass.cdagenci,5,'0')|| --cdagenci
                       vr_flstatus ||                    --flstatus
                       lpad(rw_crapcot.nrdconta,10,'0'); --nrdconta

          -- Atualiza a pl/table do relatorio crrl039.lst
          vr_tab_creditados(vr_indice).nrdconta := rw_crapcot.nrdconta;
          vr_tab_creditados(vr_indice).nrmatric := rw_crapass.nrmatric;
          vr_tab_creditados(vr_indice).nmprimtl := rw_crapass.nmprimtl;
          vr_tab_creditados(vr_indice).vljurass := vr_tot_vljurass;
          vr_tab_creditados(vr_indice).sldmdcap := vr_sldmdcap;
          vr_tab_creditados(vr_indice).dtdemiss := rw_crapass.dtdemiss;
          vr_tab_creditados(vr_indice).cdagenci := rw_crapass.cdagenci;
          vr_tab_creditados(vr_indice).flstatus := vr_flstatus;
          vr_tab_creditados(vr_indice).flcredit := 11;

          continue;     /*  Le o proximo registro  */
        END IF;

        -- Cria o indice para a pl/table
        vr_indice := '10'||                            -- flcredit
                     lpad(rw_crapass.cdagenci,5,'0')|| --cdagenci
                     vr_flstatus ||                    --flstatus
                     lpad(rw_crapcot.nrdconta,10,'0'); --nrdconta

        -- Atualiza a pl/table do relatorio crrl039.lst
        vr_tab_creditados(vr_indice).nrdconta := rw_crapcot.nrdconta;
        vr_tab_creditados(vr_indice).nrmatric := rw_crapass.nrmatric;
        vr_tab_creditados(vr_indice).nmprimtl := rw_crapass.nmprimtl;
        vr_tab_creditados(vr_indice).vljurass := vr_tot_vljurass;
        vr_tab_creditados(vr_indice).sldmdcap := vr_sldmdcap;
        vr_tab_creditados(vr_indice).dtdemiss := rw_crapass.dtdemiss;
        vr_tab_creditados(vr_indice).cdagenci := rw_crapass.cdagenci;
        vr_tab_creditados(vr_indice).flstatus := vr_flstatus;
        vr_tab_creditados(vr_indice).flcredit := 10;

        -- Atualiza os totalizadores
        vr_tab_creditados(vr_indice).mes(1).vlcapmes  := rw_crapcot.vlcapmes##1;
        vr_tab_creditados(vr_indice).mes(2).vlcapmes  := rw_crapcot.vlcapmes##2;
        vr_tab_creditados(vr_indice).mes(3).vlcapmes  := rw_crapcot.vlcapmes##3;
        vr_tab_creditados(vr_indice).mes(4).vlcapmes  := rw_crapcot.vlcapmes##4;
        vr_tab_creditados(vr_indice).mes(5).vlcapmes  := rw_crapcot.vlcapmes##5;
        vr_tab_creditados(vr_indice).mes(6).vlcapmes  := rw_crapcot.vlcapmes##6;
        vr_tab_creditados(vr_indice).mes(7).vlcapmes  := rw_crapcot.vlcapmes##7;
        vr_tab_creditados(vr_indice).mes(8).vlcapmes  := rw_crapcot.vlcapmes##8;
        vr_tab_creditados(vr_indice).mes(9).vlcapmes  := rw_crapcot.vlcapmes##9;
        vr_tab_creditados(vr_indice).mes(10).vlcapmes := rw_crapcot.vlcapmes##10;
        vr_tab_creditados(vr_indice).mes(11).vlcapmes := rw_crapcot.vlcapmes##11;
        vr_tab_creditados(vr_indice).mes(12).vlcapmes := rw_crapcot.vlcapmes##12;
        FOR vr_contador IN vr_nrmesini..vr_nrmesfin LOOP
          vr_tab_creditados(vr_indice).mes(vr_contador).vljurcap := ROUND(ROUND(
                                                              vr_tab_vljurcap(vr_contador).vljurcap /
                                                              vr_tab_vlmoefix(vr_contador).vlmoefix,4) *
                                                              vr_tab_vlmoefix(vr_nrmesfin).vlmoefix,2);
        END LOOP;

      END LOOP;

      -- Gera a linha final do arquivo JUROSCAP.DAT
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfile,           --> Handle do arquivo aberto
          pr_des_text => '9 99999999 99999999,9999 ' ||
             '9999999999,99 9999999999,99 9999999999,99 ' ||
             '9999999999,99 9999999999,99 9999999999,99 ' ||
             '9999999999,99 9999999999,99 9999999999,99 ' ||
             '9999999999,99 9999999999,99 9999999999,99');

      -- Fecha o arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh =>vr_utlfile); --> Handle do arquivo aberto

      -- Se ocorreu erro na geracao do arquivo cancela o programa
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      /*  Classifica arquivo de juros pelo indicador de integr. e conta .. */
      gene0001.pc_OScommand_Shell('sort -k 1,2 -o '|| vr_nom_direto||'/juroscap.dat '||
                                                      vr_nom_direto||'/juroscap.dat  2> /dev/null');


      /*
      -- Inicio da geracao do crrl039.lst
      */

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicilizar as informações do XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '<?xml version="1.0" encoding="utf-8"?><crrl039>');

      vr_indice := vr_tab_creditados.first;
      WHILE vr_indice IS NOT NULL LOOP
        IF vr_tab_creditados(vr_indice).flcredit = 10 THEN

          -- Se for o primeiro registro, abre o no de creditados
          IF vr_indice = vr_tab_creditados.first THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '<credit>');
          END IF;

          IF vr_tab_creditados(vr_indice).flstatus = 1 THEN
            IF vr_tab_creditados(vr_indice).sldmdcap > 0 THEN
              vr_qtsldati := vr_qtsldati + 1;
              vr_vlsldati := vr_vlsldati + vr_tab_creditados(vr_indice).sldmdcap;
            END IF;

            IF vr_tab_creditados(vr_indice).vljurass > 0 THEN
              vr_qtpouati := vr_qtpouati + 1;
              vr_vlpouati := vr_vlpouati + vr_tab_creditados(vr_indice).vljurass;
            END IF;
          ELSIF vr_tab_creditados(vr_indice).flstatus = 2 THEN
            IF vr_tab_creditados(vr_indice).sldmdcap > 0 THEN
              vr_qtslddem := vr_qtslddem + 1;
              vr_vlslddem := vr_vlslddem + vr_tab_creditados(vr_indice).sldmdcap;
            END IF;

            IF vr_tab_creditados(vr_indice).vljurass > 0 THEN
              vr_qtpoudem := vr_qtpoudem + 1;
              vr_vlpoudem := vr_vlpoudem + vr_tab_creditados(vr_indice).vljurass;
            END IF;
          ELSIF vr_tab_creditados(vr_indice).flstatus = 3 THEN
            IF vr_tab_creditados(vr_indice).sldmdcap > 0 THEN
              vr_qtsldant := vr_qtsldant + 1;
              vr_vlsldant := vr_vlsldant + vr_tab_creditados(vr_indice).sldmdcap;
            END IF;

            IF vr_tab_creditados(vr_indice).vljurass > 0 THEN
              vr_qtpouant := vr_qtpouant + 1;
              vr_vlpouant := vr_vlpouant + vr_tab_creditados(vr_indice).vljurass;
            END IF;
          END IF;

          IF vr_tab_creditados(vr_indice).sldmdcap > 0 THEN
            vr_tot_qtdsdmed := vr_tot_qtdsdmed + 1;
            vr_tot_vlrsdmed := vr_tot_vlrsdmed + vr_tab_creditados(vr_indice).sldmdcap;
          END IF;

          IF vr_tab_creditados(vr_indice).vljurass > 0 THEN
            vr_tot_qtdpomed := vr_tot_qtdpomed + 1;
            vr_tot_vlrpomed := vr_tot_vlrpomed + vr_tab_creditados(vr_indice).vljurass;
          END IF;

          -- Acumula o total por mes
          FOR vr_contador IN vr_nrmesini..vr_nrmesfin LOOP
            IF vr_tab_tot_mes.exists(vr_contador) THEN
              vr_tab_tot_mes(vr_contador).vlcapmes := vr_tab_tot_mes(vr_contador).vlcapmes +
                                             vr_tab_creditados(vr_indice).mes(vr_contador).vlcapmes;
              vr_tab_tot_mes(vr_contador).vljurcap := vr_tab_tot_mes(vr_contador).vljurcap +
                                             vr_tab_creditados(vr_indice).mes(vr_contador).vljurcap;
            ELSE
              vr_tab_tot_mes(vr_contador).vlcapmes := vr_tab_creditados(vr_indice).mes(vr_contador).vlcapmes;
              vr_tab_tot_mes(vr_contador).vljurcap := vr_tab_creditados(vr_indice).mes(vr_contador).vljurcap;
            END IF;
            vr_vljurcaptot := vr_vljurcaptot + vr_tab_creditados(vr_indice).mes(vr_contador).vljurcap;
          END LOOP;

          -- Verifica se eh a primeira agencia diferente
          IF vr_indice = vr_tab_creditados.first OR -- Se for o primeir registro
             vr_tab_creditados(vr_indice).cdagenci <> vr_tab_creditados(vr_tab_creditados.prior(vr_indice)).cdagenci THEN -- Se a agencia eh diferente da anterior

            -- Abre o cursor de agencia
            OPEN cr_crapage(vr_tab_creditados(vr_indice).cdagenci);
            FETCH cr_crapage INTO rw_crapage;
            CLOSE cr_crapage;

            -- Abre o no de agencia e escreve o nome da agencia
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '<pa>'||
                                '<agencia>'||vr_tab_creditados(vr_indice).cdagenci||' - '||rw_crapage.nmresage||'</agencia>');
          END IF;

          -- Verifica se eh o primeiro status diferente
          IF vr_indice = vr_tab_creditados.first OR -- Se for o primeir registro
             vr_tab_creditados(vr_indice).cdagenci <> vr_tab_creditados(vr_tab_creditados.prior(vr_indice)).cdagenci OR -- Se a agencia eh diferente da anterior
             vr_tab_creditados(vr_indice).flstatus <> vr_tab_creditados(vr_tab_creditados.prior(vr_indice)).flstatus THEN -- Se o status eh diferente da anterior
            -- Abre o no de status e escreve o nome do status
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                            '<flstatus>'||
                              '<agencia>PA => '||vr_tab_creditados(vr_indice).cdagenci||' - '||rw_crapage.nmresage||'</agencia>'||
                              '<msg>VALORES CREDITADOS:</msg>');

            IF vr_tab_creditados(vr_indice).flstatus = 1 THEN
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                '<dsstatus>COOPERADOS ATIVOS</dsstatus>');
            ELSIF vr_tab_creditados(vr_indice).flstatus = 2 THEN
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                '<dsstatus>COOPERADOS DEMITIDOS NO ANO DE '||to_char(rw_crapdat.dtmvtolt,'YYYY')||'</dsstatus>');
            ELSE
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                '<dsstatus>COOPERADOS DEMITIDOS ANTES DE '||to_char(rw_crapdat.dtmvtolt,'YYYY')||'</dsstatus>');
            END IF;
          END IF;

          -- Escreve a linha de detalhe
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                  '<conta>'||
                                    '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_creditados(vr_indice).nrdconta)    ||'</nrdconta>'||
                                    '<nrmatric>'||to_char(vr_tab_creditados(vr_indice).nrmatric,'fm999G990')       ||'</nrmatric>'||
                                    '<nmprimtl>'||substr(vr_tab_creditados(vr_indice).nmprimtl,1,50)               ||'</nmprimtl>'||
                                    '<vljurass>'||to_char(vr_tab_creditados(vr_indice).vljurass,'fm999G999G990D00')||'</vljurass>'||
                                    '<sldmdcap>'||to_char(vr_tab_creditados(vr_indice).sldmdcap,'fm999G999G990D00')||'</sldmdcap>'||
                                    '<dtdemiss>'||to_char(vr_tab_creditados(vr_indice).dtdemiss,'dd/mm/yyyy')      ||'</dtdemiss>'||
                                  '</conta>');

          -- Se for o ultimo status deve fechar o no
          IF vr_indice = vr_tab_creditados.last OR -- Se for o ultimo registro
             vr_tab_creditados(vr_indice).cdagenci <> vr_tab_creditados(vr_tab_creditados.next(vr_indice)).cdagenci OR -- Se a agencia eh diferente do proximo
             vr_tab_creditados(vr_indice).flstatus <> vr_tab_creditados(vr_tab_creditados.next(vr_indice)).flstatus OR -- Se o status eh diferente do proximo
             vr_tab_creditados(vr_indice).flcredit <> vr_tab_creditados(vr_tab_creditados.next(vr_indice)).flcredit THEN -- Se o credito eh diferente do proximo
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '</flstatus>');
          END IF;

          -- Verifica se eh o ultimo PA
          IF vr_indice = vr_tab_creditados.last OR -- Se for o ultimo registro
             vr_tab_creditados(vr_indice).cdagenci <> vr_tab_creditados(vr_tab_creditados.next(vr_indice)).cdagenci OR -- Se a agencia eh diferente do proximo
             vr_tab_creditados(vr_indice).flcredit <> vr_tab_creditados(vr_tab_creditados.next(vr_indice)).flcredit THEN -- Se o credito eh diferente do proximo

            -- Imprime os totais do PA
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '<total>'||
                                '<titulo>TOTAIS DO PA'||TO_CHAR(vr_tab_creditados(vr_indice).cdagenci,'9999')||'</titulo>'||
                                '<qtpouati>'||to_char(vr_qtpouati,'fm999G999G990')     ||'</qtpouati>'||
                                '<vlpouati>'||to_char(vr_vlpouati,'fm999G999G990D00')  ||'</vlpouati>'||
                                '<qtsldati>'||to_char(vr_qtsldati,'fm999G999G990')     ||'</qtsldati>'||
                                '<vlsldati>'||to_char(vr_vlsldati,'fm999G999G990D00')  ||'</vlsldati>'||
                                '<anoatual>'||to_char(rw_Crapdat.dtmvtolt,'YYYY')      ||'</anoatual>'||
                                '<qtpoudem>'||to_char(vr_qtpoudem,'fm999G999G990')     ||'</qtpoudem>'||
                                '<vlpoudem>'||to_char(vr_vlpoudem,'fm999G999G990D00')  ||'</vlpoudem>'||
                                '<qtslddem>'||to_char(vr_qtslddem,'fm999G999G990')     ||'</qtslddem>'||
                                '<vlslddem>'||to_char(vr_vlslddem,'fm999G999G990D00')  ||'</vlslddem>'||
                                '<qtpouant>'||to_char(vr_qtpouant,'fm999G999G990')     ||'</qtpouant>'||
                                '<vlpouant>'||to_char(vr_vlpouant,'fm999G999G990D00')  ||'</vlpouant>'||
                                '<qtsldant>'||to_char(vr_qtsldant,'fm999G999G990')     ||'</qtsldant>'||
                                '<vlsldant>'||to_char(vr_vlsldant,'fm999G999G990D00')  ||'</vlsldant>'||
                                '<qtdpomed>'||to_char(vr_tot_qtdpomed,'fm999G999G990')     ||'</qtdpomed>'||
                                '<vlrpomed>'||to_char(vr_tot_vlrpomed,'fm999G999G990D00')  ||'</vlrpomed>'||
                                '<qtdsdmed>'||to_char(vr_tot_qtdsdmed,'fm999G999G990')     ||'</qtdsdmed>'||
                                '<vlrsdmed>'||to_char(vr_tot_vlrsdmed,'fm999G999G990D00')  ||'</vlrsdmed>'||
                                '<vlcapmes1>'||to_char(vr_tab_tot_mes(1).vlcapmes,'fm999G999G990D00')||'</vlcapmes1>'||
                                '<vlcapmes2>'||to_char(vr_tab_tot_mes(2).vlcapmes,'fm999G999G990D00')||'</vlcapmes2>'||
                                '<vlcapmes3>'||to_char(vr_tab_tot_mes(3).vlcapmes,'fm999G999G990D00')||'</vlcapmes3>'||
                                '<vlcapmes4>'||to_char(vr_tab_tot_mes(4).vlcapmes,'fm999G999G990D00')||'</vlcapmes4>'||
                                '<vlcapmes5>'||to_char(vr_tab_tot_mes(5).vlcapmes,'fm999G999G990D00')||'</vlcapmes5>'||
                                '<vlcapmes6>'||to_char(vr_tab_tot_mes(6).vlcapmes,'fm999G999G990D00')||'</vlcapmes6>'||
                                '<vlcapmes7>'||to_char(vr_tab_tot_mes(7).vlcapmes,'fm999G999G990D00')||'</vlcapmes7>'||
                                '<vlcapmes8>'||to_char(vr_tab_tot_mes(8).vlcapmes,'fm999G999G990D00')||'</vlcapmes8>'||
                                '<vlcapmes9>'||to_char(vr_tab_tot_mes(9).vlcapmes,'fm999G999G990D00')||'</vlcapmes9>'||
                                '<vlcapmes10>'||to_char(vr_tab_tot_mes(10).vlcapmes,'fm999G999G990D00')||'</vlcapmes10>'||
                                '<vlcapmes11>'||to_char(vr_tab_tot_mes(11).vlcapmes,'fm999G999G990D00')||'</vlcapmes11>'||
                                '<vlcapmes12>'||to_char(vr_tab_tot_mes(12).vlcapmes,'fm999G999G990D00')||'</vlcapmes12>'||
                                '<vljurcap1>'||to_char(vr_tab_tot_mes(1).vljurcap,'fm999G999G990D00')||'</vljurcap1>'||
                                '<vljurcap2>'||to_char(vr_tab_tot_mes(2).vljurcap,'fm999G999G990D00')||'</vljurcap2>'||
                                '<vljurcap3>'||to_char(vr_tab_tot_mes(3).vljurcap,'fm999G999G990D00')||'</vljurcap3>'||
                                '<vljurcap4>'||to_char(vr_tab_tot_mes(4).vljurcap,'fm999G999G990D00')||'</vljurcap4>'||
                                '<vljurcap5>'||to_char(vr_tab_tot_mes(5).vljurcap,'fm999G999G990D00')||'</vljurcap5>'||
                                '<vljurcap6>'||to_char(vr_tab_tot_mes(6).vljurcap,'fm999G999G990D00')||'</vljurcap6>'||
                                '<vljurcap7>'||to_char(vr_tab_tot_mes(7).vljurcap,'fm999G999G990D00')||'</vljurcap7>'||
                                '<vljurcap8>'||to_char(vr_tab_tot_mes(8).vljurcap,'fm999G999G990D00')||'</vljurcap8>'||
                                '<vljurcap9>'||to_char(vr_tab_tot_mes(9).vljurcap,'fm999G999G990D00')||'</vljurcap9>'||
                                '<vljurcap10>'||to_char(vr_tab_tot_mes(10).vljurcap,'fm999G999G990D00')||'</vljurcap10>'||
                                '<vljurcap11>'||to_char(vr_tab_tot_mes(11).vljurcap,'fm999G999G990D00')||'</vljurcap11>'||
                                '<vljurcap12>'||to_char(vr_tab_tot_mes(12).vljurcap,'fm999G999G990D00')||'</vljurcap12>'||
                                '<txjurcap1>'||to_char(vr_tab_txjurcap(1).txjurcap*100,'fm990D000000')||' %</txjurcap1>'||
                                '<txjurcap2>'||to_char(vr_tab_txjurcap(2).txjurcap*100,'fm990D000000')||' %</txjurcap2>'||
                                '<txjurcap3>'||to_char(vr_tab_txjurcap(3).txjurcap*100,'fm990D000000')||' %</txjurcap3>'||
                                '<txjurcap4>'||to_char(vr_tab_txjurcap(4).txjurcap*100,'fm990D000000')||' %</txjurcap4>'||
                                '<txjurcap5>'||to_char(vr_tab_txjurcap(5).txjurcap*100,'fm990D000000')||' %</txjurcap5>'||
                                '<txjurcap6>'||to_char(vr_tab_txjurcap(6).txjurcap*100,'fm990D000000')||' %</txjurcap6>'||
                                '<txjurcap7>'||to_char(vr_tab_txjurcap(7).txjurcap*100,'fm990D000000')||' %</txjurcap7>'||
                                '<txjurcap8>'||to_char(vr_tab_txjurcap(8).txjurcap*100,'fm990D000000')||' %</txjurcap8>'||
                                '<txjurcap9>'||to_char(vr_tab_txjurcap(9).txjurcap*100,'fm990D000000')||' %</txjurcap9>'||
                                '<txjurcap10>'||to_char(vr_tab_txjurcap(10).txjurcap*100,'fm990D000000')||' %</txjurcap10>'||
                                '<txjurcap11>'||to_char(vr_tab_txjurcap(11).txjurcap*100,'fm990D000000')||' %</txjurcap11>'||
                                '<txjurcap12>'||to_char(vr_tab_txjurcap(12).txjurcap*100,'fm990D000000')||' %</txjurcap12>'||
                                '<vljurcaptot>'||to_char(vr_vljurcaptot,'fm999G999G990D00')||'</vljurcaptot>'||
                              '</total>');


            -- Somar as variaveis nos totalizadores do relatorio
            vr_qtpouati_ger := vr_qtpouati_ger + vr_qtpouati;
            vr_vlpouati_ger := vr_vlpouati_ger + vr_vlpouati;
            vr_qtsldati_ger := vr_qtsldati_ger + vr_qtsldati;
            vr_vlsldati_ger := vr_vlsldati_ger + vr_vlsldati;
            vr_qtpoudem_ger := vr_qtpoudem_ger + vr_qtpoudem;
            vr_vlpoudem_ger := vr_vlpoudem_ger + vr_vlpoudem;
            vr_qtslddem_ger := vr_qtslddem_ger + vr_qtslddem;
            vr_vlslddem_ger := vr_vlslddem_ger + vr_vlslddem;
            vr_qtpouant_ger := vr_qtpouant_ger + vr_qtpouant;
            vr_vlpouant_ger := vr_vlpouant_ger + vr_vlpouant;
            vr_qtsldant_ger := vr_qtsldant_ger + vr_qtsldant;
            vr_vlsldant_ger := vr_vlsldant_ger + vr_vlsldant;
            vr_tot_qtdpomed_ger := vr_tot_qtdpomed_ger + vr_tot_qtdpomed;
            vr_tot_vlrpomed_ger := vr_tot_vlrpomed_ger + vr_tot_vlrpomed;
            vr_tot_qtdsdmed_ger := vr_tot_qtdsdmed_ger + vr_tot_qtdsdmed;
            vr_tot_vlrsdmed_ger := vr_tot_vlrsdmed_ger + vr_tot_vlrsdmed;
            vr_vljurcaptot_ger  := vr_vljurcaptot_ger  + vr_vljurcaptot;
            -- Acumula por mes
            FOR vr_contador IN vr_nrmesini..vr_nrmesfin LOOP
              IF vr_tab_tot_mes_ger.exists(vr_contador) THEN
                 vr_tab_tot_mes_ger(vr_contador).vljurcap := vr_tab_tot_mes_ger(vr_contador).vljurcap + vr_tab_tot_mes(vr_contador).vljurcap;
                 vr_tab_tot_mes_ger(vr_contador).vlcapmes := vr_tab_tot_mes_ger(vr_contador).vlcapmes + vr_tab_tot_mes(vr_contador).vlcapmes;
              ELSE
                 vr_tab_tot_mes_ger(vr_contador).vljurcap := vr_tab_tot_mes(vr_contador).vljurcap;
                 vr_tab_tot_mes_ger(vr_contador).vlcapmes := vr_tab_tot_mes(vr_contador).vlcapmes;
              END IF;
            END LOOP;

            -- Zera as variaveis acumuladoras de agencia
            vr_qtpouati := 0;
            vr_vlpouati := 0;
            vr_qtsldati := 0;
            vr_vlsldati := 0;
            vr_qtpoudem := 0;
            vr_vlpoudem := 0;
            vr_qtslddem := 0;
            vr_vlslddem := 0;
            vr_qtpouant := 0;
            vr_vlpouant := 0;
            vr_qtsldant := 0;
            vr_vlsldant := 0;
            vr_tot_qtdpomed := 0;
            vr_tot_vlrpomed := 0;
            vr_tot_qtdsdmed := 0;
            vr_tot_vlrsdmed := 0;
            vr_vljurcaptot  := 0;
            vr_tab_tot_mes.delete;

            -- Fechar o no do PA
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '</pa>');
          END IF;

          -- Se for o ultimo registro do credito deve fechar o registro de credito
          IF vr_indice = vr_tab_creditados.last OR -- Se for o ultimo registro
             vr_tab_creditados(vr_indice).flcredit <> vr_tab_creditados(vr_tab_creditados.next(vr_indice)).flcredit THEN -- Se o credito eh diferente do proximo

            -- Imprime os totais do PA
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '<totalger>'||
                                '<titulo>TOTAIS GERAIS</titulo>'||
                                '<qtpouati>'||to_char(vr_qtpouati_ger,'fm999G999G990')     ||'</qtpouati>'||
                                '<vlpouati>'||to_char(vr_vlpouati_ger,'fm999G999G990D00')  ||'</vlpouati>'||
                                '<qtsldati>'||to_char(vr_qtsldati_ger,'fm999G999G990')     ||'</qtsldati>'||
                                '<vlsldati>'||to_char(vr_vlsldati_ger,'fm999G999G990D00')  ||'</vlsldati>'||
                                '<anoatual>'||to_char(rw_Crapdat.dtmvtolt,'YYYY')      ||'</anoatual>'||
                                '<qtpoudem>'||to_char(vr_qtpoudem_ger,'fm999G999G990')     ||'</qtpoudem>'||
                                '<vlpoudem>'||to_char(vr_vlpoudem_ger,'fm999G999G990D00')  ||'</vlpoudem>'||
                                '<qtslddem>'||to_char(vr_qtslddem_ger,'fm999G999G990')     ||'</qtslddem>'||
                                '<vlslddem>'||to_char(vr_vlslddem_ger,'fm999G999G990D00')  ||'</vlslddem>'||
                                '<qtpouant>'||to_char(vr_qtpouant_ger,'fm999G999G990')     ||'</qtpouant>'||
                                '<vlpouant>'||to_char(vr_vlpouant_ger,'fm999G999G990D00')  ||'</vlpouant>'||
                                '<qtsldant>'||to_char(vr_qtsldant_ger,'fm999G999G990')     ||'</qtsldant>'||
                                '<vlsldant>'||to_char(vr_vlsldant_ger,'fm999G999G990D00')  ||'</vlsldant>'||
                                '<qtdpomed>'||to_char(vr_tot_qtdpomed_ger,'fm999G999G990')     ||'</qtdpomed>'||
                                '<vlrpomed>'||to_char(vr_tot_vlrpomed_ger,'fm999G999G990D00')  ||'</vlrpomed>'||
                                '<qtdsdmed>'||to_char(vr_tot_qtdsdmed_ger,'fm999G999G990')     ||'</qtdsdmed>'||
                                '<vlrsdmed>'||to_char(vr_tot_vlrsdmed_ger,'fm999G999G990D00')  ||'</vlrsdmed>'||
                                '<vlcapmes1>'||to_char(vr_tab_tot_mes_ger(1).vlcapmes,'fm999G999G990D00')||'</vlcapmes1>'||
                                '<vlcapmes2>'||to_char(vr_tab_tot_mes_ger(2).vlcapmes,'fm999G999G990D00')||'</vlcapmes2>'||
                                '<vlcapmes3>'||to_char(vr_tab_tot_mes_ger(3).vlcapmes,'fm999G999G990D00')||'</vlcapmes3>'||
                                '<vlcapmes4>'||to_char(vr_tab_tot_mes_ger(4).vlcapmes,'fm999G999G990D00')||'</vlcapmes4>'||
                                '<vlcapmes5>'||to_char(vr_tab_tot_mes_ger(5).vlcapmes,'fm999G999G990D00')||'</vlcapmes5>'||
                                '<vlcapmes6>'||to_char(vr_tab_tot_mes_ger(6).vlcapmes,'fm999G999G990D00')||'</vlcapmes6>'||
                                '<vlcapmes7>'||to_char(vr_tab_tot_mes_ger(7).vlcapmes,'fm999G999G990D00')||'</vlcapmes7>'||
                                '<vlcapmes8>'||to_char(vr_tab_tot_mes_ger(8).vlcapmes,'fm999G999G990D00')||'</vlcapmes8>'||
                                '<vlcapmes9>'||to_char(vr_tab_tot_mes_ger(9).vlcapmes,'fm999G999G990D00')||'</vlcapmes9>'||
                                '<vlcapmes10>'||to_char(vr_tab_tot_mes_ger(10).vlcapmes,'fm999G999G990D00')||'</vlcapmes10>'||
                                '<vlcapmes11>'||to_char(vr_tab_tot_mes_ger(11).vlcapmes,'fm999G999G990D00')||'</vlcapmes11>'||
                                '<vlcapmes12>'||to_char(vr_tab_tot_mes_ger(12).vlcapmes,'fm999G999G990D00')||'</vlcapmes12>'||
                                '<vljurcap1>'||to_char(vr_tab_tot_mes_ger(1).vljurcap,'fm999G999G990D00')||'</vljurcap1>'||
                                '<vljurcap2>'||to_char(vr_tab_tot_mes_ger(2).vljurcap,'fm999G999G990D00')||'</vljurcap2>'||
                                '<vljurcap3>'||to_char(vr_tab_tot_mes_ger(3).vljurcap,'fm999G999G990D00')||'</vljurcap3>'||
                                '<vljurcap4>'||to_char(vr_tab_tot_mes_ger(4).vljurcap,'fm999G999G990D00')||'</vljurcap4>'||
                                '<vljurcap5>'||to_char(vr_tab_tot_mes_ger(5).vljurcap,'fm999G999G990D00')||'</vljurcap5>'||
                                '<vljurcap6>'||to_char(vr_tab_tot_mes_ger(6).vljurcap,'fm999G999G990D00')||'</vljurcap6>'||
                                '<vljurcap7>'||to_char(vr_tab_tot_mes_ger(7).vljurcap,'fm999G999G990D00')||'</vljurcap7>'||
                                '<vljurcap8>'||to_char(vr_tab_tot_mes_ger(8).vljurcap,'fm999G999G990D00')||'</vljurcap8>'||
                                '<vljurcap9>'||to_char(vr_tab_tot_mes_ger(9).vljurcap,'fm999G999G990D00')||'</vljurcap9>'||
                                '<vljurcap10>'||to_char(vr_tab_tot_mes_ger(10).vljurcap,'fm999G999G990D00')||'</vljurcap10>'||
                                '<vljurcap11>'||to_char(vr_tab_tot_mes_ger(11).vljurcap,'fm999G999G990D00')||'</vljurcap11>'||
                                '<vljurcap12>'||to_char(vr_tab_tot_mes_ger(12).vljurcap,'fm999G999G990D00')||'</vljurcap12>'||
                                '<txjurcap1>'||to_char(vr_tab_txjurcap(1).txjurcap*100,'fm990D000000')||' %</txjurcap1>'||
                                '<txjurcap2>'||to_char(vr_tab_txjurcap(2).txjurcap*100,'fm990D000000')||' %</txjurcap2>'||
                                '<txjurcap3>'||to_char(vr_tab_txjurcap(3).txjurcap*100,'fm990D000000')||' %</txjurcap3>'||
                                '<txjurcap4>'||to_char(vr_tab_txjurcap(4).txjurcap*100,'fm990D000000')||' %</txjurcap4>'||
                                '<txjurcap5>'||to_char(vr_tab_txjurcap(5).txjurcap*100,'fm990D000000')||' %</txjurcap5>'||
                                '<txjurcap6>'||to_char(vr_tab_txjurcap(6).txjurcap*100,'fm990D000000')||' %</txjurcap6>'||
                                '<txjurcap7>'||to_char(vr_tab_txjurcap(7).txjurcap*100,'fm990D000000')||' %</txjurcap7>'||
                                '<txjurcap8>'||to_char(vr_tab_txjurcap(8).txjurcap*100,'fm990D000000')||' %</txjurcap8>'||
                                '<txjurcap9>'||to_char(vr_tab_txjurcap(9).txjurcap*100,'fm990D000000')||' %</txjurcap9>'||
                                '<txjurcap10>'||to_char(vr_tab_txjurcap(10).txjurcap*100,'fm990D000000')||' %</txjurcap10>'||
                                '<txjurcap11>'||to_char(vr_tab_txjurcap(11).txjurcap*100,'fm990D000000')||' %</txjurcap11>'||
                                '<txjurcap12>'||to_char(vr_tab_txjurcap(12).txjurcap*100,'fm990D000000')||' %</txjurcap12>'||
                                '<vljurcaptot>'||to_char(vr_vljurcaptot_ger,'fm999G999G990D00')||'</vljurcaptot>'||
                              '</totalger>'||
                            '</credit>');
          END IF;



        ELSE --vr_tab_creditados(vr_indice).flcredit <> 10
          -- Se for o primeiro registro de nao creditados, abre o no de nao creditados
          IF vr_indice = vr_tab_creditados.first OR -- Se for o primeiro registro
             vr_tab_creditados(vr_tab_creditados.prior(vr_indice)).flcredit = 10 THEN -- ou se o flag do registro anterior for 10
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '<naocredit><pa><flstatus><dsstatus></dsstatus>'||
                              '<msg>VALORES NAO CREDITADOS - SOBRAS CALCULADAS PARA ASSOCIADOS DEMITIDOS:</msg>');
          END IF;
          -- Escreve a linha de detalhe
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                  '<conta>'||
                                    '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_creditados(vr_indice).nrdconta)    ||'</nrdconta>'||
                                    '<nrmatric>'||to_char(vr_tab_creditados(vr_indice).nrmatric,'fm999G990')       ||'</nrmatric>'||
                                    '<nmprimtl>'||substr(vr_tab_creditados(vr_indice).nmprimtl,1,50)               ||'</nmprimtl>'||
                                    '<vljurass>'||to_char(vr_tab_creditados(vr_indice).vljurass,'fm999G999G990D00')||'</vljurass>'||
                                    '<sldmdcap>'||to_char(vr_tab_creditados(vr_indice).sldmdcap,'fm999G999G990D00')||'</sldmdcap>'||
                                    '<dtdemiss>'||to_char(vr_tab_creditados(vr_indice).dtdemiss,'dd/mm/yyyy')      ||'</dtdemiss>'||
                                  '</conta>');

          -- Se for o ultimo registro, fecha o no
          IF vr_indice = vr_tab_creditados.last THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '</flstatus></pa></naocredit>');
          END IF;
        END IF;


        vr_indice := vr_tab_creditados.next(vr_indice);
      END LOOP;

      -- Fecha o no principal
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                        '</crrl039>',TRUE);

      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl'); --> Utilizaremos o contab

      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl039',                     --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl039.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_direto||'/crrl039.lst',  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                  pr_nmformul  => '132dm',                        --> Nome do formulario
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro



      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END iF;

      -- Se for dezembro zera os valores
      IF to_char(rw_crapdat.dtmvtolt,'MM') = 12 THEN
        BEGIN
          UPDATE craptab
             SET dstextab = substr(dstextab,1,4)||
                          '000,000000;000,000000;000,000000;000,000000;'||
                          '000,000000;000,000000;000,000000;000,000000;'|| +
                          '000,000000;000,000000;000,000000;000,000000'
           WHERE cdcooper = pr_cdcooper
             AND nmsistem = 'CRED'
             AND tptabela = 'GENERI'
             AND cdempres = 0
             AND cdacesso = 'EXEJUROCAP'
             AND tpregist = 1;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPTAB: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
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

  END pc_crps044;
/

