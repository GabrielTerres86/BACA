BEGIN

	UPDATE credito.tbcred_pronampe_contrato
		 SET dtcancelamento = SYSDATE
	 WHERE cdcooper = 7
		 AND (nrdconta, nrcontrato) IN
				 ((82833753, 113708), (99693410, 113644), (99758725, 112573));

	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;