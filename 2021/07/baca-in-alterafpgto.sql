BEGIN
	INSERT INTO crapaca(nmdeacao
										 ,nmpackag
										 ,nmproced
										 ,lstparam
										 ,nrseqrdr
										 ) 
							 VALUES('ALTERA_FORMA_PAGTO'
										 ,NULL
										 ,'CREDITO.alterarFormaPagtoWeb	'
										 ,'pr_nrdconta,pr_nrcontrato'
										 ,1045
										 );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
