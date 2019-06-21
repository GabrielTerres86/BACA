CREATE OR REPLACE PACKAGE CECRED.PREJ0006 AS
/*...............................................................................

     Programa: PREJ0006                       Antigo: Nao ha
     Sistema : Cred
     Sigla   : CRED
     Autor   : Reginaldo Rubens da Silva - AMCom
     Data    : Abril/2019                                      Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Di�ria (sempre que chamada)
     Objetivo  : Rotinas complementares do preju�zo de conta corrente (complemento da PREJ0003).

     Alteracoes: 

  ..............................................................................*/
  
  
-- Obt�m o saldo da movimenta��o do dia na CRAPLCM (cr�ditos - d�bitos)
FUNCTION fn_obtem_saldo_lcm_dia(pr_cdcooper IN NUMBER
                              , pr_nrdconta IN NUMBER
                              , pr_dtmvtolt IN DATE DEFAULT NULL)  RETURN NUMBER;
                              
-- Zera o saldo liberado da Conta Transit�ria para opera��es de saque
PROCEDURE pc_zera_saldo_liberado_CT(pr_cdcooper IN NUMBER
                                  , pr_nrdconta IN NUMBER);  
                                  
-- Incrementa saldo do preju�zo de conta corrente
PROCEDURE pc_incrementa_saldo_prej(pr_cdcooper IN NUMBER
                                 , pr_nrdconta IN NUMBER
                                 , pr_vllanmto IN NUMBER
                                 , pr_dtmvtolt IN DATE DEFAULT NULL
                                 , pr_cdcritic OUT NUMBER
                                 , pr_dscritic OUT VARCHAR2);                                                                   
                                  
-- Bloqueia valor da CRAPLCM para a conta Transit�ria
PROCEDURE pc_bloqueia_valor_para_CT(pr_cdcooper IN NUMBER
                                  , pr_nrdconta IN NUMBER
                                  , pr_vllanmto IN NUMBER
                                  , pr_cdcritic IN OUT crapcri.cdcritic%TYPE
                                  , pr_dscritic IN OUT crapcri.dscritic%TYPE);                                                                                              

--  Processa d�bitos que incrementam saldo do preju�zo da conta corrente                                
PROCEDURE pc_processa_debt_inc_prj(pr_cdcooper IN NUMBER);                                  

end PREJ0006;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0006 AS
/*..............................................................................

   Programa: PREJ0006                       Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Reginaldo Rubens da Silva - AMCom
   Data    : Abril/2019                                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Di�ria (sempre que chamada)
   Objetivo  : Rotinas complementares do preju�zo de conta corrente (complemento da PREJ0003).

   Alteracoes:
..............................................................................*/

