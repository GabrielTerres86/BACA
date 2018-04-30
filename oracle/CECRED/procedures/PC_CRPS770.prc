CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS770(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                             ,pr_cdagenci IN NUMBER
                                             ,pr_nmdatela  in varchar2              --> Nome da tela
                                             ,pr_infimsol OUT PLS_INTEGER
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT VARCHAR2) IS              --> Descricao da Critica
/* ..........................................................................

   Programa: pc_crps211 (antigo Fontes/crps211.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rafael - Mout's
   Data    : Fevereiro / 2018                     Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Chamado via JOB .
   Objetivo  : Atende a solicitacao M324.
               Rotina para realizar o pagamento de preju�zo automaticamente

   Alteracoes: 
............................................................................. */                                       


                                           
  -- Contratos sem garantia
  CURSOR c01 IS
    SELECT decode(epr.tpemprst,1,'PP','TR') idtpprd
          --, dtultpag
          ,epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.vlsdprej vlsdvpar
          ,epr.inliquid
          ,epr.rowid
      FROM crapepr epr,
           crapprp prp
     WHERE 
           epr.cdcooper = pr_cdcooper
       AND epr.cdcooper = prp.cdcooper
       AND epr.nrdconta = prp.nrdconta
       AND epr.nrctremp = prp.nrctrato
       AND epr.inprejuz = 1  --> Somente as em preju�zo
       AND epr.dtprejuz IS NOT NULL
       AND prp.nrgarope = 10 -- Sem Garantia
       AND epr.vlsdprej > 0
       --AND epr.cdcooper = 8           
       --AND epr.nrdconta = 25461         --> Coop conectada           
       --AND epr.nrctremp = 200467
       ;
  -- Ordem de maior Valor
  CURSOR C02 IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.vlsdprej
          ,ROW_NUMBER () OVER (PARTITION BY epr.nrdconta
                                   ORDER BY epr.vlsdprej DESC) sequencia              
      FROM crapepr epr,
           crapprp prp
     WHERE 
           epr.cdcooper = pr_cdcooper
       AND epr.cdcooper = prp.cdcooper
       AND epr.nrdconta = prp.nrdconta
       AND epr.nrctremp = prp.nrctrato
       AND epr.inprejuz = 1  --> Somente as em preju�zo
       AND epr.dtprejuz IS NOT NULL
       AND prp.nrgarope <> 10 -- Sem Garantia
       AND epr.vlsdprej > 0
       ORDER BY epr.nrdconta, sequencia
       ;        
  --
  CURSOR c_crapcyc(pr_cdcooper IN NUMBER
                  ,pr_nrdconta IN NUMBER
                  ,pr_nrctremp IN NUMBER) IS          
    SELECT 1
      FROM crapcyc 
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND flgehvip = 1
       AND cdmotcin IN (1,2,7)
       AND cdorigem = 3; 
  --
  vr_cdcritic    NUMBER;
  vr_dscritic    VARCHAR2(1000);
  vr_tab_erro    gene0001.typ_tab_erro;
  vr_nrdrowid    ROWID;
  vr_cdprogra    VARCHAR2(40) := 'PC_CRPS770';
  vr_nomdojob    VARCHAR2(40) := 'JBP_PAG_PREJUIZO'; 
  vr_flgerlog    BOOLEAN := FALSE;
  vr_exc_erro    EXCEPTION;
  vr_flgativo  INTEGER;  
  --
  TYPE typ_reg_crapsld IS
  RECORD(vlsdblfp crapsld.vlsdblfp%TYPE
        ,vlsdbloq crapsld.vlsdbloq%TYPE
        ,vlsdblpr crapsld.vlsdblpr%TYPE
        ,vlsddisp crapsld.vlsddisp%TYPE
        ,vlsdchsl crapsld.vlsdchsl%TYPE
        ,vlipmfap crapsld .vlipmfap%TYPE
        ,vlipmfpg crapsld.vlipmfpg%TYPE);
  TYPE typ_tab_crapsld IS
  TABLE OF typ_reg_crapsld
  INDEX BY PLS_INTEGER; --> N�mero da conta  
  vr_tab_crapsld typ_tab_crapsld;
  --
  vr_tab_sald    extr0001.typ_tab_saldos;
  vr_des_reto    VARCHAR2(3);
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  --
  vr_dsvlrgar  VARCHAR2(32000) := '';
  vr_tipsplit  gene0002.typ_split;   
  vr_dsctajud    crapprm.dsvlrprm%TYPE;         --> Parametro de contas que nao podem debitar os emprestimos
  vr_dsctactrjud crapprm.dsvlrprm%TYPE := null; --> Parametro de contas e contratos espec�ficos que nao podem debitar os emprestimos SD#618307  
  
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    --> Controlar gera��o de log de execu��o dos jobs 
    BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  END pc_controla_log_batch; 
 
