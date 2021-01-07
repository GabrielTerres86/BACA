BEGIN
	UPDATE craprel rel
	   SET rel.nrmodulo = 1
     WHERE rel.cdrelato = 664;

	COMMIT;
END;