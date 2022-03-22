BEGIN
    UPDATE crapprm crapprm 
       SET crapprm.dsvlrprm = 'A'
     WHERE crapprm.cdcooper = 7    
       AND crapprm.cdacesso = 'FLG_PAG_FGTS' 
       AND crapprm.nmsistem = 'CRED';
    
    COMMIT;
END;