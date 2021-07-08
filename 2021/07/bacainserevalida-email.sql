BEGIN
	INSERT INTO crapaca(nmdeacao
										 ,nmpackag
										 ,nmproced
										 ,lstparam
										 ,nrseqrdr
										 ) 
							 VALUES('VALIDA_EMAIL'
										 ,NULL
										 ,'CREDITO.validaEmailContasWeb'
										 ,'pr_nrdconta'
										 ,1045);
										 
  COMMIT;
END;
