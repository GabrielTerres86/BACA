PL/SQL Developer Test script 3.0
351
DECLARE

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
    
    dbms_output.put_line(' ');
    dbms_output.put_line('   Par�metros (ATZ VLR e LCM VLR):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Data...........: '||To_Char(vr_dtmvtolt,'dd/mm/yyyy'));
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line(' ');

    -- Atualizar Valor Saldo Preju�zo (Diminui o valor da divida)
    IF prm_nrdconta <> 88420 THEN
      
      IF prm_idaument =0 THEN
        BEGIN
          UPDATE tbcc_prejuizo  a
          SET    a.vlsdprej = Nvl(vlsdprej,0) - Nvl(prm_vllanmto,0)
          WHERE  a.cdcooper = prm_cdcooper
          AND    a.nrdconta = prm_nrdconta
          RETURNING a.idprejuizo INTO vr_idprejuizo;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: '||SubStr(SQLERRM,1,255);
            RAISE vr_erro;  
        END; 
      ELSE
        BEGIN
          UPDATE tbcc_prejuizo  a
          SET    a.vlsdprej = Nvl(vlsdprej,0) + Nvl(prm_vllanmto,0)
          WHERE  a.cdcooper = prm_cdcooper
          AND    a.nrdconta = prm_nrdconta
          RETURNING a.idprejuizo INTO vr_idprejuizo;
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
                               prm_vllanmto IN craplcm.vllanmto%TYPE) IS
  
    -- Vari�veis neg�cio
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;

    -- Vari�veis Tratamento Erro
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

  BEGIN
    dbms_output.put_line(' ');
    dbms_output.put_line('   Par�metros (ATZ VLR):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line(' ');

    -- Atualizar Valor Saldo Preju�zo (Diminui o valor da divida)
    BEGIN
      UPDATE tbcc_prejuizo  a
      SET    a.vlsdprej = Nvl(vlsdprej,0) - Nvl(prm_vllanmto,0)
      WHERE  a.cdcooper = prm_cdcooper
      AND    a.nrdconta = prm_nrdconta
      RETURNING a.idprejuizo INTO vr_idprejuizo;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo (2). Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro;  
    END; 
    --
    IF Nvl(SQL%RowCount,0) > 0 THEN 
      dbms_output.put_line('   Atualizado Saldo Devedor Preju�zo(2): '||Nvl(SQL%RowCount,0)||' registro(s).');
    ELSE
      vr_dscritic := 'Conta n�o encontrada. Cooperativa(2): '||prm_cdcooper||' | Conta: '||prm_nrdconta;
      RAISE vr_erro;  
    END IF;   


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
    dbms_output.put_line(' ');

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
  dbms_output.put_line('Script iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  
  -- INC0036157 - Unilos: 6 - Conta: 88420
  prc_gera_acerto (prm_cdcooper => 6,
                   prm_nrdconta => 88420,
                   prm_vllanmto => 1540.92,
                   prm_cdhistor => 2721,
                   prm_idaument => 0); -- diminui
                   
  insert into tbcc_prejuizo_lancamento (DTMVTOLT, CDAGENCI, NRDCONTA, NRDOCMTO, CDHISTOR, VLLANMTO, DTHRTRAN, CDOPERAD, CDCOOPER, CDORIGEM, DSOPERAC)
  values ( TRUNC(SYSDATE), 1, 88420, 1, 2738, 1540.92, SYSDATE, '1', 6, 0, null);

  prc_gera_acerto (prm_cdcooper => 6,
                   prm_nrdconta => 88420,
                   prm_vllanmto => 1540.92,
                   prm_cdhistor => 2721,
                   prm_idaument => 0); -- diminui
                   
  insert into tbcc_prejuizo_lancamento (DTMVTOLT, CDAGENCI, NRDCONTA, NRDOCMTO, CDHISTOR, VLLANMTO, DTHRTRAN, CDOPERAD, CDCOOPER, CDORIGEM, DSOPERAC)
  values ( TRUNC(SYSDATE), 1, 88420, 1, 2738, 1540.92, SYSDATE, '1', 6, 0, null);
  
  prc_gera_acerto (prm_cdcooper => 6,
                   prm_nrdconta => 88420,
                   prm_vllanmto => 1540.92,
                   prm_cdhistor => 2721,
                   prm_idaument => 0); -- diminui
                   
  insert into tbcc_prejuizo_lancamento (DTMVTOLT, CDAGENCI, NRDCONTA, NRDOCMTO, CDHISTOR, VLLANMTO, DTHRTRAN, CDOPERAD, CDCOOPER, CDORIGEM, DSOPERAC)
  values ( TRUNC(SYSDATE), 1, 88420, 1, 2738, 1540.92, SYSDATE, '1', 6, 0, null);                  
  
  -- INC0042841 - Viacredi: 1 - Conta: 9929762 
  prc_gera_acerto (prm_cdcooper => 1,
                   prm_nrdconta => 9929762,
                   prm_vllanmto => 400,
                   prm_cdhistor => 2408,
                   prm_idaument => 1); -- aumenta
    
   -- INC0043574 - Viacredi: 1 - Conta: 8778116
  prc_gera_acerto (prm_cdcooper => 1,
                   prm_nrdconta => 8778116,
                   prm_vllanmto => 1.19,
                   prm_cdhistor => 2721,
                   prm_idaument => 0); -- diminui  
  
  --Salva
  COMMIT;
  
  dbms_output.put_line(' ');
  dbms_output.put_line('Script finalizado com Sucesso em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));

EXCEPTION    
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));    
END;
0
0
