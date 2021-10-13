
DECLARE
	BEGIN
	  
	  UPDATE tbpix_chave_enderecamento
		SET FLGCHAVE_FAVORITA = 'S';
		
	EXCEPTION
	  WHEN OTHERS THEN
		ROLLBACK;
END;		
/