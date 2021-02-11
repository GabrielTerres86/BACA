CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS280_I_WAG(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Coop. conectada
                                                   ,pr_rw_crapdat IN OUT btch0001.cr_crapdat%ROWTYPE --> Dados da crapdat
                                                   ,pr_dtrefere   IN DATE                  --> Data de referência para o cálculo
                                                   ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Codigo programa conectado
                                                   ,pr_dsdircop   IN crapcop.dsdircop%TYPE --> Diretório da cooperativa
                                                    ----
                                                   ,pr_cdagenci IN PLS_INTEGER DEFAULT 0 --> Código da agência, utilizado no paralelismo
                                                   ,pr_idparale IN PLS_INTEGER DEFAULT 0 --> Identificador do job executando em paralelo.
                                                   ,pr_flgresta IN PLS_INTEGER           --> Flag padrão para utilização de restart
                                                   ,pr_flgrelat IN PLS_INTEGER DEFAULT 0 --> Flag padr�o para somente gerar os relat�rios
                                                   ,pr_stprogra OUT PLS_INTEGER          --> Saída de termino da execução
                                                   ,pr_infimsol OUT PLS_INTEGER          --> Saída de termino da solicitação,
                                                    ----
                                                   ,pr_vltotprv  OUT crapbnd.vltotprv%TYPE --> Total acumulado de provisões
                                                   ,pr_vltotdiv  OUT crapbnd.vltotdiv%TYPE --> Total acumulado de dívidas
                                                   ,pr_cdcritic  OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                                   ,pr_dscritic  OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
BEGIN
  /* ..........................................................................

  Wagner: Feito em 05/01/2021 - Objetivo: Ter a op��o de somente gerar os 
  relat�rios.
  ............................................................................. */

  DECLARE
    -- Constante
      vr_flgerar  CHAR(1) := 'N';
    -- Tratamento de erros
    vr_exc_erro exception;
    -- Erro em chamadas da pc_gera_erro
    vr_des_reto VARCHAR(3);
    vr_tab_erro GENE0001.typ_tab_erro;
    -- Desvio de fluxo para ingorar o registro
    vr_exc_ignorar EXCEPTION;
    -- chave de indice
    vr_chave_index VARCHAR2(240);

    -- Constante para usar em indice do primeiro nivel
    vr_vlfinanc_pf CONSTANT VARCHAR2(10) := 'VLFINANCPF'; -- Valor Financiamento PF
    vr_vlfinanc_pj CONSTANT VARCHAR2(10) := 'VLFINANCPJ'; -- Valor Financiamento PJ
    vr_vlempres_pf CONSTANT VARCHAR2(10) := 'VLEMPRESPF'; -- Valor Emprestimo PF
    vr_vlempres_pj CONSTANT VARCHAR2(10) := 'VLEMPRESPJ'; -- Valor Emprestimo PJ
      vr_vlchqdes    CONSTANT VARCHAR2(10) := 'VLCHQDES';   -- Valor Cheque Descontado
    vr_vltitdes_cr CONSTANT VARCHAR2(10) := 'VLTITDESCR'; -- Valor Titulo Descontado Com Registro
    vr_vltitdes_sr CONSTANT VARCHAR2(10) := 'VLTITDESCR'; -- Valor Titulo Descontado Sem Registro
      vr_vladtdep    CONSTANT VARCHAR2(10) := 'VLADTDEP';   -- Valor Adiantamento Depositante
      vr_vlchqesp    CONSTANT VARCHAR2(10) := 'VLCHQESP';   -- Valor Cheque Especial
    vr_vleprces    CONSTANT VARCHAR2(10) := 'VLEPRCES'; -- Valor Emprestimo PF
    -- Constante para usar em indice do segundo nivel
      vr_provis      CONSTANT VARCHAR2(10) := 'PROVIS';     -- Coluna de Provisao do relat 227
      vr_divida      CONSTANT VARCHAR2(10) := 'DIVIDA';     -- Coluna de Divida do relat 227

    ------------- Projeto Ligeirinho: -------------
    -- Qtde parametrizada de Jobs
    vr_qtdjobs number;
    -- Job name dos processos criados
    vr_jobname varchar2(30);
    -- ID para o paralelismo
    vr_idparale   integer;
    vr_cdcritic   pls_integer;
    vr_dscritic   varchar2(2000);
    vr_qterro     number := 0;
    vr_tpexecucao tbgen_prglog.tpexecucao%type;
    -- Exceptions
    vr_exc_fimprg exception;
    vr_exc_saida  exception;
    -- Código do programa
    vr_cdprogra      crapprg.cdprogra%type;
    vr_idlog_ini_ger tbgen_prglog.idprglog%type;
    vr_idlog_ini_par tbgen_prglog.idprglog%type;
    -- Bloco PLSQL para chamar a execução paralela
    vr_dsplsql varchar2(4000);
    -- Índices para leitura das pl/tables ao gerar o XML
    vr_indice_dados_epr varchar2(1000);
    vr_indice_crapris   varchar2(1000);
    vr_ds_xml           tbgen_batch_relatorio_wrk.dscritic%type;

    --(AWAE) Titulos de Borderos: pl/tables de Titulos
    vr_indice_dados_tdb varchar2(200);
    vr_indice_tdb       varchar2(200);
    vr_nrctrdsc_tdb     crapcyb.nrctremp%TYPE;
    vr_idx_grp          VARCHAR2(20);

    ds_character_separador constant varchar2(1) := '#';
    --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
    vr_idcontrole tbgen_batch_controle.idcontrole%TYPE;

    ---------- Cursores Genéricos ----------

    -- Cursor genérico de parametrização --
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT tab.dstextab
              ,tab.tpregist
        FROM craptab tab
         WHERE tab.cdcooper        = pr_cdcooper
         AND UPPER(tab.nmsistem) = pr_nmsistem
         AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres        = pr_cdempres
         AND UPPER(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist        >= pr_tpregist
       ORDER BY tab.progress_recid;
    rw_craptab cr_craptab%ROWTYPE;

    -------- Tipos e registros genéricos ------------

    -- Definição do tipo de registro para englobar descrições e percentuais dos riscos A, B, C, etc...
    -- Obs: Na versao antiga do programa, cada campo era um vetor, na nova, todos os campos
    --      ficam presentes num unico registro da tabela vr_tab_risco
      TYPE typ_reg_risco IS
        RECORD(dsdrisco VARCHAR2(2)   -- "x(02)"
              ,percentu NUMBER(5,2)); -- "zz9.99"

    -- Definicao do tipo de tabela de riscos
      TYPE typ_tab_risco IS
        TABLE OF typ_reg_risco
          INDEX BY PLS_INTEGER;

    -- Pl-Table para gravar valores contah por tipo de pessoa com o index - 1-Fisico/2-Juridico
      TYPE typ_reg_total IS
        RECORD(vlfinanc_pf NUMBER   -- Valor Financiamento Pessoa Fisica
              ,vlfinanc_pj NUMBER   -- Valor Financiamento Pessoa Juridica
              ,vlempres_pf NUMBER   -- Valor Emprestimo
              ,vlempres_pj NUMBER   -- Valor Emprestimo
              ,vlchqdes NUMBER      -- Valor Cheque Descontado
              ,vltitdes_cr NUMBER   -- Valor Titulo Descontado
              ,vltitdes_sr NUMBER   -- Valor Titulo Descontado
              ,vladtdep NUMBER      -- Valor Adiantamento Depositante
              ,vlchqesp NUMBER);    -- Valor Cheque Especial

    -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
    TYPE typ_tab_total IS TABLE OF typ_reg_total INDEX BY PLS_INTEGER;

    -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
    TYPE typ_tab_coluna IS TABLE OF typ_tab_total INDEX BY VARCHAR2(10);

    -- Dados Para Contabilidade - 1-Fisico/2-Juridico
    TYPE typ_tab_contab IS TABLE OF typ_tab_coluna INDEX BY VARCHAR2(10);

    -- Vetor para armazenar os dados de riscos
    vr_tab_risco typ_tab_risco;
    -- Vetor auxiliar para guardar uma posição a mais
    vr_tab_risco_aux typ_tab_risco;
    -- Vetor auxiliar para guardar uma posição a mais
      vr_tab_contab    typ_tab_contab;
    -- Vetor auxiliar para guardar uma posição a mais
      vr_tab_contab_cessao    typ_tab_contab;

    -- AWAE: Registro para as informações de borderô e título de borderô
    --       das tabelas crapbdt e craptdb. Pode ser que não necessitemos de todos estes campos
    TYPE typ_reg_craptdb IS RECORD (
             nrdconta craptdb.nrdconta%TYPE
            ,dtvencto craptdb.dtvencto%TYPE
            ,nrseqdig craptdb.nrseqdig%TYPE
            ,cdoperad craptdb.cdoperad%TYPE
            ,nrdocmto craptdb.nrdocmto%TYPE
            ,nrctrlim craptdb.nrctrlim%TYPE
            ,nrborder craptdb.nrborder%TYPE
            ,vlliquid craptdb.vlliquid%TYPE
            ,dtlibbdt craptdb.dtlibbdt%TYPE
            ,cdcooper craptdb.cdcooper%TYPE
            ,cdbandoc craptdb.cdbandoc%TYPE
            ,nrdctabb craptdb.nrdctabb%TYPE
            ,nrcnvcob craptdb.nrcnvcob%TYPE
            ,cdoperes craptdb.cdoperes%TYPE
            ,dtresgat craptdb.dtresgat%TYPE
            ,vlliqres craptdb.vlliqres%TYPE
            ,vltitulo craptdb.vltitulo%TYPE
            ,insittit craptdb.insittit%TYPE
            ,nrinssac craptdb.nrinssac%TYPE
            ,dtdpagto craptdb.dtdpagto%TYPE
            ,dtdebito craptdb.dtdebito%TYPE
            ,dtrefatu craptdb.dtrefatu%TYPE
            ,insitapr craptdb.insitapr%TYPE
            ,cdoriapr craptdb.cdoriapr%TYPE
            ,flgenvmc craptdb.flgenvmc%TYPE
            ,insitmch craptdb.insitmch%TYPE
            ,vlsldtit craptdb.vlsldtit%TYPE
            ,nrtitulo craptdb.nrtitulo%TYPE
            ,vliofprc craptdb.vliofprc%TYPE
            ,vliofadc craptdb.vliofadc%TYPE
            ,vliofcpl craptdb.vliofcpl%TYPE
            ,vlmtatit craptdb.vlmtatit%TYPE
            ,vlmratit craptdb.vlmratit%TYPE
            ,vljura60 craptdb.vljura60%TYPE
            ,vlpagiof craptdb.vlpagiof%TYPE
            ,vlpagmta craptdb.vlpagmta%TYPE
            ,vlpagmra craptdb.vlpagmra%TYPE
            ,nrctrdsc crapcyb.nrctremp%TYPE
            ,vlatraso craptdb.vltitulo%TYPE
            ,vlsaldodev craptdb.vlsldtit%TYPE
            ,cddlinha crapldc.cddlinha%TYPE
            ,qtdiaatr INTEGER
            ,qtmesdec INTEGER
            ,qtprepag INTEGER
            ,vlprepag craptdb.vltitulo%TYPE
            ,dsdlinha crapldc.dsdlinha%TYPE
            ,txmensal crapbdt.txmensal%TYPE
            ,txdiaria crapbdt.txmensal%TYPE
            -- Campos Prejuizo
            ,inprejuz crapbdt.inprejuz%TYPE
            ,dtprejuz crapbdt.dtprejuz%TYPE
            ,vlsdprej craptdb.vlsdprej%TYPE
    );

    -- AWAE: Definição de um tipo de tabela com o registro acima
      TYPE typ_tab_craptdb IS
        TABLE OF typ_reg_craptdb
          INDEX BY VARCHAR2(150);

    -- AWAE: Variaveis para armazenar informações de Titulos do Borderô
    vr_tab_craptdb typ_tab_craptdb;

    -- Registro para as informações copiadas da tabela crapris (Antigo w-crapris)
      TYPE typ_reg_crapris IS
        RECORD(cdagenci crapage.cdagenci%TYPE  --> Chave Asc
              ,nroprest NUMBER                 --> Chave Desc
              ,nmprimtl crapass.nmprimtl%TYPE  --> Chave Asc
              ,nrdconta crapris.nrdconta%TYPE
              ,nrcpfcgc crapris.nrcpfcgc%TYPE
              ,dtrefere crapris.dtrefere%TYPE
              ,innivris crapris.innivris%TYPE
              ,nrctremp crapris.nrctremp%TYPE
              ,vlpreemp crapepr.vlpreemp%TYPE
              ,cdlcremp VARCHAR2(10)
              ,qtatraso NUMBER
              ,qtdiaatr PLS_INTEGER
              ,cdmodali crapris.cdmodali%TYPE
              ,nrseqctr crapris.nrseqctr%TYPE
              ,vldivida crapris.vldivida%TYPE
              ,vljura60 crapris.vljura60%TYPE
              ,cdorigem crapris.cdorigem%TYPE
              ,inpessoa crapris.inpessoa%TYPE
              ,qtdriclq crapris.qtdriclq%TYPE
              ,cdfinemp crapepr.cdfinemp%TYPE
              ,dsinfaux crapris.dsinfaux%TYPE
              ,tpemprst VARCHAR2(10)
              ,cdusolcr craplcr.cdusolcr%TYPE
              ,dsorgrec craplcr.dsorgrec%TYPE
              ,dtinictr crapris.dtinictr%TYPE
              ,fleprces INTEGER
              ,inprejuz crapass.inprejuz%TYPE
              ,vliofmes crapsld.vliofmes%TYPE
              ,vljurantpp crapris.vljurantpp %TYPE --P577
              ,vljurmorpp crapris.vljurmorpp%TYPE -- PRJ577
              ,vljurmulpp crapris.vljurmulpp%TYPE -- PRJ577
              );

    -- Definição de um tipo de tabela com o registro acima
      TYPE typ_tab_crapris IS
        TABLE OF typ_reg_crapris
          INDEX BY VARCHAR2(150);

    -- Tabela para armazenar os registros da crapris em processo
    vr_tab_crapris typ_tab_crapris;

    -- Variavel para chaveamento da tabela de riscos
    -- Agencia(5) + NroPrest(12) + NmPrintl(60) + NrCtrEmp(10) + NrSeqCtr(5)
    -- NrdConta(10) + DtRefere(8) + InNivRis(5)
    vr_des_chave_crapris VARCHAR2(150);

    -- Definição de registro para totalização dos riscos
      TYPE typ_reg_totris IS
        RECORD(qtdabase INTEGER   -- "zzz,zz9"
              ,vldabase NUMBER    -- "zzz,zzz,zzz,zz9.99"
              ,vljura60 NUMBER    --
              ,vljrpf60 NUMBER    --
              ,vljrpj60 NUMBER    --
              ,vlprovis NUMBER);  -- "zzz,zzz,zzz,zz9.99"

    -- Definicao do tipo de tabela de totalização de riscos
      TYPE typ_tab_totris IS
        TABLE OF typ_reg_totris
          INDEX BY PLS_INTEGER;

    -- Vetor para armazenar a totalização dos riscos por PAC
    vr_tab_totrispac typ_tab_totris;
    -- Vetor para armazenar a totalização dos riscos geral
    vr_tab_totrisger typ_tab_totris;

    -- Tipo de registro para as informações da contabilidade
      TYPE typ_reg_contabi IS
        RECORD(rel1731_1      NUMBER(14,2) DEFAULT 0  -- Financiamentos Pessoais [Provisao]
              ,rel1731_1_v    NUMBER(14,2) DEFAULT 0  -- Financiamentos Pessoais [Divida(S/Prejuizo)]
              ,rel1731_2      NUMBER(14,2) DEFAULT 0  -- Financiamentos Empresas [Provisao]
              ,rel1731_2_v    NUMBER(14,2) DEFAULT 0  -- Financiamentos Empresas [Divida(S/Prejuizo)]
              ,rel5584        NUMBER(14,2) DEFAULT 0  -- Emprestimos Pessoais [Provisao]
              ,rel5584_v      NUMBER(14,2) DEFAULT 0  -- Emprestimos Pessoais [Divida(S/Prejuizo)]
              ,rel1723        NUMBER(14,2) DEFAULT 0  -- Emprestimos Empresas [Provisao]
              ,rel1723_v      NUMBER(14,2) DEFAULT 0  -- Emprestimos Empresas [Divida(S/Prejuizo)]
              ,rel1724_c      NUMBER(14,2) DEFAULT 0  -- Cheques Descontados [Provisao]
              ,rel1724_v_c    NUMBER(14,2) DEFAULT 0  -- Cheques Descontados [Divida(S/Prejuizo)]
              ,rel1724_cr     NUMBER(14,2) DEFAULT 0  -- Titulos Desc. C/Registro [Provisao]
              ,rel1724_v_cr   NUMBER(14,2) DEFAULT 0  -- Titulos Desc. C/Registro [Divida(S/Prejuizo)]
              ,rel1724_sr     NUMBER(14,2) DEFAULT 0  -- Titulos Desc. S/Registro [Provisao]
              ,rel1724_v_sr   NUMBER(14,2) DEFAULT 0  -- Titulos Desc. S/Registro [Divida(S/Prejuizo)]
              ,rel1722_0101   NUMBER(14,2) DEFAULT 0  -- Adiant.Depositante [Provisao]
              ,rel1722_0101_v NUMBER(14,2) DEFAULT 0  -- Adiant.Depositante [Divida(S/Prejuizo)]
              ,rel1722_0201   NUMBER(14,2) DEFAULT 0  -- Cheque Especial [Provisao]
              ,rel1722_0201_v NUMBER(14,2) DEFAULT 0  -- Cheque Especial [Divida(S/Prejuizo)]
              ,rel1760        NUMBER(14,2) DEFAULT 0  -- Emprestimos cessao [Provisao]
              ,rel1760_v      NUMBER(14,2) DEFAULT 0  -- Emprestimos cessao [Divida(S/Prejuizo)]
      );

    -- Criação de um vetor com base nesse registro
    vr_vet_contabi typ_reg_contabi;

    -- Estrutra de PL Table para tabela CRAPTCO
      TYPE typ_tab_craptco 
        IS TABLE OF crapass.nrdconta%TYPE
          INDEX BY PLS_INTEGER;

    vr_tab_craptco typ_tab_craptco;

    -- Definição de registro para totalização por origem de microcrédito
      TYPE typ_reg_microcredito IS
        RECORD(idgrumic INTEGER   -- Id do grupo para separação das informações - 1 - CECRED / 2 - BNDES
              ,vlpesfis NUMBER    -- Valor acumulado das operações no MicroCrédito para Pessoas Físicas
              ,vlpesjur NUMBER    -- Valor acumulado das operações no MicroCrédito para Pessoas Jurídicas
							-- PRJ Microcredito
              ,vlate90d NUMBER    -- Valor acumulado das operações no MicroCrédito com prazo até 90 dias
              ,vlaci90d NUMBER    -- Valor acumulado das operações no MicroCrédito com prazo acima de 90 dias
							,vlj60at90d NUMBER    -- Valor acumulado dos juros +60 até 90 dias
							,vlj60ac90d NUMBER    -- Valor acumulado dos juros +60 acima de 90 dias
							);

    -- Definicao do tipo de tabela totalização por origem de microcrédito
      TYPE typ_tab_microcredito IS
        TABLE OF typ_reg_microcredito
          INDEX BY craplcr.dsorgrec%type;

    -- Vetor para armazenar a totalização por origem de microcrédito
    vr_tab_microcredito typ_tab_microcredito;

    -- Definição de registro para totalização por finalidade de microcrédito
      TYPE typ_reg_miccred_fin IS
        RECORD(vllibctr    NUMBER   -- Valor acumulado liberação de contratos
              ,vlaprrec    NUMBER   -- Valor acumulado apropriação de receitas
              ,vlprvper    NUMBER   -- Valor acumulado provisão de perdas
              ,vldebpar91  NUMBER   -- Valor acumulado débito de parcelas historico 91
              ,vldebpar95  NUMBER   -- Valor acumulado débito de parcelas historico 95
      ,vldebpar441 NUMBER); -- Valor acumulado débito de parcelas historico 441

    -- Definicao do tipo de tabela totalização por finalidade de microcrédito
      TYPE typ_tab_miccred_fin IS
        TABLE OF typ_reg_miccred_fin
          INDEX BY VARCHAR2(5);

    -- Vetor para armazenar a totalização por finalidade de microcrédito
    vr_tab_miccred_fin typ_tab_miccred_fin;

    -- Definição de registro para totalização por nível de risco de microcrédito
      TYPE typ_reg_miccred_nivris IS
        RECORD(vlslddev NUMBER);  -- Valor acumulado saldo devedor

    -- Definicao do tipo de tabela totalização por nível de risco de microcrédito
      TYPE typ_tab_miccred_nivris IS
        TABLE OF typ_reg_miccred_nivris
          INDEX BY crawepr.dsnivris%type;

    -- Vetor para armazenar a totalização por nível de risco de microcrédito
    vr_tab_miccred_nivris typ_tab_miccred_nivris;

      
    -- Definição de registro para totalização por nível de risco de FINAME
      TYPE typ_reg_finame_nivris IS
        RECORD(vlslddev NUMBER);  -- Valor acumulado saldo devedor

    -- Definicao do tipo de tabela totalização por nível de risco de FINAME
      TYPE typ_tab_finame_nivris IS
        TABLE OF typ_reg_finame_nivris
          INDEX BY crawepr.dsnivris%type;

    -- Vetor para armazenar a totalização por nível de risco de FINAME
    vr_tab_finame_nivris typ_tab_finame_nivris;



    -- Temp Table para armazenar a data do maior atraso
    TYPE typ_tab_crapgrp IS TABLE OF NUMBER
      INDEX BY VARCHAR2(20); -- cdcooper + nrcpfcgc
    vr_tab_crapgrp typ_tab_crapgrp;


    /* PROGRAMA PESE BNDES */
    v_pese_vldivida    NUMBER := 0;   -- Valor acumulado saldo devedor
    v_pese_vlaprrec    NUMBER := 0;   -- Valor acumulado apropriação de receitas
    v_pese_vlprvper    NUMBER := 0;   -- Valor acumulado provisão de perdas
    
    TYPE typ_reg_pese_nivris IS RECORD(vlslddev NUMBER);  -- Valor acumulado saldo devedor

    -- Definicao do tipo de tabela totalização por nível de risco de microcrédito
    TYPE typ_tab_pese_nivris IS TABLE OF typ_reg_pese_nivris INDEX BY crawepr.dsnivris%type;

    -- Vetor para armazenar a totalização por nível de risco de microcrédito
    vr_tab_pese_nivris typ_tab_pese_nivris;
    /* FIM PROGRAMA PESE BNDES */

    ---------- Cursores específicos do processo ----------

    -- Busca as agencias (paralelismo) ref. arquivo para controle de informaçõs da central de risco.
    CURSOR cr_crapris_agenci(pr_cdcooper IN NUMBER,
                             pr_dtrefere IN DATE,
                             pr_cdagenci IN NUMBER,
                             pr_dtmvtolt IN DATE,
                             pr_cdprogra IN VARCHAR2) IS
      SELECT DISTINCT ass.cdagenci
        FROM crapass ass, stage.stg_crapris@bidw_temp ris
       WHERE ris.cdcooper = ass.cdcooper
         AND ris.nrdconta = ass.nrdconta
         AND ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = pr_dtrefere
         AND ris.inddocto = 1 -- Docto 3020
         AND ris.vldivida > 0
         AND ass.cdagenci = decode(pr_cdagenci, 0, ass.cdagenci, pr_cdagenci)
         AND NOT EXISTS
              (SELECT 1
                 FROM tbgen_batch_controle
                WHERE tbgen_batch_controle.cdcooper = pr_cdcooper
                  AND tbgen_batch_controle.cdprogra = pr_cdprogra
                  AND tbgen_batch_controle.tpagrupador = 1
                  AND tbgen_batch_controle.cdagrupador = ass.cdagenci
                  AND tbgen_batch_controle.insituacao = 2
                  AND tbgen_batch_controle.dtmvtolt = pr_dtmvtolt);

    -- Busca do arquivo para controle de informaçõs da central de risco
    CURSOR cr_crapris IS
      SELECT ris.nrdconta
              ,DECODE(ass.inpessoa,3,2,ass.inpessoa) inpessoa /* Tratamento para Pessoa Administrativa considerar com PJ*/
            ,ris.nrcpfcgc
            ,ris.dtrefere
            ,ris.innivris
            ,ris.nrctremp
            ,ris.cdorigem
            ,ris.qtdiaatr
            ,ris.cdmodali
            ,ris.nrseqctr
            ,ris.vldivida
            ,ris.vljura60
            ,ris.qtdriclq
            ,ass.cdagenci
            ,ass.nmprimtl
            ,ris.dsinfaux
            ,ris.dtinictr
            ,ass.inprejuz
            ,ris.vljurantpp -- P577
            ,ris.vljurmorpp -- PRJ577
            ,ris.vljurmulpp -- PRJ577
        FROM crapass ass
            ,stage.stg_crapris@bidw_temp ris
         WHERE ris.cdcooper  = ass.cdcooper
           AND ris.nrdconta  = ass.nrdconta
           AND ris.cdcooper  = pr_cdcooper
           AND ris.dtrefere  = pr_dtrefere
           AND ris.inddocto  = 1 -- Docto 3020
         AND ris.vldivida > 0
         -- P450 - Alterado agencia do decode de alias= ris para alias= ass
         AND ass.cdagenci = decode(pr_cdagenci, 0, ass.cdagenci, pr_cdagenci); -- Ligeirinho.

    -- Busca de registro de transferência entre cooperativas
    CURSOR cr_craptco_via_alto IS
      SELECT tco.nrdconta
        FROM craptco tco
       WHERE tco.cdcooper = pr_cdcooper
         AND tco.cdagenci = decode(pr_cdagenci, 0, tco.cdagenci, pr_cdagenci) -- Ligeirinho.
         AND tco.cdcopant = 1
         AND tco.tpctatrf <> 3;

    CURSOR cr_craptco_acredi_via IS
      SELECT tco.nrdconta
        FROM craptco tco
       WHERE tco.cdcooper = pr_cdcooper
         AND tco.cdcopant = 2
         AND tco.tpctatrf <> 3
         AND tco.cdageant IN (2, 4, 6, 7, 11)
         AND tco.cdagenci = decode(pr_cdagenci, 0, tco.cdagenci, pr_cdagenci); -- Ligeirinho.

    CURSOR cr_craptco_concredi_via IS
      SELECT tco.nrdconta
        FROM craptco tco
       WHERE tco.cdcooper = pr_cdcooper
         AND tco.cdcopant = 4
         AND tco.tpctatrf <> 3
         AND tco.cdagenci = decode(pr_cdagenci, 0, tco.cdagenci, pr_cdagenci); -- Ligeirinho.

    CURSOR cr_craptco_credimilsul_civia IS /*Alteração scrcred civia - Paulo Martins - Mouts*/
      SELECT tco.nrdconta
        FROM craptco tco
       WHERE tco.cdcooper = pr_cdcooper
         AND tco.cdcopant = 15
         AND tco.tpctatrf <> 3
         AND tco.cdagenci =  decode(pr_cdagenci, 0, tco.cdagenci, pr_cdagenci); -- Ligeirinho.

    -- Busca dos limites não utilizados
    CURSOR cr_ris_liminutz IS
        SELECT ris.nrdconta
              ,ris.vldivida
              ,ris.inpessoa
        FROM stage.stg_crapris@bidw_temp ris
         WHERE ris.cdcooper  = pr_cdcooper
         AND ris.dtrefere >= pr_dtrefere
         AND ris.inddocto = 3 -- Docto 3020 (Limite Não Utilizado
         AND ris.cdagenci = decode(pr_cdagenci, 0, ris.cdagenci, pr_cdagenci); -- Ligeirinho.

    -- Buscar detalhes dos empréstimos
      CURSOR cr_crapepr(pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.qtmesdec
              ,epr.dtdpagto
              ,epr.qtprecal
              ,epr.vlsdeved
              ,epr.qtpreemp
              ,epr.vlpreemp
              ,epr.cdlcremp
              ,epr.tpemprst
              ,epr.flgpagto
              ,epr.qtlcalat
              ,epr.qtpcalat
              ,epr.txmensal
              ,epr.vlsdevat
              ,epr.inliquid
              ,epr.txjuremp
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.vlpapgat
              ,epr.qtmdecat
              ,epr.inprejuz
              ,epr.cdfinemp
              ,epr.dtmvtolt
              ,epr.vlemprst
              ,epr.tpdescto
              ,epr.vlppagat
              ,epr.vljurmes
              ,epr.cdagenci -- Ligeirinho.
            ,
             (SELECT ces.dtvencto
                FROM tbcrd_cessao_credito ces
               WHERE ces.cdcooper = epr.cdcooper
                 AND ces.nrdconta = epr.nrdconta
                   AND ces.nrctremp = epr.nrctremp ) dtvencto_original
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;

    -- Buscar detalhes do emprestimo BNDES
      CURSOR cr_crapebn (pr_nrdconta IN crapebn.nrdconta%TYPE
                        ,pr_nrctremp IN crapebn.nrdconta%TYPE) IS
      SELECT ebn.vlparepr
        FROM crapebn ebn
       WHERE ebn.cdcooper = pr_cdcooper
         AND ebn.nrdconta = pr_nrdconta
         AND ebn.nrctremp = pr_nrctremp;

    -- AWAE: Buscar dados dos Títulos de Borderô Vencidos.
    CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%TYPE
                      ,pr_nrdconta IN craptdb.nrdconta%TYPE
                      ,pr_nrctremp IN craptdb.nrborder%TYPE
                      --,pr_dtinictr IN crapris.dtinictr%TYPE
                      ,pr_dtrefere IN DATE) IS
    SELECT tdb.nrdconta
          ,tdb.dtvencto
          ,tdb.nrseqdig
          ,tdb.cdoperad
          ,tdb.nrdocmto
          ,tdb.nrctrlim
          ,tdb.nrborder
          ,tdb.vlliquid
          ,tdb.dtlibbdt
          ,tdb.cdcooper
          ,tdb.cdbandoc
          ,tdb.nrdctabb
          ,tdb.nrcnvcob
          ,tdb.cdoperes
          ,tdb.dtresgat
          ,tdb.vlliqres
          ,tdb.vltitulo
          ,tdb.insittit
          ,tdb.nrinssac
          ,COALESCE(tdb.dtdpagto,tdb.dtdebito) as dtdpagto
          ,tdb.dtdebito
          ,tdb.dtrefatu
          ,tdb.insitapr
          ,tdb.cdoriapr
          ,tdb.flgenvmc
          ,tdb.insitmch
          ,tdb.vlsldtit
          ,tdb.nrtitulo
          ,tdb.vliofprc
          ,tdb.vliofadc
          ,tdb.vliofcpl
          ,tdb.vlmtatit
          ,tdb.vlmratit
          ,tdb.vljura60
          ,tdb.vlpagiof
          ,tdb.vlpagmta
          ,tdb.vlpagmra
          ,(tdb.vlsldtit + (tdb.vlmtatit - tdb.vlpagmta) + (tdb.vlmratit - tdb.vlpagmra) + (tdb.vliofcpl - tdb.vlpagiof)) as vlatraso
          ,(tdb.vlsldtit + (tdb.vlmtatit - tdb.vlpagmta) + (tdb.vlmratit - tdb.vlpagmra) + (tdb.vliofcpl - tdb.vlpagiof)) as vlsaldodev
          ,NVL(pr_dtrefere - tdb.dtvencto,0) as qtdiaatr
          ,TRUNC(MONTHS_BETWEEN(pr_dtrefere, tdb.dtvencto)) as qtmesdec
          ,CASE
             WHEN tdb.insittit = 4 THEN 0
             ELSE 1
           END as qtprepag 
          ,(tdb.vltitulo - tdb.vlsldtit) + tdb.vlpagmta + tdb.vlpagmra + tdb.vlpagiof AS vlprepag  
          ,ldc.cddlinha
          ,ldc.dsdlinha
          ,bdt.txmensal
          ,ROUND(bdt.txmensal/30,7) as txdiaria
          -- Campos prejuizo
          ,bdt.inprejuz
          ,bdt.dtprejuz
          ,tdb.vlsdprej
      FROM craptdb tdb
     INNER JOIN crapbdt bdt
        ON tdb.cdcooper = bdt.cdcooper
       AND tdb.nrdconta = bdt.nrdconta
       AND tdb.nrborder = bdt.nrborder
     INNER JOIN craplim lim
        ON lim.cdcooper = bdt.cdcooper
       AND lim.nrdconta = bdt.nrdconta
       AND lim.nrctrlim = bdt.nrctrlim
       AND lim.tpctrlim = 3 -- desconto de títulos
     INNER JOIN crapldc ldc
        ON lim.cdcooper = ldc.cdcooper
       AND lim.cddlinha = ldc.cddlinha
     WHERE tdb.cdcooper = pr_cdcooper
       AND tdb.nrdconta = pr_nrdconta
       AND tdb.nrborder = pr_nrctremp -- nrctrem da crapris
       AND tdb.insittit = 4 -- títulos em aberto 
       AND tdb.dtvencto <= pr_dtrefere
       AND ldc.tpdescto = 3 -- desconto de título
       AND bdt.flverbor = 1; -- considerar somente os títulos vencidos de borderôs novos
    rw_craptdb cr_craptdb%ROWTYPE;

    -- Buscar detalhes do saldo da conta
    CURSOR cr_crapsld(pr_nrdconta IN crapsld.nrdconta%TYPE) IS
      SELECT sld.qtdriclq
           , sld.vliofmes
        FROM STAGE.STG_CRAPSLD_HISTORICO@bidw_temp sld
       WHERE sld.cdcooper = pr_cdcooper
         AND sld.nrdconta = pr_nrdconta
         AND sld.dtrefere = pr_rw_crapdat.dtmvtolt;
    rw_crapsld cr_crapsld%ROWTYPE;

    -- Buscar nome da agência
    CURSOR cr_crapage(pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT nmresage
        FROM crapage
       WHERE cdcooper = pr_cdcooper
         AND cdagenci = pr_cdagenci;
    vr_nmresage crapage.nmresage%TYPE;

    -- Testar a existência de risco na data passada, tipo e dcmto passado
      CURSOR cr_crapris_tst(pr_nrdconta IN crapris.nrdconta%TYPE
                           ,pr_innivris IN crapris.innivris%TYPE
                           ,pr_dtini IN crapris.dtrefere%TYPE
                           ,pr_dtfim IN crapris.dtrefere%TYPE
                           ,pr_inddocto IN crapris.inddocto%TYPE) IS

      SELECT COUNT(DISTINCT ris.dtrefere) AS exis_crapris
        FROM stage.stg_crapris@bidw_temp ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.innivris = pr_innivris
         AND ris.dtrefere BETWEEN pr_dtini AND pr_dtfim
         AND ris.inddocto = pr_inddocto;

    vr_exis_crapris NUMBER;


    CURSOR cr_crapvri(pr_dtrefere IN crapris.dtrefere%TYPE) IS
      SELECT nrdconta
            ,innivris
            ,cdmodali        
            ,nrctremp        
            ,nrseqctr        
            ,SUM(DECODE(greatest(cdvencto,110),cdvencto,DECODE(LEAST(cdvencto,290),cdvencto, vldivida,0),0)) vldivida
            ,SUM(DECODE(greatest(cdvencto,205),cdvencto,DECODE(LEAST(cdvencto,290),cdvencto, vldivida,0),0)) vltotatr
            ,COUNT(DISTINCT DECODE(greatest(cdvencto,205),cdvencto,DECODE(LEAST(cdvencto,290),cdvencto, 1,NULL),NULL)) qtpreatr
            ,SUM(DECODE(cdvencto, 310, vldivida, 320, vldivida, 330, vldivida, 0) ) vlprejuz
        FROM stage.stg_crapvri@bidw_temp
       WHERE cdcooper = pr_cdcooper
         AND dtrefere = pr_dtrefere
    GROUP BY nrdconta,innivris,cdmodali,nrctremp,nrseqctr;

    TYPE typ_crapvri IS TABLE OF cr_crapvri%ROWTYPE                            index by PLS_INTEGER;
    vr_tab_crapvri typ_crapvri;

    
    --Type para armazenar as os associados
    type typ_reg_crapvri is record (vldivida crapvri.vldivida%TYPE,
      vltotatr crapvri.vldivida%TYPE,
      qtpreatr crapass.qtfoltal%TYPE,
      vlprejuz crapvri.vldivida%TYPE);

    type typ_tab_reg_crapvri is table of typ_reg_crapvri index by VARCHAR2(240);
    vr_tab_crapvri_index typ_tab_reg_crapvri;


    -- Testar a existência de Rating efetivo
    CURSOR cr_crapnrc(pr_nrdconta IN crapnrc.nrdconta%TYPE) IS
      SELECT 1
        FROM crapnrc
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND insitrat = 2;

    -- Testar a existência de Rating por contrato
      CURSOR cr_contrato_nrc(pr_nrdconta IN crapnrc.nrdconta%TYPE
                            ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE
                            ,pr_tpctrrat IN crapnrc.nrctrrat%TYPE) IS
      SELECT indrisco
        FROM crapnrc
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrrat = pr_nrctrrat
         AND tpctrrat = pr_tpctrrat;

    -- Buscar nível de risco do empréstimo
      CURSOR cr_crawepr(pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT dsnivris,
               rowid
        FROM crawepr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;

    -- Buscar quantidade de meses através dos registros na crapris
      CURSOR cr_crapris_count(pr_nrdconta IN crapris.nrdconta%TYPE
                             ,pr_nrctremp IN crapris.nrctremp%TYPE
                             ,pr_cdorigem IN crapris.cdorigem%TYPE) IS
      SELECT COUNT(1)
        FROM stage.stg_crapris@bidw_temp ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.nrctremp = pr_nrctremp
           AND ris.cdorigem  = pr_cdorigem
         AND ris.dtrefere >= pr_dtrefere - 190;
    vr_qtd_crapris NUMBER;

    -- Testar a existência de risco na data passada, origem, modalidade e docto
      CURSOR cr_crapris_est(pr_nrdconta IN crapris.nrdconta%TYPE
                           ,pr_cdorigem IN crapris.cdorigem%TYPE
                           ,pr_cdmodali IN crapris.cdmodali%TYPE
                           ,pr_dtrefere IN crapris.dtrefere%TYPE
                           ,pr_inddocto IN crapris.inddocto%TYPE) IS
      SELECT 1
        FROM stage.stg_crapris@bidw_temp ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.cdmodali = pr_cdmodali
         AND ris.cdorigem = pr_cdorigem
         AND ris.dtrefere = pr_dtrefere
         AND ris.inddocto = pr_inddocto;
    vr_flgexis_estouro NUMBER;

    -- Retornar ultimo lançamento de risco para a data e tipo de documento passado
      CURSOR cr_crapris_last(pr_nrdconta IN crapris.nrdconta%TYPE
                               ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
      SELECT /*+ INDEX (ris CRAPRIS##CRAPRIS1) */
              'S' ind_achou
              ,ris.innivris
              ,ris.dtdrisco
              ,ris.vldivida
        FROM stage.stg_crapris@bidw_temp ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.dtrefere = pr_dtrefere
         AND ris.inddocto = 1
       ORDER BY CDCOOPER DESC, NRDCONTA DESC, DTREFERE DESC, INNIVRIS DESC;

    rw_crapris_last cr_crapris_last%ROWTYPE;

    -- Verifica se a conta em questao pertence a algum grupo economico
    -- Alterado a tabela CRAPGRP para TBCC_GRUPO_ECONOMICO
    CURSOR cr_crapgrp IS
      SELECT *
        FROM (SELECT int.nrdconta, int.nrcpfcgc
                FROM tbcc_grupo_economico_integ INT
                    ,tbcc_grupo_economico p
               WHERE int.dtexclusao IS NULL
                 AND int.cdcooper = pr_cdcooper
                 AND int.idgrupo  = p.idgrupo
               UNION
              SELECT pai.nrdconta, ass.Nrcpfcgc
                FROM tbcc_grupo_economico       pai
                   , crapass                    ass
                   , tbcc_grupo_economico_integ int
               WHERE ass.cdcooper = pai.cdcooper
                 AND ass.nrdconta = pai.nrdconta
                 AND int.idgrupo  = pai.idgrupo
                 AND int.dtexclusao is null
                 AND int.cdcooper = pr_cdcooper
                 AND ass.cdcooper = pr_cdcooper
            ) dados;

    /* Cursor de Linha de Credito */
      CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%TYPE
                        ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT craplcr.cdlcremp
              ,craplcr.dsoperac
              ,craplcr.cdusolcr
              ,craplcr.dsorgrec              
        FROM craplcr
       WHERE craplcr.cdcooper = pr_cdcooper
        AND   craplcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;

      CURSOR cr_craplem(pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE) IS 
        SELECT lem.cdhistor
              ,NVL(SUM(lem.vllanmto),0) vllanmto
        FROM craplem lem
       WHERE lem.cdcooper = pr_cdcooper
         AND lem.nrdconta = pr_nrdconta
         AND lem.nrctremp = pr_nrctremp
           AND lem.dtmvtolt BETWEEN TRUNC(pr_rw_crapdat.dtmvtolt,'MM') AND pr_rw_crapdat.dtmvtolt
           AND lem.cdhistor in (91,95,441) --> Pagamentos / juros
       GROUP BY lem.cdhistor;

      CURSOR cr_craplim(pr_nrdconta IN craplim.nrdconta%TYPE
                       ,pr_nrctremp IN craplim.nrctrlim%TYPE) IS 
      SELECT count(*) existe_contrato_finame
        FROM craplim lim
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.nrctrlim = pr_nrctremp
           AND lim.tpctrlim = 1  --> Cheque especial
           AND lim.insitlim = 2  --> Ativo
         AND lim.cddlinha = 2; --> Linha BNDES Finame;
    rw_craplim cr_craplim%ROWTYPE;

    CURSOR cr_crapris_reccaixa IS
      SELECT cop.nmrescop,
               LTRIM(gene0002.fn_mask(epr.nrctremp,'zz.zzz.zz9')) nrctremp,
             ris.dtinictr,
             epr.vlemprst,
             epr.vlsdeved
          FROM stage.stg_crapris@bidw_temp ris
              ,crapepr epr
              ,crapcop cop
       WHERE ris.nrdconta = epr.nrdconta
         AND ris.nrctremp = epr.nrctremp
         AND ris.cdcooper = epr.cdcooper
         AND epr.nrdconta = cop.nrctactl
         AND ris.nrdconta = epr.nrdconta
         AND ris.nrctremp = epr.nrctremp
         and epr.vlsdeved > 0
         AND epr.cdfinemp = 1
         AND ris.cdorigem = 3
         AND ris.dtrefere = pr_dtrefere
         AND ris.cdcooper = pr_cdcooper
        ORDER BY cop.nmrescop,
                 epr.nrctremp;

    -- Variaveis para o retorno da pc_obtem_dados_empresti
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;

    -- Variaveis auxiliares
      vr_contador  INTEGER;     -- Contador para a tabela de riscos

    --  Variaveis para o calculo de empréstimo
      vr_qtmesdec       NUMBER;       --> Quantidade decimal de meses decorrentes
      vr_qtprecal_decim NUMBER;       --> Quantidade para calculo de parcelas em atraso (em decimal)
      vr_qtprecal_intei INTEGER;      --> Quantidade para calculo de parcelas em atraso
      vr_vlsdeved_atual crapepr.vlsdeved%type; --> Saldo devedor pra calculo atual
      vr_inusatab       BOOLEAN;      --> Indicador S/N de utilização de tabela de juros

      vr_fleprces       INTEGER;      --> Indicador se emprestimo de Cessao.

    -- Variaveis temporárias para gravação da tabela crapris somente após processar
    vr_vlpreemp crapepr.vlpreemp%TYPE;
    vr_cdlcremp VARCHAR2(10);
    vr_nroprest NUMBER;
    vr_qtatraso NUMBER;
    vr_qtdiaatr PLS_INTEGER;
    vr_cdfinemp crapepr.cdlcremp%TYPE;

    -- Variaveis para o retorno da configuração tab30
      vr_vlarrast NUMBER;  -- Limite (valor de arrasto)
      vr_vlsalmin NUMBER;  -- Salário mínimo
    vr_diasatrs INTEGER; -- Dias de atraso
    vr_atrsinad INTEGER; -- Dias de atraso para inadimplencia

    -- Variaveis para os XMLs
    --> crrl227
    vr_clobxml_227 CLOB;
    vr_txtauxi_227 VARCHAR2(32767);
    --> crrl354
    vr_clobxml_354 CLOB;
    vr_txtauxi_354 VARCHAR2(32767);
    --> crrl581
    vr_clobxml_581 CLOB;
    vr_txtauxi_581 VARCHAR2(32767);

    --> Descrição genérica para reaproveitamento de código
    vr_des_xml_gene VARCHAR2(32767);

    -- Variáveis auxiliares para o relatório 5 - crrl581.lst
    vr_ddatraso INTEGER;
    vr_contdata INTEGER;
    vr_flgrisco BOOLEAN;
    vr_dsorigem VARCHAR2(1);
    vr_dtfimmes DATE;

    vr_dtmesant DATE;
    vr_dt6meses DATE;
		-- PRJ Microcredito
		vr_vljur60       NUMBER(15,2) := 0;--> Totalizador juros 60
    -- Variáveis genéricas para vários relatórios
      vr_vldivida       NUMBER(15,2);--> Totalizador de dívida
      vr_vljuro60_desconto NUMBER(15,2);--> Totalizador auxiliar Juro60
      vr_vldivjur       NUMBER(15,2);--> Totalizador de dívida quando PJ
      vr_vlpreatr       NUMBER;      --> Valor perstação em atraso
    vr_vlprejuz       NUMBER := 0; --> Total geral de prejuízo
      vr_vlprejuz_conta NUMBER;      --> Total de prejuízo na conta
    vr_qtpreatr       PLS_INTEGER; --> Indicador de atraso
      vr_vltotatr       NUMBER;      --> Totalizador de atrasos
      vr_vlpercen       NUMBER;      --> Valor auxiliar para calcular o atraso
    vr_nivrisco       VARCHAR2(2); --> Auxiliar para nível do risco
      vr_dtdrisco       DATE;        --> Data do risco ant
      vr_qtdiaris       INTEGER;     --> Qtd dias do risco
    vr_dsnivris       VARCHAR2(2); --> Nivel do risco atual
    vr_pertenge       VARCHAR2(1); --> Indicador de grupo empresarial
      vr_percentu       NUMBER(5,2); --> Percentual auxiliar
    vr_indrisco       crapnrc.indrisco%TYPE; -- Risco rating
      vr_vlpreapg       NUMBER(20,10); --> Vl. prestacao paga.
      vr_cdorigem       NUMBER(1);   --> Origem do Cyber

      vr_tpemprst       VARCHAR2(10); -- Tipo de Contrato

    -- Flags para indicar que as tags de agência já foram enviadas no XML
    vr_flgpac01 BOOLEAN;
    vr_flgpac02 BOOLEAN;

    -- Variáveis de totalização por PAC
      vr_tot_qtctremp INTEGER;     -- CONTRATOS EM ATRASO
      vr_tot_vlpreatr NUMBER;      -- DESPESA PROVISIONADA
      vr_tot_qtctrato INTEGER;     -- CONTRATOS EM DIA
      vr_tot_vldespes NUMBER;      -- DESPESA PROVISIONADA
      vr_tot_qtempres INTEGER;     -- TOTAIS DA CARTEIRA
      vr_tot_vlsdeved NUMBER;      -- SALDO DEVEDOR DA CARTEIRA
      vr_med_percentu NUMBER;      -- MÿDIA % TAXA
      vr_tot_vlsdvatr NUMBER;      -- SALDO DEVEDOR EM ATRASO
      vr_tot_vlatraso NUMBER;      -- VALOR EM ATRASO
      vr_percbase     NUMBER(5,2); -- %BASE
      vr_tot_qtdopera INTEGER;     -- TOTAL QTDE
      vr_tot_qtdopfis INTEGER;     -- TOTAL QTDE POR PF
      vr_tot_qtdopjur INTEGER;     -- TOTAL QTDE POR PJ
      vr_tot_vlropera NUMBER(18,2);      -- TOTAL SALDO DEVEDOR
      vr_tot_vlropfis NUMBER(18,2);      -- TOTAL SALDO DEVEDOR POR PF
      vr_tot_vlropjur NUMBER(18,2);      -- TOTAL SALDO DEVEDOR POR PJ

      vr_tot_qtatrasa INTEGER;     -- QTDE ATRASO MAIOR INADIMPLENCIA
      vr_tot_qtatrfis INTEGER;     -- QTDE ATRASO MAIOR INADIMPLENCIA POR PF
      vr_tot_qtatrjur INTEGER;     -- QTDE ATRASO MAIOR INADIMPLENCIA POR PJ
      vr_tot_vlatrasa NUMBER;      -- VALOR ATRASO MAIOR INADIMPLENCIA
      vr_tot_vlatrfis NUMBER;      -- VALOR ATRASO MAIOR INADIMPLENCIA POR PF
      vr_tot_vlatrjur NUMBER;      -- VALOR ATRASO MAIOR INADIMPLENCIA POR PJ
      vr_med_atrsinad NUMBER;      -- % INADIMPLENCIA
      vr_med_atindfis NUMBER;      -- % INADIMPLENCIA POR PF
      vr_med_atindjur NUMBER;      -- % INADIMPLENCIA POR PJ

    -- Variáveis para totalização geral
    vr_tot_qtctremp_geral INTEGER := 0; -- CONTRATOS EM ATRASO
      vr_tot_vlpreatr_geral NUMBER  := 0; -- DESPESA PROVISIONADA
    vr_tot_qtctrato_geral INTEGER := 0; -- CONTRATOS EM DIA
      vr_tot_vldespes_geral NUMBER  := 0; -- DESPESA PROVISIONADA
      vr_tot_vlatraso_geral NUMBER  := 0; -- VALOR EM ATRASO
      vr_tot_vlsdeved_geral NUMBER  := 0; -- SALDO DEVEDOR
    vr_tot_qtempres_geral INTEGER := 0; -- QUANTIDADE DE EMPREST
    vr_tot_qtdopera_geral INTEGER := 0; -- TOTAL QTDE
    vr_tot_qtdopfis_geral INTEGER := 0; -- TOTAL QTDE POR PF
    vr_tot_qtdopjur_geral INTEGER := 0; -- TOTAL QTDE POR PJ
      vr_tot_vlropera_geral NUMBER  := 0; -- TOTAL SALDO DEVEDOR
      vr_tot_vlropfis_geral NUMBER  := 0; -- TOTAL SALDO DEVEDOR
      vr_tot_vlropjur_geral NUMBER  := 0; -- TOTAL SALDO DEVEDOR
    vr_tot_qtatrasa_geral INTEGER := 0; -- QTDE ATRASO MAIOR INADIMPLENCIA
    vr_tot_qtatrfis_geral INTEGER := 0; -- QTDE ATRASO MAIOR INADIMPLENCIA POR PF
    vr_tot_qtatrjur_geral INTEGER := 0; -- QTDE ATRASO MAIOR INADIMPLENCIA POR PJ
      vr_tot_vlatrasa_geral NUMBER  := 0; -- VALOR ATRASO MAIOR INADIMPLENCIA
      vr_tot_vlatrfis_geral NUMBER  := 0; -- VALOR ATRASO MAIOR INADIMPLENCIA POR PJ
      vr_tot_vlatrjur_geral NUMBER  := 0; -- VALOR ATRASO MAIOR INADIMPLENCIA POR PJ
      vr_med_atrsinad_geral NUMBER  := 0; -- % INADIMPLENCIA
      vr_med_atindfis_geral NUMBER  := 0; -- % INADIMPLENCIA POR PJ
      vr_med_atindjur_geral NUMBER  := 0; -- % INADIMPLENCIA POR PJ

    -- Variáveis para a escrita no arquivo crrl354.txt
      vr_clob_354     CLOB;               --> Clob para conter o dados do txt
      vr_txtarqui_354  VARCHAR2(32767);    --> Texto auxiliar para evitar gravação excessiva no CLOB
      vr_nmdireto_354 VARCHAR2(200);      --> Diretório específico para o mesmo
      vr_nmarquiv_354 VARCHAR2(20);       --> Nome do arquivo 354
    vr_dssepcol_354 VARCHAR2(1) := ';'; --> Caracter separador dentro do arquivo 354
      vr_cdlcremp_354 VARCHAR2(10);        --> Linha de crédito auxiliar
      vr_dspathcp_354 VARCHAR2(4000);     --> Path para cópia do arquivo exportado

    -- Variaveis para cópia e envio de e-mail dos relatórios
    vr_dspathcopia VARCHAR2(4000);
    vr_dsmailcopia VARCHAR2(4000);
    vr_dsassunmail VARCHAR2(300);

    -- Variável para o caminho dos arquivos no rl
      vr_nom_direto  VARCHAR2(200);
      vr_indice      VARCHAR2(100);

    -- Variaveis para o Cyber
      vr_txmensal    NUMBER(10,6);
      vr_dstextab    VARCHAR2(100);
      vr_flgrpeco    NUMBER(1);
      vr_flgresid    NUMBER(1);
      vr_txmenemp    crapepr.txmensal%TYPE;
      vr_txdjuros    craplcr.txdiaria%TYPE;
      
      -- P577 - Inicio
      vr_tot_vljurantpp    NUMBER := 0;
      vr_vltotjur60        NUMBER := 0;
      vr_vltotjurant60     NUMBER := 0;
      vr_tot_vltotjurant60 NUMBER := 0;
      vr_tot_vltotjur60    NUMBER := 0;
      -- P577 - Fim
      
    vr_tab_diapagto NUMBER;
    vr_tab_dtcalcul DATE;
    -- Flag para desconto em folha
    vr_tab_flgfolha BOOLEAN;
    -- Configuração para mês novo
    vr_tab_ddmesnov INTEGER;
    vr_flgconsg     INTEGER;

    --microcredito
    vr_chave_microcredito craplcr.dsorgrec%TYPE;
    vr_cdusolcr           craplcr.cdusolcr%TYPE;
    vr_dsorgrec           craplcr.dsorgrec%TYPE;

    --finame
    vr_tot_libctnfiname   NUMBER := 0;
    vr_tot_prvperdafiname NUMBER := 0;

    --controle de arquivo
      vr_dtmvtolt_yymmdd    VARCHAR2(6);
      vr_nom_diretorio      VARCHAR2(200); 
      vr_nom_dir_copia      VARCHAR2(200);

    -- P307 Calculo de Compensação de Microcrédito
    vr_tot_vltttlcr_dim        NUMBER := 0;
    vr_tot_vltttlcr_dim_outros NUMBER := 0;
		-- PRJ Microcredito
    vr_totatraso90_dim         NUMBER := 0;
    vr_totatraso90_dim_outros  NUMBER := 0;
    -- Juros + 60 até e acima de 90 dias
    vr_tot_vlj60at90d_dim          NUMBER := 0;
    vr_tot_vlj60ac90d_dim          NUMBER := 0;
    vr_tot_vlj60at90d_dim_outros          NUMBER := 0;
    vr_tot_vlj60ac90d_dim_outros          NUMBER := 0;

    -- Retorna linha cabeçalho arquivo Radar ou Matera
    FUNCTION fn_set_cabecalho(pr_inilinha IN VARCHAR2
                             ,pr_dtarqmv  IN DATE
                             ,pr_dtarqui  IN DATE
                               ,pr_origem   IN NUMBER      --> Conta Origem
                               ,pr_destino  IN NUMBER      --> Conta Destino
                               ,pr_vltotal  IN NUMBER      --> Soma total de todas as agencias
                               ,pr_dsconta  IN VARCHAR2)   --> Descricao da conta
     RETURN VARCHAR2 IS
    BEGIN
      RETURN pr_inilinha --> Identificacao inicial da linha
              ||TO_CHAR(pr_dtarqmv,'YYMMDD')||',' --> Data AAMMDD do Arquivo
              ||TO_CHAR(pr_dtarqui,'DDMMYY')||',' --> Data DDMMAA
              ||pr_origem||','                    --> Conta Origem
              ||pr_destino||','                   --> Conta Destino
              ||TRIM(TO_CHAR(pr_vltotal,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','
              ||'5210'||','
              ||pr_dsconta;
    END fn_set_cabecalho;

    -- Retorna linha gerencial arquivo Radar ou Matera
      FUNCTION fn_set_gerencial(pr_cdagenci in number
                               ,pr_vlagenci in number)  
      RETURN VARCHAR2 IS
    BEGIN
         RETURN lpad(pr_cdagenci,3,0)||',' 
              ||TRIM(TO_CHAR(pr_vlagenci,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
    END fn_set_gerencial;

    -- SobRotina que cria registros contab no arquivo texto
      PROCEDURE pc_cria_node_contab(pr_des_xml    IN OUT VARCHAR2
                                   ,pr_des_contab IN VARCHAR2
                                   ,pr_num_valor1 IN NUMBER
                                   ,pr_num_valor2 IN NUMBER
                                   ,pr_num_vlpvpf IN NUMBER
                                   ,pr_num_vlprpj IN NUMBER
                                   ,pr_num_vldvpf IN NUMBER
                                   ,pr_num_vldvpj IN NUMBER
                                   ,pr_flcessao   IN INTEGER DEFAULT 0
                                   ) IS
    BEGIN
      -- Escreve no XML abrindo e fechando a tag de contab
         pr_des_xml := pr_des_xml
                      ||'<contab>'
                      ||'  <idcessao>'||pr_flcessao  ||'</idcessao> '
                      ||'  <dscontab>'||pr_des_contab||'</dscontab>'
                      ||'  <vlprovis>'||to_char(pr_num_valor1,'fm999g999g999g990d00')||'</vlprovis>'
                      ||'  <vldivida>'||to_char(pr_num_valor2,'fm999g999g999g990d00')||'</vldivida>'
                      ||'  <vlprvfis>'||to_char(pr_num_vlpvpf,'fm999g999g999g990d00')||'</vlprvfis>'
                      ||'  <vlprvjur>'||to_char(pr_num_vlprpj,'fm999g999g999g990d00')||'</vlprvjur>'
                      ||'  <vldivfis>'||to_char(pr_num_vldvpf,'fm999g999g999g990d00')||'</vldivfis>'
                      ||'  <vldivjur>'||to_char(pr_num_vldvpj,'fm999g999g999g990d00')||'</vldivjur>'
                      ||'</contab>';
    END;

    -- SobRotina que cria registros microcredito no arquivo texto
      PROCEDURE pc_cria_node_miccre(pr_des_xml          IN OUT VARCHAR2
                                   ,pr_idgrumic         IN NUMBER
                                   ,pr_ds_microcredito  IN VARCHAR2
                                   ,pr_vlreprec         IN NUMBER
                                   ,pr_vlempatr         IN NUMBER
                                   ,pr_vlreprec_pf      IN NUMBER
                                   ,pr_vlreprec_pj      IN NUMBER
																	 -- PRJ Microcredito
                                   ,pr_vlate90d         IN NUMBER
                                   ,pr_vlaci90d         IN NUMBER
                                   ,pr_vlj60at90d         IN NUMBER
                                   ,pr_vlj60ac90d       IN NUMBER
																	 ) IS
    BEGIN
      -- Escreve no XML abrindo e fechando a tag de microcredito
         pr_des_xml := pr_des_xml
                      ||'<microcredito>'
                      ||'  <idgrumic>'||pr_idgrumic||'</idgrumic>'
                      ||'  <dsorgrec>'||pr_ds_microcredito||'</dsorgrec>'
                      ||'  <vlreprec>'||to_char(pr_vlreprec,'fm999g999g999g990d00')||'</vlreprec>'
                      ||'  <vlempatr>'||to_char(pr_vlempatr,'fm999g999g999g990d00')||'</vlempatr>'                       
                      ||'  <vlrepfis>'||to_char(pr_vlreprec_pf,'fm999g999g999g990d00')||'</vlrepfis>'
                      ||'  <vlrepjur>'||to_char(pr_vlreprec_pj,'fm999g999g999g990d00')||'</vlrepjur>'
											-- PRJ Microcredito
                      ||'  <vlaci90d>'||to_char(pr_vlaci90d,'fm999g999g999g990d00')||'</vlaci90d>'                      
                      ||'  <vlate90d>'||to_char(pr_vlate90d,'fm999g999g999g990d00')||'</vlate90d>'
                      ||'  <vlj60at90d>'||to_char(pr_vlj60at90d,'fm999g999g999g990d00')||'</vlj60at90d>'
                      ||'  <vlj60ac90d>'||to_char(pr_vlj60ac90d,'fm999g999g999g990d00')||'</vlj60ac90d>'
                      ||'</microcredito>';

    END pc_cria_node_miccre;

      
    -- Inicializa Pl-Table
    PROCEDURE pc_inicializa_pltable IS
    BEGIN
         FOR idx IN 1..3 LOOP
        -- Inicializa Todas as Informacoes da Coluna Provisao
        vr_tab_contab(vr_vlfinanc_pf)(vr_provis)(idx).vlfinanc_pf := 0;
        vr_tab_contab(vr_vlfinanc_pj)(vr_provis)(idx).vlfinanc_pj := 0;
        vr_tab_contab(vr_vlempres_pf)(vr_provis)(idx).vlempres_pf := 0;
        vr_tab_contab(vr_vlempres_pj)(vr_provis)(idx).vlempres_pj := 0;
        vr_tab_contab(vr_vlchqdes)(vr_provis)(idx).vlchqdes := 0;
        vr_tab_contab(vr_vltitdes_cr)(vr_provis)(idx).vltitdes_cr := 0;
        vr_tab_contab(vr_vltitdes_sr)(vr_provis)(idx).vltitdes_sr := 0;
        vr_tab_contab(vr_vladtdep)(vr_provis)(idx).vladtdep := 0;
        vr_tab_contab(vr_vlchqesp)(vr_provis)(idx).vlchqesp := 0;

        -- Inicializa Todas as Informacoes da Coluna Divida
        vr_tab_contab(vr_vlfinanc_pf)(vr_divida)(idx).vlfinanc_pf := 0;
        vr_tab_contab(vr_vlfinanc_pj)(vr_divida)(idx).vlfinanc_pj := 0;
        vr_tab_contab(vr_vlempres_pf)(vr_divida)(idx).vlempres_pf := 0;
        vr_tab_contab(vr_vlempres_pj)(vr_divida)(idx).vlempres_pj := 0;
        vr_tab_contab(vr_vlchqdes)(vr_divida)(idx).vlchqdes := 0;
        vr_tab_contab(vr_vltitdes_cr)(vr_divida)(idx).vltitdes_cr := 0;
        vr_tab_contab(vr_vltitdes_sr)(vr_divida)(idx).vltitdes_sr := 0;
        vr_tab_contab(vr_vladtdep)(vr_divida)(idx).vladtdep := 0;
        vr_tab_contab(vr_vlchqesp)(vr_divida)(idx).vlchqesp := 0;
      END LOOP;
      vr_tab_contab_cessao(vr_vleprces)(vr_provis)(1).vlempres_pf := 0;
      vr_tab_contab_cessao(vr_vleprces)(vr_provis)(2).vlempres_pj := 0;
      vr_tab_contab_cessao(vr_vleprces)(vr_divida)(1).vlempres_pf := 0;
      vr_tab_contab_cessao(vr_vleprces)(vr_divida)(2).vlempres_pj := 0;
    END;

    PROCEDURE pc_gera_arq_compe_mic(pr_dscritic OUT VARCHAR2) IS

      vr_txt_compmicro VARCHAR2(500);
         vr_nmarquiv   VARCHAR2(200);
         vr_dscritic   VARCHAR2(4000);
         vr_input_file UTL_FILE.file_type;  
         vr_typ_said         VARCHAR2(4);

    BEGIN
        -- PRJ Microcredito
        IF  (nvl(vr_tot_vltttlcr_dim,0) + 
                   nvl(vr_tot_vltttlcr_dim_outros,0) +       
                   nvl(vr_totatraso90_dim,0) + 
             nvl(vr_totatraso90_dim_outros,0)    +
             nvl(vr_tot_vlj60at90d_dim,0)        +
             nvl(vr_tot_vlj60ac90d_dim,0)        +
             nvl(vr_tot_vlj60at90d_dim_outros,0) +
             nvl(vr_tot_vlj60ac90d_dim_outros,0)  
             ) > 0 THEN

        -- Nome do arquivo a ser gerado
          vr_nmarquiv := vr_dtmvtolt_yymmdd||'_'||lpad(pr_cdcooper,2,0)||'_MICROCREDITO_COMPENSACAO.txt';

        -- Tenta abrir o arquivo de log em modo gravacao
          gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                  ,pr_nmarquiv => vr_nmarquiv          --> Nome do arquivo
                                  ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_dscritic);        --> Erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        --Linhas PNMPO DIM E CAIXA
        -- 1ª linha
				-- PRJ Microcredito
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,'3965'
                                              ,'9264'
                                              ,vr_tot_vltttlcr_dim_outros
                                              ,'"SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA ⿿ VENCIDOS ATE 90 DIAS"');

          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);

                            
        -- 2ª linha
				-- PRJ Microcredito
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,'3968'
                                              ,'9264'
                                              ,vr_totatraso90_dim_outros
                                              ,'"SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA ⿿ VENCIDOS A MAIS DE 90 DIAS"');

          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);

                                         
        -- 3ª linha
				-- PRJ Microcredito
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,'9264'
                                              ,'3965'
                                              ,vr_tot_vltttlcr_dim_outros
                                              ,'"REVERSAO DO SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA ⿿ VENCIDOS ATE 90 DIAS"');

          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);

                            
        -- 4ª linha
				-- PRJ Microcredito
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,'9264'
                                              ,'3968'
                                              ,vr_totatraso90_dim_outros
                                              ,'"REVERSAO DO SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA ⿿ VENCIDOS A MAIS DE 90 DIAS"');

          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);

                                                  
          -- 1ª linha RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA
          -- PRJ Microcredito Juro +60 acima 90 dias
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,'9264'
                                              ,'3965'
                                              ,vr_tot_vlj60at90d_dim_outros
                                              ,'"JUROS 60 SOBRE SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA ⿿ VENCIDOS ATE 90 DIAS"');

          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);
                                        
          -- 2ª linha RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA
          -- PRJ Microcredito Juro +60 acima 90 dias
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,'9264'
                                              ,'3968'
                                              ,vr_tot_vlj60ac90d_dim_outros
                                              ,'"JUROS 60 SOBRE SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA ⿿ VENCIDOS A MAIS DE 90 DIAS"');

          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);

          -- 3ª linha RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA
          -- PRJ Microcredito Juro +60 acima 90 dias
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,'3965'
                                              ,'9264'
                                              ,vr_tot_vlj60at90d_dim_outros
                                              ,'"REVERSAO JUROS 60 SOBRE SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA ⿿ VENCIDOS ATE 90 DIAS"');

          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);
                                        
          -- 4ª linha RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA
          -- PRJ Microcredito Juro +60 acima 90 dias
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,'3968'
                                              ,'9264'
                                              ,vr_tot_vlj60ac90d_dim_outros
                                              ,'"REVERSAO JUROS 60 SOBRE SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA ⿿ VENCIDOS A MAIS DE 90 DIAS"');

          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);
                                        
        -- Fechar Arquivo
        BEGIN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
             vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_diretorio||'/'||vr_nmarquiv||'>: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;

        -- Copia o arquivo gerado para o diretório final convertendo para DOS
          gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarquiv||' > '||vr_nom_dir_copia||'/'||vr_nmarquiv||' 2>/dev/null',
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
        -- Testar erro
        if vr_typ_said = 'ERR' then
             vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarquiv||': '||vr_dscritic;
          raise vr_exc_erro;
        end if;

      END IF;

    END pc_gera_arq_compe_mic;
    --

    PROCEDURE pc_gera_arq_finame(pr_dscritic OUT VARCHAR2) IS

         vr_nmarqfin   VARCHAR2(200);
         vr_dscritic   VARCHAR2(4000);
         vr_input_file UTL_FILE.file_type;  
         vr_setlinha         VARCHAR2(400);                  --> Linhas do arquivo        
         vr_typ_said         VARCHAR2(4);
         vr_chave_nivris     VARCHAR2(10);
      --
         vr_destino          NUMBER;
         vr_origem           NUMBER;
      -- Variavel de Exception
      vr_exc_erro EXCEPTION;

    BEGIN

      -- Nome do arquivo a ser gerado
         vr_nmarqfin := vr_dtmvtolt_yymmdd||'_'||lpad(pr_cdcooper,2,0)||'_AJUSTE_FINAME.txt';

      -- Tenta abrir o arquivo de log em modo gravacao
         gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                 ,pr_nmarquiv => vr_nmarqfin          --> Nome do arquivo
                                 ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                 ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                 ,pr_des_erro => vr_dscritic);        --> Erro
      IF vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Valor liberação contrato finame
      IF vr_tot_libctnfiname > 0 THEN

            vr_setlinha := fn_set_cabecalho('20'
                                           ,pr_rw_crapdat.dtmvtolt
                                           ,pr_rw_crapdat.dtmvtolt
                                           ,1432
                                           ,1631
                                           ,vr_tot_libctnfiname
                                           ,'"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO BNDES - FINAME"');

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

            vr_setlinha := fn_set_gerencial('999',vr_tot_libctnfiname);

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

      END IF;

      --Valor provisão de perda contrato finame
      IF vr_tot_prvperdafiname > 0 THEN

        --Linhas de provisão
            vr_setlinha := fn_set_cabecalho('20'
                                           ,pr_rw_crapdat.dtmvtolt
                                           ,pr_rw_crapdat.dtmvtolt
                                           ,1722
                                           ,1435
                                           ,vr_tot_prvperdafiname
                                           ,'"AJUSTE CONTABIL ⿿ PROVISAO BNDES FINAME"');

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

            vr_setlinha := fn_set_gerencial('999',vr_tot_prvperdafiname);

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        --Linhas de reversão
            vr_setlinha := fn_set_cabecalho('20'
                                           ,pr_rw_crapdat.dtmvtopr
                                           ,pr_rw_crapdat.dtmvtopr
                                           ,1435
                                           ,1722
                                           ,vr_tot_prvperdafiname
                                           ,'"REVERSAO AJUSTE CONTABIL ⿿ PROVISAO BNDES FINAME"');

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

            vr_setlinha := fn_set_gerencial('999',vr_tot_prvperdafiname);

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

      END IF;
      --
      vr_chave_nivris := vr_tab_finame_nivris.first;
      LOOP

        EXIT WHEN vr_chave_nivris IS NULL;

        --Gera no arquivo linhas referente a valor de liberação de contrato
        IF vr_tab_finame_nivris(vr_chave_nivris).vlslddev > 0 THEN

               IF vr_chave_nivris IN ('A','AA') THEN
                  vr_destino := 3321;  --provisão 
                  vr_origem  := 3321;  --reversão
          ELSIF vr_chave_nivris = 'B' THEN
            vr_destino := 3332; --provisão
            vr_origem  := 3332; --reversão
          ELSIF vr_chave_nivris = 'C' THEN
            vr_destino := 3342; --provisão
            vr_origem  := 3342; --reversão
          ELSIF vr_chave_nivris = 'D' THEN
            vr_destino := 3352; --provisão
            vr_origem  := 3352; --reversão
          ELSIF vr_chave_nivris = 'E' THEN
            vr_destino := 3362; --provisão
            vr_origem  := 3362; --reversão
          ELSIF vr_chave_nivris = 'F' THEN
            vr_destino := 3372; --provisão
            vr_origem  := 3372; --reversão
          ELSIF vr_chave_nivris = 'G' THEN
            vr_destino := 3382; --provisão
            vr_origem  := 3382; --reversão
               ELSIF vr_chave_nivris IN ('H','HH') THEN
            vr_destino := 3392; --provisão
            vr_origem  := 3392; --reversão
          END IF;

          --Gerar linhas de PROVISÿO
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,9302
                                              ,vr_destino
                                              ,vr_tab_finame_nivris(vr_chave_nivris).vlslddev
                                              ,'"CLASSIFICACAO DE RISCO DE REPASSES BNDES FINAME DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          --Gerar linhas de REVERSÿO
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,vr_origem
                                              ,9302
                                              ,vr_tab_finame_nivris(vr_chave_nivris).vlslddev
                                              ,'"REVERSAO DE AJUSTE DE CLASSIFICACAO DE RISCO DE REPASSES BNDES FINAME DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

        END IF;

        vr_chave_nivris := vr_tab_finame_nivris.next(vr_chave_nivris);
      END LOOP;

      -- Fechar Arquivo
      BEGIN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
            vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_diretorio||'/'||vr_nmarqfin||'>: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Copia o arquivo gerado para o diretório final convertendo para DOS
         gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqfin||' > '||vr_nom_dir_copia||'/'||vr_nmarqfin||' 2>/dev/null',
                                  pr_typ_saida   => vr_typ_said,
                                  pr_des_saida   => vr_dscritic);
      -- Testar erro
      if vr_typ_said = 'ERR' then
           vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarqfin||': '||vr_dscritic;
        raise vr_exc_erro;
      end if;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
           pr_dscritic := 'Erro geral na procedure pc_gera_arq_finame: '||SQLERRM;       
    END pc_gera_arq_finame;

    PROCEDURE pc_gera_arq_miccred(pr_dscritic OUT VARCHAR2) IS

      vr_nmarqmic         VARCHAR2(200);
      vr_dscritic         VARCHAR2(4000);
      vr_chave_finalidade VARCHAR2(50);
      vr_chave_nivris     VARCHAR2(10);
         vr_input_file       UTL_FILE.file_type;             --> Handle Utl File
         vr_setlinha         VARCHAR2(400);                  --> Linhas do arquivo        
      vr_typ_said         VARCHAR2(4);
      --
         vr_destino          NUMBER;
         vr_origem           NUMBER;
         vr_descricao        VARCHAR2(400);

      -- Variavel de Exception
      vr_exc_erro EXCEPTION;

    BEGIN

      -- Nome do arquivo a ser gerado
         vr_nmarqmic := vr_dtmvtolt_yymmdd||'_'||lpad(pr_cdcooper,2,0)||'_AJUSTE_MICROCREDITO.txt';

      -- Tenta abrir o arquivo de log em modo gravacao
         gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                 ,pr_nmarquiv => vr_nmarqmic          --> Nome do arquivo
                                 ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                 ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                 ,pr_des_erro => vr_dscritic);        --> Erro
      IF vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      vr_chave_finalidade := vr_tab_miccred_fin.first;
      LOOP

        EXIT WHEN vr_chave_finalidade IS NULL;

        --Gera no arquivo linhas referente a valor de liberação de contrato
        IF vr_tab_miccred_fin(vr_chave_finalidade).vllibctr > 0 THEN

          IF vr_chave_finalidade = 1 THEN
                  vr_origem := 1437;
            vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO MICROCREDITO CEF"';
          ELSIF vr_chave_finalidade = 2 THEN
                  vr_origem := 1780;  
            vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO CCB IMOBILIZADO REFAP"';
          ELSIF vr_chave_finalidade = 3 THEN
            vr_origem := 1621;
            vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO CCB MAIS CREDITO"';
          ELSIF vr_chave_finalidade = 4 THEN
                  vr_origem := 1440;  
            vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO MICROCREDITO BNDES"';
          END IF;

               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,vr_origem
                                              ,1662
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vllibctr
                                              ,vr_descricao);

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

               IF vr_chave_finalidade IN (1,4) THEN
                  vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vllibctr);
          ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vllibctr);  
          END IF;

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
        END IF;

        --Gera no arquivo linhas referente a valor de apropriação de contrato
        IF vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec > 0 THEN

          IF vr_chave_finalidade = 1 THEN
                  vr_origem := 1437;
                  vr_destino := 7302;
            vr_descricao := '"AJUSTE CONTABIL REF. JUROS MICROCREDITO CEF"';
          ELSIF vr_chave_finalidade = 2 THEN
                  vr_origem := 1780;  
                  vr_destino := 7112;                  
            vr_descricao := '"AJUSTE CONTABIL - JUROS CCB IMOBILIZADO REFAP (INVESTIMENTOS)"';
          ELSIF vr_chave_finalidade = 3 THEN
            vr_origem := 1621;  
                  vr_destino := 7116;                  
            vr_descricao := '"AJUSTE CONTABIL - JUROS CCB MAIS CREDITO"';
          ELSIF vr_chave_finalidade = 4 THEN
                  vr_origem := 1440;  
                  vr_destino := 7306;                  
            vr_descricao := '"AJUSTE CONTABIL REF. JUROS MICROCREDITO BNDES"';
          END IF;

               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,vr_origem
                                              ,1662
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec
                                              ,vr_descricao);

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

               IF vr_chave_finalidade IN (1,4) THEN
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec);
          ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec);
          END IF;

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          --Escreve novamente as linhas para outra conta de débito e crédito
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,7141
                                              ,vr_destino
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec
                                              ,vr_descricao);

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

               IF vr_chave_finalidade IN (1,4) THEN
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec);
          ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec); 
          END IF;

          --Escreve duas vezes a linha gerencial
               FOR i IN 1..2 LOOP
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita
          END LOOP;
        END IF;

        --Gera no arquivo linhas referente a valor de provisão de contrato
        IF vr_tab_miccred_fin(vr_chave_finalidade).vlprvper > 0 THEN

          IF vr_chave_finalidade = 1 THEN
            --para provisão
            vr_destino := 1438;
            
            --para reversao
                  vr_origem := 1438;
            vr_descricao := '"AJUSTE CONTABIL - PROVISAO CEF"';
          ELSIF vr_chave_finalidade = 2 THEN
            --para provisão
            vr_destino := 1702;
            
            --para reversao
                  vr_origem  := 1702;  
            vr_descricao := '"AJUSTE CONTABIL - PROVISAO CCB IMOBILIZADO REFAP"';
          ELSIF vr_chave_finalidade = 4 THEN
            --para provisão
            vr_destino := 1441;
            
            --para reversao
                  vr_origem  := 1441;  
            vr_descricao := '"AJUSTE CONTABIL - PROVISAO BNDES"';
          END IF;

          --Cria linhas de provisão
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,1731
                                              ,vr_destino
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vlprvper
                                              ,vr_descricao);

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

               IF vr_chave_finalidade IN (1,4) THEN
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper);
          ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper);                 
          END IF;

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          --Cria linhas de reversão
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,vr_origem
                                              ,1731
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vlprvper
                                              ,replace(vr_descricao,'PROVISAO','REVERSAO'));

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

               IF vr_chave_finalidade IN (1,4) THEN
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper);
          ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper); 
          END IF;

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

        END IF;

        -- Gera no arquivo linhas referente a valor de pagamento de parcelas de contrato
        IF vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91 > 0 THEN

          IF vr_chave_finalidade = 1 THEN
                  vr_destino := 1437;
            vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS MICROCREDITO CEF"';
          ELSIF vr_chave_finalidade = 2 THEN
                  vr_destino := 1780;
            vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS CCB IMOBILIZADO REFAP"';
          ELSIF vr_chave_finalidade = 3 THEN
            vr_destino := 1621;
            vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS CCB MAIS CREDITO"';
          ELSIF vr_chave_finalidade = 4 THEN
                  vr_destino := 1440;
            vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS MICROCREDITO BNDES"';
          END IF;

               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,1662
                                              ,vr_destino
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91
                                              ,vr_descricao);

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

               IF vr_chave_finalidade IN (1,4) THEN            
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91);
          ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91);
          END IF;

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
        END IF;

        -- Gera no arquivo linhas referente a valor de pagamento de parcelas de contrato
        IF vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95 > 0 THEN

          IF vr_chave_finalidade = 1 THEN
                  vr_destino := 1437;
            vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL MICROCREDITO CEF"';
          ELSIF vr_chave_finalidade = 2 THEN
                  vr_destino := 1780;  
            vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL CCB IMOBILIZADO REFAP"';
          ELSIF vr_chave_finalidade = 3 THEN
            vr_destino := 1621;  
            vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL CCB MAIS CREDITO"';
          ELSIF vr_chave_finalidade = 4 THEN
                  vr_destino := 1440;  
            vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL MICROCREDITO BNDES"';
          END IF;

               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,1662
                                              ,vr_destino
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95
                                              ,vr_descricao);

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

               IF vr_chave_finalidade IN (1,4) THEN
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95);
          ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95);
          END IF;

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
        END IF;

        -- Gera no arquivo linhas referente a valor de pagamento de parcelas de contrato
        IF vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441 > 0 THEN

          IF vr_chave_finalidade = 1 THEN
                  vr_origem  := 7306;
                  vr_destino := 7302;
            vr_descricao := '(AJUSTE DE SALDO - MICROCREDITO CEF - AJUSTE CONTABIL)"';
          ELSIF vr_chave_finalidade = 2 THEN
                  vr_origem  := 7306;
                  vr_destino := 7112;
            vr_descricao := '(AJUSTE DE SALDO - CCB IMOBILIZADO REFAP - AJUSTE CONTABIL)"';
          ELSIF vr_chave_finalidade = 3 THEN
                  vr_origem  := 7306;
                  vr_destino := 7116;
            vr_descricao := '(AJUSTE DE SALDO - CCB MAIS CREDITO - AJUSTE CONTABIL)"';
          ELSIF vr_chave_finalidade = 4 THEN
                  vr_origem  := 1440;
                  vr_destino := 1662;
            vr_descricao := '(AJUSTE DE SALDO - MICROCREDITO BNDES - AJUSTE CONTABIL)"';
          END IF;

               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,vr_origem
                                              ,vr_destino
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441
                                              ,'"EMPRESTIMOS EFETUADOS PARA ASSOCIADOS - (0441) JUROS SOBRE EMPRESTIMOS ' || vr_descricao);

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

               IF vr_chave_finalidade IN (1,4) THEN            
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441);
          ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441);   
          END IF;

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
        END IF;

        vr_chave_finalidade := vr_tab_miccred_fin.next(vr_chave_finalidade);

      END LOOP;

      vr_chave_nivris := vr_tab_miccred_nivris.first;
      
      LOOP

        EXIT WHEN vr_chave_nivris IS NULL;

        --Gera no arquivo linhas referente a valor de liberação de contrato
        IF vr_tab_miccred_nivris(vr_chave_nivris).vlslddev > 0 THEN

              IF vr_chave_nivris IN ('A','AA') THEN
                 vr_destino := 3321;  --provisão 
                 vr_origem  := 3321;  --reversão
          ELSIF vr_chave_nivris = 'B' THEN
            vr_destino := 3332; --provisão
            vr_origem  := 3332; --reversão
          ELSIF vr_chave_nivris = 'C' THEN
            vr_destino := 3342; --provisão
            vr_origem  := 3342; --reversão
          ELSIF vr_chave_nivris = 'D' THEN
            vr_destino := 3352; --provisão
            vr_origem  := 3352; --reversão
          ELSIF vr_chave_nivris = 'E' THEN
            vr_destino := 3362; --provisão
            vr_origem  := 3362; --reversão
          ELSIF vr_chave_nivris = 'F' THEN
            vr_destino := 3372; --provisão
            vr_origem  := 3372; --reversão
          ELSIF vr_chave_nivris = 'G' THEN
            vr_destino := 3382; --provisão
            vr_origem  := 3382; --reversão
              ELSIF vr_chave_nivris IN ('H','HH') THEN
            vr_destino := 3392; --provisão
            vr_origem  := 3392; --reversão
          END IF;

          --Gerar linhas de PROVISÿO
              vr_setlinha := fn_set_cabecalho('20'
                                             ,pr_rw_crapdat.dtmvtolt
                                             ,pr_rw_crapdat.dtmvtolt
                                             ,9302
                                             ,vr_destino
                                             ,vr_tab_miccred_nivris(vr_chave_nivris).vlslddev
                                             ,'"CLASSIFICACAO DE RISCO DE REPASSES CEF E BNDES DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          --Gerar linhas de REVERSÿO
              vr_setlinha := fn_set_cabecalho('20'
                                             ,pr_rw_crapdat.dtmvtopr
                                             ,pr_rw_crapdat.dtmvtopr
                                             ,vr_origem
                                             ,9302
                                             ,vr_tab_miccred_nivris(vr_chave_nivris).vlslddev
                                             ,'"REVERSAO DE AJUSTE DE CLASSIFICACAO DE RISCO DE REPASSES CEF E BNDES DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

        END IF;

        vr_chave_nivris := vr_tab_miccred_nivris.next(vr_chave_nivris);
      END LOOP;

      /* PROGRAMA PESE BNDES */
      IF v_pese_vldivida > 0 THEN
        vr_origem    := 1444;
        vr_destino   := 1667;
        vr_descricao := '"RECLASSIFICACAO CONTABIL REF. REPASSE BNDES PESE"';

        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_rw_crapdat.dtmvtolt
                                       ,pr_rw_crapdat.dtmvtolt
                                       ,vr_origem
                                       ,vr_destino
                                       ,v_pese_vldivida
                                       ,vr_descricao);

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        vr_setlinha := fn_set_gerencial('999',v_pese_vldivida);  

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

        --Cria linha de reversao
        vr_descricao := '"REVERSAO RECLASSIFICACAO CONTABIL REF. REPASSE BNDES PESE"';

        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_rw_crapdat.dtmvtopr
                                       ,pr_rw_crapdat.dtmvtopr
                                       ,vr_destino
                                       ,vr_origem
                                       ,v_pese_vldivida
                                       ,vr_descricao);

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        vr_setlinha := fn_set_gerencial('999',v_pese_vldivida);  

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
      END IF;

      --Gera no arquivo linhas referente a valor de provisão de contrato
      IF v_pese_vlprvper > 0 THEN
        vr_origem    := 1733;
        vr_destino   := 1446;
        vr_descricao := '"RECLASSIFICACAO CONTABIL REF. REPASSE BNDES PESE"';

        --Cria linhas de provisão
        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_rw_crapdat.dtmvtolt
                                       ,pr_rw_crapdat.dtmvtolt
                                       ,vr_origem
                                       ,vr_destino
                                       ,v_pese_vlprvper
                                       ,vr_descricao);

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        vr_setlinha := fn_set_gerencial('999',v_pese_vlprvper);

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        --Cria linhas de reversão
        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_rw_crapdat.dtmvtopr
                                       ,pr_rw_crapdat.dtmvtopr
                                       ,vr_destino
                                       ,vr_origem
                                       ,v_pese_vlprvper
                                       ,replace(vr_descricao,'RECLASSIFICACAO','REVERSAO RECLASSIFICACAO'));

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        vr_setlinha := fn_set_gerencial('999',v_pese_vlprvper); 

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
      END IF;

      --Gera no arquivo linhas referente a valor de apropriação de contrato
      IF v_pese_vlaprrec > 0 THEN
        vr_origem    := 7135;
        vr_destino   := 7289;
        vr_descricao := '"RECLASSIFICACAO CONTABIL REF. RENDAS SOBRE REPASSE BNDES PESE"';

        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_rw_crapdat.dtmvtolt
                                       ,pr_rw_crapdat.dtmvtolt
                                       ,vr_origem
                                       ,vr_destino
                                       ,v_pese_vlaprrec
                                       ,vr_descricao);

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        vr_setlinha := fn_set_gerencial('999',v_pese_vlaprrec);

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita
        
        --Criar segundo linha pois ambas as contas possuem rateio por gerencial
        vr_setlinha := fn_set_gerencial('999',v_pese_vlaprrec);

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita
      END IF;
      
      vr_chave_nivris := vr_tab_pese_nivris.first;

      LOOP
        EXIT WHEN vr_chave_nivris IS NULL;

        --Gera no arquivo linhas referente a valor de liberação de contrato
        IF vr_tab_pese_nivris(vr_chave_nivris).vlslddev > 0 THEN
          IF vr_chave_nivris IN ('A','AA') THEN
            vr_destino := 3321;  --provisão 
            vr_origem  := 3321;  --reversão
          ELSIF vr_chave_nivris = 'B' THEN
            vr_destino := 3332; --provisão
            vr_origem  := 3332; --reversão
          ELSIF vr_chave_nivris = 'C' THEN
            vr_destino := 3342; --provisão
            vr_origem  := 3342; --reversão
          ELSIF vr_chave_nivris = 'D' THEN
            vr_destino := 3352; --provisão
            vr_origem  := 3352; --reversão
          ELSIF vr_chave_nivris = 'E' THEN
            vr_destino := 3362; --provisão
            vr_origem  := 3362; --reversão
          ELSIF vr_chave_nivris = 'F' THEN
            vr_destino := 3372; --provisão
            vr_origem  := 3372; --reversão
          ELSIF vr_chave_nivris = 'G' THEN
            vr_destino := 3382; --provisão
            vr_origem  := 3382; --reversão
          ELSIF vr_chave_nivris IN ('H','HH') THEN
            vr_destino := 3392; --provisão
            vr_origem  := 3392; --reversão
          END IF;

          --Gerar linhas de PROVISÿO
          vr_setlinha := fn_set_cabecalho('20'
                                         ,pr_rw_crapdat.dtmvtolt
                                         ,pr_rw_crapdat.dtmvtolt
                                         ,9302
                                         ,vr_destino
                                         ,vr_tab_pese_nivris(vr_chave_nivris).vlslddev
                                         ,'"RECLASSIFICACAO CONTABIL REF. REPASSE BNDES PESE"');

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          --Gerar linhas de REVERSÿO
          vr_setlinha := fn_set_cabecalho('20'
                                         ,pr_rw_crapdat.dtmvtopr
                                         ,pr_rw_crapdat.dtmvtopr
                                         ,vr_origem
                                         ,9302
                                         ,vr_tab_pese_nivris(vr_chave_nivris).vlslddev
                                         ,'"REVERSAO RECLASSIFICACAO CONTABIL REF. REPASSE BNDES PESE"');

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
        END IF;

        vr_chave_nivris := vr_tab_pese_nivris.next(vr_chave_nivris);
      END LOOP;
      /* FIM PROGRAMA PESE BNDES */

      -- Fechar Arquivo
      BEGIN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
           vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_diretorio||'/'||vr_nmarqmic||'>: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Copia o arquivo gerado para o diretório final convertendo para DOS
        gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqmic||' > '||vr_nom_dir_copia||'/'||vr_nmarqmic||' 2>/dev/null',
                                  pr_typ_saida   => vr_typ_said,
                                  pr_des_saida   => vr_dscritic);
      -- Testar erro
      if vr_typ_said = 'ERR' then
          vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarqmic||': '||vr_dscritic;
        raise vr_exc_erro;
      end if;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
           pr_dscritic := 'Erro geral na procedure pc_gera_arq_miccred: '||SQLERRM; 
    END pc_gera_arq_miccred;


    /* Processar conta de migração entre cooperativas */
      FUNCTION fn_verifica_conta_migracao(pr_nrdconta  IN crapass.nrdconta%TYPE) --> Número da conta
     RETURN BOOLEAN IS
    BEGIN
      -- Validamos Apenas Via, AV e SCR
         IF NOT pr_cdcooper IN(1,13,16) THEN
        -- OK
        RETURN TRUE;
      ELSE
        IF vr_tab_craptco.exists(pr_nrdconta) THEN
          RETURN FALSE;
        ELSE
          -- Tudo OK até aqui, retornamos true
          RETURN TRUE;
        END IF;
      END IF;
    END fn_verifica_conta_migracao;

    ------------------------
    -- Projeto Ligeirinho --
    ------------------------

    procedure pc_iniciar_amb_paralel is
    begin
      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_id_paralelo;
      -- Se houver algum erro, vr_idparale será 0 (Zero)
      IF vr_idparale = 0 THEN
        -- Levantar exceção
        vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_id_paralelo.';
        RAISE vr_exc_saida;
      END IF;

    exception
      when vr_exc_saida then
        raise vr_exc_saida;
    end pc_iniciar_amb_paralel;

    --Limpar todos os dados temporarios gerados por este programa.
    procedure pc_clear_memoria(pr_CDAGENCI in tbgen_batch_relatorio_wrk.CDAGENCI%type) is
    begin
      delete from tbgen_batch_relatorio_wrk wrk
       where wrk.cdcooper = pr_cdcooper
         and wrk.cdprograma = pr_cdprogra --in ('CRPS280_I','CRPS280','CRPS516' )
         and wrk.dtmvtolt = pr_rw_crapdat.dtmvtolt
         and wrk.cdagenci = decode(pr_CDAGENCI, 0, wrk.cdagenci, pr_CDAGENCI);

    end pc_clear_memoria;

    procedure pc_criar_job_paralelo is
    begin

      pc_log_programa(PR_DSTIPLOG     => 'O',
                      PR_CDPROGRAMA   => pr_cdprogra || '_' || pr_cdagenci || '$',
                      pr_cdcooper     => pr_cdcooper,
                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia => 4,
                      pr_dsmensagem   => 'pc_criar_job_paralelo - INICIO cursor cr_crapage. AGENCIA: ' ||
                                         pr_cdagenci || ' - INPROCES: ' ||
                                         pr_rw_crapdat.inproces,
                      PR_IDPRGLOG     => vr_idlog_ini_ger);

      for reg_crapage in cr_crapris_agenci(pr_cdcooper => pr_cdcooper,
                                           pr_dtrefere => pr_dtrefere,
                                           pr_cdagenci => pr_cdagenci,
                                           pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                                           pr_cdprogra => vr_cdprogra) loop
        -- Montar o prefixo do código do programa para o jobname
        vr_jobname := vr_cdprogra || '_' || reg_crapage.cdagenci || '$';

        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => LPAD(reg_crapage.cdagenci, 3, '0') --> Utiliza a agência como id programa
                                  ,pr_des_erro => vr_dscritic);

        -- Testar saida com erro
        if vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;
        -- Montar o bloco PLSQL que será executado
        -- Ou seja, executaremos a geração dos dados
        -- para a agência atual atraves de Job no banco
        vr_dsplsql := 'declare ' || chr(13) ||
                      ' wpr_stprogra  binary_integer; ' || chr(13) ||
                      ' wpr_infimsol  binary_integer; ' || chr(13) ||
                      ' wpr_cdcritic  number(5); ' || chr(13) ||
                      ' wpr_dscritic  varchar2(4000); ' || chr(13) ||
                      ' wpr_vltotprv  crapbnd.vltotprv%TYPE; ' || chr(13) ||
                      ' wpr_vltotdiv  crapbnd.vltotdiv%TYPE; ' || chr(13) ||
                      ' rw_crapdat    btch0001.cr_crapdat%ROWTYPE;' || chr(13) ||
                      'begin ' || chr(13) ||
                      '   cecred.PC_CRPS280_I_WAG(' || pr_cdcooper || ',' || chr(13) ||
                      'rw_crapdat,' || chr(13) ||
                      '''' || pr_dtrefere || '''' || ',' || chr(13) ||
                      '''' || pr_cdprogra || '''' || ',' || chr(13) ||
                      '''' || pr_dsdircop || '''' || ',' || chr(13) ||
                      reg_crapage.cdagenci || ',' || chr(13) ||
                      vr_idparale || ',' || chr(13) ||
                      pr_flgresta || ',' || chr(13) ||
                      pr_flgrelat || ',' || chr(13) ||
                      'wpr_stprogra,' || chr(13) ||
                      'wpr_infimsol,' || chr(13) ||
                      'wpr_vltotprv,' || chr(13) ||
                      'wpr_vltotdiv,' || chr(13) ||
                       'wpr_cdcritic,' || chr(13) ||
                      'wpr_dscritic' || chr(13) ||
                      ');' || chr(13) ||
                      '   if nvl(wpr_cdcritic,0) > 0 or trim(wpr_dscritic) is not null then' || chr(13) ||
                      '      raise_application_error(-20500,wpr_cdcritic||''-''||wpr_dscritic);' || chr(13) ||
                      '   END IF;'  || chr(13) ||
                      'end;';
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper --> Código da cooperativa
                              ,pr_cdprogra => vr_cdprogra --> Código do programa
                              ,pr_dsplsql  => vr_dsplsql --> Bloco PLSQL a executar
                              ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                              ,pr_interva  => NULL --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                              ,pr_jobname  => vr_jobname --> Nome randomico criado
                              ,pr_des_erro => vr_dscritic);

        -- Testar saida com erro
        if vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;

        -- Chama rotina que irá pausar este processo controlador
        -- caso tenhamos excedido a quantidade de JOBS em execuçao
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale,
                                     pr_qtdproce => vr_qtdjobs,
                                     pr_des_erro => vr_dscritic);
        -- Testar saida com erro
        if vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;

      end loop reg_crapage;

      pc_log_programa(PR_DSTIPLOG     => 'O',
                      PR_CDPROGRAMA   => pr_cdprogra || '_' || pr_cdagenci || '$',
                      pr_cdcooper     => pr_cdcooper,
                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia => 4,
                      pr_dsmensagem   => 'pc_criar_job_paralelo - FIM cursor cr_crapage. AGENCIA: ' ||
                                         pr_cdagenci || ' - INPROCES: ' ||
                                         pr_rw_crapdat.inproces,
                      PR_IDPRGLOG     => vr_idlog_ini_ger);
    exception
      when vr_exc_saida then
        raise vr_exc_saida;

    end pc_criar_job_paralelo;

    procedure pc_busca_arq_controle_risco is
    begin
      -- Busca do arquivo para controle de informaçõs da central de risco
      FOR rw_crapris IN cr_crapris LOOP
        BEGIN
          -- Verifica migração/incorporação
          IF NOT
              fn_verifica_conta_migracao(pr_nrdconta => rw_crapris.nrdconta) THEN
            CONTINUE;
          END IF;

          vr_fleprces := 0;

          -- Para Emprestimos/Financiamentos
          IF rw_crapris.cdorigem = 3 THEN
            -- Para empréstimos BNDES
            IF rw_crapris.dsinfaux = 'BNDES' THEN
              -- Buscar informações da crapebn
              OPEN cr_crapebn(pr_nrdconta => rw_crapris.nrdconta,
                              pr_nrctremp => rw_crapris.nrctremp);
              FETCH cr_crapebn
                INTO vr_vlpreemp;
              -- Se encontrou
              IF cr_crapebn%FOUND THEN
                CLOSE cr_crapebn;
                vr_cdlcremp := 'BNDES';
				vr_tpemprst := NULL; -- paralelismo.

                IF rw_crapris.qtdiaatr > 0 THEN
                  vr_qtatraso := TRUNC(rw_crapris.qtdiaatr / 30, 0) + 1;
									vr_qtdiaatr := rw_crapris.qtdiaatr; -- paralelismo.
                ELSE
                  vr_qtatraso := 0;
									vr_qtdiaatr := 0; -- paralelismo.
                END IF;

                /* BNDES - Enquanto nao tivermos campo no arquivo de
                     OPERACOES da TOTVS com a quantidade
                     de parcelas em atraso, iremos utilizar a quantidade de
                     meses em atraso. Enquanto nao ultrapassar a da final
                     do contrato nao teremos problema, pois a quantidade de
                     meses em atraso vai bater com a quantidade de parcelas
                     em atraso. Porem, se ultrapassar, a quantidade de
                     meses continuara aumentando, e a quantidade de
                     parcelas nao, e este campo nao podera ser igual.
                */
                vr_nroprest := vr_qtatraso;
              ELSE
                CLOSE cr_crapebn;
              END IF;
              -- Empréstimos Cooperativa
            ELSE
              -- Buscar detalhes dos empréstimos
              OPEN cr_crapepr(pr_nrdconta => rw_crapris.nrdconta,
                              pr_nrctremp => rw_crapris.nrctremp);
              FETCH cr_crapepr
                INTO rw_crapepr;
              -- Somente se encontrar
              IF cr_crapepr%FOUND THEN
                -- fechar o cursor e continuar o processo
                CLOSE cr_crapepr;

                -- Indicador se é um emprestimo de cessao
                vr_fleprces := case
                                 when rw_crapepr.dtvencto_original is null then
                                  0
                                 else
                                  1
                               end;

                -- Inicializar qtde meses decorridos com o valor da tabela
                vr_qtmesdec := rw_crapepr.qtmesdec;

                /* Efetuar correcao quantidade parcelas em atraso */

                vr_qtprecal_intei := rw_crapepr.qtprecal;

                -- Se existir data do primeiro pagamento
                IF rw_crapepr.dtdpagto IS NOT NULL THEN
                  -- Se o dia de pagamento é posterior E a data correte ainda é no mesmo mÿs
                  --   OU
                  -- Se o dia corrente e o próximo dia util são do mesmo mês e a data de pagamento venceu
                  IF (to_char(rw_crapepr.dtdpagto, 'dd') >
                     to_char(pr_rw_crapdat.dtmvtolt, 'dd') AND
                     TRUNC(rw_crapepr.dtdpagto, 'mm') =
                     TRUNC(pr_rw_crapdat.dtmvtolt, 'mm')) OR
                     (TRUNC(pr_rw_crapdat.dtmvtolt, 'mm') =
                     TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') AND
                     rw_crapepr.dtdpagto > pr_rw_crapdat.dtmvtolt) THEN
                    -- Decrementar -1 mês
                    vr_qtmesdec := vr_qtmesdec - 1;
                  END IF;
                END IF;

                -- Iremos buscar a tabela de juros nas linhas de crédito
                OPEN cr_craplcr(pr_cdcooper => pr_cdcooper,
                                pr_cdlcremp => rw_crapepr.cdlcremp);
                FETCH cr_craplcr
                  INTO rw_craplcr;
                -- Se não encontrar
                IF cr_craplcr%NOTFOUND THEN
                  -- Fechar o cursor
                  CLOSE cr_craplcr;
                  -- Gerar erro
                  pr_cdcritic := 363;
                  pr_dscritic := gene0001.fn_busca_critica(363);
                  -- sai do loop e continua o procesamento
                  -- equivalente LEAVE do progress
                  EXIT;
                END IF;
                -- Fechar o cursor
                CLOSE cr_craplcr;


                vr_txmenemp := rw_crapepr.txmensal;

                /* Diario */
                IF to_char(pr_rw_crapdat.dtmvtolt, 'MM') =
                   to_char(pr_rw_crapdat.dtmvtopr, 'MM') THEN
                  -- verifica o tipo do emprestimo 0-atual
                  IF rw_crapepr.tpemprst = 0 THEN
                    vr_qtprecal_decim := rw_crapepr.qtlcalat;
                  ELSE
                    /* END IF crapepr.tpemprst = 0 */
                    vr_qtprecal_decim := rw_crapepr.qtpcalat;
                  END IF;

                  -- Guardar o valor retornado para a variavel inteira
                  vr_qtprecal_intei := vr_qtprecal_decim;
                  -- Acumular aos valores de retorno (inteiro e decimal) o valor da tabela
                  vr_qtprecal_intei := vr_qtprecal_intei +
                                       rw_crapepr.qtprecal;
                  vr_qtprecal_decim := vr_qtprecal_decim +
                                       rw_crapepr.qtprecal;
                  -- Guardar o saldo devedor atual
                  vr_vlsdeved_atual := rw_crapepr.vlsdevat;

                ELSE
                  /* Mensal */
                  vr_qtprecal_intei := rw_crapepr.qtprecal;
                  vr_vlsdeved_atual := rw_crapepr.vlsdeved;
                  vr_qtprecal_decim := rw_crapepr.qtprecal;
                END IF;

                -- Buscando a configuração de empréstimo cfme a empresa da conta
                empr0001.pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                                                   ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data corrente
                                                   ,pr_nrdconta => rw_crapris.nrdconta --> Numero da conta do empréstim
                                                   ,pr_dtcalcul => vr_tab_dtcalcul --> Data calculada de pagamento
                                                   ,pr_diapagto => vr_tab_diapagto --> Dia de pagamento das parcelas
                                                   ,pr_flgfolha => vr_tab_flgfolha --> Flag de desconto em folha S/N
                                                   ,pr_ddmesnov => vr_tab_ddmesnov --> Configuração para mês novo
                                                   ,pr_cdcritic => pr_cdcritic --> Código do erro
                                                   ,pr_des_erro => pr_dscritic);

                -- atribui a taxa de juros do emprestimo
                vr_txdjuros := rw_crapepr.txjuremp;

                ----------------------------------
                -- criando registro de emprestimo
                ----------------------------------

                -- criando o indice da tabela temporaria
                vr_indice := LPAD(rw_crapepr.nrdconta, 10, '0') ||
                             LPAD(rw_crapepr.nrctremp, 10, '0');
                -- Alimentando a tabela de emprestimos
                vr_tab_dados_epr(vr_indice).cdagenci := rw_crapepr.cdagenci; -- Ligeirinho.
                vr_tab_dados_epr(vr_indice).nrdconta := rw_crapepr.nrdconta;
                vr_tab_dados_epr(vr_indice).nrctremp := rw_crapepr.nrctremp;
                vr_tab_dados_epr(vr_indice).vlpapgat := rw_crapepr.vlpapgat;
                vr_tab_dados_epr(vr_indice).flgpagto := rw_crapepr.flgpagto;
                vr_tab_dados_epr(vr_indice).dtdpagto := rw_crapepr.dtdpagto;
                vr_tab_dados_epr(vr_indice).vlsdevat := rw_crapepr.vlsdevat;
                vr_tab_dados_epr(vr_indice).qtpcalat := rw_crapepr.qtpcalat;
                vr_tab_dados_epr(vr_indice).txmensal := vr_txmenemp;
                vr_tab_dados_epr(vr_indice).txjuremp := vr_txdjuros;
                vr_tab_dados_epr(vr_indice).vlppagat := rw_crapepr.vlppagat;
                vr_tab_dados_epr(vr_indice).qtmdecat := rw_crapepr.qtmdecat;
                vr_tab_dados_epr(vr_indice).inprejuz := rw_crapepr.inprejuz;
                vr_tab_dados_epr(vr_indice).inliquid := rw_crapepr.inliquid;
                vr_tab_dados_epr(vr_indice).qtpreemp := rw_crapepr.qtpreemp;
                vr_tab_dados_epr(vr_indice).cdlcremp := rw_crapepr.cdlcremp;
                vr_tab_dados_epr(vr_indice).cdfinemp := rw_crapepr.cdfinemp;
                vr_tab_dados_epr(vr_indice).dtmvtolt := rw_crapepr.dtmvtolt;
                vr_tab_dados_epr(vr_indice).vlemprst := rw_crapepr.vlemprst;
                vr_tab_dados_epr(vr_indice).tpdescto := rw_crapepr.tpdescto;
                vr_tab_dados_epr(vr_indice).vljurmes := rw_crapepr.vljurmes;
                -- Para microcrédito
                IF rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN
                  -- Armazenar a origem do Microcrédito
                  vr_tab_dados_epr(vr_indice).dsorgrec := rw_craplcr.dsorgrec;
                END IF;
                -- Armazenar a data de início do contrato
                vr_tab_dados_epr(vr_indice).dtinictr := rw_crapris.dtinictr;

                /* Caso for cessao de credito, a data da primeira parcela eh o vcto original da cessao */
                IF vr_fleprces = 1 THEN
                  --17/04/2020 - INC0043759
                  --Somente popular a dtdpagto com a data da cessão do cartão se o contrato de cessão não foi renegociado,
                  --se foi renegociado, a dtdpagto é a data de pagamento da primeira prestação da renegociação. 
                  IF empr0021.fn_retorna_qtd_renegociacoes(pr_cdcooper => pr_cdcooper
                                                          ,pr_nrdconta => rw_crapepr.nrdconta
                                                          ,pr_nrctremp => rw_crapepr.nrctremp
                                                          ,pr_tplibera => 1) = 0 THEN                                                
                    IF Nvl(vr_tab_dados_epr(vr_indice).qtpreemp,0) = 1 THEN
                      vr_tab_dados_epr(vr_indice).dtdpagto := rw_crapepr.dtvencto_original;
                    --24/07/2020 - INC0055731
                    --Para Cessão de Cartão com mais de uma Parcela, somente popular a dtdpagto com a data da cessão se tiver
                    --atraso da primeira parcela, nas demais parcelas a dtdpagto deve ser a data da parcela do empréstimo.  
                    ELSE 
                      IF Nvl(vr_tab_dados_epr(vr_indice).qtpcalat,0) = 0 THEN                                                                                                                   
                        vr_tab_dados_epr(vr_indice).dtdpagto := rw_crapepr.dtvencto_original;
                      END IF;  
                    END IF;
                  END IF;                    
                END IF;

                -- Para empréstimo pré-fixado ou Pos-Fixado
                IF rw_crapepr.tpemprst IN (1, 2) THEN
                  -- Utilizaremos o valor da tabela
                  vr_qtdiaatr := rw_crapris.qtdiaatr;
                ELSE
                  -- Calcular os dias em atraso com base nos meses decorridos
                  vr_qtdiaatr := (vr_qtmesdec - vr_qtprecal_decim) * 30;

                  IF vr_qtdiaatr <= 0 AND rw_crapepr.flgpagto = 0 THEN
                    -- Conta corrente
                    vr_qtdiaatr := pr_rw_crapdat.dtmvtolt -
                                   rw_crapepr.dtdpagto;
                  END IF;

                  -- Garantir que não fique negativo
                  IF vr_qtdiaatr < 0 THEN
                    vr_qtdiaatr := 0;
                  END IF;

                END IF;

                -- Decrementar dos meses corridos a quantidade calculada
                vr_qtmesdec := (vr_qtmesdec - vr_qtprecal_intei);

                -- Garantir que a quantidade não fique abaixo de zero
                IF vr_qtmesdec < 0 THEN
                  vr_qtmesdec := 0;
                END IF;

                -- Copiar o valor a variável de atraso
                vr_qtatraso := vr_qtmesdec;

                -- Garantir que não fique superior a quantidade de parcelas
                IF vr_qtmesdec > rw_crapepr.qtpreemp THEN
                  vr_qtmesdec := rw_crapepr.qtpreemp;
                END IF;

                -- Atribuir aos campos da tabela o valor da parcela e linha de credito
                vr_vlpreemp := rw_crapepr.vlpreemp;
                vr_cdlcremp := to_char(rw_crapepr.cdlcremp);
                vr_cdfinemp := rw_crapepr.cdfinemp;
                vr_cdusolcr := rw_craplcr.cdusolcr;
                vr_dsorgrec := rw_craplcr.dsorgrec;

                CASE rw_crapepr.tpemprst
                  WHEN 0 THEN
                    vr_tpemprst := 'TR';
                  WHEN 1 THEN
                    vr_tpemprst := 'PP';
                  WHEN 2 THEN
                    vr_tpemprst := 'POS';
                  ELSE
                    vr_tpemprst := '-';
                END CASE;

                -- Para empréstimo pré-fixado ou Pos-Fixado
                IF rw_crapepr.tpemprst IN (1, 2) THEN
                  -- Número prestações recebe qtde decorrida - parcelas calculadas
                  vr_nroprest := rw_crapepr.qtmesdec - nvl(rw_crapepr.qtpcalat, 0);

                  -- Se deu negativo, considerar 0
                  IF vr_nroprest < 0 THEN
                    vr_nroprest := 0;
                  END IF;

                  -- Se houver atraso na tabela de risco
                  IF rw_crapris.qtdiaatr > 0 THEN
                    -- Calcular dividindo a quantidade de dias por 30
                    vr_qtatraso := TRUNC(rw_crapris.qtdiaatr / 30) + 1;
                  ELSE
                    -- Sem atraso
                    vr_qtatraso := 0;
                  END IF;
                ELSE
                  -- Número de prestações e quantidade em atraso é equivalente a quantidade de meses decorridos
                  vr_nroprest := vr_qtmesdec;
                  vr_qtatraso := vr_qtatraso;
                END IF;

              ELSE
                -- Apenas fechar o cursor
                CLOSE cr_crapepr;
                -- Limpar variáveis
                vr_vlpreemp := NULL;
                vr_cdlcremp := NULL;
                vr_cdfinemp := NULL;
                vr_tpemprst := NULL;
                vr_cdusolcr := NULL;
                vr_dsorgrec := NULL;
              END IF;

            END IF;

            -- Montar chave para tabela de riscos com Nro Prestação
            -- Agencia(5) + NroPrest(12) + NmPrimtl(60) + NrCtrEmp(10) + NrSeqCtr(5)
            -- NrdConta(10) + DtRefere(8) + InNivRis(5)
            vr_des_chave_crapris := LPAD(rw_crapris.cdagenci, 5, '0') ||
                                    to_char(999999.9999 - nvl(vr_nroprest, 0), '000000d0000') ||
                                    RPAD(rw_crapris.nmprimtl, 60, ' ') ||
                                    LPAD(rw_crapris.nrctremp, 10, '0') ||
                                    LPAD(rw_crapris.nrseqctr, 5, '0') ||
                                    LPAD(rw_crapris.nrdconta, 10, '0') ||
                                    to_char(rw_crapris.dtrefere, 'ddmmyyyy') ||
                                    LPAD(rw_crapris.innivris, 5, '0');

            -- Para conta corrente
          ELSIF rw_crapris.cdorigem = 1 THEN

            -- Limpar variaveis específicas de empréstimo
            vr_vlpreemp := NULL;
            vr_cdlcremp := NULL;
            vr_nroprest := NULL;
            vr_cdfinemp := NULL;
            vr_tpemprst := NULL;
            vr_qtatraso := 0;
            vr_qtdiaatr := 0;
            vr_cdusolcr := NULL;
            vr_dsorgrec := NULL;

            -- Buscar informaçoes do saldo da conta
            OPEN cr_crapsld(pr_nrdconta => rw_crapris.nrdconta);
            FETCH cr_crapsld
              INTO rw_crapsld;
            -- Se tiver encontrado
            IF cr_crapsld%FOUND THEN
              -- Utilizar o campo com a quantidade de dias com saldo negativo
              vr_qtatraso := rw_crapsld.qtdriclq;
            END IF;
            -- Fechar o cursor
            CLOSE cr_crapsld;

            -- Montar chave para tabela de riscos sem Nro Prestação
            -- Agencia(5) + NroPrest(12) + NmPrimtl(60) + NrCtrEmp(10) + NrSeqCtr(5)
            -- NrdConta(10) + DtRefere(8) + InNivRis(5)
            vr_des_chave_crapris := LPAD(rw_crapris.cdagenci, 5, '0') ||
                                    to_char(999999.9999, '000000d0000') ||
                                    RPAD(rw_crapris.nmprimtl, 60, ' ') ||
                                    LPAD(rw_crapris.nrctremp, 10, '0') ||
                                    LPAD(rw_crapris.nrseqctr, 5, '0') ||
                                    LPAD(rw_crapris.nrdconta, 10, '0') ||
                                    to_char(rw_crapris.dtrefere, 'ddmmyyyy') ||
                                    LPAD(rw_crapris.innivris, 5, '0');
          ELSE
            -- Limpar variaveis específicas de empréstimo
            vr_vlpreemp := NULL;
            vr_cdlcremp := NULL;
            vr_cdfinemp := NULL;
            vr_nroprest := NULL;
            vr_tpemprst := NULL;
            vr_qtatraso := 0;
            vr_qtdiaatr := 0;
            vr_cdusolcr := NULL;
            vr_dsorgrec := NULL;

            -- Montar chave para tabela de riscos sem Nro Prestação
            -- Agencia(5) + NroPrest(12) + NmPrimtl(60) + NrCtrEmp(10) + NrSeqCtr(5)
            -- NrdConta(10) + DtRefere(8) + InNivRis(5)
            vr_des_chave_crapris := LPAD(rw_crapris.cdagenci, 5, '0') ||
                                    to_char(999999.9999, '000000d0000') ||
                                    RPAD(rw_crapris.nmprimtl, 60, ' ') ||
                                    LPAD(rw_crapris.nrctremp, 10, '0') ||
                                    LPAD(rw_crapris.nrseqctr, 5, '0') ||
                                    LPAD(rw_crapris.nrdconta, 10, '0') ||
                                    to_char(rw_crapris.dtrefere, 'ddmmyyyy') ||
                                    LPAD(rw_crapris.innivris, 5, '0');

          END IF;

          -- Criar registro com as informações do risco
          vr_tab_crapris(vr_des_chave_crapris).cdagenci := rw_crapris.cdagenci;
          vr_tab_crapris(vr_des_chave_crapris).nroprest := vr_nroprest;
          vr_tab_crapris(vr_des_chave_crapris).nmprimtl := rw_crapris.nmprimtl;
          vr_tab_crapris(vr_des_chave_crapris).nrdconta := rw_crapris.nrdconta;
          vr_tab_crapris(vr_des_chave_crapris).nrcpfcgc := rw_crapris.nrcpfcgc;
          vr_tab_crapris(vr_des_chave_crapris).dtrefere := rw_crapris.dtrefere;
          vr_tab_crapris(vr_des_chave_crapris).innivris := rw_crapris.innivris;
          vr_tab_crapris(vr_des_chave_crapris).nrctremp := rw_crapris.nrctremp;
          vr_tab_crapris(vr_des_chave_crapris).cdmodali := rw_crapris.cdmodali;
          vr_tab_crapris(vr_des_chave_crapris).nrseqctr := rw_crapris.nrseqctr;
          vr_tab_crapris(vr_des_chave_crapris).vldivida := rw_crapris.vldivida;
          vr_tab_crapris(vr_des_chave_crapris).vljura60 := rw_crapris.vljura60;
          vr_tab_crapris(vr_des_chave_crapris).cdorigem := rw_crapris.cdorigem;
          vr_tab_crapris(vr_des_chave_crapris).inpessoa := rw_crapris.inpessoa;
          vr_tab_crapris(vr_des_chave_crapris).qtdriclq := rw_crapris.qtdriclq;
          vr_tab_crapris(vr_des_chave_crapris).vlpreemp := nvl(vr_vlpreemp, 0);
          vr_tab_crapris(vr_des_chave_crapris).cdlcremp := vr_cdlcremp;
          vr_tab_crapris(vr_des_chave_crapris).cdfinemp := vr_cdfinemp;
          vr_tab_crapris(vr_des_chave_crapris).qtatraso := vr_qtatraso;
          vr_tab_crapris(vr_des_chave_crapris).cdusolcr := vr_cdusolcr;
          vr_tab_crapris(vr_des_chave_crapris).dsorgrec := vr_dsorgrec;
          vr_tab_crapris(vr_des_chave_crapris).dtinictr := rw_crapris.dtinictr;
          vr_tab_crapris(vr_des_chave_crapris).inprejuz := rw_crapris.inprejuz;
          vr_tab_crapris(vr_des_chave_crapris).vliofmes := rw_crapsld.vliofmes;

          -- P577 - Inicio
          --vr_tot_vljurantpp := vr_tot_vljurantpp + nvl(rw_crapris.vljurantpp, 0);
          vr_tab_crapris(vr_des_chave_crapris).vljurantpp := rw_crapris.vljurantpp;
          vr_tab_crapris(vr_des_chave_crapris).vljurmorpp := rw_crapris.vljurmorpp;
          vr_tab_crapris(vr_des_chave_crapris).vljurmulpp := rw_crapris.vljurmulpp;
          --vr_vltotjur60 := vr_vltotjur60 + rw_crapris.vljura60;
          --vr_vltotjurant60 := vr_vltotjurant60 + rw_crapris.vljurantpp;
          -- P577 - Fim

          IF rw_crapris.cdorigem = 1 THEN
            -- conta corrente
            vr_tab_crapris(vr_des_chave_crapris).qtdiaatr := vr_qtatraso;
          ELSIF (rw_crapris.cdorigem IN (4,5)) THEN
            vr_tab_crapris(vr_des_chave_crapris).qtdiaatr := rw_crapris.qtdiaatr;
          ELSE
            vr_tab_crapris(vr_des_chave_crapris).qtdiaatr := vr_qtdiaatr;
          END IF;

          vr_tab_crapris(vr_des_chave_crapris).dsinfaux := rw_crapris.dsinfaux;
          vr_tab_crapris(vr_des_chave_crapris).tpemprst := vr_tpemprst;
          vr_tab_crapris(vr_des_chave_crapris).fleprces := nvl(vr_fleprces, 0);

          -- AWAE: Como Risco de Borderô hoje é tratado aqui, vou verificar aqui
          --       caso não fique OK, passar como ELSE do IF Maior.
          IF rw_crapris.cdorigem in (4,5) THEN -- Títulos C/Registro e S/Registro
            -- aqui vai ser aberto o cursor para os títulos e populado a vr_tab_craptdb.
            FOR rw_craptdb IN cr_craptdb(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_crapris.nrdconta
                                        ,pr_nrctremp => rw_crapris.nrctremp
                                        --,pr_dtinictr => rw_crapris.dtinictr
                                        ,pr_dtrefere => pr_dtrefere) LOOP --> ou pr_dtrefere (Verificar o que vai ser mais correto.)

              IF pr_flgrelat = 0 THEN
                -- calculando a chave para tabela da CYBER.
                CYBE0003.pc_inserir_titulo_cyber(pr_cdcooper => rw_craptdb.cdcooper
                                                ,pr_nrdconta => rw_craptdb.nrdconta
                                                ,pr_nrborder => rw_craptdb.nrborder
                                                ,pr_nrtitulo => rw_craptdb.nrtitulo
                                                ,pr_nrctrdsc => vr_nrctrdsc_tdb
                                                ,pr_dscritic => pr_dscritic);
              END IF;
              
              -- criando o indice da tabela temporaria
              vr_indice_tdb := LPAD(rw_craptdb.nrdconta, 10, '0') ||
                               LPAD(rw_craptdb.nrborder, 10, '0') ||
                               LPAD(rw_craptdb.nrtitulo, 10, '0');
              vr_tab_craptdb(vr_indice_tdb).nrdconta := rw_craptdb.nrdconta;
              vr_tab_craptdb(vr_indice_tdb).dtvencto := rw_craptdb.dtvencto;
              vr_tab_craptdb(vr_indice_tdb).qtdiaatr := NVL(pr_dtrefere - rw_craptdb.dtvencto,0);
              vr_tab_craptdb(vr_indice_tdb).qtmesdec := rw_craptdb.qtmesdec;
              vr_tab_craptdb(vr_indice_tdb).qtprepag := rw_craptdb.qtprepag;
              vr_tab_craptdb(vr_indice_tdb).vlprepag := rw_craptdb.vlprepag;
              vr_tab_craptdb(vr_indice_tdb).nrseqdig := rw_craptdb.nrseqdig;
              vr_tab_craptdb(vr_indice_tdb).cdoperad := rw_craptdb.cdoperad;
              vr_tab_craptdb(vr_indice_tdb).nrdocmto := rw_craptdb.nrdocmto;
              vr_tab_craptdb(vr_indice_tdb).nrctrlim := rw_craptdb.nrctrlim;
              vr_tab_craptdb(vr_indice_tdb).nrborder := rw_craptdb.nrborder;
              vr_tab_craptdb(vr_indice_tdb).vlliquid := rw_craptdb.vlliquid;
              vr_tab_craptdb(vr_indice_tdb).dtlibbdt := rw_craptdb.dtlibbdt;
              vr_tab_craptdb(vr_indice_tdb).cdcooper := rw_craptdb.cdcooper;
              vr_tab_craptdb(vr_indice_tdb).cdbandoc := rw_craptdb.cdbandoc;
              vr_tab_craptdb(vr_indice_tdb).nrdctabb := rw_craptdb.nrdctabb;
              vr_tab_craptdb(vr_indice_tdb).nrcnvcob := rw_craptdb.nrcnvcob;
              vr_tab_craptdb(vr_indice_tdb).cdoperes := rw_craptdb.cdoperes;
              vr_tab_craptdb(vr_indice_tdb).dtresgat := rw_craptdb.dtresgat;
              vr_tab_craptdb(vr_indice_tdb).vlliqres := rw_craptdb.vlliqres;
              vr_tab_craptdb(vr_indice_tdb).vltitulo := rw_craptdb.vltitulo;
              vr_tab_craptdb(vr_indice_tdb).insittit := rw_craptdb.insittit;
              vr_tab_craptdb(vr_indice_tdb).nrinssac := rw_craptdb.nrinssac;
              vr_tab_craptdb(vr_indice_tdb).dtdpagto := rw_craptdb.dtdpagto;
              vr_tab_craptdb(vr_indice_tdb).dtdebito := rw_craptdb.dtdebito;
              vr_tab_craptdb(vr_indice_tdb).dtrefatu := rw_craptdb.dtrefatu;
              vr_tab_craptdb(vr_indice_tdb).insitapr := rw_craptdb.insitapr;
              vr_tab_craptdb(vr_indice_tdb).cdoriapr := rw_craptdb.cdoriapr;
              vr_tab_craptdb(vr_indice_tdb).flgenvmc := rw_craptdb.flgenvmc;
              vr_tab_craptdb(vr_indice_tdb).insitmch := rw_craptdb.insitmch;
              vr_tab_craptdb(vr_indice_tdb).vlsldtit := rw_craptdb.vlsldtit;
              vr_tab_craptdb(vr_indice_tdb).nrtitulo := rw_craptdb.nrtitulo;
              vr_tab_craptdb(vr_indice_tdb).vliofprc := rw_craptdb.vliofprc;
              vr_tab_craptdb(vr_indice_tdb).vliofadc := rw_craptdb.vliofadc;
              vr_tab_craptdb(vr_indice_tdb).vliofcpl := rw_craptdb.vliofcpl;
              vr_tab_craptdb(vr_indice_tdb).vlmtatit := rw_craptdb.vlmtatit;
              vr_tab_craptdb(vr_indice_tdb).vlmratit := rw_craptdb.vlmratit;
              vr_tab_craptdb(vr_indice_tdb).vljura60 := rw_craptdb.vljura60;
              vr_tab_craptdb(vr_indice_tdb).vlpagiof := rw_craptdb.vlpagiof;
              vr_tab_craptdb(vr_indice_tdb).vlpagmta := rw_craptdb.vlpagmta;
              vr_tab_craptdb(vr_indice_tdb).vlpagmra := rw_craptdb.vlpagmra;
              vr_tab_craptdb(vr_indice_tdb).nrctrdsc := vr_nrctrdsc_tdb;
              vr_tab_craptdb(vr_indice_tdb).vlatraso := rw_craptdb.vlatraso;
              vr_tab_craptdb(vr_indice_tdb).vlsaldodev := rw_craptdb.vlsaldodev;
              vr_tab_craptdb(vr_indice_tdb).cddlinha := rw_craptdb.cddlinha;
              vr_tab_craptdb(vr_indice_tdb).dsdlinha := rw_craptdb.dsdlinha;
              vr_tab_craptdb(vr_indice_tdb).txmensal := rw_craptdb.txmensal;
              vr_tab_craptdb(vr_indice_tdb).txdiaria := rw_craptdb.txdiaria;
              -- Campos de Prejuizo
              vr_tab_craptdb(vr_indice_tdb).inprejuz := rw_craptdb.inprejuz;
              vr_tab_craptdb(vr_indice_tdb).dtprejuz := rw_craptdb.dtprejuz;
              vr_tab_craptdb(vr_indice_tdb).vlsdprej := rw_craptdb.vlsdprej;
            END LOOP;
          END IF; -- FIM DOS TITULOS DE BORDERÿ

        EXCEPTION
          WHEN vr_exc_ignorar THEN
            -- Exceção criada apenas para desviar o fluxo
            -- para este ponto e não processar o registro
            NULL;
        END;
      END LOOP; --FOR rw_crapris IN cr_crapris LOOP --> Termino leitura dos riscos

    END pc_busca_arq_controle_risco;

    PROCEDURE pc_popular_tbgen_batch_rel_wrk(pr_cdcooper     in tbgen_batch_relatorio_wrk.cdcooper%type,
                                             pr_nmtabmemoria in tbgen_batch_relatorio_wrk.cdprograma%type,
                                             pr_dtmvtolt     in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                             pr_cdagenci     in tbgen_batch_relatorio_wrk.cdagenci%type,

                                             pr_vlindice in tbgen_batch_relatorio_wrk.dschave%type,
                                             pr_dscritic  in tbgen_batch_relatorio_wrk.dscritic%type,
                                             pr_des_erro out varchar2) is
    begin
      insert into tbgen_batch_relatorio_wrk
        (cdcooper,
         cdprograma,
         dsrelatorio,
         dtmvtolt,
         cdagenci,
         nrdconta,
         dschave,
         dscritic)
      values
        (pr_cdcooper,
         pr_cdprogra,
         pr_nmtabmemoria,
         pr_dtmvtolt,
         99999,
         9999999999,
         pr_vlindice,
         pr_dscritic);

      commit;
    EXCEPTION
      WHEN OTHERS THEN
        --Montar mensagem de erro
        pr_des_erro := 'Erro ao inserir na tabela tbgen_batch_relatorio_wrk. ' || SQLERRM;
    END pc_popular_tbgen_batch_rel_wrk;

    PROCEDURE pc_grava_tab_wrk_dados_epr(pr_des_erro out varchar2) IS
      -- VR_TAB_DADOS_EPR
    BEGIN
      vr_indice_dados_epr := vr_tab_dados_epr.first;
      while vr_indice_dados_epr is not null loop
        vr_ds_xml := ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).cdagenci || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).nrdconta || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).nrctremp || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).vlpapgat || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).flgpagto || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).dtdpagto || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).vlsdevat || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).qtpcalat || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).txmensal || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).txjuremp || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).vlppagat || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).qtmdecat || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).inprejuz || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).inliquid || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).qtpreemp || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).cdlcremp || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).cdfinemp || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).dtmvtolt || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).vlemprst || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).tpdescto || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).vljurmes || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).dsorgrec || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).dtinictr || ds_character_separador;

        pc_popular_tbgen_batch_rel_wrk(pr_cdcooper     => pr_cdcooper,
                                       pr_nmtabmemoria => 'VR_TAB_DADOS_EPR',
                                       pr_dtmvtolt     => pr_rw_crapdat.dtmvtolt,
                                       pr_cdagenci     => vr_tab_dados_epr(vr_indice_dados_epr).cdagenci,
                                       pr_vlindice     => vr_indice_dados_epr,
                                       pr_dscritic     => vr_ds_xml,
                                       pr_des_erro     => vr_dscritic);
        vr_indice_dados_epr := vr_tab_dados_epr.next(vr_indice_dados_epr);
      end loop; -- vr_tab_dados_epr
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro PC_GRAVA_TAB_WRK_DADOS_EPR: ' || sqlerrm;
        dbms_output.put_line('erro :' || sqlerrm);
    END pc_grava_tab_wrk_dados_epr;

    PROCEDURE pc_grava_tab_men_dados_epr(pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                         pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                         pr_des_erro out varchar2) IS
      cursor c_dados_epr is
        select substr(tab.dsxml, instr(tab.dsxml, '#', 1, 1) + 1, instr(tab.dsxml, '#', 1, 2) - instr(tab.dsxml, '#', 1, 1) - 1) cdagenci,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 2) + 1, instr(tab.dsxml, '#', 1, 3) - instr(tab.dsxml, '#', 1, 2) - 1) nrdconta,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 3) + 1, instr(tab.dsxml, '#', 1, 4) - instr(tab.dsxml, '#', 1, 3) - 1) nrctremp,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 4) + 1, instr(tab.dsxml, '#', 1, 5) - instr(tab.dsxml, '#', 1, 4) - 1) vlpapgat,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 5) + 1, instr(tab.dsxml, '#', 1, 6) - instr(tab.dsxml, '#', 1, 5) - 1) flgpagto,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 6) + 1, instr(tab.dsxml, '#', 1, 7) - instr(tab.dsxml, '#', 1, 6) - 1) dtdpagto,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 7) + 1, instr(tab.dsxml, '#', 1, 8) - instr(tab.dsxml, '#', 1, 7) - 1) vlsdevat,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 8) + 1, instr(tab.dsxml, '#', 1, 9) - instr(tab.dsxml, '#', 1, 8) - 1) qtpcalat,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 9) + 1, instr(tab.dsxml, '#', 1, 10) - instr(tab.dsxml, '#', 1, 9) - 1) txmensal,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 10) + 1, instr(tab.dsxml, '#', 1, 11) - instr(tab.dsxml, '#', 1, 10) - 1) txjuremp,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 11) + 1, instr(tab.dsxml, '#', 1, 12) - instr(tab.dsxml, '#', 1, 11) - 1) vlppagat,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 12) + 1, instr(tab.dsxml, '#', 1, 13) - instr(tab.dsxml, '#', 1, 12) - 1) qtmdecat,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 13) + 1, instr(tab.dsxml, '#', 1, 14) - instr(tab.dsxml, '#', 1, 13) - 1) inprejuz,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 14) + 1, instr(tab.dsxml, '#', 1, 15) - instr(tab.dsxml, '#', 1, 14) - 1) inliquid,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 15) + 1, instr(tab.dsxml, '#', 1, 16) - instr(tab.dsxml, '#', 1, 15) - 1) qtpreemp,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 16) + 1, instr(tab.dsxml, '#', 1, 17) - instr(tab.dsxml, '#', 1, 16) - 1) cdlcremp,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 17) + 1, instr(tab.dsxml, '#', 1, 18) - instr(tab.dsxml, '#', 1, 17) - 1) cdfinemp,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 18) + 1, instr(tab.dsxml, '#', 1, 19) - instr(tab.dsxml, '#', 1, 18) - 1) dtmvtolt,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 19) + 1, instr(tab.dsxml, '#', 1, 20) - instr(tab.dsxml, '#', 1, 19) - 1) vlemprst,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 20) + 1, instr(tab.dsxml, '#', 1, 21) - instr(tab.dsxml, '#', 1, 20) - 1) tpdescto,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 21) + 1, instr(tab.dsxml, '#', 1, 22) - instr(tab.dsxml, '#', 1, 21) - 1) vljurmes,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 22) + 1, instr(tab.dsxml, '#', 1, 23) - instr(tab.dsxml, '#', 1, 22) - 1) dsorgrec,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 23) + 1, instr(tab.dsxml, '#', 1, 24) - instr(tab.dsxml, '#', 1, 23) - 1) dtinictr,
               tab.dschave vr_indice
          from (select wrk.dscritic dsxml,
                       wrk.dschave
                  from tbgen_batch_relatorio_wrk wrk
                 where wrk.cdcooper = pr_cdcooper
                   and wrk.cdprograma = pr_cdprogra
                   and wrk.dsrelatorio = 'VR_TAB_DADOS_EPR'
                   and wrk.dtmvtolt = pr_dtmvtolt
                   and wrk.cdagenci = 99999
                   and wrk.nrdconta = 9999999999) tab;
    BEGIN
      BEGIN
        FOR r_dados_epr IN c_dados_epr LOOP
          --Criar registro na dados_epr
          vr_tab_dados_epr(r_dados_epr.vr_indice).cdagenci := r_dados_epr.cdagenci;
          vr_tab_dados_epr(r_dados_epr.vr_indice).nrdconta := r_dados_epr.nrdconta;
          vr_tab_dados_epr(r_dados_epr.vr_indice).nrctremp := r_dados_epr.nrctremp;
          vr_tab_dados_epr(r_dados_epr.vr_indice).vlpapgat := r_dados_epr.vlpapgat;
          vr_tab_dados_epr(r_dados_epr.vr_indice).flgpagto := r_dados_epr.flgpagto;
          vr_tab_dados_epr(r_dados_epr.vr_indice).dtdpagto := r_dados_epr.dtdpagto;
          vr_tab_dados_epr(r_dados_epr.vr_indice).vlsdevat := r_dados_epr.vlsdevat;
          vr_tab_dados_epr(r_dados_epr.vr_indice).qtpcalat := r_dados_epr.qtpcalat;
          vr_tab_dados_epr(r_dados_epr.vr_indice).txmensal := r_dados_epr.txmensal;
          vr_tab_dados_epr(r_dados_epr.vr_indice).txjuremp := r_dados_epr.txjuremp;
          vr_tab_dados_epr(r_dados_epr.vr_indice).vlppagat := r_dados_epr.vlppagat;
          vr_tab_dados_epr(r_dados_epr.vr_indice).qtmdecat := r_dados_epr.qtmdecat;
          vr_tab_dados_epr(r_dados_epr.vr_indice).inprejuz := r_dados_epr.inprejuz;
          vr_tab_dados_epr(r_dados_epr.vr_indice).inliquid := r_dados_epr.inliquid;
          vr_tab_dados_epr(r_dados_epr.vr_indice).qtpreemp := r_dados_epr.qtpreemp;
          vr_tab_dados_epr(r_dados_epr.vr_indice).cdlcremp := r_dados_epr.cdlcremp;
          vr_tab_dados_epr(r_dados_epr.vr_indice).cdfinemp := r_dados_epr.cdfinemp;
          vr_tab_dados_epr(r_dados_epr.vr_indice).dtmvtolt := r_dados_epr.dtmvtolt;
          vr_tab_dados_epr(r_dados_epr.vr_indice).vlemprst := r_dados_epr.vlemprst;
          vr_tab_dados_epr(r_dados_epr.vr_indice).vljurmes := r_dados_epr.vljurmes;
          vr_tab_dados_epr(r_dados_epr.vr_indice).dsorgrec := r_dados_epr.dsorgrec;
          vr_tab_dados_epr(r_dados_epr.vr_indice).dtinictr := r_dados_epr.dtinictr;
          vr_tab_dados_epr(r_dados_epr.vr_indice).dtdpagto := r_dados_epr.dtdpagto;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          pr_des_erro := 'Erro pc_grava_tab_men_dados_epr: ' || sqlerrm;
      END;
    END pc_grava_tab_men_dados_epr;

    PROCEDURE pc_grava_tab_wrk_crapris(pr_des_erro out varchar2) IS
      -- VR_TAB_CRAPRIS
    BEGIN
      vr_indice_crapris := vr_tab_crapris.first;
      while vr_indice_crapris is not null loop
        vr_ds_xml := ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdagenci || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nroprest || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nmprimtl || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nrdconta || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nrcpfcgc || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).dtrefere || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).innivris || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nrctremp || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdmodali || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nrseqctr || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).vldivida || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).vljura60 || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdorigem || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).inpessoa || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).qtdriclq || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).vlpreemp || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdlcremp || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdfinemp || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).qtatraso || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdusolcr || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).dsorgrec || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).dtinictr || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).qtdiaatr || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).dsinfaux || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).tpemprst || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).fleprces || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).vliofmes || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).inprejuz || ds_character_separador ||
                     -- P577 - Inicio
                     vr_tab_crapris(vr_indice_crapris).vljurantpp || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).vljurmorpp || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).vljurmulpp || ds_character_separador;
                     -- P577 - Fim
        pc_popular_tbgen_batch_rel_wrk(pr_cdcooper     => pr_cdcooper,
                                       pr_nmtabmemoria => 'VR_TAB_CRAPRIS',
                                       pr_dtmvtolt     => pr_rw_crapdat.dtmvtolt,
                                       pr_cdagenci     => vr_tab_crapris(vr_indice_crapris).cdagenci,
                                       pr_vlindice     => vr_indice_crapris,
                                       pr_dscritic     => vr_ds_xml,
                                       pr_des_erro     => vr_dscritic);
        vr_indice_crapris:= vr_tab_crapris.next(vr_indice_crapris);
      end loop; -- vr_tab_crapris
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro PC_GRAVA_TAB_WRK_CRAPRIS: ' || sqlerrm;
        dbms_output.put_line('erro :' || sqlerrm);
    END pc_grava_tab_wrk_crapris;

    PROCEDURE pc_grava_tab_men_crapris(pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                       pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                       pr_des_erro out varchar2) IS
      cursor c_crapris is
        select substr(tab.dsxml, instr(tab.dsxml, '#', 1, 1) + 1, instr(tab.dsxml, '#', 1, 2) - instr(tab.dsxml, '#', 1, 1) - 1) cdagenci,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 2) + 1, instr(tab.dsxml, '#', 1, 3) - instr(tab.dsxml, '#', 1, 2) - 1) nroprest,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 3) + 1, instr(tab.dsxml, '#', 1, 4) - instr(tab.dsxml, '#', 1, 3) - 1) nmprimtl,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 4) + 1, instr(tab.dsxml, '#', 1, 5) - instr(tab.dsxml, '#', 1, 4) - 1) nrdconta,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 5) + 1, instr(tab.dsxml, '#', 1, 6) - instr(tab.dsxml, '#', 1, 5) - 1) nrcpfcgc,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 6) + 1, instr(tab.dsxml, '#', 1, 7) - instr(tab.dsxml, '#', 1, 6) - 1) dtrefere,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 7) + 1, instr(tab.dsxml, '#', 1, 8) - instr(tab.dsxml, '#', 1, 7) - 1) innivris,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 8) + 1, instr(tab.dsxml, '#', 1, 9) - instr(tab.dsxml, '#', 1, 8) - 1) nrctremp,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 9) + 1, instr(tab.dsxml, '#', 1, 10) - instr(tab.dsxml, '#', 1, 9) - 1) cdmodali,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 10) + 1, instr(tab.dsxml, '#', 1, 11) - instr(tab.dsxml, '#', 1, 10) - 1) nrseqctr,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 11) + 1, instr(tab.dsxml, '#', 1, 12) - instr(tab.dsxml, '#', 1, 11) - 1) vldivida,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 12) + 1, instr(tab.dsxml, '#', 1, 13) - instr(tab.dsxml, '#', 1, 12) - 1) vljura60,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 13) + 1, instr(tab.dsxml, '#', 1, 14) - instr(tab.dsxml, '#', 1, 13) - 1) cdorigem,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 14) + 1, instr(tab.dsxml, '#', 1, 15) - instr(tab.dsxml, '#', 1, 14) - 1) inpessoa,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 15) + 1, instr(tab.dsxml, '#', 1, 16) - instr(tab.dsxml, '#', 1, 15) - 1) qtdriclq,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 16) + 1, instr(tab.dsxml, '#', 1, 17) - instr(tab.dsxml, '#', 1, 16) - 1) vlpreemp,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 17) + 1, instr(tab.dsxml, '#', 1, 18) - instr(tab.dsxml, '#', 1, 17) - 1) cdlcremp,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 18) + 1, instr(tab.dsxml, '#', 1, 19) - instr(tab.dsxml, '#', 1, 18) - 1) cdfinemp,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 19) + 1, instr(tab.dsxml, '#', 1, 20) - instr(tab.dsxml, '#', 1, 19) - 1) qtatraso,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 20) + 1, instr(tab.dsxml, '#', 1, 21) - instr(tab.dsxml, '#', 1, 20) - 1) cdusolcr,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 21) + 1, instr(tab.dsxml, '#', 1, 22) - instr(tab.dsxml, '#', 1, 21) - 1) dsorgrec,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 22) + 1, instr(tab.dsxml, '#', 1, 23) - instr(tab.dsxml, '#', 1, 22) - 1) dtinictr,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 23) + 1, instr(tab.dsxml, '#', 1, 24) - instr(tab.dsxml, '#', 1, 23) - 1) qtdiaatr,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 24) + 1, instr(tab.dsxml, '#', 1, 25) - instr(tab.dsxml, '#', 1, 24) - 1) dsinfaux,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 25) + 1, instr(tab.dsxml, '#', 1, 26) - instr(tab.dsxml, '#', 1, 25) - 1) tpemprst,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 26) + 1, instr(tab.dsxml, '#', 1, 27) - instr(tab.dsxml, '#', 1, 26) - 1) fleprces,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 27) + 1, instr(tab.dsxml, '#', 1, 28) - instr(tab.dsxml, '#', 1, 27) - 1) vliofmes,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 28) + 1, instr(tab.dsxml, '#', 1, 29) - instr(tab.dsxml, '#', 1, 28) - 1) inprejuz,
               -- P577 - Inicio
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 29) + 1, instr(tab.dsxml, '#', 1, 30) - instr(tab.dsxml, '#', 1, 29) - 1) vljurantpp,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 30) + 1, instr(tab.dsxml, '#', 1, 31) - instr(tab.dsxml, '#', 1, 30) - 1) vljurmorpp,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 31) + 1, instr(tab.dsxml, '#', 1, 32) - instr(tab.dsxml, '#', 1, 31) - 1) vljurmulpp,
               -- P577 - Fim
               tab.dschave vr_indice
          from (select wrk.dscritic dsxml,
                       wrk.dschave
                  from tbgen_batch_relatorio_wrk wrk
                 where wrk.cdcooper = pr_cdcooper
                   and wrk.cdprograma = pr_cdprogra
                   and wrk.dsrelatorio = 'VR_TAB_CRAPRIS'
                   and wrk.dtmvtolt = pr_dtmvtolt
                   and wrk.cdagenci = 99999
                   and wrk.nrdconta = 9999999999) tab;
    BEGIN
      BEGIN
        FOR r_crapris IN c_crapris LOOP
          --Criar registro na crapris
          vr_tab_crapris(r_crapris.vr_indice).cdagenci := r_crapris.cdagenci;
          vr_tab_crapris(r_crapris.vr_indice).nroprest := r_crapris.nroprest;
          vr_tab_crapris(r_crapris.vr_indice).nmprimtl := r_crapris.nmprimtl;
          vr_tab_crapris(r_crapris.vr_indice).nrdconta := r_crapris.nrdconta;
          vr_tab_crapris(r_crapris.vr_indice).nrcpfcgc := r_crapris.nrcpfcgc;
          vr_tab_crapris(r_crapris.vr_indice).dtrefere := r_crapris.dtrefere;
          vr_tab_crapris(r_crapris.vr_indice).innivris := r_crapris.innivris;
          vr_tab_crapris(r_crapris.vr_indice).nrctremp := r_crapris.nrctremp;
          vr_tab_crapris(r_crapris.vr_indice).cdmodali := r_crapris.cdmodali;
          vr_tab_crapris(r_crapris.vr_indice).nrseqctr := r_crapris.nrseqctr;
          vr_tab_crapris(r_crapris.vr_indice).vldivida := r_crapris.vldivida;
          vr_tab_crapris(r_crapris.vr_indice).vljura60 := r_crapris.vljura60;
          vr_tab_crapris(r_crapris.vr_indice).cdorigem := r_crapris.cdorigem;
          vr_tab_crapris(r_crapris.vr_indice).inpessoa := r_crapris.inpessoa;
          vr_tab_crapris(r_crapris.vr_indice).qtdriclq := r_crapris.qtdriclq;
          vr_tab_crapris(r_crapris.vr_indice).vlpreemp := r_crapris.vlpreemp;
          vr_tab_crapris(r_crapris.vr_indice).cdlcremp := r_crapris.cdlcremp;
          vr_tab_crapris(r_crapris.vr_indice).cdfinemp := r_crapris.cdfinemp;
          vr_tab_crapris(r_crapris.vr_indice).qtatraso := r_crapris.qtatraso;
          vr_tab_crapris(r_crapris.vr_indice).cdusolcr := r_crapris.cdusolcr;
          vr_tab_crapris(r_crapris.vr_indice).dsorgrec := r_crapris.dsorgrec;
          vr_tab_crapris(r_crapris.vr_indice).dtinictr := r_crapris.dtinictr;
          vr_tab_crapris(r_crapris.vr_indice).qtdiaatr := r_crapris.qtdiaatr;
          vr_tab_crapris(r_crapris.vr_indice).dsinfaux := r_crapris.dsinfaux;
          vr_tab_crapris(r_crapris.vr_indice).tpemprst := r_crapris.tpemprst;
          vr_tab_crapris(r_crapris.vr_indice).fleprces := r_crapris.fleprces;
          vr_tab_crapris(r_crapris.vr_indice).vliofmes := r_crapris.vliofmes;
          vr_tab_crapris(r_crapris.vr_indice).inprejuz := r_crapris.inprejuz;
          -- P577 - Inicio
          vr_tab_crapris(r_crapris.vr_indice).vljurantpp := r_crapris.vljurantpp;
          vr_tab_crapris(r_crapris.vr_indice).vljurmorpp := r_crapris.vljurmorpp;
          vr_tab_crapris(r_crapris.vr_indice).vljurmulpp := r_crapris.vljurmulpp;
          -- P577 - Fim
          --vr_tab_dados_epr(r_dados_epr.vr_indice).vlindice:= r_dados_epr.vr_indice;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          pr_des_erro := 'Erro pc_grava_tab_men_crapris: ' || sqlerrm;
      END;
    END pc_grava_tab_men_crapris;

    --awae: rotina para tabela wrk de Titulos de Borderô
    PROCEDURE pc_grava_tab_wrk_dados_tdb(pr_des_erro out varchar2) IS
      -- VR_TAB_CRAPTDB
    BEGIN
      vr_indice_dados_tdb := vr_tab_craptdb.first;
      while vr_indice_dados_tdb is not null loop
        vr_ds_xml := ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).nrdconta || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).dtvencto || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).nrseqdig || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).cdoperad || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).nrdocmto || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).nrctrlim || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).nrborder || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vlliquid || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).dtlibbdt || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).cdcooper || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).cdbandoc || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).nrdctabb || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).nrcnvcob || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).cdoperes || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).dtresgat || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vlliqres || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vltitulo || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).insittit || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).nrinssac || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).dtdpagto || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).dtdebito || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).dtrefatu || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).insitapr || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).cdoriapr || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).flgenvmc || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).insitmch || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vlsldtit || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).nrtitulo || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vliofprc || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vliofadc || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vliofcpl || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vlmtatit || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vlmratit || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vljura60 || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vlpagiof || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vlpagmta || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vlpagmra || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).nrctrdsc || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vlatraso || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vlsaldodev || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).cddlinha || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).dsdlinha || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).txmensal || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).inprejuz || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).dtprejuz || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).vlsdprej || ds_character_separador ||
                      vr_tab_craptdb(vr_indice_dados_tdb).qtdiaatr || ds_character_separador;

        pc_popular_tbgen_batch_rel_wrk(pr_cdcooper     => pr_cdcooper,
                                       pr_nmtabmemoria => 'VR_TAB_CRAPTDB',
                                       pr_dtmvtolt     => pr_rw_crapdat.dtmvtolt,
                                       pr_cdagenci     => 99999,
                                       pr_vlindice     => vr_indice_dados_tdb,
                                       pr_dscritic     => vr_ds_xml,
                                       pr_des_erro     => vr_dscritic);
        vr_indice_dados_tdb := vr_tab_craptdb.next(vr_indice_dados_tdb);
      end loop; -- VR_TAB_CRAPTDB
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro PC_GRAVA_TAB_WRK_DADOS_TDB: ' || sqlerrm;
        dbms_output.put_line('erro :' || sqlerrm);
        pc_internal_exception(pr_compleme => vr_indice_dados_tdb);
    END pc_grava_tab_wrk_dados_tdb;

    --awae: rotina para tabela mem de Titulos de Borderô
    PROCEDURE pc_grava_tab_men_dados_tdb(pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                         pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                         pr_des_erro out varchar2) IS
      cursor cr_dados_tdb is
        select substr(tab.dsxml, instr(tab.dsxml, '#', 1, 1) + 1, instr(tab.dsxml, '#', 1, 2) - instr(tab.dsxml, '#', 1, 1) - 1) nrdconta,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 2) + 1, instr(tab.dsxml, '#', 1, 3) - instr(tab.dsxml, '#', 1, 2) - 1) dtvencto,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 3) + 1, instr(tab.dsxml, '#', 1, 4) - instr(tab.dsxml, '#', 1, 3) - 1) nrseqdig,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 4) + 1, instr(tab.dsxml, '#', 1, 5) - instr(tab.dsxml, '#', 1, 4) - 1) cdoperad,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 5) + 1, instr(tab.dsxml, '#', 1, 6) - instr(tab.dsxml, '#', 1, 5) - 1) nrdocmto,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 6) + 1, instr(tab.dsxml, '#', 1, 7) - instr(tab.dsxml, '#', 1, 6) - 1) nrctrlim,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 7) + 1, instr(tab.dsxml, '#', 1, 8) - instr(tab.dsxml, '#', 1, 7) - 1) nrborder,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 8) + 1, instr(tab.dsxml, '#', 1, 9) - instr(tab.dsxml, '#', 1, 8) - 1) vlliquid,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 9) + 1, instr(tab.dsxml, '#', 1, 10) - instr(tab.dsxml, '#', 1, 9) - 1) dtlibbdt,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 10) + 1, instr(tab.dsxml, '#', 1, 11) - instr(tab.dsxml, '#', 1, 10) - 1) cdcooper,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 11) + 1, instr(tab.dsxml, '#', 1, 12) - instr(tab.dsxml, '#', 1, 11) - 1) cdbandoc,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 12) + 1, instr(tab.dsxml, '#', 1, 13) - instr(tab.dsxml, '#', 1, 12) - 1) nrdctabb,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 13) + 1, instr(tab.dsxml, '#', 1, 14) - instr(tab.dsxml, '#', 1, 13) - 1) nrcnvcob,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 14) + 1, instr(tab.dsxml, '#', 1, 15) - instr(tab.dsxml, '#', 1, 14) - 1) cdoperes,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 15) + 1, instr(tab.dsxml, '#', 1, 16) - instr(tab.dsxml, '#', 1, 15) - 1) dtresgat,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 16) + 1, instr(tab.dsxml, '#', 1, 17) - instr(tab.dsxml, '#', 1, 16) - 1) vlliqres,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 17) + 1, instr(tab.dsxml, '#', 1, 18) - instr(tab.dsxml, '#', 1, 17) - 1) vltitulo,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 18) + 1, instr(tab.dsxml, '#', 1, 19) - instr(tab.dsxml, '#', 1, 18) - 1) insittit,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 19) + 1, instr(tab.dsxml, '#', 1, 20) - instr(tab.dsxml, '#', 1, 19) - 1) nrinssac,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 20) + 1, instr(tab.dsxml, '#', 1, 21) - instr(tab.dsxml, '#', 1, 20) - 1) dtdpagto,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 21) + 1, instr(tab.dsxml, '#', 1, 22) - instr(tab.dsxml, '#', 1, 21) - 1) dtdebito,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 22) + 1, instr(tab.dsxml, '#', 1, 23) - instr(tab.dsxml, '#', 1, 22) - 1) dtrefatu,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 23) + 1, instr(tab.dsxml, '#', 1, 24) - instr(tab.dsxml, '#', 1, 23) - 1) insitapr,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 24) + 1, instr(tab.dsxml, '#', 1, 25) - instr(tab.dsxml, '#', 1, 24) - 1) cdoriapr,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 25) + 1, instr(tab.dsxml, '#', 1, 26) - instr(tab.dsxml, '#', 1, 25) - 1) flgenvmc,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 26) + 1, instr(tab.dsxml, '#', 1, 27) - instr(tab.dsxml, '#', 1, 26) - 1) insitmch,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 27) + 1, instr(tab.dsxml, '#', 1, 28) - instr(tab.dsxml, '#', 1, 27) - 1) vlsldtit,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 28) + 1, instr(tab.dsxml, '#', 1, 29) - instr(tab.dsxml, '#', 1, 28) - 1) nrtitulo,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 29) + 1, instr(tab.dsxml, '#', 1, 30) - instr(tab.dsxml, '#', 1, 29) - 1) vliofprc,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 30) + 1, instr(tab.dsxml, '#', 1, 31) - instr(tab.dsxml, '#', 1, 30) - 1) vliofadc,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 31) + 1, instr(tab.dsxml, '#', 1, 32) - instr(tab.dsxml, '#', 1, 31) - 1) vliofcpl,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 32) + 1, instr(tab.dsxml, '#', 1, 33) - instr(tab.dsxml, '#', 1, 32) - 1) vlmtatit,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 33) + 1, instr(tab.dsxml, '#', 1, 34) - instr(tab.dsxml, '#', 1, 33) - 1) vlmratit,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 34) + 1, instr(tab.dsxml, '#', 1, 35) - instr(tab.dsxml, '#', 1, 34) - 1) vljura60,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 35) + 1, instr(tab.dsxml, '#', 1, 36) - instr(tab.dsxml, '#', 1, 35) - 1) vlpagiof,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 36) + 1, instr(tab.dsxml, '#', 1, 37) - instr(tab.dsxml, '#', 1, 36) - 1) vlpagmta,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 37) + 1, instr(tab.dsxml, '#', 1, 38) - instr(tab.dsxml, '#', 1, 37) - 1) vlpagmra,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 38) + 1, instr(tab.dsxml, '#', 1, 39) - instr(tab.dsxml, '#', 1, 38) - 1) nrctrdsc,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 39) + 1, instr(tab.dsxml, '#', 1, 40) - instr(tab.dsxml, '#', 1, 39) - 1) vlatraso,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 40) + 1, instr(tab.dsxml, '#', 1, 41) - instr(tab.dsxml, '#', 1, 40) - 1) vlsaldodev,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 41) + 1, instr(tab.dsxml, '#', 1, 42) - instr(tab.dsxml, '#', 1, 41) - 1) cddlinha,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 42) + 1, instr(tab.dsxml, '#', 1, 43) - instr(tab.dsxml, '#', 1, 42) - 1) dsdlinha,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 43) + 1, instr(tab.dsxml, '#', 1, 44) - instr(tab.dsxml, '#', 1, 43) - 1) txmensal,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 44) + 1, instr(tab.dsxml, '#', 1, 45) - instr(tab.dsxml, '#', 1, 44) - 1) inprejuz,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 45) + 1, instr(tab.dsxml, '#', 1, 46) - instr(tab.dsxml, '#', 1, 45) - 1) dtprejuz,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 46) + 1, instr(tab.dsxml, '#', 1, 47) - instr(tab.dsxml, '#', 1, 46) - 1) vlsdprej,
               substr(tab.dsxml, instr(tab.dsxml, '#', 1, 47) + 1, instr(tab.dsxml, '#', 1, 48) - instr(tab.dsxml, '#', 1, 47) - 1) qtdiaatr,
               
               tab.dschave vr_indice
          from (select wrk.dscritic dsxml,
                       wrk.dschave
                  from tbgen_batch_relatorio_wrk wrk
                 where wrk.cdcooper = pr_cdcooper
                   and wrk.cdprograma = pr_cdprogra
                   and wrk.dsrelatorio = 'VR_TAB_CRAPTDB'
                   and wrk.dtmvtolt = pr_dtmvtolt
                   and wrk.cdagenci = 99999
                   and wrk.nrdconta = 9999999999) tab;

       r_dados_tdb cr_dados_tdb%ROWTYPE;
       vr_indice_tdbtmp r_dados_tdb.vr_indice%TYPE;

    BEGIN
      BEGIN
        FOR r_dados_tdb IN cr_dados_tdb LOOP
          vr_indice_tdbtmp := r_dados_tdb.vr_indice;
          --Criar registro na vr_tab_craptdb
          vr_tab_craptdb(r_dados_tdb.vr_indice).nrdconta := r_dados_tdb.nrdconta;
          vr_tab_craptdb(r_dados_tdb.vr_indice).dtvencto := r_dados_tdb.dtvencto;
          vr_tab_craptdb(r_dados_tdb.vr_indice).nrseqdig := r_dados_tdb.nrseqdig;
          vr_tab_craptdb(r_dados_tdb.vr_indice).cdoperad := r_dados_tdb.cdoperad;
          vr_tab_craptdb(r_dados_tdb.vr_indice).nrdocmto := r_dados_tdb.nrdocmto;
          vr_tab_craptdb(r_dados_tdb.vr_indice).nrctrlim := r_dados_tdb.nrctrlim;
          vr_tab_craptdb(r_dados_tdb.vr_indice).nrborder := r_dados_tdb.nrborder;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vlliquid := r_dados_tdb.vlliquid;
          vr_tab_craptdb(r_dados_tdb.vr_indice).dtlibbdt := r_dados_tdb.dtlibbdt;
          vr_tab_craptdb(r_dados_tdb.vr_indice).cdcooper := r_dados_tdb.cdcooper;
          vr_tab_craptdb(r_dados_tdb.vr_indice).cdbandoc := r_dados_tdb.cdbandoc;
          vr_tab_craptdb(r_dados_tdb.vr_indice).nrdctabb := r_dados_tdb.nrdctabb;
          vr_tab_craptdb(r_dados_tdb.vr_indice).nrcnvcob := r_dados_tdb.nrcnvcob;
          vr_tab_craptdb(r_dados_tdb.vr_indice).cdoperes := r_dados_tdb.cdoperes;
          vr_tab_craptdb(r_dados_tdb.vr_indice).dtresgat := r_dados_tdb.dtresgat;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vlliqres := r_dados_tdb.vlliqres;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vltitulo := r_dados_tdb.vltitulo;
          vr_tab_craptdb(r_dados_tdb.vr_indice).insittit := r_dados_tdb.insittit;
          vr_tab_craptdb(r_dados_tdb.vr_indice).nrinssac := r_dados_tdb.nrinssac;
          vr_tab_craptdb(r_dados_tdb.vr_indice).dtdpagto := r_dados_tdb.dtdpagto;
          vr_tab_craptdb(r_dados_tdb.vr_indice).dtdebito := r_dados_tdb.dtdebito;
          vr_tab_craptdb(r_dados_tdb.vr_indice).dtrefatu := r_dados_tdb.dtrefatu;
          vr_tab_craptdb(r_dados_tdb.vr_indice).insitapr := r_dados_tdb.insitapr;
          vr_tab_craptdb(r_dados_tdb.vr_indice).cdoriapr := r_dados_tdb.cdoriapr;
          vr_tab_craptdb(r_dados_tdb.vr_indice).flgenvmc := r_dados_tdb.flgenvmc;
          vr_tab_craptdb(r_dados_tdb.vr_indice).insitmch := r_dados_tdb.insitmch;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vlsldtit := r_dados_tdb.vlsldtit;
          vr_tab_craptdb(r_dados_tdb.vr_indice).nrtitulo := r_dados_tdb.nrtitulo;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vliofprc := r_dados_tdb.vliofprc;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vliofadc := r_dados_tdb.vliofadc;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vliofcpl := r_dados_tdb.vliofcpl;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vlmtatit := r_dados_tdb.vlmtatit;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vlmratit := r_dados_tdb.vlmratit;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vljura60 := r_dados_tdb.vljura60;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vlpagiof := r_dados_tdb.vlpagiof;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vlpagmta := r_dados_tdb.vlpagmta;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vlpagmra := r_dados_tdb.vlpagmra;
          vr_tab_craptdb(r_dados_tdb.vr_indice).nrctrdsc := r_dados_tdb.nrctrdsc;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vlatraso := r_dados_tdb.vlatraso;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vlsaldodev := r_dados_tdb.vlsaldodev;
          vr_tab_craptdb(r_dados_tdb.vr_indice).cddlinha := r_dados_tdb.cddlinha;
          vr_tab_craptdb(r_dados_tdb.vr_indice).dsdlinha := r_dados_tdb.dsdlinha;
          vr_tab_craptdb(r_dados_tdb.vr_indice).txmensal := r_dados_tdb.txmensal;
          vr_tab_craptdb(r_dados_tdb.vr_indice).inprejuz := r_dados_tdb.inprejuz;
          vr_tab_craptdb(r_dados_tdb.vr_indice).dtprejuz := r_dados_tdb.dtprejuz;
          vr_tab_craptdb(r_dados_tdb.vr_indice).vlsdprej := r_dados_tdb.vlsdprej;
          vr_tab_craptdb(r_dados_tdb.vr_indice).qtdiaatr := r_dados_tdb.qtdiaatr;
        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Erro pc_grava_tab_men_dados_tdb: ' || sqlerrm;
          pc_internal_exception(pr_compleme => vr_indice_tdbtmp);
      END;
    END pc_grava_tab_men_dados_tdb;

    ---------------------------------------
    -- Inicio Bloco Principal PC_CRPS280_I_WAG
    ---------------------------------------

  BEGIN
    -- Limpar as tabelas geradas no processo
    vr_tab_erro.DELETE;
    vr_tab_risco.DELETE;
    vr_tab_risco_aux.DELETE;
    vr_tab_crapris.DELETE;
    vr_tab_totrispac.DELETE;
    vr_tab_totrisger.DELETE;
    vr_tab_contab.DELETE;
    vr_tab_microcredito.DELETE;
    vr_tab_miccred_fin.DELETE;
    vr_tab_miccred_nivris.DELETE;
    vr_tab_pese_nivris.DELETE;

    -- Inicializar pl-table
    pc_inicializa_pltable;

    -- Quando for rodado pelo programa crps184, deverá ser gerado o relatorio no mesmo instante
    IF pr_cdprogra = 'CRPS184' THEN
      vr_flgerar := 'S';
    END IF;

    -- Para os programas em paralelo devemos buscar o array crapdat.
    -- Leitura do calendário da cooperativa
    IF pr_rw_crapdat.dtmvtolt IS NULL THEN
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO pr_rw_crapdat;
      CLOSE btch0001.cr_crapdat;
    END IF;
		
      IF pr_idparale = 0 THEN	  

			-- Leitura das descricoes de risco A,B,C etc e percentuais
		  FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper
									  ,pr_nmsistem => 'CRED'
									  ,pr_tptabela => 'GENERI'
									  ,pr_cdempres => 00
									  ,pr_cdacesso => 'PROVISAOCL'
									  ,pr_tpregist => 0) LOOP
				-- Para cada registro, buscar o contador atual na posição 12
			 vr_contador := SUBSTR(rw_craptab.dstextab,12,2);
				-- Adicionar na tabela as informações de descrição e percentuais
			 vr_tab_risco(vr_contador).dsdrisco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
			 vr_tab_risco(vr_contador).percentu := SUBSTR(rw_craptab.dstextab,1,6);
			 vr_tab_risco_aux(vr_contador).dsdrisco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
			 vr_tab_risco_aux(vr_contador).percentu := SUBSTR(rw_craptab.dstextab,1,6);
			END LOOP;

			-- Alimentar variavel para nao ser preciso criar registro na PROVISAOCL
		  vr_tab_risco(10).dsdrisco     := 'HH';
		  vr_tab_risco(10).percentu     := 0;
			vr_tab_risco_aux(10).dsdrisco := 'H';
			vr_tab_risco_aux(10).percentu := 0;

			-- Buscar o primeiro registro com tpregist >= 0
		  OPEN cr_craptab(pr_cdcooper => pr_cdcooper
						 ,pr_nmsistem => 'CRED'
						 ,pr_tptabela => 'GENERI'
						 ,pr_cdempres => 00
						 ,pr_cdacesso => 'PROVISAOCL'
						 ,pr_tpregist => 0);
			FETCH cr_craptab
				INTO rw_craptab;
			-- Se não encontrar
			IF cr_craptab%NOTFOUND THEN
				-- Utilizar percentual = 100
				vr_percbase := 100;
			ELSE
				-- Utilizar o percentual encontrado
			 vr_percbase := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,1,6));
			END IF;
			CLOSE cr_craptab;

			-- Leitura do indicador de uso da tabela de taxa de juros
			rw_craptab := NULL;
		  OPEN cr_craptab(pr_cdcooper => pr_cdcooper
						 ,pr_nmsistem => 'CRED'
						 ,pr_tptabela => 'USUARI'
						 ,pr_cdempres => 11
						 ,pr_cdacesso => 'TAXATABELA'
						 ,pr_tpregist => 0);
			FETCH cr_craptab
				INTO rw_craptab;
			-- Se encontrar
			IF cr_craptab%FOUND THEN
				-- Se a primeira posição do campo
				-- dstextab for diferente de zero
			 IF SUBSTR(rw_craptab.dstextab,1,1) != '0' THEN
					-- ÿ porque existe tabela parametrizada
					vr_inusatab := TRUE;
				ELSE
					-- Não existe
					vr_inusatab := FALSE;
				END IF;
			ELSE
				-- Não existe
				vr_inusatab := FALSE;
			END IF;
			CLOSE cr_craptab;

			-- Carregar os dados gravados na TAB030
		  tabe0001.pc_busca_tab030(pr_cdcooper => pr_cdcooper     --> Coop
								  ,pr_cdagenci => 0               --> Código da agência
								  ,pr_nrdcaixa => 0               --> Número do caixa
								  ,pr_cdoperad => 0               --> Código do Operador
								  ,pr_vllimite => vr_vlarrast     --> Limite
								  ,pr_vlsalmin => vr_vlsalmin     --> Salário mínimo
								  ,pr_diasatrs => vr_diasatrs     --> Dias de atraso
								  ,pr_atrsinad => vr_atrsinad     --> Dias de atraso para inadimplência
								  ,pr_des_reto => vr_des_reto     --> Indicador de saída com erro (OK/NOK)
								  ,pr_tab_erro => vr_tab_erro);   --> Tabela com erros) IS

			-- Se retornar erro
			IF vr_des_reto = 'NOK' THEN
				-- Se veio erro na tabela
				IF vr_tab_erro.COUNT > 0 then
					-- Montar erro
					pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
					pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
				ELSE
					-- Por algum motivo retornou erro mais a tabela veio vazia
					pr_dscritic := 'Tab.Erro vazia - não é possível retornar o erro da chamada tabe0001.pc_busca_tab030';
				END IF;
				-- Sair com erro
				RAISE vr_exc_erro;
			END IF;

			-- Carrega as tabelas de contas transferidas da Viacredi e do AltoVale e SCRCred
			IF pr_cdcooper = 1 THEN

				-- Vindas da Acredicoop
				IF pr_dtrefere <= TO_DATE('31/12/2013', 'DD/MM/RRRR') THEN
					FOR regs IN cr_craptco_acredi_via LOOP
						vr_tab_craptco(regs.nrdconta) := regs.nrdconta;
					END LOOP;
				END IF;

				-- Incorporação da Concredi
				IF pr_dtrefere <= TO_DATE('30/11/2014', 'DD/MM/RRRR') THEN
					FOR regs IN cr_craptco_concredi_via LOOP
						vr_tab_craptco(regs.nrdconta) := regs.nrdconta;
					END LOOP;
				END IF;

				-- Migração Via >> Altovale
		  ELSIF pr_cdcooper = 16 AND pr_dtrefere <= TO_DATE('31/12/2012', 'DD/MM/RRRR') THEN
				-- Vindas da Via
				FOR regs IN cr_craptco_via_alto LOOP
					vr_tab_craptco(regs.nrdconta) := regs.nrdconta;
				END LOOP;
				-- Incorporação da Credimil >> SCR
		  ELSIF pr_cdcooper = 13 AND pr_dtrefere <= TO_DATE('30/11/2014', 'DD/MM/RRRR') THEN
				-- Vindas da Credimil
				FOR regs IN cr_craptco_credimilsul_civia LOOP
					vr_tab_craptco(regs.nrdconta) := regs.nrdconta;
				END LOOP;
			END IF;

			-- Busca do diretório base da cooperativa para a geração de relatórios
		  vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
																						,pr_cdcooper => pr_cdcooper);

			-- Busca agora o diretório base da cooperativa para a geração de arquivos
			-- Obs: será utilizado apenas para o 354.txt
		  vr_nmdireto_354 := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
																							,pr_cdcooper => pr_cdcooper
																							,pr_nmsubdir => '/arq');

			-- Desde que o programa chamador não seja o 184
			IF pr_cdprogra <> 'CRPS184' THEN
				-- Atribuir o nome ao arquivo
				vr_nmarquiv_354 := 'crrl354.txt';
				-- Criar o CLOB para envio dos dados do txt
				dbms_lob.createtemporary(vr_clob_354, TRUE, dbms_lob.CALL);
				dbms_lob.open(vr_clob_354, dbms_lob.lob_readwrite);
				-- Envio do header
			 gene0002.pc_escreve_xml(pr_xml => vr_clob_354
									,pr_texto_completo => vr_txtarqui_354
									,pr_texto_novo =>'CONTA/DV'||vr_dssepcol_354
												   ||'TITULAR'||vr_dssepcol_354
												   ||'TIPO'||vr_dssepcol_354
												   ||'ORG'||vr_dssepcol_354
												   ||'CONTRATO'||vr_dssepcol_354
												   ||'LC'||vr_dssepcol_354
												   ||'SALDO DEVEDOR'||vr_dssepcol_354
												   ||'JUR.ATRASO+60'||vr_dssepcol_354
												   ||'PARCELA'||vr_dssepcol_354
												   ||'QT.PARC.'||vr_dssepcol_354
												   ||'TOT.ATRASO'||vr_dssepcol_354
												   ||'DESPESA'||vr_dssepcol_354
												   ||'%'||vr_dssepcol_354
												   ||'PA'||vr_dssepcol_354
												   ||'MESES/DIAS ATR.'||vr_dssepcol_354
												   ||'RISCO ATU.'||vr_dssepcol_354
												   ||'RISCO ANT.'||vr_dssepcol_354
												   ||'DATA RISCO ANT'||vr_dssepcol_354
												   ||'DIAS RIS'||vr_dssepcol_354
												   ||'DIAS ATR'||vr_dssepcol_354
												   ||'TOT.ATRASO ATENDA'
																									||chr(10));
			END IF;

			-- Inicializar os registros no totalizador de riscos geral
		  FOR vr_contador IN vr_tab_risco.FIRST..vr_tab_risco.LAST LOOP
				-- Acumular totalizadores por risco geral
				vr_tab_totrisger(vr_contador).qtdabase := 0;
				vr_tab_totrisger(vr_contador).vljura60 := 0;
				vr_tab_totrisger(vr_contador).vljrpf60 := 0;
				vr_tab_totrisger(vr_contador).vljrpj60 := 0;
				vr_tab_totrisger(vr_contador).vlprovis := 0;
				vr_tab_totrisger(vr_contador).vldabase := 0;
			END LOOP;

			-- Obter taxa mensal da craptab
		  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
												   ,pr_nmsistem => 'CRED'
												   ,pr_tptabela => 'USUARI'
												   ,pr_cdempres => 11
												   ,pr_cdacesso => 'JUROSNEGAT'
												   ,pr_tpregist => 1);

		  IF vr_dstextab IS NOT NULL  THEN
			 vr_txmensal := to_number ( substr(vr_dstextab,1,10) );
			END IF;

			-- Inicializar totalizadores -de provisão e dívida os valores calculados
			pr_vltotdiv := 0;
			pr_vltotprv := 0;

			 pc_log_programa(PR_DSTIPLOG     => 'O',
											PR_CDPROGRAMA   => pr_cdprogra || '_' || pr_cdagenci || '$',
											pr_cdcooper     => pr_cdcooper,
											pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											pr_tpocorrencia => 4,
						  pr_dsmensagem   => 'crapvri Início AGENCIA: [' ||pr_cdagenci || '] - INPROCES: ' || pr_rw_crapdat.inproces,
											PR_IDPRGLOG     => vr_idlog_ini_ger);

				-- carrega a PLTABLE da CRAPVRI baseado na data de referencia do CRPS
				OPEN cr_crapvri(pr_dtrefere);

				LOOP
			FETCH cr_crapvri BULK COLLECT INTO vr_tab_crapvri LIMIT 100000; -- carrega de 100 em 100 mil registros

					EXIT WHEN vr_tab_crapvri.COUNT = 0;

					IF vr_tab_crapvri.COUNT > 0 THEN
						-- percorre a PLTABLE refazendo o indice com a composicao dos campos
			  FOR idx IN vr_tab_crapvri.FIRST..vr_tab_crapvri.LAST LOOP
							-- monta o indice
				vr_chave_index := vr_tab_crapvri(idx).nrdconta || vr_tab_crapvri(idx).innivris || vr_tab_crapvri(idx).cdmodali || vr_tab_crapvri(idx).nrctremp || vr_tab_crapvri(idx).nrseqctr;
							-- alimenta a nova PLTABLE apenas com os campos necessarios
							vr_tab_crapvri_index(vr_chave_index).vldivida := vr_tab_crapvri(idx).vldivida;
							vr_tab_crapvri_index(vr_chave_index).vltotatr := vr_tab_crapvri(idx).vltotatr;
							vr_tab_crapvri_index(vr_chave_index).qtpreatr := vr_tab_crapvri(idx).qtpreatr;
							vr_tab_crapvri_index(vr_chave_index).vlprejuz := vr_tab_crapvri(idx).vlprejuz;

						END LOOP;
					END IF;

					vr_tab_crapvri.DELETE;

				END LOOP;
				CLOSE cr_crapvri;

				pc_log_programa(PR_DSTIPLOG     => 'O',
											PR_CDPROGRAMA   => pr_cdprogra || '_' || pr_cdagenci || '$',
											pr_cdcooper     => pr_cdcooper,
											pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											pr_tpocorrencia => 4,
						  pr_dsmensagem   => 'crapvri Fim AGENCIA: [' || pr_cdagenci || '] - INPROCES: ' || pr_rw_crapdat.inproces,
											PR_IDPRGLOG     => vr_idlog_ini_ger);
      END IF; --pr_idparale = 0.
									
    -- Ligeirinho - inicio:
    vr_cdprogra := 'CRPS280_I';
    -- Validações iniciais do programa
    btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
    -- Se retornou algum erro
    if vr_cdcritic <> 0 then
      vr_dscritic := nvl(vr_dscritic, 'x') ||
                     'Chamou btch0001.pc_valida_iniprg.';
      raise vr_exc_saida;
    end if;

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS280_I_WAG',
                               pr_action => vr_cdprogra);

    -- Buscar quantidade parametrizada de Jobs
    vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper => pr_cdcooper --pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                                 ,pr_cdprogra => Pr_cdprogra --pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Código do programa
                                                 );

    /* Paralelismo visando performance Rodar Somente no processo Noturno */
    if pr_rw_crapdat.inproces > 2
    and vr_qtdjobs > 0
    and pr_cdagenci = 0 then

      pc_clear_memoria(pr_CDAGENCI => 0);

      vr_tpexecucao := 1;

      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I',
                      pr_cdprograma => pr_cdprogra,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => 1, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger); --Out.

      --Gerar o vr_idparale, para ser usado nos jobs.
      pc_iniciar_amb_paralel;

      --Rotina responsavel em criar os jobs por agencia, considerando a sua cooperativa.
      pc_criar_job_paralelo;

      --Chamar rotina de aguardo agora passando 0, para esperar
      --até que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale,
                                   pr_qtdproce => 0,
                                   pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      if vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;

      --Verificar a qtde de erro gerado pelos jobs.
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                    pr_cdprogra    => pr_cdprogra,
                                                    pr_dtmvtolt    => pr_rw_crapdat.dtmvtolt,
                                                    pr_tpagrupador => 1,
                                                    pr_nrexecucao  => 1);

      if vr_qterro > 0 then
        vr_cdcritic := 0;
        vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
        raise vr_exc_saida;
      end if;

    else

      if pr_cdagenci <> 0 then
        vr_tpexecucao := 2;
      else
        vr_tpexecucao := 1;
      end if;

      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I',
                      pr_cdprograma => pr_cdprogra || '_' || pr_cdagenci,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par);

      -- Grava controle de batch por agência
      gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper -- Codigo da Cooperativa
                                      ,pr_cdprogra    => pr_cdprogra -- Codigo do Programa
                                      ,pr_dtmvtolt    => pr_rw_crapdat.dtmvtolt -- Data de Movimento
                                      ,pr_tpagrupador => 1 -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                      ,pr_cdagrupador => pr_cdagenci -- Codigo do agrupador conforme (tpagrupador)
                                      ,pr_cdrestart   => null -- Controle do registro de restart em caso de erro na execucao
                                      ,pr_nrexecucao  => 1 -- Numero de identificacao da execucao do programa
                                      ,pr_idcontrole  => vr_idcontrole -- ID de Controle
                                      ,pr_cdcritic    => pr_cdcritic -- Codigo da critica
                                      ,pr_dscritic    => vr_dscritic);
      -- Testar saida com erro
      if vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;

      --Cada Job é responsável em buscar todos os dados da sua agencia na qual foi parametrizada no Job.
      pc_log_programa(PR_DSTIPLOG     => 'O',
                      PR_CDPROGRAMA   => pr_cdprogra || '_' || pr_cdagenci || '$',
                      pr_cdcooper     => pr_cdcooper,
                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia => 4,
                      pr_dsmensagem   => 'Início - pc_busca_arq_controle_risco AGENCIA: [' ||
                                         pr_cdagenci || '] - INPROCES: ' ||
                                         pr_rw_crapdat.inproces,
                      PR_IDPRGLOG     => vr_idlog_ini_par);

      --Preencher a pl-table com as informações dos associados.
      pc_busca_arq_controle_risco;

      --Cada Job é responsável em buscar todos os dados da sua agencia na qual foi parametrizada no Job.
      pc_log_programa(PR_DSTIPLOG     => 'O',
                      PR_CDPROGRAMA   => pr_cdprogra || '_' || pr_cdagenci || '$',
                      pr_cdcooper     => pr_cdcooper,
                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia => 4,
                      pr_dsmensagem   => 'Fim - pc_busca_arq_controle_risco AGENCIA: [' ||
                                         pr_cdagenci || '] - INPROCES: ' ||
                                         pr_rw_crapdat.inproces,
                      PR_IDPRGLOG     => vr_idlog_ini_par);

      --Quando esta rotina for executada via job criado por paralelismo, o pr_idparale deve ser <> 0
      if pr_idparale <> 0 then

        --Popular a tabela wrk, com as informações das agencias que estao na pl-table.
        pc_grava_tab_wrk_dados_epr(vr_dscritic);
        --Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;

        pc_grava_tab_wrk_crapris(vr_dscritic);
        --Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;

        -- AWAE: Para Titulos de Borderô
        pc_grava_tab_wrk_dados_tdb(vr_dscritic);
        --Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;
      end if;

      --Grava data fim para o JOB na tabela de LOG
      pc_log_programa(pr_dstiplog   => 'F',
                      pr_cdprograma => pr_cdprogra || '_' || pr_cdagenci,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par,
                      pr_flgsucesso => 1);
    end if;

    --Nao foi executado por um job paralelo.
    if (pr_idparale = 0) then

      -- Ligeirinho - fim.

      pc_log_programa(PR_DSTIPLOG     => 'O',
                      PR_CDPROGRAMA   => pr_cdprogra,
                      pr_cdcooper     => pr_cdcooper,
                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia => 4,
                      pr_dsmensagem   => 'Início grava tabela memoria. AGENCIA: ' ||
                                         pr_cdagenci || ' - INPROCES: ' ||
                                         pr_rw_crapdat.inproces ||
                                         ' - Horário: ' ||
                                         to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'),
                      PR_IDPRGLOG     => vr_idlog_ini_ger);

      pc_grava_tab_men_dados_epr(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                                 pr_des_erro => vr_dscritic);
      --Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Exceção
        RAISE vr_exc_saida;
      END IF;

      pc_grava_tab_men_crapris(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                               pr_des_erro => vr_dscritic);
      --Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Exceção
        RAISE vr_exc_saida;
      END IF;

      -- AWAE: Para Titulos de Borderô
      pc_grava_tab_men_dados_tdb(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                                 pr_des_erro => vr_dscritic);
      --Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Exceção
        RAISE vr_exc_saida;
      END IF;

      pc_log_programa(PR_DSTIPLOG     => 'O',
                      PR_CDPROGRAMA   => pr_cdprogra,
                      pr_cdcooper     => pr_cdcooper,
                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia => 4,
                      pr_dsmensagem   => 'Fim grava tabela memoria. AGENCIA: ' ||pr_cdagenci ||
                                         ' - INPROCES: ' ||pr_rw_crapdat.inproces ||
                                         ' - Horário: ' ||to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss'),
                      PR_IDPRGLOG     => vr_idlog_ini_ger);

      -------- Inicialização comum de todos os CLOBs de XML ------

      -- Para o crrl227.lst
      dbms_lob.createtemporary(vr_clobxml_227, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml_227, dbms_lob.lob_readwrite);
      gene0002.pc_escreve_xml(pr_xml => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo => '<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Para o crrl354.lst
      dbms_lob.createtemporary(vr_clobxml_354, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml_354, dbms_lob.lob_readwrite);
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Para o crr581.lst
      dbms_lob.createtemporary(vr_clobxml_581, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml_581, dbms_lob.lob_readwrite);
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_581
                             ,pr_texto_completo => vr_txtauxi_581
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><raiz>');

      pc_log_programa(PR_DSTIPLOG     => 'O',
                      PR_CDPROGRAMA   => pr_cdprogra,
                      pr_cdcooper     => pr_cdcooper,
                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia => 4,
                      pr_dsmensagem   => 'Início01 - loop tab men. AGENCIA: ' ||pr_cdagenci ||
                                         ' - INPROCES: ' ||pr_rw_crapdat.inproces ||
                                         ' - Horário: ' ||to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss'),
                      PR_IDPRGLOG     => vr_idlog_ini_ger);


      -- Popular a VR_TAB com todos os grupos economicos
      FOR rw_crapgrp IN cr_crapgrp LOOP
        -- Popular o Indice
        vr_idx_grp := lpad(pr_cdcooper,5,'0')||lpad(rw_crapgrp.nrcpfcgc,15,'0');
        vr_tab_crapgrp(vr_idx_grp) := rw_crapgrp.nrcpfcgc;        
      END LOOP;

      -- Buscar o primeiro registro da tabela temporária
      vr_des_chave_crapris := vr_tab_crapris.FIRST;
      LOOP
        -- Sair quando não houverem mais registros a processar
        EXIT WHEN vr_des_chave_crapris IS NULL;

        -- Reiniciar variáveis de controle
        vr_vldivida       := 0;
        vr_vljuro60_desconto := 0;
        vr_vlprejuz_conta := 0;
        vr_qtpreatr       := 0;
        vr_vltotatr       := 0;
				vr_vljur60        := 0; -- PRJ Microcredito

        -- Se mudou o PAC ou é o primeiro registro
         IF vr_des_chave_crapris = vr_tab_crapris.FIRST OR vr_tab_crapris(vr_tab_crapris.PRIOR(vr_des_chave_crapris)).cdagenci <> vr_tab_crapris(vr_des_chave_crapris).cdagenci THEN
          -- Buscar nome da agência
          OPEN cr_crapage(vr_tab_crapris(vr_des_chave_crapris).cdagenci);
          FETCH cr_crapage
            INTO vr_nmresage;
          CLOSE cr_crapage;

          -- Inicializar os registros no totalizador de riscos por PAC
            FOR vr_contador IN vr_tab_risco.FIRST..vr_tab_risco.LAST LOOP
            -- Acumular totalizadores por risco geral
            vr_tab_totrispac(vr_contador).qtdabase := 0;
            vr_tab_totrispac(vr_contador).vljrpf60 := 0;
            vr_tab_totrispac(vr_contador).vljrpj60 := 0;
            vr_tab_totrispac(vr_contador).vljura60 := 0;
            vr_tab_totrispac(vr_contador).vlprovis := 0;
            vr_tab_totrispac(vr_contador).vldabase := 0;
          END LOOP;

          -- Reiniciar totalizadores
          vr_tot_qtctremp := 0;
          vr_tot_qtctrato := 0;
          vr_tot_vldespes := 0;
          vr_tot_qtempres := 0;
          vr_tot_vlsdeved := 0;
          vr_med_percentu := 0;
          vr_tot_vlsdvatr := 0;
          vr_tot_vlatraso := 0;
          vr_tot_vlpreatr := 0;
          vr_tot_qtdopera := 0;
          vr_tot_qtdopfis := 0;
          vr_tot_qtdopjur := 0;
          vr_tot_vlropera := 0;
          vr_tot_vlropfis := 0;
          vr_tot_vlropjur := 0;
          vr_tot_qtatrasa := 0;
          vr_tot_qtatrfis := 0;
          vr_tot_qtatrjur := 0;
          vr_tot_vlatrasa := 0;
          vr_tot_vlatrfis := 0;
          vr_tot_vlatrjur := 0;
          -- P577 - Inicio
          vr_tot_vltotjurant60 := 0;
          vr_tot_vltotjur60 := 0;
          -- P577 - Fim
          -- Reinicializar controle de envio da tag de PAC
          vr_flgpac01 := FALSE;
          vr_flgpac02 := FALSE;

        END IF;

        -- Guardar a origem cfme os tipos
        IF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 1 THEN
          vr_dsorigem := 'C';
         ELSIF vr_tab_crapris(vr_des_chave_crapris).cdorigem IN(2,4,5) THEN
          vr_dsorigem := 'D';
        ELSE
          vr_dsorigem := 'E';
        END IF;

        -- Se o risco tiver nivel de risco = 9
        IF vr_tab_crapris(vr_des_chave_crapris).innivris = 9 THEN
          -- Preparar as informações para geração de linha no relatório crrl581
            vr_dtfimmes := TRUNC(pr_dtrefere,'mm')-1; --> Mês anterior
          vr_contdata := 1;
          vr_flgrisco := TRUE;

          -- Para origem 3 - empréstimos
          IF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 3 THEN
            -- Multiplicar os dias para termos a informação em meses
            vr_ddatraso := vr_tab_crapris(vr_des_chave_crapris).qtatraso * 30;
          ELSE
            -- Utilizar a informação já retornada
            vr_ddatraso := vr_tab_crapris(vr_des_chave_crapris).qtatraso;
          END IF;

          -- Efetuar laço de 6 tentativas para buscar o risco 9
          -- nos ultimos 6 fechamentos de mês
            vr_dtmesant := LAST_DAY(ADD_MONTHS(TRUNC(pr_dtrefere,'mm'), -1)); --> Ultimo dia Mês anterior (30-31)/MM/YYYY
            vr_dt6meses := ADD_MONTHS(TRUNC(pr_dtrefere,'mm'), -6); --> Primeiro dia de 5 meses atras 01/MM/YYYY

               OPEN cr_crapris_tst(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                                  ,pr_innivris => 9
                               ,pr_dtini    => vr_dt6meses
                               ,pr_dtfim    => vr_dtmesant
                                  ,pr_inddocto => 1 ); -- Docto 3020
          FETCH cr_crapris_tst
            INTO vr_exis_crapris;
          -- Se não existir risco H no mês procurado
          IF vr_exis_crapris < 6 THEN
            vr_flgrisco := FALSE;
          END IF;

          CLOSE cr_crapris_tst;

          -- Se mesmo assim continuar existindo o risco
          IF vr_flgrisco THEN
            -- Enviar o registro para o XML do relatório
            gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_581
                                   ,pr_texto_completo => vr_txtauxi_581
                                   ,pr_texto_novo     =>'<riscoH>'
                                                      ||' <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_crapris(vr_des_chave_crapris).nrdconta))||'</nrdconta>'
                                                      ||' <nmprimtl>'||SUBSTR(vr_tab_crapris(vr_des_chave_crapris).nmprimtl,1,40)||'</nmprimtl>'
                                                      ||' <tpemprst>'||vr_tab_crapris(vr_des_chave_crapris).tpemprst||'</tpemprst>'
                                                      ||' <cdagenci>'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'</cdagenci>'
                                                      ||' <dsorigem>'||vr_dsorigem||'</dsorigem>'
                                                      ||' <nrctremp>'||LTRIM(gene0002.fn_mask(vr_tab_crapris(vr_des_chave_crapris).nrctremp,'zz.zzz.zz9'))||'</nrctremp>'
                                                      ||' <cdmodali>'||to_char(vr_tab_crapris(vr_des_chave_crapris).cdmodali,'fm0000')||'</cdmodali>'
                                                      ||' <vldivida>'||to_char(vr_tab_crapris(vr_des_chave_crapris).vldivida,'fm999g999g990d00')||'</vldivida>'
                                                      ||' <ddatraso>'||to_char(vr_ddatraso,'fm999g990')||'</ddatraso>'
                                                      ||'</riscoH>');
          END IF;
        END IF;

        vr_chave_index := vr_tab_crapris(vr_des_chave_crapris).nrdconta || vr_tab_crapris(vr_des_chave_crapris).innivris ||
                          vr_tab_crapris(vr_des_chave_crapris).cdmodali || vr_tab_crapris(vr_des_chave_crapris).nrctremp ||
                          vr_tab_crapris(vr_des_chave_crapris).nrseqctr;

        /*
         Se a modalidade é 0101, soma o valor dos juros +60 aos saldos devedores,
         pois a CRAPVRI é alimentada para esta modalidade somente com o valor do
         saldo devedor até 59 dias de atraso (sem os juros +60)
         Reginaldo/AMcom - P450
        */
        IF vr_tab_crapvri_index.exists(vr_chave_index) THEN

          vr_vljuro60_desconto := vr_vljuro60_desconto +
                                  CASE WHEN vr_tab_crapris(vr_des_chave_crapris).cdmodali = 101 
                                        AND vr_tab_crapris(vr_des_chave_crapris).innivris >= 10 --> Apenas operações que estejam em prejuizo
                                       THEN vr_tab_crapris(vr_des_chave_crapris).vljura60
                                       ELSE 0
                                  END;

          vr_vldivida := vr_vldivida + 
					               (vr_tab_crapvri_index(vr_chave_index).vldivida +
												  CASE WHEN vr_tab_crapris(vr_des_chave_crapris).cdmodali = 101 
														   THEN vr_tab_crapris(vr_des_chave_crapris).vljura60
															 ELSE 0
													END);
					-- PRJ Microcredito
					vr_vljur60 := vr_vljur60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljura60,0);
					
          vr_qtpreatr := vr_tab_crapvri_index(vr_chave_index).qtpreatr;
          vr_vltotatr := vr_vltotatr + 
					               (vr_tab_crapvri_index(vr_chave_index).vltotatr +
												  CASE WHEN vr_tab_crapris(vr_des_chave_crapris).cdmodali = 101 
														   THEN vr_tab_crapris(vr_des_chave_crapris).vljura60
															 ELSE 0
													END);
          vr_vlprejuz := vr_vlprejuz + 
					               (vr_tab_crapvri_index(vr_chave_index).vlprejuz +
												  CASE WHEN vr_tab_crapris(vr_des_chave_crapris).cdmodali = 101 
														        AND vr_tab_crapvri_index(vr_chave_index).vlprejuz > 0
														   THEN vr_tab_crapris(vr_des_chave_crapris).vljura60
															 ELSE 0
													END);
          vr_vlprejuz_conta := vr_vlprejuz_conta + 
					                     (vr_tab_crapvri_index(vr_chave_index).vlprejuz +
												       CASE WHEN vr_tab_crapris(vr_des_chave_crapris).cdmodali = 101 
																         AND vr_tab_crapvri_index(vr_chave_index).vlprejuz > 0
														        THEN vr_tab_crapris(vr_des_chave_crapris).vljura60
															      ELSE 0
													     END);
        END IF;

        -- Somente considerar se houver diferença na dívida, do contrario considerar prejuízo
        IF vr_vlprejuz_conta <> vr_tab_crapris(vr_des_chave_crapris).vldivida THEN
          -- Guardar percentual
          vr_percentu := vr_tab_risco(vr_tab_crapris(vr_des_chave_crapris).innivris).percentu;
          -- Calcular o percentual para o atraso com base nos percentuais da tabela
          vr_vlpercen := vr_percentu / 100;

          -- Calcular o valor de prestação em atraso
            vr_vlpreatr := ROUND( (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60
                                               - nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0) -- PRJ577 -- O cálculo da provisão deve considerar o Valor do Juros+60 Anterior 
                                  ) * vr_vlpercen ,2);
            
          -- Acumular totalizadores por risco de PAC
          vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).qtdabase := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).qtdabase + 1;
          vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljura60 := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljura60 + vr_tab_crapris(vr_des_chave_crapris).vljura60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577 -- Considerar no resumo do relatório crrl227 o valor do Juros+60 anterior
          -- Acumular juros 60 por PA separando por PF e PJ
          IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
            IF vr_tab_totrispac.EXISTS(vr_tab_crapris(vr_des_chave_crapris).innivris) THEN
              vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 + vr_tab_crapris(vr_des_chave_crapris).vljura60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577 -- Considerar no resumo do relatório crrl227 o valor do Juros+60 anterior
            ELSE
              vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 := vr_tab_crapris(vr_des_chave_crapris).vljura60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577 -- Considerar no resumo do relatório crrl227 o valor do Juros+60 anterior
            END IF;
          ELSE
            IF vr_tab_totrispac.EXISTS(vr_tab_crapris(vr_des_chave_crapris).innivris) THEN
              vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 + vr_tab_crapris(vr_des_chave_crapris).vljura60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577 -- Considerar no resumo do relatório crrl227 o valor do Juros+60 anterior
            ELSE
              vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 := vr_tab_crapris(vr_des_chave_crapris).vljura60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577 -- Considerar no resumo do relatório crrl227 o valor do Juros+60 anterior
            END IF;
          END IF;
          vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vlprovis := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vlprovis + vr_vlpreatr;
          vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vldabase := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vldabase + vr_vldivida;
          -- Acumular totalizadores por risco geral
          vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).qtdabase := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).qtdabase + 1;
          vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljura60 := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljura60 + vr_tab_crapris(vr_des_chave_crapris).vljura60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577 -- Considerar no resumo do relatório crrl227 o valor do Juros+60 anterior
          -- Acumular juros 60 por PF e PJ
          IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
            IF vr_tab_totrisger.EXISTS(vr_tab_crapris(vr_des_chave_crapris).innivris) THEN
              vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 + vr_tab_crapris(vr_des_chave_crapris).vljura60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577 -- Considerar no resumo do relatório crrl227 o valor do Juros+60 anterior
            ELSE
              vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 := vr_tab_crapris(vr_des_chave_crapris).vljura60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577 -- Considerar no resumo do relatório crrl227 o valor do Juros+60 anterior
            END IF;
          ELSE
            IF vr_tab_totrisger.EXISTS(vr_tab_crapris(vr_des_chave_crapris).innivris) THEN
              vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 + vr_tab_crapris(vr_des_chave_crapris).vljura60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577 -- Considerar no resumo do relatório crrl227 o valor do Juros+60 anterior
            ELSE
              vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 := vr_tab_crapris(vr_des_chave_crapris).vljura60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577 -- Considerar no resumo do relatório crrl227 o valor do Juros+60 anterior
            END IF;
          END IF;
          --
          vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vlprovis := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vlprovis + vr_vlpreatr;
          vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vldabase := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vldabase + vr_vldivida;

          -- Para origens de empréstimo
          IF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 3 THEN

               
            -- Re-criando o indice da tabela temporaria
               vr_indice := LPAD(vr_tab_crapris(vr_des_chave_crapris).nrdconta,10,'0')
                         || LPAD(vr_tab_crapris(vr_des_chave_crapris).nrctremp,10,'0');

            -- Checagem Origem
            IF vr_tab_dados_epr.exists(vr_indice) THEN
              IF vr_tab_dados_epr(vr_indice).dsorgrec IS NOT NULL THEN
                -- Checar se este recurso já possui registro na vr_tab_microcredito
                IF NOT vr_tab_microcredito.exists(vr_tab_dados_epr(vr_indice).dsorgrec) THEN
                  -- Criar o registro:
                  vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesfis := 0;
                  vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesjur := 0;
									-- PRJ Microcredito
                  vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlate90d := 0;
                  vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlaci90d := 0;
                  vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlj60at90d := 0;
                  vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlj60ac90d := 0;

                  -- Verificar o grupo conforme os tipos de MicroCrédito
                        IF vr_tab_dados_epr(vr_indice).dsorgrec LIKE '%BRDE%' 
                        OR vr_tab_dados_epr(vr_indice).dsorgrec LIKE '%BNDES%' THEN
                    -- BNDEs
                    vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).idgrumic := 2;
                  ELSE
                    -- Cecred
                    vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).idgrumic := 1;
                  END IF;
                END IF;

                -- Armazenaremos a operação atual conforme o tipo de pessoa da mesma
                IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesfis 
                           := vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesfis + vr_vldivida;
                ELSE
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesjur 
                           := vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesjur + vr_vldivida;
                END IF;

								-- PRJ Microcredito
                -- Se o atraso for até 90 dias
                IF vr_tab_crapris(vr_des_chave_crapris).qtdiaatr <= 90 THEN
                  -- Acumular no período até 90
									
									-- PRJ Microcredito
                  vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlj60at90d 
                             := vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlj60at90d + vr_vljur60;
                  
									
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlate90d 
                           := vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlate90d + vr_vldivida;

                  IF vr_tab_dados_epr(vr_indice).dsorgrec = 'MICROCREDITO DIM' THEN
                    vr_tot_vltttlcr_dim := vr_tot_vltttlcr_dim + vr_vldivida; -- Acumulo total da linha
                    vr_tot_vlj60at90d_dim := vr_tot_vlj60at90d_dim + vr_vljur60;
                        ELSIF vr_tab_dados_epr(vr_indice).dsorgrec IN ('MICROCREDITO PNMPO CAIXA','MICROCREDITO PNMPO DIM') THEN
                    vr_tot_vltttlcr_dim_outros := vr_tot_vltttlcr_dim_outros + vr_vldivida; -- Acumulo total da linha
                    vr_tot_vlj60at90d_dim_outros := vr_tot_vlj60at90d_dim_outros + vr_vljur60;
                  END IF;

                ELSE
									-- PRJ Microcredito
                  vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlj60ac90d 
                             := vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlj60ac90d + vr_vljur60;
                  
                  
                  -- Acumular no restante
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlaci90d 
                           := vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlaci90d + vr_vldivida;

                  IF vr_tab_dados_epr(vr_indice).dsorgrec = 'MICROCREDITO DIM' THEN
                    vr_totatraso90_dim := vr_totatraso90_dim + vr_vldivida;
                    vr_tot_vlj60ac90d_dim := vr_tot_vlj60ac90d_dim + vr_vljur60;
                        ELSIF vr_tab_dados_epr(vr_indice).dsorgrec IN ('MICROCREDITO PNMPO CAIXA','MICROCREDITO PNMPO DIM') THEN
                    vr_totatraso90_dim_outros := vr_totatraso90_dim_outros + vr_vldivida;
                    vr_tot_vlj60ac90d_dim_outros := vr_tot_vlj60ac90d_dim_outros + vr_vljur60;
                  END IF;

                END IF;
              END IF;
            END IF;

            -- Emprestimo de cessao de credito
            IF vr_tab_crapris(vr_des_chave_crapris).fleprces = 1 THEN

              -- Gravar Emprestimos conforme o tipo de pessoa
              IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
                -- Gravar campos
                vr_vet_contabi.rel1760   := vr_vet_contabi.rel1760 + vr_vlpreatr;
                vr_vet_contabi.rel1760_v := vr_vet_contabi.rel1760_v + vr_vldivida;

                -- Gravar inf de emprestimos por coluna separando por tipo de pessoa
                vr_tab_contab_cessao(vr_vleprces)(vr_provis)(1).vlempres_pf := vr_tab_contab_cessao(vr_vleprces)(vr_provis)(1).vlempres_pf + vr_vlpreatr;
                vr_tab_contab_cessao(vr_vleprces)(vr_divida)(1).vlempres_pf := vr_tab_contab_cessao(vr_vleprces)(vr_divida)(1).vlempres_pf + vr_vldivida;

              ELSE
                vr_vet_contabi.rel1760   := vr_vet_contabi.rel1760 + vr_vlpreatr;
                vr_vet_contabi.rel1760_v := vr_vet_contabi.rel1760_v + vr_vldivida;

                -- Gravar inf de emprestimos por coluna separando por tipo de pessoa
                vr_tab_contab_cessao(vr_vleprces)(vr_provis)(2).vlempres_pj := vr_tab_contab_cessao(vr_vleprces)(vr_provis)(2).vlempres_pj + vr_vlpreatr;
                vr_tab_contab_cessao(vr_vleprces)(vr_divida)(2).vlempres_pj := vr_tab_contab_cessao(vr_vleprces)(vr_divida)(2).vlempres_pj + vr_vldivida;

              END IF;

               
               
              -- Para modalidade 299 -
            ELSIF vr_tab_crapris(vr_des_chave_crapris).cdmodali = 299 THEN

              -- Gravar Emprestimos conforme o tipo de pessoa
              IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
                -- Gravar campos
                vr_vet_contabi.rel5584   := vr_vet_contabi.rel5584 + vr_vlpreatr;
                vr_vet_contabi.rel5584_v := vr_vet_contabi.rel5584_v + vr_vldivida;

                -- Gravar inf de emprestimos por coluna separando por tipo de pessoa
                vr_tab_contab(vr_vlempres_pf)(vr_provis)(1).vlempres_pf := vr_tab_contab(vr_vlempres_pf)(vr_provis)(1).vlempres_pf + vr_vlpreatr;
                vr_tab_contab(vr_vlempres_pf)(vr_divida)(1).vlempres_pf := vr_tab_contab(vr_vlempres_pf)(vr_divida)(1).vlempres_pf + vr_vldivida;

              ELSE
                vr_vet_contabi.rel1723   := vr_vet_contabi.rel1723 + vr_vlpreatr;
                vr_vet_contabi.rel1723_v := vr_vet_contabi.rel1723_v + vr_vldivida;

                -- Gravar inf de emprestimos por coluna separando por tipo de pessoa
                vr_tab_contab(vr_vlempres_pj)(vr_provis)(2).vlempres_pj := vr_tab_contab(vr_vlempres_pj)(vr_provis)(2).vlempres_pj + vr_vlpreatr;
                vr_tab_contab(vr_vlempres_pj)(vr_divida)(2).vlempres_pj := vr_tab_contab(vr_vlempres_pj)(vr_divida)(2).vlempres_pj + vr_vldivida;

              END IF;

              -- Para modalidade 499
            ELSIF vr_tab_crapris(vr_des_chave_crapris).cdmodali = 499 THEN

              -- Gravar Financiamentos conforme o tipo de pessoa
              IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
                -- Gravar campos
                vr_vet_contabi.rel1731_1   := vr_vet_contabi.rel1731_1 + vr_vlpreatr;
                vr_vet_contabi.rel1731_1_v := vr_vet_contabi.rel1731_1_v + vr_vldivida;

                -- Gravar inf de financiamento por coluna separando por tipo de pessoa
                vr_tab_contab(vr_vlfinanc_pf)(vr_provis)(1).vlfinanc_pf := vr_tab_contab(vr_vlfinanc_pf)(vr_provis)(1).vlfinanc_pf + vr_vlpreatr;
                vr_tab_contab(vr_vlfinanc_pf)(vr_divida)(1).vlfinanc_pf := vr_tab_contab(vr_vlfinanc_pf)(vr_divida)(1).vlfinanc_pf + vr_vldivida;

              ELSE
                vr_vet_contabi.rel1731_2   := vr_vet_contabi.rel1731_2 + vr_vlpreatr;
                vr_vet_contabi.rel1731_2_v := vr_vet_contabi.rel1731_2_v + vr_vldivida;

                -- Gravar inf de financiamento por coluna separando por tipo de pessoa
                vr_tab_contab(vr_vlfinanc_pj)(vr_provis)(2).vlfinanc_pj := vr_tab_contab(vr_vlfinanc_pj)(vr_provis)(2).vlfinanc_pj + vr_vlpreatr;
                vr_tab_contab(vr_vlfinanc_pj)(vr_divida)(2).vlfinanc_pj := vr_tab_contab(vr_vlfinanc_pj)(vr_divida)(2).vlfinanc_pj + vr_vldivida;

              END IF;

            END IF;
            -- Para origens de conta corrente
          ELSIF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 1 THEN
            -- Para modalidade 201
            IF vr_tab_crapris(vr_des_chave_crapris).cdmodali = 0201 THEN
              -- Cheque Especial
              vr_vet_contabi.rel1722_0201   := vr_vet_contabi.rel1722_0201 + vr_vlpreatr;
              vr_vet_contabi.rel1722_0201_v := vr_vet_contabi.rel1722_0201_v + vr_vldivida;

              -- Gravar inf de cheque especial por coluna separando por tipo de pessoa
              vr_tab_contab(vr_vlchqesp)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqesp := vr_tab_contab(vr_vlchqesp)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqesp + vr_vlpreatr;
              vr_tab_contab(vr_vlchqesp)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqesp := vr_tab_contab(vr_vlchqesp)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqesp + vr_vldivida;

            ELSE
              -- Adiant.Depositante
                  vr_vet_contabi.rel1722_0101   := vr_vet_contabi.rel1722_0101   + vr_vlpreatr;
              -- P450 - Desconsiderar do vr_vldivida, o juro 60. São casos em que esse juro é de nivelrisco >= 10 (prejuizo).  
              vr_vet_contabi.rel1722_0101_v := vr_vet_contabi.rel1722_0101_v + vr_vldivida  - vr_vljuro60_desconto;

              -- Gravar inf de Adiant.Depositante por coluna separando por tipo de pessoa
              vr_tab_contab(vr_vladtdep)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vladtdep := vr_tab_contab(vr_vladtdep)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vladtdep + vr_vlpreatr;
              vr_tab_contab(vr_vladtdep)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vladtdep := vr_tab_contab(vr_vladtdep)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vladtdep + vr_vldivida - vr_vljuro60_desconto;

            END IF;
            -- Para Desconto de Cheques
          ELSIF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 2 THEN
            vr_vet_contabi.rel1724_v_c := vr_vet_contabi.rel1724_v_c + vr_vldivida;
               vr_vet_contabi.rel1724_c   := vr_vet_contabi.rel1724_c   + vr_vlpreatr;

            -- Gravar inf de desconto de cheques por coluna separando por tipo de pessoa
            vr_tab_contab(vr_vlchqdes)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqdes := vr_tab_contab(vr_vlchqdes)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqdes + vr_vlpreatr;
            vr_tab_contab(vr_vlchqdes)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqdes := vr_tab_contab(vr_vlchqdes)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqdes + vr_vldivida;

            -- Para Desconto de Titulos S/ Registro
          ELSIF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 4 THEN
            vr_vet_contabi.rel1724_v_sr := vr_vet_contabi.rel1724_v_sr + vr_vldivida;
               vr_vet_contabi.rel1724_sr   := vr_vet_contabi.rel1724_sr   + vr_vlpreatr;

            -- Gravar inf de desconto de titulos s/ registro por coluna separando por tipo de pessoa
            vr_tab_contab(vr_vltitdes_sr)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_sr := vr_tab_contab(vr_vltitdes_sr)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_sr + vr_vlpreatr;
            vr_tab_contab(vr_vltitdes_sr)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_sr := vr_tab_contab(vr_vltitdes_sr)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_sr + vr_vldivida;

            -- Desconto de Titulos C/ Registro
          ELSIF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 5 THEN
            vr_vet_contabi.rel1724_v_cr := vr_vet_contabi.rel1724_v_cr + vr_vldivida;
               vr_vet_contabi.rel1724_cr   := vr_vet_contabi.rel1724_cr   + vr_vlpreatr;

            -- Gravar inf de desconto de titulos c/ registro por coluna separando por tipo de pessoa
            vr_tab_contab(vr_vltitdes_cr)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_cr := vr_tab_contab(vr_vltitdes_cr)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_cr + vr_vlpreatr;
            vr_tab_contab(vr_vltitdes_cr)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_cr := vr_tab_contab(vr_vltitdes_cr)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_cr + vr_vldivida;

          END IF;

          -- Totais por PAC
          vr_tot_qtempres := vr_tot_qtempres + 1;
          vr_tot_vlsdeved := vr_tot_vlsdeved + vr_vldivida;
          -- Totalização cfme existência de atraso sim/nao

          IF vr_qtpreatr > 0 THEN
            -- Acumular como empréstimo
            vr_tot_qtctremp := vr_tot_qtctremp + 1;
            vr_tot_vlpreatr := vr_tot_vlpreatr + vr_vlpreatr;
          ELSE
            -- Acumular como carteira
            vr_tot_qtctrato := vr_tot_qtctrato + 1;
            vr_tot_vldespes := vr_tot_vldespes + vr_vlpreatr;
          END IF;

          -- P577 - Inicio
          vr_tot_vltotjur60 := vr_tot_vltotjur60 + vr_tab_crapris(vr_des_chave_crapris).vljura60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0);
          
          vr_tot_vltotjurant60 := vr_tot_vltotjurant60 + nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0);
          -- P577 - Fim

          -- Acumular valor e quantidade de operações de empréstimo
          vr_tot_vlropera := vr_tot_vlropera + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60) - nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577
          vr_tot_qtdopera := vr_tot_qtdopera + 1;

          -- Acumular valor e quantidade de operações de empréstimo por tipo de pessoa
          IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
            vr_tot_vlropfis := vr_tot_vlropfis + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60) - nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577
            vr_tot_qtdopfis := vr_tot_qtdopfis + 1;
          ELSE
            vr_tot_vlropjur := vr_tot_vlropjur + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60) - nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577
            vr_tot_qtdopjur := vr_tot_qtdopjur + 1;
          END IF;

          -- Se a quantidade de dias em atraso for superior a inadimplencia parametrizada
            IF vr_tab_crapris(vr_des_chave_crapris).qtdiaatr > NVL(vr_atrsinad,0) THEN
            -- Sumarizar nas quantidades de inadimplencia
            vr_tot_vlatrasa := vr_tot_vlatrasa + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60) - nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577
            vr_tot_qtatrasa := vr_tot_qtatrasa + 1;

            -- Sumarizar nas quantidades de inadimplencia por tipo de pessoa
            IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
              vr_tot_vlatrfis := vr_tot_vlatrfis + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60) - nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577
              vr_tot_qtatrfis := vr_tot_qtatrfis + 1;
            ELSE
              vr_tot_vlatrjur := vr_tot_vlatrjur + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60) - nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0); -- PRJ577
              vr_tot_qtatrjur := vr_tot_qtatrjur + 1;
            END IF;

          END IF;

          -- Acumular nas totalizadores de provisão e dívida os valores calculados
          pr_vltotdiv := pr_vltotdiv + vr_vldivida;
          pr_vltotprv := pr_vltotprv + vr_vlpreatr;
        END IF;


        -- Alimentar varíaveis para detalhamento dos riscos atual e anterior
        vr_dtdrisco := NULL;
        vr_qtdiaris := 0;

        -- Buscar o ultimo lançamento de risco para a conta com
        -- valor superior ao valor de arrasto e data igual ao final do mês
        vr_nivrisco     := NULL;
        rw_crapris_last := NULL;

         FOR rw_crapris_last IN cr_crapris_last(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                                                ,pr_dtrefere => pr_rw_crapdat.dtultdma) LOOP  --> Final do mês anterior
          IF rw_crapris_last.vldivida > vr_vlarrast THEN
            vr_nivrisco := vr_tab_risco_aux(rw_crapris_last.innivris).dsdrisco;
            vr_dtdrisco := rw_crapris_last.dtdrisco;
            EXIT;
          ELSE
            -- atribui na primeira vez e guarda o maior risco
            IF rw_crapris_last.innivris = 10 THEN
              vr_nivrisco := vr_tab_risco_aux(rw_crapris_last.innivris).dsdrisco;

              -- atribui com data do primeiro registro
              IF vr_dtdrisco IS NULL THEN
                vr_dtdrisco := rw_crapris_last.dtdrisco;
                EXIT;
              END IF;
            END IF;
          END IF;
        END LOOP;

        -- Novamente busca o ultimo lançamento de risco para a conta com
        -- valor superior ao valor de arrasto e desta vez com a data igual
        -- a data de referência passada para buscarmos as informações do risco atual
        vr_dsnivris     := 'A';
        rw_crapris_last := NULL;

         FOR rw_crapris_last IN cr_crapris_last(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                                                ,pr_dtrefere => pr_dtrefere) LOOP  --> Data passada
        --  IF vr_dtdrisco IS NULL THEN
            vr_dtdrisco := rw_crapris_last.dtdrisco;
        --  END IF;

          IF rw_crapris_last.vldivida > vr_vlarrast THEN
            vr_dsnivris := vr_tab_risco_aux(rw_crapris_last.innivris).dsdrisco;

            IF rw_crapris_last.innivris = 10 THEN
              IF vr_nivrisco IS NULL THEN
                vr_nivrisco := vr_dsnivris;
              END IF;
            END IF;

            EXIT;
          ELSE
            -- atribui na primeira vez e guarda o maior risco
            IF rw_crapris_last.innivris = 10 THEN
              vr_dsnivris := vr_tab_risco_aux(rw_crapris_last.innivris).dsdrisco;

              IF vr_nivrisco IS NULL THEN
                vr_nivrisco := vr_dsnivris;
              END IF;
            END IF;

          END IF;
        END LOOP;

        IF vr_nivrisco IS NULL THEN
          vr_nivrisco := 'A';
        END IF;

        -- Se encontrou o registro
        IF NOT vr_dtdrisco IS NULL THEN
          -- Se a data for anterior ao dia atual
          IF pr_rw_crapdat.dtmvtolt > vr_dtdrisco THEN
            -- Calcular a diferença
            vr_qtdiaris := pr_rw_crapdat.dtmvtolt - vr_dtdrisco;
          END IF;
        END IF;

        -- Reiniciar variavel de controle de grupo empresarial
        vr_pertenge := '';
        vr_idx_grp  := lpad(pr_cdcooper,5,'0')||lpad(vr_tab_crapris(vr_des_chave_crapris).nrcpfcgc,15,'0');
        IF vr_tab_crapgrp.exists(vr_idx_grp) THEN
           -- Verifica se o CPF/CNPJ em questao pertence a algum grupo economico
           vr_pertenge := '*';
        END IF;

        -- Se houve atraso
        IF vr_qtpreatr > 0 THEN
          -- Acumular no totalizador de saldo devedor
          vr_tot_vlsdvatr := vr_tot_vlsdvatr + vr_vldivida;
        END IF;


        -- Acumular o totalizador de atraso
        vr_tot_vlatraso := vr_tot_vlatraso + vr_vltotatr;

        -- Gerar linha no relatório 227 cfme as regras abaixo:
        -- 1) Existe atraso
        -- 2.1) Modalidade 101 desde que a quantidade de dias Saldo Negativo Risco > dias em atraso
        -- OU
        -- 2.2) OU Modalidade <> 101
        IF vr_qtpreatr > 0 AND
           (   (vr_tab_crapris(vr_des_chave_crapris).cdmodali = 101 AND vr_tab_crapris(vr_des_chave_crapris).qtdriclq >= vr_diasatrs)
             OR
           (vr_tab_crapris(vr_des_chave_crapris).cdmodali <> 101) ) THEN

          -- Se ainda não foi enviada a TAG de agência
          IF NOT vr_flgpac01 THEN
            -- Criar a tag do PAC no relatório
            gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                   ,pr_texto_completo => vr_txtauxi_227
                                   ,pr_texto_novo     => '<agencia cdagenci="'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'" nmresage="'||vr_nmresage||'">');
            -- Ativar flag para não enviar mais a tag de agência
            vr_flgpac01 := TRUE;
          END IF;

          -- Exclui do relatório os contratos de ADP de contas que foram transferidas para prejuízo
          IF NOT (vr_tab_crapris(vr_des_chave_crapris).inprejuz = 1
          AND vr_tab_crapris(vr_des_chave_crapris).cdmodali = 101) THEN

          -- Enviar registro para o XML 1
          vr_des_xml_gene := '<atraso>'
                           ||' <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_crapris(vr_des_chave_crapris).nrdconta))||'</nrdconta>'
                           ||' <nmprimtl>'||SUBSTR(vr_tab_crapris(vr_des_chave_crapris).nmprimtl,1,35)||'</nmprimtl>'
                           ||' <tpemprst>'||vr_tab_crapris(vr_des_chave_crapris).tpemprst||'</tpemprst>'
                           ||' <dsorigem>'||vr_dsorigem||'</dsorigem>'
                           ||' <nrctremp>'||LTRIM(gene0002.fn_mask(vr_tab_crapris(vr_des_chave_crapris).nrctremp,'zzzzzzz9'))||'</nrctremp>'
                           ||' <vldivida>'||to_char(vr_vldivida,'fm999g999g990d00')||'</vldivida>'
                           ||' <vljura60>'||to_char(vr_tab_crapris(vr_des_chave_crapris).vljura60,'fm999g999g990d00')||'</vljura60>'
                           -- P577 - Inicio
                           ||' <vljurantpp>'||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0),'fm999g999g990d00')||'</vljurantpp>'
                           -- P577 - Fim
                           ||' <vlpreemp>'||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).vlpreemp,0),'fm999g990d00')||'</vlpreemp>'
                           ||' <nroprest>'||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).nroprest,0),'fm990d00')||'</nroprest>'
                           ||' <qtatraso>'||to_char(vr_tab_crapris(vr_des_chave_crapris).qtatraso,'fm990d00')||'</qtatraso>'
                           ||' <vltotatr>'||to_char(vr_vltotatr,'fm999g999g990d00')||'</vltotatr>'
                           ||' <vlpreatr>'||to_char(vr_vlpreatr,'fm999g999g990d00')||'</vlpreatr>'
                           ||' <percentu>'||to_char(vr_percentu,'fm990d00')||'</percentu>'
                           ||' <cdagenci>'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'</cdagenci>'
                           ||' <pertenge>'||vr_pertenge||'</pertenge>'
                           ||' <nivrisco>'||vr_nivrisco||'</nivrisco>'
                           ||' <dtdrisco>'||to_char(vr_dtdrisco,'dd/mm/rr')||'</dtdrisco>'
                           ||' <qtdiaris>'||to_char(vr_qtdiaris,'fm9990')||'</qtdiaris>'
                           ||' <qtdiaatr>'||to_char(vr_tab_crapris(vr_des_chave_crapris).qtdiaatr,'fm999990')||'</qtdiaatr>';

          -- Somente enviar limite de crédio com origem = 'E'
          IF vr_dsorigem = 'E' THEN
              vr_des_xml_gene := vr_des_xml_gene || '<cdlcremp>'||vr_tab_crapris(vr_des_chave_crapris).cdlcremp||'</cdlcremp>';
          ELSE
            vr_des_xml_gene := vr_des_xml_gene || '<cdlcremp/>';
          END IF;

          -- Não enviar nivel em caso de ser AA
