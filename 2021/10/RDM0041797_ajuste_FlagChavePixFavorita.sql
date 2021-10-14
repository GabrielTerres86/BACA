
DECLARE
	BEGIN
	  
	  UPDATE tbpix_chave_enderecamento
		SET FLGCHAVE_FAVORITA = 'S'
	  WHERE IDCHAVE = 188494;
		
	  COMMIT;	
	
	EXCEPTION
	  WHEN OTHERS THEN
		ROLLBACK;
END;		
/