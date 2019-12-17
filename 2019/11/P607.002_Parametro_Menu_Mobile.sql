BEGIN
	INSERT INTO menumobile
		(menumobileid, menupaiid, nome, sequencia, habilitado, autorizacao, versaominimaapp, versaomaximaapp)
	VALUES
		(1005, 900, ' Ailos Pag', 1, 1, 1, '2.6.0.0', NULL);
    COMMIT;
END;
