BEGIN
	update CECRED.craprda
	   set insaqtot = 1,
		   vlsdrdca = 0
	 where cdcooper = 1
	   and nrdconta = 8270333;
	
	COMMIT;
END;