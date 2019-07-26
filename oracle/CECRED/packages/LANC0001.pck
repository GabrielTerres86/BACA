CREATE OR REPLACE PACKAGE CECRED.LANC0001 IS

-- Tipo record para declaração de parâmetro de retorno da "pc_gerar_lancamento_conta"
TYPE typ_reg_retorno IS RECORD (
    rowidlct           ROWID,        -- rowid do registro do lançamento inserido
    nmtabela           VARCHAR2(60), -- tabela onde o lançamento foi inserido (CRAPLCM, TBCC_LANCAMENTOS_BLOQUEADOS, ...)
    progress_recid_lcm craplcm.progress_recid%TYPE,
    rowidlot ROWID,
    progress_recid_lot craplot.progress_recid%TYPE
);

TYPE typ_tab_hist_prej_nao_saldo IS TABLE OF NUMBER
     INDEX BY PLS_INTEGER;
vr_tab_histDeb_prej_nao_saldo typ_tab_hist_prej_nao_saldo;

--Buscar informacoes de lote
CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                 ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                 ,pr_cdagenci IN craplot.cdagenci%TYPE
                 ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                 ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
  SELECT craplot.cdcooper
        ,craplot.dtmvtolt
        ,craplot.nrdolote
        ,craplot.cdagenci
        ,craplot.nrseqdig
        ,craplot.cdbccxlt
        ,craplot.qtcompln
        ,craplot.qtinfoln
        ,craplot.vlcompcr
        ,craplot.vlinfocr
        ,craplot.vlcompdb
        ,craplot.vlinfodb
        ,craplot.tplotmov
        ,craplot.rowid
        ,craplot.progress_recid
    FROM craplot craplot
   WHERE craplot.cdcooper = pr_cdcooper
     AND craplot.dtmvtolt = pr_dtmvtolt
     AND craplot.cdagenci = pr_cdagenci
     AND craplot.cdbccxlt = pr_cdbccxlt
     AND craplot.nrdolote = pr_nrdolote;

-- Retorna TRUE ou FALSE indicando se um histórico pode ser debitado de uma conta
FUNCTION fn_pode_debitar(pr_cdcooper craplcm.cdcooper%TYPE
                       , pr_nrdconta craplcm.nrdconta%TYPE
                       , pr_cdhistor craplcm.cdhistor%TYPE) RETURN BOOLEAN;

--> Rotina para verificar se pode realizar o debito - Versão Progress
PROCEDURE pc_pode_debitar (pr_cdcooper  IN craplcm.cdcooper%TYPE
                         , pr_nrdconta  IN craplcm.nrdconta%TYPE
                         , pr_cdhistor  IN craplcm.cdhistor%TYPE
                         , pr_flpoddeb OUT INTEGER);

-- Faz as críticas aplicáveis e efetua o lançamento na CRAPLCM se for permitido
PROCEDURE pc_gerar_lancamento_conta(pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE DEFAULT NULL
                                  , pr_cdagenci IN  craplcm.cdagenci%TYPE default 0
                                  , pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE default 0
                                  , pr_nrdolote IN  craplcm.nrdolote%TYPE default 0
                                  , pr_nrdconta IN  craplcm.nrdconta%TYPE default 0
                                  , pr_nrdocmto IN  craplcm.nrdocmto%TYPE default 0
                                  , pr_cdhistor IN  craplcm.cdhistor%TYPE default 0
                                  , pr_nrseqdig IN  craplcm.nrseqdig%TYPE default 0
                                  , pr_vllanmto IN  craplcm.vllanmto%TYPE default 0
                                  , pr_nrdctabb IN  craplcm.nrdctabb%TYPE default 0
                                  , pr_cdpesqbb IN  craplcm.cdpesqbb%TYPE default ' '
                                  , pr_vldoipmf IN  craplcm.vldoipmf%TYPE default 0
                                  , pr_nrautdoc IN  craplcm.nrautdoc%TYPE default 0
                                  , pr_nrsequni IN  craplcm.nrsequni%TYPE default 0
                                  , pr_cdbanchq IN  craplcm.cdbanchq%TYPE default 0
                                  , pr_cdcmpchq IN  craplcm.cdcmpchq%TYPE default 0
                                  , pr_cdagechq IN  craplcm.cdagechq%TYPE default 0
                                  , pr_nrctachq IN  craplcm.nrctachq%TYPE default 0
                                  , pr_nrlotchq IN  craplcm.nrlotchq%TYPE default 0
                                  , pr_sqlotchq IN  craplcm.sqlotchq%TYPE default 0
                                  , pr_dtrefere IN  craplcm.dtrefere%TYPE DEFAULT NULL
                                  , pr_hrtransa IN  craplcm.hrtransa%TYPE default 0
                                  , pr_cdoperad IN  craplcm.cdoperad%TYPE default ' '
                                  , pr_dsidenti IN  craplcm.dsidenti%TYPE default ' '
                                  , pr_cdcooper IN  craplcm.cdcooper%TYPE default 0
                                  , pr_nrdctitg IN  craplcm.nrdctitg%TYPE default ' '
                                  , pr_dscedent IN  craplcm.dscedent%TYPE default ' '
                                  , pr_cdcoptfn IN  craplcm.cdcoptfn%TYPE default 0
                                  , pr_cdagetfn IN  craplcm.cdagetfn%TYPE default 0
                                  , pr_nrterfin IN  craplcm.nrterfin%TYPE default 0
                                  , pr_nrparepr IN  craplcm.nrparepr%TYPE default 0
                                  , pr_nrseqava IN  craplcm.nrseqava%TYPE default 0
                                  , pr_nraplica IN  craplcm.nraplica%TYPE default 0
                                  , pr_cdorigem IN  craplcm.cdorigem%TYPE default 0
                                  , pr_idlautom IN  craplcm.idlautom%TYPE default 0
                                  -------------------------------------------------
                                  -- Dados do lote (Opcional)
                                  -------------------------------------------------
                                  , pr_inprolot IN  INTEGER DEFAULT 0 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                  , pr_tplotmov IN  craplot.tplotmov%TYPE DEFAULT 0
                                  , pr_tab_retorno OUT typ_reg_retorno
                                  , pr_incrineg OUT INTEGER           -- Indicador de crítica de negócio
                                  , pr_cdcritic OUT PLS_INTEGER
                                  , pr_dscritic OUT VARCHAR2);

-- Versão adaptada da procedure para chamadas em programas Progress
PROCEDURE pc_gerar_lancto_conta_prog(pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                  , pr_cdagenci IN  craplcm.cdagenci%TYPE
                                  , pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                                  , pr_nrdolote IN  craplcm.nrdolote%TYPE
                                  , pr_nrdconta IN  craplcm.nrdconta%TYPE
                                  , pr_nrdocmto IN  VARCHAR2 --craplcm.nrdocmto%TYPE
                                  , pr_cdhistor IN  craplcm.cdhistor%TYPE
                                  , pr_nrseqdig IN  craplcm.nrseqdig%TYPE
                                  , pr_vllanmto IN  craplcm.vllanmto%TYPE
                                  , pr_nrdctabb IN  craplcm.nrdctabb%TYPE
                                  , pr_cdpesqbb IN  craplcm.cdpesqbb%TYPE
                                  , pr_vldoipmf IN  craplcm.vldoipmf%TYPE
                                  , pr_nrautdoc IN  craplcm.nrautdoc%TYPE
                                  , pr_nrsequni IN  craplcm.nrsequni%TYPE
                                  , pr_cdbanchq IN  craplcm.cdbanchq%TYPE
                                  , pr_cdcmpchq IN  craplcm.cdcmpchq%TYPE
                                  , pr_cdagechq IN  craplcm.cdagechq%TYPE
                                  , pr_nrctachq IN  craplcm.nrctachq%TYPE
                                  , pr_nrlotchq IN  craplcm.nrlotchq%TYPE
                                  , pr_sqlotchq IN  craplcm.sqlotchq%TYPE
                                  , pr_dtrefere IN  craplcm.dtrefere%TYPE
                                  , pr_hrtransa IN  craplcm.hrtransa%TYPE
                                  , pr_cdoperad IN  craplcm.cdoperad%TYPE
                                  , pr_dsidenti IN  craplcm.dsidenti%TYPE
                                  , pr_cdcooper IN  craplcm.cdcooper%TYPE
                                  , pr_nrdctitg IN  craplcm.nrdctitg%TYPE
                                  , pr_dscedent IN  craplcm.dscedent%TYPE
                                  , pr_cdcoptfn IN  craplcm.cdcoptfn%TYPE
                                  , pr_cdagetfn IN  craplcm.cdagetfn%TYPE
                                  , pr_nrterfin IN  craplcm.nrterfin%TYPE
                                  , pr_nrparepr IN  craplcm.nrparepr%TYPE
                                  , pr_nrseqava IN  craplcm.nrseqava%TYPE
                                  , pr_nraplica IN  craplcm.nraplica%TYPE
                                  , pr_cdorigem IN  craplcm.cdorigem%TYPE
                                  , pr_idlautom IN  craplcm.idlautom%TYPE
                                  -------------------------------------------------
                                  -- Dados do lote (Opcional)
                                  -------------------------------------------------
                                  , pr_inprolot  IN  INTEGER           -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                  , pr_tplotmov  IN  craplot.tplotmov%TYPE
                                  , pr_dsretorn_xml  OUT CLOB          -- Retorno em formato xml
                                  , pr_incrineg  OUT INTEGER           -- Indicador de crítica de negócio
                                  , pr_cdcritic  OUT PLS_INTEGER
                                  , pr_dscritic  OUT VARCHAR2);        -- Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)

-- Inclui/Altera CRAPLOT (migrada da EMPR0001)
PROCEDURE pc_inclui_altera_lote(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                               ,pr_cdagenci IN crapass.cdagenci%TYPE --Codigo Agencia
                               ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE --Codigo Caixa
                               ,pr_nrdolote IN craplot.nrdolote%TYPE --Numero Lote
                               ,pr_tplotmov IN craplot.tplotmov%TYPE --Tipo movimento
                               ,pr_cdoperad IN craplot.cdoperad%TYPE --Operador
                               ,pr_cdhistor IN craplot.cdhistor%TYPE --Codigo Historico
                               ,pr_dtmvtopg IN crapdat.dtmvtolt%TYPE --Data Pagamento Emprestimo
                               ,pr_vllanmto IN craplcm.vllanmto%TYPE --Valor Lancamento
                               ,pr_flgincre IN BOOLEAN --Indicador Credito
                               ,pr_flgcredi IN BOOLEAN --Credito
                               ,pr_nrseqdig OUT INTEGER --Numero Sequencia
                               ,pr_cdcritic OUT INTEGER --Codigo Erro
                               ,pr_dscritic OUT VARCHAR2);

