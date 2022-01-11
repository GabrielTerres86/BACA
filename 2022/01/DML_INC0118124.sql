DECLARE 

  pr_nrdconta NUMBER := 9920862;
  pr_cdcooper NUMBER := 1;
  pr_nrctremp NUMBER := 2407376;
  pr_vlrlanc  NUMBER := 1254.28;
  vr_vlEstDespesa NUMBER := 10.57;
  vr_dsincid VARCHAR2(50):= 'INC0118124';
  
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
  

  PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_vlrlanc  => pr_vlrlanc
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_dsoperac => 'RECP0001 Ajuste '||vr_dsincid
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic); 
                                                        
  IF nvl(vr_cdcritic, 0) > 0 OR 
     TRIM(vr_dscritic) IS NOT NULL THEN    
    RAISE vr_exc_erro;
  END IF;  
  
  TELA_ATENDA_DEPOSVIS.pc_paga_prejuz_cc(pr_cdcooper => pr_cdcooper,
                                         pr_nrdconta => pr_nrdconta,
                                         pr_vlrpagto => 627.14,
                                         pr_vlrabono => 0,
                                         pr_xmllog   => vr_xmllog,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic,
                                         pr_retxml   => vr_retxml,
                                         pr_nmdcampo => vr_nmdcampo,
                                         pr_des_erro => vr_des_erro);
  
  IF nvl(vr_cdcritic, 0) > 0 OR 
     TRIM(vr_dscritic) IS NOT NULL THEN    
    RAISE vr_exc_erro;
  END IF;
  
  
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
  
  
  vr_xmllog := 
'<?xml version="1.0" encoding="WINDOWS-1252"?>
<Root>
  <Dados>
    <cdcooper>'||pr_cdcooper||'</cdcooper>
    <nrdconta>'||pr_nrdconta||'</nrdconta>
    <nrctremp>'||pr_nrctremp||'</nrctremp>
    <vlrabono>0</vlrabono>
    <vlrpagto>'||vr_vlEstDespesa||'</vlrpagto>
    <nrseqava>0</nrseqava>
  </Dados>
  <params>
    <nmprogra>TELA_ATENDA_DEPOSVIS</nmprogra>
    <nmeacao>PAGA_EMPRESTIMO_CT</nmeacao>
    <cdcooper>'||pr_cdcooper||'</cdcooper>
    <cdagenci>0</cdagenci>
    <nrdcaixa>0</nrdcaixa>
    <idorigem>5</idorigem>
    <cdoperad>1</cdoperad>
    <filesphp>/var/www/ayllos/telas/atenda/dep_vista/paga_emprestimo.php</filesphp>
  </params>
</Root>';

  vr_retxml := XMLTYPE.createXML(vr_xmllog);
  
  TELA_ATENDA_DEPOSVIS.pc_paga_emprestimo_ct
                                 (pr_cdcooper => pr_cdcooper  --> Código da cooperativa (0-processa todas)
                                 ,pr_nrdconta => pr_nrdconta  --> Conta do cooperado
                                 ,pr_nrctremp => pr_nrctremp  --> Número do contrato de empréstimo
                                 ,pr_vlrabono => 0            --> valor de abono pago
                                 ,pr_vlrpagto => vr_vlEstDespesa  --> valor pago
                                 ,pr_xmllog   => vr_xmllog    --> XML com informações de LOG
                                 ,pr_cdcritic => vr_cdcritic  --> Código da crítica
                                 ,pr_dscritic => vr_dscritic  --> Descrição da crítica
                                 ,pr_retxml   => vr_retxml    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo => vr_nmdcampo  --> Nome do campo com erro
                                 ,pr_des_erro => vr_des_erro); 
  
  

  COMMIT;
  
EXCEPTION   
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20500,vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500,SQLERRM);  
END;
