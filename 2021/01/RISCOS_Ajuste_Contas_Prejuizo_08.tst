PL/SQL Developer Test script 3.0
883
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


  PROCEDURE prc_gera_acerto_transit (prm_cdcooper IN craplcm.cdcooper%TYPE,
                                     prm_nrdconta IN craplcm.nrdconta%TYPE,
                                     prm_vllanmto IN craplcm.vllanmto%TYPE) IS
  
    -- Vari�veis neg�cio
    vr_dtmvtolt    craplcm.dtmvtolt%TYPE;
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
    vr_cdhistor    tbcc_prejuizo_detalhe.cdhistor%TYPE;

    -- Vari�veis Tratamento Erro
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
    dbms_output.put_line('   Par�metros (ATZ TRANSIT):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Data...........: '||To_Char(vr_dtmvtolt,'dd/mm/yyyy'));
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line(' ');


    -- Cria lan�amento (Tabela tbcc_prejuizo_lancamento)
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
      dbms_output.put_line('   Lan�amento Credito Conta Transitoria efetuado com Sucesso na Coop/Conta '||prm_cdcooper||'/'||prm_nrdconta||'.');  
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


  PROCEDURE prc_gera_acerto (prm_cdcooper IN craplcm.cdcooper%TYPE,
                             prm_nrdconta IN craplcm.nrdconta%TYPE,
                             prm_vllanmto IN craplcm.vllanmto%TYPE,
                             prm_cdhistor IN craplcm.cdhistor%TYPE,
                             prm_idaument IN NUMBER DEFAULT 0) IS
  
    -- Vari�veis neg�cio
    vr_dtmvtolt    craplcm.dtmvtolt%TYPE;
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
    vr_cdhistor    tbcc_prejuizo_detalhe.cdhistor%TYPE;

    -- Vari�veis Tratamento Erro
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

  BEGIN

    --Busca Data Atual da Cooperativa
    BEGIN
      SELECT dtmvtolt
        INTO vr_dtmvtolt
        FROM crapdat
       WHERE cdcooper = prm_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar Data da Cooperatriva. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro; 
    END;

    OPEN cr_sld_prj (pr_cdcooper => prm_cdcooper
                    ,pr_nrdconta => prm_nrdconta);
    FETCH cr_sld_prj INTO rw_sld_prj;
    vr_found      := cr_sld_prj%FOUND;
    vr_idprejuizo := rw_sld_prj.idprejuizo;
    CLOSE cr_sld_prj;

    IF NOT vr_found THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro ao buscar Saldo Prejuizo Cop/Cta (' ||prm_cdcooper || '/'||prm_nrdconta||')';
      RAISE vr_erro;  
    END IF;
    vr_found := NULL;


    dbms_output.put_line('   Par�metros (prc_gera_acerto):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Data...........: '||To_Char(vr_dtmvtolt,'dd/mm/yyyy'));
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);


    -- Cria lan�amento (Tabela tbcc_prejuizo_detalhe)
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
      dbms_output.put_line('   Lan�amento do Hist�rico '||prm_cdhistor||' efetuado com Sucesso na Coop\Conta '||prm_cdcooper||'\'||prm_nrdconta||'.');  
    END IF;

    registrarVERLOG(pr_cdcooper  => prm_cdcooper
                   ,pr_nrdconta  => prm_nrdconta
                   ,pr_dstransa  => 'Ajuste Contabil - ' || To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss')
                   ,pr_dsCampo   => 'pc_gera_lcto_extrato_prj'
                   ,pr_antes     => ''
                   ,pr_depois    => prm_vllanmto);


  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('prc_gera_acerto: '||vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20001,vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('prc_gera_acerto: Erro: '||SubStr(SQLERRM,1,255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20002,'Erro Geral no prc_gera_acerto. Erro: '||SubStr(SQLERRM,1,255));    
  END prc_gera_acerto;
  
 PROCEDURE prc_gera_lct (prm_cdcooper IN craplcm.cdcooper%TYPE,
                         prm_nrdconta IN craplcm.nrdconta%TYPE,
                         prm_vllanmto IN craplcm.vllanmto%TYPE,
                         prm_cdhistor IN craplcm.cdhistor%TYPE) IS
  
    -- Vari�veis neg�cio
    vr_dtmvtolt    craplcm.dtmvtolt%TYPE;
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
    vr_cdhistor    tbcc_prejuizo_detalhe.cdhistor%TYPE;

    -- Vari�veis Tratamento Erro
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
    dbms_output.put_line('   Par�metros (LCM VLR):');
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

    -- Cria lan�amento (Tabela tbcc_prejuizo_detalhe)
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
      dbms_output.put_line('   Lan�amento do Hist�rico '||prm_cdhistor||' efetuado com Sucesso na Coop\Conta '||prm_cdcooper||'\'||prm_nrdconta||'.');  
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
  
    -- Vari�veis neg�cio
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
    vr_tipoacao    BOOLEAN;
    vr_vlsdprej    tbcc_prejuizo.vlsdprej%TYPE;

    -- Vari�veis Tratamento Erro
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
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro ao buscar Saldo Prejuizo Cop/Cta (' ||prm_cdcooper || '/'||prm_nrdconta||')';
      RAISE vr_erro;  
    END IF;
    vr_found := NULL;

-- 2721 - Quando lan�a, Diminui o Saldo Prejuizo      [D] 2721 - REC. PREJUIZO-> TBCC_PREJUIZO_DETALHE
-- 2408 - Quando lan�a, Aumenta o Saldo Prejuizo      [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
-- 2721 - Quando EXCLUI, Aumenta o Saldo Prejuizo     [D] 2721 - REC. PREJUIZO-> TBCC_PREJUIZO_DETALHE
-- 2408 - Quando EXCLUI, Diminui o Saldo Prejuizo     [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE


    dbms_output.put_line(' ');
    dbms_output.put_line('   Par�metros (prc_atlz_prejuizo):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line('     Historico......: '||prm_cdhistor);
    dbms_output.put_line('     Tipo Ajuste....: '||prm_tipoajus);
    dbms_output.put_line('     Sld Prej. Antes: '||vr_vlsdprej);

    IF prm_tipoajus IS NULL
    OR prm_tipoajus NOT IN ('E','I') THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: Tipo de Ajuste invalido! (' ||prm_tipoajus||')';
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
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: Historico n�o encontrato Cop/Hist (' ||prm_cdcooper || '/'||prm_cdhistor||')';
      RAISE vr_erro;  
    END IF;

    IF prm_tipoajus = 'E' THEN --Exclus�o
      IF vr_indebcre = 'C' THEN
         -- Exclus�o de CREDITO, diminui Saldo Prejuizo
         vr_tipoacao := TRUE;
      ELSE -- D - debito
         -- Exclus�o de DEBITO, aumenta Saldo Prejuizo
         vr_tipoacao := FALSE;
      END IF;
    ELSE -- I - Inclus�o
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
          vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: '||SubStr(SQLERRM,1,255);
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
          vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_erro;  
      END; 
    END IF;  
    --
    IF Nvl(SQL%RowCount,0) > 0 THEN 
      dbms_output.put_line('   Atualizado Saldo Devedor Preju�zo: '||Nvl(SQL%RowCount,0)||' registro(s).');
    ELSE
      vr_dscritic := 'Conta n�o encontrada. Cooperativa: '||prm_cdcooper||' | Conta: '||prm_nrdconta;
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

  PROCEDURE prc_exclui_lct (prm_cdcooper IN craplcm.cdcooper%TYPE,
                            prm_nrdconta IN craplcm.nrdconta%TYPE,
                            prm_vllanmto IN craplcm.vllanmto%TYPE,
                            prm_cdhistor IN craplcm.cdhistor%TYPE,
                            prm_idlancto IN tbcc_prejuizo_detalhe.idlancto%TYPE) IS
  
    -- Vari�veis Tratamento Erro
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

  BEGIN

    dbms_output.put_line(' ');
    dbms_output.put_line('   Par�metros (Dele��o):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line('     Historico......: '||prm_cdhistor);
    dbms_output.put_line('     IDLANCTO.......: '||nvl(prm_idlancto,0));
    dbms_output.put_line(' ');


    IF (prm_cdcooper = 11 AND prm_nrdconta = 20036)
    OR (prm_cdcooper = 9  AND prm_nrdconta = 154580) THEN
    -- Se for essa conta acima, ajusta o Saldo Devedor Prejuizo
      -- Verificar o historico a ser deletado
      OPEN cr_his (pr_cdcooper => prm_cdcooper
                  ,pr_cdhistor => prm_cdhistor);
      FETCH cr_his INTO rw_his;
      vr_found    := cr_his%FOUND;
      vr_indebcre := rw_his.indebcre;
      CLOSE cr_his;

      IF NOT vr_found THEN
        vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: Historico n�o encontrato Cop/Hist (' ||prm_cdcooper || '/'||prm_cdhistor||')';
        RAISE vr_erro;  
      END IF;


      IF vr_indebcre = 'C' THEN
        -- Se for exclus�o de um CREDITO, deve DIMINUIR ao saldo prej
        BEGIN
          UPDATE tbcc_prejuizo  a
             SET a.vlsdprej = Nvl(vlsdprej,0) - Nvl(prm_vllanmto,0)
           WHERE a.cdcooper = prm_cdcooper
             AND a.nrdconta = prm_nrdconta;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: '||SubStr(SQLERRM,1,255);
            RAISE vr_erro;  
        END; 
      ELSE
      -- Se for exclus�o de um DEBITO, deve SOMAR ao saldo prej
        BEGIN
          UPDATE tbcc_prejuizo  a
             SET a.vlsdprej = Nvl(vlsdprej,0) + Nvl(prm_vllanmto,0)
           WHERE a.cdcooper = prm_cdcooper
             AND a.nrdconta = prm_nrdconta;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: '||SubStr(SQLERRM,1,255);
            RAISE vr_erro;  
        END; 
      END IF;  
      --
      IF Nvl(SQL%RowCount,0) > 0 THEN 
        dbms_output.put_line('   Atualizado Saldo Devedor Preju�zo: '||Nvl(SQL%RowCount,0)||' registro(s).');
      ELSE
        vr_dscritic := 'Conta n�o encontrada. Cooperativa: '||prm_cdcooper||' | Conta: '||prm_nrdconta;
        RAISE vr_erro;  
      END IF;
    END IF;


    BEGIN
      DELETE FROM tbcc_prejuizo_detalhe a
       WHERE a.cdcooper = prm_cdcooper
         AND a.nrdconta = prm_nrdconta
         AND a.cdhistor = prm_cdhistor
         AND a.vllanmto = prm_vllanmto
         AND (a.idlancto = prm_idlancto OR prm_idlancto IS NULL);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao DELETAR v. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro;  
    END; 
    --
    IF Nvl(SQL%RowCount,0) > 0 THEN 
      dbms_output.put_line('   Registro(s) removido(s): '||Nvl(SQL%RowCount,0)||' registro(s).');
    ELSE
      vr_dscritic := 'Registro n�o encontrado. Cooperativa(3): '||prm_cdcooper||' | Conta: '||prm_nrdconta;
      RAISE vr_erro;  
    END IF;   

  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('prc_exclui_lct: '||vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20001,vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('prc_exclui_lct: Erro: '||SubStr(SQLERRM,1,255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20002,'Erro Geral no prc_exclui_lct. Erro: '||SubStr(SQLERRM,1,255));    
  END prc_exclui_lct;  




BEGIN
  

------------ BLOCO PRINCIPAL ---------------------
  dbms_output.put_line('Script iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));

-- 2721 - Quando lan�a, Diminui o Saldo Prejuizo      [D] 2721 - REC. PREJUIZO-> TBCC_PREJUIZO_DETALHE
-- 2408 - Quando lan�a, Aumenta o Saldo Prejuizo      [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
-- 2721 - Quando EXCLUI, Aumenta o Saldo Prejuizo      [D] 2721 - REC. PREJUIZO-> TBCC_PREJUIZO_DETALHE
-- 2408 - Quando EXCLUI, Diminui o Saldo Prejuizo      [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE


-- ## 01
---------------------------------------------------
  -- INC0066847 - Evolua - C/C 8.101-9 - R$ 6,90
---------------------------------------------------
  vr_incidente := 'INC0066847';
  vr_cdcooper  := 14;
  vr_nrdconta  := 81019;
  vr_vllanmto  := 6.90;
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

  dbms_output.put_line('  ');
---------------------------------------------------


-- ## 02
---------------------------------------------------
  -- INC0068522 - VIACREDI - Conta: 10553649
---------------------------------------------------
  vr_incidente := 'INC0068522';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10553649;
  vr_vllanmto  := 9.61;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_acerto(prm_cdcooper => vr_cdcooper
                 ,prm_nrdconta => vr_nrdconta
                 ,prm_vllanmto => vr_vllanmto
                 ,prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'E'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------



-- ## 03
---------------------------------------------------
  -- INC0068967 - ALTOVALE : 16 - Conta: 412384 
  -- => Solu��o: Efetuar a exclus�o do 2408 no valor de R$ 2.145,00.
---------------------------------------------------
  vr_incidente := 'INC0068967';
  vr_cdcooper  := 16;
  vr_nrdconta  := 412384;
  vr_vllanmto  := 2145;
  vr_cdhistor  := 2408;
  vr_idlancto  := 144941;  -- PROD tbcc_prejuizo_detalhe.idlancto

  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_exclui_lct (prm_cdcooper => vr_cdcooper,
                  prm_nrdconta => vr_nrdconta,
                  prm_vllanmto => vr_vllanmto,
                  prm_cdhistor => vr_cdhistor,
                  prm_idlancto => vr_idlancto);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'E'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------


-- ## 04
---------------------------------------------------
  -- INC0069317 - TRANSPOCRED : 9 - Conta: 216569 
  -- => Solu��o: Efetuar a exclus�o do 2408 no valor de R$ 22.000,00.
---------------------------------------------------
  vr_incidente := 'INC0069317';
  vr_cdcooper  := 9;
  vr_nrdconta  := 216569;
  vr_vllanmto  := 22000;
  vr_cdhistor  := 2408;
  vr_idlancto  := 146444;  -- PROD tbcc_prejuizo_detalhe.idlancto

  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_exclui_lct (prm_cdcooper => vr_cdcooper,
                  prm_nrdconta => vr_nrdconta,
                  prm_vllanmto => vr_vllanmto,
                  prm_cdhistor => vr_cdhistor,
                  prm_idlancto => vr_idlancto);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'E'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------


-- ## 05
---------------------------------------------------
  -- INC0070443 - VIACREDI : 1 - Conta: 6413226 
  -- => Solu��o: Efetuar lan�amento cr�dito na transitoria, valor R$ 137.91
---------------------------------------------------
  vr_incidente := 'INC0070443';
  vr_cdcooper  := 1;
  vr_nrdconta  := 6413226;
  vr_vllanmto  := 137.91;

  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  prc_gera_acerto_transit (prm_cdcooper => vr_cdcooper
                          ,prm_nrdconta => vr_nrdconta
                          ,prm_vllanmto => vr_vllanmto
                           );
  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');


-- ## 06
---------------------------------------------------
  -- INC0068966 - EVOLUA : 14 - Conta: 66290 
  -- => Solu��o: Efetuar lan�amento cr�dito na transitoria, valor R$ 231.93
---------------------------------------------------
  vr_incidente := 'INC0068966';
  vr_cdcooper  := 14;
  vr_nrdconta  := 66290;
  vr_vllanmto  := 231.93;

  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  prc_gera_acerto_transit (prm_cdcooper => vr_cdcooper
                          ,prm_nrdconta => vr_nrdconta
                          ,prm_vllanmto => vr_vllanmto
                           );
  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');


-- ## 07
---------------------------------------------------
  -- INC0071256 - CREDIFOZ : 11 - Conta: 366366 
  -- => Solu��o: Excluir o 2408 no valor de R$ 6491,60.
              -- Zerar a conta transit�ria.
---------------------------------------------------
  vr_incidente := 'INC0071256';
  vr_cdcooper  := 11;
  vr_nrdconta  := 366366;
  vr_vllanmto  := 6491.60;
  vr_cdhistor  := 2408;
  vr_idlancto  := 151588;  -- PROD tbcc_prejuizo_detalhe.idlancto

  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_exclui_lct (prm_cdcooper => vr_cdcooper,
                  prm_nrdconta => vr_nrdconta,
                  prm_vllanmto => vr_vllanmto,
                  prm_cdhistor => vr_cdhistor,
                  prm_idlancto => vr_idlancto);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'E'); --[I] Inclusao / [E] Exclusao

  prc_gera_acerto_transit (prm_cdcooper => vr_cdcooper
                          ,prm_nrdconta => vr_nrdconta
                          ,prm_vllanmto => vr_vllanmto
                           );

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------


-- ## 08
---------------------------------------------------
  -- INC0068523 - VIACREDI : 1 - Conta: 8504849 
  -- => Solu��o: Efetuar a exclus�o do 2408 no valor de R$ 22.000,00.
---------------------------------------------------
  vr_incidente := 'INC0068523';
  vr_cdcooper  := 1;
  vr_nrdconta  := 8504849;
  vr_vllanmto  := 201.36;
  vr_cdhistor  := 2721;
  vr_idlancto  := 148948;  -- PROD tbcc_prejuizo_detalhe.idlancto

  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_exclui_lct (prm_cdcooper => vr_cdcooper,
                  prm_nrdconta => vr_nrdconta,
                  prm_vllanmto => vr_vllanmto,
                  prm_cdhistor => vr_cdhistor,
                  prm_idlancto => vr_idlancto);

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'E'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------


-- ## 09
---------------------------------------------------
  -- INC0070951 - VIACREDI : 1 - Conta: 9216715 
  -- => Solu��o: Efetuar lan�amento cr�dito na transitoria, valor R$ 1500.00
---------------------------------------------------

  vr_incidente := 'INC0070951';
  vr_cdcooper  := 1;
  vr_nrdconta  := 9216715;
  vr_vllanmto  := 1500.00;

  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  prc_gera_acerto_transit (prm_cdcooper => vr_cdcooper
                          ,prm_nrdconta => vr_nrdconta
                          ,prm_vllanmto => vr_vllanmto
                           );
  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------


-- ## 10
-- INC0070721 - Credifoz - 11 - Conta 397270 - R$ 12,51
  vr_incidente := 'INC0070721';
  vr_cdcooper  := 11;
  vr_nrdconta  := 397270;
  vr_vllanmto  := 12.51;
  vr_cdhistor  := 2408;
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
0
9
prm_cdcooper
prm_nrdconta
prm_vllanmto
prm_cdhistor
vr_dtmvtolt
vr_vlsdprej
vr_found
vr_idprejuizo
prm_idlancto
