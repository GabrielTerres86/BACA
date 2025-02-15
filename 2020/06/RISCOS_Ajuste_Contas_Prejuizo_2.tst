PL/SQL Developer Test script 3.0
764
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


  PROCEDURE prc_gera_acerto_transit (prm_cdcooper IN craplcm.cdcooper%TYPE,
                                     prm_nrdconta IN craplcm.nrdconta%TYPE,
                                     prm_vllanmto IN craplcm.vllanmto%TYPE,
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
      INTO   vr_dtmvtolt
      FROM   crapdat
      WHERE  cdcooper = prm_cdcooper;
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
-- 2721 - Quando EXCLUI, Aumenta o Saldo Prejuizo      [D] 2721 - REC. PREJUIZO-> TBCC_PREJUIZO_DETALHE
-- 2408 - Quando LAN�A, Diminui o Saldo Prejuizo      [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE


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



---------------------------------------------------
  -- INC0052436 - Viacredi: 1 - Conta: 3649130
  -- => Solu��o: Fazer um 2721 de R$ 2,35 e outro de R$ 0,71.
  vr_incidente := 'INC0052436';
  vr_cdcooper  := 1;
  vr_nrdconta  := 3649130;
  vr_vllanmto  := 2.35;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  prc_gera_acerto (prm_cdcooper => vr_cdcooper,
                   prm_nrdconta => vr_nrdconta,
                   prm_vllanmto => vr_vllanmto,
                   prm_cdhistor => vr_cdhistor);
  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_cdcooper  := 1;
  vr_nrdconta  := 3649130;
  vr_vllanmto  := 0.71;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  prc_gera_acerto (prm_cdcooper => vr_cdcooper,
                   prm_nrdconta => vr_nrdconta,
                   prm_vllanmto => vr_vllanmto,
                   prm_cdhistor => vr_cdhistor);
  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line(' ');
---------------------------------------------------


---------------------------------------------------
  -- INC0049661 - Viacredi: 1 - Conta: 9846735
  -- => Solu��o: Fazer um 2721 de 0,38.
  vr_incidente := 'INC0049661';
  vr_cdcooper  := 1;
  vr_nrdconta  := 9846735;
  vr_vllanmto  := 0.38;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  prc_gera_acerto (prm_cdcooper => vr_cdcooper,
                   prm_nrdconta => vr_nrdconta,
                   prm_vllanmto => vr_vllanmto,
                   prm_cdhistor => vr_cdhistor);
  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line(' ');
---------------------------------------------------


---------------------------------------------------
  -- INC0051243 - Viacredi: 1 - Conta: 10010947
  -- => Solu��o: Fazer um 2721 no valor de R$ 0,18.
  vr_incidente := 'INC0051243';
  vr_cdcooper  := 1;
  vr_nrdconta  := 10010947;
  vr_vllanmto  := 0.18;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  prc_gera_acerto (prm_cdcooper => vr_cdcooper,
                   prm_nrdconta => vr_nrdconta,
                   prm_vllanmto => vr_vllanmto,
                   prm_cdhistor => vr_cdhistor);
  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line(' ');
---------------------------------------------------


---------------------------------------------------
  -- INC0051329 - Viacredi Alto Vale: 16 - Conta: 35.188-1
  -- => Solu��o: Fazer um 2721 de 0,46.
  vr_incidente := 'INC0051329';
  vr_cdcooper  := 16;
  vr_nrdconta  := 351881;
  vr_vllanmto  := 0.46;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  prc_gera_acerto (prm_cdcooper => vr_cdcooper,
                   prm_nrdconta => vr_nrdconta,
                   prm_vllanmto => vr_vllanmto,
                   prm_cdhistor => vr_cdhistor);
  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line(' ');
---------------------------------------------------


---------------------------------------------------
  -- INC0051549 - Civia: 13 - Conta: 11.849-4
  -- Lancar na transitoria valor de R$ 2.014,65
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- INC0051549 - INICIO --------');
  prc_gera_acerto_transit (prm_cdcooper => 13,
                           prm_nrdconta => 118494,
                           prm_vllanmto => 2014.65);

  dbms_output.put_line('-------- INC0051549 - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------


---------------------------------------------------
  -- INC0049431 - Viacredi: 1 - Conta: 7235690
  -- => Solu��o: Fazer um 2721 de 3,60 e outro de 45,44.
  vr_incidente := 'INC0049431';
  vr_cdcooper  := 1;
  vr_nrdconta  := 7235690;
  vr_vllanmto  := 3.60;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  prc_gera_acerto (prm_cdcooper => vr_cdcooper,
                   prm_nrdconta => vr_nrdconta,
                   prm_vllanmto => vr_vllanmto,
                   prm_cdhistor => vr_cdhistor);
  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao / [E] Exclusao

  vr_cdcooper  := 1;
  vr_nrdconta  := 7235690;
  vr_vllanmto  := 45.44;
  vr_cdhistor  := 2721;
  prc_gera_acerto (prm_cdcooper => vr_cdcooper,
                   prm_nrdconta => vr_nrdconta,
                   prm_vllanmto => vr_vllanmto,
                   prm_cdhistor => vr_cdhistor);
  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao Lan�amento / [E] Exclusao Lan�amento
  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line(' ');
---------------------------------------------------


---------------------------------------------------
  -- INC0050494 - Viacredi : 1 - Conta: 9675469
  -- => Solu��o: Efetuar um 2721 no valor de 0,03. Dever� atualizar o saldo de preju�zo.
  vr_incidente := 'INC0050494';
  vr_cdcooper  := 1;
  vr_nrdconta  := 9675469;
  vr_vllanmto  := 0.03;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  prc_gera_acerto (prm_cdcooper => vr_cdcooper,
                   prm_nrdconta => vr_nrdconta,
                   prm_vllanmto => vr_vllanmto,
                   prm_cdhistor => vr_cdhistor);
  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao Lan�amento / [E] Exclusao Lan�amento
  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
----------------------------------------------------


----------------------------------------------------
  -- INC0047305 - Viacredi : 1 - Conta: 7268475
  -- => Solu��o: Solu��o: Lan�ar um 2408 de R$ 10,00 para preju�zo.

  vr_incidente := 'INC0047305';
  vr_cdcooper  := 1;
  vr_nrdconta  := 7268475;
  vr_vllanmto  := 10;
  vr_cdhistor  := 2408;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  prc_gera_acerto (prm_cdcooper => vr_cdcooper,
                   prm_nrdconta => vr_nrdconta,
                   prm_vllanmto => vr_vllanmto,
                   prm_cdhistor => vr_cdhistor);
  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao Lan�amento / [E] Exclusao Lan�amento
  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------


----------------------------------------------------
  -- RITM0050282 - Viacredi : 1 - Conta: 2939495
  -- => Solu��o: Lancar 122.67 - Historico
  vr_incidente := 'RITM0050282';
  vr_cdcooper  := 1;
  vr_nrdconta  := 2939495;
  vr_vllanmto  := 122.67;
  vr_cdhistor  := 2408;     -- [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper
                   ,prm_nrdconta => vr_nrdconta
                   ,prm_vllanmto => vr_vllanmto
                   ,prm_cdhistor => vr_cdhistor
                   ,prm_tipoajus => 'I'); --[I] Inclusao Lan�amento / [E] Exclusao Lan�amento
  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
----------------------------------------------------


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
6
prm_cdcooper
prm_nrdconta
prm_vllanmto
prm_cdhistor
vr_dtmvtolt
vr_vlsdprej
