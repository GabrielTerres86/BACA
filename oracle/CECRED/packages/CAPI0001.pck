CREATE OR REPLACE PACKAGE CECRED.CAPI0001 IS

----------------------------------------------------------------------------------------------------------
--
--  Programa : CAPI0001
--  Sistema  : Rotinas genericas referentea integraliza��o de cotas
--  Sigla    : CAPI
--  Autor    : Ricardo Linhares - CECRED
--  Data     : Setembro - 2016.                   Ultima atualizacao: 23/03/2018
--
-- Dados referentes ao programa:
--
-- Frequencia : -----
-- Objetivo   : Agrupar rotinas genericas referente a integraliza��o de cotas
--
-- Alteracoes : 24/04/2017 - Nao considerar valores bloqueados na composicao de saldo disponivel
--                           Heitor (Mouts) - Melhoria 440
--
--              23/03/2018 - Incluido na rotina pc_integraliza_cotas valida��o de valores de integralizacao
--                           negativos ou zerados (Tiago/Jean INC0010838).
--
--              20/02/2018 - Removido tabela "craptip" do cursor "cr_crapass" na procedure
--                           pc_integraliza_cotas. PRJ366 (Lombardi).
--
--              23/05/2018 - Verificacao de valor minimo de capital quando for a primeira
--                           integralizacao na proc pc_integraliza_cotas. PRJ366 (Lombardi).
							   
--                01/08/2018 - PRJ450 - Centraliza��o de lan�amento na craplcm (Jos� Amcom)

--                15/10/2018 - PRJ450 - Regulatorios de Credito - centralizacao de estorno de lan�amentos na conta corrente              
--	                         pc_estorna_lancto_conta (Fabio Adriano - AMcom)
--
--                13/12/2018 - Remo��o da atualiza��o da capa de lote de COTAS
--                             Yuri - Mouts

---------------------------------------------------------------------------------------------------------
  -- Rotina para integralizar as cotas
  PROCEDURE pc_integraliza_cotas(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_cdagenci IN craplct.cdagenci%TYPE
                                ,pr_nrdcaixa IN INTEGER --Numero do Caixa
                                ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                ,pr_nmdatela IN VARCHAR2 --Nome da Tela
                                ,pr_idorigem IN INTEGER --Origem dos Dados
                                ,pr_nrdconta IN craplct.nrdconta%TYPE
                                ,pr_idseqttl IN craplgm.idseqttl%TYPE
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE -- Data do movimento
                                ,pr_vlintegr IN craplcm.vllanmto%TYPE
                                ,pr_flgnegat IN INTEGER -- flag que indica se permite nega
                                ,pr_cdcritic OUT PLS_INTEGER -- C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2); -- Descri��o da cr�tica

  -- Rotina para cancelar a integraliza��o.
  PROCEDURE pc_cancela_integralizacao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_cdagenci IN craplct.cdagenci%TYPE
                                     ,pr_nrdcaixa IN INTEGER
                                     ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                     ,pr_nmdatela IN VARCHAR2
                                     ,pr_idorigem IN INTEGER
                                     ,pr_nrdconta IN craplct.nrdconta%TYPE
                                     ,pr_idseqttl IN craplgm.idseqttl%TYPE
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE -- Data do movimento
                                     ,pr_nrdrowid IN VARCHAR2
                                     ,pr_cdcritic OUT PLS_INTEGER -- C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2); -- Descri��o da cr�tica

