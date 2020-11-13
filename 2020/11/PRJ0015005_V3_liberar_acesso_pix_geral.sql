BEGIN
	UPDATE tbpix_crapass SET flliberacao_restrita = 1 WHERE dtdemiss IS NULL;
	COMMIT;
END;