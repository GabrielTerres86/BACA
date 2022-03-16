BEGIN
	INSERT INTO crapprm (
		NMSISTEM,
		CDCOOPER,
		CDACESSO,
		DSTEXPRM,
		DSVLRPRM
	) VALUES (
		'CRED',
		0,
		'BLOQ_DESC_EMPR_CONSIG',
		'Bloqueio para não descontar os empréstimos do consignado quando o batch da FIS ou o ODI não executar',
		'0'
	);
	
    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir registro crapprm - '||sqlerrm);
END;
