--Rollback de todas as rotinas
UPDATE CRAPPRM SET DSVLRPRM = 'N' WHERE CDACESSO LIKE '%REVT_OR_PC_%' AND cdcooper = 0 AND NMSISTEM = 'CRED';