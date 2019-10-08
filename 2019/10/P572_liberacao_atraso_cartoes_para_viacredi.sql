BEGIN
	UPDATE CRAPPRM prm
	SET prm.dsvlrprm = ''
	WHERE prm.nmsistem = 'CRED'
		AND prm.cdcooper = 0
		AND prm.cdacesso = 'BLQ_COOP_CCRD_BANCOOB';
	COMMIT;
EXCEPTION
	when others then
		dbms_output.put_line('Erro ao atualizar CRAPPRM. Param: BLQ_COOP_CCRD_BANCOOB');
		null;
END;