-- Inclui um registro na CRAPLOT (Capa do lote)
PROCEDURE pc_incluir_lote(pr_dtmvtolt   IN  craplot.dtmvtolt%TYPE DEFAULT NULL
                        , pr_cdagenci   IN  craplot.cdagenci%TYPE default 0
                        , pr_cdbccxlt   IN  craplot.cdbccxlt%TYPE default 0
                        , pr_nrdolote   IN  craplot.nrdolote%TYPE default 0
                        , pr_nrseqdig   IN  craplot.nrseqdig%TYPE default 0
                        , pr_qtcompln   IN  craplot.qtcompln%TYPE default 0
                        , pr_qtinfoln   IN  craplot.qtinfoln%TYPE default 0
                        , pr_tplotmov   IN  craplot.tplotmov%TYPE default 0
                        , pr_vlcompcr   IN  craplot.vlcompcr%TYPE default 0
                        , pr_vlcompdb   IN  craplot.vlcompdb%TYPE default 0
                        , pr_vlinfodb   IN  craplot.vlinfodb%TYPE default 0
                        , pr_vlinfocr   IN  craplot.vlinfocr%TYPE default 0
                        , pr_dtmvtopg   IN  craplot.dtmvtopg%TYPE DEFAULT NULL
                        , pr_tpdmoeda   IN  craplot.tpdmoeda%TYPE default 1
                        , pr_cdoperad   IN  craplot.cdoperad%TYPE default ' '
                        , pr_cdhistor   IN  craplot.cdhistor%TYPE default 0
                        , pr_cdbccxpg   IN  craplot.cdbccxpg%TYPE default 0
                        , pr_nrdcaixa   IN  craplot.nrdcaixa%TYPE default 0
                        , pr_cdopecxa   IN  craplot.cdopecxa%TYPE default ' '
                        , pr_qtinfocc   IN  craplot.qtinfocc%TYPE default 0
                        , pr_qtcompcc   IN  craplot.qtcompcc%TYPE default 0
                        , pr_vlinfocc   IN  craplot.vlinfocc%TYPE default 0
                        , pr_vlcompcc   IN  craplot.vlcompcc%TYPE default 0
                        , pr_qtcompcs   IN  craplot.qtcompcs%TYPE default 0
                        , pr_qtinfocs   IN  craplot.qtinfocs%TYPE default 0
                        , pr_vlcompcs   IN  craplot.vlcompcs%TYPE default 0
                        , pr_vlinfocs   IN  craplot.vlinfocs%TYPE default 0
                        , pr_qtcompci   IN  craplot.qtcompci%TYPE default 0
                        , pr_qtinfoci   IN  craplot.qtinfoci%TYPE default 0
                        , pr_vlcompci   IN  craplot.vlcompci%TYPE default 0
                        , pr_vlinfoci   IN  craplot.vlinfoci%TYPE default 0
                        , pr_nrautdoc   IN  craplot.nrautdoc%TYPE default 0
                        , pr_flgltsis   IN  craplot.flgltsis%TYPE default 0
                        , pr_cdcooper   IN  craplot.cdcooper%TYPE default 0
                        , pr_rw_craplot OUT cr_craplot%ROWTYPE -- Retorna o registro inserido na CRAPLOT
                        , pr_cdcritic   OUT PLS_INTEGER
                        , pr_dscritic   OUT VARCHAR2);

FUNCTION fn_retorna_val_bloq_transf(pr_cdcooper craplcm.cdcooper%TYPE
                                  , pr_nrdconta craplcm.nrdconta%TYPE
                                  , pr_cdhistor craplcm.cdhistor%TYPE
                                  , pr_dtmvtolt craplcm.dtmvtolt%TYPE DEFAULT NULL)
  RETURN  tbblqj_ordem_transf.vlordem%TYPE;

-- Rotina centralizada para estorno de lançamentos na conta corrente, com tratamento para
-- contas transferidas para prejuízo
PROCEDURE pc_estorna_lancto_conta(pr_cdcooper IN  craplcm.cdcooper%TYPE
                                , pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                , pr_cdagenci IN  craplcm.cdagenci%TYPE
                                , pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                                , pr_nrdolote IN  craplcm.nrdolote%TYPE
                                , pr_nrdctabb IN  craplcm.nrdctabb%TYPE
                                , pr_nrdocmto IN  craplcm.nrdocmto%TYPE
                                , pr_cdhistor IN  craplcm.cdhistor%TYPE
                                , pr_nrctachq IN  craplcm.nrctachq%TYPE
                                , pr_nrdconta IN  craplcm.nrdconta%TYPE
                                , pr_cdpesqbb IN  craplcm.cdpesqbb%TYPE
                                , pr_rowid    IN  ROWID
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE);


PROCEDURE pc_estorna_lancto_prog (pr_cdcooper IN  craplcm.cdcooper%TYPE
                                , pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                , pr_cdagenci IN  craplcm.cdagenci%TYPE
                                , pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                                , pr_nrdolote IN  craplcm.nrdolote%TYPE
                                , pr_nrdctabb IN  craplcm.nrdctabb%TYPE
                                , pr_nrdocmto IN  VARCHAR2 --craplcm.nrdocmto%TYPE
                                , pr_cdhistor IN  craplcm.cdhistor%TYPE
                                , pr_nrctachq IN  craplcm.nrctachq%TYPE
                                , pr_nrdconta IN  craplcm.nrdconta%TYPE
                                , pr_cdpesqbb IN  craplcm.cdpesqbb%TYPE
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE);

FUNCTION fn_verifica_cred_bloq_futuro (pr_cdcooper IN  craplcm.cdcooper%TYPE
                                     , pr_nrdconta IN  craplcm.nrdconta%TYPE
                                     , pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                     , pr_cdhistor IN  craplcm.cdhistor%TYPE
                                     , pr_nrdocmto IN  craplcm.nrdocmto%type
                                     ) return NUMBER;

PROCEDURE pc_estorna_saque_conta_prej(pr_cdcooper IN  craplcm.cdcooper%TYPE
                                    , pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                    , pr_cdagenci IN  craplcm.cdagenci%TYPE
                                    , pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                                    , pr_nrdctabb IN  craplcm.nrdctabb%TYPE
                                    , pr_nrdocmto IN  craplcm.nrdocmto%TYPE
                                    , pr_cdhistor IN  craplcm.cdhistor%TYPE
                                    , pr_nrdconta IN  craplcm.nrdconta%TYPE
                                    , pr_nrseqdig IN  craplcm.nrseqdig%TYPE
                                    , pr_vllanmto IN  craplcm.vllanmto%TYPE
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE);

