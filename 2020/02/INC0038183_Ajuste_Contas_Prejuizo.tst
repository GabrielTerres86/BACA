PL/SQL Developer Test script 3.0
134
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
    dbms_output.put_line('   Parâmetros:');
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
      Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));    
  END prc_gera_acerto;
      

BEGIN
  dbms_output.put_line('Script iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));

  -- Acerto caso 1
  prc_gera_acerto(prm_cdcooper => 1,
                  prm_nrdconta => 8623910,
                  prm_vllanmto => 31.41,
                  prm_cdhistor => 2721); --2721 - RECUPERACAO DE PREJUIZO C/C

  -- Acerto caso 2
  prc_gera_acerto(prm_cdcooper => 1,
                  prm_nrdconta => 9687203,
                  prm_vllanmto => 29.49,
                  prm_cdhistor => 2721); 

  -- Acerto caso 3
  prc_gera_acerto(prm_cdcooper => 1,
                  prm_nrdconta => 6134815,
                  prm_vllanmto => 1.56,
                  prm_cdhistor => 2721); 

  -- Acerto caso 4
  prc_gera_acerto(prm_cdcooper => 1,
                  prm_nrdconta => 9541284,
                  prm_vllanmto => 5.51,
                  prm_cdhistor => 2721); 

  -- Acerto caso 5
  prc_gera_acerto(prm_cdcooper => 1,
                  prm_nrdconta => 10039201,
                  prm_vllanmto => 8.77,
                  prm_cdhistor => 2721); 

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
