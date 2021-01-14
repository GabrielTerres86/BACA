PL/SQL Developer Test script 3.0
104
DECLARE
  CURSOR c_crapepr(prc_cdcooper craplem.cdcooper%TYPE
                  ,prc_nrdconta craplem.nrdconta%TYPE
                  ,prc_nrctremp craplem.nrctremp%TYPE) IS
    SELECT epr.cdcooper
          ,epr.dtmvtolt
          ,ass.cdagenci
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.txjuremp
          ,epr.vlpreemp
          ,epr.qtpreemp
      FROM crapepr epr
          ,crapass ass
     WHERE epr.cdcooper = ass.cdcooper
       AND epr.nrdconta = ass.nrdconta
       AND epr.cdcooper = prc_cdcooper
       AND epr.nrdconta = prc_nrdconta
       AND epr.nrctremp = prc_nrctremp;

  r_crapepr c_crapepr%ROWTYPE;

  vr_cdcritic NUMBER(3);
  vr_dscritic VARCHAR2(1000);
  vr_erro EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_dtmvtolt DATE;

BEGIN
  -- Verifica se a data esta cadastrada
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => 1);
  FETCH BTCH0001.cr_crapdat
    INTO rw_crapdat;

  CLOSE BTCH0001.cr_crapdat;

  vr_dtmvtolt := rw_crapdat.dtmvtolt;

  OPEN c_crapepr(1, 9221557, 2605757);
  FETCH c_crapepr
    INTO r_crapepr;
  IF c_crapepr%FOUND THEN
  
    EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => r_crapepr.cdcooper
                                   ,pr_dtmvtolt => vr_dtmvtolt 
                                   ,pr_cdagenci => r_crapepr.cdagenci 
                                   ,pr_cdbccxlt => 100 
                                   ,pr_cdoperad => 1 
                                   ,pr_cdpactra => r_crapepr.cdagenci 
                                   ,pr_tplotmov => 5
                                   ,pr_nrdolote => 600031 
                                   ,pr_nrdconta => r_crapepr.nrdconta
                                   ,pr_cdhistor => 1705                            
                                   ,pr_nrctremp => r_crapepr.nrctremp 
                                   ,pr_vllanmto => 155.08 
                                   ,pr_dtpagemp => '07/12/2020'                            
                                   ,pr_txjurepr => r_crapepr.txjuremp 
                                   ,pr_vlpreemp => r_crapepr.vlpreemp 
                                   ,pr_nrsequni => 0 
                                   ,pr_nrparepr => 6 
                                   ,pr_flgincre => FALSE 
                                   ,pr_flgcredi => FALSE                             
                                   ,pr_nrseqava => 0 
                                   ,pr_cdorigem => 5
                                   ,pr_cdcritic => vr_cdcritic 
                                   ,pr_dscritic => vr_dscritic); 
                                   
    EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => r_crapepr.cdcooper 
                                   ,pr_dtmvtolt => vr_dtmvtolt 
                                   ,pr_cdagenci => r_crapepr.cdagenci --Codigo Agencia
                                   ,pr_cdbccxlt => 100 --Codigo Caixa
                                   ,pr_cdoperad => 1 --Operador
                                   ,pr_cdpactra => r_crapepr.cdagenci --Posto Atendimento
                                   ,pr_tplotmov => 5 --Tipo movimento
                                   ,pr_nrdolote => 600031 --Numero Lote
                                   ,pr_nrdconta => r_crapepr.nrdconta --Numero da Conta
                                   ,pr_cdhistor => 3272 --Codigo Historico                            
                                   ,pr_nrctremp => r_crapepr.nrctremp --Numero Contrato
                                   ,pr_vllanmto => 13.81 --Valor Lancamento
                                   ,pr_dtpagemp => '07/12/2020' --Data Pagamento Emprestimo                            
                                   ,pr_txjurepr => r_crapepr.txjuremp --Taxa Juros Emprestimo
                                   ,pr_vlpreemp => r_crapepr.vlpreemp --Valor Emprestimo
                                   ,pr_nrsequni => 0 --Numero Sequencia
                                   ,pr_nrparepr => 6 --Numero Parcelas Emprestimo
                                   ,pr_flgincre => FALSE --Indicador Credito
                                   ,pr_flgcredi => FALSE --Credito                            
                                   ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                   ,pr_cdorigem => 5
                                   ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                   ,pr_dscritic => vr_dscritic); --Descricao Erro                                   
  
    CLOSE c_crapepr;
  
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_erro;
    END IF;
  
   -- COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
0
0