--        IF vr_dsnivris <> 'AA' THEN
              vr_des_xml_gene := vr_des_xml_gene || '<dsnivris>'||vr_dsnivris||'</dsnivris>';
--        ELSE
--          vr_des_xml_gene := vr_des_xml_gene || '<dsnivris/>';
--        END IF;

          -- Fechar tag atraso enviando pro XML
            gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                  ,pr_texto_completo => vr_txtauxi_227
                                  ,pr_texto_novo     => vr_des_xml_gene || '</atraso>');
          END IF;
          
        END IF;

        -- Gerar linha no relatório 354 se não houver prejuizo total
        IF vr_vldivida > 0 THEN

          -- Se ainda não foi enviada a TAG de agência
          IF NOT vr_flgpac02 THEN
            -- Criar a tag do PAC no relatório
            gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                                   ,pr_texto_completo => vr_txtauxi_354
                                   ,pr_texto_novo     => '<agencia cdagenci="'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'" nmresage="'||vr_nmresage||'">');
            -- Ativar flag para não enviar mais a tag de agência
            vr_flgpac02 := true;
          END IF;

          -- Exclui do relatório os contratos de ADP de contas que foram transferidas para prejuízo
          IF NOT (vr_tab_crapris(vr_des_chave_crapris).inprejuz = 1
          AND vr_tab_crapris(vr_des_chave_crapris).cdmodali = 101) THEN

          -- Enviar registro para o XML 2
          vr_des_xml_gene :='<divida>'
                          ||' <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_crapris(vr_des_chave_crapris).nrdconta))||'</nrdconta>'
                          ||' <nmprimtl>'||SUBSTR(vr_tab_crapris(vr_des_chave_crapris).nmprimtl,1,35)||'</nmprimtl>'
                          ||' <tpemprst>'||vr_tab_crapris(vr_des_chave_crapris).tpemprst||'</tpemprst>'
                          ||' <dsorigem>'||vr_dsorigem||'</dsorigem>'
                          ||' <nrctremp>'||LTRIM(gene0002.fn_mask(vr_tab_crapris(vr_des_chave_crapris).nrctremp,'zzzzzzz9'))||'</nrctremp>'
                          ||' <vldivida>'||to_char(vr_vldivida,'fm999g999g990d00')||'</vldivida>'
                          ||' <vljura60>'||to_char(vr_tab_crapris(vr_des_chave_crapris).vljura60,'fm999g990d00')||'</vljura60>'
                          -- P577 - Inicio
                          ||' <vljurantpp>'||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0),'fm999g999g990d00')||'</vljurantpp>'
                          -- P577 - Fim
                          ||' <vlpreemp>'||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).vlpreemp,0),'fm999g990d00')||'</vlpreemp>'
                          ||' <nroprest>'||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).nroprest,0),'fm990d00')||'</nroprest>'
                          ||' <qtatraso>'||to_char(vr_tab_crapris(vr_des_chave_crapris).qtatraso,'fm990d00')||'</qtatraso>'
                          ||' <vltotatr>'||to_char(vr_vltotatr,'fm999g999g990d00')||'</vltotatr>'
                          ||' <cdagenci>'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'</cdagenci>'
                          ||' <vlpreatr>'||to_char(vr_vlpreatr,'fm999g999g990d00')||'</vlpreatr>'
                          ||' <percentu>'||to_char(vr_percentu,'fm990d00')||'</percentu>'
                          ||' <pertenge>'||vr_pertenge||'</pertenge>'
                          ||' <nivrisco>'||vr_nivrisco||'</nivrisco>'
                          ||' <dtdrisco>'||to_char(vr_dtdrisco,'dd/mm/rr')||'</dtdrisco>'
                          ||' <qtdiaris>'||to_char(vr_qtdiaris,'fm9990')||'</qtdiaris>'
                          ||' <qtdiaatr>'||to_char(vr_tab_crapris(vr_des_chave_crapris).qtdiaatr,'fm999990')||'</qtdiaatr>';

          -- Somente enviar limite de crédio com origem = 'E'
          IF vr_dsorigem = 'E' THEN
               vr_des_xml_gene := vr_des_xml_gene || '<cdlcremp>'||vr_tab_crapris(vr_des_chave_crapris).cdlcremp||'</cdlcremp>';
          ELSE
            vr_des_xml_gene := vr_des_xml_gene || '<cdlcremp/>';
          END IF;

          -- Não enviar nivel em caso de ser AA
