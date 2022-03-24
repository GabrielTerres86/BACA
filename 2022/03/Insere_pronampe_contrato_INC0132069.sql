BEGIN
  INSERT
    INTO CREDITO.TBCRED_PRONAMPE_CONTRATO(CDCOOPER
                                         ,NRDCONTA
                                         ,NRCONTRATO
                                         ,IDCONTRATO
                                         ,DTVLRCREDIT)
                                   VALUES(1
                                         ,7066600
                                         ,2900346
                                         ,3075749
                                         ,TO_DATE('03/09/2020','DD/MM/RRRR'));
                                         
  INSERT
    INTO CREDITO.TBCRED_PRONAMPE_CONTRATO(CDCOOPER
                                         ,NRDCONTA
                                         ,NRCONTRATO
                                         ,IDCONTRATO
                                         ,DTVLRCREDIT)
                                   VALUES(1
                                         ,8844933
                                         ,2901576
                                         ,3077429
                                         ,TO_DATE('02/09/2020','DD/MM/RRRR'));   
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;  
