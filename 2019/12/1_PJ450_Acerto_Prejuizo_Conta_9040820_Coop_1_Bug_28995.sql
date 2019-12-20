/* ...........................................................................
   Autor......: Marcelo Elias Gonçalves (AMcom)
   Data.......: 19/12/2019   
   Objetivo...: Script Acerto Conta-Corrente em Prejuízo.
                Bug 28995 - INC0030321 - Diferença Prejuízo Viacredi.
..............................................................................*/
DECLARE
  --2721 - RECUPERACAO DE PREJUIZO C/C
  --2733 - RECUPERACAO DE PREJUIZO C/C
  --2725 - BAIXA DE PREJUIZO C/C VALOR PRINCIPAL

  --Informar Valores ?????
  vr_cdcooper    craplcm.cdcooper%TYPE := 1;       --?????
  vr_nrdconta    craplcm.nrdconta%TYPE := 9040820; --?????
  vr_vllanmto    craplcm.vllanmto%TYPE := 69.85;   --?????
  --
  vr_dtmvtolt    crapdat.dtmvtolt%TYPE;
  vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
  vr_cdhistor    tbcc_prejuizo_detalhe.cdhistor%TYPE;
  --
  -- Variáveis Tratamento Erro
  vr_erro        EXCEPTION;
  vr_cdcritic    NUMBER;
  vr_dscritic    VARCHAR2(1000);
  --
BEGIN
  --
  --Busca Data Atual da Cooperativa
  BEGIN
    SELECT dtmvtolt
    INTO   vr_dtmvtolt
    FROM   crapdat
    WHERE  cdcooper = vr_cdcooper;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao Buscar Data da Cooperatriva. Erro: '||SubStr(SQLERRM,1,255);
      RAISE vr_erro; 
  END;
  --
  dbms_output.put_line('Script iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  dbms_output.put_line(' ');
  dbms_output.put_line('   Parâmetros:');
  dbms_output.put_line('     Cooperativa....: '||vr_cdcooper);
  dbms_output.put_line('     Conta..........: '||vr_nrdconta);
  dbms_output.put_line('     Data...........: '||To_Char(vr_dtmvtolt,'dd/mm/yyyy'));
  dbms_output.put_line('     Valor..........: '||vr_vllanmto);
  dbms_output.put_line(' ');
  --
  -- Atualizar Valor Saldo Prejuízo (Diminui o valor da divida)
  BEGIN
    UPDATE tbcc_prejuizo  a
    SET    a.vlsdprej = Nvl(vlsdprej,0) - Nvl(vr_vllanmto,0)
    WHERE  a.cdcooper = vr_cdcooper
    AND    a.nrdconta = vr_nrdconta
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
    vr_dscritic := 'Conta não encontrada. Cooperativa: '||vr_cdcooper||' | Conta: '||vr_nrdconta;
    RAISE vr_erro;  
  END IF;   
  --
  --
  -- Cria lançamento (Tabela tbcc_prejuizo_detalhe)
  vr_cdhistor := 2721;
  prej0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => vr_cdcooper
                                   ,pr_nrdconta   => vr_nrdconta
                                   ,pr_dtmvtolt   => vr_dtmvtolt
                                   ,pr_cdhistor   => vr_cdhistor
                                   ,pr_idprejuizo => vr_idprejuizo
                                   ,pr_vllanmto   => vr_vllanmto
                                   ,pr_dthrtran   => SYSDATE
                                   ,pr_cdcritic   => vr_cdcritic
                                   ,pr_dscritic   => vr_dscritic);
  IF Nvl(vr_cdcritic,0) > 0 OR Trim(vr_dscritic) IS NOT NULL THEN
    RAISE vr_erro; 
  ELSE
    dbms_output.put_line('   Lançamento do Histórico '||vr_cdhistor||' efetuado com Sucesso.');  
  END IF; 
  --
  --
  -- Cria lançamento (Tabela tbcc_prejuizo_detalhe)
  vr_cdhistor := 2733;
  prej0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => vr_cdcooper
                                   ,pr_nrdconta   => vr_nrdconta
                                   ,pr_dtmvtolt   => vr_dtmvtolt
                                   ,pr_cdhistor   => vr_cdhistor
                                   ,pr_idprejuizo => vr_idprejuizo
                                   ,pr_vllanmto   => vr_vllanmto
                                   ,pr_dthrtran   => SYSDATE
                                   ,pr_cdcritic   => vr_cdcritic
                                   ,pr_dscritic   => vr_dscritic);
  IF Nvl(vr_cdcritic,0) > 0 OR Trim(vr_dscritic) IS NOT NULL THEN
    RAISE vr_erro; 
  ELSE
    dbms_output.put_line('   Lançamento do Histórico '||vr_cdhistor||' efetuado com Sucesso.');  
  END IF; 
  --
  --
  -- Cria lançamento (Tabela tbcc_prejuizo_detalhe)
  vr_cdhistor := 2725;
  prej0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => vr_cdcooper
                                   ,pr_nrdconta   => vr_nrdconta
                                   ,pr_dtmvtolt   => vr_dtmvtolt
                                   ,pr_cdhistor   => vr_cdhistor
                                   ,pr_idprejuizo => vr_idprejuizo
                                   ,pr_vllanmto   => vr_vllanmto
                                   ,pr_dthrtran   => SYSDATE
                                   ,pr_cdcritic   => vr_cdcritic
                                   ,pr_dscritic   => vr_dscritic);
  IF Nvl(vr_cdcritic,0) > 0 OR Trim(vr_dscritic) IS NOT NULL THEN
    RAISE vr_erro; 
  ELSE
    dbms_output.put_line('   Lançamento do Histórico '||vr_cdhistor||' efetuado com Sucesso.');  
  END IF; 
  --
  -- 
  --Salva
  COMMIT;
  --
  --
  dbms_output.put_line(' ');
  dbms_output.put_line('Script finalizado com Sucesso em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  --
EXCEPTION
  WHEN vr_erro THEN
    dbms_output.put_line(vr_dscritic);
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20001,vr_dscritic);
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
END;
/
