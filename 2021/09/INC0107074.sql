DECLARE

  vr_incidente VARCHAR2(15);
  vr_cdcooper  crapcop.cdcooper%TYPE;
  vr_nrdconta  crapass.nrdconta%TYPE;
  vr_vllanmto  tbcc_prejuizo.vlsdprej%TYPE;
  vr_cdhistor  craphis.cdhistor%TYPE;
  vr_idlancto  tbcc_prejuizo_detalhe.idlancto%TYPE;

  PROCEDURE registrarVERLOG(pr_cdcooper            IN crawepr.cdcooper%TYPE
                           ,pr_nrdconta            IN crawepr.nrdconta%TYPE
                           ,pr_dstransa            IN VARCHAR2      -- Operacao que foi efetuada
                           ,pr_dsCampo             IN VARCHAR       -- ITEM - Campo alterado
                           ,pr_antes               IN VARCHAR2
                           ,pr_depois              IN VARCHAR2) IS

 

    vr_dstransa             craplgm.dstransa%TYPE;
    vr_descitem             craplgi.nmdcampo%TYPE;
    vr_nrdrowid             ROWID;
    vr_risco_anterior       VARCHAR2(10);

 

  BEGIN

    vr_dstransa := pr_dstransa;

    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_dstransa => vr_dstransa
                        ,pr_dscritic => ''
                        ,pr_cdoperad => '1'
                        ,pr_dsorigem => 'SCRIPT'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 0
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => ''
                        ,pr_nrdrowid => vr_nrdrowid);

    IF trim(pr_dsCampo) IS NOT NULL THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => pr_dsCampo
                               ,pr_dsdadant => pr_antes
                               ,pr_dsdadatu => pr_depois);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
  END registrarVERLOG;


  PROCEDURE prc_gera_acerto_transit (prm_cdcooper IN craplcm.cdcooper%TYPE,
                                     prm_nrdconta IN craplcm.nrdconta%TYPE,
                                     prm_vllanmto IN craplcm.vllanmto%TYPE,
                                     prm_idaument IN NUMBER DEFAULT 0) IS
  
    -- Variáveis negócio
    vr_dtmvtolt    craplcm.dtmvtolt%TYPE;
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
    vr_cdhistor    tbcc_prejuizo_detalhe.cdhistor%TYPE;

    -- Variáveis Tratamento Erro
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

  BEGIN

    --Busca Data Atual da Cooperativa
    BEGIN
      SELECT dtmvtolt
      INTO   vr_dtmvtolt
      FROM   crapdat
      WHERE  cdcooper = prm_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar Data da Cooperatriva. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro; 
    END;
    
    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (ATZ TRANSIT):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Data...........: '||To_Char(vr_dtmvtolt,'dd/mm/yyyy'));
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line(' ');


    -- Cria lançamento (Tabela tbcc_prejuizo_lancamento)
    prej0003.pc_gera_cred_cta_prj(pr_cdcooper => prm_cdcooper,
                                  pr_nrdconta => prm_nrdconta,
                                  pr_vlrlanc  => prm_vllanmto,
                                  pr_dtmvtolt => vr_dtmvtolt,
                                  pr_dsoperac => 'Ajuste Contabil - ' || To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'),
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);

    IF Nvl(vr_cdcritic,0) > 0 OR Trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_erro; 
    ELSE
      dbms_output.put_line('   Lançamento Credito Conta Transitoria efetuado com Sucesso na Coop/Conta '||prm_cdcooper||'/'||prm_nrdconta||'.');  
    END IF;

    registrarVERLOG(pr_cdcooper  => prm_cdcooper
                   ,pr_nrdconta  => prm_nrdconta
                   ,pr_dstransa  => 'Ajuste Contabil - ' || To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss')
                   ,pr_dsCampo   => 'pc_gera_cred_cta_prj'
                   ,pr_antes     => 0
                   ,pr_depois    => prm_vllanmto);

  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('prc_gera_acerto_transit: '||vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20001,vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('prc_gera_acerto_transit: Erro: '||SubStr(SQLERRM,1,255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20002,'Erro Geral no prc_gera_acerto_transit. Erro: '||SubStr(SQLERRM,1,255));    
  END prc_gera_acerto_transit;

PROCEDURE prc_gera_crd_cc (prm_cdcooper IN craplcm.cdcooper%TYPE,
                           prm_nrdconta IN craplcm.nrdconta%TYPE,
                           prm_vllanmto IN craplcm.vllanmto%TYPE) IS

    -- Variáveis negócio
    vr_dtmvtolt    craplcm.dtmvtolt%TYPE;


    -- Variáveis Tratamento Erro
    vr_des_erro    VARCHAR2(1000);
    vr_tab_erro    GENE0001.typ_tab_erro;
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);
    
BEGIN
  
    --Busca Data Atual da Cooperativa
    BEGIN
      SELECT dtmvtolt
      INTO   vr_dtmvtolt
      FROM   crapdat
      WHERE  cdcooper = prm_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar Data da Cooperatriva. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro; 
    END;
    
    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (LCM VLR):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Data...........: '||To_Char(vr_dtmvtolt,'dd/mm/yyyy'));
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line(' ');
  
    --gerar lancto na cc
    EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => prm_cdcooper                     --> Cooperativa conectada
                                      ,pr_dtmvtolt => vr_dtmvtolt                  --> Movimento atual
                                      ,pr_cdagenci => 0                            --> Código da agência
                                      ,pr_cdbccxlt => 100                          --> Número do caixa
                                      ,pr_cdoperad => '1'                          --> Código do Operador
                                      ,pr_cdpactra => 0                            --> P.A. da transação
                                      ,pr_nrdolote => 650001                       --> Numero do Lote
                                      ,pr_nrdconta => prm_nrdconta                 --> Número da conta
                                      ,pr_cdhistor => 2182                         --> Codigo historico 2182 - PAGAMENTO DAS DESPESAS ACORDO
                                      ,pr_vllanmto => prm_vllanmto                  --> Valor da parcela emprestimo
                                      ,pr_nrparepr => 0                            --> Número parcelas empréstimo
                                      ,pr_nrctremp => 0                            --> Número do contrato de empréstimo
                                      ,pr_des_reto => vr_des_erro                  --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);                --> Tabela com possíves erros
      -- Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
          END IF;
          RAISE vr_erro;
        END IF;

 