END CAPI0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.capi0001 IS

  TRUE CONSTANT NUMBER := 1;

  -- constante para validar origem
  vc_internet CONSTANT INTEGER := 3;
  
  -- constante para utilizar sempre a mesma agencia
  vc_cdagenci CONSTANT INTEGER := 1;

  -- constantes para lotes
  vc_lote_cotas_capital  CONSTANT INTEGER := 10002;
  vc_lote_deposito_vista CONSTANT INTEGER := 10129;
  vc_cdbccxlt            CONSTANT INTEGER := 100;
  tp_lote_cotas_capital  CONSTANT INTEGER := 2;
  tp_lote_deposito_vista CONSTANT INTEGER := 1;

  -- constantes dos h�storico
  cd_craplct_cdhist          CONSTANT INTEGER := 61;
  cd_craplcm_cdhist          CONSTANT INTEGER := 127;
  cd_craplct_cdhist_internet CONSTANT NUMBER(5) := 2138;
  cd_craplcm_cdhist_internet CONSTANT NUMBER(5) := 2139;

  PROCEDURE pc_buscar_lote_credito(pr_cdcooper IN craplot.cdcooper%TYPE
                                  ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                                  ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                                  ,pr_nrdolote IN craplot.nrdolote%TYPE
                                  ,pr_tplotmov IN craplot.tplotmov%TYPE
                                  ,pr_vlintegr IN craplot.vlcompcr%TYPE
                                  ,pr_qtinfoln OUT craplot.qtinfoln%TYPE
                                  ,pr_qtcompln OUT craplot.qtcompln%TYPE
                                  ,pr_nrseqdig OUT craplot.nrseqdig%TYPE) IS

    -- Cursor para o lote
    CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplot.cdagenci%TYPE
                     ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                     ,pr_nrdolote IN craplot.nrdolote%TYPE) IS

      SELECT ROWID
            ,nrseqdig
            ,qtcompln
            ,qtinfoln
            ,vlcompcr
            ,vlinfocr
        FROM craplot
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND cdagenci = pr_cdagenci
         AND cdbccxlt = pr_cdbccxlt
         AND nrdolote = pr_nrdolote;

    rw_craplot cr_craplot%ROWTYPE;

  BEGIN

    OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => pr_dtmvtolt
                   ,pr_cdagenci => vc_cdagenci
                   ,pr_cdbccxlt => pr_cdbccxlt
                   ,pr_nrdolote => pr_nrdolote);

    FETCH cr_craplot
     INTO rw_craplot;

    IF cr_craplot%NOTFOUND THEN
      pr_qtinfoln := 1;
      pr_qtcompln := 1;
      pr_nrseqdig := 1;

      INSERT INTO craplot
        (cdcooper
        ,dtmvtolt
        ,cdagenci
        ,cdbccxlt
        ,nrdolote
        ,tplotmov
        ,qtinfoln
        ,qtcompln
        ,nrseqdig
        ,vlcompcr
        ,vlinfocr)
      VALUES
        (pr_cdcooper
        ,pr_dtmvtolt
        ,vc_cdagenci
        ,pr_cdbccxlt
        ,pr_nrdolote
        ,pr_tplotmov
        ,pr_qtinfoln
        ,pr_qtcompln
        ,pr_nrseqdig
        ,pr_vlintegr
        ,pr_vlintegr);
    ELSE

      pr_qtinfoln := rw_craplot.qtinfoln + 1;
      pr_qtcompln := rw_craplot.qtcompln + 1;

      -- Como n�o incrementa mais no update, Busca o sequencial 
      rw_craplot.nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT',
                             pr_nmdcampo => 'NRSEQDIG',
                             pr_dsdchave => to_char(pr_cdcooper)||';'||
                                            to_char(pr_dtmvtolt,'DD/MM/RRRR')||';'||
                                            vc_cdagenci||';'||
                                            pr_cdbccxlt||';'||
                                            pr_nrdolote);
      pr_nrseqdig := rw_craplot.nrseqdig;

      -- comentado por Yuri - Mouts