END LANC0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.LANC0001 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : LANC0001
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Reginaldo (AMcom)
  --  Data     : Abril/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para centralização de lançamentos na CRAPLCM e aplicação das respectivas
  --             regras de negócio.
  --
  -- Alterado  : 10/05/2018 - Migração do cursor "cr_craplot" e da procedure "pc_inclui_altera_lote"
  --                          a partir da package "EMPR0001".
  --                          (Reginaldo - AMcom - PRJ 450)
  --
  -- Alterado  : 23/10/2018 - Correção histórico 2738 ao excluir lançamentos conta transitória
  --                          (Renato - AMcom - PRJ 450)
  --
  --             16/11/2018 - prj450 - história 10669:Crédito de Estorno de Saque em conta em Prejuízo
  --                          (Fabio Adriano - AMcom).
  --
  -- Alterado  : 04/12/2018 - Atendimento estória 12541 - Tratamento saldo deposito em cheque em conta em prejuizo
  --                          (Renato - AMcom - PRJ 450)
  --
  --             25/04/2019 - Remoção da procedure "pc_debito_prejuizo" e retirada do tratamento para incremento
  --                          do saldo do prejuízo em tempo real, quando é lançado um débito (o incremento do saldo
  --                          do prejuízo passará a ser realizado no processo noturno, através de procedure específica
  --                          criada na PREJ0006, que será chamada pela PC_CRPS752.
  --                          (P450 - Reginaldo/AMcom)
  --
  --             03/06/2019 - Incluida validacao para nao atualizar/inserir CRAPLOT dos lotes removidos na primeira fase
  --                          do projeto de remocao de lotes (Pagamentos, Transferencias, Poupanca Programada)
  --                          Heitor (Mouts) - Projeto Revitalizacao (Remocao de Lotes)
  --
  --             07/06/2019 - Incluído parâmetro pr_incrineg = 1 para crítica 717 retornada em casos de débitos em 
  --                          contas monitoradas. (Reinert)
  ---------------------------------------------------------------------------------------------------------------

-- Record para armazenar dados dos históricos para evitar consultas repetitivas
TYPE typ_reg_historico IS RECORD (
     indebcre        craphis.indebcre%TYPE
   , indebprj        craphis.indebprj%TYPE
   , intransf_cred_prejuizo craphis.intransf_cred_prejuizo%TYPE
);

-- Tabela com dados dos históricos já consultados na rotina
TYPE typ_tab_historico IS TABLE OF typ_reg_historico INDEX BY VARCHAR2(8);

-- Varíavel para armazenamento da tabela de dados dos históricos
vr_tab_historico typ_tab_historico;

-- Tabela para armazenar a informação de dias de atraso das contas para evitar consultas repetitivas
TYPE typ_tab_atraso IS TABLE OF crapsld.qtddsdev%TYPE INDEX BY VARCHAR2(18);

-- Variável para armazenamento da tabela de dias de atraso das contas
vr_tab_atraso typ_tab_atraso;

-- Record com dados do lote, obtidos a partir do cursor "LANC0001.cr_craplot"
rw_craplot cr_craplot%ROWTYPE;

-- Função que Obtém dados do histórico (CRAPHIS)
FUNCTION fn_obtem_dados_historico(pr_cdcooper craplcm.cdcooper%TYPE
                              , pr_cdhistor craplcm.cdhistor%TYPE)
  RETURN typ_reg_historico AS vr_reg_historico typ_reg_historico;

  -- Recupera os do histórico
  CURSOR cr_historico IS
  SELECT his.indebprj
       , his.indebcre
       , his.intransf_cred_prejuizo
    FROM craphis his
   WHERE his.cdcooper = pr_cdcooper
     AND his.cdhistor = pr_cdhistor;
  rw_historico cr_historico%ROWTYPE;

  vr_chvhist VARCHAR2(8);  -- Chave para indexação da tabela de históricos
BEGIN
     vr_chvhist := lpad(pr_cdcooper, 3, '0') || lpad(pr_cdhistor, 5, '0');

     IF vr_tab_historico.exists(vr_chvhist) THEN
       vr_reg_historico := vr_tab_historico(vr_chvhist);
     ELSE
       OPEN cr_historico;
       FETCH cr_historico INTO rw_historico;
       CLOSE cr_historico;

       vr_tab_historico(vr_chvhist).indebcre := rw_historico.indebcre;
       vr_tab_historico(vr_chvhist).indebprj := rw_historico.indebprj;
       vr_tab_historico(vr_chvhist).intransf_cred_prejuizo := rw_historico.intransf_cred_prejuizo;
       vr_reg_historico.indebcre := rw_historico.indebcre;
       vr_reg_historico.indebprj := rw_historico.indebprj;
       vr_reg_historico.intransf_cred_prejuizo := rw_historico.intransf_cred_prejuizo;
     END IF;

     RETURN vr_reg_historico;
END fn_obtem_dados_historico;

-- Função que obtém dias em atraso da conta (estouro)
FUNCTION fn_obtem_dias_atraso(pr_cdcooper crapsld.cdcooper%TYPE
                          , pr_nrdconta crapsld.nrdconta%TYPE)
  RETURN crapsld.qtddsdev%TYPE AS vr_dias_atraso crapsld.qtddsdev%TYPE;

  -- Cursos que recupera a quantidade de dias em que a conta está em atraso (ADP)
  CURSOR cr_saldo IS
  SELECT sld.qtddsdev
    FROM crapsld sld
   WHERE sld.cdcooper = pr_cdcooper
     AND sld.nrdconta = pr_nrdconta;

  vr_chvconta VARCHAR2(18);  -- Chave para indexação da tabela de dias de atraso

BEGIN
  vr_chvconta := lpad(pr_cdcooper, 3, '0') || lpad(pr_nrdconta, 15, '0');

  IF vr_tab_atraso.exists(vr_chvconta) THEN
    vr_dias_atraso := vr_tab_atraso(vr_chvconta);
  ELSE
    OPEN cr_saldo;
    FETCH cr_saldo INTO vr_dias_atraso;
    CLOSE cr_saldo;

    vr_tab_atraso(vr_chvconta) := vr_dias_atraso;
  END IF;

  RETURN vr_dias_atraso;
END fn_obtem_dias_atraso ;

-- Função que obtém saldo bloqueado em BACENJUD para a conta
FUNCTION fn_obtem_saldo_blq_bacenjud(pr_cdcooper crapsld.cdcooper%TYPE
                            , pr_nrdconta crapsld.nrdconta%TYPE)
  RETURN tbblqj_monitora_ordem_bloq.vlsaldo%TYPE AS vr_vlsaldo tbblqj_monitora_ordem_bloq.vlsaldo%TYPE;

  -- Cursos que recupera o saldo bloqueado em BACENJUD
  CURSOR cr_saldo IS
  SELECT bcj.vlsaldo
    FROM tbblqj_monitora_ordem_bloq bcj
   WHERE bcj.cdcooper = pr_cdcooper
     AND bcj.nrdconta = pr_nrdconta;

BEGIN
  OPEN cr_saldo;
  FETCH cr_saldo INTO vr_vlsaldo;
  CLOSE cr_saldo;

  RETURN vr_vlsaldo;
END fn_obtem_saldo_blq_bacenjud ;

-- Função qye verifica se pode debitar um histórico em uma conta de acordo com as marcações feitas
-- na tela HISTOR
FUNCTION fn_pode_debitar(pr_cdcooper craplcm.cdcooper%TYPE
                       , pr_nrdconta craplcm.nrdconta%TYPE
                       , pr_cdhistor craplcm.cdhistor%TYPE)
  RETURN BOOLEAN AS vr_pode_debitar BOOLEAN;

  ----- >>> VARIÁVEIS <<<-----
  vr_reg_historico typ_reg_historico;

BEGIN
  vr_pode_debitar := TRUE;

  -- Se as regras de negócio do prejuízo já estão ativadas
  IF PREJ0003.fn_verifica_flg_ativa_prju(pr_cdcooper) THEN
    vr_reg_historico := fn_obtem_dados_historico(pr_cdcooper, pr_cdhistor);

    -- Confere se o histórico em questão é de Débito
    IF vr_reg_historico.indebcre = 'D' THEN
      -- Se a conta está em prejuízo e o histórico não permite aumentar o estouro da conta
      IF PREJ0003.fn_verifica_preju_conta(pr_cdcooper, pr_nrdconta)
      AND vr_reg_historico.indebprj = 0 THEN
        vr_pode_debitar := FALSE;
      END IF;
    END IF;
  END IF;

  RETURN vr_pode_debitar;
END fn_pode_debitar;

--> Rotina para verificar se pode realizar o debito - Versão para uso em programas Progress
PROCEDURE pc_pode_debitar (pr_cdcooper  IN craplcm.cdcooper%TYPE
                         , pr_nrdconta  IN craplcm.nrdconta%TYPE
                         , pr_cdhistor  IN craplcm.cdhistor%TYPE
                         , pr_flpoddeb OUT INTEGER )               --> Indica se pode debitat  0-Nao 1-Sim
                         IS
  /* ............................................................................
        Programa: pc_pode_debitar
        Sistema : Ayllos
        Sigla   : CRED
        Autor   : Odirlei Busana/AMcom
        Data    : Junho/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para verificar se pode realizar o debito - Versão Progress
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

BEGIN

  -- Verifica se pode debitar um histórico em uma conta
  IF fn_pode_debitar(pr_cdcooper => pr_cdcooper
                   , pr_nrdconta => pr_nrdconta
                   , pr_cdhistor => pr_cdhistor) THEN
    pr_flpoddeb := 1; -- Sim, pode debitar
  ELSE
    pr_flpoddeb := 0; -- Não pode debitar
  END IF;

END pc_pode_debitar;

-- Inclui um novo lançamento na CRAPLCM e aplica as devidas regras de negócio
PROCEDURE pc_gerar_lancamento_conta(pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE DEFAULT NULL
                                  , pr_cdagenci IN  craplcm.cdagenci%TYPE default 0
                                  , pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE default 0
                                  , pr_nrdolote IN  craplcm.nrdolote%TYPE default 0
                                  , pr_nrdconta IN  craplcm.nrdconta%TYPE default 0
                                  , pr_nrdocmto IN  craplcm.nrdocmto%TYPE default 0
                                  , pr_cdhistor IN  craplcm.cdhistor%TYPE default 0
                                  , pr_nrseqdig IN  craplcm.nrseqdig%TYPE default 0
                                  , pr_vllanmto IN  craplcm.vllanmto%TYPE default 0
                                  , pr_nrdctabb IN  craplcm.nrdctabb%TYPE default 0
                                  , pr_cdpesqbb IN  craplcm.cdpesqbb%TYPE default ' '
                                  , pr_vldoipmf IN  craplcm.vldoipmf%TYPE default 0
                                  , pr_nrautdoc IN  craplcm.nrautdoc%TYPE default 0
                                  , pr_nrsequni IN  craplcm.nrsequni%TYPE default 0
                                  , pr_cdbanchq IN  craplcm.cdbanchq%TYPE default 0
                                  , pr_cdcmpchq IN  craplcm.cdcmpchq%TYPE default 0
                                  , pr_cdagechq IN  craplcm.cdagechq%TYPE default 0
                                  , pr_nrctachq IN  craplcm.nrctachq%TYPE default 0
                                  , pr_nrlotchq IN  craplcm.nrlotchq%TYPE default 0
                                  , pr_sqlotchq IN  craplcm.sqlotchq%TYPE default 0
                                  , pr_dtrefere IN  craplcm.dtrefere%TYPE DEFAULT NULL
                                  , pr_hrtransa IN  craplcm.hrtransa%TYPE default 0
                                  , pr_cdoperad IN  craplcm.cdoperad%TYPE default ' '
                                  , pr_dsidenti IN  craplcm.dsidenti%TYPE default ' '
                                  , pr_cdcooper IN  craplcm.cdcooper%TYPE default 0
                                  , pr_nrdctitg IN  craplcm.nrdctitg%TYPE default ' '
                                  , pr_dscedent IN  craplcm.dscedent%TYPE default ' '
                                  , pr_cdcoptfn IN  craplcm.cdcoptfn%TYPE default 0
                                  , pr_cdagetfn IN  craplcm.cdagetfn%TYPE default 0
                                  , pr_nrterfin IN  craplcm.nrterfin%TYPE default 0
                                  , pr_nrparepr IN  craplcm.nrparepr%TYPE default 0
                                  , pr_nrseqava IN  craplcm.nrseqava%TYPE default 0
                                  , pr_nraplica IN  craplcm.nraplica%TYPE default 0
                                  , pr_cdorigem IN  craplcm.cdorigem%TYPE default 0
                                  , pr_idlautom IN  craplcm.idlautom%TYPE default 0
                                  -------------------------------------------------
                                  -- Dados do lote (Opcional)
                                  -------------------------------------------------
                                  , pr_inprolot  IN  INTEGER DEFAULT 0   -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                  , pr_tplotmov  IN  craplot.tplotmov%TYPE DEFAULT 0 -- Campo para inclusão na CRAPLOT
                                  , pr_tab_retorno OUT typ_reg_retorno   -- Record com os dados retornados pela procedure
                                  , pr_incrineg  OUT INTEGER             -- Retorna o indicador de crítica de negócio (0 - Não, 1 - Sim)
                                  , pr_cdcritic  OUT PLS_INTEGER
                                  , pr_dscritic  OUT VARCHAR2) IS
BEGIN
   /* ............................................................................
        Programa: pc_gerar_lancamento_conta
        Sistema : Ayllos
        Sigla   : CRED
        Autor   : Reginaldo/AMcom
        Data    : Abril/2018                 Ultima atualizacao: 21/12/2018

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina centralizada para incluir lançamentos na CRAPLCM,
                    aplicando as respectivas regras de negócio.

        Observacao: -----
        Alteracoes: 21/12/2018 - Ajustado rotina para caso de lançamento de debito,
                                 chamar a rotina para aumentar prejuizo.
                                 PRJ450 - Regulatorio (Odirlei-AMcom)

                    13/02/2019 - Inclusao de regras para contas com bloqueio judicial
                               - Projeto 530 BACENJUD - Everton(AMcom).

                    10/04/2019 - PJ530-Bacenjud fase 2 - Não permite Debitos para conta monitorada e histórico com bacenjud ativo
                                 (Renato Cordeiro - AMcom)
    ..............................................................................*/

DECLARE
    ----->>> VARIÁVEIS <<<-----
    vr_reg_historico  typ_reg_historico;       -- Registro para armazenar os dados do histórico do lançamento
    vr_nrseqdig       craplot.nrseqdig%TYPE;   -- Aramazena o valor do campo "nrseqdig" da CRAPLOT para referência na CRAPLCM
    vr_flgcredi       BOOLEAN;                 -- Flag indicadora para Crédito/Débito
    vr_inprejuz       BOOLEAN;                 -- Indicador de conta em prejuízo
--    vr_vlsldblq       tbblqj_monitora_ordem_bloq.vlsaldo%TYPE; -- Saldo bloqueado por BACENJUD (somente para Créditos)
    vr_vltransf       NUMBER;                  -- Valor a transferir para Conta Transitória (somente para Créditos)

    vr_dsidenti       craplcm.dsidenti%type;

    vr_id_conta_monitorada NUMBER(1);

    CURSOR cr_craphis (pr_cdcooper IN NUMBER,
                       pr_cdhistor IN NUMBER) IS
       SELECT h.indutblq
             ,h.inhistor
       FROM craphis h
       WHERE h.cdcooper = pr_cdcooper
         AND h.cdhistor = pr_cdhistor;
    rw_craphis  cr_craphis%ROWTYPE;

    vr_exc_erro       EXCEPTION;
BEGIN
    -- Inicialização de variáveis/parâmetros
    pr_cdcritic := 0;
    pr_dscritic := '';
    pr_incrineg := 0;
    pr_tab_retorno.nmtabela := 'CRAPLCM'; -- Fluxo padrão insere na CRAPLCM
    vr_nrseqdig := pr_nrseqdig;

    -- Carrega dados do histórico do lançamento
    vr_reg_historico := fn_obtem_dados_historico(pr_cdcooper, pr_cdhistor);

    -- Se o lançamento é um débito, o histórico não permite estourar e a conta está em prejuízo
    -- (e se as regras de negócio do prejuízo já estão ativas)
    IF vr_reg_historico.indebcre = 'D' AND PREJ0003.fn_verifica_flg_ativa_prju(pr_cdcooper) THEN
      -- Se a conta está estourada e não permite debitar
      IF NOT fn_pode_debitar(pr_cdcooper, pr_nrdconta, pr_cdhistor) THEN
         pr_cdcritic := 1390; -- 1390 - Nao foi possivel realizar debito - Conta em prejuizo.
         pr_incrineg := 1;    -- Indica que trata-se de crítica de negócio e não erro de BD
         RAISE vr_exc_erro;
      END IF;
    END IF;

    if vr_reg_historico.indebcre = 'D' then -- se é débito

        blqj0002.pc_verifica_conta_bloqueio(pr_cdcooper => pr_cdcooper, -- rotina testa se conta monitorada ou não
                                            pr_nrdconta => pr_nrdconta,
                                            pr_id_conta_monitorada => vr_id_conta_monitorada,
                                            pr_cdcritic => pr_cdcritic,
                                            pr_dscritic => pr_dscritic);
        IF nvl(pr_cdcritic, 0) > 0 OR pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        IF vr_id_conta_monitorada = 1 THEN -- Se conta monitorada
          OPEN cr_craphis(pr_cdcooper, pr_cdhistor);
          FETCH cr_craphis INTO rw_craphis;
          IF rw_craphis.indutblq = 'N' AND rw_craphis.inhistor = 11 then -- se o histórico DEBITO não permite débitos
            pr_cdcritic := 717; -- critico falta de saldo
					  pr_incrineg := 1;    -- Indica que trata-se de crítica de negócio e não erro de BD
            RAISE vr_exc_erro;
          END IF;
          CLOSE cr_craphis;
        end if;
    end if;

    -- Se deve processar internamente o lote (CRAPLOT)
    IF pr_inprolot = 1 THEN
      if pr_nrdolote not in (7050,8383,8473,10104,10105,10115,11900,15900,23900) then
        IF vr_reg_historico.indebcre = 'C' THEN
          vr_flgcredi := TRUE;
        ELSE
          vr_flgcredi := FALSE;
        END IF;

        pc_inclui_altera_lote(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                             ,pr_dtmvtolt => pr_dtmvtolt   --Data Emprestimo
                             ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                             ,pr_cdbccxlt => pr_cdbccxlt   --Codigo Caixa
                             ,pr_nrdolote => pr_nrdolote   --Numero Lote
                             ,pr_tplotmov => pr_tplotmov   --Tipo movimento
                             ,pr_cdoperad => pr_cdoperad   --Operador
                             ,pr_cdhistor => pr_cdhistor   --Codigo Historico
                             ,pr_dtmvtopg => pr_dtmvtolt   --Data Pagamento Emprestimo
                             ,pr_vllanmto => pr_vllanmto   --Valor Lancamento
                             ,pr_flgincre => TRUE          --Incremento
                             ,pr_flgcredi => vr_flgcredi   --Credito
                             ,pr_nrseqdig => vr_nrseqdig   --Numero Sequencia
                             ,pr_cdcritic => pr_cdcritic   --Codigo Erro
                             ,pr_dscritic => pr_dscritic); --Descricao Erro

        --Se ocorreu erro
        IF nvl(pr_cdcritic, 0) > 0 OR pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => pr_dtmvtolt
                   ,pr_cdagenci => pr_cdagenci
                   ,pr_cdbccxlt => pr_cdbccxlt
                   ,pr_nrdolote => pr_nrdolote);
        FETCH cr_craplot INTO rw_craplot;
        CLOSE cr_craplot;

        pr_tab_retorno.rowidlot := rw_craplot.rowid;
        pr_tab_retorno.progress_recid_lot := rw_craplot.progress_recid;
      ELSE
        vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                    to_char(pr_dtmvtolt, 'DD/MM/RRRR')||';'||
                                    to_char(pr_cdagenci)||';'||
                                    to_char(pr_cdbccxlt)||';'||
                                    to_char(pr_nrdolote));
      end if;
    END IF;

    --Trata caractere inválido PRB0040625
    vr_dsidenti := replace(pr_dsidenti,'´','');

    INSERT INTO craplcm (
        dtmvtolt
      , cdagenci
      , cdbccxlt
      , nrdolote
      , nrdconta
      , nrdocmto
      , cdhistor
      , nrseqdig
      , vllanmto
      , nrdctabb
      , cdpesqbb
      , vldoipmf
      , nrautdoc
      , nrsequni
      , cdbanchq
      , cdcmpchq
      , cdagechq
      , nrctachq
      , nrlotchq
      , sqlotchq
      , dtrefere
      , hrtransa
      , cdoperad
      , dsidenti
      , cdcooper
      , nrdctitg
      , dscedent
      , cdcoptfn
      , cdagetfn
      , nrterfin
      , nrparepr
      , nrseqava
      , nraplica
      , cdorigem
      , idlautom
    )
    VALUES (
        pr_dtmvtolt
      , pr_cdagenci
      , pr_cdbccxlt
      , pr_nrdolote
      , pr_nrdconta
      , pr_nrdocmto
      , pr_cdhistor
      , vr_nrseqdig
      , pr_vllanmto
      , pr_nrdctabb
      , pr_cdpesqbb
      , pr_vldoipmf
      , pr_nrautdoc
      , pr_nrsequni
      , pr_cdbanchq
      , pr_cdcmpchq
      , pr_cdagechq
      , pr_nrctachq
      , pr_nrlotchq
      , pr_sqlotchq
      , pr_dtrefere
      , pr_hrtransa
      , pr_cdoperad
      , vr_dsidenti
      , pr_cdcooper
      , pr_nrdctitg
      , pr_dscedent
      , pr_cdcoptfn
      , pr_cdagetfn
      , pr_nrterfin
      , pr_nrparepr
      , pr_nrseqava
      , pr_nraplica
      , pr_cdorigem
      , pr_idlautom
    )
    RETURNING
      ROWID, progress_recid
    INTO
      pr_tab_retorno.rowidlct, pr_tab_retorno.progress_recid_lcm;

    -- Se é um lançamento de crédito e se as regras de negócio do prejuízo já estão ativas
    IF vr_reg_historico.indebcre = 'C' THEN
      -- Identifica se a conta está em prejuízo
      vr_inprejuz := PREJ0003.fn_verifica_preju_conta(pr_cdcooper,
                                                      pr_nrdconta);

      IF  vr_inprejuz
      AND vr_reg_historico.intransf_cred_prejuizo = 1
      AND PREJ0003.fn_verifica_flg_ativa_prju(pr_cdcooper) THEN
        pr_tab_retorno.nmtabela := 'TBCC_PREJUIZO_LANCAMENTO';

        vr_vltransf := pr_vllanmto;

        -- Processar bloqueio BACENJUD
