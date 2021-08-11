DECLARE
  CURSOR cr_his (pr_cdcooper IN crapcop.cdcooper%TYPE
                ,pr_cdhistor IN craphis.cdhistor%TYPE)IS
    SELECT t.cdhistor, t.dshistor, t.indebcre
      FROM craphis t
     WHERE t.cdcooper = pr_cdcooper
       AND t.cdhistor = pr_cdhistor;
  rw_his  cr_his%ROWTYPE;
  
  CURSOR cr_sld_prj (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
    SELECT t.vlsdprej, t.idprejuizo
      FROM tbcc_prejuizo t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta;
  rw_sld_prj  cr_sld_prj%ROWTYPE;

  vr_indebcre  craphis.indebcre%TYPE;
  vr_found     BOOLEAN;

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
    
    --Busca id do saldo da conta em prejuizo
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


  PROCEDURE prc_atlz_prejuizo (prm_cdcooper IN craplcm.cdcooper%TYPE,
                               prm_nrdconta IN craplcm.nrdconta%TYPE,
                               prm_vllanmto IN craplcm.vllanmto%TYPE,
                               prm_cdhistor IN craplcm.cdhistor%TYPE,
                               prm_tipoajus IN VARCHAR2) IS
  
    -- Variáveis negócio
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
    vr_tipoacao    BOOLEAN;
    vr_vlsdprej    tbcc_prejuizo.vlsdprej%TYPE;

    -- Variáveis Tratamento Erro
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

  BEGIN

    OPEN cr_sld_prj (pr_cdcooper => prm_cdcooper
                    ,pr_nrdconta => prm_nrdconta);
    FETCH cr_sld_prj INTO rw_sld_prj;
    vr_found    := cr_sld_prj%FOUND;
    vr_vlsdprej := rw_sld_prj.vlsdprej;
    CLOSE cr_sld_prj;

    IF NOT vr_found THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro ao buscar Saldo Prejuizo Cop/Cta (' ||prm_cdcooper || '/'||prm_nrdconta||')';
      RAISE vr_erro;  
    END IF;
    vr_found := NULL;

    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (prc_atlz_prejuizo):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line('     Historico......: '||prm_cdhistor);
    dbms_output.put_line('     Tipo Ajuste....: '||prm_tipoajus);
    dbms_output.put_line('     Sld Prej. Antes: '||vr_vlsdprej);

    IF prm_tipoajus IS NULL
    OR prm_tipoajus NOT IN ('E','I') THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: Tipo de Ajuste invalido! (' ||prm_tipoajus||')';
      RAISE vr_erro;  
    END IF;

    -- Verificar o historico a ser deletado
    OPEN cr_his (pr_cdcooper => prm_cdcooper
                ,pr_cdhistor => prm_cdhistor);
    FETCH cr_his INTO rw_his;
    vr_found    := cr_his%FOUND;
    vr_indebcre := rw_his.indebcre;
    CLOSE cr_his;

    IF NOT vr_found THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: Historico não encontrato Cop/Hist (' ||prm_cdcooper || '/'||prm_cdhistor||')';
      RAISE vr_erro;  
    END IF;

    IF prm_tipoajus = 'E' THEN --Exclusão
      IF vr_indebcre = 'C' THEN
         -- Exclusão de CREDITO, diminui Saldo Prejuizo
         vr_tipoacao := TRUE;
      ELSE -- D - debito
         -- Exclusão de DEBITO, aumenta Saldo Prejuizo
         vr_tipoacao := FALSE;
      END IF;
    ELSE -- I - Inclusão
      IF vr_indebcre = 'C' THEN
         -- Inclusao de CREDITO, aumenta Saldo Prejuizo
         vr_tipoacao := FALSE;
      ELSE -- D - debito
         -- Inclusao de DEBITO, diminui Saldo Prejuizo
         vr_tipoacao := TRUE;
      END IF;
    END IF;



    IF vr_tipoacao THEN -- TRUE - diminui Saldo Prejuizo
      BEGIN
        UPDATE tbcc_prejuizo  a
           SET a.vlsdprej = Nvl(vlsdprej,0) - Nvl(prm_vllanmto,0)
         WHERE a.cdcooper = prm_cdcooper
           AND a.nrdconta = prm_nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_erro;  
      END; 
    ELSE  -- FALSE - aumenta Saldo Prejuizo
      BEGIN
        UPDATE tbcc_prejuizo  a
           SET a.vlsdprej = Nvl(vlsdprej,0) + Nvl(prm_vllanmto,0)
         WHERE a.cdcooper = prm_cdcooper
           AND a.nrdconta = prm_nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_erro;  
      END; 
    END IF;  
    --
    IF Nvl(SQL%RowCount,0) > 0 THEN 
      dbms_output.put_line('   Atualizado Saldo Devedor Prejuízo: '||Nvl(SQL%RowCount,0)||' registro(s).');
    ELSE
      vr_dscritic := 'Conta não encontrada. Cooperativa: '||prm_cdcooper||' | Conta: '||prm_nrdconta;
      RAISE vr_erro;  
    END IF;

    vr_vlsdprej := 0;
    OPEN cr_sld_prj (pr_cdcooper => prm_cdcooper
                    ,pr_nrdconta => prm_nrdconta);
    FETCH cr_sld_prj INTO rw_sld_prj;
    vr_vlsdprej := rw_sld_prj.vlsdprej;
    CLOSE cr_sld_prj;

    dbms_output.put_line('     Sld Prej.Depois: '||vr_vlsdprej);


    registrarVERLOG(pr_cdcooper  => prm_cdcooper
                   ,pr_nrdconta  => prm_nrdconta
                   ,pr_dstransa  => 'Ajuste Contabil - ' || To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss')
                   ,pr_dsCampo   => 'Saldo Prejuizo'
                   ,pr_antes     => vr_vlsdprej
                   ,pr_depois    => rw_sld_prj.vlsdprej);


  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('prc_atlz_prejuizo: '||vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20001,vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('prc_atlz_prejuizo: Erro: '||SubStr(SQLERRM,1,255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20002,'Erro Geral no prc_atlz_prejuizo. Erro: '||SubStr(SQLERRM,1,255));    
  END prc_atlz_prejuizo;     

BEGIN  
------------ BLOCO PRINCIPAL ---------------------
  dbms_output.put_line('Script iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));

---------------------------------------------------
  --#1 INC0098887  Acentra 5  178527  20/07/2021 2722 = R$ 149,44, 2721 = R$ 124,47 
---------------------------------------------------
  vr_incidente := 'INC0098887';
  vr_cdcooper  := 5;
  vr_nrdconta  := 178527;
  vr_vllanmto  := 149.44;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
   prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao
                   
  vr_cdhistor  := 2721;
  vr_vllanmto  := 124.47; 
    
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('finalizando conta :'||vr_nrdconta||' e cooperativa :'|| vr_cdcooper);
-------------------------------------------------------------

 ---------------------------------------------------
  --#2 INC0098901  AcrediCoop 2  335096  20/07/2021 2722 R$ 196,78  2721 R$ 112,23 
---------------------------------------------------
  vr_incidente := 'INC0098901';
  vr_cdcooper  := 2;
  vr_nrdconta  := 335096;
  vr_vllanmto  := 196.78;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
   prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao
                   
  vr_cdhistor  := 2721;
  vr_vllanmto  := 112.23; 
    
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('finalizando conta :'||vr_nrdconta||' e cooperativa :'|| vr_cdcooper);
------------------------------------------------------------- 

---------------------------------------------------
  --#3 INC0099123 AcrediCoop 2  745090  22/07/2021  2722 R$ 150,00  2721 R$ 133,60
---------------------------------------------------
  vr_incidente := 'INC0099123';
  vr_cdcooper  := 2;
  vr_nrdconta  := 745090;
  vr_vllanmto  := 150;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
   prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao
                   
  vr_cdhistor  := 2721;
  vr_vllanmto  := 133.60; 
    
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('finalizando conta :'||vr_nrdconta||' e cooperativa :'|| vr_cdcooper);

---------------------------------------------------------------------------------
  --#6 INC0099146 Civia 13  190144  16/07/2021  2722 = 90,00, 2721 = R$ 85,75
---------------------------------------------------
  vr_incidente := 'INC0099146';
  vr_cdcooper  := 13;
  vr_nrdconta  := 190144;
  vr_vllanmto  := 90;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
   prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao
                   
  vr_cdhistor  := 2721;
  vr_vllanmto  := 85.75;
    
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('finalizando conta :'||vr_nrdconta||' e cooperativa :'|| vr_cdcooper);
 --------------------------------------------------------------------------------------
----#9 INC0099452  Civia 324426  26/07/2021  2722 = R$ 250,00    R$ 244,71
---------------------------------------------------
  vr_incidente := 'INC0099452';
  vr_cdcooper  := 13;
  vr_nrdconta  := 324426;
  vr_vllanmto  := 250;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
   prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao
                   
  vr_cdhistor  := 2721;
  vr_vllanmto  := 244.71; 
    
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('finalizando conta :'||vr_nrdconta||' e cooperativa :'|| vr_cdcooper);
-------------------------------------------------------------
  ----#10 INC0099540  Civia 287628  15/07/2021  2722 = R$ 166,38   R$ 153,43 
---------------------------------------------------
  vr_incidente := 'INC0099540';
  vr_cdcooper  := 13;
  vr_nrdconta  := 287628;
  vr_vllanmto  := 166.38;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
   prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao
                   
  vr_cdhistor  := 2721;
  vr_vllanmto  := 153.43; 
    
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('finalizando conta :'||vr_nrdconta||' e cooperativa :'|| vr_cdcooper);
-------------------------------------------------------------
 ---#11 INC0099553  Civia 185019  19/07/2021  2722 =  R$ 966,67    R$ 816,11  
---------------------------------------------------
  vr_incidente := 'INC0099553';
  vr_cdcooper  := 13;
  vr_nrdconta  := 185019;
  vr_vllanmto  := 966.67;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
   prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao
                   
  vr_cdhistor  := 2721;
  vr_vllanmto  := 816.11; 
    
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('finalizando conta :'||vr_nrdconta||' e cooperativa :'|| vr_cdcooper);
-------------------------------------------------------------
-----#13 INC0099591  Civia 336718  27/07/2021  2722 =  R$ 182,55   R$ 144,86    
---------------------------------------------------
  vr_incidente := 'INC0099591';
  vr_cdcooper  := 13;
  vr_nrdconta  := 336718;
  vr_vllanmto  := 182.55;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
   prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao
                   
  vr_cdhistor  := 2721;
  vr_vllanmto  := 144.86; 
    
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('finalizando conta :'||vr_nrdconta||' e cooperativa :'|| vr_cdcooper);
-------------------------------------------------------------
----#15 INC0099591  Civia 145726  27/07/2021  2722 =  R$ 225,00    R$ 165,59   
---------------------------------------------------
  vr_incidente := 'INC0099591';
  vr_cdcooper  := 13;
  vr_nrdconta  := 145726;
  vr_vllanmto  := 225.00;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
   prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao
                   
  vr_cdhistor  := 2721;
  vr_vllanmto  := 165.59; 
    
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('finalizando conta :'||vr_nrdconta||' e cooperativa :'|| vr_cdcooper);
-------------------------------------------------------------
----#16 INC0099455  CredCrea  228389  26/7/2021  2722 = R$ 249,75, 2721 = R$ 218,51 
---------------------------------------------------
  vr_incidente := 'INC0099455';
  vr_cdcooper  := 7;
  vr_nrdconta  := 228389;
  vr_vllanmto  := 249.75;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
   prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao
                   
  vr_cdhistor  := 2721;
  vr_vllanmto  := 218.51; 
    
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('finalizando conta :'||vr_nrdconta||' e cooperativa :'|| vr_cdcooper);
  
  
-------------------------------------------------------------
----#17 INC0099458  credicomin  132730  26/7/2021 2722 = R$ 148,08, 2721 = R$ 99,38 
---------------------------------------------------
  vr_incidente := 'INC0099458';
  vr_cdcooper  := 10;
  vr_nrdconta  := 132730;
  vr_vllanmto  := 148.08;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
   prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao
                   
  vr_cdhistor  := 2721;
  vr_vllanmto  := 99.38; 
    
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('finalizando conta :'||vr_nrdconta||' e cooperativa :'|| vr_cdcooper);
-------------------------------------------------------------
  -- #26 INC0098640   -  CrediFoz  - c/c   39305-3  |  16/07/2021   | 2722 =   R$ 1.140,84  | 2721 =   R$ 775,93
---------------------------------------------------
  vr_incidente := 'INC0098640';
  vr_cdcooper  := 11;
  vr_nrdconta  := 393053;
  vr_vllanmto  := 1140.84;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 775.93;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
------------------------------------------------------------------------------
  -- #27 INC0099297   -  CrediFoz  - c/c   44156-2  |  23/07/2021   | 2722 =    R$ 225,00   | 2721 =    R$ 212,67 
---------------------------------------------------
  vr_incidente := 'INC0099297';
  vr_cdcooper  := 11;
  vr_nrdconta  := 441562;
  vr_vllanmto  := 225.00;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 212.67;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
-----------------------------------------------------------------------------
  -- #29  INC0099621   -  CrediFoz  - c/c   47043-0  |  27/07/2021   | 2722 =    R$ 250,00   | 2721 =    R$ 54,67 
---------------------------------------------------
  vr_incidente := 'INC0099621';
  vr_cdcooper  := 11;
  vr_nrdconta  := 470430;
  vr_vllanmto  := 250.00;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 54.67;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
-------------------------------------------------------------------------------
  -- #30 INC0099470   -  Evolua  - c/c   07924-3  |  26/07/2021   | 2722 =    R$ 178,65   | 2721 =    R$ 147,06 
---------------------------------------------------
  vr_incidente := 'INC0099470';
  vr_cdcooper  := 14;
  vr_nrdconta  := 79243;
  vr_vllanmto  := 178.65;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 147.06;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
-------------------------------------------------------------------------
  -- #32 INC0099557   -  Evolua  - c/c   08118-3  |  22/07/2021   | 2722 =    R$ 1.000,00   | 2721 =    R$ 954,29 
---------------------------------------------------
  vr_incidente := 'INC0099557';
  vr_cdcooper  := 14;
  vr_nrdconta  := 81183;
  vr_vllanmto  := 1000.00;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 954.29;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
-----------------------------------------------------------------------
  --#34  INC0098979   -  Transpocred - c/c   21901-0  |  21/07/2021   | 2722 =   R$ 197,34  | 2721 =   R$ 188,58
---------------------------------------------------
  vr_incidente := 'INC0098979';
  vr_cdcooper  := 9;
  vr_nrdconta  := 219010;
  vr_vllanmto  := 197.34;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 188.58;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
-----------------------------------------------------------------------------------
  --#35  INC0098979   -  Transpocred - c/c   22761-7  |  21/07/2021   | 2722 =   R$ 300,00  | 2721 =   R$ 281,92
---------------------------------------------------
  vr_incidente := 'INC0098979';
  vr_cdcooper  := 9;
  vr_nrdconta  := 227617;
  vr_vllanmto  := 300.00;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 281.92;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');

----------------------------------------------------------------------
  -- #37 INC0099633   -  Únilos  - c/c   11741-2  |  27/07/2021   | 2722 =    R$ 299,73   | 2721 =    R$ 282,80 
---------------------------------------------------
  vr_incidente := 'INC0099633';
  vr_cdcooper  := 6;
  vr_nrdconta  := 117412;
  vr_vllanmto  := 299.73;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 282.80;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------------------------------------
  --#39  INC0099291   -  Viacredi Alto Vale  - c/c   13184-9  |  23/07/2021   | 2722 =    R$ 175,00   | 2721 =    R$ 163,69 
---------------------------------------------------
  vr_incidente := 'INC0099291';
  vr_cdcooper  := 16;
  vr_nrdconta  := 131849;
  vr_vllanmto  := 175.00;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 163.69;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
----------------------------------------------------------------------------------------
  -- #43 INC0098887 Viacredi Alto Vale  302295  28/07/2021   2722 = R$ 164,89, 2721 = R$ 160,08 
---------------------------------------------------
  vr_incidente := 'INC0098887';
  vr_cdcooper  := 16;
  vr_nrdconta  := 302295;
  vr_vllanmto  := 164.89;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 160.08;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
-------------------------------------------------------------------------------------
  -- #44 INC0098887 Viacredi Alto Vale  167991  2722 = R$ 413,90, 2721 = R$ 404,80 
---------------------------------------------------
  vr_incidente := 'INC0098887';
  vr_cdcooper  := 16;
  vr_nrdconta  := 167991;
  vr_vllanmto  := 413.90;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 404.80;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
-------------------------------------------------------------------------------------
-- #45 INC0098887 Credifoz  507598  28/07/2021  2722 = R$ 174,90, 2721 = R$ 153,96  
---------------------------------------------------
  vr_incidente := 'INC0098887';
  vr_cdcooper  := 11;
  vr_nrdconta  := 507598;
  vr_vllanmto  := 174.90;
  vr_cdhistor  := 2722;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_vllanmto  := 153.96;
  vr_cdhistor  := 2721; 

    prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao                  

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
-------------------------------------------------------------------------------------


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
