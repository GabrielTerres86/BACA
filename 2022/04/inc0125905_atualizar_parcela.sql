BEGIN
	UPDATE crappep
	SET dtvencto = add_months(dtvencto,7)
	WHERE  
		cdcooper = 1
		AND nrdconta = 13352881
		AND nrctremp = 4602620;
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
	RAISE_APPLICATION_ERROR(-20500, SQLERRM);
	ROLLBACK;
END;