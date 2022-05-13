BEGIN
	UPDATE crapaca c
	   SET c.lstparam = lstparam || ',pr_tpcustei'
	 WHERE c.nmpackag = 'SEGU0001'
	   AND c.nmdeacao = 'CRIA_PROPOSTA_SEGURO';
	 
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/

