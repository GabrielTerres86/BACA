BEGIN
  INSERT
    INTO CREDITO.TBCRED_PRONAMPE_CONTRATO(CDCOOPER
                                         ,NRDCONTA
                                         ,NRCONTRATO
                                         ,IDCONTRATO)
                                   VALUES(1
                                         ,7066600
                                         ,2900346
                                         ,3075749);
                                         
  INSERT
    INTO CREDITO.TBCRED_PRONAMPE_CONTRATO(CDCOOPER
                                         ,NRDCONTA
                                         ,NRCONTRATO
                                         ,IDCONTRATO)
                                   VALUES(1
                                         ,8844933
                                         ,2901576
                                         ,3077429);   
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;  
