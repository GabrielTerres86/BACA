BEGIN
	INSERT INTO crapaca(nmdeacao
										 ,nmpackag
										 ,nmproced
										 ,lstparam
										 ,nrseqrdr
										 ) 
							 VALUES('VALIDA_EMAIL_JFF'
										 ,NULL
										 ,'CREDITO.validaEmailContasWeb'
										 ,'pr_nrdconta'
										 ,1045
										 );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;