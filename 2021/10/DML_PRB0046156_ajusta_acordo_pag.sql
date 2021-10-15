DECLARE 

  pr_cdcooper NUMBER := 1;
  
  vr_tab_erro gene0001.typ_tab_erro ;
  vr_des_reto VARCHAR2(2000);  
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(2000);
  vr_idx      PLS_INTEGER;
  
  TYPE typ_acordos 
      IS RECORD (nracordo NUMBER,
                 vlbloque NUMBER,
                 vlestorn NUMBER,
                 inprejcc INTEGER,
                 vlabono  NUMBER);
  TYPE typ_tab_acordos IS TABLE OF typ_acordos
      INDEX BY PLS_INTEGER;
  vr_tab_acordos typ_tab_acordos;
  
  CURSOR cr_acordo(pr_nracordo NUMBER,
                   pr_cdsituac NUMBER) IS
    SELECT a.nrdconta
      FROM tbrecup_acordo a
     WHERE a.nracordo = pr_nracordo
       AND a.cdsituacao = nvl(pr_cdsituac,a.cdsituacao)
       ;
  rw_acordo cr_acordo%ROWTYPE;  

  PROCEDURE bloquear (pr_cdcooper IN NUMBER,
                      pr_nrdconta IN NUMBER,
                      pr_nracordo IN NUMBER,
                      pr_dtmvtolt IN DATE,
                      pr_vllamnto IN NUMBER,
                      pr_cdcritic OUT NUMBER,
                      pr_dscritic OUT VARCHAR2
                      )IS 
    
    vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Realiza o lançamento do saldo bloqueado na conta corrente do cooperado
    EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper           --> Cooperativa conectada
                                  ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                  ,pr_cdagenci => 1          --> Código da agência
                                  ,pr_cdbccxlt => 100                          --> Número do caixa
                                  ,pr_cdoperad => 1                  --> Código do Operador
                                  ,pr_cdpactra => 1          --> P.A. da transação
                                  ,pr_nrdolote => 650001                       --> Numero do Lote
                                  ,pr_nrdconta => pr_nrdconta           --> Número da conta
                                  ,pr_cdhistor => 2193                         --> Codigo historico 2193 - DEBITO BLOQUEIO ACORDOS
                                  ,pr_vllanmto => pr_vllamnto                  --> Valor da parcela emprestimo
                                  ,pr_nrparepr => 0                  --> Número parcelas empréstimo
                                  ,pr_nrctremp => 0                            --> Número do contrato de empréstimo
                                  ,pr_des_reto => vr_des_reto                  --> Retorno OK / NOK
                                  ,pr_tab_erro => vr_tab_erro);                --> Tabela com possíves erros

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

    -- Alterar o valor bloqueado no acordo, com o valor lançado
    BEGIN
      -- Alterar a situação do acordo para cancelado
      UPDATE tbrecup_acordo
         SET vlbloqueado = NVL(vlbloqueado,0) + NVL(pr_vllamnto,0)
       WHERE nracordo = pr_nracordo;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao atualizar acordo: '||SQLERRM;
        RAISE vr_exc_erro;
    END;  
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      NULL;
    WHEN OTHERS THEN 
      pr_dscritic := 'Erro ao bloquear valor: '||SQLERRM;  
  END bloquear;   
  
  PROCEDURE desbloquear ( pr_cdcooper IN NUMBER,
                          pr_nrdconta IN NUMBER,
                          pr_nracordo IN NUMBER,
                          pr_dtmvtolt IN DATE,
                          pr_vllamnto IN NUMBER,
                          pr_cdcritic OUT NUMBER,
                          pr_dscritic OUT VARCHAR2
                      )IS 
    
    vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Realiza o lançamento do saldo bloqueado na conta corrente do cooperado
    EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper  --> Cooperativa conectada
                                  ,pr_dtmvtolt => pr_dtmvtolt  --> Movimento atual
                                  ,pr_cdagenci => 1            --> Código da agência
                                  ,pr_cdbccxlt => 100          --> Número do caixa
                                  ,pr_cdoperad => 1            --> Código do Operador
                                  ,pr_cdpactra => 1            --> P.A. da transação
                                  ,pr_nrdolote => 650001       --> Numero do Lote
                                  ,pr_nrdconta => pr_nrdconta  --> Número da conta
                                  ,pr_cdhistor => 2194         --> Codigo historico 2194 - Credito de desbloqueio
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

    -- Alterar o valor bloqueado no acordo, com o valor lançado
    BEGIN
      -- Alterar a situação do acordo para cancelado
      UPDATE tbrecup_acordo
         SET vlbloqueado = NVL(vlbloqueado,0) - NVL(pr_vllamnto,0)
       WHERE nracordo = pr_nracordo;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao atualizar acordo: '||SQLERRM;
        RAISE vr_exc_erro;
    END;  
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      NULL;
    WHEN OTHERS THEN 
      pr_dscritic := 'Erro ao desbloquear valor: '||SQLERRM;  
  END desbloquear;    
  
  PROCEDURE EstornarDespesas (pr_cdcooper IN NUMBER,
                              pr_nrdconta IN NUMBER,
                              pr_nracordo IN NUMBER,
                              pr_dtmvtolt IN DATE,
                              pr_vllamnto IN NUMBER,
                              pr_forcaPrej IN INTEGER DEFAULT 0,
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


  PROCEDURE LancarAbono ( pr_cdcooper IN NUMBER,
                          pr_nrdconta IN NUMBER,
                          pr_nracordo IN NUMBER,
                          pr_dtmvtolt IN DATE,
                          pr_vldabono IN NUMBER,
                          pr_forcaPrej IN INTEGER DEFAULT 0,
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
                                  ,pr_cdhistor => 2181         --> Codigo historico Abono
                                  ,pr_vllanmto => pr_vldabono  --> Valor da parcela emprestimo
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
      pr_dscritic := 'Erro ao lancar abono valor: '||SQLERRM;  
  END LancarAbono;   


BEGIN
  
  -- Leitura do calendário da cooperativa
  OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat into rw_crapdat;  
  CLOSE btch0001.cr_crapdat;
 
  dbms_output.put_line('Bloquear valor Acordo');

  vr_tab_acordos.delete;
  /*vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 305825;
  vr_tab_acordos(vr_idx).vlbloque := 133.18;
  */
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 305909;
  vr_tab_acordos(vr_idx).vlbloque := 90.68;
  
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 307115;
  vr_tab_acordos(vr_idx).vlbloque := 649.28;
  
  --8799792
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 286524;
  vr_tab_acordos(vr_idx).vlbloque := 28.22;
  
  --8003432
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 289395;
  vr_tab_acordos(vr_idx).vlbloque := 90.33;
  
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 290164;
  vr_tab_acordos(vr_idx).vlbloque := 45.92;
  
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 286654;
  vr_tab_acordos(vr_idx).vlbloque := 32.24;
  
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 320681;
  vr_tab_acordos(vr_idx).vlbloque := 46.89;
  
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 284589;
  vr_tab_acordos(vr_idx).vlbloque := 13.81;
   
  
  --284.308-0
  vr_idx := vr_tab_acordos.count; 
  vr_tab_acordos(vr_idx).nracordo := 309596;  
  vr_tab_acordos(vr_idx).vlbloque := 15.23;
  --879.979-2  vr_tab_acordos(vr_idx).vlbloque := 28.22;
  
  --400.189-3    
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 304789; 
  vr_tab_acordos(vr_idx).vlbloque := 17.47;  
  
  --800.343-2  vr_tab_acordos(vr_idx).vlbloque := 90.33;
  --364.542-8 
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 265518;  
  vr_tab_acordos(vr_idx).vlbloque := 112.88;
  
  --917.421-4  
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 240645; 
  vr_tab_acordos(vr_idx).vlbloque := 5.96;
  
  --897.450-0  
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 306617; 
  vr_tab_acordos(vr_idx).vlbloque := 132.33;
  
  --788.126-6  
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 282074; 
  vr_tab_acordos(vr_idx).vlbloque := 80.2;
  
  FOR idx IN vr_tab_acordos.first..vr_tab_acordos.count -1 LOOP
    
    OPEN cr_acordo (pr_nracordo => vr_tab_acordos(idx).nracordo,
                    pr_cdsituac => 1);
    FETCH cr_acordo INTO rw_acordo;
    CLOSE cr_acordo;
    
    dbms_output.put_line(rw_acordo.nrdconta||';'||vr_tab_acordos(idx).vlbloque);
  
    bloquear ( pr_cdcooper => pr_cdcooper
              ,pr_nrdconta => rw_acordo.nrdconta
              ,pr_nracordo => vr_tab_acordos(idx).nracordo
              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
              ,pr_vllamnto => vr_tab_acordos(idx).vlbloque
              ,pr_cdcritic => vr_cdcritic 
              ,pr_dscritic => vr_dscritic);
    
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      ROLLBACK; 
      raise_application_error(-20500,'Erro '||vr_cdcritic||vr_dscritic);
    END IF; 
  
  END LOOP;  
 
  dbms_output.put_line('Estornar Despesa');
  vr_tab_acordos.delete;
  
  vr_idx := vr_tab_acordos.count; --823.976-2 
  vr_tab_acordos(vr_idx).vlestorn := 108.56;  
  vr_tab_acordos(vr_idx).nracordo := 292589;
  
  --vr_idx := vr_tab_acordos.count; --1056.011-4  
  --vr_tab_acordos(vr_idx).vlestorn := 105.47;  
  --vr_tab_acordos(vr_idx).nracordo := 343726;
  --vr_tab_acordos(vr_idx).inprejcc := 1;
  --vr_tab_acordos(vr_idx).vlabono  := 0.18;  
  
  vr_idx := vr_tab_acordos.count; --969.898-1 
  vr_tab_acordos(vr_idx).vlestorn := 146.58 ; 
  vr_tab_acordos(vr_idx).nracordo :=281976;
  
  vr_idx := vr_tab_acordos.count; --315.806-3 
  vr_tab_acordos(vr_idx).vlestorn := 320.88;  
  vr_tab_acordos(vr_idx).nracordo :=189736;
  
  vr_idx := vr_tab_acordos.count; --196.520-4 
  vr_tab_acordos(vr_idx).vlestorn := 533.94;  
  vr_tab_acordos(vr_idx).nracordo :=284912;
  
  vr_idx := vr_tab_acordos.count; --752.100-6 
  vr_tab_acordos(vr_idx).vlestorn := 231.4 ;
  vr_tab_acordos(vr_idx).nracordo :=223311;
  
  vr_idx := vr_tab_acordos.count; --652.496-6 
  vr_tab_acordos(vr_idx).vlestorn := 103.24;  
  vr_tab_acordos(vr_idx).nracordo :=99632;
  
  vr_idx := vr_tab_acordos.count; --623.277-9 
  vr_tab_acordos(vr_idx).vlestorn := 115.39  ;
  vr_tab_acordos(vr_idx).nracordo :=184017;
  
  vr_idx := vr_tab_acordos.count; --619.939-9 
  vr_tab_acordos(vr_idx).vlestorn := 158.68;  
  vr_tab_acordos(vr_idx).nracordo :=277025;
  
  vr_idx := vr_tab_acordos.count; --402.892-9 
  vr_tab_acordos(vr_idx).vlestorn := 93.2  ;
  vr_tab_acordos(vr_idx).nracordo :=161645;
  
  vr_idx := vr_tab_acordos.count; --742.694-1 
  vr_tab_acordos(vr_idx).vlestorn := 146.72  ;
  vr_tab_acordos(vr_idx).nracordo :=215291;
  
  vr_idx := vr_tab_acordos.count; --702.434-7   
  vr_tab_acordos(vr_idx).vlestorn := 624.51  ;
  vr_tab_acordos(vr_idx).nracordo :=152139;
  
  vr_idx := vr_tab_acordos.count; --355.772-3 
  vr_tab_acordos(vr_idx).vlestorn := 410.3 ;
  vr_tab_acordos(vr_idx).nracordo :=112792;
  
  vr_idx := vr_tab_acordos.count; --355.772-3 
  vr_tab_acordos(vr_idx).vlestorn := 37.53 ;
  vr_tab_acordos(vr_idx).nracordo := 112812;
  
  
  vr_idx := vr_tab_acordos.count; --1015.780-8
  vr_tab_acordos(vr_idx).vlestorn := 1713.78;  
  vr_tab_acordos(vr_idx).nracordo := 312790;
  
  
  FOR idx IN vr_tab_acordos.first..vr_tab_acordos.count -1 LOOP
    
    rw_acordo := NULL;
    OPEN cr_acordo (pr_nracordo => vr_tab_acordos(idx).nracordo,
                    pr_cdsituac => NULL);
    FETCH cr_acordo INTO rw_acordo;
    CLOSE cr_acordo;
    
    dbms_output.put_line(rw_acordo.nrdconta||';'||vr_tab_acordos(idx).vlestorn);
  
    EstornarDespesas(  pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => rw_acordo.nrdconta
                      ,pr_nracordo => vr_tab_acordos(idx).nracordo
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_vllamnto => vr_tab_acordos(idx).vlestorn
                      ,pr_forcaPrej => vr_tab_acordos(idx).inprejcc
                      ,pr_cdcritic => vr_cdcritic 
                      ,pr_dscritic => vr_dscritic);
    
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      ROLLBACK;
      raise_application_error(-20500,'Erro '||vr_cdcritic||vr_dscritic);
    END IF;
    
    IF vr_tab_acordos(idx).vlabono > 0 THEN
      lancarAbono (  pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => rw_acordo.nrdconta
                    ,pr_nracordo => vr_tab_acordos(idx).nracordo
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                    ,pr_vldabono => vr_tab_acordos(idx).vlabono
                    ,pr_forcaPrej => vr_tab_acordos(idx).inprejcc
                    ,pr_cdcritic => vr_cdcritic 
                    ,pr_dscritic => vr_dscritic);
      
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        ROLLBACK; 
        raise_application_error(-20500,'Erro '||vr_cdcritic||vr_dscritic);
      END IF;  
    
    END IF;   
  
  END LOOP;
  
  dbms_output.put_line('Desbloquear Valor acordo');
  vr_tab_acordos.delete;
  -- 903.496-0   
  vr_idx := vr_tab_acordos.count;
  vr_tab_acordos(vr_idx).nracordo := 318067; 
  vr_tab_acordos(vr_idx).vlbloque := 202.33; 
  
  FOR idx IN vr_tab_acordos.first..vr_tab_acordos.count -1 LOOP
    
    rw_acordo := NULL;
    OPEN cr_acordo (pr_nracordo => vr_tab_acordos(idx).nracordo,
                    pr_cdsituac => NULL);
    FETCH cr_acordo INTO rw_acordo;
    CLOSE cr_acordo;
    
    dbms_output.put_line(rw_acordo.nrdconta||';'||vr_tab_acordos(idx).vlbloque);
  
    desbloquear( pr_cdcooper => pr_cdcooper
                ,pr_nrdconta => rw_acordo.nrdconta
                ,pr_nracordo => vr_tab_acordos(idx).nracordo
                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                ,pr_vllamnto => vr_tab_acordos(idx).vlbloque
                ,pr_cdcritic => vr_cdcritic 
                ,pr_dscritic => vr_dscritic);
    
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      ROLLBACK; 
      raise_application_error(-20500,'Erro '||vr_cdcritic||vr_dscritic);
    END IF; 
  
  END LOOP; 
  
  COMMIT;

END;