--        vr_vlsldblq := fn_obtem_saldo_blq_bacenjud(pr_cdcooper
--                                                 , pr_nrdconta);

--        IF vr_vlsldblq > 0 THEN
--          IF vr_vltransf > vr_vlsldblq THEN
--            vr_vltransf := vr_vltransf - vr_vlsldblq;
--          ELSE
--            vr_vltransf := 0;
--          END IF;
--        END IF;

        --> Verificar se for os historicos de desbloqueio
--        IF pr_cdhistor IN (1404,1405) THEN

          -- Verificar se possui TED de bloqueio judicial pendente e retornar saldo
          -- para bloquio prejuixo caso possua
--          vr_vltransf :=  fn_retorna_val_bloq_transf( pr_cdcooper => pr_cdcooper
--                                                    , pr_nrdconta => pr_nrdconta
--                                                    , pr_cdhistor => pr_cdhistor
--                                                    , pr_dtmvtolt => pr_dtmvtolt);
--        END IF;

        -- Se há valor a transferir após verificação de bloqueio por BACENJUD
        IF vr_vltransf > 0 THEN
          -- Calcula o "nrseqdig"

          IF fn_verifica_cred_bloq_futuro(pr_cdcooper,
                                          pr_nrdconta,
                                          pr_dtmvtolt,
                                          pr_cdhistor,
                                          pr_nrdocmto) = 0 THEN

          vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                    to_char(pr_dtmvtolt, 'DD/MM/RRRR')||';'||
                                    '1;100;650009');

          -- Efetua débito do valor que será transferido para a Conta Transitória (créditos bloqueados por prejuízo em conta)
          INSERT INTO craplcm
			 (dtmvtolt
            , cdagenci
            , cdbccxlt
            , nrdolote
            , nrdconta
            , nrdocmto
            , cdhistor
            , nrseqdig
            , vllanmto
            , nrdctabb
            , cdpesqbb
            , dtrefere
            , hrtransa
            , cdoperad
            , cdcooper
            ,cdorigem)
        VALUES
             (pr_dtmvtolt
            , pr_cdagenci
            , pr_cdbccxlt
            , 650009
            , pr_nrdconta
            , pr_nrdocmto
            , 2719
            , vr_nrseqdig
            , vr_vltransf
            , pr_nrdctabb
            , 'ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO'
            , pr_dtmvtolt
            , gene0002.fn_busca_time
            , 1
            , pr_cdcooper
            ,5);

          -- Insere lançamento do crédito transferido para a Conta Transitória
          INSERT INTO TBCC_PREJUIZO_LANCAMENTO 
                (dtmvtolt
               , cdagenci
               , nrdconta
               , nrdocmto
               , cdhistor
               , vllanmto
               , dthrtran
               , cdoperad
               , cdcooper
               , cdorigem
            )
          VALUES
               ( pr_dtmvtolt
               , pr_cdagenci
               , pr_nrdconta
               , pr_nrdocmto
               , 2738
               , vr_vltransf
               , SYSDATE
               , 1
               , pr_cdcooper
               , 5
               );
        END IF;
      END IF;
     END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := NVL(pr_cdcritic, 0);

      IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      END IF;
    WHEN DUP_VAL_ON_INDEX THEN
      pr_cdcritic := 92; -- Lançamento já existe
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic) ||
                     ' pc_gerar_lancamento_conta - ' || SQLERRM || ')';
    WHEN OTHERS THEN
      pr_cdcritic := 9999;
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic) || ' pc_gerar_lancamento_conta - ' || SQLERRM || ')';
  END;
