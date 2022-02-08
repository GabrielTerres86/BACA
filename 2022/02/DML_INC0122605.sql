DECLARE 

  pr_nrdconta NUMBER := 451509;
  pr_cdcooper NUMBER := 13;
  vr_vlEstDespesa NUMBER := 0.31;
  vr_dsincid VARCHAR2(50):= 'INC0122605';
  
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(2000);
  vr_exc_erro EXCEPTION;
  
  vr_retxml   xmltype;
  vr_des_reto VARCHAR2(4000);
  vr_xmllog   VARCHAR2(4000);
  vr_nmdcampo VARCHAR2(50);
  vr_des_erro VARCHAR2(4000);
  vr_tab_erro gene0001.typ_tab_erro;
  
  PROCEDURE EstornarDespesas (pr_cdcooper IN NUMBER,
                              pr_nrdconta IN NUMBER,
                              pr_dtmvtolt IN DATE,
                              pr_vllamnto IN NUMBER,
                              pr_cdcritic OUT NUMBER,
                              pr_dscritic OUT VARCHAR2
                            )IS 
    
    -- Buscar os dados do cooperado
    CURSOR cr_crapass(pr_cdcooper  crapass.cdcooper%TYPE
                     ,pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT ass.cdagenci
            ,ass.vllimcre
            ,ass.inprejuz
        FROM crapass ass
       WHERE ass.nrdconta = pr_nrdconta
         AND ass.cdcooper = pr_cdcooper;
    rw_crapass   cr_crapass%ROWTYPE;
    
    vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Buscar os dados do cooperado
    OPEN  cr_crapass(pr_cdcooper
                    ,pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;
    
    -- Realiza o lançamento do saldo bloqueado na conta corrente do cooperado
    EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper  --> Cooperativa conectada
                                  ,pr_dtmvtolt => pr_dtmvtolt  --> Movimento atual
                                  ,pr_cdagenci => 1            --> Código da agência
                                  ,pr_cdbccxlt => 100          --> Número do caixa
                                  ,pr_cdoperad => 1            --> Código do Operador
                                  ,pr_cdpactra => 1            --> P.A. da transação
                                  ,pr_nrdolote => 650001       --> Numero do Lote
                                  ,pr_nrdconta => pr_nrdconta  --> Número da conta
                                  ,pr_cdhistor => 2545         --> Codigo historico 2545 - Estorno de despesas
                                  ,pr_vllanmto => pr_vllamnto  --> Valor da parcela emprestimo
                                  ,pr_nrparepr => 0            --> Número parcelas empréstimo
                                  ,pr_nrctremp => 0            --> Número do contrato de empréstimo
                                  ,pr_des_reto => vr_des_reto  --> Retorno OK / NOK
                                  ,pr_tab_erro => vr_tab_erro);--> Tabela com possíves erros

    -- Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
      -- Se possui algum erro na tabela de erros
      IF vr_tab_erro.COUNT() > 0 THEN
        pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
      END IF;
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      NULL;
    WHEN OTHERS THEN 
      pr_dscritic := 'Erro ao Estornar despesas valor: '||SQLERRM;  
  END EstornarDespesas;
  

BEGIN
  
  -- Leitura do calendário da cooperativa
  OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat into rw_crapdat;  
  CLOSE btch0001.cr_crapdat; 
    
  
  EstornarDespesas (pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                    pr_vllamnto => vr_vlEstDespesa,
                    pr_cdcritic => vr_cdcritic,
                    pr_dscritic => vr_dscritic);
  
  IF nvl(vr_cdcritic, 0) > 0 OR 
     TRIM(vr_dscritic) IS NOT NULL THEN    
    RAISE vr_exc_erro;
  END IF;
  
  PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_vlrlanc  => vr_vlEstDespesa
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_dsoperac => 'Ajuste '||vr_dsincid
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic); 
                                                        
  IF nvl(vr_cdcritic, 0) > 0 OR 
     TRIM(vr_dscritic) IS NOT NULL THEN    
    RAISE vr_exc_erro;
  END IF;
  
  COMMIT;
  
EXCEPTION   
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20500,vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500,SQLERRM);  
END;
