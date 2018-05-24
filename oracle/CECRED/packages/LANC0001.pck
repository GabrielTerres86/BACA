CREATE OR REPLACE PACKAGE CECRED.LANC0001 IS

-- Retorna TRUE ou FALSE indicando se um histórico pode ser debitado de uma conta
FUNCTION fn_pode_debitar(pr_cdcooper craplcm.cdcooper%TYPE
                       , pr_nrdconta craplcm.nrdconta%TYPE
                       , pr_cdhistor craplcm.cdhistor%TYPE) RETURN BOOLEAN;

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
                                  , pr_proclote IN  INTEGER DEFAULT 0 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                  , pr_tplotmov IN  craplot.tplotmov%TYPE DEFAULT 0
                                  , pr_cdcritic OUT PLS_INTEGER
                                  , pr_dscritic OUT VARCHAR2
																	, pr_rowid    OUT ROWID
																	, pr_tabela   OUT VARCHAR2);

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
                        , pr_rw_craplot OUT craplot%ROWTYPE -- Retorna o registro inserido na CRAPLOT
                        , pr_cdcritic   OUT PLS_INTEGER
                        , pr_dscritic   OUT VARCHAR2);

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
  -- Objetivo  : Procedimentos para lançamentos na CRAPLCM e tabelas auxiliares (CRAPLOT, ...)
  --
  -- Alterado  : 10/05/2018 - Migração do cursor "cr_craplot" e da procedure "pc_inclui_altera_lote" a partir
  --                          da package "EMPR0001".
  --                          (Reginaldo - AMcom - PRJ 450)
  --
  ---------------------------------------------------------------------------------------------------------------

TYPE typ_reg_historico IS RECORD (
     indebcre        craphis.indebcre%TYPE
   , inestoura_conta craphis.inestoura_conta%TYPE);

TYPE typ_tab_historico IS TABLE OF typ_reg_historico INDEX BY VARCHAR2(8);

vr_tab_historico typ_tab_historico; -- tabela para manter em memória dados dos históricos

TYPE typ_tab_atraso IS TABLE OF crapsld.qtddsdev%TYPE INDEX BY VARCHAR2(18);

vr_tab_atraso typ_tab_atraso; -- tabela para manter os dias de atraso (estouro) da conta

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
    FROM craplot craplot
   WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = pr_cdagenci
         AND craplot.cdbccxlt = pr_cdbccxlt
         AND craplot.nrdolote = pr_nrdolote;
rw_craplot cr_craplot%ROWTYPE;

-- Obtém dados do histórico (CRAPHIS)
FUNCTION fn_get_dados_historico(pr_cdcooper craplcm.cdcooper%TYPE
                              , pr_cdhistor craplcm.cdhistor%TYPE)
  RETURN typ_reg_historico AS vr_reg_historico typ_reg_historico;

  -- Recupera os do histórico
  CURSOR cr_historico IS
  SELECT his.inestoura_conta
       , his.indebcre
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
       vr_tab_historico(vr_chvhist).inestoura_conta := rw_historico.inestoura_conta;
     END IF;

     RETURN vr_reg_historico;
END fn_get_dados_historico;

-- Obtém dias em atraso da conta (estouro)
FUNCTION fn_get_dias_atraso(pr_cdcooper crapsld.cdcooper%TYPE
                          , pr_nrdconta crapsld.nrdconta%TYPE)
  RETURN crapsld.qtddsdev%TYPE AS vr_dias_atraso crapsld.qtddsdev%TYPE;

  -- Recupera a quantidade de dias em que a conta está devedora (estourada)
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
END fn_get_dias_atraso ;

-- Verifica se pode debitar um histórico em uma conta
FUNCTION fn_pode_debitar(pr_cdcooper craplcm.cdcooper%TYPE
                       , pr_nrdconta craplcm.nrdconta%TYPE
                       , pr_cdhistor craplcm.cdhistor%TYPE)
  RETURN BOOLEAN AS vr_pode_debitar BOOLEAN;  

  ----- >>> VARIÁVEIS <<<-----
  vr_qtd_dias_estouro crapsld.qtddsdev%TYPE; -- Quantidade de dias em que a conta está devedora (estourada) para verificação
  vr_reg_historico typ_reg_historico;

BEGIN
  vr_qtd_dias_estouro := fn_get_dias_atraso(pr_cdcooper, pr_nrdconta);

  vr_reg_historico := fn_get_dados_historico(pr_cdcooper, pr_cdhistor);

  vr_pode_debitar := TRUE;

  -- Se a conta está estourada há 60 dias ou mais e o histórico não permite debitar
  -- (aumentar o estouro da conta)
  IF vr_qtd_dias_estouro >= 60 AND vr_reg_historico.inestoura_conta = 0 THEN
    vr_pode_debitar := FALSE;
  END IF;

  RETURN vr_pode_debitar;
END fn_pode_debitar;

-- Inclui um novo lançamento na CRAPLCM
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
                                  , pr_proclote  IN  INTEGER DEFAULT 0 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                  , pr_tplotmov  IN  craplot.tplotmov%TYPE DEFAULT 0
                                  , pr_cdcritic  OUT PLS_INTEGER
                                  , pr_dscritic  OUT VARCHAR2
																	, pr_rowid     OUT ROWID             -- Rowid do registro inserido 
																	, pr_tabela    OUT VARCHAR2) IS      -- Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)