-- Obt�m o saldo da movimenta��o do dia na CRAPLCM (cr�ditos - d�bitos)
FUNCTION fn_obtem_saldo_lcm_dia(pr_cdcooper IN NUMBER
                              , pr_nrdconta IN NUMBER
                              , pr_dtmvtolt IN DATE DEFAULT NULL)
  RETURN NUMBER IS
    
  /* .............................................................................

   Programa: fn_obtem_saldo_lcm_dia
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Abril/2019.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Obt�m o saldo da movimenta��o do dia na CRAPLCM

   Observacao:
   
   Alteracoes:
   ..............................................................................*/
   
    CURSOR cr_craplcm(pr_cdcooper NUMBER 
                    , pr_nrdconta NUMBER
                    , pr_dtmvtolt DATE) IS
    SELECT nvl(SUM(decode(his.indebcre, 'C', lcm.vllanmto, lcm.vllanmto * (-1))), 0)
      FROM craplcm lcm
         , craphis his
     WHERE lcm.cdcooper = pr_cdcooper
       AND lcm.nrdconta = pr_nrdconta
       AND lcm.dtmvtolt = pr_dtmvtolt
       AND his.cdcooper = lcm.cdcooper
       AND his.cdhistor = lcm.cdhistor
       AND lcm.cdhistor <> 2919; -- Exclui os lan�amentos de cr�dito de abono do CYBER
			 
    vr_dtmvtolt DATE := pr_dtmvtolt;
		vr_sldmvdia NUMBER;
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
	BEGIN
    IF pr_dtmvtolt IS NULL THEN
      OPEN BTCH0001.cr_crapdat(pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      
      vr_dtmvtolt:= rw_crapdat.dtmvtolt;
    END IF;
    
		OPEN cr_craplcm(pr_cdcooper
                  , pr_nrdconta
                  , vr_dtmvtolt);
		FETCH cr_craplcm INTO vr_sldmvdia;
		
		CLOSE cr_craplcm;
		
		RETURN vr_sldmvdia;
END fn_obtem_saldo_lcm_dia;

-- Verifica se houve estorno do lan�amento de d�bito no mesmo dia
FUNCTION fn_verifica_estorno_debito(pr_cdcooper IN craplcm.cdcooper%TYPE
                                  , pr_nrdconta IN craplcm.nrdconta%TYPE
                                  , pr_cdhistor IN craplcm.cdhistor%TYPE
                                  , pr_nrdocmto IN craplcm.nrdocmto%TYPE
                                  , pr_vllanmto IN craplcm.vllanmto%TYPE
                                  , pr_dtmvtolt IN craplcm.dtmvtolt%TYPE)
  RETURN BOOLEAN IS
  
 /* .............................................................................

   Programa: fn_verifica_estorno_debito
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Abril/2019.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Verifica se houve estorno do lan�amento de d�bito no mesmo dia

   Observacao:
   
   Alteracoes: 21/06/2019 - P450 - Corre��o para filtrar nro docto conforme regra estorno (crps444)
                            somando + 1000000 (Marcelo/AMCom)
   ..............................................................................*/ 
  
  TYPE typ_tab_hisest IS TABLE OF VARCHAR(100) 
    INDEX BY PLS_INTEGER;
    
  vr_tab_hisest typ_tab_hisest; -- Tabela com rela��o de poss�veis hist�ricos de estorno para cada hist�rico de d�bito
  vr_numlctos INTEGER;
  vr_sqlinstr VARCHAR2(1000);
BEGIN
  /* Montagem da tabela com a lista de hist�ricos de estorno para cada hist�rico de d�bito.
     Separar a listagem de hist�ricos de estorno com ",". */
  vr_tab_hisest(661) := '662';
  vr_tab_hisest(524) := '47,573';
  vr_tab_hisest(521) := '47';
  vr_tab_hisest(21)  := '47';
  
  -- Se o hist�rico de d�bito n�o est� na tabela de hist�ricos de estorno
  IF NOT vr_tab_hisest.exists(pr_cdhistor) THEN
    RETURN FALSE;
  END IF;
  
  vr_sqlinstr:= 'SELECT COUNT(*) ' ||
                '  FROM CRAPLCM ' || 
                ' WHERE cdcooper = :pr_cdcooper ' ||
                '   AND nrdconta = :pr_nrdconta ' ||
                '   AND dtmvtolt = :pr_dtmvtolt ' ||
                '   AND (nrdocmto = :pr_nrdocmto OR nrdocmto = ''1'' || :pr_nrdocmto OR nrdocmto = :pr_nrdocmto + 1000000) ' || -- em alguns casos, usa-se o "1" como prefixo do n�mero do documento no hist�rico de estorno
                '   AND vllanmto = :pr_vllanmto ' ||
                '   AND cdhistor in (:pr_lshistor) ';
                
  EXECUTE IMMEDIATE vr_sqlinstr
    INTO vr_numlctos
    USING pr_cdcooper
        , pr_nrdconta
        , pr_dtmvtolt
        , pr_nrdocmto
        , pr_nrdocmto
        , pr_nrdocmto
        , pr_vllanmto
        , vr_tab_hisest(pr_cdhistor);
    
  RETURN vr_numlctos > 0; -- Se h� lan�amentos, o d�bito foi estornado
END fn_verifica_estorno_debito;

-- Zera o saldo liberado da Conta Transit�ria para opera��es de saque
PROCEDURE pc_zera_saldo_liberado_CT(pr_cdcooper IN NUMBER
                                  , pr_nrdconta IN NUMBER) IS
	/* .............................................................................

   Programa: pc_zera_saldo_liberado_CT
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Abril/2019.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado

   Objetivo  : Zera o saldo liberado da Conta Transit�ria para opera��es de saque

   Observacao:
   
   Alteracoes:
   ..............................................................................*/
BEGIN
  UPDATE tbcc_prejuizo prj
     SET prj.vlsldlib = 0
   WHERE prj.cdcooper = pr_cdcooper
     AND prj.nrdconta = pr_nrdconta
     AND dtliquidacao IS NULL;      
END pc_zera_saldo_liberado_CT;

-- Bloqueia valor da CRAPLCM para a conta Transit�ria
PROCEDURE pc_bloqueia_valor_para_CT(pr_cdcooper IN NUMBER
                                  , pr_nrdconta IN NUMBER
                                  , pr_vllanmto IN NUMBER
                                  , pr_cdcritic IN OUT crapcri.cdcritic%TYPE
                                  , pr_dscritic IN OUT crapcri.dscritic%TYPE) IS
	/* .............................................................................

   Programa: pc_bloqueia_valor_para_CT
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Abril/2019.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado

   Objetivo  : Bloqueia valor da CRAPLCM para a conta Transit�ria

   Observacao:
   
   Alteracoes:
   ..............................................................................*/
   
  CURSOR cr_nrdocmto(pr_cdcooper NUMBER
                   , pr_dtmvtolt DATE
                   , pr_cdagenci NUMBER
                   , pr_cdbccxlt NUMBER
                   , pr_nrdolote NUMBER
                   , pr_nrdctabb NUMBER) IS 
  SELECT nvl(MAX(nrdocmto), 0) + 1 nrdocmto
    FROM craplcm
   WHERE cdcooper = pr_cdcooper
     AND dtmvtolt = pr_dtmvtolt
     AND cdagenci = pr_cdagenci
     AND cdbccxlt = pr_cdbccxlt
     AND nrdctabb = pr_nrdctabb;
     
  vr_nrdocmto NUMBER;  
  vr_incrineg INTEGER;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  vr_nrseqdig craplcm.nrseqdig%TYPE;
  
  vr_exc_semsaldo EXCEPTION;
  
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;   
BEGIN
  pr_cdcritic:= NULL;
  pr_dscritic:= NULL;
  
  OPEN BTCH0001.cr_crapdat(pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;
  
  IF pr_vllanmto > fn_obtem_saldo_lcm_dia(pr_cdcooper => pr_cdcooper
                                        , pr_nrdconta => pr_nrdconta
                                        , pr_dtmvtolt => rw_crapdat.dtmvtolt) THEN
    RAISE vr_exc_semsaldo;
  END IF;

  -- Calcula n�mero do documento
  OPEN cr_nrdocmto(pr_cdcooper => 1
                 , pr_dtmvtolt => rw_crapdat.dtmvtolt
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 650009
                 , pr_nrdctabb => pr_nrdconta);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                            ,pr_nmdcampo => 'NRSEQDIG'
                            ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                            to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')||';'||
                            '1;100;650009');

  -- Efetua d�bito do valor que ser� transferido para a Conta Transit�ria 
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
    , dtrefere
    , hrtransa
    , cdoperad
    , cdcooper
    , cdorigem
  )
  VALUES (
      rw_crapdat.dtmvtolt
    , 1
    , 100
    , 650009
    , pr_nrdconta
    , vr_nrdocmto
    , 2719
    , vr_nrseqdig
    , pr_vllanmto 
    , pr_nrdconta
    , 'BLOQUEADO PREJU�ZO'
    , rw_crapdat.dtmvtolt
    , gene0002.fn_busca_time
    , 1
    , pr_cdcooper
    , 5
  );

  -- Insere lan�amento do cr�dito transferido para a Conta Transit�ria
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
         rw_crapdat.dtmvtolt
       , 1
       , pr_nrdconta
       , vr_nrdocmto
       , 2738 
       , pr_vllanmto 
       , SYSDATE
       , 1
       , pr_cdcooper
       , 5
  );
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_semsaldo THEN
    pr_cdcritic:= 717; -- Nao ha saldo suficiente para a operacao.
    pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    
    ROLLBACK;
  WHEN OTHERS THEN
    pr_cdcritic:= 0;
    pr_dscritic:= 'Erro n�o tratado na PREJ0006.pc_bloqueia_valor_para_CT (' || SQLERRM || ').';
    
    ROLLBACK;
