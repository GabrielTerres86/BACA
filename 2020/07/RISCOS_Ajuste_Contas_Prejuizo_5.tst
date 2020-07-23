PL/SQL Developer Test script 3.0
656
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
    IF (prm_cdcooper = 16 AND prm_nrdconta = 380660) then
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
                            prm_idlancto IN tbcc_prejuizo_detalhe.idlancto%TYPE,
                            prm_dtmvtolt IN tbcc_prejuizo_detalhe.dtmvtolt%type) IS
  
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
    dbms_output.put_line('     IDLANCTO.......: '||prm_idlancto);
    dbms_output.put_line('     Data...........: '||prm_dtmvtolt);
    dbms_output.put_line(' ');

    
    IF (prm_cdcooper = 9  AND prm_nrdconta = 154580) or
       (prm_cdcooper = 13 and prm_nrdconta = 4855)   or
       (prm_cdcooper = 11 and prm_nrdconta = 323870) or
       (prm_cdcooper = 1  and prm_nrdconta = 9273760) THEN
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
         AND (a.idlancto = prm_idlancto OR prm_idlancto IS NULL)
         AND (a.dtmvtolt = prm_dtmvtolt or prm_dtmvtolt is null);
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
  -- INC0052084 - Transpocred: 9 - Conta: 15.458-0
  dbms_output.put_line('-------- INC0052084 - INICIO --------');
  dbms_output.put_line(' ');
  prc_exclui_lct (prm_cdcooper => 9,
                  prm_nrdconta => 154580 ,
                  prm_vllanmto => 1000,
                  prm_cdhistor => 2408,  -- [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                  prm_idlancto => NULL,
                  prm_dtmvtolt => to_date('15/06/2020', 'dd/mm/RRRR'));
  dbms_output.put_line('-------- INC0052084 - FIM --------');
  dbms_output.put_line(' ');
---------------------------------------------------

---------------------------------------------------
  -- INC0052670 - Civia: 13 - Conta: 4855
  dbms_output.put_line('-------- INC0052670 - INICIO --------');
  dbms_output.put_line(' ');
  prc_exclui_lct (prm_cdcooper => 13,
                  prm_nrdconta => 4855,
                  prm_vllanmto => 4500,
                  prm_cdhistor => 2408,  -- [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                  prm_idlancto => NULL,
                  prm_dtmvtolt => to_date('18/06/2020', 'dd/mm/RRRR'));
  dbms_output.put_line('-------- INC0052670 - FIM --------');
  dbms_output.put_line(' ');
---------------------------------------------------

---------------------------------------------------
  -- INC0052897 - Credifoz: 11 - Conta: 32.387-0
  dbms_output.put_line('-------- INC0052897 - INICIO --------');
  dbms_output.put_line(' ');
  prc_exclui_lct (prm_cdcooper => 11,
                  prm_nrdconta => 323870,
                  prm_vllanmto => 95000,
                  prm_cdhistor => 2408,  -- [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                  prm_idlancto => NULL,
                  prm_dtmvtolt => to_date('22/06/2020', 'dd/mm/RRRR'));
  dbms_output.put_line('-------- INC0052897 - FIM --------');
  dbms_output.put_line(' ');
---------------------------------------------------

---------------------------------------------------
  -- INC0054635 - Viacredi: 1 - Conta: 927.376-0
  dbms_output.put_line('-------- INC0054635 - INICIO --------');
  dbms_output.put_line(' ');
  
  prc_exclui_lct (prm_cdcooper => 1,
                  prm_nrdconta => 9273760,
                  prm_vllanmto => 500,
                  prm_cdhistor => 2408,  -- [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                  prm_idlancto => 107029,
                  prm_dtmvtolt => to_date('29/06/2020', 'dd/mm/RRRR'));
                  
  prc_exclui_lct (prm_cdcooper => 1,
                  prm_nrdconta => 9273760,
                  prm_vllanmto => 1000,
                  prm_cdhistor => 2408,  -- [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                  prm_idlancto => 107030,
                  prm_dtmvtolt => to_date('29/06/2020', 'dd/mm/RRRR'));
                  
  prc_exclui_lct (prm_cdcooper => 1,
                  prm_nrdconta => 9273760,
                  prm_vllanmto => 500,
                  prm_cdhistor => 2408,  -- [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                  prm_idlancto => 107031,
                  prm_dtmvtolt => to_date('29/06/2020', 'dd/mm/RRRR'));
                  
  prc_exclui_lct (prm_cdcooper => 1,
                  prm_nrdconta => 9273760,
                  prm_vllanmto => 500,
                  prm_cdhistor => 2408,  -- [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                  prm_idlancto => 107032,
                  prm_dtmvtolt => to_date('29/06/2020', 'dd/mm/RRRR'));
                  
  prc_exclui_lct (prm_cdcooper => 1,
                  prm_nrdconta => 9273760,
                  prm_vllanmto => 180,
                  prm_cdhistor => 2408,  -- [C] 2408 - TRF. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                  prm_idlancto => 107033,
                  prm_dtmvtolt => to_date('29/06/2020', 'dd/mm/RRRR'));
                  
  dbms_output.put_line('-------- INC0054635 - FIM --------');
  dbms_output.put_line(' ');
---------------------------------------------------

---------------------------------------------------
  -- INC0054927 - Alto Vale: 16 - Conta: 38.066-0
  dbms_output.put_line('-------- INC0054927 - INICIO --------');
  dbms_output.put_line(' ');
  
  prc_gera_acerto (prm_cdcooper => 16,
                   prm_nrdconta => 380660,
                   prm_vllanmto => 0.91,
                   prm_cdhistor => 2721);  -- [D] 2721 - RECUP. PREJUIZO-> TBCC_PREJUIZO_DETALHE
                  
  dbms_output.put_line('-------- INC0054927 - FIM --------');
  dbms_output.put_line(' ');
---------------------------------------------------

---------------------------------------------------
  -- INC0048253 - ALTOVALE: 16 - Conta: 401900
  -- => Solução: Lancar 32,00 - Conta Transitoria
  
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- INC0048253 - INICIO --------');

  prc_gera_acerto_transit (prm_cdcooper => 16
                          ,prm_nrdconta => 401900
                          ,prm_vllanmto => 32);

  dbms_output.put_line('-------- INC0048253 - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------

---------------------------------------------------
  -- INC0053098 - TRANSPOCRED: 09 - Conta: 17.615-0
  -- => Solução: Lancar 266,52 - Conta Transitoria
  
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- INC0053098 - INICIO --------');

  prc_gera_acerto_transit (prm_cdcooper => 09
                          ,prm_nrdconta => 176150
                          ,prm_vllanmto => 266.52);

  dbms_output.put_line('-------- INC0053098 - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------

---------------------------------------------------
  -- INC0053420 - TRANSPOCRED: 09 - Conta: 21.299-7
  -- => Solução: Lancar 1.928,00 - Conta Transitoria
  --             Lancar 1.917,00 - Conta Transitoria
  
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- INC0053420 - INICIO --------');

  prc_gera_acerto_transit (prm_cdcooper => 09
                          ,prm_nrdconta => 212997
                          ,prm_vllanmto => 1928);
                          
  prc_gera_acerto_transit (prm_cdcooper => 09
                          ,prm_nrdconta => 212997
                          ,prm_vllanmto => 1917);

  dbms_output.put_line('-------- INC0053420 - FIM --------');
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
