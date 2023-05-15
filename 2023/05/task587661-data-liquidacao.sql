BEGIN
	UPDATE cecred.crapepr 
     SET dtliquid = NULL
   WHERE cdcooper = 16
     AND nrctremp = 406085
     AND nrdconta = 99985861;
	
	COMMIT;
	
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);
END;
