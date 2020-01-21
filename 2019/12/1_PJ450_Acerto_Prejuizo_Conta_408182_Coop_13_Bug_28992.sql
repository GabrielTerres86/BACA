/* ...........................................................................
   Autor......: Marcelo Elias Gonçalves (AMcom)
   Data.......: 19/12/2019   
   Objetivo...: Script Acerto Conta-Corrente em Prejuízo.
                Bug 28992 - INC0030466 - Diferença Prejuízo Civia.
..............................................................................*/
DECLARE
  --2408 - SALDO DEVEDOR C/C TRANSFERIDO PARA PREJUIZO

  --Informar Valores ?????
  vr_cdcooper    craplcm.cdcooper%TYPE := 13;       --?????
  vr_nrdconta    craplcm.nrdconta%TYPE := 408182;   --?????
  vr_vllanmto    craplcm.vllanmto%TYPE := 821.07;   --?????
  vr_dtmvtolt    craplcm.dtmvtolt%TYPE := To_Date('07/11/2019','dd/mm/yyyy'); --?????
  --
  vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
  vr_cdhistor    tbcc_prejuizo_detalhe.cdhistor%TYPE := 2408;
  --
  -- Variáveis Tratamento Erro
  vr_erro        EXCEPTION;
  vr_cdcritic    NUMBER;
  vr_dscritic    VARCHAR2(1000);
  --
BEGIN
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
  -- Atualizar Valor Saldo Prejuízo (Diminui o valor do Histórico 2408 que será excluido)
  BEGIN
    UPDATE tbcc_prejuizo  a
    SET    a.vlsdprej = DECODE(SIGN(Nvl(vlsdprej,0) - Nvl(vr_vllanmto,0)),-1,0
                                                                            ,(Nvl(vlsdprej,0) - Nvl(vr_vllanmto,0)))
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
  --Exclui tbcc_prejuizo_detalhe
  BEGIN
    DELETE tbcc_prejuizo_detalhe  b
    WHERE  b.cdcooper = vr_cdcooper 
    AND    b.nrdconta = vr_nrdconta
    AND    b.dtmvtolt = vr_dtmvtolt
    AND    b.vllanmto = vr_vllanmto
    AND    b.cdhistor = vr_cdhistor;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao Excluir tbcc_prejuizo_detalhe. Erro: '||SubStr(SQLERRM,1,255);
      RAISE vr_erro;  
  END; 
  --
  IF Nvl(SQL%RowCount,0) > 0 THEN 
    dbms_output.put_line('   Excluído tbcc_prejuizo_detalhe. Histórico '||vr_cdhistor||': '||Nvl(SQL%RowCount,0)||' registro(s).');
  ELSE
    dbms_output.put_line('   Nenhum registro Excluído na tbcc_prejuizo_detalhe.');   
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
