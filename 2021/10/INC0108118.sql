DECLARE

  vr_incidente VARCHAR2(15);
  vr_cdcooper  crapcop.cdcooper%TYPE;
  vr_nrdconta  crapass.nrdconta%TYPE;
  vr_vllanmto  tbcc_prejuizo.vlsdprej%TYPE;
  vr_cdhistor  craphis.cdhistor%TYPE;
  vr_idlancto  tbcc_prejuizo_detalhe.idlancto%TYPE;
  vr_found     BOOLEAN;
  vr_indebcre  craphis.indebcre%TYPE;
  

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
  

BEGIN
  

------------ BLOCO PRINCIPAL ---------------------
  dbms_output.put_line('Script iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
---------------------------------------------------
  -- 01 Acredicoop	7/out	666050	 R$ 36,27 	36,27
  vr_incidente := 'INC0108118';
  vr_cdcooper  := 2;
  vr_nrdconta  := 666050;
  vr_vllanmto  := 36.27;
  vr_cdhistor  := 2971; 
  
  --realizar um credito na transitoria (tbcc_prejuizo_lancamento)
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);                       
              
---------------------------------------------------------------------

-- 02 Acredicoop	28/set	517372	 R$ 36,19 	36,19
  vr_incidente := 'INC0108118';
  vr_cdcooper  := 2;
  vr_nrdconta  := 517372;
  vr_vllanmto  := 36.19;
  vr_cdhistor  := 2971; 
  
  --realizar um credito na transitoria (tbcc_prejuizo_lancamento)
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);                       
              
---------------------------------------------------------------------

-- 03 Acredicoop	17/set	791334	 R$ 43,20 	43,2
  vr_incidente := 'INC0108118';
  vr_cdcooper  := 2;
  vr_nrdconta  := 791334;
  vr_vllanmto  := 43.20;
  vr_cdhistor  := 2971; 
  
  --realizar um credito na transitoria (tbcc_prejuizo_lancamento)
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);                       
              
---------------------------------------------------------------------

-- 04 Credcrea	30/set	266248	 R$ 29,16 	29,16
  vr_incidente := 'INC0108118';
  vr_cdcooper  := 7;
  vr_nrdconta  := 266248;
  vr_vllanmto  := 29.16;
  vr_cdhistor  := 2971; 
  
  --realizar um credito na transitoria (tbcc_prejuizo_lancamento)
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);                       
              
---------------------------------------------------------------------

-- 05 Credifoz	28/set	291250	 R$ 12,84 	12,84
  vr_incidente := 'INC0108118';
  vr_cdcooper  := 11;
  vr_nrdconta  := 291250;
  vr_vllanmto  := 12.84;
  vr_cdhistor  := 2971; 
  
  --realizar um credito na transitoria (tbcc_prejuizo_lancamento)
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);                       
              
---------------------------------------------------------------------

-- 06 Credifoz	28/set	597864	 R$ 17,66 	17,66
  vr_incidente := 'INC0108118';
  vr_cdcooper  := 11;
  vr_nrdconta  := 597864;
  vr_vllanmto  := 17.66;
  vr_cdhistor  := 2971; 
  
  --realizar um credito na transitoria (tbcc_prejuizo_lancamento)
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);                       
              
---------------------------------------------------------------------

-- 07 Credifoz	7/out	141151	 R$ 19,84 	19,84
  vr_incidente := 'INC0108118';
  vr_cdcooper  := 11;
  vr_nrdconta  := 141151;
  vr_vllanmto  := 19.84;
  vr_cdhistor  := 2971; 
  
  --realizar um credito na transitoria (tbcc_prejuizo_lancamento)
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);                       
              
---------------------------------------------------------------------

-- 08 Credifoz	22/set	463132	 R$ 13,15 	13,15
  vr_incidente := 'INC0108118';
  vr_cdcooper  := 11;
  vr_nrdconta  := 463132;
  vr_vllanmto  := 13.15;
  vr_cdhistor  := 2971; 
  
  --realizar um credito na transitoria (tbcc_prejuizo_lancamento)
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);                       
              
---------------------------------------------------------------------

-- 09 Credifoz	25/ago	477699	 R$ 14,84 	14,84
  vr_incidente := 'INC0108118';
  vr_cdcooper  := 11;
  vr_nrdconta  := 477699;
  vr_vllanmto  := 14.84;
  vr_cdhistor  := 2971; 
  
  --realizar um credito na transitoria (tbcc_prejuizo_lancamento)
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);                       
              
---------------------------------------------------------------------

  
  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
-----------------------------------------------------------------------

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