END pc_bloqueia_valor_para_CT;

-- Incrementa saldo do preju�zo de conta corrente
PROCEDURE pc_incrementa_saldo_prej(pr_cdcooper IN NUMBER
                                 , pr_nrdconta IN NUMBER
                                 , pr_vllanmto IN NUMBER
                                 , pr_dtmvtolt IN DATE DEFAULT NULL
                                 , pr_cdcritic OUT NUMBER
                                 , pr_dscritic OUT VARCHAR2) IS
	/* .............................................................................

   Programa: pc_incrementa_saldo_prej
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Abril/2019.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado

   Objetivo  : Incrementa saldo do preju�zo de conta corrente

   Observacao:
   
   Alteracoes:
   ..............................................................................*/
   
  CURSOR cr_prejuizo IS
  SELECT prj.ROWID 
    FROM tbcc_prejuizo prj
   WHERE prj.cdcooper = pr_cdcooper
     AND prj.nrdconta = pr_nrdconta
     AND prj.dtliquidacao IS NULL;
      
  vr_rowidprj ROWID;
  vr_dtmvtolt DATE:= pr_dtmvtolt;
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(2000);
  
  vr_exc_prejnaoencontrado EXCEPTION;
  vr_exc_errolanct2408     EXCEPTION;
  
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
BEGIN
  pr_cdcritic:= NULL;
  pr_dscritic:= NULL;
  
  IF pr_dtmvtolt IS NULL THEN
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
  END IF;
  
  OPEN cr_prejuizo;
  FETCH cr_prejuizo INTO vr_rowidprj;
  
  IF cr_prejuizo%NOTFOUND THEN
    CLOSE cr_prejuizo;
    
    RAISE vr_exc_prejnaoencontrado;
  END IF;
  
  CLOSE cr_prejuizo;
  
  BEGIN
    SAVEPOINT savtransincrprejuizo;
    
    PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                                    , pr_nrdconta => pr_nrdconta
                                    , pr_dtmvtolt => vr_dtmvtolt
                                    , pr_cdhistor => 2408 -- Transfer�ncia de valor para preju�zo de conta corrente
                                    , pr_vllanmto => pr_vllanmto
                                    , pr_dthrtran => SYSDATE
                                    , pr_cdcritic => pr_cdcritic
                                    , pr_dscritic => pr_dscritic);
                                    
    IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN 
      RAISE vr_exc_errolanct2408;
    END IF;
    
    UPDATE tbcc_prejuizo prj
       SET prj.vlsdprej = prj.vlsdprej + pr_vllanmto
     WHERE prj.rowid = vr_rowidprj;    
  EXCEPTION
    WHEN vr_exc_prejnaoencontrado THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'N�o h� preju�zo ativo para a conta corrente ' || pr_nrdconta;
      
      ROLLBACK TO SAVEPOINT savtransincrprejuizo;
    WHEN vr_exc_errolanct2408 THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro ao incluir lan�amento com hist�rico 2408.';
      
      ROLLBACK TO SAVEPOINT savtransincrprejuizo;
    WHEN OTHERS THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro n�o tratado na PREJ0006.pc_incrementa_saldo_prej (' || SQLERRM || ').';
      
      ROLLBACK TO SAVEPOINT savtransincrprejuizo;
  END;
