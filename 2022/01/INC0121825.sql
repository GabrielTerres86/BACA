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

BEGIN
  

------------ BLOCO PRINCIPAL ---------------------
  dbms_output.put_line('Script iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  
  vr_incidente := 'INC0104199';
  

---------------------------------------------------
  -- Acredicoop 65.228.8 - 2721  12,50 
  vr_cdcooper  := 2;
  vr_nrdconta  := 652288;
  vr_vllanmto  := 12.50;
  vr_cdhistor  := 2721;
  
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
              
  --realizar o debito na lislot (tbcc_prejuizo_detalhe)         
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             

---------------------------------------------------
  -- Acredicoop 19.840.4 2721  7,50 
  vr_cdcooper  := 2;
  vr_nrdconta  := 198404;
  vr_vllanmto  := 7.50;
  vr_cdhistor  := 2721;
  
  dbms_output.put_line('  ');
              
  --realizar o debito na lislot (tbcc_prejuizo_detalhe)         
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             
             
---------------------------------------------------
  -- Alto Vale 53.304.1 2721   5,25 
  vr_cdcooper  := 16;
  vr_nrdconta  := 533041;
  vr_vllanmto  := 5.25;
  vr_cdhistor  := 2721;
  
  dbms_output.put_line('  ');
              
  --realizar o debito na lislot (tbcc_prejuizo_detalhe)         
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             
             
---------------------------------------------------
  -- Civia 22.589.4 2721   11,20 
  vr_cdcooper  := 13;
  vr_nrdconta  := 225894;
  vr_vllanmto  := 11.20;
  vr_cdhistor  := 2721;
  
  dbms_output.put_line('  ');
              
  --realizar o debito na lislot (tbcc_prejuizo_detalhe)         
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             
             
---------------------------------------------------
  -- Civia 15.834-8 2721   12,49 
  vr_cdcooper  := 13;
  vr_nrdconta  := 158348;
  vr_vllanmto  := 12.49;
  vr_cdhistor  := 2721;
  
  dbms_output.put_line('  ');
              
  --realizar o debito na lislot (tbcc_prejuizo_detalhe)         
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             

---------------------------------------------------
  -- Civia 12.449-4 2721   9,63
  vr_cdcooper  := 13;
  vr_nrdconta  := 124494;
  vr_vllanmto  := 9.63;
  vr_cdhistor  := 2721;
  
  dbms_output.put_line('  ');
              
  --realizar o debito na lislot (tbcc_prejuizo_detalhe)         
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             
---------------------------------------------------
  -- Civia 11.753.6 2721   15,52 
  vr_cdcooper  := 13;
  vr_nrdconta  := 117536;
  vr_vllanmto  := 15.52;
  vr_cdhistor  := 2721;
  
  dbms_output.put_line('  ');
              
  --realizar o debito na lislot (tbcc_prejuizo_detalhe)         
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             
             
---------------------------------------------------
  -- Civia 44.095.7  58,94
  vr_cdcooper  := 13;
  vr_nrdconta  := 440957;
  vr_vllanmto  := 58.94;
  
  dbms_output.put_line('  ');
              
  --realizar o credito na transitoria c/ o histórico 2738 (tbcc_prejuizo_lancamento) 
  prc_gera_acerto_transit(prm_cdcooper => vr_cdcooper,
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
