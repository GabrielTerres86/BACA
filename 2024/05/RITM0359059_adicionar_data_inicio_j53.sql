BEGIN 
  INSERT INTO CECRED.crapprm
    (nmsistem
    ,cdcooper
    ,cdacesso
    ,dstexprm
    ,dsvlrprm)
  VALUES 
    ('CRED'
    ,0
    ,'DT_LIM_CNAB240_SEM_J53'
    ,'Data limite para aceite de arquivos CNAB240 sem o J53.'
    , '30/06/2024');
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN 
    ROLLBACK;  
END;