--        IF vr_dsnivris <> 'AA' THEN
          vr_des_xml_gene := vr_des_xml_gene || '<dsnivris>'||vr_dsnivris||'</dsnivris>';
--        ELSE
--          vr_des_xml_gene := vr_des_xml_gene || '<dsnivris/>';
--        END IF;

          -- Finalmente enviar para o XML
            gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                                   ,pr_texto_completo => vr_txtauxi_354
                                   ,pr_texto_novo     => vr_des_xml_gene||'</divida>');
          END IF;

          -- Desde que o programa chamador não seja o 184
          IF pr_cdprogra <> 'CRPS184' THEN
            -- Limpar linha de Crédito
            vr_cdlcremp_354 := ' ';

            -- Somente se a origem for empréstimo
            IF vr_dsorigem = 'E' THEN
                  vr_cdlcremp_354 := vr_tab_crapris(vr_des_chave_crapris).cdlcremp;
              -- inicializando o valor
              vr_vlpreapg := 0;
              -- monta o indice de busca dos emprestimo
              vr_indice   := lpad(vr_tab_crapris(vr_des_chave_crapris).nrdconta,10,'0')||
                             lpad(vr_tab_crapris(vr_des_chave_crapris).nrctremp,10,'0');

              -- se existir registro na tabela de emprestimo
              --IF vr_indice IS NOT NULL THEN
              IF vr_tab_dados_epr.exists(vr_indice) THEN

                -- Copiar o valor do atraso
                vr_vlpreapg := vr_tab_dados_epr(vr_indice).vlpapgat;

                     IF ((pr_cdcooper = 1) AND  /* 1 - Viacredi */  
                   (vr_tab_dados_epr(vr_indice).cdlcremp = 800 OR
                    vr_tab_dados_epr(vr_indice).cdlcremp = 900 OR
                    vr_tab_dados_epr(vr_indice).cdlcremp = 907 OR
                    vr_tab_dados_epr(vr_indice).cdlcremp = 909)) THEN
                  vr_cdorigem := 2; -- Desconto
                     ELSIF ((pr_cdcooper = 2)  AND /* 2 - Creditextil */
                      (vr_tab_dados_epr(vr_indice).cdlcremp = 850 OR
                       vr_tab_dados_epr(vr_indice).cdlcremp = 900)) THEN
                  vr_cdorigem := 2; -- Desconto
                ELSIF ((pr_cdcooper = 13) AND /* 13 - SCRCRED */
                      (vr_tab_dados_epr(vr_indice).cdlcremp = 800 OR
                       vr_tab_dados_epr(vr_indice).cdlcremp = 900 OR
                       vr_tab_dados_epr(vr_indice).cdlcremp = 903)) THEN
                  vr_cdorigem := 2; -- Desconto
                ELSIF (((pr_cdcooper <> 1) AND (pr_cdcooper <> 2) AND (pr_cdcooper <> 13)) AND
                      (vr_tab_dados_epr(vr_indice).cdlcremp = 800 OR
                        vr_tab_dados_epr(vr_indice).cdlcremp = 900)) THEN
                  vr_cdorigem := 2; -- Desconto
                ELSE
                  vr_cdorigem := 3;
                END IF;

                -- Flag de residuo
                     IF  vr_tab_dados_epr(vr_indice).inprejuz  = 0 AND
                         vr_tab_dados_epr(vr_indice).inliquid  = 0 AND
                   vr_tab_dados_epr(vr_indice).vlsdevat >= 0 AND
                         vr_tab_dados_epr(vr_indice).qtpcalat >= vr_tab_dados_epr(vr_indice).qtpreemp  THEN
                  --informa que existe residuo
                  vr_flgresid := 1;
                ELSE
                  vr_flgresid := 0;
                END IF;

                -- Grupo economico
                     IF vr_pertenge = '*'  THEN
                  vr_flgrpeco := 1;
                ELSE
                  vr_flgrpeco := 0;
                END IF;

                -- verifica o indicador de consignado
                IF vr_tab_dados_epr(vr_indice).tpdescto = 2 THEN
                  vr_flgconsg := 1;
                ELSE
                  vr_flgconsg := 0;
                END IF;

                -- Somente atualiza os dados para o Cyber caso nao esteja rodando na Cecred
                IF pr_cdcooper <> 3 AND pr_flgrelat = 0 THEN
                  -- Atualiza dados do emprestimo para o CYBER
                   cybe0001.pc_atualiza_dados_financeiro(pr_cdcooper => pr_cdcooper                                   -- Codigo da Cooperativa
                                                        ,pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta -- Numero da conta
                                                        ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp -- Numero do contrato
                                                        ,pr_cdorigem => vr_cdorigem                                   -- Origem cyber
                                                        ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt                        -- Identifica a data de criacao do reg. de cobranca na CYBER.
                                                        ,pr_vlsdeved => vr_tab_dados_epr(vr_indice).vlsdevat          -- Saldo devedor
                                                        ,pr_vlpreapg => vr_tab_dados_epr(vr_indice).vlpapgat          -- Valor a regularizar
                                                        ,pr_qtprepag => vr_tab_dados_epr(vr_indice).qtpcalat          -- Prestacoes Pagas
                                                        ,pr_txmensal => vr_tab_dados_epr(vr_indice).txmensal          -- Taxa mensal
                                                        ,pr_txdiaria => vr_tab_dados_epr(vr_indice).txjuremp          -- Taxa diaria
                                                        ,pr_vlprepag => vr_tab_dados_epr(vr_indice).vlppagat          -- Vlr. Prest. Pagas
                                                        ,pr_qtmesdec => vr_tab_dados_epr(vr_indice).qtmdecat          -- Qtd. meses decorridos
                                                        ,pr_dtdpagto => vr_tab_dados_epr(vr_indice).dtdpagto          -- Data de pagamento
                                                        ,pr_cdlcremp => vr_tab_dados_epr(vr_indice).cdlcremp          -- Codigo da linha de credito
                                                        ,pr_cdfinemp => vr_tab_dados_epr(vr_indice).cdfinemp          -- Codigo da finalidade.
                                                        ,pr_dtefetiv => vr_tab_dados_epr(vr_indice).dtmvtolt          -- Data da efetivacao do emprestimo.
                                                        ,pr_vlemprst => vr_tab_dados_epr(vr_indice).vlemprst          -- Valor emprestado.
                                                        ,pr_qtpreemp => vr_tab_dados_epr(vr_indice).qtpreemp          -- Quantidade de prestacoes.
                                                        ,pr_flgfolha => vr_tab_dados_epr(vr_indice).flgpagto          -- O pagamento e por Folha
                                                        ,pr_vljura60 => vr_tab_crapris(vr_des_chave_crapris).vljura60 + vr_tab_crapris(vr_des_chave_crapris).vljurantpp -- Juros 60 dias + jurantpp
                                                        ,pr_vlpreemp => vr_tab_crapris(vr_des_chave_crapris).vlpreemp -- Valor da prestacao
                                                        ,pr_qtpreatr => vr_tab_crapris(vr_des_chave_crapris).nroprest -- Qtd. Prestacoes
                                                        ,pr_vldespes => vr_vlpreatr                                   -- Valor despesas
                                                        ,pr_vlperris => vr_percentu                                   -- Valor percentual risco
                                                        ,pr_nivrisat => vr_dsnivris                                   -- Risco atual
                                                        ,pr_nivrisan => vr_nivrisco                                   -- Risco anterior
                                                        ,pr_dtdrisan => vr_dtdrisco                                   -- Data risco anterior
                                                        ,pr_qtdiaris => vr_qtdiaris                                   -- Quantidade dias risco
                                                        ,pr_qtdiaatr => vr_tab_crapris(vr_des_chave_crapris).qtdiaatr -- Dias de atraso
                                                        ,pr_flgrpeco => vr_flgrpeco                                   -- Grupo Economico
                                                        ,pr_flgpreju => vr_tab_dados_epr(vr_indice).inprejuz          -- Esta em prejuizo.
                                                        ,pr_flgconsg => vr_flgconsg                                   --Indicador de valor consignado.
                                                        ,pr_flgresid => vr_flgresid                                   -- Flag de residuo
                                                        ,pr_dscritic => pr_dscritic);

                     IF pr_dscritic IS NOT NULL  THEN
                      pc_log_programa(PR_DSTIPLOG     => 'O',
                                      PR_CDPROGRAMA   => pr_cdprogra,
                                      pr_cdcooper     => pr_cdcooper,
                                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                      pr_tpocorrencia => 4,
                                      pr_dsmensagem   => 'ERRO01 - CYBER'||vr_tab_crapris(vr_des_chave_crapris).nrdconta||' '||
                                                         vr_tab_crapris(vr_des_chave_crapris).nrctremp||' '||
                                                         vr_cdorigem||' '||
                                                         TO_CHAR(pr_rw_crapdat.dtmvtolt,'DD/MM/RRRR'),
                                      PR_IDPRGLOG     => vr_idlog_ini_ger);
                        
                     
                    RAISE vr_exc_erro;
                  END IF;
                END IF;

              END IF; -- IF vr_indice IS NOT NULL THEN

            -- Origem de conta corrente e Adiant. a Depositante
            -- Somente se a conta não está em prejuízo (e se não foi liquidada na data atual)
            -- Contas em prejuízo são procesadas na PC_CRPS656 (Reginaldo/AMcom - P450)
               ELSIF vr_dsorigem = 'C'
                 AND vr_tab_crapris(vr_des_chave_crapris).cdmodali = 0101 
                 AND nvl(vr_tab_crapris(vr_des_chave_crapris).inprejuz,0) = 0 
                 AND NOT PREJ0003.fn_verifica_liquidacao_preju(pr_cdcooper => pr_cdcooper
                                                             , pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                                                             , pr_dtmvtolt => pr_rw_crapdat.dtmvtolt) THEN

              -- Grupo economico
                  IF vr_pertenge = '*'  THEN
                vr_flgrpeco := 1;
              ELSE
                vr_flgrpeco := 0;
              END IF;

              -- Somente atualiza os dados para o Cyber caso nao esteja rodando na Cecred
              IF pr_cdcooper <> 3 AND pr_flgrelat = 0 THEN
                -- Atualizar os contratos em cobranca do CYBER
                cybe0001.pc_atualiza_dados_financeiro (pr_cdcooper => pr_cdcooper                                   -- Codigo da Cooperativa
                                                      ,pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta -- Numero da conta
                                                      ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp -- Numero do contrato
                                                      ,pr_cdorigem => 1                                             -- Conta corrente
                                                      ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt                        -- Identifica a data de criacao do reg. de cobranca na CYBER.
                                                      ,pr_dtdpagto => pr_rw_crapdat.dtmvtolt                        -- Data de pagamento
                                                      ,pr_dtefetiv => pr_rw_crapdat.dtmvtolt                        -- Data da efetivacao do emprestimo.
                                                      ,pr_qtpreemp => 1                                             -- Quantidade de prestacoes.
                                                      ,pr_vlemprst => vr_vldivida                                   -- Valor emprestado.
                                                      ,pr_vlsdeved => vr_vldivida + NVL(vr_tab_crapris(vr_des_chave_crapris).vliofmes,0)   -- Saldo devedor
                                                      ,pr_vljura60 => vr_tab_crapris(vr_des_chave_crapris).vljura60 -- Juros 60 dias
                                                      ,pr_vlpreemp => vr_tab_crapris(vr_des_chave_crapris).vlpreemp -- Valor da prestacao
                                                      ,pr_qtpreatr => vr_tab_crapris(vr_des_chave_crapris).nroprest -- Qtd. Prestacoes
                                                      ,pr_vlpreapg => vr_vldivida + NVL(vr_tab_crapris(vr_des_chave_crapris).vliofmes,0)   -- Valor a regularizar
                                                      ,pr_vldespes => vr_vlpreatr                                   -- Valor despesas
                                                      ,pr_vlperris => vr_percentu                                   -- Valor percentual risco
                                                      ,pr_nivrisat => vr_dsnivris                                   -- Risco atual
                                                      ,pr_nivrisan => vr_nivrisco                                   -- Risco anterior
                                                      ,pr_dtdrisan => vr_dtdrisco                                   -- Data risco anterior
                                                      ,pr_qtdiaris => vr_qtdiaris                                   -- Quantidade dias risco
                                                      ,pr_qtdiaatr => vr_tab_crapris(vr_des_chave_crapris).qtatraso -- Dias de atraso
                                                      ,pr_flgrpeco => vr_flgrpeco                                   -- Grupo Economico
                                                      ,pr_flgresid => 0                                             -- Flag de residuo
                                                      ,pr_qtprepag => 0                                             -- Prestacoes Pagas
                                                      ,pr_txmensal => vr_txmensal                                   -- Taxa mensal
                                                      ,pr_txdiaria => 0                                             -- Taxa diaria
                                                      ,pr_vlprepag => 0                                             -- Vlr. Prest. Pagas
                                                      ,pr_qtmesdec => 0                                             -- Qtd. meses decorridos
                                                      ,pr_cdlcremp => 0                                             -- Codigo da linha de credito
                                                      ,pr_cdfinemp => 0                                             -- Codigo da finalidade.
                                                      ,pr_flgfolha => 0                                             -- O pagamento e por Folha
                                                      ,pr_flgpreju => 0                                             -- Esta em prejuizo.
                                                      ,pr_flgconsg => 0                                             --Indicador de valor consignado.
                                                      ,pr_dscritic => pr_dscritic);

                  IF pr_dscritic IS NOT NULL  THEN
                      pc_log_programa(PR_DSTIPLOG     => 'O',
                                      PR_CDPROGRAMA   => pr_cdprogra,
                                      pr_cdcooper     => pr_cdcooper,
                                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                      pr_tpocorrencia => 4,
                                      pr_dsmensagem   => 'ERRO01 - CYBER'||vr_tab_crapris(vr_des_chave_crapris).nrdconta||' '||
                                                         vr_tab_crapris(vr_des_chave_crapris).nrctremp||' '||
                                                         1||' '||
                                                         TO_CHAR(pr_rw_crapdat.dtmvtolt,'DD/MM/RRRR'),
                                      PR_IDPRGLOG     => vr_idlog_ini_ger);
                    
                  RAISE vr_exc_erro;
                END IF;
              END IF;

            --AWAE: Enviar os títulos de Desconto para a tabela da CYBER.
            ELSIF vr_dsorigem = 'D' AND vr_tab_crapris(vr_des_chave_crapris).cdmodali = 301  THEN
              -- inicializando o valor
              vr_vlpreapg := 0;
              vr_indice_dados_tdb := vr_tab_craptdb.first;
              WHILE vr_indice_dados_tdb IS NOT NULL LOOP
                IF (vr_tab_craptdb(vr_indice_dados_tdb).cdcooper = pr_cdcooper AND
                    vr_tab_craptdb(vr_indice_dados_tdb).nrdconta = vr_tab_crapris(vr_des_chave_crapris).nrdconta AND
                    vr_tab_craptdb(vr_indice_dados_tdb).nrborder = vr_tab_crapris(vr_des_chave_crapris).nrctremp AND
                    vr_tab_craptdb(vr_indice_dados_tdb).dtlibbdt = vr_tab_crapris(vr_des_chave_crapris).dtinictr AND 
                    vr_tab_crapris(vr_des_chave_crapris).cdorigem IN (4,5)) THEN

                  -- Somente atualiza os dados para o Cyber caso nao esteja rodando na Cecred
                  IF pr_cdcooper <> 3 AND pr_flgrelat = 0 THEN
                    -- Atualiza dados do emprestimo para o CYBER
                    cybe0001.pc_atualiza_dados_financeiro(pr_cdcooper => pr_cdcooper                                   -- Codigo da Cooperativa
                                                         ,pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta -- Numero da conta
                                                         ,pr_nrctremp => vr_tab_craptdb(vr_indice_dados_tdb).nrctrdsc  -- Numero do contrato
                                                         ,pr_cdorigem => 4                                             -- Origem cyber
                                                         ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt                        -- Identifica a data de criacao do reg. de cobranca na CYBER.
                                                         ,pr_vlsdeved => vr_tab_craptdb(vr_indice_dados_tdb).vlsldtit  -- Saldo devedor
                                                         ,pr_vlpreapg => vr_tab_craptdb(vr_indice_dados_tdb).vlatraso  -- Valor a regularizar
                                                         ,pr_qtprepag => vr_tab_craptdb(vr_indice_dados_tdb).qtprepag  -- Prestacoes Pagas
                                                         ,pr_txmensal => vr_tab_craptdb(vr_indice_dados_tdb).txmensal  -- Taxa mensal
                                                         ,pr_txdiaria => vr_tab_craptdb(vr_indice_dados_tdb).txdiaria  -- Taxa diaria
                                                         ,pr_vlprepag => vr_tab_craptdb(vr_indice_dados_tdb).vlprepag  -- Vlr. Prest. Pagas
                                                         ,pr_qtmesdec => vr_tab_craptdb(vr_indice_dados_tdb).qtmesdec  -- Qtd. meses decorridos
                                                         ,pr_dtdpagto => vr_tab_craptdb(vr_indice_dados_tdb).dtdpagto  -- Data de pagamento
                                                         ,pr_cdlcremp => vr_tab_craptdb(vr_indice_dados_tdb).cddlinha  -- Codigo da linha de credito
                                                         ,pr_cdfinemp => 0                                             -- Codigo da finalidade.
                                                         ,pr_dtefetiv => vr_tab_craptdb(vr_indice_dados_tdb).dtlibbdt  -- Data da efetivacao do emprestimo.
                                                         ,pr_vlemprst => vr_tab_craptdb(vr_indice_dados_tdb).vltitulo  -- Valor emprestado.
                                                         ,pr_qtpreemp => 1                                             -- Quantidade de prestacoes.
                                                         ,pr_flgfolha => 0                                             -- O pagamento e por Folha
                                                         ,pr_vljura60 => vr_tab_craptdb(vr_indice_dados_tdb).vljura60  -- Juros 60 dias --,pr_vljura60 => vr_tab_crapris(vr_des_chave_crapris).vljura60 -- Juros 60 dias (CRAPRIS)
                                                         ,pr_vlpreemp => vr_tab_craptdb(vr_indice_dados_tdb).vltitulo  -- Valor da prestacao
                                                         ,pr_qtpreatr => 1                                             -- Qtd. Prestacoes
                                                         ,pr_vldespes => vr_vlpreatr                                   -- Valor despesas
                                                         ,pr_vlperris => vr_percentu                                   -- Valor percentual risco
                                                         ,pr_nivrisat => vr_dsnivris                                   -- Risco atual
                                                         ,pr_nivrisan => vr_nivrisco                                   -- Risco anterior
                                                         ,pr_dtdrisan => vr_dtdrisco                                   -- Data risco anterior
                                                         ,pr_qtdiaris => vr_qtdiaris                                   -- Quantidade dias risco
                                                         ,pr_qtdiaatr => vr_tab_craptdb(vr_indice_dados_tdb).qtdiaatr  -- Dias de atraso
                                                         ,pr_flgrpeco => vr_flgrpeco                                   -- Grupo Economico
                                                         ,pr_flgpreju => vr_tab_craptdb(vr_indice_dados_tdb).inprejuz  -- Esta em prejuizo.
                                                         ,pr_flgconsg => 0                                             --Indicador de valor consignado.
                                                         ,pr_flgresid => 0                                             -- Flag de residuo
                                                         ,pr_nrborder => vr_tab_craptdb(vr_indice_dados_tdb).nrborder  --> Numero do bordero do titulo em atraso no cyber
                                                         ,pr_nrtitulo => vr_tab_craptdb(vr_indice_dados_tdb).nrtitulo  --> Numero do titulo em atraso no cyber
                                                         ,pr_dtprejuz => vr_tab_craptdb(vr_indice_dados_tdb).dtprejuz  --> Data em que o bordero entrou em prejuizo
                                                         ,pr_vlsdprej => vr_tab_craptdb(vr_indice_dados_tdb).vlsdprej  --> Valor de prejuizo do titulo
                                                         ,pr_dscritic => pr_dscritic);
                    IF pr_dscritic IS NOT NULL  THEN
                      pc_log_programa(PR_DSTIPLOG     => 'O',
                                      PR_CDPROGRAMA   => pr_cdprogra,
                                      pr_cdcooper     => pr_cdcooper,
                                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                      pr_tpocorrencia => 4,
                                      pr_dsmensagem   => 'ERRO01 - CYBER'||vr_tab_crapris(vr_des_chave_crapris).nrdconta||' '||
                                                         vr_tab_craptdb(vr_indice_dados_tdb).nrctrdsc||' '||
                                                         4||' '||
                                                         TO_CHAR(pr_rw_crapdat.dtmvtolt,'DD/MM/RRRR'),
                                      PR_IDPRGLOG     => vr_idlog_ini_ger);
                      
                      RAISE vr_exc_erro;
                    END IF;
                  END IF;
                END IF;
                vr_indice_dados_tdb := vr_tab_craptdb.next(vr_indice_dados_tdb);
              END LOOP;
            END IF;

            -- Enviar a linha arquivo arquivo 354.txt
            gene0002.pc_escreve_xml(pr_xml => vr_clob_354
                                    ,pr_texto_completo => vr_txtarqui_354
                                    ,pr_texto_novo =>RPAD(vr_tab_crapris(vr_des_chave_crapris).nrdconta,8,' ')||vr_dssepcol_354
                                                   ||RPAD(vr_tab_crapris(vr_des_chave_crapris).nmprimtl,50,' ')||vr_dssepcol_354
                                                   ||RPAD(vr_tab_crapris(vr_des_chave_crapris).tpemprst,4,' ')||vr_dssepcol_354
                                                   ||vr_dsorigem||vr_dssepcol_354
                                                   ||LPAD(to_char(vr_tab_crapris(vr_des_chave_crapris).nrctremp,'fm99999999'),8,' ')||vr_dssepcol_354
                                                   ||RPAD(vr_cdlcremp_354,8,' ')||vr_dssepcol_354
                                                   ||RPAD(vr_vldivida,8,' ')||vr_dssepcol_354
                                                   ||RPAD(NVL(to_char(vr_tab_crapris(vr_des_chave_crapris).vljura60),' '),8,' ')||vr_dssepcol_354
                                                   -- P577 - Inicio
                                                   ||RPAD(NVL(to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).vljurantpp, 0)),' '),8,' ')||vr_dssepcol_354
                                                   -- P577 - Fim
                                                   ||RPAD(NVL(to_char(vr_tab_crapris(vr_des_chave_crapris).vlpreemp),' '),8,' ')||vr_dssepcol_354
                                                   ||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).nroprest,0),'999990d00')||vr_dssepcol_354
                                                   ||RPAD(vr_vltotatr,8,' ')||vr_dssepcol_354
                                                   ||RPAD(vr_vlpreatr,8,' ')||vr_dssepcol_354
                                                   ||LPAD(to_char(vr_percentu,'fm990d00'),6,' ')||vr_dssepcol_354
                                                   ||LPAD(vr_tab_crapris(vr_des_chave_crapris).cdagenci,3,' ')||vr_dssepcol_354
                                                   ||to_char(vr_tab_crapris(vr_des_chave_crapris).qtatraso,'999990d00')||vr_dssepcol_354
                                                   ||RPAD(vr_dsnivris,8,' ')||vr_dssepcol_354
                                                   ||RPAD(vr_nivrisco,8,' ')||vr_dssepcol_354
                                                   ||to_char(vr_dtdrisco,'dd/mm/rr')||vr_dssepcol_354
                                                   ||RPAD(vr_qtdiaris,8,' ')||vr_dssepcol_354
                                                   ||LPAD(to_char(vr_tab_crapris(vr_des_chave_crapris).qtdiaatr,'fm99999999'),10,' ') || vr_dssepcol_354
                                                   ||LPAD(to_char(NVL(vr_vlpreapg,0),'fm999G999G999G990D00'),18,' ')
                                                   ||chr(10));

          END IF;
        END IF;

        -- Se é o ultimo registro do PAC ou é o ultro registro da tabela
         IF vr_des_chave_crapris = vr_tab_crapris.LAST OR vr_tab_crapris(vr_tab_crapris.NEXT(vr_des_chave_crapris)).cdagenci <> vr_tab_crapris(vr_des_chave_crapris).cdagenci THEN

          -- Se uma das variáveis de pac estão ativas
          IF vr_flgpac01 OR vr_flgpac02 THEN

            -- Testar caso uma das flags não esteja ativa e em caso positivo enviar a tag da agência
            -- pois mesmo não existindo detalhes do 227 ou do 354 existe do outro, e então temos que
            -- enviar as informações totalizadoras e de risco
            IF NOT vr_flgpac01 THEN
              -- Criar a tag do PAC no relatório
              gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                     ,pr_texto_completo => vr_txtauxi_227
                                     ,pr_texto_novo     =>'<agencia cdagenci="'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'" nmresage="'||vr_nmresage||'">');
              -- Ativar flag para não enviar mais a tag de agência
              vr_flgpac01 := true;
            END IF;

            IF NOT vr_flgpac02 THEN
              -- Criar a tag do PAC no relatório
              gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                                     ,pr_texto_completo => vr_txtauxi_354
                                     ,pr_texto_novo     => '<agencia cdagenci="'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'" nmresage="'||vr_nmresage||'">');
              -- Ativar flag para não enviar mais a tag de agência
              vr_flgpac02 := true;
            END IF;

            -- Somente calcular o total percentual se saldo devedor > 0
            IF vr_tot_vlsdeved > 0 THEN
                  vr_med_percentu := (vr_tot_vlatraso / vr_tot_vlsdeved)*100;
            ELSE
              vr_med_percentu := null;
            END IF;

            -- Somente se houver valor de operação
            IF vr_tot_vlropera <> 0 THEN
                  vr_med_atrsinad := ROUND(((vr_tot_vlatrasa / vr_tot_vlropera) * 100),2);
            ELSE
              vr_med_atrsinad := 0;
            END IF;

            -- Somente se houver valor de operação por pessoa fisica
            IF vr_tot_vlropfis <> 0 THEN
                  vr_med_atindfis := ROUND(((vr_tot_vlatrfis / vr_tot_vlropfis) * 100),2);
            ELSE
              vr_med_atindfis := 0;
            END IF;

            -- Somente se houver valor de operação por pessoa juridica
            IF vr_tot_vlropjur <> 0 THEN
                  vr_med_atindjur := ROUND(((vr_tot_vlatrjur / vr_tot_vlropjur) * 100),2);
            ELSE
              vr_med_atindjur := 0;
            END IF;

            -- Montar informações de totalização e provisão
            vr_des_xml_gene := '<totalizacao>'
                             || '  <qtctremp>'||to_char(vr_tot_qtctremp,'fm999g990')||'</qtctremp>'
                             || '  <vlsdvatr>'||to_char(vr_tot_vlsdvatr,'fm999g999g999g990d00')||'</vlsdvatr>'
                             -- P577 - Inicio
                             || '  <vltotjur60>'||to_char(vr_tot_vltotjur60,'fm999g999g999g990d00')||'</vltotjur60>'
                             || '  <vltotjurant60>'||to_char(vr_tot_vltotjurant60,'fm999g999g999g990d00')||'</vltotjurant60>'
                             -- P577 - Fim
                             || '  <vlatraso>'||to_char(vr_tot_vlatraso,'fm999g999g999g990d00')||'</vlatraso>'
                             || '  <qtempres>'||to_char(vr_tot_qtempres,'fm999g990')||'</qtempres>'
                             || '  <vlsdeved>'||to_char(vr_tot_vlsdeved,'fm999g999g999g990d00')||'</vlsdeved>'
                             || '  <percentu>'||to_char(vr_med_percentu,'fm990d00')||'</percentu>'
                             || '  <vlpreatr>'||to_char(vr_tot_vlpreatr,'fm999g999g999g990d00')||'</vlpreatr>'
                             || '  <qtctrato>'||to_char(vr_tot_qtctrato,'fm999g990')||'</qtctrato>'
                             || '  <vldespes>'||to_char(vr_tot_vldespes,'fm999g999g999g990d00')||'</vldespes>'
                             || '  <percbase>'||to_char(vr_percbase,'fm990d00')||'</percbase>'
                             || '  <qtdopera>'||to_char(vr_tot_qtdopera,'fm999g990')||'</qtdopera>'
                             || '  <qtdopfis>'||to_char(vr_tot_qtdopfis,'fm999g990')||'</qtdopfis>'
                             || '  <qtdopjur>'||to_char(vr_tot_qtdopjur,'fm999g990')||'</qtdopjur>'
                             || '  <vlropera>'||to_char(vr_tot_vlropera,'fm999g999g999g990d00')||'</vlropera>'
                             || '  <vlropfis>'||to_char(vr_tot_vlropfis,'fm999g999g999g990d00')||'</vlropfis>'
                             || '  <vlropjur>'||to_char(vr_tot_vlropjur,'fm999g999g999g990d00')||'</vlropjur>'
                             || '  <qtatrasa>'||to_char(vr_tot_qtatrasa,'fm999g990')||'</qtatrasa>'
                             || '  <qtatrfis>'||to_char(vr_tot_qtatrfis,'fm999g990')||'</qtatrfis>'
                             || '  <qtatrjur>'||to_char(vr_tot_qtatrjur,'fm999g990')||'</qtatrjur>'
                             || '  <vlatrasa>'||to_char(vr_tot_vlatrasa,'fm999g999g999g990d00')||'</vlatrasa>'
                             || '  <vlatrfis>'||to_char(vr_tot_vlatrfis,'fm999g999g999g990d00')||'</vlatrfis>'
                             || '  <vlatrjur>'||to_char(vr_tot_vlatrjur,'fm999g999g999g990d00')||'</vlatrjur>'
                             || '  <atrsinad>'||to_char(nvl(vr_atrsinad,0),'fm990')||'</atrsinad>'
                             || '  <med_atrsinad>'||to_char(vr_med_atrsinad,'fm999g990d00')||'%</med_atrsinad>'
                             || '  <med_atindfis>'||to_char(vr_med_atindfis,'fm999g990d00')||'%</med_atindfis>'
                             || '  <med_atindjur>'||to_char(vr_med_atindjur,'fm999g990d00')||'%</med_atindjur>'
                             || '  <vlprejuz/>'
                             || '</totalizacao>';

            -- Enviar informações de totalização para os relatórios 1 e 2
               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                    ,pr_texto_completo => vr_txtauxi_227
                                    ,pr_texto_novo     => vr_des_xml_gene);
               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                                      ,pr_texto_completo => vr_txtauxi_354
                                      ,pr_texto_novo     => vr_des_xml_gene);
            -- Reiniciar string genérica
            vr_des_xml_gene := '<tabriscos>';

            -- Para cada registro da tabela de riscos por PAC (Navegar somente até last-1 para não mostrar o HH)
               FOR vr_ind IN vr_tab_totrispac.FIRST..vr_tab_totrispac.LAST-1 LOOP
              -- Criar uma nova tag para o risco atual
              vr_des_xml_gene := vr_des_xml_gene
                              ||'<risco>'
                              ||' <dsdrisco>'||vr_tab_risco(vr_ind).dsdrisco||'</dsdrisco>'
                              ||' <percentu>'||to_char(vr_tab_risco(vr_ind).percentu,'fm990d00')||'</percentu>'
                              ||' <qtdabase>'||to_char(vr_tab_totrispac(vr_ind).qtdabase,'fm999g990')||'</qtdabase>'
                              ||' <vldabase>'||to_char(vr_tab_totrispac(vr_ind).vldabase,'fm999g999g999g990d00')||'</vldabase>'
                              ||' <vljrpf60>'||to_char(vr_tab_totrispac(vr_ind).vljrpf60,'fm999g999g999g990d00')||'</vljrpf60>'
                              ||' <vljrpj60>'||to_char(vr_tab_totrispac(vr_ind).vljrpj60,'fm999g999g999g990d00')||'</vljrpj60>'
                              ||' <vljura60>'||to_char(vr_tab_totrispac(vr_ind).vljura60,'fm999g999g999g990d00')||'</vljura60>'
                              ||' <vlprovis>'||to_char(vr_tab_totrispac(vr_ind).vlprovis,'fm999g999g999g990d00')||'</vlprovis>'
                              ||'</risco>';
            END LOOP;

            -- Fechar tag de tab de riscos
               vr_des_xml_gene := vr_des_xml_gene||'</tabriscos>';

            -- Enviar o quadro de valores por risco montado na string
               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                      ,pr_texto_completo => vr_txtauxi_227
                                      ,pr_texto_novo     => vr_des_xml_gene);

            -- Zerar os totalizadores por risco por PAC
            vr_tab_totrispac.DELETE;

            -- Fechar a tag do PAC nos relatórios 227 e 354 (1 e 2)
               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                      ,pr_texto_completo => vr_txtauxi_227
                                      ,pr_texto_novo     => '</agencia>');

               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                                      ,pr_texto_completo => vr_txtauxi_354
                                      ,pr_texto_novo     => '</agencia>');

            -- Sumarizar totalizadores
            vr_tot_qtctremp_geral := vr_tot_qtctremp_geral + vr_tot_qtctremp;
            vr_tot_vlpreatr_geral := vr_tot_vlpreatr_geral + vr_tot_vlpreatr;
            vr_tot_qtctrato_geral := vr_tot_qtctrato_geral + vr_tot_qtctrato;
            vr_tot_vldespes_geral := vr_tot_vldespes_geral + vr_tot_vldespes;
            vr_tot_qtempres_geral := vr_tot_qtempres_geral + vr_tot_qtempres;
            vr_tot_vlatraso_geral := vr_tot_vlatraso_geral + vr_tot_vlatraso;
            vr_tot_vlsdeved_geral := vr_tot_vlsdeved_geral + vr_tot_vlsdeved;
            vr_tot_qtdopera_geral := vr_tot_qtdopera_geral + vr_tot_qtdopera;
            vr_tot_qtdopfis_geral := vr_tot_qtdopfis_geral + vr_tot_qtdopfis;
            vr_tot_qtdopjur_geral := vr_tot_qtdopjur_geral + vr_tot_qtdopjur;
            vr_tot_vlropera_geral := vr_tot_vlropera_geral + vr_tot_vlropera;
            vr_tot_vlropfis_geral := vr_tot_vlropfis_geral + vr_tot_vlropfis;
            vr_tot_vlropjur_geral := vr_tot_vlropjur_geral + vr_tot_vlropjur;
            vr_tot_qtatrasa_geral := vr_tot_qtatrasa_geral + vr_tot_qtatrasa;
            vr_tot_qtatrfis_geral := vr_tot_qtatrfis_geral + vr_tot_qtatrfis;
            vr_tot_qtatrjur_geral := vr_tot_qtatrjur_geral + vr_tot_qtatrjur;
            vr_tot_vlatrasa_geral := vr_tot_vlatrasa_geral + vr_tot_vlatrasa;
            vr_tot_vlatrfis_geral := vr_tot_vlatrfis_geral + vr_tot_vlatrfis;
            vr_tot_vlatrjur_geral := vr_tot_vlatrjur_geral + vr_tot_vlatrjur;
          END IF;
        END IF;

        --Agupar valores microcrédito das filiadas por finalidade
         IF pr_cdcooper = 3 AND (TRUNC(pr_rw_crapdat.dtmvtolt,'mm') <> TRUNC(pr_rw_crapdat.dtmvtopr,'mm')) THEN

            -- com a migracao da carteira ira gerar contrato pos com isso deve ignroar
            IF vr_tab_crapris(vr_des_chave_crapris).tpemprst = 'TR' THEN
              IF ((vr_tab_crapris(vr_des_chave_crapris).cdfinemp IN (1,4) AND
                  vr_tab_crapris(vr_des_chave_crapris).cdusolcr = 1) OR
                  (vr_tab_crapris(vr_des_chave_crapris).cdfinemp IN (2,3)) AND
                   vr_tab_crapris(vr_des_chave_crapris).cdusolcr = 0) AND
                 vr_tab_crapris(vr_des_chave_crapris).dsorgrec <> ' ' THEN

              -- Garantir que a finalidade exista na PL Table
              IF NOT vr_tab_miccred_fin.exists(vr_tab_crapris(vr_des_chave_crapris).cdfinemp) THEN
                   vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vllibctr    := 0;
                   vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlaprrec    := 0;
                   vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlprvper    := 0;
                   vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar91  := 0;
                   vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar95  := 0;
                vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar441 := 0;
              END IF;

              --Apenas contratos liberados no mês
                 IF vr_tab_crapris(vr_des_chave_crapris).dtinictr BETWEEN TRUNC(pr_rw_crapdat.dtmvtolt,'mm') 
                                                                   AND pr_rw_crapdat.dtmvtolt THEN
                vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vllibctr := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vllibctr + vr_tab_dados_epr(vr_indice).vlemprst;
              END IF;

              vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlaprrec := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlaprrec + vr_tab_dados_epr(vr_indice).vljurmes;
              vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlprvper := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlprvper + vr_vlpreatr;

              -- Busca valor de parcelas pagas
                 FOR rw_craplem in cr_craplem(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                                             ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp) LOOP
                IF rw_craplem.cdhistor = 91 then
                  vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar91 := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar91 + rw_craplem.vllanmto;
                ELSIF rw_craplem.cdhistor = 95 then
                  vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar95 := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar95 + rw_craplem.vllanmto;
                ELSE
                  vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar441 := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar441 + rw_craplem.vllanmto;
                END IF;
              END LOOP;

              --Agupar valores microcrédito das filiadas por nível de risco
                 IF vr_tab_crapris(vr_des_chave_crapris).cdfinemp IN (1,4) THEN
                IF vr_tab_miccred_nivris.exists(vr_dsnivris) THEN
                  vr_tab_miccred_nivris(vr_dsnivris).vlslddev := vr_tab_miccred_nivris(vr_dsnivris).vlslddev + vr_vldivida;
                ELSE
                  vr_tab_miccred_nivris(vr_dsnivris).vlslddev := vr_vldivida;
                END IF;
              END IF;
            END IF;
          END IF; -- TR
          
          /* PROGRAMA PESE BNDES */
          IF vr_tab_crapris(vr_des_chave_crapris).cdusolcr = 3 THEN
            v_pese_vldivida := v_pese_vldivida + vr_tab_crapris(vr_des_chave_crapris).vldivida;

            v_pese_vlaprrec := v_pese_vlaprrec + vr_tab_dados_epr(vr_indice).vljurmes;
            v_pese_vlprvper := v_pese_vlprvper + vr_vlpreatr;

            --Agupar valores microcrédito das filiadas por nível de risco
            IF vr_tab_crapris(vr_des_chave_crapris).cdfinemp IN (1,4) THEN
              IF vr_tab_pese_nivris.exists(vr_dsnivris) THEN
                vr_tab_pese_nivris(vr_dsnivris).vlslddev := vr_tab_pese_nivris(vr_dsnivris).vlslddev + vr_vldivida;
              ELSE
                vr_tab_pese_nivris(vr_dsnivris).vlslddev := vr_vldivida;
              END IF;
            END IF;
          END IF;
          /* FIM PROGRAMA PESE BNDES */

          --Agrupar informações operação finame
          IF vr_tab_crapris(vr_des_chave_crapris).cdmodali = 201 THEN

            -- Verifica se contrato é finame
               OPEN cr_craplim(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                              ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp);
               FETCH cr_craplim INTO rw_craplim;
            CLOSE cr_craplim;
            --
            IF rw_craplim.existe_contrato_finame > 0 THEN

              IF vr_tab_crapris(vr_des_chave_crapris).dtinictr >= TRUNC(pr_rw_crapdat.dtmvtolt,'mm') AND
                 vr_tab_crapris(vr_des_chave_crapris).dtinictr <= pr_rw_crapdat.dtmvtolt THEN

                    vr_tot_libctnfiname   := vr_tot_libctnfiname + vr_vldivida;

              END IF;

              vr_tot_prvperdafiname := vr_tot_prvperdafiname + vr_vlpreatr;

              --Agrupar valores de finame por nível de risco
              IF vr_tab_finame_nivris.exists(vr_dsnivris) THEN
                vr_tab_finame_nivris(vr_dsnivris).vlslddev := vr_tab_finame_nivris(vr_dsnivris).vlslddev + vr_vldivida;
              ELSE
                vr_tab_finame_nivris(vr_dsnivris).vlslddev := vr_vldivida;
              END IF;
            END IF;
          END IF;
        END IF;
        --
        -- Buscar o próximo registro
        vr_des_chave_crapris := vr_tab_crapris.NEXT(vr_des_chave_crapris);
      END LOOP;

      pc_log_programa(PR_DSTIPLOG     => 'O',
                      PR_CDPROGRAMA   => pr_cdprogra,
                      pr_cdcooper     => pr_cdcooper,
                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia => 4,
                      pr_dsmensagem   => 'Fim01 - loop tab men. AGENCIA: ' ||pr_cdagenci ||
                                         ' - INPROCES: ' ||pr_rw_crapdat.inproces ||
                                         ' - Horário: ' ||to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss'),
                      PR_IDPRGLOG     => vr_idlog_ini_ger);

      --Gerar arquivo de operações de micro crédito e finame das filiadas
      IF (TRUNC(pr_rw_crapdat.dtmvtolt,'mm') <> TRUNC(pr_rw_crapdat.dtmvtopr,'mm')) THEN

        -- Formata a data para criar o nome do arquivo
        vr_dtmvtolt_yymmdd := to_char(pr_rw_crapdat.dtmvtolt, 'yymmdd');

        -- Busca do diretório onde ficará o arquivo
        vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                  pr_cdcooper => pr_cdcooper,
                                                  pr_nmsubdir => 'contab');

        -- Busca do diretório onde o Radar ou Matera pegará o arquivo
         vr_nom_dir_copia := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                    ,pr_cdcooper => 0
                                                    ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');

        --Apenas para cecred e apenas no último dia do mês
        IF pr_cdcooper = 3 THEN
          --Gera arquivo de operação de microcrédito
          pc_gera_arq_miccred(pr_dscritic);

          IF pr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          --Gera arquivo de operação de finame
          pc_gera_arq_finame(pr_dscritic);

          IF pr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        ELSE
          --Gerar somente para as filiadas
        --Gera arquivo de compensação de microcredito
        pc_gera_arq_compe_mic(pr_dscritic);
        END IF;
      END IF;

      -- Agora iremos enviar o PAC 99 como totalizador das informações
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => '<agencia cdagenci="99" nmresage="TOTALIZACAO">');

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => '<agencia cdagenci="99" nmresage="TOTALIZACAO">');

      -- Somente calcular o total percentual se saldo devedor > 0
      IF vr_tot_vlsdeved_geral > 0 THEN
         vr_med_percentu := (vr_tot_vlatraso_geral / vr_tot_vlsdeved_geral)*100;
      ELSE
        vr_med_percentu := NULL;
      END IF;

      -- Somente se houver valor de operação
      IF vr_tot_vlropera_geral <> 0 THEN
         vr_med_atrsinad_geral := ROUND(((vr_tot_vlatrasa_geral / vr_tot_vlropera_geral) * 100),2);
      ELSE
        vr_med_atrsinad_geral := 0;
      END IF;

      -- Somente se houver valor de operação de pessoa fisica
      IF vr_tot_vlropfis_geral <> 0 THEN
         vr_med_atindfis_geral := ROUND(((vr_tot_vlatrfis_geral / vr_tot_vlropfis_geral) * 100),2);
      ELSE
        vr_med_atindfis_geral := 0;
      END IF;

      -- Somente se houver valor de operação de pessoa juridica
      IF vr_tot_vlropjur_geral <> 0 THEN
         vr_med_atindjur_geral := ROUND(((vr_tot_vlatrjur_geral / vr_tot_vlropjur_geral) * 100),2);
      ELSE
        vr_med_atindjur_geral := 0;
      END IF;

      -- Gerar registro de totalização
      vr_des_xml_gene := '<totalizacao>'
                      || '  <qtctremp>'||to_char(vr_tot_qtctremp_geral,'fm999g990')||'</qtctremp>'
                      || '  <vlsdvatr/>'
                      || '  <vlatraso>'||to_char(vr_tot_vlatraso_geral,'fm999g999g999g990d00')||'</vlatraso>'
                      || '  <qtempres>'||to_char(vr_tot_qtempres_geral,'fm999g990')||'</qtempres>'
                      || '  <vlsdeved>'||to_char(vr_tot_vlsdeved_geral,'fm999g999g999g990d00')||'</vlsdeved>'
                      || '  <percentu>'||to_char(vr_med_percentu,'fm990d00')||'</percentu>'
                      -- P577 - Inicio
                      || '  <vltotjur60>'||to_char(vr_vltotjur60,'fm999g999g999g990d00')||'</vltotjur60>'
                      || '  <vltotjurant60>'||to_char(vr_vltotjurant60,'fm999g999g999g990d00')||'</vltotjurant60>'
                      -- P577 - Fim
                      || '  <vlpreatr>'||to_char(vr_tot_vlpreatr_geral,'fm999g999g999g990d00')||'</vlpreatr>'
                      || '  <qtctrato>'||to_char(vr_tot_qtctrato_geral,'fm999g990')||'</qtctrato>'
                      || '  <vldespes>'||to_char(vr_tot_vldespes_geral,'fm999g999g999g990d00')||'</vldespes>'
                      || '  <qtdopera>'||to_char(vr_tot_qtdopera_geral,'fm999g990')||'</qtdopera>'
                      || '  <qtdopfis>'||to_char(vr_tot_qtdopfis_geral,'fm999g990')||'</qtdopfis>'
                      || '  <qtdopjur>'||to_char(vr_tot_qtdopjur_geral,'fm999g990')||'</qtdopjur>'
                      || '  <vlropera>'||to_char(vr_tot_vlropera_geral,'fm999g999g999g990d00')||'</vlropera>'
                      || '  <vlropfis>'||to_char(vr_tot_vlropfis_geral,'fm999g999g999g990d00')||'</vlropfis>'
                      || '  <vlropjur>'||to_char(vr_tot_vlropjur_geral,'fm999g999g999g990d00')||'</vlropjur>'
                      || '  <qtatrasa>'||to_char(vr_tot_qtatrasa_geral,'fm999g990')||'</qtatrasa>'
                      || '  <qtatrfis>'||to_char(vr_tot_qtatrfis_geral,'fm999g990')||'</qtatrfis>'
                      || '  <qtatrjur>'||to_char(vr_tot_qtatrjur_geral,'fm999g990')||'</qtatrjur>'
                      || '  <vlatrasa>'||to_char(vr_tot_vlatrasa_geral,'fm999g999g999g990d00')||'</vlatrasa>'
                      || '  <vlatrfis>'||to_char(vr_tot_vlatrfis_geral,'fm999g999g999g990d00')||'</vlatrfis>'
                      || '  <vlatrjur>'||to_char(vr_tot_vlatrjur_geral,'fm999g999g999g990d00')||'</vlatrjur>'
                      || '  <atrsinad>'||to_char(nvl(vr_atrsinad,0),'fm990')||'</atrsinad>'
                      || '  <med_atrsinad>'||to_char(vr_med_atrsinad_geral,'fm999g990d00')||'%</med_atrsinad>'
                      || '  <med_atindfis>'||to_char(vr_med_atindfis_geral,'fm999g990d00')||'%</med_atindfis>'
                      || '  <med_atindjur>'||to_char(vr_med_atindjur_geral,'fm999g990d00')||'%</med_atindjur>'
                      || '  <percbase>'||to_char(vr_percbase,'fm990d00')||'</percbase>'
                      || '  <vlprejuz>'||to_char(vr_vlprejuz,'fm999g999g999g990d00')||'</vlprejuz>'
                      || '</totalizacao>';

      -- Enviar as Tags de totalização ao XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => vr_des_xml_gene);

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => vr_des_xml_gene);

      -- Reiniciar string genérica
      vr_des_xml_gene := '<tabriscos>';

      -- Para cada registro da tabela de riscos geral (Navegar somente até last-1 para não mostrar o HH)
      FOR vr_ind IN vr_tab_totrisger.FIRST..vr_tab_totrisger.LAST-1 LOOP
        -- Criar uma nova tag para o risco atual
        vr_des_xml_gene := vr_des_xml_gene
                         ||'<risco>'
                         ||' <dsdrisco>'||vr_tab_risco(vr_ind).dsdrisco||'</dsdrisco>'
                         ||' <percentu>'||to_char(vr_tab_risco(vr_ind).percentu,'fm990d00')||'</percentu>'
                         ||' <qtdabase>'||to_char(vr_tab_totrisger(vr_ind).qtdabase,'fm999g990')||'</qtdabase>'
                         ||' <vldabase>'||to_char(vr_tab_totrisger(vr_ind).vldabase,'fm999g999g999g990d00')||'</vldabase>'
                         ||' <vljrpf60>'||to_char(vr_tab_totrisger(vr_ind).vljrpf60,'fm999g999g999g990d00')||'</vljrpf60>'
                         ||' <vljrpj60>'||to_char(vr_tab_totrisger(vr_ind).vljrpj60,'fm999g999g999g990d00')||'</vljrpj60>'
                         ||' <vljura60>'||to_char(vr_tab_totrisger(vr_ind).vljura60,'fm999g999g999g990d00')||'</vljura60>'
                         ||' <vlprovis>'||to_char(vr_tab_totrisger(vr_ind).vlprovis,'fm999g999g999g990d00')||'</vlprovis>'
                         ||'</risco>';
      END LOOP;

      -- Fechar tag de tab de riscos
      vr_des_xml_gene := vr_des_xml_gene||'</tabriscos>';

      -- Enviar o quadro de valores por risco montado na string
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => vr_des_xml_gene);

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => vr_des_xml_gene);

      -- Zerar o totalizador geral
      vr_tab_totrisger.DELETE;

      -- Enviar o quadro "DADOS PARA CONTABILIDADE", primeiro a tag principal
      vr_des_xml_gene := '<tabcontab>';

      -- Para cada informação, efetuar a chamada que monta a tag completa
      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Financiamentos Pessoais'
                         ,pr_num_valor1 => vr_vet_contabi.rel1731_1
                         ,pr_num_valor2 => vr_vet_contabi.rel1731_1_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlfinanc_pf)(vr_provis)(1).vlfinanc_pf
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlfinanc_pf)(vr_provis)(2).vlfinanc_pf
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlfinanc_pf)(vr_divida)(1).vlfinanc_pf
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlfinanc_pf)(vr_divida)(2).vlfinanc_pf);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Financiamentos Empresas'
                         ,pr_num_valor1 => vr_vet_contabi.rel1731_2
                         ,pr_num_valor2 => vr_vet_contabi.rel1731_2_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlfinanc_pj)(vr_provis)(1).vlfinanc_pj
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlfinanc_pj)(vr_provis)(2).vlfinanc_pj
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlfinanc_pj)(vr_divida)(1).vlfinanc_pj
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlfinanc_pj)(vr_divida)(2).vlfinanc_pj);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Emprestimos Pessoais'
                         ,pr_num_valor1 => vr_vet_contabi.rel5584
                         ,pr_num_valor2 => vr_vet_contabi.rel5584_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlempres_pf)(vr_provis)(1).vlempres_pf
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlempres_pf)(vr_provis)(2).vlempres_pf
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlempres_pf)(vr_divida)(1).vlempres_pf
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlempres_pf)(vr_divida)(2).vlempres_pf);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Emprestimos Empresas'
                         ,pr_num_valor1 => vr_vet_contabi.rel1723
                         ,pr_num_valor2 => vr_vet_contabi.rel1723_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlempres_pj)(vr_provis)(1).vlempres_pj
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlempres_pj)(vr_provis)(2).vlempres_pj
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlempres_pj)(vr_divida)(1).vlempres_pj
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlempres_pj)(vr_divida)(2).vlempres_pj);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Cheques Descontados'
                         ,pr_num_valor1 => vr_vet_contabi.rel1724_c
                         ,pr_num_valor2 => vr_vet_contabi.rel1724_v_c
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlchqdes)(vr_provis)(1).vlchqdes
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlchqdes)(vr_provis)(2).vlchqdes
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlchqdes)(vr_divida)(1).vlchqdes
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlchqdes)(vr_divida)(2).vlchqdes);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Titulos Desc. C/Registro'
                         ,pr_num_valor1 => vr_vet_contabi.rel1724_cr
                         ,pr_num_valor2 => vr_vet_contabi.rel1724_v_cr
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vltitdes_cr)(vr_provis)(1).vltitdes_cr
                         ,pr_num_vlprpj => vr_tab_contab(vr_vltitdes_cr)(vr_provis)(2).vltitdes_cr
                         ,pr_num_vldvpf => vr_tab_contab(vr_vltitdes_cr)(vr_divida)(1).vltitdes_cr
                         ,pr_num_vldvpj => vr_tab_contab(vr_vltitdes_cr)(vr_divida)(2).vltitdes_cr);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Titulos Desc. S/Registro'
                         ,pr_num_valor1 => vr_vet_contabi.rel1724_sr
                         ,pr_num_valor2 => vr_vet_contabi.rel1724_v_sr
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vltitdes_sr)(vr_provis)(1).vltitdes_sr
                         ,pr_num_vlprpj => vr_tab_contab(vr_vltitdes_sr)(vr_provis)(2).vltitdes_sr
                         ,pr_num_vldvpf => vr_tab_contab(vr_vltitdes_sr)(vr_divida)(1).vltitdes_sr
                         ,pr_num_vldvpj => vr_tab_contab(vr_vltitdes_sr)(vr_divida)(2).vltitdes_sr);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Adiant.Depositante'
                         ,pr_num_valor1 => vr_vet_contabi.rel1722_0101
                         ,pr_num_valor2 => vr_vet_contabi.rel1722_0101_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vladtdep)(vr_provis)(1).vladtdep
                         ,pr_num_vlprpj => vr_tab_contab(vr_vladtdep)(vr_provis)(2).vladtdep
                         ,pr_num_vldvpf => vr_tab_contab(vr_vladtdep)(vr_divida)(1).vladtdep
                         ,pr_num_vldvpj => vr_tab_contab(vr_vladtdep)(vr_divida)(2).vladtdep);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Cheque Especial'
                         ,pr_num_valor1 => vr_vet_contabi.rel1722_0201
                         ,pr_num_valor2 => vr_vet_contabi.rel1722_0201_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlchqesp)(vr_provis)(1).vlchqesp
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlchqesp)(vr_provis)(2).vlchqesp
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlchqesp)(vr_divida)(1).vlchqesp
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlchqesp)(vr_divida)(2).vlchqesp);


      -- Dados da cessao de credito
      -- Para cada informação, efetuar a chamada que monta a tag completa
      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Avais e Garantias Prestadas'
                         ,pr_num_valor1 => vr_vet_contabi.rel1760
                         ,pr_num_valor2 => vr_vet_contabi.rel1760_v
                         ,pr_num_vlpvpf => vr_tab_contab_cessao(vr_vleprces)(vr_provis)(1).vlempres_pf
                         ,pr_num_vlprpj => vr_tab_contab_cessao(vr_vleprces)(vr_provis)(2).vlempres_pj
                         ,pr_num_vldvpf => vr_tab_contab_cessao(vr_vleprces)(vr_divida)(1).vlempres_pf
                         ,pr_num_vldvpj => vr_tab_contab_cessao(vr_vleprces)(vr_divida)(2).vlempres_pj
                         ,pr_flcessao   => 1);

      -- FEchar a tag de contabilização
      vr_des_xml_gene := vr_des_xml_gene || '</tabcontab>';

      --Abrir tag microcredito
      vr_des_xml_gene := vr_des_xml_gene || '<tabmicrocredito>';

      --Repete para ordem por grupo de microcredito
      FOR vr_cont in 1..2 LOOP
        vr_chave_microcredito := vr_tab_microcredito.first;
        LOOP

          EXIT WHEN vr_chave_microcredito IS NULL;

          IF vr_tab_microcredito(vr_chave_microcredito).idgrumic = vr_cont THEN
             pc_cria_node_miccre(pr_des_xml          => vr_des_xml_gene
                                ,pr_idgrumic         => vr_tab_microcredito(vr_chave_microcredito).idgrumic
                                ,pr_ds_microcredito  => vr_chave_microcredito
                                ,pr_vlreprec         => vr_tab_microcredito(vr_chave_microcredito).vlpesfis +
                                                        vr_tab_microcredito(vr_chave_microcredito).vlpesjur
                                ,pr_vlempatr         => vr_tab_microcredito(vr_chave_microcredito).vlate90d +
                                                        vr_tab_microcredito(vr_chave_microcredito).vlaci90d -
                                                        vr_tab_microcredito(vr_chave_microcredito).vlj60at90d -
                                                        vr_tab_microcredito(vr_chave_microcredito).vlj60ac90d 
                                ,pr_vlreprec_pf      => vr_tab_microcredito(vr_chave_microcredito).vlpesfis
                                ,pr_vlreprec_pj      => vr_tab_microcredito(vr_chave_microcredito).vlpesjur
																-- PRJ Microcredito
                                ,pr_vlate90d         => vr_tab_microcredito(vr_chave_microcredito).vlate90d
                                ,pr_vlaci90d      	  => vr_tab_microcredito(vr_chave_microcredito).vlaci90d
																-- PRJ Microcredito
                                ,pr_vlj60at90d         => vr_tab_microcredito(vr_chave_microcredito).vlj60at90d
                                ,pr_vlj60ac90d         => vr_tab_microcredito(vr_chave_microcredito).vlj60ac90d
																);     

          END IF;
          vr_chave_microcredito := vr_tab_microcredito.next(vr_chave_microcredito);

        END LOOP;
      END LOOP;

      vr_des_xml_gene := vr_des_xml_gene || '</tabmicrocredito>';

      --Gerar quadro de recursos captados da caixa apenas no crrl227 da central
      IF pr_cdcooper = 3 THEN
        --Abrir tag reccaixa
        vr_des_xml_gene := vr_des_xml_gene || '<tabreccaixa>';

        FOR rw_reccaixa in cr_crapris_reccaixa loop
          vr_des_xml_gene := vr_des_xml_gene
                            ||'<reccaixa>'
                            ||'  <nmrescop_caixa>'||rw_reccaixa.nmrescop||'</nmrescop_caixa>'
                            ||'  <nrctremp_caixa>'||rw_reccaixa.nrctremp||'</nrctremp_caixa>'
                            ||'  <dtinictr_caixa>'||to_char(rw_reccaixa.dtinictr,'dd/mm/rrrr')||'</dtinictr_caixa>'
                            ||'  <vlemprst_caixa>'||to_char(rw_reccaixa.vlemprst,'fm999g999g999g990d00')||'</vlemprst_caixa>'
                            ||'  <vlsdeved_caixa>'||to_char(rw_reccaixa.vlsdeved,'fm999g999g999g990d00')||'</vlsdeved_caixa>'
                            ||'</reccaixa>';
        END LOOP;

        vr_des_xml_gene := vr_des_xml_gene || '</tabreccaixa>';
      END IF;

      -- Zerar totalizadores para Limite não Utilizado (Dados para Bacen)
      vr_vldivida := 0;
      vr_vldivjur := 0;

      -- Busca dos riscos de Limite Não Utilizado
      FOR rw_ris IN cr_ris_liminutz LOOP
        -- Verifica migração/incorporação
         IF NOT fn_verifica_conta_migracao(pr_nrdconta  => rw_ris.nrdconta) THEN
          CONTINUE;
        END IF;

        -- Acumular o valor conforme inpessoa
        IF rw_ris.inpessoa = 1 THEN
          vr_vldivida := vr_vldivida + rw_ris.vldivida;
        ELSE
          vr_vldivjur := vr_vldivjur + rw_ris.vldivida;
        END IF;
      END LOOP;

      -- Enviar o quadro "DADOS PARA BANCO CENTRAL", primeiro a tag principal
      vr_des_xml_gene := vr_des_xml_gene || '<infbacen>'
                                         ||'  <dsinform>Limite contratado e nao utilizado</dsinform>'
                                         ||'  <vldivida>'||to_char(vr_vldivida,'fm999g999g999g990d00')||'</vldivida>'
                                         ||'  <vldivjur>'||to_char(vr_vldivjur,'fm999g999g999g990d00')||'</vldivjur>'
                                         ||'</infbacen>';

      -- Enviar as Tags de contailização ao XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => vr_des_xml_gene);

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => vr_des_xml_gene);

      -- Fechar as tags para o PAC 99
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => '</agencia>');

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => '</agencia>');

      -------- Trecho comum de criação de XML a partir do CLOB ------

      -- Para o crrl227.lst
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

      -- Para o crrl354.lst
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

      -- Para o crrl581.lst
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_581
                             ,pr_texto_completo => vr_txtauxi_581
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

      dbms_output.put_line('Rel.581 em 1: '||vr_nom_direto||'/rl/crrl581.lst');
      -- Solicitar a geração do relatório crrl581
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt               --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml_581                         --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/riscoH'                       --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl581.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl581.lst'     --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => vr_flgerar                           --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'                             --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_cdrelato  => 581                                  --> Qual a seq do cabrel
                                 ,pr_des_erro  => pr_dscritic);                        --> Saída com erro

      dbms_lob.close(vr_clobxml_581);
      dbms_lob.freetemporary(vr_clobxml_581);

      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_erro;
      END IF;

      -- Quando execução em programa diferente do crps184
      IF pr_cdprogra <> 'CRPS184' THEN
        -- Cópia do 354.lst com lógica comum, onde ocorre envio conforme o diretório parametrizado em CRRL354_COPIA.
         vr_dspathcopia := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL354_COPIA');
        -- Se tiver encontrado parâmetro
        IF vr_dspathcopia IS NOT NULL THEN
          -- Se existir o literal [dsdircop] iremos substituí-lo
            vr_dspathcopia := REPLACE(vr_dspathcopia,'[dsdircop]',pr_dsdircop);
        END IF;
      END IF;

      dbms_output.put_line('Rel.354 em 1: '||vr_nom_direto||'/rl/crrl354.lst');
      -- Solicitar a geração do relatório crrl354
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt               --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml_354                         --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/agencia'                      --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl354.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl354.lst'     --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                                  --> 132 colunas
                                 ,pr_flg_gerar => vr_flgerar                           --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '234dh'                              --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_cdrelato  => 354                                  --> Qual a seq do cabrel
                                 ,pr_dspathcop => vr_dspathcopia                       --> Diretório a copiar o LST ao termino da geração
                                 ,pr_fldoscop  => 'S'                                  --> Flag para converter o arquivo gerado em DOS antes da cópia
                                 ,pr_des_erro  => pr_dscritic);                        --> Saída com erro

      dbms_lob.close(vr_clobxml_354);
      dbms_lob.freetemporary(vr_clobxml_354);

      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_erro;
      END IF;

      
      dbms_output.put_line('Rel.227 em 1: '||vr_nom_direto||'/rl/crrl227.lst');
      -- Solicitar a geração do relatório crrl227
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt               --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml_227                         --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/agencia'                      --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl227.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl227.lst'     --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                                  --> 132 colunas
                                 ,pr_flg_gerar => vr_flgerar                           --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '234dh'                              --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 3                                    --> Número de cópias
                                 ,pr_cdrelato  => 227                                  --> Qual a seq do cabrel
                                 ,pr_nrvergrl  => 1                                    --> Define tipo de relatorio (1 - Tibco)
                                 ,pr_des_erro  => pr_dscritic);                        --> Saída com erro

      dbms_lob.close(vr_clobxml_227);
      dbms_lob.freetemporary(vr_clobxml_227);

      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_erro;
      END IF;

      -- Quando execução em programa diferente do crps184
      IF pr_cdprogra <> 'CRPS184' THEN

        -- Copia do 354.TXT com lógica comum, onde ocorre envio conforme o diretório parametrizado em CRRL354_COPIA.
         vr_dspathcp_354 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL354_COPIA');

        -- Se tiver encontrado parâmetro
        IF vr_dspathcp_354 IS NOT NULL THEN
          -- Se existir o literal [dsdircop] iremos substituí-lo
            vr_dspathcp_354 := REPLACE(vr_dspathcp_354,'[dsdircop]',pr_dsdircop);
        END IF;

        -- Somente para 1 e 2 (Viacredi e Acredicoop)
         IF pr_cdcooper IN(1,2) THEN
          -- Copiar também o arquivo crrl354.txt para o diretório salvar
            vr_dspathcp_354 := vr_dspathcp_354 || ';' || vr_nom_direto||'/salvar/';
        END IF;

        -- Se foi encontrado algum path para export do arquivo
        IF vr_dspathcp_354 IS NOT NULL THEN
          -- Efetuar escrita final do 354.txt para gravar a varchar2 pendente no clob
            gene0002.pc_escreve_xml(pr_xml            => vr_clob_354
                                   ,pr_texto_completo => vr_txtarqui_354
                                   ,pr_texto_novo     => ''
                                   ,pr_fecha_xml      => TRUE); 
            dbms_output.put_line('Rel.354 em 2: '||vr_nmdireto_354||'/'||vr_nmarquiv_354);
            dbms_output.put_line('Rel.354 em 3: '||vr_dspathcp_354);
            -- Finalmente submete o arquivo pra geração
            gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                            --> Cooperativa conectada
                                               ,pr_cdprogra  => pr_cdprogra                            --> Programa chamador
                                               ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt                 --> Data do movimento atual
                                               ,pr_dsxml     => vr_clob_354                            --> Arquivo XML de dados
                                               ,pr_cdrelato  => '354'                                  --> Código do relatório
                                               ,pr_dsarqsaid => vr_nmdireto_354||'/'||vr_nmarquiv_354  --> Arquivo final com o path
                                               ,pr_flg_gerar => vr_flgerar                             --> Geraçao na hora
                                               ,pr_dspathcop => vr_dspathcp_354                        --> Copiar para o diretório
                                              ,pr_fldoscop  => 'S'                                    --> executar comando ux2dos
                                              ,pr_flgremarq => 'S'                                    --> Após cópia, remover arquivo de origem
                                              ,pr_des_erro  => pr_dscritic);                          --> Saída com erro
        END IF;

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clob_354);
        dbms_lob.freetemporary(vr_clob_354);

        -- Testar se houve erro
        IF pr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Limpar as tabelas geradas no processo
      vr_tab_erro.DELETE;
      vr_tab_risco.DELETE;
      vr_tab_risco_aux.DELETE;
      vr_tab_crapris.DELETE;
      vr_tab_totrispac.DELETE;
      vr_tab_totrisger.DELETE;
      vr_tab_contab.DELETE;
      vr_tab_microcredito.DELETE;
      vr_tab_miccred_fin.DELETE;
      vr_tab_miccred_nivris.DELETE;

      pc_log_programa(PR_DSTIPLOG     => 'O',
                      PR_CDPROGRAMA   => pr_cdprogra,
                      pr_cdcooper     => pr_cdcooper,
                      pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia => 4,
                      pr_dsmensagem   => 'fim1. AGENCIA: ' ||pr_cdagenci ||
                                         ' - INPROCES: ' ||pr_rw_crapdat.inproces ||
                                         ' - Horário: ' ||to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss'),
                      PR_IDPRGLOG     => vr_idlog_ini_ger);


      if pr_rw_crapdat.inproces > 2 then
        --Grava data fim para o JOB na tabela de LOG
        pc_log_programa(pr_dstiplog   => 'F',
                        pr_cdprograma => pr_cdprogra,
                        pr_cdcooper   => pr_cdcooper,
                        pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_ger,
                        pr_flgsucesso => 0);

      end if;

      --Salvar informacoes no banco de dados
      commit;

      --Se for job chamado pelo programa do batch
    else
      -- DA LINHA 3377
                  pc_log_programa(PR_DSTIPLOG     => 'O',
                                  PR_CDPROGRAMA   => pr_cdprogra,
                                  pr_cdcooper     => pr_cdcooper,
                                  pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                  pr_tpocorrencia => 4,
                                  pr_dsmensagem   => 'fim2. AGENCIA: ' ||pr_cdagenci ||
                                                     ' - INPROCES: ' ||pr_rw_crapdat.inproces ||
                                                     ' - Horário: ' ||to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss'),
                                  PR_IDPRGLOG     => vr_idlog_ini_ger);

      -- Atualiza finalização do batch na tabela de controle
      gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole --ID de Controle
                                         ,pr_cdcritic   => pr_cdcritic --Codigo da critica
                                         ,pr_dscritic   => vr_dscritic);

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale,
                                   pr_idprogra => LPAD(pr_cdagenci, 3, '0'),
                                   pr_des_erro => vr_dscritic);

      --Salvar informacoes no banco de dados
      commit;
    end if;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se não foi passado o codigo da critica
      IF pr_cdcritic IS NULL THEN
        -- Utilizaremos código zero, pois foi erro não cadastrado
        pr_cdcritic := 0;
      END IF;
      -- Retornar o erro tratado
         pr_dscritic := 'Erro na rotina PC_CRPS280_I_WAG. Detalhes: '||pr_dscritic;
      WHEN vr_exc_fimprg THEN

			-- Se foi retornado apenas código
			if vr_cdcritic > 0 and vr_dscritic is null then
				-- Buscar a descrição
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			end if;

			-- Se foi gerada critica para envio ao log
			if vr_cdcritic > 0 or vr_dscritic is not null then
				-- Envio centralizado de log de erro
				btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
																	 pr_ind_tipo_log => 2, -- Erro tratato
																	 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
																									 || vr_cdprogra || ' --> '
																									 || vr_dscritic );
			end if;

			-- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
			btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
															 ,pr_cdprogra => vr_cdprogra
															 ,pr_infimsol => pr_infimsol
															 ,pr_stprogra => pr_stprogra);

			--Grava data fim para o JOB na tabela de LOG - Ligeirinho
			pc_log_programa(pr_dstiplog   => 'F',
											pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
											pr_cdcooper   => pr_cdcooper,
											pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											pr_idprglog   => vr_idlog_ini_par,
											pr_flgsucesso => 1);
											
			if nvl(pr_idparale,0) <> 0 then
				-- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
				pc_log_programa(PR_DSTIPLOG           => 'E',
												PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
												pr_cdcooper           => pr_cdcooper,
												pr_tpexecucao         => vr_tpexecucao,    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
												pr_tpocorrencia       => 3,
												pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
																								 'pr_dscritic:'||pr_dscritic,
												PR_IDPRGLOG           => vr_idlog_ini_par);

				--Grava data fim para o JOB na tabela de LOG
				pc_log_programa(pr_dstiplog   => 'F',
												pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
												pr_cdcooper   => pr_cdcooper,
												pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
												pr_idprglog   => vr_idlog_ini_par,
												pr_flgsucesso => 0);

				-- Encerrar o job do processamento paralelo dessa agência
				gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
																		,pr_idprogra => LPAD(pr_cdagenci,3,'0')
																		,pr_des_erro => vr_dscritic);
			end if;

			-- Efetuar commit pois gravaremos o que foi processo até então
			commit;
										 
    WHEN vr_exc_saida THEN

			-- Se foi retornado apenas código
			if vr_cdcritic > 0 and vr_dscritic is null then
				-- Buscar a descrição
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			end if;

			-- Devolvemos código e critica encontradas
			pr_cdcritic := nvl(vr_cdcritic,0);
			pr_dscritic := vr_dscritic;
			
			if nvl(pr_idparale,0) <> 0 then
				-- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
				pc_log_programa(PR_DSTIPLOG           => 'E',
												PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
												pr_cdcooper           => pr_cdcooper,
												pr_tpexecucao         => vr_tpexecucao,    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
												pr_tpocorrencia       => 3,
							pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)|| 'pr_dscritic:'||pr_dscritic,
												PR_IDPRGLOG           => vr_idlog_ini_par);

				--Grava data fim para o JOB na tabela de LOG
				pc_log_programa(pr_dstiplog   => 'F',
												pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
												pr_cdcooper   => pr_cdcooper,
												pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
												pr_idprglog   => vr_idlog_ini_par,
												pr_flgsucesso => 0);

				-- Encerrar o job do processamento paralelo dessa agência
				gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
																		,pr_idprogra => LPAD(pr_cdagenci,3,'0')
																		,pr_des_erro => vr_dscritic);
			end if;
			
			-- Efetuar rollback
			rollback;										 
	 WHEN OTHERS THEN
      -- Retornar o erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic ||'.Erro não tratado na rotina PC_CRPS280_I_WAG. Detalhes: ' ||SQLERRM;

      if nvl(pr_idparale, 0) <> 0 then
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG     => 'E',
                        PR_CDPROGRAMA   => pr_cdprogra || '_' || pr_cdagenci,
                        pr_cdcooper     => pr_cdcooper,
                        pr_tpexecucao   => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia => 3,
                        pr_dsmensagem   => 'pr_cdcritic:' || pr_cdcritic || CHR(13) || 'pr_dscritic:' || pr_dscritic,
                        PR_IDPRGLOG     => vr_idlog_ini_par);

        --Grava data fim para o JOB na tabela de LOG
        pc_log_programa(pr_dstiplog   => 'F',
                        pr_cdprograma => pr_cdprogra || '_' || pr_cdagenci,
                        pr_cdcooper   => pr_cdcooper,
                        pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);

        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale,
                                     pr_idprogra => LPAD(pr_cdagenci, 3, '0'),
                                     pr_des_erro => vr_dscritic);
      end if;
  END;
END PC_CRPS280_I_WAG;
/
