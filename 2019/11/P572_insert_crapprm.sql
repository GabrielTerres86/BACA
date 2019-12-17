BEGIN
	insert into crapprm (NMSISTEM
				, CDCOOPER
				, CDACESSO
				, DSTEXPRM
				, DSVLRPRM)
		   values ('CRED'
				, 0
				, 'REL_CESSAO_N_LOCALIZADA'
				, 'Email das pessoas responsáveis por receber o relatorio de cessao nao localizada'
				, 'recuperareport@ailos.coop.br');
	COMMIT;
EXCEPTION
	when others then
		RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir CRAPPRM: '||SQLERRM);
END;