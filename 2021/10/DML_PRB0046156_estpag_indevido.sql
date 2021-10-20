DECLARE

  pr_cdcooper NUMBER := 1;
  pr_nrdconta NUMBER := 1919750;  
  pr_nrctremp_est NUMBER := 444442;
  pr_nrctremp_pag NUMBER := 177351;
  pr_dscritic     VARCHAR2(2000);
  pr_cdcritic     NUMBER;
  pr_vlparcel     NUMBER := 168.66;
  
  pr_nracordo NUMBER := 321946;
  pr_nrparcel NUMBER := 4;
  pr_cdoperad NUMBER := 1;
  pr_nmtelant VARCHAR2(50) := 'CRPS538';
  
  pr_dtestorn     DATE := to_date('14/10/2021','DD/MM/RRRR');
  
  vr_tab_erro gene0001.typ_tab_erro ;
  vr_des_reto VARCHAR2(2000);  
  vr_exc_erro EXCEPTION;
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(2000);
  vr_idx      PLS_INTEGER;
  vr_idvlrmin NUMBER;
  vr_vltotpag NUMBER;
  
  
BEGIN
  
  -- Leitura do calendário da cooperativa
  OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat into rw_crapdat;  
  CLOSE btch0001.cr_crapdat;
  
  PREJ0002.pc_estorno_pagamento ( pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => 1
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp_est
                                 ,pr_dtmvtolt => pr_dtestorn
                                 ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                 ,pr_tab_erro => vr_tab_erro);
  IF vr_des_reto = 'NOK' THEN
    IF vr_tab_erro.exists(vr_tab_erro.first) THEN
      pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
    ELSE
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel executar estorno do Pagamento do Prejuízo.';
    END IF;
    RAISE vr_exc_erro;
  END IF;
  
  -- Efetuar o calculo do lançamento a ser creditado na conta corrente
  RECP0001.pc_pagar_contrato_emprestimo( pr_cdcooper => pr_cdcooper-- Código da Cooperativa
                                        ,pr_nrdconta => pr_nrdconta-- Número da Conta
                                        ,pr_cdagenci => 1          -- Código da agencia
                                        ,pr_crapdat  => rw_crapdat -- Datas da cooperativa
                                        ,pr_nrctremp => pr_nrctremp_pag-- Número do contrato de empréstimo 
                                        ,pr_nracordo => pr_nracordo-- Número do acordo
                                        ,pr_nrparcel => pr_nrparcel-- Número da parcela
                                        ,pr_cdoperad => pr_cdoperad-- Código do operador
                                        ,pr_vlparcel => pr_vlparcel-- Valor pago do boleto do acordo
                                        ,pr_idorigem => 7 -- Indicador da origem
                                        ,pr_nmtelant => pr_nmtelant -- Nome da tela 
                                        ,pr_idvlrmin => vr_idvlrmin-- Indica que houve critica do valor minimo
                                        ,pr_vltotpag => vr_vltotpag-- Retorno do valor pago
                                        ,pr_cdcritic => pr_cdcritic-- Código de críticia
                                        ,pr_dscritic => pr_dscritic-- Descrição da crítica
                                        );
  IF nvl(pr_cdcritic, 0) > 0 OR pr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  
  COMMIT;
  
EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      raise_application_error(-20500,pr_cdcritic||'-'||pr_dscritic);
    WHEN OTHERS THEN 
      ROLLBACK;
      pr_dscritic := 'Erro EstornarContratoPagarAcordo: '||SQLERRM; 
      raise_application_error(-20500,pr_cdcritic||'-'||pr_dscritic);   
END;  