END prc_gera_crd_cc;

PROCEDURE prc_gera_lct (prm_cdcooper IN craplcm.cdcooper%TYPE,
                         prm_nrdconta IN craplcm.nrdconta%TYPE,
                         prm_vllanmto IN craplcm.vllanmto%TYPE,
                         prm_cdhistor IN craplcm.cdhistor%TYPE) IS
  
    -- Variáveis negócio
    vr_dtmvtolt    craplcm.dtmvtolt%TYPE;
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
    vr_cdhistor    tbcc_prejuizo_detalhe.cdhistor%TYPE;

    -- Variáveis Tratamento Erro
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

  BEGIN

    --Busca Data Atual da Cooperativa
    BEGIN
      SELECT dtmvtolt
      INTO   vr_dtmvtolt
      FROM   crapdat
      WHERE  cdcooper = prm_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar Data da Cooperatriva. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro; 
    END;
    
    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (LCM VLR):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Data...........: '||To_Char(vr_dtmvtolt,'dd/mm/yyyy'));
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line(' ');
    
    --Busca Data Atual da Cooperativa
    BEGIN
      SELECT a.idprejuizo
        INTO vr_idprejuizo
        FROM tbcc_prejuizo a
       WHERE a.cdcooper = prm_cdcooper
         AND a.nrdconta = prm_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar chave prejuizo. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro; 
    END;

    -- Cria lançamento (Tabela tbcc_prejuizo_detalhe)
    prej0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => prm_cdcooper
                                     ,pr_nrdconta   => prm_nrdconta
                                     ,pr_dtmvtolt   => vr_dtmvtolt
                                     ,pr_cdhistor   => prm_cdhistor
                                     ,pr_idprejuizo => vr_idprejuizo
                                     ,pr_vllanmto   => prm_vllanmto
                                     ,pr_dthrtran   => SYSDATE
                                     ,pr_cdcritic   => vr_cdcritic
                                     ,pr_dscritic   => vr_dscritic);
    IF Nvl(vr_cdcritic,0) > 0 OR Trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_erro; 
    ELSE
      dbms_output.put_line('   Lançamento do Histórico '||prm_cdhistor||' efetuado com Sucesso na Coop\Conta '||prm_cdcooper||'\'||prm_nrdconta||'.');  
    END IF;

    registrarVERLOG(pr_cdcooper  => prm_cdcooper
                   ,pr_nrdconta  => prm_nrdconta
                   ,pr_dstransa  => 'Ajuste Contabil - ' || To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss')
                   ,pr_dsCampo   => 'pc_gera_lcto_extrato_prj'
                   ,pr_antes     => ''
                   ,pr_depois    => prm_vllanmto);

  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('prc_gera_lct: '||vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20001,vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('prc_gera_lct: Erro: '||SubStr(SQLERRM,1,255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20002,'Erro Geral no prc_gera_lct. Erro: '||SubStr(SQLERRM,1,255));    
  END prc_gera_lct;
  
        

BEGIN
  

------------ BLOCO PRINCIPAL ---------------------
  dbms_output.put_line('Script iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));

-- 2739 - Quando lança, Diminui o Saldo Prejuizo      [D] 2739 - REC. PREJUIZO-> TBCC_PREJUIZO_DETALHE
-- 2738 - Quando lança, Aumenta o Saldo Prejuizo      [C] 2738 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE

---------------------------------------------------
  -- INC0107074 - Viacredi - c/c 882.832-6
  vr_incidente := 'INC0107074';
  vr_cdcooper  := 1;
  vr_nrdconta  := 8828326;
  vr_vllanmto  := 250.48;
  vr_cdhistor  := 2738;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
  --realizar um credito na transitoria (tbcc_prejuizo_lancamento)
  prc_gera_acerto_transit(prm_cdcooper => vr_cdcooper,
                          prm_nrdconta => vr_nrdconta,
                          prm_vllanmto => vr_vllanmto);
              
  --realizar o debito na lislot (tbcc_prejuizo_detalhe)         
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => 2721);

  --realizar lancamentos na conta corrente
  prc_gera_crd_cc(prm_cdcooper => vr_cdcooper,
                  prm_nrdconta => vr_nrdconta,
                  prm_vllanmto => vr_vllanmto);
  
  
  
  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------


  --Salva
  COMMIT;

  dbms_output.put_line(' ');
  dbms_output.put_line('Script finalizado com Sucesso em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
------------ BLOCO PRINCIPAL - FIM ---------------------


EXCEPTION    
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));    
END;
