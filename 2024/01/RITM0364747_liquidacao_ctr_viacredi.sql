BEGIN
	UPDATE crapepr
		 SET dtliquid = to_date('16/01/2024', 'DD/MM/YYYY')
			,inliquid = 1
			,vlsdeved = 0
			,vlsdevat = 0
	 WHERE cdcooper = 1
		 AND nrdconta IN
				 (8158487,12620882,7523904,10526439,12999032,15941914,16033035)
		 AND nrctremp IN
				 (7788867,7791276,7786996,7787578,7789162,7758795,7785361);

	UPDATE crappep
		 SET inliquid = 1
			,vlsdvpar = 0
			,vlsdvatu = 0
			,vlsdvsji = 0
			,vlpagpar = 0
	 WHERE cdcooper = 1
		 AND nrdconta IN
				 (8158487,12620882,7523904,10526439,12999032,15941914,16033035)
		 AND nrctremp IN
				 (7788867,7791276,7786996,7787578,7789162,7758795,7785361)
		 AND inliquid = 0;

	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
END;