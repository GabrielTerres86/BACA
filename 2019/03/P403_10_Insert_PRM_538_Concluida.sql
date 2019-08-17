BEGIN
INSERT INTO crapprm (SELECT 'CRED',cdcooper,'FLG_CRPS538_CONCLUIDA','Define se a crps538 foi concluida no processo noturno','1',NULL FROM crapcop where flgativo = 1);
COMMIT; 
END;
