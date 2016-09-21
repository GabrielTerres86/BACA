CREATE OR REPLACE PROCEDURE CECRED.pc_crps080(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: Fontes/crps080.p
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Janeiro/94.                         Ultima atualizacao: 21/06/2016

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Atende a solicitacao 043.
                   Processar as solicitacoes de geracao dos debitos de emprestimos.
                   Emite relatorio 65.

       Alteracoes: 22/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                              quidacao do emprestimo (Edson).

                   05/07/94 - Alterado para eliminar o literal "cruzeiros reais".

                   06/10/94 - Alterado para gerar arquivo de descontos para a
                              empresa 11 no formato da folha RUBI (Edson).

                   25/10/94 - Alterado para gerar os descontos com o codigo da verba
                              utilizada na empresa a que se refere (Edson).

                   11/01/95 - Alterado para trocar o codigo da empresa 10 para 1
                              na geracao do arquivo (padrao RUBI) para a HERCO
                              (Edson).

                   23/01/95 - Alterado para trocar o codigo da empresa 13 para 10
                              na geracao do arquivo (padrao RUBI) para a Associacao
                              (Deborah).

                   04/04/95 - Alterado para registrar no log o aviso para tranmis-
                              sao e gravacao dos arquivos das empresas 1,4,9,20 e
                              99 e copiar os mesmos arquivos para o diretorio salvar
                              (Edson).

                   28/04/95 - Alterado para copiar os arquivos gerados para o dire-
                              torio integrar (Edson).

                   30/05/95 - Alterado para gerar crapavs para as empresas com
                              tipo de debito igual 2 (Debito em conta) (Edson).

                   09/08/95 - Alterado para eliminar a diferenciacao feita na cria-
                              cao do avs para empresa 4 (Odair).

                   16/01/96 - Alterado para tratar empresa 9 (Consumo) gravando no
                              formato RUBI com o codigo da empresa = 1 (Odair).

                   31/10/96 - Na leitura do EPR, selecionar apenas os que tenham
                              flgpagto como TRUE (Odair).

                   19/11/96 - Alterar a mascara do campo nrctremp (Odair).

                   24/03/97 - Alterado para incorporar o valor da CPMF a prestacao
                              quando a empresa for LOJAS HERING (Edson).

                   16/07/97 - Quando for criar avs verificar tpconven para gerar a
                              crapavs.dtmvtolt (Odair)

                   24/07/97 - Atualizar emp.inavsemp (Odair)

                   05/08/97 - Na criacao do avs alimentar cdempcnv com o valor do
                              crapsol.cdempres. (Odair).

                   27/08/97 - Alterado para incluir o campo flgproce na criacao
                              do crapavs (Deborah).

                   22/01/98 - Alterado para gerar cdsecext para Ceval Jaragua com
                              zeros (Deborah).

                   24/03/98 - Cancelada a alteracao anterior (Deborah).

                   13/04/98 - Alterado para mostrar a CPMF no relatorio (Deborah).

                   24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   24/03/1999 - Acerto para o dia 25/03/1999 para a empresa 6
                                (Deborah).

                   07/05/1999 - Alterado para classificar por conta e nao mais por
                                cadastro da empresa (Deborah).

                   26/05/99 - Zerar variaveis de cpmf (Odair).

                   31/05/1999 - Tratar CPMF (Deborah).

                   17/01/2000 - Tratat tpdebemp = 3 (Deborah).

                   28/06/2005 - Alimentado campo cdcooper da tabela crapavs
                                (Diego).

                   15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando

                   01/09/2008 - Alteracao CDEMPRES (Kbase).

                   09/03/2012 - Declarada variaveis novas da include lelem.i (Tiago)

                   01/11/2012 - Tratar so os emprestimos do tipo zero Price TR (Oscar).

                   14/01/2014 - Inclusao de VALIDATE crapavs (Carlos)

                   28/03/2014 - Conversão Progress >> Oracle (Petter - Supero)

                   11/04/2014 - Sequencia conversão Progress >> Oracle (Edison - AMcom)

                   27/05/2014 - Alterado o pr_flg_impri = 'S' na chamada da pc_solicita_relato (Edison - AMcom)

                   21/01/2015 - Alterado o formato do campo nrctremp para 8
                                caracters (Kelvin - 233714)

                   21/06/2016 - Correcao para o uso correto do indice da CRAPTAB nesta rotina.
                                (Carlos Rafael Tanholi).
    ............................................................................ */

    DECLARE
      ---------------------------- PL Table --------------------------------
      -- PL Table de dados de parâmetros
      TYPE typ_reg_craptab IS
        RECORD(dstextab craptab.dstextab%TYPE);
      TYPE typ_tab_craptab IS TABLE OF typ_reg_craptab INDEX BY VARCHAR2(10);

      -- PL Table de dados da emprea
      TYPE typ_reg_crapemp IS
        RECORD(cdempres    crapemp.cdempres%TYPE
              ,nmresemp    crapemp.nmresemp%TYPE
              ,tpconven    crapemp.tpconven%TYPE
              ,cddescto##1 crapemp.cddescto##1%TYPE
              ,tpdebemp    crapemp.tpdebemp%TYPE
              ,sgempres    crapemp.sgempres%TYPE);
      TYPE typ_tab_crapemp IS TABLE OF typ_reg_crapemp INDEX BY VARCHAR2(10);

      -- PL Table de associados
      TYPE typ_reg_crapass IS
        RECORD(nrdconta crapass.nrdconta%TYPE
              ,inpessoa crapass.inpessoa%TYPE
              ,cdtipsfx crapass.cdtipsfx%TYPE
              ,inisipmf crapass.inisipmf%TYPE
              ,dtdemiss crapass.dtdemiss%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,nrcadast crapass.nrcadast%TYPE
              ,cdsecext crapass.cdsecext%TYPE
              ,cdagenci crapass.cdagenci%TYPE);
      TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY VARCHAR2(100);

      -- PL Table para daddos do UNION das tabelas CRAPTTL e CRAPJUR
      TYPE typ_reg_ttljur IS
        RECORD(cdempres crapttl.cdempres%TYPE);
      TYPE typ_tab_ttljur IS TABLE OF typ_reg_ttljur INDEX BY VARCHAR2(15);


      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS080';

      -- Tratamento de erros
      vr_exc_saida      EXCEPTION;
      vr_exc_fimprg     EXCEPTION;
      vr_cdcritic       PLS_INTEGER;
      vr_dscritic       VARCHAR2(4000);

      -- Variáveis de negócio
      vr_rel_dsempres   VARCHAR2(4000);
      vr_rel_nrcadast   PLS_INTEGER := 0;
      vr_rel_nrdconta   PLS_INTEGER := 0;
      vr_rel_nrctremp   PLS_INTEGER := 0;
      vr_rel_nrdocmto   PLS_INTEGER := 0;
      vr_rel_cdsecext   PLS_INTEGER := 0;
      vr_rel_cdagenci   PLS_INTEGER := 0;
      vr_rel_vlpreemp   NUMBER := 0;
      vr_rel_vltotpre   NUMBER := 0;
      vr_rel_vlprecpm   NUMBER := 0;
      vr_rel_nmprimtl   VARCHAR2(4000);
      vr_rel_dtrefere   PLS_INTEGER := 0;
      vr_rel_dtproces   VARCHAR2(8);
      vr_rel_nrversao   PLS_INTEGER := 0;
      vr_rel_nrseqdeb   PLS_INTEGER := 0;
      vr_rel_dtultdia   DATE;
      vr_rel_cddescto   PLS_INTEGER := 0;
      vr_rel_cdempres   PLS_INTEGER := 0;
      vr_rel_nmsistem   VARCHAR2(400) := 'EM';
      vr_rel_tpdebito   PLS_INTEGER := 0;
      vr_rel_dsdebito   VARCHAR2(400);
      vr_rel_vldaurvs   NUMBER := 0;
      vr_tot_qtdassoc   PLS_INTEGER := 0;
      vr_tot_qtctremp   PLS_INTEGER := 0;
      vr_tot_vlpreemp   NUMBER := 0;
      vr_tot_vlprecpm   NUMBER := 0;
      vr_epr_qtctremp   PLS_INTEGER := 0;
      vr_epr_nrctremp   dbms_sql.Number_Table;
      vr_epr_vlpreemp   dbms_sql.Number_Table;
      vr_tab_txdjuros   dbms_sql.Number_Table;
      vr_tab_diapagto   PLS_INTEGER := 0;
      vr_tab_cdempres   PLS_INTEGER := 0;
      vr_tab_dtcalcul   DATE;
      vr_tab_inusatab   BOOLEAN;
      vr_tab_ddpgtohr   PLS_INTEGER := 0;
      vr_tab_ddpgtoms   PLS_INTEGER := 0;
      vr_tab_ddmesnov   PLS_INTEGER := 0;
      vr_arq_nrseqdeb   PLS_INTEGER := 0;
      vr_ass_nrseqdeb   PLS_INTEGER := 0;
      vr_con_nrcadast   PLS_INTEGER := 0;
      vr_nmarqimp       dbms_sql.Varchar2_Table;
      vr_nrdevias       dbms_sql.Number_Table;
      vr_nmarqdeb       VARCHAR2(400);
      vr_nmarqtrf       VARCHAR2(400);
      vr_intipsai       VARCHAR2(400);
      vr_regexist       BOOLEAN;
      vr_flgfirst       BOOLEAN;
      vr_flgarqab       BOOLEAN;
      vr_contaarq       PLS_INTEGER := 0;
      vr_contador       PLS_INTEGER := 0;
      vr_cdtipsfx       PLS_INTEGER := 0;
      vr_cdcalcul       PLS_INTEGER := 0;
      vr_inisipmf       PLS_INTEGER := 0;
      vr_nrseqsol       VARCHAR2(400);
      vr_dtcalcul       DATE;
      vr_dtultdia       DATE;
      vr_dtultpag       DATE;
      vr_dtmesnov       DATE;
      vr_dtdemiss       DATE;
      vr_nrdconta       PLS_INTEGER := 0;
      vr_nrctremp       PLS_INTEGER := 0;
      vr_qtprepag       PLS_INTEGER := 0;
      vr_qtprecal       crapepr.qtprecal%TYPE;
      vr_vljurmes       NUMBER := 0;
      vr_vljuracu       NUMBER := 0;
      vr_vlsdeved       crapepr.vlsdeved%TYPE := 0;
      vr_vlprepag       NUMBER := 0;
      vr_txdjuros       NUMBER(20,7) := 0;
      vr_tpdebito       PLS_INTEGER := 0;
      vr_vldaurvs       NUMBER := 0;
      vr_vldacpmf       NUMBER := 0;
      vr_dtmvtolt       DATE;
      vr_tab_craptab    typ_tab_craptab;
      vr_nom_dir        VARCHAR2(400);
      vr_nom_arq        VARCHAR2(400);
      vr_nom_int        VARCHAR2(400);
      vr_nom_salvar     VARCHAR2(400);
      vr_tab_crapemp    typ_tab_crapemp;
      vr_tab_crapass    typ_tab_crapass;
      vr_tab_ttljur     typ_tab_ttljur;
      vr_xmlc           CLOB;
      vr_xmlb           VARCHAR2(32767);
      vr_xmlc3          CLOB;
      vr_tab_txcpmfcc   NUMBER := 0;
      vr_tab_dtinipmf   DATE;
      vr_tab_dtfimpmf   DATE;
      vr_tab_txrdcpmf   NUMBER := 0;
      vr_tab_indabono   PLS_INTEGER := 0;
      vr_tab_dtiniabo   DATE;
      vr_nrcopias       PLS_INTEGER := 0;
      vr_nmformul       VARCHAR2(400);

      -- variaveis de escrita CLOB
      vr_texto_completo3 VARCHAR2(32600);
      vr_linha           VARCHAR2(500);

      -- variaveis de controle de comandos shell
      vr_comando			VARCHAR2(500);
      vr_typ_saida    VARCHAR2(1000);

      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;

      ------------------------------- CURSORES ---------------------------------
      -- Buscar dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Buscar dados do cadastro das linhas de crédito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE) IS
        SELECT lcr.cdlcremp
              ,lcr.txdiaria
        FROM craplcr lcr
        WHERE lcr.cdcooper = pr_cdcooper;

      -- Buscar dados das solicitações
      CURSOR cr_crapsol(pr_cdcooper IN crapsol.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapsol.dtrefere%TYPE) IS
        SELECT sol.dsparame
              ,sol.cdempres
              ,sol.nrdevias
              ,sol.dtrefere
              ,sol.nrseqsol
              ,sol.rowid
        FROM crapsol sol
        WHERE sol.cdcooper = pr_cdcooper
          AND sol.dtrefere = pr_dtmvtolt
          AND sol.nrsolici = 43
          AND sol.insitsol = 1 --solicitacao não processada.
        ORDER BY cdcooper, nrsolici, dtrefere, nrseqsol;

      -- Buscar dados de parametros
      CURSOR cr_craptabp(pr_cdcooper IN crapsol.cdcooper%TYPE) IS
        SELECT tab.tpregist
              ,tab.dstextab
        FROM craptab tab
        WHERE tab.cdcooper = pr_cdcooper
          AND UPPER(tab.nmsistem) = 'CRED'
          AND UPPER(tab.tptabela) = 'GENERI'
          AND tab.cdempres = 0
          AND UPPER(tab.cdacesso) = 'DIADOPAGTO';

      -- Buscar dados de empresas
      CURSOR cr_crapemp(pr_cdcooper IN crapsol.cdcooper%TYPE) IS
        SELECT emp.cdempres
              ,emp.nmresemp
              ,emp.tpconven
              ,emp.cddescto##1
              ,emp.tpdebemp
              ,emp.sgempres
        FROM crapemp emp
        WHERE emp.cdcooper = pr_cdcooper;

      -- Buscar dados dos emprétimos
      CURSOR cr_crapepr( pr_cdcooper IN crapepr.cdcooper%TYPE
                        ,pr_dtmesnov IN DATE
                        ,pr_cdempres IN crapepr.cdempres%TYPE) IS
        SELECT epr.cdempres
              ,epr.dtmvtolt
              ,epr.nrdconta
              ,epr.inliquid
              ,epr.cdlcremp
              ,epr.nrctremp
              ,epr.qtpreemp
              ,epr.vlpreemp
              ,epr.vlsdeved
              ,epr.vljuracu
              ,epr.dtultpag
              ,epr.txjuremp
              ,ROW_NUMBER() OVER(PARTITION BY epr.nrdconta
                                     ORDER BY  epr.nrdconta
                                             ,epr.nrctremp) seq_nrdconta
              ,LEAD(epr.nrdconta) OVER(ORDER BY epr.nrdconta
                                             ,epr.nrctremp) post_nrdconta
        FROM crapepr epr
        WHERE epr.cdcooper = pr_cdcooper
          AND epr.inliquid = 0 --Indicador de liquidacao do emprestimo. 0-ativo e 1-liquidado
          AND epr.flgpagto = 1 --"0" para debitar no dia da Folha ou "1" para debitar em C/C.
          AND epr.tpemprst = 0 --Contem o tipo do emprestimo (0 - atual, 1 - pre-fixada)
          AND epr.dtmvtolt < pr_dtmesnov
          AND epr.cdempres = pr_cdempres
        ORDER BY epr.nrdconta
                ,epr.nrctremp;

      -- Buscar dados dos associados
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT ass.nrdconta
              ,ass.inpessoa
              ,ass.cdtipsfx
              ,ass.inisipmf
              ,ass.dtdemiss
              ,ass.nmprimtl
              ,ass.nrcadast
              ,ass.cdsecext
              ,ass.cdagenci
        FROM crapass ass
        WHERE ass.cdcooper = pr_cdcooper;

      -- Buscar empresa para pessoas físicas e jurídicas
      CURSOR cr_ttljur(pr_cdcooper IN crapttl.cdcooper%TYPE) IS
        SELECT ttl.cdempres
              ,ttl.nrdconta
        FROM crapttl ttl
        WHERE ttl.cdcooper = pr_cdcooper
          AND ttl.idseqttl = 1
        UNION ALL
        SELECT jur.cdempres
              ,jur.nrdconta
        FROM crapjur jur
        WHERE jur.cdcooper = pr_cdcooper;

    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;

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
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

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
      -- Buscar valores de CPMF
      gene0005.pc_busca_cpmf(pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_dtinipmf => vr_tab_dtinipmf
                            ,pr_dtfimpmf => vr_tab_dtfimpmf
                            ,pr_txcpmfcc => vr_tab_txcpmfcc
                            ,pr_txrdcpmf => vr_tab_txrdcpmf
                            ,pr_indabono => vr_tab_indabono
                            ,pr_dtiniabo => vr_tab_dtiniabo
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreram erros
      IF NVL(vr_cdcritic, 0) > 0 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Gravar dados do cadastro da linha de crédito
      FOR rw_craplcr IN cr_craplcr(pr_cdcooper) LOOP
        vr_tab_txdjuros(rw_craplcr.cdlcremp) := rw_craplcr.txdiaria;
      END LOOP;

      -- Carregar PL Table de empresas
      FOR rw_crapemp IN cr_crapemp(pr_cdcooper) LOOP
        vr_tab_crapemp(LPAD(rw_crapemp.cdempres, 10, '0')).cdempres := rw_crapemp.cdempres;
        vr_tab_crapemp(LPAD(rw_crapemp.cdempres, 10, '0')).nmresemp := rw_crapemp.nmresemp;
        vr_tab_crapemp(LPAD(rw_crapemp.cdempres, 10, '0')).tpconven := rw_crapemp.tpconven;
        vr_tab_crapemp(LPAD(rw_crapemp.cdempres, 10, '0')).cddescto##1 := rw_crapemp.cddescto##1;
        vr_tab_crapemp(LPAD(rw_crapemp.cdempres, 10, '0')).tpdebemp := rw_crapemp.tpdebemp;
        vr_tab_crapemp(LPAD(rw_crapemp.cdempres, 10, '0')).sgempres := rw_crapemp.sgempres;
      END LOOP;

      -- Carregar PL Table de parâmetros
      FOR rw_craptabp IN cr_craptabp(pr_cdcooper) LOOP
        vr_tab_craptab(LPAD(rw_craptabp.tpregist, 5, '0')).dstextab := rw_craptabp.dstextab;
      END LOOP;

      -- Carregar Pl Table de associdos
      FOR rw_crapass IN cr_crapass(pr_cdcooper) LOOP
        vr_tab_crapass(rw_crapass.nrdconta).nrdconta := rw_crapass.nrdconta;
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
        vr_tab_crapass(rw_crapass.nrdconta).cdtipsfx := rw_crapass.cdtipsfx;
        vr_tab_crapass(rw_crapass.nrdconta).inisipmf := rw_crapass.inisipmf;
        vr_tab_crapass(rw_crapass.nrdconta).dtdemiss := rw_crapass.dtdemiss;
        vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
        vr_tab_crapass(rw_crapass.nrdconta).nrcadast := rw_crapass.nrcadast;
        vr_tab_crapass(rw_crapass.nrdconta).cdsecext := rw_crapass.cdsecext;
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
      END LOOP;

      -- Carregar PL Tabl de pessoas (juridica e físca)
      FOR rw_ttljur IN cr_ttljur(pr_cdcooper) LOOP
        vr_tab_ttljur(rw_ttljur.nrdconta).cdempres := rw_ttljur.cdempres;
      END LOOP;

      -- Assimilar valores inicias das variáveis
      vr_regexist := FALSE;
      vr_rel_dtrefere := TO_CHAR(rw_crapdat.dtmvtolt, 'RRRRMMDD');
      vr_rel_dtproces := vr_rel_dtrefere;
      vr_dtultdia := LAST_DAY(rw_crapdat.dtmvtolt);
      vr_rel_dtultdia := vr_dtultdia;

      --diretorio /rl
      vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/rl');
      --diretorio /arq
      vr_nom_arq := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/arq');
      --diretorio /integra
      vr_nom_int := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/integra');
      --diretorio /salvar
      vr_nom_salvar := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/salvar');


      -- Buscar configuração na tabela
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);   

      IF TRIM(vr_dstextab) IS NULL THEN 
        vr_tab_inusatab := FALSE;
      ELSE
        IF SUBSTR(vr_dstextab, 1, 1) = '0' THEN
          vr_tab_inusatab := FALSE;
        ELSE
          vr_tab_inusatab := TRUE;
        END IF;
      END IF;

      -- Percorre a tabela de solicitações retornando somente as informações
      -- das solicitações 43
      FOR rw_crapsol IN cr_crapsol(pr_cdcooper, rw_crapdat.dtmvtolt)
      LOOP

        -- Verifica dados de processamento
        IF rw_crapdat.inproces = 1 AND SUBSTR(rw_crapsol.dsparame, 3, 1) = '1' THEN
          CONTINUE;
        END IF;

        -- Inicializar CLOB
        dbms_lob.createtemporary(vr_xmlc, TRUE);
        dbms_lob.open(vr_xmlc, dbms_lob.lob_readwrite);
        dbms_lob.createtemporary(vr_xmlc3, TRUE);
        dbms_lob.open(vr_xmlc3, dbms_lob.lob_readwrite);

        -- Gerar TAG root
        vr_xmlb := vr_xmlb || '<?xml version="1.0" encoding="utf-8"?><root>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => TRUE, pr_clob => vr_xmlc);

        -- Verificar se existe o tipo na tabela de parametros
        IF NOT vr_tab_craptab.exists(LPAD(rw_crapsol.cdempres, 5, '0')) THEN
          --055 - Tabela nao cadastrada.
          vr_cdcritic := 55;
          --decricao da critica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          --escreve no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                                                        ' DIA DO PAGAMENTO DA EMPRESA ' || rw_crapsol.cdempres
                                    ,pr_nmarqlog     => 'PROC_BATCH');

          --vai para a proxima iteracao
          CONTINUE;
        ELSE
          vr_tab_ddmesnov := SUBSTR(vr_tab_craptab(LPAD(rw_crapsol.cdempres, 5, '0')).dstextab, 1, 2);
          vr_tab_ddpgtoms := SUBSTR(vr_tab_craptab(LPAD(rw_crapsol.cdempres, 5, '0')).dstextab, 4, 2);
          vr_tab_ddpgtohr := SUBSTR(vr_tab_craptab(LPAD(rw_crapsol.cdempres, 5, '0')).dstextab, 7, 2);
          vr_dtmesnov := TO_DATE(vr_tab_ddmesnov || TO_CHAR(rw_crapdat.dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');
        END IF;

        -- Agrevar valores de controle
        vr_cdcritic := 0;
        vr_regexist := TRUE;
        vr_flgfirst := TRUE;
        vr_flgarqab := FALSE;
        vr_nrseqsol := SUBSTR(LPAD(rw_crapsol.nrseqsol,4,'0'), 2, 3);
        vr_contaarq := vr_contaarq + 1;

        --gera o nome do arquivo
        vr_nmarqimp(vr_contaarq) := 'crrl065_' || vr_nrseqsol || '.lst';
        vr_nrdevias(vr_contaarq) := rw_crapsol.nrdevias;
        vr_nmarqdeb := 'emp' || TO_CHAR(rw_crapdat.dtmvtolt, 'MMRRRR') || '.' || LPAD(rw_crapsol.cdempres, 5, '0');
        vr_nmarqtrf := vr_nmarqdeb;
        vr_intipsai := SUBSTR(rw_crapsol.dsparame, 1, 1);
        vr_tpdebito := SUBSTR(rw_crapsol.dsparame, 5, 1);
        vr_vldaurvs := SUBSTR(rw_crapsol.dsparame, 7, 9);
        vr_cdcalcul := SUBSTR(rw_crapsol.dsparame, 17, 3);
        vr_tot_vlpreemp := 0;
        vr_tot_vlprecpm := 0;
        vr_tot_qtdassoc := 0;
        vr_tot_qtctremp := 0;
        vr_rel_nrseqdeb := 0;
        vr_arq_nrseqdeb := 0;

        -- Leitura do cadastro da empresa
        IF NOT vr_tab_crapemp.exists(LPAD(rw_crapsol.cdempres, 10, '0')) THEN
          --040 - Empresa nao cadastrada.
          vr_cdcritic := 40;
          --descricao da critica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          --escreve no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                                                        ' EMPRESA ' || rw_crapsol.cdempres
                                    ,pr_nmarqlog     => 'PROC_BATCH');

          --aborta a execucao do programa
          RAISE vr_exc_saida;
        END IF;

        -- Assimilar valores nas variáveis
        vr_rel_dsempres := LPAD(vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).cdempres, 5, '0') || '-' || vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).nmresemp;
        vr_rel_tpdebito := vr_tpdebito;
        vr_rel_vldaurvs := vr_vldaurvs;

        IF vr_rel_tpdebito = 1 THEN
          vr_rel_dsdebito := vr_rel_tpdebito||'-EM REAIS';
        ELSE
          vr_rel_dsdebito := vr_rel_tpdebito||'-EM URV';
        END IF;

        -- Verifica tipo para buscar dia útil
        IF vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).tpconven = 2 THEN
          vr_dtmvtolt := vr_dtultdia;

          vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => vr_dtmvtolt + 1);
        ELSE
          vr_dtmvtolt := rw_crapdat.dtmvtolt;
        END IF;

        -- Busca dados do desconto
        IF vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).cddescto##1 = 0 THEN
          vr_rel_cddescto := 420;
        ELSE
          vr_rel_cddescto := vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).cddescto##1;
        END IF;

        -- Eliminar avisos anteriores
        IF vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).tpdebemp IN (2,3) THEN
          BEGIN
            DELETE crapavs avs
            WHERE avs.cdcooper = pr_cdcooper
              AND avs.dtmvtolt = vr_dtmvtolt
              AND avs.dtrefere = vr_rel_dtultdia
              AND avs.cdempres = rw_crapsol.cdempres
              AND avs.cdhistor = 108
              AND avs.dtdebito IS NULL;
          EXCEPTION
            WHEN OTHERS THEN
              --descricao da critica
              vr_dscritic := 'Erro ao excluir dados da tabela crapavs. '||SQLERRM;
              --abortando a execucao do programa
              RAISE vr_exc_saida;
          END;
        END IF;

        --leitura dos emprestimos
        FOR rw_crapepr IN cr_crapepr( pr_cdcooper => pr_cdcooper
                                     ,pr_dtmesnov => vr_dtmesnov
                                     ,pr_cdempres => rw_crapsol.cdempres)
        LOOP

          -- Verifica primeiro registro da conta
          IF rw_crapepr.seq_nrdconta = 1 THEN
            -- Verifica se existe associado
            IF NOT vr_tab_crapass.exists(rw_crapepr.nrdconta) THEN
              --251 - Associado nao encontrado no crapass. ERRO DE SISTEMA.
              vr_cdcritic := 251;
              --descricao da critica
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              --escreve no log
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2
                                        ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                                                            ' - CONTA =  ' || TO_CHAR(rw_crapepr.nrdconta, 'FM9999G999G9')
                                        ,pr_nmarqlog     => 'PROC_BATCH');
              --aborta a execucao do programa
              RAISE vr_exc_saida;
            END IF;

            -- Verifica o tipo do associado
            IF vr_tab_ttljur.exists(vr_tab_crapass(rw_crapepr.nrdconta).nrdconta) THEN
              vr_tab_cdempres := vr_tab_ttljur(vr_tab_crapass(rw_crapepr.nrdconta).nrdconta).cdempres;
            END IF;
            -- Assimilar valores nas variáveis
            vr_cdtipsfx := vr_tab_crapass(rw_crapepr.nrdconta).cdtipsfx;
            vr_inisipmf := vr_tab_crapass(rw_crapepr.nrdconta).inisipmf;
            vr_dtdemiss := vr_tab_crapass(rw_crapepr.nrdconta).dtdemiss;
            vr_rel_nmprimtl := vr_tab_crapass(rw_crapepr.nrdconta).nmprimtl;
            vr_rel_nrcadast := vr_tab_crapass(rw_crapepr.nrdconta).nrcadast;
            vr_rel_nrdconta := vr_tab_crapass(rw_crapepr.nrdconta).nrdconta;
            vr_rel_cdsecext := vr_tab_crapass(rw_crapepr.nrdconta).cdsecext;
            vr_rel_cdagenci := vr_tab_crapass(rw_crapepr.nrdconta).cdagenci;
            vr_rel_vltotpre := 0;
            vr_ass_nrseqdeb := 0;
            vr_epr_qtctremp := 0;

            WHILE vr_contador < 100
              LOOP
                vr_contador := vr_contador + 1;

                vr_epr_nrctremp(vr_contador) := 0;
                vr_epr_vlpreemp(vr_contador) := 0;
              END LOOP;

            -- Assimilar valor para empresa 9
            IF rw_crapsol.cdempres = 9 THEN
              vr_con_nrcadast := TRUNC((vr_rel_nrcadast - 3100000) / 10, 0);
            END IF;
          END IF;--IF rw_crapepr.nrdconta <> NVL(rw_crapepr.prev_nrdconta, 0) THEN

          -- Próximo registro para data nula
          IF vr_dtdemiss IS NOT NULL THEN
            --vai para a proxima iteracao
            CONTINUE;
          END IF;

          -- Consiste empresa pela data de referência
          IF vr_tab_cdempres = 6 AND
             rw_crapsol.dtrefere = TO_DATE('25/03/1999', 'DD/MM/RRRR') AND
             vr_rel_cdagenci <> 14 THEN
            -- vai para a proxima iteracao
            CONTINUE;
          END IF;

          -- Consiste valor líquido
          IF vr_tab_inusatab AND rw_crapepr.inliquid = 0 THEN
             vr_txdjuros := vr_tab_txdjuros(rw_crapepr.cdlcremp);
          ELSE
             vr_txdjuros := rw_crapepr.txjuremp;
          END IF;

          -- Assimilar valores
          vr_nrdconta := rw_crapepr.nrdconta;
          vr_nrctremp := rw_crapepr.nrctremp;
          vr_vlsdeved := rw_crapepr.vlsdeved;
          vr_vljuracu := rw_crapepr.vljuracu;
          vr_dtultpag := rw_crapepr.dtultpag;
          vr_rel_nrctremp := rw_crapepr.nrctremp;

          --verifica o codigo do tipo de salario fixo: hora ou mensalista
          IF vr_cdtipsfx IN (1, 3, 4) THEN
            vr_tab_diapagto := vr_tab_ddpgtoms;
          ELSE
            vr_tab_diapagto := vr_tab_ddpgtohr;
          END IF;

          vr_dtcalcul := vr_dtultdia + vr_tab_diapagto;

          -- Verificar se a data cai em um dia útil
          vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => vr_dtcalcul);

          -- Verifica se o pagamento cai em um dia útil
          IF rw_crapdat.inproces > 2 AND TO_CHAR(rw_crapdat.dtmvtolt, 'MM') <> TO_CHAR(rw_crapdat.dtmvtopr, 'MM') THEN
            vr_tab_diapagto := TO_CHAR(vr_dtcalcul, 'DD');
          ELSE
            vr_tab_dtcalcul := TO_DATE(vr_tab_diapagto || TO_CHAR(rw_crapdat.dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');

            vr_tab_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => vr_tab_dtcalcul);
          END IF;

          -- Leitura de pagamentos de empréstimos
          empr0001.pc_leitura_lem(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_nrdconta => rw_crapepr.nrdconta
                                 ,pr_nrctremp => rw_crapepr.nrctremp
                                 ,pr_dtcalcul => vr_dtcalcul
                                 ,pr_diapagto => vr_tab_diapagto
                                 ,pr_txdjuros => vr_txdjuros
                                 ,pr_qtprecal => vr_qtprecal
                                 ,pr_qtprepag => vr_qtprepag
                                 ,pr_vlprepag => vr_vlprepag
                                 ,pr_vljurmes => vr_vljurmes
                                 ,pr_vljuracu => vr_vljuracu
                                 ,pr_vlsdeved => vr_vlsdeved
                                 ,pr_dtultpag => vr_dtultpag
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_des_erro => vr_dscritic);

          -- Verifica se ocorreram erros
          IF NVL(vr_dscritic, 0) > 0 THEN
            --descricao da critica
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            --escreve no log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                                                          ' - CONTA =  ' || TO_CHAR(rw_crapepr.nrdconta, 'FM9999G999G9') ||
                                                          ' - CONTRATO = ' || TO_CHAR(rw_crapepr.nrctremp, 'FM99G999G999')
                                      ,pr_nmarqlog     => 'PROC_BATCH');

            --aborta a execucao do programa
            RAISE vr_exc_saida;
          END IF;

          -- Compara saldo devedor
          IF nvl(vr_vlsdeved,0) > rw_crapepr.vlpreemp AND rw_crapepr.qtpreemp > 1 THEN
            vr_epr_qtctremp := vr_epr_qtctremp + 1;
            vr_epr_nrctremp(vr_epr_qtctremp) := rw_crapepr.nrctremp;
            vr_epr_vlpreemp(vr_epr_qtctremp) := nvl(rw_crapepr.vlpreemp,0);
          ELSIF nvl(vr_vlsdeved,0) > 0 THEN
            vr_epr_qtctremp := vr_epr_qtctremp + 1;
            vr_epr_nrctremp(vr_epr_qtctremp) := rw_crapepr.nrctremp;
            vr_epr_vlpreemp(vr_epr_qtctremp) := nvl(vr_vlsdeved,0);
          END IF;

          -- Verifica se não é o último registro do grupo de contas
          IF rw_crapepr.nrdconta = nvl(rw_crapepr.post_nrdconta,0) THEN
            --vai para a proxima interacao
            CONTINUE;
          END IF;

          -- Limpar contador e iniciar LOOP
          vr_contador := 1;
          WHILE vr_contador <= vr_epr_qtctremp
          LOOP
            -- Calcular prestação em URV
            IF vr_tpdebito = 2 THEN
              vr_epr_vlpreemp(vr_contador) := TRUNC(vr_epr_vlpreemp(vr_contador) / vr_vldaurvs, 2);

              IF vr_epr_vlpreemp(vr_contador) = 0 THEN
                vr_epr_vlpreemp(vr_contador) := 0.01;
              END IF;
            END IF;

            -- Assimilar valores das variáveis
            vr_rel_vltotpre := nvl(vr_rel_vltotpre,0) + nvl(vr_epr_vlpreemp(vr_contador),0);
            vr_rel_nrseqdeb := vr_rel_nrseqdeb + 1;
            vr_rel_nrctremp := vr_epr_nrctremp(vr_contador);
            vr_rel_vlpreemp := vr_epr_vlpreemp(vr_contador);
            vr_rel_nrdocmto := vr_rel_nrctremp;

            -- Verificar tipo do bem
            IF vr_intipsai IN (1, 4, 5) AND
               vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).tpdebemp NOT IN (2, 3) THEN
              -- Verificar empresa
              IF rw_crapsol.cdempres IN (1, 4, 20, 99) THEN
                -- Formato Hering
                IF vr_flgfirst THEN
                  --marca que havera geracao do arquivo
                  vr_flgarqab := TRUE;

                  --escreve no arquivo
                  gene0002.pc_escreve_xml(vr_xmlc3,
                                          vr_texto_completo3,
                                          'DEBEM'||
                                          nvl(vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).sgempres,' ')||
                                          vr_rel_dtproces||
                                          vr_rel_dtrefere||
                                          LPAD(vr_rel_nrversao,3,'0')||
                                          LPAD(rw_crapsol.cdempres,5,'0')||
                                          vr_tpdebito||
                                          LPAD(nvl(vr_vldaurvs,0) * 100,7,'0')||
                                          LPAD(' ',16,' ')||chr(13));
                END IF;

                -- Gerar quebra por contator
                IF vr_contador = vr_epr_qtctremp THEN
                  --incrementa o sequencial do arquivo
                  vr_arq_nrseqdeb := vr_arq_nrseqdeb + 1;

                  --escreve no arquivo
                  gene0002.pc_escreve_xml(vr_xmlc3,
                                          vr_texto_completo3,
                                          LPAD(rw_crapsol.cdempres,5,'0')||
                                          LPAD(vr_rel_nrcadast,7,'0')    ||
                                          LPAD(vr_rel_cddescto,3,'0')    ||
                                          ' '                            ||
                                          vr_rel_dtrefere                ||
                                          LPAD(vr_arq_nrseqdeb,5,'0')    ||
                                          ' '                            ||
                                          LPAD(nvl(vr_rel_nmsistem,' '),2,' ')||
                                          LPAD(vr_rel_vltotpre * 100,16,'0')||
                                          LPAD(' ',4,' ')||CHR(13));
                END IF;
              ELSIF rw_crapsol.cdempres IN (9, 10, 11, 13) THEN
                -- Formato SENIOR - RUBI
                IF vr_flgfirst THEN
                  vr_flgarqab := TRUE;

                  -- Consistir por tipo de empresa
                  IF rw_crapsol.cdempres = 10 OR rw_crapsol.cdempres = 9 THEN
                    vr_rel_cdempres := 1;
                  ELSIF rw_crapsol.cdempres = 13 THEN
                    vr_rel_cdempres := 10;
                  ELSE
                    vr_rel_cdempres := rw_crapsol.cdempres;
                  END IF;
                  --escreve no arquivo
                  gene0002.pc_escreve_xml(vr_xmlc3,
                                          vr_texto_completo3,
                                          '0;FP-EVENTOS'||CHR(13));
                END IF;

                -- Verificar número de iterações do contador
                IF vr_contador = vr_epr_qtctremp THEN

                  --montando a linha que sera escrita no arquivo
                  vr_linha := '1;'||
                              LPAD(vr_rel_cdempres,5,'0')||';'||
                              LPAD(vr_cdcalcul,3,'0')||';';

                  IF rw_crapsol.cdempres = 9 THEN
                    vr_linha := vr_linha ||LPAD(vr_con_nrcadast,9,'0')||';';
                  ELSE
                    vr_linha := vr_linha ||LPAD(vr_rel_nrcadast,9,'0')||';';
                  END IF;

                  vr_linha := vr_linha ||LPAD(vr_rel_cddescto,4,'0')||';;100;'||
                              LPAD(vr_rel_vltotpre * 100,11,'0');

                  --escreve no arquivo
                  gene0002.pc_escreve_xml(vr_xmlc3,
                                          vr_texto_completo3,
                                          vr_linha||chr(13));

                END IF;
              ELSE
                -- Formato de crédito
                IF vr_flgfirst THEN
                  --atualiza para verdadeiro
                  vr_flgarqab := TRUE;
                  --escreve no arquivo
                  gene0002.pc_escreve_xml(vr_xmlc3,
                                          vr_texto_completo3,
                                          '1 '||
                                          TO_CHAR(vr_rel_dtultdia,'DDMMYYYY')    ||' '||
                                          LPAD(rw_crapsol.cdempres,5,'0')||' '||
                                          nvl(vr_tpdebito,0)             ||' '||
                                          LPAD(TO_CHAR(nvl(vr_vldaurvs,0),'FM99990D00'),8,'0')||
                                          LPAD(' ',24,' ')||chr(13));
                END IF;

                -- Verificar contador
                IF vr_contador = vr_epr_qtctremp THEN
                  --incrementando o contador de registros do arquivo
                  vr_arq_nrseqdeb := vr_arq_nrseqdeb + 1;
                  --escreve no arquivo
                  gene0002.pc_escreve_xml(vr_xmlc3,
                                          vr_texto_completo3,
                                          '0 '||
                                          LPAD(vr_arq_nrseqdeb,6,'0')||' '||
                                          LPAD(vr_rel_nrdconta,8,'0')||' '||
                                          LPAD(TO_CHAR(vr_rel_vltotpre,'FM999999990D00'),12,'0')||' '||
                                          '93 '||
                                          LPAD(vr_cdtipsfx,2,'0')||' '||
                                          '000000000,00'||chr(13));
                END IF;
              END IF;

            ELSIF vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).tpdebemp IN (2,3) THEN
              -- Gravar dados na CRAPAVS
              BEGIN
                --incrementa a sequencia
                vr_ass_nrseqdeb := vr_ass_nrseqdeb + 1;
                --insere dados na tabela crapavs
                INSERT INTO crapavs(dtmvtolt
                                   ,nrdconta
                                   ,nrdocmto
                                   ,vllanmto
                                   ,cdagenci
                                   ,tpdaviso
                                   ,cdhistor
                                   ,dtdebito
                                   ,cdsecext
                                   ,cdempres
                                   ,cdempcnv
                                   ,insitavs
                                   ,dtrefere
                                   ,vldebito
                                   ,vlestdif
                                   ,nrseqdig
                                   ,flgproce
                                   ,cdcooper)
                 VALUES(vr_dtmvtolt          --dtmvtolt
                       ,vr_rel_nrdconta      --nrdconta
                       ,vr_rel_nrdocmto      --nrdocmto
                       ,vr_rel_vlpreemp      --vllanmto
                       ,vr_rel_cdagenci      --cdagenci
                       ,1                    --tpdaviso
                       ,108                  --cdhistor
                       ,NULL                 --dtdebito
                       ,vr_rel_cdsecext      --cdsecext
                       ,rw_crapsol.cdempres  --cdempres
                       ,rw_crapsol.cdempres  --cdempcnv
                       ,0                    --insitavs
                       ,vr_rel_dtultdia      --dtrefere
                       ,0                    --vldebito
                       ,0                    --vlestdif
                       ,vr_ass_nrseqdeb      --nrseqdig
                       ,0                    --flgproce
                       ,pr_cdcooper);        --cdcooper
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao gravar em CRAPAVS: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
            END IF;

            -- Validar valor incicial
            IF vr_intipsai IN (2, 3, 4, 5) THEN
              -- Verificar flag de controle
              IF vr_flgfirst THEN
                -- Dados do XML
                vr_xmlb := vr_xmlb || '<arquivo><nmarqimp>' || vr_nmarqimp(vr_contaarq) || '</nmarqimp></arquivo>';
                gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);

                vr_flgarqab := TRUE;

                -- Dados do XML
                vr_xmlb := vr_xmlb || '<empresa><rel_dsempres>' || RPAD(vr_rel_dsempres,20,' ') || '</rel_dsempres>';
                --vr_xmlb := vr_xmlb || '<rel_dsempres>' || vr_rel_dsempres || '</rel_dsempres>';
                vr_xmlb := vr_xmlb || '<rel_dsdebito>' || vr_rel_dsdebito || '</rel_dsdebito></empresa>';
                gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
              END IF;

              -- Tratamento exclusivo loja Hering
              IF rw_crapsol.cdempres = 6 THEN
                vr_vldacpmf := ROUND(nvl(vr_rel_vlpreemp,0) * nvl(vr_tab_txcpmfcc,0), 2);
                vr_rel_vlprecpm := nvl(vr_rel_vlpreemp,0) + nvl(vr_vldacpmf,0);
                vr_rel_vltotpre := nvl(vr_rel_vltotpre,0) + nvl(vr_vldacpmf,0);
              ELSE
                vr_vldacpmf := 0;
                vr_rel_vlprecpm := 0;
                vr_rel_vltotpre := 0;
              END IF;

              -- Gerar dados XML
              vr_xmlb := vr_xmlb || '<dados><rel_nrseqdeb>' || gene0002.fn_mask(vr_rel_nrseqdeb,'zzz.zz9') || '</rel_nrseqdeb>';
              vr_xmlb := vr_xmlb || '<rel_nrcadast>' || gene0002.fn_mask(vr_rel_nrcadast,'zzzz.zzz.9') || '</rel_nrcadast>';
              gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
              vr_xmlb := vr_xmlb || '<rel_nrdconta>' || gene0002.fn_mask_conta(vr_rel_nrdconta) || '</rel_nrdconta>';
              vr_xmlb := vr_xmlb || '<rel_nrctremp>' || gene0002.fn_mask(vr_rel_nrctremp,'zz.zzz.zz9') || '</rel_nrctremp>';
              gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
              vr_xmlb := vr_xmlb || '<rel_nrdocmto>' || gene0002.fn_mask(vr_rel_nrdocmto,'z.zzz.zz9') || '</rel_nrdocmto>';
              vr_xmlb := vr_xmlb || '<rel_vlpreemp>' || TO_CHAR(vr_rel_vlpreemp,'fm999G999G990D00') || '</rel_vlpreemp>';
              gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
              vr_xmlb := vr_xmlb || '<rel_vlprecpm>' || TO_CHAR(vr_rel_vlprecpm,'fm999G999G990D00') || '</rel_vlprecpm>';
              vr_xmlb := vr_xmlb || '<rel_nmprimtl>' || SUBSTR(vr_rel_nmprimtl,1,37) || '</rel_nmprimtl>';
              gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);

              IF vr_contador = vr_epr_qtctremp THEN
                vr_xmlb := vr_xmlb || '<rel_vltotpre>' || TO_CHAR(vr_rel_vltotpre,'fm999G999G990D00') || '</rel_vltotpre>';
              ELSE
                vr_xmlb := vr_xmlb || '<rel_vltotpre></rel_vltotpre>';
              END IF;

              -- Gerar dados XML
              vr_xmlb := vr_xmlb || '<rel_dsempres>' || RPAD(vr_rel_dsempres,20,' ') || '</rel_dsempres>';
              vr_xmlb := vr_xmlb || '<rel_tpdebito>' || vr_rel_tpdebito || '</rel_tpdebito>';
              gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
              vr_xmlb := vr_xmlb || '<rel_dsdebito>' || vr_rel_dsdebito || '</rel_dsdebito></dados>';
              gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);

              -- Assimilar valores
              vr_tot_vlpreemp := nvl(vr_tot_vlpreemp,0) + nvl(vr_rel_vlpreemp,0);
              vr_tot_vlprecpm := nvl(vr_tot_vlprecpm,0) + nvl(vr_rel_vlprecpm,0);
              vr_tot_qtctremp := nvl(vr_tot_qtctremp,0) + 1;

              IF vr_contador = vr_epr_qtctremp THEN
                vr_tot_qtdassoc := nvl(vr_tot_qtdassoc,0) + 1;
              END IF;
            END IF;
            -- vai para o proximo item
            vr_contador := vr_contador + 1;
            --indica que não é o primeiro registro
            vr_flgfirst := FALSE;
          END LOOP;
        END LOOP;

        -- Verificar flag de quebra de arquivo
        IF vr_flgarqab THEN
          -- Verificar tipo de inicialização
          IF vr_intipsai IN (1, 4, 5) AND vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).tpdebemp NOT IN (2, 3) THEN
            -- Verificar empresa da solicitação
            IF rw_crapsol.cdempres NOT IN (1, 4, 9, 10, 11, 13, 20, 99) THEN
              --escreve no arquivo
              gene0002.pc_escreve_xml(vr_xmlc3,
                                      vr_texto_completo3,
                                      '9 999999 99999999 999999999,99 99 99 999999999,99'||chr(13));
            END IF;
            --finaliza o arquivo xml
            gene0002.pc_escreve_xml(vr_xmlc3,
                                    vr_texto_completo3,' ',TRUE);

            -- Gerando o arquivo fisico
            gene0002.pc_clob_para_arquivo(pr_clob => vr_xmlc3
                                         ,pr_caminho => vr_nom_arq
                                         ,pr_arquivo => vr_nmarqdeb
                                         ,pr_des_erro => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;


            -- Gerar mensagens no LOG de acordo com a empresa
            IF rw_crapsol.cdempres IN (1, 20, 99) THEN
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 3
                                        ,pr_des_log      => TO_CHAR(SYSDATE, 'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> Transmitir o arquivo ' ||
                                                            vr_nmarqtrf || '(ap/cccr/empr/' || LPAD(rw_crapsol.cdempres, 5, '0') || ') para a Hering');
            ELSIF rw_crapsol.cdempres = 4 THEN
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 3
                                        ,pr_des_log      => TO_CHAR(SYSDATE, 'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> Gravar fita para a Ceval com o arquivo ' ||
                                                            vr_nmarqtrf);
            ELSIF rw_crapsol.cdempres = 9 THEN
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 3
                                        ,pr_des_log      => TO_CHAR(SYSDATE, 'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> Gravar disquete para a CONSUMO com o arquivo ' ||
                                                            vr_nmarqtrf);
            ELSIF rw_crapsol.cdempres = 10 THEN
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 3
                                        ,pr_des_log      => TO_CHAR(SYSDATE, 'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> Gravar disquete para a HERCO com o arquivo ' ||
                                                            vr_nmarqtrf);
            ELSIF rw_crapsol.cdempres = 13 THEN
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 3
                                        ,pr_des_log      => TO_CHAR(SYSDATE, 'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> Gravar disquete para a ADH com o arquivo ' ||
                                                            vr_nmarqtrf);
            END IF;

            --copia o arquivo para o diretorio /integra com nome diferente
            IF rw_crapsol.cdempres IN (5,26,29,31) THEN
              -- Comando para copiar o arquivo para a pasta salvar
              vr_comando := 'cp '||vr_nom_arq||'/'||vr_nmarqdeb||' '||
                            vr_nom_int||'/e'||LPAD(rw_crapsol.cdempres,5,'0')||
                            TO_CHAR(vr_rel_dtultdia,'DDMMYYYY')||' 2> /dev/null';

              --Executar o comando no unix
              GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => pr_dscritic);

              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
               pr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
               -- retornando ao programa chamador
               RAISE vr_exc_saida;
              END IF;

            END IF;

            -- Comando para copiar o arquivo para a pasta salvar
            vr_comando := 'cp '||vr_nom_arq||'/'||vr_nmarqdeb||' '||vr_nom_salvar||' 2> /dev/null';

            --Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => pr_dscritic);

            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
             pr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
             -- retornando ao programa chamador
             RAISE vr_exc_saida;
            END IF;

          END IF;

          -- Verificar valor inicial
          IF vr_intipsai IN (2, 3, 4, 5) THEN
            vr_xmlb := vr_xmlb || '<sumarizacao><rel_dsempres>' || RPAD(vr_rel_dsempres,20,' ') || '</rel_dsempres>';
            vr_xmlb := vr_xmlb || '<rel_tpdebito>' || vr_rel_tpdebito || '</rel_tpdebito>';
            vr_xmlb := vr_xmlb || '<rel_dsdebito>' || vr_rel_dsdebito || '</rel_dsdebito>';
            gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
            vr_xmlb := vr_xmlb || '<tot_qtdassoc>' || gene0002.fn_mask(vr_tot_qtdassoc,'zzz.zz9') || '</tot_qtdassoc>';
            vr_xmlb := vr_xmlb || '<tot_qtctremp>' || gene0002.fn_mask(vr_tot_qtctremp,'zzz.zz9') || '</tot_qtctremp>';
            vr_xmlb := vr_xmlb || '<tot_vlpreemp>' || TO_CHAR(vr_tot_vlpreemp,'fm999G999G990D00') || '</tot_vlpreemp>';
            gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
            vr_xmlb := vr_xmlb || '<tot_vlprecpm>' || TO_CHAR(vr_tot_vlprecpm,'fm999G999G990D00') || '</tot_vlprecpm></sumarizacao>';
            gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);

            -- Definir parâmetros do relatório
            vr_nrcopias := 1;

            IF vr_nrdevias(vr_contaarq) > 1 THEN
              vr_nmformul := vr_nrdevias(vr_contaarq) || 'vias';
            ELSE
              vr_nmformul := ' ';
            END IF;

            -- Finalizar XML
            vr_xmlb := vr_xmlb || '</root>';
            gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => TRUE, pr_clob => vr_xmlc);

            -- Gerando o relatório
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                       ,pr_cdprogra  => vr_cdprogra
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                       ,pr_dsxml     => vr_xmlc
                                       ,pr_dsxmlnode => '/root/dados'
                                       ,pr_dsjasper  => 'crrl065.jasper'
                                       ,pr_dsparams  => ''
                                       ,pr_dsarqsaid => vr_nom_dir||'/'||vr_nmarqimp(vr_contaarq)
                                       ,pr_flg_gerar => 'N'
                                       ,pr_qtcoluna  => 132
                                       ,pr_sqcabrel  => 2
                                       ,pr_flg_impri => 'S'
                                       ,pr_nmformul  => vr_nmformul
                                       ,pr_nrcopias  => 1
                                       ,pr_des_erro  => vr_dscritic);

          END IF;
        END IF;

        -- Atualizando os valores da tabela crapsol
        BEGIN
          UPDATE crapsol sol
          SET sol.insitsol = 2
          WHERE sol.rowid = rw_crapsol.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- gerando a critica
            vr_dscritic := 'Erro ao atualizar as tabelas crapsol . '||SQLERRM;
            --abortando a execucao
            RAISE vr_exc_saida;
        END;

        --atualizando os valores da tabela crapemp
        BEGIN
          UPDATE crapemp emp
          SET emp.inavsemp = 1
          WHERE emp.cdcooper = pr_cdcooper
            AND emp.cdempres = rw_crapsol.cdempres;

          -- Verifica se algum registro foi atualizado
          IF SQL%ROWCOUNT = 0 THEN
            --040 - Empresa nao cadastrada.
            vr_cdcritic := 40;
            --descricao da critica
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            --escreve no log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                                                          'EMPRESA ' || LPAD(rw_crapsol.cdempres, 5, '0')
                                      ,pr_nmarqlog     => 'PROC_BATCH');

            --aborta a execucao do sistema
            RAISE vr_exc_saida;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            --gerando a critica
            vr_dscritic := 'Erro ao atualizar as tabelas crapemp. '||SQLERRM;
            --abortando a execucao do programa
            RAISE vr_exc_saida;
        END;
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_xmlc);
        dbms_lob.freetemporary(vr_xmlc);

        dbms_lob.close(vr_xmlc3);
        dbms_lob.freetemporary(vr_xmlc3);

      END LOOP;

      -- Gerar mensagem de crítica para falha no processo
      IF NOT vr_regexist THEN
        --157 - Nao ha solicitacoes
        vr_cdcritic := 157;
        --descricao da critica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        --escreve no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic || ' - SOL043 '
                                  ,pr_nmarqlog     => 'PROC_BATCH');

        --aborta a execucao do programa
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
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> '|| vr_dscritic );

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
  END pc_crps080;
/