END pc_gerar_lancamento_conta;

-- Versão adaptada da procedure para chamadas em programas Progress
PROCEDURE pc_gerar_lancto_conta_prog(pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                  , pr_cdagenci IN  craplcm.cdagenci%TYPE
                                  , pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                                  , pr_nrdolote IN  craplcm.nrdolote%TYPE
                                  , pr_nrdconta IN  craplcm.nrdconta%TYPE
                                  , pr_nrdocmto IN  VARCHAR2 -- craplcm.nrdocmto%TYPE
                                  , pr_cdhistor IN  craplcm.cdhistor%TYPE
                                  , pr_nrseqdig IN  craplcm.nrseqdig%TYPE
                                  , pr_vllanmto IN  craplcm.vllanmto%TYPE
                                  , pr_nrdctabb IN  craplcm.nrdctabb%TYPE
                                  , pr_cdpesqbb IN  craplcm.cdpesqbb%TYPE
                                  , pr_vldoipmf IN  craplcm.vldoipmf%TYPE
                                  , pr_nrautdoc IN  craplcm.nrautdoc%TYPE
                                  , pr_nrsequni IN  craplcm.nrsequni%TYPE
                                  , pr_cdbanchq IN  craplcm.cdbanchq%TYPE
                                  , pr_cdcmpchq IN  craplcm.cdcmpchq%TYPE
                                  , pr_cdagechq IN  craplcm.cdagechq%TYPE
                                  , pr_nrctachq IN  craplcm.nrctachq%TYPE
                                  , pr_nrlotchq IN  craplcm.nrlotchq%TYPE
                                  , pr_sqlotchq IN  craplcm.sqlotchq%TYPE
                                  , pr_dtrefere IN  craplcm.dtrefere%TYPE
                                  , pr_hrtransa IN  craplcm.hrtransa%TYPE
                                  , pr_cdoperad IN  craplcm.cdoperad%TYPE
                                  , pr_dsidenti IN  craplcm.dsidenti%TYPE
                                  , pr_cdcooper IN  craplcm.cdcooper%TYPE
                                  , pr_nrdctitg IN  craplcm.nrdctitg%TYPE
                                  , pr_dscedent IN  craplcm.dscedent%TYPE
                                  , pr_cdcoptfn IN  craplcm.cdcoptfn%TYPE
                                  , pr_cdagetfn IN  craplcm.cdagetfn%TYPE
                                  , pr_nrterfin IN  craplcm.nrterfin%TYPE
                                  , pr_nrparepr IN  craplcm.nrparepr%TYPE
                                  , pr_nrseqava IN  craplcm.nrseqava%TYPE
                                  , pr_nraplica IN  craplcm.nraplica%TYPE
                                  , pr_cdorigem IN  craplcm.cdorigem%TYPE
                                  , pr_idlautom IN  craplcm.idlautom%TYPE
                                  -------------------------------------------------
                                  -- Dados do lote (Opcional)
                                  -------------------------------------------------
                                  , pr_inprolot  IN  INTEGER           -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                  , pr_tplotmov  IN  craplot.tplotmov%TYPE
                                  , pr_dsretorn_xml  OUT CLOB          -- Retorno em formato xml
                                  , pr_incrineg  OUT INTEGER           -- Indicador de crítica de negócio
                                  , pr_cdcritic  OUT PLS_INTEGER
                                  , pr_dscritic  OUT VARCHAR2) IS      -- Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)

   /* ............................................................................
        Programa: pc_gerar_lancto_conta_prog
        Sistema : Ayllos
        Sigla   : CRED
        Autor   : Reginaldo/AMcom
        Data    : Abril/2018                 Ultima atualizacao: 07/12/2018

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Versão adaptada da procedure para chamada em programas Progress
        Observacao: -----

        Alteracoes: 07/12/2018 - Ajustado pr_nrdocmto para varchar2 visto que o mesmo pode ter até 25 posicoes
                                 que na comunicação com o Progress é truncado. PRJ450 - Regulatorio (Odirlei-AMcom)
    ..............................................................................*/
  --------------> VARIAVEIS <-----------------
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(1000);
  vr_exc_erro EXCEPTION;

  vr_rec_retorno  typ_reg_retorno; -- Registro com os dados retornados pela procedure "pc_gerar_lancamento_conta"
  vr_dstexto      VARCHAR2(32767);
  vr_string       VARCHAR2(32767);

