BEGIN	

	UPDATE credito.tbcred_pronampe_contrato
	 SET dtsolicitacaohonra = ''
		,vlsolicitacaohonra = 0
		,tpsituacaohonra    = 0
	WHERE cdcooper = 16
		AND nrdconta IN (99129663, 99508818, 99632306)
		AND nrcontrato IN (307513, 191308, 309438);
		
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
END;