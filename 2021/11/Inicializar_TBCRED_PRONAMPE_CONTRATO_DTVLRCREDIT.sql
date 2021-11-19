DECLARE
  CURSOR cr_dthr_credit_pronampe IS
    SELECT e.cdcooper, e.nrdconta, e.nrctremp, l.dttrans 
    FROM craplcm l,crapepr e
    WHERE e.cdcooper = l.cdcooper
      AND e.nrdconta = l.nrdconta
      AND e.nrctremp = l.nrdocmto
      AND e.cdlcremp in (2600,2610)
      AND l.cdhistor = 3280
      AND l.dttrans IS NOT NULL;
BEGIN
  -- Atualiza data do crédito dos contratos Pronampe onde o lançamento na craplem teve como numero de documento o numero do contrato
  FOR ret_dthr_credit_pronampe IN cr_dthr_credit_pronampe LOOP
    UPDATE CREDITO.TBCRED_PRONAMPE_CONTRATO a
    SET a.DTVLRCREDIT = ret_dthr_credit_pronampe.dttrans
    WHERE a.cdcooper = ret_dthr_credit_pronampe.cdcooper
      AND a.nrdconta = ret_dthr_credit_pronampe.nrdconta
      AND a.nrcontrato = ret_dthr_credit_pronampe.nrctremp;  
  END LOOP;
  
  -- Atualiza data do crédito de casos específicos de contratos Pronampe onde o lançamento na craplem teve como numero de documento um numero diferente do numero do contrato, mas sabemos que se trata de um lançamento do respectivo contrato por termos realizado uma análise caso a caso (INC0111224)
  UPDATE CREDITO.TBCRED_PRONAMPE_CONTRATO a
  SET DTVLRCREDIT = (SELECT l.dttrans FROM craplcm l
                     WHERE l.cdcooper = 1
                       AND l.dtmvtolt = to_date('12/07/2021', 'DD/MM/YYYY')
                       AND l.nrdconta = 9643524
                       AND l.nrdocmto = 4201886
                       AND l.cdhistor = 3280
                       AND l.dttrans IS NOT NULL)
  WHERE a.cdcooper = 1
    AND a.nrdconta = 9643524
    AND a.nrcontrato = 4201886;
  
  UPDATE CREDITO.TBCRED_PRONAMPE_CONTRATO a
  SET DTVLRCREDIT = (SELECT l.dttrans FROM craplcm l
                     WHERE l.cdcooper = 1
                       AND l.dtmvtolt = to_date('15/07/2021', 'DD/MM/YYYY')
                       AND l.nrdconta = 9643524
                       AND l.nrdocmto = 4201886
                       AND l.cdhistor = 3280
                       AND l.dttrans IS NOT NULL)
  WHERE a.cdcooper = 1
    AND a.nrdconta = 9643524
    AND a.nrcontrato = 4216254;
  
  UPDATE CREDITO.TBCRED_PRONAMPE_CONTRATO a
  SET DTVLRCREDIT = (SELECT l.dttrans FROM craplcm l
                     WHERE l.cdcooper = 16
                       AND l.dtmvtolt = to_date('26/07/2021', 'DD/MM/YYYY')
                       AND l.nrdconta = 78140
                       AND l.nrdocmto = 9411
                       AND l.cdhistor = 3280
                       AND l.dttrans IS NOT NULL)
  WHERE a.cdcooper = 16
    AND a.nrdconta = 78140
    AND a.nrcontrato = 309411;  
  
  UPDATE CREDITO.TBCRED_PRONAMPE_CONTRATO a
  SET DTVLRCREDIT = (SELECT l.dttrans FROM craplcm l
                     WHERE l.cdcooper = 16
                       AND l.dtmvtolt = to_date('21/07/2021', 'DD/MM/YYYY')
                       AND l.nrdconta = 377848
                       AND l.nrdocmto = 308589
                       AND l.cdhistor = 3280
                       AND l.dttrans IS NOT NULL)
  WHERE a.cdcooper = 16
    AND a.nrdconta = 377848
    AND a.nrcontrato = 306589; 
  
  UPDATE CREDITO.TBCRED_PRONAMPE_CONTRATO a
  SET DTVLRCREDIT = (SELECT l.dttrans FROM craplcm l
                     WHERE l.cdcooper = 16
                       AND l.dtmvtolt = to_date('28/07/2021', 'DD/MM/YYYY')
                       AND l.nrdconta = 437760
                       AND l.nrdocmto = 309812
                       AND l.cdhistor = 3280
                       AND l.dttrans IS NOT NULL)
  WHERE a.cdcooper = 16
    AND a.nrdconta = 437760
    AND a.nrcontrato = 309815;   
  
  UPDATE CREDITO.TBCRED_PRONAMPE_CONTRATO a
  SET DTVLRCREDIT = (SELECT l.dttrans FROM craplcm l
                     WHERE l.cdcooper = 16
                       AND l.dtmvtolt = to_date('22/07/2021', 'DD/MM/YYYY')
                       AND l.nrdconta = 537080
                       AND l.nrdocmto = 308507
                       AND l.cdhistor = 3280
                       AND l.dttrans IS NOT NULL)
  WHERE a.cdcooper = 16
    AND a.nrdconta = 537080
    AND a.nrcontrato = 307507; 

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;

