BEGIN
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
                                           ,TO_DATE('03/09/2020 20:00:36','DD/MM/RRRR HH24:MI:SS'));
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      UPDATE CREDITO.TBCRED_PRONAMPE_CONTRATO
         SET DTVLRCREDIT = TO_DATE('03/09/2020 20:00:36','DD/MM/RRRR HH24:MI:SS')
       WHERE CDCOOPER = 1
         AND NRDCONTA = 7066600
         AND NRCONTRATO = 2900346;
  END;                                             
  
  BEGIN                                       
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
                                           ,TO_DATE('02/09/2020 20:00:36','DD/MM/RRRR HH24:MI:SS'));  
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      UPDATE CREDITO.TBCRED_PRONAMPE_CONTRATO
         SET DTVLRCREDIT = TO_DATE('02/09/2020 20:00:36','DD/MM/RRRR HH24:MI:SS')
       WHERE CDCOOPER = 1
         AND NRDCONTA = 8844933
         AND NRCONTRATO = 2901576;
  END;                                              
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;  