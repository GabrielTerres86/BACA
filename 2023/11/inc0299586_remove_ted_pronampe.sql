BEGIN
  UPDATE CREDITO.TBCRED_PRONAMPE_REMESSA
     SET TBCRED_PRONAMPE_REMESSA.DTENVIOSPB       = NULL
        ,TBCRED_PRONAMPE_REMESSA.CDCTRLIFENVIOSPB = NULL
   WHERE TBCRED_PRONAMPE_REMESSA.NRREMESSA IN (409, 412, 413, 414);
   
  COMMIT;
  
  DELETE 
    FROM CREDITO.tbcred_pronampe_infdiario r
   WHERE r.idregistro IN (25147, 25148, 25149, 25150);
   
  COMMIT;
  
END;     