BEGIN
    pc_gerar_lancamento_conta(pr_dtmvtolt => pr_dtmvtolt
                              , pr_cdagenci => pr_cdagenci
                              , pr_cdbccxlt => pr_cdbccxlt
                              , pr_nrdolote => pr_nrdolote
                              , pr_nrdconta => pr_nrdconta
                              , pr_nrdocmto => pr_nrdocmto
                              , pr_cdhistor => pr_cdhistor
                              , pr_nrseqdig => pr_nrseqdig
                              , pr_vllanmto => pr_vllanmto
                              , pr_nrdctabb => pr_nrdctabb
                              , pr_cdpesqbb => pr_cdpesqbb
                              , pr_vldoipmf => pr_vldoipmf
                              , pr_nrautdoc => pr_nrautdoc
                              , pr_nrsequni => pr_nrsequni
                              , pr_cdbanchq => pr_cdbanchq
                              , pr_cdcmpchq => pr_cdcmpchq
                              , pr_cdagechq => pr_cdagechq
                              , pr_nrctachq => pr_nrctachq
                              , pr_nrlotchq => pr_nrlotchq
                              , pr_sqlotchq => pr_sqlotchq
                              , pr_dtrefere => pr_dtrefere
                              , pr_hrtransa => pr_hrtransa
                              , pr_cdoperad => pr_cdoperad
                              , pr_dsidenti => pr_dsidenti
                              , pr_cdcooper => pr_cdcooper
                              , pr_nrdctitg => pr_nrdctitg
                              , pr_dscedent => pr_dscedent
                              , pr_cdcoptfn => pr_cdcoptfn
                              , pr_cdagetfn => pr_cdagetfn
                              , pr_nrterfin => pr_nrterfin
                              , pr_nrparepr => pr_nrparepr
                              , pr_nrseqava => pr_nrseqava
                              , pr_nraplica => pr_nraplica
                              , pr_cdorigem => pr_cdorigem
                              , pr_idlautom => pr_idlautom
                              , pr_inprolot => pr_inprolot
                              , pr_tplotmov => pr_tplotmov
                              , pr_tab_retorno => vr_rec_retorno
                              , pr_incrineg => pr_incrineg
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL OR
     nvl(vr_cdcritic,0) > 0 THEN
    RAISE vr_exc_erro;
  END IF;

  -- Criar documento XML
  dbms_lob.createtemporary(pr_dsretorn_xml, TRUE);
  dbms_lob.open(pr_dsretorn_xml, dbms_lob.lob_readwrite);
  vr_dstexto := NULL;

  -- Insere o cabeçalho do XML
  gene0002.pc_escreve_xml(pr_xml            => pr_dsretorn_xml
                         ,pr_texto_completo => vr_dstexto
                         ,pr_texto_novo     => '<root>');

  --Listar dados
  vr_string := '<lancamento>'||
                   '<rowid_lcm> '|| vr_rec_retorno.rowidlct  ||'</rowid_lcm>'||
                   '<recid_lcm> '|| vr_rec_retorno.progress_recid_lcm  ||'</recid_lcm>'||
                   '<nmtabela>  '|| vr_rec_retorno.nmtabela  ||'</nmtabela>'||
                   '<rowid_lot> '|| vr_rec_retorno.rowidlot  ||'</rowid_lot>'||
                   '<recid_lot> '|| vr_rec_retorno.progress_recid_lot  ||'</recid_lot>'||
               '</lancamento>';

  -- Escrever no XML
  gene0002.pc_escreve_xml(pr_xml            => pr_dsretorn_xml
                         ,pr_texto_completo => vr_dstexto
                         ,pr_texto_novo     => vr_string
                         ,pr_fecha_xml      => FALSE);

  -- Encerrar a tag raiz
  gene0002.pc_escreve_xml(pr_xml            => pr_dsretorn_xml
                         ,pr_texto_completo => vr_dstexto
                         ,pr_texto_novo     => '</root>'
                         ,pr_fecha_xml      => TRUE);


EXCEPTION
  WHEN vr_exc_erro THEN
    -- Se foi retornado apenas código
    IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    --Variavel de erro recebe erro ocorrido
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN

    -- Montar descrição de erro não tratado
    pr_dscritic := 'Erro não tratado na pc_gerar_lancto_conta_prog ' ||
                   SQLERRM;
END pc_gerar_lancto_conta_prog;

-- Incluir ou atualizar o lote (versão resumida - migrada da EMPR0001)
PROCEDURE pc_inclui_altera_lote(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                               ,pr_cdagenci IN crapass.cdagenci%TYPE --Codigo Agencia
                               ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE --Codigo Caixa
                               ,pr_nrdolote IN craplot.nrdolote%TYPE --Numero Lote
                               ,pr_tplotmov IN craplot.tplotmov%TYPE --Tipo movimento
                               ,pr_cdoperad IN craplot.cdoperad%TYPE --Operador
                               ,pr_cdhistor IN craplot.cdhistor%TYPE --Codigo Historico
                               ,pr_dtmvtopg IN crapdat.dtmvtolt%TYPE --Data Pagamento Emprestimo
                               ,pr_vllanmto IN craplcm.vllanmto%TYPE --Valor Lancamento
                               ,pr_flgincre IN BOOLEAN --Indicador Credito
                               ,pr_flgcredi IN BOOLEAN --Credito
                               ,pr_nrseqdig OUT INTEGER --Numero Sequencia
                               ,pr_cdcritic OUT INTEGER --Codigo Erro
                               ,pr_dscritic OUT VARCHAR2) IS --Descricao Erro
BEGIN
  /* .............................................................................

     Programa: pc_inclui_altera_lote                 Antigo: includes/b1craplot.p/inclui-altera-lote
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson
     Data    : Fevereiro/2014                        Ultima atualizacao: 25/02/2014

     Dados referentes ao programa:

     Frequencia: Diaria - Sempre que for chamada
     Objetivo  : Rotina para Incluir ou atualizar o lote

     Alteracoes: 25/02/2014 - Conversão Progress para Oracle (Alisson - AMcom)
                 10/05/2018 - Migração da package EMPR0001 para a LANC0001 (Reginaldo - AMcom)

  ............................................................................. */

  DECLARE
    --Variaveis Locais
    vr_nrincrem INTEGER;

    --Variaveis Erro
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis Excecao
    vr_exc_erro EXCEPTION;

  BEGIN

    --Inicializar variavel erro
    pr_cdcritic := NULL;
    pr_dscritic := NULL;

    --Numero Incremento
    IF pr_flgincre THEN
      vr_nrincrem := 1;
    ELSE
      vr_nrincrem := -1;
    END IF;

    /* Leitura do lote */
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => pr_dtmvtolt
                   ,pr_cdagenci => pr_cdagenci
                   ,pr_cdbccxlt => pr_cdbccxlt
                   ,pr_nrdolote => pr_nrdolote);

    --Posicionar no proximo registro
    FETCH cr_craplot
      INTO rw_craplot;
    --Se não encontrou registro
    IF cr_craplot%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_craplot;

      IF pr_flgcredi THEN -- Crédito
        /*Total de valores computados a credito no lote*/
        rw_craplot.vlcompcr := (pr_vllanmto * vr_nrincrem);
        /*Total de valores a credito do lote.*/
        rw_craplot.vlinfocr := (pr_vllanmto * vr_nrincrem);
        /*Total de valores computados a debito no lote.*/
        rw_craplot.vlcompdb := 0;
        /*Total de valores a debito do lote.*/
        rw_craplot.vlinfodb := 0;
      ELSE -- Débito
        /*Total de valores computados a credito no lote*/
        rw_craplot.vlcompcr := 0;
        /*Total de valores a credito do lote.*/
        rw_craplot.vlinfocr := 0;

        /*Total de valores computados a debito no lote.*/
        rw_craplot.vlcompdb := (pr_vllanmto * vr_nrincrem);
        /*Total de valores a debito do lote.*/
        rw_craplot.vlinfodb := (pr_vllanmto * vr_nrincrem);
      END IF;

      --Criar lote
      BEGIN
        INSERT INTO craplot
          (craplot.cdcooper
          ,craplot.dtmvtolt
          ,craplot.cdagenci
          ,craplot.cdbccxlt
          ,craplot.nrdolote
          ,craplot.tplotmov
          ,craplot.cdoperad
          ,craplot.cdhistor
          ,craplot.dtmvtopg
          ,craplot.nrseqdig
          ,craplot.qtcompln
          ,craplot.qtinfoln
          ,craplot.vlcompcr
          ,craplot.vlinfocr
          ,craplot.vlcompdb
          ,craplot.vlinfodb)
        VALUES
          (pr_cdcooper
          ,pr_dtmvtolt
          ,pr_cdagenci
          ,pr_cdbccxlt
          ,pr_nrdolote
          ,pr_tplotmov
          ,pr_cdoperad
          ,pr_cdhistor
          ,pr_dtmvtopg
          ,1
          ,vr_nrincrem
          ,vr_nrincrem
          ,rw_craplot.vlcompcr
          ,rw_craplot.vlinfocr
          ,rw_craplot.vlcompdb
          ,rw_craplot.vlinfodb)
        RETURNING craplot.nrseqdig, ROWID INTO pr_nrseqdig, rw_craplot.rowid;
      EXCEPTION
        WHEN Dup_Val_On_Index THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Lote ja cadastrado.';
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir na tabela de lotes. ' ||
                         sqlerrm;
          RAISE vr_exc_erro;
      END;
    ELSE
      --Fechar Cursor
      CLOSE cr_craplot;
      --Incrementar Sequencial
      rw_craplot.nrseqdig := nvl(rw_craplot.nrseqdig, 0) + 1;
      /*Quantidade computada de lancamentos.*/
      rw_craplot.qtcompln := nvl(rw_craplot.qtcompln, 0) + vr_nrincrem;
      /*Quantidade de lancamentos do lote.*/
      rw_craplot.qtinfoln := nvl(rw_craplot.qtinfoln, 0) + vr_nrincrem;

      IF pr_flgcredi THEN -- Crédito
        /*Total de valores computados a credito no lote*/
        rw_craplot.vlcompcr := nvl(rw_craplot.vlcompcr, 0) +
                               (pr_vllanmto * vr_nrincrem);
        /*Total de valores a credito do lote.*/
        rw_craplot.vlinfocr := nvl(rw_craplot.vlinfocr, 0) +
                               (pr_vllanmto * vr_nrincrem);
      ELSE -- Débito
        /*Total de valores computados a debito no lote.*/
        rw_craplot.vlcompdb := nvl(rw_craplot.vlcompdb, 0) +
                               (pr_vllanmto * vr_nrincrem);
        /*Total de valores a debito do lote.*/
        rw_craplot.vlinfodb := nvl(rw_craplot.vlinfodb, 0) +
                               (pr_vllanmto * vr_nrincrem);
      END IF;

      --Atualizar Lote
      BEGIN
        UPDATE craplot
           SET craplot.nrseqdig = rw_craplot.nrseqdig
              ,craplot.qtcompln = rw_craplot.qtcompln
              ,craplot.qtinfoln = rw_craplot.qtinfoln
              ,craplot.vlcompcr = rw_craplot.vlcompcr
              ,craplot.vlinfocr = rw_craplot.vlinfocr
              ,craplot.vlcompdb = rw_craplot.vlcompdb
              ,craplot.vlinfodb = rw_craplot.vlinfodb
         WHERE craplot.rowid = rw_craplot.rowid
        RETURNING rw_craplot.nrseqdig INTO pr_nrseqdig;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar lote. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;

    --Fechar Cursor
    IF cr_craplot%ISOPEN THEN
      CLOSE cr_craplot;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na rotina LANC0001.pc_inclui_altera_lote. ' || sqlerrm;
  END;
END pc_inclui_altera_lote;

