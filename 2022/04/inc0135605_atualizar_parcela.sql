BEGIN
	UPDATE crappep
	SET vlsdvpar = 0, vlsdvatu = 0, inliquid = 1, vlpagpar = 976.28
	WHERE cdcooper = 10
		AND nrdconta = 78883
		AND nrctremp = 15763
		AND nrparepr = 17;
	COMMIT;
END;