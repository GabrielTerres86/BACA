BEGIN

UPDATE	CECRED.crapprm
SET	DSVLRPRM = 'LEGADO_EMPRESTIMOS_PF'
WHERE	CDACESSO = 'REGRA_PF_MOTOR_9'
AND	CDCOOPER = 0;


UPDATE	CECRED.crapprm
SET	DSVLRPRM = 'LEGADO_EMPRESTIMOS_PJ'
WHERE	CDACESSO = 'REGRA_PJ_MOTOR_9'
AND	CDCOOPER = 0;

COMMIT;

END;
