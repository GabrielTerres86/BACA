BEGIN
UPDATE cecred.crapprm
        SET dsvlrprm = '1131'
        WHERE
         nmsistem = 'CRED'
         AND cdacesso = 'BLQJ_FIM_MONITORAMENTO'             
         AND cdcooper = 0;  
COMMIT;
END;
