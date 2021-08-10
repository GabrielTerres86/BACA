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
										 ,'pr_nrdconta, pr_nrcontrato'
										 ,1045
										 );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