/*    UPDATE craplot
         SET nrseqdig = pr_nrseqdig
            ,qtcompln = pr_qtcompln
            ,qtinfoln = pr_qtinfoln
            ,vlcompcr = craplot.vlcompcr + pr_vlintegr
            ,vlinfocr = craplot.vlinfocr + pr_vlintegr
       WHERE ROWID = rw_craplot.rowid;*/

    END IF;
    
    CLOSE cr_craplot;

  END pc_buscar_lote_credito;

  PROCEDURE pc_buscar_lote_debito(pr_cdcooper IN craplot.cdcooper%TYPE
                                  ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                                  ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                                  ,pr_nrdolote IN craplot.nrdolote%TYPE
                                  ,pr_tplotmov IN craplot.tplotmov%TYPE
                                  ,pr_vlintegr IN craplot.vlcompcr%TYPE
                                  ,pr_qtinfoln OUT craplot.qtinfoln%TYPE
                                  ,pr_qtcompln OUT craplot.qtcompln%TYPE
                                  ,pr_nrseqdig OUT craplot.nrseqdig%TYPE) IS

    -- Cursor para o lote
    CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplot.cdagenci%TYPE
                     ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                     ,pr_nrdolote IN craplot.nrdolote%TYPE) IS

      SELECT ROWID
            ,nrseqdig
            ,qtcompln
            ,qtinfoln
            ,vlcompdb
            ,vlinfodb
        FROM craplot
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND cdagenci = pr_cdagenci
         AND cdbccxlt = pr_cdbccxlt
         AND nrdolote = pr_nrdolote;

    rw_craplot cr_craplot%ROWTYPE;

  BEGIN

    OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => pr_dtmvtolt
                   ,pr_cdagenci => vc_cdagenci
                   ,pr_cdbccxlt => pr_cdbccxlt
                   ,pr_nrdolote => pr_nrdolote);

    FETCH cr_craplot
     INTO rw_craplot;

    IF cr_craplot%NOTFOUND THEN
      pr_qtinfoln := 1;
      pr_qtcompln := 1;
      pr_nrseqdig := 1;

      INSERT INTO craplot
        (cdcooper
        ,dtmvtolt
        ,cdagenci
        ,cdbccxlt
        ,nrdolote
        ,tplotmov
        ,qtinfoln
        ,qtcompln
        ,nrseqdig
        ,vlcompdb
        ,vlinfodb)
      VALUES
        (pr_cdcooper
        ,pr_dtmvtolt
        ,vc_cdagenci
        ,pr_cdbccxlt
        ,pr_nrdolote
        ,pr_tplotmov
        ,pr_qtinfoln
        ,pr_qtcompln
        ,pr_nrseqdig
        ,pr_vlintegr
        ,pr_vlintegr);
    ELSE

      pr_qtinfoln := rw_craplot.qtinfoln + 1;
      pr_qtcompln := rw_craplot.qtcompln + 1;
      -- Busca o sequencial 
      rw_craplot.nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT',
                             pr_nmdcampo => 'NRSEQDIG',
                             pr_dsdchave => to_char(pr_cdcooper)||';'||
                                            to_char(pr_dtmvtolt,'DD/MM/RRRR')||
                                            vc_cdagenci||';'||
                                            pr_cdbccxlt||';'||
                                            pr_nrdolote);

      pr_nrseqdig := rw_craplot.nrseqdig;
      -- comentado por Yuri - Mouts
