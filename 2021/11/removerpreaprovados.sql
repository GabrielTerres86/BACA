BEGIN

delete from CREDITO.TBCRED_CARGA_PREAPROV  where cdcooper = 11 and idcarga in (2,51);

delete from CREDITO.TBCRED_CARGA_PREAPROV_DET  where cdcooper = 11 and iddcarga in (2,51);

delete from CREDITO.TBCRED_PREAPROV where cdcooper = 11 and idcarga = 2;

delete from CREDITO.TBCRED_PREAPROV_DET where cdcooper = 11 and iddcarga = 2;
    
  COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
     ROLLBACK;
END;
       