END pc_incrementa_saldo_prej;

-- Processa d�bitos que incrementam saldo do preju�zo da conta corrente
PROCEDURE pc_processa_debt_inc_prj(pr_cdcooper IN NUMBER) IS
	/* .............................................................................

   Programa: pc_processa_debt_inc_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Abril/2019.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado

   Objetivo  : Processa d�bitos que incrementam saldo do preju�zo da conta corrente

   Observacao:
   
   Alteracoes:
   ..............................................................................*/
   
  -- Busca lan�amentos de d�bito ocorridos em contas em preju�zo no dia
  CURSOR cr_craplcm(pr_cdcooper NUMBER
                  , pr_dtmvtolt DATE) IS
  SELECT lcm.nrdconta
       , his.cdhistor
       , lcm.vllanmto
       , lcm.nrdocmto
    FROM craplcm lcm
       , craphis his
       , tbcc_prejuizo prj
   WHERE lcm.cdcooper = pr_cdcooper
     AND lcm.dtmvtolt = pr_dtmvtolt
     AND prj.cdcooper = lcm.cdcooper
     AND prj.nrdconta = lcm.nrdconta
     AND prj.dtinclusao <= lcm.dtmvtolt
     AND prj.dtliquidacao IS NULL
     AND his.cdcooper = lcm.cdcooper
     AND his.cdhistor = lcm.cdhistor
     AND his.indebcre = 'D';
  rw_craplcm cr_craplcm%ROWTYPE;
  
  -- Calend�rio de datas da cooperativa
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE; 
  
  TYPE typ_tab_hstexc IS TABLE OF NUMBER
    INDEX BY PLS_INTEGER;
  
  vr_tab_lsthis   gene0002.typ_split;
  vr_tab_hstexc   typ_tab_hstexc;
  vr_dslsthis     VARCHAR2(4000);
  
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(2000);
BEGIN
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;
 
  -- Carrega lista dos hist�ricos de d�bito que n�o devem incrementar o preju�zo 
  vr_dslsthis := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                             pr_cdcooper => pr_cdcooper, 
                                             pr_cdacesso => 'HISTOR_PREJ_N_SALDO');
                                             
  vr_tab_lsthis := gene0002.fn_quebra_string(pr_string  => vr_dslsthis, 
                                             pr_delimit => ';');
                                            
  IF vr_tab_lsthis.count > 0 THEN
    FOR i IN vr_tab_lsthis.first..vr_tab_lsthis.last LOOP        
      vr_tab_hstexc(vr_tab_lsthis(i)) := vr_tab_lsthis(i);      
    END LOOP; 
  END IF;
       
  FOR rw_craplcm IN cr_craplcm(pr_cdcooper => pr_cdcooper
                             , pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP    
    -- Se o hist�rico do lan�amento est� na lista de exce��es 
    IF vr_tab_hstexc.exists(rw_craplcm.cdhistor) THEN
      CONTINUE; -- Ignora o lan�amento
    END IF;
                             
    -- Se o d�bito foi estornado no mesmo dia
    IF fn_verifica_estorno_debito(pr_cdcooper => pr_cdcooper
                                , pr_nrdconta => rw_craplcm.nrdconta
                                , pr_cdhistor => rw_craplcm.cdhistor
                                , pr_nrdocmto => rw_craplcm.nrdocmto
                                , pr_vllanmto => rw_craplcm.vllanmto
                                , pr_dtmvtolt => rw_crapdat.dtmvtolt) THEN
      CONTINUE;
    END IF;
    
    -- Realiza incremento do saldo do preju�zo e lan�a hist�rico 2408 para fins de contabiliza��o
    pc_incrementa_saldo_prej(pr_cdcooper => pr_cdcooper 
                           , pr_nrdconta => rw_craplcm.nrdconta
                           , pr_vllanmto => rw_craplcm.vllanmto
                           , pr_dtmvtolt => rw_crapdat.dtmvtolt
                           , pr_cdcritic => vr_cdcritic
                           , pr_dscritic => vr_dscritic);
                           
    IF trim(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
      NULL; -- Gravar log
    END IF;    
  END LOOP;
  
  COMMIT;                
END pc_processa_debt_inc_prj;

END PREJ0006;
/
