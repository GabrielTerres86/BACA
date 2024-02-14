BEGIN
	DELETE FROM credito.tbcred_peac_contrato_parcela WHERE idpeac_contrato > 2076;
	DELETE FROM credito.tbcred_peac_contrato WHERE idpeac_contrato > 2076;
	COMMIT;
END;