/*      UPDATE craplot
         SET nrseqdig = pr_nrseqdig
            ,qtcompln = pr_qtcompln
            ,qtinfoln = pr_qtinfoln
            ,vlcompdb = craplot.vlcompdb + pr_vlintegr
            ,vlinfodb = craplot.vlinfodb + pr_vlintegr
       WHERE ROWID = rw_craplot.rowid;*/

    END IF;
    
    CLOSE cr_craplot;

  END pc_buscar_lote_debito;

  -- Busca o valor m�ximo para integraliza��o de acordo com o tipo de pessoa
  FUNCTION fn_buscar_val_max_integr(pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_nrdconta IN craplct.nrdconta%TYPE)
    RETURN NUMBER IS

    -- Cursor para o associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;

    -- vari�veis para implementa��o
    rw_crapass  cr_crapass%ROWTYPE;
    vr_dstextab craptab.dstextab%TYPE;
    vr_valmaxin NUMBER;
    vc_nrpos CONSTANT INTEGER := 35; -- Posi��o texto parametros

  BEGIN

    -- Busca o Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass
     INTO rw_crapass;

    -- Busca a parametriza��o de falor m�ximo para integraliza��o por tipo de pessoa (F�sica/Jur�dica)
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'LIMINTERNT'
                                             ,pr_tpregist => rw_crapass.inpessoa);

    -- Busca o valor m�ximo para integraliza��o
    vr_valmaxin := gene0002.fn_busca_entrada(pr_postext     => vc_nrpos
                                            ,pr_dstext      => vr_dstextab
                                            ,pr_delimitador => ';');
                                            
    CLOSE cr_crapass;                                            

    RETURN(vr_valmaxin);

  END fn_buscar_val_max_integr;

  -- Busca o saldo dispon�vel para integraliza��o
  PROCEDURE pc_buscar_saldo_disp_integra(pr_cdcooper IN crapcop.cdcooper%TYPE
                                        ,pr_cdagenci IN craplct.cdagenci%TYPE
                                        ,pr_nrdcaixa IN INTEGER --Numero do Caixa
                                        ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                        ,pr_nrdconta IN craplct.nrdconta%TYPE
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE -- Data do movimento
                                        ,pr_vlsaldoi OUT NUMBER -- Saldo para integralizacao
                                        ,pr_cdcritic OUT PLS_INTEGER
                                        ,pr_dscritic OUT VARCHAR2) IS

    -- variaveis para controle de cr�ticas
    vr_exc_erro EXCEPTION;
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(1000);

    -- vari�veis para consulta de saldo
    vr_tab_erro  gene0001.typ_tab_erro; --> Tabela com erros
    vr_tab_saldo extr0001.typ_tab_saldos; --> Tabela de retorno da rotina
    vr_des_reto  VARCHAR2(3);

    -- Cursor para encontrar a conta/corrente
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.nrdconta
            ,ass.vllimcre
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  BEGIN

    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- busca o associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
   FETCH cr_crapass
    INTO rw_crapass;
   CLOSE cr_crapass;


    -- Obtem os saldos do dia
    extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                               ,pr_rw_crapdat => rw_crapdat
                               ,pr_cdagenci   => pr_cdagenci
                               ,pr_nrdcaixa   => pr_nrdcaixa
                               ,pr_cdoperad   => pr_cdoperad
                               ,pr_nrdconta   => pr_nrdconta
                               ,pr_vllimcre   => rw_crapass.vllimcre
                               ,pr_dtrefere   => pr_dtmvtolt
                               ,pr_flgcrass   => FALSE
                               ,pr_tipo_busca => 'A'
                               ,pr_des_reto   => vr_des_reto
                               ,pr_tab_sald   => vr_tab_saldo
                               ,pr_tab_erro   => vr_tab_erro);

    IF vr_des_reto <> 'OK' THEN
      IF vr_tab_erro.count = 0 THEN
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
      END IF;
      vr_cdcritic := 0;
      vr_dscritic := 'Retorno NOK na extr0001.pc_obtem_saldo_dia e sem informa��o na pr_tab_erro, Conta: ' ||
                      pr_nrdconta;
      RAISE vr_exc_erro;
    END IF;

    pr_vlsaldoi := 0;

    IF vr_tab_saldo.count > 0 THEN

      pr_vlsaldoi := NVL(vr_tab_saldo(vr_tab_saldo.first).vlsddisp, 0) +
                     NVL(vr_tab_saldo(vr_tab_saldo.first).vlsdchsl, 0) +
                     NVL(vr_tab_saldo(vr_tab_saldo.first).vllimcre, 0);

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro integralizar cotas(CAPI0001.pc_integraliza_cotas): ' ||
                     SQLERRM;

  END pc_buscar_saldo_disp_integra;

  -- Rotina para integralizar contas
  PROCEDURE pc_integraliza_cotas(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_cdagenci IN craplct.cdagenci%TYPE
                                ,pr_nrdcaixa IN INTEGER --Numero do Caixa
                                ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                ,pr_nmdatela IN VARCHAR2 --Nome da Tela
                                ,pr_idorigem IN INTEGER --Origem dos Dados
                                ,pr_nrdconta IN craplct.nrdconta%TYPE
                                ,pr_idseqttl IN craplgm.idseqttl%TYPE
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE -- Data do movimento
                                ,pr_vlintegr IN craplcm.vllanmto%TYPE
                                ,pr_flgnegat IN INTEGER -- flag que indica se permite negativar
                                ,pr_cdcritic OUT PLS_INTEGER -- C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2) IS -- Descri��o da cr�tica

  vr_tab_retorno    LANC0001.typ_reg_retorno;
  vr_incrineg       INTEGER;  --> Indicador de cr�tica de neg�cio para uso com a "pc_gerar_lancamento_conta"
                                

    CURSOR cr_crapass(pr_cdcooper      IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta      IN crapass.nrdconta%TYPE) IS
    SELECT crapass.cdcooper
          ,crapass.nrdconta
          ,decode(crapass.inpessoa,1,1,2) inpessoa
          ,crapass.cdtipcta
      FROM crapass 
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    CURSOR cr_craplct(pr_cdcooper      IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta      IN crapass.nrdconta%TYPE) IS
    SELECT 1
      FROM craplct 
     WHERE craplct.cdcooper = pr_cdcooper
       AND craplct.nrdconta = pr_nrdconta;
    rw_craplct cr_craplct%ROWTYPE;
    
    -- Erros do processo

    -- vari�veis para consulta de valores
    vr_saldo_disponivel        NUMBER;
    vr_vlmaximo_integralizacao NUMBER;

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(1000);
    vr_tab_erro gene0001.typ_tab_erro;
    vr_des_reto VARCHAR2(3); 

    -- vari�ves referentes ao Lote (craplot)
    vr_qtinfoln craplot.qtinfoln%TYPE;
    vr_qtcompln craplot.qtcompln%TYPE;
    vr_nrseqdig craplot.nrseqdig%TYPE;

    -- vari�vel para controle de hist�rico
    vr_craplct_cdhist craplct.cdhistor%TYPE;
    vr_craplcm_cdhist craplcm.cdhistor%TYPE;
    
    vr_cdpesqbb craplcm.cdpesqbb%TYPE;
    vr_vlminimo NUMBER(25,2);
    vr_nmdcampo VARCHAR2(100);

    -- variaveis para log
    vr_dstransa VARCHAR2(150);
    vr_dsorigem VARCHAR2(40);
    vr_nrdrowid ROWID;


  BEGIN

    IF NVL(pr_vlintegr,0) <= 0 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Valor de integraliza��o n�o pode ser negativo ou zero.';
      RAISE vr_exc_erro;
    END IF;

    -- verifica o saldo dispon�vel para intgegraliza��o
    IF pr_flgnegat = TRUE THEN -- Pelo Ayllos pode for�ar a integraliza��o mesmo que a negative.

        pc_buscar_saldo_disp_integra(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_dtmvtolt => pr_dtmvtolt
                                    ,pr_vlsaldoi => vr_saldo_disponivel
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_dscritic => pr_dscritic);

        IF vr_saldo_disponivel < pr_vlintegr THEN
          vr_cdcritic := 0;
          vr_dscritic := 'N�o h� saldo suficiente para a opera��o.';
          RAISE vr_exc_erro;
        END IF;

    END IF;


    IF pr_idorigem = vc_internet THEN

      -- verifica o valor m�ximo para integraliza��o
      vr_vlmaximo_integralizacao := fn_buscar_val_max_integr(pr_cdcooper => pr_cdcooper
                                                            ,pr_nrdconta => pr_nrdconta);
      IF pr_vlintegr > vr_vlmaximo_integralizacao THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Valor m�ximo excedido para a opera��o.';
        RAISE vr_exc_erro;
      END IF;
      vr_craplct_cdhist := cd_craplct_cdhist_internet;
      vr_craplcm_cdhist := cd_craplcm_cdhist_internet;
    ELSE
      vr_craplct_cdhist := cd_craplct_cdhist;
      vr_craplcm_cdhist := cd_craplcm_cdhist;
      
      -- Abre o cursor de associados
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
                     
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
        
        CLOSE cr_crapass;
        
        pr_dscritic := 'Associado nao encontrado!';
        RAISE vr_exc_erro;
        
      END IF;
      
      CLOSE cr_crapass;    

      OPEN cr_craplct (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_craplct INTO rw_craplct;
      
      IF cr_craplct%FOUND THEN
      CADA0003.pc_busca_valor_minimo_capital(pr_cdcooper  => pr_cdcooper
                                            ,pr_cdagenci  => pr_cdagenci
                                            ,pr_nrdcaixa  => pr_nrdcaixa
                                            ,pr_idorigem  => pr_idorigem
                                            ,pr_nmdatela  => pr_nmdatela
                                            ,pr_cdoperad  => pr_cdoperad
                                            ,pr_cddopcao  => 'C'
                                            ,pr_cdcopsel  => pr_cdcooper
                                            ,pr_tppessoa  => rw_crapass.inpessoa
                                            ,pr_cdtipcta  => rw_crapass.cdtipcta
                                            ,pr_vlminimo  => vr_vlminimo
                                            ,pr_nmdcampo  => vr_nmdcampo  --Nome do Campo
                                            ,pr_des_erro  => vr_des_reto  --Saida OK/NOK
                                            ,pr_tab_erro  => vr_tab_erro); --Tabela Erros                                       
            
      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
          
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          pr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          pr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          pr_dscritic:= 'Erro ao executar a CADA0003.pc_busca_valor_minimo_capital.';
        END IF;    
          
        --Levantar Excecao
        RAISE vr_exc_erro;
              
          END IF;
        ELSE
          CADA0006.pc_valor_min_capital(pr_cdcooper         => pr_cdcooper
                                       ,pr_inpessoa         => rw_crapass.inpessoa
                                       ,pr_cdtipo_conta     => rw_crapass.cdtipcta
                                       ,pr_vlminimo_capital => vr_vlminimo
                                       ,pr_des_erro         => vr_des_reto
                                       ,pr_dscritic         => vr_dscritic);
          --Se Ocorreu erro
          IF vr_des_reto = 'NOK' THEN
            pr_dscritic := vr_dscritic;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;    
          
      END IF;
      
      IF NOT pr_vlintegr >= vr_vlminimo THEN
        
        vr_cdcritic := 0;
        vr_dscritic := 'O valor m�nimo deve ser R$ ' || to_char(vr_vlminimo,'fm999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') || '.';
        RAISE vr_exc_erro;
            
      END IF;
      
    END IF;

    -- Buscar lote para lan�amento de cotas
    pc_buscar_lote_credito(pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdbccxlt => vc_cdbccxlt
                          ,pr_nrdolote => vc_lote_cotas_capital
                          ,pr_tplotmov => tp_lote_cotas_capital
                          ,pr_vlintegr => pr_vlintegr
                          ,pr_qtinfoln => vr_qtinfoln
                          ,pr_qtcompln => vr_qtcompln
                          ,pr_nrseqdig => vr_nrseqdig);


    -- Lancamentos de cotas/capital - craplct
    BEGIN

      INSERT INTO craplct
        (cdcooper
        ,dtmvtolt
        ,cdagenci
        ,cdbccxlt
        ,nrdolote
        ,nrdconta
        ,nrdocmto
        ,cdhistor
        ,nrseqdig
        ,cdopeori
        ,cdageori
        ,dtinsori
        ,vllanmto)
      VALUES
        (pr_cdcooper
        ,pr_dtmvtolt
        ,vc_cdagenci
        ,vc_cdbccxlt
        ,vc_lote_cotas_capital
        ,pr_nrdconta
        ,vr_nrseqdig
        ,vr_craplct_cdhist
        ,vr_nrseqdig
        ,pr_cdoperad
        ,pr_cdagenci
        ,SYSDATE
        ,pr_vlintegr);
        
        vr_cdpesqbb := vr_nrseqdig;

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
             vr_cdcritic := 92;
             RAISE vr_exc_erro;
    END;

    -- Buscar lote para lan�amento de deposito a vista
      pc_buscar_lote_debito(pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdbccxlt => vc_cdbccxlt
                            ,pr_nrdolote => vc_lote_deposito_vista
                            ,pr_tplotmov => tp_lote_deposito_vista
                            ,pr_vlintegr => pr_vlintegr
                            ,pr_qtinfoln => vr_qtinfoln
                            ,pr_qtcompln => vr_qtcompln
                            ,pr_nrseqdig => vr_nrseqdig);

    -- cria lan�amento de depositos a vista - craplcm
    -- Inserir registro de cr�dito:
    LANC0001.pc_gerar_lancamento_conta(pr_cdagenci =>vc_cdagenci             -- cdagenci
                                      ,pr_cdbccxlt =>vc_cdbccxlt             -- cdbccxlt
                                      ,pr_cdhistor =>vr_craplcm_cdhist       -- cdhistor
                                      ,pr_dtmvtolt =>pr_dtmvtolt             -- dtmvtolt
                                      ,pr_cdpesqbb =>vr_cdpesqbb             -- cdpesqbb                                                                                                
                                      ,pr_nrdconta =>pr_nrdconta             -- nrdconta   
                                      ,pr_nrdctabb =>pr_nrdconta             -- nrdctabb
                                      ,pr_nrdctitg =>LPAD(pr_nrdconta, 9, 0) -- nrdctitg                                              
                                      ,pr_nrdocmto =>vr_nrseqdig             -- nrdocmto                                                
                                      ,pr_nrdolote =>vc_lote_deposito_vista  -- nrdolote                                                
                                      ,pr_nrseqdig =>vr_nrseqdig             -- nrseqdig
                                      ,pr_vllanmto =>pr_vlintegr             -- vllanmto 
                                      ,pr_cdcooper =>pr_cdcooper             -- cdcooper     

                                      -- OUTPUT --
                                      ,pr_tab_retorno => vr_tab_retorno
                                      ,pr_incrineg => vr_incrineg
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;    
    vr_nrdrowid := vr_tab_retorno.rowidlct;

   -- atualiza as cotas de capital
   UPDATE crapcot
      SET vldcotas = (vldcotas + pr_vlintegr)
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta;

    -- log
    vr_dstransa := 'Integraliza��o de capital';
    vr_dsorigem:= GENE0001.vr_vet_des_origens(pr_idorigem);

    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => SUBSTR(vr_dsorigem,1,13)
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time()
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => SUBSTR(pr_nmdatela,1,12)
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    -- Log de item
    GENE0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                              ,pr_nmdcampo => 'Documento'
                              ,pr_dsdadant => ' '
                              ,pr_dsdadatu => vr_cdpesqbb);

    GENE0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                              ,pr_nmdcampo => 'Valor'
                              ,pr_dsdadant => ' '
                              ,pr_dsdadatu => pr_vlintegr);


  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => pr_cdcritic
                           ,pr_dscritic => pr_dscritic
                           ,pr_tab_erro => vr_tab_erro);

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro integralizar cotas(CAPI0001.pc_integraliza_cotas): ' || SQLERRM;

  END pc_integraliza_cotas;

  -- Cancelar integraliza��o
  PROCEDURE pc_cancela_integralizacao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_cdagenci IN craplct.cdagenci%TYPE
                                     ,pr_nrdcaixa IN INTEGER
                                     ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                     ,pr_nmdatela IN VARCHAR2
                                     ,pr_idorigem IN INTEGER
                                     ,pr_nrdconta IN craplct.nrdconta%TYPE
                                     ,pr_idseqttl IN craplgm.idseqttl%TYPE
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE -- Data do movimento
                                     ,pr_nrdrowid IN VARCHAR2
                                     ,pr_cdcritic OUT PLS_INTEGER -- C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2) IS

    -- Cursor para encontrar a conta/corrente
    CURSOR cr_craplct(pr_nrdrowid IN craplct.progress_recid%TYPE) IS
      SELECT cdcooper
            ,nrdconta
            ,dtmvtolt
            ,nrdocmto
            ,vllanmto
            ,ROWID
            ,cdhistor
            ,cdagenci
            ,nrdolote
            ,cdbccxlt
        FROM craplct
       WHERE progress_recid = pr_nrdrowid;

    rw_craplct cr_craplct%ROWTYPE;

    --var�avel para hist�rico
    vr_cdhistor craplcm.cdhistor%TYPE;

    -- Cursor gen�rico de calend�rio
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Tratamento de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(1000);
    vr_des_reto  VARCHAR2(3);
    vr_tab_erro  gene0001.typ_tab_erro; --> Tabela com erros

    vr_dstransa VARCHAR2(150);
    vr_dsorigem VARCHAR2(40);

  BEGIN

     -- busca a data
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH btch0001.cr_crapdat
      INTO rw_crapdat;

      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        CLOSE BTCH0001.cr_crapdat;
      END IF;

     -- busca o lan�amento
      OPEN cr_craplct(pr_nrdrowid => pr_nrdrowid);
     FETCH cr_craplct
      INTO rw_craplct;

      IF cr_craplct%NOTFOUND THEN
         CLOSE cr_craplct;
         vr_dscritic := 'N�o foi poss�vel consultar lan�amento. -> ' || pr_nrdrowid ;
         RAISE vr_exc_erro;
      ELSE
          CLOSE cr_craplct;
      END IF;

     -- valida a data do registro
     IF rw_craplct.dtmvtolt <> pr_dtmvtolt THEN
         vr_dscritic := 'Apenas lan�amentos do dia podem ser cancelados.';
         RAISE vr_exc_erro;
     END IF;

     -- Valida o valor das cotas
      EXTR0001.pc_ver_capital(pr_cdcooper => pr_cdcooper -- C�digo da cooperativa
                             ,pr_cdagenci => pr_cdagenci         -- C�digo da ag�ncia
                             ,pr_nrdcaixa => pr_nrdcaixa         -- N�mero do caixa
                             ,pr_inproces => rw_crapdat.inproces -- Indicador do processo
                             ,pr_dtmvtolt => rw_craplct.dtmvtolt -- Data de movimento
                             ,pr_dtmvtopr => rw_crapdat.dtmvtopr -- Data do programa
                             ,pr_cdprogra => pr_nmdatela         -- C�digo do programa
                             ,pr_idorigem => pr_idorigem         -- Origem do programa
                             ,pr_nrdconta => pr_nrdconta -- N�mero da conta
                             ,pr_vllanmto => rw_craplct.vllanmto -- Valor de lancamento
                             ,pr_des_reto => vr_des_reto         -- Retorno OK/NOK
                             ,pr_tab_erro => vr_tab_erro);

      -- Se ocorreu erro
     IF vr_des_reto <> 'OK' THEN
       IF vr_tab_erro.COUNT > 0 THEN
         vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
         vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '|| pr_nrdconta;
       ELSE
         vr_cdcritic:= NULL;
         vr_dscritic:= 'Retorno "NOK" na EXTR0001.pc_ver_capital e sem informa��o na pr_tab_erro, Conta: '|| pr_nrdconta;
       END IF;
       RAISE vr_exc_erro;
     END IF;

     -- atualizar lote de cotas de capital (cr�dito lote)
     -- Comentado por Yuri - Mouts