-- Incluir registro na CRAPLOT
PROCEDURE pc_incluir_lote(pr_dtmvtolt   IN  craplot.dtmvtolt%TYPE DEFAULT NULL
                        , pr_cdagenci   IN  craplot.cdagenci%TYPE default 0
                        , pr_cdbccxlt   IN  craplot.cdbccxlt%TYPE default 0
                        , pr_nrdolote   IN  craplot.nrdolote%TYPE default 0
                        , pr_nrseqdig   IN  craplot.nrseqdig%TYPE default 0
                        , pr_qtcompln   IN  craplot.qtcompln%TYPE default 0
                        , pr_qtinfoln   IN  craplot.qtinfoln%TYPE default 0
                        , pr_tplotmov   IN  craplot.tplotmov%TYPE default 0
                        , pr_vlcompcr   IN  craplot.vlcompcr%TYPE default 0
                        , pr_vlcompdb   IN  craplot.vlcompdb%TYPE default 0
                        , pr_vlinfodb   IN  craplot.vlinfodb%TYPE default 0
                        , pr_vlinfocr   IN  craplot.vlinfocr%TYPE default 0
                        , pr_dtmvtopg   IN  craplot.dtmvtopg%TYPE DEFAULT NULL
                        , pr_tpdmoeda   IN  craplot.tpdmoeda%TYPE default 1
                        , pr_cdoperad   IN  craplot.cdoperad%TYPE default ' '
                        , pr_cdhistor   IN  craplot.cdhistor%TYPE default 0
                        , pr_cdbccxpg   IN  craplot.cdbccxpg%TYPE default 0
                        , pr_nrdcaixa   IN  craplot.nrdcaixa%TYPE default 0
                        , pr_cdopecxa   IN  craplot.cdopecxa%TYPE default ' '
                        , pr_qtinfocc   IN  craplot.qtinfocc%TYPE default 0
                        , pr_qtcompcc   IN  craplot.qtcompcc%TYPE default 0
                        , pr_vlinfocc   IN  craplot.vlinfocc%TYPE default 0
                        , pr_vlcompcc   IN  craplot.vlcompcc%TYPE default 0
                        , pr_qtcompcs   IN  craplot.qtcompcs%TYPE default 0
                        , pr_qtinfocs   IN  craplot.qtinfocs%TYPE default 0
                        , pr_vlcompcs   IN  craplot.vlcompcs%TYPE default 0
                        , pr_vlinfocs   IN  craplot.vlinfocs%TYPE default 0
                        , pr_qtcompci   IN  craplot.qtcompci%TYPE default 0
                        , pr_qtinfoci   IN  craplot.qtinfoci%TYPE default 0
                        , pr_vlcompci   IN  craplot.vlcompci%TYPE default 0
                        , pr_vlinfoci   IN  craplot.vlinfoci%TYPE default 0
                        , pr_nrautdoc   IN  craplot.nrautdoc%TYPE default 0
                        , pr_flgltsis   IN  craplot.flgltsis%TYPE default 0
                        , pr_cdcooper   IN  craplot.cdcooper%TYPE default 0
                        , pr_rw_craplot OUT cr_craplot%ROWTYPE -- Retorna dados do registro inserido na CRAPLOT
                        , pr_cdcritic   OUT PLS_INTEGER
                        , pr_dscritic   OUT VARCHAR2) IS

BEGIN
    /* ............................................................................
        Programa: pc_incluir_lote
        Sistema : Ayllos
        Sigla   : CRED
        Autor   : Reginaldo/AMcom
        Data    : Abril/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina centralizada para incluir registro na CRAPLOT
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

BEGIN
  pr_cdcritic := 0;
  pr_dscritic := '';

  INSERT INTO craplot lot (
      dtmvtolt
    , cdagenci
    , cdbccxlt
    , nrdolote
    , nrseqdig
    , qtcompln
    , qtinfoln
    , tplotmov
    , vlcompcr
    , vlcompdb
    , vlinfodb
    , vlinfocr
    , dtmvtopg
    , tpdmoeda
    , cdoperad
    , cdhistor
    , cdbccxpg
    , nrdcaixa
    , cdopecxa
    , qtinfocc
    , qtcompcc
    , vlinfocc
    , vlcompcc
    , qtcompcs
    , qtinfocs
    , vlcompcs
    , vlinfocs
    , qtcompci
    , qtinfoci
    , vlcompci
    , vlinfoci
    , nrautdoc
    , flgltsis
    , cdcooper
  )
  VALUES (
      pr_dtmvtolt
    , pr_cdagenci
    , pr_cdbccxlt
    , pr_nrdolote
    , pr_nrseqdig
    , pr_qtcompln
    , pr_qtinfoln
    , pr_tplotmov
    , pr_vlcompcr
    , pr_vlcompdb
    , pr_vlinfodb
    , pr_vlinfocr
    , pr_dtmvtopg
    , pr_tpdmoeda
    , pr_cdoperad
    , pr_cdhistor
    , pr_cdbccxpg
    , pr_nrdcaixa
    , pr_cdopecxa
    , pr_qtinfocc
    , pr_qtcompcc
    , pr_vlinfocc
    , pr_vlcompcc
    , pr_qtcompcs
    , pr_qtinfocs
    , pr_vlcompcs
    , pr_vlinfocs
    , pr_qtcompci
    , pr_qtinfoci
    , pr_vlcompci
    , pr_vlinfoci
    , pr_nrautdoc
    , pr_flgltsis
    , pr_cdcooper
  )
  RETURNING -- Retorna dados do registro inserido
       cdcooper
      ,dtmvtolt
      ,nrdolote
      ,cdagenci
      ,nrseqdig
      ,cdbccxlt
      ,qtcompln
      ,qtinfoln
      ,vlcompcr
      ,vlinfocr
      ,vlcompdb
      ,vlinfodb
      ,tplotmov
      ,rowid
  INTO
     pr_rw_craplot.cdcooper
    ,pr_rw_craplot.dtmvtolt
    ,pr_rw_craplot.nrdolote
    ,pr_rw_craplot.cdagenci
    ,pr_rw_craplot.nrseqdig
    ,pr_rw_craplot.cdbccxlt
    ,pr_rw_craplot.qtcompln
    ,pr_rw_craplot.qtinfoln
    ,pr_rw_craplot.vlcompcr
    ,pr_rw_craplot.vlinfocr
    ,pr_rw_craplot.vlcompdb
    ,pr_rw_craplot.vlinfodb
    ,pr_rw_craplot.tplotmov
    ,pr_rw_craplot.rowid
  ;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 9999;
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic) || ' pc_incluir_lote - ' || SQLERRM || ')';
  END;
END pc_incluir_lote;

FUNCTION fn_retorna_val_bloq_transf(pr_cdcooper craplcm.cdcooper%TYPE
                                  , pr_nrdconta craplcm.nrdconta%TYPE
                                  , pr_cdhistor craplcm.cdhistor%TYPE
                                  , pr_dtmvtolt craplcm.dtmvtolt%TYPE DEFAULT NULL)
  RETURN  tbblqj_ordem_transf.vlordem%TYPE AS vr_vlbloq tbblqj_ordem_transf.vlordem%TYPE;

  /* .............................................................................

    Programa: fn_retorna_val_bloq_transf
    Sistema :
    Sigla   : LANC
    Autor   : Heckmann - AMcom
    Data    : Agosto/2018.                  Ultima atualizacao: 28/08/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para identificar se o valor de credito se refere a TED
                para bloqueio judicial e se sobrará saldo que deverá ir para o bloqueado prejuizo..

    Alteracoes:

    ..............................................................................*/


  -- Cursores
  CURSOR cr_vlordem IS
    SELECT Sum(b.vlordem) vlordem
      FROM tbblqj_ordem_transf b
          ,tbblqj_ordem_online a
     WHERE a.tpordem = 4 -- Ted
       AND a.instatus = 1 -- Pendente
       AND b.idordem = a.idordem
       AND a.cdcooper = pr_cdcooper
       AND b.nrdconta = pr_nrdconta;
    rw_vlordem cr_vlordem%ROWTYPE;

  CURSOR cr_craplcm IS
    SELECT sum(craplcm.vllanmto) vllanmto
      FROM craplcm craplcm
     WHERE craplcm.cdcooper = pr_cdcooper
       AND craplcm.nrdconta = pr_nrdconta
       AND craplcm.cdhistor = pr_cdhistor
       AND craplcm.dtmvtolt = pr_dtmvtolt;
    rw_craplcm cr_craplcm%ROWTYPE;

BEGIN

  --> Buscar ordens de Transferencias pendentes
  OPEN cr_vlordem;
  FETCH cr_vlordem INTO rw_vlordem;
  CLOSE cr_vlordem;

  --> Buscar lançamentos no dia
  OPEN cr_craplcm;
  FETCH cr_craplcm INTO rw_craplcm;
  CLOSE cr_craplcm;

  -- Caso o valor de lançamentos for maior que o total de ordens está diferença deve ser
  -- transferida para o bloqueado prejuízo
  IF nvl(rw_craplcm.vllanmto,0) > nvl(rw_vlordem.vlordem,0) THEN
    vr_vlbloq := nvl(rw_craplcm.vllanmto,0) - nvl(rw_vlordem.vlordem,0);
  END IF;

  RETURN vr_vlbloq;

END fn_retorna_val_bloq_transf;

