BEGIN
  UPDATE tbcred_pronampe_contrato
     SET dtsolicitacaohonra = TRUNC(SYSDATE)
        ,vlsolicitacaohonra = 23965.51
        ,tpsituacaohonra    = 1
   WHERE cdcooper = 9
     AND nrdconta = 185272
     AND nrcontrato = 35014;
  UPDATE tbcred_pronampe_contrato
     SET dtsolicitacaohonra = TRUNC(SYSDATE)
        ,vlsolicitacaohonra = 16052.38
        ,tpsituacaohonra    = 1
   WHERE cdcooper = 10
     AND nrdconta = 105490
     AND nrcontrato = 15652;
  UPDATE tbcred_pronampe_contrato
     SET dtsolicitacaohonra = TRUNC(SYSDATE)
        ,vlsolicitacaohonra = 11368.37
        ,tpsituacaohonra    = 1
   WHERE cdcooper = 10
     AND nrdconta = 121223
     AND nrcontrato = 15258;
  UPDATE tbcred_pronampe_contrato
     SET dtsolicitacaohonra = TRUNC(SYSDATE)
        ,vlsolicitacaohonra = 29897.33
        ,tpsituacaohonra    = 1
   WHERE cdcooper = 10
     AND nrdconta = 151009
     AND nrcontrato = 15323;
  UPDATE tbcred_pronampe_contrato
     SET dtsolicitacaohonra = TRUNC(SYSDATE)
        ,vlsolicitacaohonra = 11554.36
        ,tpsituacaohonra    = 1
   WHERE cdcooper = 16
     AND nrdconta = 269115
     AND nrcontrato = 188394;

  INSERT INTO tbcred_pronampe_remessa
    (nrremessa
    ,dtremessa
    ,dhgeracao
    ,cdsituacao)
  VALUES
    (92
    ,TRUNC(SYSDATE)
    ,SYSDATE
    ,1);
    
    COMMIT;
    
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500,
                            'Erro ao gravar TBCRED_PRONAMPE_REMESSA: ' ||
                            SQLERRM);
END;
