BEGIN
	DELETE FROM tbgen_batch_relatorio_wrk w WHERE w.dtmvtolt IS NULL AND w.cdprograma = 'CRPS670';
	
	COMMIT;
END;