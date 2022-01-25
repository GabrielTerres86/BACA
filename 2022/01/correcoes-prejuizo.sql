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
  
  vr_cdcooper  crapcop.cdcooper%TYPE;
  vr_nrdconta  crapass.nrdconta%TYPE;
  vr_vllanmto  tbcc_prejuizo.vlsdprej%TYPE;
  vr_cdhistor  craphis.cdhistor%TYPE;
  vr_idlancto  tbcc_prejuizo_detalhe.idlancto%TYPE;

  PROCEDURE registrarVERLOG(pr_cdcooper            IN INTEGER
                           ,pr_nrdconta            IN INTEGER
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
  dbms_output.put_line('INC0121825 iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  
-- INC0121825 INICIO
---------------------------------------------------
  -- falta VAV em 25/11 no valor 11,11 a CC 79464
  vr_cdcooper  := 16;
  vr_nrdconta  := 79464;
  vr_vllanmto  := 11.11;
  vr_cdhistor  := 2408;
  
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo (prm_cdcooper => vr_cdcooper,
                               prm_nrdconta => vr_nrdconta,
                               prm_vllanmto => vr_vllanmto,
                               prm_cdhistor => vr_cdhistor,
                               prm_tipoajus => 'I');             

---------------------------------------------------
  -- sobra Civia em 23/12 no valor 648,35 na CC 35784-7
  vr_cdcooper  := 13;
  vr_nrdconta  := 357847;
  vr_vllanmto  := 648.35;
  vr_cdhistor  := 2721;
  
  dbms_output.put_line('  ');
     
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo (prm_cdcooper => vr_cdcooper,
                               prm_nrdconta => vr_nrdconta,
                               prm_vllanmto => vr_vllanmto,
                               prm_cdhistor => vr_cdhistor,
                               prm_tipoajus => 'I');
                               
---------------------------------------------------
  -- sobra Viacredi em 22/12 no valor 1,90 na CC 1032162-4
  vr_cdcooper  := 1;
  vr_nrdconta  := 10321624;
  vr_vllanmto  := 1.90;
  vr_cdhistor  := 2721;
  
  dbms_output.put_line('  ');
     
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo (prm_cdcooper => vr_cdcooper,
                               prm_nrdconta => vr_nrdconta,
                               prm_vllanmto => vr_vllanmto,
                               prm_cdhistor => vr_cdhistor,
                               prm_tipoajus => 'I');

---------------------------------------------------
  -- falta Viacredi em 22/12 no valor 5,38 na CC 1038448-0
  vr_cdcooper  := 1;
  vr_nrdconta  := 10384480;
  vr_vllanmto  := 5.43;
  vr_cdhistor  := 2408;
  
  dbms_output.put_line('  ');
    
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo (prm_cdcooper => vr_cdcooper,
                               prm_nrdconta => vr_nrdconta,
                               prm_vllanmto => vr_vllanmto,
                               prm_cdhistor => vr_cdhistor,
                               prm_tipoajus => 'I'); 
                               
---------------------------------------------------
  -- falta VAV em 20/12 no valor 161,48 na CC 67211-4
  vr_cdcooper  := 16;
  vr_nrdconta  := 672114;
  vr_vllanmto  := 161.48;
  vr_cdhistor  := 2408;
  
  dbms_output.put_line('  ');
    
  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);

  prc_atlz_prejuizo (prm_cdcooper => vr_cdcooper,
                               prm_nrdconta => vr_nrdconta,
                               prm_vllanmto => vr_vllanmto,
                               prm_cdhistor => vr_cdhistor,
                               prm_tipoajus => 'I');
             
-- INC0121825 FIM
  dbms_output.put_line(' ');
  dbms_output.put_line('INC0121825 finalizado com Sucesso em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
-- INC0121831 INICIO
  dbms_output.put_line('INC0121831 iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
---------------------------------------------------
  -- Acredicoop 65.228.8 - 2721  12,50 
  vr_cdcooper  := 2;
  vr_nrdconta  := 652288;
  vr_vllanmto  := 12.50;
  vr_cdhistor  := 2721;
  
  --realizar o debito na lislot (tbcc_prejuizo_detalhe)         
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
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
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
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
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
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
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
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
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
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
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
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
  prc_gera_lct(prm_cdcooper => vr_cdcooper,
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


-- INC0121831 FIM
  dbms_output.put_line(' ');
  dbms_output.put_line('INC0121831 finalizado com Sucesso em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
---------------------------------------------------

-- INC0119555 INICIO
  dbms_output.put_line('INC0119555 iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  
  DELETE FROM TBCC_PREJUIZO_LANCAMENTO
   WHERE CDCOOPER = 6
     AND NRDCONTA = 130664
     AND VLLANMTO = 110
     AND CDHISTOR = 2738
     AND dtmvtolt = to_date('18/01/2022', 'dd/mm/rrrr');
       
  UPDATE tbcc_prejuizo
     SET vlsdprej = Nvl(vlsdprej, 0) - 110
   WHERE cdcooper = 6
     AND nrdconta = 130664;
     
-- INC0119555 FIM
  dbms_output.put_line(' ');
  dbms_output.put_line('INC0119555 finalizado com Sucesso em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
         
  --Salva
  --COMMIT;
  ROLLBACK;

------------ BLOCO PRINCIPAL - FIM ---------------------

EXCEPTION    
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));    
END;
