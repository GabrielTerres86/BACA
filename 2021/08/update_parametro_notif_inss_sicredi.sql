BEGIN

UPDATE crapprm a SET a.dsvlrprm = 'N'
 WHERE a.cdacesso = 'FLG_NOTIF_INSS_SICREDI';

COMMIT;  
END;
