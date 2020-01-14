--Rollback para a rotina gera devolucao capital
UPDATE CRAPPRM SET DSVLRPRM = 'N' WHERE CDACESSO = 'REVT_OR_PC_GERA_DEV_CAPT' AND cdcooper = 0 AND NMSISTEM = 'CRED';