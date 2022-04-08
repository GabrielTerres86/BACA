BEGIN
    UPDATE crapprm crapprm 
       SET crapprm.dsvlrprm = 'A'
     WHERE crapprm.cdcooper IN (8,9,10,12,14)     
       AND crapprm.cdacesso = 'FLG_PAG_FGTS' 
       AND crapprm.nmsistem = 'CRED';
    
    COMMIT;
END;