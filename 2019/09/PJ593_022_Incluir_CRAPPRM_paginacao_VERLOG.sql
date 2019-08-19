BEGIN
    
	INSERT INTO crapprm
		(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
	VALUES
		('CRED'
		,0
		,'VERLOG_NRITENS_PAGINACAO'
		,'Maximo de itens para paginacao na listagem da VERLOG.'
		,15);

    COMMIT;
END;
