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
--#1 INC0101363	10511725	21/jul	 2722 =	 R$ 104,09 	 2721 = R$ 100,18 
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10511725;
  vr_vllanmto  := 104.09;
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
  vr_vllanmto  := 100.18; 
    
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

--#2 INC0101363	10677615	21/jul	 2722 =	 R$ 140,00 	 2721 = R$ 134,34
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10677615;
  vr_vllanmto  := 140;
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
  vr_vllanmto  := 134.34; 
    
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

--#3 INC0101363	10280740	21/jul	 2722 =	 R$ 250,00 	 2721 = R$ 244,79
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10280740;
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
  vr_vllanmto  := 244.79; 
    
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

--#4 INC0101363	10991395	21/jul	 2722 =	 R$ 100,00 	 2721 = R$ 84,39 
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10991395;
  vr_vllanmto  := 100;
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
  vr_vllanmto  := 84.39; 
    
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

--#5 INC0101363	10418598	22/jul	 2722 =	 R$ 66,67 	 2721 = R$ 64,84 
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10418598;
  vr_vllanmto  := 66.67;
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
  vr_vllanmto  := 64.84; 
    
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

--#6 INC0101363	9990771		22/jul	 2722 =	 R$ 114,27 	 2721 = R$ 112,89 
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 9990771;
  vr_vllanmto  := 114.27;
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
  vr_vllanmto  := 112.89; 
    
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

--#7 INC0101363	2414821		23/jul	 2722 =	 R$ 499,16 	 2721 = R$ 430,32
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 2414821;
  vr_vllanmto  := 499.16;
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
  vr_vllanmto  := 430.32; 
    
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

--#8 INC0101363	10079483	26/jul	 2722 =	 R$ 174,75 	 2721 = R$ 171,06
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10079483;
  vr_vllanmto  := 174.75;
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
  vr_vllanmto  := 171.06; 
    
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

--#9 INC0101363	10332170	26/jul	 2722 =	 R$ 162,41 	 2721 = R$ 156,32
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10332170;
  vr_vllanmto  := 162.41;
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
  vr_vllanmto  := 156.32; 
    
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

--#10 INC0101363	10922040	26/jul	 2722 =	 R$ 99,92 	 2721 = R$ 94,07
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10922040;
  vr_vllanmto  := 99.92;
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
  vr_vllanmto  := 94.07; 
    
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

--#11 INC0101363	8399182		27/jul	 2722 =	 R$ 166,57 	 2721 = R$ 162,08
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 8399182;
  vr_vllanmto  := 166.57;
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
  vr_vllanmto  := 162.08; 
    
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

--#12 INC0101363	9086595		27/jul	 2722 =  R$ 660,00 	 2721 = R$ 631,43
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 9086595;
  vr_vllanmto  := 660;
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
  vr_vllanmto  := 631.43; 
    
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

--#13 INC0101363	10280138	27/jul	 2722 =	 R$ 149,94 	 2721 = R$ 148,46 
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10280138;
  vr_vllanmto  := 149.94;
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
  vr_vllanmto  := 148.46; 
    
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

--#14 INC0101363	10763759	27/jul	 2722 =	 R$ 66,55 	 2721 = R$ 60,43 
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10763759;
  vr_vllanmto  := 66.55;
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
  vr_vllanmto  := 60.43; 
    
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

--#15 INC0101363	11075481	27/jul	 2722 =	 R$ 100,00 	 2721 = R$ 87,06  
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 11075481;
  vr_vllanmto  := 100;
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
  vr_vllanmto  := 87.06; 
    
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

--#16 INC0101363	10450947	15/jul	 2722 =	 R$ 325,00 	 2721 = R$ 314,53 
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10450947;
  vr_vllanmto  := 325;
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
  vr_vllanmto  := 314.53; 
    
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

--#17 INC0101363	9061568		15/jul	 2722 =	 R$ 500,00 	 2721 = R$ 499,34 
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 9061568;
  vr_vllanmto  := 500;
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
  vr_vllanmto  := 499.34; 
    
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

--#18 INC0101363	8631140		15/jul	 2722 =	 R$ 249,15 	 2721 = R$ 181,15 
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 8631140;
  vr_vllanmto  := 249.15;
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
  vr_vllanmto  := 181.15; 
    
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

--#19 INC0101363	10848720	15/jul	 2722 =  R$ 174,98 	 2721 = R$ 173,60 
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10848720;
  vr_vllanmto  := 174.98;
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
  vr_vllanmto  := 173.60; 
    
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

--#20 INC0101363	9990658		15/jul	 2722 =	 R$ 99,97 	 2721 = R$ 98,06
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 9990658;
  vr_vllanmto  := 99.97;
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
  vr_vllanmto  := 98.06; 
    
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

--#21 INC0101363	9347160		15/jul	 2722 =	 R$ 165,46 	 2721 = R$ 47,92
---------------------------------------------------
  vr_incidente := 'INC0101363';
  vr_cdcooper  := 1;
  vr_nrdconta  := 9347160;
  vr_vllanmto  := 165.46;
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
  vr_vllanmto  := 47.92; 
    
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
