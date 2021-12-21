DECLARE
BEGIN  
	DELETE FROM cecred.tbcc_operacoes_diarias WHERE cdoperacao IN (24, 25);
	COMMIT;
END;
/