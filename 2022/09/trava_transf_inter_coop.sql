BEGIN
	INSERT INTO cecred.crapprm 
	  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
	VALUES 
	  ('CRED', 0, 'TRAVA_TRANSF_INTER_ATIVO', 'Desabilita transferencia inter cooperativa', '1');
	COMMIT;
END;	
/