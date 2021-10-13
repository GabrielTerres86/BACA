

DECLARE
	BEGIN
	  
	  UPDATE tbpix_chave_enderecamento
		SET FLGCHAVE_FAVORITA = 'N';
		
	EXCEPTION
	  WHEN OTHERS THEN
		ROLLBACK;
END;		
/