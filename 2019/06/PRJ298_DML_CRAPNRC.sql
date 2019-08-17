DECLARE
  --
BEGIN
	--
	UPDATE crapnrc nrc
		 SET nrc.flgativo = 1
	 WHERE nrc.cdcooper = 1
		 AND nrc.nrdconta = 8217556
		 AND nrc.nrctrrat = 801063009
		 AND nrc.tpctrrat = 90;
	--
	COMMIT;
	--
END;
