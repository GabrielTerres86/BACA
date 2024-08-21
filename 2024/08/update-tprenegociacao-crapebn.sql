BEGIN
	
	UPDATE cecred.CRAPEBN SET tprenegociacao = 1 WHERE cdcooper = 16 and nrdconta = 81731701 and nrctremp = 64313625;
	UPDATE cecred.CRAPEBN SET tprenegociacao = 1 WHERE cdcooper = 16 and nrdconta = 81784007 and nrctremp = 64313626;
	UPDATE cecred.CRAPEBN SET tprenegociacao = 1 WHERE cdcooper = 16 and nrdconta = 82477663 and nrctremp = 64313593;
	UPDATE cecred.CRAPEBN SET tprenegociacao = 1 WHERE cdcooper = 16 and nrdconta = 82634050 and nrctremp = 64313608;
	UPDATE cecred.CRAPEBN SET tprenegociacao = 1 WHERE cdcooper = 16 and nrdconta = 82859361 and nrctremp = 64313622;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;