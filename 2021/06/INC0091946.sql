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

  vr_incidente VARCHAR2(15);
  vr_cdcooper  crapcop.cdcooper%TYPE;
  vr_nrdconta  crapass.nrdconta%TYPE;
  vr_vllanmto  tbcc_prejuizo.vlsdprej%TYPE;
  vr_cdhistor  craphis.cdhistor%TYPE;
  vr_idlancto  tbcc_prejuizo_detalhe.idlancto%TYPE;
  vr_dtmvtolt  tbcc_prejuizo_detalhe.dtmvtolt%TYPE;
  

  PROCEDURE prc_exclui_lct (prm_cdcooper IN craplcm.cdcooper%TYPE,
                            prm_nrdconta IN craplcm.nrdconta%TYPE,
                            prm_vllanmto IN craplcm.vllanmto%TYPE,
                            prm_cdhistor IN craplcm.cdhistor%TYPE,
                            prm_dtmvtolt IN tbcc_prejuizo_detalhe.dtmvtolt%TYPE) IS

    -- Variáveis Tratamento Erro
   
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

  BEGIN
    
  --Busca id lancamento prejuizo
    BEGIN
       SELECT a.idlancto 
        INTO vr_idlancto   
        FROM tbcc_prejuizo_detalhe a
       WHERE a.cdcooper = prm_cdcooper
         AND a.nrdconta = prm_nrdconta
         AND a.cdhistor = prm_cdhistor
         and a.dtmvtolt = prm_dtmvtolt;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar chave prejuizo. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro; 
    END;

    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (Deleção):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line('     Historico......: '||prm_cdhistor);
    dbms_output.put_line('     IDLANCTO.......: '||nvl(vr_idlancto,0));
    dbms_output.put_line(' ');


    IF (prm_cdcooper = 9 AND prm_nrdconta = 20010) THEN
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
         AND a.vllanmto = NVL(prm_vllanmto * -1,0)
         AND (a.idlancto = vr_idlancto OR vr_idlancto IS NULL);
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := 'Erro ao DELETAR v. Erro: '||SubStr(SQLERRM,1,255);
      RAISE vr_erro;
        
    END; 
    --
    IF Nvl(SQL%RowCount,0) > 0 THEN 
      dbms_output.put_line('   Registro(s) removido(s): '||Nvl(SQL%RowCount,0)||' registro(s).');
    ELSE
      vr_dscritic := 'Registro não encontrado. Cooperativa: '||prm_cdcooper||' | Conta: '||prm_nrdconta;
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

-- ## 01
---------------------------------------------------
  -- INC0091935 - Transpocred - C/C 2.0010   R$ 43,53 
  -- -> Solução: Remover um 2781 no valor de R$ 43,53 
---------------------------------------------------
  vr_incidente := 'INC0091946';
  vr_cdcooper  := 9;
  vr_nrdconta  := 20010;
  vr_vllanmto  := 43.53;
  vr_cdhistor  := 2781;
  vr_dtmvtolt  := '11/05/2021';
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
 
  prc_exclui_lct(prm_cdcooper => vr_cdcooper,
                   prm_nrdconta => vr_nrdconta,
                   prm_vllanmto => vr_vllanmto,
                   prm_cdhistor => vr_cdhistor,
                   prm_dtmvtolt => vr_dtmvtolt);


  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
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
