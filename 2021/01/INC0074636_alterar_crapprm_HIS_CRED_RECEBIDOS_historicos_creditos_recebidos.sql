BEGIN
    UPDATE crapprm
       SET dsvlrprm = dsvlrprm || '3318;3373;3374;3396;3336;'
     WHERE nmsistem = 'CRED'
       AND cdacesso = 'HIS_CRED_RECEBIDOS';
    COMMIT;
END;