BEGIN
   /* ............................................................................
        Programa: pc_gerar_lancamento_conta
        Sistema : Ayllos
        Sigla   : CRED
        Autor   : Reginaldo/AMcom
        Data    : Abril/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina centralizada para incluir lançamentos na CRAPLCM, fazendo as críticas necessárias
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE
    ----->>> VARIÁVEIS <<<-----
    vr_reg_historico  typ_reg_historico;       -- Registro para armazenar os dados do histórico
    vr_nrseqdig       craplot.nrseqdig%TYPE;   -- Aramazena o valor do campo "nrseqdig" da CRAPLOT para referência na CRAPLCM
    vr_flgcredi       BOOLEAN;                 -- Flag indicadora para Crédito/Débito
    vr_exc_erro       EXCEPTION;

BEGIN
	-- Inicialização de variáveis/parâmetros
  pr_cdcritic := 0;
  pr_dscritic := '';
	pr_tabela   := 'CRAPLCM'; -- Fluxo padrão insere na CRAPLCM
  vr_nrseqdig := pr_nrseqdig;
	
 
  vr_reg_historico := fn_get_dados_historico(pr_cdcooper, pr_cdhistor);

  -- Se o lançamento é um débito e o histórico não permite estourar a conta
  IF vr_reg_historico.indebcre = 'D' AND vr_reg_historico.inestoura_conta = 0 THEN
		-- Se a conta está estourada e não permite debitar
		IF NOT fn_pode_debitar(pr_cdcooper, pr_nrdconta, pr_cdhistor) THEN
       pr_cdcritic := 1139;
       pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic);
       RETURN;
		-- ELSIF vr_reg_historico.indebcre = 'C' AND fn_verifica_preju_conta(pr_cdcooper, pr_nrdconta) THEN
		END IF;
  END IF;

  IF pr_proclote = 1 THEN -- insere/altera lote
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
    IF pr_cdcritic IS NOT NULL OR pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  END IF;

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
    , pr_dsidenti
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
	RETURNING ROWID INTO pr_rowid;


  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := 'Erro: ' || ' pc_gerar_lancamento_conta - ' || pr_dscritic || ')';
    WHEN OTHERS THEN
      pr_cdcritic := 9999;
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic) || ' pc_gerar_lancamento_conta - ' || SQLERRM || ')';
  END;
END pc_gerar_lancamento_conta;

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
                        , pr_rw_craplot OUT craplot%ROWTYPE -- Retorna o registro inserido na CRAPLOT
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
DECLARE

  -- Recupera o registro inserido na CRAPLOT para retornar no parâmetro "pr_rw_craplot"
  CURSOR cr_craplot(pr_progress_recid craplot.progress_recid%TYPE) IS
  SELECT lot.*
    FROM craplot lot
   WHERE lot.progress_recid = pr_progress_recid;

  vr_progress_recid craplot.progress_recid%TYPE; -- Guarda o PROGRESS_RECID do registro inserido na CRAPLOT

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
  RETURNING
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
		, progress_recid
	INTO
		pr_rw_craplot.dtmvtolt
    , pr_rw_craplot.cdagenci
    , pr_rw_craplot.cdbccxlt
    , pr_rw_craplot.nrdolote
    , pr_rw_craplot.nrseqdig
    , pr_rw_craplot.qtcompln
    , pr_rw_craplot.qtinfoln
    , pr_rw_craplot.tplotmov
    , pr_rw_craplot.vlcompcr
    , pr_rw_craplot.vlcompdb
    , pr_rw_craplot.vlinfodb
    , pr_rw_craplot.vlinfocr
    , pr_rw_craplot.dtmvtopg
    , pr_rw_craplot.tpdmoeda
    , pr_rw_craplot.cdoperad
    , pr_rw_craplot.cdhistor
    , pr_rw_craplot.cdbccxpg
    , pr_rw_craplot.nrdcaixa
    , pr_rw_craplot.cdopecxa
    , pr_rw_craplot.qtinfocc
    , pr_rw_craplot.qtcompcc
    , pr_rw_craplot.vlinfocc
    , pr_rw_craplot.vlcompcc
    , pr_rw_craplot.qtcompcs
    , pr_rw_craplot.qtinfocs
    , pr_rw_craplot.vlcompcs
    , pr_rw_craplot.vlinfocs
    , pr_rw_craplot.qtcompci
    , pr_rw_craplot.qtinfoci
    , pr_rw_craplot.vlcompci
    , pr_rw_craplot.vlinfoci
    , pr_rw_craplot.nrautdoc
    , pr_rw_craplot.flgltsis
    , pr_rw_craplot.cdcooper
		, pr_rw_craplot.progress_recid
	; -- Retorna o reigstro inserido

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 9999;
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic) || ' pc_incluir_lote - ' || SQLERRM || ')';
  END;
END pc_incluir_lote;

END LANC0001;
/
