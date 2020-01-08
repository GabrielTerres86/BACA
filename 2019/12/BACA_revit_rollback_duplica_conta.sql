--Rollback para a rotina duplica conta 
UPDATE CRAPPRM SET DSVLRPRM = 'N' WHERE CDACESSO = 'REVT_OR_PC_DUPLICA_CONTA' AND cdcooper = 0 AND NMSISTEM = 'CRED';