PL/SQL Developer Test script 3.0
569
DECLARE
  CURSOR cr_his (pr_cdcooper IN crapcop.cdcooper%TYPE
                ,pr_cdhistor IN craphis.cdhistor%TYPE)IS
    SELECT t.cdhistor, t.dshistor, t.indebcre
      FROM craphis t
     WHERE t.cdcooper = pr_cdcooper
       AND t.cdhistor = pr_cdhistor;
  rw_his  cr_his%ROWTYPE;

  vr_indebcre  craphis.indebcre%TYPE;
  vr_found     BOOLEAN;


  PROCEDURE prc_gera_acerto_transit (prm_cdcooper IN craplcm.cdcooper%TYPE,
                                     prm_nrdconta IN craplcm.nrdconta%TYPE,
                                     prm_vllanmto IN craplcm.vllanmto%TYPE,
                                     prm_cdhistor IN craplcm.cdhistor%TYPE,
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
      dbms_output.put_line('   Lançamento do Histórico '||prm_cdhistor||' efetuado com Sucesso na Coop\Conta '||prm_cdcooper||'\'||prm_nrdconta||'.');  
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
    dbms_output.put_line('   Parâmetros (ATZ VLR e LCM VLR):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Data...........: '||To_Char(vr_dtmvtolt,'dd/mm/yyyy'));
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line(' ');


    -- Atualizar Valor Saldo Prejuízo (Diminui o valor da divida)
    IF (prm_cdcooper = 11 AND prm_nrdconta = 20036)
    OR (prm_cdcooper = 9  AND prm_nrdconta = 154580) THEN
       -- Se for essa conta acima, ajusta o Saldo Devedor Prejuizo
      IF prm_idaument = 0 THEN
        BEGIN
          UPDATE tbcc_prejuizo  a
             SET a.vlsdprej = Nvl(vlsdprej,0) - Nvl(prm_vllanmto,0)
           WHERE a.cdcooper = prm_cdcooper
             AND a.nrdconta = prm_nrdconta
          RETURNING a.idprejuizo INTO vr_idprejuizo;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: '||SubStr(SQLERRM,1,255);
            RAISE vr_erro;  
        END; 
      ELSE
        BEGIN
          UPDATE tbcc_prejuizo  a
             SET a.vlsdprej = Nvl(vlsdprej,0) + Nvl(prm_vllanmto,0)
           WHERE a.cdcooper = prm_cdcooper
             AND a.nrdconta = prm_nrdconta
          RETURNING a.idprejuizo INTO vr_idprejuizo;
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
    END IF;

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
  
    -- Variáveis negócio
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;

    -- Variáveis Tratamento Erro
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

  BEGIN
    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (ATZ VLR):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line(' ');

    -- Atualizar Valor Saldo Prejuízo (Diminui o valor da divida)
    BEGIN
      UPDATE tbcc_prejuizo  a
      SET    a.vlsdprej = Nvl(vlsdprej,0) - Nvl(prm_vllanmto,0)
      WHERE  a.cdcooper = prm_cdcooper
      AND    a.nrdconta = prm_nrdconta
      RETURNING a.idprejuizo INTO vr_idprejuizo;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo (2). Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro;  
    END; 
    --
    IF Nvl(SQL%RowCount,0) > 0 THEN 
      dbms_output.put_line('   Atualizado Saldo Devedor Prejuízo(2): '||Nvl(SQL%RowCount,0)||' registro(s).');
    ELSE
      vr_dscritic := 'Conta não encontrada. Cooperativa(2): '||prm_cdcooper||' | Conta: '||prm_nrdconta;
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
  
    -- Variáveis Tratamento Erro
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

  BEGIN

    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (Deleção):');
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
        vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: Historico não encontrato Cop/Hist (' ||prm_cdcooper || '/'||prm_cdhistor||')';
        RAISE vr_erro;  
      END IF;


      IF vr_indebcre = 'C' THEN
        -- Se for exclusão de um CREDITO, deve DIMINUIR ao saldo prej
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
      ELSE
      -- Se for exclusão de um DEBITO, deve SOMAR ao saldo prej
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
      vr_dscritic := 'Registro não encontrado. Cooperativa(3): '||prm_cdcooper||' | Conta: '||prm_nrdconta;
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



---------------------------------------------------
  -- INC0045262 - Viacredi: 1 - Conta: 9790470
  dbms_output.put_line('-------- INC0045262 - INICIO --------');
  dbms_output.put_line(' ');
  prc_exclui_lct (prm_cdcooper => 1,
                  prm_nrdconta => 9790470 ,
                  prm_vllanmto => 8389.38,
                  prm_cdhistor => 2408,  -- [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                  prm_idlancto => 49336);
  dbms_output.put_line('-------- INC0045262 - FIM --------');
  dbms_output.put_line(' ');
---------------------------------------------------



---------------------------------------------------
  -- INC0049699 - Viacredi: 1 - Conta: 246.749.6
  -- Lancar na transitoria 2x valor de $ 200.89
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- INC0049699 - INICIO --------');
  prc_gera_acerto_transit (prm_cdcooper => 1,
                           prm_nrdconta => 2467496,
                           prm_vllanmto => 200.89,
                           prm_cdhistor => 2738);

  prc_gera_acerto_transit (prm_cdcooper => 1,
                           prm_nrdconta => 2467496,
                           prm_vllanmto => 200.89,
                           prm_cdhistor => 2738);
  dbms_output.put_line('-------- INC0049699 - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------



---------------------------------------------------
  -- INC0045723 - UNILOS - 6 - Conta: 88420
  -- Lancar na transitoria  - $1540.92
  -- Excluir lancamentos 2721 da prejuizo_detalhe
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- INC0045723 - INICIO --------');
  prc_gera_acerto_transit (prm_cdcooper => 6,
                           prm_nrdconta => 88420,
                           prm_vllanmto => 1540.92,
                           prm_cdhistor => 2738);
  prc_exclui_lct (prm_cdcooper => 6,
                  prm_nrdconta => 88420,
                  prm_vllanmto => 1540.92,
                  prm_cdhistor => 2721,
                  prm_idlancto => 74107);
  prc_exclui_lct (prm_cdcooper => 6,
                  prm_nrdconta => 88420,
                  prm_vllanmto => 1540.92,
                  prm_cdhistor => 2721,
                  prm_idlancto => 74108);
  prc_exclui_lct (prm_cdcooper => 6,
                  prm_nrdconta => 88420,
                  prm_vllanmto => 1540.92,
                  prm_cdhistor => 2721,
                  prm_idlancto => 74109);
  dbms_output.put_line('-------- INC0045723 - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------



---------------------------------------------------
  -- INC0047308 - Credifoz - 11 - Conta: 20036
  -- Lançar 2721 - $ 30.91
  -- Excluir 2408 - $12000
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- INC0047308 - INICIO --------');
  prc_gera_acerto (prm_cdcooper => 11,
                   prm_nrdconta => 20036,
                   prm_vllanmto => 30.91,
                   prm_cdhistor => 2721,
                   prm_idaument => 0); -- Diminuir Saldo Prejuizo

  prc_exclui_lct (prm_cdcooper => 11,
                  prm_nrdconta => 20036,
                  prm_vllanmto => 12000,
                  prm_cdhistor => 2408,
                  prm_idlancto => 97110); -- Excluido, altera Saldo Prejuizo
  dbms_output.put_line('-------- INC0047308 - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------



---------------------------------------------------
  -- INC0049432 - Viacredi - 01 - Conta: 9497625
  -- Lançar 2721 - $ 45,73
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- INC0049432 - INICIO --------');
  prc_gera_acerto (prm_cdcooper => 1,
                   prm_nrdconta => 9497625,
                   prm_vllanmto => 45.73,
                   prm_cdhistor => 2721,  -- [D] 2721 - REC. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                   prm_idaument => 0);    -- Diminuir Saldo Prejuizo
  dbms_output.put_line('-------- INC0049432 - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------



---------------------------------------------------
  -- INC0049097 - Transpocred - 09 - Conta: 154580
  -- Excluir lancamento 2408
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- INC0049097 - INICIO --------');
  prc_exclui_lct (prm_cdcooper => 9,
                  prm_nrdconta => 154580,
                  prm_vllanmto => 1030,
                  prm_cdhistor => 2408,   -- [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                  prm_idlancto => 97083); -- Excluido, altera Saldo Prejuizo
  dbms_output.put_line('-------- INC0049097 - FIM --------');
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
5
prm_cdcooper
prm_nrdconta
prm_vllanmto
prm_cdhistor
vr_dtmvtolt
