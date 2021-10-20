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
                 vlabono  NUMBER,
                 nrctremp NUMBER);
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
  
  PROCEDURE pc_forcaTransBloqPrejCC ( pr_cdcooper IN NUMBER,
                                      pr_nrdconta IN NUMBER,
                                      pr_nracordo IN NUMBER,
                                      pr_dtmvtolt IN DATE,
                                      pr_vllamnto IN NUMBER,
                                      pr_cdcritic OUT NUMBER,
                                      pr_dscritic OUT VARCHAR2
                                    )IS 
  
    vr_nrseqdig NUMBER;
    vr_nrdocmto NUMBER;
    vr_incrineg NUMBER;
    vr_exc_erro EXCEPTION;
    vr_tab_retorno LANC0001.typ_reg_retorno;
    
  BEGIN
    
    vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                              ,pr_nmdcampo => 'NRSEQDIG'
                              ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                              to_char(pr_dtmvtolt, 'DD/MM/RRRR')||';'||
                              '1;100;650009');

    vr_nrdocmto := 999992722; 
    LOOP
            
        LANC0001.pc_gerar_lancamento_conta
                                   (pr_dtmvtolt => pr_dtmvtolt
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 650009
                                   , pr_nrdconta => pr_nrdconta
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 2719
                                   , pr_hrtransa => gene0002.fn_busca_time
                                   , pr_nrseqdig => vr_nrseqdig
                                   , pr_vllanmto => pr_vllamnto
                                   , pr_nrdctabb => pr_nrdconta
                                   , pr_cdpesqbb => 'ESTORNO DE PAGAMENTO DE PREJUÍZO DE C/C'
                                   , pr_dtrefere => pr_dtmvtolt
                                   , pr_cdoperad => 1
                                   , pr_cdcooper => pr_cdcooper
                                   , pr_cdorigem => 5
                                   , pr_incrineg => vr_incrineg
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => vr_cdcritic
                                   , pr_dscritic => vr_dscritic);
                                                                               
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        IF vr_incrineg = 0 THEN
          IF vr_cdcritic = 92 THEN
            vr_nrdocmto := vr_nrdocmto + 10000;
            continue;
        END IF;
          RAISE vr_exc_erro;
        ELSE
          RAISE vr_exc_erro;
        END IF;
      END IF;
            
      EXIT;
          
    END LOOP;      
    
    PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
                                , pr_nrdconta => pr_nrdconta
                                , pr_vlrlanc  => pr_vllamnto
                                , pr_dtmvtolt => pr_dtmvtolt
                                , pr_dsoperac => 'RECP0001 VLDESP INC0108929'
                                , pr_cdcritic => vr_cdcritic
                                , pr_dscritic => vr_dscritic); 
                                                        
    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                
      RAISE vr_exc_erro;
    END IF;
      
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      IF TRIM(pr_dscritic) IS NULL THEN
        pr_dscritic := 'Erro ao transf bloq prej CC';
      END IF;  
    WHEN OTHERS THEN 
      pr_dscritic := 'Erro ao pc_forcaTransBloqPrejCC valor: '||SQLERRM;  
  END pc_forcaTransBloqPrejCC;  
    
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
    
    IF rw_crapass.inprejuz = 0 AND 
       nvl(pr_forcaPrej,0) = 1 THEN       
      pc_forcaTransBloqPrejCC ( pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nracordo => pr_nracordo,
                                pr_dtmvtolt => pr_dtmvtolt,
                                pr_vllamnto => pr_vllamnto,
                                pr_cdcritic => pr_cdcritic,
                                pr_dscritic => pr_dscritic
                              ); 
      
      IF nvl(pr_cdcritic, 0) > 0 OR pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;   
      
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
    
    --> Caso a conta não estiver mais em prejuizo, e for necessario forcar
    IF rw_crapass.inprejuz = 0 AND 
       nvl(pr_forcaPrej,0) = 1 THEN
            
      pc_forcaTransBloqPrejCC ( pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nracordo => pr_nracordo,
                                pr_dtmvtolt => pr_dtmvtolt,
                                pr_vllamnto => pr_vldabono,
                                pr_cdcritic => pr_cdcritic,
                                pr_dscritic => pr_dscritic
                              ); 
      
      IF nvl(pr_cdcritic, 0) > 0 OR pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;   
     
    END IF;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      NULL;
    WHEN OTHERS THEN 
      pr_dscritic := 'Erro ao lancar abono valor: '||SQLERRM;  
  END LancarAbono; 
  
  PROCEDURE abonarPPAtivo ( pr_cdcooper IN NUMBER,
                            pr_nrdconta IN NUMBER,
                            pr_nracordo IN NUMBER,
                            pr_crapdat  IN btch0001.cr_crapdat%ROWTYPE,
                            pr_nrctremp IN NUMBER,
                            pr_vldabono OUT NUMBER,
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
    
    -- Consulta valor bloqueado pelo acordo
    CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                     ,pr_nrdconta crapepr.nrdconta%TYPE
                     ,pr_nrctremp crapepr.nrctremp%TYPE)IS
      SELECT epr.vlsdeved
            ,epr.vlsdevat
       FROM crapepr epr
           ,crawepr wpr
      WHERE epr.cdcooper = wpr.cdcooper
        AND epr.nrdconta = wpr.nrdconta
        AND epr.nrctremp = wpr.nrctremp
        AND epr.cdcooper = pr_cdcooper
        AND epr.nrdconta = pr_nrdconta
        AND epr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;
    
    vr_exc_erro EXCEPTION;
    vr_idvlrmin NUMBER;
  BEGIN
    
    -- Buscar os dados do cooperado
    OPEN  cr_crapass(pr_cdcooper
                    ,pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;
    
    OPEN cr_crapepr( pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctremp => pr_nrctremp);

    FETCH cr_crapepr INTO rw_crapepr;
    CLOSE cr_crapepr;
    
    -- Pagar empréstimo PP
    RECP0001.pc_pagar_emprestimo_pp(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta         
                                   ,pr_cdagenci => 1
                                   ,pr_crapdat  => pr_crapdat
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_nracordo => pr_nracordo
                                   ,pr_nrparcel => 0
                                   ,pr_vlsdeved => rw_crapepr.vlsdeved
                                   ,pr_vlsdevat => rw_crapepr.vlsdevat
                                   ,pr_vlparcel => 0
                                   ,pr_idorigem => 7 
                                   ,pr_nmtelant => 'JOB'
                                   ,pr_cdoperad => 1
                                   ,pr_inliqaco => 'S'
                                   ,pr_idvlrmin => vr_idvlrmin
                                   ,pr_vltotpag => pr_vldabono
                                   ,pr_cdcritic => pr_cdcritic         
                                   ,pr_dscritic => pr_dscritic);       
                        
    -- Se retornar erro da rotina
    IF pr_dscritic IS NOT NULL OR NVL(pr_cdcritic,0) > 0 THEN

      IF NVL(vr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      END IF;
      RAISE vr_exc_erro;
                         
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      NULL;
    WHEN OTHERS THEN 
      pr_dscritic := 'Erro abonar PP avito valor: '||SQLERRM;  
  END abonarPPAtivo;    


BEGIN
  
  -- Leitura do calendário da cooperativa
  OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat into rw_crapdat;  
  CLOSE btch0001.cr_crapdat;
 
  dbms_output.put_line('Estornar Despesa');
  vr_tab_acordos.delete;

  vr_idx := vr_tab_acordos.count; --1056.011-4  
  vr_tab_acordos(vr_idx).vlestorn := 105.29;  
  vr_tab_acordos(vr_idx).nracordo := 343726;
  vr_tab_acordos(vr_idx).inprejcc := 1;
  vr_tab_acordos(vr_idx).vlabono  := 0.18;  
  
  vr_idx := vr_tab_acordos.count; --981.807-3
  vr_tab_acordos(vr_idx).vlestorn := 280.11;  
  vr_tab_acordos(vr_idx).nracordo := 259897;  

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

  
  dbms_output.put_line('Abonar Contrato acordo');
  vr_tab_acordos.delete;
  vr_idx := vr_tab_acordos.count; --981.807-3
  vr_tab_acordos(vr_idx).vlestorn := 280.11;  
  vr_tab_acordos(vr_idx).nracordo := 259897; 
  vr_tab_acordos(vr_idx).nrctremp := 1213160;
  vr_tab_acordos(vr_idx).vlabono  := 0;
  
  FOR idx IN vr_tab_acordos.first..vr_tab_acordos.count -1 LOOP
    
    rw_acordo := NULL;
    OPEN cr_acordo (pr_nracordo => vr_tab_acordos(idx).nracordo,
                    pr_cdsituac => NULL);
    FETCH cr_acordo INTO rw_acordo;
    CLOSE cr_acordo;
    
    dbms_output.put_line(rw_acordo.nrdconta||';'||vr_tab_acordos(idx).vlestorn);
  
    abonarPPAtivo ( pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => rw_acordo.nrdconta
                   ,pr_nracordo => vr_tab_acordos(idx).nracordo
                   ,pr_crapdat  => rw_crapdat
                   ,pr_nrctremp => vr_tab_acordos(idx).nrctremp
                   ,pr_vldabono => vr_tab_acordos(idx).vlabono
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
  
  COMMIT;
   
END;
