
DECLARE
	BEGIN
	  
	  UPDATE tbpix_chave_enderecamento
		SET FLGCHAVE_FAVORITA = 'S';
		
	  COMMIT;	
	
	EXCEPTION
	  WHEN OTHERS THEN
		ROLLBACK;
END;		
/