BEGIN
  vr_dsvlrgar := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdcooper => 0,pr_cdacesso => 'BLOQ_AUTO_PREJ');
  vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsvlrgar, pr_delimit => ';');
  
  FOR i IN vr_tipsplit.first..vr_tipsplit.last LOOP
    IF pr_cdcooper = vr_tipsplit(i) THEN
      RETURN;
    END IF;
  END LOOP;

  pc_controla_log_batch(pr_dstiplog => 'I',
                            pr_dscritic => vr_dscritic); 
  --
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat  INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  -- Primeiro com os sem garantias
  FOR r01 IN c01 LOOP
    vr_flgativo := 0;
    -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
    vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');
     -- Lista de contas e contratos espec�ficos que nao podem debitar os emprestimos (formato="(cta,ctr)") SD#618307
    vr_dsctactrjud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_cdacesso => 'CTA_CTR_ACAO_JUDICIAL');  

    -- Condicao para verificar se permite incluir as linhas parametrizadas
    IF INSTR(',' || vr_dsctajud || ',',',' || r01.nrdconta || ',') > 0 THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => r01.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => '(1) Atencao - Pagamento nao permitido. Verifique situacao da conta'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS770'
                          ,pr_nrdconta => r01.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      CONTINUE; -- Proximo registro do Loop  
    END IF;

    -- Condicao para verificar se permite incluir as linhas parametrizadas SD#618307
    IF INSTR(replace(vr_dsctactrjud,' '),'('||trim(to_char(r01.nrdconta))||','||trim(to_char(r01.nrctremp))||')') > 0 THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => r01.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => '(2) Atencao - Pagamento nao permitido. Verifique situacao da conta'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS770'
                          ,pr_nrdconta => r01.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      CONTINUE; -- Proximo registro do Loop
    END IF;    
  
    OPEN c_crapcyc(r01.cdcooper, 
                   r01.nrdconta, 
                   r01.nrctremp);
    FETCH c_crapcyc INTO vr_flgativo;
    CLOSE c_crapcyc;
          
    IF nvl(vr_flgativo,0) = 1 THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => r01.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => '(3) Pagamento nao permitido, conta possui motivo 1,2,7 e VIP'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS770'
                          ,pr_nrdconta => r01.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      CONTINUE; -- Proximo registro do Loop
    END IF;
    --  
    -- Acordo com modulo.
    RECP0001.pc_verifica_acordo_ativo (pr_cdcooper => r01.cdcooper
                                      ,pr_nrdconta => r01.nrdconta
                                      ,pr_nrctremp => r01.nrctremp
                                      ,pr_cdorigem => 3
                                      ,pr_flgativo => vr_flgativo
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
    IF vr_cdcritic > 0
      OR vr_dscritic IS NOT NULL THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => r01.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => 'Erro ao buscar se existe acordo com modulo - RECP0001'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS770'
                          ,pr_nrdconta => r01.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      CONTINUE; -- Proximo registro do Loop
    END IF;

    IF NVL(vr_flgativo,0) = 1 THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => r01.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => 'Pagamento nao permitido, emprestimo em acordo - Modulo'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS770'
                          ,pr_nrdconta => r01.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      CONTINUE; -- Proximo registro do Loop                    
    END IF;
    --    
    EXTR0001.PC_OBTEM_SALDO_DIA(pr_cdcooper   => r01.cdcooper,
                                pr_rw_crapdat => rw_crapdat,
                                pr_cdagenci => 0,
                                pr_nrdcaixa => 0,
                                pr_cdoperad => '1',
                                pr_nrdconta => r01.nrdconta,
                                pr_vllimcre => 0,
                                pr_dtrefere => rw_crapdat.dtmvtolt,
                                pr_flgcrass => FALSE, --pr_flgcrass,
                                pr_tipo_busca => 'A',
                                pr_des_reto => vr_des_reto,
                                pr_tab_sald => vr_tab_sald,
                                pr_tab_erro => vr_tab_erro);
          
    IF vr_des_reto <> 'OK' THEN
      IF vr_tab_erro.count() > 0 THEN -- RMM
        -- Atribui cr�ticas �s variaveis
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := 'Falha ao buscar saldo atual '||vr_tab_erro(vr_tab_erro.first).dscritic;
        RAISE vr_exc_erro;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Falha ao buscar saldo atual - '||sqlerrm;
        raise vr_exc_erro;
      END IF;          
    END IF;
                 
    IF vr_tab_sald.EXISTS(vr_tab_sald.first) THEN
      vr_tab_crapsld(r01.nrdconta).vlsddisp := vr_tab_sald(vr_tab_sald.first).vlsddisp;
    END IF;
    -- Chamar somente para casos que tenham saldo
    IF NVL(vr_tab_crapsld(r01.nrdconta).vlsddisp,0) > 0 THEN
      vr_dscritic := NULL;
      pc_crps780_1(pr_cdcooper => r01.cdcooper,
                   pr_nrdconta => r01.nrdconta,
                   pr_nrctremp => r01.nrctremp,
                   pr_vlpagmto => 0, -- parametro 0 para considerar o saldo da conta
                   pr_vldabono => 0, -- Na automatica n�o dever� ter abono
                   pr_cdagenci => 1,
                   pr_cdoperad => '1',
                   pr_cdcritic => vr_cdcritic,
                   pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => r01.cdcooper
                            ,pr_cdoperad => '1'
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => 'AYLLOS'
                            ,pr_dstransa => 'Falha ao pagar Prejuizo Automatico Contrato sem Garantia'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'CRPS770'
                            ,pr_nrdconta => r01.nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        COMMIT;
        --RAISE vr_exc_erro;
      END IF;
    END IF;
  END LOOP;
  --
  /* ------------------------------------------------------------------------------------------ */
  -- Com Garantia
  FOR r02 IN c02 LOOP
    vr_flgativo := 0;
    -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
    vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');
     -- Lista de contas e contratos espec�ficos que nao podem debitar os emprestimos (formato="(cta,ctr)") SD#618307
    vr_dsctactrjud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_cdacesso => 'CTA_CTR_ACAO_JUDICIAL');  

    -- Condicao para verificar se permite incluir as linhas parametrizadas
    IF INSTR(',' || vr_dsctajud || ',',',' || r02.nrdconta || ',') > 0 THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => r02.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => '(3) Atencao - Pagamento nao permitido. Verifique situacao da conta'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS770'
                          ,pr_nrdconta => r02.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      CONTINUE; -- Proximo registro do Loop  
    END IF;

    -- Condicao para verificar se permite incluir as linhas parametrizadas SD#618307
    IF INSTR(replace(vr_dsctactrjud,' '),'('||trim(to_char(r02.nrdconta))||','||trim(to_char(r02.nrctremp))||')') > 0 THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => r02.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => '(4) Atencao - Pagamento nao permitido. Verifique situacao da conta'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS770'
                          ,pr_nrdconta => r02.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      CONTINUE; -- Proximo registro do Loop
    END IF;    
  
    OPEN c_crapcyc(r02.cdcooper, 
                   r02.nrdconta, 
                   r02.nrctremp);
    FETCH c_crapcyc INTO vr_flgativo;
    CLOSE c_crapcyc;
          
    IF nvl(vr_flgativo,0) = 1 THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => r02.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => '(5) Pagamento nao permitido, conta possui motivo 1,2,7 e VIP'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS770'
                          ,pr_nrdconta => r02.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      CONTINUE; -- Proximo registro do Loop
    END IF; 
    --
    -- Acordo com modulo.
    RECP0001.pc_verifica_acordo_ativo (pr_cdcooper => r02.cdcooper
                                      ,pr_nrdconta => r02.nrdconta
                                      ,pr_nrctremp => r02.nrctremp
                                      ,pr_cdorigem => 3
                                      ,pr_flgativo => vr_flgativo
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
    IF vr_cdcritic > 0
      OR vr_dscritic IS NOT NULL THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => r02.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => 'Erro ao buscar se existe acordo com modulo - RECP0001'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS770'
                          ,pr_nrdconta => r02.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      CONTINUE; -- Proximo registro do Loop
    END IF;

    IF NVL(vr_flgativo,0) = 1 THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => r02.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => '(2) Pagamento nao permitido, emprestimo em acordo - Modulo'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS770'
                          ,pr_nrdconta => r02.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      CONTINUE; -- Proximo registro do Loop                    
    END IF;       
    -- Buscar o saldo atual da conta
    EXTR0001.PC_OBTEM_SALDO_DIA(pr_cdcooper   => r02.cdcooper,
                                pr_rw_crapdat => rw_crapdat,
                                pr_cdagenci => 0,
                                pr_nrdcaixa => 0,
                                pr_cdoperad => '1',
                                pr_nrdconta => r02.nrdconta,
                                pr_vllimcre => 0,
                                pr_dtrefere => rw_crapdat.dtmvtolt,
                                pr_flgcrass => FALSE, --pr_flgcrass,
                                pr_tipo_busca => 'A',
                                pr_des_reto => vr_des_reto,
                                pr_tab_sald => vr_tab_sald,
                                pr_tab_erro => vr_tab_erro);
          
    IF vr_des_reto <> 'OK' THEN
      IF vr_tab_erro.count() > 0 THEN -- RMM
        -- Atribui cr�ticas �s variaveis
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := 'Falha ao buscar saldo atual '||vr_tab_erro(vr_tab_erro.first).dscritic;
        RAISE vr_exc_erro;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Falha ao buscar saldo atual - '||sqlerrm;
        raise vr_exc_erro;
      END IF;          
    END IF;
                 
    IF vr_tab_sald.EXISTS(vr_tab_sald.first) THEN
      vr_tab_crapsld(r02.nrdconta).vlsddisp := vr_tab_sald(vr_tab_sald.first).vlsddisp;
    END IF;
    -- Chamar somente para casos que tenham saldo
    IF NVL(vr_tab_crapsld(r02.nrdconta).vlsddisp,0) > 0 THEN    
      vr_dscritic := NULL;
      -- Rotina que realiza o pagamento de prejuizo
      pc_crps780_1(pr_cdcooper => r02.cdcooper,
                   pr_nrdconta => r02.nrdconta,
                   pr_nrctremp => r02.nrctremp,
                   pr_vlpagmto => 0, -- parametro 0 para considerar o saldo da conta
                   pr_vldabono => 0, -- Na automatica n�o dever� ter abono
                   pr_cdagenci => 1,
                   pr_cdoperad => '1',
                   pr_cdcritic => vr_cdcritic,
                   pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        gene0001.pc_gera_log(pr_cdcooper => r02.cdcooper
                            ,pr_cdoperad => '1'
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => 'AYLLOS'
                            ,pr_dstransa => 'Falha ao pagar Prejuizo Automatico Contrato com Garantia'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'CRPS770'
                            ,pr_nrdconta => r02.nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        COMMIT;
        --RAISE vr_exc_erro;
      END IF;
    END IF;
  END LOOP;  
  -- Caso n�o ter erros, confirmar pagamentos
  COMMIT;
  pc_controla_log_batch(pr_dstiplog => 'F',
                        pr_dscritic => vr_dscritic);  
EXCEPTION
  WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'pc_crps770: '||vr_dscritic;
  WHEN OTHERS THEN
      ROLLBACK;
      -- Erro
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro na rotina PC_CRPS770. '||SQLERRM;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper, 
                                   pr_compleme => vr_dscritic);      

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 100
                           ,pr_nrsequen => 1 /** Sequencia **/
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);
                           
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Log de erro de execucao
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => vr_dscritic);                           

  
END;
/
