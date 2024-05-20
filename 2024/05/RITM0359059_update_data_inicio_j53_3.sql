BEGIN 
  UPDATE CECRED.crapprm prm
     SET prm.dstexprm = 'Data limite para aceite de arquivos CNAB240 sem o J53.'
        ,prm.dsvlrprm = '15/05/2024'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 0
     AND prm.cdacesso = 'DT_LIM_CNAB240_SEM_J53';
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN 
    ROLLBACK;  
END;
