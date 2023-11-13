BEGIN
    update CECRED.crapprm p set p.dsvlrprm  = 'ftp.1347' where p.cdacesso = 'CUST_CHQ_ARQ_PASS_FTP';

    update CECRED.crapprm p set p.dsvlrprm  = 'ftpcustodia' where p.cdacesso = 'CUST_CHQ_ARQ_USER_FTP';

    update CECRED.crapprm p set p.dsvlrprm  = 'fileex' where p.cdacesso = 'CUST_CHQ_ARQ_SERV_FTP';

    COMMIT;
END;
/