/*   UPDATE craplot
        SET qtcompln = (qtcompln - 1)
           ,qtinfoln = (qtinfoln - 1)
           ,vlcompcr = (vlcompcr - rw_craplct.vllanmto)
           ,vlinfocr = (vlinfocr - rw_craplct.vllanmto)
      WHERE dtmvtolt = rw_craplct.dtmvtolt
        AND cdagenci = vc_cdagenci
        AND cdbccxlt = vc_cdbccxlt
        AND nrdolote = vc_lote_cotas_capital;*/

     -- atualizar lote de dep�sito (d�bito lote)
     -- Comentado por Yuri - Mouts
/*   UPDATE craplot
        SET qtcompln = (qtcompln - 1)
           ,qtinfoln = (qtinfoln - 1)
           ,vlcompdb = (vlcompdb - rw_craplct.vllanmto)
           ,vlinfodb = (vlinfodb - rw_craplct.vllanmto)
      WHERE dtmvtolt = rw_craplct.dtmvtolt
        AND cdagenci = vc_cdagenci
        AND cdbccxlt = vc_cdbccxlt
        AND nrdolote = vc_lote_deposito_vista;*/

     -- atualizar o valor das cotas
     UPDATE crapcot
        SET vldcotas = (vldcotas - rw_craplct.vllanmto)
      WHERE nrdconta = rw_craplct.nrdconta
        AND cdcooper = rw_craplct.cdcooper;

     -- excluir lan�amento na craplct
     DELETE craplct
      WHERE progress_recid = pr_nrdrowid;

     -- Verifica qual hist�rico deve utilizar na CRAPLCM
     IF rw_craplct.cdhistor = cd_craplct_cdhist_internet THEN
       vr_cdhistor := cd_craplcm_cdhist_internet;
     ELSE
       vr_cdhistor := cd_craplcm_cdhist;
     END IF;

     -- excluir lan�amento na craplcm

        
     lanc0001.pc_estorna_lancto_conta(pr_cdcooper => rw_craplct.cdcooper
                                    , pr_dtmvtolt => rw_craplct.dtmvtolt
                                    , pr_cdagenci => rw_craplct.cdagenci
                                    , pr_cdbccxlt => rw_craplct.cdbccxlt
                                    , pr_nrdolote => vc_lote_deposito_vista
                                    , pr_nrdctabb => NULL 
                                    , pr_nrdocmto => NULL
                                    , pr_cdhistor => vr_cdhistor
                                    , pr_nrctachq => NULL 
                                    , pr_nrdconta => rw_craplct.nrdconta
                                    , pr_cdpesqbb => rw_craplct.nrdocmto
                                    , pr_rowid    => NULL
                                    , pr_cdcritic => vr_cdcritic
                                    , pr_dscritic => vr_dscritic); 
                                         
     IF nvl(vr_cdcritic, 0) >= 0 OR vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Problemas ao excluir lancamento: '||vr_dscritic;
        RAISE vr_exc_erro;
     END IF; 

     -- log
    vr_dstransa := 'Cancelamento de integraliza��o de capital';
    vr_dsorigem:= GENE0001.vr_vet_des_origens(pr_idorigem);

    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => SUBSTR(vr_dsorigem,1,13)
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time()
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => SUBSTR(pr_nmdatela,1,12)
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => rw_craplct.rowid);

    -- Log de item
    GENE0001.pc_gera_log_item (pr_nrdrowid => rw_craplct.rowid
                              ,pr_nmdcampo => 'Documento'
                              ,pr_dsdadant => ' '
                              ,pr_dsdadatu => rw_craplct.nrdocmto);

    GENE0001.pc_gera_log_item (pr_nrdrowid => rw_craplct.rowid
                              ,pr_nmdcampo => 'Valor'
                              ,pr_dsdadant => ' '
                              ,pr_dsdadatu => rw_craplct.vllanmto);

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => pr_cdcritic
                           ,pr_dscritic => pr_dscritic
                           ,pr_tab_erro => vr_tab_erro);

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao cancelar integraliza��o de cotas(CAPI0001.pc_cancelar_integralizacao): ' || SQLERRM;


  END pc_cancela_integralizacao;

END capi0001;
/
