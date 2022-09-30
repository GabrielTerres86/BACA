BEGIN
	INSERT INTO crapprm 
	  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
	VALUES 
	  ('CRED', 0, 'TRAVA_TRANSF_INTRA_ATIVO', 'Desabilita transferencia inter cooperativa', '1');
	COMMIT;
END;	
/