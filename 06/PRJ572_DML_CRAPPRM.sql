DECLARE
  --
BEGIN
	--
	INSERT INTO crapprm(nmsistem
										 ,cdcooper
										 ,cdacesso
										 ,dstexprm
										 ,dsvlrprm
										 )
							 VALUES('CRED'
										 ,0
										 ,'BLQ_COOP_CCRD_BANCOOB'
										 ,'Cooperativa bloqueada no processo de importa��o dos arquivos (CB093) de cart�es do bancoob.'
										 ,'1'
										 );
	--
	COMMIT;
	--
END;
