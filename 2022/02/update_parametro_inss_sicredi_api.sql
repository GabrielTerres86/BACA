BEGIN
    UPDATE crapprm  a SET a.dsvlrprm = 'N' WHERE a.cdacesso = 'FLG_UTL_API_PV_SICREDI';
    COMMIT;
END;
