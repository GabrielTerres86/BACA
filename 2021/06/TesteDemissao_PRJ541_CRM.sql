BEGIN
	update crapass set dtdemiss = to_date('16/06/2021','DD/MM/RRRR'), cdsitdct = 4 WHERE cdcooper = 16 and nrdconta = 895202;
	update crapass set dtdemiss = to_date('16/06/2021','DD/MM/RRRR'), cdsitdct = 4 WHERE cdcooper = 8 and nrdconta = 56618;
	update crapass set dtdemiss = to_date('16/06/2021','DD/MM/RRRR'), cdsitdct = 4 WHERE cdcooper = 1 and nrdconta = 12880663;

	COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;