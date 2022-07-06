BEGIN

	UPDATE crapaca c
	SET c.lstparam = lstparam || ',pr_nrctremp'
    WHERE c.nmpackag = 'SEGU0003'
	AND c.nmdeacao = 'BUSCA_CONTRATOS_PRESTAMISTA';
	
  COMMIT;
  EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;	
END;