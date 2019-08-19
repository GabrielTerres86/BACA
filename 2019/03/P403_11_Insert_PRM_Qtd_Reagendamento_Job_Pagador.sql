BEGIN
INSERT INTO crapprm (SELECT 'CRED',cdcooper,'QTD_VEZ_REAGEN_JOB_PAGAD','Contador da quantidade de vezes que ocorreu a criação do reagendamento do job de analise do pagador','0',NULL FROM crapcop where flgativo = 1);
INSERT INTO crapprm (SELECT 'CRED',cdcooper,'QTD_MAX_REAGEN_JOB_PAGAD','Quantidade máxima de criação do reagendamento do job de analise do pagador','0',NULL FROM crapcop where flgativo = 1);
COMMIT; 
END;