-- Rotina centralizada para estorno de lançamentos na conta corrente, com tratamento para
-- contas transferidas para prejuízo
PROCEDURE pc_estorna_lancto_conta(pr_cdcooper IN  craplcm.cdcooper%TYPE
                                , pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                , pr_cdagenci IN  craplcm.cdagenci%TYPE
                                , pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                                , pr_nrdolote IN  craplcm.nrdolote%TYPE
                                , pr_nrdctabb IN  craplcm.nrdctabb%TYPE
                                , pr_nrdocmto IN  craplcm.nrdocmto%TYPE
                                , pr_cdhistor IN  craplcm.cdhistor%TYPE
                                , pr_nrctachq IN  craplcm.nrctachq%TYPE
                                , pr_nrdconta IN  craplcm.nrdconta%TYPE
                                , pr_cdpesqbb IN  craplcm.cdpesqbb%TYPE
                                , pr_rowid    IN  ROWID
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE) IS

  vr_cdcooper craplcm.cdcooper%TYPE;
  vr_dtmvtolt craplcm.dtmvtolt%TYPE;
  vr_nrdocmto craplcm.nrdocmto%TYPE;
  vr_nrdconta craplcm.nrdconta%TYPE;

  vr_comando   varchar2(4000); -- usado para montar o comando a ser usado pelo cursor de leitura, retornando
                               -- os rowid conforme parametros passados

  vr_and       varchar2(10);   -- lógica para decidir se gera a clausula AND ou não

  wlinha rowid;                -- retorno do cursor, para poder fazer o DELETE na craplcm

  type t_cursor is ref cursor;
  c_cursor t_cursor;           -- cursor dinamico

  -- procedure usada para ir concatenando os parametros, respeitando clausula AND e ASPAS
  procedure pc_concatena(pr_comando in out varchar2, pr_conteudo in varchar2, pr_aspas in varchar2, pr_campo in varchar2) is
    vr_aspas varchar2(4);
  begin
     if pr_aspas = 'S' then
        vr_aspas := '''';
     else
        vr_aspas := null;
     end if;

     if pr_comando = 'SELECT ROWID FROM craplcm where ' then
        vr_and := null;
     else
        vr_and := ' and ';
     end if;

     pr_comando := pr_comando || vr_and || pr_campo || '=' || vr_aspas || pr_conteudo || vr_aspas;

  end pc_concatena;

BEGIN

  -- inicia montagem do comando, se vier rowid como parametro já assume e não trata os outros parametros
  if pr_rowid is not null then
     vr_comando := 'SELECT ROWID FROM craplcm where rowid = '||''''||pr_rowid||'''';
  else
     vr_comando := 'SELECT ROWID FROM craplcm where ';
     if nvl(pr_cdcooper,0) <> 0 then
        pc_concatena(vr_comando,pr_cdcooper,'N','cdcooper');
     end if;
--     if nvl(pr_dtmvtolt,' ') <> ' ' then
     if pr_dtmvtolt is not null then
        pc_concatena(vr_comando,pr_dtmvtolt,'S','dtmvtolt');
     end if;
     if nvl(pr_cdagenci,0) <> 0 then
        pc_concatena(vr_comando,pr_cdagenci,'N','cdagenci');
     end if;
     if nvl(pr_cdbccxlt,0) <> 0 then
        pc_concatena(vr_comando,pr_cdbccxlt,'N','cdbccxlt');
     end if;
     if nvl(pr_nrdolote,0) <> 0 then
        pc_concatena(vr_comando,pr_nrdolote,'N','nrdolote');
     end if;
     if nvl(pr_nrdctabb,0) <> 0 then
        pc_concatena(vr_comando,pr_nrdctabb,'N','nrdctabb');
     end if;
     if nvl(pr_nrdocmto,0) <> 0 then
        pc_concatena(vr_comando,pr_nrdocmto,'N','nrdocmto');
     end if;
     if nvl(pr_cdhistor,0) <> 0 then
        pc_concatena(vr_comando,pr_cdhistor,'N','cdhistor');
     end if;
     if nvl(pr_nrctachq,0) <> 0 then
        pc_concatena(vr_comando,pr_nrctachq,'N','nrctachq');
     end if;
     if nvl(pr_nrdconta,0) <> 0 then
        pc_concatena(vr_comando,pr_nrdconta,'N','nrdconta');
     end if;
     if nvl(pr_cdpesqbb,' ') <> ' ' then
        pc_concatena(vr_comando,pr_cdpesqbb,'S','cdpesqbb');
     end if;
  end if;

  -- inicio lógica DELETE
  open c_cursor for VR_comando;
  fetch c_cursor into wlinha;
  while c_cursor%FOUND loop
     --Exclui o lançamento da CRAPLCM
     DELETE FROM craplcm lcm
      WHERE ROWID = wlinha
     RETURNING LCM.cdcooper, lcm.dtmvtolt, lcm.nrdocmto, lcm.nrdconta
     INTO       vr_cdcooper,  vr_dtmvtolt, vr_nrdocmto,  vr_nrdconta;
     IF PREJ0003.fn_verifica_preju_conta(pr_cdcooper, vr_nrdconta) THEN
         -- Exclui lançamento de estorno do crédito da conta corrente para movimentação para a conta transitória
        DELETE FROM craplcm lcm
         WHERE lcm.cdcooper   = vr_cdcooper
           AND lcm.dtmvtolt   = vr_dtmvtolt
           AND lcm.nrdconta   = vr_nrdconta
            AND lcm.nrdocmto   = vr_nrdocmto
            AND lcm.cdhistor   = 2719;
        -- Exclui lançamento de crédito da conta transitória
         DELETE FROM tbcc_prejuizo_lancamento prj
         WHERE prj.cdcooper = vr_cdcooper
            AND prj.nrdconta = vr_nrdconta
            AND prj.dtmvtolt = vr_dtmvtolt
            AND prj.nrdocmto = vr_nrdocmto
            AND prj.cdhistor = 2738;
     END IF;
     -- le proxima linha
     fetch c_cursor into wlinha;
  end loop;
EXCEPTION
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro nao tratado na rotina "LANC0001.pc_estorna_lancto_conta": ' || SQLERRM;
END pc_estorna_lancto_conta;

PROCEDURE pc_estorna_lancto_prog (pr_cdcooper IN  craplcm.cdcooper%TYPE
                                , pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                , pr_cdagenci IN  craplcm.cdagenci%TYPE
                                , pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                                , pr_nrdolote IN  craplcm.nrdolote%TYPE
                                , pr_nrdctabb IN  craplcm.nrdctabb%TYPE
                                , pr_nrdocmto IN  VARCHAR2 --craplcm.nrdocmto%TYPE
                                , pr_cdhistor IN  craplcm.cdhistor%TYPE
                                , pr_nrctachq IN  craplcm.nrctachq%TYPE
                                , pr_nrdconta IN  craplcm.nrdconta%TYPE
                                , pr_cdpesqbb IN  craplcm.cdpesqbb%TYPE
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE) IS

  /* .............................................................................

    Programa: pc_estorna_lancto_prog
    Sistema :
    Sigla   : LANC
    Autor   :
    Data    : Agosto/2018.                  Ultima atualizacao: 07/12/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina centralizada para estorno de lançamentos na conta corrente, com tratamento para
                contas transferidas para prejuízo - Chamada Progress

    Alteracoes: 07/12/2018 - Ajustado pr_nrdocmto para varchar2 visto que o mesmo pode ter até 25 posicoes
                             que na comunicação com o Progress é truncado. PRJ450 - Regulatorio (Odirlei-AMcom)

    ..............................................................................*/
begin
   pc_estorna_lancto_conta(pr_cdcooper => pr_cdcooper
                         , pr_dtmvtolt => pr_dtmvtolt
                         , pr_cdagenci => pr_cdagenci
                         , pr_cdbccxlt => pr_cdbccxlt
                         , pr_nrdolote => pr_nrdolote
                         , pr_nrdctabb => pr_nrdctabb
                         , pr_nrdocmto => pr_nrdocmto
                         , pr_cdhistor => pr_cdhistor
                         , pr_nrctachq => pr_nrctachq
                         , pr_nrdconta => pr_nrdconta
                         , pr_cdpesqbb => pr_cdpesqbb
                         , pr_rowid    => null
                         , pr_cdcritic => pr_cdcritic
                         , pr_dscritic => pr_dscritic);

end pc_estorna_lancto_prog;


FUNCTION fn_verifica_cred_bloq_futuro (pr_cdcooper IN  craplcm.cdcooper%TYPE
                                     , pr_nrdconta IN  craplcm.nrdconta%TYPE
                                     , pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                     , pr_cdhistor IN  craplcm.cdhistor%TYPE
                                     , pr_nrdocmto IN  craplcm.nrdocmto%type
                                     ) return NUMBER is
   vr_existe number(1) := 0;
begin

   begin
      select 1 into vr_existe
      from crapdpb a
      where a.cdcooper = pr_cdcooper
        and a.nrdconta = pr_nrdconta
        and a.dtmvtolt = pr_dtmvtolt
        and a.cdhistor = pr_cdhistor
        and a.nrdocmto = pr_nrdocmto;
   exception
      when no_data_found then
         vr_existe := 0;
   end;

   return (vr_existe);

end FN_VERIFICA_CRED_BLOQ_FUTURO;



-- Rotina para estorno de saque em conta em prejuizo
PROCEDURE pc_estorna_saque_conta_prej(pr_cdcooper IN  craplcm.cdcooper%TYPE
                                    , pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                    , pr_cdagenci IN  craplcm.cdagenci%TYPE
                                    , pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                                    , pr_nrdctabb IN  craplcm.nrdctabb%TYPE
                                    , pr_nrdocmto IN  craplcm.nrdocmto%TYPE
                                    , pr_cdhistor IN  craplcm.cdhistor%TYPE
                                    , pr_nrdconta IN  craplcm.nrdconta%TYPE
                                    , pr_nrseqdig IN  craplcm.nrseqdig%TYPE
                                    , pr_vllanmto IN  craplcm.vllanmto%TYPE
                                    , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    , pr_dscritic OUT crapcri.dscritic%TYPE) IS
BEGIN

     IF PREJ0003.fn_verifica_preju_conta(pr_cdcooper, pr_nrdconta) THEN
         -- Efetua débito do valor que será transferido para a Conta Transitória (créditos bloqueados por prejuízo em conta)
        /*INSERT INTO craplcm (
                              dtmvtolt
                            , cdagenci
                            , cdbccxlt
                            , nrdolote
                            , nrdconta
                            , nrdocmto
                            , cdhistor
                            , nrseqdig
                            , vllanmto
                            , nrdctabb
                            , cdpesqbb
                            , dtrefere
                            , hrtransa
                            , cdoperad
                            , cdcooper
                            , cdorigem
                          )
        VALUES (
                pr_dtmvtolt
              , pr_cdagenci
              , pr_cdbccxlt
              , 650009
              , pr_nrdconta
              , pr_nrdocmto
              , 2719
              , pr_nrseqdig
              , pr_vllanmto
              , pr_nrdctabb
              , 'ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO'
              , pr_dtmvtolt
              , gene0002.fn_busca_time
              , 1
              , pr_cdcooper
              , 5
            );
        */
        --Substituida a inserção de débito pela exclusão do registro de crédito porque violou o indice CRAPLCM3
        DELETE FROM craplcm lcm
         WHERE lcm.dtmvtolt   = pr_dtmvtolt
           AND lcm.cdagenci   = pr_cdagenci
           AND lcm.cdbccxlt   = pr_cdbccxlt
           AND lcm.nrdconta   = pr_nrdconta
           AND lcm.nrdocmto   = pr_nrdocmto
           AND lcm.cdhistor   = pr_cdhistor
           AND lcm.nrseqdig   = pr_nrseqdig
           AND lcm.vllanmto   = pr_vllanmto
           AND lcm.nrdctabb   = pr_nrdctabb
           AND lcm.cdcooper   = pr_cdcooper;

        -- Insere lançamento do crédito transferido para a Conta Transitória
        INSERT INTO TBCC_PREJUIZO_LANCAMENTO (
                                               dtmvtolt
                                             , cdagenci
                                             , nrdconta
                                             , nrdocmto
                                             , cdhistor
                                             , vllanmto
                                             , dthrtran
                                             , cdoperad
                                             , cdcooper
                                             , cdorigem
                                             )
        VALUES (
                 pr_dtmvtolt
               , pr_cdagenci
               , pr_nrdconta
               , pr_nrdocmto
               , 2738
               , pr_vllanmto
               , SYSDATE
               , 1
               , pr_cdcooper
               , 5
               );
     END IF;

EXCEPTION
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro nao tratado na rotina "LANC0001.pc_estorna_saque_conta_prej": ' || SQLERRM;

END pc_estorna_saque_conta_prej;

END LANC0001;
/
