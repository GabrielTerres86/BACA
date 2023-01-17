BEGIN
  
    INSERT INTO cecred.crapprm 
      (NMSISTEM, 
       CDCOOPER, 
       CDACESSO, 
       DSTEXPRM, 
       DSVLRPRM)
    VALUES 
      ('CRED', 
       0, 
       'QTD_COMMIT_CRPS145', 
       'Quantidade de commit para o programa CRPS145', 
       '10000');

  COMMIT;
END;
