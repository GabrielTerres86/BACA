BEGIN
	UPDATE tbpix_crapass SET flliberacao_restrita = 1 WHERE dtdemiss IS NULL AND flliberacao_restrita = 0;
	COMMIT;
END;