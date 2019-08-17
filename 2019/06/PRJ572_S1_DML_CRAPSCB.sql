BEGIN
	--
	UPDATE crapscb scb
		 SET scb.dsdirarq = '/usr/connect/bancoob'
	 WHERE scb.tparquiv = 6;
	--
	COMMIT;
	--
EXCEPTION
	WHEN OTHERS THEN
	  ROLLBACK;
		dbms_output.put_line('Erro: ' || SQLERRM);
END;  
