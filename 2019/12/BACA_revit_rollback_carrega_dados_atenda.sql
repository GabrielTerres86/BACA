--Rollback para a rotina carrega dados atenda - tela atenda
UPDATE CRAPPRM SET DSVLRPRM = 'N' WHERE CDACESSO = 'REVT_OR_PC_CARR_DAD_ATEN' AND cdcooper = 0 AND NMSISTEM = 'CRED';