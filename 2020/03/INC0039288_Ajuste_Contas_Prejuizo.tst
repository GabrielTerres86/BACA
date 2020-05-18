PL/SQL Developer Test script 3.0
423
DECLARE

  PROCEDURE prc_gera_acerto (prm_cdcooper IN craplcm.cdcooper%TYPE,
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
    dbms_output.put_line('   Parâmetros (ATZ VLR e LCM VLR):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Data...........: '||To_Char(vr_dtmvtolt,'dd/mm/yyyy'));
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
        vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro;  
    END; 
    --
    IF Nvl(SQL%RowCount,0) > 0 THEN 
      dbms_output.put_line('   Atualizado Saldo Devedor Prejuízo: '||Nvl(SQL%RowCount,0)||' registro(s).');
    ELSE
      vr_dscritic := 'Conta não encontrada. Cooperativa: '||prm_cdcooper||' | Conta: '||prm_nrdconta;
      RAISE vr_erro;  
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
  dbms_output.put_line('Script iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));

  -- Acerto caso 1
  /*INC0039288 / Transpocred conta 15.458-0
  Correção: excluir o lançamento 2408 no valor de R$ 600,00 do dia 12/02
  Realizar UPDATE de R$ 600,00 na transitória */  
  prc_exclui_lct (prm_cdcooper => 9,
                  prm_nrdconta => 154580,
                  prm_vllanmto => 600,
                  prm_cdhistor => 2408,
                  prm_idlancto => NULL);

  prc_atlz_prejuizo(prm_cdcooper => 9, -- Transpocred
                    prm_nrdconta => 154580,
                    prm_vllanmto => 600);
  -- Acerto caso 1 (Fim)

  -- Acerto caso 2
  /*INC0039001 /  Viacredi conta 992.976-2
  Correção: excluir o lançamento 2408 no valor de R$ 200,00 do dia 07/02
  Realizar UPDATE de R$ 200,00 na transitória */
  prc_exclui_lct (prm_cdcooper => 1,
                  prm_nrdconta => 9929762,
                  prm_vllanmto => 200,
                  prm_cdhistor => 2408,
                  prm_idlancto => 61438);

  prc_atlz_prejuizo(prm_cdcooper => 1, -- Viacredi
                    prm_nrdconta => 9929762,
                    prm_vllanmto => 200);
  -- Acerto caso 2 (Fim).

  -- Acerto caso 3
  /*INC0039559 /  Viacredi conta 992.976-2
  Correção: excluir o lançamento 2408 no valor de R$ 200,00 do dia 05/02
  Realizar UPDATE de R$ 200,00 na transitória */
  prc_exclui_lct (prm_cdcooper => 1,
                  prm_nrdconta => 9929762,
                  prm_vllanmto => 200,
                  prm_cdhistor => 2408,
                  prm_idlancto => 60669);

  prc_atlz_prejuizo(prm_cdcooper => 1, -- Viacredi
                    prm_nrdconta => 9929762,
                    prm_vllanmto => 200);
  -- Acerto caso 3 (Fim)

  -- Acerto caso 4
  /*INC0039558 / Viacredi conta 992.976-2
  Correção: Excluir lançamento 2408 de R$ 200,00 do dia 07/02
  Realizar UPDATE de R$ 200,00 na transitória*/
  prc_exclui_lct (prm_cdcooper => 1,
                  prm_nrdconta => 9929762,
                  prm_vllanmto => 200,
                  prm_cdhistor => 2408,
                  prm_idlancto => 61440);

  prc_atlz_prejuizo(prm_cdcooper => 1, -- Viacredi
                    prm_nrdconta => 9929762,
                    prm_vllanmto => 200);
  -- Acerto caso 4 (Fim)

  -- Acerto caso 5
  /*INC0038845 / Viacredi conta 992.976-2
  Correção: Lançamento 2721 R$ 24,10
  Realizar UPDATE de R$ 24,10 na transitória*/
  prc_gera_acerto (prm_cdcooper => 1, -- Viacredi
                   prm_nrdconta => 9929762,
                   prm_vllanmto => 24.10,
                   prm_cdhistor => 2721);
  -- Acerto caso 5 (Fim).

  -- Acerto caso 6
  /*INC0038846 / Alto Vale conta 263125
  Correção: Lançamento 2721 R$ 151,03
  Realizar UPDATE de R$ 151,03 na transitória*/
  prc_gera_acerto (prm_cdcooper => 16, -- Viacredi Alto Vale
                   prm_nrdconta => 263125,
                   prm_vllanmto => 151.03,
                   prm_cdhistor => 2721);
                   
  /*Alto Vale conta 25.061-9
  Diferença entre o pagamento de prejuízo e o saldo dos detalhes. Ambas as contas geraram o 2718. Valor da diferença 0,02 (correspondente ao débito de JR do dia 31/01/2020)
  Correção: Lançamento 2721 R$ 0,02
  Realizar UPDATE de R$ 0,02 na transitória*/
  prc_gera_acerto (prm_cdcooper => 16, -- Viacredi Alto Vale
                   prm_nrdconta => 250619,
                   prm_vllanmto => 0.02,
                   prm_cdhistor => 2721);
  -- Acerto caso 6 (Fim).

  -- Acerto caso 7
  /*INC0036161 / Viacredi conta 754.372-7
  Correção: Lançamento 2722 no valor de R$ 0,29
            Lançamento 2721 R$ 0,63 (mata o 2718)
  Realizar UPDATE de R$ 0,63 na transitória*/
  prc_gera_lct (prm_cdcooper   => 1,
                prm_nrdconta   => 7543727,
                prm_vllanmto   => 0.29,
                prm_cdhistor   => 2722);

  prc_gera_acerto (prm_cdcooper => 1, -- Viacredi
                   prm_nrdconta => 7543727,
                   prm_vllanmto => 0.63,
                   prm_cdhistor => 2721);
  -- Acerto caso 7 (Fim)


  -- Acerto caso 9  
  /*INC0036154 / Evolua conta 72-8
  Correção: lançamento 2721 no valor de R$ 37,23 
  Realizar UPDATE de R$ 37,23 na transitória*/
  prc_gera_acerto (prm_cdcooper => 14, -- Evolua
                   prm_nrdconta => 728,
                   prm_vllanmto => 37.23,
                   prm_cdhistor => 2721);
  -- Acerto caso 9 (Fim).  

  -- Acerto caso 10  
  /*INC0036159 / Viacredi conta 989.733.0
  Correção: lançamento 2721 no valor de R$ 25,67 
  Realizar UPDATE de R$ 25,67 na transitória */
  prc_gera_acerto (prm_cdcooper => 1, -- Viacredi
                   prm_nrdconta => 9897330,
                   prm_vllanmto => 25.67,
                   prm_cdhistor => 2721);
  -- Acerto caso 10 (Fim).  

  --Salva
  COMMIT;
  
  -- Acerto caso 11 INC0039398
  insert into tbcc_prejuizo_lancamento ( DTMVTOLT, CDAGENCI, NRDCONTA, NRDOCMTO, CDHISTOR, VLLANMTO, DTHRTRAN, CDOPERAD, CDCOOPER, CDORIGEM, DSOPERAC)
  values ( SYSDATE, 1, 9437967, 1, 2738, 177.00, SYSDATE, 'f0031800', 1, 0, null);
  
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
