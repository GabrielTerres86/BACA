BEGIN
	UPDATE CRAPCEM
	   SET DSDEMAIL = 'juantalissonnazario@gmail.com'
	 WHERE CDCOOPER = 1
	   AND NRDCONTA = 10228209;
	COMMIT;
END;